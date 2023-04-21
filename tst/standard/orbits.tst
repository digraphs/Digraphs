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

#  DigraphStabilizer, error
gap> gr := NullDigraph(0);
<immutable empty digraph with 0 vertices>
gap> DigraphStabilizer(gr, 1);
Error, the 2nd argument <v> must not exceed 
0, the number of vertices of the digraph in the 1st argument <D>,

#  DigraphStabilizer,
gap> gr := CompleteDigraph(3);
<immutable complete digraph with 3 vertices>
gap> DigraphStabilizer(gr, 1);
Group([ (2,3) ])
gap> DigraphStabilizer(gr, 2);
Group([ (1,3) ])
gap> DigraphStabilizer(gr, 3);
Group([ (1,2) ])

#  DigraphGroup
gap> gr := Digraph([[2, 3], [1], [2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> DigraphGroup(gr);
Group(())
gap> gr := Digraph([[3], [3], [1, 2, 3]]);
<immutable digraph with 3 vertices, 5 edges>
gap> Size(AutomorphismGroup(gr));
2
gap> gr := Digraph([[3, 2], [1], [1]]);
<immutable digraph with 3 vertices, 4 edges>
gap> DigraphGroup(gr);
Group([ (2,3) ])

#  DigraphOrbits
gap> gr := CycleDigraph(10);
<immutable cycle digraph with 10 vertices>
gap> DigraphOrbits(gr);
[ [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] ]

#  RepresentativeOutNeighbours
gap> gr := ChainDigraph(3);
<immutable chain digraph with 3 vertices>
gap> RepresentativeOutNeighbours(gr);
[ [ 2 ], [ 3 ], [  ] ]
gap> gr := CycleDigraph(12);
<immutable cycle digraph with 12 vertices>
gap> RepresentativeOutNeighbours(gr);
[ [ 2 ] ]

#  DIGRAPHS_UnbindVariables
gap> Unbind(gr);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/orbits.tst", 0);
