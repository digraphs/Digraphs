#############################################################################
##
##  weights.gd
##  Copyright (C) 2023                                Raiyan Chowdhury
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# 1. Edge Weights
DeclareAttribute("EdgeWeights", IsDigraph);
DeclareGlobalFunction("EdgeWeightedDigraph");
DeclareProperty("IsNegativeEdgeWeightedDigraph", IsDigraph and HasEdgeWeights);

# 2. Edge Weight Copies
DeclareOperation("EdgeWeightsMutableCopy", [IsDigraph and HasEdgeWeights]);

# 3. Minimum Spanning Trees
DeclareAttribute("DigraphEdgeWeightedMinimumSpanningTree", IsDigraph and HasEdgeWeights);

# 4. Shortest Path
DeclareOperation("DigraphEdgeWeightedShortestPath", [IsDigraph and HasEdgeWeights, IsPosInt]);
DeclareAttribute("DigraphEdgeWeightedShortestPaths", IsDigraph and HasEdgeWeights);

# 5. Maximum Flow
DeclareOperation("DigraphMaximumFlow", [IsDigraph and HasEdgeWeights, IsPosInt, IsPosInt]);
DeclareAttribute("DigraphMinimumCuts", IsDigraph);

# 6. Random Edge Weighted Digraph
DeclareOperation("RandomUniqueEdgeWeightedDigraph",[IsPosInt]);
DeclareOperation("RandomUniqueEdgeWeightedDigraph", [IsPosInt, IsFloat]);
DeclareOperation("RandomUniqueEdgeWeightedDigraph", [IsPosInt, IsRat]);
DeclareOperation("RandomUniqueEdgeWeightedDigraph", [IsFunction, IsPosInt, IsFloat]);
DeclareOperation("RandomUniqueEdgeWeightedDigraph", [IsFunction, IsPosInt, IsRat]);

# 7. Painting Edge Weighted Digraph
DeclareOperation("DigraphFromPaths", [IsDigraph, IsRecord]);
DeclareOperation("DigraphFromPath", [IsDigraph, IsRecord, IsPosInt]);
DeclareOperation("DotEdgeWeightedDigraph", [IsDigraph, IsDigraph, IsRecord]);
