#############################################################################
##
#W  standard/io.tst
#Y  Copyright (C) 2014-15
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/io.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#T# DigraphFromGraph6String and Graph6String
gap> DigraphFromGraph6String("?");
<digraph with 0 vertices, 0 edges>
gap> DigraphFromGraph6String("E?A?");
<digraph with 6 vertices, 2 edges>
gap> DigraphFromGraph6String("@");
<digraph with 1 vertex, 0 edges>
gap> gr := Digraph(300, [1, 2], [2, 1]);
<digraph with 300 vertices, 2 edges>
gap> str := Graph6String(gr);;
gap> DigraphFromGraph6String(str) = gr;
true
gap> gr := Digraph([[2], [1, 4], [5], [2], [3]]);
<digraph with 5 vertices, 6 edges>
gap> str := Graph6String(gr);
"DaG"
gap> DigraphFromGraph6String(str);
<digraph with 5 vertices, 6 edges>
gap>  l := ["BW", "C]", "DQw", "ECO_", "FCZUo", "GCZenS", "HCQTndn",
> "H?qcyxf"];;
gap> List(l, x -> DigraphFromGraph6String(x));
[ <digraph with 3 vertices, 4 edges>, <digraph with 4 vertices, 8 edges>, 
  <digraph with 5 vertices, 10 edges>, <digraph with 6 vertices, 6 edges>, 
  <digraph with 7 vertices, 20 edges>, <digraph with 8 vertices, 30 edges>, 
  <digraph with 9 vertices, 38 edges>, <digraph with 9 vertices, 34 edges> ]

# ReadDigraphs
gap> str := Concatenation(DIGRAPHS_Dir(), "/data/graph5.g6.gz");;
gap> list := ReadDigraphs(str);;
gap> Size(list);
34
gap> list2 := ReadDigraphs(str, DigraphFromGraph6String);;
gap> list = list2;
true
gap> gr := ReadDigraphs(str, 10);
<digraph with 5 vertices, 8 edges>
gap> list = gr;
false
gap> list[10] = gr;
true
gap> ReadDigraphs(34, DigraphFromGraph6String, 5);
Error, Digraphs: ReadDigraphs: usage,
ReadDigraphs( filename [, decoder][, pos] ),
gap> ReadDigraphs(str, (1, 6, 5), 5);
Error, Digraphs: ReadDigraphs: usage,
ReadDigraphs( filename [, decoder][, pos] ),
gap> ReadDigraphs(str, DigraphFromGraph6String, 0);
Error, Digraphs: ReadDigraphs: usage,
ReadDigraphs( filename [, decoder][, pos] ),
gap> str := Concatenation(DIGRAPHS_Dir(), "/data/tree9.4.txt");;
gap> list := ReadDigraphs(str);;
gap> list2 := ReadDigraphs(str,
>                          DigraphPlainTextLineDecoder("  ", " ", 1),
>                          infinity);;
gap> list = list2;
true
gap> ReadDigraphs(str, 2, true, "elephant");
Error, Digraphs: ReadDigraphs: usage,
ReadDigraphs( filename [, decoder][, pos] ),
gap> badfilename := "path/to/some/madeupfile.g6.gz";;
gap> ReadDigraphs(badfilename, 3);
Error, Digraphs: ReadDigraphs: usage,
cannot open file path/to/some/madeupfile.g6.gz,

