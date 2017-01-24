#############################################################################
##
#W  standard/attr.tst
#Y  Copyright (C) 2014-17                                James D. Mitchell
##                                                          Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/attr.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#T# DigraphSource and DigraphRange
gap> nbs := [[12, 22, 17, 1, 10, 11], [23, 21, 21, 16],
>  [15, 5, 22, 11, 12, 8, 10, 1], [21, 15, 23, 5, 23, 8, 24],
>  [20, 17, 25, 25], [5, 24, 22, 5, 2], [11, 8, 19],
>  [18, 20, 13, 3, 11], [15, 18, 12, 10], [8, 23, 15, 25, 8, 19, 17],
>  [19, 2, 17, 21, 18], [9, 4, 7, 3], [14, 10, 2], [11, 24, 14],
>  [2, 21], [12], [9, 2, 11, 9], [21, 24, 16, 8, 8], [3], [5, 6],
>  [14, 2], [24, 24, 20], [19, 8, 20], [7, 1, 2, 15, 13, 9],
>  [16, 12, 19]];;
gap> gr := Digraph(nbs);
<multidigraph with 25 vertices, 100 edges>
gap> HasDigraphSource(gr);
false
gap> HasDigraphRange(gr);
false
gap> DigraphNrVertices(gr);
25
gap> DigraphSource(gr);
[ 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 
  5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 
  10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 14, 14, 14, 
  15, 15, 16, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 20, 20, 21, 21, 22, 22, 
  22, 23, 23, 23, 24, 24, 24, 24, 24, 24, 25, 25, 25 ]
gap> HasDigraphSource(gr);
true
gap> HasDigraphRange(gr);
true
gap> DigraphRange(gr);
[ 12, 22, 17, 1, 10, 11, 23, 21, 21, 16, 15, 5, 22, 11, 12, 8, 10, 1, 21, 15, 
  23, 5, 23, 8, 24, 20, 17, 25, 25, 5, 24, 22, 5, 2, 11, 8, 19, 18, 20, 13, 
  3, 11, 15, 18, 12, 10, 8, 23, 15, 25, 8, 19, 17, 19, 2, 17, 21, 18, 9, 4, 
  7, 3, 14, 10, 2, 11, 24, 14, 2, 21, 12, 9, 2, 11, 9, 21, 24, 16, 8, 8, 3, 
  5, 6, 14, 2, 24, 24, 20, 19, 8, 20, 7, 1, 2, 15, 13, 9, 16, 12, 19 ]
gap> gr := Digraph(nbs);
<multidigraph with 25 vertices, 100 edges>
gap> HasDigraphSource(gr);
false
gap> HasDigraphRange(gr);
false
gap> DigraphRange(gr);
[ 12, 22, 17, 1, 10, 11, 23, 21, 21, 16, 15, 5, 22, 11, 12, 8, 10, 1, 21, 15, 
  23, 5, 23, 8, 24, 20, 17, 25, 25, 5, 24, 22, 5, 2, 11, 8, 19, 18, 20, 13, 
  3, 11, 15, 18, 12, 10, 8, 23, 15, 25, 8, 19, 17, 19, 2, 17, 21, 18, 9, 4, 
  7, 3, 14, 10, 2, 11, 24, 14, 2, 21, 12, 9, 2, 11, 9, 21, 24, 16, 8, 8, 3, 
  5, 6, 14, 2, 24, 24, 20, 19, 8, 20, 7, 1, 2, 15, 13, 9, 16, 12, 19 ]
gap> HasDigraphSource(gr);
true
gap> HasDigraphRange(gr);
true
gap> DigraphSource(gr);
[ 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 
  5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 
  10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 14, 14, 14, 
  15, 15, 16, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 20, 20, 21, 21, 22, 22, 
  22, 23, 23, 23, 24, 24, 24, 24, 24, 24, 25, 25, 25 ]

#T# DigraphDual
gap> gr := Digraph([[6, 7], [6, 9], [1, 3, 4, 5, 8, 9],
> [1, 2, 3, 4, 5, 6, 7, 10], [1, 5, 6, 7, 10], [2, 4, 5, 9, 10],
> [3, 4, 5, 6, 7, 8, 9, 10], [1, 3, 5, 7, 8, 9], [1, 2, 5],
> [1, 2, 4, 6, 7, 8]]);;
gap> OutNeighbours(DigraphDual(gr));
[ [ 1, 2, 3, 4, 5, 8, 9, 10 ], [ 1, 2, 3, 4, 5, 7, 8, 10 ], [ 2, 6, 7, 10 ], 
  [ 8, 9 ], [ 2, 3, 4, 8, 9 ], [ 1, 3, 6, 7, 8 ], [ 1, 2 ], [ 2, 4, 6, 10 ], 
  [ 3, 4, 6, 7, 8, 9, 10 ], [ 3, 5, 9, 10 ] ]
gap> gr := Digraph(rec(vertices := ["a", "b"],
> source := ["b", "b"], range := ["a", "a"]));
<multidigraph with 2 vertices, 2 edges>
gap> DigraphDual(gr);
Error, Digraphs: DigraphDual: usage,
the argument <graph> must not have multiple edges,
gap> gr := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> DigraphDual(gr);
<digraph with 0 vertices, 0 edges>
gap> gr := Digraph([[], []]);
<digraph with 2 vertices, 0 edges>
gap> DigraphDual(gr);
<digraph with 2 vertices, 4 edges>
gap> gr := Digraph(rec(nrvertices := 2, source := [], range := []));
<digraph with 2 vertices, 0 edges>
gap> DigraphDual(gr);
<digraph with 2 vertices, 4 edges>
gap> gr := Digraph([[2, 2], []]);
<multidigraph with 2 vertices, 2 edges>
gap> DigraphDual(gr);
Error, Digraphs: DigraphDual: usage,
the argument <graph> must not have multiple edges,
gap> r := rec(nrvertices := 6,
> source := [2, 2, 2, 2, 2, 2, 4, 4, 4],
> range  := [1, 2, 3, 4, 5, 6, 3, 4, 5]);;
gap> gr := Digraph(r);
<digraph with 6 vertices, 9 edges>
gap> DigraphDual(gr);
<digraph with 6 vertices, 27 edges>
gap> r := rec(nrvertices := 4, source := [], range := []);;
gap> gr := Digraph(r);
<digraph with 4 vertices, 0 edges>
gap> DigraphDual(gr);
<digraph with 4 vertices, 16 edges>
gap> gr := Digraph(r);;
gap> SetDigraphVertexLabels(gr, [4, 3, 2, 1]);
gap> gr2 := DigraphDual(gr);;
gap> DigraphVertexLabels(gr2);
[ 4, 3, 2, 1 ]
gap> DigraphNrVertices(gr2);
4
gap> gr := Digraph([[1], [1, 3], [1, 2]]);
<digraph with 3 vertices, 5 edges>
gap> DigraphGroup(gr) = Group((2, 3));
true
gap> gr2 := DigraphDual(gr);
<digraph with 3 vertices, 4 edges>
gap> OutNeighbours(gr2);
[ [ 2, 3 ], [ 2 ], [ 3 ] ]
gap> HasDigraphGroup(gr2);
true
gap> DigraphGroup(gr2) = Group((2, 3));
true
gap> DigraphGroup(gr2) = DigraphGroup(gr);
true

