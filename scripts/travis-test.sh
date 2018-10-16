# If a command fails, exit this script with an error code
set -e
set -o pipefail

# Remember some important locations
cd $HOME
touch testlog.txt
TESTLOG="`pwd`/testlog.txt"
GAP_DIR="$HOME/gap"
DIG_DIR="$GAP_DIR/pkg/digraphs"
GAP="$GAP_DIR/bin/gap.sh"

if [ "$SUITE" == "lint" ]; then
  
  echo -e "\nLinting with gaplint and cpplint..."
  cd $DIG_DIR
  gaplint `grep "^\s\+gaplint" Makefile.am | cut -d " " -f2-`
  cpplint --extensions=c,cc,h `grep "^\s\+cpplint" Makefile.am | cut -d " " -f2-`

elif [ "$SUITE" == "coverage" ]; then

  echo -e "\nPerforming code coverage tests..."
  cd $DIG_DIR
  for TEST in tst/standard/*.tst; do
    FILENAME=${TEST##*/}
    if [ ! `grep -E "$FILENAME" .covignore` ]; then
      scripts/travis-coverage.py $TEST $THRESHOLD | tee -a $TESTLOG
    else
      echo -e "\033[35mignoring $FILENAME, which is listed in .covignore\033[0m"
    fi
  done
elif [ "$SUITE" == "test" ]; then

  cd $DIG_DIR/tst/workspaces
  echo -e "\nRunning SaveWorkspace tests..."
  echo "LoadPackage(\"digraphs\"); DigraphsTestInstall(); Test(\"save-workspace.tst\"); quit; quit; quit;" |
    $GAP -A -r -m 1g -T 2>&1 | tee -a $TESTLOG
  echo -e "\nRunning LoadWorkspace tests..."
  echo "Test(\"load-workspace.tst\"); DigraphsTestInstall(); quit; quit; quit;" |
    $GAP -L test-output.w -A -x 80 -r -m 1g -T 2>&1 | tee -a $TESTLOG

  echo -e "\nRunning Digraphs package tests and manual examples..."
  echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); DigraphsTestExtreme();" |
    $GAP -A -x 80 -r -m 1g -T 2>&1 | tee -a $TESTLOG

else
  echo -e "\nUnrecognised test suite"
  exit 1
fi

( ! grep -E "Diff|brk>|#E|Error|Errors detected|# WARNING|Syntax warning|Couldn't open saved workspace|insufficient|WARNING in|FAILED|Total errors found:" $TESTLOG )
