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

#  AutomorphismGroup: for a digraph without multiple edges

# Complete digraph on n vertices should have automorphism group S_n
gap> n := 5;;
gap> gr := CompleteDigraph(n);
<immutable complete digraph with 5 vertices>
gap> AutomorphismGroup(gr) = SymmetricGroup(n);
true
gap> not DIGRAPHS_NautyAvailable or
> NautyAutomorphismGroup(gr) = SymmetricGroup(n);
true

# Empty digraph on n vertices should have automorphism group S_n
gap> n := 10;;
gap> gr := EmptyDigraph(n);
<immutable empty digraph with 10 vertices>
gap> AutomorphismGroup(gr) = SymmetricGroup(n);
true
gap> not DIGRAPHS_NautyAvailable or
> NautyAutomorphismGroup(gr) = SymmetricGroup(n);
true

# Chain digraph on n vertices should have trivial automorphism group
gap> n := 5;;
gap> gr := ChainDigraph(n);
<immutable chain digraph with 5 vertices>
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
<immutable cycle digraph with 5 vertices>
gap> IsCyclic(AutomorphismGroup(gr));
true
gap> Size(AutomorphismGroup(gr)) = n;
true
gap> not DIGRAPHS_NautyAvailable or
> Size(NautyAutomorphismGroup(gr)) = n;
true

# Complete bipartitite graph with parts of size m and n
# should have automorphism group S_m x S_n
gap> m := 5;; n := 4;;
gap> gr := CompleteBipartiteDigraph(m, n);
<immutable complete bipartite digraph with bicomponent sizes 5 and 4>
gap> G := AutomorphismGroup(gr);;
gap> G = DirectProduct(SymmetricGroup(m), SymmetricGroup(n));
true
gap> G := NautyAutomorphismGroup(gr);;
gap> not DIGRAPHS_NautyAvailable or
> G = DirectProduct(SymmetricGroup(m), SymmetricGroup(n));
true

# A small example
gap> gr := Digraph([[2], [], [2], [2]]);
<immutable digraph with 4 vertices, 3 edges>
gap> AutomorphismGroup(gr) = SymmetricGroup([1, 3, 4]);
true
gap> not DIGRAPHS_NautyAvailable or
> NautyAutomorphismGroup(gr) = SymmetricGroup([1, 3, 4]);
true

#  IsIsomorphicDigraph: for digraphs without multiple edges

# A small example
gap> gr := Digraph([[2], [], [2], [2]]);
<immutable digraph with 4 vertices, 3 edges>
gap> gr = gr;
true
gap> IsIsomorphicDigraph(gr, gr);
true
gap> gr1 := OnDigraphs(gr, (1, 3, 4));
<immutable digraph with 4 vertices, 3 edges>
gap> gr = gr1;
true
gap> IsIsomorphicDigraph(gr, gr1);
true
gap> gr2 := OnDigraphs(gr, (1, 3)(2, 4));
<immutable digraph with 4 vertices, 3 edges>
gap> not DIGRAPHS_NautyAvailable or NautyCanonicalLabelling(gr2) = (1, 2, 3, 4);
true
gap> gr = gr2;
false
gap> IsIsomorphicDigraph(gr, gr2);
true
gap> gr3 := DigraphReverseEdge(gr, [4, 2]);
<immutable digraph with 4 vertices, 3 edges>
gap> gr = gr3;
false
gap> IsIsomorphicDigraph(gr, gr3);
false

# Different number of edges
gap> gr4 := DigraphAddEdge(gr, [1, 3]);
<immutable digraph with 4 vertices, 4 edges>
gap> gr = gr4;
false
gap> IsIsomorphicDigraph(gr, gr4);
false

# Different number of vertices
gap> gr5 := DigraphAddVertex(gr);
<immutable digraph with 5 vertices, 3 edges>
gap> gr = gr5;
false
gap> IsIsomorphicDigraph(gr, gr5);
false

# A larger example
gap> gr := Digraph([
> [10], [4, 8], [3, 9], [7, 13, 16, 20], [5, 10, 14, 18], [14],
> [], [1, 6], [16], [6, 12], [8], [2, 14], [2, 12], [17],
> [4, 20], [1, 5, 6, 14, 18], [3], [5, 7], [4], [6, 11]]);
<immutable digraph with 20 vertices, 38 edges>
gap> p := (1, 13, 3, 14, 18)(2, 12, 6, 15, 5, 17, 11, 9, 19, 10, 7, 16, 20, 4);
(1,13,3,14,18)(2,12,6,15,5,17,11,9,19,10,7,16,20,4)
gap> gr1 := OnDigraphs(gr, p);
<immutable digraph with 20 vertices, 38 edges>
gap> gr = gr1;
false
gap> IsIsomorphicDigraph(gr, gr1);
true
gap> gr2 := OnDigraphs(gr, Transformation([1, 1]));
<immutable digraph with 20 vertices, 38 edges>
gap> gr = gr2;
false
gap> IsIsomorphicDigraph(gr, gr2);
false

