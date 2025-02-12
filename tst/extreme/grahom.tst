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

#  GeneratorsOfEndomorphismMonoid 1
# PJC example, 45 vertices
gap> gr := DigraphFromDigraph6String(Concatenation(
> "+l??O?C?A_@???CE????GAAG?C??M?????@_?OO??G??@?IC???_C?G?o??C?AO???c_??A?A",
> "?S???OAA???OG???G_A??C?@?cC????_@G???S??C_?C???[??A?A?OA?O?@?A?@A???GGO??",
> "`?_O??G?@?A??G?@AH????AA?O@??_??b???Cg??C???_??W?G????d?G?C@A?C???GC?W???",
> "??K???__O[??????O?W???O@??_G?@?CG??G?@G?C??@G???_Q?O?O?c???OAO?C??C?G?O??",
> "A@??D??G?C_?A??O?_GA??@@?_?G???E?IW??????_@G?C??"));
<immutable digraph with 45 vertices, 180 edges>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);;
gap> Length(gens);
329
gap> Size(Semigroup(gens));
105120
gap> HomomorphismDigraphsFinder(gr, gr, fail, [], infinity, fail, 0,
> [1, 14, 28, 39, 42], [], fail, fail);;
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
gap> str := HomomorphismDigraphsFinder(gr, gr, fail, [], infinity, fail, 0,
> [1, 14, 28, 39, 42], [], fail, fail);;
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
gap> Length(str);
192

