#############################################################################
##
##  display.gi
##  Copyright (C) 2014-24                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# TODO:
# * add graph6 string or whatever as a comment at the start of the string
# * check JupyterInterface Splash function
# * for edge colored non-digraphs, should ensure that the edge colors are
# symmetric, i.e. the same colors for x -> y and y -> x

#############################################################################
# Graphs and digraphs
#############################################################################

InstallOtherMethod(GraphvizDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
  local gv, x, y;
  gv := GraphvizDigraph("hgn");
  GraphvizSetAttr(gv, "node [shape=circle]");
  for x in DigraphVertices(D) do
    GraphvizAddNode(gv, x);
  od;
  for x in DigraphVertices(D) do
    for y in OutNeighboursOfVertexNC(D, x) do
      GraphvizAddEdge(gv, x, y);
    od;
  od;
  return gv;
end);

InstallOtherMethod(GraphvizGraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
  local gv, x, y;
  if not IsSymmetricDigraph(D) then
    ErrorNoReturn("the argument (a digraph) must be symmetric");
  fi;
  gv := GraphvizGraph("hgn");
  GraphvizSetAttr(gv, "node [shape=circle]");
  for x in DigraphVertices(D) do
    GraphvizAddNode(gv, x);
  od;
  for x in DigraphVertices(D) do
    for y in OutNeighboursOfVertexNC(D, x) do
      if x > y then
        GraphvizAddEdge(gv, x, y);
      fi;
    od;
  od;
  return gv;
end);

#############################################################################
# Vertex coloured graphs and digraphs
#############################################################################

InstallMethod(GraphvizVertexColoredDigraph, "for a digraph and a list",
[IsDigraph, IsList],
{D, colors} -> GraphvizSetNodeColors(GraphvizDigraph(D), colors));

InstallMethod(GraphvizVertexColoredGraph, "for a digraph and a list",
[IsDigraph, IsList],
# IsSymmetricDigraph checked by GraphvizGraph
{D, colors} -> GraphvizSetNodeColors(GraphvizGraph(D), colors));

#############################################################################
# Edge coloured graphs and digraphs
#############################################################################

# This function is here rather than graphviz b/c otherwise if D has multiple
# edges we can't reliably get the corresponding graphviz edge from the head and
# tail of the edge from gv.
BindGlobal("DIGRAPHS_ErrorIfNotEdgeColoring",
function(D, colors)
  local out, i;

  out := OutNeighbours(D);
  if Length(colors) <> Length(out) then
    ErrorFormatted("the 2nd argument (edge colors) must have ",
                   "the same number of entries as the 1st argument ",
                   "(a digraph) has nodes, expected {} but found {}",
                   Length(out),
                   Length(colors));
  fi;
  for i in [1 .. Length(colors)] do
    if not IsList(colors[i]) then
      ErrorFormatted("the 2nd argument (edge colors) must be ",
                     "a list of lists, found {} in position {}",
                     TNAM_OBJ(colors[i]),
                     i);
    elif Length(out[i]) <> Length(colors[i]) then
      ErrorFormatted("the 2nd argument (edge colors) must have ",
                     "the same shape as the out neighbours of the 1st ",
                     "argument (a digraph), in position {} expected ",
                     "a list of length {} but found list of length {}",
                     i,
                     Length(out[i]),
                     Length(colors[i]));
    fi;
    Perform(colors[i], ErrorIfNotValidColor);
  od;
end);

BindGlobal("DIGRAPHS_AddEdgesAndColorsNC",
function(D, gv, colors)
  local out, e, n, i;

  # This duplicates code in the GraphvizDigraph function because otherwise if D
  # has multiple edges we can't reliably get the corresponding graphviz edge
  # from the head and tail of the edge from gv.
  out := OutNeighbours(D);
  for n in DigraphVertices(D) do
    for i in [1 .. Length(out[n])] do
      if IsGraphvizDigraph(gv) or n > out[n][i] then
        e := GraphvizAddEdge(gv, n, out[n][i]);
        GraphvizSetAttr(e, "color", colors[n][i]);
      fi;
    od;
  od;
  return gv;
end);

InstallMethod(GraphvizEdgeColoredDigraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
function(D, colors)
  local gv;
  DIGRAPHS_ErrorIfNotEdgeColoring(D, colors);
  gv := GraphvizDigraph(NullDigraph(DigraphNrVertices(D)));
  return DIGRAPHS_AddEdgesAndColorsNC(D, gv, colors);
end);

InstallMethod(GraphvizEdgeColoredGraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
function(D, colors)
  local gv;
  if not IsSymmetricDigraph(D) then
    ErrorNoReturn("the argument (a digraph) must be symmetric");
  fi;
  DIGRAPHS_ErrorIfNotEdgeColoring(D, colors);
  gv := GraphvizGraph(NullDigraph(DigraphNrVertices(D)));
  return DIGRAPHS_AddEdgesAndColorsNC(D, gv, colors);
end);

#############################################################################
# Vertex and edge coloured graphs and digraphs
#############################################################################

InstallMethod(GraphvizColoredDigraph,
"for a digraph, list, and list",
[IsDigraph, IsList, IsList],
{D, n_colors, e_colors} -> GraphvizSetNodeColors(
                            GraphvizEdgeColoredDigraph(D, e_colors),
                            n_colors));

InstallMethod(GraphvizColoredGraph,
"for a digraph, list, and list",
[IsDigraph, IsList, IsList],
# IsSymmetricDigraph checked by GraphvizEdgeColoredGraph
{D, n_colors, e_colors} -> GraphvizSetNodeColors(
                            GraphvizEdgeColoredGraph(D, e_colors),
                            n_colors));

