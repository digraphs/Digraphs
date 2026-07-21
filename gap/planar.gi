#############################################################################
##
##  planar.gi
##  Copyright (C) 2018-19                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# The methods in this file utilise the kernel module functions that wrap
# Boyer's reference implementation (in C) of the planarity and subgraph
# homeomorphism algorithms from:
#
# John M. Boyer and Wendy J. Myrvold, On the Cutting Edge: Simplified O(n)
# Planarity by Edge Addition. Journal of Graph Algorithms and Applications,
# Vol. 8, No. 3, pp. 241-273, 2004.

########################################################################
#
# This file is organised as follows:
#
# 1. Attributes
#
# 2. Properties
#
########################################################################

########################################################################
# 1. Attributes
########################################################################

BindGlobal("DIGRAPHS_HasTrivialRotationSystem",
function(D)
  if IsMultiDigraph(D) then
    ErrorNoReturn("expected a digraph with no multiple edges");
  elif HasIsPlanarDigraph(D) and not IsPlanarDigraph(D) then
    return false;
  elif DigraphNrVertices(D) < 3 then
    return true;
  fi;
  return DigraphNrAdjacenciesWithoutLoops(D) = 0;
end);

InstallMethod(PlanarEmbedding, "for a digraph", [IsDigraph],
function(D)
  if DIGRAPHS_HasTrivialRotationSystem(D) then;
    return OutNeighbors(D);
  fi;
  return PLANAR_EMBEDDING(D);
end);

InstallMethod(OuterPlanarEmbedding, "for a digraph", [IsDigraph],
function(D)
  if DIGRAPHS_HasTrivialRotationSystem(D) then;
    return OutNeighbors(D);
  fi;
  return OUTER_PLANAR_EMBEDDING(D);
end);

InstallMethod(KuratowskiPlanarSubdigraph, "for a digraph", [IsDigraph],
KURATOWSKI_PLANAR_SUBGRAPH);

InstallMethod(KuratowskiOuterPlanarSubdigraph, "for a digraph", [IsDigraph],
KURATOWSKI_OUTER_PLANAR_SUBGRAPH);

InstallMethod(SubdigraphHomeomorphicToK23, "for a digraph", [IsDigraph],
SUBGRAPH_HOMEOMORPHIC_TO_K23);

InstallMethod(SubdigraphHomeomorphicToK4, "for a digraph", [IsDigraph],
SUBGRAPH_HOMEOMORPHIC_TO_K4);

InstallMethod(SubdigraphHomeomorphicToK33, "for a digraph", [IsDigraph],
SUBGRAPH_HOMEOMORPHIC_TO_K33);

InstallMethod(DualPlanarGraph, "for a digraph", [IsDigraph],
function(D)
  local digraph, rotationSystem, facialWalks, dualEdges,
        cycle1, cycle2, commonNodes, i;

    if not IsPlanarDigraph(D) then
        return fail;
    fi;

    digraph := DigraphSymmetricClosure(DigraphRemoveLoops(
        DigraphRemoveAllMultipleEdges(DigraphMutableCopyIfMutable(D))));
    rotationSystem := PlanarEmbedding(digraph);
    facialWalks := FacialWalks(digraph, rotationSystem);

    dualEdges := [];
    for cycle1 in [1 .. Length(facialWalks) - 1] do
        for cycle2 in [cycle1 .. Length(facialWalks)] do
            if cycle1 = cycle2 then
                if not IsDuplicateFree(facialWalks[cycle1]) then
                    Add(dualEdges, [cycle1, cycle1]);
                fi;
            else
                commonNodes := Intersection(facialWalks[cycle1],
                                            facialWalks[cycle2]);
                if Length(commonNodes) = Length(facialWalks[cycle1]) then
                    for i in [1 .. Length(commonNodes)] do
                        Add(dualEdges, [cycle1, cycle2]);
                        Add(dualEdges, [cycle2, cycle1]);
                    od;
                else
                    for i in [1 .. Length(commonNodes) - 1] do
                        Add(dualEdges, [cycle1, cycle2]);
                        Add(dualEdges, [cycle2, cycle1]);
                    od;
                fi;
            fi;
        od;
    od;
    return DigraphByEdges(dualEdges);
end);

