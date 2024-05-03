#############################################################################
##
##  deprecated.gi
##  Copyright (C) 2024                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

BindGlobal("_PrintDeprecated", function(old, arg...)
  Info(InfoWarning, 1, "`", old, "` is deprecated and will be removed in v3",
       " use `", Concatenation(List(arg, AsString)), "` instead!");
end);

InstallMethod(DotDigraph, "for a digraph", [IsDigraph],
function(D)
  _PrintDeprecated("DotDigraph", "GraphvizDigraph");
  return AsString(GraphvizDigraph(D));
end);

InstallMethod(DotSymmetricDigraph, "for a digraph", [IsDigraph],
function(D)
  _PrintDeprecated("DotSymmetricDigraph", "GraphvizGraph");
  return AsString(GraphvizGraph(D));
end);

InstallMethod(DotSymmetricVertexColoredDigraph,
"for a digraph and list of colors",
[IsDigraph, IsHomogeneousList],
function(D, colors)
  _PrintDeprecated("DotSymmetricVertexColoredDigraph",
                   "GraphvizVertexColoredGraph");
  return AsString(GraphvizVertexColoredGraph(D, colors));
end);

InstallMethod(DotVertexColoredDigraph, "for a digraph and a list",
[IsDigraph, IsList],
function(D, colors)
  _PrintDeprecated("DotVertexColoredDigraph",
                   "GraphvizVertexColoredDigraph");
  return AsString(GraphvizVertexColoredDigraph(D, colors));
end);

InstallMethod(DotSymmetricEdgeColoredDigraph,
"for a digraph and list of colors",
[IsDigraph, IsHomogeneousList],
function(D, colors)
  _PrintDeprecated("DotSymmetricEdgeColoredDigraph",
                   "GraphvizEdgeColoredGraph");
  return AsString(GraphvizEdgeColoredGraph(D, colors));
end);

InstallMethod(DotEdgeColoredDigraph, "for a digraph and a list",
[IsDigraph, IsList],
function(D, colors)
  _PrintDeprecated("DotEdgeColoredDigraph",
                   "GraphvizEdgeColoredDigraph");
  return AsString(GraphvizEdgeColoredDigraph(D, colors));
end);

InstallMethod(DotSymmetricColoredDigraph,
"for a digraph, vertex colors, and edge colors",
[IsDigraph, IsHomogeneousList, IsHomogeneousList],
function(D, n_colors, e_colors)
  _PrintDeprecated("DotSymmetricColoredDigraph",
                   "GraphvizColoredGraph");
  return AsString(GraphvizColoredGraph(D, n_colors, e_colors));
end);

InstallMethod(DotColoredDigraph,
"for a digraph, vertex colors, and edge colors",
[IsDigraph, IsHomogeneousList, IsHomogeneousList],
function(D, n_colors, e_colors)
  _PrintDeprecated("DotColoredDigraph",
                   "GraphvizColoredDigraph");
  return AsString(GraphvizColoredDigraph(D, n_colors, e_colors));
end);

InstallMethod(DotVertexLabelledDigraph, "for a digraph", [IsDigraph],
function(D)
  _PrintDeprecated("DotVertexLabelledDigraph",
                   "GraphvizVertexLabelledDigraph");
  return AsString(GraphvizVertexLabelledDigraph(D));
end);

InstallMethod(DotPartialOrderDigraph, "for a digraph", [IsDigraph],
function(D)
  _PrintDeprecated("DotPartialOrderDigraph",
                   "GraphvizPartialOrderDigraph");
  return AsString(GraphvizPartialOrderDigraph(D));
end);

InstallMethod(DotPreorderDigraph, "for a digraph", [IsDigraph],
function(D)
  _PrintDeprecated("DotPreorderDigraph",
                   "GraphvizPreorderDigraph");
  return AsString(GraphvizPreorderDigraph(D));
end);

InstallMethod(DotHighlightedDigraph,
"for a digraph, list, and two strings",
[IsDigraph, IsList, IsString, IsString],
function(D, hi_verts, hi, lo)
  _PrintDeprecated("DotHighlightedDigraph",
                   "GraphvizHighlightedDigraph");
  return AsString(GraphvizHighlightedDigraph(D, hi_verts, hi, lo));
end);

InstallMethod(DotHighlightedDigraph, "for a digraph and list",
[IsDigraph, IsList],
function(D, list)
  _PrintDeprecated("DotHighlightedDigraph",
                   "GraphvizHighlightedDigraph");
  return AsString(GraphvizHighlightedDigraph(D, list, "black", "grey"));
end);
