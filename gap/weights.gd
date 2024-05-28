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
DeclareAttribute("EdgeWeightedDigraphTotalWeight", IsDigraph and HasEdgeWeights);

# 2. Edge Weight Copies
DeclareOperation("EdgeWeightsMutableCopy", [IsDigraph and HasEdgeWeights]);

# 3. Minimum Spanning Trees
DeclareAttribute("EdgeWeightedDigraphMinimumSpanningTree",
                 IsDigraph and HasEdgeWeights);
