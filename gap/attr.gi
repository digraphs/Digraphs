#############################################################################
##
##  attr.gi
##  Copyright (C) 2014-17                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallMethod(DigraphNrVertices, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  IsValidDigraph(D);
  return DIGRAPH_NR_VERTICES(D);
end);

InstallMethod(OutNeighbours, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  IsValidDigraph(D);
  return DIGRAPH_OUT_NEIGHBOURS(D);
end);

# The next method is (yet another) DFS as described in
# http://www.eecs.wsu.edu/~holder/courses/CptS223/spr08/slides/graphapps.pdf

InstallMethod(ArticulationPoints, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local copy, nbs, counter, visited, num, low, parent, points, points_seen,
        stack, depth, v, w, i;
  IsValidDigraph(D);
  if (HasIsConnectedDigraph(D) and not IsConnectedDigraph(D))
      or DigraphNrVertices(D) <= 1 then
    return [];
  elif not IsSymmetricDigraph(D) then
    copy := DigraphSymmetricClosure(DigraphMutableCopy(D));
  else
    copy := D;
  fi;
  nbs := OutNeighbours(copy);

  counter     := 0;
  visited     := BlistList([1 .. DigraphNrVertices(copy)], []);
  num         := [];
  low         := [];
  parent      := [1];
  points      := [];
  points_seen := BlistList([1 .. DigraphNrVertices(copy)], []);
  stack       := [[1, 0]];
  depth       := 1;

  while depth > 1 or not visited[1] do
    v := stack[depth][1];
    if visited[v] then
      depth := depth - 1;
      v     := stack[depth][1];
      w     := nbs[v][stack[depth][2]];
      if v <> 1 and low[w] >= num[v] and not points_seen[v] then
        points_seen[v] := true;
        Add(points, v);
      fi;
      if low[w] < low[v] then
        low[v] := low[w];
      fi;
    else
      visited[v] := true;
      counter    := counter + 1;
      num[v]     := counter;
      low[v]     := counter;
    fi;
    i := PositionProperty(nbs[v], w -> w <> v, stack[depth][2]);
    while i <> fail do
      w := nbs[v][i];
      if not visited[w] then
        parent[w]       := v;
        stack[depth][2] := i;
        depth           := depth + 1;
        if not IsBound(stack[depth]) then
          stack[depth] := [];
        fi;
        stack[depth][1] := w;
        stack[depth][2] := 0;
        break;
      elif parent[v] <> w and num[w] < low[v] then
        low[v] := num[w];
      fi;
      i := PositionProperty(nbs[v], w -> w <> v, i);
    od;
  od;

  if counter = DigraphNrVertices(D) then
    i := Position(parent, 1, 1);
    if i <> fail and Position(parent, 1, i) <> fail then
      Add(points, 1);
    fi;
    if IsAttributeStoringRep(D) then
      SetIsConnectedDigraph(D, true);
    fi;
    return points;
  else
    if IsAttributeStoringRep(D) then
      SetIsConnectedDigraph(D, false);
    fi;
    return [];
  fi;
end);

