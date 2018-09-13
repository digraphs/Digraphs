#############################################################################
##
#W  standard/isomorph.tst
#Y  Copyright (C) 2015-17                                   Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/isomorph.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#T# AutomorphismGroup: for a digraph without multiple edges

# Complete digraph on n vertices should have automorphism group S_n
gap> n := 5;;
gap> gr := CompleteDigraph(n);
<digraph with 5 vertices, 20 edges>
gap> AutomorphismGroup(gr) = SymmetricGroup(n);
true
gap> not DIGRAPHS_NautyAvailable or
> NautyAutomorphismGroup(gr) = SymmetricGroup(n);
true

# Empty digraph on n vertices should have automorphism group S_n
gap> n := 10;;
gap> gr := EmptyDigraph(n);
<digraph with 10 vertices, 0 edges>
gap> AutomorphismGroup(gr) = SymmetricGroup(n);
true
gap> not DIGRAPHS_NautyAvailable or
> NautyAutomorphismGroup(gr) = SymmetricGroup(n);
true

# Chain digraph on n vertices should have trivial automorphism group
gap> n := 5;;
gap> gr := ChainDigraph(n);
<digraph with 5 vertices, 4 edges>
gap> IsTrivial(AutomorphismGroup(gr));
true
gap> not DIGRAPHS_NautyAvailable or IsTrivial(NautyAutomorphismGroup(gr));
true
gap> gr := DigraphCopy(ChainDigraph(n));;
gap> not DIGRAPHS_NautyAvailable or IsTrivial(NautyAutomorphismGroup(gr));
true
gap> not DIGRAPHS_NautyAvailable
> or IsTrivial(NautyAutomorphismGroup(gr, [1, 2, 3, 1, 2]));
true

# Cycle digraph on n vertices should have cyclic automorphism group C_n
gap> n := 5;;
gap> gr := CycleDigraph(n);
<digraph with 5 vertices, 5 edges>
gap> IsCyclic(AutomorphismGroup(gr));
true
gap> Size(AutomorphismGroup(gr)) = n;
true
gap> not DIGRAPHS_NautyAvailable or
> Size(NautyAutomorphismGroup(gr)) = n;
true

# Complete bipartitite graph with parts of size m and n
# shoud have automorphism group S_m x S_n
gap> m := 5;; n := 4;;
gap> gr := CompleteBipartiteDigraph(m, n);
<digraph with 9 vertices, 40 edges>
gap> G := AutomorphismGroup(gr);;
gap> G = DirectProduct(SymmetricGroup(m), SymmetricGroup(n));
true
gap> G := NautyAutomorphismGroup(gr);;
gap> not DIGRAPHS_NautyAvailable or
> G = DirectProduct(SymmetricGroup(m), SymmetricGroup(n));
true

# A small example
gap> gr := Digraph([[2], [], [2], [2]]);
<digraph with 4 vertices, 3 edges>
gap> AutomorphismGroup(gr) = SymmetricGroup([1, 3, 4]);
true
gap> not DIGRAPHS_NautyAvailable or
> NautyAutomorphismGroup(gr) = SymmetricGroup([1, 3, 4]);
true

#T# AutomorphismGroup: for a digraph with multiple edges

# An edge union of complete digraphs
gap> gr := DigraphEdgeUnion(CompleteDigraph(4), CompleteDigraph(4));
<multidigraph with 4 vertices, 24 edges>
gap> G := AutomorphismGroup(gr);;
gap> Image(Projection(G, 1)) = SymmetricGroup(4);
true
gap> StructureDescription(Image(Projection(G, 2)));
"C2 x C2 x C2 x C2 x C2 x C2 x C2 x C2 x C2 x C2 x C2"

# A small example
gap> gr := Digraph([[2], [1, 3], [], [3, 3]]);
<multidigraph with 4 vertices, 5 edges>
gap> G := AutomorphismGroup(gr);
Group([ (), (1,2) ])
gap> IsTrivial(Image(Projection(G, 1)));
true
gap> Image(Projection(G, 2));
Group([ (4,5) ])

# A larger example
gap> gr := Digraph([
>   [5, 7, 8, 4, 6, 1], [3, 1, 7, 2, 7, 9], [1, 5, 2, 3, 9],
>   [1, 3, 3, 9, 9], [6, 3, 5, 7, 9], [3, 9],
>   [8, 3, 6, 8, 8, 7, 7, 8, 9], [6, 1, 6, 7, 8, 4, 2, 5, 4],
>   [1, 5, 2, 3, 9]]);
<multidigraph with 9 vertices, 52 edges>
gap> G := AutomorphismGroup(gr);;
gap> Size(G);
3072
gap> Image(Projection(G, 1)) = Group((3, 9));
true
gap> Image(Projection(G, 2)) = Group([(21, 22), (34, 37), (35, 36), (39, 41),
> (44, 47), (9, 11)(33, 37, 34), (19, 20)(30, 34)(33, 37)]);
true
gap> BlissCanonicalLabelling(gr)
> = BlissCanonicalLabelling(DigraphCopy(gr));
true

#T# IsIsomorphicDigraph: for digraphs without multiple edges

