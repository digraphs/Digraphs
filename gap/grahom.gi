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
function(arg...)
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
      ErrorNoReturn("the 2nd argument must be a homogeneous list,");
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
    if DigraphHasNoVertices(D) then
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

InstallMethod(SubdigraphsMonomorphismsRepresentatives,
"for a digraph and a digraph", [IsDigraph, IsDigraph],
function(H, G)
  local GV, HN, map, reps, result, set, rep;

  GV := DigraphVertices(G);
  HN := DigraphNrVertices(H);

  map := HashMap();
  reps := [];

  for set in Combinations(GV, HN) do
    if not set in map then
      Add(reps, set);
      DIGRAPHS_AddOrbitToHashMap(AutomorphismGroup(G), set, map);
    fi;
  od;

  result := [];
  for rep in reps do
    map :=
    HomomorphismDigraphsFinder(H,                   # domain
                               G,                   # range
                               fail,                # hook
                               [],                  # user_param
                               1,                   # max_results
                               HN,                  # hint (i.e. rank)
                               true,                # injective
                               rep,                 # image
                               [],                  # partial_map
                               fail,                # colors1
                               fail,                # colors2
                               DigraphWelshPowellOrder(H),
                               Group(()));
    if Length(map) <> 0 then
      Add(result, map[1]);
    fi;
  od;
  return result;
end);

InstallMethod(SubdigraphsMonomorphisms, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(H, G)
  local ApplyHomomorphismNC, reps, AG, result, sub, o, x, rep, i;

  ApplyHomomorphismNC := function(D1, D2, t)
    local old, new, v, im;
    old := OutNeighbours(D1);
    new := List([1 .. DigraphNrVertices(D2)], x -> []);
    for v in DigraphVertices(D1) do
      im := v ^ t;
      if not IsBound(new[im]) then
        new[im] := [];
      fi;
      Append(new[im], OnTuples(old[v], t));
    od;
    return DigraphNC(new);
  end;

  reps := SubdigraphsMonomorphismsRepresentatives(H, G);
  AG := AutomorphismGroup(G);
  result := [];
  for rep in reps do
    sub := ApplyHomomorphismNC(H, G, rep);
    o   := Enumerate(Orb(AG, sub, OnDigraphs, rec(schreier := true)));
    for i in [1 .. Length(o)] do
      x := EvaluateWord(GeneratorsOfGroup(AG), TraceSchreierTreeForward(o, i));
      Add(result, rep * x);
    od;
  od;
  return result;
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
{src, ran, x, cols1, cols2}
-> DigraphsRespectsColouring(src, ran, AsTransformation(x), cols1, cols2));

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
  elif not IsSubset(DigraphVertices(ran), OnSets(DigraphVertices(src), x)) then
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
  out := List(OutNeighbours(D1), ShallowCopy);
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

InstallMethod(LatticeDigraphEmbedding, "for a pair of digraphs",
[IsDigraph, IsDigraph],
function(L1, L2)
  local join1, meet1, meet2, join2, N1, N2, p, map, conditions, out1, out2,
  in1, in2, mask, defined, not_in_image, FindNextAmong, Recurse;

  p := PermList(Reversed(DigraphWelshPowellOrder(L1)));
  L1 := OnDigraphs(L1, p ^ -1);

  # We compute the join/meet table to avoid having to do this twice if L1 or L2
  # is mutable
  join1 := DigraphJoinTable(L1);
  meet1 := DigraphMeetTable(L1);

  if join1 = fail or meet1 = fail then
    ErrorNoReturn("the 1st argument (a digraph) must be a lattice digraph");
  fi;

  meet2 := DigraphMeetTable(L2);
  join2 := DigraphJoinTable(L2);

  if join2 = fail or meet2 = fail then
    ErrorNoReturn("the 2nd argument (a digraph) must be a lattice digraph");
  fi;

  N1 := DigraphNrVertices(L1);
  N2 := DigraphNrVertices(L2);

  if N2 < N1 then
    return fail;
  fi;

  map        := EmptyPlist(N1);
  conditions := [List([1 .. N1], x -> BlistList([1 .. N2], [1 .. N2]))];

  out1 := BooleanAdjacencyMatrix(L1);
  out2 := BooleanAdjacencyMatrixMutableCopy(L2);

  in1 := TransposedMat(BooleanAdjacencyMatrix(L1));
  in2 := TransposedMatMutable(BooleanAdjacencyMatrixMutableCopy(L2));

  mask := List([1 .. N2], i -> BlistList([1 .. N2], [i]));

  defined      := BlistList([1 .. N1], []);
  not_in_image := BlistList([1 .. N2], [1 .. N2]);

  FindNextAmong := function(among, depth)
    local nr_options, min, next, x;

    next := fail;
    min  := N2 + 1;

    for x in among do
      if not defined[x] then
        nr_options := SizeBlist(IntersectionBlist(conditions[depth][x],
                                                  not_in_image));
        if nr_options = 0 then
          return fail;
        elif nr_options < min then
          min  := nr_options;
          next := x;
        fi;
      fi;
    od;
    return next;
  end;

  Recurse := function(depth, print)
    local next, value, try_next_value, prev, x;

    if depth = N1 + 1 then  # When depth = N1 + 1, we have defined all images
      return true;
    fi;
    # Find the next vertex, i.e. the one with fewest options
    next := FindNextAmong([1 .. N1], depth);
    if next = fail then
      return false;
    fi;

    value := Position(conditions[depth][next], true, 0);
    while value <> fail do
      map[next]             := value;
      defined[next]         := true;
      not_in_image[value]   := false;
      # TODO(later): can we avoid copying the entire "conditions" here, like in
      # the C-code?
      conditions[depth + 1] := StructuralCopy(conditions[depth]);

      # meets and joins map to meets and joins, respectively
      for prev in [1 .. N1] do
        if defined[prev] then
          IntersectBlist(conditions[depth + 1][join1[prev][next]],
                         mask[join2[map[prev]][map[next]]]);
          IntersectBlist(conditions[depth + 1][meet1[prev][next]],
                         mask[meet2[map[prev]][map[next]]]);
        fi;
      od;

      try_next_value := false;
      # If the value map[next] breaks a previously defined image of map,
      # try the next possible value for map[next]
      for x in [1 .. N1] do
        if defined[x] and not conditions[depth + 1][x][map[x]] then
          try_next_value := true;
          break;
        fi;
      od;
      if not try_next_value then
        for x in [1 .. N1] do
          if out1[next][x] then
            IntersectBlist(conditions[depth + 1][x], out2[value]);
          else
            FlipBlist(out2[value]);
            IntersectBlist(conditions[depth + 1][x], out2[value]);
            FlipBlist(out2[value]);
          fi;
          if in1[next][x] then
            IntersectBlist(conditions[depth + 1][x], in2[value]);
          else
            FlipBlist(in2[value]);
            IntersectBlist(conditions[depth + 1][x], in2[value]);
            FlipBlist(in2[value]);
          fi;
        od;
        if Recurse(depth + 1, print) then
          return true;
        fi;
      fi;
      Unbind(conditions[depth + 1]);
      Unbind(map[next]);
      not_in_image[value] := true;
      defined[next]       := false;
      value := Position(conditions[depth][next], true, value);
    od;
    return false;
  end;

  if Recurse(1, false) then
    Append(map, [N1 + 1 .. N2]);
    return p ^ -1 * Transformation(map);
  fi;
  return fail;
end);

