#!/usr/bin/env bash

set -e
set -o pipefail

# This script is intended to be run inside a docker container
# that already has GAP installed

bold() {
    printf "\033[1m%s\033[0m\n" "$*"
}

################################################################################
# Check required environment variables are set
################################################################################

if [[ -z "${SUITE}" ]] ; then 
  bold "Error, environment variable SUITE is undefined"
  exit 1
fi

if [[ -z "${GAP_HOME}" ]] ; then 
  bold "Error, environment variable GAP_HOME is undefined"
  exit 1
fi

if [[ -z "${GAP_VERSION}" ]] ; then 
  bold "Error, environment variable GAP_VERSION is undefined"
  exit 1
fi

if [[ -z "${DIGRAPHS_LIB}" ]] ; then 
  bold "Error, environment variable GAP_VERSION is undefined"
  exit 1
fi

if [[ -z "${PACKAGES}" ]] ; then 
  bold "Error, environment variable GAP_VERSION is undefined"
  exit 1
fi

if [ "$SUITE" == "coverage" ] && [ -z "${THRESHOLD}" ] ; then
  bold "Error, environment variable THRESHOLD is undefined"
  exit 1
fi

if [ "$SUITE" != "test" ] && [ "$SUITE" != "coverage" ] && [ "$SUITE" != "conda" ] ; then
  bold "Error, unrecognised suite: $SUITE"
  exit 1
fi

env | grep -v "^LS_COLORS"

################################################################################
# Define globals
################################################################################

# Common curl settings
CURL="curl --connect-timeout 5 --max-time 40 --retry 5 --retry-delay 0  -L"
TESTLOG="$GAP_HOME/testlog.txt"
GAPSH="$GAP_HOME/bin/gap.sh"
DIG_DIR="$GAP_HOME/pkg/digraphs"

################################################################################
# Install system dependencies 
################################################################################

bold "Installing dependencies (apt-get). . ."
sudo apt-get --yes update
sudo apt-get install libtool curl git --yes

if [ "$GAP_VERSION" == "master" ]; then 
  # Stops the documentation from failing to compile because enumitem.sty isn't
  # available
  sudo apt-get remove texlive-latex-base --yes
fi

if [ "$SUITE" == "coverage" ]; then
  sudo apt-get install python3 --yes
fi

if [ "$SUITE" == "conda" ]; then
  bold "Installing dependencies (conda). . ."
  wget http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh;
  chmod +x miniconda.sh;
  ./miniconda.sh -b;
  export PATH=/home/gap/miniconda3/bin:$PATH;
  conda update --yes conda;
  conda install -c conda-forge --yes mamba;
  mamba install -c conda-forge --yes bliss;
  mamba install -c conda-forge --yes planarity;
  export PKG_CONFIG_PATH="/home/gap/miniconda3/lib/pkgconfig:/home/gap/miniconda3/share/pkgconfig"
  export LD_LIBRARY_PATH="/home/gap/miniconda3/lib"
  export CFLAGS="-I/home/gap/miniconda3/include"
  export LDFLAGS="-L/home/gap/miniconda3/lib"
  EXTREME=no
  EXTRA_PKG_FLAGS="--with-external-planarity --with-external-bliss --without-intrinsics"
  SUITE="test"
fi

bold "Fixing permissions . . . "
sudo chown -R gap: $GAP_HOME/pkg/digraphs

################################################################################
# Compile Digraphs and install Digraphs lib
################################################################################

bold "Compiling the Digraphs package..."
cd "$GAP_HOME/pkg/digraphs"
./autogen.sh
./configure $PKG_FLAGS $EXTRA_PKG_FLAGS
make

bold "Downloading $DIGRAPHS_LIB..."
$CURL -O https://digraphs.github.io/Digraphs/$DIGRAPHS_LIB.tar.gz
tar xf $DIGRAPHS_LIB.tar.gz
rm $DIGRAPHS_LIB.tar.gz

################################################################################
# Copy Digraphs to its proper location
################################################################################

if [ "$SETUP" == "appveyor" ]; then
  cp -r /cygdrive/c/projects/digraphs $GAP_HOME/pkg/digraphs
fi

################################################################################
# Install gap dependencies
################################################################################

bold "Installing GAP dependencies . . ."
PKGS=( "io" "orb" "datastructures" )
if [ "$GRAPE" != "no" ]; then
  PKGS+=( "grape" )
fi
if [ "$SUITE" == "coverage" ]; then
  PKGS+=( "profiling" )
fi

