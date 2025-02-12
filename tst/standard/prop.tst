#############################################################################
##
#W  standard/prop.tst
#Y  Copyright (C) 2014-21                                James D. Mitchell
##                                                          Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/prop.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#  IsChainDigraph
gap> IsChainDigraph(ChainDigraph(1));
true
gap> IsChainDigraph(ChainDigraph(7));
true
gap> IsChainDigraph(CycleDigraph(1));
false
gap> IsChainDigraph(CycleDigraph(7));
false
gap> IsChainDigraph(Digraph([[2], [3], [4], [5], [5]]));
false
gap> IsChainDigraph(Digraph([[2, 3], [4], [5], [], []]));
false
gap> IsChainDigraph(Digraph([[2], [3, 4], [], []]));
false
gap> G := QuaternionGroup(8);
<pc group of size 8 with 3 generators>
gap> IsChainDigraph(CayleyDigraph(G));
false
gap> IsChainDigraph(DigraphReverse(ChainDigraph(21)));
true
gap> IsChainDigraph(Digraph([[], [3], [4], []]));
false
gap> IsChainDigraph(Digraph([[2], [3], [4], []]));
true

#  IsMultiDigraph
gap> gr1 := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> IsMultiDigraph(gr1);
false
gap> gr2 := Digraph([[]]);
<immutable empty digraph with 1 vertex>
gap> IsMultiDigraph(gr2);
false
gap> source := [1 .. 10000];;
gap> range := List(source, x -> Random(source));;
gap> r := rec (DigraphVertices := [1 .. 10000],
>              DigraphSource   := source,
>              DigraphRange    := range);;
gap> gr3 := Digraph(r);
<immutable digraph with 10000 vertices, 10000 edges>
gap> IsMultiDigraph(gr3);
false
gap> Add(source, 10000);;
gap> Add(range, range[10000]);;
gap> r := rec(DigraphVertices := [1 .. 10000],
>             DigraphSource   := source,
>             DigraphRange    := range);;
gap> gr4 := Digraph(r);
<immutable multidigraph with 10000 vertices, 10001 edges>
gap> IsMultiDigraph(gr4);
true

#  IsAcyclicDigraph
gap> D := Digraph([[2], [1]]);;
gap> IsStronglyConnectedDigraph(D);;
gap> IsAcyclicDigraph(D);
false
gap> loop := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> IsMultiDigraph(loop);
false
gap> IsAcyclicDigraph(loop);
false
gap> r := rec(DigraphVertices := [1, 2],
>             DigraphSource   := [1, 1],
>             DigraphRange    := [2, 2]);;
gap> multiple := Digraph(r);
<immutable multidigraph with 2 vertices, 2 edges>
gap> IsMultiDigraph(multiple);
true
gap> IsAcyclicDigraph(multiple);
true
gap> r := rec(DigraphVertices := [1 .. 100],
>             DigraphSource   := [],
>             DigraphRange    := []);;
gap> for i in [1 .. 100] do
>   for j in [1 .. 100] do
>     Add(r.DigraphSource, i);
>     Add(r.DigraphRange, j);
>   od;
> od;
gap> complete100 := Digraph(r);
<immutable digraph with 100 vertices, 10000 edges>
gap> IsMultiDigraph(complete100);
false
gap> IsAcyclicDigraph(complete100);
false
gap> r := rec(DigraphVertices := [1 .. 20000],
>             DigraphSource   := [],
>             DigraphRange    := []);;
gap> for i in [1 .. 9999] do
>   Add(r.DigraphSource, i);
>   Add(r.DigraphRange, i + 1);
> od;
> Add(r.DigraphSource, 10000);;
> Add(r.DigraphRange, 20000);;
> Add(r.DigraphSource, 10002);;
> Add(r.DigraphRange, 15000);;
> Add(r.DigraphSource, 10001);;
> Add(r.DigraphRange, 1);;
> for i in [10001 .. 19999] do
>   Add(r.DigraphSource, i);
>   Add(r.DigraphRange, i + 1);
> od;
gap> circuit := Digraph(r);
<immutable digraph with 20000 vertices, 20001 edges>
gap> IsMultiDigraph(circuit);
false
gap> IsAcyclicDigraph(circuit);
true
gap> r := rec(DigraphNrVertices := 8,
> DigraphSource := [1, 1, 1, 2, 3, 4, 4, 5, 7, 7],
> DigraphRange := [4, 3, 4, 8, 2, 2, 6, 7, 4, 8]);;
gap> grid := Digraph(r);
<immutable multidigraph with 8 vertices, 10 edges>
gap> IsMultiDigraph(grid);
true
gap> IsAcyclicDigraph(grid);
true
gap> gr := Digraph([[1]]);;
gap> DigraphHasLoops(gr);
true
gap> HasIsAcyclicDigraph(gr);
true
gap> IsAcyclicDigraph(gr);
false
gap> gr := Digraph([[2], []]);
<immutable digraph with 2 vertices, 1 edge>
gap> IsTournament(gr);
true
gap> IsTransitiveDigraph(gr);
true
gap> HasIsAcyclicDigraph(gr);
true
gap> IsAcyclicDigraph(gr);
true
gap> gr := Digraph([[2], []]);
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphStronglyConnectedComponents(gr);
rec( comps := [ [ 2 ], [ 1 ] ], id := [ 2, 1 ] )
gap> HasIsStronglyConnectedDigraph(gr);
true
gap> IsStronglyConnectedDigraph(gr);
false
gap> IsAcyclicDigraph(gr);
true
gap> gr := Digraph([[1, 2], []]);
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphStronglyConnectedComponents(gr);
rec( comps := [ [ 2 ], [ 1 ] ], id := [ 2, 1 ] )
gap> IsAcyclicDigraph(gr);
false
gap> gr := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphStronglyConnectedComponents(gr);
rec( comps := [ [ 1, 2 ] ], id := [ 1, 1 ] )
gap> HasIsStronglyConnectedDigraph(gr);
true
gap> IsStronglyConnectedDigraph(gr);
true
gap> IsAcyclicDigraph(gr);
false
gap> gr := Digraph([
> [9, 10], [8], [4], [1, 7, 8], [], [5], [], [6], [], [4, 8]]);
<immutable digraph with 10 vertices, 11 edges>
gap> DigraphTopologicalSort(gr);
fail
gap> HasIsAcyclicDigraph(gr);
false
gap> IsAcyclicDigraph(gr);
false

#  IsFunctionalDigraph
gap> IsFunctionalDigraph(multiple);
false
gap> IsFunctionalDigraph(grid);
false
gap> IsFunctionalDigraph(circuit);
false
gap> IsFunctionalDigraph(loop);
true
gap> gr := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> IsFunctionalDigraph(gr);
true
gap> r := rec(DigraphVertices := [1 .. 10],
> DigraphSource :=
> [1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5,
> 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 10, 10,
> 10, 10, 10, 10],
> DigraphRange :=
> [6, 7, 6, 9, 1, 3, 4, 5, 8, 9, 1, 2, 3, 4, 5, 6, 7, 10, 1, 5, 6, 7, 10, 2,
> 4, 5, 9, 10, 3, 4, 5, 6, 7, 8, 9, 10, 1, 3, 5, 7, 8, 9, 1, 2, 5, 1, 2,
> 4, 6, 7, 8]);;
gap> g1 := Digraph(r);
<immutable digraph with 10 vertices, 51 edges>
gap> IsFunctionalDigraph(g1);
false
gap> g2 := Digraph(OutNeighbours(g1));
<immutable digraph with 10 vertices, 51 edges>
gap> IsFunctionalDigraph(g2);
false
gap> g3 := Digraph([[1], [3], [2], [2]]);
<immutable digraph with 4 vertices, 4 edges>
gap> IsFunctionalDigraph(g3);
true
gap> g4 := Digraph(rec(DigraphVertices := [1 .. 3],
> DigraphSource := [3, 2, 1], DigraphRange := [2, 1, 3]));
<immutable digraph with 3 vertices, 3 edges>
gap> IsFunctionalDigraph(g4);
true
gap> g5 := Digraph(rec(DigraphVertices := [1 .. 3],
> DigraphSource := [3, 2, 2], DigraphRange := [2, 1, 3]));
<immutable digraph with 3 vertices, 3 edges>
gap> IsFunctionalDigraph(g5);
false

#  IsPermutationDigraph
gap> D := CompleteDigraph(5);
<immutable complete digraph with 5 vertices>
gap> IsPermutationDigraph(D);
false
gap> IsPermutationDigraph(CycleDigraph(5));
true
gap> IsPermutationDigraph(NullDigraph(1));
false
gap> IsPermutationDigraph(g1);
false
gap> IsPermutationDigraph(g2);
false
gap> IsPermutationDigraph(g3);
false
gap> IsPermutationDigraph(g4);
true
gap> IsPermutationDigraph(g5);
false

