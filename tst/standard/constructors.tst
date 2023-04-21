#############################################################################
##
#W  standard/constructors.tst
#Y  Copyright (C) 2019                                  James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/constructors.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

# BipartiteDoubleDigraph
gap> n := 5;
5
gap> adj := function(x, y)
> return ((x + 1) mod n) = (y mod n);
> end;
function( x, y ) ... end
gap> group := CyclicGroup(IsPermGroup, n);
Group([ (1,2,3,4,5) ])
gap> digraph := Digraph(group, [1 .. n], \^, adj);
<immutable digraph with 5 vertices, 5 edges>
gap> bddigraph := BipartiteDoubleDigraph(digraph);
<immutable digraph with 10 vertices, 10 edges>
gap> bdgroup := DigraphGroup(bddigraph);
Group([ (1,2,3,4,5)(6,7,8,9,10), (1,6)(2,7)(3,8)(4,9)(5,10) ])

#  DoubleDigraph
gap> out := [[2, 3, 4], [], [], []];
[ [ 2, 3, 4 ], [  ], [  ], [  ] ]
gap> group := Group([(2, 3), (2, 4)]);
Group([ (2,3), (2,4) ])
gap> digraph := Digraph(out);
<immutable digraph with 4 vertices, 3 edges>
gap> SetDigraphGroup(digraph, group);
gap> ddigraph := BipartiteDoubleDigraph(digraph);
<immutable digraph with 8 vertices, 6 edges>
gap> DigraphGroup(ddigraph);
Group([ (2,3)(6,7), (2,4)(6,8), (1,5)(2,6)(3,7)(4,8) ])
gap> ddigraph := DoubleDigraph(digraph);
<immutable digraph with 8 vertices, 12 edges>
gap> DigraphGroup(ddigraph);
Group([ (2,3)(6,7), (2,4)(6,8), (1,5)(2,6)(3,7)(4,8) ])

#  (Bipartite)DoubleDigraph with multidigraph
gap> gr := Digraph([[2, 3], [1], []]);;
gap> gr2 := DoubleDigraph(gr);
<immutable digraph with 6 vertices, 12 edges>
gap> OutNeighbours(gr2);
[ [ 2, 3, 5, 6 ], [ 1, 4 ], [  ], [ 5, 6, 2, 3 ], [ 4, 1 ], [  ] ]
gap> gr2 := BipartiteDoubleDigraph(gr);
<immutable digraph with 6 vertices, 6 edges>
gap> OutNeighbours(gr2);
[ [ 5, 6 ], [ 4 ], [  ], [ 2, 3 ], [ 1 ], [  ] ]
gap> gr := Digraph([[2, 2, 3], [1], []]);;
gap> gr2 := DoubleDigraph(gr);
<immutable multidigraph with 6 vertices, 16 edges>
gap> OutNeighbours(gr2);
[ [ 2, 2, 3, 5, 5, 6 ], [ 1, 4 ], [  ], [ 5, 5, 6, 2, 2, 3 ], [ 4, 1 ], [  ] ]
gap> gr2 := BipartiteDoubleDigraph(gr);
<immutable multidigraph with 6 vertices, 8 edges>
gap> OutNeighbours(gr2);
[ [ 5, 5, 6 ], [ 4 ], [  ], [ 2, 2, 3 ], [ 1 ], [  ] ]

#  DistanceDigraph
gap> out := [[70, 79, 103], [76, 92, 116], [77, 93, 117],
> [78, 94, 118], [66, 71, 88], [89, 106, 107], [89, 108, 125],
> [90, 109, 126], [91, 109, 110], [64, 67, 98], [104, 115, 119],
> [100, 104, 114], [76, 120, 124], [81, 86, 113], [81, 105, 120],
> [87, 94, 121], [86, 93, 122], [64, 65, 72], [118, 123, 124],
> [99, 102, 105], [85, 99, 101], [88, 117, 126], [77, 102, 121],
> [72, 75, 97], [91, 96, 123], [72, 108, 119], [96, 102, 108],
> [101, 107, 110], [75, 79, 111], [65, 68, 80], [65, 66, 81],
> [67, 69, 82], [112, 125, 126], [103, 113, 125], [67, 93, 106],
> [98, 103, 118], [70, 110, 115], [90, 105, 111], [80, 85, 112],
> [82, 87, 112], [80, 100, 123], [82, 115, 120], [100, 106, 111],
> [114, 116, 121], [85, 92, 122], [68, 73, 74], [69, 74, 95],
> [68, 70, 77], [69, 71, 96], [95, 113, 114], [97, 117, 124],
> [71, 79, 92], [64, 109, 116], [78, 119, 122], [95, 97, 101],
> [74, 78, 90], [66, 94, 107], [73, 83, 84], [75, 84, 87],
> [73, 76, 89], [84, 86, 91], [83, 98, 99], [83, 88, 104],
> [10, 18, 53], [18, 30, 31], [5, 31, 57], [10, 32, 35],
> [30, 46, 48], [32, 47, 49], [1, 37, 48], [5, 49, 52],
> [18, 24, 26], [46, 58, 60], [46, 47, 56], [24, 29, 59],
> [2, 13, 60], [3, 23, 48], [4, 54, 56], [1, 29, 52],
> [30, 39, 41], [14, 15, 31], [32, 40, 42], [58, 62, 63],
> [58, 59, 61], [21, 39, 45], [14, 17, 61], [16, 40, 59],
> [5, 22, 63], [6, 7, 60], [8, 38, 56], [9, 25, 61], [2, 45, 52],
> [3, 17, 35], [4, 16, 57], [47, 50, 55], [25, 27, 49],
> [24, 51, 55], [10, 36, 62], [20, 21, 62], [12, 41, 43], [21, 28, 55],
> [20, 23, 27], [1, 34, 36], [11, 12, 63], [15, 20, 38],
> [6, 35, 43], [6, 28, 57], [7, 26, 27], [8, 9, 53], [9, 28, 37],
> [29, 38, 43], [33, 39, 40], [14, 34, 50], [12, 44, 50],
> [11, 37, 42], [2, 44, 53], [3, 22, 51], [4, 19, 36],
> [11, 26, 54], [13, 15, 42], [16, 23, 44], [17, 45, 54],
> [19, 25, 41], [13, 19, 51], [7, 33, 34], [8, 22, 33]];;
gap> digraph := Digraph(out);
<immutable digraph with 126 vertices, 378 edges>
gap> DigraphDiameter(digraph);
6
gap> DistanceDigraph(digraph, 4);
<immutable digraph with 126 vertices, 3024 edges>
gap> DistanceDigraph(digraph, [1, 3, 5]);
<immutable digraph with 126 vertices, 7938 edges>
gap> gr := DistanceDigraph(digraph, 0);
<immutable digraph with 126 vertices, 126 edges>
gap> OutNeighbours(gr) = List([1 .. 126], x -> [x]);
true

