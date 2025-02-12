#############################################################################
##
#W  standard/labels.tst
#Y  Copyright (C) 2019                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/labels.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#  DigraphVertexLabels
gap> gr := RandomDigraph(10);;
gap> DigraphVertexLabels(gr);
[ 1 .. 10 ]
gap> SetDigraphVertexLabels(gr, ["a", "b", 10]);
Error, the 2nd argument <names> must be a list with length equal to the number\
 of vertices of the digraph <D> that is the 1st argument,
gap> gr := RandomDigraph(3);;
gap> SetDigraphVertexLabels(gr, ["a", "b", 10]);
gap> DigraphVertexLabels(gr);
[ "a", "b", 10 ]
gap> DigraphVertexLabel(gr, 1);
"a"
gap> DigraphVertexLabel(gr, 2);
"b"
gap> DigraphVertexLabel(gr, 10);
Error, the 2nd argument <v> has no label or is not a vertex of the digraph <D>\
 that is the 1st argument
gap> DigraphVertexLabel(gr, 3);
10
gap> SetDigraphVertexLabel(gr, 3, 3);
gap> DigraphVertexLabel(gr, 3);
3
gap> ClearDigraphVertexLabels(gr);
gap> DigraphVertexLabels(gr);
[ 1 .. 3 ]
gap> gr := RandomDigraph(5);;
gap> SetDigraphVertexLabel(gr, 6, (1, 3, 2, 5, 4));
Error, the 2nd argument <v> is not a vertex of the digraph <D> that is the 1st\
 argument,
