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

#  HomomorphismDigraphsFinder: checking errors and robustness
gap> HomomorphismDigraphsFinder(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
Error, the 1st argument <digraph1> must be a digraph, not integer,
gap> gr1 := ChainDigraph(2);;
gap> gr2 := CompleteDigraph(3);;
gap> HomomorphismDigraphsFinder(0, gr2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
Error, the 1st argument <digraph1> must be a digraph, not integer,
gap> HomomorphismDigraphsFinder(gr1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
Error, the 2nd argument <digraph2> must be a digraph, not integer,
gap> HomomorphismDigraphsFinder(gr1, gr2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
Error, the 3rd argument <hook> must be a function with 2 arguments,
gap> HomomorphismDigraphsFinder(gr2, gr1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
Error, the 3rd argument <hook> must be a function with 2 arguments,
gap> gr1 := CompleteDigraph(2);;
gap> HomomorphismDigraphsFinder(gr1, gr2, 0, 0, 0, 0, 0, 0, 0, 0, 0);
Error, the 3rd argument <hook> must be a function with 2 arguments,
gap> HomomorphismDigraphsFinder(gr1, gr2, IsTournament, 0, 0, 0, 0, 0, 0, 0, 0);
Error, the 3rd argument <hook> must be a function with 2 arguments,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, 0, 0, 0, 0, 0, 0, 0, 0);
Error, the 3rd argument <hook> is fail and so the 4th argument must be a mutab\
le list, not integer,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, "a", "a", 0, 0, 0, 0, 0, 0);
Error, the 5th argument <max_results> must be an integer or infinity, not list\
 (string),
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, "a", 1, 0, 0, 0, 0, 0, 0);
Error, the 6th argument <hint> must be a positive integer, not 0,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, "a", 5, 1, "b", 0, 0, 0, 0);
Error, the 7th argument <injective> must be an integer or true or false, not l\
ist (string),
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, "a", infinity, fail, -1, 0, 0,
> 0, 0);
Error, the 7th argument <injective> must 0, 1, or 2, not -1,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, "a", infinity, 2, 1, 0, 0,
> 0, 0);
Error, the 8th argument <image> must be a list or fail, not integer,

# Commented out due to difference in the rmessage for GAP 4.10 vs GAP 4.11
#gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, 1, [1, []], 0,
#> 0, 0);
#Error, the 8th argument <image> must only contain positive integers, but found\
# list (plain,empty) in position 2,
#gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, 1, [[], []], 0,
#> 0, 0);
#Error, the 8th argument <image> must only contain positive integers, but found\
# list (plain,empty) in position 1,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, 1, [0, 1], 0, 0,
> 0);
Error, the 8th argument <image> must only contain positive integers, but found\
 integer in position 1,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, 1, [4, 4], 0, 0,
> 0);
Error, in the 8th argument <image> position 1 is out of range, must be in the \
range [1, 3],
gap> HomomorphismDigraphsFinder(gr2, gr1, fail, [], 1, 1, 1, [3], 0, 0, 0);
Error, in the 8th argument <image> position 1 is out of range, must be in the \
range [1, 2],
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, 1, [3], 0, 0, 0);
Error, the 9th argument <partial_map> must be a list or fail, not integer,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, 1, [3], [1 .. 4],
> 0, 0);
Error, the 9th argument <partial_map> is too long, must be at most 2, found 4,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, 1, [],
> [1, 2, 3, 2], 0, 0);
Error, the 9th argument <partial_map> is too long, must be at most 2, found 4,
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, 1, [1], [1],
> fail, fail);
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
[  ]
gap> HomomorphismDigraphsFinder(CompleteDigraph(2),
>                               CompleteDigraph(3),
>                               fail,    # hook
>                               [],      # user_param
>                               1,       # limit
>                               2,       # hint      (rank 2)
>                               1,       # injective (yes)
>                               [1, 2],  # only values 1 and 2 in the image
>                               [1],     # 1 -> 1
>                               fail,    # no colours
>                               fail);   # no colours
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
[ IdentityTransformation ]
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 3, 0, [1, 2], [1],
> fail, fail);
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
[  ]
gap> HomomorphismDigraphsFinder(gr2, gr1, fail, [], 1, 3, 0, [1, 2], [1],
> fail, fail);
[  ]
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, 0, [], [], fail,
> fail);
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
[  ]
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, 0, [1, 2], [],
> fail, fail);
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
[  ]
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 1, 0, [1, 2], [],
> fail, fail);
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
[  ]
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, 2, 0, [1], [], fail,
> fail);
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
[  ]
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, 0, [1, 2], [],
> fail, fail);
[ IdentityTransformation ]
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, 0, [1, 2],
> [], [[1, 2]], fail);
Error, the 10th and 11th arguments <colors1> and <colors2> must both be lists \
or both be fail,
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, 0, [1, 2],
> [], fail, [[1, 2]]);
Error, the 10th and 11th arguments <colors1> and <colors2> must both be lists \
or both be fail,
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, 0, [1, 2],
> [], [[1, 2]], [[1, 2]]);
[ IdentityTransformation ]
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, 0, [1, 2],
> [], [[1, 2], [2]], [[1, 2]]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 2], since it contains the vertex 2 more than once,
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, 0, [1, 2],
> [], [1, 2], [2, 1]);
[ Transformation( [ 2, 1 ] ) ]
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, 0, [1, 2],
> [], [1, 2, 3], [2, 1]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 
2
 ]. The 2nd argument must have one of the following forms: 1. a list of length 
2 consisting of every integer in the range [1 .. m], for some m <= 
2; or 2. a list of non-empty disjoint lists whose union is [1 .. 2].
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, 0, [1, 2],
> [], [1, 3], [2, 1]);
Error, the 2nd argument <partition> does not define a colouring of the vertice\
s [1 .. 2], since it contains the integer 3, which is greater than 2,
gap> HomomorphismDigraphsFinder(gr1, gr1, fail, [], 1, 2, 0, [1, 2],
> [], [1, fail], [2, 1]);
Error, the 2nd argument <partition> must be a homogeneous list,
gap> gr := ChainDigraph(2);
<immutable chain digraph with 2 vertices>
gap> GeneratorsOfEndomorphismMonoid();
Error, at least 1 argument expected, found 0,
gap> GeneratorsOfEndomorphismMonoid(Group(()));
Error, the 1st argument must be a digraph,
gap> GeneratorsOfEndomorphismMonoid(gr);
[ IdentityTransformation ]
gap> gr := DigraphTransitiveClosure(CompleteDigraph(2));
<immutable transitive digraph with 2 vertices, 4 edges>
gap> DigraphHasLoops(gr);
true
gap> GeneratorsOfEndomorphismMonoid(gr);
[ Transformation( [ 2, 1 ] ), IdentityTransformation, 
  Transformation( [ 1, 1 ] ) ]
gap> gr := EmptyDigraph(2);
<immutable empty digraph with 2 vertices>
gap> GeneratorsOfEndomorphismMonoid(gr, Group(()), Group((1, 2)));
Error, the 2nd argument must be a homogeneous list,
gap> gr := EmptyDigraph(2);;
gap> GeneratorsOfEndomorphismMonoid(gr, Group(()));
Error, the 2nd argument must be a homogeneous list,
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
[ Transformation( [ 2, 3, 4, 5, 1 ] ), Transformation( [ 2, 1 ] ), 
  IdentityTransformation ]
gap> GeneratorsOfEndomorphismMonoid(gr, [1, 1, 1, 2, 2]);
[ Transformation( [ 1, 2, 3, 5, 4 ] ), Transformation( [ 1, 3, 2 ] ), 
  Transformation( [ 2, 1 ] ), IdentityTransformation ]
gap> GeneratorsOfEndomorphismMonoid(gr, [1, 1, 1, 2, 2], 1);
[ Transformation( [ 1, 2, 3, 5, 4 ] ), Transformation( [ 1, 3, 2 ] ), 
  Transformation( [ 2, 1 ] ) ]
gap> GeneratorsOfEndomorphismMonoid(gr, [1, 1, 1, 2, 2], 0);
Error, the 3rd argument must be a positive integer or infinity,

#  GeneratorsOfEndomorphismMonoid: digraphs with loops

# loops1
gap> gr := Digraph([[], [2]]);
<immutable digraph with 2 vertices, 1 edge>
gap> GeneratorsOfEndomorphismMonoid(gr);
[ IdentityTransformation, Transformation( [ 2, 2 ] ) ]

# loops2
gap> gr := Digraph([[2], [], [3]]);
<immutable digraph with 3 vertices, 2 edges>
gap> GeneratorsOfEndomorphismMonoid(gr);
[ IdentityTransformation, Transformation( [ 3, 3, 3 ] ) ]

# loops3
gap> gr := Digraph([[2], [1], [3]]);
<immutable digraph with 3 vertices, 3 edges>
gap> GeneratorsOfEndomorphismMonoid(gr);
[ Transformation( [ 2, 1 ] ), IdentityTransformation, 
  Transformation( [ 3, 3, 3 ] ) ]

#  DigraphGreedyColouring and DigraphColouring: checking errors and robustness
gap> gr := Digraph([[2, 2], []]);
<immutable multidigraph with 2 vertices, 2 edges>
gap> DigraphColouring(gr, 1);
fail
gap> gr := EmptyDigraph(3);
<immutable empty digraph with 3 vertices>
gap> DigraphColouring(gr, 4);
fail
gap> DigraphColouring(gr, 3);
IdentityTransformation
gap> DigraphColouring(gr, 2);
Transformation( [ 1, 1, 2 ] )
gap> DigraphColouring(gr, 1);
Transformation( [ 1, 1, 1 ] )
gap> gr := CompleteDigraph(3);
<immutable complete digraph with 3 vertices>
gap> DigraphColouring(gr, 1);
fail
gap> DigraphColouring(gr, 2);
fail
gap> DigraphColouring(gr, 3);
IdentityTransformation
gap> gr := EmptyDigraph(0);
<immutable empty digraph with 0 vertices>
gap> DigraphColouring(gr, 1);
fail
gap> DigraphColouring(gr, 2);
fail
gap> DigraphColouring(gr, 3);
fail
gap> gr := EmptyDigraph(1);
<immutable empty digraph with 1 vertex>
gap> DigraphColouring(gr, 1);
IdentityTransformation
gap> DigraphColouring(gr, 2);
fail
gap> gr := Digraph([[1, 2], []]);;
gap> DigraphColouring(gr, -1);
Error, the 2nd argument <n> must be a non-negative integer,
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
<immutable digraph with 45 vertices, 180 edges>
gap> DigraphGreedyColouring(gr);
Transformation( [ 1, 1, 1, 1, 1, 2, 2, 1, 2, 2, 2, 1, 1, 2, 1, 2, 1, 2, 2, 3,
  3, 2, 3, 3, 3, 2, 1, 4, 4, 2, 3, 3, 3, 3, 3, 1, 3, 4, 4, 3, 2, 1, 4, 3,
  1 ] )
gap> DigraphColouring(gr, 4);
Transformation( [ 1, 1, 1, 1, 1, 2, 2, 1, 2, 2, 2, 1, 1, 2, 1, 2, 1, 2, 2, 3,
  3, 2, 3, 3, 3, 2, 1, 4, 4, 2, 3, 3, 3, 3, 3, 1, 3, 4, 4, 3, 2, 1, 4, 3,
  1 ] )
gap> D := Digraph([[4, 6, 8], [], [], [], [7], [2], [], [], [8], []]);
<immutable digraph with 10 vertices, 6 edges>
gap> DigraphColouring(D, 2);
Transformation( [ 1, 1, 1, 2, 1, 2, 2, 2, 1, 1 ] )
gap> DigraphColouring(Digraph([[1], []]), 2);
fail