# A small example
gap> gr := Digraph([[2], [], [2], [2]]);
<digraph with 4 vertices, 3 edges>
gap> gr = gr;
true
gap> IsIsomorphicDigraph(gr, gr);
true
gap> gr1 := OnDigraphs(gr, (1, 3, 4));
<digraph with 4 vertices, 3 edges>
gap> gr = gr1;
true
gap> IsIsomorphicDigraph(gr, gr1);
true
gap> gr2 := OnDigraphs(gr, (1, 3)(2, 4));
<digraph with 4 vertices, 3 edges>
gap> not DIGRAPHS_NautyAvailable or NautyCanonicalLabelling(gr2) = (1, 2, 3, 4);
true
gap> gr = gr2;
false
gap> IsIsomorphicDigraph(gr, gr2);
true
gap> gr3 := DigraphReverseEdge(gr, [4, 2]);
<digraph with 4 vertices, 3 edges>
gap> gr = gr3;
false
gap> IsIsomorphicDigraph(gr, gr3);
false

# Different number of edges
gap> gr4 := DigraphAddEdge(gr, [1, 3]);
<digraph with 4 vertices, 4 edges>
gap> gr = gr4;
false
gap> IsIsomorphicDigraph(gr, gr4);
false

# Different number of vertices
gap> gr5 := DigraphAddVertex(gr);
<digraph with 5 vertices, 3 edges>
gap> gr = gr5;
false
gap> IsIsomorphicDigraph(gr, gr5);
false

# A larger example
gap> gr := Digraph([
> [10], [4, 8], [3, 9], [7, 13, 16, 20], [5, 10, 14, 18], [14],
> [], [1, 6], [16], [6, 12], [8], [2, 14], [2, 12], [17],
> [4, 20], [1, 5, 6, 14, 18], [3], [5, 7], [4], [6, 11]]);
<digraph with 20 vertices, 38 edges>
gap> p := (1, 13, 3, 14, 18)(2, 12, 6, 15, 5, 17, 11, 9, 19, 10, 7, 16, 20, 4);
(1,13,3,14,18)(2,12,6,15,5,17,11,9,19,10,7,16,20,4)
gap> gr1 := OnDigraphs(gr, p);
<digraph with 20 vertices, 38 edges>
gap> gr = gr1;
false
gap> IsIsomorphicDigraph(gr, gr1);
true
gap> gr2 := OnDigraphs(gr, Transformation([1, 1]));
<digraph with 20 vertices, 38 edges>
gap> gr = gr2;
false
gap> IsIsomorphicDigraph(gr, gr2);
false

#T# IsIsomorphicDigraph: for digraphs with multiple edges

# Different number of vertices
gap> gr1 := Digraph([[1, 2, 3, 2], [1, 3], [3]]);
<multidigraph with 3 vertices, 7 edges>
gap> gr2 := Digraph([[1, 2, 3, 2], [1, 3], [3], []]);
<multidigraph with 4 vertices, 7 edges>
gap> IsIsomorphicDigraph(gr1, gr2);
false

# Different number of edges
gap> gr1 := Digraph([[1, 2, 3, 2], [1, 3], [3]]);
<multidigraph with 3 vertices, 7 edges>
gap> gr2 := Digraph([[1, 2, 3, 2], [1, 3], [3, 2]]);
<multidigraph with 3 vertices, 8 edges>
gap> IsIsomorphicDigraph(gr1, gr2);
false

# One MultiDigraph, one not MultiDigraph
gap> gr1 := Digraph([[1, 2, 3, 2], [1, 3], [3]]);
<multidigraph with 3 vertices, 7 edges>
gap> gr2 := Digraph([[1, 2, 3], [1, 2, 3], [3]]);
<digraph with 3 vertices, 7 edges>
gap> IsIsomorphicDigraph(gr1, gr2);
false

# A random example
gap> gr := Digraph([
>   [5, 7, 8, 4, 6, 1], [3, 1, 7, 2, 7, 9], [1, 5, 2, 3, 9],
>   [1, 3, 3, 9, 9], [6, 3, 5, 7, 9], [3, 9],
>   [8, 3, 6, 8, 8, 7, 7, 8, 9], [6, 1, 6, 7, 8, 4, 2, 5, 4],
>   [1, 5, 2, 3, 9]]);
<multidigraph with 9 vertices, 52 edges>
gap> IsIsomorphicDigraph(gr, gr);
true
gap> gr1 := OnDigraphs(gr, (3, 9)(1, 2, 7, 5));;
gap> IsIsomorphicDigraph(gr, gr1);
true
gap> gr2 := OnDigraphs(gr, (3, 9));;
gap> IsIsomorphicDigraph(gr, gr2);
true

#T# IsIsomorphicDigraph: for digraphs with colourings and without multiple edges
gap> gr1 := Digraph([[2, 2], [1]]);
<multidigraph with 2 vertices, 3 edges>
gap> gr2 := CompleteDigraph(2);
<digraph with 2 vertices, 2 edges>
gap> IsIsomorphicDigraph(gr1, gr2, [1, 1], [1, 1]);
false
gap> IsIsomorphicDigraph(gr2, gr1, [1, 1], [1, 1]);
false
gap> IsIsomorphicDigraph(gr1, gr1, [1, 1], [1, 1]);
true
gap> IsIsomorphicDigraph(gr2, gr2, [], [1, 1]);
Error, Digraphs: IsIsomorphicDigraph: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 2].
The list <partition> must have one of the following forms:
1. <partition> is a list of length 2 consisting of every integer in the range
   [1 .. m], for some m <= 2;
