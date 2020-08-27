#############################################################################
##
##  display.gi
##  Copyright (C) 2014-19                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
# TO DO Uncomment lines containing StringFormatted when
# Digraphs requires gap-4.10.0
# and delete the duplicate code
# AN's code, adapted by WW

BindGlobal("DIGRAPHS_DotDigraph",
function(D, node_funcs, edge_funcs)
  local str, out, i, func, j, k, l;
  str   := "//dot\n";
  Append(str, "digraph hgn{\n");
  Append(str, "node [shape=circle]\n");
  for i in DigraphVertices(D) do
    # Append(str, StringFormatted("{}", i));
    # This line can be replaced with the above commented one when the required version is 4.10.0
    Append(str, String(i));
    for func in node_funcs do
      Append(str, func(i));
    od;
    Append(str, "\n");
  od;
  out := OutNeighbours(D);
  for i in DigraphVertices(D) do
    l := Length(out[i]);
    for j in [1..l] do
      # Append(str, StringFormatted("{} -> {}", i, j));
      # This line can be replaced with the above commented one when the required version is 4.10.0
      Append(str, String(i));
      Append(str, " -> ");
      Append(str, String(out[i][j]));
      for func in edge_funcs do
        Append(str, func(i, j));
      od;
      Append(str, "\n");
    od;
  od;
  Append(str, "}\n");
  return str;
end);

BindGlobal("DIGRAPHS_ValidRGBValue",
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
  if x = (l-1) then
    return true;
  else
    return false;
  fi;
end);


BindGlobal("DIGRAPHS_ValidVertColors",
function(D, verts)
  local v, col, colors, f, filename, Dir;
  v := DigraphVertices(D);
  Dir := DIGRAPHS_Dir();
  filename := Concatenation(Dir, "/data/colors.p");
  f := IO_File(filename);
  colors := IO_Unpickle(f);
  if Length(verts) <> Length(v) then
    ErrorNoReturn("the number of vertex colors must be the same as the number of vertices, expected ",
    Length(v), " but found ", Length(verts), "");
  fi;
  if Length(verts) = Length(v) then  
    for col in verts do
      if not IsString(col) then
        ErrorNoReturn("expected a string");
      elif DIGRAPHS_ValidRGBValue(col) = false and (col in colors) = false then
        ErrorNoReturn("expected RGB Value or valid color name as defined by GraphViz 2.44.1 X11 Color Scheme (http://graphviz.org/doc/info/colors.html)");
      else
        return true;
      fi;
    od;
  fi; 
end);

BindGlobal("DIGRAPHS_ValidEdgeColors",
function(D, edge)
  local out, col, colors, v, f, filename, Dir;
  out := OutNeighbours(D);
  Dir := DIGRAPHS_Dir();
  filename := Concatenation(Dir, "/data/colors.p");
  f := IO_File(filename);
  colors := IO_Unpickle(f);
  if Length(edge) <> Length(out) then
    ErrorNoReturn("the list of edge colors needs to have the same shape as the out-neighbours of the digraph");    
  fi;
  if Length(edge) = Length(out) then  
    for v in [1..Length(edge)] do
      if Length(out[v]) <> Length(edge[v]) then
        ErrorNoReturn("the list of edge colors needs to have the same shape as the out-neighbours of the digraph");
      else
        for col in edge[v] do
          if not IsString(col) then
            ErrorNoReturn("expected a string");
          elif DIGRAPHS_ValidRGBValue(col) = false and (col in colors) = false then
            ErrorNoReturn("expected RGB Value or valid color name as defined by GraphViz 2.44.1 X11 Color Scheme (http://graphviz.org/doc/info/colors.html)");
          else
            return true;
          fi;
        od;
      fi;
    od;
  fi; 
end);     

InstallMethod(DotDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
  return DIGRAPHS_DotDigraph(D, [], []);
end);

InstallMethod(DotColoredDigraph, "for a digraph by out-neighbours and two lists",
[IsDigraphByOutNeighboursRep, IsList, IsList],
function(D, vert, edge)
  if DIGRAPHS_ValidVertColors(D, vert) = true and DIGRAPHS_ValidEdgeColors(D, edge) = true then
# This code can be replaced with the commented out code when the required version of GAP becomes 4.10.0
    return(DIGRAPHS_DotDigraph(D,
                               [i -> Concatenation("[color=",
                               vert[i], ", style=filled]")],
                               [{i, j} -> Concatenation("[color=",
                               edge[i][j], "]")]));
    # return DIGRAPHS_DotDigraph(D,
    #                             [i -> StringFormatted("[color={}, style=filled]",
    #                             vert[i])],
    #                             [{i, j} -> StringFormatted("[color={}]",
    #                             edge[i][j])]);
  else
    return (DIGRAPHS_ValidVertColors(D, vert), DIGRAPHS_ValidEdgeColors(D, edge));
  fi;

end);