#T# AdjacencyMatrix
gap> gr := Digraph(rec(nrvertices := 10,
> source := [1, 1, 1, 1, 1, 1, 1, 1],
> range := [2, 2, 3, 3, 4, 4, 5, 5]));
<multidigraph with 10 vertices, 8 edges>
gap> AdjacencyMatrix(gr);
[ [ 0, 2, 2, 2, 2, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ]
gap> AdjacencyMatrix(Digraph([[]]));
[ [ 0 ] ]
gap> AdjacencyMatrix(Digraph([]));
[  ]
gap> r := rec(nrvertices := 7,
> source := [1, 1, 2, 2, 3, 4, 4, 5, 6, 7, 7],
> range  := [3, 4, 2, 4, 6, 6, 7, 2, 7, 5, 5]);;
gap> gr := Digraph(r);
<multidigraph with 7 vertices, 11 edges>
gap> adj1 := AdjacencyMatrix(gr);
[ [ 0, 0, 1, 1, 0, 0, 0 ], [ 0, 1, 0, 1, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 1, 0 ], 
  [ 0, 0, 0, 0, 0, 1, 1 ], [ 0, 1, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 1 ], 
  [ 0, 0, 0, 0, 2, 0, 0 ] ]
gap> gr := Digraph(OutNeighbours(gr));
<multidigraph with 7 vertices, 11 edges>
gap> adj2 := AdjacencyMatrix(gr);
[ [ 0, 0, 1, 1, 0, 0, 0 ], [ 0, 1, 0, 1, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 1, 0 ], 
  [ 0, 0, 0, 0, 0, 1, 1 ], [ 0, 1, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 1 ], 
  [ 0, 0, 0, 0, 2, 0, 0 ] ]
gap> adj1 = adj2;
true
gap> r := rec(nrvertices := 1, source := [1, 1], range := [1, 1]);;
gap> gr := Digraph(r);
<multidigraph with 1 vertex, 2 edges>
gap> adj1 := AdjacencyMatrix(gr);
[ [ 2 ] ]
gap> gr := Digraph(OutNeighbours(gr));
<multidigraph with 1 vertex, 2 edges>
gap> adj2 := AdjacencyMatrix(gr);
[ [ 2 ] ]
gap> adj1 = adj2;
true
gap> AdjacencyMatrix(Digraph([]));
[  ]
gap> AdjacencyMatrix(
> Digraph(rec(nrvertices := 0, source := [], range := [])));
[  ]

#T# DigraphTopologicalSort
gap> r := rec(nrvertices := 20000, source := [], range := []);;
gap> for i in [1 .. 9999] do
>   Add(r.source, i);
>   Add(r.range, i + 1);
> od;
> Add(r.source, 10000);; Add(r.range, 20000);;
> Add(r.source, 10001);; Add(r.range, 1);;
> for i in [10001 .. 19999] do
>   Add(r.source, i);
>   Add(r.range, i + 1);
> od;
gap> circuit := Digraph(r);
<digraph with 20000 vertices, 20000 edges>
gap> topo := DigraphTopologicalSort(circuit);;
gap> Length(topo);
20000
gap> topo[1] = 20000;
true
gap> topo[20000] = 10001;
true
gap> topo[12345];
17656
gap> gr := Digraph([[2], [1]]);
<digraph with 2 vertices, 2 edges>
gap> DigraphTopologicalSort(gr);
fail
gap> r := rec(nrvertices := 2, source := [1, 1], range := [2, 2]);;
gap> multiple := Digraph(r);;
gap> DigraphTopologicalSort(multiple);
[ 2, 1 ]
gap> gr := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> DigraphTopologicalSort(gr);
[  ]
gap> gr := Digraph([[]]);
<digraph with 1 vertex, 0 edges>
gap> DigraphTopologicalSort(gr);
[ 1 ]
gap> gr := Digraph([[1]]);
<digraph with 1 vertex, 1 edge>
gap> DigraphTopologicalSort(gr);
[ 1 ]
gap> gr := Digraph([[2], [1]]);
<digraph with 2 vertices, 2 edges>
gap> DigraphTopologicalSort(gr);
fail
gap> r := rec(nrvertices := 8,
> source := [1, 1, 1, 2, 3, 4, 4, 5, 7, 7],
> range := [4, 3, 4, 8, 2, 2, 6, 7, 4, 8]);;
gap> grid := Digraph(r);;
gap> DigraphTopologicalSort(grid);
[ 8, 2, 6, 4, 3, 1, 7, 5 ]
gap> adj := [[3], [], [2, 3, 4], []];;
gap> gr := Digraph(adj);
<digraph with 4 vertices, 4 edges>
gap> IsAcyclicDigraph(gr);
false
gap> DigraphTopologicalSort(gr);
[ 2, 4, 3, 1 ]
gap> gr := Digraph([
> [7], [], [], [6], [], [3], [], [], [5, 15], [], [],
> [6], [19], [], [11], [13], [], [17], [], [17]]);
<digraph with 20 vertices, 11 edges>
gap> DigraphTopologicalSort(gr);
[ 7, 1, 2, 3, 6, 4, 5, 8, 11, 15, 9, 10, 12, 19, 13, 14, 16, 17, 18, 20 ]
gap> gr := Digraph([[2], [], []]);
<digraph with 3 vertices, 1 edge>
gap> DigraphTopologicalSort(gr);
[ 2, 1, 3 ]

#T# DigraphStronglyConnectedComponents

# <gr> is Digraph(RightCayleyGraphSemigroup) of the gens:
# [Transformation([1, 3, 3]),
#  Transformation([2, 1, 2]),
#  Transformation([2, 2, 1])];;
gap> adj := [
> [1, 11, 11], [3, 10, 11], [3, 11, 10], [6, 9, 11], [7, 8, 11],
> [6, 11, 9], [7, 11, 8], [12, 5, 11], [13, 4, 11], [14, 2, 11],
> [15, 1, 11], [12, 11, 5], [13, 11, 4], [14, 11, 2], [15, 11, 1]];;
gap> gr := Digraph(adj);
<multidigraph with 15 vertices, 45 edges>
gap> DigraphStronglyConnectedComponents(gr);
rec( 
  comps := [ [ 1, 11, 15 ], [ 2, 3, 10, 14 ], [ 4, 6, 9, 13 ], 
      [ 5, 7, 8, 12 ] ], id := [ 1, 2, 2, 3, 4, 3, 4, 4, 3, 2, 1, 4, 3, 2, 1 
     ] )
gap> adj := [[3, 4, 5, 7, 10], [4, 5, 10], [1, 2, 4, 7], [2, 9],
> [4, 5, 8, 9], [1, 3, 4, 5, 6], [1, 2, 4, 6],
> [1, 2, 3, 4, 5, 6, 7, 9], [2, 4, 8], [4, 5, 6, 8, 11], [10]];;
gap> gr := Digraph(adj);
<digraph with 11 vertices, 44 edges>
gap> scc := DigraphStronglyConnectedComponents(gr);
rec( comps := [ [ 1, 3, 2, 4, 9, 8, 5, 6, 7, 10, 11 ] ], 
  id := [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ] )
gap> gr := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> DigraphStronglyConnectedComponents(gr);
rec( comps := [  ], id := [  ] )
gap> r := rec(nrvertices := 9,
> range := [1, 7, 6, 9, 4, 8, 2, 5, 8, 9, 3, 9, 4, 8, 1, 1, 3],
> source := [1, 1, 2, 2, 4, 4, 5, 6, 6, 6, 7, 7, 8, 8, 9, 9, 9]);;
gap> gr := Digraph(r);
<multidigraph with 9 vertices, 17 edges>
gap> scc := DigraphStronglyConnectedComponents(gr);
rec( comps := [ [ 3 ], [ 1, 7, 9 ], [ 8, 4 ], [ 2, 6, 5 ] ], 
  id := [ 2, 4, 1, 3, 4, 4, 2, 3, 2 ] )
gap> wcc := DigraphConnectedComponents(gr);
rec( comps := [ [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ] ], 
  id := [ 1, 1, 1, 1, 1, 1, 1, 1, 1 ] )
gap> scc := DigraphStronglyConnectedComponents(circuit);;
gap> Length(scc.comps);
20000
gap> Length(scc.comps) = DigraphNrVertices(circuit);
true
gap> gr := CycleDigraph(10);
<digraph with 10 vertices, 10 edges>
gap> gr2 := DigraphRemoveEdges(gr, [10]);
<digraph with 10 vertices, 9 edges>
gap> IsStronglyConnectedDigraph(gr);
true
gap> DigraphStronglyConnectedComponents(gr);
rec( comps := [ [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] ], 
  id := [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ] )
gap> IsAcyclicDigraph(gr2);
true
gap> DigraphStronglyConnectedComponents(gr2);
rec( comps := [ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], 
      [ 9 ], [ 10 ] ], id := [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] )

#T# DigraphConnectedComponents
gap> gr := Digraph([[1, 2], [1], [2], [5], []]);
<digraph with 5 vertices, 5 edges>
gap> wcc := DigraphConnectedComponents(gr);
rec( comps := [ [ 1, 2, 3 ], [ 4, 5 ] ], id := [ 1, 1, 1, 2, 2 ] )
gap> gr := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> DigraphConnectedComponents(gr);
rec( comps := [  ], id := [  ] )
gap> gr := Digraph([[]]);
<digraph with 1 vertex, 0 edges>
gap> DigraphConnectedComponents(gr);
rec( comps := [ [ 1 ] ], id := [ 1 ] )
gap> gr := Digraph([[1], [2], [3], [4]]);
<digraph with 4 vertices, 4 edges>
gap> DigraphConnectedComponents(gr);
rec( comps := [ [ 1 ], [ 2 ], [ 3 ], [ 4 ] ], id := [ 1, 2, 3, 4 ] )
gap> gr := Digraph([[3, 4, 5, 7, 8, 9], [1, 4, 5, 8, 9, 5, 10],
> [2, 4, 5, 6, 7, 10], [6], [1, 1, 1, 7, 8, 9], [2, 2, 6, 8], [1, 5, 6, 9, 10],
> [3, 4, 6, 7], [1, 2, 3, 5], [5, 7]]);
<multidigraph with 10 vertices, 45 edges>
gap> DigraphConnectedComponents(gr);
rec( comps := [ [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] ], 
  id := [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ] )
