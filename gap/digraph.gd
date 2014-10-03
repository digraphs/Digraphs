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

DeclareCategory("IsDigraph", IsObject);
# created by adjacencies
DeclareCategory("IsDigraphByAdjacency", IsDigraph);      
# created by source and range
DeclareCategory("IsDigraphBySourceAndRange", IsDigraph); 

BindGlobal("DigraphFamily", NewFamily("DigraphFamily",
 IsDigraph));

BindGlobal("DigraphByAdjacencyType", NewType(DigraphFamily,
 IsDigraphByAdjacency and IsComponentObjectRep and IsAttributeStoringRep));

BindGlobal("DigraphBySourceAndRangeType", NewType(DigraphFamily,
 IsDigraphBySourceAndRange and IsComponentObjectRep and IsAttributeStoringRep));

# constructors . . . 

DeclareOperation("Digraph", [IsRecord]);
DeclareOperation("Digraph", [IsList]);
DeclareOperation("DigraphNC", [IsRecord]);
DeclareOperation("DigraphNC", [IsList]);
DeclareOperation("DigraphByAdjacencyMatrix", [IsRectangularTable]);
DeclareOperation("DigraphByEdges", [IsRectangularTable]);
DeclareOperation("DigraphByEdges", [IsRectangularTable, IsPosInt]);
DeclareOperation("Graph", [IsDigraph]);
DeclareOperation("RandomSimpleDigraph", [IsPosInt]);
DeclareOperation("AsDigraph", [IsTransformation]);
DeclareOperation("AsDigraph", [IsTransformation, IsInt]);

