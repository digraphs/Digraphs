#############################################################################
##
#W  testinstall.tst
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: testinstall.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#  Conversion to and from GRAPE graphs
gap> gr := Digraph(
> [[8], [4, 5, 6, 8, 9], [2, 4, 5, 7, 10], [9],
> [1, 4, 6, 7, 9], [2, 3, 6, 7, 10], [3, 4, 5, 8, 9],
> [3, 4, 9, 10], [1, 2, 3, 5, 6, 9, 10], [2, 4, 5, 6, 9]]);
<immutable digraph with 10 vertices, 43 edges>
gap> OutNeighbours(gr);
[ [ 8 ], [ 4, 5, 6, 8, 9 ], [ 2, 4, 5, 7, 10 ], [ 9 ], [ 1, 4, 6, 7, 9 ], 
  [ 2, 3, 6, 7, 10 ], [ 3, 4, 5, 8, 9 ], [ 3, 4, 9, 10 ], 
  [ 1, 2, 3, 5, 6, 9, 10 ], [ 2, 4, 5, 6, 9 ] ]
gap> not DIGRAPHS_IsGrapeLoaded()
> or (DIGRAPHS_IsGrapeLoaded() and Digraph(Graph(gr)) = gr);
true
gap> not DIGRAPHS_IsGrapeLoaded()
> or (DIGRAPHS_IsGrapeLoaded() and Graph(Digraph(Graph(gr))).adjacencies =
>     Graph(gr).adjacencies);
true
gap> adj := [
> [17, 19], [17, 20], [17, 18], [17, 20], [17, 18], [18, 19],
> [18, 20], [17, 19], [19, 20], [17, 20], [19, 20], [18, 19],
> [19, 20], [17, 19], [18, 20], [18, 20],
> [1, 2, 3, 4, 5, 8, 10, 14], [3, 5, 6, 7, 12, 15, 16],
> [1, 6, 8, 9, 11, 12, 13, 14], [2, 4, 7, 9, 10, 11, 13, 15, 16]];;
gap> func := function(x, y) return y in adj[x]; end;
function( x, y ) ... end
gap> not DIGRAPHS_IsGrapeLoaded() or
> (DIGRAPHS_IsGrapeLoaded() and
>  Digraph(Graph(Group(()), [1 .. 20], OnPoints, func, true)) = Digraph(adj));
true

#  IsAcyclicDigraph
gap> gr := Digraph([
>  [1, 2, 4, 10], [3, 15], [3, 15], [1, 3, 7, 8, 9, 11, 12, 13],
>  [4, 8], [1, 2, 4, 5, 6, 7, 8, 10, 14, 15], [3, 4, 6, 11, 13, 15],
>  [3, 5, 6, 7, 8, 9, 10, 15], [2, 5, 6, 7, 8, 9, 10, 11, 12],
>  [2, 3, 10, 11, 14], [3, 5, 14, 15], [7, 9, 10, 14, 15],
>  [1, 4, 7, 8, 10, 14, 15], [1, 2, 4, 7, 13, 14, 15],
>  [1, 2, 3, 9, 10, 11, 12, 13, 14, 15]]);
<immutable digraph with 15 vertices, 89 edges>
gap> IsMultiDigraph(gr);
false
gap> IsAcyclicDigraph(gr);
false
gap> r := rec(DigraphNrVertices := 10000,
>             DigraphSource := [],
>             DigraphRange := []);;
gap> for i in [1 .. 9999] do
>    Add(r.DigraphSource, i);
>    Add(r.DigraphRange, i + 1);
>  od;
gap> Add(r.DigraphSource, 10000);; Add(r.DigraphRange, 1);;
gap> gr := Digraph(r);
<immutable digraph with 10000 vertices, 10000 edges>
gap> IsAcyclicDigraph(gr);
false
gap> gr := DigraphRemoveEdge(gr, 10000, 1);
<immutable digraph with 10000 vertices, 9999 edges>
gap> IsAcyclicDigraph(gr);
true
gap> gr := Digraph([[2, 3], [4, 5], [5, 6], [], [], [], [3]]);
<immutable digraph with 7 vertices, 7 edges>
gap> IsDigraph(gr);
true

