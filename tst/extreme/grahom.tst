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

#T# GeneratorsOfEndomorphismMonoid for complete digraphs

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

#T# GeneratorsOfEndomorphismMonoid for empty digraphs

# EmptyDigraph(n) has T_n automorphism group
gap> gr := EmptyDigraph(5);
<digraph with 5 vertices, 0 edges>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);;
gap> Size(Semigroup(gens)) = 5 ^ 5;
true

#T# GeneratorsOfEndomorphismMonoid for chain digraphs

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

#T# GeneratorsOfEndomorphismMonoid for cycle digraphs

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

#T# HomomorphismGraphsFinder: trying to break it
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

#T# HomomorphismGraphsFinder: some larger examples
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
gap> gr1 := Digraph([
>  [3, 8, 7, 16, 20], [6, 8, 17, 3, 5], [2, 9, 20, 1, 19],
>  [7, 11, 14, 16, 17], [2, 7, 8, 18, 13], [18, 20, 2, 16],
>  [1, 10, 15, 4, 5, 18], [8, 1, 2, 5, 11, 16, 20], [10, 3, 12],
>  [9, 7], [4, 8, 12, 16, 20, 17], [9, 12, 13, 19, 11, 18],
>  [5, 13, 12], [4, 16], [15, 17, 7, 20], [1, 4, 6, 8, 20, 11, 14],
>  [4, 11, 2, 15], [7, 12, 5, 6], [3, 12], [1, 8, 15, 3, 6, 11, 16]]);
<digraph with 20 vertices, 92 edges>
gap> gr2 := Digraph([
>  [7, 5, 12], [2, 4, 7, 8, 3, 10], [2, 11], [2, 6, 10, 11],
>  [1, 6, 7, 9, 11], [7, 10, 4, 5], [2, 5, 6, 11, 1, 12], [9, 11, 2],
>  [5, 9, 11, 8], [2, 11, 4, 6], [4, 3, 5, 7, 8, 9, 10, 12],
>  [1, 7, 11, 12]]);
<digraph with 12 vertices, 53 edges>
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, fail, false, [1 .. 12],
> []);
[ Transformation( [ 1, 11, 5, 1, 7, 12, 5, 12, 6, 7, 12, 7, 2, 7, 1, 12, 7, 1,
     1, 7 ] ) ]
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 10, fail, false, [1 .. 12],
> []);
[ Transformation( [ 1, 11, 5, 1, 7, 12, 5, 12, 6, 7, 12, 7, 2, 7, 1, 12, 7, 1,
     1, 7 ] ), Transformation( [ 1, 11, 5, 1, 7, 12, 5, 12, 6, 7, 12, 7, 1, 7,
     1, 12, 7, 1, 1, 7 ] ), Transformation( [ 1, 11, 5, 1, 7, 12, 5, 12, 6, 7,
     12, 7, 5, 7, 1, 12, 7, 1, 1, 7 ] ), 
  Transformation( [ 1, 11, 5, 1, 7, 12, 5, 12, 6, 7, 12, 7, 6, 7, 1, 12, 7, 1,
     1, 7 ] ), Transformation( [ 1, 11, 5, 1, 7, 12, 5, 12, 6, 7, 12, 7, 11,
      7, 1, 12, 7, 1, 1, 7 ] ), 
  Transformation( [ 1, 11, 5, 1, 7, 12, 5, 12, 6, 7, 12, 7, 12, 7, 1, 12, 7,
      1, 1, 7 ] ), Transformation( [ 1, 11, 5, 1, 7, 12, 5, 12, 6, 7, 12, 7,
      2, 7, 1, 12, 7, 1, 6, 7 ] ), 
  Transformation( [ 1, 11, 5, 1, 7, 12, 5, 12, 6, 7, 12, 7, 1, 7, 1, 12, 7, 1,
     6, 7 ] ), Transformation( [ 1, 11, 5, 1, 7, 12, 5, 12, 6, 7, 12, 7, 5, 7,
     1, 12, 7, 1, 6, 7 ] ), Transformation( [ 1, 11, 5, 1, 7, 12, 5, 12, 6, 7,
     12, 7, 6, 7, 1, 12, 7, 1, 6, 7 ] ) ]
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 50, fail, false, [1 .. 12],
> []);;
gap> ForAll(last, t -> ForAll(DigraphEdges(gr1),
>                e -> e[1] = e[2] or IsDigraphEdge(gr2, [e[1] ^ t, e[2] ^ t])));
true
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 10, false, [1 .. 12],
> []);
[ Transformation( [ 2, 11, 3, 2, 5, 4, 7, 7, 2, 2, 2, 7, 1, 10, 2, 2, 8, 6, 2,
     2 ] ) ]

##T# DIGRAPHS_UnbindVariables
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
