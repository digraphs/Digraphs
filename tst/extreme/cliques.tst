#############################################################################
##
#W  extreme/cliques.tst
#Y  Copyright (C) 2024                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: extreme/cliques.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();
gap> D :=
> DigraphFromGraph6String("hJ\\zz{vJw~jvV^]^mvz\\~N^|{~xt~zJ~|N~~Y~~yf\
> ~~m~~~]~~~HR|nbmm~w^N}~Rmzv{inlnwcezjyBx{F{w}p~~VM]~~zH}T~~mvz~^~Lv~\
> }~~Y~~z^~nNv~n~yf~~n~~???????");
<immutable symmetric digraph with 41 vertices, 1212 edges>
gap> Length(DigraphCliques(D));
1651734

#  DIGRAPHS_UnbindVariables
gap> Unbind(D);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/cliques.tst", 0);