#  OutNeighbours
# Check that it can handle non-plists in the source and range
gap> gr := Digraph(rec(DigraphNrVertices := 1000,
>                      DigraphSource := [1 .. 1000],
>                      DigraphRange := Concatenation([2 .. 1000], [1])));;
gap> OutNeighbours(gr);;

#  IsMultiDigraph: for an empty digraph
gap> d := Digraph(rec(DigraphVertices := [1 .. 5], 
>                     DigraphRange := [], 
>                     DigraphSource := []));
<immutable empty digraph with 5 vertices>
gap> IsMultiDigraph(d);
false

#  DigraphFromSparse6String
gap> DigraphFromSparse6String(":Fa@x^");
<immutable symmetric digraph with 7 vertices, 8 edges>

#  (In/Out)Neighbours and (In/Out)NeighboursOfVertex and (In/Out)DegreeOfVertex
gap> gr := Digraph([[4], [2, 2], [2, 3, 1, 4], [1]]);
<immutable multidigraph with 4 vertices, 8 edges>
gap> InDegreeOfVertex(gr, 2);
3
gap> InNeighboursOfVertex(gr, 2);
[ 2, 2, 3 ]
gap> InNeighbours(gr);
[ [ 3, 4 ], [ 2, 2, 3 ], [ 3 ], [ 1, 3 ] ]
gap> gr := Digraph(rec(DigraphNrVertices := 10, 
>                      DigraphSource := [1, 1, 2, 3, 3, 3],
>                      DigraphRange := [3, 1, 1, 4, 4, 1]));
<immutable multidigraph with 10 vertices, 6 edges>
gap> InNeighboursOfVertex(gr, 5);
[  ]
gap> InDegreeOfVertex(gr, 5);
0
gap> InNeighbours(gr);
[ [ 1, 2, 3 ], [  ], [ 1 ], [ 3, 3 ], [  ], [  ], [  ], [  ], [  ], [  ] ]
gap> InDegreeOfVertex(gr, 1);
3
gap> OutDegreeOfVertex(gr, 3);
3
gap> OutNeighboursOfVertex(gr, 3);
[ 4, 4, 1 ]
gap> OutNeighbours(gr);
[ [ 3, 1 ], [ 1 ], [ 4, 4, 1 ], [  ], [  ], [  ], [  ], [  ], [  ], [  ] ]

# DigraphInEdges and DigraphOutEdges for a vertex
gap> gr := Digraph([[5, 5, 1, 5], [], [], [2, 3, 1], [4]]);
<immutable multidigraph with 5 vertices, 8 edges>
gap> DigraphInEdges(gr, 5);
[ [ 1, 5 ], [ 1, 5 ], [ 1, 5 ] ]
gap> DigraphOutEdges(gr, 2);
[  ]
gap> DigraphOutEdges(gr, 4);
[ [ 4, 2 ], [ 4, 3 ], [ 4, 1 ] ]

#  DigraphPeriod and IsAperiodicDigraph
gap> gr := Digraph([[2], [3], [4], [5], [1], [7], [6]]);
<immutable digraph with 7 vertices, 7 edges>
gap> DigraphPeriod(gr);
1
gap> IsAperiodicDigraph(gr);
true
gap> gr := Digraph([[2], [3], [4], [5], [6], [1]]);
<immutable digraph with 6 vertices, 6 edges>
gap> DigraphPeriod(gr);
6
gap> IsAperiodicDigraph(gr);
false

