# If a command fails, exit this script with an error code
set -e

cd ../..
echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); DigraphsTestExtreme(); quit; quit; quit;" | bin/gap.sh -A -r -m 1g -T 2>&1 | tee testlog.txt
( ! grep -E "########> Diff|brk>|#E|Error|# WARNING|fail|Syntax warning" testlog.txt )
