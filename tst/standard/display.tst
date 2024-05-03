#############################################################################
##
#W  standard/display.tst
#Y  Copyright (C) 2014-24                                James D. Mitchell
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
"//dot\ndigraph hgn {\n\tnode [shape=circle] \n\t1\n\t2\n\t3"
gap> dot{[51 .. 75]};
"\n\t1 -> 1\n\t1 -> 2\n\t1 -> 2\n"
gap> r := rec(DigraphVertices := [1 .. 8],
> DigraphSource := [1, 1, 2, 2, 3, 4, 4, 4, 5, 5, 5, 5, 5, 6, 7, 7, 7, 7, 7, 8,
>                   8],
> DigraphRange  := [6, 7, 1, 6, 5, 1, 4, 8, 1, 3, 6, 6, 7, 7, 1, 4, 4, 5, 7, 5,
>                   6]);;
gap> gr1 := Digraph(r);
<immutable multidigraph with 8 vertices, 21 edges>
gap> DotDigraph(gr1){[50 .. 109]};
"3\n\t4\n\t5\n\t6\n\t7\n\t8\n\t1 -> 6\n\t1 -> 7\n\t2 -> 1\n\t2 -> 6\n\t3 -> 5\
\n\t4 "
gap> adj := [[2], [1, 3], [2, 3, 4], [3]];
[ [ 2 ], [ 1, 3 ], [ 2, 3, 4 ], [ 3 ] ]
gap> gr2 := Digraph(adj);
<immutable digraph with 4 vertices, 7 edges>
gap> DotDigraph(gr2){[11 .. 75]};
"aph hgn {\n\tnode [shape=circle] \n\t1\n\t2\n\t3\n\t4\n\t1 -> 2\n\t2 -> 1\n\t\
2 ->"
gap> DotSymmetricDigraph(gr2){[12 .. 70]};
" hgn {\n\tnode [shape=circle] \n\t1\n\t2\n\t3\n\t4\n\t2 -- 1\n\t3 -- 2\n\t4"
gap> DotSymmetricDigraph(gr1);
Error, the argument (a digraph) must be symmetric

#DotColoredDigraph and DotSymmetriColoredDigraph
# TODO fix the colors here!
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
"//dot\ndigraph hgn {\n\tnode [sha"
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
"//dot\ngraph hgn {\n\tnode [shape=circle] \n\t1 [color=blue, style=filled]\n\
\t2 [color=pink, style=filled]\n\t3 [color=purple, style=filled]\n\t2 -- 1 [co\
lor=green]\n\t3 -- 2 [color=red]\n}\n"
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
"//dot\ndigraph hgn {\n\tnode [shape=circle] \n\t1 [color=blue, style=filled]\
\n\t2 [color=red, style=filled]\n\t3 [color=green, style=filled]\n\t1 -> 2 [co\
lor=orange]\n\t1 -> 3 [color=yellow]\n\t2 -> 1 [color=orange]\n\t2 -> 3 [color\
=pink]\n\t3 -> 1 [color=yellow]\n}\n"
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
gap> vertcolors := ["blue", "red", "green", "yellow"];;
gap> edgecolors := ListWithIdenticalEntries(3,
> ["orange", "orange", "orange"]);;
#@if CompareVersionNumbers(GAPInfo.Version, "4.12.0")
gap> DotSymmetricColoredDigraph(D, vertcolors, edgecolors);
Error, the 2nd argument (edge colors) must have the same number of entries as \
the 1st argument (a digraph) has nodes, expected 4 but found 3
#@else
gap> DotSymmetricColoredDigraph(D, vertcolors, edgecolors);
Error, the 2nd argument (edge colors) must have the same number of entries as \
the 1st\
 argument (a digraph) has nodes, expected 4 but found 3
