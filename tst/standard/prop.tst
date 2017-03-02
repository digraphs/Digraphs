#############################################################################
##
#W  standard/prop.tst
#Y  Copyright (C) 2014-17                                James D. Mitchell
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

#T# IsMultiDigraph
gap> gr1 := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> IsMultiDigraph(gr1);
false
gap> gr2 := Digraph([[]]);
<digraph with 1 vertex, 0 edges>
gap> IsMultiDigraph(gr2);
false
gap> source := [1 .. 10000];;
gap> range := List(source, x -> Random(source));;
gap> r := rec (vertices := [1 .. 10000], source := source, range := range);;
gap> gr3 := Digraph(r);
<digraph with 10000 vertices, 10000 edges>
gap> IsMultiDigraph(gr3);
false
gap> Add(source, 10000);;
gap> Add(range, range[10000]);;
gap> r := rec(vertices := [1 .. 10000], source := source, range := range);;
gap> gr4 := Digraph(r);
<multidigraph with 10000 vertices, 10001 edges>
gap> IsMultiDigraph(gr4);
true

#T# IsAcyclicDigraph
gap> loop := Digraph([[1]]);
<digraph with 1 vertex, 1 edge>
gap> IsMultiDigraph(loop);
false
gap> IsAcyclicDigraph(loop);
false
gap> r := rec(vertices := [1, 2], source := [1, 1], range := [2, 2]);;
gap> multiple := Digraph(r);
<multidigraph with 2 vertices, 2 edges>
gap> IsMultiDigraph(multiple);
true
gap> IsAcyclicDigraph(multiple);
true
gap> r := rec(vertices := [1 .. 100], source := [], range := []);;
gap> for i in [1 .. 100] do
>   for j in [1 .. 100] do
>     Add(r.source, i);
>     Add(r.range, j);
>   od;
> od;
gap> complete100 := Digraph(r);
<digraph with 100 vertices, 10000 edges>
gap> IsMultiDigraph(complete100);
false
gap> IsAcyclicDigraph(complete100);
false
gap> r := rec(vertices := [1 .. 20000], source := [], range := []);;
gap> for i in [1 .. 9999] do
>   Add(r.source, i);
>   Add(r.range, i + 1);
> od;
> Add(r.source, 10000);;
> Add(r.range, 20000);;
> Add(r.source, 10002);;
> Add(r.range, 15000);;
> Add(r.source, 10001);;
> Add(r.range, 1);;
> for i in [10001 .. 19999] do
>   Add(r.source, i);
>   Add(r.range, i + 1);
> od;
gap> circuit := Digraph(r);
<digraph with 20000 vertices, 20001 edges>
gap> IsMultiDigraph(circuit);
false
gap> IsAcyclicDigraph(circuit);
true
gap> r := rec(nrvertices := 8,
> source := [1, 1, 1, 2, 3, 4, 4, 5, 7, 7],
> range := [4, 3, 4, 8, 2, 2, 6, 7, 4, 8]);;
gap> grid := Digraph(r);
<multidigraph with 8 vertices, 10 edges>
gap> IsMultiDigraph(grid);
true
gap> IsAcyclicDigraph(grid);
true
gap> gr := Digraph([[1]]);;
gap> DigraphHasLoops(gr);
true
gap> HasIsAcyclicDigraph(gr);
false
gap> IsAcyclicDigraph(gr);
false
gap> gr := Digraph([[2], []]);
<digraph with 2 vertices, 1 edge>
gap> IsTournament(gr);
true
gap> IsTransitiveDigraph(gr);
true
gap> HasIsAcyclicDigraph(gr);
true
gap> IsAcyclicDigraph(gr);
true
gap> gr := Digraph([[2], []]);
<digraph with 2 vertices, 1 edge>
gap> DigraphStronglyConnectedComponents(gr);
rec( comps := [ [ 2 ], [ 1 ] ], id := [ 2, 1 ] )
gap> IsAcyclicDigraph(gr);
true
gap> gr := Digraph([[1, 2], []]);
<digraph with 2 vertices, 2 edges>
gap> DigraphStronglyConnectedComponents(gr);
rec( comps := [ [ 2 ], [ 1 ] ], id := [ 2, 1 ] )
gap> IsAcyclicDigraph(gr);
false
gap> gr := Digraph([[2], [1]]);
<digraph with 2 vertices, 2 edges>
gap> DigraphStronglyConnectedComponents(gr);
rec( comps := [ [ 1, 2 ] ], id := [ 1, 1 ] )
gap> IsAcyclicDigraph(gr);
false
gap> gr := Digraph([
> [9, 10], [8], [4], [1, 7, 8], [], [5], [], [6], [], [4, 8]]);
<digraph with 10 vertices, 11 edges>
gap> DigraphTopologicalSort(gr);
fail
gap> HasIsAcyclicDigraph(gr);
false
gap> IsAcyclicDigraph(gr);
false

