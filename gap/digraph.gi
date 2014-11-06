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

  out := List( [ 1 .. n ], x -> [ ] );
  
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

InstallMethod(Digraph, "for a binary relation",
[IsBinaryRelation],
function(rel)
  local d, out, gr, i;
  
  d := GeneratorsOfDomain(UnderlyingDomainOfBinaryRelation(rel));
  if not IsRange(d) or d[1] <> 1 then
    Error("Digraphs: Digraph: usage,\n",
          "the argument <rel> must be a binary relation\n",
          "on the domain [ 1 .. n ] for some positive integer n,");
    return;
  fi;
  out := EmptyPlist(Length(d));
  for i in d do
    out[i] := ImagesElm( rel, i );
  od;
  gr := DigraphNC(out);
  SetIsMultiDigraph(gr, false);
  if HasIsReflexiveBinaryRelation(rel) then
    SetIsReflexiveDigraph(gr, IsReflexiveBinaryRelation(rel));
  fi;
  if HasIsSymmetricBinaryRelation(rel) then
    SetIsSymmetricDigraph(gr, IsSymmetricBinaryRelation(rel));
  fi;
  if HasIsTransitiveBinaryRelation(rel) then
    SetIsTransitiveDigraph(gr, IsTransitiveBinaryRelation(rel));
  fi;
  if HasIsAntisymmetricBinaryRelation(rel) then
    SetIsAntisymmetricDigraph(gr, IsAntisymmetricBinaryRelation(rel));
  fi;
  return gr;
end);

InstallMethod(SetDigraphVertexName, "for a digraph, pos int, object",
[IsDigraph, IsPosInt, IsObject], 
function(graph, i, name)

  if not IsBound(graph!.vertexnames) then 
    graph!.vertexnames := [ 1 .. DigraphNrVertices(graph) ];
  fi;

  if i > DigraphNrVertices(graph) then 
    Error("Digraphs: SetDigraphVertexName: usage,\n",
    "there are only ",  DigraphNrVertices(graph), " vertices,");
    return;
  fi;
  graph!.vertexnames[i] := name;
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
   i, " is nameless or not a vertex,");
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
    " to the number of\nvertices of the digraph,");
    return;
  fi;
  return;
end);

InstallMethod(DigraphVertexNames, "for a digraph and pos int",
[IsDigraph], 
function(graph)

  if not IsBound(graph!.vertexnames) then 
    graph!.vertexnames := [ 1 .. DigraphNrVertices(graph) ];
  fi;
  return graph!.vertexnames;
end);

InstallMethod(SetDigraphEdgeLabel, "for a digraph, pos int, object",
[IsDigraph, IsPosInt, IsObject], 
function(graph, i, name)

  if not IsBound(graph!.edgelabels) then 
    graph!.edgelabels := [ 1 .. DigraphNrEdges(graph) ];
  fi;

  if i > DigraphNrEdges(graph) then 
    Error("Digraphs: SetDigraphEdgeLabel: usage,\n",
    "there are only ",  DigraphNrEdges(graph), " vertices,");
    return;
  fi;
  graph!.edgelabels[i] := name;
  return;
end);

InstallMethod(DigraphEdgeLabel, "for a digraph and pos int",
[IsDigraph, IsPosInt], 
function(graph, i)

  if not IsBound(graph!.edgelabels) then 
    graph!.edgelabels := [1 .. DigraphNrEdges(graph)];
  fi;

  if IsBound(graph!.edgelabels[i]) then 
    return graph!.edgelabels[i];
  fi;
  Error("Digraphs: DigraphEdgeLabel: usage,\n",
   i, " is nameless or not a vertex,");
  return;
end);

InstallMethod(SetDigraphEdgeLabels, "for a digraph and list",
[IsDigraph, IsList], 
function(graph, names)
  
  if Length(names) = DigraphNrEdges(graph) then 
    graph!.edgelabels := names;
  else 
    Error("Digraphs: SetDigraphEdgeLabels: usage,\n",
    "the 2nd arument <names> must be a list with length equal",
    " to the number of\nvertices of the digraph,");
    return;
  fi;
  return;
end);

InstallMethod(DigraphEdgeLabels, "for a digraph and pos int",
[IsDigraph], 
function(graph)

  if not IsBound(graph!.edgelabels) then 
    graph!.edgelabels := [ 1 .. DigraphNrEdges(graph) ];
  fi;
  return graph!.edgelabels;
end);

# multi means it has at least one multiple edges

