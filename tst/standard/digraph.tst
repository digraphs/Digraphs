#############################################################################
##
#W  standard/digraph.tst
#Y  Copyright (C) 2014-15                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/digraph.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#  DigraphVertexLabels
gap> gr := RandomDigraph(10);;
gap> DigraphVertexLabels(gr);
[ 1 .. 10 ]
gap> SetDigraphVertexLabels(gr, ["a", "b", 10]);
Error, Digraphs: SetDigraphVertexLabels: usage,
the 2nd arument <names> must be a list with length equal to the number of
vertices of the digraph,
gap> gr := RandomDigraph(3);;
gap> SetDigraphVertexLabels(gr, ["a", "b", 10]);
gap> DigraphVertexLabels(gr);
[ "a", "b", 10 ]
gap> DigraphVertexLabel(gr, 1);
"a"
gap> DigraphVertexLabel(gr, 2);
"b"
gap> DigraphVertexLabel(gr, 10);
Error, Digraphs: DigraphVertexLabel: usage,
10 is nameless or not a vertex,
gap> DigraphVertexLabel(gr, 3);
10
gap> SetDigraphVertexLabel(gr, 3, 3);
gap> DigraphVertexLabel(gr, 3);
3
gap> gr := RandomDigraph(5);;
gap> SetDigraphVertexLabel(gr, 6, (1, 3, 2, 5, 4));
Error, Digraphs: SetDigraphVertexLabel: usage,
there are only 5 vertices,
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

#  DigraphEdgeLabels
gap> gr := Digraph([[2, 3], [3], [1, 5], [], [4]]);
<immutable digraph with 5 vertices, 6 edges>
gap> DigraphEdgeLabels(gr);
[ [ 1, 1 ], [ 1 ], [ 1, 1 ], [  ], [ 1 ] ]
gap> SetDigraphEdgeLabels(gr, [1, 2]);
Error, Digraphs: SetDigraphEdgeLabels: usage,
the list <labels> has the wrong shape, it is required to have the same shape
as the return value of OutNeighbours(<D>),
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
Error, Digraphs: SetDigraphEdgeLabels: usage,
edge labels are not supported on digraphs with multiple edges,
gap> DigraphEdgeLabels(gr);
Error, Digraphs: DigraphEdgeLabels: usage,
edge labels are not supported on digraphs with multiple edges,
gap> SetDigraphEdgeLabel(gr, 1, 2, infinity);
Error, Digraphs: SetDigraphEdgeLabel: usage,
edge labels are not supported on digraphs with multiple edges,

#  Graph
gap> gr := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> if DIGRAPHS_IsGrapeLoaded then
>   Graph(gr);
> fi;

#  Digraph (by OutNeighbours)
gap> Digraph([[0, 1]]);
Error, the argument must be a list of lists of positive integers not exceeding\
 the length of the argument,
gap> Digraph([[2], [3]]);
Error, the argument must be a list of lists of positive integers not exceeding\
 the length of the argument,