#T# IsFunctionalDigraph
gap> IsFunctionalDigraph(multiple);
false
gap> IsFunctionalDigraph(grid);
false
gap> IsFunctionalDigraph(circuit);
false
gap> IsFunctionalDigraph(loop);
true
gap> gr := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> IsFunctionalDigraph(gr);
true
gap> r := rec(vertices := [1 .. 10],
> source :=
> [1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5,
> 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 10, 10,
> 10, 10, 10, 10],
> range :=
> [6, 7, 6, 9, 1, 3, 4, 5, 8, 9, 1, 2, 3, 4, 5, 6, 7, 10, 1, 5, 6, 7, 10, 2,
> 4, 5, 9, 10, 3, 4, 5, 6, 7, 8, 9, 10, 1, 3, 5, 7, 8, 9, 1, 2, 5, 1, 2,
> 4, 6, 7, 8]);;
gap> g1 := Digraph(r);
<digraph with 10 vertices, 51 edges>
gap> IsFunctionalDigraph(g1);
false
gap> g2 := Digraph(OutNeighbours(g1));
<digraph with 10 vertices, 51 edges>
gap> IsFunctionalDigraph(g2);
false
gap> g3 := Digraph([[1], [3], [2], [2]]);
<digraph with 4 vertices, 4 edges>
gap> IsFunctionalDigraph(g3);
true
gap> g4 := Digraph(rec(vertices := [1 .. 3],
> source := [3, 2, 1], range := [2, 1, 3]));
<digraph with 3 vertices, 3 edges>
gap> IsFunctionalDigraph(g4);
true
gap> g5 := Digraph(rec(vertices := [1 .. 3],
> source := [3, 2, 2], range := [2, 1, 3]));
<digraph with 3 vertices, 3 edges>
gap> IsFunctionalDigraph(g5);
false

#T# IsSymmetricDigraph
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
<digraph with 4 vertices, 10 edges>
gap> IsSymmetricDigraph(g6);
true
gap> gr := Digraph(rec(nrvertices := 3, source := [1, 1, 2, 2, 2, 2, 3, 3],
> range := [2, 2, 1, 1, 3, 3, 2, 2]));;
gap> IsSymmetricDigraph(gr);
true

#T# IsAntisymmetricDigraph
gap> gr := Digraph(rec(nrvertices := 10,
> source := [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 5, 5, 5, 5, 5, 5, 6,
>  6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 10],
> range := [2, 4, 6, 10, 3, 5, 7, 4, 7, 1, 9, 10, 4, 6, 9, 8, 4, 3, 7, 1, 6,
>  8, 2, 3, 9, 7, 10, 9, 4, 1, 8, 9, 3, 1, 4, 2, 5, 2, 1, 10, 5, 6, 2, 4, 8]));
<digraph with 10 vertices, 45 edges>
gap> IsAntisymmetricDigraph(gr);
true
gap> gr := Digraph([[1, 1, 1, 2, 2], [2, 3], [3, 3, 4], [4, 2]]);
<multidigraph with 4 vertices, 12 edges>
gap> IsAntisymmetricDigraph(gr);
true
gap> gr := Digraph([[1, 1, 1, 2, 2], [2, 3], [3, 3, 4], [4, 3]]);
<multidigraph with 4 vertices, 12 edges>
gap> IsAntisymmetricDigraph(gr);
false
gap> gr := Digraph([[2, 3], [3], [1]]);
<digraph with 3 vertices, 4 edges>
gap> IsAntisymmetricDigraph(gr);
false
gap> gr := Digraph([[2], [3], [1, 2]]);
<digraph with 3 vertices, 4 edges>
gap> IsAntisymmetricDigraph(gr);
false
gap> gr := Digraph([[1, 1, 1, 1, 2], [2, 2]]);
<multidigraph with 2 vertices, 7 edges>
gap> IsAntisymmetricDigraph(gr);
true
gap> gr := Digraph([[1, 1, 1, 1, 2], [2, 2, 2, 1]]);
<multidigraph with 2 vertices, 9 edges>
gap> IsAntisymmetricDigraph(gr);
false

