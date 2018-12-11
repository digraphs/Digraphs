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
<digraph with 0 vertices, 0 edges>
gap> IsPlanarDigraph(D);
true
gap> D := CompleteDigraph(4);
<digraph with 4 vertices, 12 edges>
gap> IsPlanarDigraph(D);
true
gap> D := CompleteDigraph(5);
<digraph with 5 vertices, 20 edges>
gap> IsPlanarDigraph(D);
false
gap> D := Digraph([[2, 4, 7, 9, 10], [1, 3, 4, 6, 9, 10], [6, 10], 
> [2, 5, 8, 9], [1, 2, 3, 4, 6, 7, 9, 10], [3, 4, 5, 7, 9, 10], 
> [3, 4, 5, 6, 9, 10], [3, 4, 5, 7, 9], [2, 3, 5, 6, 7, 8], [3, 5]]);
<digraph with 10 vertices, 50 edges>
gap> ChromaticNumber(D);
5
gap> IsPlanarDigraph(D);
false
gap> D := CompleteBipartiteDigraph(3, 3);
<digraph with 6 vertices, 18 edges>
gap> D := DigraphDisjointUnion(D, D);
<digraph with 12 vertices, 36 edges>
gap> IsPlanarDigraph(D);
false

# IsOuterPlanarDigraph
gap> D := Digraph([[2, 4, 7, 9, 10], [1, 3, 4, 6, 9, 10], [6, 10], 
> [2, 5, 8, 9], [1, 2, 3, 4, 6, 7, 9, 10], [3, 4, 5, 7, 9, 10], 
> [3, 4, 5, 6, 9, 10], [3, 4, 5, 7, 9], [2, 3, 5, 6, 7, 8], [3, 5]]);
<digraph with 10 vertices, 50 edges>
gap> ChromaticNumber(D);
5
gap> IsPlanarDigraph(D);
false
gap> IsOuterPlanarDigraph(D);
false
gap> D := NullDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> IsOuterPlanarDigraph(D);
true
gap> D := CompleteDigraph(4);
<digraph with 4 vertices, 12 edges>
gap> IsOuterPlanarDigraph(D);
false
gap> D := CompleteDigraph(4);
<digraph with 4 vertices, 12 edges>
gap> ChromaticNumber(D);
4
gap> IsOuterPlanarDigraph(D);
false
gap> D := Digraph([[3, 5, 10], [8, 9, 10], [1, 4], [3, 6], [1, 7, 11], [4, 7],
> [6, 8], [2, 7], [2, 11], [1, 2], [5, 9]]);
<digraph with 11 vertices, 25 edges>
gap> IsOuterPlanarDigraph(D);
false
gap> IsPlanarDigraph(D);
true

# PlanarEmbedding
gap> D := Digraph([[3, 5, 10], [8, 9, 10], [1, 4], [3, 6], [1, 7, 11], [4, 7],
> [6, 8], [2, 7], [2, 11], [1, 2], [5, 9]]);
<digraph with 11 vertices, 25 edges>
gap> PlanarEmbedding(D);
[ [ 3, 10, 5 ], [ 10, 8, 9 ], [ 4 ], [ 6 ], [ 11, 7 ], [ 7 ], [ 8 ], [  ], 
  [ 11 ], [  ], [  ] ]
