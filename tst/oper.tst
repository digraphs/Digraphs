#%T##########################################################################
##
#W  oper.tst
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: oper.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DigraphsStartTest();

#T# DigraphReverse
gap> gr := Digraph(
> [ [ 3 ], [ 1, 3, 5 ], [ 1 ], [ 1, 2, 4 ], [ 2, 3, 5 ] ]);
<digraph with 5 vertices, 11 edges>
gap> rgr := DigraphReverse(gr);
<digraph with 5 vertices, 11 edges>
gap> OutNeighbours(rgr);
[ [ 2, 3, 4 ], [ 4, 5 ], [ 1, 2, 5 ], [ 4 ], [ 2, 5 ] ]
gap> gr = DigraphReverse(rgr);
true
gap> gr := Digraph( rec ( nrvertices := 5,
> source := [ 1, 1, 2, 2, 2, 2, 2, 3, 4, 4, 4, 5, 5, 5 ],
> range  := [ 1, 3, 1, 2, 2, 4, 5, 4, 1, 3, 5, 1, 1, 3 ] ) );
<multidigraph with 5 vertices, 14 edges>
gap> e := DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 3 ], [ 2, 1 ], [ 2, 2 ], [ 2, 2 ], [ 2, 4 ], [ 2, 5 ], 
  [ 3, 4 ], [ 4, 1 ], [ 4, 3 ], [ 4, 5 ], [ 5, 1 ], [ 5, 1 ], [ 5, 3 ] ]
gap> rev := DigraphReverse(gr);
<multidigraph with 5 vertices, 14 edges>
gap> erev := DigraphEdges(rev);;
gap> temp := List( erev, x -> [ x[2], x[1] ] );;
gap> Sort(temp);
gap> e = temp;
true

#T# Digraph(Reflexive)TransitiveClosure
gap> gr := Digraph( 
> rec( nrvertices := 2, source := [ 1, 1 ], range := [ 2, 2 ] ) );
<multidigraph with 2 vertices, 2 edges>
gap> DigraphReflexiveTransitiveClosure(gr);
Error, Graphs: DigraphReflexiveTransitiveClosure: usage,
the argument <graph> cannot have multiple edges,
gap> DigraphTransitiveClosure(gr);
Error, Graphs: DigraphTransitiveClosure: usage,
the argument <graph> cannot have multiple edges,
gap> r := rec( vertices := [ 1 .. 4 ], source := [ 1, 1, 2, 3, 4 ], 
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
<digraph with 4 vertices, 16 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr);
<digraph with 4 vertices, 16 edges>
gap> gr1 = gr2;
true
gap> adj := [ [ 2, 6 ], [ 3 ], [ 7 ], [ 3 ], [  ], [ 2, 7 ], [ 5 ] ];;
gap> gr := Digraph(adj);
<digraph with 7 vertices, 8 edges>
gap> IsAcyclicDigraph(gr);
true
gap> gr1 := DigraphTransitiveClosure(gr);
<digraph with 7 vertices, 18 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr);
<digraph with 7 vertices, 25 edges>
gap> gr := Digraph( [ [ 2 ], [ 3 ], [ 4 ], [ 3 ] ] );
<digraph with 4 vertices, 4 edges>
gap> gr1 := DigraphTransitiveClosure(gr);
<digraph with 4 vertices, 9 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr);
<digraph with 4 vertices, 11 edges>
gap> gr := Digraph( [ [ 2 ], [ 3 ], [ 4, 5 ], [  ], [ 5 ] ] ); 
<digraph with 5 vertices, 5 edges>
gap> gr1 := DigraphTransitiveClosure(gr);
<digraph with 5 vertices, 10 edges>
gap> gr2 := DigraphReflexiveTransitiveClosure(gr);
<digraph with 5 vertices, 14 edges>
gap> gr := Digraph(
> [ [ 1, 4, 5, 6, 7, 8 ], [ 5, 7, 8, 9, 10, 13 ], [ 2, 4, 6, 10 ], 
>   [ 7, 9, 10, 11 ], [ 7, 9, 10, 12, 13, 15 ], [ 7, 8, 10, 13 ], [ 10, 11 ], 
>   [ 7, 10, 12, 13, 14, 15, 16 ], [ 7, 10, 11, 14, 16 ], [ 11 ], [ 11 ], 
>   [ 7, 13, 14 ], [ 10, 11 ], [ 7, 10, 11 ], [ 7, 13, 16 ], [ 7, 10, 11 ] ] );
<digraph with 16 vertices, 60 edges>
gap> trans1 := DigraphTransitiveClosure(gr);
<digraph with 16 vertices, 98 edges>
gap> trans2 := DigraphByAdjacencyMatrix(DIGRAPH_TRANS_CLOSURE(gr));
<digraph with 16 vertices, 98 edges>
gap> trans1 = trans2;
true
gap> trans := Digraph(OutNeighbours(trans1));
<digraph with 16 vertices, 98 edges>
gap> IsReflexiveDigraph(trans);
false
gap> IsTransitiveDigraph(trans);
true
gap> IS_TRANSITIVE_DIGRAPH(trans);
true
gap> reflextrans1 := DigraphReflexiveTransitiveClosure(gr);
<digraph with 16 vertices, 112 edges>
gap> reflextrans2 :=DigraphByAdjacencyMatrix(DIGRAPH_REFLEX_TRANS_CLOSURE(gr));
<digraph with 16 vertices, 112 edges>
gap> reflextrans1 = reflextrans2;
true
gap> reflextrans := Digraph(OutNeighbours(reflextrans1));
<digraph with 16 vertices, 112 edges>
gap> IsReflexiveDigraph(reflextrans);
true
gap> IsTransitiveDigraph(reflextrans);
true
gap> IS_TRANSITIVE_DIGRAPH(reflextrans);
true

#T# DigraphRemoveLoops
gap> adj := [ [ 1, 2 ], [ 3, 2 ], [ 1, 2 ], [ 4 ],  [ ], [ 1, 2, 3, 6 ] ];
[ [ 1, 2 ], [ 3, 2 ], [ 1, 2 ], [ 4 ], [  ], [ 1, 2, 3, 6 ] ]
gap> gr := Digraph(adj);
<digraph with 6 vertices, 11 edges>
gap> DigraphRemoveLoops(gr);
<digraph with 6 vertices, 7 edges>
gap> source := [ 1, 1, 2, 2, 3, 3, 4, 6, 6, 6, 6 ];;
gap> range  := [ 1, 2, 3, 2, 1, 2, 4, 1, 2, 3, 6 ];;
gap> gr := Digraph( 
> rec ( nrvertices := 6, source := source, range := range ) );
<digraph with 6 vertices, 11 edges>
gap> HasDigraphHasLoops(gr);
false
gap> DigraphHasLoops(gr);
true
gap> gr1 := DigraphRemoveLoops(gr);
<digraph with 6 vertices, 7 edges>
gap> HasDigraphHasLoops(gr1);
true
gap> DigraphHasLoops(gr1);
false

#T# DigraphRemoveEdges (by index)
gap> gr := RandomDigraph(10);;
gap> DigraphRemoveEdges(gr, [ Group(()) ]);
Error, Graphs: DigraphRemoveEdges: usage,
the second argument <edges> must be a list of indices of edges
or a list of edges of the first argument <digraph>,
gap> gr := Digraph( [ [ 2 ], [  ] ] );
<digraph with 2 vertices, 1 edge>
gap> DigraphRemoveEdges( gr, [ 1 ] );
<digraph with 2 vertices, 0 edges>
gap> r := rec( nrvertices := 5,
> source := [ 1, 1, 1, 2, 2, 3, 4, 5, 5, 5 ],
> range  := [ 1, 2, 2, 1, 3, 5, 3, 5, 5, 3 ] );;
gap> gr := Digraph(r);
<multidigraph with 5 vertices, 10 edges>
gap> gr1 := DigraphRemoveEdges(gr, [ 2, 4, 5, 6 ] );
<multidigraph with 5 vertices, 6 edges>
gap> DigraphSource(gr1);
[ 1, 1, 4, 5, 5, 5 ]
gap> DigraphRange(gr1);
[ 1, 2, 3, 5, 5, 3 ]
gap> DigraphRemoveEdges(gr1, [  ]);
<multidigraph with 5 vertices, 6 edges>
gap> last = gr1;
true

