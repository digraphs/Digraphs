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
# These "{No} errors detected" lines currently have to be printed in this way
# to satisfy the automated GAP testing system that runs on Jenkins.
# This requirement will hopefully go soon.
if DigraphsTestInstall()
    and DigraphsTestStandard()
    and DIGRAPHS_RunTest(DigraphsTestManualExamples) then
  Print("#I  No errors detected while testing\n\n");
  QUIT_GAP(0);
else
  Print("#I  Errors detected while testing\n\n");
  QUIT_GAP(1);
fi;
FORCE_QUIT_GAP(1); # if we ever get here, there was an error
