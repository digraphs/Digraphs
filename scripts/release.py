#!/usr/bin/env python
'''
Create the archive of the Digraphs package for release, and copy the relevant
things to the webpage.
'''

# TODO
# 1) --dry-run

import os, argparse, tempfile, subprocess, sys, os, re, shutil
import test, time, webbrowser, urllib, dots

from test import *

################################################################################
# Configurable variables
################################################################################

_WEBPAGE_DIR = os.path.expanduser('~/Sites/public_html/digraphs/')
_MAMP_DIR = '/Applications/MAMP/'
_DIGRAPHS_REPO_DIR = os.path.expanduser('~/gap/pkg/digraphs/')
_DIGRAPHS_LIB_ARCHIVE = 'digraphs-lib-0.5.tar.gz'
_DIGRAPHS_LIB_URL = ('https://bitbucket.org/james-d-mitchell/digraphs/downloads/'
                     + _DIGRAPHS_LIB_ARCHIVE)
_FILES_TO_DELETE_FROM_ARCHIVE = ['.hgignore', '.hgtags', '.gaplint_ignore',
                                 '.hg_archival.txt']

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
        prompt = magenta_string(" [y/n] ")
    elif default == "yes":
        prompt = magenta_string(" [Y/n] ")
    elif default == "no":
        prompt = magenta_string(" [y/N] ")
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
# Check the version numbers and dates in various files
################################################################################

def _version_number_package_info():
    '''returns the version number from the PackageInfo.g file, exits if this
    file doesn't exist or the version number can't be found.'''

    if not (os.path.exists('PackageInfo.g') and
            os.path.isfile('PackageInfo.g')):
        exit_error('cannot find PackageInfo.g file')
    else:
        try:
            contents = open('PackageInfo.g', 'r').read()
        except KeyboardInterrupt:
            exit_killed()
        except IOError:
            exit_error('cannot read PackageInfo.g')
        match = re.compile(r'Version\s*:=\s*"((\d.*)+)"').search(contents)
        if match:
            return match.group(1)
        else:
            exit_error('could not determine the' +
                       ' version number in PackageInfo.g')

def _check_date_package_info():
    '''checks if the date in the PackageInfo.g file is today's date'''

    if not (os.path.exists('PackageInfo.g') and
            os.path.isfile('PackageInfo.g')):
        exit_error('cannot find PackageInfo.g file')
    else:
        try:
            contents = open('PackageInfo.g', 'r').read()
        except KeyboardInterrupt:
            exit_killed()
        except IOError:
            exit_error('cannot read PackageInfo.g')
        regex = re.compile(r'Date\s*:=\s*"(\d\d/\d\d/\d\d\d\d)"')
        match = regex.search(contents)
        if match:
            today = time.strftime("%d/%m/%Y")
            if match.group(1) != today:
                exit_abort('Date in PackageInfo.g is ' + match.group(1)
                           + ' but today is ' + today)
        else:
            exit_error('could not determine the ' +
                       'version number in PackageInfo.g')

def _check_versions_file():
    'check the date and version number in the VERSIONS file'

    if not (os.path.exists('VERSIONS') and
            os.path.isfile('VERSIONS')):
        exit_error('cannot find VERSIONS file')
    else:
        today = time.strftime("%d/%m/%y")
        try:
            contents = open('VERSIONS', 'r').read()
        except KeyboardInterrupt:
            exit_killed()
        except IOError:
            exit_error('cannot read VERSIONS file')

        regex = re.compile(r'release\s+(\d+.\d+.\d+|\d+.\d+)\s*\-\s*' +
                           r'(\d\d/\d\d/\d\d)')
        match = regex.search(contents)

        if match:
            if match.group(1) != _VERSION:
                exit_abort('The version number in VERSIONS is ' + match.group(1)
                           + ' should be ' + _VERSION)
            info_verbose('Version in VERSIONS file is ' + match.group(1))
            if match.group(2) != today:
                exit_abort('The date in VERSIONS is ' + match.group(2)
                           + ' but today is ' + today)

            return match.group(1)
        else:
            exit_error('could not determine the ' + 'version in VERSIONS')