#T# DigraphFromSparse6String and Sparse6String
gap> DigraphFromSparse6String(":@");
<digraph with 1 vertex, 0 edges>
gap> DigraphFromSparse6String(Concatenation(":[___dCfEcdFjCIideLhIfJ",
>                                           "kLgkQge`RSbPTaOTbMNaS`QY"));
<digraph with 28 vertices, 84 edges>
gap> DigraphFromSparse6String(":I`ACWqHKhhccTF");
<digraph with 10 vertices, 30 edges>
gap> DigraphFromSparse6String(":U___gFecGdHcEdFcFdE`GHbILaJKbNaM`RS");
<digraph with 22 vertices, 66 edges>
gap> DigraphFromSparse6String(":U___fEcdcdIeHfGcFdE`GHbILaJKbNaM`RS");
<digraph with 22 vertices, 66 edges>
gap> DigraphFromSparse6String(":U___fEcdGcdeJfIcFdEbLNaKM`H`GbIRaJQ");
<digraph with 22 vertices, 66 edges>
gap> gr := Digraph([[2], [1, 4], [5], [2], [3]]);
<digraph with 5 vertices, 6 edges>
gap> str := Sparse6String(gr);
":Dapj"
gap> DigraphFromSparse6String(str);
<digraph with 5 vertices, 6 edges>
gap> gr := Digraph(231, [1, 1, 3, 4], [3, 4, 1, 1]);
<digraph with 231 vertices, 4 edges>
gap> str := Sparse6String(gr);
":~?Bf_O?_F"
gap> DigraphFromSparse6String(str);
<digraph with 231 vertices, 4 edges>
gap> gr := Digraph(rec(nrvertices := 2 ^ 17, source := [1, 1, 3, 4, 10, 100],
> range := [3, 4, 1, 1, 100, 10]));
<digraph with 131072 vertices, 6 edges>
gap> str := Sparse6String(gr);
":~_??_?A???_??_@b??H"
gap> DigraphFromSparse6String(str);
<digraph with 131072 vertices, 6 edges>

#T# DigraphFromDigraph6String and Digraph6String
gap> gr := Digraph([[5], [1, 2, 5], [1], [2], [4]]);
<digraph with 5 vertices, 7 edges>
gap> str := Digraph6String(gr);
"+DWg?[?"
gap> DigraphFromDigraph6String(str);
<digraph with 5 vertices, 7 edges>
gap> gr := Digraph(231, [1 .. 100], [1 .. 100] * 0 + 200);
<digraph with 231 vertices, 100 edges>
gap> str := Digraph6String(gr);;
gap> DigraphFromDigraph6String(str);
<digraph with 231 vertices, 100 edges>

#T# DigraphFromDiSparse6String and DiSparse6String
gap> gr := Digraph([[1, 4], [2, 3, 4], [2, 4], [2]]);
<digraph with 4 vertices, 8 edges>
gap> str := DiSparse6String(gr);
".CgXoHe@J"
gap> DigraphFromDiSparse6String(str) = gr;
true
gap> gr := Digraph(rec(nrvertices := 1617, source := [1 .. 100],
> range := Concatenation([1 .. 50], [1 .. 50] * 0 + 51)));
<digraph with 1617 vertices, 100 edges>
gap> str := DiSparse6String(gr);;
gap> DigraphFromDiSparse6String(str) = gr;
true
gap> gr := Digraph(rec(nrvertices := 2 ^ 17, source := [1 .. 100],
> range := Concatenation([50 .. 98], [-1050 .. -1000] * - 1)));
<digraph with 131072 vertices, 100 edges>
gap> str := DiSparse6String(gr);;
gap> DigraphFromDiSparse6String(str) = gr;
true
gap> gr := Digraph([[1, 1, 4], [2, 3, 4], [2, 4], [2]]);
<multidigraph with 4 vertices, 9 edges>
gap> str := DiSparse6String(gr);
".CgXo?eWCn"
gap> gr = DigraphFromDiSparse6String(str);
true
gap> gr := Digraph(rec(nrvertices := 7890, source := [1 .. 100] * 0 + 1000,
> range := [1 .. 100] * 0 + 2000));
<multidigraph with 7890 vertices, 100 edges>
gap> str := DiSparse6String(gr);;
gap> gr = DigraphFromDiSparse6String(str);
true