gap> SetDigraphVertexLabel(gr, 2, (1, 3, 2, 5, 4));
gap> DigraphVertexLabel(gr, 2);
(1,3,2,5,4)
gap> gr := RandomDigraph(3);;
gap> DigraphVertexLabel(gr, 2);
2
gap> gr := RandomDigraph(10);;
gap> gr := InducedSubdigraph(gr, [1, 2, 3, 5, 7]);;
gap> DigraphVertexLabels(gr);
[ 1, 2, 3, 5, 7 ]
gap> DigraphVertices(gr);
[ 1 .. 5 ]
gap> gr := Digraph([[4, 8], [4, 9], [5], [9], [6], [3, 5], [],
> [6], [1, 3], [10]]);
<immutable digraph with 10 vertices, 13 edges>
gap> x := DigraphVertexLabels(gr);
[ 1 .. 10 ]
gap> x[1] := "a";
"a"
gap> x;
[ "a", 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> DigraphVertexLabels(gr);
[ 1 .. 10 ]
gap> SetDigraphVertexLabel(gr, 2, []);
gap> x := DigraphVertexLabel(gr, 2);
[  ]
gap> Add(x, 1);
gap> x;
[ 1 ]
gap> DigraphVertexLabels(gr);
[ 1, [  ], 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> RemoveDigraphVertexLabel(gr, 2);
gap> DigraphVertexLabels(gr);
[ 1, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> D := NullDigraph(5);;
gap> RemoveDigraphVertexLabel(D, 6);
gap> A := Immutable([1, 2]);
[ 1, 2 ]
gap> D := CycleDigraph(2);
<immutable cycle digraph with 2 vertices>
gap> SetDigraphVertexLabels(D, A);
gap> SetDigraphVertexLabel(D, 2, "b");

#  DigraphEdgeLabels
gap> gr := Digraph([[2, 3], [3], [1, 5], [], [4]]);
<immutable digraph with 5 vertices, 6 edges>
gap> DigraphEdgeLabels(gr);
[ [ 1, 1 ], [ 1 ], [ 1, 1 ], [  ], [ 1 ] ]
gap> SetDigraphEdgeLabels(gr, [1, 2]);
Error, the 2nd argument <labels> must be a list with the same shape as the out\
-neighbours of the digraph <D> that is the 1st argument,
gap> SetDigraphEdgeLabel(gr, 2, 4, "banana");
Error, there is no edge from 2 to 
4 in the digraph <D> that is the 1st argument,
gap> SetDigraphEdgeLabels(gr, function(x, y) return x + y; end);
gap> DigraphEdgeLabels(gr);
[ [ 3, 4 ], [ 5 ], [ 4, 8 ], [  ], [ 9 ] ]
gap> SetDigraphEdgeLabels(gr, [["a", "b"], ["c"], [42, []],
> [], [1]]);
gap> DigraphEdgeLabels(gr);
[ [ "a", "b" ], [ "c" ], [ 42, [  ] ], [  ], [ 1 ] ]
gap> DigraphEdgeLabel(gr, 1, 2);
"a"
gap> SetDigraphEdgeLabel(gr, 1, 2, "23");
gap> DigraphEdgeLabel(gr, 1, 2);
"23"
gap> DigraphEdgeLabels(gr);
[ [ "23", "b" ], [ "c" ], [ 42, [  ] ], [  ], [ 1 ] ]
gap> x := DigraphEdgeLabel(gr, 3, 5);
[  ]
gap> Add(x, "hello, world");
gap> x;
[ "hello, world" ]
gap> DigraphEdgeLabels(gr);
[ [ "23", "b" ], [ "c" ], [ 42, [  ] ], [  ], [ 1 ] ]
gap> gr := Digraph([[3], [1, 3, 5], [1], [1, 2, 4], [2, 3, 5]]);
<immutable digraph with 5 vertices, 11 edges>
gap> l := DigraphEdgeLabels(gr);
[ [ 1 ], [ 1, 1, 1 ], [ 1 ], [ 1, 1, 1 ], [ 1, 1, 1 ] ]
gap> MakeImmutable(l);
[ [ 1 ], [ 1, 1, 1 ], [ 1 ], [ 1, 1, 1 ], [ 1, 1, 1 ] ]
gap> SetDigraphEdgeLabels(gr, l);
gap> SetDigraphEdgeLabel(gr, 2, 1, "Hello, banana");
gap> DigraphEdgeLabels(gr);
[ [ 1 ], [ "Hello, banana", 1, 1 ], [ 1 ], [ 1, 1, 1 ], [ 1, 1, 1 ] ]
gap> gr := Digraph([[2, 2], []]);;
gap> SetDigraphEdgeLabels(gr, [[5, infinity], []]);
Error, the argument <D> must be a digraph with no multiple edges, edge labels \
are not supported on digraphs with multiple edges,
gap> DigraphEdgeLabels(gr);
Error, the argument <D> must be a digraph with no multiple edges, edge labels \
are not supported on digraphs with multiple edges,
gap> SetDigraphEdgeLabel(gr, 1, 2, infinity);
Error, the 1st argument <D> must be a digraph with no multiple edges, edge lab\
els are not supported on digraphs with multiple edges,
gap> gr := Digraph([[2, 3], [3], [1, 5], [], [4]]);
<immutable digraph with 5 vertices, 6 edges>
gap> SetDigraphEdgeLabel(gr, 2, 3, "banana");
gap> D := Digraph(IsMutableDigraph, [[2, 3], [3], [1, 5], [], [4]]);
<mutable digraph with 5 vertices, 6 edges>
gap> DigraphEdgeLabels(D);
[ [ 1, 1 ], [ 1 ], [ 1, 1 ], [  ], [ 1 ] ]
gap> DigraphAddVertex(D);
<mutable digraph with 6 vertices, 6 edges>
gap> DigraphAddEdge(D, 6, 1);
<mutable digraph with 6 vertices, 7 edges>
gap> SetDigraphEdgeLabel(D, 6, 1, "banana");
gap> DigraphEdgeLabels(D);
[ [ 1, 1 ], [ 1 ], [ 1, 1 ], [  ], [ 1 ], [ "banana" ] ]
gap> DigraphAddEdge(D, 6, 1);
<mutable multidigraph with 6 vertices, 8 edges>
gap> DigraphEdgeLabel(D, 6, 1);
Error, the 1st argument <D> must be a digraph with no multiple edges, edge lab\
els are not supported on digraphs with multiple edges,
gap> SetDigraphEdgeLabels(D, ReturnFail);
Error, the argument <D> must be a digraph with no multiple edges, edge labels \
are not supported on digraphs with multiple edges,
gap> D := Digraph(IsMutableDigraph, [[2, 3], [3], [1, 5], [], [4]]);
<mutable digraph with 5 vertices, 6 edges>
gap> DigraphEdgeLabel(D, 1, 5);
Error, there is no edge from 1 to 
5 in the digraph <D> that is the 1st argument,
gap> gr := Digraph(IsMutableDigraph, [[2, 3], [3], [1, 5], [], [4]]);
<mutable digraph with 5 vertices, 6 edges>
gap> SetDigraphEdgeLabel(gr, 1, 2, "bab");
gap> DigraphAddVertex(gr);
<mutable digraph with 6 vertices, 6 edges>
gap> DigraphAddEdge(gr, 6, 1);
<mutable digraph with 6 vertices, 7 edges>
gap> SetDigraphEdgeLabel(gr, 6, 1, "bab");
gap> RemoveDigraphEdgeLabel(gr, 6, 1);
gap> ClearDigraphEdgeLabels(gr);
gap> DigraphEdgeLabel(gr, 6, 1);
1
gap> gr := Digraph([[2, 3], [3], [1, 5], [], [4]]);
<immutable digraph with 5 vertices, 6 edges>
gap> HaveEdgeLabelsBeenAssigned(gr);
false
gap> DigraphEdgeLabels(gr);
[ [ 1, 1 ], [ 1 ], [ 1, 1 ], [  ], [ 1 ] ]
gap> HaveEdgeLabelsBeenAssigned(gr);
true
gap> ClearDigraphEdgeLabels(gr);
gap> HaveEdgeLabelsBeenAssigned(gr);
false

# Test errors in DigraphEdgeLabel
gap> gr := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> DigraphEdgeLabel(gr, 1, 2);
Error, the 1st argument <D> must be a digraph with no multiple edges, edge lab\
els are not supported on digraphs with multiple edges,
gap> SetDigraphEdgeLabels(gr, ReturnFalse);
Error, the argument <D> must be a digraph with no multiple edges, edge labels \
are not supported on digraphs with multiple edges,
gap> gr := Digraph([[2, 1], []]);
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphEdgeLabel(gr, 2, 2);
Error, there is no edge from 2 to 
2 in the digraph <D> that is the 1st argument,
gap> SetDigraphEdgeLabel(gr, 2, 2, "a");
Error, there is no edge from 2 to 
2 in the digraph <D> that is the 1st argument,

#  DIGRAPHS_UnbindVariables
gap> Unbind(A);
gap> Unbind(D);
gap> Unbind(gr);
gap> Unbind(l);
gap> Unbind(x);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/labels.tst", 0);
