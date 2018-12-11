#!/bin/sh

aclocal &&
autoconf &&
libtoolize --copy &&
automake --add-missing --copy &&
rm -rf autom4te.cache
