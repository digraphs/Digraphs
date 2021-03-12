#############################################################################
##
##  examples.gd
##  Copyright (C) 2019                                     Murray T. Whyte
##                                                       James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# This file contains constructors for certain standard examples of digraphs.

DeclareConstructor("EmptyDigraphCons", [IsDigraph, IsInt]);
DeclareOperation("EmptyDigraph", [IsInt]);
DeclareOperation("EmptyDigraph", [IsFunction, IsInt]);
DeclareSynonym("NullDigraph", EmptyDigraph);

DeclareConstructor("CompleteBipartiteDigraphCons",
                   [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("CompleteBipartiteDigraph", [IsPosInt, IsPosInt]);
DeclareOperation("CompleteBipartiteDigraph", [IsFunction, IsPosInt, IsPosInt]);

DeclareConstructor("CompleteMultipartiteDigraphCons", [IsDigraph, IsList]);
DeclareOperation("CompleteMultipartiteDigraph", [IsList]);
DeclareOperation("CompleteMultipartiteDigraph", [IsFunction, IsList]);

DeclareConstructor("CompleteDigraphCons", [IsDigraph, IsInt]);
DeclareOperation("CompleteDigraph", [IsInt]);
DeclareOperation("CompleteDigraph", [IsFunction, IsInt]);

DeclareConstructor("ChainDigraphCons", [IsDigraph, IsPosInt]);
DeclareOperation("ChainDigraph", [IsPosInt]);
DeclareOperation("ChainDigraph", [IsFunction, IsPosInt]);

DeclareConstructor("CycleDigraphCons", [IsDigraph, IsPosInt]);
DeclareOperation("CycleDigraph", [IsPosInt]);
DeclareOperation("CycleDigraph", [IsFunction, IsPosInt]);

DeclareConstructor("JohnsonDigraphCons", [IsDigraph, IsInt, IsInt]);
DeclareOperation("JohnsonDigraph", [IsInt, IsInt]);
DeclareOperation("JohnsonDigraph", [IsFunction, IsInt, IsInt]);

DeclareConstructor("PetersenGraphCons", [IsDigraph]);
DeclareOperation("PetersenGraph", []);
DeclareOperation("PetersenGraph", [IsFunction]);

DeclareConstructor("GeneralisedPetersenGraphCons", [IsDigraph, IsInt, IsInt]);
DeclareOperation("GeneralisedPetersenGraph", [IsInt, IsInt]);
DeclareOperation("GeneralisedPetersenGraph", [IsFunction, IsInt, IsInt]);

DeclareConstructor("LollipopGraphCons", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("LollipopGraph", [IsPosInt, IsPosInt]);
DeclareOperation("LollipopGraph", [IsFunction, IsPosInt, IsPosInt]);

DeclareConstructor("KingsGraphCons", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("KingsGraph", [IsPosInt, IsPosInt]);
DeclareOperation("KingsGraph", [IsFunction, IsPosInt, IsPosInt]);

DeclareConstructor("SquareGridGraphCons", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("SquareGridGraph", [IsPosInt, IsPosInt]);
DeclareOperation("SquareGridGraph", [IsFunction, IsPosInt, IsPosInt]);
DeclareSynonym("GridGraph", SquareGridGraph);

DeclareConstructor("TriangularGridGraphCons", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("TriangularGridGraph", [IsPosInt, IsPosInt]);
DeclareOperation("TriangularGridGraph", [IsFunction, IsPosInt, IsPosInt]);

DeclareConstructor("StarDigraphCons", [IsDigraph, IsPosInt]);
DeclareOperation("StarDigraph", [IsPosInt]);
DeclareOperation("StarDigraph", [IsFunction, IsPosInt]);

DeclareConstructor("KnightsGraphCons", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("KnightsGraph", [IsPosInt, IsPosInt]);
DeclareOperation("KnightsGraph", [IsFunction, IsPosInt, IsPosInt]);

DeclareConstructor("HaarGraphCons", [IsDigraph, IsPosInt]);
DeclareOperation("HaarGraph", [IsPosInt]);
DeclareOperation("HaarGraph", [IsFunction, IsPosInt]);
