#############################################################################
##
#W  prop.tst
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: prop.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DigraphsStartTest();

# IsMultiDigraph
gap> gr1 := Digraph( [ ] );
<digraph with 0 vertices, 0 edges>
gap> IsMultiDigraph(gr1);
false

#
gap> gr2 := Digraph( [ [ ] ] );
<digraph with 1 vertex, 0 edges>
gap> IsMultiDigraph(gr2);
false

#
gap> source := [1..10000];;
gap> range := List( source, x->Random(source) );;
gap> r := rec (vertices := [ 1 .. 10000 ], source := source, range := range);;
gap> gr3 := Digraph(r);
<digraph with 10000 vertices, 10000 edges>
gap> IsMultiDigraph(gr3);
false

#
gap> Add(source, 10000);;
gap> Add(range, range[10000]);;
gap> r := rec(vertices := [ 1 .. 10000 ], source := source, range := range);;
gap> gr4 := Digraph(r);
<multidigraph with 10000 vertices, 10001 edges>
gap> IsMultiDigraph(gr4);
true

# IsAcyclicDigraph (& checking IsMultiDigraph too)
gap> loop := Digraph([ [1] ]);
<digraph with 1 vertex, 1 edge>
gap> IsMultiDigraph(loop);
false
gap> IsAcyclicDigraph(loop);
false

#
gap> r := rec( vertices := [ 1, 2 ], source := [ 1, 1 ], range := [ 2, 2 ] );;
gap> multiple := Digraph(r);
<multidigraph with 2 vertices, 2 edges>
gap> IsMultiDigraph(multiple);
true
gap> IsAcyclicDigraph(multiple);
true

#
gap> r:=rec( vertices := [ 1..100 ], source := [], range := []);;
gap> for i in [1..100] do
>   for j in [1..100] do
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

#
gap> r := rec( vertices := [1..20000], source := [], range := [] );;
gap> for i in [1..9999] do
>   Add(r.source, i);
>   Add(r.range, i+1);
> od;
> Add(r.source, 10000);; Add(r.range, 20000);;
> Add(r.source, 10002);; Add(r.range, 15000);;
> Add(r.source, 10001);; Add(r.range, 1);;
> for i in [ 10001..19999 ] do
>   Add(r.source, i);
>   Add(r.range, i+1);
> od;
gap> circuit := Digraph(r);
<digraph with 20000 vertices, 20001 edges>
gap> IsMultiDigraph(circuit);
false
gap> IsAcyclicDigraph(circuit);
true

#
gap> r:=rec( nrvertices := 8,
> source := [ 1, 1, 1, 2, 3, 4, 4, 5, 7, 7 ], 
> range := [ 4, 3, 4, 8, 2, 2, 6, 7, 4, 8 ] );;
gap> grid := Digraph(r);
<multidigraph with 8 vertices, 10 edges>
gap> IsMultiDigraph(grid);
true
gap> IsAcyclicDigraph(grid);
true

# IsFunctionalDigraph
gap> IsFunctionalDigraph(multiple);
false
gap> IsFunctionalDigraph(grid);
false
gap> IsFunctionalDigraph(circuit);
false
gap> IsFunctionalDigraph(loop);
true
gap> gr := Digraph( [ ] );
<digraph with 0 vertices, 0 edges>
gap> IsFunctionalDigraph(gr);
true

#
gap> r := rec( vertices := [ 1 .. 10 ], 
> source := 
> [ 1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5,
> 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 10, 10,
> 10, 10, 10, 10 ],
> range := 
> [ 6, 7, 6, 9, 1, 3, 4, 5, 8, 9, 1, 2, 3, 4, 5, 6, 7, 10, 1, 5, 6, 7, 10, 2, 
> 4, 5, 9, 10, 3, 4, 5, 6, 7, 8, 9, 10, 1, 3, 5, 7, 8, 9, 1, 2, 5, 1, 2,
> 4, 6, 7, 8 ] );;
gap> g1 := Digraph(r);
<digraph with 10 vertices, 51 edges>
gap> IsFunctionalDigraph(g1);
false

#
gap> g2 := Digraph(OutNeighbours(g1));
<digraph with 10 vertices, 51 edges>
gap> IsFunctionalDigraph(g2);
false

#
gap> g3 := Digraph( [ [1], [3], [2], [2] ] );
<digraph with 4 vertices, 4 edges>
gap> IsFunctionalDigraph(g3);
true

