#############################################################################
##
##  grahom.gd
##  Copyright (C) 2014-19                                James D. Mitchell
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

DeclareOperation("SubdigraphsMonomorphismsRepresentatives",
                 [IsDigraph, IsDigraph]);
DeclareOperation("SubdigraphsMonomorphisms",
                 [IsDigraph, IsDigraph]);

DeclareOperation("DigraphEpimorphism", [IsDigraph, IsDigraph]);
DeclareOperation("EpimorphismsDigraphs", [IsDigraph, IsDigraph]);
DeclareOperation("EpimorphismsDigraphsRepresentatives", [IsDigraph, IsDigraph]);

DeclareOperation("DigraphEmbedding", [IsDigraph, IsDigraph]);
DeclareOperation("EmbeddingsDigraphs", [IsDigraph, IsDigraph]);
DeclareOperation("EmbeddingsDigraphsRepresentatives", [IsDigraph, IsDigraph]);

DeclareOperation("DigraphColouring", [IsDigraph, IsInt]);

DeclareAttribute("DigraphGreedyColouring", IsDigraph);
DeclareOperation("DigraphGreedyColouring", [IsDigraph, IsFunction]);
DeclareOperation("DigraphGreedyColouring", [IsDigraph, IsHomogeneousList]);
DeclareOperation("DigraphGreedyColouringNC", [IsDigraph, IsHomogeneousList]);

DeclareAttribute("DigraphWelshPowellOrder", IsDigraph);
DeclareAttribute("DigraphSmallestLastOrder", IsDigraph);  # TODO: document

DeclareOperation("IsDigraphEndomorphism", [IsDigraph, IsTransformation]);
DeclareOperation("IsDigraphHomomorphism",
                 [IsDigraph, IsDigraph, IsTransformation]);

DeclareOperation("IsDigraphEndomorphism",
                 [IsDigraph, IsTransformation, IsList]);
DeclareOperation("IsDigraphHomomorphism",
                 [IsDigraph, IsDigraph, IsTransformation, IsList, IsList]);

DeclareOperation("IsDigraphEndomorphism", [IsDigraph, IsPerm]);
DeclareOperation("IsDigraphHomomorphism",
                 [IsDigraph, IsDigraph, IsPerm]);

DeclareOperation("IsDigraphEndomorphism",
                 [IsDigraph, IsPerm, IsList]);
DeclareOperation("IsDigraphHomomorphism",
                 [IsDigraph, IsDigraph, IsPerm, IsList, IsList]);

DeclareOperation("IsDigraphEpimorphism",
                 [IsDigraph, IsDigraph, IsTransformation]);
DeclareOperation("IsDigraphMonomorphism",
                 [IsDigraph, IsDigraph, IsTransformation]);
DeclareOperation("IsDigraphEmbedding",
                 [IsDigraph, IsDigraph, IsTransformation]);

DeclareOperation("IsDigraphEpimorphism",
                 [IsDigraph, IsDigraph, IsTransformation, IsList, IsList]);
DeclareOperation("IsDigraphMonomorphism",
                 [IsDigraph, IsDigraph, IsTransformation, IsList, IsList]);
DeclareOperation("IsDigraphEmbedding",
                 [IsDigraph, IsDigraph, IsTransformation, IsList, IsList]);

DeclareOperation("IsDigraphEpimorphism",
                 [IsDigraph, IsDigraph, IsPerm]);
DeclareOperation("IsDigraphMonomorphism",
                 [IsDigraph, IsDigraph, IsPerm]);
DeclareOperation("IsDigraphEmbedding",
                 [IsDigraph, IsDigraph, IsPerm]);

DeclareOperation("IsDigraphEpimorphism",
                 [IsDigraph, IsDigraph, IsPerm, IsList, IsList]);
DeclareOperation("IsDigraphMonomorphism",
                 [IsDigraph, IsDigraph, IsPerm, IsList, IsList]);
DeclareOperation("IsDigraphEmbedding",
                 [IsDigraph, IsDigraph, IsPerm, IsList, IsList]);

DeclareOperation("IsDigraphColouring", [IsDigraph, IsList]);
DeclareOperation("IsDigraphColouring", [IsDigraph, IsTransformation]);

DeclareOperation("DigraphsRespectsColouring",
                 [IsDigraph, IsDigraph, IsTransformation, IsList, IsList]);
DeclareOperation("DigraphsRespectsColouring",
                 [IsDigraph, IsDigraph, IsPerm, IsList, IsList]);

DeclareOperation("MaximalCommonSubdigraph", [IsDigraph, IsDigraph]);
DeclareOperation("MinimalCommonSuperdigraph", [IsDigraph, IsDigraph]);

DeclareOperation("LatticeDigraphEmbedding", [IsDigraph, IsDigraph]);

DeclareOperation("IsLatticeHomomorphism",
                 [IsDigraph, IsDigraph, IsTransformation]);
DeclareOperation("IsLatticeHomomorphism",
                 [IsDigraph, IsDigraph, IsPerm]);
DeclareOperation("IsLatticeEndomorphism", [IsDigraph, IsTransformation]);
DeclareOperation("IsLatticeEndomorphism", [IsDigraph, IsPerm]);
DeclareOperation("IsLatticeEpimorphism",
                 [IsDigraph, IsDigraph, IsTransformation]);
DeclareOperation("IsLatticeEpimorphism",
                 [IsDigraph, IsDigraph, IsPerm]);
DeclareOperation("IsLatticeEmbedding",
                 [IsDigraph, IsDigraph, IsTransformation]);
DeclareOperation("IsLatticeEmbedding",
                 [IsDigraph, IsDigraph, IsPerm]);
DeclareSynonym("IsLatticeMonomorphism", IsLatticeEmbedding);

