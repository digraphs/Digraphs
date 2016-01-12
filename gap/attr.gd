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
DeclareAttribute("OutDegreeSet", IsDigraph);
DeclareAttribute("InDegrees", IsDigraph);
DeclareAttribute("InDegreeSequence", IsDigraph);
DeclareAttribute("InDegreeSet", IsDigraph);
DeclareAttribute("DigraphSources", IsDigraph);
DeclareAttribute("DigraphSinks", IsDigraph);
DeclareAttribute("DigraphPeriod", IsDigraph);
DeclareAttribute("DigraphDiameter", IsDigraph);
DeclareAttribute("DigraphGirth", IsDigraph);
DeclareAttribute("DigraphAllSimpleCircuits", IsDigraph);

DeclareAttribute("DigraphSymmetricClosure", IsDigraph);
DeclareAttribute("DigraphReflexiveTransitiveClosure", IsDigraph);
DeclareAttribute("DigraphTransitiveClosure", IsDigraph);
DeclareGlobalFunction("DigraphTransitiveClosureNC");

DeclareAttribute("AdjacencyMatrix", IsDigraph);
DeclareAttribute("ReducedDigraph", IsDigraph);

# the following are for digraphs created with a known subgroup of the
# automorphism group.

DeclareAttribute("DigraphGroup", IsDigraph);

DeclareOperation("DigraphOrbits", [IsGroup, IsList, IsPosInt]);
DeclareAttribute("DigraphOrbits", IsDigraph);

DeclareAttribute("DigraphOrbitReps", IsDigraph);

DeclareOperation("DigraphStabilizers", [IsGroup, IsList]);
DeclareAttribute("DigraphStabilizers", IsDigraph, "mutable");
DeclareOperation("DigraphStabilizer", [IsDigraph, IsPosInt]);

DeclareAttribute("DigraphSchreierVector", IsDigraph);
DeclareAttribute("DigraphInnerOrbits", IsDigraph);

DeclareAttribute("RepresentativeOutNeighbours", IsDigraph);

# AsGraph must be mutable for grape to function properly
DeclareAttribute("AsGraph", IsDigraph, "mutable");
DeclareAttribute("AsTransformation", IsDigraph);
