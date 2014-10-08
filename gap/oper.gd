#############################################################################
##
#W  oper.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareOperation("DigraphRelabel", [IsDigraph, IsPerm]);
DeclareOperation("DigraphRemoveLoops", [IsDigraph]);
DeclareOperation("DigraphRemoveEdges", [IsDigraph, IsList]);
DeclareOperation("DigraphReflexiveTransitiveClosure", [IsDigraph]);
DeclareOperation("DigraphTransitiveClosure", [IsDigraph]);
DeclareAttribute("DigraphShortestDistances", IsDigraph);
DeclareOperation("DigraphReverse", [IsDigraph]);