gap> D := Digraph([[2, 4, 7, 9, 10], [1, 3, 4, 6, 9, 10], [6, 10], 
> [2, 5, 8, 9], [1, 2, 3, 4, 6, 7, 9, 10], [3, 4, 5, 7, 9, 10], 
> [3, 4, 5, 6, 9, 10], [3, 4, 5, 7, 9], [2, 3, 5, 6, 7, 8], [3, 5]]);
<digraph with 10 vertices, 50 edges>
gap> IsPlanarDigraph(D);
false
gap> PlanarEmbedding(D);
fail
gap> D := NullDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> PlanarEmbedding(D);
[  ]
gap> D := List(["D??", "D?_", "D?o", "D?w", "D?{", "DCO", "DCW", "DCc", "DCo",
> "DCs", "DCw", "DC{", "DEk", "DEo", "DEs", "DEw", "DE{", "DFw", "DF{", "DQg",
> "DQo", "DQw", "DQ{", "DTk", "DTw", "DT{", "DUW", "DUw", "DU{", "DV{", "D]w",
> "D]{", "D^{", "D~{"], DigraphFromGraph6String);;
gap> List(D, PlanarEmbedding);
[ [  ], [ [ 5 ], [  ], [  ], [  ], [  ] ], [ [ 5 ], [ 5 ], [  ], [  ], [  ] ],
  [ [ 5 ], [ 5 ], [ 5 ], [  ], [  ] ], [ [ 5 ], [ 5 ], [ 5 ], [ 5 ], [  ] ], 
  [ [ 4 ], [ 5 ], [  ], [  ], [  ] ], [ [ 4 ], [ 5 ], [ 5 ], [  ], [  ] ], 
  [ [ 4, 5 ], [  ], [  ], [ 5 ], [  ] ], [ [ 4, 5 ], [ 5 ], [  ], [  ], [  ] ]
    , [ [ 4, 5 ], [ 5 ], [  ], [ 5 ], [  ] ], 
  [ [ 4, 5 ], [ 5 ], [ 5 ], [  ], [  ] ], 
  [ [ 4, 5 ], [ 5 ], [ 5 ], [ 5 ], [  ] ], 
  [ [ 4, 5 ], [ 4 ], [ 5 ], [ 5 ], [  ] ], 
  [ [ 4, 5 ], [ 5, 4 ], [  ], [  ], [  ] ], 
  [ [ 4, 5 ], [ 5, 4 ], [  ], [ 5 ], [  ] ], 
  [ [ 4, 5 ], [ 5, 4 ], [ 5 ], [  ], [  ] ], 
  [ [ 4, 5 ], [ 5, 4 ], [ 5 ], [ 5 ], [  ] ], 
  [ [ 4, 5 ], [ 5, 4 ], [ 4, 5 ], [  ], [  ] ], 
  [ [ 4, 5 ], [ 5, 4 ], [ 4, 5 ], [ 5 ], [  ] ], 
  [ [ 3, 5 ], [ 4 ], [ 5 ], [  ], [  ] ], 
  [ [ 3, 5 ], [ 5, 4 ], [  ], [  ], [  ] ], 
  [ [ 3, 5 ], [ 5, 4 ], [ 5 ], [  ], [  ] ], 
  [ [ 3, 5 ], [ 4, 5 ], [ 5 ], [ 5 ], [  ] ], 
  [ [ 3, 5, 4 ], [  ], [ 4, 5 ], [ 5 ], [  ] ], 
  [ [ 3, 5, 4 ], [ 5 ], [ 4, 5 ], [  ], [  ] ], 
  [ [ 3, 5, 4 ], [ 5 ], [ 4, 5 ], [ 5 ], [  ] ], 
  [ [ 3, 4 ], [ 4, 5 ], [ 5 ], [  ], [  ] ], 
  [ [ 3, 5, 4 ], [ 4, 5 ], [ 5 ], [  ], [  ] ], 
  [ [ 3, 5, 4 ], [ 4, 5 ], [ 5 ], [ 5 ], [  ] ], 
  [ [ 3, 5, 4 ], [ 5, 4 ], [ 4, 5 ], [ 5 ], [  ] ], 
  [ [ 3, 5, 4 ], [ 4, 5, 3 ], [ 5 ], [  ], [  ] ], 
  [ [ 3, 5, 4 ], [ 4, 5, 3 ], [ 5 ], [ 5 ], [  ] ], 
  [ [ 3, 5, 4 ], [ 4, 5, 3 ], [ 4, 5 ], [ 5 ], [  ] ], fail ]

# OuterPlanarEmbedding
gap> D := Digraph([[3, 5, 10], [8, 9, 10], [1, 4], [3, 6], [1, 7, 11], [4, 7],
> [6, 8], [2, 7], [2, 11], [1, 2], [5, 9]]);
<digraph with 11 vertices, 25 edges>
gap> OuterPlanarEmbedding(D);
fail
gap> D := Digraph([[2, 4, 7, 9, 10], [1, 3, 4, 6, 9, 10], [6, 10], 
> [2, 5, 8, 9], [1, 2, 3, 4, 6, 7, 9, 10], [3, 4, 5, 7, 9, 10], 
> [3, 4, 5, 6, 9, 10], [3, 4, 5, 7, 9], [2, 3, 5, 6, 7, 8], [3, 5]]);
<digraph with 10 vertices, 50 edges>
gap> IsOuterPlanarDigraph(D);
false
gap> OuterPlanarEmbedding(D);
fail
gap> D := NullDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> OuterPlanarEmbedding(D);
[  ]
gap> D := CompleteDigraph(3);
<digraph with 3 vertices, 6 edges>
gap> OuterPlanarEmbedding(D);
[ [ 2, 3 ], [ 3 ], [  ] ]

# SubdigraphHomeomorphicToK23/33/4
gap> D := Digraph([[3, 5, 10], [8, 9, 10], [1, 4], [3, 6], [1, 7, 11], [4, 7],
> [6, 8], [2, 7], [2, 11], [1, 2], [5, 9]]);
<digraph with 11 vertices, 25 edges>
gap> SubdigraphHomeomorphicToK4(D);
[ [ 3, 5, 10 ], [ 9, 8, 10 ], [ 4 ], [ 6 ], [ 7, 11 ], [ 7 ], [ 8 ], [  ], 
  [ 11 ], [  ], [  ] ]
gap> SubdigraphHomeomorphicToK23(D);
[ [ 3, 5, 10 ], [ 9, 8, 10 ], [ 4 ], [ 6 ], [ 11 ], [ 7 ], [ 8 ], [  ], 
  [ 11 ], [  ], [  ] ]
