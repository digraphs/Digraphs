#############################################################################
##
#W  standard/grahom.tst
#Y  Copyright (C) 2015-18                                   Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/grahom.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#T# HomomorphismDigraphsFinder: checking errors and robustness
gap> HomomorphismDigraphsFinder(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 1st and 2nd arguments <gr1> and <gr2> must be digraphs,
gap> gr1 := ChainDigraph(2);;
gap> gr2 := CompleteDigraph(3);;
gap> HomomorphismDigraphsFinder(0, gr2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 1st and 2nd arguments <gr1> and <gr2> must be digraphs,
gap> HomomorphismDigraphsFinder(gr1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 1st and 2nd arguments <gr1> and <gr2> must be digraphs,
gap> HomomorphismDigraphsFinder(gr1, gr2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 3rd argument <hook> has to be a function with 2 arguments,
gap> HomomorphismDigraphsFinder(gr2, gr1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 3rd argument <hook> has to be a function with 2 arguments,
gap> gr1 := CompleteDigraph(2);;
gap> HomomorphismDigraphsFinder(gr1, gr2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 3rd argument <hook> has to be a function with 2 arguments,
gap> HomomorphismDigraphsFinder(gr1, gr2, IsTournament, 0, 0, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 3rd argument <hook> has to be a function with 2 arguments,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, 0, 0, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 4th argument <user_param> must be a list,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, "a", 0, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 5th argument <limit> has to be a positive integer or infinity,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, "a", "a", 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 5th argument <limit> has to be a positive integer or infinity,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, "a", 1, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 6th argument <hint> has to be a positive integer or fail,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, "a", 1, 1, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 7th argument <inj> has to be a true or false,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, "a", infinity, fail, 0, 0, 0,
> 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 7th argument <inj> has to be a true or false,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, "a", infinity, 2, true, 0, 0,
> 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 8th argument <image> has to be a duplicate-free list of vertices of the
2nd argument <gr2>,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, true, [1, []], 0,
> 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 8th argument <image> has to be a duplicate-free list of vertices of the
2nd argument <gr2>,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, true, [[], []], 0,
> 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 8th argument <image> has to be a duplicate-free list of vertices of the
2nd argument <gr2>,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, true, [0, 1], 0, 0,
> 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 8th argument <image> has to be a duplicate-free list of vertices of the
2nd argument <gr2>,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, true, [4, 4], 0, 0,
> 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 8th argument <image> has to be a duplicate-free list of vertices of the
2nd argument <gr2>,
gap> HomomorphismDigraphsFinder(gr2, gr1, fail, [], 1, 1, true, [3], 0, 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 8th argument <image> has to be a duplicate-free list of vertices of the
2nd argument <gr2>,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, true, [3], 0, 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 9th argument <map> must be a list of vertices of the 8th argument <image>
which is no longer than the number of vertices of the 1st argument <gr1>,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, true, [3], [1 .. 4],
> 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 9th argument <map> must be a list of vertices of the 8th argument <image>
which is no longer than the number of vertices of the 1st argument <gr1>,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, true, [],
> [1, 2, 3, 2], 0, 0);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 9th argument <map> must be a list of vertices of the 8th argument <image>
which is no longer than the number of vertices of the 1st argument <gr1>,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, true, [1], [1],
> fail, fail);
[  ]
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 2, true, [1, 2], [1],
> fail, fail);
[ IdentityTransformation ]
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 3, false, [1, 2], [1],
> fail, fail);
[  ]
gap> HomomorphismDigraphsFinder(gr2, gr1, fail, [], 1, 3, false, [1, 2], [1],
> fail, fail);
[  ]
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, false, [], [], fail,
> fail);
[  ]
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, false, [1, 2], [],
> fail, fail);
[  ]
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, false, [1, 2], [],
> fail, fail);
[  ]
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 2, false, [1], [], fail,
> fail);
[  ]
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, false, [1, 2], [],
> fail, fail);
[ IdentityTransformation ]
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, false, [1, 2],
> [], [[1, 2]], fail);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 10th and 11th arguments <list1> and <list2> must both be fail or neither m\
ust be fail,
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, false, [1, 2],
> [], fail, [[1, 2]]);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the 10th and 11th arguments <list1> and <list2> must both be fail or neither m\
ust be fail,
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, false, [1, 2],
> [], [[1, 2]], [[1, 2]]);
[ IdentityTransformation ]
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, false, [1, 2],
> [], [[1, 2], [2]], [[1, 2]]);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 2],
since it contains the vertex 2 more than once,
gap> gr := CompleteDigraph(513);;
gap> HomomorphismDigraphsFinder(gr, gr, fail, [], 1, fail, false, [1 .. 513],
> [], fail, fail);
Error, Digraphs: HomomorphismDigraphsFinder: error,
not yet implemented for digraphs with more than 512 vertices,
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, false, [1, 2],
> [], [1, 2], [2, 1]);
[ Transformation( [ 2, 1 ] ) ]
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, false, [1, 2],
> [], [1, 2, 3], [2, 1]);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 2].
The list <partition> must have one of the following forms:
1. <partition> is a list of length 2 consisting of every integer in the range
   [1 .. m], for some m <= 2;
2. <partition> is a list of non-empty disjoint lists whose union is [1 .. 2].
In the first form, <partition[i]> is the colour of vertex i; in the second
form, <partition[i]> is the list of vertices with colour i,
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, false, [1, 2],
> [], [1, 3], [2, 1]);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
the argument <partition> does not define a colouring of the vertices [1 .. 2],
since it contains the integer 3, which is greater than 2,
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, false, [1, 2],
> [], [1, fail], [2, 1]);
Error, Digraphs: HomomorphismDigraphsFinder: usage,
in order to define a colouring, the argument <partition> must be a homogeneous
list,
gap> gr := ChainDigraph(2);
<digraph with 2 vertices, 1 edge>
gap> GeneratorsOfEndomorphismMonoid();
Error, Digraphs: GeneratorsOfEndomorphismMonoid: usage,
this function takes at least one argument,
gap> GeneratorsOfEndomorphismMonoid(Group(()));
Error, Digraphs: GeneratorsOfEndomorphismMonoid: usage,
the 1st argument <digraph> must be a digraph,
gap> GeneratorsOfEndomorphismMonoid(gr);
[ IdentityTransformation ]
gap> gr := DigraphTransitiveClosure(CompleteDigraph(2));
<digraph with 2 vertices, 4 edges>
gap> DigraphHasLoops(gr);
true
gap> GeneratorsOfEndomorphismMonoid(gr);
[ Transformation( [ 2, 1 ] ), IdentityTransformation, 
  Transformation( [ 1, 1 ] ) ]
gap> gr := EmptyDigraph(2);
<digraph with 2 vertices, 0 edges>
gap> GeneratorsOfEndomorphismMonoid(gr, Group(()), Group((1, 2)));
Error, Digraphs: GeneratorsOfEndomorphismMonoid: usage,
<colours> must be a homogenous list,
gap> gr := EmptyDigraph(2);;
gap> GeneratorsOfEndomorphismMonoid(gr, Group(()));
Error, Digraphs: GeneratorsOfEndomorphismMonoid: usage,
<colours> must be a homogenous list,
gap> gr := EmptyDigraph(2);;
gap> GeneratorsOfEndomorphismMonoid(gr, 1);
[ Transformation( [ 2, 1 ] ) ]
gap> gr := EmptyDigraph(2);;
gap> GeneratorsOfEndomorphismMonoid(gr, 2);
[ Transformation( [ 2, 1 ] ), IdentityTransformation ]
gap> gr := EmptyDigraph(2);;
gap> GeneratorsOfEndomorphismMonoidAttr(gr);;
gap> GeneratorsOfEndomorphismMonoid(gr, 4) = last;
true
gap> gens := GeneratorsOfEndomorphismMonoid(gr, 3);
[ Transformation( [ 2, 1 ] ), IdentityTransformation, 
  Transformation( [ 1, 1 ] ) ]