#  IsDigraphEdge
gap> gr := Digraph(rec(DigraphNrVertices := 5, 
>                      DigraphSource := [1, 2, 3, 4, 5],
>                      DigraphRange := [2, 3, 4, 5, 1]));
<immutable digraph with 5 vertices, 5 edges>
gap> IsDigraphEdge(gr, [1, 2]);
true
gap> IsDigraphEdge(gr, [2, 2]);
false

#  DigraphReverseEdge and DigraphEdges

#
gap> gr := Digraph([[2], [3, 5], [4], [5], [1, 2]]);
<immutable digraph with 5 vertices, 7 edges>
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 2, 3 ], [ 2, 5 ], [ 3, 4 ], [ 4, 5 ], [ 5, 1 ], [ 5, 2 ] ]
gap> gr2 := DigraphReverseEdge(gr, [2, 3]);
<immutable digraph with 5 vertices, 7 edges>
gap> DigraphEdges(gr2);
[ [ 1, 2 ], [ 2, 5 ], [ 3, 4 ], [ 3, 2 ], [ 4, 5 ], [ 5, 1 ], [ 5, 2 ] ]

#
gap> gr := Digraph([[1, 2, 3], [3, 5], [4], [5], [1, 2], [5, 7], [6]]);
<immutable digraph with 7 vertices, 12 edges>
gap> gr2 := DigraphReverseEdge(gr, [1, 1]);
<immutable digraph with 7 vertices, 12 edges>
gap> gr = gr2;
true
gap> gr2 := DigraphReverseEdge(gr, 1, 2);
<immutable digraph with 7 vertices, 12 edges>

#  DigraphTopologicalSort
gap> gr := Digraph([[2, 3], [3], [], [5, 6], [6], []]);
<immutable digraph with 6 vertices, 6 edges>
gap> topo := DigraphTopologicalSort(gr);
[ 3, 2, 1, 6, 5, 4 ]
gap> p := Permutation(Transformation(topo), topo);
(1,3)(4,6)
gap> gr1 := OnDigraphs(gr, p);;
gap> DigraphTopologicalSort(gr1) = DigraphVertices(gr1);
true
gap> gr := Digraph([[], [3], [], [5], [], [2, 3, 7, 1], [1], [2, 3, 4, 5]]);
<immutable digraph with 8 vertices, 11 edges>
gap> topo := DigraphTopologicalSort(gr);
[ 1, 3, 2, 5, 4, 7, 6, 8 ]
gap> p := Permutation(Transformation(topo), topo);
(2,3)(4,5)(6,7)
gap> gr1 := OnDigraphs(gr, p ^ -1);;
gap> DigraphTopologicalSort(gr1) = DigraphVertices(gr1);
true

#  DIGRAPH_IN_OUT_NBS: for a list containing ranges
# A segfault was caused by assuming that an element of OutNeighbours was a
# PLIST. This is solved by using PLAIN_LIST on each entry of OutNeighbours.
gap> gr := Digraph(List([1 .. 5], x -> [1 .. 5]));;
gap> out := OutNeighbours(gr);
[ [ 1 .. 5 ], [ 1 .. 5 ], [ 1 .. 5 ], [ 1 .. 5 ], [ 1 .. 5 ] ]
gap> IsMultiDigraph(gr);
false
gap> out;
[ [ 1, 2, 3, 4, 5 ], [ 1, 2, 3, 4, 5 ], [ 1, 2, 3, 4, 5 ], [ 1, 2, 3, 4, 5 ], 
  [ 1, 2, 3, 4, 5 ] ]
gap> InNeighbours(gr) = out;
true

#  Issue 13: DigraphAllSimpleCircuits, reported by JDM
gap> gr := Digraph([[3], [4], [5], [1, 5], [1, 2]]);
<immutable digraph with 5 vertices, 7 edges>
gap> DigraphAllSimpleCircuits(gr);
[ [ 1, 3, 5 ], [ 1, 3, 5, 2, 4 ], [ 5, 2, 4 ] ]

