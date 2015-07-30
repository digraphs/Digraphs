#%T##########################################################################
##
#W  homos.tst
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: homos.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DigraphsStartTest();

#T# PJC example, 45 vertices
gap> gr := DigraphFromDigraph6String(Concatenation(
> "+l??O?C?A_@???CE????GAAG?C??M?????@_?OO??G??@?IC???_C?G?o??C?AO???c_??A?A",
> "?S???OAA???OG???G_A??C?@?cC????_@G???S??C_?C???[??A?A?OA?O?@?A?@A???GGO??",
> "`?_O??G?@?A??G?@AH????AA?O@??_??b???Cg??C???_??W?G????d?G?C@A?C???GC?W???",
> "??K???__O[??????O?W???O@??_G?@?CG??G?@G?C??@G???_Q?O?O?c???OAO?C??C?G?O??",
> "A@??D??G?C_?A??O?_GA??@@?_?G???E?IW??????_@G?C??"));
<digraph with 45 vertices, 180 edges>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);;
gap> Length(gens);
330
gap> Size(Semigroup(gens));
105120
gap> HomomorphismGraphsFinder(gr, gr, fail, fail, fail, fail, false,
> [1, 14, 28, 39, 42], fail);;
gap> str := HomomorphismGraphsFinder(gr, gr, fail, fail, fail, fail, false,
> [1, 14, 28, 39, 42], fail);;
gap> Length(str);
192

#T# PJC example, 153 vertices
gap> G := PrimitiveGroup(153, 1);;
gap> H := Stabilizer(G, 1);;
gap> S := Filtered(Orbits(H, [1 .. 45]), x -> (Size(x) = 4))[1];;
gap> graph := EdgeOrbitsGraph(G, List(S, x -> [1, x]));;
gap> gr := Digraph(graph);
<digraph with 153 vertices, 612 edges>
gap> t := HomomorphismGraphsFinder(gr, gr, fail, fail, 1, 7, false, fail,
>                                  fail)[1];
<transformation on 153 pts with rank 7>
gap> 1 ^ t;
1
gap> 2 ^ t;
73
gap> 3 ^ t;
97
gap> 4 ^ t;
97
gap> 5 ^ t;
97

#T# GeneratorsOfEndomorphismMonoid
gap> gr := Digraph([[2], [1, 3], [2]]);
<digraph with 3 vertices, 4 edges>
gap> GeneratorsOfEndomorphismMonoid(gr);
[ Transformation( [ 3, 2, 1 ] ), IdentityTransformation, 
  Transformation( [ 1, 2, 1 ] ), Transformation( [ 2, 1, 2 ] ) ]
gap> gr := Digraph([[2], [1, 3], [2]]);
<digraph with 3 vertices, 4 edges>
gap> GeneratorsOfEndomorphismMonoid(gr);
[ Transformation( [ 3, 2, 1 ] ), IdentityTransformation, 
  Transformation( [ 1, 2, 1 ] ), Transformation( [ 2, 1, 2 ] ) ]

#E#
gap> STOP_TEST("Digraphs package: homos.tst");
