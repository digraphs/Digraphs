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

#T# Conversion to and from GRAPE graphs
gap> gr := Digraph(
> [[8], [4, 5, 6, 8, 9], [2, 4, 5, 7, 10], [9],
> [1, 4, 6, 7, 9], [2, 3, 6, 7, 10], [3, 4, 5, 8, 9],
> [3, 4, 9, 10], [1, 2, 3, 5, 6, 9, 10], [2, 4, 5, 6, 9]]);
<digraph with 10 vertices, 43 edges>
gap> OutNeighbours(gr);
[ [ 8 ], [ 4, 5, 6, 8, 9 ], [ 2, 4, 5, 7, 10 ], [ 9 ], [ 1, 4, 6, 7, 9 ], 
  [ 2, 3, 6, 7, 10 ], [ 3, 4, 5, 8, 9 ], [ 3, 4, 9, 10 ], 
  [ 1, 2, 3, 5, 6, 9, 10 ], [ 2, 4, 5, 6, 9 ] ]
gap> not DIGRAPHS_IsGrapeLoaded
> or (DIGRAPHS_IsGrapeLoaded and Digraph(Graph(gr)) = gr);
true
gap> not DIGRAPHS_IsGrapeLoaded
> or (DIGRAPHS_IsGrapeLoaded and Graph(Digraph(Graph(gr))).adjacencies =
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
gap> not DIGRAPHS_IsGrapeLoaded or
> (DIGRAPHS_IsGrapeLoaded and
>  Digraph(Graph(Group(()), [1 .. 20], OnPoints, func, true)) = Digraph(adj));
true

#T# IsAcyclicDigraph
gap> gr := Digraph([
>  [1, 2, 4, 10], [3, 15], [3, 15], [1, 3, 7, 8, 9, 11, 12, 13],
>  [4, 8], [1, 2, 4, 5, 6, 7, 8, 10, 14, 15], [3, 4, 6, 11, 13, 15],
>  [3, 5, 6, 7, 8, 9, 10, 15], [2, 5, 6, 7, 8, 9, 10, 11, 12],
>  [2, 3, 10, 11, 14], [3, 5, 14, 15], [7, 9, 10, 14, 15],
>  [1, 4, 7, 8, 10, 14, 15], [1, 2, 4, 7, 13, 14, 15],
>  [1, 2, 3, 9, 10, 11, 12, 13, 14, 15]]);
<digraph with 15 vertices, 89 edges>
gap> IsMultiDigraph(gr);
false
gap> IsAcyclicDigraph(gr);
false
gap> r := rec(vertices := [1 .. 10000], source := [], range := []);;
gap> for i in [1 .. 9999] do
>    Add(r.source, i);
>    Add(r.range, i + 1);
>  od;
gap> Add(r.source, 10000);; Add(r.range, 1);;
gap> gr := Digraph(r);
<digraph with 10000 vertices, 10000 edges>
gap> IsAcyclicDigraph(gr);
false
gap> gr := DigraphRemoveEdges(gr, [10000]);
<digraph with 10000 vertices, 9999 edges>
gap> IsAcyclicDigraph(gr);
true
gap> gr := Digraph([[2, 3], [4, 5], [5, 6], [], [], [], [3]]);
<digraph with 7 vertices, 7 edges>
gap> IsDigraph(gr);
true

#T# OutNeighbours
# Check that it can handle non-plists in the source and range
gap> gr := Digraph(rec(nrvertices := 1000,
>                      source := [1 .. 1000],
>                      range := Concatenation([2 .. 1000], [1])));;
gap> OutNeighbours(gr);;

#T# IsMultiDigraph: for an empty digraph
gap> d := Digraph(rec(vertices := [1 .. 5], range := [], source := []));
<digraph with 5 vertices, 0 edges>
gap> IsMultiDigraph(d);
false

#T# DigraphFromSparse6String
gap> DigraphFromSparse6String(":Fa@x^");
<digraph with 7 vertices, 8 edges>

#T# (In/Out)Neighbours and (In/Out)NeighboursOfVertex and (In/Out)DegreeOfVertex
gap> gr := Digraph([[4], [2, 2], [2, 3, 1, 4], [1]]);
<multidigraph with 4 vertices, 8 edges>
gap> InDegreeOfVertex(gr, 2);
3
gap> InNeighboursOfVertex(gr, 2);
[ 2, 2, 3 ]
gap> InNeighbours(gr);
[ [ 3, 4 ], [ 2, 2, 3 ], [ 3 ], [ 1, 3 ] ]
gap> gr := Digraph(rec(nrvertices := 10, source := [1, 1, 2, 3, 3, 3],
> range := [3, 1, 1, 4, 4, 1]));
<multidigraph with 10 vertices, 6 edges>
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
<multidigraph with 5 vertices, 8 edges>
gap> DigraphInEdges(gr, 5);
[ [ 1, 5 ], [ 1, 5 ], [ 1, 5 ] ]
gap> DigraphOutEdges(gr, 2);
[  ]
gap> DigraphOutEdges(gr, 4);
[ [ 4, 2 ], [ 4, 3 ], [ 4, 1 ] ]

#T# DigraphPeriod and IsAperiodicDigraph
gap> gr := Digraph([[2], [3], [4], [5], [1], [7], [6]]);
<digraph with 7 vertices, 7 edges>
gap> DigraphPeriod(gr);
1
gap> IsAperiodicDigraph(gr);
true
gap> gr := Digraph([[2], [3], [4], [5], [6], [1]]);
<digraph with 6 vertices, 6 edges>
gap> DigraphPeriod(gr);
6
gap> IsAperiodicDigraph(gr);
false

#T# IsDigraphEdge
gap> gr := Digraph(rec(nrvertices := 5, source := [1, 2, 3, 4, 5],
> range := [2, 3, 4, 5, 1]));
<digraph with 5 vertices, 5 edges>
gap> IsDigraphEdge(gr, [1, 2]);
true
gap> IsDigraphEdge(gr, [2, 2]);
false

#T# DigraphReverseEdge and DigraphEdges

#
gap> gr := Digraph([[2], [3, 5], [4], [5], [1, 2]]);
<digraph with 5 vertices, 7 edges>
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 2, 3 ], [ 2, 5 ], [ 3, 4 ], [ 4, 5 ], [ 5, 1 ], [ 5, 2 ] ]
gap> gr2 := DigraphReverseEdge(gr, [2, 3]);
<digraph with 5 vertices, 7 edges>
gap> DigraphEdges(gr2);
[ [ 1, 2 ], [ 2, 5 ], [ 3, 4 ], [ 3, 2 ], [ 4, 5 ], [ 5, 1 ], [ 5, 2 ] ]

