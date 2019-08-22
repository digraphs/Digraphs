#############################################################################
##
##  attr.gi
##  Copyright (C) 2014-19                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallMethod(DigraphNrVertices, "for a dense digraph", [IsDenseDigraphRep],
DIGRAPH_NR_VERTICES);

InstallMethod(OutNeighbours, "for a dense digraph", [IsDenseDigraphRep],
DIGRAPH_OUT_NEIGHBOURS);

# The next method is (yet another) DFS as described in
# http://www.eecs.wsu.edu/~holder/courses/CptS223/spr08/slides/graphapps.pdf

InstallMethod(ArticulationPoints, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local copy, nbs, counter, visited, num, low, parent, points, points_seen,
        stack, depth, v, w, i;
  if (HasIsConnectedDigraph(D) and not IsConnectedDigraph(D))
      or DigraphNrVertices(D) <= 1 then
    return [];
  elif not IsSymmetricDigraph(D) then
    copy := DigraphSymmetricClosure(DigraphImmutableCopyIfMutable(D));
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
    if IsImmutableDigraph(D) then
      SetIsConnectedDigraph(D, true);
    fi;
    return points;
  else
    if IsImmutableDigraph(D) then
      SetIsConnectedDigraph(D, false);
    fi;
    return [];
  fi;
end);

InstallMethod(ChromaticNumber, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local nr, comps, upper, chrom, tmp_comps, tmp_upper, n, comp, bound, clique,
  c, i;
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
D -> {u, v} -> IsDigraphEdge(D, u, v));

InstallMethod(AsTransformation, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  if not IsFunctionalDigraph(D) then
    return fail;
  fi;
  return Transformation(Concatenation(OutNeighbours(D)));
end);

InstallMethod(DigraphNrEdges, "for a digraph", [IsDenseDigraphRep],
DIGRAPH_NREDGES);

InstallMethod(DigraphEdges, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local out, adj, nr, i, j;
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

InstallMethod(AsGraph, "for a digraph", [IsDigraph], Graph);

InstallMethod(DigraphVertices, "for a digraph", [IsDigraph],
D -> [1 .. DigraphNrVertices(D)]);

InstallMethod(DigraphRange, "for a dense digraph attribute storing digraph",
[IsDenseDigraphRep and IsImmutableDigraph],
function(D)
  if not IsBound(D!.DigraphRange) then
    DIGRAPH_SOURCE_RANGE(D);
    SetDigraphSource(D, D!.DigraphSource);
  fi;
  return D!.DigraphRange;
end);

InstallMethod(DigraphRange, "for a dense digraph attribute storing digraph",
[IsDenseDigraphRep and IsMutableDigraph],
D -> DIGRAPH_SOURCE_RANGE(D).DigraphRange);

InstallMethod(DigraphSource, "for a dense digraph attribute storing digraph",
[IsDenseDigraphRep and IsImmutableDigraph],
function(D)
  if not IsBound(D!.DigraphSource) then
    DIGRAPH_SOURCE_RANGE(D);
    SetDigraphRange(D, D!.DigraphRange);
  fi;
  return D!.DigraphSource;
end);

InstallMethod(DigraphSource, "for a dense digraph attribute storing digraph",
[IsDenseDigraphRep and IsMutableDigraph],
D -> DIGRAPH_SOURCE_RANGE(D).DigraphSource);

InstallMethod(InNeighbours, "for a digraph", [IsDenseDigraphRep],
D -> DIGRAPH_IN_OUT_NBS(OutNeighbours(D)));

InstallMethod(AdjacencyMatrix, "for a digraph", [IsDenseDigraphRep],
ADJACENCY_MATRIX);

InstallMethod(BooleanAdjacencyMatrix, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local n, nbs, mat, i, j;
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
D -> DIGRAPH_TOPO_SORT(OutNeighbours(D)));

InstallMethod(DigraphStronglyConnectedComponents, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local verts;

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
D -> Length(DigraphStronglyConnectedComponents(D).comps));

InstallMethod(DigraphConnectedComponents, "for a dense digraph",
[IsDenseDigraphRep],
DIGRAPH_CONNECTED_COMPONENTS);

InstallMethod(DigraphNrConnectedComponents, "for a digraph",
[IsDigraph],
D -> Length(DigraphConnectedComponents(D).comps));

InstallMethod(OutDegrees, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local adj, degs, i;
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
D -> Set(ShallowCopy(OutDegrees(D))));

InstallMethod(InDegreeSequence, "for a digraph", [IsDigraph],
function(D)
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
D -> Set(ShallowCopy(InDegrees(D))));

InstallMethod(DigraphSources, "for a digraph with in-degrees",
[IsDigraph and HasInDegrees], 3,
function(D)
  local degs;
  degs := InDegrees(D);
  return Filtered(DigraphVertices(D), x -> degs[x] = 0);
end);

InstallMethod(DigraphSources, "for a digraph with in-neighbours",
[IsDigraph and HasInNeighbours],
2,  # to beat the method for IsDenseDigraphRep
function(D)
  local inn, sources, count, i;

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
  degs := OutDegrees(D);
  return Filtered(DigraphVertices(D), x -> degs[x] = 0);
end);

InstallMethod(DigraphSinks, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local out, sinks, count, i;

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

  if period = 0 and IsImmutableDigraph(D) then
    SetIsAcyclicDigraph(D, true);
  fi;

  return period;
end);

InstallMethod(DIGRAPHS_ConnectivityData, "for a digraph", [IsDigraph],
D -> EmptyPlist(0));

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

  # This function attempts to find the diameter and undirected girth of a given
  # D, using its DigraphGroup.  For some digraphs, the main algorithm will
  # not produce a sensible answer, so there are checks at the start and end to
  # alter the answer for the diameter/girth if necessary.  This function is
  # called, if appropriate, by DigraphDiameter and DigraphUndirectedGirth.

  if DigraphNrVertices(D) = 0 and IsImmutableDigraph(D) then
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

  if IsImmutableDigraph(D) then
    SetDigraphDiameter(D, diameter);
    SetDigraphUndirectedGirth(D, girth);
  fi;
  return rec(diameter := diameter, girth := girth);
end);

