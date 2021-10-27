#############################################################################
##
##  prop.gi
##  Copyright (C) 2014-19                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# "multi" means it has at least one multiple edges
InstallMethod(IsMultiDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
IS_MULTI_DIGRAPH);

InstallMethod(IsChainDigraph, "for a digraph", [IsDigraph],
D -> IsDirectedTree(D) and IsSubset([0, 1], OutDegreeSet(D)));

InstallMethod(IsCycleDigraph, "for a digraph", [IsDigraph],
function(D)
  return DigraphNrVertices(D) > 0
     and DigraphNrEdges(D) = DigraphNrVertices(D)
     and IsStronglyConnectedDigraph(D);
end);

InstallMethod(IsBiconnectedDigraph, "for a digraph", [IsDigraph],
D -> IsConnectedDigraph(D) and IsEmpty(ArticulationPoints(D)));

InstallMethod(IsBridgelessDigraph, "for a digraph", [IsDigraph],
D -> IsConnectedDigraph(D) and IsEmpty(Bridges(D)));

InstallMethod(DIGRAPHS_IsMeetJoinSemilatticeDigraph, "for a homogeneous list",
[IsHomogeneousList],
function(nbs)
  local i, j, k, n, x, len;

  # The IsHomogenousList assumes the list <nbs> contains no or only empty lists
  n := Length(nbs);
  for i in [1 .. n] do
    for j in [i + 1 .. n] do
      if j in nbs[i] or i in nbs[j] then
        continue;
      fi;
      x := Intersection(nbs[i], nbs[j]);
      if IsEmpty(x) then
        return false;
      fi;
      len := Length(x);
      k := x[len];  # Check whether <k> is the meet of <i> and <j>
      if Length(nbs[k]) < len then
        return false;
      fi;
    od;
  od;
  return true;
end);

InstallMethod(IsJoinSemilatticeDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
  local topo;
  if not IsPartialOrderDigraph(D) then
    return false;
  fi;
  topo := DigraphTopologicalSort(D);
  D := DigraphMutableCopy(D);
  D := OnDigraphs(D, PermList(topo) ^ -1);
  Apply(D!.OutNeighbours, Set);
  return DIGRAPHS_IsMeetJoinSemilatticeDigraph(D!.OutNeighbours);
end);

InstallMethod(IsMeetSemilatticeDigraph, "for a digraph",
[IsDigraphByOutNeighboursRep],
function(D)
  local topo, list;
  if not IsPartialOrderDigraph(D) then
    return false;
  fi;
  topo := Reversed(DigraphTopologicalSort(D));
  D := OnDigraphs(DigraphMutableCopyIfMutable(D), PermList(topo) ^ -1);
  list := InNeighboursMutableCopy(D);
  Apply(list, Set);
  return DIGRAPHS_IsMeetJoinSemilatticeDigraph(list);
end);

InstallMethod(IsStronglyConnectedDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
D -> IS_STRONGLY_CONNECTED_DIGRAPH(OutNeighbours(D)));

InstallMethod(IsCompleteDigraph, "for a digraph",
[IsDigraph],
function(D)
  local n;
  n := DigraphNrVertices(D);
  if n = 0 then
    return true;
  elif DigraphNrEdges(D) <> (n * (n - 1)) then
    return false;
  elif DigraphHasLoops(D) then
    return false;
  fi;
  return not IsMultiDigraph(D);
end);

InstallMethod(IsCompleteBipartiteDigraph, "for a digraph",
[IsDigraph],
function(D)
  local bicomps;
  if IsMultiDigraph(D) then
    return false;
  fi;
  bicomps := DigraphBicomponents(D);
  if bicomps = fail then
    return false;
  fi;
  return DigraphNrEdges(D) = 2 * Length(bicomps[1]) * Length(bicomps[2]);
end);