#  IsIsomorphicDigraph: for digraphs with multiple edges

# Different number of vertices
gap> gr1 := Digraph([[1, 2, 3, 2], [1, 3], [3]]);
<immutable multidigraph with 3 vertices, 7 edges>
gap> gr2 := Digraph([[1, 2, 3, 2], [1, 3], [3], []]);
<immutable multidigraph with 4 vertices, 7 edges>
gap> IsIsomorphicDigraph(gr1, gr2);
false

# Different number of edges
gap> gr1 := Digraph([[1, 2, 3, 2], [1, 3], [3]]);
<immutable multidigraph with 3 vertices, 7 edges>
gap> gr2 := Digraph([[1, 2, 3, 2], [1, 3], [3, 2]]);
<immutable multidigraph with 3 vertices, 8 edges>
gap> IsIsomorphicDigraph(gr1, gr2);
false

# One MultiDigraph, one not MultiDigraph
gap> gr1 := Digraph([[1, 2, 3, 2], [1, 3], [3]]);
<immutable multidigraph with 3 vertices, 7 edges>
gap> gr2 := Digraph([[1, 2, 3], [1, 2, 3], [3]]);
<immutable digraph with 3 vertices, 7 edges>
gap> IsIsomorphicDigraph(gr1, gr2);
false

#  IsIsomorphicDigraph: for digraphs with colourings and without multiple edges
gap> gr1 := Digraph([[2, 2], [1]]);
<immutable multidigraph with 2 vertices, 3 edges>
gap> gr2 := CompleteDigraph(2);
<immutable complete digraph with 2 vertices>
gap> IsIsomorphicDigraph(gr1, gr2, [1, 1], [1, 1]);
false
gap> IsIsomorphicDigraph(gr2, gr1, [1, 1], [1, 1]);
false
gap> IsIsomorphicDigraph(gr1, gr1, [1, 1], [1, 1]);
true
gap> IsIsomorphicDigraph(gr2, gr2, [], [1, 1]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 
2
 ]. The 2nd argument must have one of the following forms: 1. a list of length 
2 consisting of every integer in the range [1 .. m], for some m <= 
2; or 2. a list of non-empty disjoint lists whose union is [1 .. 2].
gap> IsIsomorphicDigraph(gr2, gr2, [2, 2], []);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 2], since it contains the colour 2, but it lacks the colour 
1
 . A colouring must use precisely the colours [1 .. m], for some positive integ\
er m <= 2,
gap> IsIsomorphicDigraph(EmptyDigraph(1), EmptyDigraph(2), [1], [1, 1]);
false
gap> IsIsomorphicDigraph(EmptyDigraph(1), Digraph([[1]]), [1], [1]);
false
gap> IsIsomorphicDigraph(EmptyDigraph(2), EmptyDigraph(2), [1, 1], [1, 2]);
false
gap> IsIsomorphicDigraph(EmptyDigraph(2), EmptyDigraph(2), [1, 1], [1, 1]);
true
gap> IsIsomorphicDigraph(gr2, gr2, [1, 1], [2, 2]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 2], since it contains the colour 2, but it lacks the colour 
1
 . A colouring must use precisely the colours [1 .. m], for some positive integ\
er m <= 2,
gap> IsIsomorphicDigraph(gr2, gr2, [1, 2], [2, 1]);
true
gap> gr1 := CycleDigraph(4);
<immutable cycle digraph with 4 vertices>
gap> gr2 := DigraphDisjointUnion(CycleDigraph(2), CycleDigraph(2));
<immutable digraph with 4 vertices, 4 edges>
gap> IsIsomorphicDigraph(gr1, gr2, [1, 1, 1, 1], [1, 1, 1, 1]);
false
gap> IsIsomorphicDigraph(gr1, gr1, [1, 1, 2, 2], [1, 1, 1, 2]);
false

# IsomorphismDigraphs: for digraphs without multiple edges

# Non-isomorphic graphs
gap> gr1 := EmptyDigraph(3);
<immutable empty digraph with 3 vertices>
gap> gr2 := ChainDigraph(3);
<immutable chain digraph with 3 vertices>
gap> IsomorphismDigraphs(gr1, gr2);
fail
gap> IsomorphismDigraphs(gr2, gr1);
fail
gap> IsIsomorphicDigraph(gr1, gr2);
false

# A small example: check that all isomorphic copies give correct answer
gap> gr := Digraph([[3], [2, 3, 4], [1, 3], [], [1, 4]]);
<immutable digraph with 5 vertices, 8 edges>
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
<immutable digraph with 5 vertices, 8 edges>
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

#  IsomorphismDigraphs: for digraphs with colourings and without multiple edges
gap> gr1 := Digraph([[2, 2], [1]]);
<immutable multidigraph with 2 vertices, 3 edges>
gap> gr2 := CompleteDigraph(2);
<immutable complete digraph with 2 vertices>
gap> IsomorphismDigraphs(gr1, gr2, [1, 1], [1, 1]);
fail
gap> IsomorphismDigraphs(gr2, gr1, [1, 1], [1, 1]);
fail
gap> IsomorphismDigraphs(gr1, gr1, [1, 1], [1, 1]);
[ (), () ]
gap> IsomorphismDigraphs(gr2, gr2, [], [1, 1]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 
2
 ]. The 2nd argument must have one of the following forms: 1. a list of length 
