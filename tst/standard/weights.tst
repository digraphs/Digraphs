
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
gap> DigraphEdgeWeightedMinimumSpanningTree(d);
Error, digraph must be connected,

# digraph with one node
gap> d := EdgeWeightedDigraph([[]], [[]]);
<immutable empty digraph with 1 vertex>
gap> DigraphEdgeWeightedMinimumSpanningTree(d);
rec( mst := <immutable empty digraph with 1 vertex>, total := 0 )

# digraph with loop
gap> d := EdgeWeightedDigraph([[1]], [[5]]);
<immutable digraph with 1 vertex, 1 edge>
gap> DigraphEdgeWeightedMinimumSpanningTree(d);
rec( mst := <immutable empty digraph with 1 vertex>, total := 0 )

# digraph with cycle
gap> d := EdgeWeightedDigraph([[2], [3], [1]], [[5], [10], [15]]);
<immutable digraph with 3 vertices, 3 edges>
gap> DigraphEdgeWeightedMinimumSpanningTree(d);              
rec( mst := <immutable digraph with 3 vertices, 2 edges>, total := 15 )

# digraph with negative edge
gap> d := EdgeWeightedDigraph([[2], []], [[-5], []]);  
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphEdgeWeightedMinimumSpanningTree(d);
rec( mst := <immutable digraph with 2 vertices, 1 edge>, total := -5 )

# digraph with negative cycle
gap> d := EdgeWeightedDigraph([[2], [3], [1]], [[-5], [-10], [-15]]);
<immutable digraph with 3 vertices, 3 edges>
gap> DigraphEdgeWeightedMinimumSpanningTree(d);
rec( mst := <immutable digraph with 3 vertices, 2 edges>, total := -25 )

# digraph with parallel edges
gap> d := EdgeWeightedDigraph([[2, 2, 2], [1]], [[10, 5, 15], [7]]);  
<immutable multidigraph with 2 vertices, 4 edges>
gap> DigraphEdgeWeightedMinimumSpanningTree(d);
rec( mst := <immutable digraph with 2 vertices, 1 edge>, total := 5 )

# graph one node
gap> d := EdgeWeightedDigraph([[]], [[]]);           
<immutable empty digraph with 1 vertex>
gap> DigraphEdgeWeightedShortestPath(d, 1);
rec( distances := [ 0 ], edges := [ fail ], parents := [ fail ] )

# early break when path doesn't exist
gap> d := EdgeWeightedDigraph([[], [1]], [[], [-10]]);;
gap> DigraphEdgeWeightedShortestPath(d, 1);
rec( distances := [ 0, fail ], edges := [ fail, fail ], 
  parents := [ fail, fail ] )

# graph with one node and self loop
gap> d := EdgeWeightedDigraph([[1]], [[5]]);
<immutable digraph with 1 vertex, 1 edge>
gap> DigraphEdgeWeightedShortestPath(d, 1);
rec( distances := [ 0 ], edges := [ fail ], parents := [ fail ] )

# graph with two nodes and self loop on second node
gap> d := EdgeWeightedDigraph([[2], [1, 2]], [[5], [5, 5]]);
<immutable digraph with 2 vertices, 3 edges>
gap> DigraphEdgeWeightedShortestPath(d, 1);
rec( distances := [ 0, 5 ], edges := [ fail, 1 ], parents := [ fail, 1 ] )

# graph with cycle
gap> d := EdgeWeightedDigraph([[2], [3], [1]], [[2], [3], [4]]);
<immutable digraph with 3 vertices, 3 edges>
gap> DigraphEdgeWeightedShortestPath(d, 1);
rec( distances := [ 0, 2, 5 ], edges := [ fail, 1, 1 ], 
  parents := [ fail, 1, 2 ] )

# parallel edges
gap> d := EdgeWeightedDigraph([[2, 2, 2], [1]], [[10, 5, 15], [7]]);   
<immutable multidigraph with 2 vertices, 4 edges>
gap> DigraphEdgeWeightedShortestPath(d, 1);
rec( distances := [ 0, 5 ], edges := [ fail, 2 ], parents := [ fail, 1 ] )

# negative edges
gap> d := EdgeWeightedDigraph([[2], [1]], [[-2], [7]]);          
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphEdgeWeightedShortestPath(d, 1);
rec( distances := [ 0, -2 ], edges := [ fail, 1 ], parents := [ fail, 1 ] )

