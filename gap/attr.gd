#############################################################################
##
##  attr.gd
##  Copyright (C) 2014-19                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# attributes for digraphs . . .

DeclareAttribute("DigraphVertices", IsDigraph);
DeclareAttribute("DigraphEdges", IsDigraph);
DeclareAttribute("DigraphNrVertices", IsDigraph);
DeclareAttribute("DigraphNrEdges", IsDigraph);

DeclareAttribute("DigraphRange", IsDigraph);
DeclareAttribute("DigraphSource", IsDigraph);
DeclareAttribute("DigraphTopologicalSort", IsDigraph);
DeclareAttribute("DigraphShortestDistances", IsDigraph);
DeclareAttribute("DigraphStronglyConnectedComponents", IsDigraph);
DeclareAttribute("DigraphNrStronglyConnectedComponents", IsDigraph);
DeclareAttribute("DigraphConnectedComponents", IsDigraph);
DeclareAttribute("DIGRAPHS_Bipartite", IsDigraph);
DeclareAttribute("DigraphBicomponents", IsDigraph);

DeclareAttribute("OutNeighbours", IsDigraph);
DeclareSynonymAttr("OutNeighbors", OutNeighbours);
DeclareAttribute("InNeighbours", IsDigraph);
DeclareSynonymAttr("InNeighbors", InNeighbours);
DeclareAttribute("OutDegrees", IsDigraph);
DeclareAttribute("OutDegreeSequence", IsDigraph);
DeclareAttribute("OutDegreeSet", IsDigraph);
DeclareAttribute("InDegrees", IsDigraph);
DeclareAttribute("InDegreeSequence", IsDigraph);
DeclareAttribute("InDegreeSet", IsDigraph);
DeclareAttribute("DigraphSources", IsDigraph);
DeclareAttribute("DigraphSinks", IsDigraph);
DeclareAttribute("DigraphPeriod", IsDigraph);
DeclareAttribute("DigraphDiameter", IsDigraph);
DeclareAttribute("DigraphGirth", IsDigraph);
DeclareAttribute("DigraphOddGirth", IsDigraph);
DeclareAttribute("DigraphUndirectedGirth", IsDigraph);
DeclareAttribute("DigraphAllSimpleCircuits", IsDigraph);
DeclareAttribute("DigraphLongestSimpleCircuit", IsDigraph);
DeclareAttribute("DigraphLoops", IsDigraph);
DeclareAttribute("DigraphDegeneracy", IsDigraph);
DeclareAttribute("DigraphDegeneracyOrdering", IsDigraph);
DeclareAttribute("DIGRAPHS_Degeneracy", IsDigraph);

DeclareAttribute("ArticulationPoints", IsDigraph);
DeclareSynonymAttr("CutVertices", ArticulationPoints);

DeclareAttribute("ChromaticNumber", IsDigraph);
DeclareAttribute("CharacteristicPolynomial", IsDigraph);

DeclareAttribute("DigraphAdjacencyFunction", IsDigraph);

DeclareAttribute("DigraphCore", IsDigraph);

DeclareAttribute("AdjacencyMatrix", IsDigraph);
DeclareAttribute("BooleanAdjacencyMatrix", IsDigraph);

DeclareAttribute("DegreeMatrix", IsDigraph);
DeclareAttribute("LaplacianMatrix", IsDigraph);
DeclareAttribute("NrSpanningTrees", IsDigraph);

DeclareAttribute("HamiltonianPath", IsDigraph);

# AsGraph must be mutable for grape to function properly
DeclareAttribute("AsGraph", IsDigraph, "mutable");
DeclareAttribute("AsTransformation", IsDigraph);
DeclareAttribute("DIGRAPHS_ConnectivityData", IsDigraph, "mutable");

# Things that are attributes for immutable digraphs, but operations for mutable.

DeclareOperation("DigraphReverse", [IsDigraph]);
DeclareAttribute("DigraphReverseAttr", IsDigraph);
DeclareOperation("DigraphDual", [IsDigraph]);
DeclareAttribute("DigraphDualAttr", IsDigraph);
DeclareOperation("ReducedDigraph", [IsDigraph]);
DeclareAttribute("ReducedDigraphAttr", IsDigraph);

DeclareOperation("DigraphRemoveAllMultipleEdges", [IsDigraph]);
DeclareAttribute("DigraphRemoveAllMultipleEdgesAttr", IsDigraph);
DeclareOperation("DigraphAddAllLoops", [IsDigraph]);
DeclareAttribute("DigraphAddAllLoopsAttr", IsDigraph);
DeclareOperation("DigraphRemoveLoops", [IsDigraph]);
DeclareAttribute("DigraphRemoveLoopsAttr", IsDigraph);

DeclareOperation("DigraphSymmetricClosure", [IsDigraph]);
DeclareAttribute("DigraphSymmetricClosureAttr", IsDigraph);
DeclareOperation("MaximalSymmetricSubdigraph", [IsDigraph]);
DeclareAttribute("MaximalSymmetricSubdigraphAttr", IsDigraph);
DeclareOperation("MaximalSymmetricSubdigraphWithoutLoops", [IsDigraph]);
DeclareAttribute("MaximalSymmetricSubdigraphWithoutLoopsAttr", IsDigraph);
DeclareOperation("MaximalAntiSymmetricSubdigraph", [IsDigraph]);
DeclareAttribute("MaximalAntiSymmetricSubdigraphAttr", IsDigraph);

DeclareOperation("DigraphTransitiveClosure", [IsDigraph]);
DeclareAttribute("DigraphTransitiveClosureAttr", IsDigraph);
DeclareOperation("DigraphReflexiveTransitiveClosure", [IsDigraph]);
DeclareAttribute("DigraphReflexiveTransitiveClosureAttr", IsDigraph);
DeclareOperation("DigraphTransitiveReduction", [IsDigraph]);
DeclareAttribute("DigraphTransitiveReductionAttr", IsDigraph);
DeclareOperation("DigraphReflexiveTransitiveReduction", [IsDigraph]);
DeclareAttribute("DigraphReflexiveTransitiveReductionAttr", IsDigraph);

DeclareOperation("UndirectedSpanningForest", [IsDigraph]);
DeclareAttribute("UndirectedSpanningForestAttr", IsDigraph);
DeclareOperation("UndirectedSpanningTree", [IsDigraph]);
DeclareAttribute("UndirectedSpanningTreeAttr", IsDigraph);

DeclareOperation("DigraphMycielskian", [IsDigraph]);
DeclareAttribute("DigraphMycielskianAttr", IsDigraph);
