#############################################################################
##
#W  standard/cliques.tst
#Y  Copyright (C) 2016                                      Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/cliques.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#  IsClique and IsMaximalClique
gap> gr := CompleteDigraph(5);;
gap> IsClique(gr, [6]);
Error, Digraphs: IsClique: usage,
the second argument <clique> must be a duplicate-free list of vertices of the
digraph <gr>,
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
gap> IsClique(gr, [1, 5, 3, 4, 2]);
true
gap> IsClique(gr, [1, 1]);
Error, Digraphs: IsClique: usage,
the second argument <clique> must be a duplicate-free list of vertices of the
digraph <gr>,
gap> gr := Digraph([
> [2, 3, 4, 5, 7, 8, 11, 12], [1, 3, 4, 6, 7, 9, 11, 13],
> [1, 2, 5, 6, 8, 9, 12, 13], [1, 2, 5, 6, 7, 10, 11, 14],
> [1, 3, 4, 6, 8, 10, 12, 14], [2, 3, 4, 5, 9, 10, 13, 14],
> [1, 2, 4, 8, 9, 10, 11, 15], [1, 3, 5, 7, 9, 10, 12, 15],
> [2, 3, 6, 7, 8, 10, 13, 15], [4, 5, 6, 7, 8, 9, 14, 15],
> [1, 2, 4, 7, 12, 13, 14, 15], [1, 3, 5, 8, 11, 13, 14, 15],
> [2, 3, 6, 9, 11, 12, 14, 15], [4, 5, 6, 10, 11, 12, 13, 15],
> [7, 8, 9, 10, 11, 12, 13, 14]]);
<immutable digraph with 15 vertices, 120 edges>
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
<immutable digraph with 15 vertices, 120 edges>
gap> IsMaximalClique(gr, [1, 2, 4, 7, 11]);
true
gap> IsMaximalClique(gr, [1, 2, 3]);
true
gap> IsMaximalClique(gr, [16]);
Error, Digraphs: IsClique: usage,
the second argument <clique> must be a duplicate-free list of vertices of the
digraph <gr>,
gap> IsMaximalClique(gr, [1, 1]);
Error, Digraphs: IsClique: usage,
the second argument <clique> must be a duplicate-free list of vertices of the
digraph <gr>,
gap> IsMaximalClique(gr, [1, 2, 4, 7, 11, 13]);
false
gap> gr := CompleteDigraph(5);;
gap> IsMaximalClique(gr, [1]);
false

#  IsIndependentSet and IsMaximalIndependentSet
gap> gr := CycleDigraph(10);;
gap> IsIndependentSet(gr, []);
true
gap> IsIndependentSet(gr, [1, 1]);
Error, Digraphs: IsIndependentSet: usage,
the second argument <set> must be a duplicate-free list of vertices of the
digraph <gr>,
gap> IsIndependentSet(gr, [11]);
Error, Digraphs: IsIndependentSet: usage,
the second argument <set> must be a duplicate-free list of vertices of the
digraph <gr>,
gap> IsIndependentSet(gr, [1, 2]);
false
gap> IsIndependentSet(gr, [1, 3]);
true
gap> IsMaximalIndependentSet(gr, []);
false
gap> IsMaximalIndependentSet(gr, [1, 2]);
false
gap> IsMaximalIndependentSet(gr, [1, 3]);
false
gap> gr := Digraph([[], [], [], [1, 2, 3]]);
<immutable digraph with 4 vertices, 3 edges>
gap> IsIndependentSet(gr, [1, 2]);
true
gap> IsMaximalIndependentSet(gr, [1, 2]);
false
gap> IsIndependentSet(gr, [1, 2, 3]);
true
gap> IsMaximalIndependentSet(gr, [1, 2, 3]);
true
gap> gr := Digraph([[3], [3], [3]]);
<immutable digraph with 3 vertices, 3 edges>
gap> IsMaximalIndependentSet(gr, [1, 2]);
true

#  DigraphMaximalIndependentSet and DigraphIndependentSet
gap> gr := Digraph([[3], [3], [3]]);
<immutable digraph with 3 vertices, 3 edges>
gap> DigraphMaximalIndependentSet();
Error, Digraphs: DigraphMaximalIndependentSet: usage,
this function requires a least one argument,
gap> DigraphMaximalIndependentSet(3);
Error, Digraphs: DigraphMaximalIndependentSet: usage,
the first argument must be a digraph,
gap> DigraphIndependentSet();
Error, Digraphs: DigraphIndependentSet: usage,
this function requires a least one argument,
gap> DigraphIndependentSet(3);
Error, Digraphs: DigraphIndependentSet: usage,
the first argument must be a digraph,
gap> DigraphMaximalIndependentSet(gr);
[ 3 ]
gap> DigraphIndependentSet(gr);
[ 3 ]
gap> DigraphMaximalIndependentSet(gr, [], [], 2);
[ 1, 2 ]
gap> DigraphIndependentSet(gr, [], [], 3);
fail

