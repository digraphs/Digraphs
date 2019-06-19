#!/usr/bin/env python

import tempfile, subprocess, sys, os, ntpath, re
from os.path import exists, isdir, isfile

_ERR_PREFIX = '\033[31mtravis-coverage.py: error: '
_WARN_PREFIX = '\033[31mtravis-coverage.py: warning: '
_BOLD_PREFIX = '\033[1m'
_BLUE_PREFIX = '\033[34m'

f = str(sys.argv[1])
if not (exists(f) and isfile(f)):
    sys.exit(_ERR_PREFIX + f + ' does not exist!\033[0m')

threshold = int(sys.argv[2])

_DIR = tempfile.mkdtemp()
_COMMANDS = 'echo "LoadPackage(\\"digraphs\\", false);;\n'
_COMMANDS += 'Test(\\"' + f + '\\");;\n'
_COMMANDS += '''UncoverageLineByLine();;
LoadPackage(\\"profiling\\", false);;
filesdir := Concatenation(DIGRAPHS_Dir(), \\"/gap/\\");;'''
_COMMANDS += 'outdir := \\"' + _DIR + '\\";;\n'
_COMMANDS += 'x := ReadLineByLineProfile(\\"' + _DIR + '/profile.gz\\");;\n'
_COMMANDS += 'OutputAnnotatedCodeCoverageFiles(x, filesdir, outdir);"'

pro1 = subprocess.Popen(_COMMANDS, stdout=subprocess.PIPE, shell=True)
_RUN_GAP = '../../bin/gap.sh -A -q -r -m 1g -o 2g -T --cover ' + _DIR + '/profile.gz'

try:
    pro2 = subprocess.Popen(_RUN_GAP,
                            stdin=pro1.stdout,
                            shell=True)
    pro2.wait()
except KeyboardInterrupt:
    pro1.terminate()
    pro1.wait()
    pro2.terminate()
    pro2.wait()
    sys.exit('\033[31mKilled!\033[0m')
except (subprocess.CalledProcessError, IOError, OSError):
    sys.exit(_ERR_PREFIX + 'Something went wrong calling GAP!\033[0m')

filename = _DIR + '/index.html'
if not (exists(filename) and isfile(filename)):
    print _ERR_PREFIX + 'Failed to find file://' + filename + '\033[0m'
    sys.exit(1)

gi_file = ntpath.basename(f).split('.')[0] + '.gi'
for line in open(filename):
    if gi_file in line:
        break

search = re.search('coverage\d\d+[\'"]>(\d+)</td><td>([\d,]+)</td><td>([\d,]+)</td>', line)
if search == None:
    print _WARN_PREFIX + 'Could not find .gi file to which this .tst refers\033[0m'
    sys.exit(0)

percentage = search.group(1)
print _BLUE_PREFIX + gi_file + ' has ' + percentage + '% coverage: ' + search.group(2) + '/' + search.group(3) + ' lines\033[0m'

if int(percentage) < threshold:
    print _WARN_PREFIX + percentage + '% is insufficient code coverage for ' + gi_file + ' \033[0m'

sys.exit(0)
