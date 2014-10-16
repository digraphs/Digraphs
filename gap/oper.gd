#############################################################################
##
#W  oper.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareOperation("DigraphRelabel", [IsDigraph, IsPerm]);
DeclareOperation("DigraphRemoveLoops", [IsDigraph]);
DeclareOperation("DigraphRemoveEdges", [IsDigraph, IsList]);
DeclareOperation("DigraphRemoveVertices", [IsDigraph, IsList]);
DeclareOperation("DigraphAddEdges", [IsDigraph, IsList]);
DeclareOperation("DigraphAddVertices", [IsDigraph, IsList]);

DeclareOperation("DigraphFloydWarshall", [IsDigraph, IsFunction,
 IsObject, IsObject]);
DeclareOperation("DigraphTransitiveClosure", [IsDigraph]);
DeclareOperation("DigraphReflexiveTransitiveClosure", [IsDigraph]);
DeclareOperation("DigraphTransitiveClosure", [IsDigraph, IsBool]);
DeclareOperation("DigraphSymmetricClosure", [IsDigraph]);
DeclareOperation("DigraphReverse", [IsDigraph]);

DeclareOperation("QuotientDigraph", [IsDigraph, IsList]);
DeclareOperation("InducedSubdigraph", [IsDigraph, IsList]);

DeclareOperation("InNeighboursOfVertex", [IsDigraph, IsPosInt]);
DeclareOperation("InNeighboursOfVertexNC", [IsDigraph, IsPosInt]);
DeclareOperation("OutNeighboursOfVertex", [IsDigraph, IsPosInt]);
DeclareOperation("OutNeighboursOfVertexNC", [IsDigraph, IsPosInt]);