InstallMethod(IsLatticeHomomorphism,
"for a transformation and a pair of digraphs",
[IsDigraph, IsDigraph, IsTransformation],
function(L1, L2, map)
  local N1, N2, x, y, meet1, meet2, join1, join2;

  N1 := DigraphNrVertices(L1);
  N2 := DigraphNrVertices(L2);

  if LargestMovedPoint(map) > N1 then
    return false;
  fi;

  # We compute the join/meet table to avoid having to do this twice if L1 or L2
  # is mutable
  join1 := DigraphJoinTable(L1);
  meet1 := DigraphMeetTable(L1);

  if join1 = fail or meet1 = fail then
    ErrorNoReturn("the 1st argument (a digraph) must be a lattice digraph");
  fi;

  join2 := DigraphJoinTable(L2);
  meet2 := DigraphMeetTable(L2);

  if join2 = fail or meet2 = fail then
    ErrorNoReturn("the 2nd argument (a digraph) must be a lattice digraph");
  elif Maximum(ImageSetOfTransformation(map, N1)) > N2 then
    return false;
  fi;
  # The above checks if the <x ^ map> and <y ^ map> entries of
  # meet2 and join2 exist

  # TODO(later): can we avoid checking all joins and meets, i.e. by only
  # checking the join-irreducible nodes or something?
  for x in [1 .. N1] do
    for y in [1 .. N1] do
      if meet2[x ^ map, y ^ map] <> meet1[x, y] ^ map
          or join2[x ^ map, y ^ map] <> join1[x, y] ^ map then
        return false;
      fi;
    od;
  od;
  return true;
end);

InstallMethod(IsLatticeHomomorphism,
"for a digraph, a digraph, and a permutation",
[IsDigraph, IsDigraph, IsPerm],
{L1, L2, perm} -> IsLatticeHomomorphism(L1, L2, AsTransformation(perm)));

InstallMethod(IsLatticeEndomorphism, "for a digraph and a transformation",
[IsDigraph, IsTransformation],
{L, map} -> IsLatticeHomomorphism(L, L, map));

InstallMethod(IsLatticeEndomorphism, "for a digraph and a permutation",
[IsDigraph, IsPerm],
{L, perm} -> IsLatticeHomomorphism(L, L, AsTransformation(perm)));

InstallMethod(IsLatticeEpimorphism,
"for a digraph, a digraph, and a transformation",
[IsDigraph, IsDigraph, IsTransformation],
function(L1, L2, map)
  return IsLatticeHomomorphism(L1, L2, map)
    and OnSets(DigraphVertices(L1), map) = DigraphVertices(L2);
end);

InstallMethod(IsLatticeEpimorphism,
"for a digraph, a digraph, and a permutation",
[IsDigraph, IsDigraph, IsPerm],
function(L1, L2, perm)
  return IsLatticeHomomorphism(L1, L2, AsTransformation(perm))
    and OnSets(DigraphVertices(L1), perm) = DigraphVertices(L2);
end);

InstallMethod(IsLatticeEmbedding,
"for a digraph, a digraph, and a transformation",
[IsDigraph, IsDigraph, IsTransformation],
function(L1, L2, map)
  return IsLatticeHomomorphism(L1, L2, map)
    and IsInjectiveListTrans(DigraphVertices(L1), map);
end);

InstallMethod(IsLatticeEmbedding,
"for a digraph, a digraph, and a permutation",
[IsDigraph, IsDigraph, IsPerm],
{L1, L2, perm} -> IsLatticeHomomorphism(L1, L2, AsTransformation(perm)));