InstallMethod(ChromaticNumber, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local nr, comps, upper, chrom, tmp_comps, tmp_upper, n, comp, bound, clique,
  c, i;
  IsValidDigraph(D);
  nr := DigraphNrVertices(D);

  if DigraphHasLoops(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no loops,");
  elif nr = 0 then
    return 0;  # chromatic number = 0 iff <D> has 0 verts
  elif IsNullDigraph(D) then
    return 1;  # chromatic number = 1 iff <D> has >= 1 verts & no edges
  elif IsBipartiteDigraph(D) then
    return 2;  # chromatic number = 2 iff <D> has >= 2 verts & is bipartite
               # <D> has at least 2 vertices at this stage
  fi;

  # The chromatic number of <D> is at least 3 and at most nr
  D := DigraphMutableCopy(D);
  D := DigraphRemoveAllMultipleEdges(D);
  D := DigraphSymmetricClosure(D);

  if IsCompleteDigraph(D) then
    # chromatic number = nr iff <D> has >= 2 verts & this cond.
    return nr;
  elif nr = 4 then
    # if nr = 4, then 3 is only remaining possible chromatic number
    return 3;
  fi;

  # The chromatic number of <D> is at least 3 and at most nr - 1

  # The variable <chrom> is the current best known lower bound for the
  # chromatic number of <D>.
  chrom := 3;

  # Prepare a list of connected components of D whose chromatic number we
  # do not yet know.
  if IsConnectedDigraph(D) then
    comps := [D];
    upper := [RankOfTransformation(DigraphGreedyColouring(D), nr)];
    chrom := Maximum(CliqueNumber(D), chrom);
  else
    tmp_comps := [];
    tmp_upper := [];
    for comp in DigraphConnectedComponents(D).comps do
      n := Length(comp);
      if chrom < n then
        # If chrom >= n, then we can colour the vertices of comp using any n of
        # the required (at least) chrom colours, and we do not have to consider
        # comp.

        # Note that n > chrom >= 3 and so comp is not null, so no need to check
        # for that.
        comp := InducedSubdigraph(DigraphMutableCopy(D), comp);
        if IsCompleteDigraph(comp) then
          # Since n > chrom, this is an improved lower bound for the overall
          # chromatic number.
          chrom := n;
        elif not IsBipartiteDigraph(comp) then
          # If comp is bipartite, then its chromatic number is 2, and, since
          # the chromatic number of D is >= 3, this component can be
          # ignored.
          bound := RankOfTransformation(DigraphGreedyColouring(comp),
                                        DigraphNrVertices(comp));
          if bound > chrom then
            # If bound <= chrom, then comp can be coloured by at most chrom
            # colours, and so we can ignore comp.
            clique := CliqueNumber(comp);
            if clique = bound then
              # The chromatic number of this component is known, and it can be
              # ignored, and clique = bound > chrom, and so clique is an
              # improved lower bound for the chromatic number of D.
              chrom := clique;
            else
              Add(tmp_comps, comp);
              Add(tmp_upper, bound);
              if clique > chrom then
                chrom := clique;
              fi;
            fi;
          fi;
        fi;
      fi;
    od;

    # Remove the irrelevant components since we have a possibly improved value
    # of chrom.
    comps := [];
    upper := [];

    for i in [1 .. Length(tmp_comps)] do
      if chrom < DigraphNrVertices(tmp_comps[i]) and chrom < tmp_upper[i] then
        Add(comps, tmp_comps[i]);
        Add(upper, tmp_upper[i]);
      fi;
    od;

    # Sort by size, since smaller components are easier to colour
    SortParallel(comps, upper, {x, y} -> Size(x) < Size(y));
  fi;
  for i in [1 .. Length(comps)] do
    # <c> is the current best upper bound for the chromatic number of comps[i]
    c := upper[i];
    while c > chrom and DigraphColouring(comps[i], c - 1) <> fail do
      c := c - 1;
    od;
    if c > chrom then
      chrom := c;
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
# function(D)
#   local gens, sch, reps, out, trace, word, i, w;
#
#   gens := GeneratorsOfGroup(DigraphGroup(D));
#   sch  := DigraphSchreierVector(D);
#   reps := RepresentativeOutNeighbours(D);
#
#   out  := EmptyPlist(DigraphNrVertices(D));
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

InstallMethod(DigraphAdjacencyFunction, "for a dense digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return {u, v} -> IsDigraphEdge(D, u, v);
end);

InstallMethod(AsTransformation, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  IsValidDigraph(D);
  if not IsFunctionalDigraph(D) then
    return fail;
  fi;
  return Transformation(Concatenation(OutNeighbours(D)));
end);

InstallMethod(ReducedDigraph, "for a dense mutable digraph",
[IsDenseDigraphRep and IsMutableDigraph],
function(D)
  local v, niv, old, i;
  if IsConnectedDigraph(D) then
    return D;
  fi;

  v := DigraphVertices(D);
  niv := BlistList(v, []);
  old := OutNeighbours(D);

  # First find the non-isolated vertices
  for i in [1 .. Length(old)] do
    if not IsEmpty(old[i]) then
      niv[i] := true;
      UniteBlistList(v, niv, old[i]);
    fi;
  od;
  return InducedSubdigraph(D, ListBlist(v, niv));
end);

InstallMethod(ReducedDigraph, "for an immutable digraph", [IsImmutableDigraph],
function(D)
  if IsConnectedDigraph(D) then
    return D;
  fi;
  D := ReducedDigraph(DigraphMutableCopy(D));
  return MakeImmutableDigraph(D);
end);

InstallMethod(ReducedDigraphAttr, "for an immutable digraph",
[IsImmutableDigraph], ReducedDigraph);

InstallMethod(DigraphDual, "for a dense mutable digraph",
[IsDenseDigraphRep and IsMutableDigraph],
function(D)
  local nodes, list, i;
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no multiple ",
                  "edges,");
  fi;

  nodes := DigraphVertices(D);
  list := D!.OutNeighbours;

  for i in nodes do
    list[i] := DifferenceLists(nodes, list[i]);
  od;
  ClearDigraphEdgeLabels(D);
  return D;
end);

InstallMethod(DigraphDual, "for an immutable digraph", [IsImmutableDigraph],
function(D)
  local C;
  if HasDigraphDualAttr(D) then
    return DigraphDualAttr(D);
  fi;
  C := DigraphMutableCopy(D);
  C := MakeImmutableDigraph(DigraphDual(C));
  if HasDigraphGroup(D) then
    SetDigraphGroup(C, DigraphGroup(D));
  fi;
  SetDigraphDualAttr(D, C);
  return C;
end);

InstallMethod(DigraphDualAttr, "for an immutable digraph",
[IsImmutableDigraph], DigraphDual);

InstallMethod(DigraphNrEdges, "for a digraph", [IsDenseDigraphRep],
function(D)
  IsValidDigraph(D);
  return DIGRAPH_NREDGES(D);
end);

InstallMethod(DigraphEdges, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local out, adj, nr, i, j;
  IsValidDigraph(D);
  out := EmptyPlist(DigraphNrEdges(D));
  adj := OutNeighbours(D);
  nr := 0;

  for i in DigraphVertices(D) do
    for j in adj[i] do
      nr := nr + 1;
      out[nr] := [i, j];
    od;
  od;
  return out;
end);

# attributes for digraphs . . .

InstallMethod(AsGraph, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return Graph(D);
end);

InstallMethod(DigraphVertices, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return [1 .. DigraphNrVertices(D)];
end);

InstallMethod(DigraphRange, "for a dense digraph attribute storing digraph",
[IsDenseDigraphRep and IsAttributeStoringRep],
function(D)
  IsValidDigraph(D);
  if not IsBound(D!.DigraphRange) then
    DIGRAPH_SOURCE_RANGE(D);
    SetDigraphSource(D, D!.DigraphSource);
  fi;
  return D!.DigraphRange;
end);

InstallMethod(DigraphRange, "for a dense digraph attribute storing digraph",
[IsDenseDigraphRep and IsMutableDigraph],
function(D)
  return DIGRAPH_SOURCE_RANGE(D).DigraphRange;
end);

InstallMethod(DigraphSource, "for a dense digraph attribute storing digraph",
[IsDenseDigraphRep and IsAttributeStoringRep],
function(D)
  IsValidDigraph(D);
  if not IsBound(D!.DigraphSource) then
    DIGRAPH_SOURCE_RANGE(D);
    SetDigraphRange(D, D!.DigraphRange);
  fi;
  return D!.DigraphSource;
end);

InstallMethod(DigraphSource, "for a dense digraph attribute storing digraph",
[IsDenseDigraphRep and IsMutableDigraph],
function(D)
  return DIGRAPH_SOURCE_RANGE(D).DigraphSource;
end);

InstallMethod(InNeighbours, "for a digraph", [IsDenseDigraphRep],
function(D)
  IsValidDigraph(D);
  return DIGRAPH_IN_OUT_NBS(OutNeighbours(D));
end);

InstallMethod(AdjacencyMatrix, "for a digraph", [IsDenseDigraphRep],
function(D)
  IsValidDigraph(D);
  return ADJACENCY_MATRIX(D);
end);

InstallMethod(BooleanAdjacencyMatrix, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local n, nbs, mat, i, j;
  IsValidDigraph(D);
  n := DigraphNrVertices(D);
  nbs := OutNeighbours(D);
  mat := List(DigraphVertices(D), x -> BlistList([1 .. n], []));
  for i in DigraphVertices(D) do
    for j in nbs[i] do
      mat[i][j] := true;
    od;
  od;
  return mat;
end);

InstallMethod(DigraphShortestDistances, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local vertices, data, sum, distances, v, u;
  IsValidDigraph(D);
  if HasDIGRAPHS_ConnectivityData(D) then
    vertices := DigraphVertices(D);
    data := DIGRAPHS_ConnectivityData(D);
    sum := 0;
    for v in vertices do
      if IsBound(data[v]) then
        sum := sum + 1;
      fi;
    od;
    if sum > Int(0.9 * DigraphNrVertices(D))
        or (HasDigraphGroup(D) and not IsTrivial(DigraphGroup(D)))  then
      # adjust the constant 0.9 and possibly make a decision based on
      # how big the group is
      distances := [];
      for u in vertices do
        distances[u] := [];
        for v in vertices do
          distances[u][v] := DigraphShortestDistance(D, u, v);
        od;
      od;
      return distances;
    fi;
  fi;
  return DIGRAPH_SHORTEST_DIST(D);
end);

# returns the vertices (i.e. numbers) of <D> ordered so that there are no
# edges from <out[j]> to <out[i]> for all <i> greater than <j>.

InstallMethod(DigraphTopologicalSort, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  IsValidDigraph(D);
  return DIGRAPH_TOPO_SORT(OutNeighbours(D));
end);

InstallMethod(DigraphStronglyConnectedComponents, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local verts;
  IsValidDigraph(D);

  if HasIsAcyclicDigraph(D) and IsAcyclicDigraph(D) then
    verts := DigraphVertices(D);
    return rec(comps := List(verts, x -> [x]), id := verts * 1);

  elif HasIsStronglyConnectedDigraph(D)
      and IsStronglyConnectedDigraph(D) then
    verts := DigraphVertices(D);
    return rec(comps := [verts * 1], id := verts * 0 + 1);
  fi;

  return GABOW_SCC(OutNeighbours(D));
end);

InstallMethod(DigraphNrStronglyConnectedComponents, "for a digraph",
[IsDigraph],
function(D)
  IsValidDigraph(D);
  return Length(DigraphStronglyConnectedComponents(D).comps);
end);

InstallMethod(DigraphConnectedComponents, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  IsValidDigraph(D);
  return DIGRAPH_CONNECTED_COMPONENTS(D);
end);

InstallMethod(OutDegrees, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local adj, degs, i;
  IsValidDigraph(D);
  adj := OutNeighbours(D);
  degs := EmptyPlist(DigraphNrVertices(D));
  for i in DigraphVertices(D) do
    degs[i] := Length(adj[i]);
  od;
  return degs;
end);

InstallMethod(InDegrees, "for a digraph with in neighbours",
[IsDigraph and HasInNeighbours],
2,  # to beat the method for IsDenseDigraphRep
function(D)
  local inn, degs, i;
  IsValidDigraph(D);
  inn := InNeighbours(D);
  degs := EmptyPlist(DigraphNrVertices(D));
  for i in DigraphVertices(D) do
    degs[i] := Length(inn[i]);
  od;
  return degs;
end);

InstallMethod(InDegrees, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local adj, degs, x, i;
  IsValidDigraph(D);
  adj := OutNeighbours(D);
  degs := [1 .. DigraphNrVertices(D)] * 0;
  for x in adj do
    for i in x do
      degs[i] := degs[i] + 1;
    od;
  od;
  return degs;
end);

InstallMethod(OutDegreeSequence, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  D := ShallowCopy(OutDegrees(D));
  Sort(D, {a, b} -> b < a);
  return D;
  # return SortedList(OutDegrees(D), {a, b} -> b < a);
end);

InstallMethod(OutDegreeSequence,
"for a dense digraph with known digraph group",
[IsDenseDigraphRep and HasDigraphGroup],
function(D)
  local out, adj, orbs, orb;
  IsValidDigraph(D);
  out := [];
  adj := OutNeighbours(D);
  orbs := DigraphOrbits(D);
  for orb in orbs do
    Append(out, [1 .. Length(orb)] * 0 + Length(adj[orb[1]]));
  od;
  Sort(out, {a, b} -> b < a);
  return out;
end);

InstallMethod(OutDegreeSet, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return Set(ShallowCopy(OutDegrees(D)));
end);

InstallMethod(InDegreeSequence, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  D := ShallowCopy(InDegrees(D));
  Sort(D, {a, b} -> b < a);
  return D;
  # return SortedList(OutDegrees(D), {a, b} -> b < a);
end);

InstallMethod(InDegreeSequence,
"for a digraph with known digraph group and in-neighbours",
[IsDigraph and HasDigraphGroup and HasInNeighbours],
function(D)
  local out, adj, orbs, orb;
  IsValidDigraph(D);
  out := [];
  adj := InNeighbours(D);
  orbs := DigraphOrbits(D);
  for orb in orbs do
    Append(out, [1 .. Length(orb)] * 0 + Length(adj[orb[1]]));
  od;
  Sort(out, {a, b} -> b < a);
  return out;
end);

InstallMethod(InDegreeSet, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return Set(ShallowCopy(InDegrees(D)));
end);

InstallMethod(DigraphSources, "for a digraph with in-degrees",
[IsDigraph and HasInDegrees], 3,
function(D)
  local degs;
  IsValidDigraph(D);
  degs := InDegrees(D);
  return Filtered(DigraphVertices(D), x -> degs[x] = 0);
end);

InstallMethod(DigraphSources, "for a digraph with in-neighbours",
[IsDigraph and HasInNeighbours],
2,  # to beat the method for IsDenseDigraphRep
function(D)
  local inn, sources, count, i;
  IsValidDigraph(D);

  inn := InNeighbours(D);
  sources := EmptyPlist(DigraphNrVertices(D));
  count := 0;
  for i in DigraphVertices(D) do
    if IsEmpty(inn[i]) then
      count := count + 1;
      sources[count] := i;
    fi;
  od;
  ShrinkAllocationPlist(sources);
  return sources;
end);

InstallMethod(DigraphSources, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local out, seen, tmp, next, v;
  IsValidDigraph(D);
  out  := OutNeighbours(D);
  seen := BlistList(DigraphVertices(D), []);
  for next in out do
    for v in next do
      seen[v] := true;
    od;
  od;
  # FIXME use FlipBlist (when available)
  tmp  := BlistList(DigraphVertices(D), DigraphVertices(D));
  SubtractBlist(tmp, seen);
  return ListBlist(DigraphVertices(D), tmp);
end);

InstallMethod(DigraphSinks, "for a digraph with out-degrees",
[IsDigraph and HasOutDegrees],
2,  # to beat the method for IsDenseDigraphRep
function(D)
  local degs;
  IsValidDigraph(D);
  degs := OutDegrees(D);
  return Filtered(DigraphVertices(D), x -> degs[x] = 0);
end);

InstallMethod(DigraphSinks, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local out, sinks, count, i;
  IsValidDigraph(D);

  out   := OutNeighbours(D);
  sinks := [];
  count := 0;
  for i in DigraphVertices(D) do
    if IsEmpty(out[i]) then
      count := count + 1;
      sinks[count] := i;
    fi;
  od;
  return sinks;
end);

InstallMethod(DigraphPeriod, "for a digraph", [IsDenseDigraphRep],
function(D)
  local comps, out, deg, nrvisited, period, stack, len, depth, current,
        olddepth, i;

  IsValidDigraph(D);
  if HasIsAcyclicDigraph(D) and IsAcyclicDigraph(D) then
    return 0;
  fi;

  comps := DigraphStronglyConnectedComponents(D).comps;
  out := OutNeighbours(D);
  deg := OutDegrees(D);

  nrvisited := [1 .. Length(DigraphVertices(D))] * 0;
  period := 0;

  for i in [1 .. Length(comps)] do
    stack := [comps[i][1]];
    len := 1;
    depth := EmptyPlist(Length(DigraphVertices(D)));
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
    SetIsAcyclicDigraph(D, true);
  fi;

  return period;
end);

InstallMethod(DIGRAPHS_ConnectivityData, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return [];
end);

BindGlobal("DIGRAPH_ConnectivityDataForVertex",
function(D, v)
  local data, out_nbs, record, orbnum, reps, i, next, laynum, localGirth,
        layers, sum, localParameters, nprev, nhere, nnext, lnum, localDiameter,
        layerNumbers, x, y;
  data := DIGRAPHS_ConnectivityData(D);

  if IsBound(data[v]) then
    return data[v];
  fi;

  out_nbs := OutNeighbours(D);
  if HasDigraphGroup(D) then
    record          := DIGRAPHS_Orbits(DigraphStabilizer(D, v),
                                       DigraphVertices(D));
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
    orbnum          := [1 .. DigraphNrVertices(D)];
    reps            := [1 .. DigraphNrVertices(D)];
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
  for i in [1 .. DigraphNrVertices(D)] do
     layerNumbers[i] := laynum[orbnum[i]];
  od;
  data[v] := rec(layerNumbers := layerNumbers, localDiameter := localDiameter,
                 localGirth := localGirth, localParameters := localParameters,
                 layers := layers);
  return data[v];
end);

BindGlobal("DIGRAPHS_DiameterAndUndirectedGirth",
function(D)
  local outer_reps, diameter, girth, v, record, localGirth,
        localDiameter, i;

  #
  # This function attempts to find the diameter and undirected girth of a given
  # D, using its DigraphGroup.  For some digraphs, the main algorithm will
  # not produce a sensible answer, so there are checks at the start and end to
  # alter the answer for the diameter/girth if necessary.  This function is
  # called, if appropriate, by DigraphDiameter and DigraphUndirectedGirth.
  #

  if DigraphNrVertices(D) = 0 then
    SetDigraphDiameter(D, fail);
    SetDigraphUndirectedGirth(D, infinity);
    return rec(diameter := fail, girth := infinity);
  fi;

  # TODO improve this, really check if the complexity is better with the group
  # or without, or if the group is not known, but the number of vertices makes
  # the usual algorithm impossible.

  outer_reps := DigraphOrbitReps(D);
  diameter   := 0;
  girth      := infinity;

  for i in [1 .. Length(outer_reps)] do
    v := outer_reps[i];
    record     := DIGRAPH_ConnectivityDataForVertex(D, v);
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
  if not IsStronglyConnectedDigraph(D) then
    diameter := fail;
  fi;
  if DigraphHasLoops(D) then
    girth := 1;
  elif IsMultiDigraph(D) then
    girth := 2;
  fi;

  SetDigraphDiameter(D, diameter);
  SetDigraphUndirectedGirth(D, girth);
  return rec(diameter := diameter, girth := girth);
end);

InstallMethod(DigraphDiameter, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  if not IsStronglyConnectedDigraph(D) then
    # Diameter undefined
    return fail;
  elif HasDigraphGroup(D) and Size(DigraphGroup(D)) > 1 then
    # Use the group to calculate the diameter
    return DIGRAPHS_DiameterAndUndirectedGirth(D).diameter;
  fi;
  # Use the C function
  return DIGRAPH_DIAMETER(D);
end);

InstallMethod(DigraphUndirectedGirth, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  # This is only defined on undirected graphs (i.e. symmetric digraphs)
  if not IsSymmetricDigraph(D) then
    ErrorNoReturn("the argument <D> must be a symmetric digraph,");
  fi;
  if DigraphHasLoops(D) then
    # A loop is a cycle of length 1
    return 1;
  elif IsMultiDigraph(D) then
    # A pair of multiple edges is a cycle of length 2
    return 2;
  fi;
  # Otherwise D is simple
  return DIGRAPHS_DiameterAndUndirectedGirth(D).girth;
end);

InstallMethod(DigraphGirth, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local verts, girth, out, dist, i, j;
  IsValidDigraph(D);
  if DigraphHasLoops(D) then
    return 1;
  fi;
  # Only consider one vertex from each orbit
  if HasDigraphGroup(D) and not IsTrivial(DigraphGroup(D)) then
    verts := DigraphOrbitReps(D);
  else
    verts := DigraphVertices(D);
  fi;
  girth := infinity;
  out := OutNeighbours(D);
  for i in verts do
    for j in out[i] do
      dist := DigraphShortestDistance(D, j, i);
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

InstallMethod(DigraphOddGirthC, "for a digraph",
[IsDigraph],
function(digraph)
  local A, B, k, n, NVerts, NEdges, girth, comp;
  if IsStronglyConnectedDigraph(digraph) then
    girth := DigraphGirth(digraph);
    if girth = infinity or IsOddInt(girth) then
      return girth;
    fi;
    NVerts := DigraphNrVertices(digraph);
    NEdges := DigraphNrEdges(digraph);

    k      := girth - 1;

    A      := AdjacencyMatrix(digraph) ^ k;
    B      := AdjacencyMatrix(digraph) ^ 2;
    while k <= NEdges + 2 and k < NVerts do
      A := A * B;
      k := k + 2;
      if Trace(A) <> 0 then
        # It suffices to find the trace as entries of A are positive.
        return k;
      fi;
    od;
    return infinity;
  fi;
  n := infinity;
  for comp in DigraphStronglyConnectedComponents(digraph).comps do
    k := DigraphOddGirth(InducedSubdigraph(digraph, comp));
    if k < n then
      n := k;
    fi;
  od;
  return n;
end);

InstallMethod(DigraphOddGirthB, "for a digraph",
[IsDigraph],
function(digraph)
  local A, B, k, n, NVerts, NEdges, girth, comp;
  if IsAcyclicDigraph(digraph) then
    return infinity;
  elif IsStronglyConnectedDigraph(digraph) then
    girth := DigraphGirth(digraph);
    if girth = infinity or IsOddInt(girth) then
      return girth;
    fi;
    NVerts := DigraphNrVertices(digraph);
    NEdges := DigraphNrEdges(digraph);
    A      := AdjacencyMatrix(digraph);
    B      := A ^ 2;
    k      := girth - 1;
    while k <= NEdges + 2 and k < NVerts do
      A := A * B;
      k := k + 2;
      if Trace(A) <> 0 then
        # It suffices to find the trace as entries of A are positive.
        return k;
      fi;
    od;
    return infinity;
  fi;
  n := infinity;
  for comp in DigraphStronglyConnectedComponents(digraph).comps do
    k := DigraphOddGirth(InducedSubdigraph(digraph, comp));
    if k < n then
      n := k;
    fi;
  od;
  return n;
end);

InstallMethod(DigraphOddGirth, "for a digraph",
[IsDigraph],
function(digraph)
  local comps, girth, oddgirth, A, B, gr, k, comp;
  if IsAcyclicDigraph(digraph) then
    return infinity;
  elif IsOddInt(DigraphGirth(digraph)) then
    # No need to check girth isn't infinity, as we have
    # that digraph is cyclic.
    return DigraphGirth(digraph);
  fi;
  comps := DigraphStronglyConnectedComponents(digraph).comps;
  oddgirth := infinity;
  for comp in comps do
    if not IsStronglyConnectedDigraph(digraph) then
      gr    := InducedSubdigraph(digraph, comp);
    else
      gr := digraph;
      # If digraph is strongly connected, then we needn't
      # induce the subdigraph of its strongly connected comp.
    fi;
    if not IsAcyclicDigraph(gr) then
      girth := DigraphGirth(gr);
      if IsOddInt(girth) and girth < oddgirth then
        oddgirth := girth;
      else
        k := girth - 1;
        A := AdjacencyMatrix(gr) ^ k;
        B := AdjacencyMatrix(gr) ^ 2;
        while k <= DigraphNrEdges(gr) + 2 and k < DigraphNrVertices(gr) do
          A := A * B;
          k := k + 2;
          if k < oddgirth and Trace(A) <> 0 then
            # It suffices to find the trace as the entries of A are positive.
            oddgirth := k;
          fi;
        od;
      fi;
    fi;
  od;

  return oddgirth;
end);

InstallMethod(DigraphLongestSimpleCircuit, "for a digraph",
[IsDigraph],
function(D)
  local circs, lens, max;
  IsValidDigraph(D);
  if IsAcyclicDigraph(D) then
    return fail;
  fi;
  circs := DigraphAllSimpleCircuits(D);
  lens := List(circs, Length);
  max := Maximum(lens);
  return circs[Position(lens, max)];
end);

# TODO (FLS): I've just added 1 as the edge label here, is this really desired?
InstallMethod(DigraphSymmetricClosure, "for a dense mutable digraph",
[IsDenseDigraphRep and IsMutableDigraph],
function(D)
  local n, m, verts, mat, out, x, i, j, k;
  n := DigraphNrVertices(D);
  if n <= 1 or (HasIsSymmetricDigraph(D) and IsSymmetricDigraph(D)) then
    return D;
  fi;

  # The average degree
  m := Float(Sum(OutDegreeSequence(D)) / n);
  verts := [1 .. n];  # We don't want DigraphVertices as that's immutable

  if IsMultiDigraph(D) then
    mat := List(verts, x -> verts * 0);
    out := D!.OutNeighbours;

    for i in verts do
      for j in out[i] do
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
            Add(out[j], i);
          od;
        elif x < 0 then
          for k in [1 .. -x] do
            Add(out[i], j);
          od;
        fi;
      od;
    od;
    # The approximate complexity of using the adjacency matrix (first method)
    # is n * (n - 1) / 2, and that of repeatedly calling AddSet (second method)
    # is n * m * log2(m) where m is the mean degree of any vertex. Some
    # experimenting showed that the comparison below is a reasonable way to
    # decide which method to use.
  elif Float(n * (n - 1) / 2) < n * m * Log2(m) then
    # If we have no multiple edges, then we use a Boolean matrix because it
    # uses less space.
    mat := BooleanAdjacencyMatrixMutableCopy(D);
    for i in verts do
      for j in [i + 1 .. n] do
        if mat[i][j] <> mat[j][i] then
          mat[i][j] := true;
          mat[j][i] := true;
        fi;
      od;
    od;
    D!.OutNeighbours := List(mat, row -> ListBlist(verts, row));
  else
    out := D!.OutNeighbours;
    Perform(out, Sort);
    for i in [1 .. n] do
      for j in out[i] do
        if not i in out[j] then
          AddSet(out[j], i);
        fi;
      od;
    od;
  fi;
  ClearDigraphEdgeLabels(D);
  return D;
end);

InstallMethod(DigraphSymmetricClosure, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  local C;
  if HasDigraphSymmetricClosureAttr(D) then
    return DigraphSymmetricClosureAttr(D);
  fi;

  if DigraphNrVertices(D) <= 1
      or (HasIsSymmetricDigraph(D) and IsSymmetricDigraph(D)) then
    return D;
  fi;

  C := DigraphMutableCopy(D);
  C := MakeImmutableDigraph(DigraphSymmetricClosure(C));
  SetIsSymmetricDigraph(C, true);
  SetDigraphSymmetricClosureAttr(D, C);
  return C;
end);

InstallMethod(DigraphSymmetricClosureAttr, "for an immutable digraph",
[IsImmutableDigraph], DigraphSymmetricClosure);

InstallMethod(DigraphTransitiveClosure, "for a mutable dense digraph",
[IsMutableDigraph and IsDenseDigraphRep],
function(D)
  local list, m, n, nodes, sorted, trans, tmp, mat, v, u, i;

  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no multiple ",
                  "edges,");
  fi;

  list  := D!.OutNeighbours;
  m     := DigraphNrEdges(D);
  n     := DigraphNrVertices(D);
  nodes := DigraphVertices(D);

  ClearDigraphEdgeLabels(D);
  # Try correct method vis-a-vis complexity
  if m + n + (m * n) < n ^ 3 then
    sorted := DigraphTopologicalSort(D);
    if sorted <> fail then  # Method for big acyclic digraphs (loops allowed)
      trans := EmptyPlist(n);
      for v in sorted do
        trans[v] := BlistList(nodes, [v]);
        for u in list[v] do
          trans[v] := UnionBlist(trans[v], trans[u]);
        od;
        # TODO use FlipBlist
        tmp := DifferenceBlist(trans[v], BlistList(nodes, list[v]));
        tmp[v] := false;
        Append(list[v], ListBlist(nodes, tmp));
      od;
      return D;
    fi;
  fi;
  # Method for small or non-acyclic digraphs
  mat := DIGRAPH_TRANS_CLOSURE(D);
  for i in [1 .. Length(list)] do
    list[i] := nodes{PositionsProperty(mat[i], x -> x > 0)};
  od;
  return D;
end);

InstallMethod(DigraphReflexiveTransitiveClosure, "for a mutable digraph",
[IsMutableDigraph],
function(D)
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no multiple ",
                  "edges,");
  fi;
  return DigraphAddAllLoops(DigraphTransitiveClosure(D));
end);

