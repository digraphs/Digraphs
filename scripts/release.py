#!/usr/bin/env python
'''
Create the archive of the Digraphs package for release, and copy the relevant
things to the webpage.
'''

# TODO check that GAPVERS and dependencies have the same gap version number

import textwrap, os, argparse, tempfile, subprocess, sys, os, re, shutil, gzip
import test, time, webbrowser, urllib, dots

from test import pad
from test import blue_string

_WEBPAGE_DIR = os.path.expanduser('~/Sites/public_html/digraphs/')
_MAMP_DIR = '/Applications/MAMP/'
_DIGRAPHS_REPO_DIR = os.path.expanduser('~/gap/pkg/digraphs/')

################################################################################
# Strings for printing
################################################################################

_WRAPPER = textwrap.TextWrapper(break_on_hyphens=False, width=80)

def _red_string(string, wrap=True):
    'red string'
    if wrap:
        return '\n'.join(_WRAPPER.wrap('\033[31m' + string + '\033[0m'))
    else:
        return '\033[31m' + string + '\033[0m'

def _green_string(string):
    'green string'
    return '\n'.join(_WRAPPER.wrap('\033[32m' + string + '\033[0m'))

def _cyan_string(string):
    'cyan string'
    return '\n'.join(_WRAPPER.wrap('\033[36m' + string + '\033[0m'))

def _magenta_string(string):
    'magenta string'
    return '\n'.join(_WRAPPER.wrap('\033[35m' + string + '\033[0m'))

def query_yes_no(question, default="yes"):
    """Ask a yes/no question via raw_input() and return their answer.

    "question" is a string that is presented to the user.
    "default" is the presumed answer if the user just hits <Enter>.
        It must be "yes" (the default), "no" or None (meaning
        an answer is required of the user).

    The "answer" return value is True for "yes" or False for "no".
    """
    valid = {"yes": True, "y": True, "ye": True,
             "no": False, "n": False}
    if default is None:
        prompt = " [y/n] "
    elif default == "yes":
        prompt = " [Y/n] "
    elif default == "no":
        prompt = " [y/N] "
    else:
        raise ValueError("invalid default answer: '%s'" % default)

    while True:
        sys.stdout.write(question + prompt)
        choice = raw_input().lower()
        if default is not None and choice == '':
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond with 'yes' or 'no' "
                             "(or 'y' or 'n').\n")

################################################################################
# Check the version number in the branch against that in the PackageInfo.g
################################################################################

def _version_number_package_info():
    '''returns the version number from the PackageInfo.g file, exits if this
    file doesn't exist or the version number can't be found.'''

    if not (os.path.exists('PackageInfo.g') and
            os.path.isfile('PackageInfo.g')):
        sys.exit(_red_string('release.py: error: cannot find PackageInfo.g file'))
    else:
        try:
            contents = open('PackageInfo.g', 'r').read()
        except IOError:
            sys.exit(_red_string('release.py: error: cannot read PackageInfo.g'))
        match = re.compile(r'Version\s*:=\s*"((\d.*)+)"').search(contents)
        if match:
            return match.group(1)
        else:
            sys.exit(_red_string('release.py: error: could not determine the',
                                 'version number in PackageInfo.g'))

def _check_date_package_info(verbose):
    '''checks if the date in the PackageInfo.g file is today's date'''

    if not (os.path.exists('PackageInfo.g') and
            os.path.isfile('PackageInfo.g')):
        sys.exit(_red_string('release.py: error: cannot find PackageInfo.g file'))
    else:
        try:
            contents = open('PackageInfo.g', 'r').read()
        except IOError:
            sys.exit(_red_string('release.py: error: cannot read PackageInfo.g'))
        match = re.compile(r'Date\s*:=\s*"(\d\d/\d\d/\d\d\d\d)"').search(contents)
        if match:
            today = time.strftime("%d/%m/%Y")
            if match.group(1) != today and verbose:
                print _cyan_string('Date in PackageInfo.g is ' + match.group(1)
                                    + ' but today is ' + today)
            return match.group(1) == today
        else:
            sys.exit(_red_string('release.py: error: could not determine the',
                                 'version number in PackageInfo.g'))