2. <partition> is a list of non-empty disjoint lists whose union is [1 .. 2].
In the first form, <partition[i]> is the colour of vertex i; in the second
form, <partition[i]> is the list of vertices with colour i,
gap> IsIsomorphicDigraph(gr2, gr2, [2, 2], []);
Error, Digraphs: IsIsomorphicDigraph: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 2],
since it contains the colour 2, but it lacks the colour 1. A colouring must
use precisely the colours [1 .. m], for some positive integer m <= 2,
gap> IsIsomorphicDigraph(EmptyDigraph(1), EmptyDigraph(2), [1], [1, 1]);
false
gap> IsIsomorphicDigraph(EmptyDigraph(1), Digraph([[1]]), [1], [1]);
false
gap> IsIsomorphicDigraph(EmptyDigraph(2), EmptyDigraph(2), [1, 1], [1, 2]);
false
gap> IsIsomorphicDigraph(EmptyDigraph(2), EmptyDigraph(2), [1, 1], [1, 1]);
true
gap> IsIsomorphicDigraph(gr2, gr2, [1, 1], [2, 2]);
Error, Digraphs: IsIsomorphicDigraph: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 2],
since it contains the colour 2, but it lacks the colour 1. A colouring must
use precisely the colours [1 .. m], for some positive integer m <= 2,
gap> IsIsomorphicDigraph(gr2, gr2, [1, 2], [2, 1]);
true
gap> gr1 := CycleDigraph(4);
<digraph with 4 vertices, 4 edges>
gap> gr2 := DigraphDisjointUnion(CycleDigraph(2), CycleDigraph(2));
<digraph with 4 vertices, 4 edges>
gap> IsIsomorphicDigraph(gr1, gr2, [1, 1, 1, 1], [1, 1, 1, 1]);
false
gap> IsIsomorphicDigraph(gr1, gr1, [1, 1, 2, 2], [1, 1, 1, 2]);
false

#T# IsIsomorphicDigraph: for multidigraphs with colourings
gap> gr1 := Digraph([[2, 1, 2], []]);;
gap> gr2 := Digraph([[], [2, 1, 1]]);;
gap> IsIsomorphicDigraph(gr1, gr1, [1, 1], [1, 1]);
true
gap> IsIsomorphicDigraph(gr1, gr1, [1, 1], [1, 2]);
false
gap> IsIsomorphicDigraph(gr1, gr2, [1, 2], [2, 1]);
true
gap> IsIsomorphicDigraph(gr1, gr2, [1, 2], [1, 2]);
false

#T# IsomorphismDigraphs: for digraphs without multiple edges

# Non-isomorphic graphs
gap> gr1 := EmptyDigraph(3);
<digraph with 3 vertices, 0 edges>
gap> gr2 := ChainDigraph(3);
<digraph with 3 vertices, 2 edges>
gap> IsomorphismDigraphs(gr1, gr2);
fail
gap> IsomorphismDigraphs(gr2, gr1);
fail
gap> IsIsomorphicDigraph(gr1, gr2);
false

# A small example: check that all isomorphic copies give correct answer
gap> gr := Digraph([[3], [2, 3, 4], [1, 3], [], [1, 4]]);
<digraph with 5 vertices, 8 edges>
gap> IsomorphismDigraphs(gr, gr);
()
gap> not DIGRAPHS_NautyAvailable or NautyCanonicalLabelling(gr) = (1, 2, 5, 4);
true
gap> for i in SymmetricGroup(DigraphNrVertices(gr)) do
>   new := OnDigraphs(gr, i);
>   if not IsomorphismDigraphs(gr, new) = i
>       and IsomorphismDigraphs(new, gr) = i ^ -1 then
>     Print("fail");
>   fi;
> od;

# A small example: check that all isomorphic copies give correct answer
gap> gr := Digraph([[3], [2, 3, 4], [1, 3], [], [1, 4]]);
<digraph with 5 vertices, 8 edges>
gap> IsomorphismDigraphs(gr, gr);
()
gap> for i in SymmetricGroup(DigraphNrVertices(gr)) do
>   new := OnDigraphs(gr, i);
>   if not IsomorphismDigraphs(gr, new) = i
>       and IsomorphismDigraphs(new, gr) = i ^ -1 then
>     Print("fail");
>   fi;
> od;

# Test for line 376 of isomorph.gi
gap> gr1 := Digraph([[], [2, 3, 4], [1, 3], []]);;
gap> gr2 := OnDigraphs(gr1, (1, 2, 3));;
gap> gr1 <> gr2;
true
gap> IsMultiDigraph(gr1);
false
gap> not DIGRAPHS_NautyAvailable or NautyCanonicalLabelling(gr1) = (1, 2, 4);
true
gap> HasBlissCanonicalLabelling(gr1) and HasBlissCanonicalLabelling(gr2);
false
gap> not DIGRAPHS_NautyAvailable or HasNautyCanonicalLabelling(gr1) and
> NautyCanonicalLabelling(gr1) <> fail;
true
gap> not DIGRAPHS_NautyAvailable or not HasNautyCanonicalLabelling(gr2);
true
gap> IsomorphismDigraphs(gr1, gr2);;

#T# IsomorphismDigraphs: for digraphs with multiple edges

