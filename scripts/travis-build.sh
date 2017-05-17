# If a command fails, exit this script with an error code
set -e

# Display version of compiler
$CXX --version

cd ..

# Assume: linting and running GAP are mutually-exclusive test suites

if [ ! -z "$LINT" ]; then

  sudo pip install cpplint
  git clone -b master --depth=1 https://github.com/james-d-mitchell/gaplint gaplint
  mkdir gap gap/.git gap/pkg
  mv Digraphs gap/pkg/digraphs

elif [ ! -z "$GAP_BRANCH" ]; then

  echo -e "\nInstalling GAP..."
  if [ "$GAP_BRANCH" == "required" ]; then
    cd Digraphs
    GAP_BRANCH=v`grep "GAPVERS" PackageInfo.g | awk -F'"' '{print $2}'`
    cd ..
  fi
  git clone -b $GAP_BRANCH --depth=1 https://github.com/gap-system/gap.git gap
  cd gap
  if [ -f autogen.sh ]; then
    ./autogen.sh
  fi
  ./configure --with-gmp=system $GAP_FLAGS
  make -j4
  mkdir pkg
  cd pkg
  PKG_DIR=`pwd`
  mv ../../Digraphs digraphs
  cd digraphs

  echo -e "\nDownloading $DIGRAPHS_LIB..."
  curl -L -O https://gap-packages.github.io/Digraphs/$DIGRAPHS_LIB.tar.gz
  tar xf $DIGRAPHS_LIB.tar.gz
  rm $DIGRAPHS_LIB.tar.gz

  echo -e "\nCompiling the Digraphs package..."
  ./autogen.sh
  ./configure $PKG_FLAGS
  make

  if [ ! -z "$COVERAGE" ]; then
    echo -e "\nDownloading the profiling package..."
    cd $PKG_DIR
    git clone https://github.com/gap-packages/profiling.git profiling
    cd profiling
    PROFILING_VERS=`git tag | grep "v\d\+\(.\d\+\)\+" | tail -n 1`
    echo "Checking out profiling version $PROFILING_VERS..."
    git checkout $PROFILING_VERS
    ./autogen.sh
    ./configure $PKG_FLAGS
    make
    cd ..
  fi

  INSTALL_PKG () {
    echo -e "\nDownloading $1..."
    cd $PKG_DIR
    git clone https://github.com/gap-packages/$1.git $1
    cd $1
    if [ ! -z "$NEWEST" ]; then
      VERSION=`git tag | grep "v\d\+\(.\d\+\)\+" | tail -n 1`
    else
      VERSION=v`grep "\"$1\"" ../digraphs/PackageInfo.g | awk -F'"' '{print $4}' | cut -c3-`
    fi
    echo "Checking out $1 $VERSION..."
    git checkout $VERSION
    ./autogen.sh
    ./configure $PKG_FLAGS
    make
    cd ..
  }

  INSTALL_PKG "io"
  INSTALL_PKG "orb"

  echo "Downloading $GRAPE..."
  curl -O https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$GRAPE.tar.gz
  tar xzf $GRAPE.tar.gz
  rm $GRAPE.tar.gz
  cd grape
  ./configure $PKG_FLAGS
  make
  cd ..

  echo -e "\nDownloading $GAPDOC..."
  cd $PKG_DIR
  curl -O https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$GAPDOC.tar.gz
  tar xzf $GAPDOC.tar.gz
  rm $GAPDOC.tar.gz
fi