#  DigraphMaximalCliquesReps was returning too few results, since the choice
# of a pivot vertex was not necessarily valid when the stabilizer was
# non-trivial
gap> gr := DigraphFromGraph6String("L~~~ySrJ[N{NT^");
<immutable symmetric digraph with 13 vertices, 108 edges>
gap> gr = MaximalSymmetricSubdigraphWithoutLoops(gr);
true
gap> DigraphMaximalCliquesReps(gr);
[ [ 1, 2, 3, 4, 5, 6, 7 ], [ 1, 2, 3, 12 ], [ 2, 8, 12, 13 ], [ 4, 9, 13 ], 
  [ 8, 9, 10, 11, 12, 13 ] ]
gap> gr := DigraphFromGraph6String("I~~wzfJhw");
<immutable symmetric digraph with 10 vertices, 66 edges>
gap> gr = MaximalSymmetricSubdigraphWithoutLoops(gr);
true
gap> DigraphMaximalCliquesReps(gr);
[ [ 1, 2, 3, 4, 5, 6 ], [ 1, 2, 5, 9 ], [ 1, 9, 10 ], [ 7, 8, 9, 10 ] ]

#  DigraphClosure
gap> gr := CompleteDigraph(7);;
gap> gr2 := DigraphClosure(gr, 7);;
gap> gr = gr2;
true
gap> gr := DigraphRemoveEdge(gr, [1, 2]);;
gap> gr := DigraphRemoveEdges(gr, [[1, 2], [2, 1]]);;
gap> DigraphNrEdges(gr);
40
gap> DigraphNrAdjacencies(gr);
20
gap> gr2 := DigraphClosure(gr, 7);;
gap> DigraphNrEdges(gr2);
42
gap> DigraphNrAdjacencies(gr2);
21

#  Fix seg fault cause by wrong handling of no edges in
# FuncDIGRAPH_SOURCE_RANGE
gap> gr := Digraph([[]]);
<immutable empty digraph with 1 vertex>
gap> DigraphSource(gr);
[  ]
gap> DigraphRange(gr);
[  ]

#  Issue 17: Bug in OnDigraphs for a digraph and a transformation
gap> d := Digraph([[2], [3], [1, 1]]);
<immutable multidigraph with 3 vertices, 4 edges>
gap> OutNeighbours(OnDigraphs(d, PermList([2, 3, 1])));
[ [ 2, 2 ], [ 3 ], [ 1 ] ]
gap> OutNeighbours(OnDigraphs(d, Transformation([2, 3, 1])));
[ [ 2, 2 ], [ 3 ], [ 1 ] ]

#  Issue 42: Bug in AsDigraph for a transformation and an integer
gap> f := Transformation([7, 10, 10, 1, 7, 9, 10, 4, 2, 3]);
Transformation( [ 7, 10, 10, 1, 7, 9, 10, 4, 2, 3 ] )
gap> AsDigraph(f);
<immutable functional digraph with 10 vertices>
gap> AsDigraph(f, 4);
fail

# Issue 52: Bug in FuncIS_ANTISYMMETRIC_DIGRAPH causing seg fault
gap> gr := Digraph([[1], [2], [1 .. 3]]);;
gap> IsAntisymmetricDigraph(gr);
true

#  Issue 55: Bug in FuncDIGRAPH_TOPO_SORT
gap> gr := Digraph([[1 .. 4], [2, 4], [3, 4], [4]]);
<immutable digraph with 4 vertices, 9 edges>
gap> DigraphTopologicalSort(gr);
[ 4, 2, 3, 1 ]

