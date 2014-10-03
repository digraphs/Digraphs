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
gap> Adjacencies(DigraphDual(gr));
[ [ 1, 2, 3, 4, 5, 8, 9, 10 ], [ 1, 2, 3, 4, 5, 7, 8, 10 ], [ 2, 6, 7, 10 ], 
  [ 8, 9 ], [ 2, 3, 4, 8, 9 ], [ 1, 3, 6, 7, 8 ], [ 1, 2 ], [ 2, 4, 6, 10 ], 
  [ 3, 4, 6, 7, 8, 9, 10 ], [ 3, 5, 9, 10 ] ]
gap> gr:=Digraph(rec(vertices:=["a", "b"], 
> source:=["b", "b"], range:=["a", "a"]));    
<digraph with 2 vertices, 2 edges>
gap> DigraphDual(gr);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphDual' on 1 arguments
gap> gr:=Digraph([]);                  
<digraph with 0 vertices, 0 edges>
gap> DigraphDual(gr);
<digraph with 0 vertices, 0 edges>

# AdjacencyMatrix
gap> gr:=Digraph(rec(vertices:=[1..10], 
> source:=[1,1,1,1,1,1,1,1], range:=[2,2,3,3,4,4,5,5]));
<digraph with 10 vertices, 8 edges>
gap> AdjacencyMatrix(gr);
[ [ 0, 2, 2, 2, 2, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ]

# AdjacencyMatrix, testing before and after getting IsSimple and Adjacencies
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
gap> IsSimpleDigraph(gr);
true
gap> Adjacencies(gr);
[ [ 3, 4 ], [ 2, 4 ], [ 6 ], [ 6, 7 ], [ 2 ], [ 7 ], [ 5 ] ]
gap> adj2 := AdjacencyMatrix(gr);
[ [ 0, 0, 1, 1, 0, 0, 0 ], [ 0, 1, 0, 1, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 1, 0 ], 
  [ 0, 0, 0, 0, 0, 1, 1 ], [ 0, 1, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 1 ], 
  [ 0, 0, 0, 0, 1, 0, 0 ] ]
gap> adj1 = adj2;
true

# AdjacencyMatrix, testing before and after getting IsSimple and Adjacencies
# (with a not simple digraph)
gap> r:=rec(vertices:=[1..1], source:=[1,1], range:=[1,1]);
rec( range := [ 1, 1 ], source := [ 1, 1 ], vertices := [ 1 ] )
gap> gr := Digraph(r);
<digraph with 1 vertices, 2 edges>
gap> adj1 := AdjacencyMatrix(gr);
[ [ 2 ] ]
gap> gr := Digraph(r);
<digraph with 1 vertices, 2 edges>
gap> IsSimpleDigraph(gr);
false
gap> adj2 := AdjacencyMatrix(gr);
[ [ 2 ] ]
gap> adj1 = adj2;
true

#
gap> DigraphsStopTest();

#
gap> STOP_TEST( "Digraphs package: attrs.tst", 0);
