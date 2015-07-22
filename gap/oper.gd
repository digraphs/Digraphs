#############################################################################
##
#W  oper.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

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

DeclareOperation("DigraphFloydWarshall", [IsDigraph, IsFunction,
 IsObject, IsObject]);
DeclareOperation("DigraphTransitiveClosure", [IsDigraph]);
DeclareOperation("DigraphReflexiveTransitiveClosure", [IsDigraph]);
DeclareOperation("DigraphTransitiveClosure", [IsDigraph, IsBool]);
DeclareOperation("DigraphSymmetricClosure", [IsDigraph]);
DeclareOperation("DigraphReverse", [IsDigraph]);
DeclareOperation("DigraphReverseEdge", [IsDigraph, IsList]);
DeclareOperation("DigraphReverseEdge", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphReverseEdges", [IsDigraph, IsList]);
DeclareOperation("DigraphReverseEdgesNC", [IsDigraph, IsList]);
DeclareOperation("DigraphDisjointUnion", [IsDigraph, IsDigraph]);
DeclareOperation("DigraphEdgeUnion", [IsDigraph, IsDigraph]);
DeclareOperation("DigraphJoin", [IsDigraph, IsDigraph]);

DeclareOperation("QuotientDigraph", [IsDigraph, IsList]);
DeclareOperation("InducedSubdigraph", [IsDigraph, IsList]);

DeclareOperation("InDegreeOfVertex", [IsDigraph, IsPosInt]);
DeclareOperation("InDegreeOfVertexNC", [IsDigraph, IsPosInt]);
DeclareOperation("InNeighborsOfVertex", [IsDigraph, IsPosInt]);
DeclareOperation("InNeighboursOfVertex", [IsDigraph, IsPosInt]);
DeclareOperation("InNeighboursOfVertexNC", [IsDigraph, IsPosInt]);
DeclareOperation("OutDegreeOfVertex", [IsDigraph, IsPosInt]);
DeclareOperation("OutDegreeOfVertexNC", [IsDigraph, IsPosInt]);
DeclareOperation("OutNeighborsOfVertex", [IsDigraph, IsPosInt]);
DeclareOperation("OutNeighboursOfVertex", [IsDigraph, IsPosInt]);
DeclareOperation("OutNeighboursOfVertexNC", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphInEdges", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphOutEdges", [IsDigraph, IsPosInt]);
DeclareOperation("IsDigraphEdge", [IsDigraph, IsList]);

DeclareOperation("DigraphConnectedComponent", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphStronglyConnectedComponent", [IsDigraph, IsPosInt]);
DeclareOperation("IsReachable", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("DigraphLongestDistanceFromVertex", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphRemoveAllMultipleEdges", [IsDigraph]);

DeclareOperation("OutNeighboursCopy", [IsDigraph]);
DeclareOperation("OutNeighborsCopy", [IsDigraph]);