#  DigraphGreedyColouring
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
<immutable symmetric digraph with 30 vertices, 90 edges>
gap> DigraphGreedyColouring(gr);;
gap> DigraphGreedyColouring(EmptyDigraph(0));
IdentityTransformation
gap> DigraphGreedyColouring(gr, [1 .. 10]);
Error, the 2nd argument <order> must be a permutation of [1 .. 30]
gap> DigraphGreedyColouring(gr, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
> 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, -1]);
Error, the 2nd argument <order> must be a permutation of [1 .. 30]
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
<immutable symmetric digraph with 30 vertices, 90 edges>
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
<immutable symmetric digraph with 30 vertices, 90 edges>
gap> DigraphGreedyColouring(gr, order_func);
Transformation( [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2,
  2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ] )
gap> DigraphGreedyColouring(EmptyDigraph(0));
IdentityTransformation

#  HomomorphismDigraphsFinder 1
gap> gr := Digraph([[2, 3], [], [], [5], [], []]);;
gap> gr := DigraphSymmetricClosure(gr);;
gap> x := [];;
gap> HomomorphismDigraphsFinder(gr, gr, fail, x, infinity, fail, 0,
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
gap> HomomorphismDigraphsFinder(gr, gr, fail, x, infinity, fail, 0,
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

#  HomomorphismDigraphsFinder 1
gap> gr := Digraph([[2, 3], [], [], [5], [], []]);
<immutable digraph with 6 vertices, 3 edges>
gap> HomomorphismDigraphsFinder(gr, gr, fail, [], infinity, fail, 0,
> [1 .. 5], [], fail, fail);
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
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

#  HomomorphismDigraphsFinder 2
gap> gr := Digraph([[2, 3], [], [], [5], [], []]);
<immutable digraph with 6 vertices, 3 edges>
gap> HomomorphismDigraphsFinder(gr, gr, fail, [], infinity, fail, 0,
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

#  HomomorphismDigraphsFinder 3
gap> gr := Digraph([[2, 3], [], [], [5], [], []]);
<immutable digraph with 6 vertices, 3 edges>
gap> gr := DigraphSymmetricClosure(gr);
<immutable symmetric digraph with 6 vertices, 6 edges>
gap> HomomorphismDigraphsFinder(gr, gr, fail, [], infinity, fail, 0,
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

#  HomomorphismDigraphsFinder: finding monomorphisms
gap> gr1 := Digraph([[], [1]]);;
gap> gr1 := DigraphSymmetricClosure(gr1);;
gap> gr2 := Digraph([[], [1], [1, 3]]);;
gap> gr2 := DigraphSymmetricClosure(gr2);;
gap> HomomorphismDigraphsFinder(gr1, gr2, fail, [], infinity, fail, 1,
> [1, 2, 3], [], fail, fail);
[ IdentityTransformation, Transformation( [ 1, 3, 3 ] ), 
  Transformation( [ 2, 1 ] ), Transformation( [ 3, 1, 3 ] ) ]

# HomomorphismDigraphsFinder: using a subgroup of automorphisms
gap> HomomorphismDigraphsFinder(NullDigraph(4), CompleteDigraph(4),
> fail, [], infinity, fail, 1, [1 .. 4], [], fail, fail,
> Group(()));
[ IdentityTransformation, Transformation( [ 1, 2, 4, 3 ] ), 
  Transformation( [ 1, 3, 2 ] ), Transformation( [ 1, 3, 4, 2 ] ), 
  Transformation( [ 1, 4, 2, 3 ] ), Transformation( [ 1, 4, 3, 2 ] ), 
  Transformation( [ 2, 1 ] ), Transformation( [ 2, 1, 4, 3 ] ), 
  Transformation( [ 2, 3, 1 ] ), Transformation( [ 2, 3, 4, 1 ] ), 
  Transformation( [ 2, 4, 1, 3 ] ), Transformation( [ 2, 4, 3, 1 ] ), 
  Transformation( [ 3, 1, 2 ] ), Transformation( [ 3, 1, 4, 2 ] ), 
  Transformation( [ 3, 2, 1 ] ), Transformation( [ 3, 2, 4, 1 ] ), 
  Transformation( [ 3, 4, 1, 2 ] ), Transformation( [ 3, 4, 2, 1 ] ), 
  Transformation( [ 4, 1, 2, 3 ] ), Transformation( [ 4, 1, 3, 2 ] ), 
  Transformation( [ 4, 2, 1, 3 ] ), Transformation( [ 4, 2, 3, 1 ] ), 
  Transformation( [ 4, 3, 1, 2 ] ), Transformation( [ 4, 3, 2, 1 ] ) ]
gap> HomomorphismDigraphsFinder(NullDigraph(4), CompleteDigraph(4),
> fail, [], infinity, fail, 1, [1 .. 4], [], fail, fail,
> Group((2, 3)));
[ IdentityTransformation, Transformation( [ 1, 2, 4, 3 ] ), 
  Transformation( [ 1, 4, 2, 3 ] ), Transformation( [ 2, 1 ] ), 
  Transformation( [ 2, 1, 4, 3 ] ), Transformation( [ 2, 3, 1 ] ), 
  Transformation( [ 2, 3, 4, 1 ] ), Transformation( [ 2, 4, 1, 3 ] ), 
  Transformation( [ 2, 4, 3, 1 ] ), Transformation( [ 4, 1, 2, 3 ] ), 
  Transformation( [ 4, 2, 1, 3 ] ), Transformation( [ 4, 2, 3, 1 ] ) ]
gap> HomomorphismDigraphsFinder(NullDigraph(4), CompleteDigraph(4),
> fail, [], infinity, fail, 1, [1 .. 4], [], fail, fail,
> Group((1, 2, 3)));
[ IdentityTransformation, Transformation( [ 1, 2, 4, 3 ] ), 
  Transformation( [ 1, 3, 2 ] ), Transformation( [ 1, 3, 4, 2 ] ), 
  Transformation( [ 1, 4, 2, 3 ] ), Transformation( [ 1, 4, 3, 2 ] ), 
  Transformation( [ 4, 1, 2, 3 ] ), Transformation( [ 4, 1, 3, 2 ] ) ]
gap> HomomorphismDigraphsFinder(NullDigraph(4), CompleteDigraph(4),
> fail, [], infinity, fail, 2, [1 .. 4], [], fail, fail,
> Group((2, 3)));
[  ]
gap> HomomorphismDigraphsFinder(NullDigraph(4), CompleteDigraph(4),
> fail, [], infinity, fail, 0, [1 .. 4], [], fail, fail,
> Group((1, 2), (2, 3)));
[ IdentityTransformation, Transformation( [ 1, 2, 3, 1 ] ), 
  Transformation( [ 1, 2, 3, 2 ] ), Transformation( [ 1, 2, 3, 3 ] ), 
  Transformation( [ 1, 2, 4, 3 ] ), Transformation( [ 1, 2, 4, 1 ] ), 
  Transformation( [ 1, 2, 4, 2 ] ), Transformation( [ 1, 2, 4, 4 ] ), 
  Transformation( [ 1, 2, 1, 3 ] ), Transformation( [ 1, 2, 1 ] ), 
  Transformation( [ 1, 2, 1, 1 ] ), Transformation( [ 1, 2, 1, 2 ] ), 
  Transformation( [ 1, 2, 2, 3 ] ), Transformation( [ 1, 2, 2 ] ), 
  Transformation( [ 1, 2, 2, 1 ] ), Transformation( [ 1, 2, 2, 2 ] ), 
  Transformation( [ 1, 4, 2, 3 ] ), Transformation( [ 1, 4, 2, 1 ] ), 
  Transformation( [ 1, 4, 2, 2 ] ), Transformation( [ 1, 4, 2, 4 ] ), 
  Transformation( [ 1, 4, 1, 2 ] ), Transformation( [ 1, 4, 1, 1 ] ), 
  Transformation( [ 1, 4, 1, 4 ] ), Transformation( [ 1, 4, 4, 2 ] ), 
  Transformation( [ 1, 4, 4, 1 ] ), Transformation( [ 1, 4, 4, 4 ] ), 
  Transformation( [ 1, 1, 2, 3 ] ), Transformation( [ 1, 1, 2 ] ), 
  Transformation( [ 1, 1, 2, 1 ] ), Transformation( [ 1, 1, 2, 2 ] ), 
  Transformation( [ 1, 1, 4, 2 ] ), Transformation( [ 1, 1, 4, 1 ] ), 
  Transformation( [ 1, 1, 4, 4 ] ), Transformation( [ 1, 1, 1, 2 ] ), 
  Transformation( [ 1, 1, 1 ] ), Transformation( [ 1, 1, 1, 1 ] ), 
  Transformation( [ 4, 1, 2, 3 ] ), Transformation( [ 4, 1, 2, 1 ] ), 
  Transformation( [ 4, 1, 2, 2 ] ), Transformation( [ 4, 1, 2, 4 ] ), 
  Transformation( [ 4, 1, 1, 2 ] ), Transformation( [ 4, 1, 1, 1 ] ), 
  Transformation( [ 4, 1, 1, 4 ] ), Transformation( [ 4, 1, 4, 2 ] ), 
  Transformation( [ 4, 1, 4, 1 ] ), Transformation( [ 4, 1, 4, 4 ] ), 
  Transformation( [ 4, 4, 1, 2 ] ), Transformation( [ 4, 4, 1, 1 ] ), 
  Transformation( [ 4, 4, 1, 4 ] ), Transformation( [ 4, 4, 4, 1 ] ), 
  Transformation( [ 4, 4, 4, 4 ] ) ]
gap> HomomorphismDigraphsFinder(NullDigraph(4), CompleteDigraph(4),
> fail, [], infinity, fail, 0, [1 .. 4], [], fail, fail,
> Group((1, 2, 3, 4), (1, 2)));
[ IdentityTransformation, Transformation( [ 1, 2, 3, 1 ] ), 
  Transformation( [ 1, 2, 3, 2 ] ), Transformation( [ 1, 2, 3, 3 ] ), 
  Transformation( [ 1, 2, 1, 3 ] ), Transformation( [ 1, 2, 1, 1 ] ), 
  Transformation( [ 1, 2, 1, 2 ] ), Transformation( [ 1, 2, 2, 3 ] ), 
  Transformation( [ 1, 2, 2, 1 ] ), Transformation( [ 1, 2, 2, 2 ] ), 
  Transformation( [ 1, 1, 2, 3 ] ), Transformation( [ 1, 1, 2, 1 ] ), 
  Transformation( [ 1, 1, 2, 2 ] ), Transformation( [ 1, 1, 1, 2 ] ), 
  Transformation( [ 1, 1, 1, 1 ] ) ]
gap> HomomorphismDigraphsFinder(NullDigraph(4), CompleteDigraph(4),
> fail, [], infinity, fail, 0, [1 .. 4], [], fail, fail);
[ IdentityTransformation, Transformation( [ 1, 2, 3, 1 ] ), 
  Transformation( [ 1, 2, 3, 2 ] ), Transformation( [ 1, 2, 3, 3 ] ), 
  Transformation( [ 1, 2, 1, 3 ] ), Transformation( [ 1, 2, 1, 1 ] ), 
  Transformation( [ 1, 2, 1, 2 ] ), Transformation( [ 1, 2, 2, 3 ] ), 
  Transformation( [ 1, 2, 2, 1 ] ), Transformation( [ 1, 2, 2, 2 ] ), 
  Transformation( [ 1, 1, 2, 3 ] ), Transformation( [ 1, 1, 2, 1 ] ), 
  Transformation( [ 1, 1, 2, 2 ] ), Transformation( [ 1, 1, 1, 2 ] ), 
  Transformation( [ 1, 1, 1, 1 ] ) ]
gap> HomomorphismDigraphsFinder(CompleteDigraph(3), CompleteDigraph(3),
> fail, [], infinity, fail, 1, [1 .. 3], [], fail, fail,
> Group((1, 2, 3)));
[ IdentityTransformation, Transformation( [ 1, 3, 2 ] ) ]

#  DigraphHomomorphism
gap> gr1 := Digraph([[], [3], []]);;
gap> gr2 := EmptyDigraph(10);;
gap> DigraphHomomorphism(gr1, gr2);
fail
gap> gr2 := Digraph([[], [], [], [], [4], []]);;
gap> DigraphHomomorphism(gr1, gr2);
Transformation( [ 1, 5, 4, 4, 5 ] )

#  HomomorphismsDigraphs and HomomorphismsDigraphsRepresentatives
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

#  DigraphMonomorphism
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

#  MonomorphismsDigraphs and MonomorphismsDigraphsRepresentatives
gap> gr1 := ChainDigraph(2);;
gap> MonomorphismsDigraphs(gr1, EmptyDigraph(1));
[  ]
gap> gr2 := DigraphFromDigraph6String("&DZTAW?");;
gap> monos := MonomorphismsDigraphs(gr1, gr2);
[ IdentityTransformation, Transformation( [ 1, 3, 3 ] ), 
  Transformation( [ 1, 5, 3, 4, 5 ] ), Transformation( [ 2, 1 ] ), 
  Transformation( [ 2, 3, 3 ] ), Transformation( [ 2, 5, 3, 4, 5 ] ), 
  Transformation( [ 3, 2, 3 ] ), Transformation( [ 4, 2, 3, 4 ] ), 
  Transformation( [ 4, 5, 3, 4, 5 ] ), Transformation( [ 5, 1, 3, 4, 5 ] ) ]
gap> ForAll(monos, x -> IsDigraphMonomorphism(gr1, gr2, x));
true
gap> monos = MonomorphismsDigraphsRepresentatives(gr1, gr2);
true
gap> monos = HomomorphismsDigraphsRepresentatives(gr1, gr2);
true

#  DigraphEpimorphism
gap> gr1 := CycleDigraph(6);;
gap> gr2 := CycleDigraph(3);;
gap> DigraphEpimorphism(gr1, gr2);
Transformation( [ 1, 2, 3, 1, 2, 3 ] )
gap> DigraphEpimorphism(gr2, gr1);
fail

#  EpimorphismsDigraphs and EpimorphismsDigraphsRepresentatives
gap> gr1 := CompleteDigraph(2);;
gap> gr2 := CompleteDigraph(3);;
gap> EpimorphismsDigraphs(gr1, gr2);
[  ]
gap> gr1 := DigraphFromDigraph6String("&I@??HO???????A????");;
gap> IsDigraphEpimorphism(gr1, gr2, DigraphEpimorphism(gr1, gr2));
true
gap> epis := EpimorphismsDigraphsRepresentatives(gr1, gr2);;
gap> Length(epis);
972
gap> epis := EpimorphismsDigraphs(gr1, gr2);;
gap> Length(epis);
5832
gap> ForAll(epis, x -> RankOfTransformation(x, DigraphNrVertices(gr1)) = 3);
true

#  DigraphEmbedding
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
gap> D := NullDigraph(2);;
gap> DD := DigraphFromDiSparse6String(Concatenation(
> ".~?C?_W@GN?e??@`W?wJ`cAG^?EG_@AEH?CacDWj@M??ga{Igq?WG_gbO?_J?}L_I_IFG~@?",
> "G_u_AAhBAiPOD`IB_QCEOxAck@HNB}KpK_KMhSBQ?`Hd[L?z`CIxY?}VOU`OGGteCVxHbcNXB",
> "d}JxO_uYo|bwVxmBiXxqEy\\ODf[SwOfwL`tgCOpncU`p~`e[WcA_JxYgsD@dg{Bpu`[bYRAc",
> "]hoHAd_BDIe@`hgBoed{ZwiaGOxFCs]HyeQ]XAbYL`}fmhogCSaYhEyTaR_?JAIdOYaTiwD@E",
> "Em@hFFObiqBSiYs@CQPKEaQWHBAMW]`Whw\\IIC?hAgPIKJQ[qjaciiTeYSP\\IWiXk_s[@pf",
> "?^BBa?SpkfiUwBAGRH[ck_zL@oJZNKq?PCGknHi_wciolS@O\\IuaGJLANx]LQD_]bW]J\\@_",
> "QPxK?uG@m?I_tCcnrDLMD@XKQLQ[b[cqX_?QA[e{]qlislBXjmGozLyXYTMQUQP_grj?aSkz^",
> "f{qrTiiQAtgWsrUhYXb@jsorreWbRCNAA_bIqSwxL}CQ_I_zru`sK@]GShrQNIziUes^K?`c?",
> "gSa?CGEaKDghAYEGkAmL_bbg@WHAyGHB?YPobcg@gHAuR_TdC?`D_KGhUAONxY@IVOC@IVpUD",
> "qVGkeKDW[B?KXf@MJGXdySg[e{YgfEiL`CCwSPUfKVpm`sH?ef[NgECY^?XfwB@u`SNiAEE[W",
> "D@uOiGCOSII@Y`Hk_W[yNDmGIQ?O\\iOeId_\\daCwOCgWGW@wSp_hobyOb_]y_A{OpLhIJaO",
> "`wTydAOdhugQiPaikN@GIa\\HBGmJaIj?Xw@A?ZhC`ElOHj[@HsjgRATHqG@AF}PpJHyoQtkK",
> "M`bGenigk[oWNIokHH_{LaugGlbG_sJGZEkhWMA[gGPFusOcKEsoyEqtP~aGMPll_T`iKuBOW",
> "gIArIdAG@C`{PGGb]^Zb?ehwnKewWiLWwhPmUBjemsgGvIu{@RLIDrB`i{IQM]bBqcKyWLFcn",
> "zxKICIyKyEgI@g{XDeGbN"));;
gap> DigraphEmbedding(D, DD);
IdentityTransformation
gap> D := DigraphDisjointUnion(CycleDigraph(3), CycleDigraph(5));;
gap> D := DigraphSymmetricClosure(D);;
gap> DigraphEmbedding(CycleDigraph(5), D);
fail
gap> DigraphEmbedding(DigraphSymmetricClosure(CycleDigraph(5)), D);
Transformation( [ 4, 5, 6, 7, 8, 6, 7, 8 ] )

# From GR, Issue #111, bug in homomorphism finding code for restricted images.
gap> gr := DigraphFromDigraph6String(Concatenation(
> "+U^{?A?BrwAHv_CNu@SMwHQm`GpyGbUYLAbfGTO?Enool[WrI",
> "HBSatQlC[TIC{iSBlo_VrO@u[_Eyk?]YS?"));
<immutable digraph with 22 vertices, 198 edges>
gap> t := HomomorphismDigraphsFinder(gr, gr, fail, [], 1, fail, 0,
> [2, 6, 7, 11, 12, 13, 14, 15, 19, 20, 21], [], fail, fail)[1];
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
Transformation( [ 2, 13, 20, 19, 21, 19, 14, 13, 15, 14, 20, 6, 15, 21, 11,
  12, 6, 7, 7, 12, 2, 11 ] )
gap> ForAll(DigraphEdges(gr), e -> IsDigraphEdge(gr, e[1] ^ t, e[2] ^ t));
true

# IsDigraphEndomorphism and IsDigraphHomomorphism
gap> gr := Digraph([[3, 4], [1, 3], [4], [1, 2, 3, 5], [2]]);
<immutable digraph with 5 vertices, 10 edges>
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
<immutable multidigraph with 1 vertex, 2 edges>
gap> x := Transformation([3, 3, 4, 4]);
Transformation( [ 3, 3, 4, 4 ] )
gap> IsDigraphEndomorphism(gr, x);
Error, the 1st and 2nd arguments <src> and <ran> must be digraphs with no mult\
iple edges,
gap> IsDigraphEndomorphism(gr, ());
Error, the 1st and 2nd arguments <src> and <ran> must not have multiple edges,
gap> IsDigraphHomomorphism(gr, gr, ());
Error, the 1st and 2nd arguments <src> and <ran> must be digraphs with no mult\
iple edges,
gap> gr := DigraphTransitiveClosure(CompleteDigraph(2));
<immutable transitive digraph with 2 vertices, 4 edges>
gap> ForAll(GeneratorsOfEndomorphismMonoid(gr),
>           x -> IsDigraphEndomorphism(gr, x));
true
gap> x := Transformation([2, 1, 3, 3]);;
gap> ForAll(DigraphEdges(gr), e -> IsDigraphEdge(gr, e[1] ^ x, e[2] ^ x));
true
gap> IsDigraphEndomorphism(gr, x);
true
gap> x := Transformation([3, 1, 3, 3]);;
gap> IsDigraphEndomorphism(gr, x);
false
gap> IsDigraphEndomorphism(gr, ());
true
gap> IsDigraphEndomorphism(gr, (1, 2));
true
gap> x := (1, 2)(3, 4);
(1,2)(3,4)
gap> IsDigraphEndomorphism(gr, x);
true
gap> ForAll(DigraphEdges(gr), e -> IsDigraphEdge(gr, e[1] ^ x, e[2] ^ x));
true
gap> IsDigraphEndomorphism(gr, (1, 2, 3, 4));
false
gap> IsDigraphHomomorphism(NullDigraph(1),
>                          NullDigraph(3),
>                          Transformation([2, 2]));
true

# IsDigraphEpimorphism, for transformations
gap> src := Digraph([[1], [1, 2], [1, 3]]);
<immutable digraph with 3 vertices, 5 edges>
gap> ran := Digraph([[1], [1, 2]]);
<immutable digraph with 2 vertices, 3 edges>
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
<immutable digraph with 3 vertices, 5 edges>
gap> ran := Digraph([[1], [1, 2]]);
<immutable digraph with 2 vertices, 3 edges>
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
<immutable digraph with 3 vertices, 5 edges>
gap> ran := Digraph([[1], [1, 2]]);
<immutable digraph with 2 vertices, 3 edges>
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
<immutable digraph with 3 vertices, 5 edges>
gap> ran := Digraph([[1], [1, 2]]);
<immutable digraph with 2 vertices, 3 edges>
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
<immutable digraph with 3 vertices, 5 edges>
gap> ran := Digraph([[1], [1, 2]]);
<immutable digraph with 2 vertices, 3 edges>
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
<immutable digraph with 2 vertices, 3 edges>
gap> ran := Digraph([[1, 2], [1, 2], [1, 3]]);
<immutable digraph with 3 vertices, 6 edges>
gap> IsDigraphMonomorphism(src, ran, Transformation([1, 2]));
true
gap> IsDigraphEmbedding(src, ran, Transformation([1, 2]));
false

# IsDigraphEmbedding, for perms
gap> src := Digraph([[1], [1, 2], [1, 3]]);
<immutable digraph with 3 vertices, 5 edges>
gap> ran := Digraph([[1], [1, 2]]);
<immutable digraph with 2 vertices, 3 edges>
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
<immutable digraph with 2 vertices, 3 edges>
gap> ran := Digraph([[1, 2], [1, 2], [1, 3]]);
<immutable digraph with 3 vertices, 6 edges>
gap> IsDigraphMonomorphism(src, ran, ());
true
gap> IsDigraphEmbedding(src, ran, ());
false

# IsDigraphColouring
gap> D := JohnsonDigraph(5, 3);
<immutable symmetric digraph with 10 vertices, 60 edges>
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

# HomomorphismDigraphsFinder - non-symmetric digraph with colours
gap> D := Digraph([[2, 3], [], []]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               3,           # hint
>                               0,           # injective
>                               [1, 2, 3],   # image
>                               [],          # map
>                               [1, 2, 3],   # colours1
>                               [1, 3, 2]);  # colours2
[ Transformation( [ 1, 3, 2 ] ) ]

# HomomorphismDigraphsFinder - partial map defined
gap> D := Digraph([[2, 3], [], []]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               3,           # hint
>                               0,           # injective
>                               [1, 2, 3],   # image
>                               [,, 2],      # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> D := Digraph([[2, 3], [], []]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               1,           # hint
>                               0,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[  ]
gap> D := Digraph([[2, 3], [], []]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               2,           # hint
>                               0,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 3 ] ) ]
gap> D := Digraph([[2, 3], [], []]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               3,           # hint
>                               0,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> D := Digraph([[2, 3], [], []]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               0,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]

# Test monomorphisms for digraphs
gap> D := Digraph([[2, 3], [], []]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               1,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               1,           # injective
>                               [1, 2, 3],   # image
>                               [3, 3],      # map
>                               fail,        # colours1
>                               fail);       # colours2
[  ]
gap> D := Digraph([[2, 3], [2], [3]]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               1,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> D := Digraph([[2, 3], [2], [3]]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               1,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> D := Digraph([[2, 3], [], []]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               1,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               [1, 2, 3],   # colours1
>                               [1, 3, 2]);  # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               1,           # injective
>                               [1, 2, 3],   # image
>                               [],          # map
>                               [1, 2, 3],   # colours1
>                               [1, 3, 2]);  # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               2,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               2,           # injective
>                               [1, 2, 3],   # image
>                               [3, 3],      # map
>                               fail,        # colours1
>                               fail);       # colours2
[  ]

# Test embeddings for digraphs
gap> D := Digraph([[2, 3], [2], [3]]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               2,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> D := Digraph([[2, 3], [2], [3]]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               2,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> D := Digraph([[2, 3], [], []]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               2,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               [1, 2, 3],   # colours1
>                               [1, 3, 2]);  # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               2,           # injective
>                               [1, 2, 3],   # image
>                               [],          # map
>                               [1, 2, 3],   # colours1
>                               [1, 3, 2]);  # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               2,           # injective
>                               [2, 3],      # image
>                               [],          # map
>                               [1, 2, 3],   # colours1
>                               [1, 3, 2]);  # colours2
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
[  ]
gap> EmbeddingsDigraphsRepresentatives(NullDigraph(2),
>                                      Digraph([[2, 3], [], []]));
[ Transformation( [ 2, 3, 3 ] ) ]

#
gap> D1 := NullDigraph(2);;
gap> D2 := DigraphFromDiSparse6String(Concatenation(
> ".~?@c_oAN?xSA_XcBf?q^?YK?iooXja]oBJGlgZ_CLzgQoAn?kWjDIK[?P[c_qpNLM{",
> "{KFRMns`WmtSNCuT^Z?a[rvOeCCdvGixXG`ZFc__AF?hKMg?IaGH]gGIAm?z?_lpGdmR",
> "UzMYQmoASkoKS]prafo[wws?[R_AcjsseVtaiXLcvXSwg`v@gfKBQ^KJc|n]D\\thb"));;
gap> DigraphMonomorphism(D1, D2);
IdentityTransformation
gap> D1 := CompleteDigraph(2);;
gap> DigraphMonomorphism(D1, D2);
Transformation( [ 65, 66, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36,
  37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55,
  56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66 ] )
gap> D := DigraphFromDigraph6String(Concatenation(
> "+U^{?A?BrwAHv_CNu@SMwHQm`GpyGbUYLAbfGTO?Enool[WrI",
> "HBSatQlC[TIC{iSBlo_VrO@u[_Eyk?]YS?"));;
gap> HomomorphismDigraphsFinder(D, D, fail, [], 1, fail, 1,
> [2, 6, 7, 11, 12, 13, 14, 15, 19, 20, 21], [], fail, fail);
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
[  ]
gap> D := Digraph([[2], []]);;
gap> HomomorphismDigraphsFinder(D, D, fail, [], 1, fail, 1,
> [1], [], fail, fail);
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
[  ]

# Test monomorphisms for graphs
gap> D := Digraph([[2, 3], [1], [1]]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               1,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> D := Digraph([[2, 3], [1], [1]]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               0,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               1,           # injective
>                               [1, 2, 3],   # image
>                               [3, 3],      # map
>                               fail,        # colours1
>                               fail);       # colours2
[  ]
gap> D := Digraph([[2, 3], [1, 2], [1, 3]]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               1,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> D := Digraph([[2, 3], [1, 2], [1, 3]]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               1,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> D := Digraph([[2, 3], [1], [1]]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               1,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               [1, 2, 3],   # colours1
>                               [1, 3, 2]);  # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               1,           # injective
>                               [1, 2, 3],   # image
>                               [],          # map
>                               [1, 2, 3],   # colours1
>                               [1, 3, 2]);  # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               2,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               2,           # injective
>                               [1, 2, 3],   # image
>                               [3, 3],      # map
>                               fail,        # colours1
>                               fail);       # colours2
[  ]
gap> D := DigraphAddAllLoops(Digraph([[2, 3], [1], [1], [], []]));;
gap> EmbeddingsDigraphsRepresentatives(NullDigraph(2), D);
[ Transformation( [ 1, 4, 3, 4 ] ), Transformation( [ 2, 3, 3 ] ), 
  Transformation( [ 2, 4, 3, 4 ] ), Transformation( [ 4, 1, 3, 4 ] ), 
  Transformation( [ 4, 2, 3, 4 ] ), Transformation( [ 4, 5, 3, 4, 5 ] ) ]
gap> D := Digraph([[2, 3], [1, 2], [1, 3]]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               1,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> D := Digraph([[2, 3], [1, 2], [1, 3]]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               2,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> D := Digraph([[2, 3], [1], [1]]);;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               2,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               [1, 2, 3],   # colours1
>                               [1, 3, 2]);  # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               2,           # injective
>                               [1, 2, 3],   # image
>                               [],          # map
>                               [1, 2, 3],   # colours1
>                               [1, 3, 2]);  # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               2,           # injective
>                               [1, 2, 3],   # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
[ Transformation( [ 1, 3, 2 ] ) ]
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               2,           # injective
>                               [1, 2, 3],   # image
>                               [3, 3],      # map
>                               fail,        # colours1
>                               fail);       # colours2
[  ]
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,        # hook
>                               [],          # user_param
>                               1,           # limit
>                               fail,        # hint
>                               2,           # injective
>                               [2, 3],      # image
>                               [, 3],       # map
>                               fail,        # colours1
>                               fail);       # colours2
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
[  ]
gap> D := DigraphAddAllLoops(Digraph([[2, 3], [1], [1], [], [5]]));;
gap> EmbeddingsDigraphsRepresentatives(NullDigraph(2), D);
[ Transformation( [ 1, 4, 3, 4 ] ), Transformation( [ 2, 3, 3 ] ), 
  Transformation( [ 2, 4, 3, 4 ] ), Transformation( [ 4, 1, 3, 4 ] ), 
  Transformation( [ 4, 2, 3, 4 ] ), Transformation( [ 4, 5, 3, 4, 5 ] ) ]
gap> EmbeddingsDigraphsRepresentatives(CompleteDigraph(2), D);
[ IdentityTransformation, Transformation( [ 2, 1 ] ) ]
gap> MonomorphismsDigraphsRepresentatives(CompleteDigraph(2), D);
[ IdentityTransformation, Transformation( [ 2, 1 ] ) ]
gap> D := Digraph([[3], [8], [9], [11], [2, 7, 8, 18], [18, 20],
>                  [1], [], [], [], [4, 8, 16], [13, 19], [], [4], [15],
>                  [1, 4, 6, 8], [], [7, 12], [], [8]]);;
gap> EmbeddingsDigraphsRepresentatives(CompleteDigraph(2), D);
[ Transformation( [ 4, 11, 3, 4, 5, 6, 7, 8, 9, 10, 11 ] ), 
  Transformation( [ 11, 4, 3, 4, 5, 6, 7, 8, 9, 10, 11 ] ) ]
gap> EmbeddingsDigraphs(CompleteDigraph(2), D);
[ Transformation( [ 4, 11, 3, 4, 5, 6, 7, 8, 9, 10, 11 ] ), 
  Transformation( [ 4, 11, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 19, 14, 15, 16,
      17, 18, 13 ] ), Transformation( [ 4, 11, 3, 4, 5, 6, 7, 8, 9, 17, 11,
      12, 13, 14, 15, 16, 10 ] ), 
  Transformation( [ 4, 11, 3, 4, 5, 6, 7, 8, 9, 17, 11, 12, 19, 14, 15, 16,
      10, 18, 13 ] ), Transformation( [ 11, 4, 3, 4, 5, 6, 7, 8, 9, 10, 11 ] )
    , Transformation( [ 11, 4, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 19, 14, 15,
      16, 17, 18, 13 ] ), Transformation( [ 11, 4, 3, 4, 5, 6, 7, 8, 9, 17,
      11, 12, 13, 14, 15, 16, 10 ] ), 
  Transformation( [ 11, 4, 3, 4, 5, 6, 7, 8, 9, 17, 11, 12, 19, 14, 15, 16,
      10, 18, 13 ] ) ]
gap> D := DigraphAddAllLoops(Digraph([[2, 3], [1], [1], [], [5]]));;
gap> HomomorphismDigraphsFinder(D,
>                               D,
>                               fail,      # hook
>                               [],        # user_param
>                               1,         # limit
>                               fail,      # hint
>                               2,         # injective
>                               [1 .. 5],  # image
>                               [1,, 4],   # map
>                               fail,      # colours1
>                               fail);     # colours2
[  ]

# Another test from PJC
gap> parts := Filtered(PartitionsSet([1 .. 9], 3),
>                      x -> ForAll(x, y -> Length(y) = 3));;
gap> D := Digraph(parts, {x, y} -> ForAll(x, z -> not z in y));
<immutable digraph with 280 vertices, 70560 edges>
gap> t := DigraphHomomorphism(CompleteDigraph(25), D);
<transformation on 273 pts with rank 251>
gap> IsDigraphHomomorphism(CompleteDigraph(25), D, t);
true
gap> tt := HomomorphismDigraphsFinder(CompleteDigraph(26),
>                                     D,
>                                     fail,       # hook
>                                     [],         # user_param
>                                     1,          # max_results
>                                     fail,
>                                     0,
>                                     [1 .. 280],
>                                     [12, 23, 32, 44, 52, 1, 77, 85, 96, 103, 114,
> 125, 136, 145, 157, 170, 262, 204, 215, 233, 246, 255, 193, 273],
>                                     fail,
>                                     fail)[1];
<transformation on 273 pts with rank 250>

# GAP hook function
gap> found := 0;;
gap> hook := function(fnd, t) found := found + 1; end;;
gap> D := DigraphSymmetricClosure(Digraph([[2, 3], [], [], [5], [], []]));;
gap> HomomorphismDigraphsFinder(D, D, hook, true, infinity, fail, 0,
> [1 .. 6], [], fail, fail);
true
gap> found;
100

# GAP hook function with no trivial return value
gap> found := 0;;
gap> hook := function(fnd, t) found := found + 1;
>  if found = 12 then return true; fi; end;;
gap> D := DigraphSymmetricClosure(Digraph([[2, 3], [], [], [5], [], []]));;
gap> HomomorphismDigraphsFinder(D, D, hook, true, infinity, fail, 0,
> [1 .. 6], [], fail, fail);
true
gap> found;
12

# Partial map completely specifies homomorphism for symmetric digraphs
gap> D := DigraphDisjointUnion(CycleDigraph(3), CycleDigraph(5));;
gap> D := DigraphSymmetricClosure(D);;
gap> t := DigraphHomomorphism(DigraphSymmetricClosure(CycleDigraph(5)), D);
Transformation( [ 1, 2, 3, 1, 2 ] )
gap> t := HomomorphismDigraphsFinder(DigraphSymmetricClosure(CycleDigraph(5)),
>                                    D,
>                                    fail,       # hook
>                                    [],         # user_param
>                                    1,          # max_results
>                                    fail,
>                                    0,
>                                    [1 .. 8],
>                                    ListTransformation(t, 5),
>                                    fail,
>                                    fail)[1];
Transformation( [ 1, 2, 3, 1, 2 ] )
gap> t := DigraphMonomorphism(DigraphSymmetricClosure(CycleDigraph(5)), D);
Transformation( [ 4, 5, 6, 7, 8, 6, 7, 8 ] )
gap> t := HomomorphismDigraphsFinder(DigraphSymmetricClosure(CycleDigraph(5)),
>                                    D,
>                                    fail,       # hook
>                                    [],         # user_param
>                                    1,          # max_results
>                                    fail,
>                                    1,
>                                    [1 .. 8],
>                                    ListTransformation(t, 5),
>                                    fail,
>                                    fail);
[ Transformation( [ 4, 5, 6, 7, 8, 6, 7, 8 ] ) ]
gap> t := DigraphEmbedding(DigraphSymmetricClosure(CycleDigraph(5)), D);
Transformation( [ 4, 5, 6, 7, 8, 6, 7, 8 ] )
gap> HomomorphismDigraphsFinder(DigraphSymmetricClosure(CycleDigraph(5)),
>                               D,
>                               fail,       # hook
>                               [],         # user_param
>                               1,          # max_results
>                               fail,
>                               2,
>                               [1 .. 8],
>                               ListTransformation(t, 5),
>                               fail,
>                               fail);
[ Transformation( [ 4, 5, 6, 7, 8, 6, 7, 8 ] ) ]
gap> t := HomomorphismDigraphsFinder(DigraphSymmetricClosure(CycleDigraph(5)),
>                                    D,
>                                    fail,       # hook
>                                    [],         # user_param
>                                    1,          # max_results
>                                    fail,
>                                    2,
>                                    [1 .. 8],
>                                    ListTransformation(t, 6),
>                                    fail,
>                                    fail);
Error, the 9th argument <partial_map> is too long, must be at most 5, found 6,
gap> t := HomomorphismDigraphsFinder(DigraphSymmetricClosure(CycleDigraph(5)),
>                                    D,
>                                    fail,       # hook
>                                    [],         # user_param
>                                    1,          # max_results
>                                    fail,
>                                    0,
>                                    [1 .. 8],
>                                    [1, 1, 1, 1],
>                                    fail,
>                                    fail);
[  ]
gap> t := HomomorphismDigraphsFinder(DigraphSymmetricClosure(CycleDigraph(5)),
>                                    D,
>                                    fail,       # hook
>                                    [],         # user_param
>                                    1,          # max_results
>                                    fail,
>                                    1,
>                                    [1 .. 8],
>                                    [1, 2, 3, 4],
>                                    fail,
>                                    fail);
[  ]
gap> t := HomomorphismDigraphsFinder(DigraphSymmetricClosure(CycleDigraph(5)),
>                                    D,
>                                    fail,       # hook
>                                    [],         # user_param
>                                    2,          # max_results
>                                    fail,
>                                    1,
>                                    [1 .. 8],
>                                    [1, 1, 1, 1],
>                                    fail,
>                                    fail);
[  ]
gap> t := HomomorphismDigraphsFinder(DigraphSymmetricClosure(CycleDigraph(5)),
>                                    D,
>                                    fail,       # hook
>                                    [],         # user_param
>                                    1,          # max_results
>                                    2,
>                                    0,
>                                    [1 .. 8],
>                                    [4, 5, 6, 7],
>                                    fail,
>                                    fail);
[  ]

# Partial map completely specifies homomorphism for digraphs
gap> D := DigraphDisjointUnion(CycleDigraph(3), CycleDigraph(5));;
gap> t := DigraphHomomorphism(CycleDigraph(5), D);
Transformation( [ 4, 5, 6, 7, 8, 6, 7, 8 ] )
gap> t := HomomorphismDigraphsFinder(CycleDigraph(5),
>                                    D,
>                                    fail,       # hook
>                                    [],         # user_param
>                                    1,          # max_results
>                                    fail,
>                                    0,
>                                    [1 .. 8],
>                                    ListTransformation(t, 5),
>                                    fail,
>                                    fail)[1];
Transformation( [ 4, 5, 6, 7, 8, 6, 7, 8 ] )
gap> t := DigraphMonomorphism(CycleDigraph(5), D);
Transformation( [ 4, 5, 6, 7, 8, 6, 7, 8 ] )
gap> t := HomomorphismDigraphsFinder(CycleDigraph(5),
>                                    D,
>                                    fail,       # hook
>                                    [],         # user_param
>                                    1,          # max_results
>                                    fail,
>                                    1,
>                                    [1 .. 8],
>                                    ListTransformation(t, 5),
>                                    fail,
>                                    fail);
[ Transformation( [ 4, 5, 6, 7, 8, 6, 7, 8 ] ) ]
gap> t := DigraphEmbedding(CycleDigraph(5), D);
Transformation( [ 4, 5, 6, 7, 8, 6, 7, 8 ] )
gap> HomomorphismDigraphsFinder(CycleDigraph(5),
>                               D,
>                               fail,       # hook
>                               [],         # user_param
>                               1,          # max_results
>                               fail,
>                               2,
>                               [1 .. 8],
>                               ListTransformation(t, 5),
>                               fail,
>                               fail);
[ Transformation( [ 4, 5, 6, 7, 8, 6, 7, 8 ] ) ]
gap> HomomorphismDigraphsFinder(CycleDigraph(5),
>                               D,
>                               fail,       # hook
>                               [],         # user_param
>                               1,          # max_results
>                               fail,
>                               2,
>                               [1 .. 8],
>                               ListTransformation(t, 6),
>                               fail,
>                               fail);
Error, the 9th argument <partial_map> is too long, must be at most 5, found 6,
gap> D := DigraphDisjointUnion(CycleDigraph(3), CycleDigraph(5));;
gap> t := DigraphEmbedding(CycleDigraph(5), D);
Transformation( [ 4, 5, 6, 7, 8, 6, 7, 8 ] )
gap> HomomorphismDigraphsFinder(CycleDigraph(5),
>                               D,
>                               fail,       # hook
>                               [],         # user_param
>                               1,          # max_results
>                               fail,
>                               2,
>                               [1 .. 8],
>                               ListTransformation(t, 6),
>                               fail,
>                               fail);
Error, the 9th argument <partial_map> is too long, must be at most 5, found 6,
gap> HomomorphismDigraphsFinder(CycleDigraph(5),
>                               D,
>                               fail,       # hook
>                               [],         # user_param
>                               1,          # max_results
>                               fail,
>                               0,
>                               [1 .. 8],
>                               [1, 1, 1, 1],
>                               fail,
>                               fail);
[  ]
gap> HomomorphismDigraphsFinder(CycleDigraph(5),
>                               D,
>                               fail,       # hook
>                               [],         # user_param
>                               1,          # max_results
>                               fail,
>                               1,
>                               [1 .. 8],
>                               [1, 1, 1, 1],
>                               fail,
>                               fail);
[  ]
gap> HomomorphismDigraphsFinder(CycleDigraph(5),
>                               D,
>                               fail,       # hook
>                               [],         # user_param
>                               1,          # max_results
>                               fail,
>                               2,
>                               [1 .. 8],
>                               [1, 1, 1, 1],
>                               fail,
>                               fail);
[  ]
gap> HomomorphismDigraphsFinder(CycleDigraph(5),
>                               D,
>                               fail,       # hook
>                               [],         # user_param
>                               1,          # max_results
>                               2,
>                               0,
>                               [1 .. 8],
>                               [4, 5, 6, 7],
>                               fail,
>                               fail);
[  ]
gap> HomomorphismDigraphsFinder(CycleDigraph(5),
>                               D,
>                               fail,       # hook
>                               [],         # user_param
>                               1,          # max_results
>                               2,
>                               0,
>                               [1 .. 8],
>                               [4, 5, 6, 7],
>                               fail,
>                               fail,
>                               [1, 3, 4, 5, 2]);
[  ]
gap> HomomorphismDigraphsFinder(CycleDigraph(5),
>                               D,
>                               fail,       # hook
>                               [],         # user_param
>                               1,          # max_results
>                               fail,
>                               0,
>                               [1 .. 8],
>                               [4, 5, 6, 7],
>                               fail,
>                               fail,
>                               [1, 3, 4, 5, 2]);
[ Transformation( [ 4, 5, 6, 7, 8, 6, 7, 8 ] ) ]

# More arg/error checks
gap> HomomorphismDigraphsFinder(0);
Error, there must be 11, 12, or 13 arguments, found 1,
gap> DigraphHomomorphism(NullDigraph(1), NullDigraph(513));
IdentityTransformation
gap> HomomorphismDigraphsFinder(NullDigraph(1), NullDigraph(510), fail, [], 1,
> false, 0, 0, 0, 0, 0);
Error, the 6th argument <hint> must be an integer or fail, not boolean or fail\
,
gap> HomomorphismDigraphsFinder(NullDigraph(1), NullDigraph(510), fail, [], 1,
> fail, true, 0, 0, 0, 0);
Error, the 8th argument <image> must be a list or fail, not integer,
gap> HomomorphismDigraphsFinder(NullDigraph(1), NullDigraph(510), fail, [], 1,
> fail, false, 0, 0, 0, 0);
Error, the 8th argument <image> must be a list or fail, not integer,
gap> HomomorphismDigraphsFinder(NullDigraph(1), NullDigraph(510), fail, [], 1,
> fail, true, [1,, 3], 0, 0, 0);
Error, the 8th argument <image> must be a dense list,
gap> HomomorphismDigraphsFinder(NullDigraph(1), NullDigraph(510), fail, [], 1,
> fail, true, [1, 1, 3], 0, 0, 0);
Error, in the 8th argument <image> position 2 is a duplicate,
gap> HomomorphismDigraphsFinder(NullDigraph(1), NullDigraph(510), fail, [], 1,
> fail, true, [1, 2, 3], [5], 0, 0);
Error, in the 9th argument <partial_map> the value 5 in position 1 does not be\
long to the 7th argument <image>,
gap> HomomorphismDigraphsFinder(NullDigraph(1), NullDigraph(510), fail, [], 1,
> fail, true, [1, 2, 3], [1], true, 0);
Error, the 10th argument <colors1> must be a list or fail, not boolean or fail\
,
gap> HomomorphismDigraphsFinder(NullDigraph(1), NullDigraph(510), fail, [], 1,
> fail, true, [1, 2, 3], [1], fail, false);
Error, the 11th argument <colors2> must be a list or fail, not boolean or fail\
,
gap> HomomorphismDigraphsFinder(NullDigraph(1), NullDigraph(510), fail, [], 1,
> fail, true, [1, 2, 3], [1], fail, fail, true);
Error, the 12th or 13th argument <aut_grp> must be a permutation group or fail\
, not boolean or fail,
gap> HomomorphismDigraphsFinder(NullDigraph(10), NullDigraph(510), fail, [], 1,
> fail, true, [1, 2, 3], [1], fail, fail, [1]);
Error, the 12th argument <order> must be a list of length 10, not 1,
gap> HomomorphismDigraphsFinder(NullDigraph(1), NullDigraph(510), fail, [], 1,
> fail, true, [1, 2, 3], [1], fail, fail, "1");
Error, the 12th argument <order> must consist of integers, but found list (str\
ing) in position 1,
gap> HomomorphismDigraphsFinder(NullDigraph(2), NullDigraph(510), fail, [], 1,
> fail, true, [1, 2, 3], [1], fail, fail, [, 1]);
Error, the 12th argument <order> must be a dense list, but position 1 is not b\
ound,
gap> HomomorphismDigraphsFinder(NullDigraph(3), NullDigraph(510), fail, [], 1,
> fail, true, [1, 2, 3], [1], fail, fail, [1, 3, 5]);
Error, the 12th argument <order> must consist of integers, in the range [1, 3]\
 but found 5,
gap> HomomorphismDigraphsFinder(NullDigraph(3), NullDigraph(510), fail, [], 1,
> fail, true, [1, 2, 3], [1], fail, fail, [1, 1, 3]);
Error, the 12th argument <order> must be duplicate-free, but the value 1 in po\
sition 2 is a duplicate,
gap> HomomorphismDigraphsFinder(NullDigraph(3), NullDigraph(510), fail, [], 1,
> fail, true, [1, 2, 3], [1], fail, fail, 12);
Error, the 12th or 13th argument <aut_grp> must be a permutation group or fail\
, not integer,
gap> HomomorphismDigraphsFinder(NullDigraph(3), NullDigraph(510), fail, [], 1,
> fail, true, [1, 2, 3], [1], fail, fail, true);
Error, the 12th or 13th argument <aut_grp> must be a permutation group or fail\
, not boolean or fail,
gap> HomomorphismDigraphsFinder(NullDigraph(3), NullDigraph(510), fail, [], 1,
> fail, true, [1, 2, 3], [1], fail, fail,
> Group(MappingPermListList([1 .. 1000], [5 .. 1004])));
Error, expected group of automorphisms, but found a non-automorphism in positi\
on 1 of the group generators,
gap> HomomorphismDigraphsFinder(NullDigraph(3), NullDigraph(510), fail, [], 1,
> fail, true, [1, 2, 3], [1], fail, fail,
> Group((1, 2), MappingPermListList([1 .. 1000], [5 .. 1004])));
Error, expected group of automorphisms, but found a non-automorphism in positi\
on 2 of the group generators,
gap> HomomorphismDigraphsFinder(NullDigraph(3), ChainDigraph(3), fail, [], 1,
> fail, true, [1, 2, 3], [1], fail, fail, Group((1, 2, 3)));
Error, expected group of automorphisms, but found a non-automorphism in positi\
on 1 of the group generators,
gap> HomomorphismDigraphsFinder(NullDigraph(3), NullDigraph(3), fail, [], 1,
> fail, true, [1, 2, 3], [1], [1, 1, 1], [1, 2, 3], Group((1, 2, 3)));
Error, expected group of automorphisms, but found a non-automorphism in positi\
on 1 of the group generators,
gap> HomomorphismDigraphsFinder(NullDigraph(3), NullDigraph(3), fail, [], 1,
> fail, true, [1, 2, 3], [1], fail, fail,
> Group((1, 2, 3), (1, 2), (1, 3)));
Error, expected at most 2 generators in the 12th or 13th argument but got 3,

#
gap> D1 := DigraphSymmetricClosure(Digraph([[2], [3], []]));;
gap> D2 := CompleteDigraph(3);;
gap> HomomorphismDigraphsFinder(D1, D2, fail, [], 1,
> fail, 2, [1, 2, 3], [1, 2, 3], fail, fail);
[  ]
gap> HomomorphismDigraphsFinder(D1, D2, fail, [], 1,
> fail, 2, [1, 2, 3], fail, fail, fail);
[  ]

# DigraphSmallestLastOrder
gap> DigraphSmallestLastOrder(D1);
[ 3, 2, 1 ]
gap> DigraphSmallestLastOrder(D2);
[ 3, 2, 1 ]

# Issue 222
gap> D1 := DigraphFromGraph6String("E}hO");
<immutable symmetric digraph with 6 vertices, 18 edges>
gap> D2 := DigraphFromGraph6String("E}h_");
<immutable symmetric digraph with 6 vertices, 18 edges>
gap> mono := MonomorphismsDigraphs(D1, D2);
[  ]

# Issue 251
gap> gr := CompleteDigraph(5);
<immutable complete digraph with 5 vertices>
gap> GeneratorsOfEndomorphismMonoid(gr);
[ Transformation( [ 2, 3, 4, 5, 1 ] ), Transformation( [ 2, 1 ] ), 
  IdentityTransformation ]
gap> gr := CompleteDigraph(5);
<immutable complete digraph with 5 vertices>
gap> GeneratorsOfEndomorphismMonoid(gr, [1, 1, 1, 2, 3]);
[ Transformation( [ 1, 3, 2 ] ), Transformation( [ 2, 1 ] ), 
  IdentityTransformation ]
gap> GeneratorsOfEndomorphismMonoid(gr);
[ Transformation( [ 2, 3, 4, 5, 1 ] ), Transformation( [ 2, 1 ] ), 
  IdentityTransformation ]

# IsHomomorphism etc. for vertex-coloured digraphs
gap> gr1 := Digraph([[], []]);
<immutable empty digraph with 2 vertices>
gap> gr2 := Digraph([[], [1]]);
<immutable digraph with 2 vertices, 1 edge>
gap> IsDigraphAutomorphism(gr1, Transformation([1, 2]));
true
gap> IsDigraphAutomorphism(gr1, Transformation([1, 2]), [1, 2]);
true
gap> IsDigraphAutomorphism(gr2, Transformation([1, 2]), [1, 1]);
true
gap> IsDigraphHomomorphism(gr1, gr2, Transformation([1, 2]));
true
gap> IsDigraphHomomorphism(gr1, gr2, Transformation([1, 2]), [1, 2], [1, 1]);
false
gap> IsDigraphHomomorphism(gr1, gr2, Transformation([1, 2]), [1, 1], [1, 1]);
true
gap> IsDigraphHomomorphism(gr1, gr2, Transformation([1, 2]), [1, 1], [1, 2]);
false
gap> gr1 := Digraph([[], []]);
<immutable empty digraph with 2 vertices>
gap> gr1 := ChainDigraph(3);
<immutable chain digraph with 3 vertices>
gap> gr2 := ChainDigraph(6);
<immutable chain digraph with 6 vertices>
gap> IsDigraphHomomorphism(gr1, gr2, Transformation([1, 2, 3]),
> [1 .. 3], [1 .. 6]);
true
gap> IsDigraphHomomorphism(gr1, gr2, Transformation([1, 2, 3]),
> [1 .. 3], [1, 1, 2, 3, 4, 5]);
false
gap> IsDigraphHomomorphism(gr1, gr2, Transformation([1, 2, 3]),
> [2, 2, 1], [2, 2, 1, 3, 4, 5]);
true
gap> IsDigraphHomomorphism(gr1, gr2, Transformation([1, 2, 3]),
> [2, 2, 1], [1, 1, 2, 3, 4, 5]);
false
gap> IsDigraphAutomorphism(gr1, Transformation([3, 2, 1]), [1, 2, 3]);
false
gap> gr1 := CycleDigraph(6);
<immutable cycle digraph with 6 vertices>
gap> x := (1, 2, 3, 4, 5, 6);
(1,2,3,4,5,6)
gap> t := AsTransformation(x);
Transformation( [ 2, 3, 4, 5, 6, 1 ] )
gap> IsDigraphAutomorphism(gr1, x, [1 .. 6]);
false
gap> IsDigraphAutomorphism(gr1, x, [1, 1, 2, 2, 3, 3]);
false
gap> IsDigraphAutomorphism(gr1, x, [1, 1, 1, 1, 1, 1]);
true
gap> IsDigraphAutomorphism(gr1, x, [1, 1, 2, 2, 3, 3]);
false
gap> IsDigraphAutomorphism(gr1, x ^ 2, [1, 1, 2, 2, 3, 3]);
false
gap> IsDigraphAutomorphism(gr1, x ^ 2, [1, 2, 2, 3, 4, 4]);
false
gap> IsDigraphAutomorphism(gr1, x ^ 2, [1, 1, 1, 1, 1, 1]);
true
gap> IsDigraphAutomorphism(gr1, x ^ 3, [1, 2, 2, 3, 4, 4]);
false
gap> IsDigraphAutomorphism(gr1, x ^ 3, [1, 1, 1, 1, 1, 1]);
true
gap> IsDigraphAutomorphism(gr1, t, [1 .. 6]);
false
gap> IsDigraphAutomorphism(gr1, t, [1, 1, 2, 2, 3, 3]);
false
gap> IsDigraphAutomorphism(gr1, t ^ 2, [1, 1, 2, 2, 3, 3]);
false
gap> IsDigraphAutomorphism(gr1, t ^ 2, [1, 2, 2, 3, 4, 4]);
false
gap> IsDigraphAutomorphism(gr1, t ^ 3, [1, 2, 2, 3, 4, 4]);
false
gap> gr1 := DigraphFromDigraph6String("&D~~~~_");
<immutable digraph with 5 vertices, 25 edges>
gap> ForAll(AutomorphismGroup(gr1),
>           x -> x = () or not IsDigraphAutomorphism(gr1, x, [1 .. 5]));
true
gap> ForAll(AutomorphismGroup(gr1),
>           x -> IsDigraphAutomorphism(gr1, x, [1, 1, 1, 1, 1]));
true

# IsDigraphEndomorphism, for vertex-coloured digraphs
gap> gr1 := DigraphTransitiveClosure(CompleteDigraph(2));
<immutable transitive digraph with 2 vertices, 4 edges>
gap> IsDigraphEndomorphism(gr1, (1, 2), [1, 2]);
false
gap> IsDigraphEndomorphism(gr1, (1, 2), [1, 1]);
true
gap> IsDigraphEndomorphism(gr1, Transformation([1, 1]), [1, 2]);
false
gap> IsDigraphEndomorphism(gr1, Transformation([1, 1]), [1, 1]);
true
gap> ForAll(GeneratorsOfEndomorphismMonoid(gr1),
>           x -> IsDigraphEndomorphism(gr1, x, [1, 1]));
true
gap> gr2 := Digraph([[3, 4], [1, 3], [4], [1, 2, 3, 5], [2]]);
<immutable digraph with 5 vertices, 10 edges>
gap> ForAll(GeneratorsOfEndomorphismMonoid(gr2),
>           x -> IsDigraphEndomorphism(gr2, x, [1, 1, 1, 1, 1]));
true
gap> gr1 := DigraphFromDigraph6String("&D~~~~_");
<immutable digraph with 5 vertices, 25 edges>
gap> ForAll(GeneratorsOfEndomorphismMonoid(gr1),
>           x -> IsDigraphEndomorphism(gr1, x, [1, 1, 1, 1, 1]));
true
gap> ForAll(AutomorphismGroup(gr1),
>           x -> IsDigraphEndomorphism(gr1, x, [1, 1, 1, 1, 1]));
true

# IsDigraphEpimorphism, for vertex-coloured digraphs
gap> src := Digraph([[1], [1, 2], [1, 3]]);
<immutable digraph with 3 vertices, 5 edges>
gap> ran := Digraph([[1], [1, 2]]);
<immutable digraph with 2 vertices, 3 edges>
gap> IsDigraphEpimorphism(src, ran, Transformation([1, 2, 2]),
> [1, 2, 2], [1, 2]);
true
gap> IsDigraphEpimorphism(src, ran, Transformation([1, 2, 2]),
> [1, 2, 3], [1, 2]);
false
gap> IsDigraphEpimorphism(src, src, Transformation([1, 2, 3]),
>                         [1, 1, 2], [1, 1, 2]);
true
gap> IsDigraphEpimorphism(src, src, Transformation([1, 2, 3]),
>                         [1, 2, 3], [1, 1, 2]);
false
gap> IsDigraphEpimorphism(src, src, (), [1, 2, 2], [1, 2, 2]);
true
gap> IsDigraphEpimorphism(src, src, (2, 3), [1, 2, 3], [2, 3, 1]);
false
gap> IsDigraphEpimorphism(src, src, (2, 3), [2, 1, 3], [2, 3, 1]);
true

# IsDigraphMonomorphism, for vertex-coloured digraphs
gap> src := Digraph([[1], [1, 2], [1, 3]]);
<immutable digraph with 3 vertices, 5 edges>
gap> ran := Digraph([[1], [1, 2]]);
<immutable digraph with 2 vertices, 3 edges>
gap> IsDigraphMonomorphism(src, src, Transformation([1, 3, 2]),
>                          [2, 3, 1], [2, 1, 3]);
true
gap> IsDigraphMonomorphism(src, src, Transformation([1, 3, 2]),
>                          [2, 3, 1], [2, 3, 1]);
false
gap> IsDigraphMonomorphism(src, src, Transformation([1, 2, 3]),
>                          [2, 1, 1], [1, 2, 2]);
false
gap> IsDigraphMonomorphism(src, src, Transformation([1, 2, 3]),
>                          [1, 2, 2], [1, 2, 2]);
true
gap> IsDigraphMonomorphism(ran, src, Transformation([1, 2]),
>                          [2, 1], [1, 2, 1]);
false
gap> IsDigraphMonomorphism(ran, src, Transformation([1, 2]),
>                          [2, 1], [1, 1, 1]);
false
gap> IsDigraphMonomorphism(ran, src, Transformation([1, 2]),
>                          [1, 1], [1, 1, 2]);
true
gap> IsDigraphMonomorphism(src, src, (), [1, 2, 2], [1, 2, 2]);
true
gap> IsDigraphMonomorphism(src, src, (), [1, 1, 2], [1, 2, 2]);
false
gap> IsDigraphMonomorphism(ran, src, (), [1, 1], [1, 1, 2]);
true
gap> IsDigraphMonomorphism(ran, src, (), [1, 1], [2, 2, 1]);
false
gap> IsDigraphMonomorphism(ran, src, (), [1, 2], [1, 2, 1]);
true

# IsDigraphEmbedding, for vertex-coloured digraphs
gap> src := Digraph([[1], [1, 2], [1, 3]]);
<immutable digraph with 3 vertices, 5 edges>
gap> ran := Digraph([[1], [1, 2]]);
<immutable digraph with 2 vertices, 3 edges>
gap> IsDigraphEmbedding(src, src, Transformation([1, 2, 3]),
>                       [1, 1, 1], [1, 1, 1]);
true
gap> IsDigraphEmbedding(src, src, Transformation([1, 2, 3]),
>                       [1, 1, 2], [1, 1, 2]);
true
gap> IsDigraphEmbedding(ran, src, Transformation([1, 2]));
true
gap> IsDigraphEmbedding(src, src, (), [1, 1, 1], [1, 1, 1]);
true
gap> IsDigraphEmbedding(src, src, (), [2, 1, 1], [1, 1, 1]);
false
gap> IsDigraphEmbedding(ran, src, (), [1, 1], [1, 1, 2]);
true
gap> IsDigraphEmbedding(ran, src, (), [2, 1], [1, 2, 2]);
false
gap> IsDigraphEmbedding(ran, src, (), [2, 1], [1, 1, 2]);
false

# MaximalCommSubdigraph and MinimalCommonSuperDigraph
gap> MaximalCommonSubdigraph(NullDigraph(0), CompleteDigraph(10));
[ <immutable empty digraph with 0 vertices>, IdentityTransformation, 
  IdentityTransformation ]
gap> MinimalCommonSuperdigraph(NullDigraph(0), CompleteDigraph(10));
[ <immutable digraph with 10 vertices, 90 edges>, IdentityTransformation, 
  IdentityTransformation ]
gap> MaximalCommonSubdigraph(PetersenGraph(), CompleteDigraph(10));
[ <immutable digraph with 2 vertices, 2 edges>, IdentityTransformation, 
  IdentityTransformation ]
gap> MinimalCommonSuperdigraph(PetersenGraph(), CompleteDigraph(10));
[ <immutable digraph with 18 vertices, 118 edges>, IdentityTransformation, 
  Transformation( [ 1, 2, 11, 12, 13, 14, 15, 16, 17, 18, 11, 12, 13, 14, 15,
      16, 17, 18 ] ) ]
gap> MaximalCommonSubdigraph(NullDigraph(10), CompleteDigraph(10));
[ <immutable empty digraph with 1 vertex>, IdentityTransformation, 
  IdentityTransformation ]
gap> MinimalCommonSuperdigraph(NullDigraph(10), CompleteDigraph(10));
[ <immutable digraph with 19 vertices, 90 edges>, IdentityTransformation, 
  Transformation( [ 1, 11, 12, 13, 14, 15, 16, 17, 18, 19, 11, 12, 13, 14, 15,
     16, 17, 18, 19 ] ) ]
gap> MaximalCommonSubdigraph(CompleteDigraph(100), CompleteDigraph(100));
[ <immutable digraph with 100 vertices, 9900 edges>, IdentityTransformation, 
  IdentityTransformation ]
gap> MinimalCommonSuperdigraph(CompleteDigraph(100), CompleteDigraph(100));
[ <immutable digraph with 100 vertices, 9900 edges>, IdentityTransformation, 
  IdentityTransformation ]
gap> MaximalCommonSubdigraph(PetersenGraph(),
> DigraphSymmetricClosure(CycleDigraph(5)));
[ <immutable digraph with 5 vertices, 10 edges>, IdentityTransformation, 
  IdentityTransformation ]
gap> MinimalCommonSuperdigraph(PetersenGraph(),
> DigraphSymmetricClosure(CycleDigraph(5)));
[ <immutable digraph with 10 vertices, 30 edges>, IdentityTransformation, 
  IdentityTransformation ]
gap> MaximalCommonSubdigraph(Digraph([[1, 1]]), Digraph([[1]]));
Error, the 1st argument (a digraph) must not satisfy IsMultiDigraph
gap> MinimalCommonSuperdigraph(Digraph([[1, 1]]), Digraph([[1]]));
Error, the 1st argument (a digraph) must not satisfy IsMultiDigraph

# LatticeDigraphEmbedding
gap> D := Digraph([[2], [3], [4], []]);
<immutable digraph with 4 vertices, 3 edges>
gap> G := Digraph([[], [1], [2], [3]]);
<immutable digraph with 4 vertices, 3 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 4 vertices, 10 edges>
gap> G := DigraphReflexiveTransitiveClosure(G);
<immutable preorder digraph with 4 vertices, 10 edges>
gap> LatticeDigraphEmbedding(D, G);
Transformation( [ 4, 3, 2, 1 ] )
gap> D := Digraph([[2], [3], [4], []]);
<immutable digraph with 4 vertices, 3 edges>
gap> G := Digraph([[2], [3], [4], [5], []]);
<immutable digraph with 5 vertices, 4 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 4 vertices, 10 edges>
gap> G := DigraphReflexiveTransitiveClosure(G);
<immutable preorder digraph with 5 vertices, 15 edges>
gap> LatticeDigraphEmbedding(G, D);
fail
gap> LatticeDigraphEmbedding(D, G);
IdentityTransformation
gap> D := Digraph([[2, 3, 5], [4, 6], [4, 7, 9], [8, 11], [6, 10], [11],
>   [8, 12], [14], [10, 13], [11, 12], [14], [14], [14], []]);
<immutable digraph with 14 vertices, 23 edges>
gap> N5 := Digraph([[2, 4], [3], [5], [5], []]);
<immutable digraph with 5 vertices, 5 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 14 vertices, 66 edges>
gap> N5 := DigraphReflexiveTransitiveClosure(N5);
<immutable preorder digraph with 5 vertices, 13 edges>
gap> LatticeDigraphEmbedding(N5, D);
Transformation( [ 1, 9, 10, 2, 11, 6, 7, 8, 9, 10, 11 ] )
gap> D := Digraph([[2], [3], [4], []]);
<immutable digraph with 4 vertices, 3 edges>
gap> G := Digraph([[2, 3], [4], [4], []]);
<immutable digraph with 4 vertices, 4 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 4 vertices, 10 edges>
gap> G := DigraphReflexiveTransitiveClosure(G);
<immutable preorder digraph with 4 vertices, 9 edges>
gap> LatticeDigraphEmbedding(D, G);
fail
gap> LatticeDigraphEmbedding(G, D);
fail
gap> N5 := Digraph([[2, 4], [3], [5], [5], []]);
<immutable digraph with 5 vertices, 5 edges>
gap> H := Digraph([[], [1], [1], [2], [3], [2, 3], [4, 5, 6]]);
<immutable digraph with 7 vertices, 9 edges>
gap> N5 := DigraphReflexiveTransitiveClosure(N5);
<immutable preorder digraph with 5 vertices, 13 edges>
gap> H := DigraphReflexiveTransitiveClosure(H);
<immutable preorder digraph with 7 vertices, 22 edges>
gap> LatticeDigraphEmbedding(N5, H);
Transformation( [ 7, 5, 3, 4, 1, 6, 7 ] )
gap> D := Digraph([[2, 6], [3, 7], [4], [], [4], [5, 7], [4]]);
<immutable digraph with 7 vertices, 9 edges>
gap> G := DigraphRemoveVertex(D, 7);
<immutable digraph with 6 vertices, 6 edges>
gap> G := DigraphReflexiveTransitiveClosure(G);
<immutable preorder digraph with 6 vertices, 17 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 7 vertices, 22 edges>
gap> DigraphEmbedding(G, D);
IdentityTransformation
gap> LatticeDigraphEmbedding(G, D);
fail
gap> D := CycleDigraph(5);
<immutable cycle digraph with 5 vertices>
gap> G := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> LatticeDigraphEmbedding(D, G);
Error, the 1st argument (a digraph) must be a lattice digraph
gap> LatticeDigraphEmbedding(G, D);
Error, the 2nd argument (a digraph) must be a lattice digraph
gap> s := ".|}oGCAAB`?w[OL@@P?ga@@DO`SKTDEBW_kZGDbHGw]OdQqSodEEcgw{eTcSAXOnDBRa`SrFCdrLC\
> kWLEwCGz\\nFwHuO]Oqbko{bdgS\\@CcQsbyMg_QHzyEedRiYy@ChkHdAhVBMpRquK^UrSYu[cVKIi\
> \\]oaGTkdCmXrsj@fPRKUbUq_VJzQ`aqZptI|fUTKejeujYLvLpWu[Mf^";
".|}oGCAAB`?w[OL@@P?ga@@DO`SKTDEBW_kZGDbHGw]OdQqSodEEcgw{eTcSAXOnDBRa`SrFCdrLC\
kWLEwCGz\\nFwHuO]Oqbko{bdgS\\@CcQsbyMg_QHzyEedRiYy@ChkHdAhVBMpRquK^UrSYu[cVKIi\
\\]oaGTkdCmXrsj@fPRKUbUq_VJzQ`aqZptI|fUTKejeujYLvLpWu[Mf^"
gap> G := DigraphFromDiSparse6String(s);
<immutable digraph with 61 vertices, 176 edges>
gap> G := DigraphReflexiveTransitiveClosure(G);
<immutable preorder digraph with 61 vertices, 660 edges>
gap> D := DigraphFromDiSparse6String(".DsGEA_QM@Gs");
<immutable digraph with 5 vertices, 14 edges>
gap> f := LatticeDigraphEmbedding(D, G);
Transformation( [ 1, 3, 2, 9, 10, 6, 7, 8, 9, 10 ] )
gap> f := IsLatticeEmbedding(D, G, f);
true
gap> D := DigraphFromDiSparse6String(".F{GE@I@M@HGCbU@GsTn");
<immutable digraph with 7 vertices, 25 edges>
gap> G := DigraphFromDiSparse6String(".|}oGCI@@AO_cKLD__gWeIECpp?gV?_bWOuGLcb`{AAQ`Cg`I\
> IRIpa`UQRIRQSweXgDRLIESMTRc[\m\\NSrc_k]OQb@t@NIEYH_sbbBqCu[egHgW|LXMHjXxOilGCyiybSigyTO\
> hddaxaW^Ogd{S[OjEbZEUPQkXA\\OpoitbHhIGhtMHGkUlhaxesZTrYLJ^TjTrfGnXKvN@iv[Mf^");
<immutable digraph with 61 vertices, 176 edges>
gap> G := DigraphReflexiveTransitiveClosure(G);
<immutable preorder digraph with 61 vertices, 660 edges>
gap> f := LatticeDigraphEmbedding(D, G);
Transformation( [ 1, 3, 4, 10, 8, 11, 13, 8, 9, 10, 11, 12, 13 ] )
gap> IsLatticeEmbedding(D, G, f);
true
gap> D := DigraphFromDiSparse6String(".Ww__`aB_`DdeFaFbEcGHIdfKkhLM`obOeKOgLPRcPQiMQRj\
> NSTU");
<immutable digraph with 24 vertices, 49 edges>
gap> G := DigraphFromDiSparse6String(".Yy___bb`BdEaC_`HcDH`aKeKcEfIJNgLMN_dQkQfMRSaHQgJ\
> RUiLSUoPTVW");
<immutable digraph with 26 vertices, 57 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 24 vertices, 148 edges>
gap> G := DigraphReflexiveTransitiveClosure(G);
<immutable preorder digraph with 26 vertices, 162 edges>
gap> LatticeDigraphEmbedding(D, G);
fail

# IsLatticeHomomorphism (for transformations)
gap> D := DigraphFromDigraph6String("&G~tSrCO{D?oC");
<immutable digraph with 8 vertices, 27 edges>
gap> G := DigraphFromDigraph6String("&J~}|SggsO__r?a?{?g?o?_");
<immutable digraph with 11 vertices, 43 edges>
gap> f := LatticeDigraphEmbedding(D, G);
Transformation( [ 1, 8, 6, 10, 2, 9, 7, 11, 9, 10, 11 ] )
gap> IsLatticeHomomorphism(D, G, f);
true
gap> IsLatticeHomomorphism(G, D, f);
false
gap> G := Digraph([[2, 4], [3, 7], [6], [5, 7], [6], [], [6]]);
<immutable digraph with 7 vertices, 9 edges>
gap> D := DigraphRemoveVertex(G, 7);
<immutable digraph with 6 vertices, 6 edges>
gap> G := DigraphReflexiveTransitiveClosure(G);
<immutable preorder digraph with 7 vertices, 22 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 6 vertices, 17 edges>
gap> IsDigraphEmbedding(D, G, IdentityTransformation);
true
gap> IsLatticeHomomorphism(D, G, IdentityTransformation);
false
gap> D := CycleDigraph(3);
<immutable cycle digraph with 3 vertices>
gap> G := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>
gap> IsLatticeHomomorphism(D, G, IdentityTransformation);
Error, the 1st argument (a digraph) must be a lattice digraph
gap> IsLatticeHomomorphism(G, D, IdentityTransformation);
Error, the 2nd argument (a digraph) must be a lattice digraph

# IsLatticeHomomorphism (for permutations)
gap> D := Digraph([[2, 3], [4], [4], []]);
<immutable digraph with 4 vertices, 4 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 4 vertices, 9 edges>
gap> IsLatticeHomomorphism(D, D, (2, 3));
true
gap> IsLatticeHomomorphism(D, D, (1, 2, 3, 4, 5));
false
gap> IsLatticeHomomorphism(D, D, (1, 4));
false

# IsLatticeEndomorphism (for transformations)
gap> D := Digraph([[2, 3], [4], [4], []]);
<immutable digraph with 4 vertices, 4 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 4 vertices, 9 edges>
gap> f := Transformation([1, 3, 2, 4]);
Transformation( [ 1, 3, 2 ] )
gap> IsLatticeEndomorphism(D, f);
true

# IsLatticeEndomorphism (for permutations)
gap> IsLatticeEndomorphism(D, (2, 3));
true
gap> IsLatticeEndomorphism(D, (5, 6));
false

# IsLatticeEmbedding and IsLatticeMonomorphism (for transformations)
gap> D := Digraph([[2, 3], [4], [4], []]);
<immutable digraph with 4 vertices, 4 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 4 vertices, 9 edges>
gap> G := Digraph([[2, 3], [4], [4], [5], []]);
<immutable digraph with 5 vertices, 5 edges>
gap> G := DigraphReflexiveTransitiveClosure(G);
<immutable preorder digraph with 5 vertices, 14 edges>
gap> IsLatticeEmbedding(D, G, IdentityTransformation);
true
gap> IsLatticeMonomorphism(D, G, IdentityTransformation);
true
gap> f := Transformation([1, 1, 1, 1]);
Transformation( [ 1, 1, 1, 1 ] )
gap> IsLatticeEmbedding(D, G, f);
false

# IsLatticeEmbedding and IsLatticeMonomorphism (for permutations)
gap> D := Digraph([[2, 3], [4], [4], []]);
<immutable digraph with 4 vertices, 4 edges>
gap> G := Digraph([[2, 3], [4], [4], [5], []]);
<immutable digraph with 5 vertices, 5 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 4 vertices, 9 edges>
gap> G := DigraphReflexiveTransitiveClosure(G);
<immutable preorder digraph with 5 vertices, 14 edges>
gap> IsLatticeEmbedding(D, G, (2, 3));
true
gap> IsLatticeEmbedding(D, G, ());
true
gap> IsLatticeEmbedding(D, G, (1, 2, 3));
false
gap> IsLatticeMonomorphism(D, G, ());
true

# IsLatticeEpimorphism (for transformations)
gap> D := Digraph([[2, 3], [4], [4], []]);
<immutable digraph with 4 vertices, 4 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 4 vertices, 9 edges>
gap> G := Digraph([[2, 3], [4], [4], [5], []]);
<immutable digraph with 5 vertices, 5 edges>
gap> G := DigraphReflexiveTransitiveClosure(G);
<immutable preorder digraph with 5 vertices, 14 edges>
gap> f := Transformation([1, 2, 3, 4, 4]);
Transformation( [ 1, 2, 3, 4, 4 ] )
gap> IsLatticeEpimorphism(G, D, f);
true
gap> IsLatticeEpimorphism(D, G, f);
false

# IsLatticeEpimorphism (for permutations)
gap> D := Digraph([[2, 3], [4], [4], []]);
<immutable digraph with 4 vertices, 4 edges>
gap> D := DigraphReflexiveTransitiveClosure(D);
<immutable preorder digraph with 4 vertices, 9 edges>
gap> G := Digraph([[2, 3], [4], [4], [5], []]);
<immutable digraph with 5 vertices, 5 edges>
gap> G := DigraphReflexiveTransitiveClosure(G);
<immutable preorder digraph with 5 vertices, 14 edges>
gap> IsLatticeEpimorphism(D, G, (2, 3));
false
gap> IsLatticeEpimorphism(G, D, (2, 3));
false
gap> IsLatticeEpimorphism(D, D, (2, 3));
true

# SubdigraphsMonomorphisms
gap> SubdigraphsMonomorphisms(CompleteBipartiteDigraph(2, 2),
> CompleteDigraph(4));
[ Transformation( [ 1, 3, 2 ] ), Transformation( [ 2, 3, 1 ] ), 
  Transformation( [ 3, 4, 2, 1 ] ) ]
gap> D := DigraphFromGraph6String("D^{");
<immutable symmetric digraph with 5 vertices, 18 edges>
gap> SubdigraphsMonomorphisms(CompleteDigraph(4), D);
[ Transformation( [ 1, 3, 4, 5, 5 ] ), Transformation( [ 2, 3, 4, 5, 5 ] ) ]
gap> Length(SubdigraphsMonomorphisms(CompleteDigraph(4), CompleteDigraph(12)));
495
gap> D := DigraphFromGraph6String("K^vMMF@oM?{@");
<immutable symmetric digraph with 12 vertices, 60 edges>
gap> Length(SubdigraphsMonomorphisms(CompleteMultipartiteDigraph([2, 5]), D));
252
gap> D := DigraphFromGraph6String("O^vMMF@oM?w@o@o?w?N?@");
<immutable symmetric digraph with 16 vertices, 84 edges>
gap> Length(SubdigraphsMonomorphisms(CompleteMultipartiteDigraph([2, 7]), D));
3432

#
gap> H := DigraphFromGraph6String("F~CWw");
<immutable symmetric digraph with 7 vertices, 24 edges>
gap> G := DigraphFromGraph6String("G@p}|{");
<immutable symmetric digraph with 8 vertices, 36 edges>
gap> ForAll(MonomorphismsDigraphs(H, G), x -> IsDigraphMonomorphism(H, G, x));
true
gap> H := NullDigraph(3);
<immutable empty digraph with 3 vertices>
gap> G := NullDigraph(510);
<immutable empty digraph with 510 vertices>
gap> p := MappingPermListList([1 .. 1000], [5 .. 1004]);;
gap> IsDigraphAutomorphism(G, p);
false
gap> HomomorphismDigraphsFinder(NullDigraph(3), NullDigraph(510), fail, [], 1,
> fail, true, [1, 2, 3], [1], fail, fail,
> Group(MappingPermListList([1 .. 1000], [5 .. 1004])));
Error, expected group of automorphisms, but found a non-automorphism in positi\
on 1 of the group generators,
gap> HomomorphismDigraphsFinder(NullDigraph(3), NullDigraph(510), fail, [], 1,
> fail, true, [1, 2, 3], [1], fail, fail,
> Group((511, 512)));
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
[ IdentityTransformation ]

# Issue 697
gap> H := DigraphFromGraph6String("F~CWw");
<immutable symmetric digraph with 7 vertices, 24 edges>
gap> G := DigraphFromGraph6String("G@p}|{");
<immutable symmetric digraph with 8 vertices, 36 edges>
gap> p := PermList(DigraphWelshPowellOrder(H)) ^ -1;
(1,2,3,4)
gap> H := OnDigraphs(H, p);
<immutable digraph with 7 vertices, 24 edges>
gap> # Reorder H to remove the ordering from the equation

# no partial map, no group
gap> HomomorphismDigraphsFinder(H,
> G,                      # range
> fail,                   # hook
> [],                     # user_param
> 1,                      # max_results
> 7,                      # hint (i.e. rank)
> true,                   # injective
> [1, 3, 4, 5, 6, 7, 8],  # image
> [],                     # partial_map
> fail,                   # colors1
> fail);
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
[  ]

# With partial map, no hint
gap> HomomorphismDigraphsFinder(H,
> G,                      # range
> fail,                   # hook
> [],                     # user_param
> 1,                      # max_results
> fail,                   # hint (i.e. rank)
> true,                   # injective
> [1, 3, 4, 5, 6, 7, 8],  # image
> [8],                     # partial_map
> fail,                   # colors1
> fail);
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
[ Transformation( [ 8, 1, 5, 7, 3, 4, 6, 8 ] ) ]

# With group, no hint
gap> HomomorphismDigraphsFinder(H,
> G,                      # range
> fail,                   # hook
> [],                     # user_param
> 1,                      # max_results
> fail,                   # hint (i.e. rank)
> true,                   # injective
> [1, 3, 4, 5, 6, 7, 8],
> [],                     # partial_map
> fail,                   # colors1
> fail,
> [1 .. 7],
> Group(()));
[ Transformation( [ 8, 1, 5, 7, 3, 4, 6, 8 ] ) ]

# With partial map, with hint
gap> HomomorphismDigraphsFinder(H,
> G,                      # range
> fail,                   # hook
> [],                     # user_param
> 1,                      # max_results
> 7,                      # hint (i.e. rank)
> true,                   # injective
> [1, 3, 4, 5, 6, 7, 8],  # image
> [8],                    # partial_map
> fail,                   # colors1
> fail);
#I  WARNING you are trying to find homomorphisms by specifying a subset of the vertices of the target digraph. This might lead to unexpected results! If this happens, try passing Group(()) as the last argument. Please see the documentation of HomomorphismDigraphsFinder for details.
[ Transformation( [ 8, 1, 5, 7, 3, 4, 6, 8 ] ) ]

# With group, with hint
gap> HomomorphismDigraphsFinder(H,
> G,                      # range
> fail,                   # hook
> [],                     # user_param
> 1,                      # max_results
> 7,                      # hint (i.e. rank)
> true,                   # injective
> [1, 3, 4, 5, 6, 7, 8],
> [],                     # partial_map
> fail,                   # colors1
> fail,
> DigraphWelshPowellOrder(H),
> Group(()));
[ Transformation( [ 8, 1, 5, 7, 3, 4, 6, 8 ] ) ]

#  DIGRAPHS_UnbindVariables
gap> Unbind(D);
gap> Unbind(D1);
gap> Unbind(D2);
gap> Unbind(DD);
gap> Unbind(G);
gap> Unbind(H);
gap> Unbind(N5);
gap> Unbind(edges);
gap> Unbind(epis);
gap> Unbind(f);
gap> Unbind(found);
gap> Unbind(func);
gap> Unbind(gens);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(homos);
gap> Unbind(hook);
gap> Unbind(mat);
gap> Unbind(mono);
gap> Unbind(monos);
gap> Unbind(parts);
gap> Unbind(ran);
gap> Unbind(s);
gap> Unbind(src);
gap> Unbind(t);
gap> Unbind(tt);
gap> Unbind(x);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/grahom.tst", 0);