gap> gr := Digraph(rec(
> nrvertices := 100,
> source := [8, 9, 11, 11, 12, 13, 14, 14, 18, 19, 22, 27, 31, 32, 32, 34,
>             37, 40, 45, 48, 50, 52, 58, 58, 58, 59, 60, 60, 65, 66, 73,
>             75, 79, 81, 81, 83, 84, 86, 86, 89, 96, 100, 100, 100],
> range := [54, 62, 28, 55, 70, 37, 20, 32, 53, 16, 42, 66, 63, 13, 73, 89,
>            36, 5, 4, 58, 26, 48, 36, 56, 65, 78, 95, 96, 97, 60, 11, 66,
>            66, 19, 79, 21, 13, 29, 78, 98, 100, 44, 53, 69]));
<digraph with 100 vertices, 44 edges>
gap> DigraphConnectedComponents(gr);
rec( comps := [ [ 1 ], [ 2 ], [ 3 ], [ 4, 45 ], [ 5, 40 ], [ 6 ], [ 7 ], 
      [ 8, 54 ], [ 9, 62 ], [ 10 ], 
      [ 11, 13, 14, 20, 28, 32, 36, 37, 48, 52, 55, 56, 58, 65, 73, 84, 97 ], 
      [ 12, 70 ], [ 15 ], 
      [ 16, 18, 19, 27, 44, 53, 60, 66, 69, 75, 79, 81, 95, 96, 100 ], 
      [ 17 ], [ 21, 83 ], [ 22, 42 ], [ 23 ], [ 24 ], [ 25 ], [ 26, 50 ], 
      [ 29, 59, 78, 86 ], [ 30 ], [ 31, 63 ], [ 33 ], [ 34, 89, 98 ], [ 35 ], 
      [ 38 ], [ 39 ], [ 41 ], [ 43 ], [ 46 ], [ 47 ], [ 49 ], [ 51 ], [ 57 ], 
      [ 61 ], [ 64 ], [ 67 ], [ 68 ], [ 71 ], [ 72 ], [ 74 ], [ 76 ], [ 77 ], 
      [ 80 ], [ 82 ], [ 85 ], [ 87 ], [ 88 ], [ 90 ], [ 91 ], [ 92 ], [ 93 ], 
      [ 94 ], [ 99 ] ], 
  id := [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 11, 11, 13, 14, 15, 14, 14, 
      11, 16, 17, 18, 19, 20, 21, 14, 11, 22, 23, 24, 11, 25, 26, 27, 11, 11, 
      28, 29, 5, 30, 17, 31, 14, 4, 32, 33, 11, 34, 21, 35, 11, 14, 8, 11, 
      11, 36, 11, 22, 14, 37, 9, 24, 38, 11, 14, 39, 40, 14, 12, 41, 42, 11, 
      43, 14, 44, 45, 22, 14, 46, 14, 47, 16, 11, 48, 22, 49, 50, 26, 51, 52, 
      53, 54, 55, 14, 14, 11, 26, 56, 14 ] )

#T# DigraphShortestDistances
gap> adj := Concatenation(List([1 .. 11], x -> [x + 1]), [[1]]);;
gap> cycle12 := Digraph(adj);
<digraph with 12 vertices, 12 edges>
gap> mat := DigraphShortestDistances(cycle12);;
gap> Display(mat);
[ [   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11 ],
  [  11,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10 ],
  [  10,  11,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9 ],
  [   9,  10,  11,   0,   1,   2,   3,   4,   5,   6,   7,   8 ],
  [   8,   9,  10,  11,   0,   1,   2,   3,   4,   5,   6,   7 ],
  [   7,   8,   9,  10,  11,   0,   1,   2,   3,   4,   5,   6 ],
  [   6,   7,   8,   9,  10,  11,   0,   1,   2,   3,   4,   5 ],
  [   5,   6,   7,   8,   9,  10,  11,   0,   1,   2,   3,   4 ],
  [   4,   5,   6,   7,   8,   9,  10,  11,   0,   1,   2,   3 ],
  [   3,   4,   5,   6,   7,   8,   9,  10,  11,   0,   1,   2 ],
  [   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,   0,   1 ],
  [   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,   0 ] ]
gap> DigraphShortestDistances(Digraph([]));
[  ]
gap> mat := DigraphShortestDistances(Digraph([[], []]));
[ [ 0, fail ], [ fail, 0 ] ]
gap> r := rec(vertices := [1 .. 15], source := [], range := []);;
gap> for i in [1 .. 15] do
>   for j in [1 .. 15] do
>     Add(r.source, i);
>     Add(r.range, j);
>   od;
> od;
gap> complete15 := Digraph(r);
<digraph with 15 vertices, 225 edges>
gap> Display(DigraphShortestDistances(complete15));
[ [  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  0,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  0,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  0,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  0,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0 ] ]
gap> r := rec(nrvertices := 7, range := [3, 5, 5, 4, 6, 2, 5, 3, 3, 7, 2],
>  source := [1, 1, 1, 2, 2, 3, 3, 4, 5, 5, 7]);;
gap> gr := Digraph(r);
<multidigraph with 7 vertices, 11 edges>
gap> Display(DigraphShortestDistances(gr));
[ [     0,     2,     1,     3,     1,     3,     2 ],
  [  fail,     0,     2,     1,     3,     1,     4 ],
  [  fail,     1,     0,     2,     1,     2,     2 ],
  [  fail,     2,     1,     0,     2,     3,     3 ],
  [  fail,     2,     1,     3,     0,     3,     1 ],
  [  fail,  fail,  fail,  fail,  fail,     0,  fail ],
  [  fail,     1,     3,     2,     4,     2,     0 ] ]

#T# DigraphShortestDistances, using connectivity data
gap> gr := CycleDigraph(3);;
gap> DIGRAPHS_ConnectivityData(gr);
[  ]
gap> DigraphShortestDistances(gr);
[ [ 0, 1, 2 ], [ 2, 0, 1 ], [ 1, 2, 0 ] ]
gap> gr := CompleteDigraph(3);;
gap> DIGRAPH_ConnectivityDataForVertex(gr, 2);;
gap> DigraphShortestDistances(gr);
[ [ 0, 1, 1 ], [ 1, 0, 1 ], [ 1, 1, 0 ] ]

#T# OutNeighbours and InNeighbours
gap> gr := Digraph(rec(nrvertices := 10, source := [1, 1, 5, 5, 7, 10],
> range := [3, 3, 1, 10, 7, 1]));
<multidigraph with 10 vertices, 6 edges>
gap> InNeighbours(gr);
[ [ 5, 10 ], [  ], [ 1, 1 ], [  ], [  ], [  ], [ 7 ], [  ], [  ], [ 5 ] ]
gap> OutNeighbours(gr);
[ [ 3, 3 ], [  ], [  ], [  ], [ 1, 10 ], [  ], [ 7 ], [  ], [  ], [ 1 ] ]
gap> gr := Digraph([[1, 1, 4], [2, 3, 4], [2, 4, 4, 4], [2]]);
<multidigraph with 4 vertices, 11 edges>
gap> InNeighbours(gr);
[ [ 1, 1 ], [ 2, 3, 4 ], [ 2 ], [ 1, 2, 3, 3, 3 ] ]
gap> OutNeighbours(gr);
[ [ 1, 1, 4 ], [ 2, 3, 4 ], [ 2, 4, 4, 4 ], [ 2 ] ]

#T# OutDegree and OutDegreeSequence and InDegrees and InDegreeSequence
gap> r := rec(nrvertices := 0, source := [], range := []);;
gap> gr1 := Digraph(r);
<digraph with 0 vertices, 0 edges>
gap> OutDegrees(gr1);
[  ]
gap> OutDegreeSequence(gr1);
[  ]
gap> InDegrees(gr1);
[  ]
gap> InDegreeSequence(gr1);
[  ]
gap> gr2 := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> OutDegrees(gr2);
[  ]
gap> OutDegreeSequence(gr2);
[  ]
gap> InDegrees(gr2);
[  ]
gap> InDegreeSequence(gr2);
[  ]
gap> gr3 := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> InNeighbours(gr3);
[  ]
gap> OutDegrees(gr3);
[  ]
gap> OutDegreeSequence(gr3);
[  ]
gap> InDegrees(gr3);
[  ]
gap> InDegreeSequence(gr3);
[  ]
gap> adj := [
> [6, 7, 1], [1, 3, 3, 6], [5], [1, 4, 4, 4, 8], [1, 3, 4, 6, 7],
> [7, 7], [1, 4, 5, 6, 5, 7], [5, 6]];;
gap> gr1 := Digraph(adj);
<multidigraph with 8 vertices, 28 edges>
gap> OutDegrees(gr1);
[ 3, 4, 1, 5, 5, 2, 6, 2 ]
gap> OutDegreeSequence(gr1);
[ 6, 5, 5, 4, 3, 2, 2, 1 ]
gap> InDegrees(gr1);
[ 5, 0, 3, 5, 4, 5, 5, 1 ]
gap> InDegreeSequence(gr1);
[ 5, 5, 5, 5, 4, 3, 1, 0 ]
gap> gr2 := Digraph(adj);
<multidigraph with 8 vertices, 28 edges>
gap> InNeighbours(gr2);;
gap> InDegrees(gr2);
[ 5, 0, 3, 5, 4, 5, 5, 1 ]
gap> InDegreeSequence(gr2);
[ 5, 5, 5, 5, 4, 3, 1, 0 ]
gap> r := rec(nrvertices := 8,
> source := [1, 1, 1, 2, 2, 2, 2, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6, 7, 7,
>             7, 7, 7, 7, 8, 8],
> range := [6, 7, 1, 1, 3, 3, 6, 5, 1, 4, 4, 4, 8, 1, 3, 4, 6, 7, 7, 7, 1, 4,
>            5, 6, 5, 7, 5, 6]);;
gap> gr3 := Digraph(r);
<multidigraph with 8 vertices, 28 edges>
gap> OutDegrees(gr3);
[ 3, 4, 1, 5, 5, 2, 6, 2 ]
gap> OutDegreeSequence(gr3);
[ 6, 5, 5, 4, 3, 2, 2, 1 ]
gap> InDegrees(gr3);
[ 5, 0, 3, 5, 4, 5, 5, 1 ]
gap> InDegreeSequence(gr3);
[ 5, 5, 5, 5, 4, 3, 1, 0 ]
gap> OutDegrees(EmptyDigraph(5));
[ 0, 0, 0, 0, 0 ]
gap> InDegrees(EmptyDigraph(5));
[ 0, 0, 0, 0, 0 ]
gap> gr := EmptyDigraph(5);; OutNeighbours(gr);;
gap> OutDegrees(gr);
[ 0, 0, 0, 0, 0 ]
gap> gr := EmptyDigraph(5);; OutNeighbours(gr);;
gap> InDegrees(gr);
[ 0, 0, 0, 0, 0 ]

