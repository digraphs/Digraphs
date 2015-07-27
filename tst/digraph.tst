#%T##########################################################################
##
#W  digraph.tst
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: digraph.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DigraphsStartTest();

#T# DigraphVertexLabels
gap> gr := RandomDigraph(10);;
gap> DigraphVertexLabels(gr);
[ 1 .. 10 ]
gap> SetDigraphVertexLabels( gr, [ "a", "b", 10 ] );
Error, Graphs: SetDigraphVertexLabels: usage,
the 2nd arument <names> must be a list with length equal to the number of
vertices of the digraph,
gap> gr := RandomDigraph(3);;
gap> SetDigraphVertexLabels( gr, [ "a", "b", 10 ] );
gap> DigraphVertexLabels(gr);
[ "a", "b", 10 ]
gap> DigraphVertexLabel(gr, 1);
"a"
gap> DigraphVertexLabel(gr, 2);
"b"
gap> DigraphVertexLabel(gr, 10);
Error, Graphs: DigraphVertexLabel: usage,
10 is nameless or not a vertex,
gap> DigraphVertexLabel(gr, 3);
10
gap> SetDigraphVertexLabel(gr, 3, 3);
gap> DigraphVertexLabel(gr, 3);
3
gap> gr := RandomDigraph(5);;
gap> SetDigraphVertexLabel(gr, 6, (1,3,2,5,4));
Error, Graphs: SetDigraphVertexLabel: usage,
there are only 5 vertices,
gap> SetDigraphVertexLabel(gr, 2, (1,3,2,5,4));
gap> DigraphVertexLabel(gr, 2);
(1,3,2,5,4)
gap> gr := RandomDigraph(3);;
gap> DigraphVertexLabel(gr, 2);
2
gap> gr := RandomDigraph(10);;
gap> gr := InducedSubdigraph( gr, [ 1, 2, 3, 5, 7 ] );;
gap> DigraphVertexLabels(gr);
[ 1, 2, 3, 5, 7 ]
gap> DigraphVertices(gr);
[ 1 .. 5 ]

