#############################################################################
##
#W  standard/grahom.tst
#Y  Copyright (C) 2015                                   Wilfred A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/grahom.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#T# HomomorphismGraphsFinder: checking errors and robustness
gap> HomomorphismGraphsFinder(0, 0, 0, 0, 0, 0, 0, 0);
Error, Function Calls: number of arguments must be 9 (not 8)
gap> HomomorphismGraphsFinder(0, 0, 0, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 1st and 2nd arguments <gr1> and <gr2> must be digraphs,
gap> gr1 := ChainDigraph(2);;
gap> gr2 := CompleteDigraph(3);;
gap> HomomorphismGraphsFinder(0, gr2, 0, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 1st and 2nd arguments <gr1> and <gr2> must be digraphs,
gap> HomomorphismGraphsFinder(gr1, 0, 0, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 1st and 2nd arguments <gr1> and <gr2> must be digraphs,
gap> HomomorphismGraphsFinder(gr1, gr2, 0, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismGraphsFinder: error,
not yet implemented for non-symmetric digraphs,
gap> HomomorphismGraphsFinder(gr2, gr1, 0, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismGraphsFinder: error,
not yet implemented for non-symmetric digraphs,
gap> gr1 := CompleteDigraph(2);;
gap> HomomorphismGraphsFinder(gr1, gr2, 0, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 3rd argument <hook> has to be a function with 2 arguments,
gap> HomomorphismGraphsFinder(gr1, gr2, IsTournament, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 3rd argument <hook> has to be a function with 2 arguments,
gap> HomomorphismGraphsFinder(gr1, gr2, fail, 0, 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 4th argument <user_param> must be a list,
gap> HomomorphismGraphsFinder(gr1, gr2, fail, "a", 0, 0, 0, 0, 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 5th argument <limit> has to be a positive integer or infinity,
gap> HomomorphismGraphsFinder(gr1, gr2, fail, "a", "a", 0, 0, 0, 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 5th argument <limit> has to be a positive integer or infinity,
gap> HomomorphismGraphsFinder(gr1, gr2, fail, "a", 1, 0, 0, 0, 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 6th argument <hint> has to be a positive integer or fail,
gap> HomomorphismGraphsFinder(gr1, gr2, fail, "a", 1, 1, 0, 0, 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 7th argument <isinjective> has to be a true or false,
gap> HomomorphismGraphsFinder(gr1, gr2, fail, "a", infinity, fail, 0, 0, 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 7th argument <isinjective> has to be a true or false,
gap> HomomorphismGraphsFinder(gr1, gr2, fail, "a", infinity, 2, true, 0, 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 8th argument <image> has to be a duplicate-free list of vertices of the
2nd argument <gr2>,
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 1, true, [1, []], 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 8th argument <image> has to be a duplicate-free list of vertices of the
2nd argument <gr2>,
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 1, true, [[], []], 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 8th argument <image> has to be a duplicate-free list of vertices of the
2nd argument <gr2>,
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 1, true, [0, 1], 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 8th argument <image> has to be a duplicate-free list of vertices of the
2nd argument <gr2>,
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 1, true, [4, 4], 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 8th argument <image> has to be a duplicate-free list of vertices of the
2nd argument <gr2>,
gap> HomomorphismGraphsFinder(gr2, gr1, fail, [], 1, 1, true, [3], 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 8th argument <image> has to be a duplicate-free list of vertices of the
2nd argument <gr2>,
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 1, true, [3], 0);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 9th argument <map> must be a list of vertices of the 8th argument <image>
which is no longer than the number of vertices of the 1st argument <gr1>,
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 1, true, [3], [1..4]);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 9th argument <map> must be a list of vertices of the 8th argument <image>
which is no longer than the number of vertices of the 1st argument <gr1>,
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 1, true, [], [1, 2, 3, 2]);
Error, Digraphs: HomomorphismGraphsFinder: usage,
the 9th argument <map> must be a list of vertices of the 8th argument <image>
which is no longer than the number of vertices of the 1st argument <gr1>,
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 1, true, [1], [1]);
[  ]
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 2, true, [1, 2], [1]);
[  ]
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 3, false, [1, 2], [1]);
[  ]
gap> HomomorphismGraphsFinder(gr2, gr1, fail, [], 1, 3, false, [1, 2], [1]);
[  ]
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 1, false, [], []);
[  ]
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 1, false, [1, 2], []);
[  ]
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 1, false, [1, 2], []);
[  ]
gap> HomomorphismGraphsFinder(gr1, gr2, fail, [], 1, 2, false, [1], []);
[  ]
gap> HomomorphismGraphsFinder(gr1, gr1, fail, [], 1, 2, false, [1, 2], []);
[ IdentityTransformation ]
gap> gr := CompleteDigraph(513);;
gap> HomomorphismGraphsFinder(gr, gr, fail, [], 1, fail, false, [1 .. 513], []);
Error, Digraphs: HomomorphismGraphsFinder: error,
not yet implemented for digraphs with more than 512 vertices,

#T# DIGRAPHS_UnbindVariables
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);

#E#
gap> STOP_TEST("Digraphs package: standard/grahom.tst");