def _exec(string, verbose):
    if verbose:
        print _cyan_string(string + ' . . .')
    try:
        devnull = open(os.devnull, 'w')
        proc = subprocess.Popen(string,
                                stdout=devnull,
                                stderr=devnull,
                                shell=True)
        proc.wait()
    except OSError:
        sys.exit(_red_string('release.py: error: ' + string + ' failed'))
    except subprocess.CalledProcessError:
        sys.exit(_red_string('release.py: error: ' +  string + ' failed'))

def _version_hg():
    '''returns the version number from the branch name in mercurial, exits if
    something goes wrong'''
    try:
        hg_version = subprocess.check_output(['hg', 'branch']).strip()
    except OSError:
        sys.exit(_red_string('release.py: error: could not determine the ',
                             'version number'))
    except subprocess.CalledProcessError:
        sys.exit(_red_string('release.py: error: could not determine the ',
                             'version number'))
    return hg_version

def _hg_identify():
    'returns the current changeset'
    try:
        hg_identify = subprocess.check_output(['hg', 'identify']).strip()
    except OSError:
        sys.exit(_red_string('release.py: error: could not determine the ',
                             'version number'))
    except subprocess.CalledProcessError:
        sys.exit(_red_string('release.py: error: could not determine the ',
                             'version number'))
    return hg_identify.split('+')[0]

def _copy_doc(dst, verbose):
    for filename in os.listdir('doc'):
        if os.path.splitext(filename)[-1] in ['.html', '.txt', '.pdf', '.css',
                '.js', '.six']:
            if verbose:
                print _cyan_string('Copying ' + filename +
                                     ' to the archive . . .')
            shutil.copy('doc/' + filename, dst)

def _copy_build_files(dst, verbose):
    for filename in ['configure', 'configure.ac', 'Makefile.in', 'Makefile.am']:
        if verbose:
            print _cyan_string('Copying ' + filename + ' to the archive . . .')
        shutil.copy(filename, dst)

    if verbose:
        print _cyan_string('Copying cnf/* to the archive . . .')
    shutil.copytree('cnf', dst + '/cnf')

def _delete_generated_build_files(verbose):
    for filename in ['aclocal.m4', 'autom4te.cache', 'config.log',
                     'config.status']:
        if os.path.exists(filename) and os.path.isfile(filename):
            if verbose:
                print _cyan_string('Deleting ' + filename +
                                   ' from the archive . . .')
            os.remove(filename)
    for directory in ['libtool', 'digraphs-lib', 'm4']:
        if os.path.exists(directory) and os.path.isdir(directory):
            if verbose:
                print _cyan_string('Deleting ' + directory
                                   + ' from the archive . . .')
            shutil.rmtree(directory)

def _download_digraphs_lib(dst, verbose):
    urllib.urlretrieve('https://bitbucket.org/james-d-mitchell/digraphs/downloads/digraphs-lib-0.2.tar.gz',
            'digraphs-lib-0.2.tar.gz')
    _exec('tar -xzf digraphs-lib-0.2.tar.gz', verbose)
    shutil.copytree('digraphs-lib', dst + '/digraphs-lib')

def _delete_xml_files(docdir, verbose):
    for filename in os.listdir(docdir):
        if os.path.splitext(filename)[-1] == '.xml':
            if verbose:
                print _cyan_string('Deleting ' + filename +
                                      ' from the archive . . .')
            os.remove(os.path.join(docdir, filename))

def _start_mamp():
    _exec('open ' + _MAMP_DIR + 'MAMP.app', False)
    cwd = os.getcwd()
    os.chdir(_MAMP_DIR + 'bin')
    _exec('./start.sh', False)
    os.chdir(cwd)

def _stop_mamp():
    cwd = os.getcwd()
    os.chdir(_MAMP_DIR + 'bin')
    _exec('./stop.sh', False)
    os.chdir(cwd)

################################################################################
# The main event
################################################################################

