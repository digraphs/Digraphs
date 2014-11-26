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

# Display, PrintString, String
gap> Digraph( [ ] );
<digraph with 0 vertices, 0 edges>
gap> Digraph( [ [ ] ] );
<digraph with 1 vertex, 0 edges>
gap> Digraph( [ [ 1 ] ] );
<digraph with 1 vertex, 1 edge>
gap> Digraph( [ [ 2 ], [  ] ] );
<digraph with 2 vertices, 1 edge>
gap> gr := Digraph( [ [ 1, 2 ], [ 2 ], [ ] ] );
<digraph with 3 vertices, 3 edges>
gap> PrintString(gr);
"Digraph( [ [ 1, 2 ], [ 2 ], [ ] ] )"
gap> String(gr);
"Digraph( [ [ 1, 2 ], [ 2 ], [ ] ] )"
gap> gr := Digraph( [ [ 2 ], [ 1 ], [  ], [ 3 ] ] );
<digraph with 4 vertices, 3 edges>
gap> PrintString(gr);
"Digraph( [ [ 2 ], [ 1 ], [ ], [ 3 ] ] )"
gap> String(gr);
"Digraph( [ [ 2 ], [ 1 ], [ ], [ 3 ] ] )"
gap> r := rec( vertices := [ 1, 2, 3 ], source := [ 1, 2 ], range := [ 2, 3 ] );;
gap> gr := Digraph(r);
<digraph with 3 vertices, 2 edges>
gap> PrintString(gr);
"Digraph( [ [ 2 ], [ 3 ], [ ] ] )"
gap> String(gr);
"Digraph( [ [ 2 ], [ 3 ], [ ] ] )"

# DotDigraph
gap> r := rec( vertices := [ 1 .. 3 ], source := [ 1, 1, 1, 1 ], 
> range := [ 1, 2, 2, 3 ] );;
gap> gr := Digraph(r);
<multidigraph with 3 vertices, 4 edges>
gap> dot := DotDigraph(gr);;
gap> dot{[1..50]};
"//dot\ndigraph hgn{\nnode [shape=circle]\n1\n2\n3\n1 -> "
gap> dot{[51..75]};
"1\n1 -> 2\n1 -> 2\n1 -> 3\n}\n"
gap> r := rec( vertices := [ 1 .. 8 ], 
> source := [ 1, 1, 2, 2, 3, 4, 4, 4, 5, 5, 5, 5, 5, 6, 7, 7, 7, 7, 7, 8, 8 ],
> range :=  [ 6, 7, 1, 6, 5, 1, 4, 8, 1, 3, 6, 6, 7, 7, 1, 4, 4, 5, 7, 5, 6 ]);;
gap> gr := Digraph(r);
<multidigraph with 8 vertices, 21 edges>
gap> DotDigraph(gr){[50..109]};
"6\n7\n8\n1 -> 6\n1 -> 7\n2 -> 1\n2 -> 6\n3 -> 5\n4 -> 1\n4 -> 4\n4 -> "
gap> DotSymmetricDigraph(gr);
Error, Digraphs: DotSymmetricDigraph: usage,
the argument <graph> should be symmetric,
gap> adj := [ [ 2 ], [ 1, 3 ], [ 2, 3, 4 ], [ 3 ] ];
[ [ 2 ], [ 1, 3 ], [ 2, 3, 4 ], [ 3 ] ]
gap> gr := Digraph(adj);
<digraph with 4 vertices, 7 edges>
gap> DotDigraph(gr){[ 11 .. 75 ]};
"aph hgn{\nnode [shape=circle]\n1\n2\n3\n4\n1 -> 2\n2 -> 1\n2 -> 3\n3 -> 2\n"

# DotSymmetricDigraph
gap> DotSymmetricDigraph(gr){[ 12 .. 70 ]};
" hgn{\nnode [shape=circle]\n\n1\n2\n3\n4\n1 -- 2\n2 -- 3\n3 -- 3\n3 -"

#
gap> STOP_TEST( "Digraphs package: display.tst");