for PKG in "${PKGS[@]}"; do
  cd $GAP_HOME/pkg

  # Get the relevant version number
  if [ "${PACKAGES[0]}" == "latest" ] || [ "$PKG" == "profiling" ]; then
    VERSION=`$CURL -s "https://github.com/gap-packages/$PKG/releases/latest" | grep \<title\>Release | awk -F' ' '{print $2}'`
  else
    VERSION=`grep "\"$PKG\"" $GAP_HOME/pkg/digraphs/PackageInfo.g | awk -F'"' '{print $4}' | cut -c3-`
  fi
  
  if [ -z $VERSION ]; then
    bold "Could not determine the version number of the package $PKG!! Aborting..."
    exit 1
  fi

  URL="https://github.com/gap-packages/$PKG/releases/download/v$VERSION/$PKG-$VERSION.tar.gz"
  bold "Downloading $PKG-$VERSION (${PACKAGES[0]} version), from URL:"
  bold "$URL"
  $CURL "$URL" -o $PKG-$VERSION.tar.gz
  (tar xf $PKG-$VERSION.tar.gz && rm $PKG-$VERSION.tar.gz) || exit 1

  if [ -f $PKG-$VERSION/configure ]; then
    if [ "$PKG" == "orb" ] || [ "$PKG" == "grape" ] || [ "$PKG" == "datastructures" ]; then
      cd $PKG-$VERSION && ./configure && make # orb/grape don't accept flags
    else
      cd $PKG-$VERSION && ./configure $PKG_FLAGS && make
    fi
  fi
done

################################################################################
## Install NautyTracesInterface
################################################################################
if [ "$SETUP" != "appveyor" ] && [ "$NAUTY" != "no" ]; then
  bold "Getting master version of NautyTracesInterface . . ."
  git clone -b master --depth=1 https://github.com/gap-packages/NautyTracesInterface.git $GAP_HOME/pkg/nautytraces
  cd $GAP_HOME/pkg/nautytraces/nauty2*r* && ./configure $PKG_FLAGS && make
  cd $GAP_HOME/pkg/nautytraces && ./autogen.sh && ./configure $PKG_FLAGS && make
fi

################################################################################
## Run the tests
touch $GAP_HOME/testlog.txt

if [ "$SUITE" == "coverage" ]; then

  bold "Performing code coverage tests..."
  for TEST in $DIG_DIR/tst/standard/*.tst; do
    FILENAME=${TEST##*/}
    if [ ! `grep -E "$FILENAME" $DIG_DIR/.covignore` ]; then
      $DIG_DIR/ci/coverage.py $TEST $THRESHOLD | tee -a $TESTLOG
    else
      bold "ignoring $FILENAME, which is listed in .covignore"
    fi
  done

elif [ "$SUITE" == "test" ]; then

  # Temporary workaround because of GAP being weird with memory
  if [ "$ABI" == "32" ]; then
    MEM=1g
  elif [ "$ABI" == "64" ]; then
    MEM=2g
  fi

  cd $DIG_DIR/tst/workspaces
  bold "Running SaveWorkspace tests..."
  echo "LoadPackage(\"digraphs\"); DigraphsTestInstall(); Test(\"save-workspace.tst\"); quit; quit; quit;" |
    $GAPSH -A -m 768m -o $MEM -T 2>&1 | tee -a $TESTLOG

  bold "Running LoadWorkspace tests..."
  echo "Test(\"load-workspace.tst\"); DigraphsTestInstall(); quit; quit; quit;" |
    $GAPSH -L test-output.w -A -x 80 -r -m 768m -o $MEM -T 2>&1 | tee -a $TESTLOG

  bold "Running Digraphs package standard tests and manual examples..."
  echo "LoadPackage(\"digraphs\"); DigraphsTestAll();" |
    $GAPSH -A -x 80 -m 768m -o $MEM -T 2>&1 | tee -a $TESTLOG

  if [ ! "$EXTREME" == "no" ]; then
    bold "Running Digraphs package extreme tests..."
    echo "LoadPackage(\"digraphs\"); DigraphsTestExtreme();" |
      $GAPSH -A -x 80 -m 768m -o $MEM -T 2>&1 | tee -a $TESTLOG
  fi
fi

bold "Suite complete." # AppVeyor needs some extra command here (like this)

( ! grep -E "Diff|brk>|#E|Error|Errors detected|# WARNING|Syntax warning|Couldn't open saved workspace|insufficient|WARNING in|FAILED|Total errors found:" $TESTLOG )
