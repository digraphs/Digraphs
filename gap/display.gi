#############################################################################
##
#W  display.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# AN's code, adapted by WW

InstallMethod(DotDigraph, "for a digraph",
[IsDigraph],
function(graph)
  local verts, out, m, str, i, j;

  verts := DigraphVertices(graph);
  out   := OutNeighbours(graph);
  m     := DigraphNrVertices(graph);
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

#

InstallMethod(DotSymmetricDigraph, "for an 'undirected' digraph",
[IsDigraph],
function(graph)
  local verts, out, m, str, i, j;

  if not IsSymmetricDigraph(graph) then
    ErrorNoReturn("Digraphs: DotSymmetricDigraph: usage,\n",
                  "the argument <graph> should be symmetric,");
  fi;

  verts := DigraphVertices(graph);
  out   := OutNeighbours(graph);
  m     := DigraphNrEdges(graph);
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

if not IsBound(Splash) then #This function is written by A. Egri-Nagy
  if ARCH_IS_MAC_OS_X() then
    BindGlobal("VizViewers", ["xpdf", "open", "evince", "okular", "gv"]);
  elif ARCH_IS_UNIX() then
    BindGlobal("VizViewers", ["xpdf", "xdg-open", "evince", "okular", "gv"]);
  elif ARCH_IS_WINDOWS() then
    BindGlobal("VizViewers", ["xpdf", "evince", "okular", "gv"]);
  fi;

  BindGlobal("Splash",
  function(arg)
    local opt, path, dir, tdir, file, viewer, type, filetype;

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

    #

    if type = "latex" then
      FileString(Concatenation(dir, file, ".tex"), arg[1]);
      Exec(Concatenation("cd ", dir, "; ", "pdflatex ", dir, file,
                         " 2>/dev/null 1>/dev/null"));
      Exec(Concatenation(viewer, " ", dir, file,
                         ".pdf 2>/dev/null 1>/dev/null &"));
    elif type = "dot" then
      FileString(Concatenation(dir, file, ".dot"), arg[1]);
      Exec(Concatenation("dot -T", filetype, " ", dir, file, ".dot", " -o ",
                         dir, file, ".", filetype));
      Exec (Concatenation(viewer, " ", dir, file, ".", filetype,
                          " 2>/dev/null 1>/dev/null &"));
    fi;
    return;
  end);
fi;
