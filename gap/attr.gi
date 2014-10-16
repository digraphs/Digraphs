#############################################################################
##
#W  attrs.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallMethod(DigraphDual, "for a digraph with out-neighbours", 
[IsDigraph and HasOutNeighbours], 
function(graph)
  local verts, old, new, i;
  
  if IsMultiDigraph(graph) then 
    Error("Digraphs: DigraphDual: usage,\n", 
      "the argument <graph> must not have multiple edges,\n");
    return;
  fi;
  
  verts := DigraphVertices(graph);
  old := OutNeighbours(graph);
  new := [];

  for i in verts do 
    new[i] := DifferenceLists(verts, old[i]);
  od;
  return DigraphNC(new);
end);

#

InstallMethod(DigraphDual, "for a digraph (without out-neighbours)", 
[IsDigraph], 
function(graph)
  local source, range, verts, m, n, new, empty, current, seen, count, i, j;
  
  if IsMultiDigraph(graph) then 
    Error("Digraphs: DigraphDual: usage,\n", 
      "the argument <graph> must not have multiple edges,\n");
    return;
  fi;
  
  source := DigraphSource(graph);
  range := DigraphRange(graph);
  verts := DigraphVertices(graph) * 1;
  m := DigraphNrEdges(graph);
  n := DigraphNrVertices(graph);
  if m = 0 then
    return CompleteDigraph(n);
  fi;
  new := EmptyPlist(n);
  empty := [];
  current := source[ 1 ];
  empty := [ 1 .. (current - 1) ];
  seen := [  ];
  count := 0;

  for i in [ 1 .. m ] do
    if source[i] > current then
      new[current] := DifferenceLists(verts, seen);
      empty := Concatenation(empty, [ (current + 1) .. (source[i] - 1) ]);
      current := source[i];
      seen := [ ];
      count := 0;
    fi;
    count := count + 1;
    seen[count] := range[i];
  od;

  new[ source[m] ] := DifferenceLists(verts, seen);
  empty := Concatenation(empty, [ (source[m] + 1) .. n ]);
  for i in empty do
    new[i] := verts;
  od;
  
  return DigraphNC(new);
end);

#

InstallMethod(DigraphNrVertices, "for a digraph",
[IsDigraph],
function(graph)
  return graph!.nrvertices;
end);

#

InstallMethod(DigraphNrEdges, "for a digraph with out-neighbours",
[IsDigraph and HasOutNeighbours],
function(graph)
  return Sum(List(OutNeighbours(graph), Length));
end);

InstallMethod(DigraphNrEdges, "for a digraph",
[IsDigraph and HasDigraphSource], 
function(graph)
  return Length(DigraphSource(graph));
end);

#

InstallMethod(DigraphEdges, "for a digraph with range",
[IsDigraph and HasDigraphRange],
function(graph)
  local out, range, source, i;

  out:=EmptyPlist(Length(DigraphRange(graph)));
  range:=DigraphRange(graph);
  source:=DigraphSource(graph);

  for i in [1..Length(source)] do
    out[i]:=[source[i], range[i]];
  od;
  return out;
end);

InstallMethod(DigraphEdges, "for a digraph",
[IsDigraph and HasOutNeighbours],
function(graph)
  local out, adj, nr, i, j;

  out := EmptyPlist(DigraphNrEdges(graph));
  adj := OutNeighbours(graph);
  nr := 0;
  
  for i in [ 1 .. Length(adj) ] do 
    for j in adj[i] do 
      nr := nr + 1;
      out[nr] :=[i, j];
    od;
  od;
  return out;   
end);

# attributes for digraphs . . .

InstallMethod(AsGraph, "for a digraph", [IsDigraph], Graph);

