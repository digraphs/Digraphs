#%T##########################################################################
##
#W  attr.tst
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Graphs package: attr.tst");
gap> LoadPackage("graphs", false);;

#
gap> GraphsStartTest();

#T# DigraphSource and DigraphRange
gap> nbs := [ [ 12, 22, 17, 1, 10, 11 ], [ 23, 21, 21, 16 ], 
>  [ 15, 5, 22, 11, 12, 8, 10, 1 ], [ 21, 15, 23, 5, 23, 8, 24 ], 
>  [ 20, 17, 25, 25 ], [ 5, 24, 22, 5, 2 ], [ 11, 8, 19 ], 
>  [ 18, 20, 13, 3, 11 ], [ 15, 18, 12, 10 ], [ 8, 23, 15, 25, 8, 19, 17 ], 
>  [ 19, 2, 17, 21, 18 ], [ 9, 4, 7, 3 ], [ 14, 10, 2 ], [ 11, 24, 14 ], 
>  [ 2, 21 ], [ 12 ], [ 9, 2, 11, 9 ], [ 21, 24, 16, 8, 8 ], [ 3 ], [ 5, 6 ], 
>  [ 14, 2 ], [ 24, 24, 20 ], [ 19, 8, 20 ], [ 7, 1, 2, 15, 13, 9 ], 
>  [ 16, 12, 19 ] ];; 
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
gap> gr:= Digraph( [ [ 6, 7 ], [ 6, 9 ], [ 1, 3, 4, 5, 8, 9 ], 
> [ 1, 2, 3, 4, 5, 6, 7, 10 ], [ 1, 5, 6, 7, 10 ], [ 2, 4, 5, 9, 10 ], 
> [ 3, 4, 5, 6, 7, 8, 9, 10 ], [ 1, 3, 5, 7, 8, 9 ], [ 1, 2, 5 ], 
> [ 1, 2, 4, 6, 7, 8 ] ] );;
gap> OutNeighbours(DigraphDual(gr));
[ [ 1, 2, 3, 4, 5, 8, 9, 10 ], [ 1, 2, 3, 4, 5, 7, 8, 10 ], [ 2, 6, 7, 10 ], 
  [ 8, 9 ], [ 2, 3, 4, 8, 9 ], [ 1, 3, 6, 7, 8 ], [ 1, 2 ], [ 2, 4, 6, 10 ], 
  [ 3, 4, 6, 7, 8, 9, 10 ], [ 3, 5, 9, 10 ] ]
gap> gr := Digraph( rec( vertices := [ "a", "b" ], 
> source := [ "b", "b" ], range := [ "a", "a" ] ) );    
<multidigraph with 2 vertices, 2 edges>
gap> DigraphDual(gr);
Error, Graphs: DigraphDual: usage,
the argument <graph> must not have multiple edges,
gap> gr := Digraph( [ ] );                  
<digraph with 0 vertices, 0 edges>
gap> DigraphDual(gr);
<digraph with 0 vertices, 0 edges>
gap> gr := Digraph( [ [ ], [ ] ] );
<digraph with 2 vertices, 0 edges>
gap> DigraphDual(gr);
<digraph with 2 vertices, 4 edges>
gap> gr := Digraph( rec ( nrvertices := 2, source := [ ], range := [ ] ) );
<digraph with 2 vertices, 0 edges>
gap> DigraphDual(gr);
<digraph with 2 vertices, 4 edges>
gap> gr := Digraph( [ [ 2, 2 ], [  ] ] );
<multidigraph with 2 vertices, 2 edges>
gap> DigraphDual(gr);
Error, Graphs: DigraphDual: usage,
the argument <graph> must not have multiple edges,
gap> r := rec( nrvertices := 6,
> source := [ 2, 2, 2, 2, 2, 2, 4, 4, 4 ],
> range  := [ 1, 2, 3, 4, 5, 6, 3, 4, 5 ] );;
gap> gr := Digraph(r);
<digraph with 6 vertices, 9 edges>
gap> DigraphDual(gr);
<digraph with 6 vertices, 27 edges>
gap> r := rec( nrvertices := 4, source := [  ], range := [  ] );;
gap> gr := Digraph(r);
<digraph with 4 vertices, 0 edges>
gap> DigraphDual(gr);
<digraph with 4 vertices, 16 edges>
gap> gr := Digraph(r);;
gap> SetDigraphVertexLabels(gr, [ 4, 3, 2, 1 ] );
gap> gr2 := DigraphDual(gr);;
gap> DigraphVertexLabels(gr2);
[ 4, 3, 2, 1 ]

