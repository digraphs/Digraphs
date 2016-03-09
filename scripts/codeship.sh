echo "=========================================================="
echo "GAP DEV: Running tests with Semigroups and Grape loaded..."
echo "=========================================================="
echo "(including DigraphsTestExtreme)"
echo "-------------------------------"
echo "LoadPackage(\"digraphs\"); LoadPackage(\"semigroups\"); DigraphsTestAll(); DigraphsTestExtreme(); quit;" | sh gap/bin/gap.sh | tee testlog.txt

echo "=========================================================================="
echo "GAP DEV: Running tests with Semigroups and Grape loaded BEFORE Digraphs..."
echo "=========================================================================="
echo "LoadPackage(\"semigroups\"); LoadPackage(\"grape\"); LoadPackage(\"digraphs\"); DigraphsTestAll(); quit;" | sh gap/bin/gap.sh | tee -a testlog.txt

echo "================================================================"
echo "GAP DEV: Running tests with Grape loaded (but NOT Semigroups)..."
echo "================================================================"
echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); quit;" | sh gap/bin/gap.sh | tee -a testlog.txt

rm -r gap/pkg/grape

echo "================================================================"
echo "GAP DEV: Running tests with Semigroups loaded (but NOT Grape)..."
echo "================================================================"
echo "LoadPackage(\"digraphs\"); LoadPackage(\"semigroups\"); DigraphsTestAll(); quit;" | sh gap/bin/gap.sh | tee -a testlog.txt

echo "============================================================"
echo "GAP DEV: Running tests WITHOUT Semigroups or Grape loaded..."
echo "============================================================"
echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); quit;" | sh gap/bin/gap.sh | tee -a testlog.txt





echo "=========================================================="
echo "GAP 4.8: Running tests with Semigroups and Grape loaded..."
echo "=========================================================="
echo "(including DigraphsTestExtreme)"
echo "-------------------------------"
echo "LoadPackage(\"digraphs\"); LoadPackage(\"semigroups\"); DigraphsTestAll(); DigraphsTestExtreme(); quit;" | sh gap4r8/bin/gap.sh | tee -a testlog.txt

echo "=========================================================================="
echo "GAP 4.8: Running tests with Semigroups and Grape loaded BEFORE Digraphs..."
echo "=========================================================================="
echo "LoadPackage(\"semigroups\"); LoadPackage(\"grape\"); LoadPackage(\"digraphs\"); DigraphsTestAll(); quit;" | sh gap4r8/bin/gap.sh | tee -a testlog.txt

echo "================================================================"
echo "GAP 4.8: Running tests with Grape loaded (but NOT Semigroups)..."
echo "================================================================"
echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); quit;" | sh gap4r8/bin/gap.sh | tee -a testlog.txt

rm -r gap4r8/pkg/grape

echo "================================================================"
echo "GAP 4.8: Running tests with Semigroups loaded (but NOT Grape)..."
echo "================================================================"
echo "LoadPackage(\"digraphs\"); LoadPackage(\"semigroups\"); DigraphsTestAll(); quit;" | sh gap4r8/bin/gap.sh | tee -a testlog.txt

echo "============================================================"
echo "GAP 4.8: Running tests WITHOUT Semigroups or Grape loaded..."
echo "============================================================"
echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); quit;" | sh gap4r8/bin/gap.sh | tee -a testlog.txt


###############################################################################
# 32-BIT TESTS: Uncomment these and uncomment the appropriate lines on Codeship
###############################################################################

#echo "=========================================================="
#echo "GAP 32b: Running tests with Semigroups and Grape loaded..."
#echo "=========================================================="
#echo "(including DigraphsTestExtreme)"
#echo "-------------------------------"
#echo "LoadPackage(\"digraphs\"); LoadPackage(\"semigroups\"); DigraphsTestAll(); DigraphsTestExtreme(); quit;" | sh gap32/bin/gap.sh | tee -a testlog.txt

#echo "=========================================================================="
#echo "GAP 32b: Running tests with Semigroups and Grape loaded BEFORE Digraphs..."
#echo "=========================================================================="
#echo "LoadPackage(\"semigroups\"); LoadPackage(\"grape\"); LoadPackage(\"digraphs\"); DigraphsTestAll(); quit;" | sh gap32/bin/gap.sh | tee -a testlog.txt

#echo "================================================================"
#echo "GAP 32b: Running tests with Grape loaded (but NOT Semigroups)..."
#echo "================================================================"
#echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); quit;" | sh gap32/bin/gap.sh | tee -a testlog.txt

#rm -r gap32/pkg/grape

#echo "================================================================"
#echo "GAP 32b: Running tests with Semigroups loaded (but NOT Grape)..."
#echo "================================================================"
#echo "LoadPackage(\"digraphs\"); LoadPackage(\"semigroups\"); DigraphsTestAll(); quit;" | sh gap32/bin/gap.sh | tee -a testlog.txt

#echo "============================================================"
#echo "GAP 32b: Running tests WITHOUT Semigroups or Grape loaded..."
#echo "============================================================"
#echo "LoadPackage(\"digraphs\"); DigraphsTestAll(); quit;" | sh gap32/bin/gap.sh | tee -a testlog.txt

( ! grep -E "########> Diff|brk>|#E|Error|Syntax warning" testlog.txt )
