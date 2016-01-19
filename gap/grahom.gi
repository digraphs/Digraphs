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
function(gr1, gr2, hook, user_param, limit, hint, inj, image, map, list1, list2)
  local colors, gr, list, i, j;

  if not (IsDigraph(gr1) and IsDigraph(gr2)) then
    ErrorNoReturn("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                  "the 1st and 2nd arguments <gr1> and <gr2> must be ",
                  "digraphs,");
  fi;

  if hook <> fail then
    if not (IsFunction(hook) and NumberArgumentsFunction(hook) = 2) then
      ErrorNoReturn("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                    "the 3rd argument <hook> has to be a function with 2 ",
                    "arguments,");
    fi;
  elif not IsList(user_param) then
    ErrorNoReturn("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                  "the 4th argument <user_param> must be a list,");
  fi;

  if limit = infinity then
    limit := fail;
  elif not IsPosInt(limit) then
    ErrorNoReturn("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                  "the 5th argument <limit> has to be a positive integer or ",
                  "infinity,");
  fi;

  if hint <> fail and not IsPosInt(hint) then
    ErrorNoReturn("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                  "the 6th argument <hint> has to be a positive integer or ",
                  "fail,");
  fi;

  if not (inj in [true, false]) then
    ErrorNoReturn("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                  "the 7th argument <inj> has to be a true or false,");
  fi;

  if not (IsHomogeneousList(image)
          and ForAll(image, x -> IsPosInt(x) and x <= DigraphNrVertices(gr2))
          and IsDuplicateFreeList(image))
      then
    ErrorNoReturn("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                  "the 8th argument <image> has to be a duplicate-free list of",
                  " vertices of the\n2nd argument <gr2>,");
  fi;

  if not (IsList(map) and Length(map) <= DigraphNrVertices(gr1)
          and ForAll(map, x -> x in image)) then
    ErrorNoReturn("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                  "the 9th argument <map> must be a list of vertices of the 8t",
                  "h argument <image>\nwhich is no longer than the number of ",
                  "vertices of the 1st argument <gr1>,");# TODO improve
  fi;

  if list1 = fail and list2 = fail then
    colors := [fail, fail];
  elif list1 <> fail and list2 <> fail then
    gr     := [gr1, gr2];
    list   := [list1, list2];
    colors := [];
    for i in [1, 2] do
      if (not IsEmpty(list[i])) and IsList(list[i][1]) then # color classes
        colors[i] := [1 .. DigraphNrVertices(gr[i])];
        if not (IsDuplicateFreeList(Concatenation(list[i])) and
                Union(list[i]) = colors[i]) then
          ErrorNoReturn("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                        "the union of the lists in the ", 9 + i,
                        "th arg should equal ",
                        "[1 .. ", DigraphNrVertices(gr[i]), "],");
        fi;

        for j in [1 .. Length(list[i])] do
          colors[i]{list[i][j]} := [1 .. Length(list[i][j])] * 0 + j;
        od;
      else
        if not (Length(list[i]) = DigraphNrVertices(gr[i])
                and ForAll(list[i], c -> IsPosInt(c) and 1 <= c
                                     and c <= DigraphNrVertices(gr[i]))) then
          ErrorNoReturn("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                        "the ", 9 + i, "th arg must be a list of length ",
                        DigraphNrVertices(gr[i]), " of integers in [1 .. ",
                        DigraphNrVertices(gr[i]), "],");
        fi;
        colors[i] := list[i];
      fi;
    od;
  else
    ErrorNoReturn("Digraphs: HomomorphismDigraphsFinder: usage,\n",
                  "the 10th and 11th arguments <list1> and <list2> must both ",
                  "be fail or neither must be fail,");
  fi;

  # Cases where we already know the answer
  if (inj and ((hint <> fail and hint <> DigraphNrVertices(gr1)) or
            DigraphNrVertices(gr1) > DigraphNrVertices(gr2)))
        or (IsPosInt(hint) and (hint > DigraphNrVertices(gr1) or hint >
            DigraphNrVertices(gr2)))
        or IsEmpty(image)
        or (IsPosInt(hint) and hint > Length(image)) then
    return user_param;
  fi;

  if DigraphNrVertices(gr1) <= 512 and DigraphNrVertices(gr2) <= 512 then
    if IsSymmetricDigraph(gr1) and IsSymmetricDigraph(gr2) then
      GRAPH_HOMOS(gr1, gr2, hook, user_param, limit, hint, inj, image,
                  fail, map, colors[1], colors[2]);
    else
      DIGRAPH_HOMOS(gr1, gr2, hook, user_param, limit, hint, inj, image,
                    fail, map, colors[1], colors[2]);
    fi;
    return user_param;
  fi;
  ErrorNoReturn("Digraphs: HomomorphismDigraphsFinder: error,\n",
                "not yet implemented for digraphs with more than 512 ",
                "vertices,");
end);

#

InstallGlobalFunction(GeneratorsOfEndomorphismMonoid,
function(arg)
  local digraph, limit, colors, G, gens, limit_arg, out;

  if IsEmpty(arg) then
    ErrorNoReturn("Digraphs: GeneratorsOfEndomorphismMonoid: usage,\n",
                  "this function takes at least one argument,");
  fi;

  digraph := arg[1];

  if not IsDigraph(digraph) then
    ErrorNoReturn("Digraphs: GeneratorsOfEndomorphismMonoid: usage,\n",
                  "the 1st argument <digraph> must be a digraph,");
  fi;

  if IsBound(arg[2]) then
    if IsHomogeneousList(arg[2]) then
      colors := arg[2];
      G := AutomorphismGroup(DigraphRemoveAllMultipleEdges(digraph), colors);
    elif not IsBound(arg[3]) and (IsPosInt(arg[2]) or arg[2] = infinity) then
      # arg[2] is <limit>
      arg[3] := arg[2];
      colors := fail;
      G := AutomorphismGroup(DigraphRemoveAllMultipleEdges(digraph));
    else
      ErrorNoReturn("Digraphs: GeneratorsOfEndomorphismMonoid: usage,\n",
                    "<colors> must be a homogenous list,");
    fi;
  else
    if HasGeneratorsOfEndomorphismMonoidAttr(digraph) then
      return GeneratorsOfEndomorphismMonoidAttr(digraph);
    fi;
    colors := fail;
    G := AutomorphismGroup(DigraphRemoveAllMultipleEdges(digraph));
  fi;

  if IsBound(arg[3]) then
    if not (IsPosInt(arg[3]) or arg[3] = infinity) then
      ErrorNoReturn("Digraphs: GeneratorsOfEndomorphismMonoid: usage,\n",
                    "<limit> must be a positive integer or infinity,");
    fi;
    limit := arg[3];
  else
    limit := infinity;
  fi;

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
                                    false, DigraphVertices(digraph), [], colors,
                                    colors);

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
  # Special case for bipartite testing; works for large graphs
  if n = 2 then
    if not IsBipartiteDigraph(digraph) then
      return fail;
    fi;
    return DIGRAPHS_Bipartite(digraph)[2];
  fi;
  # General case for n > 2; works for small graphs
  return DigraphEpimorphism(digraph, CompleteDigraph(n));
end);