#T# DigraphRemoveEdges (by list of edges)
gap> gr := Digraph( [ [ 2 ], [  ] ] );
<digraph with 2 vertices, 1 edge>
gap> DigraphRemoveEdges( gr, [ [ 2, 1 ] ] );
<digraph with 2 vertices, 1 edge>
gap> last = gr;
true
gap> DigraphRemoveEdges( gr, [ [ 1, 2 ] ] );
<digraph with 2 vertices, 0 edges>
gap> gr := Digraph( [ [ 1, 2, 4 ], [ 1, 4 ], [ 3, 4 ], [ 1, 4, 5 ], [ 1, 5 ] ] );
<digraph with 5 vertices, 12 edges>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 2 ], [ 1, 4 ], [ 2, 1 ], [ 2, 4 ], [ 3, 3 ], [ 3, 4 ], 
  [ 4, 1 ], [ 4, 4 ], [ 4, 5 ], [ 5, 1 ], [ 5, 5 ] ]
gap> gr1 := DigraphRemoveEdges( gr, [ [ 1, 4 ], [ 4, 5 ], [ 5, 5 ] ] );
<digraph with 5 vertices, 9 edges>
gap> DigraphEdges(gr1);
[ [ 1, 1 ], [ 1, 2 ], [ 2, 1 ], [ 2, 4 ], [ 3, 3 ], [ 3, 4 ], [ 4, 1 ], 
  [ 4, 4 ], [ 5, 1 ] ]
gap> gr := Digraph( [ [ 2, 2 ], [  ] ] );
<multidigraph with 2 vertices, 2 edges>
gap> DigraphRemoveEdges(gr, [ [ 1, 2 ] ] );
Error, Graphs: DigraphRemoveEdges: usage,
the first argument <digraph> must not have multiple edges
when the second argument <edges> is a list of edges,

#T# DigraphRemoveEdge (by index)
gap> gr := Digraph( [ [ 2, 3 ], [ 1 ], [ 3 ] ] );
<digraph with 3 vertices, 4 edges>
gap> DigraphRemoveEdge(gr, 0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphRemoveEdge' on 2 arguments
gap> DigraphRemoveEdge(gr, 5);
Error, Graphs, DigraphRemoveEdge, usage,
the second argument <edge> must be the index of an edge in <digraph>,
gap> gr := DigraphRemoveEdge(gr, 3);
<digraph with 3 vertices, 3 edges>
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 1, 3 ], [ 3, 3 ] ]

#T# DigraphRemoveEdge (by a specific edge)
gap> gr := Digraph( [ [ 1, 1 ] ] );
<multidigraph with 1 vertex, 2 edges>
gap> DigraphRemoveEdge(gr, [ 1, 1 ] );
Error, Graphs: DigraphRemoveEdge: usage,
the first argument <digraph> must not have multiple edges
when the second argument <edges> is a pair of vertices,
gap> gr := Digraph( [ [ 2 ], [ 1 ] ] );
<digraph with 2 vertices, 2 edges>
gap> DigraphRemoveEdge( gr, [ 1, 1, 1 ] );
Error, Graphs: DigraphRemoveEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> DigraphRemoveEdge( gr, [ Group(()), Group(()) ] );
Error, Graphs: DigraphRemoveEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> DigraphRemoveEdge( gr, [ 1, Group(()) ] );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphRemoveEdge' on 2 arguments
gap> DigraphRemoveEdge( gr, [ 3, 1 ] );
Error, Graphs: DigraphRemoveEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> DigraphRemoveEdge( gr, [ 1, 3 ] );
Error, Graphs: DigraphRemoveEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> gr := DigraphRemoveEdge( gr, [ 2, 1 ] );
<digraph with 2 vertices, 1 edge>
gap> DigraphEdges(gr);
[ [ 1, 2 ] ]

#T# OnDigraphs (for a digraph and a perm)
gap> gr := Digraph( [ [ 2 ], [ 1 ], [ 3 ] ] );
<digraph with 3 vertices, 3 edges>
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 2, 1 ], [ 3, 3 ] ]
gap> g := (1, 2, 3);
(1,2,3)
gap> OnDigraphs(gr, g);
<digraph with 3 vertices, 3 edges>
gap> DigraphEdges(last);
[ [ 1, 1 ], [ 2, 3 ], [ 3, 2 ] ]
gap> h := (1, 2, 3, 4);
(1,2,3,4)
gap> OnDigraphs(gr, h);
Error, Graphs: OnDigraphs: usage,
the 2nd argument <perm> must permute the vertices of the 1st argument <graph>,
gap> gr := Digraph( [ [ 1, 1, 1, 3, 5 ], [ ], [ 3, 2, 4, 5 ], [ 2, 5 ], [ 1, 2, 1 ] ] );
<multidigraph with 5 vertices, 14 edges>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 1 ], [ 1, 1 ], [ 1, 3 ], [ 1, 5 ], [ 3, 3 ], [ 3, 2 ], 
  [ 3, 4 ], [ 3, 5 ], [ 4, 2 ], [ 4, 5 ], [ 5, 1 ], [ 5, 2 ], [ 5, 1 ] ]
gap> p1 := (2,4)(3,6,5);
(2,4)(3,6,5)
gap> OnDigraphs(gr, p1);
Error, Graphs: OnDigraphs: usage,
the 2nd argument <perm> must permute the vertices of the 1st argument <graph>,
gap> p2 := (1,3,4,2);
(1,3,4,2)
gap> OnDigraphs(gr, p2);
<multidigraph with 5 vertices, 14 edges>
gap> DigraphEdges(last);
[ [ 2, 1 ], [ 2, 5 ], [ 3, 3 ], [ 3, 3 ], [ 3, 3 ], [ 3, 4 ], [ 3, 5 ], 
  [ 4, 4 ], [ 4, 1 ], [ 4, 2 ], [ 4, 5 ], [ 5, 3 ], [ 5, 1 ], [ 5, 3 ] ]
gap> r := rec ( nrvertices := 4,
> source := [ 1, 1, 2, 2, 2, 3, 4, 4 ],
> range  := [ 2, 3, 1, 4, 4, 3, 3, 1 ] );;
gap> gr := Digraph(r);
<multidigraph with 4 vertices, 8 edges>
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 1, 3 ], [ 2, 1 ], [ 2, 4 ], [ 2, 4 ], [ 3, 3 ], [ 4, 3 ], 
  [ 4, 1 ] ]
gap> p1 := (1,5,4,2,3);
(1,5,4,2,3)
gap> OnDigraphs(gr, p1);
Error, Graphs: OnDigraphs: usage,
the 2nd argument <perm> must permute the vertices of the 1st argument <graph>,
gap> p2 := (1,4)(2,3);
(1,4)(2,3)
gap> OnDigraphs(gr, p2);
<multidigraph with 4 vertices, 8 edges>
gap> DigraphEdges(last);
[ [ 1, 2 ], [ 1, 4 ], [ 2, 2 ], [ 3, 4 ], [ 3, 1 ], [ 3, 1 ], [ 4, 3 ], 
  [ 4, 2 ] ]

#T# OnDigraphs (for a digraph and a transformation)
gap> gr := Digraph( [ [ 2 ], [ 1, 3 ], [  ] ] );
<digraph with 3 vertices, 3 edges>
gap> OutNeighbours(gr);
[ [ 2 ], [ 1, 3 ], [  ] ]
gap> t := Transformation([ 4, 2, 3, 4 ]);;
gap> OnDigraphs(gr, t);
Error, Graphs: OnDigraphs: usage,
the 2nd argument <trans> must transform the vertices of the 1st argument
<digraph>,
gap> t := Transformation([ 1, 2, 1 ]);;
gap> gr := OnDigraphs(gr, t);
<multidigraph with 2 vertices, 3 edges>
gap> OutNeighbours(gr);
[ [ 2 ], [ 1, 1 ] ]

#T# InNeighboursOfVertex, InDegreeOfVertex
gap> gr := Digraph( rec( nrvertices := 10, source := [ 1, 1, 5, 5, 7, 10 ],
> range := [ 3, 3, 1, 10, 7, 1 ] ) );
<multidigraph with 10 vertices, 6 edges>
gap> InNeighborsOfVertex(gr, 7);
[ 7 ]
gap> InNeighboursOfVertex(gr, 7);
[ 7 ]
gap> InDegreeOfVertex(gr, 7);
1
gap> InNeighboursOfVertex(gr, 11);
Error, Graphs: InNeighboursOfVertex: usage,
the second argument <v> is not a vertex of the first, <digraph>,
gap> InDegreeOfVertex(gr, 11);
Error, Graphs: InDegreeOfVertex: usage,
the second argument <v> is not a vertex of the first, <digraph>,
gap> gr := Digraph( [ [ 1, 1, 4 ], [ 2, 3, 4 ], [ 2, 4, 4, 4 ], [ 2 ] ] );
<multidigraph with 4 vertices, 11 edges>
gap> InNeighboursOfVertex(gr, 3);
[ 2 ]
gap> InDegreeOfVertex(gr, 3);
1
gap> InNeighbours(gr);
[ [ 1, 1 ], [ 2, 3, 4 ], [ 2 ], [ 1, 2, 3, 3, 3 ] ]
gap> InNeighboursOfVertex(gr, 4);
[ 1, 2, 3, 3, 3 ]
gap> InDegreeOfVertex(gr, 4);
5
gap> InDegrees(gr);
[ 2, 3, 1, 5 ]
gap> InDegreeOfVertex(gr, 2);
3

