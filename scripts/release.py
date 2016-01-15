#!/usr/bin/env python
'''
Create the archive of the Digraphs package for release, and copy the relevant
things to the webpage.
'''

# TODO
# 1) check that GAPVERS and dependencies have the same gap version number
# 2) check VERSIONS and VERSION file
# 3) check CHANGELOG for entry with correct version number
# 4) check all occurrences of all version numbers in PackageInfo.g
# 5) --skip-extreme

import textwrap, os, argparse, tempfile, subprocess, sys, os, re, shutil, gzip
import test, time, webbrowser, urllib, dots

from test import pad
from test import blue_string
from test import MAGENTA_DOT

################################################################################
# Configurable variables
################################################################################

_WEBPAGE_DIR = os.path.expanduser('~/Sites/public_html/digraphs/')
_MAMP_DIR = '/Applications/MAMP/'
_DIGRAPHS_REPO_DIR = os.path.expanduser('~/gap/pkg/digraphs/')
_DIGRAPHS_LIB_ARCHIVE = 'digraphs-lib-0.3.tar.gz'
_DIGRAPHS_LIB_URL = ('https://bitbucket.org/james-d-mitchell/digraphs/downloads/'
                     + _DIGRAPHS_LIB_ARCHIVE)
_FILES_TO_DELETE_FROM_ARCHIVE = ['.hgignore', '.hgtags', '.gaplint_ignore',
                                 '.hg_archival.txt']

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

################################################################################
# Error strings
################################################################################

_ERROR = 'release.py: error: '
_ABORT = '!\nAborting!'

################################################################################
# Helpers
################################################################################

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
def _abort(message):
    sys.exit(_red_string(message + _ABORT))

def _error(message):
    sys.exit(_red_string(_ERROR + message))

def _statement(message):
    print blue_string(message)

def _action(message):
    print _magenta_string(pad(message) + ' . . .')

def _action_no_eol(message):
    print _magenta_string(pad(message) + ' . . .'),

def _verbose(message, verbose):
    if verbose:
        print _cyan_string(message)

def _killed (pro=None):
    if pro != None:
        pro.terminate()
        pro.wait()
    print _red_string('Killed!')
    sys.exit(1)

def _exec(string, verbose):
    'execute the string in a subprocess.'
    if verbose:
        print _cyan_string(string + ' . . .')
    try:
        if verbose:
            pro = subprocess.check_call(string,
                                        stdout=subprocess.STDOUT,
                                        stderr=subprocess.STDOUT,
                                        shell=True)
        else:
            devnull = open(os.devnull, 'w')
            pro = subprocess.check_call(string,
                                        stdout=devnull,
                                        stderr=devnull,
                                        shell=True)
    except KeyboardInterrupt:
        sys.exit(_red_string(_ERROR + string + ' failed'))
    except (subprocess.CalledProcessError, OSError):
        sys.exit(_red_string(_ERROR + string + ' failed'))

################################################################################
# Check the version numbers and dates in various files
################################################################################

def _version_number_package_info():
    '''returns the version number from the PackageInfo.g file, exits if this
    file doesn't exist or the version number can't be found.'''

    if not (os.path.exists('PackageInfo.g') and
            os.path.isfile('PackageInfo.g')):
        _error('cannot find PackageInfo.g file')
    else:
        try:
            contents = open('PackageInfo.g', 'r').read()
        except IOError:
            _error('cannot read PackageInfo.g')
        match = re.compile(r'Version\s*:=\s*"((\d.*)+)"').search(contents)
        if match:
            return match.group(1)
        else:
            _error('could not determine the' +
                   ' version number in PackageInfo.g')

def _check_date_package_info():
    '''checks if the date in the PackageInfo.g file is today's date'''

    if not (os.path.exists('PackageInfo.g') and
            os.path.isfile('PackageInfo.g')):
        _error('cannot find PackageInfo.g file')
    else:
        try:
            contents = open('PackageInfo.g', 'r').read()
        except IOError:
            _error('cannot read PackageInfo.g')
        regex = re.compile(r'Date\s*:=\s*"(\d\d/\d\d/\d\d\d\d)"')
        match = regex.search(contents)
        if match:
            today = time.strftime("%d/%m/%Y")
            if match.group(1) != today:
                _abort('Date in PackageInfo.g is ' + match.group(1)
                       + ' but today is ' + today)
        else:
            _error('could not determine the ' +
                   'version number in PackageInfo.g')

