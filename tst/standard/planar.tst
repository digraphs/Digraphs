#############################################################################
##
#W  standard/planar.tst
#Y  Copyright (C) 2018                                   James D. Mitchell
##                       
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/planar.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

# IsPlanarDigraph
gap> D := NullDigraph(0);
<immutable empty digraph with 0 vertices>
gap> IsPlanarDigraph(D);
true
gap> D := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> IsPlanarDigraph(D);
true
gap> D := CompleteDigraph(5);
<immutable complete digraph with 5 vertices>
gap> IsPlanarDigraph(D);
false
gap> D := Digraph([[2, 4, 7, 9, 10], [1, 3, 4, 6, 9, 10], [6, 10], 
> [2, 5, 8, 9], [1, 2, 3, 4, 6, 7, 9, 10], [3, 4, 5, 7, 9, 10], 
> [3, 4, 5, 6, 9, 10], [3, 4, 5, 7, 9], [2, 3, 5, 6, 7, 8], [3, 5]]);
<immutable digraph with 10 vertices, 50 edges>
gap> ChromaticNumber(D);
5
gap> IsPlanarDigraph(D);
false
gap> D := CompleteBipartiteDigraph(3, 3);
<immutable complete bipartite digraph with bicomponent sizes 3 and 3>
gap> D := DigraphDisjointUnion(D, D);
<immutable digraph with 12 vertices, 36 edges>
gap> IsPlanarDigraph(D);
false

# IsOuterPlanarDigraph
gap> D := Digraph([[2, 4, 7, 9, 10], [1, 3, 4, 6, 9, 10], [6, 10], 
> [2, 5, 8, 9], [1, 2, 3, 4, 6, 7, 9, 10], [3, 4, 5, 7, 9, 10], 
> [3, 4, 5, 6, 9, 10], [3, 4, 5, 7, 9], [2, 3, 5, 6, 7, 8], [3, 5]]);
<immutable digraph with 10 vertices, 50 edges>
gap> ChromaticNumber(D);
5
gap> IsPlanarDigraph(D);
false
gap> IsOuterPlanarDigraph(D);
false
gap> D := NullDigraph(0);
<immutable empty digraph with 0 vertices>
gap> IsOuterPlanarDigraph(D);
true
gap> D := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> IsOuterPlanarDigraph(D);
false
gap> D := CompleteDigraph(4);
<immutable complete digraph with 4 vertices>
gap> ChromaticNumber(D);
4
gap> IsOuterPlanarDigraph(D);
false
gap> D := Digraph([[3, 5, 10], [8, 9, 10], [1, 4], [3, 6], [1, 7, 11], [4, 7],
> [6, 8], [2, 7], [2, 11], [1, 2], [5, 9]]);
<immutable digraph with 11 vertices, 25 edges>
gap> IsOuterPlanarDigraph(D);
false
gap> IsPlanarDigraph(D);
true

# PlanarEmbedding
gap> D := Digraph([[3, 5, 10], [8, 9, 10], [1, 4], [3, 6], [1, 7, 11], [4, 7],
> [6, 8], [2, 7], [2, 11], [1, 2], [5, 9]]);
<immutable digraph with 11 vertices, 25 edges>
gap> PlanarEmbedding(D);
[ [ 3, 10, 5 ], [ 10, 8, 9 ], [ 4, 1 ], [ 6, 3 ], [ 1, 11, 7 ], [ 7, 4 ], 
  [ 8, 6 ], [ 7, 2 ], [ 2, 11 ], [ 1, 2 ], [ 9, 5 ] ]