InstallMethod(DotVertexColoredDigraph, "for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
function(D, vert)
  if DIGRAPHS_ValidVertColors(D, vert) = true then
# This code can be replaced with the commented out code when the required version of GAP becomes 4.10.0
    return(DIGRAPHS_DotDigraph(D,
                               [i -> Concatenation("[color=",
                               vert[i], ", style=filled]")], []));
    # return DIGRAPHS_DotDigraph(D,
    #                             [i -> StringFormatted("[color={}, style=filled]",
    #                             vert[i])]);
  else 
    return DIGRAPHS_ValidVertColors(D, vert);
  fi;
end);

InstallMethod(DotEdgeColoredDigraph, "for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
function(D, edge)
  if DIGRAPHS_ValidEdgeColors(D, edge) = true then
# This code can be replaced with the commented out code when the required version of GAP becomes 4.10.0
    return(DIGRAPHS_DotDigraph(D, [],
                               [{i, j} -> Concatenation("[color=",
                               edge[i][j], "]")]));
    # return DIGRAPHS_DotDigraph(D,
    #                             [{i, j} -> StringFormatted("[color={}]",
    #                             edge[i][j])]);
  else
    return DIGRAPHS_ValidEdgeColors(D, edge);
  fi;
end);

InstallMethod(DotVertexLabelledDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
# this code can be replaced with the commented out code when the required version of GAP becomes 4.10.0
  return DIGRAPHS_DotDigraph(D, [i -> Concatenation(" [label=\"",
                                String(DigraphVertexLabel(D, i)), "\"]")], []);
  # return DIGRAPHS_DotDigraph(D, [i -> StringFormatted(" [label=\"{}\"]",
  #                                DigraphVertexLabel(D, i))], []);
end);

BindGlobal("DIGRAPHS_DotSymmetricDigraph",
function(D, node_funcs, edge_funcs)
  local out, str, i, j, func;
  if not IsSymmetricDigraph(D) then
    ErrorNoReturn("the argument <D> must be a symmetric digraph,");
  fi;
  out   := OutNeighbours(D);
  str   := "//dot\n";
  Append(str, "graph hgn{\n");
  Append(str, "node [shape=circle]\n\n");
  for i in DigraphVertices(D) do
    # Append(str, StringFormatted("{}", i));
    # This line can be replaced with the above commented one when the required version of GAP is 4.10.0
    Append(str, String(i));
    for func in node_funcs do
      Append(str, func(i));
    od;
    Append(str, "\n");
  od;
  for i in DigraphVertices(D) do
    for j in [1 .. Length(out[i])] do
      if j >= i then
        # Append(str, StringFormatted("{} -- {}", i, j));
        # This line can be replaced with the above commented one when the required version of GAP is 4.10.0
        Append(str, String(i));
        Append(str, " -- ");
        Append(str, String(out[i][j]));
        for func in edge_funcs do
          Append(str, func(i, j));
        od;
        Append(str, "\n");
      fi;
    od;
  od;
  Append(str, "}\n");
  return str;
end);

InstallMethod(DotSymmetricDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
  return DIGRAPHS_DotSymmetricDigraph(D, [], []);
end);

InstallMethod(DotSymmetricColoredDigraph,
"for a digraph by out-neighbours and two lists",
[IsDigraphByOutNeighboursRep, IsList, IsList],
function(D, vert, edge)
  if DIGRAPHS_ValidVertColors(D, vert) = true and DIGRAPHS_ValidEdgeColors(D, edge) = true then
# This code can be replaced with the commented out code when the required version of GAP becomes 4.10.0
    return DIGRAPHS_DotSymmetricDigraph(D,
                                       [i -> Concatenation("[color=", vert[i],
                                       ", style=filled]")],
                                       [{i, j} -> Concatenation("[color=",
                                       edge[i][j], "]")]);
    # return DIGRAPHS_DotSymmetricDigraph(D,
    #                                     [i -> StringFormatted(
    #                                     "[color={}, style=filled]", vert[i])],
    #                                     [{i, j} -> StringFormatted("[color={}]",
    #                                     edge[i][j])]);
  else
    return (DIGRAPHS_ValidVertColors(D, vert), DIGRAPHS_ValidEdgeColors(D, edge));
  fi;
end);

