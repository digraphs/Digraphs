#############################################################################
##
#W  bliss.gd
#Y  Copyright (C) 2014-17                                James D. Mitchell
##                                                          Wilf A. Wilson
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
DeclareOperation("IsIsomorphicDigraph",
                 [IsDigraph, IsDigraph, IsHomogeneousList, IsHomogeneousList]);
DeclareOperation("IsomorphismDigraphs", [IsDigraph, IsDigraph]);
DeclareOperation("IsomorphismDigraphs",
                 [IsDigraph, IsDigraph, IsHomogeneousList, IsHomogeneousList]);

DeclareGlobalFunction("DIGRAPHS_ValidateVertexColouring");
