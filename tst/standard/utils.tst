#############################################################################
##
#W  utils.tst
#Y  Copyright (C) 2016                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: utils.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#T# 1
gap> DIGRAPHS_PF(true);
"\033[1;32mPASSED!\033[0m\n"
gap> DIGRAPHS_PF(false);
"\033[1;31mFAILED!\033[0m\n"

#T# DIGRAPHS_UnbindVariables

#E#
gap> STOP_TEST("Digraphs package: utils.tst");
