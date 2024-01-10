#!/bin/bash
set -e

gaplint --disable W004 $@ *.g gap/* doc/*.xml tst/testinstall.tst tst/standard/*.tst tst/extreme/*.tst tst/workspaces/*.tst
