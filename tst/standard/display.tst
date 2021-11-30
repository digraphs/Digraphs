#############################################################################
##
#W  standard/display.tst
#Y  Copyright (C) 2014-15                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/display.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#  Display and PrintString and String
gap> Digraph([]);
<immutable empty digraph with 0 vertices>
gap> Digraph([[]]);
<immutable empty digraph with 1 vertex>
gap> Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> Digraph([[2], []]);
<immutable digraph with 2 vertices, 1 edge>
gap> gr := Digraph([[1, 2], [2], []]);
<immutable digraph with 3 vertices, 3 edges>
gap> PrintString(gr);
"DigraphFromDigraph6String(\"&Bq?\")"
gap> String(gr);
"DigraphFromDigraph6String(\"&Bq?\")"
gap> gr := Digraph([[2], [1], [], [3]]);
<immutable digraph with 4 vertices, 3 edges>
gap> PrintString(gr);
"DigraphFromDigraph6String(\"&CQ?G\")"
gap> String(gr);
"DigraphFromDigraph6String(\"&CQ?G\")"
gap> r := rec(DigraphVertices := [1, 2, 3], 
>             DigraphSource := [1, 2], 
>             DigraphRange := [2, 3]);;
gap> gr := Digraph(r);
<immutable digraph with 3 vertices, 2 edges>
gap> PrintString(gr);
"ChainDigraph(3)"
gap> String(gr);
"ChainDigraph(3)"

#  DotDigraph and DotSymmetricDigraph
gap> r := rec(DigraphVertices := [1 .. 3], DigraphSource := [1, 1, 1, 1],
> DigraphRange := [1, 2, 2, 3]);;
gap> gr := Digraph(r);
<immutable multidigraph with 3 vertices, 4 edges>
gap> dot := DotDigraph(gr);;
gap> dot{[1 .. 50]};
"//dot\ndigraph hgn{\nnode [shape=circle]\n1\n2\n3\n1 -> "
gap> dot{[51 .. 75]};
"1\n1 -> 2\n1 -> 2\n1 -> 3\n}\n"
gap> r := rec(DigraphVertices := [1 .. 8],
> DigraphSource := [1, 1, 2, 2, 3, 4, 4, 4, 5, 5, 5, 5, 5, 6, 7, 7, 7, 7, 7, 8,
>                   8],
> DigraphRange  := [6, 7, 1, 6, 5, 1, 4, 8, 1, 3, 6, 6, 7, 7, 1, 4, 4, 5, 7, 5,
>                   6]);;
gap> gr1 := Digraph(r);
<immutable multidigraph with 8 vertices, 21 edges>
gap> DotDigraph(gr1){[50 .. 109]};
"6\n7\n8\n1 -> 6\n1 -> 7\n2 -> 1\n2 -> 6\n3 -> 5\n4 -> 1\n4 -> 4\n4 -> "
gap> adj := [[2], [1, 3], [2, 3, 4], [3]];
[ [ 2 ], [ 1, 3 ], [ 2, 3, 4 ], [ 3 ] ]
gap> gr2 := Digraph(adj);
<immutable digraph with 4 vertices, 7 edges>
gap> DotDigraph(gr2){[11 .. 75]};
"aph hgn{\nnode [shape=circle]\n1\n2\n3\n4\n1 -> 2\n2 -> 1\n2 -> 3\n3 -> 2\n"
gap> DotSymmetricDigraph(gr2){[12 .. 70]};
" hgn{\nnode [shape=circle]\n\n1\n2\n3\n4\n1 -- 2\n2 -- 3\n3 -- 3\n3 -"
gap> DotSymmetricDigraph(gr1);
Error, the argument <D> must be a symmetric digraph,

