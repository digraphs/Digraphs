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
DeclareAttribute("EdgeWeightedDigraphTotalWeight",
IsDigraph and HasEdgeWeights);

# 2. Edge Weight Copies
DeclareOperation("EdgeWeightsMutableCopy", [IsDigraph and HasEdgeWeights]);

# 3. Minimum Spanning Trees
DeclareAttribute("EdgeWeightedDigraphMinimumSpanningTree",
                 IsDigraph and HasEdgeWeights);

# 4. Shortest Path
DeclareAttribute("EdgeWeightedDigraphShortestPaths",
                 IsDigraph and HasEdgeWeights);
DeclareOperation("EdgeWeightedDigraphShortestPaths",
                 [IsDigraph and HasEdgeWeights, IsPosInt]);
DeclareOperation("EdgeWeightedDigraphShortestPath",
                 [IsDigraph and HasEdgeWeights, IsPosInt, IsPosInt]);

DeclareGlobalFunction("DIGRAPHS_Edge_Weighted_Johnson");
DeclareGlobalFunction("DIGRAPHS_Edge_Weighted_FloydWarshall");
DeclareGlobalFunction("DIGRAPHS_Edge_Weighted_Bellman_Ford");
DeclareGlobalFunction("DIGRAPHS_Edge_Weighted_Dijkstra");

# 5. Maximum Flow
DeclareOperation("DigraphMaximumFlow",
                 [IsDigraph and HasEdgeWeights, IsPosInt, IsPosInt]);

# 6. Random edge weighted digraphs
DeclareOperation("RandomUniqueEdgeWeightedDigraph", [IsPosInt]);
DeclareOperation("RandomUniqueEdgeWeightedDigraph", [IsPosInt, IsFloat]);
DeclareOperation("RandomUniqueEdgeWeightedDigraph", [IsPosInt, IsRat]);
DeclareOperation("RandomUniqueEdgeWeightedDigraph", [IsFunction, IsPosInt]);
DeclareOperation("RandomUniqueEdgeWeightedDigraph",
                 [IsFunction, IsPosInt, IsFloat]);
DeclareOperation("RandomUniqueEdgeWeightedDigraph",
                 [IsFunction, IsPosInt, IsRat]);
