#############################################################################
##
##  prop.gi
##  Copyright (C) 2014-17                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# "multi" means it has at least one multiple edges
InstallMethod(IsMultiDigraph, "for a dense digraph", [IsDenseDigraphRep],
IS_MULTI_DIGRAPH);

InstallMethod(IsChainDigraph, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return IsDirectedTree(D) and IsSubset([0, 1], OutDegreeSet(D));
end);

InstallMethod(IsCycleDigraph, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return DigraphNrVertices(D) > 0 and IsStronglyConnectedDigraph(D)
         and DigraphNrEdges(D) = DigraphNrVertices(D);
end);

InstallMethod(IsBiconnectedDigraph, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return IsEmpty(ArticulationPoints(D)) and IsConnectedDigraph(D);
end);

InstallMethod(DIGRAPHS_IsMeetJoinSemilatticeDigraph,
"for a homogeneous list and a positive integer",
[IsHomogeneousList],
function(nbs)
  local i, j, k, n, x, len;

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

InstallMethod(IsJoinSemilatticeDigraph, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local topo, list;
  IsValidDigraph(D);
  if not IsPartialOrderDigraph(D) then
    return false;
  fi;
  topo := DigraphTopologicalSort(D);
  D := DigraphMutableCopy(D);
  D := OnDigraphs(D, PermList(topo) ^ -1);
  list := D!.OutNeighbours;
  Apply(list, Set);
  return DIGRAPHS_IsMeetJoinSemilatticeDigraph(list);
end);

InstallMethod(IsMeetSemilatticeDigraph, "for a digraph",
[IsDigraph],
function(D)
  local topo, list;
  IsValidDigraph(D);
  if not IsPartialOrderDigraph(D) then
    return false;
  fi;
  topo := Reversed(DigraphTopologicalSort(D));
  D := OnDigraphs(DigraphCopyIfMutable(D), PermList(topo) ^ -1);
  list := InNeighboursMutableCopy(D);
  Apply(list, Set);
  return DIGRAPHS_IsMeetJoinSemilatticeDigraph(list);
end);

InstallMethod(IsStronglyConnectedDigraph, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  IsValidDigraph(D);
  return IS_STRONGLY_CONNECTED_DIGRAPH(OutNeighbours(D));
end);

InstallMethod(IsCompleteDigraph, "for a digraph",
[IsDigraph],
function(D)
  local n;
  IsValidDigraph(D);
  n := DigraphNrVertices(D);
  if n = 0 then
    return true;
  elif IsMultiDigraph(D) then
    return false;
  elif DigraphNrEdges(D) <> (n * (n - 1)) then
    return false;
  fi;
  return not DigraphHasLoops(D);
end);

InstallMethod(IsCompleteBipartiteDigraph, "for a digraph",
[IsDigraph],
function(D)
  local bicomps;
  IsValidDigraph(D);

  if IsMultiDigraph(D) then
    return false;
  fi;

  bicomps := DigraphBicomponents(D);
  if bicomps = fail then
    return false;
  fi;

  return DigraphNrEdges(D) = 2 * Length(bicomps[1]) * Length(bicomps[2]);
end);

InstallMethod(IsConnectedDigraph, "for a digraph", [IsDigraph],
function(D)
  # Check for easy answers
  IsValidDigraph(D);
  if DigraphNrVertices(D) < 2 then
    return true;
  elif HasIsStronglyConnectedDigraph(D)
      and IsStronglyConnectedDigraph(D) then
    return true;
  elif DigraphNrEdges(D) < DigraphNrVertices(D) - 1 then
    return false;
  fi;
  # Otherwise use DigraphConnectedComponents method
  return (Length(DigraphConnectedComponents(D).comps) = 1);
end);

InstallImmediateMethod(IsAcyclicDigraph, "for a reflexive digraph",
IsReflexiveDigraph, 0,
function(D)
  if DigraphNrVertices(D) = 0 then
    return true;
  fi;
  return false;
end);

InstallImmediateMethod(IsAcyclicDigraph, "for a strongly connected digraph",
IsStronglyConnectedDigraph, 0,
function(D)
  IsValidDigraph(D);
  if DigraphNrVertices(D) > 1 then
    return false;
  fi;
  return true;
end);

InstallMethod(IsAcyclicDigraph, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local n, scc;
  IsValidDigraph(D);
  n := DigraphNrVertices(D);
  if n = 0 then
    return true;
  elif HasDigraphTopologicalSort(D) and
      DigraphTopologicalSort(D) = fail then
    return false;
  elif HasDigraphHasLoops(D) and DigraphHasLoops(D) then
    return false;
  elif HasDigraphStronglyConnectedComponents(D) then
    scc := DigraphStronglyConnectedComponents(D);
    if not Length(scc.comps) = n then
      SetIsStronglyConnectedDigraph(D, false);
      return false;
    else
      SetIsStronglyConnectedDigraph(D, false);
      return not DigraphHasLoops(D);
    fi;
  fi;
  return IS_ACYCLIC_DIGRAPH(OutNeighbours(D));
end);

# Complexity O(number of edges)
# this could probably be improved further ! JDM

InstallMethod(IsSymmetricDigraph, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local out, inn, new, i;
  IsValidDigraph(D);

  out := OutNeighbours(D);
  inn := InNeighbours(D);

  if not ForAll(out, IsSortedList) then
    new := EmptyPlist(Length(out));
    for i in DigraphVertices(D) do
      new[i] := AsSortedList(ShallowCopy(out[i]));
    od;
    return inn = new;
  fi;

  return inn = out;
end);

# Functional: for every vertex v there is exactly one edge with source v

InstallMethod(IsFunctionalDigraph, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  IsValidDigraph(D);
  return ForAll(OutNeighbours(D), x -> Length(x) = 1);
end);

InstallMethod(IsTournament, "for a digraph", [IsDigraph],
function(D)
  local n;
  IsValidDigraph(D);

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
2,  # to beat the method for IsDenseDigraphRep
function(D)
  IsValidDigraph(D);
  return DigraphNrEdges(D) = 0;
end);

InstallMethod(IsEmptyDigraph, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  IsValidDigraph(D);
  return ForAll(OutNeighbours(D), IsEmpty);
end);

InstallMethod(IsReflexiveDigraph, "for a digraph with adjacency matrix",
[IsDigraph and HasAdjacencyMatrix],
2,  # to beat the method for IsDenseDigraphRep
function(D)
  local mat, i;
  IsValidDigraph(D);
  mat := AdjacencyMatrix(D);
  for i in DigraphVertices(D) do
    if mat[i][i] = 0 then
      return false;
    fi;
  od;
  return true;
end);

InstallMethod(IsReflexiveDigraph, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local list;
  IsValidDigraph(D);
  list := OutNeighbours(D);
  return ForAll(DigraphVertices(D), x -> x in list[x]);
end);

InstallImmediateMethod(DigraphHasLoops, "for a reflexive digraph",
IsReflexiveDigraph, 0,
function(D)
  if DigraphNrVertices(D) = 0 then
    return false;
  fi;
  return true;
end);

InstallMethod(DigraphHasLoops, "for a digraph with adjacency matrix",
[IsDigraph and HasAdjacencyMatrix],
2,  # to beat the method for IsDenseDigraphRep
function(D)
  local mat, i;
  IsValidDigraph(D);
  mat := AdjacencyMatrix(D);
  for i in DigraphVertices(D) do
    if mat[i][i] <> 0 then
      return true;
    fi;
  od;
  return false;
end);

InstallMethod(DigraphHasLoops, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local list, i;
  IsValidDigraph(D);
  list := OutNeighbours(D);
  for i in DigraphVertices(D) do
    if i in list[i] then
      return true;
    fi;
  od;
  return false;
end);

InstallMethod(IsAperiodicDigraph, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return DigraphPeriod(D) = 1;
end);

InstallMethod(IsAntisymmetricDigraph, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  IsValidDigraph(D);
  return IS_ANTISYMMETRIC_DIGRAPH(OutNeighbours(D));
end);

InstallMethod(IsTransitiveDigraph, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local n, m, sorted, verts, out, trans, reflex, v, u;
  IsValidDigraph(D);

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
  IsValidDigraph(D);
  if HasDigraphHasLoops(D) and DigraphHasLoops(D) then
    return false;
  fi;
  return DIGRAPHS_Bipartite(D)[1];
end);

InstallMethod(IsInRegularDigraph, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return Length(InDegreeSet(D)) = 1;
end);

InstallMethod(IsOutRegularDigraph, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return Length(OutDegreeSet(D)) = 1;
end);

InstallMethod(IsRegularDigraph, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return IsInRegularDigraph(D) and IsOutRegularDigraph(D);
end);

InstallMethod(IsUndirectedTree, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return DigraphNrEdges(D) = 2 * (DigraphNrVertices(D) - 1)
           and IsSymmetricDigraph(D) and IsConnectedDigraph(D);
end);

InstallMethod(IsUndirectedForest, "for a digraph", [IsDigraph],
function(D)
  local comps, comp;
  IsValidDigraph(D);
  if not IsSymmetricDigraph(D) or DigraphNrVertices(D) = 0
      or IsMultiDigraph(D) then
    return false;
  fi;
  comps := DigraphConnectedComponents(D).comps;
  for comp in comps do
    comp := InducedSubdigraph(D, comp);
    if DigraphNrEdges(comp) <> 2 * (DigraphNrVertices(comp) - 1) then
      return false;
    fi;
  od;
  return true;
end);

InstallMethod(IsDistanceRegularDigraph, "for a digraph", [IsDigraph],
function(D)
  local reps, record, localParameters, localDiameter, i;
  IsValidDigraph(D);
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
  IsValidDigraph(D);
  if IsNullDigraph(D) then
    return DigraphNrVertices(D) = 1;
  else
    return IsConnectedDigraph(D) and InDegreeSet(D) = [0, 1];
  fi;
end);

InstallMethod(IsEulerianDigraph, "for a digraph", [IsDigraph],
function(D)
  local i;
  IsValidDigraph(D);
  if not IsStronglyConnectedDigraph(ReducedDigraph(D)) then
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
# http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.99.4560&rep=rep1
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
  IsValidDigraph(D);
  if DigraphNrVertices(D) <= 1 and IsEmptyDigraph(D) then
    return true;
  elif not IsStronglyConnectedDigraph(D) then
    return false;
  fi;

  D := DigraphCopyIfMutable(D);

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
    adjmatrix := BooleanAdjacencyMatrix(D);
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