gap> IsFullTransformationSemigroup(Semigroup(gens));
true
gap> Size(Semigroup(gens));
4
gap> gr := CompleteDigraph(5);;
gap> GeneratorsOfEndomorphismMonoid(gr, [1, 2, 3, 4, 5]);
[ IdentityTransformation ]
gap> GeneratorsOfEndomorphismMonoid(gr);
[ IdentityTransformation ]
gap> GeneratorsOfEndomorphismMonoid(gr, [1, 1, 1, 2, 2]);
[ Transformation( [ 1, 2, 3, 5, 4 ] ), Transformation( [ 1, 3, 2 ] ), 
  Transformation( [ 2, 1 ] ), IdentityTransformation ]
gap> GeneratorsOfEndomorphismMonoid(gr, [1, 1, 1, 2, 2], 1);
[ Transformation( [ 1, 2, 3, 5, 4 ] ), Transformation( [ 1, 3, 2 ] ), 
  Transformation( [ 2, 1 ] ) ]
gap> GeneratorsOfEndomorphismMonoid(gr, [1, 1, 1, 2, 2], 0);
Error, Digraphs: GeneratorsOfEndomorphismMonoid: usage,
<limit> must be a positive integer or infinity,

#T# GeneratorsOfEndomorphismMonoid: digraphs with loops

# loops1
gap> gr := Digraph([[], [2]]);
<digraph with 2 vertices, 1 edge>
gap> GeneratorsOfEndomorphismMonoid(gr);
[ IdentityTransformation, Transformation( [ 2, 2 ] ) ]

# loops2
gap> gr := Digraph([[2], [], [3]]);
<digraph with 3 vertices, 2 edges>
gap> GeneratorsOfEndomorphismMonoid(gr);
[ IdentityTransformation, Transformation( [ 3, 3, 3 ] ) ]

# loops3
gap> gr := Digraph([[2], [1], [3]]);
<digraph with 3 vertices, 3 edges>
gap> GeneratorsOfEndomorphismMonoid(gr);
[ Transformation( [ 2, 1 ] ), IdentityTransformation, 
  Transformation( [ 3, 3, 3 ] ) ]

#T# DigraphGreedyColouring and DigraphColouring: checking errors and robustness
gap> gr := Digraph([[2, 2], []]);
<multidigraph with 2 vertices, 2 edges>
gap> DigraphColouring(gr, 1);
fail
gap> gr := EmptyDigraph(3);
<digraph with 3 vertices, 0 edges>
gap> DigraphColouring(gr, 4);
fail
gap> DigraphColouring(gr, 3);
IdentityTransformation
gap> DigraphColouring(gr, 2);
Transformation( [ 1, 1, 2 ] )
gap> DigraphColouring(gr, 1);
Transformation( [ 1, 1, 1 ] )
gap> gr := CompleteDigraph(3);
<digraph with 3 vertices, 6 edges>
gap> DigraphColouring(gr, 1);
fail
gap> DigraphColouring(gr, 2);
fail
gap> DigraphColouring(gr, 3);
IdentityTransformation
gap> gr := EmptyDigraph(0);
<digraph with 0 vertices, 0 edges>
gap> DigraphColouring(gr, 1);
fail
gap> DigraphColouring(gr, 2);
fail
gap> DigraphColouring(gr, 3);
fail
gap> gr := EmptyDigraph(1);
<digraph with 1 vertex, 0 edges>
gap> DigraphColouring(gr, 1);
IdentityTransformation
gap> DigraphColouring(gr, 2);
fail
gap> gr := Digraph([[1, 2], []]);;
gap> DigraphColouring(gr, -1);
Error, Digraphs: DigraphColouring: usage,
the second argument <n> must be a non-negative integer,
gap> DigraphColouring(NullDigraph(0), 1);
fail
gap> DigraphColouring(NullDigraph(0), 0);
IdentityTransformation
gap> DigraphColouring(CompleteDigraph(1), 0);
fail
gap> DigraphColouring(Digraph([[1]]), 1);
fail
gap> gr := DigraphFromDigraph6String(Concatenation(
> "+l??O?C?A_@???CE????GAAG?C??M?????@_?OO??G??@?IC???_C?G?o??C?AO???c_??A?",
> "A?S???OAA???OG???G_A??C?@?cC????_@G???S??C_?C???[??A?A?OA?O?@?A?@A???GGO",
> "??`?_O??G?@?A??G?@AH????AA?O@??_??b???Cg??C???_??W?G????d?G?C@A?C???GC?W",
> "?????K???__O[??????O?W???O@??_G?@?CG??G?@G?C??@G???_Q?O?O?c???OAO?C??C?G",
> "?O??A@??D??G?C_?A??O?_GA??@@?_?G???E?IW??????_@G?C??"));
<digraph with 45 vertices, 180 edges>
gap> DigraphGreedyColouring(gr);
Transformation( [ 1, 1, 1, 1, 1, 2, 2, 1, 2, 2, 2, 1, 1, 2, 1, 2, 1, 2, 2, 3,
  3, 2, 3, 3, 3, 2, 1, 4, 4, 2, 3, 3, 3, 3, 3, 1, 3, 4, 4, 3, 2, 1, 4, 3,
  1 ] )
gap> DigraphColouring(gr, 4);
Transformation( [ 1, 1, 1, 1, 1, 2, 2, 1, 2, 2, 2, 1, 1, 2, 1, 2, 1, 2, 2, 3,
  3, 2, 3, 3, 3, 2, 1, 4, 4, 2, 3, 3, 3, 3, 3, 1, 3, 4, 4, 3, 2, 1, 4, 3,
  1 ] )

# DigraphGreedyColouring
gap> DigraphGreedyColouring(EmptyDigraph(0));
IdentityTransformation
gap> DigraphGreedyColouring(Digraph([[]]));
IdentityTransformation
gap> DigraphGreedyColouring(Digraph([[1]]));
fail
gap> DigraphGreedyColouring(CycleDigraph(2));
IdentityTransformation
gap> DigraphGreedyColouring(CycleDigraph(3));
IdentityTransformation
gap> DigraphGreedyColouring(CycleDigraph(4));
Transformation( [ 1, 2, 1, 2 ] )
gap> DigraphGreedyColouring(CycleDigraph(5));
Transformation( [ 1, 2, 1, 2, 3 ] )
gap> DigraphGreedyColouring(CycleDigraph(6));
Transformation( [ 1, 2, 1, 2, 1, 2 ] )
gap> DigraphGreedyColouring(CompleteDigraph(10));
IdentityTransformation
gap> gr := CompleteDigraph(4);;
gap> HasDigraphGreedyColouring(gr);
false
gap> DigraphGreedyColouring(gr);
IdentityTransformation
gap> HasDigraphGreedyColouring(gr);
true
gap> gr := CycleDigraph(4);;
gap> HasDigraphGreedyColouring(gr);
false
gap> DigraphGreedyColouring(gr);
Transformation( [ 1, 2, 1, 2 ] )
gap> HasDigraphGreedyColouring(gr);
true
gap> DigraphGreedyColouring(ChainDigraph(10));;
gap> DigraphGreedyColouring(CompleteDigraph(10));;
gap> gr := DigraphFromSparse6String(
> ":]nA?LcB@_EDfEB`GIaHGdJIgEKcLK`?MdCHiFLaBJhFMkJM");
<digraph with 30 vertices, 90 edges>
gap> DigraphGreedyColouring(gr);;
gap> DigraphGreedyColouring(EmptyDigraph(0));
IdentityTransformation
gap> DigraphGreedyColouring(gr, [1 .. 10]);
Error, the second argument <order> must be a permutation of [ 1 .. 30 ]
gap> DigraphGreedyColouring(gr, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
> 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, -1]);
Error, the second argument <order> must be a permutation of [ 1 .. 30 ]
gap> DigraphGreedyColouring(gr, [1 .. 30]);
Transformation( [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2,
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ] )
gap> D := Digraph([[3, 4, 6, 8], [4, 6, 7, 8, 10], [2, 6, 7, 8, 9], [3, 5, 7],
> [1, 2, 3, 6, 9], [2, 6, 8, 10], [7], [1, 10], [2, 7, 8], [1, 2, 6, 8, 10]]);;
gap> DigraphHasLoops(D);
true
gap> DigraphGreedyColouring(D);
fail
gap> DigraphColouring(D, 3);
fail
gap> D := Digraph([[3], [], [2]]);;
gap> DigraphGreedyColouring(D, [1 .. 3]);
Transformation( [ 1, 1, 2 ] )

