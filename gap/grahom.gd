#############################################################################
##
##  grahom.gd
##  Copyright (C) 2014-17                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareGlobalFunction("GeneratorsOfEndomorphismMonoid");
DeclareAttribute("GeneratorsOfEndomorphismMonoidAttr", IsDigraph);

DeclareOperation("DigraphHomomorphism", [IsDigraph, IsDigraph]);
DeclareOperation("HomomorphismsDigraphs", [IsDigraph, IsDigraph]);
DeclareOperation("HomomorphismsDigraphsRepresentatives",
                 [IsDigraph, IsDigraph]);

DeclareOperation("DigraphMonomorphism", [IsDigraph, IsDigraph]);
DeclareOperation("MonomorphismsDigraphs", [IsDigraph, IsDigraph]);
DeclareOperation("MonomorphismsDigraphsRepresentatives",
                 [IsDigraph, IsDigraph]);

DeclareOperation("DigraphEpimorphism", [IsDigraph, IsDigraph]);
DeclareOperation("EpimorphismsDigraphs", [IsDigraph, IsDigraph]);
DeclareOperation("EpimorphismsDigraphsRepresentatives", [IsDigraph, IsDigraph]);

DeclareOperation("DigraphEmbedding", [IsDigraph, IsDigraph]);

DeclareOperation("DigraphColouring", [IsDigraph, IsInt]);
DeclareAttribute("DigraphColouring", IsDigraph);
DeclareSynonymAttr("DigraphColoring", DigraphColouring);

DeclareGlobalFunction("HomomorphismDigraphsFinder");