InstallMethod(IsCompleteMultipartiteDigraph, "for a digraph",
[IsDigraph],
function(D)
  local n, size, seen, max;
  n := DigraphNrVertices(D);

  if IsEmptyDigraph(D) or IsMultiDigraph(D) or DigraphHasLoops(D)
      or not IsSymmetricDigraph(D) then
    return false;
  elif HasIsCompleteDigraph(D) and IsCompleteDigraph(D) then
    return n > 1;
  fi;

  size := [];
  seen := [];
  while Length(seen) < n do
    max := DigraphMaximalIndependentSet(D, [], seen);
    if max = fail then
      return false;
    fi;
    Add(size, Length(max));
    Append(seen, max);
  od;
  # <size> has at least two maximal independent sets because <D> is not empty.
  if DigraphNrEdges(D) <> Sum(size, k -> k * (n - k)) then
    return false;
  fi;
  # <size> describes the type of the multipartite-ness.
  if IsImmutableDigraph(D) then
    SetIsCompleteBipartiteDigraph(D, Length(size) = 2);
  fi;
  return true;
end);

InstallMethod(IsConnectedDigraph, "for a digraph", [IsDigraph],
function(D)
  # Check for easy answers
  if DigraphNrVertices(D) < 2 then
    return true;
  elif DigraphNrEdges(D) < DigraphNrVertices(D) - 1 then
    return false;
  fi;
  # Otherwise use DigraphConnectedComponents method
  return DigraphNrConnectedComponents(D) = 1;
end);

InstallImmediateMethod(IsAcyclicDigraph, "for a reflexive digraph",
IsReflexiveDigraph, 0,
D -> DigraphNrVertices(D) = 0);

InstallImmediateMethod(IsAcyclicDigraph, "for a strongly connected digraph",
IsStronglyConnectedDigraph, 0,
D -> DigraphNrVertices(D) <= 1 and IsEmptyDigraph(D));

InstallMethod(IsAcyclicDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
  local n;
  n := DigraphNrVertices(D);
  if n = 0 then
    return true;
  elif HasDigraphTopologicalSort(D) and
      DigraphTopologicalSort(D) = fail then
    return false;
  elif HasDigraphHasLoops(D) and DigraphHasLoops(D) then
    return false;
  elif HasDigraphStronglyConnectedComponents(D) then
    if DigraphNrStronglyConnectedComponents(D) = n then
      return not DigraphHasLoops(D);
    fi;
    return false;
  fi;
  return IS_ACYCLIC_DIGRAPH(OutNeighbours(D));
end);

# Complexity O(number of edges)
# this could probably be improved further ! JDM

InstallMethod(IsSymmetricDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
  local out, inn, new, i;

  if not IsMultiDigraph(D)
      and (DigraphNrEdges(D) - Length(DigraphLoops(D))) mod 2 = 1 then
    return false;
  elif HasAdjacencyMatrix(D) then
    TryNextMethod();
  fi;

  out := OutNeighbours(D);
  inn := InNeighbours(D);
  if not ForAll(out, IsSortedList) then
    new := EmptyPlist(Length(out));
    for i in DigraphVertices(D) do
      new[i] := AsSortedList(ShallowCopy(out[i]));
    od;
    out := new;
  fi;
  return inn = out;
end);

InstallMethod(IsSymmetricDigraph, "for a digraph with adjacency matrix",
[IsDigraph and HasAdjacencyMatrix],
function(D)
  local mat, n, i, j;
  mat := AdjacencyMatrix(D);
  n := DigraphNrVertices(D);
  for i in [1 .. n - 1] do
    for j in [i + 1 .. n] do
      if mat[i][j] <> mat[j][i] then
        return false;
      fi;
    od;
  od;
  return true;
end);

# Functional: for every vertex v there is exactly one edge with source v

InstallMethod(IsFunctionalDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
D -> ForAll(OutNeighbours(D), x -> Length(x) = 1));

