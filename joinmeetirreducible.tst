#@local b2, chain, graph, lattice, m3

# Setup test environment
gap> START_TEST("Digraphs package: joinmeetirreducible.tst");
gap> LoadPackage("digraphs", false);;
gap> DIGRAPHS_StartTest();

# The pentagon lattice N5: 1 < {2, 3}, 3 < 4, {2, 4} < 5
gap> graph := Digraph([[2, 3], [5], [4], [5], []]);
<immutable digraph with 5 vertices, 5 edges>
gap> lattice := DigraphReflexiveTransitiveClosure(graph);
<immutable preorder digraph with 5 vertices, 13 edges>

# Test IsJoinIrreducible on N5
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

# Test IsMeetIrreducible on N5
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

# A 4-element chain: every element is doubly irreducible
gap> chain := DigraphReflexiveTransitiveClosure(ChainDigraph(4));
<immutable preorder digraph with 4 vertices, 10 edges>

# Test IsJoinIrreducible on a chain
gap> IsJoinIrreducible(chain, 1);
true
gap> IsJoinIrreducible(chain, 2);
true
gap> IsJoinIrreducible(chain, 3);
true
gap> IsJoinIrreducible(chain, 4);
true

# Test IsMeetIrreducible on a chain
gap> IsMeetIrreducible(chain, 1);
true
gap> IsMeetIrreducible(chain, 2);
true
gap> IsMeetIrreducible(chain, 3);
true
gap> IsMeetIrreducible(chain, 4);
true

# The Boolean lattice B2: 1 < {2, 3} < 4
gap> b2 := DigraphReflexiveTransitiveClosure(Digraph([[2, 3], [4], [4], []]));
<immutable preorder digraph with 4 vertices, 9 edges>

# Test IsJoinIrreducible on B2
gap> IsJoinIrreducible(b2, 1);
true
gap> IsJoinIrreducible(b2, 2);
true
gap> IsJoinIrreducible(b2, 3);
true
gap> IsJoinIrreducible(b2, 4);
false

# Test IsMeetIrreducible on B2
gap> IsMeetIrreducible(b2, 1);
false
gap> IsMeetIrreducible(b2, 2);
true
gap> IsMeetIrreducible(b2, 3);
true
gap> IsMeetIrreducible(b2, 4);
true

# The M3 lattice: 1 < {2, 3, 4} < 5
gap> m3 := DigraphReflexiveTransitiveClosure(Digraph([[2, 3, 4], [5], [5], [5], []]));
<immutable preorder digraph with 5 vertices, 12 edges>

# Test IsJoinIrreducible on M3
gap> IsJoinIrreducible(m3, 1);
true
gap> IsJoinIrreducible(m3, 2);
true
gap> IsJoinIrreducible(m3, 3);
true
gap> IsJoinIrreducible(m3, 4);
true
gap> IsJoinIrreducible(m3, 5);
false

# Test IsMeetIrreducible on M3
gap> IsMeetIrreducible(m3, 1);
false
gap> IsMeetIrreducible(m3, 2);
true
gap> IsMeetIrreducible(m3, 3);
true
gap> IsMeetIrreducible(m3, 4);
true
gap> IsMeetIrreducible(m3, 5);
true

# Teardown test environment
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: joinmeetirreducible.tst", 0);