def _check_version_file():
    'check the version number in the VERSION file'

    if not (os.path.exists('VERSION') and
            os.path.isfile('VERSION')):
        exit_error('cannot find VERSION file')
    else:
        try:
            contents = open('VERSION', 'r').read()
        except KeyboardInterrupt:
            exit_killed()
        except IOError:
            exit_error('cannot read VERSION file')

        regex = re.compile(r'(\d+.\d+.\d+|\d+.\d+)')
        match = regex.search(contents)

        if match:
            if match.group(1) != _VERSION:
                exit_abort('The version number in VERSION is ' + match.group(1)
                       + ' should be ' + _VERSION)
            info_verbose('Version in VERSION file is ' + match.group(1))
        else:
            exit_error('could not determine the version in VERSIONS')

def _check_change_log():
    ''

    if not (os.path.exists('CHANGELOG.md') and
            os.path.isfile('CHANGELOG.md')):
        exit_error('cannot find CHANGELOG.md file')
    else:
        try:
            contents = open('CHANGELOG.md', 'r').read()
        except KeyboardInterrupt:
            exit_killed()
        except IOError:
            exit_error('cannot read CHANGELOG.md file')

        today = time.strftime("%d/%m/%Y")
        regex = re.compile(r'##\s*Version\s*' + _VERSION +
                           r'\s*\(released\s*(\d\d/\d\d/\d\d\d\d)\)')
        match = regex.search(contents)

        if match:
            if match.group(1) != today:
                exit_abort('The date in CHANGELOG.md is ' + match.group(1)
                       + ' but today is ' + today)
        else:
            exit_abort('The entry for version ' + _VERSION + ' in CHANGELOG.md'
                   + ' is missing or incorrect')

def _check_package_info():
    '''check that all the version numbers in the package info and the archive
    names are correct.'''

    if not (os.path.exists('PackageInfo.g') and
            os.path.isfile('PackageInfo.g')):
        exit_error('cannot find PackageInfo.g file')

    try:
        contents = open('PackageInfo.g', 'r').read()
    except KeyboardInterrupt:
        exit_killed()
    except IOError:
        exit_error('cannot read PackageInfo.g')

    # get the doc's version number
    match = re.compile(r'<!ENTITY\s+VERSION\s*"((\d.*)+)"').search(contents)
    if match:
        if match.group(1) != _VERSION:
            exit_abort('The version for the doc in PackageInfo.g is ' +
                        match.group(1) + ' should be ' + _VERSION)
        else:
            info_verbose('The version in PackageInfo.g is ok')
    else:
        exit_abort('Can\'t find the digraphs version for the doc in PackageInfo.g')

    # check the ArchiveURL
    match = re.compile(r'ArchiveURL\s+:=\s+"([^"]*)"').search(contents)
    if match:
        if not match.group(1).endswith('digraphs-' + _VERSION):
            exit_abort('The ArchiveURL is ' + match.group(1).split('/')[-1]
                   + ' should be digraphs-' + _VERSION)
        else:
            info_verbose('The ArchiveURL is ok')
    else:
        exit_abort('Can\'t find the ArchiveURL in PackageInfo.g')

    # check ARCHIVENAME
    match = re.compile(r'<!ENTITY\s+ARCHIVENAME\s*"([^"]*)"').search(contents)
    if not match:
        exit_abort('Can\'t find the ARCHIVENAME for the doc in PackageInfo.g')
    if match.group(1) == 'digraphs-' + _VERSION:
        info_verbose('The ARCHIVENAME is ok')
    else:
        exit_abort('The doc archive name is ' + match.group(1) +
               ' it should be digraphs-' + _VERSION)

    # check GAPVERS
    match = re.compile(r'<!ENTITY\s+GAPVERS\s*"((\d.*)+)"').search(contents)
    if not match:
        exit_abort('Can\'t find the GAP version for the doc in PackageInfo.g')
    gapvers = match.group(1)
    match = re.compile(r'\s*GAP\s*:=\s*">=((\d.)*\d)"').search(contents)
    if match:
        if match.group(1) == gapvers:
            info_verbose('The GAP version is ok')
        else:
            exit_abort('The doc GAP version is ' + gapvers +
                   ' and dependencies GAP version is ' + match.group(1))
    else:
        exit_abort('Can\'t find the GAP version in Dependencies')

    # check IOVERS
    match = re.compile(r'<!ENTITY\s+IOVERS\s*"((\d.*)+)"').search(contents)
    if not match:
        exit_abort('Can\'t find the io version for the doc in PackageInfo.g')
    iovers = match.group(1)
    match = re.compile(r'"io"\s*,\s*">=((\d.)*\d)"').search(contents)
    if match:
        if match.group(1) == iovers:
            info_verbose('The IO version is ok')
        else:
            exit_abort('The doc io version is ' + iovers +
                   ' and dependencies io version is ' + match.group(1))
    else:
        exit_abort('Can\'t find the io version in Dependencies')

    # check GRAPEVERS
    match = re.compile(r'<!ENTITY\s+GRAPEVERS\s*"((\d.*)+)"').search(contents)
    if not match:
        exit_abort('Can\'t find the grape version for the doc in PackageInfo.g')
    grapevers = match.group(1)
    match = re.compile(r'"grape"\s*,\s*">=((\d.)*\d)"').search(contents)
    if match:
        if match.group(1) == grapevers:
            info_verbose('The GRAPE version is ok')
        else:
            exit_abort('The doc grape version is ' + grapevers +
                   ' and dependencies grape version is ' + match.group(1))
    else:
        exit_abort('Can\'t find the grape version in Dependencies')

