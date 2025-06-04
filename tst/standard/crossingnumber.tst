# This is a file containing all tests I (Mark Toner) have written

gap> START_TEST("Digraphs package: standard/crossingnumber.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

# Tests function for finding crossing number of Complete Digraphs

# Test for Complete Digraph on 0 vertices
gap> D := CompleteDigraph(0);
<immutable empty digraph with 0 vertices>
gap> DIGRAPHS_CompleteDigraphCrossingNumber(D);
0

# Test for non-Complete Digraph
gap> D := CompleteBipartiteDigraph(3, 3);
<immutable complete bipartite digraph with bicomponent sizes 3 and 3>
gap> DIGRAPHS_CompleteDigraphCrossingNumber(D);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 2nd choice method found for `DIGRAPHS_CompleteDigraphCrossingNumber'\
 on 1 arguments

# Test for Complete Digraph on 14 vertices
gap> D := CompleteDigraph(14);
<immutable complete digraph with 14 vertices>
gap> DIGRAPHS_CompleteDigraphCrossingNumber(D);
1260

# Test for Complete Digraph on 15 vertices
gap> D := CompleteDigraph(15);
<immutable complete digraph with 15 vertices>
gap> DIGRAPHS_CompleteDigraphCrossingNumber(D);
Error, Complete Digraph contains too many vertices for known crossing number

# Tests function for finding partitions size of CompleteMultipartiteDigraph

# Test for complete bipartite digraph
gap> D := CompleteBipartiteDigraph(2, 3);
<immutable complete bipartite digraph with bicomponent sizes 2 and 3>
gap> CompleteMultipartiteDigraphPartitionSize(D);
[ 2, 3 ]

# Test for valid complete multipartite digraph (1)
gap> D := CompleteMultipartiteDigraph([2, 3, 4]);
<immutable complete multipartite digraph with 9 vertices, 52 edges>
gap> CompleteMultipartiteDigraphPartitionSize(D);
[ 2, 3, 4 ]

# Test for valid complete multipartite digraph (2)
gap> D := CompleteMultipartiteDigraph([1, 1, 2, 3]);
<immutable complete multipartite digraph with 7 vertices, 34 edges>
gap> CompleteMultipartiteDigraphPartitionSize(D);
[ 1, 1, 2, 3 ]

# tests for DIGRAPHS_CrossingNumberInequality function
# test crossing number is 0 for planar Graph
gap> D := WindmillGraph(4, 3);
<immutable symmetric digraph with 10 vertices, 36 edges>
gap> DIGRAPHS_CrossingNumberInequality(D);
0

# test crossing number is correct for a graph with e >= 6.95n (1)
gap> D := CompleteDigraph(10);
<immutable complete digraph with 10 vertices>
gap> DIGRAPHS_CrossingNumberInequality(D);
252

# test crossing number is correct for a graph with e >= 6.95n (2)
gap> D := CompleteDigraph(8);
<immutable complete digraph with 8 vertices>
gap> DIGRAPHS_CrossingNumberInequality(D);
95

# test crossing number is correct for a graph with e <= 6.95n (1)
gap> D := CompleteDigraph(5);
<immutable complete digraph with 5 vertices>
gap> DIGRAPHS_CrossingNumberInequality(D);
5

# test crossing number is correct for a graph with e <= 6.95n (2)
gap> D := CompleteDigraph(6);
<immutable complete digraph with 6 vertices>
gap> DIGRAPHS_CrossingNumberInequality(D);
19

# test crossing number for empty graph
gap> D := Digraph([]);
<immutable empty digraph with 0 vertices>
gap> DIGRAPHS_CrossingNumberInequality(D);
0

# test crossing number for graph with no edges
gap> D := Digraph([[], [], [], [], []]);
<immutable empty digraph with 5 vertices>
gap> DIGRAPHS_CrossingNumberInequality(D);
0

# Cubic Digraph Construction tests 

# Test for 0 vertices
gap> D := RandomDigraph(IsCubicDigraph, 0);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RandomDigraph' on 2 arguments

# Test for 2 vertices
gap> D := RandomDigraph(IsCubicDigraph, 2);
Error, Cubic Digraphs must have at least 4 vertices

# Test for 4 vertices
gap> D := RandomDigraph(IsCubicDigraph, 4);
<immutable tournament with 4 vertices>

# Test for 7 vertices
gap> D := RandomDigraph(IsCubicDigraph, 7);
Error, Cubic Digraphs exist only for even vertices

# Test for 10 vertices
gap> D := RandomDigraph(IsCubicDigraph, 10);
<immutable digraph with 10 vertices, 15 edges>

# Test for 500 vertices
gap> D := RandomDigraph(IsCubicDigraph, 500);
<immutable digraph with 500 vertices, 750 edges>

# Test for 2000 vertices
gap> D := RandomDigraph(IsCubicDigraph, 2000);
<immutable digraph with 2000 vertices, 3000 edges>

# Tests for finding all triangles in a digraph

# Test for an empty digraph
gap> D := EmptyDigraph(0);;
gap> DigraphAllThreeCycles(D);
[  ]

# Test for a digraph with loops
gap> D := CompleteDigraph(3);;
gap> D := DigraphAddAllLoops(D);;
gap> DigraphAllThreeCycles(D);
[ [ 1, 2, 3 ], [ 1, 3, 2 ] ]

# Test for a regular expected digraph (1)
gap> D := CompleteDigraph(4);;
gap> DigraphAllThreeCycles(D);
[ [ 1, 2, 3 ], [ 1, 2, 4 ], [ 1, 3, 2 ], [ 1, 3, 4 ], [ 1, 4, 2 ], 
  [ 1, 4, 3 ], [ 2, 3, 4 ], [ 2, 4, 3 ] ]

# Test for a regular expected digraph (2)
gap> D := Digraph([[2], [3], [1]]);;
gap> DigraphAllThreeCycles(D);
[ [ 1, 2, 3 ] ]

# Test for a regular expected digraph (3)
gap> D := Digraph([[2, 4, 5], [1, 3], [1, 5], [5], [1, 4]]);;
gap> DigraphAllThreeCycles(D);
[ [ 1, 2, 3 ], [ 1, 4, 5 ] ]

# Tests for finding all triangles in a digraph

# Test for an empty digraph
gap> D := EmptyDigraph(0);
<immutable empty digraph with 0 vertices>
gap> DigraphAllTriangles(D);
[  ]

# Test for a digraph with loops
gap> D := CompleteDigraph(3);;
gap> D := DigraphAddAllLoops(D);;
gap> DigraphAllTriangles(D);
[ [ 1, 2, 3 ] ]

# Test for a regular expected digraph (1)
gap> D := CompleteDigraph(4);;
gap> DigraphAllTriangles(D);
[ [ 1, 2, 3 ], [ 1, 2, 4 ], [ 1, 3, 4 ], [ 2, 3, 4 ] ]

# Test for a regular expected digraph (2)
gap> D := Digraph([[2], [3], [1]]);;
gap> DigraphAllTriangles(D);
[ [ 1, 2, 3 ] ]

# Test for a regular expected digraph (3)
gap> D := Digraph([[2, 4, 5], [1, 3], [1, 5], [5], [4]]);;
gap> DigraphAllTriangles(D);
[ [ 1, 2, 3 ], [ 1, 3, 5 ], [ 1, 4, 5 ] ]

# tests for DIGRAPHS_CrossingNumberAlbertson function

# Test that the method fails for a digraph with loops
gap> D := CompleteDigraph(5);
<immutable complete digraph with 5 vertices>
gap> D := DigraphAddAllLoops(D);
<immutable reflexive digraph with 5 vertices, 25 edges>
gap> DIGRAPHS_CrossingNumberAlbertson(D);
Error, the argument <D> must be a digraph with no loops,

# Test for digraph with valid chromatic number (1)
gap> D := CompleteDigraph(5);
<immutable complete digraph with 5 vertices>
gap> DIGRAPHS_CrossingNumberAlbertson(D);
1

# Test for digraph with valid chromatic number (2)
gap> D := CompleteDigraph(10);
<immutable complete digraph with 10 vertices>
gap> DIGRAPHS_CrossingNumberAlbertson(D);
60

# Test for digraph with valid chromatic number (3)
gap> D := CompleteBipartiteDigraph(2, 5);
<immutable complete bipartite digraph with bicomponent sizes 2 and 5>
gap> DIGRAPHS_CrossingNumberAlbertson(D);
0

# Test for digraph with chromatic number higher than 14
gap> D := CompleteDigraph(15);
<immutable complete digraph with 15 vertices>
gap> DIGRAPHS_CrossingNumberAlbertson(D);
-1

# Tests for the IsCubicDigraph method

# Test for an empty digraph with 0 vertices
gap> D := EmptyDigraph(0);;
gap> IsCubicDigraph(D);
true

# Test for a cubic digraph (1)
gap> D := RandomTournament(4);;
gap> IsCubicDigraph(D);
true

# Test for a cubic digraph (2)
gap> D := Digraph([[4, 5], [3, 4, 6], [5, 6], [5], [], [1]]);;
gap> IsCubicDigraph(D);
true

# Test for a non cubic digraph (1)
gap> D := CompleteBipartiteDigraph(3, 3);;
gap> IsCubicDigraph(D);
false

# Test for a non cubic digraph (2)
gap> D := RandomDigraph(9);;
gap> IsCubicDigraph(D);
false

# Test for a digraph with loops
gap> D := RandomTournament(4);;
gap> D := DigraphAddAllLoops(D);;
gap> IsCubicDigraph(D);
false

# Test for a multidigraph (will always return false for a multidigraph so randomness unimportant)
gap> D := RandomMultiDigraph(10);;
gap> IsCubicDigraph(D);
false

# Tests to determine if a digraph is semicomplete or not

# Test for a semicomplete digraph (1)
gap> D := Digraph([[2, 3], [3], []]);
<immutable digraph with 3 vertices, 3 edges>
gap> IsSemicompleteDigraph(D);
true

# Test for a semicomplete digraph (2)
gap> D := Digraph([[2, 3, 4, 5], [3, 5], [4], [1, 2], [1, 2, 3, 4]]);
<immutable digraph with 5 vertices, 13 edges>
gap> IsSemicompleteDigraph(D);
true

# Test for an empty digraph
gap> D := EmptyDigraph(0);
<immutable empty digraph with 0 vertices>
gap> IsSemicompleteDigraph(D);
true

# Test for a tournament
gap> D := RandomTournament(15);
<immutable tournament with 15 vertices>
gap> IsSemicompleteDigraph(D);
true

# Test for a complete digraph
gap> D := CompleteDigraph(15);
<immutable complete digraph with 15 vertices>
gap> IsSemicompleteDigraph(D);
true

# Test for a non-semicomplete digraph (1)
gap> D := CycleDigraph(9);
<immutable cycle digraph with 9 vertices>
gap> IsSemicompleteDigraph(D);
false

# Test for a non-semicomplete digraph (2)
gap> D := BinaryTree(6);
<immutable digraph with 63 vertices, 62 edges>
gap> IsSemicompleteDigraph(D);
false

# tests for DIGRAPHS_IsK22FreeDigraph function

# test that a complete digraph is K22-free
gap> D := CompleteDigraph(9);
<immutable complete digraph with 9 vertices>
gap> DIGRAPHS_IsK22FreeDigraph(D);
true

# test that a complete bipartite graph is not K22-free
gap> D := CompleteBipartiteDigraph(3, 2);
<immutable complete bipartite digraph with bicomponent sizes 3 and 2>
gap> DIGRAPHS_IsK22FreeDigraph(D);
false

# test that a digraph with fewer than 4 vertices is K22-free
gap> D := CompleteDigraph(3);
<immutable complete digraph with 3 vertices>
gap> DIGRAPHS_IsK22FreeDigraph(D);
true

# test that a digraph that is not K2,2 free is correctly identified as such
gap> D := Digraph([[3, 4], [3, 4], [1, 2], [1, 2]]);
<immutable digraph with 4 vertices, 8 edges>
gap> DIGRAPHS_IsK22FreeDigraph(D);
false

# Tests for random semicomplete digraph generation

# Test for n = 10,  p not given
gap> D := RandomDigraph(IsSemicompleteDigraph, 10);;
gap> IsSemicompleteDigraph(D);
true

# Test for n = 3, p not given
gap> D := RandomDigraph(IsSemicompleteDigraph, 3);;
gap> IsSemicompleteDigraph(D);
true

# Test for n = 9, p=0
gap> D := RandomDigraph(IsSemicompleteDigraph, 9);;
gap> IsSemicompleteDigraph(D);
true

# Test for n = 9, p=1
gap> D := RandomDigraph(IsSemicompleteDigraph, 9, 1);;
gap> IsSemicompleteDigraph(D);
true

# Test for n = 9, p=0.5
gap> D := RandomDigraph(IsSemicompleteDigraph, 9, 0.5);;
gap> IsSemicompleteDigraph(D);
true

# Test for n=-1 
gap> D := RandomDigraph(IsSemicompleteDigraph, -1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RandomDigraph' on 2 arguments

# Test for n=1, p=-1
gap> D := RandomDigraph(IsSemicompleteDigraph, 1, -1);
<immutable empty digraph with 1 vertex>

# Test for n=1, p=1.1
gap> D := RandomDigraph(IsSemicompleteDigraph, 1, 1.1);;
gap> IsSemicompleteDigraph(D);
true

# Test for n=s, p=1
gap> D := RandomDigraph(IsSemicompleteDigraph, "s", -1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RandomDigraph' on 3 arguments

# Test for no n,p
gap> D := RandomDigraph(IsSemicompleteDigraph);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RandomDigraph' on 1 arguments

# Tests for semicomplete digraph crossing number calculator

# Test for a planar SemicompleteDigraph
gap> D := RandomDigraph(IsSemicompleteDigraph, 4);;
gap> SemicompleteDigraphCrossingNumber(D);        
0

# Test for a semicomplete digraph without known crossing number (<15 vertices) (1)
gap> D := RandomDigraph(IsSemicompleteDigraph, 5);;
gap> SemicompleteDigraphCrossingNumber(D);        
[ 1, 4 ]

# Test for a semicomplete digraph without known crossing number (<15 vertices) (2)
gap> D := RandomDigraph(IsSemicompleteDigraph, 12);;
gap> SemicompleteDigraphCrossingNumber(D);          
[ 150, 600 ]

# Test for a semicomplete digraph without known crossing number (>=15 vertices)
gap> D := RandomDigraph(IsSemicompleteDigraph, 15);;
gap> SemicompleteDigraphCrossingNumber(D);          
[ 178, 1764 ]

# Tests function for finding crossing number of Tournaments

# Test for tournament on 0 vertices
gap> D := RandomTournament(0);
<immutable empty digraph with 0 vertices>
gap> DIGRAPHS_TournamentCrossingNumber(D);
0

# Test for tournament on 14 vertices
gap> D := RandomTournament(14);
<immutable tournament with 14 vertices>
gap> DIGRAPHS_TournamentCrossingNumber(D);
315

# Test for tournament on 15 vertices
gap> D := RandomTournament(15);
<immutable tournament with 15 vertices>
gap> DIGRAPHS_TournamentCrossingNumber(D);
-1
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/constructors.tst", 0);
