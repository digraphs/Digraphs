#############################################################################
##
#W  standard/bliss.tst
#Y  Copyright (C) 2015                                   Wilfred A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/bliss.tst");
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

# Empty digraph on n vertices should have automorphism group S_n
gap> n := 10;;
gap> gr := EmptyDigraph(n);
<digraph with 10 vertices, 0 edges>
gap> AutomorphismGroup(gr) = SymmetricGroup(n);
true

# Chain digraph on n vertices should have trivial automorphism group
gap> n := 5;;
gap> gr := ChainDigraph(n);
<digraph with 5 vertices, 4 edges>
gap> IsTrivial(AutomorphismGroup(gr));
true

# Cycle digraph on n vertices should have cyclic automorphism group C_n
gap> n := 5;;
gap> gr := CycleDigraph(n);
<digraph with 5 vertices, 5 edges>
gap> IsCyclic(AutomorphismGroup(gr));
true
gap> Size(AutomorphismGroup(gr)) = n;
true

# Complete bipartitite graph with parts of size m and n
# shoud have automorphism group S_m x S_n
gap> m := 5;; n := 4;;
gap> gr := CompleteBipartiteDigraph(m, n);
<digraph with 9 vertices, 40 edges>
gap> G := AutomorphismGroup(gr);;
gap> G = DirectProduct(SymmetricGroup(m), SymmetricGroup(n));
true

# A small example
gap> gr := Digraph([[2], [], [2], [2]]);
<digraph with 4 vertices, 3 edges>
gap> AutomorphismGroup(gr) = SymmetricGroup([1, 3, 4]);
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
gap> DigraphCanonicalLabelling(gr)
> = DigraphCanonicalLabelling(DigraphCopy(gr));
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
gap> for i in SymmetricGroup(DigraphNrVertices(gr)) do
>   new := OnDigraphs(gr, i);
>   if not IsomorphismDigraphs(gr, new) = i
>       and IsomorphismDigraphs(new, gr) = i ^ -1 then
>     Print("fail");
>   fi;
> od;

#T# IsomorphismDigraphs: for digraphs with multiple edges

# An example used in previous tests
gap> gr := Digraph([
>   [5, 7, 8, 4, 6, 1], [3, 1, 7, 2, 7, 9], [1, 5, 2, 3, 9],
>   [1, 3, 3, 9, 9], [6, 3, 5, 7, 9], [3, 9],
>   [8, 3, 6, 8, 8, 7, 7, 8, 9], [6, 1, 6, 7, 8, 4, 2, 5, 4],
>   [1, 5, 2, 3, 9]]);
<multidigraph with 9 vertices, 52 edges>
gap> DigraphCanonicalLabelling(gr);
[ (1,5,4,2,3,7,9,6), (1,30,49)(2,34,47,35,45,39,38,51,8,12,18,24,21,28,23,13,
    4,29,22,27,20,25,14)(3,33,48)(5,31,52,7,19,26,17,9,16,10,11,15,6,32,
    50)(36,44)(37,46,40,41)(42,43) ]
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

#T# DigraphCanonicalLabelling: for a digraph without multiple edges

# A small example: check that all isomorphic copies have same canonical image
gap> gr := Digraph([[2], [3, 5, 6], [3], [4, 6], [1, 4], [4]]);
<digraph with 6 vertices, 10 edges>
gap> DigraphCanonicalLabelling(gr);
(2,5,4,6,3)
gap> canon := OutNeighbours(OnDigraphs(gr, last));
[ [ 5 ], [ 2 ], [ 6 ], [ 1, 6 ], [ 2, 4, 3 ], [ 6, 3 ] ]
gap> for i in SymmetricGroup(DigraphNrVertices(gr)) do
>   new := OnDigraphs(gr, i);
>   if not OutNeighbours(OnDigraphs(new, DigraphCanonicalLabelling(new))) =
>       canon then
>     Print("fail");
>   fi;
> od;
gap> gr1 := DigraphReverseEdge(gr, [2, 5]);
<digraph with 6 vertices, 10 edges>
gap> gr = gr1;
false
gap> IsIsomorphicDigraph(gr, gr1);
false
gap> canon = OnDigraphs(gr1, DigraphCanonicalLabelling(gr1));
false

#T# DigraphCanonicalLabelling: for a digraph with multiple edges

# A small example: check that all isomorphic copies have same canonical image
gap> gr := Digraph([[2, 2], [1, 1], [2]]);
<multidigraph with 3 vertices, 5 edges>
gap> DigraphCanonicalLabelling(gr);
[ (1,2,3), (1,3,5) ]
gap> canon := OutNeighbours(OnMultiDigraphs(gr, last));
[ [ 3 ], [ 3, 3 ], [ 2, 2 ] ]
gap> for i in SymmetricGroup(DigraphNrVertices(gr)) do
> for j in SymmetricGroup(DigraphNrEdges(gr)) do
>   new := OnMultiDigraphs(gr, [i, j]);
>   if not OutNeighbours(OnMultiDigraphs(new,
>       DigraphCanonicalLabelling(new))) = canon then
>     Print("fail");
>   fi;
> od; od;
gap> gr1 := Digraph([[2, 2], [1, 3], [2]]);
<multidigraph with 3 vertices, 5 edges>
gap> gr = gr1;
false
gap> IsIsomorphicDigraph(gr, gr1);
false
gap> canon = OnMultiDigraphs(gr1, DigraphCanonicalLabelling(gr1));
false

