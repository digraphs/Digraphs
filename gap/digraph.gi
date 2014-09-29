#############################################################################
##
#W  digraph.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# vertices should always be a range (to save space, and improve membership
# checking performance), adjacencies should be a plist of plist.

# constructors

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
    IsBound(record.vertices)) then
    Error("usage: the argument must be a record with components `source',",
    " `range', and `vertices'");
    return;
  fi;

  if not (IsList(record.vertices) and IsList(record.source) and
    IsList(record.range)) then
    Error("usage: the record components 'vertices', 'source'",
    " and 'range' should be lists,");
    return;
  fi;

  if Length(record.source)<>Length(record.range) then
    Error("usage: the record components 'source'",
    " and 'range' should be of equal length,");
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

  record:=StructuralCopy(record);

  # rewrite the vertices to numbers
  if record.vertices<>[1..Length(record.vertices)] then
    record.names:=record.vertices;
    record.vertices:=[1..Length(record.names)];
    for i in [1..Length(record.range)] do
      record.range[i]:=Position(record.names, record.range[i]);
      record.source[i]:=Position(record.names, record.source[i]);
    od;
  else
    record.names := record.vertices;
  fi;

  if not IsRangeRep(record.vertices) then
    ConvertToRangeRep(record.vertices);
  fi;

  # make sure that the record.source is sorted
  record.range:=Permuted(record.range, Sortex(record.source));

  MakeImmutable(record.range);
  MakeImmutable(record.source);
  MakeImmutable(record.vertices);
  MakeImmutable(record.names);

  return Objectify(DirectedGraphType, record);
end);

#

InstallMethod(DirectedGraphNC, "for a record", [IsRecord],
function(record)
  local i;

  if IsGraph(record) then
    return DirectedGraphNC(List(Vertices(record), x-> Adjacency(record, x)));
  fi;

  record:=StructuralCopy(record);

  MakeImmutable(record.range);
  MakeImmutable(record.source);
  MakeImmutable(record.vertices);

  if not IsBound(record.names) then
    record.names := record.vertices;
  else
    MakeImmutable(record.names);
  fi;

  return Objectify(DirectedGraphType, record);
end);

#

InstallMethod(DirectedGraph, "for a list of lists of pos ints",
[IsList],
function(adj)
  local len, x, record, i;

  len := Length(adj);
  adj := StructuralCopy(adj);

  for x in adj do
    if IsDuplicateFreeList(x) then
      for i in x do
        if not (IsPosInt(i) and i <= len) then
          Error("usage: the argument must be a list of duplicate free lists of positive",
          " integers not exceeding the length of the argument,");
          return;
        fi;
      od;
      x := x * 1; # make sure that lists in <adj> are plists
    else
      Error("usage: the argument must be a list of duplicate free lists,");
      return;
    fi;
  od;

  record:=rec( adj := adj );
  ObjectifyWithAttributes(record, DirectedGraphType, Adjacencies, adj);
  return record;
end);

InstallMethod(DirectedGraphNC, "for a list of lists of pos ints", [IsList],
function(adj)
  local record;
  record := rec( adj := StructuralCopy(adj) );
  ObjectifyWithAttributes(record, DirectedGraphType, Adjacencies, record.adj);
  return record;
end);

#

InstallMethod(DirectedGraphByAdjacencyMatrix, "for a rectangular table",
[IsRectangularTable],
function(mat)
  local n, record, i, j, k, out;

  n := Length(mat);

  if Length(mat[1]) <> n then
    Error("the given matrix is not square, so not an adjacency matrix, ");
    return;
  fi;

  record := rec( vertices := [ 1 .. n ], source := [], range := [] );
  for i in [1..n] do
    for j in [1..n] do
      if IsPosInt(mat[i][j]) or mat[i][j] = 0 then 
        for k in [1..mat[i][j]] do
          Add(record.source, i);
          Add(record.range, j);
        od;
      else
        Error("the given matrix is not solely non-negative integers, ");
        return;
      fi;
    od;
  od;
  out := DirectedGraph(record);
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
    Error("usage: the argument <edges> must be a list of pairs,");
    return;
  fi;

  if not (IsPosInt(edges[1][1]) and IsPosInt(edges[1][2])) then 
    Error("usage: the argument <edges> must be a list of pairs of pos ints,");
    return;
  fi;

  adj := List([1..n], x-> []);

  for edge in edges do
    if edge[1] > n or edge[2] > n then
      Error("more vertices are required than have been allowed,");
      return;
    fi;
    Add(adj[edge[1]], edge[2]);
  od;

  gr:=DirectedGraphNC(adj);
  SetEdges(gr, edges);
  return gr;
end);

