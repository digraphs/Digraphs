#############################################################################
##
#W  standard/oper.tst
#Y  Copyright (C) 2014-17                                James D. Mitchell
##                                                          Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/oper.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#  DigraphRemoveLoops
gap> gr := DigraphFromDigraph6String("&EhxPC?@");
<immutable digraph with 6 vertices, 11 edges>
gap> DigraphRemoveLoops(gr);
<immutable digraph with 6 vertices, 7 edges>
gap> gr := DigraphFromDigraph6String("&EhxPC?@");
<immutable digraph with 6 vertices, 11 edges>
gap> HasDigraphHasLoops(gr);
false
gap> DigraphHasLoops(gr);
true
gap> gr1 := DigraphRemoveLoops(gr);
<immutable digraph with 6 vertices, 7 edges>
gap> HasDigraphHasLoops(gr1);
true
gap> DigraphHasLoops(gr1);
false

#  DigraphRemoveEdges: for a list of edges
gap> gr := Digraph([[2], []]);
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphRemoveEdges(gr, [[2, 1]]);
<immutable digraph with 2 vertices, 1 edge>
gap> last = gr;
true
gap> DigraphRemoveEdges(gr, [[1, 2]]);
<immutable empty digraph with 2 vertices>
gap> gr := DigraphFromDigraph6String("&DtGsw_");
<immutable digraph with 5 vertices, 12 edges>
gap> Set(DigraphEdges(gr)) = Set(
> [[1, 2], [1, 1], [1, 4], [2, 1], [2, 4], [3, 4],
>  [3, 3], [4, 1], [4, 5], [4, 4], [5, 1], [5, 5]]);
true
gap> gr1 := DigraphRemoveEdges(gr, [[1, 4], [4, 5], [5, 5]]);
<immutable digraph with 5 vertices, 9 edges>
gap> DigraphEdges(gr1);
[ [ 1, 2 ], [ 1, 1 ], [ 2, 1 ], [ 2, 4 ], [ 3, 4 ], [ 3, 3 ], [ 4, 1 ], 
  [ 4, 4 ], [ 5, 1 ] ]
gap> gr := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> DigraphRemoveEdges(gr, [[1, 2]]);
Error, the 1st argument <D> must be a digraph with no multiple edges,

#  DigraphRemoveEdge: for an edge
gap> gr := Digraph([[1, 1]]);
<immutable multidigraph with 1 vertex, 2 edges>
gap> DigraphRemoveEdge(gr, [1, 1]);
Error, the 1st argument <D> must be a digraph with no multiple edges,
gap> gr := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphRemoveEdge(gr, [1, 1, 1]);
Error, the 2nd argument <edge> must be a list of length 2,
gap> DigraphRemoveEdge(gr, [Group(()), Group(())]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphRemoveEdge' on 3 arguments
gap> DigraphRemoveEdge(gr, [1, Group(())]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphRemoveEdge' on 3 arguments
gap> DigraphRemoveEdge(gr, [3, 1]);
Error, the 2nd argument <src> must be a vertex of the digraph <D> that is the \
1st argument,
gap> DigraphRemoveEdge(gr, [1, 3]);
Error, the 3rd argument <ran> must be a vertex of the digraph <D> that is the \
1st argument,
gap> gr := DigraphRemoveEdge(gr, [2, 1]);
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphEdges(gr);
[ [ 1, 2 ] ]

#  OnDigraphs: for a digraph and a perm
gap> gr := Digraph([[2], [1], [3]]);
<immutable digraph with 3 vertices, 3 edges>
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 2, 1 ], [ 3, 3 ] ]
gap> g := (1, 2, 3);
(1,2,3)
gap> OnDigraphs(gr, g);
<immutable digraph with 3 vertices, 3 edges>
gap> DigraphEdges(last);
[ [ 1, 1 ], [ 2, 3 ], [ 3, 2 ] ]
gap> h := (1, 2, 3, 4);
(1,2,3,4)
gap> OnDigraphs(gr, h);
Error, the 2nd argument <p> must be a permutation that permutes of the digraph\
 <D> that is the 1st argument,
gap> gr := Digraph([[1, 1, 1, 3, 5], [], [3, 2, 4, 5], [2, 5], [1, 2, 1]]);
<immutable multidigraph with 5 vertices, 14 edges>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 1 ], [ 1, 1 ], [ 1, 3 ], [ 1, 5 ], [ 3, 3 ], [ 3, 2 ], 
  [ 3, 4 ], [ 3, 5 ], [ 4, 2 ], [ 4, 5 ], [ 5, 1 ], [ 5, 2 ], [ 5, 1 ] ]
gap> p1 := (2, 4)(3, 6, 5);
(2,4)(3,6,5)
gap> OnDigraphs(gr, p1);
Error, the 2nd argument <p> must be a permutation that permutes of the digraph\
 <D> that is the 1st argument,
gap> p2 := (1, 3, 4, 2);
(1,3,4,2)
gap> OnDigraphs(gr, p2);
<immutable multidigraph with 5 vertices, 14 edges>
gap> DigraphEdges(last);
[ [ 2, 1 ], [ 2, 5 ], [ 3, 3 ], [ 3, 3 ], [ 3, 3 ], [ 3, 4 ], [ 3, 5 ], 
  [ 4, 4 ], [ 4, 1 ], [ 4, 2 ], [ 4, 5 ], [ 5, 3 ], [ 5, 1 ], [ 5, 3 ] ]
gap> gr := DigraphFromDiSparse6String(".CaoJG_hF");
<immutable multidigraph with 4 vertices, 8 edges>
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 1, 3 ], [ 2, 1 ], [ 2, 4 ], [ 2, 4 ], [ 3, 3 ], [ 4, 1 ], 
  [ 4, 3 ] ]
gap> p1 := (1, 5, 4, 2, 3);
(1,5,4,2,3)
gap> OnDigraphs(gr, p1);
Error, the 2nd argument <p> must be a permutation that permutes of the digraph\
 <D> that is the 1st argument,
gap> p2 := (1, 4)(2, 3);
(1,4)(2,3)
gap> OnDigraphs(gr, p2);
<immutable multidigraph with 4 vertices, 8 edges>
gap> DigraphEdges(last);
[ [ 1, 4 ], [ 1, 2 ], [ 2, 2 ], [ 3, 4 ], [ 3, 1 ], [ 3, 1 ], [ 4, 3 ], 
  [ 4, 2 ] ]

#  OnDigraphs: for a digraph and a transformation
gap> gr := Digraph([[2], [1, 3], []]);
<immutable digraph with 3 vertices, 3 edges>
gap> OutNeighbours(gr);
[ [ 2 ], [ 1, 3 ], [  ] ]
gap> t := Transformation([4, 2, 3, 4]);;
gap> OnDigraphs(gr, t);
Error, the 2nd argument <t> must be a transformation that maps every vertex of\
 the digraph <D> that is the 1st argument, to another vertex.
gap> t := Transformation([1, 2, 1]);;
gap> gr := OnDigraphs(gr, t);
<immutable multidigraph with 3 vertices, 3 edges>
gap> OutNeighbours(gr);
[ [ 2 ], [ 1, 1 ], [  ] ]

#  OnMultiDigraphs: for a pair of permutations
gap> gr1 := CompleteDigraph(3);
<immutable complete digraph with 3 vertices>
gap> DigraphEdges(gr1);
[ [ 1, 2 ], [ 1, 3 ], [ 2, 1 ], [ 2, 3 ], [ 3, 1 ], [ 3, 2 ] ]
gap> gr2 := OnMultiDigraphs(gr1, (1, 3), (3, 6));;
gap> DigraphEdges(gr1);;
gap> OnMultiDigraphs(gr1, [(1, 3)]);
Error, the 2nd argument <perms> must be a pair of permutations,
gap> OnMultiDigraphs(gr1, [(1, 3), (1, 7)]);
Error, the 2nd entry of the 2nd argument <perms> must permute the edges of the\
 digraph <D> that is the 1st argument,

#  InNeighboursOfVertex and InDegreeOfVertex
gap> gr := DigraphFromDiSparse6String(".IgBGLQ?Apkc");
<immutable multidigraph with 10 vertices, 6 edges>
gap> InNeighborsOfVertex(gr, 7);
[ 7 ]
gap> InNeighboursOfVertex(gr, 7);
[ 7 ]
gap> InDegreeOfVertex(gr, 7);
1
gap> InNeighboursOfVertex(gr, 11);
Error, the 2nd argument <v> is not a vertex of the 1st argument <D>,
gap> InDegreeOfVertex(gr, 11);
Error, the 2nd argument <v> is not a vertex of the 1st argument <D>,
gap> gr := DigraphFromDiSparse6String(".CgXo?eWCaJ");
<immutable multidigraph with 4 vertices, 11 edges>
gap> InNeighboursOfVertex(gr, 3);
[ 2 ]
gap> InDegreeOfVertex(gr, 3);
1
gap> InNeighbours(gr);
[ [ 1, 1 ], [ 2, 3, 4 ], [ 2 ], [ 1, 2, 3, 3, 3 ] ]
gap> InNeighboursOfVertex(gr, 4);
[ 1, 2, 3, 3, 3 ]
gap> InDegreeOfVertex(gr, 4);
5
gap> InDegrees(gr);
[ 2, 3, 1, 5 ]
gap> InDegreeOfVertex(gr, 2);
3

#  OutNeighboursOfVertex and OutDegreeOfVertex
gap> gr := DigraphFromDiSparse6String(".Ig??OaDgDQ~");
<immutable multidigraph with 10 vertices, 8 edges>
gap> OutNeighborsOfVertex(gr, 2);
[  ]
gap> OutNeighboursOfVertex(gr, 2);
[  ]
gap> OutDegreeOfVertex(gr, 2);
0
gap> OutNeighboursOfVertex(gr, 5);
[ 1, 1, 2, 2, 3, 3 ]
gap> OutDegreeOfVertex(gr, 5);
6
gap> OutNeighboursOfVertex(gr, 12);
Error, the 2nd argument <v> is not a vertex of the 1st argument <D>,
gap> OutDegreeOfVertex(gr, 12);
Error, the 2nd argument <v> is not a vertex of the 1st argument <D>,
gap> gr := Digraph([[2, 2, 2, 2], [2, 2]]);
<immutable multidigraph with 2 vertices, 6 edges>
gap> OutNeighboursOfVertex(gr, 2);
[ 2, 2 ]
gap> OutDegreeOfVertex(gr, 2);
2
gap> OutDegrees(gr);
[ 4, 2 ]
gap> OutDegreeOfVertex(gr, 1);
4

#  InducedSubdigraph
gap> r := rec(DigraphNrVertices := 8,
> DigraphSource := [1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 5, 5, 5, 5, 5, 5],
> DigraphRange := [1, 1, 2, 3, 3, 4, 1, 1, 3, 4, 5, 1, 3, 4, 4, 5, 7]);;
gap> gr := Digraph(r);
<immutable multidigraph with 8 vertices, 17 edges>
gap> InducedSubdigraph(gr, [-1]);
Error, the 2nd argument <list> must be a duplicate-free subset of the vertices\
 of the digraph <D> that is the 1st argument,
gap> InducedSubdigraph(gr, [1 .. 9]);
Error, the 2nd argument <list> must be a duplicate-free subset of the vertices\
 of the digraph <D> that is the 1st argument,
gap> InducedSubdigraph(gr, []);
<immutable empty digraph with 0 vertices>
gap> InducedSubdigraph(gr, [2 .. 6]);
<immutable multidigraph with 5 vertices, 7 edges>
gap> InducedSubdigraph(gr, [8]);
<immutable empty digraph with 1 vertex>
gap> i1 := InducedSubdigraph(gr, [1, 4, 3]);
<immutable multidigraph with 3 vertices, 6 edges>
gap> OutNeighbours(i1);
[ [ 1, 1, 3, 3, 2 ], [  ], [ 2 ] ]
gap> i2 := InducedSubdigraph(gr, [3, 4, 3, 1]);
Error, the 2nd argument <list> must be a duplicate-free subset of the vertices\
 of the digraph <D> that is the 1st argument,
gap> adj := [[2, 3, 4, 5, 6, 6, 7], [1, 1, 1, 3, 4, 5], [4], [3, 5],
> [1, 2, 2, 3, 4, 4, 6, 5, 6, 7], [], [1], []];;
gap> gr := Digraph(adj);
<immutable multidigraph with 8 vertices, 27 edges>
gap> InducedSubdigraph(gr, ["a"]);
Error, the 2nd argument <list> must be a duplicate-free subset of the vertices\
 of the digraph <D> that is the 1st argument,
gap> InducedSubdigraph(gr, [0]);
Error, the 2nd argument <list> must be a duplicate-free subset of the vertices\
 of the digraph <D> that is the 1st argument,
gap> InducedSubdigraph(gr, [2 .. 9]);
Error, the 2nd argument <list> must be a duplicate-free subset of the vertices\
 of the digraph <D> that is the 1st argument,