# DigraphWelshPowellOrder
gap> DigraphGreedyColouring(EmptyDigraph(0), DigraphWelshPowellOrder);
IdentityTransformation
gap> DigraphGreedyColouring(Digraph([[]]), DigraphWelshPowellOrder);
IdentityTransformation
gap> DigraphGreedyColouring(Digraph([[1]]), DigraphWelshPowellOrder);
fail
gap> DigraphGreedyColouring(CycleDigraph(2), DigraphWelshPowellOrder);
IdentityTransformation
gap> DigraphGreedyColouring(CycleDigraph(3), DigraphWelshPowellOrder);
IdentityTransformation
gap> DigraphGreedyColouring(CycleDigraph(4), DigraphWelshPowellOrder);
Transformation( [ 1, 2, 1, 2 ] )
gap> DigraphGreedyColouring(CycleDigraph(5), DigraphWelshPowellOrder);
Transformation( [ 1, 2, 1, 2, 3 ] )
gap> DigraphGreedyColouring(CycleDigraph(6), DigraphWelshPowellOrder);
Transformation( [ 1, 2, 1, 2, 1, 2 ] )
gap> DigraphGreedyColouring(CompleteDigraph(10), DigraphWelshPowellOrder);
IdentityTransformation
gap> gr := CompleteDigraph(4);;
gap> HasDigraphGreedyColouring(gr);
false
gap> DigraphGreedyColouring(gr, DigraphWelshPowellOrder);
IdentityTransformation
gap> HasDigraphGreedyColouring(gr);
false
gap> gr := CycleDigraph(4);;
gap> HasDigraphGreedyColouring(gr);
false
gap> DigraphGreedyColouring(gr, DigraphWelshPowellOrder);
Transformation( [ 1, 2, 1, 2 ] )
gap> HasDigraphGreedyColouring(gr);
false
gap> DigraphGreedyColouring(ChainDigraph(10), DigraphWelshPowellOrder);
Transformation( [ 2, 1, 2, 1, 2, 1, 2, 1, 2, 1 ] )
gap> DigraphGreedyColouring(CompleteDigraph(10), DigraphWelshPowellOrder);
IdentityTransformation
gap> gr := DigraphFromSparse6String(
> ":]nA?LcB@_EDfEB`GIaHGdJIgEKcLK`?MdCHiFLaBJhFMkJM");
<digraph with 30 vertices, 90 edges>
gap> DigraphGreedyColouring(gr, DigraphWelshPowellOrder);
Transformation( [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2,
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ] )
gap> DigraphGreedyColouring(EmptyDigraph(0));
IdentityTransformation

# DigraphWelshPowellOrder
gap> order_func := D -> [1 .. DigraphNrVertices(D)];;
gap> DigraphGreedyColouring(EmptyDigraph(0), order_func);
IdentityTransformation
gap> DigraphGreedyColouring(Digraph([[]]), order_func);
IdentityTransformation
gap> DigraphGreedyColouring(Digraph([[1]]), order_func);
fail
gap> DigraphGreedyColouring(CycleDigraph(2), order_func);
IdentityTransformation
gap> DigraphGreedyColouring(CycleDigraph(3), order_func);
IdentityTransformation
gap> DigraphGreedyColouring(CycleDigraph(4), order_func);
Transformation( [ 1, 2, 1, 2 ] )
gap> DigraphGreedyColouring(CycleDigraph(5), order_func);
Transformation( [ 1, 2, 1, 2, 3 ] )
gap> DigraphGreedyColouring(CycleDigraph(6), order_func);
Transformation( [ 1, 2, 1, 2, 1, 2 ] )
gap> DigraphGreedyColouring(CompleteDigraph(10), order_func);
IdentityTransformation
gap> gr := CompleteDigraph(4);;
gap> HasDigraphGreedyColouring(gr);
false
gap> DigraphGreedyColouring(gr, order_func);
IdentityTransformation
gap> HasDigraphGreedyColouring(gr);
false
gap> gr := CycleDigraph(4);;
gap> HasDigraphGreedyColouring(gr);
false
gap> DigraphGreedyColouring(gr, order_func);
Transformation( [ 1, 2, 1, 2 ] )
gap> HasDigraphGreedyColouring(gr);
false
gap> DigraphGreedyColouring(ChainDigraph(10), order_func);
Transformation( [ 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 ] )
gap> DigraphGreedyColouring(CompleteDigraph(10), order_func);
IdentityTransformation
gap> gr := DigraphFromSparse6String(
> ":]nA?LcB@_EDfEB`GIaHGdJIgEKcLK`?MdCHiFLaBJhFMkJM");
<digraph with 30 vertices, 90 edges>
gap> DigraphGreedyColouring(gr, order_func);
Transformation( [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2,
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ] )
gap> DigraphGreedyColouring(EmptyDigraph(0));
IdentityTransformation

