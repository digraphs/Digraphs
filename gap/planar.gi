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
