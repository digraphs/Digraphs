#############################################################################
##
#W  attrs.tst
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: attrs.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DigraphsStartTest();

# DigraphDual
gap> gr:= Digraph( [ [ 6, 7 ], [ 6, 9 ], [ 1, 3, 4, 5, 8, 9 ], 
> [ 1, 2, 3, 4, 5, 6, 7, 10 ], [ 1, 5, 6, 7, 10 ], [ 2, 4, 5, 9, 10 ], 
> [ 3, 4, 5, 6, 7, 8, 9, 10 ], [ 1, 3, 5, 7, 8, 9 ], [ 1, 2, 5 ], 
> [ 1, 2, 4, 6, 7, 8 ] ] );;
gap> OutNeighbours(DigraphDual(gr));
[ [ 1, 2, 3, 4, 5, 8, 9, 10 ], [ 1, 2, 3, 4, 5, 7, 8, 10 ], [ 2, 6, 7, 10 ], 
  [ 8, 9 ], [ 2, 3, 4, 8, 9 ], [ 1, 3, 6, 7, 8 ], [ 1, 2 ], [ 2, 4, 6, 10 ], 
  [ 3, 4, 6, 7, 8, 9, 10 ], [ 3, 5, 9, 10 ] ]
gap> gr := Digraph( rec( vertices := [ "a", "b" ], 
> source := ["b", "b"], range := ["a", "a"] ) );    
<multidigraph with 2 vertices, 2 edges>
gap> DigraphDual(gr);
Error, Digraphs: DigraphDual: usage,
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
Error, Digraphs: DigraphDual: usage,
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

# AdjacencyMatrix
gap> gr:=Digraph(rec(vertices:=[1..10], 
> source:=[1,1,1,1,1,1,1,1], range:=[2,2,3,3,4,4,5,5]));
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

# AdjacencyMatrix, testing before and after getting IsSimple and OutNeighbours
# (with a simple digraph)
gap> r:=rec(vertices:=[1..7],
> source:=[1,1,2,2,3,4,4,5,6,7],
> range:=[3,4,2,4,6,6,7,2,7,5]);
rec( range := [ 3, 4, 2, 4, 6, 6, 7, 2, 7, 5 ], 
  source := [ 1, 1, 2, 2, 3, 4, 4, 5, 6, 7 ], vertices := [ 1 .. 7 ] )
gap> gr := Digraph(r);
<digraph with 7 vertices, 10 edges>
gap> adj1 := AdjacencyMatrix(gr);
[ [ 0, 0, 1, 1, 0, 0, 0 ], [ 0, 1, 0, 1, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 1, 0 ], 
  [ 0, 0, 0, 0, 0, 1, 1 ], [ 0, 1, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 1 ], 
  [ 0, 0, 0, 0, 1, 0, 0 ] ]
gap> gr := Digraph(r);
<digraph with 7 vertices, 10 edges>
gap> IsMultiDigraph(gr);
false
gap> OutNeighbours(gr);
[ [ 3, 4 ], [ 2, 4 ], [ 6 ], [ 6, 7 ], [ 2 ], [ 7 ], [ 5 ] ]
gap> adj2 := AdjacencyMatrix(gr);
[ [ 0, 0, 1, 1, 0, 0, 0 ], [ 0, 1, 0, 1, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 1, 0 ], 
  [ 0, 0, 0, 0, 0, 1, 1 ], [ 0, 1, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 1 ], 
  [ 0, 0, 0, 0, 1, 0, 0 ] ]
gap> adj1 = adj2;
true

# AdjacencyMatrix, testing before and after getting IsSimple and OutNeighbours
# (with a not simple digraph)
gap> r:=rec(vertices:=[1..1], source:=[1,1], range:=[1,1]);
rec( range := [ 1, 1 ], source := [ 1, 1 ], vertices := [ 1 ] )
gap> gr := Digraph(r);
<multidigraph with 1 vertex, 2 edges>
gap> adj1 := AdjacencyMatrix(gr);
[ [ 2 ] ]
gap> gr := Digraph(r);
<multidigraph with 1 vertex, 2 edges>
gap> IsMultiDigraph(gr);
true
gap> adj2 := AdjacencyMatrix(gr);
[ [ 2 ] ]
gap> adj1 = adj2;
true