InstallMethod(IsTournament, "for a digraph", [IsDigraph],
function(D)
  local n;

  if IsMultiDigraph(D) then
    return false;
  fi;

  n := DigraphNrVertices(D);

  if n = 0 then
    return true;
  elif DigraphNrEdges(D) <> n * (n - 1) / 2 then
    return false;
  elif DigraphHasLoops(D) then
    return false;
  elif n <= 2 then
    return true;
  elif HasIsAcyclicDigraph(D) and IsAcyclicDigraph(D) then
    return true;
  fi;
  return IsAntisymmetricDigraph(D);
end);

InstallMethod(IsEmptyDigraph, "for a digraph with known number of edges",
[IsDigraph and HasDigraphNrEdges],
D -> DigraphNrEdges(D) = 0);

InstallMethod(IsEmptyDigraph, "for a digraph",
[IsDigraph],
D -> ForAll(DigraphVertices(D), x -> OutDegreeOfVertex(D, x) = 0));

InstallMethod(IsReflexiveDigraph, "for a digraph with adjacency matrix",
[IsDigraph and HasAdjacencyMatrix],
function(D)
  local mat, i;
  mat := AdjacencyMatrix(D);
  for i in DigraphVertices(D) do
    if mat[i][i] = 0 then
      return false;
    fi;
  od;
  return true;
end);

InstallMethod(IsReflexiveDigraph, "for a digraph", [IsDigraph],
D -> ForAll(DigraphVertices(D), x -> IsDigraphEdge(D, x, x)));

InstallImmediateMethod(DigraphHasLoops, "for a reflexive digraph",
IsReflexiveDigraph, 0,
D -> DigraphNrVertices(D) > 0);

InstallMethod(DigraphHasLoops, "for a digraph with adjacency matrix",
[IsDigraph and HasAdjacencyMatrix],
function(D)
  local mat;
  mat := AdjacencyMatrix(D);
  return ForAny(DigraphVertices(D), i -> mat[i][i] <> 0);
end);

InstallMethod(DigraphHasLoops, "for a digraph", [IsDigraph],
D -> ForAny(DigraphVertices(D), x -> IsDigraphEdge(D, x, x)));

InstallMethod(IsAperiodicDigraph, "for a digraph", [IsDigraph],
D -> DigraphPeriod(D) = 1);

InstallMethod(IsAntisymmetricDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
D -> IS_ANTISYMMETRIC_DIGRAPH(OutNeighbours(D)));

InstallMethod(IsTransitiveDigraph, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
  local n, m, sorted, verts, out, trans, reflex, v, u;

  n := DigraphNrVertices(D);
  m := DigraphNrEdges(D);

  # Try correct method vis-a-vis complexity
  if m + n + (m * n) < (n * n * n) then
    sorted := DigraphTopologicalSort(D);
    if sorted <> fail then
      # Essentially create the transitive closure vertex by vertex.
      # And after doing this for each vertex, check we've added nothing
      verts := DigraphVertices(D);
      out   := OutNeighbours(D);
      trans := EmptyPlist(n);
      for v in sorted do
        trans[v] := BlistList(verts, [v]);
        reflex   := false;
        for u in out[v] do
          trans[v] := UnionBlist(trans[v], trans[u]);
          if u = v then
            reflex := true;
          fi;
        od;
        if not reflex then
          trans[v][v] := false;
        fi;
        # Set() is a temporary stop-gap, to allow multi-digraphs
        # and to not have to worry about the ordering of these lists yet
        if Set(out[v]) <> Set(ListBlist(verts, trans[v])) then
          return false;
        fi;
        trans[v][v] := true;
      od;
      return true;
    fi;
  fi;
  # Otherwise fall back to the Floyd Warshall version
  return IS_TRANSITIVE_DIGRAPH(D);
end);

InstallMethod(IsBipartiteDigraph, "for a digraph", [IsDigraph],
function(D)
  if HasDigraphHasLoops(D) and DigraphHasLoops(D) then
    return false;
  fi;
  return DIGRAPHS_Bipartite(D)[1];
end);

InstallMethod(IsInRegularDigraph, "for a digraph", [IsDigraph],
D -> Length(InDegreeSet(D)) = 1);

