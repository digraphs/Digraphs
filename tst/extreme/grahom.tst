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

#T# GeneratorsOfEndomorphismMonoid 1
# PJC example, 45 vertices
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

#T# GeneratorsOfEndomorphismMonoid 2
# PJC example, 153 vertices
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

#T# GeneratorsOfEndomorphismMonoid 3
# Small example
gap> gr := Digraph([[2], [1, 3], [2]]);
<digraph with 3 vertices, 4 edges>
gap> GeneratorsOfEndomorphismMonoid(gr);
[ Transformation( [ 3, 2, 1 ] ), IdentityTransformation, 
  Transformation( [ 1, 2, 1 ] ), Transformation( [ 2, 1, 2 ] ) ]
gap> gr := DigraphCopy(gr);
<digraph with 3 vertices, 4 edges>
gap> GeneratorsOfEndomorphismMonoid(gr);
[ Transformation( [ 3, 2, 1 ] ), IdentityTransformation, 
  Transformation( [ 1, 2, 1 ] ), Transformation( [ 2, 1, 2 ] ) ]
gap> gr := DigraphCopy(gr);;
gap> GeneratorsOfEndomorphismMonoid(gr, infinity);
[ Transformation( [ 3, 2, 1 ] ), IdentityTransformation, 
  Transformation( [ 1, 2, 1 ] ), Transformation( [ 2, 1, 2 ] ) ]
gap> gr := DigraphCopy(gr);;
gap> GeneratorsOfEndomorphismMonoid(gr, 1);
[ Transformation( [ 3, 2, 1 ] ) ]
gap> gr := DigraphCopy(gr);;
gap> GeneratorsOfEndomorphismMonoid(gr, 2);
[ Transformation( [ 3, 2, 1 ] ), IdentityTransformation ]
gap> HasGeneratorsOfEndomorphismMonoidAttr(gr);
false
gap> GeneratorsOfEndomorphismMonoid(gr, 3);
[ Transformation( [ 3, 2, 1 ] ), IdentityTransformation, 
  Transformation( [ 1, 2, 1 ] ) ]
gap> HasGeneratorsOfEndomorphismMonoidAttr(gr);
false
gap> GeneratorsOfEndomorphismMonoid(gr, 4);
[ Transformation( [ 3, 2, 1 ] ), IdentityTransformation, 
  Transformation( [ 1, 2, 1 ] ), Transformation( [ 2, 1, 2 ] ) ]
gap> HasGeneratorsOfEndomorphismMonoidAttr(gr);
false

#T# GeneratorsOfEndomorphismMonoid 4
# Complete digraph

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
gap> GeneratorsOfEndomorphismMonoid(gr) = gens;
true

# CompleteDigraph(n) (with loops added) has T_n automorphism group
gap> gr := Digraph(List([1 .. 5], x -> [1 .. 5]));
<digraph with 5 vertices, 25 edges>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);
Error, Digraphs: GeneratorsOfEndomorphismMonoid: error,
not yet implemented for digraphs with loops,

#T# GeneratorsOfEndomorphismMonoid 5
# Empty digraph

# EmptyDigraph(n) has endomorphism monoid T_n
gap> gr := EmptyDigraph(5);
<digraph with 5 vertices, 0 edges>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);;
gap> Size(Semigroup(gens)) = 5 ^ 5;
true

#T# GeneratorsOfEndomorphismMonoid 6
# Chain digraph: endomorphisms of the chain preserve order

# ChainDigraph (with no loops) has all strict order preserving transformations
gap> gr := ChainDigraph(20);
<digraph with 20 vertices, 19 edges>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);
Error, Digraphs: GeneratorsOfEndomorphismMonoid: error,
not yet implemented for non-symmetric digraphs,

# ChainDigraph (with loops) has all order preserving transformations
gap> gr := Digraph(Concatenation(List([1 .. 19], x -> [x, x + 1]), [[20]]));
<digraph with 20 vertices, 39 edges>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);
Error, Digraphs: GeneratorsOfEndomorphismMonoid: error,
not yet implemented for non-symmetric digraphs,

#T# GeneratorsOfEndomorphismMonoid 7
# Cycle digraph: EndomorphismMonoid = AutomorphismGroup = C_n

# CycleDigraph (with no loops) has no singular endomorphisms
gap> gr := CycleDigraph(20);
<digraph with 20 vertices, 20 edges>
gap> gens := [];;
gap> gens := Concatenation(gens, GeneratorsOfEndomorphismMonoid(gr));
Error, Digraphs: GeneratorsOfEndomorphismMonoid: error,
not yet implemented for non-symmetric digraphs,
gap> ForAll(gens, x -> AsPermutation(x) in AutomorphismGroup(gr));
true