#T# HomomorphismDigraphsFinder 1
gap> gr := Digraph([[2, 3], [], [], [5], [], []]);;
gap> gr := DigraphSymmetricClosure(gr);;
gap> x := [];;
gap> HomomorphismDigraphsFinder(gr, gr, fail, x, infinity, fail, false,
> [1 .. 6], [], fail, fail);
[ IdentityTransformation, Transformation( [ 1, 2, 3, 4, 5, 1 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 2 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 3 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 4 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 5 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 4 ] ), Transformation( [ 1, 2, 3, 1, 2 ] ),
  Transformation( [ 1, 2, 3, 1, 2, 1 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 2 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 3 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 4 ] ), Transformation( [ 1, 2, 3, 1, 3 ] ),
  Transformation( [ 1, 2, 3, 1, 3, 1 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 2 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 3 ] ), 
  Transformation( [ 1, 2, 3, 2, 1, 4 ] ), Transformation( [ 1, 2, 3, 2, 1 ] ),
  Transformation( [ 1, 2, 3, 2, 1, 1 ] ), 
  Transformation( [ 1, 2, 3, 2, 1, 2 ] ), 
  Transformation( [ 1, 2, 3, 2, 1, 3 ] ), 
  Transformation( [ 1, 2, 3, 3, 1, 4 ] ), Transformation( [ 1, 2, 3, 3, 1 ] ),
  Transformation( [ 1, 2, 3, 3, 1, 1 ] ), 
  Transformation( [ 1, 2, 3, 3, 1, 2 ] ), 
  Transformation( [ 1, 2, 3, 3, 1, 3 ] ), 
  Transformation( [ 1, 2, 2, 3, 1, 4 ] ), Transformation( [ 1, 2, 2, 3, 1 ] ),
  Transformation( [ 1, 2, 2, 3, 1, 1 ] ), 
  Transformation( [ 1, 2, 2, 3, 1, 2 ] ), 
  Transformation( [ 1, 2, 2, 3, 1, 3 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 3 ] ), Transformation( [ 1, 2, 2 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 1 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 2 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 4 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 5 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 4 ] ), Transformation( [ 1, 2, 2, 1, 3 ] ),
  Transformation( [ 1, 2, 2, 1, 3, 1 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 2 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 3 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 3 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 4 ] ), Transformation( [ 1, 2, 2, 1, 2 ] ),
  Transformation( [ 1, 2, 2, 1, 2, 1 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 2 ] ), 
  Transformation( [ 1, 2, 2, 2, 1, 3 ] ), 
  Transformation( [ 1, 2, 2, 2, 1, 4 ] ), Transformation( [ 1, 2, 2, 2, 1 ] ),
  Transformation( [ 1, 2, 2, 2, 1, 1 ] ), 
  Transformation( [ 1, 2, 2, 2, 1, 2 ] ), 
  Transformation( [ 2, 1, 1, 3, 1, 4 ] ), Transformation( [ 2, 1, 1, 3, 1 ] ),
  Transformation( [ 2, 1, 1, 3, 1, 1 ] ), 
  Transformation( [ 2, 1, 1, 3, 1, 2 ] ), 
  Transformation( [ 2, 1, 1, 3, 1, 3 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 3 ] ), Transformation( [ 2, 1, 1 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 1 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 2 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 4 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 5 ] ), 
  Transformation( [ 2, 1, 1, 1, 3, 4 ] ), Transformation( [ 2, 1, 1, 1, 3 ] ),
  Transformation( [ 2, 1, 1, 1, 3, 1 ] ), 
  Transformation( [ 2, 1, 1, 1, 3, 2 ] ), 
  Transformation( [ 2, 1, 1, 1, 3, 3 ] ), 
  Transformation( [ 2, 1, 1, 1, 2, 3 ] ), 
  Transformation( [ 2, 1, 1, 1, 2, 4 ] ), Transformation( [ 2, 1, 1, 1, 2 ] ),
  Transformation( [ 2, 1, 1, 1, 2, 1 ] ), 
  Transformation( [ 2, 1, 1, 1, 2, 2 ] ), 
  Transformation( [ 2, 1, 1, 2, 1, 3 ] ), 
  Transformation( [ 2, 1, 1, 2, 1, 4 ] ), Transformation( [ 2, 1, 1, 2, 1 ] ),
  Transformation( [ 2, 1, 1, 2, 1, 1 ] ), 
  Transformation( [ 2, 1, 1, 2, 1, 2 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 3 ] ), Transformation( [ 4, 5, 5, 1, 2 ] ),
  Transformation( [ 4, 5, 5, 1, 2, 1 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 2 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 4 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 5 ] ), 
  Transformation( [ 4, 5, 5, 2, 1, 3 ] ), Transformation( [ 4, 5, 5, 2, 1 ] ),
  Transformation( [ 4, 5, 5, 2, 1, 1 ] ), 
  Transformation( [ 4, 5, 5, 2, 1, 2 ] ), 
  Transformation( [ 4, 5, 5, 2, 1, 4 ] ), 
  Transformation( [ 4, 5, 5, 2, 1, 5 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 1 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 2 ] ), Transformation( [ 4, 5, 5, 4, 5 ] ),
  Transformation( [ 4, 5, 5, 4, 5, 4 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 5 ] ), 
  Transformation( [ 4, 5, 5, 5, 4, 1 ] ), 
  Transformation( [ 4, 5, 5, 5, 4, 2 ] ), Transformation( [ 4, 5, 5, 5, 4 ] ),
  Transformation( [ 4, 5, 5, 5, 4, 4 ] ), 
  Transformation( [ 4, 5, 5, 5, 4, 5 ] ) ]
