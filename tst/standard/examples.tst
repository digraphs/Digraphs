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
<immutable digraph with 16 vertices, 48 edges>
gap> D := GeneralisedPetersenGraph(8, 3);
<immutable symmetric digraph with 16 vertices, 48 edges>
gap> IsIsomorphicDigraph(D, G8_3);
true

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

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/examples.tst", 0);
