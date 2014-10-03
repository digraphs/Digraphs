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

DeclareAttribute("AdjacencyMatrix", IsDigraph);
# GrapeGraph must be mutable for grape to function properly
DeclareAttribute("GrapeGraph", IsDigraph, "mutable");
DeclareAttribute("Range", IsDigraph);
DeclareAttribute("Source", IsDigraph);
DeclareAttribute("Edges", IsDigraph);
DeclareAttribute("Adjacencies", IsDigraph);
DeclareAttribute("NrVertices", IsDigraph);
DeclareAttribute("NrEdges", IsDigraph);
DeclareAttribute("DigraphTopologicalSort", IsDigraph);
DeclareAttribute("DigraphDual", IsDigraph);

# these are really attributes but are declared elsewhere as operations and so we
# must declare them as operations too
DeclareOperation("Vertices", [IsDigraph]);
DeclareOperation("StronglyConnectedComponents", [IsDigraph]);


