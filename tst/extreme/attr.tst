#############################################################################
##
#W  extreme/attr.tst
#Y  Copyright (C) 2014-15                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

#@local circs, g, gr, str
gap> START_TEST("Digraphs package: extreme/attr.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#  ReducedDigraph 1
# For a digraph with lots of edges: digraphs-lib/extreme.d6.gz
gap> gr := ReadDigraphs(Concatenation(DIGRAPHS_Dir(),
>                                     "/digraphs-lib/extreme.d6.gz"), 1);
<immutable digraph with 5000 vertices, 4211332 edges>
gap> ReducedDigraph(gr);
<immutable connected digraph with 5000 vertices, 4211332 edges>

#  DigraphSymmetricClosure 1
# For a digraph with lots of edges: digraphs-lib/extreme.d6.gz
gap> DigraphSymmetricClosure(gr);
<immutable symmetric digraph with 5000 vertices, 7713076 edges>
gap> gr := ReadDigraphs(Concatenation(DIGRAPHS_Dir(),
>                                     "/data/symmetric-closure.ds6.gz"),
>                       DigraphFromDiSparse6String,
>                       1);
<immutable digraph with 46656 vertices, 120245 edges>
gap> DigraphSymmetricClosure(gr);
<immutable symmetric digraph with 46656 vertices, 197930 edges>

#  DigraphAllSimpleCircuits
gap> gr := DigraphFromDigraph6String(
> "+N{MYG?cJOU}MqNJLoVPHC?tDlcxgFACCDWxDMX?");
<immutable digraph with 15 vertices, 92 edges>
gap> circs := DigraphAllSimpleCircuits(gr);;
gap> Length(circs);
1291792

#  HamiltonianPath and IsHamiltonianDigraph
gap> g := CompleteDigraph(20);
<immutable complete digraph with 20 vertices>
gap> HamiltonianPath(g);
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 ]
gap> IsDigraphMonomorphism(CycleDigraph(20), 
>                          g,
>                          Transformation(HamiltonianPath(g)));
true
gap> IsHamiltonianDigraph(g);
true
gap> g := CompleteMultipartiteDigraph([1, 9, 1, 1, 2, 1, 1, 1]);
<immutable complete multipartite digraph with 17 vertices, 198 edges>
gap> HamiltonianPath(g);
fail
gap> IsHamiltonianDigraph(g);
false

# ChromaticNumber (from Issue #163)
gap> str := Concatenation("""khdLA_gc?N_QQchPIS@Q_dH@GKA_W@OW?Fo???~{G??SgSo""",
>                         """SgSQISIaQcQgD?\@?SASI?gGggC_[`??N_M??APNG?Qc?E?""",
>                         """DIG?_?IS?B??IS?E??dH?C??H@_B??A_W?o??IB?E???Fo?""",
>                         """O????F~O??????N~~{""");;
gap> gr := DigraphFromGraph6String(str);;
gap> ChromaticNumber(gr);
6

# DigraphVertexConnectivity
gap> str := Concatenation("""{???????????_?O?@??G??_?@??@???_??G??@?@???A??""",
> """?_?O?O?_??C?G??_C?A?C??C?_??C?G??A?O???G?O??@?G?@???G?A??@????????????""",
> """??_???????????@?????????????G???F_??????WW?????Bo???o???_???E??A?_?E??""",
> """?C????B??C@???K??@???@_??@?M?????????B??????C?o??????P_????????W??????""",
> """?KB???????I??????W????????CG??_?????B??B""");;  # House of Graphs 1357
gap> gr := DigraphFromGraph6String(str);;
gap> DigraphVertexConnectivity(gr);
3
gap> gr := CompleteMultipartiteDigraph([20, 20, 20]);;
gap> DigraphVertexConnectivity(gr);
40
gap> str := Concatenation("""~?@A}rEEB?oE?W?o?o?W?E??o?B??E??E??B???o??E???""",
> """W???n~~~n~~~V~~~d~~~wn~~~A~~~{D~~~wD~~~wA~~~{?n~~~?D~~~w?V~~~_?n~~~??n""",
> """~~~??V~~~_?D~~~w??n~~~??A~~~{??D~~~w??D~~~w??A~~~{???^~~~~~~z~~~~~~~N~""",
> """~~~~~{^~~~~~~w^~~~~~~wN~~~~~~{B~~~~~~~?^~~~~~~w@~~~~~~~_B~~~~~~~?B~~~~""",
> """~~~?@~~~~~~~_?^~~~~~~w?B~~~~~~~??N~~~~~~{??^~~~~~~w??^~~~~~~w??N~~~~~~""",
> """{??B~~~~~~~???^~~~~~~w??@~~~~~~~_???""");;  # House of Graphs 52267
gap> gr := DigraphFromGraph6String(str);;
gap> DigraphVertexConnectivity(gr);
44

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: extreme/attr.tst", 0);