#T# IsEmptyDigraph
gap> gr1 := Digraph(rec(nrvertices := 5, source := [], range := []));;
gap> IsEmptyDigraph(gr1);
true
gap> gr2 :=
> Digraph(rec(vertices := [1 .. 6], source := [6], range := [1]));;
gap> IsEmptyDigraph(gr2);
false
gap> gr3 := DigraphNC([[], [], [], []]);;
gap> IsEmptyDigraph(gr3);
true
gap> gr4 := DigraphNC([[], [3], [1]]);;
gap> IsEmptyDigraph(gr4);
false
gap> gr5 := DigraphByAdjacencyMatrix([[0, 0], [0, 0]]);
<digraph with 2 vertices, 0 edges>
gap> IsEmptyDigraph(gr5);
true
gap> gr6 := DigraphByEdges([[3, 5], [1, 1], [2, 3], [5, 4]]);
<digraph with 5 vertices, 4 edges>
gap> IsEmptyDigraph(gr6);
false

#T# IsTournament
gap> gr := Digraph(rec(
> nrvertices := 2, source := [1, 1], range := [2, 2]));
<multidigraph with 2 vertices, 2 edges>
gap> IsTournament(gr);
false
gap> gr := Digraph([[2], [1], [1, 2]]);
<digraph with 3 vertices, 4 edges>
gap> IsTournament(gr);
false
gap> gr := Digraph([[2, 3], [3], []]);
<digraph with 3 vertices, 3 edges>
gap> IsAcyclicDigraph(gr);
true
gap> IsTournament(gr);
true
gap> gr := EmptyDigraph(0);;
gap> IsTournament(gr);
true
gap> gr := Digraph([[1], []]);
<digraph with 2 vertices, 1 edge>
gap> IsTournament(gr);
false
gap> gr := EmptyDigraph(1);
<digraph with 1 vertex, 0 edges>
gap> HasIsTournament(gr);
false
gap> IsTournament(gr);
true
gap> gr := Digraph([[2], [3], [1]]);
<digraph with 3 vertices, 3 edges>
gap> IsTournament(gr);
true
gap> gr := Digraph([[2], [1], [1]]);
<digraph with 3 vertices, 3 edges>
gap> IsTournament(gr);
false

#T# IsStronglyConnectedDigraph
gap> gr := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> IsStronglyConnectedDigraph(gr);
true
gap> adj := [[3, 4, 5, 7, 10], [4, 5, 10], [1, 2, 4, 7], [2, 9],
> [4, 5, 8, 9], [1, 3, 4, 5, 6], [1, 2, 4, 6],
> [1, 2, 3, 4, 5, 6, 7, 9], [2, 4, 8], [4, 5, 6, 8, 11], [10]];;
gap> gr := Digraph(adj);
<digraph with 11 vertices, 44 edges>
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
gap> r := rec(nrvertices := 9,
> range := [1, 7, 6, 9, 4, 8, 2, 5, 8, 9, 3, 9, 4, 8, 1, 1, 3],
> source := [1, 1, 2, 2, 4, 4, 5, 6, 6, 6, 7, 7, 8, 8, 9, 9, 9]);;
gap> gr := Digraph(r);
<multidigraph with 9 vertices, 17 edges>
gap> IsStronglyConnectedDigraph(gr);
false
gap> gr := CycleDigraph(10000);;
gap> gr2 := DigraphRemoveEdges(gr, [10000]);
<digraph with 10000 vertices, 9999 edges>
gap> IsStronglyConnectedDigraph(gr2);
false
gap> gr2 := DigraphRemoveEdges(gr, [10000]);
<digraph with 10000 vertices, 9999 edges>
gap> IsAcyclicDigraph(gr2);
true
gap> IsStronglyConnectedDigraph(gr2);
false
gap> gr := Digraph([[2], []]);
<digraph with 2 vertices, 1 edge>
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