# An example used in previous tests
gap> gr := Digraph([
>   [5, 7, 8, 4, 6, 1], [3, 1, 7, 2, 7, 9], [1, 5, 2, 3, 9],
>   [1, 3, 3, 9, 9], [6, 3, 5, 7, 9], [3, 9],
>   [8, 3, 6, 8, 8, 7, 7, 8, 9], [6, 1, 6, 7, 8, 4, 2, 5, 4],
>   [1, 5, 2, 3, 9]]);
<multidigraph with 9 vertices, 52 edges>
gap> IsomorphismDigraphs(gr, gr);
[ (), () ]
gap> BlissCanonicalLabelling(gr);
[ (1,5,4,2,3,7,9,6), (1,30,49)(2,34,47,35,45,39,38,51,8,12,18,24,21,28,23,13,
    4,29,22,27,20,25,14)(3,33,48)(5,31,52,7,19,26,17,9,16,10,11,15,6,32,
    50)(36,44)(37,46,40,41)(42,43) ]
gap> NautyCanonicalLabelling(gr);
fail
gap> AutomorphismGroup(gr);
<permutation group with 10 generators>
gap> p := (1, 8, 2)(3, 5, 4, 9, 7);;
gap> gr1 := OnDigraphs(gr, p);
<multidigraph with 9 vertices, 52 edges>
gap> iso := IsomorphismDigraphs(gr, gr1);
[ (1,8,2)(3,5,4,9,7), (1,42,10,4,45,13,30,16,33,19,49,38,24,26,28,35,21,51,40,
    8,2,43,11,5,46,14,31,17,34,20,50,39,7)(3,44,12,6,47,15,32,18,48,37,23,25,
    27,29,36,22,52,41,9) ]
gap> OnMultiDigraphs(gr, iso) = gr1;
true
gap> iso[1] = p;
true
gap> p := (1, 7, 8, 4)(2, 6, 5);;
gap> gr1 := OnDigraphs(gr, p);
<multidigraph with 9 vertices, 52 edges>
gap> iso := IsomorphismDigraphs(gr, gr1);
[ (1,7,8,4)(2,6,5), (1,33,42,19,2,34,43,20,3,35,44,21,4,36,45,22,5,37,46,23,6,
    38,47,24,7,27,10,30,39,16,14,12,32,41,18)(8,28,25)(9,29,26)(11,31,40,17,
    15,13) ]
gap> OnMultiDigraphs(gr, iso) = gr1;
true
gap> iso[1] = p;
true

#T# IsomorphismDigraphs: for digraphs with colourings and without multiple edges
gap> gr1 := Digraph([[2, 2], [1]]);
<multidigraph with 2 vertices, 3 edges>
gap> gr2 := CompleteDigraph(2);
<digraph with 2 vertices, 2 edges>
gap> IsomorphismDigraphs(gr1, gr2, [1, 1], [1, 1]);
fail
gap> IsomorphismDigraphs(gr2, gr1, [1, 1], [1, 1]);
fail
gap> IsomorphismDigraphs(gr1, gr1, [1, 1], [1, 1]);
[ (), () ]
gap> IsomorphismDigraphs(gr2, gr2, [], [1, 1]);
Error, Digraphs: IsomorphismDigraphs: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 2].
The list <partition> must have one of the following forms:
1. <partition> is a list of length 2 consisting of every integer in the range
   [1 .. m], for some m <= 2;
2. <partition> is a list of non-empty disjoint lists whose union is [1 .. 2].
In the first form, <partition[i]> is the colour of vertex i; in the second
form, <partition[i]> is the list of vertices with colour i,
gap> IsomorphismDigraphs(gr2, gr2, [2, 2], []);
Error, Digraphs: IsomorphismDigraphs: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 2],
since it contains the colour 2, but it lacks the colour 1. A colouring must
use precisely the colours [1 .. m], for some positive integer m <= 2,
gap> IsomorphismDigraphs(EmptyDigraph(1), EmptyDigraph(2), [1], [1, 1]);
fail
gap> IsomorphismDigraphs(EmptyDigraph(1), Digraph([[1]]), [1], [1]);
fail
gap> IsomorphismDigraphs(EmptyDigraph(2), EmptyDigraph(2), [1, 1], [1, 2]);
fail
gap> IsomorphismDigraphs(EmptyDigraph(2), EmptyDigraph(2), [1, 1], [1, 1]);
()
gap> IsomorphismDigraphs(gr2, gr2, [1, 1], [[1, 2]]);
()
gap> IsomorphismDigraphs(gr2, gr2, [1, 2], [2, 1]);
(1,2)
gap> gr1 := CycleDigraph(4);
<digraph with 4 vertices, 4 edges>
gap> gr2 := DigraphDisjointUnion(CycleDigraph(2), CycleDigraph(2));
<digraph with 4 vertices, 4 edges>
gap> IsomorphismDigraphs(gr1, gr2, [1, 1, 1, 1], [1, 1, 1, 1]);
fail
gap> gr1 := CompleteDigraph(3);;
gap> IsomorphismDigraphs(gr1, gr1, [1, 2, 2], [[1, 3], [2]]);
fail

#T# IsomorphismDigraphs: for multidigraphs with colourings
gap> gr1 := Digraph([[2, 1, 2], []]);;
gap> gr2 := Digraph([[], [2, 1, 1]]);;
gap> IsomorphismDigraphs(gr1, gr1, [1, 1], [1, 1]);
[ (), () ]
gap> IsomorphismDigraphs(gr1, gr1, [1, 1], [1, 2]);
fail
gap> IsomorphismDigraphs(gr1, gr2, [1, 2], [2, 1]);
[ (1,2), (1,2) ]
gap> IsomorphismDigraphs(gr1, gr2, [1, 2], [1, 2]);
fail
gap> IsomorphismDigraphs(gr1, gr2, [1, 1], [1, 1]);
[ (1,2), (1,2) ]

