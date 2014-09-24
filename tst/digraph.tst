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
gap> loop:=DirectedGraph([ [1] ]);
<directed graph with 1 vertices, 1 edges>
gap> IsSimpleDirectedGraph(loop);
true
gap> IsAcyclicDirectedGraph(loop);
false

#
gap> r:=rec(vertices:=[1,2],source:=[1,1],range:=[2,2]);;
gap> multiple:=DirectedGraph(r);
<directed graph with 2 vertices, 2 edges>
gap> IsSimpleDirectedGraph(multiple);
false
gap> IsAcyclicDirectedGraph(multiple);
true

#
gap> r:=rec(vertices:=[1..100],source:=[],range:=[]);;
gap> for i in [1..100] do
>   for j in [1..100] do
>     Add(r.source, i);
>     Add(r.range, j);
>   od;
> od;
gap> complete:=DirectedGraph(r);
<directed graph with 100 vertices, 10000 edges>
gap> IsSimpleDirectedGraph(complete);
true
gap> IsAcyclicDirectedGraph(complete);
false

#
gap> r:=rec(vertices:=[1..20000],source:=[],range:=[]);;
gap> for i in [1..9999] do
>   Add(r.source, i);
>   Add(r.range, i+1);
> od;
> Add(r.source, 10001);; Add(r.range, 1);;
> Add(r.source, 10000);; Add(r.range, 20000);;
> for i in [10001..19999] do
>   Add(r.source, i);
>   Add(r.range, i+1);
> od;
gap> circuit:=DirectedGraph(r);
<directed graph with 20000 vertices, 20000 edges>
gap> IsSimpleDirectedGraph(circuit);
true
gap> IsAcyclicDirectedGraph(circuit);
true

#
gap> r:=rec(
> vertices:=[1..8],source:=[1,1,1,2,3,4,4,5,7,7],range:=[4,3,4,8,2,2,6,7,4,8]);;
gap> grid:=DirectedGraph(r);
<directed graph with 8 vertices, 10 edges>
gap> IsSimpleDirectedGraph(grid);
false
gap> IsAcyclicDirectedGraph(grid);
true

# DirectedGraphTopologicalSort
gap> topo:=DirectedGraphTopologicalSort(circuit);;
gap> Length(topo);
20000
gap> topo[1]=20000;
true
gap> topo[20000]=10001;
true
gap> topo[12345];
17656

#
gap> DirectedGraphTopologicalSort(multiple);
[ 2, 1 ]

#
gap> DirectedGraphTopologicalSort(grid);
[ 8, 2, 3, 6, 4, 1, 7, 5 ]

#
gap> DigraphsStopTest();

#
gap> STOP_TEST( "Digraphs package: digraph.tst", 0);
