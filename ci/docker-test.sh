#!/usr/bin/env bash

# If a command fails, exit this script with an error code
set -e
set -o pipefail

# This script is intended to be run inside the docker container
# gapsystem/gap-docker

echo -e "\nInstalling dependencies . . . "
sudo apt-get --yes update
sudo apt-get --yes upgrade
sudo apt-get install libtool curl --yes

# TODO check that environment variables exist

if [ "$SUITE" == "lint" ]; then
  # Install cpplint and gaplint
  sudo pip install cpplint
  sudo pip install gaplint
fi

echo -e "\nFixing permissions . . . "
sudo chown -R gap: $GAP_HOME/pkg/digraphs

################################################################################
# Compile Digraphs and install Digraphs lib
if [ "$SUITE" != "lint" ]; then
  echo -e "\nCompiling the Digraphs package..."
  cd "$GAP_HOME/pkg/digraphs"
  ./autogen.sh
  ./configure $PKG_FLAGS $EXTRA_PKG_FLAGS
  make
  echo -e "\nDownloading $DIGRAPHS_LIB..."
  curl --retry 5 -L -O https://gap-packages.github.io/Digraphs/$DIGRAPHS_LIB.tar.gz
  tar xf $DIGRAPHS_LIB.tar.gz
  rm $DIGRAPHS_LIB.tar.gz
fi

if [ "$SUITE" != "test" ] && [ "$SUITE" != "coverage" ] && [ "$SUITE" != "lint" ]; then
  echo -e "\nError, unrecognised Travis suite: $SUITE"
  exit 1
fi

################################################################################
# Install software necessary for linting: cpplint and gaplint
################################################################################

################################################################################
# Copy Digraphs to its proper location
if [ "$SETUP" == "appveyor" ]; then
  cp -r /cygdrive/c/projects/digraphs $GAP_HOME/pkg/digraphs
fi

# Common curl settings
CURL="curl --connect-timeout 5 --max-time 10 --retry 5 --retry-delay 0 --retry-max-time 40 -L"

################################################################################
# Install grape, io, orb, and profiling
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
    echo -e "\nCould not determine the version number of the package $PKG!! Aborting..."
    exit 1
  fi

  URL="https://github.com/gap-packages/$PKG/releases/download/v$VERSION/$PKG-$VERSION.tar.gz"
  echo -e "\nDownloading $PKG-$VERSION (${PACKAGES[0]} version), from URL:\n$URL"
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
## Install NautyTracesInterface in Travis
if [ "$SETUP" == "travis" ] && [ "$NAUTY" != "no" ]; then
  echo -e "\nGetting master version of NautyTracesInterface"
  git clone -b master --depth=1 https://github.com/sebasguts/NautyTracesInterface.git $GAP_HOME/pkg/nautytraces
  cd $GAP_HOME/pkg/nautytraces/nauty2*r* && ./configure $PKG_FLAGS && make
  cd $GAP_HOME/pkg/nautytraces && ./autogen.sh && ./configure $PKG_FLAGS && make
fi

################################################################################
## Run the tests
touch $GAP_HOME/testlog.txt
TESTLOG="$GAP_HOME/testlog.txt"
GAPSH="$GAP_HOME/bin/gap.sh"
DIG_DIR="$GAP_HOME/pkg/digraphs"

if [ "$SUITE" == "lint" ]; then
  
  echo -e "\nLinting with gaplint and cpplint..."
  cd $DIG_DIR
  gaplint `grep "^\s\+gaplint" Makefile.am | cut -d " " -f2-`
  cpplint --extensions=c,cc,h `grep "^\s\+cpplint" Makefile.am | cut -d " " -f2-`

elif [ "$SUITE" == "coverage" ]; then

  echo -e "\nPerforming code coverage tests..."
  for TEST in $DIG_DIR/tst/standard/*.tst; do
    FILENAME=${TEST##*/}
    if [ ! `grep -E "$FILENAME" $DIG_DIR/.covignore` ]; then
      $DIG_DIR/scripts/travis-coverage.py $TEST $THRESHOLD | tee -a $TESTLOG
    else
      echo -e "\033[35mignoring $FILENAME, which is listed in .covignore\033[0m"
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
  echo -e "\nRunning SaveWorkspace tests..."
  echo "LoadPackage(\"digraphs\"); DigraphsTestInstall(); Test(\"save-workspace.tst\"); quit; quit; quit;" |
    $GAPSH -A -r -m 768m -o $MEM -T 2>&1 | tee -a $TESTLOG

  echo -e "\nRunning LoadWorkspace tests..."
  echo "Test(\"load-workspace.tst\"); DigraphsTestInstall(); quit; quit; quit;" |
    $GAPSH -L test-output.w -A -x 80 -r -m 768m -o $MEM -T 2>&1 | tee -a $TESTLOG

  echo -e "\nRunning Digraphs package standard tests and manual examples..."
  echo "LoadPackage(\"digraphs\"); DigraphsTestAll();" |
    $GAPSH -A -x 80 -r -m 768m -o $MEM -T 2>&1 | tee -a $TESTLOG

  if [ ! "$EXTREME" == "no" ]; then
    echo -e "\nRunning Digraphs package extreme tests..."
    echo "LoadPackage(\"digraphs\"); DigraphsTestExtreme();" |
      $GAPSH -A -x 80 -r -m 768m -o $MEM -T 2>&1 | tee -a $TESTLOG
  fi
fi

echo -e "\nSuite complete." # AppVeyor needs some extra command here (like this)

( ! grep -E "Diff|brk>|#E|Error|Errors detected|# WARNING|Syntax warning|Couldn't open saved workspace|insufficient|WARNING in|FAILED|Total errors found:" $TESTLOG )
