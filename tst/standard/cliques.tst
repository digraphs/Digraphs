#############################################################################
##
#W  standard/cliques.tst
#Y  Copyright (C) 2016                                   Wilfred A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/cliques.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#T# IsClique and IsMaximalClique

# Cliques of the complete digraph
gap> gr := CompleteDigraph(5);;
gap> IsClique(gr, []);
true
gap> IsClique(gr, [4]);
true
gap> IsClique(gr, [4, 3]);
true
gap> IsClique(gr, [4, 1, 3]);
true
gap> IsClique(gr, [4, 2, 3, 1]);
true
gap> IsClique(gr, [1 , 5, 3, 4, 2]);
true
gap> gr := Digraph([
> [2, 3, 4, 5, 7, 8, 11, 12], [1, 3, 4, 6, 7, 9, 11, 13],
> [1, 2, 5, 6, 8, 9, 12, 13], [1, 2, 5, 6, 7, 10, 11, 14],
> [1, 3, 4, 6, 8, 10, 12, 14], [2, 3, 4, 5, 9, 10, 13, 14],
> [1, 2, 4, 8, 9, 10, 11, 15], [1, 3, 5, 7, 9, 10, 12, 15],
> [2, 3, 6, 7, 8, 10, 13, 15], [4, 5, 6, 7, 8, 9, 14, 15],
> [1, 2, 4, 7, 12, 13, 14, 15], [1, 3, 5, 8, 11, 13, 14, 15],
> [2, 3, 6, 9, 11, 12, 14, 15], [4, 5, 6, 10, 11, 12, 13, 15],
> [7, 8, 9, 10, 11, 12, 13, 14]]);
<digraph with 15 vertices, 120 edges>
gap> IsClique(gr, [1, 2, 4, 7, 11]);
true
gap> IsClique(gr, [1, 2, 3]);
true
gap> gr := Digraph([
> [2, 3, 4, 5, 7, 8, 11, 12], [1, 3, 4, 6, 7, 9, 11, 13],
> [1, 2, 5, 6, 8, 9, 12, 13], [1, 2, 5, 6, 7, 10, 11, 14],
> [1, 3, 4, 6, 8, 10, 12, 14], [2, 3, 4, 5, 9, 10, 13, 14],
> [1, 2, 4, 8, 9, 10, 11, 15], [1, 3, 5, 7, 9, 10, 12, 15],
> [2, 3, 6, 7, 8, 10, 13, 15], [4, 5, 6, 7, 8, 9, 14, 15],
> [1, 2, 4, 7, 12, 13, 14, 15], [1, 3, 5, 8, 11, 13, 14, 15],
> [2, 3, 6, 9, 11, 12, 14, 15], [4, 5, 6, 10, 11, 12, 13, 15],
> [7, 8, 9, 10, 11, 12, 13, 14]]);
<digraph with 15 vertices, 120 edges>
gap> IsMaximalClique(gr, [1, 2, 4, 7, 11]);
true
gap> IsMaximalClique(gr, [1, 2, 3]);
true

##T# IsIndependentSet and IsMaximalIndependentSet
#gap>
##T# DigraphMaximalClique
#gap>
#
##T# DigraphIndependentSet
#gap>
#
##T# DigraphMaximalCliques
#gap>
#
##T# DigraphMaximalIndependentSets
#gap>
#

