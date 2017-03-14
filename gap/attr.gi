#############################################################################
##
#W  attr.gi
#Y  Copyright (C) 2014-17                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallMethod(ChromaticNumber, "for a digraph", [IsDigraph],
function(digraph)
  local nr, comps, chrom, n, subdigraph, comp, i;

  nr := DigraphNrVertices(digraph);

  if DigraphHasLoops(digraph) then
    ErrorNoReturn("Digraphs: ChromaticNumber: usage,\n",
                  "the digraph (1st argument) must not have loops,");
  elif nr = 0 then
    return 0; # chromatic number = 0 iff <digraph> has 0 verts
  elif IsNullDigraph(digraph) then
    return 1; # chromatic number = 1 iff <digraph> has >= 1 verts & no edges
  elif IsBipartiteDigraph(digraph) then
    return 2; # chromatic number = 2 iff <digraph> has >= 2 verts & is bipartite
              # <digraph> has at least 2 vertices at this stage
  fi;

  digraph := DigraphRemoveAllMultipleEdges(digraph);

  if IsCompleteDigraph(DigraphSymmetricClosure(digraph)) then
    return nr; # chromatic number = nr iff <digraph> has >= 2 verts & this cond.
  elif nr = 4 then
    return 3; # if nr = 4, then 3 is only remaining possible chromatic number
  fi;

  # The chromatic number of <digraph> is at least 3 and at most n - 1

  comps := DigraphConnectedComponents(digraph).comps;
  chrom := 3;

  for comp in comps do
    n := Length(comp);

    if n < nr then
      subdigraph := InducedSubdigraph(digraph, comp);
    else
      subdigraph := digraph;
    fi;

    if not IsNullDigraph(subdigraph)
        and not IsBipartiteDigraph(subdigraph) then
      if IsCompleteDigraph(DigraphSymmetricClosure(subdigraph)) then
        if n > chrom then
          chrom := n;
        fi;
      else
        for i in [3 .. n - 1] do
          if DigraphColoring(subdigraph, i) <> fail then
            if i > chrom then
              chrom := i;
            fi;
            break;
          fi;
        od;
      fi;
    fi;
    if chrom = nr - 1 then
      return chrom;
    fi;
  od;
  return chrom;
end);

#
# The following method is currently useless, as the OutNeighbours are computed
# and set whenever a digraph is created.  It could be reinstated later if we
# decide to allow digraphs to exist without known OutNeighbours.
#

# InstallMethod(OutNeighbours,
# "for a digraph with representative out neighbours and group",
# [IsDigraph and HasRepresentativeOutNeighbours and HasDigraphGroup],
# function(digraph)
#   local gens, sch, reps, out, trace, word, i, w;
#
#   gens := GeneratorsOfGroup(DigraphGroup(digraph));
#   sch  := DigraphSchreierVector(digraph);
#   reps := RepresentativeOutNeighbours(digraph);
#
#   out  := EmptyPlist(DigraphNrVertices(digraph));
#
#   for i in [1 .. Length(sch)] do
#     if sch[i] < 0 then
#       out[i] := reps[-sch[i]];
#     fi;
#
#     trace  := DIGRAPHS_TraceSchreierVector(gens, sch, i);
#     out[i] := out[trace.representative];
#     word   := trace.word;
#     for w in word do
#        out[i] := OnTuples(out[i], gens[w]);
#     od;
#   od;

#   return out;
# end);

#

InstallMethod(DigraphAdjacencyFunction, "for a digraph", [IsDigraph],
function(digraph)
  local func;

  func := function(u, v)
    return IsDigraphEdge(digraph, u, v);
  end;

  return func;
end);

#

InstallMethod(AsTransformation, "for a digraph",
[IsDigraph],
function(digraph)
  if not IsFunctionalDigraph(digraph) then
    return fail;
  fi;
  return Transformation(Concatenation(OutNeighbours(digraph)));
end);

#

InstallMethod(ReducedDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  local v, niv, old, vlabels, elabels, old_elabels, i, len, adj, map, gr;

  if IsConnectedDigraph(digraph) then
    return digraph;
  fi;

  v := DigraphVertices(digraph);
  niv := BlistList(v, []);
  old := OutNeighbours(digraph);

  # First find the non-isolated vertices
  for i in [1 .. Length(old)] do
    if not IsEmpty(old[i]) then
      niv[i] := true;
      UniteBlistList(v, niv, old[i]);
    fi;
  od;

  # Compress, store map oldvertex -> newvertex, order invariant
  map := [];
  len := 1;
  for i in [1 .. Length(niv)] do
    if niv[i] then
      map[i] := len;
      len := len + 1;
    fi;
  od;

  # Vertex labels
  vlabels := ListBlist(DigraphVertexLabels(digraph), niv);
  vlabels := StructuralCopy(vlabels);

  # Adjacencies and edge labels
  old_elabels := DigraphEdgeLabelsNC(digraph);
  adj := [];
  elabels := [];
  for i in [1 .. Length(niv)] do
    if niv[i] then
      Add(adj, List(old[i], x -> map[x]));
      Add(elabels, StructuralCopy(old_elabels[i]));
    fi;
  od;

  # Return the reduced graph, with labels preserved
  gr := DigraphNC(adj);
  SetDigraphVertexLabels(gr, vlabels);
  SetDigraphEdgeLabelsNC(gr, elabels);
  return gr;
end);

