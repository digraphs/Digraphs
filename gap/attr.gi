#############################################################################
##
#W  attrs.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallMethod(DigraphDual, "for a digraph", 
[IsDigraph], 
function(graph)
  local verts, old, new, i;
  
  if IsMultiDigraph(graph) then 
    Error("Digraphs: DigraphDual: usage,\n", 
      "the argument <graph> must not have multiple edges,");
    return;
  fi;
  
  verts := DigraphVertices(graph);
  old := OutNeighbours(graph);
  new := [  ];

  for i in verts do 
    new[i] := DifferenceLists(verts, old[i]);
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

InstallMethod(DigraphNrEdges, "for a digraph",
[IsDigraph], DIGRAPH_NREDGES);

#

InstallMethod(DigraphEdges, "for a digraph",
[IsDigraph],
function(graph)
  local out, adj, nr, i, j;

  out := EmptyPlist(DigraphNrEdges(graph));
  adj := OutNeighbours(graph);
  nr := 0;
  
  for i in DigraphVertices(graph) do 
    for j in adj[i] do 
      nr := nr + 1;
      out[nr] := [ i, j ];
    od;
  od;
  return out;   
end);

# attributes for digraphs . . .

InstallMethod(AsGraph, "for a digraph", [IsDigraph], Graph);

#

InstallMethod(DigraphVertices, "for a digraph",
[IsDigraph],
function(digraph)
  return [ 1 .. DigraphNrVertices(digraph) ];
end);

InstallMethod(DigraphRange, "for a digraph",
[IsDigraph],
function(digraph)
  DIGRAPH_SOURCE_RANGE(digraph);
  SetDigraphSource(digraph, digraph!.source);
  return digraph!.range;
end);

InstallMethod(DigraphSource, "for a digraph",
[IsDigraph],
function(digraph)
  DIGRAPH_SOURCE_RANGE(digraph);
  SetDigraphRange(digraph, digraph!.range);
  return digraph!.source;
end);

# We don't need an OutNeighbours function, as any graph already has this attr

#InstallMethod(OutNeighbours, "for a digraph",
#[IsDigraph], DIGRAPH_OUT_NBS);

InstallMethod(OutNeighbors, "for a digraph", [IsDigraph], OutNeighbours);

#

InstallMethod(InNeighbours, "for a digraph",
[IsDigraph], DIGRAPH_IN_NBS);

InstallMethod(InNeighbors, "for a digraph", [IsDigraph], InNeighbours);

#

InstallMethod(AdjacencyMatrix, "for a digraph",
[IsDigraph], ADJACENCY_MATRIX);

#

InstallMethod(DigraphShortestDistances, "for a digraph",
[IsDigraph], DIGRAPH_SHORTEST_DIST);

# returns the vertices (i.e. numbers) of <digraph> ordered so that there are no
# edges from <out[j]> to <out[i]> for all <i> greater than <j>.

InstallMethod(DigraphTopologicalSort, "for a digraph",
[IsDigraph], function(graph)
  return DIGRAPH_TOPO_SORT(OutNeighbours(graph));
end);

# the scc index 1 corresponds to the "deepest" scc, i.e. the minimal ideal in
# our case...