2 consisting of every integer in the range [1 .. m], for some m <= 
2; or 2. a list of non-empty disjoint lists whose union is [1 .. 2].
gap> IsomorphismDigraphs(gr2, gr2, [2, 2], []);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 2], since it contains the colour 2, but it lacks the colour 
1
 . A colouring must use precisely the colours [1 .. m], for some positive integ\
er m <= 2,
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
<immutable cycle digraph with 4 vertices>
gap> gr2 := DigraphDisjointUnion(CycleDigraph(2), CycleDigraph(2));
<immutable digraph with 4 vertices, 4 edges>
gap> IsomorphismDigraphs(gr1, gr2, [1, 1, 1, 1], [1, 1, 1, 1]);
fail
gap> gr1 := CompleteDigraph(3);;
gap> IsomorphismDigraphs(gr1, gr1, [1, 2, 2], [[1, 3], [2]]);
fail

#  CanonicalLabelling: for a digraph without multiple edges

# A small example: check that all isomorphic copies have same canonical image
gap> gr := Digraph([[2], [3, 5, 6], [3], [4, 6], [1, 4], [4]]);
<immutable digraph with 6 vertices, 10 edges>
gap> BlissCanonicalLabelling(gr);
(1,2,6,3)(4,5)
gap> not DIGRAPHS_NautyAvailable or NautyCanonicalLabelling(gr) =
> (1, 3, 2, 6)(4, 5);
true
gap> canon := OutNeighbours(BlissCanonicalDigraph(gr));
[ [ 1 ], [ 6 ], [ 5 ], [ 2, 5 ], [ 5, 3 ], [ 1, 4, 3 ] ]
gap> for i in SymmetricGroup(DigraphNrVertices(gr)) do
>   new := OnDigraphs(gr, i);
>   if not OutNeighbours(OnDigraphs(new, BlissCanonicalLabelling(new))) =
>       canon then
>     Print("fail\n");
>   fi;
> od;
gap> gr1 := DigraphReverseEdge(gr, [2, 5]);
<immutable digraph with 6 vertices, 10 edges>
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

#  CanonicalLabelling: with colours
gap> G := Digraph(10, [1, 1, 3, 4, 4, 5, 8, 8], [6, 3, 3, 9, 10, 9, 4, 10]);;
gap> BlissCanonicalLabelling(G, [[1 .. 5], [6 .. 10]]);
(1,5,2)(6,9)(8,10)
gap> not DIGRAPHS_NautyAvailable or
> NautyCanonicalLabelling(G, [[1 .. 5], [6 .. 10]])
> = (1, 5, 3, 4)(6, 8, 10)(7, 9);
true
gap> BlissCanonicalLabelling(G, [1, 1, 1, 1, 1, 2, 2, 2, 2, 2]);
(1,5,2)(6,9)(8,10)
gap> not DIGRAPHS_NautyAvailable or
> NautyCanonicalLabelling(G, [1, 1, 1, 1, 1, 2, 2, 2, 2, 2])
> = (1, 5, 3, 4)(6, 8, 10)(7, 9);
true

#  AutomorphismGroup: for a digraph with colored vertices
gap> gr := CompleteBipartiteDigraph(4, 4);
<immutable complete bipartite digraph with bicomponent sizes 4 and 4>
gap> AutomorphismGroup(gr) = Group([
> (7, 8), (6, 7), (5, 6), (3, 4), (2, 3), (1, 2), (1, 5)(2, 6)(3, 7)(4, 8)]);
true
gap> AutomorphismGroup(gr, [[1 .. 4], [5 .. 8]]);
Group([ (7,8), (6,7), (5,6), (3,4), (2,3), (1,2) ])
gap> AutomorphismGroup(gr, [1 .. 8]);
Group(())

#  AutomorphismGroup: for a digraph with incorrect colors
gap> gr := CompleteBipartiteDigraph(4, 4);
<immutable complete bipartite digraph with bicomponent sizes 4 and 4>
gap> AutomorphismGroup(gr, [[1 .. 4], [5 .. 9]]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 8], since the entry in position 2 contains 
9 which is not an integer in the range [1 .. 8],
gap> AutomorphismGroup(gr, ["a", "b"]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 8], since the entry in position 
1 contains 'a' which is not an integer in the range [1 .. 8],
gap> AutomorphismGroup(gr, [1 .. 10]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 
8
 ]. The 2nd argument must have one of the following forms: 1. a list of length 
8 consisting of every integer in the range [1 .. m], for some m <= 
8; or 2. a list of non-empty disjoint lists whose union is [1 .. 8].
gap> AutomorphismGroup(gr, [-1 .. -10]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 
8
 ]. The 2nd argument must have one of the following forms: 1. a list of length 
