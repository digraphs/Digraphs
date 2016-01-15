#############################################################################
##
#W  attr.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallMethod(AsTransformation, "for a digraph",
[IsDigraph],
function(digraph)
  if not IsFunctionalDigraph(digraph) then
    return fail;
  fi;
  return Transformation(Concatenation(OutNeighbours(digraph)));
end);

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

InstallMethod(BooleanAdjacencyMatrix,
"for a digraph",
[IsDigraph],
function(gr)
  local n, nbs, mat, i, j;

  n := DigraphNrVertices(gr);
  nbs := OutNeighbours(gr);
  mat := List(DigraphVertices(gr), x -> BlistList([1 .. n], []));
  for i in DigraphVertices(gr) do
    for j in nbs[i] do
      mat[i][j] := true;
    od;
  od;
  return mat;
end);

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
function(digraph)
  local UNBLOCK, CIRCUIT, out, stack, endofstack, gr, scc, n, blocked, B,
  gr_comp, comp, s, loops, i;

    UNBLOCK := function(u)
      local w;
      blocked[u] := false;
      while not IsEmpty(B[u]) do
        w := B[u][1];
        Remove(B[u], 1);
        if blocked[w] then
          UNBLOCK(w);
        fi;
      od;
    end;

    CIRCUIT := function(v, component)
      local f, buffer, dummy, w;

      f := false;
      endofstack := endofstack + 1;
      stack[endofstack] := v;
      blocked[v] := true;

      for w in OutNeighboursOfVertex(component, v) do
        if w = 1 then
          buffer := stack{[1 .. endofstack]};
          Add(out, DigraphVertexLabels(component){buffer});
          f := true;
        elif blocked[w] = false then
          dummy := CIRCUIT(w, component);
          if dummy then
            f := true;
          fi;
        fi;
      od;

      if f then
        UNBLOCK(v);
      else
        for w in OutNeighboursOfVertex(component, v) do
          if not w in B[w] then
            Add(B[w], v);
          fi;
        od;
      fi;

      endofstack := endofstack - 1;
      return f;
    end;

    out := [];
    stack := [];
    endofstack := 0;

    # TODO should we also remove multiple edges, as they create extra work?
    # Reduce the digraph, remove loops, and store the correct vertex labels
    gr := DigraphRemoveLoops(ReducedDigraph(digraph));
    if DigraphVertexLabels(digraph) <> DigraphVertices(digraph) then
      SetDigraphVertexLabels(gr, Filtered(DigraphVertices(digraph),
                                          x -> OutDegrees(digraph) <> 0));
    fi;

    # Strongly connected components of the reduced graph
    scc := DigraphStronglyConnectedComponents(gr);

    # B and blocked only need to be as long as the longest connected component
    n := Maximum(List(scc.comps, Length));
    blocked := BlistList([1 .. n], []);
    B := List([1 .. n], x -> []);

    # Perform algorithm once per connected component of the whole digraph
    for gr_comp in scc.comps do
      n := Length(gr_comp);
      if n = 1 then
        continue;
      fi;
      gr_comp := InducedSubdigraph(gr, gr_comp);
      comp := gr_comp;
      s := 1;
      while s < n do
        if s <> 1 then
          comp := InducedSubdigraph(gr_comp, [s .. n]);
          comp := InducedSubdigraph(comp,
                                    DigraphStronglyConnectedComponent(comp, 1));
        fi;

        if not IsEmptyDigraph(comp) then
          # TODO would it be faster/better to create blocked as a new BlistList?
          # Are these things already going to be initialised anyway?
          for i in DigraphVertices(comp) do
            blocked[i] := false;
            B[i] := [];
          od;
          CIRCUIT(1, comp);
          s := s + 1;
        else
          s := n;
        fi;
      od;
    od;
    loops := List(DigraphLoops(digraph), x -> [x]);
    return Concatenation(loops, out);
end);

# The following method 'DIGRAPHS_Bipartite' was written by Isabella Scott
# It is the backend to IsBipartiteDigraph, Bicomponents, and DigraphColouring
# for a 2-colouring

# Can this be improved with a simple depth 1st search to remove need for
# symmetric closure, etc?

InstallMethod(DIGRAPHS_Bipartite, "for a digraph", [IsDigraph],
function(digraph)
  local n, colour, queue, i, node, node_neighbours, root, t;

  n := DigraphNrVertices(digraph);
  if n < 2 then
    return [false, fail];
  elif IsEmptyDigraph(digraph) then
    t := Concatenation(ListWithIdenticalEntries(n - 1, 1), [2]);
    return [true, Transformation(t)];
  fi;
  digraph := DigraphSymmetricClosure(DigraphRemoveAllMultipleEdges(digraph));
  colour := ListWithIdenticalEntries(n, 0);

  #This means there is a vertex we haven't visited yet
  while 0 in colour do
    root := Position(colour, 0);
    colour[root] := 1;
    queue := [root];
    Append(queue, OutNeighboursOfVertex(digraph, root));
    while queue <> [] do
      #Explore the first element of queue
      node := queue[1];
      node_neighbours := OutNeighboursOfVertex(digraph, node);
      for i in node_neighbours do
        #If node and its neighbour have the same colour, graph is not bipartite
        if colour[node] = colour[i] then
          return [false, fail, fail];
        elif colour[i] = 0 then # Give i opposite colour to node
          if colour[node] = 1 then
            colour[i] := 2;
          else
            colour[i] := 1;
          fi;
          Add(queue, i);
        fi;
      od;
      Remove(queue, 1);
    od;
  od;
  return [true, Transformation(colour)];
end);