#############################################################################
# Vertex labelled graphs and digraphs
#############################################################################

InstallMethod(GraphvizVertexLabelledDigraph, "for a digraph",
[IsDigraph],
D -> GraphvizSetNodeLabels(GraphvizDigraph(D), DigraphVertexLabels(D)));

InstallMethod(GraphvizVertexLabelledGraph, "for a digraph",
[IsDigraph],
# symmetry checked in GraphvizGraph
D -> GraphvizSetNodeLabels(GraphvizGraph(D), DigraphVertexLabels(D)));

#############################################################################
# Partial and preorder digraphs
#############################################################################

InstallMethod(GraphvizPartialOrderDigraph, "for a partial order digraph",
[IsDigraph],
function(D)
  if not IsPartialOrderDigraph(D) then
    ErrorNoReturn("the argument (a digraph) must be a partial order");
  fi;
  D := DigraphMutableCopyIfMutable(D);
  return GraphvizDigraph(DigraphReflexiveTransitiveReduction(D));
end);

InstallMethod(GraphvizPreorderDigraph, "for a preorder digraph",
[IsDigraph],
function(D)
  local comps, gv, label, node, nodes, c, x, e;

  if not IsPreorderDigraph(D) then
    ErrorNoReturn("the argument (a digraph) must be a preorder");
  fi;

  # Quotient by the strongly connected components to get a partial order
  # D and draw this without loops or edges implied by transitivity.
  comps := DigraphStronglyConnectedComponents(D).comps;
  D     := DigraphMutableCopy(D);
  DigraphRemoveAllMultipleEdges(QuotientDigraph(D, comps));
  DigraphReflexiveTransitiveReduction(D);

  gv := GraphvizDigraph("graphname");
  GraphvizSetAttr(gv, "node [shape=\"Mrecord\"]");
  GraphvizSetAttr(gv, "height=\"0.5\"");
  GraphvizSetAttr(gv, "fixedsize=\"true\"");
  GraphvizSetAttr(gv, "ranksep=\"1\"");

  for c in [1 .. Length(comps)] do

    label := "\"";
    Append(label, String(comps[c][1]));
    for x in comps[c]{[2 .. Length(comps[c])]} do
      Append(label, "|");
      Append(label, String(x));
    od;
    Append(label, "\"");

    node := GraphvizAddNode(gv, c);
    GraphvizSetAttr(node, "label", label);
    GraphvizSetAttr(node, "width", Float(Length(comps[c]) / 2));
  od;

  nodes := GraphvizNodes(gv);
  for e in DigraphEdges(D) do
    GraphvizAddEdge(gv, nodes[e[1]], nodes[e[2]]);
  od;

  return gv;
end);

#############################################################################
# Highlighted subdigraphs
#############################################################################

BindGlobal("DIGRAPHS_GraphvizHighlight",
function(D, gv, hi_verts, hi, lo)
  local node, color, out, nodes, edge, v, i, j;

  if IsMultiDigraph(D) then
    ErrorNoReturn("the 1st argument (a digraph) must not have multiple edges");
  elif not IsSubset(DigraphVertices(D), hi_verts) then
    ErrorNoReturn("the 2nd argument (list) must consist of vertices ",
                  "of the 1st argument (a digraph)");
  fi;
  ErrorIfNotValidColor(hi);
  ErrorIfNotValidColor(lo);

  GraphvizSetAttr(gv, "shape", "circle");

  for v in DigraphVertices(D) do
    node := GraphvizAddNode(gv, v);
    if v in hi_verts then
      color := hi;
    else
      color := lo;
    fi;
    GraphvizSetAttr(node, "color", color);
  od;

  out   := OutNeighbours(D);
  nodes := GraphvizNodes(gv);

  for i in DigraphVertices(D) do
    for j in out[i] do
      if IsGraphvizDigraph(gv) or i > j then
        edge := GraphvizAddEdge(gv, nodes[i], nodes[j]);
        if i in hi_verts and j in hi_verts then
          color := hi;
        else
          color := lo;
        fi;
        GraphvizSetAttr(edge, "color", color);
      fi;
    od;
  od;

  return gv;
end);

InstallMethod(GraphvizHighlightedDigraph,
"for a digraph by out-neighbours, list, and two strings",
[IsDigraphByOutNeighboursRep, IsList, IsString, IsString],
{D, hi_verts, hi, lo} ->
DIGRAPHS_GraphvizHighlight(D, GraphvizDigraph(), hi_verts, hi, lo));

InstallMethod(GraphvizHighlightedDigraph, "for a digraph and list",
[IsDigraph, IsList],
{D, list} -> GraphvizHighlightedDigraph(D, list, "black", "grey"));

InstallMethod(GraphvizHighlightedGraph,
"for a digraph by out-neighbours, list, and two strings",
[IsDigraphByOutNeighboursRep, IsList, IsString, IsString],
function(D, hi_verts, hi, lo)
  if not IsSymmetricDigraph(D) then
    ErrorNoReturn("the argument (a digraph) must be symmetric");
  fi;
  return DIGRAPHS_GraphvizHighlight(D, GraphvizGraph(), hi_verts, hi, lo);
end);

InstallMethod(GraphvizHighlightedGraph, "for a digraph and list",
[IsDigraph, IsList],
# IsSymmetricDigraph checked in GraphvizHighlightedGraph
{D, list} -> GraphvizHighlightedGraph(D, list, "black", "grey"));