gap> Length(x);
100
gap> HomomorphismDigraphsFinder(gr, gr, fail, x, infinity, fail, false,
> [1 .. 6], [], fail, fail);
[ IdentityTransformation, Transformation( [ 1, 2, 3, 4, 5, 1 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 2 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 3 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 4 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 5 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 4 ] ), Transformation( [ 1, 2, 3, 1, 2 ] ),
  Transformation( [ 1, 2, 3, 1, 2, 1 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 2 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 3 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 4 ] ), Transformation( [ 1, 2, 3, 1, 3 ] ),
  Transformation( [ 1, 2, 3, 1, 3, 1 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 2 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 3 ] ), 
  Transformation( [ 1, 2, 3, 2, 1, 4 ] ), Transformation( [ 1, 2, 3, 2, 1 ] ),
  Transformation( [ 1, 2, 3, 2, 1, 1 ] ), 
  Transformation( [ 1, 2, 3, 2, 1, 2 ] ), 
  Transformation( [ 1, 2, 3, 2, 1, 3 ] ), 
  Transformation( [ 1, 2, 3, 3, 1, 4 ] ), Transformation( [ 1, 2, 3, 3, 1 ] ),
  Transformation( [ 1, 2, 3, 3, 1, 1 ] ), 
  Transformation( [ 1, 2, 3, 3, 1, 2 ] ), 
  Transformation( [ 1, 2, 3, 3, 1, 3 ] ), 
  Transformation( [ 1, 2, 2, 3, 1, 4 ] ), Transformation( [ 1, 2, 2, 3, 1 ] ),
  Transformation( [ 1, 2, 2, 3, 1, 1 ] ), 
  Transformation( [ 1, 2, 2, 3, 1, 2 ] ), 
  Transformation( [ 1, 2, 2, 3, 1, 3 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 3 ] ), Transformation( [ 1, 2, 2 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 1 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 2 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 4 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 5 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 4 ] ), Transformation( [ 1, 2, 2, 1, 3 ] ),
  Transformation( [ 1, 2, 2, 1, 3, 1 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 2 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 3 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 3 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 4 ] ), Transformation( [ 1, 2, 2, 1, 2 ] ),
  Transformation( [ 1, 2, 2, 1, 2, 1 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 2 ] ), 
  Transformation( [ 1, 2, 2, 2, 1, 3 ] ), 
  Transformation( [ 1, 2, 2, 2, 1, 4 ] ), Transformation( [ 1, 2, 2, 2, 1 ] ),
  Transformation( [ 1, 2, 2, 2, 1, 1 ] ), 
  Transformation( [ 1, 2, 2, 2, 1, 2 ] ), 
  Transformation( [ 2, 1, 1, 3, 1, 4 ] ), Transformation( [ 2, 1, 1, 3, 1 ] ),
  Transformation( [ 2, 1, 1, 3, 1, 1 ] ), 
  Transformation( [ 2, 1, 1, 3, 1, 2 ] ), 
  Transformation( [ 2, 1, 1, 3, 1, 3 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 3 ] ), Transformation( [ 2, 1, 1 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 1 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 2 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 4 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 5 ] ), 
  Transformation( [ 2, 1, 1, 1, 3, 4 ] ), Transformation( [ 2, 1, 1, 1, 3 ] ),
  Transformation( [ 2, 1, 1, 1, 3, 1 ] ), 
  Transformation( [ 2, 1, 1, 1, 3, 2 ] ), 
  Transformation( [ 2, 1, 1, 1, 3, 3 ] ), 
  Transformation( [ 2, 1, 1, 1, 2, 3 ] ), 
  Transformation( [ 2, 1, 1, 1, 2, 4 ] ), Transformation( [ 2, 1, 1, 1, 2 ] ),
  Transformation( [ 2, 1, 1, 1, 2, 1 ] ), 
  Transformation( [ 2, 1, 1, 1, 2, 2 ] ), 
  Transformation( [ 2, 1, 1, 2, 1, 3 ] ), 
  Transformation( [ 2, 1, 1, 2, 1, 4 ] ), Transformation( [ 2, 1, 1, 2, 1 ] ),
  Transformation( [ 2, 1, 1, 2, 1, 1 ] ), 
  Transformation( [ 2, 1, 1, 2, 1, 2 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 3 ] ), Transformation( [ 4, 5, 5, 1, 2 ] ),
  Transformation( [ 4, 5, 5, 1, 2, 1 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 2 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 4 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 5 ] ), 
  Transformation( [ 4, 5, 5, 2, 1, 3 ] ), Transformation( [ 4, 5, 5, 2, 1 ] ),
  Transformation( [ 4, 5, 5, 2, 1, 1 ] ), 
  Transformation( [ 4, 5, 5, 2, 1, 2 ] ), 
  Transformation( [ 4, 5, 5, 2, 1, 4 ] ), 
  Transformation( [ 4, 5, 5, 2, 1, 5 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 1 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 2 ] ), Transformation( [ 4, 5, 5, 4, 5 ] ),
  Transformation( [ 4, 5, 5, 4, 5, 4 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 5 ] ), 
  Transformation( [ 4, 5, 5, 5, 4, 1 ] ), 
  Transformation( [ 4, 5, 5, 5, 4, 2 ] ), Transformation( [ 4, 5, 5, 5, 4 ] ),
  Transformation( [ 4, 5, 5, 5, 4, 4 ] ), 
  Transformation( [ 4, 5, 5, 5, 4, 5 ] ), IdentityTransformation, 
  Transformation( [ 1, 2, 3, 4, 5, 1 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 2 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 3 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 4 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 5 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 4 ] ), Transformation( [ 1, 2, 3, 1, 2 ] ),
  Transformation( [ 1, 2, 3, 1, 2, 1 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 2 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 3 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 4 ] ), Transformation( [ 1, 2, 3, 1, 3 ] ),
  Transformation( [ 1, 2, 3, 1, 3, 1 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 2 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 3 ] ), 
  Transformation( [ 1, 2, 3, 2, 1, 4 ] ), Transformation( [ 1, 2, 3, 2, 1 ] ),
  Transformation( [ 1, 2, 3, 2, 1, 1 ] ), 
  Transformation( [ 1, 2, 3, 2, 1, 2 ] ), 
  Transformation( [ 1, 2, 3, 2, 1, 3 ] ), 
  Transformation( [ 1, 2, 3, 3, 1, 4 ] ), Transformation( [ 1, 2, 3, 3, 1 ] ),
  Transformation( [ 1, 2, 3, 3, 1, 1 ] ), 
  Transformation( [ 1, 2, 3, 3, 1, 2 ] ), 
  Transformation( [ 1, 2, 3, 3, 1, 3 ] ), 
  Transformation( [ 1, 2, 2, 3, 1, 4 ] ), Transformation( [ 1, 2, 2, 3, 1 ] ),
  Transformation( [ 1, 2, 2, 3, 1, 1 ] ), 
  Transformation( [ 1, 2, 2, 3, 1, 2 ] ), 
  Transformation( [ 1, 2, 2, 3, 1, 3 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 3 ] ), Transformation( [ 1, 2, 2 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 1 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 2 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 4 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 5 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 4 ] ), Transformation( [ 1, 2, 2, 1, 3 ] ),
  Transformation( [ 1, 2, 2, 1, 3, 1 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 2 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 3 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 3 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 4 ] ), Transformation( [ 1, 2, 2, 1, 2 ] ),
  Transformation( [ 1, 2, 2, 1, 2, 1 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 2 ] ), 
  Transformation( [ 1, 2, 2, 2, 1, 3 ] ), 
  Transformation( [ 1, 2, 2, 2, 1, 4 ] ), Transformation( [ 1, 2, 2, 2, 1 ] ),
  Transformation( [ 1, 2, 2, 2, 1, 1 ] ), 
  Transformation( [ 1, 2, 2, 2, 1, 2 ] ), 
  Transformation( [ 2, 1, 1, 3, 1, 4 ] ), Transformation( [ 2, 1, 1, 3, 1 ] ),
  Transformation( [ 2, 1, 1, 3, 1, 1 ] ), 
  Transformation( [ 2, 1, 1, 3, 1, 2 ] ), 
  Transformation( [ 2, 1, 1, 3, 1, 3 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 3 ] ), Transformation( [ 2, 1, 1 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 1 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 2 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 4 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 5 ] ), 
  Transformation( [ 2, 1, 1, 1, 3, 4 ] ), Transformation( [ 2, 1, 1, 1, 3 ] ),
  Transformation( [ 2, 1, 1, 1, 3, 1 ] ), 
  Transformation( [ 2, 1, 1, 1, 3, 2 ] ), 
  Transformation( [ 2, 1, 1, 1, 3, 3 ] ), 
  Transformation( [ 2, 1, 1, 1, 2, 3 ] ), 
  Transformation( [ 2, 1, 1, 1, 2, 4 ] ), Transformation( [ 2, 1, 1, 1, 2 ] ),
  Transformation( [ 2, 1, 1, 1, 2, 1 ] ), 
  Transformation( [ 2, 1, 1, 1, 2, 2 ] ), 
  Transformation( [ 2, 1, 1, 2, 1, 3 ] ), 
  Transformation( [ 2, 1, 1, 2, 1, 4 ] ), Transformation( [ 2, 1, 1, 2, 1 ] ),
  Transformation( [ 2, 1, 1, 2, 1, 1 ] ), 
  Transformation( [ 2, 1, 1, 2, 1, 2 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 3 ] ), Transformation( [ 4, 5, 5, 1, 2 ] ),
  Transformation( [ 4, 5, 5, 1, 2, 1 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 2 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 4 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 5 ] ), 
  Transformation( [ 4, 5, 5, 2, 1, 3 ] ), Transformation( [ 4, 5, 5, 2, 1 ] ),
  Transformation( [ 4, 5, 5, 2, 1, 1 ] ), 
  Transformation( [ 4, 5, 5, 2, 1, 2 ] ), 
  Transformation( [ 4, 5, 5, 2, 1, 4 ] ), 
  Transformation( [ 4, 5, 5, 2, 1, 5 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 1 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 2 ] ), Transformation( [ 4, 5, 5, 4, 5 ] ),
  Transformation( [ 4, 5, 5, 4, 5, 4 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 5 ] ), 
  Transformation( [ 4, 5, 5, 5, 4, 1 ] ), 
  Transformation( [ 4, 5, 5, 5, 4, 2 ] ), Transformation( [ 4, 5, 5, 5, 4 ] ),
  Transformation( [ 4, 5, 5, 5, 4, 4 ] ), 
  Transformation( [ 4, 5, 5, 5, 4, 5 ] ) ]
gap> Length(x);
200
gap> x{[1 .. 100]} = x{[101 .. 200]};
true

#T# HomomorphismDigraphsFinder 1
gap> gr := Digraph([[2, 3], [], [], [5], [], []]);
<digraph with 6 vertices, 3 edges>
gap> HomomorphismDigraphsFinder(gr, gr, fail, [], infinity, fail, false,
> [1 .. 5], [], fail, fail);
[ Transformation( [ 1, 2, 3, 4, 5, 1 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 2 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 3 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 4 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 5 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 4 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 5 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 1 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 2 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 3 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 4 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 5 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 1 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 2 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 3 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 3 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 1 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 2 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 4 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 5 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 4 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 5 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 1 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 2 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 3 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 3 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 4 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 5 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 1 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 2 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 3 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 1 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 2 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 4 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 5 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 1 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 2 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 4 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 5 ] ) ]
gap> Length(last);
39