#T# DigraphEdges
gap> r := rec(
> nrvertices := 5,
> source := [1, 1, 2, 3, 5, 5],
> range := [1, 4, 3, 5, 2, 2]);
rec( nrvertices := 5, range := [ 1, 4, 3, 5, 2, 2 ], 
  source := [ 1, 1, 2, 3, 5, 5 ] )
gap> gr := Digraph(r);
<multidigraph with 5 vertices, 6 edges>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 4 ], [ 2, 3 ], [ 3, 5 ], [ 5, 2 ], [ 5, 2 ] ]
gap> gr := Digraph([[4], [2, 3, 1, 3], [3, 3], [], [1, 4, 5]]);
<multidigraph with 5 vertices, 10 edges>
gap> DigraphEdges(gr);
[ [ 1, 4 ], [ 2, 2 ], [ 2, 3 ], [ 2, 1 ], [ 2, 3 ], [ 3, 3 ], [ 3, 3 ], 
  [ 5, 1 ], [ 5, 4 ], [ 5, 5 ] ]
gap> gr := Digraph([[1, 2, 3, 5, 6, 8], [6, 6, 7, 8], [1, 2, 3, 4, 6, 7],
> [2, 3, 5, 6, 2, 7], [5, 6, 5, 5], [3, 2, 8], [1, 5, 7], [6, 7]]);
<multidigraph with 8 vertices, 34 edges>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ], [ 1, 5 ], [ 1, 6 ], [ 1, 8 ], [ 2, 6 ], 
  [ 2, 6 ], [ 2, 7 ], [ 2, 8 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ], [ 3, 4 ], 
  [ 3, 6 ], [ 3, 7 ], [ 4, 2 ], [ 4, 3 ], [ 4, 5 ], [ 4, 6 ], [ 4, 2 ], 
  [ 4, 7 ], [ 5, 5 ], [ 5, 6 ], [ 5, 5 ], [ 5, 5 ], [ 6, 3 ], [ 6, 2 ], 
  [ 6, 8 ], [ 7, 1 ], [ 7, 5 ], [ 7, 7 ], [ 8, 6 ], [ 8, 7 ] ]

#T# DigraphSources and DigraphSinks
gap> r := rec(nrvertices := 10,
> source := [2, 2, 3, 3, 3, 5, 7, 7, 7, 7, 9, 9, 9, 9, 9],
> range  := [2, 2, 6, 8, 2, 4, 2, 6, 8, 6, 8, 5, 8, 2, 4]);;
gap> gr := Digraph(r);
<multidigraph with 10 vertices, 15 edges>
gap> DigraphSinks(gr);
[ 1, 4, 6, 8, 10 ]
gap> DigraphSources(gr);
[ 1, 3, 7, 9, 10 ]
gap> gr := Digraph(OutNeighbours(gr));;
gap> DigraphSinks(gr);
[ 1, 4, 6, 8, 10 ]
gap> DigraphSources(gr);
[ 1, 3, 7, 9, 10 ]
gap> gr := Digraph(r);;
gap> InNeighbours(gr);
[ [  ], [ 2, 2, 3, 7, 9 ], [  ], [ 5, 9 ], [ 9 ], [ 3, 7, 7 ], [  ], 
  [ 3, 7, 9, 9 ], [  ], [  ] ]
gap> DigraphSinks(gr);
[ 1, 4, 6, 8, 10 ]
gap> DigraphSources(gr);
[ 1, 3, 7, 9, 10 ]
gap> gr := Digraph(r);;
gap> OutDegrees(gr);
[ 0, 2, 3, 0, 1, 0, 4, 0, 5, 0 ]
gap> InDegrees(gr);
[ 0, 5, 0, 2, 1, 3, 0, 4, 0, 0 ]
gap> DigraphSinks(gr);
[ 1, 4, 6, 8, 10 ]
gap> DigraphSources(gr);
[ 1, 3, 7, 9, 10 ]

#T# DigraphPeriod
gap> gr := EmptyDigraph(100);
<digraph with 100 vertices, 0 edges>
gap> DigraphPeriod(gr);
0
gap> gr := CompleteDigraph(100);
<digraph with 100 vertices, 9900 edges>
gap> DigraphPeriod(gr);
1
gap> gr := Digraph([[2, 2], [3], [4], [1]]);
<multidigraph with 4 vertices, 5 edges>
gap> DigraphPeriod(gr);
4
gap> gr := Digraph([[2], [3], [4], []]);
<digraph with 4 vertices, 3 edges>
gap> HasIsAcyclicDigraph(gr);
false
gap> DigraphPeriod(gr);
0
gap> HasIsAcyclicDigraph(gr);
true
gap> IsAcyclicDigraph(gr);
true
gap> gr := Digraph([[2], [3], [4], []]);
<digraph with 4 vertices, 3 edges>
gap> IsAcyclicDigraph(gr);
true
gap> DigraphPeriod(gr);
0

#T# DigraphDiameter 1
gap> gr := Digraph([[2], []]);;
gap> DigraphDiameter(gr);
fail
gap> gr := Digraph([[2], [3], [4, 5], [5], [1]]);;
gap> DigraphDiameter(gr);
4
gap> gr := Digraph([[1, 2], [1]]);;
gap> DigraphDiameter(gr);
1
gap> gr := Digraph([[2], [3], []]);;
gap> IsStronglyConnectedDigraph(gr);
false
gap> DigraphDiameter(gr);
fail
gap> gr := Digraph([[1]]);;
gap> DigraphDiameter(gr);
0
gap> gr := EmptyDigraph(0);;
gap> DigraphDiameter(gr);
fail
gap> gr := EmptyDigraph(1);;
gap> DigraphDiameter(gr);
0

