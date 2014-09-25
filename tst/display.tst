#############################################################################
##
#W  display.tst
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: display.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DigraphsStartTest();

# DotDigraph for a very basic not simple digraph
gap> r := rec( vertices := [ 1 .. 3 ], source := [ 1, 1, 1, 1 ], 
> range := [ 1, 2, 2, 3 ] );;
gap> gr := DirectedGraph(r);
<directed graph with 3 vertices, 4 edges>
gap> DotDigraph(gr);
"//dot\ndigraph hgn{\nnode [shape=circle]\n1 -> 1\n1 -> 2\n1 -> 2\n1 -> 3\n}\n\
"

# DotDigraph for a more complex not simple digraph
gap> r := rec( vertices := [ 1 ..8 ], 
> source := [ 1, 1, 2, 2, 3, 4, 4, 4, 5, 5, 5, 5, 5, 6, 7, 7, 7, 7, 7, 8, 8 ],
> range :=  [ 6, 7, 1, 6, 5, 1, 4, 8, 1, 3, 6, 6, 7, 7, 1, 4, 4, 5, 7, 5, 6 ]);;
gap> gr := DirectedGraph(r);
<directed graph with 8 vertices, 21 edges>
gap> DotDigraph(gr){[1..69]};
"//dot\ndigraph hgn{\nnode [shape=circle]\n1 -> 6\n1 -> 7\n2 -> 1\n2 -> 6\n3 "

# DotDigraph & DotGraph for a small undirected simple graph
gap> adj := [ [ 2 ], [ 1, 3 ], [ 2, 3, 4 ], [ 3 ] ];
[ [ 2 ], [ 1, 3 ], [ 2, 3, 4 ], [ 3 ] ]
gap> gr := DirectedGraph(adj);
<directed graph with 4 vertices, 7 edges>
gap> DotDigraph(gr){[11..79]};
"aph hgn{\nnode [shape=circle]\n1 -> 2\n2 -> 1\n2 -> 3\n3 -> 2\n3 -> 3\n3 -> "
gap> DotGraph(gr);
"//dot\ngraph hgn{\nnode [shape=circle]\n1 -- 2\n2 -- 3\n3 -- 3\n3 -- 4\n}\n"

#
gap> DigraphsStopTest();

#
gap> STOP_TEST( "Digraphs package: display.tst", 0);