#
gap> gr := Digraph([[1, 2, 3], [3, 5], [4], [5], [1, 2], [5, 7], [6]]);
<digraph with 7 vertices, 12 edges>
gap> gr2 := DigraphReverseEdge(gr, [1, 1]);
<digraph with 7 vertices, 12 edges>
gap> gr = gr2;
true
gap> gr2 := DigraphReverseEdge(gr, 2);
<digraph with 7 vertices, 12 edges>

#T# DigraphTopologicalSort
gap> gr := Digraph([[2, 3], [3], [], [5, 6], [6], []]);
<digraph with 6 vertices, 6 edges>
gap> topo := DigraphTopologicalSort(gr);
[ 3, 2, 1, 6, 5, 4 ]
gap> p := Permutation(Transformation(topo), topo);
(1,3)(4,6)
gap> gr1 := OnDigraphs(gr, p);;
gap> DigraphTopologicalSort(gr1) = DigraphVertices(gr1);
true
gap> gr := Digraph([[], [3], [], [5], [], [2, 3, 7, 1], [1], [2, 3, 4, 5]]);
<digraph with 8 vertices, 11 edges>
gap> topo := DigraphTopologicalSort(gr);
[ 1, 3, 2, 5, 4, 7, 6, 8 ]
gap> p := Permutation(Transformation(topo), topo);
(2,3)(4,5)(6,7)
gap> gr1 := OnDigraphs(gr, p ^ -1);;
gap> DigraphTopologicalSort(gr1) = DigraphVertices(gr1);
true

#T# AutomorphismGroup: for a multidigraph
# CanonicalLabelling was being set incorrectly by AutomorphismGroup for
# a multidigraph
gap> gr := Digraph([
>   [5, 7, 8, 4, 6, 1], [3, 1, 7, 2, 7, 9], [1, 5, 2, 3, 9],
>   [1, 3, 3, 9, 9], [6, 3, 5, 7, 9], [3, 9],
>   [8, 3, 6, 8, 8, 7, 7, 8, 9], [6, 1, 6, 7, 8, 4, 2, 5, 4],
>   [1, 5, 2, 3, 9]]);
<multidigraph with 9 vertices, 52 edges>
gap> G := AutomorphismGroup(gr);;
gap> HasBlissCanonicalLabelling(gr);
true
gap> BlissCanonicalLabelling(gr);
[ (1,5,4,2,3,7,9,6), (1,30,49)(2,34,47,35,45,39,38,51,8,12,18,24,21,28,23,13,
    4,29,22,27,20,25,14)(3,33,48)(5,31,52,7,19,26,17,9,16,10,11,15,6,32,
    50)(36,44)(37,46,40,41)(42,43) ]
gap> BlissCanonicalLabelling(gr) = BlissCanonicalLabelling(DigraphCopy(gr));
true

#T# DIGRAPH_IN_OUT_NBS: for a list containing ranges
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