# CycleDigraph (with loops)
gap> gr := Digraph(List([1 .. 20], x -> [x, x mod 20 + 1]));
<digraph with 20 vertices, 40 edges>

#T# HomomorphismGraphsFinder 1
# Small example: CompleteDigraph(2) to CompleteDigraph(3)
gap> gr1 := CompleteDigraph(2);
<digraph with 2 vertices, 2 edges>
gap> gr2 := CompleteDigraph(3);
<digraph with 3 vertices, 6 edges>
gap> func := function(user_param, t)
>      user_param := user_param ^ t;
> end;;
gap> homos := HomomorphismGraphsFinder(gr1, gr2, func, Group(()), infinity,
>  fail, false, DigraphVertices(gr2), []);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `^' on 2 arguments
gap> func := function(user_param, t)
>      Add(user_param, t);
> end;;
gap> homos := HomomorphismGraphsFinder(gr1, gr2, fail, [], infinity, fail,
> false, DigraphVertices(gr2), []);
[ IdentityTransformation ]

#T# HomomorphismGraphsFinder 2
# Small example: CompleteDigraph(15) to [CompleteDigraph(3) with loops]
gap> homos := HomomorphismGraphsFinder(gr1, gr2, func, [], infinity,
>  fail, false, DigraphVertices(gr2), []);
[ IdentityTransformation ]
gap> homos := HomomorphismGraphsFinder(CompleteDigraph(15),
> Digraph(List([1 .. 3], x -> [1 .. 3])), fail, [], infinity, fail, false,
> [1 .. 3], []);;
gap> Length(homos);
2391485
gap> last * 6 = 3 ^ 15 + 3;
true

#T# HomomorphismGraphsFinder 3
# Small example: randomly chosen
gap> gr1 := Digraph([
>  [15, 3, 6, 7, 8, 16, 19], [5, 17, 18, 13, 19], [1, 7, 19, 4, 15, 17],
>  [3, 7, 15, 10, 14, 16], [8, 2, 7, 10], [1],
>  [1, 4, 5, 9, 12, 3, 8, 16], [1, 7, 13, 5, 11, 17], [14, 7, 13],
>  [4, 5, 19], [8, 18], [7, 15, 20], [2, 9, 16, 18, 8, 19],
>  [4, 18, 9], [3, 12, 1, 4, 16, 18], [1, 4, 7, 15, 13, 17],
>  [3, 8, 16, 2], [13, 15, 2, 11, 14, 20], [1, 2, 10, 13, 20, 3],
>  [12, 18, 19]]);
<digraph with 20 vertices, 94 edges>
gap> gr2 := Digraph([
>  [2, 6, 8, 11, 9, 12], [3, 7, 1, 8], [12, 2], [7, 11, 12, 5, 9],
>  [4, 7, 9], [12, 1], [5, 9, 10, 2, 4, 8], [2, 7, 10, 1],
>  [1, 4, 5, 7], [7, 8], [1, 4], [1, 6, 3, 4]]);
<digraph with 12 vertices, 44 edges>
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, fail, false, [1 .. 12],
> []);
[ Transformation( [ 4, 5, 5, 9, 4, 11, 7, 5, 5, 5, 4, 5, 4, 4, 7, 5, 4, 9, 7,
      4 ] ) ]
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 10, fail, false, [1 .. 12],
> []);
[ Transformation( [ 4, 5, 5, 9, 4, 11, 7, 5, 5, 5, 4, 5, 4, 4, 7, 5, 4, 9, 7,
      4 ] ), Transformation( [ 4, 5, 5, 9, 4, 12, 7, 5, 5, 5, 4, 5, 4, 4, 7,
      5, 4, 9, 7, 4 ] ), Transformation( [ 4, 5, 5, 9, 4, 5, 7, 5, 5, 5, 4, 5,
     4, 4, 7, 5, 4, 9, 7, 4 ] ), 
  Transformation( [ 4, 5, 5, 9, 4, 7, 7, 5, 5, 5, 4, 5, 4, 4, 7, 5, 4, 9, 7,
      4 ] ), Transformation( [ 4, 5, 5, 9, 4, 9, 7, 5, 5, 5, 4, 5, 4, 4, 7, 5,
     4, 9, 7, 4 ] ), Transformation( [ 4, 5, 5, 9, 4, 11, 7, 5, 5, 5, 4, 5, 4,
     4, 7, 5, 7, 9, 7, 4 ] ), Transformation( [ 4, 5, 5, 9, 4, 12, 7, 5, 5, 5,
     4, 5, 4, 4, 7, 5, 7, 9, 7, 4 ] ), 
  Transformation( [ 4, 5, 5, 9, 4, 5, 7, 5, 5, 5, 4, 5, 4, 4, 7, 5, 7, 9, 7,
      4 ] ), Transformation( [ 4, 5, 5, 9, 4, 7, 7, 5, 5, 5, 4, 5, 4, 4, 7, 5,
     7, 9, 7, 4 ] ), Transformation( [ 4, 5, 5, 9, 4, 9, 7, 5, 5, 5, 4, 5, 4,
      4, 7, 5, 7, 9, 7, 4 ] ) ]
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 200, fail, false, [1 .. 12],
> []);;
gap> ForAll(last, t -> ForAll(DigraphEdges(gr1),
>                        e -> IsDigraphEdge(gr2, [e[1] ^ t, e[2] ^ t])));
true
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 12, false, [1 .. 12],
> []);
[  ]
gap> HomomorphismGraphsFinder(gr2, gr1, fail, [], 1, fail, false, [1 .. 20],
> []);
[  ]

#T# HomomorphismGraphsFinder 4
# Large example: randomly chosen
gap> gr1 := DigraphFromGraph6String(
> "]b?_?a@I??T_Y?ADcGAACUP@_AOG?C_BoH?Pg?C??gk?AA@?A?CJD?EO?sO`@H?j@S?C?_PG??")
> ;
<digraph with 30 vertices, 174 edges>
gap> gr2 := DigraphFromGraph6String(Concatenation(
> "ghYlce}\\ANfA}}WbK^qUDQqfGwl]UecLg{xSyQ]fHK}]uHFUyn\\]weXQVCRZDlYUvqYpnNNv",
> "z@v]KDJvDxH}BB\\wwtMdxNFpKu?QX]RA@|MlHRpLK]EFg}WaFWuKcFK}hFs"));
<digraph with 40 vertices, 812 edges>
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, fail, false, [1 .. 40],
> []);
[ Transformation( [ 1, 2, 22, 5, 31, 5, 12, 3, 6, 36, 10, 19, 25, 5, 38, 15,
      13, 16, 26, 9, 7, 8, 7, 29, 4, 30, 27, 11, 32, 17 ] ) ]
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 10, false, [1 .. 40],
> []);
[ Transformation( [ 1, 2, 2, 5, 1, 1, 1, 3, 6, 20, 2, 20, 13, 7, 13, 15, 13,
      3, 13, 9, 7, 20, 2, 13, 1, 13, 2, 1, 2, 1 ] ) ]
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 15, false, [1 .. 40],
> []);
[ Transformation( [ 1, 2, 22, 5, 8, 1, 1, 3, 6, 1, 2, 19, 11, 7, 38, 15, 13,
      30, 13, 9, 7, 8, 7, 13, 1, 30, 8, 11, 7, 8 ] ) ]
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 20, false, [1 .. 40],
> []);
[ Transformation( [ 1, 2, 22, 5, 31, 1, 1, 3, 6, 19, 2, 19, 25, 5, 38, 15, 13,
     16, 9, 9, 7, 8, 7, 29, 1, 30, 27, 11, 7, 3 ] ) ]
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 25, false, [1 .. 40],
> []);
[ Transformation( [ 1, 2, 22, 5, 31, 5, 1, 3, 6, 36, 3, 19, 25, 5, 38, 15, 13,
     16, 26, 9, 7, 8, 7, 29, 4, 30, 27, 11, 32, 17 ] ) ]
