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

DeclareOperation("Vertices", [IsDirectedGraph]);
DeclareAttribute("Range", IsDirectedGraph);
DeclareAttribute("Source", IsDirectedGraph);
DeclareAttribute("Edges", IsDirectedGraph);
DeclareAttribute("Adjacencies", IsDirectedGraph);
DeclareOperation("StronglyConnectedComponents", [IsDirectedGraph]);
DeclareAttribute("AdjacencyMatrix", IsDirectedGraph);