8 consisting of every integer in the range [1 .. m], for some m <= 
8; or 2. a list of non-empty disjoint lists whose union is [1 .. 8].

#  CanonicalLabelling: for a digraph with colored vertices
gap> gr := CompleteBipartiteDigraph(4, 4);
<immutable complete bipartite digraph with bicomponent sizes 4 and 4>
gap> BlissCanonicalLabelling(gr);
(1,8,4)(2,3)(5,7)
gap> not DIGRAPHS_NautyAvailable
> or NautyCanonicalLabelling(gr) = (2, 6, 3, 7, 4, 8, 5);
true
gap> not DIGRAPHS_NautyAvailable
> or NautyCanonicalLabelling(gr, [1 .. 8]) = ();
true
gap> BlissCanonicalLabelling(gr, [[1 .. 4], [5 .. 8]]);
(1,4)(2,3)(5,8)(6,7)
gap> not DIGRAPHS_NautyAvailable
> or NautyCanonicalLabelling(gr, [[1 .. 4], [5 .. 8]]) = ();
true

#  CanonicalLabelling: for a digraph with no automorphisms
gap> gr := ChainDigraph(5);               
<immutable chain digraph with 5 vertices>
gap> BlissCanonicalLabelling(gr);
(1,5)(2,4)
gap> BlissCanonicalLabelling(BlissCanonicalDigraph(gr));
()

#  CanonicalLabelling: for a digraph with incorrect colors
gap> gr := CompleteBipartiteDigraph(4, 4);
<immutable complete bipartite digraph with bicomponent sizes 4 and 4>
gap> BlissCanonicalLabelling(gr, [[1 .. 4], [5 .. 9]]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 8], since the entry in position 2 contains 
9 which is not an integer in the range [1 .. 8],
gap> BlissCanonicalLabelling(gr, ["a", "b"]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 8], since the entry in position 
1 contains 'a' which is not an integer in the range [1 .. 8],
gap> BlissCanonicalLabelling(gr, [1 .. 10]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 
8
 ]. The 2nd argument must have one of the following forms: 1. a list of length 
8 consisting of every integer in the range [1 .. m], for some m <= 
8; or 2. a list of non-empty disjoint lists whose union is [1 .. 8].
gap> BlissCanonicalLabelling(gr, [-1 .. -10]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 
8
 ]. The 2nd argument must have one of the following forms: 1. a list of length 
8 consisting of every integer in the range [1 .. m], for some m <= 
8; or 2. a list of non-empty disjoint lists whose union is [1 .. 8].

#  DIGRAPHS_ValidateVertexColouring, 1, errors
gap> DIGRAPHS_ValidateVertexColouring();
Error, Function: number of arguments must be 2 (not 0)
gap> DIGRAPHS_ValidateVertexColouring(fail);
Error, Function: number of arguments must be 2 (not 1)
gap> DIGRAPHS_ValidateVertexColouring(fail, fail);
Error, the 1st argument <n> must be a non-negative integer,
gap> DIGRAPHS_ValidateVertexColouring(0, fail);
Error, the 2nd argument <partition> must be a homogeneous list,
gap> DIGRAPHS_ValidateVertexColouring(fail, []);
Error, the 1st argument <n> must be a non-negative integer,
gap> DIGRAPHS_ValidateVertexColouring(0, [], fail);
Error, Function: number of arguments must be 2 (not 3)

#  DIGRAPHS_ValidateVertexColouring, 2
gap> DIGRAPHS_ValidateVertexColouring(0, []);
[  ]
gap> DIGRAPHS_ValidateVertexColouring(0, [2]);
Error, the only valid partition of the vertices of the digraph with 0 vertices\
 is the empty list,
gap> DIGRAPHS_ValidateVertexColouring(1, []);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 
1
 ]. The 2nd argument must have one of the following forms: 1. a list of length 
1 consisting of every integer in the range [1 .. m], for some m <= 
1; or 2. a list of non-empty disjoint lists whose union is [1 .. 1].
gap> DIGRAPHS_ValidateVertexColouring(1, [fail]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 
1
 ]. The 2nd argument must have one of the following forms: 1. a list of length 
1 consisting of every integer in the range [1 .. m], for some m <= 
1; or 2. a list of non-empty disjoint lists whose union is [1 .. 1].
gap> DIGRAPHS_ValidateVertexColouring(1, [1, 1]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 
1
 ]. The 2nd argument must have one of the following forms: 1. a list of length 
