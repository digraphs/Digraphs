#############################################################################
##
#W  standard/orbits.tst
#Y  Copyright (C) 2014-15
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/orbits.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

# Test DigraphStabilizer error
gap> gr := NullDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> DigraphStabilizer(gr, 1);
Error, Digraphs: DigraphStabilizer: usage,
the second argument must not exceed 0,

#E#
gap> STOP_TEST("Digraphs package: standard/orbits.tst");