#T# WriteDigraphs and ReadDigraphs
gap> gr := [];;
gap> gr[1] := Digraph(2 ^ 16, [1, 1, 3, 4, 7, 10, 100],
> [3, 4, 1, 1, 3, 100, 10]);
<digraph with 65536 vertices, 7 edges>
gap> gr[2] := Digraph(1000,
> [1 .. 1000],
> Concatenation([2 .. 1000], [1]));
<digraph with 1000 vertices, 1000 edges>
gap> gr[3] := Digraph([[1, 1, 4], [2, 3, 4], [2, 4], [2], [1, 3, 3, 5]]);
<multidigraph with 5 vertices, 13 edges>
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/test.ds6");;
gap> WriteDigraphs(filename, gr, "w");
gap> ReadDigraphs(filename);
[ <digraph with 65536 vertices, 7 edges>, 
  <digraph with 1000 vertices, 1000 edges>, 
  <multidigraph with 5 vertices, 13 edges> ]
gap> gr[1] := Digraph([[5], [1, 2, 5], [1], [2], [4]]);
<digraph with 5 vertices, 7 edges>
gap> gr[2] := Digraph(rec(nrvertices := 105, source := [1 .. 100],
> range := [1 .. 100] * 0 + 52));
<digraph with 105 vertices, 100 edges>
gap> gr[3] := EmptyDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> gr[4] := Digraph([[6, 7], [6, 9], [1, 3, 4, 5, 8, 9],
> [1, 2, 3, 4, 5, 6, 7, 10], [1, 5, 6, 7, 10], [2, 4, 5, 9, 10],
> [3, 4, 5, 6, 7, 8, 9, 10], [1, 3, 5, 7, 8, 9], [1, 2, 5], [1, 2]]);
<digraph with 10 vertices, 47 edges>
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/test.d6");;
gap> WriteDigraphs(filename, gr, "w");
gap> ReadDigraphs(filename);
[ <digraph with 5 vertices, 7 edges>, <digraph with 105 vertices, 100 edges>, 
  <digraph with 0 vertices, 0 edges>, <digraph with 10 vertices, 47 edges> ]
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/test.txt");;
gap> WriteDigraphs(filename, gr, "w");
gap> ReadDigraphs(filename); # Note that some edges in gr[2] are lost
[ <digraph with 5 vertices, 7 edges>, <digraph with 100 vertices, 100 edges>, 
  <digraph with 0 vertices, 0 edges>, <digraph with 10 vertices, 47 edges> ]
gap> gr := [];;
gap> gr[1] := Digraph(30, [1, 2], [2, 1]);
<digraph with 30 vertices, 2 edges>
gap> gr[2] := Digraph([[2], [1, 4], [5], [2], [3]]);
<digraph with 5 vertices, 6 edges>
gap> gr[3] := Digraph([[2], [1]]);
<digraph with 2 vertices, 2 edges>
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/test.g6");;
gap> WriteDigraphs(filename, gr, "w");
gap> rdgr := ReadDigraphs(filename);;
gap> gr = rdgr;
true
gap> gr[3] := Digraph([[1, 2], [1, 2]]);
<digraph with 2 vertices, 4 edges>
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/test.s6.bzip2");;
gap> WriteDigraphs(filename, gr, "w");
gap> rdgr := ReadDigraphs(filename);;
gap> gr = rdgr;
true
gap> newfilename := Concatenation(DIGRAPHS_Dir(), "/tst/out/test.bzip2");;
gap> IO_rename(filename, newfilename);
true
gap> rdgr := ReadDigraphs(newfilename);
Error, Digraphs: ReadDigraphs: usage,
cannot determine the file format,
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/test.h6.bzip2");;
gap> IO_rename(newfilename, filename);
true
gap> rdgr := ReadDigraphs(filename);
Error, Digraphs: ReadDigraphs: usage,
cannot determine the file format,

