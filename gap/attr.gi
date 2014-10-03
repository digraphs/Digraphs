#############################################################################
##
#W  attrs.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallMethod(DigraphDual, "for a directed graph", 
[IsDirectedGraph], 
function(graph)
  local verts, old, new, i;

  if not IsSimpleDirectedGraph(graph) then 
    Error("Digraphs: DigraphDual: usage, the argument must be a simple",
    " digraph,");
    return;
  fi;

  verts := Vertices(graph);
  old := Adjacencies(graph);
  new := [];

  for i in verts do 
    new[i]:=DifferenceLists(verts, old[i]);
  od;
  return DirectedGraphNC(new);
end);

#

InstallMethod(NrVertices, "for a directed graph",
[IsDirectedGraph],
function(graph)
  return graph!.nrvertices;
end);

#

InstallMethod(NrEdges, "for a directed graph",
[IsDirectedGraph],
function(graph)
  if not HasSource(graph) 
    and (HasAdjacencies(graph) and IsSimpleDirectedGraph(graph)) then 
    return Sum(List(Adjacencies(graph), Length));
  fi;

  return Length(Source(graph));
end);

# attributes for directed graphs . . .

InstallMethod(GrapeGraph, "for a directed graph", 
[IsDirectedGraph], Graph);

BindGlobal("DIGRAPHS_RangeSource",
function(graph)
  local adj, nr, source, range, j, i;

  if IsBound(graph!.range) then
    return;
  fi;

  adj := Adjacencies(graph);
  nr := 0;

  for j in adj do
    nr := nr + Length(j);
  od;

  source := EmptyPlist(nr);
  range := EmptyPlist(nr);
  nr := 0;

  for i in [1..Length(adj)] do
    for j in adj[i] do
      nr := nr + 1;
      source[nr] := i;
      range[nr] := j;
    od;
  od;

  graph!.range := range;
  graph!.source := source;

  return;
end);


#

InstallMethod(Vertices, "for a directed graph",
[IsDirectedGraph],
function(graph)
  return [ 1 .. NrVertices(graph) ];
end);

InstallMethod(Range, "for a directed graph",
[IsDirectedGraph],
function(graph)
  DIGRAPHS_RangeSource(graph);
  return graph!.range;
end);

InstallMethod(Source, "for a directed graph",
[IsDirectedGraph],
function(graph)
  DIGRAPHS_RangeSource(graph);
  return graph!.source;
end);

InstallMethod(Edges, "for a directed graph",
[IsDirectedGraph],
function(graph)
  local out, range, source, i;

  out:=EmptyPlist(Length(Range(graph)));
  range:=Range(graph);
  source:=Source(graph);
  for i in [1..Length(source)] do
    out[i]:=[source[i], range[i]];
  od;
  return Set(out);
end);

if IsBound(DIGRAPH_ADJACENCY) then
  InstallMethod(Adjacencies, "for a directed graph",
  [IsDirectedGraph], DIGRAPH_ADJACENCY);
else
  InstallMethod(Adjacencies, "for a directed graph",
  [IsDirectedGraph],
  function(graph)
    local range, source, out, i;

    range:=Range(graph);
    source:=Source(graph);
    out:=List(Vertices(graph), x-> []);

    for i in [1..Length(source)] do
      AddSet(out[source[i]], range[i]);
    od;

    MakeImmutable(out);
    graph!.adj := out;
    return out;
  end);
fi;

InstallMethod(AdjacencyMatrix, "for a directed graph",
[IsDirectedGraph], 
function(graph)
  local n, out, verts, adj, source, range, i;
  
  n := Length(Vertices(graph));
  out := EmptyPlist(n);
  verts := [ 1 .. n ];

  if HasIsSimpleDirectedGraph(graph) and IsSimpleDirectedGraph(graph) and HasAdjacencies(graph) then 
    adj := Adjacencies(graph);
    for i in verts do 
      out[i] := verts * 0;
      out[i]{adj[i]} := ( [1 .. Length(adj[i])] * 0 ) + 1;
    od;
    return out;
  fi;
  
  source := Source(graph);
  range := Range(graph);

  out := EmptyPlist(n);
  
  for i in verts do 
    out[i] := verts * 0;
  od;
  
  for i in [1..Length(source)] do 
    out[source[i]][range[i]] := out[source[i]][range[i]] + 1;
  od;
  
  return out;  
end);

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
    if nr <= 1 then
      return Vertices(graph);
    fi;
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
            # Note: can't enter this if level <= 1
            SetIsAcyclicDirectedGraph(graph, false);
            level := level - 1;
            if stack[2 * level - 1] <> j then # Cycle is not just a loop 
              return fail;
            fi;
            stack[2 * level] := stack[2 * level] + 1;
            vertex_in_path[j] := false;
          elif vertex_complete[j] or k > Length(adj[j]) then
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