#DotColoredDigraph and DotSymmetriColoredDigraph
gap> D := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> vertcolors := [];;
gap> vertcolors[1] := "blue";; vertcolors[2] := "red";; 
gap> vertcolors[3] := "green";; vertcolors[4] := "yellow";;
gap> edgecolors := [];;
gap> edgecolors[1] := [];; edgecolors[2] := [];;
gap> edgecolors[3] := [];; edgecolors[4] := [];; 
gap> edgecolors[1][1] := "lightblue";;
gap> edgecolors[1][2] := "pink";;
gap> edgecolors[1][3] := "purple";;
gap> edgecolors[2][1] := "lightblue";;
gap> edgecolors[2][2] := "pink";; 
gap> edgecolors[2][3] := "purple";; 
gap> edgecolors[3][1] := "lightblue";; 
gap> edgecolors[3][2] := "pink";; 
gap> edgecolors[3][3] := "purple";;
gap> edgecolors[4][1] := "lightblue";; 
gap> edgecolors[4][2] := "pink";;
gap> edgecolors[4][3] := "purple";;
gap> DotColoredDigraph(D, vertcolors, edgecolors){[1 .. 30]};
"//dot\ndigraph hgn{\nnode [shape"
gap> D := Digraph([[2], [1, 3], [2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> vertcolors := [];;
gap> vertcolors[1] := "blue";;
gap> vertcolors[2] := "pink";;
gap> vertcolors[3] := "purple";;
gap> edgecolors := [];;
gap> edgecolors[1] := [];; edgecolors[2] := [];;
gap> edgecolors[3] := [];;
gap> edgecolors[1][1] := "green";;
gap> edgecolors[2][1] := "green";;
gap> edgecolors[3][1] := "red";; edgecolors[2][2] := "red";;
gap> DotSymmetricColoredDigraph(D, vertcolors, edgecolors);
"//dot\ngraph hgn{\nnode [shape=circle]\n\n1[color=blue, style=filled]\n2[colo\
r=pink, style=filled]\n3[color=purple, style=filled]\n1 -- 2[color=green]\n2 -\
- 3[color=red]\n}\n"
gap> D := Digraph([[2, 3], [1, 3], [1]]);
<immutable digraph with 3 vertices, 5 edges>
gap> vertcolors := [];;
gap> vertcolors[1] := "blue";; vertcolors[2] := "red";;
gap> vertcolors[3] := "green";;
gap> edgecolors := [];;
gap> edgecolors[1] := [];; edgecolors[2] := [];;
gap> edgecolors[3] := [];;
gap> edgecolors[1][1] := "orange";; edgecolors[1][2] := "yellow";;
gap> edgecolors[2][1] := "orange";; edgecolors[2][2] := "pink";;
gap> edgecolors[3][1] := "yellow";;
gap> DotColoredDigraph(D, vertcolors, edgecolors);
"//dot\ndigraph hgn{\nnode [shape=circle]\n1[color=blue, style=filled]\n2[colo\
r=red, style=filled]\n3[color=green, style=filled]\n1 -> 2[color=orange]\n1 ->\
 3[color=yellow]\n2 -> 1[color=orange]\n2 -> 3[color=pink]\n3 -> 1[color=yello\
w]\n}\n"
gap> D := Digraph(IsMutableDigraph, [[2, 3], [1, 3], [1]]);
<mutable digraph with 3 vertices, 5 edges>
gap> vertcolors := [];;
gap> vertcolors[1] := "blue";; vertcolors[2] := "red";;
gap> vertcolors[3] := "green";;
gap> edgecolors := [];;
gap> edgecolors[1] := [];; edgecolors[2] := [];;
gap> edgecolors[3] := [];;
gap> edgecolors[1][1] := "orange";; edgecolors[1][2] := "yellow";;
gap> edgecolors[2][1] := "orange";; edgecolors[2][2] := "pink";;
gap> edgecolors[3][1] := "yellow";;
gap> DotColoredDigraph(D, vertcolors, edgecolors);;
gap> D;
<mutable digraph with 3 vertices, 5 edges>
gap> D := Digraph([[2, 4], [1, 3], [2], [1]]);
<immutable digraph with 4 vertices, 6 edges>
gap> vertcolors := [];;
gap> vertcolors[1] := "blue";; vertcolors[2] := "red";;
gap> vertcolors[3] := "green";; vertcolors[4] := "yellow";;
gap> edgecolors := [];;
gap> edgecolors[1] := [];; edgecolors[2] := [];;
gap> edgecolors[3] := [];; edgecolors[4] := [];;
gap> edgecolors[1][1] := "orange";; edgecolors[1][2] := "orange";;
gap> edgecolors[2][1] := "orange";; edgecolors[2][2] := "orange";;
gap> edgecolors[3][1] := "orange";; edgecolors[4][1] := "orange";;
gap> DotSymmetricColoredDigraph(D, vertcolors, edgecolors);
"//dot\ngraph hgn{\nnode [shape=circle]\n\n1[color=blue, style=filled]\n2[colo\
r=red, style=filled]\n3[color=green, style=filled]\n4[color=yellow, style=fill\
ed]\n1 -- 2[color=orange]\n1 -- 4[color=orange]\n2 -- 3[color=orange]\n}\n"
gap> D := Digraph(IsMutableDigraph, [[2, 4], [1, 3], [2], [1]]);
<mutable digraph with 4 vertices, 6 edges>
gap> vertcolors := [];;
gap> vertcolors[1] := "blue";; vertcolors[2] := "red";;
gap> vertcolors[3] := "green";; vertcolors[4] := "yellow";;
gap> edgecolors := [];;
gap> edgecolors[1] := [];; edgecolors[2] := [];;
gap> edgecolors[3] := [];; edgecolors[4] := [];;
gap> edgecolors[1][1] := "orange";; edgecolors[1][2] := "orange";;
gap> edgecolors[2][1] := "orange";; edgecolors[2][2] := "orange";;
gap> edgecolors[3][1] := "orange";; edgecolors[4][1] := "orange";;
gap> DotSymmetricColoredDigraph(D, vertcolors, edgecolors);
"//dot\ngraph hgn{\nnode [shape=circle]\n\n1[color=blue, style=filled]\n2[colo\
r=red, style=filled]\n3[color=green, style=filled]\n4[color=yellow, style=fill\
ed]\n1 -- 2[color=orange]\n1 -- 4[color=orange]\n2 -- 3[color=orange]\n}\n"
gap> D;
<mutable digraph with 4 vertices, 6 edges>
gap> D := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> vertcolors := [];;
gap> vertcolors[1] := "blue";; vertcolors[2] := "banana";; 
gap> vertcolors[3] := "green";; vertcolors[4] := "yellow";;
gap> edgecolors := [];;
gap> edgecolors[1] := [];; edgecolors[2] := [];;
gap> edgecolors[3] := [];; edgecolors[4] := [];; 
gap> edgecolors[1][1] := "lightblue";;
gap> edgecolors[1][2] := "pink";;
gap> edgecolors[1][3] := "purple";;
gap> edgecolors[2][1] := "lightblue";;
gap> edgecolors[2][2] := "pink";; 
gap> edgecolors[2][3] := "purple";; 
gap> edgecolors[3][1] := "lightblue";; 
gap> edgecolors[3][2] := "pink";; 
gap> edgecolors[3][3] := "purple";;
gap> edgecolors[4][1] := "lightblue";; 
gap> edgecolors[4][2] := "pink";;
gap> edgecolors[4][3] := "purple";;
gap> DotColoredDigraph(D, vertcolors, edgecolors){[5 .. 35]};
Error, expected RGB Value or valid color name as defined by GraphViz 2.44.1 X1\
1 Color Scheme http://graphviz.org/doc/info/colors.html
gap> D := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> vertcolors := [];;
gap> vertcolors[1] := "blue";; vertcolors[2] := "red";; 
gap> vertcolors[3] := "green";;
gap> edgecolors := [];;
gap> edgecolors[1] := [];; edgecolors[2] := [];;
gap> edgecolors[3] := [];; edgecolors[4] := [];; 
gap> edgecolors[1][1] := "lightblue";;
gap> edgecolors[1][2] := "pink";;
gap> edgecolors[1][3] := "purple";;
gap> edgecolors[2][1] := "lightblue";;
gap> edgecolors[2][2] := "pink";; 
gap> edgecolors[2][3] := "purple";; 
gap> edgecolors[3][1] := "lightblue";; 
gap> edgecolors[3][2] := "pink";; 
gap> edgecolors[3][3] := "purple";;
gap> edgecolors[4][1] := "lightblue";; 
gap> edgecolors[4][2] := "pink";;
gap> edgecolors[4][3] := "purple";;
gap> DotColoredDigraph(D, vertcolors, edgecolors);
Error, the number of vertex colors must be the same as the number of vertices,\
 expected 4 but found 3
gap> D := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> vertcolors := [];;
gap> vertcolors[1] := 2;; vertcolors[2] := 1;; 
gap> vertcolors[3] := 1;; vertcolors[4] := 3;;
gap> edgecolors := [];;
gap> edgecolors[1] := [];; edgecolors[2] := [];;
gap> edgecolors[3] := [];; edgecolors[4] := [];; 
gap> edgecolors[1][1] := "lightblue";;
gap> edgecolors[1][2] := "pink";;
gap> edgecolors[1][3] := "purple";;
gap> edgecolors[2][1] := "lightblue";;
gap> edgecolors[2][2] := "pink";; 
gap> edgecolors[2][3] := "purple";; 
gap> edgecolors[3][1] := "lightblue";; 
gap> edgecolors[3][2] := "pink";; 
gap> edgecolors[3][3] := "purple";;
gap> edgecolors[4][1] := "lightblue";; 
gap> edgecolors[4][2] := "pink";;
gap> edgecolors[4][3] := "purple";;
gap> DotColoredDigraph(D, vertcolors, edgecolors);
Error, expected a string
gap> D := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> vertcolors := [];;
gap> vertcolors[1] := "#AB3487";; vertcolors[2] := "#DF4738";; 
gap> vertcolors[3] := "#4BF234";; vertcolors[4] := "#AF34C9";;
gap> edgecolors := [];;
gap> edgecolors[1] := [];; edgecolors[2] := [];;
gap> edgecolors[3] := [];; edgecolors[4] := [];; 
gap> edgecolors[1][1] := "lightblue";;
gap> edgecolors[1][2] := "pink";;
gap> edgecolors[1][3] := "purple";;
gap> edgecolors[2][1] := "lightblue";;
gap> edgecolors[2][2] := "pink";; 
gap> edgecolors[2][3] := "purple";; 
gap> edgecolors[3][1] := "lightblue";; 
gap> edgecolors[3][2] := "pink";; 
gap> edgecolors[3][3] := "purple";;
gap> edgecolors[4][1] := "lightblue";; 
gap> edgecolors[4][2] := "pink";;
gap> edgecolors[4][3] := "purple";;
gap> DotColoredDigraph(D, vertcolors, edgecolors);
"//dot\ndigraph hgn{\nnode [shape=circle]\n1[color=#AB3487, style=filled]\n2[c\
olor=#DF4738, style=filled]\n3[color=#4BF234, style=filled]\n4[color=#AF34C9, \
style=filled]\n1 -> 2[color=lightblue]\n1 -> 3[color=pink]\n1 -> 4[color=purpl\
e]\n2 -> 1[color=lightblue]\n2 -> 3[color=pink]\n2 -> 4[color=purple]\n3 -> 1[\
color=lightblue]\n3 -> 2[color=pink]\n3 -> 4[color=purple]\n4 -> 1[color=light\
blue]\n4 -> 2[color=pink]\n4 -> 3[color=purple]\n}\n"
gap> D := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> vertcolors := [];;
gap> vertcolors[1] := "blue";; vertcolors[2] := "red";; 
gap> vertcolors[3] := "green";; vertcolors[4] := "yellow";;
gap> edgecolors := [];;
gap> edgecolors[1] := [];; edgecolors[2] := [];;
gap> edgecolors[3] := [];; edgecolors[4] := [];; 
gap> edgecolors[1][1] := "banana";;
gap> edgecolors[1][2] := "pink";;
gap> edgecolors[1][3] := "purple";;
gap> edgecolors[2][1] := "lightblue";;
gap> edgecolors[2][2] := "pink";; 
gap> edgecolors[2][3] := "purple";; 
gap> edgecolors[3][1] := "cherry";; 
gap> edgecolors[3][2] := "pink";; 
gap> edgecolors[3][3] := "purple";;
gap> edgecolors[4][1] := "lightblue";; 
gap> edgecolors[4][2] := "pink";;
gap> edgecolors[4][3] := "purple";;
gap> DotColoredDigraph(D, vertcolors, edgecolors);
Error, expected RGB Value or valid color name as defined by GraphViz 2.44.1 X1\
1 Color Scheme http://graphviz.org/doc/info/colors.html
gap> D := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> vertcolors := [];;
gap> vertcolors[1] := "blue";; vertcolors[2] := "red";; 
gap> vertcolors[3] := "green";; vertcolors[4] := "yellow";;
gap> edgecolors := [];;
gap> edgecolors[1] := [];; edgecolors[2] := [];;
gap> edgecolors[3] := [];; edgecolors[4] := [];; 
gap> edgecolors[1][1] := "lightblue";;
gap> edgecolors[1][2] := "pink";;
gap> edgecolors[1][3] := "purple";;
gap> edgecolors[2][1] := "lightblue";;
gap> edgecolors[2][2] := "pink";; 
gap> edgecolors[2][3] := "purple";; 
gap> edgecolors[3][1] := "lightblue";; 
gap> edgecolors[3][2] := "pink";; 
gap> edgecolors[3][3] := "purple";;
gap> edgecolors[4][1] := "lightblue";; 
gap> edgecolors[4][2] := "pink";;
gap> DotColoredDigraph(D, vertcolors, edgecolors);
Error, the list of edge colors needs to have the same shape as the out-neighbo\
urs of the digraph

# DotVertexColoredDigraph
gap> D := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> vertcolors := [];;
gap> vertcolors[1] := "blue";; vertcolors[2] := "red";; 
gap> vertcolors[3] := "green";; vertcolors[4] := "yellow";;
gap> Print(DotVertexColoredDigraph(D, vertcolors));
//dot
digraph hgn{
node [shape=circle]
1[color=blue, style=filled]
2[color=red, style=filled]
3[color=green, style=filled]
4[color=yellow, style=filled]
1 -> 2
1 -> 3
1 -> 4
2 -> 1
2 -> 3
2 -> 4
3 -> 1
3 -> 2
3 -> 4
4 -> 1
4 -> 2
4 -> 3
}
gap> D := EmptyDigraph(3);
<immutable empty digraph with 3 vertices>
gap> vertcolors := [];;
gap> vertcolors[1] := "blue";; vertcolors[2] := "red";;
gap> vertcolors[3] := "green";;
gap> edgecolors := [];;
gap> edgecolors[1] := [];; edgecolors[2] := [];; 
gap> edgecolors[3] := [];;
gap> DotVertexColoredDigraph(D, vertcolors);
"//dot\ndigraph hgn{\nnode [shape=circle]\n1[color=blue, style=filled]\n2[colo\
r=red, style=filled]\n3[color=green, style=filled]\n}\n"

# DotEdgeColoredDigraph
gap> D := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> edgecolors := [];;
gap> edgecolors[1] := [];; edgecolors[2] := [];;
gap> edgecolors[3] := [];; edgecolors[4] := [];; 
gap> edgecolors[1][1] := "lightblue";;
gap> edgecolors[1][2] := "pink";;
gap> edgecolors[1][3] := "purple";;
gap> edgecolors[2][1] := "lightblue";;
gap> edgecolors[2][2] := "pink";; 
gap> edgecolors[2][3] := "purple";; 
gap> edgecolors[3][1] := "lightblue";; 
gap> edgecolors[3][2] := "pink";; 
gap> edgecolors[3][3] := "purple";;
gap> edgecolors[4][1] := "lightblue";; 
gap> edgecolors[4][2] := "pink";;
gap> edgecolors[4][3] := "purple";;
gap> DotEdgeColoredDigraph(D, edgecolors);
"//dot\ndigraph hgn{\nnode [shape=circle]\n1\n2\n3\n4\n1 -> 2[color=lightblue]\
\n1 -> 3[color=pink]\n1 -> 4[color=purple]\n2 -> 1[color=lightblue]\n2 -> 3[co\
lor=pink]\n2 -> 4[color=purple]\n3 -> 1[color=lightblue]\n3 -> 2[color=pink]\n\
3 -> 4[color=purple]\n4 -> 1[color=lightblue]\n4 -> 2[color=pink]\n4 -> 3[colo\
r=purple]\n}\n"
gap> DotEdgeColoredDigraph(CycleDigraph(3), []);
Error, the list of edge colors needs to have the same shape as the out-neighbo\
urs of the digraph
gap> DotEdgeColoredDigraph(CycleDigraph(3), [[fail, fail], [fail], [fail]]);
Error, the list of edge colors needs to have the same shape as the out-neighbo\
urs of the digraph
gap> DotEdgeColoredDigraph(CycleDigraph(3), [[fail], [fail], [fail]]);
Error, expected a string

# DotSymmetricVertexColoredDigraph
gap> D := Digraph([[2], [1, 3], [2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> vertcolors := [];;
gap> vertcolors[1] := "blue";;
gap> vertcolors[2] := "pink";;
gap> vertcolors[3] := "purple";;
gap> DotSymmetricVertexColoredDigraph(D, vertcolors);
"//dot\ngraph hgn{\nnode [shape=circle]\n\n1[color=blue, style=filled]\n2[colo\
r=pink, style=filled]\n3[color=purple, style=filled]\n1 -- 2\n2 -- 3\n}\n"

# DotSymmetricEdgeColoredDigraph
gap> D := Digraph([[2], [1, 3], [2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> edgecolors := [];;
gap> edgecolors[1] := [];; edgecolors[2] := [];;
gap> edgecolors[3] := [];;
gap> edgecolors[1][1] := "green";; edgecolors[2][1] := "green";;
gap> edgecolors[2][2] := "red";; edgecolors[3][1] := "red";;
gap> DotSymmetricEdgeColoredDigraph(D, edgecolors);
"//dot\ngraph hgn{\nnode [shape=circle]\n\n1\n2\n3\n1 -- 2[color=green]\n2 -- \
3[color=red]\n}\n"

# DotVertexLabelledDigraph
gap> r := rec(DigraphVertices := [1 .. 3], DigraphSource := [1, 1, 1, 1],
> DigraphRange := [1, 2, 2, 3]);;
gap> gr := Digraph(r);
<immutable multidigraph with 3 vertices, 4 edges>
gap> dot := DotVertexLabelledDigraph(gr);;
gap> dot;
"//dot\ndigraph hgn{\nnode [shape=circle]\n1 [label=\"1\"]\n2 [label=\"2\"]\n3\
 [label=\"3\"]\n1 -> 1\n1 -> 2\n1 -> 2\n1 -> 3\n}\n"
gap> SetDigraphVertexLabel(gr, 1, 2);
gap> dot := DotVertexLabelledDigraph(gr);;
gap> dot;
"//dot\ndigraph hgn{\nnode [shape=circle]\n1 [label=\"2\"]\n2 [label=\"2\"]\n3\
 [label=\"3\"]\n1 -> 1\n1 -> 2\n1 -> 2\n1 -> 3\n}\n"

# Splash 
gap> Splash(1);
Error, the 1st argument must be a string,
gap> Splash("string", 0);
Error, the 2nd argument must be a record,
gap> Splash("string");
Error, the component "type" of the 2nd argument <a record>  must be "dot" or "\
latex",
gap> Splash("string", rec(path := "~/", filename := "filename"));
Error, the component "type" of the 2nd argument <a record>  must be "dot" or "\
latex",
gap> Splash("string", rec(viewer := "xpdf"));
Error, the viewer "xpdf" specified in the option `viewer` is not available,
gap> Splash("string", rec(type := "dot", engine := "dott"));
Error, the component "engine" of the 2nd argument <a record> must be one of: "\
dot", "neato", "twopi", "circo", "fdp", "sfdp", or "patchwork"
gap> tmpdir := Filename(DirectoryTemporary(), "");;
gap> Splash("string",
> rec(path      := tmpdir,
>     directory := "digraphs_temporary_directory"));
Error, the component "type" of the 2nd argument <a record>  must be "dot" or "\
latex",
gap> Splash("%latex", rec(filetype := "latex", engine := fail));
Error, the component "engine" of the 2nd argument <a record> must be one of: "\
dot", "neato", "twopi", "circo", "fdp", "sfdp", or "patchwork"
gap> Splash("//dot", rec(filetype := "pdf", engine := fail));
Error, the component "engine" of the 2nd argument <a record> must be one of: "\
dot", "neato", "twopi", "circo", "fdp", "sfdp", or "patchwork"
gap> MakeReadWriteGlobal("VizViewers");
gap> VizViewers_backup := ShallowCopy(VizViewers);;
gap> VizViewers := ["nonexistent-viewer"];;
gap> Splash("//dot");
Error, none of the default viewers [ "nonexistent-viewer" 
 ] is available, please specify an available viewer in the options record comp\
onent `viewer`,
gap> VizViewers := VizViewers_backup;;
gap> MakeReadOnlyGlobal("VizViewers");

# DotPartialOrderDigraph
gap> gr := Digraph([[1], [1, 2], [1, 3], [1, 4], [1 .. 5], [1 .. 6],
> [1, 2, 3, 4, 5, 7], [1, 8]]);;
gap> Print(DotPartialOrderDigraph(gr));
//dot
digraph hgn{
node [shape=circle]
1
2
3
4
5
6
7
8
2 -> 1
3 -> 1
4 -> 1
5 -> 2
5 -> 3
5 -> 4
6 -> 5
7 -> 5
8 -> 1
}
gap> gr := Digraph([[1], [2], [1, 3], [2, 4], [1, 2, 3, 4, 5], [1, 2, 3, 6]]);;
gap> Print(DotPartialOrderDigraph(gr));
//dot
digraph hgn{
node [shape=circle]
1
2
3
4
5
6
3 -> 1
4 -> 2
5 -> 3
5 -> 4
6 -> 3
6 -> 2
}
gap> gr := Digraph([[1], []]);;
gap> DotPartialOrderDigraph(gr);
Error, the argument <D> must be a partial order digraph,

# DotPreorderDigraph and DotQuasiorderDigraph
gap> DotPreorderDigraph(CompleteDigraph(5));
Error, the argument <D> must be a preorder digraph,
gap> gr := Digraph([[1], [1, 2], [1, 3], [1, 4], [1 .. 5], [1 .. 6],
> [1, 2, 3, 4, 5, 7], [1, 8]]);;
gap> Print(DotPreorderDigraph(gr), "\n");
//dot
digraph graphname {
node [shape=Mrecord, height=0.5, fixedsize=true]ranksep=1;
1 [label="1", width=0.5]
2 [label="2", width=0.5]
3 [label="3", width=0.5]
4 [label="4", width=0.5]
5 [label="5", width=0.5]
6 [label="6", width=0.5]
7 [label="7", width=0.5]
8 [label="8", width=0.5]
2 -> 1
3 -> 1
4 -> 1
5 -> 2
5 -> 3
5 -> 4
6 -> 5
7 -> 5
8 -> 1
}
gap> gr := Concatenation("&X_?_A]|^Vr[nHpmVcy~zy[A????_???G??B]nhtmvcwvJq\\^~",
> "|m??_AEx]Rb[nHo??__vJy[??A??O_aV~^Zb]njo???_???GZdxMLy}n_");;
gap> gr := DigraphFromDigraph6String(gr);;
gap> Print(DotPreorderDigraph(gr){[1 .. 94]}, "\n");
//dot
digraph graphname {
node [shape=Mrecord, height=0.5, fixedsize=true]ranksep=1;
1 [label=
gap> gr := DigraphDisjointUnion(CompleteDigraph(10),
>                               CompleteDigraph(5),
>                               CycleDigraph(2));;
gap> gr := DigraphReflexiveTransitiveClosure(DigraphAddEdge(gr, [10, 11]));;
gap> IsPreorderDigraph(gr);
true
gap> Print(DotPreorderDigraph(gr), "\n");
//dot
digraph graphname {
node [shape=Mrecord, height=0.5, fixedsize=true]ranksep=1;
1 [label="11|12|13|14|15", width=2.5]
2 [label="1|2|3|4|5|6|7|8|9|10", width=5.]
3 [label="16|17", width=1.]
2 -> 1
}

# DotHighlightedDigraph
gap> gr := Digraph([[2, 3], [2], [1, 3]]);
<immutable digraph with 3 vertices, 5 edges>
gap> Print(DotHighlightedDigraph(gr, [1, 2], "red", "black"));
//dot
digraph hgn{
subgraph lowverts{
node [shape=circle, color=black]
 edge [color=black]
3
}
subgraph highverts{
node [shape=circle, color=red]
 edge [color=red]
1
2
}
subgraph lowverts{
3 -> 1
3 -> 3
}
subgraph highverts{
1 -> 2
1 -> 3 [color=black]
2 -> 2
}
}
gap> D := CycleDigraph(5);;
gap> DotHighlightedDigraph(D, [10], "black", "grey");
Error, the 2nd argument <highverts> must be a list of vertices of the 1st argu\
ment <D>,
gap> DotHighlightedDigraph(D, [1], "", "grey");
Error, the 3rd argument <highcolour> must be a string containing the name of a\
 colour,
gap> DotHighlightedDigraph(D, [1], "black", "");
Error, the 4th argument <lowcolour> must be a string containing the name of a \
colour,
gap> Print(DotHighlightedDigraph(D, Filtered(DigraphVertices(D), IsEvenInt)));
//dot
digraph hgn{
subgraph lowverts{
node [shape=circle, color=grey]
 edge [color=grey]
1
3
5
}
subgraph highverts{
node [shape=circle, color=black]
 edge [color=black]
2
4
}
subgraph lowverts{
1 -> 2
3 -> 4
5 -> 1
}
subgraph highverts{
2 -> 3 [color=grey]
4 -> 5 [color=grey]
}
}

# Splash
gap> Splash(DotDigraph(RandomDigraph(10)), rec(viewer := 1));
Error, the option `viewer` must be a string, not an integer,
gap> Splash(DotDigraph(RandomDigraph(10)), rec(viewer := "asdfasfa"));
Error, the viewer "asdfasfa" specified in the option `viewer` is not available\
,

#  DIGRAPHS_UnbindVariables
gap> Unbind(adj);
gap> Unbind(dot);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(r);
gap> Unbind(tmpdir);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/display.tst", 0);
