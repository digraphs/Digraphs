#!/bin/sh
#
# Regenerate configure from configure.ac. Requires GNU autoconf.
set -ex
mkdir -p gen
aclocal -Wall --force
autoconf -Wall -f
autoheader -Wall -f
