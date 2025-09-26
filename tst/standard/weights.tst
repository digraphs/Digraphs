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

#@local D, d, distances, edges, gr, m, parents, r, tree
gap> START_TEST("Digraphs package: standard/weights.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#############################################################################
# 1. Edge Weights
#############################################################################

# create edge-weighted digraph
gap> d := EdgeWeightedDigraph([[2], []], [[5], []]);
<immutable digraph with 2 vertices, 1 edge>
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

#############################################################################
# 2. Copies of edge weights
#############################################################################

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

#############################################################################
# 3. Minimum Spanning Trees
#############################################################################

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

#############################################################################
# 4. Shortest Path
#############################################################################

# Shortest paths: one node
gap> d := EdgeWeightedDigraph([[]], [[]]);
<immutable empty digraph with 1 vertex>
gap> EdgeWeightedDigraphShortestPaths(d, 1);
rec( distances := [ 0 ], edges := [ fail ], parents := [ fail ] )

# Shortest paths: early break when path doesn't exist
gap> d := EdgeWeightedDigraph([[], [1]], [[], [-10]]);;
gap> EdgeWeightedDigraphShortestPaths(d, 1);
rec( distances := [ 0, fail ], edges := [ fail, fail ], 
  parents := [ fail, fail ] )

# Shortest paths: one node and loop
gap> d := EdgeWeightedDigraph([[1]], [[5]]);
<immutable digraph with 1 vertex, 1 edge>
gap> EdgeWeightedDigraphShortestPaths(d, 1);
rec( distances := [ 0 ], edges := [ fail ], parents := [ fail ] )

# Shortest paths: two nodes and loop on second node
gap> d := EdgeWeightedDigraph([[2], [1, 2]], [[5], [5, 5]]);
<immutable digraph with 2 vertices, 3 edges>
gap> EdgeWeightedDigraphShortestPaths(d, 1);
rec( distances := [ 0, 5 ], edges := [ fail, 1 ], parents := [ fail, 1 ] )

# Shortest paths: cycle
gap> d := EdgeWeightedDigraph([[2], [3], [1]], [[2], [3], [4]]);
<immutable digraph with 3 vertices, 3 edges>
gap> EdgeWeightedDigraphShortestPaths(d, 1);
rec( distances := [ 0, 2, 5 ], edges := [ fail, 1, 1 ], 
  parents := [ fail, 1, 2 ] )

# Shortest paths: parallel edges
gap> d := EdgeWeightedDigraph([[2, 2, 2], [1]], [[10, 5, 15], [7]]);
<immutable multidigraph with 2 vertices, 4 edges>
gap> EdgeWeightedDigraphShortestPaths(d, 1);
rec( distances := [ 0, 5 ], edges := [ fail, 2 ], parents := [ fail, 1 ] )

# Shortest paths: negative edges
gap> d := EdgeWeightedDigraph([[2], [1]], [[-2], [7]]);
<immutable digraph with 2 vertices, 2 edges>
gap> EdgeWeightedDigraphShortestPaths(d, 1);
rec( distances := [ 0, -2 ], edges := [ fail, 1 ], parents := [ fail, 1 ] )

# Shortest paths: parallel negative edges
gap> d := EdgeWeightedDigraph([[2, 2, 2], [1]], [[-2, -3, -4], [7]]);
<immutable multidigraph with 2 vertices, 4 edges>
gap> EdgeWeightedDigraphShortestPaths(d, 1);
rec( distances := [ 0, -4 ], edges := [ fail, 3 ], parents := [ fail, 1 ] )

# Shortest paths: negative cycle
gap> d := EdgeWeightedDigraph([[2, 2, 2], [1]], [[-10, 5, -15], [7]]);
<immutable multidigraph with 2 vertices, 4 edges>
gap> EdgeWeightedDigraphShortestPaths(d, 1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 2nd choice method found for `EdgeWeightedDigraphShortestPaths' on 2 \
arguments

# Shortest paths: source not in graph
gap> d := EdgeWeightedDigraph([[2], [1]], [[2], [7]]);
<immutable digraph with 2 vertices, 2 edges>
gap> EdgeWeightedDigraphShortestPaths(d, 3);
Error, the 2nd argument <source> must be a vertex of the 1st argument <digraph\
>,
gap> EdgeWeightedDigraphShortestPath(d, 3, 1);
Error, the 2nd argument <source> must be a vertex of the 1st argument <digraph\
>,
gap> EdgeWeightedDigraphShortestPath(d, 1, 3);
Error, the 3rd argument <dest> must be a vertex of the 1st argument <digraph>,

# Shortest paths: no path exists
gap> d := EdgeWeightedDigraph([[1], [2]], [[5], [10]]);
<immutable digraph with 2 vertices, 2 edges>
gap> EdgeWeightedDigraphShortestPaths(d, 1);
rec( distances := [ 0, fail ], edges := [ fail, fail ], 
  parents := [ fail, fail ] )
gap> EdgeWeightedDigraphShortestPath(d, 1, 2);
fail

# Shortest paths: no path exists with negative edge weight
gap> d := EdgeWeightedDigraph([[2], [2], []], [[-5], [10], []]);
<immutable digraph with 3 vertices, 2 edges>
gap> r := EdgeWeightedDigraphShortestPaths(d, 1);;
gap> r.distances = [0, -5, fail];
true
gap> r.edges = [fail, 1, fail];
true
gap> r.parents = [fail, 1, fail];
true

# Shortest paths: parallel edges
gap> d := EdgeWeightedDigraph([[2, 2, 2], []], [[3, 2, 1], []]);
<immutable multidigraph with 2 vertices, 3 edges>
gap> EdgeWeightedDigraphShortestPaths(d, 1);
rec( distances := [ 0, 1 ], edges := [ fail, 3 ], parents := [ fail, 1 ] )
gap> EdgeWeightedDigraphShortestPaths(d);
rec( distances := [ [ 0, 1 ], [ fail, 0 ] ], 
  edges := [ [ fail, 3 ], [ fail, fail ] ], 
  parents := [ [ fail, 1 ], [ fail, fail ] ] )
gap> EdgeWeightedDigraphShortestPath(d, 1, 2);
[ [ 1, 2 ], [ 3 ] ]

# Shortest paths: negative cycle
gap> d := EdgeWeightedDigraph([[2], [3], [1]], [[-3], [-5], [-7]]);
<immutable digraph with 3 vertices, 3 edges>
gap> EdgeWeightedDigraphShortestPaths(d);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 2nd choice method found for `EdgeWeightedDigraphShortestPaths' on 1 \
arguments

# Shortest paths: source not in graph neg int
gap> EdgeWeightedDigraphShortestPaths(d, -1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `EdgeWeightedDigraphShortestPaths' on 2 \
arguments

# Shortest path: same vertex
gap> d := EdgeWeightedDigraph([[2], [3], [1]], [[-3], [-5], [-7]]);;
gap> EdgeWeightedDigraphShortestPath(d, 2, 2);
fail

# Shortest paths: Johnson
gap> d := EdgeWeightedDigraph([[2], [3], [], [], []], [[3], [5], [], [], []]);
<immutable digraph with 5 vertices, 2 edges>
gap> EdgeWeightedDigraphShortestPaths(d, 1);
rec( distances := [ 0, 3, 8, fail, fail ], edges := [ fail, 1, 1, fail, fail ]
    , parents := [ fail, 1, 2, fail, fail ] )
gap> EdgeWeightedDigraphShortestPaths(d);
rec( distances := [ [ 0, 3, 8, fail, fail ], [ fail, 0, 5, fail, fail ], 
      [ fail, fail, 0, fail, fail ], [ fail, fail, fail, 0, fail ], 
      [ fail, fail, fail, fail, 0 ] ], 
  edges := [ [ fail, 1, 1, fail, fail ], [ fail, fail, 1, fail, fail ], 
      [ fail, fail, fail, fail, fail ], [ fail, fail, fail, fail, fail ], 
      [ fail, fail, fail, fail, fail ] ], 
  parents := [ [ fail, 1, 2, fail, fail ], [ fail, fail, 2, fail, fail ], 
      [ fail, fail, fail, fail, fail ], [ fail, fail, fail, fail, fail ], 
      [ fail, fail, fail, fail, fail ] ] )
gap> EdgeWeightedDigraphShortestPaths(d, 6);
Error, the 2nd argument <source> must be a vertex of the 1st argument <digraph\
>,
gap> EdgeWeightedDigraphShortestPath(d, 1, 3);
[ [ 1, 2, 3 ], [ 1, 1 ] ]

#############################################################################
# 5. Maximum Flow
#############################################################################

# Maximum flow: empty digraphs
gap> d := EdgeWeightedDigraph([], []);
<immutable empty digraph with 0 vertices>
gap> DigraphMaximumFlow(d, 1, 1);
Error, <start> must be a vertex of <digraph>,

# Maximum flow: single vertex (also empty digraphs)
gap> d := EdgeWeightedDigraph([[]], [[]]);
<immutable empty digraph with 1 vertex>
gap> DigraphMaximumFlow(d, 1, 1);
[ [  ] ]

# Maximum flow: source = dest
gap> d := EdgeWeightedDigraph([[2], []], [[5], []]);
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphMaximumFlow(d, 1, 1);
[ [ 0 ], [  ] ]

# Maximum flow: has loop
gap> d := EdgeWeightedDigraph([[1, 2], []], [[5, 10], []]);
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphMaximumFlow(d, 1, 2);
[ [ 0, 10 ], [  ] ]

# Maximum flow: invalid source
gap> d := EdgeWeightedDigraph([[1, 2], []], [[5, 10], []]);
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphMaximumFlow(d, 5, 2);
Error, <start> must be a vertex of <digraph>,

# Maximum flow: invalid sink
gap> d := EdgeWeightedDigraph([[1, 2], []], [[5, 10], []]);
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphMaximumFlow(d, 1, 5);
Error, <destination> must be a vertex of <digraph>,

# Maximum flow: sink not reachable
gap> d := EdgeWeightedDigraph([[1], []], [[5], []]);
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphMaximumFlow(d, 1, 2);
[ [ 0 ], [  ] ]

# Maximum flow: source has in neighbours
gap> d := EdgeWeightedDigraph([[2], [3], []], [[5], [10], []]);
<immutable digraph with 3 vertices, 2 edges>
gap> DigraphMaximumFlow(d, 2, 3);
[ [ 0 ], [ 10 ], [  ] ]

# Maximum flow: sink has out neighbours
gap> d := EdgeWeightedDigraph([[2], [3], [2]], [[5], [10], [7]]);
<immutable digraph with 3 vertices, 3 edges>
gap> DigraphMaximumFlow(d, 2, 3);                           
[ [ 0 ], [ 10 ], [ 0 ] ]

# Maximum flow: cycle
gap> d := EdgeWeightedDigraph([[2], [3], [1]], [[5], [10], [7]]);
<immutable digraph with 3 vertices, 3 edges>
gap> DigraphMaximumFlow(d, 1, 3);
[ [ 5 ], [ 5 ], [ 0 ] ]

# Maximum flow: example from Wikipedia
gap> gr := EdgeWeightedDigraph([[3, 4], [], [2, 4], [2]],
>                              [[10, 5], [], [5, 15], [10]]);;
gap> DigraphMaximumFlow(gr, 1, 2);
[ [ 10, 5 ], [  ], [ 5, 5 ], [ 10 ] ]
gap> DigraphMaximumFlow(gr, 3, 2);
[ [ 0, 0 ], [  ], [ 5, 10 ], [ 10 ] ]

# Maximum flow: example from Wikipedia article on Push-label maximum flow
gap> gr := EdgeWeightedDigraph([[2], [3, 6], [4], [1, 6], [1, 3], []],
>                              [[12], [3, 7], [10], [5, 10], [15, 4], []]);;
gap> DigraphMaximumFlow(gr, 5, 6);
[ [ 10 ], [ 3, 7 ], [ 7 ], [ 0, 7 ], [ 10, 4 ], [  ] ]

#############################################################################
# 6. Random edge-weighted digraphs
#############################################################################

# Random edge-weighted digraph with n
gap> D := RandomUniqueEdgeWeightedDigraph(5);;
gap> DigraphNrVertices(D);
5
gap> HasEdgeWeights(D);
true

# Random edge-weighted digraph with n, p
gap> D := RandomUniqueEdgeWeightedDigraph(10, 1 / 2);;
gap> DigraphNrVertices(D);
10
gap> HasEdgeWeights(D);
true
gap> SortedList(Flat(EdgeWeights(D))) = [1 .. DigraphNrEdges(D)];
true

# Random edge-weighted digraph with filt, n, p
gap> D := RandomUniqueEdgeWeightedDigraph(IsEulerianDigraph, 5, 0.3);;
gap> DigraphNrVertices(D);
5
gap> HasEdgeWeights(D);
true
gap> IsEulerianDigraph(D);
true
gap> SortedList(Flat(EdgeWeights(D))) = [1 .. DigraphNrEdges(D)];
true

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/weights.tst", 0);