################################################################################
# Mercurial stuff
################################################################################

def _check_hg_version():
    '''returns the version number from the branch name in mercurial, exits if
    something goes wrong'''
    try:
        hg_version = subprocess.check_output(['hg', 'branch']).strip()
    except KeyboardInterrupt:
        exit_killed()
    except (subprocess.CalledProcessError, OSError):
        exit_error('could not determine the hg branch')
    if hg_version != _VERSION:
        exit_abort('The version number in the PackageInfo.g file is '
               + _VERSION + ' but the branch name is ' + hg_version)

def _hg_identify():
    'returns the current changeset'
    try:
        hg_identify = subprocess.check_output(['hg', 'identify']).strip()
    except KeyboardInterrupt:
        exit_killed()
    except (OSError, subprocess.CalledProcessError):
        exit_error('could not determine the version number')
    return hg_identify.split('+')[0]

def _hg_pending_commits():
    'check for pending hg commits'
    pro = subprocess.Popen(('hg', 'summary'),
                           stdout=subprocess.PIPE)
    output = subprocess.check_output(('grep', 'commit:'),
                                     stdin=pro.stdout).rstrip()
    if output != 'commit: (clean)' and output != 'commit: (head closed)':
        pro = subprocess.Popen(('hg', 'summary'), stdout=subprocess.PIPE)
        try:
            output = subprocess.check_output(('grep', 'commit:.*clean'),
                                             stdin=pro.stdout).rstrip()
        except KeyboardInterrupt:
            exit_killed(pro)
        except:
            exit_abort('There are uncommited changes')

def _hg_tag_release():
    'hg tag the repo'
    exec_string('hg tag -f ' + _VERSION + '-release')

################################################################################
# Steps in the release process
################################################################################

def _copy_doc(dst):
    for filename in os.listdir('doc'):
        if (os.path.splitext(filename)[-1] in
                ['.html', '.txt', '.pdf', '.css', '.js', '.six']):
            info_verbose('Copying ' + filename + ' to the archive')
            shutil.copy('doc/' + filename, dst)

def _create_build_files(dst):
    cwd = os.getcwd()
    os.chdir(dst)
    exec_string('./autogen.sh')
    os.chdir(cwd)

def _delete_generated_build_files():
    for filename in ['config.log', 'config.status']:
        if os.path.exists(filename) and os.path.isfile(filename):
            info_verbose('Deleting ' + filename + ' from the archive')
            os.remove(filename)
    for directory in ['digraphs-lib']:
        if os.path.exists(directory) and os.path.isdir(directory):
            info_verbose('Deleting ' + directory + ' from the archive')
            shutil.rmtree(directory)

