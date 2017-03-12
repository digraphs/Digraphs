#############################################################################
##
#W  standard/grahom.tst
#Y  Copyright (C) 2015-17                                   Wilf A. Wilson
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
gap> HomomorphismDigraphsFinder(0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
Error, Function Calls: number of arguments must be 11 (not 10)
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

#T# DigraphColouring and DigraphColouring: checking errors and robustness
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

#T# DigraphColouring
gap> DigraphColouring(EmptyDigraph(0));
IdentityTransformation
gap> DigraphColouring(Digraph([[1]]));
IdentityTransformation
gap> DigraphColouring(CycleDigraph(2));
IdentityTransformation
gap> DigraphColouring(CycleDigraph(3));
IdentityTransformation
gap> DigraphColouring(CycleDigraph(4));
Transformation( [ 1, 2, 1, 2 ] )
gap> DigraphColouring(CycleDigraph(5));
Transformation( [ 1, 2, 1, 2, 3 ] )
gap> DigraphColouring(CycleDigraph(6));
Transformation( [ 1, 2, 1, 2, 1, 2 ] )
gap> DigraphColouring(CompleteDigraph(10));
IdentityTransformation
gap> gr := CompleteDigraph(4);;
gap> HasDigraphColoring(gr) or HasDigraphColouring(gr);
false
gap> DigraphColoring(gr);
IdentityTransformation
gap> HasDigraphColoring(gr) and HasDigraphColouring(gr);
true
gap> gr := CycleDigraph(4);;
gap> HasDigraphColoring(gr) or HasDigraphColouring(gr);
false
gap> DigraphColouring(gr);
Transformation( [ 1, 2, 1, 2 ] )
gap> HasDigraphColoring(gr) and HasDigraphColouring(gr);
true

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
gap> STOP_TEST("Digraphs package: standard/grahom.tst");