#  GeneratorsOfEndomorphismMonoid 2
# PJC example, 153 vertices
# G = PrimitiveGroup(153, 1);
gap> G := Group([
> (1, 29, 118)(2, 136, 112)(3, 89, 144)(4, 54, 146)(5, 84, 148)(6, 153, 36)
>  (7, 76, 137)(8, 138, 152)(9, 150, 123)(10, 124, 83)(11, 105, 74)
>  (12, 119, 134)(13, 44, 103)(14, 135, 56)(15, 93, 139)(16, 142, 149)
>  (17, 107, 20)(18, 82, 19)(21, 48, 91)(22, 87, 125)(23, 130, 60)(24, 50, 122)
>  (25, 86, 102)(26, 101, 95)(27, 67, 61)(28, 98, 126)(30, 55, 63)(31, 116, 66)
>  (32, 58, 145)(33, 99, 68)(34, 140, 131)(35, 117, 92)(37, 38, 52)
>  (39, 147, 106)(40, 85, 97)(41, 96, 70)(42, 65, 94)(43, 71, 111)(45, 46, 110)
>  (47, 141, 49)(51, 59, 90)(53, 114, 143)(57, 115, 80)(62, 133, 73)
>  (64, 113, 121)(69, 77, 75)(72, 129, 88)(78, 120, 127)(79, 81, 132)
>  (100, 151, 108)(104, 128, 109),
> (1, 147)(2, 110)(3, 35)(4, 67)(5, 145)(6, 96)(7, 84)(8, 63)(9, 101)(10, 138)
>  (11, 142)(12, 90)(13, 78)(14, 121)(15, 43)(16, 135)(17, 115)(19, 118)(20, 97)
>  (21, 104)(22, 77)(23, 53)(24, 103)(25, 122)(26, 125)(27, 153)(28, 80)
>  (29, 109)(30, 113)(31, 131)(32, 99)(33, 128)(34, 98)(36, 137)(37, 123)
>  (38, 50)(39, 130)(40, 119)(41, 56)(42, 72)(44, 71)(45, 143)(46, 68)(48, 54)
>  (49, 59)(51, 149)(52, 141)(55, 65)(57, 132)(58, 120)(60, 150)(61, 111)
>  (62, 114)(64, 93)(66, 136)(69, 100)(70, 140)(74, 83)(75, 129)(76, 151)
>  (82, 133)(85, 139)(86, 108)(87, 106)(89, 127)(91, 134)(92, 148)(94, 116)
>  (95, 124)(107, 144)(112, 146)(117, 126)]);;
gap> H := Stabilizer(G, 1);;
gap> S := Filtered(Orbits(H, [1 .. 45]), x -> (Size(x) = 4))[1];;
gap> gr := EdgeOrbitsDigraph(G, List(S, x -> [1, x]));
<immutable digraph with 153 vertices, 612 edges>
gap> t := HomomorphismDigraphsFinder(gr, gr, fail, [], 1, 7, 0, [1 .. 153],
> [], fail, fail)[1];
<transformation on 153 pts with rank 7>
gap> 1 ^ t;
1
gap> 2 ^ t;
27
gap> 3 ^ t;
113
gap> 4 ^ t;
97
gap> 5 ^ t;
71
gap> IsDigraphHomomorphism(gr, gr, t);
true
gap> if GAPInfo.BytesPerVariable = 8 then
>      t := HomomorphismDigraphsFinder(gr, gr, fail, [], 1, 9, 0, [1 .. 153],
>                                      [], fail, fail)[1];
>    else
>      t := Transformation([1, 97, 97, 113, 97, 71, 71, 103, 97, 71, 113, 71,
>                           71, 113, 27, 71, 73, 1, 27, 71, 71, 97, 71, 103,
>                           73, 113, 27, 97, 97, 113, 97, 97, 93, 71, 82, 113,
>                           71, 113, 97, 71, 97, 97, 97, 97, 82, 113, 113, 97,
>                           71, 71, 71, 71, 113, 113, 113, 97, 71, 93, 93, 113,
>                           97, 97, 97, 113, 73, 97, 113, 71, 97, 71, 71, 113,
>                           73, 71, 113, 113, 73, 73, 71, 97, 1, 113, 71, 71,
>                           71, 97, 71, 97, 113, 71, 113, 113, 97, 113, 71, 97,
>                           97, 113, 113, 27, 71, 27, 103, 71, 82, 103, 113,
>                           97, 97, 71, 97, 82, 113, 103, 113, 71, 113, 113,
>                           71, 27, 113, 113, 97, 97, 113, 113, 71, 93, 113,
>                           71, 71, 103, 71, 97, 1, 82, 97, 1, 1, 93, 93, 97,
>                           97, 113, 71, 82, 113, 97, 113, 71, 113, 97, 97]);
>    fi; 
gap> IsDigraphHomomorphism(gr, gr, t);
true
gap> ListTransformation(t);
[ 1, 97, 97, 113, 97, 71, 71, 103, 97, 71, 113, 71, 71, 113, 27, 71, 73, 1, 
  27, 71, 71, 97, 71, 103, 73, 113, 27, 97, 97, 113, 97, 97, 93, 71, 82, 113, 
  71, 113, 97, 71, 97, 97, 97, 97, 82, 113, 113, 97, 71, 71, 71, 71, 113, 
  113, 113, 97, 71, 93, 93, 113, 97, 97, 97, 113, 73, 97, 113, 71, 97, 71, 
  71, 113, 73, 71, 113, 113, 73, 73, 71, 97, 1, 113, 71, 71, 71, 97, 71, 97, 
  113, 71, 113, 113, 97, 113, 71, 97, 97, 113, 113, 27, 71, 27, 103, 71, 82, 
  103, 113, 97, 97, 71, 97, 82, 113, 103, 113, 71, 113, 113, 71, 27, 113, 
  113, 97, 97, 113, 113, 71, 93, 113, 71, 71, 103, 71, 97, 1, 82, 97, 1, 1, 
  93, 93, 97, 97, 113, 71, 82, 113, 97, 113, 71, 113, 97, 97 ]