#T# WritePlainTextDigraph and ReadPlainTextDigraph
gap> gr := Digraph([[1, 2], [2, 3], []]);
<digraph with 3 vertices, 4 edges>
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/plain.txt");;
gap> WritePlainTextDigraph(1, 2, 3, 4);
Error, Digraphs: WritePlainTextDigraph: usage,
WritePlainTextDigraph(filename, digraph, delimiter, offset),
gap> WritePlainTextDigraph(".", gr, ",", -2);
Error, Digraphs: WritePlainTextDigraph:
can not open file .,
gap> WritePlainTextDigraph(filename, gr, ',', -3);
gap> WritePlainTextDigraph(filename, gr, ",", -1);
gap> ReadPlainTextDigraph(1, 2, 3, 4);
Error, Digraphs: ReadPlainTextDigraph: usage,
ReadPlainTextDigraph(filename, delimiter, offset, ignore),
gap> ReadPlainTextDigraph(filename, ",", 1, ['i', 'd']);
<digraph with 3 vertices, 4 edges>
gap> ReadPlainTextDigraph(filename, ',', 1, 'i');
<digraph with 3 vertices, 4 edges>
gap> last = gr;
true

#T# TournamentLineDecoder
gap> gr := TournamentLineDecoder("101001");
<digraph with 4 vertices, 6 edges>
gap> OutNeighbours(gr);
[ [ 2, 4 ], [  ], [ 1, 2, 4 ], [ 2 ] ]
gap> gr := TournamentLineDecoder("");
<digraph with 1 vertex, 0 edges>

#T# AdjacencyMatrixUpperTriangleLineDecoder
gap> gr := AdjacencyMatrixUpperTriangleLineDecoder("100101");
<digraph with 4 vertices, 3 edges>
gap> OutNeighbours(gr);
[ [ 2 ], [ 3 ], [ 4 ], [  ] ]
gap> gr := AdjacencyMatrixUpperTriangleLineDecoder("11y111x111");
<digraph with 5 vertices, 8 edges>
gap> OutNeighbours(gr);
[ [ 2, 3, 5 ], [ 3, 4 ], [ 4, 5 ], [ 5 ], [  ] ]
gap> gr := AdjacencyMatrixUpperTriangleLineDecoder("");
<digraph with 1 vertex, 0 edges>

#T# TCodeDecoder
gap> gr := TCodeDecoder("3 2 0 2 2 1");
<digraph with 3 vertices, 2 edges>
gap> OutNeighbours(gr);
[ [ 3 ], [  ], [ 2 ] ]
gap> gr = TCodeDecoderNC("3 2 0 2 2 1");
true
gap> gr := TCodeDecoder("12 3 0 10 6 2 8 8");
<digraph with 12 vertices, 3 edges>
gap> OutNeighbours(gr);
[ [ 11 ], [  ], [  ], [  ], [  ], [  ], [ 3 ], [  ], [ 9 ], [  ], [  ], [  ] ]
gap> gr := TCodeDecoder(3);
Error, Digraphs: TCodeDecoder: usage,
first argument <str> must be a string,
gap> gr := TCodeDecoder("gr 5");
Error, Digraphs: TCodeDecoder: usage,
1st argument <str> must be a string of space-separated non-negative integers,
gap> gr := TCodeDecoder("10");
Error, Digraphs: TCodeDecoder: usage,
first argument <str> must be a string of at least two integers,
gap> gr := TCodeDecoder("2 2 0 4 1 2");
Error, Digraphs: TCodeDecoder: usage,
vertex numbers must be in the range [0..n-1],
where n is the first entry in <str>,
gap> gr := TCodeDecoder("3 2 0 2");
Error, Digraphs: TCodeDecoder: usage,
<str> must contain at least 2e+2 entries,
where e is the number of edges (the 2nd entry in <str>),
gap> gr := TCodeDecoderNC("100 5 0 12 48 49 99 1 54 49 49 49");
<digraph with 100 vertices, 5 edges>

#T# Empty strings should not create graphs
gap> DigraphFromGraph6String("");
Error, Digraphs: DigraphFromGraph6String: usage,
the input string should be non-empty,
gap> DigraphFromDigraph6String("");
Error, Digraphs: DigraphFromDigraph6String: usage,
the input string should be non-empty,
gap> DigraphFromSparse6String("");
Error, Digraphs: DigraphFromSparse6String: usage,
the input string should be non-empty,
gap> DigraphFromDiSparse6String("");
Error, Digraphs: DigraphFromDiSparse6String: usage,
the input string should be non-empty,