InstallMethod(DigraphTransitiveClosure, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  local C;
  if HasDigraphTransitiveClosureAttr(D) then
    return DigraphTransitiveClosureAttr(D);
  fi;
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no multiple ",
                  "edges,");
  fi;
  C := DigraphTransitiveClosure(DigraphMutableCopy(D));
  C := MakeImmutableDigraph(C);
  SetIsTransitiveDigraph(C, true);
  SetDigraphVertexLabels(C, DigraphVertexLabels(D));
  SetDigraphTransitiveClosureAttr(D, C);
  return C;
end);

InstallMethod(DigraphReflexiveTransitiveClosure, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  local C;
  if HasDigraphReflexiveTransitiveClosureAttr(D) then
    return DigraphReflexiveTransitiveClosureAttr(D);
  fi;
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no multiple ",
                  "edges,");
  fi;
  C := DigraphReflexiveTransitiveClosure(DigraphMutableCopy(D));
  C := MakeImmutableDigraph(C);
  SetIsTransitiveDigraph(C, true);
  SetIsReflexiveDigraph(C, true);
  SetDigraphVertexLabels(C, DigraphVertexLabels(D));
  SetDigraphReflexiveTransitiveClosureAttr(D, C);
  return C;
end);

InstallMethod(DigraphTransitiveClosureAttr, "for an immutable digraph",
[IsImmutableDigraph], DigraphTransitiveClosure);

