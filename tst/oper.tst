#############################################################################
##
#W  oper.tst
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

gap> START_TEST("Digraphs package: oper.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DigraphsStartTest();

# DirectedGraphReverse
gap> gr:=DirectedGraph(
> [ [ 3 ], [ 1, 3, 5 ], [ 1 ], [ 1, 2, 4 ], [ 2, 3, 5 ] ]);
<directed graph with 5 vertices, 11 edges>
gap> rgr:=DirectedGraphReverse(gr);
<directed graph with 5 vertices, 11 edges>
gap> Adjacencies(rgr);
[ [ 2, 3, 4 ], [ 4, 5 ], [ 1, 2, 5 ], [ 4 ], [ 2, 5 ] ]
gap> gr=DirectedGraphReverse(rgr);
true

#
gap> DigraphsStopTest();

#
gap> STOP_TEST( "Digraphs package: attrs.tst", 0);
