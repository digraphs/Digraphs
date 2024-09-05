#############################################################################
##
#W  standard/attr.tst
#Y  Copyright (C) 2014-24                                James D. Mitchell
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

#  DigraphSource and DigraphRange
gap> nbs := [[12, 22, 17, 1, 10, 11], [23, 21, 21, 16],
>  [15, 5, 22, 11, 12, 8, 10, 1], [21, 15, 23, 5, 23, 8, 24],
>  [20, 17, 25, 25], [5, 24, 22, 5, 2], [11, 8, 19],
>  [18, 20, 13, 3, 11], [15, 18, 12, 10], [8, 23, 15, 25, 8, 19, 17],
>  [19, 2, 17, 21, 18], [9, 4, 7, 3], [14, 10, 2], [11, 24, 14],
>  [2, 21], [12], [9, 2, 11, 9], [21, 24, 16, 8, 8], [3], [5, 6],
>  [14, 2], [24, 24, 20], [19, 8, 20], [7, 1, 2, 15, 13, 9],
>  [16, 12, 19]];;
gap> gr := Digraph(nbs);
<immutable multidigraph with 25 vertices, 100 edges>
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
<immutable multidigraph with 25 vertices, 100 edges>
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

#  DigraphDual
gap> gr := Digraph([[6, 7], [6, 9], [1, 3, 4, 5, 8, 9],
> [1, 2, 3, 4, 5, 6, 7, 10], [1, 5, 6, 7, 10], [2, 4, 5, 9, 10],
> [3, 4, 5, 6, 7, 8, 9, 10], [1, 3, 5, 7, 8, 9], [1, 2, 5],
> [1, 2, 4, 6, 7, 8]]);;
gap> OutNeighbours(DigraphDual(gr));
[ [ 1, 2, 3, 4, 5, 8, 9, 10 ], [ 1, 2, 3, 4, 5, 7, 8, 10 ], [ 2, 6, 7, 10 ], 
  [ 8, 9 ], [ 2, 3, 4, 8, 9 ], [ 1, 3, 6, 7, 8 ], [ 1, 2 ], [ 2, 4, 6, 10 ], 
  [ 3, 4, 6, 7, 8, 9, 10 ], [ 3, 5, 9, 10 ] ]
gap> gr := Digraph(rec(DigraphVertices := ["a", "b"],
> DigraphSource := ["b", "b"], DigraphRange := ["a", "a"]));
<immutable multidigraph with 2 vertices, 2 edges>
gap> DigraphDual(gr);
Error, the argument <D> must be a digraph with no multiple edges,
gap> DigraphDual(DigraphMutableCopy(gr));
Error, the argument <D> must be a digraph with no multiple edges,
gap> gr := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> DigraphDual(gr);
<immutable empty digraph with 0 vertices>
gap> DigraphDual(gr);
<immutable empty digraph with 0 vertices>
gap> gr := Digraph([[], []]);
<immutable empty digraph with 2 vertices>
gap> DigraphDual(gr);
<immutable digraph with 2 vertices, 4 edges>
gap> gr := Digraph(rec(DigraphNrVertices := 2,
>                      DigraphSource := [],
>                      DigraphRange := []));
<immutable empty digraph with 2 vertices>
gap> DigraphDual(gr);
<immutable digraph with 2 vertices, 4 edges>
gap> gr := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> DigraphDual(gr);
Error, the argument <D> must be a digraph with no multiple edges,
gap> r := rec(DigraphNrVertices := 6,
> DigraphSource := [2, 2, 2, 2, 2, 2, 4, 4, 4],
> DigraphRange := [1, 2, 3, 4, 5, 6, 3, 4, 5]);;
gap> gr := Digraph(r);
<immutable digraph with 6 vertices, 9 edges>
gap> DigraphDual(gr);
<immutable digraph with 6 vertices, 27 edges>
gap> r := rec(DigraphNrVertices := 4, DigraphSource := [], DigraphRange := []);;
gap> gr := Digraph(r);
<immutable empty digraph with 4 vertices>
gap> DigraphDual(gr);
<immutable digraph with 4 vertices, 16 edges>
gap> gr := Digraph(r);;
gap> SetDigraphVertexLabels(gr, [4, 3, 2, 1]);
gap> gr2 := DigraphDual(gr);;
gap> DigraphVertexLabels(gr2);
[ 4, 3, 2, 1 ]
gap> DigraphNrVertices(gr2);
4
gap> gr := Digraph([[1], [1, 3], [1, 2]]);
<immutable digraph with 3 vertices, 5 edges>
gap> DigraphGroup(gr) = Group((2, 3));
true
gap> gr2 := DigraphDual(gr);
<immutable digraph with 3 vertices, 4 edges>
gap> OutNeighbours(gr2);
[ [ 2, 3 ], [ 2 ], [ 3 ] ]
gap> HasDigraphGroup(gr2);
true
gap> DigraphGroup(gr2) = Group((2, 3));
true
gap> DigraphGroup(gr2) = DigraphGroup(gr);
true

#  AdjacencyMatrix
gap> gr := Digraph(rec(DigraphNrVertices := 10,
> DigraphSource := [1, 1, 1, 1, 1, 1, 1, 1],
> DigraphRange := [2, 2, 3, 3, 4, 4, 5, 5]));
<immutable multidigraph with 10 vertices, 8 edges>
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
gap> r := rec(DigraphNrVertices := 7,
> DigraphSource := [1, 1, 2, 2, 3, 4, 4, 5, 6, 7, 7],
> DigraphRange := [3, 4, 2, 4, 6, 6, 7, 2, 7, 5, 5]);;
gap> gr := Digraph(r);
<immutable multidigraph with 7 vertices, 11 edges>
gap> adj1 := AdjacencyMatrix(gr);
[ [ 0, 0, 1, 1, 0, 0, 0 ], [ 0, 1, 0, 1, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 1, 0 ], 
  [ 0, 0, 0, 0, 0, 1, 1 ], [ 0, 1, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 1 ], 
  [ 0, 0, 0, 0, 2, 0, 0 ] ]
gap> gr := Digraph(OutNeighbours(gr));
<immutable multidigraph with 7 vertices, 11 edges>
gap> adj2 := AdjacencyMatrix(gr);
[ [ 0, 0, 1, 1, 0, 0, 0 ], [ 0, 1, 0, 1, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 1, 0 ], 
  [ 0, 0, 0, 0, 0, 1, 1 ], [ 0, 1, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 1 ], 
  [ 0, 0, 0, 0, 2, 0, 0 ] ]
gap> adj1 = adj2;
true
gap> r := rec(DigraphNrVertices := 1,
>             DigraphSource := [1, 1],
>             DigraphRange := [1, 1]);;
gap> gr := Digraph(r);
<immutable multidigraph with 1 vertex, 2 edges>
gap> adj1 := AdjacencyMatrix(gr);
[ [ 2 ] ]
gap> gr := Digraph(OutNeighbours(gr));
<immutable multidigraph with 1 vertex, 2 edges>
gap> adj2 := AdjacencyMatrix(gr);
[ [ 2 ] ]
gap> adj1 = adj2;
true
gap> AdjacencyMatrix(Digraph([]));
[  ]
gap> AdjacencyMatrix(Digraph(rec(DigraphNrVertices := 0,
>                                DigraphSource     := [],
>                                DigraphRange      := [])));
[  ]

#  DigraphNrAdjacencies
gap> G := Digraph([[1, 3, 4, 5, 6, 7, 10, 12, 14, 15, 16, 17, 19, 20, 21, 22, 23, 26, 28, 29, 30], 
>  [2, 3, 4, 6, 7, 8, 11, 13, 14, 17, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30],
>  [1, 2, 4, 5, 6, 9, 10, 12, 14, 15, 17, 20, 22, 24, 25, 26, 27, 28, 30],
>  [1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 16, 18, 19, 20, 21, 22, 23, 24, 25, 26, 28, 29],
>  [1, 4, 6, 7, 9, 10, 11, 12, 14, 15, 16, 18, 19, 20, 21, 22, 23, 24, 25, 28, 29, 30],
>  [1, 5, 6, 7, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25, 26, 28, 29, 30],
>  [1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 13, 15, 16, 18, 19, 21, 22, 23, 25, 26, 27, 28, 30],
>  [2, 5, 6, 8, 9, 10, 12, 13, 14, 15, 19, 20, 21, 22, 23, 24, 25, 26, 29],
>  [1, 5, 6, 9, 12, 13, 14, 16, 18, 20, 21, 22, 23, 24, 25, 26, 29, 30],
>  [1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 13, 15, 16, 18, 19, 20, 21, 22, 25, 28],
>  [1, 2, 3, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16, 18, 19, 20, 21, 23, 24, 25, 26, 27, 28, 29],
>  [1, 2, 5, 9, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30],
>  [1, 3, 4, 5, 8, 9, 10, 14, 16, 17, 18, 19, 21, 22, 23, 24, 26, 27, 28, 29, 30],
>  [2, 3, 4, 5, 6, 7, 8, 9, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 28, 29, 30],
>  [1, 2, 3, 4, 6, 7, 8, 10, 11, 12, 13, 14, 16, 17, 20, 22, 23, 24, 25, 26, 27, 28],
>  [1, 3, 6, 8, 10, 11, 13, 14, 15, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28],
>  [1, 2, 3, 6, 7, 8, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 22, 23, 26, 27, 30],
>  [1, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 28, 30],
>  [1, 3, 4, 5, 6, 10, 11, 13, 14, 15, 18, 19, 20, 21, 22, 24, 25, 27, 28, 29],
>  [1, 2, 4, 7, 8, 9, 10, 11, 18, 20, 21, 22, 23, 24, 25, 26, 28, 30],
>  [1, 2, 3, 4, 5, 10, 11, 12, 13, 14, 18, 19, 20, 21, 22, 24, 25, 26, 28, 29, 30],
>  [1, 3, 5, 7, 8, 9, 10, 12, 13, 14, 17, 18, 19, 21, 24, 26, 29, 30],
>  [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 14, 16, 17, 18, 19, 20, 21, 23, 24, 25, 27, 28, 29],
>  [1, 2, 3, 6, 8, 9, 11, 12, 14, 16, 17, 18, 20, 22, 25, 26, 27, 28, 29, 30],
>  [1, 2, 3, 4, 5, 8, 9, 10, 11, 12, 13, 14, 15, 16, 18, 19, 20, 21, 24, 25, 27, 28, 29, 30],
>  [1, 2, 5, 6, 7, 10, 12, 13, 14, 15, 16, 19, 20, 21, 24, 25, 26, 27, 28, 29, 30],
>  [1, 2, 4, 5, 6, 7, 9, 10, 13, 17, 18, 20, 21, 23, 24, 25, 26, 27, 28, 29, 30],
>  [1, 3, 4, 7, 8, 9, 11, 12, 13, 14, 16, 17, 19, 20, 21, 23, 24, 26, 27, 29],
>  [1, 4, 5, 6, 7, 8, 10, 11, 12, 13, 15, 16, 17, 18, 20, 21, 23, 24, 25, 27, 28, 30],
>  [1, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 18, 19, 20, 21, 22, 24, 27, 28, 29]]);;
gap> DigraphNrAdjacencies(G) * 2 - DigraphNrLoops(G) = 
> DigraphNrEdges(DigraphSymmetricClosure(G));
true
gap> DigraphNrAdjacenciesWithoutLoops(G) * 2 + DigraphNrLoops(G) = 
> DigraphNrEdges(DigraphSymmetricClosure(G));
true

#  DigraphTopologicalSort
gap> r := rec(DigraphNrVertices := 20000,
>             DigraphSource     := [],
>             DigraphRange      := []);;
gap> for i in [1 .. 9999] do
>   Add(r.DigraphSource, i);
>   Add(r.DigraphRange, i + 1);
> od;
> Add(r.DigraphSource, 10000);; Add(r.DigraphRange, 20000);;
> Add(r.DigraphSource, 10001);; Add(r.DigraphRange, 1);;
> for i in [10001 .. 19999] do
>   Add(r.DigraphSource, i);
>   Add(r.DigraphRange, i + 1);
> od;
gap> circuit := Digraph(r);
<immutable digraph with 20000 vertices, 20000 edges>
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
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphTopologicalSort(gr);
fail
gap> r := rec(DigraphNrVertices := 2,
>             DigraphSource := [1, 1],
>             DigraphRange := [2, 2]);;
gap> multiple := Digraph(r);;
gap> DigraphTopologicalSort(multiple);
[ 2, 1 ]
gap> gr := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> DigraphTopologicalSort(gr);
[  ]
gap> gr := Digraph([[]]);
<immutable empty digraph with 1 vertex>
gap> DigraphTopologicalSort(gr);
[ 1 ]
gap> gr := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> DigraphTopologicalSort(gr);
[ 1 ]
gap> gr := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphTopologicalSort(gr);
fail
gap> r := rec(DigraphNrVertices := 8,
> DigraphSource := [1, 1, 1, 2, 3, 4, 4, 5, 7, 7],
> DigraphRange := [4, 3, 4, 8, 2, 2, 6, 7, 4, 8]);;
gap> grid := Digraph(r);;
gap> DigraphTopologicalSort(grid);
[ 8, 2, 6, 4, 3, 1, 7, 5 ]
gap> adj := [[3], [], [2, 3, 4], []];;
gap> gr := Digraph(adj);
<immutable digraph with 4 vertices, 4 edges>
gap> IsAcyclicDigraph(gr);
false
gap> DigraphTopologicalSort(gr);
[ 2, 4, 3, 1 ]
gap> gr := Digraph([
> [7], [], [], [6], [], [3], [], [], [5, 15], [], [],
> [6], [19], [], [11], [13], [], [17], [], [17]]);
<immutable digraph with 20 vertices, 11 edges>
gap> DigraphTopologicalSort(gr);
[ 7, 1, 2, 3, 6, 4, 5, 8, 11, 15, 9, 10, 12, 19, 13, 14, 16, 17, 18, 20 ]
gap> gr := Digraph([[2], [], []]);
<immutable digraph with 3 vertices, 1 edge>
gap> DigraphTopologicalSort(gr);
[ 2, 1, 3 ]

#  DigraphStronglyConnectedComponents

# <gr> is Digraph(RightCayleyGraphSemigroup) of the gens:
# [Transformation([1, 3, 3]),
#  Transformation([2, 1, 2]),
#  Transformation([2, 2, 1])];;
gap> adj := [
> [1, 11, 11], [3, 10, 11], [3, 11, 10], [6, 9, 11], [7, 8, 11],
> [6, 11, 9], [7, 11, 8], [12, 5, 11], [13, 4, 11], [14, 2, 11],
> [15, 1, 11], [12, 11, 5], [13, 11, 4], [14, 11, 2], [15, 11, 1]];;
gap> gr := Digraph(adj);
<immutable multidigraph with 15 vertices, 45 edges>
gap> DigraphStronglyConnectedComponents(gr);
rec( 
  comps := [ [ 1, 11, 15 ], [ 2, 3, 10, 14 ], [ 4, 6, 9, 13 ], 
      [ 5, 7, 8, 12 ] ], id := [ 1, 2, 2, 3, 4, 3, 4, 4, 3, 2, 1, 4, 3, 2, 1 
     ] )
gap> adj := [[3, 4, 5, 7, 10], [4, 5, 10], [1, 2, 4, 7], [2, 9],
> [4, 5, 8, 9], [1, 3, 4, 5, 6], [1, 2, 4, 6],
> [1, 2, 3, 4, 5, 6, 7, 9], [2, 4, 8], [4, 5, 6, 8, 11], [10]];;
gap> gr := Digraph(adj);
<immutable digraph with 11 vertices, 44 edges>
gap> scc := DigraphStronglyConnectedComponents(gr);
rec( comps := [ [ 1, 3, 2, 4, 9, 8, 5, 6, 7, 10, 11 ] ], 
  id := [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ] )
gap> gr := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> DigraphStronglyConnectedComponents(gr);
rec( comps := [  ], id := [  ] )
gap> r := rec(DigraphNrVertices := 9,
> DigraphRange := [1, 7, 6, 9, 4, 8, 2, 5, 8, 9, 3, 9, 4, 8, 1, 1, 3],
> DigraphSource := [1, 1, 2, 2, 4, 4, 5, 6, 6, 6, 7, 7, 8, 8, 9, 9, 9]);;
gap> gr := Digraph(r);
<immutable multidigraph with 9 vertices, 17 edges>
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
<immutable cycle digraph with 10 vertices>
gap> gr2 := DigraphRemoveEdge(gr, 10, 1);
<immutable digraph with 10 vertices, 9 edges>
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

#  DigraphNrStronglyConnectedComponents
gap> D := CycleDigraph(10);;
gap> for i in [1 .. 50] do
> D := DigraphDisjointUnion(D, CycleDigraph(10));
> od;
gap> DigraphNrStronglyConnectedComponents(D);
51
gap> D := CayleyDigraph(SymmetricGroup(6));;
gap> DigraphNrStronglyConnectedComponents(D);
1
gap> D := Digraph([[2, 3], [1, 4, 5], [3], [2, 5], [6], [3, 5]]);;
gap> DigraphNrStronglyConnectedComponents(D);
3
gap>  D := Digraph([[]]);;
gap> DigraphNrStronglyConnectedComponents(D);
1
gap> D := EmptyDigraph(0);;
gap> DigraphNrStronglyConnectedComponents(D);
0

#  DigraphConnectedComponents
gap> gr := Digraph([[1, 2], [1], [2], [5], []]);
<immutable digraph with 5 vertices, 5 edges>
gap> wcc := DigraphConnectedComponents(gr);
rec( comps := [ [ 1, 2, 3 ], [ 4, 5 ] ], id := [ 1, 1, 1, 2, 2 ] )
gap> gr := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> DigraphConnectedComponents(gr);
rec( comps := [  ], id := [  ] )
gap> gr := Digraph([[]]);
<immutable empty digraph with 1 vertex>
gap> DigraphConnectedComponents(gr);
rec( comps := [ [ 1 ] ], id := [ 1 ] )
gap> gr := Digraph([[1], [2], [3], [4]]);
<immutable digraph with 4 vertices, 4 edges>
gap> DigraphConnectedComponents(gr);
rec( comps := [ [ 1 ], [ 2 ], [ 3 ], [ 4 ] ], id := [ 1, 2, 3, 4 ] )
gap> gr := Digraph([[3, 4, 5, 7, 8, 9], [1, 4, 5, 8, 9, 5, 10],
> [2, 4, 5, 6, 7, 10], [6], [1, 1, 1, 7, 8, 9], [2, 2, 6, 8], [1, 5, 6, 9, 10],
> [3, 4, 6, 7], [1, 2, 3, 5], [5, 7]]);
<immutable multidigraph with 10 vertices, 45 edges>
gap> DigraphConnectedComponents(gr);
rec( comps := [ [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] ], 
  id := [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ] )
