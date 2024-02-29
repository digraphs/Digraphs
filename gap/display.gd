############################################################################
##
##  display.gd
##  Copyright (C) 2017-19                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareAttribute("GV_DotDigraph", IsDigraph);
DeclareOperation("GV_DotColoredDigraph", [IsDigraph, IsList, IsList]);
DeclareOperation("GV_DotVertexColoredDigraph", [IsDigraph, IsList]);
DeclareOperation("GV_DotEdgeColoredDigraph", [IsDigraph, IsList]);
DeclareOperation("GV_DotVertexLabelledDigraph", [IsDigraph]);
DeclareAttribute("GV_DotSymmetricDigraph", IsDigraph);
DeclareOperation("GV_DotSymmetricColoredDigraph", [IsDigraph, IsList, IsList]);
DeclareOperation("GV_DotSymmetricVertexColoredDigraph", [IsDigraph, IsList]);
DeclareOperation("GV_DotSymmetricEdgeColoredDigraph", [IsDigraph, IsList]);
DeclareAttribute("GV_DotPartialOrderDigraph", IsDigraph);
DeclareAttribute("GV_DotPreorderDigraph", IsDigraph);
DeclareSynonym("GV_DotQuasiorderDigraph", GV_DotPreorderDigraph);
DeclareOperation("GV_DotHighlightedDigraph", [IsDigraph, IsList]);
DeclareOperation("GV_DotHighlightedDigraph",
                 [IsDigraph, IsList, IsString, IsString]);

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

