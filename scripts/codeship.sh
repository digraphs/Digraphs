echo "Running tests with Semigroups and Grape loaded..."
echo "LoadPackage(\"digraphs\"); LoadPackage(\"semigroups\"); DigraphsTestAll(); quit;" | sh bin/gap.sh | tee testlog.txt
echo "Running tests with Grape loaded..."
echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); quit;" | sh bin/gap.sh | tee -a testlog.txt
rm -r pkg/grape
echo "Running tests with Semigroups loaded..."
echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); quit;" | sh bin/gap.sh | tee -a testlog.txt
echo "Running tests with no optional packages loaded..."
echo "LoadPackage(\"digraphs\"); LoadPackage(\"semigroups\"); DigraphsTestAll(); quit;" | sh bin/gap.sh | tee -a testlog.txt

grep --colour=always -A 1 -E "########> Diff|$" testlog.txt ; ( ! grep -E "########> Diff|# WARNING" testlog.txt )