# A graph is a map graph if we can find a "witness" that is planar
# and bipartite that the original graph is a half-square of

BindGlobal("DIGRAPHS_EdgesCoveredBy",
  function(clique, subEdges, mapping)
    local covered, a, b, ia, ib, edgeIdx, temp;
    covered := BlistList([1 .. Length(subEdges)], []);

    for a in [1 .. Length(clique)] do
      for b in [a+1 .. Length(clique)] do
        ia := mapping[clique[a]];
        ib := mapping[clique[b]];
        if ia > ib then
          temp := ia;
          ia := ib;
          ib := temp;
        fi;
        edgeIdx := PositionSorted(subEdges, [ia, ib]);
        if edgeIdx <= Length(subEdges) and subEdges[edgeIdx] = [ia, ib] then
          covered[edgeIdx] := true;
        fi;
      od;
    od;
    return covered;
  end);

# for all vertices v find all ways to cover its edges using a set of cliques
BindGlobal("DIGRAPHS_NbrCliqueCovers",
function(D, v)
  local nbrs, sub, subEdges, maxCliques, mapping, cliqueCoverage,
        covers, i, j, e, Backtrack;
  nbrs := ShallowCopy(OutNeighboursOfVertex(D, v));
  nbrs := Filtered(nbrs, x -> x <> v);
  Sort(nbrs);

  if IsEmpty(nbrs) then
    return [[]];
  fi;
  sub := InducedSubdigraph(D, nbrs);

  # gets the edges in the new graph
  subEdges := [];
  for i in DigraphVertices(sub) do
    for e in OutNeighboursOfVertex(sub, i) do
      if e > i then
        Add(subEdges, [i, e]);
      fi;
    od;
  od;

  if IsEmpty(subEdges) then
    return [List(nbrs, u -> [u])];
  fi;

  maxCliques := List(DigraphMaximalCliques(sub),
                     cl -> List(cl, idx -> nbrs[idx]));

  mapping := [];
  for i in [1 .. Length(nbrs)] do
    mapping[nbrs[i]] := i;
  od;

  cliqueCoverage := List(maxCliques, cl->DIGRAPHS_EdgesCoveredBy(cl, subEdges, mapping));

  covers := [];

  # find all edge covering clique sets
  Backtrack := function(cover, uncovered, start)
    local newUncovered, cov, touchedVerts, u, jj;

    if not ForAny(uncovered, x -> x) then
      touchedVerts := Union(cover);
      cov := ShallowCopy(cover);

      for u in nbrs do
        if not u in touchedVerts then
          Add(cov, [u]);
        fi;
      od;

      Add(covers, cov);
      return;
    fi;

    for i in [start .. Length(maxCliques)] do

      if ForAny([1 .. Length(subEdges)],
                jj -> uncovered[jj] and cliqueCoverage[i][jj]) then

        newUncovered := ShallowCopy(uncovered);
        for j in [1 .. Length(subEdges)] do
          if cliqueCoverage[i][j] then
            newUncovered[j] := false;
          fi;
        od;

        Add(cover, maxCliques[i]);
        Backtrack(cover, newUncovered, i + 1);
        Remove(cover);
      fi;
    od;
  end;

  Backtrack([], BlistList([1 .. Length(subEdges)],
                          [1 .. Length(subEdges)]), 1);

  if IsEmpty(covers) then
    return [List(nbrs, u -> [u])];
  fi;

  return covers;
end);

BindGlobal("DIGRAPHS_BuildWitness",
function(n, covers)
  local witnessMap, nextWitness, outNeighb, v, clique, canon, key, w, u;

  witnessMap := HashMap();
  nextWitness := n + 1;
  outNeighb := List([1 .. n], i -> []);

  for v in [1 .. n] do
    for clique in covers[v] do
      canon := ShallowCopy(clique);
      if not v in canon then
        AddSet(canon, v);
      fi;

      if not IsBound(witnessMap[canon]) then
        witnessMap[canon] := nextWitness;
        Add(outNeighb, []);
        nextWitness := nextWitness + 1;
      fi;
      w := witnessMap[canon];

      for u in canon do
        AddSet(outNeighb[u], w);
        AddSet(outNeighb[w], u);
      od;
    od;
  od;

  for v in [1 .. Length(outNeighb)] do
    Sort(outNeighb[v]);
  od;

  return Digraph(outNeighb);
end);

