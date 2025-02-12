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

#  Digraph (by OutNeighbours)
gap> Digraph([[0, 1]]);
Error, the argument <list> must be a list of lists of positive integers not ex\
ceeding the length of the argument,
gap> Digraph([[2], [3]]);
Error, the argument <list> must be a list of lists of positive integers not ex\
ceeding the length of the argument,
gap> Digraph([[1],, [2]]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphCons' on 2 arguments
gap> Digraph([[1], 2, [3]]);
Error, the argument <list> must be a list of lists of positive integers not ex\
ceeding the length of the argument,

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
gap> Digraph(rec(DigraphNrVertices := n,
>                DigraphSource     := s,
>                DigraphVertices   := v));
Error, the argument <record> must be a record with components 'DigraphSource',\
 'DigraphRange', and either 'DigraphVertices' or 'DigraphNrVertices' (but not \
both),
gap> Digraph(rec(DigraphNrVertices := n,
>                DigraphRange      := r,
>                DigraphVertices   := v));
Error, the argument <record> must be a record with components 'DigraphSource',\
 'DigraphRange', and either 'DigraphVertices' or 'DigraphNrVertices' (but not \
both),
gap> Digraph(rec(DigraphSource := s, DigraphRange := r));
Error, the argument <record> must be a record with components 'DigraphSource',\
 'DigraphRange', and either 'DigraphVertices' or 'DigraphNrVertices' (but not \
both),
gap> Digraph(rec(DigraphNrVertices := n,
>                DigraphSource     := s,
>                DigraphRange      := 4));
Error, the record components 'DigraphSource' and 'DigraphRange' must be lists,
gap> Digraph(rec(DigraphNrVertices := n,
>                DigraphSource     := 1,
>                DigraphRange      := r));
Error, the record components 'DigraphSource' and 'DigraphRange' must be lists,
gap> Digraph(rec(DigraphNrVertices := n,
>                DigraphSource     := [1, 2],
>                DigraphRange      := r));
Error, the record components 'DigraphSource' and 'DigraphRange' must have equa\
l length,
gap> Digraph(rec(DigraphNrVertices := "a",
>                DigraphSource     := s,
>                DigraphRange      := r));
Error, the record component 'DigraphNrVertices' must be a non-negative integer\
,
gap> Digraph(rec(DigraphNrVertices := -3,
>                DigraphSource     := s,
>                DigraphRange      := r));
Error, the record component 'DigraphNrVertices' must be a non-negative integer\
,
gap> Digraph(rec(DigraphNrVertices := 2, DigraphVertices := [1 .. 3],
>                DigraphSource     := [2],
>                DigraphRange      := [2]));
Error, the record must only have one of the components 'DigraphVertices' and '\
DigraphNrVertices', not both,
gap> Digraph(rec(DigraphNrVertices := n,
>                DigraphSource     := [0 .. 2],
>                DigraphRange      := r));
Error, the record component 'DigraphSource' is invalid,
gap> Digraph(rec(DigraphNrVertices := n,
>                DigraphSource     := [2 .. 4],
>                DigraphRange      := r));
Error, the record component 'DigraphSource' is invalid,
gap> Digraph(rec(DigraphVertices := 2,
>                DigraphSource     := s,
>                DigraphRange      := r));
Error, the record component 'DigraphVertices' must be a list,
gap> Digraph(rec(DigraphNrVertices := n,
>                DigraphSource     := [1, 2, 4],
>                DigraphRange      := r));
Error, the record component 'DigraphSource' is invalid,
gap> Digraph(rec(DigraphVertices := v,
>                DigraphSource   := [1, 2, 4],
>                DigraphRange    := r));
Error, the record component 'DigraphSource' is invalid,
gap> Digraph(rec(DigraphNrVertices := n,
>                DigraphSource     := s,
>                DigraphRange      := [1, 4, 2]));
Error, the record component 'DigraphRange' is invalid,
gap> Digraph(rec(DigraphVertices := v,
>                DigraphSource   := s,
>                DigraphRange    := [1, 4, 2]));
Error, the record component 'DigraphRange' is invalid,
gap> Digraph(rec(DigraphVertices := "abc",
>                DigraphSource   := "acbab",
>                DigraphRange    := "cbabb"));
<immutable digraph with 3 vertices, 5 edges>
gap> Digraph(rec(DigraphVertices := [1, 1, 2],
>                DigraphSource   := [1, 2],
>                DigraphRange    := [1, 2]));
Error, the record component 'DigraphVertices' must be duplicate-free,

#  Digraph (by nrvertices, source, and range)
gap> Digraph(Group(()), [], []);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Digraph' on 3 arguments
gap> Digraph(2, [1, "a"], [2, 1]);
Error, the record component 'DigraphSource' is invalid,
gap> Digraph(2, [1, 1], [1, Group(())]);
Error, the record component 'DigraphRange' is invalid,
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
<immutable empty digraph with 5 vertices>
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
gap> Digraph(IsMutableDigraph, 4, [3, 1, 2, 3], [4, 1, 2, 4]);
<mutable multidigraph with 4 vertices, 4 edges>

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
gap> if DIGRAPHS_IsGrapeLoaded() then
>   g := Graph(gr);
>   if not Digraph(g) = gr then
>     Print("fail");
>   fi;
> fi;
gap> gr := Digraph(IsMutableDigraph, [1 .. 3], [3, 2, 1], [2, 3, 2]);
<mutable digraph with 3 vertices, 3 edges>

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
Error, the argument <rel> must be a binary relation on the domain [1 .. n] for\
 some positive integer n,
gap> d := Domain([2 .. 10]);;
gap> bin := BinaryRelationByElements(d, [
>  DirectProductElement([2, 5]),
>  DirectProductElement([6, 3]),
>  DirectProductElement([4, 5])]);;
gap> gr := AsDigraph(bin);
Error, the argument <rel> must be a binary relation on the domain [1 .. n] for\
 some positive integer n,
gap> d := Domain([1 .. 10]);;
gap> bin := BinaryRelationByElements(d, [
>  DirectProductElement([2, 5]),
>  DirectProductElement([6, 3]),
>  DirectProductElement([4, 5])]);;
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
<immutable equivalence digraph with 5 vertices, 9 edges>
gap> gr := Digraph([[1, 2], [3], []]);
<immutable digraph with 3 vertices, 3 edges>
gap> b := AsBinaryRelation(gr);;
gap> IsAntisymmetricBinaryRelation(b);
true
gap> gr := AsDigraph(b);
<immutable antisymmetric digraph with 3 vertices, 3 edges>
gap> HasIsAntisymmetricDigraph(gr);
true

#  DigraphByEdges
gap> gr := Digraph([[1, 2, 3, 5], [1, 5], [2, 3, 6], [1, 3, 4],
> [1, 4, 6], [3, 4]]);
<immutable digraph with 6 vertices, 17 edges>
gap> gr = DigraphByEdges(DigraphEdges(gr));
true
gap> DigraphByEdges([["nonsense", "more"]]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphByEdgesCons' on 3 arguments
gap> DigraphByEdges([["nonsense"]]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphByEdgesCons' on 3 arguments
gap> DigraphByEdges([["a", "b"]], 2);
Error, the 1st argument (list of edges) must be pairs of positive integers but\
 found [ "a", "b" ] in position 1
gap> DigraphByEdges([[1, 2, 3]], 3);
Error, the 1st argument (list of edges) must be a list of lists of length 2, f\
ound [ 1, 2, 3 ] (length 3 in position 1)
gap> gr := DigraphByEdges(DigraphEdges(gr), 10);
<immutable digraph with 10 vertices, 17 edges>
gap> gr := DigraphByEdges([[1, 2]]);
<immutable digraph with 2 vertices, 1 edge>
gap> gr := DigraphByEdges([[2, 1]]);
<immutable digraph with 2 vertices, 1 edge>
gap> gr := DigraphByEdges([[1, 2]], 1);
Error, the 1st argument (list of edges) must be pairs of positive integers <= 
1 but found [ 1, 2 ] in position 1
gap> gr := DigraphByEdges([], 3);
<immutable empty digraph with 3 vertices>
gap> gr := DigraphByEdges([]);
<immutable empty digraph with 0 vertices>
gap> gr = EmptyDigraph(0);
true
gap> DigraphByEdges([[1, 2], [3, 0]]);
Error, the 1st argument (list of edges) must be pairs of positive integers but\
 found [ 3, 0 ] in position 2
gap> DigraphByEdges([12], 10);
Error, the 1st argument (list of edges) must be a list of lists, but found int\
eger in position 1

#  DigraphByAdjacencyMatrix (by an integer matrix)

# for a matrix of integers
gap> mat := [
> [1, 2, 3],
> [1, 2, 3]];;
gap> DigraphByAdjacencyMatrix(mat);
Error, the argument <mat> must be a square matrix,
gap> mat := [
> [11, 2, 3],
> [11, 2, 3],
> [-1, 2, 2]];;
gap> DigraphByAdjacencyMatrix(mat);
Error, the argument <mat> must be a matrix of non-negative integers,
gap> mat := [["a"]];;
gap> DigraphByAdjacencyMatrix(mat);
Error, the argument <mat> must be a matrix of non-negative integers,
gap> mat := [
> [0, 2, 0, 0, 1],
> [0, 2, 1, 0, 1],
> [0, 0, 0, 0, 1],
> [1, 0, 1, 1, 0],
> [0, 0, 3, 0, 0]];;
gap> gr := DigraphByAdjacencyMatrix(mat);
<immutable multidigraph with 5 vertices, 14 edges>
gap> grnc := DigraphByAdjacencyMatrix(mat);
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
gap> r := rec(DigraphNrVertices := 10,
>             DigraphSource     := ShallowCopy(DigraphSource(gr)),
>             DigraphRange      := ShallowCopy(DigraphRange(gr)));;
gap> gr2 := Digraph(r);
<immutable multidigraph with 10 vertices, 73 edges>
gap> HasAdjacencyMatrix(gr2);
false
gap> AdjacencyMatrix(gr2) = mat;
true
gap> DigraphByAdjacencyMatrix([]);
<immutable empty digraph with 0 vertices>

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
gap> gr4 := DigraphByInNeighbours(inn);
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
Error, the argument <list> must be a list of lists of positive integers not ex\
ceeding the length of the argument,
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
gap> gr2 := DigraphByInNeighboursConsNC(IsImmutableDigraph, inn);
<immutable multidigraph with 20 vertices, 8 edges>
gap> gr2 := DigraphByInNeighbours(IsImmutableDigraph, inn);
<immutable multidigraph with 20 vertices, 8 edges>

#  AsDigraph for a transformation
gap> f := Transformation([]);
IdentityTransformation
gap> gr := AsDigraph(f);
<immutable empty digraph with 0 vertices>
gap> gr = Digraph([]);
true
gap> AsDigraph(f, 10);
<immutable functional digraph with 10 vertices>
gap> g := Transformation([2, 6, 7, 2, 6, 1, 1, 5]);
Transformation( [ 2, 6, 7, 2, 6, 1, 1, 5 ] )
gap> AsDigraph(g);
<immutable functional digraph with 8 vertices>
gap> AsDigraph(g, -1);
Error, the 2nd argument <n> should be a non-negative integer,
gap> AsDigraph(g, 10);
<immutable functional digraph with 10 vertices>
gap> AsDigraph(g, 6);
fail
gap> AsDigraph(g, 7);
<immutable functional digraph with 7 vertices>
gap> h := Transformation([2, 4, 1, 3, 5]);
Transformation( [ 2, 4, 1, 3 ] )
gap> AsDigraph(h);
<immutable functional digraph with 4 vertices>
gap> AsDigraph(h, 2);
fail

# AsDigraph for a permutation
gap> f := ();;
gap> D := AsDigraph(f);
<immutable empty digraph with 0 vertices>
gap> D = EmptyDigraph(0);
true
gap> AsDigraph(f, 10);
<immutable functional digraph with 10 vertices>
gap> g := (1, 3, 7)(2, 6, 5, 8);;
gap> D := AsDigraph(g);
<immutable functional digraph with 8 vertices>
gap> DigraphRange(D) = ListPerm(g);
true
gap> AsDigraph(g, -1);
Error, the 2nd argument <n> should be a non-negative integer,
gap> AsDigraph(g, 0);
<immutable empty digraph with 0 vertices>
gap> D := AsDigraph(g, 10);
<immutable functional digraph with 10 vertices>
gap> DigraphRange(D) = Concatenation(ListPerm(g), [9, 10]);
true
gap> AsDigraph(g, 7);
fail
gap> h := (2, 5, 3);;
gap> D := AsDigraph(IsMutableDigraph, h);
<mutable digraph with 5 vertices, 5 edges>
gap> DigraphRange(D) = ListPerm(h);
true
gap> AsDigraph(IsImmutableDigraph, h, 5);
<immutable functional digraph with 5 vertices>
gap> D = AsDigraph(IsImmutableDigraph, h, 5);
true
gap> D := AsDigraph(IsMutableDigraph, h, 6);
<mutable digraph with 6 vertices, 6 edges>
gap> OutNeighbours(D);
[ [ 1 ], [ 5 ], [ 2 ], [ 4 ], [ 3 ], [ 6 ] ]

# AsDigraph for a partial perm
gap> f := PartialPerm([]);;
gap> D := AsDigraph(f);
<immutable empty digraph with 0 vertices>
gap> D = EmptyDigraph(0);
true
gap> AsDigraph(f, 10);
<immutable empty digraph with 10 vertices>
gap> x := AsPartialPerm((1, 3, 7)(2, 6, 5, 8));
(1,3,7)(2,6,5,8)(4)
gap> D := AsDigraph(x);
<immutable digraph with 8 vertices, 8 edges>
gap> AsDigraph(x, -1);
Error, the 2nd argument <n> should be a non-negative integer,
gap> AsDigraph(x, 0);
<immutable empty digraph with 0 vertices>
gap> D := AsDigraph(g, 10);
<immutable functional digraph with 10 vertices>
gap> AsDigraph(g, 7);
fail
gap> x := AsPartialPerm((2, 5, 3), 5);
(1)(2,5,3)(4)
gap> D := AsDigraph(IsMutableDigraph, x);
<mutable digraph with 5 vertices, 5 edges>
gap> AsDigraph(IsImmutableDigraph, x, 5);
<immutable digraph with 5 vertices, 5 edges>
gap> D = AsDigraph(IsImmutableDigraph, x, 5);
true
gap> D := AsDigraph(IsMutableDigraph, x, 6);
<mutable digraph with 6 vertices, 5 edges>
gap> OutNeighbours(D);
[ [ 1 ], [ 5 ], [ 2 ], [ 4 ], [ 3 ], [  ] ]
gap> AsDigraph(AsPartialPerm((2, 5, 3)), 2);
fail

#  RandomDigraph
gap> IsImmutableDigraph(RandomDigraph(100, 0.2));
true
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
<immutable empty digraph with 4 vertices>
gap> RandomDigraph(10, 1.01);
Error, the 2nd argument <p> must be between 0 and 1,
gap> RandomDigraph(10, -0.01);
Error, the 2nd argument <p> must be between 0 and 1,
gap> RandomDigraph(10, 1 / 10);;

# RandomDigraph(IsImmutableDigraph, ...)
gap> IsImmutableDigraph(RandomDigraph(IsImmutableDigraph, 100, 0.2));
true
gap> DigraphNrVertices(RandomDigraph(IsImmutableDigraph, 10));
10
gap> DigraphNrVertices(RandomDigraph(IsImmutableDigraph, 200, 0.854));
200
gap> IsMultiDigraph(RandomDigraph(IsImmutableDigraph, 1000));
false
gap> RandomDigraph(IsImmutableDigraph, 0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RandomDigraph' on 2 arguments
gap> RandomDigraph(IsImmutableDigraph, "a");
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RandomDigraph' on 2 arguments
gap> RandomDigraph(IsImmutableDigraph, 4, 0);
<immutable empty digraph with 4 vertices>
gap> RandomDigraph(IsImmutableDigraph, 10, 1.01);
Error, the 2nd argument <p> must be between 0 and 1,
gap> RandomDigraph(IsImmutableDigraph, 10, -0.01);
Error, the 2nd argument <p> must be between 0 and 1,
gap> RandomDigraph(IsImmutableDigraph, 10, 1 / 10);;

# RandomDigraph(IsMutableDigraph, ...)
gap> IsMutableDigraph(RandomDigraph(IsMutableDigraph, 100, 0.2));
true
gap> DigraphNrVertices(RandomDigraph(IsMutableDigraph, 10));
10
gap> DigraphNrVertices(RandomDigraph(IsMutableDigraph, 200, 0.854));
200
gap> IsMultiDigraph(RandomDigraph(IsMutableDigraph, 1000));
false
gap> RandomDigraph(IsMutableDigraph, 0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RandomDigraph' on 2 arguments
gap> RandomDigraph(IsMutableDigraph, "a");
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RandomDigraph' on 2 arguments
gap> RandomDigraph(IsMutableDigraph, 4, 0);
<mutable empty digraph with 4 vertices>
gap> RandomDigraph(IsMutableDigraph, 10, 1.01);
Error, the 2nd argument <p> must be between 0 and 1,
gap> RandomDigraph(IsMutableDigraph, 10, -0.01);
Error, the 2nd argument <p> must be between 0 and 1,
gap> RandomDigraph(IsMutableDigraph, 10, 1 / 10);;

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
<immutable tournament with 25 vertices>
gap> RandomTournament(0);
<immutable empty digraph with 0 vertices>
gap> RandomTournament(-1);
Error, the argument <n> must be a non-negative integer,
gap> RandomTournament(IsMutableDigraph, 10);
<mutable digraph with 10 vertices, 45 edges>

#  RandomLattice
gap> RandomLattice(25);;
gap> RandomLattice(1);
<immutable digraph with 1 vertex, 1 edge>
gap> RandomLattice(-1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RandomLattice' on 1 arguments

# The list of random lattice Digraph6Strings D was generated by running:
# D := List([1 .. 100], x -> Digraph6String(RandomLattice(7)));
gap> D := [
> "&F~grwcIB?_", "&G~tSrCO{D?oC", "&F~kqG{IB?_",
> "&J~}jSpw`O~_t?a?{?g?o?_", "&H~zzIWxAGH?wB?G", "&G~t[~DosD?oC",
> "&F~kqG{IB?_", "&H~z~IgrAGN?gB?G", "&I~|TR~DSKoP?{@OB?C",
> "&G~s[jFOcD?oC", "&G~sc~EocF?oC", "&G~tSrCO{D?oC", "&F~kqG{IB?_",
> "&F~kqG{IB?_", "&I~|nqTFKKoP?{@OB?C", "&I~|OrPCCNoP?{@OB?C",
> "&F~kqG{IB?_", "&G~tSrCO{D?oC", "&H~ynMWbAWN?gB?G", "&G~tSrCO{D?oC",
> "&I~|Sr~DKLOP?{@OB?C", "&F~hrgcIB?_", "&G~s[rCOsD?oC", "&G~tCtCO{D?oC",
> "&F~lQG{IB?_", "&F~hrgcIB?_", "&I~|DRrDKGOP?{@OB?C", "&F~jRWcIB?_",
> "&G~tSpCO{D?oC", "&F~mrGcMB?_", "&F~iRwcMB?_", "&F~lQG{IB?_",
> "&F~lQG{IB?_", "&H~yhKw`BwH?wB?G", "&I~|zqdEKGO^?{@OB?C",
> "&G~tSrCO{D?oC", "&G~tSrCO{D?oC", "&G~tSrCO{D?oC", "&F~kqG{IB?_",
> "&F~lQG{IB?_", "&G~skxCOcF?oC", "&J~}dCggoo__~?a?{?g?o?_",
> "&F~lQG{IB?_", "&G~usdEocD?oC", "&G~tSrCO{D?oC", "&H~ybLG`BWH?wB?G",
> "&F~irgcIB?_", "&I~|TRBCCNoT?{@OB?C", "&F~iqwcMB?_", "&H~yTHgxAGH?gB?G",
> "&F~nqg{IB?_", "&I~|PRRCCNoR?{@OB?C", "&F~lqWcMB?_",
> "&J~}lKhgoo__~?e?s?g?o?_", "&F~nqW{IB?_", "&G~tSrCO{D?oC",
> "&F~jrWkMB?_", "&G~vKpCO{D?oC", "&F~irgcIB?_", "&H~y~LwnAWN?gB?G",
> "&F~kqG{IB?_", "&I~|zqdEKGO^?{@OB?C", "&G~t{`EocF?oC",
> "&H~zNGW~AGN?wB?G", "&H~zNGW~AgN?gB?G", "&F~nQgsIB?_", "&F~hrwkMB?_",
> "&G~vkbEocF?oC", "&G~s{zCOkF?oC", "&F~grwkMB?_", "&G~tKtCO{D?oC",
> "&F~nqwsIB?_", "&J~}jKpw_o~_r?a?{?g?o?_", "&F~nqg{IB?_",
> "&G~s{~DO{D?oC", "&G~tSrCO{D?oC", "&K~~\\tGdCTBr@p?`?P?N?D?B?@",
> "&G~tSrCO{D?oC", "&H~zjKW`BwJ?gB?G", "&K~~PrG^FnAd@b?`?R?N?D?B?@",
> "&H~ydKW`AWN?gB?G", "&F~lQG{IB?_", "&G~tSrCO{D?oC", "&H~zNGg~AGN?gB?G",
> "&G~u[bFocF?oC", "&H~yrMwrAGN?wB?G", "&G~t{zEocF?oC",
> "&H~yhJw`BWH?wB?G", "&G~uk`FokF?oC", "&F~lqGcMB?_", "&F~kqG{IB?_",
> "&G~sC~EocF?oC", "&F~lQG{IB?_", "&G~s[~EocF?oC", "&G~tKpCO{D?oC",
> "&F~jrGcMB?_", "&I~|SrNCKNoR?{@OB?C", "&F~lQG{IB?_", "&F~irgcIB?_",
> "&F~kqG{IB?_"];;
gap> D := List(D, DigraphFromDigraph6String);;
gap> iso := [];;
gap> iso_distr := [];;
gap> eq := [];;
gap> eq_distr := [];;
gap> for i in [1 .. Length(D)] do
>   iso_new := true;
>   eq_new := true;
>   for j in [1 .. Length(iso)] do
>     if IsIsomorphicDigraph(D[i], iso[j]) then
>       iso_distr[j] := iso_distr[j] + 1;
>       iso_new := false;
>       break;
>     fi;
>   od;
>   for j in [1 .. Length(eq)] do
>     if D[i] = eq[j] then
>       eq_distr[j] := eq_distr[j] + 1;
>       eq_new := false;
>       break;
>     fi;
>   od;
>   if iso_new then
>     Add(iso, D[i]);
>     Add(iso_distr, 1);
>   fi;
>   if eq_new then
>     Add(eq, D[i]);
>     Add(eq_distr, 1);
>   fi;
> od;

# The total number of nonisomorphic digraphs generated, out of 100.
# There are 53 distinct lattices on 7 points according to OEIS A006966
gap> Length(iso);
41

# The distribution of nonisomorhpic generated lattices.
# To the left is the number of times a particular lattice occurs among the
# randomly generated ones.
# To the right is how many distinct lattices have # this number of occurrences.
# So entry [3, 5] means that there were five distinct lattices each of which was
# generated 3 times.
gap> Display(Collected(iso_distr));
[ [   1,  26 ],
  [   2,   7 ],
  [   3,   3 ],
  [   4,   1 ],
  [   5,   2 ],
  [  14,   1 ],
  [  23,   1 ] ]

# Same as above but for non-equal lattices
gap> Length(eq);
69
gap> Display(Collected(eq_distr));
[ [   1,  62 ],
  [   2,   3 ],
  [   3,   1 ],
  [   8,   1 ],
  [   9,   1 ],
  [  12,   1 ] ]

#  Equals (\=) for two digraphs
gap> r1 := rec(DigraphNrVertices := 2,
>              DigraphSource     := [1, 1, 2],
>              DigraphRange      := [1, 2, 2]);;
gap> r2 := rec(DigraphNrVertices := 2,
>              DigraphSource     := [1, 1, 2],
>              DigraphRange      := [2, 1, 2]);;
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
<immutable empty digraph with 3 vertices>
gap> gr2 := Digraph(rec(DigraphNrVertices := 3,
>                       DigraphSource     := [],
>                       DigraphRange      := []));
<immutable empty digraph with 3 vertices>
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
gap> graph2 := Digraph(rec(DigraphNrVertices := 3,
>                          DigraphSource     := [1, 2],
>                          DigraphRange      := [2, 1]));
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
gap> gr2 := Digraph(rec(DigraphNrVertices := 1,
>                       DigraphSource     := [],
>                       DigraphRange      := []));;
gap> gr1 = gr2;  # Different number of vertices
false
gap> gr2 := Digraph(rec(DigraphNrVertices := 2,
>                       DigraphSource     := [1, 2],
>                       DigraphRange      := [1, 2]));;
gap> gr1 = gr2;  # Different number of edges
false
gap> EmptyDigraph(2) = Digraph(rec(DigraphNrVertices := 2,
>                                  DigraphSource     := [],
>                                  DigraphRange      := []));  # Both empty
true
gap> gr1 := Digraph([[], [1, 2]]);;
gap> gr1 = gr2;  # |out1[1]| = 0, |out2[1]| <> =
false
gap> gr1 := Digraph([[1, 1], [2, 2]]);;
gap> gr2 := Digraph(rec(DigraphNrVertices := 2,
>                       DigraphSource     := [1, 2, 2, 2],
>                       DigraphRange      := [1, 2, 2, 2]));;
gap> gr1 = gr2;  # |out1[1]| = 2, |out2[1]| = 1
false
gap> gr2 := Digraph(rec(DigraphNrVertices := 2,
>                       DigraphSource     := [1, 1, 1, 2],
>                       DigraphRange      := [1, 1, 1, 2]));;
gap> gr1 = gr2;  # |out1[1]| = 2, |out2[1]| = 3
false
gap> gr1 := Digraph([[1, 2], [2, 1]]);;
gap> gr2 := Digraph(rec(DigraphNrVertices := 2,
>                       DigraphSource     := [1, 1, 2, 2],
>                       DigraphRange      := [1, 2, 2, 2]));;
gap> gr1 = gr2;  # Different contents of out[2]
false
gap> gr2 := Digraph(rec(DigraphNrVertices := 2,
>                       DigraphSource     := [1, 1, 2, 2],
>                       DigraphRange      := [1, 2, 1, 2]));;
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
gap> gr2 := Digraph(rec(DigraphNrVertices := 10,
>                       DigraphSource     := s,
>                       DigraphRange      := r2));;
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
gap> gr1 := Digraph(rec(DigraphNrVertices := 2,
>                       DigraphSource     := [1, 2],
>                       DigraphRange      := [1, 2]));;
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
gap> gr1 := Digraph(rec(DigraphNrVertices := 0,
>                       DigraphSource     := [],
>                       DigraphRange      := []));;
gap> gr1 = gr1;  # IsIdenticalObj
true
gap> gr2 := Digraph(rec(DigraphNrVertices := 1,
>                       DigraphSource     := [],
>                       DigraphRange      := []));;
gap> gr1 = gr2;  # Different number of vertices
false
gap> gr1 := Digraph(rec(DigraphNrVertices := 1,
>                       DigraphSource     := [1],
>                       DigraphRange      := [1]));;
gap> gr1 = gr2;  # Different sources
false
gap> gr2 := Digraph(rec(DigraphNrVertices := 1,
>                       DigraphSource     := [1],
>                       DigraphRange      := [1]));;
gap> gr1 = gr2;  # Equal range
true
gap> gr1 := Digraph(rec(DigraphNrVertices := 3,
>                       DigraphSource     := [1, 2, 2, 3, 3],
>                       DigraphRange      := [1, 1, 2, 2, 3]));;
gap> gr2 := Digraph(rec(DigraphNrVertices := 3,
>                       DigraphSource     := [1, 2, 2, 3, 3],
>                       DigraphRange      := [1, 2, 2, 3, 2]));;
gap> gr1 = gr2;  # Different contents of out[2]
false
gap> gr1 := Digraph(rec(DigraphNrVertices := 3,
>                       DigraphSource     := [1, 2, 2, 3, 3],
>                       DigraphRange      := [1, 1, 2, 2, 3]));;
gap> gr2 := Digraph(rec(DigraphNrVertices := 3,
>                       DigraphSource     := [1, 2, 2, 3, 3],
>                       DigraphRange      := [1, 2, 1, 3, 3]));;
gap> gr1 = gr2;  # Different contents of out[3]
false
gap> gr1 := Digraph(rec(DigraphNrVertices := 3,
>                       DigraphSource     := [1, 2, 2, 3, 3],
>                       DigraphRange      := [1, 1, 2, 2, 3]));;
gap> gr2 := Digraph(rec(DigraphNrVertices := 3,
>                       DigraphSource     := [1, 2, 2, 3, 3],
>                       DigraphRange      := [1, 2, 1, 3, 2]));;
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
gap> gr1 := Digraph(rec(DigraphNrVertices := 10,
>                       DigraphSource     := s,
>                       DigraphRange      := r1));;
gap> gr2 := Digraph(rec(DigraphNrVertices := 10,
>                       DigraphSource     := s,
>                       DigraphRange      := r2));;
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
<immutable complete digraph with 6 vertices>
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
<immutable empty digraph with 0 vertices>
gap> String(gr2);
"Digraph([  ])"
gap> PrintString(gr2);
"Digraph([  ])"
gap> D := CycleDigraph(10 * 10 ^ 5);
<immutable cycle digraph with 1000000 vertices>
gap> D1 := DigraphCopy(D);
<immutable digraph with 1000000 vertices, 1000000 edges>
gap> DigraphEdgeLabels(D);;
gap> D2 := DigraphCopy(D);
<immutable digraph with 1000000 vertices, 1000000 edges>

# Tests for DigraphCopy originally located in oper.tst
gap> gr := Digraph([[6, 1, 2, 3], [6], [2, 2, 3], [1, 1], [6, 5],
> [6, 4]]);
<immutable multidigraph with 6 vertices, 14 edges>
gap> gr = DigraphCopy(gr);
true
gap> gr := CompleteDigraph(100);
<immutable complete digraph with 100 vertices>
gap> gr = DigraphCopy(gr);
true
gap> gr := CycleDigraph(10000);
<immutable cycle digraph with 10000 vertices>
gap> gr = DigraphCopy(gr);
true
gap> SetDigraphVertexLabel(gr, 1, "w");
gap> DigraphVertexLabels(DigraphCopy(gr))[1];
"w"
gap> gr := Digraph(rec(DigraphVertices := ["a", Group((1, 2))],
>                      DigraphSource   := [Group((1, 2))],
>                      DigraphRange    := ["a"]));
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
gap> IsDigraphByOutNeighboursRep(digraph);
true
gap> digraph := Digraph("abcd", function(i, j) return i < j; end);
<immutable digraph with 4 vertices, 6 edges>
gap> digraph := Digraph(IsMutableDigraph, "abcd", {i, j} -> i < j);
<mutable digraph with 4 vertices, 6 edges>
gap> digraph := Digraph([1 .. 10], function(i, j) return i = j + 1; end);
<immutable digraph with 10 vertices, 9 edges>
gap> digraph := Digraph(["hello", "world", 13, true, (1, 4, 3)],
>                  function(i, j) return j = "world"; end);
<immutable digraph with 5 vertices, 5 edges>
gap> HasDigraphAdjacencyFunction(digraph);
true
gap> IsDigraphByOutNeighboursRep(digraph);
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
gap> D := DigraphNC(IsMutableDigraph, list);
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
gap> D := DigraphNC(IsMutableDigraph, OutNeighbours(MakeImmutable(D)));
<mutable digraph with 2 vertices, 2 edges>
gap> D := DigraphNC(rec(xxx := 1, DigraphRange := [], DigraphSource := [],
>  DigraphNrVertices := 1000));
<immutable empty digraph with 1000 vertices>
gap> IsBound(D!.xxx);
false
gap> list := [[1, 2], []];
[ [ 1, 2 ], [  ] ]
gap> D := DigraphNC(IsMutableDigraph, list);
<mutable digraph with 2 vertices, 2 edges>
gap> PrintString(D);
"Digraph(IsMutableDigraph, [ [ 1, 2 ], [  ] ])"
gap> EvalString(String(D)) = D;
true
gap> DigraphByAdjacencyMatrix(IsMutableDigraph, []);
<mutable empty digraph with 0 vertices>
gap> DigraphByAdjacencyMatrix(IsMutableDigraph, [[true]]);
<mutable digraph with 1 vertex, 1 edge>
gap> DigraphByAdjacencyMatrix([[true]]);
<immutable digraph with 1 vertex, 1 edge>
gap> DigraphByEdges(IsMutableDigraph, []);
<mutable empty digraph with 0 vertices>
gap> DigraphByEdges(IsMutableDigraph, [], 10);
<mutable empty digraph with 10 vertices>
gap> D := AsDigraph(IsMutableDigraph, Transformation([1, 1, 2]));
<mutable digraph with 3 vertices, 3 edges>
gap> IsFunctionalDigraph(D);
true

#  AsBinaryRelation
gap> gr := EmptyDigraph(0);
<immutable empty digraph with 0 vertices>
gap> AsBinaryRelation(gr);
Error, the argument <D> must be a digraph with at least 1 vertex,
gap> gr := Digraph([[1, 1]]);
<immutable multidigraph with 1 vertex, 2 edges>
gap> AsBinaryRelation(gr);
Error, the argument <D> must be a digraph with no multiple edges
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
gap> rel3 := AsBinaryRelation(AsDigraph(rel1));;
gap> HasIsReflexiveBinaryRelation(rel3);
true
gap> HasIsSymmetricBinaryRelation(rel3);
true
gap> HasIsTransitiveBinaryRelation(rel3);
true
gap> HasIsAntisymmetricBinaryRelation(rel3);
true

# AsSemigroup, AsMonoid (for IsPartialPermX and a digraph)
gap> di := Digraph(IsMutableDigraph, [[1], [1, 2], [1, 2, 3], [1, 2, 3, 4]]);
<mutable digraph with 4 vertices, 10 edges>
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> di;
<mutable digraph with 4 vertices, 10 edges>
gap> di := DigraphMutableCopy(DigraphFromDigraph6String("&H_E?gF_~GH~n~?G"));
<mutable digraph with 9 vertices, 36 edges>
gap> S := AsSemigroup(IsPartialPermSemigroup, di);;
gap> IsInverseSemigroup(S) and ForAll(Elements(S), IsIdempotent);
true
gap> di = DigraphFromDigraph6String("&H_E?gF_~GH~n~?G");
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
Error, the 2nd argument <D> must be digraph that is a join or meet semilattice\
,
gap> S := AsMonoid(IsPartialPermMonoid, di);;
Error, the 2nd argument <D> must be a lattice digraph,
gap> S := AsSemigroup(IsTransformation, di);;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 2nd choice method found for `AsSemigroup' on 2 arguments
gap> S := AsMonoid(IsTransformation, di);;
Error, the 1st argument <filt> must be IsPartialPermMonoid or IsPartialPermSem\
igroup,

# AsSemigroup (for IsPartialPermSemigroup, a digraph, a list of groups,
# and homomorphisms)
gap> G1 := SymmetricGroup(4);;
gap> G2 := SymmetricGroup(2);;
gap> G3 := SymmetricGroup(3);;
gap> G4 := SymmetricGroup(4);;
gap> gr := Digraph(IsMutableDigraph, [[1, 3], [2, 3], [3]]);
<mutable digraph with 3 vertices, 5 edges>
gap> gr2 := Digraph([[1, 3], [2, 3], [3], [1, 2, 3, 4]]);
<immutable digraph with 4 vertices, 9 edges>
gap> sgn := function(x)
> if SignPerm(x) = 1 then
> return ();
> fi;
> return (1, 2);
> end;;
gap> hom13 := GroupHomomorphismByFunction(G1, G3, sgn);;
gap> hom23 := GroupHomomorphismByFunction(G2, G3, sgn);;
gap> T := AsSemigroup(IsPartialPermSemigroup, gr, [G1, G2, G3], [[1, 3, hom13],
> [2, 3, hom23]]);;
gap> gr;
<mutable digraph with 3 vertices, 5 edges>
gap> Size(T);
32
gap> D := GreensDClasses(T);;
gap> List(D, Size);
[ 6, 24, 2 ]
gap> for i in [1 .. 3] do
> for j in [1 .. 3] do
> for x in D[i] do
> for y in D[j] do
> if i = j and not x * y in D[i] then
> Error(D[i], x, y);
> elif i <> j and not x * y in D[1] then
> Error(D[i], D[j], x, y, x * y);
> fi;
> od;
> od;
> od;
> od;
gap> Size(GroupHClassOfGreensDClass(D[1])) = Size(D[1]);
true
gap> Size(GroupHClassOfGreensDClass(D[2])) = Size(D[2]);
true
gap> Size(GroupHClassOfGreensDClass(D[3])) = Size(D[3]);
true
gap> hom41 := GroupHomomorphismByFunction(G4, G1, sgn);;
gap> hom42 := GroupHomomorphismByFunction(G4, G2, sgn);;
gap> T := AsSemigroup(IsPartialPermSemigroup, gr2, [G1, G2, G3, G4],
> [[1, 3, hom13], [2, 3, hom23], [4, 1, hom41], [4, 2, hom42]]);;
gap> Size(T);
56
gap> List(GreensDClasses(T), Size);
[ 6, 24, 2, 24 ]
gap> List(GreensDClasses(T), x -> Size(x) = Size(GroupHClassOfGreensDClass(x)));
[ true, true, true, true ]
gap> gr3 := Digraph([[1]]);;
gap> T := AsSemigroup(IsPartialPermSemigroup, gr3, [G1], []);;
gap> Size(T);
24
gap> Size(GreensHClassOfElement(T, Representative(T)));
24
gap> gr4 := Digraph([[1], [1, 2], [1, 3], [1, 4], [1, 2, 3, 5]]);;
gap> G5 := AlternatingGroup(4);;
gap> G2 := SymmetricGroup(4);;
gap> hom21 := GroupHomomorphismByFunction(G2, G1, sgn);;
gap> hom31 := GroupHomomorphismByFunction(G3, G1, x -> x);;
gap> hom41 := GroupHomomorphismByFunction(G4, G1, x -> One(G1));;
gap> hom52 := GroupHomomorphismByFunction(G5, G2, x -> x);;
gap> hom53 := GroupHomomorphismByFunction(G5, G3, sgn);;
gap> T := AsSemigroup(IsPartialPermSemigroup, gr4, [G1, G2, G3, G4, G5],
> [[2, 1, hom21], [3, 1, hom31], [4, 1, hom41], [5, 2, hom52], [5, 3, hom53]]);;
gap> Size(T);
90
gap> List(GreensDClasses(T), Size);
[ 24, 24, 6, 24, 12 ]
gap> U := AsSemigroup(IsPartialPermSemigroup,
> DigraphReverse(gr4),
> [G1, G2, G3, G4, G5],
> [[2, 1, hom21], [3, 1, hom31], [4, 1, hom41], [5, 2, hom52], [5, 3, hom53]]);;
gap> U = T;
true
gap> gr5 := Digraph([[1], [1, 2], [1, 3], [1, 4], [2, 3, 5]]);;
gap> T := AsSemigroup(IsPartialPermSemigroup, gr5, [G1, G2, G3, G4, G5],
> [[2, 1, hom21], [3, 1, hom31], [4, 1, hom41], [5, 2, hom52], [5, 3, hom52]]);;
Error, the second argument must be a join semilattice digraph or a meet semila\
ttice digraph,
gap> T := AsSemigroup(IsPartialPermSemigroup, gr4, [G1, G2, G3, G4],
> [[2, 1, hom21], [3, 1, hom31], [4, 1, hom41], [5, 2, hom52], [5, 3, hom52]]);;
Error, the third argument must have length equal to the number of vertices in \
the second argument,
gap> S := FullTransformationMonoid(4);;
gap> T := AsSemigroup(IsPartialPermSemigroup, gr4, [S, G2, G3, G4, G5],
> [[2, 1, hom21], [3, 1, hom31], [4, 1, hom41], [5, 2, hom52], [5, 3, hom53]]);;
Error, the third argument must be a list of groups,
gap> T := AsSemigroup(IsPartialPermSemigroup, gr4, [G1, G2, G3, G4, G5],
> [[2, 1, hom21], [3, 1, hom31], [4, 1, hom41], [5, 2, hom52]]);;
Error, the third argument must be a list of triples [i, j, hom] of length equa\
l to the number of edges in the reflexive transitive reduction of the second a\
rgument, where [i, j] is an edge in the reflex transitive reduction and hom is\
 a group homomorphism from group i to group j,
gap> T := AsSemigroup(IsPartialPermSemigroup, gr4, [G1, G2, G3, G4, G5],
> [[2, 1, hom21], [3, 1, hom31], [4, 1, hom41], [5, 2, hom52], [5, 4, hom53]]);;
Error, the third argument must be a list of triples [i, j, hom] of length equa\
l to the number of edges in the reflexive transitive reduction of the second a\
rgument, where [i, j] is an edge in the reflex transitive reduction and hom is\
 a group homomorphism from group i to group j,
gap> T := AsSemigroup(IsPartialPermSemigroup, gr4, [G1, G2, G3, G4, G5],
> [[2, 1], [3, 1, hom31], [4, 1, hom41], [5, 2, hom52], [5, 3, hom53]]);;
Error, the third argument must be a list of triples [i, j, hom] of length equa\
l to the number of edges in the reflexive transitive reduction of the second a\
rgument, where [i, j] is an edge in the reflex transitive reduction and hom is\
 a group homomorphism from group i to group j,
gap> T := AsSemigroup(IsPartialPermSemigroup, gr4, [G1, G2, G3, G4, G5],
> [[-2, 1, hom21],
>  [3, 1, hom31],
>  [4, 1, hom41],
>  [5, 2, hom52],
>  [5, 3, hom53]]);;
Error, the third argument must be a list of triples [i, j, hom] of length equa\
l to the number of edges in the reflexive transitive reduction of the second a\
rgument, where [i, j] is an edge in the reflex transitive reduction and hom is\
 a group homomorphism from group i to group j,
gap> T := AsSemigroup(IsPartialPermSemigroup, gr4, [G1, G2, G3, G4, G5],
> [[2, -1, hom21],
>  [3, 1, hom31],
>  [4, 1, hom41],
>  [5, 2, hom52],
>  [5, 3, hom53]]);;
Error, the third argument must be a list of triples [i, j, hom] of length equa\
l to the number of edges in the reflexive transitive reduction of the second a\
rgument, where [i, j] is an edge in the reflex transitive reduction and hom is\
 a group homomorphism from group i to group j,
gap> T := AsSemigroup(IsPartialPermSemigroup, gr4, [G1, G2, G3, G4, G5],
> [[2, 1, sgn], [3, 1, hom31], [4, 1, hom41], [5, 2, hom52], [5, 3, hom53]]);;
Error, the third argument must be a list of triples [i, j, hom] of length equa\
l to the number of edges in the reflexive transitive reduction of the second a\
rgument, where [i, j] is an edge in the reflex transitive reduction and hom is\
 a group homomorphism from group i to group j,
gap> T := AsSemigroup(IsPartialPermSemigroup, gr4, [G1, G2, G3, G4, G5],
> [[2, 1, sgn], [3, 1, hom31], [4, 1, hom41], [5, 2, hom52], [4, 1, hom53]]);;
Error, the third argument must be a list of triples [i, j, hom] of length equa\
l to the number of edges in the reflexive transitive reduction of the second a\
rgument, where [i, j] is an edge in the reflex transitive reduction and hom is\
 a group homomorphism from group i to group j,
gap> T := AsSemigroup(IsPartialPermSemigroup, gr4, [G1, G2, G3, G4, G5],
> [[2, 1, sgn], [3, 1, hom31], [4, 1, hom41], [5, 2, hom52], [5, 2, hom53]]);;
Error, the third argument must be a list of triples [i, j, hom] of length equa\
l to the number of edges in the reflexive transitive reduction of the second a\
rgument, where [i, j] is an edge in the reflex transitive reduction and hom is\
 a group homomorphism from group i to group j,
gap> T := AsSemigroup(IsPartialPermSemigroup, gr4, [G1, G2, G3, G4, G5],
> [[2, 1, hom21], [3, 1, hom31], [4, 1, hom41], [5, 2, hom52], [5, 2, hom52]]);;
Error, the fourth argument must contain a triple [i, j, hom] for each edge [i,\
 j] in the reflexive transitive reduction of the second argument,

# MakeImmutable
gap> D := NullDigraph(IsMutableDigraph, 10);
<mutable empty digraph with 10 vertices>
gap> MakeImmutable(D);
<immutable empty digraph with 10 vertices>

#
gap> D := NullDigraph(10);
<immutable empty digraph with 10 vertices>
gap> if DIGRAPHS_IsGrapeLoaded() then
>   D := Graph(D);
>   if D <> rec(
>       adjacencies := [[]],
>       group := SymmetricGroup([1 .. 10]),
>       isGraph := true,
>       names := [1 .. 10],
>       order := 10,
>       representatives := [1],
>       schreierVector := [-1, 1, 1, 1, 1, 1, 1, 1, 1, 1]) then
>     Error();
>   fi;
>   DigraphCons(IsImmutableDigraph, D);
>   if Digraph(IsImmutableDigraph, D) <> NullDigraph(10) then
>     Error();
>   fi;
> fi;

# ViewString
gap> CycleDigraph(3);
<immutable cycle digraph with 3 vertices>
gap> ChainDigraph(3);
<immutable chain digraph with 3 vertices>
gap> CompleteDigraph(3);
<immutable complete digraph with 3 vertices>
gap> CompleteBipartiteDigraph(3, 2);
<immutable complete bipartite digraph with bicomponent sizes 3 and 2>
gap> D := Digraph([[1, 2], [2]]);;
gap> IsLatticeDigraph(D);;
gap> D;
<immutable lattice digraph with 2 vertices, 3 edges>
gap> D := Digraph([[1, 2], [2]]);;
gap> IsMeetSemilatticeDigraph(D);;
gap> D;
<immutable meet semilattice digraph with 2 vertices, 3 edges>
gap> D := Digraph([[1, 2], [2]]);;
gap> IsJoinSemilatticeDigraph(D);;
gap> D;
<immutable join semilattice digraph with 2 vertices, 3 edges>
gap> D := Digraph([[2], [3], [1]]);;
gap> IsStronglyConnectedDigraph(D);;
gap> D;
<immutable strongly connected digraph with 3 vertices, 3 edges>
gap> D := Digraph([[2, 3], [4], [4], []]);;
gap> IsBiconnectedDigraph(D);;
gap> D;
<immutable biconnected digraph with 4 vertices, 4 edges>
gap> D := Digraph([[2], [3], []]);;
gap> IsConnectedDigraph(D);;
gap> D;
<immutable connected digraph with 3 vertices, 2 edges>
gap> CompleteMultipartiteDigraph([3, 4, 5]);
<immutable complete multipartite digraph with 12 vertices, 94 edges>
gap> D := Digraph([[2], [3], []]);;
gap> IsBipartiteDigraph(D);;
gap> D;
<immutable bipartite digraph with bicomponent sizes 2 and 1>
gap> D := Digraph([[2], [3], [1]]);;
gap> IsVertexTransitive(D);;
gap> D;
<immutable vertex-transitive digraph with 3 vertices, 3 edges>
gap> IsEdgeTransitive(D);;
gap> D;
<immutable edge- and vertex-transitive digraph with 3 vertices, 3 edges>
gap> D := Digraph([[2], [3], [1]]);;
gap> IsEdgeTransitive(D);;
gap> D;
<immutable edge-transitive digraph with 3 vertices, 3 edges>
gap> D := Digraph([[2, 3], [1, 3], [1, 2]]);;
gap> IsOutRegularDigraph(D);;
gap> D;
<immutable out-regular digraph with 3 vertices, 6 edges>
gap> IsInRegularDigraph(D);;
gap> D;
<immutable regular digraph with 3 vertices, 6 edges>
gap> D := Digraph([[2, 3], [1, 3], [1, 2]]);;
gap> IsInRegularDigraph(D);;
gap> D;
<immutable in-regular digraph with 3 vertices, 6 edges>
gap> D := Digraph([[2], [3], []]);;
gap> IsAcyclicDigraph(D);;
gap> D;
<immutable acyclic digraph with 3 vertices, 2 edges>
gap> D := Digraph([[1, 2], [2]]);;
gap> IsPartialOrderDigraph(D);;
gap> D;
<immutable partial order digraph with 2 vertices, 3 edges>
gap> D := Digraph([[1, 2], [2]]);;
gap> IsPreorderDigraph(D);;
gap> D;
<immutable preorder digraph with 2 vertices, 3 edges>
gap> D := Digraph([[2], [1]]);;
gap> IsSymmetricDigraph(D);;
gap> D;
<immutable symmetric digraph with 2 vertices, 2 edges>
gap> D := Digraph([[1, 2], [2]]);;
gap> IsTransitiveDigraph(D);;
gap> D;
<immutable transitive digraph with 2 vertices, 3 edges>
gap> D := Digraph([[2], [1]]);;
gap> IsEulerianDigraph(D);;
gap> D;
<immutable Eulerian digraph with 2 vertices, 2 edges>
gap> IsHamiltonianDigraph(D);;
gap> D;
<immutable Eulerian and Hamiltonian digraph with 2 vertices, 2 edges>
gap> D := Digraph([[2], [1]]);;
gap> IsHamiltonianDigraph(D);;
gap> D;
<immutable Hamiltonian digraph with 2 vertices, 2 edges>
gap> D := Digraph([[2], [1, 3], [2]]);;
gap> IsSymmetricDigraph(D);;
gap> D;
<immutable symmetric digraph with 3 vertices, 4 edges>
gap> IsStronglyConnectedDigraph(D);
true
gap> D;
<immutable connected symmetric digraph with 3 vertices, 4 edges>

# String
gap> D := CycleDigraph(3);
<immutable cycle digraph with 3 vertices>
gap> String(D);
"CycleDigraph(3)"
gap> D := CycleDigraph(IsMutableDigraph, 16);
<mutable digraph with 16 vertices, 16 edges>
gap> DigraphAddVertex(D, 17);
<mutable digraph with 17 vertices, 16 edges>
gap> DigraphAddEdge(D, [17, 1]);
<mutable digraph with 17 vertices, 17 edges>
gap> String(D);
"DigraphFromDiSparse6String(IsMutableDigraph, \".Pn?_p_`abcdefghijklm\")"
gap> G := CompleteBipartiteDigraph(IsMutableDigraph, 5, 5);
<mutable digraph with 10 vertices, 50 edges>
gap> String(G);
"DigraphFromGraph6String(IsMutableDigraph, \"I?B~vrw}?\")"
gap> D := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> String(D);
"Digraph([  ])"
gap> D := CompleteDigraph(7);
<immutable complete digraph with 7 vertices>
gap> String(D);
"CompleteDigraph(7)"
gap> D := EvalString(
> "DigraphFromDigraph6String(\"&N~~nf~v~~~~u\\\\mvf~vvv~Zzv|vNxuxVw~|v~Lro\")"
> );
<immutable digraph with 15 vertices, 182 edges>
gap> String(D);
"DigraphFromDigraph6String(\"&N~~nf~v~~~~u\\\\mvf~vvv~Zzv|vNxuxVw~|v~Lro\")"

# Load the NAMED DIGRAPHS MAIN and NAMED DIGRAPHS TEST records.
# Check the entries match.
gap> DIGRAPHS_LoadNamedDigraphs();
gap> main := DIGRAPHS_NamedDigraphs;;
gap> DIGRAPHS_LoadNamedDigraphsTests();
gap> test := DIGRAPHS_NamedDigraphsTests;;
gap> Set(RecNames(main)) = Set(RecNames(test));
true

# NAMED DIGRAPHS MAIN:
# - ensure every name is lowercase with no spaces
# - ensure every value is a string
# if anything does not satisfy these conditions, goes in failed list.
gap> failed_names := [];;
gap> failed_values := [];;
gap> for name in RecNames(main) do
>      name2 := LowercaseString(name);;
>      RemoveCharacters(name2, " \n\t\r");;
>      if name <> name2 then
>        Add(failed_names, name);;
>      fi;
>      if not IsString(main.(name)) then
>        Add(failed_values, name);;
>      fi;
>    od;
gap> failed_names;
[  ]
gap> failed_values;
[  ]

# NAMED DIGRAPHS TEST:
# - ensure every value is a record
# - ensure every value has at least one component
# if any component doesn't satisfy these conditions, its name goes in "failed"
gap> failed := [];;
gap> for name in RecNames(test) do
>      if not IsRecord(test.(name)) then
>        Add(failed, name);;
>      else
>        if Length(RecNames(test.(name))) = 0 then
>          Add(failed, name);;
>        fi;
>      fi;
>    od;
gap> failed;
[  ]

# Named digraphs
gap> Digraph("The smallest digraph that cannot be described in 100 chars");
Error, named digraph <name> not found; see ListNamedDigraphs,
gap> D := Digraph("folkman");
<immutable digraph with 20 vertices, 80 edges>
gap> D = Digraph("F \n  Ol k\tMA\r\r n");
true
gap> Digraph("");
<immutable empty digraph with 0 vertices>

# Check attributes of first few digraphs (extreme/named.tst checks all).
# "failed" is a list of pairs [name, prop] where the digraph called "name"
# did not coincide with the test record on property "prop". The test is
# passed if this list remains empty. If it contains graphs, you should check
# those graphs for errors.
gap> m := Minimum(20, Length(RecNames(main)));;
gap> failed := [];;
>    for name in RecNames(main){[1 .. m]} do
>      D := Digraph(name);;
>      properties := test.(name);;
>      for prop in RecNames(properties) do
>        if ValueGlobal(prop)(D) <> properties.(prop) then
>          Add(failed, [name, prop]);;
>        fi;
>      od;
>    od;
gap> failed;
[  ]

# ListNamedDigraphs
gap> Length(RecNames(main))
>    = Length(ListNamedDigraphs(""));
true
gap> "folkman" in ListNamedDigraphs("F\n oL");
true
gap> ListNamedDigraphs("Surely no digraph has this name");
[  ]
gap> "diamond" in ListNamedDigraphs("mo", 1);
false
gap> "diamond" in ListNamedDigraphs("mond", 2);
true
gap> "petersen" in ListNamedDigraphs("et!er", 3);
true
gap> "petersen" in ListNamedDigraphs("et!er1413", 3);
false
gap> "brinkmann" in ListNamedDigraphs("man", 1000);
true

# OutNeighbours
gap> OutNeighbours(OutNeighbours);
Error, expected a digraph, not a function

# Random Connected Digraph
gap> for n in [1 .. 20] do
>   graph := RandomDigraph(IsConnectedDigraph, n, 0);
>   if DigraphNrEdges(graph) <> n - 1 then
>     Print("False");
>   fi;
> od;
gap> for n in [1 .. 20] do
>   graph := RandomDigraph(IsConnectedDigraph, n, 1);
>   if DigraphNrEdges(graph) <> (n * n) then
>     Print("False");
>   fi;
> od;
gap> for p in [1 .. 9] do
>   graph := RandomDigraph(IsConnectedDigraph, 10, Float(p) / 10);
>   if (not IsConnectedDigraph(graph)) or (IsMultiDigraph(graph)) then
>     Print("False");
>   fi;
> od;
gap> graph := RandomDigraph(IsConnectedDigraph, 10);;
>   if not IsConnectedDigraph(graph) then
>     Print("False");
>   fi;

# Random Strongly Connected Digraph
gap> for n in [1 .. 20] do
>   c := RandomDigraph(IsConnectedDigraph, n, 0);
>   s := RandomDigraph(IsStronglyConnectedDigraph, n, 0);
>   if DigraphNrEdges(c) > DigraphNrEdges(s) then
>     Print("False");
>   fi;
> od;

# Random Symmetric Digraph
gap> for n in [1 .. 20] do
>   graph := RandomDigraph(IsSymmetricDigraph, n, 0);
>   if DigraphNrEdges(graph) <> 0 then
>     Print("False");
>   fi;
> od;
gap> for n in [1 .. 20] do
>   graph := RandomDigraph(IsSymmetricDigraph, n, 1);
>   if DigraphNrEdges(graph) <> (n * n) then
>     Print("False");
>   fi;
> od;
gap> for p in [1 .. 9] do
>   graph := RandomDigraph(IsSymmetricDigraph, 10, Float(p) / 10);
>   if (not IsSymmetricDigraph(graph)) or (IsMultiDigraph(graph)) then
>     Print("False");
>   fi;
> od;
gap> graph := RandomDigraph(IsSymmetricDigraph, 10);;
>   if not IsSymmetricDigraph(graph) then
>     Print("False");
>   fi;

# Random Hamiltonian Digraph
gap> graph := RandomDigraph(IsHamiltonianDigraph, 1, 0);;
>   if DigraphNrEdges(graph) <> 0 then
>     Print("False");
>   fi;
gap> graph := RandomDigraph(IsHamiltonianDigraph, 1, 1);;
>   if DigraphNrEdges(graph) <> 1 then
>     Print("False");
>   fi;
gap> for n in [2 .. 20] do
>   graph := RandomDigraph(IsHamiltonianDigraph, n, 0);
>   if DigraphNrEdges(graph) <> n then
>     Print("False");
>   fi;
> od;
gap> for n in [1 .. 20] do
>   graph := RandomDigraph(IsHamiltonianDigraph, n, 1);
>   if DigraphNrEdges(graph) <> (n * n) then
>     Print("False");
>   fi;
> od;
gap> for p in [1 .. 9] do
>   graph := RandomDigraph(IsHamiltonianDigraph, 10, Float(p) / 10);
>   if (not IsHamiltonianDigraph(graph)) or (IsMultiDigraph(graph)) then
>     Print("False");
>   fi;
> od;
gap> graph := RandomDigraph(IsHamiltonianDigraph, 10);;
>   if not IsHamiltonianDigraph(graph) then
>     Print("False");
>   fi;

# Random Acyclic Digraph
gap> for n in [1 .. 20] do
>   graph := RandomDigraph(IsAcyclicDigraph, n, 0);
>   if DigraphNrEdges(graph) <> 0 then
>     Print("False");
>   fi;
> od;
gap> for n in [1 .. 20] do
>   graph := RandomDigraph(IsAcyclicDigraph, n, 1);
>   if DigraphNrEdges(graph) <> (n * (n - 1)) / 2 then
>     Print("False");
>   fi;
> od;
gap> for p in [1 .. 9] do
>   graph := RandomDigraph(IsAcyclicDigraph, 10, Float(p) / 10);
>   if (not IsAcyclicDigraph(graph)) or (IsMultiDigraph(graph)) then
>     Print("False");
>   fi;
> od;
gap> graph := RandomDigraph(IsAcyclicDigraph, 10);;
>   if not IsAcyclicDigraph(graph) then
>     Print("False");
>   fi;

# Random Eulerian Digraph
gap> graph := RandomDigraph(IsEulerianDigraph, 1, 0);;
>   if DigraphNrEdges(graph) <> 0 then
>     Print("False");
>   fi;
gap> graph := RandomDigraph(IsEulerianDigraph, 1, 1);;
>   if DigraphNrEdges(graph) <> 1 then
>     Print("False");
>   fi;
gap> for n in [2 .. 20] do
>   graph := RandomDigraph(IsEulerianDigraph, n, 0);
>   if DigraphNrEdges(graph) <> n then
>     Print("False");
>   fi;
> od;
gap> for p in [1 .. 9] do
>   graph := RandomDigraph(IsEulerianDigraph, 10, Float(p) / 10);
>   if (not IsEulerianDigraph(graph)) or (IsMultiDigraph(graph)) then
>     Print("False");
>   fi;
> od;
gap> graph := RandomDigraph(IsEulerianDigraph, 10);;
>   if not IsEulerianDigraph(graph) then
>     Print("False");
>   fi;

#  DIGRAPHS_UnbindVariables
gap> Unbind(D);
gap> Unbind(D1);
gap> Unbind(D2);
gap> Unbind(G);
gap> Unbind(G1);
gap> Unbind(G2);
gap> Unbind(G3);
gap> Unbind(G4);
gap> Unbind(G5);
gap> Unbind(S);
gap> Unbind(T);
gap> Unbind(U);
gap> Unbind(adj);
gap> Unbind(b);
gap> Unbind(bin);
gap> Unbind(d);
gap> Unbind(di);
gap> Unbind(digraph);
gap> Unbind(divides);
gap> Unbind(elms);
gap> Unbind(eq);
gap> Unbind(error);
gap> Unbind(f);
gap> Unbind(failed);
gap> Unbind(foo);
gap> Unbind(g);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(gr3);
gap> Unbind(gr4);
gap> Unbind(gr5);
gap> Unbind(graph);
gap> Unbind(graph1);
gap> Unbind(graph2);
gap> Unbind(grnc);
gap> Unbind(h);
gap> Unbind(hom13);
gap> Unbind(hom21);
gap> Unbind(hom23);
gap> Unbind(hom31);
gap> Unbind(hom41);
gap> Unbind(hom42);
gap> Unbind(hom52);
gap> Unbind(hom53);
gap> Unbind(i);
gap> Unbind(im);
gap> Unbind(inn);
gap> Unbind(iso);
gap> Unbind(j);
gap> Unbind(list);
gap> Unbind(m);
gap> Unbind(main);
gap> Unbind(mat);
gap> Unbind(n);
gap> Unbind(name);
gap> Unbind(names);
gap> Unbind(new);
gap> Unbind(p);
gap> Unbind(prop);
gap> Unbind(r);
gap> Unbind(r1);
gap> Unbind(r2);
gap> Unbind(record);
gap> Unbind(rel1);
gap> Unbind(rel2);
gap> Unbind(rel3);
gap> Unbind(s);
gap> Unbind(sgn);
gap> Unbind(temp);
gap> Unbind(test);
gap> Unbind(v);
gap> Unbind(x);
gap> Unbind(y);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/digraph.tst", 0);
