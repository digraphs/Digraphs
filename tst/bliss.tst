#############################################################################
##
#W  bliss.tst
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: bliss.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DigraphsStartTest();

# AutomorphismGroup: all graphs of 5 vertices, compare with grape
gap> graph5:=ReadDigraphs("pkg/digraphs/data/graph5.g6");
[ <digraph with 5 vertices, 0 edges>, <digraph with 5 vertices, 2 edges>, 
  <digraph with 5 vertices, 4 edges>, <digraph with 5 vertices, 6 edges>, 
  <digraph with 5 vertices, 8 edges>, <digraph with 5 vertices, 4 edges>, 
  <digraph with 5 vertices, 6 edges>, <digraph with 5 vertices, 6 edges>, 
  <digraph with 5 vertices, 6 edges>, <digraph with 5 vertices, 8 edges>, 
  <digraph with 5 vertices, 8 edges>, <digraph with 5 vertices, 10 edges>, 
  <digraph with 5 vertices, 10 edges>, <digraph with 5 vertices, 8 edges>, 
  <digraph with 5 vertices, 10 edges>, <digraph with 5 vertices, 10 edges>, 
  <digraph with 5 vertices, 12 edges>, <digraph with 5 vertices, 12 edges>, 
  <digraph with 5 vertices, 14 edges>, <digraph with 5 vertices, 8 edges>, 
  <digraph with 5 vertices, 8 edges>, <digraph with 5 vertices, 10 edges>, 
  <digraph with 5 vertices, 12 edges>, <digraph with 5 vertices, 12 edges>, 
  <digraph with 5 vertices, 12 edges>, <digraph with 5 vertices, 14 edges>, 
  <digraph with 5 vertices, 10 edges>, <digraph with 5 vertices, 12 edges>, 
  <digraph with 5 vertices, 14 edges>, <digraph with 5 vertices, 16 edges>, 
  <digraph with 5 vertices, 14 edges>, <digraph with 5 vertices, 16 edges>, 
  <digraph with 5 vertices, 18 edges>, <digraph with 5 vertices, 20 edges> ]
gap> List(graph5, AutomorphismGroup)                                           
> = List(graph5, gr-> AutomorphismGroup(Graph(gr)));
true
gap> trees:=ReadDigraphs("pkg/digraphs/data/tree9.4.txt");
[ <digraph with 9 vertices, 8 edges>, <digraph with 9 vertices, 8 edges>, 
  <digraph with 9 vertices, 8 edges>, <digraph with 9 vertices, 8 edges>, 
  <digraph with 9 vertices, 8 edges>, <digraph with 9 vertices, 8 edges>, 
  <digraph with 9 vertices, 8 edges>, <digraph with 9 vertices, 8 edges>, 
  <digraph with 9 vertices, 8 edges>, <digraph with 9 vertices, 8 edges>, 
  <digraph with 9 vertices, 8 edges>, <digraph with 9 vertices, 8 edges>, 
  <digraph with 9 vertices, 8 edges>, <digraph with 9 vertices, 8 edges> ]
gap> List(trees, AutomorphismGroup) 
> =List(trees, gr-> AutomorphismGroup(Graph(gr))); 
true

# AutomorphismGroup: this example is broken if we use Digraphs rather than
# Graphs in the bliss code
gap> G:=PrimitiveGroup(45,3);;
gap> H:=Stabilizer(G,1);;
gap> S:=Filtered(Orbits(H,[1..45]),x->(Size(x)=4))[1];;
gap> graph:=EdgeOrbitsGraph(G,List(S,x->[1,x]));;
gap> gr:=Digraph(graph);
<digraph with 45 vertices, 180 edges>
gap> H:=AutomorphismGroup(gr);
<permutation group with 6 generators>
gap> IsomorphismGroups(G, H) <> fail;
true

# AutomorphismGroup: some random examples
gap> AutomorphismGroup(Digraph( [ ] ));
Group(())
gap> gr := Digraph( [ [ 6, 7 ], [ 6, 9 ], [ 1, 3, 4, 5, 8, 9 ], 
> [ 1, 2, 3, 4, 5, 6, 7, 10 ], [ 1, 5, 6, 7, 10 ], [ 2, 4, 5, 9, 10 ], 
> [ 3, 4, 5, 6, 7, 8, 9, 10 ], [ 1, 3, 5, 7, 8, 9 ], [ 1, 2, 5 ], 
> [ 1, 2, 4, 6, 7, 8 ] ] );;
gap> AutomorphismGroup(gr);
Group(())
gap> gr := CycleDigraph(1000);
<digraph with 1000 vertices, 1000 edges>
gap> AutomorphismGroup(gr);
<permutation group with 1 generators>
gap> Size(last);
1000

#
gap> DigraphsStopTest();

#
gap> STOP_TEST( "Digraphs package: bliss.tst", 0);
