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
gap> gr := RandomDigraph(10);;
gap> DigraphVertexNames(gr);
[ 1 .. 10 ]
gap> SetDigraphVertexNames( gr, [ "a", "b", 10 ] );
Error, Digraphs: SetDigraphVertexNames: usage,
the 2nd arument <names> must be a list with length equal to the number of
vertices of the digraph,
gap> gr := RandomDigraph(3);;
gap> SetDigraphVertexNames( gr, [ "a", "b", 10 ] );
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
gap> gr := RandomDigraph(5);;
gap> SetDigraphVertexName(gr, 6, (1,3,2,5,4));
Error, Digraphs: SetDigraphVertexName: usage,
there are only 5 vertices,
gap> SetDigraphVertexName(gr, 2, (1,3,2,5,4));
gap> DigraphVertexName(gr, 2);
(1,3,2,5,4)
gap> gr := RandomDigraph(3);;
gap> DigraphVertexName(gr, 2);
2
gap> gr := RandomDigraph(10);;
gap> gr := InducedSubdigraph( gr, [ 1, 2, 3, 5, 7 ] );;
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

# Digraph (for an integer and a function)
gap> divides := function(a, b)
>   if b mod a = 0 then
>     return true;
>   fi;
>   return false;
> end;;
gap> gr := Digraph( 12, divides );
<digraph with 12 vertices, 35 edges>

# Digraph (for a binary relation)
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
Error, Digraphs: Digraph: usage,
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
Error, Digraphs: Digraph: usage,
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

# RandomDigraph
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
Error, Digraphs: RandomDigraph: usage,
the second argument <p> must be a float between 0 and 1,
gap> RandomDigraph(10, -0.01);
Error, Digraphs: RandomDigraph: usage,
the second argument <p> must be a float between 0 and 1,

# RandomMultiDigraph
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

# RandomTournament
gap> RandomTournament(25);
<digraph with 25 vertices, 300 edges>
gap> RandomTournament(0);
<digraph with 0 vertices, 0 edges>
gap> RandomTournament(-1);
Error, Digraphs: RandomTournament: usage,
the argument <n> must be a non-negative integer,

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

# CycleDigraph
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

# CompleteBipartiteDigraph
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

# \= for digraph with out-neighbours, and digraph with range 
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

# \= for 2 digraphs with out-neighbours
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

# \= for 2 digraphs with source and range
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

#
gap> DigraphsStopTest();

#
gap> STOP_TEST( "Digraphs package: digraph.tst", 0);