#  IsSymmetricDigraph
gap> IsSymmetricDigraph(g1);
false
gap> IsSymmetricDigraph(g2);
false
gap> IsSymmetricDigraph(g3);
false
gap> IsSymmetricDigraph(g4);
false
gap> IsSymmetricDigraph(g5);
false
gap> IsSymmetricDigraph(loop);
true
gap> IsSymmetricDigraph(multiple);
false
gap> g6 := Digraph([[1, 2, 4], [1, 3], [2, 3, 4], [3, 1]]);
<immutable digraph with 4 vertices, 10 edges>
gap> IsSymmetricDigraph(g6);
true
gap> gr := Digraph(rec(DigraphNrVertices := 3,
>                      DigraphSource     := [1, 1, 2, 2, 2, 2, 3, 3],
>                      DigraphRange      := [2, 2, 1, 1, 3, 3, 2, 2]));;
gap> IsSymmetricDigraph(gr);
true
gap> D := Digraph([[2], [3], [2]]);;
gap> IsSymmetricDigraph(D);
false
gap> D := Digraph([[2], [2], [2]]);;
gap> IsSymmetricDigraph(D);
false
gap> D := Digraph([[2], [2], [1]]);;
gap> IsSymmetricDigraph(D);
false
gap> D := CycleDigraph(3);;
gap> AdjacencyMatrix(D);;
gap> IsSymmetricDigraph(D);
false
gap> D := Digraph([[2, 3], [1, 2, 3], [1, 2]]);;
gap> AdjacencyMatrix(D);;
gap> IsSymmetricDigraph(D);
true
gap> D := Digraph([[2], [2], [2]]);;
gap> AdjacencyMatrix(D);;
gap> IsSymmetricDigraph(D);
false
gap> D := Digraph([[2], [2], [2, 1]]);;
gap> IsSymmetricDigraph(D);
false

