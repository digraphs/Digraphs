# If a command fails, exit this script with an error code
set -e

cd ..
mv Digraphs $HOME/digraphs

################################################################################
# Install software necessary for linting: cpplint and gaplint
################################################################################

if [ "$SUITE" == "lint" ]; then

  # Install cpplint using pip
  cd $HOME
  sudo pip install cpplint

  # Install gaplint using pip
  sudo pip install gaplint

  # Move Digraphs package into a GAP folder structure, so that cpplint is happy
  mkdir gap gap/.git gap/pkg
  mv digraphs $HOME/gap/pkg/digraphs

  exit 0
fi

################################################################################
# Install software necessary for tests and coverage: GAP and packages
################################################################################ 

if [ "$SUITE" != "test" ] && [ "$SUITE" != "coverage" ]; then
  echo -e "\nError, unrecognised Travis suite: $SUITE"
  exit 1
fi

################################################################################
# Install GAP
echo -e "\nInstalling GAP..."
if [ "$GAP" == "required" ]; then
  cd $HOME/digraphs
  GAP=v`grep "GAPVERS" PackageInfo.g | awk -F'"' '{print $2}'`
fi
git clone -b $GAP --depth=1 https://github.com/gap-system/gap.git $GAPROOT
cd $GAPROOT
if [ -f autogen.sh ]; then
  ./autogen.sh
fi
./configure --with-gmp=system $GAP_FLAGS
make -j4
mkdir pkg

################################################################################
# Move Digraphs into its proper location
mv $HOME/digraphs $GAPROOT/pkg/digraphs

################################################################################
# Install io, orb, and profiling
PKGS=( "io" "orb" "profiling" )
for PKG in "${PKGS[@]}"; do
  cd $GAPROOT/pkg
  if [ "$PACKAGES" == "newest" ] || [ "$PKG" == "profiling" ]; then
    echo -e "\nGetting latest release of $PKG..."
    VERSION=`curl -sL "https://github.com/gap-packages/$PKG/releases/latest" | grep \<title\>Release | awk -F' ' '{print $2}'`
  else
    echo -e "\nGetting required release of $PKG..."
    VERSION=`grep "\"$PKG\"" $GAPROOT/pkg/digraphs/PackageInfo.g | awk -F'"' '{print $4}' | cut -c3-`
  fi
  URL="https://github.com/gap-packages/$PKG/releases/download/v$VERSION/$PKG-$VERSION.tar.gz"
  echo -e "Downloading $PKG-$VERSION, from URL:\n$URL"
  curl -LO "$URL"
  tar xf $PKG-$VERSION.tar.gz
  rm $PKG-$VERSION.tar.gz
  cd $PKG-$VERSION
  if [ -f configure ]; then
    ./configure $PKG_FLAGS
    make
  fi
done

################################################################################
# Install NautyTracesInterface
cd $GAPROOT/pkg
echo -e "\nGetting master version of NautyTracesInterface"
git clone -b master --depth=1 https://github.com/sebasguts/NautyTracesInterface.git nautytracesinterface
cd nautytracesinterface
cd nauty26r7
./configure $PKG_FLAGS
make
cd ..
./autogen.sh
./configure  $PKG_FLAGS
make

################################################################################
# Install GRAPE and GAPDoc
PKGS=( $GRAPE )
for PKG in "${PKGS[@]}"; do
  echo -e "\nDownloading $PKG..."
  cd $GAPROOT/pkg
  curl -O "https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$PKG.tar.gz"
  PKG_DIR=`tar -tf $PKG.tar.gz | head -1 | cut -f1 -d"/"`
  tar xf $PKG.tar.gz
  rm $PKG.tar.gz
  cd $PKG_DIR
  if [ -f configure ]; then
    ./configure $PKG_FLAGS
    make
  fi
done

################################################################################
# Install required GAP packages
cd $GAPROOT/pkg
echo -e "\nGetting the required GAP packages (smallgrp, transgrp, primgrp)..."
curl -LO "http://www.gap-system.org/pub/gap/gap4pkgs/packages-required-master.tar.gz"
tar xf packages-required-master.tar.gz
rm packages-required-master.tar.gz