################################################################################
# HOMOMORPHISMS

# Finds a single homomorphism of highest rank from gr1 to gr2

InstallMethod(DigraphHomomorphism, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local out;

  out := HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1, fail, false,
                                    DigraphVertices(gr2), [], fail, fail);

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
                                    DigraphVertices(gr2), [], fail, fail);
end);

# Finds the set of all homomorphisms from gr1 to gr2

InstallMethod(HomomorphismsDigraphs, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local hom, aut;

  hom := HomomorphismsDigraphsRepresentatives(gr1, gr2);
  aut := List(AutomorphismGroup(DigraphRemoveAllMultipleEdges(gr2)),
              AsTransformation);
  return Union(List(aut, x -> hom * x));
end);

################################################################################
# INJECTIVE HOMOMORPHISMS

# Finds a single injective homomorphism of gr1 into gr2

InstallMethod(DigraphMonomorphism, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local out;

  out := HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1,
                                    DigraphNrVertices(gr1), true,
                                    DigraphVertices(gr2), [], fail, fail);

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
                                    DigraphVertices(gr2), [], fail, fail);
end);

# Finds the set of all monomorphisms from gr1 to gr2

InstallMethod(MonomorphismsDigraphs, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local hom, aut;

  hom := MonomorphismsDigraphsRepresentatives(gr1, gr2);
  aut := List(AutomorphismGroup(DigraphRemoveAllMultipleEdges(gr2)),
              AsTransformation);
  return Union(List(aut, x -> hom * x));
end);

################################################################################
# SURJECTIVE HOMOMORPHISMS

# Finds a single epimorphism from gr1 onto gr2

InstallMethod(DigraphEpimorphism, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local out;

  out := HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1,
                                    DigraphNrVertices(gr2), false,
                                    DigraphVertices(gr2), [], fail, fail);

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
                                    DigraphVertices(gr2), [], fail, fail);
end);

# Finds the set of all epimorphisms from gr1 to gr2

InstallMethod(EpimorphismsDigraphs, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local hom, aut;

  hom := EpimorphismsDigraphsRepresentatives(gr1, gr2);
  aut := List(AutomorphismGroup(DigraphRemoveAllMultipleEdges(gr2)),
              AsTransformation);
  return Union(List(aut, x -> hom * x));
end);

################################################################################
# EMBEDDINGS

InstallMethod(DigraphEmbedding, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local iso, monos, dual1, edges1, mat, t;

  if DigraphNrVertices(gr1) = DigraphNrVertices(gr2) then
    iso := IsomorphismDigraphs(DigraphRemoveAllMultipleEdges(gr1),
                               DigraphRemoveAllMultipleEdges(gr2));
    if iso = fail then
      return fail;
    fi;
    return AsTransformation(iso);
  fi;

  monos := MonomorphismsDigraphsRepresentatives(gr1, gr2);
  dual1 := DigraphDual(DigraphRemoveAllMultipleEdges(gr1));
  edges1 := DigraphEdges(dual1);
  mat := AdjacencyMatrix(gr2);
  for t in monos do
    if ForAll(edges1, e -> mat[e[1] ^ t][e[2] ^ t] = 0) then
      return t;
    fi;
  od;
  return fail;
end);
