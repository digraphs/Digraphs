#############################################################################
##
#W  digraph.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# category, family, type, representations . . .

DeclareCategory("IsDirectedGraph", IsObject);
# created by adjacencies
DeclareCategory("IsDigraphByAdjacency", IsDirectedGraph);      
# created by source and range
DeclareCategory("IsDigraphBySourceAndRange", IsDirectedGraph); 

BindGlobal("DirectedGraphFamily", NewFamily("DirectedGraphFamily",
 IsDirectedGraph));

BindGlobal("DigraphByAdjacencyType", NewType(DirectedGraphFamily,
 IsDigraphByAdjacency and IsComponentObjectRep and IsAttributeStoringRep));

BindGlobal("DigraphBySourceAndRangeType", NewType(DirectedGraphFamily,
 IsDigraphBySourceAndRange and IsComponentObjectRep and IsAttributeStoringRep));

# constructors . . . 

DeclareOperation("DirectedGraph", [IsRecord]);
DeclareOperation("DirectedGraph", [IsList]);
DeclareOperation("DirectedGraphNC", [IsRecord]);
DeclareOperation("DirectedGraphNC", [IsList]);
DeclareOperation("DirectedGraphByAdjacencyMatrix", [IsRectangularTable]);
DeclareOperation("DirectedGraphByEdges", [IsRectangularTable]);
DeclareOperation("DirectedGraphByEdges", [IsRectangularTable, IsPosInt]);
DeclareOperation("Graph", [IsDirectedGraph]);
DeclareOperation("RandomSimpleDirectedGraph", [IsPosInt]);
DeclareOperation("AsDirectedGraph", [IsTransformation]);
DeclareOperation("AsDirectedGraph", [IsTransformation, IsInt]);

