#############################################################################
##
#W  standard/exmpl.tst
#Y  Copyright (C) 2019                                   Murray T. Whyte
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/exmpl.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

# PetersenGraph
gap> ChromaticNumber(PetersenGraph());
3
gap> DigraphGirth(PetersenGraph());
2

#E#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/exmpl.tst", 0);
