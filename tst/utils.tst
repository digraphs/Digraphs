#############################################################################
##
#W  utils.tst
#Y  Copyright (C) 2014
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: utils.tst");
gap> LoadPackage("digraphs", false);;

#
gap> ReadGraph6Line("?");
<directed graph with 0 vertices, 0 edges>
gap> ReadGraph6Line("E?A?");
<directed graph with 6 vertices, 2 edges>

#
gap>  l := ["BW", "C]", "DQw", "ECO_", "FCZUo", "GCZenS",
> "HCQTndn", "H?qcyxf"];
[ "BW", "C]", "DQw", "ECO_", "FCZUo", "GCZenS", "HCQTndn", "H?qcyxf" ]
gap> List(l, x -> ReadGraph6Line(x));
[ <directed graph with 3 vertices, 4 edges>, 
  <directed graph with 4 vertices, 8 edges>, 
  <directed graph with 5 vertices, 10 edges>, 
  <directed graph with 6 vertices, 6 edges>, 
  <directed graph with 7 vertices, 20 edges>, 
  <directed graph with 8 vertices, 30 edges>, 
  <directed graph with 9 vertices, 38 edges>, 
  <directed graph with 9 vertices, 34 edges> ]

#
gap> str := Concatenation(DigraphsDir(), "/data/graph5.g6");;
gap> list := ReadDirectedGraphs(str);;
gap> Size(list);
34

#
gap> ReadSparse6Line(":Fa@x^");
<directed graph with 7 vertices, 8 edges>

#
gap> STOP_TEST( "Digraphs package: digraph.tst", 0);