InstallMethod(IsMultiDigraph, "for a digraph",
[IsDigraph], IS_MULTI_DIGRAPH);

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
  local ran, out, gr, i;
  
  if int < 0 then
    Error("Digraphs: AsDigraph: usage,\n",
          "the second argument should be a non-negative integer,");
    return;
  fi;

  ran := ListTransformation(trans, int);
  out := EmptyPlist(int);
  for i in [ 1 .. int ] do
    out[i] := [ ran[i] ];
  od;
  gr := DigraphNC(out);
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

#

InstallMethod(RandomDigraph, "for a pos int",
[IsPosInt],
function(n)
  return RandomDigraph( n, Float(Random([0..10000]))/10000 );
end);

InstallMethod(RandomDigraph, "for a pos int and a float",
[IsPosInt, IsFloat],
function(n, p)
  local out, lim;
  
  if p < 0.0 or 1.0 < p then
    Error("Digraphs: RandomDigraph: usage,\n",
    "the second argument <p> must be a float between 0 and 1,");
  fi;
  out := DigraphNC( RANDOM_DIGRAPH( n, Int( p * 10000 ) ) );
  SetIsMultiDigraph(out, false);
  return out;
end);

#

InstallMethod(RandomMultiDigraph, "for a pos int",
[IsPosInt],
function(n)
  return RandomMultiDigraph( n, Random( [ 1 .. ( n * (n - 1) ) / 2 ] ) );
end);

InstallMethod(RandomMultiDigraph, "for two pos ints",
[IsPosInt, IsPosInt],
function(n, m)
  return DigraphNC( RANDOM_MULTI_DIGRAPH( n, m ) );
end);

#

InstallMethod(RandomTournament, "for an integer",
[IsInt],
function(n)
  local gr, choice, nr, out, i, j;
  
  if n < 0 then
    Error("Digraphs: RandomTournament: usage,\n",
    "the argument <n> must be a non-negative integer,");
    return;
  elif n = 0 then
    gr := EmptyDigraph(0);
  else
    choice := [ true, false ];
    nr := n * (n - 1) / 2;
    out := [ ];
    for i in [ 1 .. n ] do
      out[ i ] := [ ];
      for j in [ (i + 1) .. n ] do
        if Random(choice) then
          Add(out[i], j);
        else
          if IsBound(out[j]) then
            Add(out[j], i);
          else
          out[j] := [ i ];
          fi;
        fi;
      od;
    od;
    gr := DigraphNC(out);
    SetDigraphNrEdges(gr, nr);
  fi;
  SetIsTournament(gr, true);
  return gr;
end);

#

InstallMethod(CompleteDigraph, "for an integer",
[IsInt],
function(n)
  local verts, out, gr, i;
  
  if n < 0 then
    Error("Digraphs: CompleteDigraph: usage,\n",
      "the argument <n> must be a non-negative integer,");
    return;
  elif n = 0 then
    gr := EmptyDigraph(0);
  else
    verts := [ 1 .. n ];
    out := EmptyPlist(n);
    for i in verts do
      out[i] := Concatenation( [ 1 .. (i - 1) ], [ (i + 1) .. n ] );
    od;
    gr := DigraphNC(out);
    SetIsEmptyDigraph(gr, false);
    SetIsAcyclicDigraph(gr, false);
    if n > 1 then
      SetIsAntisymmetricDigraph(gr, true);
    fi;
  fi;
  SetIsMultiDigraph(gr, false);
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
      "the argument <n> must be a non-negative integer,");
    return;
  fi;
  gr := DigraphNC( List( [ 1 .. n ], x -> [  ] ) );
  SetIsEmptyDigraph(gr, true);
  SetIsMultiDigraph(gr, false);
  return gr;
end);

#

