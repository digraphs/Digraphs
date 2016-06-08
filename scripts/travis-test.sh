# If a command fails, exit this script with an error code
set -e

echo -en 'travis_fold:start:RunTests\r'
cd ../..
echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); DigraphsTestExtreme(); quit; quit; quit;" | bin/gap.sh -A -r -m 1g -T 2>&1 | tee testlog.txt
echo -en 'travis_fold:end:RunTests\r'
( ! grep -E "########> Diff|brk>|#E|Error|# WARNING|fail|Syntax warning" testlog.txt )
