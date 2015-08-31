#%T##########################################################################
##
#W  extreme/oper.tst
#Y  Copyright (C) 2015                                  Michael C. Torpey
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: homos.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#T# DigraphReverseEdges
gap> s := Semigroup( [ Transformation( [ 5, 4, 6, 7, 3, 8, 2, 9, 7, 8 ] ),
>                      Transformation( [ 5, 5, 6, 6, 6, 5, 5, 4, 4, 3 ] ),
>                      Transformation( [ 6, 2, 2, 4, 6, 2, 9, 1, 3, 1 ] ),
>                      Transformation( [ 7, 1, 5, 8, 6, 8, 4, 4, 5, 4 ] ) ] );;
gap> d := DigraphRemoveAllMultipleEdges(Digraph(CayleyGraphSemigroup(s)));;
gap> DigraphReverseEdges(d, [12, 2001, 401000]);
<digraph with 113082 vertices, 451854 edges>
gap> s := Semigroup( [ Transformation( [ 2, 5, 2, 1, 6, 1, 7, 6 ] ), 
> Transformation( [ 2, 8, 4, 7, 5, 8, 3, 5 ] ), 
> Transformation( [ 5, 6, 3, 8, 4, 6, 5, 7 ] ), 
> Transformation( [ 8, 6, 2, 2, 7, 8, 8, 2 ] ), 
> Transformation( [ 8, 8, 7, 5, 1, 3, 1, 4 ] ) ] );;
gap> d := DigraphRemoveAllMultipleEdges(Digraph(CayleyGraphSemigroup(s)));;
gap> DigraphReverseEdges(d, [12, 2001, 401000]);
<digraph with 156614 vertices, 783064 edges>
gap> s := Semigroup( [ Transformation( [ 1, 5, 2, 6, 6, 7, 4, 1 ] ), 
>  Transformation( [ 2, 2, 4, 4, 7, 6, 1, 3 ] ), 
>  Transformation( [ 5, 6, 3, 8, 2, 8, 3, 7 ] ), 
>  Transformation( [ 5, 8, 6, 2, 2, 7, 8, 8 ] ), 
>  Transformation( [ 6, 2, 8, 4, 7, 5, 8, 3 ] ), 
>  Transformation( [ 6, 6, 2, 2, 3, 5, 7, 2 ] ) ] );;
gap> d := DigraphRemoveAllMultipleEdges(Digraph(CayleyGraphSemigroup(s)));;
gap> DigraphReverseEdges(d, [50001,300001,3000007]);
<digraph with 572429 vertices, 3418121 edges>
gap> DigraphReverseEdges(d, [[42,257], [128,763]]);
<digraph with 572429 vertices, 3418121 edges>

#E#
gap> STOP_TEST("Digraphs package: homos.tst");