gap> D := Digraph([[2, 4, 7, 9, 10], [1, 3, 4, 6, 9, 10], [6, 10], 
> [2, 5, 8, 9], [1, 2, 3, 4, 6, 7, 9, 10], [3, 4, 5, 7, 9, 10], 
> [3, 4, 5, 6, 9, 10], [3, 4, 5, 7, 9], [2, 3, 5, 6, 7, 8], [3, 5]]);
<immutable digraph with 10 vertices, 50 edges>
gap> IsPlanarDigraph(D);
false
gap> PlanarEmbedding(D);
fail
gap> D := NullDigraph(0);
<immutable empty digraph with 0 vertices>
gap> PlanarEmbedding(D);
[  ]
gap> D := List(["D??", "D?_", "D?o", "D?w", "D?{", "DCO", "DCW", "DCc", "DCo",
> "DCs", "DCw", "DC{", "DEk", "DEo", "DEs", "DEw", "DE{", "DFw", "DF{", "DQg",
> "DQo", "DQw", "DQ{", "DTk", "DTw", "DT{", "DUW", "DUw", "DU{", "DV{", "D]w",
> "D]{", "D^{", "D~{"], DigraphFromGraph6String);;
gap> List(D, PlanarEmbedding);
[ [ [  ], [  ], [  ], [  ], [  ] ], [ [ 5 ], [  ], [  ], [  ], [ 1 ] ], 
  [ [ 5 ], [ 5 ], [  ], [  ], [ 1, 2 ] ], 
  [ [ 5 ], [ 5 ], [ 5 ], [  ], [ 1, 2, 3 ] ], 
  [ [ 5 ], [ 5 ], [ 5 ], [ 5 ], [ 1, 2, 3, 4 ] ], 
  [ [ 4 ], [ 5 ], [  ], [ 1 ], [ 2 ] ], 
  [ [ 4 ], [ 5 ], [ 5 ], [ 1 ], [ 2, 3 ] ], 
  [ [ 4, 5 ], [  ], [  ], [ 5, 1 ], [ 1, 4 ] ], 
  [ [ 4, 5 ], [ 5 ], [  ], [ 1 ], [ 1, 2 ] ], 
  [ [ 4, 5 ], [ 5 ], [  ], [ 5, 1 ], [ 1, 4, 2 ] ], 
  [ [ 4, 5 ], [ 5 ], [ 5 ], [ 1 ], [ 1, 2, 3 ] ], 
  [ [ 4, 5 ], [ 5 ], [ 5 ], [ 5, 1 ], [ 1, 4, 2, 3 ] ], 
  [ [ 4, 5 ], [ 4 ], [ 5 ], [ 5, 1, 2 ], [ 1, 4, 3 ] ], 
  [ [ 4, 5 ], [ 5, 4 ], [  ], [ 2, 1 ], [ 1, 2 ] ], 
  [ [ 4, 5 ], [ 5, 4 ], [  ], [ 2, 5, 1 ], [ 1, 4, 2 ] ], 
  [ [ 4, 5 ], [ 5, 4 ], [ 5 ], [ 2, 1 ], [ 1, 2, 3 ] ], 
  [ [ 4, 5 ], [ 5, 4 ], [ 5 ], [ 2, 5, 1 ], [ 1, 4, 2, 3 ] ], 
  [ [ 4, 5 ], [ 5, 4 ], [ 4, 5 ], [ 2, 3, 1 ], [ 1, 3, 2 ] ], 
  [ [ 4, 5 ], [ 5, 4 ], [ 4, 5 ], [ 2, 5, 3, 1 ], [ 1, 3, 4, 2 ] ], 
  [ [ 3, 5 ], [ 4 ], [ 5, 1 ], [ 2 ], [ 1, 3 ] ], 
  [ [ 3, 5 ], [ 5, 4 ], [ 1 ], [ 2 ], [ 1, 2 ] ], 
  [ [ 3, 5 ], [ 5, 4 ], [ 5, 1 ], [ 2 ], [ 1, 3, 2 ] ], 
  [ [ 3, 5 ], [ 4, 5 ], [ 5, 1 ], [ 5, 2 ], [ 1, 3, 2, 4 ] ], 
  [ [ 4, 5, 3 ], [  ], [ 1, 5, 4 ], [ 3, 5, 1 ], [ 1, 4, 3 ] ], 
  [ [ 4, 3, 5 ], [ 5 ], [ 5, 1, 4 ], [ 3, 1 ], [ 1, 3, 2 ] ], 
  [ [ 4, 5, 3 ], [ 5 ], [ 1, 5, 4 ], [ 3, 5, 1 ], [ 1, 4, 3, 2 ] ], 
  [ [ 4, 3 ], [ 5, 4 ], [ 1, 5 ], [ 2, 1 ], [ 3, 2 ] ], 
  [ [ 4, 5, 3 ], [ 5, 4 ], [ 1, 5 ], [ 2, 1 ], [ 3, 1, 2 ] ], 
  [ [ 4, 5, 3 ], [ 5, 4 ], [ 1, 5 ], [ 2, 5, 1 ], [ 3, 1, 4, 2 ] ], 
  [ [ 4, 3, 5 ], [ 5, 4 ], [ 1, 4, 5 ], [ 2, 5, 3, 1 ], [ 1, 3, 4, 2 ] ], 
  [ [ 4, 5, 3 ], [ 3, 5, 4 ], [ 1, 5, 2 ], [ 2, 1 ], [ 1, 2, 3 ] ], 
  [ [ 4, 5, 3 ], [ 3, 5, 4 ], [ 1, 5, 2 ], [ 2, 5, 1 ], [ 1, 4, 2, 3 ] ], 
  [ [ 4, 5, 3 ], [ 3, 5, 4 ], [ 1, 5, 2, 4 ], [ 3, 2, 5, 1 ], [ 1, 4, 2, 3 ] ]
    , fail ]