#T# CliquesFinder: error checking
gap> CliquesFinder(Group(()), fail, fail, fail, fail, fail, fail, fail, fail);
Error, Digraphs: CliquesFinder: usage,
the first argument <gr> must be a digraph,
gap> gr := CompleteDigraph(5);;
gap> CliquesFinder(gr, [], fail, fail, fail, fail, fail, fail, fail);
Error, Digraphs: CliquesFinder: usage,
the second argument <hook> has to be either fail, or a function with two
arguments,
gap> f := function(a) return; end;;
gap> CliquesFinder(gr, f, fail, fail, fail, fail, fail, fail, fail);
Error, Digraphs: CliquesFinder: usage,
the second argument <hook> has to be either fail, or a function with two
arguments,
gap> CliquesFinder(gr, fail, fail, fail, fail, fail, fail, fail, fail);
Error, Digraphs: CliquesFinder: usage,
when the fourth argument <hook> is fail, the third argument <user_param> has
to be a list,
gap> f := function(a, b) return; end;;
gap> CliquesFinder(gr, f, fail, fail, fail, fail, fail, fail, fail);
Error, Digraphs: CliquesFinder: usage,
the fourth argument <limit> has to be either infinity, or a positive integer,
gap> CliquesFinder(gr, fail, [], infinity, fail, fail, fail, fail, fail);
Error, Digraphs: CliquesFinder: usage,
the fifth argument <include> and the sixth argument <exclude> have to be
(possibly empty) duplicate-free lists of vertices of the digraph in the first
argument <gr>,
gap> CliquesFinder(gr, fail, [], infinity, [0, 'a'], fail, fail, fail, fail);
Error, Digraphs: CliquesFinder: usage,
the fifth argument <include> and the sixth argument <exclude> have to be
(possibly empty) duplicate-free lists of vertices of the digraph in the first
argument <gr>,
gap> CliquesFinder(gr, fail, [], infinity, [0], fail, fail, fail, fail);
Error, Digraphs: CliquesFinder: usage,
the fifth argument <include> and the sixth argument <exclude> have to be
(possibly empty) duplicate-free lists of vertices of the digraph in the first
argument <gr>,
gap> CliquesFinder(gr, fail, [], infinity, [1, 1], fail, fail, fail, fail);
Error, Digraphs: CliquesFinder: usage,
the fifth argument <include> and the sixth argument <exclude> have to be
(possibly empty) duplicate-free lists of vertices of the digraph in the first
argument <gr>,
gap> CliquesFinder(gr, fail, [], infinity, [1], fail, fail, fail, fail);
Error, Digraphs: CliquesFinder: usage,
the fifth argument <include> and the sixth argument <exclude> have to be
(possibly empty) duplicate-free lists of vertices of the digraph in the first
argument <gr>,
gap> CliquesFinder(gr, fail, [], infinity, [1], [0, 'a'], fail, fail, fail);
Error, Digraphs: CliquesFinder: usage,
the fifth argument <include> and the sixth argument <exclude> have to be
(possibly empty) duplicate-free lists of vertices of the digraph in the first
argument <gr>,
gap> CliquesFinder(gr, fail, [], infinity, [1], [0], fail, fail, fail);
Error, Digraphs: CliquesFinder: usage,
the fifth argument <include> and the sixth argument <exclude> have to be
(possibly empty) duplicate-free lists of vertices of the digraph in the first
argument <gr>,
gap> CliquesFinder(gr, fail, [], infinity, [1], [1, 1], fail, fail, fail);
Error, Digraphs: CliquesFinder: usage,
the fifth argument <include> and the sixth argument <exclude> have to be
(possibly empty) duplicate-free lists of vertices of the digraph in the first
argument <gr>,
gap> CliquesFinder(gr, fail, [], infinity, [1], [1], fail, fail, fail);
Error, Digraphs: CliquesFinder: usage,
the seventh argument <max> must be either true or false,
gap> CliquesFinder(gr, fail, [], infinity, [1], [1], false, 0, fail);
Error, Digraphs: CliquesFinder: usage,
the eighth argument <size> has to be either fail, or a positive integer,
gap> CliquesFinder(gr, fail, [], infinity, [1], [1], false, 1, fail);
Error, Digraphs: CliquesFinder: usage,
the ninth argument <reps> must be either true or false,
gap> CliquesFinder(gr, fail, [], infinity, [1], [], false, 1, true);
Error, Digraphs: CliquesFinder: usage,
if the ninth argument <reps> is true then the fourth and fifth arguments
<include> and <exclude> must be invariant under the action of the DigraphGroup
of <gr>,
gap> CliquesFinder(gr, fail, [], infinity, [], [1], false, 1, true);
Error, Digraphs: CliquesFinder: usage,
if the ninth argument <reps> is true then the fourth and fifth arguments
<include> and <exclude> must be invariant under the action of the DigraphGroup
of <gr>,
gap> CliquesFinder(gr, fail, [], infinity, [1 .. 5], [1 .. 5], false, 1, true);
[  ]
gap> CliquesFinder(gr, fail, [], infinity, [1], [1], false, 1, false);
[  ]