#
gap> g4 := Digraph( rec( vertices := [ 1 .. 3 ] ,
> source := [ 3, 2, 1 ], range := [ 2 , 1, 3 ] ) );
<digraph with 3 vertices, 3 edges>
gap> IsFunctionalDigraph(g4);
true

#
gap> g5 := Digraph( rec( vertices := [ 1 .. 3 ] ,
> source := [ 3, 2, 2 ], range := [ 2 , 1, 3 ] ) );
<digraph with 3 vertices, 3 edges>
gap> IsFunctionalDigraph(g5);
false

# IsSymmetricDigraph
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
gap> g6 := Digraph( [ [ 1, 2, 4 ], [ 1, 3 ], [ 2, 3, 4 ], [ 3, 1 ] ] );
<digraph with 4 vertices, 10 edges>
gap> IsSymmetricDigraph(g6);
true
gap> gr := Digraph(CayleyGraph(SymmetricGroup(6)));;
gap> IsSymmetricDigraph(gr);
true
gap> gr := Digraph( rec ( nrvertices := 3, source := [ 1, 1, 2, 2, 2, 2, 3, 3 ],
> range := [ 2, 2, 1, 1, 3, 3, 2, 2 ] ) );;
gap> IsSymmetricDigraph(gr);
true

# IsEmptyDigraph
gap> gr1 := Digraph( rec( nrvertices := 5, source := [ ], range := [ ] ) );;
gap> IsEmptyDigraph(gr1);
true
gap> gr2 := 
> Digraph( rec( vertices := [ 1 .. 6 ], source := [ 6 ], range := [ 1 ] ) );;
gap> IsEmptyDigraph(gr2);
false
gap> gr3 := Digraph( [ [ ], [ ], [ ], [ ] ] );;
gap> IsEmptyDigraph(gr3);
true
gap> gr4 := Digraph( [ [ ], [ 3 ], [ 1 ] ] );;
gap> IsEmptyDigraph(gr4);
false
gap> gr5 := DigraphByAdjacencyMatrix( [ [ 0, 0 ], [ 0, 0 ] ] );
<digraph with 2 vertices, 0 edges>
gap> IsEmptyDigraph(gr5);
true
gap> gr6 := DigraphByEdges( [ [ 3, 5 ], [ 1, 1 ], [ 2, 3 ], [ 5, 4 ] ] );
<digraph with 5 vertices, 4 edges>
gap> IsEmptyDigraph(gr6);
false

# IsTournament
gap> gr := Digraph( rec ( 
> nrvertices := 2, source := [ 1, 1 ], range := [ 2, 2 ] ) );
<multidigraph with 2 vertices, 2 edges>
gap> IsTournament(gr);
false
gap> gr := Digraph( [ [ 2 ], [ 1 ], [ 1, 2 ] ] );
<digraph with 3 vertices, 4 edges>
gap> IsTournament(gr);
false
gap> gr := Digraph( [ [ 2, 3 ], [ 3 ], [ ] ] );
<digraph with 3 vertices, 3 edges>
gap> IsAcyclicDigraph(gr);
true
gap> IsTournament(gr);
true
gap> gr := Digraph( [ [ 2 ], [ 3 ], [ 1 ] ] );
<digraph with 3 vertices, 3 edges>
gap> IsTournament(gr);
Error, Digraphs: IsTournament: not yet implemented,


# IsStronglyConnectedDigraph
gap> gr := Digraph( [ ] );
<digraph with 0 vertices, 0 edges>
gap> IsStronglyConnectedDigraph(gr);
true
gap> adj := [ [ 3, 4, 5, 7, 10 ], [ 4, 5, 10 ], [ 1, 2, 4, 7 ], [ 2, 9 ],
> [ 4, 5, 8, 9 ], [ 1, 3, 4, 5, 6 ], [ 1, 2, 4, 6 ],
> [ 1, 2, 3, 4, 5, 6, 7, 9 ], [ 2, 4, 8 ], [ 4, 5, 6, 8, 11 ], [ 10 ] ];;
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
gap> r := rec( nrvertices := 9, 
> range := [ 1, 7, 6, 9, 4, 8, 2, 5, 8, 9, 3, 9, 4, 8, 1, 1, 3 ], 
> source := [ 1, 1, 2, 2, 4, 4, 5, 6, 6, 6, 7, 7, 8, 8, 9, 9, 9 ] );;
gap> gr := Digraph(r);
<multidigraph with 9 vertices, 17 edges>
gap> IsStronglyConnectedDigraph(gr);
false

