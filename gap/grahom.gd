#############################################################################
##
#W  grahom.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareAttribute("DigraphEndomorphisms", IsDigraph);
DeclareOperation("HomomorphismDigraphs", [IsDigraph, IsDigraph]);
DeclareOperation("DigraphHomomorphism", [IsDigraph, IsDigraph]);
DeclareAttribute("EndomorphismMonoid", IsDigraph);
DeclareOperation("DigraphColoring", [IsDigraph, IsPosInt]);