InstallMethod(DigraphDiameter, "for a digraph", [IsDigraph],
function(D)
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
  # This is only defined on undirected graphs (i.e. symmetric digraphs)
  if not IsSymmetricDigraph(D) then
    ErrorNoReturn("the argument <D> must be a symmetric digraph,");
  elif DigraphHasLoops(D) then
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

InstallMethod(DigraphOddGirth, "for a digraph",
[IsDigraph],
function(digraph)
  local comps, girth, oddgirth, A, B, gr, k, comp;

  if IsAcyclicDigraph(digraph) then
    return infinity;
  elif IsOddInt(DigraphGirth(digraph)) then
    # No need to check girth isn't infinity, as we have
    # that digraph is not acyclic.
    return DigraphGirth(digraph);
  fi;
  comps := DigraphStronglyConnectedComponents(digraph).comps;
  if Length(comps) > 1 and IsMutableDigraph(digraph) then
    # Necessary because InducedSubdigraph alters mutable args
    digraph := DigraphImmutableCopy(digraph);
  fi;
  oddgirth := infinity;
  for comp in comps do
    if comps > 1 then
      gr := InducedSubdigraph(digraph, comp);
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
        while k <= DigraphNrEdges(gr) + 2 and k < DigraphNrVertices(gr)
            and k < oddgirth - 2 do
          A := A * B;
          k := k + 2;
          if Trace(A) <> 0 then
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
  if IsAcyclicDigraph(D) then
    return fail;
  fi;
  circs := DigraphAllSimpleCircuits(D);
  lens := List(circs, Length);
  max := Maximum(lens);
  return circs[Position(lens, max)];
end);

InstallMethod(DigraphAllSimpleCircuits, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local UNBLOCK, CIRCUIT, out, stack, endofstack, C, scc, n, blocked, B,
  c_comp, comp, s, loops, i;

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
  C := DigraphRemoveLoops(ReducedDigraph(DigraphImmutableCopyIfMutable(D)));
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
    c_comp := InducedSubdigraph(DigraphImmutableCopyIfMutable(C), c_comp);
    comp := c_comp;
    s := 1;
    while s < n do
      if s <> 1 then
        comp := InducedSubdigraph(DigraphImmutableCopyIfMutable(c_comp),
                                  [s .. n]);
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
    colours[v] := 1;
    stack := [[v, 1]];
    while Length(stack) > 0 do
      pop := Remove(stack);
      v := pop[1];
      pos := pop[2];
      nbrs := Concatenation(OutNeighboursOfVertex(D, v), in_nbrs[v]);
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
  if HasDigraphHasLoops(D) and not DigraphHasLoops(D) then
    return [];
  fi;
  return Filtered(DigraphVertices(D), x -> x in OutNeighboursOfVertex(D, x));
end);

InstallMethod(DigraphDegeneracy, "for a digraph", [IsDigraph],
function(D)
  if not IsSymmetricDigraph(D) or IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a symmetric digraph ",
                  "with no multiple edges,");
  fi;
  return DIGRAPHS_Degeneracy(DigraphRemoveLoops(D))[1];
end);