#T# HomomorphismDigraphsFinder 2
gap> gr := Digraph([[2, 3], [], [], [5], [], []]);
<digraph with 6 vertices, 3 edges>
gap> HomomorphismDigraphsFinder(gr, gr, fail, [], infinity, fail, false,
> [1 .. 6], [], fail, fail);
[ IdentityTransformation, Transformation( [ 1, 2, 3, 4, 5, 1 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 2 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 3 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 4 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 5 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 4 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 5 ] ), Transformation( [ 1, 2, 3, 1, 2 ] ),
  Transformation( [ 1, 2, 3, 1, 2, 1 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 2 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 3 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 4 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 5 ] ), Transformation( [ 1, 2, 3, 1, 3 ] ),
  Transformation( [ 1, 2, 3, 1, 3, 1 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 2 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 3 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 3 ] ), Transformation( [ 1, 2, 2 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 1 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 2 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 4 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 5 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 4 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 5 ] ), Transformation( [ 1, 2, 2, 1, 3 ] ),
  Transformation( [ 1, 2, 2, 1, 3, 1 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 2 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 3 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 3 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 4 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 5 ] ), Transformation( [ 1, 2, 2, 1, 2 ] ),
  Transformation( [ 1, 2, 2, 1, 2, 1 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 2 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 3 ] ), Transformation( [ 4, 5, 5, 1, 2 ] ),
  Transformation( [ 4, 5, 5, 1, 2, 1 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 2 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 4 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 5 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 1 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 2 ] ), Transformation( [ 4, 5, 5, 4, 5 ] ),
  Transformation( [ 4, 5, 5, 4, 5, 4 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 5 ] ) ]
gap> Length(last);
47

#T# HomomorphismDigraphsFinder 3
gap> gr := Digraph([[2, 3], [], [], [5], [], []]);
<digraph with 6 vertices, 3 edges>
gap> gr := DigraphSymmetricClosure(gr);
<digraph with 6 vertices, 6 edges>
gap> HomomorphismDigraphsFinder(gr, gr, fail, [], infinity, fail, false,
> [1 .. 6], [], fail, fail);
[ IdentityTransformation, Transformation( [ 1, 2, 3, 4, 5, 1 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 2 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 3 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 4 ] ), 
  Transformation( [ 1, 2, 3, 4, 5, 5 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 4 ] ), Transformation( [ 1, 2, 3, 1, 2 ] ),
  Transformation( [ 1, 2, 3, 1, 2, 1 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 2 ] ), 
  Transformation( [ 1, 2, 3, 1, 2, 3 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 4 ] ), Transformation( [ 1, 2, 3, 1, 3 ] ),
  Transformation( [ 1, 2, 3, 1, 3, 1 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 2 ] ), 
  Transformation( [ 1, 2, 3, 1, 3, 3 ] ), 
  Transformation( [ 1, 2, 3, 2, 1, 4 ] ), Transformation( [ 1, 2, 3, 2, 1 ] ),
  Transformation( [ 1, 2, 3, 2, 1, 1 ] ), 
  Transformation( [ 1, 2, 3, 2, 1, 2 ] ), 
  Transformation( [ 1, 2, 3, 2, 1, 3 ] ), 
  Transformation( [ 1, 2, 3, 3, 1, 4 ] ), Transformation( [ 1, 2, 3, 3, 1 ] ),
  Transformation( [ 1, 2, 3, 3, 1, 1 ] ), 
  Transformation( [ 1, 2, 3, 3, 1, 2 ] ), 
  Transformation( [ 1, 2, 3, 3, 1, 3 ] ), 
  Transformation( [ 1, 2, 2, 3, 1, 4 ] ), Transformation( [ 1, 2, 2, 3, 1 ] ),
  Transformation( [ 1, 2, 2, 3, 1, 1 ] ), 
  Transformation( [ 1, 2, 2, 3, 1, 2 ] ), 
  Transformation( [ 1, 2, 2, 3, 1, 3 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 3 ] ), Transformation( [ 1, 2, 2 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 1 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 2 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 4 ] ), 
  Transformation( [ 1, 2, 2, 4, 5, 5 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 4 ] ), Transformation( [ 1, 2, 2, 1, 3 ] ),
  Transformation( [ 1, 2, 2, 1, 3, 1 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 2 ] ), 
  Transformation( [ 1, 2, 2, 1, 3, 3 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 3 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 4 ] ), Transformation( [ 1, 2, 2, 1, 2 ] ),
  Transformation( [ 1, 2, 2, 1, 2, 1 ] ), 
  Transformation( [ 1, 2, 2, 1, 2, 2 ] ), 
  Transformation( [ 1, 2, 2, 2, 1, 3 ] ), 
  Transformation( [ 1, 2, 2, 2, 1, 4 ] ), Transformation( [ 1, 2, 2, 2, 1 ] ),
  Transformation( [ 1, 2, 2, 2, 1, 1 ] ), 
  Transformation( [ 1, 2, 2, 2, 1, 2 ] ), 
  Transformation( [ 2, 1, 1, 3, 1, 4 ] ), Transformation( [ 2, 1, 1, 3, 1 ] ),
  Transformation( [ 2, 1, 1, 3, 1, 1 ] ), 
  Transformation( [ 2, 1, 1, 3, 1, 2 ] ), 
  Transformation( [ 2, 1, 1, 3, 1, 3 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 3 ] ), Transformation( [ 2, 1, 1 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 1 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 2 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 4 ] ), 
  Transformation( [ 2, 1, 1, 4, 5, 5 ] ), 
  Transformation( [ 2, 1, 1, 1, 3, 4 ] ), Transformation( [ 2, 1, 1, 1, 3 ] ),
  Transformation( [ 2, 1, 1, 1, 3, 1 ] ), 
  Transformation( [ 2, 1, 1, 1, 3, 2 ] ), 
  Transformation( [ 2, 1, 1, 1, 3, 3 ] ), 
  Transformation( [ 2, 1, 1, 1, 2, 3 ] ), 
  Transformation( [ 2, 1, 1, 1, 2, 4 ] ), Transformation( [ 2, 1, 1, 1, 2 ] ),
  Transformation( [ 2, 1, 1, 1, 2, 1 ] ), 
  Transformation( [ 2, 1, 1, 1, 2, 2 ] ), 
  Transformation( [ 2, 1, 1, 2, 1, 3 ] ), 
  Transformation( [ 2, 1, 1, 2, 1, 4 ] ), Transformation( [ 2, 1, 1, 2, 1 ] ),
  Transformation( [ 2, 1, 1, 2, 1, 1 ] ), 
  Transformation( [ 2, 1, 1, 2, 1, 2 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 3 ] ), Transformation( [ 4, 5, 5, 1, 2 ] ),
  Transformation( [ 4, 5, 5, 1, 2, 1 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 2 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 4 ] ), 
  Transformation( [ 4, 5, 5, 1, 2, 5 ] ), 
  Transformation( [ 4, 5, 5, 2, 1, 3 ] ), Transformation( [ 4, 5, 5, 2, 1 ] ),
  Transformation( [ 4, 5, 5, 2, 1, 1 ] ), 
  Transformation( [ 4, 5, 5, 2, 1, 2 ] ), 
  Transformation( [ 4, 5, 5, 2, 1, 4 ] ), 
  Transformation( [ 4, 5, 5, 2, 1, 5 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 1 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 2 ] ), Transformation( [ 4, 5, 5, 4, 5 ] ),
  Transformation( [ 4, 5, 5, 4, 5, 4 ] ), 
  Transformation( [ 4, 5, 5, 4, 5, 5 ] ), 
  Transformation( [ 4, 5, 5, 5, 4, 1 ] ), 
  Transformation( [ 4, 5, 5, 5, 4, 2 ] ), Transformation( [ 4, 5, 5, 5, 4 ] ),
  Transformation( [ 4, 5, 5, 5, 4, 4 ] ), 
  Transformation( [ 4, 5, 5, 5, 4, 5 ] ) ]
gap> Length(last);
100

#T# HomomorphismDigraphsFinder: finding monomorphisms
gap> gr1 := Digraph([[], [1]]);;
gap> gr1 := DigraphSymmetricClosure(gr1);;
gap> gr2 := Digraph([[], [1], [1, 3]]);;
gap> gr2 := DigraphSymmetricClosure(gr2);;
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], infinity, fail, true,
> [1, 2, 3], [], fail, fail);
[ IdentityTransformation, Transformation( [ 1, 3, 3 ] ), 
  Transformation( [ 2, 1 ] ), Transformation( [ 3, 1, 3 ] ) ]