#T# Issue 13: DigraphAllSimpleCircuits, reported by JDM
gap> gr := Digraph([[3], [4], [5], [1, 5], [1, 2]]);
<digraph with 5 vertices, 7 edges>
gap> DigraphAllSimpleCircuits(gr);
[ [ 1, 3, 5 ], [ 1, 3, 5, 2, 4 ], [ 5, 2, 4 ] ]

#T# DigraphMaximalCliquesReps was returning too few results, since the choice
# of a pivot vertex was not necessarily valid when the stabilizer was
# non-trivial
gap> gr := DigraphFromGraph6String("L~~~ySrJ[N{NT^");
<digraph with 13 vertices, 108 edges>
gap> gr = MaximalSymmetricSubdigraphWithoutLoops(gr);
true
gap> DigraphMaximalCliquesReps(gr);
[ [ 1, 2, 3, 4, 5, 6, 7 ], [ 1, 2, 3, 12 ], [ 2, 8, 12, 13 ], [ 4, 9, 13 ], 
  [ 8, 9, 10, 11, 12, 13 ] ]
gap> gr := DigraphFromGraph6String("I~~wzfJhw");
<digraph with 10 vertices, 66 edges>
gap> gr = MaximalSymmetricSubdigraphWithoutLoops(gr);
true
gap> DigraphMaximalCliquesReps(gr);
[ [ 1, 2, 3, 4, 5, 6 ], [ 1, 2, 5, 9 ], [ 1, 9, 10 ], [ 7, 8, 9, 10 ] ]

#T# DigraphClosure 
gap> gr := CompleteDigraph(7);; 
gap> gr2 := DigraphClosure(gr, 7);;
gap> gr = gr2;
true
gap> gr := DigraphRemoveEdge(gr, [1, 2]);;
gap> gr := DigraphRemoveEdges(gr, [[1, 2], [2, 1]]);;
gap> DigraphNrEdges(gr);
40
gap> gr2 := DigraphClosure(gr, 7);;                   
gap> DigraphNrEdges(gr2);                          
42

#T# Fix seg fault cause by wrong handling of no edges in
# FuncDIGRAPH_SOURCE_RANGE
gap> gr := Digraph([[]]);
<digraph with 1 vertex, 0 edges>
gap> DigraphSource(gr);
[  ]
gap> DigraphRange(gr);
[  ]

#T# Issue 17: Bug in OnDigraphs for a digraph and a transformation
gap> d := Digraph([[2], [3], [1, 1]]);
<multidigraph with 3 vertices, 4 edges>
gap> OutNeighbours(OnDigraphs(d, PermList([2, 3, 1])));
[ [ 2, 2 ], [ 3 ], [ 1 ] ]
gap> OutNeighbours(OnDigraphs(d, Transformation([2, 3, 1])));
[ [ 2, 2 ], [ 3 ], [ 1 ] ]

#T# Issue 42: Bug in AsDigraph for a transformation and an integer
gap> f := Transformation([7, 10, 10, 1, 7, 9, 10, 4, 2, 3]);
Transformation( [ 7, 10, 10, 1, 7, 9, 10, 4, 2, 3 ] )
gap> AsDigraph(f);
<digraph with 10 vertices, 10 edges>
gap> AsDigraph(f, 4);
fail

# Issue 52: Bug in FuncIS_ANTISYMMETRIC_DIGRAPH causing seg fault
gap> gr := Digraph([[1], [2], [1 .. 3]]);;
gap> IsAntisymmetricDigraph(gr);
true

#T# Issue 55: Bug in FuncDIGRAPH_TOPO_SORT
gap> gr := Digraph([[1 .. 4], [2, 4], [3, 4], [4]]);
<digraph with 4 vertices, 9 edges>
gap> DigraphTopologicalSort(gr);
[ 4, 2, 3, 1 ]

#T# Issue 81: Bug in Digraph for a malformed list of out-neighbours
gap> gr := Digraph([[1],, [2]]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Digraph' on 1 arguments
gap> gr := Digraph([[1], 2, [2]]);
Error, Digraphs: Digraph: usage,
the argument must be a list of lists of positive integers not exceeding the
length of the argument,

#T# Symmetric closure of a digraph with no vertices
gap> gr := EmptyDigraph(0);;
gap> DigraphSymmetricClosure(gr);
<digraph with 0 vertices, 0 edges>

#T# DIGRAPHS_UnbindVariables
gap> Unbind(gr2);
gap> Unbind(gr);
gap> Unbind(G);
gap> Unbind(p);
gap> Unbind(i);
gap> Unbind(gr1);
gap> Unbind(topo);
gap> Unbind(source);
gap> Unbind(range);
gap> Unbind(r);
gap> Unbind(func);
gap> Unbind(adj);
gap> Unbind(d);

#E#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: testinstall.tst", 0);
