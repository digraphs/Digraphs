#############################################################################
##
#W  standard/grahom.tst
#Y  Copyright (C) 2015                                   Wilfred A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/grahom.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#T# HomomorphismGraphsFinder: finding monomorphisms
gap> gr1 := Digraph([[], [1]]);;
gap> gr1 := DigraphSymmetricClosure(gr1);;
gap> gr2 := Digraph([[], [1], [1, 3]]);;
gap> gr2 := DigraphSymmetricClosure(gr2);;
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], infinity, fail, true,
> [1,2,3], []);
[ IdentityTransformation, Transformation( [ 1, 3 ] ), 
  Transformation( [ 2, 1 ] ), Transformation( [ 3, 1 ] ) ]

#T# DIGRAPHS_UnbindVariables
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);

#E#
gap> STOP_TEST("Digraphs package: standard/grahom.tst");
