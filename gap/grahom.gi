#############################################################################
##
##  grahom.gi
##  Copyright (C) 2014-18                                  Julius Jonusas
##                                                         James Mitchell
##                                                         Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallGlobalFunction(GeneratorsOfEndomorphismMonoid,
function(arg)
  local digraph, limit, colours, G, gens, limit_arg, out;

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
      colours := arg[2];
      G := AutomorphismGroup(DigraphRemoveAllMultipleEdges(digraph), colours);
    elif not IsBound(arg[3]) and (IsPosInt(arg[2]) or arg[2] = infinity) then
      # arg[2] is <limit>
      arg[3] := arg[2];
      colours := fail;
      G := AutomorphismGroup(DigraphRemoveAllMultipleEdges(digraph));
    else
      ErrorNoReturn("Digraphs: GeneratorsOfEndomorphismMonoid: usage,\n",
                    "<colours> must be a homogenous list,");
    fi;
  else
    if HasGeneratorsOfEndomorphismMonoidAttr(digraph) then
      return GeneratorsOfEndomorphismMonoidAttr(digraph);
    fi;
    colours := fail;
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

  out := HomomorphismDigraphsFinder(digraph,                   # gr1
                                    digraph,                   # gr2
                                    fail,                      # hook
                                    gens,                      # user_param
                                    limit,                     # limit
                                    fail,                      # hint
                                    0,                         # injective
                                    DigraphVertices(digraph),  # image
                                    [],                        # partial map
                                    colours,                   # colours1
                                    colours,                   # colours2
                                    DigraphWelshPowellOrder(digraph));

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

