#############################################################################
##
#W  attr.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallMethod(ReducedDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  local old, adj, len, map, labels, i, sinkmap, sinklen, x, pos, gr;

  if IsConnectedDigraph(digraph) then
    return digraph;
  fi;

  old := OutNeighbours(digraph);

  # Extract all the non-empty lists of out-neighbours
  adj := [];
  len := 0;
  map := [];
  labels := [];
  for i in DigraphVertices(digraph) do
    if not IsEmpty(old[i]) then
      len := len + 1;
      adj[len] := ShallowCopy(old[i]);
      map[len] := i;
      labels[len] := DigraphVertexLabel(digraph, i);
    fi;
  od;

  # Renumber the contents
  sinkmap := [];
  sinklen := 0;
  for x in adj do
    for i in [1 .. Length(x)] do
      pos := PositionSet(map, x[i]);
      if pos = fail then
        # x[i] has no out-neighbours
        pos := Position(sinkmap, x[i]);
        if pos = fail then
          # x[i] has not yet been encountered
          sinklen := sinklen + 1;
          sinkmap[sinklen] := x[i];
          pos := sinklen + len;
          adj[pos] := EmptyPlist(0);
          labels[pos] := DigraphVertexLabel(digraph, x[i]);
        else
          pos := pos + len;
        fi;
      fi;
      x[i] := pos;
    od;
  od;

  # Return the reduced graph, with labels preserved
  gr := DigraphNC(adj);
  SetDigraphVertexLabels(gr, labels);
  return gr;
end);