# reconstruct graph from the planar bipartite graph
# for the inputted H we have U = [1...n] and V is the rest(all junctions)
BindGlobal("DIGRAPHS_HalfSquare",
function(H, n)
  local out_neighbors, u, w, v, outgoing;

  out_neighbors := List([1..n], u ->
    Filtered(DigraphDistanceSet(H, u, 2), v -> v <= n)
  );

  return Digraph(out_neighbors);
end);

BindGlobal("DIGRAPHS_IsMapGraphSearch",
function(G, n)
  local allCovers, coverCounts, indices, assignment, H,
        halfsq, i, v, targetEdges;

  targetEdges := Set(DigraphEdges(G));

  allCovers   := List([1 .. n], v -> DIGRAPHS_NbrCliqueCovers(G, v));
  coverCounts := List(allCovers, Length);

  if ForAny(allCovers, IsEmpty) then
    return false;
  fi;

  indices := List([1 .. n], i -> 1);

  while true do
    assignment := List([1 .. n], v -> allCovers[v][indices[v]]);
    H := DIGRAPHS_BuildWitness(n, assignment);

    if IsPlanarDigraph(H) then
      halfsq := DIGRAPHS_HalfSquare(H, n);

      if Set(DigraphEdges(halfsq)) = targetEdges then
        return true;
      fi;
    fi;
    i := n;
    while i >= 1 do
      if indices[i] < coverCounts[i] then
        indices[i] := indices[i] + 1;
        break;
      else
        indices[i] := 1;
        i := i - 1;
      fi;
    od;
    if i = 0 then
      break;
    fi;
  od;

  return false;
end);

########################################################################
# 2. Properties
########################################################################

InstallMethod(IsPlanarDigraph, "for a digraph", [IsDigraph],
function(D)
  local v, e;
  v := DigraphNrVertices(D);
  e := DigraphNrAdjacenciesWithoutLoops(D);
  if HasIsPlanarDigraph(D) then
    return IsPlanarDigraph(D);
  fi;
  if v < 5 or e < 9 then
    return true;
  elif (IsConnectedDigraph(D) and e > 3 * v - 6)
      or (HasChromaticNumber(D) and ChromaticNumber(D) > 4) then
    return false;
  fi;
  return IS_PLANAR(D);
end);

InstallMethod(IsOuterPlanarDigraph, "for a digraph", [IsDigraph],
function(D)
  local v, e;
  if HasIsPlanarDigraph(D) and not IsPlanarDigraph(D) then
    return false;
  fi;
  v := DigraphNrVertices(D);
  e := DigraphNrAdjacenciesWithoutLoops(D);
  if v < 4 or e < 6 then
    return true;
  elif HasChromaticNumber(D) and ChromaticNumber(D) > 3 then
    # Outer planar graphs are 3-colourable
    return false;
  fi;
  return IS_OUTER_PLANAR(D);
end);

InstallMethod(IsMapGraph, "for a digraph", [IsDigraph],
function(D)
  local G, n, m;

  if IsMultiDigraph(D) then
    ErrorNoReturn("expected a digraph with no multiple edges");
  fi;

  G := MaximalSymmetricSubdigraphWithoutLoops(D);

  n := DigraphNrVertices(G);
  m := DigraphNrAdjacenciesWithoutLoops(G);
  # Graphs with n < 5 or m < 9 are inherently planar
  # Direct combination of Planar Bipartite Edge Limit and Euler's formula
  # Map graphs by definition are a superset of planar graphs
  if n < 5 or m < 9 then
    return true;
  elif m > 2 * (6 * n - 12) then
    return false;
  elif IsPlanarDigraph(G) then
    return true;
  fi;

  return DIGRAPHS_IsMapGraphSearch(G, n);
end);