InstallMethod(DigraphColouring, "for a digraph and an integer",
[IsDigraph, IsInt],
function(digraph, n)
  if n < 0 then
    ErrorNoReturn("Digraphs: DigraphColouring: usage,\n",
                  "the second argument <n> must be a non-negative integer,");
  fi;

  if HasDigraphGreedyColouring(digraph) then
    if DigraphGreedyColouring(digraph) = fail then
      return fail;
    elif RankOfTransformation(DigraphGreedyColouring(digraph),
                              DigraphNrVertices(digraph)) = n then
      return DigraphGreedyColouring(digraph);
    fi;
  fi;

  # Only the null digraph with 0 vertices can be coloured with 0 colours
  if n = 0 then
    if DigraphNrVertices(digraph) = 0 then
      return IdentityTransformation;
    fi;
    return fail;
  fi;

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

InstallMethod(DigraphGreedyColouring, "for a digraph", [IsDigraph],
function(D)
  return DigraphGreedyColouringNC(D, DigraphWelshPowellOrder(D));
end);

InstallMethod(DigraphGreedyColouring, "for a digraph",
[IsDigraph, IsHomogeneousList],
function(D, order)
  local n;
  n := DigraphNrVertices(D);
  if Length(order) <> n or ForAny(order, x -> (not IsPosInt(x)) or x > n) then
    ErrorNoReturn("the second argument <order> must be a permutation of ",
                  [1 .. n]);
  fi;
  return DigraphGreedyColouringNC(D, order);
end);

InstallMethod(DigraphGreedyColouringNC, "for a digraph and a homogeneous list",
[IsDigraph, IsHomogeneousList],
function(digraph, order)
  local n, colour, colouring, out, inn, empty, all, available, nr_coloured, v;

  n := DigraphNrVertices(digraph);

  if n = 0 then
    return IdentityTransformation;
  elif DigraphHasLoops(digraph) then
    return fail;
  fi;

  colour := 1;
  colouring := ListWithIdenticalEntries(n, 0);
  out := OutNeighbours(digraph);
  inn := InNeighbours(digraph);
  empty := BlistList([1 .. n], []);
  all := BlistList([1 .. n], [1 .. n]);
  available := BlistList([1 .. n], [1 .. n]);

  nr_coloured := 0;

  while nr_coloured < n do
    for v in order do
      if colouring[v] = 0 and available[v] then
        nr_coloured := nr_coloured + 1;
        colouring[v] := colour;
        available[v] := false;
        SubtractBlist(available, BlistList([1 .. n], out[v]));
        SubtractBlist(available, BlistList([1 .. n], inn[v]));
        if available = empty then
          break;
        fi;
      fi;
    od;
    UniteBlist(available, all);
    colour := colour + 1;
  od;
  return TransformationNC(colouring);
end);

InstallMethod(DigraphGreedyColouring, "for a digraph and a function",
[IsDigraph, IsFunction],
function(D, func)
  return DigraphGreedyColouringNC(D, func(D));
end);

InstallMethod(DigraphWelshPowellOrder, "for a digraph", [IsDigraph],
function(digraph)
  local order, deg;
  order := [1 .. DigraphNrVertices(digraph)];
  deg   := ShallowCopy(OutDegrees(digraph)) + InDegrees(digraph);
  SortParallel(deg, order, {x, y} -> x > y);
  return order;
end);

################################################################################
# HOMOMORPHISMS

# Finds a single homomorphism of highest rank from D1 to D2

InstallMethod(DigraphHomomorphism, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(D1, D2)
  local out;
  out := HomomorphismDigraphsFinder(D1,
                                    D2,
                                    fail,                 # hook
                                    [],                   # user_param
                                    1,                    # limit
                                    fail,                 # hint
                                    0,                    # injective
                                    DigraphVertices(D2),  # image
                                    [],                   # map
                                    fail,                 # colours1
                                    fail,                 # colours2
                                    DigraphWelshPowellOrder(D1));
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
function(D1, D2)
  return HomomorphismDigraphsFinder(D1,
                                    D2,
                                    fail,                  # hook
                                    [],                    # user_param
                                    infinity,              # limit
                                    fail,                  # hint
                                    0,                     # injective
                                    DigraphVertices(D2),   # image
                                    [],                    # map
                                    fail,                  # colours1
                                    fail,                  # colours2
                                    DigraphWelshPowellOrder(D1));
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
function(D1, D2)
  local out;
  out := HomomorphismDigraphsFinder(D1,
                                    D2,
                                    fail,                   # hook
                                    [],                     # user_param
                                    1,                      # limit
                                    DigraphNrVertices(D1),  # hint
                                    1,                      # injective
                                    DigraphVertices(D2),    # image
                                    [],                     # map
                                    fail,                   # colours1
                                    fail,                   # colours2
                                    DigraphWelshPowellOrder(D1));
  if IsEmpty(out) then
    return fail;
  fi;
  return out[1];
end);

# Same as HomomorphismsDigraphsRepresentatives, except only injective ones

InstallMethod(MonomorphismsDigraphsRepresentatives,
"for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(D1, D2)
  return HomomorphismDigraphsFinder(D1,
                                    D2,
                                    fail,                    # hook
                                    [],                      # user_param
                                    infinity,                # limit
                                    DigraphNrVertices(D1),   # hint
                                    1,                       # injective
                                    DigraphVertices(D2),     # image
                                    [],                      # map
                                    fail,                    # colours1
                                    fail,                    # colours2
                                    DigraphWelshPowellOrder(D1));
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

# Finds a single epimorphism from D1 onto D2

InstallMethod(DigraphEpimorphism, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(D1, D2)
  local out;
  out := HomomorphismDigraphsFinder(D1,
                                    D2,
                                    fail,                   # hook
                                    [],                     # user_param
                                    1,                      # limit
                                    DigraphNrVertices(D2),  # hint
                                    0,                      # injective
                                    DigraphVertices(D2),    # image
                                    [],                     # map
                                    fail,                   # colours1
                                    fail,                   # colours2
                                    DigraphWelshPowellOrder(D1));
  if IsEmpty(out) then
    return fail;
  fi;
  return out[1];
end);

# Same as HomomorphismsDigraphsRepresentatives, except only surjective ones

InstallMethod(EpimorphismsDigraphsRepresentatives,
"for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(D1, D2)
  return HomomorphismDigraphsFinder(D1,
                                    D2,
                                    fail,                   # hook
                                    [],                     # user_param
                                    infinity,               # limit
                                    DigraphNrVertices(D2),  # hint
                                    0,                      # injective
                                    DigraphVertices(D2),    # image
                                    [],                     # map
                                    fail,                   # colours1
                                    fail,                   # colours2
                                    DigraphWelshPowellOrder(D1));
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
# Embeddings
################################################################################

InstallMethod(DigraphEmbedding, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(D1, D2)
  local out;
  out := HomomorphismDigraphsFinder(D1,
                                    D2,
                                    fail,                   # hook
                                    [],                     # user_param
                                    1,                      # limit
                                    DigraphNrVertices(D1),  # hint
                                    2,                      # injective
                                    DigraphVertices(D2),    # image
                                    [],                     # map
                                    fail,                   # colours1
                                    fail,                   # colours2
                                    DigraphWelshPowellOrder(D1));
  if IsEmpty(out) then
    return fail;
  fi;
  return out[1];
end);

# Same as HomomorphismsDigraphsRepresentatives, except only embeddings ones

InstallMethod(EmbeddingsDigraphsRepresentatives,
"for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(D1, D2)
  return HomomorphismDigraphsFinder(D1,
                                    D2,
                                    fail,                   # hook
                                    [],                     # user_param
                                    infinity,               # limit
                                    DigraphNrVertices(D1),  # hint
                                    2,                      # injective
                                    DigraphVertices(D2),    # image
                                    [],                     # map
                                    fail,                   # colours1
                                    fail,                   # colours2
                                    DigraphWelshPowellOrder(D1));
end);

InstallMethod(EmbeddingsDigraphs, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local hom, aut;
  hom := EmbeddingsDigraphsRepresentatives(gr1, gr2);
  aut := List(AutomorphismGroup(DigraphRemoveAllMultipleEdges(gr2)),
              AsTransformation);
  return Union(List(aut, x -> hom * x));
end);

########################################################################
# IsDigraphHomo/Epi/.../morphism
########################################################################

InstallMethod(IsDigraphHomomorphism, "for digraph, digraph, and perm",
[IsDigraph, IsDigraph, IsPerm],
function(src, ran, x)
  local i, j;
  if IsMultiDigraph(src) or IsMultiDigraph(ran) then
    ErrorNoReturn("Digraphs: IsDigraphHomomorphism: usage,\n",
                  "the first 2 arguments must not have multiple edges,");
  elif LargestMovedPoint(x) > DigraphNrVertices(src) then
    return false;
  fi;
  for i in DigraphVertices(src) do
    for j in OutNeighbours(src)[i] do
      if not IsDigraphEdge(ran, i ^ x, j ^ x) then
        return false;
      fi;
    od;
  od;
  return true;
end);

InstallMethod(IsDigraphEndomorphism, "for a digraph and a perm",
[IsDigraph, IsPerm], IsDigraphAutomorphism);

InstallMethod(IsDigraphHomomorphism,
"for digraph, digraph, and transformation",
[IsDigraph, IsDigraph, IsTransformation],
function(src, ran, x)
  local i, j;
  if IsMultiDigraph(src) or IsMultiDigraph(ran) then
    ErrorNoReturn("Digraphs: IsDigraphHomomorphism: usage,\n",
                  "the first 2 arguments must not have multiple edges,");
  elif LargestMovedPoint(x) > DigraphNrVertices(src) then
    return false;
  fi;
  for i in DigraphVertices(src) do
    for j in OutNeighbours(src)[i] do
      if not IsDigraphEdge(ran, i ^ x, j ^ x) then
        return false;
      fi;
    od;
  od;
  return true;
end);

InstallMethod(IsDigraphEndomorphism, "for a digraph and a transformation",
[IsDigraph, IsTransformation],
function(gr, x)
  return IsDigraphHomomorphism(gr, gr, x);
end);

InstallMethod(IsDigraphEpimorphism, "for digraph, digraph, and transformation",
[IsDigraph, IsDigraph, IsTransformation],
function(src, ran, x)
  return IsDigraphHomomorphism(src, ran, x)
    and OnSets(DigraphVertices(src), x) = DigraphVertices(ran);
end);

InstallMethod(IsDigraphEpimorphism, "for digraph, digraph, and perm",
[IsDigraph, IsDigraph, IsPerm],
function(src, ran, x)
  return IsDigraphHomomorphism(src, ran, x)
    and OnSets(DigraphVertices(src), x) = DigraphVertices(ran);
end);

InstallMethod(IsDigraphMonomorphism,
"for digraph, digraph, and transformation",
[IsDigraph, IsDigraph, IsTransformation],
function(src, ran, x)
  return IsDigraphHomomorphism(src, ran, x)
    and IsInjectiveListTrans(DigraphVertices(src), x);
end);

InstallMethod(IsDigraphMonomorphism, "for digraph, digraph, and perm",
[IsDigraph, IsDigraph, IsPerm], IsDigraphHomomorphism);

InstallMethod(IsDigraphEmbedding,
"for digraph, digraph, and transformation",
[IsDigraph, IsDigraph, IsTransformation],
function(src, ran, x)
  local y, induced, i, j;
  if not IsDigraphMonomorphism(src, ran, x) then
    return false;
  fi;
  y := MappingPermListList(OnTuples(DigraphVertices(src), x),
                           DigraphVertices(src));
  induced := BlistList(DigraphVertices(ran), OnSets(DigraphVertices(src), x));
  for i in DigraphVertices(ran) do
    if induced[i] then
      for j in OutNeighbours(ran)[i] do
        if induced[j] and not IsDigraphEdge(src, i ^ y, j ^ y) then
          return false;
        fi;
      od;
    fi;
  od;
  return true;
end);

InstallMethod(IsDigraphEmbedding, "for digraph, digraph, and perm",
[IsDigraph, IsDigraph, IsPerm],
function(src, ran, x)
  local y, induced, i, j;
  if not IsDigraphHomomorphism(src, ran, x) then
    return false;
  fi;
  y := x ^ -1;
  induced := BlistList(DigraphVertices(ran), OnSets(DigraphVertices(src), x));
  for i in DigraphVertices(ran) do
    if induced[i] then
      for j in OutNeighbours(ran)[i] do
        if induced[j] and not IsDigraphEdge(src, i ^ y, j ^ y) then
          return false;
        fi;
      od;
    fi;
  od;
  return true;
end);

InstallMethod(IsDigraphColouring, "for a digraph and a list",
[IsDigraph, IsHomogeneousList],
function(digraph, colours)
  local n, out, v, w;
  n := DigraphNrVertices(digraph);
  if Length(colours) <> n or ForAny(colours, x -> not IsPosInt(x)) then
    return false;
  fi;
  out := OutNeighbours(digraph);
  for v in DigraphVertices(digraph) do
    for w in out[v] do
      if colours[w] = colours[v] then
        return false;
      fi;
    od;
  od;
  return true;
end);

InstallMethod(IsDigraphColouring, "for a digraph and a transformation",
[IsDigraph, IsTransformation],
function(digraph, t)
  local n;
  n := DigraphNrVertices(digraph);
  return IsDigraphColouring(digraph,
                            ImageListOfTransformation(t, n));
end);
