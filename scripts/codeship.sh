echo "=========================================================="
echo "GAP DEV: Running tests with Semigroups and Grape loaded..."
echo "=========================================================="
echo "LoadPackage(\"digraphs\"); LoadPackage(\"semigroups\"); DigraphsTestAll(); quit;" | sh gap/bin/gap.sh | tee testlog.txt
echo "==========================================="
echo "GAP DEV: Running tests with Grape loaded..."
echo "==========================================="
echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); quit;" | sh gap/bin/gap.sh | tee -a testlog.txt
rm -r pkg/grape
echo "================================================"
echo "GAP DEV: Running tests with Semigroups loaded..."
echo "================================================"
echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); quit;" | sh gap/bin/gap.sh | tee -a testlog.txt
echo "=========================================================="
echo "GAP DEV: Running tests with no optional packages loaded..."
echo "=========================================================="
echo "LoadPackage(\"digraphs\"); LoadPackage(\"semigroups\"); DigraphsTestAll(); quit;" | sh gap/bin/gap.sh | tee -a testlog.txt

echo "=========================================================="
echo "GAP 4.8: Running tests with Semigroups and Grape loaded..."
echo "=========================================================="
echo "LoadPackage(\"digraphs\"); LoadPackage(\"semigroups\"); DigraphsTestAll(); quit;" | sh gap4r8/bin/gap.sh | tee -a testlog.txt
echo "==========================================="
echo "GAP 4.8: Running tests with Grape loaded..."
echo "==========================================="
echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); quit;" | sh gap4r8/bin/gap.sh | tee -a testlog.txt
rm -r pkg/grape
echo "================================================"
echo "GAP 4.8: Running tests with Semigroups loaded..."
echo "================================================"
echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); quit;" | sh gap4r8/bin/gap.sh | tee -a testlog.txt
echo "=========================================================="
echo "GAP 4.8: Running tests with no optional packages loaded..."
echo "=========================================================="
echo "LoadPackage(\"digraphs\"); LoadPackage(\"semigroups\"); DigraphsTestAll(); quit;" | sh gap4r8/bin/gap.sh | tee -a testlog.txt

grep --colour=always -A 1 -E "########> Diff|$" testlog.txt ; ( ! grep -E "########> Diff" testlog.txt )
