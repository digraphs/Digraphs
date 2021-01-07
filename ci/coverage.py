#!/usr/bin/env python3

import tempfile, subprocess, sys, os, ntpath, re
from os.path import exists, isdir, isfile

_BLUE_PREFIX = '\033[34m'
_RED_PREFIX = '\033[31m'
_RESET = '\033[0m' 
_ERR_PREFIX = _RED_PREFIX + 'coverage.py: error: '
_WARN_PREFIX = _RED_PREFIX + 'coverage.py: warning: '

def error_exit(msg):
    print(_ERR_PREFIX + msg + _RESET)
    sys.exit(1)

def warn_exit(msg):
    print(_WARN_PREFIX + msg + _RESET)
    sys.exit(0)

if len(sys.argv) != 3:
    error_exit('arguments must be a test file and the threshold')

f = str(sys.argv[1])
if not (exists(f) and isfile(f)):
    error_exit(f + ' does not exist!')

threshold = int(sys.argv[2])

_DIR = tempfile.mkdtemp()
_COMMANDS = 'LoadPackage("digraphs", false); Test("' + f + '");;'
_COMMANDS += 'outdir := "' + _DIR + '";;'
_COMMANDS += '''
UncoverageLineByLine();;
LoadPackage("profiling", false);;
filesdir := Concatenation(DIGRAPHS_Dir(), "/gap/");;
x := ReadLineByLineProfile(Concatenation(outdir, "/profile.gz"));;
OutputAnnotatedCodeCoverageFiles(x, filesdir, outdir);
QUIT_GAP(0);
'''

_RUN_GAP = '../../bin/gap.sh -A -q -m 1g -o 2g -T --cover ' + _DIR + '/profile.gz -c "' + _COMMANDS.replace('"', '\\"') + '"'

try:
    pro = subprocess.Popen(_RUN_GAP, shell=True)
    pro.wait()
except KeyboardInterrupt:
    pro.terminate()
    pro.wait()
    error_exit('Killed!')
except (subprocess.CalledProcessError, IOError, OSError):
    error_exit('Something went wrong calling GAP!')

filename = _DIR + '/index.html'
if not (exists(filename) and isfile(filename)):
    error_exit('Failed to find file://' + filename)

gi_file = ntpath.basename(f).split('.')[0] + '.gi'
for line in open(filename):
    if gi_file in line:
        break

search = re.search('coverage\d\d+[\'"]>(\d+)</td><td>([\d,]+)</td><td>([\d,]+)</td>', line)
if search == None:
    warn_exit('Could not find .gi file to which this .tst refers')

percentage = search.group(1)
print(_BLUE_PREFIX + gi_file + ' has ' + percentage + '% coverage: ' + search.group(2) + '/' + search.group(3) + ' lines' + _RESET)

if int(percentage) < threshold:
    warn_exit(percentage + '% is insufficient code coverage for ' + gi_file)
