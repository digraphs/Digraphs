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
  local D, limit, colours, G, gens, limit_arg, out;
  if IsEmpty(arg) then
    ErrorNoReturn("at least 1 argument expected, found 0,");
  fi;
  D := arg[1];
  if not IsDigraph(D) then
    ErrorNoReturn("the 1st argument must be a digraph,");
  fi;
  IsValidDigraph(D);
  D := DigraphCopyIfMutable(D);
  if IsBound(arg[2]) then
    if IsHomogeneousList(arg[2]) then
      colours := arg[2];
      G := AutomorphismGroup(DigraphRemoveAllMultipleEdges(D), colours);
    elif not IsBound(arg[3]) and (IsPosInt(arg[2]) or arg[2] = infinity) then
      # arg[2] is <limit>
      arg[3] := arg[2];
      if IsVertexColoredDigraph(D) then
        colours := DigraphVertexColors(D);
      else
        colours := fail;
      fi;
      G := AutomorphismGroup(DigraphRemoveAllMultipleEdges(D));
    else
      ErrorNoReturn("the 2nd argument must be a homogenous list,");
    fi;
  else
    if HasGeneratorsOfEndomorphismMonoidAttr(D) then
      return GeneratorsOfEndomorphismMonoidAttr(D);
    fi;
    if IsVertexColoredDigraph(D) then
      colours := DigraphVertexColors(D);
    else
      colours := fail;
    fi;
    G := AutomorphismGroup(DigraphRemoveAllMultipleEdges(D));
  fi;

  if IsBound(arg[3]) then
    if not (IsPosInt(arg[3]) or arg[3] = infinity) then
      ErrorNoReturn("the 3rd argument must be a positive integer or ",
                    "infinity,");
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

  out := HomomorphismDigraphsFinder(D,                   # gr1
                                    D,                   # gr2
                                    fail,                # hook
                                    gens,                # user_param
                                    limit,               # limit
                                    fail,                # hint
                                    0,                   # injective
                                    DigraphVertices(D),  # image
                                    [],                  # partial map
                                    colours,             # colours1
                                    colours,             # colours2
                                    DigraphWelshPowellOrder(D));

  if limit = infinity or Length(gens) < limit_arg then
    SetGeneratorsOfEndomorphismMonoidAttr(D, out);
  fi;
  return out;
end);

InstallMethod(GeneratorsOfEndomorphismMonoidAttr, "for a digraph",
[IsDigraph], GeneratorsOfEndomorphismMonoid);

################################################################################
# COLOURING

InstallMethod(DigraphColouring, "for a digraph and an integer",
[IsDigraph, IsInt],
function(D, n)
  if n < 0 then
    ErrorNoReturn("the 2nd argument <n> must be a non-negative integer,");
  fi;
  IsValidDigraph(D);
  if HasDigraphGreedyColouring(D) then
    if DigraphGreedyColouring(D) = fail then
      return fail;
    elif RankOfTransformation(DigraphGreedyColouring(D),
                              DigraphNrVertices(D)) = n then
      return DigraphGreedyColouring(D);
    fi;
  fi;

  # Only the null D with 0 vertices can be coloured with 0 colours
  if n = 0 then
    if DigraphNrVertices(D) = 0 then
      return IdentityTransformation;
    fi;
    return fail;
  fi;

  # Special case for bipartite testing; works for large graphs
  if n = 2 then
    if not IsBipartiteDigraph(D) then
      return fail;
    fi;
    return DIGRAPHS_Bipartite(D)[2];
  fi;

  # General case for n > 2; works for small graphs
  return DigraphEpimorphism(D, CompleteDigraph(n));
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
    ErrorNoReturn("the 2nd argument <order> must be a permutation of ",
                  "[1 .. ", n, "]");
  fi;
  return DigraphGreedyColouringNC(D, order);
end);

InstallMethod(DigraphGreedyColouringNC,
"for a dense digraph and a homogeneous list",
[IsDenseDigraphRep, IsHomogeneousList],
function(D, order)
  local n, colour, colouring, out, inn, empty, all, available, nr_coloured, v;
  IsValidDigraph(D);
  n := DigraphNrVertices(D);
  if n = 0 then
    return IdentityTransformation;
  elif DigraphHasLoops(D) then
    return fail;
  fi;
  colour := 1;
  colouring := ListWithIdenticalEntries(n, 0);
  out := OutNeighbours(D);
  inn := InNeighbours(D);
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
function(D)
  local order, deg;
  IsValidDigraph(D);
  order := [1 .. DigraphNrVertices(D)];
  deg   := ShallowCopy(OutDegrees(D)) + InDegrees(D);
  SortParallel(deg, order, {x, y} -> x > y);
  return order;
end);

