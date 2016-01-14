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
gap> IsClique(gr, [2, 5, 3, 1, 2]);
true

#T# IsIndependentSet and IsMaximalIndependentSet
gap>

#T# DigraphMaximalClique
gap>

#T# DigraphIndependentSet
gap>

#T# DigraphMaximalCliques
gap>

#T# DigraphMaximalIndependentSets
gap>

#T# DIGRAPHS_UnbindVariables

#E#
gap> STOP_TEST("Digraphs package: standard/cliques.tst");
