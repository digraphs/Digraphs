#############################################################################
##
##  prop.gi
##  Copyright (C) 2014-17                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallMethod(IsChainDigraph, "for a digraph", [IsDigraph],
function(digraph)
  return IsDirectedTree(digraph) and IsSubset([0, 1], OutDegreeSet(digraph));
end);

InstallMethod(IsCycleDigraph, "for a digraph", [IsDigraph],
function(digraph)
  return DigraphNrVertices(digraph) > 0 and IsStronglyConnectedDigraph(digraph)
         and DigraphNrEdges(digraph) = DigraphNrVertices(digraph);
end);

InstallMethod(IsBiconnectedDigraph, "for a digraph", [IsDigraph],
function(digraph)
  return IsEmpty(ArticulationPoints(digraph))
         and IsConnectedDigraph(digraph);
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

InstallMethod(IsJoinSemilatticeDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  local topo, gr, nbs;

  if not IsPartialOrderDigraph(digraph) then
    return false;
  fi;

  topo := DigraphTopologicalSort(digraph);
  gr := OnDigraphs(digraph, PermList(topo) ^ -1);
  nbs := OutNeighboursMutableCopy(gr);
  Apply(nbs, Set);

  return DIGRAPHS_IsMeetJoinSemilatticeDigraph(nbs);
end);

InstallMethod(IsMeetSemilatticeDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  local topo, gr, nbs;

  if not IsPartialOrderDigraph(digraph) then
    return false;
  fi;

  topo := Reversed(DigraphTopologicalSort(digraph));
  gr := OnDigraphs(digraph, PermList(topo) ^ -1);
  nbs := InNeighboursMutableCopy(gr);
  Apply(nbs, Set);

  return DIGRAPHS_IsMeetJoinSemilatticeDigraph(nbs);
end);

# InstallImmediateMethod(IsStronglyConnectedDigraph, "for an acyclic digraph",
# IsAcyclicDigraph,
# function(digraph)
#   if DigraphNrVertices(digraph) > 1 then
#     return false;
#   fi;
# end);

InstallMethod(IsStronglyConnectedDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  return IS_STRONGLY_CONNECTED_DIGRAPH(OutNeighbours(digraph));
end);

#

InstallMethod(IsCompleteDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  local n;

  n := DigraphNrVertices(digraph);
  if n = 0 then
    return true;
  elif IsMultiDigraph(digraph) then
    return false;
  elif DigraphNrEdges(digraph) <> (n * (n - 1)) then
    return false;
  fi;
  return not DigraphHasLoops(digraph);
end);

#

InstallMethod(IsCompleteBipartiteDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  local bicomps;

  if IsMultiDigraph(digraph) then
    return false;
  fi;

  bicomps := DigraphBicomponents(digraph);
  if bicomps = fail then
    return false;
  fi;

  return DigraphNrEdges(digraph) = 2 * Length(bicomps[1]) * Length(bicomps[2]);
end);

#

InstallMethod(IsConnectedDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  # Check for easy answers
  if DigraphNrVertices(digraph) < 2 then
    return true;
  elif HasIsStronglyConnectedDigraph(digraph)
      and IsStronglyConnectedDigraph(digraph) then
    return true;
  elif DigraphNrEdges(digraph) < DigraphNrVertices(digraph) - 1 then
    return false;
  fi;
  # Otherwise use DigraphConnectedComponents method
  return (Length(DigraphConnectedComponents(digraph).comps) = 1);
end);

#

InstallImmediateMethod(IsAcyclicDigraph, "for a reflexive digraph",
IsReflexiveDigraph, 0,
function(digraph)
  if DigraphNrVertices(digraph) = 0 then
    return true;
  fi;
  return false;
end);

InstallImmediateMethod(IsAcyclicDigraph, "for a strongly connected digraph",
IsStronglyConnectedDigraph, 0,
function(digraph)
  if DigraphNrVertices(digraph) > 1 then
    return false;
  fi;
  return true;
end);

#

InstallMethod(IsAcyclicDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  local n, scc;

  n := DigraphNrVertices(digraph);

  if n = 0 then
    return true;
  elif HasDigraphTopologicalSort(digraph) and
      DigraphTopologicalSort(digraph) = fail then
    return false;
  elif HasDigraphHasLoops(digraph) and DigraphHasLoops(digraph) then
    return false;
  elif HasDigraphStronglyConnectedComponents(digraph) then
    scc := DigraphStronglyConnectedComponents(digraph);
    if not Length(scc.comps) = n then
      SetIsStronglyConnectedDigraph(digraph, false);
      return false;
    else
      SetIsStronglyConnectedDigraph(digraph, false);
      return not DigraphHasLoops(digraph);
    fi;
  fi;
  return IS_ACYCLIC_DIGRAPH(OutNeighbours(digraph));
  end);

# Complexity O(number of edges)
# this could probably be improved further ! JDM

InstallMethod(IsSymmetricDigraph, "for a digraph",
[IsDigraph],
function(graph)
  local out, inn, new, i;

  out := OutNeighbours(graph);
  inn := InNeighbours(graph);

  if not ForAll(out, IsSortedList) then
    new := EmptyPlist(Length(out));
    for i in DigraphVertices(graph) do
      new[i] := AsSortedList(ShallowCopy(out[i]));
    od;
    return inn = new;
  fi;

  return inn = out;
end);

# Functional: for every vertex v there is exactly one edge with source v

InstallMethod(IsFunctionalDigraph, "for a digraph",
[IsDigraph],
function(graph)
  return ForAll(OutNeighbours(graph), x -> Length(x) = 1);
end);

#

InstallMethod(IsTournament, "for a digraph",
[IsDigraph],
function(digraph)
  local n;

  if IsMultiDigraph(digraph) then
    return false;
  fi;

  n := DigraphNrVertices(digraph);

  if n = 0 then
    return true;
  fi;

  if DigraphNrEdges(digraph) <> n * (n - 1) / 2 then
    return false;
  fi;

  if DigraphHasLoops(digraph) then
    return false;
  fi;

  if n <= 2 then
    return true;
  fi;

  if HasIsAcyclicDigraph(digraph) and IsAcyclicDigraph(digraph) then
    return true;
  fi;

  return IsAntisymmetricDigraph(digraph);
end);

#

InstallMethod(IsEmptyDigraph, "for a digraph with known number of edges",
[IsDigraph and HasDigraphNrEdges],
function(digraph)
  return DigraphNrEdges(digraph) = 0;
end);

InstallMethod(IsEmptyDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  local adj, e;

  adj := OutNeighbours(digraph);
  for e in adj do
    if not IsEmpty(e) then
      return false;
    fi;
  od;
  return true;
end);

# InstallImmediateMethod(IsReflexiveDigraph,
# "for a digraph with HasDigraphHasLoops",
# HasDigraphHasLoops,
# function(digraph)
#   if DigraphNrVertices(digraph) = 0 then
#     return true;
#   elif not DigraphHasLoops(digraph) then
#     return false;
#   fi;
# end);

InstallMethod(IsReflexiveDigraph, "for a digraph with adjacency matrix",
[IsDigraph and HasAdjacencyMatrix],
function(digraph)
  local verts, mat, i;

  verts := DigraphVertices(digraph);
  mat := AdjacencyMatrix(digraph);

  for i in verts do
    if mat[i][i] = 0 then
      return false;
    fi;
  od;
  return true;
end);

InstallMethod(IsReflexiveDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  local adj;

  adj := OutNeighbours(digraph);
  return ForAll(DigraphVertices(digraph), x -> x in adj[x]);
end);

#

InstallImmediateMethod(DigraphHasLoops, "for a reflexive digraph",
IsReflexiveDigraph, 0,
function(digraph)
  if DigraphNrVertices(digraph) = 0 then
    return false;
  fi;
  return true;
end);

InstallMethod(DigraphHasLoops, "for a digraph with adjacency matrix",
[IsDigraph and HasAdjacencyMatrix],
function(digraph)
  local mat, i;

  mat := AdjacencyMatrix(digraph);
  for i in DigraphVertices(digraph) do
    if mat[i][i] <> 0 then
      return true;
    fi;
  od;
  return false;
end);

InstallMethod(DigraphHasLoops, "for a digraph",
[IsDigraph],
function(digraph)
  local on, i;
  on := OutNeighbours(digraph);
  for i in DigraphVertices(digraph) do
    if i in on[i] then
      return true;
    fi;
  od;
  return false;
end);

#

InstallMethod(IsAperiodicDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  return DigraphPeriod(digraph) = 1;
end);

#

InstallMethod(IsAntisymmetricDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  # TODO check if the digraph has multiple edges, if not, then
  # this can return false if it has too many edges.
  return IS_ANTISYMMETRIC_DIGRAPH(OutNeighbours(digraph));
end);

#

InstallMethod(IsTransitiveDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  local n, m, sorted, verts, out, trans, reflex, v, u;

  n := DigraphNrVertices(digraph);
  m := DigraphNrEdges(digraph);

  # Try correct method vis-a-vis complexity
  if m + n + (m * n) < (n * n * n) then
    sorted := DigraphTopologicalSort(digraph);
    if sorted <> fail then
      # Essentially create the transitive closure vertex by vertex.
      # And after doing this for each vertex, check we've added nothing
      verts := DigraphVertices(digraph);
      out   := OutNeighbours(digraph);
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
  return IS_TRANSITIVE_DIGRAPH(digraph);
end);

#

InstallMethod(IsBipartiteDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  if HasDigraphHasLoops(digraph) and DigraphHasLoops(digraph) then
    return false;
  fi;
  return DIGRAPHS_Bipartite(digraph)[1];
end);

#

InstallMethod(IsInRegularDigraph, "for a digraph", [IsDigraph],
function(digraph)
  return Length(InDegreeSet(digraph)) = 1;
end);

#

InstallMethod(IsOutRegularDigraph, "for a digraph", [IsDigraph],
function(digraph)
  return Length(OutDegreeSet(digraph)) = 1;
end);

#

InstallMethod(IsRegularDigraph, "for a digraph", [IsDigraph],
function(digraph)
  return IsInRegularDigraph(digraph) and IsOutRegularDigraph(digraph);
end);

#

InstallMethod(IsUndirectedTree, "for a digraph", [IsDigraph],
function(gr)
  return DigraphNrEdges(gr) = 2 * (DigraphNrVertices(gr) - 1)
           and IsSymmetricDigraph(gr) and IsConnectedDigraph(gr);
end);

InstallMethod(IsUndirectedForest, "for a digraph", [IsDigraph],
function(gr)
  local comps, comp;

  if not IsSymmetricDigraph(gr) or DigraphNrVertices(gr) = 0
      or IsMultiDigraph(gr) then
    return false;
  fi;
  comps := DigraphConnectedComponents(gr).comps;
  for comp in comps do
    comp := InducedSubdigraph(gr, comp);
    if DigraphNrEdges(comp) <> 2 * (DigraphNrVertices(comp) - 1) then
      return false;
    fi;
  od;
  return true;
end);

#

InstallMethod(IsDistanceRegularDigraph, "for a symmetric digraph",
[IsDigraph],
function(graph)
  local reps, record, localParameters, localDiameter, i;

  if IsEmptyDigraph(graph) then
    return true;
  elif not IsSymmetricDigraph(graph) or not IsConnectedDigraph(graph) then
    return false;
  fi;

  reps            := DigraphOrbitReps(graph);
  record          := DIGRAPH_ConnectivityDataForVertex(graph, reps[1]);
  localParameters := record.localParameters;
  localDiameter   := record.localDiameter;

  for i in [2 .. Length(reps)] do
     record := DIGRAPH_ConnectivityDataForVertex(graph, reps[2]);
     if record.localDiameter <> localDiameter then
        return false;
     fi;

     if record.localParameters <> localParameters then
        return false;
     fi;
  od;

  return true;
end);

#

InstallMethod(IsDirectedTree, "for a digraph",
[IsDigraph],
function(g)
  local incount, zerocount, out, i, j, k;
  zerocount := 0;
  out := OutNeighbours(g);
  incount := ListWithIdenticalEntries(Length(out), 0);
  for i in [1 .. Length(out)] do
    for j in [1 .. Length(out[i])] do
      incount[out[i][j]] := incount[out[i][j]] + 1;
      if out[i][j] = i then
        return false;
      fi;
    od;
  od;
  for k in [1 .. Length(out)] do
    if incount[k] > 1 then
      return false;
    elif incount[k] = 0 then
      zerocount := zerocount + 1;
    fi;
  od;
  if not zerocount = 1 then
    return false;
  fi;

  return true;
end);

#

InstallMethod(IsEulerianDigraph, "for a digraph",
[IsDigraph],
function(gr)
  local i;

  if not IsStronglyConnectedDigraph(ReducedDigraph(gr)) then
     return false;
  fi;

  for i in DigraphVertices(gr) do
    if not OutDegreeOfVertex(gr, i) = InDegreeOfVertex(gr, i) then
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
InstallMethod(IsHamiltonianDigraph, "for a digraph",
[IsDigraph],
function(gr)
  local indegs, fulldegs, outdegs, n, checkMT, check41, check42,
        dominatedcheck, dominatingcheck, adjmatrix, i, j, k, tempblist;

  if DigraphNrVertices(gr) <= 1 and IsEmptyDigraph(gr) then
    return true;
  elif not IsStronglyConnectedDigraph(gr) then
    return false;
  fi;

  if IsMultiDigraph(gr) then
    gr := DigraphRemoveAllMultipleEdges(gr);
  fi;
  if DigraphHasLoops(gr) then
    gr := DigraphRemoveLoops(gr);
  fi;

  n := DigraphNrVertices(gr);

  if n <= 512 then
    indegs := InDegrees(gr);
    outdegs := OutDegrees(gr);
    fulldegs := indegs + outdegs;
    adjmatrix := BooleanAdjacencyMatrix(gr);
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

  return HamiltonianPath(gr) <> fail;
end);

InstallMethod(IsHamiltonianDigraph, "for a digraph with hamiltonian path",
[IsDigraph and HasHamiltonianPath],
x -> HamiltonianPath(x) <> fail);