def main():
    # parse the args
    parser = argparse.ArgumentParser(prog='release.py',
                                     usage='%(prog)s [options]')

    parser.add_argument('--verbose', dest='verbose', action='store_true',
                        help='verbose mode (default: False)')
    parser.set_defaults(verbose=False)
    parser.add_argument('--skip-tests', dest='skip_tests', action='store_true',
                        help='verbose mode (default: False)')
    parser.set_defaults(skip_tests=False)
    parser.add_argument('--gap-root', nargs='*', type=str,
                        help='the gap root directory (default: [~/gap])',
                        default=['~/gap/'])
    parser.add_argument('--pkg-dir', nargs='?', type=str,
                        help='the pkg directory (default: gap-root/pkg/)',
                        default='~/gap/pkg/')

    args = parser.parse_args()

    for i in xrange(len(args.gap_root)):
        if args.gap_root[i][-1] != '/':
            args.gap_root[i] += '/'
    if not args.pkg_dir[-1] == '/':
        args.pkg_dir += '/'

    args.gap_root = [os.path.expanduser(x) for x in args.gap_root]
    args.pkg_dir = os.path.expanduser(args.pkg_dir)

    for gap_root_dir in args.gap_root:
        if not (os.path.exists(gap_root_dir) and os.path.isdir(gap_root_dir)):
            sys.exit(_red_string('release.py: error: can\'t find GAP root' +
                                 ' directory' + gap_root_dir + '!'))
    if not (os.path.exists(args.pkg_dir) or os.path.isdir(args.pkg_dir)):
        sys.exit(_red_string('release.py: error: can\'t find package' +
                             ' directory!'))

    # get the version number
    vers = _version_number_package_info()
    tmpdir_base = tempfile.mkdtemp()
    tmpdir = tmpdir_base + '/digraphs-' + vers

    if vers != _version_hg():
        sys.exit(_red_string('release.py: error: the version number in the ' +
                             'PackageInfo.g file is ' + vers + ' but the branch ' +
                             'name is ' + _version_hg()))

    if not _check_date_package_info(args.verbose):
        sys.exit(_red_string('release.py: error: date in PackageInfo.g ' +
                             'is not today!'))

    print blue_string('The version number is: ' + vers)
    if args.verbose:
        print _cyan_string('Using temporary directory: ' + tmpdir)

    test.digraphs_make_doc(args.gap_root[0])

    # archive . . .
    print _magenta_string(pad('Archiving using hg') + ' . . .')
    _exec('hg archive ' + tmpdir, args.verbose)

    # handle the doc . . .
    _copy_doc(tmpdir + '/doc/', args.verbose)
    _copy_build_files(tmpdir, args.verbose)
    if not args.skip_tests:
        print _magenta_string(pad('Downloading digraphs-lib-0.2.tar.gz') +
                              ' . . . '),
        sys.stdout.flush()
        dots.dotIt(test.MAGENTA_DOT, _download_digraphs_lib, tmpdir, args.verbose)
        print ''

    # delete extra files and dirs
    for filename in ['.hgignore', '.hgtags', '.gaplint_ignore', 'autogen.sh']:
        if (os.path.exists(os.path.join(tmpdir, filename))
                and os.path.isfile(os.path.join(tmpdir, filename))):
            print _magenta_string(pad('Deleting file ' + filename) + ' . . .')
            try:
                os.remove(os.path.join(tmpdir, filename))
            except OSError:
                sys.exit(_red_string('release.py: error: could not delete' +
                                     filename))

    print _magenta_string(pad('Deleting directory scripts') + ' . . .')
    try:
        shutil.rmtree(os.path.join(tmpdir, 'scripts'))
    except OSError:
        sys.exit(_red_string('release.py: error: could not delete scripts/*'))

    if args.skip_tests:
        print _magenta_string(pad('Skipping tests') + ' . . .')
    else:
        print _magenta_string(pad('Running the tests on the archive') + ' . . .')
        os.chdir(tmpdir_base)
        for directory in args.gap_root:
            digraphs_dir = os.path.join(directory, 'pkg/digraphs-' + vers)
            try:
                shutil.copytree('digraphs-' + vers, digraphs_dir)
                if os.path.exists(os.path.join(directory, 'pkg/digraphs')):
                    shutil.move(os.path.join(directory, 'pkg/digraphs'),
                                tmpdir_base)
            except Exception as e:
                sys.exit(_red_string(str(e)))

            try:
                test.run_digraphs_tests(directory,
                                        directory + '/pkg',
                                        'digraphs-' + vers)
            except (OSError, IOError) as e:
                sys.exit(_red_string(str(e)))
            finally:
                if os.path.exists(os.path.join(tmpdir_base, 'digraphs')):
                    shutil.move(os.path.join(tmpdir_base, 'digraphs'),
                                os.path.join(directory, 'pkg/digraphs'))
                shutil.rmtree(digraphs_dir)

    print _magenta_string(pad('Creating the tarball') + ' . . .')
    os.chdir(tmpdir)
    _delete_generated_build_files(args.verbose)
    os.chdir(tmpdir_base)

    for filename in ['.hgignore', '.hgtags', '.gaplint_ignore', 'autogen.sh']:
        if (os.path.exists(os.path.join(tmpdir, filename))
                and os.path.isfile(os.path.join(tmpdir, filename))):
            print _magenta_string(pad('Deleting file ' + filename) + ' . . .')
            try:
                os.remove(os.path.join(tmpdir, filename))
            except OSError:
                sys.exit(_red_string('release.py: error: could not delete' +
                                     filename))

    _exec('tar -cpf digraphs-' + vers + '.tar digraphs-' + vers +
          '; gzip -9 digraphs-' + vers + '.tar', args.verbose)

    print _magenta_string(pad('Copying to webpage') + ' . . .')
    try:
        os.chdir(tmpdir_base)
        shutil.copy('digraphs-' + vers + '.tar.gz', _WEBPAGE_DIR)
        os.chdir(tmpdir)
        shutil.copy('README.md', _WEBPAGE_DIR)
        shutil.copy('PackageInfo.g', _WEBPAGE_DIR)
        shutil.copy('CHANGELOG.md', _WEBPAGE_DIR)
        shutil.rmtree(_WEBPAGE_DIR + 'doc')
        shutil.copytree('doc', _WEBPAGE_DIR + 'doc')
    except Exception as e:
        print _red_string('release.py: error: could not copy to the webpage!')
        sys.exit(_red_string(str(e)))

    os.chdir(_WEBPAGE_DIR)
    print _magenta_string(pad('Adding archive to webpage repo') + ' . . .')
    _exec('hg add digraphs-' + vers + '.tar.gz', args.verbose)
    _exec('hg addremove', args.verbose)
    print _magenta_string(pad('Committing webpage repo') + ' . . .')
    _exec('hg commit -m "Releasing digraphs ' + vers + '"', args.verbose)

    _start_mamp()
    webbrowser.open('http://localhost:8888/public_html/digraphs.php')
    publish = query_yes_no(_magenta_string('Publish the webpage?'))
    _stop_mamp()

    if not publish:
        sys.exit(_red_string('Aborting!'))

    print _magenta_string(pad('Pushing webpage to server') + ' . . .')
    _exec('hg push', args.verbose)
    os.chdir(_DIGRAPHS_REPO_DIR)

    print _magenta_string(pad('Merging ' + vers + ' into default') + ' . . .')
    _exec('hg up -r default', args.verbose)
    _exec('hg merge -r ' + vers, args.verbose)
    _exec('hg commit -m "Merge from' + vers + '"', args.verbose)

    print _magenta_string(pad('Closing branch ' + vers) + ' . . .')
    _exec('hg up -r ' + vers, args.verbose)
    _exec('hg commit --close-branch -m "closing branch"', args.verbose)

    print _magenta_string(pad('Updating to default branch') + ' . . .')
    _exec('hg up -r default', args.verbose)

    print blue_string('Don\'t forget to check everything is ok at: ' +
                      'http://www.gap-system.org/Packages/Authors/authors.html')
    print _green_string('SUCCESS!')
    sys.exit(1)

################################################################################
# So that we can load this as a module if we want
################################################################################

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(_red_string('Killed!'))
