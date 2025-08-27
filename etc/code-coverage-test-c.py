#!/usr/bin/env python
"""
"""

# pylint: disable=invalid-name, broad-except

import argparse
import tempfile
import subprocess
import sys
import os
import webbrowser

from os.path import exists, isfile

_ERR_PREFIX = '\033[31merror: '

def exec_string(string):
    'execute the string in a subprocess.'
    try:
        subprocess.check_call(string, shell=True)
    except KeyboardInterrupt:
        sys.exit('\033[31m\nKilled!\033[0m')
    except (subprocess.CalledProcessError, OSError):
        sys.exit(_ERR_PREFIX + 'executing:\n' + string + '\n failed!\033[0m')

_PARSER = argparse.ArgumentParser(prog='code-coverage-test-c.py',
                                  usage='%(prog)s [options]')
_PARSER.add_argument('files', nargs='+', type=str,
                     help='the test files you want to check code coverage for'
                     + '(must be at least one)')
_PARSER.add_argument('--gap-root', nargs='?', type=str,
                     help='the gap root directory (default: ~/gap)',
                     default='~/gap/')
_PARSER.add_argument('--pkg', nargs='?', type=str,
                     help='the package to profile (default: None)',
                     default=None)
_PARSER.add_argument('--build', dest='build', action='store_true',
                     help='rebuild GAP (default: False)')
_PARSER.set_defaults(build=False)
_PARSER.add_argument('--open', nargs='?', type=str,
                     help=('open the lcov html page for this file ' +
                           '(default: None)'),
                     default=None)
_PARSER.add_argument('--line', nargs='?', type=str,
                     help=('open the html page for the file specified by --open' +
                           ' at this line (default: None)'),
                     default=None)
_ARGS = _PARSER.parse_args()

if not _ARGS.gap_root[-1] == '/':
    _ARGS.gap_root += '/'

_ARGS.gap_root = os.path.expanduser(_ARGS.gap_root)
if _ARGS.pkg != None:
    _ARGS.pkg = _ARGS.gap_root + '/pkg/' + _ARGS.pkg

if not (os.path.exists(_ARGS.gap_root) and os.path.isdir(_ARGS.gap_root)):
    sys.exit('\033[31mcode-coverage-test-c.py: error: can\'t find gap root' +
             ' directory!\033[0m')
if (_ARGS.pkg != None and not (os.path.exists(_ARGS.pkg) and
    os.path.isdir(_ARGS.pkg))):
    sys.exit('\033[31mcode-coverage-test-c.py: error: can\'t find the pkg' +
             ' directory %s\033[0m' % _ARGS.pkg)
for f in _ARGS.files:
    if not (os.path.exists(f) and os.path.isfile(f)):
        sys.exit('\033[31mcode-coverage-test-c.py: error: ' + f +
                 ' does not exist!\033[0m')

_DIR = tempfile.mkdtemp()
print('\033[35musing temporary directory: ' + _DIR + '\033[0m')

_COMMANDS = 'echo "'
for f in _ARGS.files:
    _COMMANDS += 'Test(\\"' + f + '\\");;'
_COMMANDS += '"'

# TODO build if files changed since last build or built with the wrong flags,
# by looking in config.log

# for source in :
#     if time.ctime(os.path.getmtime(file))

if _ARGS.build:
    cwd = os.getcwd()
    os.chdir(_ARGS.gap_root)
    exec_string('''rm -rf bin/ && \
                   make clean && \
                   ./configure CFLAGS="-O0 -g --coverage" \
                               CXXFLAGS="-O0 -g --coverage" \
                               LDFLAGS="-O0 -g --coverage" && \
                   make -j8''')
    if _ARGS.pkg != None:
        os.chdir(_ARGS.pkg)
        exec_string('rm -rf bin/ && \
                       make clean && \
                       ./configure CFLAGS="-O0 -g --coverage" \
                                   CXXFLAGS="-O0 -g --coverage" \
                                   LDFLAGS="-O0 -g --coverage" && \
                       make -j8''')
    os.chdir(cwd)

pro1 = subprocess.Popen(_COMMANDS, stdout=subprocess.PIPE, shell=True)
_RUN_GAP = _ARGS.gap_root + 'bin/gap.sh -A -m 1g -T'

try:
    pro2 = subprocess.Popen(_RUN_GAP,
                            stdin=pro1.stdout,
                            shell=True)
    pro2.wait()
    print('')
except KeyboardInterrupt:
    pro1.terminate()
    pro1.wait()
    pro2.terminate()
    pro2.wait()
    print('\033[31mKilled!\033[0m')
    sys.exit(1)
except Exception:
    sys.exit('\033[31mcode-coverage-test-c.py: error: something went wrong '
             + 'calling GAP!\033[0m''')
if _ARGS.pkg != None:
    exec_string('lcov --capture --directory ' + _ARGS.pkg +
                '/src --output-file ' + _DIR + '/lcov.info')
else:
    exec_string('lcov --capture --directory ' + _ARGS.gap_root +
                '/src --output-file ' + _DIR + '/lcov.info')

exec_string('genhtml ' + _DIR + '/lcov.info --output-directory ' + _DIR +
            '/lcov-out')

filename = _DIR + '/lcov-out/'
if _ARGS.open:
    filename += _ARGS.open + '.gcov.html'
else:
    filename += '/index.html'

if exists(filename) and isfile(filename):
    if _ARGS.open and _ARGS.line:
        filename += '#' + _ARGS.line
    print('file://' + filename)
    try:
        webbrowser.get('chrome').open('file://' + filename, new=2)
    except Exception:
        webbrowser.open('file://' + filename, new=2)
else:
    sys.exit('\n' + _ERR_PREFIX + 'Failed to open file://' + filename +
             '\033[0m')

print('\n\033[32mSUCCESS!\033[0m')
sys.exit(0)