BindGlobal("DIGRAPHS_SourceRange",
function(graph)
  local adj, nr, source, range, j, i;

  if IsBound(graph!.range) then
    return;
  fi;

  adj := OutNeighbours(graph);
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

InstallMethod(DigraphVertices, "for a digraph",
[IsDigraph],
function(graph)
  return [ 1 .. DigraphNrVertices(graph) ];
end);

InstallMethod(DigraphRange, "for a digraph with out-neighbours",
[IsDigraph and HasOutNeighbours],
function(graph)
  DIGRAPHS_SourceRange(graph);
  return graph!.range;
end);

InstallMethod(DigraphSource, "for a digraph with out-neighbours",
[IsDigraph and HasOutNeighbours],
function(graph)
  DIGRAPHS_SourceRange(graph);
  return graph!.source;
end);

#

if IsBound(DIGRAPH_OUT_NBS) then
  InstallMethod(OutNeighbours, "for a digraph",
  [IsDigraph and HasDigraphSource], DIGRAPH_OUT_NBS);
else
  InstallMethod(OutNeighbours, "for a digraph with source and range",
  [IsDigraph and HasDigraphSource],
  function(graph)
    local range, source, out, i;

    range:=DigraphRange(graph);
    source:=DigraphSource(graph);
    out:=List(DigraphVertices(graph), x-> []);

    for i in [ 1 .. Length(source)] do
      Add(out[source[i]], range[i]);
    od;

    MakeImmutable(out);
    graph!.adj := out;
    return out;
  end);
fi;

InstallMethod(OutNeighbors, "for a digraph",
[IsDigraph], OutNeighbours);

#

if IsBound(DIGRAPH_IN_NBS) then
  InstallMethod(InNeighbours, "for a digraph",
  [IsDigraph], DIGRAPH_IN_NBS);
else
  InstallMethod(InNeighbours, "for a digraph with out-neighbours",
  [IsDigraph and HasOutNeighbours],
  function(graph)
    local out, inn, i, j;
  
    out := OutNeighbours(graph);
    inn := List(DigraphVertices(graph), x -> []);
    for i in DigraphVertices(graph) do
      for j in [ 1 .. Length(out[i]) ] do
        Add(inn[out[i][j]], i); 
      od;
    od;
    return inn;
  end);
  
  InstallMethod(InNeighbours, "for a digraph with source and range",
  [IsDigraph and HasDigraphSource], 1,
  function(graph)
    local range, source, inn, i;
    
    range := DigraphRange(graph);
    source := DigraphSource(graph);
    inn := List(DigraphVertices(graph), x -> [] );
    
    for i in [ 1 .. Length(source) ] do
      Add(inn[range[i]], source[i]);
    od;
    
    return inn;
  end);
fi;

InstallMethod(InNeighbors, "for a digraph",
[IsDigraph], InNeighbours);

#

InstallMethod(AdjacencyMatrix, "for a digraph with out-neighbours",
[IsDigraph and HasOutNeighbours], 
function(graph)
  local verts, adj, out, i;
  
  verts := [ 1 .. DigraphNrVertices(graph) ];
  adj := OutNeighbours(graph);
  
  out := EmptyPlist(DigraphNrVertices(graph));
  
  for i in verts do 
    out[i] := verts * 0;
    out[i]{adj[i]} := ( [1 .. Length(adj[i])] * 0 ) + 1;
  od;
  return out;
end);

InstallMethod(AdjacencyMatrix, "for a digraph with source and range",
[IsDigraph and HasDigraphSource], 
function(graph)
  local verts, source, range, out, i;
  
  verts := [ 1 .. DigraphNrVertices(graph) ];
  source := DigraphSource(graph);
  range := DigraphRange(graph);

  out := EmptyPlist(DigraphNrVertices(graph));
  
  for i in verts do 
    out[i] := verts * 0;
  od;
  
  for i in [1..Length(source)] do 
    out[source[i]][range[i]] := out[source[i]][range[i]] + 1;
  od;
  
  return out;  
end);

#

InstallMethod(DigraphShortestDistances, "for a digraph",
[IsDigraph], DIGRAPH_SHORTEST_DIST);

#function(graph)
#  local func;
#
#  func := function(dist, i, j, k)
#    if dist[i][k] <> -1 and dist[k][j] <> -1 then  
#      if dist[i][j] = -1 or dist[i][j] > dist[i][k] + dist[k][j] then 
#        dist[i][j] := dist[i][k] + dist[k][j];
#      fi;
#    fi;
#  end;
#  return DigraphFloydWarshall(graph, func, -1, 1);
#end);

# returns the vertices (i.e. numbers) of <digraph> ordered so that there are no
# edges from <out[j]> to <out[i]> for all <i> greater than <j>.

if IsBound(DIGRAPH_TOPO_SORT) then
  InstallMethod(DigraphTopologicalSort, "for a digraph",
  [IsDigraph], function(graph)
    return DIGRAPH_TOPO_SORT(OutNeighbours(graph));
  end);
else
  InstallMethod(DigraphTopologicalSort, "for a digraph",
  [IsDigraph],
  function(graph)
    local n, verts, adj, vertex_complete, vertex_in_path, stack, out, level, j, 
    k, i;

    n := DigraphNrVertices(graph);
    verts := DigraphVertices(graph);
    if n <= 1 then
      return verts;
    fi;
    adj := OutNeighbours(graph);
    vertex_complete := BlistList( verts, [ ] );
    vertex_in_path := BlistList( verts, [ ] );
    stack := EmptyPlist(2 * n + 2);
    out := EmptyPlist(n);

    for i in verts do
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
    return GABOW_SCC(OutNeighbours(digraph));
  end);
else
  InstallMethod(DigraphStronglyConnectedComponents, "for a digraph",
  [IsDigraph],
  function(digraph)
    local n, verts, stack1, len1, stack2, len2, id, count, comps, fptr, level, nr, w, comp, v;

    n := DigraphNrVertices(digraph);
    if n = 0 then
      return rec( comps := [], id := []);
    fi;
    verts := DigraphVertices(digraph);
    digraph := OutNeighbours(digraph);
    stack1 := EmptyPlist(n); len1 := 0;
    stack2 := EmptyPlist(n); len2 := 0;
    id := verts * 0;
    count := Length(digraph);
    comps := [];
    fptr := [];

    for v in verts do
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
            if stack2[len2] = id[fptr[2 * level - 1]] then
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

#

InstallMethod(DigraphConnectedComponents, "for a digraph",
[IsDigraph],
function(digraph)
  local n, verts, tab, find, union, source, range, adj, normalise, comps, i, j;

  n := DigraphNrVertices(digraph);
  verts := DigraphVertices(digraph);
  if n = 0 then
    return rec( comps := [  ], id := [  ] );
  fi;

  tab := ShallowCopy(DigraphVertices(digraph));

  find := function(i)
    while i <> tab[i] do
      i := tab[i];
    od;
    return i;
  end;

  union := function(i, j)
    i := find(i);
    j := find(j);
    if i < j then
      tab[j] := i;
    elif j < i then
      tab[i] := j;
    fi;
  end;
  
  if HasDigraphSource(digraph) then
    source := DigraphSource(digraph);
    range := DigraphRange(digraph);
    for i in [ 1 .. Size(source) ] do
      union(source[i], range[i]);
    od;
  elif HasOutNeighbours(digraph) then
    adj := OutNeighbours(digraph);
    for i in verts do
      for j in adj[i] do
        union(i, j);
      od;
    od;
  fi;

  normalise := function()
    local ht, next, i, ii, table;
    table := EmptyPlist(n);
    ht := [];
    next := 1;
    for i in verts do
      ii := find(i);
      if IsBound(ht[ii]) then
        table[i] := ht[ii];
      else
        table[i] := next;
        ht[ii] := next;
        next := next + 1;
      fi;
    od;
    return table;
  end;
 
  tab := normalise();
  comps := List([ 1 .. Maximum(tab) ], x -> [ ]);
  for i in verts do
    Add(comps[ tab[i] ], i);
  od;
  return rec( comps := comps, id := tab );
end);

#

InstallMethod(OutDegrees, "for a digraph with out neighbours",
[IsDigraph and HasOutNeighbours],
function(digraph)
  local adj, degs, i;
  
  adj := OutNeighbours(digraph);
  degs := EmptyPlist(  DigraphNrVertices(digraph) );
  for i in DigraphVertices(digraph) do
    degs[i] := Length(adj[i]);
  od;
  return degs;
end);

#

InstallMethod(OutDegrees, "for a digraph with source and range",
[IsDigraph and HasDigraphSource],
function(digraph)
  local n, source, degs, current, count, i;

  n := DigraphNrVertices(digraph);
  if n = 0 then
    return [ ];
  fi;
  source := DigraphSource(digraph);
  degs := [ 1 .. n ] * 0;
  current := source[1];
  count := 0;
  for i in source do
    if i <> current then
      degs[current] := count;
      count := 0;
      current := i;
    fi;
    count := count + 1;
  od;
  degs[current] := count;
  return degs;
end);

#

InstallMethod(InDegrees, "for a digraph with in neighbours",
[IsDigraph and HasInNeighbours], 3,
function(digraph)
  local inn, degs, i;
  
  inn := InNeighbours(digraph);
  degs := EmptyPlist(  DigraphNrVertices(digraph) );
  for i in DigraphVertices(digraph) do
    degs[i] := Length(inn[i]);
  od;
  return degs;
end);

#

InstallMethod(InDegrees, "for a digraph with out neighbours",
[IsDigraph and HasOutNeighbours],
function(digraph)
  local adj, degs, x, i;
  
  adj := OutNeighbours(digraph);
  degs := [ 1 .. DigraphNrVertices(digraph)] * 0;
  for x in adj do
    for i in x do
      degs[i] := degs[i] + 1;
    od;
  od;
  return degs;
end);

#

InstallMethod(InDegrees, "for a digraph with source and range",
[IsDigraph and HasDigraphSource],
function(digraph)
  local range, degs, i;

  range := DigraphRange(digraph);
  degs := [ 1 .. DigraphNrVertices(digraph)] * 0;
  for i in range do
    degs[i] := degs[i] + 1;
  od;
  return degs;
end);

#

InstallMethod(OutDegreeSequence, "for a digraph",
[IsDigraph],
function(digraph)
  local out;

  out := ShallowCopy(OutDegrees(digraph));
  Sort(out, function(a,b) return b < a; end);
  return out;
end);

#

InstallMethod(InDegreeSequence, "for a digraph",
[IsDigraph],
function(digraph)
  local out;

  out := ShallowCopy(InDegrees(digraph));
  Sort(out, function(a,b) return b < a; end);
  return out;
end);

#EOF