gap> D := Digraph([[3, 5, 10], [8, 9, 10], [1, 4], [3, 6], [1, 11], [4, 7],
> [6, 8], [2, 7], [2, 11], [1, 2], [5, 9]]);
<digraph with 11 vertices, 24 edges>
gap> SubdigraphHomeomorphicToK4(D);
fail
gap> SubdigraphHomeomorphicToK23(D);
[ [ 3, 10, 5 ], [ 10, 8, 9 ], [ 4 ], [ 6 ], [ 11 ], [ 7 ], [ 8 ], [  ], 
  [ 11 ], [  ], [  ] ]
gap> SubdigraphHomeomorphicToK33(D);
fail
gap> SubdigraphHomeomorphicToK23(NullDigraph(0));
fail
gap> SubdigraphHomeomorphicToK33(CompleteDigraph(5));
fail
gap> SubdigraphHomeomorphicToK33(CompleteBipartiteDigraph(3, 3));
[ [ 4, 6, 5 ], [ 4, 5, 6 ], [ 6, 5, 4 ], [  ], [  ], [  ] ]
gap> SubdigraphHomeomorphicToK4(CompleteDigraph(3));
fail

# KuratowskiPlanarSubdigraph
gap> D := Digraph([[3, 5, 10], [8, 9, 10], [1, 4], [3, 6], [1, 7, 11], [4, 7],
> [6, 8], [2, 7], [2, 11], [1, 2], [5, 9]]);
<digraph with 11 vertices, 25 edges>
gap> KuratowskiPlanarSubdigraph(D);
fail
gap> D := Digraph([[2, 4, 7, 9, 10], [1, 3, 4, 6, 9, 10], [6, 10], 
> [2, 5, 8, 9], [1, 2, 3, 4, 6, 7, 9, 10], [3, 4, 5, 7, 9, 10], 
> [3, 4, 5, 6, 9, 10], [3, 4, 5, 7, 9], [2, 3, 5, 6, 7, 8], [3, 5]]);
<digraph with 10 vertices, 50 edges>
gap> IsPlanarDigraph(D);
false
gap> KuratowskiPlanarSubdigraph(D);
[ [ 2, 9, 7 ], [ 3 ], [ 6 ], [ 5, 9 ], [ 6 ], [  ], [ 4 ], [ 7, 9, 3 ], [  ], 
  [  ] ]
gap> D := NullDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> KuratowskiPlanarSubdigraph(D);
fail

# KuratowskiOuterPlanarSubdigraph
gap> D := Digraph([[3, 5, 10], [8, 9, 10], [1, 4], [3, 6], [1, 7, 11], [4, 7],
> [6, 8], [2, 7], [2, 11], [1, 2], [5, 9]]);
<digraph with 11 vertices, 25 edges>
gap> KuratowskiOuterPlanarSubdigraph(D);
[ [ 3, 5, 10 ], [ 9, 8, 10 ], [ 4 ], [ 6 ], [ 11 ], [ 7 ], [ 8 ], [  ], 
  [ 11 ], [  ], [  ] ]
gap> D := Digraph([[2, 4, 7, 9, 10], [1, 3, 4, 6, 9, 10], [6, 10], 
> [2, 5, 8, 9], [1, 2, 3, 4, 6, 7, 9, 10], [3, 4, 5, 7, 9, 10], 
> [3, 4, 5, 6, 9, 10], [3, 4, 5, 7, 9], [2, 3, 5, 6, 7, 8], [3, 5]]);
<digraph with 10 vertices, 50 edges>
gap> IsOuterPlanarDigraph(D);
false
gap> KuratowskiOuterPlanarSubdigraph(D);
[ [  ], [  ], [  ], [ 8, 9 ], [  ], [  ], [ 9, 4 ], [ 7, 9 ], [  ], [  ] ]
gap> D := NullDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> KuratowskiOuterPlanarSubdigraph(D);
fail
gap> D := CompleteDigraph(3);
<digraph with 3 vertices, 6 edges>
gap> KuratowskiOuterPlanarSubdigraph(D);
fail

# Kernel function boyers_planarity_check, errors
gap> IS_PLANAR(2);
Error, Digraphs: boyers_planarity_check (C): the 1st argument must be a digrap\
h, not integer
gap> IS_PLANAR(NullDigraph(0));
Error, Digraphs: boyers_planarity_check (C): invalid number of nodes!
gap> IS_PLANAR(NullDigraph(70000));
Error, Digraphs: boyers_planarity_check (C): invalid number of edges!
gap> IsPlanarDigraph(NullDigraph(70000));
true
gap> IS_PLANAR(CompleteDigraph(2));
Error, Digraphs: boyers_planarity_check (C): the 1st argument must be an antis\
ymmetric digraph

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/attr.tst", 0);

#T# DigraphSource and DigraphRange
