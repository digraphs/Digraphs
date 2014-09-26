#############################################################################
##
#W  digraph.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

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
DeclareOperation("DirectedGraphByEdges", [IsRectangularTable]);
DeclareOperation("DirectedGraphByEdges", [IsRectangularTable, IsPosInt]);
DeclareOperation("Graph", [IsDirectedGraph]);
DeclareOperation("RandomSimpleDirectedGraph", [IsPosInt]);

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

DeclareAttribute("DirectedGraphFloydWarshall", IsDirectedGraph);
DeclareOperation("AsDirectedGraph", [IsTransformation]);
DeclareOperation("AsDirectedGraph", [IsTransformation, IsInt]);