#  GeneratorsOfEndomorphismMonoid 3
# Small example
gap> gr := Digraph([[2], [1, 3], [2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> Set(GeneratorsOfEndomorphismMonoid(gr));
[ Transformation( [ 1, 2, 1 ] ), IdentityTransformation, 
  Transformation( [ 2, 1, 2 ] ), Transformation( [ 3, 2, 1 ] ) ]
gap> gr := DigraphCopy(gr);
<immutable digraph with 3 vertices, 4 edges>
gap> Set(GeneratorsOfEndomorphismMonoid(gr));
[ Transformation( [ 1, 2, 1 ] ), IdentityTransformation, 
  Transformation( [ 2, 1, 2 ] ), Transformation( [ 3, 2, 1 ] ) ]
gap> gr := DigraphCopy(gr);;
gap> Set(GeneratorsOfEndomorphismMonoid(gr, infinity));
[ Transformation( [ 1, 2, 1 ] ), IdentityTransformation, 
  Transformation( [ 2, 1, 2 ] ), Transformation( [ 3, 2, 1 ] ) ]
gap> gr := DigraphCopy(gr);;
gap> GeneratorsOfEndomorphismMonoid(gr, 1);
[ Transformation( [ 3, 2, 1 ] ) ]
gap> gr := DigraphCopy(gr);;
gap> GeneratorsOfEndomorphismMonoid(gr, 2);
[ Transformation( [ 3, 2, 1 ] ), Transformation( [ 2, 1, 2 ] ) ]
gap> HasGeneratorsOfEndomorphismMonoidAttr(gr);
false
gap> GeneratorsOfEndomorphismMonoid(gr, 3);
[ Transformation( [ 3, 2, 1 ] ), Transformation( [ 2, 1, 2 ] ), 
  IdentityTransformation ]
gap> HasGeneratorsOfEndomorphismMonoidAttr(gr);
false
gap> GeneratorsOfEndomorphismMonoid(gr, 4);
[ Transformation( [ 3, 2, 1 ] ), Transformation( [ 2, 1, 2 ] ), 
  IdentityTransformation, Transformation( [ 1, 2, 1 ] ) ]
gap> HasGeneratorsOfEndomorphismMonoidAttr(gr);
false

#  GeneratorsOfEndomorphismMonoid 4
# Complete digraph

# CompleteDigraph (with no loops) has no singular endomorphisms
gap> gr := CompleteDigraph(25);
<immutable complete digraph with 25 vertices>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);
[ Transformation( [ 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
      18, 19, 20, 21, 22, 23, 24, 25, 1 ] ), Transformation( [ 2, 1 ] ), 
  Transformation( [ 7, 2, 3, 4, 5, 6, 1, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
     24, 19, 20, 21, 22, 23, 18 ] ) ]
gap> ForAll(gens, x -> IsDigraphAutomorphism(gr, x)); 
true
gap> GeneratorsOfEndomorphismMonoid(gr) = gens;
true

# CompleteDigraph(n) (with loops added) has T_n automorphism group
gap> gr := Digraph(List([1 .. 5], x -> [1 .. 5]));
<immutable digraph with 5 vertices, 25 edges>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);
[ Transformation( [ 1, 2, 3, 5, 4 ] ), Transformation( [ 1, 2, 4, 3 ] ), 
  Transformation( [ 1, 3, 2 ] ), Transformation( [ 2, 1 ] ), 
  IdentityTransformation, Transformation( [ 1, 2, 3, 4, 1 ] ), 
  Transformation( [ 1, 2, 3, 4, 2 ] ), Transformation( [ 1, 2, 3, 4, 3 ] ), 
  Transformation( [ 1, 2, 3, 4, 4 ] ), Transformation( [ 1, 2, 3, 1, 4 ] ), 
  Transformation( [ 1, 2, 3, 1, 1 ] ), Transformation( [ 1, 2, 3, 1, 2 ] ), 
  Transformation( [ 1, 2, 3, 1, 3 ] ), Transformation( [ 1, 2, 3, 2, 4 ] ), 
  Transformation( [ 1, 2, 3, 2, 1 ] ), Transformation( [ 1, 2, 3, 2, 2 ] ), 
  Transformation( [ 1, 2, 3, 2, 3 ] ), Transformation( [ 1, 2, 3, 3, 4 ] ), 
  Transformation( [ 1, 2, 3, 3, 1 ] ), Transformation( [ 1, 2, 3, 3, 2 ] ), 
  Transformation( [ 1, 2, 3, 3, 3 ] ), Transformation( [ 1, 2, 1, 3, 4 ] ), 
  Transformation( [ 1, 2, 1, 3, 1 ] ), Transformation( [ 1, 2, 1, 3, 2 ] ), 
  Transformation( [ 1, 2, 1, 3, 3 ] ), Transformation( [ 1, 2, 1, 1, 3 ] ), 
  Transformation( [ 1, 2, 1, 1, 1 ] ), Transformation( [ 1, 2, 1, 1, 2 ] ), 
  Transformation( [ 1, 2, 1, 2, 3 ] ), Transformation( [ 1, 2, 1, 2, 1 ] ), 
  Transformation( [ 1, 2, 1, 2, 2 ] ), Transformation( [ 1, 2, 2, 3, 4 ] ), 
  Transformation( [ 1, 2, 2, 3, 1 ] ), Transformation( [ 1, 2, 2, 3, 2 ] ), 
  Transformation( [ 1, 2, 2, 3, 3 ] ), Transformation( [ 1, 2, 2, 1, 3 ] ), 
  Transformation( [ 1, 2, 2, 1, 1 ] ), Transformation( [ 1, 2, 2, 1, 2 ] ), 
  Transformation( [ 1, 2, 2, 2, 3 ] ), Transformation( [ 1, 2, 2, 2, 1 ] ), 
  Transformation( [ 1, 2, 2, 2, 2 ] ), Transformation( [ 1, 1, 2, 3, 4 ] ), 
  Transformation( [ 1, 1, 2, 3, 1 ] ), Transformation( [ 1, 1, 2, 3, 2 ] ), 
  Transformation( [ 1, 1, 2, 3, 3 ] ), Transformation( [ 1, 1, 2, 1, 3 ] ), 
  Transformation( [ 1, 1, 2, 1, 1 ] ), Transformation( [ 1, 1, 2, 1, 2 ] ), 
  Transformation( [ 1, 1, 2, 2, 3 ] ), Transformation( [ 1, 1, 2, 2, 1 ] ), 
  Transformation( [ 1, 1, 2, 2, 2 ] ), Transformation( [ 1, 1, 1, 2, 3 ] ), 
  Transformation( [ 1, 1, 1, 2, 1 ] ), Transformation( [ 1, 1, 1, 2, 2 ] ), 
  Transformation( [ 1, 1, 1, 1, 2 ] ), Transformation( [ 1, 1, 1, 1, 1 ] ) ]

#  GeneratorsOfEndomorphismMonoid 5
# Empty digraph

# EmptyDigraph(n) has endomorphism monoid T_n
gap> gr := EmptyDigraph(5);
<immutable empty digraph with 5 vertices>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);;
gap> Size(Semigroup(gens)) = 5 ^ 5;
true

