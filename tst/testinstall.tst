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
gap> DigraphsStartTest();

# conversion to and from Grape graphs
gap> gr:=DirectedGraph( 
> [ [ 8 ], [ 4, 5, 6, 8, 9 ], [ 2, 4, 5, 7, 10 ], [ 9 ], 
> [ 1, 4, 6, 7, 9 ], [ 2, 3, 6, 7, 10 ], [ 3, 4, 5, 8, 9 ], 
> [ 3, 4, 9, 10 ], [ 1, 2, 3, 5, 6, 9, 10 ], [ 2, 4, 5, 6, 9 ] ] );
<directed graph with 10 vertices, 43 edges>
gap> Graph(gr);
rec( adjacencies := [ [ 8 ], [ 4, 5, 6, 8, 9 ], [ 2, 4, 5, 7, 10 ], [ 9 ], 
      [ 1, 4, 6, 7, 9 ], [ 2, 3, 6, 7, 10 ], [ 3, 4, 5, 8, 9 ], 
      [ 3, 4, 9, 10 ], [ 1, 2, 3, 5, 6, 9, 10 ], [ 2, 4, 5, 6, 9 ] ], 
  group := Group(()), isGraph := true, names := [ 1 .. 10 ], order := 10, 
  representatives := [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ], 
  schreierVector := [ -1, -2, -3, -4, -5, -6, -7, -8, -9, -10 ] )
gap> Adjacencies(gr);
[ [ 8 ], [ 4, 5, 6, 8, 9 ], [ 2, 4, 5, 7, 10 ], [ 9 ], [ 1, 4, 6, 7, 9 ], 
  [ 2, 3, 6, 7, 10 ], [ 3, 4, 5, 8, 9 ], [ 3, 4, 9, 10 ], 
  [ 1, 2, 3, 5, 6, 9, 10 ], [ 2, 4, 5, 6, 9 ] ]
gap> DirectedGraph(Graph(gr))=gr;
true
gap> Graph(DirectedGraph(Graph(gr)))=Graph(gr);
true
gap> S:=Semigroup( [ Transformation( [ 1, 5, 5, 5, 4 ] ), 
> Transformation( [ 2, 3, 3 ] ), Transformation( [ 3, 5, 3, 2, 4 ] ), 
> Transformation( [ 4, 4, 2, 5, 3 ] ), Transformation( [ 4, 5, 3, 2, 4 ] ) ] );;
gap> D:=DClass(S, Transformation( [ 2, 2, 2 ] ));;
gap> R:=PrincipalFactor(D);
<Rees 0-matrix semigroup 16x4 over Group([ (2,5,4), (2,4) ])>
gap> RZMSGraph(R);
rec( adjacencies := [ [ 17, 19 ], [ 17, 20 ], [ 17, 18 ], [ 17, 20 ], 
      [ 17, 18 ], [ 18, 19 ], [ 18, 20 ], [ 17, 19 ], [ 19, 20 ], [ 17, 20 ], 
      [ 19, 20 ], [ 18, 19 ], [ 19, 20 ], [ 17, 19 ], [ 18, 20 ], [ 18, 20 ], 
      [ 1, 2, 3, 4, 5, 8, 10, 14 ], [ 3, 5, 6, 7, 12, 15, 16 ], 
      [ 1, 6, 8, 9, 11, 12, 13, 14 ], [ 2, 4, 7, 9, 10, 11, 13, 15, 16 ] ], 
  group := Group(()), isGraph := true, names := [ 1 .. 20 ], order := 20, 
  representatives := [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20 ], 
  schreierVector := [ -1, -2, -3, -4, -5, -6, -7, -8, -9, -10, -11, -12, -13, 
      -14, -15, -16, -17, -18, -19, -20 ] )
gap> DirectedGraph(last);
<directed graph with 20 vertices, 64 edges>

# IsAcyclicDirectedGraph
gap> gr:=DirectedGraph([
>  [ 1, 2, 4, 10 ], [ 3, 15 ], [ 3, 15 ], [ 1, 3, 7, 8, 9, 11, 12, 13 ], 
>  [ 4, 8 ], [ 1, 2, 4, 5, 6, 7, 8, 10, 14, 15 ], [ 3, 4, 6, 11, 13, 15 ], 
>  [ 3, 5, 6, 7, 8, 9, 10, 15 ], [ 2, 5, 6, 7, 8, 9, 10, 11, 12 ], 
>  [ 2, 3, 10, 11, 14 ], [ 3, 5, 14, 15 ], [ 7, 9, 10, 14, 15 ], 
>  [ 1, 4, 7, 8, 10, 14, 15 ], [ 1, 2, 4, 7, 13, 14, 15 ], 
>  [ 1, 2, 3, 9, 10, 11, 12, 13, 14, 15 ] ]);
<directed graph with 15 vertices, 89 edges>
gap> IsSimpleDirectedGraph(gr);
true
gap> IsAcyclicDirectedGraph(gr);
false
gap> r:=rec(vertices:=[1..10000],source:=[],range:=[]);;
gap> for i in [1..9999] do
>    Add(r.source, i);
>    Add(r.range, i+1);
>  od;
gap> Add(r.source, 10000);; Add(r.range, 1);;
gap> gr:=DirectedGraph(r);
<directed graph with 10000 vertices, 10000 edges>
gap> IsAcyclicDirectedGraph(gr);
false
gap> gr:=DirectedGraphRemoveEdges(gr, [10000]);
<directed graph with 10000 vertices, 9999 edges>
gap> IsAcyclicDirectedGraph(gr);
true
gap> gr:=DirectedGraph( [ [ 2, 3 ], [ 4, 5 ], [ 5, 6 ], [], [], [], [ 3 ] ] );
<directed graph with 7 vertices, 7 edges>
gap> IsDirectedGraph(gr);
true

# check if Adjacencies can handle non-plists in source, range.
gap> gr:=DirectedGraph(rec( vertices:=[1..1000],
>                           source:=[1..1000],
>                           range:=Concatenation([2..1000],[1])));;
gap> Adjacencies(gr);;

#
gap> DigraphsStopTest();

#
gap> STOP_TEST( "Digraphs package: testinstall.tst", 0);
