#############################################################################
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

# DigraphReverse (for a digraph by adjacency)
gap> gr := Digraph(
> [ [ 3 ], [ 1, 3, 5 ], [ 1 ], [ 1, 2, 4 ], [ 2, 3, 5 ] ]);
<digraph with 5 vertices, 11 edges>
gap> rgr := DigraphReverse(gr);
<digraph with 5 vertices, 11 edges>
gap> OutNeighbours(rgr);
[ [ 2, 3, 4 ], [ 4, 5 ], [ 1, 2, 5 ], [ 4 ], [ 2, 5 ] ]
gap> gr = DigraphReverse(rgr);
true

# DigraphReverse (for a digraph with source)
gap> gr := Digraph( rec ( nrvertices := 5,
> source := [ 1, 1, 2, 2, 2, 2, 2, 3, 4, 4, 4, 5, 5, 5 ],
> range  := [ 1, 3, 1, 2, 2, 4, 5, 4, 1, 3, 5, 1, 1, 3 ] ) );
<multidigraph with 5 vertices, 14 edges>
gap> e := DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 3 ], [ 2, 1 ], [ 2, 2 ], [ 2, 2 ], [ 2, 4 ], [ 2, 5 ], 
  [ 3, 4 ], [ 4, 1 ], [ 4, 3 ], [ 4, 5 ], [ 5, 1 ], [ 5, 1 ], [ 5, 3 ] ]
gap> rev := DigraphReverse(gr);
<multidigraph with 5 vertices, 14 edges>
gap> erev := DigraphEdges(rev);
[ [ 1, 1 ], [ 1, 2 ], [ 1, 5 ], [ 1, 4 ], [ 1, 5 ], [ 2, 2 ], [ 2, 2 ], 
  [ 3, 1 ], [ 3, 4 ], [ 3, 5 ], [ 4, 3 ], [ 4, 2 ], [ 5, 2 ], [ 5, 4 ] ]
gap> temp := List( erev, x -> [ x[2], x[1] ] );;
gap> Sort(temp);
gap> e = temp;
true

# DigraphTransitiveClosure & DigraphReflexiveTransitiveClosure
gap> gr := Digraph( 
> rec( nrvertices := 2, source := [ 1, 1 ], range := [ 2, 2 ] ) );
<multidigraph with 2 vertices, 2 edges>
gap> DigraphReflexiveTransitiveClosure(gr);
Error, Digraphs: DigraphReflexiveTransitiveClosure: usage,
the argument <graph> cannot have multiple edges,

gap> DigraphTransitiveClosure(gr);
Error, Digraphs: DigraphTransitiveClosure: usage,
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

# DigraphRemoveLoops (for a digraph by adjacency)
gap> adj := [ [ 1, 2 ], [ 3, 2 ], [ 1, 2 ], [ 4 ],  [ ], [ 1, 2, 3, 6 ] ];
[ [ 1, 2 ], [ 3, 2 ], [ 1, 2 ], [ 4 ], [  ], [ 1, 2, 3, 6 ] ]
gap> gr := Digraph(adj);
<digraph with 6 vertices, 11 edges>
gap> DigraphRemoveLoops(gr);
<digraph with 6 vertices, 7 edges>

# DigraphRemoveLoops (for a digraph by source and range)
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

# DigraphRemoveEdges (by index)
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

# DigraphRemoveEdges (by list of edges)
gap> gr := Digraph( [ [ 2 ], [  ] ] );
<digraph with 2 vertices, 1 edge>
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
Error, Digraphs: DigraphRemoveEdges: usage,
the first argument <graph> must not have multiple edges
when the second argument <edges> is a list of edges,


# OnDigraphs (for a digraph by adjacency and perm)
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
Error, Digraphs: OnDigraphs: usage,
the 2nd argument <perm> must permute the vertices of the 1st argument <graph>,

gap> gr := Digraph( [ [ 1, 1, 1, 3, 5 ], [ ], [ 3, 2, 4, 5 ], [ 2, 5 ], [ 1, 2, 1 ] ] );
<multidigraph with 5 vertices, 14 edges>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 1 ], [ 1, 1 ], [ 1, 3 ], [ 1, 5 ], [ 3, 3 ], [ 3, 2 ], 
  [ 3, 4 ], [ 3, 5 ], [ 4, 2 ], [ 4, 5 ], [ 5, 1 ], [ 5, 2 ], [ 5, 1 ] ]
gap> p1 := (2,4)(3,6,5);
(2,4)(3,6,5)
gap> OnDigraphs(gr, p1);
Error, Digraphs: OnDigraphs: usage,
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
Error, Digraphs: OnDigraphs: usage,
the 2nd argument <perm> must permute the vertices of the 1st argument <graph>,