#T# CanonicalLabelling: for a digraph without multiple edges

# A small example: check that all isomorphic copies have same canonical image
gap> gr := Digraph([[2], [3, 5, 6], [3], [4, 6], [1, 4], [4]]);
<digraph with 6 vertices, 10 edges>
gap> BlissCanonicalLabelling(gr);
(1,2,4,6,5,3)
gap> not DIGRAPHS_NautyAvailable or NautyCanonicalLabelling(gr) =
> (1, 3, 2, 6)(4, 5);
true
gap> canon := OutNeighbours(BlissCanonicalDigraph(gr));
[ [ 1 ], [ 4 ], [ 2, 6 ], [ 1, 3, 5 ], [ 6 ], [ 6, 5 ] ]
gap> for i in SymmetricGroup(DigraphNrVertices(gr)) do
>   new := OnDigraphs(gr, i);
>   if not OutNeighbours(OnDigraphs(new, BlissCanonicalLabelling(new))) =
>       canon then
>     Print("fail\n");
>   fi;
> od;
gap> gr1 := DigraphReverseEdge(gr, [2, 5]);
<digraph with 6 vertices, 10 edges>
gap> gr = gr1;
false
gap> IsIsomorphicDigraph(gr, gr1);
false
gap> canon = OnDigraphs(gr1, BlissCanonicalLabelling(gr1));
false
gap> canon := NautyCanonicalDigraph(gr);;
gap> canon = fail or OutNeighbours(canon)
>    = [[5], [2], [6], [3, 5], [5, 1], [2, 4, 1]];
true
gap> if canon <> fail then
>   for i in SymmetricGroup(DigraphNrVertices(gr)) do
>     new := OnDigraphs(gr, i);
>     if OnDigraphs(new, NautyCanonicalLabelling(new)) <> canon then
>       Print("fail\n");
>     fi;
>   od;
> fi;

#T# CanonicalLabelling: for a digraph with multiple edges

# A small example: check that all isomorphic copies have same canonical image
gap> gr := Digraph([[2, 2], [1, 1], [2]]);
<multidigraph with 3 vertices, 5 edges>
gap> BlissCanonicalLabelling(gr);
[ (1,2,3), (1,3,5) ]
gap> canon := OutNeighbours(OnMultiDigraphs(gr, last));
[ [ 3 ], [ 3, 3 ], [ 2, 2 ] ]
gap> for i in SymmetricGroup(DigraphNrVertices(gr)) do
> for j in SymmetricGroup(DigraphNrEdges(gr)) do
>   new := OnMultiDigraphs(gr, [i, j]);
>   if not OutNeighbours(OnMultiDigraphs(new,
>       BlissCanonicalLabelling(new))) = canon then
>     Print("fail");
>   fi;
> od; od;
gap> gr1 := Digraph([[2, 2], [1, 3], [2]]);
<multidigraph with 3 vertices, 5 edges>
gap> gr = gr1;
false
gap> IsIsomorphicDigraph(gr, gr1);
false
gap> canon = OnMultiDigraphs(gr1, BlissCanonicalLabelling(gr1));
false
gap> NautyCanonicalLabelling(gr);
fail

#T# CanonicalLabelling: with colours
gap> G := Digraph(10, [1, 1, 3, 4, 4, 5, 8, 8], [6, 3, 3, 9, 10, 9, 4, 10]);;
gap> BlissCanonicalLabelling(G, [[1 .. 5], [6 .. 10]]);
(1,4,3,5)(6,8)(7,9,10)
gap> not DIGRAPHS_NautyAvailable or
> NautyCanonicalLabelling(G, [[1 .. 5], [6 .. 10]])
> = (1, 5, 3, 4)(6, 8, 10)(7, 9);
true
gap> BlissCanonicalLabelling(G, [1, 1, 1, 1, 1, 2, 2, 2, 2, 2]);
(1,4,3,5)(6,8)(7,9,10)
gap> not DIGRAPHS_NautyAvailable or
> NautyCanonicalLabelling(G, [1, 1, 1, 1, 1, 2, 2, 2, 2, 2])
> = (1, 5, 3, 4)(6, 8, 10)(7, 9);
true

#T# AutomorphismGroup: for a digraph with colored vertices
gap> gr := CompleteBipartiteDigraph(4, 4);
<digraph with 8 vertices, 32 edges>
gap> AutomorphismGroup(gr) = Group([
> (7, 8), (6, 7), (5, 6), (3, 4), (2, 3), (1, 2), (1, 5)(2, 6)(3, 7)(4, 8)]);
true
gap> AutomorphismGroup(gr, [[1 .. 4], [5 .. 8]]);
Group([ (7,8), (6,7), (5,6), (3,4), (2,3), (1,2) ])
gap> AutomorphismGroup(gr, [1 .. 8]);
Group(())

#T# AutomorphismGroup: for a digraph with incorrect colors
gap> gr := CompleteBipartiteDigraph(4, 4);
<digraph with 8 vertices, 32 edges>
gap> AutomorphismGroup(gr, [[1 .. 4], [5 .. 9]]);
Error, Digraphs: AutomorphismGroup: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 8],
since <partition[i]> contains <x>, which is not an integer in the range
[1 .. 8],
gap> AutomorphismGroup(gr, ["a", "b"]);
Error, Digraphs: AutomorphismGroup: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 8],
since <partition[i]> contains <x>, which is not an integer in the range
[1 .. 8],
gap> AutomorphismGroup(gr, [1 .. 10]);
Error, Digraphs: AutomorphismGroup: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 8].
The list <partition> must have one of the following forms:
1. <partition> is a list of length 8 consisting of every integer in the range
   [1 .. m], for some m <= 8;