#T# DiSparse6 
gap> DigraphFromDiSparse6String("I'm a string");
Error, Digraphs: DigraphFromDiSparse6String: usage,
<s> must be a string in disparse6 format,
gap> DigraphFromDiSparse6String(".~~");
Error, Digraphs: DigraphFromDiSparse6String: usage,
<s> must be a string in disparse6 format,
gap> DigraphFromDiSparse6String(".~~??@???o??N");
<digraph with 262144 vertices, 0 edges>
gap> DigraphFromDiSparse6String(".~??");
Error, Digraphs: DigraphFromDiSparse6String: usage,
.~?? is not a valid disparse6 input,
gap> DiSparse6String(CompleteDigraph(1));
".@~"
gap> DigraphFromDiSparse6String(".@~");
<digraph with 1 vertex, 0 edges>
gap> gr := Digraph([[], [], [1, 2]]);;
gap> DiSparse6String(gr);
".BoN"

#T# Plain text encoding  
gap> gr := CompleteDigraph(3);
<digraph with 3 vertices, 6 edges>
gap> str := PlainTextString(gr);
"0 1  0 2  1 0  1 2  2 0  2 1"
gap> gr2 := DigraphFromPlainTextString(str);
<digraph with 3 vertices, 6 edges>
gap> gr = gr2;
true

#T# Invalid sizes
gap> DigraphFromGraph6String("~llk");
Error, Digraphs: DigraphFromGraph6String: usage,
<s> is not a valid graph6 input,
gap> DigraphFromDigraph6String("+~llk");
Error, Digraphs: DigraphFromDigraph6String: usage,
<s> must be a string in Digraph6 format,
gap> DigraphFromSparse6String(":~~l");
Error, Digraphs: DigraphFromSparse6String: usage,
<s> must be a string in Sparse6 format,
gap> DigraphFromSparse6String(":~hl");
Error, Digraphs: DigraphFromSparse6String: usage,
<s> must be a string in Sparse6 format,
gap> DigraphFromDiSparse6String(".~~l");
Error, Digraphs: DigraphFromDiSparse6String: usage,
<s> must be a string in disparse6 format,

#T# Special format characters
gap> DigraphFromDigraph6String("x");
Error, Digraphs: DigraphFromDigraph6String: usage,
<s> must be a string in Digraph6 format,
gap> DigraphFromSparse6String("y");
Error, Digraphs: DigraphFromSparse6String: usage,
<s> must be a string in Sparse6 format,
gap> DigraphFromDiSparse6String("z");
Error, Digraphs: DigraphFromDiSparse6String: usage,
<s> must be a string in disparse6 format,

#T# Special format characters
gap> Sparse6String(ChainDigraph(3));
Error, Digraphs: Sparse6String: usage,
the argument <graph> must be a symmetric digraph,
gap> Sparse6String(CompleteDigraph(1));
":@"
gap> gr := Digraph([[1], []]);;
gap> Sparse6String(gr);
":AF"

#T# DigraphFromSparse6String: an unusual but valid case
gap> DigraphFromSparse6String(":TdBkJ`Kq?x");
<digraph with 21 vertices, 10 edges>
gap> Sparse6String(last);
":TdBkJ`Kq?"

#T# DigraphPlainTextLineDecoder: bad input
gap> DigraphPlainTextLineDecoder(" ", "  ", 1, ".");
Error, Digraphs: DigraphPlainTextLineDecoder: usage,
DigraphPlainTextLineDecoder(delimiter, [,delimiter], offset),

#T# WriteDigraphs: bad input
gap> list := [CompleteDigraph(4), CycleDigraph(8), "hello world"];;
gap> WriteDigraphs(72, list, "w");
Error, Digraphs: WriteDigraphs: usage,
<name> must be a string,
gap> WriteDigraphs("mylist", list, "w");
Error, Digraphs: WriteDigraphs: usage,
<digraphs> must be a list of digraphs,

