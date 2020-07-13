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
DeclareOperation("DotVertexLabelledDigraph", [IsDigraph]);
DeclareAttribute("DotSymmetricDigraph", IsDigraph);
DeclareOperation("DotSymmetricColoredDigraph", [IsDigraph, IsList, IsList]);
DeclareAttribute("DotPartialOrderDigraph", IsDigraph);
DeclareAttribute("DotPreorderDigraph", IsDigraph);
DeclareSynonym("DotQuasiorderDigraph", DotPreorderDigraph);
DeclareOperation("DotHighlightedDigraph", [IsDigraph, IsList]);
DeclareOperation("DotHighlightedDigraph",
                 [IsDigraph, IsList, IsString, IsString]);