1 consisting of every integer in the range [1 .. m], for some m <= 
1; or 2. a list of non-empty disjoint lists whose union is [1 .. 1].
gap> DIGRAPHS_ValidateVertexColouring(2, [1, -1]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 2], since it contains the element -1, which is not a positive integer,
gap> DIGRAPHS_ValidateVertexColouring(2, [2, 3]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 2], since it contains the integer 3, which is greater than 2,
gap> DIGRAPHS_ValidateVertexColouring(2, [2, 0]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 2], since it contains the element 0, which is not a positive integer,
gap> DIGRAPHS_ValidateVertexColouring(2, [[]]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 2], since it does not assign a colour to the vertex 1,
gap> DIGRAPHS_ValidateVertexColouring(1, [[1, 1]]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 1], since it contains the vertex 1 more than once,
gap> DIGRAPHS_ValidateVertexColouring(1, [[0, 1]]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 1], since the entry in position 1 contains 
0 which is not an integer in the range [1 .. 1],
gap> DIGRAPHS_ValidateVertexColouring(1, [[2]]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 1], since the entry in position 1 contains 
2 which is not an integer in the range [1 .. 1],
gap> DIGRAPHS_ValidateVertexColouring(4, [[3], [2, 1], [4]]);
[ 2, 2, 1, 3 ]
gap> DIGRAPHS_ValidateVertexColouring(4, [1, 1, 3, 4]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 4], since it contains the colour 4, but it lacks the colour 
2
 . A colouring must use precisely the colours [1 .. m], for some positive integ\
er m <= 4,
gap> DIGRAPHS_ValidateVertexColouring(4, [1, 1, 3, 2]);
[ 1, 1, 3, 2 ]

# DIGRAPHS_ValidateEdgeColouring
gap> D := ChainDigraph(3);;
gap> DIGRAPHS_ValidateEdgeColouring(3, 3);
Error, the 1st argument must be a digraph,
gap> DIGRAPHS_ValidateEdgeColouring(D, 3); 
Error, the 2nd argument must be a list of the same shape as OutNeighbours(grap\
h), where graph is the 1st argument,
gap> DIGRAPHS_ValidateEdgeColouring(D, [3]);
Error, the 2nd argument must be a list of the same shape as OutNeighbours(grap\
h), where graph is the 1st argument,
gap> DIGRAPHS_ValidateEdgeColouring(D, [[1], [], [2]]);
Error, the 2nd argument must be a list of the same shape as OutNeighbours(grap\
h), where graph is the 1st argument,
gap> DIGRAPHS_ValidateEdgeColouring(D, [[-1], [2], []]);
Error, the 2nd argument should be a list of lists of positive integers,
gap> DIGRAPHS_ValidateEdgeColouring(D, [[3], [2], []]); 
Error, the 2nd argument should be a list of lists whose union is [1 .. number \
of colours],
gap> DIGRAPHS_ValidateEdgeColouring(D, fail);
true

#  CanonicalDigraph
gap> gr1 := Digraph([[1, 2], [1, 2], [2, 3], [1, 2, 3], [5]]);;
gap> gr2 := Digraph([[1, 3], [2, 3], [2, 3], [1, 2, 3], [5]]);;
gap> BlissCanonicalDigraph(gr1) = BlissCanonicalDigraph(gr2);
true
gap> gr3 := Digraph([[2, 3], [2, 3], [1, 3], [1, 2, 3], [5]]);;
gap> BlissCanonicalDigraph(gr1) = BlissCanonicalDigraph(gr3);
false
gap> BlissCanonicalDigraph(gr3, [1, 1, 1, 1, 1]);
<immutable digraph with 5 vertices, 10 edges>
gap> BlissCanonicalDigraph(Digraph([[1], [2], [3], [3], [2], [1]]))
> = BlissCanonicalDigraph(Digraph([[1], [2], [3], [1], [2], [3]]));
true

#  CanonicalDigraph
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
<immutable digraph with 4 vertices, 13 edges>
gap> IsDigraphAutomorphism(gr1, (1, 2, 3));
false
gap> IsDigraphAutomorphism(gr1, (2, 3));
true
gap> IsDigraphAutomorphism(gr1, ());
true
gap> gr2 := Digraph([[1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 2, 3, 4, 5, 6]]);
<immutable digraph with 6 vertices, 15 edges>
gap> IsDigraphAutomorphism(gr2, (2, 3, 4, 5));
true
gap> IsDigraphAutomorphism(gr2, (1, 6));
false
gap> IsDigraphAutomorphism(gr2, (2, 3, 6));
false
gap> IsDigraphAutomorphism(Digraph([[1, 1], [1, 1, 2], [1, 2, 2, 3]]), ());
Error, the 1st and 2nd arguments <src> and <ran> must not have multiple edges,

# IsDigraphAutomorphism, for digraph and transformation
gap> gr1 := Digraph([[1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1]]);
<immutable digraph with 4 vertices, 13 edges>
gap> IsDigraphAutomorphism(gr1, AsTransformation((1, 2, 3)));
false
gap> IsDigraphAutomorphism(gr1, AsTransformation((2, 3)));
true
gap> IsDigraphAutomorphism(gr1, AsTransformation(()));
true
gap> gr2 := Digraph([[1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 2, 3, 4, 5, 6]]);
<immutable digraph with 6 vertices, 15 edges>
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
Error, the 1st and 2nd arguments <src> and <ran> must not have multiple edges,