#T# OutNeighboursOfVertex, OutDegreeOfVertex
gap> gr := Digraph( rec( nrvertices := 10, source := [ 1, 5, 5, 5, 5, 5, 5, 6 ],
> range := [ 1, 1, 2, 3, 1, 2, 3, 6 ] ) );
<multidigraph with 10 vertices, 8 edges>
gap> OutNeighborsOfVertex(gr, 2);
[  ]
gap> OutNeighboursOfVertex(gr, 2);
[  ]
gap> OutDegreeOfVertex(gr, 2);
0
gap> OutNeighboursOfVertex(gr, 5);
[ 1, 2, 3, 1, 2, 3 ]
gap> OutDegreeOfVertex(gr, 5);
6
gap> OutNeighboursOfVertex(gr, 12);
Error, Graphs: OutNeighboursOfVertex: usage,
the second argument <v> is not a vertex of the first, <digraph>,
gap> OutDegreeOfVertex(gr, 12);
Error, Graphs: OutDegreeOfVertex: usage,
the second argument <v> is not a vertex of the first, <digraph>,
gap> gr := Digraph( [ [ 2, 2, 2, 2 ], [ 2, 2 ] ] );
<multidigraph with 2 vertices, 6 edges>
gap> OutNeighboursOfVertex(gr, 2);
[ 2, 2 ]
gap> OutDegreeOfVertex(gr, 2);
2
gap> OutDegrees(gr);
[ 4, 2 ]
gap> OutDegreeOfVertex(gr, 1);
4

#T# InducedSubdigraph
gap> r := rec( nrvertices := 8,
> source := [ 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 5, 5, 5, 5, 5, 5 ],
> range  := [ 1, 1, 2, 3, 3, 4, 1, 1, 3, 4, 5, 1, 3, 4, 4, 5, 7 ] );
rec( nrvertices := 8, 
  range := [ 1, 1, 2, 3, 3, 4, 1, 1, 3, 4, 5, 1, 3, 4, 4, 5, 7 ], 
  source := [ 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 5, 5, 5, 5, 5, 5 ] )
gap> gr := Digraph(r);
<multidigraph with 8 vertices, 17 edges>
gap> InducedSubdigraph( gr, [ -1 ] );
Error, Graphs: InducedSubdigraph: usage,
the second argument <subverts> must be a duplicate-free subset
of the vertices of the first argument <digraph>,
gap> InducedSubdigraph( gr, [ 1 .. 9 ] );
Error, Graphs: InducedSubdigraph: usage,
the second argument <subverts> must be a duplicate-free subset
of the vertices of the first argument <digraph>,
gap> InducedSubdigraph( gr, [ ] );
<digraph with 0 vertices, 0 edges>
gap> InducedSubdigraph( gr, [ 2 .. 6 ] );
<multidigraph with 5 vertices, 7 edges>
gap> InducedSubdigraph( gr, [ 8 ] );
<digraph with 1 vertex, 0 edges>
gap> i1 := InducedSubdigraph( gr, [ 1, 4, 3 ] );
<multidigraph with 3 vertices, 6 edges>
gap> OutNeighbours(i1);
[ [ 1, 1, 3, 3, 2 ], [  ], [ 2 ] ]
gap> i2 := InducedSubdigraph( gr, [ 3, 4, 3, 1 ] );
Error, Graphs: InducedSubdigraph: usage,
the second argument <subverts> must be a duplicate-free subset
of the vertices of the first argument <digraph>,
gap> adj := [
> [ 2, 3, 4, 5, 6, 6, 7 ],
> [ 1, 1, 1, 3, 4, 5 ],
> [ 4 ],
> [ 3, 5 ],
> [ 1, 2, 2, 3, 4, 4, 6, 5, 6, 7 ],
> [ ],
> [ 1 ],
> [ ] ];;
gap> gr := Digraph(adj);
<multidigraph with 8 vertices, 27 edges>
gap> InducedSubdigraph( gr, [ "a" ] );
Error, Graphs: InducedSubdigraph: usage,
the second argument <subverts> must be a duplicate-free subset
of the vertices of the first argument <digraph>,
gap> InducedSubdigraph( gr, [ 0 ] );
Error, Graphs: InducedSubdigraph: usage,
the second argument <subverts> must be a duplicate-free subset
of the vertices of the first argument <digraph>,
gap> InducedSubdigraph( gr, [ 2 .. 9 ] );
Error, Graphs: InducedSubdigraph: usage,
the second argument <subverts> must be a duplicate-free subset
of the vertices of the first argument <digraph>,
gap> InducedSubdigraph( gr, [ ] );
<digraph with 0 vertices, 0 edges>
gap> i1 := InducedSubdigraph( gr, [ 1, 3, 5, 7 ] );
<digraph with 4 vertices, 8 edges>
gap> OutNeighbours(i1);
[ [ 2, 3, 4 ], [  ], [ 1, 2, 3, 4 ], [ 1 ] ]
gap> i2 := InducedSubdigraph( gr, [ 7, 5, 3, 1 ] );
<digraph with 4 vertices, 8 edges>
gap> i1 = i2;
false
gap> IsIsomorphicDigraph(i1, i2);
true
gap> InducedSubdigraph( gr, [ 2 .. 8 ] );
<multidigraph with 7 vertices, 15 edges>
gap> InducedSubdigraph( gr, [ 8 ] );
<digraph with 1 vertex, 0 edges>
gap> InducedSubdigraph( gr, [ 7, 8 ] );
<digraph with 2 vertices, 0 edges>
gap> gr := Digraph( [  [ 2, 4 ], [ 4, 5 ], [ 2, 5, 5 ], [ 5, 5 ] , [ 3 ] ] );
<multidigraph with 5 vertices, 10 edges>
gap> DigraphEdgeLabels(gr);
[ 1 .. 10 ]
gap> gri := InducedSubdigraph(gr, [ 4, 2, 5 ] );
<multidigraph with 3 vertices, 4 edges>
gap> DigraphVertexLabels(gri);
[ 4, 2, 5 ]
gap> DigraphEdgeLabels(gri);
[ 8, 9, 3, 4 ]
gap> OutNeighbours(gri);
[ [ 3, 3 ], [ 1, 3 ], [  ] ]

#T# QuotientDigraph
gap> gr := CompleteDigraph(2);
<digraph with 2 vertices, 2 edges>
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 2, 1 ] ]
gap> qr := QuotientDigraph( gr, [ [ 1, 2 ] ] );
<multidigraph with 1 vertex, 2 edges>
gap> DigraphEdges(qr);
[ [ 1, 1 ], [ 1, 1 ] ]
gap> QuotientDigraph( EmptyDigraph(0), [ ] );
<digraph with 0 vertices, 0 edges>
gap> QuotientDigraph( EmptyDigraph(0), [ [ 1 ] ] );
Error, Graphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition of the
vertices of the null digraph <digraph>. The only valid partition
of <digraph> is the empty list,
gap> gr := Digraph( [ [ 1, 2, 3, 2 ], [ 1, 3, 2 ], [ 1, 2 ] ] );
<multidigraph with 3 vertices, 9 edges>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ], [ 1, 2 ], [ 2, 1 ], [ 2, 3 ], [ 2, 2 ], 
  [ 3, 1 ], [ 3, 2 ] ]
gap> qr := QuotientDigraph( gr, [ [ 1, 3 ], [ 2 ] ] );
<multidigraph with 2 vertices, 9 edges>
gap> DigraphEdges(qr);
[ [ 1, 1 ], [ 1, 2 ], [ 1, 1 ], [ 1, 2 ], [ 1, 1 ], [ 1, 2 ], [ 2, 1 ], 
  [ 2, 1 ], [ 2, 2 ] ]
