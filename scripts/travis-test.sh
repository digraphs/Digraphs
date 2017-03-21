# If a command fails, exit this script with an error code
set -e
set -o pipefail

cd ../..
echo -e "\nRunning tests and manual examples..."
echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); DigraphsTestExtreme(); quit; quit; quit;" | bin/gap.sh -A -r -m 1g -T 2>&1 | tee testlog.txt

# Run gaplint
cd pkg/digraphs
echo -e "\nRunning gaplint..."
../../../gaplint/gaplint.py gap/*.gi | tee -a ../../testlog.txt

# Run coverage checks
if [ ! -z "$COVERAGE" ]; then
  echo -e "\nPerforming code coverage tests..."
  for testfile in tst/standard/*.tst; do
    filename=${testfile##*/}
    if [ ! `grep -E "$filename" .covignore` ]; then
      scripts/travis-coverage.py $testfile 98 | tee -a ../../testlog.txt
    else
      echo -e "\033[35mignoring $filename, since it is listed in .covignore\033[0m"
    fi
  done
else
  echo -e "\nNot performing code coverage tests..."
fi

# Check the logs for invalid phrases
( ! grep -E "########> Diff|brk>|#E|Error|error|fail|Syntax warning|insufficient|# WARNING|FAILED" ../../testlog.txt )