# operators

InstallMethod(\=, "for directed graphs",
[IsDirectedGraph, IsDirectedGraph],
function(graph1, graph2)
  return Vertices(graph1)=Vertices(graph2) and Range(graph1)=Range(graph2)
   and Source(graph1)=Source(graph2);
end);

# simple means no multiple edges (loops are allowed)
if IsBound(IS_SIMPLE_DIGRAPH) then
  InstallMethod(IsSimpleDirectedGraph, "for a directed graph",
  [IsDirectedGraph], IS_SIMPLE_DIGRAPH);
else
  InstallMethod(IsSimpleDirectedGraph, "for a directed graph",
  [IsDirectedGraph],
  function(graph)
    local adj, nr, range, source, len, n, current, marked, x, i;

    if not HasRange(graph) then
      return true;
    elif HasAdjacencies(graph) then
      adj := Adjacencies(graph);
      nr := 0;
      for x in adj do
        nr := nr + Length(x);
      od;
      return nr = Length(Range(graph));
    else
      range := Range(graph);
      source := Source(graph);
      len := Length(range);
      n := Length(Vertices(graph));
      current := 0;
      marked := [ 1 .. n ] * 0;

      for i in [ 1 .. len ] do
        if source[i] <> current then
          current := source[i];
          marked[range[i]] := current;
        elif marked[range[i]] = current then
          return false;
        else
          marked[range[i]] := current;
        fi;
      od;
      return true;
    fi;

  end);
fi;

# Undirected means every (non-loop) edge has a complement edge
# JDM: improve!
InstallMethod(IsUndirectedGraph, "for a directed graph",
[IsDirectedGraph],
function(graph)
  local adj;
  adj := AdjacencyMatrix(graph);
  if adj = TransposedMat(adj) then
    return true;
  fi;
  return false;
end);

# Functional means: for every vertex v there is exactly one edge with source v

InstallMethod(IsFunctionalDirectedGraph, "for a directed graph",
[IsDirectedGraph],
function(graph)
  local n, adj, source;
  
  n := Length(Vertices(graph));
  
  if (not HasSource(graph)) and HasAdjacencies(graph) then
    adj := Adjacencies(graph);
    return ForAll(adj, x -> Length(x) = 1);
  fi;
  
  source := Source(graph);
  if Length(source) <> n then
    return false;
  fi;

  return Source(graph) = [ 1 .. n ];
end);

#