gap> QuotientDigraph( gr, [ 3 ] );
Error, Graphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],
gap> QuotientDigraph( gr, [ ] );
Error, Graphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],
gap> QuotientDigraph( gr, [ [ ], [ ] ] );
Error, Graphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],
gap> QuotientDigraph( gr, [ [ 0 ], [ 1 ] ] );
Error, Graphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],
gap> QuotientDigraph( gr, [ [ 1 ], [ 2 ], [ 0 ] ] );
Error, Graphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],
gap> QuotientDigraph( gr, [ [ 1 ], [ 2, 4 ] ] );
Error, Graphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],
gap> QuotientDigraph( gr, [ [ 1, 2 ], [ 2 ] ] );
Error, Graphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],
gap> QuotientDigraph( gr, [ [ 1 ], [ 2 ] ] );
Error, Graphs: QuotientDigraph: usage,
the second argument <partition> does not partition
every vertex of the first argument, <digraph>,
gap> gr := Digraph( rec( nrvertices := 8,
> source := [ 1, 1, 2, 2, 3, 4, 4, 4, 5, 5, 5, 5, 5, 6, 7, 7, 7, 7, 7, 8, 8 ],
> range := [ 6, 7, 1, 6, 5, 1, 4, 8, 1, 3, 4, 6, 7, 7, 1, 4, 5, 6, 7, 5, 6 ]
> ) );
<digraph with 8 vertices, 21 edges>
gap> qr := QuotientDigraph( gr, [ [ 1 ], [ 2, 3, 5, 7 ], [ 4, 6, 8 ] ] );
<multidigraph with 3 vertices, 21 edges>
gap> OutNeighbours(qr);
[ [ 3, 2 ], [ 1, 3, 2, 1, 2, 3, 3, 2, 1, 3, 2, 3, 2 ], [ 1, 3, 3, 2, 2, 3 ] ]

#T# DigraphInEdges and DigraphOutEdges
gap> gr := Digraph( [ [ 2, 2, 2, 2, 2 ], [ 1, 1, 1, 1 ], [ 1 ], [ 3, 2 ] ] );
<multidigraph with 4 vertices, 12 edges>
gap> DigraphInEdges(gr, 1);
[ [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 3, 1 ] ]
gap> DigraphOutEdges(gr, 3);
[ [ 3, 1 ] ]
gap> DigraphOutEdges(gr, 5);
Error, Graphs: DigraphOutEdges: usage,
5 is not a vertex of the digraph,
gap> DigraphInEdges(gr, 1000);
Error, Graphs: DigraphInEdges: usage,
1000 is not a vertex of the digraph,
gap> gr := Digraph( rec( vertices := [ "a", "b", "c" ], source := [ "a", "a", "b" ],
> range := [ "b", "b", "c" ] ) );
<multidigraph with 3 vertices, 3 edges>
gap> DigraphInEdges(gr, 1);
[  ]
gap> DigraphInEdges(gr, 2);
[ [ 1, 2 ], [ 1, 2 ] ]
gap> DigraphOutEdges(gr, 1);
[ [ 1, 2 ], [ 1, 2 ] ]

#T# DigraphStronglyConnectedComponent
gap> gr := Digraph( [ [ 2, 4 ], [ ], [ 2, 6 ], [ 1, 3 ], [ 2, 3 ], [ 5 ] ] );
<digraph with 6 vertices, 9 edges>
gap> DigraphStronglyConnectedComponent(gr, 1);
[ 1, 4 ]
gap> DigraphStronglyConnectedComponent(gr, 2);
[ 2 ]
gap> DigraphStronglyConnectedComponent(gr, 3);
[ 3, 6, 5 ]
gap> DigraphStronglyConnectedComponent(gr, 7);
Error, Graphs: DigraphStronglyConnectedComponent: usage,
7 is not a vertex of the digraph,

#T# DigraphyConnectedComponent
gap> gr := Digraph( [ [ 2, 4 ], [ ], [ 2, 6 ], [ 1, 3 ], [ 2, 3 ], [ 5 ] ] );
<digraph with 6 vertices, 9 edges>
gap> DigraphConnectedComponent(gr, 3);
[ 1, 2, 3, 4, 5, 6 ]
gap> DigraphConnectedComponent(gr, 7);
Error, Graphs: DigraphConnectedComponent: usage,
7 is not a vertex of the digraph,

#T# IsDigraphEdge
gap> gr := CycleDigraph(1000); # CycleDigraph with source/range
<digraph with 1000 vertices, 1000 edges>
gap> IsDigraphEdge(gr, [ 1 ] );
false
gap> IsDigraphEdge(gr, [ "a", 2 ] );
false
gap> IsDigraphEdge(gr, [ 1, "a" ] );
false
gap> IsDigraphEdge(gr, [ 1001, 1 ] );
false
gap> IsDigraphEdge(gr, [ 1, 1001 ] );
false
gap> IsDigraphEdge(gr, [ 100, 101 ]);
true
gap> IsDigraphEdge(gr, [ 1000, 1 ]);
true
gap> IsDigraphEdge(gr, [ 1000, 600 ]);
false
gap> out := List( [ 1 .. 999 ], x -> [ x + 1 ] );;
gap> Add(out, [ 1 ]);;
gap> gr := Digraph(out); # CycleDigraph with OutNeighbours
<digraph with 1000 vertices, 1000 edges>
gap> IsDigraphEdge(gr, [ 1 ] );
false
gap> IsDigraphEdge(gr, [ "a", 2 ] );
false
gap> IsDigraphEdge(gr, [ 1, "a" ] );
false
gap> IsDigraphEdge(gr, [ 1001, 1 ] );
false
gap> IsDigraphEdge(gr, [ 1, 1001 ] );
false
gap> IsDigraphEdge(gr, [ 100, 101 ]);
true
gap> IsDigraphEdge(gr, [ 1000, 1 ]);
true
gap> IsDigraphEdge(gr, [ 1000, 600 ]);
false
gap> gr := Digraph( rec( nrvertices := 2, source := [ 1 ], range := [ 2 ] ) );
<digraph with 2 vertices, 1 edge>
gap> IsDigraphEdge(gr, [ 2, 1 ] );
false
gap> IsDigraphEdge(gr, [ 1, 1 ] );
false
gap> gr := CompleteDigraph(500); # A bigger digraph with OutNeighbours
<digraph with 500 vertices, 249500 edges>
gap> IsDigraphEdge(gr, [ 200, 199 ]);
true
gap> IsDigraphEdge(gr, [ 499, 499 ]);
false
gap> IsDigraphEdge(gr, [ 249, 251 ]);
true
gap> gr := EmptyDigraph(1000000);
<digraph with 1000000 vertices, 0 edges>
gap> IsDigraphEdge(gr, [ 9999, 9999 ]);
false
gap> gr := CompleteDigraph( 10 );
<digraph with 10 vertices, 90 edges>
gap> mat := AdjacencyMatrix(gr);;
gap> IsDigraphEdge( gr, [ 5, 5 ] );
false
gap> IsDigraphEdge( gr, [ 5, 6 ] );
true
gap> gr := Digraph( [ [ 1, 1 ], [ 2 ] ] );
<multidigraph with 2 vertices, 3 edges>
gap> mat := AdjacencyMatrix(gr);;
gap> IsDigraphEdge(gr, [ 1, 1 ]);
true
gap> IsDigraphEdge(gr, [ 1, 2 ]);
false

#T# DigraphAddEdges
gap> gr := RandomDigraph(100);;
gap> DigraphAddEdges(gr, [ ]);;
gap> gr = last;
true
gap> DigraphAddEdges(gr, [ 12 ] );
Error, Graphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [ [ 12 ] ] );
Error, Graphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [ [ 12, 13, 14 ], [ 11, 10 ] ] );
Error, Graphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [ [ -2, 3 ], [ "a" ] ] );
Error, Graphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [ [ 11, 10 ], [ 12, 13, 14 ] ] );
Error, Graphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [ [ 4, 5 ], [ 1, 120 ], [ 1, 1 ] ] );
Error, Graphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges(gr, [ [ 4, 5 ], [ 120, 1 ], [ 1, 1 ] ] );
Error, Graphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> gr := Digraph( [ [ 2, 2 ], [ 1, 3, 2 ], [ 2, 1 ], [ 1 ] ] );
<multidigraph with 4 vertices, 8 edges>
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 1, 2 ], [ 2, 1 ], [ 2, 3 ], [ 2, 2 ], [ 3, 2 ], [ 3, 1 ], 
  [ 4, 1 ] ]
gap> gr2 := DigraphAddEdges( gr, [ [ 2, 1 ], [ 3, 3 ], [ 2, 4 ], [ 3, 3 ] ] );
<multidigraph with 4 vertices, 12 edges>
gap> DigraphEdges(gr2);
[ [ 1, 2 ], [ 1, 2 ], [ 2, 1 ], [ 2, 3 ], [ 2, 2 ], [ 2, 1 ], [ 2, 4 ], 
  [ 3, 2 ], [ 3, 1 ], [ 3, 3 ], [ 3, 3 ], [ 4, 1 ] ]