#  GeneratorsOfEndomorphismMonoid 6
# Chain digraph: endomorphisms of the chain preserve order

# ChainDigraph (with no loops) has no singular endomorphisms
gap> gr := ChainDigraph(20);
<immutable chain digraph with 20 vertices>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);
[ IdentityTransformation ]

# ChainDigraph (with loops) has all transformations where the image of a point
# is equal to, or one more than, the image of the previous point
gap> n := 12;;
gap> D := DigraphAddAllLoops(ChainDigraph(n));
<immutable reflexive digraph with 12 vertices, 23 edges>
gap> S := GeneratorsOfEndomorphismMonoid(D);;
gap> if IsBound(SmallSemigroupGeneratingSet) then 
> S := SmallSemigroupGeneratingSet(S);;
> S := Semigroup(S);
> fi;
gap> Size(S);
13312
gap> Size(S) = (n + 1) * 2 ^ (n - 2);
true

# Reflexive transitive closure of ChainDigraph has all order preserving
# transformations
gap> n := 6;;
gap> D := DigraphReflexiveTransitiveClosure(ChainDigraph(n));
<immutable preorder digraph with 6 vertices, 21 edges>
gap> S := GeneratorsOfEndomorphismMonoid(D);;
gap> if IsBound(SmallSemigroupGeneratingSet) then 
> S := SmallSemigroupGeneratingSet(S);;
> S := Semigroup(S);;
> fi;
gap> Size(S);
462

#  GeneratorsOfEndomorphismMonoid 7
# Cycle digraph: EndomorphismMonoid = AutomorphismGroup = C_n

# CycleDigraph (with no loops) has no singular endomorphisms
gap> gr := CycleDigraph(20);
<immutable cycle digraph with 20 vertices>
gap> gens := [];;
gap> gens := Concatenation(gens, GeneratorsOfEndomorphismMonoid(gr));
[ Transformation( [ 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
      18, 19, 20, 1 ] ), IdentityTransformation ]
