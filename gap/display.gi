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

  graph := GV_Digraph("hgn");
  GV_SetAttr(graph, "node [shape=\"circle\"]");

  for i in DigraphVertices(D) do
    node := GV_AddNode(graph, StringFormatted("{}", i));
    for func in node_funcs do
      func(graph, node, i);
    od;
  od;

  nodes := GV_Nodes(graph);
  out := OutNeighbours(D);
  for i in DigraphVertices(D) do
    l := Length(out[i]);
    for j in [1 .. l] do
      tail := nodes[String(i)];
      head := nodes[String(out[i][j])];
      edge := GV_AddEdge(graph, tail, head);
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

InstallMethod(GV_DotDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
D -> GV_DIGRAPHS_DotDigraph(D, [], []));

InstallMethod(DotDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
D -> GV_String(GV_DotDigraph(D)));

InstallMethod(GV_DotColoredDigraph, "for a digraph by out-neighbours and two lists",
[IsDigraphByOutNeighboursRep, IsList, IsList],
function(D, vert, edge)
  local vert_func, edge_func;
  if GV_DIGRAPHS_ValidVertColors(D, vert) and GV_DIGRAPHS_ValidEdgeColors(D, edge) then
    vert_func := {g, n, i} -> GV_SetAttrs(n, rec(color := vert[i], style := "filled"));
    edge_func := {g, e, i, j} -> GV_SetAttrs(e, rec(color := edge[i][j]));
    return GV_DIGRAPHS_DotDigraph(D, [vert_func], [edge_func]);
  fi;
end);

InstallMethod(DotColoredDigraph, "for a digraph by out-neighbours and two lists",
[IsDigraphByOutNeighboursRep, IsList, IsList],
{D, vert, edge} -> GV_String(GV_DotColoredDigraph(D, vert, edge)));

InstallMethod(GV_DotVertexColoredDigraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
function(D, vert)
  local func;
  if GV_DIGRAPHS_ValidVertColors(D, vert) then
    func := {g, n, i} -> GV_SetAttrs(n, rec(color := vert[i], style := "filled"));
    return GV_DIGRAPHS_DotDigraph(D, [func], []);
  fi;
end);

InstallMethod(DotVertexColoredDigraph, 
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
{D, vert} -> GV_String(GV_DotVertexColoredDigraph(D, vert)));

InstallMethod(GV_DotEdgeColoredDigraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
function(D, edge)
  local func;
  if GV_DIGRAPHS_ValidEdgeColors(D, edge) then
    func := {g, e, i, j} -> GV_SetAttrs(e, rec(color := edge[i][j]));
    return GV_DIGRAPHS_DotDigraph(D, [], [func]);
  fi;
end);

InstallMethod(DotEdgeColoredDigraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
{D, edge} -> GV_String(GV_DotEdgeColoredDigraph(D, edge)));

InstallMethod(GV_DotVertexLabelledDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
  local func;
  func := {g, n, i} -> GV_SetAttrs(n, rec(label := DigraphVertexLabel(D, i)));
  return GV_DIGRAPHS_DotDigraph(D, [func], []);
end);

InstallMethod(DotVertexLabelledDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
{D} -> GV_String(GV_DotVertexLabelledDigraph(D)));


BindGlobal("GV_DIGRAPHS_DotSymmetricDigraph",
function(D, node_funcs, edge_funcs)
  local graph, node, nodes, edge, out, n1, n2, str, i, j, func;
  if not IsSymmetricDigraph(D) then
    ErrorNoReturn("the argument <D> must be a symmetric digraph,");
  fi;

  out := OutNeighbours(D);
  
  graph := GV_Graph("hgn");
  GV_SetAttr(graph, "node [shape=\"circle\"]");
  for i in DigraphVertices(D) do
    node := GV_AddNode(graph, StringFormatted("{}", i));
    for func in node_funcs do
      func(graph, node, i);
    od;
  od;

  nodes := GV_Nodes(graph);
  for i in DigraphVertices(D) do
    for j in [1 .. Length(out[i])] do
      if out[i][j] >= i then
        n1 := nodes[String(i)];
        n2 := nodes[String(out[i][j])];
        edge := GV_AddEdge(graph, n1, n2);
        for func in edge_funcs do
          func(graph, edge, i, j);
        od;
      fi;
    od;
  od;
  return graph;
end);

InstallMethod(GV_DotSymmetricDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
D -> GV_DIGRAPHS_DotSymmetricDigraph(D, [], []));

InstallMethod(DotSymmetricDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
D -> GV_String(GV_DotSymmetricDigraph(D)));

InstallMethod(GV_DotSymmetricColoredDigraph,
"for a digraph by out-neighbours and two lists",
[IsDigraphByOutNeighboursRep, IsList, IsList],
function(D, vert, edge)
  local vert_func, edge_func;
  if GV_DIGRAPHS_ValidVertColors(D, vert) and GV_DIGRAPHS_ValidEdgeColors(D, edge) then
    vert_func := {g, n, i} -> GV_SetAttrs(n, rec(color := vert[i], style := "filled"));
    edge_func := {g, e, i, j} -> GV_SetAttrs(e, rec(color := edge[i][j]));
    return GV_DIGRAPHS_DotSymmetricDigraph(D, [vert_func], [edge_func]);
  fi;
end);

