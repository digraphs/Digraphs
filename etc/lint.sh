#!/bin/bash
set -e

gaplint --disable W004 *.g gap/*
gaplint --disable W004 doc/*.xml
gaplint --disable W004 tst/testinstall.tst tst/standard/*.tst tst/extreme/*.tst tst/workspaces/*.tst
cpplint src/*.[ch]