gap> ForAll(gens, x -> AsPermutation(x) in AutomorphismGroup(gr));
true

# CycleDigraph (with loops)
gap> gr := Digraph(List([1 .. 20], x -> [x, x mod 20 + 1]));
<immutable digraph with 20 vertices, 40 edges>

#  GeneratorsOfEndomorphismMonoid8
# Check endomorphism monoid of all symmetric digraphs with 5 vertices
gap> graph5 := ReadDigraphs(Concatenation(DIGRAPHS_Dir(),
>                                         "/data/graph5.g6.gz"));;
gap> ForAll(graph5, IsSymmetricDigraph);
true
gap> adj := [];;
gap> for gr in graph5
> do
>   adj := AdjacencyMatrix(gr);;
>   endos1 := Elements(Semigroup(GeneratorsOfEndomorphismMonoid(gr)));
>   endos2 := [];
>   for t in Elements(FullTransformationMonoid(5)) do
>     if ForAll(DigraphEdges(gr), x -> adj[x[1] ^ t][x[2] ^ t] = 1) then
>       Add(endos2, t);
>     fi;
>   od;
>   if not (IsSubset(endos1, endos2) and Length(endos1) = Length(endos2)) then
>     Print("fail");
>   fi;
> od;

#  GeneratorsOfEndomorphismMonoid9
# Check some symmetric digraphs from digraphs-lib
gap> gr := ReadDigraphs(
> Concatenation(DIGRAPHS_Dir(), "/digraphs-lib/sts.g6.gz"), 1);
<immutable symmetric digraph with 26 vertices, 390 edges>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);;
gap> adj := AdjacencyMatrix(gr);;
gap> ForAll(gens, t -> ForAll(DigraphEdges(gr),
>      x -> adj[x[1] ^ t][x[2] ^ t] = 1));
true
gap> gr := ReadDigraphs(
> Concatenation(DIGRAPHS_Dir(), "/digraphs-lib/sts.g6.gz"), 2);
<immutable symmetric digraph with 35 vertices, 630 edges>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);;
gap> adj := AdjacencyMatrix(gr);;
gap> ForAll(gens, t -> ForAll(DigraphEdges(gr),
>      x -> adj[x[1] ^ t][x[2] ^ t] = 1));
true
gap> gr := ReadDigraphs(
> Concatenation(DIGRAPHS_Dir(), "/digraphs-lib/sts.g6.gz"), 21);
<immutable symmetric digraph with 7 vertices, 42 edges>
gap> gens := GeneratorsOfEndomorphismMonoid(gr);;
gap> adj := AdjacencyMatrix(gr);;
gap> ForAll(gens, t -> ForAll(DigraphEdges(gr),
>      x -> adj[x[1] ^ t][x[2] ^ t] = 1));
true
gap> gr := ReadDigraphs(
> Concatenation(DIGRAPHS_Dir(), "/digraphs-lib/sts.g6.gz"), 25);
<immutable symmetric digraph with 12 vertices, 108 edges>
gap> GeneratorsOfEndomorphismMonoid(gr);;

