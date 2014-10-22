#############################################################################
##
#W  digraph.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallMethod(Digraph, "for a positive integer and a function",
[IsPosInt, IsFunction],
function(n, func)
  local out, V, i, j;

  out:=List( [ 1 .. n ], x -> [] );
  
  V:= [ 1 .. n ];

  for i in V do 
    for j in V do 
      if func(i, j) then 
        Add(out[i], j);
      fi;
    od;
  od;
  return DigraphNC(out);
end);

InstallMethod(SetDigraphVertexName, "for a digraph, pos int, object",
[IsDigraph, IsPosInt, IsObject], 
function(graph, i, name)

  if not IsBound(graph!.vertexnames) then 
    graph!.vertexnames := [1 .. DigraphNrVertices(graph)];
  fi;

  if i > DigraphNrVertices(graph) then 
    Error("Digraphs: SetDigraphVertexName: usage,\n",
    "there are only ",  DigraphNrVertices(graph), " vertices,\n");
    return;
  fi;
  graph!.vertexnames[i]:=name;
  return;
end);

InstallMethod(DigraphVertexName, "for a digraph and pos int",
[IsDigraph, IsPosInt], 
function(graph, i)

  if not IsBound(graph!.vertexnames) then 
    graph!.vertexnames := [1 .. DigraphNrVertices(graph)];
  fi;

  if IsBound(graph!.vertexnames[i]) then 
    return graph!.vertexnames[i];
  fi;
  Error("Digraphs: DigraphVertexName: usage,\n",
   i, " is nameless or not a vertex,\n");
  return;
end);

InstallMethod(SetDigraphVertexNames, "for a digraph and list",
[IsDigraph, IsList], 
function(graph, names)
  
  if Length(names) = DigraphNrVertices(graph) then 
    graph!.vertexnames := names;
  else 
    Error("Digraphs: SetDigraphVertexNames: usage,\n",
    "the 2nd arument <names> must be a list with length equal",
    " to the number of\nvertices of the digraph,\n");
    return;
  fi;
  return;
end);

InstallMethod(DigraphVertexNames, "for a digraph and pos int",
[IsDigraph], 
function(graph)

  if not IsBound(graph!.vertexnames) then 
    graph!.vertexnames := [1 .. DigraphNrVertices(graph)];
  fi;
  return graph!.vertexnames;
end);

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
function(trans)
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

  verts := [ 1 .. n ];
  adj := [ ];

  for i in verts do
    nr := Random(verts);
    adj[i] := [ ];
    for j in [ 1 .. nr ] do
      AddSet(adj[i], Random(verts));
    od;
  od;

  gr := DigraphNC(adj);
  SetIsMultiDigraph(gr, false);
  return gr;
end);

#

InstallMethod(RandomTournament, "for an integer",
[IsInt],
function(n)
  local verts, choice, nr, source, range, count, gr, i, j;
  
  if n < 0 then
    Error("Digraphs: RandomTournament: usage,\n",
    "the argument <n> must be a non-negative integer,\n");
    return;
  elif n = 0 then
    gr := EmptyDigraph(0);
  else
    verts := [ 1 .. n ];
    choice := [ true, false ];
    nr := n * (n - 1) / 2;
    source := EmptyPlist( nr );
    range := EmptyPlist( nr );
    count := 0;
    for i in verts do
      for j in [ (i + 1) .. n ] do
        count := count + 1;
        if Random(choice) then
          source[count] := i;
          range[count] := j;
        else
          source[count] := j;
          range[count] := i;
        fi;
      od;
    od;
    range := Permuted(range, Sortex(source));
    gr := DigraphNC(rec( nrvertices := n, source := source, range := range )); 
    SetDigraphNrEdges(gr, nr);
  fi;
  SetIsAntisymmetricDigraph(gr, true);
  # Commented out for now to allow testing of IsTournament
  # SetIsTournament(gr, true);
  return gr;

end);

#

InstallMethod(CompleteDigraph, "for an integer",
[IsInt],
function(n)
  local verts, adj, gr, i;
  
  if n < 0 then
    Error("Digraphs: CompleteDigraph: usage,\n",
      "the argument <n> must be a non-negative integer,\n");
    return;
  elif n = 0 then
    gr := DigraphNC( [ ] );
    SetIsEmptyDigraph(gr, true);
  else
    verts := [ 1 .. n ];
    adj := EmptyPlist(n);
    for i in verts do
      adj[i] := verts;
    od;
    gr := DigraphNC(adj);
  fi;
  SetIsMultiDigraph(gr, false);
  SetIsSymmetricDigraph(gr, true);
  SetIsCompleteDigraph(gr, true);
  return gr;
end);

#