# DigraphTopologicalSort: standard example
gap> r := rec( vertices := [1..20000], source := [], range := [] );;
gap> for i in [1..9999] do
>   Add(r.source, i);
>   Add(r.range, i+1);
> od;
> Add(r.source, 10000);; Add(r.range, 20000);;
> Add(r.source, 10001);; Add(r.range, 1);;
> for i in [ 10001..19999 ] do
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

# DigraphTopologicalSort: testing almost trivial cases
gap> r := rec( vertices := [ 1, 2 ], source := [ 1, 1 ], range := [ 2, 2 ] );;
gap> multiple := Digraph(r);;
gap> DigraphTopologicalSort(multiple);
[ 2, 1 ]
gap> gr := Digraph( [] );
<digraph with 0 vertices, 0 edges>
gap> DigraphTopologicalSort(gr);
[  ]
gap> gr := Digraph([ [ ] ]);
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

# DigraphTopologicalSort: other small cases
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

# DigraphStronglyConnectedComponents
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

# DigraphStronglyConnectedComponents: weakly connected, 4 strong components
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

# DigraphStronglyConnectedComponents: weakly conn., 20000 singletonstrong comps
gap> scc := DigraphStronglyConnectedComponents(circuit);;
gap> Length(scc.comps);
20000
gap> Length(scc.comps) = DigraphNrVertices(circuit);
true

# DigraphConnectedComponents
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

# DigraphShortestDistances
gap> adj := Concatenation(List( [ 1 .. 11 ], x -> [ x + 1 ] ), [ [ 1 ] ]);;
gap> cycle12 := Digraph(adj);
<digraph with 12 vertices, 12 edges>
gap> mat := DigraphShortestDistances(cycle12);;
gap> Display(mat);
[ [  12,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11 ],
  [  11,  12,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10 ],
  [  10,  11,  12,   1,   2,   3,   4,   5,   6,   7,   8,   9 ],
  [   9,  10,  11,  12,   1,   2,   3,   4,   5,   6,   7,   8 ],
  [   8,   9,  10,  11,  12,   1,   2,   3,   4,   5,   6,   7 ],
  [   7,   8,   9,  10,  11,  12,   1,   2,   3,   4,   5,   6 ],
  [   6,   7,   8,   9,  10,  11,  12,   1,   2,   3,   4,   5 ],
  [   5,   6,   7,   8,   9,  10,  11,  12,   1,   2,   3,   4 ],
  [   4,   5,   6,   7,   8,   9,  10,  11,  12,   1,   2,   3 ],
  [   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,   1,   2 ],
  [   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,   1 ],
  [   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12 ] ]
gap> DigraphShortestDistances( Digraph( [ ] ) );
[  ]
gap> mat := DigraphShortestDistances( Digraph( [ [ ], [ ] ] ) );
[ [ -1, -1 ], [ -1, -1 ] ]
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
[ [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ],
  [  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 ] ]
gap> r := rec( nrvertices := 7, range := [ 3, 5, 5, 4, 6, 2, 5, 3, 3, 7, 2 ], 
>  source := [ 1, 1, 1, 2, 2, 3, 3, 4, 5, 5, 7 ] );
rec( nrvertices := 7, range := [ 3, 5, 5, 4, 6, 2, 5, 3, 3, 7, 2 ], 
  source := [ 1, 1, 1, 2, 2, 3, 3, 4, 5, 5, 7 ] )
gap> gr := Digraph(r);
<multidigraph with 7 vertices, 11 edges>
gap> Display(DigraphShortestDistances(gr));         
[ [  -1,   2,   1,   3,   1,   3,   2 ],
  [  -1,   3,   2,   1,   3,   1,   4 ],
  [  -1,   1,   2,   2,   1,   2,   2 ],
  [  -1,   2,   1,   3,   2,   3,   3 ],
  [  -1,   2,   1,   3,   2,   3,   1 ],
  [  -1,  -1,  -1,  -1,  -1,  -1,  -1 ],
  [  -1,   1,   3,   2,   4,   2,   5 ] ]

#
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

# OutDegrees & OutDegreeSequence; InDegrees & InDegreeSequence (Trivial cases)
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

# OutDegrees & OutDegreeSequence; InDegrees & InDegreeSequence
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

# DigraphEdges
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

#
gap> DigraphsStopTest();

#
gap> STOP_TEST( "Digraphs package: attrs.tst", 0);