#T# IsReflexiveDigraph
gap> r := rec(vertices := [1 .. 5],
> source := [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5],
> range  := [1, 2, 3, 1, 2, 5, 1, 3, 5, 2, 3, 4, 1, 2, 2]);;
gap> gr := Digraph(r);
<multidigraph with 5 vertices, 15 edges>
gap> IsReflexiveDigraph(gr);
false
gap> r := rec(nrvertices := 4,
> source := [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4],
> range  := [1, 2, 3, 1, 2, 2, 1, 2, 4, 1, 1, 4]);;
gap> gr := Digraph(r);
<multidigraph with 4 vertices, 12 edges>
gap> IsReflexiveDigraph(gr);
false
gap> r := rec(nrvertices := 5,
> source := [1, 1, 1, 2, 2, 3, 3, 3, 4, 5, 5, 5],
> range  := [1, 1, 3, 2, 5, 1, 3, 5, 4, 1, 5, 2]);;
gap> gr := Digraph(r);
<multidigraph with 5 vertices, 12 edges>
gap> IsReflexiveDigraph(gr);
true
gap> gr := EmptyDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> IsReflexiveDigraph(gr);
true
gap> gr := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> HasIsAcyclicDigraph(gr);
false
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
<digraph with 3 vertices, 4 edges>
gap> IsReflexiveDigraph(gr);
false
gap> adj := [[4, 2, 3, 1], [2, 3], [1, 3], [4]];;
gap> gr := Digraph(adj);
<digraph with 4 vertices, 9 edges>
gap> IsReflexiveDigraph(gr);
true
gap> mat := [[2, 1, 0], [0, 1, 0], [0, 0, 0]];;
gap> gr := DigraphByAdjacencyMatrix(mat);
<multidigraph with 3 vertices, 4 edges>
gap> IsReflexiveDigraph(gr);
false
gap> mat := [[2, 0, 3, 1], [1, 1, 0, 2], [3, 0, 4, 0], [9, 1, 2, 1]];;
gap> gr := DigraphByAdjacencyMatrix(mat);
<multidigraph with 4 vertices, 30 edges>
gap> IsReflexiveDigraph(gr);
true

#T# IsCompleteDigraph
gap> gr := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> IsCompleteDigraph(gr);
true
gap> gr := Digraph([[2, 2], []]);
<multidigraph with 2 vertices, 2 edges>
gap> IsCompleteDigraph(gr);
false
gap> gr := Digraph([[1, 2], [1]]);
<digraph with 2 vertices, 3 edges>
gap> IsCompleteDigraph(gr);
false
gap> gr := Digraph([[1, 2], []]);
<digraph with 2 vertices, 2 edges>
gap> IsCompleteDigraph(gr);
false
gap> gr := Digraph([[2], [1]]);
<digraph with 2 vertices, 2 edges>
gap> IsCompleteDigraph(gr);
true

#T# IsConnectedDigraph
gap> gr := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> IsConnectedDigraph(gr);
true
gap> gr := Digraph([[]]);
<digraph with 1 vertex, 0 edges>
gap> IsConnectedDigraph(gr);
true
gap> gr := Digraph([[1]]);
<digraph with 1 vertex, 1 edge>
gap> IsConnectedDigraph(gr);
true
gap> gr := Digraph([[1, 1]]);
<multidigraph with 1 vertex, 2 edges>
gap> IsConnectedDigraph(gr);
true
gap> gr := Digraph([[1], [2]]);
<digraph with 2 vertices, 2 edges>
gap> IsStronglyConnectedDigraph(gr);
false
gap> IsConnectedDigraph(gr);
false
gap> gr := Digraph([[2], [1]]);
<digraph with 2 vertices, 2 edges>
gap> IsStronglyConnectedDigraph(gr);
true
gap> IsConnectedDigraph(gr);
true
gap> gr := Digraph([[2], [3], [], []]);
<digraph with 4 vertices, 2 edges>
gap> IsConnectedDigraph(gr);
false
gap> gr := Digraph([[2], [3], [], [3]]);
<digraph with 4 vertices, 3 edges>
gap> IsConnectedDigraph(gr);
true

