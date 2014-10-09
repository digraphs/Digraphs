#############################################################################
##
#W  io.tst
#Y  Copyright (C) 2014
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: utils.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DigraphFromGraph6String("?");
<digraph with 0 vertices, 0 edges>
gap> DigraphFromGraph6String("E?A?");
<digraph with 6 vertices, 2 edges>

#
gap> gr := Digraph(rec( nrvertices := 300, source := [1..2], range := [2,1]));
<digraph with 300 vertices, 2 edges>
gap> str := WriteGraph6(gr);;
gap> DigraphFromGraph6String(str) = gr;
true

#
gap> gr := Digraph([[2], [1,4], [5], [2], [3]]);
<digraph with 5 vertices, 6 edges>
gap> str := WriteGraph6(gr);
"DaG"
gap> DigraphFromGraph6String(str);
<digraph with 5 vertices, 6 edges>

#
gap>  l :=  ["BW", "C]", "DQw", "ECO_", "FCZUo", "GCZenS", "HCQTndn", 
> "H?qcyxf"];;
gap> List(l, x -> DigraphFromGraph6String(x));
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
gap> DigraphFromSparse6String(":[___dCfEcdFjCIideLhIfJkLgkQge`RSbPTaOTbMNaS`QY");
<digraph with 28 vertices, 84 edges>
gap> DigraphFromSparse6String(":I`ACWqHKhhccTF");
<digraph with 10 vertices, 30 edges>
gap> DigraphFromSparse6String(":U___gFecGdHcEdFcFdE`GHbILaJKbNaM`RS");
<digraph with 22 vertices, 66 edges>
gap> DigraphFromSparse6String(":U___fEcdcdIeHfGcFdE`GHbILaJKbNaM`RS");
<digraph with 22 vertices, 66 edges>
gap> DigraphFromSparse6String(":U___fEcdGcdeJfIcFdEbLNaKM`H`GbIRaJQ");
<digraph with 22 vertices, 66 edges>

#
gap> gr := Digraph([[2], [1,4], [5], [2], [3]]);
<digraph with 5 vertices, 6 edges>
gap> str :=  WriteSparse6(gr);
":Dapj"

#
gap> DigraphFromSparse6String(str);
<digraph with 5 vertices, 6 edges>
gap> gr := Digraph(rec(nrvertices := 231, source := [1,1,3,4],
> range := [3,4,1,1]));
<digraph with 231 vertices, 4 edges>
gap> str := WriteSparse6(gr);
":~?Bf_O?_F"
gap> DigraphFromSparse6String(str);
<digraph with 231 vertices, 4 edges>
gap> gr := Digraph(rec(nrvertices := 2^17, source := [1,1,3,4,10,100],
> range := [3,4,1,1,100,10]));
<digraph with 131072 vertices, 6 edges>
gap> str := WriteSparse6(gr);
":~_??_?A???_??_@b??H"
gap> DigraphFromSparse6String(str);
<digraph with 131072 vertices, 6 edges>

#
gap> gr := Digraph([[5], [1,2,5], [1], [2],[4]]);
<digraph with 5 vertices, 7 edges>
gap> str := WriteDigraph6(gr);
"+DWg?[?"
gap> DigraphFromDigraph6String(str);
<digraph with 5 vertices, 7 edges>
gap> gr := Digraph(rec(nrvertices := 231, source := [1..100],
> range := [1..100]*0+200));
<digraph with 231 vertices, 100 edges>
gap> str := WriteDigraph6(gr);;
gap> DigraphFromDigraph6String(str);
<digraph with 231 vertices, 100 edges>

#
gap> gr := Digraph([[1,4],[2,3,4],[2,4],[2]]);
<digraph with 4 vertices, 8 edges>
gap> str := WriteDiSparse6(gr);
".CgXoHe@J"
gap> DigraphFromDiSparse6String(str) = gr;
true

#
gap> STOP_TEST( "Digraphs package: utils.tst", 0);
