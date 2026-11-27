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
  if not IsSymmetricDigraph(D) then
    ErrorNoReturn("the argument <D> must be a symmetric digraph,");
  fi;
  D := DigraphMutableCopyIfMutable(D);
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

# algorithm is based on "Map Graphs" (arXiv:cs/9910013) characterisation:
# for every map graph G, there exists a witness graph H, such that H is planar
# and bipartite, and that G is a half-square of H
#
# the witness H's two sides are analogous to:
# - vertices for the countries of the map
# - vertices for borderings of two or more countries
# each edge is between a country and a border it is part of
#
# this function generates witnesses by a backtrack search, each step adding
# potential borderings until all edges have been covered
BindGlobal("DIGRAPHS_FindMapWitness",
function(G)
  local n, edges, edgeindex, e, Backtrack;

  n := DigraphNrVertices(G);

  edges := Filtered(DigraphEdges(G), e -> e[1] < e[2]);
  edgeindex := List([1 .. n], e -> []);
  for e in [1 .. Length(edges)] do
    edgeindex[edges[e][1]][edges[e][2]] := e;
  od;

  Backtrack := function(witness, edgescovered, prevk, cache, forbidden, depth)
    local added, k, clique, i, j, newcovered, v, result;

    k := Position(edgescovered, false, prevk);
    if k = fail then
      return DigraphImmutableCopy(witness);
    fi;

    # cache[k] is all cliques containing edges[k], in descending order of size
    # because larger cliques cover more, so find witness faster
    if not IsBound(cache[k]) then
      cache[k] := Set(Concatenation(List(
        CliquesFinder(G, fail, [], infinity, edges[k], [], true, fail, false),
        maxcl -> List(Combinations(Difference(maxcl, edges[k])),
                      cl -> Set(Concatenation(edges[k], cl))))));
      SortBy(cache[k], cl -> -Length(cl));

      # TODO: check if this version is faster once #966 is fixed
      # cache[k] := SortedList(
      #  CliquesFinder(G, fail, [], infinity, edges[k], [], false, fail, false),
      #  {x, y} -> Length(x) > Length(y));
    fi;

    # the order in which you choose cliques to make a witness doesn't matter. so
    # if adding a clique to the current witness was unsuccessful, forbid using
    # it at a later point from the current witness
    added := [];

    for clique in cache[k] do
      if not clique in forbidden then
        newcovered := ShallowCopy(edgescovered);
        for i in [1 .. Length(clique) - 1] do
          for j in [i + 1 .. Length(clique)] do
            newcovered[edgeindex[clique[i]][clique[j]]] := true;
          od;
        od;

        # add new junction point in witness, make clique countries connect to it
        # directly modifying !.OutNeighbours avoids unnecessary safety checks
        Add(witness!.OutNeighbours, ShallowCopy(clique));
        for v in clique do
          Add(witness!.OutNeighbours[v], n + depth + 1);
        od;

        AddSet(forbidden, clique);
        AddSet(added, clique);

        # adding vertices to non-planar witness will never make it planar
        if IsPlanarDigraph(witness) then
          result := Backtrack(witness, newcovered, k, cache, forbidden,
                              depth + 1);
          if result <> fail then
            return result;
          fi;
        fi;

        # cleanup junction and associated edges, again avoiding safety checks
        Remove(witness!.OutNeighbours);
        for v in clique do
          Remove(witness!.OutNeighbours[v]);
        od;
      fi;
    od;

    SubtractSet(forbidden, added);

    return fail;
  end;

  return Backtrack(EmptyDigraph(IsMutableDigraph, n), List(edges, ReturnFalse),
                   0, [], [], 0);
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
  local G, comp, H;

  G := MaximalSymmetricSubdigraphWithoutLoops(D);

  # each disjoint component is map graph <=> entire graph is map graph
  for comp in DigraphConnectedComponents(G).comps do
    H := InducedSubdigraph(G, comp);

    # complete digraph is a map where countries meet at a point, like a pizza
    # planar digraphs are a subset of map graphs
    if IsCompleteDigraph(H) or IsPlanarDigraph(H) then
      continue;
    fi;

    # from "Map Graphs" (arXiv:cs/9910013): if G has no clique of size
    # four, then it is a map graph if and only if it is a planar graph.
    if CliqueNumber(H) < 4 or DIGRAPHS_FindMapWitness(H) = fail then
      return false;
    fi;
  od;
  return true;
end);