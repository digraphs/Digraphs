#############################################################################
##
#W  extreme/attr.tst
#Y  Copyright (C) 2014-15                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: extreme/attr.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#  ReducedDigraph 1
# For a digraph with lots of edges: digraphs-lib/extreme.d6.gz
gap> gr := ReadDigraphs(Concatenation(DIGRAPHS_Dir(),
>                                     "/digraphs-lib/extreme.d6.gz"), 1);
<digraph with 5000 vertices, 4211332 edges>
gap> ReducedDigraph(gr);
<digraph with 5000 vertices, 4211332 edges>

#  DigraphSymmetricClosure 1
# For a digraph with lots of edges: digraphs-lib/extreme.d6.gz
gap> gr := ReadDigraphs(Concatenation(DIGRAPHS_Dir(),
>                                     "/digraphs-lib/extreme.d6.gz"), 1);
<digraph with 5000 vertices, 4211332 edges>
gap> DigraphSymmetricClosure(gr);
<digraph with 5000 vertices, 7713076 edges>
gap> gr := ReadDigraphs(Concatenation(DIGRAPHS_Dir(),
>                                     "/data/symmetric-closure.ds6.gz"),
>                       DigraphFromDiSparse6String,
>                       1);
<digraph with 46656 vertices, 120245 edges>
gap> DigraphSymmetricClosure(gr);
<digraph with 46656 vertices, 197930 edges>

#  DigraphAllSimpleCircuits
gap> gr := DigraphFromDigraph6String(
> "+N{MYG?cJOU}MqNJLoVPHC?tDlcxgFACCDWxDMX?");
<digraph with 15 vertices, 92 edges>
gap> circs := DigraphAllSimpleCircuits(gr);;
gap> Length(circs);
1291792

#  HamiltonianPath and IsHamiltonianDigraph
gap> g := CompleteDigraph(20);
<digraph with 20 vertices, 380 edges>
gap> HamiltonianPath(g);
[ 1, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 19, 17, 15, 13, 11, 9, 7, 5, 3 ]
gap> IsHamiltonianDigraph(g);
true
gap> g := CompleteMultipartiteDigraph([1, 9, 1, 1, 2, 1, 1, 1]);
<digraph with 17 vertices, 198 edges>
gap> HamiltonianPath(g);
fail
gap> IsHamiltonianDigraph(g);
false

#  DIGRAPHS_UnbindVariables
gap> Unbind(circs);
gap> Unbind(gr);

#E#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: extreme/attr.tst", 0);
