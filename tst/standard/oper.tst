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

#  DigraphReverse
gap> gr := DigraphFromDigraph6String("&DHUEe_");
<digraph with 5 vertices, 11 edges>
gap> rgr := DigraphReverse(gr);
<digraph with 5 vertices, 11 edges>
gap> OutNeighbours(rgr);
[ [ 2, 3, 4 ], [ 4, 5 ], [ 1, 2, 5 ], [ 4 ], [ 2, 5 ] ]
gap> gr = DigraphReverse(rgr);
true
gap> gr := Digraph(rec(nrvertices := 5,
> source := [1, 1, 2, 2, 2, 2, 2, 3, 4, 4, 4, 5, 5, 5],
> range  := [1, 3, 1, 2, 2, 4, 5, 4, 1, 3, 5, 1, 1, 3]));
<multidigraph with 5 vertices, 14 edges>
gap> e := DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 3 ], [ 2, 1 ], [ 2, 2 ], [ 2, 2 ], [ 2, 4 ], [ 2, 5 ], 
  [ 3, 4 ], [ 4, 1 ], [ 4, 3 ], [ 4, 5 ], [ 5, 1 ], [ 5, 1 ], [ 5, 3 ] ]
gap> rev := DigraphReverse(gr);
<multidigraph with 5 vertices, 14 edges>
gap> erev := DigraphEdges(rev);;
gap> temp := List(erev, x -> [x[2], x[1]]);;
gap> Sort(temp);
gap> e = temp;
true
gap> gr := Digraph([[2], [1]]);
<digraph with 2 vertices, 2 edges>
gap> IsSymmetricDigraph(gr);
true
gap> DigraphReverse(gr) = gr;
true
gap> gr := Digraph([[2], [1]]);
<digraph with 2 vertices, 2 edges>
gap> SetIsSymmetricDigraph(gr, true);
gap> gr = DigraphReverse(gr);
true

#  DigraphRemoveLoops
gap> gr := DigraphFromDigraph6String("&EhxPC?@");
<digraph with 6 vertices, 11 edges>
gap> DigraphRemoveLoops(gr);
<digraph with 6 vertices, 7 edges>
gap> gr := DigraphFromDigraph6String("&EhxPC?@");
<digraph with 6 vertices, 11 edges>
gap> HasDigraphHasLoops(gr);
false
gap> DigraphHasLoops(gr);
true
gap> gr1 := DigraphRemoveLoops(gr);
<digraph with 6 vertices, 7 edges>
gap> HasDigraphHasLoops(gr1);
true
gap> DigraphHasLoops(gr1);
false

#  DigraphRemoveEdges: for an index
gap> gr := RandomDigraph(10);;
gap> DigraphRemoveEdges(gr, [Group(())]);
Error, Digraphs: DigraphRemoveEdges: usage,
the second argument <edges> must be a list of indices of
edges or a list of edges of the first argument <digraph>,
gap> gr := Digraph([[2], []]);
<digraph with 2 vertices, 1 edge>
gap> DigraphRemoveEdges(gr, [1]);
<digraph with 2 vertices, 0 edges>
gap> gr := DigraphFromDiSparse6String(".DaqjO_HocR");
<multidigraph with 5 vertices, 10 edges>
gap> gr1 := DigraphRemoveEdges(gr, [2, 4, 5, 6]);
<multidigraph with 5 vertices, 6 edges>
gap> DigraphSource(gr1);
[ 1, 1, 4, 5, 5, 5 ]
gap> DigraphRange(gr1);
[ 1, 2, 3, 3, 5, 5 ]
gap> DigraphRemoveEdges(gr1, []);
<multidigraph with 5 vertices, 6 edges>
gap> last = gr1;
true

#  DigraphRemoveEdges: for a list of edges
gap> gr := Digraph([[2], []]);
<digraph with 2 vertices, 1 edge>
gap> DigraphRemoveEdges(gr, [[2, 1]]);
<digraph with 2 vertices, 1 edge>
gap> last = gr;
true
gap> DigraphRemoveEdges(gr, [[1, 2]]);
<digraph with 2 vertices, 0 edges>
gap> gr := DigraphFromDigraph6String("&DtGsw_");
<digraph with 5 vertices, 12 edges>
gap> Set(DigraphEdges(gr)) = Set(
> [[1, 2], [1, 1], [1, 4], [2, 1], [2, 4], [3, 4],
>  [3, 3], [4, 1], [4, 5], [4, 4], [5, 1], [5, 5]]);
true
gap> gr1 := DigraphRemoveEdges(gr, [[1, 4], [4, 5], [5, 5]]);
<digraph with 5 vertices, 9 edges>
gap> DigraphEdges(gr1);
[ [ 1, 2 ], [ 1, 1 ], [ 2, 1 ], [ 2, 4 ], [ 3, 4 ], [ 3, 3 ], [ 4, 1 ], 
  [ 4, 4 ], [ 5, 1 ] ]
gap> gr := Digraph([[2, 2], []]);
<multidigraph with 2 vertices, 2 edges>
gap> DigraphRemoveEdges(gr, [[1, 2]]);
Error, Digraphs: DigraphRemoveEdges: usage,
the first argument <digraph> must not have multiple edges
when the second argument <edges> is a list of edges,

#  DigraphRemoveEdge: for an index
gap> gr := Digraph([[2, 3], [1], [3]]);
<digraph with 3 vertices, 4 edges>
gap> DigraphRemoveEdge(gr, 0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphRemoveEdge' on 2 arguments
gap> DigraphRemoveEdge(gr, 5);
Error, Digraphs: DigraphRemoveEdge: usage,
the second argument <edge> must be the index of an edge in <digraph>,
gap> gr := DigraphRemoveEdge(gr, 3);
<digraph with 3 vertices, 3 edges>
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 1, 3 ], [ 3, 3 ] ]

#  DigraphRemoveEdge: for an edge
gap> gr := Digraph([[1, 1]]);
<multidigraph with 1 vertex, 2 edges>
gap> DigraphRemoveEdge(gr, [1, 1]);
Error, Digraphs: DigraphRemoveEdge: usage,
the first argument <digraph> must not have multiple edges
when the second argument <edges> is a pair of vertices,
gap> gr := Digraph([[2], [1]]);
<digraph with 2 vertices, 2 edges>
gap> DigraphRemoveEdge(gr, [1, 1, 1]);
Error, Digraphs: DigraphRemoveEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> DigraphRemoveEdge(gr, [Group(()), Group(())]);
Error, Digraphs: DigraphRemoveEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> DigraphRemoveEdge(gr, [1, Group(())]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphRemoveEdge' on 2 arguments
gap> DigraphRemoveEdge(gr, [3, 1]);
Error, Digraphs: DigraphRemoveEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> DigraphRemoveEdge(gr, [1, 3]);
Error, Digraphs: DigraphRemoveEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> gr := DigraphRemoveEdge(gr, [2, 1]);
<digraph with 2 vertices, 1 edge>
gap> DigraphEdges(gr);
[ [ 1, 2 ] ]

#  OnDigraphs: for a digraph and a perm
gap> gr := Digraph([[2], [1], [3]]);
<digraph with 3 vertices, 3 edges>
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 2, 1 ], [ 3, 3 ] ]
gap> g := (1, 2, 3);
(1,2,3)
gap> OnDigraphs(gr, g);
<digraph with 3 vertices, 3 edges>
gap> DigraphEdges(last);
[ [ 1, 1 ], [ 2, 3 ], [ 3, 2 ] ]
gap> h := (1, 2, 3, 4);
(1,2,3,4)
gap> OnDigraphs(gr, h);
Error, Digraphs: OnDigraphs: usage,
the 2nd argument <perm> must permute the vertices of the 1st argument <graph>,
gap> gr := Digraph([[1, 1, 1, 3, 5], [], [3, 2, 4, 5], [2, 5], [1, 2, 1]]);
<multidigraph with 5 vertices, 14 edges>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 1 ], [ 1, 1 ], [ 1, 3 ], [ 1, 5 ], [ 3, 3 ], [ 3, 2 ], 
  [ 3, 4 ], [ 3, 5 ], [ 4, 2 ], [ 4, 5 ], [ 5, 1 ], [ 5, 2 ], [ 5, 1 ] ]
gap> p1 := (2, 4)(3, 6, 5);
(2,4)(3,6,5)
gap> OnDigraphs(gr, p1);
Error, Digraphs: OnDigraphs: usage,
the 2nd argument <perm> must permute the vertices of the 1st argument <graph>,
gap> p2 := (1, 3, 4, 2);
(1,3,4,2)
gap> OnDigraphs(gr, p2);
<multidigraph with 5 vertices, 14 edges>
gap> DigraphEdges(last);
[ [ 2, 1 ], [ 2, 5 ], [ 3, 3 ], [ 3, 3 ], [ 3, 3 ], [ 3, 4 ], [ 3, 5 ], 
  [ 4, 4 ], [ 4, 1 ], [ 4, 2 ], [ 4, 5 ], [ 5, 3 ], [ 5, 1 ], [ 5, 3 ] ]