# AutomorphismGroup, for a vertex/edge coloured digraph
gap> AutomorphismGroup(Digraph([]), [], []);                    
Group(())
gap> AutomorphismGroup(Digraph([[]]), [1], [[]]);
Group(())
gap> AutomorphismGroup(Digraph([[], []]), [1, 1], [[], []]);
Group([ (1,2) ])
gap> AutomorphismGroup(Digraph([[], []]), [1, 2], [[], []]);
Group(())
gap> AutomorphismGroup(Digraph([[2], [1]]), [1, 1], [[1], [1]]);
Group([ (1,2) ])
gap> AutomorphismGroup(Digraph([[2], [1]]), [1, 2], [[1], [1]]);
Group(())
gap> AutomorphismGroup(Digraph([[2], [1]]), [1, 1], [[2], [1]]);
Group(())
gap> AutomorphismGroup(Digraph([[2, 2], [1, 1]]), [1, 1], [[2, 1], [1, 2]]);
Group([ (1,2), () ])
gap> D := Digraph([[2, 3, 3, 4], [3, 4, 4, 1], [4, 1, 1, 2], [1, 2, 2, 3]]);;
gap> ec := [[1, 1, 2, 2], [2, 1, 2, 1], [1, 1, 2, 2], [2, 1, 2, 1]];;
gap> vc := [1, 1, 1, 1];;
gap> AutomorphismGroup(D, vc, ec);
Group([ (1,2)(3,4), (1,3)(2,4), () ])
gap> vc := [1, 1, 2, 2];;
gap> AutomorphismGroup(D, vc, ec);
Group([ (1,2)(3,4), () ])

#  AutomorphismGroup: for a digraph with multiple edges

# An edge union of complete digraphs
gap> gr := DigraphEdgeUnion(CompleteDigraph(4), CompleteDigraph(4));
<immutable multidigraph with 4 vertices, 24 edges>
gap> G := AutomorphismGroup(gr);;
gap> Image(Projection(G, 1)) = SymmetricGroup(4);
true
gap> StructureDescription(Image(Projection(G, 2)));
"C2 x C2 x C2 x C2 x C2 x C2 x C2 x C2 x C2 x C2 x C2 x C2"

# AutomorphismGroup for a multidigraph with repeated edges
gap> D := Digraph([[2, 2, 4], [3], [2], [1, 2, 2]]);
<immutable multidigraph with 4 vertices, 8 edges>
gap> v_cols := [1, 2, 2, 1];;              
gap> e_cols := [[1, 1, 2], [3], [4], [2, 1, 1]];;
gap> G := AutomorphismGroup(D, v_cols, e_cols);
Group([ (1,2), (3,4), (5,6) ])
gap> Range(Projection(G, 1));
Group([ (1,4) ])
gap> Range(Projection(G, 2));
Group([ (1,2), (7,8) ])

# A small example
gap> gr := Digraph([[2], [1, 3], [], [3, 3]]);
<immutable multidigraph with 4 vertices, 5 edges>
gap> G := AutomorphismGroup(gr);
Group([ (), (1,2) ])
gap> IsTrivial(Image(Projection(G, 1)));
true
gap> Image(Projection(G, 2));
Group([ (4,5) ])
gap> IsTrivial(AutomorphismGroup(Digraph(OutNeighbours(Digraph("frucht")))));
true

# A larger example
gap> gr := Digraph([
>   [5, 7, 8, 4, 6, 1], [3, 1, 7, 2, 7, 9], [1, 5, 2, 3, 9],
>   [1, 3, 3, 9, 9], [6, 3, 5, 7, 9], [3, 9],
>   [8, 3, 6, 8, 8, 7, 7, 8, 9], [6, 1, 6, 7, 8, 4, 2, 5, 4],
>   [1, 5, 2, 3, 9]]);
<immutable multidigraph with 9 vertices, 52 edges>
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

# A random example
gap> gr := Digraph([
>   [5, 7, 8, 4, 6, 1], [3, 1, 7, 2, 7, 9], [1, 5, 2, 3, 9],
>   [1, 3, 3, 9, 9], [6, 3, 5, 7, 9], [3, 9],
>   [8, 3, 6, 8, 8, 7, 7, 8, 9], [6, 1, 6, 7, 8, 4, 2, 5, 4],
>   [1, 5, 2, 3, 9]]);
<immutable multidigraph with 9 vertices, 52 edges>
gap> IsIsomorphicDigraph(gr, gr);
true
gap> gr1 := OnDigraphs(gr, (3, 9)(1, 2, 7, 5));;
gap> IsIsomorphicDigraph(gr, gr1);
true
gap> gr2 := OnDigraphs(gr, (3, 9));;
gap> IsIsomorphicDigraph(gr, gr2);
true

#  IsIsomorphicDigraph: for multidigraphs with colourings
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

#  IsomorphismDigraphs: for digraphs with multiple edges