#T# DigraphDiameter 2
# For a digraph (not strongly connected) with too many vertices for
# Floyd-Warshall
gap> str := Concatenation(
> ".~?Ng_k?QDoFG]?MaO?IHoBwu?`cGBQPGAXD_Ic]AaKO^xO`\\dMD}VGYwcq}DTKWSsq?mrRAP",
> "BmZ?]HlAACzLoWSv_ur`EvMSE[y@VrIfWAU]GkH{AlgAEU_W?yBbBg[FqaGUII?kguBW^{xiO?G",
> "hOGIdOP`SsmHBR?OdL`SCDGhRgLLNPfs~AJSWYh@hHtICFSoHlR`KTQ@aREU{hxZr|_^B}kW}Yt",
> "?jeLGam?Fix`mcvVgW`Zy}Axj}Dub[}ZAD]c}VIp@HxeuOEOMmqOFyDuTDxX[aDfpAsEd@YSO\\",
> "kQUpSloModdnANU~H\\[cXpkxEVN@X\\GcdNjkCMH~]?^DYJpf^nMHq|Gzw]F^nW?YVP@XTBLHy",
> "Sa}X[GrVu?X^kLT~OerEoCDqD_aKBAlIt_cp[bkEaVMhQFA?qJITjogWqVuDokD|oyIMExukP?w",
> "bEPjCqEWvclpQKOlTB[UcTp__A~S^zepSpkLAFDS[\\Gcbq[vGGd{aCldib^HAPKdGHqWWjI?oB",
> "exQHZdWdp^{_Qdq@dkCkUWVVed^XJKXviPXLR@diWXAj_f[rUdYTPTxtQHKPOJMGCPCxwNjfkoq",
> "]kVVNrng?RUYHju^mO^IWHO[GQUsQE[bdOXSpwDmWMz\\i|GCKORhKhedO[eqsmfNRGUlLiQ_{B",
> "fB{X|PA{_@BjTGOpRYjPrGNTq]lW@SPVjG|}lOMyvITjkyAchhs@u?SYx]oqtZDLFDrX@NGDzJB",
> "jbvXySCvs^Ja`BYof|kfF`mGe[hErQiGTB?Ul{R|oH|vEES}YO[IVDqxm_D`]|tcVvY`V]Our@p",
> "oJN^b]p]ScTcp_gNEe~STsYkrP`SYvlB[CVnN\\^U`mDEpoLotIaYmFhFwag~aypmL@qD]RJbgp",
> "GbpgLXqChFGsCQ\\Nip~cpA}SdzKlqkQYy]UaeTxK[jyeTN{pOnEkhS[pUcJTZ\\hOUGxJwAVt`",
> "N?vMpES^_Q]W|U@]_DlOAargON`GjYoznEXxj]bjc`OcbhQAijF_X|dQLZNU_\\N?y\\d_FSOw|",
> "RXjAOwJKMjCbyoqncnUq[rbyluH`Sce`|dGDSrl@d\\jkajvJhH\\?T}o{z_D{uF[q^hZzi?VWl",
> "iYMUBQBIo^f^@ASqLCZQNq`~?F?pfwKyiU^B?XLUjuN^aPthhuphrpixd}]N@MSmm@xKo]SIMuF",
> "rGXIr}\\EYMN]Fg@AYM|E^vso~RhmDyJQAOX`}o}kDJz@AIXI\\e}PdHPMSq^ZgJXnzcfSbUwqL",
> "F~zt?^nseWoeFJQh]Dnbiv}U\\HWLrlt^NItYU{Yjhhiy\\^qZyo\\i~i\\cALjzWXMyqBOwnfz",
> "yUNpna`p}WZVK~sOP?H@c@kKoGpJAFCwAc@Gg`HbOBiM_?X?`PafBUPO^hHaOck?iSWNhGqeDBI",
> "kMKj`CquBzJ_U{bH_AgeMAMXOUXe@ke[EKM{s?g@qe}HA[W]HVrh?vM{Us{PgP}fm?]FC~?D_P`",
> "zOCZt?p{sF@EKA`OrPpbyg[KMaGGyH_ogiG{ULE_Os\\E^QGDlHpCCN`eC?QSaYT`jbHQwZhFyO",
> "S@hgEuf?VY^aqiK@O\\KwYdA@iWQ?d[Zw_tV?RTgLTW?sTbDQPUkh?ys`kjUB?iTZPGoGC`VGhD",
> "\\pksljyByopGHzOVkWF[YLboeUPFCNeHtd@Ip[koHYo\\gPQUbDvYWik{zFUkHNYw[DkPTbjlm",
> "UaI\\nALvCAWUEx?qzd@MBjQYGDsAnvSD~T]yx_zlE?m}@u{HXIMVkH|LM}O?_LVsEuM?[k~zzb",
> "sfYNe~PoZ}epn}ZGwsXaHWDC\\__]pu{CwKKDBWFEBoQByocL^A`_r^wWEEVMCeEowW]GBa?WtQ",
> "Jus?kHM^Cx@kSgFpUOrE@_iXwrP@bTBEMQ[DHpuPCzsW[^AcGe_fGAL{aaoGQ^zHQDkeC`dPIRI",
> "?~cDxWGPdgQUV_acjJj?UAwPKpBAJdEAThMBPF}rKRCkEY?_B@rUNhBeZRVxqI{VjM`QkLoTroD",
> "Kv]]aPEFsCbyDWfXCh]sMEFPP~iKDKsYLX@{mjcYPC|hlJufqOqGKhiSu]iCCykKxj?^CDLYHxt",
> "oUjVXz\\]`Ht}@OUUoRFoAAeLeN_f\\a`Og{XnXPqsKyzspk{gDILhEmqrl\\YMuPDRJS^Y|PEv",
> "S~uDvATYWdr\\UW~vMKw\\}hltFLv[Hc^`gLwDLrp\\hZM|PYbQa]PakE}R|gYvukN[v?bXvDwM",
> "[IUnBP\\pjV|^uIX}mHinwiXt[^DqS{YBAFzb`]mNDEetTu|nGr]G~xONpRNJTzznttBozPzMXA",
> "?`QTPUbJW~[uO^VASUqTsK_wvrsptNhEdcyCR?skjP~eFyIDIoUQwGxi_zOtavRPqqjOhgR_RAY",
> "v|RJ[dripPXn|XFXY^@y_mmg{z?L?biatW\\cNrClQnXtqWfYBSiEE}mufCz]AsGv[QUDY`GS^?",
> "yswWQOzoAWWU?SsRbzwJDW~^qDv?{CZl@L{ge]EUCvUFc{ABDCNG]VpWWCEPLObx@F|nhMuQ`En",
> "zrGWcfubY^STJVft{lYsHxV?|ERyp|OhyXckj|gmJbxykH?fAddpSmp}Nvjc[pCc^POcVkr^}tQ",
> "Rz`W~nsXUbTMwIcNpD@r]n`{_APJKFiU}UO|gJ[ZhJXj}stivsAumX}e?MAPhcZkZfYQgqx|[l^",
> "WGOsZDfHNmBwze{E~aj~oF~~Ch`^Nx`K^");;
gap> gr := DigraphFromDiSparse6String(str);
<digraph with 1000 vertices, 1053 edges>
gap> DigraphDiameter(gr);
fail

#T# DigraphSymmetricClosure
gap> gr1 := Digraph([[2], [1]]);
<digraph with 2 vertices, 2 edges>
gap> IsSymmetricDigraph(gr1);
true
gap> gr2 := DigraphSymmetricClosure(gr1);
<digraph with 2 vertices, 2 edges>
gap> IsIdenticalObj(gr1, gr2);
false
gap> gr1 = gr2;
true
gap> gr1 := Digraph([[1, 1, 1, 1]]);
<multidigraph with 1 vertex, 4 edges>
gap> gr2 := DigraphSymmetricClosure(gr1);
<multidigraph with 1 vertex, 4 edges>
gap> IsIdenticalObj(gr1, gr2);
false
gap> gr1 = gr2;
true
gap> gr1 := Digraph(
> [[], [4, 5], [12], [3], [2, 10, 11, 12], [2, 8, 10, 12], [5],
> [11, 12], [12], [12], [2, 6, 7, 8], [3, 8, 10]]);
<digraph with 12 vertices, 24 edges>
gap> IsSymmetricDigraph(gr1);
false
gap> gr2 := DigraphSymmetricClosure(gr1);
<digraph with 12 vertices, 38 edges>
gap> HasIsSymmetricDigraph(gr2);
true
gap> IsSymmetricDigraph(gr2);
true
gap> gr3 := Digraph(
> [[], [4, 5, 11, 6], [4, 12], [2, 3], [2, 10, 11, 12, 7],
> [8, 10, 12, 2, 11], [5, 11], [11, 12, 6], [12], [5, 6, 12],
> [7, 6, 2, 5, 8], [10, 5, 3, 8, 6, 9]]);;
gap> gr2 = gr3;
true

#T# Digraph(Reflexive)TransitiveClosure
gap> gr := Digraph(rec(nrvertices := 2, source := [1, 1], range := [2, 2]));
<multidigraph with 2 vertices, 2 edges>
gap> DigraphReflexiveTransitiveClosure(gr);
Error, Digraphs: DigraphReflexiveTransitiveClosure: usage,
the argument <graph> cannot have multiple edges,
gap> DigraphTransitiveClosure(gr);
Error, Digraphs: DigraphTransitiveClosure: usage,
the argument <graph> cannot have multiple edges,
gap> r := rec(vertices := [1 .. 4], source := [1, 1, 2, 3, 4],
> range := [1, 2, 3, 4, 1]);;
gap> gr := Digraph(r);
<digraph with 4 vertices, 5 edges>
gap> IsAcyclicDigraph(gr);
false
gap> DigraphTopologicalSort(gr);
fail
gap> gr1 := DigraphTransitiveClosure(gr);
<digraph with 4 vertices, 16 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr);
<digraph with 4 vertices, 16 edges>
gap> gr1 = gr2;
true
gap> adj := [[2, 6], [3], [7], [3], [], [2, 7], [5]];;
gap> gr := Digraph(adj);
<digraph with 7 vertices, 8 edges>
gap> IsAcyclicDigraph(gr);
true
gap> gr1 := DigraphTransitiveClosure(gr);
<digraph with 7 vertices, 18 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr);
<digraph with 7 vertices, 25 edges>
gap> gr := Digraph([[2], [3], [4], [3]]);
<digraph with 4 vertices, 4 edges>
gap> gr1 := DigraphTransitiveClosure(gr);
<digraph with 4 vertices, 9 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr);
<digraph with 4 vertices, 11 edges>
gap> gr := Digraph([[2], [3], [4, 5], [], [5]]);
<digraph with 5 vertices, 5 edges>
gap> gr1 := DigraphTransitiveClosure(gr);
<digraph with 5 vertices, 10 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr);
<digraph with 5 vertices, 14 edges>
gap> gr := Digraph(
> [[1, 4, 5, 6, 7, 8], [5, 7, 8, 9, 10, 13], [2, 4, 6, 10],
>  [7, 9, 10, 11], [7, 9, 10, 12, 13, 15], [7, 8, 10, 13], [10, 11],
>  [7, 10, 12, 13, 14, 15, 16], [7, 10, 11, 14, 16], [11], [11],
>  [7, 13, 14], [10, 11], [7, 10, 11], [7, 13, 16], [7, 10, 11]]);
<digraph with 16 vertices, 60 edges>
gap> trans1 := DigraphTransitiveClosure(gr);
<digraph with 16 vertices, 98 edges>
gap> trans2 := DigraphByAdjacencyMatrix(DIGRAPH_TRANS_CLOSURE(gr));
<digraph with 16 vertices, 98 edges>
gap> trans1 = trans2;
true
gap> trans := Digraph(OutNeighbours(trans1));
<digraph with 16 vertices, 98 edges>
gap> IsReflexiveDigraph(trans);
false
gap> IsTransitiveDigraph(trans);
true
gap> IS_TRANSITIVE_DIGRAPH(trans);
true
gap> reflextrans1 := DigraphReflexiveTransitiveClosure(gr);
<digraph with 16 vertices, 112 edges>
gap> reflextrans2 :=
> DigraphByAdjacencyMatrix(DIGRAPH_REFLEX_TRANS_CLOSURE(gr));
<digraph with 16 vertices, 112 edges>
gap> reflextrans1 = reflextrans2;
true
gap> reflextrans := Digraph(OutNeighbours(reflextrans1));
<digraph with 16 vertices, 112 edges>
gap> IsReflexiveDigraph(reflextrans);
true
gap> IsTransitiveDigraph(reflextrans);
true
gap> IS_TRANSITIVE_DIGRAPH(reflextrans);
true