gap> p2 := (1,4)(2,3);
(1,4)(2,3)
gap> OnDigraphs(gr, p2);
<multidigraph with 4 vertices, 8 edges>
gap> DigraphEdges(last);
[ [ 1, 2 ], [ 1, 4 ], [ 2, 2 ], [ 3, 4 ], [ 3, 1 ], [ 3, 1 ], [ 4, 3 ], 
  [ 4, 2 ] ]

# InNeighboursOfVeretx, InDegreeOfVertex
gap> gr := Digraph( rec( nrvertices := 10, source := [ 1, 1, 5, 5, 7, 10 ],
> range := [ 3, 3, 1, 10, 7, 1 ] ) );
<multidigraph with 10 vertices, 6 edges>
gap> InNeighboursOfVertex(gr, 7);
[ 7 ]
gap> InDegreeOfVertex(gr, 7);
1
gap> InNeighboursOfVertex(gr, 11);
Error, Digraphs: InNeighboursOfVertex: usage,
11 is not a vertex of the digraph,

gap> InDegreeOfVertex(gr, 11);
Error, Digraphs: InDegreeOfVertex: usage,
11 is not a vertex of the digraph,

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

# OutNeighboursOfVeretx, OutDegreeOfVertex
gap> gr := Digraph( rec( nrvertices := 10, source := [ 1, 5, 5, 5, 5, 5, 5, 6 ],
> range := [ 1, 1, 2, 3, 1, 2, 3, 6 ] ) );
<multidigraph with 10 vertices, 8 edges>
gap> OutNeighboursOfVertex(gr, 2);
[  ]
gap> OutDegreeOfVertex(gr, 2);
0
gap> OutNeighboursOfVertex(gr, 5);
[ 1, 2, 3, 1, 2, 3 ]
gap> OutDegreeOfVertex(gr, 5);
6
gap> OutNeighboursOfVertex(gr, 12);
Error, Digraphs: OutNeighboursOfVertex: usage,
12 is not a vertex of the digraph,

gap> OutDegreeOfVertex(gr, 12);
Error, Digraphs: OutDegreeOfVertex: usage,
12 is not a vertex of the digraph,

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

# InducedSubdigraph (source and range version)
gap> r := rec( nrvertices := 8,
> source := [ 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 5, 5, 5, 5, 5, 5 ],
> range  := [ 1, 1, 2, 3, 3, 4, 1, 1, 3, 4, 5, 1, 3, 4, 4, 5, 7 ] );
rec( nrvertices := 8, 
  range := [ 1, 1, 2, 3, 3, 4, 1, 1, 3, 4, 5, 1, 3, 4, 4, 5, 7 ], 
  source := [ 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 5, 5, 5, 5, 5, 5 ] )
gap> gr := Digraph(r);
<multidigraph with 8 vertices, 17 edges>
gap> InducedSubdigraph( gr, [ -1 ] );
Error, Digraphs: InducedSubdigraph: usage,
the second argument <subverts> must be a duplicate-free subset
of the vertices of the first argument <digraph>,

gap> InducedSubdigraph( gr, [ 1 .. 9 ] );
Error, Digraphs: InducedSubdigraph: usage,
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
[ [ 1, 1, 2, 2, 3 ], [ 3 ], [  ] ]
gap> i2 := InducedSubdigraph( gr, [ 3, 4, 3, 1 ] );
Error, Digraphs: InducedSubdigraph: usage,
the second argument <subverts> must be a duplicate-free subset
of the vertices of the first argument <digraph>,


# InducedSubdigraph (OutNeighbours version)
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
Error, Digraphs: InducedSubdigraph: usage,
the second argument <subverts> must be a duplicate-free subset
of the vertices of the first argument <digraph>,

gap> InducedSubdigraph( gr, [ 0 ] );
Error, Digraphs: InducedSubdigraph: usage,
the second argument <subverts> must be a duplicate-free subset
of the vertices of the first argument <digraph>,

gap> InducedSubdigraph( gr, [ 2 .. 9 ] );
Error, Digraphs: InducedSubdigraph: usage,
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
true
gap> InducedSubdigraph( gr, [ 2 .. 8 ] );
<multidigraph with 7 vertices, 15 edges>
gap> InducedSubdigraph( gr, [ 8 ] );
<digraph with 1 vertex, 0 edges>
gap> InducedSubdigraph( gr, [ 7, 8 ] );
<digraph with 2 vertices, 0 edges>