InstallMethod(DigraphSmallestLastOrder, "for a digraph", [IsDigraph],
function(D)
  local order, n, copy, deg, v;
  IsValidDigraph(D);
  order := [];
  n := DigraphNrVertices(D);
  copy := DigraphCopyIfMutable(D);
  while n > 0 do
    deg := ShallowCopy(OutDegrees(copy)) + InDegrees(copy);
    v := PositionMinimum(deg);
    order[n] := DigraphVertexLabel(copy, v);
    copy := DigraphRemoveVertex(copy, v);
    n := n - 1;
  od;
  return order;
end);

################################################################################
# HOMOMORPHISMS

# Finds a single homomorphism of highest rank from D1 to D2

InstallMethod(DigraphHomomorphism, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(D1, D2)
  local out;
  IsValidDigraph(D1, D2);
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
  IsValidDigraph(D1, D2);
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
function(D1, D2)
  local hom, aut;
  IsValidDigraph(D1, D2);
  hom := HomomorphismsDigraphsRepresentatives(D1, D2);
  D2 := DigraphCopyIfMutable(D2);
  aut := List(AutomorphismGroup(DigraphRemoveAllMultipleEdges(D2)),
              AsTransformation);
  return Union(List(aut, x -> hom * x));
end);

InstallMethod(DigraphHomomorphism,
"for a vertex colored digraph and a vertex colored digraph",
[IsVertexColoredDigraph, IsVertexColoredDigraph],
function(C, D)
  local out;
  out := HomomorphismDigraphsFinder(C,
                                    D,
                                    fail,
                                    [],
                                    1,
                                    fail,
                                    false,
                                    DigraphVertices(D),
                                    [],
                                    DigraphVertexColors(C),
                                    DigraphVertexColors(D),
                                    DigraphWelshPowellOrder(C));
  if IsEmpty(out) then
    return fail;
  fi;
  return out[1];
end);

InstallMethod(DigraphHomomorphism,
"for a vertex colored digraph and a digraph",
[IsVertexColoredDigraph, IsDigraph], ReturnFail);

InstallMethod(DigraphHomomorphism,
"for a digraph and a vertex colored digraph",
[IsDigraph, IsVertexColoredDigraph], ReturnFail);

InstallMethod(HomomorphismsDigraphsRepresentatives,
"for a vertex colored digraph and a vertex colored digraph",
[IsVertexColoredDigraph, IsVertexColoredDigraph],
function(C, D)
  if IsIsomorphicDigraph(C, D) then
    return AsTransformation(IsomorphismDigraphs(C, D));
  fi;
  return HomomorphismDigraphsFinder(C,
                                    D,
                                    fail,
                                    [],
                                    infinity,
                                    fail,
                                    false,
                                    DigraphVertices(D),
                                    [],
                                    DigraphVertexColors(C),
                                    DigraphVertexColors(D));
end);

InstallMethod(HomomorphismsDigraphsRepresentatives,
"for a vertex colored digraph and a digraph",
[IsVertexColoredDigraph, IsDigraph], ReturnFail);

InstallMethod(HomomorphismsDigraphsRepresentatives,
"for a digraph and a vertex colored digraph",
[IsDigraph, IsVertexColoredDigraph], ReturnFail);

InstallMethod(HomomorphismsDigraphs,
"for a vertex colored digraph and a digraph",
[IsVertexColoredDigraph, IsDigraph], ReturnFail);

InstallMethod(HomomorphismsDigraphs,
"for a digraph and a vertex colored digraph",
[IsDigraph, IsVertexColoredDigraph], ReturnFail);

################################################################################
# INJECTIVE HOMOMORPHISMS

# Finds a single injective homomorphism of gr1 into gr2