InstallMethod(CycleDigraph, "for a positive integer",
[IsPosInt],
function(n)
  local gr, i, out;

  out := EmptyPlist(n);
  for i in [ 1 .. n - 1 ] do
    out[i] := [ i + 1 ];
  od;
  out[n] := [ 1 ];
  gr := DigraphNC( out ); 
  if n = 1 then
    SetIsTransitiveDigraph(gr, true);
    SetDigraphHasLoops(gr, true);
  else
    SetIsTransitiveDigraph(gr, false);
    SetDigraphHasLoops(gr, false);
  fi;
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
      k := (m * n) + ( (j - 1) * m ) + i; # Ensures that source is sorted
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
          "'source', 'range', and either 'vertices' or 'nrvertices',");
    return;
  fi;

  if not (IsList(graph.source) and IsList(graph.range)) then
    Error("Digraphs: Digraph: usage,\n",
          "the graph components 'source' and 'range' should be lists,");
    return;
  fi;
  
  if Length(graph.source) <> Length(graph.range) then
    Error("Digraphs: Digraph: usage,\n",
          "the record components ",
          "'source' and 'range' should have equal length,");
    return;
  fi;
  
  check_source := true;

  if IsBound(graph.nrvertices) then 
    if not (IsInt(graph.nrvertices) and graph.nrvertices >= 0) then 
      Error("Digraphs: Digraph: usage,\n",
            "the record component 'nrvertices' ",
            "should be a non-negative integer,");
      return;
    fi;
    if IsBound(graph.vertices) and
     not (IsList(graph.vertices) and Length(graph.vertices) = graph.nrvertices) then
      Error("Digraphs: Digraph: usage,\n",
        "the record components 'nrvertices' and 'vertices' are inconsistent,");
      return;
    fi;
    cmp := LT;
    obj := graph.nrvertices + 1;
    
    if IsRange(graph.source) then 
      if not IsEmpty(graph.source) and (graph.source[1] < 1 or
         graph.source[Length(graph.source)] > graph.nrvertices) then 
        Error("Digraphs: Digraph: usage,\n",
              "the record component 'source' is invalid,");
        return;
      fi;
      check_source := false;
    fi;

  elif IsBound(graph.vertices) then 
    if not IsList(graph.vertices) then
      Error("Digraphs: Digraph: usage,\n",
            "the record component 'vertices' should be a list,");
      return;
    fi;
    cmp := \in;
    obj := graph.vertices;
    graph.nrvertices := Length(graph.vertices);
  fi;

  if check_source and not ForAll(graph.source, x-> cmp(x, obj)) then
    Error("Digraphs: Digraph: usage,\n",
          "the record component 'source' is invalid,");
    return;
  fi;

  if not ForAll(graph.range, x-> cmp(x, obj)) then
    Error("Digraphs: Digraph: usage,\n",
          "the record component 'range' is invalid,");
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
  local out;
  ObjectifyWithAttributes(graph, DigraphType, DigraphRange,
   graph.range, DigraphSource, graph.source);
  
  # Temporary probably; make sure it works 
  out := DIGRAPH_OUT_NBS( graph!.nrvertices, graph!.source, graph!.range );
  graph!.adj := out;
  SetOutNeighbours(graph, out);
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
              "not exceeding the length of the argument,");
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
  local n, verts, out, count, i, j, k;

  n := Length(mat);

  if Length(mat[1]) <> n then
    Error("Digraphs: DigraphByAdjacencyMatrix: usage,\n",
          "the matrix is not square,");
    return;
  fi;

  verts := [ 1 .. n ];
  out := EmptyPlist(n);
  for i in verts do
    out[i] := [  ];
    count := 0;
    for j in verts do
      if IsInt(mat[i][j]) and mat[i][j] >= 0 then 
        for k in [ 1 .. mat[i][j] ] do
          count := count + 1;
          out[i][count] := j;
        od;
      else
        Error("Digraphs: DigraphByAdjacencyMatrix: usage,\n",
              "the argument must be a matrix of non-negative integers,");
        return;
      fi;
    od;
  od;
  out := DigraphNC(out);
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
  local n, verts, out, count, i, j, k;

  n := Length(mat);
  verts := [ 1 .. n ];
  out := EmptyPlist(n);
  for i in verts do
    out[i] := [  ];
    count := 0;
    for j in verts do
      for k in [ 1 .. mat[i][j] ] do
        count := count + 1;
        out[i][count] := j;
      od;
    od;
  od;
  out := DigraphNC(out);
  SetAdjacencyMatrix(out, mat);
  return out;
end);

#

InstallMethod(DigraphByAdjacencyMatrixNC, "for an empty list",
[IsList and IsEmpty],
function(mat)
  return EmptyDigraph(0);
end);

#