InstallMethod(DigraphDegeneracyOrdering, "for a digraph", [IsDigraph],
function(D)
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

InstallMethod(DegreeMatrix, "for a digraph", [IsDigraph],
function(D)
  if DigraphNrVertices(D) = 0 then
    return [];
  fi;
  return DiagonalMat(OutDegrees(D));
end);

InstallMethod(LaplacianMatrix, "for a digraph", [IsDigraph],
D -> DegreeMatrix(D) - AdjacencyMatrix(D));

InstallMethod(NrSpanningTrees, "for a digraph", [IsDigraph],
function(D)
  local mat, n;
  if not IsSymmetricDigraph(D) then
    ErrorNoReturn("the argument <D> must be a symmetric digraph,");
  fi;

  n := DigraphNrVertices(D);
  if n = 0 then
    return 0;
  elif n = 1 then
    return 1;
  fi;

  mat := LaplacianMatrix(D);
  mat := mat{[1 .. n - 1]}{[1 .. n - 1]};
  return Determinant(mat);
end);

InstallMethod(HamiltonianPath, "for a digraph", [IsDigraph],
function(D)
  local path, iter, n;

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

InstallMethod(DigraphCore, "for a digraph",
[IsDigraph],
function(digraph)
  local N, lo, topdown, bottomup, hom, lo_var, image,
  comps, comp, cores, D, in_core, n, m, L, i;
  digraph := DigraphImmutableCopy(digraph);
  # copy is necessary so can change vertex labels in function
  N := DigraphNrVertices(digraph);
  if IsEmptyDigraph(digraph) then
    if N >= 1 then
      return [1];
    fi;
    return [];
  fi;
  SetDigraphVertexLabels(digraph, [1 .. N]);
  digraph := ReducedDigraph(digraph);  # isolated verts are not in core
  N       := DigraphNrVertices(digraph);
  if DigraphHasLoops(digraph) then
    i := First(DigraphVertices(digraph),
         i -> i in OutNeighboursOfVertex(digraph, i));
    return [DigraphVertexLabel(digraph, i)];
  elif IsCompleteDigraph(digraph) then
    return DigraphVertexLabels(digraph);
  elif IsSymmetricDigraph(digraph) and IsBipartiteDigraph(digraph) then
    i := First(DigraphVertices(digraph), i -> OutDegreeOfVertex(digraph, i) > 0);
    return DigraphVertexLabels(digraph){
    [i, OutNeighboursOfVertex(digraph, i)[1]]};
  elif not IsConnectedDigraph(digraph) then
    comps  := DigraphConnectedComponents(digraph).comps;
    cores  := [];
    for comp in comps do
      D := InducedSubdigraph(digraph, comp);
      D := InducedSubdigraph(D, DigraphCore(D));
      Add(cores, D);
    od;
    L       := Length(cores);
    in_core := ListWithIdenticalEntries(L, true);
    n       := 1;
    while n <= L do
      if n <> L then
        m := n + 1;
      else
        m := 1;
      fi;
      while m <> n and in_core[n] do
        if in_core[m] and DigraphHomomorphism(cores[m], cores[n]) <> fail then
          in_core[m] := false;
        fi;
        if m < L then
          m := m + 1;
        else
          m := 1;
        fi;
      od;
      n := n + 1;
    od;
    cores := ListBlist(cores, in_core);
    return Union(List(cores, DigraphVertexLabels));
  elif IsDigraphCore(digraph) then
    return DigraphVertexLabels(digraph);
  fi;

  lo := function(D)  # lower bound on core size
    local oddgirth;
    oddgirth := DigraphOddGirth(D);
    if oddgirth <> infinity then
      return oddgirth;
    fi;
    return 3;
  end;

  hom      := [];
  lo_var   := lo(digraph);
  bottomup := lo_var;
  N        := DigraphNrVertices(digraph);
  topdown  := N;

  while topdown >= bottomup do
    HomomorphismDigraphsFinder(digraph,                   # domain copy
                               digraph,                   # range copy
                               fail,                      # hook
                               hom,                       # user_param
                               1,                         # max_results
                               bottomup,                  # hint (i.e. rank)
                               false,                     # injective
                               DigraphVertices(digraph),  # image
                               [],                        # partial_map
                               fail,                      # colors1
                               fail);                     # colors2

    if Length(hom) = 1 then
      return DigraphVertexLabels(digraph){ImageSetOfTransformation(hom[1], N)};
    fi;

    HomomorphismDigraphsFinder(digraph,                   # domain copy
                               digraph,                   # range copy
                               fail,                      # hook
                               hom,                       # user_param
                               1,                         # max_results
                               topdown,                   # hint (i.e. rank)
                               false,                     # injective
                               DigraphVertices(digraph),  # image
                               [],                        # partial_map
                               fail,                      # colors1
                               fail);                     # colors2

    if Length(hom) = 1 then
      image    := ImageSetOfTransformation(hom[1], N);
      digraph  := InducedSubdigraph(digraph, image);
      N        := DigraphNrVertices(digraph);
      lo_var   := lo(digraph);
      Unbind(hom[1]);
    fi;

    topdown  := Minimum(topdown - 1, N);
    bottomup := Maximum(bottomup + 1, lo_var);

  od;
  return DigraphVertexLabels(digraph);
end);

InstallMethod(CharacteristicPolynomial, "for a digraph", [IsDigraph],
D -> CharacteristicPolynomial(AdjacencyMatrix(D)));

InstallMethod(IsVertexTransitive, "for a digraph", [IsDigraph],
D -> IsTransitive(AutomorphismGroup(D), DigraphVertices(D)));

InstallMethod(IsEdgeTransitive, "for a digraph", [IsDigraph],
function(D)
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no multiple",
                  " edges,");
  fi;
  return IsTransitive(AutomorphismGroup(D), DigraphEdges(D), OnPairs);
end);

# Things that are attributes for immutable digraphs, but operations for mutable.

InstallMethod(DigraphReverse, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local inn, C;
  if IsSymmetricDigraph(D) then
    return D;
  fi;
  inn := InNeighboursMutableCopy(D);
  if IsImmutableDigraph(D) then
    C := ConvertToImmutableDigraphNC(inn);
    SetDigraphVertexLabels(C, StructuralCopy(DigraphVertexLabels(D)));
    SetInNeighbours(C, OutNeighbours(D));
    SetDigraphReverseAttr(D, C);
    return C;
  fi;
  D!.OutNeighbours := inn;
  ClearDigraphEdgeLabels(D);
  return D;
end);

InstallMethod(DigraphReverse, "for a digraph with known digraph reverse",
[IsDigraph and HasDigraphReverseAttr], SUM_FLAGS, DigraphReverseAttr);

InstallMethod(DigraphReverseAttr, "for an immutable digraph",
[IsImmutableDigraph], DigraphReverse);

InstallMethod(DigraphDual, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local nodes, C, list, i;
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no multiple ",
                  "edges,");
  fi;

  nodes := DigraphVertices(D);

  C := DigraphMutableCopyIfImmutable(D);
  list := C!.OutNeighbours;
  for i in nodes do
    list[i] := DifferenceLists(nodes, list[i]);
  od;
  ClearDigraphEdgeLabels(C);
  if IsImmutableDigraph(D) then
    MakeImmutable(C);
    if HasDigraphGroup(D) then
      SetDigraphGroup(C, DigraphGroup(D));
    fi;
    # TODO WW: Could preserve some further properties/attributes too
  fi;
  return C;
end);

