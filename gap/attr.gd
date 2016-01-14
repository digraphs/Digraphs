#############################################################################
##
#W  attr.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
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
DeclareAttribute("DigraphDual", IsDigraph);
DeclareAttribute("DigraphShortestDistances", IsDigraph);
DeclareAttribute("DigraphStronglyConnectedComponents", IsDigraph);
DeclareAttribute("DigraphConnectedComponents", IsDigraph);
DeclareAttribute("DIGRAPHS_Bipartite", IsDigraph);
DeclareAttribute("DigraphBicomponents", IsDigraph);

DeclareAttribute("OutNeighbours", IsDigraph);
DeclareSynonymAttr("OutNeighbors", OutNeighbours);
DeclareAttribute("InNeighbours", IsDigraph);
DeclareSynonymAttr("InNeighbors", InNeighbours);
DeclareAttribute("OutDegrees", IsDigraph);
DeclareAttribute("OutDegreeSequence", IsDigraph);
DeclareAttribute("InDegrees", IsDigraph);
DeclareAttribute("InDegreeSequence", IsDigraph);
DeclareAttribute("DigraphSources", IsDigraph);
DeclareAttribute("DigraphSinks", IsDigraph);
DeclareAttribute("DigraphPeriod", IsDigraph);
DeclareAttribute("DigraphDiameter", IsDigraph);
DeclareAttribute("DigraphAllSimpleCircuits", IsDigraph);
DeclareAttribute("DigraphLoops", IsDigraph);
DeclareAttribute("DigraphDegeneracy", IsDigraph);
DeclareAttribute("DigraphDegeneracyOrdering", IsDigraph);
DeclareAttribute("DIGRAPHS_Degeneracy", IsDigraph);

DeclareAttribute("DigraphSymmetricClosure", IsDigraph);
DeclareAttribute("DigraphReflexiveTransitiveClosure", IsDigraph);
DeclareAttribute("DigraphTransitiveClosure", IsDigraph);
DeclareGlobalFunction("DigraphTransitiveClosureNC");

DeclareAttribute("AdjacencyMatrix", IsDigraph);
DeclareAttribute("BooleanAdjacencyMatrix", IsDigraph);
DeclareAttribute("ReducedDigraph", IsDigraph);
DeclareAttribute("MaximalSymmetricSubdigraph", IsDigraph);
DeclareAttribute("MaximalSymmetricSubdigraphWithoutLoops", IsDigraph);
DeclareOperation("DIGRAPHS_MaximalSymmetricSubdigraph", [IsDigraph, IsBool]);

DeclareAttribute("AsTransformation", IsDigraph);

# AsGraph must be mutable for grape to function properly
DeclareAttribute("AsGraph", IsDigraph, "mutable");