#T# DIGRAPHS_BronKerbosch: easy cases
gap> gr := ChainDigraph(5);;
gap> CliquesFinder(gr, fail, [], infinity, [], [1 .. 4], false, 3, false);
[  ]
gap> CliquesFinder(gr, fail, [], infinity, [1, 2], [], false, 3, false);
[  ]
gap> gr := CompleteDigraph(5);;
gap> CliquesFinder(gr, fail, [], infinity, [1 .. 5], [], false, 1, false);
[  ]
gap> CliquesFinder(gr, fail, [], infinity, [1 .. 5], [1 .. 5], false, fail,
> false);
[  ]
gap> CliquesFinder(gr, fail, [], infinity, [1], [], false, 1, false);
[ [ 1 ] ]
gap> CliquesFinder(gr, fail, [], infinity, [], [], false, 1, false);
[ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ] ]

#T# DIGRAPHS_BronKerbosch: getting code coverage
gap> gr := CompleteDigraph(5);;
gap> CliquesFinder(gr, fail, [], infinity, [], [], true, 4, true);
[  ]
gap> CliquesFinder(gr, fail, [], infinity, [], [], true, 5, true);
[ [ 1, 2, 3, 4, 5 ] ]
gap> CliquesFinder(gr, fail, [], infinity, [], [], true, fail, true);
[ [ 1, 2, 3, 4, 5 ] ]
gap> CliquesFinder(gr, fail, [], infinity, [], [], false, fail, true);
[ [ 1 ], [ 1, 2 ], [ 1, 2, 3 ], [ 1, 2, 3, 4 ], [ 1, 2, 3, 4, 5 ] ]
gap> out := CliquesFinder(gr, fail, [], infinity, [], [], false, fail, false);
[ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], 
  [ 1, 5 ], [ 2, 4 ], [ 2, 5 ], [ 3, 4 ], [ 3, 5 ], [ 4, 5 ], [ 1, 2, 3 ], 
  [ 1, 2, 4 ], [ 1, 2, 5 ], [ 1, 3, 4 ], [ 1, 3, 5 ], [ 2, 3, 4 ], 
  [ 1, 4, 5 ], [ 2, 3, 5 ], [ 2, 4, 5 ], [ 3, 4, 5 ], [ 1, 2, 3, 4 ], 
  [ 1, 2, 3, 5 ], [ 1, 2, 4, 5 ], [ 1, 3, 4, 5 ], [ 2, 3, 4, 5 ], 
  [ 1, 2, 3, 4, 5 ] ]
gap> Length(out);
31
gap> lim := 32;;
gap> CliquesFinder(gr, fail, [], lim, [], [], false, fail, false) = out;
true
gap> lim := 12;;
gap> out := CliquesFinder(gr, fail, [], lim, [], [], false, fail, false);
[ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], 
  [ 1, 5 ], [ 2, 4 ], [ 2, 5 ] ]
gap> Length(out) = lim;
true
gap> out := CliquesFinder(gr, fail, [], lim, [1, 4], [], false, fail, false);
[ [ 1, 4 ], [ 1, 2, 4 ], [ 1, 3, 4 ], [ 1, 4, 5 ], [ 1, 2, 3, 4 ], 
  [ 1, 2, 4, 5 ], [ 1, 3, 4, 5 ], [ 1, 2, 3, 4, 5 ] ]
gap> out := CliquesFinder(gr, fail, [], lim, [1, 4], [], false, 4, false);
[ [ 1, 2, 3, 4 ], [ 1, 2, 4, 5 ], [ 1, 3, 4, 5 ] ]
gap> lim := infinity;;
gap> out := CliquesFinder(gr, fail, [], lim, [2], [4, 5], false, fail, false);
[ [ 2 ], [ 1, 2 ], [ 2, 3 ], [ 1, 2, 3 ] ]
gap> out := CliquesFinder(gr, fail, [], lim, [], [3, 4, 5], false, fail, false);
[ [ 1 ], [ 2 ], [ 1, 2 ] ]
gap> out := CliquesFinder(gr, fail, [], lim, [], [3, 4, 5], false, 2, false);
[ [ 1, 2 ] ]
gap> gr := DigraphSymmetricClosure(ChainDigraph(5));;
gap> out := CliquesFinder(gr, fail, [], lim, [], [], true, 3, true);
[  ]

#T# DIGRAPHS_UnbindVariables
gap> Unbind(gr);
gap> Unbind(f);
gap> Unbind(out);

#E#
gap> STOP_TEST("Digraphs package: standard/cliques.tst");
