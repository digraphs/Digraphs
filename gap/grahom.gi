#############################################################################
##
##  grahom.gi
##  Copyright (C) 2014-19                                  Julius Jonusas
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
  D := DigraphImmutableCopyIfMutable(D);
  if IsBound(arg[2]) then
    if IsHomogeneousList(arg[2]) then
      colours := arg[2];
      G := AutomorphismGroup(DigraphRemoveAllMultipleEdges(D), colours);
    elif not IsBound(arg[3]) and (IsPosInt(arg[2]) or arg[2] = infinity) then
      # arg[2] is <limit>
      arg[3] := arg[2];
      colours := fail;
      G := AutomorphismGroup(DigraphRemoveAllMultipleEdges(D));
    else
      ErrorNoReturn("the 2nd argument must be a homogenous list,");
    fi;
  else
    if HasGeneratorsOfEndomorphismMonoidAttr(D) then
      return GeneratorsOfEndomorphismMonoidAttr(D);
    fi;
    colours := fail;
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

  if (limit = infinity or Length(gens) < limit_arg) and IsImmutableDigraph(D)
      and colours = fail then
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
  elif HasDigraphGreedyColouring(D) then
    if DigraphGreedyColouring(D) = fail then
      return fail;
    elif RankOfTransformation(DigraphGreedyColouring(D),
                              DigraphNrVertices(D)) = n then
      return DigraphGreedyColouring(D);
    fi;
  fi;

  # Only the null digraph with 0 vertices can be coloured with 0 colours
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
D -> DigraphGreedyColouringNC(D, DigraphWelshPowellOrder(D)));

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
"for a digraph by out-neighbours and a homogeneous list",
[IsDigraphByOutNeighboursRep, IsHomogeneousList],
function(D, order)
  local n, colour, colouring, out, inn, empty, all, available, nr_coloured, v;
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
{D, func} -> DigraphGreedyColouringNC(D, func(D)));

InstallMethod(DigraphWelshPowellOrder, "for a digraph", [IsDigraph],
function(D)
  local order, deg;
  order := [1 .. DigraphNrVertices(D)];
  deg   := ShallowCopy(OutDegrees(D)) + InDegrees(D);
  SortParallel(deg, order, {x, y} -> x > y);
  return order;
end);

