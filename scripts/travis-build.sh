# If a command fails, exit this script with an error code
set -e

# Display version of compiler
$CXX --version

# Store this directory
DIGRAPHSDIR=$(pwd)

# Download and compile GAP
cd ..
git clone -b $GAP_BRANCH --depth=1 https://github.com/$GAP_FORK/gap.git
cd gap
./configure --with-gmp=system $GAP_FLAGS
make
mkdir pkg
cd ..

# Compile the Digraphs package
mv $DIGRAPHSDIR gap/pkg/digraphs
cd gap/pkg/digraphs
curl -L -O https://gap-packages.github.io/Digraphs/$DIGRAPHS_LIB.tar.gz
tar xf $DIGRAPHS_LIB.tar.gz
rm $DIGRAPHS_LIB.tar.gz
./autogen.sh
./configure $PKG_FLAGS
make
cd ../..

# Get the packages
cd pkg
curl -O https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$GAPDOC.tar.gz
tar xzf $GAPDOC.tar.gz
rm $GAPDOC.tar.gz
curl -O https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$IO.tar.gz
tar xzf $IO.tar.gz
rm $IO.tar.gz
cd $IO
./configure $PKG_FLAGS
make
cd ..
curl -O https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$ORB.tar.gz
tar xzf $ORB.tar.gz
rm $ORB.tar.gz
cd $ORB
./configure $PKG_FLAGS
make
cd ..
# Only install profiling package if we'll run coverage checks
if [ ! -z "$COVERAGE" ]; then
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
curl -O https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$GENSS.tar.gz
tar xzf $GENSS.tar.gz
rm $GENSS.tar.gz
curl -O https://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$GRAPE.tar.gz
tar xzf $GRAPE.tar.gz
rm $GRAPE.tar.gz
cd grape
./configure $PKG_FLAGS
make
cd ../../..

# Get gaplint
echo "Downloading gaplint..."
git clone -b master --depth=1 https://github.com/james-d-mitchell/gaplint
