#############################################################################
##
#W  digraph.tst
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: digraph.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DigraphsStartTest();

# IsAcyclicDigraph
gap> loop:=Digraph([ [1] ]);
<digraph with 1 vertices, 1 edges>
gap> IsMultiDigraph(loop);
false
gap> IsAcyclicDigraph(loop);
false

#
gap> r:=rec(vertices:=[1,2],source:=[1,1],range:=[2,2]);;
gap> multiple:=Digraph(r);
<multidigraph with 2 vertices, 2 edges>
gap> IsMultiDigraph(multiple);
true
gap> IsAcyclicDigraph(multiple);
true

#
gap> r:=rec(vertices:=[1..100],source:=[],range:=[]);;
gap> for i in [1..100] do
>   for j in [1..100] do
>     Add(r.source, i);
>     Add(r.range, j);
>   od;
> od;
gap> complete:=Digraph(r);
<digraph with 100 vertices, 10000 edges>
gap> IsMultiDigraph(complete);
false
gap> IsAcyclicDigraph(complete);
false

#
gap> r:=rec(vertices:=[1..20000],source:=[],range:=[]);;
gap> for i in [1..9999] do
>   Add(r.source, i);
>   Add(r.range, i+1);
> od;
> Add(r.source, 10000);; Add(r.range, 20000);;
> Add(r.source, 10001);; Add(r.range, 1);;
> for i in [10001..19999] do
>   Add(r.source, i);
>   Add(r.range, i+1);
> od;
gap> circuit:=Digraph(r);
<digraph with 20000 vertices, 20000 edges>
gap> IsMultiDigraph(circuit);
false
gap> IsAcyclicDigraph(circuit);
true

#
gap> r:=rec(
> vertices:=[1..8],source:=[1,1,1,2,3,4,4,5,7,7],range:=[4,3,4,8,2,2,6,7,4,8]);;
gap> grid:=Digraph(r);
<multidigraph with 8 vertices, 10 edges>
gap> IsMultiDigraph(grid);
true
gap> IsAcyclicDigraph(grid);
true

# DigraphTopologicalSort
gap> topo:=DigraphTopologicalSort(circuit);;
gap> Length(topo);
20000
gap> topo[1]=20000;
true
gap> topo[20000]=10001;
true
gap> topo[12345];
17656
gap> gr := Digraph( [ [ 2 ], [ 1 ] ] );
<digraph with 2 vertices, 2 edges>
gap> DigraphTopologicalSort(gr);
fail

#
gap> DigraphTopologicalSort(multiple);
[ 2, 1 ]
gap> gr := Digraph([]);
<digraph with 0 vertices, 0 edges>
gap> DigraphTopologicalSort(gr);
[  ]
gap> gr := Digraph([ [ ] ]);
<digraph with 1 vertices, 0 edges>
gap> DigraphTopologicalSort(gr);
[ 1 ]
gap> gr := Digraph([ [ 1 ] ]);
<digraph with 1 vertices, 1 edges>
gap> DigraphTopologicalSort(gr);
[ 1 ]
gap> gr := Digraph([ [ 2 ], [ 1 ] ]);
<digraph with 2 vertices, 2 edges>
gap> DigraphTopologicalSort(gr);
fail
gap> adj := [ [ 3 ], [ ], [ 2, 3, 4 ], [ ] ];;
gap> gr := Digraph(adj);
<digraph with 4 vertices, 4 edges>
gap> IsAcyclicDigraph(gr);
false
gap> DigraphTopologicalSort(gr);
[ 2, 4, 3, 1 ]

#
gap> DigraphTopologicalSort(grid);
[ 8, 2, 6, 4, 3, 1, 7, 5 ]

