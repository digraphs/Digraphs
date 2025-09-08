#############################################################################
##
#W  teststandard.g
#Y  Copyright (C) 2021                                      Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
LoadPackage("digraphs", false);;
if SizeBlist([DigraphsTestInstall(),
              DigraphsTestStandard(rec(earlyStop := false)),
              DIGRAPHS_RunTest(DigraphsTestManualExamples)]) = 3 then
  QUIT_GAP(0);
else
  QUIT_GAP(1);
fi;
FORCE_QUIT_GAP(1); # if we ever get here, there was an error
