#############################################################################
##
##  deprecated.gd
##  Copyright (C) 2024                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareAttribute("DotDigraph", IsDigraph);
DeclareAttribute("DotSymmetricDigraph", IsDigraph);

DeclareOperation("DotSymmetricVertexColoredDigraph", [IsDigraph, IsList]);
DeclareOperation("DotVertexColoredDigraph", [IsDigraph, IsList]);

DeclareOperation("DotEdgeColoredDigraph", [IsDigraph, IsList]);
DeclareOperation("DotSymmetricEdgeColoredDigraph", [IsDigraph, IsList]);

DeclareOperation("DotColoredDigraph", [IsDigraph, IsList, IsList]);
DeclareOperation("DotSymmetricColoredDigraph", [IsDigraph, IsList, IsList]);

DeclareOperation("DotVertexLabelledDigraph", [IsDigraph]);

DeclareAttribute("DotPartialOrderDigraph", IsDigraph);
DeclareAttribute("DotPreorderDigraph", IsDigraph);

DeclareSynonym("DotQuasiorderDigraph", DotPreorderDigraph);

DeclareOperation("DotHighlightedDigraph", [IsDigraph, IsList]);
DeclareOperation("DotHighlightedDigraph",
                 [IsDigraph, IsList, IsString, IsString]);
DeclareOperation("DotHighlightedGraph", [IsDigraph, IsList]);
DeclareOperation("DotHighlightedGraph",
                 [IsDigraph, IsList, IsString, IsString]);