InstallMethod(DigraphReflexiveTransitiveClosureAttr,
"for an immutable digraph",
[IsImmutableDigraph], DigraphReflexiveTransitiveClosure);

InstallMethod(DigraphAllSimpleCircuits, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local UNBLOCK, CIRCUIT, out, stack, endofstack, C, scc, n, blocked, B,
  c_comp, comp, s, loops, i;
  IsValidDigraph(D);

  if DigraphNrVertices(D) = 0 or DigraphNrEdges(D) = 0 then
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

  # Reduce the D, remove loops, and store the correct vertex labels
  C := DigraphRemoveLoops(ReducedDigraph(DigraphMutableCopy(D)));
  if DigraphVertexLabels(D) <> DigraphVertices(D) then
    SetDigraphVertexLabels(C, Filtered(DigraphVertices(D),
                                       x -> OutDegrees(D) <> 0));
  fi;

  # Strongly connected components of the reduced graph
  scc := DigraphStronglyConnectedComponents(C);

  # B and blocked only need to be as long as the longest connected component
  n := Maximum(List(scc.comps, Length));
  blocked := BlistList([1 .. n], []);
  B := List([1 .. n], x -> []);

  # Perform algorithm once per connected component of the whole digraph
  for c_comp in scc.comps do
    n := Length(c_comp);
    if n = 1 then
      continue;
    fi;
    c_comp := InducedSubdigraph(DigraphMutableCopy(C), c_comp);
    comp := c_comp;
    s := 1;
    while s < n do
      if s <> 1 then
        comp := InducedSubdigraph(DigraphMutableCopy(c_comp), [s .. n]);
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
  loops := List(DigraphLoops(D), x -> [x]);
  return Concatenation(loops, out);
end);

