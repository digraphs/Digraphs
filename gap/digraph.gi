#############################################################################
##
#W  digraph.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# constructors . . .

InstallMethod(AsDigraph, "for a transformation",
[IsTransformation],
function(trans);
  return AsDigraph(trans, DegreeOfTransformation(trans));
end);

#

InstallMethod(AsDigraph, "for a transformation and an integer",
[IsTransformation, IsInt],
function(trans, int)
  local deg, ran, r, gr;
  
  if int < 0 then
    Error("usage: the second argument should be a non-negative integer,");
    return;
  fi;

  ran := ListTransformation(trans, int);
  r := rec( nrvertices := int, source := [ 1 .. int ], range := ran );
  gr := DigraphNC(r);
  
  SetIsSimpleDigraph(gr, true);
  SetIsFunctionalDigraph(gr, true);
  
  return gr;
end);

#

InstallMethod(Graph, "for a digraph",
[IsDigraph],
function(graph)
  local adj;

  if not IsSimpleDigraph(graph) then
    Info(InfoWarning, 1, "Grape does not support multiple edges, so ",
    "the Grape graph will have fewer\n#I  edges than the original,");
  fi;

  adj:=function(i, j)
    return j in Adjacencies(graph)[i];
  end;

  return Graph(Group(()), ShallowCopy(Vertices(graph)), OnPoints, adj, true);
end);

#

InstallMethod(RandomSimpleDigraph, "for a pos int",
[IsPosInt],
function(n)
  local verts, adj, nr, i, j, gr;

  verts := [1..n];
  adj := [];

  for i in verts do
    nr := Random(verts);
    adj[i] := [];
    for j in [1..nr] do
      AddSet(adj[i], Random(verts));
    od;
  od;

  gr := DigraphNC(adj);
  SetIsSimpleDigraph(gr, true);
  return gr;
end);

#

InstallMethod(Digraph, "for a record", [IsRecord],
function(graph)
  local check_source, cmp, obj, i;

  if IsGraph(graph) then
    return DigraphNC(List(Vertices(graph), x-> Adjacency(graph, x)));
  fi;

  if not (IsBound(graph.source) and IsBound(graph.range) and
    (IsBound(graph.vertices) or IsBound(graph.nrvertices))) then
    Error("usage: the argument must be a record with components 'source',",
    " 'range', and 'vertices' or 'nrvertices'");
    return;
  fi;

  if not (IsList(graph.source) and IsList(graph.range)) then
    Error("usage: the graph components 'source'",
    " and 'range' should be lists,");
    return;
  fi;
  
  if Length(graph.source)<>Length(graph.range) then
    Error("usage: the record components 'source'",
    " and 'range' should be of equal length,");
    return;
  fi;
  
  check_source := true;

  if IsBound(graph.nrvertices) then 
    if not (IsInt(graph.nrvertices) and graph.nrvertices >= 0) then 
      Error("usage: the record component 'nrvertices' ",
      "should be a non-negative integer,");
      return;
    fi;
    cmp := LT;
    obj := graph.nrvertices + 1;
    
    if IsRange(graph.source) then 
      if not IsEmpty(graph.source) and (graph.source[1] < 1 or
         graph.source[Length(graph.source)] > graph.nrvertices) then 
        Error("usage: the record component 'source' is invalid,");
        return;
      fi;
      check_source := false;
    fi;

  elif IsBound(graph.vertices) then 
    if not IsList(graph.vertices) then
      Error("usage: the record component 'vertices' ",
      "should be a list,");
      return;
    fi;
    cmp := \in;
    obj := graph.vertices;
    graph.nrvertices := Length(graph.vertices);
  fi;
 
  if check_source and not ForAll(graph.source, x-> cmp(x, obj)) then
    Error("usage: the record component 'source' is invalid,");
    return;
  fi;

  if not ForAll(graph.range, x-> cmp(x, obj)) then
    Error("usage: the record component 'range' is invalid,");
    return;
  fi;

  graph:=StructuralCopy(graph);

  # rewrite the vertices to numbers
  if IsBound(graph.vertices) then
    if graph.vertices <> [ 1 .. graph.nrvertices ] then  
      for i in [1..Length(graph.range)] do
        graph.range[i]:=Position(graph.vertices, graph.range[i]);
        graph.source[i]:=Position(graph.vertices, graph.source[i]);
      od;
    fi;
  fi;

  # make sure that the graph.source is sorted, and range is too
  graph.range:=Permuted(graph.range, Sortex(graph.source));

  return DigraphNC(graph);
end);

#

InstallMethod(DigraphNC, "for a record", [IsRecord],
function(graph)
  ObjectifyWithAttributes(graph, DigraphBySourceAndRangeType, Range,
   graph.range, Source, graph.source);
  return graph;
end);

#

InstallMethod(Digraph, "for a list of lists of pos ints",
[IsList],
function(adj)
  local len, record, x, y;

  len := Length(adj);

  for x in adj do
    for y in x do
      if not (IsPosInt(y) and y <= len) then
        Error("usage: the argument must be a list of lists of positive",
        " integers not exceeding the length of the argument,");
        return;
      fi;
    od;
  od;

  return DigraphNC(adj);
end);

#

InstallMethod(DigraphNC, "for a list", [IsList],
function(adj)
  local graph;
  graph := rec( adj := StructuralCopy(adj), nrvertices := Length(adj) );
  ObjectifyWithAttributes(graph, DigraphByAdjacencyType, Adjacencies, adj,
   NrVertices, graph.nrvertices, IsSimpleDigraph, true);
  return graph;
end);

#