InstallMethod(DigraphByEdges, "for a rectangular table",
[IsRectangularTable],
function(edges)
  local adj, max_range, gr, edge, i;
  
  if not Length(edges[1]) = 2 then 
    Error("Digraphs: DigraphByEdges: usage,\n",
          "the argument <edges> must be a list of pairs,");
    return;
  fi;

  if not (IsPosInt(edges[1][1]) and IsPosInt(edges[1][2])) then 
    Error("Digraphs: DigraphByEdges: usage,\n",
          "the argument <edges> must be a list of pairs of pos ints,");
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

  for i in [ 1 .. Maximum(Length(adj), max_range) ] do 
    if not IsBound(adj[i]) then 
      adj[i] := [];
    fi;
  od;

  gr := DigraphNC(adj);
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
          "the argument <edges> must be a list of pairs,");
    return;
  fi;

  if not (IsPosInt(edges[1][1]) and IsPosInt(edges[1][2])) then 
    Error("Digraphs: DigraphByEdges: usage,\n",
          "the argument <edges> must be a list of pairs of pos ints,");
    return;
  fi;

  adj := List( [ 1 .. n ], x-> [  ] );

  for edge in edges do
    if edge[1] > n or edge[2] > n then
      Error("Digraphs: DigraphByEdges: usage,\n",
            "the specified edges must not contain values greater than ",
            n, ",");
      return;
    fi;
    Add(adj[edge[1]], edge[2]);
  od;

  gr := DigraphNC(adj);
  SetDigraphEdges(gr, edges);
  return gr;
end);

#

InstallMethod(DigraphByEdges, "for an empty list",
[IsList and IsEmpty],
function(edges)
  return EmptyDigraph(0);
end);

#

InstallMethod(DigraphByEdges, "for an empty list, and a pos int",
[IsList and IsEmpty, IsPosInt],
function(edges, n)
  return EmptyDigraph(n);
end);

# operators . . .

InstallMethod(\=, "for two digraphs",
[IsDigraph, IsDigraph],
DIGRAPH_EQUALS);

#

InstallMethod(DigraphCopy, "for a digraph",
[IsDigraph],
function(digraph)
  local out, gr;

  out := List(OutNeighbours(digraph), ShallowCopy);
  gr := DigraphNC(out);
  SetDigraphVertexNames(gr, DigraphVertexNames(digraph));
  return gr;
end);

# Printing, and viewing . . .

InstallMethod(ViewString, "for a digraph",
[IsDigraph],
function(graph)
  local str, n, m;
  
  str := "<";
  
  if IsMultiDigraph(graph) then 
    Append(str, "multi");
  fi;

  n := DigraphNrVertices(graph);
  m := DigraphNrEdges(graph);

  Append(str, "digraph with ");
  Append(str, String(n));
  if n = 1 then
    Append(str, " vertex, ");
  else
    Append(str, " vertices, ");
  fi;
  Append(str, String(m));
  if m = 1 then
    Append(str, " edge>");
  else
    Append(str, " edges>");
  fi;
  return str;
end);

#

InstallMethod(PrintString, "for a digraph",
[IsDigraph],
function(graph)
  local str;

  str:="Digraph( ";

  if DigraphNrEdges(graph) >= DigraphNrVertices(graph) then
    return Concatenation(str, PrintString(OutNeighbours(graph)), " )");
  else 
    Append(str, "\>\>rec(\n\>\>");
    SET_PRINT_OBJ_INDEX(1);
    str := Concatenation(str, "\<nrvertices := \>",
                          PrintString(DigraphNrVertices(graph)), "\<\<,\n\>\>");
    SET_PRINT_OBJ_INDEX(2);
    str := Concatenation(str, "\<source := \>",
                          PrintString(DigraphSource(graph)), "\<\<,\n\>\>");
    SET_PRINT_OBJ_INDEX(3);
    str := Concatenation(str, "\<range := \>",
                          PrintString(DigraphRange(graph)), "\<\<\n\>\>");
    Append(str, " \<\<) \<\<)");
    return str;
  fi;
end);

#

InstallMethod(String, "for a digraph",
[IsDigraph],
function(graph)
  local str;

  str:="Digraph( ";

  if DigraphNrEdges(graph) >= DigraphNrVertices(graph) then
    return Concatenation(str, String(OutNeighbours(graph)), " )");
  else
    Append(str, "rec( ");
    
    SET_PRINT_OBJ_INDEX(1);
    str := Concatenation(str,
                          "nrvertices := ", PrintString(DigraphNrVertices(graph)), ", ");
    SET_PRINT_OBJ_INDEX(2);
    str := Concatenation(str,
                          "source := ", PrintString(DigraphSource(graph)), ", ");
    SET_PRINT_OBJ_INDEX(3);
    str := Concatenation(str,
                          "range := ", PrintString(DigraphRange(graph)));
    Append(str, " ) )");
    return str;
  fi;
end);

#EOF
