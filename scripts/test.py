#!/usr/bin/env python
'''
This is a script for checking that the Semigroups package is releasable, i.e.
that it passes all the tests in all configurations.
'''

#TODO verbose mode

import textwrap, os, argparse, tempfile, subprocess, sys, os, signal, dots

################################################################################
# Strings for printing
################################################################################

_WRAPPER = textwrap.TextWrapper(break_on_hyphens=False, width=80)

def _red_string(string, wrap=True):
    'red string'
    if wrap:
        return '\n        '.join(_WRAPPER.wrap('\033[31m' + string + '\033[0m'))
    else:
        return '\033[31m' + string + '\033[0m'

def _green_string(string):
    'green string'
    return '\n        '.join(_WRAPPER.wrap('\033[32m' + string + '\033[0m'))

def _cyan_string(string):
    'cyan string'
    return '\n        '.join(_WRAPPER.wrap('\033[36m' + string + '\033[0m'))

def blue_string(string):
    'blue string'
    return '\n        '.join(_WRAPPER.wrap('\033[40;38;5;82m' + string + '\033[0m'))

def _magenta_string(string):
    'magenta string'
    return '\n        '.join(_WRAPPER.wrap('\033[35m' + string + '\033[0m'))

MAGENTA_DOT = _magenta_string('. ')
CYAN_DOT = _cyan_string('. ')

def hide_cursor():
    if os.name == 'posix':
        sys.stdout.write("\033[?25l")
        sys.stdout.flush()

def show_cursor():
    if os.name == 'posix':
        sys.stdout.write("\033[?25h")
        sys.stdout.flush()

################################################################################
# Parse the arguments
################################################################################

_LOG_NR = 0

def _run_gap(gap_root, verbose=False):
    'returns the bash script to run GAP and detect errors'
    out = gap_root + 'bin/gap.sh -r -A -T -m 1g'
    if not verbose:
        out += ' -q'
    return out

def _log_file(tmp_dir):
    'returns the string "LogTo(a unique file);"'
    global _LOG_NR
    _LOG_NR += 1
    log_file = os.path.join(tmp_dir, 'test-' + str(_LOG_NR) + '.log')
    return log_file

################################################################################
# Functions
################################################################################

def _run_test(gap_root, message, stop_for_diffs, *arg):
    '''echo the GAP commands in the string <commands> into _GAPTest, after
       printing the string <message>.'''

    dots.dotIt(MAGENTA_DOT, _run_test_base, gap_root, message,
               stop_for_diffs, *arg)

def _run_test_base (gap_root, message, stop_for_diffs, *arg):
    hide_cursor()
    print pad(_magenta_string(message + ' . . . ')),
    sys.stdout.flush()

    tmpdir = tempfile.mkdtemp()
    log_file = _log_file(tmpdir)
    commands = 'echo "LogTo(\\"' + log_file + '\\");\n' + '\n'.join(arg) + '"'
    pro1 = subprocess.Popen(commands,
                            stdout=subprocess.PIPE,
                            shell=True)
    try:
        devnull = open(os.devnull, 'w')
        pro2 = subprocess.Popen(_run_gap(gap_root),
                                stdin=pro1.stdout,
                                stdout=devnull,
                                stderr=devnull,
                                shell=True)
        pro2.wait()
    except KeyboardInterrupt:
        pro1.terminate()
        pro1.wait()
        pro2.terminate()
        pro2.wait()
        show_cursor()
        print _red_string('Killed!')
        sys.exit(1)
    except subprocess.CalledProcessError:
        print _red_string('FAILED!')
        if stop_for_diffs:
            show_cursor()
            sys.exit(1)

    try:
        log = open(log_file, 'r').read()
    except IOError:
        show_cursor()
        sys.exit(_red_string('test.py: error: ' + log_file + ' not found!'))

    if len(log) == 0:
        print _red_string('test.py: warning: ' + log_file + ' is empty!')

    if (log.find('########> Diff') != -1
            or log.find('# WARNING') != -1
            or log.find('#E ') != -1
            or log.find('Error') != -1
            or log.find('brk>') != -1
            or log.find('LoadPackage("semigroups", false);\nfail') != -1):
        print _red_string('FAILED!')
        for line in open(log_file, 'r').readlines():
            print _red_string(line.rstrip(), False)
        if stop_for_diffs:
            show_cursor()
            sys.exit(1)
    show_cursor()
    print ''

