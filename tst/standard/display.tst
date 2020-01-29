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
> DigraphSource := [1, 1, 2, 2, 3, 4, 4, 4, 5, 5, 5, 5, 5, 6, 7, 7, 7, 7, 7, 8, 8],
> DigraphRange := [6, 7, 1, 6, 5, 1, 4, 8, 1, 3, 6, 6, 7, 7, 1, 4, 4, 5, 7, 5, 6]);;
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

# DotVertexLabelledDigraph
gap> r := rec(DigraphVertices := [1 .. 3], DigraphSource := [1, 1, 1, 1],
> DigraphRange := [1, 2, 2, 3]);;
gap> gr := Digraph(r);
<immutable multidigraph with 3 vertices, 4 edges>
gap> dot := DotVertexLabelledDigraph(gr);;
gap> dot{[1 .. 50]};
"//dot\ndigraph hgn{\nnode [shape=circle]\n1 [label=\"1"
gap> SetDigraphVertexLabel(gr, 1, 2);
gap> dot := DotVertexLabelledDigraph(gr);;
gap> dot{[1 .. 50]};
"//dot\ndigraph hgn{\nnode [shape=circle]\n1 [label=\"2"

# The following tests can't be run because they fail if Semigroups is loaded
# first
#  Splash 
#gap> Splash(1);
#Error, Digraphs: Splash: usage,
#<arg>[1] must be a string,
#gap> Splash("string", 0);
#Error, Digraphs: Splash: usage,
#<arg>[2] must be a record,
#gap> Splash("string");
#Error, Digraphs: Splash: usage,
#the option <type> must be "dot" or "latex",
#gap> Splash("string", rec(path := "~/", filename := "filename"));
#Error, Digraphs: Splash: usage,
#the option <type> must be "dot" or "latex",
#gap> Splash("string", rec(viewer := "xpdf"));
#Error, Digraphs: Splash: usage,
#the option <type> must be "dot" or "latex",
#gap> Splash("string", rec(type := "dot", engine := "dott"));
#Error, Digraphs: Splash: usage,
#the option <engine> must be "dot", "neato", "twopi", "circo", "fdp", "sfdp", or "patchwork"

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
gap> gr := DigraphDisjointUnion(CompleteDigraph(10), CompleteDigraph(5), CycleDigraph(2));;
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

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/display.tst", 0);