InstallMethod(DigraphByAdjacencyMatrix, "for a rectangular table",
[IsRectangularTable],
function(mat)
  local n, record, out, i, j, k;

  n := Length(mat);

  if Length(mat[1]) <> n then
    Error("the given matrix is not square, so not an adjacency matrix, ");
    return;
  fi;

  record := rec( nrvertices := n, source := [], range := [] );
  for i in [ 1 .. n ] do
    for j in [ 1 .. n ] do
      if IsInt(mat[i][j]) and mat[i][j] >= 0 then 
        for k in [ 1 .. mat[i][j] ] do
          Add(record.source, i);
          Add(record.range, j);
        od;
      else
        Error("DigraphByAdjacencyMatrix: usage, the argument must", 
        " be a matrix of non-negative integers,");
        return;
      fi;
    od;
  od;
  out := DigraphNC(record);
  SetAdjacencyMatrix(out, mat);
  return out;
end);

#

InstallMethod(DigraphByAdjacencyMatrixNC, "for a rectangular table",
[IsRectangularTable],
function(mat)
  local n, record, out, i, j, k;

  n := Length(mat);
  record := rec( nrvertices := n, source := [], range := [] );
  for i in [ 1 .. n ] do
    for j in [ 1 .. n ] do
      for k in [ 1 .. mat[i][j] ] do
        Add(record.source, i);
        Add(record.range, j);
      od;
    od;
  od;
  out := DigraphNC(record);
  SetAdjacencyMatrix(out, mat);
  return out;
end);

#

InstallMethod(DigraphByEdges, "for a rectangular table",
[IsRectangularTable],
function(edges)
  local adj, max_range, gr, edge, i;
  
  if not Length(edges[1]) = 2 then 
    Error("usage: the argument <edges> must be a list of pairs,");
    return;
  fi;

  if not (IsPosInt(edges[1][1]) and IsPosInt(edges[1][2])) then 
    Error("usage: the argument <edges> must be a list of pairs of pos ints,");
    return;
  fi;

  adj := [];
  max_range := 0;

  for edge in edges do 
    if not IsBound(adj[edge[1]]) then 
      adj[edge[1]] := [edge[2]];
    else
      Add(adj[edge[1]], edge[2]);
    fi;
    max_range := Maximum(max_range, edge[2]);
  od;

  for i in [1..Maximum(Length(adj), max_range)] do 
    if not IsBound(adj[i]) then 
      adj[i] := [];
    fi;
  od;

  gr:=DigraphNC(adj);
  SetEdges(gr, edges);
  return gr;
end);

# <n> is the number of vertices

InstallMethod(DigraphByEdges, "for a rectangular table, and a pos int",
[IsRectangularTable, IsPosInt],
function(edges, n)
  local adj, gr, edge;
  
  if not Length(edges[1]) = 2 then 
    Error("DigraphByEdges: usage, the argument <edges> must be a list of pairs,");
    return;
  fi;

  if not (IsPosInt(edges[1][1]) and IsPosInt(edges[1][2])) then 
    Error("DigraphByEdges: usage, the argument <edges> must be a list of", 
    " pairs of pos ints,");
    return;
  fi;

  adj := List([1..n], x-> []);

  for edge in edges do
    if edge[1] > n or edge[2] > n then
      Error("DigraphByEdges: usage, the specified edges must not contain", 
      " values greater than ", n );
      return;
    fi;
    Add(adj[edge[1]], edge[2]);
  od;

  gr:=DigraphNC(adj);
  SetEdges(gr, edges);
  return gr;
end);

# operators . . .

InstallMethod(\=, "for digraphs",
[IsDigraph, IsDigraph],
function(graph1, graph2)
  return Vertices(graph1)=Vertices(graph2) and Range(graph1)=Range(graph2)
   and Source(graph1)=Source(graph2);
end);

# printing, and viewing . . .

InstallMethod(ViewString, "for a digraph",
[IsDigraph],
function(graph)
  local str;

  str:="<digraph with ";
  Append(str, String(NrVertices(graph)));
  Append(str, " vertices, ");
  Append(str, String(NrEdges(graph)));
  Append(str, " edges>");
  return str;
end);

InstallMethod(PrintString, "for a digraph",
[IsDigraph],
function(graph)
  local str, com, i, nam;

  str:="Digraph( ";

  if IsSimpleDigraph(graph) then
    return Concatenation(str, PrintString(Adjacencies(graph)), " )");
  fi;

  Append(str, "\>\>rec(\n\>\>");
  com := false;
  i := 1;
  for nam in ["range", "source", "nrvertices"] do
    if com then
      Append(str, "\<\<,\n\>\>");
    else
      com := true;
    fi;
    SET_PRINT_OBJ_INDEX(i);
    i := i+1;
    Append(str, nam);
    Append(str, "\< := \>");
    Append(str, PrintString(graph!.(nam)));
  od;
  Append(str, " \<\<\<\<)");
  return str;
end);

InstallMethod(String, "for a digraph",
[IsDigraph],
function(graph)
  local str, com, i, nam;

  str:="Digraph( ";

  if IsSimpleDigraph(graph) then
    return Concatenation(str, PrintString(Adjacencies(graph)), " )");
  fi;

  Append(str, "rec( ");
  com := false;
  i := 1;
  for nam in ["range", "source", "nrvertices"] do
    if com then
      Append(str, ", ");
    else
      com := true;
    fi;
    SET_PRINT_OBJ_INDEX(i);
    i := i+1;
    Append(str, nam);
    Append(str, " := ");
    Append(str, PrintString(graph!.(nam)));
  od;
  Append(str, " )");
  return str;
end);

#EOF
