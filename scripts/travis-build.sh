# If a command fails, exit this script with an error code
set -e

# Display version of compiler
$CXX --version

# Store this directory
DIGRAPHSDIR=$(pwd)

# Download and compile GAP
cd ..
echo -en 'travis_fold:start:InstallGAP\r'
git clone -b $GAP_BRANCH --depth=1 https://github.com/$GAP_FORK/gap.git
cd gap
./configure --with-gmp=system $GAP_FLAGS
make
mkdir pkg
cd ..
echo -en 'travis_fold:end:InstallGAP\r'

# Compile the Digraphs package
echo -en 'travis_fold:start:BuildDigraphs\r'
mv $DIGRAPHSDIR gap/pkg/digraphs
cd gap/pkg/digraphs
curl -L -O http://gap-packages.github.io/Digraphs/$DIGRAPHS_LIB.tar.gz
tar xf $DIGRAPHS_LIB.tar.gz
rm $DIGRAPHS_LIB.tar.gz
./autogen.sh
./configure $PKG_FLAGS
make
cd ../..
echo -en 'travis_fold:end:BuildDigraphs\r'

# Get the packages
echo -en 'travis_fold:start:InstallPackages\r'
cd pkg
curl -O http://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$GAPDOC.tar.gz
tar xzf $GAPDOC.tar.gz
rm $GAPDOC.tar.gz
curl -O http://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$IO.tar.gz
tar xzf $IO.tar.gz
rm $IO.tar.gz
cd $IO
./configure $PKG_FLAGS
make
cd ..
curl -O http://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$ORB.tar.gz
tar xzf $ORB.tar.gz
rm $ORB.tar.gz
cd $ORB
./configure $PKG_FLAGS
make
cd ..
curl -O http://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$GENSS.tar.gz
tar xzf $GENSS.tar.gz
rm $GENSS.tar.gz
curl -O http://www.gap-system.org/pub/gap/gap4/tar.gz/packages/$GRAPE.tar.gz
tar xzf $GRAPE.tar.gz
rm $GRAPE.tar.gz
cd grape
./configure $PKG_FLAGS
make
cd ../../..
echo -en 'travis_fold:end:InstallPackages\r'
