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
<digraph with 0 vertices, 0 edges>
gap> ReadGraph6Line("E?A?");
<digraph with 6 vertices, 2 edges>

#
gap>  l :=  ["BW", "C]", "DQw", "ECO_", "FCZUo", "GCZenS", "HCQTndn", 
> "H?qcyxf"];;
gap> List(l, x -> ReadGraph6Line(x));
[ <digraph with 3 vertices, 4 edges>, <digraph with 4 vertices, 8 edges>, 
  <digraph with 5 vertices, 10 edges>, <digraph with 6 vertices, 6 edges>, 
  <digraph with 7 vertices, 20 edges>, <digraph with 8 vertices, 30 edges>, 
  <digraph with 9 vertices, 38 edges>, <digraph with 9 vertices, 34 edges> ]

#
gap> str := Concatenation(DigraphsDir(), "/data/graph5.g6");;
gap> list := ReadDigraphs(str);;
gap> Size(list);
34

#
gap> ReadSparse6Line(":[___dCfEcdFjCIideLhIfJkLgkQge`RSbPTaOTbMNaS`QY");
<digraph with 28 vertices, 82 edges>
gap> ReadSparse6Line(":I`ACWqHKhhccTF");
<digraph with 10 vertices, 30 edges>
gap> ReadSparse6Line(":U___gFecGdHcEdFcFdE`GHbILaJKbNaM`RS");
<digraph with 22 vertices, 64 edges>
gap> ReadSparse6Line(":U___fEcdcdIeHfGcFdE`GHbILaJKbNaM`RS");
<digraph with 22 vertices, 64 edges>
gap> ReadSparse6Line(":U___fEcdGcdeJfIcFdEbLNaKM`H`GbIRaJQ");
<digraph with 22 vertices, 64 edges>

#
gap> STOP_TEST( "Digraphs package: utils.tst", 0);