2. <partition> is a list of non-empty disjoint lists whose union is [1 .. 8].
In the first form, <partition[i]> is the colour of vertex i; in the second
form, <partition[i]> is the list of vertices with colour i,
gap> AutomorphismGroup(gr, [-1 .. -10]);
Error, Digraphs: AutomorphismGroup: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 8].
The list <partition> must have one of the following forms:
1. <partition> is a list of length 8 consisting of every integer in the range
   [1 .. m], for some m <= 8;
2. <partition> is a list of non-empty disjoint lists whose union is [1 .. 8].
In the first form, <partition[i]> is the colour of vertex i; in the second
form, <partition[i]> is the list of vertices with colour i,

#T# AutomorphismGroup: for a multidigraph
gap> gr := Digraph([[2, 2], []]);
<multidigraph with 2 vertices, 2 edges>
gap> AutomorphismGroup(gr, [1, 2]);
Group([ (), (1,2) ])
gap> NautyAutomorphismGroup(gr);
fail
gap> NautyAutomorphismGroup(gr, [1, 2]);
fail

#T# CanonicalLabelling: for a digraph with colored vertices
gap> gr := CompleteBipartiteDigraph(4, 4);
<digraph with 8 vertices, 32 edges>
gap> BlissCanonicalLabelling(gr);
(1,8)(2,7)(3,6)(4,5)
gap> not DIGRAPHS_NautyAvailable
> or NautyCanonicalLabelling(gr) = (2, 6, 3, 7, 4, 8, 5);
true
gap> BlissCanonicalLabelling(gr, [1 .. 8]);
()
gap> not DIGRAPHS_NautyAvailable
> or NautyCanonicalLabelling(gr, [1 .. 8]) = ();
true
gap> BlissCanonicalLabelling(gr, [[1 .. 4], [5 .. 8]]);
(1,4)(2,3)(5,8)(6,7)
gap> not DIGRAPHS_NautyAvailable
> or NautyCanonicalLabelling(gr, [[1 .. 4], [5 .. 8]]) = ();
true

#T# CanonicalLabelling: for a digraph with incorrect colors
gap> gr := CompleteBipartiteDigraph(4, 4);
<digraph with 8 vertices, 32 edges>
gap> BlissCanonicalLabelling(gr, [[1 .. 4], [5 .. 9]]);
Error, Digraphs: BlissCanonicalLabelling: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 8],
since <partition[i]> contains <x>, which is not an integer in the range
[1 .. 8],
gap> BlissCanonicalLabelling(gr, ["a", "b"]);
Error, Digraphs: BlissCanonicalLabelling: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 8],
since <partition[i]> contains <x>, which is not an integer in the range
[1 .. 8],
gap> BlissCanonicalLabelling(gr, [1 .. 10]);
Error, Digraphs: BlissCanonicalLabelling: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 8].
The list <partition> must have one of the following forms:
1. <partition> is a list of length 8 consisting of every integer in the range
   [1 .. m], for some m <= 8;
2. <partition> is a list of non-empty disjoint lists whose union is [1 .. 8].
In the first form, <partition[i]> is the colour of vertex i; in the second
form, <partition[i]> is the list of vertices with colour i,
gap> BlissCanonicalLabelling(gr, [-1 .. -10]);
Error, Digraphs: BlissCanonicalLabelling: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 8].
The list <partition> must have one of the following forms:
1. <partition> is a list of length 8 consisting of every integer in the range
   [1 .. m], for some m <= 8;
2. <partition> is a list of non-empty disjoint lists whose union is [1 .. 8].
In the first form, <partition[i]> is the colour of vertex i; in the second
form, <partition[i]> is the list of vertices with colour i,

#T# CanonicalLabelling: for a multidigraph
gap> gr := Digraph([[2, 2], []]);
<multidigraph with 2 vertices, 2 edges>
gap> BlissCanonicalLabelling(gr, [1, 2]);
[ (), (1,2) ]
gap> NautyCanonicalLabelling(gr, [1, 2]);
fail

#T# DIGRAPHS_ValidateVertexColouring, 1, errors
gap> DIGRAPHS_ValidateVertexColouring();
Error, Function: number of arguments must be 3 (not 0)
gap> DIGRAPHS_ValidateVertexColouring(fail);
Error, Function: number of arguments must be 3 (not 1)
gap> DIGRAPHS_ValidateVertexColouring(fail, fail);
Error, Function: number of arguments must be 3 (not 2)
gap> DIGRAPHS_ValidateVertexColouring(0, fail, "TestFunction");
Error, Digraphs: TestFunction: usage,
in order to define a colouring, the argument <partition> must be a homogeneous
list,
gap> DIGRAPHS_ValidateVertexColouring(fail, [], "TestFunction");
Error, Digraphs: DIGRAPHS_ValidateVertexColouring: usage,
the first argument <n> must be a non-negative integer,
gap> DIGRAPHS_ValidateVertexColouring(0, [], fail);
Error, Digraphs: DIGRAPHS_ValidateVertexColouring: usage,
the third argument <method> must be a string,