InstallMethod(DigraphDual, "for a digraph with known dual",
[IsDigraph and HasDigraphDualAttr], SUM_FLAGS, DigraphDualAttr);

InstallMethod(DigraphDualAttr, "for an immutable digraph", [IsImmutableDigraph],
DigraphDual);

InstallMethod(ReducedDigraph, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local v, niv, old, C, i;
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
  C := InducedSubdigraph(D, ListBlist(v, niv));
  # Store result if input (and hence output) immutable
  if IsImmutableDigraph(D) then
    SetReducedDigraphAttr(D, C);
  fi;
  return C;
end);

InstallMethod(ReducedDigraph, "for a digraph with known reduced digraph",
[IsDigraph and HasReducedDigraphAttr], SUM_FLAGS, ReducedDigraphAttr);

InstallMethod(ReducedDigraphAttr, "for an immutable digraph",
[IsImmutableDigraph], ReducedDigraph);

InstallMethod(DigraphRemoveAllMultipleEdges, "for a mutable dense digraph",
[IsMutableDigraph and IsDenseDigraphRep],
function(D)
  local nodes, list, empty, seen, keep, v, u, pos;

  nodes := DigraphVertices(D);
  list  := D!.OutNeighbours;
  empty := BlistList(nodes, []);
  seen  := BlistList(nodes, []);
  for u in nodes do
    keep := [];
    for pos in [1 .. Length(list[u])] do
      v := list[u][pos];
      if not seen[v] then
        seen[v] := true;
        Add(keep, pos);
      fi;
    od;
    list[u] := list[u]{keep};
    IntersectBlist(seen, empty);
  od;
  # Multidigraphs did not have edge labels
  SetDigraphVertexLabels(D, DigraphVertexLabels(D));
  return D;
end);