# IsReflexiveDigraph: using source and range
gap> r := rec( vertices := [ 1 .. 5 ],
> source := [ 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5 ],
> range  := [ 1, 2, 3, 1, 2, 5, 1, 3, 5, 2, 3, 4, 1, 2, 2 ]);;
gap> gr := Digraph(r);
<multidigraph with 5 vertices, 15 edges>
gap> IsReflexiveDigraph(gr);
false
gap> r := rec( nrvertices := 4,
> source := [ 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4 ],
> range  := [ 1, 2, 3, 1, 2, 2, 1, 2, 4, 1, 1, 4 ]);;
gap> gr := Digraph(r);
<multidigraph with 4 vertices, 12 edges>
gap> IsReflexiveDigraph(gr);
false
gap> r := rec( nrvertices := 5,
> source := [ 1, 1, 1, 2, 2, 3, 3, 3, 4, 5, 5, 5 ],
> range  := [ 1, 1, 3, 2, 5, 1, 3, 5, 4, 1, 5, 2 ]);;
gap> gr := Digraph(r);
<multidigraph with 5 vertices, 12 edges>
gap> IsReflexiveDigraph(gr);
true

# IsReflexiveDigraph: using OutNeighbours
gap> adj := [ [ 2, 1 ], [ 1, 3 ], [ ] ];;
gap> gr := Digraph(adj);
<digraph with 3 vertices, 4 edges>
gap> IsReflexiveDigraph(gr);
false
gap> adj := [ [ 4, 2, 3, 1 ], [ 2, 3 ], [ 1, 3 ], [ 4 ] ];;
gap> gr := Digraph(adj);
<digraph with 4 vertices, 9 edges>
gap> IsReflexiveDigraph(gr);
true

# IsReflexiveDigraph: using adjacency matrix
gap> mat := [ [ 2, 1, 0 ], [ 0, 1, 0 ], [ 0, 0, 0 ] ];;
gap> gr := DigraphByAdjacencyMatrix(mat);
<multidigraph with 3 vertices, 4 edges>
gap> IsReflexiveDigraph(gr);
false
gap> mat := [ [ 2, 0, 3, 1 ], [ 1, 1, 0, 2 ], [ 3, 0, 4, 0 ], [ 9, 1, 2, 1 ] ];;
gap> gr := DigraphByAdjacencyMatrix(mat);
<multidigraph with 4 vertices, 30 edges>
gap> IsReflexiveDigraph(gr);
true

# IsCompleteDigraph
gap> gr := Digraph( [ ] );
<digraph with 0 vertices, 0 edges>
gap> IsCompleteDigraph(gr);
true
gap> gr := Digraph( [ [ 1, 2 ], [ 2, 2 ] ] );
<multidigraph with 2 vertices, 4 edges>
gap> IsCompleteDigraph(gr);
false
gap> gr := Digraph( [ [ 1, 2 ], [ 2 ] ] );
<digraph with 2 vertices, 3 edges>
gap> IsCompleteDigraph(gr);
false
gap> gr := Digraph( [ [ 1, 2 ], [ 2, 1 ] ] );
<digraph with 2 vertices, 4 edges>
gap> IsCompleteDigraph(gr);
true

# IsConnectedDigraph
gap> gr := Digraph( [  ] );
<digraph with 0 vertices, 0 edges>
gap> IsConnectedDigraph(gr);
true
gap> gr := Digraph( [ [  ] ] );
<digraph with 1 vertex, 0 edges>
gap> IsConnectedDigraph(gr);
true
gap> gr := Digraph( [ [ 1 ] ] );
<digraph with 1 vertex, 1 edge>
gap> IsConnectedDigraph(gr);
true
gap> gr := Digraph( [ [ 1 ], [ 2 ] ] );
<digraph with 2 vertices, 2 edges>
gap> IsStronglyConnectedDigraph(gr);
false
gap> IsConnectedDigraph(gr);
Error, Digraphs: DigraphSymmetricClosure, not yet implemented,