#  DistanceDigraph with known automorphisms
gap> gr := Digraph([[1, 2], [], [2, 3]]);;
gap> DigraphGroup(gr) = Group((1, 3));
true
gap> OutNeighbours(DistanceDigraph(gr, 0));
[ [ 1 ], [ 2 ], [ 3 ] ]
gap> OutNeighbours(DistanceDigraph(gr, 1));
[ [ 2 ], [  ], [ 2 ] ]
gap> OutNeighbours(DistanceDigraph(gr, 2));
[ [  ], [  ], [  ] ]

#  DistanceDigraph: bad input
gap> gr := Digraph([[1, 2], [2, 3], [4], [1]]);;
gap> DistanceDigraph(gr, -2);
Error, the 2nd argument <distance> must be a non-negative integer,

#  LineDigraph
gap> gr := LineUndirectedDigraph(CompleteDigraph(3));
<immutable digraph with 3 vertices, 6 edges>
gap> gr = CompleteDigraph(3);
true
gap> gr := LineDigraph(CompleteDigraph(3));
<immutable digraph with 6 vertices, 12 edges>
gap> OutNeighbours(gr);
[ [ 3, 4 ], [ 5, 6 ], [ 1, 2 ], [ 6, 5 ], [ 2, 1 ], [ 4, 3 ] ]
gap> gr := LineUndirectedDigraph(CompleteDigraph(4));;
gap> OutNeighbours(gr);
[ [ 2, 4, 5, 3 ], [ 3, 6, 4, 1 ], [ 5, 1, 2, 6 ], [ 5, 6, 2, 1 ], 
  [ 1, 3, 6, 4 ], [ 2, 3, 5, 4 ] ]
gap> gr := Digraph([[2, 4], [1, 3, 4], [2, 4], [1, 2, 3]]);
<immutable digraph with 4 vertices, 10 edges>
gap> gr2 := LineUndirectedDigraph(gr);
<immutable digraph with 5 vertices, 16 edges>
gap> OutNeighbours(gr2);
[ [ 2, 3, 4 ], [ 1, 4, 5 ], [ 1, 4, 5 ], [ 1, 2, 3, 5 ], [ 2, 3, 4 ] ]
gap> gr := Digraph([[2, 4], [3], [1, 2, 4], [3]]);
<immutable digraph with 4 vertices, 7 edges>
gap> gr2 := LineDigraph(gr);
<immutable digraph with 7 vertices, 12 edges>
gap> OutNeighbours(gr2);
[ [ 3 ], [ 7 ], [ 4, 5, 6 ], [ 1, 2 ], [ 3 ], [ 7 ], [ 4, 5, 6 ] ]
gap> gr := CompleteDigraph(6);;
gap> gr2 := LineUndirectedDigraph(gr);
<immutable digraph with 15 vertices, 120 edges>
gap> DigraphGroup(gr) = SymmetricGroup(6);
true
gap> gr3 := LineUndirectedDigraph(gr);
<immutable digraph with 15 vertices, 120 edges>
gap> gr2 = gr3;
true
gap> gr := CycleDigraph(8);
<immutable cycle digraph with 8 vertices>
gap> gr2 := LineDigraph(gr);
<immutable digraph with 8 vertices, 8 edges>
gap> DigraphGroup(gr);
Group([ (1,2,3,4,5,6,7,8) ])
gap> gr3 := LineDigraph(gr);
<immutable digraph with 8 vertices, 8 edges>
gap> gr2 = gr3;
true
gap> gr := ChainDigraph(4);
<immutable chain digraph with 4 vertices>
gap> LineUndirectedDigraph(gr);
Error, the argument <D> must be a symmetric digraph,

#  DIGRAPHS_UnbindVariables
gap> Unbind(adj);
gap> Unbind(bddigraph);
gap> Unbind(bdgroup);
gap> Unbind(ddigraph);
gap> Unbind(digraph);
gap> Unbind(gr);
gap> Unbind(gr2);
gap> Unbind(gr3);
gap> Unbind(group);
gap> Unbind(n);
gap> Unbind(out);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/constructors.tst", 0);
