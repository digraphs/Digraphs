#############################################################################
##
#W  grahom.tst
#Y  Copyright (C) 2014
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: grahom.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DigraphsStartTest();

#
gap> gr := Digraph([[],[],[3]]);;
gap> HomomorphismDigraphs(gr, gr);
found endomorphism of rank 2
found endomorphism of rank 3
found endomorphism of rank 3
found endomorphism of rank 2
[ Transformation( [ 1, 1 ] ), IdentityTransformation, 
  Transformation( [ 2, 1 ] ), Transformation( [ 2, 2 ] ) ]
gap> DigraphEndomorphisms(gr);
GAP: at depth 1
GAP: at depth 2
found endomorphism of rank 2
found endomorphism of rank 3
[ Transformation( [ 2, 1 ] ), Transformation( [ 1, 1 ] ), 
  IdentityTransformation ]
gap> s := Semigroup(DigraphEndomorphisms(EmptyDigraph(4)));
GAP: at depth 1
GAP: at depth 2
GAP: at depth 3
GAP: at depth 4
found endomorphism of rank 3
found endomorphism of rank 3
found endomorphism of rank 3
found endomorphism of rank 4
GAP: at depth 4
GAP: at depth 5
GAP: at depth 5
GAP: at depth 5
GAP: at depth 4
GAP: at depth 5
GAP: at depth 5
GAP: at depth 5
GAP: at depth 3
GAP: at depth 4
GAP: at depth 5
GAP: at depth 5
GAP: at depth 5
GAP: at depth 4
GAP: at depth 5
GAP: at depth 5
<transformation monoid on 4 pts with 17 generators>
gap> IsFullTransformationMonoid(s);
true
gap> m := EndomorphismMonoid(CompleteDigraph(4));
GAP: at depth 1
GAP: at depth 2
<transformation monoid on 4 pts with 3 generators>
gap> Size(m);
24

#
gap> DigraphsStopTest();

#
gap> STOP_TEST( "Digraphs package: grahom.tst", 0);