#T# WriteDigraphs: automatic format selection
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/choose.gz");;
gap> list := [CompleteDigraph(5), EmptyDigraph(100), CompleteDigraph(3)];;
gap> ForAll(list, IsSymmetricDigraph);
true
gap> WriteDigraphs(filename, list, "w");
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/choose.s6.gz");;
gap> list2 := ReadDigraphs(filename);;
gap> list = list2;
true
gap> mult := Digraph([[1, 2], [1, 1, 3], []]);;
gap> list := [CompleteDigraph(5), EmptyDigraph(100), mult];;
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/choosemult.gz");;
gap> WriteDigraphs(filename, list, "w");
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/choosemult.ds6.gz");;
gap> list2 := ReadDigraphs(filename);;
gap> list = list2;
true
gap> list := [CompleteDigraph(3), CycleDigraph(100), EmptyDigraph(2)];;
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/choose");;
gap> WriteDigraphs(filename, list, "w");
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/choose.ds6");;
gap> list2 := ReadDigraphs(filename);;
gap> list = list2;
true
gap> gr := Digraph([[2, 2], [1, 1]]);;
gap> IsSymmetricDigraph(gr);
true
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/alone");;
gap> WriteDigraphs(filename, [gr], "w");
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/alone.ds6");;
gap> list2 := ReadDigraphs(filename);
[ <multidigraph with 2 vertices, 4 edges> ]
gap> list2[1] = gr;
true
gap> list := [CompleteDigraph(10), CompleteDigraph(15)];;
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/dense.bzip2");;
gap> WriteDigraphs(filename, list, "w");
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/dense.g6.bzip2");;
gap> list2 := ReadDigraphs(filename);;
gap> list = list2;
true
gap> gr := [Digraph([[1, 2, 3, 4], [1, 2, 3, 4], [1, 3, 4], [1, 2, 3, 4]])];
[ <digraph with 4 vertices, 15 edges> ]
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/dense");;
gap> WriteDigraphs(filename, gr, "w");
gap> filename := Concatenation(DIGRAPHS_Dir(), "/tst/out/dense.d6");;
gap> list2 := ReadDigraphs(filename);;
gap> gr = list2;
true
gap> filename := "does/not/exist.gz";;
gap> WriteDigraphs(filename, gr, "w");
Error, Digraphs: WriteDigraphs: usage,
cannot open file does/not/exist.d6.gz,

#T# DigraphPlainTextLineDecoder: bad input
gap> Graph6String(ChainDigraph(4));
Error, Digraphs: Graph6String: usage,
<graph> must be symmetric and have no loops or multiple edges,
gap> DIGRAPHS_Graph6Length(-1);
fail
gap> DIGRAPHS_Graph6Length(68719476737);
fail
gap> DIGRAPHS_Graph6Length(258748);
[ 63, 63, 0, 0, 0, 63, 10, 60 ]
gap> WriteDigraphs(1, 1, "w");
Error, Digraphs: WriteDigraphs: usage,
<name> must be a string,
gap> WriteDigraphs("string", [1], "w");
Error, Digraphs: WriteDigraphs: usage,
<digraphs> must be a list of digraphs,
gap> Sparse6String(EmptyDigraph(2 ^ 20));
":~~??C???"
gap> DigraphFromSparse6String(":~~??C???");
<digraph with 1048576 vertices, 0 edges>

#T# DIGRAPHS_UnbindVariables
gap> Unbind(gr);
gap> Unbind(list);
gap> Unbind(list2);
gap> Unbind(l);
gap> Unbind(filename);
gap> Unbind(newfilename);
gap> Unbind(source);
gap> Unbind(range);
gap> Unbind(str);
gap> Unbind(rdgr);

#E#
gap> STOP_TEST("Digraphs package: standard/io.tst");
