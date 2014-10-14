#############################################################################
##
#W  digraph.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# multi means it has at least one multiple edges

if IsBound(IS_MULTI_DIGRAPH) then
  InstallMethod(IsMultiDigraph, "for a digraph",
  [IsDigraph], IS_MULTI_DIGRAPH);
else 
  InstallMethod(IsMultiDigraph, "for a digraph",
  [IsDigraph],
  function(graph)
    local range, source, nredges, current, marked, out, nbs, i, j;

    if HasDigraphSource(graph) then
      range := DigraphRange(graph);
      source := DigraphSource(graph);
      nredges := Length(range);
      current := 0;
      marked := [ 1 .. DigraphNrVertices(graph)] * 0;

      for i in [ 1 .. nredges ] do
        if source[i] <> current then
          current := source[i];
          marked[range[i]] := current;
        elif marked[range[i]] = current then
          return true;
        else
          marked[range[i]] := current;
        fi;
      od;
      return false;
    else
      out := OutNeighbours(graph);
      for i in DigraphVertices(graph) do
        nbs := out[i];
        for j in [ 1 .. Length(nbs) ] do 
          if Position( nbs, nbs[j], 0 ) < j  then
            return true;
          fi;
        od;
      od;
      return false;
    fi;
  end);
fi;

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
    Error("Digraphs: AsDigraph: usage,\n",
          "the second argument should be a non-negative integer,\n");
    return;
  fi;

  ran := ListTransformation(trans, int);
  r := rec( nrvertices := int, source := [ 1 .. int ], range := ran );
  gr := DigraphNC(r);
  
  SetIsMultiDigraph(gr, false);
  SetIsFunctionalDigraph(gr, true);
  
  return gr;
end);

#

InstallMethod(Graph, "for a digraph",
[IsDigraph],
function(graph)
  local adj;

  if IsMultiDigraph(graph) then
    Info(InfoWarning, 1, "Grape does not support multiple edges, so ",
    "the Grape graph will have fewer\n#I  edges than the original,");
  fi;

  adj:=function(i, j)
    return j in OutNeighbours(graph)[i];
  end;

  return Graph(Group(()), ShallowCopy(DigraphVertices(graph)), OnPoints, adj, true);
end);

# JDM improve this!

InstallMethod(RandomDigraph, "for a pos int",
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
  SetIsMultiDigraph(gr, false);
  SetIsSymmetricDigraph(gr, true);
  return gr;
end);

# WW - do we want loops on a complete digraph, or not?

InstallMethod(CompleteDigraph, "for a pos int",
[IsPosInt],
function(n)
  local verts, adj, gr, i;
  
  verts := [ 1 .. n ];
  adj := EmptyPlist(n);
  for i in verts do
    adj[i] := verts;
  od;
  gr := DigraphNC(adj);
  SetIsMultiDigraph(gr, false);
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
    Error("Digraphs: Digraph: usage,\n",
          "the argument must be a record with components 'source',",
          " 'range', and either 'vertices' or 'nrvertices',\n");
    return;
  fi;

  if not (IsList(graph.source) and IsList(graph.range)) then
    Error("Digraphs: Digraph: usage,\n",
          "the graph components 'source' and 'range' should be lists,\n");
    return;
  fi;
  
  if Length(graph.source)<>Length(graph.range) then
    Error("Digraphs: Digraph: usage,\nthe record components ",
          "'source' and 'range' should have equal length,\n");
    return;
  fi;
  
  check_source := true;

  if IsBound(graph.nrvertices) then 
    if not (IsInt(graph.nrvertices) and graph.nrvertices >= 0) then 
      Error("Digraphs: Digraph: usage,\n",
            "the record component 'nrvertices' ",
            "should be a non-negative integer,\n");
      return;
    fi;
    cmp := LT;
    obj := graph.nrvertices + 1;
    
    if IsRange(graph.source) then 
      if not IsEmpty(graph.source) and (graph.source[1] < 1 or
         graph.source[Length(graph.source)] > graph.nrvertices) then 
        Error("Digraphs: Digraph: usage,\n",
              "the record component 'source' is invalid,\n");
        return;
      fi;
      check_source := false;
    fi;

  elif IsBound(graph.vertices) then 
    if not IsList(graph.vertices) then
      Error("Digraphs: Digraph: usage,\n",
            "the record component 'vertices' should be a list,\n");
      return;
    fi;
    cmp := \in;
    obj := graph.vertices;
    graph.nrvertices := Length(graph.vertices);
  fi;
 
  if check_source and not ForAll(graph.source, x-> cmp(x, obj)) then
    Error("Digraphs: Digraph: usage,\n",
          "the record component 'source' is invalid,\n");
    return;
  fi;

  if not ForAll(graph.range, x-> cmp(x, obj)) then
    Error("Digraphs: Digraph: usage,\n",
          "the record component 'range' is invalid,\n");
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
  ObjectifyWithAttributes(graph, DigraphType, DigraphRange,
   graph.range, DigraphSource, graph.source);
  return graph;
end);

#

InstallMethod(Digraph, "for a list of lists of pos ints",
[IsList],
function(adj)
  local nr, record, x, y;

  nr := Length(adj);

  for x in adj do
    for y in x do
      if not (IsPosInt(y) and y <= nr) then
        Error("Digraphs: Digraph: usage,\n",
              "the argument must be a list of lists of positive",
              " integers not exceeding the length of the argument,\n");
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
  
  graph := rec( adj        := StructuralCopy(adj), 
                nrvertices := Length(adj)         );

  ObjectifyWithAttributes(graph, DigraphType, 
    OutNeighbours, adj, DigraphNrVertices, graph.nrvertices);
  return graph;
end);