#  Issue 81: Bug in Digraph for a malformed list of out-neighbours
gap> gr := Digraph([[1],, [2]]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DigraphCons' on 2 arguments
gap> gr := Digraph([[1], 2, [2]]);
Error, the argument <list> must be a list of lists of positive integers not ex\
ceeding the length of the argument,

#  Symmetric closure of a digraph with no vertices
gap> gr := EmptyDigraph(0);;
gap> DigraphSymmetricClosure(gr);
<immutable empty digraph with 0 vertices>

# Issue 114: Bug in NautyTracesInterface for graphs with 0 vertices
gap> not DIGRAPHS_NautyAvailable or 
> NautyAutomorphismGroup(NullDigraph(0)) = Group(());
true
gap> not DIGRAPHS_NautyAvailable or 
> NautyAutomorphismGroup(NullDigraph(0), []) = Group(());
true
gap> not DIGRAPHS_NautyAvailable or 
> NautyCanonicalLabelling(NullDigraph(0)) = ();
true
gap> not DIGRAPHS_NautyAvailable or 
> NautyCanonicalLabelling(NullDigraph(0), []) = ();
true

# Issue 158: Digraph6 file format incompatibility (with nauty)
gap> SortedList(DigraphEdges(DigraphFromDigraph6String("&DI?AO?")) - 1);
[ [ 0, 2 ], [ 0, 4 ], [ 3, 1 ], [ 3, 4 ] ]
gap> str := "&O?????C??O?@??C??O?@??C??O?@??C??O?@??C??o??";;
gap> gr := DigraphFromDigraph6String(str);
<immutable digraph with 16 vertices, 15 edges>
gap> str = Digraph6String(gr);
true

# MakeImmutable
gap> D := NullDigraph(IsMutableDigraph, 10);
<mutable empty digraph with 10 vertices>
gap> MakeImmutable(D);
<immutable empty digraph with 10 vertices>

# Issue 272: ViewString for known non-complete digraphs
gap> D := Digraph([[2], []]);;
gap> IsCompleteDigraph(D);
false
gap> D;
<immutable digraph with 2 vertices, 1 edge>

# Issue 276: ViewString for mutable empty digraphs
gap> D := EmptyDigraph(IsMutableDigraph, 3);
<mutable empty digraph with 3 vertices>
gap> IsAcyclicDigraph(D);
true
gap> DigraphDisjointUnion(D, CycleDigraph(IsMutableDigraph, 3));
<mutable digraph with 6 vertices, 3 edges>
gap> IsAcyclicDigraph(D);
false
gap> D := EmptyDigraph(IsMutableDigraph, 3);
<mutable empty digraph with 3 vertices>
gap> IsAcyclicDigraph(D);
true
gap> DigraphDisjointUnion(D, CycleDigraph(IsImmutableDigraph, 3));
<mutable digraph with 6 vertices, 3 edges>
gap> IsAcyclicDigraph(D);
false

# Issue 276: Correct mutability for DigraphDisjointUnion
gap> D := EmptyDigraph(IsMutableDigraph, 3);
<mutable empty digraph with 3 vertices>
gap> DigraphDisjointUnion(D, CycleDigraph(3));
<mutable digraph with 6 vertices, 3 edges>
gap> IsMutable(D!.OutNeighbours);
true
gap> ForAll(D!.OutNeighbours, IsMutable);
true

# Issue 284: HomomorphismDigraphsFinder not finding any homomorphisms
gap> HomomorphismDigraphsFinder(NullDigraph(1), NullDigraph(100), fail, [], infinity,
> fail, 2, [1 .. 100], [], fail, fail);
[ IdentityTransformation ]
gap> HomomorphismDigraphsFinder(NullDigraph(1), NullDigraph(100), fail, [], infinity,
> fail, 2, [1 .. 100], [], fail, fail);
[ IdentityTransformation ]
gap> HomomorphismDigraphsFinder(NullDigraph(2), NullDigraph(2), fail, [], infinity,  
> fail, 2, [1, 2], [], fail, fail); 
[ IdentityTransformation ]
gap> HomomorphismDigraphsFinder(NullDigraph(1), NullDigraph(100), fail, [], infinity,
> fail, 2, [1 .. 100], [], fail, fail);
[ IdentityTransformation ]

# Issue 367: bug in the homomorphisms finder c code
gap> D := Digraph([[2, 2], []]);;
gap> GeneratorsOfEndomorphismMonoid(D);
Error, expected a digraph without multiple edges!
gap> D := Digraph([[2, 2, 2, 2, 2], []]);;
gap> GeneratorsOfEndomorphismMonoid(D);
Error, expected a digraph without multiple edges!

# Issue 517: bug in String for digraphs satisfying IsChainDigraph or
# IsCycleDigraph but not being equal to ChainDigraph or CycleDigraph.
gap> D := ChainDigraph(4);
<immutable chain digraph with 4 vertices>
gap> D := DigraphReverse(D);
<immutable digraph with 4 vertices, 3 edges>
gap> IsChainDigraph(D);
true
gap> D = ChainDigraph(4);
false
gap> String(D);
"DigraphFromDigraph6String(\"&CACG\")"
gap> String(ChainDigraph(4));
"ChainDigraph(4)"
gap> D := CycleDigraph(4);
<immutable cycle digraph with 4 vertices>
gap> D := DigraphReverse(D);
<immutable digraph with 4 vertices, 4 edges>
gap> IsCycleDigraph(D);
true
gap> D = CycleDigraph(4);
false
gap> String(D);
"DigraphFromDigraph6String(\"&CECG\")"
gap> String(CycleDigraph(4));
"CycleDigraph(4)"

# Edge-weighted digraphs
gap> d := EdgeWeightedDigraph([[2], [1]], [[5], [10]]);
<immutable digraph with 2 vertices, 2 edges>
gap> EdgeWeights(d);
[ [ 5 ], [ 10 ] ]
gap> EdgeWeightedDigraphTotalWeight(d);
15
gap> EdgeWeightedDigraphMinimumSpanningTree(d);
<immutable digraph with 2 vertices, 1 edge>

# Issue 617: bug in DigraphRemoveEdge, wasn't removing edge labels
gap> D := DigraphByEdges(IsMutableDigraph, [[1, 2], [2, 3], [3, 4], [4, 1], [1, 1]]);;
gap> DigraphEdgeLabels(D);
[ [ 1, 1 ], [ 1 ], [ 1 ], [ 1 ] ]
gap> DigraphRemoveEdge(D, [1, 2]);;
gap> DigraphEdgeLabels(D);
[ [ 1 ], [ 1 ], [ 1 ], [ 1 ] ]
gap> D := DigraphByEdges(IsMutableDigraph, [[1, 2], [2, 3], [3, 4], [4, 1], [1, 1]]);;
gap> SetDigraphEdgeLabel(D, 1, 2, "test");
gap> DigraphRemoveEdge(D, 1, 2);;
gap> DigraphEdgeLabels(D);
[ [ 1 ], [ 1 ], [ 1 ], [ 1 ] ]

# DigraphContractEdge
gap> D := DigraphByEdges(IsMutableDigraph, [[1, 2], [2, 1]]);
<mutable digraph with 2 vertices, 2 edges>
gap> DigraphContractEdge(D, 2, 1);;
gap> DigraphEdges(D);
[  ]
gap> D := DigraphByEdges([[1, 2], [2, 1], [2, 3]]);
<immutable digraph with 3 vertices, 3 edges>
gap> C := DigraphContractEdge(D, 2, 1);
<immutable digraph with 2 vertices, 1 edge>
gap> DigraphEdges(C);
[ [ 2, 1 ] ]

#  DIGRAPHS_UnbindVariables
gap> Unbind(C);
gap> Unbind(D);
gap> Unbind(adj);
gap> Unbind(d);
gap> Unbind(f);
gap> Unbind(func);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(i);
gap> Unbind(out);
gap> Unbind(p);
gap> Unbind(r);
gap> Unbind(str);
gap> Unbind(topo);

#E#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: testinstall.tst", 0);