InstallMethod(GV_DotSymmetricVertexColoredDigraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
function(D, vert)
  local func;
  if GV_DIGRAPHS_ValidVertColors(D, vert) then
    func := {g, n, i} -> GV_SetAttrs(n, rec(color := vert[i], style := "filled"));
    return GV_DIGRAPHS_DotSymmetricDigraph(D, [func], []);
  fi;
end);

InstallMethod(GV_DotSymmetricEdgeColoredDigraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
function(D, edge)
  local func;
  if GV_DIGRAPHS_ValidEdgeColors(D, edge) then
    func := {g, e, i, j} -> GV_SetAttrs(e, rec(color := edge[i][j]));
    return GV_DIGRAPHS_DotSymmetricDigraph(D, [], [func]);
  fi;
end);

InstallMethod(DotSymmetricEdgeColoredDigraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
{D, edge} -> GV_String(GV_DotSymmetricEdgeColoredDigraph(D, edge)));

DeclareOperation("GV_Splash", [IsGVGraph, IsRecord]);
InstallMethod(GV_Splash, "for a graphviz graph and a record",
[IsGVGraph, IsRecord],
function(g, r)
  Splash(GV_String(g), r); 
  return; 
end);

# CR's code

InstallMethod(GV_DotPartialOrderDigraph, "for a partial order digraph",
[IsDigraph],
function(D)
  if not IsPartialOrderDigraph(D) then
    ErrorNoReturn("the argument <D> must be a partial order digraph,");
  fi;
  D := DigraphMutableCopyIfMutable(D);
  return GV_DotDigraph(DigraphReflexiveTransitiveReduction(D));
end);

InstallMethod(DotPartialOrderDigraph, "for a partial order digraph",
[IsDigraph],
{D} -> GV_String(GV_DotPartialOrderDigraph(D)));

InstallMethod(GV_DotPreorderDigraph, "for a preorder digraph",
[IsDigraph],
function(D)
  local comps, quo, red, str, c, x, e, node, graph, label, head, tail, nodes;
  if not IsPreorderDigraph(D) then
    ErrorNoReturn("the argument <D> must be a preorder digraph,");
  fi;

  # Quotient by the strongly connected components to get a partial order
  # D and draw this without loops or edges implied by transitivity.
  D      := DigraphMutableCopyIfMutable(D);
  comps  := DigraphStronglyConnectedComponents(D).comps;
  quo    := DigraphRemoveAllMultipleEdges(QuotientDigraph(D, comps));
  red    := DigraphReflexiveTransitiveReduction(quo);

  graph := GV_Digraph("graphname");
  GV_SetAttr(graph, "node [shape=\"Mrecord\"]");
  GV_SetAttr(graph, "height=\"0.5\"");
  GV_SetAttr(graph, "fixedsize=\"true\"");
  GV_SetAttr(graph, "ranksep=\"1\"");

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

    node := GV_AddNode(graph, String(c));
    GV_SetAttr(node, "label", label);
    GV_SetAttr(node, "width", String(Float(Length(comps[c]) / 2)));
  od;

  # Add the edges of the quotient D.
  nodes := GV_Nodes(graph);
  for e in DigraphEdges(red) do
    tail := nodes[String(e[1])];
    head := nodes[String(e[2])];
    GV_AddEdge(graph, tail, head);
  od;

  return graph;
end);

InstallMethod(DotPreorderDigraph, "for a preorder digraph",
[IsDigraph],
{D} -> GV_String(GV_DotPreorderDigraph(D)));


InstallMethod(GV_DotHighlightedDigraph, "for a digraph and list",
[IsDigraph, IsList],
{D, list} -> GV_DotHighlightedDigraph(D, list, "black", "grey"));

InstallMethod(DotHighlightedDigraph, "for a digraph and list",
[IsDigraph, IsList],
{D, list} -> GV_String(GV_DotHighlightedDigraph(D, list, "black", "grey")));

InstallMethod(GV_DotHighlightedDigraph,
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

  graph := GV_Digraph("hgn");

  for i in lowverts do
    node := GV_AddNode(graph, String(i));
    GV_SetAttrs(node, rec( shape := "circle", color := lowcolour));
  od;


  for i in highverts do
    node := GV_AddNode(graph, String(i));
    GV_SetAttrs(node, rec( shape := "circle", color := highcolour));
  od;

  nodes := GV_Nodes(graph);
  for i in lowverts do
    for j in out[i] do
      edge := GV_AddEdge(graph, nodes[String(i)], nodes[String(j)]);
      GV_SetAttr(edge, "color", lowcolour);
    od;
  od;

  for i in highverts do
    for j in out[i] do
      edge := GV_AddEdge(graph, nodes[String(i)], nodes[String(j)]);
      GV_SetAttr(edge, "color", highcolour);
      if j in lowverts then
        GV_SetAttr(edge, "color", lowcolour);
      fi;
    od;
  od;

  return graph;
end);


InstallMethod(DotHighlightedDigraph,
"for a digraph by out-neighbours, list, and two strings",
[IsDigraphByOutNeighboursRep, IsList, IsString, IsString],
{D, highverts, highcolour, lowcolour} ->
  GV_String(GV_DotHighlightedDigraph(D, highverts, highcolour, lowcolour)));