#  DigraphMaximalIndependentSetsReps and DigraphIndependentSetsReps
gap> gr := EmptyDigraph(1);;
gap> DigraphMaximalIndependentSetsReps();
Error, Digraphs: DigraphMaximalIndependentSetsReps: usage,
this function requires at least one argument,
gap> DigraphIndependentSetsReps();
Error, Digraphs: DigraphIndependentSetsReps: usage,
this function requires at least one argument,
gap> DigraphMaximalIndependentSets();
Error, Digraphs: DigraphMaximalIndependentSetsReps: usage,
this function requires at least one argument,
gap> DigraphIndependentSets();
Error, Digraphs: DigraphIndependentSets: usage,
this function requires at least one argument,
gap> DigraphMaximalIndependentSetsReps(1);
Error, Digraphs: DigraphMaximalIndependentSetsReps: usage,
the first argument <digraph> must be a digraph,
gap> DigraphIndependentSetsReps(1);
Error, Digraphs: DigraphIndependentSetsReps: usage,
the first argument <digraph> must be a digraph,
gap> DigraphMaximalIndependentSets(1);
Error, Digraphs: DigraphMaximalIndependentSets: usage,
the first argument <digraph> must be a digraph,
gap> DigraphIndependentSets(1);
Error, Digraphs: DigraphIndependentSets: usage,
the first argument <digraph> must be a digraph,
gap> DigraphMaximalIndependentSetsReps(gr);
[ [ 1 ] ]
gap> DigraphMaximalIndependentSetsReps(gr);
[ [ 1 ] ]
gap> DigraphIndependentSetsReps(gr);
[ [ 1 ] ]
gap> DigraphMaximalIndependentSets(gr);
[ [ 1 ] ]
gap> DigraphIndependentSets(gr);
[ [ 1 ] ]
gap> DigraphMaximalIndependentSetsReps(gr, []);
[ [ 1 ] ]
gap> DigraphIndependentSetsReps(gr, []);
[ [ 1 ] ]
gap> DigraphMaximalIndependentSets(gr, []);
[ [ 1 ] ]
gap> DigraphIndependentSets(gr, []);
[ [ 1 ] ]
gap> DigraphMaximalIndependentSetsReps(gr, [], []);
[ [ 1 ] ]
gap> DigraphIndependentSetsReps(gr, [], []);
[ [ 1 ] ]
gap> DigraphMaximalIndependentSets(gr, [], []);
[ [ 1 ] ]
gap> DigraphIndependentSets(gr, [], []);
[ [ 1 ] ]
gap> DigraphMaximalIndependentSetsReps(gr, [], [], 1);
[ [ 1 ] ]
gap> DigraphIndependentSetsReps(gr, [], [], 1);
[ [ 1 ] ]
gap> DigraphMaximalIndependentSets(gr, [], [], 1);
[ [ 1 ] ]
gap> DigraphIndependentSets(gr, [], [], 1);
[ [ 1 ] ]
gap> DigraphMaximalIndependentSetsReps(gr, [], [], 1, 1);
[ [ 1 ] ]
gap> DigraphIndependentSetsReps(gr, [], [], 1, 1);
[ [ 1 ] ]
gap> DigraphMaximalIndependentSets(gr, [], [], 1, 1);
[ [ 1 ] ]
gap> DigraphIndependentSets(gr, [], [], 1, 1);
[ [ 1 ] ]
gap> gr := CompleteDigraph(10);;
gap> DigraphMaximalIndependentSetsRepsAttr(gr);
[ [ 1 ] ]
gap> DigraphMaximalIndependentSetsAttr(gr);
[ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ] ]

#  DigraphMaximalIndependentSets and DigraphIndependentSets
gap> gr := ChainDigraph(2);;
gap> DigraphMaximalIndependentSets(gr);
[ [ 1 ], [ 2 ] ]
gap> gr := CompleteDigraph(2);;
gap> DigraphMaximalIndependentSets(gr);
[ [ 1 ], [ 2 ] ]
gap> gr := DigraphFromDigraph6String("&FWsK?WSKC?");
<immutable digraph with 7 vertices, 14 edges>
gap> DigraphMaximalIndependentSetsReps(gr);
[ [ 1, 4 ], [ 1, 5 ], [ 2, 5, 7 ] ]
gap> Set(DigraphMaximalIndependentSets(gr));
[ [ 1, 4 ], [ 1, 5 ], [ 1, 6 ], [ 2, 4 ], [ 2, 5, 7 ], [ 2, 6, 7 ], [ 3, 4 ], 
  [ 3, 5, 7 ], [ 3, 6, 7 ] ]