#T# DigraphHasLoops
gap> gr := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> DigraphHasLoops(gr);
false
gap> gr := Digraph([[]]);
<digraph with 1 vertex, 0 edges>
gap> DigraphHasLoops(gr);
false
gap> gr := Digraph([[1]]);
<digraph with 1 vertex, 1 edge>
gap> DigraphHasLoops(gr);
true
gap> gr := Digraph([[6, 7], [6, 9], [1, 2, 4, 5, 8, 9],
> [1, 2, 3, 4, 5, 6, 7, 10], [1, 5, 6, 7, 10], [2, 4, 5, 9, 10],
> [3, 4, 5, 6, 7, 8, 9, 10], [1, 3, 5, 7, 8, 9], [1, 2, 5],
> [1, 2, 4, 6, 7, 8]]);
<digraph with 10 vertices, 51 edges>
gap> DigraphHasLoops(gr);
true
gap> gr := Digraph([[6, 7], [6, 9], [1, 2, 4, 5, 8, 9],
> [1, 2, 3, 7, 5, 6, 7, 10], [1, 2, 2, 6, 7, 10], [2, 4, 5, 9, 10],
> [3, 4, 5, 6, 8, 8, 9, 10], [1, 1, 3, 5, 7, 6, 9], [1, 1, 1, 2, 5],
> [1, 2, 4, 6, 7, 8]]);
<multidigraph with 10 vertices, 55 edges>
gap> DigraphHasLoops(gr);
false
gap> gr := Digraph(rec(nrvertices := 0, source := [], range := []));
<digraph with 0 vertices, 0 edges>
gap> DigraphHasLoops(gr);
false
gap> gr := Digraph(rec(nrvertices := 1, source := [], range := []));
<digraph with 1 vertex, 0 edges>
gap> DigraphHasLoops(gr);
false
gap> gr := Digraph(rec(nrvertices := 1, source := [1], range := [1]));
<digraph with 1 vertex, 1 edge>
gap> DigraphHasLoops(gr);
true
gap> r := rec(nrvertices := 10,
> source :=
> [1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6,
>  6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 10, 10, 10, 10,
>  10, 10],
> range  := [6, 7, 6, 9, 1, 2, 4, 5, 8, 9, 1, 2, 3, 4, 5, 6, 7, 10, 1, 5, 6,
>  7, 10, 2, 4, 5, 9, 10, 3, 4, 5, 6, 7, 8, 9, 10, 1, 3, 5, 7, 8, 9, 1, 2, 5,
>  1, 2, 4, 6, 7, 8]);;
gap> gr := Digraph(r);
<digraph with 10 vertices, 51 edges>
gap> DigraphHasLoops(gr);
true
gap> gr := Digraph(r);;
gap> AdjacencyMatrix(gr);;
gap> DigraphHasLoops(gr);
true
gap> r := rec(nrvertices := 10,
> source :=
> [1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 6,
>  6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10,
>  10, 10, 10, 10, 10],
> range  :=
> [6, 7, 6, 9, 1, 2, 4, 5, 8, 9, 1, 2, 3, 7, 5, 6, 7, 10, 1, 2, 2, 6, 7, 10,
>  2, 4, 5, 9, 10, 3, 4, 5, 6, 8, 8, 9, 10, 1, 1, 3, 5, 7, 6, 9, 1, 1, 1, 2,
>  5, 1, 2, 4, 6, 7, 8]);;
gap> gr := Digraph(r);
<multidigraph with 10 vertices, 55 edges>
gap> DigraphHasLoops(gr);
false
gap> gr := Digraph(r);;
gap> AdjacencyMatrix(gr);;
gap> DigraphHasLoops(gr);
false