#  IsAntisymmetricDigraph
gap> gr := Digraph(rec(DigraphNrVertices := 10,
>  DigraphSource := [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 5, 5, 5, 5,
>                    5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9,
>                    9, 9, 10, 10, 10, 10, 10],
>  DigraphRange  := [2, 4, 6, 10, 3, 5, 7, 4, 7, 1, 9, 10, 4, 6, 9, 8, 4, 3, 7,
>                    1, 6, 8, 2, 3, 9, 7, 10, 9, 4, 1, 8, 9, 3, 1, 4, 2, 5, 2,
>                    1, 10, 5, 6, 2, 4, 8]));
<immutable digraph with 10 vertices, 45 edges>
gap> IsAntisymmetricDigraph(gr);
true
gap> gr := Digraph([[1, 1, 1, 2, 2], [2, 3], [3, 3, 4], [4, 2]]);
<immutable multidigraph with 4 vertices, 12 edges>
gap> IsAntisymmetricDigraph(gr);
true
gap> gr := Digraph([[1, 1, 1, 2, 2], [2, 3], [3, 3, 4], [4, 3]]);
<immutable multidigraph with 4 vertices, 12 edges>
gap> IsAntisymmetricDigraph(gr);
false
gap> gr := Digraph([[2, 3], [3], [1]]);
<immutable digraph with 3 vertices, 4 edges>
gap> IsAntisymmetricDigraph(gr);
false
gap> gr := Digraph([[2], [3], [1, 2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> IsAntisymmetricDigraph(gr);
false
gap> gr := Digraph([[1, 1, 1, 1, 2], [2, 2]]);
<immutable multidigraph with 2 vertices, 7 edges>
gap> IsAntisymmetricDigraph(gr);
true
gap> gr := Digraph([[1, 1, 1, 1, 2], [2, 2, 2, 1]]);
<immutable multidigraph with 2 vertices, 9 edges>
gap> IsAntisymmetricDigraph(gr);
false

#  IsEmptyDigraph
gap> gr1 := Digraph(rec(DigraphNrVertices := 5,
>                       DigraphSource     := [],
>                       DigraphRange      := []));;
gap> IsEmptyDigraph(gr1);
true
gap> gr2 := Digraph(rec(DigraphVertices := [1 .. 6],
>                       DigraphSource   := [6],
>                       DigraphRange    := [1]));;
gap> IsEmptyDigraph(gr2);
false
gap> gr3 := DigraphNC([[], [], [], []]);;
gap> IsEmptyDigraph(gr3);
true
gap> gr4 := DigraphNC([[], [3], [1]]);;
gap> IsEmptyDigraph(gr4);
false
gap> gr5 := DigraphByAdjacencyMatrix([[0, 0], [0, 0]]);
<immutable empty digraph with 2 vertices>
gap> IsEmptyDigraph(gr5);
true
gap> gr6 := DigraphByEdges([[3, 5], [1, 1], [2, 3], [5, 4]]);
<immutable digraph with 5 vertices, 4 edges>
gap> IsEmptyDigraph(gr6);
false

#  IsTournament
gap> gr := Digraph(rec(DigraphNrVertices := 2,
>                      DigraphSource     := [1, 1],
>                      DigraphRange      := [2, 2]));
<immutable multidigraph with 2 vertices, 2 edges>
gap> IsTournament(gr);
false
gap> gr := Digraph([[2], [1], [1, 2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> IsTournament(gr);
false
gap> gr := Digraph([[2, 3], [3], []]);
<immutable digraph with 3 vertices, 3 edges>
gap> IsAcyclicDigraph(gr);
true
gap> IsTournament(gr);
true
gap> gr := EmptyDigraph(0);;
gap> IsTournament(gr);
true
gap> gr := Digraph([[1], []]);
<immutable digraph with 2 vertices, 1 edge>
gap> IsTournament(gr);
false
gap> gr := EmptyDigraph(1);
<immutable empty digraph with 1 vertex>
gap> HasIsTournament(gr);
false
gap> IsTournament(gr);
true
gap> gr := Digraph([[2], [3], [1]]);
<immutable digraph with 3 vertices, 3 edges>
gap> IsTournament(gr);
true
gap> gr := Digraph([[2], [1], [1]]);
<immutable digraph with 3 vertices, 3 edges>
gap> IsTournament(gr);
false

#  IsStronglyConnectedDigraph
gap> gr := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> IsStronglyConnectedDigraph(gr);
true
gap> adj := [[3, 4, 5, 7, 10], [4, 5, 10], [1, 2, 4, 7], [2, 9],
> [4, 5, 8, 9], [1, 3, 4, 5, 6], [1, 2, 4, 6],
> [1, 2, 3, 4, 5, 6, 7, 9], [2, 4, 8], [4, 5, 6, 8, 11], [10]];;
gap> gr := Digraph(adj);
<immutable digraph with 11 vertices, 44 edges>
gap> IsStronglyConnectedDigraph(gr);
true
gap> IsStronglyConnectedDigraph(multiple);
false
gap> IsStronglyConnectedDigraph(grid);
false
gap> IsStronglyConnectedDigraph(circuit);
false
gap> IsStronglyConnectedDigraph(loop);
true
gap> r := rec(DigraphNrVertices := 9,
> DigraphRange := [1, 7, 6, 9, 4, 8, 2, 5, 8, 9, 3, 9, 4, 8, 1, 1, 3],
> DigraphSource := [1, 1, 2, 2, 4, 4, 5, 6, 6, 6, 7, 7, 8, 8, 9, 9, 9]);;
gap> gr := Digraph(r);
<immutable multidigraph with 9 vertices, 17 edges>
gap> IsStronglyConnectedDigraph(gr);
false
gap> gr := CycleDigraph(10000);;
gap> gr2 := DigraphRemoveEdge(gr, 10000, 1);
<immutable digraph with 10000 vertices, 9999 edges>
gap> IsStronglyConnectedDigraph(gr2);
false
gap> gr2 := DigraphRemoveEdge(gr, 10000, 1);
<immutable digraph with 10000 vertices, 9999 edges>
gap> IsAcyclicDigraph(gr2);
true
gap> IsStronglyConnectedDigraph(gr2);
false
gap> gr := Digraph([[2], []]);
<immutable digraph with 2 vertices, 1 edge>
gap> HasIsAcyclicDigraph(gr);
false
gap> IsTournament(gr);
true
gap> HasIsAcyclicDigraph(gr);
false
gap> IsTransitiveDigraph(gr);
true
gap> HasIsAcyclicDigraph(gr);
true
gap> IsAcyclicDigraph(gr);
true
gap> HasIsStronglyConnectedDigraph(gr);
false
gap> IsStronglyConnectedDigraph(gr);
false

#  IsReflexiveDigraph
gap> r := rec(DigraphVertices := [1 .. 5],
> DigraphSource := [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5],
> DigraphRange := [1, 2, 3, 1, 2, 5, 1, 3, 5, 2, 3, 4, 1, 2, 2]);;
gap> gr := Digraph(r);
<immutable multidigraph with 5 vertices, 15 edges>
gap> IsReflexiveDigraph(gr);
false
gap> r := rec(DigraphNrVertices := 4,
> DigraphSource := [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4],
> DigraphRange := [1, 2, 3, 1, 2, 2, 1, 2, 4, 1, 1, 4]);;
gap> gr := Digraph(r);
<immutable multidigraph with 4 vertices, 12 edges>
gap> IsReflexiveDigraph(gr);
false
gap> r := rec(DigraphNrVertices := 5,
> DigraphSource := [1, 1, 1, 2, 2, 3, 3, 3, 4, 5, 5, 5],
> DigraphRange := [1, 1, 3, 2, 5, 1, 3, 5, 4, 1, 5, 2]);;
gap> gr := Digraph(r);
<immutable multidigraph with 5 vertices, 12 edges>
gap> IsReflexiveDigraph(gr);
true
gap> gr := EmptyDigraph(0);
<immutable empty digraph with 0 vertices>
gap> IsReflexiveDigraph(gr);
true
gap> gr := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> HasIsAcyclicDigraph(gr) and IsAcyclicDigraph(gr);
true
gap> IsReflexiveDigraph(gr);
true
gap> HasIsAcyclicDigraph(gr);
true
gap> IsAcyclicDigraph(gr);
true
gap> gr := Digraph([]);;
gap> IsAcyclicDigraph(gr);
true
gap> adj := [[2, 1], [1, 3], []];;
gap> gr := Digraph(adj);
<immutable digraph with 3 vertices, 4 edges>
gap> IsReflexiveDigraph(gr);
false
gap> adj := [[4, 2, 3, 1], [2, 3], [1, 3], [4]];;
gap> gr := Digraph(adj);
<immutable digraph with 4 vertices, 9 edges>
gap> IsReflexiveDigraph(gr);
true
gap> mat := [[2, 1, 0], [0, 1, 0], [0, 0, 0]];;
gap> gr := DigraphByAdjacencyMatrix(mat);
<immutable multidigraph with 3 vertices, 4 edges>
gap> IsReflexiveDigraph(gr);
false
gap> mat := [[2, 0, 3, 1], [1, 1, 0, 2], [3, 0, 4, 0], [9, 1, 2, 1]];;
gap> gr := DigraphByAdjacencyMatrix(mat);
<immutable multidigraph with 4 vertices, 30 edges>
gap> IsReflexiveDigraph(gr);
true

#  IsCompleteDigraph
gap> gr := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> IsCompleteDigraph(gr);
true
gap> gr := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> IsCompleteDigraph(gr);
false
gap> gr := Digraph([[1, 2], [1]]);
<immutable digraph with 2 vertices, 3 edges>
gap> IsCompleteDigraph(gr);
false
gap> gr := Digraph([[1, 2], []]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsCompleteDigraph(gr);
false
gap> gr := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsCompleteDigraph(gr);
true

#  IsConnectedDigraph
gap> gr := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> IsConnectedDigraph(gr);
true
gap> gr := Digraph([[]]);
<immutable empty digraph with 1 vertex>
gap> IsConnectedDigraph(gr);
true
gap> gr := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> IsConnectedDigraph(gr);
true
gap> gr := Digraph([[1, 1]]);
<immutable multidigraph with 1 vertex, 2 edges>
gap> IsConnectedDigraph(gr);
true
gap> gr := Digraph([[1], [2]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsStronglyConnectedDigraph(gr);
false
gap> IsConnectedDigraph(gr);
false
gap> gr := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsStronglyConnectedDigraph(gr);
true
gap> HasIsConnectedDigraph(gr);
true
gap> IsConnectedDigraph(gr);
true
gap> gr := Digraph([[2], [3], [], []]);
<immutable digraph with 4 vertices, 2 edges>
gap> IsConnectedDigraph(gr);
false
gap> gr := Digraph([[2], [3], [], [3]]);
<immutable digraph with 4 vertices, 3 edges>
gap> IsConnectedDigraph(gr);
true
gap> gr := Digraph([[2], [3], [], [3]]);
<immutable digraph with 4 vertices, 3 edges>
gap> DigraphConnectedComponents(gr);
rec( comps := [ [ 1, 2, 3, 4 ] ], id := [ 1, 1, 1, 1 ] )
gap> HasIsConnectedDigraph(gr);
true
gap> IsConnectedDigraph(gr);
true

#  DigraphHasLoops
gap> gr := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> DigraphHasLoops(gr);
false
gap> gr := Digraph([[]]);
<immutable empty digraph with 1 vertex>
gap> DigraphHasLoops(gr);
false
gap> gr := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> DigraphHasLoops(gr);
true
gap> gr := Digraph([[6, 7], [6, 9], [1, 2, 4, 5, 8, 9],
> [1, 2, 3, 4, 5, 6, 7, 10], [1, 5, 6, 7, 10], [2, 4, 5, 9, 10],
> [3, 4, 5, 6, 7, 8, 9, 10], [1, 3, 5, 7, 8, 9], [1, 2, 5],
> [1, 2, 4, 6, 7, 8]]);
<immutable digraph with 10 vertices, 51 edges>
gap> DigraphHasLoops(gr);
true
gap> gr := Digraph([[6, 7], [6, 9], [1, 2, 4, 5, 8, 9],
> [1, 2, 3, 7, 5, 6, 7, 10], [1, 2, 2, 6, 7, 10], [2, 4, 5, 9, 10],
> [3, 4, 5, 6, 8, 8, 9, 10], [1, 1, 3, 5, 7, 6, 9], [1, 1, 1, 2, 5],
> [1, 2, 4, 6, 7, 8]]);
<immutable multidigraph with 10 vertices, 55 edges>
gap> DigraphHasLoops(gr);
false
gap> gr := Digraph(rec(DigraphNrVertices := 0,
>                      DigraphSource     := [],
>                      DigraphRange      := []));
<immutable empty digraph with 0 vertices>
gap> DigraphHasLoops(gr);
false
gap> gr := Digraph(rec(DigraphNrVertices := 1,
>                      DigraphSource     := [],
>                      DigraphRange      := []));
<immutable empty digraph with 1 vertex>
gap> DigraphHasLoops(gr);
false
gap> gr := Digraph(rec(DigraphNrVertices := 1,
>                      DigraphSource     := [1],
>                      DigraphRange      := [1]));
<immutable digraph with 1 vertex, 1 edge>
gap> DigraphHasLoops(gr);
true
gap> r := rec(DigraphNrVertices := 10,
> DigraphSource :=
> [1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6,
>  6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 10, 10, 10, 10,
>  10, 10],
> DigraphRange := [6, 7, 6, 9, 1, 2, 4, 5, 8, 9, 1, 2, 3, 4, 5, 6, 7, 10, 1, 5,
>  6, 7, 10, 2, 4, 5, 9, 10, 3, 4, 5, 6, 7, 8, 9, 10, 1, 3, 5, 7, 8, 9, 1, 2, 5,
>  1, 2, 4, 6, 7, 8]);;
gap> gr := Digraph(r);
<immutable digraph with 10 vertices, 51 edges>
gap> DigraphHasLoops(gr);
true
gap> gr := Digraph(r);;
gap> AdjacencyMatrix(gr);;
gap> DigraphHasLoops(gr);
true
gap> r := rec(DigraphNrVertices := 10,
> DigraphSource :=
> [1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 6,
>  6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10,
>  10, 10, 10, 10, 10],
> DigraphRange :=
> [6, 7, 6, 9, 1, 2, 4, 5, 8, 9, 1, 2, 3, 7, 5, 6, 7, 10, 1, 2, 2, 6, 7, 10,
>  2, 4, 5, 9, 10, 3, 4, 5, 6, 8, 8, 9, 10, 1, 1, 3, 5, 7, 6, 9, 1, 1, 1, 2,
>  5, 1, 2, 4, 6, 7, 8]);;
gap> gr := Digraph(r);
<immutable multidigraph with 10 vertices, 55 edges>
gap> DigraphHasLoops(gr);
false
gap> gr := Digraph(r);;
gap> AdjacencyMatrix(gr);;
gap> DigraphHasLoops(gr);
false

#  IsAperiodicDigraph
gap> gr := Digraph([[2], [3], [4], [5], [6], [1], [8], [7]]);
<immutable digraph with 8 vertices, 8 edges>
gap> IsAperiodicDigraph(gr);
false
gap> gr := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> IsAperiodicDigraph(gr);
true
gap> gr := Digraph([[2, 2], [3, 3], [1], [5], [4, 4, 4]]);
<immutable multidigraph with 5 vertices, 9 edges>
gap> IsAperiodicDigraph(gr);
true
gap> gr := Digraph([[2, 2], [3, 3], [4], []]);
<immutable multidigraph with 4 vertices, 5 edges>
gap> IsAperiodicDigraph(gr);
false

#  IsTransitiveDigraph
gap> gr := Digraph([[2, 3, 4], [3, 4], [4], [4]]);
<immutable digraph with 4 vertices, 7 edges>
gap> IsTransitiveDigraph(gr);
true
gap> gr := Digraph([[2, 3, 4], [3, 4, 1], [4], [4]]);
<immutable digraph with 4 vertices, 8 edges>
gap> IsTransitiveDigraph(gr);
false
gap> gr := Digraph([[1, 1]]);
<immutable multidigraph with 1 vertex, 2 edges>
gap> IsTransitiveDigraph(gr);
true
gap> gr := Digraph([[2, 2], [1, 1]]);;
gap> IsTransitiveDigraph(gr);
false
gap> gr := Digraph([[1, 2, 2], [1, 2]]);;
gap> IsTransitiveDigraph(gr);
true
gap> gr := Digraph(
> [[2, 4, 5, 7], [4, 6, 9, 10, 12, 14], [2, 5, 6, 7, 8], [9],
>   [2, 7, 10, 11, 12], [4, 9, 13, 16, 18, 19, 22, 23, 26, 28, 30],
>   [2, 4, 6, 10], [2, 4, 11], [], [4, 9, 13, 15, 19, 21, 22, 24],
>   [2, 4, 14], [4, 9, 15, 17, 20, 21, 24, 25, 27, 29, 31], [4, 9],
>   [4, 9, 16, 17, 18, 20, 23, 25, 26, 27, 28, 29, 30, 31], [4, 9], [4],
>   [4], [4], [4, 9], [4], [4, 9], [4, 9], [4], [4, 9], [4],
>   [4], [4], [4], [4, 29], [4], [4]]);
<immutable digraph with 31 vertices, 100 edges>
gap> IsTransitiveDigraph(gr);
false
gap> trans := Digraph([
> [2, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
>   24, 25, 26, 27, 28, 29, 30, 31],
> [4, 6, 9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
>   27, 28, 29, 30, 31],
> [2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22,
>   23, 24, 25, 26, 27, 28, 29, 30, 31],
> [9],
> [2, 4, 6, 7, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
>   24, 25, 26, 27, 28, 29, 30, 31],
> [4, 9, 13, 16, 18, 19, 22, 23, 26, 28, 30],
> [2, 4, 6, 9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
>   26, 27, 28, 29, 30, 31],
> [2, 4, 6, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
>   25, 26, 27, 28, 29, 30, 31],
> [],
> [4, 9, 13, 15, 19, 21, 22, 24],
> [2, 4, 6, 9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
>   26, 27, 28, 29, 30, 31],
> [4, 9, 15, 17, 20, 21, 24, 25, 27, 29, 31],
> [4, 9],
> [4, 9, 16, 17, 18, 20, 23, 25, 26, 27, 28, 29, 30, 31],
> [4, 9], [4, 9], [4, 9], [4, 9], [4, 9], [4, 9], [4, 9],
> [4, 9], [4, 9], [4, 9], [4, 9], [4, 9], [4, 9], [4, 9],
> [4, 9], [4, 9], [4, 9]]);
<immutable digraph with 31 vertices, 265 edges>
gap> IsTransitiveDigraph(trans);
true
gap> nottrans := Digraph([
> [2, 4, 5, 6, 7, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
>   24, 25, 26, 27, 28, 29, 30, 31],
> [4, 6, 9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
>   27, 28, 29, 30, 31],
> [2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22,
>   23, 24, 25, 26, 27, 28, 29, 30, 31],
> [9],
> [2, 4, 6, 7, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
>   24, 25, 26, 27, 28, 29, 30, 31],
> [4, 9, 13, 16, 18, 19, 22, 23, 26, 28, 30],
> [2, 4, 6, 9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
>   26, 27, 28, 29, 30, 31],
> [2, 4, 6, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
>   25, 26, 27, 28, 29, 30, 31],
> [],
> [4, 9, 13, 15, 19, 21, 22, 24],
> [2, 4, 6, 9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
>   26, 27, 28, 29, 30, 31],
> [4, 9, 15, 17, 20, 21, 24, 25, 27, 29, 31],
> [4, 9],
> [4, 9, 16, 17, 18, 20, 23, 20, 25, 26, 27, 28, 29, 30, 31],
> [4, 9], [4, 9], [4, 9], [4, 9], [4, 9], [4, 9], [4, 9],
> [4, 9], [4, 9], [4, 9], [4, 9], [4, 9], [4, 9], [4, 9],
> [4, 9], [4, 9], [4, 9]]);
<immutable multidigraph with 31 vertices, 265 edges>
gap> IsTransitiveDigraph(nottrans);
false
gap> gr := Digraph([[2, 3, 3], [3, 3], []]);;
gap> IsTransitiveDigraph(gr);
true
gap> IS_TRANSITIVE_DIGRAPH(gr);
true

#  IsBipartiteDigraph
gap> gr := Digraph([[2, 4], [], [1], [1], [4]]);
<immutable digraph with 5 vertices, 5 edges>
gap> IsBipartiteDigraph(gr);
true
gap> gr := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> IsBipartiteDigraph(gr);
false
gap> gr := CycleDigraph(89);
<immutable cycle digraph with 89 vertices>
gap> IsBipartiteDigraph(gr);
false
gap> gr := CycleDigraph(314);
<immutable cycle digraph with 314 vertices>
gap> IsBipartiteDigraph(gr);
true
gap> gr := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> IsBipartiteDigraph(gr);
false
gap> gr := Digraph([[2, 4], [], [1], [1], [4], [7], []]);
<immutable digraph with 7 vertices, 6 edges>
gap> IsBipartiteDigraph(gr);
true
gap> gr := Digraph([[2], [3], [1], [6], [6], []]);
<immutable digraph with 6 vertices, 5 edges>
gap> IsBipartiteDigraph(gr);
false
gap> gr := Digraph([[1], [2]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsBipartiteDigraph(gr);
false
gap> gr := Digraph([[3], [2], [1, 2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> IsBipartiteDigraph(gr);
false
gap> gr := Digraph([[3], [3], [1, 2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> IsBipartiteDigraph(gr);
true
gap> gr := Digraph([[2, 3, 4], [5, 6], [], [7], [], [], []]);
<immutable digraph with 7 vertices, 6 edges>
gap> IsBipartiteDigraph(gr);
true
gap> gr := Digraph([[2, 3, 4], [5, 6], [], [7], [], [], [], [9], []]);
<immutable digraph with 9 vertices, 7 edges>
gap> IsBipartiteDigraph(gr);
true
gap> gr := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> DigraphHasLoops(gr);
true
gap> IsBipartiteDigraph(gr);
false
gap> D := Digraph([[4, 6, 8], [], [], [], [7], [2], [], [], [8], []]);
<immutable digraph with 10 vertices, 6 edges>
gap> IsBipartiteDigraph(D);
true

#  IsIn/OutRegularDigraph
gap> gr := Digraph([[1, 2, 3, 4], [], [], []]);;
gap> IsInRegularDigraph(gr);
true
gap> IsOutRegularDigraph(gr);
false
gap> gr := CompleteDigraph(4);;
gap> IsInRegularDigraph(gr);
true
gap> IsOutRegularDigraph(gr);
true
gap> gr := CompleteDigraph(4);;
gap> IsRegularDigraph(gr);
true

#  IsDistanceRegularDigraph
gap> gr := DigraphSymmetricClosure(ChainDigraph(5));;
gap> IsDistanceRegularDigraph(gr);
false
gap> gr := Digraph([[2, 3, 4], [1, 3, 4], [1, 2, 4], [1, 2, 3]]);;
gap> IsDistanceRegularDigraph(gr);
true
gap> gr := CompleteBipartiteDigraph(3, 3);;
gap> IsDistanceRegularDigraph(gr);
true
gap> gr := DigraphFromGraph6String("MhEGHC@AI?_PC@_G_");
<immutable symmetric digraph with 14 vertices, 42 edges>
gap> IsDistanceRegularDigraph(gr);
true
gap> IsDistanceRegularDigraph(ChainDigraph(5));
false
gap> IsDistanceRegularDigraph(EmptyDigraph(2));
true
gap> gr := Digraph([[2], [1], [4], [3]]);
<immutable digraph with 4 vertices, 4 edges>
gap> IsDistanceRegularDigraph(gr);
false
gap> gr := Digraph([[2], [1, 3], [2, 4], [3, 5, 6], [4, 6], [4, 5]]);
<immutable digraph with 6 vertices, 12 edges>
gap> IsDistanceRegularDigraph(gr);
false
gap> gr := CompleteBipartiteDigraph(3, 4);
<immutable complete bipartite digraph with bicomponent sizes 3 and 4>
gap> IsDistanceRegularDigraph(gr);
false
gap> gr := Digraph([[], [3], [2]]);
<immutable digraph with 3 vertices, 2 edges>
gap> IsDistanceRegularDigraph(gr);
false

#  IsCompleteBipartiteDigraph
gap> gr := CompleteBipartiteDigraph(4, 5);
<immutable complete bipartite digraph with bicomponent sizes 4 and 5>
gap> IsCompleteBipartiteDigraph(gr);
true
gap> gr := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> IsCompleteBipartiteDigraph(gr);
false
gap> gr := CycleDigraph(3);
<immutable cycle digraph with 3 vertices>
gap> IsCompleteBipartiteDigraph(gr);
false
gap> gr := CycleDigraph(4);
<immutable cycle digraph with 4 vertices>
gap> IsCompleteBipartiteDigraph(gr);
false
gap> gr := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsCompleteBipartiteDigraph(gr);
true

# IsCompleteMultipartiteDigraph
gap> D := CompleteMultipartiteDigraph([5, 3, 3, 2, 7]);
<immutable complete multipartite digraph with 20 vertices, 304 edges>
gap> IsCompleteMultipartiteDigraph(D);
true
gap> D := Digraph(OutNeighbours(D));
<immutable digraph with 20 vertices, 304 edges>
gap> IsCompleteMultipartiteDigraph(D);
true
gap> IsCompleteMultipartiteDigraph(EmptyDigraph(5));  # empty
false
gap> D := Digraph([[2, 2], [1]]);  # multidigraph
<immutable multidigraph with 2 vertices, 3 edges>
gap> IsCompleteMultipartiteDigraph(D);
false
gap> D := Digraph([[1, 2], [1]]);  # has loops
<immutable digraph with 2 vertices, 3 edges>
gap> IsCompleteMultipartiteDigraph(D);
false
gap> D := Digraph([[2], []]);  # not symmetric
<immutable digraph with 2 vertices, 1 edge>
gap> IsCompleteMultipartiteDigraph(D);
false
gap> D := Digraph(IsImmutableDigraph, [[2], [1]]);  # complete bipartite digraph
<immutable digraph with 2 vertices, 2 edges>
gap> IsCompleteMultipartiteDigraph(D);
true
gap> HasIsCompleteBipartiteDigraph(D) and IsCompleteBipartiteDigraph(D);
true
gap> D := CompleteDigraph(5);  # complete digraph
<immutable complete digraph with 5 vertices>
gap> IsCompleteMultipartiteDigraph(D);
true
gap> D := Digraph(OutNeighbours(D));;  # complete digraph created differently
gap> IsCompleteDigraph(D);
true
gap> IsCompleteMultipartiteDigraph(D);
true
gap> D := DigraphEdgeUnion(CycleDigraph(IsMutableDigraph, 4),
>                          DigraphReverse(CycleDigraph(IsMutableDigraph, 4)));
<mutable digraph with 4 vertices, 8 edges>
gap> IsCompleteMultipartiteDigraph(D);
true
gap> IsCompleteBipartiteDigraph(D);
true
gap> DigraphRemoveEdges(D, [[1, 2], [2, 1]]);
<mutable digraph with 4 vertices, 6 edges>
gap> IsCompleteMultipartiteDigraph(D);
false
gap> D := Digraph(IsImmutableDigraph, [[2], [1, 3], [2, 4], [3]]);
<immutable digraph with 4 vertices, 6 edges>
gap> IsCompleteMultipartiteDigraph(D);
false

#  IsDirectedTree
gap> g := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[]]);
<immutable empty digraph with 1 vertex>
gap> IsDirectedTree(g);
true
gap> g := Digraph([[], []]);
<immutable empty digraph with 2 vertices>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[], [2]]);
<immutable digraph with 2 vertices, 1 edge>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[3], [3], []]);
<immutable digraph with 3 vertices, 2 edges>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[2], [3], []]);
<immutable digraph with 3 vertices, 2 edges>
gap> IsDirectedTree(g);
true
gap> g := Digraph([[2], [3], [], []]);
<immutable digraph with 4 vertices, 2 edges>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[2, 3], [6], [4, 5], [], [], []]);
<immutable digraph with 6 vertices, 5 edges>
gap> IsDirectedTree(g);
true
gap> g := Digraph([[2, 3], [6], [4, 5], [], [], [], []]);
<immutable digraph with 7 vertices, 5 edges>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[2, 3], [6], [4, 5], [7], [], [7], []]);
<immutable digraph with 7 vertices, 7 edges>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[2, 3], [1, 3], [1, 2]]);
<immutable digraph with 3 vertices, 6 edges>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[2, 3, 4], [1, 3, 4], [1, 2, 4], [1, 2, 3]]);
<immutable digraph with 4 vertices, 12 edges>
gap> IsDirectedTree(g);
false

#  IsUndirectedTree
gap> g := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[]]);
<immutable empty digraph with 1 vertex>
gap> IsUndirectedTree(g);
true
gap> g := Digraph([[], []]);
<immutable empty digraph with 2 vertices>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[], [2]]);
<immutable digraph with 2 vertices, 1 edge>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsUndirectedTree(g);
true
gap> g := Digraph([[3], [3], []]);
<immutable digraph with 3 vertices, 2 edges>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[3], [3], [1, 2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> IsUndirectedTree(g);
true
gap> g := Digraph([[3], [3], [1, 2], []]);
<immutable digraph with 4 vertices, 4 edges>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[2, 3], [6], [4, 5], [], [], []]);
<immutable digraph with 6 vertices, 5 edges>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[2, 3], [6, 1], [4, 5, 1], [3], [3], [2]]);
<immutable digraph with 6 vertices, 10 edges>
gap> IsUndirectedTree(g);
true
gap> g := Digraph([[2, 3], [1, 3], [1, 2]]);
<immutable digraph with 3 vertices, 6 edges>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[2, 3, 4], [1, 3, 4], [1, 2, 4], [1, 2, 3]]);
<immutable digraph with 4 vertices, 12 edges>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[1], [2]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsConnectedDigraph(g);
false

