#############################################################################
##
#W  standard/examples.tst
#Y  Copyright (C) 2019                                   Murray T. Whyte
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/examples.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

# PetersenGraph
gap> ChromaticNumber(PetersenGraph());
3
gap> DigraphGirth(PetersenGraph());
2
gap> PetersenGraph(IsMutableDigraph);
<mutable digraph with 10 vertices, 30 edges>

# GeneralisedPetersenGraph
gap> D := GeneralisedPetersenGraph(8, 3);
<immutable symmetric digraph with 16 vertices, 48 edges>
gap> IsBipartiteDigraph(D);
true
gap> D := GeneralisedPetersenGraph(15, 7);
<immutable symmetric digraph with 30 vertices, 90 edges>
gap> IsBipartiteDigraph(D);
false
gap> D := GeneralisedPetersenGraph(10, 2);
<immutable symmetric digraph with 20 vertices, 60 edges>
gap> IsVertexTransitive(D);
true
gap> D := GeneralisedPetersenGraph(11, 2);
<immutable symmetric digraph with 22 vertices, 66 edges>
gap> IsVertexTransitive(D);
false
gap> D := GeneralisedPetersenGraph(5, 2);
<immutable symmetric digraph with 10 vertices, 30 edges>
gap> IsIsomorphicDigraph(D, PetersenGraph());
true
gap> G8_3 := DigraphFromGraph6String("OCQa`Q?OH?a@A@@?_OGB@");
<immutable symmetric digraph with 16 vertices, 48 edges>
gap> D := GeneralisedPetersenGraph(8, 3);
<immutable symmetric digraph with 16 vertices, 48 edges>
gap> IsIsomorphicDigraph(D, G8_3);
true
gap> D := GeneralisedPetersenGraph(1, -1);
Error, the argument <k> must be a non-negative integer,
gap> D := GeneralisedPetersenGraph(-1, 1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `GeneralisedPetersenGraph' on 2 argument\
s
gap> D := GeneralisedPetersenGraph(8, 5);
Error, the argument <k> must be less than or equal to <n> / 2,
gap> D := GeneralisedPetersenGraph(8, 4);
<immutable symmetric digraph with 16 vertices, 40 edges>

#  CompleteDigraph
gap> gr := CompleteDigraph(5);
<immutable complete digraph with 5 vertices>
gap> AutomorphismGroup(gr) = SymmetricGroup(5);
true
gap> CompleteDigraph(1) = EmptyDigraph(1);
true
gap> CompleteDigraph(0);
<immutable empty digraph with 0 vertices>
gap> CompleteDigraph(-1);
Error, the argument <n> must be a non-negative integer,
gap> CompleteDigraph(IsMutableDigraph, 10);
<mutable digraph with 10 vertices, 90 edges>

#  EmptyDigraph
gap> gr := EmptyDigraph(5);
<immutable empty digraph with 5 vertices>
gap> AutomorphismGroup(gr) = SymmetricGroup(5);
true
gap> EmptyDigraph(0);
<immutable empty digraph with 0 vertices>
gap> EmptyDigraph(-1);
Error, the argument <n> must be a non-negative integer,
gap> EmptyDigraph(IsMutableDigraph, -1);
Error, the argument <n> must be a non-negative integer,

#  CycleDigraph
gap> gr := CycleDigraph(0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `CycleDigraph' on 1 arguments
gap> gr := CycleDigraph(1);
<immutable digraph with 1 vertex, 1 edge>
gap> AutomorphismGroup(gr) = Group(());
true
gap> gr := CycleDigraph(6);;
gap> AutomorphismGroup(gr) = Group((1, 2, 3, 4, 5, 6));
true
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 4, 5 ], [ 5, 6 ], [ 6, 1 ] ]
gap> gr := CycleDigraph(1000);
<immutable cycle digraph with 1000 vertices>
gap> gr := CycleDigraph(IsMutableDigraph, 6);
<mutable digraph with 6 vertices, 6 edges>
gap> gr = DigraphCycle(IsImmutableDigraph, 6);
true