#T# ReducedDigraph
gap> gr := EmptyDigraph(0);;
gap> ReducedDigraph(gr) = gr;
true
gap> gr := Digraph([[2, 4, 2, 6, 1], [], [], [2, 1, 4], [],
> [1, 7, 7, 7], [4, 6]]);
<multidigraph with 7 vertices, 14 edges>
gap> rd := ReducedDigraph(gr);
<multidigraph with 5 vertices, 14 edges>
gap> DigraphVertexLabels(rd);
[ 1, 2, 4, 6, 7 ]
gap> gr := CompleteDigraph(10);
<digraph with 10 vertices, 90 edges>
gap> rd := ReducedDigraph(gr);
<digraph with 10 vertices, 90 edges>
gap> rd = gr;
true
gap> DigraphVertexLabels(gr) = DigraphVertexLabels(rd);
true
gap> gr := Digraph([[], [4, 2], [], [3]]);
<digraph with 4 vertices, 3 edges>
gap> SetDigraphVertexLabels(gr, ["one", "two", "three", "four"]);
gap> rd := ReducedDigraph(gr);
<digraph with 3 vertices, 3 edges>
gap> DigraphVertexLabels(gr);
[ "one", "two", "three", "four" ]
gap> DigraphVertexLabels(rd);
[ "two", "three", "four" ]
gap> gr := Digraph([[], [4, 2], [], [3]]);
<digraph with 4 vertices, 3 edges>
gap> SetDigraphEdgeLabels(gr, [[], ["a", "b"], [], ["c"]]);
gap> rd := ReducedDigraph(gr);
<digraph with 3 vertices, 3 edges>
gap> DigraphEdgeLabels(gr);
[ [  ], [ "a", "b" ], [  ], [ "c" ] ]
gap> DigraphEdgeLabels(rd);
[ [ "a", "b" ], [  ], [ "c" ] ]

#T# DigraphAllSimpleCircuits
gap> gr := Digraph([]);;
gap> DigraphAllSimpleCircuits(gr);
[  ]
gap> gr := ChainDigraph(4);;
gap> DigraphAllSimpleCircuits(gr);
[  ]
gap> gr := CompleteDigraph(2);;
gap> DigraphAllSimpleCircuits(gr);
[ [ 1, 2 ] ]
gap> gr := CompleteDigraph(3);;
gap> DigraphAllSimpleCircuits(gr);
[ [ 1, 2 ], [ 1, 2, 3 ], [ 1, 3 ], [ 1, 3, 2 ], [ 2, 3 ] ]
gap> gr := Digraph(["a", "b"], ["a", "b"], ["b", "a"]);
<digraph with 2 vertices, 2 edges>
gap> DigraphAllSimpleCircuits(gr);
[ [ 1, 2 ] ]
gap> gr := Digraph([[], [3], [2, 4], [5, 4], [4]]);
<digraph with 5 vertices, 6 edges>
gap> DigraphAllSimpleCircuits(gr);
[ [ 4 ], [ 4, 5 ], [ 2, 3 ] ]
gap> gr := Digraph([[], [], [], [4], [], [], [8], [7]]);
<digraph with 8 vertices, 3 edges>
gap> DigraphAllSimpleCircuits(gr);
[ [ 4 ], [ 7, 8 ] ]
gap> gr := Digraph([[1, 2], [2, 1]]);
<digraph with 2 vertices, 4 edges>
gap> DigraphAllSimpleCircuits(gr);
[ [ 1 ], [ 2 ], [ 1, 2 ] ]
gap> gr := Digraph([[4], [1, 3], [1, 2], [2, 3]]);;
gap> DigraphAllSimpleCircuits(gr);
[ [ 1, 4, 2 ], [ 1, 4, 2, 3 ], [ 1, 4, 3 ], [ 1, 4, 3, 2 ], [ 2, 3 ] ]
gap> gr := Digraph([[3, 6, 7], [3, 6, 8], [1, 2, 3, 6, 7, 8],
> [2, 3, 4, 8], [2, 3, 4, 5, 6, 7], [1, 3, 4, 5, 7], [2, 3, 6, 8],
> [1, 2, 3, 8]]);;
gap> Length(DigraphAllSimpleCircuits(gr));
259

#T# DigraphLongestSimpleCircuit
gap> gr := Digraph([]);;
gap> DigraphLongestSimpleCircuit(gr);
fail
gap> gr := Digraph([[], [2]]);;
gap> DigraphLongestSimpleCircuit(gr);
[ 2 ]
gap> gr := Digraph([[], [3], [2, 4], [5, 4], [4]]);;
gap> DigraphLongestSimpleCircuit(gr);
[ 4, 5 ]
gap> gr := ChainDigraph(10);;
gap> DigraphLongestSimpleCircuit(gr);
fail
gap> gr := Digraph([[3], [1], [1, 4], [1, 1]]);;
gap> DigraphLongestSimpleCircuit(gr);
[ 1, 3, 4 ]
gap> gr := Digraph([[2, 6, 10], [3], [4], [5], [1],
>                   [7], [8], [9], [1], [11], [12], [13], [1]]);;
gap> DigraphLongestSimpleCircuit(gr);
[ 1, 2, 3, 4, 5 ]
gap> gr := Digraph([[2, 6, 10], [3], [4], [5], [1],
>                   [7], [8], [9], [1], [11], [12], [1, 13], [14], [1]]);;
gap> DigraphLongestSimpleCircuit(gr);
[ 1, 10, 11, 12, 13, 14 ]

#T# AsTransformation
gap> gr := Digraph([[2], [1, 3], [4], [3]]);;
gap> AsTransformation(gr);
fail
gap> gr := AsDigraph(Transformation([1, 1, 1]), 5);
<digraph with 5 vertices, 5 edges>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 2, 1 ], [ 3, 1 ], [ 4, 4 ], [ 5, 5 ] ]
gap> AsTransformation(gr);
Transformation( [ 1, 1, 1 ] )

#T# DigraphBicomponents
gap> DigraphBicomponents(EmptyDigraph(0));
fail
gap> DigraphBicomponents(EmptyDigraph(1));
fail
gap> DigraphBicomponents(EmptyDigraph(2));
[ [ 1 ], [ 2 ] ]
gap> DigraphBicomponents(EmptyDigraph(3));
[ [ 1, 2 ], [ 3 ] ]
gap> DigraphBicomponents(EmptyDigraph(4));
[ [ 1, 2, 3 ], [ 4 ] ]
gap> DigraphBicomponents(CompleteBipartiteDigraph(3, 5));
[ [ 1, 2, 3 ], [ 4, 5, 6, 7, 8 ] ]
gap> DigraphBicomponents(Digraph([[2], [], [], [3]]));
[ [ 1, 3 ], [ 2, 4 ] ]
gap> DigraphBicomponents(CycleDigraph(3));
fail

#T# DigraphLoops
gap> gr := ChainDigraph(4);;
gap> DigraphHasLoops(gr);
false
gap> DigraphLoops(gr);
[  ]
gap> gr := Digraph([[2], [1]]);;
gap> DigraphLoops(gr);
[  ]
gap> gr := Digraph([[1, 5, 6], [1, 3, 4, 5, 6], [1, 3, 4], [2, 4, 6], [2],
> [1, 4, 5]]);
<digraph with 6 vertices, 18 edges>
gap> DigraphLoops(gr);
[ 1, 3, 4 ]

#T# Out/InDegreeSequence with known automorphsims and sets
gap> gr := Digraph([[2, 3, 4, 5], [], [], [], []]);;
gap> OutDegrees(gr);
[ 4, 0, 0, 0, 0 ]
gap> InDegrees(gr);
[ 0, 1, 1, 1, 1 ]
gap> InDegreeSet(gr);
[ 0, 1 ]
gap> OutDegrees(gr);
[ 4, 0, 0, 0, 0 ]
gap> OutDegreeSet(gr);
[ 0, 4 ]
gap> gr := Digraph([[2, 3, 4, 5], [], [], [], []]);;
gap> InNeighbours(gr);;
gap> DigraphGroup(gr);
Group([ (4,5), (3,4), (2,3) ])
gap> InDegreeSequence(gr);
[ 1, 1, 1, 1, 0 ]
gap> gr := DigraphSymmetricClosure(ChainDigraph(4));;
gap> DigraphGroup(gr);
Group([ (1,4)(2,3) ])
gap> HasDigraphGroup(gr);
true
gap> OutDegreeSequence(gr);
[ 2, 2, 1, 1 ]