if IsBound(GABOW_SCC) then
  InstallMethod(DigraphStronglyConnectedComponents, "for a digraph",
  [IsDigraph],
  function(digraph)
    local verts;
    
    if HasIsAcyclicDigraph(digraph) and IsAcyclicDigraph(digraph) then
      verts := DigraphVertices(digraph);
      return rec( comps := List( verts, x -> [ x ] ), id := verts * 1 );

    elif HasIsStronglyConnectedDigraph(digraph)
     and IsStronglyConnectedDigraph(digraph) then
      verts := DigraphVertices(digraph);
      return rec( comps := [ verts * 1 ], id := verts * 0 + 1 );
    fi;

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

if IsBound(DIGRAPH_CONNECTED_COMPONENTS) then
  InstallMethod(DigraphConnectedComponents, "for a digraph",
  [IsDigraph],
  DIGRAPH_CONNECTED_COMPONENTS);
else
  InstallMethod(DigraphConnectedComponents, "for a digraph",
  [IsDigraph],
  function(digraph)
    local n, verts, tab, find, union, adj, normalise, comps, i, j;
    
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
    
    adj := OutNeighbours(digraph);
    for i in verts do
      for j in adj[i] do
        union(i, j);
      od;
    od;
    
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
fi;
#

InstallMethod(OutDegrees, "for a digraph",
[IsDigraph],
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

InstallMethod(InDegrees, "for a digraph with in neighbours",
[IsDigraph and HasInNeighbours], 
function(digraph)
  local inn, degs, i;
  
  inn := InNeighbours(digraph);
  degs := EmptyPlist( DigraphNrVertices(digraph) );
  for i in DigraphVertices(digraph) do
    degs[i] := Length(inn[i]);
  od;
  return degs;
end);

#

InstallMethod(InDegrees, "for a digraph",
[IsDigraph],
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

#

InstallMethod(DigraphSources, "for a digraph with in-degrees",
[IsDigraph and HasInDegrees], 3,
function(digraph)
  local degs;

  degs := InDegrees(digraph);
  return Filtered( DigraphVertices(digraph), x -> degs[x] = 0 );
end);

InstallMethod(DigraphSources, "for a digraph with in-neighbours",
[IsDigraph and HasInNeighbours],
function(digraph)
  local inn, sources, count, i;

  inn := InNeighbours(digraph);
  sources := EmptyPlist( DigraphNrVertices(digraph) );
  count := 0;
  for i in DigraphVertices(digraph) do
    if IsEmpty(inn[i]) then
      count := count + 1;
      sources[count] := i;
    fi;
  od;
  ShrinkAllocationPlist(sources);
  return sources;
end);

InstallMethod(DigraphSources, "for a digraph",
[IsDigraph],
function(digraph)
  local verts, out, seen, v, i;

  verts := DigraphVertices(digraph);
  out := OutNeighbours(digraph);
  seen := BlistList( verts, [  ] );
  for v in out do
    for i in v do
      seen[i] := true;
    od;
  od;
  return Filtered( verts, x -> not seen[x] );
end);

#

InstallMethod(DigraphSinks, "for a digraph with out-degrees",
[IsDigraph and HasOutDegrees],
function(digraph)
  local degs;

  degs := OutDegrees(digraph);
  return Filtered( DigraphVertices(digraph), x -> degs[x] = 0 );
end);

InstallMethod(DigraphSinks, "for a digraph",
[IsDigraph],
function(digraph)
  local out, sinks, count, i;

  out   := OutNeighbours(digraph);
  sinks := [  ];
  count := 0;
  for i in DigraphVertices(digraph) do
    if IsEmpty(out[i]) then
      count := count + 1;
      sinks[count] := i;
    fi;
  od;
  return sinks;
end);

#

InstallMethod(DigraphPeriod, "for a digraph",
[IsDigraph],
function(digraph)
  local comps, out, deg, nrvisited, period, current, stack, len, depth,
  olddepth, i;

  if HasIsAcyclicDigraph(digraph) and IsAcyclicDigraph(digraph) then
    return 0;
  fi;

  comps := DigraphStronglyConnectedComponents(digraph)!.comps;
  out := OutNeighbours(digraph);
  deg := OutDegrees(digraph);

  nrvisited := [ 1 .. Length(DigraphVertices(digraph)) ] * 0;
  period := 0;

  for i in [ 1 .. Length(comps) ] do
    stack := [comps[i][1]];
    len := 1;
    depth := EmptyPlist(Length(DigraphVertices(digraph)));
    depth[comps[i][1]] := 1;
    while len <> 0 do
      current := stack[len];
      if nrvisited[current] = deg[current] then
        len := len - 1;
      else
        nrvisited[current] := nrvisited[current] + 1;
        len := len + 1;
        stack[len] := out[current][nrvisited[current]];
        olddepth := depth[current];
        if IsBound(depth[stack[len]]) then
          period := GcdInt(period, depth[stack[len]] - olddepth - 1);
          if period = 1 then
            return period;
          fi;
        else
          depth[stack[len]] := olddepth + 1;
        fi;
      fi;
    od;
  od;

  if period = 0 then
    SetIsAcyclicDigraph(digraph, true);
  fi;

  return period;
end);
#EOF