InstallMethod(DigraphRemoveAllMultipleEdges, "for an immutable digraph",
[IsImmutableDigraph], DigraphRemoveAllMultipleEdgesAttr);

InstallMethod(DigraphRemoveAllMultipleEdgesAttr, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  if IsMultiDigraph(D) then
    D := MakeImmutable(DigraphRemoveAllMultipleEdges(DigraphMutableCopy(D)));
    SetIsMultiDigraph(D, false);
  fi;
  return D;
end);

InstallMethod(DigraphAddAllLoops, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local ismulti, C, list, v;
  if HasIsReflexiveDigraph(D) and IsReflexiveDigraph(D) then
    return D;
  fi;
  ismulti := IsMultiDigraph(D);
  C := DigraphMutableCopyIfImmutable(D);
  list := C!.OutNeighbours;
  Assert(1, IsMutable(list));
  for v in DigraphVertices(C) do
    if not v in list[v] then
      Add(list[v], v);
      if not ismulti then
        SetDigraphEdgeLabel(C, v, v, 1);
      fi;
    fi;
  od;
  if IsImmutableDigraph(D) then
    MakeImmutable(C);
    SetDigraphAddAllLoopsAttr(D, C);
    SetIsReflexiveDigraph(C, true);
    SetIsMultiDigraph(C, ismulti);
    SetDigraphHasLoops(C, DigraphNrVertices(C) > 0);
  fi;
  return C;
end);

InstallMethod(DigraphAddAllLoops, "for a digraph with known add-all-loops",
[IsDigraph and HasDigraphAddAllLoopsAttr], SUM_FLAGS, DigraphAddAllLoopsAttr);

InstallMethod(DigraphAddAllLoopsAttr, "for an immutable digraph",
[IsImmutableDigraph], DigraphAddAllLoops);

InstallMethod(DigraphRemoveLoops, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local C, out, lbl, pos, v;
  C := DigraphMutableCopyIfImmutable(D);
  out := C!.OutNeighbours;
  lbl := DigraphEdgeLabelsNC(C);
  for v in DigraphVertices(C) do
    pos := Position(out[v], v);
    while pos <> fail do
      Remove(out[v], pos);
      Remove(lbl[v], pos);
      pos := Position(out[v], v);
    od;
  od;
  if IsImmutableDigraph(D) then
    MakeImmutable(C);
    SetDigraphRemoveLoopsAttr(D, C);
    SetDigraphHasLoops(C, false);
  fi;
  return C;
end);

InstallMethod(DigraphRemoveLoops, "for a digraph with stored result",
[IsDigraph and HasDigraphRemoveLoopsAttr], SUM_FLAGS, DigraphRemoveLoopsAttr);

InstallMethod(DigraphRemoveLoopsAttr, "for an immutable digraph",
[IsImmutableDigraph], DigraphRemoveLoops);

# TODO (FLS): I've just added 1 as the edge label here, is this really desired?
InstallMethod(DigraphSymmetricClosure, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local n, m, verts, C, mat, out, x, i, j, k;

  n := DigraphNrVertices(D);
  if n <= 1 or IsSymmetricDigraph(D) then
    return D;
  fi;

  # The average degree
  m := Float(Sum(OutDegreeSequence(D)) / n);
  verts := [1 .. n];  # We don't want DigraphVertices as that's immutable

  if IsMultiDigraph(D) then
    C := DigraphMutableCopyIfImmutable(D);
    mat := List(verts, x -> verts * 0);
    out := C!.OutNeighbours;

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
    out := List(mat, row -> ListBlist(verts, row));
    if IsImmutableDigraph(D) then
      C := ConvertToImmutableDigraphNC(out);
    else
      C := D;
      C!.OutNeighbours := out;
    fi;
  else
    C := DigraphMutableCopyIfImmutable(D);
    out := C!.OutNeighbours;
    Perform(out, Sort);
    for i in [1 .. n] do
      for j in out[i] do
        if not i in out[j] then
          AddSet(out[j], i);
        fi;
      od;
    od;
  fi;
  ClearDigraphEdgeLabels(C);
  if IsImmutableDigraph(D) then
    MakeImmutable(C);
    SetDigraphSymmetricClosureAttr(D, C);
    SetIsSymmetricDigraph(C, true);
  fi;
  return C;
end);

InstallMethod(DigraphSymmetricClosure,
"for a digraph with known symmetric closure",
[IsDigraph and HasDigraphSymmetricClosureAttr], SUM_FLAGS,
DigraphSymmetricClosureAttr);

