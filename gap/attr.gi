#############################################################################
##
#W  attrs.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallMethod(DigraphDual, "for a digraph by adjacency", 
[IsDigraphByAdjacency], 
function(graph)
  local verts, old, new, i;

  verts := Vertices(graph);
  old := Adjacencies(graph);
  new := [];

  for i in verts do 
    new[i]:=DifferenceLists(verts, old[i]);
  od;
  return DigraphNC(new);
end);

#

InstallMethod(NrVertices, "for a digraph",
[IsDigraph],
function(graph)
  return graph!.nrvertices;
end);

# IsDigraphByAdjacency implies IsSimpleDigraph

InstallMethod(NrEdges, "for a digraph by adjacency",
[IsDigraphByAdjacency],
function(graph)
  return Sum(List(Adjacencies(graph), Length));
end);

InstallMethod(NrEdges, "for a digraph",
[IsDigraph and HasSource], 
function(graph)
  return Length(Source(graph));
end);

# IsDigraphByAdjacency implies IsSimpleDigraph

InstallMethod(Edges, "for a digraph by adjacency",
[IsDigraphByAdjacency],
function(graph)
  local adj, nr, out, i, j;

  adj := Adjacencies(graph);
  nr := 0;
  out := [];

  for i in Vertices(graph) do 
    for j in adj[i] do 
      nr := nr + 1;
      out[nr] := [i, j];
    od;
  od;
  return out;
end);
  
InstallMethod(Edges, "for a digraph",
[IsDigraph],
function(graph)
  local out, range, source, i;

  out:=EmptyPlist(Length(Range(graph)));
  range:=Range(graph);
  source:=Source(graph);

  for i in [1..Length(source)] do
    out[i]:=[source[i], range[i]];
  od;
  return out;
end);

# attributes for digraphs . . .

InstallMethod(GrapeGraph, "for a digraph", 
[IsDigraph], Graph);

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

InstallMethod(Vertices, "for a digraph",
[IsDigraph],
function(graph)
  return [ 1 .. NrVertices(graph) ];
end);

InstallMethod(Range, "for a digraph by adjacency",
[IsDigraphByAdjacency],
function(graph)
  DIGRAPHS_RangeSource(graph);
  return graph!.range;
end);

InstallMethod(Source, "for a digraph by adjacency",
[IsDigraphByAdjacency],
function(graph)
  DIGRAPHS_RangeSource(graph);
  return graph!.source;
end);

if IsBound(DIGRAPH_ADJACENCY) then
  InstallMethod(Adjacencies, "for a digraph",
  [IsDigraphBySourceAndRange], DIGRAPH_ADJACENCY);
else
  InstallMethod(Adjacencies, "for a digraph by source and range",
  [IsDigraphBySourceAndRange],
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

InstallMethod(AdjacencyMatrix, "for a digraph by adjacency",
[IsDigraphByAdjacency], 
function(graph)
  local verts, adj, out, i;
  
  verts := Vertices(graph);
  adj := Adjacencies(graph);
  
  out := EmptyPlist(NrVertices(graph));
  
  for i in verts do 
    out[i] := verts * 0;
    out[i]{adj[i]} := ( [1 .. Length(adj[i])] * 0 ) + 1;
  od;
  return out;
end);

InstallMethod(AdjacencyMatrix, "for a digraph by source and range",
[IsDigraphBySourceAndRange], 
function(graph)
  local verts, source, range, out, i;
  
  verts := Vertices(graph);
  source := Source(graph);
  range := Range(graph);

  out := EmptyPlist(NrVertices(graph));
  
  for i in verts do 
    out[i] := verts * 0;
  od;
  
  for i in [1..Length(source)] do 
    out[source[i]][range[i]] := out[source[i]][range[i]] + 1;
  od;
  
  return out;  
end);

if IsBound(DIGRAPH_TOPO_SORT) then
  InstallMethod(DigraphTopologicalSort, "for a digraph",
  [IsDigraph], function(graph)
    return DIGRAPH_TOPO_SORT(Adjacencies(graph));
  end);
else
  InstallMethod(DigraphTopologicalSort, "for a digraph",
  [IsDigraph],
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
            SetIsAcyclicDigraph(graph, false);
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

# the scc index 1 corresponds to the "deepest" scc, i.e. the minimal ideal in
# our case...

if IsBound(GABOW_SCC) then
  InstallMethod(DigraphStronglyConnectedComponents, "for a digraph",
  [IsDigraph],
  function(digraph)
    return GABOW_SCC(Adjacencies(digraph));
  end);
else
  InstallMethod(DigraphStronglyConnectedComponents, "for a digraph",
  [IsDigraph],
  function(digraph)
    local n, stack1, len1, stack2, len2, id, count, comps, fptr, level, nr, w, comp, v;

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
              nr := 0;
              repeat
                nr := nr + 1;
                w := stack1[len1];
                len1 := len1 - 1;
                id[w] := count;
              until w = fptr[2 * level - 1];
              comp := stack1{[len1 + 1..len1 + nr]};
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
