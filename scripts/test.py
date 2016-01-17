#!/usr/bin/env python

'''
This is a script for checking that the Semigroups package is releasable, i.e.
that it passes all the tests in all configurations.
'''

#TODO verbose mode

import textwrap, os, argparse, tempfile, subprocess, sys, os, signal, dots

from dots import dotIt

################################################################################
# Globals
################################################################################

_WRAPPER = textwrap.TextWrapper(break_on_hyphens=False, width=80)

################################################################################
# Strings for printing
################################################################################

def red_string(string, wrap=True):
    'red string'
    if wrap:
        return '\n'.join(_WRAPPER.wrap('\033[31m' + string + '\033[0m'))
    else:
        return '\033[31m' + string + '\033[0m'

def cyan_string(string):
    'cyan string'
    return '\n'.join(_WRAPPER.wrap('\033[36m' + string + '\033[0m'))

def magenta_string(string):
    'magenta string'
    return '\n'.join(_WRAPPER.wrap('\033[35m' + string + '\033[0m'))

def neon_green_string(string):
    'blue string'
    return '\n'.join(_WRAPPER.wrap('\033[40;38;5;82m' + string + '\033[0m'))

def pad_string(string, extra=0):
    for i in xrange(extra + 43 - len(string)):
        string += ' '
    return string

def exit_abort(message=''):
    '''Exit the script and print message in red. Use this if something is wrong
    in the release, i.e. dates or version numbers don't agree.'''
    show_cursor()
    if message != '':
        sys.exit(red_string(message + '!\nAborting!'))
    else:
        sys.exit(red_string('\nAborting!'))

def exit_error_func(script_name):
    def exit_error(message):
        show_cursor()
        sys.exit(red_string(script_name + ': error: ' + message))
    return exit_error

exit_error = exit_error_func('test.py')

def exit_killed(*arg):
    for pro in arg:
        pro.terminate()
        pro.wait()
    show_cursor()
    print red_string('Killed!')
    sys.exit(1)

def info_statement(message):
    '''Print the statement <message> in bright green.'''
    print neon_green_string(message)

def info_action(message, eol=True):
    if eol or _VERBOSE:
        print magenta_string(pad_string(message) + '. . .')
    else:
        print magenta_string(pad_string(message) + '. . . '),
        sys.stdout.flush()

def info_verbose(message):
    if _VERBOSE:
        print cyan_string(pad_string(message) + '. . .')

def info_warn(message):
    print red_string('test.p: warning: ' + message)

################################################################################
# Functions to define behaviour for this as a module
################################################################################

def set_verbose(val):
    global _VERBOSE
    if val == True:
        _VERBOSE = True
    elif val == False:
        _VERBOSE = False
    else:
        exit_error('the value must be True or False')

################################################################################
# Helpers
################################################################################

def exec_string(string):
    'execute the string in a subprocess.'
    info_verbose(string)
    try:
        if _VERBOSE:
            subprocess.check_call(string, shell=True)
        else:
            devnull = open(os.devnull, 'w')
            subprocess.check_call(string,
                                  stdout=devnull,
                                  stderr=devnull,
                                  shell=True)
    except KeyboardInterrupt:
        exit_killed()
    except (subprocess.CalledProcessError, OSError):
        exit_error(string + ' failed')

def hide_cursor():
    if os.name == 'posix':
        sys.stdout.write("\033[?25l")
        sys.stdout.flush()

def show_cursor():
    if os.name == 'posix':
        sys.stdout.write("\033[?25h")
        sys.stdout.flush()

################################################################################
# Run GAP
################################################################################

def _run_gap(gap_root):
    'returns the bash script to run GAP and detect errors'
    out = gap_root + 'bin/gap.sh -r -A -T -m 1g'
    if not _VERBOSE:
        out += ' -q'
    return out

_LOG_NR = 0

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
    if not _VERBOSE:
        dots.dotIt(magenta_string('. '), _run_test_base, gap_root, message,
                   stop_for_diffs, *arg)
    else:
        _run_test_base(gap_root, message, stop_for_diffs, *arg)

