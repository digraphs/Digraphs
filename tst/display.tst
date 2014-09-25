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

# DotDigraph
gap> s:=rec( vertices:=[1..3],source:=[1,1,1,1], range:=[1,2,2,3] );;
gap> ss:=DirectedGraph(s);
<directed graph with 3 vertices, 4 edges>
gap> DotDigraph(ss);
"//dot\ndigraph hgn{\nnode [shape=circle]\n1 -> 1\n1 -> 2\n1 -> 2\n1 -> 3\n}\n\
"

#
gap> DigraphsStopTest();

#
gap> STOP_TEST( "Digraphs package: display.tst", 0);
