#############################################################################
##
#W  extreme/attr.tst
#Y  Copyright (C) 2014-15                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: extreme/attr.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#T# ReducedDigraph, for a digraph with lots of edges
gap> gr := ReadDigraphs(Concatenation(DIGRAPHS_Dir(),
>                                     "/digraphs-lib/extreme.d6.gz"), 1);
<digraph with 5000 vertices, 4211332 edges>
gap> ReducedDigraph(gr);
<digraph with 5000 vertices, 4211332 edges>

#T# DigraphSymmetricClosure, for a digraph with lots of edges
gap> gr := ReadDigraphs(Concatenation(DIGRAPHS_Dir(),
>                                     "/digraphs-lib/extreme.d6.gz"), 1);
<digraph with 5000 vertices, 4211332 edges>
gap> DigraphSymmetricClosure(gr);
<digraph with 5000 vertices, 7713076 edges>

#E#
gap> STOP_TEST("Digraphs package: extreme/attr.tst");