#  IsUndirectedForest
gap> gr := ChainDigraph(10);
<immutable chain digraph with 10 vertices>
gap> IsUndirectedForest(gr);
false
gap> gr := EmptyDigraph(0);
<immutable empty digraph with 0 vertices>
gap> IsUndirectedForest(gr);
false
gap> gr := EmptyDigraph(1);
<immutable empty digraph with 1 vertex>
gap> IsUndirectedForest(gr);
true
gap> gr := Digraph([[1, 1]]);
<immutable multidigraph with 1 vertex, 2 edges>
gap> IsUndirectedForest(gr);
false
gap> gr := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> IsUndirectedForest(gr);
false
gap> gr := DigraphSymmetricClosure(ChainDigraph(4));
<immutable symmetric digraph with 4 vertices, 6 edges>
gap> HasIsUndirectedTree(gr) or HasIsUndirectedForest(gr);
false
gap> IsUndirectedTree(gr);
true
gap> HasIsUndirectedForest(gr);
true
gap> IsUndirectedForest(gr);
true
gap> gr := DigraphDisjointUnion(gr, gr, gr);
<immutable digraph with 12 vertices, 18 edges>
gap> IsUndirectedTree(gr);
false
gap> IsUndirectedForest(gr);
true
gap> gr := DigraphDisjointUnion(CompleteDigraph(2), CycleDigraph(3));
<immutable digraph with 5 vertices, 5 edges>
gap> IsUndirectedForest(gr);
false
gap> gr := Digraph(IsMutableDigraph, [[2], [1, 3], [2], [5], [4, 6], [5]]);
<mutable digraph with 6 vertices, 8 edges>
gap> IsUndirectedForest(gr);
true