InstallMethod(IsOutRegularDigraph, "for a digraph", [IsDigraph],
D -> Length(OutDegreeSet(D)) = 1);

InstallMethod(IsRegularDigraph, "for a digraph", [IsDigraph],
D -> IsInRegularDigraph(D) and IsOutRegularDigraph(D));

InstallMethod(IsUndirectedTree, "for a digraph", [IsDigraph],
D -> DigraphNrEdges(D) = 2 * (DigraphNrVertices(D) - 1)
     and IsSymmetricDigraph(D) and IsConnectedDigraph(D));

InstallMethod(IsUndirectedForest, "for a digraph", [IsDigraph],
function(D)
  if not IsSymmetricDigraph(D) or DigraphNrVertices(D) = 0
      or IsMultiDigraph(D) then
    return false;
  fi;
  return ForAll(DigraphConnectedComponents(D).comps,
                c -> Sum(c, i -> OutDegreeOfVertex(D, i)) = 2 * Length(c) - 2);
end);

InstallMethod(IsDistanceRegularDigraph, "for a digraph", [IsDigraph],
function(D)
  local reps, record, localParameters, localDiameter, i;
  if IsEmptyDigraph(D) then
    return true;
  elif not IsSymmetricDigraph(D) or not IsConnectedDigraph(D) then
    return false;
  fi;

  reps            := DigraphOrbitReps(D);
  record          := DIGRAPH_ConnectivityDataForVertex(D, reps[1]);
  localParameters := record.localParameters;
  localDiameter   := record.localDiameter;

  for i in [2 .. Length(reps)] do
    record := DIGRAPH_ConnectivityDataForVertex(D, reps[2]);
    if record.localDiameter <> localDiameter
        or record.localParameters <> localParameters then
      return false;
    fi;
  od;
  return true;
end);

InstallMethod(IsDirectedTree, "for a digraph", [IsDigraph],
function(D)
  if IsNullDigraph(D) then
    return DigraphNrVertices(D) = 1;
  fi;
  return IsConnectedDigraph(D) and InDegreeSet(D) = [0, 1];
end);

InstallMethod(IsEulerianDigraph, "for a digraph", [IsDigraph],
function(D)
  local i;
  if not IsStronglyConnectedDigraph(D) then
     return false;
  fi;
  for i in DigraphVertices(D) do
    if not OutDegreeOfVertex(D, i) = InDegreeOfVertex(D, i) then
      return false;
    fi;
  od;
  return true;
end);