#  HomomorphismDigraphsFinder 1
# Small example: CompleteDigraph(2) to CompleteDigraph(3)
gap> gr1 := CompleteDigraph(2);
<immutable complete digraph with 2 vertices>
gap> gr2 := CompleteDigraph(3);
<immutable complete digraph with 3 vertices>
gap> func := function(user_param, t)
>      user_param := user_param ^ t;
> end;;
gap> homos := HomomorphismDigraphsFinder(gr1, gr2, func, Group(()), infinity,
>  fail, 0, DigraphVertices(gr2), [], fail, fail);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `^' on 2 arguments
gap> func := function(user_param, t)
>      Add(user_param, t);
> end;;
gap> homos := HomomorphismDigraphsFinder(gr1, gr2, fail, [], infinity, fail,
> 0, DigraphVertices(gr2), [], fail, fail);
[ IdentityTransformation ]

#  HomomorphismDigraphsFinder 2
# Small example: CompleteDigraph(15) to [CompleteDigraph(3) with loops]
gap> homos := HomomorphismDigraphsFinder(gr1, gr2, func, [], infinity,
>  fail, 0, DigraphVertices(gr2), [], fail, fail);
[ IdentityTransformation ]
gap> homos := HomomorphismDigraphsFinder(CompleteDigraph(15),
> Digraph(List([1 .. 3], x -> [1 .. 3])), fail, [], infinity, fail, 0,
> [1 .. 3], [], fail, fail);;
gap> Length(homos);
2391485
gap> last * 6 = 3 ^ 15 + 3;
true

#  HomomorphismDigraphsFinder 3
# Small example: randomly chosen
gap> gr1 := Digraph([
>  [15, 3, 6, 7, 8, 16, 19], [5, 17, 18, 13, 19], [1, 7, 19, 4, 15, 17],
>  [3, 7, 15, 10, 14, 16], [8, 2, 7, 10], [1],
>  [1, 4, 5, 9, 12, 3, 8, 16], [1, 7, 13, 5, 11, 17], [14, 7, 13],
>  [4, 5, 19], [8, 18], [7, 15, 20], [2, 9, 16, 18, 8, 19],
>  [4, 18, 9], [3, 12, 1, 4, 16, 18], [1, 4, 7, 15, 13, 17],
>  [3, 8, 16, 2], [13, 15, 2, 11, 14, 20], [1, 2, 10, 13, 20, 3],
>  [12, 18, 19]]);
<immutable digraph with 20 vertices, 94 edges>
gap> gr2 := Digraph([
>  [2, 6, 8, 11, 9, 12], [3, 7, 1, 8], [12, 2], [7, 11, 12, 5, 9],
>  [4, 7, 9], [12, 1], [5, 9, 10, 2, 4, 8], [2, 7, 10, 1],
>  [1, 4, 5, 7], [7, 8], [1, 4], [1, 6, 3, 4]]);
<immutable digraph with 12 vertices, 44 edges>
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, fail, 0, [1 .. 12],
> [], fail, fail);
[ Transformation( [ 4, 5, 5, 9, 4, 11, 7, 5, 5, 5, 4, 5, 4, 4, 7, 5, 4, 9, 7,
      4 ] ) ]
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 10, fail, 0, [1 .. 12],
> [], fail, fail);
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
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 200, fail, 0, [1 .. 12],
> [], fail, fail);;
gap> ForAll(last, t -> ForAll(DigraphEdges(gr1),
>                        e -> IsDigraphEdge(gr2, [e[1] ^ t, e[2] ^ t])));
true
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 12, 0, [1 .. 12],
> [], fail, fail);
[  ]
gap> HomomorphismDigraphsFinder(gr2, gr1, fail, [], 1, fail, 0, [1 .. 20],
> [], fail, fail);
[  ]

#  HomomorphismDigraphsFinder 4
# Large example: randomly chosen
gap> gr1 := DigraphFromGraph6String(
> "]b?_?a@I??T_Y?ADcGAACUP@_AOG?C_BoH?Pg?C??gk?AA@?A?CJD?EO?sO`@H?j@S?C?_PG??")
> ;
<immutable symmetric digraph with 30 vertices, 174 edges>
gap> gr2 := DigraphFromGraph6String(Concatenation(
> "ghYlce}\\ANfA}}WbK^qUDQqfGwl]UecLg{xSyQ]fHK}]uHFUyn\\]weXQVCRZDlYUvqYpnNNv",
> "z@v]KDJvDxH}BB\\wwtMdxNFpKu?QX]RA@|MlHRpLK]EFg}WaFWuKcFK}hFs"));
<immutable symmetric digraph with 40 vertices, 812 edges>
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, fail, 0, [1 .. 40],
> [], fail, fail);
[ Transformation( [ 1, 2, 22, 5, 31, 5, 12, 3, 6, 36, 10, 19, 25, 5, 38, 15,
      13, 16, 26, 9, 7, 8, 7, 29, 4, 30, 27, 11, 32, 17, 31, 32, 33, 34, 35,
      36, 37, 38 ] ) ]
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 10, 0, [1 .. 40],
> [], fail, fail);
[ Transformation( [ 1, 2, 2, 5, 1, 1, 1, 3, 6, 20, 2, 20, 13, 7, 13, 15, 13,
      3, 13, 9, 7, 20, 2, 13, 1, 13, 2, 1, 2, 1 ] ) ]
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 15, 0, [1 .. 40],
> [], fail, fail);
[ Transformation( [ 1, 2, 22, 5, 8, 1, 1, 3, 6, 1, 2, 19, 11, 7, 38, 15, 13,
      30, 13, 9, 7, 8, 7, 13, 1, 30, 8, 11, 7, 8, 31, 32, 33, 34, 35, 36, 37,
      38 ] ) ]
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 20, 0, [1 .. 40],
> [], fail, fail);
[ Transformation( [ 1, 2, 22, 5, 31, 1, 1, 3, 6, 19, 2, 19, 25, 5, 38, 15, 13,
     16, 9, 9, 7, 8, 7, 29, 1, 30, 27, 11, 7, 3, 31, 32, 33, 34, 35, 36, 37,
      38 ] ) ]
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 25, 0, [1 .. 40],
> [], fail, fail);
[ Transformation( [ 1, 2, 22, 5, 31, 5, 1, 3, 6, 36, 3, 19, 25, 5, 38, 15, 13,
     16, 26, 9, 7, 8, 7, 29, 4, 30, 27, 11, 32, 17, 31, 32, 33, 34, 35, 36,
      37, 38 ] ) ]