#

InstallMethod(DigraphDual, "for a digraph",
[IsDigraph],
function(digraph)
  local verts, old, new, gr, i;

  if IsMultiDigraph(digraph) then
    ErrorNoReturn("Digraphs: DigraphDual: usage,\n",
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
  if HasDigraphGroup(digraph) then
    SetDigraphGroup(gr, DigraphGroup(digraph));
  fi;
  return gr;
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
  Perform(out, IsSet);
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
[IsDigraph],
function(digraph)
  local vertices, data, sum, distances, v, u;

  if HasDIGRAPHS_ConnectivityData(digraph) then
    vertices := DigraphVertices(digraph);
    data := DIGRAPHS_ConnectivityData(digraph);
    sum := 0;
    for v in vertices do
      if IsBound(data[v]) then
        sum := sum + 1;
      fi;
    od;
    if sum > Int(0.9 * DigraphNrVertices(digraph)) or
        (HasDigraphGroup(digraph) and
         not IsTrivial(DigraphGroup(digraph)))  then
      # adjust the constant 0.9 and possibly make a the decision based on
      # how big the group is
      distances := [];
      for u in vertices do
        distances[u] := [];
        for v in vertices do
          distances[u][v] := DigraphShortestDistance(digraph, u, v);
        od;
      od;
      return distances;
    fi;
  fi;

  return DIGRAPH_SHORTEST_DIST(digraph);
end);

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

InstallMethod(OutDegreeSequence, "for a digraph with known digraph group",
[IsDigraph and HasDigraphGroup],
function(digraph)
  local out, adj, orbs, orb;

  out := [];
  adj := OutNeighbours(digraph);
  orbs := DigraphOrbits(digraph);
  for orb in orbs do
    Append(out, [1 .. Length(orb)] * 0 + Length(adj[orb[1]]));
  od;
  Sort(out,
       function(a, b)
         return b < a;
       end);
  return out;
end);

#

InstallMethod(OutDegreeSet, "for a digraph",
[IsDigraph],
function(digraph)
  local out;

  out := ShallowCopy(OutDegrees(digraph));
  return Set(out);
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

InstallMethod(InDegreeSequence,
"for a digraph with known digraph group and in-neighbours",
[IsDigraph and HasDigraphGroup and HasInNeighbours],
function(digraph)
  local out, adj, orbs, orb;

  out := [];
  adj := InNeighbours(digraph);
  orbs := DigraphOrbits(digraph);
  for orb in orbs do
    Append(out, [1 .. Length(orb)] * 0 + Length(adj[orb[1]]));
  od;
  Sort(out,
       function(a, b)
         return b < a;
       end);
  return out;
end);

#

InstallMethod(InDegreeSet, "for a digraph",
[IsDigraph],
function(digraph)
  local out;

  out := ShallowCopy(InDegrees(digraph));
  return Set(out);
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
  local comps, out, deg, nrvisited, period, stack, len, depth, current,
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

InstallMethod(DIGRAPHS_ConnectivityData, "for a digraph",
[IsDigraph],
function(digraph)
  return [];
end);

#

BindGlobal("DIGRAPH_ConnectivityDataForVertex",
function(digraph, v)
  local data, out_nbs, record, orbnum, reps, i, next, laynum, localGirth,
        layers, sum, localParameters, nprev, nhere, nnext, lnum, localDiameter,
        layerNumbers, x, y;

  data := DIGRAPHS_ConnectivityData(digraph);

  if IsBound(data[v]) then
    return data[v];
  fi;

  out_nbs         := OutNeighbours(digraph);
  if HasDigraphGroup(digraph) then
    record          := DIGRAPHS_Orbits(DigraphStabilizer(digraph, v),
                                       DigraphVertices(digraph));
    orbnum          := record.lookup;
    reps            := List(record.orbits, Representative);
    i               := 1;
    next            := [orbnum[v]];
    laynum          := [1 .. Length(reps)] * 0;
    laynum[next[1]] := 1;
    localGirth      := -1;
    layers          := [next];
    sum             := 1;
    localParameters := [];
  else
    orbnum          := [1 .. DigraphNrVertices(digraph)];
    reps            := [1 .. DigraphNrVertices(digraph)];
    i               := 1;
    next            := [orbnum[v]];
    laynum          := [1 .. Length(reps)] * 0;
    laynum[next[1]] := 1;
    localGirth      := -1;
    layers          := [next];
    sum             := 1;
    localParameters := [];
  fi;

  # localDiameter is the length of the longest shortest path starting at v
  #
  # localParameters is a list of 3-tuples [a_{i - 1}, b_{i - 1}, c_{i - 1}] for
  # each i between 1 and localDiameter where c_i (respectively a_i and b_i) is
  # the number of vertices at distance i − 1 (respectively i and i + 1) from v
  # that are adjacent to a vertex w at distance i from v.

  while Length(next) > 0 do
    next := [];
    for x in layers[i] do
      nprev := 0;
      nhere := 0;
      nnext := 0;
      for y in out_nbs[reps[x]] do
        lnum := laynum[orbnum[y]];
        if i > 1 and lnum = i - 1 then
          nprev := nprev + 1;
        elif lnum = i then
          nhere := nhere + 1;
        elif lnum = i + 1 then
          nnext := nnext + 1;
        elif lnum = 0 then
          AddSet(next, orbnum[y]);
          nnext := nnext + 1;
          laynum[orbnum[y]] := i + 1;
        fi;
      od;
      if (localGirth = -1 or localGirth = 2 * i - 1) and nprev > 1 then
        localGirth := 2 * (i - 1);
      fi;
      if localGirth = -1 and nhere > 0 then
        localGirth := 2 * i - 1;
      fi;
      if not IsBound(localParameters[i]) then
         localParameters[i] := [nprev, nhere, nnext];
      else
         if nprev <> localParameters[i][1] then
            localParameters[i][1] := -1;
         fi;
         if nhere <> localParameters[i][2] then
            localParameters[i][2] := -1;
         fi;
         if nnext <> localParameters[i][3] then
            localParameters[i][3] := -1;
         fi;
      fi;
    od;
    if Length(next) > 0 then
      i := i + 1;
      layers[i] := next;
      sum := sum + Length(next);
    fi;
  od;
  if sum = Length(reps) then
     localDiameter := Length(layers) - 1;
  else
     localDiameter := -1;
  fi;

  layerNumbers := [];
  for i in [1 .. DigraphNrVertices(digraph)] do
     layerNumbers[i] := laynum[orbnum[i]];
  od;
  data[v] := rec(layerNumbers := layerNumbers, localDiameter := localDiameter,
                 localGirth := localGirth, localParameters := localParameters,
                 layers := layers);
  return data[v];
end);
#

BindGlobal("DIGRAPHS_DiameterAndUndirectedGirth",
function(digraph)
  local outer_reps, out_nbs, diameter, girth, v, record, localGirth,
        localDiameter, i;

  #
  # This function attempts to find the diameter and undirected girth of a given
  # graph, using its DigraphGroup.  For some digraphs, the main algorithm will
  # not produce a sensible answer, so there are checks at the start and end to
  # alter the answer for the diameter/girth if necessary.  This function is
  # called, if appropriate, by DigraphDiameter and DigraphUndirectedGirth.
  #

  if DigraphNrVertices(digraph) = 0 then
    SetDigraphDiameter(digraph, fail);
    SetDigraphUndirectedGirth(digraph, infinity);
    return rec(diameter := fail, girth := infinity);
  fi;

  #TODO improve this, really check if the complexity is better with the group
  #or without, or if the group is not known, but the number of vertices makes
  #the usual algorithm impossible.

  outer_reps := DigraphOrbitReps(digraph);
  out_nbs    := OutNeighbours(digraph);
  diameter   := 0;
  girth      := infinity;

  for i in [1 .. Length(outer_reps)] do
    v := outer_reps[i];
    record     := DIGRAPH_ConnectivityDataForVertex(digraph, v);
    localGirth := record.localGirth;
    localDiameter := record.localDiameter;

    if localDiameter > diameter then
      diameter := localDiameter;
    fi;

    if localGirth <> -1 and localGirth < girth then
      girth := localGirth;
    fi;
  od;

  # Checks to ensure both components are valid
  if not IsStronglyConnectedDigraph(digraph) then
    diameter := fail;
  fi;
  if DigraphHasLoops(digraph) then
    girth := 1;
  elif IsMultiDigraph(digraph) then
    girth := 2;
  fi;

  SetDigraphDiameter(digraph, diameter);
  SetDigraphUndirectedGirth(digraph, girth);
  return rec(diameter := diameter, girth := girth);
end);

#

InstallMethod(DigraphDiameter, "for a digraph",
[IsDigraph],
function(digraph)
  if not IsStronglyConnectedDigraph(digraph) then
    # Diameter undefined
    return fail;
  elif HasDigraphGroup(digraph) and Size(DigraphGroup(digraph)) > 1 then
    # Use the group to calculate the diameter
    return DIGRAPHS_DiameterAndUndirectedGirth(digraph).diameter;
  fi;
  # Use the C function
  return DIGRAPH_DIAMETER(digraph);
end);

#

InstallMethod(DigraphUndirectedGirth, "for a digraph",
[IsDigraph],
function(digraph)
  # This is only defined on undirected graphs (i.e. symmetric digraphs)
  if not IsSymmetricDigraph(digraph) then
    ErrorNoReturn("Digraphs: DigraphUndirectedGirth: usage,\n",
                  "<digraph> must be a symmetric digraph,");
  fi;
  if DigraphHasLoops(digraph) then
    # A loop is a cycle of length 1
    return 1;
  elif IsMultiDigraph(digraph) then
    # A pair of multiple edges is a cycle of length 2
    return 2;
  fi;
  # Otherwise digraph is simple
  return DIGRAPHS_DiameterAndUndirectedGirth(digraph).girth;
end);

#

InstallMethod(DigraphGirth, "for a digraph",
[IsDigraph],
function(digraph)
  local verts, girth, out, dist, i, j;
  if DigraphHasLoops(digraph) then
    return 1;
  fi;
  # Only consider one vertex from each orbit
  if HasDigraphGroup(digraph) and not IsTrivial(DigraphGroup(digraph)) then
    verts := DigraphOrbitReps(digraph);
  else
    verts := DigraphVertices(digraph);
  fi;
  girth := infinity;
  out := OutNeighbours(digraph);
  for i in verts do
    for j in out[i] do
      dist := DigraphShortestDistance(digraph, j, i);
      # distance [j,i] + 1 equals the cycle length
      if dist <> fail and dist + 1 < girth then
        girth := dist + 1;
        if girth = 2 then
          return girth;
        fi;
      fi;
    od;
  od;
  return girth;
end);

#

InstallMethod(DigraphLongestSimpleCircuit, "for a digraph",
[IsDigraph],
function(digraph)
  local circs, lens, max;
  if IsAcyclicDigraph(digraph) then
    return fail;
  fi;
  circs := DigraphAllSimpleCircuits(digraph);
  lens := List(circs, Length);
  max := Maximum(lens);
  return circs[Position(lens, max)];
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
    new := OutNeighboursMutableCopy(digraph);
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
    ErrorNoReturn("Digraphs: DigraphTransitiveClosure: usage,\n",
                  "the argument <graph> cannot have multiple edges,");
  fi;
  return DigraphTransitiveClosureNC(graph, false);
end);

#

InstallMethod(DigraphReflexiveTransitiveClosure, "for a digraph",
[IsDigraph],
function(graph)
  if IsMultiDigraph(graph) then
    ErrorNoReturn("Digraphs: DigraphReflexiveTransitiveClosure: usage,\n",
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

  if DigraphNrVertices(digraph) = 0 or DigraphNrEdges(digraph) = 0 then
    return [];
  fi;

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
      fi;
      s := s + 1;
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

#

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
    ErrorNoReturn("Digraphs: DigraphDegeneracy: usage,\n",
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
    ErrorNoReturn("Digraphs: DigraphDegeneracyOrdering: usage,\n",
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

#

InstallMethod(UndirectedSpanningForest,
"for a digraph",
[IsDigraph],
function(gr)
  local out;
  if DigraphNrVertices(gr) = 0 then
    return fail;
  fi;

  gr := MaximalSymmetricSubdigraph(gr);
  out := Digraph(DIGRAPH_SYMMETRIC_SPANNING_FOREST(OutNeighbours(gr)));
  SetIsUndirectedForest(out, true);
  SetIsMultiDigraph(out, false);
  SetDigraphHasLoops(out, false);
  return out;
end);

#

InstallMethod(UndirectedSpanningTree,
"for a digraph",
[IsDigraph],
function(gr)
  local out;
  if DigraphNrVertices(gr) = 0
      or not IsStronglyConnectedDigraph(MaximalSymmetricSubdigraph(gr)) then
    return fail;
  fi;
  out := UndirectedSpanningForest(gr);
  SetIsUndirectedTree(out, true);
  return out;
end);
