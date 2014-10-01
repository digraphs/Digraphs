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

InstallMethod(AsDirectedGraph, "for a transformation",
[IsTransformation],
function(trans);
  return AsDirectedGraph(trans, DegreeOfTransformation(trans));
end);

#

InstallMethod(AsDirectedGraph, "for a transformation and an integer",
[IsTransformation, IsInt],
function(trans, int)
  local deg, ran, r, gr;
  
  if int < 0 then
    return fail;
  fi;

  ran := ListTransformation(trans, int);
  r := rec( nrvertices := int, source := [ 1 .. int ], range := ran );
  gr := DirectedGraphNC(r);
  
  SetIsSimpleDirectedGraph(gr, true);
  SetIsFunctionalDirectedGraph(gr, true);
  
  return gr;
end);

#

InstallMethod(Graph, "for a directed graph",
[IsDirectedGraph],
function(graph)
  local adj;

  if not IsSimpleDirectedGraph(graph) then
    Info(InfoWarning, 1, "Grape does not support multiple edges, so ",
    "the Grape graph will have fewer\n#I  edges than the original,");
  fi;

  adj:=function(i, j)
    return j in Adjacencies(graph)[i];
  end;

  return Graph(Group(()), ShallowCopy(Vertices(graph)), OnPoints, adj, true);
end);

#

InstallMethod(RandomSimpleDirectedGraph, "for a pos int",
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

  gr := DirectedGraphNC(adj);
  SetIsSimpleDirectedGraph(gr, true);
  return gr;
end);

#

InstallMethod(DirectedGraph, "for a record", [IsRecord],
function(record)
  local i;

  if IsGraph(record) then
    return DirectedGraphNC(List(Vertices(record), x-> Adjacency(record, x)));
  fi;

  if not (IsBound(record.source) and IsBound(record.range) and
    (IsBound(record.vertices) or IsBound(record.nrvertices))) then
    Error("usage: the argument must be a record with components `source',",
    " `range', and `vertices' or 'nrvertices'");
    return;
  fi;

  if not (IsList(record.source) and IsList(record.range)) then
    Error("usage: the record components 'source'",
    " and 'range' should be lists,");
    return;
  fi;
  
  if Length(record.source)<>Length(record.range) then
    Error("usage: the record components 'source'",
    " and 'range' should be of equal length,");
    return;
  fi;

  if IsBound(record.vertices) then 
    if not IsList(record.vertices) then
      Error("usage: the record components 'vertices'",
      "should be a list,");
      return;
    fi;
    
    if not ForAll(record.source, x-> x in record.vertices) then
      Error("usage: every element of the record components 'source'",
      " must belong to the component 'vertices',");
      return;
    fi;

    if not ForAll(record.range, x-> x in record.vertices) then
      Error("usage: every element of the record components 'range'",
      " must belong to the component 'vertices',");
      return;
    fi;

  elif IsBound(record.nrvertices) then 
    if not IsPosInt(record.nrvertices) then 
      Error("usage: the record components 'nrvertices'",
      "should be a positive integer,");
      return;
    fi;
    
    if not ForAll(record.source, x-> x <= record.nrvertices) then
      Error("usage: every element of the record components 'source'",
      " must be at most 'nrvertices',");
      return;
    fi;

    if not ForAll(record.range, x-> x <= record.vertices) then
      Error("usage: every element of the record components 'range'",
      " must be at most 'nrvertices',");
      return;
    fi;
  fi;

  record:=StructuralCopy(record);

  # rewrite the vertices to numbers
  if IsBound(record.vertices) then
    record.nrvertices := Length(record.vertices);
    for i in [1..Length(record.range)] do
      record.range[i]:=Position(record.vertices, record.range[i]);
      record.source[i]:=Position(record.vertices, record.source[i]);
    od;
  fi;

  # make sure that the record.source is sorted, and range is too
  record.range:=Permuted(record.range, Sortex(record.source));

  MakeImmutable(record);

  return Objectify(DirectedGraphType, record);
end);

#