# OuterPlanarEmbedding
gap> D := Digraph([[3, 5, 10], [8, 9, 10], [1, 4], [3, 6], [1, 7, 11], [4, 7],
> [6, 8], [2, 7], [2, 11], [1, 2], [5, 9]]);
<immutable digraph with 11 vertices, 25 edges>
gap> OuterPlanarEmbedding(D);
fail
gap> D := Digraph([[2, 4, 7, 9, 10], [1, 3, 4, 6, 9, 10], [6, 10], 
> [2, 5, 8, 9], [1, 2, 3, 4, 6, 7, 9, 10], [3, 4, 5, 7, 9, 10], 
> [3, 4, 5, 6, 9, 10], [3, 4, 5, 7, 9], [2, 3, 5, 6, 7, 8], [3, 5]]);
<immutable digraph with 10 vertices, 50 edges>
gap> IsOuterPlanarDigraph(D);
false
gap> OuterPlanarEmbedding(D);
fail
gap> D := NullDigraph(0);
<immutable empty digraph with 0 vertices>
gap> OuterPlanarEmbedding(D);
[  ]
gap> D := CompleteDigraph(3);
<immutable complete digraph with 3 vertices>
gap> OuterPlanarEmbedding(D);
[ [ 2, 3 ], [ 3, 1 ], [ 1, 2 ] ]

# SubdigraphHomeomorphicToK23/33/4
gap> D := Digraph([[3, 5, 10], [8, 9, 10], [1, 4], [3, 6], [1, 7, 11], [4, 7],
> [6, 8], [2, 7], [2, 11], [1, 2], [5, 9]]);
<immutable digraph with 11 vertices, 25 edges>
gap> SubdigraphHomeomorphicToK4(D);
[ [ 3, 5, 10 ], [ 9, 8, 10 ], [ 4, 1 ], [ 6, 3 ], [ 1, 7, 11 ], [ 7, 4 ], 
  [ 8, 6 ], [ 2, 7 ], [ 11, 2 ], [ 2, 1 ], [ 5, 9 ] ]
gap> SubdigraphHomeomorphicToK23(D);
[ [ 3, 5, 10 ], [ 9, 8, 10 ], [ 4, 1 ], [ 6, 3 ], [ 1, 11 ], [ 7, 4 ], 
  [ 8, 6 ], [ 2, 7 ], [ 11, 2 ], [ 2, 1 ], [ 5, 9 ] ]
gap> D := Digraph([[3, 5, 10], [8, 9, 10], [1, 4], [3, 6], [1, 11], [4, 7],
> [6, 8], [2, 7], [2, 11], [1, 2], [5, 9]]);
<immutable digraph with 11 vertices, 24 edges>
gap> SubdigraphHomeomorphicToK4(D);
fail
gap> SubdigraphHomeomorphicToK23(D);
[ [ 3, 10, 5 ], [ 10, 8, 9 ], [ 4, 1 ], [ 6, 3 ], [ 11, 1 ], [ 7, 4 ], 
  [ 8, 6 ], [ 2, 7 ], [ 2, 11 ], [ 1, 2 ], [ 9, 5 ] ]
