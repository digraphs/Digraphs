# If a command fails, exit this script with an error code
set -e
set -o pipefail

# Create the testlog and remember its location
cd $HOME
touch testlog.txt
TESTLOG="`pwd`/testlog.txt"

if [ "$SUITE" == "lint" ]; then
  
  cd $HOME/gap/pkg/digraphs

  for FILE in `grep "^\s\+gaplint" Makefile.am | cut -d " " -f2-`; do
    gaplint $FILE
  done
  for FILE in `grep "^\s\+cpplint" Makefile.am | cut -d " " -f2-`; do
    cpplint --extensions=c,cc,h $FILE
  done

elif [ ! -z "$GAP" ]; then

  cd $HOME/gap
  GAP_DIR=`pwd`
  cd $GAP_DIR/pkg/digraphs
  if [ "$SUITE" == "coverage" ]; then

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
    # Run the SaveWorkspace tests
    cd tst/workspaces
    echo -e "\nRunning SaveWorkspace tests..."
    echo "LoadPackage(\"digraphs\", false); DigraphsTestInstall(); Test(\"save-workspace.tst\"); quit; quit; quit;" | $GAP_DIR/bin/gap.sh -A -r -m 1g -T 2>&1 | tee -a $TESTLOG
    echo "Test(\"load-workspace.tst\"); DigraphsTestInstall(); quit; quit; quit;" | $GAP_DIR/bin/gap.sh -L test-output.w -A -r -m 1g -T 2>&1 | tee -a $TESTLOG
    rm test-output.w
    cd ../..
    # Run all tests and manual examples
    echo -e "\nRunning tests and manual examples..."
    echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); DigraphsTestExtreme(); quit; quit; quit;" | $GAP_DIR/bin/gap.sh -A -r -m 1g -T 2>&1 | tee $TESTLOG
  fi
fi

( ! grep -E "Diff|brk>|#E|Error|error|# WARNING|fail|Syntax warning|Couldn't open saved workspace|insufficient|WARNING in|FAILED|Total errors found:" $TESTLOG )