InstallMethod(DigraphSmallestLastOrder, "for a digraph", [IsDigraph],
function(D)
  local order, n, deg, v;
  order := [];
  n := DigraphNrVertices(D);
  D := DigraphMutableCopyIfMutable(D);
  while n > 0 do
    deg := ShallowCopy(OutDegrees(D)) + InDegrees(D);
    v := PositionMinimum(deg);
    order[n] := DigraphVertexLabel(D, v);
    D := DigraphRemoveVertex(D, v);
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
function(D1, D2)
  local hom, aut;
  hom := HomomorphismsDigraphsRepresentatives(D1, D2);
  D2 := DigraphMutableCopyIfMutable(D2);
  aut := List(AutomorphismGroup(DigraphRemoveAllMultipleEdges(D2)),
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

# Finds the set of all monomorphisms from D1 to D2

InstallMethod(MonomorphismsDigraphs, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(D1, D2)
  local hom, aut;
  hom := MonomorphismsDigraphsRepresentatives(D1, D2);
  D2 := DigraphMutableCopyIfMutable(D2);
  aut := List(AutomorphismGroup(DigraphRemoveAllMultipleEdges(D2)),
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
function(D1, D2)
  local hom, aut;
  hom := EpimorphismsDigraphsRepresentatives(D1, D2);
  aut := List(AutomorphismGroup(DigraphRemoveAllMultipleEdges(D2)),
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
function(D1, D2)
  local hom, aut;
  hom := EmbeddingsDigraphsRepresentatives(D1, D2);
  D2 := DigraphMutableCopyIfMutable(D2);
  aut := List(AutomorphismGroup(DigraphRemoveAllMultipleEdges(D2)),
              AsTransformation);
  return Union(List(aut, x -> hom * x));
end);

########################################################################
# IsDigraph{Homo/Epi/...}morphism
########################################################################

# Given:
#
# 1) two digraphs <src> and <ran>,
# 2) a transformation <x> mapping the vertices of <src> to <ran>, and
# 3) two lists <cols1> and <cols2> of positive integers defining vertex
#    colourings of <src> and <ran>,
#
# this operation tests whether <x> respects the colouring, i.e. whether for all
# vertices i in <src>, cols[i] = cols[i ^ x].
InstallMethod(DigraphsRespectsColouring,
[IsDigraph, IsDigraph, IsTransformation, IsList, IsList],
function(src, ran, x, cols1, cols2)
  if Maximum(OnTuples(DigraphVertices(src), x)) > DigraphNrVertices(ran) then
    ErrorNoReturn("the third argument <x> must map the vertices of the first ",
                  "argument <src> into the vertices of the second argument ",
                  "<ran>,");
  fi;
  DIGRAPHS_ValidateVertexColouring(DigraphNrVertices(src), cols1);
  DIGRAPHS_ValidateVertexColouring(DigraphNrVertices(ran), cols2);

  return ForAll(DigraphVertices(src), i -> cols1[i] = cols2[i ^ x]);
end);

InstallMethod(DigraphsRespectsColouring,
[IsDigraph, IsDigraph, IsPerm, IsList, IsList],
function(src, ran, x, cols1, cols2)
  return DigraphsRespectsColouring(src, ran, AsTransformation(x), cols1, cols2);
end);

InstallMethod(IsDigraphHomomorphism,
"for a digraph by out-neighbours, a digraph, and a perm",
[IsDigraphByOutNeighboursRep, IsDigraph, IsPerm],
{src, ran, x} -> IsDigraphHomomorphism(src, ran, AsTransformation(x)));

InstallMethod(IsDigraphHomomorphism,
"for a digraph by out-neighbours, a digraph, a perm, and two lists",
[IsDigraphByOutNeighboursRep, IsDigraph, IsPerm, IsList, IsList],
{src, ran, x, c1, c2} ->
IsDigraphHomomorphism(src, ran, AsTransformation(x), c1, c2));

InstallMethod(IsDigraphEndomorphism, "for a digraph and a perm",
[IsDigraph, IsPerm], IsDigraphAutomorphism);

InstallMethod(IsDigraphEndomorphism, "for a digraph and a perm",
[IsDigraph, IsPerm, IsList], IsDigraphAutomorphism);

InstallMethod(IsDigraphHomomorphism,
"for a digraph by out-neighbours, digraph, and transformation",
[IsDigraphByOutNeighboursRep, IsDigraph, IsTransformation],
function(src, ran, x)
  local i, j;
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

InstallMethod(IsDigraphHomomorphism,
"for a digraph by out-neighbours, a digraph, a transformation, and two lists",
[IsDigraphByOutNeighboursRep, IsDigraph, IsTransformation, IsList, IsList],

function(src, ran, x, cols1, cols2)
  return IsDigraphHomomorphism(src, ran, x) and
         DigraphsRespectsColouring(src, ran, x, cols1, cols2);
end);

InstallMethod(IsDigraphEndomorphism, "for a digraph and a transformation",
[IsDigraph, IsTransformation],
{D, x} -> IsDigraphHomomorphism(D, D, x));

InstallMethod(IsDigraphEndomorphism,
"for a digraph, transformation, and a list",
[IsDigraph, IsTransformation, IsList],
{D, x, c} -> IsDigraphHomomorphism(D, D, x, c, c));

InstallMethod(IsDigraphEpimorphism, "for digraph, digraph, and transformation",
[IsDigraph, IsDigraph, IsTransformation],
function(src, ran, x)
  return IsDigraphHomomorphism(src, ran, x)
    and OnSets(DigraphVertices(src), x) = DigraphVertices(ran);
end);

InstallMethod(IsDigraphEpimorphism, "for digraph, digraph, and transformation",
[IsDigraph, IsDigraph, IsTransformation, IsList, IsList],
function(src, ran, x, cols1, cols2)
  return IsDigraphEpimorphism(src, ran, x) and
         DigraphsRespectsColouring(src, ran, x, cols1, cols2);
end);

InstallMethod(IsDigraphEpimorphism, "for digraph, digraph, and perm",
[IsDigraph, IsDigraph, IsPerm],
function(src, ran, x)
  return IsDigraphHomomorphism(src, ran, x)
    and OnSets(DigraphVertices(src), x) = DigraphVertices(ran);
end);

InstallMethod(IsDigraphEpimorphism,
"for digraph, digraph, perm, list, and list",
[IsDigraph, IsDigraph, IsPerm, IsList, IsList],
function(src, ran, x, cols1, cols2)
  return IsDigraphEpimorphism(src, ran, x)
    and DigraphsRespectsColouring(src, ran, x, cols1, cols2);
end);

InstallMethod(IsDigraphMonomorphism,
"for digraph, digraph, and transformation",
[IsDigraph, IsDigraph, IsTransformation],
function(src, ran, x)
  return IsDigraphHomomorphism(src, ran, x)
    and IsInjectiveListTrans(DigraphVertices(src), x);
end);

InstallMethod(IsDigraphMonomorphism,
"for digraph, digraph, transformation, list, list",
[IsDigraph, IsDigraph, IsTransformation, IsList, IsList],
function(src, ran, x, cols1, cols2)
  return IsDigraphMonomorphism(src, ran, x)
    and DigraphsRespectsColouring(src, ran, x, cols1, cols2);
end);

InstallMethod(IsDigraphMonomorphism, "for digraph, digraph, and perm",
[IsDigraph, IsDigraph, IsPerm], IsDigraphHomomorphism);

InstallMethod(IsDigraphMonomorphism, "for digraph, digraph, perm, list, list",
[IsDigraph, IsDigraph, IsPerm, IsList, IsList],
function(src, ran, x, cols1, cols2)
  return IsDigraphHomomorphism(src, ran, x)
    and DigraphsRespectsColouring(src, ran, x, cols1, cols2);
end);

InstallMethod(IsDigraphEmbedding,
"for digraph, digraph by out-neighbours, and transformation",
[IsDigraph, IsDigraphByOutNeighboursRep, IsTransformation],
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

InstallMethod(IsDigraphEmbedding,
"for digraph, digraph by out-neighbours, transformation, list, and list",
[IsDigraph, IsDigraphByOutNeighboursRep, IsTransformation, IsList, IsList],
function(src, ran, x, cols1, cols2)
  return IsDigraphEmbedding(src, ran, x)
    and DigraphsRespectsColouring(src, ran, x, cols1, cols2);
end);

InstallMethod(IsDigraphEmbedding,
"for a digraph, a digraph by out-neighbours, and a perm",
[IsDigraph, IsDigraphByOutNeighboursRep, IsPerm],
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

InstallMethod(IsDigraphEmbedding,
"for a digraph, a digraph by out-neighbours, a perm, a list, and a list",
[IsDigraph, IsDigraphByOutNeighboursRep, IsPerm, IsList, IsList],
function(src, ran, x, cols1, cols2)
  return IsDigraphEmbedding(src, ran, x)
    and DigraphsRespectsColouring(src, ran, x, cols1, cols2);
end);

InstallMethod(IsDigraphColouring, "for a digraph by out-neighbours and a list",
[IsDigraphByOutNeighboursRep, IsHomogeneousList],
function(D, colours)
  local n, out, v, w;
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
  n := DigraphNrVertices(D);
  return IsDigraphColouring(D, ImageListOfTransformation(t, n));
end);

InstallMethod(MaximalCommonSubdigraph, "for a pair of digraphs",
[IsDigraph, IsDigraph],
function(A, B)
  local D1, D2, MPG, nonloops, Clqus, M, l, n, m, embedding1, embedding2, iso;

  D1 := DigraphImmutableCopy(A);
  D2 := DigraphImmutableCopy(B);

  # If the digraphs are isomorphic then we return the first one as the answer
  iso := IsomorphismDigraphs(D1, D2);
  if iso <> fail then
    return [D1, IdentityTransformation, AsTransformation(iso)];
  fi;

  n := DigraphNrVertices(D1);
  m := DigraphNrVertices(D2);

  # The algorithm works as follows: We construct the modular product digraph
  # MPG (see https://en.wikipedia.org/wiki/Modular_product_of_graphs for the
  # undirected version) a maximal partial isomorphism between D1 and D2 is
  # equal to a maximal clique this digraph. We then search for cliques using the
  # DigraphMaximalCliquesReps function.

  MPG := ModularProduct(D1, D2);

  nonloops := Filtered([1 .. n * m], x -> not x in OutNeighbours(MPG)[x]);
  # We find a big clique
  Clqus := DigraphMaximalCliquesReps(MPG, [], nonloops);
  M := 1;
  for l in [1 .. Size(Clqus)] do
    if Size(Clqus[l]) > Size(Clqus[M]) then
      M := l;
    fi;
  od;

  embedding1 := List(Clqus[M], x -> QuoInt(x - 1, m) + 1);
  embedding2 := List(Clqus[M], x -> RemInt(x - 1, m) + 1);
  return [InducedSubdigraph(D1, embedding1),
          Transformation([1 .. Size(embedding1)], embedding1),
          Transformation([1 .. Size(embedding2)], embedding2)];

end);

InstallMethod(MinimalCommonSuperdigraph, "for a pair of digraphs",
[IsDigraph, IsDigraph],
function(D1, D2)
  local out, L, v, e, embfunc, embedding1, embedding2, newvertices;
  L := MaximalCommonSubdigraph(D1, D2);
  L[2] := List([1 .. DigraphNrVertices(L[1])], x -> x ^ L[2]);
  L[3] := List([1 .. DigraphNrVertices(L[1])], x -> x ^ L[3]);
  out := List(OutNeighbours(D1), x -> ShallowCopy(x));
  newvertices := Filtered(DigraphVertices(D2), x -> not x in L[3]);
  embedding1 := [1 .. DigraphNrVertices(D1)];

  embfunc := function(v)
    if v in L[3] then
      return L[2][Position(L[3], v)];
    fi;
    return Position(newvertices, v) + DigraphNrVertices(D1);
  end;
  embedding2 := List(DigraphVertices(D2), embfunc);

  for v in newvertices do
    Add(out, []);
  od;

  for e in DigraphEdges(D2) do
    if (not e[1] in L[3]) or (not e[2] in L[3]) then
       Add(out[embedding2[e[1]]], embedding2[e[2]]);
    fi;
  od;

  return [Digraph(out), Transformation([1 .. Size(embedding1)], embedding1),
                        Transformation([1 .. Size(embedding2)], embedding2)];

end);