#T# AdjacencyMatrix
gap> gr:=Digraph( rec( nrvertices := 10, 
> source := [ 1, 1, 1, 1, 1, 1, 1, 1 ],
> range := [ 2, 2, 3, 3, 4, 4, 5, 5 ] ) );
<multidigraph with 10 vertices, 8 edges>
gap> AdjacencyMatrix(gr);
[ [ 0, 2, 2, 2, 2, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ]
gap> AdjacencyMatrix( Digraph( [ [ ] ] ) );
[ [ 0 ] ]
gap> AdjacencyMatrix( Digraph( [ ] ) );
[  ]
gap> r := rec( nrvertices := 7,
> source := [ 1, 1, 2, 2, 3, 4, 4, 5, 6, 7, 7 ],
> range  := [ 3, 4, 2, 4, 6, 6, 7, 2, 7, 5, 5 ] );;
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
gap> r := rec( nrvertices := 1, source := [ 1, 1 ], range := [ 1, 1 ] );;
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
gap> AdjacencyMatrix(Digraph( [ ] ));
[  ]
gap> AdjacencyMatrix( 
> Digraph( rec( nrvertices := 0, source := [ ], range := [ ] ) ) );
[  ]

#T# DigraphTopologicalSort
gap> r := rec( nrvertices := 20000, source := [  ], range := [  ] );;
gap> for i in [ 1 .. 9999 ] do
>   Add(r.source, i);
>   Add(r.range, i+1);
> od;
> Add(r.source, 10000);; Add(r.range, 20000);;
> Add(r.source, 10001);; Add(r.range, 1);;
> for i in [ 10001 .. 19999 ] do
>   Add(r.source, i);
>   Add(r.range, i+1);
> od;
gap> circuit := Digraph(r);
<digraph with 20000 vertices, 20000 edges>
gap> topo := DigraphTopologicalSort( circuit );;
gap> Length(topo);
20000
gap> topo[ 1 ] = 20000;
true
gap> topo[ 20000 ] = 10001;
true
gap> topo[ 12345 ];
17656
gap> gr := Digraph( [ [ 2 ], [ 1 ] ] );
<digraph with 2 vertices, 2 edges>
gap> DigraphTopologicalSort(gr);
fail
gap> r := rec( nrvertices := 2, source := [ 1, 1 ], range := [ 2, 2 ] );;
gap> multiple := Digraph(r);;
gap> DigraphTopologicalSort(multiple);
[ 2, 1 ]
gap> gr := Digraph( [  ] );
<digraph with 0 vertices, 0 edges>
gap> DigraphTopologicalSort(gr);
[  ]
gap> gr := Digraph([ [  ] ]);
<digraph with 1 vertex, 0 edges>
gap> DigraphTopologicalSort(gr);
[ 1 ]
gap> gr := Digraph([ [ 1 ] ]);
<digraph with 1 vertex, 1 edge>
gap> DigraphTopologicalSort(gr);
[ 1 ]
gap> gr := Digraph([ [ 2 ], [ 1 ] ]);
<digraph with 2 vertices, 2 edges>
gap> DigraphTopologicalSort(gr);
fail
gap> r:=rec( nrvertices := 8,
> source := [ 1, 1, 1, 2, 3, 4, 4, 5, 7, 7 ], 
> range := [ 4, 3, 4, 8, 2, 2, 6, 7, 4, 8 ] );;
gap> grid := Digraph(r);;
gap> DigraphTopologicalSort(grid);
[ 8, 2, 6, 4, 3, 1, 7, 5 ]
gap> adj := [ [ 3 ], [ ], [ 2, 3, 4 ], [ ] ];;
gap> gr := Digraph(adj);
<digraph with 4 vertices, 4 edges>
gap> IsAcyclicDigraph(gr);
false
gap> DigraphTopologicalSort(gr);
[ 2, 4, 3, 1 ]
gap> gr := Digraph([
> [ 7 ], [  ], [  ], [ 6 ], [  ], [ 3 ], [  ], [  ], [ 5, 15 ], [  ], [  ], 
> [ 6 ], [ 19 ], [  ], [ 11 ], [ 13 ], [  ], [ 17 ], [  ], [ 17 ] ]);
<digraph with 20 vertices, 11 edges>
gap> DigraphTopologicalSort(gr);
[ 7, 1, 2, 3, 6, 4, 5, 8, 11, 15, 9, 10, 12, 19, 13, 14, 16, 17, 18, 20 ]
gap> gr := Digraph( [ [ 2 ], [ ], [ ] ] );
<digraph with 3 vertices, 1 edge>
gap> DigraphTopologicalSort(gr);
[ 2, 1, 3 ]

#T# DigraphStronglyConnectedComponents
gap> gens := [ Transformation( [ 1, 3, 3 ] ), Transformation( [ 2, 1, 2 ] ), 
> Transformation( [ 2, 2, 1 ] ) ];;
gap> s := Semigroup(gens);
<transformation semigroup on 3 pts with 3 generators>
gap> gr := Digraph(RightCayleyGraphSemigroup(s));
<multidigraph with 15 vertices, 45 edges>
gap> DigraphStronglyConnectedComponents(gr);
rec( 
  comps := [ [ 1, 11, 15 ], [ 2, 3, 10, 14 ], [ 4, 6, 9, 13 ], 
      [ 5, 7, 8, 12 ] ], id := [ 1, 2, 2, 3, 4, 3, 4, 4, 3, 2, 1, 4, 3, 2, 1 
     ] )
gap> adj := [ [ 3, 4, 5, 7, 10 ], [ 4, 5, 10 ], [ 1, 2, 4, 7 ], [ 2, 9 ],
> [ 4, 5, 8, 9 ], [ 1, 3, 4, 5, 6 ], [ 1, 2, 4, 6 ],
> [ 1, 2, 3, 4, 5, 6, 7, 9 ], [ 2, 4, 8 ], [ 4, 5, 6, 8, 11 ], [ 10 ] ];;
gap> gr := Digraph(adj);
<digraph with 11 vertices, 44 edges>
gap> scc := DigraphStronglyConnectedComponents(gr);
rec( comps := [ [ 1, 3, 2, 4, 9, 8, 5, 6, 7, 10, 11 ] ], 
  id := [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ] )
gap> gr := Digraph( [ ] );
<digraph with 0 vertices, 0 edges>
gap> DigraphStronglyConnectedComponents(gr);
rec( comps := [  ], id := [  ] )
gap> r := rec( nrvertices := 9, 
> range := [ 1, 7, 6, 9, 4, 8, 2, 5, 8, 9, 3, 9, 4, 8, 1, 1, 3 ], 
> source := [ 1, 1, 2, 2, 4, 4, 5, 6, 6, 6, 7, 7, 8, 8, 9, 9, 9 ] );
rec( nrvertices := 9, 
  range := [ 1, 7, 6, 9, 4, 8, 2, 5, 8, 9, 3, 9, 4, 8, 1, 1, 3 ], 
  source := [ 1, 1, 2, 2, 4, 4, 5, 6, 6, 6, 7, 7, 8, 8, 9, 9, 9 ] )
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
gap> gr2 := DigraphRemoveEdges( gr, [ 10 ] );
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
gap> gr := Digraph( [ [ 1, 2 ], [ 1 ], [ 2 ], [ 5 ], [ ] ] );
<digraph with 5 vertices, 5 edges>
gap> wcc := DigraphConnectedComponents(gr);
rec( comps := [ [ 1, 2, 3 ], [ 4, 5 ] ], id := [ 1, 1, 1, 2, 2 ] )
gap> gr := Digraph( [  ] );
<digraph with 0 vertices, 0 edges>
gap> DigraphConnectedComponents(gr);
rec( comps := [  ], id := [  ] )
gap> gr := Digraph( [ [ ] ] );
<digraph with 1 vertex, 0 edges>
gap> DigraphConnectedComponents(gr);
rec( comps := [ [ 1 ] ], id := [ 1 ] )
gap> gr := Digraph( [ [ 1 ], [ 2 ], [ 3 ], [ 4 ] ] );
<digraph with 4 vertices, 4 edges>
gap> DigraphConnectedComponents(gr);
rec( comps := [ [ 1 ], [ 2 ], [ 3 ], [ 4 ] ], id := [ 1, 2, 3, 4 ] )
gap> gr := Digraph( [ [ 3, 4, 5, 7, 8, 9 ], [ 1, 4, 5, 8, 9, 5, 10 ],
> [ 2, 4, 5, 6, 7, 10 ], [ 6 ], [ 1, 1, 1, 7, 8, 9 ], [ 2, 2, 6, 8 ], [ 1, 5, 6, 9, 10 ],
> [ 3, 4, 6, 7 ], [ 1, 2, 3, 5 ], [ 5, 7 ] ] );
<multidigraph with 10 vertices, 45 edges>
gap> DigraphConnectedComponents(gr);
rec( comps := [ [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] ], 
  id := [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ] )
gap> gr := Digraph( rec(
> nrvertices := 100,
> source := [ 8, 9, 11, 11, 12, 13, 14, 14, 18, 19, 22, 27, 31, 32, 32, 34,
>             37, 40, 45, 48, 50, 52, 58, 58, 58, 59, 60, 60, 65, 66, 73,
>             75, 79, 81, 81, 83, 84, 86, 86, 89, 96, 100, 100, 100 ],
> range := [ 54, 62, 28, 55, 70, 37, 20, 32, 53, 16, 42, 66, 63, 13, 73, 89,
>            36, 5, 4, 58, 26, 48, 36, 56, 65, 78, 95, 96, 97, 60, 11, 66, 
>            66, 19, 79, 21, 13, 29, 78, 98, 100, 44, 53, 69 ] ) );
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
gap> adj := Concatenation(List( [ 1 .. 11 ], x -> [ x + 1 ] ), [ [ 1 ] ]);;
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
gap> DigraphShortestDistances( Digraph( [ ] ) );
[  ]
gap> mat := DigraphShortestDistances( Digraph( [ [ ], [ ] ] ) );
[ [ 0, -1 ], [ -1, 0 ] ]
gap> r:=rec( vertices := [ 1 .. 15 ], source := [ ], range := [ ] );;
gap> for i in [ 1 .. 15 ] do
>   for j in [ 1 .. 15 ] do
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
gap> r := rec( nrvertices := 7, range := [ 3, 5, 5, 4, 6, 2, 5, 3, 3, 7, 2 ], 
>  source := [ 1, 1, 1, 2, 2, 3, 3, 4, 5, 5, 7 ] );
rec( nrvertices := 7, range := [ 3, 5, 5, 4, 6, 2, 5, 3, 3, 7, 2 ], 
  source := [ 1, 1, 1, 2, 2, 3, 3, 4, 5, 5, 7 ] )
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
gap> gr := Digraph( rec( nrvertices := 10, source := [ 1, 1, 5, 5, 7, 10 ],
> range := [ 3, 3, 1, 10, 7, 1 ] ) );
<multidigraph with 10 vertices, 6 edges>
gap> InNeighbours(gr);
[ [ 5, 10 ], [  ], [ 1, 1 ], [  ], [  ], [  ], [ 7 ], [  ], [  ], [ 5 ] ]
gap> OutNeighbours(gr);
[ [ 3, 3 ], [  ], [  ], [  ], [ 1, 10 ], [  ], [ 7 ], [  ], [  ], [ 1 ] ]
gap> gr := Digraph([[1,1,4],[2,3,4],[2,4,4,4],[2]]);
<multidigraph with 4 vertices, 11 edges>
gap> InNeighbours(gr);
[ [ 1, 1 ], [ 2, 3, 4 ], [ 2 ], [ 1, 2, 3, 3, 3 ] ]
gap> OutNeighbours(gr);
[ [ 1, 1, 4 ], [ 2, 3, 4 ], [ 2, 4, 4, 4 ], [ 2 ] ]

#T# OutDegrees, OutDegreeSequence, InDegrees, InDegreeSequence
gap> r := rec( nrvertices := 0, source := [ ], range := [ ] );;
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
gap> gr2 := Digraph( [ ] );
<digraph with 0 vertices, 0 edges>
gap> OutDegrees(gr2);
[  ]
gap> OutDegreeSequence(gr2);
[  ]
gap> InDegrees(gr2);
[  ]
gap> InDegreeSequence(gr2);
[  ]
gap> gr3 := Digraph( [ ] );
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
gap> adj :=  [
> [ 6, 7, 1 ], [ 1, 3, 3, 6 ], [ 5 ], [ 1, 4, 4, 4, 8 ], [ 1, 3, 4, 6, 7 ],
> [ 7, 7 ], [ 1, 4, 5, 6, 5, 7 ], [ 5, 6 ] ];;
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
gap> r := rec ( nrvertices := 8,
> source := [ 1, 1, 1, 2, 2, 2, 2, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6, 7, 7,
>             7, 7, 7, 7, 8, 8 ],
> range := [ 6, 7, 1, 1, 3, 3, 6, 5, 1, 4, 4, 4, 8, 1, 3, 4, 6, 7, 7, 7, 1, 4, 
>            5, 6, 5, 7, 5, 6 ] );;
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
gap> r := rec ( 
> nrvertices := 5,
> source := [ 1, 1, 2, 3, 5, 5 ],
> range := [ 1, 4, 3, 5, 2, 2 ] );
rec( nrvertices := 5, range := [ 1, 4, 3, 5, 2, 2 ], 
  source := [ 1, 1, 2, 3, 5, 5 ] )
gap> gr := Digraph(r);
<multidigraph with 5 vertices, 6 edges>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 4 ], [ 2, 3 ], [ 3, 5 ], [ 5, 2 ], [ 5, 2 ] ]
gap> gr := Digraph( [ [ 4 ], [ 2, 3, 1, 3 ], [ 3, 3 ], [  ], [ 1, 4, 5 ] ] );
<multidigraph with 5 vertices, 10 edges>
gap> DigraphEdges(gr);
[ [ 1, 4 ], [ 2, 2 ], [ 2, 3 ], [ 2, 1 ], [ 2, 3 ], [ 3, 3 ], [ 3, 3 ], 
  [ 5, 1 ], [ 5, 4 ], [ 5, 5 ] ]