gap> gr := Digraph( [ [ 2 ], [ 1 ] ] );
<digraph with 2 vertices, 2 edges>
gap> IsStronglyConnectedDigraph(gr);
true
gap> IsConnectedDigraph(gr);
true
gap> gr := Digraph( [ [ 2 ], [ 3 ], [  ], [  ] ] );
<digraph with 4 vertices, 2 edges>
gap> IsConnectedDigraph(gr);
false

# DigraphHasLoops (out neighbours)
gap> gr := Digraph( [ ] );
<digraph with 0 vertices, 0 edges>
gap> DigraphHasLoops(gr);
false
gap> gr := Digraph( [ [ ] ] );
<digraph with 1 vertex, 0 edges>
gap> DigraphHasLoops(gr);
false
gap> gr := Digraph( [ [ 1 ] ] );
<digraph with 1 vertex, 1 edge>
gap> DigraphHasLoops(gr);
true
gap> gr := Digraph( [ [ 6, 7 ], [ 6, 9 ], [ 1, 2, 4, 5, 8, 9 ],
> [ 1, 2, 3, 4, 5, 6, 7, 10 ], [ 1, 5, 6, 7, 10 ], [ 2, 4, 5, 9, 10 ],
> [ 3, 4, 5, 6, 7, 8, 9, 10 ], [ 1, 3, 5, 7, 8, 9 ], [ 1, 2, 5 ],
> [ 1, 2, 4, 6, 7, 8 ] ] );
<digraph with 10 vertices, 51 edges>
gap> DigraphHasLoops(gr);
true
gap> gr := Digraph( [ [ 6, 7 ], [ 6, 9 ], [ 1, 2, 4, 5, 8, 9 ],
> [ 1, 2, 3, 7, 5, 6, 7, 10 ], [ 1, 2, 2, 6, 7, 10 ], [ 2, 4, 5, 9, 10 ],
> [ 3, 4, 5, 6, 8, 8, 9, 10 ], [ 1, 1, 3, 5, 7, 6, 9 ], [ 1, 1, 1, 2, 5 ],
> [ 1, 2, 4, 6, 7, 8 ] ] );
<multidigraph with 10 vertices, 55 edges>
gap> DigraphHasLoops(gr);
false

# DigraphHasLoops (source and range)
gap> gr := Digraph( rec( nrvertices := 0, source := [  ], range := [  ] ) );
<digraph with 0 vertices, 0 edges>
gap> DigraphHasLoops(gr);
false
gap> gr := Digraph( rec( nrvertices := 1, source := [  ], range := [  ] ) );
<digraph with 1 vertex, 0 edges>
gap> DigraphHasLoops(gr);
false
gap> gr := Digraph( rec( nrvertices := 1, source := [ 1 ], range := [ 1 ] ) );
<digraph with 1 vertex, 1 edge>
gap> DigraphHasLoops(gr);
true
gap> r := rec( nrvertices := 10,
> source := [ 1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6,
>             6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 10, 10, 10, 10,
>             10, 10 ],
> range  := [ 6, 7, 6, 9, 1, 2, 4, 5, 8, 9, 1, 2, 3, 4, 5, 6, 7, 10, 1, 5, 6, 7, 10, 2,
>             4, 5, 9, 10, 3, 4, 5, 6, 7, 8, 9, 10, 1, 3, 5, 7, 8, 9, 1, 2, 5, 1, 2, 4,
>             6, 7, 8 ] );;
gap> gr := Digraph(r);
<digraph with 10 vertices, 51 edges>
gap> DigraphHasLoops(gr);
true
gap> r := rec( nrvertices := 10,
> source := [ 1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 6,
>             6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10,
>             10, 10, 10, 10, 10 ],
> range  := [ 6, 7, 6, 9, 1, 2, 4, 5, 8, 9, 1, 2, 3, 7, 5, 6, 7, 10, 1, 2, 2, 6, 7, 10,
>             2, 4, 5, 9, 10, 3, 4, 5, 6, 8, 8, 9, 10, 1, 1, 3, 5, 7, 6, 9, 1, 1, 1, 2,
>             5, 1, 2, 4, 6, 7, 8 ] );;
gap> gr := Digraph( r );
<multidigraph with 10 vertices, 55 edges>
gap> DigraphHasLoops(gr);
false

#
gap> DigraphsStopTest();

#
gap> STOP_TEST( "Digraphs package: prop.tst", 0);