InstallMethod(DigraphSymmetricClosureAttr, "for an immutable digraph",
[IsImmutableDigraph], DigraphSymmetricClosure);

InstallMethod(MaximalSymmetricSubdigraph, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local C, inn, out, i;

  # Remove multiple edges if present
  if IsMultiDigraph(D) then
    if HasDigraphRemoveAllMultipleEdgesAttr(D) then
      C := DigraphMutableCopy(DigraphRemoveAllMultipleEdges(D));
    else
      C := DigraphRemoveAllMultipleEdges(DigraphMutableCopyIfImmutable(D));
    fi;
  else
    C := D;
  fi;

  if not IsSymmetricDigraph(C) then
    # C is still immutable here if <D> is immutable and not a multidigraph
    inn := InNeighbours(C);
    C   := DigraphMutableCopyIfImmutable(C);
    out := C!.OutNeighbours;
    for i in DigraphVertices(C) do
      Sort(out[i]);
      IntersectSet(out[i], inn[i]);
    od;
  fi;

  ClearDigraphEdgeLabels(C);
  if IsImmutableDigraph(D) then
    MakeImmutable(C);
    SetMaximalSymmetricSubdigraphAttr(D, C);
    SetIsSymmetricDigraph(C, true);
    SetIsMultiDigraph(C, false);
  fi;
  return C;
end);

InstallMethod(MaximalSymmetricSubdigraph,
"for a digraph with known maximal symmetric subdigraph",
[IsDigraph and HasMaximalSymmetricSubdigraphAttr], SUM_FLAGS,
MaximalSymmetricSubdigraphAttr);

InstallMethod(MaximalSymmetricSubdigraphAttr, "for an immutable digraph",
[IsImmutableDigraph], MaximalSymmetricSubdigraph);

InstallMethod(MaximalSymmetricSubdigraphWithoutLoops, "for a mutable digraph",
[IsMutableDigraph],
D -> DigraphRemoveLoops(MaximalSymmetricSubdigraph(D)));

InstallMethod(MaximalSymmetricSubdigraphWithoutLoops,
"for an immutable digraph",
[IsImmutableDigraph], MaximalSymmetricSubdigraphWithoutLoopsAttr);

InstallMethod(MaximalSymmetricSubdigraphWithoutLoopsAttr,
"for an immutable digraph",
[IsImmutableDigraph],
function(D)
  if HasMaximalSymmetricSubdigraphAttr(D) then
    D := DigraphRemoveLoops(MaximalSymmetricSubdigraph(D));
  else
    D := DigraphMutableCopy(D);
    D := MakeImmutable(MaximalSymmetricSubdigraphWithoutLoops(D));
  fi;
  SetDigraphHasLoops(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsMultiDigraph(D, false);
  return D;
end);

InstallMethod(MaximalAntiSymmetricSubdigraph, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local n, C, m, out, i, j;

  n := DigraphNrVertices(D);
  if not IsMultiDigraph(D) and (n <= 1 or IsAntisymmetricDigraph(D)) then
    return D;
  elif IsMultiDigraph(D) then
    if HasDigraphRemoveAllMultipleEdgesAttr(D) then
      C := DigraphMutableCopy(DigraphRemoveAllMultipleEdges(D));
    else
      C := DigraphRemoveAllMultipleEdges(DigraphMutableCopyIfImmutable(D));
    fi;
  else
    C := DigraphMutableCopyIfImmutable(D);
  fi;

  # The average degree
  m := Float(Sum(OutDegreeSequence(C)) / n);

  if Float(n * (n - 1) / 2) < n * m * Log2(m) then
    # The approximate complexity of using the adjacency matrix (first method)
    # is n * (n - 1) / 2, and that of repeatedly calling AddSet (second method)
    # is n * m * log2(m) where m is the mean degree of any vertex. Some
    # experimenting showed that the comparison below is a reasonable way to
    # decide which method to use.
    out := BooleanAdjacencyMatrixMutableCopy(C);
    for i in [1 .. n] do
      for j in [i + 1 .. n] do
        if out[i][j] then
          out[j][i] := false;
        fi;
      od;
    od;
    C!.OutNeighbours := List([1 .. n], v -> ListBlist([1 .. n], out[v]));
  else
    out := C!.OutNeighbours;
    Perform(out, Sort);
    for i in [1 .. n] do
      for j in out[i] do
        if i <> j then
          RemoveSet(out[j], i);
        fi;
      od;
    od;
  fi;
  ClearDigraphEdgeLabels(C);
  if IsMutableDigraph(D) then
    return C;
  fi;
  MakeImmutable(C);
  SetIsAntisymmetricDigraph(C, true);
  SetIsMultiDigraph(C, false);
  SetMaximalAntiSymmetricSubdigraphAttr(D, C);
  return C;
end);

InstallMethod(MaximalAntiSymmetricSubdigraph,
"for a digraph with known maximal antisymmetric subdigraph",
[IsDigraph and HasMaximalAntiSymmetricSubdigraphAttr], SUM_FLAGS,
MaximalAntiSymmetricSubdigraphAttr);

InstallMethod(MaximalAntiSymmetricSubdigraphAttr, "for an immutable digraph",
[IsImmutableDigraph], MaximalAntiSymmetricSubdigraph);

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

InstallMethod(DigraphTransitiveClosure, "for an immutable digraph",
[IsImmutableDigraph], DigraphTransitiveClosureAttr);

InstallMethod(DigraphTransitiveClosureAttr, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  local C;
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no multiple ",
                  "edges,");
  fi;
  C := MakeImmutable(DigraphTransitiveClosure(DigraphMutableCopy(D)));
  SetIsTransitiveDigraph(C, true);
  SetIsMultiDigraph(C, false);
  return C;
end);