def _delete_files_archive(tmpdir):
    # delete extra files and dirs
    for filename in _FILES_TO_DELETE_FROM_ARCHIVE:
        if (os.path.exists(os.path.join(tmpdir, filename))
                and os.path.isfile(os.path.join(tmpdir, filename))):
            info_action('Deleting file ' + filename)
            try:
                os.remove(os.path.join(tmpdir, filename))
            except KeyboardInterrupt:
                exit_killed()
            except:
                exit_error('could not delete ' + filename)

    info_action('Deleting directory scripts')

    try:
        shutil.rmtree(os.path.join(tmpdir, 'scripts'))
    except KeyboardInterrupt:
        exit_killed()
    except:
        exit_error('could not delete scripts/*')

def _download_digraphs_lib(tmpdir):
    def inner(dst):
        urllib.urlretrieve(_DIGRAPHS_LIB_URL, _DIGRAPHS_LIB_ARCHIVE)
        shutil.copytree('digraphs-lib', dst + '/digraphs-lib')

    info_action('Downloading ' + _DIGRAPHS_LIB_ARCHIVE, False)
    sys.stdout.flush()
    if not _VERBOSE:
        dots.dotIt(magenta_string('. '), inner, tmpdir)
    else:
        inner(tmpdir)
    print ''
    exec_string('tar -xzf ' + _DIGRAPHS_LIB_ARCHIVE)

def _start_mamp():
    exec_string('open ' + _MAMP_DIR + 'MAMP.app')
    cwd = os.getcwd()
    os.chdir(_MAMP_DIR + 'bin')
    exec_string('./start.sh')
    os.chdir(cwd)

def _stop_mamp():
    cwd = os.getcwd()
    os.chdir(_MAMP_DIR + 'bin')
    exec_string('./stop.sh')
    os.chdir(cwd)

################################################################################
# The main event
################################################################################