InstallMethod(ViewString, "for a directed graph",
[IsDirectedGraph],
function(graph)
  local str;

  str:="<directed graph with ";
  Append(str, String(Length(Vertices(graph))));
  Append(str, " vertices, ");
  Append(str, String(Length(Range(graph))));
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
  for nam in ["range", "source", "vertices"] do
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
  for nam in ["range", "source", "vertices"] do
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

# graph algorithms

InstallMethod(DirectedGraphRemoveLoops, "for a digraph",
[IsDirectedGraph],
function(graph)
  local source, range, newsource, newrange, i;

  source := Source(graph);
  range := Range(graph);

  newsource := [];
  newrange := [];

  for i in [ 1 .. Length(source) ] do
    if range[i] <> source[i] then
      Add(newrange, range[i]);
      Add(newsource, source[i]);
    fi;
  od;

  return DirectedGraphNC(rec( source:=newsource, range:=newrange,
                              vertices:=ShallowCopy(Vertices(graph))));
end);

InstallMethod(DirectedGraphRemoveEdges, "for a digraph and a list",
[IsDirectedGraph, IsList],
function(graph, edges)
  local range, vertices, source, newsource, newrange, i;

  if Length(edges) > 0 and IsPosInt(edges[1]) then # remove edges by index
    edges := Difference( [ 1 .. Length(Source(graph)) ], edges );

    return DirectedGraphNC(rec(
      source := Source(graph){edges},
      range := Range(graph){edges},
      vertices := ShallowCopy(Vertices(graph))));
  else
    if not IsSimpleDirectedGraph(graph) then
      Error("usage: to remove edges given as pairs of vertices,",
      " the graph must be simple,");
      return;
    fi;
    source := Source(graph);;
    range := Range(graph);;
    newsource := [ ];
    newrange := [ ];

    for i in [ 1 .. Length(source) ] do
      if not [ source[i], range[i] ] in edges then
        Add(newrange, range[i]);
        Add(newsource, source[i]);
      fi;
    od;

    return DirectedGraphNC(rec( source:=newsource, range:=newrange,
                                vertices:=ShallowCopy(Vertices(graph))));
  fi;
end);

InstallMethod(DirectedGraphRelabel, "for a digraph and perm",
[IsDirectedGraph, IsPerm],
function(graph, perm)

  if OnSets(ShallowCopy(Vertices(graph)), perm) <> Vertices(graph) then
    Error("usage: the 2nd argument <perm> must permute ",
    "the vertices of the 1st argument <graph>,");
    return;
  fi;

  return DirectedGraphNC(rec(
    source := ShallowCopy(OnTuples(Source(graph), perm)),
    range:= ShallowCopy(OnTuples(Range(graph), perm)),
    vertices:=ShallowCopy(Vertices(graph))));
end);

if IsBound(IS_ACYCLIC_DIGRAPH) then
  InstallMethod(IsAcyclicDirectedGraph, "for a digraph",
  [IsDirectedGraph], function(graph)
    return IS_ACYCLIC_DIGRAPH(Adjacencies(graph));
  end);
else
  InstallMethod(IsAcyclicDirectedGraph, "for a digraph",
  [IsDirectedGraph],
  function(graph)
    local adj, nr, vertex_complete, vertex_in_path, stack, level, j, k, i;

    adj := Adjacencies(graph);
    nr:=Length(adj);
    vertex_complete := BlistList([1..nr], []);
    vertex_in_path := BlistList([1..nr], []);
    stack:=EmptyPlist(2 * nr + 2);

    for i in [1..nr] do
      if Length(adj[i]) = 0 then
        vertex_complete[i] := true;
      elif not vertex_complete[i] then
        level := 1;
        stack[1] := i;
        stack[2] := 1;
        while true do
          j:=stack[2 * level - 1];
          k:=stack[2 * level];
          if vertex_in_path[j] then
            return false;  # We have just travelled around a cycle
          fi;
          # Check whether:
          # 1. We've previously finished with this vertex, OR
          # 2. Whether we've now investigated all branches descending from it
          if vertex_complete[j] or k > Length(adj[j]) then
            vertex_complete[j] := true;
            level := level - 1 ;
            if level = 0 then
              break;
            fi;
            # Backtrack and choose next available branch
            stack[2 * level]:=stack[2 * level] + 1;
            vertex_in_path[stack[2 * level - 1]] := false;
          else # Otherwise move onto the next available branch
            vertex_in_path[j] := true;
            level := level + 1;
            stack[2 * level - 1] := adj[j][k];
            stack[2 * level] := 1;
          fi;
        od;
      fi;
    od;
    return true;
  end);
fi;

InstallMethod(DirectedGraphFloydWarshall, "for a digraph",
[IsDirectedGraph],
function(graph)
  local dist, i, j, k, n, m;

  # Firstly assuming no multiple edges or loops. Will be easy to include.
  # Also not dealing with graph weightings.
  # Need discussions on suitability of data structures, etc

  n:=Length(Vertices(graph));
  m:=Length(Edges(graph));
  dist:=List([1..n],x->List([1..n],x->infinity));

  for i in [1..n] do
    dist[i][i]:=0;
  od;

  for i in [1..m] do
    dist[Source(graph)[i]][Range(graph)[i]]:=1;
  od;

  for k in [1..n] do
    for i in [1..n] do
      for j in [1..n] do
        if dist[i][k] <> infinity and dist[k][j] <> infinity and dist[i][j] > dist[i][k] + dist[k][j] then
          dist[i][j]:= dist[i][k] + dist[k][j];
        fi;
      od;
    od;
  od;

  return dist;

end);

# returns the vertices (i.e. numbers) of <digraph> ordered so that there are no
# edges from <out[j]> to <out[i]> for all <i> greater than <j>.

if IsBound(DIGRAPH_TOPO_SORT) then
  InstallMethod(DirectedGraphTopologicalSort, "for a digraph",
  [IsDirectedGraph], function(graph)
    return DIGRAPH_TOPO_SORT(Adjacencies(graph));
  end);
else
  InstallMethod(DirectedGraphTopologicalSort, "for a digraph",
  [IsDirectedGraph],
  function(graph)
    local adj, nr, vertex_complete, vertex_in_path, stack, out, level, j, k, i;

    adj := Adjacencies(graph);
    nr := Length(adj);
    vertex_complete := BlistList([1..nr], []);
    vertex_in_path := BlistList([1..nr], []);
    stack := EmptyPlist(2 * nr + 2);
    out := EmptyPlist(nr);

    for i in [1..nr] do
      if Length(adj[i]) = 0 then
        vertex_complete[i] := true;
      elif not vertex_complete[i] then
        level := 1;
        stack[1] := i;
        stack[2] := 1;
        while true do
          j := stack[2 * level - 1];
          k := stack[2 * level];
          if vertex_in_path[j] then
            SetIsAcyclicDirectedGraph(graph, false);
            #Error("the digraph has a cycle of length >1, ");
            return fail;
          fi;
          if vertex_complete[j] or k > Length(adj[j]) then
            if not vertex_complete[j] then
              Add(out, j);
            fi;
            vertex_complete[j] := true;
            level := level - 1;
            if level = 0 then
              break;
            fi;
              stack[2 * level] := stack[2 * level] + 1;
              vertex_in_path[stack[2 * level - 1]] := false;
          else
            vertex_in_path[j] := true;
            level := level + 1;
            stack[2 * level - 1] := adj[j][k];
            stack[2 * level] := 1;
          fi;
        od;
      fi;
    od;
    return out;
  end);
fi;

# JDM: requires a method for non-acyclic graphs

InstallMethod(DirectedGraphReflexiveTransitiveClosure,
"for a digraph", [IsDirectedGraph],
function(graph)
  local sorted, vertices, n, adj, out, trans, mat, flip, v, u, w;

  if not IsSimpleDirectedGraph(graph) then
    Error("usage: the argument should be a simple directed graph,");
    return;
  fi;

  vertices := Vertices(graph);
  n := Length(vertices);
  adj := Adjacencies(graph);
  sorted := DirectedGraphTopologicalSort(graph);

  if sorted <> fail then # Easier method for acyclic graphs (loops allowed)
    out := EmptyPlist(n);
    trans := EmptyPlist(n);

    for v in sorted do
      trans[v] := BlistList(vertices, [v]);
      for u in adj[v] do
        trans[v] := UnionBlist(trans[v], trans[u]);
      od;
      out[v] := ListBlist(vertices, trans[v]);
    od;

    out := DirectedGraphNC(out);
    SetIsSimpleDirectedGraph(out, true);
    return out;
  else # Non-acyclic method
    mat := List( vertices, x -> List( vertices, y -> infinity ) ); 

    for v in [ 1 .. n ] do # Make graph reflexive
      mat[v][v] := 1;
    od;

    for v in vertices do # Record edges
      for u in adj[v] do
        mat[v][u] := 1;
      od;
    od;

    for w in vertices do # Variation of Floyd Warshall
      for u in vertices do
        for v in vertices do
          if mat[u][w] <> infinity and mat[w][v] <> infinity then
            mat[u][v] := 1;
          fi;
        od;
      od;
    od;

    flip:=function(x)
      if x = infinity then
        return 0;
      else
        return 1;
      fi;
    end;

    mat := List( mat, x -> List( x, flip ) ); # Create adjacency matrix
    out := DirectedGraphByAdjacencyMatrix(mat);
    SetIsSimpleDirectedGraph(out, true);
    return out;
  fi;
end);

# JDM: requires a method for non-acyclic graphs

InstallMethod(DirectedGraphTransitiveClosure, "for a digraph",
[IsDirectedGraph],
function(graph)
  local sorted, vertices, n, adj, out, trans, reflex, mat, flip, v, u, w;

  if not IsSimpleDirectedGraph(graph) then
    Error("usage: the argument should be a simple directed graph,");
    return;
  fi;

  vertices := Vertices(graph);
  n := Length(vertices);
  adj := Adjacencies(graph);
  sorted := DirectedGraphTopologicalSort(graph);

  if sorted <> fail then # Easier method for acyclic graphs (loops allowed)
    out := EmptyPlist(n);
    trans := EmptyPlist(n);

    for v in sorted do
      trans[v] := BlistList( vertices, [v]);
      reflex := false;
      for u in adj[v] do
        trans[v] := UnionBlist(trans[v], trans[u]);
        if u = v then
          reflex := true;
        fi;
      od;
      if not reflex then
        trans[v][v] := false;
      fi;
      out[v] := ListBlist(vertices, trans[v]);
      trans[v][v] := true;
    od;

    out := DirectedGraphNC(out);
    SetIsSimpleDirectedGraph(out, true);
    return out;
  else # Non-acyclic method

    mat := List( vertices, x -> List( vertices, y -> infinity ) ); 
    reflex := [ 1 .. n ] * 0;
    
    for v in vertices do # Assume graph reflexive for now
      mat[v][v] := 1;
    od;

    for v in vertices do # Record edges and remember loops
      for u in adj[v] do
        mat[v][u] := 1;
        if u = v then
          reflex[v] := 1;
        fi;
      od;
    od;

    for w in vertices do # Variation of Floyd Warshall
      for u in vertices do
        for v in vertices do
          if mat[u][w] <> infinity and mat[w][v] <> infinity then
            mat[u][v] := 1;
          fi;
        od;
      od;
    od;

    flip:=function(x)
      if x = infinity then
        return 0;
      else
        return 1;
      fi;
    end;

    mat := List( mat, x -> List( x, flip ) ); # Create adjacency matrix
    for v in vertices do # Only include original loops
      mat[v][v] := reflex[v]; 
    od;
    out := DirectedGraphByAdjacencyMatrix(mat);
    SetIsSimpleDirectedGraph(out, true);
    return out;
  fi;
end);

if IsBound(IS_STRONGLY_CONNECTED_DIGRAPH) then
  InstallMethod(IsStronglyConnectedDirectedGraph, "for a digraph",
  [IsDirectedGraph],
  function(graph)
    return IS_STRONGLY_CONNECTED_DIGRAPH(Adjacencies(graph));
  end);
else
  InstallMethod(IsStronglyConnectedDirectedGraph, "for a digraph",
  [IsDirectedGraph],
  function(graph)
    local adj, n, stack1, len1, stack2, len2, id, count, fptr, level, l, w, v;

    adj := Adjacencies(graph);
    n := Length(adj);

    if n = 0 then
      return true;
    fi;

    stack1 := EmptyPlist(n); len1 := 1;
    stack2 := EmptyPlist(n); len2 := 1;
    id:=[ 1 .. n ] * 0;
    level := 1;
    fptr := [];

    fptr[1] := 1; # vertex
    fptr[2] := 1; # adjacency index
    stack1[len1] := 1;
    stack2[len2] := len1;
    id[1] := len1;

    while true do # we always return before level = 0
      if fptr[2 * level] > Length(adj[fptr[2 * level - 1]]) then
        if stack2[len2] = id[fptr[2 * level - 1]] then
          repeat
            n := n - 1;
            w := stack1[len1];
            len1 := len1 - 1;
          until w = fptr[2 * level - 1];
          return (n = 0);
        fi;
        level := level - 1;
      else
        w := adj[fptr[2 * level - 1]][fptr[2 * level]];
        fptr[2 * level] := fptr[2 * level] + 1;

        if id[ w ] = 0 then
          level := level + 1;
          fptr[2 * level - 1] := w; #fptr[0], vertex
          fptr[2 * level ] := 1;   #fptr[2], index
          len1 := len1 + 1;
          stack1[ len1 ] := w;
          len2 := len2 + 1;
          stack2[ len2 ] := len1;
          id[ w ] := len1;
        else # we saw <w> earlier in this run
          while stack2[ len2 ] > id[ w ] do
            len2 := len2 - 1; # pop from stack2
          od;
        fi;
      fi;
    od;
  end);
fi;

# the scc index 1 corresponds to the "deepest" scc, i.e. the minimal ideal in
# our case...

if IsBound(GABOW_SCC) then
  InstallMethod(StronglyConnectedComponents, "for a directed graph",
  [IsDirectedGraph],
  function(digraph)
    return GABOW_SCC(Adjacencies(digraph));
  end);
else
  InstallMethod(StronglyConnectedComponents, "for a directed graph",
  [IsDirectedGraph],
  function(digraph)
    local n, stack1, len1, stack2, len2, id, count, comps, fptr, level, l, comp, w, v;

    digraph := Adjacencies(digraph);
    n := Length(digraph);

    if n = 0 then
      return rec( comps := [], id := []);
    fi;

    stack1 := EmptyPlist(n); len1 := 0;
    stack2 := EmptyPlist(n); len2 := 0;
    id := [ 1 .. n ] * 0;
    count := Length(digraph);
    comps := [];
    fptr := [];

    for v in [ 1 .. Length(digraph) ] do
      if id[v] = 0 then
        level := 1;
        fptr[1] := v; #fptr[0], vertex
        fptr[2] := 1; #fptr[2], index
        len1 := len1 + 1;
        stack1[len1] := v;
        len2 := len2 + 1;
        stack2[len2] := len1;
        id[v] := len1;

        while level > 0 do
          if fptr[ 2 * level] > Length(digraph[fptr[2 * level - 1]]) then
            if stack2[len2]=id[fptr[2 * level - 1]] then
              len2 := len2 - 1;
              count := count + 1;
              l := 0;
              comp := [];
              repeat
                w := stack1[len1];
                id[w] := count;
                len1 := len1 - 1; #pop from stack1
                l := l + 1;
                comp[l] := w;
              until w = fptr[2 * level - 1];
              ShrinkAllocationPlist(comp);
              MakeImmutable(comp);
              Add(comps, comp);
            fi;
            level := level - 1;
          else
            w := digraph[fptr[2 * level - 1]][fptr[2 * level]];
            fptr[2 * level] := fptr[2 * level] + 1;

            if id[w] = 0 then
              level := level + 1;
              fptr[2 * level - 1 ] := w; #fptr[0], vertex
              fptr[2 * level] := 1;   #fptr[2], index
              len1 := len1 + 1;
              stack1[len1] := w;
              len2 := len2 + 1;
              stack2[len2] := len1;
              id[w] := len1;

            else # we saw <w> earlier in this run
              while stack2[len2] > id[w] do
                len2 := len2 - 1; # pop from stack2
              od;
            fi;
          fi;
        od;
      fi;
    od;

    MakeImmutable(id);
    ShrinkAllocationPlist(comps);
    MakeImmutable(comps);
    return rec(id := id - Length(digraph), comps := comps);
  end);
fi;

#

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
  r := rec( vertices := [ 1 .. int ], source := [ 1 .. int ], range := ran );
  gr := DirectedGraphNC(r);
  
  SetIsSimpleDirectedGraph(gr, true);
  SetIsFunctionalDirectedGraph(gr, true);
  
  return gr;
end);

#EOF