gap> gr := DigraphFromDiSparse6String(".CaoJG_hF");
<multidigraph with 4 vertices, 8 edges>
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 1, 3 ], [ 2, 1 ], [ 2, 4 ], [ 2, 4 ], [ 3, 3 ], [ 4, 1 ], 
  [ 4, 3 ] ]
gap> p1 := (1, 5, 4, 2, 3);
(1,5,4,2,3)
gap> OnDigraphs(gr, p1);
Error, Digraphs: OnDigraphs: usage,
the 2nd argument <perm> must permute the vertices of the 1st argument <graph>,
gap> p2 := (1, 4)(2, 3);
(1,4)(2,3)
gap> OnDigraphs(gr, p2);
<multidigraph with 4 vertices, 8 edges>
gap> DigraphEdges(last);
[ [ 1, 4 ], [ 1, 2 ], [ 2, 2 ], [ 3, 4 ], [ 3, 1 ], [ 3, 1 ], [ 4, 3 ], 
  [ 4, 2 ] ]

#  OnDigraphs: for a digraph and a transformation
gap> gr := Digraph([[2], [1, 3], []]);
<digraph with 3 vertices, 3 edges>
gap> OutNeighbours(gr);
[ [ 2 ], [ 1, 3 ], [  ] ]
gap> t := Transformation([4, 2, 3, 4]);;
gap> OnDigraphs(gr, t);
Error, Digraphs: OnDigraphs: usage,
the 2nd argument <trans> must transform the vertices of the 1st argument
<digraph>,
gap> t := Transformation([1, 2, 1]);;
gap> gr := OnDigraphs(gr, t);
<multidigraph with 3 vertices, 3 edges>
gap> OutNeighbours(gr);
[ [ 2 ], [ 1, 1 ], [  ] ]

#  OnMultiDigraphs: for a pair of permutations
gap> gr1 := CompleteDigraph(3);
<digraph with 3 vertices, 6 edges>
gap> DigraphEdges(gr1);
[ [ 1, 2 ], [ 1, 3 ], [ 2, 1 ], [ 2, 3 ], [ 3, 1 ], [ 3, 2 ] ]
gap> gr2 := OnMultiDigraphs(gr1, (1, 3), (3, 6));;
gap> DigraphEdges(gr1);;
gap> OnMultiDigraphs(gr1, [(1, 3)]);
Error, Digraphs: OnMultiDigraphs: usage,
the 2nd argument must be a pair of permutations,
gap> OnMultiDigraphs(gr1, [(1, 3), (1, 7)]);
Error, Digraphs: OnMultiDigraphs: usage,
the argument <perms[2]> must permute the edges of the 1st argument <graph>,

#  InNeighboursOfVertex and InDegreeOfVertex
gap> gr := DigraphFromDiSparse6String(".IgBGLQ?Apkc");
<multidigraph with 10 vertices, 6 edges>
gap> InNeighborsOfVertex(gr, 7);
[ 7 ]
gap> InNeighboursOfVertex(gr, 7);
[ 7 ]
gap> InDegreeOfVertex(gr, 7);
1
gap> InNeighboursOfVertex(gr, 11);
Error, Digraphs: InNeighboursOfVertex: usage,
the 2nd argument <v> is not a vertex of the first, <digraph>,
gap> InDegreeOfVertex(gr, 11);
Error, Digraphs: InDegreeOfVertex: usage,
the 2nd argument <v> is not a vertex of the 1st, <digraph>,
gap> gr := DigraphFromDiSparse6String(".CgXo?eWCaJ");
<multidigraph with 4 vertices, 11 edges>
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
<multidigraph with 10 vertices, 8 edges>
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
Error, Digraphs: OutNeighboursOfVertex: usage,
the 2nd argument <v> is not a vertex of the 1st, <digraph>,
gap> OutDegreeOfVertex(gr, 12);
Error, Digraphs: OutDegreeOfVertex: usage,
the 2nd argument <v> is not a vertex of the 1st, <digraph>,
gap> gr := Digraph([[2, 2, 2, 2], [2, 2]]);
<multidigraph with 2 vertices, 6 edges>
gap> OutNeighboursOfVertex(gr, 2);
[ 2, 2 ]
gap> OutDegreeOfVertex(gr, 2);
2
gap> OutDegrees(gr);
[ 4, 2 ]
gap> OutDegreeOfVertex(gr, 1);
4

#  InducedSubdigraph
gap> r := rec(nrvertices := 8,
> source := [1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 5, 5, 5, 5, 5, 5],
> range  := [1, 1, 2, 3, 3, 4, 1, 1, 3, 4, 5, 1, 3, 4, 4, 5, 7]);;
gap> gr := Digraph(r);
<multidigraph with 8 vertices, 17 edges>
gap> InducedSubdigraph(gr, [-1]);
Error, Digraphs: InducedSubdigraph: usage,
the second argument <subverts> must be a duplicate-free subset
of the vertices of the first argument <digraph>,
gap> InducedSubdigraph(gr, [1 .. 9]);
Error, Digraphs: InducedSubdigraph: usage,
the second argument <subverts> must be a duplicate-free subset
of the vertices of the first argument <digraph>,
gap> InducedSubdigraph(gr, []);
<digraph with 0 vertices, 0 edges>
gap> InducedSubdigraph(gr, [2 .. 6]);
<multidigraph with 5 vertices, 7 edges>
gap> InducedSubdigraph(gr, [8]);
<digraph with 1 vertex, 0 edges>
gap> i1 := InducedSubdigraph(gr, [1, 4, 3]);
<multidigraph with 3 vertices, 6 edges>
gap> OutNeighbours(i1);
[ [ 1, 1, 3, 3, 2 ], [  ], [ 2 ] ]
gap> i2 := InducedSubdigraph(gr, [3, 4, 3, 1]);
Error, Digraphs: InducedSubdigraph: usage,
the second argument <subverts> must be a duplicate-free subset
of the vertices of the first argument <digraph>,
gap> adj := [[2, 3, 4, 5, 6, 6, 7], [1, 1, 1, 3, 4, 5], [4], [3, 5],
> [1, 2, 2, 3, 4, 4, 6, 5, 6, 7], [], [1], []];;
gap> gr := Digraph(adj);
<multidigraph with 8 vertices, 27 edges>
gap> InducedSubdigraph(gr, ["a"]);
Error, Digraphs: InducedSubdigraph: usage,
the second argument <subverts> must be a duplicate-free subset
of the vertices of the first argument <digraph>,
gap> InducedSubdigraph(gr, [0]);
Error, Digraphs: InducedSubdigraph: usage,
the second argument <subverts> must be a duplicate-free subset
of the vertices of the first argument <digraph>,
gap> InducedSubdigraph(gr, [2 .. 9]);
Error, Digraphs: InducedSubdigraph: usage,
the second argument <subverts> must be a duplicate-free subset
of the vertices of the first argument <digraph>,
gap> InducedSubdigraph(gr, []);
<digraph with 0 vertices, 0 edges>
gap> i1 := InducedSubdigraph(gr, [1, 3, 5, 7]);
<digraph with 4 vertices, 8 edges>
gap> OutNeighbours(i1);
[ [ 2, 3, 4 ], [  ], [ 1, 2, 3, 4 ], [ 1 ] ]
gap> i2 := InducedSubdigraph(gr, [7, 5, 3, 1]);
<digraph with 4 vertices, 8 edges>
gap> i1 = i2;
false
gap> IsIsomorphicDigraph(i1, i2);
true
gap> InducedSubdigraph(gr, [2 .. 8]);
<multidigraph with 7 vertices, 15 edges>
gap> InducedSubdigraph(gr, [8]);
<digraph with 1 vertex, 0 edges>
gap> InducedSubdigraph(gr, [7, 8]);
<digraph with 2 vertices, 0 edges>
gap> gr := Digraph([[2, 4], [4, 5], [2, 5, 5], [5, 5], [3]]);
<multidigraph with 5 vertices, 10 edges>
gap> gri := InducedSubdigraph(gr, [4, 2, 5]);
<multidigraph with 3 vertices, 4 edges>
gap> DigraphVertexLabels(gri);
[ 4, 2, 5 ]
gap> OutNeighbours(gri);
[ [ 3, 3 ], [ 1, 3 ], [  ] ]