gap> Digraph([[1],, [2]]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Digraph' on 1 arguments
gap> Digraph([[1], 2, [3]]);
Error, the argument must be a list of lists of positive integers not exceeding\
 the length of the argument,

#  Digraph (by record)
gap> n := 3;;
gap> v := [1 .. 3];;
gap> s := [1, 2, 3];;
gap> r := [3, 1, 2];;
gap> Digraph(rec(DigraphNrVertices := n, DigraphSource := s));
Error, the argument <record> must be a record with components 'DigraphSource',\
 'DigraphRange', and either 'DigraphVertices' or 'DigraphNrVertices' (but not \
both),
gap> Digraph(rec(DigraphNrVertices := n, DigraphRange := r));
Error, the argument <record> must be a record with components 'DigraphSource',\
 'DigraphRange', and either 'DigraphVertices' or 'DigraphNrVertices' (but not \
both),
gap> Digraph(rec(DigraphNrVertices := n, DigraphSource := s, DigraphVertices := v));
Error, the argument <record> must be a record with components 'DigraphSource',\
 'DigraphRange', and either 'DigraphVertices' or 'DigraphNrVertices' (but not \
both),
gap> Digraph(rec(DigraphNrVertices := n, DigraphRange := r, DigraphVertices := v));
Error, the argument <record> must be a record with components 'DigraphSource',\
 'DigraphRange', and either 'DigraphVertices' or 'DigraphNrVertices' (but not \
both),
gap> Digraph(rec(DigraphSource := s, DigraphRange := r));
Error, the argument <record> must be a record with components 'DigraphSource',\
 'DigraphRange', and either 'DigraphVertices' or 'DigraphNrVertices' (but not \
both),
gap> Digraph(rec(DigraphNrVertices := n, DigraphSource := s, DigraphRange := 4));
Error, the record components 'DigraphSource' and 'DigraphRange' must be lists,
gap> Digraph(rec(DigraphNrVertices := n, DigraphSource := 1, DigraphRange := r));
Error, the record components 'DigraphSource' and 'DigraphRange' must be lists,
gap> Digraph(rec(DigraphNrVertices := n, DigraphSource := [1, 2], DigraphRange := r));
Error, the record components 'DigraphSource' and 'DigraphRange' must have equa\
l length,
gap> Digraph(rec(DigraphNrVertices := "a", DigraphSource := s, DigraphRange := r));
Error, the record component 'DigraphNrVertices' must be a non-negative integer\
,
gap> Digraph(rec(DigraphNrVertices := -3, DigraphSource := s, DigraphRange := r));
Error, the record component 'DigraphNrVertices' must be a non-negative integer\
,
gap> Digraph(
> rec(DigraphNrVertices := 2, DigraphVertices := [1 .. 3], DigraphSource := [2], DigraphRange := [2]));
Error, the record must only have one of the components 'DigraphVertices' and '\
DigraphNrVertices', not both,
gap> Digraph(rec(DigraphNrVertices := n, DigraphSource := [0 .. 2], DigraphRange := r));
Error, the record component 'DigraphSource' is invalid,
gap> Digraph(rec(DigraphNrVertices := n, DigraphSource := [2 .. 4], DigraphRange := r));
Error, the record component 'DigraphSource' is invalid,
gap> Digraph(rec(DigraphVertices := 2, DigraphSource := s, DigraphRange := r));
Error, the record component 'DigraphVertices' must be a list,
gap> Digraph(rec(DigraphNrVertices := n, DigraphSource := [1, 2, 4], DigraphRange := r));
Error, the record component 'DigraphSource' is invalid,
gap> Digraph(rec(DigraphVertices := v, DigraphSource := [1, 2, 4], DigraphRange := r));
Error, the record component 'DigraphSource' is invalid,
gap> Digraph(rec(DigraphNrVertices := n, DigraphSource := s, DigraphRange := [1, 4, 2]));
Error, the record component 'DigraphRange' is invalid,
gap> Digraph(rec(DigraphVertices := v, DigraphSource := s, DigraphRange := [1, 4, 2]));
Error, the record component 'DigraphRange' is invalid,
gap> Digraph(rec(DigraphVertices := "abc", DigraphSource := "acbab", DigraphRange := "cbabb"));
<immutable digraph with 3 vertices, 5 edges>
gap> Digraph(rec(
> DigraphVertices := [1, 1, 2], DigraphSource := [1, 2], DigraphRange := [1, 2]));
Error, the record component 'DigraphVertices' must be duplicate-free,

#  Digraph (by nrvertices, source, and range)
gap> Digraph(Group(()), [], []);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Digraph' on 3 arguments
gap> Digraph(2, [1, "a"], [2, 1]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Digraph' on 3 arguments
gap> Digraph(2, [1, 1], [1, Group(())]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Digraph' on 3 arguments
gap> Digraph(-1, [], []);
Error, the record component 'DigraphNrVertices' must be a non-negative integer\
,
gap> Digraph(0, [], ["a"]);
Error, the record components 'DigraphSource' and 'DigraphRange' must have equa\
l length,
gap> Digraph(2, [1], [2, 2]);
Error, the record components 'DigraphSource' and 'DigraphRange' must have equa\
l length,
gap> Digraph(5, [], []);
<immutable digraph with 5 vertices, 0 edges>
gap> Digraph(2, "ab", [0, 1]);
Error, the record component 'DigraphSource' is invalid,
gap> Digraph(2, [0, 1], "ab");
Error, the record component 'DigraphSource' is invalid,
gap> Digraph(1, [2], [1]);
Error, the record component 'DigraphSource' is invalid,
gap> Digraph(1, [1], [2]);
Error, the record component 'DigraphRange' is invalid,
gap> Digraph(2, [1, 0], [2, 1]);
Error, the record component 'DigraphSource' is invalid,
gap> Digraph(2, [1, 1], [2, 0]);
Error, the record component 'DigraphRange' is invalid,
gap> Digraph(4, [3, 1, 2, 3], [4, 1, 2, 4]);
<immutable multidigraph with 4 vertices, 4 edges>

#  Digraph (by vertices, source, and range)
gap> Digraph(Group(()), [], []);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Digraph' on 3 arguments
gap> Digraph([], Group(()), []);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Digraph' on 3 arguments
gap> Digraph([], [], Group(()));
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Digraph' on 3 arguments
gap> Digraph([1], [2], [3, 4]);
Error, the record components 'DigraphSource' and 'DigraphRange' must have equa\
l length,
gap> Digraph([1, 1], [], []);
Error, the record component 'DigraphVertices' must be duplicate-free,
gap> Digraph([Group(())], [1], [Group(())]);
Error, the record component 'DigraphSource' is invalid,
gap> Digraph([Group(())], [Group(())], [1]);
Error, the record component 'DigraphRange' is invalid,
gap> gr := Digraph(
> [Group(()), SymmetricGroup(3)], [Group(())], [SymmetricGroup(3)]);;
gap> DigraphVertexLabels(gr);
[ Group(()), Sym( [ 1 .. 3 ] ) ]
gap> HasDigraphNrEdges(gr);
false
gap> HasDigraphNrVertices(gr);
false
gap> HasDigraphSource(gr);
false
gap> HasDigraphRange(gr);
false
gap> gr;
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphSource(gr);
[ 1 ]
gap> DigraphRange(gr);
[ 2 ]
gap> gr := Digraph([1 .. 3], [3, 2, 1], [2, 3, 2]);;
gap> DigraphVertexLabels(gr);
[ 1 .. 3 ]
gap> HasDigraphNrEdges(gr);
false
gap> HasDigraphNrVertices(gr);
false
gap> HasDigraphSource(gr);
false
gap> HasDigraphRange(gr);
false
gap> DigraphSource(gr);
[ 1, 2, 3 ]
gap> DigraphRange(gr);
[ 2, 3, 2 ]
gap> gr;
<immutable digraph with 3 vertices, 3 edges>
gap> if DIGRAPHS_IsGrapeLoaded then
>   g := Graph(gr);
>   if not Digraph(g) = gr then
>     Print("fail");
>   fi;
> fi;

#  Digraph (by an integer and a function)
gap> divides := function(a, b)
>   if b mod a = 0 then
>     return true;
>   fi;
>   return false;
> end;;
gap> gr := Digraph([1 .. 12], divides);
<immutable digraph with 12 vertices, 35 edges>

#  AsDigraph (by binary relation)
gap> g := Group((1, 2, 3));
Group([ (1,2,3) ])
gap> elms := [
>  DirectProductElement([(1, 2, 3), (1, 3, 2)]),
>  DirectProductElement([(1, 3, 2), (1, 2, 3)]),
>  DirectProductElement([(), ()])];;
gap> bin := BinaryRelationByElements(g, elms);
<general mapping: Group( [ (1,2,3) ] ) -> Group( [ (1,2,3) ] ) >
gap> AsDigraph(bin);
Error, the argument must be a binary relation on the domain [1 .. n] for some \
positive integer n,
gap> d := Domain([2 .. 10]);;
gap> bin := BinaryRelationByElements(d, [
>  DirectProductElement([2, 5]),
>  DirectProductElement([6, 3]),
>  DirectProductElement([4, 5])]);
<general mapping: <object> -> <object> >
gap> gr := AsDigraph(bin);
Error, the argument must be a binary relation on the domain [1 .. n] for some \
positive integer n,
gap> d := Domain([1 .. 10]);;
gap> bin := BinaryRelationByElements(d, [
>  DirectProductElement([2, 5]),
>  DirectProductElement([6, 3]),
>  DirectProductElement([4, 5])]);
<general mapping: <object> -> <object> >
gap> gr := AsDigraph(bin);
<immutable digraph with 10 vertices, 3 edges>
gap> DigraphEdges(gr);
[ [ 2, 5 ], [ 4, 5 ], [ 6, 3 ] ]
gap> bin := BinaryRelationOnPoints([[1], [4], [5], [2], [4]]);
Binary Relation on 5 points
gap> gr := AsDigraph(bin);
<immutable digraph with 5 vertices, 5 edges>
gap> OutNeighbours(gr);
[ [ 1 ], [ 4 ], [ 5 ], [ 2 ], [ 4 ] ]
gap> gr := Digraph([[1, 2], [1, 2], [3], [4, 5], [4, 5]]);;
gap> b := AsBinaryRelation(gr);
Binary Relation on 5 points
gap> IsEquivalenceRelation(b);
true
gap> gr2 := AsDigraph(b);
<immutable digraph with 5 vertices, 9 edges>
gap> gr := Digraph([[1, 2], [3], []]);
<immutable digraph with 3 vertices, 3 edges>
gap> b := AsBinaryRelation(gr);;
gap> IsAntisymmetricBinaryRelation(b);
true
gap> gr := AsDigraph(b);
<immutable digraph with 3 vertices, 3 edges>
gap> HasIsAntisymmetricDigraph(gr);
true

#  DigraphByEdges
gap> gr := Digraph([[1, 2, 3, 5], [1, 5], [2, 3, 6], [1, 3, 4],
> [1, 4, 6], [3, 4]]);
<immutable digraph with 6 vertices, 17 edges>
gap> gr = DigraphByEdges(DigraphEdges(gr));
true
gap> DigraphByEdges([["nonsense", "more"]]);
Error, the argument must be a list of pairs of positive integers,
gap> DigraphByEdges([["nonsense"]]);
Error, the argument must be a list of pairs,
gap> DigraphByEdges([["a", "b"]], 2);
Error, the first argument must be a list of pairs of pos ints,
gap> DigraphByEdges([[1, 2, 3]], 3);
Error, the first argument must be a list of pairs,
gap> gr := DigraphByEdges(DigraphEdges(gr), 10);
<immutable digraph with 10 vertices, 17 edges>
gap> gr := DigraphByEdges([[1, 2]]);
<immutable digraph with 2 vertices, 1 edge>
gap> gr := DigraphByEdges([[2, 1]]);
<immutable digraph with 2 vertices, 1 edge>
gap> gr := DigraphByEdges([[1, 2]], 1);
Error, the first argument must not contain values greater than 1,
gap> gr := DigraphByEdges([], 3);
<immutable digraph with 3 vertices, 0 edges>
gap> gr := DigraphByEdges([]);
<immutable digraph with 0 vertices, 0 edges>
gap> gr = EmptyDigraph(0);
true

#  DigraphByAdjacencyMatrix (by an integer matrix)

# for a matrix of integers
gap> mat := [
> [1, 2, 3],
> [1, 2, 3]];;
gap> DigraphByAdjacencyMatrix(mat);
Error, the argument must be a square matrix,
gap> mat := [
> [11, 2, 3],
> [11, 2, 3],
> [-1, 2, 2]];;
gap> DigraphByAdjacencyMatrix(mat);
Error, the argument must be a matrix of non-negative integers,
gap> mat := [["a"]];;
gap> DigraphByAdjacencyMatrix(mat);
Error, the argument must be a matrix of non-negative integers,
gap> mat := [
> [0, 2, 0, 0, 1],
> [0, 2, 1, 0, 1],
> [0, 0, 0, 0, 1],
> [1, 0, 1, 1, 0],
> [0, 0, 3, 0, 0]];;
gap> gr := DigraphByAdjacencyMatrix(mat);
<immutable multidigraph with 5 vertices, 14 edges>
gap> grnc := DigraphByAdjacencyMatrixNC(mat);
<immutable multidigraph with 5 vertices, 14 edges>
gap> gr = grnc;
true
gap> IsStronglyConnectedDigraph(gr);
false
gap> IsMultiDigraph(gr);
true
gap> OutNeighbours(gr);
[ [ 2, 2, 5 ], [ 2, 2, 3, 5 ], [ 5 ], [ 1, 3, 4 ], [ 3, 3, 3 ] ]
gap> OutNeighbours(grnc) = last;
true
gap> mat := [
> [0, 0, 0, 9, 1, 0, 0, 1, 0, 0],
> [0, 1, 0, 1, 1, 1, 0, 1, 1, 0],
> [0, 1, 0, 1, 2, 0, 1, 0, 0, 3],
> [0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
> [1, 0, 0, 1, 0, 1, 1, 0, 1, 0],
> [0, 1, 1, 0, 0, 5, 1, 0, 0, 1],
> [0, 0, 1, 2, 1, 0, 0, 1, 1, 0],
> [0, 0, 1, 1, 0, 0, 0, 2, 1, 1],
> [1, 2, 3, 0, 1, 1, 0, 0, 1, 1],
> [0, 1, 3, 4, 1, 1, 0, 0, 1, 0]];;
gap> gr := DigraphByAdjacencyMatrix(mat);
<immutable multidigraph with 10 vertices, 73 edges>
gap> IsMultiDigraph(gr);
true
gap> OutNeighbours(gr);
[ [ 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 8 ], [ 2, 4, 5, 6, 8, 9 ], 
  [ 2, 4, 5, 5, 7, 10, 10, 10 ], [ 9 ], [ 1, 4, 6, 7, 9 ], 
  [ 2, 3, 6, 6, 6, 6, 6, 7, 10 ], [ 3, 4, 4, 5, 8, 9 ], [ 3, 4, 8, 8, 9, 10 ],
  [ 1, 2, 2, 3, 3, 3, 5, 6, 9, 10 ], [ 2, 3, 3, 3, 4, 4, 4, 4, 5, 6, 9 ] ]
gap> r := rec(DigraphNrVertices := 10, DigraphSource := ShallowCopy(DigraphSource(gr)),
> DigraphRange := ShallowCopy(DigraphRange(gr)));;
gap> gr2 := Digraph(r);
<immutable multidigraph with 10 vertices, 73 edges>
gap> HasAdjacencyMatrix(gr2);
false
gap> AdjacencyMatrix(gr2) = mat;
true
gap> DigraphByAdjacencyMatrix([]);
<immutable digraph with 0 vertices, 0 edges>

#  DigraphByAdjacencyMatrix (by a boolean matrix)
gap> mat := List([1 .. 5], x -> BlistList([1 .. 5], []));;
gap> DigraphByAdjacencyMatrix(mat) = EmptyDigraph(5);
true
gap> mat := List([1 .. 5], x -> BlistList([1 .. 5],
>                                         Difference([1 .. 5], [x])));;
gap> DigraphByAdjacencyMatrix(mat) = CompleteDigraph(5);
true

#  DigraphByInNeighbours
gap> gr1 := RandomMultiDigraph(50, 3000);
<immutable multidigraph with 50 vertices, 3000 edges>
gap> inn := InNeighbours(gr1);;
gap> gr2 := DigraphByInNeighbours(inn);
<immutable multidigraph with 50 vertices, 3000 edges>
gap> gr3 := DigraphByInNeighbors(inn);;
gap> gr4 := DigraphByInNeighboursNC(inn);
<immutable multidigraph with 50 vertices, 3000 edges>
gap> DigraphNrEdges(gr3);
3000
gap> gr1 = gr2;
true
gap> gr1 = gr3;
true
gap> gr2 = gr3;
true
gap> gr1 = gr4;
true
gap> HasInNeighbours(gr2);
true
gap> InNeighbours(gr2) = inn;
true
gap> HasInNeighbours(gr3);
true
gap> InNeighbours(gr3) = inn;
true
gap> inn := [[3, 1, 2], [1]];;
gap> DigraphByInNeighbours(inn);
Error, the argument must be a list of lists of positive integers not exceeding\
 the length of the argument,
gap> inn := [
> [], [3], [7], [], [], [], [], [], [], [], [], [6],
> [], [2], [], [], [], [], [5], []];;
gap> gr := DigraphByInNeighbours(inn);
<immutable digraph with 20 vertices, 5 edges>
gap> OutNeighbours(gr);
[ [  ], [ 14 ], [ 2 ], [  ], [ 19 ], [ 12 ], [ 3 ], [  ], [  ], [  ], [  ], 
  [  ], [  ], [  ], [  ], [  ], [  ], [  ], [  ], [  ] ]
gap> inn := [
> [14], [20], [], [], [5, 19, 5], [4], [], [], [], [],
> [12], [], [], [], [], [], [], [], [], [2]];;
gap> gr := DigraphByInNeighbours(inn);
<immutable multidigraph with 20 vertices, 8 edges>
gap> OutNeighbours(gr);
[ [  ], [ 20 ], [  ], [ 6 ], [ 5, 5 ], [  ], [  ], [  ], [  ], [  ], [  ], 
  [ 11 ], [  ], [ 1 ], [  ], [  ], [  ], [  ], [ 5 ], [ 2 ] ]
gap> InNeighbors(gr) = inn;
true

#  AsDigraph
gap> f := Transformation([]);
IdentityTransformation
gap> gr := AsDigraph(f);
<immutable digraph with 0 vertices, 0 edges>
gap> gr = Digraph([]);
true
gap> AsDigraph(f, 10);
<immutable digraph with 10 vertices, 10 edges>
gap> g := Transformation([2, 6, 7, 2, 6, 1, 1, 5]);
Transformation( [ 2, 6, 7, 2, 6, 1, 1, 5 ] )
gap> AsDigraph(g);
<immutable digraph with 8 vertices, 8 edges>
gap> AsDigraph(g, -1);
Error, the second argument should be a non-negative integer,
gap> AsDigraph(g, 10);
<immutable digraph with 10 vertices, 10 edges>
gap> AsDigraph(g, 6);
fail
gap> AsDigraph(g, 7);
<immutable digraph with 7 vertices, 7 edges>
gap> h := Transformation([2, 4, 1, 3, 5]);
Transformation( [ 2, 4, 1, 3 ] )
gap> AsDigraph(h);
<immutable digraph with 4 vertices, 4 edges>
gap> AsDigraph(h, 2);
fail

#  RandomDigraph
gap> DigraphNrVertices(RandomDigraph(10));
10
gap> DigraphNrVertices(RandomDigraph(200, 0.854));
200
gap> IsMultiDigraph(RandomDigraph(1000));
false
gap> RandomDigraph(0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RandomDigraph' on 1 arguments
gap> RandomDigraph("a");
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RandomDigraph' on 1 arguments
gap> RandomDigraph(4, 0);
<immutable digraph with 4 vertices, 0 edges>
gap> RandomDigraph(10, 1.01);
Error, the second argument must be between 0 and 1,
gap> RandomDigraph(10, -0.01);
Error, the second argument must be between 0 and 1,
gap> RandomDigraph(10, 1 / 10);;

#  RandomMultiDigraph
gap> DigraphNrVertices(RandomMultiDigraph(100));
100
gap> gr := RandomMultiDigraph(100, 1000);;
gap> DigraphNrVertices(gr);
100
gap> DigraphNrEdges(gr);
1000
gap> RandomMultiDigraph(0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RandomMultiDigraph' on 1 arguments
gap> RandomMultiDigraph(0, 1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RandomMultiDigraph' on 2 arguments
gap> RandomMultiDigraph(1, 0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RandomMultiDigraph' on 2 arguments

#  RandomTournament
gap> RandomTournament(25);
<immutable digraph with 25 vertices, 300 edges>
gap> RandomTournament(0);
<immutable digraph with 0 vertices, 0 edges>
gap> RandomTournament(-1);
Error, the argument must be a non-negative integer,

#  CompleteDigraph
gap> gr := CompleteDigraph(5);
<immutable digraph with 5 vertices, 20 edges>
gap> AutomorphismGroup(gr) = SymmetricGroup(5);
true
gap> CompleteDigraph(1) = EmptyDigraph(1);
true
gap> CompleteDigraph(0);
<immutable digraph with 0 vertices, 0 edges>
gap> CompleteDigraph(-1);
Error, the argument must be a non-negative integer,

#  EmptyDigraph
gap> gr := EmptyDigraph(5);
<immutable digraph with 5 vertices, 0 edges>
gap> AutomorphismGroup(gr) = SymmetricGroup(5);
true
gap> EmptyDigraph(0);
<immutable digraph with 0 vertices, 0 edges>
gap> EmptyDigraph(-1);
Error, the argument must be a non-negative integer,

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
<immutable digraph with 1000 vertices, 1000 edges>

#  ChainDigraph
gap> gr := ChainDigraph(0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ChainDigraph' on 1 arguments
gap> gr := ChainDigraph(1);
<immutable digraph with 1 vertex, 0 edges>
gap> IsEmptyDigraph(gr);
true
gap> gr = EmptyDigraph(1);
true
gap> gr := ChainDigraph(2);
<immutable digraph with 2 vertices, 1 edge>
gap> AutomorphismGroup(gr) = Group(());
true
gap> HasIsTransitiveDigraph(gr);
true
gap> IsTransitiveDigraph(gr);
true
gap> gr := ChainDigraph(10);
<immutable digraph with 10 vertices, 9 edges>
gap> OutNeighbours(gr);
[ [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ], [  ] ]
gap> AutomorphismGroup(gr) = Group(());
true
gap> grrt := DigraphReflexiveTransitiveClosure(gr);
<immutable digraph with 10 vertices, 55 edges>
gap> IsPartialOrderBinaryRelation(AsBinaryRelation(grrt));
true
gap> IsAntisymmetricDigraph(grrt);
true

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
<immutable digraph with 7 vertices, 24 edges>
gap> AutomorphismGroup(gr) = Group((1, 2, 3, 4), (1, 2), (5, 6, 7), (5, 6));
true
gap> DigraphEdges(gr);
[ [ 1, 5 ], [ 1, 6 ], [ 1, 7 ], [ 2, 5 ], [ 2, 6 ], [ 2, 7 ], [ 3, 5 ], 
  [ 3, 6 ], [ 3, 7 ], [ 4, 5 ], [ 4, 6 ], [ 4, 7 ], [ 5, 1 ], [ 5, 2 ], 
  [ 5, 3 ], [ 5, 4 ], [ 6, 1 ], [ 6, 2 ], [ 6, 3 ], [ 6, 4 ], [ 7, 1 ], 
  [ 7, 2 ], [ 7, 3 ], [ 7, 4 ] ]
gap> gr := CompleteBipartiteDigraph(4, 4);
<immutable digraph with 8 vertices, 32 edges>
gap> AutomorphismGroup(gr) = Group((1, 2, 3, 4), (1, 2), (5, 6, 7, 8), (5, 6),
>                                  (1, 5)(2, 6)(3, 7)(4, 8));
true

#  Equals (\=) for two digraphs
gap> r1 := rec(DigraphNrVertices := 2, DigraphSource := [1, 1, 2], DigraphRange := [1, 2, 2]);;
gap> r2 := rec(DigraphNrVertices := 2, DigraphSource := [1, 1, 2], DigraphRange := [2, 1, 2]);;
gap> gr1 := Digraph(r1);
<immutable digraph with 2 vertices, 3 edges>
gap> gr2 := Digraph(r2);
<immutable digraph with 2 vertices, 3 edges>
gap> DigraphRange(gr1);
[ 1, 2, 2 ]
gap> DigraphRange(gr2);
[ 2, 1, 2 ]
gap> gr1 = gr2;
true
gap> gr1 := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> gr2 := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> gr1 = gr2;
false
gap> gr1 := Digraph([[1, 2], []]);
<immutable digraph with 2 vertices, 2 edges>
gap> gr2 := Digraph([[1], [2]]);
<immutable digraph with 2 vertices, 2 edges>
gap> gr1 = gr2;
false
gap> gr1 := Digraph([[], [], []]);
<immutable digraph with 3 vertices, 0 edges>
gap> gr2 := Digraph(rec(DigraphNrVertices := 3, DigraphSource := [], DigraphRange := []));
<immutable digraph with 3 vertices, 0 edges>
gap> gr1 = gr2;
true
gap> gr1 := Digraph([[1], []]);
<immutable digraph with 2 vertices, 1 edge>
gap> gr2 := Digraph([[2], []]);
<immutable digraph with 2 vertices, 1 edge>
gap> gr1 = gr2;
false
gap> gr1 := Digraph([[1], [2]]);
<immutable digraph with 2 vertices, 2 edges>
gap> gr2 := Digraph([[2], [1]]);
<immutable digraph with 2 vertices, 2 edges>
gap> gr1 = gr2;
false
gap> gr1 := Digraph([[1, 3, 1], [3, 2], [1, 3, 2]]);
<immutable multidigraph with 3 vertices, 8 edges>
gap> gr2 := Digraph(rec(DigraphNrVertices := 3,
> DigraphSource := [1, 1, 1, 2, 2, 3, 3, 3],
> DigraphRange := [1, 1, 2, 3, 2, 1, 3, 2]));
<immutable multidigraph with 3 vertices, 8 edges>
gap> gr3 := Digraph(rec(DigraphNrVertices := 3,
> DigraphSource := [1, 1, 1, 2, 2, 3, 3, 3],
> DigraphRange := [1, 3, 1, 3, 3, 1, 3, 2]));
<immutable multidigraph with 3 vertices, 8 edges>
gap> gr4 := Digraph(rec(DigraphNrVertices := 3,
> DigraphSource := [1, 1, 1, 2, 2, 3, 3, 3],
> DigraphRange := [1, 3, 1, 3, 2, 1, 2, 2]));
<immutable multidigraph with 3 vertices, 8 edges>
gap> gr5 := Digraph(rec(DigraphNrVertices := 3,
> DigraphSource := [1, 1, 1, 2, 2, 3, 3, 3],
> DigraphRange := [1, 1, 3, 2, 3, 2, 1, 3]));
<immutable multidigraph with 3 vertices, 8 edges>
gap> gr1 = gr1;
true
gap> gr1 = gr2;
false
gap> gr1 = gr3;
false
gap> gr1 = gr4;
false
gap> gr1 = gr5;
true
gap> graph1 := Digraph([[2], [1], []]);
<immutable digraph with 3 vertices, 2 edges>
gap> graph2 := Digraph(rec(
> DigraphNrVertices := 3, DigraphSource := [1, 2], DigraphRange := [2, 1]));
<immutable digraph with 3 vertices, 2 edges>
gap> graph1 = graph2;
true
gap> gr1 := Digraph([[2], [1], [1, 2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> gr2 := Digraph([[2], [1], [2, 1]]);
<immutable digraph with 3 vertices, 4 edges>
gap> gr1 = gr2;
true
gap> im := OnDigraphs(gr1, (1, 2));
<immutable digraph with 3 vertices, 4 edges>
gap> DigraphSource(im);
[ 1, 2, 3, 3 ]
gap> gr1 = im;
true
gap> gr2 = im;
true
gap> gr1 = gr1;
true
gap> gr1 := Digraph([[2], []]);;
gap> gr2 := Digraph(rec(DigraphNrVertices := 1, DigraphSource := [], DigraphRange := []));;
gap> gr1 = gr2;  # Different number of vertices
false
gap> gr2 := Digraph(rec(
> DigraphNrVertices := 2, DigraphSource := [1, 2], DigraphRange := [1, 2]));;
gap> gr1 = gr2;  # Different number of edges
false
gap> EmptyDigraph(2) =
> Digraph(rec(DigraphNrVertices := 2, DigraphSource := [], DigraphRange := []));  # Both empty
true
gap> gr1 := Digraph([[], [1, 2]]);;
gap> gr1 = gr2;  # |out1[1]| = 0, |out2[1]| <> =
false
gap> gr1 := Digraph([[1, 1], [2, 2]]);;
gap> gr2 := Digraph(rec(
> DigraphNrVertices := 2, DigraphSource := [1, 2, 2, 2], DigraphRange := [1, 2, 2, 2]));;
gap> gr1 = gr2;  # |out1[1]| = 2, |out2[1]| = 1
false
gap> gr2 := Digraph(rec(
> DigraphNrVertices := 2, DigraphSource := [1, 1, 1, 2], DigraphRange := [1, 1, 1, 2]));;
gap> gr1 = gr2;  # |out1[1]| = 2, |out2[1]| = 3
false
gap> gr1 := Digraph([[1, 2], [2, 1]]);;
gap> gr2 := Digraph(rec(
> DigraphNrVertices := 2, DigraphSource := [1, 1, 2, 2], DigraphRange := [1, 2, 2, 2]));;
gap> gr1 = gr2;  # Different contents of out[2]
false
gap> gr2 := Digraph(rec(
> DigraphNrVertices := 2, DigraphSource := [1, 1, 2, 2], DigraphRange := [1, 2, 1, 2]));;
gap> gr1 = gr2;  # out[2] sorted differently
true
gap> gr1 := Digraph(
> [[10, 8, 4, 6, 7, 2, 9, 5, 3], [10, 9, 2, 1, 4, 7, 6, 8, 3],
>  [6, 7, 9, 3, 10, 5, 2, 4, 1], [1, 7, 4, 8, 5, 3, 9, 10],
>  [2, 9, 6, 10, 5, 8, 3, 4, 7], [3, 6, 10, 1, 7, 9, 5, 8, 4],
>  [1, 9, 4, 10, 7, 8, 5, 2], [4, 10, 7, 6, 1, 2, 3, 8, 5],
>  [6, 2, 7, 9, 3, 8, 5, 1, 4], [4, 3, 2, 10, 8, 7, 5, 6, 9]]);;
gap> s :=
> [1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3,
>  3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6,
>  6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8,
>  8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 10, 10, 10];;
gap> r2 :=
> [3, 5, 9, 2, 7, 6, 4, 8, 10, 3, 8, 6, 7, 4, 1, 2, 9, 10, 1, 4, 2, 5,
>  10, 3, 9, 7, 6, 10, 9, 3, 5, 8, 4, 7, 1, 7, 4, 3, 8, 5, 10, 6, 9, 2,
>  4, 8, 5, 9, 7, 1, 10, 6, 3, 2, 5, 8, 7, 10, 4, 9, 1, 5, 8, 3, 2, 1, 6,
>  7, 10, 4, 4, 1, 5, 8, 3, 9, 7, 2, 6, 9, 6, 5, 7, 8, 10, 2, 3, 4];;
gap> gr2 := Digraph(rec(DigraphNrVertices := 10, DigraphSource := s, DigraphRange := r2));;
gap> gr1 = gr2;
true
gap> gr1 := Digraph([[2], []]);;
gap> gr2 := Digraph([[1]]);;
gap> gr1 = gr2;  # Different number of vertices
false
gap> gr2 := Digraph([[1], [2]]);;
gap> gr1 = gr2;  # Different number of edges
false
gap> EmptyDigraph(2) = Digraph([[], []]);  # Both empty digraphs
true
gap> gr1 := Digraph(rec(
> DigraphNrVertices := 2, DigraphSource := [1, 2], DigraphRange := [1, 2]));;
gap> OutNeighbours(gr1);;
gap> gr1 = gr2;  # Equal outneighbours
true
gap> gr1 := Digraph([[], [1, 2]]);;
gap> gr1 = gr2;  # Different lengths of out[1]
false
gap> gr1 := Digraph([[1, 1], []]);;
gap> gr1 = gr2;  # Different lengths of out[1]
false
gap> gr1 := Digraph([[1], [1]]);;
gap> gr1 = gr2;  # Different contents of out[2]
false
gap> gr1 := Digraph([[1], [1, 2]]);;
gap> gr2 := Digraph([[1], [1, 1]]);;
gap> gr1 = gr2;  # Different contents of out[2]
false
gap> gr2 := Digraph([[1], [2, 1]]);;
gap> gr1 = gr2;  # out[2] sorted differently
true
gap> gr1 := Digraph(
> [[10, 8, 4, 6, 7, 2, 9, 5, 3], [10, 9, 2, 1, 4, 7, 6, 8, 3],
>  [6, 7, 9, 3, 10, 5, 2, 4, 1], [1, 7, 4, 8, 5, 3, 9, 10],
>  [2, 9, 6, 10, 5, 8, 3, 4, 7], [3, 6, 10, 1, 7, 9, 5, 8, 4],
>  [1, 9, 4, 10, 7, 8, 5, 2], [4, 10, 7, 6, 1, 2, 3, 8, 5],
>  [6, 2, 7, 9, 3, 8, 5, 1, 4], [4, 3, 2, 10, 8, 7, 5, 6, 9]]);;
gap> gr2 := Digraph(List(ShallowCopy(OutNeighbours(gr1)), Reversed));;
gap> gr1 = gr2;
true
gap> gr1 := Digraph(
> [[1, 4, 9], [7], [6, 7, 9, 10], [2, 6], [4, 5], [1, 8, 10],
>  [8], [4, 6], [1, 4, 9], [2, 3, 6, 8]]);;
gap> new := List(ShallowCopy(OutNeighbours(gr1)), Reversed);;
gap> new[10] := [8, 6, 7, 2];;
gap> gr2 := Digraph(new);;
gap> gr1 = gr2;
false
gap> gr1 := RandomDigraph(10, 0.264);;
gap> gr2 := Digraph(List(ShallowCopy(OutNeighbours(gr1)), Reversed));;
gap> gr1 = gr2;
true
gap> gr1 := Digraph(rec(DigraphNrVertices := 0, DigraphSource := [], DigraphRange := []));;
gap> gr1 = gr1;  # IsIdenticalObj
true
gap> gr2 := Digraph(rec(DigraphNrVertices := 1, DigraphSource := [], DigraphRange := []));;
gap> gr1 = gr2;  # Different number of vertices
false
gap> gr1 := Digraph(rec(DigraphNrVertices := 1, DigraphSource := [1], DigraphRange := [1]));;
gap> gr1 = gr2;  # Different sources
false
gap> gr2 := Digraph(rec(DigraphNrVertices := 1, DigraphSource := [1], DigraphRange := [1]));;
gap> gr1 = gr2;  # Equal range
true
gap> gr1 := Digraph(rec(
> DigraphNrVertices := 3, DigraphSource := [1, 2, 2, 3, 3], DigraphRange := [1, 1, 2, 2, 3]));;
gap> gr2 := Digraph(rec(
> DigraphNrVertices := 3, DigraphSource := [1, 2, 2, 3, 3], DigraphRange := [1, 2, 2, 3, 2]));;
gap> gr1 = gr2;  # Different contents of out[2]
false
gap> gr1 := Digraph(rec(
> DigraphNrVertices := 3, DigraphSource := [1, 2, 2, 3, 3], DigraphRange := [1, 1, 2, 2, 3]));;
gap> gr2 := Digraph(rec(
> DigraphNrVertices := 3, DigraphSource := [1, 2, 2, 3, 3], DigraphRange := [1, 2, 1, 3, 3]));;
gap> gr1 = gr2;  # Different contents of out[3]
false
gap> gr1 := Digraph(rec(
> DigraphNrVertices := 3, DigraphSource := [1, 2, 2, 3, 3], DigraphRange := [1, 1, 2, 2, 3]));;
gap> gr2 := Digraph(rec(
> DigraphNrVertices := 3, DigraphSource := [1, 2, 2, 3, 3], DigraphRange := [1, 2, 1, 3, 2]));;
gap> gr1 = gr2;  # out[2] and out[3] sorted differently
true
gap> s :=
> [1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3,
>  3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6,
>  6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8,
>  8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 10, 10, 10];;
gap> r1 :=
> [10, 8, 4, 7, 6, 2, 9, 5, 3, 10, 9, 2, 1, 4, 7, 6, 8, 3, 6, 7, 9, 3,
>  10, 5, 2, 4, 1, 1, 7, 4, 8, 5, 3, 9, 10, 2, 9, 6, 10, 5, 8, 3, 4, 7,
>  3, 6, 10, 1, 7, 9, 5, 8, 4, 1, 9, 4, 10, 7, 8, 5, 2, 4, 10, 7, 6, 1,
>  2, 3, 8, 5, 6, 2, 7, 9, 3, 8, 5, 1, 4, 4, 3, 2, 10, 8, 7, 5, 6, 9];;
gap> r2 :=
> [3, 5, 9, 2, 7, 6, 4, 8, 10, 3, 8, 6, 7, 4, 1, 2, 9, 10, 1, 4, 2, 5,
>  10, 3, 9, 7, 6, 10, 9, 3, 5, 8, 4, 7, 1, 7, 4, 3, 8, 5, 10, 6, 9, 2,
>  4, 8, 5, 9, 7, 1, 10, 6, 3, 2, 5, 8, 7, 10, 4, 9, 1, 5, 8, 3, 2, 1, 6,
>  7, 10, 4, 4, 1, 5, 8, 3, 9, 7, 2, 6, 9, 6, 5, 7, 8, 10, 2, 3, 4];;
gap> gr1 := Digraph(rec(DigraphNrVertices := 10, DigraphSource := s, DigraphRange := r1));;
gap> gr2 := Digraph(rec(DigraphNrVertices := 10, DigraphSource := s, DigraphRange := r2));;
gap> gr1 = gr2;
true

#  Less than (\<) for two digraphs
gap> gr1 := RandomMultiDigraph(10, 20);;
gap> gr2 := RandomMultiDigraph(11, 21);;
gap> gr1 < gr2;  # Different NrVertices
true
gap> gr2 < gr1;
false
gap> gr2 := RandomMultiDigraph(10, 21);;
gap> gr1 < gr2;  # Different NrEdges
true
gap> gr2 < gr1;
false
gap> error := false;;  # Test lots randomly with equal vertices & edges
> for i in [1 .. 20] do
>   j := Random([10 .. 100]);
>   k := Random([j .. j ^ 2]);
>   gr1 := RandomMultiDigraph(j, k);
>   gr2 := RandomMultiDigraph(j, k);
>   c1 := gr1 < gr2;
>   c2 := gr2 < gr1;
>   if c1 and c2 then
>     error := true;
>   fi;
>   if not c1 and not c2 and not c1 = c2 then
>     error := true;
>   fi;
> od;
> if error then
>   Print("Error encountered!");
> fi;
gap> gr1 := Digraph([[1], [1, 1]]);
<immutable multidigraph with 2 vertices, 3 edges>
gap> gr2 := Digraph([[2, 2], [1]]);
<immutable multidigraph with 2 vertices, 3 edges>
gap> gr1 < gr2;
true
gap> gr2 < gr1;
false
gap> gr1 := Digraph([[1], [1, 1]]);
<immutable multidigraph with 2 vertices, 3 edges>
gap> gr2 := Digraph([[1, 1], [2]]);
<immutable multidigraph with 2 vertices, 3 edges>
gap> gr1 < gr2;
false
gap> gr2 < gr1;
true
gap> gr1 := Digraph([[2], [1, 2]]);
<immutable digraph with 2 vertices, 3 edges>
gap> gr2 := Digraph([[1, 2], [2]]);
<immutable digraph with 2 vertices, 3 edges>
gap> gr1 < gr2;
false
gap> gr2 < gr1;
true
gap> gr1 := Digraph([[3], [], [2]]);
<immutable digraph with 3 vertices, 2 edges>
gap> gr2 := Digraph([[3], [], [2]]);
<immutable digraph with 3 vertices, 2 edges>
gap> gr1 < gr2;
false
gap> gr2 < gr1;
false
gap> gr1 = gr2;
true
gap> gr1 := Digraph([[3], [], [2]]);
<immutable digraph with 3 vertices, 2 edges>
gap> gr2 := Digraph([[3], [1], []]);
<immutable digraph with 3 vertices, 2 edges>
gap> gr1 < gr2;
false
gap> gr2 < gr1;
true
gap> gr1 := Digraph([[3], [], [2, 3]]);
<immutable digraph with 3 vertices, 3 edges>
gap> gr2 := Digraph([[3], [], [3, 2]]);
<immutable digraph with 3 vertices, 3 edges>
gap> gr1 < gr2;
false
gap> gr2 < gr1;
false
gap> gr1 = gr2;
true
gap> gr1 := Digraph([[3], [], [2, 3]]);
<immutable digraph with 3 vertices, 3 edges>
gap> gr2 := Digraph([[3], [], [2, 3]]);
<immutable digraph with 3 vertices, 3 edges>
gap> gr1 < gr2;
false
gap> gr2 < gr1;
false
gap> gr1 = gr2;
true
gap> gr1 := Digraph([[3], [2], [1, 2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> gr2 := Digraph([[3], [1, 2], [1]]);
<immutable digraph with 3 vertices, 4 edges>
gap> gr1 < gr2;
false
gap> gr2 < gr1;
true
gap> gr1 := Digraph([[3], [1], [1, 2]]);
<immutable digraph with 3 vertices, 4 edges>
gap> gr2 := Digraph([[3], [2, 3], [1]]);
<immutable digraph with 3 vertices, 4 edges>
gap> gr1 < gr2;
true
gap> gr2 < gr1;
false
gap> gr1 := Digraph([
>   [1, 2, 3], [15], [1, 11], [8, 14, 11, 15],
>   [10, 11, 10, 20, 15, 8, 16, 2], [11, 4], [11, 18], [6, 14],
>   [18, 7, 13], [5, 16, 5, 19], [13], [8, 18], [12], [5],
>   [5, 4, 7, 19, 13], [15], [17, 19, 3], [9], [4, 12, 14], [3]]);
<immutable multidigraph with 20 vertices, 50 edges>
gap> gr2 := Digraph([
>   [1, 2, 3], [15], [1, 11], [8, 14, 11, 15],
>   [10, 11, 10, 20, 15, 8, 16, 2], [11, 4], [11, 18], [6, 14],
>   [18, 7, 13], [5, 16, 5, 19], [13], [8, 18, 12], [], [5],
>   [5, 4, 7, 19, 13], [15], [17, 19, 3], [9], [4, 12, 14], [3]]);
<immutable multidigraph with 20 vertices, 50 edges>
gap> gr1 = gr2;
false
gap> gr1 < gr2;
false
gap> gr2 < gr1;
true

#  DigraphCopy

# Tests for DigraphCopy originally located in digraph.tst
gap> gr1 := CompleteDigraph(6);
<immutable digraph with 6 vertices, 30 edges>
gap> SetDigraphVertexLabels(gr1, Elements(SymmetricGroup(3)));
gap> DigraphVertexLabels(gr1);
[ (), (2,3), (1,2), (1,2,3), (1,3,2), (1,3) ]
gap> AdjacencyMatrix(gr1);;
gap> HasAdjacencyMatrix(gr1);
true
gap> gr2 := DigraphCopy(gr1);
<immutable digraph with 6 vertices, 30 edges>
gap> gr1 = gr2;
true
gap> IsIdenticalObj(gr1, gr2);
false
gap> HasAdjacencyMatrix(gr2);
false
gap> gr1 := EmptyDigraph(0);;
gap> gr2 := DigraphCopy(gr1);
<immutable digraph with 0 vertices, 0 edges>
gap> String(gr2);
"Digraph( [ ] )"
gap> PrintString(gr2);
"Digraph( [ ] )"

# Tests for DigraphCopy originally located in oper.tst
gap> gr := Digraph([[6, 1, 2, 3], [6], [2, 2, 3], [1, 1], [6, 5],
> [6, 4]]);
<immutable multidigraph with 6 vertices, 14 edges>
gap> gr = DigraphCopy(gr);
true
gap> gr := CompleteDigraph(100);
<immutable digraph with 100 vertices, 9900 edges>
gap> gr = DigraphCopy(gr);
true
gap> gr := CycleDigraph(10000);
<immutable digraph with 10000 vertices, 10000 edges>
gap> gr = DigraphCopy(gr);
true
gap> SetDigraphVertexLabel(gr, 1, "w");
gap> DigraphVertexLabels(DigraphCopy(gr))[1];
"w"
gap> gr := Digraph(rec(DigraphVertices := ["a", Group((1, 2))],
> DigraphSource := [Group((1, 2))], DigraphRange := ["a"]));
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphVertexLabels(gr);
[ "a", Group([ (1,2) ]) ]
gap> gr2 := DigraphCopy(gr);;
gap> gr = gr2;
true
gap> DigraphVertexLabels(gr2);
[ "a", Group([ (1,2) ]) ]

# Digraph: for a list and a function
gap> G := DihedralGroup(8);
<pc group of size 8 with 3 generators>
gap> digraph := Digraph(G, ReturnTrue);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Digraph' on 2 arguments
gap> digraph := Digraph(AsSet(G), ReturnTrue);
<immutable digraph with 8 vertices, 64 edges>
gap> HasDigraphAdjacencyFunction(digraph);
true
gap> digraph := DigraphCopy(digraph);
<immutable digraph with 8 vertices, 64 edges>
gap> HasDigraphAdjacencyFunction(digraph);
false
gap> foo := function(x, y)
> return ForAny(GeneratorsOfGroup(G), z -> x * z = y);
> end;
function( x, y ) ... end
gap> digraph := Digraph(AsSet(G), foo);
<immutable digraph with 8 vertices, 24 edges>
gap> G := DihedralGroup(8);
<pc group of size 8 with 3 generators>
gap> digraph := Digraph(AsSet(G), ReturnTrue);
<immutable digraph with 8 vertices, 64 edges>
gap> IsDenseDigraphRep(digraph);
true
gap> digraph := Digraph("abcd", function(i, j) return i < j; end);
<immutable digraph with 4 vertices, 6 edges>
gap> digraph := Digraph([1 .. 10], function(i, j) return i = j + 1; end);
<immutable digraph with 10 vertices, 9 edges>
gap> digraph := Digraph(["hello", "world", 13, true, (1, 4, 3)],
>                  function(i, j) return j = "world"; end);
<immutable digraph with 5 vertices, 5 edges>
gap> HasDigraphAdjacencyFunction(digraph);
true
gap> IsDenseDigraphRep(digraph);
true

#  Digraphs with known automorphisms
gap> gr := Digraph([[], [], [], [], [1, 2, 3, 4, 5]]);;
gap> adj := function(x, y)
> return x = 5;
> end;;
gap> gr2 := Digraph(SymmetricGroup([1 .. 4]), [1 .. 5], OnPoints, adj);;
gap> gr3 := Digraph(Group((1, 2, 3, 4)), [1 .. 5], OnPoints, adj);;
gap> gr = gr2;
true
gap> gr = gr3;
true

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
<immutable digraph with 8 vertices, 8 edges>
gap> gr2 := LineDigraph(gr);
<immutable digraph with 8 vertices, 8 edges>
gap> DigraphGroup(gr);
Group([ (1,2,3,4,5,6,7,8) ])
gap> gr3 := LineDigraph(gr);
<immutable digraph with 8 vertices, 8 edges>
gap> gr2 = gr3;
true
gap> gr := ChainDigraph(4);
<immutable digraph with 4 vertices, 3 edges>
gap> LineUndirectedDigraph(gr);
Error, the argument <digraph> must be a symmetric digraph,

#  CayleyDigraph
gap> group := DihedralGroup(8);
<pc group of size 8 with 3 generators>
gap> digraph := CayleyDigraph(group);
<immutable digraph with 8 vertices, 24 edges>
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
Error, the 2nd argument must consist of elements of the 1st argument,
gap> group := FreeGroup(2);;
gap> digraph := CayleyDigraph(group);
Error, the 1st argument must be a finite group,

#  BipartiteDoubleDigraph
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
gap> gr := Digraph([[2, 2], [3, 3], []]);
<immutable multidigraph with 3 vertices, 4 edges>
gap> OutNeighbours(DistanceDigraph(gr, 0));
[ [ 1 ], [ 2 ], [ 3 ] ]
gap> OutNeighbours(DistanceDigraph(gr, 1));
[ [ 2 ], [ 3 ], [  ] ]
gap> OutNeighbours(DistanceDigraph(gr, 2));
[ [ 3 ], [  ], [  ] ]

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

#  DistanceDigraph on multidigraph with known automorphisms
gap> gr := Digraph([[1, 2, 2], [], [2, 2, 3]]);;
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
Error, second arg <distance> must be a non-negative integer,

#  DigraphAddEdgeOrbit
gap> digraph := NullDigraph(4);
<immutable digraph with 4 vertices, 0 edges>
gap> HasDigraphGroup(digraph);
true
gap> digraph := DigraphCopy(digraph);
<immutable digraph with 4 vertices, 0 edges>
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
<immutable digraph with 4 vertices, 12 edges>
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
gap> if DIGRAPHS_IsGrapeLoaded then
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
gap> if DIGRAPHS_IsGrapeLoaded then
>   gr := Digraph(CompleteGraph(Group((1, 2, 3), (1, 2))));
> else
>   gr := Digraph([[2, 3], [1, 3], [1, 2]]);
>   SetDigraphGroup(gr, Group((1, 2, 3), (1, 2)));
> fi;
gap> HasDigraphGroup(gr);
true
gap> DigraphGroup(gr);
Group([ (1,2,3), (1,2) ])
gap> if DIGRAPHS_IsGrapeLoaded then
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
<immutable digraph with 0 vertices, 0 edges>
gap> OutNeighbours(digraph);
[  ]
gap> HasDigraphGroup(digraph);
true
gap> digraph := EdgeOrbitsDigraph(Group((1, 2)), [[1, 2], [3, 6, 5]]);
Error, the 2nd argument must be a list of pairs of positive integers,
gap> digraph := EdgeOrbitsDigraph(Group((1, 2)), [[1, 2], [3, -6]]);
Error, the 2nd argument must be a list of pairs of positive integers,
gap> digraph := EdgeOrbitsDigraph(Group((1, 2)), [[1, 2], [3, 6]], -1);
Error, the 3rd argument must be a non-negative integer,

#  DigraphAdd/RemoveEdgeOrbit
gap> gr1 := CayleyDigraph(DihedralGroup(8));
<immutable digraph with 8 vertices, 24 edges>
gap> gr2 := DigraphAddEdgeOrbit(gr1, [1, 8]);
<immutable digraph with 8 vertices, 32 edges>
gap> DigraphEdges(gr1);
[ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 1 ], [ 2, 8 ], [ 2, 6 ], [ 3, 5 ], 
  [ 3, 4 ], [ 3, 7 ], [ 4, 6 ], [ 4, 7 ], [ 4, 1 ], [ 5, 3 ], [ 5, 2 ], 
  [ 5, 8 ], [ 6, 4 ], [ 6, 5 ], [ 6, 2 ], [ 7, 8 ], [ 7, 1 ], [ 7, 3 ], 
  [ 8, 7 ], [ 8, 6 ], [ 8, 5 ] ]
gap> DigraphEdges(gr2);
[ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 1, 8 ], [ 2, 1 ], [ 2, 8 ], [ 2, 6 ], 
  [ 2, 3 ], [ 3, 5 ], [ 3, 4 ], [ 3, 7 ], [ 3, 2 ], [ 4, 6 ], [ 4, 7 ], 
  [ 4, 1 ], [ 4, 5 ], [ 5, 3 ], [ 5, 2 ], [ 5, 8 ], [ 5, 4 ], [ 6, 4 ], 
  [ 6, 5 ], [ 6, 2 ], [ 6, 7 ], [ 7, 8 ], [ 7, 1 ], [ 7, 3 ], [ 7, 6 ], 
  [ 8, 7 ], [ 8, 6 ], [ 8, 5 ], [ 8, 1 ] ]
gap> gr3 := DigraphRemoveEdgeOrbit(gr2, [1, 8]);
<immutable digraph with 8 vertices, 24 edges>
gap> gr3 = gr1;
true
gap> gr3 := DigraphRemoveEdgeOrbit(gr1, [1, 3]);
<immutable digraph with 8 vertices, 16 edges>
gap> gr3 := DigraphRemoveEdgeOrbit(gr3, [1, 2]);
<immutable digraph with 8 vertices, 8 edges>
gap> gr3 := DigraphRemoveEdgeOrbit(gr3, [1, 4]);
<immutable digraph with 8 vertices, 0 edges>
gap> DigraphAddEdgeOrbit(gr1, [0, 3]);
Error, the 2nd argument must be a list of 2 positive integers,
gap> DigraphAddEdgeOrbit(gr1, [1, 2, 3]);
Error, the 2nd argument must be a list of 2 positive integers,
gap> DigraphRemoveEdgeOrbit(gr1, [0, 3]);
Error, the 2nd argument must be a pair of positive integers,
gap> DigraphRemoveEdgeOrbit(gr1, [1, 2, 3]);
Error, the 2nd argument must be a pair of positive integers,
gap> gr2 := DigraphAddEdgeOrbit(gr1, [1, 4]);
<immutable digraph with 8 vertices, 24 edges>
gap> gr1 = gr2;
true
gap> DigraphAddEdgeOrbit(gr1, [3, 9]);
Error, the 2nd argument must be a list of 2 vertices of the 1st argument,
gap> DigraphRemoveEdgeOrbit(gr1, [3, 9]);
Error, the 2nd argument must be a pair of vertices of the 1st argument,
gap> gr2 := DigraphRemoveEdgeOrbit(gr1, [1, 8]);
<immutable digraph with 8 vertices, 24 edges>
gap> gr1 = gr2;
true

#  Digraph (by list and function)
gap> f := function(i, j) return i < j; end;
function( i, j ) ... end
gap> gr := Digraph([1 .. 4], f);
<immutable digraph with 4 vertices, 6 edges>
gap> IsDigraphEdge(gr, [2, 1]);
false
gap> gr := Digraph([4, 3 .. 1], f);
<immutable digraph with 4 vertices, 6 edges>
gap> IsDigraphEdge(gr, [2, 1]);
true

#  DigraphAddAllLoops
gap> gr := CompleteDigraph(10);
<immutable digraph with 10 vertices, 90 edges>
gap> OutNeighbours(gr)[1];
[ 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> gr2 := DigraphAddAllLoops(gr);
<immutable digraph with 10 vertices, 100 edges>
gap> OutNeighbours(gr2)[1];
[ 2, 3, 4, 5, 6, 7, 8, 9, 10, 1 ]
gap> gr3 := DigraphAddAllLoops(gr);
<immutable digraph with 10 vertices, 100 edges>
gap> OutNeighbours(gr3)[1];
[ 2, 3, 4, 5, 6, 7, 8, 9, 10, 1 ]
gap> gr := EmptyDigraph(100);
<immutable digraph with 100 vertices, 0 edges>
gap> DigraphAddAllLoops(gr);
<immutable digraph with 100 vertices, 100 edges>
gap> gr := Digraph([[1, 2, 3], [2, 2, 2, 2], [5, 1], [1, 2, 3, 4], [5]]);
<immutable multidigraph with 5 vertices, 14 edges>
gap> gr2 := DigraphAddAllLoops(gr);
<immutable multidigraph with 5 vertices, 15 edges>
gap> OutNeighbours(gr2);
[ [ 1, 2, 3 ], [ 2, 2, 2, 2 ], [ 5, 1, 3 ], [ 1, 2, 3, 4 ], [ 5 ] ]

#  JohnsonDigraph
gap> JohnsonDigraph(0, 4);
<immutable digraph with 0 vertices, 0 edges>
gap> JohnsonDigraph(0, 0);
<immutable digraph with 1 vertex, 0 edges>
gap> JohnsonDigraph(3, 0);
<immutable digraph with 1 vertex, 0 edges>
gap> JohnsonDigraph(1, 0);
<immutable digraph with 1 vertex, 0 edges>
gap> gr := JohnsonDigraph(3, 1);
<immutable digraph with 3 vertices, 6 edges>
gap> OutNeighbours(gr);
[ [ 2, 3 ], [ 1, 3 ], [ 1, 2 ] ]
gap> gr := JohnsonDigraph(4, 2);
<immutable digraph with 6 vertices, 24 edges>
gap> OutNeighbours(gr);
[ [ 2, 3, 4, 5 ], [ 1, 3, 4, 6 ], [ 1, 2, 5, 6 ], [ 1, 2, 5, 6 ], 
  [ 1, 3, 4, 6 ], [ 2, 3, 4, 5 ] ]
gap> JohnsonDigraph(5, 1) = CompleteDigraph(5);
true
gap> JohnsonDigraph(3, -2);
Error, both arguments must be non-negative integers,
gap> JohnsonDigraph(-1, 2);
Error, both arguments must be non-negative integers,

#  CompleteMultipartiteDigraph
gap> CompleteMultipartiteDigraph([5, 4, 2]);
<immutable digraph with 11 vertices, 76 edges>
gap> CompleteMultipartiteDigraph([5, 4, 2, 10, 1000]);
<immutable digraph with 1021 vertices, 42296 edges>
gap> CompleteMultipartiteDigraph([5]);
<immutable digraph with 5 vertices, 0 edges>
gap> CompleteMultipartiteDigraph([]);
<immutable digraph with 0 vertices, 0 edges>
gap> CompleteMultipartiteDigraph([5, 4, 2, 10, -5]);
Error, the argument must be a list of positive integers,
gap> CompleteMultipartiteDigraph([5, 0, 2]);
Error, the argument must be a list of positive integers,
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

# Test errors in DigraphEdgeLabel
gap> gr := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> DigraphEdgeLabel(gr, 1, 2);
Error, Digraphs: DigraphEdgeLabel: usage,
edge labels are not supported on digraphs with multiple edges,
gap> SetDigraphEdgeLabels(gr, ReturnFalse);
Error, Digraphs: SetDigraphEdgeLabels: usage,
edge labels are not supported on digraphs with multiple edges,
gap> gr := Digraph([[2, 1], []]);
<immutable digraph with 2 vertices, 2 edges>
gap> DigraphEdgeLabel(gr, 2, 2);
Error, Digraphs: DigraphEdgeLabel:
[2, 2] is not an edge of <D>,
gap> SetDigraphEdgeLabel(gr, 2, 2, "a");
Error, Digraphs: SetDigraphEdgeLabel:
[2, 2] is not an edge of <D>,

# ConvertToImmutableDigraphNC
gap> record := rec(OutNeighbours := [[1, 2], []]);
rec( OutNeighbours := [ [ 1, 2 ], [  ] ] )
gap> D := ConvertToImmutableDigraphNC(record);
<immutable digraph with 2 vertices, 2 edges>
gap> IsIdenticalObj(record, D);
true
gap> record;
<immutable digraph with 2 vertices, 2 edges>
gap> IsImmutableDigraph(D);
true
gap> IsMutable(D);
false
gap> IsMutable(OutNeighbours(D));
false
gap> IsMutable(OutNeighbours(D)[1]);
false
gap> IsIdenticalObj(OutNeighbours(D), OutNeighbours(D));
true
gap> IsIdenticalObj(DigraphSinks(D), DigraphSinks(D));
true
gap> IsAttributeStoringRep(D);
true

# MutableDigraphs
gap> list := [[1, 2], []];
[ [ 1, 2 ], [  ] ]
gap> D := MutableDigraphNC(list);
<mutable digraph with 2 vertices, 2 edges>
gap> IsMutableDigraph(D);
true
gap> IsMutable(D);
true
gap> OutNeighbours(D);
[ [ 1, 2 ], [  ] ]
gap> IsIdenticalObj(DigraphSinks(D), DigraphSinks(D));
false
gap> IsIdenticalObj(list, OutNeighbours(D));
false
gap> IsIdenticalObj(list[1], OutNeighbours(D)[1]);
false
gap> D := ConvertToMutableDigraphNC(list);
<mutable digraph with 2 vertices, 2 edges>
gap> IsMutableDigraph(D);
true
gap> IsMutable(D);
true
gap> OutNeighbours(D);
[ [ 1, 2 ], [  ] ]
gap> IsIdenticalObj(DigraphSinks(D), DigraphSinks(D));
false
gap> IsIdenticalObj(list, D!.OutNeighbours);
true
gap> D := MutableDigraphNC(OutNeighbours(MakeImmutableDigraph(D)));
<mutable digraph with 2 vertices, 2 edges>
gap> D := DigraphNC(rec(xxx := 1, DigraphRange := [], DigraphSource := [],
>  DigraphNrVertices := 1000));
<immutable digraph with 1000 vertices, 0 edges>
gap> IsBound(D!.xxx);
false
gap> list := [[1, 2], []];
[ [ 1, 2 ], [  ] ]
gap> D := MutableDigraphNC(list);
<mutable digraph with 2 vertices, 2 edges>
gap> PrintString(D);
"MutableDigraph( [ [ 1, 2 ], [ ] ] )"
gap> EvalString(String(D)) = D;
true
gap> MutableDigraphByAdjacencyMatrixNC([]);
<mutable digraph with 0 vertices, 0 edges>
gap> MutableDigraphByAdjacencyMatrixNC([[true]]);
<mutable digraph with 1 vertex, 1 edge>
gap> DigraphByAdjacencyMatrixNC([[true]]);
<immutable digraph with 1 vertex, 1 edge>
gap> MutableDigraphByEdges([]);
<mutable digraph with 0 vertices, 0 edges>
gap> MutableDigraphByEdges([], 10);
<mutable digraph with 10 vertices, 0 edges>
gap> D := AsMutableDigraph(Transformation([1, 1, 2]));
<mutable digraph with 3 vertices, 3 edges>
gap> IsFunctionalDigraph(D);
true

#  AsBinaryRelation
gap> gr := EmptyDigraph(0);
<immutable digraph with 0 vertices, 0 edges>
gap> AsBinaryRelation(gr);
Error, the argument (a digraph) must have at least one vertex,
gap> gr := Digraph([[1, 1]]);
<immutable multidigraph with 1 vertex, 2 edges>
gap> AsBinaryRelation(gr);
Error, the argument (a digraph) must not have multiple edges
gap> gr := Digraph(
> [[1, 2, 3], [1, 2, 3], [1, 2, 3], [4, 5], [4, 5]]);
<immutable digraph with 5 vertices, 13 edges>
gap> rel1 := AsBinaryRelation(gr);
Binary Relation on 5 points
gap> AsDigraph(rel1) = gr;
true
gap> IsReflexiveBinaryRelation(rel1);
true
gap> IsSymmetricBinaryRelation(rel1);
true
gap> IsTransitiveBinaryRelation(rel1);
true
gap> IsAntisymmetricBinaryRelation(rel1);
false
gap> IsEquivalenceRelation(rel1);
true
gap> List(EquivalenceClasses(rel1), Elements);
[ [ 1, 2, 3 ], [ 4, 5 ] ]
gap> DigraphStronglyConnectedComponents(gr).comps;
[ [ 1, 2, 3 ], [ 4, 5 ] ]
gap> last = last2;
true
gap> Successors(rel1);
[ [ 1, 2, 3 ], [ 1, 2, 3 ], [ 1, 2, 3 ], [ 4, 5 ], [ 4, 5 ] ]
gap> OutNeighbours(gr);
[ [ 1, 2, 3 ], [ 1, 2, 3 ], [ 1, 2, 3 ], [ 4, 5 ], [ 4, 5 ] ]
gap> last = last2;
true
gap> IsReflexiveDigraph(gr);
true
gap> IsSymmetricDigraph(gr);
true
gap> IsAntisymmetricDigraph(gr);
false
gap> rel2 := AsBinaryRelation(gr);
Binary Relation on 5 points
gap> HasIsReflexiveBinaryRelation(rel2);
true
gap> HasIsSymmetricBinaryRelation(rel2);
true
gap> HasIsTransitiveBinaryRelation(rel2);
false
gap> HasIsAntisymmetricBinaryRelation(rel2);
true
gap> rel3 := AsBinaryRelation(AsDigraph(rel1));
<equivalence relation on <object> >
gap> HasIsReflexiveBinaryRelation(rel3);
true
gap> HasIsSymmetricBinaryRelation(rel3);
true
gap> HasIsTransitiveBinaryRelation(rel3);
true
gap> HasIsAntisymmetricBinaryRelation(rel3);
true

# AsSemigroup, AsMonoid (for IsPartialPermX and a digraph)
gap> di := Digraph([[1], [1, 2], [1, 2, 3], [1, 2, 3, 4]]);;
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> di := Digraph([[1], [1, 2], [1, 3], [1, 2, 3, 4]]);;
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> temp := "&P_?@_?B`?FrCK_GXoXo_B?_A@aCA`GDroG`_?`?@e??c?@w??_";;
gap> di := DigraphFromDigraph6String(temp);;
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> temp := Concatenation("+u~~~~~~~~~^~w??????Nw???????E????????A",
>     "????????@_????????_???????AO????????g???????EE???????AA???????@`_?????",
>     "??__??????AQO???????gg??????NwF~~}???E?B~_??????@w????????o????????O??",
>     "??????W????????u????????Q????????Z?????A???_??????@w]???????oK???????O",
>     "C???????WE???????uL_??????QC_???@_?ZEw????_???G???AO??_C????g???I???EE",
>     "B~_@~o???@w??{?????o??W?????O??G?????W??K?????u??Z?????Q??H?????Z??L_?",
>     "AA??_??O???@w]?{N????oK?WE????OC?GA????WE?KB????uL_ZEo???QC_HAO@`_ZEwL",
>     "b[?__??G??CAQO?_C?OA?gg??I??D");;
gap> di := DigraphFromDigraph6String(temp);;
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> di := Digraph(Combinations([1 .. 6]), {i, j} -> IsSubset(i, j));;
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> di := Digraph([[1], [1, 2], [1, 2, 3, 4, 5, 6], [4], [4, 5], [6]]);;
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> di := Digraph([[1]]);;
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> di := Digraph([[1], [1, 2], [1, 2, 3], [1, 2, 4], [1, 2, 3, 4, 5]]);;
gap> S := AsMonoid(IsPartialPermMonoid, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> IsMonoid(S);
true
gap> di := Digraph([[1], [2]]);
<immutable digraph with 2 vertices, 2 edges>
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
Error, the second argument (a digraph) must be a join or  meet semilattice,
gap> S := AsMonoid(IsPartialPermMonoid, di);;
Error, Digraphs: AsMonoid usage,
the second argument must be a lattice digraph,
gap> S := AsSemigroup(IsTransformation, di);;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 2nd choice method found for `AsSemigroup' on 2 arguments
gap> S := AsMonoid(IsTransformation, di);;
Error, Digraphs: AsMonoid usage,
the first argument must be IsPartialPermMonoid or IsPartialPermSemigroup,

#  DIGRAPHS_UnbindVariables
gap> Unbind(G);
gap> Unbind(adj);
gap> Unbind(b);
gap> Unbind(bddigraph);
gap> Unbind(bdgroup);
gap> Unbind(bin);
gap> Unbind(d);
gap> Unbind(ddigraph);
gap> Unbind(digraph);
gap> Unbind(divides);
gap> Unbind(elms);
gap> Unbind(error);
gap> Unbind(f);
gap> Unbind(foo);
gap> Unbind(g);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(gr3);
gap> Unbind(gr4);
gap> Unbind(gr5);
gap> Unbind(gr6);
gap> Unbind(graph1);
gap> Unbind(graph2);
gap> Unbind(grnc);
gap> Unbind(group);
gap> Unbind(grrt);
gap> Unbind(h);
gap> Unbind(i);
gap> Unbind(im);
gap> Unbind(inn);
gap> Unbind(mat);
gap> Unbind(n);
gap> Unbind(new);
gap> Unbind(out);
gap> Unbind(r);
gap> Unbind(r1);
gap> Unbind(r2);
gap> Unbind(s);
gap> Unbind(v);
gap> Unbind(x);

#E#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/digraph.tst", 0);