#T# DigraphEdgeLabels
gap> gr := RandomMultiDigraph(8, 20);;
gap> DigraphEdgeLabels(gr);
[ 1 .. 20 ]
gap> DigraphEdgeLabel(gr, 10);
10
gap> gr := RandomMultiDigraph(8, 20);;
gap> DigraphEdgeLabel(gr, 15);
15
gap> gr := RandomMultiDigraph(8, 20);;
gap> SetDigraphEdgeLabel(gr, 4, Group((1,2,3)));
gap> DigraphEdgeLabel(gr, 4);
Group([ (1,2,3) ])
gap> DigraphEdgeLabel(gr, 5);
5
gap> gr := RandomMultiDigraph(8, 20);;
gap> SetDigraphEdgeLabel(gr, 0, 0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `SetDigraphEdgeLabel' on 3 arguments
gap> SetDigraphEdgeLabel(gr, 21, 21);
Error, Graphs: SetDigraphEdgeLabel: usage,
there are only 20 vertices,
gap> SetDigraphEdgeLabels(gr, Elements(CyclicGroup(20)));;
gap> DigraphEdgeLabels(gr);
[ <identity> of ..., f1, f2, f3, f1*f2, f1*f3, f2*f3, f3^2, f1*f2*f3, 
  f1*f3^2, f2*f3^2, f3^3, f1*f2*f3^2, f1*f3^3, f2*f3^3, f3^4, f1*f2*f3^3, 
  f1*f3^4, f2*f3^4, f1*f2*f3^4 ]
gap> DigraphEdgeLabel(gr, 10);
f1*f3^2
gap> DigraphEdgeLabel(gr, 21);
Error, Graphs: DigraphEdgeLabel: usage,
21 is nameless or not a vertex,
gap> SetDigraphEdgeLabels(gr, [ 1 .. 21 ]);
Error, Graphs: SetDigraphEdgeLabels: usage,
the 2nd arument <names> must be a list with length equal to the number of
vertices of the digraph,

#T# Graph
gap> gr := Digraph( [ [ 2, 2 ], [ ] ] );
<multidigraph with 2 vertices, 2 edges>
gap> if DIGRAPHS_IsGrapeLoaded then 
>   Graph(gr); 
> fi;

#T# Digraph (by OutNeighbours)
gap> Digraph( [ [ 0, 1 ] ] );
Error, Graphs: Digraph: usage,
the argument must be a list of lists of positive integers
not exceeding the length of the argument,
gap> Digraph( [ [ 2 ], [ 3 ] ] );
Error, Graphs: Digraph: usage,
the argument must be a list of lists of positive integers
not exceeding the length of the argument,

#T# Digraph (by record)
gap> n := 3;;
gap> v := [ 1 .. 3 ];;
gap> s := [ 1, 2, 3 ];;
gap> r := [ 3, 1, 2 ];;
gap> Digraph( rec( nrvertices := n, source := s ) );
Error, Graphs: Digraph: usage,
the argument must be a record with components:
'source', 'range', and either 'vertices' or 'nrvertices',
gap> Digraph( rec( nrvertices := n, range := r ) );
Error, Graphs: Digraph: usage,
the argument must be a record with components:
'source', 'range', and either 'vertices' or 'nrvertices',
gap> Digraph( rec( nrvertices := n, source := s, vertices := v ) );
Error, Graphs: Digraph: usage,
the argument must be a record with components:
'source', 'range', and either 'vertices' or 'nrvertices',
gap> Digraph( rec( nrvertices := n, range := r, vertices := v ) );
Error, Graphs: Digraph: usage,
the argument must be a record with components:
'source', 'range', and either 'vertices' or 'nrvertices',
gap> Digraph( rec( source := s, range := r ) );
Error, Graphs: Digraph: usage,
the argument must be a record with components:
'source', 'range', and either 'vertices' or 'nrvertices',
gap> Digraph( rec( nrvertices := n, source := s, range := 4 ) );
Error, Graphs: Digraph: usage,
the graph components 'source' and 'range' should be lists,
gap> Digraph( rec( nrvertices := n, source := 1, range := r ) );
Error, Graphs: Digraph: usage,
the graph components 'source' and 'range' should be lists,
gap> Digraph( rec( nrvertices := n, source := [ 1, 2 ], range := r ) );
Error, Graphs: Digraph: usage,
the record components 'source' and 'range' should have equal length,
gap> Digraph( rec( nrvertices := "a", source := s, range := r ) );
Error, Graphs: Digraph: usage,
the record component 'nrvertices' should be a non-negative integer,
gap> Digraph( rec( nrvertices := -3, source := s, range := r ) );
Error, Graphs: Digraph: usage,
the record component 'nrvertices' should be a non-negative integer,
gap> Digraph(
> rec( nrvertices := 2, vertices := [ 1 .. 3 ], source := [ 2 ], range := [ 2 ] ) );
Error, Graphs: Digraph: usage,
the record components 'nrvertices' and 'vertices' are inconsistent,
gap> Digraph( rec( nrvertices := n, source := [ 0 .. 2 ], range := r ) );
Error, Graphs: Digraph: usage,
the record component 'source' is invalid,
gap> Digraph( rec( nrvertices := n, source := [ 2 .. 4 ], range := r ) );
Error, Graphs: Digraph: usage,
the record component 'source' is invalid,
gap> Digraph( rec( vertices := 2, source := s, range := r ) );
Error, Graphs: Digraph: usage,
the record component 'vertices' should be a list,
gap> Digraph( rec( nrvertices := n, source := [ 1, 2, 4 ], range := r ) );
Error, Graphs: Digraph: usage,
the record component 'source' is invalid,
gap> Digraph( rec( vertices := v, source := [ 1, 2, 4 ], range := r ) );
Error, Graphs: Digraph: usage,
the record component 'source' is invalid,
gap> Digraph( rec( nrvertices := n, source := s, range := [ 1, 4, 2 ] ) );
Error, Graphs: Digraph: usage,
the record component 'range' is invalid,
gap> Digraph( rec( vertices := v, source := s, range := [ 1, 4, 2 ] ) );
Error, Graphs: Digraph: usage,
the record component 'range' is invalid,
gap> Digraph( rec( vertices := "abc", source := "acbab", range := "cbabb" ) );
<digraph with 3 vertices, 5 edges>
gap> Digraph( rec(
> vertices := [ 1, 1, 2 ], source := [ 1, 2 ], range := [ 1, 2 ] ) );
Error, Graphs: Digraph: usage,
the record component 'vertices' must be duplicate-free,

#T# Digraph (for nrvertices, source and range)
gap> Digraph( Group(()), [  ], [  ] );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Digraph' on 3 arguments
gap> Digraph( 2, [ 1, "a" ], [ 2, 1 ] );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Digraph' on 3 arguments
gap> Digraph( 2, [ 1, 1 ], [ 1, Group(()) ] );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Digraph' on 3 arguments
gap> Digraph( -1, [  ], [  ] );
Error, Graphs: Digraph: usage,
the first argument <nrvertices> must be a non-negative integer,
gap> Digraph( 0, [  ], [ "a" ] );
Error, Graphs: Digraph: usage,
the second and third arguments <source> and <range> must be lists
of equal length,
gap> Digraph( 2, [ 1 ], [ 2, 2 ] );
Error, Graphs: Digraph: usage,
the second and third arguments <source> and <range> must be lists
of equal length,
gap> Digraph( 5, [  ], [  ] );
<digraph with 5 vertices, 0 edges>
gap> Digraph( 2, "ab", [ 0, 1 ] );
Error, Graphs: Digraph: usage,
the second and third arguments <source> and <range> must be lists
of positive integers no greater than the first argument <nrvertices>,
gap> Digraph( 2, [ 0, 1 ], "ab" );
Error, Graphs: Digraph: usage,
the second and third arguments <source> and <range> must be lists
of positive integers no greater than the first argument <nrvertices>,
gap> Digraph( 1, [ 2 ], [ 1 ] );
Error, Graphs: Digraph: usage,
the second and third arguments <source> and <range> must be lists
of positive integers no greater than the first argument <nrvertices>,
gap> Digraph( 1, [ 1 ], [ 2 ] );
Error, Graphs: Digraph: usage,
the second and third arguments <source> and <range> must be lists
of positive integers no greater than the first argument <nrvertices>,
gap> Digraph( 2, [ 1, 0 ], [ 2, 1 ] );
Error, Graphs: Digraph: usage,
the second and third arguments <source> and <range> must be lists
of positive integers no greater than the first argument <nrvertices>,
gap> Digraph( 2, [ 1, 1 ], [ 2, 0 ] );
Error, Graphs: Digraph: usage,
the second and third arguments <source> and <range> must be lists
of positive integers no greater than the first argument <nrvertices>,
gap> Digraph( 4, [ 3, 1, 2, 3 ], [ 4, 1, 2, 4 ] );
<multidigraph with 4 vertices, 4 edges>

#T# Digraph (for vertices, source, range)
gap> Digraph( Group(()), [  ], [  ] );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Digraph' on 3 arguments
gap> Digraph( [  ], Group(()), [  ] );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Digraph' on 3 arguments
gap> Digraph( [  ], [  ], Group(()) );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Digraph' on 3 arguments
gap> Digraph( [ 1 ], [ 2 ], [ 3, 4 ] );
Error, Graphs: Digraph: usage,
the second and third arguments <source> and <range> must be lists of
equal length,
gap> Digraph( [ 1, 1 ], [  ], [  ] );
Error, Graphs: Digraph: usage,
the first argument <vertices> must be a duplicate-free list,
gap> Digraph( [ Group(()) ], [ 1 ], [ Group(()) ] );
Error, Graphs: Digraph: usage,
the second argument <source> must be a list of elements of <vertices>,
gap> Digraph( [ Group(()) ], [ Group(()) ], [ 1 ] );
Error, Graphs: Digraph: usage,
the third argument <range> must be a list of elements of <vertices>,
gap> gr := Digraph(
> [ Group(()), SymmetricGroup(3) ], [ Group(()) ], [ SymmetricGroup(3) ] );;
gap> DigraphVertexLabels(gr);
[ Group(()), Sym( [ 1 .. 3 ] ) ]
gap> HasDigraphNrEdges(gr);
true
gap> HasDigraphNrVertices(gr);
true
gap> HasDigraphSource(gr);
true
gap> HasDigraphRange(gr);
true
gap> gr;
<digraph with 2 vertices, 1 edge>
gap> DigraphSource(gr);
[ 1 ]
gap> DigraphRange(gr);
[ 2 ]
gap> gr := Digraph( [ 1 .. 3 ], [ 3, 2, 1 ], [ 2, 3, 2 ] );;
gap> DigraphVertexLabels(gr);
[ 1 .. 3 ]
gap> HasDigraphNrEdges(gr);
true
gap> HasDigraphNrVertices(gr);
true
gap> HasDigraphSource(gr);
true
gap> HasDigraphRange(gr);
true
gap> DigraphSource(gr);
[ 1, 2, 3 ]
gap> DigraphRange(gr);
[ 2, 3, 2 ]
gap> gr;
<digraph with 3 vertices, 3 edges>

#T# Digraph (for an integer and a function)
gap> divides := function(a, b)
>   if b mod a = 0 then
>     return true;
>   fi;
>   return false;
> end;;
gap> gr := Digraph( 12, divides );
<digraph with 12 vertices, 35 edges>

#T# Digraph (for a binary relation)
gap> g := Group( (1,2,3) );
Group([ (1,2,3) ])
gap> elms := [
>  DirectProductElement( [ (1,2,3), (1,3,2) ] ),
>  DirectProductElement( [ (1,3,2), (1,2,3) ] ),
>  DirectProductElement( [ (), () ] )
> ];;
gap> bin := BinaryRelationByElements(g, elms);
<general mapping: Group( [ (1,2,3) ] ) -> Group( [ (1,2,3) ] ) >
gap> Digraph(bin);
Error, Graphs: Digraph: usage,
the argument <rel> must be a binary relation
on the domain [ 1 .. n ] for some positive integer n,
gap> d := Domain( [ 2 .. 10 ] );;
gap> bin := BinaryRelationByElements(d, [
>  DirectProductElement([ 2, 5 ]),
>  DirectProductElement([ 6, 3 ]),
>  DirectProductElement([ 4, 5 ])
> ] );
<general mapping: <object> -> <object> >
gap> gr := Digraph(bin);
Error, Graphs: Digraph: usage,
the argument <rel> must be a binary relation
on the domain [ 1 .. n ] for some positive integer n,
gap> d := Domain( [ 1 .. 10 ] );;
gap> bin := BinaryRelationByElements(d, [
>  DirectProductElement([ 2, 5 ]),
>  DirectProductElement([ 6, 3 ]),
>  DirectProductElement([ 4, 5 ])
> ] );
<general mapping: <object> -> <object> >
gap> gr := Digraph(bin);
<digraph with 10 vertices, 3 edges>
gap> DigraphEdges(gr);
[ [ 2, 5 ], [ 4, 5 ], [ 6, 3 ] ]
gap> bin := BinaryRelationOnPoints( [ [ 1 ], [ 4 ], [ 5 ], [ 2 ], [ 4 ] ] );
Binary Relation on 5 points
gap> gr := Digraph(bin);
<digraph with 5 vertices, 5 edges>
gap> OutNeighbours(gr);
[ [ 1 ], [ 4 ], [ 5 ], [ 2 ], [ 4 ] ]

#T# DigraphByEdges
gap> gr := Digraph( [ [ 1, 2, 3, 5 ], [ 1, 5 ], [ 2, 3, 6 ], [ 1, 3, 4 ], 
> [ 1, 4, 6 ], [ 3, 4 ] ] );
<digraph with 6 vertices, 17 edges>
gap> gr = DigraphByEdges(DigraphEdges(gr));
true
gap> DigraphByEdges( [ [ "nonsense", "more" ] ] );
Error, Graphs: DigraphByEdges: usage,
the argument <edges> must be a list of pairs of pos ints,
gap> DigraphByEdges( [ [ "nonsense" ] ] );
Error, Graphs: DigraphByEdges: usage,
the argument <edges> must be a list of pairs,
gap> DigraphByEdges( [[  "a", "b" ] ], 2 );
Error, Graphs: DigraphByEdges: usage,
the argument <edges> must be a list of pairs of pos ints,
gap> DigraphByEdges( [ [ 1, 2, 3 ] ], 3 );
Error, Graphs: DigraphByEdges: usage,
the argument <edges> must be a list of pairs,
gap> gr := DigraphByEdges(DigraphEdges(gr), 10);
<digraph with 10 vertices, 17 edges>
gap> gr := DigraphByEdges( [ [ 1, 2 ] ] );
<digraph with 2 vertices, 1 edge>
gap> gr := DigraphByEdges( [ [ 2, 1 ] ] );
<digraph with 2 vertices, 1 edge>
gap> gr := DigraphByEdges( [ [ 1, 2 ] ], 1 ); 
Error, Graphs: DigraphByEdges: usage,
the specified edges must not contain values greater than 1,
gap> gr := DigraphByEdges( [  ], 3 );
<digraph with 3 vertices, 0 edges>

#T# DigraphByAdjacencyMatrix
gap> mat := [
> [ 1, 2, 3 ],
> [ 1, 2, 3 ] ];;
gap> DigraphByAdjacencyMatrix(mat);
Error, Graphs: DigraphByAdjacencyMatrix: usage,
the matrix is not square,
gap> mat := [
> [ 11, 2, 3 ],
> [ 11, 2, 3 ],
> [ -1, 2, 2 ] ];;
gap> DigraphByAdjacencyMatrix(mat);
Error, Graphs: DigraphByAdjacencyMatrix: usage,
the argument must be a matrix of non-negative integers,
gap> mat := [ [ "a" ] ];;
gap> DigraphByAdjacencyMatrix(mat);
Error, Graphs: DigraphByAdjacencyMatrix: usage,
the argument must be a matrix of non-negative integers,
gap> mat := [
> [ 0, 2, 0, 0, 1 ],
> [ 0, 2, 1, 0, 1 ],
> [ 0, 0, 0, 0, 1 ],
> [ 1, 0, 1, 1, 0 ],
> [ 0, 0, 3, 0, 0 ] ];;
gap> gr := DigraphByAdjacencyMatrix(mat);
<multidigraph with 5 vertices, 14 edges>
gap> grnc := DigraphByAdjacencyMatrixNC(mat);
<multidigraph with 5 vertices, 14 edges>
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
> [ 0, 0, 0, 9, 1, 0, 0, 1, 0, 0 ],
> [ 0, 1, 0, 1, 1, 1, 0, 1, 1, 0 ],
> [ 0, 1, 0, 1, 2, 0, 1, 0, 0, 3 ],
> [ 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 ],
> [ 1, 0, 0, 1, 0, 1, 1, 0, 1, 0 ],
> [ 0, 1, 1, 0, 0, 5, 1, 0, 0, 1 ],
> [ 0, 0, 1, 2, 1, 0, 0, 1, 1, 0 ],
> [ 0, 0, 1, 1, 0, 0, 0, 2, 1, 1 ],
> [ 1, 2, 3, 0, 1, 1, 0, 0, 1, 1 ],
> [ 0, 1, 3, 4, 1, 1, 0, 0, 1, 0 ] ];;
gap> gr := DigraphByAdjacencyMatrix(mat);
<multidigraph with 10 vertices, 73 edges>
gap> IsMultiDigraph(gr);
true
gap> OutNeighbours(gr);
[ [ 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 8 ], [ 2, 4, 5, 6, 8, 9 ], 
  [ 2, 4, 5, 5, 7, 10, 10, 10 ], [ 9 ], [ 1, 4, 6, 7, 9 ], 
  [ 2, 3, 6, 6, 6, 6, 6, 7, 10 ], [ 3, 4, 4, 5, 8, 9 ], [ 3, 4, 8, 8, 9, 10 ],
  [ 1, 2, 2, 3, 3, 3, 5, 6, 9, 10 ], [ 2, 3, 3, 3, 4, 4, 4, 4, 5, 6, 9 ] ]
gap> r := rec( nrvertices:= 10, source := ShallowCopy(DigraphSource(gr)),
> range := ShallowCopy(DigraphRange(gr)) );;
gap> gr2 := Digraph(r);
<multidigraph with 10 vertices, 73 edges>
gap> HasAdjacencyMatrix(gr2);
false
gap> AdjacencyMatrix(gr2) = mat;
true
gap> DigraphByAdjacencyMatrix( [ ] );
<digraph with 0 vertices, 0 edges>

#T# DigraphByInNeighbours
gap> gr1 := RandomMultiDigraph(50, 3000);
<multidigraph with 50 vertices, 3000 edges>
gap> inn := InNeighbours(gr1);;
gap> gr2 := DigraphByInNeighbours(inn);
<multidigraph with 50 vertices, 3000 edges>
gap> gr3 := DigraphByInNeighbors(inn);;
gap> gr4 := DigraphByInNeighboursNC(inn);
<multidigraph with 50 vertices, 3000 edges>
gap> HasDigraphNrEdges(gr3);
true
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
gap> inn := [ [ 3, 1, 2 ], [ 1 ] ];;
gap> DigraphByInNeighbours(inn);
Error, Graphs: DigraphByInNeighbours: usage,
the argument must be a list of lists of positive integers
not exceeding the length of the argument,
gap> inn := [
> [  ], [ 3 ], [ 7 ], [  ], [  ], [  ], [  ], [  ], [  ], [  ], [  ], [ 6 ],
> [  ], [ 2 ], [  ], [  ], [  ], [  ], [ 5 ], [  ] ];;
gap> gr := DigraphByInNeighbours(inn);
<digraph with 20 vertices, 5 edges>
gap> OutNeighbours(gr);
[ [  ], [ 14 ], [ 2 ], [  ], [ 19 ], [ 12 ], [ 3 ], [  ], [  ], [  ], [  ], 
  [  ], [  ], [  ], [  ], [  ], [  ], [  ], [  ], [  ] ]
gap> inn := [
> [ 14 ], [ 20 ], [  ], [  ], [ 5, 19, 5 ], [ 4 ], [  ], [  ], [  ], [  ],
> [ 12 ], [  ], [  ], [  ], [  ], [  ], [  ], [  ], [  ], [ 2 ] ];;
gap> gr := DigraphByInNeighbours(inn);
<multidigraph with 20 vertices, 8 edges>
gap> OutNeighbours(gr);
[ [  ], [ 20 ], [  ], [ 6 ], [ 5, 5 ], [  ], [  ], [  ], [  ], [  ], [  ], 
  [ 11 ], [  ], [ 1 ], [  ], [  ], [  ], [  ], [ 5 ], [ 2 ] ]
gap> InNeighbors(gr) = inn;
true

#T# AsDigraph
gap> f := Transformation([]);
IdentityTransformation
gap> gr := AsDigraph(f);
<digraph with 0 vertices, 0 edges>
gap> gr = Digraph( [] );
true
gap> AsDigraph(f, 10);
<digraph with 10 vertices, 10 edges>
gap> g := Transformation( [ 2, 6, 7, 2, 6, 1, 1, 5 ] );
Transformation( [ 2, 6, 7, 2, 6, 1, 1, 5 ] )
gap> AsDigraph(g);
<digraph with 8 vertices, 8 edges>
gap> AsDigraph(g, -1);
Error, Graphs: AsDigraph: usage,
the second argument should be a non-negative integer,
gap> AsDigraph(g, 10);
<digraph with 10 vertices, 10 edges>
gap> h := Transformation( [ 2, 4, 1, 3, 5 ] );
Transformation( [ 2, 4, 1, 3 ] )
gap> AsDigraph(h);
<digraph with 4 vertices, 4 edges>

#T# RandomDigraph
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
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RandomDigraph' on 2 arguments
gap> RandomDigraph(10, 1.01);
Error, Graphs: RandomDigraph: usage,
the second argument <p> must be a float between 0 and 1,
gap> RandomDigraph(10, -0.01);
Error, Graphs: RandomDigraph: usage,
the second argument <p> must be a float between 0 and 1,

#T# RandomMultiDigraph
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

#T# RandomTournament
gap> RandomTournament(25);
<digraph with 25 vertices, 300 edges>
gap> RandomTournament(0);
<digraph with 0 vertices, 0 edges>
gap> RandomTournament(-1);
Error, Graphs: RandomTournament: usage,
the argument <n> must be a non-negative integer,

#T# CompleteDigraph
gap> gr := CompleteDigraph(5);
<digraph with 5 vertices, 20 edges>
gap> CompleteDigraph(1) = EmptyDigraph(1);
true
gap> CompleteDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> CompleteDigraph(-1);
Error, Graphs: CompleteDigraph: usage,
the argument <n> must be a non-negative integer,

#T# EmptyDigraph
gap> gr := EmptyDigraph(5);
<digraph with 5 vertices, 0 edges>
gap> EmptyDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> EmptyDigraph(-1);
Error, Graphs: EmptyDigraph: usage,
the argument <n> must be a non-negative integer,

#T# CycleDigraph
gap> gr := CycleDigraph(0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `CycleDigraph' on 1 arguments
gap> gr := CycleDigraph(1);
<digraph with 1 vertex, 1 edge>
gap> gr := CycleDigraph(6);;
gap> DigraphEdges(gr);
[ [ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 4, 5 ], [ 5, 6 ], [ 6, 1 ] ]
gap> gr := CycleDigraph(1000);
<digraph with 1000 vertices, 1000 edges>

#T# ChainDigraph
gap> gr := ChainDigraph(0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ChainDigraph' on 1 arguments
gap> gr := ChainDigraph(1);
<digraph with 1 vertex, 0 edges>
gap> IsEmptyDigraph(gr);
true
gap> gr = EmptyDigraph(1);
true
gap> gr := ChainDigraph(10);
<digraph with 10 vertices, 9 edges>
gap> OutNeighbours(gr);
[ [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ], [  ] ]
gap> grrt := DigraphReflexiveTransitiveClosure(gr);
<digraph with 10 vertices, 55 edges>
gap> IsPartialOrderBinaryRelation(AsBinaryRelation(grrt));
true
gap> IsAntisymmetricDigraph(grrt);
true

#T# CompleteBipartiteDigraph
gap> gr := CompleteBipartiteDigraph(2, 0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `CompleteBipartiteDigraph' on 2 argument\
s
gap> gr := CompleteBipartiteDigraph(0, 2);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `CompleteBipartiteDigraph' on 2 argument\
s
gap> gr := CompleteBipartiteDigraph(4, 3);
<digraph with 7 vertices, 24 edges>
gap> DigraphEdges(gr);
[ [ 1, 5 ], [ 1, 6 ], [ 1, 7 ], [ 2, 5 ], [ 2, 6 ], [ 2, 7 ], [ 3, 5 ], 
  [ 3, 6 ], [ 3, 7 ], [ 4, 5 ], [ 4, 6 ], [ 4, 7 ], [ 5, 1 ], [ 5, 2 ], 
  [ 5, 3 ], [ 5, 4 ], [ 6, 1 ], [ 6, 2 ], [ 6, 3 ], [ 6, 4 ], [ 7, 1 ], 
  [ 7, 2 ], [ 7, 3 ], [ 7, 4 ] ]

#T# Equals
gap> r1 := rec( nrvertices := 2, source := [ 1, 1, 2 ], range := [ 1, 2, 2 ] );
rec( nrvertices := 2, range := [ 1, 2, 2 ], source := [ 1, 1, 2 ] )
gap> r2 := rec( nrvertices := 2, source := [ 1, 1, 2 ], range := [ 2, 1, 2 ] );
rec( nrvertices := 2, range := [ 2, 1, 2 ], source := [ 1, 1, 2 ] )
gap> gr1 := Digraph(r1);
<digraph with 2 vertices, 3 edges>
gap> gr2 := Digraph(r2);
<digraph with 2 vertices, 3 edges>
gap> DigraphRange(gr1);
[ 1, 2, 2 ]
gap> DigraphRange(gr2);
[ 2, 1, 2 ]
gap> gr1 = gr2;
true
gap> gr1 := Digraph( [ [ 2 ], [ 1 ] ] );
<digraph with 2 vertices, 2 edges>
gap> gr2 := Digraph( [ [ 1 ] ] );
<digraph with 1 vertex, 1 edge>
gap> gr1 = gr2;
false
gap> gr1 := Digraph( [ [ 1, 2 ], [ ] ] );
<digraph with 2 vertices, 2 edges>
gap> gr2 := Digraph( [ [ 1 ] , [ 2 ] ] );
<digraph with 2 vertices, 2 edges>
gap> gr1 = gr2;
false
gap> gr1 := Digraph( [ [ ], [ ], [ ] ] );
<digraph with 3 vertices, 0 edges>
gap> gr2 := Digraph( rec ( nrvertices := 3, source := [ ], range := [ ] ) );
<digraph with 3 vertices, 0 edges>
gap> gr1 = gr2;
true
gap> gr1 := Digraph( [ [ 1 ], [ ] ] );
<digraph with 2 vertices, 1 edge>
gap> gr2 := Digraph( [ [ 2 ], [ ] ] );
<digraph with 2 vertices, 1 edge>
gap> gr1 = gr2;
false
gap> gr1 := Digraph( [ [ 1 ], [ 2 ] ] );
<digraph with 2 vertices, 2 edges>
gap> gr2 := Digraph( [ [ 2 ], [ 1 ] ] );
<digraph with 2 vertices, 2 edges>
gap> gr1 = gr2;
false
gap> gr1 := Digraph( [ [ 1, 3, 1 ], [ 3, 2 ], [ 1, 3, 2 ] ] );
<multidigraph with 3 vertices, 8 edges>
gap> gr2 := Digraph( rec( nrvertices := 3,
> source := [ 1, 1, 1, 2, 2, 3, 3, 3 ],
> range := [ 1, 1, 2, 3, 2, 1, 3, 2 ] ) );
<multidigraph with 3 vertices, 8 edges>
gap> gr3 := Digraph( rec( nrvertices := 3,
> source := [ 1, 1, 1, 2, 2, 3, 3, 3 ],
> range := [ 1, 3, 1, 3, 3, 1, 3, 2 ] ) );
<multidigraph with 3 vertices, 8 edges>
gap> gr4 := Digraph( rec( nrvertices := 3,
> source := [ 1, 1, 1, 2, 2, 3, 3, 3 ],
> range := [ 1, 3, 1, 3, 2, 1, 2, 2 ] ) );
<multidigraph with 3 vertices, 8 edges>
gap> gr5 := Digraph( rec( nrvertices := 3,
> source := [ 1, 1, 1, 2, 2, 3, 3, 3 ],
> range := [ 1, 1, 3, 2, 3, 2, 1, 3 ] ) );
<multidigraph with 3 vertices, 8 edges>
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
gap> graph1 := Digraph( [ [ 2 ], [ 1 ], [ ] ] );
<digraph with 3 vertices, 2 edges>
gap> graph2 := Digraph(
> rec( nrvertices := 3, source := [ 1, 2 ], range := [ 2, 1 ] ) );
<digraph with 3 vertices, 2 edges>
gap> graph1 = graph2;                     
true
gap> gr1 := Digraph( [ [ 2 ], [ 1 ], [ 1, 2 ] ] );
<digraph with 3 vertices, 4 edges>
gap> gr2 := Digraph( [ [ 2 ], [ 1 ] , [ 2, 1 ] ] );
<digraph with 3 vertices, 4 edges>
gap> gr1 = gr2;
true
gap> im := OnDigraphs( gr1, (1,2) ); 
<digraph with 3 vertices, 4 edges>
gap> DigraphSource(im);
[ 1, 2, 3, 3 ]
gap> gr1 = im;
true
gap> gr2 = im;
true
gap> gr1 = gr1;
true
gap> gr1 := Digraph( [ [ 2 ], [ ] ] );;
gap> gr2 := Digraph( rec( nrvertices := 1, source := [ ], range := [ ] ) );;
gap> gr1 = gr2; # Different number of vertices
false
gap> gr2 := Digraph( rec(
> nrvertices := 2, source := [ 1, 2 ], range := [ 1, 2 ] ) );;
gap> gr1 = gr2; # Different number of edges
false
gap> EmptyDigraph(2) =
> Digraph( rec( nrvertices := 2, source := [ ], range := [ ] ) ); # Both empty
true
gap> gr1 := Digraph( [ [ ], [ 1, 2 ] ] );;
gap> gr1 = gr2; # |out1[1]| = 0, |out2[1]| <> =
false
gap> gr1 := Digraph( [ [ 1, 1 ], [ 2, 2 ] ] );;
gap> gr2 := Digraph( rec(
> nrvertices := 2, source := [ 1, 2, 2, 2 ], range := [ 1, 2, 2, 2 ] ) );;
gap> gr1 = gr2; # |out1[1]| = 2, |out2[1]| = 1
false
gap> gr2 := Digraph( rec(
> nrvertices := 2, source := [ 1, 1, 1, 2 ], range := [ 1, 1, 1, 2 ] ) );;
gap> gr1 = gr2; # |out1[1]| = 2, |out2[1]| = 3
false
gap> gr1 := Digraph( [ [ 1, 2 ], [ 2, 1 ] ] );;
gap> gr2 := Digraph( rec(
> nrvertices := 2, source := [ 1, 1, 2, 2 ], range := [ 1, 2, 2, 2 ] ) );;
gap> gr1 = gr2; # Different contents of out[2]
false
gap> gr2 := Digraph( rec(
> nrvertices := 2, source := [ 1, 1, 2, 2 ], range := [ 1, 2, 1, 2 ] ) );;
gap> gr1 = gr2; # out[2] sorted differently
true
gap> gr1 := Digraph(
> [ [ 10, 8, 4, 6, 7, 2, 9, 5, 3 ], [ 10, 9, 2, 1, 4, 7, 6, 8, 3 ], 
>   [ 6, 7, 9, 3, 10, 5, 2, 4, 1 ], [ 1, 7, 4, 8, 5, 3, 9, 10 ], 
>   [ 2, 9, 6, 10, 5, 8, 3, 4, 7 ], [ 3, 6, 10, 1, 7, 9, 5, 8, 4 ], 
>   [ 1, 9, 4, 10, 7, 8, 5, 2 ], [ 4, 10, 7, 6, 1, 2, 3, 8, 5 ], 
>   [ 6, 2, 7, 9, 3, 8, 5, 1, 4 ], [ 4, 3, 2, 10, 8, 7, 5, 6, 9 ] ] );;
gap> s :=
> [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3,
>   3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6,
>   6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8,
>   8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 10, 10, 10 ];;
gap> r2 :=
> [ 3, 5, 9, 2, 7, 6, 4, 8, 10, 3, 8, 6, 7, 4, 1, 2, 9, 10, 1, 4, 2, 5,
>   10, 3, 9, 7, 6, 10, 9, 3, 5, 8, 4, 7, 1, 7, 4, 3, 8, 5, 10, 6, 9, 2,
>   4, 8, 5, 9, 7, 1, 10, 6, 3, 2, 5, 8, 7, 10, 4, 9, 1, 5, 8, 3, 2, 1, 6, 
>   7, 10, 4, 4, 1, 5, 8, 3, 9, 7, 2, 6, 9, 6, 5, 7, 8, 10, 2, 3, 4 ];;
gap> gr2 := Digraph( rec( nrvertices := 10, source := s, range := r2 ) );;
gap> gr1 = gr2;
true
gap> gr1 := Digraph( [ [ 2 ], [ ] ] );;
gap> gr2 := Digraph( [ [ 1 ] ] );;
gap> gr1 = gr2; # Different number of vertices
false
gap> gr2 := Digraph( [ [ 1 ], [ 2 ] ] );;
gap> gr1 = gr2; # Different number of edges
false
gap> EmptyDigraph(2) = Digraph( [ [ ], [ ] ] ); # Both empty digraphs
true
gap> gr1 := Digraph(
> rec( nrvertices := 2, source := [ 1, 2 ], range := [ 1, 2 ] ) );;
gap> OutNeighbours(gr1);;
gap> gr1 = gr2; # Equal outneighbours
true
gap> gr1 := Digraph( [ [ ], [ 1, 2 ] ] );;
gap> gr1 = gr2; # Different lengths of out[1]
false
gap> gr1 := Digraph( [ [ 1, 1 ], [ ] ] );;
gap> gr1 = gr2; # Different lengths of out[1]
false
gap> gr1 := Digraph( [ [ 1 ], [ 1 ] ] );;
gap> gr1 = gr2; # Different contents of out[2]
false
gap> gr1 := Digraph( [ [ 1 ], [ 1, 2 ] ] );;
gap> gr2 := Digraph( [ [ 1 ], [ 1, 1 ] ] );;
gap> gr1 = gr2; # Different contents of out[2]
false
gap> gr2 := Digraph( [ [ 1 ], [ 2, 1 ] ] );;
gap> gr1 = gr2; # out[2] sorted differently
true
gap> gr1 := Digraph(
> [ [ 10, 8, 4, 6, 7, 2, 9, 5, 3 ], [ 10, 9, 2, 1, 4, 7, 6, 8, 3 ], 
>   [ 6, 7, 9, 3, 10, 5, 2, 4, 1 ], [ 1, 7, 4, 8, 5, 3, 9, 10 ], 
>   [ 2, 9, 6, 10, 5, 8, 3, 4, 7 ], [ 3, 6, 10, 1, 7, 9, 5, 8, 4 ], 
>   [ 1, 9, 4, 10, 7, 8, 5, 2 ], [ 4, 10, 7, 6, 1, 2, 3, 8, 5 ], 
>   [ 6, 2, 7, 9, 3, 8, 5, 1, 4 ], [ 4, 3, 2, 10, 8, 7, 5, 6, 9 ] ] );;
gap> gr2 := Digraph( List( ShallowCopy(OutNeighbours(gr1)), Reversed ) );;
gap> gr1 = gr2;
true
gap> gr1 := Digraph(
> [ [ 1, 4, 9 ], [ 7 ], [ 6, 7, 9, 10 ], [ 2, 6 ], [ 4, 5 ], [ 1, 8, 10 ],
>   [ 8 ], [ 4, 6 ], [ 1, 4, 9 ], [ 2, 3, 6, 8 ] ] );;
gap> new := List( ShallowCopy(OutNeighbours(gr1)), Reversed );;
gap> new[ 10 ] := [ 8, 6, 7, 2 ];;
gap> gr2 := Digraph( new );;
gap> gr1 = gr2;
false
gap> gr1 := RandomDigraph( 10, 0.264 );;
gap> gr2 := Digraph( List( ShallowCopy(OutNeighbours(gr1)), Reversed ) );;
gap> gr1 = gr2;
true
gap> gr1 := Digraph( rec( nrvertices := 0, source := [ ], range := [ ] ) );;
gap> gr1 = gr1; # IsIdenticalObj
true
gap> gr2 := Digraph( rec( nrvertices := 1, source := [ ], range := [ ] ) );;
gap> gr1 = gr2; # Different number of vertices
false
gap> gr1 := Digraph( rec( nrvertices := 1, source := [ 1 ], range := [ 1 ] ) );;
gap> gr1 = gr2; # Different sources
false
gap> gr2 := Digraph( rec( nrvertices := 1, source := [ 1 ], range := [ 1 ] ) );;
gap> gr1 = gr2; # Equal range
true
gap> gr1 := Digraph(
> rec( nrvertices := 3,
>      source := [ 1, 2, 2, 3, 3 ], range := [ 1, 1, 2, 2, 3 ] ) );;
gap> gr2 := Digraph(
> rec( nrvertices := 3,
>      source := [ 1, 2, 2, 3, 3 ], range := [ 1, 2, 2, 3, 2 ] ) );;
gap> gr1 = gr2; # Different contents of out[2]
false
gap> gr1 := Digraph(
> rec( nrvertices := 3,
>      source := [ 1, 2, 2, 3, 3 ], range := [ 1, 1, 2, 2, 3 ] ) );;
gap> gr2 := Digraph(
> rec( nrvertices := 3,
>      source := [ 1, 2, 2, 3, 3 ], range := [ 1, 2, 1, 3, 3 ] ) );;
gap> gr1 = gr2; # Different contents of out[3]
false
gap> gr1 := Digraph(
> rec( nrvertices := 3,
>      source := [ 1, 2, 2, 3, 3 ], range := [ 1, 1, 2, 2, 3 ] ) );;
gap> gr2 := Digraph(
> rec( nrvertices := 3,
>      source := [ 1, 2, 2, 3, 3 ], range := [ 1, 2, 1, 3, 2 ] ) );;
gap> gr1 = gr2; # out[2] and out[3] sorted differently
true
gap> s :=
> [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3,
>   3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6,
>   6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8,
>   8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 10, 10, 10 ];;
gap> r1 := 
> [ 10, 8, 4, 7, 6, 2, 9, 5, 3, 10, 9, 2, 1, 4, 7, 6, 8, 3, 6, 7, 9, 3,
>   10, 5, 2, 4, 1, 1, 7, 4, 8, 5, 3, 9, 10, 2, 9, 6, 10, 5, 8, 3, 4, 7,
>   3, 6, 10, 1, 7, 9, 5, 8, 4, 1, 9, 4, 10, 7, 8, 5, 2, 4, 10, 7, 6, 1,
>   2, 3, 8, 5, 6, 2, 7, 9, 3, 8, 5, 1, 4, 4, 3, 2, 10, 8, 7, 5, 6, 9 ];;
gap> r2 :=
> [ 3, 5, 9, 2, 7, 6, 4, 8, 10, 3, 8, 6, 7, 4, 1, 2, 9, 10, 1, 4, 2, 5,
>   10, 3, 9, 7, 6, 10, 9, 3, 5, 8, 4, 7, 1, 7, 4, 3, 8, 5, 10, 6, 9, 2,
>   4, 8, 5, 9, 7, 1, 10, 6, 3, 2, 5, 8, 7, 10, 4, 9, 1, 5, 8, 3, 2, 1, 6, 
>   7, 10, 4, 4, 1, 5, 8, 3, 9, 7, 2, 6, 9, 6, 5, 7, 8, 10, 2, 3, 4 ];;
gap> gr1 := Digraph( rec( nrvertices := 10, source := s, range := r1 ) );;
gap> gr2 := Digraph( rec( nrvertices := 10, source := s, range := r2 ) );;
gap> gr1 = gr2;
true

#T# Less than (<) for two digraphs
gap> gr1 := RandomMultiDigraph(10, 20);;
gap> gr2 := RandomMultiDigraph(11, 21);;
gap> gr1 < gr2; # Different NrVertices
true
gap> gr2 < gr1;
false
gap> gr2 := RandomMultiDigraph(10, 21);;
gap> gr1 < gr2; # Different NrEdges
true
gap> gr2 < gr1;
false
gap> error := false;; # Test lots randomly with equal vertices & edges
> for i in [ 1 .. 20 ] do
>   j := Random( [ 10 .. 100 ] );
>   k := Random( [ j .. j^2 ] );
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
gap> gr1 := Digraph( [ [ 1 ], [ 1, 1 ] ] );
<multidigraph with 2 vertices, 3 edges>
gap> gr2 := Digraph( [ [ 2, 2 ], [ 1 ] ] );
<multidigraph with 2 vertices, 3 edges>
gap> gr1 < gr2; #
true
gap> gr2 < gr1;
false
gap> gr1 := Digraph( [ [ 1 ], [ 1, 1 ] ] );
<multidigraph with 2 vertices, 3 edges>
gap> gr2 := Digraph( [ [ 1, 1 ], [ 2 ] ] );
<multidigraph with 2 vertices, 3 edges>
gap> gr1 < gr2; #
false
gap> gr2 < gr1;
true
gap> gr1 := Digraph( [ [ 2 ], [ 1, 2 ] ] );
<digraph with 2 vertices, 3 edges>
gap> gr2 := Digraph( [ [ 1, 2 ], [ 2 ] ] );
<digraph with 2 vertices, 3 edges>
gap> gr1 < gr2; #
false
gap> gr2 < gr1;
true
gap> gr1 := Digraph( [ [ 3 ], [  ], [ 2 ] ] );
<digraph with 3 vertices, 2 edges>
gap> gr2 := Digraph( [ [ 3 ], [  ], [ 2 ] ] );
<digraph with 3 vertices, 2 edges>
gap> gr1 < gr2;
false
gap> gr2 < gr1;
false
gap> gr1 = gr2;
true
gap> gr1 := Digraph( [ [ 3 ], [  ], [ 2 ] ] );
<digraph with 3 vertices, 2 edges>
gap> gr2 := Digraph( [ [ 3 ], [ 1 ], [  ] ] );
<digraph with 3 vertices, 2 edges>
gap> gr1 < gr2;
false
gap> gr2 < gr1;
true
gap> gr1 := Digraph( [ [ 3 ], [  ], [ 2, 3 ] ] );
<digraph with 3 vertices, 3 edges>
gap> gr2 := Digraph( [ [ 3 ], [  ], [ 3, 2 ] ] );
<digraph with 3 vertices, 3 edges>
gap> gr1 < gr2;
false
gap> gr2 < gr1;
false
gap> gr1 = gr2;
true
gap> gr1 := Digraph( [ [ 3 ], [  ], [ 2, 3 ] ] );
<digraph with 3 vertices, 3 edges>
gap> gr2 := Digraph( [ [ 3 ], [  ], [ 2, 3 ] ] );
<digraph with 3 vertices, 3 edges>
gap> gr1 < gr2;
false
gap> gr2 < gr1;
false
gap> gr1 = gr2;
true
gap> gr1 := Digraph( [ [ 3 ], [ 2 ], [ 1, 2 ] ] );
<digraph with 3 vertices, 4 edges>
gap> gr2 := Digraph( [ [ 3 ], [ 1, 2 ], [ 1 ] ] );
<digraph with 3 vertices, 4 edges>
gap> gr1 < gr2;
false
gap> gr2 < gr1;
true
gap> gr1 := Digraph( [ [ 3 ], [ 1 ], [ 1, 2 ] ] );
<digraph with 3 vertices, 4 edges>
gap> gr2 := Digraph( [ [ 3 ], [ 2, 3 ], [ 1 ] ] );
<digraph with 3 vertices, 4 edges>
gap> gr1 < gr2;
true
gap> gr2 < gr1;
false
gap> gr1 := Digraph([
>   [ 1, 2, 3 ], [ 15 ], [ 1, 11 ], [ 8, 14, 11, 15 ],
>   [ 10, 11, 10, 20, 15, 8, 16, 2 ], [ 11, 4 ], [ 11, 18 ], [ 6, 14 ],
>   [ 18, 7, 13 ], [ 5, 16, 5, 19 ], [ 13 ], [ 8, 18 ], [ 12 ], [ 5 ],
>   [ 5, 4, 7, 19, 13 ], [ 15 ], [ 17, 19, 3 ], [ 9 ], [ 4, 12, 14 ], [ 3 ]
> ] );
<multidigraph with 20 vertices, 50 edges>
gap> gr2 := Digraph( [
>   [ 1, 2, 3 ], [ 15 ], [ 1, 11 ], [ 8, 14, 11, 15 ],
>   [ 10, 11, 10, 20, 15, 8, 16, 2 ], [ 11, 4 ], [ 11, 18 ], [ 6, 14 ],
>   [ 18, 7, 13 ], [ 5, 16, 5, 19 ], [ 13 ], [ 8, 18, 12 ], [  ], [ 5 ],
>   [ 5, 4, 7, 19, 13 ], [ 15 ], [ 17, 19, 3 ], [ 9 ], [ 4, 12, 14 ], [ 3 ]
> ] );
<multidigraph with 20 vertices, 50 edges>
gap> gr1 = gr2;
false
gap> gr1 < gr2;
false
gap> gr2 < gr1;
true

#T# ReducedDigraph
gap> gr := EmptyDigraph(0);;
gap> ReducedDigraph(gr) = gr;
true
gap> gr := Digraph( [ [ 2, 4, 2, 6, 1 ], [  ], [  ], [ 2, 1, 4 ], [  ],
> [ 1, 7, 7, 7 ], [ 4, 6 ] ] );
<multidigraph with 7 vertices, 14 edges>
gap> rd := ReducedDigraph(gr);
<multidigraph with 5 vertices, 14 edges>
gap> DigraphEdgeLabels(rd) = DigraphEdgeLabels(gr);
true
gap> DigraphVertexLabels(rd);
[ 1, 4, 6, 7, 2 ]
gap> gr := CompleteDigraph(10);
<digraph with 10 vertices, 90 edges>
gap> rd := ReducedDigraph(gr);
<digraph with 10 vertices, 90 edges>
gap> rd = gr;
true
gap> DigraphVertexLabels(gr) = DigraphVertexLabels(rd);
true
gap> gr := Digraph( [ [  ], [ 4, 2 ], [  ], [ 3 ] ] );
<digraph with 4 vertices, 3 edges>
gap> SetDigraphVertexLabels(gr, [ "one", "two", "three", "four" ]);
gap> rd := ReducedDigraph(gr);
<digraph with 3 vertices, 3 edges>
gap> DigraphVertexLabels(gr);
[ "one", "two", "three", "four" ]
gap> DigraphVertexLabels(rd);
[ "two", "four", "three" ]

#E#
gap> STOP_TEST( "Graphs package: digraph.tst");