InstallMethod(DigraphDual, "for a digraph",
[IsDigraph],
function(digraph)
  local verts, old, new, gr, i;

  if IsMultiDigraph(digraph) then
    ErrorMayQuit("Digraphs: DigraphDual: usage,\n",
                 "the argument <graph> must not have multiple edges,");
  fi;

  verts := DigraphVertices(digraph);
  old := OutNeighbours(digraph);
  new := [];

  for i in verts do
    new[i] := DifferenceLists(verts, old[i]);
  od;
  gr := DigraphNC(new);
  SetDigraphVertexLabels(gr, DigraphVertexLabels(digraph));
  return gr;
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
      out[nr] := [i, j];
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
  return [1 .. DigraphNrVertices(digraph)];
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

#

InstallMethod(OutNeighbours, "for a digraph",
[IsDigraph],
function(digraph)
  local out;
  if IsBound(digraph!.adj) then
    return digraph!.adj;
  fi;
  out := DIGRAPH_OUT_NBS(DigraphNrVertices(digraph),
                         DigraphSource(digraph),
                         DigraphRange(digraph));
  digraph!.adj := out;
  return out;
end);

#

InstallMethod(InNeighbours, "for a digraph",
[IsDigraph],
function(digraph)
  return DIGRAPH_IN_OUT_NBS(OutNeighbours(digraph));
end);

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

#

InstallMethod(DigraphStronglyConnectedComponents, "for a digraph",
[IsDigraph],
function(digraph)
  local verts;

  if HasIsAcyclicDigraph(digraph) and IsAcyclicDigraph(digraph) then
    verts := DigraphVertices(digraph);
    return rec(comps := List(verts, x -> [x]), id := verts * 1);

  elif HasIsStronglyConnectedDigraph(digraph)
      and IsStronglyConnectedDigraph(digraph) then
    verts := DigraphVertices(digraph);
    return rec(comps := [verts * 1], id := verts * 0 + 1);
  fi;

  return GABOW_SCC(OutNeighbours(digraph));
end);

#

InstallMethod(DigraphConnectedComponents, "for a digraph",
[IsDigraph],
DIGRAPH_CONNECTED_COMPONENTS);

#

InstallMethod(OutDegrees, "for a digraph",
[IsDigraph],
function(digraph)
  local adj, degs, i;

  adj := OutNeighbours(digraph);
  degs := EmptyPlist(DigraphNrVertices(digraph));
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
  degs := EmptyPlist(DigraphNrVertices(digraph));
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
  degs := [1 .. DigraphNrVertices(digraph)] * 0;
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
  Sort(out,
       function(a, b)
         return b < a;
       end);
  return out;
end);

#

InstallMethod(InDegreeSequence, "for a digraph",
[IsDigraph],
function(digraph)
  local out;

  out := ShallowCopy(InDegrees(digraph));
  Sort(out,
       function(a, b)
         return b < a;
       end);
  return out;
end);

#

InstallMethod(DigraphSources, "for a digraph with in-degrees",
[IsDigraph and HasInDegrees], 3,
function(digraph)
  local degs;

  degs := InDegrees(digraph);
  return Filtered(DigraphVertices(digraph), x -> degs[x] = 0);
end);

InstallMethod(DigraphSources, "for a digraph with in-neighbours",
[IsDigraph and HasInNeighbours],
function(digraph)
  local inn, sources, count, i;

  inn := InNeighbours(digraph);
  sources := EmptyPlist(DigraphNrVertices(digraph));
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
  seen := BlistList(verts, []);
  for v in out do
    for i in v do
      seen[i] := true;
    od;
  od;
  return Filtered(verts, x -> not seen[x]);
end);

#

InstallMethod(DigraphSinks, "for a digraph with out-degrees",
[IsDigraph and HasOutDegrees],
function(digraph)
  local degs;

  degs := OutDegrees(digraph);
  return Filtered(DigraphVertices(digraph), x -> degs[x] = 0);
end);

InstallMethod(DigraphSinks, "for a digraph",
[IsDigraph],
function(digraph)
  local out, sinks, count, i;

  out   := OutNeighbours(digraph);
  sinks := [];
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

  nrvisited := [1 .. Length(DigraphVertices(digraph))] * 0;
  period := 0;

  for i in [1 .. Length(comps)] do
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

#

InstallMethod(DigraphDiameter, "for a digraph",
[IsDigraph],
function(digraph)
  if DigraphNrVertices(digraph) = 0 then
    return - 1;
  elif not IsStronglyConnectedDigraph(digraph) then
    return - 1;
  fi;
  return DIGRAPH_DIAMETER(digraph);
end);

#

InstallMethod(DigraphSymmetricClosure, "for a digraph",
[IsDigraph],
function(digraph)
  local n, verts, mat, new, x, gr, i, j, k;

  n := DigraphNrVertices(digraph);
  if not (HasIsSymmetricDigraph(digraph) and IsSymmetricDigraph(digraph))
      and n > 1 then
    verts := [1 .. n]; # We don't want DigraphVertices as that's immutable
    mat := List(verts, x -> verts * 0);
    new := OutNeighboursCopy(digraph);
    for i in verts do
      for j in new[i] do
        if j < i then
          mat[j][i] := mat[j][i] - 1;
        else
          mat[i][j] := mat[i][j] + 1;
        fi;
      od;
    od;
    for i in verts do
      for j in [i + 1 .. n] do
        x := mat[i][j];
        if x > 0 then
          for k in [1 .. x] do
            Add(new[j], i);
          od;
        elif x < 0 then
          for k in [1 .. -x] do
            Add(new[i], j);
          od;
        fi;
      od;
    od;
    gr := DigraphNC(new);
  else
    gr := DigraphCopy(digraph);
  fi;
  SetIsSymmetricDigraph(gr, true);
  return gr;
end);

#

InstallMethod(DigraphTransitiveClosure, "for a digraph",
[IsDigraph],
function(graph)
  if IsMultiDigraph(graph) then
    ErrorMayQuit("Digraphs: DigraphTransitiveClosure: usage,\n",
                 "the argument <graph> cannot have multiple edges,");
  fi;
  return DigraphTransitiveClosureNC(graph, false);
end);

#

InstallMethod(DigraphReflexiveTransitiveClosure, "for a digraph",
[IsDigraph],
function(graph)
  if IsMultiDigraph(graph) then
    ErrorMayQuit("Digraphs: DigraphReflexiveTransitiveClosure: usage,\n",
                 "the argument <graph> cannot have multiple edges,");
  fi;
  return DigraphTransitiveClosureNC(graph, true);
end);

#

InstallGlobalFunction(DigraphTransitiveClosureNC,
function(graph, reflexive)
  local adj, m, n, verts, sorted, out, trans, reflex, mat, v, u;

  # <graph> is a digraph without multiple edges
  # <reflexive> is a boolean: true if we want the reflexive transitive closure

  adj   := OutNeighbours(graph);
  m     := DigraphNrEdges(graph);
  n     := DigraphNrVertices(graph);
  verts := DigraphVertices(graph);

  # Try correct method vis-a-vis complexity
  if m + n + (m * n) < (n * n * n) then
    sorted := DigraphTopologicalSort(graph);
    if sorted <> fail then # Method for big acyclic digraphs (loops allowed)
      out   := EmptyPlist(n);
      trans := EmptyPlist(n);
      for v in sorted do
        trans[v] := BlistList(verts, [v]);
        reflex   := false;
        for u in adj[v] do
          trans[v] := UnionBlist(trans[v], trans[u]);
          if u = v then
            reflex := true;
          fi;
        od;
        if (not reflexive) and (not reflex) then
          trans[v][v] := false;
        fi;
        out[v] := ListBlist(verts, trans[v]);
        trans[v][v] := true;
      od;
      out := DigraphNC(out);
    fi;
  fi;

  # Method for small or non-acyclic digraphs
  if not IsBound(out) then
    if reflexive then
      mat := DIGRAPH_REFLEX_TRANS_CLOSURE(graph);
    else
      mat := DIGRAPH_TRANS_CLOSURE(graph);
    fi;
    out := DigraphByAdjacencyMatrixNC(mat);
  fi;

  SetIsMultiDigraph(out, false);
  SetIsTransitiveDigraph(out, true);
  return out;
end);

InstallMethod(DigraphAllSimpleCircuits,
"for a digraph",
[IsDigraph],
function(d)
  local stack, endofstack, output, g, n, blocked, B, s, UNBLOCK, CIRCUIT, sub,
    scc, min, index, ind, component, i;

    stack := [];
    endofstack := 0;
    output := [];

    g := ReducedDigraph(d);
    n := Size(DigraphVertices(g));

    blocked := List([1 .. n], x -> false);
    B := List([1 .. n], x -> []);
    s := 1;

    UNBLOCK := function(u)
      local w;
      blocked[u] := false;
      B[u] := [];
      for w in B[u] do
        if blocked[w] then
          UNBLOCK(w);
        fi;
      od;
    end;

    CIRCUIT := function(v, comp)
      local f, endofstack, pos, buffer, dummy, w;

      f := false;

      endofstack := endofstack + 1;
      stack[endofstack] := v;
      blocked[v] := true;

      pos := Position(List(DigraphVertices(comp),
                           x -> DigraphVertexLabel(comp, x)), v);

      for w in OutNeighbours(comp)[pos] do
        if DigraphVertexLabel(comp, w) = s then
          buffer := stack{[1 .. endofstack]};
          Add(output, buffer);
          f := true;
        elif blocked[DigraphVertexLabel(comp, w)] = false then
          dummy := CIRCUIT(DigraphVertexLabel(comp, w), comp);
          if dummy then
            f := true;
          fi;
        fi;
      od;

      if f then
        UNBLOCK(v);
      else for w in OutNeighbours(comp)[pos] do
        if not DigraphVertexLabel(comp, w)
            in B[DigraphVertexLabel(comp, w)] then
          Add(B[DigraphVertexLabel(comp, w)], v);
        fi;
      od;
      fi;

      endofstack := endofstack - 1;
      return f;
    end;

    while s < n do

      sub := InducedSubdigraph(g, [s .. n]);
      scc := DigraphStronglyConnectedComponents(sub);
      min := Minimum(List([1 .. Size(scc.comps)], x -> Minimum(scc.comps[x])));

      for component in scc.comps do
        if min in component then
          index := Position(scc.comps, component);
        fi;
      od;

      ind := InducedSubdigraph(sub, scc.comps[index]);

      if ForAny(OutNeighbours(ind), x -> not IsEmpty(x)) then
        s := Minimum(DigraphVertexLabels(ind));
        for i in DigraphVertices(ind) do;
          blocked[DigraphVertexLabel(ind, i)] := false;
          B[DigraphVertexLabel(ind, i)] := [];
        od;
        CIRCUIT(s, ind);
        s := s + 1;
      else
        s := n;
      fi;
    od;
    return output;
end);
