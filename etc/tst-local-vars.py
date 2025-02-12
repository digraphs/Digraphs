#!/usr/bin/env python3
"""
This simple script adds the local variables used in a GAP tst file to the top
of the file.
"""
import os
import re
import sys
import textwrap

import yaml
from bs4 import BeautifulSoup


def main():
    if sys.version_info[0] < 3:
        raise Exception("Python 3 is required")
    args = sys.argv[1:]
    pattern1 = re.compile(r"(\w+)\s*:=")
    pattern2 = re.compile(r"for (\w+) in")
    for fname in args:
        lvars = []
        with open(fname, "r") as f:
            lines = f.read()
            lvars.extend([x.group(1) for x in re.finditer(pattern1, lines)])
            lvars.extend([x.group(1) for x in re.finditer(pattern2, lines)])
        lvars = ", ".join(sorted([*{*lvars}]))
        lvars = [x if x[-1] != "," else x[:-1] for x in textwrap.wrap(lvars, width=72)]
        lvars = [""] + ["#@local " + x for x in lvars]
        lines = lines.split("\n")
        pos = next(i for i in range(len(lines)) if "START_TEST" in lines[i])
        lines = lines[:pos] + lvars + lines[pos:]
        lines = "\n".join(lines)
        with open(fname, "w") as f:
            print(f"Writing local variables to {fname}...")
            f.write(lines)


if __name__ == "__main__":
    main()
