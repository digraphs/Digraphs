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
DeclareOperation("DigraphNC", [IsList, IsInt]);
DeclareOperation("DigraphByAdjacencyMatrix", [IsRectangularTable]);
DeclareOperation("DigraphByAdjacencyMatrix", [IsList and IsEmpty]);
DeclareOperation("DigraphByAdjacencyMatrixNC", [IsRectangularTable]);
DeclareOperation("DigraphByAdjacencyMatrixNC", [IsList and IsEmpty]);
DeclareOperation("DigraphByEdges", [IsRectangularTable]);
DeclareOperation("DigraphByEdges", [IsRectangularTable, IsPosInt]);
DeclareOperation("DigraphByEdges", [IsList and IsEmpty]);
DeclareOperation("DigraphByEdges", [IsList and IsEmpty, IsPosInt]);
DeclareOperation("DigraphByInNeighbours", [IsList]);
DeclareOperation("DigraphByInNeighbors", [IsList]);
DeclareOperation("DigraphByInNeighboursNC", [IsList]);
DeclareOperation("DigraphByInNeighboursNC", [IsList, IsInt]);
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

DeclareOperation("DigraphVertexLabel", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphVertexLabels", [IsDigraph]);
DeclareOperation("SetDigraphVertexLabel", [IsDigraph, IsPosInt, IsObject]);
DeclareOperation("SetDigraphVertexLabels", [IsDigraph, IsList]);

DeclareOperation("DigraphEdgeLabel", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphEdgeLabels", [IsDigraph]);
DeclareOperation("SetDigraphEdgeLabel", [IsDigraph, IsPosInt, IsObject]);
DeclareOperation("SetDigraphEdgeLabels", [IsDigraph, IsList]);

DeclareOperation("ReducedDigraph", [IsDigraph]);