gap> gr := Digraph(rec(
> DigraphNrVertices := 100,
> DigraphSource     := [8, 9, 11, 11, 12, 13, 14, 14, 18, 19, 22, 27, 31, 32,
>                       32, 34, 37, 40, 45, 48, 50, 52, 58, 58, 58, 59, 60, 60,
>                       65, 66, 73, 75, 79, 81, 81, 83, 84, 86, 86, 89, 96, 100,
>                       100, 100],
> DigraphRange      := [54, 62, 28, 55, 70, 37, 20, 32, 53, 16, 42, 66, 63, 13,
>                       73, 89, 36, 5, 4, 58, 26, 48, 36, 56, 65, 78, 95, 96,
>                       97, 60, 11, 66, 66, 19, 79, 21, 13, 29, 78, 98, 100, 44,
>                       53, 69]));
<immutable digraph with 100 vertices, 44 edges>
gap> OutNeighbours(gr);
[ [  ], [  ], [  ], [  ], [  ], [  ], [  ], [ 54 ], [ 62 ], [  ], [ 28, 55 ], 
  [ 70 ], [ 37 ], [ 20, 32 ], [  ], [  ], [  ], [ 53 ], [ 16 ], [  ], [  ], 
  [ 42 ], [  ], [  ], [  ], [  ], [ 66 ], [  ], [  ], [  ], [ 63 ], 
  [ 13, 73 ], [  ], [ 89 ], [  ], [  ], [ 36 ], [  ], [  ], [ 5 ], [  ], 
  [  ], [  ], [  ], [ 4 ], [  ], [  ], [ 58 ], [  ], [ 26 ], [  ], [ 48 ], 
  [  ], [  ], [  ], [  ], [  ], [ 36, 56, 65 ], [ 78 ], [ 95, 96 ], [  ], 
  [  ], [  ], [  ], [ 97 ], [ 60 ], [  ], [  ], [  ], [  ], [  ], [  ], 
  [ 11 ], [  ], [ 66 ], [  ], [  ], [  ], [ 66 ], [  ], [ 19, 79 ], [  ], 
  [ 21 ], [ 13 ], [  ], [ 29, 78 ], [  ], [  ], [ 98 ], [  ], [  ], [  ], 
  [  ], [  ], [  ], [ 100 ], [  ], [  ], [  ], [ 44, 53, 69 ] ]
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

#  DigraphShortestDistances
gap> adj := Concatenation(List([1 .. 11], x -> [x + 1]), [[1]]);;
gap> cycle12 := Digraph(adj);
<immutable digraph with 12 vertices, 12 edges>
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
gap> r := rec(DigraphVertices := [1 .. 15],
>             DigraphSource   := [],
>             DigraphRange    := []);;
gap> for i in [1 .. 15] do
>   for j in [1 .. 15] do
>     Add(r.DigraphSource, i);
>     Add(r.DigraphRange, j);
>   od;
> od;
gap> complete15 := Digraph(r);
<immutable digraph with 15 vertices, 225 edges>
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
gap> r := rec(DigraphNrVertices := 7,
>             DigraphRange      := [3, 5, 5, 4, 6, 2, 5, 3, 3, 7, 2],
>             DigraphSource     := [1, 1, 1, 2, 2, 3, 3, 4, 5, 5, 7]);;
gap> gr := Digraph(r);
<immutable multidigraph with 7 vertices, 11 edges>
gap> Display(DigraphShortestDistances(gr));
[ [     0,     2,     1,     3,     1,     3,     2 ],
  [  fail,     0,     2,     1,     3,     1,     4 ],
  [  fail,     1,     0,     2,     1,     2,     2 ],
  [  fail,     2,     1,     0,     2,     3,     3 ],
  [  fail,     2,     1,     3,     0,     3,     1 ],
  [  fail,  fail,  fail,  fail,  fail,     0,  fail ],
  [  fail,     1,     3,     2,     4,     2,     0 ] ]

#  DigraphShortestDistances, using connectivity data
gap> gr := CycleDigraph(3);;
gap> DIGRAPHS_ConnectivityData(gr);
[  ]
gap> DigraphShortestDistances(gr);
[ [ 0, 1, 2 ], [ 2, 0, 1 ], [ 1, 2, 0 ] ]
gap> gr := CompleteDigraph(3);;
gap> DIGRAPH_ConnectivityDataForVertex(gr, 2);;
gap> DigraphShortestDistances(gr);
[ [ 0, 1, 1 ], [ 1, 0, 1 ], [ 1, 1, 0 ] ]

#  OutNeighbours and InNeighbours
gap> gr := Digraph(rec(DigraphNrVertices := 10,
>                      DigraphSource := [1, 1, 5, 5, 7, 10],
>                      DigraphRange := [3, 3, 1, 10, 7, 1]));
<immutable multidigraph with 10 vertices, 6 edges>
gap> InNeighbours(gr);
[ [ 5, 10 ], [  ], [ 1, 1 ], [  ], [  ], [  ], [ 7 ], [  ], [  ], [ 5 ] ]
gap> OutNeighbours(gr);
[ [ 3, 3 ], [  ], [  ], [  ], [ 1, 10 ], [  ], [ 7 ], [  ], [  ], [ 1 ] ]
gap> gr := Digraph([[1, 1, 4], [2, 3, 4], [2, 4, 4, 4], [2]]);
<immutable multidigraph with 4 vertices, 11 edges>
gap> InNeighbours(gr);
[ [ 1, 1 ], [ 2, 3, 4 ], [ 2 ], [ 1, 2, 3, 3, 3 ] ]
gap> OutNeighbours(gr);
[ [ 1, 1, 4 ], [ 2, 3, 4 ], [ 2, 4, 4, 4 ], [ 2 ] ]

#  OutDegree and OutDegreeSequence and InDegrees and InDegreeSequence
gap> r := rec(DigraphNrVertices := 0, DigraphSource := [], DigraphRange := []);;
gap> gr1 := Digraph(r);
<immutable empty digraph with 0 vertices>
gap> OutDegrees(gr1);
[  ]
gap> OutDegreeSequence(gr1);
[  ]
gap> InDegrees(gr1);
[  ]
gap> InDegreeSequence(gr1);
[  ]
gap> gr2 := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> OutDegrees(gr2);
[  ]
gap> OutDegreeSequence(gr2);
[  ]
gap> InDegrees(gr2);
[  ]
gap> InDegreeSequence(gr2);
[  ]
gap> gr3 := Digraph([]);
<immutable empty digraph with 0 vertices>
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
<immutable multidigraph with 8 vertices, 28 edges>
gap> OutDegrees(gr1);
[ 3, 4, 1, 5, 5, 2, 6, 2 ]
gap> OutDegreeSequence(gr1);
[ 6, 5, 5, 4, 3, 2, 2, 1 ]
gap> InDegrees(gr1);
[ 5, 0, 3, 5, 4, 5, 5, 1 ]
gap> InDegreeSequence(gr1);
[ 5, 5, 5, 5, 4, 3, 1, 0 ]
gap> gr2 := Digraph(adj);
<immutable multidigraph with 8 vertices, 28 edges>
gap> InNeighbours(gr2);;
gap> InDegrees(gr2);
[ 5, 0, 3, 5, 4, 5, 5, 1 ]
gap> InDegreeSequence(gr2);
[ 5, 5, 5, 5, 4, 3, 1, 0 ]
gap> r := rec(DigraphNrVertices := 8,
> DigraphSource := [1, 1, 1, 2, 2, 2, 2, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6,
>                   7, 7, 7, 7, 7, 7, 8, 8],
> DigraphRange := [6, 7, 1, 1, 3, 3, 6, 5, 1, 4, 4, 4, 8, 1, 3, 4, 6, 7, 7, 7,
>                  1, 4, 5, 6, 5, 7, 5, 6]);;
gap> gr3 := Digraph(r);
<immutable multidigraph with 8 vertices, 28 edges>
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

#  DigraphEdges
gap> r := rec(
> DigraphNrVertices := 5,
> DigraphSource := [1, 1, 2, 3, 5, 5],
> DigraphRange := [1, 4, 3, 5, 2, 2]);
rec( DigraphNrVertices := 5, DigraphRange := [ 1, 4, 3, 5, 2, 2 ], 
  DigraphSource := [ 1, 1, 2, 3, 5, 5 ] )
gap> gr := Digraph(r);
<immutable multidigraph with 5 vertices, 6 edges>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 4 ], [ 2, 3 ], [ 3, 5 ], [ 5, 2 ], [ 5, 2 ] ]
gap> gr := Digraph([[4], [2, 3, 1, 3], [3, 3], [], [1, 4, 5]]);
<immutable multidigraph with 5 vertices, 10 edges>
gap> DigraphEdges(gr);
[ [ 1, 4 ], [ 2, 2 ], [ 2, 3 ], [ 2, 1 ], [ 2, 3 ], [ 3, 3 ], [ 3, 3 ], 
  [ 5, 1 ], [ 5, 4 ], [ 5, 5 ] ]
gap> gr := Digraph([[1, 2, 3, 5, 6, 8], [6, 6, 7, 8], [1, 2, 3, 4, 6, 7],
> [2, 3, 5, 6, 2, 7], [5, 6, 5, 5], [3, 2, 8], [1, 5, 7], [6, 7]]);
<immutable multidigraph with 8 vertices, 34 edges>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ], [ 1, 5 ], [ 1, 6 ], [ 1, 8 ], [ 2, 6 ], 
  [ 2, 6 ], [ 2, 7 ], [ 2, 8 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ], [ 3, 4 ], 
  [ 3, 6 ], [ 3, 7 ], [ 4, 2 ], [ 4, 3 ], [ 4, 5 ], [ 4, 6 ], [ 4, 2 ], 
  [ 4, 7 ], [ 5, 5 ], [ 5, 6 ], [ 5, 5 ], [ 5, 5 ], [ 6, 3 ], [ 6, 2 ], 
  [ 6, 8 ], [ 7, 1 ], [ 7, 5 ], [ 7, 7 ], [ 8, 6 ], [ 8, 7 ] ]

#  DigraphSources and DigraphSinks
gap> r := rec(DigraphNrVertices := 10,
> DigraphSource := [2, 2, 3, 3, 3, 5, 7, 7, 7, 7, 9, 9, 9, 9, 9],
> DigraphRange := [2, 2, 6, 8, 2, 4, 2, 6, 8, 6, 8, 5, 8, 2, 4]);;
gap> gr := Digraph(r);
<immutable multidigraph with 10 vertices, 15 edges>
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

#  DigraphPeriod
gap> gr := EmptyDigraph(100);
<immutable empty digraph with 100 vertices>
gap> DigraphPeriod(gr);
0
gap> gr := CompleteDigraph(100);
<immutable complete digraph with 100 vertices>
gap> DigraphPeriod(gr);
1
gap> gr := Digraph([[2, 2], [3], [4], [1]]);
<immutable multidigraph with 4 vertices, 5 edges>
gap> DigraphPeriod(gr);
4
gap> gr := Digraph([[2], [3], [4], []]);
<immutable digraph with 4 vertices, 3 edges>
gap> HasIsAcyclicDigraph(gr);
false
gap> DigraphPeriod(gr);
0
gap> HasIsAcyclicDigraph(gr);
true
gap> IsAcyclicDigraph(gr);
true
gap> gr := Digraph([[2], [3], [4], []]);
<immutable digraph with 4 vertices, 3 edges>
gap> IsAcyclicDigraph(gr);
true
gap> DigraphPeriod(gr);
0

#  DigraphDiameter 1
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

#  DigraphDiameter 2
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
<immutable digraph with 1000 vertices, 1053 edges>
gap> DigraphDiameter(gr);
fail

#  DigraphSymmetricClosure
gap> gr1 := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsSymmetricDigraph(gr1);
true
gap> gr2 := DigraphSymmetricClosure(gr1);
<immutable symmetric digraph with 2 vertices, 2 edges>
gap> IsIdenticalObj(gr1, gr2);
true
gap> gr1 = gr2;
true
gap> gr1 := Digraph([[1, 1, 1, 1]]);
<immutable multidigraph with 1 vertex, 4 edges>
gap> gr2 := DigraphSymmetricClosure(gr1);
<immutable multidigraph with 1 vertex, 4 edges>
gap> IsIdenticalObj(gr1, gr2);
true
gap> gr1 = gr2;
true
gap> gr1 := Digraph(
> [[], [4, 5], [12], [3], [2, 10, 11, 12], [2, 8, 10, 12], [5],
> [11, 12], [12], [12], [2, 6, 7, 8], [3, 8, 10]]);
<immutable digraph with 12 vertices, 24 edges>
gap> IsSymmetricDigraph(gr1);
false
gap> gr2 := DigraphSymmetricClosure(gr1);
<immutable symmetric digraph with 12 vertices, 38 edges>
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
gap> gr := DigraphSymmetricClosure(ChainDigraph(10000));
<immutable symmetric digraph with 10000 vertices, 19998 edges>
gap> IsSymmetricDigraph(gr);
true
gap> gr := DigraphCopy(gr);
<immutable digraph with 10000 vertices, 19998 edges>
gap> IsSymmetricDigraph(gr);
true

#  Digraph(Reflexive)TransitiveClosure
gap> gr := Digraph(rec(DigraphNrVertices := 2,
>                      DigraphSource := [1, 1],
>                      DigraphRange := [2, 2]));
<immutable multidigraph with 2 vertices, 2 edges>
gap> DigraphReflexiveTransitiveClosure(gr);
Error, the argument <D> must be a digraph with no multiple edges,
gap> DigraphTransitiveClosure(gr);
Error, the argument <D> must be a digraph with no multiple edges,
gap> r := rec(DigraphVertices := [1 .. 4], DigraphSource := [1, 1, 2, 3, 4],
> DigraphRange := [1, 2, 3, 4, 1]);;
gap> gr := Digraph(r);
<immutable digraph with 4 vertices, 5 edges>
gap> IsAcyclicDigraph(gr);
false
gap> DigraphTopologicalSort(gr);
fail
gap> gr1 := DigraphTransitiveClosure(gr);
<immutable transitive digraph with 4 vertices, 16 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr);
<immutable preorder digraph with 4 vertices, 16 edges>
gap> gr1 = gr2;
true
gap> gr1 = DigraphReflexiveTransitiveClosure(DigraphMutableCopy(gr));
true
gap> adj := [[2, 6], [3], [7], [3], [], [2, 7], [5]];;
gap> gr := Digraph(adj);
<immutable digraph with 7 vertices, 8 edges>
gap> IsAcyclicDigraph(gr);
true
gap> gr1 := DigraphTransitiveClosure(gr);
<immutable transitive digraph with 7 vertices, 18 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(DigraphImmutableCopy(gr));
<immutable preorder digraph with 7 vertices, 25 edges>
gap> gr := Digraph([[2], [3], [4], [3]]);
<immutable digraph with 4 vertices, 4 edges>
gap> gr1 := DigraphTransitiveClosure(gr);
<immutable transitive digraph with 4 vertices, 9 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr);
<immutable preorder digraph with 4 vertices, 11 edges>
gap> gr := Digraph([[2], [3], [4, 5], [], [5]]);
<immutable digraph with 5 vertices, 5 edges>
gap> gr1 := DigraphTransitiveClosure(gr);
<immutable transitive digraph with 5 vertices, 10 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr);
<immutable preorder digraph with 5 vertices, 14 edges>
gap> gr := Digraph(
> [[1, 4, 5, 6, 7, 8], [5, 7, 8, 9, 10, 13], [2, 4, 6, 10],
>  [7, 9, 10, 11], [7, 9, 10, 12, 13, 15], [7, 8, 10, 13], [10, 11],
>  [7, 10, 12, 13, 14, 15, 16], [7, 10, 11, 14, 16], [11], [11],
>  [7, 13, 14], [10, 11], [7, 10, 11], [7, 13, 16], [7, 10, 11]]);
<immutable digraph with 16 vertices, 60 edges>
gap> trans1 := DigraphTransitiveClosure(gr);
<immutable transitive digraph with 16 vertices, 98 edges>
gap> trans2 := DigraphByAdjacencyMatrix(DIGRAPH_TRANS_CLOSURE(gr));
<immutable digraph with 16 vertices, 98 edges>
gap> trans1 = trans2;
true
gap> trans := Digraph(OutNeighbours(trans1));
<immutable digraph with 16 vertices, 98 edges>
gap> IsReflexiveDigraph(trans);
false
gap> IsTransitiveDigraph(trans);
true
gap> IS_TRANSITIVE_DIGRAPH(trans);
true
gap> reflextrans1 := DigraphReflexiveTransitiveClosure(gr);
<immutable preorder digraph with 16 vertices, 112 edges>
gap> reflextrans2 :=
> DigraphByAdjacencyMatrix(DIGRAPH_REFLEX_TRANS_CLOSURE(gr));
<immutable digraph with 16 vertices, 112 edges>
gap> reflextrans1 = reflextrans2;
true
gap> reflextrans := Digraph(OutNeighbours(reflextrans1));
<immutable digraph with 16 vertices, 112 edges>
gap> IsReflexiveDigraph(reflextrans);
true
gap> IsTransitiveDigraph(reflextrans);
true
gap> IS_TRANSITIVE_DIGRAPH(reflextrans);
true

#  ReducedDigraph
gap> gr := EmptyDigraph(0);;
gap> ReducedDigraph(gr) = gr;
true
gap> DigraphEdges(ReducedDigraph(Digraph(IsMutableDigraph, [[2], []])));
[ [ 1, 2 ] ]
gap> gr := Digraph([[2, 4, 2, 6, 1], [], [], [2, 1, 4], [],
> [1, 7, 7, 7], [4, 6]]);
<immutable multidigraph with 7 vertices, 14 edges>
gap> rd := ReducedDigraph(gr);
<immutable multidigraph with 5 vertices, 14 edges>
gap> DigraphVertexLabels(rd);
[ 1, 2, 4, 6, 7 ]
gap> gr := CompleteDigraph(10);
<immutable complete digraph with 10 vertices>
gap> rd := ReducedDigraph(gr);
<immutable complete digraph with 10 vertices>
gap> rd = gr;
true
gap> DigraphVertexLabels(gr) = DigraphVertexLabels(rd);
true
gap> gr := Digraph([[], [4, 2], [], [3]]);
<immutable digraph with 4 vertices, 3 edges>
gap> SetDigraphVertexLabels(gr, ["one", "two", "three", "four"]);
gap> rd := ReducedDigraph(gr);
<immutable digraph with 3 vertices, 3 edges>
gap> DigraphVertexLabels(gr);
[ "one", "two", "three", "four" ]
gap> DigraphVertexLabels(rd);
[ "two", "three", "four" ]
gap> gr := Digraph([[], [4, 2], [], [3]]);
<immutable digraph with 4 vertices, 3 edges>
gap> SetDigraphEdgeLabels(gr, [[], ["a", "b"], [], ["c"]]);
gap> rd := ReducedDigraph(gr);
<immutable digraph with 3 vertices, 3 edges>
gap> DigraphEdgeLabels(gr);
[ [  ], [ "a", "b" ], [  ], [ "c" ] ]
gap> DigraphEdgeLabels(rd);
[ [ "a", "b" ], [  ], [ "c" ] ]

