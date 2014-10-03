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
<directed graph with 1 vertices, 1 edges>
gap> IsSimpleDigraph(loop);
true
gap> IsAcyclicDigraph(loop);
false

#
gap> r:=rec(vertices:=[1,2],source:=[1,1],range:=[2,2]);;
gap> multiple:=Digraph(r);
<directed graph with 2 vertices, 2 edges>
gap> IsSimpleDigraph(multiple);
false
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
<directed graph with 100 vertices, 10000 edges>
gap> IsSimpleDigraph(complete);
true
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
<directed graph with 20000 vertices, 20000 edges>
gap> IsSimpleDigraph(circuit);
true
gap> IsAcyclicDigraph(circuit);
true

#
gap> r:=rec(
> vertices:=[1..8],source:=[1,1,1,2,3,4,4,5,7,7],range:=[4,3,4,8,2,2,6,7,4,8]);;
gap> grid:=Digraph(r);
<directed graph with 8 vertices, 10 edges>
gap> IsSimpleDigraph(grid);
false
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
<directed graph with 2 vertices, 2 edges>
gap> DigraphTopologicalSort(gr);
fail

#
gap> DigraphTopologicalSort(multiple);
[ 2, 1 ]
gap> gr := Digraph([]);
<directed graph with 0 vertices, 0 edges>
gap> DigraphTopologicalSort(gr);
[  ]
gap> gr := Digraph([ [ ] ]);
<directed graph with 1 vertices, 0 edges>
gap> DigraphTopologicalSort(gr);
[ 1 ]
gap> gr := Digraph([ [ 1 ] ]);
<directed graph with 1 vertices, 1 edges>
gap> DigraphTopologicalSort(gr);
[ 1 ]
gap> gr := Digraph([ [ 2 ], [ 1 ] ]);
<directed graph with 2 vertices, 2 edges>
gap> DigraphTopologicalSort(gr);
fail
gap> adj := [ [ 3 ], [ ], [ 2, 3, 4 ], [ ] ];;
gap> gr := Digraph(adj);
<directed graph with 4 vertices, 4 edges>
gap> IsAcyclicDigraph(gr);
false
gap> DigraphTopologicalSort(gr);
[ 2, 4, 3, 1 ]

#
gap> DigraphTopologicalSort(grid);
[ 8, 2, 3, 6, 4, 1, 7, 5 ]

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
<directed graph with 10 vertices, 51 edges>
gap> IsFunctionalDigraph(g1);
false
gap> g2 := Digraph(Adjacencies(g1));
<directed graph with 10 vertices, 51 edges>
gap> IsFunctionalDigraph(g2);
false
gap> g3 := Digraph( [ [1], [3], [2], [2] ] );
<directed graph with 4 vertices, 4 edges>
gap> IsFunctionalDigraph(g3);
true
gap> g4 := Digraph( rec( vertices := [ 1 .. 3 ] ,
> source := [ 3, 2, 1 ], range := [ 2 , 1, 3 ] ) );
<directed graph with 3 vertices, 3 edges>
gap> IsFunctionalDigraph(g4);
true
gap> g5 := Digraph( rec( vertices := [ 1 .. 3 ] ,
> source := [ 3, 2, 2 ], range := [ 2 , 1, 3 ] ) );
<directed graph with 3 vertices, 3 edges>
gap> IsFunctionalDigraph(g5);
false

# IsUndirectedGraph
gap> IsUndirectedGraph(g1);
false
gap> IsUndirectedGraph(g2);
false
gap> IsUndirectedGraph(g3);
false
gap> IsUndirectedGraph(g4);
false
gap> IsUndirectedGraph(g5);
false
gap> IsUndirectedGraph(loop);
true
gap> IsUndirectedGraph(multiple);
false
gap> g6 := Digraph( [ [ 1, 2, 4 ], [ 1, 3 ], [ 2, 3, 4 ], [ 3, 1 ] ] );
<directed graph with 4 vertices, 10 edges>
gap> IsUndirectedGraph(g6);
true

