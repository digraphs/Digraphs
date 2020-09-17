#############################################################################
##
##  display.gd
##  Copyright (C) 2017-19                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareAttribute("DotDigraph", IsDigraph);
DeclareOperation("DotColoredDigraph", [IsDigraph, IsList, IsList]);
DeclareOperation("DotVertexColoredDigraph", [IsDigraph, IsList]);
DeclareOperation("DotEdgeColoredDigraph", [IsDigraph, IsList]);
DeclareOperation("DotVertexLabelledDigraph", [IsDigraph]);
DeclareAttribute("DotSymmetricDigraph", IsDigraph);
DeclareOperation("DotSymmetricColoredDigraph", [IsDigraph, IsList, IsList]);
DeclareOperation("DotSymmetricVertexColoredDigraph", [IsDigraph, IsList]);
DeclareOperation("DotSymmetricEdgeColoredDigraph", [IsDigraph, IsList]);
DeclareAttribute("DotPartialOrderDigraph", IsDigraph);
DeclareAttribute("DotPreorderDigraph", IsDigraph);
DeclareSynonym("DotQuasiorderDigraph", DotPreorderDigraph);
DeclareOperation("DotHighlightedDigraph", [IsDigraph, IsList]);
DeclareOperation("DotHighlightedDigraph",
                 [IsDigraph, IsList, IsString, IsString]);
