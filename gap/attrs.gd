#############################################################################
##
#W  attrs.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# attributes for directed graphs . . .

DeclareAttribute("AdjacencyMatrix", IsDirectedGraph);
# GrapeGraph must be mutable for grape to function properly
DeclareAttribute("GrapeGraph", IsDirectedGraph, "mutable");
DeclareAttribute("Range", IsDirectedGraph);
DeclareAttribute("Source", IsDirectedGraph);
DeclareAttribute("Edges", IsDirectedGraph);
DeclareAttribute("Adjacencies", IsDirectedGraph);

# these are really attributes but are declared elsewhere as operations and so we
# must declare them as operations too
DeclareOperation("Vertices", [IsDirectedGraph]);
DeclareOperation("StronglyConnectedComponents", [IsDirectedGraph]);