# An example used in previous tests
gap> gr := Digraph([
>   [5, 7, 8, 4, 6, 1], [3, 1, 7, 2, 7, 9], [1, 5, 2, 3, 9],
>   [1, 3, 3, 9, 9], [6, 3, 5, 7, 9], [3, 9],
>   [8, 3, 6, 8, 8, 7, 7, 8, 9], [6, 1, 6, 7, 8, 4, 2, 5, 4],
>   [1, 5, 2, 3, 9]]);
<immutable multidigraph with 9 vertices, 52 edges>
gap> IsomorphismDigraphs(gr, gr);
[ (), () ]
gap> BlissCanonicalLabelling(gr);
[ (1,9,6,2,4)(3,7), () ]
gap> NautyCanonicalLabelling(gr);
fail
gap> AutomorphismGroup(gr);
<permutation group with 9 generators>
gap> p := (1, 8, 2)(3, 5, 4, 9, 7);;
gap> gr1 := OnDigraphs(gr, p);
<immutable multidigraph with 9 vertices, 52 edges>
gap> iso := IsomorphismDigraphs(gr, gr1);
[ (1,8,2)(3,5,4,9,7), () ]
gap> OnMultiDigraphs(gr, iso) = gr1;
true
gap> iso[1] = p;
true
gap> p := (1, 7, 8, 4)(2, 6, 5);;
gap> gr1 := OnDigraphs(gr, p);
<immutable multidigraph with 9 vertices, 52 edges>
gap> iso := IsomorphismDigraphs(gr, gr1);
[ (1,7,8,4)(2,6,5), () ]
gap> OnMultiDigraphs(gr, iso) = gr1;
true
gap> iso[1] = p;
true

#  IsomorphismDigraphs: for multidigraphs with colourings
gap> gr1 := Digraph([[2, 1, 2], []]);;
gap> gr2 := Digraph([[], [2, 1, 1]]);;
gap> IsomorphismDigraphs(gr1, gr1, [1, 1], [1, 1]);
[ (), () ]
gap> IsomorphismDigraphs(gr1, gr1, [1, 1], [1, 2]);
fail
gap> IsomorphismDigraphs(gr1, gr2, [1, 2], [2, 1]);
[ (1,2), () ]
gap> IsomorphismDigraphs(gr1, gr2, [1, 2], [1, 2]);
fail
gap> IsomorphismDigraphs(gr1, gr2, [1, 1], [1, 1]);
[ (1,2), () ]

#  CanonicalLabelling: for a digraph with multiple edges

# A small example: check that all isomorphic copies have same canonical image
gap> gr := Digraph([[2, 2], [1, 1], [2]]);
<immutable multidigraph with 3 vertices, 5 edges>
gap> BlissCanonicalLabelling(gr);
[ (), () ]
gap> canon := OutNeighbours(OnMultiDigraphs(gr, last));
[ [ 2, 2 ], [ 1, 1 ], [ 2 ] ]
gap> for i in SymmetricGroup(DigraphNrVertices(gr)) do
> for j in SymmetricGroup(DigraphNrEdges(gr)) do
>   new := OnMultiDigraphs(gr, [i, j]);
>   if not OutNeighbours(OnMultiDigraphs(new,
>       BlissCanonicalLabelling(new))) = canon then
>     Print("fail");
>   fi;
> od; od;
gap> gr1 := Digraph([[2, 2], [1, 3], [2]]);
<immutable multidigraph with 3 vertices, 5 edges>
gap> gr = gr1;
false
gap> IsIsomorphicDigraph(gr, gr1);
false
gap> canon = OnMultiDigraphs(gr1, BlissCanonicalLabelling(gr1));
false
gap> NautyCanonicalLabelling(gr);
fail

#  AutomorphismGroup: for a multidigraph
gap> gr := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> AutomorphismGroup(gr, [1, 2]);
Group([ (), (1,2) ])
gap> NautyAutomorphismGroup(gr);
fail
gap> NautyAutomorphismGroup(gr, [1, 2]);
fail

#  CanonicalLabelling: for a multidigraph
gap> gr := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> BlissCanonicalLabelling(gr, [1, 2]);
[ (), () ]
gap> NautyCanonicalLabelling(gr, [1, 2]);
fail

# Canonical digraph
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

#  AutomorphismGroup: for a multidigraph
# CanonicalLabelling was being set incorrectly by AutomorphismGroup for
# a multidigraph
gap> gr := Digraph([
>   [5, 7, 8, 4, 6, 1], [3, 1, 7, 2, 7, 9], [1, 5, 2, 3, 9],
>   [1, 3, 3, 9, 9], [6, 3, 5, 7, 9], [3, 9],
>   [8, 3, 6, 8, 8, 7, 7, 8, 9], [6, 1, 6, 7, 8, 4, 2, 5, 4],
>   [1, 5, 2, 3, 9]]);
<immutable multidigraph with 9 vertices, 52 edges>
gap> G := AutomorphismGroup(gr);;
gap> HasBlissCanonicalLabelling(gr);
true
gap> BlissCanonicalLabelling(gr);
[ (1,9,6,2,4)(3,7), () ]
gap> BlissCanonicalLabelling(gr) = BlissCanonicalLabelling(DigraphCopy(gr));
true