InstallMethod(EmptyDigraph, "for an integer",
[IsInt],
function(n)
  local gr;

  if n < 0 then
    Error("Digraphs: EmptyDigraph: usage,\n",
      "the argument <n> must be a non-negative integer,\n");
    return;
  fi;
  gr := DigraphNC( rec( nrvertices := n, source := [ ], range := [ ] ) );
  SetIsEmptyDigraph(gr, true);
  SetIsMultiDigraph(gr, false);
  return gr;
end);

#

InstallMethod(CycleDigraph, "for a positive integer",
[IsPosInt],
function(n)
  local gr, source, range, i;

  source := EmptyPlist(n);
  range := EmptyPlist(n);
  for i in [ 1 .. (n - 1) ] do
    source[i] := i;
    range[i] := i + 1;
  od;
  source[n] := n;
  range[n] := 1;
  gr := DigraphNC( rec( nrvertices := n, source := source, range := range ) );
  SetIsAcyclicDigraph(gr, false);
  SetIsEmptyDigraph(gr, false);
  SetIsMultiDigraph(gr, false);
  SetDigraphNrEdges(gr, n);
  SetIsFunctionalDigraph(gr, true);
  return gr;
end);

#

InstallMethod(CompleteBipartiteDigraph, "for two positive integers",
[IsPosInt, IsPosInt],
function(m, n)
  local source, range, count, k, r, gr, i, j;

  source := EmptyPlist(2 * m * n);
  range := EmptyPlist(2 * m * n);
  count := 0;
  for i in [ 1 .. m ] do
    for j in [ 1 .. n ] do
      count := count + 1;
      source[count] := i;
      range[count] := m + j;
      k := (m * n) + ( (j - 1) * m ) + i; # This ensures that source is sorted
      source[k] := m + j;
      range[k] := i;
    od;
  od;
  r := rec( nrvertices := m + n, source := source, range := range );
  gr := DigraphNC(r);
  SetIsSymmetricDigraph(gr, true);
  SetDigraphNrEdges(gr, 2 * m * n);
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
          "the argument must be a record with components:\n",
          "'source', 'range', and either 'vertices' or 'nrvertices',\n");
    return;
  fi;

  if not (IsList(graph.source) and IsList(graph.range)) then
    Error("Digraphs: Digraph: usage,\n",
          "the graph components 'source' and 'range' should be lists,\n");
    return;
  fi;
  
  if Length(graph.source) <> Length(graph.range) then
    Error("Digraphs: Digraph: usage,\n",
          "the record components ",
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
    if IsBound(graph.vertices) and
     not (IsList(graph.vertices) and Length(graph.vertices) = graph.nrvertices) then
      Error("Digraphs: Digraph: usage,\n",
            "the record components 'nrvertices' and 'vertices' are inconsistent,\n");
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
      for i in [ 1 .. Length(graph.range) ] do
        graph.range[i] := Position(graph.vertices, graph.range[i]);
        graph.source[i] := Position(graph.vertices, graph.source[i]);
      od;
      graph.vertexnames := graph.vertices;
      Unbind(graph.vertices);
    fi;
  fi;

  # make sure that the graph.source is sorted, and range is too
  graph.range := Permuted(graph.range, Sortex(graph.source));

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
      if not IsPosInt(y)
         or y > nr then
        Error("Digraphs: Digraph: usage,\n",
              "the argument must be a list of lists of positive integers\n",
              "not exceeding the length of the argument,\n");
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
        Error("Digraphs: DigraphByAdjacencyMatrix: usage,\n",
              "the argument must be a matrix of non-negative integers,\n");
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

  for i in [1 .. Maximum(Length(adj), max_range)] do 
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

  adj := List( [ 1.. n ], x-> [  ]);

  for edge in edges do
    if edge[1] > n or edge[2] > n then
      Error("Digraphs: DigraphByEdges: usage,\n",
            "the specified edges must not contain values greater than ",
            n, ",\n");
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
  local sources, source, range1, range2, m, n, stop, start, a, b, i;
  
  if DigraphVertices(graph1) <> DigraphVertices(graph2) or
     DigraphSource(graph1) <> DigraphSource(graph2) then
    return false;
  elif IsEmpty(DigraphRange(graph1)) and IsEmpty(DigraphRange(graph2)) then
    return true;
  fi;

  source := DigraphSource(graph1);
  sources := Set(source);
  range1 := DigraphRange(graph1);
  range2 := DigraphRange(graph2);
  m := Length(source);
  n := Length(sources);

  stop := 1;
  for i in [ 2 .. n ] do
    start := stop;
    stop := Position(source, sources[i]);
    a := range1{ [ start .. (stop - 1) ] };
    b := range2{ [ start .. (stop - 1) ] };
    Sort(a);
    Sort(b);
    if a <> b then
      return false;
    fi;
  od;
  a := range1{ [ stop .. m ] };
  b := range2{ [ stop .. m ] };
  Sort(a);
  Sort(b);
  if a <> b then
    return false;
  fi;

  return true;

end);

#EOF
