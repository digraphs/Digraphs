#############################################################################
##
#W  grahom.gi
#Y  Copyright (C) 2014-15                                  Julius Jonusas
##                                                         James Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# Wrapper for C function DI/GRAPH_HOMOS

InstallGlobalFunction(HomomorphismDigraphsFinder,
function(gr1, gr2, hook, user_param, limit, hint, isinjective, image, map)

  if not (IsDigraph(gr1) and IsDigraph(gr2)) then
    ErrorMayQuit("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                 "the 1st and 2nd arguments <gr1> and <gr2> must be digraphs,");
  fi;

  if hook <> fail then
    if not (IsFunction(hook) and NumberArgumentsFunction(hook) = 2) then
      ErrorMayQuit("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                   "the 3rd argument <hook> has to be a function with 2 ",
                   "arguments,");
    fi;
  elif not IsList(user_param) then
    ErrorMayQuit("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                 "the 4th argument <user_param> must be a list,");
  fi;

  if limit = infinity then
    limit := fail;
  elif not IsPosInt(limit) then
    ErrorMayQuit("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                 "the 5th argument <limit> has to be a positive integer or ",
                 "infinity,");
  fi;

  if hint <> fail and not IsPosInt(hint) then
    ErrorMayQuit("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                  "the 6th argument <hint> has to be a positive integer or ",
                  "fail,");
  fi;

  if not (isinjective in [true, false]) then
    ErrorMayQuit("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                 "the 7th argument <isinjective> has to be a true or false,");
  fi;

  if not (IsHomogeneousList(image)
          and ForAll(image, x -> IsPosInt(x) and x <= DigraphNrVertices(gr2))
          and IsDuplicateFreeList(image))
      then
    ErrorMayQuit("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                 "the 8th argument <image> has to be a duplicate-free list of ",
                 "vertices of the\n2nd argument <gr2>,");
  fi;

  if not (IsList(map) and Length(map) <= DigraphNrVertices(gr1)
          and ForAll(map, x -> x in image)) then
    ErrorMayQuit("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                 "the 9th argument <map> must be a list of vertices of the 8th",
                 " argument <image>\nwhich is no longer than the number of ",
                 "vertices of the 1st argument <gr1>,");# TODO improve
  fi;

  # Cases where we already know the answer
  if (isinjective and ((hint <> fail and hint <> DigraphNrVertices(gr1)) or
            DigraphNrVertices(gr1) > DigraphNrVertices(gr2)))
        or (IsPosInt(hint) and (hint > DigraphNrVertices(gr1) or hint >
            DigraphNrVertices(gr2)))
        or IsEmpty(image)
        or (IsPosInt(hint) and hint > Length(image)) then
    return user_param;
  fi;

  if DigraphNrVertices(gr1) <= 512 and DigraphNrVertices(gr2) <= 512 then
    if IsSymmetricDigraph(gr1) and IsSymmetricDigraph(gr2) then
      GRAPH_HOMOS(gr1, gr2, hook, user_param, limit, hint, isinjective, image,
                  fail, map);
    else
      DIGRAPH_HOMOS(gr1, gr2, hook, user_param, limit, hint, isinjective, image,
                    fail, map);
    fi;
    return user_param;
  fi;
  ErrorMayQuit("Digraphs: HomomorphismDigraphsFinder: error,\n",
               "not yet implemented for digraphs with more than 512 ",
               "vertices,");
end);

#

InstallGlobalFunction(GeneratorsOfEndomorphismMonoid,
function(arg)
  local digraph, limit, G, gens, limit_arg, out;

  if IsEmpty(arg) then
    ErrorMayQuit("Digraphs: GeneratorsOfEndomorphismMonoid: usage,\n",
                 "this function takes at least one argument,");
  fi;

  digraph := arg[1];

  if HasGeneratorsOfEndomorphismMonoidAttr(digraph) then
    return GeneratorsOfEndomorphismMonoidAttr(digraph);
  fi;

  if not IsDigraph(digraph) then
    ErrorMayQuit("Digraphs: GeneratorsOfEndomorphismMonoid: usage,\n",
                 "the 1st argument <digraph> must be a digraph,");
  fi;

  if IsBound(arg[2]) and (IsPosInt(arg[2]) or arg[2] = infinity) then
    limit := arg[2];
  else
    limit := infinity;
  fi;

  G := AutomorphismGroup(digraph);

  if IsTrivial(G) then
    gens := [];
  else
    gens := List(GeneratorsOfGroup(G), AsTransformation);
  fi;

  if IsPosInt(limit) then
    limit_arg := limit;
    limit := limit - Length(gens);
  fi;

  if limit <= 0 then
    return gens;
  fi;

  out := HomomorphismDigraphsFinder(digraph, digraph, fail, gens, limit, fail,
                                    false, DigraphVertices(digraph), []);

  if limit = infinity or Length(gens) < limit_arg then
    SetGeneratorsOfEndomorphismMonoidAttr(digraph, out);
  fi;
  return out;
end);

InstallMethod(GeneratorsOfEndomorphismMonoidAttr, "for a digraph",
[IsDigraph],
function(digraph)
  return GeneratorsOfEndomorphismMonoid(digraph);
end);

################################################################################
# COLOURING

InstallMethod(DigraphColoring, "for a digraph and pos int",
[IsDigraph, IsPosInt],
function(digraph, n)
  local out;

  if IsMultiDigraph(digraph) then
    ErrorMayQuit("Digraphs: DigraphColoring: usage,\n",
                 "the 1st argument <digraph> must not be a  multidigraph,");
  fi;

  out := DigraphEpimorphism(digraph, CompleteDigraph(n));

  if IsEmpty(out) then
    return fail;
  fi;
  return out[1];
end);

InstallMethod(DigraphColouring, "for a digraph and a pos int",
[IsDigraph, IsPosInt],
DigraphColoring);

################################################################################
# HOMOMORPHISMS

# Finds a single homomorphism of highest rank from gr1 to gr2

InstallMethod(DigraphHomomorphism, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local out;

  out := HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, fail, false,
                                    DigraphVertices(gr2), []);

  if IsEmpty(out) then
    return fail;
  fi;
  return out[1];
end);

# Finds a set S of homomorphism from gr1 to gr2 such that every homomorphism g
# between the two graphs can expressed as a composition g = f * x of an element
# f in S and an automorphism x of gr2

InstallMethod(HomomorphismsDigraphsRepresentatives,
"for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)

  return HomomorphismDigraphsFinder(gr1, gr2, fail, [], infinity, fail, false,
                                    DigraphVertices(gr2), []);
end);

# Finds the set of all homomorphisms from gr1 to gr2

InstallMethod(HomomorphismsDigraphs, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local hom, aut;

  hom := HomomorphismsDigraphsRepresentatives(gr1, gr2);
  aut := List(AutomorphismGroup(gr2), AsTransformation);
  return Union(List(aut, x -> hom * x));
end);

################################################################################
# INJECTIVE HOMOMORPHISMS

# Finds a single embedding of gr1 into gr2

InstallMethod(DigraphEmbedding, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local out;

  if DigraphNrVertices(gr1) = DigraphNrVertices(gr2) then
    return AsTransformation(IsomorphismDigraphs(gr1, gr2));
  fi;

  out := HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1,
                                    DigraphNrVertices(gr1), true,
                                    DigraphVertices(gr2), []);

  if IsEmpty(out) then
    return fail;
  fi;
  return out[1];
end);

# Same as HomomorphismsDigraphsRepresentatives, except only injective ones

InstallMethod(MonomorphismsDigraphsRepresentatives,
"for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)

  return HomomorphismDigraphsFinder(gr1, gr2, fail, [], infinity,
                                    DigraphNrVertices(gr1), true,
                                    DigraphVertices(gr2), []);
end);

# Finds the set of all monomorphisms from gr1 to gr2

InstallMethod(MonomorphismsDigraphs, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local hom, aut;

  hom := MonomorphismsDigraphsRepresentatives(gr1, gr2);
  aut := List(AutomorphismGroup(gr2), AsTransformation);
  return Union(List(aut, x -> hom * x));
end);

################################################################################
# SURJECTIVE HOMOMORPHISMS

# Finds a single epimorphism from gr1 onto gr2

InstallMethod(DigraphEpimorphism, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local out;

  if DigraphNrVertices(gr1) = DigraphNrVertices(gr2) then
    return AsTransformation(IsomorphismDigraphs(gr1, gr2));
  fi;

  out := HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1,
                                    DigraphNrVertices(gr2), false,
                                    DigraphVertices(gr2), []);

  if IsEmpty(out) then
    return fail;
  fi;
  return out[1];
end);

# Same as HomomorphismsDigraphsRepresentatives, except only surjective ones

InstallMethod(EpimorphismsDigraphsRepresentatives,
"for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)

  return HomomorphismDigraphsFinder(gr1, gr2, fail, [], infinity,
                                    DigraphNrVertices(gr2), false,
                                    DigraphVertices(gr2), []);
end);

# Finds the set of all epimorphisms from gr1 to gr2

InstallMethod(EpimorphismsDigraphs, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local hom, aut;

  hom := EpimorphismsDigraphsRepresentatives(gr1, gr2);
  aut := List(AutomorphismGroup(gr2), AsTransformation);
  return Union(List(aut, x -> hom * x));
end);
