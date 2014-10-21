#############################################################################
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

# Names
gap> gr:=RandomDigraph(10);;
gap> DigraphVertexNames(gr);
[ 1 .. 10 ]
gap> SetDigraphVertexNames(gr, ["a", "b", 10]);
Error, Digraphs: SetDigraphVertexNames: usage,
the 2nd arument <names> must be a list with length equal to the number of
vertices of the digraph,

gap> gr:=RandomDigraph(3);;
gap> SetDigraphVertexNames(gr, ["a", "b", 10]);
gap> DigraphVertexNames(gr);
[ "a", "b", 10 ]
gap> DigraphVertexName(gr, 1);
"a"
gap> DigraphVertexName(gr, 2);
"b"
gap> DigraphVertexName(gr, 10);
Error, Digraphs: DigraphVertexName: usage,
10 is nameless or not a vertex,

gap> DigraphVertexName(gr, 3);
10
gap> SetDigraphVertexName(gr, 3, 3);
gap> DigraphVertexName(gr, 3);
3
gap> gr:=RandomDigraph(10);;
gap> gr:=InducedSubdigraph(gr, [1,2,3,5,7]);;
gap> DigraphVertexNames(gr);
[ 1, 2, 3, 5, 7 ]
gap> DigraphVertices(gr);
[ 1 .. 5 ]

# Graph
gap> gr := Digraph( [ [ 2, 2 ], [ ] ] );
<multidigraph with 2 vertices, 2 edges>
gap> Graph(gr);
rec( adjacencies := [ [ 2 ], [  ] ], group := Group(()), isGraph := true, 
  names := [ 1, 2 ], order := 2, representatives := [ 1, 2 ], 
  schreierVector := [ -1, -2 ] )

# Digraph (by list of OutNeighbours)
gap> Digraph( [ [ 0, 1 ] ] );
Error, Digraphs: Digraph: usage,
the argument must be a list of lists of positive integers
not exceeding the length of the argument,

gap> Digraph( [ [ 2 ], [ 3 ] ] );
Error, Digraphs: Digraph: usage,
the argument must be a list of lists of positive integers
not exceeding the length of the argument,


# Digraph (by record)
gap> n := 3;;
gap> v := [ 1 .. 3 ];;
gap> s := [ 1, 2, 3 ];;
gap> r := [ 3, 1, 2 ];;
gap> Digraph( rec( nrvertices := n, source := s ) );
Error, Digraphs: Digraph: usage,
the argument must be a record with components:
'source', 'range', and either 'vertices' or 'nrvertices',

gap> Digraph( rec( nrvertices := n, range := r ) );
Error, Digraphs: Digraph: usage,
the argument must be a record with components:
'source', 'range', and either 'vertices' or 'nrvertices',

gap> Digraph( rec( nrvertices := n, source := s, vertices := v ) );
Error, Digraphs: Digraph: usage,
the argument must be a record with components:
'source', 'range', and either 'vertices' or 'nrvertices',

gap> Digraph( rec( nrvertices := n, range := r, vertices := v ) );
Error, Digraphs: Digraph: usage,
the argument must be a record with components:
'source', 'range', and either 'vertices' or 'nrvertices',

gap> Digraph( rec( source := s, range := r ) );
Error, Digraphs: Digraph: usage,
the argument must be a record with components:
'source', 'range', and either 'vertices' or 'nrvertices',

gap> Digraph( rec( nrvertices := n, source := s, range := 4 ) );
Error, Digraphs: Digraph: usage,
the graph components 'source' and 'range' should be lists,

gap> Digraph( rec( nrvertices := n, source := 1, range := r ) );
Error, Digraphs: Digraph: usage,
the graph components 'source' and 'range' should be lists,

gap> Digraph( rec( nrvertices := n, source := [ 1, 2 ], range := r ) );
Error, Digraphs: Digraph: usage,
the record components 'source' and 'range' should have equal length,

gap> Digraph( rec( nrvertices := "a", source := s, range := r ) );
Error, Digraphs: Digraph: usage,
the record component 'nrvertices' should be a non-negative integer,

gap> Digraph( rec( nrvertices := -3, source := s, range := r ) );
Error, Digraphs: Digraph: usage,
the record component 'nrvertices' should be a non-negative integer,

gap> Digraph(
> rec( nrvertices := 2, vertices := [ 1 .. 3 ], source := [ 2 ], range := [ 2 ] ) );
Error, Digraphs: Digraph: usage,
the record components 'nrvertices' and 'vertices' are inconsistent,

gap> Digraph( rec( nrvertices := n, source := [ 0 .. 2 ], range := r ) );
Error, Digraphs: Digraph: usage,
the record component 'source' is invalid,

gap> Digraph( rec( nrvertices := n, source := [ 2 .. 4 ], range := r ) );
Error, Digraphs: Digraph: usage,
the record component 'source' is invalid,

