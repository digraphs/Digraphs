
#############################################################################
##
#W  standard/weights.tst
#Y  Copyright (C) 2023                                Raiyan Chowdhury
##
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

gap> START_TEST("Digraphs package: standard/weights.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();
gap> d := EdgeWeightedDigraph([[2], []], [[5], []]);
<immutable digraph with 2 vertices, 1 edge>

# create edge weighted digraph
gap> d := EdgeWeightedDigraph(Digraph([[2], []]), [[5], []]);
<immutable digraph with 2 vertices, 1 edge>
gap> EdgeWeightedDigraphTotalWeight(d);
5

# weight not valid
gap> d := EdgeWeightedDigraph([[2], []], [["a"], []]);
Error, out neighbour weight must be an integer, float or rational,

# check all elements of out neighbours are list
gap> d := EdgeWeightedDigraph(["a", []], [[5], []]);
Error, the argument <list> must be a list of lists of positive integers not ex\
ceeding the length of the argument,

# check all elements of weights are list
gap> d := EdgeWeightedDigraph([[1], []], [5, []]);
Error, the 2nd argument (list) must be a list of lists,

# string for digraphs
gap> d := EdgeWeightedDigraph([["a"], []], [[2], []]);
Error, the argument <list> must be a list of lists of positive integers not ex\
ceeding the length of the argument,

# incorrect digraph and weights
gap> d := EdgeWeightedDigraph([[2]], [[5], []]);
Error, the argument <list> must be a list of lists of positive integers not ex\
ceeding the length of the argument,

# incorrect digraph and weights
gap> d := EdgeWeightedDigraph([[2], []], [[5]]);
Error, the number of out neighbours and weights must be equal,

# incorrect digraph and weights
gap> d := EdgeWeightedDigraph([[2, 2], []], [[5], []]);
Error, the sizes of the out neighbours and weights for vertex 1 must be equal,

# incorrect digraph and weights
gap> d := EdgeWeightedDigraph([[2], []], [[5, 10], []]);
Error, the sizes of the out neighbours and weights for vertex 1 must be equal,

# changing edge weights mutable copy
gap> d := EdgeWeightedDigraph([[2], [1]], [[5], [10]]);
<immutable digraph with 2 vertices, 2 edges>
gap> m := EdgeWeightsMutableCopy(d);
[ [ 5 ], [ 10 ] ]
gap> m[1] := [25];
[ 25 ]
gap> m;
[ [ 25 ], [ 10 ] ]
gap> m[2][1] := 30;
30
gap> m;
[ [ 25 ], [ 30 ] ]
gap> m := EdgeWeights(d);
[ [ 5 ], [ 10 ] ]
gap> m[1] := [25];
Error, List Assignment: <list> must be a mutable list

# negative edge weights
gap> d := EdgeWeightedDigraph([[2], [1]], [[5], [10]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsNegativeEdgeWeightedDigraph(d);
false
gap> d := EdgeWeightedDigraph([[2], [1]], [[-5], [10]]);
<immutable digraph with 2 vertices, 2 edges>
gap> IsNegativeEdgeWeightedDigraph(d);
true

# not connnected digraph
gap> d := EdgeWeightedDigraph([[1], [2]], [[5], [10]]);
<immutable digraph with 2 vertices, 2 edges>
gap> EdgeWeightedDigraphMinimumSpanningTree(d);
Error, the argument <digraph> must be a connected digraph,

# digraph with one node
gap> d := EdgeWeightedDigraph([[]], [[]]);
<immutable empty digraph with 1 vertex>
gap> tree := EdgeWeightedDigraphMinimumSpanningTree(d);
<immutable empty digraph with 1 vertex>
gap> EdgeWeightedDigraphTotalWeight(tree);
0

# digraph with loop
gap> d := EdgeWeightedDigraph([[1]], [[5]]);
<immutable digraph with 1 vertex, 1 edge>
gap> EdgeWeightedDigraphMinimumSpanningTree(d);
<immutable empty digraph with 1 vertex>

# digraph with cycle
gap> d := EdgeWeightedDigraph([[2], [3], [1]], [[5], [10], [15]]);
<immutable digraph with 3 vertices, 3 edges>
gap> tree := EdgeWeightedDigraphMinimumSpanningTree(d);              
<immutable digraph with 3 vertices, 2 edges>
gap> EdgeWeightedDigraphTotalWeight(tree);
15

# digraph with negative edge
gap> d := EdgeWeightedDigraph([[2], []], [[-5], []]);  
<immutable digraph with 2 vertices, 1 edge>
gap> EdgeWeightedDigraphMinimumSpanningTree(d);
<immutable digraph with 2 vertices, 1 edge>

# digraph with negative cycle
gap> d := EdgeWeightedDigraph([[2], [3], [1]], [[-5], [-10], [-15]]);
<immutable digraph with 3 vertices, 3 edges>
gap> EdgeWeightedDigraphMinimumSpanningTree(d);
<immutable digraph with 3 vertices, 2 edges>

# digraph with parallel edges
gap> d := EdgeWeightedDigraph([[2, 2, 2], [1]], [[10, 5, 15], [7]]);  
<immutable multidigraph with 2 vertices, 4 edges>
gap> EdgeWeightedDigraphMinimumSpanningTree(d);
<immutable digraph with 2 vertices, 1 edge>

#  DIGRAPHS_UnbindVariables
gap> Unbind(d);
gap> Unbind(tree);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/weights.tst", 0);