#  QuotientDigraph
gap> gr := CompleteDigraph(2);
<digraph with 2 vertices, 2 edges>
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 2, 1 ] ]
gap> qr := QuotientDigraph(gr, [[1, 2]]);
<multidigraph with 1 vertex, 2 edges>
gap> DigraphEdges(qr);
[ [ 1, 1 ], [ 1, 1 ] ]
gap> QuotientDigraph(EmptyDigraph(0), []);
<digraph with 0 vertices, 0 edges>
gap> QuotientDigraph(EmptyDigraph(0), [[1]]);
Error, Digraphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition of the
vertices of the null digraph <digraph>. The only valid partition
of <digraph> is the empty list,
gap> gr := Digraph([[1, 2, 3, 2], [1, 3, 2], [1, 2]]);
<multidigraph with 3 vertices, 9 edges>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ], [ 1, 2 ], [ 2, 1 ], [ 2, 3 ], [ 2, 2 ], 
  [ 3, 1 ], [ 3, 2 ] ]
gap> qr := QuotientDigraph(gr, [[1, 3], [2]]);
<multidigraph with 2 vertices, 9 edges>
gap> DigraphEdges(qr);
[ [ 1, 1 ], [ 1, 2 ], [ 1, 1 ], [ 1, 2 ], [ 1, 1 ], [ 1, 2 ], [ 2, 1 ], 
  [ 2, 1 ], [ 2, 2 ] ]
gap> QuotientDigraph(gr, [3]);
Error, Digraphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],
gap> QuotientDigraph(gr, []);
Error, Digraphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],
gap> QuotientDigraph(gr, [[], []]);
Error, Digraphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],
gap> QuotientDigraph(gr, [[0], [1]]);
Error, Digraphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],
gap> QuotientDigraph(gr, [[1], [2], [0]]);
Error, Digraphs: QuotientDigraph: usage,
the second argument <partition> is not a valid
partition of the vertices of <digraph>, [ 1 .. 3 ],
gap> QuotientDigraph(gr, [[1], [2, 4]]);
Error, Digraphs: QuotientDigraph: usage,
the second argument <partition> is not a valid
partition of the vertices of <digraph>, [ 1 .. 3 ],
gap> QuotientDigraph(gr, [[1, 2], [2]]);
Error, Digraphs: QuotientDigraph: usage,
the second argument <partition> is not a valid
partition of the vertices of <digraph>, [ 1 .. 3 ],
gap> QuotientDigraph(gr, [[1], [2]]);
Error, Digraphs: QuotientDigraph: usage,
the second argument <partition> does not partition
every vertex of the first argument, <digraph>,
gap> gr := Digraph(rec(
> nrvertices := 8,
> source := [1, 1, 2, 2, 3, 4, 4, 4, 5, 5, 5, 5, 5, 6, 7, 7, 7, 7, 7, 8, 8],
> range := [6, 7, 1, 6, 5, 1, 4, 8, 1, 3, 4, 6, 7, 7, 1, 4, 5, 6, 7, 5, 6]));
<digraph with 8 vertices, 21 edges>
gap> qr := QuotientDigraph(gr, [[1], [2, 3, 5, 7], [4, 6, 8]]);
<multidigraph with 3 vertices, 21 edges>
gap> OutNeighbours(qr);
[ [ 3, 2 ], [ 1, 3, 2, 1, 2, 3, 3, 2, 1, 3, 2, 3, 2 ], [ 1, 3, 3, 2, 2, 3 ] ]

#  DigraphInEdges and DigraphOutEdges: for a vertex
gap> gr := Digraph([[2, 2, 2, 2, 2], [1, 1, 1, 1], [1], [3, 2]]);
<multidigraph with 4 vertices, 12 edges>
gap> DigraphInEdges(gr, 1);
[ [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 3, 1 ] ]
gap> DigraphOutEdges(gr, 3);
[ [ 3, 1 ] ]
gap> DigraphOutEdges(gr, 5);
Error, Digraphs: DigraphOutEdges: usage,
5 is not a vertex of the digraph,
gap> DigraphInEdges(gr, 1000);
Error, Digraphs: DigraphInEdges: usage,
1000 is not a vertex of the digraph,
gap> gr := Digraph(rec(vertices := ["a", "b", "c"], source := ["a", "a", "b"],
> range := ["b", "b", "c"]));
<multidigraph with 3 vertices, 3 edges>
gap> DigraphInEdges(gr, 1);
[  ]
gap> DigraphInEdges(gr, 2);
[ [ 1, 2 ], [ 1, 2 ] ]
gap> DigraphOutEdges(gr, 1);
[ [ 1, 2 ], [ 1, 2 ] ]

#  DigraphStronglyConnectedComponent
gap> gr := Digraph([[2, 4], [], [2, 6], [1, 3], [2, 3], [5]]);
<digraph with 6 vertices, 9 edges>
gap> DigraphStronglyConnectedComponent(gr, 1);
[ 1, 4 ]
gap> DigraphStronglyConnectedComponent(gr, 2);
[ 2 ]
gap> DigraphStronglyConnectedComponent(gr, 3);
[ 3, 6, 5 ]
gap> DigraphStronglyConnectedComponent(gr, 7);
Error, Digraphs: DigraphStronglyConnectedComponent: usage,
7 is not a vertex of the digraph,

#  DigraphyConnectedComponent
gap> gr := Digraph([[2, 4], [], [2, 6], [1, 3], [2, 3], [5]]);
<digraph with 6 vertices, 9 edges>
gap> DigraphConnectedComponent(gr, 3);
[ 1, 2, 3, 4, 5, 6 ]
gap> DigraphConnectedComponent(gr, 7);
Error, Digraphs: DigraphConnectedComponent: usage,
7 is not a vertex of the digraph,

#  IsDigraphEdge

# CycleDigraph with source/range
gap> gr := CycleDigraph(1000);
<digraph with 1000 vertices, 1000 edges>
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
<digraph with 1000 vertices, 1000 edges>
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
gap> gr := Digraph(rec(nrvertices := 2, source := [1], range := [2]));
<digraph with 2 vertices, 1 edge>
gap> IsDigraphEdge(gr, [2, 1]);
false
gap> IsDigraphEdge(gr, [1, 1]);
false

# A bigger digraph with OutNeighbours
gap> gr := CompleteDigraph(500);
<digraph with 500 vertices, 249500 edges>
gap> IsDigraphEdge(gr, [200, 199]);
true
gap> IsDigraphEdge(gr, [499, 499]);
false
gap> IsDigraphEdge(gr, [249, 251]);
true
gap> gr := EmptyDigraph(1000000);
<digraph with 1000000 vertices, 0 edges>
gap> IsDigraphEdge(gr, [9999, 9999]);
false
gap> gr := CompleteDigraph(10);
<digraph with 10 vertices, 90 edges>
gap> mat := AdjacencyMatrix(gr);;
gap> IsDigraphEdge(gr, [5, 5]);
false
gap> IsDigraphEdge(gr, [5, 6]);
true
gap> gr := Digraph([[1, 1], [2]]);
<multidigraph with 2 vertices, 3 edges>
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
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [[12]]);
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [[12, 13, 14], [11, 10]]);
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [[-2, 3], ["a"]]);
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [[11, 10], [12, 13, 14]]);
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [[4, 5], [1, 120], [1, 1]]);
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [[4, 5], [120, 1], [1, 1]]);
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> gr := Digraph([[2, 2], [1, 3, 2], [2, 1], [1]]);
<multidigraph with 4 vertices, 8 edges>
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 1, 2 ], [ 2, 1 ], [ 2, 3 ], [ 2, 2 ], [ 3, 2 ], [ 3, 1 ], 
  [ 4, 1 ] ]
gap> gr2 := DigraphAddEdges(gr, [[2, 1], [3, 3], [2, 4], [3, 3]]);
<multidigraph with 4 vertices, 12 edges>
gap> DigraphEdges(gr2);
[ [ 1, 2 ], [ 1, 2 ], [ 2, 1 ], [ 2, 3 ], [ 2, 2 ], [ 2, 1 ], [ 2, 4 ], 
  [ 3, 2 ], [ 3, 1 ], [ 3, 3 ], [ 3, 3 ], [ 4, 1 ] ]
gap> gr3 := Digraph(rec(nrvertices := DigraphNrVertices(gr),
>                         source     := ShallowCopy(DigraphSource(gr)),
>                         range      := ShallowCopy(DigraphRange(gr))));
<multidigraph with 4 vertices, 8 edges>
gap> gr4 := DigraphAddEdges(gr3, [[2, 1], [3, 3], [2, 4], [3, 3]]);
<multidigraph with 4 vertices, 12 edges>
gap> gr2 = gr4;
true
gap> gr := Digraph([[1, 2], [], [1]]);
<digraph with 3 vertices, 3 edges>
gap> gr1 := DigraphAddEdges(gr, []);
<digraph with 3 vertices, 3 edges>
gap> gr = gr1;
true
gap> DigraphAddEdges(gr, [3]);
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [[3]]);
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, ["ab"]);
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [[-1, -2]]);
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [[1, 2], [1, 2, 3]]);
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [[4, 2]]);
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [[2, 4]]);
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [[2, 3], [2, 3]]);
<multidigraph with 3 vertices, 5 edges>
gap> DigraphEdges(last);
[ [ 1, 1 ], [ 1, 2 ], [ 2, 3 ], [ 2, 3 ], [ 3, 1 ] ]
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 2 ], [ 3, 1 ] ]

