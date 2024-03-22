#############################################################################
##
##  display.gi
##  Copyright (C) 2014-21                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
# AN's code, adapted by WW

BindGlobal("GV_DIGRAPHS_DotDigraph",
function(D, node_funcs, edge_funcs)
  local out, nodes, tail, head, node, edge, graph, i, func, j, l;

  graph := GraphvizDigraph("hgn");
  GraphvizSetAttr(graph, "node [shape=\"circle\"]");

  for i in DigraphVertices(D) do
    node := GraphvizAddNode(graph, StringFormatted("{}", i));
    for func in node_funcs do
      func(graph, node, i);
    od;
  od;

  nodes := GraphvizNodes(graph);
  out := OutNeighbours(D);
  for i in DigraphVertices(D) do
    l := Length(out[i]);
    for j in [1 .. l] do
      tail := nodes[String(i)];
      head := nodes[String(out[i][j])];
      edge := GraphvizAddEdge(graph, tail, head);
      for func in edge_funcs do
        func(graph, edge, i, j);
      od;
    od;
  od;
  return graph;
end);

BindGlobal("GV_DIGRAPHS_ValidRGBValue",
function(str)
  local l, chars, x, i;
  l := Length(str);
  x := 0;
  chars := "0123456789ABCDEFabcdef";
  if l = 7 then
    if str[1] = '#' then
      for i in [2 .. l] do
        if str[i] in chars then
            x := x + 1;
        fi;
      od;
    fi;
  fi;
  if x = (l - 1) then
    return true;
  else
    return false;
  fi;
end);

BindGlobal("GV_DIGRAPHS_GraphvizColorsList", fail);

BindGlobal("GV_DIGRAPHS_GraphvizColors",
function()
  local f;
  if GV_DIGRAPHS_GraphvizColorsList = fail then
    f := IO_File(Concatenation(DIGRAPHS_Dir(), "/data/colors.p"));
    MakeReadWriteGlobal("GV_DIGRAPHS_GraphvizColorsList");
    GV_DIGRAPHS_GraphvizColorsList := IO_Unpickle(f);
    MakeReadOnlyGlobal("GV_DIGRAPHS_GraphvizColorsList");
    IO_Close(f);
  fi;
  return GV_DIGRAPHS_GraphvizColorsList;
end);

BindGlobal("GV_DIGRAPHS_ValidVertColors",
function(D, verts)
  local v, sum, colors, col;
  v := DigraphVertices(D);
  sum := 0;
  if Length(verts) <> Length(v) then
    ErrorNoReturn("the number of vertex colors must be the same as the number",
    " of vertices, expected ", Length(v), " but found ", Length(verts), "");
  fi;
  colors := GV_DIGRAPHS_GraphvizColors();
  if Length(verts) = Length(v) then
    for col in verts do
      if not IsString(col) then
        ErrorNoReturn("expected a string");
      elif GV_DIGRAPHS_ValidRGBValue(col) = false and
          (col in colors) = false then
        ErrorNoReturn("expected RGB Value or valid color name as defined",
        " by GraphViz 2.44.1 X11 Color Scheme",
        " http://graphviz.org/doc/info/colors.html");
      else
        sum := sum + 1;
      fi;
    od;
    if sum = Length(verts) then
      return true;
    fi;
  fi;
end);

BindGlobal("GV_DIGRAPHS_ValidEdgeColors",
function(D, edge)
  local out, l, counter, sum, colors, v, col;
  out := OutNeighbours(D);
  l := Length(edge);
  counter := 0;
  sum := 0;
  colors := GV_DIGRAPHS_GraphvizColors();
  if Length(edge) <> Length(out) then
    ErrorNoReturn("the list of edge colors needs to have the",
    " same shape as the out-neighbours of the digraph");
  else
    for v in [1 .. l] do
      sum := 0;
      if Length(out[v]) <> Length(edge[v]) then
        ErrorNoReturn("the list of edge colors needs to have the",
        " same shape as the out-neighbours of the digraph");
      else
        for col in edge[v] do
          if not IsString(col) then
            ErrorNoReturn("expected a string");
          elif GV_DIGRAPHS_ValidRGBValue(col) = false and
              (col in colors) = false then
            ErrorNoReturn("expected RGB Value or valid color name as defined",
            " by GraphViz 2.44.1 X11 Color Scheme",
            " http://graphviz.org/doc/info/colors.html");
          else
            sum := sum + 1;
          fi;
        od;
        if sum = Length(edge[v]) then
          counter := counter + 1;
        fi;
      fi;
    od;
    if counter = Length(edge) then
      return true;
    fi;
  fi;
end);