#T# DigraphHomomorphism
gap> gr1 := Digraph([[], [3], []]);;
gap> gr2 := EmptyDigraph(10);;
gap> DigraphHomomorphism(gr1, gr2);
fail
gap> gr2 := Digraph([[], [], [], [], [4], []]);;
gap> DigraphHomomorphism(gr1, gr2);
Transformation( [ 1, 5, 4, 4, 5 ] )

#T# HomomorphismsDigraphs and HomomorphismsDigraphsRepresentatives
gap> gr1 := Digraph([[], [3], []]);;
gap> gr2 := Digraph([[], [], [], [], [4], []]);;
gap> HomomorphismsDigraphsRepresentatives(gr1, gr2);
[ Transformation( [ 1, 5, 4, 4, 5 ] ), Transformation( [ 4, 5, 4, 4, 5 ] ), 
  Transformation( [ 5, 5, 4, 4, 5 ] ) ]
gap> homos := HomomorphismsDigraphs(gr1, gr2);
[ Transformation( [ 1, 5, 4, 4, 5, 2 ] ), 
  Transformation( [ 1, 5, 4, 4, 5, 3 ] ), Transformation( [ 1, 5, 4, 4, 5 ] ),
  Transformation( [ 2, 5, 4, 4, 5, 1 ] ), 
  Transformation( [ 2, 5, 4, 4, 5, 3 ] ), Transformation( [ 2, 5, 4, 4, 5 ] ),
  Transformation( [ 3, 5, 4, 4, 5, 1 ] ), 
  Transformation( [ 3, 5, 4, 4, 5, 2 ] ), Transformation( [ 3, 5, 4, 4, 5 ] ),
  Transformation( [ 4, 5, 4, 4, 5, 1 ] ), 
  Transformation( [ 4, 5, 4, 4, 5, 2 ] ), 
  Transformation( [ 4, 5, 4, 4, 5, 3 ] ), Transformation( [ 4, 5, 4, 4, 5 ] ),
  Transformation( [ 5, 5, 4, 4, 5, 1 ] ), 
  Transformation( [ 5, 5, 4, 4, 5, 2 ] ), 
  Transformation( [ 5, 5, 4, 4, 5, 3 ] ), Transformation( [ 5, 5, 4, 4, 5 ] ),
  Transformation( [ 6, 5, 4, 4, 5, 1 ] ), 
  Transformation( [ 6, 5, 4, 4, 5, 2 ] ), 
  Transformation( [ 6, 5, 4, 4, 5, 3 ] ) ]
gap> edges := DigraphEdges(gr1);;
gap> mat := AdjacencyMatrix(gr2);;
gap> ForAll(homos, t -> ForAll(edges, e -> mat[e[1] ^ t][e[2] ^ t] = 1));
true

#T# DigraphMonomorphism
gap> gr1 := EmptyDigraph(1);;
gap> DigraphMonomorphism(gr1, gr1);
IdentityTransformation
gap> gr2 := EmptyDigraph(2);;
gap> DigraphMonomorphism(gr2, gr1);
fail
gap> DigraphMonomorphism(gr1, gr2);
IdentityTransformation
gap> DigraphMonomorphism(CompleteDigraph(2), Digraph([[2], [1, 3], [2]]));
IdentityTransformation

#T# MonomorphismsDigraphs and MonomorphismsDigraphsRepresentatives
gap> gr1 := ChainDigraph(2);;
gap> MonomorphismsDigraphs(gr1, EmptyDigraph(1));
[  ]
gap> gr2 := DigraphFromDigraph6String("+DRZ?L?");;
gap> monos := MonomorphismsDigraphs(gr1, gr2);
[ IdentityTransformation, Transformation( [ 1, 3, 3 ] ), 
  Transformation( [ 1, 5, 3, 4, 5 ] ), Transformation( [ 2, 1 ] ), 
  Transformation( [ 2, 3, 3 ] ), Transformation( [ 2, 5, 3, 4, 5 ] ), 
  Transformation( [ 3, 2, 3 ] ), Transformation( [ 4, 2, 3, 4 ] ), 
  Transformation( [ 4, 5, 3, 4, 5 ] ), Transformation( [ 5, 1, 3, 4, 5 ] ) ]
gap> monos = MonomorphismsDigraphsRepresentatives(gr1, gr2);
true
gap> monos = HomomorphismsDigraphsRepresentatives(gr1, gr2);
true

#T# DigraphEpimorphism
gap> gr1 := CycleDigraph(6);;
gap> gr2 := CycleDigraph(3);;
gap> DigraphEpimorphism(gr1, gr2);
Transformation( [ 1, 2, 3, 1, 2, 3 ] )
gap> DigraphEpimorphism(gr2, gr1);
fail

#T# EpimorphismsDigraphs and EpimorphismsDigraphsRepresentatives
gap> gr1 := CompleteDigraph(2);;
gap> gr2 := CompleteDigraph(3);;
gap> EpimorphismsDigraphs(gr1, gr2);
[  ]
gap> gr1 := DigraphFromDigraph6String("+IG????G??I??O?????");;
gap> DigraphEpimorphism(gr1, gr2);
Transformation( [ 1, 1, 2, 1, 1, 3, 1, 2, 1, 1 ] )
gap> epis := EpimorphismsDigraphsRepresentatives(gr1, gr2);;
gap> Length(epis);
972
gap> epis := EpimorphismsDigraphs(gr1, gr2);;
gap> Length(epis);
5832
gap> ForAll(epis, x -> RankOfTransformation(x, DigraphNrVertices(gr1)) = 3);
true

#T# DigraphEmbedding
gap> gr1 := CycleDigraph(3);;
gap> gr2 := CompleteBipartiteDigraph(4, 3);;
gap> DigraphEmbedding(gr1, gr2);
fail
gap> gr2 := CompleteDigraph(4);;
gap> DigraphEmbedding(gr1, gr2);
fail
gap> gr2 := Digraph([[2], [4, 1], [2], [3], [4]]);;
gap> DigraphEmbedding(gr1, gr2);
Transformation( [ 2, 4, 3, 4 ] )
gap> gr2 := CompleteDigraph(3);;
gap> DigraphEmbedding(gr1, gr2);
fail
gap> DigraphEmbedding(gr1, gr1);
IdentityTransformation

# From GR, Issue #111, bug in homomorphism finding code for restricted images.
gap> gr := DigraphFromDigraph6String(Concatenation(
> "+U^{?A?BrwAHv_CNu@SMwHQm`GpyGbUYLAbfGTO?Enool[WrI",
> "HBSatQlC[TIC{iSBlo_VrO@u[_Eyk?]YS?"));
<digraph with 22 vertices, 198 edges>
gap> t := HomomorphismDigraphsFinder(gr, gr, fail, [], 1, fail, false, 
> [2, 6, 7, 11, 12, 13, 14, 15, 19, 20, 21], [], fail, fail)[1];
Transformation( [ 2, 13, 20, 19, 21, 19, 14, 13, 15, 14, 20, 6, 15, 21, 11,
  12, 6, 7, 7, 12, 2, 11 ] )
gap> ForAll(DigraphEdges(gr), e -> IsDigraphEdge(gr, e[1] ^ t, e[2] ^ t));
true

