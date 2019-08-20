#!/usr/bin/env bash

# If a command fails, exit this script with an error code
set -e
set -o pipefail

GAPROOT=$HOME/gap
touch $GAPROOT/testlog.txt
TESTLOG="$GAPROOT/testlog.txt"
GAPSH="$GAPROOT/bin/gap.sh"
DIG_DIR="$GAPROOT/pkg/digraphs"

if [ "$SUITE" == "lint" ]; then
  
  echo -e "\nLinting with gaplint and cpplint..."
  cd $DIG_DIR
  gaplint `grep "^\s\+gaplint" Makefile.am | cut -d " " -f2-`
  cpplint --extensions=c,cc,h `grep "^\s\+cpplint" Makefile.am | cut -d " " -f2-`

elif [ "$SUITE" == "coverage" ]; then

  echo -e "\nPerforming code coverage tests..."
  for TEST in $DIG_DIR/tst/standard/*.tst; do
    FILENAME=${TEST##*/}
    if [ ! `grep -E "$FILENAME" $DIG_DIR/.covignore` ]; then
      $DIG_DIR/scripts/travis-coverage.py $TEST $THRESHOLD | tee -a $TESTLOG
    else
      echo -e "\033[35mignoring $FILENAME, which is listed in .covignore\033[0m"
    fi
  done

elif [ "$SUITE" == "test" ]; then

  # Temporary workaround because of GAP being weird with memory
  if [ "$ABI" == "32" ]; then
    MEM=1g
  elif [ "$ABI" == "64" ]; then
    MEM=2g
  fi

  cd $DIG_DIR/tst/workspaces
  echo -e "\nRunning SaveWorkspace tests..."
  echo "LoadPackage(\"digraphs\"); DigraphsTestInstall(); Test(\"save-workspace.tst\"); quit; quit; quit;" |
    $GAPSH -A -r -m 768m -o $MEM -T 2>&1 | tee -a $TESTLOG

  echo -e "\nRunning LoadWorkspace tests..."
  echo "Test(\"load-workspace.tst\"); DigraphsTestInstall(); quit; quit; quit;" |
    $GAPSH -L test-output.w -A -x 80 -r -m 768m -o $MEM -T 2>&1 | tee -a $TESTLOG

  echo -e "\nRunning Digraphs package tests and manual examples..."
  echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); DigraphsTestExtreme();" |
    $GAPSH -A -x 80 -r -m 768m -o $MEM -T 2>&1 | tee -a $TESTLOG
fi

echo -e "\nSuite complete." # AppVeyor needs some extra command here (like this)

( ! grep -E "Diff|brk>|#E|Error|Errors detected|# WARNING|Syntax warning|Couldn't open saved workspace|insufficient|WARNING in|FAILED|Total errors found:" $TESTLOG )