gap> gr := Digraph( [ [ 1, 2, 3, 5, 6, 8 ], [ 6, 6, 7, 8 ], [ 1, 2, 3, 4, 6, 7 ], 
> [ 2, 3, 5, 6, 2, 7 ], [ 5, 6, 5, 5 ], [ 3, 2, 8 ], [ 1, 5, 7 ], [ 6, 7 ] ] );
<multidigraph with 8 vertices, 34 edges>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ], [ 1, 5 ], [ 1, 6 ], [ 1, 8 ], [ 2, 6 ], 
  [ 2, 6 ], [ 2, 7 ], [ 2, 8 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ], [ 3, 4 ], 
  [ 3, 6 ], [ 3, 7 ], [ 4, 2 ], [ 4, 3 ], [ 4, 5 ], [ 4, 6 ], [ 4, 2 ], 
  [ 4, 7 ], [ 5, 5 ], [ 5, 6 ], [ 5, 5 ], [ 5, 5 ], [ 6, 3 ], [ 6, 2 ], 
  [ 6, 8 ], [ 7, 1 ], [ 7, 5 ], [ 7, 7 ], [ 8, 6 ], [ 8, 7 ] ]

#T# DigraphSources and DigraphSinks
gap> r := rec( nrvertices := 10,
> source := [ 2, 2, 3, 3, 3, 5, 7, 7, 7, 7, 9, 9, 9, 9, 9 ],
> range  := [ 2, 2, 6, 8, 2, 4, 2, 6, 8, 6, 8, 5, 8, 2, 4 ] );;
gap> gr := Digraph(r);
<multidigraph with 10 vertices, 15 edges>
gap> DigraphSinks(gr);
[ 1, 4, 6, 8, 10 ]
gap> DigraphSources(gr);
[ 1, 3, 7, 9, 10 ]
gap> gr := Digraph( OutNeighbours(gr) );;
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
gap> gr := Digraph( [ [ 2, 2 ], [ 3 ], [ 4 ], [ 1 ] ] );
<multidigraph with 4 vertices, 5 edges>
gap> DigraphPeriod(gr);
4
gap> gr := Digraph( [ [ 2 ], [ 3 ], [ 4 ], [ ] ] );
<digraph with 4 vertices, 3 edges>
gap> HasIsAcyclicDigraph(gr);
false
gap> DigraphPeriod(gr);
0
gap> HasIsAcyclicDigraph(gr);
true
gap> IsAcyclicDigraph(gr);
true
gap> gr := Digraph( [ [ 2 ], [ 3 ], [ 4 ], [ ] ] );
<digraph with 4 vertices, 3 edges>
gap> IsAcyclicDigraph(gr);
true
gap> DigraphPeriod(gr);
0

#T# DigraphDiameter
gap> gr := Digraph( [ [ 2 ], [  ] ] );;
gap> DigraphDiameter(gr);
-1
gap> gr := Digraph( [ [ 2 ], [ 3 ], [ 4, 5 ], [ 5 ] , [ 1 ] ] );;
gap> DigraphDiameter(gr);
4
gap> gr := Digraph( [ [ 1, 2 ], [ 1 ] ] );;
gap> DigraphDiameter(gr);
1
gap> gr := Digraph( [ [ 2 ], [ 3 ], [  ] ] );;
gap> IsStronglyConnectedDigraph(gr);
false
gap> DigraphDiameter(gr);
-1
gap> gr := Digraph( [ [ 1 ] ] );;
gap> DigraphDiameter(gr);
0
gap> gr := EmptyDigraph(0);;
gap> DigraphDiameter(gr);
-1
gap> gr := EmptyDigraph(1);;
gap> DigraphDiameter(gr);
0

#E#
gap> STOP_TEST( "Graphs package: attr.tst");
