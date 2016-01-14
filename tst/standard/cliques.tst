#############################################################################
##
#W  standard/cliques.tst
#Y  Copyright (C) 2016                                   Wilfred A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/cliques.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#T# IsClique and IsMaximalClique

# Cliques of the complete digraph
gap> gr := CompleteDigraph(5);;
gap> IsClique(gr, []);
true
gap> IsClique(gr, [4]);
true
gap> IsClique(gr, [4, 3]);
true
gap> IsClique(gr, [4, 1, 3]);
true
gap> IsClique(gr, [4, 2, 3, 1]);
true
gap> IsClique(gr, [1 , 5, 3, 4, 2]);
true
gap> gr := Digraph([
> [2, 3, 4, 5, 7, 8, 11, 12], [1, 3, 4, 6, 7, 9, 11, 13],
> [1, 2, 5, 6, 8, 9, 12, 13], [1, 2, 5, 6, 7, 10, 11, 14],
> [1, 3, 4, 6, 8, 10, 12, 14], [2, 3, 4, 5, 9, 10, 13, 14],
> [1, 2, 4, 8, 9, 10, 11, 15], [1, 3, 5, 7, 9, 10, 12, 15],
> [2, 3, 6, 7, 8, 10, 13, 15], [4, 5, 6, 7, 8, 9, 14, 15],
> [1, 2, 4, 7, 12, 13, 14, 15], [1, 3, 5, 8, 11, 13, 14, 15],
> [2, 3, 6, 9, 11, 12, 14, 15], [4, 5, 6, 10, 11, 12, 13, 15],
> [7, 8, 9, 10, 11, 12, 13, 14]]);
<digraph with 15 vertices, 120 edges>
gap> IsClique(gr, [1, 2, 4, 7, 11]);
true
gap> IsClique(gr, [1, 2, 3]);
true
gap> gr := Digraph([
> [2, 3, 4, 5, 7, 8, 11, 12], [1, 3, 4, 6, 7, 9, 11, 13],
> [1, 2, 5, 6, 8, 9, 12, 13], [1, 2, 5, 6, 7, 10, 11, 14],
> [1, 3, 4, 6, 8, 10, 12, 14], [2, 3, 4, 5, 9, 10, 13, 14],
> [1, 2, 4, 8, 9, 10, 11, 15], [1, 3, 5, 7, 9, 10, 12, 15],
> [2, 3, 6, 7, 8, 10, 13, 15], [4, 5, 6, 7, 8, 9, 14, 15],
> [1, 2, 4, 7, 12, 13, 14, 15], [1, 3, 5, 8, 11, 13, 14, 15],
> [2, 3, 6, 9, 11, 12, 14, 15], [4, 5, 6, 10, 11, 12, 13, 15],
> [7, 8, 9, 10, 11, 12, 13, 14]]);
<digraph with 15 vertices, 120 edges>
gap> IsMaximalClique(gr, [1, 2, 4, 7, 11]);
true
gap> IsMaximalClique(gr, [1, 2, 3]);
true

##T# IsIndependentSet and IsMaximalIndependentSet
#gap>
##T# DigraphMaximalClique
#gap>
#
##T# DigraphIndependentSet
#gap>
#
##T# DigraphMaximalCliques
#gap>
#
##T# DigraphMaximalIndependentSets
#gap>
#
##T# DIGRAPHS_UnbindVariables

#E#
gap> STOP_TEST("Digraphs package: standard/cliques.tst");
