#############################################################################
##
#W  standard/grape.tst
#Y  Copyright (C) 2019-21                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/grape.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#  CayleyDigraph
gap> group := DihedralGroup(8);
<pc group of size 8 with 3 generators>
gap> digraph := CayleyDigraph(group);
<immutable digraph with 8 vertices, 24 edges>
gap> DigraphVertexLabels(digraph) = AsList(group);
true
gap> DigraphEdgeLabels(digraph) =
> ListWithIdenticalEntries(Size(group), GeneratorsOfGroup(group));
true
gap> ForAll(DigraphEdges(digraph), e -> AsList(group)[e[1]]
> * DigraphEdgeLabel(digraph, e[1], e[2]) = AsList(group)[e[2]]);
true
gap> group := DihedralGroup(IsPermGroup, 8);
Group([ (1,2,3,4), (2,4) ])
gap> digraph := CayleyDigraph(group);
<immutable digraph with 8 vertices, 16 edges>
gap> IsCayleyDigraph(digraph);
true
gap> IsDigraph(digraph);
true
gap> digraph := CayleyDigraph(group, [()]);
<immutable digraph with 8 vertices, 8 edges>
gap> GroupOfCayleyDigraph(digraph) = group;
true
gap> GeneratorsOfCayleyDigraph(digraph);
[ () ]
gap> digraph := CayleyDigraph(group, [(1, 2, 3, 4), (2, 5)]);
Error, the 2nd argument <gens> must consist of elements of the 1st argument,
gap> group := FreeGroup(2);;
gap> digraph := CayleyDigraph(group);
Error, the 1st argument <G> must be a finite group,

#  CayleyDigraph: check edge labels
#
gap> group := SymmetricGroup(4);;
gap> gens := [(1, 2, 3, 4), (1, 2)];;
gap> D := CayleyDigraph(group, gens);
<immutable digraph with 24 vertices, 48 edges>
gap> DigraphNrEdges(D) = Length(gens) * Size(group);
true
gap> DigraphVertexLabels(D) = AsList(group);
true
gap> ForAll(DigraphVertices(D), u -> ForAll(OutNeighboursOfVertex(D, u), v ->
> DigraphVertexLabel(D, u) * DigraphEdgeLabel(D, u, v)
> = DigraphVertexLabel(D, v)));
true

#
gap> group := GL(2, 3);;
gap> D := CayleyDigraph(group);
<immutable digraph with 48 vertices, 96 edges>
gap> DigraphNrEdges(D) = Length(GeneratorsOfGroup(group)) * Size(group);
true
gap> DigraphVertexLabels(D) = AsList(group);
true
gap> ForAll(DigraphVertices(D), u -> ForAll(OutNeighboursOfVertex(D, u), v ->
> DigraphVertexLabel(D, u) * DigraphEdgeLabel(D, u, v)
> = DigraphVertexLabel(D, v)));
true

#
gap> gens := [
> [[Z(3) ^ 0, Z(3) ^ 0], [Z(3) ^ 0, 0 * Z(3)]],
> [[0 * Z(3), Z(3)], [Z(3), 0 * Z(3)]],
> [[0 * Z(3), Z(3) ^ 0], [Z(3) ^ 0, 0 * Z(3)]]];;
gap> D := CayleyDigraph(group, gens);
<immutable digraph with 48 vertices, 144 edges>
gap> DigraphNrEdges(D) = Length(gens) * Size(group);
true
gap> DigraphVertexLabels(D) = AsList(group);
true
gap> ForAll(DigraphVertices(D), u -> ForAll(OutNeighboursOfVertex(D, u), v ->
> DigraphVertexLabel(D, u) * DigraphEdgeLabel(D, u, v)
> = DigraphVertexLabel(D, v)));
true

#  DigraphAddEdgeOrbit
gap> digraph := NullDigraph(4);
<immutable empty digraph with 4 vertices>
gap> HasDigraphGroup(digraph);
true
gap> digraph := DigraphCopy(digraph);
<immutable empty digraph with 4 vertices>
gap> HasDigraphGroup(digraph);
false
gap> SetDigraphGroup(digraph, Group((1, 3), (1, 2)(3, 4)));
gap> digraph := DigraphAddEdgeOrbit(digraph, [4, 3]);
<immutable digraph with 4 vertices, 8 edges>
gap> Graph(digraph);
rec( adjacencies := [ [ 2, 4 ] ], group := Group([ (1,3), (1,2)(3,4) ]), 
  isGraph := true, names := [ 1 .. 4 ], order := 4, representatives := [ 1 ], 
  schreierVector := [ -1, 2, 1, 2 ] )