InstallMethod(DigraphReflexiveTransitiveClosure, "for a digraph",
[IsDigraph],
function(D)
  local C;
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no multiple ",
                  "edges,");
  elif HasDigraphTransitiveClosureAttr(D) then
    C := DigraphAddAllLoops(DigraphTransitiveClosure(D));
  else
    C := DigraphMutableCopyIfImmutable(D);
    DigraphAddAllLoops(DigraphTransitiveClosure(C));
  fi;

  if IsMutableDigraph(D) then
    return C;
  fi;
  MakeImmutable(C);
  SetDigraphReflexiveTransitiveClosureAttr(D, C);
  SetIsTransitiveDigraph(C, true);
  SetIsReflexiveDigraph(C, true);
  SetIsMultiDigraph(C, false);
  return C;
end);

InstallMethod(DigraphReflexiveTransitiveClosure,
"for a digraph with known reflexive transitive closure",
[IsDigraph and HasDigraphReflexiveTransitiveClosureAttr], SUM_FLAGS,
DigraphReflexiveTransitiveClosureAttr);

InstallMethod(DigraphReflexiveTransitiveClosureAttr, "for an immutable digraph",
[IsImmutableDigraph], DigraphReflexiveTransitiveClosure);

InstallMethod(DigraphTransitiveReduction, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local topo, p, C;
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no ",
                  "multiple edges,");
  elif DigraphTopologicalSort(D) = fail then
    ErrorNoReturn("not yet implemented for non-topologically sortable ",
                  "digraphs,");
  fi;
  topo := DigraphTopologicalSort(D);
  p    := Permutation(Transformation(topo), topo);

  C := DigraphMutableCopyIfImmutable(D);
  OnDigraphs(C, p ^ -1);       # changes C in-place
  DIGRAPH_TRANS_REDUCTION(C);  # changes C in-place
  ClearDigraphEdgeLabels(C);
  OnDigraphs(C, p);            # changes C in-place
  if IsImmutableDigraph(D) then
    MakeImmutable(C);
    SetDigraphTransitiveReductionAttr(D, C);
    SetIsMultiDigraph(C, false);
  fi;
  return C;
end);

InstallMethod(DigraphTransitiveReduction,
"for a digraph with known transitive reduction",
[IsDigraph and HasDigraphTransitiveReductionAttr], SUM_FLAGS,
DigraphTransitiveReductionAttr);

InstallMethod(DigraphTransitiveReductionAttr, "for an immutable digraph",
[IsImmutableDigraph], DigraphTransitiveReduction);

# For a topologically sortable digraph G, this returns the least subgraph G'
# of G such that the (reflexive) transitive closures of G and G' are equal.
InstallMethod(DigraphReflexiveTransitiveReduction, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local C;
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no ",
                  "multiple edges,");
  elif DigraphTopologicalSort(D) = fail then
    ErrorNoReturn("not yet implemented for non-topologically sortable ",
                  "digraphs,");
  elif IsNullDigraph(D) then
    return D;
  elif HasDigraphRemoveLoopsAttr(D) then
    C := DigraphMutableCopy(DigraphRemoveLoops(D));
  else
    C := DigraphRemoveLoops(DigraphMutableCopyIfImmutable(D));
  fi;
  DigraphTransitiveReduction(C);
  if IsImmutableDigraph(D) then
    MakeImmutable(C);
    SetDigraphReflexiveTransitiveReductionAttr(D, C);
    SetIsReflexiveDigraph(C, false);
    SetDigraphHasLoops(C, false);
    SetIsMultiDigraph(C, false);
  fi;
  return C;