#  DigraphAllSimpleCircuits
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
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphAllSimpleCircuits(gr);
[ [ 1, 2 ] ]
gap> gr := Digraph([[], [3], [2, 4], [5, 4], [4]]);
<immutable digraph with 5 vertices, 6 edges>
gap> DigraphAllSimpleCircuits(gr);
[ [ 4 ], [ 4, 5 ], [ 2, 3 ] ]
gap> gr := Digraph([[], [], [], [4], [], [], [8], [7]]);
<immutable digraph with 8 vertices, 3 edges>
gap> DigraphAllSimpleCircuits(gr);
[ [ 4 ], [ 7, 8 ] ]
gap> gr := Digraph([[1, 2], [2, 1]]);
<immutable digraph with 2 vertices, 4 edges>
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

#  DigraphAllUndirectedSimpleCircuits
gap> gr := Digraph([]);;
gap> DigraphAllUndirectedSimpleCircuits(gr);
[  ]
gap> gr := ChainDigraph(4);;
gap> DigraphAllUndirectedSimpleCircuits(gr);
[  ]
gap> gr := CompleteDigraph(2);;
gap> DigraphAllUndirectedSimpleCircuits(gr);
[  ]
gap> gr := CompleteDigraph(3);;
gap> DigraphAllUndirectedSimpleCircuits(gr);
[ [ 1, 2, 3 ] ]
gap> gr := Digraph([[], [3], [2, 4], [5, 4], [4]]);
<immutable digraph with 5 vertices, 6 edges>
gap> DigraphAllUndirectedSimpleCircuits(gr);
[ [ 4 ] ]
gap> gr := Digraph([[1, 2], [2, 1]]);
<immutable digraph with 2 vertices, 4 edges>
gap> DigraphAllUndirectedSimpleCircuits(gr);
[ [ 1 ], [ 2 ] ]
gap> gr := Digraph([[4], [1, 3], [1, 2], [2, 3]]);;
gap> DigraphAllUndirectedSimpleCircuits(gr);
[ [ 1, 2, 3 ], [ 1, 2, 3, 4 ], [ 1, 2, 4 ], [ 1, 2, 4, 3 ], [ 1, 3, 2, 4 ], 
  [ 1, 3, 4 ], [ 2, 3, 4 ] ]
gap> gr := Digraph([[3, 6, 7], [3, 6, 8], [1, 2, 3, 6, 7, 8],
> [2, 3, 4, 8], [2, 3, 4, 5, 6, 7], [1, 3, 4, 5, 7], [2, 3, 6, 8],
> [1, 2, 3, 8]]);;
gap> Length(DigraphAllUndirectedSimpleCircuits(gr));
1330

# DigraphAllChordlessCycles
gap> gr := Digraph([]);;
gap> DigraphAllChordlessCycles(gr);
[  ]
gap> gr := ChainDigraph(4);;
gap> DigraphAllChordlessCycles(gr);
[  ]
gap> D := CycleDigraph(3);;
gap> DigraphAllChordlessCycles(D);
[ [ 2, 1, 3 ] ]
gap> D := CompleteDigraph(4);;
gap> DigraphAllChordlessCycles(D);
[ [ 2, 1, 3 ], [ 2, 1, 4 ], [ 3, 1, 4 ], [ 3, 2, 4 ] ]
gap> D := Digraph([[2, 4, 5], [3, 6], [4, 7], [8], [6, 8], [7], [8], []]);;
gap> DigraphAllChordlessCycles(D);
[ [ 6, 5, 8, 7 ], [ 3, 4, 8, 5, 6, 2 ], [ 3, 4, 8, 7 ], [ 1, 4, 8, 5 ], 
  [ 1, 4, 8, 7, 6, 2 ], [ 1, 4, 3, 2 ], [ 1, 4, 3, 7, 6, 5 ], [ 3, 2, 6, 7 ], 
  [ 2, 1, 5, 6 ], [ 2, 1, 5, 8, 7, 3 ] ]

#  Issue #676
gap> D := Digraph([[], [3], []]);;
gap> SetDigraphVertexLabels(D, ["one", "two", "three"]);
gap> DigraphAllSimpleCircuits(D);
[  ]

#  DigraphLongestSimpleCircuit
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

#  AsTransformation
gap> gr := Digraph([[2], [1, 3], [4], [3]]);;
gap> AsTransformation(gr);
fail
gap> gr := AsDigraph(Transformation([1, 1, 1]), 5);
<immutable functional digraph with 5 vertices>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 2, 1 ], [ 3, 1 ], [ 4, 4 ], [ 5, 5 ] ]
gap> AsTransformation(gr);
Transformation( [ 1, 1, 1 ] )

#  DigraphBicomponents
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

#  DigraphLoops
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
<immutable digraph with 6 vertices, 18 edges>
gap> DigraphLoops(gr);
[ 1, 3, 4 ]

#  Out/InDegreeSequence with known automorphsims and sets
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

#  Diameter and UndirectedGirth with known automorphisms
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
gap> gr := DigraphSymmetricClosure(DigraphAddEdge(CycleDigraph(7), 1, 2));;
gap> IsMultiDigraph(gr);
true
gap> SetDigraphGroup(gr, Group((1, 2)(3, 7)(4, 6)));
gap> DigraphDiameter(gr);
3
gap> DigraphUndirectedGirth(gr);
2
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
<immutable multidigraph with 5 vertices, 12 edges>
gap> DigraphDiameter(gr);
4
gap> DigraphUndirectedGirth(gr);
2
gap> gr := EmptyDigraph(0);;
gap> DigraphUndirectedGirth(gr);
infinity
gap> DigraphDiameter(gr);
fail

#  DigraphBooleanAdjacencyMatrix
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

#  DigraphUndirectedGirth: easy cases
gap> gr := Digraph([[2], [3], []]);;
gap> DigraphUndirectedGirth(gr);
Error, the argument <D> must be a symmetric digraph,
gap> gr := Digraph([[2], [1, 3], [2, 3]]);;
gap> DigraphUndirectedGirth(gr);
1
gap> gr := Digraph([[2, 2], [1, 1, 3], [2]]);;
gap> DigraphUndirectedGirth(gr);
2

