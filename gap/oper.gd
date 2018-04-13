#############################################################################
##
##  oper.gd
##  Copyright (C) 2014-17                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareOperation("IsSubdigraph", [IsDigraph, IsDigraph]);
DeclareOperation("IsUndirectedSpanningTree", [IsDigraph, IsDigraph]);
DeclareOperation("IsUndirectedSpanningForest", [IsDigraph, IsDigraph]);

DeclareOperation("AsBinaryRelation", [IsDigraph]);
DeclareOperation("OnDigraphs", [IsDigraph, IsPerm]);
DeclareOperation("OnDigraphs", [IsDigraph, IsTransformation]);
DeclareOperation("OnMultiDigraphs", [IsDigraph, IsPermCollection]);
DeclareOperation("OnMultiDigraphs", [IsDigraph, IsPerm, IsPerm]);

DeclareOperation("DigraphRemoveLoops", [IsDigraph]);
DeclareOperation("DigraphRemoveEdge", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphRemoveEdge", [IsDigraph, IsList]);
DeclareOperation("DigraphRemoveEdges", [IsDigraph, IsList]);
DeclareOperation("DigraphRemoveEdgesNC", [IsDigraph, IsList]);
DeclareOperation("DigraphRemoveVertex", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphRemoveVertices", [IsDigraph, IsList]);
DeclareOperation("DigraphRemoveVerticesNC", [IsDigraph, IsList]);
DeclareOperation("DigraphAddEdge", [IsDigraph, IsList]);
DeclareOperation("DigraphAddEdges", [IsDigraph, IsList]);
DeclareOperation("DigraphAddEdgesNC", [IsDigraph, IsList]);
DeclareOperation("DigraphAddVertex", [IsDigraph]);
DeclareOperation("DigraphAddVertex", [IsDigraph, IsObject]);
DeclareOperation("DigraphAddVertices", [IsDigraph, IsInt]);
DeclareOperation("DigraphAddVertices", [IsDigraph, IsInt, IsList]);
DeclareOperation("DigraphAddVerticesNC", [IsDigraph, IsInt, IsList]);

DeclareOperation("DigraphFloydWarshall",
                 [IsDigraph, IsFunction, IsObject, IsObject]);
DeclareOperation("DigraphReflexiveTransitiveReduction", [IsDigraph]);
DeclareOperation("DigraphTransitiveReduction", [IsDigraph]);
DeclareOperation("DigraphTransitiveReductionNC", [IsDigraph, IsBool]);
DeclareOperation("DigraphReverse", [IsDigraph]);
DeclareOperation("DigraphReverseEdge", [IsDigraph, IsList]);
DeclareOperation("DigraphReverseEdge", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphReverseEdges", [IsDigraph, IsList]);
DeclareOperation("DigraphReverseEdgesNC", [IsDigraph, IsList]);

DeclareGlobalFunction("DigraphDisjointUnion");
DeclareGlobalFunction("DigraphEdgeUnion");
DeclareGlobalFunction("DigraphJoin");

DeclareOperation("QuotientDigraph", [IsDigraph, IsList]);
DeclareOperation("InducedSubdigraph", [IsDigraph, IsList]);

DeclareOperation("InDegreeOfVertex", [IsDigraph, IsPosInt]);
DeclareOperation("InDegreeOfVertexNC", [IsDigraph, IsPosInt]);
DeclareOperation("InNeighboursOfVertex", [IsDigraph, IsPosInt]);
DeclareSynonym("InNeighborsOfVertex", InNeighboursOfVertex);
DeclareOperation("InNeighboursOfVertexNC", [IsDigraph, IsPosInt]);
DeclareOperation("OutDegreeOfVertex", [IsDigraph, IsPosInt]);
DeclareOperation("OutDegreeOfVertexNC", [IsDigraph, IsPosInt]);
DeclareOperation("OutNeighboursOfVertex", [IsDigraph, IsPosInt]);
DeclareSynonym("OutNeighborsOfVertex", OutNeighboursOfVertex);
DeclareOperation("OutNeighboursOfVertexNC", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphInEdges", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphOutEdges", [IsDigraph, IsPosInt]);
DeclareOperation("IsDigraphEdge", [IsDigraph, IsList]);
DeclareOperation("IsDigraphEdge", [IsDigraph, IsPosInt, IsPosInt]);

DeclareOperation("DigraphConnectedComponent", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphStronglyConnectedComponent", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphPath", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("IteratorOfPaths", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("IteratorOfPaths", [IsList, IsPosInt, IsPosInt]);
DeclareOperation("IteratorOfPathsNC", [IsList, IsPosInt, IsPosInt]);
DeclareOperation("IsReachable", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("DigraphLongestDistanceFromVertex", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphRemoveAllMultipleEdges", [IsDigraph]);

DeclareOperation("OutNeighboursMutableCopy", [IsDigraph]);
DeclareSynonym("OutNeighborsMutableCopy", OutNeighboursMutableCopy);
DeclareOperation("InNeighboursMutableCopy", [IsDigraph]);
DeclareSynonym("InNeighborsMutableCopy", InNeighboursMutableCopy);
DeclareOperation("AdjacencyMatrixMutableCopy", [IsDigraph]);
DeclareOperation("BooleanAdjacencyMatrixMutableCopy", [IsDigraph]);

DeclareOperation("DigraphLayers", [IsDigraph, IsPosInt]);
DeclareAttribute("DIGRAPHS_Layers", IsDigraph, "mutable");
DeclareOperation("DigraphDistanceSet", [IsDigraph, IsPosInt, IsInt]);
DeclareOperation("DigraphDistanceSet", [IsDigraph, IsPosInt, IsList]);
DeclareOperation("DigraphShortestDistance", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("DigraphShortestDistance", [IsDigraph, IsList, IsList]);
DeclareOperation("DigraphShortestDistance", [IsDigraph, IsList]);

DeclareOperation("PartialOrderDigraphJoinOfVertices",
[IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("PartialOrderDigraphMeetOfVertices",
[IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("DigraphClosure", [IsDigraph, IsPosInt]);

DeclareOperation("DIGRAPHS_Matching", [IsDigraph, IsHomogeneousList]);
DeclareOperation("IsMatching", [IsDigraph, IsHomogeneousList]);
DeclareOperation("IsPerfectMatching", [IsDigraph, IsHomogeneousList]);
DeclareOperation("IsMaximalMatching", [IsDigraph, IsHomogeneousList]);