gap> t := HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 23, 0,
> [4 .. 37], [], fail, fail, DigraphWelshPowellOrder(gr1))[1];
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
Transformation( [ 15, 11, 4, 7, 4, 9, 6, 17, 11, 31, 10, 7, 25, 9, 26, 22, 29,
 8, 21, 27, 25, 25, 30, 19, 18, 13, 16, 8, 5, 32, 31, 32 ] )
gap> ForAll(DigraphEdges(gr1), e -> IsDigraphEdge(gr2, [e[1] ^ t, e[2] ^ t]));
true
gap> t := HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 23, 0,
> [6 .. 37], [], fail, fail, DigraphWelshPowellOrder(gr1))[1];
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
Transformation( [ 13, 20, 6, 30, 25, 24, 6, 23, 17, 30, 14, 9, 29, 11, 19, 28,
 13, 34, 32, 7, 9, 10, 18, 15, 12, 21, 7, 11, 37, 19, 31, 32, 33, 34, 35, 36,
  37 ] )
gap> IsDigraphHomomorphism(gr1, gr2, t);
true
gap> ForAll(DigraphEdges(gr1), e -> IsDigraphEdge(gr2, [e[1] ^ t, e[2] ^ t]));
true
gap> HomomorphismDigraphsFinder(gr2, gr1, fail, [], 1, fail, 0, [1 .. 30],
> [], fail, fail);
[  ]

# Another test from PJC
gap> parts := Filtered(PartitionsSet([1 .. 9], 3), 
>                      x -> ForAll(x, y -> Length(y) = 3));;
gap> D := Digraph(parts, {x, y} -> ForAll(x, z -> not z in y));
<immutable digraph with 280 vertices, 70560 edges>
gap> t := DigraphHomomorphism(CompleteDigraph(25), D);
<transformation on 273 pts with rank 251>
gap> tt := HomomorphismDigraphsFinder(CompleteDigraph(26),
>                                     D,
>                                     fail,       # hook
>                                     [],         # user_param
>                                     1,          # max_results
>                                     fail,         
>                                     0,          
>                                     [1 .. 280], 
>                                     OnTuples([2 .. 25], t),         
>                                     fail,       
>                                     fail)[1];
<transformation on 273 pts with rank 250>
gap> OnTuples([2 .. 25], t) = OnTuples([2 .. 25], tt);
false
gap> for i in [1 .. 25] do 
> tt := HomomorphismDigraphsFinder(CompleteDigraph(25),
>                                  D,
>                                  fail,       # hook
>                                  [],         # user_param
>                                  1,          # max_results
>                                  fail,         
>                                  0,          
>                                  [1 .. 280], 
>                                  OnTuples([1 .. i], t),         
>                                  fail,       
>                                  fail)[1];
>  if not IsDigraphHomomorphism(CompleteDigraph(25), D, tt) then 
>    Print("Error 1 in number ", i, "\n");
>  elif OnTuples([1 .. i], tt) <> OnTuples([1 .. i], t) then 
>    Print("Error 2 in number ", i, "\n");
>  fi;
> od;