################################################################################

def _get_ready_to_make(pkg_dir, package_name):
    os.chdir(pkg_dir)
    package_dir = None
    for pkg in os.listdir(pkg_dir):
        if os.path.isdir(pkg) and pkg.startswith(package_name):
            package_dir = pkg

    if not package_dir:
        sys.exit(_red_string('test.py: error: can\'t find the ' + package_name
                             + ' directory'))
    os.chdir(package_dir)

################################################################################

def _exec(command):
    try: #FIXME use popen here
        devnull = open(os.devnull, 'w')
        pro = subprocess.check_call(command,
                                    stdout=devnull,
                                    stderr=devnull,
                                    shell=True)
    except KeyboardInterrupt:
        os.kill(pro.pid, signal.SIGKILL)
        print _red_string('Killed!')
        show_cursor()
        sys.exit(1)
    except subprocess.CalledProcessError:
        show_cursor()
        sys.exit(_red_string('test.py: error: ' + command + ' failed!!'))

################################################################################

def _make_clean(gap_root, directory, name):
    hide_cursor()
    print _cyan_string(pad('Deleting ' + name + ' binary') + ' . . . '),
    cwd = os.getcwd()
    sys.stdout.flush()
    _get_ready_to_make(directory, name)
    _exec('./configure --with-gaproot=' + gap_root)
    _exec('make clean')
    os.chdir(cwd)
    print ''
    show_cursor()

################################################################################

def _configure_make(gap_root, directory, name):
    hide_cursor()
    print _cyan_string(pad('Compiling ' + name) + ' . . . '),
    cwd = os.getcwd()
    sys.stdout.flush()
    _get_ready_to_make(directory, name)
    _exec('./configure --with-gaproot=' + gap_root)
    _exec('make')
    os.chdir(cwd)
    print ''
    show_cursor()

################################################################################

def _man_ex_str(gap_root, name):
    return ('ex := ExtractExamples(\\"'  + gap_root + 'doc/ref\\", \\"'
            + name + '\\", [\\"' + name + '\\"], \\"Section\\");' +
            ' RunExamples(ex);')

def pad(string, extra=0):
    for i in xrange(extra + 35 - len(string)):
        string += ' '
    return string

################################################################################
# the GAP commands to run the tests
################################################################################

_LOAD = 'LoadPackage(\\"digraphs\\", false);'
_LOAD_SMALLSEMI = 'LoadPackage(\\"smallsemi\\", false);'
_LOAD_ONLY_NEEDED = 'LoadPackage(\\"digraphs\\", false : OnlyNeeded);'
_TEST_STANDARD = 'DigraphsTestStandard();'
_TEST_EXTREME = 'DigraphsTestExtreme();'
_TEST_INSTALL = 'DigraphsTestInstall();'
_TEST_MAN_EX = 'DigraphsTestManualExamples();'
_MAKE_DOC = 'DigraphsMakeDoc();'

def _validate_package_info(gap_root, pkg_name):
    return ('ValidatePackageInfo(\\"' + gap_root +
            'pkg/' + pkg_name + '/PackageInfo.g\\");')

def _test_gap_quick(gap_root):
# anymore?
    return 'Read(\\"' + gap_root + 'tst/testinstall.g\\");'

############################################################################
# Run the tests
############################################################################

def digraphs_make_doc(gap_root):
    _run_test(gap_root, pad('Compiling the doc'), True, _LOAD, _MAKE_DOC)

