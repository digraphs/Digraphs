#############################################################################
##
#W  digraph.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# category, family, type . . .

DeclareCategory("IsDirectedGraph", IsObject);

BindGlobal("DirectedGraphFamily", NewFamily("DirectedGraphFamily",
 IsDirectedGraph));

BindGlobal("DirectedGraphType", NewType(DirectedGraphFamily,
 IsDirectedGraph and IsComponentObjectRep and IsAttributeStoringRep));

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

