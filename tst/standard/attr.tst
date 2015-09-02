#############################################################################
##
#W  standard/attr.tst
#Y  Copyright (C) 2014                                   James D. Mitchell
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
[ [ 0, -1 ], [ -1, 0 ] ]
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
[ [   0,   2,   1,   3,   1,   3,   2 ],
  [  -1,   0,   2,   1,   3,   1,   4 ],
  [  -1,   1,   0,   2,   1,   2,   2 ],
  [  -1,   2,   1,   0,   2,   3,   3 ],
  [  -1,   2,   1,   3,   0,   3,   1 ],
  [  -1,  -1,  -1,  -1,  -1,   0,  -1 ],
  [  -1,   1,   3,   2,   4,   2,   0 ] ]

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

#T# OutDegrees, OutDegreeSequence, InDegrees, InDegreeSequence
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

#T# DigraphDiameter
gap> gr := Digraph([[2], []]);;
gap> DigraphDiameter(gr);
-1
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
-1
gap> gr := Digraph([[1]]);;
gap> DigraphDiameter(gr);
0
gap> gr := EmptyDigraph(0);;
gap> DigraphDiameter(gr);
-1
gap> gr := EmptyDigraph(1);;
gap> DigraphDiameter(gr);
0

#T# DigraphDiameter: not strongly connected, too many vertices for
# Floyd-Warshall
gap> nbs := [
> [], [117], [499, 707], [980], [18, 80], [608], [], [248],
> [367], [344], [151], [253], [], [26], [], [], [],
> [52, 253, 841], [969, 981], [], [79, 327, 690, 704], [631],
> [5], [393, 609], [], [], [499], [234], [], [480, 843],
> [], [], [], [283], [], [200, 264, 274, 917], [528, 538, 883],
> [], [889], [], [], [820], [], [644], [], [291, 880],
> [29], [], [276, 364, 875, 885], [], [], [297], [], [132],
> [526], [], [249, 526], [], [105], [], [15, 817, 904],
> [254], [164, 382], [], [297, 461, 617], [335], [], [76],
> [609, 944], [607], [880], [], [3, 940], [82, 702], [],
> [870], [400, 453, 901], [909], [16, 403, 459], [759],
> [209, 710], [130], [838], [131, 441, 633, 707, 785], [], [],
> [], [], [], [203], [], [], [406], [313], [], [],
> [612, 908], [573, 648, 795], [922], [207], [301], [], [513],
> [], [353], [], [347], [300, 783], [34, 205, 362], [309],
> [], [334], [540], [172], [209], [], [], [459], [],
> [207, 397], [228], [], [], [], [708, 938], [183, 933],
> [139, 243, 795, 821, 941], [], [819], [331], [], [], [53],
> [], [], [], [296, 673], [10, 175, 298, 645], [730], [11],
> [186], [832], [518], [41, 278, 945],
> [99, 128, 148, 224, 367, 886], [165, 366], [297, 603], [], [],
> [405], [409], [], [999], [751], [], [], [940],
> [644, 708, 915], [658], [], [], [94, 167], [825], [],
> [418, 575, 591], [], [], [96], [193, 590], [356], [],
> [434, 847], [], [613, 836], [], [229, 936], [582],
> [278, 893], [320, 704], [], [], [758, 777], [240], [185],
> [], [108], [74, 655], [420, 782], [], [], [171], [469],
> [264], [617], [611, 889], [271, 537], [739], [], [167, 545],
> [], [94], [], [], [457, 731], [], [267], [744], [286],
> [242, 865], [397], [758], [73, 494], [60], [], [654],
> [531], [121], [376, 707], [131, 158, 800], [501], [195],
> [303], [110, 258, 966], [856], [431, 501], [220, 328], [402],
> [267, 891], [], [52, 501, 846], [], [550], [176], [203, 327],
> [], [434], [38, 858], [505, 982], [], [744], [905], [177],
> [], [424], [504], [], [392, 521], [], [174, 689, 989],
> [260, 402, 505], [267, 528, 620], [], [751, 809], [], [593],
> [502, 836], [548], [102, 305, 543], [], [4, 358], [], [],
> [552, 905], [196], [601, 985], [582], [], [896], [556],
> [844], [125], [296, 972], [], [89, 572], [513], [575],
> [45, 946], [356], [], [], [652, 759], [932], [],
> [55, 256, 445], [231, 483], [865], [711], [303],
> [9, 304, 333, 391], [589, 672, 962], [635, 946], [], [], [],
> [460], [429], [131, 721], [792], [71, 170, 982], [333, 607],
> [882, 969], [377], [290], [], [133, 835], [615], [], [562],
> [], [], [169, 262, 277], [], [570, 613], [], [106], [],
> [], [208], [493, 831], [70], [720], [], [], [], [905],
> [855, 924], [214, 263, 799], [148, 883], [371, 546], [570],
> [132, 629, 874], [940], [78, 652], [753], [153], [], [],
> [], [50, 306, 364], [184], [168, 820], [184, 423], [254, 738],
> [16, 470], [64], [], [882], [], [], [801], [627], [465],
> [615, 760], [453], [], [250], [482, 832], [], [], [],
> [440], [], [44, 697], [199], [137], [977], [852], [850],
> [31, 824], [940], [611], [111, 537], [156], [607], [], [],
> [], [], [197, 368, 627, 797], [], [186], [], [], [94, 974],
> [284, 475], [250], [525, 561, 839], [410, 472, 533], [351, 549],
> [160, 371, 735], [], [635, 836], [296], [206], [], [], [],
> [], [425, 830], [706], [201, 236], [], [32, 916], [268],
> [673], [189], [], [273, 982], [], [], [], [711], [685],
> [790], [], [134], [263, 751], [161], [613], [923, 961], [],
> [132, 835], [981], [859], [], [], [], [], [], [],
> [723], [622, 732], [], [302, 510], [85, 512], [678, 771], [],
> [], [], [], [237, 301], [], [], [633, 899], [287, 804],
> [], [914], [303, 533, 948], [897], [507], [776], [], [878],
> [772], [512], [], [656], [207, 436], [141], [715], [],
> [740, 747], [], [45], [], [], [293, 973], [319], [], [],
> [], [], [271, 320], [], [755, 817], [521], [], [], [572],
> [], [249], [361], [], [480], [905], [905], [], [157],
> [], [240], [61, 480], [], [7, 817], [187, 262, 547, 700, 802],
> [171, 206, 318, 329], [], [967], [], [900], [369], [103],
> [932, 982], [13], [], [], [869], [785], [107, 762], [991],
> [78, 784], [199, 582, 613, 651], [993], [], [890], [93],
> [45, 137], [], [], [174, 347], [554, 884, 931], [],
> [396, 522, 575, 681, 899], [143], [593], [908], [152, 469],
> [290], [654, 823, 860, 970], [201], [405, 909], [364], [],
> [397, 847, 933], [191], [587], [89, 382], [566], [715],
> [762], [630], [620], [164], [56, 475], [], [564], [],
> [57], [100, 283], [], [], [538], [112, 302, 873], [],
> [197, 363], [270], [], [986], [278], [], [], [513],
> [507], [128, 960], [462], [85], [], [209], [57, 577, 981],
> [338], [943], [549], [122, 462], [862], [], [643],
> [742, 804, 913], [], [152], [], [], [302], [182, 568], [],
> [], [581], [950], [522], [840], [395], [], [], [922],
> [193, 462], [], [302], [], [], [], [303, 384], [577],
> [166], [577, 724], [924, 983], [38], [90, 852], [47],
> [487, 645, 668], [176], [403], [], [], [479], [291],
> [590, 609], [603], [196, 267], [450, 477, 890], [], [842],
> [599], [171, 344], [235], [138, 393], [259], [], [18, 138],
> [], [], [], [], [], [], [502, 754], [693], [],
> [391, 635], [559], [464], [632], [734], [155], [617],
> [216, 860], [416, 965], [457, 499, 848, 929], [194, 322], [529],
> [151], [732], [104, 285], [322], [170, 865], [121, 184, 388],
> [476], [428], [731], [269, 522], [], [], [333], [],
> [58, 435, 870], [970], [628, 940], [717, 995], [91, 809], [],
> [659], [31, 58], [544], [104], [], [], [], [189], [1],
> [59], [], [745], [961], [], [68, 167], [], [570],
> [132, 741], [], [635], [788, 991], [85, 556, 865], [], [496],
> [], [820], [30], [], [331], [], [], [816],
> [465, 659, 716], [212], [258], [], [], [327], [460], [903],
> [363, 764], [], [420], [93], [893, 953], [317], [12, 826],
> [], [118], [574], [], [], [593, 624], [288, 370, 529],
> [728, 937], [], [884], [], [], [160], [], [],
> [456, 755, 973], [56, 138], [230, 284, 422, 649, 674], [6],
> [368], [80], [], [638], [], [], [102, 500, 578, 790],
> [533, 872], [454], [605, 765], [], [45, 380, 826], [], [],
> [280], [], [534], [], [815], [], [], [220, 388],
> [113, 360], [505], [], [378, 585], [357, 814], [561, 644],
> [565, 928, 995], [876], [], [], [556], [283, 783, 917],
> [410], [281, 676, 735], [647], [849], [], [760], [248, 763],
> [647], [], [], [849], [434], [519], [], [597, 619], [],
> [584], [], [656], [], [], [], [], [844], [711], [],
> [], [115, 176, 307], [827, 981], [], [197], [72],
> [105, 429, 940], [826], [329], [], [521], [158, 502, 800, 987],
> [935], [268], [], [], [380, 407], [], [148, 746], [],
> [167, 701, 820], [200, 352, 666, 672], [], [], [536],
> [108, 331], [116, 174, 268, 686], [475, 643], [548], [152],
> [515, 763], [532], [519], [], [141], [288], [10, 487, 491],
> [518], [], [366, 514, 557], [873, 972], [63, 146, 731], [542],
> [754], [208, 430], [985], [741], [41, 585], [], [523],
> [343, 481, 831], [597], [108, 830, 833, 974], [],
> [30, 474, 769, 923], [], [114], [], [822], [37, 450, 817],
> [], [292, 974], [], [812], [806], [928], [314], [228],
> [855], [], [], [], [], [779], [147, 836], [], [259],
> [333], [], [406], [728, 803], [380], [187, 588], [258, 766],
> [61], [], [], [96, 433], [972], [], [320, 604, 990], [],
> [6, 903], [710], [426], [285], [388, 578], [173, 253], [],
> [133], [307, 419, 437], [127, 648], [], [449], [564], [961],
> [470, 602], [], [], [26, 428, 702], [124], [], [236, 618],
> [729], [669, 937], [], [743, 765], [], [40, 332], [369, 485],
> [609], [], [], [328, 866], [930], [], [], [], [101, 977],
> [360], [], [], [206, 228], [753], [], [133], [655], [],
> [510], [], [], [254, 468, 902], [838], [289], [132, 392],
> [866], [], [166], [], [], [], [530, 613], [316, 447, 563],
> [149, 627], [202], [], [], [], [524, 824], [], [315],
> [142, 882], [142, 256], [], [516], [], [589], [561],
> [196, 990], [181], [332], [535], [], [], [696], [], [],
> [], [467, 706], [463], [747], [], [347], [422], [484, 687],
> [212, 699, 944], [807], [], [], [119], [384, 670],
> [130, 219], [], [], [101], [886], [132, 541, 762], [],
> [601], [], [], [], [995], [57], [], [219], [820]];;
gap> gr := Digraph(nbs);
<digraph with 1000 vertices, 1053 edges>
gap> DigraphDiameter(gr);
-1

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
[ 1, 4, 6, 7, 2 ]
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
[ "two", "four", "three" ]

#T# DIGRAPHS_UnbindVariables
gap> Unbind(gr);
gap> Unbind(nrvertices);
gap> Unbind(nbs);
gap> Unbind(reflextrans);
gap> Unbind(scc);
gap> Unbind(id);
gap> Unbind(rd);
gap> Unbind(source);
gap> Unbind(wcc);
gap> Unbind(adj1);
gap> Unbind(adj);
gap> Unbind(reflextrans1);
gap> Unbind(reflextrans2);
gap> Unbind(multiple);
gap> Unbind(mat);
gap> Unbind(cycle12);
gap> Unbind(adj2);
gap> Unbind(trans1);
gap> Unbind(trans2);
gap> Unbind(topo);
gap> Unbind(comps);
gap> Unbind(grid);
gap> Unbind(gr2);
gap> Unbind(gr3);
gap> Unbind(gr1);
gap> Unbind(i);
gap> Unbind(j);
gap> Unbind(range);
gap> Unbind(r);
gap> Unbind(circuit);
gap> Unbind(trans);
gap> Unbind(complete15);

#E#
gap> STOP_TEST("Digraphs package: standard/attr.tst");