#  DigraphAddEdge
gap> gr := RandomDigraph(10);;
gap> DigraphAddEdge(gr, [1, 2, 3]);
Error, Digraphs: DigraphAddEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> DigraphAddEdge(gr, ["a", "a"]);
Error, Digraphs: DigraphAddEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> DigraphAddEdge(gr, [1, "a"]);
Error, Digraphs: DigraphAddEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> DigraphAddEdge(gr, [11, 1]);
Error, Digraphs: DigraphAddEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> DigraphAddEdge(gr, [1, 11]);
Error, Digraphs: DigraphAddEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> gr := EmptyDigraph(2);
<digraph with 2 vertices, 0 edges>
gap> DigraphAddEdge(gr, [1, 2]);
<digraph with 2 vertices, 1 edge>
gap> DigraphEdges(last);
[ [ 1, 2 ] ]

#  DigraphAddVertices
gap> gr := Digraph([[1]]);;
gap> gr2 := DigraphAddVertices(gr, 3);
<digraph with 4 vertices, 1 edge>
gap> DigraphVertices(gr2);
[ 1 .. 4 ]
gap> DigraphEdges(gr) = DigraphEdges(gr2);
true
gap> gr2 := DigraphAddVertices(gr, 3, [SymmetricGroup(2), Group(())]);
Error, Digraphs: DigraphAddVertices: usage,
the number of new vertex names (the length of the third argument <names>)
must match the number of new vertices ( the value of the second argument <m>),
gap> gr2 := DigraphAddVertices(gr, 2, [SymmetricGroup(2), Group(())]);
<digraph with 3 vertices, 1 edge>
gap> DigraphVertices(gr2);
[ 1 .. 3 ]
gap> DigraphEdges(gr) = DigraphEdges(gr2);
true
gap> DigraphVertexLabels(gr2);
[ 1, Sym( [ 1 .. 2 ] ), Group(()) ]
gap> gr := Digraph([[1]]);;
gap> SetDigraphVertexLabels(gr, [AlternatingGroup(5)]);
gap> gr2 := DigraphAddVertices(gr, 2, [SymmetricGroup(2), Group(())]);
<digraph with 3 vertices, 1 edge>
gap> DigraphVertexLabels(gr2);
[ Alt( [ 1 .. 5 ] ), Sym( [ 1 .. 2 ] ), Group(()) ]
gap> gr := Digraph(rec(nrvertices := 1, source := [1], range := [1]));
<digraph with 1 vertex, 1 edge>
gap> gr2 := DigraphAddVertices(gr, 2);
<digraph with 3 vertices, 1 edge>
gap> DigraphVertexLabels(gr2);
[ 1, 2, 3 ]
gap> SetDigraphVertexLabels(gr, [true]);
gap> gr2 := DigraphAddVertices(gr, 2);
<digraph with 3 vertices, 1 edge>
gap> DigraphVertexLabels(gr2);
[ true, 2, 3 ]
gap> gr := Digraph(rec(nrvertices := 1, source := [1], range := [1]));;
gap> gr2 := DigraphAddVertices(gr, 2, [SymmetricGroup(2), Group(())]);
<digraph with 3 vertices, 1 edge>
gap> DigraphVertexLabels(gr2);
[ 1, Sym( [ 1 .. 2 ] ), Group(()) ]
gap> gr := Digraph(rec(nrvertices := 1, source := [1], range := [1]));;
gap> SetDigraphVertexLabels(gr, [AlternatingGroup(5)]);
gap> gr2 := DigraphAddVertices(gr, 2, [SymmetricGroup(2), Group(())]);
<digraph with 3 vertices, 1 edge>
gap> DigraphVertexLabels(gr2);
[ Alt( [ 1 .. 5 ] ), Sym( [ 1 .. 2 ] ), Group(()) ]
gap> DigraphAddVertices(gr2, -1);
Error, Digraphs: DigraphAddVertices: usage,
the second argument <m> (the number of vertices to add) must be non-negative,
gap> gr3 := DigraphAddVertices(gr2, 0);
<digraph with 3 vertices, 1 edge>
gap> IsIdenticalObj(gr2, gr3);
false
gap> gr2 = gr3;
true
gap> DigraphAddVertices(gr2, -1, []);
Error, Digraphs: DigraphAddVertices: usage,
the second argument <m> (the number of vertices to add) must be non-negative,
gap> gr3 := DigraphAddVertices(gr2, 0, []);
<digraph with 3 vertices, 1 edge>
gap> IsIdenticalObj(gr2, gr3);
false
gap> gr2 = gr3;
true