InstallMethod(DotSymmetricVertexColoredDigraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
function(D, vert)
  if DIGRAPHS_ValidVertColors(D, vert) = true then
    # This code can be replaced with the commented out code
    # when the required version of GAP becomes 4.10.0
    return(DIGRAPHS_DotSymmetricDigraph(D,
                                        [i -> Concatenation("[color=",
                                        vert[i], ", style=filled]")], []));
    # return DIGRAPHS_DotSymmetricDigraph(D,
    #                                    [i -> StringFormatted
    #                                    ("[color={}, style=filled]", vert[i])]);
  else
    return DIGRAPHS_ValidVertColors(D, vert);
  fi;
end);

InstallMethod(DotSymmetricEdgeColoredDigraph,
"for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsList],
function(D, edge)
  if DIGRAPHS_ValidEdgeColors(D, edge) = true then
    # This code can be replaced with the commented out code
    # when the required version of GAP becomes 4.10.0
    return(DIGRAPHS_DotSymmetricDigraph(D, [],
                                       [{i, j} -> Concatenation("[color=",
                                       edge[i][j], "]")]));
    # return DIGRAPHS_DotSymmetricDigraph(D,
    #                                    [{i, j} -> StringFormatted("[color={}]",
    #                                    edge[i][j])]);
  else 
    return DIGRAPHS_ValidEdgeColors(D, edge);
  fi;
end);

# AN's code

if not IsBound(Splash) then  # This function is written by A. Egri-Nagy
  BindGlobal("VizViewers",
             ["xpdf", "xdg-open", "open", "evince", "okular", "gv"]);

  BindGlobal("Splash",
  function(arg)
    local opt, path, dir, tdir, file, engine, viewer, type, filetype;

    if not IsString(arg[1]) then
      ErrorNoReturn("the 1st argument must be a string,");
    fi;

    if IsBound(arg[2]) then
      if not IsRecord(arg[2]) then
        ErrorNoReturn("the 2nd argument must be a record,");
      else
        opt := arg[2];
      fi;
    else
      opt := rec();
    fi;

    # path
    if IsBound(opt.path) then
      path := opt.path;
    else
      path := "~/";
    fi;

    # directory
    if IsBound(opt.directory) then
      if not opt.directory in DirectoryContents(path) then
        Exec(Concatenation("mkdir ", path, opt.directory));
      fi;
      dir := Concatenation(path, opt.directory, "/");
    elif IsBound(opt.path) then
      if not "tmp.viz" in DirectoryContents(path) then
        tdir := Directory(Concatenation(path, "/", "tmp.viz"));
        dir := Filename(tdir, "");
      fi;
    else
      tdir := DirectoryTemporary();
      dir := Filename(tdir, "");
    fi;

    # file
    if IsBound(opt.filename) then
      file := opt.filename;
    else
      file := "vizpicture";
    fi;

    # viewer
    if IsBound(opt.viewer) then
      viewer := opt.viewer;
      if not IsString(viewer) then
        ErrorNoReturn("the option `viewer` must be a string, not an ",
                      TNAM_OBJ(viewer), ",");
      elif Filename(DirectoriesSystemPrograms(), viewer) = fail then
        ErrorNoReturn("the viewer \"", viewer, "\" specified in the option ",
                      "`viewer` is not available,");
      fi;
    else
      viewer := First(VizViewers, x ->
                      Filename(DirectoriesSystemPrograms(), x) <> fail);
      if viewer = fail then
        ErrorNoReturn("none of the default viewers ", VizViewers,
                      " is available, please specify an available viewer",
                      " in the options record component `viewer`,");
      fi;
    fi;

    # type
    if IsBound(opt.type) and (opt.type = "latex" or opt.type = "dot") then
      type := opt.type;
    elif arg[1]{[1 .. 6]} = "%latex" then
      type := "latex";
    elif arg[1]{[1 .. 5]} = "//dot" then
      type := "dot";
    else
      ErrorNoReturn("the component \"type\" of the 2nd argument <a record> ",
                    " must be \"dot\" or \"latex\",");
    fi;

    # output type
    if IsBound(opt.filetype) then
      filetype := opt.filetype;
    else
      filetype := "pdf";
    fi;

    # engine
    if IsBound(opt.engine) then
      if opt.engine in ["dot", "neato", "twopi", "circo",
                        "fdp", "sfdp", "patchwork"] then
        engine := opt.engine;
      else
        ErrorNoReturn("the component \"engine\" of the 2nd argument ",
                      "<a record> must be one of: \"dot\", \"neato\", ",
                      "\"twopi\", \"circo\", \"fdp\", \"sfdp\", ",
                      "or \"patchwork\"");
      fi;
    else
      engine := "dot";
    fi;

    #

    if type = "latex" then
      FileString(Concatenation(dir, file, ".tex"), arg[1]);
      Exec(Concatenation("cd ", dir, "; ", "pdflatex ", dir, file,
                         " 2>/dev/null 1>/dev/null"));
      Exec(Concatenation(viewer, " ", dir, file,
                         ".pdf 2>/dev/null 1>/dev/null &"));
    elif type = "dot" then
      FileString(Concatenation(dir, file, ".dot"), arg[1]);
      Exec(Concatenation(engine, " -T", filetype, " ", dir, file, ".dot", " -o ",
                         dir, file, ".", filetype));
      Exec(Concatenation(viewer, " ", dir, file, ".", filetype,
                          " 2>/dev/null 1>/dev/null &"));
    fi;
    return;
  end);
