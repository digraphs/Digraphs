#############################################################################
##
#W  digraph.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# in case we want to make a more elaborate data structure in the future

DeclareCategory("IsDirectedGraph", IsObject);

BindGlobal("DirectedGraphFamily", NewFamily("DirectedGraphFamily",
 IsDirectedGraph));

BindGlobal("DirectedGraphType", NewType(DirectedGraphFamily,
 IsDirectedGraph and IsComponentObjectRep and IsAttributeStoringRep));

# constructors
DeclareOperation("DirectedGraph", [IsRecord]);
DeclareOperation("DirectedGraph", [IsList]);
DeclareOperation("DirectedGraphNC", [IsRecord]);
DeclareOperation("DirectedGraphNC", [IsList]);
DeclareOperation("DirectedGraphByAdjacencyMatrix", [IsRectangularTable]);
DeclareOperation("Graph", [IsDirectedGraph]);
DeclareOperation("RandomSimpleDirectedGraph", [IsPosInt]);

# basic attributes
DeclareOperation("Vertices", [IsDirectedGraph]);
DeclareAttribute("Range", IsDirectedGraph);
DeclareAttribute("Source", IsDirectedGraph);
DeclareAttribute("Edges", IsDirectedGraph);
DeclareAttribute("Adjacencies", IsDirectedGraph);
DeclareOperation("StronglyConnectedComponents", [IsDirectedGraph]);

# properties
DeclareProperty("IsSimpleDirectedGraph", IsDirectedGraph);
DeclareProperty("IsUndirectedGraph", IsDirectedGraph);
DeclareProperty("IsFunctionalDirectedGraph", IsDirectedGraph);
DeclareProperty("IsStronglyConnectedDirectedGraph", IsDirectedGraph);
DeclareProperty("IsAcyclicDirectedGraph", IsDirectedGraph);

# operations
DeclareOperation("DirectedGraphRelabel", [IsDirectedGraph, IsPerm]);
DeclareOperation("DirectedGraphRemoveLoops", [IsDirectedGraph]);
DeclareOperation("DirectedGraphRemoveEdges", [IsDirectedGraph, IsList]);
DeclareOperation("DirectedGraphTopologicalSort", [IsDirectedGraph]);
DeclareOperation("DirectedGraphReflexiveTransitiveClosure", [IsDirectedGraph]);
DeclareOperation("DirectedGraphTransitiveClosure", [IsDirectedGraph]);

# calls to GRAPE functions
DeclareOperation("IsIsomorphicDirectedGraph", [IsDirectedGraph, IsDirectedGraph]);
DeclareAttribute("AutomorphismGroup", IsDirectedGraph);
DeclareOperation("DirectedGraphIsomorphism", [IsDirectedGraph, IsDirectedGraph]);
#DeclareOperation("Girth", [IsDirectedGraph]);
DeclareOperation("Diameter", [IsDirectedGraph]);
DeclareProperty("IsConnectedDigraph", IsDirectedGraph);

DeclareAttribute("DirectedGraphFloydWarshall", IsDirectedGraph);

DeclareOperation("WriteGraph6", [IsDirectedGraph]);
DeclareOperation("WriteDigraph6", [IsDirectedGraph]);