#T# Diameter and UndirectedGirth with known automorphisms
gap> gr := Digraph([[2, 3, 4, 5], [], [], [], []]);;
gap> DigraphGroup(gr);
Group([ (4,5), (3,4), (2,3) ])
gap> DigraphDiameter(gr);
fail
gap> gr := Digraph([[2, 3, 4, 5], [6], [6], [6], [6], [1]]);;
gap> DigraphGroup(gr);
Group([ (4,5), (3,4), (2,3) ])
gap> DigraphDiameter(gr);
3
gap> gr := DigraphSymmetricClosure(CycleDigraph(7));;
gap> DigraphUndirectedGirth(gr);
7
gap> DigraphDiameter(gr);
3
gap> DigraphGroup(gr) = DihedralGroup(IsPermGroup, 14);
true
gap> gr := DigraphSymmetricClosure(CycleDigraph(7));;
gap> DigraphDiameter(gr);
3
gap> DigraphUndirectedGirth(gr);
7
gap> DigraphGroup(gr) = DihedralGroup(IsPermGroup, 14);
true
gap> gr := Digraph([[], [3], [2]]);;
gap> DigraphUndirectedGirth(gr);
infinity
gap> DigraphDiameter(gr);
fail
gap> gr := Digraph([[2, 4], [1, 3], [2, 3], [1, 5], [4, 5]]);;
gap> DigraphGroup(gr);
Group([ (2,4)(3,5) ])
gap> DigraphDiameter(gr);
4
gap> DigraphUndirectedGirth(gr);
1
gap> gr := Digraph([[2, 2, 4, 4], [1, 1, 3], [2], [1, 1, 5], [4]]);
<multidigraph with 5 vertices, 12 edges>
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

#T# DigraphBooleanAdjacencyMatrix
gap> gr := CompleteDigraph(4);;
gap> mat := BooleanAdjacencyMatrix(gr);
[ [ false, true, true, true ], [ true, false, true, true ], 
  [ true, true, false, true ], [ true, true, true, false ] ]
gap> IsSymmetricDigraph(gr) and mat = TransposedMat(mat);
true
gap> gr := EmptyDigraph(5);;
gap> mat := BooleanAdjacencyMatrix(gr);
[ [ false, false, false, false, false ], [ false, false, false, false, false ]
    , [ false, false, false, false, false ], 
  [ false, false, false, false, false ], 
  [ false, false, false, false, false ] ]
gap> IsSymmetricDigraph(gr) and mat = TransposedMat(mat);
true
gap> gr := CycleDigraph(4);;
gap> mat := BooleanAdjacencyMatrix(gr);
[ [ false, true, false, false ], [ false, false, true, false ], 
  [ false, false, false, true ], [ true, false, false, false ] ]
gap> not (IsSymmetricDigraph(gr) or mat = TransposedMat(mat));
true
gap> gr := ChainDigraph(4);;
gap> mat := BooleanAdjacencyMatrix(gr);
[ [ false, true, false, false ], [ false, false, true, false ], 
  [ false, false, false, true ], [ false, false, false, false ] ]
gap> not (IsSymmetricDigraph(gr) or mat = TransposedMat(mat));
true
gap> gr := Digraph([
> [1, 4, 6, 8], [2, 8, 10], [4], [1, 6], [6, 7], [1, 2, 4, 10],
> [3], [3], [1, 8], [2, 5]]);;
gap> mat := BooleanAdjacencyMatrix(gr);
[ [ true, false, false, true, false, true, false, true, false, false ], 
  [ false, true, false, false, false, false, false, true, false, true ], 
  [ false, false, false, true, false, false, false, false, false, false ], 
  [ true, false, false, false, false, true, false, false, false, false ], 
  [ false, false, false, false, false, true, true, false, false, false ], 
  [ true, true, false, true, false, false, false, false, false, true ], 
  [ false, false, true, false, false, false, false, false, false, false ], 
  [ false, false, true, false, false, false, false, false, false, false ], 
  [ true, false, false, false, false, false, false, true, false, false ], 
  [ false, true, false, false, true, false, false, false, false, false ] ]
gap> gr = DigraphByAdjacencyMatrix(mat);
true

#T# DigraphUndirectedGirth: easy cases
gap> gr := Digraph([[2], [3], []]);;
gap> DigraphUndirectedGirth(gr);
Error, Digraphs: DigraphUndirectedGirth: usage,
<digraph> must be a symmetric digraph,
gap> gr := Digraph([[2], [1, 3], [2, 3]]);;
gap> DigraphUndirectedGirth(gr);
1
gap> gr := Digraph([[2, 2], [1, 1, 3], [2]]);;
gap> DigraphUndirectedGirth(gr);
2

#T# DigraphGirth
gap> gr := Digraph([[1], [1]]);
<digraph with 2 vertices, 2 edges>
gap> DigraphGirth(gr);
1
gap> gr := Digraph([[2, 3], [3], [4], []]);
<digraph with 4 vertices, 4 edges>
gap> DigraphGirth(gr);
infinity
gap> gr := Digraph([[2, 3], [3], [4], [1]]);
<digraph with 4 vertices, 5 edges>
gap> DigraphGirth(gr);
3
gap> gr := EmptyDigraph(42);;
gap> DigraphGirth(gr);
infinity
gap> gr := EmptyDigraph(0);;
gap> DigraphGirth(gr);
infinity
gap> gr := Digraph([[2], [1]]);;
gap> DigraphGirth(gr);
2
gap> DigraphUndirectedGirth(gr);
infinity
gap> gr := Digraph([[2], [1], [4], [5, 6], [], []]);;
gap> DigraphGirth(gr);
2
gap> DigraphUndirectedGirth(gr);
Error, Digraphs: DigraphUndirectedGirth: usage,
<digraph> must be a symmetric digraph,

#T# DigraphDegeneracy and DigraphDegeneracyOrdering
gap> gr := Digraph([[2, 2], [1, 1]]);;
gap> IsMultiDigraph(gr) and IsSymmetricDigraph(gr);
true
gap> DigraphDegeneracy(gr);
Error, Digraphs: DigraphDegeneracy: usage,
the argument <gr> must be a symmetric digraph without multiple edges,
gap> DigraphDegeneracyOrdering(gr);
Error, Digraphs: DigraphDegeneracyOrdering: usage,
the argument <gr> must be a symmetric digraph without multiple edges,
gap> gr := Digraph([[2], []]);
<digraph with 2 vertices, 1 edge>
gap> not IsMultiDigraph(gr) and not IsSymmetricDigraph(gr);
true
gap> DigraphDegeneracy(gr);
Error, Digraphs: DigraphDegeneracy: usage,
the argument <gr> must be a symmetric digraph without multiple edges,
gap> DigraphDegeneracyOrdering(gr);
Error, Digraphs: DigraphDegeneracyOrdering: usage,
the argument <gr> must be a symmetric digraph without multiple edges,
gap> gr := CompleteDigraph(5);;
gap> DigraphDegeneracy(gr);
4
gap> DigraphDegeneracyOrdering(gr);
[ 5, 4, 3, 2, 1 ]
gap> gr := DigraphSymmetricClosure(ChainDigraph(4));
<digraph with 4 vertices, 6 edges>
gap> DigraphDegeneracy(gr);
1
gap> DigraphDegeneracyOrdering(gr);
[ 4, 3, 2, 1 ]
gap> gr := Digraph([[3], [], [1]]);
<digraph with 3 vertices, 2 edges>
gap> DigraphDegeneracy(gr);
1
gap> gr := DigraphSymmetricClosure(Digraph(
> [[2, 5], [3, 5], [4], [5, 6], [], []]));
<digraph with 6 vertices, 14 edges>
gap> DigraphDegeneracy(gr);
2
gap> DigraphDegeneracyOrdering(gr);
[ 6, 4, 3, 2, 5, 1 ]

#T# DigraphGirth with known automorphisms
gap> gr := Digraph([[2, 3, 4, 5], [6, 3], [6, 2], [6], [6], [1]]);;
gap> DigraphGirth(gr);
2
gap> gr := Digraph([[2, 3, 4, 5], [6, 3], [6, 2], [6], [6], [1]]);;
gap> DigraphGroup(gr);
Group([ (4,5), (2,3) ])
gap> DigraphGirth(gr);
2
gap> gr := Digraph([[2, 6, 10], [3], [4], [5], [1],
>                   [7], [8], [9], [1], [11], [12], [13], [1]]);;
gap> DigraphGirth(gr);
5
gap> gr := Digraph([[2, 6, 10], [3], [4], [5], [1],
>                   [7], [8], [9], [1], [11], [12], [13], [1]]);;
gap> DigraphGroup(gr);
Group([ (6,10)(7,11)(8,12)(9,13), (2,6)(3,7)(4,8)(5,9) ])
gap> DigraphGirth(gr);
5

