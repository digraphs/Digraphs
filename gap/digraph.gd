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
DeclareOperation("Digraph", [IsPosInt, IsFunction]);
DeclareOperation("Digraph", [IsBinaryRelation]);
DeclareOperation("DigraphNC", [IsRecord]);
DeclareOperation("DigraphNC", [IsList]);
DeclareOperation("DigraphByAdjacencyMatrix", [IsRectangularTable]);
DeclareOperation("DigraphByAdjacencyMatrix", [IsList and IsEmpty]);
DeclareOperation("DigraphByAdjacencyMatrixNC", [IsRectangularTable]);
DeclareOperation("DigraphByAdjacencyMatrixNC", [IsList and IsEmpty]);
DeclareOperation("DigraphByEdges", [IsRectangularTable]);
DeclareOperation("DigraphByEdges", [IsRectangularTable, IsPosInt]);
DeclareOperation("DigraphByEdges", [IsList and IsEmpty]);
DeclareOperation("DigraphByEdges", [IsList and IsEmpty, IsPosInt]);
DeclareOperation("Graph", [IsDigraph]);
DeclareOperation("AsDigraph", [IsTransformation]);
DeclareOperation("AsDigraph", [IsTransformation, IsInt]);
DeclareOperation("DigraphCopy", [IsDigraph]);

DeclareOperation("RandomDigraph", [IsPosInt]);
DeclareOperation("RandomDigraph", [IsPosInt, IsFloat]);
DeclareOperation("RandomMultiDigraph", [IsPosInt]);
DeclareOperation("RandomMultiDigraph", [IsPosInt, IsPosInt]);
DeclareOperation("RandomTournament", [IsInt]);

DeclareOperation("CompleteBipartiteDigraph", [IsPosInt, IsPosInt]);
DeclareOperation("CompleteDigraph", [IsInt]);
DeclareOperation("EmptyDigraph", [IsInt]);
DeclareOperation("CycleDigraph", [IsPosInt]);

DeclareOperation("DigraphVertexName", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphVertexNames", [IsDigraph]);
DeclareOperation("SetDigraphVertexName", [IsDigraph, IsPosInt, IsObject]);
DeclareOperation("SetDigraphVertexNames", [IsDigraph, IsList]);

DeclareOperation("DigraphEdgeLabel", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphEdgeLabels", [IsDigraph]);
DeclareOperation("SetDigraphEdgeLabel", [IsDigraph, IsPosInt, IsObject]);
DeclareOperation("SetDigraphEdgeLabels", [IsDigraph, IsList]);