InstallMethod(GraphvizDotDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
D -> GV_DIGRAPHS_DotDigraph(D, [], []));

InstallMethod(DotDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
D -> AsString(GraphvizDotDigraph(D)));

InstallMethod(GraphvizDotColoredDigraph,
"for a digraph by out-neighbours and two lists",
[IsDigraphByOutNeighboursRep, IsList, IsList],
function(D, vert, edge)
  local vert_func, cond, edge_func;
  cond := GV_DIGRAPHS_ValidVertColors(D, vert);
  cond := cond and GV_DIGRAPHS_ValidEdgeColors(D, edge);
  if cond then
    vert_func := {g, n, i} -> GraphvizSetAttrs(n, rec(color := vert[i],
                                                      style := "filled"));
    edge_func := {g, e, i, j} -> GraphvizSetAttrs(e, rec(color := edge[i][j]));
    return GV_DIGRAPHS_DotDigraph(D, [vert_func], [edge_func]);
  fi;
end);

InstallMethod(DotColoredDigraph, "for a digraph by out-neighbours and two lists",
[IsDigraphByOutNeighboursRep, IsList, IsList],
{D, vert, edge} -> AsString(GraphvizDotColoredDigraph(D, vert, edge)));

InstallMethod(GraphvizDotVertexColoredDigraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
function(D, vert)
  local func;
  if GV_DIGRAPHS_ValidVertColors(D, vert) then
    func := {g, n, i} -> GraphvizSetAttrs(n, rec(color := vert[i],
                                                 style := "filled"));
    return GV_DIGRAPHS_DotDigraph(D, [func], []);
  fi;
end);

InstallMethod(DotVertexColoredDigraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
{D, vert} -> AsString(GraphvizDotVertexColoredDigraph(D, vert)));

InstallMethod(GraphvizDotEdgeColoredDigraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
function(D, edge)
  local func;
  if GV_DIGRAPHS_ValidEdgeColors(D, edge) then
    func := {g, e, i, j} -> GraphvizSetAttrs(e, rec(color := edge[i][j]));
    return GV_DIGRAPHS_DotDigraph(D, [], [func]);
  fi;
end);

InstallMethod(DotEdgeColoredDigraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
{D, edge} -> AsString(GraphvizDotEdgeColoredDigraph(D, edge)));

InstallMethod(GraphvizDotVertexLabelledDigraph,
"for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
  local func;
  func := {g, n, i} -> GraphvizSetAttrs(n, rec(label :=
                                               DigraphVertexLabel(D, i)));
    return GV_DIGRAPHS_DotDigraph(D, [func], []);
end);

InstallMethod(DotVertexLabelledDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
{D} -> AsString(GraphvizDotVertexLabelledDigraph(D)));

BindGlobal("GV_DIGRAPHS_DotSymmetricDigraph",
function(D, node_funcs, edge_funcs)
  local graph, node, nodes, edge, out, n1, n2, i, j, func;
  if not IsSymmetricDigraph(D) then
    ErrorNoReturn("the argument <D> must be a symmetric digraph,");
  fi;

  out := OutNeighbours(D);

  graph := GraphvizGraph("hgn");
  GraphvizSetAttr(graph, "node [shape=\"circle\"]");
  for i in DigraphVertices(D) do
    node := GraphvizAddNode(graph, StringFormatted("{}", i));
    for func in node_funcs do
      func(graph, node, i);
    od;
  od;

  nodes := GraphvizNodes(graph);
  for i in DigraphVertices(D) do
    for j in [1 .. Length(out[i])] do
      if out[i][j] >= i then
        n1 := nodes[String(i)];
        n2 := nodes[String(out[i][j])];
        edge := GraphvizAddEdge(graph, n1, n2);
        for func in edge_funcs do
          func(graph, edge, i, j);
        od;
      fi;
    od;
  od;
  return graph;
end);

InstallMethod(GraphvizDotSymmetricDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
D -> GV_DIGRAPHS_DotSymmetricDigraph(D, [], []));

InstallMethod(DotSymmetricDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
D -> AsString(GraphvizDotSymmetricDigraph(D)));

InstallMethod(GraphvizDotSymmetricColoredDigraph,
"for a digraph by out-neighbours and two lists",
[IsDigraphByOutNeighboursRep, IsList, IsList],
function(D, vert, edge)
  local vert_func, cond, edge_func;
  cond := GV_DIGRAPHS_ValidVertColors(D, vert);
  cond := cond and GV_DIGRAPHS_ValidEdgeColors(D, edge);
  if cond then
    vert_func := {g, n, i} -> GraphvizSetAttrs(n, rec(color := vert[i],
                                                      style := "filled"));
    edge_func := {g, e, i, j} -> GraphvizSetAttrs(e, rec(color := edge[i][j]));
    return GV_DIGRAPHS_DotSymmetricDigraph(D, [vert_func], [edge_func]);
  fi;
end);

InstallMethod(GraphvizDotSymmetricVertexColoredDigraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
function(D, vert)
  local func;
  if GV_DIGRAPHS_ValidVertColors(D, vert) then
    func := {g, n, i} -> GraphvizSetAttrs(n, rec(color := vert[i],
                                                 style := "filled"));
    return GV_DIGRAPHS_DotSymmetricDigraph(D, [func], []);
  fi;
end);

InstallMethod(GraphvizDotSymmetricEdgeColoredDigraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
function(D, edge)
  local func;
  if GV_DIGRAPHS_ValidEdgeColors(D, edge) then
    func := {g, e, i, j} -> GraphvizSetAttrs(e, rec(color := edge[i][j]));
    return GV_DIGRAPHS_DotSymmetricDigraph(D, [], [func]);
  fi;
end);

InstallMethod(DotSymmetricEdgeColoredDigraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
{D, edge} -> AsString(GraphvizDotSymmetricEdgeColoredDigraph(D, edge)));

# CR's code

InstallMethod(GraphvizDotPartialOrderDigraph, "for a partial order digraph",
[IsDigraph],
function(D)
  if not IsPartialOrderDigraph(D) then
    ErrorNoReturn("the argument <D> must be a partial order digraph,");
  fi;
  D := DigraphMutableCopyIfMutable(D);
  return GraphvizDotDigraph(DigraphReflexiveTransitiveReduction(D));
end);

InstallMethod(DotPartialOrderDigraph, "for a partial order digraph",
[IsDigraph],
{D} -> AsString(GraphvizDotPartialOrderDigraph(D)));