def _run_test_base (gap_root, message, stop_for_diffs, *arg):
    hide_cursor()
    info_action(message, False)

    tmpdir = tempfile.mkdtemp()
    log_file = _log_file(tmpdir)
    commands = 'echo "LogTo(\\"' + log_file + '\\");\n' + '\n'.join(arg) + '"'
    info_verbose(commands)
    pro1 = subprocess.Popen(commands,
                            stdout=subprocess.PIPE,
                            shell=True)
    try:
        if _VERBOSE:
            pro2 = subprocess.Popen(_run_gap(gap_root),
                                    stdin=pro1.stdout,
                                    shell=True)
        else:
            devnull = open(os.devnull, 'w')
            pro2 = subprocess.Popen(_run_gap(gap_root),
                                    stdin=pro1.stdout,
                                    stdout=devnull,
                                    stderr=devnull,
                                    shell=True)
        pro2.wait()
    except KeyboardInterrupt:
        exit_killed(pro1, pro2)
    except subprocess.CalledProcessError:
        print red_string('FAILED!')
        if stop_for_diffs:
            exit_abort()
    except (OSError, IOError):
        exit_error('internal error 1')

    try:
        log = open(log_file, 'r').read()
    except IOError:
        exit_error(log_file + ' not found!')

    if len(log) == 0:
        info_warn(log_file + 'is empty!')

    if (log.find('########> Diff') != -1
            or log.find('# WARNING') != -1
            or log.find('#E ') != -1
            or log.find('Error') != -1
            or log.find('brk>') != -1
            or log.find('LoadPackage("semigroups", false);\nfail') != -1):
        print red_string('FAILED!')
        for line in open(log_file, 'r').readlines():
            print red_string(line.rstrip(), False)
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
        exit_error('can\'t find the ' + package_name + ' directory')
    os.chdir(package_dir)

################################################################################

def _make_clean(gap_root, directory, name):
    def inner(gap_root, directory, name):
        hide_cursor()
        info_action('Deleting ' + name + ' binary', False)
        cwd = os.getcwd()
        _get_ready_to_make(directory, name)
        if name == 'grape':
            exec_string('./configure ' + gap_root)
        else:
            exec_string('./configure --with-gaproot=' + gap_root)

        exec_string('make clean')
        os.chdir(cwd)
        print ''
        show_cursor()
    if not _VERBOSE:
        dotIt(magenta_string('. '), inner, gap_root, directory, name)
    else:
        inner(gap_root, directory, name)

################################################################################

def _configure_make(gap_root, directory, name):
    def inner(gap_root, directory, name):
        hide_cursor()
        info_action('Compiling ' + name, False)
        cwd = os.getcwd()
        _get_ready_to_make(directory, name)
        if name == 'grape':
            exec_string('./configure ' + gap_root)
        else:
            exec_string('./configure --with-gaproot=' + gap_root)
        exec_string('make -j')
        os.chdir(cwd)
        print ''
        show_cursor()

    if not _VERBOSE:
        dotIt(magenta_string('. '), inner, gap_root, directory, name)
    else:
        inner(gap_root, directory, name)

################################################################################

def _man_ex_str(gap_root, name):
    return ('ex := ExtractExamples(\\"'  + gap_root + 'doc/ref\\", \\"'
            + name + '\\", [\\"' + name + '\\"], \\"Section\\");' +
            ' RunExamples(ex);')

################################################################################
# the GAP commands to run the tests
################################################################################

_LOAD = 'LoadPackage(\\"digraphs\\", false);'
_LOAD_SEMIGROUPS = 'LoadPackage(\\"semigroups\\", false);'
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
    return 'Read(\\"' + gap_root + 'tst/testinstall.g\\");'

############################################################################
# Run the tests
############################################################################

def digraphs_make_doc(gap_root):
    _run_test(gap_root, 'Compiling the doc', True, _LOAD, _MAKE_DOC)

