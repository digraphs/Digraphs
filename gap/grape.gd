#############################################################################
##
#W  grape.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareOperation("IsIsomorphicDirectedGraph", [IsDirectedGraph, IsDirectedGraph]);
DeclareAttribute("AutomorphismGroup", IsDirectedGraph);
DeclareOperation("DirectedGraphIsomorphism", [IsDirectedGraph, IsDirectedGraph]);
DeclareOperation("Girth", [IsDirectedGraph]);
DeclareOperation("Diameter", [IsDirectedGraph]);
DeclareProperty("IsConnectedDigraph", IsDirectedGraph);