#T# IsAperiodicDigraph
gap> gr := Digraph([[2], [3], [4], [5], [6], [1], [8], [7]]);
<digraph with 8 vertices, 8 edges>
gap> IsAperiodicDigraph(gr);
false
gap> gr := Digraph([[1]]);
<digraph with 1 vertex, 1 edge>
gap> IsAperiodicDigraph(gr);
true
gap> gr := Digraph([[2, 2], [3, 3], [1], [5], [4, 4, 4]]);
<multidigraph with 5 vertices, 9 edges>
gap> IsAperiodicDigraph(gr);
true
gap> gr := Digraph([[2, 2], [3, 3], [4], []]);
<multidigraph with 4 vertices, 5 edges>
gap> IsAperiodicDigraph(gr);
false

#T# IsTransitiveDigraph
gap> gr := Digraph([[2, 3, 4], [3, 4], [4], [4]]);
<digraph with 4 vertices, 7 edges>
gap> IsTransitiveDigraph(gr);
true
gap> gr := Digraph([[2, 3, 4], [3, 4, 1], [4], [4]]);
<digraph with 4 vertices, 8 edges>
gap> IsTransitiveDigraph(gr);
false
gap> gr := Digraph([[1, 1]]);
<multidigraph with 1 vertex, 2 edges>
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
<digraph with 31 vertices, 100 edges>
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
<digraph with 31 vertices, 265 edges>
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
<multidigraph with 31 vertices, 265 edges>
gap> IsTransitiveDigraph(nottrans);
false
gap> gr := Digraph([[2, 3, 3], [3, 3], []]);;
gap> IsTransitiveDigraph(gr);
true
gap> IS_TRANSITIVE_DIGRAPH(gr);
true

#T# IsBipartiteDigraph
gap> gr := Digraph([[2, 4], [], [1], [1], [4]]);
<digraph with 5 vertices, 5 edges>
gap> IsBipartiteDigraph(gr);
true
gap> gr := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> IsBipartiteDigraph(gr);
false
gap> gr := CycleDigraph(89);
<digraph with 89 vertices, 89 edges>
gap> IsBipartiteDigraph(gr);
false
gap> gr := CycleDigraph(314);
<digraph with 314 vertices, 314 edges>
gap> IsBipartiteDigraph(gr);
true
gap> gr := CompleteDigraph(4);
<digraph with 4 vertices, 12 edges>
gap> IsBipartiteDigraph(gr);
false
gap> gr := Digraph([[2, 4], [], [1], [1], [4], [7], []]);
<digraph with 7 vertices, 6 edges>
gap> IsBipartiteDigraph(gr);
true
gap> gr := Digraph([[2], [3], [1], [6], [6], []]);
<digraph with 6 vertices, 5 edges>
gap> IsBipartiteDigraph(gr);
false
gap> gr := Digraph([[1], [2]]);
<digraph with 2 vertices, 2 edges>
gap> IsBipartiteDigraph(gr);
false
gap> gr := Digraph([[3], [2], [1, 2]]);
<digraph with 3 vertices, 4 edges>
gap> IsBipartiteDigraph(gr);
false
gap> gr := Digraph([[3], [3], [1, 2]]);
<digraph with 3 vertices, 4 edges>
gap> IsBipartiteDigraph(gr);
true
gap> gr := Digraph([[2, 3, 4], [5, 6], [], [7], [], [], []]);
<digraph with 7 vertices, 6 edges>
gap> IsBipartiteDigraph(gr);
true
gap> gr := Digraph([[2, 3, 4], [5, 6], [], [7], [], [], [], [9], []]);
<digraph with 9 vertices, 7 edges>
gap> IsBipartiteDigraph(gr);
true
gap> gr := Digraph([[1]]);
<digraph with 1 vertex, 1 edge>
gap> DigraphHasLoops(gr);
true
gap> IsBipartiteDigraph(gr);
false

#T# IsIn/OutRegularDigraph
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