#  ChainDigraph
gap> gr := ChainDigraph(0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ChainDigraph' on 1 arguments
gap> gr := ChainDigraph(1);
<immutable empty digraph with 1 vertex>
gap> IsEmptyDigraph(gr);
true
gap> gr = EmptyDigraph(1);
true
gap> gr := ChainDigraph(2);
<immutable chain digraph with 2 vertices>
gap> AutomorphismGroup(gr) = Group(());
true
gap> HasIsTransitiveDigraph(gr);
true
gap> IsTransitiveDigraph(gr);
true
gap> gr := ChainDigraph(10);
<immutable chain digraph with 10 vertices>
gap> OutNeighbours(gr);
[ [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ], [  ] ]
gap> AutomorphismGroup(gr) = Group(());
true
gap> grrt := DigraphReflexiveTransitiveClosure(gr);
<immutable preorder digraph with 10 vertices, 55 edges>
gap> IsPartialOrderBinaryRelation(AsBinaryRelation(grrt));
true
gap> IsAntisymmetricDigraph(grrt);
true
gap> grrt;
<immutable partial order digraph with 10 vertices, 55 edges>
gap> ChainDigraph(IsMutableDigraph, 10);
<mutable digraph with 10 vertices, 9 edges>

#  CompleteBipartiteDigraph
gap> gr := CompleteBipartiteDigraph(2, 0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `CompleteBipartiteDigraph' on 2 argument\
s
gap> gr := CompleteBipartiteDigraph(0, 2);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `CompleteBipartiteDigraph' on 2 argument\
s
gap> gr := CompleteBipartiteDigraph(4, 3);
<immutable complete bipartite digraph with bicomponent sizes 4 and 3>
gap> AutomorphismGroup(gr) = Group((1, 2, 3, 4), (1, 2), (5, 6, 7), (5, 6));
true
gap> DigraphEdges(gr);
[ [ 1, 5 ], [ 1, 6 ], [ 1, 7 ], [ 2, 5 ], [ 2, 6 ], [ 2, 7 ], [ 3, 5 ], 
  [ 3, 6 ], [ 3, 7 ], [ 4, 5 ], [ 4, 6 ], [ 4, 7 ], [ 5, 1 ], [ 5, 2 ], 
  [ 5, 3 ], [ 5, 4 ], [ 6, 1 ], [ 6, 2 ], [ 6, 3 ], [ 6, 4 ], [ 7, 1 ], 
  [ 7, 2 ], [ 7, 3 ], [ 7, 4 ] ]
gap> gr := CompleteBipartiteDigraph(4, 4);
<immutable complete bipartite digraph with bicomponent sizes 4 and 4>
gap> AutomorphismGroup(gr) = Group((1, 2, 3, 4), (1, 2), (5, 6, 7, 8), (5, 6),
>                                  (1, 5)(2, 6)(3, 7)(4, 8));
true

#  CompleteMultipartiteDigraph
gap> CompleteMultipartiteDigraph([5, 4, 2]);
<immutable complete multipartite digraph with 11 vertices, 76 edges>
gap> CompleteMultipartiteDigraph([5, 4, 2, 10, 1000]);
<immutable complete multipartite digraph with 1021 vertices, 42296 edges>
gap> CompleteMultipartiteDigraph([5]);
<immutable empty digraph with 5 vertices>
gap> CompleteMultipartiteDigraph([]);
<immutable empty digraph with 0 vertices>
gap> CompleteMultipartiteDigraph([5, 4, 2, 10, -5]);
Error, the argument <list> must be a list of positive integers,
gap> CompleteMultipartiteDigraph([5, 0, 2]);
Error, the argument <list> must be a list of positive integers,
gap> DigraphEdges(CompleteMultipartiteDigraph([3, 2]));
[ [ 1, 4 ], [ 1, 5 ], [ 2, 4 ], [ 2, 5 ], [ 3, 4 ], [ 3, 5 ], [ 4, 1 ], 
  [ 4, 2 ], [ 4, 3 ], [ 5, 1 ], [ 5, 2 ], [ 5, 3 ] ]
gap> DigraphVertices(CompleteMultipartiteDigraph([2, 1, 2]));
[ 1 .. 5 ]
gap> DigraphEdges(CompleteMultipartiteDigraph([7, 8, 2]));
[ [ 1, 8 ], [ 1, 9 ], [ 1, 10 ], [ 1, 11 ], [ 1, 12 ], [ 1, 13 ], [ 1, 14 ], 
  [ 1, 15 ], [ 1, 16 ], [ 1, 17 ], [ 2, 8 ], [ 2, 9 ], [ 2, 10 ], [ 2, 11 ], 
  [ 2, 12 ], [ 2, 13 ], [ 2, 14 ], [ 2, 15 ], [ 2, 16 ], [ 2, 17 ], [ 3, 8 ], 
  [ 3, 9 ], [ 3, 10 ], [ 3, 11 ], [ 3, 12 ], [ 3, 13 ], [ 3, 14 ], [ 3, 15 ], 
  [ 3, 16 ], [ 3, 17 ], [ 4, 8 ], [ 4, 9 ], [ 4, 10 ], [ 4, 11 ], [ 4, 12 ], 
  [ 4, 13 ], [ 4, 14 ], [ 4, 15 ], [ 4, 16 ], [ 4, 17 ], [ 5, 8 ], [ 5, 9 ], 
  [ 5, 10 ], [ 5, 11 ], [ 5, 12 ], [ 5, 13 ], [ 5, 14 ], [ 5, 15 ], 
  [ 5, 16 ], [ 5, 17 ], [ 6, 8 ], [ 6, 9 ], [ 6, 10 ], [ 6, 11 ], [ 6, 12 ], 
  [ 6, 13 ], [ 6, 14 ], [ 6, 15 ], [ 6, 16 ], [ 6, 17 ], [ 7, 8 ], [ 7, 9 ], 
  [ 7, 10 ], [ 7, 11 ], [ 7, 12 ], [ 7, 13 ], [ 7, 14 ], [ 7, 15 ], 
  [ 7, 16 ], [ 7, 17 ], [ 8, 1 ], [ 8, 2 ], [ 8, 3 ], [ 8, 4 ], [ 8, 5 ], 
  [ 8, 6 ], [ 8, 7 ], [ 8, 16 ], [ 8, 17 ], [ 9, 1 ], [ 9, 2 ], [ 9, 3 ], 
  [ 9, 4 ], [ 9, 5 ], [ 9, 6 ], [ 9, 7 ], [ 9, 16 ], [ 9, 17 ], [ 10, 1 ], 
  [ 10, 2 ], [ 10, 3 ], [ 10, 4 ], [ 10, 5 ], [ 10, 6 ], [ 10, 7 ], 
  [ 10, 16 ], [ 10, 17 ], [ 11, 1 ], [ 11, 2 ], [ 11, 3 ], [ 11, 4 ], 
  [ 11, 5 ], [ 11, 6 ], [ 11, 7 ], [ 11, 16 ], [ 11, 17 ], [ 12, 1 ], 
  [ 12, 2 ], [ 12, 3 ], [ 12, 4 ], [ 12, 5 ], [ 12, 6 ], [ 12, 7 ], 
  [ 12, 16 ], [ 12, 17 ], [ 13, 1 ], [ 13, 2 ], [ 13, 3 ], [ 13, 4 ], 
  [ 13, 5 ], [ 13, 6 ], [ 13, 7 ], [ 13, 16 ], [ 13, 17 ], [ 14, 1 ], 
  [ 14, 2 ], [ 14, 3 ], [ 14, 4 ], [ 14, 5 ], [ 14, 6 ], [ 14, 7 ], 
  [ 14, 16 ], [ 14, 17 ], [ 15, 1 ], [ 15, 2 ], [ 15, 3 ], [ 15, 4 ], 
  [ 15, 5 ], [ 15, 6 ], [ 15, 7 ], [ 15, 16 ], [ 15, 17 ], [ 16, 1 ], 
  [ 16, 2 ], [ 16, 3 ], [ 16, 4 ], [ 16, 5 ], [ 16, 6 ], [ 16, 7 ], 
  [ 16, 8 ], [ 16, 9 ], [ 16, 10 ], [ 16, 11 ], [ 16, 12 ], [ 16, 13 ], 
  [ 16, 14 ], [ 16, 15 ], [ 17, 1 ], [ 17, 2 ], [ 17, 3 ], [ 17, 4 ], 
  [ 17, 5 ], [ 17, 6 ], [ 17, 7 ], [ 17, 8 ], [ 17, 9 ], [ 17, 10 ], 
  [ 17, 11 ], [ 17, 12 ], [ 17, 13 ], [ 17, 14 ], [ 17, 15 ] ]

#  JohnsonDigraph
gap> JohnsonDigraph(0, 4);
<immutable empty digraph with 0 vertices>
gap> JohnsonDigraph(0, 0);
<immutable empty digraph with 1 vertex>
gap> JohnsonDigraph(3, 0);
<immutable empty digraph with 1 vertex>
gap> JohnsonDigraph(1, 0);
<immutable empty digraph with 1 vertex>
gap> gr := JohnsonDigraph(3, 1);
<immutable symmetric digraph with 3 vertices, 6 edges>
gap> OutNeighbours(gr);
[ [ 2, 3 ], [ 1, 3 ], [ 1, 2 ] ]
gap> gr := JohnsonDigraph(4, 2);
<immutable symmetric digraph with 6 vertices, 24 edges>
gap> OutNeighbours(gr);
[ [ 2, 3, 4, 5 ], [ 1, 3, 4, 6 ], [ 1, 2, 5, 6 ], [ 1, 2, 5, 6 ], 
  [ 1, 3, 4, 6 ], [ 2, 3, 4, 5 ] ]
gap> JohnsonDigraph(5, 1) = CompleteDigraph(5);
true
gap> JohnsonDigraph(3, -2);
Error, the arguments <n> and <k> must be non-negative integers,
gap> JohnsonDigraph(-1, 2);
Error, the arguments <n> and <k> must be non-negative integers,
gap> JohnsonDigraph(IsMutableDigraph, 4, 2);
<mutable digraph with 6 vertices, 24 edges>

# LollipopGraph
gap> LollipopGraph(5, 4);
<immutable connected symmetric digraph with 9 vertices, 28 edges>
gap> LollipopGraph(8, 4);
<immutable connected symmetric digraph with 12 vertices, 64 edges>
gap> D := LollipopGraph(5, 3);
<immutable connected symmetric digraph with 8 vertices, 26 edges>
gap> DigraphNrVertices(D);
8
gap> DigraphNrEdges(D);
26
gap> DigraphNrAdjacencies(D);
13
gap> DigraphUndirectedGirth(D);
3
gap> LollipopGraph(IsMutableDigraph, 5, 3);
<mutable digraph with 8 vertices, 26 edges>

#  SquareGridGraph
gap> SquareGridGraph(7, 7);
<immutable connected bipartite symmetric digraph with bicomponent sizes 25 and\
 24>
gap> SquareGridGraph(2, 4);
<immutable connected bipartite symmetric digraph with bicomponent sizes 4 and \
4>
gap> SquareGridGraph(IsMutableDigraph, 5, 3);
<mutable digraph with 15 vertices, 44 edges>
gap> SquareGridGraph(IsImmutableDigraph, 1, 1);
<immutable empty digraph with 1 vertex>
gap> SquareGridGraph(1, 4);
<immutable connected bipartite symmetric digraph with bicomponent sizes 2 and \
2>
gap> SquareGridGraph(2, 1);
<immutable connected bipartite symmetric digraph with bicomponent sizes 1 and \
1>

#  TriangularGridGraph
gap> TriangularGridGraph(3, 4);
<immutable connected symmetric digraph with 12 vertices, 46 edges>
gap> TriangularGridGraph(IsMutableDigraph, 7, 2);
<mutable digraph with 14 vertices, 50 edges>
gap> TriangularGridGraph(1, 1);
<immutable empty digraph with 1 vertex>
gap> TriangularGridGraph(1, 5);
<immutable connected bipartite symmetric digraph with bicomponent sizes 3 and \
2>
gap> TriangularGridGraph(3, 1);
<immutable connected bipartite symmetric digraph with bicomponent sizes 2 and \
1>

# StarGraph
gap> StarGraph(IsMutable, 10);
<mutable digraph with 10 vertices, 18 edges>
gap> StarGraph(IsImmutableDigraph, 10);
<immutable complete bipartite digraph with bicomponent sizes 1 and 9>
gap> StarGraph(3);
<immutable complete bipartite digraph with bicomponent sizes 1 and 2>
gap> StarGraph(1);
<immutable empty digraph with 1 vertex>
gap> IsSymmetricDigraph(StarGraph(3));
true
gap> IsMultiDigraph(StarGraph(3));
false

#  KingsGraph
gap> KingsGraph(8, 8);
<immutable connected symmetric digraph with 64 vertices, 420 edges>
gap> D := KingsGraph(4, 7);
<immutable connected symmetric digraph with 28 vertices, 162 edges>
gap> IsConnectedDigraph(D);
true
gap> D := KingsGraph(2, 2);
<immutable connected symmetric digraph with 4 vertices, 12 edges>
gap> OutNeighbors(D);
[ [ 2, 3, 4 ], [ 1, 4, 3 ], [ 4, 1, 2 ], [ 3, 2, 1 ] ]
gap> DigraphVertexLabels(KingsGraph(3, 4));
[ [ 1, 1 ], [ 2, 1 ], [ 3, 1 ], [ 1, 2 ], [ 2, 2 ], [ 3, 2 ], [ 1, 3 ], 
  [ 2, 3 ], [ 3, 3 ], [ 1, 4 ], [ 2, 4 ], [ 3, 4 ] ]

#  QueensGraph
gap> QueensGraph(5, 2);
<immutable connected symmetric digraph with 10 vertices, 66 edges>
gap> QueensGraph(3, 4);
<immutable connected symmetric digraph with 12 vertices, 92 edges>
gap> D := QueensGraph(2, 3);
<immutable connected symmetric digraph with 6 vertices, 26 edges>
gap> OutNeighbours(D);
[ [ 2, 3, 5, 4 ], [ 1, 4, 6, 3 ], [ 4, 1, 5, 2, 6 ], [ 3, 2, 6, 1, 5 ], 
  [ 6, 1, 3, 4 ], [ 5, 2, 4, 3 ] ]
gap> DigraphVertexLabels(QueensGraph(3, 4));
[ [ 1, 1 ], [ 2, 1 ], [ 3, 1 ], [ 1, 2 ], [ 2, 2 ], [ 3, 2 ], [ 1, 3 ], 
  [ 2, 3 ], [ 3, 3 ], [ 1, 4 ], [ 2, 4 ], [ 3, 4 ] ]

#  RooksGraph
gap> RooksGraph(4, 8);
<immutable connected regular symmetric digraph with 32 vertices, 320 edges>
gap> D := RooksGraph(3, 2);
<immutable connected regular symmetric digraph with 6 vertices, 18 edges>
gap> IsPlanarDigraph(D);
true
gap> OutNeighbours(D);
[ [ 2, 3, 4 ], [ 1, 3, 5 ], [ 1, 2, 6 ], [ 5, 6, 1 ], [ 4, 6, 2 ], 
  [ 4, 5, 3 ] ]
gap> DigraphVertexLabels(RooksGraph(3, 4));
[ [ 1, 1 ], [ 2, 1 ], [ 3, 1 ], [ 1, 2 ], [ 2, 2 ], [ 3, 2 ], [ 1, 3 ], 
  [ 2, 3 ], [ 3, 3 ], [ 1, 4 ], [ 2, 4 ], [ 3, 4 ] ]

#  BishopsGraph
gap> D := BishopsGraph("dark", 7, 9);
<immutable connected symmetric digraph with 32 vertices, 272 edges>
gap> IsConnectedDigraph(D);
true
gap> DigraphVertexLabels(D);
[ [ 1, 1 ], [ 3, 1 ], [ 5, 1 ], [ 7, 1 ], [ 2, 2 ], [ 4, 2 ], [ 6, 2 ], 
  [ 1, 3 ], [ 3, 3 ], [ 5, 3 ], [ 7, 3 ], [ 2, 4 ], [ 4, 4 ], [ 6, 4 ], 
  [ 1, 5 ], [ 3, 5 ], [ 5, 5 ], [ 7, 5 ], [ 2, 6 ], [ 4, 6 ], [ 6, 6 ], 
  [ 1, 7 ], [ 3, 7 ], [ 5, 7 ], [ 7, 7 ], [ 2, 8 ], [ 4, 8 ], [ 6, 8 ], 
  [ 1, 9 ], [ 3, 9 ], [ 5, 9 ], [ 7, 9 ] ]
gap> D := BishopGraph("light", 4, 3);
<immutable connected symmetric digraph with 6 vertices, 16 edges>
gap> OutNeighbours(D);
[ [ 3, 4, 6 ], [ 4, 5 ], [ 1, 5 ], [ 1, 2, 5, 6 ], [ 2, 3, 4 ], [ 1, 4 ] ]
gap> BishopsGraph("blue", 8, 4);
Error, the argument <color> must be "dark", "light", or "both"
gap> D := BishopsGraph(5, 4);
<immutable symmetric digraph with 20 vertices, 80 edges>
gap> IsConnectedDigraph(D);
false
gap> OutNeighbours(D);
[ [ 7, 13, 19 ], [ 6, 8, 14, 20 ], [ 7, 9, 11, 15 ], [ 8, 10, 12, 16 ], 
  [ 9, 13, 17 ], [ 2, 12, 18 ], [ 1, 3, 11, 13, 19 ], 
  [ 2, 4, 12, 14, 16, 20 ], [ 3, 5, 13, 15, 17 ], [ 4, 14, 18 ], 
  [ 3, 7, 17 ], [ 4, 6, 8, 16, 18 ], [ 1, 5, 7, 9, 17, 19 ], 
  [ 2, 8, 10, 18, 20 ], [ 3, 9, 19 ], [ 4, 8, 12 ], [ 5, 9, 11, 13 ], 
  [ 6, 10, 12, 14 ], [ 1, 7, 13, 15 ], [ 2, 8, 14 ] ]
gap> DigraphVertexLabels(BishopsGraph(3, 4));
[ [ 1, 1 ], [ 2, 1 ], [ 3, 1 ], [ 1, 2 ], [ 2, 2 ], [ 3, 2 ], [ 1, 3 ], 
  [ 2, 3 ], [ 3, 3 ], [ 1, 4 ], [ 2, 4 ], [ 3, 4 ] ]

#  Knight's Graph
gap> D := KnightsGraph(8, 8);
<immutable connected symmetric digraph with 64 vertices, 336 edges>
gap> IsConnectedDigraph(D);
true
gap> D := KnightsGraph(3, 3);
<immutable symmetric digraph with 9 vertices, 16 edges>
gap> IsConnectedDigraph(D);
false
gap> KnightsGraph(IsMutable, 3, 9);
<mutable digraph with 27 vertices, 88 edges>
gap> DigraphVertexLabels(KnightsGraph(3, 4));
[ [ 1, 1 ], [ 2, 1 ], [ 3, 1 ], [ 1, 2 ], [ 2, 2 ], [ 3, 2 ], [ 1, 3 ], 
  [ 2, 3 ], [ 3, 3 ], [ 1, 4 ], [ 2, 4 ], [ 3, 4 ] ]

# HaarGraph
gap> HaarGraph(1);
<immutable complete digraph with 2 vertices>
gap> OutNeighbours(last);
[ [ 2 ], [ 1 ] ]
gap> HaarGraph(2);
<immutable bipartite vertex-transitive symmetric digraph with bicomponent size\
s 2 and 2>
gap> OutNeighbours(last);
[ [ 3 ], [ 4 ], [ 1 ], [ 2 ] ]
gap> HaarGraph(3);
<immutable bipartite vertex-transitive symmetric digraph with bicomponent size\
s 2 and 2>
gap> OutNeighbours(last);
[ [ 3, 4 ], [ 3, 4 ], [ 1, 2 ], [ 1, 2 ] ]
gap> D := HaarGraph(16);
<immutable bipartite vertex-transitive symmetric digraph with bicomponent size\
s 5 and 5>
gap> IsBipartiteDigraph(D);
true

# BananaTree
gap> D := BananaTree(2, 4);
<immutable undirected tree digraph with 9 vertices>
gap> D := BananaTree(3, 3);
<immutable undirected tree digraph with 10 vertices>
gap> D := BananaTree(5, 2);
<immutable undirected tree digraph with 11 vertices>
gap> D := BananaTree(3, 4);
<immutable undirected tree digraph with 13 vertices>
gap> D := BananaTree(0, 0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `BananaTree' on 2 arguments
gap> D := BananaTree(IsMutableDigraph, 5, 3);
<mutable digraph with 16 vertices, 30 edges>
gap> BananaTree(3, 1);
Error, The second argument must be an integer greater than one

# TadpoleGraph
gap> TadpoleGraph(2, 2);
Error, the first argument <m> must be an integer greater than 2
gap> TadpoleGraph(10, 15);
<immutable symmetric digraph with 25 vertices, 50 edges>
gap> TadpoleGraph(IsMutableDigraph, 5, 6);
<mutable digraph with 11 vertices, 22 edges>
gap> IsSymmetricDigraph(TadpoleGraph(3, 5));
true
gap> TadpoleGraph(3, 1);
<immutable symmetric digraph with 4 vertices, 8 edges>

# BookGraph
gap> BookGraph(1);
<immutable bipartite symmetric digraph with bicomponent sizes 2 and 2>
gap> BookGraph(2);
<immutable bipartite symmetric digraph with bicomponent sizes 3 and 3>
gap> BookGraph(7);
<immutable bipartite symmetric digraph with bicomponent sizes 8 and 8>
gap> BookGraph(12);
<immutable bipartite symmetric digraph with bicomponent sizes 13 and 13>
gap> BookGraph(IsMutable, 12);
<mutable digraph with 26 vertices, 74 edges>
gap> IsSymmetricDigraph(BookGraph(24));
true
gap> IsBipartiteDigraph(BookGraph(32));
true

# StackedBookGraph
gap> StackedBookGraph(1, 5);
<immutable bipartite symmetric digraph with bicomponent sizes 5 and 5>
gap> StackedBookGraph(20, 10);
<immutable bipartite symmetric digraph with bicomponent sizes 105 and 105>
gap> StackedBookGraph(7, 2);
<immutable bipartite symmetric digraph with bicomponent sizes 8 and 8>
gap> StackedBookGraph(12, 1);
<immutable bipartite symmetric digraph with bicomponent sizes 1 and 12>
gap> StackedBookGraph(IsMutable, 12, 2);
<mutable digraph with 26 vertices, 74 edges>
gap> IsSymmetricDigraph(StackedBookGraph(4, 3));
true
gap> IsBipartiteDigraph(StackedBookGraph(5, 4));
true

# BinaryTree
gap> BinaryTree(4);
<immutable digraph with 15 vertices, 14 edges>

# AndrasfaiGraph
gap> D := AndrasfaiGraph(1);
<immutable Hamiltonian biconnected vertex-transitive symmetric digraph with 2 \
vertices, 2 edges>
gap> D := AndrasfaiGraph(3);
<immutable Hamiltonian biconnected vertex-transitive symmetric digraph with 8 \
vertices, 24 edges>
gap> IsIsomorphicDigraph(D, MobiusLadderGraph(4));
true
gap> AndrasfaiGraph(0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `AndrasfaiGraph' on 1 arguments

# BinomialTreeGraph
gap> D := BinomialTreeGraph(6);
<immutable undirected tree digraph with 6 vertices>
gap> D := BinomialTreeGraph(16);
<immutable undirected tree digraph with 16 vertices>
gap> DigraphEdges(D);
[ [ 1, 2 ], [ 1, 3 ], [ 1, 5 ], [ 1, 9 ], [ 2, 1 ], [ 3, 1 ], [ 3, 4 ], 
  [ 4, 3 ], [ 5, 1 ], [ 5, 6 ], [ 5, 7 ], [ 6, 5 ], [ 7, 5 ], [ 7, 8 ], 
  [ 8, 7 ], [ 9, 1 ], [ 9, 10 ], [ 9, 11 ], [ 9, 13 ], [ 10, 9 ], [ 11, 9 ], 
  [ 11, 12 ], [ 12, 11 ], [ 13, 9 ], [ 13, 14 ], [ 13, 15 ], [ 14, 13 ], 
  [ 15, 13 ], [ 15, 16 ], [ 16, 15 ] ]
gap> BinomialTreeGraph(1);
<immutable empty digraph with 1 vertex>
gap> BinomialTreeGraph(0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `BinomialTreeGraph' on 1 arguments

# BondyGraph
gap> D := BondyGraph(2);
<immutable symmetric digraph with 34 vertices, 102 edges>
gap> IsIsomorphicDigraph(D, GeneralisedPetersenGraph(17, 2));
true
gap> BondyGraph(-1);
Error, the argument <n> must be a non-negative integer,

# CirculantGraph
gap> D := CirculantGraph(5, [1, 2]);
<immutable Hamiltonian biconnected vertex-transitive symmetric digraph with 5 \
vertices, 20 edges>
gap> IsIsomorphicDigraph(D, CompleteDigraph(5));
true
gap> D := CirculantGraph(6, [2, 3]);
<immutable Hamiltonian biconnected vertex-transitive symmetric digraph with 6 \
vertices, 18 edges>
gap> IsIsomorphicDigraph(D, PrismGraph(3));
true
gap> D := CirculantGraph(4, [1]);
<immutable Hamiltonian biconnected vertex-transitive symmetric digraph with 4 \
vertices, 8 edges>
gap> IsIsomorphicDigraph(D, CycleGraph(4));
true
gap> CirculantGraph(4, [1, 5]);
Error, arguments must be an integer <n> greater than 1 and a list of integers \
between 1 and n,
gap> CirculantGraph(0, [1]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `CirculantGraph' on 2 arguments
gap> D := CirculantGraph(10, [1, 5]);
<immutable Hamiltonian biconnected vertex-transitive symmetric digraph with 10\
 vertices, 30 edges>
gap> IsIsomorphicDigraph(D, MobiusLadderGraph(5));
true

# CycleGraph
gap> IsIsomorphicDigraph(CycleGraph(5), DigraphSymmetricClosure(CycleDigraph(5)));
true
gap> CycleGraph(2);
Error, the argument <n> must be an integer greater than 2,

# GearGraph
gap> D := GearGraph(4);
<immutable symmetric digraph with 9 vertices, 24 edges>
gap> DigraphEdges(D);
[ [ 1, 2 ], [ 1, 8 ], [ 2, 1 ], [ 2, 3 ], [ 2, 9 ], [ 3, 2 ], [ 3, 4 ], 
  [ 4, 3 ], [ 4, 5 ], [ 4, 9 ], [ 5, 4 ], [ 5, 6 ], [ 6, 5 ], [ 6, 7 ], 
  [ 6, 9 ], [ 7, 6 ], [ 7, 8 ], [ 8, 1 ], [ 8, 7 ], [ 8, 9 ], [ 9, 2 ], 
  [ 9, 4 ], [ 9, 6 ], [ 9, 8 ] ]
gap> GearGraph(2);
Error, the argument <n> must be an integer greater than 2,

# HalvedCubeGraph
gap> HalvedCubeGraph(1);
<immutable empty digraph with 1 vertex>
gap> D := HalvedCubeGraph(3);
<immutable Hamiltonian connected symmetric digraph with 4 vertices, 12 edges>
gap> IsIsomorphicDigraph(D, CompleteDigraph(4));
true
gap> HalvedCubeGraph(-1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `HalvedCubeGraph' on 1 arguments

# HanoiGraph
gap> D := HanoiGraph(1);
<immutable Hamiltonian connected symmetric digraph with 3 vertices, 6 edges>
gap> IsIsomorphicDigraph(D, CycleGraph(3));
true
gap> gr := HanoiGraph(4);
<immutable Hamiltonian connected symmetric digraph with 81 vertices, 240 edges\
>
gap> IsPlanarDigraph(gr);
true
gap> IsHamiltonianDigraph(gr);
true
gap> IsPlanarDigraph(DigraphMutableCopy(gr));
true
gap> HanoiGraph(0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `HanoiGraph' on 1 arguments

# HelmGraph
gap> D := HelmGraph(6);
<immutable symmetric digraph with 13 vertices, 36 edges>
gap> DigraphEdges(D);
[ [ 1, 2 ], [ 1, 6 ], [ 1, 7 ], [ 1, 8 ], [ 2, 1 ], [ 2, 3 ], [ 2, 7 ], 
  [ 2, 9 ], [ 3, 2 ], [ 3, 4 ], [ 3, 7 ], [ 3, 10 ], [ 4, 3 ], [ 4, 5 ], 
  [ 4, 7 ], [ 4, 11 ], [ 5, 4 ], [ 5, 6 ], [ 5, 7 ], [ 5, 12 ], [ 6, 1 ], 
  [ 6, 5 ], [ 6, 7 ], [ 6, 13 ], [ 7, 1 ], [ 7, 2 ], [ 7, 3 ], [ 7, 4 ], 
  [ 7, 5 ], [ 7, 6 ], [ 8, 1 ], [ 9, 2 ], [ 10, 3 ], [ 11, 4 ], [ 12, 5 ], 
  [ 13, 6 ] ]
gap> HelmGraph(1);
Error, the argument <n> must be an integer greater than 2,

# HypercubeGraph
gap> HypercubeGraph(0);
<immutable empty digraph with 1 vertex>
gap> D := HypercubeGraph(2);
<immutable Hamiltonian connected bipartite symmetric digraph with bicomponent \
sizes 2 and 2>
gap> IsIsomorphicDigraph(D, CycleGraph(4));
true
gap> HypercubeGraph(-1);
Error, the argument <n> must be a non-negative integer,

# KellerGraph
gap> IsIsomorphicDigraph(EmptyDigraph(4), KellerGraph(1));
true
gap> D := KellerGraph(2);
<immutable Hamiltonian connected symmetric digraph with 16 vertices, 80 edges>
gap> KellerGraph(-1);
Error, the argument <n> must be a non-negative integer,

# KneserGraph
gap> IsIsomorphicDigraph(KneserGraph(5, 1), CompleteDigraph(5));
true
gap> KneserGraph(6, 3);
<immutable edge- and vertex-transitive symmetric digraph with 20 vertices, 20 \
edges>
gap> KneserGraph(3, 4);
Error, argument <n> must be greater than or equal to argument <k>,
gap> KneserGraph(3, -1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `KneserGraph' on 2 arguments
gap> KneserGraph(-1, 4);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `KneserGraph' on 2 arguments
gap> D := KneserGraph(5, 2);
<immutable edge- and vertex-transitive symmetric digraph with 10 vertices, 30 \
edges>
gap> DigraphEdges(D);
[ [ 1, 8 ], [ 1, 9 ], [ 1, 10 ], [ 2, 6 ], [ 2, 7 ], [ 2, 10 ], [ 3, 5 ], 
  [ 3, 7 ], [ 3, 9 ], [ 4, 5 ], [ 4, 6 ], [ 4, 8 ], [ 5, 3 ], [ 5, 4 ], 
  [ 5, 10 ], [ 6, 2 ], [ 6, 4 ], [ 6, 9 ], [ 7, 2 ], [ 7, 3 ], [ 7, 8 ], 
  [ 8, 1 ], [ 8, 4 ], [ 8, 7 ], [ 9, 1 ], [ 9, 3 ], [ 9, 6 ], [ 10, 1 ], 
  [ 10, 2 ], [ 10, 5 ] ]
gap> D := KneserGraph(6, 4);
<immutable empty digraph with 15 vertices>
gap> ChromaticNumber(D);
1
gap> D := KneserGraph(10, 2);
<immutable Hamiltonian connected edge- and vertex-transitive symmetric digraph\
 with 45 vertices, 1260 edges>

# LindgrenSousselierGraph
gap> D := LindgrenSousselierGraph(1);
<immutable symmetric digraph with 10 vertices, 30 edges>
gap> AutomorphismGroup(D) = Group([(4, 8)(5, 7)(9, 10), (2, 10, 9)(3, 4, 5, 6, 7, 8), (1, 2, 3, 4, 10)(5, 7, 9, 6, 8)]);
true
gap> LindgrenSousselierGraph(0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `LindgrenSousselierGraph' on 1 arguments
gap> LindgrenSousselierGraph(3);
<immutable symmetric digraph with 22 vertices, 70 edges>
gap> IsIsomorphicDigraph(LindgrenSousselierGraph(1), GeneralisedPetersenGraph(5, 2));
true

# MobiusLadderGraph
gap> MobiusLadderGraph(2);
Error, the argument <n> must be an integer equal to 4 or more,
gap> D := MobiusLadderGraph(4);
<immutable symmetric digraph with 8 vertices, 24 edges>
gap> DigraphEdges(D);
[ [ 1, 2 ], [ 1, 8 ], [ 1, 5 ], [ 2, 1 ], [ 2, 3 ], [ 2, 6 ], [ 3, 2 ], 
  [ 3, 4 ], [ 3, 7 ], [ 4, 3 ], [ 4, 5 ], [ 4, 8 ], [ 5, 4 ], [ 5, 6 ], 
  [ 5, 1 ], [ 6, 5 ], [ 6, 7 ], [ 6, 2 ], [ 7, 6 ], [ 7, 8 ], [ 7, 3 ], 
  [ 8, 1 ], [ 8, 7 ], [ 8, 4 ] ]
gap> MobiusLadderGraph(10);
<immutable symmetric digraph with 20 vertices, 60 edges>

# MycielskiGraph
gap> D := MycielskiGraph(2);
<immutable Hamiltonian connected symmetric digraph with 2 vertices, 2 edges>
gap> IsIsomorphicDigraph(MycielskiGraph(3), CycleGraph(5));
true
gap> MycielskiGraph(1);
Error, the argument <n> must be an integer greater than 1,

# OddGraph
gap> IsIsomorphicDigraph(OddGraph(2), CycleGraph(3));
true
gap> OddGraph(4);
<immutable edge- and vertex-transitive symmetric digraph with 35 vertices, 140\
 edges>
gap> OddGraph(0);
Error, the argument <n> must be an integer greater than 0,

# PathGraph
gap> D := PathGraph(4);
<immutable undirected tree digraph with 4 vertices>
gap> IsIsomorphicDigraph(D, DigraphSymmetricClosure(ChainDigraph(4)));
true
gap> PathGraph(1);
<immutable empty digraph with 1 vertex>
gap> PathGraph(0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `PathGraph' on 1 arguments

# PermutationStarGraph
gap> D := PermutationStarGraph(3, 2);
<immutable vertex-transitive symmetric digraph with 6 vertices, 12 edges>
gap> IsIsomorphicDigraph(D, CycleGraph(6));
true
gap> D := PermutationStarGraph(4, 3);
<immutable vertex-transitive symmetric digraph with 24 vertices, 72 edges>
gap> DigraphDiameter(D);
4
gap> IsIsomorphicDigraph(D, GeneralisedPetersenGraph(12, 5));
true
gap> PermutationStarGraph(2, 4);
Error, the argument <n> must be greater than or equal to <k>,
gap> PermutationStarGraph(5, -1);
Error, the arguments <n> and <k> must be integers, with n greater than 0 and k\
 non-negative,
gap> PermutationStarGraph(0, 2);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `PermutationStarGraph' on 2 arguments

# PrismGraph
gap> PrismGraph(3);
<immutable symmetric digraph with 6 vertices, 18 edges>
gap> PrismGraph(2);
Error, the argument <n> must be an integer equal to 3 or more,
gap> D := PrismGraph(5);
<immutable symmetric digraph with 10 vertices, 30 edges>
gap> DigraphEdges(D);
[ [ 1, 2 ], [ 1, 5 ], [ 1, 6 ], [ 2, 1 ], [ 2, 3 ], [ 2, 7 ], [ 3, 2 ], 
  [ 3, 4 ], [ 3, 8 ], [ 4, 3 ], [ 4, 5 ], [ 4, 9 ], [ 5, 1 ], [ 5, 4 ], 
  [ 5, 10 ], [ 6, 1 ], [ 6, 7 ], [ 6, 10 ], [ 7, 2 ], [ 7, 6 ], [ 7, 8 ], 
  [ 8, 3 ], [ 8, 7 ], [ 8, 9 ], [ 9, 4 ], [ 9, 8 ], [ 9, 10 ], [ 10, 5 ], 
  [ 10, 6 ], [ 10, 9 ] ]

# StackedPrismGraph
gap> D := StackedPrismGraph(4, 1);
<immutable symmetric digraph with 4 vertices, 8 edges>
gap> IsIsomorphicDigraph(D, CycleGraph(4));
true
gap> D := StackedPrismGraph(5, 2);
<immutable symmetric digraph with 10 vertices, 30 edges>
gap> IsIsomorphicDigraph(D, PrismGraph(5));
true
gap> StackedPrismGraph(3, 3);
<immutable symmetric digraph with 9 vertices, 30 edges>
gap> StackedPrismGraph(2, 2);
Error, the arguments <n> and <k> must be integers, with <n> greater than 2 and\
 <k> greater than 0,
gap> StackedPrismGraph(3, 0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `StackedPrismGraph' on 2 arguments
gap> StackedPrismGraph(0, -1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `StackedPrismGraph' on 2 arguments

# WalshHadamardGraph
gap> WalshHadamardGraph(1);
<immutable symmetric digraph with 4 vertices, 4 edges>
gap> D := WalshHadamardGraph(2);
<immutable symmetric digraph with 8 vertices, 16 edges>
gap> IsIsomorphicDigraph(D, CycleGraph(8));
true
gap> WalshHadamardGraph(0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `WalshHadamardGraph' on 1 arguments

# WebGraph
gap> D := WebGraph(3);
<immutable symmetric digraph with 9 vertices, 24 edges>
gap> DigraphEdges(D);
[ [ 1, 4 ], [ 2, 5 ], [ 3, 6 ], [ 4, 5 ], [ 4, 6 ], [ 4, 1 ], [ 4, 7 ], 
  [ 5, 4 ], [ 5, 6 ], [ 5, 2 ], [ 5, 8 ], [ 6, 4 ], [ 6, 5 ], [ 6, 3 ], 
  [ 6, 9 ], [ 7, 8 ], [ 7, 9 ], [ 7, 4 ], [ 8, 7 ], [ 8, 9 ], [ 8, 5 ], 
  [ 9, 7 ], [ 9, 8 ], [ 9, 6 ] ]
gap> WebGraph(2);
Error, the argument <n> must be an integer greater than 2,

# WheelGraph
gap> D := WheelGraph(5);
<immutable Hamiltonian connected symmetric digraph with 5 vertices, 16 edges>
gap> DigraphEdges(D);
[ [ 1, 2 ], [ 1, 4 ], [ 1, 5 ], [ 2, 1 ], [ 2, 3 ], [ 2, 5 ], [ 3, 2 ], 
  [ 3, 4 ], [ 3, 5 ], [ 4, 1 ], [ 4, 3 ], [ 4, 5 ], [ 5, 1 ], [ 5, 2 ], 
  [ 5, 3 ], [ 5, 4 ] ]
gap> WheelGraph(2);
Error, the argument <n> must be an integer greater than 3,
gap> ChromaticNumber(D);
3
gap> D := WheelGraph(6);
<immutable Hamiltonian connected symmetric digraph with 6 vertices, 20 edges>
gap> ChromaticNumber(D);
4

# WindmillGraph
gap> D := WindmillGraph(3, 3);
<immutable symmetric digraph with 7 vertices, 18 edges>
gap> DigraphEdges(D);
[ [ 1, 2 ], [ 1, 7 ], [ 2, 1 ], [ 2, 7 ], [ 3, 4 ], [ 3, 7 ], [ 4, 3 ], 
  [ 4, 7 ], [ 5, 6 ], [ 5, 7 ], [ 6, 5 ], [ 6, 7 ], [ 7, 1 ], [ 7, 2 ], 
  [ 7, 3 ], [ 7, 4 ], [ 7, 5 ], [ 7, 6 ] ]
gap> WindmillGraph(0, 3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `WindmillGraph' on 2 arguments
gap> WindmillGraph(2, 1);
Error, the arguments <n> and <m> must be integers greater than 1,
gap> WindmillGraph(-1, 0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `WindmillGraph' on 2 arguments

#  DIGRAPHS_UnbindVariables
gap> Unbind(D);
gap> Unbind(G8_3);
gap> Unbind(gr);
gap> Unbind(grrt);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/examples.tst", 0);