gap> InducedSubdigraph(gr, []);
<immutable empty digraph with 0 vertices>
gap> i1 := InducedSubdigraph(gr, [1, 3, 5, 7]);
<immutable digraph with 4 vertices, 8 edges>
gap> OutNeighbours(i1);
[ [ 2, 3, 4 ], [  ], [ 1, 2, 3, 4 ], [ 1 ] ]
gap> i2 := InducedSubdigraph(gr, [7, 5, 3, 1]);
<immutable digraph with 4 vertices, 8 edges>
gap> i1 = i2;
false
gap> IsIsomorphicDigraph(i1, i2);
true
gap> InducedSubdigraph(gr, [2 .. 8]);
<immutable multidigraph with 7 vertices, 15 edges>
gap> InducedSubdigraph(gr, [8]);
<immutable empty digraph with 1 vertex>
gap> InducedSubdigraph(gr, [7, 8]);
<immutable empty digraph with 2 vertices>
gap> gr := Digraph([[2, 4], [4, 5], [2, 5, 5], [5, 5], [3]]);
<immutable multidigraph with 5 vertices, 10 edges>
gap> gri := InducedSubdigraph(gr, [4, 2, 5]);
<immutable multidigraph with 3 vertices, 4 edges>
gap> DigraphVertexLabels(gri);
[ 4, 2, 5 ]
gap> OutNeighbours(gri);
[ [ 3, 3 ], [ 1, 3 ], [  ] ]

#  QuotientDigraph
gap> gr := CompleteDigraph(2);
<immutable complete digraph with 2 vertices>
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 2, 1 ] ]
gap> qr := QuotientDigraph(gr, [[1, 2]]);
<immutable digraph with 1 vertex, 1 edge>
gap> DigraphEdges(qr);
[ [ 1, 1 ] ]
gap> QuotientDigraph(EmptyDigraph(0), []);
<immutable empty digraph with 0 vertices>
gap> QuotientDigraph(EmptyDigraph(0), [[1]]);
Error, the 2nd argument <partition> should be an empty list, which is the only\
 valid partition of the vertices of 1st argument <D> because it has no vertice\
s,
gap> gr := Digraph([[1, 2, 3, 2], [1, 3, 2], [1, 2]]);
<immutable multidigraph with 3 vertices, 9 edges>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ], [ 1, 2 ], [ 2, 1 ], [ 2, 3 ], [ 2, 2 ], 
  [ 3, 1 ], [ 3, 2 ] ]
gap> qr := QuotientDigraph(gr, [[1, 3], [2]]);
<immutable digraph with 2 vertices, 4 edges>
gap> DigraphEdges(qr);
[ [ 1, 1 ], [ 1, 2 ], [ 2, 1 ], [ 2, 2 ] ]
gap> QuotientDigraph(gr, [3]);
Error, the 2nd argument <partition> is not a valid partition of the vertices [\
1 .. 3] of the 1st argument <D>,
gap> QuotientDigraph(gr, []);
Error, the 2nd argument <partition> is not a valid partition of the vertices [\
1 .. 3] of the 1st argument <D>,
gap> QuotientDigraph(gr, [[], []]);
Error, the 2nd argument <partition> is not a valid partition of the vertices [\
1 .. 3] of the 1st argument <D>,
gap> QuotientDigraph(gr, [[0], [1]]);
Error, the 2nd argument <partition> is not a valid partition of the vertices [\
1 .. 3] of the 1st argument <D>,
gap> QuotientDigraph(gr, [[1], [2], [0]]);
Error, the 2nd argument <partition> is not a valid partition of the vertices [\
1 .. 3] of the 1st argument <D>,
gap> QuotientDigraph(gr, [[1], [2, 4]]);
Error, the 2nd argument <partition> is not a valid partition of the vertices [\
1 .. 3] of the 1st argument <D>,
gap> QuotientDigraph(gr, [[1, 2], [2]]);
Error, the 2nd argument <partition> is not a valid partition of the vertices [\
1 .. 3] of the 1st argument <D>,
gap> QuotientDigraph(gr, [[1], [2]]);
Error, the 2nd argument <partition> is not a valid partition of the vertices [\
1 .. 3] of the 1st argument <D>,
gap> gr := Digraph(rec(
> DigraphNrVertices := 8,
> DigraphSource := [1, 1, 2, 2, 3, 4, 4, 4, 5, 5, 5, 5, 5, 6, 7, 7, 7, 7, 7, 8, 8],
> DigraphRange := [6, 7, 1, 6, 5, 1, 4, 8, 1, 3, 4, 6, 7, 7, 1, 4, 5, 6, 7, 5, 6]));
<immutable digraph with 8 vertices, 21 edges>
gap> qr := QuotientDigraph(gr, [[1], [2, 3, 5, 7], [4, 6, 8]]);
<immutable digraph with 3 vertices, 8 edges>
gap> OutNeighbours(qr);
[ [ 2, 3 ], [ 1, 2, 3 ], [ 1, 2, 3 ] ]

#  DigraphInEdges and DigraphOutEdges: for a vertex
gap> gr := Digraph([[2, 2, 2, 2, 2], [1, 1, 1, 1], [1], [3, 2]]);
<immutable multidigraph with 4 vertices, 12 edges>
gap> DigraphInEdges(gr, 1);
[ [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 3, 1 ] ]
gap> DigraphOutEdges(gr, 3);
[ [ 3, 1 ] ]
gap> DigraphOutEdges(gr, 5);
Error, the 2nd argument <v> is not a vertex of the 1st argument <D>,
gap> DigraphInEdges(gr, 1000);
Error, the 2nd argument <v> is not a vertex of the 1st argument <D>,
gap> gr := Digraph(rec(DigraphVertices := ["a", "b", "c"], DigraphSource := ["a", "a", "b"],
> DigraphRange := ["b", "b", "c"]));
<immutable multidigraph with 3 vertices, 3 edges>
gap> DigraphInEdges(gr, 1);
[  ]
gap> DigraphInEdges(gr, 2);
[ [ 1, 2 ], [ 1, 2 ] ]
gap> DigraphOutEdges(gr, 1);
[ [ 1, 2 ], [ 1, 2 ] ]

#  DigraphStronglyConnectedComponent
gap> gr := Digraph([[2, 4], [], [2, 6], [1, 3], [2, 3], [5]]);
<immutable digraph with 6 vertices, 9 edges>
gap> DigraphStronglyConnectedComponent(gr, 1);
[ 1, 4 ]
gap> DigraphStronglyConnectedComponent(gr, 2);
[ 2 ]
gap> DigraphStronglyConnectedComponent(gr, 3);
[ 3, 6, 5 ]
gap> DigraphStronglyConnectedComponent(gr, 7);
Error, the 2nd argument <v> is not a vertex of the 1st argument <D>,

#  DigraphyConnectedComponent
gap> gr := Digraph([[2, 4], [], [2, 6], [1, 3], [2, 3], [5]]);
<immutable digraph with 6 vertices, 9 edges>
gap> DigraphConnectedComponent(gr, 3);
[ 1, 2, 3, 4, 5, 6 ]
gap> DigraphConnectedComponent(gr, 7);
Error, the 2nd argument <v> is not a vertex of the 1st argument <D>,

#  IsDigraphEdge

# CycleDigraph with source/range
gap> gr := CycleDigraph(1000);
<immutable cycle digraph with 1000 vertices>
gap> IsDigraphEdge(gr, [1]);
false
gap> IsDigraphEdge(gr, ["a", 2]);
false
gap> IsDigraphEdge(gr, [1, "a"]);
false
gap> IsDigraphEdge(gr, [1001, 1]);
false
gap> IsDigraphEdge(gr, [1, 1001]);
false
gap> IsDigraphEdge(gr, [100, 101]);
true
gap> IsDigraphEdge(gr, [1000, 1]);
true
gap> IsDigraphEdge(gr, [1000, 600]);
false
gap> out := List([1 .. 999], x -> [x + 1]);;
gap> Add(out, [1]);;

# CycleDigraph with OutNeighbours
gap> gr := Digraph(out);
<immutable digraph with 1000 vertices, 1000 edges>
gap> IsDigraphEdge(gr, [1]);
false
gap> IsDigraphEdge(gr, ["a", 2]);
false
gap> IsDigraphEdge(gr, [1, "a"]);
false
gap> IsDigraphEdge(gr, [1001, 1]);
false
gap> IsDigraphEdge(gr, [1, 1001]);
false
gap> IsDigraphEdge(gr, [100, 101]);
true
gap> IsDigraphEdge(gr, [1000, 1]);
true
gap> IsDigraphEdge(gr, [1000, 600]);
false
gap> gr := Digraph(rec(DigraphNrVertices := 2, DigraphSource := [1], DigraphRange := [2]));
<immutable digraph with 2 vertices, 1 edge>
gap> IsDigraphEdge(gr, [2, 1]);
false
gap> IsDigraphEdge(gr, [1, 1]);
false

# A bigger digraph with OutNeighbours
gap> gr := CompleteDigraph(500);
<immutable complete digraph with 500 vertices>
gap> IsDigraphEdge(gr, [200, 199]);
true
gap> IsDigraphEdge(gr, [499, 499]);
false
gap> IsDigraphEdge(gr, [249, 251]);
true
gap> gr := EmptyDigraph(1000000);
<immutable empty digraph with 1000000 vertices>
gap> IsDigraphEdge(gr, [9999, 9999]);
false
gap> gr := CompleteDigraph(10);
<immutable complete digraph with 10 vertices>
gap> mat := AdjacencyMatrix(gr);;
gap> IsDigraphEdge(gr, [5, 5]);
false
gap> IsDigraphEdge(gr, [5, 6]);
true
gap> gr := Digraph([[1, 1], [2]]);
<immutable multidigraph with 2 vertices, 3 edges>
gap> mat := AdjacencyMatrix(gr);;
gap> IsDigraphEdge(gr, [1, 1]);
true
gap> IsDigraphEdge(gr, [1, 2]);
false

# Adjacency function
gap> adj := function(i, j) return i = j * 2; end;
function( i, j ) ... end
gap> gr := Digraph([1 .. 20], adj);;
gap> IsDigraphEdge(gr, [1, 4]);
false
gap> IsDigraphEdge(gr, 3, 6);
false
gap> IsDigraphEdge(gr, 12, 6);
true
gap> IsDigraphEdge(gr, 26, 13);
false

#  DigraphAddEdges
gap> gr := RandomDigraph(100);;
gap> DigraphAddEdges(gr, []);;
gap> gr = last;
true
gap> DigraphAddEdges(gr, [12]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphAddEdge' on 2 arguments
gap> DigraphAddEdges(gr, [[12]]);
Error, the 2nd argument <edge> must be a list of length 2,
gap> DigraphAddEdges(gr, [[12, 13, 14], [11, 10]]);
Error, the 2nd argument <edge> must be a list of length 2,
gap> DigraphAddEdges(gr, [[-2, 3], ["a"]]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphAddEdge' on 3 arguments
gap> DigraphAddEdges(gr, [[11, 10], [12, 13, 14]]);
Error, the 2nd argument <edge> must be a list of length 2,
gap> DigraphAddEdges(gr, [[4, 5], [1, 120], [1, 1]]);
Error, the 2nd argument <ran> must be a vertex of the digraph <D> that is the \
1st argument,
gap> DigraphAddEdges(gr, [[4, 5], [120, 1], [1, 1]]);
Error, the 2nd argument <src> must be a vertex of the digraph <D> that is the \
1st argument,
gap> gr := Digraph([[2, 2], [1, 3, 2], [2, 1], [1]]);
<immutable multidigraph with 4 vertices, 8 edges>
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 1, 2 ], [ 2, 1 ], [ 2, 3 ], [ 2, 2 ], [ 3, 2 ], [ 3, 1 ], 
  [ 4, 1 ] ]
gap> gr2 := DigraphAddEdges(gr, [[2, 1], [3, 3], [2, 4], [3, 3]]);
<immutable multidigraph with 4 vertices, 12 edges>
gap> DigraphEdges(gr2);
[ [ 1, 2 ], [ 1, 2 ], [ 2, 1 ], [ 2, 3 ], [ 2, 2 ], [ 2, 1 ], [ 2, 4 ], 
  [ 3, 2 ], [ 3, 1 ], [ 3, 3 ], [ 3, 3 ], [ 4, 1 ] ]