def _check_versions_file(vers, verbose):
    ''

    if not (os.path.exists('VERSIONS') and
            os.path.isfile('VERSIONS')):
        _error('cannot find VERSIONS file')
    else:
        today = time.strftime("%d/%m/%y")
        try:
            contents = open('VERSIONS', 'r').read()
        except IOError:
            _error('cannot read VERSIONS file')

        regex = re.compile(r'release\s+' +
                r'(\d+.\d+.\d+|\d+.\d+)\s*\-\s*(\d\d/\d\d/\d\d)')
        match = regex.search(contents)

        if match:
            if match.group(1) != vers:
                _abort('The version number in VERSIONS is ' + match.group(1)
                       + 'should be ' + vers)
            if verbose:
                print _cyan_string('Version in VERSIONS file is ' +
                                   match.group(1))
            if match.group(2) != today:
                _abort('The date in VERSIONS is ' + match.group(2)
                       + ' but today is ' + today)

            return match.group(1)
        else:
            _error('could not determine the ' + 'version in VERSIONS')

def _check_version_file(vers, verbose):
    ''

    if not (os.path.exists('VERSION') and
            os.path.isfile('VERSION')):
        _error('cannot find VERSION file')
    else:
        try:
            contents = open('VERSION', 'r').read()
        except IOError:
            _error('cannot read VERSION file')

        regex = re.compile(r'(\d+.\d+.\d+|\d+.\d+)')
        match = regex.search(contents)

        if match:
            if match.group(1) != vers:
                _abort('The version number in VERSION is ' + match.group(1)
                       + 'should be ' + vers)
            if verbose:
                print _cyan_string('Version in VERSION file is ' +
                                   match.group(1))
        else:
            _error('could not determine the ' + 'version in VERSIONS')

def _check_change_log(vers, verbose):
    ''

    if not (os.path.exists('CHANGELOG.md') and
            os.path.isfile('CHANGELOG.md')):
        _error('cannot find CHANGELOG.md file')
    else:
        try:
            contents = open('CHANGELOG.md', 'r').read()
        except IOError:
            _error('cannot read CHANGELOG.md file')

        today = time.strftime("%d/%m/%Y")
        regex = re.compile(r'##\s*Version\s*' + vers +
                           r'\s*\(released\s*(\d\d/\d\d/\d\d\d\d)\)')
        match = regex.search(contents)

        if match:
            if match.group(1) != today:
                _abort('The date in CHANGELOG.md is ' + match.group(1)
                       + ' but today is ' + today)
        else:
            _abort('The entry for Version ' + vers + ' in CHANGELOG.md'
                   + ' is missing or incorrect')

################################################################################
# Mercurial stuff
################################################################################

def _check_hg_version(vers):
    '''returns the version number from the branch name in mercurial, exits if
    something goes wrong'''
    try:
        hg_version = subprocess.check_output(['hg', 'branch']).strip()
    except KeyboardInterrupt:
        _killed()
    except (subprocess.CalledProcessError, OSError):
        _error('could not determine the hg branch')
    if hg_version != vers:
        _abort('The version number in the PackageInfo.g file is '
               + vers + ' but the branch name is ' + hg_version)

def _hg_identify():
    'returns the current changeset'
    try:
        hg_identify = subprocess.check_output(['hg', 'identify']).strip()
    except (OSError, subprocess.CalledProcessError):
        _error('could not determine the version number')
    return hg_identify.split('+')[0]

def _hg_pending_commits():
    pro = subprocess.Popen(('hg', 'summary'),
                           stdout=subprocess.PIPE)
    output = subprocess.check_output(('grep', 'commit:'),
                                     stdin=pro.stdout).rstrip()
    if output != 'commit: (clean)' and output != 'commit: (head closed)':
        pro = subprocess.Popen(('hg', 'summary'), stdout=subprocess.PIPE)
        try:
            output = subprocess.check_output(('grep', 'commit:.*clean'),
                                             stdin=pro.stdout).rstrip()
        except KeyboardInterrupt: #TODO add this in more places
            _killed(pro)
        except:
            _abort('There are uncommited changes')