# QuotientDigraph
gap> gr := CompleteDigraph(2);
<digraph with 2 vertices, 4 edges>
gap> DigraphEdges(gr);
[ [ 1, 1 ], [ 1, 2 ], [ 2, 1 ], [ 2, 2 ] ]
gap> qr := QuotientDigraph( gr, [ [ 1, 2 ] ] );
<multidigraph with 1 vertex, 4 edges>
gap> DigraphEdges(qr);
[ [ 1, 1 ], [ 1, 1 ], [ 1, 1 ], [ 1, 1 ] ]
gap> QuotientDigraph( EmptyDigraph(0), [ ] );
Error, Digraphs: QuotientDigraph: usage,
the first argument <digraph> must have at least one vertex,

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
gap> QuotientDigraph( gr, [ ] );
Error, Digraphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],

gap> QuotientDigraph( gr, [ [ ], [ ] ] );
Error, Digraphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],

gap> QuotientDigraph( gr, [ [ 0 ], [ 1 ] ] );
Error, Digraphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],

gap> QuotientDigraph( gr, [ [ 1 ], [ 2 ], [ 0 ] ] );
Error, Digraphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],

gap> QuotientDigraph( gr, [ [ 1 ], [ 2, 4 ] ] );
Error, Digraphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],

gap> QuotientDigraph( gr, [ [ 1, 2 ], [ 2 ] ] );
Error, Digraphs: QuotientDigraph: usage,
the second argument <partition> is not a valid partition
of the vertices of <digraph>, [ 1 .. 3 ],

gap> QuotientDigraph( gr, [ [ 1 ], [ 2 ] ] );
Error, Digraphs: QuotientDigraph: usage,
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
[ [ 3, 2 ], [ 1, 3, 2, 2, 3, 3, 1, 3, 1, 3, 2, 2, 2 ], [ 1, 3, 2, 3, 2, 3 ] ]

# DigraphInEdges / DigraphOutEdges
gap> gr := Digraph( [ [ 2, 2, 2, 2, 2 ], [ 1, 1, 1, 1 ], [ 1 ], [ 3, 2 ] ] );
<multidigraph with 4 vertices, 12 edges>
gap> DigraphInEdges(gr, 1);
[ [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 3, 1 ] ]
gap> DigraphOutEdges(gr, 3);
[ [ 3, 1 ] ]
gap> DigraphOutEdges(gr, 5);
Error, Digraphs: DigraphOutEdges: usage,
5 is not a vertex of the digraph,

gap> DigraphInEdges(gr, 1000);
Error, Digraphs: DigraphInEdges: usage,
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

# DigraphStronglyConnectedComponent
gap> gr := Digraph( [ [ 2, 4 ], [ ], [ 2, 6 ], [ 1, 3 ], [ 2, 3 ], [ 5 ] ] );
<digraph with 6 vertices, 9 edges>
gap> DigraphStronglyConnectedComponent(gr, 1);
[ 1, 4 ]
gap> DigraphStronglyConnectedComponent(gr, 2);
[ 2 ]
gap> DigraphStronglyConnectedComponent(gr, 3);
[ 3, 6, 5 ]
gap> DigraphStronglyConnectedComponent(gr, 7);
Error, Digraphs: DigraphStronglyConnectedComponent: usage,
7 is not a vertex of the digraph,


# DigraphAddEdges
gap> gr := RandomDigraph(100);;
gap> DigraphAddEdges(gr, [ ]);;
gap> gr = last;
true
gap> DigraphAddEdges(gr, [ 12 ] );
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of edges of <graph>,
i.e. a list of pairs of vertices of <graph>,

gap> DigraphAddEdges(gr, [ [ 12 ] ] );
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of edges of <graph>,
i.e. a list of pairs of vertices of <graph>,

gap> DigraphAddEdges(gr, [ [ 12, 13, 14 ], [ 11, 10 ] ] );
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of edges of <graph>,
i.e. a list of pairs of vertices of <graph>,

gap> DigraphAddEdges(gr, [ [ -2, 3 ], [ "a" ] ] );
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of edges of <graph>,
i.e. a list of pairs of vertices of <graph>,

gap> DigraphAddEdges(gr, [ [ 11, 10 ], [ 12, 13, 14 ] ] );
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of edges of <graph>,
i.e. a list of pairs of vertices of <graph>,

gap> DigraphAddEdges(gr, [ [ 4, 5 ], [ 1, 120 ], [ 1, 1 ] ] );
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of edges with
source and range amongst the vertices of <graph>,

gap> DigraphAddEdges(gr, [ [ 4, 5 ], [ 120, 1 ], [ 1, 1 ] ] );
Error, Digraphs: DigraphAddEdges: usage,
the second argument <edges> must be a list of edges with
source and range amongst the vertices of <graph>,

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

#
gap> DigraphsStopTest();

#
gap> STOP_TEST( "Digraphs package: attrs.tst", 0);
