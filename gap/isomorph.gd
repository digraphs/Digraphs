#############################################################################
##
##  isomorph.gd
##  Copyright (C) 2014-17                                James D. Mitchell
##                                                          Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareAttribute("AutomorphismGroup", IsDigraph);
DeclareOperation("AutomorphismGroup", [IsDigraph, IsHomogeneousList]);

DeclareAttribute("BlissAutomorphismGroup", IsDigraph);
DeclareOperation("BlissAutomorphismGroup", [IsDigraph, IsHomogeneousList]);

DeclareAttribute("NautyAutomorphismGroup", IsDigraph);
DeclareOperation("NautyAutomorphismGroup", [IsDigraph, IsHomogeneousList]);

DeclareAttribute("BlissCanonicalLabelling", IsDigraph);
DeclareOperation("BlissCanonicalLabelling", [IsDigraph, IsHomogeneousList]);

DeclareAttribute("NautyCanonicalLabelling", IsDigraph);
DeclareOperation("NautyCanonicalLabelling", [IsDigraph, IsHomogeneousList]);

DeclareAttribute("BlissCanonicalDigraph", IsDigraph);
DeclareOperation("BlissCanonicalDigraph", [IsDigraph, IsHomogeneousList]);

DeclareAttribute("NautyCanonicalDigraph", IsDigraph);
DeclareOperation("NautyCanonicalDigraph", [IsDigraph, IsHomogeneousList]);

DeclareOperation("IsIsomorphicDigraph", [IsDigraph, IsDigraph]);
DeclareOperation("IsIsomorphicDigraph",
                 [IsDigraph, IsDigraph, IsHomogeneousList, IsHomogeneousList]);
DeclareOperation("IsomorphismDigraphs", [IsDigraph, IsDigraph]);
DeclareOperation("IsomorphismDigraphs",
                 [IsDigraph, IsDigraph, IsHomogeneousList, IsHomogeneousList]);

DeclareGlobalFunction("DigraphsUseBliss");
DeclareGlobalFunction("DigraphsUseNauty");

BindGlobal("DIGRAPHS_UsingBliss", true);

DeclareGlobalFunction("DIGRAPHS_ValidateVertexColouring");

DeclareOperation("IsDigraphAutomorphism", [IsDigraph, IsPerm]);