#  DigraphGirth
gap> gr := Digraph([[1], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphGirth(gr);
1
gap> gr := Digraph([[2, 3], [3], [4], []]);
<immutable digraph with 4 vertices, 4 edges>
gap> DigraphGirth(gr);
infinity
gap> gr := Digraph([[2, 3], [3], [4], [1]]);
<immutable digraph with 4 vertices, 5 edges>
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
Error, the argument <D> must be a symmetric digraph,

# DigraphOddGirth
gap> gr := Digraph([[2, 3], [3], [1]]);
<immutable digraph with 3 vertices, 4 edges>
gap> DigraphOddGirth(gr);
3
gap> gr := Digraph([[2], [3], [], [3], [4]]);
<immutable digraph with 5 vertices, 4 edges>
gap> DigraphOddGirth(gr);
infinity
gap> gr := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> DigraphOddGirth(gr);
1
gap> gr := Digraph([[2], []]);
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphOddGirth(gr);
infinity
gap> gr := CycleDigraph(4);
<immutable cycle digraph with 4 vertices>
gap> DigraphOddGirth(gr);
infinity
gap> gr := DigraphDisjointUnion(CycleDigraph(2), CycleDigraph(3));;
gap> for i in [1 .. 50] do
> gr := DigraphDisjointUnion(gr, CycleDigraph(3));
> od;
gap> DigraphOddGirth(gr);
3
gap> G := Digraph(IsMutableDigraph, [[]]);
<mutable empty digraph with 1 vertex>
gap> for i in [2 .. 200] do
>   DigraphAddVertex(G, i);
>   DigraphAddEdges(G, [[1, i], [i, 1]]);
> od;
gap> D := CycleDigraph(IsMutableDigraph, 7);
<mutable digraph with 7 vertices, 7 edges>
gap> for i in [1 .. 10] do
>   DigraphDisjointUnion(D, G);
> od;
gap> DigraphOddGirth(D);
7
gap> D := DigraphFromDigraph6String("&IWsC_A?_PG_GDKC?cO");
<immutable digraph with 10 vertices, 22 edges>
gap> DigraphGirth(D);
2
gap> DigraphOddGirth(D);
3

# DigraphMycielskian
gap> D1 := DigraphSymmetricClosure(CycleDigraph(2));
<immutable cycle digraph with 2 vertices>
gap> D2 := DigraphSymmetricClosure(CycleDigraph(5));
<immutable symmetric digraph with 5 vertices, 10 edges>
gap> IsIsomorphicDigraph(DigraphMycielskian(D1), D2);
true
gap> D := DigraphSymmetricClosure(CayleyDigraph(DihedralGroup(8)));
<immutable symmetric digraph with 8 vertices, 32 edges>
gap> ChromaticNumber(D);
4
gap> D := DigraphMycielskian(D);
<immutable digraph with 17 vertices, 112 edges>
gap> ChromaticNumber(D);
5
gap> D1 := Digraph([[], [3], [2]]);
<immutable digraph with 3 vertices, 2 edges>
gap> D2 := Digraph([[], [3, 4], [2, 5], [2, 6], [3, 6], [4, 5, 7], [6]]);
<immutable digraph with 7 vertices, 12 edges>
gap> IsIsomorphicDigraph(DigraphMycielskian(D1), D2);
true
gap> D := DigraphSymmetricClosure(CycleDigraph(5));
<immutable symmetric digraph with 5 vertices, 10 edges>
gap> D := DigraphMutableCopy(D);
<mutable digraph with 5 vertices, 10 edges>
gap> DigraphMycielskian(D);
<mutable digraph with 11 vertices, 40 edges>
gap> D := DigraphSymmetricClosure(Digraph([[1, 2], [1]]));
<immutable symmetric digraph with 2 vertices, 3 edges>
gap> D := DigraphMutableCopy(D);
<mutable digraph with 2 vertices, 3 edges>
gap> DigraphMycielskian(D);
<mutable digraph with 5 vertices, 13 edges>
gap> D := DigraphEdgeUnion(CycleDigraph(3), CycleDigraph(3));
<immutable multidigraph with 3 vertices, 6 edges>
gap> DigraphMycielskian(D);
Error, the argument <D> must be a symmetric digraph with no multiple edges,
gap> DigraphMycielskian(DigraphMutableCopy(D));
Error, the argument <D> must be a symmetric digraph with no multiple edges,
gap> D := DigraphEdgeUnion(CompleteDigraph(3), CompleteDigraph(3));
<immutable multidigraph with 3 vertices, 12 edges>
gap> DigraphMycielskian(D);
Error, the argument <D> must be a symmetric digraph with no multiple edges,
gap> DigraphMycielskian(DigraphMutableCopy(D));
Error, the argument <D> must be a symmetric digraph with no multiple edges,

#  DigraphDegeneracy and DigraphDegeneracyOrdering
gap> gr := Digraph([[2, 2], [1, 1]]);;
gap> IsMultiDigraph(gr) and IsSymmetricDigraph(gr);
true
gap> DigraphDegeneracy(gr);
Error, the argument <D> must be a symmetric digraph with no multiple edges,
gap> DigraphDegeneracyOrdering(gr);
Error, the argument <D> must be a symmetric digraph with no multiple edges,
gap> gr := Digraph([[2], []]);
<immutable digraph with 2 vertices, 1 edge>
gap> not IsMultiDigraph(gr) and not IsSymmetricDigraph(gr);
true
gap> DigraphDegeneracy(gr);
Error, the argument <D> must be a symmetric digraph with no multiple edges,
gap> DigraphDegeneracyOrdering(gr);
Error, the argument <D> must be a symmetric digraph with no multiple edges,
gap> gr := CompleteDigraph(5);;
gap> DigraphDegeneracy(gr);
4
gap> DigraphDegeneracyOrdering(gr);
[ 5, 4, 3, 2, 1 ]
gap> gr := DigraphSymmetricClosure(ChainDigraph(4));
<immutable symmetric digraph with 4 vertices, 6 edges>
gap> DigraphDegeneracy(gr);
1
gap> DigraphDegeneracyOrdering(gr);
[ 4, 3, 2, 1 ]
gap> gr := Digraph([[3], [], [1]]);
<immutable digraph with 3 vertices, 2 edges>
gap> DigraphDegeneracy(gr);
1
gap> gr := DigraphSymmetricClosure(Digraph(
> [[2, 5], [3, 5], [4], [5, 6], [], []]));
<immutable symmetric digraph with 6 vertices, 14 edges>
gap> DigraphDegeneracy(gr);
2
gap> DigraphDegeneracyOrdering(gr);
[ 6, 4, 3, 2, 5, 1 ]

#  DigraphGirth with known automorphisms
gap> gr := Digraph([[2, 3, 4, 5], [6, 3], [6, 2], [6], [6], [1]]);;
gap> DigraphGirth(gr);
2
gap> gr := Digraph([[2, 3, 4, 5], [6, 3], [6, 2], [6], [6], [1]]);;
gap> DigraphGroup(gr) = Group([(4, 5), (2, 3)]);
true
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

#  MaximalSymmetricSubdigraph and MaximalSymmetricSubdigraphWithoutLoops
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
<immutable digraph with 4 vertices, 6 edges>
gap> IsSymmetricDigraph(gr);
false
gap> gr2 := MaximalSymmetricSubdigraph(gr);
<immutable symmetric digraph with 4 vertices, 3 edges>
gap> OutNeighbours(gr2);
[ [ 2 ], [ 1 ], [  ], [ 4 ] ]
gap> gr2 := MaximalSymmetricSubdigraphWithoutLoops(gr);
<immutable symmetric digraph with 4 vertices, 2 edges>
gap> OutNeighbours(gr2);
[ [ 2 ], [ 1 ], [  ], [  ] ]
gap> gr := Digraph([[2, 2], [1, 1]]);
<immutable multidigraph with 2 vertices, 4 edges>
gap> gr2 := MaximalSymmetricSubdigraphWithoutLoops(gr);
<immutable symmetric digraph with 2 vertices, 2 edges>
gap> OutNeighbours(gr2);
[ [ 2 ], [ 1 ] ]
gap> gr := Digraph([[1, 2, 2], [1, 1]]);
<immutable multidigraph with 2 vertices, 5 edges>
gap> IsSymmetricDigraph(gr);
true
gap> gr3 := MaximalSymmetricSubdigraphWithoutLoops(gr);
<immutable symmetric digraph with 2 vertices, 2 edges>
gap> gr2 = gr3;
true
gap> gr := Digraph([[2, 3], [1], [1, 3]]);
<immutable digraph with 3 vertices, 5 edges>
gap> IsSymmetricDigraph(gr);
true
gap> gr := MaximalSymmetricSubdigraphWithoutLoops(gr);
<immutable symmetric digraph with 3 vertices, 4 edges>
gap> OutNeighbours(gr);
[ [ 2, 3 ], [ 1 ], [ 1 ] ]
gap> D := Digraph(IsImmutableDigraph, [[2, 2], [1]]);
<immutable multidigraph with 2 vertices, 3 edges>
gap> DigraphRemoveAllMultipleEdges(D);;
gap> HasDigraphRemoveAllMultipleEdgesAttr(D);
true
gap> IsCompleteDigraph(MaximalSymmetricSubdigraph(D));
true

#  RepresentativeOutNeighbours
gap> gr := CycleDigraph(5);
<immutable cycle digraph with 5 vertices>
gap> RepresentativeOutNeighbours(gr);
[ [ 2 ] ]
gap> DigraphOrbitReps(gr);
[ 1 ]
gap> gr := Digraph([[2], [3], []]);
<immutable digraph with 3 vertices, 2 edges>
gap> RepresentativeOutNeighbours(gr);
[ [ 2 ], [ 3 ], [  ] ]

#  DigraphAdjacencyFunction
gap> gr := Digraph([[1, 3], [2], []]);
<immutable digraph with 3 vertices, 3 edges>
gap> adj := DigraphAdjacencyFunction(gr);
function( u, v ) ... end
gap> adj(1, 1);
true
gap> adj(3, 1);
false
gap> adj(2, 7);
false

#  Test ChromaticNumber
gap> ChromaticNumber(Digraph([[1]]));
Error, the argument <D> must be a digraph with no loops,
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
Transformation( [ 2, 2, 3, 1, 2, 1, 2, 3, 2, 1 ] )
gap> ChromaticNumber(DigraphDisjointUnion(CompleteDigraph(1),
> Digraph([[2], [4], [1, 2], [3]])));
3
gap> ChromaticNumber(DigraphDisjointUnion(CompleteDigraph(1),
> Digraph([[2], [4], [1, 2], [3], [1, 2, 3]])));
4
gap> gr := DigraphFromDigraph6String(Concatenation(
> "&l??O?C?A_@???CE????GAAG?C??M?????@_?OO??G??@?IC???_C?G?o??C?AO???c_??A?",
> "A?S???OAA???OG???G_A??C?@?cC????_@G???S??C_?C???[??A?A?OA?O?@?A?@A???GGO",
> "??`?_O??G?@?A??G?@AH????AA?O@??_??b???Cg??C???_??W?G????d?G?C@A?C???GC?W",
> "?????K???__O[??????O?W???O@??_G?@?CG??G?@G?C??@G???_Q?O?O?c???OAO?C??C?G",
> "?O??A@??D??G?C_?A??O?_GA??@@?_?G???E?IW??????_@G?C??"));
<immutable digraph with 45 vertices, 180 edges>
gap> ChromaticNumber(gr);
3
gap> DigraphColouring(gr, 3);
Transformation( [ 1, 2, 1, 2, 3, 2, 1, 1, 1, 2, 2, 1, 2, 3, 3, 1, 1, 1, 2, 1,
  2, 2, 3, 3, 3, 1, 1, 2, 3, 3, 3, 2, 3, 2, 3, 2, 3, 1, 2, 1, 3, 1, 2, 3,
  3 ] )
gap> DigraphColouring(gr, 2);
fail
gap> DigraphGreedyColouring(gr);
Transformation( [ 1, 1, 1, 1, 1, 2, 2, 1, 2, 2, 2, 1, 1, 2, 1, 2, 1, 2, 2, 3,
  3, 2, 3, 3, 3, 2, 1, 4, 4, 2, 3, 3, 3, 3, 3, 1, 3, 4, 4, 3, 2, 1, 4, 3,
  1 ] )
gap> gr := Digraph([[2, 3, 4], [3], [], []]);
<immutable digraph with 4 vertices, 4 edges>
gap> ChromaticNumber(gr);
3
gap> ChromaticNumber(EmptyDigraph(0));
0
gap> gr := CompleteDigraph(4);;
gap> gr := DigraphAddVertex(gr);;
gap> ChromaticNumber(gr);
4
gap> gr := DigraphFromDiSparse6String(Concatenation(
> ".~?C?_O?WF?MD?L`[DgX?}@oX`o?W^?}Fgb@mHOTa_?Od`ODOd`}EGnA?HW]`?IGfaULOLak",
> "LGA?sBoYAiMOt`[Lw_AGJWP`WHGs_gNWSBIMGF@oKhCASIWxc[BWUAgLGY@uFhKAY?OBBuRp",
> "EdGH_i_cDOaDEHGf_{COdcQNw|DEV?MCuPG`ASUhH`[I@ADqKOqEAHOiCiTgT`gNPSaWSgNB",
> "iSGTAeLpIcwS@SD[YGeE]L@UbGVGNBwSGE@_M@^`SHotBi[oBBOXH^_SEou_oG?sB[UGeA{\\",
> "Gq_CBo`AgK@WDeHPNE_[wXeq@oXDuGP\\aSIo{bK^hC`WJp`fMC_bEW\\G`AOK`[E_^iFF}IOy",
> "CMapZ_?BoWAw[@vGeN?~CKZGNBcPPwaOH_rD{ax?DKXAD_[P`u_CLISCsUgaAkbwKAKMGTAK",
> "O`BCgZQO_oT@T_oB_kB?[YTHaCoYA?OPkF?dGKEk\\ACHmAodAcL`RHiJPYDmW`jFYFpba_Pq",
> "MH[gGE@CJovE[aH}HUXa^e?ZWFA_I`jb?PpOF}?OODwXqRa?MGQCSRq___CoiCoVgOAcKOvE",
> "qQGBA{UQh`gG@YEkZh|akU@XGofaeIaYpsF{fwB?wCPKC{^q]_I@piJAMphEk_aB_KF`[D{X",
> "PngMJaCjkL`FHcgAw`{MPMDWkghB_W@sIAH`oH{jAzc{TPwHOjA|_WD_yC?TQ^ew[AQHwhap",
> "bKda`JUDo_G[hw[@{_aMc?P@JGOewPECXq[IGobB_cNbBa[XQBICjqs_gO`NDWhqoJMC_SAM",
> "CoYAWKpUIYFqj_?BpXEG[q?JCoycdygw|FGgqpaKK_vCC]A@Gskr@ao^AP_sG@EEwZqZISjw",
> "CIU?_iDOXP}JCogsKKpBEdKdxWE]V`gJksbS_?@_JGGaaxLiGOcBWTAt_KJ_tBoeXzG{oI?H",
> "[iRTL]GwK@STqLIoqG\\AwKp`ESfwaCOVPyGK`BK_GHowFoabPc[YPuGkmbR`?ZrIm_BOOFIA",
> "_\\HGjgKBGP`QEGWqjJ_nBSdwYrXMeK@mGweg?CCPG?FobrDMaEPUFo`bl`sQ`qHMU@^EC[aT",
> "HsrWFCCQ@IDSbROLWugPKOsW?Akhr[akL`\\FK`aFKmGQq`wS`dF_]apKeCp`Fg`qRL_yRl`S",
> "|goGG`h@JOlrnaSXq_LWwrs_oJ`?CKSqMIu^ry_WOqGHWtk?_G?GF?EB?B_{AgB_MD?A`MDo",
> "U`kAgG@KEwK?sCOR`]AOQaW?gU_kBGiAaDOX_CH_gawD_hb???SbGEGWbMCgG@cE__AaM?v_",
> "oE_paSHwV_SDw}?sHgF@]OOW@cLgCcOCOdAaC?kc_JhJByBgec{F_i_cD_l_ARwI?kDpPawK",
> "@J`?TG??SEomd_NxY?C@h[A?KgcASI`Yce?OF?cFOgbWSGi_gIPPDYQGdacI_yEINpWcGPPK",
> "__AO^BsRwL?{MwmB?QPR`yR`QEiRxH`SE?^`CC_l`oPgMA?Uhs?}A`j`KD?bCOXW`Ck[@ueA",
> "B?vDMJ_vEeM@kEyNp@fwCpi`OD`beYKPlFeK@WEk^IC?gBoRBoWHiFaKqBfmMpCDOVg`CORg",
> "KB?Xa@_SYP{fC`x`EW]GbaeYiQAaHhVEq[AOh[M@PF[]QF_WBogB?NpoFUA?pBOYgMD_VaP_",
> "WGpFE?`HGEmV``aCKpLDmPpjGmgPDDGUPz_oD`CHY?PK`cF@CaC`GRCOS@~bcW@xF}B?mGKa",
> "WK@oNO~CWU`wdKV@kGAB_VASKpgFoeWC?sD@gEkaAa_sEO~EW]`}IUK?{H{hH?D_^qHGkbQf",
> "_oJ@kGCdQdf[_wpBwRpRE?Z`x`GGpXDg^gL?wL@FGOiWRAOXAUJEIPgFQI@rGiN`OFcex|HW",
> "eqv`WE?_AsU`}fi@oZAOSa@__]QQJ]C@LGocWbA[RPMDO^qBa[O@NDUVQBGWhGZF?`aHIsjw",
> "HCGdXkFKaQwa?L@hGWjwqC?Yq[KUAPyGK`aqe[cyw_oH@GD{\\xjF}C`]EkbaPJAI?tC?YQ@_",
> "KO@bKm??RE_^Q}_WRAAHULpCC_\\AGKm?PeFS\\qyKmBoOIopBEKqAQCHSsi^LEMgF@olQuLQC",
> "@OHotwUEEuoPA{^A_K?pw`CG[@tHYH`a_sO`BCo`a__SCp]IspxGI?nrSdCdbILiCOsJStiZ",
> "JeDOqC?PaPHYC?jDSXR^hOpwTA_UQOHggG?@yK@@C_\\rEbwRQHKYG?aA[N`HK}A?gCKVwSAQ",
> "??mFEIpLFoiHZGWgqiLaK`wFsrILLmSQ[KC{XhGyVPnHoubdaoS`]D{lrl`WG?nB?QPPEwyg",
> "JD?Ta@Io|GX@wG@lHkkbYaCHOoJgrWqGkmRCL_wWIBo[AFIgpbZ_kQ`~IKlrD`GD_sGoewiB",
> "?QaKJr"));
<immutable digraph with 256 vertices, 1371 edges>
gap> gr := DigraphDisjointUnion(gr, CompleteDigraph(5));
<immutable digraph with 261 vertices, 1391 edges>
gap> ChromaticNumber(gr);
5
gap> gr := Digraph([[2, 4, 7, 3], [3, 5, 8, 1], [1, 6, 9, 2],
> [5, 7, 1, 6], [6, 8, 2, 4], [4, 9, 3, 5], [8, 1, 4, 9], [9, 2, 5, 7],
> [7, 3, 6, 8]]);;
gap> ChromaticNumber(gr);
3
gap> gr := DigraphSymmetricClosure(ChainDigraph(5));
<immutable symmetric digraph with 5 vertices, 8 edges>
gap> DigraphGreedyColouring(gr);;
gap> ChromaticNumber(gr);
2
gap> gr := DigraphFromGraph6String("KmKk~K??G@_@");
<immutable symmetric digraph with 12 vertices, 42 edges>
gap> ChromaticNumber(gr);
4
gap> gr := CycleDigraph(7);
<immutable cycle digraph with 7 vertices>
gap> ChromaticNumber(gr);
3
gap> gr := CycleDigraph(71);
<immutable cycle digraph with 71 vertices>
gap> ChromaticNumber(gr);
3
gap> gr := CycleDigraph(1001);
<immutable cycle digraph with 1001 vertices>
gap> ChromaticNumber(gr);
3
gap> a := DigraphRemoveEdges(CompleteDigraph(50), [[1, 2], [2, 1]]);;
gap> b := DigraphAddVertex(a);;
gap> ChromaticNumber(a);
49
gap> ChromaticNumber(b);
49
gap> D := DigraphFromGraph6String("ElNG");
<immutable symmetric digraph with 6 vertices, 18 edges>
gap> ChromaticNumber(D);
3
gap> IsSymmetricDigraph(D) and IsRegularDigraph(D) and OutDegreeSet(D) = [3];
true
gap> IsBiconnectedDigraph(D);
true
gap> D := Digraph(OutNeighbours(CycleDigraph(13)));;
gap> ChromaticNumber(D);
3

#  Test ChromaticNumber Lawler
gap> ChromaticNumber(NullDigraph(10) : lawler);
1
gap> ChromaticNumber(CompleteDigraph(10) : lawler);
10
gap> ChromaticNumber(CompleteBipartiteDigraph(5, 5) : lawler);
2
gap> ChromaticNumber(DigraphRemoveEdge(CompleteDigraph(10), [1, 2]) : lawler);
10
gap> ChromaticNumber(Digraph([[4, 8], [6, 10], [9], [2, 3, 9], [],
> [3], [4], [6], [], [5, 7]]) : lawler);
3
gap> ChromaticNumber(DigraphDisjointUnion(CompleteDigraph(1),
> Digraph([[2], [4], [1, 2], [3]])) : lawler);
3
gap> ChromaticNumber(DigraphDisjointUnion(CompleteDigraph(1),
> Digraph([[2], [4], [1, 2], [3], [1, 2, 3]])) : lawler);
4
gap> gr := Digraph([[2, 3, 4], [3], [], []]);
<immutable digraph with 4 vertices, 4 edges>
gap> ChromaticNumber(gr : lawler);
3
gap> ChromaticNumber(EmptyDigraph(0) : lawler);
0
gap> gr := CompleteDigraph(4);;
gap> gr := DigraphAddVertex(gr);;
gap> ChromaticNumber(gr : lawler);
4
gap> gr := Digraph([[2, 4, 7, 3], [3, 5, 8, 1], [1, 6, 9, 2],
> [5, 7, 1, 6], [6, 8, 2, 4], [4, 9, 3, 5], [8, 1, 4, 9], [9, 2, 5, 7],
> [7, 3, 6, 8]]);;
gap> ChromaticNumber(gr : lawler);
3
gap> gr := DigraphSymmetricClosure(ChainDigraph(5));
<immutable symmetric digraph with 5 vertices, 8 edges>
gap> ChromaticNumber(gr : lawler);
2
gap> gr := DigraphFromGraph6String("KmKk~K??G@_@");
<immutable symmetric digraph with 12 vertices, 42 edges>
gap> ChromaticNumber(gr : lawler);
4
gap> gr := CycleDigraph(7);
<immutable cycle digraph with 7 vertices>
gap> ChromaticNumber(gr : lawler);
3
gap> ChromaticNumber(gr : lawler);
3
gap> ChromaticNumber(gr : lawler);
3

#  Test ChromaticNumber Byskov
gap> ChromaticNumber(NullDigraph(10) : byskov);
1
gap> ChromaticNumber(CompleteDigraph(10) : byskov);
10
gap> ChromaticNumber(CompleteBipartiteDigraph(5, 5) : byskov);
2
gap> ChromaticNumber(DigraphRemoveEdge(CompleteDigraph(10), [1, 2]) : byskov);
10
gap> ChromaticNumber(Digraph([[4, 8], [6, 10], [9], [2, 3, 9], [],
> [3], [4], [6], [], [5, 7]]) : byskov);
3
gap> ChromaticNumber(DigraphDisjointUnion(CompleteDigraph(1),
> Digraph([[2], [4], [1, 2], [3]])) : byskov);
3
gap> ChromaticNumber(DigraphDisjointUnion(CompleteDigraph(1),
> Digraph([[2], [4], [1, 2], [3], [1, 2, 3]])) : byskov);
4
gap> gr := Digraph([[2, 3, 4], [3], [], []]);
<immutable digraph with 4 vertices, 4 edges>
gap> ChromaticNumber(gr : byskov);
3
gap> ChromaticNumber(EmptyDigraph(0) : byskov);
0
gap> gr := CompleteDigraph(4);;
gap> gr := DigraphAddVertex(gr);;
gap> ChromaticNumber(gr : byskov);
4
gap> gr := Digraph([[2, 4, 7, 3], [3, 5, 8, 1], [1, 6, 9, 2],
> [5, 7, 1, 6], [6, 8, 2, 4], [4, 9, 3, 5], [8, 1, 4, 9], [9, 2, 5, 7],
> [7, 3, 6, 8]]);;
gap> ChromaticNumber(gr : byskov);
3
gap> gr := DigraphSymmetricClosure(ChainDigraph(5));
<immutable symmetric digraph with 5 vertices, 8 edges>
gap> ChromaticNumber(gr : byskov);
2
gap> gr := DigraphFromGraph6String("KmKk~K??G@_@");
<immutable symmetric digraph with 12 vertices, 42 edges>
gap> ChromaticNumber(gr : byskov);
4
gap> gr := CycleDigraph(7);
<immutable cycle digraph with 7 vertices>
gap> ChromaticNumber(gr : byskov);
3
gap> ChromaticNumber(gr : byskov);
3
gap> ChromaticNumber(gr : byskov);
3

# Extra tests for under three colourable check
gap> DIGRAPHS_UnderThreeColourable(Digraph([[1]]));
Error, the argument <D> must be a digraph with no loops,
gap> DIGRAPHS_UnderThreeColourable(EmptyDigraph(0));
0

#  DegreeMatrix
gap> gr := Digraph([[2, 3, 4], [2, 5], [1, 5, 4], [1], [1, 1, 2, 4]]);;
gap> DegreeMatrix(gr);
[ [ 3, 0, 0, 0, 0 ], [ 0, 2, 0, 0, 0 ], [ 0, 0, 3, 0, 0 ], [ 0, 0, 0, 1, 0 ], 
  [ 0, 0, 0, 0, 4 ] ]
gap> DegreeMatrix(Digraph([]));
[  ]
gap> DegreeMatrix(Digraph([[]]));
[ [ 0 ] ]
gap> DegreeMatrix(Digraph([[1]]));
[ [ 1 ] ]

#  LaplacianMatrix
gap> gr := Digraph([[2, 3, 4], [2, 5], [1, 5, 4], [1], [1, 1, 2, 4]]);;
gap> LaplacianMatrix(gr);
[ [ 3, -1, -1, -1, 0 ], [ 0, 1, 0, 0, -1 ], [ -1, 0, 3, -1, -1 ], 
  [ -1, 0, 0, 1, 0 ], [ -2, -1, 0, -1, 4 ] ]
gap> LaplacianMatrix(Digraph([]));
[  ]
gap> LaplacianMatrix(Digraph([[1]]));
[ [ 0 ] ]
gap> LaplacianMatrix(CycleDigraph(5));
[ [ 1, -1, 0, 0, 0 ], [ 0, 1, -1, 0, 0 ], [ 0, 0, 1, -1, 0 ], 
  [ 0, 0, 0, 1, -1 ], [ -1, 0, 0, 0, 1 ] ]
gap> LaplacianMatrix(CompleteDigraph(5));
[ [ 4, -1, -1, -1, -1 ], [ -1, 4, -1, -1, -1 ], [ -1, -1, 4, -1, -1 ], 
  [ -1, -1, -1, 4, -1 ], [ -1, -1, -1, -1, 4 ] ]

#  NrSpanningTrees
gap> NrSpanningTrees(CompleteDigraph(5));
125
gap> NrSpanningTrees(CycleDigraph(5));
Error, the argument <D> must be a symmetric digraph,
gap> NrSpanningTrees(DigraphSymmetricClosure(CycleDigraph(5)));
5
gap> NrSpanningTrees(Digraph([]));
0
gap> NrSpanningTrees(Digraph([[1]]));
1
gap> NrSpanningTrees(Digraph([[2, 3, 4], [1, 5], [1, 5], [1, 5], [2, 3, 4]]));
12

#  UndirectedSpanningTree and UndirectedSpanningForest
gap> gr := EmptyDigraph(0);
<immutable empty digraph with 0 vertices>
gap> tree := UndirectedSpanningTree(gr);
fail
gap> forest := UndirectedSpanningForest(gr);
fail
gap> UndirectedSpanningForest(EmptyDigraph(IsMutableDigraph, 0));
fail
gap> UndirectedSpanningTree(ChainDigraph(IsMutableDigraph, 4));
fail
gap> gr := EmptyDigraph(1);
<immutable empty digraph with 1 vertex>
gap> tree := UndirectedSpanningTree(gr);
<immutable empty digraph with 1 vertex>
gap> forest := UndirectedSpanningForest(gr);
<immutable empty digraph with 1 vertex>
gap> IsUndirectedSpanningTree(gr, gr);
true
gap> IsUndirectedSpanningTree(gr, forest);
true
gap> gr = forest;
true
gap> gr := EmptyDigraph(2);
<immutable empty digraph with 2 vertices>
gap> tree := UndirectedSpanningTree(gr);
fail
gap> forest := UndirectedSpanningForest(gr);
<immutable empty digraph with 2 vertices>
gap> IsUndirectedTree(forest);
false
gap> IsUndirectedSpanningForest(gr, forest);
true
gap> gr = forest;
true
gap> gr := DigraphFromDigraph6String("&IG@qqW?HO?BSQGA?CG");
<immutable digraph with 10 vertices, 23 edges>
gap> IsStronglyConnectedDigraph(gr);
true
gap> UndirectedSpanningTree(gr);
fail
gap> UndirectedSpanningTree(gr);
fail
gap> DigraphEdges(UndirectedSpanningForest(gr));
[ [ 2, 7 ], [ 7, 2 ] ]
gap> DigraphEdges(UndirectedSpanningForest(gr));
[ [ 2, 7 ], [ 7, 2 ] ]
gap> IsUndirectedSpanningForest(gr, UndirectedSpanningForest(gr));
true
gap> D := DigraphFromDigraph6String("&I~~~~^Znn~|~~x^|v{");
<immutable digraph with 10 vertices, 89 edges>
gap> tree := UndirectedSpanningTree(D);
<immutable undirected tree digraph with 10 vertices>
gap> IsUndirectedSpanningTree(D, tree);
true
gap> tree := UndirectedSpanningTree(DigraphMutableCopy(D));
<mutable digraph with 10 vertices, 18 edges>
gap> IsUndirectedSpanningTree(D, tree);
true

# ArticulationPoints
gap> ArticulationPoints(CycleDigraph(5));
[  ]
gap> StrongOrientation(DigraphSymmetricClosure(CycleDigraph(5)))
> = CycleDigraph(5);
true
gap> ArticulationPoints(Digraph([[2, 7], [3, 5], [4], [2], [6], [1], []]));
[ 2, 1 ]
gap> StrongOrientation(Digraph([[2, 7], [3, 5], [4], [2], [6], [1], []]));
Error, not yet implemented
gap> ArticulationPoints(ChainDigraph(5));
[ 4, 3, 2 ]
gap> StrongOrientation(ChainDigraph(5));
Error, not yet implemented
gap> ArticulationPoints(NullDigraph(5));
[  ]
gap> StrongOrientation(NullDigraph(5));
fail
gap> gr :=
> Digraph([[35, 55, 87], [38], [6, 53], [], [66], [56], [36], []
> , [], [19], [23], [], [40, 76], [72, 79], [46, 48], [22, 68], [
> 26], [17, 60], [17], [42], [34, 91], [68, 87], [14, 46], [23, 80
> ], [6, 8], [], [], [], [], [], [28, 35], [], [18, 40, 94], [], [
>  27, 44, 78], [], [25], [71], [72], [2, 33], [87], [], [42], [
> ], [43], [63], [], [58, 89], [68, 97], [24, 40], [13], [9], [
> 44], [80], [], [40], [78], [9], [], [35, 44, 57], [], [], [67,
> 74, 81], [], [86], [], [54, 93], [66, 79], [], [], [], [], [100
> ], [19], [62, 68], [87], [4, 15, 89], [61, 86], [], [41], [21,
> 41], [59, 64], [], [53], [59], [14, 33], [], [], [37, 71, 92], [
> 3, 20], [56], [56], [], [89], [], [1, 14, 38, 85], [], [19], [
> 30], [56, 98]]);
<immutable digraph with 100 vertices, 110 edges>
gap> IsConnectedDigraph(gr);
false
gap> ArticulationPoints(gr);
[  ]
gap> StrongOrientation(gr);
Error, not yet implemented
gap> gr := DigraphCopy(gr);
<immutable digraph with 100 vertices, 110 edges>
gap> ArticulationPoints(gr);
[  ]
gap> IsConnectedDigraph(gr);
false
gap> ArticulationPoints(Digraph([[1, 2], [2]]));
[  ]
gap> StrongOrientation(Digraph([[1, 2], [2]]));
Error, not yet implemented
gap> gr := Digraph([[1, 1, 2, 2, 2, 2, 2], [2, 2, 3, 3], []]);  # path
<immutable multidigraph with 3 vertices, 11 edges>
gap> ArticulationPoints(gr);
[ 2 ]
gap> StrongOrientation(gr);
Error, not yet implemented
gap> gr := Digraph([[1, 1, 2, 2, 2, 2, 2], [2, 2, 3, 3], [1, 1, 1]]);  # cycle
<immutable multidigraph with 3 vertices, 14 edges>
gap> ArticulationPoints(gr);
[  ]
gap> gr := Digraph([[2], [3], [], [3]]);
<immutable digraph with 4 vertices, 3 edges>
gap> ArticulationPoints(gr);
[ 3, 2 ]
gap> IsConnectedDigraph(DigraphRemoveVertex(gr, 3));
false
gap> IsConnectedDigraph(DigraphRemoveVertex(gr, 2));
false
gap> IsConnectedDigraph(DigraphRemoveVertex(gr, 1));
true
gap> IsConnectedDigraph(DigraphRemoveVertex(gr, 4));
true
gap> ArticulationPoints(Digraph([]));
[  ]
gap> ArticulationPoints(Digraph([[]]));
[  ]
gap> ArticulationPoints(Digraph([[1]]));
[  ]
gap> ArticulationPoints(Digraph([[1, 1]]));
[  ]
gap> ArticulationPoints(Digraph([[1], [2]]));
[  ]
gap> ArticulationPoints(Digraph([[2], [1]]));
[  ]
gap> ArticulationPoints(DigraphFromGraph6String("FlCX?"));
[ 3, 4 ]
gap> ArticulationPoints(Digraph([[2, 4, 5], [1, 4], [4, 7], [1, 2, 3, 5, 6, 7],
>                                [1, 4], [4, 7], [3, 4, 6]]));
[ 4 ]
gap> gr := DigraphFromSparse6String(
> ":~?@V`OINBg_McouHAxQD@gyYEW}Q_@_YdgE`?OgZgpEbfYQKDGqiDQEI`wGdjoADGZG\
> FIJONFQSplq]y@IwvbPKhMh}JGK?OLzW{agKKfRCtarqTGayQGb]rMIurapkxPG?RGcI]\
> IBtB_`EQKJ@LmxlL_?k^QieOkB|T");
<immutable symmetric digraph with 87 vertices, 214 edges>
gap> Set(ArticulationPoints(gr));
[ 1, 3, 8, 11, 12, 15, 17, 18, 19, 21, 23, 27, 30, 36, 37, 41, 42, 46, 51, 
  52, 59, 60, 61, 63, 66, 68, 69, 73, 75, 76, 79, 84, 87 ]
gap> IsDuplicateFree(last);
true
gap> ForAll(ArticulationPoints(gr),
> x -> not IsConnectedDigraph(DigraphRemoveVertex(gr, x)));
true
gap> Set(ArticulationPoints(gr))
> = Filtered(DigraphVertices(gr),
>            x -> not IsConnectedDigraph(DigraphRemoveVertex(gr, x)));
true
gap> D := Digraph([[2, 5], [1, 3, 4, 5], [2, 4], [2, 3], [1, 2]]);
<immutable digraph with 5 vertices, 12 edges>
gap> Bridges(D);
[  ]
gap> ArticulationPoints(D);
[ 2 ]
gap> D := Digraph([[2], [3], [4], [2]]);
<immutable digraph with 4 vertices, 4 edges>
gap> Bridges(D);
[ [ 1, 2 ] ]
gap> ArticulationPoints(D);
[ 2 ]
gap> D := Digraph([[1, 1, 2, 2], [2, 2, 3, 3], []]);
<immutable multidigraph with 3 vertices, 8 edges>
gap> ArticulationPoints(D);
[ 2 ]
gap> Bridges(D);
[ [ 2, 3 ], [ 1, 2 ] ]

# StrongOrientation
gap> filename := Concatenation(DIGRAPHS_Dir(), "/data/graph5.g6.gz");;
gap> D := ReadDigraphs(filename);;
gap> ForAll(D,
>           d -> StrongOrientation(d) = fail
>                or IsStronglyConnectedDigraph(StrongOrientation(d)));
true
gap> Number(D, d -> StrongOrientation(d) <> fail);
11
gap> Number(D, IsBridgelessDigraph);
11
gap> D := Filtered(D, d -> StrongOrientation(d) <> fail);;
gap> ForAll(D, d -> IsSubdigraph(d, StrongOrientation(d)));
true
gap> ForAll(D,
> d -> DigraphNrEdges(d) / 2 = DigraphNrEdges(StrongOrientation(d)));
true

#  HamiltonianPath
gap> g := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> HamiltonianPath(g);
[  ]
gap> g := Digraph([[]]);
<immutable empty digraph with 1 vertex>
gap> HamiltonianPath(g);
[ 1 ]
gap> g := Digraph([[], []]);
<immutable empty digraph with 2 vertices>
gap> HamiltonianPath(g);
fail
gap> g := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> HamiltonianPath(g);
[ 1 ]
gap> g := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> HamiltonianPath(g);
fail
gap> g := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> HamiltonianPath(g);
[ 1, 2 ]
gap> g := Digraph([[3], [3], []]);
<immutable digraph with 3 vertices, 2 edges>
gap> HamiltonianPath(g);
fail
gap> g := Digraph([[3], [3], [1, 2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> HamiltonianPath(g);
fail
gap> g := Digraph([[3], [], [2]]);
<immutable digraph with 3 vertices, 2 edges>
gap> HamiltonianPath(g);
fail
gap> g := Digraph([[2], [3], [1]]);
<immutable digraph with 3 vertices, 3 edges>
gap> HamiltonianPath(g);
[ 1, 2, 3 ]
gap> g := Digraph([[2], [3], [1], []]);
<immutable digraph with 4 vertices, 3 edges>
gap> HamiltonianPath(g);
fail
gap> g := Digraph([[2], [3], [1, 4], []]);
<immutable digraph with 4 vertices, 4 edges>
gap> HamiltonianPath(g);
fail
gap> g := Digraph([[3, 6], [4], [2, 1], [5, 1], [3], [4]]);
<immutable digraph with 6 vertices, 9 edges>
gap> HamiltonianPath(g);
fail
gap> g := Digraph([[3, 6], [4, 1], [2, 1], [5, 1], [3], [4]]);
<immutable digraph with 6 vertices, 10 edges>
gap> HamiltonianPath(g);
[ 1, 6, 4, 5, 3, 2 ]
gap> g := Digraph([[3, 6], [4], [2, 1], [5, 1], [3], [4, 7], []]);
<immutable digraph with 7 vertices, 10 edges>
gap> HamiltonianPath(g);
fail
gap> g := Digraph([[3, 6, 7], [4, 1], [2, 1], [5, 1], [3], [4, 7], [6]]);
<immutable digraph with 7 vertices, 13 edges>
gap> HamiltonianPath(g);
[ 1, 7, 6, 4, 5, 3, 2 ]
gap>  g := Digraph([[3, 6], [4], [2, 1], [5, 1], [3], [4, 7], [6]]);
<immutable digraph with 7 vertices, 11 edges>
gap> HamiltonianPath(g);
fail
gap> g := Digraph([[5, 6, 10], [2, 9], [3, 7], [2, 3], [9, 10], [2, 9], [1],
>                  [2, 3, 4, 7, 9], [3, 10], [4, 5, 6, 8]]);
<immutable digraph with 10 vertices, 25 edges>
gap> HamiltonianPath(g);
fail
gap> g := Digraph([[2, 4, 6, 10], [1, 3, 4, 5, 6, 7, 9, 10], [1, 5, 7, 8],
>                  [6, 10], [1, 7], [3, 4, 6, 7, 9], [2, 3, 4, 7],
>                  [2, 4, 5, 6], [2, 3, 5, 6, 7, 9, 10], [2, 3, 5]]);
<immutable digraph with 10 vertices, 43 edges>
gap> HamiltonianPath(g);
[ 1, 4, 6, 9, 10, 3, 8, 5, 7, 2 ]
gap> IsDigraphMonomorphism(CycleDigraph(10),
>                          g,
>                          Transformation(HamiltonianPath(g)));
true
gap> g := CompleteMultipartiteDigraph([1, 30]);
<immutable complete bipartite digraph with bicomponent sizes 1 and 30>
gap> HamiltonianPath(g);
fail
gap> g := Digraph([[2, 5, 6], [3, 1, 7], [4, 2, 8], [5, 3, 9], [1, 4, 10],
>                  [1, 8, 9], [2, 9, 10], [3, 10, 6], [4, 6, 7], [5, 7, 8]]);
<immutable digraph with 10 vertices, 30 edges>
gap> HamiltonianPath(g);
fail
gap> g := CompleteMultipartiteDigraph([16, 15]);
<immutable complete bipartite digraph with bicomponent sizes 16 and 15>
gap> HamiltonianPath(g);
fail
gap> g := CompleteMultipartiteDigraph([1, 15, 1, 1, 1, 1, 1, 1]);
<immutable complete multipartite digraph with 22 vertices, 252 edges>
gap> HamiltonianPath(g);
fail
gap> g := CycleDigraph(100);
<immutable cycle digraph with 100 vertices>
gap> HamiltonianPath(g);
[ 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 
  96, 97, 98, 99, 100, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
  17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 
  36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 
  55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 
  74, 75, 76 ]
gap> g := CycleDigraph(513);
<immutable cycle digraph with 513 vertices>
gap> g := DigraphAddEdges(g, [[6, 8], [8, 7], [7, 9]]);
<immutable digraph with 513 vertices, 516 edges>
gap> g := DigraphRemoveEdge(g, [6, 7]);
<immutable digraph with 513 vertices, 515 edges>
gap> HamiltonianPath(g);
[ 1, 2, 3, 4, 5, 6, 8, 7, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 
  79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 
  98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 
  113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 
  128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 
  143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 
  158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 
  173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 
  188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 
  203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 
  218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 
  233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 
  248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 
  263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 
  278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 
  293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 
  308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 
  323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 
  338, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351, 352, 
  353, 354, 355, 356, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366, 367, 
  368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 
  383, 384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394, 395, 396, 397, 
  398, 399, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 
  413, 414, 415, 416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 
  428, 429, 430, 431, 432, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442, 
  443, 444, 445, 446, 447, 448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 
  458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 
  473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 
  488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 
  503, 504, 505, 506, 507, 508, 509, 510, 511, 512, 513, 1 ]
gap> gr := DigraphAddEdges(DigraphAddVertex(CycleDigraph(600)),
>                          [[600, 601], [601, 600]]);
<immutable digraph with 601 vertices, 602 edges>
gap> HamiltonianPath(gr);
fail

# DigraphCore
gap> D := Digraph([[3, 6], [1], [4], [5, 7], [1], [2, 7], [4, 1]]);
<immutable digraph with 7 vertices, 11 edges>
gap> DigraphCore(D);
[ 1, 3, 4, 6, 7 ]
gap> D := Digraph([[2, 3], [1, 3], [1, 2, 4], [1]]);
<immutable digraph with 4 vertices, 8 edges>
gap> DigraphCore(D);
[ 1, 2, 3 ]
gap> DIGRAPHS_FREE_HOMOS_DATA();;
gap> DigraphHomomorphism(D, InducedSubdigraph(D, DigraphCore(D)));
Transformation( [ 1, 3, 2, 3 ] )
gap> D := CompleteDigraph(10);
<immutable complete digraph with 10 vertices>
gap> DigraphCore(D);
[ 1 .. 10 ]
gap> D := Digraph([[2], [3], [4], [5], [6], [2]]);
<immutable digraph with 6 vertices, 6 edges>
gap> DigraphCore(D);
[ 2, 3, 4, 5, 6 ]
gap> D := Digraph([[2], [1], [4, 5], [5], [4]]);
<immutable digraph with 5 vertices, 6 edges>
gap> DigraphCore(D);
[ 3, 4, 5 ]
gap> D := EmptyDigraph(0);
<immutable empty digraph with 0 vertices>
gap> DigraphCore(D);
[  ]
gap> D := EmptyDigraph(1000);
<immutable empty digraph with 1000 vertices>
gap> DigraphCore(D);
[ 1 ]
gap> D := EmptyDigraph(IsMutableDigraph, 0);
<mutable empty digraph with 0 vertices>
gap> for i in [2 .. 15] do
> DigraphDisjointUnion(D, CycleDigraph(i));
> od;
gap> DigraphCore(D);
[ 1, 2, 3, 4, 5, 10, 11, 12, 13, 14, 21, 22, 23, 24, 25, 26, 27, 55, 56, 57, 
  58, 59, 60, 61, 62, 63, 64, 65, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
  89, 90 ]
gap> D1 := DigraphFromDigraph6String("&FJBWqNbXV?");
<immutable digraph with 7 vertices, 24 edges>
gap> IsDigraphCore(D1);
true
gap> D2 := DigraphFromDigraph6String("&FJbWqNbWu?");
<immutable digraph with 7 vertices, 24 edges>
gap> IsDigraphCore(D2);
true
gap> M1 := DigraphMycielskian(D1);
<immutable digraph with 15 vertices, 86 edges>
gap> IsDigraphCore(M1);
true
gap> D := DigraphDisjointUnion(D1, D2, M1);
<immutable digraph with 29 vertices, 134 edges>
gap> DigraphCore(D);
[ 8 .. 29 ]
gap> IsDigraphCore(InducedSubdigraph(D, DigraphCore(D)));
true
gap> str := ".qb`hOAW@fAiG]g??aGD[TXAbjgWl^?fkG{~cA@p`e~EIRlHSxBFHx\\RJ@ERCYhV\
> SoIDvIE?c?x_YBJg?IWmoN_djWMyKnckGkdMqBsQMBWsBaK?\\BBFWOvY[vcHp]N";;
gap> D := DigraphFromDiSparse6String(str);
<immutable digraph with 50 vertices, 79 edges>
gap> DigraphCore(D);
[ 1, 2, 4, 7, 8, 9, 11, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 25, 26, 
  29, 30, 32, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 46, 47, 48, 49, 50 ]
gap> D := Digraph([[2, 8], [3], [1], [5], [6], [7], [4], []]);
<immutable digraph with 8 vertices, 8 edges>
gap> DigraphCore(D);
[ 1 .. 7 ]
gap> D := Digraph([[], [2]]);
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphCore(D);
[ 2 ]
gap> D := DigraphDisjointUnion(EmptyDigraph(1), CompleteBipartiteDigraph(3, 3));
<immutable digraph with 7 vertices, 18 edges>
gap> DigraphCore(D);
[ 2, 5 ]
gap> D := DigraphFromDigraph6String("&IO?_@?A?CG??O?_G??");
<immutable digraph with 10 vertices, 9 edges>
gap> DigraphCore(D);
[ 7, 8, 9 ]
gap> D := CycleDigraph(IsMutableDigraph, 2);
<mutable digraph with 2 vertices, 2 edges>
gap> for i in [1 .. 9] do
>      DigraphDisjointUnion(D, D);
>    od;
gap> DigraphCore(D);
[ 1, 2 ]
gap> D := DigraphFromDigraph6String("&G?_cO`EO?@??");
<immutable digraph with 8 vertices, 10 edges>
gap> DigraphCore(D);
[ 2, 5 ]
gap> D := DigraphFromDigraph6String("&GSY??A?SA?O?");
<immutable digraph with 8 vertices, 10 edges>
gap> DigraphCore(D);
[ 1, 2 ]
gap> D := Digraph([[2], [1, 3], []]);;
gap> DigraphCore(D);
[ 1, 2 ]

# MaximalAntiSymmetricSubdigraph
gap> MaximalAntiSymmetricSubdigraph(Digraph([[2, 2], [1]]));
<immutable antisymmetric digraph with 2 vertices, 1 edge>
gap> MaximalAntiSymmetricSubdigraph(Digraph(IsMutableDigraph, [[2, 2], [1]]));
<mutable digraph with 2 vertices, 1 edge>
gap> D := Digraph(IsMutableDigraph, [[1]]);
<mutable digraph with 1 vertex, 1 edge>
gap> MaximalAntiSymmetricSubdigraph(D) = D;
true
gap> MaximalAntiSymmetricSubdigraph(NullDigraph(0));
<immutable empty digraph with 0 vertices>
gap> IsAntisymmetricDigraph(DigraphCopy(last));
true
gap> MaximalAntiSymmetricSubdigraph(NullDigraph(1));
<immutable empty digraph with 1 vertex>
gap> IsAntisymmetricDigraph(DigraphCopy(last));
true
gap> MaximalAntiSymmetricSubdigraph(CompleteDigraph(1));
<immutable empty digraph with 1 vertex>
gap> IsAntisymmetricDigraph(DigraphCopy(last));
true
gap> MaximalAntiSymmetricSubdigraph(CompleteBipartiteDigraph(2, 30000));
<immutable antisymmetric digraph with 30002 vertices, 60000 edges>
gap> IsAntisymmetricDigraph(DigraphCopy(last));
true
gap> MaximalAntiSymmetricSubdigraph(Digraph([[1, 1, 2, 2], []]));
<immutable antisymmetric digraph with 2 vertices, 2 edges>
gap> OutNeighbours(last);
[ [ 1, 2 ], [  ] ]
gap> MaximalAntiSymmetricSubdigraph(CompleteDigraph(10));
<immutable antisymmetric digraph with 10 vertices, 45 edges>
gap> D := CompleteDigraph(10);
<immutable complete digraph with 10 vertices>
gap> MaximalAntiSymmetricSubdigraph(D);
<immutable antisymmetric digraph with 10 vertices, 45 edges>
gap> MaximalAntiSymmetricSubdigraph(D);
<immutable antisymmetric digraph with 10 vertices, 45 edges>
gap> D := Digraph(IsImmutableDigraph, [[2, 2], [1]]);
<immutable multidigraph with 2 vertices, 3 edges>
gap> DigraphRemoveAllMultipleEdges(D);;
gap> HasDigraphRemoveAllMultipleEdgesAttr(D);
true
gap> IsChainDigraph(MaximalAntiSymmetricSubdigraph(D));
true

# CharacteristicPolynomial
gap> gr := Digraph([
> [2, 2, 2], [1, 3, 6, 8, 9, 10], [4, 6, 8],
> [1, 2, 3, 9], [3, 3], [3, 5, 6, 10], [1, 2, 7],
> [1, 2, 3, 10, 5, 6, 10], [1, 3, 4, 5, 8, 10],
> [2, 3, 4, 6, 7, 10]]);
<immutable multidigraph with 10 vertices, 44 edges>
gap> CharacteristicPolynomial(gr);
x_1^10-3*x_1^9-7*x_1^8-x_1^7+14*x_1^6+x_1^5-26*x_1^4+51*x_1^3-10*x_1^2+18*x_1-\
30
gap> gr := CompleteDigraph(5);
<immutable complete digraph with 5 vertices>
gap> CharacteristicPolynomial(gr);
x_1^5-10*x_1^3-20*x_1^2-15*x_1-4

# IsVertexTransitive
gap> IsVertexTransitive(Digraph([]));
true
gap> IsVertexTransitive(Digraph([[1], [2]]));
true
gap> IsVertexTransitive(Digraph([[2], [3], []]));
false
gap> IsVertexTransitive(CompleteDigraph(20));
true

# IsEdgeTransitive
gap> IsEdgeTransitive(Digraph([]));
true
gap> IsEdgeTransitive(Digraph([[1], [2]]));
true
gap> IsEdgeTransitive(Digraph([[2], [3], []]));
false
gap> IsEdgeTransitive(CompleteDigraph(20));
true
gap> IsEdgeTransitive(Digraph([[2], [3, 3, 3], []]));
Error, the argument <D> must be a digraph with no multiple edges,

# AsGraph
gap> D := NullDigraph(IsMutableDigraph, 3);
<mutable empty digraph with 3 vertices>
gap> AsGraph(D);
rec( adjacencies := [ [  ], [  ], [  ] ], group := Group(()), isGraph := true,
  names := [ 1 .. 3 ], order := 3, representatives := [ 1, 2, 3 ], 
  schreierVector := [ -1, -2, -3 ] )

# DigraphSource
gap> D := NullDigraph(IsMutableDigraph, 3);
<mutable empty digraph with 3 vertices>
gap> DigraphSource(D);
[  ]
gap> DigraphRange(D);
[  ]
gap> DigraphSymmetricClosure(NullDigraph(IsMutableDigraph, 1));
<mutable empty digraph with 1 vertex>
gap> D := Digraph([[2], []]);
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphSymmetricClosure(D);
<immutable symmetric digraph with 2 vertices, 2 edges>
gap> DigraphSymmetricClosure(D);
<immutable symmetric digraph with 2 vertices, 2 edges>
gap> D := Digraph(IsMutableDigraph, [[2, 2], []]);
<mutable multidigraph with 2 vertices, 2 edges>
gap> DigraphTransitiveClosure(D);
Error, the argument <D> must be a digraph with no multiple edges,
gap> DigraphReflexiveTransitiveClosure(D);
Error, the argument <D> must be a digraph with no multiple edges,
gap> MakeImmutable(D);
<immutable multidigraph with 2 vertices, 2 edges>
gap> DigraphTransitiveClosure(D);
Error, the argument <D> must be a digraph with no multiple edges,
gap> D := Digraph([[2], []]);
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphTransitiveClosure(D);
<immutable transitive digraph with 2 vertices, 1 edge>
gap> DigraphTransitiveClosure(D);
<immutable transitive digraph with 2 vertices, 1 edge>
gap> DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 2 vertices, 3 edges>
gap> DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 2 vertices, 3 edges>
gap> D := DigraphMutableCopy(DigraphSymmetricClosure(D));
<mutable digraph with 2 vertices, 2 edges>
gap> MaximalSymmetricSubdigraphWithoutLoops(D);
<mutable digraph with 2 vertices, 2 edges>
gap> MaximalSymmetricSubdigraphWithoutLoops(MakeImmutable(D));
<immutable symmetric digraph with 2 vertices, 2 edges>
gap> MaximalSymmetricSubdigraphWithoutLoops(D);
<immutable symmetric digraph with 2 vertices, 2 edges>
gap> D := CycleDigraph(IsMutableDigraph, 10);
<mutable digraph with 10 vertices, 10 edges>
gap> UndirectedSpanningForest(D);
<mutable empty digraph with 10 vertices>

#  Digraph(Reflexive)TransitiveReduction

# Check errors
gap> gr := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> DigraphTransitiveReduction(gr);
Error, the argument <D> must be a digraph with no multiple edges,
gap> DigraphReflexiveTransitiveReduction(gr);
Error, the argument <D> must be a digraph with no multiple edges,
gap> gr := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphTransitiveReduction(gr);
Error, not yet implemented for non-topologically sortable digraphs,
gap> DigraphReflexiveTransitiveReduction(gr);
Error, not yet implemented for non-topologically sortable digraphs,
gap> D := Digraph(IsImmutableDigraph, [[1, 2, 3], [3], [3]]);;
gap> DigraphRemoveLoops(D);; HasDigraphRemoveLoopsAttr(D);
true
gap> DigraphReflexiveTransitiveReduction(D) = ChainDigraph(3);
true

# Working examples
gap> gr1 := ChainDigraph(6);
<immutable chain digraph with 6 vertices>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr1);
<immutable preorder digraph with 6 vertices, 21 edges>
gap> DigraphTransitiveReduction(gr2) = gr1;  # trans reduction contains loops
false
gap> DigraphReflexiveTransitiveReduction(gr2) = gr1;  # ref trans reduct doesnt
true
gap> gr3 := DigraphAddEdge(gr1, [3, 3]);
<immutable digraph with 6 vertices, 6 edges>
gap> DigraphHasLoops(gr3);
true
gap> gr4 := DigraphTransitiveClosure(gr3);
<immutable transitive digraph with 6 vertices, 16 edges>
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

#  DigraphReverse
gap> gr := DigraphFromDigraph6String("&DHUEe_");
<immutable digraph with 5 vertices, 11 edges>
gap> rgr := DigraphReverse(gr);
<immutable digraph with 5 vertices, 11 edges>
gap> OutNeighbours(rgr);
[ [ 2, 3, 4 ], [ 4, 5 ], [ 1, 2, 5 ], [ 4 ], [ 2, 5 ] ]
gap> gr = DigraphReverse(rgr);
true
gap> gr := Digraph(rec(DigraphNrVertices := 5,
> DigraphSource := [1, 1, 2, 2, 2, 2, 2, 3, 4, 4, 4, 5, 5, 5],
> DigraphRange := [1, 3, 1, 2, 2, 4, 5, 4, 1, 3, 5, 1, 1, 3]));
<immutable multidigraph with 5 vertices, 14 edges>
gap> e := DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 3 ], [ 2, 1 ], [ 2, 2 ], [ 2, 2 ], [ 2, 4 ], [ 2, 5 ], 
  [ 3, 4 ], [ 4, 1 ], [ 4, 3 ], [ 4, 5 ], [ 5, 1 ], [ 5, 1 ], [ 5, 3 ] ]
gap> rev := DigraphReverse(gr);
<immutable multidigraph with 5 vertices, 14 edges>
gap> erev := DigraphEdges(rev);;
gap> temp := List(erev, x -> [x[2], x[1]]);;
gap> Sort(temp);
gap> e = temp;
true
gap> gr := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsSymmetricDigraph(gr);
true
gap> DigraphReverse(gr) = gr;
true
gap> gr := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> SetIsSymmetricDigraph(gr, true);
gap> gr = DigraphReverse(gr);
true
gap> DigraphReverse(Digraph(IsMutableDigraph, [[2], [1]]))
> = CompleteDigraph(2);
true
gap> OutNeighbours(DigraphReverse(ChainDigraph(IsMutableDigraph, 5)));
[ [  ], [ 1 ], [ 2 ], [ 3 ], [ 4 ] ]

# DigraphCartesianProductProjections
gap> D := DigraphCartesianProduct(ChainDigraph(3), CycleDigraph(4),
> Digraph([[2], [2]]));;
gap> HasDigraphCartesianProductProjections(D);
true
gap> proj := DigraphCartesianProductProjections(D);; Length(proj);
3
gap> IsIdempotent(proj[2]);
true
gap> RankOfTransformation(proj[3]);
2
gap> S := ImageSetOfTransformation(proj[2]);;
gap> IsIsomorphicDigraph(CycleDigraph(4), InducedSubdigraph(D, S));
true
gap> G := DigraphRemoveLoops(RandomDigraph(12));;
gap> H := DigraphRemoveLoops(RandomDigraph(50));;
gap> D := DigraphCartesianProduct(G, H);;
gap> proj := DigraphCartesianProductProjections(D);;
gap> IsIdempotent(proj[1]);
true
gap> RankOfTransformation(proj[2]);
50
gap> S := ImageSetOfTransformation(proj[2]);;
gap> IsIsomorphicDigraph(H, InducedSubdigraph(D, S));
true

# DigraphDirectProductProjections
gap> D := DigraphDirectProduct(ChainDigraph(3), CycleDigraph(4),
> Digraph([[2], [2]]));;
gap> HasDigraphDirectProductProjections(D);
true
gap> proj := DigraphDirectProductProjections(D);; Length(proj);
3
gap> IsIdempotent(proj[2]);
true
gap> RankOfTransformation(proj[3]);
2
gap> P := DigraphRemoveAllMultipleEdges(
> ReducedDigraph(OnDigraphs(D, proj[2])));;
gap> IsIsomorphicDigraph(CycleDigraph(4), P);
true
gap> G := RandomDigraph(12);;
gap> H := RandomDigraph(50);;
gap> D := DigraphDirectProduct(G, H);;
gap> proj := DigraphDirectProductProjections(D);;
gap> IsIdempotent(proj[1]);
true
gap> RankOfTransformation(proj[2]);
50
gap> P := DigraphRemoveAllMultipleEdges(
> ReducedDigraph(OnDigraphs(D, proj[2])));;
gap> IsIsomorphicDigraph(H, P);
true

# DigraphMaximalMatching
gap> D := DigraphFromDigraph6String("&Sq_MN|bDCLy~Xj}u}GxOLlGfqJtnSQ|l\
> Q?lYvjbqN~XNNAQYDJE[UHOhyGOqtsjCWJy[");
<immutable digraph with 20 vertices, 205 edges>
gap> M := DigraphMaximalMatching(D);; IsMaximalMatching(D, M);
true
gap> D := DigraphFromDigraph6String(IsMutable,
> "&Sq_MN|bDCLy~Xj}u}GxOLlGfqJtnSQ|lQ?lYvjbqN~XNNAQYDJE[UHOhyGOqtsjCWJy[");
<mutable digraph with 20 vertices, 205 edges>
gap> M := DigraphMaximalMatching(D);; IsMaximalMatching(D, M);
true
gap> D := Digraph(IsMutable, [[2], [3], [4], [1]]);
<mutable digraph with 4 vertices, 4 edges>
gap> M := DigraphMaximalMatching(D);;
gap> M = [[1, 2], [3, 4]] or M = [[2, 3], [4, 1]];
true
gap> D;
<mutable digraph with 4 vertices, 4 edges>

# DigraphMaximumMatching
gap> D := DigraphFromDiSparse6String(
> ".]cBn@kqAlt?EpclQp|M}bAgFjHkoDsIuACyCM_Hj");
<immutable digraph with 30 vertices, 26 edges>
gap> M := DigraphMaximumMatching(D);; IsMaximalMatching(D, M);
true
gap> Length(M);
14
gap> D := Digraph([[5, 6, 7, 8], [6, 7, 8], [7, 8], [8], [], [], [], []]);
<immutable digraph with 8 vertices, 10 edges>
gap> DigraphMaximumMatching(D);
[ [ 1, 5 ], [ 2, 6 ], [ 3, 7 ], [ 4, 8 ] ]
gap> D := Digraph(IsMutable, [[2, 3], [1, 4], [2, 4], [5], [3, 5]]);
<mutable digraph with 5 vertices, 9 edges>
gap> M := DigraphMaximumMatching(D);; IsMaximalMatching(D, M);
true
gap> Length(M);
3
gap> D := DigraphFromDiSparse6String("\
> .~?B]zsE?cB?kH?cK?{M?{O?SIaWHaoQ_{X??@?wJ@gT`{[BKF@s^BG[_OOAca?{@@gXB_^bK?A\
> gXbGc_gF@o\\dGG`gXC[X`K__OC?oG@GI@wOAGQAWSAoWBOZBo_CGgDGkDk?BGd_wMBgfdsFC{Q\
> Ao]CGmdsJBGbC_ebGdD{ZDsXCgnEsC?oHAWkDsFbK@BGb`?PDsD?wfcGmE[Fb?ZD?mEWsE{LBGb\
> DSmEW~aOmE[XB_^C[XbKmEW~G[gDp@_x?dop_wfdosGKWDp@dsJBGt`wYDopFHJH{FA{F_waG@I\
> I[OC?mbGtdsUDor`?IAG_DGmFhVbWgDovGHH_GXBwbFcFCwqdpVJKXG{XGx]_wVISC?omFKXF[X\
> CkFCP?IXSaOmEXCbGtIsXGs?BGddpP_xS_wKAwfIP_dpVJH\\_?TBGdDWnEowFXEGx]JxaKXfLC\
> mEHJIKUDorJCFL[XDXfLkWDosGHLHpY`GkDox`WXEhOIsmEW~dorFxtbGjLhpcGmEW~MkA?_E@?\
> H@ONA?PAWSBO_DGkDgmEGxFhJHxPIhVJH\\KHhL`mM[A@?IA?PA__DGlDo|IhVJH\\L`x_WF`wY\
> DpPNKQAo]DorFxCJ@dL{IAGmJHkNHydopHxPNKUDorNkgDp@JS?BGdL@lbGeEk@@WLBG[BwbC_e\
> DOtF`AGhOIpZKplMaBcGmEW~c?lDpxNSFdorFxBHCFL[mIHhNKmFHx_wfEP[aOUB?ZBo`D?mEWs\
> Ew~GHBG`GHHLHpWJPdLxqMhuN@xNi?OIDPCSC?mNHybGbDPDOcFNYFbGbOaN_waIcF_wyQ[FLYH\
> do|JHxNSFHPSLSmEW~OiLbOmIHhLpxPSF@`jaWmFHx__E@GNAWYD_mEGxHXNIH`LHmMXxNP{NyI\
> PYXR[XChbLkXCgnKXlRkmGHMMQLdo|JHxNQUaWmFHxPY[dp@JQLbWmEx@HHYPkmFHxPY[SKFAxj\
> PITdp@HhqPi^a?_DpTNHydp@JQLSSXEhUKqC_WFFQS_yFQCB?waFP?HPRI`cLPzOyOQQRQaVTQj\
> dp@JQLSQbTCD?wK@oVBgfE?qFpKIP[K@jMAHPaTRQdTcFCxKJam_xSLQVTc_DgmNHyOsmGHMMQL\
> dorNi?PkXCotOYCbHEKPfLk]DorNi?PkgDp@HHYPkFCw}HamT{FQYkdorFyDPiWdosGHLMQL_WF\
> NYkdp@JQ@PkRDoxNIZRcAC?lDpxNSmGHqPi^SsWDp@MQLbGzJpaLkXC_tKqCagXChl_?TBGdLjC\
> cGmEW~NALbGcEiCW[FIXSKak_WFFPSNYFQARQaiTYkVI{_gFCwoFqmb?mGHqPj@dp@JQ@Pi|a__\
> DpTNHyPsmHxPNH~RcmEW~GXtMqLbGdDWzGpFJp^KPfLhpMytWSXCYCPyP_waIaQTcFLXoQimdor\
> Ni?Pir_yRTaxXKF@`jRQm_x?HPSTc??GB?gF@WK@gMAgVBG[Bg^CObC_dCofDOjDonE?qEguF?y\
> FW{Fp?GPDGpFHPKI@QIXSIpZJ`]Jx_KPbK`eKxgLPjLhoMHsMxzOQBOaFPIKPyOQIQQYSQiVRQ\\
> \RqdTIiTYkTqnUAsUiwVI{WRBWbDWzGXJIYBPYRRYjUY{GDGmJHxNSAC?mNHyV{mGHMMQLUS]Do\
> rNiLUsFLXoTrRYrW");;
gap> M := DigraphMaximumMatching(D);; IsMaximalMatching(D, M);
true
gap> Length(M);
111
gap> M1 := [
> [1, 198], [2, 61], [3, 219], [4, 189], [5, 10], [6, 63], [7, 98], [8, 26],
> [9, 62], [11, 18], [12, 81], [13, 155], [14, 67], [15, 30], [16, 125],
> [17, 168], [19, 23], [20, 162], [21, 143], [22, 197], [24, 166], [25, 79],
> [27, 154], [28, 56], [29, 70], [31, 221], [32, 92], [33, 90], [34, 134],
> [35, 101], [36, 54], [37, 39], [38, 209], [40, 108], [41, 130], [42, 218],
> [43, 144], [44, 120], [45, 116], [46, 192], [47, 217], [48, 159], [49, 203],
> [50, 128], [51, 141], [52, 66], [53, 188], [55, 57], [58, 82], [59, 171],
> [60, 99], [64, 126], [65, 216], [68, 208], [69, 102], [71, 182], [72, 96],
> [73, 137], [74, 184], [75, 152], [76, 111], [77, 185], [78, 167], [80, 207],
> [83, 97], [84, 201], [85, 202], [86, 206], [87, 117], [88, 94], [89, 112],
> [91, 115], [93, 176], [95, 195], [100, 158], [103, 170], [104, 114],
> [105, 131], [106, 139], [107, 177], [109, 127], [110, 133], [113, 212],
> [118, 119], [121, 199], [122, 142], [123, 157], [124, 145], [129, 183],
> [132, 181], [135, 178], [136, 172], [138, 150], [140, 165], [146, 210],
> [147, 211], [148, 149], [151, 161], [153, 187], [156, 191], [160, 193],
> [163, 169], [164, 174], [173, 175], [179, 220], [180, 213], [186, 214],
> [190, 205], [194, 204], [196, 200], [215, 222]];;
gap> M = M1;
true
gap> D := DigraphFromDiSparse6String("\
> .~?@}~ggEb?eM@X?@_?CC@OWIAowO_PEPdOOPcX_HBHaPDgWICW[GAOoLE@e?@`ESbp]PfG_[cP\
> M?@_gMCPk\\_OOJC@CQDPWYd@yHB@_[`pqPD`gdcQA[IH_XFHCUEaShapCd_?SEA_wPCpk\\GAK\
> cHQiPJwMPHQeGFAE^frQPCqKn_OOJCPSUEaShJQwq__MA?o[GAOoLBpCSDp_XF@w^GQGeHq_jJB\
> CrLBSwfrOtMWSMCQ}@CPGdfBePDaShKb]PCq{u_?SEA_wPEpscJrm]MW{^MXCdIRGvNgCPCaS{`\
> os[IAkxNXCiJrAFFA_xPXCRGAgnKCYPGAgnQGOJCPSdIQwv_@C\\HA|?_PCdNCQA?pwpMBe@C@C\
> db`CnOGCPHWCPHSPK_rCxRWs[IBc|PX[^MW_[GbeSFbd@`@CTHQwvQgkPHQwvQgGBBpOVF@w^Hb\
> CsLR_xMcDARTHSTgCOCQTMbp{sMSHXdp{xTDe@CQTO_b_xRTeDB`CnMsA^MTPXVGGBD@w^HbCwM\
> SDLSdXXVg_WFACaKrdTaP_XFAoxcPKnNx[^MTd[a?cKE@c[GQGfJBKxPTTaWwCOCQTCRd@YVWs[\
> MSTRdp{xUTpdfbd@Tdd`fACrMUHeb`CnOC|^bp{sLRcyOddZVHCRJr|cfrdSUTp_b`CnOC|kcQ{\
> oPca@CQTMSDtffBc|PTMPCqKnLhCRGAKiJr?uNs@EQCdcZfDsd@weMTd`_PCQHRpC`pogMSTF_P\
> CdPCpPfA_jMSULFBdDSuaFFA_jMSTyfBc|PTLr]~");;
gap> M := DigraphMaximumMatching(D);; IsMaximalMatching(D, M);
true
gap> Length(M);
63
gap> M1 := [
> [1, 76], [2, 56], [3, 95], [4, 57], [5, 22], [6, 60], [7, 30], [8, 125],
> [9, 52], [10, 100], [11, 28], [12, 89], [13, 40], [14, 105], [15, 37],
> [16, 67], [17, 91], [18, 58], [19, 120], [20, 73], [21, 87], [23, 63],
> [24, 85], [25, 99], [26, 45], [27, 46], [29, 90], [31, 78], [32, 98],
> [33, 74], [34, 108], [35, 86], [36, 117], [38, 48], [39, 119], [41, 84],
> [42, 75], [43, 71], [44, 123], [47, 88], [49, 114], [50, 83], [51, 68],
> [53, 92], [54, 59], [55, 64], [61, 77], [62, 116], [65, 118], [66, 107],
> [69, 104], [70, 103], [72, 121], [79, 115], [80, 113], [81, 94], [82, 122],
> [93, 110], [96, 109], [97, 112], [101, 111], [102, 106], [124, 126]];;
gap> M = M1;
true
gap> D := DigraphFromDiSparse6String("\
> .~?BG`WHawSbOT_wJbwYcOOcgCCS`d?SBkj?gedo_`sp?OOdSuCCC?o^bS[cwgdD?A[wdC}gofF\
> [FGLJA_\\GhIi?uio_j?RF[bH|OaGyjgjjwOFdAHXYdhMbSQIDdE`KKTf?PalGh__jIKYHXPe@H\
> gD]kLfdXcekPA`pmoSfslG[[n_CCGx_gpGd~CGdDhfic}IKBAhPbS@?XJJpnbogGHdg\\_kXslS\
> aHeKJKaeXphhqk@pqOODABe[fKHgqoTfCKEPOrOSFxEHHqNQKr`qd@|cTc`YSqMb@G]CsRptl`h\
> LSc@G`QrSZSS@?G~h`hPKD@X@GpTTLiMifSyjc@[NYUmq@PAOp[D?o]bG\\Gq[T|uiMvCq]Ryjv\
> H^LUbchZKejUsoRC]mqga`}RaocpHH`wNczJ@WPY]hHPJ|DKa@OqHUK@DhMNYbij@axmQr@xCJ@\
> KP@sVAcYAkA?wJboOcOOcgabSgBkjCsmCCMCkP_Sieo__cCb_ifWggGwdC}gofF[FGLJBhDHSMh\
> oMi?uiONHSCH|U@w_fcocXNfhOaLBjwCAD`Dk~ILOkhKKTf?PSKThDLPbSoHKPGD]m@fkctaGUM\
> LYmoSC{}LklG\\{CGxnw`K|SfsBAmCBp]L{gGHd_@BJ{jKDbg@bLSaHXKpgafS@BpijxpqOADAB\
> eWycxHKHgNeUAmW@_qI@YhCSFxEHHqr`^MSgN@|cOokeSqMb@?WBoeaXHptl`hLSc@GdkRSZfxw\
> pIc_gJGHEIiblHiMijc@CN[_OIGQCNOYJuWXBhERancXuuy^nSZCxis[VChZK`ddijvo]H@YLYV\
> dPuaaohHKNCzJ@WKY]w`DOIH_GHDhzS\\TTlmQv");;
gap> M := DigraphMaximumMatching(D);; IsMaximalMatching(D, M);
true
gap> Length(M);
96
gap> D := DigraphFromDiSparse6String("\
> .~?BZ_O?__B_SF?CE_kC_[A@[M@KP?sDACC@{M_OL`cJ`OV`GU`?T_{EA[DASCAKB_O]_GMBk?@\
> g[b[JBSIBKHBCGA{FC{TCsDAcCAWc_WQ_OP_G`_?_`sL`_\\`W[D{IDsHBOl`?XDcFB?ja{U__g\
> _WSC{AAWe_GQCgy_?PC_xa?w`waE{MCGuekKB{JBor`O\\ESH`?ZdxE_oXDpDb?lGcVD`B_WUDX\
> A_OTDSSDH?_?RDCfFsPCo|cg{c_z`obFPR`gaFHQ`_wIK_ExO`O^H{HEhM`?\\Ecr_oZESDBOpH\
> SCBGob?nHCVDpF_GUDhE_?TGh_a_jJ{idHAJkPD@@JcOCx?J[NCo~JSMFsLJCb`WaIsICGyIk_F\
> HS`?wI[FBovL{uIKDB_tLkCBWsHxk_WYHpjhk@EHKLK?AwoHXgdxIK{THLdaWkGxcaOjK[PDPDK\
> SODHCKKgGX_cxAJx}`geGL{`[ICXZ`GaJPx`?`NC_JC^FPVMsDBoxIpt__wIhs_W[ExrbWu_GY_\
> ?XIKWEXOL{VEPNLqNaopHplPsTLaLa_nHaKaWmH[lHPhPSPPKODXfPCNDPFKshGpdOsgGhc`_fG\
> aCgXaO[ICh`OScKCGCX?Jy?_waF{ECH\\NsDC?|J`|SCCBw{JX{R{BBozJQ]bhXNQ\\fHWNI[_?\
> ZF@VNAZexUMyYbGuIhuRKWEhSMiWawsIXsQ{UIPrQsTEPPMQTa_pMIShyRaOnHpnaGmLqPdhKLi\
> O`wkHXkP{MDXILYMU[LDPHLShHAp`WgGxgUCfPQn`GeGhePImchCPAlc`BKaFTcECXbOt@KQDTS\
> CCH?KIhc?~KABTCAFp^OQf_G]Fh]Ss?Bg{OAdbacfPZNqbfHYNiajI`b@zSCVNREehUNI]WkTIh\
> wWcSI`vRbBaWqIXuRZAaOpIPtRR@aGoIHsWCnI@rRA~dpNMQV`olHppQq|`gkHhoQi{`_jH`nV[\
> JDPJLqRVSIDHILiQVKHD@HLcfQAvcpFPyu_pELIM_hDUfZ__B_o@_CE`WB_OJ_GI_CG_{EaWC_[\
> A@k@@c?@[V`GUakFAcEaSCAKBACA@{@Bk?@g[`_Z`[I`GW`CFAof_oT_gd_cQC[AAGa_GOCK?@w\
> _b{]`_\\ECJB_n`OZDsHBOl`?XDcFBCEAwi_gUDKTDCSf[@AOd_?Pa?bFCNCOvcGu`g_EkKBws`\
> W]`O\\ESHB_pbWo_wYDxE_om_glGcCAwkG[BD[AAgiGK@GCRF{QFsPCsOCkNC_zfPR`gaFHQ`_`\
> F@P`W_ExOepNbotHssHkFB`K_oqH\\IbHH_WWDxG_OVG{@Aold`DKCjGcRGX]aPAJkPGKOG@Z`w\
> eF{MCg}JKLC_|JCKF`VcOz`O`FPT`G_IcGBww_wvIPn_o\\EpPLsDB`OLkZHxk_WrHpj_OXEPib\
> C?H[UHSmKsSDhGKkRD`caPEaHDKSODHCKKND@BKCMNt]NkKCh?JkcFx[N[ICW}JXy`GaFhYNKGF\
> `X_w_FXWM{EBwyIxu_g]FHUbhTMcBB_vI`r_OZEpRMS@BOtIPpbGsIHob?rI@nawqHxmaopHsTE\
> @LLcSDxKLYKaXJLQJaOlHQIaGkHHgdXGK{NDQF`ohGqE`ggKaD`_fK[JCpa`OdGP`OSHC`@OKGJ\
> {FCO~Jp~cG}Jh}fh[Ni___^JX{R{]FXYN[AFPX_G[FI[_?ZF@VR[YExUM{XEpTRKtIaWawsIYVa\
> oragqQkpI@paWoHxoQ[QDxMLyQaGmHhmQKODhKLkND`JLaN`ojLYr`giHILUSKDHhPap`XFLAJ`\
> OfGpfPQncpDKsGKiG_xBKaFTdAKYET[DCPa__`G@`Oah_W_KAg_O^JyAS{]Fi@Ss?F`\\OC[FX[\
> NycbXZNqbbOxNkXF@{SKWExWSCuIxyR{UIpxWksIi\\WcrI`vRbBaXuRZAaPQMkPIIXa?nIAW`w\
> mHxqQy}dhMMIUVkLD`LQkjH`nQdJQ[IDHlVKHD@HLaPVCGCxGL[FCpiUsEChELIMUkDC`DLALUf\
> ");;
gap> M := DigraphMaximumMatching(D);; IsMaximalMatching(D, M);
true
gap> Length(M);
109
gap> D := DigraphFromDiSparse6String("\
> .~?B]`?C`OFc?B`kbBcd@cf@si@sXeWDCswCczE{|A{~?wGgGRgWeF|E?tJBs_DtP??HC?le_xi\
> `DipFj?kctZEozd\\LkGNGdbDT\\kxAh|BlWdlgHlwME[CapkcpAm_ompin?JeD{DD]ap[jeAAO\
> kDpcOK@FX\\KxsN{SooKA}GE?zK[@G@Mp_@?x?fqA`?~GeO?gOA?kk{^B|CIMT?xWcpyP}ZE[TI\
> [Ps@QNdyc@}R[He@^mLYh|xc`gNtpQ[XCgxGi^tgnNIgnMoBimbXHhYAep\\Lq\\uoYQ[YNUE_I\
> YiDFf@zNsoG]~BPLc}EwW{OcSTUIoB@s|lV[NAG~skIFPA`PedGiIAOu[ByP[LyKpL\\lJGivJi\
> xePSzJ{}H`zPAmuAoap]_HxYN]`gJbOTc?BcgKcKMbsjBKm?[r?kyDoqe{~?wG@|@A\\BF|KCCh\
> iG?DlS?wXGlUAXF`czIDYBCzkGNGdbDT\\e\\fGTNlWdlgHgcA@omE[Yapkm_`mpi`wUnHHkD|J\
> sUJeADpc_GWKxsN|XnCap?[E@H_MK?x?fpD`?fF{FB{DADfbw^geT?xNJEN`MXCU[AgUs@QOTyc\
> AP`KoK\\_gdN_HxNLgmKXCgxGi^tgCJHxTEoBimhKDOSuJhmRk]M}uBPfQ[YNUE_IYvXFf@zNso\
> G]~BPLc}ER|wocSPQiwq?x@lV[NAIrskyGQ|kshGhOxxFyHDNaTj`ny`\\lJGf@UcDVfX^fpKN\\
> \qUD]nJP");;
gap> M := DigraphMaximumMatching(D);; IsMaximalMatching(D, M);
true
gap> Length(M);
97
gap> D := DigraphFromDiSparse6String("\
> .~?B]_O?__B_S@`?E_kC_[A@[I_?H`CF_sD_cB@sA`c?@[IA{Y@CFAcE_gQ__Pc?A@{@BkLBcKB\
> [J`SW`?VasEAge_gSCkC_WQC[AAGa_GOCK?CCp@g]eCJD{IBWm`Gl`?XDcwAwi_gUDKTDCBA_fa\
> WeF[QCgy_?PCcOC[NCSMCK_`_^EcJBor`Oq`G[EKG_wn_om_gWDkCAwkG[BApA_OTDP@_GSDH?_\
> ?RD?~cw}aGeFkO`wcF[MCWy`hQ`_w`W_E{IBxNbotHsGBhL_w[E[EBXJ_gYEHI__XECBB?nHCAA\
> xFdhE_?TD`DKCSDXCJ{RDPBdHAJkPD@@JcOG@Z`{MCg}`gcFhW`_bF`V`WaF[y`KGBwwI[]ExQL\
> {EBhPLsDEhO__ZE`NLcrHpj_OX_GWEHKLKVE@JLCnHPfdpHa_lH@dd`FKdbaGiKShG``dCMCxAJ\
> {LCp|`_dJh{`W~J`z`ObFpZNSHCPx`?`F`X_w_J@vbwyIxuboxIptf@T_W[Exr_OZEpRMSYEhQM\
> K?IHob?rI@nhyNhsoHhkPljPcmHXiP[QDhILIIaHHLAHhCiGxedHEKiE`ggGhcOlCKYCgXaO[IC\
> hAKIA`GcKA@`?bG@^cP]_o`Fp\\_g|J`|SCCBw{JX{R{BNY]_O\\FPyRk@B_xNK?NAZbQYbKWEh\
> SMkVE`RQ{UEXQQsqIHqQkSEHOMISaWoHxoQ[nHpnaHLLqPa?lHaO`xJLaNdXjPqr`hHLQLh@hPa\
> p`WgLCICxfT{HGiHTsGChCKiGTkFC`BKak_obGPbT[aGHaOii__`G@`TKBC?~KABTC}JyAS{@Bo\
> |Jq@_?{OAdb_zJ`~ScZFP}S[YFH|SSXF@XNa`exWNY_awuI{UIpxRrDe`TNBCa_rI`vRcRIXuRZ\
> AaOpIPtWKPE@sRKODxOMYWV|NMQ}`olHqUVkkHhoQi{`_jH`nV[JDPJLsIDHlQQx`HHLaPVFWGx\
> i_odGqMUkcLALUcbG`fPar_WaGXeURZgPdPQpZV]_O?__B_o@_CE_kK@[@@S?`CP?sDACC@{B@s\
> A@k@@c?@[I`GU`?T_wS_oR_k^?WO_ONBs@@s?`cJBSIBKH`CFAof_oTCsDCkRCcBC[AAGa_K?@w\
> _`o^bsKBgobcm`GY`?XDcFB?j_oVDSUDKCDCBC{AAWeF[@AOdFS?AGcFKOFCv`o`EsLC?t`_^Ec\
> JE[\\b_p`?ZECYDxE_oXGkWDhC__kG[jGSAAgiGK@A_hGC?AWgaOffkOCg{c_zi[aFHQ`_`F@Pc\
> @ObwuH{HBot`?sHlK_oZEPJbOpHTH_WnHCAAwm_GUDhEd`DKCSG`^dPBJsQDHAJkPD@@JcfG@Z`\
> weFxY`odJKcFhW``V`WzIsICHT`G_FHS`?wI[FBovIPnbguIHmb_tLkCBWs_WYL[XEPLLS@B@KL\
> K?AxJaonK{TKslKkRDcQDXEK[PDPDKSO`xBKCfGP^NsLCp@JsKG@\\NcJC_~J`z`ObFsHCO|JPx\
> `?{JHw_w_F[EBxVMsDBoxIpt__\\IhsexSM\\R_GtISXE`oeXnawqHxmaopLiMahka_nH`jPcRH\
> YJaOlPSPDcODXGKyG`wiGxeO{MGpdOtDKcKCxCOcJCpachAgH_OL^OCFCO~N{`Fp}_g_Fh|SCCF\
> a^_W]FXYNY]bgyJLWRc?BWwIxwR[YExUMyYepTMqXb@SRCVE`RMcUIPrQsTEPPMSSe@NMARaPnQ\
> SPDpLLqPdhKLiO`wkLcMHSLDPiUSKDHGPcJD@FLAJUCICxEKyIT{HCpeTsGChd_wcGYFTcEGPbO\
> qj_gaGHaOii__`GACTKBC?~O[ABx^OS@Bp]OIe_?\\Ji?Sk[FX[NycbWyJ[YFHYNiaf@XNa`b?v\
> JA_epVNQ^WstRrDagsIi\\WcrRbBePRMqZaOpRR@aHPMaXWCnMYWV{NDpNMQVVsMDhpVkLD`LMA\
> TVcKHaSV[JDPmQYy`OhHPlVKHD@kQKGCxGLYOU{FCpFLQNUsEGphPsDC`DPkCKyKU[BPYqZ[ACH\
> APRY");;
gap> M := DigraphMaximumMatching(D);; IsMaximalMatching(D, M);
true
gap> Length(M);
111

# DigraphMaximumMatching: Issue #461, reported by Leonard Soicher on 2021-05-06.
# See https://github.com/digraphs/Digraphs/issues/461
gap> D := DigraphFromGraph6String("Cr");
<immutable symmetric digraph with 4 vertices, 8 edges>
gap> SetDigraphVertexLabels(D, [[1, 1], [2, 1], [1, 2], [2, 2]]);
gap> IsMaximumMatching(D, DigraphMaximumMatching(D));
true

# DigraphNrLoops
gap> D := EmptyDigraph(5);
<immutable empty digraph with 5 vertices>
gap> DigraphNrLoops(D);
0
gap> D := CompleteDigraph(5);
<immutable complete digraph with 5 vertices>
gap> DigraphNrLoops(D);
0
gap> D := Digraph([[2, 3], [1, 4], [3, 3, 5], [], [2, 5]]);
<immutable multidigraph with 5 vertices, 9 edges>
gap> DigraphNrLoops(D);
3
gap> D := Digraph([[2], [3], [1, 2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> DigraphNrLoops(D);
0
gap> D := Digraph([[1, 2], [2, 3], [3, 4], [1, 4, 5], [2, 5]]);
<immutable digraph with 5 vertices, 11 edges>
gap> DigraphNrLoops(D);
5
gap> D := Digraph([[1, 4, 4], [2, 2, 4], [4], [3, 5], [5]]);
<immutable multidigraph with 5 vertices, 10 edges>
gap> DigraphNrLoops(D);
4
gap> D := Digraph(IsMutableDigraph,
>                 [[1, 2], [2, 3], [3, 4], [1, 4, 5], [2, 5]]);
<mutable digraph with 5 vertices, 11 edges>
gap> DigraphNrLoops(D);
5
gap> D;
<mutable digraph with 5 vertices, 11 edges>
gap> D := DigraphByAdjacencyMatrix([
> [1, 2, 1],
> [1, 1, 0],
> [0, 0, 1]]);
<immutable multidigraph with 3 vertices, 7 edges>
gap> DigraphNrLoops(D);
3
gap> D := CompleteDigraph(IsImmutableDigraph, 3);
<immutable complete digraph with 3 vertices>
gap> DigraphHasLoops(D);
false
gap> HasDigraphHasLoops(D) and not DigraphHasLoops(D);
true
gap> DigraphNrLoops(D) = 0;
true

#  DigraphAddAllLoops
gap> gr := CompleteDigraph(10);
<immutable complete digraph with 10 vertices>
gap> OutNeighbours(gr)[1];
[ 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> gr2 := DigraphAddAllLoops(gr);
<immutable reflexive digraph with 10 vertices, 100 edges>
gap> OutNeighbours(gr2)[1];
[ 2, 3, 4, 5, 6, 7, 8, 9, 10, 1 ]
gap> gr3 := DigraphAddAllLoops(gr);
<immutable reflexive digraph with 10 vertices, 100 edges>
gap> OutNeighbours(gr3)[1];
[ 2, 3, 4, 5, 6, 7, 8, 9, 10, 1 ]
gap> gr := EmptyDigraph(100);
<immutable empty digraph with 100 vertices>
gap> DigraphAddAllLoops(gr);
<immutable reflexive digraph with 100 vertices, 100 edges>
gap> gr := Digraph([[1, 2, 3], [2, 2, 2, 2], [5, 1], [1, 2, 3, 4], [5]]);
<immutable multidigraph with 5 vertices, 14 edges>
gap> gr2 := DigraphAddAllLoops(gr);
<immutable reflexive multidigraph with 5 vertices, 15 edges>
gap> OutNeighbours(gr2);
[ [ 1, 2, 3 ], [ 2, 2, 2, 2 ], [ 5, 1, 3 ], [ 1, 2, 3, 4 ], [ 5 ] ]
gap> D := Digraph(IsImmutableDigraph,
> [[1, 3], [2, 1, 5], [3, 4], [2, 3, 4], [5, 1]]);;
gap> IsReflexiveDigraph(D);
true
gap> IsIdenticalObj(D, DigraphAddAllLoops(D));
false

# DigraphAddAllLoops - mutable
gap> D := Digraph(IsMutableDigraph,
> [[1], [3, 4], [5, 6], [4, 2, 3], [4, 5], [1]]);
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

# Semimodular lattices
gap> D := DigraphFromDigraph6String("&C[o?");
<immutable digraph with 4 vertices, 5 edges>
gap> IsUpperSemimodularDigraph(D);
false
gap> IsLowerSemimodularDigraph(D);
false
gap> NonUpperSemimodularPair(D);
Error, the argument (a digraph) is not a lattice
gap> NonLowerSemimodularPair(D);
Error, the argument (a digraph) is not a lattice
gap> D := DigraphFromDigraph6String("&K~~]mKaC_EgLb?_?~?g?m?a?b");
<immutable digraph with 12 vertices, 54 edges>
gap> IsUpperSemimodularDigraph(D);
true
gap> NonUpperSemimodularPair(D);
fail
gap> IsLowerSemimodularDigraph(D);
true
gap> NonLowerSemimodularPair(D);
fail
gap> D := DigraphFromDigraph6String("&M~~sc`lYUZO__KIBboC_@h?U_?_GL?A_?c");
<immutable digraph with 14 vertices, 66 edges>
gap> IsUpperSemimodularDigraph(D);
true
gap> IsLowerSemimodularDigraph(D);
false
gap> NonLowerSemimodularPair(D);
[ 10, 9 ]

# DigraphJoinTable and DigraphMeetTable
gap> D := DigraphReflexiveTransitiveClosure(ChainDigraph(4));
<immutable preorder digraph with 4 vertices, 10 edges>
gap> x := PartialOrderDigraphJoinOfVertices(D, 1, 3);
3
gap> y := PartialOrderDigraphMeetOfVertices(D, 3, 2);
2
gap> A := DigraphJoinTable(D);
[ [ 1, 2, 3, 4 ], [ 2, 2, 3, 4 ], [ 3, 3, 3, 4 ], [ 4, 4, 4, 4 ] ]
gap> B := DigraphMeetTable(D);
[ [ 1, 1, 1, 1 ], [ 1, 2, 2, 2 ], [ 1, 2, 3, 3 ], [ 1, 2, 3, 4 ] ]
gap> A[1, 3] = x;
true
gap> B[3, 2] = y;
true
gap> D := Digraph(IsMutable, [[2, 3], [4], [4], []]);
<mutable digraph with 4 vertices, 4 edges>
gap> DigraphReflexiveTransitiveClosure(D);
<mutable digraph with 4 vertices, 9 edges>
gap> x := PartialOrderDigraphJoinOfVertices(D, 2, 3);;
gap> y := PartialOrderDigraphMeetOfVertices(D, 2, 3);;
gap> z := PartialOrderDigraphMeetOfVertices(D, 1, 4);;
gap> A := DigraphJoinTable(D);
[ [ 1, 2, 3, 4 ], [ 2, 2, 4, 4 ], [ 3, 4, 3, 4 ], [ 4, 4, 4, 4 ] ]
gap> B := DigraphMeetTable(D);
[ [ 1, 1, 1, 1 ], [ 1, 2, 1, 2 ], [ 1, 1, 3, 3 ], [ 1, 2, 3, 4 ] ]
gap> D;
<mutable digraph with 4 vertices, 9 edges>
gap> A[2, 3] = x;
true
gap> B[2, 3] = y;
true
gap> B[1, 4] = z;
true
gap> D := ChainDigraph(3);
<immutable chain digraph with 3 vertices>
gap> DigraphJoinTable(D);
fail
gap> D := DigraphAddVertex(D, 4);
<immutable digraph with 4 vertices, 2 edges>
gap> D := DigraphAddEdge(D, [4, 3]);
<immutable digraph with 4 vertices, 3 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 4 vertices, 8 edges>
gap> x := PartialOrderDigraphJoinOfVertices(D, 1, 3);;
gap> y := PartialOrderDigraphJoinOfVertices(D, 1, 4);;
gap> z := PartialOrderDigraphJoinOfVertices(D, 1, 2);;
gap> A := DigraphJoinTable(D);
[ [ 1, 2, 3, 3 ], [ 2, 2, 3, 3 ], [ 3, 3, 3, 3 ], [ 3, 3, 3, 4 ] ]
gap> A[1, 3] = x;
true
gap> A[1, 4] = y;
true
gap> A[1, 2] = z;
true
gap> DigraphMeetTable(D);
fail
gap> D := DigraphFromDigraph6String(
> "&Q~~~VObJJtD?BB?`@?@?~~?Ob?Jt?E^?AT?@p??`??P??N??D??B??@");
<immutable digraph with 18 vertices, 97 edges>
gap> x := PartialOrderDigraphJoinOfVertices(D, 4, 8);;
gap> y := PartialOrderDigraphJoinOfVertices(D, 1, 10);;
gap> z := PartialOrderDigraphMeetOfVertices(D, 14, 15);;
gap> A := DigraphJoinTable(D);;
gap> B := DigraphMeetTable(D);;
gap> A[4, 8] = x;
true
gap> A[1, 10] = y;
true
gap> B[14, 15] = z;
true

# DigraphAbsorptionProbabilities
gap> gr := Digraph([[2, 3, 4], [3], [2], []]);
<immutable digraph with 4 vertices, 5 edges>
gap> DigraphStronglyConnectedComponents(gr).comps;  # this ordering is used
[ [ 2, 3 ], [ 4 ], [ 1 ] ]
gap> DigraphAbsorptionProbabilities(gr);
[ [ 2/3, 1/3, 0 ], [ 1, 0, 0 ], [ 1, 0, 0 ], [ 0, 1, 0 ] ]
gap> DigraphAbsorptionProbabilities(EmptyDigraph(0));
[  ]
gap> DigraphAbsorptionProbabilities(EmptyDigraph(1));
[ [ 1 ] ]
gap> DigraphAbsorptionProbabilities(CompleteDigraph(5));
[ [ 1 ], [ 1 ], [ 1 ], [ 1 ], [ 1 ] ]
gap> DigraphAbsorptionProbabilities(ChainDigraph(4));
[ [ 0, 0, 0, 1 ], [ 0, 0, 0, 1 ], [ 0, 0, 0, 1 ], [ 0, 0, 0, 1 ] ]
gap> DigraphAbsorptionProbabilities(CycleDigraph(5));
[ [ 1 ], [ 1 ], [ 1 ], [ 1 ], [ 1 ] ]
gap> gr := ChainDigraph(250);;
gap> probs := DigraphAbsorptionProbabilities(gr);;
gap> scc := DigraphStronglyConnectedComponents(gr);;
gap> sink := DigraphSinks(gr)[1];;
gap> ForAll(probs,  # all zeros except for the sink
>           v -> ForAll([1 .. 250],
>                       comp -> v[comp] = 0
>                       or (v[comp] = 1 and scc.id[comp] = sink)));
true
gap> gr := Digraph([[1], []]);;
gap> DigraphAbsorptionProbabilities(gr);
[ [ 1, 0 ], [ 0, 1 ] ]

# DigraphAbsorptionExpectedSteps
gap> DigraphAbsorptionExpectedSteps(Digraph([[2], [3], [2]]));
[ 1, 0, 0 ]
gap> DigraphAbsorptionExpectedSteps(Digraph([]));
[  ]
gap> DigraphAbsorptionExpectedSteps(Digraph([[1]]));
[ 0 ]
gap> DigraphAbsorptionExpectedSteps(Digraph([[1, 2], [2]]));
[ 2, 0 ]
gap> DigraphAbsorptionExpectedSteps(ChainDigraph(5));
[ 4, 3, 2, 1, 0 ]
gap> DigraphAbsorptionExpectedSteps(CompleteDigraph(5));
[ 0, 0, 0, 0, 0 ]

# DigraphAbsorptionExpectedSteps: mutable digraphs
gap> gr := Digraph(IsMutableDigraph, [[1, 2], [2]]);;
gap> IsMutableDigraph(gr);
true
gap> DigraphAbsorptionExpectedSteps(gr);
[ 2, 0 ]
gap> DigraphAbsorptionExpectedSteps(gr);
[ 2, 0 ]
gap> DigraphAddEdge(gr, [2, 1]);;
gap> DigraphAbsorptionExpectedSteps(gr);
[ 0, 0 ]
gap> DigraphAbsorptionExpectedSteps(gr);
[ 0, 0 ]

# Absorption motivating example: game of 'Soccer Dice'
gap> soccer := Digraph([[7, 2, 3, 5, 1, 4],
>                       [7, 2, 3, 5, 5, 4],
>                       [7, 5, 5, 5, 5, 1],
>                       [7, 7, 2, 5, 5, 5],
>                       [6, 6, 7, 7, 7, 4],
>                       [], []]);;
gap> DigraphStronglyConnectedComponents(soccer).comps;  # this ordering is used
[ [ 7 ], [ 6 ], [ 1, 2, 3, 5, 4 ] ]
gap> DigraphAbsorptionProbabilities(soccer) =
>     [[3473 / 4493, 1020 / 4493, 0],
>      [3365 / 4493, 1128 / 4493, 0],
>      [3211 / 4493, 1282 / 4493, 0],
>      [3471 / 4493, 1022 / 4493, 0],
>      [2825 / 4493, 1668 / 4493, 0],
>      [0, 1, 0],
>      [1, 0, 0]];
true
gap> DigraphAbsorptionExpectedSteps(soccer);
[ 13026/4493, 11868/4493, 10716/4493, 9510/4493, 6078/4493, 0, 0 ]

# Absorption motivating example: a flea on the vertices of a dodecahedron.
gap> gr := Digraph("dodecahedral");;
gap> gr := DigraphRemoveEdges(gr, List(OutNeighbours(gr)[1], v -> [1, v]));
<immutable digraph with 20 vertices, 57 edges>
gap> DigraphAbsorptionExpectedSteps(gr)[1];
0
gap> DigraphAbsorptionExpectedSteps(gr)[2];
19

# Test Digraphs above the max size
gap> DigraphHomomorphism(NullDigraph(65555), NullDigraph(1));
Error, the 1st argument <digraph1> must have at most 65534 vertices, found 655\
55,
gap> DigraphHomomorphism(NullDigraph(1), NullDigraph(65555));
Error, the 2nd argument <digraph2> must have at most 65534 vertices, found 655\
55,

# Test Digraph hashing
# This has a small chance to randomly fail. Sorry if it does!
gap> D1 := RandomMultiDigraph(100);;
gap> D2 := Digraph(List(OutNeighbours(D1), x -> Shuffle(ShallowCopy(x))));;
gap> D1 = D2;
true
gap> OutNeighbours(D1) = OutNeighbours(D2);
false
gap> DigraphHash(D1) = DigraphHash(D2);
true
gap> while D1 = D2 do
> D2 := RandomMultiDigraph(100);
> od;;
gap> DigraphHash(D1) = DigraphHash(D2);
false

# Unbind local variables, auto-generated by etc/tst-unbind-local-vars.py
gap> Unbind(A);
gap> Unbind(B);
gap> Unbind(D);
gap> Unbind(D1);
gap> Unbind(D2);
gap> Unbind(G);
gap> Unbind(H);
gap> Unbind(M);
gap> Unbind(M1);
gap> Unbind(P);
gap> Unbind(S);
gap> Unbind(a);
gap> Unbind(adj);
gap> Unbind(adj1);
gap> Unbind(adj2);
gap> Unbind(adjacencies);
gap> Unbind(b);
gap> Unbind(circuit);
gap> Unbind(complete15);
gap> Unbind(comps);
gap> Unbind(cycle12);
gap> Unbind(e);
gap> Unbind(erev);
gap> Unbind(filename);
gap> Unbind(forest);
gap> Unbind(g);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(gr3);
gap> Unbind(gr4);
gap> Unbind(grid);
gap> Unbind(group);
gap> Unbind(i);
gap> Unbind(id);
gap> Unbind(isGraph);
gap> Unbind(j);
gap> Unbind(mat);
gap> Unbind(multiple);
gap> Unbind(names);
gap> Unbind(nbs);
gap> Unbind(order);
gap> Unbind(probs);
gap> Unbind(proj);
gap> Unbind(r);
gap> Unbind(rd);
gap> Unbind(reflextrans);
gap> Unbind(reflextrans1);
gap> Unbind(reflextrans2);
gap> Unbind(representatives);
gap> Unbind(rev);
gap> Unbind(rgr);
gap> Unbind(scc);
gap> Unbind(schreierVector);
gap> Unbind(sink);
gap> Unbind(soccer);
gap> Unbind(str);
gap> Unbind(temp);
gap> Unbind(topo);
gap> Unbind(trans);
gap> Unbind(trans1);
gap> Unbind(trans2);
gap> Unbind(tree);
gap> Unbind(wcc);
gap> Unbind(x);
gap> Unbind(y);
gap> Unbind(z);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/attr.tst", 0);