InstallMethod(DigraphMonomorphism, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(D1, D2)
  local out;
  IsValidDigraph(D1, D2);
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
  IsValidDigraph(D1, D2);
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

# Finds the set of all monomorphisms from D1 to D2

InstallMethod(MonomorphismsDigraphs, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(D1, D2)
  local hom, aut;
  IsValidDigraph(D1, D2);
  hom := MonomorphismsDigraphsRepresentatives(D1, D2);
  D2 := DigraphCopyIfMutable(D2);
  aut := List(AutomorphismGroup(DigraphRemoveAllMultipleEdges(D2)),
              AsTransformation);
  return Union(List(aut, x -> hom * x));
end);

InstallMethod(DigraphMonomorphism,
"for a vertex colored digraph and a vertex colored digraph",
[IsVertexColoredDigraph, IsVertexColoredDigraph],
function(gr1, gr2)
  local out;
  if IsIsomorphicDigraph(gr1, gr2) then
    return AsTransformation(IsomorphismDigraphs(gr1, gr2));
  fi;
  out := HomomorphismDigraphsFinder(gr1, gr2, fail, [], 1,
                                    DigraphNrVertices(gr1), true,
                                    DigraphVertices(gr2), [],
                                    DigraphVertexColors(gr1),
                                    DigraphVertexColors(gr2));
  if IsEmpty(out) then
    return fail;
  fi;
  return out[1];
end);

InstallMethod(DigraphMonomorphism,
"for a vertex colored digraph and a digraph",
[IsVertexColoredDigraph, IsDigraph], ReturnFail);

InstallMethod(DigraphMonomorphism,
"for a digraph and a vertex colored digraph",
[IsDigraph, IsVertexColoredDigraph], ReturnFail);

InstallMethod(MonomorphismsDigraphsRepresentatives,
"for a vertex colored digraph and a vertex colored digraph",
[IsVertexColoredDigraph, IsVertexColoredDigraph],
function(C, D)
  if IsIsomorphicDigraph(C, D) then
    return AsTransformation(IsomorphismDigraphs(C, D));
  fi;
  return HomomorphismDigraphsFinder(C,
                                    D,
                                    fail,
                                    [],
                                    infinity,
                                    DigraphNrVertices(C),
                                    true,
                                    DigraphVertices(D),
                                    [],
                                    DigraphVertexColors(C),
                                    DigraphVertexColors(D));
end);

InstallMethod(MonomorphismsDigraphsRepresentatives,
"for a vertex colored digraph and a digraph",
[IsVertexColoredDigraph, IsDigraph], ReturnFail);

InstallMethod(MonomorphismsDigraphsRepresentatives,
"for a digraph and a vertex colored digraph",
[IsDigraph, IsVertexColoredDigraph], ReturnFail);

InstallMethod(MonomorphismsDigraphs,
"for a vertex colored digraph and a digraph",
[IsVertexColoredDigraph, IsDigraph], ReturnFail);

InstallMethod(MonomorphismsDigraphs,
"for a digraph and a vertex colored digraph",
[IsDigraph, IsVertexColoredDigraph], ReturnFail);

################################################################################
# SURJECTIVE HOMOMORPHISMS

# Finds a single epimorphism from D1 onto D2

InstallMethod(DigraphEpimorphism, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(D1, D2)
  local out;
  IsValidDigraph(D1, D2);
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
  IsValidDigraph(D1, D2);
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
function(D1, D2)
  local hom, aut;
  IsValidDigraph(D1, D2);
  hom := EpimorphismsDigraphsRepresentatives(D1, D2);
  aut := List(AutomorphismGroup(DigraphRemoveAllMultipleEdges(D2)),
              AsTransformation);
  return Union(List(aut, x -> hom * x));
end);

InstallMethod(DigraphEpimorphism,
"for a vertex colored digraph and a vertex colored digraph",
[IsVertexColoredDigraph, IsVertexColoredDigraph],
function(C, D)
  local out;
  if IsIsomorphicDigraph(C, D) then
    return AsTransformation(IsomorphismDigraphs(C, D));
  fi;
  out := HomomorphismDigraphsFinder(C,
                                    D,
                                    fail,
                                    [],
                                    1,
                                    DigraphNrVertices(D),
                                    false,
                                    DigraphVertices(D),
                                    [],
                                    DigraphVertexColors(C),
                                    DigraphVertexColors(D));

  if IsEmpty(out) then
    return fail;
  fi;
  return out[1];
end);

InstallMethod(DigraphEpimorphism,
"for a vertex colored digraph and a digraph",
[IsVertexColoredDigraph, IsDigraph], ReturnFail);

InstallMethod(DigraphEpimorphism,
"for a digraph and a vertex colored digraph",
[IsDigraph, IsVertexColoredDigraph], ReturnFail);

InstallMethod(EpimorphismsDigraphsRepresentatives,
"for a vertex colored digraph and a vertex colored digraph",
[IsVertexColoredDigraph, IsVertexColoredDigraph],
function(C, D)
  if IsIsomorphicDigraph(C, D) then
    return AsTransformation(IsomorphismDigraphs(C, D));
  fi;
  return HomomorphismDigraphsFinder(C,
                                    D,
                                    fail,
                                    [],
                                    infinity,
                                    DigraphNrVertices(D),
                                    false,
                                    DigraphVertices(D),
                                    [],
                                    DigraphVertexColors(C),
                                    DigraphVertexColors(D));
end);

InstallMethod(EpimorphismsDigraphsRepresentatives,
"for a vertex colored digraph and a digraph",
[IsVertexColoredDigraph, IsDigraph], ReturnFail);

InstallMethod(EpimorphismsDigraphsRepresentatives,
"for a digraph and a vertex colored digraph",
[IsDigraph, IsVertexColoredDigraph], ReturnFail);

InstallMethod(EpimorphismsDigraphs,
"for a vertex colored digraph and a digraph",
[IsVertexColoredDigraph, IsDigraph], ReturnFail);

InstallMethod(EpimorphismsDigraphs,
"for a digraph and a vertex colored digraph",
[IsDigraph, IsVertexColoredDigraph], ReturnFail);

################################################################################
# Embeddings
################################################################################

InstallMethod(DigraphEmbedding, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(D1, D2)
  local out;
  IsValidDigraph(D1, D2);
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
  IsValidDigraph(D1, D2);
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
function(D1, D2)
  local hom, aut;
  IsValidDigraph(D1, D2);
  hom := EmbeddingsDigraphsRepresentatives(D1, D2);
  D2 := DigraphCopyIfMutable(D2);
  aut := List(AutomorphismGroup(DigraphRemoveAllMultipleEdges(D2)),
              AsTransformation);
  return Union(List(aut, x -> hom * x));
end);

InstallMethod(DigraphEmbedding,
"for a vertex colored digraph and a digraph",
[IsVertexColoredDigraph, IsDigraph], ReturnFail);

InstallMethod(DigraphEmbedding,
"for a digraph and a vertex colored digraph",
[IsDigraph, IsVertexColoredDigraph], ReturnFail);

########################################################################
# IsDigraphHomo/Epi/.../morphism
########################################################################

InstallMethod(IsDigraphHomomorphism, "for a dense digraph, digraph, and perm",
[IsDenseDigraphRep, IsDigraph, IsPerm],
function(src, ran, x)
  local i, j;
  IsValidDigraph(src, ran);
  if IsMultiDigraph(src) or IsMultiDigraph(ran) then
    ErrorNoReturn("the 1st and 2nd arguments <src> and <ran> must be digraphs",
                  " with no multiple edges,");
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
"for a dense digraph, digraph, and transformation",
[IsDenseDigraphRep, IsDigraph, IsTransformation],
function(src, ran, x)
  local i, j;
  IsValidDigraph(src, ran);
  if IsMultiDigraph(src) or IsMultiDigraph(ran) then
    ErrorNoReturn("the 1st and 2nd arguments <src> and <ran> must be digraphs",
                  " with no multiple edges,");
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
function(D, x)
  IsValidDigraph(D);
  return IsDigraphHomomorphism(D, D, x);
end);

InstallMethod(IsDigraphEpimorphism, "for digraph, digraph, and transformation",
[IsDigraph, IsDigraph, IsTransformation],
function(src, ran, x)
  IsValidDigraph(src, ran);
  return IsDigraphHomomorphism(src, ran, x)
    and OnSets(DigraphVertices(src), x) = DigraphVertices(ran);
end);

InstallMethod(IsDigraphEpimorphism, "for digraph, digraph, and perm",
[IsDigraph, IsDigraph, IsPerm],
function(src, ran, x)
  IsValidDigraph(src, ran);
  return IsDigraphHomomorphism(src, ran, x)
    and OnSets(DigraphVertices(src), x) = DigraphVertices(ran);
end);

InstallMethod(IsDigraphMonomorphism,
"for digraph, digraph, and transformation",
[IsDigraph, IsDigraph, IsTransformation],
function(src, ran, x)
  IsValidDigraph(src, ran);
  return IsDigraphHomomorphism(src, ran, x)
    and IsInjectiveListTrans(DigraphVertices(src), x);
end);

InstallMethod(IsDigraphMonomorphism, "for digraph, digraph, and perm",
[IsDigraph, IsDigraph, IsPerm], IsDigraphHomomorphism);

InstallMethod(IsDigraphEmbedding,
"for digraph, dense digraph, and transformation",
[IsDigraph, IsDenseDigraphRep, IsTransformation],
function(src, ran, x)
  local y, induced, i, j;
  IsValidDigraph(src, ran);
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

InstallMethod(IsDigraphEmbedding, "for digraph, dense digraph, and perm",
[IsDigraph, IsDenseDigraphRep, IsPerm],
function(src, ran, x)
  local y, induced, i, j;
  IsValidDigraph(src, ran);
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

InstallMethod(IsDigraphColouring, "for a dense digraph and a list",
[IsDenseDigraphRep, IsHomogeneousList],
function(D, colours)
  local n, out, v, w;
  IsValidDigraph(D);
  n := DigraphNrVertices(D);
  if Length(colours) <> n or ForAny(colours, x -> not IsPosInt(x)) then
    return false;
  fi;
  out := OutNeighbours(D);
  for v in DigraphVertices(D) do
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
function(D, t)
  local n;
  IsValidDigraph(D);
  n := DigraphNrVertices(D);
  return IsDigraphColouring(D, ImageListOfTransformation(t, n));
end);