#T# IsDistanceRegularDigraph
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
<digraph with 14 vertices, 42 edges>
gap> IsDistanceRegularDigraph(gr);
true
gap> IsDistanceRegularDigraph(ChainDigraph(5));
false
gap> IsDistanceRegularDigraph(EmptyDigraph(2));
true
gap> gr := Digraph([[2], [1], [4], [3]]);
<digraph with 4 vertices, 4 edges>
gap> IsDistanceRegularDigraph(gr);
false
gap> gr := Digraph([[2], [1, 3], [2, 4], [3, 5, 6], [4, 6], [4, 5]]);
<digraph with 6 vertices, 12 edges>
gap> IsDistanceRegularDigraph(gr);
false
gap> gr := CompleteBipartiteDigraph(3, 4);
<digraph with 7 vertices, 24 edges>
gap> IsDistanceRegularDigraph(gr);
false
gap> gr := Digraph([[], [3], [2]]);
<digraph with 3 vertices, 2 edges>
gap> IsDistanceRegularDigraph(gr);
false

#T# IsCompleteBipartiteDigraph
gap> gr := CompleteBipartiteDigraph(4, 5);
<digraph with 9 vertices, 40 edges>
gap> IsCompleteBipartiteDigraph(gr);
true
gap> gr := Digraph([[2, 2], []]);
<multidigraph with 2 vertices, 2 edges>
gap> IsCompleteBipartiteDigraph(gr);
false
gap> gr := CycleDigraph(3);
<digraph with 3 vertices, 3 edges>
gap> IsCompleteBipartiteDigraph(gr);
false
gap> gr := CycleDigraph(4);
<digraph with 4 vertices, 4 edges>
gap> IsCompleteBipartiteDigraph(gr);
false
gap> gr := Digraph([[2], [1]]);
<digraph with 2 vertices, 2 edges>
gap> IsCompleteBipartiteDigraph(gr);
true

#T# IsDirectedTree
gap> g := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[]]);
<digraph with 1 vertex, 0 edges>
gap> IsDirectedTree(g);
true
gap> g := Digraph([[], []]);
<digraph with 2 vertices, 0 edges>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[1]]);
<digraph with 1 vertex, 1 edge>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[2, 2], []]);
<multidigraph with 2 vertices, 2 edges>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[], [2]]);
<digraph with 2 vertices, 1 edge>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[2], [1]]);
<digraph with 2 vertices, 2 edges>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[3], [3], []]);
<digraph with 3 vertices, 2 edges>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[2], [3], []]);
<digraph with 3 vertices, 2 edges>
gap> IsDirectedTree(g);
true
gap> g := Digraph([[2], [3], [], []]);
<digraph with 4 vertices, 2 edges>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[2, 3], [6], [4, 5], [], [], []]);
<digraph with 6 vertices, 5 edges>
gap> IsDirectedTree(g);
true
gap> g := Digraph([[2, 3], [6], [4, 5], [], [], [], []]);
<digraph with 7 vertices, 5 edges>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[2, 3], [6], [4, 5], [7], [], [7], []]);
<digraph with 7 vertices, 7 edges>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[2, 3], [1, 3], [1, 2]]);
<digraph with 3 vertices, 6 edges>
gap> IsDirectedTree(g);
false
gap> g := Digraph([[2, 3, 4], [1, 3, 4], [1, 2, 4], [1, 2, 3]]);
<digraph with 4 vertices, 12 edges>
gap> IsDirectedTree(g);
false

#T# IsUndirectedTree
gap> g := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[]]);
<digraph with 1 vertex, 0 edges>
gap> IsUndirectedTree(g);
true
gap> g := Digraph([[], []]);
<digraph with 2 vertices, 0 edges>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[1]]);
<digraph with 1 vertex, 1 edge>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[2, 2], []]);
<multidigraph with 2 vertices, 2 edges>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[], [2]]);
<digraph with 2 vertices, 1 edge>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[2], [1]]);
<digraph with 2 vertices, 2 edges>
gap> IsUndirectedTree(g);
true
gap> g := Digraph([[3], [3], []]);
<digraph with 3 vertices, 2 edges>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[3], [3], [1, 2]]);
<digraph with 3 vertices, 4 edges>
gap> IsUndirectedTree(g);
true
gap> g := Digraph([[3], [3], [1, 2], []]);
<digraph with 4 vertices, 4 edges>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[2, 3], [6], [4, 5], [], [], []]);
<digraph with 6 vertices, 5 edges>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[2, 3], [6, 1], [4, 5, 1], [3], [3], [2]]);
<digraph with 6 vertices, 10 edges>
gap> IsUndirectedTree(g);
true
gap> g := Digraph([[2, 3], [1, 3], [1, 2]]);
<digraph with 3 vertices, 6 edges>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[2, 3, 4], [1, 3, 4], [1, 2, 4], [1, 2, 3]]);
<digraph with 4 vertices, 12 edges>
gap> IsUndirectedTree(g);
false
gap> g := Digraph([[1], [2]]);
<digraph with 2 vertices, 2 edges>
gap> IsConnectedDigraph(g);
false