#T# MaximalSymmetricSubdigraph and MaximalSymmetricSubdigraphWithoutLoops
gap> gr := Digraph([[2], [1]]);;
gap> IsSymmetricDigraph(gr);
true
gap> MaximalSymmetricSubdigraph(gr) = gr;
true
gap> gr2 := Digraph([[2, 2], [1, 1]]);;
gap> IsSymmetricDigraph(gr2) and IsMultiDigraph(gr2);
true
gap> MaximalSymmetricSubdigraph(gr2) = gr;
true
gap> gr := Digraph([[2, 3], [1, 3], [4], [4]]);
<digraph with 4 vertices, 6 edges>
gap> IsSymmetricDigraph(gr);
false
gap> gr2 := MaximalSymmetricSubdigraph(gr);
<digraph with 4 vertices, 3 edges>
gap> OutNeighbours(gr2);
[ [ 2 ], [ 1 ], [  ], [ 4 ] ]
gap> gr2 := MaximalSymmetricSubdigraphWithoutLoops(gr);
<digraph with 4 vertices, 2 edges>
gap> OutNeighbours(gr2);
[ [ 2 ], [ 1 ], [  ], [  ] ]
gap> gr := Digraph([[2, 2], [1, 1]]);
<multidigraph with 2 vertices, 4 edges>
gap> gr2 := MaximalSymmetricSubdigraphWithoutLoops(gr);
<digraph with 2 vertices, 2 edges>
gap> OutNeighbours(gr2);
[ [ 2 ], [ 1 ] ]
gap> gr := Digraph([[1, 2, 2], [1, 1]]);
<multidigraph with 2 vertices, 5 edges>
gap> IsSymmetricDigraph(gr);
true
gap> gr3 := MaximalSymmetricSubdigraphWithoutLoops(gr);
<digraph with 2 vertices, 2 edges>
gap> gr2 = gr3;
true
gap> gr := Digraph([[2, 3], [1], [1, 3]]);
<digraph with 3 vertices, 5 edges>
gap> IsSymmetricDigraph(gr);
true
gap> gr := MaximalSymmetricSubdigraphWithoutLoops(gr);
<digraph with 3 vertices, 4 edges>
gap> OutNeighbours(gr);
[ [ 2, 3 ], [ 1 ], [ 1 ] ]

#T# RepresentativeOutNeighbours
gap> gr := CycleDigraph(5);
<digraph with 5 vertices, 5 edges>
gap> RepresentativeOutNeighbours(gr);
[ [ 2 ] ]
gap> DigraphOrbitReps(gr);
[ 1 ]
gap> gr := Digraph([[2], [3], []]);
<digraph with 3 vertices, 2 edges>
gap> RepresentativeOutNeighbours(gr);
[ [ 2 ], [ 3 ], [  ] ]

#T# DigraphAdjacencyFunction
gap> gr := Digraph([[1, 3], [2], []]);
<digraph with 3 vertices, 3 edges>
gap> adj := DigraphAdjacencyFunction(gr);
function( u, v ) ... end
gap> adj(1, 1);
true
gap> adj(3, 1);
false
gap> adj(2, 7);
false

#T# Test ChromaticNumber
gap> ChromaticNumber(Digraph([[1]]));
Error, Digraphs: ChromaticNumber: usage,
the digraph (1st argument) must not have loops,
gap> ChromaticNumber(NullDigraph(10));
1
gap> ChromaticNumber(CompleteDigraph(10));
10
gap> ChromaticNumber(CompleteBipartiteDigraph(5, 5));
2
gap> ChromaticNumber(DigraphRemoveEdge(CompleteDigraph(10), [1, 2]));
10
gap> ChromaticNumber(DigraphDisjointUnion(CompleteDigraph(10),
> CompleteBipartiteDigraph(50, 50)));
10
gap> ChromaticNumber(Digraph([[4, 8], [6, 10], [9], [2, 3, 9], [],
> [3], [4], [6], [], [5, 7]]));
3
gap> DigraphColouring(Digraph([[4, 8], [6, 10], [9], [2, 3, 9], [],
> [3], [4], [6], [], [5, 7]]), 2);
fail
gap> DigraphColouring(Digraph([[4, 8], [6, 10], [9], [2, 3, 9], [],
> [3], [4], [6], [], [5, 7]]), 3);
Transformation( [ 1, 3, 1, 2, 1, 2, 1, 3, 3, 2 ] )
gap> ChromaticNumber(DigraphDisjointUnion(CompleteDigraph(1),
> Digraph([[2], [4], [1, 2], [3]])));
3
gap> ChromaticNumber(DigraphDisjointUnion(CompleteDigraph(1),
> Digraph([[2], [4], [1, 2], [3], [1, 2, 3]])));
4
gap> gr := DigraphFromDigraph6String(Concatenation(
> "+l??O?C?A_@???CE????GAAG?C??M?????@_?OO??G??@?IC???_C?G?o??C?AO???c_??A?",
> "A?S???OAA???OG???G_A??C?@?cC????_@G???S??C_?C???[??A?A?OA?O?@?A?@A???GGO",
> "??`?_O??G?@?A??G?@AH????AA?O@??_??b???Cg??C???_??W?G????d?G?C@A?C???GC?W",
> "?????K???__O[??????O?W???O@??_G?@?CG??G?@G?C??@G???_Q?O?O?c???OAO?C??C?G",
> "?O??A@??D??G?C_?A??O?_GA??@@?_?G???E?IW??????_@G?C??"));
<digraph with 45 vertices, 180 edges>
gap> ChromaticNumber(gr);
3
gap> DigraphColoring(gr, 3);
Transformation( [ 1, 2, 2, 1, 2, 1, 3, 1, 1, 2, 2, 2, 1, 2, 1, 2, 1, 1, 3, 3,
  3, 2, 3, 3, 2, 2, 1, 3, 1, 3, 3, 3, 2, 1, 3, 1, 3, 1, 1, 2, 2, 3, 3, 3,
  2 ] )
gap> DigraphColoring(gr, 2);
fail
gap> DigraphColoring(gr);
Transformation( [ 1, 1, 1, 1, 1, 1, 2, 1, 2, 2, 2, 2, 1, 2, 1, 2, 1, 2, 2, 3,
  3, 2, 3, 3, 3, 2, 1, 4, 4, 3, 3, 3, 3, 1, 3, 1, 3, 4, 4, 2, 2, 5, 3, 3,
  4 ] )
gap> gr := Digraph([[2, 3, 4], [3], [], []]);
<digraph with 4 vertices, 4 edges>
gap> ChromaticNumber(gr);
3
gap> ChromaticNumber(EmptyDigraph(0));
0
gap> gr := CompleteDigraph(4);;
gap> gr := DigraphAddVertex(gr);;
gap> ChromaticNumber(gr);
4

#T# UndirectedSpanningTree and UndirectedSpanningForest
gap> gr := EmptyDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> tree := UndirectedSpanningTree(gr);
fail
gap> forest := UndirectedSpanningForest(gr);
fail
gap> gr := EmptyDigraph(1);
<digraph with 1 vertex, 0 edges>
gap> tree := UndirectedSpanningTree(gr);
<digraph with 1 vertex, 0 edges>
gap> forest := UndirectedSpanningForest(gr);
<digraph with 1 vertex, 0 edges>
gap> IsUndirectedSpanningTree(gr, gr);
true
gap> IsUndirectedSpanningTree(gr, forest);
true
gap> gr = forest;
true
gap> gr := EmptyDigraph(2);
<digraph with 2 vertices, 0 edges>
gap> tree := UndirectedSpanningTree(gr);
fail
gap> forest := UndirectedSpanningForest(gr);
<digraph with 2 vertices, 0 edges>
gap> IsUndirectedTree(forest);
false
gap> IsUndirectedSpanningForest(gr, forest);
true
gap> gr = forest;
true
gap> gr := DigraphFromDigraph6String("+I?PIMAQc@A?W?ADPP?");
<digraph with 10 vertices, 23 edges>
gap> IsStronglyConnectedDigraph(gr);
true
gap> UndirectedSpanningTree(gr);
fail
gap> DigraphEdges(UndirectedSpanningForest(gr));
[ [ 2, 7 ], [ 7, 2 ] ]
gap> IsUndirectedSpanningForest(gr, UndirectedSpanningForest(gr));
true

#T# DIGRAPHS_UnbindVariables
gap> Unbind(adj);
gap> Unbind(adj1);
gap> Unbind(adj2);
gap> Unbind(circuit);
gap> Unbind(complete15);
gap> Unbind(cycle12);
gap> Unbind(forest);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(gr3);
gap> Unbind(grid);
gap> Unbind(i);
gap> Unbind(j);
gap> Unbind(mat);
gap> Unbind(multiple);
gap> Unbind(nbs);
gap> Unbind(r);
gap> Unbind(rd);
gap> Unbind(reflextrans);
gap> Unbind(reflextrans1);
gap> Unbind(reflextrans2);
gap> Unbind(scc);
gap> Unbind(str);
gap> Unbind(topo);
gap> Unbind(trans);
gap> Unbind(trans1);
gap> Unbind(trans2);
gap> Unbind(tree);
gap> Unbind(wcc);

#E#
gap> STOP_TEST("Digraphs package: standard/attr.tst");