gap> gr3 := Digraph( rec( nrvertices := DigraphNrVertices(gr),
>                         source     := ShallowCopy(DigraphSource(gr)),
>                         range      := ShallowCopy(DigraphRange(gr)) ) );
<multidigraph with 4 vertices, 8 edges>
gap> gr4 := DigraphAddEdges( gr3, [ [ 2, 1 ], [ 3, 3 ], [ 2, 4 ], [ 3, 3 ] ] );
<multidigraph with 4 vertices, 12 edges>
gap> gr2 = gr4;
true
gap> gr := Digraph( [ [ 1, 2 ], [ ], [ 1 ] ] );
<digraph with 3 vertices, 3 edges>
gap> gr1 := DigraphAddEdges( gr, [ ] );
<digraph with 3 vertices, 3 edges>
gap> gr = gr1;
true
gap> DigraphAddEdges( gr, [ 3 ] );
Error, Graphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges( gr, [ [ 3 ] ] );
Error, Graphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges( gr, [ "ab" ] );
Error, Graphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges( gr, [ [ -1, -2 ] ] );
Error, Graphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges( gr, [ [ 1, 2 ], [ 1, 2, 3 ] ] );
Error, Graphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges( gr, [ [ 4, 2 ] ] );
Error, Graphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges( gr, [ [ 2, 4 ] ] );
Error, Graphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of pairs of vertices
of the first argument <digraph>,
gap> DigraphAddEdges( gr, [ [ 2, 3 ], [ 2, 3 ] ] );
<multidigraph with 3 vertices, 5 edges>
gap> DigraphEdges(last);
[ [ 1, 1 ], [ 1, 2 ], [ 2, 3 ], [ 2, 3 ], [ 3, 1 ] ]
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 2 ], [ 3, 1 ] ]

#T# DigraphAddEdge
gap> gr := RandomDigraph(10);;
gap> DigraphAddEdge( gr, [ 1, 2, 3 ] );
Error, Graphs: DigraphAddEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> DigraphAddEdge( gr, [ "a", "a" ] );
Error, Graphs: DigraphAddEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> DigraphAddEdge( gr, [ 1, "a" ] );
Error, Graphs: DigraphAddEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> DigraphAddEdge( gr, [ 11, 1 ] );
Error, Graphs: DigraphAddEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> DigraphAddEdge( gr, [ 1, 11 ] );
Error, Graphs: DigraphAddEdge: usage,
the second argument <edge> must be a pair of vertices of <digraph>,
gap> gr := EmptyDigraph(2);
<digraph with 2 vertices, 0 edges>
gap> DigraphAddEdge( gr, [ 1, 2 ] );
<digraph with 2 vertices, 1 edge>
gap> DigraphEdges(last);
[ [ 1, 2 ] ]

#T# DigraphAddVertices
gap> gr := Digraph( [ [ 1 ] ] );;
gap> gr2 := DigraphAddVertices(gr, 3);
<digraph with 4 vertices, 1 edge>
gap> DigraphVertices(gr2);
[ 1 .. 4 ]
gap> DigraphEdges(gr) = DigraphEdges(gr2);
true
gap> gr2 := DigraphAddVertices(gr, 3, [ SymmetricGroup(2), Group(()) ] );
Error, Graphs: DigraphAddVertices: usage,
the number of new vertex names (the length of the third arg <names>)
must match the number of new vertices (the value of the second arg <m>),
gap> gr2 := DigraphAddVertices(gr, 2, [ SymmetricGroup(2), Group(()) ] );
<digraph with 3 vertices, 1 edge>
gap> DigraphVertices(gr2);
[ 1 .. 3 ]
gap> DigraphEdges(gr) = DigraphEdges(gr2);
true
gap> DigraphVertexLabels(gr2);
[ 1, Sym( [ 1 .. 2 ] ), Group(()) ]
gap> gr := Digraph( [ [ 1 ] ] );;
gap> SetDigraphVertexLabels(gr, [ AlternatingGroup(5) ]);
gap> gr2 := DigraphAddVertices(gr, 2, [ SymmetricGroup(2), Group(()) ] );
<digraph with 3 vertices, 1 edge>
gap> DigraphVertexLabels(gr2);
[ Alt( [ 1 .. 5 ] ), Sym( [ 1 .. 2 ] ), Group(()) ]
gap> gr := Digraph( rec( nrvertices := 1, source := [ 1 ], range := [ 1 ] ) );
<digraph with 1 vertex, 1 edge>
gap> gr2 := DigraphAddVertices(gr, 2);
<digraph with 3 vertices, 1 edge>
gap> DigraphVertexLabels(gr2);
[ 1, 2, 3 ]
gap> SetDigraphVertexLabels(gr, [ true ]);
gap> gr2 := DigraphAddVertices(gr, 2);
<digraph with 3 vertices, 1 edge>
gap> DigraphVertexLabels(gr2);
[ true, 2, 3 ]
gap> gr := Digraph( rec( nrvertices := 1, source := [ 1 ], range := [ 1 ] ) );;
gap> gr2 := DigraphAddVertices(gr, 2, [ SymmetricGroup(2), Group(()) ] );
<digraph with 3 vertices, 1 edge>
gap> DigraphVertexLabels(gr2);
[ 1, Sym( [ 1 .. 2 ] ), Group(()) ]
gap> gr := Digraph( rec( nrvertices := 1, source := [ 1 ], range := [ 1 ] ) );;
gap> SetDigraphVertexLabels(gr, [ AlternatingGroup(5) ]);
gap> gr2 := DigraphAddVertices(gr, 2, [ SymmetricGroup(2), Group(()) ] );
<digraph with 3 vertices, 1 edge>
gap> DigraphVertexLabels(gr2);
[ Alt( [ 1 .. 5 ] ), Sym( [ 1 .. 2 ] ), Group(()) ]
gap> DigraphAddVertices(gr2, -1);
Error, Graphs: DigraphAddVertices: usage,
the second arg <m> (the number of vertices to add) must be non-negative,
gap> gr3 := DigraphAddVertices(gr2, 0);
<digraph with 3 vertices, 1 edge>
gap> IsIdenticalObj(gr2, gr3);
false
gap> gr2 = gr3;
true
gap> DigraphAddVertices(gr2, -1, [ ]);
Error, Graphs: DigraphAddVertices: usage,
the second arg <m> (the number of vertices to add) must be non-negative,
gap> gr3 := DigraphAddVertices(gr2, 0, [ ]);
<digraph with 3 vertices, 1 edge>
gap> IsIdenticalObj(gr2, gr3);
false
gap> gr2 = gr3;
true

#T# DigraphAddVertex
gap> gr := CompleteDigraph(1);
<digraph with 1 vertex, 0 edges>
gap> DigraphVertices(gr);
[ 1 ]
gap> gr2 := DigraphAddVertex(gr);
<digraph with 2 vertices, 0 edges>
gap> DigraphVertices(gr2);
[ 1, 2 ]
gap> DigraphEdges(gr) = DigraphEdges(gr2);
true
gap> gr := DigraphAddEdge(gr, [ 1, 1 ]);
<digraph with 1 vertex, 1 edge>
gap> DigraphVertices(gr);
[ 1 ]
gap> gr2 := DigraphAddVertex(gr);
<digraph with 2 vertices, 1 edge>
gap> DigraphVertices(gr2);
[ 1, 2 ]
gap> DigraphEdges(gr) = DigraphEdges(gr2);
true
gap> gr2 := DigraphAddVertex(gr, SymmetricGroup(2));
<digraph with 2 vertices, 1 edge>
gap> DigraphVertices(gr2);
[ 1, 2 ]
gap> DigraphEdges(gr) = DigraphEdges(gr2);
true
gap> DigraphVertexLabels(gr);
[ 1 ]
gap> DigraphVertexLabels(gr2);
[ 1, Sym( [ 1 .. 2 ] ) ]