# Another test from PJC
gap> parts := Filtered(PartitionsSet([1 .. 9], 3), 
>                      x -> ForAll(x, y -> Length(y) = 3));;
gap> D := Digraph(parts, {x, y} -> ForAll(x, z -> not z in y));
<immutable digraph with 280 vertices, 70560 edges>
gap> t := DigraphHomomorphism(CompleteDigraph(25), D);
<transformation on 273 pts with rank 251>
gap> tt := HomomorphismDigraphsFinder(CompleteDigraph(26),
>                                     D,
>                                     fail,       # hook
>                                     [],         # user_param
>                                     1,          # max_results
>                                     fail,         
>                                     0,          
>                                     [1 .. 280], 
>                                     OnTuples([2 .. 25], t),         
>                                     fail,       
>                                     fail)[1];
<transformation on 273 pts with rank 250>
gap> OnTuples([2 .. 25], t) = OnTuples([1 .. 24], tt);
true
gap> for i in [1 .. 25] do 
> tt := HomomorphismDigraphsFinder(CompleteDigraph(25),
>                                  D,
>                                  fail,       # hook
>                                  [],         # user_param
>                                  1,          # max_results
>                                  fail,         
>                                  0,          
>                                  [1 .. 280], 
>                                  OnTuples([1 .. i], t),         
>                                  fail,       
>                                  fail)[1];
>  if not IsDigraphHomomorphism(CompleteDigraph(25), D, tt) then 
>    Print("Error 1 in number ", i, "\n");
>  elif OnTuples([1 .. i], tt) <> OnTuples([1 .. i], t) then 
>    Print("Error 2 in number ", i, "\n");
>  fi;
> od;
gap> t := DigraphEpimorphism(D, CompleteDigraph(28));
<transformation on 280 pts with rank 28>
gap> IsDigraphEpimorphism(D, CompleteDigraph(28), t);
true
gap> DigraphEpimorphism(D, CompleteDigraph(27));
fail

# From https://math.stackexchange.com/questions/1561029
gap> D := DigraphFromGraph6String(
> "khdLA_gc?N_QQchPIS@Q_dH@GKA_W@OW?Fo???~{G??SgSoSgSQISIaQcQgD?\\@?SASI?gGggC_[\
> `??N_M??APNG?Qc?E?DIG?_?IS?B??IS?E??dH?C??H@_B??A_W?o??IB?E???Fo?O????F~O?????\
> ?N~~{");
<immutable symmetric digraph with 44 vertices, 464 edges>
gap> t := DigraphEpimorphism(D, CompleteDigraph(6));
Transformation( [ 4, 2, 1, 2, 1, 4, 2, 3, 2, 3, 1, 4, 4, 5, 5, 4, 1, 3, 3, 3,
  1, 2, 3, 2, 6, 4, 5, 2, 6, 6, 3, 5, 4, 4, 5, 4, 4, 3, 5, 5, 5, 5, 2, 1 ] )
gap> IsDigraphEpimorphism(D, CompleteDigraph(6), t);
true
gap> t := DigraphEpimorphism(D, CompleteDigraph(5));
fail

# This example shows why memory allocation is bad . . .
# gap> D := ReadDigraphs(Concatenation(DIGRAPHS_Dir(),
# >                                    "/data/boolean_row_spaces.d6.gz"));;
# gap> D := Digraph(D, {x, y} -> x <> y and DigraphEmbedding(x, y) <> fail);
# <immutable digraph with 393 vertices, 15253 edges>

#  DIGRAPHS_UnbindVariables
gap> Unbind(D);
gap> Unbind(G);
gap> Unbind(H);
gap> Unbind(S);
gap> Unbind(adj);
gap> Unbind(func);
gap> Unbind(gens);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(graph5);
gap> Unbind(homos);
gap> Unbind(i);
gap> Unbind(n);
gap> Unbind(parts);
gap> Unbind(str);
gap> Unbind(t);
gap> Unbind(tt);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: extreme/grahom.tst", 0);