#T# IsUndirectedForest
gap> gr := ChainDigraph(10);
<digraph with 10 vertices, 9 edges>
gap> IsUndirectedForest(gr);
false
gap> gr := EmptyDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> IsUndirectedForest(gr);
false
gap> gr := EmptyDigraph(1);
<digraph with 1 vertex, 0 edges>
gap> IsUndirectedForest(gr);
true
gap> gr := Digraph([[1, 1]]);
<multidigraph with 1 vertex, 2 edges>
gap> IsUndirectedForest(gr);
false
gap> gr := Digraph([[1]]);
<digraph with 1 vertex, 1 edge>
gap> IsUndirectedForest(gr);
false
gap> gr := DigraphSymmetricClosure(ChainDigraph(4));
<digraph with 4 vertices, 6 edges>
gap> HasIsUndirectedTree(gr) or HasIsUndirectedForest(gr);
false
gap> IsUndirectedTree(gr);
true
gap> HasIsUndirectedForest(gr);
true
gap> IsUndirectedForest(gr);
true
gap> gr := DigraphDisjointUnion(gr, gr, gr);
<digraph with 12 vertices, 18 edges>
gap> IsUndirectedTree(gr);
false
gap> IsUndirectedForest(gr);
true
gap> gr := DigraphDisjointUnion(CompleteDigraph(2), CycleDigraph(3));
<digraph with 5 vertices, 5 edges>
gap> IsUndirectedForest(gr);
false

#T# IsEulerianDigraph
gap> g := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[]]);
<digraph with 1 vertex, 0 edges>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[], []]);
<digraph with 2 vertices, 0 edges>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[1]]);
<digraph with 1 vertex, 1 edge>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[2, 2], []]);
<multidigraph with 2 vertices, 2 edges>
gap> IsEulerianDigraph(g);
false
gap> g := Digraph([[2], [1]]);
<digraph with 2 vertices, 2 edges>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[3], [3], []]);
<digraph with 3 vertices, 2 edges>
gap> IsEulerianDigraph(g);
false
gap> g := Digraph([[3], [3], [1, 2]]);
<digraph with 3 vertices, 4 edges>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[3], [], [2]]);
<digraph with 3 vertices, 2 edges>
gap> IsEulerianDigraph(g);
false
gap> g := Digraph([[2], [3], [1]]);
<digraph with 3 vertices, 3 edges>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[2], [3], [1], []]);
<digraph with 4 vertices, 3 edges>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[2], [3], [1, 4], []]);
<digraph with 4 vertices, 4 edges>
gap> IsEulerianDigraph(g);
false
gap> g := Digraph([[3, 6], [4], [2, 1], [5, 1], [3], [4]]);
<digraph with 6 vertices, 9 edges>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[3, 6], [4], [2, 1], [5, 1], [3], [4], []]);
<digraph with 7 vertices, 9 edges>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[3, 6], [4], [2, 1], [5, 1], [3], [4, 7], []]);
<digraph with 7 vertices, 10 edges>
gap> IsEulerianDigraph(g);
false
gap> g := Digraph([[3, 6], [4], [2, 1], [5, 1], [3], [4, 7], [6]]);
<digraph with 7 vertices, 11 edges>
gap> IsEulerianDigraph(g);
true
gap> g := Digraph([[2, 3], [3], [1]]);
<digraph with 3 vertices, 4 edges>
gap> IsEulerianDigraph(g);
false

#T# DIGRAPHS_UnbindVariables
gap> Unbind(adj);
gap> Unbind(circuit);
gap> Unbind(complete100);
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

#E#
gap> STOP_TEST("Digraphs package: standard/prop.tst");
