#############################################################################
##
#W  oper.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareOperation("MultiDigraphReverse", [IsMultiDigraph]);
DeclareOperation("MultiDigraphRelabel", [IsMultiDigraph, IsPerm]);
DeclareOperation("MultiDigraphRemoveLoops", [IsMultiDigraph]);
DeclareOperation("MultiDigraphRemoveEdges", [IsMultiDigraph, IsList]);
DeclareOperation("QuotientMultiDigraph", [IsMultiDigraph, IsList]);

DeclareOperation("DigraphReverse", [IsDigraph]);
DeclareOperation("DigraphRelabel", [IsDigraph, IsPerm]);
DeclareOperation("DigraphRemoveLoops", [IsDigraph]);
DeclareOperation("DigraphRemoveEdges", [IsDigraph, IsList]);
DeclareOperation("QuotientDigraph", [IsDigraph, IsList]);

DeclareAttribute("MultiDigraphFloydWarshall", IsMultiDigraph);

DeclareOperation("DigraphReflexiveTransitiveClosure", [IsDigraph]);
DeclareOperation("DigraphTransitiveClosure", [IsDigraph]);