# parallel negative edges
gap> d := EdgeWeightedDigraph([[2, 2, 2], [1]], [[-2, -3, -4], [7]]);
<immutable multidigraph with 2 vertices, 4 edges>
gap> DigraphEdgeWeightedShortestPath(d, 1);
rec( distances := [ 0, -4 ], edges := [ fail, 3 ], parents := [ fail, 1 ] )

# negative cycle
gap> d := EdgeWeightedDigraph([[2, 2, 2], [1]], [[-10, 5, -15], [7]]);
<immutable multidigraph with 2 vertices, 4 edges>
gap> DigraphEdgeWeightedShortestPath(d, 1);
Error, negative cycle exists,

# source not in graph pos int
gap> d := EdgeWeightedDigraph([[2], [1]], [[2], [7]]);
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphEdgeWeightedShortestPath(d, 3);
Error, source vertex does not exist within digraph

# no path exists
gap> d := EdgeWeightedDigraph([[1], [2]], [[5], [10]]);
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphEdgeWeightedShortestPath(d, 1);
rec( distances := [ 0, fail ], edges := [ fail, fail ], 
  parents := [ fail, fail ] )

# no path exists with negative edge weight
gap> d := EdgeWeightedDigraph([[2], [2], []], [[-5], [10], []]);
<immutable digraph with 3 vertices, 2 edges>
gap> r := DigraphEdgeWeightedShortestPath(d, 1);;
gap> r.distances = [0, -5, fail];
true
gap> r.edges = [fail, 1, fail];
true
gap> r.parents = [fail, 1, fail];
true

# parallel edges
gap> d := EdgeWeightedDigraph([[2, 2, 2], []], [[3, 2, 1], []]);
<immutable multidigraph with 2 vertices, 3 edges>
gap> DigraphEdgeWeightedShortestPaths(d); 
rec( distances := [ [ 0, 1 ], [ fail, 0 ] ], 
  edges := [ [ fail, 3 ], [ fail, fail ] ], 
  parents := [ [ fail, 1 ], [ fail, fail ] ] )

# negative cycle
gap> d := EdgeWeightedDigraph([[2], [3], [1]], [[-3], [-5], [-7]]);
<immutable digraph with 3 vertices, 3 edges>
gap> DigraphEdgeWeightedShortestPaths(d);
Error, negative cycle exists,