#

InstallMethod(DigraphBicomponents, "for a digraph", [IsDigraph],
function(digraph)
  local b;

  # Attribute only applies to bipartite digraphs
  if not IsBipartiteDigraph(digraph) then
    return fail;
  fi;
  b := KernelOfTransformation(DIGRAPHS_Bipartite(digraph)[2],
                              DigraphNrVertices(digraph));
  return b;
end);

InstallMethod(DigraphLoops, "for a digraph", [IsDigraph],
function(gr)
  if HasDigraphHasLoops(gr) and not DigraphHasLoops(gr) then
    return [];
  fi;
  return Filtered(DigraphVertices(gr), x -> x in OutNeighboursOfVertex(gr, x));
end);

#

InstallMethod(DigraphDegeneracy,
"for a digraph",
[IsDigraph],
function(gr)
  if not IsSymmetricDigraph(gr) or IsMultiDigraph(gr) then
    ErrorMayQuit("Digraphs: DigraphDegeneracy: usage,\n",
                 "the argument <gr> must be a symmetric digraph without ",
                 "multiple edges,");
  fi;
  return DIGRAPHS_Degeneracy(DigraphRemoveLoops(gr))[1];
end);

InstallMethod(DigraphDegeneracyOrdering,
"for a digraph",
[IsDigraph],
function(gr)
  if not IsSymmetricDigraph(gr) or IsMultiDigraph(gr) then
    ErrorMayQuit("Digraphs: DigraphDegeneracyOrdering: usage,\n",
                 "the argument <gr> must be a symmetric digraph without ",
                 "multiple edges,");
  fi;
  return DIGRAPHS_Degeneracy(DigraphRemoveLoops(gr))[2];
end);

# Returns [ degeneracy, degeneracy ordering ]

InstallMethod(DIGRAPHS_Degeneracy,
"for a digraph",
[IsDigraph],
function(gr)
  local nbs, n, out, deg_vert, m, verts_deg, k, i, v, d, w;

  # The code assumes undirected, no multiple edges, no loops
  gr := MaximalSymmetricSubdigraph(gr);
  nbs := OutNeighbours(gr);
  n := DigraphNrVertices(gr);
  out := EmptyPlist(n);
  deg_vert := ShallowCopy(OutDegrees(gr));
  m := Maximum(deg_vert);
  verts_deg := List([1 .. m], x -> []);

  # Prepare the set verts_deg
  for v in DigraphVertices(gr) do
    if deg_vert[v] = 0 then
      Add(out, v);
    else
      Add(verts_deg[deg_vert[v]], v);
    fi;
  od;

  k := 0;
  while Length(out) < n do
    i := First([1 .. m], x -> not IsEmpty(verts_deg[x]));
    k := Maximum(k, i);
    v := Remove(verts_deg[i]);
    Add(out, v);
    for w in Difference(nbs[v], out) do
      d := deg_vert[w];
      Remove(verts_deg[d], Position(verts_deg[d], w));
      d := d - 1;
      deg_vert[w] := d;
      if d = 0 then
        Add(out, w);
      else
        Add(verts_deg[d], w);
      fi;
    od;
  od;

  return [k, out];
end);

#

InstallMethod(MaximalSymmetricSubdigraphWithoutLoops, "for a digraph",
[IsDigraph],
function(gr)
  if not DigraphHasLoops(gr) then
    return MaximalSymmetricSubdigraph(gr);
  fi;
  if HasIsSymmetricDigraph(gr) and IsSymmetricDigraph(gr) then
    if IsMultiDigraph(gr) then
      return DigraphRemoveLoops(DigraphRemoveAllMultipleEdges(gr));
    fi;
    return DigraphRemoveLoops(gr);
  fi;
  return DIGRAPHS_MaximalSymmetricSubdigraph(gr, false);
end);

#

InstallMethod(MaximalSymmetricSubdigraph, "for a digraph",
[IsDigraph],
function(gr)
  if HasIsSymmetricDigraph(gr) and IsSymmetricDigraph(gr) then
    if IsMultiDigraph(gr) then
      return DigraphRemoveAllMultipleEdges(gr);
    fi;
    return gr;
  fi;
  return DIGRAPHS_MaximalSymmetricSubdigraph(gr, true);
end);

#

InstallMethod(DIGRAPHS_MaximalSymmetricSubdigraph,
"for a digraph and a bool",
[IsDigraph, IsBool],
function(gr, loops)
  local out_nbs, in_nbs, new_out, new_in, new_gr, i, j;

  out_nbs := OutNeighbours(gr);
  in_nbs  := InNeighbours(gr);
  new_out := List(DigraphVertices(gr), x -> []);
  new_in  := List(DigraphVertices(gr), x -> []);

  for i in DigraphVertices(gr) do
    for j in Intersection(out_nbs[i], in_nbs[i]) do
      if loops or i <> j then
        Add(new_out[i], j);
        Add(new_in[j], i);
      fi;
    od;
  od;

  new_gr := DigraphNC(new_out);
  SetInNeighbors(new_gr, new_in);
  SetIsSymmetricDigraph(new_gr, true);
  SetDigraphVertexLabels(new_gr, DigraphVertexLabels(gr));
  return new_gr;
end);