#@fi
gap> D := Digraph(IsMutableDigraph, [[2, 4], [1, 3], [2], [1]]);
<mutable digraph with 4 vertices, 6 edges>
gap> vertcolors := ["blue", "red", "green", "yellow"];;
gap> edgecolors := ListWithIdenticalEntries(3,
> ["orange", "orange", "orange"]);;
#@if CompareVersionNumbers(GAPInfo.Version, "4.12.0")
gap> DotSymmetricColoredDigraph(D, vertcolors, edgecolors);
Error, the 2nd argument (edge colors) must have the same number of entries as \
the 1st argument (a digraph) has nodes, expected 4 but found 3
#@else
gap> DotSymmetricColoredDigraph(D, vertcolors, edgecolors);
Error, the 2nd argument (edge colors) must have the same number of entries as \
the 1st\
 argument (a digraph) has nodes, expected 4 but found 3
#@fi
gap> D;
<mutable digraph with 4 vertices, 6 edges>
gap> D := CompleteDigraph(4);;
gap> vertcolors := ["blue", "banana", "green", "yellow"];;
gap> edgecolors := ListWithIdenticalEntries(4,
> ["lightblue", "pink", "purple"]);;
#@if CompareVersionNumbers(GAPInfo.Version, "4.12.0")
gap> DotColoredDigraph(D, vertcolors, edgecolors);
Error, invalid color "banana" (list (string)), valid colors are RGB values or \
names from the GraphViz 2.44.1 X11 Color Scheme http://graphviz.org/doc/info/c\
olors.html
#@else
gap> DotColoredDigraph(D, vertcolors, edgecolors);
Error, invalid color "banana" (list (string)), valid colors are RGB values or \
names from the GraphViz 2.44.1 X11 Color Sch\
eme http://graphviz.org/doc/info/colors.html
#@fi
gap> D := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> vertcolors := ["blue", "red", "green"];;
gap> edgecolors := ListWithIdenticalEntries(4,
> ["lightblue", "pink", "purple"]);;
#@if CompareVersionNumbers(GAPInfo.Version, "4.12.0")
gap> DotColoredDigraph(D, vertcolors, edgecolors);
Error, the number of node colors must be the same as the number of nodes, expe\
cted 4 but found 3
#@else
gap> DotColoredDigraph(D, vertcolors, edgecolors);
Error, the number of node colors must be the same as the number of nodes, expe\
cted 4 but found 3
#@fi
gap> D := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> vertcolors := [2, 1, 1, 3];;
gap> edgecolors := ListWithIdenticalEntries(4,
> ["lightblue", "pink", "purple"]);;
#@if CompareVersionNumbers(GAPInfo.Version, "4.12.0")
gap> DotColoredDigraph(D, vertcolors, edgecolors);
Error, invalid color 2 (integer), valid colors are RGB values or names from th\
e GraphViz 2.44.1 X11 Color Scheme http://graphviz.org/doc/info/colors.html
#@else
gap> DotColoredDigraph(D, vertcolors, edgecolors);
Error, invalid color 2 (integer), valid colors are RGB values or names from th\
e GraphViz 2.44.1 X11 Color Sch\
eme http://graphviz.org/doc/info/colors.html
#@fi
gap> D := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> vertcolors := ["#AB3487", "#DF4738", "#4BF234", "#AF34C9"];;
gap> edgecolors := ListWithIdenticalEntries(4,
> ["lightblue", "pink", "purple"]);;
gap> Print(DotColoredDigraph(D, vertcolors, edgecolors));
//dot
digraph hgn {
	node [shape=circle] 
	1 [color="#AB3487", style=filled]
	2 [color="#DF4738", style=filled]
	3 [color="#4BF234", style=filled]
	4 [color="#AF34C9", style=filled]
	1 -> 2 [color=lightblue]
	1 -> 3 [color=pink]
	1 -> 4 [color=purple]
	2 -> 1 [color=lightblue]
	2 -> 3 [color=pink]
	2 -> 4 [color=purple]
	3 -> 1 [color=lightblue]
	3 -> 2 [color=pink]
	3 -> 4 [color=purple]
	4 -> 1 [color=lightblue]
	4 -> 2 [color=pink]
	4 -> 3 [color=purple]
}
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
#@if CompareVersionNumbers(GAPInfo.Version, "4.12.0")
gap> DotColoredDigraph(D, vertcolors, edgecolors);
Error, invalid color "banana" (list (string)), valid colors are RGB values or \
names from the GraphViz 2.44.1 X11 Color Scheme http://graphviz.org/doc/info/c\
olors.html
#@else
gap> DotColoredDigraph(D, vertcolors, edgecolors);
Error, invalid color "banana" (list (string)), valid colors are RGB values or \
names from the GraphViz 2.44.1 X11 Color Sch\
eme http://graphviz.org/doc/info/colors.html
#@fi
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
#@if CompareVersionNumbers(GAPInfo.Version, "4.12.0")
gap> DotColoredDigraph(D, vertcolors, edgecolors);
Error, the 2nd argument (edge colors) must have the same shape as the out neig\
hbours of the 1st argument (a digraph), in position 4 expected a list of lengt\
h 3 but found list of length 2
#@else
gap> DotColoredDigraph(D, vertcolors, edgecolors);
Error, the 2nd argument (edge colors) must have the same shape as the out neig\
hbours \
of the 1st argument (a digraph), in position 4 expected a list of length 3 but\
 found list of length 2
