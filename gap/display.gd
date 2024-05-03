############################################################################
##
##  display.gd
##  Copyright (C) 2017-19                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

#############################################################################
# Graphs and digraphs
#############################################################################

DeclareOperation("GraphvizDigraph", [IsDigraph]);
DeclareOperation("GraphvizGraph", [IsDigraph]);

#############################################################################
# Vertex coloured graphs and digraphs
#############################################################################

DeclareOperation("GraphvizVertexColoredDigraph", [IsDigraph, IsList]);
DeclareOperation("GraphvizVertexColoredGraph", [IsDigraph, IsList]);

#############################################################################
# Edge coloured graphs and digraphs
#############################################################################

DeclareOperation("GraphvizEdgeColoredDigraph", [IsDigraph, IsList]);
DeclareOperation("GraphvizEdgeColoredGraph", [IsDigraph, IsList]);

#############################################################################
# Vertex and edge coloured graphs and digraphs
#############################################################################

DeclareOperation("GraphvizColoredDigraph", [IsDigraph, IsList, IsList]);
DeclareOperation("GraphvizColoredGraph", [IsDigraph, IsList, IsList]);

#############################################################################
# Vertex labelled graphs and digraphs
#############################################################################

DeclareOperation("GraphvizVertexLabelledDigraph", [IsDigraph]);
DeclareOperation("GraphvizVertexLabelledGraph", [IsDigraph]);

#############################################################################
# Partial and preorder digraphs
#############################################################################

DeclareAttribute("GraphvizPartialOrderDigraph", IsDigraph);
DeclareAttribute("GraphvizPreorderDigraph", IsDigraph);

DeclareSynonym("GraphvizQuasiorderDigraph", GraphvizPreorderDigraph);

#############################################################################
# Highlighted subdigraphs
#############################################################################

DeclareOperation("GraphvizHighlightedDigraph", [IsDigraph, IsList]);
DeclareOperation("GraphvizHighlightedDigraph",
                 [IsDigraph, IsList, IsString, IsString]);
DeclareOperation("GraphvizHighlightedGraph", [IsDigraph, IsList]);
DeclareOperation("GraphvizHighlightedGraph",
                 [IsDigraph, IsList, IsString, IsString]);
