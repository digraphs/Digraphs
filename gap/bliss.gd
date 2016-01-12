#############################################################################
##
#W  bliss.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareAttribute("AutomorphismGroup", IsDigraph);
DeclareOperation("AutomorphismGroup", [IsDigraph, IsHomogeneousList]);
DeclareAttribute("DigraphCanonicalLabelling", IsDigraph);
DeclareOperation("DigraphCanonicalLabelling", [IsDigraph, IsHomogeneousList]);
DeclareOperation("IsIsomorphicDigraph", [IsDigraph, IsDigraph]);
DeclareOperation("IsomorphismDigraphs", [IsDigraph, IsDigraph]);
