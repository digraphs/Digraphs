#############################################################################
##
##  oper.gd
##  Copyright (C) 2014-19                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# 1. Adding and removing vertices . . .
DeclareOperation("DigraphAddVertex", [IsDigraph]);
DeclareOperation("DigraphAddVertex", [IsDigraph, IsObject]);
DeclareOperation("DigraphAddVertices", [IsDigraph, IsInt]);
DeclareOperation("DigraphAddVertices", [IsDigraph, IsList]);
# 3-arg version of DigraphAddVertices is included for backwards compatibility.
DeclareOperation("DigraphAddVertices", [IsDigraph, IsInt, IsList]);

DeclareOperation("DigraphRemoveVertex", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphRemoveVertices", [IsDigraph, IsList]);
DeclareOperation("DigraphRemoveVerticesNC", [IsDigraph, IsList]);

# 2. Adding, removing, and reversing edges . . .
DeclareOperation("DigraphAddEdge", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("DigraphAddEdge", [IsDigraph, IsList]);
DeclareOperation("DigraphAddEdges", [IsDigraph, IsList]);

DeclareOperation("DigraphRemoveEdge", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("DigraphRemoveEdge", [IsDigraph, IsList]);
DeclareOperation("DigraphRemoveEdges", [IsDigraph, IsList]);

DeclareOperation("DigraphReverseEdge", [IsDigraph, IsList]);
DeclareOperation("DigraphReverseEdge", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("DigraphReverseEdges", [IsDigraph, IsList]);

DeclareOperation("DigraphClosure", [IsDigraph, IsPosInt]);

# 3. Ways of combining digraphs . . .
DeclareGlobalFunction("DigraphDisjointUnion");
DeclareGlobalFunction("DigraphJoin");
DeclareGlobalFunction("DigraphEdgeUnion");
DeclareGlobalFunction("DigraphCartesianProduct");
DeclareGlobalFunction("DigraphDirectProduct");
DeclareGlobalFunction("DIGRAPHS_CombinationOperProcessArgs");

# 4. Actions . . .
DeclareOperation("OnDigraphs", [IsDigraph, IsPerm]);
DeclareOperation("OnDigraphs", [IsDigraph, IsTransformation]);
DeclareOperation("OnMultiDigraphs", [IsDigraph, IsPermCollection]);
DeclareOperation("OnMultiDigraphs", [IsDigraph, IsPerm, IsPerm]);

# 5. Substructures and quotients . . .
DeclareOperation("QuotientDigraph", [IsDigraph, IsList]);
DeclareOperation("InducedSubdigraph", [IsDigraph, IsList]);

# 6. In and out degrees, neighbours, and edges of vertices . . .
DeclareOperation("InDegreeOfVertex", [IsDigraph, IsPosInt]);
DeclareOperation("InDegreeOfVertexNC", [IsDigraph, IsPosInt]);
DeclareOperation("OutDegreeOfVertex", [IsDigraph, IsPosInt]);
DeclareOperation("OutDegreeOfVertexNC", [IsDigraph, IsPosInt]);

DeclareOperation("InNeighboursOfVertex", [IsDigraph, IsPosInt]);
DeclareOperation("InNeighboursOfVertexNC", [IsDigraph, IsPosInt]);
DeclareOperation("OutNeighboursOfVertex", [IsDigraph, IsPosInt]);
DeclareOperation("OutNeighboursOfVertexNC", [IsDigraph, IsPosInt]);
DeclareSynonym("InNeighborsOfVertex", InNeighboursOfVertex);
DeclareSynonym("OutNeighborsOfVertex", OutNeighboursOfVertex);

DeclareOperation("DigraphInEdges", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphOutEdges", [IsDigraph, IsPosInt]);

# 7. Copies of out/in-neighbours
DeclareOperation("OutNeighboursMutableCopy", [IsDigraph]);
DeclareOperation("InNeighboursMutableCopy", [IsDigraph]);
DeclareOperation("AdjacencyMatrixMutableCopy", [IsDigraph]);
DeclareOperation("BooleanAdjacencyMatrixMutableCopy", [IsDigraph]);

DeclareSynonym("OutNeighborsMutableCopy", OutNeighboursMutableCopy);
DeclareSynonym("InNeighborsMutableCopy", InNeighboursMutableCopy);

# 8. IsSomething . . .
DeclareOperation("IsDigraphEdge", [IsDigraph, IsList]);
DeclareOperation("IsDigraphEdge", [IsDigraph, IsInt, IsInt]);

DeclareOperation("IsSubdigraph", [IsDigraph, IsDigraph]);
DeclareOperation("IsUndirectedSpanningTree", [IsDigraph, IsDigraph]);
DeclareOperation("IsUndirectedSpanningForest", [IsDigraph, IsDigraph]);

DeclareOperation("IsMatching", [IsDigraph, IsHomogeneousList]);
DeclareOperation("IsMaximalMatching", [IsDigraph, IsHomogeneousList]);
DeclareOperation("IsMaximumMatching", [IsDigraph, IsHomogeneousList]);
DeclareOperation("IsPerfectMatching", [IsDigraph, IsHomogeneousList]);

# 9. Connectivity . . .
DeclareOperation("DigraphFloydWarshall",
                 [IsDigraph, IsFunction, IsObject, IsObject]);
DeclareOperation("DigraphDijkstra",
                 [IsDigraph, IsPosInt]);
DeclareOperation("DigraphDijkstra",
                 [IsDigraph, IsPosInt, IsPosInt]);

DeclareOperation("DigraphConnectedComponent", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphStronglyConnectedComponent", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphPath", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("IteratorOfPaths", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("IteratorOfPaths", [IsList, IsPosInt, IsPosInt]);
DeclareOperation("IteratorOfPathsNC", [IsList, IsPosInt, IsPosInt]);
DeclareOperation("IsReachable", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("DigraphLongestDistanceFromVertex", [IsDigraph, IsPosInt]);

DeclareOperation("DigraphLayers", [IsDigraph, IsPosInt]);
DeclareAttribute("DIGRAPHS_Layers", IsDigraph, "mutable");
DeclareOperation("DigraphDistanceSet", [IsDigraph, IsPosInt, IsInt]);
DeclareOperation("DigraphDistanceSet", [IsDigraph, IsPosInt, IsList]);
DeclareOperation("DigraphShortestDistance", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("DigraphShortestDistance", [IsDigraph, IsList, IsList]);
DeclareOperation("DigraphShortestDistance", [IsDigraph, IsList]);
DeclareOperation("DigraphShortestPath", [IsDigraph, IsPosInt, IsPosInt]);

# 10. Operations for vertices . . .
DeclareOperation("PartialOrderDigraphJoinOfVertices",
                 [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("PartialOrderDigraphMeetOfVertices",
                 [IsDigraph, IsPosInt, IsPosInt]);