#T# DigraphRemoveVertex
gap> gr := Digraph( [
> [ 2, 4, 5 ], [ 1, 9, 11 ], [ 1, 10, 12 ], [ 4, 6, 10 ], 
> [ 2, 3, 4, 6, 8, 11, 12, 14 ], [ 2, 5, 6, 9, 14 ], [  ], [ 5, 8, 10 ], 
> [ 8, 11, 12, 14 ], [ 2, 3, 8, 13, 14 ], [ 3, 6, 7, 8, 11, 12, 13, 14 ], 
> [ 6, 8, 12, 13 ], [ 4, 8 ], [ 6, 8, 9 ] ] );
<digraph with 14 vertices, 54 edges>
gap> DigraphRemoveVertex(gr, "a");
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphRemoveVertex' on 2 arguments
gap> DigraphRemoveVertex(gr, 0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphRemoveVertex' on 2 arguments
gap> DigraphRemoveVertex(gr, 15);
Error, Graphs: DigraphRemoveVertex: usage,
the second arg <m> is not a vertex of the first arg <digraph>,
gap> gr2 := DigraphRemoveVertex(gr, 10);;
gap> DigraphNrVertices(gr2);
13
gap> DigraphNrEdges(gr2) =
> DigraphNrEdges(gr) - OutDegreeOfVertex(gr, 10) - InDegreeOfVertex(gr, 10);
true

#T# DigraphRemoveVertices
gap> gr := CompleteDigraph(4);
<digraph with 4 vertices, 12 edges>
gap> gr2 := DigraphRemoveVertices( gr, [  ] );
<digraph with 4 vertices, 12 edges>
gap> gr = gr2;
true
gap> gr2 := DigraphRemoveVertices(gr, [ 0 ] );
Error, Graphs: DigraphRemoveVertices: usage,
the second arg <verts> should be a duplicate free list of vertices of
the first arg <digraph>,
gap> gr2 := DigraphRemoveVertices( gr, [ 1, "a" ]);
Error, Graphs: DigraphRemoveVertices: usage,
the second arg <verts> should be a duplicate free list of vertices of
the first arg <digraph>,
gap> gr2 := DigraphRemoveVertices( gr, [ 1, 1 ] );
Error, Graphs: DigraphRemoveVertices: usage,
the second arg <verts> should be a duplicate free list of vertices of
the first arg <digraph>,
gap> gr2 := DigraphRemoveVertices( gr, [ 1, 0 ] );
Error, Graphs: DigraphRemoveVertices: usage,
the second arg <verts> should be a duplicate free list of vertices of
the first arg <digraph>,
gap> gr2 := DigraphRemoveVertices( gr, [ 1, 5 ] );
Error, Graphs: DigraphRemoveVertices: usage,
the second arg <verts> should be a duplicate free list of vertices of
the first arg <digraph>,
gap> gr2 := DigraphRemoveVertices( gr, [ 1, 3 ] );
<digraph with 2 vertices, 2 edges>
gap> IsCompleteDigraph(gr2);
true
gap> DigraphVertexLabels(gr2);
[ 2, 4 ]
gap> gr3 := DigraphRemoveVertices( gr, [ 1 .. 4 ] );
<digraph with 0 vertices, 0 edges>
gap> gr := Digraph( rec( nrvertices := 4,
> source := [ 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4 ],
> range  := [ 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4 ] ) );
<digraph with 4 vertices, 16 edges>
gap> IsCompleteDigraph(gr);
false
gap> SetDigraphVertexLabels( gr, [ (), (1,2), (1,2,3), (1,2,3,4) ] );
gap> gr2 := DigraphRemoveVertices( gr, [ 1 .. 4 ] );
<digraph with 0 vertices, 0 edges>
gap> gr3 := DigraphRemoveVertices( gr, [ 2, 3 ] );
<digraph with 2 vertices, 4 edges>
gap> DigraphVertexLabels(gr3);
[ (), (1,2,3,4) ]
gap> gr4 := DigraphRemoveVertices( gr, [ ] );
<digraph with 4 vertices, 16 edges>
gap> gr = gr4;
true

#T# AsBinaryRelation
gap> gr := EmptyDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> AsBinaryRelation(gr);
Error, Graphs: AsBinaryRelation: usage,
the argument <digraph> must have at least one vertex,
gap> gr := Digraph( [ [ 1, 1 ] ] );
<multidigraph with 1 vertex, 2 edges>
gap> AsBinaryRelation(gr);
Error, Graphs: AsBinaryRelation: usage,
this function does not apply to digraphs with multiple edges,
gap> gr := Digraph(
> [ [ 1, 2, 3 ], [ 1, 2, 3 ], [ 1, 2, 3 ], [ 4, 5 ], [ 4, 5 ] ] );
<digraph with 5 vertices, 13 edges>
gap> rel1 := AsBinaryRelation(gr);
Binary Relation on 5 points
gap> Digraph(rel1) = gr;
true
gap> IsReflexiveBinaryRelation(rel1);
true
gap> IsSymmetricBinaryRelation(rel1);
true
gap> IsTransitiveBinaryRelation(rel1);
true
gap> IsAntisymmetricBinaryRelation(rel1);
false
gap> IsEquivalenceRelation(rel1);
true
gap> List(EquivalenceClasses(rel1), Elements);
[ [ 1, 2, 3 ], [ 4, 5 ] ]
gap> DigraphStronglyConnectedComponents(gr).comps;
[ [ 1, 2, 3 ], [ 4, 5 ] ]
gap> last = last2;
true
gap> Successors(rel1);
[ [ 1, 2, 3 ], [ 1, 2, 3 ], [ 1, 2, 3 ], [ 4, 5 ], [ 4, 5 ] ]
gap> OutNeighbours(gr);
[ [ 1, 2, 3 ], [ 1, 2, 3 ], [ 1, 2, 3 ], [ 4, 5 ], [ 4, 5 ] ]
gap> last = last2;
true
gap> IsReflexiveDigraph(gr);
true
gap> IsSymmetricDigraph(gr);
true
gap> IsAntisymmetricDigraph(gr);
false
gap> rel2 := AsBinaryRelation(gr);
Binary Relation on 5 points
gap> HasIsReflexiveBinaryRelation(rel2);
true
gap> HasIsSymmetricBinaryRelation(rel2);
true
gap> HasIsTransitiveBinaryRelation(rel2);
false
gap> HasIsAntisymmetricBinaryRelation(rel2);
true
gap> rel3 := AsBinaryRelation(Digraph(rel1));
<equivalence relation on <object> >
gap> HasIsReflexiveBinaryRelation(rel3);
true
gap> HasIsSymmetricBinaryRelation(rel3);
true
gap> HasIsTransitiveBinaryRelation(rel3);
true
gap> HasIsAntisymmetricBinaryRelation(rel3);
true

#T# DigraphSymmetricClosure
gap> gr1 := Digraph( [ [ 2 ], [ 1 ] ] );
<digraph with 2 vertices, 2 edges>
gap> IsSymmetricDigraph(gr);
true
gap> gr2 := DigraphSymmetricClosure(gr1);
<digraph with 2 vertices, 2 edges>
gap> IsIdenticalObj(gr1, gr2);
false
gap> gr1 = gr2;
true
gap> gr1 := Digraph( [ [ 1, 1, 1, 1 ] ] );
<multidigraph with 1 vertex, 4 edges>
gap> gr2 := DigraphSymmetricClosure(gr1);
<multidigraph with 1 vertex, 4 edges>
gap> IsIdenticalObj(gr1, gr2);
false
gap> gr1 = gr2;
true
gap> gr1 := Digraph(
> [ [  ], [ 4, 5 ], [ 12 ], [ 3 ], [ 2, 10, 11, 12 ], [ 2, 8, 10, 12 ], [ 5 ],
> [ 11, 12 ], [ 12 ], [ 12 ], [ 2, 6, 7, 8 ], [ 3, 8, 10 ] ] );
<digraph with 12 vertices, 24 edges>
gap> IsSymmetricDigraph(gr1);
false
gap> gr2 := DigraphSymmetricClosure(gr1);
<digraph with 12 vertices, 38 edges>
gap> HasIsSymmetricDigraph(gr2);
true
gap> IsSymmetricDigraph(gr2);
true
gap> gr3 := Digraph(
> [ [  ], [ 4, 5, 11, 6 ], [ 4, 12 ], [ 2, 3 ], [ 2, 10, 11, 12, 7 ], 
> [ 8, 10, 12, 2, 11 ], [ 5, 11 ], [ 11, 12, 6 ], [ 12 ], [ 5, 6, 12 ], 
> [ 7, 6, 2, 5, 8 ], [ 10, 5, 3, 8, 6, 9 ] ] );;
gap> gr2 = gr3;
true

#T# DigraphReverseEdge and DigraphReverseEdges
gap> gr := Digraph( [ [ 1, 1 ] ] );
<multidigraph with 1 vertex, 2 edges>
gap> DigraphReverseEdges( gr, [ [ 2, 2 ] ] );
Error, Graphs: DigraphReverseEdges: usage,
the first argument <digraph> must not be a multigraph,
gap> DigraphReverseEdges( gr, [ 2 ] );
Error, Graphs: DigraphReverseEdges: usage,
the first argument <digraph> must not be a multigraph,
gap> gr := CompleteDigraph(100);
<digraph with 100 vertices, 9900 edges>
gap> DigraphReverseEdges(gr, "a");
Error, Graphs: DigraphReverseEdges: usage,
the second argument <edge> must be a list of edges of <digraph>,
gap> DigraphReverseEdges( gr, Group(()) );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphReverseEdges' on 2 arguments
gap> DigraphReverseEdges(gr, [ 0, 0 ]);
Error, Graphs: DigraphReverseEdges: usage,
the second argument <edge> must be a list of edges of <digraph>,
gap> DigraphReverseEdges(gr, [ [ 0 ] ]);
Error, Graphs: DigraphReverseEdges: usage,
the second argument <edges> must be a list of edges of <digraph>,
gap> DigraphReverseEdges(gr, [ [ 1 ], [ 1 ] ]);
Error, Graphs: DigraphReverseEdges: usage,
the second argument <edges> must be a list of edges of <digraph>,
gap> edges := ShallowCopy(DigraphEdges(gr));;
gap> gr = DigraphReverseEdges(gr, edges);
true
gap> gr = DigraphReverseEdges(gr, [1 .. DigraphNrEdges(gr) ]);
true
gap> DigraphReverseEdge(gr, 2) = DigraphReverseEdge( gr, [ 1, 3 ] );
true
gap> gr = DigraphReverseEdges(gr, [  ]);
true
gap> gr := CycleDigraph(100);
<digraph with 100 vertices, 100 edges>
gap> edges := ShallowCopy(DigraphEdges(gr));;
gap>  gr = DigraphReverseEdges(gr, edges);
false
gap> gr2 := DigraphReverseEdges(gr, edges);
<digraph with 100 vertices, 100 edges>
gap> gr = gr2;
false
gap> edges2 := ShallowCopy(DigraphEdges(gr2));;
gap> gr = DigraphReverseEdges(gr2, edges2);
true
gap> gr = DigraphReverseEdges(gr, [1 .. DigraphNrEdges(gr) ]);
false
gap> DigraphReverseEdge(gr, 1) = DigraphReverseEdge(gr, [1,2]);
true
gap> gr = DigraphReverseEdges(gr, []);
true

#T# DigraphDisjointUnion
gap> gr := CycleDigraph(1000);
<digraph with 1000 vertices, 1000 edges>
gap> gr2 := CompleteDigraph(100);
<digraph with 100 vertices, 9900 edges>
gap> DigraphDisjointUnion(gr, gr);
<digraph with 2000 vertices, 2000 edges>
gap> DigraphDisjointUnion(gr2, gr2);
<digraph with 200 vertices, 19800 edges>
gap> DigraphDisjointUnion(gr, gr2);
<digraph with 1100 vertices, 10900 edges>
gap> gr := CycleDigraph(1000);;
gap> DigraphDisjointUnion(gr2, gr);
<digraph with 1100 vertices, 10900 edges>
gap> gr1 := Digraph( [ [ 2, 2, 3 ], [ 3 ], [ 2 ] ] );
<multidigraph with 3 vertices, 5 edges>
gap> gr2 := Digraph( [ [ 1, 2 ], [ 1 ] ] );
<digraph with 2 vertices, 3 edges>
gap> gr3 := Digraph( rec( nrvertices := 2,
> source := [ 1, 1, 2 ], range := [ 2, 1, 1 ] ) );;
gap> gr2 = gr3;
true
gap> u1 := DigraphDisjointUnion(gr1, gr2);
<multidigraph with 5 vertices, 8 edges>
gap> u2 := DigraphDisjointUnion(gr1, gr3);
<multidigraph with 5 vertices, 8 edges>
gap> u1 = u2;
true

#T# DigraphFloydWarshall
gap> func := function(mat, i, j, k)
>   if (i = j) or (mat[i][k] <> 0 and mat[k][j] <> 0) then
>     mat[i][j] := 1;
>   fi;
> end;
function( mat, i, j, k ) ... end
gap> gr := Digraph(
> [ [ 1, 2, 4, 5, 7 ], [ 1, 2 ], [ 3, 7 ], [ 2, 10 ], [ 2, 6 ], [ 2, 7 ],
>   [  ], [ 3, 4 ], [ 1, 10 ], [ 1, 3, 9 ] ] );
<digraph with 10 vertices, 22 edges>
gap> rtclosure := DigraphFloydWarshall( gr, func, 0, 1 );;
gap> grrt := DigraphByAdjacencyMatrix(rtclosure);
<digraph with 10 vertices, 76 edges>
gap> grrt = DigraphReflexiveTransitiveClosure(gr);
true
gap> func := function(mat, i, j, k)
>   if mat[i][k] <> 0 and mat[k][j] <> 0 then
>     mat[i][j] := 1;
>   fi;
> end;
function( mat, i, j, k ) ... end
gap> gr := Digraph(
> rec(
>   nrvertices := 10,
>   source := [ 1, 2, 2, 3, 4, 5, 6, 7, 10, 10, 10 ],
>   range :=  [ 6, 9, 5, 7, 3, 4, 8, 4, 7, 9, 8 ],
> ) );
<digraph with 10 vertices, 11 edges>
gap> tclosure := DigraphFloydWarshall( gr, func, 0, 1 );;
gap> grt := DigraphByAdjacencyMatrix(tclosure);
<digraph with 10 vertices, 25 edges>
gap> grt = DigraphTransitiveClosure(gr);
true

#T# DigraphEdgeUnion
gap> gr1 := Digraph(
>  10,
>  [ 3, 4, 4, 6, 6, 9, 9, 9, 9 ],
>  [ 10, 5, 7, 3, 9, 4, 5, 8, 10 ]
> );
<digraph with 10 vertices, 9 edges>
gap> gr2 := Digraph( [ [ 9 ], [ 9, 1, 6, 3 ], [ ], [ ], [ 9, 3, 9 ],
> [ 1, 4, 3, 2, 9, 4 ], [ 1, 7 ], [ 1, 2, 4 ], [ 8 ] ] );
<multidigraph with 9 vertices, 20 edges>
gap> m1 := DigraphEdgeUnion(gr1, gr2);
<multidigraph with 10 vertices, 29 edges>
gap> m2 := DigraphEdgeUnion(gr2, gr1);
<multidigraph with 10 vertices, 29 edges>
gap> gr1 := Digraph( [ [ 2 ], [ ], [ 4 ], [ ], [ 6 ], [ ] ] );
<digraph with 6 vertices, 3 edges>
gap> gr2 := Digraph( [ [ ], [ 3 ], [ ], [ 5 ], [ ], [ 1 ] ] );
<digraph with 6 vertices, 3 edges>
gap> m := DigraphEdgeUnion(gr1, gr2);
<digraph with 6 vertices, 6 edges>
gap> m = CycleDigraph(6);
true
gap> m = DigraphEdgeUnion(gr2, gr1);
true
gap> DigraphEdgeUnion(EmptyDigraph(0),EmptyDigraph(0)) = EmptyDigraph(0);
true
gap> DigraphEdgeUnion(EmptyDigraph(5),EmptyDigraph(3)) = EmptyDigraph(5);
true
gap> gr := DigraphNC([ [ 6, 3, 3, 10, 6 ], [ 4 ], [ 5, 1 ], [ 5, 4, 6 ],
> [ 9 ], [ 8 ], [ 7, 6 ], [ 8, 10, 8, 1 ], [  ], [ 2 ] ]);;
gap> gr := DigraphEdgeUnion(gr, gr);
<multidigraph with 10 vertices, 40 edges>
gap> OutNeighbours(gr);
[ [ 6, 3, 3, 10, 6, 6, 3, 3, 10, 6 ], [ 4, 4 ], [ 5, 1, 5, 1 ], 
  [ 5, 4, 6, 5, 4, 6 ], [ 9, 9 ], [ 8, 8 ], [ 7, 6, 7, 6 ], 
  [ 8, 10, 8, 1, 8, 10, 8, 1 ], [  ], [ 2, 2 ] ]

#T# DigraphCopy
gap> gr := Digraph( [ [ 6, 1, 2, 3 ], [ 6 ], [ 2, 2, 3 ], [ 1, 1 ], [ 6, 5 ],
> [ 6, 4 ] ] );
<multidigraph with 6 vertices, 14 edges>
gap> gr = DigraphCopy(gr);
true
gap> gr := CompleteDigraph(100);
<digraph with 100 vertices, 9900 edges>
gap> gr = DigraphCopy(gr);
true
gap> gr := CycleDigraph(10000);
<digraph with 10000 vertices, 10000 edges>
gap> gr = DigraphCopy(gr);
true
gap> SetDigraphVertexLabel(gr, 1, "w");
gap> DigraphVertexLabels(DigraphCopy(gr))[1];
"w"
gap> gr := Digraph( rec( vertices := [ "a", Group((1,2)) ],
> source := [ Group((1,2)) ], range := [ "a" ] ) );
<digraph with 2 vertices, 1 edge>
gap> DigraphVertexLabels(gr);
[ "a", Group([ (1,2) ]) ]
gap> gr2 := DigraphCopy(gr);;
gap> gr = gr2;
true
gap> DigraphVertexLabels(gr2);
[ "a", Group([ (1,2) ]) ]

#T# DigraphJoin
gap> gr := CompleteDigraph(20);
<digraph with 20 vertices, 380 edges>
gap> gr2 := EmptyDigraph(10);
<digraph with 10 vertices, 0 edges>
gap> DigraphJoin(gr, gr2);
<digraph with 30 vertices, 780 edges>
gap> DigraphJoin(gr, EmptyDigraph(0));
<digraph with 20 vertices, 380 edges>
gap> DigraphJoin(EmptyDigraph(0), CycleDigraph(1000));
<digraph with 1000 vertices, 1000 edges>
gap> DigraphJoin(EmptyDigraph(0), EmptyDigraph(0));
<digraph with 0 vertices, 0 edges>
gap> DigraphJoin(EmptyDigraph(5), EmptyDigraph(5));
<digraph with 10 vertices, 50 edges>
gap> gr1 := Digraph( [ [ 2, 2, 3 ], [ 3 ], [ 2 ] ] );
<multidigraph with 3 vertices, 5 edges>
gap> gr2 := Digraph( [ [ 1, 2 ], [ 1 ] ] );
<digraph with 2 vertices, 3 edges>
gap> gr3 := Digraph( rec( nrvertices := 2,
> source := [ 1, 1, 2 ], range := [ 2, 1, 1 ] ) );;
gap> gr2 = gr3;
true
gap> j1 := DigraphJoin(gr1, gr2);
<multidigraph with 5 vertices, 20 edges>
gap> j2 := DigraphJoin(gr1, gr3);
<multidigraph with 5 vertices, 20 edges>
gap> u1 = u2;
true

#T# OnMultiDigraphs
gap> gr1 := CompleteDigraph(3);
<digraph with 3 vertices, 6 edges>
gap> DigraphEdges(gr1);
[ [ 1, 2 ], [ 1, 3 ], [ 2, 1 ], [ 2, 3 ], [ 3, 1 ], [ 3, 2 ] ]
gap> gr2 := OnMultiDigraphs( gr1, (1,3), (3,6) );;
gap> DigraphEdges(gr1);;
gap> OnMultiDigraphs( gr1, [ (1,3) ] );
Error, Graphs: OnMultiDigraphs: usage,
the 2nd argument must be a pair of permutations,
gap> OnMultiDigraphs( gr1, [ (1,3), (1,7) ] );
Error, Graphs: OnDigraphs: usage,
the argument <perms[2]> must permute the edges of the 1st argument <graph>,

#T# IsReachable
gap> gr1 := DigraphRemoveEdges(CycleDigraph(100), [ [ 100, 1 ], [ 99, 100 ] ]);
<digraph with 100 vertices, 98 edges>
gap> IsReachable(gr1, 0, 1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `IsReachable' on 3 arguments
gap> IsReachable(gr1, 101, 1);
Error, Graphs: IsReachable: usage,
the second and third arguments <u> and <v> must be vertices
of the first argument <digraph>,
gap> IsReachable(gr1, 1, 101);
Error, Graphs: IsReachable: usage,
the second and third arguments <u> and <v> must be vertices
of the first argument <digraph>,
gap> IsReachable(gr1, 1, 2);
true
gap> gr1 := DigraphRemoveEdges(CycleDigraph(100), [ [ 100, 1 ], [ 99, 100 ] ]);;
gap> AdjacencyMatrix(gr1);;
gap> IsReachable(gr1, 1, 2);
true
gap> gr1 := DigraphRemoveEdges(CycleDigraph(100), [ [ 100, 1 ], [ 99, 100 ] ]);;
gap> IsReachable(gr1, 100, 1);
false
gap> gr1 := DigraphRemoveEdges(CycleDigraph(100), [ [ 100, 1 ], [ 99, 100 ] ]);;
gap> DigraphConnectedComponents(gr1);;
gap> IsReachable(gr1, 100, 1);
false
gap> gr1 := CycleDigraph(100);
<digraph with 100 vertices, 100 edges>
gap> IsReachable(gr1, 1, 50);
true
gap> IsReachable(gr1, 1, 1);
true
gap> gr1 := CycleDigraph(100);;
gap> DigraphStronglyConnectedComponents(gr1);;
gap> IsReachable(gr1, 1, 50);
true
gap> IsReachable(gr1, 1, 1);
true
gap> gr1 := Digraph( [ [ 2 ], [ 1 ], [ 3 ], [  ] ] );
<digraph with 4 vertices, 3 edges>
gap> IsReachable(gr1, 1, 2);
true
gap> IsReachable(gr1, 1, 1);
true
gap> IsReachable(gr1, 3, 3);
true
gap> IsReachable(gr1, 1, 3);
false
gap> IsReachable(gr1, 4, 4);
false
gap> gr1 := Digraph( [ [ 2 ], [ 1 ], [ 3 ], [  ] ] );;
gap> DigraphStronglyConnectedComponents(gr1);
rec( comps := [ [ 1, 2 ], [ 3 ], [ 4 ] ], id := [ 1, 1, 2, 3 ] )
gap> IsReachable(gr1, 1, 2);
true
gap> IsReachable(gr1, 1, 1);
true
gap> IsReachable(gr1, 3, 3);
true
gap> IsReachable(gr1, 1, 3);
false
gap> IsReachable(gr1, 4, 4);
false
gap> gr := Digraph(
> [ [ 1, 3, 4, 5 ], [ ], [ 1, 3, 4, 5 ], [ 1, 3, 4, 5 ], [ 1, 3, 4, 5 ] ]);
<digraph with 5 vertices, 16 edges>
gap> IsReachable(gr, 1, 2);
false
gap> IsReachable(gr, 1, 4);
true
gap> gr := Digraph(
> [ [ 1, 3, 4, 5 ], [ ], [ 1, 3, 4, 5 ], [ 1, 3, 4, 5 ], [ 1, 3, 4, 5 ] ]);;
gap> IsTransitiveDigraph(gr);
true
gap> IsReachable(gr, 1, 2);
false
gap> IsReachable(gr, 1, 4);
true

#T# DigraphRemoveAllMultipleEdges
gap> gr1 := Digraph( [ [ 1, 1, 2, 1 ], [ 1 ] ] );
<multidigraph with 2 vertices, 5 edges>
gap> gr2 := DigraphRemoveAllMultipleEdges(gr1);
<digraph with 2 vertices, 3 edges>
gap> OutNeighbours(gr2);
[ [ 1, 2 ], [ 1 ] ]
gap> gr3 := DigraphEdgeUnion(gr1, gr1);
<multidigraph with 2 vertices, 10 edges>
gap> gr4 := DigraphRemoveAllMultipleEdges(gr3);
<digraph with 2 vertices, 3 edges>
gap> gr2 = gr4;
true

#T# OutNeighboursCopy
gap> gr := Digraph(
> [ [ 3 ], [ 10 ], [ 6 ], [ 3 ], [ 10 ], [  ], [ 6 ], [ 3 ], [  ], [ 3 ] ]);
<digraph with 10 vertices, 8 edges>
gap> out1 := OutNeighbours(gr);
[ [ 3 ], [ 10 ], [ 6 ], [ 3 ], [ 10 ], [  ], [ 6 ], [ 3 ], [  ], [ 3 ] ]
gap> IsMutable(out1);
false
gap> IsMutable(out1[1]);
false
gap> out2 := OutNeighboursCopy(gr);
[ [ 3 ], [ 10 ], [ 6 ], [ 3 ], [ 10 ], [  ], [ 6 ], [ 3 ], [  ], [ 3 ] ]
gap> IsMutable(out2);
true
gap> IsMutable(out2[1]);
true
gap> out3 := OutNeighborsCopy(gr);
[ [ 3 ], [ 10 ], [ 6 ], [ 3 ], [ 10 ], [  ], [ 6 ], [ 3 ], [  ], [ 3 ] ]
gap> IsMutable(out3);
true
gap> IsMutable(out3[1]);
true

#E#
gap> STOP_TEST( "Graphs package: oper.tst");