gap> IsNullDigraph(DigraphRemoveEdgeOrbit(digraph, [4, 3]));
true

#  DigraphRemoveEdgeOrbit
gap> digraph := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> HasDigraphGroup(digraph);
true
gap> digraph := DigraphCopy(digraph);
<immutable digraph with 4 vertices, 12 edges>
gap> HasDigraphGroup(digraph);
false
gap> SetDigraphGroup(digraph, Group((1, 3), (1, 2)(3, 4)));
gap> digraph := DigraphRemoveEdgeOrbit(digraph, [1, 3]);
<immutable digraph with 4 vertices, 8 edges>
gap> IsCompleteDigraph(DigraphAddEdgeOrbit(digraph, [1, 3]));
true
gap> Graph(digraph);
rec( adjacencies := [ [ 2, 4 ] ], group := Group([ (1,3), (1,2)(3,4) ]), 
  isGraph := true, names := [ 1 .. 4 ], order := 4, representatives := [ 1 ], 
  schreierVector := [ -1, 2, 1, 2 ] )

#  Digraph: copying group from Grape
gap> if DIGRAPHS_IsGrapeLoaded() then
>   gr := Digraph(JohnsonGraph(5, 3));
> else
>   gr := JohnsonDigraph(5, 3);
>   SetDigraphGroup(gr, Group((1, 7, 10, 6, 3)(2, 8, 4, 9, 5),
>                             (4, 7)(5, 8)(6, 9)));
> fi;
gap> HasDigraphGroup(gr);
true
gap> DigraphGroup(gr);
Group([ (1,7,10,6,3)(2,8,4,9,5), (4,7)(5,8)(6,9) ])
gap> if DIGRAPHS_IsGrapeLoaded() then
>   gr := Digraph(CompleteGraph(Group((1, 2, 3), (1, 2))));
> else
>   gr := Digraph([[2, 3], [1, 3], [1, 2]]);
>   SetDigraphGroup(gr, Group((1, 2, 3), (1, 2)));
> fi;
gap> HasDigraphGroup(gr);
true
gap> DigraphGroup(gr);
Group([ (1,2,3), (1,2) ])
gap> if DIGRAPHS_IsGrapeLoaded() then
>   gr := Digraph(Graph(Group([()]),
>                       [1, 2, 3],
>                       OnPoints,
>                       function(x, y)
>                         return x < y;
>                       end));
> else
>   gr := Digraph([[2, 3], [3], []]);
> fi;
gap> HasDigraphGroup(gr);
false
gap> DigraphGroup(gr);
Group(())
gap> HasDigraphGroup(gr);
true

#  EdgeOrbitsDigraph
gap> digraph := EdgeOrbitsDigraph(Group((1, 3), (1, 2)(3, 4)),
>                                 [[1, 2], [4, 5]], 5);
<immutable digraph with 5 vertices, 12 edges>
gap> OutNeighbours(digraph);
[ [ 2, 4, 5 ], [ 1, 3, 5 ], [ 2, 4, 5 ], [ 1, 3, 5 ], [  ] ]
gap> RepresentativeOutNeighbours(digraph);
[ [ 2, 4, 5 ], [  ] ]
gap> HasDigraphGroup(digraph);
true
gap> DigraphGroup(digraph) = Group((1, 3), (1, 2)(3, 4));
true
gap> digraph := EdgeOrbitsDigraph(Group(()), [3, 2], 3);
<immutable digraph with 3 vertices, 1 edge>
gap> OutNeighbours(digraph);
[ [  ], [  ], [ 2 ] ]
gap> HasDigraphGroup(digraph);
true
gap> HasDigraphGroup(DigraphCopy(digraph));
false
gap> digraph := EdgeOrbitsDigraph(Group(()), [3, 2]);
<immutable empty digraph with 0 vertices>
gap> OutNeighbours(digraph);
[  ]
gap> HasDigraphGroup(digraph);
true
gap> digraph := EdgeOrbitsDigraph(Group((1, 2)), [[1, 2], [3, 6, 5]]);
Error, the 2nd argument <edges> must be a list of pairs of positive integers,
gap> digraph := EdgeOrbitsDigraph(Group((1, 2)), [[1, 2], [3, -6]]);
Error, the 2nd argument <edges> must be a list of pairs of positive integers,
gap> digraph := EdgeOrbitsDigraph(Group((1, 2)), [[1, 2], [3, 6]], -1);
Error, the 3rd argument <n> must be a non-negative integer,