def run_digraphs_tests(gap_root, pkg_dir, pkg_name):

    print ''
    print blue_string('Package name is ' + pkg_name + ','),
    print blue_string('gap root is ' + gap_root)

    dots.dotIt(CYAN_DOT, _make_clean, gap_root, pkg_dir, pkg_name)
    dots.dotIt(CYAN_DOT, _configure_make, gap_root, pkg_dir, pkg_name)

    _run_test(gap_root,
              pad('Validating PackageInfo.g'),
              True,
              _validate_package_info(gap_root, pkg_name))
    _run_test(gap_root, pad('Loading package'), True, _LOAD)
    _run_test(gap_root, pad('Loading only needed'), True, _LOAD_ONLY_NEEDED)

    _make_clean(gap_root, pkg_dir, 'grape')
    _run_test(gap_root, pad('Loading Grape not compiled'), True, _LOAD)

    dots.dotIt(CYAN_DOT, _configure_make, gap_root, pkg_dir, 'grape')
    _run_test(gap_root, pad('Loading Grape compiled'), True, _LOAD)

    _run_test(gap_root, pad('Compiling the doc'), True, _LOAD, _MAKE_DOC)

    print ''
    print blue_string('Testing with Grape compiled')
    _run_test(gap_root, pad('testinstall.tst'), True, _LOAD, _TEST_INSTALL)
    _run_test(gap_root, pad('manual examples'), True, _LOAD, _TEST_MAN_EX)
    _run_test(gap_root, pad('test standard'), True, _LOAD, _TEST_STANDARD)
    _run_test(gap_root, pad('test extreme'), True, _LOAD, _TEST_EXTREME)
    _run_test(gap_root,
              pad('GAP testinstall.g'),
              False,
              _LOAD,
              _test_gap_quick(gap_root))

    print ''
    print blue_string('Testing with Grape uncompiled')
    _make_clean(gap_root, pkg_dir, 'grape')
    _run_test(gap_root, pad('testinstall.tst'), True, _LOAD, _TEST_INSTALL)
    _run_test(gap_root, pad('manual examples'), True, _LOAD, _TEST_MAN_EX)
    _run_test(gap_root, pad('test standard'), True, _LOAD, _TEST_STANDARD)
    _run_test(gap_root, pad('test extreme'), True, _LOAD, _TEST_EXTREME)
    _run_test(gap_root,
              pad('GAP testinstall.g'),
              False,
              _LOAD,
              _test_gap_quick(gap_root))
    print ''
    print blue_string('Testing with only needed packages')
    _run_test(gap_root, pad('testinstall.tst'), True, _LOAD, _TEST_INSTALL)
    _run_test(gap_root, pad('manual examples'), True, _LOAD, _TEST_MAN_EX)
    _run_test(gap_root, pad('test standard'), True, _LOAD, _TEST_STANDARD)
    _run_test(gap_root, pad('test extreme'), True, _LOAD, _TEST_EXTREME)
    _run_test(gap_root,
              pad('GAP testinstall.g'),
              False,
              _LOAD,
              _test_gap_quick(gap_root))

    print '\n\033[32mSUCCESS!\033[0m'
    return

################################################################################
# Run the script
################################################################################

def main():
    parser = argparse.ArgumentParser(prog='test.py',
                                     usage='%(prog)s [options]')
    parser.add_argument('--gap-root', nargs='?', type=str,
                        help='the gap root directory (default: ~/gap)',
                        default='~/gap/')
    parser.add_argument('--pkg-dir', nargs='?', type=str,
                        help='the pkg directory (default: ~/gap/pkg/)',
                        default='~/gap/pkg/')
    parser.add_argument('--pkg-name', nargs='?', type=str,
                        help='the pkg name (default: digraphs)',
                        default='digraphs')
    parser.add_argument('--verbose', dest='verbose', action='store_true',
                        help='verbose mode (default: False)')
    parser.set_defaults(verbose=False)

    args = parser.parse_args()

    if not args.gap_root[-1] == '/':
        args.gap_root += '/'
    if not args.pkg_dir[-1] == '/':
        args.pkg_dir += '/'

    args.gap_root = os.path.expanduser(args.gap_root)
    args.pkg_dir = os.path.expanduser(args.pkg_dir)

    if not (os.path.exists(args.gap_root) and os.path.isdir(args.gap_root)):
        sys.exit(_red_string('release.py: error: can\'t find GAP root' +
                             ' directory!'))
    if not (os.path.exists(args.pkg_dir) or os.path.isdir(args.pkg_dir)):
        sys.exit(_red_string('test.py: error: can\'t find package' +
                             ' directory!'))

    run_digraphs_tests(args.gap_root, args.pkg_dir, args.pkg_name)

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        show_cursor()
        print _red_string('Killed!')
        sys.exit(1)