gap> gr3 := Digraph(rec(DigraphNrVertices := DigraphNrVertices(gr),
>                         DigraphSource := ShallowCopy(DigraphSource(gr)),
>                         DigraphRange := ShallowCopy(DigraphRange(gr))));
<immutable multidigraph with 4 vertices, 8 edges>
gap> gr4 := DigraphAddEdges(gr3, [[2, 1], [3, 3], [2, 4], [3, 3]]);
<immutable multidigraph with 4 vertices, 12 edges>
gap> gr2 = gr4;
true
gap> gr := Digraph([[1, 2], [], [1]]);
<immutable digraph with 3 vertices, 3 edges>
gap> gr1 := DigraphAddEdges(gr, []);
<immutable digraph with 3 vertices, 3 edges>
gap> gr = gr1;
true
gap> DigraphAddEdges(gr, [3]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphAddEdge' on 2 arguments
gap> DigraphAddEdges(gr, [[3]]);
Error, the 2nd argument <edge> must be a list of length 2,
gap> DigraphAddEdges(gr, ["ab"]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphAddEdge' on 3 arguments
gap> DigraphAddEdges(gr, [[-1, -2]]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphAddEdge' on 3 arguments
gap> DigraphAddEdges(gr, [[1, 2], [1, 2, 3]]);
Error, the 2nd argument <edge> must be a list of length 2,
gap> DigraphAddEdges(gr, [[4, 2]]);
Error, the 2nd argument <src> must be a vertex of the digraph <D> that is the \
1st argument,
gap> DigraphAddEdges(gr, [[2, 4]]);
Error, the 2nd argument <ran> must be a vertex of the digraph <D> that is the \
1st argument,
gap> DigraphAddEdges(gr, [[2, 3], [2, 3]]);
<immutable multidigraph with 3 vertices, 5 edges>
gap> DigraphEdges(last);
[ [ 1, 1 ], [ 1, 2 ], [ 2, 3 ], [ 2, 3 ], [ 3, 1 ] ]
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 2 ], [ 3, 1 ] ]

#  DigraphAddEdge
gap> gr := RandomDigraph(10);;
gap> DigraphAddEdge(gr, [1, 2, 3]);
Error, the 2nd argument <edge> must be a list of length 2,
gap> DigraphAddEdge(gr, ["a", "a"]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphAddEdge' on 3 arguments
gap> DigraphAddEdge(gr, [1, "a"]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphAddEdge' on 3 arguments
gap> DigraphAddEdge(gr, [11, 1]);
Error, the 2nd argument <src> must be a vertex of the digraph <D> that is the \
1st argument,
gap> DigraphAddEdge(gr, [1, 11]);
Error, the 2nd argument <ran> must be a vertex of the digraph <D> that is the \
1st argument,
gap> gr := EmptyDigraph(2);
<immutable empty digraph with 2 vertices>
gap> DigraphAddEdge(gr, [1, 2]);
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphEdges(last);
[ [ 1, 2 ] ]

#  DigraphAddVertices
gap> gr := Digraph([[1]]);;
gap> gr2 := DigraphAddVertices(gr, 3);
<immutable digraph with 4 vertices, 1 edge>
gap> DigraphVertices(gr2);
[ 1 .. 4 ]
gap> DigraphEdges(gr) = DigraphEdges(gr2);
true
gap> gr2 := DigraphAddVertices(gr, [SymmetricGroup(2), Group(())]);
<immutable digraph with 3 vertices, 1 edge>
gap> DigraphVertices(gr2);
[ 1 .. 3 ]
gap> DigraphEdges(gr) = DigraphEdges(gr2);
true
gap> DigraphVertexLabels(gr2);
[ 1, Sym( [ 1 .. 2 ] ), Group(()) ]
gap> gr := Digraph([[1]]);;
gap> SetDigraphVertexLabels(gr, [AlternatingGroup(5)]);
gap> gr2 := DigraphAddVertices(gr, [SymmetricGroup(2), Group(())]);
<immutable digraph with 3 vertices, 1 edge>
gap> DigraphVertexLabels(gr2);
[ Alt( [ 1 .. 5 ] ), Sym( [ 1 .. 2 ] ), Group(()) ]
gap> gr := Digraph(rec(DigraphNrVertices := 1, DigraphSource := [1], DigraphRange := [1]));
<immutable digraph with 1 vertex, 1 edge>
gap> gr2 := DigraphAddVertices(gr, 2);
<immutable digraph with 3 vertices, 1 edge>
gap> DigraphVertexLabels(gr2);
[ 1, 2, 3 ]
gap> SetDigraphVertexLabels(gr, [true]);
gap> gr2 := DigraphAddVertices(gr, 2);
<immutable digraph with 3 vertices, 1 edge>
gap> DigraphVertexLabels(gr2);
[ true, 2, 3 ]
gap> gr := Digraph(rec(DigraphNrVertices := 1, DigraphSource := [1], DigraphRange := [1]));;
gap> gr2 := DigraphAddVertices(gr, [SymmetricGroup(2), Group(())]);
<immutable digraph with 3 vertices, 1 edge>
gap> DigraphVertexLabels(gr2);
[ 1, Sym( [ 1 .. 2 ] ), Group(()) ]
gap> gr := Digraph(rec(DigraphNrVertices := 1, DigraphSource := [1], DigraphRange := [1]));;
gap> SetDigraphVertexLabels(gr, [AlternatingGroup(5)]);
gap> gr2 := DigraphAddVertices(gr, [SymmetricGroup(2), Group(())]);
<immutable digraph with 3 vertices, 1 edge>
gap> DigraphVertexLabels(gr2);
[ Alt( [ 1 .. 5 ] ), Sym( [ 1 .. 2 ] ), Group(()) ]
gap> DigraphAddVertices(gr2, -1);
Error, the 2nd argument <m> must be a non-negative integer,
gap> IsIdenticalObj(gr2, DigraphAddVertices(gr2, 0));
true
gap> IsIdenticalObj(gr2, DigraphAddVertices(gr2, []));
true

#  DigraphAddVertices (redundant three-argument version)
gap> D := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> DigraphVertexLabels(D);
[ 1 ]
gap> DigraphAddVertices(D, 2, [fail]);
Error, the list <labels> (3rd argument) must have length <m> (2nd argument),
gap> D := DigraphAddVertices(D, 2, [fail, true]);
<immutable digraph with 3 vertices, 1 edge>
gap> DigraphVertexLabels(D);
[ 1, fail, true ]

#  DigraphAddVertex
gap> gr := CompleteDigraph(1);
<immutable empty digraph with 1 vertex>
gap> DigraphVertices(gr);
[ 1 ]
gap> gr2 := DigraphAddVertex(gr);
<immutable empty digraph with 2 vertices>
gap> DigraphVertices(gr2);
[ 1, 2 ]
gap> DigraphEdges(gr) = DigraphEdges(gr2);
true
gap> gr := DigraphAddEdge(gr, [1, 1]);
<immutable digraph with 1 vertex, 1 edge>
gap> DigraphVertices(gr);
[ 1 ]
gap> gr2 := DigraphAddVertex(gr);
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphVertices(gr2);
[ 1, 2 ]
gap> DigraphEdges(gr) = DigraphEdges(gr2);
true
gap> gr2 := DigraphAddVertex(gr, SymmetricGroup(2));
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphVertices(gr2);
[ 1, 2 ]
gap> DigraphEdges(gr) = DigraphEdges(gr2);
true
gap> DigraphVertexLabels(gr);
[ 1 ]
gap> DigraphVertexLabels(gr2);
[ 1, Sym( [ 1 .. 2 ] ) ]

#  DigraphRemoveVertex
gap> gr := DigraphFromDigraph6String("&MU?GAa?SDCFStK`???d?@LWOq[{DECO?U?");
<immutable digraph with 14 vertices, 54 edges>
gap> DigraphRemoveVertex(gr, "a");
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphRemoveVertex' on 2 arguments
gap> DigraphRemoveVertex(gr, 0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphRemoveVertex' on 2 arguments
gap> DigraphRemoveVertex(gr, 15);
<immutable digraph with 14 vertices, 54 edges>
gap> gr2 := DigraphRemoveVertex(gr, 10);;
gap> DigraphNrVertices(gr2);
13
gap> DigraphNrEdges(gr2) =
> DigraphNrEdges(gr) - OutDegreeOfVertex(gr, 10) - InDegreeOfVertex(gr, 10);
true
gap> D := CycleDigraph(IsMutableDigraph, 5);
<mutable digraph with 5 vertices, 5 edges>
gap> DigraphRemoveVertex(D, 1);
<mutable digraph with 4 vertices, 3 edges>
gap> DigraphVertexLabels(D);
[ 2, 3, 4, 5 ]

#  DigraphRemoveVertices
gap> gr := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> gr2 := DigraphRemoveVertices(gr, []);
<immutable digraph with 4 vertices, 12 edges>
gap> gr = gr2;
true
gap> gr2 := DigraphRemoveVertices(gr, [0]);
Error, the 2nd argument <list> must be a duplicate-free list of positive integ\
ers,
gap> gr2 := DigraphRemoveVertices(gr, [1, "a"]);
Error, the 2nd argument <list> must be a duplicate-free list of positive integ\
ers,
gap> gr2 := DigraphRemoveVertices(gr, [1, 1]);
Error, the 2nd argument <list> must be a duplicate-free list of positive integ\
ers,
gap> gr2 := DigraphRemoveVertices(gr, [1, 0]);
Error, the 2nd argument <list> must be a duplicate-free list of positive integ\
ers,
gap> gr2 := DigraphRemoveVertices(gr, [1, 5]);
<immutable digraph with 3 vertices, 6 edges>
gap> gr2 := DigraphRemoveVertices(gr, [1, 3]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsCompleteDigraph(gr2);
true
gap> DigraphVertexLabels(gr2);
[ 2, 4 ]
gap> gr3 := DigraphRemoveVertices(gr, [1 .. 4]);
<immutable empty digraph with 0 vertices>
gap> gr := Digraph(rec(DigraphNrVertices := 4,
> DigraphSource := [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4],
> DigraphRange := [1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]));
<immutable digraph with 4 vertices, 16 edges>
gap> IsCompleteDigraph(gr);
false
gap> SetDigraphVertexLabels(gr, [(), (1, 2), (1, 2, 3), (1, 2, 3, 4)]);
gap> gr2 := DigraphRemoveVertices(gr, [1 .. 4]);
<immutable empty digraph with 0 vertices>
gap> gr3 := DigraphRemoveVertices(gr, [2, 3]);
<immutable digraph with 2 vertices, 4 edges>
gap> DigraphVertexLabels(gr3);
[ (), (1,2,3,4) ]
gap> gr4 := DigraphRemoveVertices(gr, []);
<immutable digraph with 4 vertices, 16 edges>
gap> gr = gr4;
true
gap> gr := Digraph([[1, 10], [], [], [3], [3, 4, 10], [1, 3, 8],
> [9], [9], [3], [3, 5, 10]]);
<immutable digraph with 10 vertices, 15 edges>
gap> DigraphSinks(gr);
[ 2, 3 ]
gap> DigraphRemoveVertices(gr, DigraphSinks(gr));
<immutable digraph with 8 vertices, 10 edges>

#  DigraphReverseEdge and DigraphReverseEdges
gap> gr := Digraph([[1, 1]]);
<immutable multidigraph with 1 vertex, 2 edges>
gap> DigraphReverseEdges(gr, [[2, 2]]);
Error, the 1st argument <D> must be a digraph with no multiple edges,
gap> DigraphReverseEdges(gr, [2]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphReverseEdge' on 2 arguments
gap> gr := CompleteDigraph(100);
<immutable complete digraph with 100 vertices>
gap> DigraphReverseEdges(gr, "a");
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphReverseEdge' on 2 arguments
gap> DigraphReverseEdges(gr, Group(()));
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphReverseEdges' on 2 arguments
gap> DigraphReverseEdges(gr, [0, 0]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphReverseEdge' on 2 arguments
gap> DigraphReverseEdges(gr, [[0]]);
Error, the 2nd argument <e> must be a list of length 2,
gap> DigraphReverseEdges(gr, [[1], [1]]);
Error, the 2nd argument <e> must be a list of length 2,
gap> edges := ShallowCopy(DigraphEdges(gr));;
gap> gr = DigraphReverseEdges(gr, edges);
Error, the 1st argument <D> must be a digraph with no multiple edges,
gap> gr = DigraphReverseEdges(gr, [1 .. DigraphNrEdges(gr)]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphReverseEdge' on 2 arguments
gap> DigraphReverseEdge(gr, 2) = DigraphReverseEdge(gr, [1, 3]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphReverseEdge' on 2 arguments
gap> gr = DigraphReverseEdges(gr, []);
true
gap> gr := CycleDigraph(100);
<immutable cycle digraph with 100 vertices>
gap> edges := ShallowCopy(DigraphEdges(gr));;
gap>  gr = DigraphReverseEdges(gr, edges);
false
gap> gr2 := DigraphReverseEdges(gr, edges);
<immutable digraph with 100 vertices, 100 edges>
gap> gr = gr2;
false
gap> edges2 := ShallowCopy(DigraphEdges(gr2));;
gap> gr = DigraphReverseEdges(gr2, edges2);
true
gap> gr = DigraphReverseEdges(gr, [1 .. DigraphNrEdges(gr)]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphReverseEdge' on 2 arguments
gap> DigraphReverseEdge(gr, 1) = DigraphReverseEdge(gr, [1, 2]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphReverseEdge' on 2 arguments
gap> gr = DigraphReverseEdges(gr, []);
true

#  DigraphFloydWarshall
gap> func := function(mat, i, j, k)
>   if (i = j) or (mat[i][k] <> 0 and mat[k][j] <> 0) then
>     mat[i][j] := 1;
>   fi;
> end;
function( mat, i, j, k ) ... end
gap> gr := Digraph(
> [[1, 2, 4, 5, 7], [1, 2], [3, 7], [2, 10], [2, 6], [2, 7],
>  [], [3, 4], [1, 10], [1, 3, 9]]);
<immutable digraph with 10 vertices, 22 edges>
gap> rtclosure := DigraphFloydWarshall(gr, func, 0, 1);;
gap> grrt := DigraphByAdjacencyMatrix(rtclosure);
<immutable digraph with 10 vertices, 76 edges>
gap> grrt = DigraphReflexiveTransitiveClosure(gr);
true
gap> func := function(mat, i, j, k)
>   if mat[i][k] <> 0 and mat[k][j] <> 0 then
>     mat[i][j] := 1;
>   fi;
> end;
function( mat, i, j, k ) ... end
gap> gr := Digraph(rec(
> DigraphNrVertices := 10,
> DigraphSource := [1, 2, 2, 3, 4, 5, 6, 7, 10, 10, 10],
> DigraphRange := [6, 9, 5, 7, 3, 4, 8, 4, 7, 9, 8]));
<immutable digraph with 10 vertices, 11 edges>
gap> tclosure := DigraphFloydWarshall(gr, func, 0, 1);;
gap> grt := DigraphByAdjacencyMatrix(tclosure);
<immutable digraph with 10 vertices, 25 edges>
gap> grt = DigraphTransitiveClosure(gr);
true
gap> func := function(mat, i, j, k)
>   if (i = j) or (mat[i][k] <> 0 and mat[k][j] <> 0) then
>     mat[i][j] := 1;
>   fi;
> end;
function( mat, i, j, k ) ... end
gap> gr := Digraph(
> [[1, 2, 4, 5, 7], [1, 2], [3, 7], [2, 10], [2, 6], [2, 7],
>  [], [3, 4], [1, 10], [1, 3, 9]]);
<immutable digraph with 10 vertices, 22 edges>
gap> rtclosure := DigraphFloydWarshall(gr, func, 0, 1);;
gap> grrt := DigraphByAdjacencyMatrix(rtclosure);
<immutable digraph with 10 vertices, 76 edges>
gap> grrt = DigraphReflexiveTransitiveClosure(gr);
true
gap> func := function(mat, i, j, k)
>   if mat[i][k] <> 0 and mat[k][j] <> 0 then
>     mat[i][j] := 1;
>   fi;
> end;
function( mat, i, j, k ) ... end
gap> gr := DigraphFromDigraph6String("&I???@?A`?G?GCCS@??");
<immutable digraph with 10 vertices, 11 edges>
gap> tclosure := DigraphFloydWarshall(gr, func, 0, 1);;
gap> grt := DigraphByAdjacencyMatrix(tclosure);
<immutable digraph with 10 vertices, 25 edges>
gap> grt = DigraphTransitiveClosure(gr);
true

#  DigraphDisjointUnion
gap> gr := CycleDigraph(1000);
<immutable cycle digraph with 1000 vertices>
gap> gr2 := CompleteDigraph(100);
<immutable complete digraph with 100 vertices>
gap> DigraphDisjointUnion(gr) = gr;
true
gap> DigraphDisjointUnion([[]]);
Error, the arguments must be digraphs by out-neighbours, or a single non-empty\
 list of digraphs by out-neighbours,
gap> DigraphDisjointUnion([gr], [gr]);
Error, the arguments must be digraphs by out-neighbours, or a single non-empty\
 list of digraphs by out-neighbours,
gap> DigraphDisjointUnion(gr, Group(()));
Error, the arguments must be digraphs by out-neighbours, or a single non-empty\
 list of digraphs by out-neighbours,
gap> DigraphDisjointUnion(gr, gr);
<immutable digraph with 2000 vertices, 2000 edges>
gap> DigraphDisjointUnion([gr2, gr2]);
<immutable digraph with 200 vertices, 19800 edges>
gap> DigraphDisjointUnion(gr, gr2);
<immutable digraph with 1100 vertices, 10900 edges>
gap> gr := CycleDigraph(1000);;
gap> DigraphDisjointUnion(gr2, gr);
<immutable digraph with 1100 vertices, 10900 edges>
gap> gr1 := Digraph([[2, 2, 3], [3], [2]]);
<immutable multidigraph with 3 vertices, 5 edges>
gap> gr2 := Digraph([[1, 2], [1]]);
<immutable digraph with 2 vertices, 3 edges>
gap> gr3 := Digraph(rec(DigraphNrVertices := 2,
> DigraphSource := [1, 1, 2], DigraphRange := [2, 1, 1]));;
gap> gr2 = gr3;
true
gap> u1 := DigraphDisjointUnion(gr1, gr2);
<immutable multidigraph with 5 vertices, 8 edges>
gap> u2 := DigraphDisjointUnion(gr1, gr3);
<immutable multidigraph with 5 vertices, 8 edges>
gap> u1 = u2;
true
gap> n := 10;;
gap> DigraphDisjointUnion(List([1 .. n], x -> EmptyDigraph(x))) =
> EmptyDigraph(Int(n * (n + 1) / 2));
true
gap> gr := DigraphDisjointUnion(List([2 .. 5], x -> ChainDigraph(x)));
<immutable digraph with 14 vertices, 10 edges>
gap> gr := DigraphAddEdges(gr, [[2, 3], [5, 6], [9, 10]]);
<immutable digraph with 14 vertices, 13 edges>
gap> gr = ChainDigraph(14);
true
gap> D := CycleDigraph(IsMutableDigraph, 2);
<mutable digraph with 2 vertices, 2 edges>
gap> DigraphVertexLabels(D);
[ 1, 2 ]
gap> DigraphDisjointUnion(D, D);
<mutable digraph with 4 vertices, 4 edges>
gap> DigraphVertexLabels(D);
[ 1 .. 4 ]

#  DigraphEdgeUnion
gap> gr1 := DigraphFromDigraph6String("&I????@A_?AA???@d??");
<immutable digraph with 10 vertices, 9 edges>
gap> gr2 := DigraphFromDiSparse6String(".H`OS?aEMC?bneOY`l_?QCJ");
<immutable multidigraph with 9 vertices, 20 edges>
gap> DigraphEdgeUnion(gr1) = gr1;
true
gap> DigraphEdgeUnion([[]]);
Error, the arguments must be digraphs by out-neighbours, or a single list of d\
igraphs by out-neighbours,
gap> DigraphEdgeUnion([gr1], [gr1]);
Error, the arguments must be digraphs by out-neighbours, or a single list of d\
igraphs by out-neighbours,
gap> DigraphEdgeUnion(gr1, Group(()));
Error, the arguments must be digraphs by out-neighbours, or a single list of d\
igraphs by out-neighbours,
gap> m1 := DigraphEdgeUnion(gr1, gr2);
<immutable multidigraph with 10 vertices, 29 edges>
gap> m2 := DigraphEdgeUnion(gr2, gr1);
<immutable multidigraph with 10 vertices, 29 edges>
gap> gr1 := Digraph([[2], [], [4], [], [6], []]);
<immutable digraph with 6 vertices, 3 edges>
gap> gr2 := Digraph([[], [3], [], [5], [], [1]]);
<immutable digraph with 6 vertices, 3 edges>
gap> m := DigraphEdgeUnion(gr1, gr2);
<immutable digraph with 6 vertices, 6 edges>
gap> m = CycleDigraph(6);
true
gap> m = DigraphEdgeUnion(gr2, gr1);
true
gap> DigraphEdgeUnion(EmptyDigraph(0), EmptyDigraph(0)) = EmptyDigraph(0);
true
gap> DigraphEdgeUnion(EmptyDigraph(5), EmptyDigraph(3)) = EmptyDigraph(5);
true
gap> gr := DigraphNC([[6, 3, 3, 10, 6], [4], [5, 1], [5, 4, 6],
> [9], [8], [7, 6], [8, 10, 8, 1], [], [2]]);;
gap> gr := DigraphEdgeUnion(gr, gr);
<immutable multidigraph with 10 vertices, 40 edges>
gap> OutNeighbours(gr);
[ [ 6, 3, 3, 10, 6, 6, 3, 3, 10, 6 ], [ 4, 4 ], [ 5, 1, 5, 1 ], 
  [ 5, 4, 6, 5, 4, 6 ], [ 9, 9 ], [ 8, 8 ], [ 7, 6, 7, 6 ], 
  [ 8, 10, 8, 1, 8, 10, 8, 1 ], [  ], [ 2, 2 ] ]
gap> gr := DigraphEdgeUnion(ChainDigraph(2), ChainDigraph(3), ChainDigraph(4));
<immutable multidigraph with 4 vertices, 6 edges>
gap> OutNeighbours(gr);
[ [ 2, 2, 2 ], [ 3, 3 ], [ 4 ], [  ] ]

#  DigraphJoin
gap> gr := CompleteDigraph(20);
<immutable complete digraph with 20 vertices>
gap> gr2 := EmptyDigraph(10);
<immutable empty digraph with 10 vertices>
gap> DigraphJoin(gr) = gr;
true
gap> DigraphJoin([[]]);
Error, the arguments must be digraphs by out-neighbours, or a single list of d\
igraphs by out-neighbours,
gap> DigraphJoin([gr], [gr]);
Error, the arguments must be digraphs by out-neighbours, or a single list of d\
igraphs by out-neighbours,
gap> DigraphJoin([gr, Group(())]);
Error, the arguments must be digraphs by out-neighbours, or a single list of d\
igraphs by out-neighbours,
gap> DigraphJoin(gr, gr2);
<immutable digraph with 30 vertices, 780 edges>
gap> DigraphJoin(gr, EmptyDigraph(0));
<immutable digraph with 20 vertices, 380 edges>
gap> DigraphJoin(EmptyDigraph(0), CycleDigraph(1000));
<immutable digraph with 1000 vertices, 1000 edges>
gap> DigraphJoin(EmptyDigraph(0), EmptyDigraph(0));
<immutable empty digraph with 0 vertices>
gap> DigraphJoin(EmptyDigraph(5), EmptyDigraph(5));
<immutable digraph with 10 vertices, 50 edges>
gap> gr1 := Digraph([[2, 2, 3], [3], [2]]);
<immutable multidigraph with 3 vertices, 5 edges>
gap> gr2 := Digraph([[1, 2], [1]]);
<immutable digraph with 2 vertices, 3 edges>
gap> gr3 := Digraph(rec(DigraphNrVertices := 2,
> DigraphSource := [1, 1, 2], DigraphRange := [2, 1, 1]));;
gap> gr2 = gr3;
true
gap> j1 := DigraphJoin(gr1, gr2);
<immutable multidigraph with 5 vertices, 20 edges>
gap> j2 := DigraphJoin(gr1, gr3);
<immutable multidigraph with 5 vertices, 20 edges>
gap> u1 = u2;
true
gap> gr := DigraphJoin(ChainDigraph(2), CycleDigraph(4), EmptyDigraph(0));
<immutable digraph with 6 vertices, 21 edges>
gap> mat := [
> [0, 1, 1, 1, 1, 1],
> [0, 0, 1, 1, 1, 1],
> [1, 1, 0, 1, 0, 0],
> [1, 1, 0, 0, 1, 0],
> [1, 1, 0, 0, 0, 1],
> [1, 1, 1, 0, 0, 0]];;
gap> AdjacencyMatrix(gr) = mat;
true
gap> DigraphJoin(List([1 .. 5], x -> EmptyDigraph(1))) = CompleteDigraph(5);
true
gap> DigraphJoin(EmptyDigraph(3), EmptyDigraph(2)) =
> CompleteBipartiteDigraph(3, 2);
true

#  OutNeighboursMutableCopy
gap> gr := Digraph([[3], [10], [6], [3], [10], [], [6], [3], [], [3]]);
<immutable digraph with 10 vertices, 8 edges>
gap> out1 := OutNeighbours(gr);
[ [ 3 ], [ 10 ], [ 6 ], [ 3 ], [ 10 ], [  ], [ 6 ], [ 3 ], [  ], [ 3 ] ]
gap> IsMutable(out1);
false
gap> IsMutable(out1[1]);
false
gap> out2 := OutNeighboursMutableCopy(gr);
[ [ 3 ], [ 10 ], [ 6 ], [ 3 ], [ 10 ], [  ], [ 6 ], [ 3 ], [  ], [ 3 ] ]
gap> IsMutable(out2);
true
gap> IsMutable(out2[1]);
true
gap> out3 := OutNeighborsMutableCopy(gr);
[ [ 3 ], [ 10 ], [ 6 ], [ 3 ], [ 10 ], [  ], [ 6 ], [ 3 ], [  ], [ 3 ] ]
gap> IsMutable(out3);
true
gap> IsMutable(out3[1]);
true

#  InNeighboursMutableCopy
gap> gr := Digraph([[3], [10], [6], [3], [10], [], [6], [3], [], [3]]);
<immutable digraph with 10 vertices, 8 edges>
gap> in1 := InNeighbours(gr);
[ [  ], [  ], [ 1, 4, 8, 10 ], [  ], [  ], [ 3, 7 ], [  ], [  ], [  ], 
  [ 2, 5 ] ]
gap> IsMutable(in1);
false
gap> IsMutable(in1[1]);
false
gap> in2 := InNeighboursMutableCopy(gr);
[ [  ], [  ], [ 1, 4, 8, 10 ], [  ], [  ], [ 3, 7 ], [  ], [  ], [  ], 
  [ 2, 5 ] ]
gap> IsMutable(in2);
true
gap> IsMutable(in2[1]);
true
gap> in3 := InNeighborsMutableCopy(gr);
[ [  ], [  ], [ 1, 4, 8, 10 ], [  ], [  ], [ 3, 7 ], [  ], [  ], [  ], 
  [ 2, 5 ] ]
gap> IsMutable(in3);
true
gap> IsMutable(in3[1]);
true

#  AdjacencyMatrixMutableCopy
gap> gr := CycleDigraph(3);;
gap> adj := AdjacencyMatrixMutableCopy(gr);;
gap> PrintArray(adj);
[ [  0,  1,  0 ],
  [  0,  0,  1 ],
  [  1,  0,  0 ] ]
gap> adj[3][2] := 1;;
gap> PrintArray(adj);
[ [  0,  1,  0 ],
  [  0,  0,  1 ],
  [  1,  1,  0 ] ]

#  BooleanAdjacencyMatrixMutableCopy
gap> gr := Digraph([[3], [2, 3], [3], [2, 4]]);;
gap> adj := BooleanAdjacencyMatrixMutableCopy(gr);;
gap> PrintArray(adj);
[ [  false,  false,   true,  false ],
  [  false,   true,   true,  false ],
  [  false,  false,   true,  false ],
  [  false,   true,  false,   true ] ]
gap> adj[3][1] := true;;
gap> PrintArray(adj);
[ [  false,  false,   true,  false ],
  [  false,   true,   true,  false ],
  [   true,  false,   true,  false ],
  [  false,   true,  false,   true ] ]

#  DigraphRemoveAllMultipleEdges
gap> gr1 := Digraph([[1, 1, 2, 1], [1]]);
<immutable multidigraph with 2 vertices, 5 edges>
gap> gr2 := DigraphRemoveAllMultipleEdges(gr1);
<immutable digraph with 2 vertices, 3 edges>
gap> OutNeighbours(gr2);
[ [ 1, 2 ], [ 1 ] ]
gap> gr3 := DigraphEdgeUnion(gr1, gr1);
<immutable multidigraph with 2 vertices, 10 edges>
gap> gr4 := DigraphRemoveAllMultipleEdges(gr3);
<immutable digraph with 2 vertices, 3 edges>
gap> gr2 = gr4;
true

#  IsReachable
gap> gr1 := DigraphRemoveEdges(CycleDigraph(100), [[100, 1], [99, 100]]);
<immutable digraph with 100 vertices, 98 edges>
gap> IsReachable(gr1, 0, 1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `IsReachable' on 3 arguments
gap> IsReachable(gr1, 101, 1);
Error, the 2nd and 3rd arguments <u> and <v> must be vertices of the 1st argum\
ent <D>,
gap> IsReachable(gr1, 1, 101);
Error, the 2nd and 3rd arguments <u> and <v> must be vertices of the 1st argum\
ent <D>,
gap> IsReachable(gr1, 1, 2);
true
gap> gr1 := DigraphRemoveEdges(CycleDigraph(100), [[100, 1], [99, 100]]);;
gap> AdjacencyMatrix(gr1);;
gap> IsReachable(gr1, 1, 2);
true
gap> gr1 := DigraphRemoveEdges(CycleDigraph(100), [[100, 1], [99, 100]]);;
gap> IsReachable(gr1, 100, 1);
false
gap> gr1 := DigraphRemoveEdges(CycleDigraph(100), [[100, 1], [99, 100]]);;
gap> DigraphConnectedComponents(gr1);;
gap> IsReachable(gr1, 100, 1);
false
gap> gr1 := CycleDigraph(100);
<immutable cycle digraph with 100 vertices>
gap> IsReachable(gr1, 1, 50);
true
gap> IsReachable(gr1, 1, 1);
true
gap> gr1 := CycleDigraph(100);;
gap> DigraphStronglyConnectedComponents(gr1);;
gap> IsReachable(gr1, 1, 50);
true
gap> IsReachable(gr1, 1, 1);
true
gap> gr1 := Digraph([[2], [1], [3], []]);
<immutable digraph with 4 vertices, 3 edges>
gap> IsReachable(gr1, 1, 2);
true
gap> IsReachable(gr1, 1, 1);
true
gap> IsReachable(gr1, 3, 3);
true
gap> IsReachable(gr1, 1, 3);
false
gap> IsReachable(gr1, 4, 4);
false
gap> gr1 := Digraph([[2], [1], [3], []]);;
gap> DigraphStronglyConnectedComponents(gr1);
rec( comps := [ [ 1, 2 ], [ 3 ], [ 4 ] ], id := [ 1, 1, 2, 3 ] )
gap> IsReachable(gr1, 1, 2);
true
gap> IsReachable(gr1, 1, 1);
true
gap> IsReachable(gr1, 3, 3);
true
gap> IsReachable(gr1, 1, 3);
false
gap> IsReachable(gr1, 4, 4);
false
gap> gr := DigraphFromSparse6String(":DA_IAMALN");
<immutable digraph with 5 vertices, 16 edges>
gap> IsReachable(gr, 1, 2);
false
gap> IsReachable(gr, 1, 4);
true
gap> gr := Digraph(
> [[1, 3, 4, 5], [], [1, 3, 4, 5], [1, 3, 4, 5], [1, 3, 4, 5]]);;
gap> IsTransitiveDigraph(gr);
true
gap> IsReachable(gr, 1, 2);
false
gap> IsReachable(gr, 1, 4);
true

#  DigraphPath
gap> gr := ChainDigraph(10);
<immutable chain digraph with 10 vertices>
gap> DigraphPath(gr, 1, 2);
[ [ 1, 2 ], [ 1 ] ]
gap> DigraphPath(gr, 1, 1);
fail
gap> DigraphPath(gr, 2, 1);
fail
gap> DigraphPath(gr, 3, 8);
[ [ 3, 4, 5, 6, 7, 8 ], [ 1, 1, 1, 1, 1 ] ]
gap> DigraphPath(gr, 11, 1);
Error, the 2nd and 3rd arguments <u> and <v> must be vertices of the 1st argum\
ent <D>,
gap> DigraphPath(gr, 1, 11);
Error, the 2nd and 3rd arguments <u> and <v> must be vertices of the 1st argum\
ent <D>,
gap> DigraphPath(gr, 11, 11);
Error, the 2nd and 3rd arguments <u> and <v> must be vertices of the 1st argum\
ent <D>,

#  IteratorOfPaths
gap> gr := CompleteDigraph(5);;
gap> iter := IteratorOfPaths(gr, 2, 6);
Error, the 2nd and 3rd arguments <u> and <v> must be vertices of the 1st argum\
ent <D>,
gap> iter := IteratorOfPaths(gr, 6, 6);
Error, the 2nd and 3rd arguments <u> and <v> must be vertices of the 1st argum\
ent <D>,
gap> iter := IteratorOfPaths(gr, 6, 2);
Error, the 2nd and 3rd arguments <u> and <v> must be vertices of the 1st argum\
ent <D>,
gap> iter := IteratorOfPaths(gr, 2, 5);
<iterator>
gap> for a in iter do
>   Print(a, "\n");
> od;
[ [ 2, 1, 3, 4, 5 ], [ 1, 2, 3, 4 ] ]
[ [ 2, 1, 3, 5 ], [ 1, 2, 4 ] ]
[ [ 2, 1, 4, 3, 5 ], [ 1, 3, 3, 4 ] ]
[ [ 2, 1, 4, 5 ], [ 1, 3, 4 ] ]
[ [ 2, 1, 5 ], [ 1, 4 ] ]
[ [ 2, 3, 1, 4, 5 ], [ 2, 1, 3, 4 ] ]
[ [ 2, 3, 1, 5 ], [ 2, 1, 4 ] ]
[ [ 2, 3, 4, 1, 5 ], [ 2, 3, 1, 4 ] ]
[ [ 2, 3, 4, 5 ], [ 2, 3, 4 ] ]
[ [ 2, 3, 5 ], [ 2, 4 ] ]
[ [ 2, 4, 1, 3, 5 ], [ 3, 1, 2, 4 ] ]
[ [ 2, 4, 1, 5 ], [ 3, 1, 4 ] ]
[ [ 2, 4, 3, 1, 5 ], [ 3, 3, 1, 4 ] ]
[ [ 2, 4, 3, 5 ], [ 3, 3, 4 ] ]
[ [ 2, 4, 5 ], [ 3, 4 ] ]
[ [ 2, 5 ], [ 4 ] ]
gap> iter := IteratorOfPaths(gr, 2, 5);;
gap> for a in iter do
>   if not ForAll([1 .. Length(a[1]) - 1], x ->
>       OutNeighboursOfVertex(gr, a[1][x])[a[2][x]] = a[1][x + 1]) then
>     Print("fail\n");
>   fi;
> od;
gap> iter := IteratorOfPaths(gr, 4, 3);
<iterator>
gap> NextIterator(iter);
[ [ 4, 1, 2, 3 ], [ 1, 1, 2 ] ]
gap> NextIterator(iter);
[ [ 4, 1, 2, 5, 3 ], [ 1, 1, 4, 3 ] ]
gap> copy := ShallowCopy(iter);
<iterator>
gap> NextIterator(copy);
[ [ 4, 1, 3 ], [ 1, 2 ] ]
gap> NextIterator(iter);
[ [ 4, 1, 3 ], [ 1, 2 ] ]
gap> gr := [];;
gap> IteratorOfPaths(gr, 1, 1);;
Error, the 2nd and 3rd arguments <u> and <v> must be vertices of the digraph d\
efined by the 1st argument <out>,
gap> gr := [[2]];;
gap> IteratorOfPaths(gr, 1, 1);;
Error, the 1st argument <out> must be a list of out-neighbours of a digraph,
gap> gr := [[0]];;
gap> IteratorOfPaths(gr, 1, 1);;
Error, the 1st argument <out> must be a list of out-neighbours of a digraph,
gap> gr := [[1], [3]];;
gap> IteratorOfPaths(gr, 1, 1);;
Error, the 1st argument <out> must be a list of out-neighbours of a digraph,
gap> gr := [[1], [3], [2, 2]];;
gap> iter := IteratorOfPaths(gr, 1, 1);
<iterator>
gap> for a in iter do
>   Print(a, "\n");
> od;
[ [ 1, 1 ], [ 1 ] ]
gap> gr := DigraphFromDigraph6String("+E?_OHCO");
<immutable digraph with 6 vertices, 6 edges>
gap> iter := IteratorOfPaths(gr, 1, 5);
<iterator>
gap> NextIterator(iter);
[ [ 1, 2, 3, 4, 5 ], [ 1, 1, 1, 1 ] ]
gap> NextIterator(iter);
[ [ 1, 2, 6, 4, 5 ], [ 1, 2, 1, 1 ] ]
gap> IsDoneIterator(iter);
true

#  DigraphLongestDistanceFromVertex
gap> nbs := [[2, 8, 10, 11], [3, 5], [4], [], [6], [7], [], [9], [5], [6],
> [12], [13], [14], [6], [15, 1]];;
gap> gr := Digraph(nbs);
<immutable digraph with 15 vertices, 18 edges>
gap> DigraphHasLoops(gr);
true
gap> a := DigraphLongestDistanceFromVertex(gr, 1);
6
gap> 2 in nbs[1];
true
gap> b := DigraphLongestDistanceFromVertex(gr, 2);
3
gap> a >= b + 1;
true
gap> DigraphLongestDistanceFromVertex(gr, 4);
0
gap> DigraphLongestDistanceFromVertex(gr, 15);
infinity
gap> DigraphLongestDistanceFromVertex(gr, 16);
Error, the 2nd argument <v> must be a vertex of the 1st argument <D>,

#  DigraphLayers
gap> gr := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> DigraphLayers(gr, 1);
[ [ 1 ], [ 2, 3, 4 ] ]
gap> DigraphLayers(gr, 2);
[ [ 2 ], [ 3, 4, 1 ] ]
gap> DigraphLayers(gr, 3);
[ [ 3 ], [ 4, 1, 2 ] ]
gap> DigraphLayers(gr, 4);
[ [ 4 ], [ 1, 2, 3 ] ]
gap> gr := ChainDigraph(5);;
gap> DigraphLayers(gr, 2);
[ [ 2 ], [ 3 ], [ 4 ], [ 5 ] ]
gap> DigraphLayers(gr, 4);
[ [ 4 ], [ 5 ] ]
gap> gr := Digraph([[2, 5], [3], [4], [5], [6], [7], [8], [1]]);;
gap> DigraphLayers(gr, 1);
[ [ 1 ], [ 2, 5 ], [ 3, 6 ], [ 4, 7 ], [ 8 ] ]
gap> DigraphLayers(gr, 3);
[ [ 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 1 ], [ 2 ] ]
gap> DigraphLayers(gr, 6);
[ [ 6 ], [ 7 ], [ 8 ], [ 1 ], [ 2, 5 ], [ 3 ], [ 4 ] ]
gap> DigraphLayers(gr, 7);
[ [ 7 ], [ 8 ], [ 1 ], [ 2, 5 ], [ 3, 6 ], [ 4 ] ]
gap> gr := Digraph([[2, 5], [3], [4], [5], [6], [7], [8], [1], [9, 10, 11],
> [], []]);;
gap> DigraphLayers(gr, 1);
[ [ 1 ], [ 2, 5 ], [ 3, 6 ], [ 4, 7 ], [ 8 ] ]
gap> DigraphLayers(gr, 9);
[ [ 9 ], [ 10, 11 ] ]
gap> DigraphLayers(gr, 10);
[ [ 10 ] ]
gap> gr := DigraphFromDigraph6String("&GYHPQgWTIIPW");;
gap> DigraphGroup(gr);
Group([ (1,2)(3,4)(5,6)(7,8), (1,3,2,4)(5,7,6,8), (1,5)(2,6)(3,8)(4,7) ])
gap> DigraphOrbitReps(gr);
[ 1 ]
gap> DigraphLayers(gr, 1);
[ [ 1 ], [ 2, 3, 5 ], [ 4, 6, 7, 8 ] ]
gap> DigraphLayers(gr, 2);
[ [ 2 ], [ 1, 4, 6 ], [ 3, 5, 8, 7 ] ]
gap> DigraphLayers(gr, 3);
[ [ 3 ], [ 4, 2, 7 ], [ 1, 8, 6, 5 ] ]
gap> DigraphLayers(gr, 4);
[ [ 4 ], [ 3, 1, 8 ], [ 2, 7, 5, 6 ] ]
gap> DigraphLayers(gr, 10);
Error, the 2nd argument <v> must be a vertex of the 1st argument <D>,
gap> DigraphShortestDistance(gr, [2, 5, 6], [3, 7]);
1
gap> DigraphShortestDistance(gr, [2], DigraphLayers(gr, 2)[3]);
2
gap> DigraphShortestDistance(gr, [2, 3], [3, 4]);
0
gap> gr := CompleteDigraph(64);
<immutable complete digraph with 64 vertices>
gap> DigraphShortestDistance(gr, [1 .. 10], [20 .. 23]);
1
gap> DigraphShortestDistance(gr, [1, 13], [20 .. 23]);
1
gap> DigraphShortestDistance(gr, [1, 13], [38, 41]);
1
gap> gr := ChainDigraph(72);
<immutable chain digraph with 72 vertices>
gap> DigraphShortestDistance(gr, [1 .. 10], [20 .. 23]);
10
gap> DigraphShortestDistance(gr, [1, 13], [20 .. 23]);
7
gap> DigraphShortestDistance(gr, [1, 13], [38, 41]);
25
gap> gr := DigraphFromDigraph6String("+H^_HRR\P_FWEsio");
<immutable digraph with 9 vertices, 32 edges>
gap> DigraphShortestDistance(last, [1, 2], [7]);
2
gap> DigraphShortestDistance(gr, [1], DigraphLayers(gr, 1)[3]);
2
gap> DigraphShortestDistance(gr, [1, 2], DigraphLayers(gr, 1)[3]);
0
gap> DigraphShortestDistance(gr, [1, 3], DigraphLayers(gr, 1)[3]);
0
gap> DigraphShortestDistance(gr, [1, 6], DigraphLayers(gr, 1)[3]);
1

#  Issue #12
gap> gr := DigraphFromSparse6String(
> ":]n?AL`CB_EDbFE`IGaGHdJIeKGcLK_@MhDCiFLaBJmHFmKJ");
<immutable digraph with 30 vertices, 90 edges>
gap> G1 := DigraphGroup(gr);;
gap> IsPermGroup(G1) and Length(GeneratorsOfGroup(G1)) = 5;
true
gap> Size(G1);
1440
gap> DigraphShortestDistance(gr, 1, 16);
1

#  DigraphShortestDistance: two inputs
gap> gr := Digraph([[2], [3], [1, 4], [1, 3], [5]]);
<immutable digraph with 5 vertices, 7 edges>
gap> DigraphShortestDistance(gr, 1, 3);
2
gap> DigraphShortestDistance(gr, [3, 3]);
0
gap> DigraphShortestDistance(gr, 5, 2);
fail
gap> DigraphShortestDistances(gr);;
gap> DigraphShortestDistance(gr, [3, 4]);
1

#  DigraphShortestDistance: bad input
gap> DigraphShortestDistance(gr, 1, 74);
Error, the 2nd and 3rd arguments <u> and <v> must be vertices of the 1st argum\
ent <D>,
gap> DigraphShortestDistance(gr, [1, 74]);
Error, the 2nd argument <list> must consist of vertices of the 1st argument <D\
>,
gap> DigraphShortestDistance(gr, [1, 71, 3]);
Error, the 2nd argument <list> must be a list of length 2,

#  DigraphDistancesSet
gap> gr := ChainDigraph(10);
<immutable chain digraph with 10 vertices>
gap> DigraphDistanceSet(gr, 5, 2);
[ 7 ]
gap> gr := DigraphSymmetricClosure(ChainDigraph(10));
<immutable symmetric digraph with 10 vertices, 18 edges>
gap> DigraphDistanceSet(gr, 5, 2);
[ 3, 7 ]
gap> gr := ChainDigraph(10);;
gap> DigraphDistanceSet(gr, 20, 1);
Error, the 2nd argument <vertex> must be a vertex of the digraph,
gap> DigraphDistanceSet(gr, 20, [1]);
Error, the 2nd argument <vertex> must be a vertex of the digraph,
gap> DigraphDistanceSet(gr, 10, ["string", 1]);
Error, the 3rd argument <distances> must be a list of non-negative integers,
gap> gr := DigraphFromDigraph6String("&GYHPQgWTIIPW");;
gap> DigraphDistanceSet(gr, 1, [3, 7]);
[  ]
gap> DigraphDistanceSet(gr, 1, [1]);
[ 2, 3, 5 ]
gap> DigraphDistanceSet(gr, 1, [1, 2]);
[ 2, 3, 5, 4, 6, 7, 8 ]
gap> DigraphDistanceSet(gr, 2, 2);
[ 3, 5, 7, 8 ]
gap> DigraphDistanceSet(gr, 2, -1);
Error, the 3rd argument <distance> must be a non-negative integer,

#  IsSubdigraph: Issue #46
gap> gr1 := Digraph([[2], []]);;
gap> gr2 := Digraph([[2, 2], []]);;
gap> IsSubdigraph(gr1, gr2);
false
gap> IsSubdigraph(gr2, gr1);
true
gap> gr1 = gr2;
false

#  IsSubdigraph: for two digraphs, 1
gap> gr1 := CompleteDigraph(3);;
gap> gr2 := CompleteDigraph(4);;
gap> IsSubdigraph(gr1, gr2) or IsSubdigraph(gr1, gr2);
false
gap> gr3 := CycleDigraph(3);;
gap> IsSubdigraph(gr3, gr1);
false
gap> IsSubdigraph(gr1, gr3);
true
gap> gr4 := Digraph([[1, 1], [2, 2], [3, 3]]);;
gap> IsSubdigraph(gr1, gr4) or IsSubdigraph(gr4, gr1);
false
gap> gr1 := DigraphEdgeUnion(CompleteDigraph(3), CompleteDigraph(3));
<immutable multidigraph with 3 vertices, 12 edges>
gap> gr2 := DigraphEdgeUnion(CycleDigraph(3), CycleDigraph(3));
<immutable multidigraph with 3 vertices, 6 edges>
gap> IsSubdigraph(gr1, gr2);
true
gap> IsSubdigraph(gr2, gr1);
false
gap> gr3 := Digraph([[2, 2, 3], [3], []]);
<immutable multidigraph with 3 vertices, 4 edges>
gap> gr4 := Digraph([[2, 3, 3], [3], []]);
<immutable multidigraph with 3 vertices, 4 edges>
gap> IsSubdigraph(gr3, gr4) or IsSubdigraph(gr4, gr3);
false
gap> gr1 := Digraph([[1, 1], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> gr2 := Digraph([[], [2, 2]]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> IsSubdigraph(gr1, gr2) or IsSubdigraph(gr2, gr1);
false

#  IsUndirectedSpanningForest
gap> gr1 := CompleteDigraph(10);
<immutable complete digraph with 10 vertices>
gap> gr2 := EmptyDigraph(9);
<immutable empty digraph with 9 vertices>
gap> IsUndirectedSpanningForest(gr1, gr2);
false
gap> gr2 := DigraphAddEdge(EmptyDigraph(10), [1, 2]);
<immutable digraph with 10 vertices, 1 edge>
gap> IsUndirectedSpanningForest(gr1, gr2);
false
gap> gr2 := DigraphAddEdge(gr2, [2, 1]);
<immutable digraph with 10 vertices, 2 edges>
gap> IsUndirectedSpanningForest(gr1, gr2);
false
gap> IsUndirectedSpanningForest(gr1, DigraphFromSparse6String(":I`ESyTl^F"));
true
gap> gr := DigraphFromDigraph6String("&I?PIMAQc@A?W?ADPP?");
<immutable digraph with 10 vertices, 23 edges>
gap> IsUndirectedSpanningForest(gr, DigraphByEdges([[2, 7], [7, 2]], 10));
true

#  IsUndirectedSpanningTree
gap> IsUndirectedSpanningTree(EmptyDigraph(1), EmptyDigraph(1));
true
gap> IsUndirectedSpanningTree(EmptyDigraph(2), EmptyDigraph(2));
false
gap> gr := DigraphFromDigraph6String("&I?PIMAQc@A?W?ADPP?");
<immutable digraph with 10 vertices, 23 edges>
gap> IsUndirectedSpanningTree(gr, EmptyDigraph(10));
false
gap> gr := DigraphFromGraph6String("INB`cZoQ_");
<immutable digraph with 10 vertices, 38 edges>
gap> IsUndirectedSpanningTree(gr, gr);
false
gap> gr1 := DigraphEdgeUnion(CycleDigraph(5), DigraphReverse(CycleDigraph(5)));
<immutable digraph with 5 vertices, 10 edges>
gap> gr2 := DigraphEdgeUnion(ChainDigraph(5), DigraphReverse(ChainDigraph(5)));
<immutable digraph with 5 vertices, 8 edges>
gap> IsUndirectedSpanningTree(gr1, gr2);
true
gap> IsUndirectedSpanningTree(gr2, gr2);
true

#  PartialOrderDigraphMeetOfVertices
gap> gr := CycleDigraph(5);
<immutable cycle digraph with 5 vertices>
gap> PartialOrderDigraphJoinOfVertices(gr, 1, 4);
Error, the 1st argument <D> must satisfy IsPartialOrderDigraph,

#Join semilattice on 9 vertices
gap> gr := DigraphFromDiSparse6String(".HiR@AeNcC?oD?G`oAGXIoAGXAe_COqDK^F");
<immutable digraph with 9 vertices, 36 edges>
gap> PartialOrderDigraphMeetOfVertices(gr, 2, 3);
1
gap> PartialOrderDigraphJoinOfVertices(gr, 2, 3);
4
gap> PartialOrderDigraphJoinOfVertices(gr, 3, 9);
5
gap> PartialOrderDigraphMeetOfVertices(gr, 3, 9);
fail
gap> gr := DigraphReverse(gr);
<immutable digraph with 9 vertices, 36 edges>
gap> PartialOrderDigraphMeetOfVertices(gr, 2, 3);
4
gap> PartialOrderDigraphJoinOfVertices(gr, 2, 3);
1
gap> PartialOrderDigraphMeetOfVertices(gr, 3, 9);
5

# Testing invalid input
gap> gr := Digraph([[1, 2, 3], [1, 2, 3], [1, 2, 3]]);
<immutable digraph with 3 vertices, 9 edges>
gap> PartialOrderDigraphMeetOfVertices(gr, 2, 3);
Error, the 1st argument <D> must satisfy IsPartialOrderDigraph,
gap> PartialOrderDigraphJoinOfVertices(gr, 2, 3);
Error, the 1st argument <D> must satisfy IsPartialOrderDigraph,
gap> gr1 := Digraph([[1], [2], [1, 2, 3], [1, 2, 4]]);
<immutable digraph with 4 vertices, 8 edges>
gap> gr2 := DigraphReverse(gr1);
<immutable digraph with 4 vertices, 8 edges>

# Meet does not exist
gap> PartialOrderDigraphMeetOfVertices(gr1, 3, 4);
fail
gap> PartialOrderDigraphMeetOfVertices(gr2, 3, 4);
fail

# Join does not exist
gap> PartialOrderDigraphJoinOfVertices(gr2, 3, 4);
fail
gap> PartialOrderDigraphJoinOfVertices(gr1, 3, 4);
fail

#  DigraphClosure
gap> gr := Digraph([[4, 5, 6, 7, 9], [7, 3], [2, 6, 7, 9, 10],
> [5, 6, 7, 1, 9], [1, 4, 6, 7], [7, 1, 3, 4, 5],
> [1, 4, 9, 2, 3, 5, 6, 8], [7], [1, 4, 7, 3, 10], [9, 3]]);;
gap> DigraphNrEdges(gr);
42
gap> DigraphNrEdges(DigraphClosure(gr, 10));
54
gap> DigraphNrEdges(DigraphClosure(gr, 9));
90
gap> DigraphNrEdges(DigraphClosure(gr, 11));
42
gap> gr := Digraph([[1], [2], [3]]);;
gap> DigraphClosure(gr, 2);
Error, the 1st argument <D> must be a symmetric digraph with no loops, and no \
multiple edges,
gap> gr := Digraph([[2], [3], [1]]);;
gap> DigraphClosure(gr, 2);
Error, the 1st argument <D> must be a symmetric digraph with no loops, and no \
multiple edges,

#  IsMatching
gap>  gr := Digraph([[2], [3], [4], []]);;
gap>  edges := [[1, 4], [2, 3]];;
gap>  IsMatching(gr, edges);
false
gap>  gr := Digraph([[2], [3], [4], []]);;
gap>  edges := [[1, 2], [4, 3]];;
gap>  IsMatching(gr, edges);
false
gap>  edges := [[1, 2], [3, 4]];;
gap>  IsMatching(gr, edges);
true
gap>  gr := Digraph([[2], [3], [4], []]);;
gap>  edges := [[1, 4], [4, 1], [2, 3]];;
gap>  IsMatching(gr, edges);
false
gap>  gr := Digraph([[2], [3], [4], []]);;
gap>  edges := [[1, 1], [2, 3]];;
gap>  IsMatching(gr, edges);
false
gap>  gr := Digraph([[1, 2], [3], [4], []]);;
gap>  edges := [[1, 1], [2, 3]];;
gap>  IsMatching(gr, edges);
true
gap>  gr := Digraph([[2], [3], [4], []]);;
gap>  edges := [[1, 2], [3, 4]];;
gap>  IsMatching(gr, edges);
true
gap>  gr := Digraph([[2], [3], [4], []]);;
gap>  edges := [[1, 2], [2, 3]];;
gap>  IsMatching(gr, edges);
false
gap>  gr := CompleteDigraph(999);;
gap>  edges := [[1, 2], [4, 5], [6, 7]];;
gap>  IsMatching(gr, edges);
true
gap> gr := CompleteDigraph(999);;
gap>  edges := [];;
gap>  for i in [1 .. 499] do Append(edges, [[2 * i, 2 * i + 1]]); od;;
gap>  IsMatching(gr, edges);
true
gap> gr := CompleteDigraph(999);;
gap> edges := [[1, 2], [3, 4], [4, 5], [6, 7]];;
gap>  IsMatching(gr, edges);
false

#  IsPerfectMatching
gap> gr := Digraph([[2], [3], [4], [5], [1]]);
<immutable digraph with 5 vertices, 5 edges>
gap> IsPerfectMatching(gr, [[1, 3]]);
false
gap> edges := [[1, 2], [4, 5]];;
gap> IsMatching(gr, edges);
true
gap> IsPerfectMatching(gr, edges);
false
gap> gr := CompleteDigraph(500);
<immutable complete digraph with 500 vertices>
gap> edges := [];;
gap> for i in [0 .. 249] do
>   Append(edges, [[2 * i + 1, 2 * i + 2]]);
> od;;
gap> IsPerfectMatching(gr, edges);
true
gap> gr := Digraph([[2], [3, 4], [], [5], [1, 6], [1]]);
<immutable digraph with 6 vertices, 7 edges>
gap> edges := [[1, 6], [2, 3], [5, 4]];;
gap> IsMatching(gr, edges);
false
gap> edges := [[6, 1], [2, 3], [4, 5]];;
gap> IsPerfectMatching(gr, edges);
true
gap> gr := Digraph([[2], [3], [4, 3], [5], [1]]);
<immutable digraph with 5 vertices, 6 edges>
gap> edges := [[1, 2], [4, 5], [3, 3]];;
gap> IsPerfectMatching(gr, edges);
true

#  IsMaximalMatching
gap> gr := Digraph([[2], [3], [4], [5], [1]]);
<immutable digraph with 5 vertices, 5 edges>
gap> edges := [[1, 2], [4, 3]];;
gap> IsMatching(gr, edges);
false
gap> edges := [[1, 2], [3, 4]];;
gap> IsMaximalMatching(gr, edges);
true
gap> gr := Digraph([[2], [3], [4], [5], [1, 5]]);
<immutable digraph with 5 vertices, 6 edges>
gap> edges := [[1, 2], [3, 4]];;
gap> IsMaximalMatching(gr, edges);
false
gap> gr := CompleteDigraph(5);;
gap> edges := [[1, 2], [1, 3]];;
gap> IsMaximalMatching(gr, edges);
false
gap> gr := Digraph([[2], [3], [4], [1]]);;
gap> edges := [[2, 1], [4, 3]];;
gap> IsMatching(gr, edges);
false
gap> edges := [[1, 2], [3, 4]];;
gap> IsMaximalMatching(gr, edges);
true
gap> gr := Digraph([[2], [3], [1], [5], [6], [4]]);;
gap> edges := [[1, 2], [4, 5]];;
gap> IsMaximalMatching(gr, edges);
true
gap> gr := Digraph([[1, 2], [3], [4], [1]]);;
gap> edges := [[1, 1], [2, 3]];
[ [ 1, 1 ], [ 2, 3 ] ]
gap> IsMaximalMatching(gr, edges);
true

# IsMaximumMatching
gap> D := Digraph([[1, 2], [1, 2], [2, 3, 4], [3, 5], [1]]);
<immutable digraph with 5 vertices, 10 edges>
gap> IsMaximumMatching(D, [[1, 2], [3, 3], [4, 5]]);
false
gap> IsMaximumMatching(D, [[1, 1], [2, 2], [3, 3], [4, 5]]);
true
gap> IsMaximumMatching(D, [[1, 1], [1, 2], [2, 2], [3, 3], [4, 5]]);
false

# DigraphShortestPath
gap> gr := Digraph([[1], [3, 4], [5, 6], [4, 2, 3], [4, 5], [1]]);;
gap> DigraphShortestPath(gr, 1, 6);
fail
gap> DigraphShortestPath(gr, 2, 5);
[ [ 2, 3, 5 ], [ 1, 1 ] ]
gap> DigraphShortestPath(gr, 3, 3);
[ [ 3, 5, 4, 3 ], [ 1, 1, 3 ] ]
gap> DigraphShortestPath(gr, 6, 6);
fail
gap> DigraphShortestPath(gr, 5, 5);
[ [ 5, 5 ], [ 2 ] ]
gap> gr := Digraph([[]]);;
gap> DigraphShortestPath(gr, 1, 1);
fail
gap> gr := Digraph([[], []]);;
gap> DigraphShortestPath(gr, 2, 1);
fail
gap> gr := Digraph([[2], [1], [3]]);;
gap> DigraphShortestPath(gr, 1, 2);
[ [ 1, 2 ], [ 1 ] ]
gap> gr := CayleyDigraph(SymmetricGroup(7));;
gap> DigraphShortestPath(gr, 12, 5014);
[ [ 12, 912, 1919, 3595, 4915, 3433, 4153, 3242, 2522, 2886, 23, 743, 238, 
      1558, 713, 5014 ], [ 2, 2, 2, 1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 2 ] ]

# DigraphAddAllLoops - mutable
gap> D := Digraph(IsMutableDigraph, [[1], [3, 4], [5, 6], [4, 2, 3], [4, 5], [1]]);
<mutable digraph with 6 vertices, 11 edges>
gap> DigraphAddAllLoops(D);
<mutable digraph with 6 vertices, 14 edges>
gap> IsIdenticalObj(last, D);
true
gap> D := Digraph([[1], [3, 4], [5, 6], [4, 2, 3], [4, 5], [1]]);
<immutable digraph with 6 vertices, 11 edges>
gap> DigraphAddAllLoops(D);
<immutable reflexive digraph with 6 vertices, 14 edges>
gap> IsIdenticalObj(last, D);
false
gap> D := Digraph([[1], [3, 4], [5, 6], [4, 2, 3], [4, 5], [1]]);
<immutable digraph with 6 vertices, 11 edges>
gap> D := DigraphAddEdge(D, 1, 3);
<immutable digraph with 6 vertices, 12 edges>
gap> D := DigraphAddEdge(D, 1, 3);
<immutable multidigraph with 6 vertices, 13 edges>
gap> D := DigraphRemoveEdge(D, 1, 3);
Error, the 1st argument <D> must be a digraph with no multiple edges,
gap> D := Digraph([[1], [3, 4], [5, 6], [4, 2, 3], [4, 5], [1]]);
<immutable digraph with 6 vertices, 11 edges>
gap> D := DigraphAddEdge(D, 1, 3);
<immutable digraph with 6 vertices, 12 edges>
gap> D := DigraphRemoveEdge(D, 1, 3);
<immutable digraph with 6 vertices, 11 edges>
gap> D := DigraphRemoveEdge(D, 1, 3);
<immutable digraph with 6 vertices, 11 edges>

# DisjointUnion etc
gap> D := DigraphMutableCopy(CycleDigraph(3));
<mutable digraph with 3 vertices, 3 edges>
gap> DigraphDisjointUnion(D, D, D, D, D, D, D, D, D, D);
<mutable digraph with 30 vertices, 30 edges>
gap> D := DigraphMutableCopy(CycleDigraph(3));
<mutable digraph with 3 vertices, 3 edges>
gap> DigraphDisjointUnion(D, CycleDigraph(3), CycleDigraph(3),
> CycleDigraph(3));
<mutable digraph with 12 vertices, 12 edges>
gap> D := DigraphMutableCopy(CycleDigraph(3));
<mutable digraph with 3 vertices, 3 edges>
gap> DigraphJoin(D, D, D);
<mutable digraph with 9 vertices, 63 edges>
gap> D := CycleDigraph(IsMutableDigraph, 3);
<mutable digraph with 3 vertices, 3 edges>
gap> DigraphEdgeUnion(D, D, D);
<mutable multidigraph with 3 vertices, 9 edges>
gap> D := DigraphMutableCopy(CycleDigraph(3));
<mutable digraph with 3 vertices, 3 edges>
gap> DigraphJoin(D, CycleDigraph(3), CycleDigraph(3),
> CycleDigraph(3));
<mutable digraph with 12 vertices, 120 edges>
gap> D := CycleDigraph(3);
<immutable cycle digraph with 3 vertices>
gap> DigraphJoin(D, D, D);
<immutable digraph with 9 vertices, 63 edges>
gap> DigraphJoin(D, CycleDigraph(3), CycleDigraph(3),
> CycleDigraph(3));
<immutable digraph with 12 vertices, 120 edges>
gap> D := DigraphMutableCopy(CycleDigraph(3));
<mutable digraph with 3 vertices, 3 edges>
gap> DigraphEdgeUnion(D, CycleDigraph(3), CycleDigraph(3),
> CycleDigraph(3));
<mutable multidigraph with 3 vertices, 12 edges>
gap> DD := CycleDigraph(3);
<immutable cycle digraph with 3 vertices>
gap> DD := DigraphEdgeUnion(D, CycleDigraph(3), CycleDigraph(3),
> CycleDigraph(3));
<mutable multidigraph with 3 vertices, 21 edges>
gap> D = DD;
true
gap> D := Digraph(IsMutableDigraph, [[2, 3], [1, 3], [1, 2]]);
<mutable digraph with 3 vertices, 6 edges>
gap> DigraphReverse(D) = Digraph(IsMutableDigraph, [[2, 3], [1, 3], [1, 2]]);
true
gap> DigraphReverseEdge(D, 1, 2);
<mutable multidigraph with 3 vertices, 6 edges>
gap> DigraphReverseEdge(D, 1, 1);
Error, the 1st argument <D> must be a digraph with no multiple edges,
gap> DigraphAddEdge(D, 1, 1);
<mutable multidigraph with 3 vertices, 7 edges>
gap> DigraphReverseEdge(D, 1, 1);
Error, the 1st argument <D> must be a digraph with no multiple edges,
gap> D := Digraph(IsMutableDigraph, [[2, 3], [1, 3], [1, 2]]);
<mutable digraph with 3 vertices, 6 edges>
gap> DigraphAddEdge(D, 1, 1);
<mutable digraph with 3 vertices, 7 edges>
gap> DigraphReverseEdge(D, 1, 1);
<mutable digraph with 3 vertices, 7 edges>
gap> DigraphReverseEdge(D, 1, 4);
Error, there is no edge from 1 to 
4 in the digraph <D> that is the 1st argument,
gap> D := MakeImmutable(D);
<immutable digraph with 3 vertices, 7 edges>
gap> D := DigraphReverseEdge(D, 1, 2);
<immutable multidigraph with 3 vertices, 7 edges>
gap> D := CycleDigraph(3);
<immutable cycle digraph with 3 vertices>
gap> DigraphReverseEdge(D, [1, 2]);
<immutable digraph with 3 vertices, 3 edges>
gap> D := DigraphMutableCopy(CompleteDigraph(10));
<mutable digraph with 10 vertices, 90 edges>
gap> DD := InducedSubdigraph(D, [1, 2, 4, 6]);
<mutable digraph with 4 vertices, 12 edges>
gap> D;
<mutable digraph with 4 vertices, 12 edges>
gap> D := DigraphMutableCopy(CompleteDigraph(10));
<mutable digraph with 10 vertices, 90 edges>
gap> DD := QuotientDigraph(D, [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10]]);
<mutable digraph with 4 vertices, 15 edges>
gap> InNeighboursOfVertexNC(DD, 1);
[ 1, 2, 3, 4 ]
gap> MakeImmutable(DD);
<immutable digraph with 4 vertices, 15 edges>
gap> InNeighbours(DD);;
gap> InNeighboursOfVertexNC(DD, 1);
[ 1, 2, 3, 4 ]
gap> InDegreeOfVertexNC(DD, 1);
4
gap> DigraphShortestPath(DD, 1, 5);
Error, the 2nd and 3rd arguments <u> and <v> must be vertices of the 1st argum\
ent <D>,
gap> IsTransitiveDigraph(DD);
false
gap> DD := DigraphTransitiveClosure(DigraphRemoveAllMultipleEdges(DD));
<immutable transitive digraph with 4 vertices, 16 edges>
gap> IsTransitiveDigraph(DD);
true
gap> DigraphShortestPath(DD, 1, 2);
[ [ 1, 2 ], [ 2 ] ]
gap> D := ChainDigraph(4);
<immutable chain digraph with 4 vertices>
gap> D := DigraphTransitiveClosure(D);
<immutable transitive digraph with 4 vertices, 6 edges>
gap> DigraphShortestPath(D, 2, 1);
fail
gap> D := DigraphDisjointUnion(CycleDigraph(3), CycleDigraph(3));
<immutable digraph with 6 vertices, 6 edges>
gap> DigraphConnectedComponents(D);
rec( comps := [ [ 1, 2, 3 ], [ 4, 5, 6 ] ], id := [ 1, 1, 1, 2, 2, 2 ] )
gap> DigraphShortestPath(D, 1, 4);
fail
gap> D := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> PartialOrderDigraphMeetOfVertices(D, 1, 2);
Error, the 3rd argument <j> must be a vertex of the 1st argument <D>,
gap> PartialOrderDigraphMeetOfVertices(D, 2, 1);
Error, the 2nd argument <i> must be a vertex of the 1st argument <D>,
gap> PartialOrderDigraphJoinOfVertices(D, 1, 2);
Error, the 3rd argument <j> must be a vertex of the 1st argument <D>,
gap> PartialOrderDigraphJoinOfVertices(D, 2, 1);
Error, the 2nd argument <i> must be a vertex of the 1st argument <D>,

# DigraphCartesianProduct
gap> D := DigraphMutableCopy(CycleDigraph(3));
<mutable digraph with 3 vertices, 3 edges>
gap> DigraphCartesianProduct(D, D, D);
<mutable digraph with 27 vertices, 81 edges>
gap> D := DigraphMutableCopy(CycleDigraph(3));
<mutable digraph with 3 vertices, 3 edges>
gap> DigraphCartesianProduct(D, CycleDigraph(3), CycleDigraph(3), CycleDigraph(3));
<mutable digraph with 81 vertices, 324 edges>
gap> D := DigraphCartesianProduct(ChainDigraph(3), CycleDigraph(3));
<immutable digraph with 9 vertices, 15 edges>
gap> IsIsomorphicDigraph(D,
> Digraph([[2, 4], [3, 5], [6], [5, 7], [6, 8], [9], [8, 1], [9, 2], [3]]));
true
gap> D := DigraphCartesianProduct(ChainDigraph(3), CycleDigraph(3),
> Digraph([[2], [2]]));
<immutable digraph with 18 vertices, 48 edges>
gap> HasDigraphCartesianProductProjections(D);
true
gap> Length(DigraphCartesianProductProjections(D));
3
gap> G := DigraphFromDigraph6String(
> "&QSC?IA?@@?A__@OO?GG_OCOGAG?@?E_?BO?@G??s??Y??H?CE?AB?@@");;
gap> IsIsomorphicDigraph(D, G);
true
gap> D := RandomDigraph(100);; IsIsomorphicDigraph(D, 
> DigraphCartesianProduct(D, Digraph([[]])));
true
gap> DigraphCartesianProduct(Digraph([[1]]), Digraph([[1]]));
<immutable multidigraph with 1 vertex, 2 edges>

# DigraphDirectProduct
gap> D := DigraphMutableCopy(CycleDigraph(3));
<mutable digraph with 3 vertices, 3 edges>
gap> DigraphDirectProduct(D, D, D);
<mutable digraph with 27 vertices, 27 edges>
gap> D := DigraphMutableCopy(CycleDigraph(3));
<mutable digraph with 3 vertices, 3 edges>
gap> DigraphDirectProduct(D, CycleDigraph(3), CycleDigraph(3), CycleDigraph(3));
<mutable digraph with 81 vertices, 81 edges>
gap> D := DigraphDirectProduct(ChainDigraph(3), CycleDigraph(3));
<immutable digraph with 9 vertices, 6 edges>
gap> IsIsomorphicDigraph(D,
> Digraph([[5], [6], [], [8], [9], [], [2], [3], []]));
true
gap> D := DigraphDirectProduct(ChainDigraph(3), CycleDigraph(3),
> Digraph([[2], [2]]));
<immutable digraph with 18 vertices, 12 edges>
gap> HasDigraphDirectProductProjections(D);
true
gap> Length(DigraphDirectProductProjections(D));
3
gap> G := DigraphFromDigraph6String(
> "&Q??O??G?????A??@????A??@??????O??G?????A??@????A??@????");;
gap> IsIsomorphicDigraph(D, G);
true
gap> D := RandomDigraph(100);; IsIsomorphicDigraph(D,
> DigraphDirectProduct(D, Digraph([[1]])));
true

# Issue 213
gap> D := Digraph(IsMutableDigraph, [[3, 4, 6, 8], [1, 3, 4, 6, 7, 8, 10], 
> [1, 2, 6, 7, 8, 9], [3, 5, 7], [1, 2, 3, 6, 8, 9], [2, 6, 8, 10], 
> [2, 7, 10], [1, 5, 8, 10], [1, 2, 6, 7, 8, 10], [1, 2, 6, 8, 9, 10]]);
<mutable digraph with 10 vertices, 49 edges>
gap> InducedSubdigraph(D, [4, 5]);
<mutable digraph with 2 vertices, 1 edge>
gap> DigraphVertexLabels(D);
[ 4, 5 ]

# Issue 215
gap> D := Digraph([[6, 7, 8], [8], [8], [8], [8], [1, 7, 8], [1, 6, 8],
>                  [3, 2, 1, 7, 6, 5, 4]]);;
gap> C := DigraphRemoveVertex(DigraphMutableCopy(D), 5);;
gap> DigraphEdgeLabels(C);
[ [ 1, 1, 1 ], [ 1 ], [ 1 ], [ 1 ], [ 1, 1, 1 ], [ 1, 1, 1 ], 
  [ 1, 1, 1, 1, 1, 1 ] ]
gap> OutNeighbours(C);
[ [ 5, 6, 7 ], [ 7 ], [ 7 ], [ 7 ], [ 1, 6, 7 ], [ 1, 5, 7 ], 
  [ 3, 2, 1, 6, 5, 4 ] ]

#DigraphDijkstra
# When there is one path to target
gap> mat := [[0, 1, 1], [0, 0, 1], [0, 0, 0]];
[ [ 0, 1, 1 ], [ 0, 0, 1 ], [ 0, 0, 0 ] ]
gap> gr := DigraphByAdjacencyMatrix(mat);
<immutable digraph with 3 vertices, 3 edges>
gap> DigraphShortestDistance(gr, 2, 3);
1
gap> DigraphDijkstra(gr, 2, 3);
[ [ infinity, 0, 1 ], [ -1, -1, 2 ] ]
gap> DigraphDijkstra(gr, 1, 3);
[ [ 0, 1, 1 ], [ -1, 1, 1 ] ]
gap> DigraphDijkstra(gr, 1, 2);
[ [ 0, 1, 1 ], [ -1, 1, 1 ] ]
gap> DigraphShortestDistance(gr, 1, 3);
1
gap> DigraphShortestDistance(gr, 1, 2);
1
gap> mat := [[0, 1, 1], [0, 0, 0], [0, 0, 0]];
[ [ 0, 1, 1 ], [ 0, 0, 0 ], [ 0, 0, 0 ] ]
gap> gr := DigraphByAdjacencyMatrix(mat);
<immutable digraph with 3 vertices, 2 edges>
gap> DigraphShortestDistance(gr, 2, 3);
fail
gap> DigraphDijkstra(gr, 2, 3);
[ [ infinity, 0, infinity ], [ -1, -1, -1 ] ]
gap> mat := [[0, 1, 1, 1], [0, 0, 1, 1], [0, 1, 0, 0], [1, 0, 0, 0]];
[ [ 0, 1, 1, 1 ], [ 0, 0, 1, 1 ], [ 0, 1, 0, 0 ], [ 1, 0, 0, 0 ] ]
gap> gr := DigraphByAdjacencyMatrix(mat);
<immutable digraph with 4 vertices, 7 edges>
gap> DigraphDijkstra(gr, 1, 4);
[ [ 0, 1, 1, 1 ], [ -1, 1, 1, 1 ] ]
gap> mat := [[0, 1, 1, 1], [0, 0, 1, 1], [0, 1, 0, 0], [1, 0, 0, 0]];
[ [ 0, 1, 1, 1 ], [ 0, 0, 1, 1 ], [ 0, 1, 0, 0 ], [ 1, 0, 0, 0 ] ]
gap> gr := DigraphByAdjacencyMatrix(mat);
<immutable digraph with 4 vertices, 7 edges>
gap> DigraphDijkstra(gr, 1, 2);
[ [ 0, 1, 1, 1 ], [ -1, 1, 1, 1 ] ]
gap> DigraphDijkstra(gr, 1, 3);
[ [ 0, 1, 1, 1 ], [ -1, 1, 1, 1 ] ]

#DIGRAPHS_UnbindVariables
gap> Unbind(a);
gap> Unbind(adj);
gap> Unbind(b);
gap> Unbind(e);
gap> Unbind(edges);
gap> Unbind(edges2);
gap> Unbind(erev);
gap> Unbind(func);
gap> Unbind(G1);
gap> Unbind(G2);
gap> Unbind(G3);
gap> Unbind(G4);
gap> Unbind(G5);
gap> Unbind(g);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(gr3);
gap> Unbind(gr4);
gap> Unbind(gr5);
gap> Unbind(gri);
gap> Unbind(grrt);
gap> Unbind(grt);
gap> Unbind(h);
gap> Unbind(i1);
gap> Unbind(i2);
gap> Unbind(iter);
gap> Unbind(j1);
gap> Unbind(j2);
gap> Unbind(m);
gap> Unbind(m1);
gap> Unbind(m2);
gap> Unbind(mat);
gap> Unbind(n);
gap> Unbind(nat);
gap> Unbind(nbs);
gap> Unbind(out);
gap> Unbind(out1);
gap> Unbind(out2);
gap> Unbind(out3);
gap> Unbind(p1);
gap> Unbind(p2);
gap> Unbind(qr);
gap> Unbind(r);
gap> Unbind(range);
gap> Unbind(rel1);
gap> Unbind(rel2);
gap> Unbind(rel3);
gap> Unbind(rev);
gap> Unbind(rgr);
gap> Unbind(rtclosure);
gap> Unbind(source);
gap> Unbind(T);
gap> Unbind(t);
gap> Unbind(tclosure);
gap> Unbind(temp);
gap> Unbind(U);
gap> Unbind(u1);
gap> Unbind(u2);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/oper.tst", 0);