# IsFunctionalDigraph
gap> IsFunctionalDigraph(multiple);
false
gap> IsFunctionalDigraph(grid);
false
gap> IsFunctionalDigraph(circuit);
false
gap> IsFunctionalDigraph(loop);
true
gap> r := rec( vertices := [ 1 .. 10 ],
> source := [ 1, 1, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5,
> 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 10, 10,
> 10, 10, 10, 10 ],
> range := [ 6, 7, 6, 9, 1, 3, 4, 5, 8, 9, 1, 2, 3, 4, 5, 6, 7, 10, 1, 5, 6, 7,
> 10, 2, 4, 5, 9, 10, 3, 4, 5, 6, 7, 8, 9, 10, 1, 3, 5, 7, 8, 9, 1, 2, 5, 1, 2,
> 4, 6, 7, 8 ] );;
gap> g1 := Digraph(r);
<digraph with 10 vertices, 51 edges>
gap> IsFunctionalDigraph(g1);
false
gap> g2 := Digraph(OutNeighbours(g1));
<digraph with 10 vertices, 51 edges>
gap> IsFunctionalDigraph(g2);
false
gap> g3 := Digraph( [ [1], [3], [2], [2] ] );
<digraph with 4 vertices, 4 edges>
gap> IsFunctionalDigraph(g3);
true
gap> g4 := Digraph( rec( vertices := [ 1 .. 3 ] ,
> source := [ 3, 2, 1 ], range := [ 2 , 1, 3 ] ) );
<digraph with 3 vertices, 3 edges>
gap> IsFunctionalDigraph(g4);
true
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
Error, Digraphs: IsSymmetricDigraph: usage,
the argument <graph> cannot have multiple edges,
gap> g6 := Digraph( [ [ 1, 2, 4 ], [ 1, 3 ], [ 2, 3, 4 ], [ 3, 1 ] ] );
<digraph with 4 vertices, 10 edges>
gap> IsSymmetricDigraph(g6);
true
gap> gr:=Digraph(CayleyGraph(SymmetricGroup(6)));;
gap> IsSymmetricDigraph(gr);
true

# DigraphByEdges
gap> gr := Digraph( [ [ 1, 2, 3, 5 ], [ 1, 5 ], [ 2, 3, 6 ], [ 1, 3, 4 ], 
> [ 1, 4, 6 ], [ 3, 4 ] ] );
<digraph with 6 vertices, 17 edges>
gap> gr = DigraphByEdges(DigraphEdges(gr));
true
gap> DigraphByEdges([["nonsense", "more"]]);
Error, Digraphs: DigraphByEdges: usage,
the argument <edges> must be a list of pairs of pos ints,

gap> DigraphByEdges([["nonsense"]]);
Error, Digraphs: DigraphByEdges: usage,
the argument <edges> must be a list of pairs,

gap> gr := DigraphByEdges(DigraphEdges(gr), 10);
<digraph with 10 vertices, 17 edges>
gap> gr := DigraphByEdges( [ [ 1, 2 ] ] );
<digraph with 2 vertices, 1 edges>
gap> gr := DigraphByEdges( [ [ 2, 1 ] ] );
<digraph with 2 vertices, 1 edges>
gap> gr := DigraphByEdges( [ [ 1, 2 ] ], 1 ); 
Error, Digraphs: DigraphByEdges: usage,
the specified edges must not contain values greater than 1,


# AsDigraph
gap> f := Transformation([]);
IdentityTransformation
gap> gr := AsDigraph(f);
<digraph with 0 vertices, 0 edges>
gap> gr = Digraph( [] );
true
gap> AsDigraph(f, 10);
<digraph with 10 vertices, 10 edges>
gap> g := Transformation( [ 2, 6, 7, 2, 6, 1, 1, 5 ] );
Transformation( [ 2, 6, 7, 2, 6, 1, 1, 5 ] )
gap> AsDigraph(g);
<digraph with 8 vertices, 8 edges>
gap> AsDigraph(g, 10);
<digraph with 10 vertices, 10 edges>
gap> h := Transformation( [ 2, 4, 1, 3, 5 ] );
Transformation( [ 2, 4, 1, 3 ] )
gap> AsDigraph(h);
<digraph with 4 vertices, 4 edges>

# IsMultiDigraph
gap> gr1 := Digraph( [ ] );
<digraph with 0 vertices, 0 edges>
gap> IsMultiDigraph(gr);
false
gap> gr2 := Digraph( [ [] ] );
<digraph with 1 vertices, 0 edges>
gap> IsMultiDigraph(gr);
false
gap> source := [1..10000];;
gap> range := List( source, x->Random(source) );;
gap> r := rec(vertices := [ 1 .. 10000 ], source := source, range := range);;
gap> gr3 := Digraph(r);
<digraph with 10000 vertices, 10000 edges>
gap> IsMultiDigraph(g3);
false
gap> Add(source, 10000);;
gap> Add(range, range[10000]);;
gap> r := rec(vertices := [ 1 .. 10000 ], source := source, range := range);;
gap> gr4 := Digraph(r);
<multidigraph with 10000 vertices, 10001 edges>
gap> IsMultiDigraph(gr4);
true

# DigraphTransitiveClosure & DigraphReflexiveTransitiveClosure
gap> r := rec( vertices:=[ 1 .. 4 ], source := [ 1, 1, 2, 3, 4 ], 
> range := [ 1, 2, 3, 4, 1 ] );
rec( range := [ 1, 2, 3, 4, 1 ], source := [ 1, 1, 2, 3, 4 ], 
  vertices := [ 1 .. 4 ] )
