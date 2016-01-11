#!/usr/bin/env python
"""
"""

import argparse, tempfile, subprocess, sys, os

_PARSER = argparse.ArgumentParser(prog='code-coverage-test.py', usage='%(prog)s [options]')
_PARSER.add_argument('files', nargs='+', type=str,
                     help='the test files you want to check code coverage for'
                     + '(must be at least one)')
_PARSER.add_argument('--gap-root', nargs='?', type=str,
                     help='the gap root directory (default: ~/gap)',
                     default='~/gap/')
_ARGS = _PARSER.parse_args()

if not _ARGS.gap_root[-1] == '/':
    _ARGS.gap_root += '/'

_ARGS.gap_root = os.path.expanduser(_ARGS.gap_root)

if not (os.path.exists(_ARGS.gap_root) and os.path.isdir(_ARGS.gap_root)):
    sys.exit('\033[31mcode-coverage-test.py: error: can\'t find GAP root' +
             ' directory!\033[0m')

for f in _ARGS.files:
    if not (os.path.exists(f) and os.path.isfile(f)):
        sys.exit('\033[31mcode-coverage-test.py: error: ' + f + ' does not exist!\033[0m')

_DIR = tempfile.gettempdir()
print '\033[35musing temporary directory: ' + _DIR + '\033[0m'

_COMMANDS = 'echo "CoverageLineByLine(\\"' + _DIR + '/profile.gz\\");;'
_COMMANDS += 'LoadPackage(\\"digraphs\\", false);;'
for f in _ARGS.files:
    _COMMANDS += 'Test(\\"' + f + '\\");;'
_COMMANDS += '''UnprofileLineByLine();;
LoadPackage(\\"profiling\\", false);;
filesdir := Concatenation(PackageInfo(\\"digraphs\\")[1]!.InstallationPath, \\"/gap/\\");;'''
_COMMANDS += 'outdir := \\"' + _DIR + '\\";;'
_COMMANDS += 'x := ReadLineByLineProfile(\\"' + _DIR + '/profile.gz\\");;'
_COMMANDS += 'OutputAnnotatedCodeCoverageFiles(x, filesdir, outdir);"'

PS = subprocess.Popen(_COMMANDS, stdout=subprocess.PIPE, shell=True)

try:
    subprocess.check_call(_ARGS.gap_root + 'bin/gap.sh -A -r -m 1g -T',
                          stdin=PS.stdout, shell=True)
except subprocess.CalledProcessError:
    sys.exit('\033[31mcode-coverage-test.py: error: something went wrong calling GAP!\033[0m')

subprocess.call(('open', _DIR + '/index.html'))
print '\n\n\033[32mSUCCESS!\033[0m'