#T# DIGRAPHS_ValidateVertexColouring, 2
gap> DIGRAPHS_ValidateVertexColouring(0, [], "TestFunction");
[  ]
gap> DIGRAPHS_ValidateVertexColouring(0, [2], "TestFunction");
Error, Digraphs: TestFunction: usage,
the only valid partition of the vertices of the digraph with 0 vertices is the
empty list,
gap> DIGRAPHS_ValidateVertexColouring(1, [], "TestFunction");
Error, Digraphs: TestFunction: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 1].
The list <partition> must have one of the following forms:
1. <partition> is a list of length 1 consisting of every integer in the range
   [1 .. m], for some m <= 1;
2. <partition> is a list of non-empty disjoint lists whose union is [1 .. 1].
In the first form, <partition[i]> is the colour of vertex i; in the second
form, <partition[i]> is the list of vertices with colour i,
gap> DIGRAPHS_ValidateVertexColouring(1, [fail], "TestFunction");
Error, Digraphs: TestFunction: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 1].
The list <partition> must have one of the following forms:
1. <partition> is a list of length 1 consisting of every integer in the range
   [1 .. m], for some m <= 1;
2. <partition> is a list of non-empty disjoint lists whose union is [1 .. 1].
In the first form, <partition[i]> is the colour of vertex i; in the second
form, <partition[i]> is the list of vertices with colour i,
gap> DIGRAPHS_ValidateVertexColouring(1, [1, 1], "TestFunction");
Error, Digraphs: TestFunction: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 1].
The list <partition> must have one of the following forms:
1. <partition> is a list of length 1 consisting of every integer in the range
   [1 .. m], for some m <= 1;
2. <partition> is a list of non-empty disjoint lists whose union is [1 .. 1].
In the first form, <partition[i]> is the colour of vertex i; in the second
form, <partition[i]> is the list of vertices with colour i,
gap> DIGRAPHS_ValidateVertexColouring(2, [1, -1], "TestFunction");
Error, Digraphs: TestFunction: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 2],
since it contains the element <i>, which is not a positive integer,
gap> DIGRAPHS_ValidateVertexColouring(2, [2, 3], "TestFunction");
Error, Digraphs: TestFunction: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 2],
since it contains the integer 3, which is greater than 2,
gap> DIGRAPHS_ValidateVertexColouring(2, [2, 0], "TestFunction");
Error, Digraphs: TestFunction: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 2],
since it contains the element <i>, which is not a positive integer,
gap> DIGRAPHS_ValidateVertexColouring(2, [[]], "TestFunction");
Error, Digraphs: TestFunction: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 2],
since it does not assign a colour to the vertex 1,
gap> DIGRAPHS_ValidateVertexColouring(1, [[1, 1]], "TestFunction");
Error, Digraphs: TestFunction: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 1],
since it contains the vertex 1 more than once,
gap> DIGRAPHS_ValidateVertexColouring(1, [[0, 1]], "TestFunction");
Error, Digraphs: TestFunction: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 1],
since <partition[i]> contains <x>, which is not an integer in the range
[1 .. 1],
gap> DIGRAPHS_ValidateVertexColouring(1, [[2]], "TestFunction");
Error, Digraphs: TestFunction: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 1],
since <partition[i]> contains <x>, which is not an integer in the range
[1 .. 1],
gap> DIGRAPHS_ValidateVertexColouring(4, [[3], [2, 1], [4]], "TestFunction");
[ 2, 2, 1, 3 ]
gap> DIGRAPHS_ValidateVertexColouring(4, [1, 1, 3, 4], "TestFunction");
Error, Digraphs: TestFunction: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 4],
since it contains the colour 4, but it lacks the colour 2. A colouring must
use precisely the colours [1 .. m], for some positive integer m <= 4,
gap> DIGRAPHS_ValidateVertexColouring(4, [1, 1, 3, 2], "TestFunction");
[ 1, 1, 3, 2 ]

#T# CanonicalDigraph
gap> gr1 := Digraph([[1, 2], [1, 2], [2, 3], [1, 2, 3], [5]]);;
gap> gr2 := Digraph([[1, 3], [2, 3], [2, 3], [1, 2, 3], [5]]);;
gap> BlissCanonicalDigraph(gr1) = BlissCanonicalDigraph(gr2);
true
gap> gr3 := Digraph([[2, 3], [2, 3], [1, 3], [1, 2, 3], [5]]);;
gap> BlissCanonicalDigraph(gr1) = BlissCanonicalDigraph(gr3);
false
gap> BlissCanonicalDigraph(gr3, [1, 1, 1, 1, 1]);
<digraph with 5 vertices, 10 edges>
gap> BlissCanonicalDigraph(Digraph([[1], [2], [3], [3], [2], [1]]))
> = BlissCanonicalDigraph(Digraph([[1], [2], [3], [1], [2], [3]]));
true
gap> gr4 := Digraph([[3, 4], [2, 2, 3], [2, 2, 4], [2, 2, 3]]);;
gap> gr5 := BlissCanonicalDigraph(gr4);;
gap> gr5 = gr4;
false
gap> IsIsomorphicDigraph(gr4, gr5);
true
gap> gr5 = BlissCanonicalDigraph(gr4, [1, 1, 1, 1]);
true
gap> BlissCanonicalDigraph(gr4, [1, 2, 1, 2])
> = BlissCanonicalDigraph(gr4, [[1, 3], [2, 4]]);
true
gap> gr5 = BlissCanonicalDigraph(gr5);
true
gap> gr6 := OnMultiDigraphs(gr4, [(1, 2), (5, 6)]);;
gap> IsIsomorphicDigraph(gr4, gr6);
true
gap> gr5 = BlissCanonicalDigraph(gr6);
true

