#!/usr/bin/env bash

# If a command fails, exit this script with an error code
set -e

################################################################################
# Compile Digraphs and install Digraphs lib
if [ "$SUITE" != "lint" ]; then
  echo -e "\nCompiling the Digraphs package..."
  cd $HOME/gap/pkg/digraphs
  ./autogen.sh
  ./configure $PKG_FLAGS $EXTRA_PKG_FLAGS
  make
  echo -e "\nDownloading $DIGRAPHS_LIB..."
  curl --retry 5 -L -O https://gap-packages.github.io/Digraphs/$DIGRAPHS_LIB.tar.gz
  tar xf $DIGRAPHS_LIB.tar.gz
  rm $DIGRAPHS_LIB.tar.gz
fi