# The following method 'DIGRAPHS_Bipartite' was originally written by Isabella
# Scott and then modified by FLS.
# It is the backend to IsBipartiteDigraph, Bicomponents, and DigraphColouring
# for a 2-colouring

InstallMethod(DIGRAPHS_Bipartite, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local n, t, colours, in_nbrs, stack, pop, v, pos, nbrs, w, i;
  IsValidDigraph(D);
  n := DigraphNrVertices(D);
  if n < 2 then
    return [false, fail];
  elif IsEmptyDigraph(D) then
    t := Concatenation(ListWithIdenticalEntries(n - 1, 1), [2]);
    return [true, Transformation(t)];
  fi;
  colours := ListWithIdenticalEntries(n, 0);
  in_nbrs := InNeighbours(D);
  # TODO maybe use stack from DataStructures?
  stack := [];
  for v in [1 .. n] do
    if colours[v] <> 0 then
      continue;
    fi;
    stack := [[v, 1]];
    while Length(stack) > 0 do
      pop := stack[Length(stack)];
      Remove(stack, Length(stack));
      v := pop[1];
      pos := pop[2];
      nbrs := Concatenation(OutNeighboursOfVertex(D, v),
                            in_nbrs[v]);
      for i in [pos .. Length(nbrs)] do
        w := nbrs[i];
        if colours[w] <> 0 then
          if colours[w] = colours[v] then
            return [false, fail];
          fi;
        else
          colours[w] := colours[v] mod 2 + 1;
          Append(stack, [[v, i + 1], [w, 1]]);
          continue;
        fi;
      od;
    od;
  od;
  return [true, Transformation(colours)];
end);