# Meyniel's Theorem: a strongly connected digraph with n vertices, in which
# any two non-adjacent vertices have full degree sum at least 2n − 1, is
# Hamiltonian.
# This function uses theorems 4.1 and 4.2 from the following paper:
# Sufficient conditions for a digraph to be Hamiltonian
# https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.99.4560&rep=rep1
# &type=pdf
# A vertex z dominates a pair of vertices {x, y} if z->x and z->y
# A pair of vertices {x, y} dominates a vertex z if x->z and y->z
# Theorem 4.1: a strongly connected digraph with n vertices in which every pair
# of non-adjacent dominated vertices {x,y} satifies either of:
# 1.(full degree of x) ≥ n and (full degree of y) ≥ n - 1
# 2.(full degree of y) ≥ n and (full degree of x) ≥ n - 1
# Is Hamiltonian.
# Theorem 4.2: a strongly connected digraph with n vertices in which every pair
# of non-adjacent vertices {x,y} which is dominated or dominating satifies:
# 1. (out degree of x) + (in degree of y) ≥ n
# 2. (out degree of y) + (in degree of x) ≥ n
# Is Hamiltonian.
InstallMethod(IsHamiltonianDigraph, "for a digraph", [IsDigraph],
function(D)
  local indegs, fulldegs, outdegs, n, checkMT, check41, check42,
        dominatedcheck, dominatingcheck, adjmatrix, i, j, k, tempblist;
  if DigraphNrVertices(D) <= 1 and IsEmptyDigraph(D) then
    return true;
  elif not IsStronglyConnectedDigraph(D) then
    return false;
  fi;

  D := DigraphMutableCopyIfMutable(D);

  if IsMultiDigraph(D) then
    D := DigraphRemoveAllMultipleEdges(D);
  fi;
  if DigraphHasLoops(D) then
    D := DigraphRemoveLoops(D);
  fi;

  n := DigraphNrVertices(D);

  if n <= 512 then
    indegs := InDegrees(D);
    outdegs := OutDegrees(D);
    fulldegs := indegs + outdegs;
    adjmatrix := BooleanAdjacencyMatrixMutableCopy(D);
    # checks if Meyniel's theorem, Theorem 4.1 or Theorem 4.2 are applicable.
    checkMT := true;
    check41 := true;
    check42 := true;
    for i in [1 .. n] do
       for j in [1 .. n] do
          if i <> j and not adjmatrix[j][i] and not adjmatrix[i][j] then
              # Meyniel's theorem
              if checkMT and fulldegs[i] + fulldegs[j] < 2 * n - 1 then
                  checkMT := false;
              fi;

              if check41 or check42 then
                dominatedcheck := false;
                dominatingcheck := false;
                for k in [1 .. n] do
                  if adjmatrix[k][i] and adjmatrix[k][j] then
                     dominatedcheck := true;
                     break;
                  fi;
                od;
                tempblist := adjmatrix[i];
                IntersectBlist(tempblist, adjmatrix[j]);
                dominatingcheck := true in tempblist;
              fi;

              # Theorem 4.1
              if check41 and dominatedcheck then
                 if fulldegs[i] < n - 1 or fulldegs[j] < n - 1 or
                    (fulldegs[i] = n - 1 and fulldegs[j] = n - 1) then
                   check41 := false;
                 fi;
              fi;

              # Theorem 4.2
              if check42 and (dominatingcheck or dominatedcheck) then
                 if (indegs[i] + outdegs[j]) < n or
                    (indegs[j] + outdegs[i]) < n then
                   check42 := false;
                 fi;
              fi;
          fi;
          if not (checkMT or check41 or check42) then
            break;
          fi;
      od;
      if not (checkMT or check41 or check42) then
        break;
      fi;
    od;
    if checkMT or check41 or check42 then
      return true;
    fi;
  fi;
  return HamiltonianPath(D) <> fail;
end);

InstallMethod(IsHamiltonianDigraph, "for a digraph with hamiltonian path",
[IsDigraph and HasHamiltonianPath], x -> HamiltonianPath(x) <> fail);

InstallMethod(IsDigraphCore, "for a digraph",
[IsDigraph],
function(D)
  local hook, proper_endo_found, N;

  N := DigraphNrVertices(D);
  if (DigraphHasLoops(D) or IsEmptyDigraph(D)) and N > 1 then
    return false;
  elif IsCompleteDigraph(D) then
    return true;
  elif IsBipartiteDigraph(D) and IsSymmetricDigraph(D) and N > 2 then
    return false;
  fi;
  # The core of a digraph with loops is a vertex with a loop, of an empty
  # digraph is a vertex, and of a non-empty, symmetric bipartite digraph is the
  # complete digraph on 2 vertices.

  proper_endo_found := false;
  hook := function(unneded_argument, T)
    # the hook is required by HomomorphismDigraphsFinder to have two arguments,
    # the 1st of which is user_param, which this method doesn't need.
    if RankOfTransformation(T, [1 .. N]) < N then
      proper_endo_found := true;
      return true;
    fi;
    return false;
  end;

  HomomorphismDigraphsFinder(D,                         # D1
                             D,                         # D2
                             hook,                      # hook
                             fail,                      # user_param
                             infinity,                  # max results
                             fail,                      # hint
                             false,                     # injective
                             DigraphVertices(D),        # image
                             [],                        # partial_map
                             fail,                      # colors1
                             fail);                     # colors2
  return not proper_endo_found;
end);

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
