#############################################################################
##
#W  attrs.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# attributes for digraphs . . .


DeclareAttribute("DigraphVertices", [IsDigraph]);
DeclareAttribute("DigraphEdges", IsDigraph);
DeclareAttribute("OutNeighbours", IsDigraph);
DeclareAttribute("InNeighbours", IsDigraph);
DeclareAttribute("DigraphNrVertices", IsDigraph);
DeclareAttribute("DigraphNrEdges", IsDigraph);

DeclareAttribute("DigraphRange", IsDigraph);
DeclareAttribute("DigraphSource", IsDigraph);
DeclareAttribute("DigraphTopologicalSort", IsDigraph);
DeclareAttribute("DigraphDual", IsDigraph);
DeclareAttribute("DigraphShortestDistances", IsDigraph);
DeclareAttribute("DigraphStronglyConnectedComponents", IsDigraph);

DeclareAttribute("AdjacencyMatrix", IsDigraph);
# GrapeGraph must be mutable for grape to function properly
DeclareAttribute("GrapeGraph", IsDigraph, "mutable");

# these are really attributes but are declared elsewhere as operations and so we
# must declare them as operations too



