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

DeclareAttribute("OutNeighbours", IsDigraph);
DeclareAttribute("OutNeighbors", IsDigraph);
DeclareAttribute("InNeighbours", IsDigraph);
DeclareAttribute("InNeighbors", IsDigraph);

DeclareAttribute("AdjacencyMatrix", IsDigraph);

# AsGraph must be mutable for grape to function properly
DeclareAttribute("AsGraph", IsDigraph, "mutable");