gap> Set(DigraphMaximalIndependentSets(gr));
[ [ 1, 4 ], [ 1, 5 ], [ 1, 6 ], [ 2, 4 ], [ 2, 5, 7 ], [ 2, 6, 7 ], [ 3, 4 ], 
  [ 3, 5, 7 ], [ 3, 6, 7 ] ]
gap> DigraphIndependentSetsReps(gr);
[ [ 1 ], [ 1, 4 ], [ 1, 5 ], [ 2 ], [ 2, 5 ], [ 2, 5, 7 ], [ 2, 7 ], [ 7 ] ]
gap> Set(DigraphIndependentSets(gr));
[ [ 1 ], [ 1, 4 ], [ 1, 5 ], [ 1, 6 ], [ 2 ], [ 2, 4 ], [ 2, 5 ], 
  [ 2, 5, 7 ], [ 2, 6 ], [ 2, 6, 7 ], [ 2, 7 ], [ 3 ], [ 3, 4 ], [ 3, 5 ], 
  [ 3, 5, 7 ], [ 3, 6 ], [ 3, 6, 7 ], [ 3, 7 ], [ 4 ], [ 5 ], [ 5, 7 ], 
  [ 6 ], [ 6, 7 ], [ 7 ] ]

# DigraphMaximalClique and DigraphClique
gap> gr := CompleteDigraph(5);;
gap> DigraphMaximalClique();
Error, Digraphs: DigraphMaximalClique: usage,
this function requires at least one argument,
gap> DigraphClique();
Error, Digraphs: DigraphClique: usage,
this function requires at least one argument,
gap> DigraphMaximalClique(1);
Error, Digraphs: DIGRAPHS_Clique: usage,
the first argument <gr> must be a digraph,
gap> DigraphClique(1);
Error, Digraphs: DIGRAPHS_Clique: usage,
the first argument <gr> must be a digraph,
gap> DigraphMaximalClique(gr);
[ 5, 4, 3, 2, 1 ]
gap> DigraphClique(gr);
[ 5, 4, 3, 2, 1 ]
gap> DigraphMaximalClique(gr, [1, 1]);
Error, Digraphs: DIGRAPHS_Clique: usage,
the optional second argument <include> must be a duplicate-free list of
vertices of <gr>,
gap> DigraphMaximalClique(gr, [1], [1, 1]);
Error, Digraphs: DIGRAPHS_Clique: usage,
the optional third argument <exclude> must be a duplicate-free list of
vertices of <gr>,
gap> DigraphMaximalClique(gr, [1], [1], 0);
Error, Digraphs: DIGRAPHS_Clique: usage,
the optional fourth argument <size> must be a positive integer,
gap> gr := EmptyDigraph(5);;
gap> DigraphMaximalClique(gr, [1, 2], [3]);
fail
gap> DigraphMaximalClique(gr, [1, 2], [2]);
fail
gap> DigraphMaximalClique(gr, [1, 2], [3]);
fail
gap> DigraphMaximalClique(gr, [1], [2]);
[ 1 ]
gap> DigraphClique(gr, [1], [1]);
fail
gap> DigraphMaximalClique(CompleteDigraph(5), [1, 2], [3]);
fail
gap> DigraphClique(CompleteDigraph(5), [1, 2], []);
[ 1, 2, 5, 4, 3 ]