def _hg_tag_release(vers, verbose):
    _exec('hg tag -f ' + vers + '-release', verbose)

################################################################################
# Steps in the release process
################################################################################

def _copy_doc(dst, verbose):
    for filename in os.listdir('doc'):
        if os.path.splitext(filename)[-1] in ['.html', '.txt', '.pdf', '.css',
                '.js', '.six']:
            _verbose('Copying ' + filename + ' to the archive . . .', verbose)
            shutil.copy('doc/' + filename, dst)

def _create_build_files(dst, verbose):
    cwd = os.getcwd()
    os.chdir(dst)
    _exec('./autogen.sh', verbose)
    os.chdir(cwd)

def _delete_generated_build_files(verbose):
    for filename in ['config.log', 'config.status']:
        if os.path.exists(filename) and os.path.isfile(filename):
            _verbose('Deleting ' + filename + ' from the archive . . .',
                     verbose)
            os.remove(filename)
    for directory in ['digraphs-lib']:
        if os.path.exists(directory) and os.path.isdir(directory):
            _verbose('Deleting ' + directory + ' from the archive . . .',
                     verbose)
            shutil.rmtree(directory)

def _delete_files_archive(tmpdir):
    # delete extra files and dirs
    for filename in _FILES_TO_DELETE_FROM_ARCHIVE:
        if (os.path.exists(os.path.join(tmpdir, filename))
                and os.path.isfile(os.path.join(tmpdir, filename))):
            _action('Deleting file ' + filename)
            try:
                os.remove(os.path.join(tmpdir, filename))
            except:
                _error('could not delete ' + filename)

    _action('Deleting directory scripts')

    try:
        shutil.rmtree(os.path.join(tmpdir, 'scripts'))
    except:
        _error('could not delete scripts/*')

def _download_digraphs_lib_inner(dst, verbose):
    urllib.urlretrieve(_DIGRAPHS_LIB_URL, _DIGRAPHS_LIB_ARCHIVE)
    _exec('tar -xzf ' + _DIGRAPHS_LIB_ARCHIVE, verbose)
    shutil.copytree('digraphs-lib', dst + '/digraphs-lib')

