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

# IsJoinSemilatticeDigraph, IsMeetSemilatticeDigraph, and IsLatticeDigraph
gap> gr := Digraph([[1, 2], [2]]);
<digraph with 2 vertices, 3 edges>
gap> IsMeetSemilatticeDigraph(gr);
true
gap> IsJoinSemilatticeDigraph(gr);
true
gap> IsLatticeDigraph(gr);
true
gap> gr := CycleDigraph(5);
<digraph with 5 vertices, 5 edges>
gap> IsMeetSemilatticeDigraph(gr);
false
gap> IsJoinSemilatticeDigraph(gr);
false

# IsPartialOrderDigraph
gap> gr := NullDigraph(5);
<digraph with 5 vertices, 0 edges>
gap> IsPartialOrderDigraph(gr);
false
gap> gr := Digraph([[1], [2], [3]]);
<digraph with 3 vertices, 3 edges>
gap> IsPartialOrderDigraph(gr);
true
gap> gr := 
> Digraph( [ [ 1 ], [ 1, 2 ], [ 1, 2, 3 ], [ 1, 2, 3, 4 ], [ 1, 2, 3, 4, 5 ], [ \
> 1, 2, 3, 4, 5, 6 ], [ 2, 7 ], [ 2, 3, 7, 8 ], [ 2, 4, 8, 9 ], [ 2, 5, 9, 10 ],\
>  [ 2, 6, 10, 11 ], [ 2, 3, 7, 12 ], [ 3, 8, 12, 13 ], [ 3, 4, 9, 13, 14 ], [ 3\
> , 5, 10, 14, 15 ], [ 3, 6, 11, 15, 16 ], [ 2, 3, 17 ], [ 2, 3, 7, 12, 17, 18, \
> 147 ], [ 3, 8, 12, 13, 18, 19, 148 ], [ 3, 4, 9, 13, 14, 19, 20, 149 ], [ 3, 5\
> , 10, 14, 15, 20, 21, 150 ], [ 3, 6, 11, 15, 16, 21, 22, 151 ], [ 2, 4, 12, 23\
>  ], [ 3, 4, 13, 23, 24 ], [ 4, 14, 24, 25 ], [ 4, 5, 15, 25, 26 ], [ 4, 6, 16,\
>  26, 27 ], [ 2, 3, 4, 17, 28 ], [ 2, 3, 4, 12, 18, 23, 28, 29 ], [ 3, 4, 13, 1\
> 9, 23, 24, 29, 30 ], [ 4, 14, 20, 24, 25, 30, 31 ], [ 4, 5, 15, 21, 25, 26, 31\
> , 32 ], [ 4, 6, 16, 22, 26, 27, 32, 33 ], [ 2, 3, 4, 17, 34 ], [ 2, 3, 4, 17, \
> 35, 152 ], [ 2, 3, 4, 17, 36 ], [ 2, 3, 4, 17, 28, 34, 36, 37 ], [ 2, 3, 4, 28\
> , 35, 36, 38, 153 ], [ 2, 3, 4, 18, 23, 29, 36, 38, 39, 154 ], [ 3, 4, 17, 19,\
>  24, 29, 30, 35, 37, 39, 40, 152, 155 ], [ 4, 20, 25, 30, 31, 34, 35, 40, 41, \
> 153, 156 ], [ 4, 5, 21, 26, 31, 32, 34, 35, 41, 42, 65, 157, 162 ], [ 4, 6, 22\
> , 27, 32, 33, 34, 35, 42, 43, 120, 158, 177 ], [ 2, 5, 23, 44 ], [ 3, 5, 24, 4\
> 4, 45 ], [ 4, 5, 25, 45, 46 ], [ 5, 26, 46, 47 ], [ 5, 6, 27, 47, 48 ], [ 2, 3\
> , 4, 5, 28, 49 ], [ 2, 3, 5, 23, 29, 44, 49, 50 ], [ 3, 5, 24, 30, 44, 45, 50,\
>  51 ], [ 4, 5, 25, 31, 45, 46, 51, 52 ], [ 5, 26, 32, 46, 47, 52, 53 ], [ 5, 6\
> , 27, 33, 47, 48, 53, 54 ], [ 2, 3, 4, 5, 28, 34, 55 ], [ 2, 3, 4, 5, 28, 35, \
> 56 ], [ 2, 3, 4, 5, 28, 36, 57 ], [ 2, 3, 4, 5, 17, 28, 37, 49, 55, 57, 58 ], \
> [ 2, 3, 4, 5, 38, 49, 56, 57, 59 ], [ 2, 3, 4, 5, 29, 39, 44, 50, 57, 59, 60 ]\
> , [ 3, 4, 5, 17, 30, 40, 45, 50, 51, 56, 58, 60, 61, 152 ], [ 4, 5, 31, 34, 41\
> , 46, 51, 52, 55, 56, 61, 62, 153 ], [ 5, 32, 42, 47, 52, 53, 55, 56, 62, 63, \
> 65, 162 ], [ 5, 6, 33, 43, 48, 53, 54, 55, 56, 63, 64, 120, 177 ], [ 2, 3, 4, \
> 5, 34, 36, 65 ], [ 2, 3, 4, 5, 17, 34, 37, 55, 65, 66 ], [ 2, 3, 5, 35, 67, 15\
> 3 ], [ 2, 3, 4, 5, 17, 35, 37, 38, 55, 56, 67, 68, 152, 159 ], [ 2, 3, 5, 17, \
> 35, 69, 160 ], [ 2, 3, 4, 5, 36, 38, 56, 69, 70, 161 ], [ 2, 3, 4, 5, 36, 71 ]\
> , [ 2, 3, 4, 5, 17, 36, 37, 57, 65, 71, 72 ], [ 2, 3, 4, 5, 17, 28, 34, 36, 37\
> , 58, 66, 72, 73 ], [ 2, 3, 4, 5, 38, 57, 71, 74, 162 ], [ 2, 3, 4, 5, 17, 28,\
>  35, 36, 58, 59, 68, 72, 74, 75, 153, 163 ], [ 2, 3, 4, 5, 49, 59, 70, 71, 74,\
>  76, 164 ], [ 2, 3, 4, 5, 39, 44, 50, 60, 71, 74, 76, 77, 165 ], [ 3, 4, 5, 17\
> , 36, 40, 45, 51, 56, 60, 61, 69, 72, 75, 77, 78, 152, 153, 160, 166 ], [ 4, 5\
> , 28, 35, 37, 41, 46, 52, 61, 62, 67, 68, 69, 70, 73, 78, 79, 159, 160, 161, 1\
> 67 ], [ 5, 42, 47, 53, 55, 62, 63, 65, 66, 67, 68, 69, 70, 79, 80, 163, 164, 1\
> 68, 171 ], [ 5, 6, 43, 48, 54, 63, 64, 65, 66, 67, 68, 69, 70, 80, 81, 103, 12\
> 1, 123, 169, 178, 180, 200 ], [ 2, 6, 44, 82 ], [ 3, 6, 45, 82, 83 ], [ 4, 6, \
> 46, 83, 84 ], [ 5, 6, 47, 84, 85 ], [ 6, 48, 85, 86 ], [ 2, 3, 4, 5, 6, 49, 87\
>  ], [ 2, 3, 6, 44, 50, 82, 87, 88 ], [ 3, 6, 45, 51, 82, 83, 88, 89 ], [ 4, 6,\
>  46, 52, 83, 84, 89, 90 ], [ 5, 6, 47, 53, 84, 85, 90, 91 ], [ 6, 48, 54, 85, \
> 86, 91, 92 ], [ 2, 3, 4, 5, 6, 49, 55, 93 ], [ 2, 3, 4, 5, 6, 49, 56, 94 ], [ \
> 2, 3, 4, 5, 6, 49, 57, 95 ], [ 2, 3, 4, 5, 6, 17, 49, 58, 87, 93, 95, 96 ], [ \
> 2, 3, 4, 5, 6, 59, 87, 94, 95, 97 ], [ 2, 3, 4, 6, 50, 60, 82, 88, 95, 97, 98 \
> ], [ 3, 4, 6, 17, 51, 61, 83, 88, 89, 94, 96, 98, 99, 152 ], [ 4, 6, 34, 52, 6\
> 2, 84, 89, 90, 93, 94, 99, 100, 153 ], [ 5, 6, 53, 63, 65, 85, 90, 91, 93, 94,\
>  100, 101, 162 ], [ 6, 54, 64, 86, 91, 92, 93, 94, 101, 102, 120, 177 ], [ 2, \
> 3, 4, 6, 55, 65, 103 ], [ 2, 3, 4, 5, 6, 17, 28, 34, 55, 58, 66, 93, 103, 104 \
> ], [ 2, 3, 4, 6, 56, 67, 105 ], [ 2, 3, 4, 5, 6, 17, 28, 56, 58, 59, 68, 93, 9\
> 4, 105, 106, 152 ], [ 2, 3, 4, 6, 28, 56, 69, 107 ], [ 2, 3, 4, 5, 6, 57, 59, \
> 70, 94, 107, 108 ], [ 2, 3, 4, 5, 6, 57, 71, 109 ], [ 2, 3, 4, 5, 6, 28, 36, 5\
> 8, 72, 95, 109, 110 ], [ 2, 3, 4, 5, 6, 17, 28, 34, 37, 55, 57, 58, 73, 96, 10\
> 4, 110, 111 ], [ 2, 3, 4, 5, 6, 59, 74, 95, 109, 112 ], [ 2, 3, 4, 5, 6, 17, 2\
> 8, 36, 49, 56, 75, 96, 97, 106, 110, 112, 113, 153 ], [ 2, 3, 4, 5, 6, 76, 87,\
>  97, 108, 109, 112, 114 ], [ 2, 3, 4, 5, 6, 60, 77, 82, 88, 98, 109, 112, 114,\
>  115 ], [ 3, 4, 5, 6, 17, 36, 61, 78, 83, 89, 94, 98, 99, 107, 110, 113, 115, \
> 116, 152, 153, 160 ], [ 4, 5, 6, 28, 35, 37, 62, 79, 84, 90, 99, 100, 105, 106\
> , 107, 108, 111, 116, 117, 159, 160, 161 ], [ 5, 6, 55, 63, 66, 67, 80, 85, 91\
> , 100, 101, 103, 104, 105, 106, 107, 108, 117, 118, 163, 164, 171 ], [ 6, 64, \
> 81, 86, 92, 101, 102, 103, 104, 105, 106, 107, 108, 118, 119, 121, 123, 178, 1\
> 80, 200 ], [ 2, 3, 4, 5, 6, 65, 71, 120 ], [ 2, 3, 4, 5, 6, 17, 34, 36, 65, 66\
> , 72, 103, 120, 121 ], [ 2, 3, 4, 5, 6, 17, 28, 34, 36, 37, 55, 65, 66, 73, 10\
> 4, 121, 122 ], [ 2, 3, 4, 6, 67, 123, 162 ], [ 2, 3, 4, 6, 17, 34, 35, 68, 103\
> , 105, 123, 124, 153, 163 ], [ 2, 3, 4, 5, 6, 17, 28, 35, 36, 37, 38, 67, 68, \
> 73, 75, 104, 106, 124, 125, 152, 159, 170 ], [ 2, 3, 6, 69, 126, 171 ], [ 2, 3\
> , 4, 6, 17, 35, 37, 70, 105, 107, 126, 127, 152, 172 ], [ 2, 3, 4, 5, 6, 17, 2\
> 8, 35, 36, 56, 69, 72, 75, 76, 93, 106, 108, 127, 128, 152, 153, 160, 173 ], [\
>  2, 3, 6, 17, 69, 129, 174 ], [ 2, 3, 4, 6, 36, 38, 70, 107, 129, 130, 175 ], \
> [ 2, 3, 4, 5, 6, 71, 74, 76, 94, 108, 130, 131, 176 ], [ 2, 3, 4, 5, 6, 71, 13\
> 2 ], [ 2, 3, 4, 5, 6, 17, 71, 72, 109, 120, 132, 133 ], [ 2, 3, 4, 5, 6, 17, 3\
> 4, 36, 37, 57, 65, 72, 73, 110, 121, 133, 134 ], [ 2, 3, 4, 5, 6, 17, 28, 34, \
> 36, 37, 49, 55, 58, 65, 66, 71, 72, 73, 111, 122, 134, 135 ], [ 2, 3, 4, 5, 6,\
>  74, 109, 132, 136, 177 ], [ 2, 3, 4, 5, 6, 17, 28, 35, 36, 71, 75, 110, 112, \
> 133, 136, 137, 162, 178 ], [ 2, 3, 4, 5, 6, 17, 28, 35, 36, 38, 57, 58, 67, 68\
> , 72, 111, 113, 125, 134, 137, 138, 153, 163, 179 ], [ 2, 3, 4, 5, 6, 76, 95, \
> 112, 132, 136, 139, 180 ], [ 2, 3, 4, 5, 6, 17, 28, 35, 36, 49, 56, 69, 71, 96\
> , 113, 114, 128, 133, 137, 139, 140, 153, 162, 171, 181 ], [ 2, 3, 4, 5, 6, 87\
> , 97, 114, 131, 132, 136, 139, 141, 182 ], [ 2, 3, 4, 5, 6, 77, 82, 88, 98, 11\
> 5, 132, 136, 139, 141, 142, 183 ], [ 3, 4, 5, 6, 17, 36, 71, 78, 83, 89, 94, 9\
> 9, 107, 115, 116, 129, 133, 137, 140, 142, 143, 152, 153, 160, 162, 171, 174, \
> 184 ], [ 4, 5, 6, 28, 35, 38, 57, 72, 79, 84, 90, 100, 106, 108, 116, 117, 126\
> , 127, 129, 130, 134, 138, 143, 144, 160, 161, 163, 172, 175, 185, 198 ], [ 5,\
>  6, 49, 56, 58, 68, 69, 73, 80, 85, 91, 101, 117, 118, 123, 124, 125, 126, 127\
> , 128, 129, 130, 131, 135, 144, 145, 170, 172, 173, 174, 176, 186, 199 ], [ 6,\
>  81, 86, 92, 93, 102, 104, 105, 118, 119, 120, 121, 122, 123, 124, 125, 126, 1\
> 27, 128, 129, 130, 131, 145, 146, 179, 181, 182, 187, 201, 202, 213 ], [ 2, 3,\
>  7, 147 ], [ 2, 3, 7, 8, 17, 147, 148 ], [ 2, 3, 4, 8, 9, 36, 148, 149 ], [ 2,\
>  3, 5, 9, 10, 71, 149, 150 ], [ 2, 3, 6, 10, 11, 132, 150, 151 ], [ 2, 3, 152 \
> ], [ 2, 3, 4, 17, 152, 153 ], [ 2, 3, 4, 12, 18, 147, 153, 154, 188 ], [ 3, 4,\
>  13, 18, 19, 34, 148, 152, 154, 155, 189 ], [ 3, 4, 14, 17, 19, 20, 37, 149, 1\
> 52, 153, 155, 156, 190 ], [ 3, 4, 5, 15, 17, 20, 21, 72, 150, 152, 156, 157, 1\
> 62, 191 ], [ 3, 4, 6, 16, 17, 21, 22, 133, 151, 152, 157, 158, 177, 192 ], [ 2\
> , 3, 4, 34, 35, 152, 153, 159 ], [ 2, 3, 4, 152, 160 ], [ 2, 3, 4, 35, 153, 16\
> 0, 161 ], [ 2, 3, 4, 5, 36, 153, 162 ], [ 2, 3, 4, 5, 17, 37, 38, 65, 67, 152,\
>  153, 159, 162, 163 ], [ 2, 3, 4, 5, 28, 38, 161, 162, 164, 171 ], [ 2, 3, 4, \
> 5, 23, 29, 39, 154, 162, 164, 165, 193 ], [ 3, 4, 5, 17, 24, 30, 35, 39, 40, 6\
> 5, 152, 153, 155, 160, 163, 165, 166, 194 ], [ 4, 5, 25, 31, 35, 40, 41, 66, 1\
> 53, 156, 159, 160, 161, 166, 167, 195 ], [ 4, 5, 26, 32, 36, 37, 41, 42, 67, 7\
> 3, 153, 157, 159, 160, 161, 163, 164, 167, 168, 171, 196 ], [ 4, 5, 6, 27, 33,\
>  36, 37, 42, 43, 123, 134, 153, 158, 159, 160, 161, 168, 169, 178, 180, 197, 2\
> 00 ], [ 2, 3, 4, 5, 35, 66, 68, 152, 153, 159, 163, 170 ], [ 2, 3, 5, 17, 153,\
>  160, 171 ], [ 2, 3, 4, 5, 34, 67, 69, 152, 161, 171, 172 ], [ 2, 3, 4, 5, 17,\
>  35, 55, 65, 68, 70, 152, 153, 160, 163, 164, 172, 173 ], [ 2, 3, 5, 160, 174 \
> ], [ 2, 3, 4, 5, 69, 153, 161, 174, 175, 198 ], [ 2, 3, 4, 5, 56, 70, 162, 164\
> , 175, 176, 199 ], [ 2, 3, 4, 5, 6, 71, 162, 177 ], [ 2, 3, 4, 5, 6, 17, 36, 7\
> 2, 74, 120, 123, 152, 162, 163, 177, 178 ], [ 2, 3, 4, 5, 6, 17, 28, 36, 37, 3\
> 8, 67, 73, 75, 121, 124, 152, 153, 159, 163, 170, 178, 179 ], [ 2, 3, 4, 5, 6,\
>  57, 74, 164, 177, 180, 200 ], [ 2, 3, 4, 5, 6, 17, 28, 35, 36, 58, 75, 76, 12\
> 0, 152, 153, 160, 162, 171, 173, 178, 180, 181, 201 ], [ 2, 3, 4, 5, 6, 49, 59\
> , 76, 176, 177, 180, 182, 202 ], [ 2, 3, 4, 5, 6, 44, 50, 60, 77, 165, 177, 18\
> 0, 182, 183, 203 ], [ 3, 4, 5, 6, 17, 36, 45, 51, 56, 61, 69, 77, 78, 120, 152\
> , 153, 160, 162, 166, 171, 174, 178, 181, 183, 184, 204 ], [ 4, 5, 6, 28, 35, \
> 38, 46, 52, 62, 68, 70, 78, 79, 121, 160, 161, 163, 167, 171, 172, 174, 175, 1\
> 79, 184, 185, 198, 205 ], [ 5, 6, 47, 53, 56, 63, 68, 69, 79, 80, 122, 162, 16\
> 3, 168, 170, 171, 172, 173, 174, 175, 176, 185, 186, 199, 206 ], [ 5, 6, 48, 5\
> 4, 64, 71, 72, 73, 80, 81, 105, 124, 126, 135, 162, 163, 169, 170, 171, 172, 1\
> 73, 174, 175, 176, 179, 181, 182, 186, 187, 201, 202, 207, 213 ], [ 2, 4, 7, 1\
> 47, 188 ], [ 2, 3, 4, 8, 35, 147, 148, 188, 189 ], [ 2, 3, 4, 9, 28, 38, 148, \
> 149, 189, 190 ], [ 2, 3, 4, 5, 10, 57, 74, 149, 150, 190, 191 ], [ 2, 3, 4, 6,\
>  11, 109, 136, 150, 151, 191, 192 ], [ 2, 3, 5, 12, 18, 154, 171, 188, 193, 20\
> 8 ], [ 3, 5, 13, 19, 67, 152, 154, 189, 193, 194, 209 ], [ 3, 4, 5, 14, 17, 20\
> , 35, 55, 68, 152, 153, 155, 156, 160, 190, 194, 195, 210 ], [ 3, 4, 5, 15, 17\
> , 21, 28, 35, 58, 75, 152, 156, 157, 160, 162, 171, 191, 195, 196, 211 ], [ 3,\
>  4, 5, 6, 16, 17, 22, 28, 35, 110, 137, 152, 157, 158, 160, 177, 192, 196, 197\
> , 200, 212 ], [ 2, 4, 160, 198 ], [ 2, 3, 4, 5, 35, 161, 171, 174, 198, 199 ],\
>  [ 2, 3, 4, 6, 36, 162, 171, 200 ], [ 2, 3, 4, 6, 17, 37, 123, 126, 152, 153, \
> 164, 172, 200, 201 ], [ 2, 3, 4, 6, 28, 38, 164, 199, 200, 202, 213 ], [ 2, 3,\
>  4, 6, 23, 29, 39, 165, 193, 200, 202, 203, 214 ], [ 3, 4, 6, 17, 24, 30, 35, \
> 40, 123, 152, 153, 160, 165, 194, 201, 203, 204, 215 ], [ 4, 6, 25, 31, 35, 41\
> , 103, 124, 153, 159, 160, 161, 166, 195, 198, 204, 205, 216 ], [ 4, 5, 6, 26,\
>  32, 36, 38, 42, 68, 69, 104, 125, 153, 160, 161, 163, 164, 167, 168, 172, 174\
> , 196, 198, 199, 205, 206, 217 ], [ 4, 5, 6, 27, 33, 36, 38, 43, 57, 58, 68, 1\
> 11, 126, 138, 153, 160, 161, 168, 169, 172, 178, 180, 197, 198, 199, 201, 202,\
>  206, 207, 213, 218 ], [ 2, 5, 7, 188, 208 ], [ 2, 3, 5, 8, 69, 148, 188, 189,\
>  208, 209 ], [ 2, 3, 4, 5, 9, 56, 70, 149, 189, 190, 209, 210 ], [ 2, 3, 4, 5,\
>  10, 49, 59, 76, 150, 190, 191, 210, 211 ], [ 2, 3, 4, 5, 6, 11, 95, 112, 139,\
>  151, 191, 192, 211, 212 ], [ 2, 3, 6, 17, 171, 174, 213 ], [ 2, 3, 6, 12, 18,\
>  193, 208, 213, 214, 219 ], [ 3, 6, 13, 19, 126, 152, 193, 209, 214, 215, 220 \
> ], [ 3, 4, 6, 14, 17, 20, 35, 105, 127, 152, 153, 156, 160, 194, 210, 215, 216\
> , 221 ], [ 3, 4, 5, 6, 15, 17, 21, 28, 35, 56, 69, 93, 106, 128, 152, 157, 160\
> , 162, 171, 174, 195, 196, 211, 216, 217, 222 ], [ 3, 4, 5, 6, 16, 17, 22, 28,\
>  35, 49, 56, 69, 96, 113, 140, 152, 158, 160, 174, 177, 196, 197, 200, 212, 21\
> 3, 217, 218, 223 ], [ 2, 6, 7, 208, 219 ], [ 2, 3, 6, 8, 129, 148, 208, 209, 2\
> 19, 220 ], [ 2, 3, 4, 6, 9, 107, 130, 149, 190, 209, 210, 220, 221 ], [ 2, 3, \
> 4, 5, 6, 10, 94, 108, 131, 150, 191, 210, 211, 221, 222 ], [ 2, 3, 4, 5, 6, 11\
> , 87, 97, 114, 141, 151, 192, 211, 212, 222, 223 ], [ 2, 7, 224 ], [ 2, 3, 8, \
> 12, 18, 148, 224, 225 ], [ 2, 4, 9, 23, 29, 39, 149, 190, 225, 226 ], [ 2, 5, \
> 10, 44, 50, 60, 77, 150, 191, 211, 226, 227 ], [ 2, 6, 11, 82, 88, 98, 115, 14\
> 2, 151, 192, 212, 223, 227, 228 ], [ 2, 3, 6, 174, 229 ], [ 3, 13, 19, 152, 22\
> 5, 230 ], [ 3, 4, 14, 20, 24, 30, 35, 40, 153, 156, 160, 226, 230, 231 ], [ 3,\
>  5, 15, 21, 45, 51, 56, 61, 69, 78, 157, 162, 171, 174, 196, 227, 231, 232 ], \
> [ 3, 6, 16, 22, 83, 89, 94, 99, 107, 116, 129, 143, 158, 177, 197, 200, 213, 2\
> 18, 228, 229, 232, 233 ], [ 2, 3, 4, 6, 34, 126, 129, 152, 175, 199, 213, 234 \
> ], [ 2, 3, 4, 6, 129, 153, 175, 229, 235, 236 ], [ 2, 4, 5, 174, 198, 236 ], [\
>  2, 3, 4, 6, 35, 199, 213, 229, 236, 237 ], [ 2, 4, 6, 229, 236, 238 ], [ 4, 2\
> 5, 31, 41, 159, 161, 198, 231, 239 ], [ 4, 5, 26, 32, 42, 46, 52, 62, 68, 70, \
> 79, 163, 164, 168, 172, 175, 199, 232, 236, 239, 240 ], [ 4, 6, 27, 33, 43, 84\
> , 90, 100, 106, 108, 117, 127, 130, 144, 169, 178, 180, 201, 202, 207, 233, 23\
> 4, 235, 237, 238, 240, 241 ], [ 2, 3, 4, 5, 6, 35, 66, 103, 124, 127, 152, 153\
> , 159, 160, 161, 173, 201, 242 ], [ 2, 3, 4, 5, 6, 17, 35, 65, 105, 127, 130, \
> 152, 153, 160, 163, 176, 234, 243, 244 ], [ 2, 3, 5, 67, 152, 175, 199, 244 ],\
>  [ 2, 3, 4, 5, 6, 17, 35, 55, 68, 123, 152, 153, 160, 176, 201, 202, 234, 244,\
>  245 ], [ 2, 3, 5, 69, 171, 175, 199, 236, 246 ], [ 2, 3, 5, 6, 67, 126, 152, \
> 235, 237, 246, 247 ], [ 2, 3, 5, 6, 129, 171, 235, 238, 246, 248, 250 ], [ 2, \
> 3, 4, 5, 6, 56, 70, 176, 200, 202, 237, 246, 249 ], [ 2, 5, 236, 250 ], [ 2, 3\
> , 5, 6, 69, 213, 237, 238, 246, 250, 251 ], [ 2, 5, 6, 238, 250, 252 ], [ 5, 4\
> 7, 53, 63, 80, 170, 173, 176, 240, 244, 246, 250, 253 ], [ 2, 3, 4, 5, 6, 107,\
>  130, 162, 164, 176, 235, 246, 254 ], [ 5, 6, 48, 54, 64, 81, 85, 91, 101, 118\
> , 125, 128, 131, 145, 179, 181, 182, 187, 241, 242, 243, 245, 247, 248, 249, 2\
> 51, 252, 253, 254, 255 ], [ 2, 3, 4, 5, 6, 35, 56, 68, 122, 125, 152, 153, 159\
> , 162, 163, 170, 179, 256 ], [ 2, 3, 4, 5, 6, 28, 35, 36, 38, 68, 69, 104, 121\
> , 125, 128, 152, 153, 160, 161, 163, 171, 172, 179, 181, 242, 257 ], [ 2, 3, 4\
> , 6, 35, 103, 124, 152, 153, 159, 160, 161, 198, 243, 245, 258 ], [ 2, 3, 4, 5\
> , 6, 17, 28, 35, 36, 56, 69, 93, 106, 120, 128, 131, 152, 153, 160, 162, 171, \
> 174, 178, 181, 182, 243, 245, 259 ], [ 2, 3, 4, 6, 17, 35, 105, 123, 127, 152,\
>  153, 160, 201, 247, 249, 254, 260 ], [ 2, 3, 6, 126, 152, 248, 251, 261 ], [ \
> 2, 3, 4, 5, 6, 94, 108, 131, 177, 180, 182, 249, 254, 262 ], [ 2, 3, 4, 6, 107\
> , 130, 200, 202, 248, 249, 251, 254, 263 ], [ 2, 3, 6, 129, 213, 248, 251, 252\
> , 264 ], [ 2, 6, 252, 265 ], [ 6, 86, 92, 102, 119, 146, 255, 256, 257, 258, 2\
> 59, 260, 261, 262, 263, 264, 265, 266 ] ] );
<digraph with 266 vertices, 3121 edges>
gap> gr := DigraphReflexiveTransitiveClosure(gr);
<digraph with 266 vertices, 10772 edges>
gap> IsPartialOrderDigraph(gr);
true
gap> IsMeetSemilatticeDigraph(gr);
false
gap> IsJoinSemilatticeDigraph(gr);
false
gap> IsLatticeDigraph(gr);
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
