LoadPackage("digraphs");

DigraphsMakeDoc();
if DigraphsTestInstall()
    and DigraphsTestStandard()
    and DIGRAPHS_RunTest(DigraphsTestManualExamples)
    and DigraphsTestExtreme() then
  FORCE_QUIT_GAP(0);
fi;

FORCE_QUIT_GAP(1);