def _download_digraphs_lib(tmpdir, verbose):
    _action_no_eol('Downloading ' + _DIGRAPHS_LIB_ARCHIVE)
    sys.stdout.flush()
    dots.dotIt(MAGENTA_DOT, _download_digraphs_lib_inner, tmpdir, verbose)
    print ''

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
    # Parse the args
    parser = argparse.ArgumentParser(prog='release.py',
                                     usage='%(prog)s [options]')

    parser.add_argument('--verbose', dest='verbose', action='store_true',
                        help='verbose mode (default: False)')
    parser.set_defaults(verbose=False)
    parser.add_argument('--skip-tests', dest='skip_tests', action='store_true',
                        help='skip running all the tests (default: False)')
    parser.set_defaults(skip_tests=False)
    parser.add_argument('--skip-extreme', dest='skip_extreme', action='store_true',
                        help='skip running the extreme tests (default: False)')
    parser.set_defaults(skip_extreme=False)
    parser.add_argument('--gap-root', nargs='*', type=str,
                        help='the gap root directory (default: [~/gap])',
                        default=['~/gap/'])
    parser.add_argument('--pkg-dir', nargs='?', type=str,
                        help='the pkg directory (default: gap-root/pkg/)',
                        default='~/gap/pkg/')

    args = parser.parse_args()

    if args.skip_tests:
        args.skip_extreme = True

    for i in xrange(len(args.gap_root)):
        if args.gap_root[i][-1] != '/':
            args.gap_root[i] += '/'
    if not args.pkg_dir[-1] == '/':
        args.pkg_dir += '/'

    args.gap_root = [os.path.expanduser(x) for x in args.gap_root]
    args.pkg_dir = os.path.expanduser(args.pkg_dir)

    for gap_root_dir in args.gap_root:
        if not (os.path.exists(gap_root_dir) and os.path.isdir(gap_root_dir)):
            _error('can\'t find GAP root directory' + gap_root_dir + '!')
    if not (os.path.exists(args.pkg_dir) or os.path.isdir(args.pkg_dir)):
        _error('can\'t find package directory!')

    # Check for pending commits
    _hg_pending_commits()

    # Get the version number
    vers = _version_number_package_info()
    _statement('The version number is: ' + vers)

    # Check the CHANGELOG.md, VERSIONS, and VERSION
    _check_hg_version(vers)
    _check_date_package_info()
    _check_change_log(vers, args.verbose)
    _check_version_file(vers, args.verbose)
    _check_versions_file(vers, args.verbose)

    # Compile the doc
    test.digraphs_make_doc(args.gap_root[0])

    # Get the temporary dir
    tmpdir_base = tempfile.mkdtemp()
    tmpdir = tmpdir_base + '/digraphs-' + vers
    _verbose('Using temporary directory: ' + tmpdir, args.verbose)

    # Tag . . .
    _action('Tagging the last commit')
    _hg_tag_release(vers, args.verbose)

    # Archive
    _action('Archiving using hg')
    _exec('hg archive ' + tmpdir, args.verbose)

    # Copy the doc . . .
    _copy_doc(tmpdir + '/doc/', args.verbose)

    # Run autogen.sh
    _action('Creating the build files')
    _create_build_files(tmpdir, args.verbose)

    # Delete unnecessary files from the archive
    _delete_files_archive(tmpdir)

    # Download digraphs-lib if we want to run extreme tests
    if not args.skip_extreme:
        _download_digraphs_lib(tmpdir, args.verbose)

    # Run the tests
    if args.skip_tests:
        _statement('Skipping tests' + ' . . .')
    else:
        _action('Running the tests on the archive')
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

            try:#TODO pass skip-extreme here!
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

    # Create the archive file
    _action('Creating the tarball')
    os.chdir(tmpdir)
    _delete_generated_build_files(args.verbose)
    os.chdir(tmpdir_base)
    _exec('tar -cpf digraphs-' + vers + '.tar digraphs-' + vers +
          '; gzip -9 digraphs-' + vers + '.tar', args.verbose)

    # Copy files to the local copy of the website
    _action('Copying to webpage' + ' . . .')
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
        print _red_string(_ERROR + 'could not copy to the webpage!')
        sys.exit(_red_string(str(e)))

    # hg add and commit files added
    os.chdir(_WEBPAGE_DIR)
    _action('Adding archive to webpage repo')
    _exec('hg add digraphs-' + vers + '.tar.gz', args.verbose)
    _exec('hg addremove', args.verbose)
    _action('Committing webpage repo')
    _exec('hg commit -m "Releasing digraphs ' + vers + '"', args.verbose)

    # open the webpage for inspection
    _start_mamp()
    webbrowser.open('http://localhost:8888/public_html/digraphs.php')

    # actually publish?
    publish = query_yes_no(_magenta_string('Publish the webpage?'))
    _stop_mamp()

    if not publish:
        sys.exit(_red_string('Aborting!'))

    # push the website changes
    _action('Pushing webpage to server')
    _exec('hg push', args.verbose)
    os.chdir(_DIGRAPHS_REPO_DIR)

    # merge the release branch into default
    _action('Merging ' + vers + ' into default')
    _exec('hg up -r default', args.verbose)
    _exec('hg merge -r ' + vers, args.verbose)
    _exec('hg commit -m "Merge from' + vers + '"', args.verbose)

    # close the release branch
    _action('Closing branch ' + vers)
    _exec('hg up -r ' + vers, args.verbose)
    _exec('hg commit --close-branch -m "closing branch"', args.verbose)

    # go back to default branch
    _action('Updating to default branch')
    _exec('hg up -r default', args.verbose)

    _statement('Don\'t forget to check everything is ok at: ' +
               'http://www.gap-system.org/Packages/Authors/authors.html')
    webbrowser.open('http://www.gap-system.org/Packages/Authors/authors.html')

    sys.exit(0)

################################################################################
# So that we can load this as a module if we want
################################################################################

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        _killed()
