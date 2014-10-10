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
# meaning it really has multiple edges!!
DeclareProperty("IsMultiDigraph", IsDigraph);

BindGlobal("DigraphFamily", NewFamily("DigraphFamily",
 IsDigraph));

BindGlobal("DigraphType", NewType(DigraphFamily,
 IsDigraph and IsComponentObjectRep and IsAttributeStoringRep));

# constructors . . . 

DeclareOperation("Digraph", [IsRecord]);
DeclareOperation("Digraph", [IsList]);
DeclareOperation("DigraphNC", [IsRecord]);
DeclareOperation("DigraphNC", [IsList]);
DeclareOperation("DigraphByAdjacencyMatrix", [IsRectangularTable]);
DeclareOperation("DigraphByAdjacencyMatrix", [IsList and IsEmpty]);
DeclareOperation("DigraphByAdjacencyMatrixNC", [IsRectangularTable]);
DeclareOperation("DigraphByAdjacencyMatrixNC", [IsList and IsEmpty]);
DeclareOperation("DigraphByDigraphEdges", [IsRectangularTable]);
DeclareOperation("DigraphByDigraphEdges", [IsRectangularTable, IsPosInt]);
DeclareOperation("Graph", [IsDigraph]);
DeclareOperation("RandomDigraph", [IsPosInt]);
DeclareOperation("AsDigraph", [IsTransformation]);
DeclareOperation("AsDigraph", [IsTransformation, IsInt]);