# DigraphByEdges
gap> gr := Digraph( [ [ 1, 2, 3, 5 ], [ 1, 5 ], [ 2, 3, 6 ], [ 1, 3, 4 ], 
> [ 1, 4, 6 ], [ 3, 4 ] ] );
<directed graph with 6 vertices, 17 edges>
gap> gr = DigraphByEdges(Edges(gr));
true
gap> DigraphByEdges([["nonsense", "more"]]);
Error, usage: the argument <edges> must be a list of pairs of pos ints,
gap> DigraphByEdges([["nonsense"]]);
Error, usage: the argument <edges> must be a list of pairs,
gap> gr := DigraphByEdges(Edges(gr), 10);
<directed graph with 10 vertices, 17 edges>
gap> gr := DigraphByEdges( [ [ 1, 2 ] ] );
<directed graph with 2 vertices, 1 edges>
gap> gr := DigraphByEdges( [ [ 2, 1 ] ] );
<directed graph with 2 vertices, 1 edges>
gap> gr := DigraphByEdges( [ [ 1, 2 ] ], 1 ); 
Error, DigraphByEdges: usage, the specified edges must not contain value\
s greater than 1

# AsDigraph
gap> f := Transformation([]);
IdentityTransformation
gap> gr := AsDigraph(f);
<directed graph with 0 vertices, 0 edges>
gap> gr = Digraph( [] );
true
gap> AsDigraph(f, 10);
<directed graph with 10 vertices, 10 edges>
gap> g := Transformation( [ 2, 6, 7, 2, 6, 1, 1, 5 ] );
Transformation( [ 2, 6, 7, 2, 6, 1, 1, 5 ] )
gap> AsDigraph(g);
<directed graph with 8 vertices, 8 edges>
gap> AsDigraph(g, 10);
<directed graph with 10 vertices, 10 edges>
gap> h := Transformation( [ 2, 4, 1, 3, 5 ] );
Transformation( [ 2, 4, 1, 3 ] )
gap> AsDigraph(h);
<directed graph with 4 vertices, 4 edges>

# IsSimpleDigraph
gap> gr1 := Digraph( [ ] );
<directed graph with 0 vertices, 0 edges>
gap> IsSimpleDigraph(gr);
true
gap> gr2 := Digraph( [ [] ] );
<directed graph with 1 vertices, 0 edges>
gap> IsSimpleDigraph(gr);
true
gap> source := [1..10000];;
gap> range := List( source, x->Random(source) );;
gap> r := rec(vertices := [ 1 .. 10000 ], source := source, range := range);;
gap> gr3 := Digraph(r);
<directed graph with 10000 vertices, 10000 edges>
gap> IsSimpleDigraph(g3);
true
gap> Add(source, 10000);;
gap> Add(range, range[10000]);;
gap> r := rec(vertices := [ 1 .. 10000 ], source := source, range := range);;
gap> gr4 := Digraph(r);
<directed graph with 10000 vertices, 10001 edges>
gap> IsSimpleDigraph(gr4);
false

# DigraphTransitiveClosure & DigraphReflexiveTransitiveClosure
gap> r := rec( vertices:=[ 1 .. 4 ], source := [ 1, 1, 2, 3, 4 ], 
> range := [ 1, 2, 3, 4, 1 ] );
rec( range := [ 1, 2, 3, 4, 1 ], source := [ 1, 1, 2, 3, 4 ], 
  vertices := [ 1 .. 4 ] )
gap> gr := Digraph(r);
<directed graph with 4 vertices, 5 edges>
gap> IsAcyclicDigraph(gr);
false
gap> DigraphTopologicalSort(gr);
fail
gap> gr1 := DigraphTransitiveClosure(gr);
<directed graph with 4 vertices, 13 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr);
<directed graph with 4 vertices, 16 edges>
gap> adj := [ [ 2, 6 ], [ 3 ], [ 7 ], [ 3 ], [  ], [ 2, 7 ], [ 5 ] ];;
gap> gr := Digraph(adj);
<directed graph with 7 vertices, 8 edges>
gap> IsAcyclicDigraph(gr);
true
gap> gr1 := DigraphTransitiveClosure(gr);
<directed graph with 7 vertices, 18 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr);
<directed graph with 7 vertices, 25 edges>

#
gap> DigraphsStopTest();

#
gap> STOP_TEST( "Digraphs package: digraph.tst", 0);
