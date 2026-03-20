# Setup test environment
gap> START_TEST("Digraphs package: joinmeetirreducible.tst");
gap> LoadPackage("digraphs", false);;
gap> DIGRAPHS_StartTest();

# Define a lattice
gap> graph := Digraph([[2, 3], [5], [4], [5], []]);
<immutable digraph with 5 vertices, 5 edges>
gap> lattice := DigraphReflexiveTransitiveClosure(graph);
<immutable preorder digraph with 5 vertices, 13 edges>

# Test IsJoinIrreducible
gap> IsJoinIrreducible(lattice, 1);
true
gap> IsJoinIrreducible(lattice, 2);
true
gap> IsJoinIrreducible(lattice, 3);
true
gap> IsJoinIrreducible(lattice, 4);
true
gap> IsJoinIrreducible(lattice, 5);
false

# Test IsMeetIrreducible
gap> IsMeetIrreducible(lattice, 1);
false
gap> IsMeetIrreducible(lattice, 2);
true
gap> IsMeetIrreducible(lattice, 3);
true
gap> IsMeetIrreducible(lattice, 4);
true
gap> IsMeetIrreducible(lattice, 5);
true

# Teardown test environment
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: joinmeetirreducible.tst", 0);
