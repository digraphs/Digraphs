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

# DigraphByEdges
gap> gr := Digraph( [ [ 1, 2, 3, 5 ], [ 1, 5 ], [ 2, 3, 6 ], [ 1, 3, 4 ], 
> [ 1, 4, 6 ], [ 3, 4 ] ] );
<digraph with 6 vertices, 17 edges>
gap> gr = DigraphByEdges(Edges(gr));
true
gap> DigraphByEdges([["nonsense", "more"]]);
Error, usage: the argument <edges> must be a list of pairs of pos ints,
gap> DigraphByEdges([["nonsense"]]);
Error, usage: the argument <edges> must be a list of pairs,
gap> gr := DigraphByEdges(Edges(gr), 10);
<digraph with 10 vertices, 17 edges>
gap> gr := DigraphByEdges( [ [ 1, 2 ] ] );
<digraph with 2 vertices, 1 edges>
gap> gr := DigraphByEdges( [ [ 2, 1 ] ] );
<digraph with 2 vertices, 1 edges>
gap> gr := DigraphByEdges( [ [ 1, 2 ] ], 1 ); 
Error, DigraphByEdges: usage, the specified edges must not contain values grea\
ter than 1

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
gap> AsDigraph(g, 10);
<digraph with 10 vertices, 10 edges>
gap> h := Transformation( [ 2, 4, 1, 3, 5 ] );
Transformation( [ 2, 4, 1, 3 ] )
gap> AsDigraph(h);
<digraph with 4 vertices, 4 edges>

# DigraphByAdjacencyMatrix
gap> mat := [
> [ 0, 2, 0, 0, 1 ],
> [ 0, 2, 1, 0, 1 ],
> [ 0, 0, 0, 0, 1 ],
> [ 1, 0, 1, 1, 0 ],
> [ 0, 0, 3, 0, 0 ] ];;
gap> gr := DigraphByAdjacencyMatrix(mat);
<digraph with 5 vertices, 14 edges>
gap> grnc := DigraphByAdjacencyMatrixNC(mat);
<digraph with 5 vertices, 14 edges>
gap> gr = grnc;
true
gap> IsStronglyConnectedDigraph(gr);
false
gap> IsSimpleDigraph(gr);
false
gap> Adjacencies(gr);
[ [ 2, 5 ], [ 2, 3, 5 ], [ 5 ], [ 1, 3, 4 ], [ 3 ] ]
gap> Adjacencies(grnc) = last;
true
gap> mat := [
> [ 0, 0, 0, 10, 1, 0, 0, 1, 0, 0 ],
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
<digraph with 10 vertices, 74 edges>
gap> IsStronglyConnectedDigraph(gr);
true
gap> IsSimpleDigraph(gr);
false
gap> Adjacencies(gr);
[ [ 4, 5, 8 ], [ 2, 4, 5, 6, 8, 9 ], [ 2, 4, 5, 7, 10 ], [ 9 ], 
  [ 1, 4, 6, 7, 9 ], [ 2, 3, 6, 7, 10 ], [ 3, 4, 5, 8, 9 ], 
  [ 3, 4, 8, 9, 10 ], [ 1, 2, 3, 5, 6, 9, 10 ], [ 2, 3, 4, 5, 6, 9 ] ]
gap> r := rec( nrvertices:= 10, source := ShallowCopy(Source(gr)),
> range := ShallowCopy(Range(gr)) );;
gap> gr2 := Digraph(r);
<digraph with 10 vertices, 74 edges>
gap> HasAdjacencyMatrix(gr2);
false
gap> AdjacencyMatrix(gr2) = mat;
true

# Display
gap> gr := Digraph( [ [ 1, 2 ], [ 2 ], [ ] ] );
<digraph with 3 vertices, 3 edges>
gap> PrintString(gr);
"Digraph( [ [ 1, 2 ], [ 2 ], [ ] ] )"
gap> String(gr);
"Digraph( [ [ 1, 2 ], [ 2 ], [ ] ] )"

#
gap> DigraphsStopTest();

#
gap> STOP_TEST( "Digraphs package: digraph.tst", 0);
