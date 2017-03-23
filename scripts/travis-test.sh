# If a command fails, exit this script with an error code
set -e
set -o pipefail

# Start in the GAP directory
cd ../..
GAPDIR=`pwd`

# Create the testlog and remember its location
touch testlog.txt
TESTLOG="$GAPDIR/testlog.txt"

cd pkg/$PACKAGE

# Run gaplint
if [ ! -z "$RUNGAPLINT" ]; then
  echo -e "\nRunning gaplint..."
  export PATH=$PATH:$GAPDIR/pkg/gaplint
  make lint
else
  echo -e "\nNot running gaplint..."
fi

# Run the SaveWorkspace tests
cd tst/workspaces
echo -e "\nRunning SaveWorkspace tests..."
echo "LoadPackage(\"$PACKAGE\", false); DigraphsTestInstall(); Test(\"save-workspace.tst\"); quit; quit; quit;" | $GAPDIR/bin/gap.sh -A -r -m 1g -T 2>&1 | tee -a $TESTLOG
echo "Test(\"load-workspace.tst\"); DigraphsTestInstall(); quit; quit; quit;" | $GAPDIR/bin/gap.sh -L test-output.w -A -r -m 1g -T 2>&1 | tee -a $TESTLOG
rm test-output.w
cd ../..

# Run all tests and manual examples
echo -e "\nRunning tests and manual examples..."
echo "LoadPackage(\"$PACKAGE\"); DigraphsTestAll(); DigraphsTestExtreme(); quit; quit; quit;" | $GAPDIR/bin/gap.sh -A -r -m 1g -T 2>&1 | tee $TESTLOG

# Run coverage checks
if [ ! -z "$RUNCOVERAGE" ]; then
  echo -e "\nPerforming code coverage tests..."
  for TESTFILE in tst/standard/*.tst; do
    FILENAME=${TESTFILE##*/}
    if [ ! `grep -E "$FILENAME" .covignore` ]; then
      ../digraphs/scripts/travis-coverage.py $TESTFILE $THRESHOLD | tee -a $TESTLOG
    else
      echo -e "\033[35mignoring $FILENAME, since it is listed in .covignore\033[0m"
    fi
  done
else
  echo -e "\nNot performing code coverage tests..."
fi

# Check the logs for invalid phrases
( ! grep -E "Diff|brk>|#E|Error|error|# WARNING|fail|Syntax warning|Couldn't open saved workspace|insufficient|WARNING in|FAILED|Total errors found:" $TESTLOG )