#T# CanonicalDigraph
gap> gr1 := Digraph([[1, 2], [1, 2], [2, 3], [1, 2, 3], [5]]);;
gap> gr2 := Digraph([[1, 3], [2, 3], [2, 3], [1, 2, 3], [5]]);;
gap> NautyCanonicalDigraph(gr1) = NautyCanonicalDigraph(gr2);
true
gap> gr3 := Digraph([[2, 3], [2, 3], [1, 3], [1, 2, 3], [5]]);;
gap> not DIGRAPHS_NautyAvailable or
> NautyCanonicalDigraph(gr1) <> NautyCanonicalDigraph(gr3);
true
gap> gr7 := NautyCanonicalDigraph(gr3, [1, 1, 1, 1, 1]);;
gap> not DIGRAPHS_NautyAvailable or
> NautyCanonicalDigraph(gr3, [1, 2, 1, 2, 1])
> = NautyCanonicalDigraph(gr3, [[1, 3, 5], [2, 4]]);
true
gap> gr7 = fail or gr7 = NautyCanonicalDigraph(gr7);
true
gap> not DIGRAPHS_NautyAvailable or
> NautyCanonicalDigraph(Digraph([[1], [2], [3], [3], [2], [1]]))
> = NautyCanonicalDigraph(Digraph([[1], [2], [3], [1], [2], [3]]));
true
gap> gr4 := Digraph([[3, 4], [2, 2, 3], [2, 2, 4], [2, 2, 3]]);;
gap> gr5 := NautyCanonicalDigraph(gr4);
fail
gap> gr5 := NautyCanonicalDigraph(gr4, [1, 2, 3, 4]);
fail

# Issue 111
gap> not DIGRAPHS_NautyAvailable or
> NautyAutomorphismGroup(NullDigraph(0)) = Group(());
true

# DigraphsUseBliss/Nauty
gap> nauty := not DIGRAPHS_UsingBliss;;
gap> DigraphsUseNauty();
gap> DigraphsUseBliss();
gap> p := DIGRAPHS_NautyAvailable;;
gap> MakeReadWriteGlobal("DIGRAPHS_NautyAvailable");
gap> DIGRAPHS_NautyAvailable := false;;
gap> DigraphsUseNauty();
gap> DIGRAPHS_NautyAvailable := p;;
gap> MakeReadOnlyGlobal("DIGRAPHS_NautyAvailable");
gap> if not nauty then
>      DigraphsUseBliss();
>    fi;

# IsDigraphAutomorphism, for digraph and permutation
gap> gr1 := Digraph([[1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1]]);
<digraph with 4 vertices, 13 edges>
gap> IsDigraphAutomorphism(gr1, (1, 2, 3));
false
gap> IsDigraphAutomorphism(gr1, (2, 3));
true
gap> IsDigraphAutomorphism(gr1, ());
true
gap> gr2 := Digraph([[1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 2, 3, 4, 5, 6]]);
<digraph with 6 vertices, 15 edges>
gap> IsDigraphAutomorphism(gr2, (2, 3, 4, 5));
true
gap> IsDigraphAutomorphism(gr2, (1, 6));
false
gap> IsDigraphAutomorphism(gr2, (2, 3, 6));
false
gap> IsDigraphAutomorphism(Digraph([[1, 1], [1, 1, 2], [1, 2, 2, 3]]), ());
Error, Digraphs: IsDigraphIsomorphism: usage,
the first 2 arguments must not have multiple edges,

# IsDigraphAutomorphism, for digraph and transformation
gap> gr1 := Digraph([[1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1]]);
<digraph with 4 vertices, 13 edges>
gap> IsDigraphAutomorphism(gr1, AsTransformation((1, 2, 3)));
false
gap> IsDigraphAutomorphism(gr1, AsTransformation((2, 3)));
true
gap> IsDigraphAutomorphism(gr1, AsTransformation(()));
true
gap> gr2 := Digraph([[1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 2, 3, 4, 5, 6]]);
<digraph with 6 vertices, 15 edges>
gap> IsDigraphAutomorphism(gr2, AsTransformation((2, 3, 4, 5)));
true
gap> IsDigraphAutomorphism(gr2, AsTransformation((1, 6)));
false
gap> IsDigraphAutomorphism(gr2, AsTransformation((2, 3, 6)));
false
gap> IsDigraphAutomorphism(gr2, Transformation([1, 1, 2, 3]));
false
gap> IsDigraphAutomorphism(Digraph([[1, 1], [1, 1, 2], [1, 2, 2, 3]]),
> AsTransformation(()));
Error, Digraphs: IsDigraphIsomorphism: usage,
the first 2 arguments must not have multiple edges,

#T# DIGRAPHS_UnbindVariables
gap> Unbind(G);
gap> Unbind(canon);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(gr3);
gap> Unbind(gr4);
gap> Unbind(gr5);
gap> Unbind(i);
gap> Unbind(iso);
gap> Unbind(j);
gap> Unbind(m);
gap> Unbind(n);
gap> Unbind(p);

#E#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/isomorph.tst", 0);
