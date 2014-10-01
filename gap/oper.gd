#############################################################################
##
#W  oper.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareOperation("DirectedGraphRelabel", [IsDirectedGraph, IsPerm]);
DeclareOperation("DirectedGraphRemoveLoops", [IsDirectedGraph]);
DeclareOperation("DirectedGraphRemoveEdges", [IsDirectedGraph, IsList]);
DeclareOperation("DirectedGraphTopologicalSort", [IsDirectedGraph]);
DeclareOperation("DirectedGraphReflexiveTransitiveClosure", [IsDirectedGraph]);
DeclareOperation("DirectedGraphTransitiveClosure", [IsDirectedGraph]);
DeclareAttribute("DirectedGraphFloydWarshall", IsDirectedGraph);

DeclareOperation("DirectedGraphReverse", [IsDirectedGraph]);