# IsDigraphEndomorphism and IsDigraphHomomorphism
gap> gr := Digraph([[3, 4], [1, 3], [4], [1, 2, 3, 5], [2]]);
<digraph with 5 vertices, 10 edges>
gap> ForAll(GeneratorsOfEndomorphismMonoid(gr),
>           x -> IsDigraphEndomorphism(gr, x));
true
gap> x := Transformation([3, 3, 4, 4]);
Transformation( [ 3, 3, 4, 4 ] )
gap> IsDigraphEndomorphism(gr, x);
false
gap> IsDigraphHomomorphism(gr, gr, (1, 2));
false
gap> gr := Digraph([[1, 1]]);
<multidigraph with 1 vertex, 2 edges>
gap> x := Transformation([3, 3, 4, 4]);
Transformation( [ 3, 3, 4, 4 ] )
gap> IsDigraphEndomorphism(gr, x);
Error, Digraphs: IsDigraphHomomorphism: usage,
the first 2 arguments must not have multiple edges,
gap> IsDigraphEndomorphism(gr, ());
Error, Digraphs: IsDigraphIsomorphism: usage,
the first 2 arguments must not have multiple edges,
gap> IsDigraphHomomorphism(gr, gr, ());
Error, Digraphs: IsDigraphHomomorphism: usage,
the first 2 arguments must not have multiple edges,
gap> gr := DigraphTransitiveClosure(CompleteDigraph(2));
<digraph with 2 vertices, 4 edges>
gap> ForAll(GeneratorsOfEndomorphismMonoid(gr),
>           x -> IsDigraphEndomorphism(gr, x));
true
gap> x := Transformation([2, 1, 3, 3]);;
gap> IsDigraphEndomorphism(gr, x);
false
gap> x := Transformation([3, 1, 3, 3]);;
gap> IsDigraphEndomorphism(gr, x);
false
gap> IsDigraphEndomorphism(gr, ());
true
gap> IsDigraphEndomorphism(gr, (1, 2));
true
gap> IsDigraphEndomorphism(gr, (1, 2)(3, 4));
false
gap> IsDigraphEndomorphism(gr, (1, 2, 3, 4));
false
gap> IsDigraphHomomorphism(NullDigraph(1),
>                          NullDigraph(3),
>                          Transformation([2, 2]));
true

# IsDigraphEpimorphism, for transformations
gap> src := Digraph([[1], [1, 2], [1, 3]]);
<digraph with 3 vertices, 5 edges>
gap> ran := Digraph([[1], [1, 2]]);
<digraph with 2 vertices, 3 edges>
gap> IsDigraphEpimorphism(src, ran, Transformation([1, 2, 2]));
true
gap> IsDigraphEpimorphism(src, ran, Transformation([1, 2, 3]));
false
gap> IsDigraphEpimorphism(src, src, Transformation([1, 2, 3]));
true
gap> IsDigraphEpimorphism(src, src, Transformation([2, 2, 2]));
false
gap> IsDigraphEpimorphism(src, ran, Transformation([2, 2, 2]));
false

# IsDigraphEpimorphism, for perms
gap> src := Digraph([[1], [1, 2], [1, 3]]);
<digraph with 3 vertices, 5 edges>
gap> ran := Digraph([[1], [1, 2]]);
<digraph with 2 vertices, 3 edges>
gap> IsDigraphEpimorphism(src, ran, ());
false
gap> IsDigraphEpimorphism(src, ran, (1, 2));
false
gap> IsDigraphEpimorphism(src, src, ());
true
gap> IsDigraphEpimorphism(src, src, (2, 3));
true
gap> IsDigraphEpimorphism(ran, src, ());
false

# IsDigraphMonomorphism, for transformations
gap> src := Digraph([[1], [1, 2], [1, 3]]);
<digraph with 3 vertices, 5 edges>
gap> ran := Digraph([[1], [1, 2]]);
<digraph with 2 vertices, 3 edges>
gap> IsDigraphMonomorphism(src, ran, Transformation([1, 2, 2]));
false
gap> IsDigraphMonomorphism(src, ran, Transformation([1, 2, 3]));
false
gap> IsDigraphMonomorphism(src, src, Transformation([1, 2, 3]));
true
gap> IsDigraphMonomorphism(src, src, Transformation([2, 2, 2]));
false
gap> IsDigraphMonomorphism(src, ran, Transformation([2, 2, 2]));
false
gap> IsDigraphMonomorphism(ran, src, Transformation([2, 1]));
false
gap> IsDigraphMonomorphism(ran, src, Transformation([1, 2]));
true

# IsDigraphMonomorphism, for perms
gap> src := Digraph([[1], [1, 2], [1, 3]]);
<digraph with 3 vertices, 5 edges>
gap> ran := Digraph([[1], [1, 2]]);
<digraph with 2 vertices, 3 edges>
gap> IsDigraphMonomorphism(src, ran, (1, 2));
false
gap> IsDigraphMonomorphism(src, ran, ());
false
gap> IsDigraphMonomorphism(src, src, ());
true
gap> IsDigraphMonomorphism(ran, src, (1, 2));
false
gap> IsDigraphMonomorphism(ran, src, ());
true

# IsDigraphEmbedding, for transformations
gap> src := Digraph([[1], [1, 2], [1, 3]]);
<digraph with 3 vertices, 5 edges>
gap> ran := Digraph([[1], [1, 2]]);
<digraph with 2 vertices, 3 edges>
gap> IsDigraphEmbedding(src, ran, Transformation([1, 2, 2]));
false
gap> IsDigraphEmbedding(src, ran, Transformation([1, 2, 3]));
false
gap> IsDigraphEmbedding(src, src, Transformation([1, 2, 3]));
true
gap> IsDigraphEmbedding(src, src, Transformation([2, 2, 2]));
false
gap> IsDigraphEmbedding(src, ran, Transformation([2, 2, 2]));
false
gap> IsDigraphEmbedding(ran, src, Transformation([2, 1]));
false
gap> IsDigraphEmbedding(ran, src, Transformation([1, 2]));
true
gap> src := Digraph([[1], [1, 2]]);
<digraph with 2 vertices, 3 edges>
gap> ran := Digraph([[1, 2], [1, 2], [1, 3]]);
<digraph with 3 vertices, 6 edges>
gap> IsDigraphMonomorphism(src, ran, Transformation([1, 2]));
true
gap> IsDigraphEmbedding(src, ran, Transformation([1, 2]));
false

# IsDigraphEmbedding, for perms
gap> src := Digraph([[1], [1, 2], [1, 3]]);
<digraph with 3 vertices, 5 edges>
gap> ran := Digraph([[1], [1, 2]]);
<digraph with 2 vertices, 3 edges>
gap> IsDigraphEmbedding(src, ran, (1, 2));
false
gap> IsDigraphEmbedding(src, ran, ());
false
gap> IsDigraphEmbedding(src, src, ());
true
gap> IsDigraphEmbedding(ran, src, (1, 2));
false
gap> IsDigraphEmbedding(ran, src, ());
true
gap> src := Digraph([[1], [1, 2]]);
<digraph with 2 vertices, 3 edges>
gap> ran := Digraph([[1, 2], [1, 2], [1, 3]]);
<digraph with 3 vertices, 6 edges>
gap> IsDigraphMonomorphism(src, ran, ());
true
gap> IsDigraphEmbedding(src, ran, ());
false

# IsDigraphColouring
gap> D := JohnsonDigraph(5, 3);
<digraph with 10 vertices, 60 edges>
gap> IsDigraphColouring(D, [1, 2, 3, 3, 2, 1, 4, 5, 6, 7]);
true
gap> IsDigraphColouring(D, [1, 2, 3, 3, 2, 1, 2, 5, 6, 7]);
false
gap> IsDigraphColouring(D, [1, 2, 3, 3, 2, 1, 2, 5, 6, -1]);
false
gap> IsDigraphColouring(D, [1, 2, 3]);
false
gap> IsDigraphColouring(D, IdentityTransformation);
true

#T# DIGRAPHS_UnbindVariables
gap> Unbind(edges);
gap> Unbind(epis);
gap> Unbind(gens);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(homos);
gap> Unbind(mat);
gap> Unbind(monos);
gap> Unbind(x);

#E#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/grahom.tst", 0);