end);

InstallMethod(DigraphReflexiveTransitiveReduction,
"for a digraph with known reflexive transitive reduction",
[IsDigraph and HasDigraphReflexiveTransitiveReductionAttr], SUM_FLAGS,
DigraphReflexiveTransitiveReductionAttr);

InstallMethod(DigraphReflexiveTransitiveReductionAttr,
"for an immutable digraph",
[IsImmutableDigraph], DigraphReflexiveTransitiveReduction);

InstallMethod(UndirectedSpanningForest, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local C;
  if DigraphNrVertices(D) = 0 then
    return fail;
  fi;
  C := MaximalSymmetricSubdigraph(D)!.OutNeighbours;
  C := DIGRAPH_SYMMETRIC_SPANNING_FOREST(C);
  if IsMutableDigraph(D) then
    D!.OutNeighbours := C;
    ClearDigraphEdgeLabels(D);
    return D;
  fi;
  C := ConvertToImmutableDigraphNC(C);
  SetUndirectedSpanningForestAttr(D, C);
  SetIsUndirectedForest(C, true);
  SetIsMultiDigraph(C, false);
  SetDigraphHasLoops(C, false);
  return C;
end);

InstallMethod(UndirectedSpanningForest,
"for a digraph with known undirected spanning forest",
[IsDigraph and HasUndirectedSpanningForestAttr], SUM_FLAGS,
UndirectedSpanningForestAttr);

InstallMethod(UndirectedSpanningForestAttr, "for an immutable digraph",
[IsImmutableDigraph], UndirectedSpanningForest);

InstallMethod(UndirectedSpanningTree, "for a mutable digraph",
[IsMutableDigraph],
function(D)
  if DigraphNrVertices(D) = 0
      or not IsStronglyConnectedDigraph(D)
      or not IsConnectedDigraph(UndirectedSpanningForest(DigraphMutableCopy(D)))
      then
    return fail;
  fi;
  return UndirectedSpanningForest(D);
end);

InstallMethod(UndirectedSpanningTree, "for an immutable digraph",
[IsImmutableDigraph], UndirectedSpanningTreeAttr);

InstallMethod(UndirectedSpanningTreeAttr, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  if DigraphNrVertices(D) = 0
      or not IsStronglyConnectedDigraph(D)
      or (HasMaximalSymmetricSubdigraphAttr(D)
          and not IsStronglyConnectedDigraph(MaximalSymmetricSubdigraph(D)))
      or (DigraphNrEdges(UndirectedSpanningForest(D))
          <> 2 * (DigraphNrVertices(D) - 1)) then
    return fail;
  fi;
  return UndirectedSpanningForest(D);
end);

InstallMethod(DigraphMycielskian, "for a digraph",
[IsDigraph],
function(D)
  local n, C, i, j;
  if not IsSymmetricDigraph(D) or IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a symmetric digraph ",
                  "with no multiple edges,");
  fi;

  # Based on the construction given at https://en.wikipedia.org/wiki/Mycielskian
  # on 2019-04-10, v_k = vertex k, u_k = vertex n + k and w = vertex 2n + 1

  n := DigraphNrVertices(D);
  C := DigraphMutableCopyIfImmutable(D);

  for i in [1 .. n + 1] do
    DigraphAddVertex(C);
  od;

  for i in [n + 1 .. 2 * n] do
    DigraphAddEdge(C, [i, 2 * n + 1]);
    DigraphAddEdge(C, [2 * n + 1, i]);
  od;

  for i in [1 .. n] do
    for j in [i .. n] do
      if IsDigraphEdge(C, i, j) then
        DigraphAddEdge(C, [i + n, j]);
        DigraphAddEdge(C, [j, i + n]);
        if i <> j then  # Stops duplicate edges being constructed if C has loops
          DigraphAddEdge(C, [i, j + n]);
          DigraphAddEdge(C, [j + n, i]);
        fi;
      fi;
    od;
  od;

  if IsImmutableDigraph(D) then
    MakeImmutable(C);
    SetDigraphMycielskianAttr(D, C);
  fi;
  return C;
end);

InstallMethod(DigraphMycielskian,
"for a digraph with known Mycielskian",
[IsDigraph and HasDigraphMycielskianAttr], SUM_FLAGS, DigraphMycielskianAttr);

InstallMethod(DigraphMycielskianAttr, "for an immutable digraph",
[IsImmutableDigraph], DigraphMycielskian);