InstallMethod(DirectedGraphNC, "for a record", [IsRecord],
function(record)

  if IsGraph(record) then
    return DirectedGraphNC(List(Vertices(record), x-> Adjacency(record, x)));
  fi;

  record:=StructuralCopy(record);
  MakeImmutable(record);

  return Objectify(DirectedGraphType, record);
end);

#

InstallMethod(DirectedGraph, "for a list of lists of pos ints",
[IsList],
function(adj)
  local len, record, x, y;

  len := Length(adj);
  adj := StructuralCopy(adj);

  for x in adj do
    for y in x do
      if not (IsPosInt(y) and y <= len) then
        Error("usage: the argument must be a list of lists of positive",
        " integers not exceeding the length of the argument,");
        return;
      fi;
    od;
  od;

  record:=rec( adj := adj, nrvertices := Length(adj) );
  # ObjectifyWithAttributes doesn't work on an immutable record
  ObjectifyWithAttributes(record, DirectedGraphType, Adjacencies, adj,
   NrVertices, Length(adj));
  return record;
end);

InstallMethod(DirectedGraphNC, "for a list of lists of pos ints", [IsList],
function(adj)
  local record;
  record := rec( adj := StructuralCopy(adj), nrvertices := Length(adj));
  # ObjectifyWithAttributes doesn't work on an immutable record
  ObjectifyWithAttributes(record, DirectedGraphType, Adjacencies, record.adj, 
    NrVertices, Length(adj));
  return record;
end);

#

InstallMethod(DirectedGraphByAdjacencyMatrix, "for a rectangular table",
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
        Error("DirectedGraphByAdjacencyMatrix: usage, the argument must", 
        " be a matrix of non-negative integers,");
        return;
      fi;
    od;
  od;
  out := DirectedGraphNC(record);
  SetAdjacencyMatrix(out, mat);
  return out;
end);

#

InstallMethod(DirectedGraphByEdges, "for a rectangular table",
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

  gr:=DirectedGraphNC(adj);
  SetEdges(gr, edges);
  return gr;
end);

# <n> is the number of arguments

InstallMethod(DirectedGraphByEdges, "for a rectangular table, and a pos int",
[IsRectangularTable, IsPosInt],
function(edges, n)
  local adj, gr, edge;
  
  if not Length(edges[1]) = 2 then 
    Error("DirectedGraphByEdges: usage, the argument <edges> must be a list of pairs,");
    return;
  fi;

  if not (IsPosInt(edges[1][1]) and IsPosInt(edges[1][2])) then 
    Error("DirectedGraphByEdges: usage, the argument <edges> must be a list of", 
    " pairs of pos ints,");
    return;
  fi;

  adj := List([1..n], x-> []);

  for edge in edges do
    if edge[1] > n or edge[2] > n then
      Error("DirectedGraphByEdges: usage, the specified edges must not contain", 
      " values greater than ", n );
      return;
    fi;
    Add(adj[edge[1]], edge[2]);
  od;

  gr:=DirectedGraphNC(adj);
  SetEdges(gr, edges);
  return gr;
end);

# operators . . .

InstallMethod(\=, "for directed graphs",
[IsDirectedGraph, IsDirectedGraph],
function(graph1, graph2)
  return Vertices(graph1)=Vertices(graph2) and Range(graph1)=Range(graph2)
   and Source(graph1)=Source(graph2);
end);

# printing, and viewing . . .

InstallMethod(ViewString, "for a directed graph",
[IsDirectedGraph],
function(graph)
  local str;

  str:="<directed graph with ";
  Append(str, String(NrVertices(graph)));
  Append(str, " vertices, ");
  Append(str, String(NrEdges(graph)));
  Append(str, " edges>");
  return str;
end);

InstallMethod(PrintString, "for a directed graph",
[IsDirectedGraph],
function(graph)
  local str, com, i, nam;

  str:="DirectedGraph( ";

  if IsSimpleDirectedGraph(graph) then
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

InstallMethod(String, "for a directed graph",
[IsDirectedGraph],
function(graph)
  local str, com, i, nam;

  str:="DirectedGraph( ";

  if IsSimpleDirectedGraph(graph) then
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
