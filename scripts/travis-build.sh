# If a command fails, exit this script with an error code
set -e

# Display version of compiler
$CXX --version

INITIALDIR=`pwd`

# Download and compile GAP
cd ..
git clone -b $GAP_BRANCH --depth=1 https://github.com/$GAP_FORK/gap.git gap
cd gap
if [ -f autogen.sh ]; then
  ./autogen.sh
fi
./configure --with-gmp=system $GAP_FLAGS
make
mkdir pkg
cd ..

# Move the package itself to the correct location
mv $INITIALDIR gap/pkg/$PACKAGE
cd gap/pkg/$PACKAGE

if [ "$PACKAGE" == "semigroups" ] && [ -d src ]; then
  cd src
  git clone -b $LIBSEMIGROUPS_BR --depth=1 https://github.com/james-d-mitchell/libsemigroups.git libsemigroups
  cd ..
  ./autogen.sh
  ./configure $PKG_FLAGS
  make
fi

if [ "$PACKAGE" == "digraphs" ]; then
  curl -L -O https://gap-packages.github.io/Digraphs/$DIGRAPHS_LIB.tar.gz
  tar xf $DIGRAPHS_LIB.tar.gz
  rm $DIGRAPHS_LIB.tar.gz
fi

cd ..

# Download and install dependencies and tools...

# Compile Digraphs
if [ "$PACKAGE" == "semigroups" ]; then
  git clone -b $DIGRAPHS_BR --depth=1 https://github.com/gap-packages/Digraphs.git digraphs
fi
cd digraphs
./autogen.sh
./configure $PKG_FLAGS
make
cd ..

# GAPDoc
echo "Downloading $GAPDOC..."
curl -O https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$GAPDOC.tar.gz
tar xzf $GAPDOC.tar.gz
rm $GAPDOC.tar.gz

# GenSS
echo "Downloading $GENSS..."
curl -O https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$GENSS.tar.gz
tar xzf $GENSS.tar.gz
rm $GENSS.tar.gz

# IO
echo "Downloading $IO..."
curl -O https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$IO.tar.gz
tar xzf $IO.tar.gz
rm $IO.tar.gz
cd $IO
./configure $PKG_FLAGS
make
cd ..

# Orb
echo "Downloading $ORB..."
curl -O https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$ORB.tar.gz
tar xzf $ORB.tar.gz
rm $ORB.tar.gz
cd $ORB
./configure $PKG_FLAGS
make
cd ..

# Grape: only install if we're testing the digraphs package
if [ "$PACKAGE" == "digraphs" ]; then
  echo "Downloading $GRAPE..."
  curl -O https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$GRAPE.tar.gz
  tar xzf $GRAPE.tar.gz
  rm $GRAPE.tar.gz
  cd grape
  ./configure $PKG_FLAGS
  make
  cd ..
fi

# Only install profiling package if we'll run coverage checks
if [ ! -z "$RUNCOVERAGE" ]; then
  echo "Downloading $PROFILING..."
  curl -LO https://github.com/gap-packages/profiling/releases/download/v$PROFILING/profiling-$PROFILING.tar.gz
  tar xzf profiling-$PROFILING.tar.gz
  rm profiling-$PROFILING.tar.gz
  mv profiling-$PROFILING profiling
  cd profiling
  ./autogen.sh
  ./configure $PKG_FLAGS
  make
  cd ..
fi

# Only install gaplint if we'll run the linting checks
if [ ! -z "$RUNGAPLINT" ]; then
  echo "Downloading gaplint..."
  git clone -b master --depth=1 https://github.com/james-d-mitchell/gaplint gaplint
  cd ..
fi
