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

InstallMethod(PlanarEmbedding, "for a digraph", [IsDigraph],
function(D)
  if IsEmptyDigraph(D) or DigraphNrVertices(D) < 3 then
    return [];
  elif HasIsPlanarDigraph(D) and not IsPlanarDigraph(D) then
    return fail;
  fi;
  D := MaximalAntiSymmetricSubdigraph(DigraphMutableCopyIfMutable(D));
  return PLANAR_EMBEDDING(D);
end);

InstallMethod(OuterPlanarEmbedding, "for a digraph", [IsDigraph],
function(D)
  if IsEmptyDigraph(D) or DigraphNrVertices(D) < 3 then
    return [];
  elif HasIsOuterPlanarDigraph(D) and not IsOuterPlanarDigraph(D) then
    return fail;
  fi;
  D := MaximalAntiSymmetricSubdigraph(DigraphMutableCopyIfMutable(D));
  return OUTER_PLANAR_EMBEDDING(D);
end);

InstallMethod(KuratowskiPlanarSubdigraph, "for a digraph", [IsDigraph],
function(D)
  if IsPlanarDigraph(D) then
    return fail;
  fi;
  D := MaximalAntiSymmetricSubdigraph(DigraphMutableCopyIfMutable(D));
  return KURATOWSKI_PLANAR_SUBGRAPH(D);
end);

InstallMethod(KuratowskiOuterPlanarSubdigraph, "for a digraph", [IsDigraph],
function(D)
  if IsOuterPlanarDigraph(D) then
    return fail;
  fi;
  D := MaximalAntiSymmetricSubdigraph(DigraphMutableCopyIfMutable(D));
  return KURATOWSKI_OUTER_PLANAR_SUBGRAPH(D);
end);

InstallMethod(SubdigraphHomeomorphicToK23, "for a digraph", [IsDigraph],
function(D)
  if IsOuterPlanarDigraph(D) then
    return fail;
  fi;
  D := MaximalAntiSymmetricSubdigraph(DigraphMutableCopyIfMutable(D));
  return SUBGRAPH_HOMEOMORPHIC_TO_K23(D);
end);

InstallMethod(SubdigraphHomeomorphicToK4, "for a digraph", [IsDigraph],
function(D)
  if IsOuterPlanarDigraph(D) then
    return fail;
  fi;
  D := MaximalAntiSymmetricSubdigraph(DigraphMutableCopyIfMutable(D));
  return SUBGRAPH_HOMEOMORPHIC_TO_K4(D);
end);

InstallMethod(SubdigraphHomeomorphicToK33, "for a digraph", [IsDigraph],
function(D)
  if IsPlanarDigraph(D) then
    return fail;
  fi;
  D := MaximalAntiSymmetricSubdigraph(DigraphMutableCopyIfMutable(D));
  return SUBGRAPH_HOMEOMORPHIC_TO_K33(D);
end);

########################################################################
# 2. Properties
########################################################################

InstallMethod(IsPlanarDigraph, "for a digraph", [IsDigraph],
function(D)
  local C, v, e;
  C := MaximalAntiSymmetricSubdigraph(DigraphMutableCopyIfMutable(D));
  v := DigraphNrVertices(D);
  e := DigraphNrEdges(C);
  if v < 5 or e < 9 then
    return true;
  elif (IsConnectedDigraph(D) and e > 3 * v - 6)
      or (HasChromaticNumber(D) and ChromaticNumber(D) > 4) then
    return false;
  fi;
  return IS_PLANAR(C);
end);

InstallMethod(IsOuterPlanarDigraph, "for a digraph", [IsDigraph],
function(D)
  local C, v, e;
  if HasIsPlanarDigraph(D) and not IsPlanarDigraph(D) then
    return false;
  fi;
  v := DigraphNrVertices(D);
  e := DigraphNrEdges(D);
  if v < 4 or e < 6 then
    return true;
  elif HasChromaticNumber(D) and ChromaticNumber(D) > 3 then
    # Outer planar graphs are 3-colourable
    return false;
  fi;
  C := DigraphMutableCopyIfMutable(D);
  return IS_OUTER_PLANAR(MaximalAntiSymmetricSubdigraph(C));
end);