#  DigraphAddVertex
gap> gr := CompleteDigraph(1);
<digraph with 1 vertex, 0 edges>
gap> DigraphVertices(gr);
[ 1 ]
gap> gr2 := DigraphAddVertex(gr);
<digraph with 2 vertices, 0 edges>
gap> DigraphVertices(gr2);
[ 1, 2 ]
gap> DigraphEdges(gr) = DigraphEdges(gr2);
true
gap> gr := DigraphAddEdge(gr, [1, 1]);
<digraph with 1 vertex, 1 edge>
gap> DigraphVertices(gr);
[ 1 ]
gap> gr2 := DigraphAddVertex(gr);
<digraph with 2 vertices, 1 edge>
gap> DigraphVertices(gr2);
[ 1, 2 ]
gap> DigraphEdges(gr) = DigraphEdges(gr2);
true
gap> gr2 := DigraphAddVertex(gr, SymmetricGroup(2));
<digraph with 2 vertices, 1 edge>
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
<digraph with 14 vertices, 54 edges>
gap> DigraphRemoveVertex(gr, "a");
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphRemoveVertex' on 2 arguments
gap> DigraphRemoveVertex(gr, 0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphRemoveVertex' on 2 arguments
gap> DigraphRemoveVertex(gr, 15);
Error, Digraphs: DigraphRemoveVertex: usage,
the second argument <m> is not a vertex of the first argument <digraph>,
gap> gr2 := DigraphRemoveVertex(gr, 10);;
gap> DigraphNrVertices(gr2);
13
gap> DigraphNrEdges(gr2) =
> DigraphNrEdges(gr) - OutDegreeOfVertex(gr, 10) - InDegreeOfVertex(gr, 10);
true

#  DigraphRemoveVertices
gap> gr := CompleteDigraph(4);
<digraph with 4 vertices, 12 edges>
gap> gr2 := DigraphRemoveVertices(gr, []);
<digraph with 4 vertices, 12 edges>
gap> gr = gr2;
true
gap> gr2 := DigraphRemoveVertices(gr, [0]);
Error, Digraphs: DigraphRemoveVertices: usage,
the second argument <verts> should be a duplicate free list of vertices of
the first argument <digraph>,
gap> gr2 := DigraphRemoveVertices(gr, [1, "a"]);
Error, Digraphs: DigraphRemoveVertices: usage,
the second argument <verts> should be a duplicate free list of vertices of
the first argument <digraph>,
gap> gr2 := DigraphRemoveVertices(gr, [1, 1]);
Error, Digraphs: DigraphRemoveVertices: usage,
the second argument <verts> should be a duplicate free list of vertices of
the first argument <digraph>,
gap> gr2 := DigraphRemoveVertices(gr, [1, 0]);
Error, Digraphs: DigraphRemoveVertices: usage,
the second argument <verts> should be a duplicate free list of vertices of
the first argument <digraph>,
gap> gr2 := DigraphRemoveVertices(gr, [1, 5]);
Error, Digraphs: DigraphRemoveVertices: usage,
the second argument <verts> should be a duplicate free list of vertices of
the first argument <digraph>,
gap> gr2 := DigraphRemoveVertices(gr, [1, 3]);
<digraph with 2 vertices, 2 edges>
gap> IsCompleteDigraph(gr2);
true
gap> DigraphVertexLabels(gr2);
[ 2, 4 ]
gap> gr3 := DigraphRemoveVertices(gr, [1 .. 4]);
<digraph with 0 vertices, 0 edges>
gap> gr := Digraph(rec(nrvertices := 4,
> source := [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4],
> range  := [1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]));
<digraph with 4 vertices, 16 edges>
gap> IsCompleteDigraph(gr);
false
gap> SetDigraphVertexLabels(gr, [(), (1, 2), (1, 2, 3), (1, 2, 3, 4)]);
gap> gr2 := DigraphRemoveVertices(gr, [1 .. 4]);
<digraph with 0 vertices, 0 edges>
gap> gr3 := DigraphRemoveVertices(gr, [2, 3]);
<digraph with 2 vertices, 4 edges>
gap> DigraphVertexLabels(gr3);
[ (), (1,2,3,4) ]
gap> gr4 := DigraphRemoveVertices(gr, []);
<digraph with 4 vertices, 16 edges>
gap> gr = gr4;
true
gap> gr := Digraph([[1, 10], [], [], [3], [3, 4, 10], [1, 3, 8],
> [9], [9], [3], [3, 5, 10]]);
<digraph with 10 vertices, 15 edges>
gap> DigraphSinks(gr);
[ 2, 3 ]
gap> DigraphRemoveVertices(gr, DigraphSinks(gr));
<digraph with 8 vertices, 10 edges>

#  AsBinaryRelation
gap> gr := EmptyDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> AsBinaryRelation(gr);
Error, Digraphs: AsBinaryRelation: usage,
the argument <digraph> must have at least one vertex,
gap> gr := Digraph([[1, 1]]);
<multidigraph with 1 vertex, 2 edges>
gap> AsBinaryRelation(gr);
Error, Digraphs: AsBinaryRelation: usage,
the argument <digraph> must be a digraph with no multiple edges,
gap> gr := Digraph(
> [[1, 2, 3], [1, 2, 3], [1, 2, 3], [4, 5], [4, 5]]);
<digraph with 5 vertices, 13 edges>
gap> rel1 := AsBinaryRelation(gr);
Binary Relation on 5 points
gap> Digraph(rel1) = gr;
true
gap> IsReflexiveBinaryRelation(rel1);
true
gap> IsSymmetricBinaryRelation(rel1);
true
gap> IsTransitiveBinaryRelation(rel1);
true
gap> IsAntisymmetricBinaryRelation(rel1);
false
gap> IsEquivalenceRelation(rel1);
true
gap> List(EquivalenceClasses(rel1), Elements);
[ [ 1, 2, 3 ], [ 4, 5 ] ]
gap> DigraphStronglyConnectedComponents(gr).comps;
[ [ 1, 2, 3 ], [ 4, 5 ] ]
gap> last = last2;
true
gap> Successors(rel1);
[ [ 1, 2, 3 ], [ 1, 2, 3 ], [ 1, 2, 3 ], [ 4, 5 ], [ 4, 5 ] ]
gap> OutNeighbours(gr);
[ [ 1, 2, 3 ], [ 1, 2, 3 ], [ 1, 2, 3 ], [ 4, 5 ], [ 4, 5 ] ]
gap> last = last2;
true
gap> IsReflexiveDigraph(gr);
true
gap> IsSymmetricDigraph(gr);
true
gap> IsAntisymmetricDigraph(gr);
false
gap> rel2 := AsBinaryRelation(gr);
Binary Relation on 5 points
gap> HasIsReflexiveBinaryRelation(rel2);
true
gap> HasIsSymmetricBinaryRelation(rel2);
true
gap> HasIsTransitiveBinaryRelation(rel2);
false
gap> HasIsAntisymmetricBinaryRelation(rel2);
true
gap> rel3 := AsBinaryRelation(Digraph(rel1));
<equivalence relation on <object> >
gap> HasIsReflexiveBinaryRelation(rel3);
true
gap> HasIsSymmetricBinaryRelation(rel3);
true
gap> HasIsTransitiveBinaryRelation(rel3);
true
gap> HasIsAntisymmetricBinaryRelation(rel3);
true

#  DigraphReverseEdge and DigraphReverseEdges
gap> gr := Digraph([[1, 1]]);
<multidigraph with 1 vertex, 2 edges>
gap> DigraphReverseEdges(gr, [[2, 2]]);
Error, Digraphs: DigraphReverseEdges: usage,
the first argument <digraph> must not be a multigraph,
gap> DigraphReverseEdges(gr, [2]);
Error, Digraphs: DigraphReverseEdges: usage,
the first argument <digraph> must not be a multigraph,
gap> gr := CompleteDigraph(100);
<digraph with 100 vertices, 9900 edges>
gap> DigraphReverseEdges(gr, "a");
Error, Digraphs: DigraphReverseEdges: usage,
the second argument <edge> must be a list of edges of <digraph>,
gap> DigraphReverseEdges(gr, Group(()));
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphReverseEdges' on 2 arguments
gap> DigraphReverseEdges(gr, [0, 0]);
Error, Digraphs: DigraphReverseEdges: usage,
the second argument <edge> must be a list of edges of <digraph>,
gap> DigraphReverseEdges(gr, [[0]]);
Error, Digraphs: DigraphReverseEdges: usage,
the second argument <edges> must be a list of edges of <digraph>,
gap> DigraphReverseEdges(gr, [[1], [1]]);
Error, Digraphs: DigraphReverseEdges: usage,
the second argument <edges> must be a list of edges of <digraph>,
gap> edges := ShallowCopy(DigraphEdges(gr));;
gap> gr = DigraphReverseEdges(gr, edges);
true
gap> gr = DigraphReverseEdges(gr, [1 .. DigraphNrEdges(gr)]);
true
gap> DigraphReverseEdge(gr, 2) = DigraphReverseEdge(gr, [1, 3]);
true
gap> gr = DigraphReverseEdges(gr, []);
true
gap> gr := CycleDigraph(100);
<digraph with 100 vertices, 100 edges>
gap> edges := ShallowCopy(DigraphEdges(gr));;
gap>  gr = DigraphReverseEdges(gr, edges);
false
gap> gr2 := DigraphReverseEdges(gr, edges);
<digraph with 100 vertices, 100 edges>
gap> gr = gr2;
false
gap> edges2 := ShallowCopy(DigraphEdges(gr2));;
gap> gr = DigraphReverseEdges(gr2, edges2);
true
gap> gr = DigraphReverseEdges(gr, [1 .. DigraphNrEdges(gr)]);
false
gap> DigraphReverseEdge(gr, 1) = DigraphReverseEdge(gr, [1, 2]);
true
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
<digraph with 10 vertices, 22 edges>
gap> rtclosure := DigraphFloydWarshall(gr, func, 0, 1);;
gap> grrt := DigraphByAdjacencyMatrix(rtclosure);
<digraph with 10 vertices, 76 edges>
gap> grrt = DigraphReflexiveTransitiveClosure(gr);
true
gap> func := function(mat, i, j, k)
>   if mat[i][k] <> 0 and mat[k][j] <> 0 then
>     mat[i][j] := 1;
>   fi;
> end;
function( mat, i, j, k ) ... end
gap> gr := Digraph(rec(
> nrvertices := 10,
> source := [1, 2, 2, 3, 4, 5, 6, 7, 10, 10, 10],
> range := [6, 9, 5, 7, 3, 4, 8, 4, 7, 9, 8]));
<digraph with 10 vertices, 11 edges>
gap> tclosure := DigraphFloydWarshall(gr, func, 0, 1);;
gap> grt := DigraphByAdjacencyMatrix(tclosure);
<digraph with 10 vertices, 25 edges>
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
<digraph with 10 vertices, 22 edges>
gap> rtclosure := DigraphFloydWarshall(gr, func, 0, 1);;
gap> grrt := DigraphByAdjacencyMatrix(rtclosure);
<digraph with 10 vertices, 76 edges>
gap> grrt = DigraphReflexiveTransitiveClosure(gr);
true
gap> func := function(mat, i, j, k)
>   if mat[i][k] <> 0 and mat[k][j] <> 0 then
>     mat[i][j] := 1;
>   fi;
> end;
function( mat, i, j, k ) ... end
gap> gr := DigraphFromDigraph6String("&I???@?A`?G?GCCS@??");
<digraph with 10 vertices, 11 edges>
gap> tclosure := DigraphFloydWarshall(gr, func, 0, 1);;
gap> grt := DigraphByAdjacencyMatrix(tclosure);
<digraph with 10 vertices, 25 edges>
gap> grt = DigraphTransitiveClosure(gr);
true

#  DigraphDisjointUnion
gap> gr := CycleDigraph(1000);
<digraph with 1000 vertices, 1000 edges>
gap> gr2 := CompleteDigraph(100);
<digraph with 100 vertices, 9900 edges>
gap> DigraphDisjointUnion(gr) = gr;
true
gap> DigraphDisjointUnion([[]]);
Error, Digraphs: DigraphDisjointUnion: usage,
the arguments must be digraphs, or the argument must be a list of digraphs,
gap> DigraphDisjointUnion([gr], [gr]);
Error, Digraphs: DigraphDisjointUnion: usage,
the arguments must be digraphs, or the argument must be a list of digraphs,
gap> DigraphDisjointUnion(gr, Group(()));
Error, Digraphs: DigraphDisjointUnion: usage,
the arguments must be digraphs, or the argument must be a list of digraphs,
gap> DigraphDisjointUnion(gr, gr);
<digraph with 2000 vertices, 2000 edges>
gap> DigraphDisjointUnion([gr2, gr2]);
<digraph with 200 vertices, 19800 edges>
gap> DigraphDisjointUnion(gr, gr2);
<digraph with 1100 vertices, 10900 edges>
gap> gr := CycleDigraph(1000);;
gap> DigraphDisjointUnion(gr2, gr);
<digraph with 1100 vertices, 10900 edges>
gap> gr1 := Digraph([[2, 2, 3], [3], [2]]);
<multidigraph with 3 vertices, 5 edges>
gap> gr2 := Digraph([[1, 2], [1]]);
<digraph with 2 vertices, 3 edges>
gap> gr3 := Digraph(rec(nrvertices := 2,
> source := [1, 1, 2], range := [2, 1, 1]));;
gap> gr2 = gr3;
true
gap> u1 := DigraphDisjointUnion(gr1, gr2);
<multidigraph with 5 vertices, 8 edges>
gap> u2 := DigraphDisjointUnion(gr1, gr3);
<multidigraph with 5 vertices, 8 edges>
gap> u1 = u2;
true
gap> n := 10;;
gap> DigraphDisjointUnion(List([1 .. n], x -> EmptyDigraph(x))) =
> EmptyDigraph(Int(n * (n + 1) / 2));
true
gap> gr := DigraphDisjointUnion(List([2 .. 5], x -> ChainDigraph(x)));
<digraph with 14 vertices, 10 edges>
gap> gr := DigraphAddEdges(gr, [[2, 3], [5, 6], [9, 10]]);
<digraph with 14 vertices, 13 edges>
gap> gr = ChainDigraph(14);
true

#  DigraphEdgeUnion
gap> gr1 := DigraphFromDigraph6String("&I????@A_?AA???@d??");
<digraph with 10 vertices, 9 edges>
gap> gr2 := DigraphFromDiSparse6String(".H`OS?aEMC?bneOY`l_?QCJ");
<multidigraph with 9 vertices, 20 edges>
gap> DigraphEdgeUnion(gr1) = gr1;
true
gap> DigraphEdgeUnion([[]]);
Error, Digraphs: DigraphEdgeUnion: usage,
the arguments must be digraphs, or the argument must be a list of digraphs,
gap> DigraphEdgeUnion([gr1], [gr1]);
Error, Digraphs: DigraphEdgeUnion: usage,
the arguments must be digraphs, or the argument must be a list of digraphs,
gap> DigraphEdgeUnion(gr1, Group(()));
Error, Digraphs: DigraphEdgeUnion: usage,
the arguments must be digraphs, or the argument must be a list of digraphs,
gap> m1 := DigraphEdgeUnion(gr1, gr2);
<multidigraph with 10 vertices, 29 edges>
gap> m2 := DigraphEdgeUnion(gr2, gr1);
<multidigraph with 10 vertices, 29 edges>
gap> gr1 := Digraph([[2], [], [4], [], [6], []]);
<digraph with 6 vertices, 3 edges>
gap> gr2 := Digraph([[], [3], [], [5], [], [1]]);
<digraph with 6 vertices, 3 edges>
gap> m := DigraphEdgeUnion(gr1, gr2);
<digraph with 6 vertices, 6 edges>
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
<multidigraph with 10 vertices, 40 edges>
gap> OutNeighbours(gr);
[ [ 6, 3, 3, 10, 6, 6, 3, 3, 10, 6 ], [ 4, 4 ], [ 5, 1, 5, 1 ], 
  [ 5, 4, 6, 5, 4, 6 ], [ 9, 9 ], [ 8, 8 ], [ 7, 6, 7, 6 ], 
  [ 8, 10, 8, 1, 8, 10, 8, 1 ], [  ], [ 2, 2 ] ]
gap> gr := DigraphEdgeUnion(ChainDigraph(2), ChainDigraph(3), ChainDigraph(4));
<multidigraph with 4 vertices, 6 edges>
gap> OutNeighbours(gr);
[ [ 2, 2, 2 ], [ 3, 3 ], [ 4 ], [  ] ]

#  DigraphJoin
gap> gr := CompleteDigraph(20);
<digraph with 20 vertices, 380 edges>
gap> gr2 := EmptyDigraph(10);
<digraph with 10 vertices, 0 edges>
gap> DigraphJoin(gr) = gr;
true
gap> DigraphJoin([[]]);
Error, Digraphs: DigraphJoin: usage,
the arguments must be digraphs, or the argument must be a list of digraphs,
gap> DigraphJoin([gr], [gr]);
Error, Digraphs: DigraphJoin: usage,
the arguments must be digraphs, or the argument must be a list of digraphs,
gap> DigraphJoin([gr, Group(())]);
Error, Digraphs: DigraphJoin: usage,
the arguments must be digraphs, or the argument must be a list of digraphs,
gap> DigraphJoin(gr, gr2);
<digraph with 30 vertices, 780 edges>
gap> DigraphJoin(gr, EmptyDigraph(0));
<digraph with 20 vertices, 380 edges>
gap> DigraphJoin(EmptyDigraph(0), CycleDigraph(1000));
<digraph with 1000 vertices, 1000 edges>
gap> DigraphJoin(EmptyDigraph(0), EmptyDigraph(0));
<digraph with 0 vertices, 0 edges>
gap> DigraphJoin(EmptyDigraph(5), EmptyDigraph(5));
<digraph with 10 vertices, 50 edges>
gap> gr1 := Digraph([[2, 2, 3], [3], [2]]);
<multidigraph with 3 vertices, 5 edges>
gap> gr2 := Digraph([[1, 2], [1]]);
<digraph with 2 vertices, 3 edges>
gap> gr3 := Digraph(rec(nrvertices := 2,
> source := [1, 1, 2], range := [2, 1, 1]));;
gap> gr2 = gr3;
true
gap> j1 := DigraphJoin(gr1, gr2);
<multidigraph with 5 vertices, 20 edges>
gap> j2 := DigraphJoin(gr1, gr3);
<multidigraph with 5 vertices, 20 edges>
gap> u1 = u2;
true
gap> gr := DigraphJoin(ChainDigraph(2), CycleDigraph(4), EmptyDigraph(0));
<digraph with 6 vertices, 21 edges>
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
<digraph with 10 vertices, 8 edges>
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
<digraph with 10 vertices, 8 edges>
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
<multidigraph with 2 vertices, 5 edges>
gap> gr2 := DigraphRemoveAllMultipleEdges(gr1);
<digraph with 2 vertices, 3 edges>
gap> OutNeighbours(gr2);
[ [ 1, 2 ], [ 1 ] ]
gap> gr3 := DigraphEdgeUnion(gr1, gr1);
<multidigraph with 2 vertices, 10 edges>
gap> gr4 := DigraphRemoveAllMultipleEdges(gr3);
<digraph with 2 vertices, 3 edges>
gap> gr2 = gr4;
true

#  IsReachable
gap> gr1 := DigraphRemoveEdges(CycleDigraph(100), [[100, 1], [99, 100]]);
<digraph with 100 vertices, 98 edges>
gap> IsReachable(gr1, 0, 1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `IsReachable' on 3 arguments
gap> IsReachable(gr1, 101, 1);
Error, Digraphs: IsReachable: usage,
the second and third arguments <u> and <v> must be
vertices of the first argument <digraph>,
gap> IsReachable(gr1, 1, 101);
Error, Digraphs: IsReachable: usage,
the second and third arguments <u> and <v> must be
vertices of the first argument <digraph>,
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
<digraph with 100 vertices, 100 edges>
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
<digraph with 4 vertices, 3 edges>
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
<digraph with 5 vertices, 16 edges>
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
<digraph with 10 vertices, 9 edges>
gap> DigraphPath(gr, 1, 2);
[ [ 1, 2 ], [ 1 ] ]
gap> DigraphPath(gr, 1, 1);
fail
gap> DigraphPath(gr, 2, 1);
fail
gap> DigraphPath(gr, 3, 8);
[ [ 3, 4, 5, 6, 7, 8 ], [ 1, 1, 1, 1, 1 ] ]
gap> DigraphPath(gr, 11, 1);
Error, Digraphs: DigraphPath: usage,
the second and third arguments <u> and <v> must be
vertices of the first argument <digraph>,
gap> DigraphPath(gr, 1, 11);
Error, Digraphs: DigraphPath: usage,
the second and third arguments <u> and <v> must be
vertices of the first argument <digraph>,
gap> DigraphPath(gr, 11, 11);
Error, Digraphs: DigraphPath: usage,
the second and third arguments <u> and <v> must be
vertices of the first argument <digraph>,

#  IteratorOfPaths
gap> gr := CompleteDigraph(5);;
gap> iter := IteratorOfPaths(gr, 2, 6);
Error, Digraphs: IteratorOfPaths: usage,
the second and third arguments <u> and <v> must be vertices of the first
argument, <digraph>,
gap> iter := IteratorOfPaths(gr, 6, 6);
Error, Digraphs: IteratorOfPaths: usage,
the second and third arguments <u> and <v> must be vertices of the first
argument, <digraph>,
gap> iter := IteratorOfPaths(gr, 6, 2);
Error, Digraphs: IteratorOfPaths: usage,
the second and third arguments <u> and <v> must be vertices of the first
argument, <digraph>,
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
Error, Digraphs: IteratorOfPaths: usage,
the second and third arguments <u> and <v> must be vertices of the digraph
defined by the first argument, <digraph>,
gap> gr := [[2]];;
gap> IteratorOfPaths(gr, 1, 1);;
Error, Digraphs: IteratorOfPaths: usage,
the first argument <out> must be a list of out-neighbours of a digraph,
gap> gr := [[0]];;
gap> IteratorOfPaths(gr, 1, 1);;
Error, Digraphs: IteratorOfPaths: usage,
the first argument <out> must be a list of out-neighbours of a digraph,
gap> gr := [[1], [3]];;
gap> IteratorOfPaths(gr, 1, 1);;
Error, Digraphs: IteratorOfPaths: usage,
the first argument <out> must be a list of out-neighbours of a digraph,
gap> gr := [[1], [3], [2, 2]];;
gap> iter := IteratorOfPaths(gr, 1, 1);
<iterator>
gap> for a in iter do
>   Print(a, "\n");
> od;
[ [ 1, 1 ], [ 1 ] ]
gap> gr := DigraphFromDigraph6String("+E?_OHCO");
<digraph with 6 vertices, 6 edges>
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
<digraph with 15 vertices, 18 edges>
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
Error, Digraphs: DigraphLongestDistanceFromVertex: usage,
the second argument <v> must be a vertex of the first argument, <digraph>,

#  Digraph(Reflexive)TransitiveReduction

# Check errors
gap> gr := Digraph([[2, 2], []]);
<multidigraph with 2 vertices, 2 edges>
gap> DigraphTransitiveReduction(gr);
Error, Digraphs: DigraphTransitiveReduction: usage,
this method does not work for MultiDigraphs,
gap> DigraphReflexiveTransitiveReduction(gr);
Error, Digraphs: DigraphReflexiveTransitiveReduction: usage,
this method does not work for MultiDigraphs,
gap> gr := Digraph([[2], [1]]);
<digraph with 2 vertices, 2 edges>
gap> DigraphTransitiveReduction(gr);
Error, Digraphs: DigraphTransitiveReduction:
not yet implemented for non-topologically sortable digraphs,
gap> DigraphReflexiveTransitiveReduction(gr);
Error, Digraphs: DigraphReflexiveTransitiveReduction:
not yet implemented for non-topologically sortable digraphs,

# Working examples
gap> gr1 := ChainDigraph(6);
<digraph with 6 vertices, 5 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr1);
<digraph with 6 vertices, 21 edges>
gap> DigraphTransitiveReduction(gr2) = gr1;  # trans reduction contains loops
false
gap> DigraphReflexiveTransitiveReduction(gr2) = gr1;  # ref trans reduct doesnt
true
gap> gr3 := DigraphAddEdge(gr1, [3, 3]);
<digraph with 6 vertices, 6 edges>
gap> DigraphHasLoops(gr3);
true
gap> gr4 := DigraphTransitiveClosure(gr3);
<digraph with 6 vertices, 16 edges>
gap> gr2 = gr4;
false
gap> DigraphReflexiveTransitiveReduction(gr4) = gr1;
true
gap> DigraphReflexiveTransitiveReduction(gr4) = gr3;
false
gap> DigraphTransitiveReduction(gr4) = gr3;
true

# Special cases
gap> DigraphTransitiveReduction(EmptyDigraph(0)) = EmptyDigraph(0);
true
gap> DigraphReflexiveTransitiveReduction(EmptyDigraph(0)) = EmptyDigraph(0);
true

#  DigraphLayers
gap> gr := CompleteDigraph(4);
<digraph with 4 vertices, 12 edges>
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
Error, Digraphs: DigraphLayers: usage,
the argument <v> must be a vertex of <digraph>,
gap> DigraphShortestDistance(gr, [2, 5, 6], [3, 7]);
1
gap> DigraphShortestDistance(gr, [2], DigraphLayers(gr, 2)[3]);
2
gap> DigraphShortestDistance(gr, [2, 3], [3, 4]);
0
gap> gr := CompleteDigraph(64);
<digraph with 64 vertices, 4032 edges>
gap> DigraphShortestDistance(gr, [1 .. 10], [20 .. 23]);
1
gap> DigraphShortestDistance(gr, [1, 13], [20 .. 23]);
1
gap> DigraphShortestDistance(gr, [1, 13], [38, 41]);
1
gap> gr := ChainDigraph(72);
<digraph with 72 vertices, 71 edges>
gap> DigraphShortestDistance(gr, [1 .. 10], [20 .. 23]);
10
gap> DigraphShortestDistance(gr, [1, 13], [20 .. 23]);
7
gap> DigraphShortestDistance(gr, [1, 13], [38, 41]);
25
gap> gr := DigraphFromDigraph6String("+H^_HRR\P_FWEsio");
<digraph with 9 vertices, 32 edges>
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
<digraph with 30 vertices, 90 edges>
gap> DigraphGroup(gr);
<permutation group with 5 generators>
gap> DigraphShortestDistance(gr, 1, 16);
1

#  DigraphShortestDistance: two inputs
gap> gr := Digraph([[2], [3], [1, 4], [1, 3], [5]]);
<digraph with 5 vertices, 7 edges>
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
Error, Digraphs: DigraphShortestDistance: usage,
the second argument and third argument must be
vertices of the digraph,
gap> DigraphShortestDistance(gr, [1, 74]);
Error, Digraphs: DigraphShortestDistance: usage,
elements of the list must be vertices of the digraph,
gap> DigraphShortestDistance(gr, [1, 71, 3]);
Error, Digraphs: DigraphShortestDistance: usage,
the second argument must be of length 2,

#  DigraphDistancesSet
gap> gr := ChainDigraph(10);
<digraph with 10 vertices, 9 edges>
gap> DigraphDistanceSet(gr, 5, 2);
[ 7 ]
gap> gr := DigraphSymmetricClosure(ChainDigraph(10));
<digraph with 10 vertices, 18 edges>
gap> DigraphDistanceSet(gr, 5, 2);
[ 3, 7 ]
gap> gr := ChainDigraph(10);;
gap> DigraphDistanceSet(gr, 20, 1);
Error, Digraphs: DigraphDistanceSet: usage,
the second argument must be a vertex of the digraph,
gap> DigraphDistanceSet(gr, 20, [1]);
Error, Digraphs: DigraphDistanceSet: usage,
the second argument must be a vertex of the digraph,
gap> DigraphDistanceSet(gr, 10, ["string", 1]);
Error, Digraphs: DigraphDistanceSet: usage,
the third argument must be a list of non-negative integers,
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
Error, Digraphs: DigraphDistanceSet: usage,
the third argument must be a non-negative integer,

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
<multidigraph with 3 vertices, 12 edges>
gap> gr2 := DigraphEdgeUnion(CycleDigraph(3), CycleDigraph(3));
<multidigraph with 3 vertices, 6 edges>
gap> IsSubdigraph(gr1, gr2);
true
gap> IsSubdigraph(gr2, gr1);
false
gap> gr3 := Digraph([[2, 2, 3], [3], []]);
<multidigraph with 3 vertices, 4 edges>
gap> gr4 := Digraph([[2, 3, 3], [3], []]);
<multidigraph with 3 vertices, 4 edges>
gap> IsSubdigraph(gr3, gr4) or IsSubdigraph(gr4, gr3);
false
gap> gr1 := Digraph([[1, 1], []]);
<multidigraph with 2 vertices, 2 edges>
gap> gr2 := Digraph([[], [2, 2]]);
<multidigraph with 2 vertices, 2 edges>
gap> IsSubdigraph(gr1, gr2) or IsSubdigraph(gr2, gr1);
false

#  IsUndirectedSpanningForest
gap> gr1 := CompleteDigraph(10);
<digraph with 10 vertices, 90 edges>
gap> gr2 := EmptyDigraph(9);
<digraph with 9 vertices, 0 edges>
gap> IsUndirectedSpanningForest(gr1, gr2);
false
gap> gr2 := DigraphAddEdge(EmptyDigraph(10), [1, 2]);
<digraph with 10 vertices, 1 edge>
gap> IsUndirectedSpanningForest(gr1, gr2);
false
gap> gr2 := DigraphAddEdge(gr2, [2, 1]);
<digraph with 10 vertices, 2 edges>
gap> IsUndirectedSpanningForest(gr1, gr2);
false
gap> IsUndirectedSpanningForest(gr1, DigraphFromSparse6String(":I`ESyTl^F"));
true
gap> gr := DigraphFromDigraph6String("&I?PIMAQc@A?W?ADPP?");
<digraph with 10 vertices, 23 edges>
gap> IsUndirectedSpanningForest(gr, DigraphByEdges([[2, 7], [7, 2]], 10));
true

#  IsUndirectedSpanningTree
gap> IsUndirectedSpanningTree(EmptyDigraph(1), EmptyDigraph(1));
true
gap> IsUndirectedSpanningTree(EmptyDigraph(2), EmptyDigraph(2));
false
gap> gr := DigraphFromDigraph6String("&I?PIMAQc@A?W?ADPP?");
<digraph with 10 vertices, 23 edges>
gap> IsUndirectedSpanningTree(gr, EmptyDigraph(10));
false
gap> gr := DigraphFromGraph6String("INB`cZoQ_");
<digraph with 10 vertices, 38 edges>
gap> IsUndirectedSpanningTree(gr, gr);
false
gap> gr1 := DigraphEdgeUnion(CycleDigraph(5), DigraphReverse(CycleDigraph(5)));
<digraph with 5 vertices, 10 edges>
gap> gr2 := DigraphEdgeUnion(ChainDigraph(5), DigraphReverse(ChainDigraph(5)));
<digraph with 5 vertices, 8 edges>
gap> IsUndirectedSpanningTree(gr1, gr2);
true
gap> IsUndirectedSpanningTree(gr2, gr2);
true

#  PartialOrderDigraphMeetOfVertices
gap> gr := CycleDigraph(5);
<digraph with 5 vertices, 5 edges>
gap> PartialOrderDigraphJoinOfVertices(gr, 1, 4);
Error, Digraphs: PartialOrderDigraphJoinOfVertices: usage,
the first argument <digraph> must be a partial order digraph,

#Join semilattice on 9 vertices
gap> gr := DigraphFromDiSparse6String(".HiR@AeNcC?oD?G`oAGXIoAGXAe_COqDK^F");
<digraph with 9 vertices, 36 edges>
gap> PartialOrderDigraphMeetOfVertices(gr, 2, 3);
1
gap> PartialOrderDigraphJoinOfVertices(gr, 2, 3);
4
gap> PartialOrderDigraphJoinOfVertices(gr, 3, 9);
5
gap> PartialOrderDigraphMeetOfVertices(gr, 3, 9);
fail
gap> gr := DigraphReverse(gr);
<digraph with 9 vertices, 36 edges>
gap> PartialOrderDigraphMeetOfVertices(gr, 2, 3);
4
gap> PartialOrderDigraphJoinOfVertices(gr, 2, 3);
1
gap> PartialOrderDigraphMeetOfVertices(gr, 3, 9);
5

# Testing invalid input
gap> gr := Digraph([[1, 2, 3], [1, 2, 3], [1, 2, 3]]);
<digraph with 3 vertices, 9 edges>
gap> PartialOrderDigraphMeetOfVertices(gr, 2, 3);
Error, Digraphs: PartialOrderDigraphMeetOfVertices: usage,
the first argument <digraph> must be a partial order digraph,
gap> PartialOrderDigraphJoinOfVertices(gr, 2, 3);
Error, Digraphs: PartialOrderDigraphJoinOfVertices: usage,
the first argument <digraph> must be a partial order digraph,
gap> gr1 := Digraph([[1], [2], [1, 2, 3], [1, 2, 4]]);
<digraph with 4 vertices, 8 edges>
gap> gr2 := DigraphReverse(gr1);
<digraph with 4 vertices, 8 edges>

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
Error, Digraphs: DigraphClosure: usage,
the digraph must by symmetric, without loops, and no multiple edges,
gap> gr := Digraph([[2], [3], [1]]);;
gap> DigraphClosure(gr, 2);
Error, Digraphs: DigraphClosure: usage,
the digraph must by symmetric, without loops, and no multiple edges,

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
<digraph with 5 vertices, 5 edges>
gap> IsPerfectMatching(gr, [[1, 3]]);
false
gap> edges := [[1, 2], [4, 5]];;
gap> IsMatching(gr, edges);
true
gap> IsPerfectMatching(gr, edges);
false
gap> gr := CompleteDigraph(500);
<digraph with 500 vertices, 249500 edges>
gap> edges := [];;
gap> for i in [0 .. 249] do
>   Append(edges, [[2 * i + 1, 2 * i + 2]]);
> od;;
gap> IsPerfectMatching(gr, edges);
true
gap> gr := Digraph([[2], [3, 4], [], [5], [1, 6], [1]]);
<digraph with 6 vertices, 7 edges>
gap> edges := [[1, 6], [2, 3], [5, 4]];;
gap> IsMatching(gr, edges);
false
gap> edges := [[6, 1], [2, 3], [4, 5]];;
gap> IsPerfectMatching(gr, edges);
true
gap> gr := Digraph([[2], [3], [4, 3], [5], [1]]);
<digraph with 5 vertices, 6 edges>
gap> edges := [[1, 2], [4, 5], [3, 3]];;
gap> IsPerfectMatching(gr, edges);
true

#  IsMaximalMatching
gap> gr := Digraph([[2], [3], [4], [5], [1]]);
<digraph with 5 vertices, 5 edges>
gap> edges := [[1, 2], [4, 3]];;
gap> IsMatching(gr, edges);
false
gap> edges := [[1, 2], [3, 4]];;
gap> IsMaximalMatching(gr, edges);
true
gap> gr := Digraph([[2], [3], [4], [5], [1, 5]]);
<digraph with 5 vertices, 6 edges>
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

# AsSemigroup, AsMonoid (for IsPartialPermX and a digraph)
gap> di := Digraph([[1], [1, 2], [1, 2, 3], [1, 2, 3, 4]]);;
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> di := Digraph([[1], [1, 2], [1, 3], [1, 2, 3, 4]]);;
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> temp := "&P_?@_?B`?FrCK_GXoXo_B?_A@aCA`GDroG`_?`?@e??c?@w??_";;
gap> di := DigraphFromDigraph6String(temp);;
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> temp := Concatenation("+u~~~~~~~~~^~w??????Nw???????E????????A",
>     "????????@_????????_???????AO????????g???????EE???????AA???????@`_?????",
>     "??__??????AQO???????gg??????NwF~~}???E?B~_??????@w????????o????????O??",
>     "??????W????????u????????Q????????Z?????A???_??????@w]???????oK???????O",
>     "C???????WE???????uL_??????QC_???@_?ZEw????_???G???AO??_C????g???I???EE",
>     "B~_@~o???@w??{?????o??W?????O??G?????W??K?????u??Z?????Q??H?????Z??L_?",
>     "AA??_??O???@w]?{N????oK?WE????OC?GA????WE?KB????uL_ZEo???QC_HAO@`_ZEwL",
>     "b[?__??G??CAQO?_C?OA?gg??I??D");;
gap> di := DigraphFromDigraph6String(temp);;
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> di := Digraph(Combinations([1 .. 6]), {i, j} -> IsSubset(i, j));;
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> di := Digraph([[1], [1, 2], [1, 2, 3, 4, 5, 6], [4], [4, 5], [6]]);;
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> di := Digraph([[1]]);;
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> di := Digraph([[1], [1, 2], [1, 2, 3], [1, 2, 4], [1, 2, 3, 4, 5]]);;
gap> S := AsMonoid(IsPartialPermMonoid, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> IsMonoid(S);
true
gap> di := Digraph([[1], [2]]);
<digraph with 2 vertices, 2 edges>
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
Error, Digraphs: AsSemigroup usage,
the second argument must be a join semilattice digraph or a meet semilattice d\
igraph,
gap> S := AsMonoid(IsPartialPermMonoid, di);;
Error, Digraphs: AsMonoid usage,
the second argument must be a lattice digraph,
gap> S := AsSemigroup(IsTransformation, di);;
Error, Digraphs: AsSemigroup usage,
the first argument must be IsPartialPermSemigroup,
gap> S := AsMonoid(IsTransformation, di);;
Error, Digraphs: AsMonoid usage,
the first argument must be IsPartialPermMonoid or IsPartialPermSemigroup,

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

# DIGRAPHS_UnbindVariables
gap> Unbind(a);
gap> Unbind(adj);
gap> Unbind(b);
gap> Unbind(e);
gap> Unbind(edges);
gap> Unbind(edges2);
gap> Unbind(erev);
gap> Unbind(func);
gap> Unbind(g);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(gr3);
gap> Unbind(gr4);
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
gap> Unbind(t);
gap> Unbind(tclosure);
gap> Unbind(temp);
gap> Unbind(u1);
gap> Unbind(u2);

#E#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/oper.tst", 0);
