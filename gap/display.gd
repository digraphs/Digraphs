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
DeclareOperation("DotVertexLabelledDigraph", [IsDigraph]);
DeclareAttribute("DotSymmetricDigraph", IsDigraph);
DeclareAttribute("DotPartialOrderDigraph", IsDigraph);
DeclareAttribute("DotPreorderDigraph", IsDigraph);
DeclareSynonym("DotQuasiorderDigraph", DotPreorderDigraph);
DeclareOperation("DotHighlightedDigraph", [IsDigraph, IsList]);
DeclareOperation("DotHighlightedDigraph",
                 [IsDigraph, IsList, IsString, IsString]);