#  DigraphAdd/RemoveEdgeOrbit
gap> gr1 := CayleyDigraph(DihedralGroup(8));
<immutable digraph with 8 vertices, 24 edges>
gap> gr2 := DigraphAddEdgeOrbit(gr1, [1, 8]);
<immutable digraph with 8 vertices, 32 edges>
gap> DigraphEdges(gr1);
[ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 1 ], [ 2, 5 ], [ 2, 6 ], [ 3, 8 ], 
  [ 3, 4 ], [ 3, 7 ], [ 4, 6 ], [ 4, 7 ], [ 4, 1 ], [ 5, 7 ], [ 5, 6 ], 
  [ 5, 8 ], [ 6, 4 ], [ 6, 8 ], [ 6, 2 ], [ 7, 5 ], [ 7, 1 ], [ 7, 3 ], 
  [ 8, 3 ], [ 8, 2 ], [ 8, 5 ] ]
gap> DigraphEdges(gr2);
[ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 1, 8 ], [ 2, 1 ], [ 2, 5 ], [ 2, 6 ], 
  [ 2, 7 ], [ 3, 8 ], [ 3, 4 ], [ 3, 7 ], [ 3, 6 ], [ 4, 6 ], [ 4, 7 ], 
  [ 4, 1 ], [ 4, 5 ], [ 5, 7 ], [ 5, 6 ], [ 5, 8 ], [ 5, 4 ], [ 6, 4 ], 
  [ 6, 8 ], [ 6, 2 ], [ 6, 3 ], [ 7, 5 ], [ 7, 1 ], [ 7, 3 ], [ 7, 2 ], 
  [ 8, 3 ], [ 8, 2 ], [ 8, 5 ], [ 8, 1 ] ]
gap> gr3 := DigraphRemoveEdgeOrbit(gr2, [1, 8]);
<immutable digraph with 8 vertices, 24 edges>
gap> gr3 = gr1;
true
gap> gr3 := DigraphRemoveEdgeOrbit(gr1, [1, 3]);
<immutable digraph with 8 vertices, 16 edges>
gap> gr3 := DigraphRemoveEdgeOrbit(gr3, [1, 2]);
<immutable digraph with 8 vertices, 8 edges>
gap> gr3 := DigraphRemoveEdgeOrbit(gr3, [1, 4]);
<immutable empty digraph with 8 vertices>
gap> DigraphAddEdgeOrbit(gr1, [0, 3]);
Error, the 2nd argument <edge> must be a list of 2 positive integers,
gap> DigraphAddEdgeOrbit(gr1, [1, 2, 3]);
Error, the 2nd argument <edge> must be a list of 2 positive integers,
gap> DigraphRemoveEdgeOrbit(gr1, [0, 3]);
Error, the 2nd argument <edge> must be a pair of positive integers,
gap> DigraphRemoveEdgeOrbit(gr1, [1, 2, 3]);
Error, the 2nd argument <edge> must be a pair of positive integers,
gap> gr2 := DigraphAddEdgeOrbit(gr1, [1, 4]);
<immutable digraph with 8 vertices, 24 edges>
gap> gr1 = gr2;
true
gap> DigraphAddEdgeOrbit(gr1, [3, 9]);
Error, the 2nd argument <edge> must be a list of 2 vertices of the 1st argumen\
t <D>,
gap> DigraphRemoveEdgeOrbit(gr1, [3, 9]);
Error, the 2nd argument <edge> must be a pair of vertices of the 1st argument \
<D>,
gap> gr2 := DigraphRemoveEdgeOrbit(gr1, [1, 8]);
<immutable digraph with 8 vertices, 24 edges>
gap> gr1 = gr2;
true

#  Graph
gap> gr := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> if DIGRAPHS_IsGrapeLoaded() then
>   Graph(gr);
> fi;

# Non-trivial action
gap> Digraph(SymmetricGroup(3), [1, 2, 3], OnPoints, {x, y} -> x <> y);
<immutable digraph with 3 vertices, 6 edges>

#  DIGRAPHS_UnbindVariables
gap> Unbind(D);
gap> Unbind(digraph);
gap> Unbind(gens);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(gr3);
gap> Unbind(group);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/grape.tst", 0);