def _main():
    global _VERBOSE, _VERSION
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
    parser.add_argument('--dry-run', dest='dry_run', action='store_true',
                        help='dry run (default: False)')
    parser.set_defaults(dry_run=False)
    parser.add_argument('--gap-root', nargs='*', type=str,
                        help='the gap root directory (default: [~/gap])',
                        default=['~/gap/'])
    parser.add_argument('--pkg-dir', nargs='?', type=str,
                        help='the pkg directory (default: gap-root/pkg/)',
                        default='~/gap/pkg/')

    args = parser.parse_args()

    # set verbose in test.py
    set_verbose(args.verbose)
    _VERBOSE = args.verbose

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
            exit_error('can\'t find GAP root directory' + gap_root_dir + '!')
    if not (os.path.exists(args.pkg_dir) or os.path.isdir(args.pkg_dir)):
        exit_error('can\'t find package directory!')

    # Check for pending commits
    if not args.dry_run:
        _hg_pending_commits()

    # Get the version number
    _VERSION = _version_number_package_info()
    print neon_green_string(pad_string('The version number is:') + _VERSION)

    # Check the CHANGELOG.md, VERSIONS, and VERSION
    _check_hg_version()
    _check_date_package_info()
    _check_change_log()
    _check_version_file()
    _check_versions_file()
    _check_package_info()

    # Compile the doc
    test.digraphs_make_doc(args.gap_root[0])

    # Get the temporary dir
    tmpdir_base = tempfile.mkdtemp()
    tmpdir = tmpdir_base + '/digraphs-' + _VERSION
    info_verbose('Using temporary directory: ' + tmpdir)

    # Tag . . .
    if not args.dry_run:
        info_action('Tagging the last commit')
        _hg_tag_release()

    # Archive
    info_action('Archiving using hg')
    exec_string('hg archive ' + tmpdir)

    # Copy the doc . . .
    _copy_doc(tmpdir + '/doc/')

    # Run autogen.sh
    info_action('Creating the build files')
    _create_build_files(tmpdir)

    # Delete unnecessary files from the archive
    _delete_files_archive(tmpdir)

    # Download digraphs-lib if we want to run extreme tests
    if not args.skip_extreme:
        _download_digraphs_lib(tmpdir)

    # Run the tests
    if args.skip_tests:
        info_statement('Skipping tests')
    else:
        info_statement('Running test.py')
        os.chdir(tmpdir_base)
        for directory in args.gap_root:
            digraphs_dir = os.path.join(directory, 'pkg/digraphs-' + _VERSION)
            try:
                shutil.copytree('digraphs-' + _VERSION, digraphs_dir)
                if os.path.exists(os.path.join(directory, 'pkg/digraphs')):
                    shutil.move(os.path.join(directory, 'pkg/digraphs'),
                                tmpdir_base)
            except KeyboardInterrupt:
                exit_killed()
            except Exception as e:
                sys.exit(red_string(str(e)))

            try:
                test.run_digraphs_tests(directory,
                                        directory + '/pkg',
                                        'digraphs-' + _VERSION,
                                        args.skip_extreme)
            except (OSError, IOError) as e:
                sys.exit(red_string(str(e)))
            finally:
                if os.path.exists(os.path.join(tmpdir_base, 'digraphs')):
                    shutil.move(os.path.join(tmpdir_base, 'digraphs'),
                                os.path.join(directory, 'pkg/digraphs'))
                shutil.rmtree(digraphs_dir)

    # Create the archive file
    info_action('Creating the tarball')
    os.chdir(tmpdir)
    _delete_generated_build_files()
    os.chdir(tmpdir_base)
    exec_string('tar -cpf digraphs-' + _VERSION + '.tar digraphs-' + _VERSION)
    exec_string('gzip -9 digraphs-' + _VERSION + '.tar')

    # Copy files to the local copy of the website
    info_action('Copying to webpage')
    try:
        os.chdir(tmpdir_base)
        shutil.copy('digraphs-' + _VERSION + '.tar.gz', _WEBPAGE_DIR)
        os.chdir(tmpdir)
        shutil.copy('README.md', _WEBPAGE_DIR)
        shutil.copy('PackageInfo.g', _WEBPAGE_DIR)
        shutil.copy('CHANGELOG.md', _WEBPAGE_DIR)
        shutil.rmtree(_WEBPAGE_DIR + 'doc')
        shutil.copytree('doc', _WEBPAGE_DIR + 'doc')
    except KeyboardInterrupt:
        exit_killed()
    except Exception as e:
        print red_string(exit_error + 'could not copy to the webpage!')
        sys.exit(red_string(str(e)))

    # hg add and commit files added
    os.chdir(_WEBPAGE_DIR)
    if not args.dry_run:
        info_action('Adding archive to webpage repo')
        exec_string('hg add digraphs-' + _VERSION + '.tar.gz')
        exec_string('hg addremove')
        info_action('Committing webpage repo')
        exec_string('hg commit -m "Releasing digraphs ' + _VERSION + '"')

    # open the webpage for inspection
    _start_mamp()
    webbrowser.open('http://localhost:8888/public_html/digraphs.php')

    # actually publish?
    if not args.dry_run:
        publish = query_yes_no(magenta_string('Publish the webpage?'))
        _stop_mamp()

        if not publish:
            exit_abort()
    else:
        print neon_green_string('Dry run succeeded!')
        exit_abort()

    # push the website changes
    info_action('Pushing webpage to server')
    exec_string('hg push')
    os.chdir(_DIGRAPHS_REPO_DIR)

    # merge the release branch into default
    info_action('Merging ' + _VERSION + ' into default')
    exec_string('hg up -r default')
    exec_string('hg merge -r ' + _VERSION)
    exec_string('hg commit -m "Merge from' + _VERSION + '"')

    # close the release branch
    info_action('Closing branch ' + _VERSION)
    exec_string('hg up -r ' + _VERSION)
    exec_string('hg commit --close-branch -m "closing branch"')

    # go back to default branch
    info_action('Updating to default branch')
    exec_string('hg up -r default')

    info_statement('Don\'t forget to check everything is ok at: ' +
                   'http://www.gap-system.org/Packages/Authors/authors.html')
    webbrowser.open('http://www.gap-system.org/Packages/Authors/authors.html')

    sys.exit(0)

################################################################################
# So that we can load this as a module if we want
################################################################################

if __name__ == '__main__':
    try:
        _main()
    except KeyboardInterrupt:
        exit_killed()