gap> Digraph( rec( vertices := 2, source := s, range := r ) );
Error, Digraphs: Digraph: usage,
the record component 'vertices' should be a list,

gap> Digraph( rec( nrvertices := n, source := [ 1, 2, 4 ], range := r ) );
Error, Digraphs: Digraph: usage,
the record component 'source' is invalid,

gap> Digraph( rec( vertices := v, source := [ 1, 2, 4 ], range := r ) );
Error, Digraphs: Digraph: usage,
the record component 'source' is invalid,

gap> Digraph( rec( nrvertices := n, source := s, range := [ 1, 4, 2 ] ) );
Error, Digraphs: Digraph: usage,
the record component 'range' is invalid,

gap> Digraph( rec( vertices := v, source := s, range := [ 1, 4, 2 ] ) );
Error, Digraphs: Digraph: usage,
the record component 'range' is invalid,

gap> Digraph( rec( vertices := "abc", source := "acbab", range := "cbabb" ) );
<digraph with 3 vertices, 5 edges>

# RandomDigraph
gap> DigraphNrVertices(RandomDigraph(10));
10

# DigraphByEdges
gap> gr := Digraph( [ [ 1, 2, 3, 5 ], [ 1, 5 ], [ 2, 3, 6 ], [ 1, 3, 4 ], 
> [ 1, 4, 6 ], [ 3, 4 ] ] );
<digraph with 6 vertices, 17 edges>
gap> gr = DigraphByEdges(DigraphEdges(gr));
true
gap> DigraphByEdges( [ [ "nonsense", "more" ] ] );
Error, Digraphs: DigraphByEdges: usage,
the argument <edges> must be a list of pairs of pos ints,

gap> DigraphByEdges( [ [ "nonsense" ] ] );
Error, Digraphs: DigraphByEdges: usage,
the argument <edges> must be a list of pairs,

gap> DigraphByEdges( [[  "a", "b" ] ], 2 );
Error, Digraphs: DigraphByEdges: usage,
the argument <edges> must be a list of pairs of pos ints,

gap> DigraphByEdges( [ [ 1, 2, 3 ] ], 3 );
Error, Digraphs: DigraphByEdges: usage,
the argument <edges> must be a list of pairs,

gap> gr := DigraphByEdges(DigraphEdges(gr), 10);
<digraph with 10 vertices, 17 edges>
gap> gr := DigraphByEdges( [ [ 1, 2 ] ] );
<digraph with 2 vertices, 1 edge>
gap> gr := DigraphByEdges( [ [ 2, 1 ] ] );
<digraph with 2 vertices, 1 edge>
gap> gr := DigraphByEdges( [ [ 1, 2 ] ], 1 ); 
Error, Digraphs: DigraphByEdges: usage,
the specified edges must not contain values greater than 1,


# AsDigraph
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
Error, Digraphs: AsDigraph: usage,
the second argument should be a non-negative integer,

gap> AsDigraph(g, 10);
<digraph with 10 vertices, 10 edges>
gap> h := Transformation( [ 2, 4, 1, 3, 5 ] );
Transformation( [ 2, 4, 1, 3 ] )
gap> AsDigraph(h);
<digraph with 4 vertices, 4 edges>

# DigraphByAdjacencyMatrix
gap> mat := [
> [ 1, 2, 3 ],
> [ 1, 2, 3 ] ];;
gap> DigraphByAdjacencyMatrix(mat);
Error, Digraphs: DigraphByAdjacencyMatrix: usage,
the matrix is not square,

gap> mat := [
> [ 11, 2, 3 ],
> [ 11, 2, 3 ],
> [ -1, 2, 2 ] ];;
gap> DigraphByAdjacencyMatrix(mat);
Error, Digraphs: DigraphByAdjacencyMatrix: usage,
the argument must be a matrix of non-negative integers,

gap> mat := [ [ "a" ] ];;
gap> DigraphByAdjacencyMatrix(mat);
Error, Digraphs: DigraphByAdjacencyMatrix: usage,
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

# CompleteDigraph
gap> gr := CompleteDigraph(5);
<digraph with 5 vertices, 25 edges>
gap> CompleteDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> CompleteDigraph(-1);
Error, Digraphs: CompleteDigraph: usage,
the argument <n> must be a non-negative integer,


# EmptyDigraph
gap> gr := EmptyDigraph(5);
<digraph with 5 vertices, 0 edges>
gap> EmptyDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> EmptyDigraph(-1);
Error, Digraphs: EmptyDigraph: usage,
the argument <n> must be a non-negative integer,


# Equals (= \=)
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

# Issue #2
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

#
gap> DigraphsStopTest();

#
gap> STOP_TEST( "Digraphs package: digraph.tst", 0);
