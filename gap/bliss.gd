#############################################################################
##
#W  grape.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareOperation("IsIsomorphicDigraph", [IsDigraph, IsDigraph]);
DeclareAttribute("AutomorphismGroup", IsDigraph);
DeclareOperation("DigraphIsomorphism", [IsDigraph, IsDigraph]);
DeclareOperation("Girth", [IsDigraph]);
DeclareOperation("Diameter", [IsDigraph]);
DeclareProperty("IsConnectedDigraph", IsDigraph);