InstallMethod(DigraphBicomponents, "for a digraph", [IsDigraph],
function(D)
  local b;
  IsValidDigraph(D);

  # Attribute only applies to bipartite digraphs
  if not IsBipartiteDigraph(D) then
    return fail;
  fi;
  b := KernelOfTransformation(DIGRAPHS_Bipartite(D)[2],
                              DigraphNrVertices(D));
  return b;
end);

InstallMethod(DigraphLoops, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  IsValidDigraph(D);
  if HasDigraphHasLoops(D) and not DigraphHasLoops(D) then
    return [];
  fi;
  return Filtered(DigraphVertices(D), x -> x in OutNeighboursOfVertex(D, x));
end);

InstallMethod(DigraphDegeneracy, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  if not IsSymmetricDigraph(D) or IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a symmetric digraph ",
                  "with no multiple edges,");
  fi;
  return DIGRAPHS_Degeneracy(DigraphRemoveLoops(D))[1];
end);

InstallMethod(DigraphDegeneracyOrdering, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  if not IsSymmetricDigraph(D) or IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a symmetric digraph ",
                  "with no multiple edges,");
  fi;
  return DIGRAPHS_Degeneracy(DigraphRemoveLoops(D))[2];
end);

InstallMethod(DIGRAPHS_Degeneracy, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local nbs, n, out, deg_vert, m, verts_deg, k, i, v, d, w;

  # The code assumes undirected, no multiple edges, no loops
  nbs := OutNeighbours(D);
  n := DigraphNrVertices(D);
  out := EmptyPlist(n);
  deg_vert := ShallowCopy(OutDegrees(D));
  m := Maximum(deg_vert);
  verts_deg := List([1 .. m], x -> []);

  # Prepare the set verts_deg
  for v in DigraphVertices(D) do
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

InstallMethod(MaximalSymmetricSubdigraphWithoutLoops, "for a mutable digraph",
[IsMutableDigraph],
function(D)
  return DigraphRemoveLoops(MaximalSymmetricSubdigraph(D));
end);

InstallMethod(MaximalSymmetricSubdigraphWithoutLoops,
"for an immutable digraph",
[IsImmutableDigraph],
function(D)
  local C;
  if HasMaximalSymmetricSubdigraphWithoutLoopsAttr(D) then
    return MaximalSymmetricSubdigraphWithoutLoopsAttr(D);
  fi;
  C := DigraphMutableCopy(D);
  C := MakeImmutableDigraph(MaximalSymmetricSubdigraphWithoutLoops(C));
  SetMaximalSymmetricSubdigraphWithoutLoopsAttr(D, C);
  return C;
end);

InstallMethod(MaximalSymmetricSubdigraphWithoutLoopsAttr,
"for an immutable digraph",
[IsImmutableDigraph], MaximalSymmetricSubdigraphWithoutLoops);

InstallMethod(MaximalSymmetricSubdigraph, "for a mutable digraph",
[IsMutableDigraph],
function(D)
  local out, inn, i;
  DigraphRemoveAllMultipleEdges(D);
  if IsSymmetricDigraph(D) then
    return D;
  fi;
  out := D!.OutNeighbours;
  inn := InNeighbours(D);
  for i in DigraphVertices(D) do
    Sort(out[i]);
    IntersectSet(out[i], inn[i]);
  od;
  ClearDigraphEdgeLabels(D);
  return D;
end);

InstallMethod(MaximalSymmetricSubdigraph, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  local C;
  if HasMaximalSymmetricSubdigraphAttr(D) then
    return MaximalSymmetricSubdigraphAttr(D);
  fi;
  C := DigraphMutableCopy(D);
  C := MakeImmutableDigraph(MaximalSymmetricSubdigraph(C));
  SetDigraphVertexLabels(C, DigraphVertexLabels(D));
  SetMaximalSymmetricSubdigraphAttr(D, C);
  return C;
end);

InstallMethod(MaximalSymmetricSubdigraphAttr, "for an immutable digraph",
[IsImmutableDigraph], MaximalSymmetricSubdigraph);

InstallMethod(UndirectedSpanningForestAttr, [IsImmutableDigraph],
UndirectedSpanningForest);

InstallMethod(UndirectedSpanningForest, "for a dense mutable digraph",
[IsMutableDigraph and IsDenseDigraphRep],
function(D)
  if DigraphNrVertices(D) = 0 then
    return fail;
  fi;
  MaximalSymmetricSubdigraph(D);
  D!.OutNeighbours := DIGRAPH_SYMMETRIC_SPANNING_FOREST(D!.OutNeighbours);
  ClearDigraphEdgeLabels(D);
  return D;
end);

InstallMethod(UndirectedSpanningForest, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  local C;
  if HasUndirectedSpanningForestAttr(D) then
    return UndirectedSpanningForestAttr(D);
  fi;
  if DigraphNrVertices(D) = 0 then
    SetUndirectedSpanningForestAttr(D, fail);
    return fail;
  fi;
  C := UndirectedSpanningForest(DigraphMutableCopy(D));
  C := MakeImmutableDigraph(C);
  SetIsUndirectedForest(C, true);
  SetIsMultiDigraph(C, false);
  SetDigraphHasLoops(C, false);
  SetUndirectedSpanningForestAttr(D, C);
  return C;
end);

InstallMethod(UndirectedSpanningTreeAttr, [IsImmutableDigraph],
UndirectedSpanningTree);

InstallMethod(UndirectedSpanningTree, "for a dense mutable digraph",
[IsMutableDigraph and IsDenseDigraphRep],
function(D)
  local C;
  if not IsStronglyConnectedDigraph(D) then
    return fail;
  fi;
  C := MaximalSymmetricSubdigraph(DigraphMutableCopy(D));
  if not IsStronglyConnectedDigraph(C) then
    return fail;
  fi;
  return UndirectedSpanningForest(D);
end);

InstallMethod(UndirectedSpanningTree, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  local C;
  if HasUndirectedSpanningTreeAttr(D) then
    return UndirectedSpanningTreeAttr(D);
  fi;
  C := UndirectedSpanningTree(DigraphMutableCopy(D));
  SetUndirectedSpanningTreeAttr(D, C);
  if C = fail then
    return C;
  fi;
  SetIsUndirectedTree(C, true);
  return MakeImmutableDigraph(C);
end);

InstallMethod(HamiltonianPath, "for a digraph", [IsDigraph],
function(D)
  local path, iter, n;
  IsValidDigraph(D);

  if DigraphNrVertices(D) <= 1 and IsEmptyDigraph(D) then
    if DigraphNrVertices(D) = 0 then
      return [];
    else
      return [1];
    fi;
  elif not IsStronglyConnectedDigraph(D) then
    return fail;
  fi;

  if DigraphNrVertices(D) < 256 then
    path := DigraphMonomorphism(CycleDigraph(DigraphNrVertices(D)), D);
    if path = fail then
      return fail;
    fi;
    return ImageListOfTransformation(path, DigraphNrVertices(D));
  fi;

  iter := IteratorOfPaths(D, 1, 1);
  n := DigraphNrVertices(D) + 1;
  while not IsDoneIterator(iter) do
    path := NextIterator(iter)[1];
    if Length(path) = n then
      return path;
    fi;
  od;
  return fail;
end);

InstallMethod(MaximalAntiSymmetricSubdigraphAttr, "for an immutable digraph",
[IsImmutableDigraph], MaximalAntiSymmetricSubdigraph);

InstallMethod(MaximalAntiSymmetricSubdigraph, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  local C;
  if HasMaximalAntiSymmetricSubdigraphAttr(D) then
    return MaximalAntiSymmetricSubdigraphAttr(D);
  fi;
  C := DigraphMutableCopy(D);
  C := MakeImmutableDigraph(MaximalAntiSymmetricSubdigraph(C));
  SetIsAntisymmetricDigraph(C, true);
  SetMaximalAntiSymmetricSubdigraphAttr(D, C);
  return C;
end);

InstallMethod(MaximalAntiSymmetricSubdigraph, "for a dense mutable digraph",
[IsMutableDigraph and IsDenseDigraphRep],
function(D)
  local n, m, out, i, j;

  n := DigraphNrVertices(D);
  if IsMultiDigraph(D) then
    return MaximalAntiSymmetricSubdigraph(DigraphRemoveAllMultipleEdges(D));
  elif n <= 1 or IsAntisymmetricDigraph(D) then
    return D;
  fi;

  # The average degree
  m := Float(Sum(OutDegreeSequence(D)) / n);

  if Float(n * (n - 1) / 2) < n * m * Log2(m) then
    # The approximate complexity of using the adjacency matrix (first method)
    # is n * (n - 1) / 2, and that of repeatedly calling AddSet (second method)
    # is n * m * log2(m) where m is the mean degree of any vertex. Some
    # experimenting showed that the comparison below is a reasonable way to
    # decide which method to use.
    out := BooleanAdjacencyMatrixMutableCopy(D);
    for i in [1 .. n] do
      for j in [i + 1 .. n] do
        if out[i][j] then
          out[j][i] := false;
        fi;
      od;
    od;
    D!.OutNeighbours := List([1 .. n], v -> ListBlist([1 .. n], out[v]));
  else
    out := D!.OutNeighbours;
    Perform(out, Sort);
    for i in [1 .. n] do
      for j in out[i] do
        if i <> j then
          RemoveSet(out[j], i);
        fi;
      od;
    od;
  fi;
  ClearDigraphEdgeLabels(D);
  return D;
end);

InstallMethod(CharacteristicPolynomial, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return CharacteristicPolynomial(AdjacencyMatrix(D));
end);

InstallMethod(IsVertexTransitive, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return IsTransitive(AutomorphismGroup(D), DigraphVertices(D));
end);

InstallMethod(IsEdgeTransitive, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no multiple",
                  " edges,");
  fi;
  return IsTransitive(AutomorphismGroup(D),
                      DigraphEdges(D),
                      OnPairs);
end);
