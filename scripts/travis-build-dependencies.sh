#!/usr/bin/env bash

# If a command fails, exit this script with an error code
set -e

if [ "$SUITE" != "test" ] && [ "$SUITE" != "coverage" ] && [ "$SUITE" != "lint" ]; then
  echo -e "\nError, unrecognised Travis suite: $SUITE"
  exit 1
fi

if [ "$SETUP" == "travis" ]; then
  mv ../Digraphs $HOME/digraphs
fi

################################################################################
# Install software necessary for linting: cpplint and gaplint
################################################################################

if [ "$SUITE" == "lint" ]; then

  # Install cpplint and gaplint
  sudo pip install cpplint
  sudo pip install gaplint

  # Move Digraphs package into a GAP folder structure, so that cpplint is happy
  mkdir $HOME/gap $HOME/gap/.git $HOME/gap/pkg
  mv $HOME/digraphs $HOME/gap/pkg/digraphs

  exit 0
fi

################################################################################
# Install software necessary for tests and coverage: GAP and packages
################################################################################ 

################################################################################
# Install GAP
echo -e "\nInstalling GAP..."
if [ "$GAP" == "required" ]; then
  GAP=v`grep "GAPVERS" $HOME/digraphs/PackageInfo.g | awk -F'"' '{print $2}'`
fi
GAPROOT="$HOME/gap"
echo -e "\nInstalling GAP $GAP into $GAPROOT..."
git clone -b $GAP --depth=1 https://github.com/gap-system/gap.git $GAPROOT
cd $GAPROOT
./autogen.sh
./configure --with-gmp=system $GAP_FLAGS
make -j4
mkdir pkg

################################################################################
# Copy Digraphs to its proper location
if [ "$SETUP" == "appveyor" ]; then
  cp -r /cygdrive/c/projects/digraphs* $GAPROOT/pkg/digraphs
elif [ "$SETUP" == "travis" ]; then
  mv $HOME/digraphs $GAPROOT/pkg/digraphs
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
  cd $GAPROOT/pkg

  # Get the relevant version number
  if [ "${PACKAGES[0]}" == "latest" ] || [ "$PKG" == "profiling" ]; then
    VERSION=`$CURL -s "https://github.com/gap-packages/$PKG/releases/latest" | grep \<title\>Release | awk -F' ' '{print $2}'`
  else
    VERSION=`grep "\"$PKG\"" $GAPROOT/pkg/digraphs/PackageInfo.g | awk -F'"' '{print $4}' | cut -c3-`
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
# Install required GAP packages
cd $GAPROOT/pkg
echo -e "\nGetting the required GAP packages (smallgrp, transgrp, primgrp)..."
$CURL -O "https://www.gap-system.org/pub/gap/gap4pkgs/packages-required-master.tar.gz"
tar xf packages-required-master.tar.gz
rm packages-required-master.tar.gz

################################################################################
## Install NautyTracesInterface in Travis
if [ "$SETUP" == "travis" ] && [ "$NAUTY" != "no" ]; then
  echo -e "\nGetting master version of NautyTracesInterface"
  git clone -b master --depth=1 https://github.com/gap-packages/NautyTracesInterface.git $GAPROOT/pkg/nautytraces
  cd $GAPROOT/pkg/nautytraces/nauty2*r* && ./configure $PKG_FLAGS && make
  cd $GAPROOT/pkg/nautytraces && ./autogen.sh && ./configure $PKG_FLAGS && make
fi
