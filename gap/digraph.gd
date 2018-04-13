#############################################################################
##
##  digraph.gd
##  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# category, family, type, representations . . .

DeclareCategory("IsDigraph", IsObject);
DeclareCategory("IsDigraphWithAdjacencyFunction", IsDigraph);
DeclareCategory("IsCayleyDigraph", IsDigraph);

DeclareAttribute("GroupOfCayleyDigraph", IsCayleyDigraph);
DeclareAttribute("SemigroupOfCayleyDigraph", IsCayleyDigraph);
DeclareAttribute("GeneratorsOfCayleyDigraph", IsCayleyDigraph);

# meaning it really has multiple edges!!
DeclareProperty("IsMultiDigraph", IsDigraph);

BindGlobal("DigraphFamily", NewFamily("DigraphFamily", IsDigraph));

# constructors . . .

DeclareOperation("Digraph", [IsRecord]);
DeclareOperation("Digraph", [IsList]);
DeclareOperation("Digraph", [IsList, IsFunction]);
DeclareOperation("Digraph", [IsInt, IsList, IsList]);
DeclareOperation("Digraph", [IsList, IsList, IsList]);
DeclareOperation("Digraph", [IsBinaryRelation]);
DeclareOperation("Digraph", [IsGroup,
                             IsListOrCollection,
                             IsFunction,
                             IsFunction]);
DeclareOperation("CayleyDigraph", [IsGroup]);
DeclareOperation("CayleyDigraph", [IsGroup, IsList]);

DeclareOperation("DoubleDigraph", [IsDigraph]);

DeclareOperation("DistanceDigraph", [IsDigraph, IsInt]);
DeclareOperation("DistanceDigraph", [IsDigraph, IsList]);

DeclareOperation("BipartiteDoubleDigraph", [IsDigraph]);

DeclareOperation("DigraphNC", [IsRecord]);
DeclareOperation("DigraphNC", [IsList]);
DeclareOperation("DigraphNC", [IsList, IsInt]);
DeclareOperation("DigraphByAdjacencyMatrix", [IsHomogeneousList]);
DeclareOperation("DigraphByAdjacencyMatrixNC", [IsHomogeneousList]);
DeclareOperation("DigraphByEdges", [IsRectangularTable]);
DeclareOperation("DigraphByEdges", [IsRectangularTable, IsPosInt]);
DeclareOperation("DigraphByEdges", [IsList and IsEmpty]);
DeclareOperation("DigraphByEdges", [IsList and IsEmpty, IsPosInt]);
DeclareOperation("DigraphByInNeighbours", [IsList]);
DeclareOperation("DigraphByInNeighbors", [IsList]);
DeclareOperation("DigraphByInNeighboursNC", [IsList]);
DeclareOperation("DigraphByInNeighboursNC", [IsList, IsInt]);
DeclareOperation("EdgeOrbitsDigraph", [IsPermGroup, IsList, IsInt]);
DeclareOperation("EdgeOrbitsDigraph", [IsPermGroup, IsList]);
DeclareOperation("DigraphAddEdgeOrbit", [IsDigraph, IsList]);
DeclareOperation("DigraphRemoveEdgeOrbit", [IsDigraph, IsList]);

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
DeclareOperation("CompleteMultipartiteDigraph", [IsList]);
DeclareOperation("CompleteDigraph", [IsInt]);
DeclareOperation("EmptyDigraph", [IsInt]);
DeclareSynonym("NullDigraph", EmptyDigraph);
DeclareOperation("CycleDigraph", [IsPosInt]);
DeclareOperation("ChainDigraph", [IsPosInt]);
DeclareOperation("LineDigraph", [IsDigraph]);
DeclareOperation("LineUndirectedDigraph", [IsDigraph]);
DeclareSynonym("EdgeDigraph", LineDigraph);
DeclareSynonym("EdgeUndirectedDigraph", LineUndirectedDigraph);

# Vertex labels
DeclareOperation("DigraphVertexLabel", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphVertexLabels", [IsDigraph]);
DeclareOperation("SetDigraphVertexLabel", [IsDigraph, IsPosInt, IsObject]);
DeclareOperation("SetDigraphVertexLabels", [IsDigraph, IsList]);

# Edge labels
DeclareOperation("DigraphEdgeLabel", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("DigraphEdgeLabelsNC", [IsDigraph]);
DeclareOperation("DigraphEdgeLabels", [IsDigraph]);
DeclareOperation("SetDigraphEdgeLabel",
                 [IsDigraph, IsPosInt, IsPosInt, IsObject]);
DeclareOperation("SetDigraphEdgeLabelsNC", [IsDigraph, IsList]);
DeclareOperation("SetDigraphEdgeLabels", [IsDigraph, IsList]);
DeclareOperation("SetDigraphEdgeLabels", [IsDigraph, IsFunction]);

DeclareOperation("DigraphAddAllLoops", [IsDigraph]);

DeclareOperation("JohnsonDigraph", [IsInt, IsInt]);