#  DigraphCliquesReps and DigraphMaximalCliquesReps
gap> DigraphCliquesReps();
Error, Digraphs: DigraphCliquesReps: usage,
this function requires at least one argument,
gap> DigraphCliques();
Error, Digraphs: DigraphCliques: usage,
this function requires at least one argument,
gap> gr := EmptyDigraph(5);;
gap> DigraphMaximalCliquesRepsAttr(gr);
[ [ 1 ] ]
gap> DigraphMaximalCliquesReps();
Error, Digraphs: DigraphMaximalCliquesReps: usage,
this function requires at least one argument,
gap> DigraphMaximalCliquesReps(gr);
[ [ 1 ] ]
gap> DigraphMaximalCliquesAttr(gr);
[ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ] ]
gap> DigraphMaximalCliques();
Error, Digraphs: DigraphMaximalCliques: usage,
this function requires at least one argument,
gap> DigraphMaximalCliques(gr);
[ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ] ]
gap> gr := EmptyDigraph(1);;
gap> DigraphMaximalCliques(gr);
[ [ 1 ] ]
gap> gr := DigraphFromDigraph6String("&DNNNF?");
<immutable digraph with 5 vertices, 15 edges>
gap> DigraphMaximalCliquesReps(gr);
[ [ 1, 3 ] ]
gap> Set(DigraphMaximalCliques(gr));
[ [ 1, 3 ], [ 1, 4 ], [ 2, 4 ], [ 2, 5 ], [ 3, 5 ] ]
gap> gr := DigraphFromGraph6String("N~~~~~~~wzmxufyZsvw");
<immutable digraph with 15 vertices, 170 edges>
gap> DigraphMaximalCliquesReps(gr);
[ [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ], [ 1, 2, 3, 5, 8, 9, 14 ], 
  [ 1, 2, 5, 13, 14 ], [ 1, 13, 14, 15 ], [ 11, 12, 13, 14, 15 ] ]
gap> gr := DigraphFromGraph6String(
> "X~~~~~~~~~~~~~~~~~wvaSD{iLzBU{JJ}B]^FQn|gq~~Gb~TjF~");
<immutable digraph with 25 vertices, 440 edges>
gap> DigraphMaximalCliquesReps(gr);
[ [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ], 
  [ 1, 2, 3, 4, 5, 8, 12, 24 ], [ 2, 4, 12, 17, 24, 25 ], 
  [ 4, 16, 17, 22, 23, 24, 25 ], [ 4, 7, 9, 16, 25 ], [ 3, 18, 19, 23, 24 ], 
  [ 5, 16, 18, 22, 24 ], [ 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 ] ]

#  CliquesFinder: error checking
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
when the second argument <hook> is fail, the third argument <user_param> has
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
<include> and <exclude> must be invariant under the action of <group>,
gap> CliquesFinder(gr, fail, [], infinity, [], [1], false, 1, true);
Error, Digraphs: CliquesFinder: usage,
if the ninth argument <reps> is true then the fourth and fifth arguments
<include> and <exclude> must be invariant under the action of <group>,
gap> CliquesFinder(gr, fail, [], infinity, [1 .. 5], [1 .. 5], false, 1, true);
[  ]
gap> CliquesFinder(gr, fail, [], infinity, [1], [1], false, 1, false);
[  ]

#  DIGRAPHS_BronKerbosch: easy cases
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

#  DIGRAPHS_BronKerbosch: getting code coverage
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
[ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 1, 3 ], 
  [ 4, 5 ], [ 2, 4 ], [ 1, 5 ], [ 3, 5 ], [ 1, 4 ], [ 2, 5 ], [ 1, 2, 3 ], 
  [ 2, 3, 4 ], [ 3, 4, 5 ], [ 1, 3, 4 ], [ 1, 4, 5 ], [ 2, 4, 5 ], 
  [ 1, 2, 5 ], [ 1, 3, 5 ], [ 1, 2, 4 ], [ 2, 3, 5 ], [ 1, 2, 3, 4 ], 
  [ 2, 3, 4, 5 ], [ 1, 3, 4, 5 ], [ 1, 2, 4, 5 ], [ 1, 2, 3, 5 ], 
  [ 1, 2, 3, 4, 5 ] ]
gap> Length(out);
31
gap> lim := 32;;
gap> CliquesFinder(gr, fail, [], lim, [], [], false, fail, false) = out;
true
gap> lim := 12;;
gap> out := CliquesFinder(gr, fail, [], lim, [], [], false, fail, false);
[ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 1, 3 ], 
  [ 4, 5 ], [ 2, 4 ], [ 1, 5 ] ]
gap> Length(out) = lim;
true
gap> out := CliquesFinder(gr, fail, [], lim, [1, 4], [], false, fail, false);
[ [ 1, 4 ], [ 1, 2, 4 ], [ 1, 3, 4 ], [ 1, 4, 5 ], [ 1, 2, 3, 4 ], 
  [ 1, 3, 4, 5 ], [ 1, 2, 4, 5 ], [ 1, 2, 3, 4, 5 ] ]
gap> out := CliquesFinder(gr, fail, [], lim, [1, 4], [], false, 4, false);
[ [ 1, 2, 3, 4 ], [ 1, 3, 4, 5 ], [ 1, 2, 4, 5 ] ]
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

