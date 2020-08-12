#############################################################################
##
##  isomorph.gd
##  Copyright (C) 2014-19                                James D. Mitchell
##                                                          Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareAttribute("AutomorphismGroup", IsDigraph);
DeclareOperation("AutomorphismGroup", [IsDigraph, IsHomogeneousList]);
DeclareOperation("AutomorphismGroup", [IsDigraph, IsHomogeneousList, IsList]);
DeclareOperation("AutomorphismGroup", [IsDigraph, IsBool, IsList]);

DeclareAttribute("BlissAutomorphismGroup", IsDigraph);
DeclareOperation("BlissAutomorphismGroup", [IsDigraph, IsHomogeneousList]);
DeclareOperation("BlissAutomorphismGroup",
                 [IsDigraph, IsHomogeneousList, IsList]);
DeclareOperation("BlissAutomorphismGroup", [IsDigraph, IsBool, IsList]);

DeclareAttribute("NautyAutomorphismGroup", IsDigraph);
DeclareOperation("NautyAutomorphismGroup", [IsDigraph, IsHomogeneousList]);
DeclareOperation("NautyAutomorphismGroup",
                 [IsDigraph, IsHomogeneousList, IsList]);
DeclareOperation("NautyAutomorphismGroup", [IsDigraph, IsBool, IsList]);

DeclareAttribute("BlissCanonicalLabelling", IsDigraph);
DeclareOperation("BlissCanonicalLabelling", [IsDigraph, IsHomogeneousList]);

DeclareAttribute("NautyCanonicalLabelling", IsDigraph);
DeclareOperation("NautyCanonicalLabelling", [IsDigraph, IsHomogeneousList]);

DeclareAttributeThatReturnsDigraph("BlissCanonicalDigraph", IsDigraph);
DeclareOperation("BlissCanonicalDigraph", [IsDigraph, IsHomogeneousList]);

#  TODO document 2-arg BlissCanonicalDigraph and NautyCanonicalDigraph

DeclareAttributeThatReturnsDigraph("NautyCanonicalDigraph", IsDigraph);
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
DeclareGlobalFunction("DIGRAPHS_ValidateEdgeColouring");
DeclareGlobalFunction("DIGRAPHS_CollapseMultiColouredEdges");
DeclareGlobalFunction("DIGRAPHS_CollapseMultipleEdges");

DeclareOperation("IsDigraphAutomorphism", [IsDigraph, IsPerm]);
DeclareOperation("IsDigraphAutomorphism", [IsDigraph, IsPerm, IsList]);
DeclareOperation("IsDigraphAutomorphism", [IsDigraph, IsTransformation]);
DeclareOperation("IsDigraphAutomorphism", [IsDigraph, IsTransformation, IsList]);

DeclareOperation("IsDigraphIsomorphism", [IsDigraph, IsDigraph, IsPerm]);
DeclareOperation("IsDigraphIsomorphism",
                 [IsDigraph, IsDigraph, IsPerm, IsList, IsList]);
DeclareOperation("IsDigraphIsomorphism",
                 [IsDigraph, IsDigraph, IsTransformation]);
DeclareOperation("IsDigraphIsomorphism",
                 [IsDigraph, IsDigraph, IsTransformation, IsList, IsList]);