gap> SubdigraphHomeomorphicToK33(D);
fail
gap> SubdigraphHomeomorphicToK23(NullDigraph(0));
fail
gap> SubdigraphHomeomorphicToK33(CompleteDigraph(5));
fail
gap> SubdigraphHomeomorphicToK33(CompleteBipartiteDigraph(3, 3));
[ [ 4, 6, 5 ], [ 4, 5, 6 ], [ 6, 5, 4 ], [ 1, 2, 3 ], [ 3, 2, 1 ], 
  [ 2, 3, 1 ] ]
gap> SubdigraphHomeomorphicToK4(CompleteDigraph(3));
fail

# KuratowskiPlanarSubdigraph
gap> D := Digraph([[3, 5, 10], [8, 9, 10], [1, 4], [3, 6], [1, 7, 11], [4, 7],
> [6, 8], [2, 7], [2, 11], [1, 2], [5, 9]]);
<immutable digraph with 11 vertices, 25 edges>
gap> KuratowskiPlanarSubdigraph(D);
fail
gap> D := Digraph([[2, 4, 7, 9, 10], [1, 3, 4, 6, 9, 10], [6, 10], 
> [2, 5, 8, 9], [1, 2, 3, 4, 6, 7, 9, 10], [3, 4, 5, 7, 9, 10], 
> [3, 4, 5, 6, 9, 10], [3, 4, 5, 7, 9], [2, 3, 5, 6, 7, 8], [3, 5]]);
<immutable digraph with 10 vertices, 50 edges>
gap> IsPlanarDigraph(D);
false
gap> KuratowskiPlanarSubdigraph(D);
[ [ 2, 9, 7 ], [ 1, 3 ], [ 6 ], [ 5, 9 ], [ 6, 4 ], [ 3, 5 ], [ 4 ], 
  [ 7, 9, 3 ], [ 8 ], [  ] ]
gap> D := NullDigraph(0);
<immutable empty digraph with 0 vertices>
gap> KuratowskiPlanarSubdigraph(D);
fail

# KuratowskiOuterPlanarSubdigraph
gap> D := Digraph([[3, 5, 10], [8, 9, 10], [1, 4], [3, 6], [1, 7, 11], [4, 7],
> [6, 8], [2, 7], [2, 11], [1, 2], [5, 9]]);
<immutable digraph with 11 vertices, 25 edges>
gap> KuratowskiOuterPlanarSubdigraph(D);
[ [ 3, 5, 10 ], [ 9, 8, 10 ], [ 4, 1 ], [ 6, 3 ], [ 1, 11 ], [ 7, 4 ], 
  [ 8, 6 ], [ 2, 7 ], [ 11, 2 ], [ 2, 1 ], [ 5, 9 ] ]
gap> D := Digraph([[2, 4, 7, 9, 10], [1, 3, 4, 6, 9, 10], [6, 10], 
> [2, 5, 8, 9], [1, 2, 3, 4, 6, 7, 9, 10], [3, 4, 5, 7, 9, 10], 
> [3, 4, 5, 6, 9, 10], [3, 4, 5, 7, 9], [2, 3, 5, 6, 7, 8], [3, 5]]);
<immutable digraph with 10 vertices, 50 edges>
gap> IsOuterPlanarDigraph(D);
false
gap> KuratowskiOuterPlanarSubdigraph(D);
[ [  ], [  ], [  ], [ 8, 9 ], [  ], [  ], [ 9, 4 ], [ 7, 9, 4 ], [ 8, 7 ], 
  [  ] ]
gap> D := NullDigraph(0);
<immutable empty digraph with 0 vertices>
gap> KuratowskiOuterPlanarSubdigraph(D);
fail
gap> D := CompleteDigraph(3);
<immutable complete digraph with 3 vertices>
gap> KuratowskiOuterPlanarSubdigraph(D);
fail

# Kernel function boyers_planarity_check, errors
gap> IS_PLANAR(2);
Error, Digraphs: boyers_planarity_check (C): the 1st argument must be a digrap\
h, not integer
gap> IS_PLANAR(NullDigraph(0));
true
gap> IS_PLANAR(NullDigraph(70000));
true
gap> IsPlanarDigraph(NullDigraph(70000));
true
gap> IS_PLANAR(CompleteDigraph(2));
true

#  DIGRAPHS_UnbindVariables
gap> Unbind(D);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/planar.tst", 0);

#T# DigraphSource and DigraphRange