#  DigraphMaximalCliques: examples that had been giving duplicate results
gap> gr := DigraphFromGraph6String(
> "X~~~~~~~~~~~~~~~~~}EkpJK_vyRUwvH{fL^FFfzdo~tmB~cU^~");
<immutable digraph with 25 vertices, 440 edges>
gap> AutomorphismGroup(gr);;
gap> c := DigraphMaximalCliques(gr);;
gap> Length(c);
52
gap> gr := DigraphFromGraph6String(Concatenation(
> "b~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~bx[^fbY^zbMznyvej^AX~",
> "v|Zf\\r~jXmr~}|LD~t}iF~ztlNV~_"));
<immutable digraph with 35 vertices, 1010 edges>
gap> AutomorphismGroup(gr);;
gap> c := DigraphMaximalCliques(gr);;
gap> Length(c);
302
gap> gr := DigraphFromGraph6String(Concatenation(
> "~?@O~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
> "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
> "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
> "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
> "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}NrN}}~~[F",
> "~X}H}jr~~t]~zwvmv\\zzy}n~y~m~Tzjy}M~{Jr^YZ~V|~~~V|uuu|^^Z|^w^emV|n~^}z~j",
> "uYz\\u~l~zz~~T|nllvb}~Z~~~~it~a}zvD~~j}tY~f~x~qn~~z~Z||{V]Sn~~~~z~jnfzod",
> "V~}nzn}}}~MFVn~z|F|F~|tNx~~~{"));
<immutable digraph with 80 vertices, 5840 edges>
gap> AutomorphismGroup(gr);;
gap> c := DigraphMaximalCliques(gr);;
gap> Length(c);
12815

#  Issue #23: Digraphs with isolated vertices
gap> gr := DigraphFromSparse6String(":~?@c__EC?_F");
<immutable digraph with 100 vertices, 6 edges>
gap> DigraphMaximalCliquesReps(gr);
[ [ 1 ], [ 2, 3, 5 ] ]
gap> DigraphMaximalCliques(gr);
[ [ 1 ], [ 4 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ], [ 11 ], [ 12 ], [ 13 ], 
  [ 14 ], [ 15 ], [ 16 ], [ 17 ], [ 18 ], [ 19 ], [ 20 ], [ 21 ], [ 22 ], 
  [ 23 ], [ 24 ], [ 25 ], [ 26 ], [ 27 ], [ 28 ], [ 29 ], [ 30 ], [ 31 ], 
  [ 32 ], [ 33 ], [ 34 ], [ 35 ], [ 36 ], [ 37 ], [ 38 ], [ 39 ], [ 40 ], 
  [ 41 ], [ 42 ], [ 43 ], [ 44 ], [ 45 ], [ 46 ], [ 47 ], [ 48 ], [ 49 ], 
  [ 50 ], [ 51 ], [ 52 ], [ 53 ], [ 54 ], [ 55 ], [ 56 ], [ 57 ], [ 58 ], 
  [ 59 ], [ 60 ], [ 61 ], [ 62 ], [ 63 ], [ 64 ], [ 65 ], [ 66 ], [ 67 ], 
  [ 68 ], [ 69 ], [ 70 ], [ 71 ], [ 72 ], [ 73 ], [ 74 ], [ 75 ], [ 76 ], 
  [ 77 ], [ 78 ], [ 79 ], [ 80 ], [ 81 ], [ 82 ], [ 83 ], [ 84 ], [ 85 ], 
  [ 86 ], [ 87 ], [ 88 ], [ 89 ], [ 90 ], [ 91 ], [ 92 ], [ 93 ], [ 94 ], 
  [ 95 ], [ 96 ], [ 97 ], [ 98 ], [ 99 ], [ 100 ], [ 2, 3, 5 ] ]

# Test CliqueNumber
gap> CliqueNumber(NullDigraph(10));
1
gap> CliqueNumber(NullDigraph(0));
0
gap> CliqueNumber(CompleteDigraph(10));
10
gap> CliqueNumber(DigraphRemoveEdge(CompleteDigraph(10), [1, 2]));
9
gap> CliqueNumber(JohnsonDigraph(10, 2));
9
gap> CliqueNumber(ChainDigraph(10));
1
gap> CliqueNumber(ChainDigraph(9));
1
gap> CliqueNumber(CycleDigraph(9));
1
gap> CliqueNumber(CycleDigraph(8));
1
gap> CliqueNumber(DigraphSymmetricClosure(CycleDigraph(8)));
2

#  DIGRAPHS_UnbindVariables
gap> Unbind(f);
gap> Unbind(c);
gap> Unbind(gr);
gap> Unbind(lim);
gap> Unbind(out);

#E#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/cliques.tst", 0);
