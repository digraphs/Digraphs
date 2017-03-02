#############################################################################
##
#W  standard/orbits.tst
#Y  Copyright (C) 2014-17                                   Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/orbits.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#T# DigraphStabilizer, error
gap> gr := NullDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> DigraphStabilizer(gr, 1);
Error, Digraphs: DigraphStabilizer: usage,
the second argument must not exceed 0,

#T# DigraphStabilizer,
gap> gr := CompleteDigraph(3);
<digraph with 3 vertices, 6 edges>
gap> DigraphStabilizer(gr, 1);
Group([ (2,3) ])
gap> DigraphStabilizer(gr, 2);
Group([ (1,3) ])
gap> DigraphStabilizer(gr, 3);
Group([ (1,2) ])

#T# DigraphGroup
gap> gr := Digraph([[2, 2], [1]]);
<multidigraph with 2 vertices, 3 edges>
gap> DigraphGroup(gr);
Group(())
gap> gr := Digraph([[2], [3, 2], [1, 3, 2, 3]]);
<multidigraph with 3 vertices, 7 edges>
gap> Size(AutomorphismGroup(gr));
2
gap> gr := Digraph([[3, 2], [1], [1]]);
<digraph with 3 vertices, 4 edges>
gap> DigraphGroup(gr);
Group([ (2,3) ])

#T# DigraphOrbits
gap> gr := CycleDigraph(10);
<digraph with 10 vertices, 10 edges>
gap> DigraphOrbits(gr);
[ [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] ]

#T# RepresentativeOutNeighbours
gap> gr := ChainDigraph(3);
<digraph with 3 vertices, 2 edges>
gap> RepresentativeOutNeighbours(gr);
[ [ 2 ], [ 3 ], [  ] ]
gap> gr := CycleDigraph(12);
<digraph with 12 vertices, 12 edges>
gap> RepresentativeOutNeighbours(gr);
[ [ 2 ] ]

#E#
gap> STOP_TEST("Digraphs package: standard/orbits.tst");