gap> gr := Digraph(r);
<digraph with 4 vertices, 5 edges>
gap> IsAcyclicDigraph(gr);
false
gap> DigraphTopologicalSort(gr);
fail
gap> gr1 := DigraphTransitiveClosure(gr);
<digraph with 4 vertices, 13 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr);
<digraph with 4 vertices, 16 edges>
gap> adj := [ [ 2, 6 ], [ 3 ], [ 7 ], [ 3 ], [  ], [ 2, 7 ], [ 5 ] ];;
gap> gr := Digraph(adj);
<digraph with 7 vertices, 8 edges>
gap> IsAcyclicDigraph(gr);
true
gap> gr1 := DigraphTransitiveClosure(gr);
<digraph with 7 vertices, 18 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr);
<digraph with 7 vertices, 25 edges>

# DigraphByAdjacencyMatrix
gap> mat := [
> [ 0, 2, 0, 0, 1 ],
> [ 0, 2, 1, 0, 1 ],
> [ 0, 0, 0, 0, 1 ],
> [ 1, 0, 1, 1, 0 ],
> [ 0, 0, 3, 0, 0 ] ];;
gap> gr := DigraphByAdjacencyMatrix(mat);
<multidigraph with 5 vertices, 14 edges>
gap> grnc := DigraphByAdjacencyMatrixNC(mat);
<multidigraph with 5 vertices, 14 edges>
gap> gr = grnc;
true
gap> IsStronglyConnectedDigraph(gr);
false
gap> IsMultiDigraph(gr);
true
gap> OutNeighbours(gr);
[ [ 2, 2, 5 ], [ 2, 2, 3, 5 ], [ 5 ], [ 1, 3, 4 ], [ 3, 3, 3 ] ]
gap> OutNeighbours(grnc) = last;
true
gap> mat := [
> [ 0, 0, 0, 9, 1, 0, 0, 1, 0, 0 ],
> [ 0, 1, 0, 1, 1, 1, 0, 1, 1, 0 ],
> [ 0, 1, 0, 1, 2, 0, 1, 0, 0, 3 ],
> [ 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 ],
> [ 1, 0, 0, 1, 0, 1, 1, 0, 1, 0 ],
> [ 0, 1, 1, 0, 0, 5, 1, 0, 0, 1 ],
> [ 0, 0, 1, 2, 1, 0, 0, 1, 1, 0 ],
> [ 0, 0, 1, 1, 0, 0, 0, 2, 1, 1 ],
> [ 1, 2, 3, 0, 1, 1, 0, 0, 1, 1 ],
> [ 0, 1, 3, 4, 1, 1, 0, 0, 1, 0 ] ];;
gap> gr := DigraphByAdjacencyMatrix(mat);
<multidigraph with 10 vertices, 73 edges>
gap> IsMultiDigraph(gr);
true
gap> OutNeighbours(gr);
[ [ 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 8 ], [ 2, 4, 5, 6, 8, 9 ], 
  [ 2, 4, 5, 5, 7, 10, 10, 10 ], [ 9 ], [ 1, 4, 6, 7, 9 ], 
  [ 2, 3, 6, 6, 6, 6, 6, 7, 10 ], [ 3, 4, 4, 5, 8, 9 ], [ 3, 4, 8, 8, 9, 10 ],
  [ 1, 2, 2, 3, 3, 3, 5, 6, 9, 10 ], [ 2, 3, 3, 3, 4, 4, 4, 4, 5, 6, 9 ] ]
gap> r := rec( nrvertices:= 10, source := ShallowCopy(DigraphSource(gr)),
> range := ShallowCopy(DigraphRange(gr)) );;
gap> gr2 := Digraph(r);
<multidigraph with 10 vertices, 73 edges>
gap> HasAdjacencyMatrix(gr2);
false
gap> AdjacencyMatrix(gr2) = mat;
true
gap> DigraphByAdjacencyMatrix( [ ] );
<digraph with 0 vertices, 0 edges>

# Display
gap> gr := Digraph( [ [ 1, 2 ], [ 2 ], [ ] ] );
<digraph with 3 vertices, 3 edges>
gap> PrintString(gr);
"Digraph( [ [ 1, 2 ], [ 2 ], [ ] ] )"
gap> String(gr);
"Digraph( [ [ 1, 2 ], [ 2 ], [ ] ] )"

#
gap> DigraphsStopTest();

#
gap> STOP_TEST( "Digraphs package: digraph.tst", 0);
