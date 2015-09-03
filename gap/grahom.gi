#############################################################################
##
#W  grahom.gi
#Y  Copyright (C) 2014                                     Julius Jonusas
##                                                         James Mitchell
##
##  Copyright (C) 2014 - Julius Jonusas and James Mitchell.
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# Wrapper for C function GRAPH_HOMOS

InstallGlobalFunction(HomomorphismGraphsFinder,
function(gr1, gr2, hook, user_param, limit, hint, isinjective, image, map)
  local out;

  if not (IsDigraph(gr1) and IsDigraph(gr2) and IsSymmetricDigraph(gr1)
          and IsSymmetricDigraph(gr2)) then
    Error("Digraphs: HomomorphismGraphsFinder: error,\n",
          "not yet implemented,");
  fi;

  if hook <> fail then 
    if not (IsFunction(hook) and NumberArgumentsFunction(hook) = 2) then
      Error("Digraphs: HomomorphismGraphsFinder: usage,\n",
            "the 3rd argument <hook> has to be a function with 2 arguments,");
      return;
    fi;
  elif not IsList(user_param) then 
    Error("Digraphs: HomomorphismGraphsFinder: usage,\n",
          "the 4th argument <user_param> must be a list,");
    return;
  fi;

  if limit = infinity then
    limit := fail;
  elif not IsPosInt(limit) then
    Error("Digraphs: HomomorphismGraphsFinder: usage,\n",
          "the 5th argument <limit> has to be a positive integer or infinity,");
    return;
  fi;

  if hint <> fail and not IsPosInt(hint) then
    Error("Digraphs: HomomorphismGraphsFinder: usage,\n",
          "the 6th argument <hint> has to be a positive integer or fail,");
    return;
  fi;

  if not (isinjective in [true, false]) then
    Error("Digraphs: HomomorphismGraphsFinder: usage,\n",
          "the 7th argument <isinjective> has to be a true or false,");
    return;
  elif isinjective and hint < DigraphNrVertices(gr1) then 
    return user_param;
  fi;

  if not (IsHomogeneousList(image) 
          and ForAll(image, x -> IsPosInt(x) and x <= DigraphNrVertices(gr2)))
      then
    Error("Digraphs: HomomorphismGraphsFinder: usage,\n",
          "the 8th argument <image> has to be a list of vertices of the 2nd argument,");
    return;
  fi;

  if not (IsList(map) and Length(map) <= DigraphNrVertices(gr1) 
          and ForAll(map, x -> x in image)) then
    Error("Digraphs: HomomorphismGraphsFinder: usage,\n",
          "the 9th argument <map> has to be a list,");# TODO improve
    return;
  fi;
  
  #if image = DigraphVertices(gr2) then 
  #  image := fail;
  #fi;

  if DigraphNrVertices(gr1) <= 512 and DigraphNrVertices(gr2) <= 512 then
    DIGRAPH_HOMOS(gr1, gr2, hook, user_param, limit, hint, isinjective, image,
                fail, map);
    return user_param;
  else
    Error("Digraphs: HomomorphismGraphsFinder: error,\n",
          "not yet implemented,");
    return;
  fi;
end);

#

InstallGlobalFunction(GeneratorsOfEndomorphismMonoid,
function(arg)
  local digraph, limit, gens, out;

  digraph := arg[1];

  if HasGeneratorsOfEndomorphismMonoidAttr(digraph) then
    return GeneratorsOfEndomorphismMonoidAttr(digraph);
  fi;

  if not (IsDigraph(digraph) and IsSymmetricDigraph(digraph)) then
    Error("Digraphs: GeneratorsOfEndomorphismMonoid: error,\n",
          "not yet implemented for non-symmetric digraphs,");
  fi;

  if IsDigraph(digraph) and DigraphHasLoops(digraph) then
    Error("Digraphs: GeneratorsOfEndomorphismMonoid: error,\n",
          "not yet implemented for digraphs with loops,");
  fi;

  if IsBound(arg[2]) and (IsPosInt(arg[2]) or arg[2] = infinity) then
    limit := arg[2];
  else
    limit := infinity;
  fi;

  gens := List(GeneratorsOfGroup(AutomorphismGroup(digraph)),
               AsTransformation);

  if IsPosInt(limit) then
    limit := limit - Length(gens);
  fi;

  if limit <= 0 then
    return gens;
  fi;

  out := HomomorphismGraphsFinder(digraph, digraph, fail, gens, limit, fail,
                                  false, DigraphVertices(digraph), []);

  if limit = infinity then
    SetGeneratorsOfEndomorphismMonoidAttr(digraph, out);
  fi;
  return out;
end);

#

InstallMethod(DigraphColoring, "for a digraph and pos int",
[IsDigraph, IsPosInt],
function(digraph, n)
  if IsMultiDigraph(digraph) then
    Error("Digraphs: DigraphColoring: usage,\n",
          "the argument <digraph> must not be a  multigraph,");
    return;
  fi;
  return DigraphHomomorphism(digraph, CompleteDigraph(n));
end);

InstallMethod(DigraphColouring, "for a digraph and a pos int",
[IsDigraph, IsPosInt],
DigraphColoring);

#

InstallMethod(GeneratorsOfEndomorphismMonoidAttr, "for a digraph",
[IsDigraph],
function(digraph)
  return GeneratorsOfEndomorphismMonoid(digraph);
end);

# Finds a single homomorphism of highest rank from graph1 to graph2

InstallMethod(HomomorphismGraphs, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local out;
  # TODO revise this
  out := HomomorphismGraphsFinder(gr1, gr2, fail, fail, 1,
                                  DigraphNrVertices(gr2), false, fail, fail);

  if IsEmpty(out) then
    return fail;
  fi;
    return out[1];
end);

# Finds a set S of homomorphism from graph1 to graph2 such that every
# homomorphism between the two graphs can expressed as a composition of an
# element in S and an automorphism of graph2.

InstallMethod(HomomorphismsGraphsRepresentatives,
"for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  # TODO revise this
  return HomomorphismGraphsFinder(gr1, gr2, fail, fail, fail,
                                  DigraphNrVertices(gr2), false, fail, fail);
end);

InstallMethod(HomomorphismsDigraphs, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local hom, aut;

  hom := HomomorphismsGraphsRepresentatives(gr1, gr2);
  aut := List(GeneratorsOfGroup(AutomorphismGroup(gr2)), AsTransformation);
  return Union(List(aut, x -> hom * x));
end);

# Finds a single embedding of graph1 into graph2

InstallMethod(MonomorphismGraphs, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local out;

  if DigraphNrVertices(gr1) = DigraphNrVertices(gr2) then
    return IsomorphismDigraphs(gr1, gr2);
  fi;

  out := HomomorphismGraphsFinder(gr1, gr2, fail, fail, 1,
                                  DigraphNrVertices(gr2), true, fail, fail);

  if IsEmpty(out) then
    return fail;
  fi;
  return out[1];
end);