fi;

# CR's code

InstallMethod(DotPartialOrderDigraph, "for a partial order digraph",
[IsDigraph],
function(D)
  if not IsPartialOrderDigraph(D) then
    ErrorNoReturn("the argument <D> must be a partial order digraph,");
  fi;
  D := DigraphMutableCopyIfMutable(D);
  return DotDigraph(DigraphReflexiveTransitiveReduction(D));
end);

InstallMethod(DotPreorderDigraph, "for a preorder digraph",
[IsDigraph],
function(D)
  local comps, quo, red, str, c, x, e;
  if not IsPreorderDigraph(D) then
    ErrorNoReturn("the argument <D> must be a preorder digraph,");
  fi;

  # Quotient by the strongly connected components to get a partial order
  # D and draw this without loops or edges implied by transitivity.
  D      := DigraphMutableCopyIfMutable(D);
  comps  := DigraphStronglyConnectedComponents(D).comps;
  quo    := DigraphRemoveAllMultipleEdges(QuotientDigraph(D, comps));
  red    := DigraphReflexiveTransitiveReduction(quo);

  str   := "//dot\n";
  Append(str, "digraph graphname {\n");
  Append(str, "node [shape=Mrecord, height=0.5, fixedsize=true]");
  Append(str, "ranksep=1;\n");

  # Each vertex of the quotient D is labelled by its preimage.
  for c in [1 .. Length(comps)] do
    Append(str, String(c));
    Append(str, " [label=\"");
    Append(str, String(comps[c][1]));
    for x in comps[c]{[2 .. Length(comps[c])]} do
      Append(str, "|");
      Append(str, String(x));
    od;
    Append(str, "\", width=");
    Append(str, String(Float(Length(comps[c]) / 2)));
    Append(str, "]\n");
  od;

  # Add the edges of the quotient D.
  for e in DigraphEdges(red) do
    Append(str, Concatenation(String(e[1]), " -> ", String(e[2]), "\n"));
  od;

  Append(str, "}");
  return str;
end);

InstallMethod(DotHighlightedDigraph, "for a digraph and list",
[IsDigraph, IsList],
{D, list} -> DotHighlightedDigraph(D, list, "black", "grey"));

InstallMethod(DotHighlightedDigraph,
"for a digraph by out-neighbours, list, and two strings",
[IsDigraphByOutNeighboursRep, IsList, IsString, IsString],
function(D, highverts, highcolour, lowcolour)
  local lowverts, out, str, i, j;

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
  str       := "//dot\n";

  Append(str, "digraph hgn{\n");

  Append(str, "subgraph lowverts{\n");
  Append(str, Concatenation("node [shape=circle, color=",
                            lowcolour,
                            "]\n edge [color=",
                            lowcolour,
                            "]\n"));

  for i in lowverts do
    Append(str, Concatenation(String(i), "\n"));
  od;

  Append(str, "}\n");

  Append(str, "subgraph highverts{\n");
  Append(str, Concatenation("node [shape=circle, color=",
                            highcolour,
                            "]\n edge [color=",
                            highcolour,
                            "]\n"));

  for i in highverts do
    Append(str, Concatenation(String(i), "\n"));
  od;

  Append(str, "}\n");

  Append(str, "subgraph lowverts{\n");
  for i in lowverts do
    for j in out[i] do
      Append(str, Concatenation(String(i), " -> ", String(j), "\n"));
    od;
  od;
  Append(str, "}\n");

  Append(str, "subgraph highverts{\n");
  for i in highverts do
    for j in out[i] do
      Append(str, Concatenation(String(i), " -> ", String(j)));
      if j in lowverts then
        Append(str, Concatenation(" [color=", lowcolour, "]"));
      fi;
      Append(str, "\n");
    od;
  od;
  Append(str, "}\n}\n");

  return str;
end);
