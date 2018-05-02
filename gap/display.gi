#############################################################################
##
##  display.gi
##  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# AN's code, adapted by WW

InstallMethod(DotDigraph, "for a digraph",
[IsDigraph],
function(graph)
  local verts, out, str, i, j;

  verts := DigraphVertices(graph);
  out   := OutNeighbours(graph);
  str   := "//dot\n";

  Append(str, "digraph hgn{\n");
  Append(str, "node [shape=circle]\n");

  for i in verts do
    Append(str, Concatenation(String(i), "\n"));
  od;

  for i in verts do
    for j in out[i] do
      Append(str, Concatenation(String(i), " -> ", String(j), "\n"));
    od;
  od;
  Append(str, "}\n");
  return str;
end);

InstallMethod(DotVertexLabelledDigraph, "for a digraph", [IsDigraph],
function(digraph)
  local verts, out, str, i, j;

  verts := DigraphVertices(digraph);
  out   := OutNeighbours(digraph);
  str   := "//dot\n";

  Append(str, "digraph hgn{\n");
  Append(str, "node [shape=circle]\n");

  for i in verts do
    Append(str, String(i));
    Append(str, " [label=\"");
    Append(str, String(DigraphVertexLabel(digraph, i)));
    Append(str, "\"]\n");
  od;

  for i in verts do
    for j in out[i] do
      Append(str, Concatenation(String(i), " -> ", String(j), "\n"));
    od;
  od;
  Append(str, "}\n");
  return str;
end);

#

InstallMethod(DotSymmetricDigraph, "for an 'undirected' digraph",
[IsDigraph],
function(graph)
  local verts, out, str, i, j;

  if not IsSymmetricDigraph(graph) then
    ErrorNoReturn("Digraphs: DotSymmetricDigraph: usage,\n",
                  "the argument <graph> should be symmetric,");
  fi;

  verts := DigraphVertices(graph);
  out   := OutNeighbours(graph);
  str   := "//dot\n";

  Append(str, "graph hgn{\n");
  Append(str, "node [shape=circle]\n\n");

  for i in verts do
    Append(str, Concatenation(String(i), "\n"));
  od;

  for i in verts do
    for j in out[i] do
      if j >= i then
        Append(str, Concatenation(String(i), " -- ", String(j), "\n"));
      fi;
    od;
  od;
  Append(str, "}\n");
  return str;
end);

# AN's code

if not IsBound(Splash) then  # This function is written by A. Egri-Nagy
  if ARCH_IS_MAC_OS_X() then
    BindGlobal("VizViewers", ["xpdf", "open", "evince", "okular", "gv"]);
  elif ARCH_IS_UNIX() then
    BindGlobal("VizViewers", ["xpdf", "xdg-open", "evince", "okular", "gv"]);
  elif ARCH_IS_WINDOWS() then
    BindGlobal("VizViewers", ["xpdf", "evince", "okular", "gv"]);
  fi;

  BindGlobal("Splash",
  function(arg)
    local opt, path, dir, tdir, file, engine, viewer, type, filetype;

    if not IsString(arg[1]) then
      ErrorNoReturn("Digraphs: Splash: usage,\n",
                    "<arg>[1] must be a string,");
    fi;

    if IsBound(arg[2]) then
      if not IsRecord(arg[2]) then
        ErrorNoReturn("Digraphs: Splash: usage,\n",
                      "<arg>[2] must be a record,");
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
    else
      viewer := First(VizViewers, x ->
                      Filename(DirectoriesSystemPrograms(), x) <> fail);
    fi;

    # type
    if IsBound(opt.type) and (opt.type = "latex" or opt.type = "dot") then
      type := opt.type;
    elif arg[1]{[1 .. 6]} = "%latex" then
      type := "latex";
    elif arg[1]{[1 .. 5]} = "//dot" then
      type := "dot";
    else
      ErrorNoReturn("Digraphs: Splash: usage,\n",
                    "the option <type> must be \"dot\" or \"latex\",");
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
        ErrorNoReturn("Digraphs: Splash: usage,\n",
                      "the option <engine> must be \"dot\", \"neato\", ",
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
function(digraph)
  if not IsPartialOrderDigraph(digraph) then
    ErrorNoReturn("Digraphs: DotPartialOrderDigraph: usage,\n",
                  "the argument <digraph> should be a partial order digraph,");
  fi;
  return DotDigraph(DigraphReflexiveTransitiveReduction(digraph));
end);

InstallMethod(DotPreorderDigraph, "for a preorder digraph",
[IsDigraph],
function(digraph)
  local comps, quo, red, str, c, x, e;

  if not IsPreorderDigraph(digraph) then
    ErrorNoReturn("Digraphs: DotPreorderDigraph: usage,\n",
                  "the argument <digraph> should be a preorder digraph,");
  fi;

  # Quotient by the strongly connected components to get a partial order
  # digraph and draw this without loops or edges implied by transitivity.
  comps  := DigraphStronglyConnectedComponents(digraph).comps;
  quo    := DigraphRemoveAllMultipleEdges(QuotientDigraph(digraph, comps));
  red    := DigraphReflexiveTransitiveReduction(quo);

  str   := "//dot\n";
  Append(str, "digraph graphname {\n");
  Append(str, "node [shape=Mrecord, height=0.5, fixedsize=true]");
  Append(str, "ranksep=1;\n");

  # Each vertex of the quotient digraph is labelled by its preimage.
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

  # Add the edges of the quotient digraph.
  for e in DigraphEdges(red) do
    Append(str, Concatenation(String(e[1]), " -> ", String(e[2]), "\n"));
  od;

  Append(str, "}");
  return str;
end);