# Diameter for multidigraphs
gap> gr := Digraph([[2, 2, 4, 4], [1, 1, 3], [2], [1, 1, 5], [4]]);
<immutable multidigraph with 5 vertices, 12 edges>
gap> DigraphGroup(gr);
Group([ (2,4)(3,5) ])
gap> DigraphDiameter(gr);
4
gap> DigraphUndirectedGirth(gr);
2
gap> gr := EmptyDigraph(0);;
gap> DigraphUndirectedGirth(gr);
infinity
gap> DigraphDiameter(gr);
fail

# DistanceDigraph on multidigraph with known automorphisms
gap> gr := Digraph([[1, 2, 2], [], [2, 2, 3]]);;
gap> DigraphGroup(gr) = Group((1, 3));
true
gap> OutNeighbours(DistanceDigraph(gr, 0));
[ [ 1 ], [ 2 ], [ 3 ] ]
gap> OutNeighbours(DistanceDigraph(gr, 1));
[ [ 2 ], [  ], [ 2 ] ]
gap> OutNeighbours(DistanceDigraph(gr, 2));
[ [  ], [  ], [  ] ]

# BlissAutomorphismGroup, error handling
gap> gr := Digraph([[2], [1, 3], [2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> BlissAutomorphismGroup(gr, false, []);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 2nd choice method found for `BlissAutomorphismGroup' on 3 arguments
gap> BlissAutomorphismGroup(gr, fail, []);
Error, the 2nd argument must be a list of the same shape as OutNeighbours(grap\
h), where graph is the 1st argument,
gap> BlissAutomorphismGroup(gr, fail, [[1], [1, 1], [1]]) = Group([(1, 3)]);
true

# IsDigraphIsomorphism
gap> gr1 := Digraph([[2, 3, 4], [1, 3, 4], [1, 2], [1, 2]]);
<immutable digraph with 4 vertices, 10 edges>
gap> IsDigraphIsomorphism(gr1, gr1, (1, 2));
true
gap> IsDigraphIsomorphism(gr1, gr1, (1, 2)(3, 4));
true
gap> gr2 := Digraph([[2, 3, 4, 4], [1, 3, 4], [1, 2], [1, 2]]);
<immutable multidigraph with 4 vertices, 11 edges>
gap> IsDigraphIsomorphism(gr1, gr2, (1, 2));
Error, the 1st and 2nd arguments <src> and <ran> must not have multiple edges,
gap> IsDigraphIsomorphism(gr2, gr1, (1, 2));
Error, the 1st and 2nd arguments <src> and <ran> must not have multiple edges,
gap> IsDigraphIsomorphism(gr1, gr1, Transformation([2, 1, 4, 3, 6, 5]));
true
gap> IsDigraphIsomorphism(gr1, gr1, Transformation([2, 1, 3, 5, 4, 6]));
false
gap> gr := NullDigraph(5);; 
gap> ForAll(AutomorphismGroup(gr),        
>           x -> IsDigraphAutomorphism(gr, x, [1, 1, 1, 1, 1]));
true
gap> Number(AutomorphismGroup(gr),                              
>           x -> IsDigraphAutomorphism(gr, x, [1, 2, 3, 4, 5]));
1
gap> gr2 := CycleDigraph(6);
<immutable cycle digraph with 6 vertices>
gap> t := Transformation([2, 3, 4, 5, 6, 1, 8, 7]);
Transformation( [ 2, 3, 4, 5, 6, 1, 8, 7 ] )
gap> ForAll([1 .. 6],
>            i -> IsDigraphAutomorphism(gr2,
>                                       t ^ i,  
>                                       [1, 1, 1, 1, 1, 1]));
true
gap> ForAll([2, 4, 6],
>            i -> IsDigraphAutomorphism(gr2,
>                                       t ^ i,
>                                       [1, 2, 1, 2, 1, 2]));
true
gap> IsDigraphAutomorphism(gr2, t ^ 3, [1, 2, 3, 1, 2, 3]);
true
gap> gr3 := CycleDigraph(5);;
gap> Number(FullTransformationMonoid(5),
>           t -> IsDigraphAutomorphism(gr3,
>                                      t,
>                                      [1, 1, 1, 1, 1]));   
5

#  DIGRAPHS_UnbindVariables
gap> Unbind(D);
gap> Unbind(G);
gap> Unbind(canon);
gap> Unbind(cols);
gap> Unbind(ec);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(gr3);
gap> Unbind(gr4);
gap> Unbind(gr5);
gap> Unbind(gr6);
gap> Unbind(gr7);
gap> Unbind(i);
gap> Unbind(iso);
gap> Unbind(j);
gap> Unbind(m);
gap> Unbind(n);
gap> Unbind(nauty);
gap> Unbind(p);
gap> Unbind(t);
gap> Unbind(vc);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/isomorph.tst", 0);
