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
gap> gr4 := DigraphAddEdge(gr, [1, 3]);
<digraph with 4 vertices, 4 edges>
gap> gr = gr4;
false
gap> IsIsomorphicDigraph(gr, gr4);
false
gap> gr5 := DigraphAddVertex(gr);
<digraph with 5 vertices, 3 edges>
gap> gr = gr5;
false
gap> IsIsomorphicDigraph(gr, gr5);
false
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

#T# IsIsomorphicDigraph: for digraphs possibly with multiple edges

# A random example
gap> gr := Digraph([
>   [5, 7, 8, 4, 6, 1], [3, 1, 7, 2, 7, 9], [1, 5, 2, 3, 9],
>   [1, 3, 3, 9, 9], [6, 3, 5, 7, 9], [3, 9],
>   [8, 3, 6, 8, 8, 7, 7, 8, 9], [6, 1, 6, 7, 8, 4, 2, 5, 4],
>   [1, 5, 2, 3, 9]]);
<multidigraph with 9 vertices, 52 edges>
gap> IsIsomorphicDigraph(gr, gr);
true

#T# IsomorphismDigraphs: for digraphs without multiple edges

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

#T# IsomorphismDigraphs: for digraphs without multiple edges
gap> ;

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

#E#
gap> STOP_TEST("Digraphs package: standard/bliss.tst");