#T# DigraphCanonicalLabelling: with colours
gap> G := Digraph(10, [1, 1, 3, 4, 4, 5, 8, 8], [6, 3, 3, 9, 10, 9, 4, 10]);;
gap> DigraphCanonicalLabelling(G, [[1 .. 5], [6 .. 10]]);
(1,3,5,2)(6,7)(8,9,10)
gap> DigraphCanonicalLabelling(G, [1, 1, 1, 1, 1, 2, 2, 2, 2, 2]);
(1,3,5,2)(6,7)(8,9,10)

#T# AutomorphismGroup: for a digraph with colored vertices
gap> gr := CompleteBipartiteDigraph(4, 4);
<digraph with 8 vertices, 32 edges>
gap> AutomorphismGroup(gr);
Group([ (7,8), (6,7), (5,6), (3,4), (2,3), (1,2), (1,5)(2,6)(3,7)(4,8) ])
gap> AutomorphismGroup(gr, [[1 .. 4], [5 .. 8]]);
Group([ (7,8), (6,7), (5,6), (3,4), (2,3), (1,2) ])
gap> AutomorphismGroup(gr, [1 .. 8]);
Group(())

#T# AutomorphismGroup: for a digraph with incorrect colors
gap> gr := CompleteBipartiteDigraph(4, 4);
<digraph with 8 vertices, 32 edges>
gap> AutomorphismGroup(gr, [[1 .. 4], [5 .. 9]]);
Error, Digraphs: AutomorphismGroup: usage,
the union of the lists in the second arg should equal [1 .. 8],
gap> AutomorphismGroup(gr, ["a", "b"]);
Error, Digraphs: AutomorphismGroup: usage,
the union of the lists in the second arg should equal [1 .. 8],
gap> AutomorphismGroup(gr, [1 .. 10]);
Error, Digraphs: AutomorphismGroup: usage,
the second arg must be a list of length 8 of integers in [1 .. 8],
gap> AutomorphismGroup(gr, [-1 .. -10]);
Error, Digraphs: AutomorphismGroup: usage,
the second arg must be a list of length 8 of integers in [1 .. 8],

#T# AutomorphismGroup: for a multidigraph
gap> gr := Digraph([[2, 2], []]);
<multidigraph with 2 vertices, 2 edges>
gap> AutomorphismGroup(gr, [1, 2]);
fail

#T# DigraphCanonicalLabelling: for a digraph with colored vertices
gap> gr := CompleteBipartiteDigraph(4, 4);
<digraph with 8 vertices, 32 edges>
gap> DigraphCanonicalLabelling(gr);
(1,8)(2,6,3,5,7)
gap> DigraphCanonicalLabelling(gr, [1 .. 8]);
()
gap> DigraphCanonicalLabelling(gr, [[1 .. 4], [5 .. 8]]);
(1,4)(2,3)(5,8)(6,7)

#T# DigraphCanonicalLabelling: for a digraph with incorrect colors
gap> gr := CompleteBipartiteDigraph(4, 4);
<digraph with 8 vertices, 32 edges>
gap> DigraphCanonicalLabelling(gr, [[1 .. 4], [5 .. 9]]);
Error, Digraphs: DigraphCanonicalLabelling: usage,
the union of the lists in the second arg should equal [1 .. 8],
gap> DigraphCanonicalLabelling(gr, ["a", "b"]);
Error, Digraphs: DigraphCanonicalLabelling: usage,
the union of the lists in the second arg should equal [1 .. 8],
gap> DigraphCanonicalLabelling(gr, [1 .. 10]);
Error, Digraphs: DigraphCanonicalLabelling: usage,
the second arg must be a list of length 8 of integers in [1 .. 8],
gap> DigraphCanonicalLabelling(gr, [-1 .. -10]);
Error, Digraphs: DigraphCanonicalLabelling: usage,
the second arg must be a list of length 8 of integers in [1 .. 8],

#T# DigraphCanonicalLabelling: for a multidigraph
gap> gr := Digraph([[2, 2], []]);
<multidigraph with 2 vertices, 2 edges>
gap> DigraphCanonicalLabelling(gr, [1, 2]);
fail

#T# DIGRAPHS_UnbindVariables
gap> Unbind(gr4);
gap> Unbind(gr5);
gap> Unbind(gr2);
gap> Unbind(gr);
gap> Unbind(G);
gap> Unbind(gr1);
gap> Unbind(i);
gap> Unbind(canon);
gap> Unbind(j);
gap> Unbind(m);
gap> Unbind(n);
gap> Unbind(p);
gap> Unbind(iso);
gap> Unbind(new);
gap> Unbind(gr3);

#E#
gap> STOP_TEST("Digraphs package: standard/bliss.tst");