#  IsEulerianDigraph
gap> g := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[]]);
<immutable empty digraph with 1 vertex>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[], []]);
<immutable empty digraph with 2 vertices>
gap> IsEulerianDigraph(g);
false
gap> g := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> IsEulerianDigraph(g);
false
gap> g := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[3], [3], []]);
<immutable digraph with 3 vertices, 2 edges>
gap> IsEulerianDigraph(g);
false
gap> g := Digraph([[3], [3], [1, 2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[3], [], [2]]);
<immutable digraph with 3 vertices, 2 edges>
gap> IsEulerianDigraph(g);
false
gap> g := Digraph([[2], [3], [1]]);
<immutable digraph with 3 vertices, 3 edges>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[2], [3], [1], []]);
<immutable digraph with 4 vertices, 3 edges>
gap> IsEulerianDigraph(g);
false
gap> g := Digraph([[2], [3], [1, 4], []]);
<immutable digraph with 4 vertices, 4 edges>
gap> IsEulerianDigraph(g);
false
gap> g := Digraph([[3, 6], [4], [2, 1], [5, 1], [3], [4]]);
<immutable digraph with 6 vertices, 9 edges>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[3, 6], [4], [2, 1], [5, 1], [3], [4], []]);
<immutable digraph with 7 vertices, 9 edges>
gap> IsEulerianDigraph(g);
false
gap> g := Digraph([[3, 6], [4], [2, 1], [5, 1], [3], [4, 7], []]);
<immutable digraph with 7 vertices, 10 edges>
gap> IsEulerianDigraph(g);
false
gap> g := Digraph([[3, 6], [4], [2, 1], [5, 1], [3], [4, 7], [6]]);
<immutable digraph with 7 vertices, 11 edges>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[2, 3], [3], [1]]);
<immutable digraph with 3 vertices, 4 edges>
gap> IsEulerianDigraph(g);
false
gap> g := EmptyDigraph(IsMutableDigraph, 10);
<mutable empty digraph with 10 vertices>
gap> IsEulerianDigraph(g);
false
gap> g;
<mutable empty digraph with 10 vertices>