def run_digraphs_tests(gap_root, pkg_dir, pkg_name, skip_extreme):

    print neon_green_string(pad_string('Package name:') + pkg_name)
    print neon_green_string(pad_string('GAP root:') + gap_root)

    _make_clean(gap_root, pkg_dir, pkg_name)
    _configure_make(gap_root, pkg_dir, pkg_name)

    _run_test(gap_root,
              'Validating PackageInfo.g',
              True,
              _validate_package_info(gap_root, pkg_name))
    _run_test(gap_root,
              'Loading package',
              True,
              _LOAD)
    _run_test(gap_root,
              'Loading only needed',
              True,
              _LOAD_ONLY_NEEDED)

    _make_clean(gap_root, pkg_dir, 'grape')

    _run_test(gap_root,
              'Loading Grape not compiled',
              True,
              _LOAD)

    _configure_make(gap_root, pkg_dir, 'grape')

    _run_test(gap_root,
              'Loading Grape compiled',
              True,
              _LOAD)
    _run_test(gap_root,
              'Loading Semigroups first',
              True,
              _LOAD_SEMIGROUPS,
              _LOAD)

    _run_test(gap_root,
              'Compiling the doc',
              True,
              _LOAD,
              _MAKE_DOC)

    info_statement('Semigroups loaded first')
    _run_test(gap_root,
              'Testing digraphs/tst/testinstall.tst',
              True,
              _LOAD_SEMIGROUPS,
              _LOAD,
              _TEST_INSTALL)
    _run_test(gap_root,
              'Testing digraphs manual examples',
              True,
              _LOAD_SEMIGROUPS,
              _LOAD,
              _TEST_MAN_EX)
    _run_test(gap_root,
              'Testing digraphs/tst/standard/*',
              True,
              _LOAD_SEMIGROUPS,
              _LOAD,
              _TEST_STANDARD)

    info_statement('Grape compiled')

    _run_test(gap_root,
              'Testing digraphs/tst/testinstall.tst',
              True,
              _LOAD,
              _TEST_INSTALL)
    _run_test(gap_root,
              'Testing digraphs manual examples',
              True,
              _LOAD,
              _TEST_MAN_EX)
    _run_test(gap_root,
              'Testing digraphs/tst/standard/*',
              True,
              _LOAD,
              _TEST_STANDARD)
    if not skip_extreme:
        _run_test(gap_root,
                  'Testing digraphs/tst/extreme/*',
                  True,
                  _LOAD,
                  _TEST_EXTREME)
        _run_test(gap_root,
                  'Testing gap/tst/testinstall.g',
                  False,
                  _LOAD,
                  _test_gap_quick(gap_root))
    else:
        info_verbose('Skipping extreme tests')

    info_statement('Grape uncompiled')

    _make_clean(gap_root, pkg_dir, 'grape')
    _run_test(gap_root,
              'Testing digraphs/tst/testinstall.tst',
              True,
              _LOAD,
              _TEST_INSTALL)
    _run_test(gap_root,
              'Testing digraphs manual examples',
              True,
              _LOAD,
              _TEST_MAN_EX)
    _run_test(gap_root,
              'Testing digraphs/tst/standard/*',
              True,
              _LOAD,
              _TEST_STANDARD)
    if not skip_extreme:
        _run_test(gap_root,
                  'Testing digraphs/tst/extreme/*',
                  True,
                  _LOAD,
                  _TEST_EXTREME)
        _run_test(gap_root,
                  'Testing gap/tst/testinstall.g',
                  False,
                  _LOAD,
                  _test_gap_quick(gap_root))
    else:
        info_verbose('Skipping extreme tests')

    info_statement('Only needed packages')

    _run_test(gap_root,
              'Testing digraphs/tst/testinstall.tst',
              True,
              _LOAD_ONLY_NEEDED,
              _TEST_INSTALL)
    _run_test(gap_root,
              'Testing digraphs manual examples',
              True,
              _LOAD_ONLY_NEEDED,
              _TEST_MAN_EX)
    _run_test(gap_root,
              'Testing digraphs/tst/standard/*',
              True,
              _LOAD_ONLY_NEEDED,
              _TEST_STANDARD)
    if not skip_extreme:
        _run_test(gap_root,
                  'Testing digraphs/tst/extreme/*',
                  True,
                  _LOAD_ONLY_NEEDED,
                  _TEST_EXTREME)
        _run_test(gap_root,
                  'Testing gap/tst/testinstall.g',
                  False,
                  _LOAD_ONLY_NEEDED,
                  _test_gap_quick(gap_root))
    else:
        info_verbose('Skipping extreme tests')

    info_statement('SUCCESS!')

################################################################################
# Run the script
################################################################################

def main():
    global _VERBOSE

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
    parser.add_argument('--skip-extreme', dest='skip_extreme', action='store_true',
                        help='skip extreme tests (default: False)')
    parser.set_defaults(verbose=False)

    args = parser.parse_args()
    _VERBOSE = args.verbose

    if not args.gap_root[-1] == '/':
        args.gap_root += '/'
    if not args.pkg_dir[-1] == '/':
        args.pkg_dir += '/'

    args.gap_root = os.path.expanduser(args.gap_root)
    args.pkg_dir = os.path.expanduser(args.pkg_dir)

    if not (os.path.exists(args.gap_root) and os.path.isdir(args.gap_root)):
        exit_error('can\'t find GAP root directory '+ args.gap_root + '!')
    if not (os.path.exists(args.pkg_dir) or os.path.isdir(args.pkg_dir)):
        exit_error('can\'t find package directory ' + args.pkg_dir + '!')

    run_digraphs_tests(args.gap_root,
                       args.pkg_dir,
                       args.pkg_name,
                       args.skip_extreme)

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        exit_killed()