# source not in graph neg int
gap> DigraphEdgeWeightedShortestPath(d, -1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphEdgeWeightedShortestPath' on 2 a\
rguments

# testing johnson
gap> d := EdgeWeightedDigraph([[2], [3], [], [], []], [[3], [5], [], [], []]);
<immutable digraph with 5 vertices, 2 edges>
gap> DigraphEdgeWeightedShortestPaths(d);
rec( distances := [ [ 0, 3, 8, fail, fail ], [ fail, 0, 5, fail, fail ], 
      [ fail, fail, 0, fail, fail ], [ fail, fail, fail, 0, fail ], 
      [ fail, fail, fail, fail, 0 ] ], 
  edges := [ [ fail, 1, 1, fail, fail ], [ fail, fail, 1, fail, fail ], 
      [ fail, fail, fail, fail, fail ], [ fail, fail, fail, fail, fail ], 
      [ fail, fail, fail, fail, fail ] ], 
  parents := [ [ fail, 1, 2, fail, fail ], [ fail, fail, 2, fail, fail ], 
      [ fail, fail, fail, fail, fail ], [ fail, fail, fail, fail, fail ], 
      [ fail, fail, fail, fail, fail ] ] )

# empty digraphs
gap> d := EdgeWeightedDigraph([], []);
<immutable empty digraph with 0 vertices>
gap> DigraphMaximumFlow(d, 1, 1);
Error, invalid source,

# single vertex (also empty digraphs)
gap> d := EdgeWeightedDigraph([[]], [[]]);
<immutable empty digraph with 1 vertex>
gap> DigraphMaximumFlow(d, 1, 1);        
rec( flows := [ [  ] ], maxFlow := 0, parents := [ [  ] ] )

# source = dest
gap> d := EdgeWeightedDigraph([[2], []], [[5], []]);
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphMaximumFlow(d, 1, 1);                
rec( flows := [ [  ], [  ] ], maxFlow := 0, parents := [ [  ], [  ] ] )

# has loop 
gap> d := EdgeWeightedDigraph([[1, 2], []], [[5, 10], []]);
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphMaximumFlow(d, 1, 2);
rec( flows := [ [  ], [ 10 ] ], maxFlow := 10, parents := [ [  ], [ 1 ] ] )

# invalid source
gap> d := EdgeWeightedDigraph([[1, 2], []], [[5, 10], []]);                
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphMaximumFlow(d, 5, 2);
Error, invalid source,

# invalid sink
gap> d := EdgeWeightedDigraph([[1, 2], []], [[5, 10], []]);
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphMaximumFlow(d, 1, 5);
Error, invalid sink,

# sink not reachable
gap> d := EdgeWeightedDigraph([[1], []], [[5], []]);     
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphMaximumFlow(d, 1, 2);
rec( flows := [ [  ], [  ] ], maxFlow := 0, parents := [ [  ], [  ] ] )

# source has in neighbours
gap> d := EdgeWeightedDigraph([[2], [3], []], [[5], [10], []]); 
<immutable digraph with 3 vertices, 2 edges>
gap> DigraphMaximumFlow(d, 2, 3);
rec( flows := [ [  ], [  ], [ 10 ] ], maxFlow := 10, 
  parents := [ [  ], [  ], [ 2 ] ] )

# sink has out neighbours
gap> d := EdgeWeightedDigraph([[2], [3], [2]], [[5], [10], [7]]);
<immutable digraph with 3 vertices, 3 edges>
gap> DigraphMaximumFlow(d, 2, 3);                           
rec( flows := [ [  ], [  ], [ 10 ] ], maxFlow := 10, 
  parents := [ [  ], [  ], [ 2 ] ] )

# cycle
gap> d := EdgeWeightedDigraph([[2], [3], [1]], [[5], [10], [7]]);
<immutable digraph with 3 vertices, 3 edges>
gap> DigraphMaximumFlow(d, 1, 3);
rec( flows := [ [  ], [ 5 ], [ 5 ] ], maxFlow := 5, 
  parents := [ [  ], [ 1 ], [ 2 ] ] )

# random edge weighted digraph creation
gap> d := RandomUniqueEdgeWeightedDigraph(5);;
gap> DigraphNrVertices(d);
5
gap> OutNeighbours(d);
[ [ 1, 2, 3, 4, 5 ], [ 1, 2, 3, 4, 5 ], [ 1, 2, 3, 4, 5 ], [ 1, 2, 3, 4, 5 ], 
  [ 1, 2, 3, 4, 5 ] ]

# more random edge weighted digraph creation tests
gap> d := RandomUniqueEdgeWeightedDigraph(5, 0.1);;
gap> DigraphNrVertices(d);                         
5

# more random edge weighted digraph creation tests
gap> d := RandomUniqueEdgeWeightedDigraph(IsStronglyConnectedDigraph, 5, 0.1);;
gap> DigraphNrVertices(d);
5

# dot tests
gap> d := EdgeWeightedDigraph([[2], [1]], [[5], [10]]);;
gap> sp := DigraphEdgeWeightedShortestPath(d, 1);;
gap> sd := DigraphFromPaths(d, sp);;
gap> DotEdgeWeightedDigraph(d, sd, rec(sourceColour := "red"));;

# dot tests
gap> d := EdgeWeightedDigraph([[2], [1]], [[5], [10]]);;
gap> sp := DigraphEdgeWeightedShortestPath(d, 1);;
gap> sd := DigraphFromPaths(d, sp);;
gap> DotEdgeWeightedDigraph(d, sd, rec(source := 1));;

# dot tests
gap> d := EdgeWeightedDigraph([[2], [1]], [[5], [10]]);;
gap> sp := DigraphEdgeWeightedShortestPath(d, 1);;
gap> sd := DigraphFromPaths(d, sp);;
gap> DotEdgeWeightedDigraph(d, sd, rec(source := 500));
Error, source vertex does not exist,

# dot tests
gap> d := EdgeWeightedDigraph([[2], [1]], [[5], [10]]);;
gap> sp := DigraphEdgeWeightedShortestPath(d, 1);;
gap> sd := DigraphFromPaths(d, sp);;
gap> DotEdgeWeightedDigraph(d, sd, rec(dest := 2));;

# dot tests
gap> d := EdgeWeightedDigraph([[2], [1]], [[5], [10]]);;
gap> sp := DigraphEdgeWeightedShortestPath(d, 1);;
gap> sd := DigraphFromPaths(d, sp);;
gap> DotEdgeWeightedDigraph(d, sd, rec(dest := 500));
Error, destination vertex does not exist,

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/weights.tst", 0);