# IsJoinSemilatticeDigraph, IsMeetSemilatticeDigraph, and IsLatticeDigraph
gap> gr := Digraph([[1, 2], [2]]);
<immutable digraph with 2 vertices, 3 edges>
gap> IsMeetSemilatticeDigraph(gr);
true
gap> IsJoinSemilatticeDigraph(gr);
true
gap> IsLatticeDigraph(gr);
true
gap> gr := CycleDigraph(5);
<immutable cycle digraph with 5 vertices>
gap> IsMeetSemilatticeDigraph(gr);
false
gap> IsJoinSemilatticeDigraph(gr);
false
gap> D := DigraphReflexiveTransitiveClosure(ChainDigraph(10));
<immutable preorder digraph with 10 vertices, 55 edges>
gap> IsMeetSemilatticeDigraph(D);
true
gap> IsJoinSemilatticeDigraph(D);
true
gap> D := DigraphReflexiveTransitiveClosure(ChainDigraph(10));
<immutable preorder digraph with 10 vertices, 55 edges>
gap> IsJoinSemilatticeDigraph(D);
true
gap> IsMeetSemilatticeDigraph(D);
true
gap> D := DigraphAddVertex(D, 11);
<immutable digraph with 11 vertices, 55 edges>
gap> D := DigraphAddEdge(D, [11, 4]);
<immutable digraph with 11 vertices, 56 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 11 vertices, 63 edges>
gap> IsJoinSemilatticeDigraph(D);
true
gap> IsMeetSemilatticeDigraph(D);
false
gap> D := Digraph([[1], [2]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsJoinSemilatticeDigraph(D);
false
gap> D := ChainDigraph(IsMutable, 4);
<mutable digraph with 4 vertices, 3 edges>
gap> IsMeetSemilatticeDigraph(D);
false
gap> D;
<mutable digraph with 4 vertices, 3 edges>
gap> D := Digraph(IsMutable, [[2, 3], [4], [4], []]);
<mutable digraph with 4 vertices, 4 edges>
gap> DigraphReflexiveTransitiveClosure(D);
<mutable digraph with 4 vertices, 9 edges>
gap> IsJoinSemilatticeDigraph(D);
true
gap> D := Digraph([[1, 2, 2], [2]]);
<immutable multidigraph with 2 vertices, 4 edges>
gap> IsJoinSemilatticeDigraph(D);
Error, the argument must not be a multidigraph,
gap> IsMeetSemilatticeDigraph(D);
Error, the argument must not be a multidigraph,
gap> D := DigraphReflexiveTransitiveClosure(ChainDigraph(4));
<immutable preorder digraph with 4 vertices, 10 edges>
gap> AdjacencyMatrix(D);
[ [ 1, 1, 1, 1 ], [ 0, 1, 1, 1 ], [ 0, 0, 1, 1 ], [ 0, 0, 0, 1 ] ]
gap> IsJoinSemilatticeDigraph(D);
true
gap> IsMeetSemilatticeDigraph(D);
true

# Join semilattice on 9 vertices
gap> gr := DigraphFromDiSparse6String(".HiR@AeNcC?oD?G`oAGXIoAGXAe_COqDK^F");
<immutable digraph with 9 vertices, 36 edges>
gap> IsMeetSemilatticeDigraph(gr);
false
gap> IsJoinSemilatticeDigraph(gr);
true
gap> IsLatticeDigraph(gr);
false
gap> gr := DigraphReverse(gr);
<immutable digraph with 9 vertices, 36 edges>
gap> IsMeetSemilatticeDigraph(gr);
true
gap> IsJoinSemilatticeDigraph(gr);
false
gap> IsLatticeDigraph(gr);
false

# IsDistributiveLatticeDigraph
gap> D := Digraph([[11, 10], [], [2], [2], [3], [4, 3], [6, 5], [7], [7],
>      [8], [9, 8]]);
<immutable digraph with 11 vertices, 14 edges>
gap> IsDistributiveLatticeDigraph(D);
false
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 11 vertices, 60 edges>
gap> IsDistributiveLatticeDigraph(D);
true
gap> D := DigraphReflexiveTransitiveClosure(CycleDigraph(5));
<immutable preorder digraph with 5 vertices, 25 edges>
gap> IsDistributiveLatticeDigraph(D);
false
gap> D := Digraph([[2, 4], [3, 5], [9], [5, 6], [7], [7, 8], [9], [9], []]);
<immutable digraph with 9 vertices, 12 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 9 vertices, 34 edges>
gap> IsDistributiveLatticeDigraph(D);
false
gap> N5 := DigraphReflexiveTransitiveClosure(Digraph([[2, 4], [3], [5], [5], []]));
<immutable preorder digraph with 5 vertices, 13 edges>
gap> M5 := DigraphReflexiveTransitiveClosure(Digraph([[2, 3, 4], [5], [5], [5], []]));
<immutable preorder digraph with 5 vertices, 12 edges>
gap> IsDistributiveLatticeDigraph(N5) or IsDistributiveLatticeDigraph(M5);
false
gap> D := Digraph([[2, 4], [3, 4], [5], [5], []]);
<immutable digraph with 5 vertices, 6 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 5 vertices, 14 edges>
gap> IsDistributiveLatticeDigraph(D);
true

# IsModularLatticeDigraph
gap>  D := Digraph([[11, 10], [], [2], [2], [3], [4, 3], [6, 5], [7], [7],
>      [8], [9, 8]]);
<immutable digraph with 11 vertices, 14 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 11 vertices, 60 edges>
gap> IsModularLatticeDigraph(D);
true
gap> D := ChainDigraph(10);
<immutable chain digraph with 10 vertices>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 10 vertices, 55 edges>
gap> IsModularLatticeDigraph(D);
true
gap> D := Digraph([[2, 4], [3, 5], [9], [5, 6], [7], [7, 8], [9], [9], []]);
<immutable digraph with 9 vertices, 12 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 9 vertices, 34 edges>
gap> IsModularLatticeDigraph(D);
false
gap> M3 := Digraph([[2, 3, 4], [5], [5], [5], []]);
<immutable digraph with 5 vertices, 6 edges>
gap> M3 := DigraphReflexiveTransitiveClosure(M3);
<immutable preorder digraph with 5 vertices, 12 edges>
gap> IsModularLatticeDigraph(M3);
true

# IsPartialOrderDigraph
gap> gr := NullDigraph(5);
<immutable empty digraph with 5 vertices>
gap> IsPartialOrderDigraph(gr);
false
gap> gr := Digraph([[1], [2], [3]]);
<immutable digraph with 3 vertices, 3 edges>
gap> IsPartialOrderDigraph(gr);
true

# Big partial order digraph
gap> gr := DigraphFromDiSparse6String(Concatenation(
> ".~?CI_A?WA_M@G@_G@gB?]@?G_SAWA?Y@oJ__BGH?uA_M_IAoO_oCWL@IB_R_{DGB?mB",
> "?U_sDwM@aBoX_KCGP@WEwQ@[FGR@_FWS@cFgT@gFwB@A?oO_KCGZACGwZAGGw[AUFOcAY",
> "F_f`{IG_Ae@?U`[IwWAqEOl`gJgC@mF?jBAFOkBEF_lBIFomBMG?nBQ@?ZAE@?ZAI@?ZA",
> "MH?oBWMGdB?LowaWKOya[K_xBmI?rBqIOsBuI_tBy@?`AMH?uCA@?aaOHOuB[OgCAIHOv",
> "CQ@?baOM@?CYMP@C]HOwCYMOyCKPpHbgPPHbkQw{CgRG|C_RW}CyNpN_SIwkDEJPQawSw",
> "nDQ@OobCSPUbGS`VbKSpWbOT@XbSTPY_SK?u_SK?v_SK?wbcT`[DyM`UDsVgzD[WG{D_V",
> "p`bsUPabwU`bb{Upc_SL`?bcOP[EY@OvCIMOyCKV@\\Ea@OvCQM`DDsYgDB_PgxC[V`kc",
> "_VpfEuM`HDwZHID{W@hEsZxJE?YpncoWPpcsW`oFIR`bEw[xNEO\\HOES\\WDC?Ph@C[X",
> "`vc_Xpw_SOhBEWY@yc_Q`fEc]wDCQH@DE_Y`|cgQphEk^gDCQPPiGAQpjGE@PEc[Z@vGM",
> "Q@lF_`HmFc`XHEo_xIEsZqCG]Z`oFo`QGckZqFf?[P~G_ahpGGahqGq[qJGu\\AHGy\\Q",
> "EG}\\aO_G@gF@?cgGAKcwHCWdGIGKdWA_KCAV`CeGQACeWRAOegSC[ewTGOfG`AGeGBH]",
> "GaWH}@?bHaH?dC?Oa]IEHQ_IEHaba[gaca_OQdacQAeag`QfcCOqa_OeA^aCO`CI?ihBC",
> "SgabIm@A^cOgAlcSgqm_SPa`c[QPvFggaoc_Q`wFkiQpccgqocgQqkJCkxJI{kxKJURQs",
> "JYRaqJ]RpxJaSAEJe?qQaGcqzaSdA{ccdQ|g[da}hcigQCGoHBHkoXIHooiGHsoy^i?ia",
> "lKU@Q`IiH@yFsgqjK]grEK]hBHa[oRGKiI@zISobJfohrKgciBL_OmxCJorxDJssHJJws",
> "YIJ{sgDIgjZ?LQC`|LU^aZKCth~KKtyJKOuGDK}_BOLi_RPLm_bQLqbBRLu@gPHKvweJs",
> "wHKLGwYLLwwgDIuCaVMAHqZH{wRdcsjRBMGxiMLcwrcM]GP|G?jbELQ_AmMQjRDkWtBcM",
> "mxBja_fa_KSxhMI[iqmKWxrjMybrMM_yRiMozRncC]p}IoqH}GCganMeOamKYOqnK_qRh",
> "NMjbEMmO`|MgzBtmgzRti{qRkNUyzkMs|Rxms}XNIcjAnM{{rtNe_QnMg|YOJg{BpNG|B",
> "uN[}ByNk~B|fc^Aqfo^qqJO{XzNG|H~GGlAtNG|H}K_|bwNu^RvNi_atN_~ZvN_}b|n[}",
> "bznmcR}N|?C@OH?sCOT@cFObAiQ@ECgR`QDWaaSOgea]IGhaiOxCcUQPycg]xJcqRXMc}",
> "SH{fsgx}f}_I@gI`yGgeaiJgqbYMg}cIPheeiZhqfYciUhifiajinjMlItjYlywjemj?k",
> "EojBkQqZIkmrJLkytZUl]uJXmkyjrNI}Rv"));
<immutable digraph with 266 vertices, 919 edges>
gap> gr := DigraphReflexiveTransitiveClosure(gr);
<immutable preorder digraph with 266 vertices, 10772 edges>
gap> IsPartialOrderDigraph(gr);
true
gap> IsMeetSemilatticeDigraph(gr);
false
gap> IsJoinSemilatticeDigraph(gr);
false
gap> IsLatticeDigraph(gr);
false

#  IsCycleDigraph
gap> IsCycleDigraph(NullDigraph(10));
false
gap> IsCycleDigraph(CycleDigraph(10));
true
gap> IsCycleDigraph(NullDigraph(0));
false
gap> IsCycleDigraph(NullDigraph(1));
false
gap> IsCycleDigraph(CycleDigraph(1));
true

#  IsBiconnectedDigraph
gap> gr := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> IsBiconnectedDigraph(gr);
true
gap> gr := Digraph([[]]);
<immutable empty digraph with 1 vertex>
gap> IsBiconnectedDigraph(gr);
true
gap> gr := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> IsBiconnectedDigraph(gr);
true
gap> gr := Digraph([[1, 1]]);
<immutable multidigraph with 1 vertex, 2 edges>
gap> IsBiconnectedDigraph(gr);
true
gap> gr := Digraph([[1], [2]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsBiconnectedDigraph(gr);
false
gap> gr := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsBiconnectedDigraph(gr);
true
gap> gr := Digraph([[2], [3], [], []]);
<immutable digraph with 4 vertices, 2 edges>
gap> IsBiconnectedDigraph(gr);
false
gap> gr := Digraph([[2], [3], [], [3]]);
<immutable digraph with 4 vertices, 3 edges>
gap> IsBiconnectedDigraph(gr);
false
gap> IsBiconnectedDigraph(DigraphFromGraph6String("FlCX?"));
false
gap> IsBiconnectedDigraph(Digraph([[2, 4, 5], [1, 4], [4, 7], [1, 2, 3, 5, 6,
>                                   7], [1, 4], [4, 7], [3, 4, 6]]));
false

#  IsHamiltonianDigraph
gap> g := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> IsHamiltonianDigraph(g);
true
gap> g := Digraph([[]]);
<immutable empty digraph with 1 vertex>
gap> IsHamiltonianDigraph(g);
true
gap> g := Digraph([[], []]);
<immutable empty digraph with 2 vertices>
gap> IsHamiltonianDigraph(g);
false
gap> g := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> IsHamiltonianDigraph(g);
true
gap> g := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> IsHamiltonianDigraph(g);
false
gap> g := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsHamiltonianDigraph(g);
true
gap> g := Digraph([[3], [3], []]);
<immutable digraph with 3 vertices, 2 edges>
gap> IsHamiltonianDigraph(g);
false
gap> g := Digraph([[3], [3], [1, 2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> IsHamiltonianDigraph(g);
false
gap> g := Digraph([[3], [], [2]]);
<immutable digraph with 3 vertices, 2 edges>
gap> IsHamiltonianDigraph(g);
false
gap> g := Digraph([[2], [3], [1]]);
<immutable digraph with 3 vertices, 3 edges>
gap> IsHamiltonianDigraph(g);
true
gap> g := Digraph([[2], [3], [1], []]);
<immutable digraph with 4 vertices, 3 edges>
gap> IsHamiltonianDigraph(g);
false
gap> g := Digraph([[2], [3], [1, 4], []]);
<immutable digraph with 4 vertices, 4 edges>
gap> IsHamiltonianDigraph(g);
false
gap> g := Digraph([[3, 6], [4], [2, 1], [5, 1], [3], [4]]);
<immutable digraph with 6 vertices, 9 edges>
gap> IsHamiltonianDigraph(g);
false
gap> g := Digraph([[3, 6], [4, 1], [2, 1], [5, 1], [3], [4]]);
<immutable digraph with 6 vertices, 10 edges>
gap> IsHamiltonianDigraph(g);
true
gap> g := Digraph([[3, 6], [4], [2, 1], [5, 1], [3], [4, 7], []]);
<immutable digraph with 7 vertices, 10 edges>
gap> IsHamiltonianDigraph(g);
false
gap> g := Digraph([[3, 6, 7], [4, 1], [2, 1], [5, 1], [3], [4, 7], [6]]);
<immutable digraph with 7 vertices, 13 edges>
gap> IsHamiltonianDigraph(g);
true
gap> g := Digraph([[3, 6], [4], [2, 1], [5, 1], [3], [4, 7], [6]]);
<immutable digraph with 7 vertices, 11 edges>
gap> IsHamiltonianDigraph(g);
false
gap> g := Digraph([[5, 6, 10], [2, 9], [3, 7], [2, 3], [9, 10], [2, 9], [1],
>                  [2, 3, 4, 7, 9], [3, 10], [4, 5, 6, 8]]);
<immutable digraph with 10 vertices, 25 edges>
gap> IsHamiltonianDigraph(g);
false
gap> g := Digraph([[2, 4, 6, 10], [1, 3, 4, 5, 6, 7, 9, 10], [1, 5, 7, 8],
>                  [6, 10], [1, 7], [3, 4, 6, 7, 9], [2, 3, 4, 7],
>                  [2, 4, 5, 6], [2, 3, 5, 6, 7, 9, 10], [2, 3, 5]]);
<immutable digraph with 10 vertices, 43 edges>
gap> IsHamiltonianDigraph(g);
true
gap> g := CompleteMultipartiteDigraph([1, 30]);
<immutable complete bipartite digraph with bicomponent sizes 1 and 30>
gap> IsHamiltonianDigraph(g);
false
gap> g := CompleteMultipartiteDigraph([16, 15]);
<immutable complete bipartite digraph with bicomponent sizes 16 and 15>
gap> IsHamiltonianDigraph(g);
false
gap> g := CompleteMultipartiteDigraph([1, 1, 2, 3, 5, 8, 13, 21]);
<immutable complete multipartite digraph with 54 vertices, 2202 edges>
gap> IsHamiltonianDigraph(g);
true
gap> g := CompleteMultipartiteDigraph([1, 1, 2, 3, 5, 8, 13, 21, 34]);
<immutable complete multipartite digraph with 88 vertices, 5874 edges>
gap> IsHamiltonianDigraph(g);
true
gap> g := CompleteBipartiteDigraph(50, 50);
<immutable complete bipartite digraph with bicomponent sizes 50 and 50>
gap> IsHamiltonianDigraph(g);
true
gap> g := CompleteMultipartiteDigraph([1, 15, 1, 1, 1, 1, 1, 1]);
<immutable complete multipartite digraph with 22 vertices, 252 edges>
gap> IsHamiltonianDigraph(g);
false
gap> g := CompleteDigraph(50);
<immutable complete digraph with 50 vertices>
gap> IsHamiltonianDigraph(g);
true
gap> g := CycleDigraph(1000000);
<immutable cycle digraph with 1000000 vertices>
gap> IsHamiltonianDigraph(g);
true
gap> g := CompleteDigraph(100);
<immutable complete digraph with 100 vertices>
gap> IsHamiltonianDigraph(g);
true
gap> g := CycleDigraph(513);
<immutable cycle digraph with 513 vertices>
gap> g := DigraphAddEdges(g, [[6, 8], [8, 7], [7, 9]]);
<immutable digraph with 513 vertices, 516 edges>
gap> g := DigraphRemoveEdge(g, [6, 7]);
<immutable digraph with 513 vertices, 515 edges>
gap> IsHamiltonianDigraph(g);
true
gap> gr := DigraphAddEdges(DigraphAddVertex(CycleDigraph(600)),
>                          [[600, 601], [601, 600]]);
<immutable digraph with 601 vertices, 602 edges>
gap> HamiltonianPath(gr);
fail
gap> IsHamiltonianDigraph(gr);
false
gap> gr := Digraph([[2, 2], [1, 1]]);;
gap> IsMultiDigraph(gr) and IsHamiltonianDigraph(gr);
true

# IsDigraphCore
gap> D := CompleteDigraph(10);
<immutable complete digraph with 10 vertices>
gap> IsDigraphCore(D);
true
gap> D := JohnsonDigraph(8, 3);
<immutable symmetric digraph with 56 vertices, 840 edges>
gap> IsDigraphCore(D);
true
gap> D := CompleteBipartiteDigraph(500, 500);
<immutable complete bipartite digraph with bicomponent sizes 500 and 500>
gap> IsDigraphCore(D);
false
gap> D := PetersenGraph();
<immutable digraph with 10 vertices, 30 edges>
gap> IsDigraphCore(D);
true
gap> D := DigraphSymmetricClosure(CycleDigraph(IsMutableDigraph, 40));
<mutable digraph with 40 vertices, 80 edges>
gap> IsDigraphCore(D);
false
gap> D;
<mutable digraph with 40 vertices, 80 edges>
gap> D := EmptyDigraph(100000);
<immutable empty digraph with 100000 vertices>
gap> IsDigraphCore(D);
false
gap> D := EmptyDigraph(0);
<immutable empty digraph with 0 vertices>
gap> IsDigraphCore(D);
true

# IsPreorderDigraph and IsQuasiorderDigraph
gap> gr := Digraph([[1], [1, 2], [1, 3], [1, 4], [1 .. 5], [1 .. 6],
> [1, 2, 3, 4, 5, 7], [1, 8]]);;
gap> IsPreorderDigraph(gr) and IsQuasiorderDigraph(gr);
true
gap> gr := Concatenation("+XqD?OG???FbueZpzRKGC@?}]sr]nYXnNl[saOEGOgA@w|he?A?",
> "?}NyxnFlKvbueZpzrLGcHa??A?]NYx_?_GC??AJpzrnw~jm{]srO???_");;
gap> gr := DigraphFromDigraph6String(gr);;
gap> IsPreorderDigraph(gr) and IsQuasiorderDigraph(gr);
true
gap> gr := Concatenation("+]KO??G_CP??G?A?AGGC?_Di_H__O?gT?E@A`a@?O?D@?ACCA_?",
> "PAOg@O?CHe?G__gK?_??__Oa???QGC@?AG???`O@??O?@??O?W?U_I?A_?DOOOBoG@P_CGp?Cw",
> "?A??C_W?_??P_?s@??Bi?G@?O?a");;
gap> gr := DigraphFromDigraph6String(gr);;
gap> IsPreorderDigraph(gr) or IsQuasiorderDigraph(gr);
false
gap> gr := Digraph([[], [2], [1, 2, 3]]);;
gap> IsPreorderDigraph(gr) or IsQuasiorderDigraph(gr);
false
gap> gr := Digraph([[1], [1, 2], [2, 3]]);;
gap> IsPreorderDigraph(gr) or IsQuasiorderDigraph(gr);
false

# Code coverage
gap> D := DigraphCopy(NullDigraph(4));
<immutable empty digraph with 4 vertices>
gap> HasIsNullDigraph(D) and IsNullDigraph(D);
true
gap> HasIsEmptyDigraph(D) and IsEmptyDigraph(D);
true
gap> HasDigraphNrEdges(D);
true
gap> IsEmptyDigraph(D);
true

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

# DigraphHasNoVertices and DigraphHasAVertex
gap> List([0 .. 3], i -> DigraphHasAVertex(EmptyDigraph(i)));
[ false, true, true, true ]
gap> List([0 .. 3], i -> DigraphHasNoVertices(EmptyDigraph(i)));
[ true, false, false, false ]
gap> DigraphHasAVertex(Digraph([]));
false
gap> DigraphHasNoVertices(Digraph([]));
true
gap> DigraphHasAVertex(Digraph([[1]]));
true
gap> DigraphHasNoVertices(Digraph([[1]]));
false

# IsNonemptyDigraph
gap> ForAny([0 .. 10], i -> IsNonemptyDigraph(EmptyDigraph(i)));
false
gap> ForAny([0 .. 10], i -> IsNonemptyDigraph(Digraph(
> ListWithIdenticalEntries(i, []))));
false
gap> IsNonemptyDigraph(Digraph([[], [3], []]));
true

# Implications that something is false
# DigraphHasLoops
gap> D := Digraph([[2], [], [2]]);;
gap> SetIsAcyclicDigraph(D, true);
gap> HasDigraphHasLoops(D) and not DigraphHasLoops(D);
true

#
gap> D := Digraph([[2], []]);;
gap> SetIsTournament(D, true);
gap> HasDigraphHasLoops(D) and not DigraphHasLoops(D);
true

#
gap> D := Digraph([[2], [1, 3, 4], [2], [2], [6], [5]]);;
gap> SetIsUndirectedForest(D, true);
gap> HasDigraphHasLoops(D) and not DigraphHasLoops(D);
true

#
gap> D := Digraph([[3], [1, 4], [], []]);;
gap> SetIsDirectedTree(D, true);
gap> HasDigraphHasLoops(D) and not DigraphHasLoops(D);
true

#
gap> D := Digraph([[], []]);;
gap> SetIsEmptyDigraph(D, true);
gap> HasDigraphHasLoops(D) and not DigraphHasLoops(D);
true

#
gap> D := Digraph([[2, 3], [1, 3], [1, 2]]);;
gap> SetIsCompleteDigraph(D, true);
gap> SetIsNonemptyDigraph(D, true);
gap> HasDigraphHasLoops(D) and not DigraphHasLoops(D);
true

#
gap> D := Digraph([[2], []]);;
gap> SetIsBipartiteDigraph(D, true);
gap> HasDigraphHasLoops(D) and not DigraphHasLoops(D);
true

# IsAcyclicDigraph
gap> D := Digraph([[2], [1]]);;
gap> SetIsCompleteDigraph(D, true);
gap> SetIsNonemptyDigraph(D, true);
gap> HasIsAcyclicDigraph(D) and not IsAcyclicDigraph(D);
true

#
gap> D := Digraph([[2, 3], [2], [2]]);;
gap> SetDigraphHasLoops(D, true);
gap> HasIsAcyclicDigraph(D) and not IsAcyclicDigraph(D);
true

#
gap> D := Digraph([[3], [1], [2]]);;
gap> SetIsStronglyConnectedDigraph(D, true);
gap> SetIsNonemptyDigraph(D, true);
gap> HasIsAcyclicDigraph(D) and not IsAcyclicDigraph(D);
true

# Other
gap> D := Digraph([[], []]);;
gap> SetIsEmptyDigraph(D, true);
gap> HasIsNonemptyDigraph(D) and not IsNonemptyDigraph(D);
true

#
gap> D := Digraph([[], [1]]);;
gap> SetIsNonemptyDigraph(D, true);
gap> HasIsEmptyDigraph(D) and not IsEmptyDigraph(D);
true

#
gap> D := Digraph([]);;
gap> SetDigraphHasNoVertices(D, true);
gap> HasDigraphHasAVertex(D) and not DigraphHasAVertex(D);
true

#
gap> D := Digraph([[]]);;
gap> SetDigraphHasAVertex(D, true);
gap> HasDigraphHasNoVertices(D) and not DigraphHasNoVertices(D);
true

#
gap> D := Digraph([[2], [1]]);;
gap> SetIsCompleteDigraph(D, true);
gap> SetIsNonemptyDigraph(D, true);
gap> HasIsAntisymmetricDigraph(D) and not IsAntisymmetricDigraph(D);
true

#
gap> D := Digraph([[2], [3], [3]]);;
gap> SetDigraphHasLoops(D, true);
gap> HasIsChainDigraph(D) and not IsChainDigraph(D);
true

#
gap> D := Digraph([[2, 3], [1], [1, 4], [3]]);;
gap> SetIsSymmetricDigraph(D, true);
gap> SetIsNonemptyDigraph(D, true);
gap> HasIsChainDigraph(D) and not IsChainDigraph(D);
true

#
gap> D := Digraph([[2], [3], [3]]);;
gap> SetDigraphHasLoops(D, true);
gap> HasIsCompleteDigraph(D) and not IsCompleteDigraph(D);
true

#
gap> D := Digraph([[2], [5], [], [5], [6], []]);;
gap> SetIsAcyclicDigraph(D, true);
gap> SetDigraphHasAVertex(D, true);
gap> HasIsReflexiveDigraph(D) and not IsReflexiveDigraph(D);
true

# IsSymmetricDigraph
gap> D := Digraph([[3], [], [2]]);;
gap> SetIsAcyclicDigraph(D, true);
gap> SetIsNonemptyDigraph(D, true);
gap> HasIsSymmetricDigraph(D) and not IsSymmetricDigraph(D);
true

#
gap> D := Digraph([[3], [], [2]]);;
gap> SetIsDirectedTree(D, true);
gap> SetIsNonemptyDigraph(D, true);
gap> HasIsSymmetricDigraph(D) and not IsSymmetricDigraph(D);
true

#
gap> D := Digraph([[3], [1], [2]]);;
gap> SetIsTournament(D, true);
gap> SetIsNonemptyDigraph(D, true);
gap> HasIsSymmetricDigraph(D) and not IsSymmetricDigraph(D);
true

# IsMultiDigraph
gap> D := Digraph([[2], [3], [4], []]);;
gap> SetIsChainDigraph(D, true);
gap> HasIsMultiDigraph(D) and not IsMultiDigraph(D);
true

#
gap> D := Digraph([[2, 3], [3, 1], [2, 1]]);;
gap> SetIsCompleteDigraph(D, true);
gap> HasIsMultiDigraph(D) and not IsMultiDigraph(D);
true

#
gap> D := Digraph([[2, 3], [3, 1], [2, 1]]);;
gap> SetIsCompleteMultipartiteDigraph(D, true);
gap> HasIsMultiDigraph(D) and not IsMultiDigraph(D);
true

#
gap> D := Digraph([[2], [1]]);;
gap> SetIsCycleDigraph(D, true);
gap> HasIsMultiDigraph(D) and not IsMultiDigraph(D);
true

#
gap> D := Digraph([[], []]);;
gap> SetIsEmptyDigraph(D, true);
gap> HasIsMultiDigraph(D) and not IsMultiDigraph(D);
true

#
gap> D := Digraph([[3], [2], [3], [1]]);;
gap> SetIsFunctionalDigraph(D, true);
gap> HasIsMultiDigraph(D) and not IsMultiDigraph(D);
true

#
gap> D := Digraph([[3], [1], [2]]);;
gap> SetIsTournament(D, true);
gap> HasIsMultiDigraph(D) and not IsMultiDigraph(D);
true

#
gap> D := Digraph([[2], [1, 3, 4], [2], [2], [6], [5]]);;
gap> SetIsUndirectedForest(D, true);
gap> HasIsMultiDigraph(D) and not IsMultiDigraph(D);
true

#  DIGRAPHS_UnbindVariables
gap> Unbind(D);
gap> Unbind(G);
gap> Unbind(M5);
gap> Unbind(N5);
gap> Unbind(adj);
gap> Unbind(circuit);
gap> Unbind(complete100);
gap> Unbind(g);
gap> Unbind(g1);
gap> Unbind(g2);
gap> Unbind(g3);
gap> Unbind(g4);
gap> Unbind(g5);
gap> Unbind(g6);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(gr3);
gap> Unbind(gr4);
gap> Unbind(gr5);
gap> Unbind(gr6);
gap> Unbind(grid);
gap> Unbind(i);
gap> Unbind(j);
gap> Unbind(loop);
gap> Unbind(mat);
gap> Unbind(multiple);
gap> Unbind(nottrans);
gap> Unbind(r);
gap> Unbind(range);
gap> Unbind(source);
gap> Unbind(trans);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/prop.tst", 0);