gap> t := HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 23, false,
> [4 .. 37], [])[1];
Transformation( [ 4, 7, 13, 9, 28, 28, 6, 11, 8, 20, 5, 10, 20, 13, 31, 15,
  13, 30, 23, 25, 18, 20, 18, 37, 26, 34, 12, 4, 29, 16 ] )
gap> ForAll(DigraphEdges(gr1), e -> IsDigraphEdge(gr2, [e[1] ^ t, e[2] ^ t]));
true
gap> t := HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 23, false,
> [6 .. 37], [])[1];
Transformation( [ 6, 9, 30, 32, 31, 34, 8, 21, 10, 11, 15, 11, 7, 14, 16, 24,
  18, 25, 27, 21, 9, 23, 29, 34, 12, 19, 19, 13, 6, 21 ] )
gap> ForAll(DigraphEdges(gr1), e -> IsDigraphEdge(gr2, [e[1] ^ t, e[2] ^ t]));
true
gap> HomomorphismGraphsFinder(gr2, gr1, fail, [], 1, fail, false, [1 .. 30],
> []);
[  ]

#T# DIGRAPHS_UnbindVariables
gap> Unbind(gr);
gap> Unbind(G);
gap> Unbind(H);
gap> Unbind(gens);
gap> Unbind(S);
gap> Unbind(t);
gap> Unbind(str);
gap> Unbind(graph);
gap> Unbind(homos);
gap> Unbind(gr1);
gap> Unbind(gr2);

#E#
gap> STOP_TEST("Digraphs package: extreme/grahom.tst");
