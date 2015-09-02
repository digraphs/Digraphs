#############################################################################
##
#W  extreme/grahom.tst
#Y  Copyright (C) 2014-15                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: extreme/grahom.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

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
gap> HomomorphismGraphsFinder(gr, gr, fail, [], infinity, fail, false,
> [1, 14, 28, 39, 42], []);;
gap> str := HomomorphismGraphsFinder(gr, gr, fail, [], infinity, fail, false,
> [1, 14, 28, 39, 42], []);;
gap> Length(str);
192

#T# PJC example, 153 vertices
gap> G := PrimitiveGroup(153, 1);;
gap> H := Stabilizer(G, 1);;
gap> S := Filtered(Orbits(H, [1 .. 45]), x -> (Size(x) = 4))[1];;
gap> graph := EdgeOrbitsGraph(G, List(S, x -> [1, x]));;
gap> gr := Digraph(graph);
<digraph with 153 vertices, 612 edges>
gap> t := HomomorphismGraphsFinder(gr, gr, fail, [], 1, 7, false, [], [])[1];
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

# CompleteDigraph (with no loops) has no singular endomorphisms
gap> gr := CompleteDigraph(25);
<digraph with 25 vertices, 600 edges>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);
[ Transformation( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
     18, 19, 20, 21, 22, 23, 25, 24 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
     18, 19, 20, 21, 22, 24, 23 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
     18, 19, 20, 21, 23, 22 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
     18, 19, 20, 22, 21 ] ), Transformation( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
      11, 12, 13, 14, 15, 16, 17, 18, 19, 21, 20 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
     18, 20, 19 ] ), Transformation( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
      13, 14, 15, 16, 17, 19, 18 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 18,
     17 ] ), Transformation( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
      15, 17, 16 ] ), Transformation( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
     13, 14, 16, 15 ] ), Transformation( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
      12, 13, 15, 14 ] ), Transformation( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
     12, 14, 13 ] ), Transformation( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13,
      12 ] ), Transformation( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 11 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 10 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 6, 7, 8, 10, 9 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 6, 7, 9, 8 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 6, 8, 7 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 7, 6 ] ), 
  Transformation( [ 1, 2, 3, 4, 6, 5 ] ), Transformation( [ 1, 2, 3, 5, 4 ] ),
  Transformation( [ 1, 2, 4, 3 ] ), Transformation( [ 1, 3, 2 ] ), 
  Transformation( [ 2, 1 ] ), IdentityTransformation ]
gap> ForAll(gens, x -> AsPermutation(x) in AutomorphismGroup(gr));
true

# CompleteDigraph(n) (with loops added) has T_n automorphism group
gap> gr := Digraph(List([1 .. 5], x -> [1 .. 5]));
<digraph with 5 vertices, 25 edges>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);
Error, Digraphs: GeneratorsOfEndomorphismMonoid: error,
not yet implemented for digraphs with loops,

# EmptyDigraph(n) has T_n automorphism group
gap> gr := EmptyDigraph(5);
<digraph with 5 vertices, 0 edges>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);;
gap> Size(Semigroup(gens)) = 5 ^ 5;
true

# ChainDigraph (with no loops) has all strict order preserving transformations
gap> gr := ChainDigraph(20);
<digraph with 20 vertices, 19 edges>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);
Error, Digraphs: GeneratorsOfEndomorphismMonoid: error,
not yet implemented for non-symmetric digraphs,

# ChainDigraph (with no loops) has all order preserving transformations
gap> gr := ChainDigraph(20);
<digraph with 20 vertices, 19 edges>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);
Error, Digraphs: GeneratorsOfEndomorphismMonoid: error,
not yet implemented for non-symmetric digraphs,

#T# DIGRAPHS_UnbindVariables
gap> Unbind(gr);
gap> Unbind(G);
gap> Unbind(H);
gap> Unbind(gens);
gap> Unbind(S);
gap> Unbind(t);
gap> Unbind(str);
gap> Unbind(graph);

#E#
gap> STOP_TEST("Digraphs package: extreme/grahom.tst");