#@fi

# DotVertexColoredDigraph
gap> D := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> vertcolors := [];;
gap> vertcolors[1] := "blue";; vertcolors[2] := "red";;
gap> vertcolors[3] := "green";; vertcolors[4] := "yellow";;
gap> Print(DotVertexColoredDigraph(D, vertcolors));
//dot
digraph hgn {
	node [shape=circle] 
	1 [color=blue, style=filled]
	2 [color=red, style=filled]
	3 [color=green, style=filled]
	4 [color=yellow, style=filled]
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
"//dot\ndigraph hgn {\n\tnode [shape=circle] \n\t1 [color=blue, style=filled]\
\n\t2 [color=red, style=filled]\n\t3 [color=green, style=filled]\n}\n"

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
"//dot\ndigraph hgn {\n\tnode [shape=circle] \n\t1\n\t2\n\t3\n\t4\n\t1 -> 2 [c\
olor=lightblue]\n\t1 -> 3 [color=pink]\n\t1 -> 4 [color=purple]\n\t2 -> 1 [col\
or=lightblue]\n\t2 -> 3 [color=pink]\n\t2 -> 4 [color=purple]\n\t3 -> 1 [color\
=lightblue]\n\t3 -> 2 [color=pink]\n\t3 -> 4 [color=purple]\n\t4 -> 1 [color=l\
ightblue]\n\t4 -> 2 [color=pink]\n\t4 -> 3 [color=purple]\n}\n"
#@if CompareVersionNumbers(GAPInfo.Version, "4.12.0")
gap> DotEdgeColoredDigraph(CycleDigraph(3), []);
Error, the 2nd argument (edge colors) must have the same number of entries as \
the 1st argument (a digraph) has nodes, expected 3 but found 0
gap> DotEdgeColoredDigraph(CycleDigraph(3), [[fail, fail], [fail], [fail]]);
Error, the 2nd argument (edge colors) must have the same shape as the out neig\
hbours of the 1st argument (a digraph), in position 1 expected a list of lengt\
h 1 but found list of length 2
#@else
gap> DotEdgeColoredDigraph(CycleDigraph(3), []);
Error, the 2nd argument (edge colors) must have the same number of entries as \
the 1st\
 argument (a digraph) has nodes, expected 3 but found 0
#@fi
#@if CompareVersionNumbers(GAPInfo.Version, "4.12.0")
gap> DotEdgeColoredDigraph(CycleDigraph(3), [[fail], [fail], [fail]]);
Error, invalid color fail (boolean or fail), valid colors are RGB values or na\
mes from the GraphViz 2.44.1 X11 Color Scheme http://graphviz.org/doc/info/col\
ors.html
#@else
gap> DotEdgeColoredDigraph(CycleDigraph(3), [[fail], [fail], [fail]]);
Error, invalid color fail (boolean or fail), valid colors are RGB values or na\
mes from the GraphViz 2.44.1 X11 Color Sch\
eme http://graphviz.org/doc/info/colors.html
#@fi

# DotSymmetricVertexColoredDigraph
gap> D := Digraph([[2], [1, 3], [2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> vertcolors := [];;
gap> vertcolors[1] := "blue";;
gap> vertcolors[2] := "pink";;
gap> vertcolors[3] := "purple";;
gap> DotSymmetricVertexColoredDigraph(D, vertcolors);
"//dot\ngraph hgn {\n\tnode [shape=circle] \n\t1 [color=blue, style=filled]\n\
\t2 [color=pink, style=filled]\n\t3 [color=purple, style=filled]\n\t2 -- 1\n\t\
3 -- 2\n}\n"

# DotSymmetricEdgeColoredDigraph
gap> D := Digraph([[2], [1, 3], [2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> edgecolors := [];;
gap> edgecolors[1] := [];; edgecolors[2] := [];;
gap> edgecolors[3] := [];;
gap> edgecolors[1][1] := "green";; edgecolors[2][1] := "green";;
gap> edgecolors[2][2] := "red";; edgecolors[3][1] := "red";;
gap> DotSymmetricEdgeColoredDigraph(D, edgecolors);
"//dot\ngraph hgn {\n\tnode [shape=circle] \n\t1\n\t2\n\t3\n\t2 -- 1 [color=gr\
een]\n\t3 -- 2 [color=red]\n}\n"

# DotVertexLabelledDigraph
gap> r := rec(DigraphVertices := [1 .. 3], DigraphSource := [1, 1, 1, 1],
> DigraphRange := [1, 2, 2, 3]);;
gap> gr := Digraph(r);
<immutable multidigraph with 3 vertices, 4 edges>
gap> dot := DotVertexLabelledDigraph(gr);;
gap> dot;
"//dot\ndigraph hgn {\n\tnode [shape=circle] \n\t1 [label=1]\n\t2 [label=2]\n\
\t3 [label=3]\n\t1 -> 1\n\t1 -> 2\n\t1 -> 2\n\t1 -> 3\n}\n"
gap> SetDigraphVertexLabel(gr, 1, 2);
gap> dot := DotVertexLabelledDigraph(gr);;
gap> dot;
"//dot\ndigraph hgn {\n\tnode [shape=circle] \n\t1 [label=2]\n\t2 [label=2]\n\
\t3 [label=3]\n\t1 -> 1\n\t1 -> 2\n\t1 -> 2\n\t1 -> 3\n}\n"

# Splash
gap> Splash(1);
Error, the 1st argument must be a string or graphviz graph, found integer
gap> Splash("string", 0);
Error, the 2nd argument must be a record,
gap> Splash("string");
Error, the component "type" of the 2nd argument <a record>  must be "dot" or "\
latex",
gap> Splash("string", rec(path := "~/", filename := "filename"));
Error, the component "type" of the 2nd argument <a record>  must be "dot" or "\
latex",
gap> Splash("string", rec(viewer := "bad"));
Error, the viewer "bad" specified in the option `viewer` is not available
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
digraph hgn {
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
digraph hgn {
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
Error, the argument (a digraph) must be a partial order

# DotPreorderDigraph and DotQuasiorderDigraph
gap> DotPreorderDigraph(CompleteDigraph(5));
Error, the argument (a digraph) must be a preorder
gap> gr := Digraph([[1], [1, 2], [1, 3], [1, 4], [1 .. 5], [1 .. 6],
> [1, 2, 3, 4, 5, 7], [1, 8]]);;
gap> Print(DotPreorderDigraph(gr), "\n");
//dot
digraph graphname {
	node [shape="Mrecord"] height="0.5" fixedsize="true" ranksep="1" 
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
	node [shape="Mrecord"] height="0.5" fixedsize="true" ranksep="1" 
	
gap> gr := DigraphDisjointUnion(CompleteDigraph(10),
>                               CompleteDigraph(5),
>                               CycleDigraph(2));;
gap> gr := DigraphReflexiveTransitiveClosure(DigraphAddEdge(gr, [10, 11]));;
gap> IsPreorderDigraph(gr);
true
gap> Print(DotPreorderDigraph(gr), "\n");
//dot
digraph graphname {
	node [shape="Mrecord"] height="0.5" fixedsize="true" ranksep="1" 
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
digraph  {
	shape=circle 
	1 [color=red]
	2 [color=red]
	3 [color=black]
	1 -> 2 [color=red]
	1 -> 3 [color=black]
	2 -> 2 [color=red]
	3 -> 1 [color=black]
	3 -> 3 [color=black]
}
gap> D := CycleDigraph(5);;
gap> DotHighlightedDigraph(D, [10], "black", "grey");
Error, the 2nd argument (list) must consist of vertices of the 1st argument (a\
 digraph)
#@if CompareVersionNumbers(GAPInfo.Version, "4.12.0")
gap> DotHighlightedDigraph(D, [1], "", "grey");
Error, invalid color "" (list (string)), valid colors are RGB values or names \
from the GraphViz 2.44.1 X11 Color Scheme http://graphviz.org/doc/info/colors.\
html
#@else
gap> DotHighlightedDigraph(D, [1], "", "grey");
Error, invalid color "" (list (string)), valid colors are RGB values or names \
from the GraphViz 2.44.1 X11 Color Sch\
eme http://graphviz.org/doc/info/colors.html
#@fi
#@if CompareVersionNumbers(GAPInfo.Version, "4.12.0")
gap> DotHighlightedDigraph(D, [1], "black", "");
Error, invalid color "" (list (string)), valid colors are RGB values or names \
from the GraphViz 2.44.1 X11 Color Scheme http://graphviz.org/doc/info/colors.\
html
#@else
gap> DotHighlightedDigraph(D, [1], "black", "");
Error, invalid color "" (list (string)), valid colors are RGB values or names \
from the GraphViz 2.44.1 X11 Color Sch\
eme http://graphviz.org/doc/info/colors.html
#@fi
gap> Print(DotHighlightedDigraph(D, Filtered(DigraphVertices(D), IsEvenInt)));
//dot
digraph  {
	shape=circle 
	1 [color=grey]
	2 [color=black]
	3 [color=grey]
	4 [color=black]
	5 [color=grey]
	1 -> 2 [color=grey]
	2 -> 3 [color=grey]
	3 -> 4 [color=grey]
	4 -> 5 [color=grey]
	5 -> 1 [color=grey]
}

# Splash
gap> Splash(DotDigraph(RandomDigraph(10)), rec(viewer := 1));
Error, the option `viewer` must be a string, not an integer
gap> Splash(DotDigraph(RandomDigraph(10)), rec(viewer := "asdfasfa"));
Error, the viewer "asdfasfa" specified in the option `viewer` is not available

# Test errors
gap> GraphvizEdgeColoredGraph(ChainDigraph(3), ["blue"]);
Error, the argument (a digraph) must be symmetric
gap> D := DigraphSymmetricClosure(ChainDigraph(3));;
gap> GraphvizVertexLabelledGraph(D);
<graphviz graph hgn with 3 nodes and 2 edges>
gap> GraphvizEdgeColoredGraph(D, List(DigraphVertices(D), ReturnFail));
Error, the 2nd argument (edge colors) must be a list of lists, found boolean o\
r fail in position 1
gap> GraphvizHighlightedDigraph(D, [2]);
<graphviz digraph with 3 nodes and 4 edges>
gap> GraphvizHighlightedGraph(D, [2]);
<graphviz graph with 3 nodes and 2 edges>
gap> Print(AsString(last));
//dot
graph  {
	shape=circle 
	1 [color=grey]
	2 [color=black]
	3 [color=grey]
	2 -- 1 [color=grey]
	3 -- 2 [color=grey]
}
gap> GraphvizHighlightedGraph(D, [1, 2], "red", "blue");
<graphviz graph with 3 nodes and 2 edges>
gap> Print(AsString(last));
//dot
graph  {
	shape=circle 
	1 [color=red]
	2 [color=red]
	3 [color=blue]
	2 -- 1 [color=red]
	3 -- 2 [color=blue]
}
gap> GraphvizHighlightedGraph(ChainDigraph(3), [1, 2], "red", "blue");
Error, the argument (a digraph) must be symmetric
gap> D := Digraph([[], [1, 1]]);;
gap> GraphvizHighlightedDigraph(D, [2]);
Error, the 1st argument (a digraph) must not have multiple edges

#  DIGRAPHS_UnbindVariables
gap> Unbind(D);
gap> Unbind(adj);
gap> Unbind(backup);
gap> Unbind(dot);
gap> Unbind(edgecolors);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(r);
gap> Unbind(tmpdir);
gap> Unbind(vertcolors);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/display.tst", 0);
