#!/usr/bin/env python3
"""
This is a simple script to run code coverage for some test files.
"""
# pylint: disable=invalid-name

import argparse
import os
import re
import subprocess
import sys
import tempfile

from os.path import exists, isdir, isfile
from os import getcwd

_ERR_PREFIX = "\033[31mcode-coverage-test-gap.py: error: "
_INFO_PREFIX = "\033[0m\033[1m"

_PARSER = argparse.ArgumentParser(
    prog="code-coverage-test-gap.py", usage="%(prog)s [options]"
)
_PARSER.add_argument(
    "tstfiles",
    nargs="+",
    type=str,
    help="the test files you want to check code coverage for"
    + "(must be at least one)",
)
_PARSER.add_argument(
    "--gap-root",
    nargs="?",
    type=str,
    help="the gap root directory (default: ~/gap)",
    default="~/gap/",
)
_PARSER.add_argument(
    "--open",
    nargs="?",
    type=str,
    help=("open the html page for this file (default: None)"),
    default=None,
)

_ARGS = _PARSER.parse_args()
if not _ARGS.gap_root[-1] == "/":
    _ARGS.gap_root += "/"

if exists("gap") and isdir("gap"):
    _PROFILE_DIR = "/gap/"
elif exists("lib") and isdir("lib"):
    _PROFILE_DIR = "/lib/"
else:
    sys.exit(f"{_ERR_PREFIX}no directory gap or lib to profile!\033[0m")

_ARGS.gap_root = os.path.expanduser(_ARGS.gap_root)
if not (exists(_ARGS.gap_root) and isdir(_ARGS.gap_root)):
    sys.exit(f"{_ERR_PREFIX}can't find GAP root directory!\033[0m")

for f in _ARGS.tstfiles:
    if not (exists(f) and isfile(f)):
        sys.exit(f"{_ERR_PREFIX}{f} does not exist!\033[0m")

_DIR = tempfile.mkdtemp()
print(f"{_INFO_PREFIX}Using temporary directory: {_DIR}\033[0m")

# Raw strings are used to correctly escape quotes " for input in another
# process, i.e. we explicitly need the string to contain \" instead of just "
# for each quote.
_GAP_COMMANDS = [rf"Test(\"{f}\");;" for f in _ARGS.tstfiles]
_GAP_COMMANDS.extend(
    [
        "UncoverageLineByLine();;",
        r"LoadPackage(\"profiling\", false);;",
        rf"filesdir := \"{getcwd()}{_PROFILE_DIR}\";;",
        rf"outdir := \"{_DIR}\";;",
        rf"x := ReadLineByLineProfile(\"{_DIR}/profile.gz\");;",
        "OutputAnnotatedCodeCoverageFiles(x, filesdir, outdir);",
    ]
)

_RUN_GAP = f"{_ARGS.gap_root}/gap -A -m 1g -T --cover {_DIR}/profile.gz"

# Commands are stored in a list and then joined with "\n" since including
# newlines directly in raw strings cause issues when piping into GAP on some
# platforms.
with subprocess.Popen(
    'echo "' + "\n".join(_GAP_COMMANDS) + '"', stdout=subprocess.PIPE, shell=True
) as pro1:
    try:
        with subprocess.Popen(_RUN_GAP, stdin=pro1.stdout, shell=True) as pro2:
            pro2.wait()
    except KeyboardInterrupt:
        pro1.terminate()
        pro1.wait()
        sys.exit("\033[31mKilled!\033[0m")
    except (subprocess.CalledProcessError, IOError, OSError):
        sys.exit(_ERR_PREFIX + "Something went wrong calling GAP!\033[0m")


def rewrite_fname(fname: str) -> str:
    return fname.replace("/", "_")


suffix = ""
if _ARGS.open:
    filename = f"{_DIR}/{rewrite_fname(getcwd())}/{rewrite_fname(_ARGS.open)}.html"
    p = re.compile(r"<tr class='missed'><td><a name=\"line(\d+)\">")
    with open(filename, "r", encoding="utf-8") as f:
        m = p.search(f.read())
        if m:
            suffix += "#line" + m.group(1)
else:
    filename = _DIR + "/index.html"
print(f"{_INFO_PREFIX}\nSUCCESS!\033[0m")
print(f"{_INFO_PREFIX} See {filename}")
sys.exit(0)