InstallMethod(GraphvizDotPreorderDigraph, "for a preorder digraph",
[IsDigraph],
function(D)
  local comps, quo, red, c, x, e, node, graph, label, head, tail, nodes;
  if not IsPreorderDigraph(D) then
    ErrorNoReturn("the argument <D> must be a preorder digraph,");
  fi;

  # Quotient by the strongly connected components to get a partial order
  # D and draw this without loops or edges implied by transitivity.
  D      := DigraphMutableCopyIfMutable(D);
  comps  := DigraphStronglyConnectedComponents(D).comps;
  quo    := DigraphRemoveAllMultipleEdges(QuotientDigraph(D, comps));
  red    := DigraphReflexiveTransitiveReduction(quo);

  graph := GraphvizDigraph("graphname");
  GraphvizSetAttr(graph, "node [shape=\"Mrecord\"]");
  GraphvizSetAttr(graph, "height=\"0.5\"");
  GraphvizSetAttr(graph, "fixedsize=\"true\"");
  GraphvizSetAttr(graph, "ranksep=\"1\"");

  # Each vertex of the quotient D is labelled by its preimage.
  for c in [1 .. Length(comps)] do

    # create node w/ label
    label := "\"";
    Append(label, String(comps[c][1]));
    for x in comps[c]{[2 .. Length(comps[c])]} do
      Append(label, "|");
      Append(label, String(x));
    od;
    Append(label, "\"");

    node := GraphvizAddNode(graph, String(c));
    GraphvizSetAttr(node, "label", label);
    GraphvizSetAttr(node, "width", String(Float(Length(comps[c]) / 2)));
  od;

  # Add the edges of the quotient D.
  nodes := GraphvizNodes(graph);
  for e in DigraphEdges(red) do
    tail := nodes[String(e[1])];
    head := nodes[String(e[2])];
    GraphvizAddEdge(graph, tail, head);
  od;

  return graph;
end);

InstallMethod(DotPreorderDigraph, "for a preorder digraph",
[IsDigraph],
{D} -> AsString(GraphvizDotPreorderDigraph(D)));

InstallMethod(GraphvizDotHighlightedDigraph, "for a digraph and list",
[IsDigraph, IsList],
{D, list} -> GraphvizDotHighlightedDigraph(D, list, "black", "grey"));

InstallMethod(DotHighlightedDigraph, "for a digraph and list",
[IsDigraph, IsList],
{D, list} -> AsString(GraphvizDotHighlightedDigraph(D, list, "black", "grey")));

InstallMethod(GraphvizDotHighlightedDigraph,
"for a digraph by out-neighbours, list, and two strings",
[IsDigraphByOutNeighboursRep, IsList, IsString, IsString],
function(D, highverts, highcolour, lowcolour)
  local lowverts, graph, node, edge, nodes, out, i, j;

  if not IsSubset(DigraphVertices(D), highverts) then
    ErrorNoReturn("the 2nd argument <highverts> must be a list of vertices ",
                  "of the 1st argument <D>,");
  elif IsEmpty(highcolour) then
    ErrorNoReturn("the 3rd argument <highcolour> must be a string ",
                  "containing the name of a colour,");
  elif IsEmpty(lowcolour) then
    ErrorNoReturn("the 4th argument <lowcolour> must be a string ",
                  "containing the name of a colour,");
  fi;

  lowverts  := Difference(DigraphVertices(D), highverts);
  out       := OutNeighbours(D);

  graph := GraphvizDigraph("hgn");

  for i in lowverts do
    node := GraphvizAddNode(graph, String(i));
    GraphvizSetAttrs(node, rec(shape := "circle", color := lowcolour));
  od;

  for i in highverts do
    node := GraphvizAddNode(graph, String(i));
    GraphvizSetAttrs(node, rec(shape := "circle", color := highcolour));
  od;

  nodes := GraphvizNodes(graph);
  for i in lowverts do
    for j in out[i] do
      edge := GraphvizAddEdge(graph, nodes[String(i)], nodes[String(j)]);
      GraphvizSetAttr(edge, "color", lowcolour);
    od;
  od;

  for i in highverts do
    for j in out[i] do
      edge := GraphvizAddEdge(graph, nodes[String(i)], nodes[String(j)]);
      GraphvizSetAttr(edge, "color", highcolour);
      if j in lowverts then
        GraphvizSetAttr(edge, "color", lowcolour);
      fi;
    od;
  od;

  return graph;
end);

InstallMethod(DotHighlightedDigraph,
"for a digraph by out-neighbours, list, and two strings",
[IsDigraphByOutNeighboursRep, IsList, IsString, IsString],
{D, highverts, highcolour, lowcolour} ->
  AsString(GraphvizDotHighlightedDigraph(D, highverts, highcolour, lowcolour)));