# JDM: could set IsMultigraph here if we check if mat[i][j] > 1 in line 234 

InstallMethod(DigraphByAdjacencyMatrix, "for a rectangular table",
[IsRectangularTable],
function(mat)
  local n, record, verts, out, i, j, k;

  n := Length(mat);

  if Length(mat[1]) <> n then
    Error("Digraphs: DigraphByAdjacencyMatrix: usage,\n",
          "the matrix is not square,\n");
    return;
  fi;

  record := rec( nrvertices := n, source := [], range := [] );
  verts := [ 1 .. n ];
  for i in verts do
    for j in verts do
      if IsInt(mat[i][j]) and mat[i][j] >= 0 then 
        for k in [ 1 .. mat[i][j] ] do
          Add(record.source, i);
          Add(record.range, j);
        od;
      else
        Error("Digraphs: DigraphByAdjacencyMatrix: usage,\nthe argument must", 
              " be a matrix of non-negative integers,\n");
        return;
      fi;
    od;
  od;
  out := DigraphNC(record);
  SetAdjacencyMatrix(out, mat);
  return out;
end);

#

InstallMethod(DigraphByAdjacencyMatrix, "for an empty list",
[IsList and IsEmpty],
function(mat)
  return DigraphByAdjacencyMatrixNC( mat );
end);

#

InstallMethod(DigraphByAdjacencyMatrixNC, "for a rectangular table",
[IsRectangularTable],
function(mat)
  local n, record, verts, out, i, j, k;

  n := Length(mat);
  record := rec( nrvertices := n, source := [], range := [] );
  verts := [ 1 .. n ];
  for i in verts do
    for j in verts do
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

InstallMethod(DigraphByAdjacencyMatrixNC, "for an empty list",
[IsList and IsEmpty],
function(mat)
  return DigraphNC( [ ] );
end);

#

InstallMethod(DigraphByEdges, "for a rectangular table",
[IsRectangularTable],
function(edges)
  local adj, max_range, gr, edge, i;
  
  if not Length(edges[1]) = 2 then 
    Error("Digraphs: DigraphByEdges: usage,\n",
          "the argument <edges> must be a list of pairs,\n");
    return;
  fi;

  if not (IsPosInt(edges[1][1]) and IsPosInt(edges[1][2])) then 
    Error("Digraphs: DigraphByEdges: usage,\n",
          "the argument <edges> must be a list of pairs of pos ints,\n");
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
  SetDigraphEdges(gr, edges);
  return gr;
end);

# <n> is the number of vertices

InstallMethod(DigraphByEdges, "for a rectangular table, and a pos int",
[IsRectangularTable, IsPosInt],
function(edges, n)
  local adj, gr, edge;
  
  if not Length(edges[1]) = 2 then 
    Error("Digraphs: DigraphByEdges: usage,\n",
          "the argument <edges> must be a list of pairs,\n");
    return;
  fi;

  if not (IsPosInt(edges[1][1]) and IsPosInt(edges[1][2])) then 
    Error("Digraphs: DigraphByEdges: usage,\n",
          "the argument <edges> must be a list of pairs of pos ints,\n");
    return;
  fi;

  adj := List([1..n], x-> []);

  for edge in edges do
    if edge[1] > n or edge[2] > n then
      Error("Digraphs: DigraphByEdges: usage,\nthe specified edges ",
            "must not contain values greater than ", n, ",\n");
      return;
    fi;
    Add(adj[edge[1]], edge[2]);
  od;

  gr:=DigraphNC(adj);
  SetDigraphEdges(gr, edges);
  return gr;
end);

# operators . . .

InstallMethod(\=, "for digraphs",
[IsDigraph, IsDigraph],
function(graph1, graph2)
  return DigraphVertices(graph1)=DigraphVertices(graph2) and DigraphRange(graph1)=DigraphRange(graph2)
   and DigraphSource(graph1)=DigraphSource(graph2);
end);

# printing, and viewing . . .

InstallMethod(ViewString, "for a digraph",
[IsDigraph],
function(graph)
  local str;
  str := "<";
  
  if IsMultiDigraph(graph) then 
    Append(str, "multi");
  fi;

  Append(str, "digraph with ");
  Append(str, String(DigraphNrVertices(graph)));
  Append(str, " vertices, ");
  Append(str, String(DigraphNrEdges(graph)));
  Append(str, " edges>");
  return str;
end);

InstallMethod(PrintString, "for a digraph",
[IsDigraph],
function(graph)
  local str, com, i, nam;

  str:="Digraph( ";

  if DigraphNrEdges(graph) >= DigraphNrVertices(graph) then
    return Concatenation(str, PrintString(OutNeighbours(graph)), " )");
  else 
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
  fi;
end);

InstallMethod(String, "for a digraph",
[IsDigraph],
function(graph)
  local str, com, i, nam;

  str:="Digraph( ";

  if DigraphNrEdges(graph) >= DigraphNrVertices(graph) then
    return Concatenation(str, String(OutNeighbours(graph)), " )");
  else
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
  fi;
end);

#EOF
