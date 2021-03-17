#############################################################################
##
##  examples.gi
##  Copyright (C) 2019                                     Murray T. Whyte
##                                                       James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# This file contains constructions of certain types of digraphs from parameters

InstallMethod(EmptyDigraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsInt],
function(filt, n)
  if n < 0 then
    ErrorNoReturn("the argument <n> must be a non-negative integer,");
  fi;
  return ConvertToMutableDigraphNC(List([1 .. n], x -> []));
end);

InstallMethod(EmptyDigraphCons, "for IsImmutableDigraph and an integer",
[IsImmutableDigraph, IsInt],
function(filt, n)
  local D;
  if n < 0 then
    ErrorNoReturn("the argument <n> must be a non-negative integer,");
  fi;
  D := MakeImmutable(EmptyDigraph(IsMutableDigraph, n));
  SetIsEmptyDigraph(D, true);
  SetIsMultiDigraph(D, false);
  SetAutomorphismGroup(D, SymmetricGroup(n));
  return D;
end);

InstallMethod(EmptyDigraph, "for an integer", [IsInt],
n -> EmptyDigraphCons(IsImmutableDigraph, n));

InstallMethod(EmptyDigraph, "for a function and an integer",
[IsFunction, IsInt], EmptyDigraphCons);

InstallMethod(CompleteBipartiteDigraphCons,
"for IsMutableDigraph and two positive integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(filt, m, n)
  local src, ran, count, k, i, j;
  src := EmptyPlist(2 * m * n);
  ran := EmptyPlist(2 * m * n);
  count := 0;
  for i in [1 .. m] do
    for j in [1 .. n] do
      count := count + 1;
      src[count] := i;
      ran[count] := m + j;
      k := (m * n) + ((j - 1) * m) + i;  # Ensures that src is sorted
      src[k] := m + j;
      ran[k] := i;
    od;
  od;
  return DigraphNC(IsMutableDigraph, rec(DigraphNrVertices := m + n,
                                         DigraphSource     := src,
                                         DigraphRange      := ran));
end);

InstallMethod(CompleteBipartiteDigraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(filt, m, n)
  local D, aut;
  D := MakeImmutable(CompleteBipartiteDigraph(IsMutableDigraph, m, n));
  SetIsSymmetricDigraph(D, true);
  SetDigraphNrEdges(D, 2 * m * n);
  SetIsCompleteBipartiteDigraph(D, true);
  if m = n then
    aut := WreathProduct(SymmetricGroup(m), Group((1, 2)));
  else
    aut := DirectProduct(SymmetricGroup(m), SymmetricGroup(n));
  fi;
  SetAutomorphismGroup(D, aut);
  return D;
end);

InstallMethod(CompleteBipartiteDigraph, "for two positive integers",
[IsPosInt, IsPosInt],
{m, n} -> CompleteBipartiteDigraph(IsImmutableDigraph, m, n));

InstallMethod(CompleteBipartiteDigraph,
"for a function and two positive integers",
[IsFunction, IsPosInt, IsPosInt],
CompleteBipartiteDigraphCons);

# For input list <sizes> of length nr_parts, CompleteMultipartiteDigraph
# returns the complete multipartite digraph containing parts 1, 2, ..., n
# of orders sizes[1], sizes[2], ..., sizes[n], where each vertex is adjacent
# to every other not contained in the same part.

InstallMethod(CompleteMultipartiteDigraphCons,
"for IsMutableDigraph and a list",
[IsMutableDigraph, IsList],
function(filt, list)
  local M, N, out, start, next, i, v;
  if not ForAll(list, IsPosInt) then
    ErrorNoReturn("the argument <list> must be a list of positive ",
                  "integers,");
  fi;

  M := Length(list);
  N := Sum(list);

  if M <= 1 then
    return EmptyDigraph(IsMutableDigraph, N);
  fi;

  out := EmptyPlist(N);
  start := 1;
  for i in [1 .. M] do
    next := Concatenation([1 .. start - 1], [start + list[i] .. N]);
    for v in [start .. start + list[i] - 1] do
      out[v] := next;
    od;
    start := start + list[i];
  od;
  return ConvertToMutableDigraphNC(out);
end);

InstallMethod(CompleteMultipartiteDigraphCons,
"for IsImmutableDigraph and a list",
[IsImmutableDigraph, IsList],
function(filt, list)
  local D;
  D := MakeImmutable(CompleteMultipartiteDigraph(IsMutableDigraph, list));
  SetIsEmptyDigraph(D, Length(list) <= 1);
  SetIsSymmetricDigraph(D, true);
  SetIsCompleteBipartiteDigraph(D, Length(list) = 2);
  SetIsCompleteMultipartiteDigraph(D, Length(list) > 1);
  if Length(list) = 2 then
    SetDigraphBicomponents(D, [[1 .. list[1]], [list[1] + 1 .. Sum(list)]]);
  fi;
  return D;
end);

InstallMethod(CompleteMultipartiteDigraph, "for a list", [IsList],
list -> CompleteMultipartiteDigraphCons(IsImmutableDigraph, list));

InstallMethod(CompleteMultipartiteDigraph, "for a function and a list",
[IsFunction, IsList], CompleteMultipartiteDigraphCons);

InstallMethod(ChainDigraphCons, "for IsMutableDigraph and a positive integer",
[IsMutableDigraph, IsPosInt],
function(filt, n)
  local list, i;
  list := EmptyPlist(n);
  for i in [1 .. n - 1] do
    list[i] := [i + 1];
  od;
  list[n] := [];
  return ConvertToMutableDigraphNC(list);
end);

InstallMethod(ChainDigraphCons,
"for IsImmutableDigraph and a positive integer",
[IsImmutableDigraph, IsPosInt],
function(filt, n)
  local D;
  D := MakeImmutable(ChainDigraphCons(IsMutableDigraph, n));
  SetIsChainDigraph(D, true);
  SetIsTransitiveDigraph(D, n = 2);
  SetDigraphHasLoops(D, false);
  SetIsAcyclicDigraph(D, true);
  SetIsMultiDigraph(D, false);
  SetDigraphNrEdges(D, n - 1);
  SetIsConnectedDigraph(D, true);
  SetIsStronglyConnectedDigraph(D, false);
  SetIsFunctionalDigraph(D, false);
  SetAutomorphismGroup(D, Group(()));
  return D;
end);

InstallMethod(ChainDigraph, "for a function and a positive integer",
[IsFunction, IsPosInt],
ChainDigraphCons);

InstallMethod(ChainDigraph, "for a positive integer", [IsPosInt],
n -> ChainDigraphCons(IsImmutableDigraph, n));

InstallMethod(CompleteDigraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsInt],
function(filt, n)
  local verts, out, i;
  if n < 0 then
    ErrorNoReturn("the argument <n> must be a non-negative integer,");
  elif n = 0 then
    return EmptyDigraph(IsMutableDigraph, 0);
  fi;
  verts := [1 .. n];
  out := EmptyPlist(n);
  for i in verts do
    out[i] := Concatenation([1 .. (i - 1)], [(i + 1) .. n]);
  od;
  return ConvertToMutableDigraphNC(out);
end);

InstallMethod(CompleteDigraphCons, "for IsImmutableDigraph and an integer",
[IsImmutableDigraph, IsInt],
function(filt, n)
  local D;
  D := MakeImmutable(CompleteDigraphCons(IsMutableDigraph, n));
  SetIsEmptyDigraph(D, n <= 1);
  SetIsAcyclicDigraph(D, n <= 1);
  if n > 1 then
    SetIsAntisymmetricDigraph(D, false);
  fi;
  SetIsMultiDigraph(D, false);
  SetIsCompleteDigraph(D, true);
  SetIsCompleteBipartiteDigraph(D, n = 2);
  SetIsCompleteMultipartiteDigraph(D, n > 1);
  SetAutomorphismGroup(D, SymmetricGroup(n));
  return D;
end);

InstallMethod(CompleteDigraph, "for a function and an integer",
[IsFunction, IsInt], CompleteDigraphCons);

InstallMethod(CompleteDigraph, "for an integer", [IsInt],
n -> CompleteDigraphCons(IsImmutableDigraph, n));

InstallMethod(CycleDigraphCons, "for IsMutableDigraph and a positive integer",
[IsMutableDigraph, IsPosInt],
function(filt, n)
  local list, i;
  list := EmptyPlist(n);
  for i in [1 .. n - 1] do
    list[i] := [i + 1];
  od;
  list[n] := [1];
  return ConvertToMutableDigraphNC(list);
end);

InstallMethod(CycleDigraphCons,
"for IsImmutableDigraph and a positive integer",
[IsImmutableDigraph, IsPosInt],
function(filt, n)
  local D;
  D := MakeImmutable(CycleDigraphCons(IsMutableDigraph, n));
  if n = 1 then
    SetIsTransitiveDigraph(D, true);
    SetDigraphHasLoops(D, true);
  else
    SetIsTransitiveDigraph(D, false);
    SetDigraphHasLoops(D, false);
  fi;
  SetIsAcyclicDigraph(D, false);
  SetIsCycleDigraph(D, true);
  SetIsEmptyDigraph(D, false);
  SetIsMultiDigraph(D, false);
  SetDigraphNrEdges(D, n);
  SetIsFunctionalDigraph(D, true);
  SetIsStronglyConnectedDigraph(D, true);
  SetAutomorphismGroup(D, CyclicGroup(IsPermGroup, n));
  return D;
end);

InstallMethod(CycleDigraph, "for a function and a positive integer",
[IsFunction, IsPosInt], CycleDigraphCons);

InstallMethod(CycleDigraph, "for a positive integer", [IsPosInt],
n -> CycleDigraphCons(IsImmutableDigraph, n));

InstallMethod(JohnsonDigraphCons,
"for IsMutableDigraph and two integers",
[IsMutableDigraph, IsInt, IsInt],
function(filt, n, k)
  if n < 0 or k < 0 then
    ErrorNoReturn("the arguments <n> and <k> must be ",
                  "non-negative integers,");
  fi;
  return Digraph(IsMutableDigraph,
                 Combinations([1 .. n], k),
                 {u, v} -> Length(Intersection(u, v)) = k - 1);
end);

InstallMethod(JohnsonDigraphCons,
"for IsImmutableDigraph, integer, integer",
[IsImmutableDigraph, IsInt, IsInt],
function(filt, n, k)
  local D;
  D := MakeImmutable(JohnsonDigraphCons(IsMutableDigraph, n, k));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  return D;
end);

InstallMethod(JohnsonDigraph, "for a function, integer, integer",
[IsFunction, IsInt, IsInt],
JohnsonDigraphCons);

InstallMethod(JohnsonDigraph, "for integer, integer", [IsInt, IsInt],
{n, k} -> JohnsonDigraphCons(IsImmutableDigraph, n, k));

InstallMethod(PetersenGraphCons, "for IsMutableDigraph", [IsMutableDigraph],
function(filt)
  local mat;
  mat := [[0, 1, 0, 0, 1, 1, 0, 0, 0, 0],
          [1, 0, 1, 0, 0, 0, 1, 0, 0, 0],
          [0, 1, 0, 1, 0, 0, 0, 1, 0, 0],
          [0, 0, 1, 0, 1, 0, 0, 0, 1, 0],
          [1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
          [1, 0, 0, 0, 0, 0, 0, 1, 1, 0],
          [0, 1, 0, 0, 0, 0, 0, 0, 1, 1],
          [0, 0, 1, 0, 0, 1, 0, 0, 0, 1],
          [0, 0, 0, 1, 0, 1, 1, 0, 0, 0],
          [0, 0, 0, 0, 1, 0, 1, 1, 0, 0]];
  # the above is an adjacency matrix of the Petersen graph
  return DigraphByAdjacencyMatrix(IsMutableDigraph, mat);
end);

InstallMethod(PetersenGraphCons, "for IsImmutableDigraph",
[IsImmutableDigraph],
filt -> MakeImmutable(PetersenGraphCons(IsMutableDigraph)));

InstallMethod(PetersenGraph, "for a function", [IsFunction],
PetersenGraphCons);

InstallMethod(PetersenGraph, [], {} -> PetersenGraphCons(IsImmutableDigraph));

InstallMethod(GeneralisedPetersenGraphCons,
"for IsMutableDigraph and two integers",
[IsMutableDigraph, IsInt, IsInt],
function(filt, n, k)
  local D, i;
  if n < 1 then
    ErrorNoReturn("the argument <n> must be a positive integer,");
  elif k < 0 then
    ErrorNoReturn("the argument <k> must be a non-negative integer,");
  elif k > n / 2 then
    ErrorNoReturn("the argument <k> must be less than <n> / 2,");
  fi;
  D := EmptyDigraph(filt, 2 * n);
  for i in [1 .. n] do
    if i <> n then
      DigraphAddEdge(D, [i, i + 1]);
    else
      DigraphAddEdge(D, [n, 1]);
    fi;
    DigraphAddEdge(D, [i, n + i]);
    if n + i + k <= 2 * n then
      DigraphAddEdge(D, [n + i, n + i + k]);
    else
      DigraphAddEdge(D, [n + i, ((n + i + k) mod n) + n]);
    fi;
  od;
  return DigraphSymmetricClosure(D);
end);

InstallMethod(GeneralisedPetersenGraphCons,
"for IsImmutableDigraph, integer, int",
[IsImmutableDigraph, IsInt, IsInt],
function(filt, n, k)
  local D;
  D := MakeImmutable(GeneralisedPetersenGraphCons(IsMutableDigraph, n, k));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  return D;
end);

InstallMethod(GeneralisedPetersenGraph, "for a function, integer, integer",
[IsFunction, IsInt, IsInt],
GeneralisedPetersenGraphCons);

InstallMethod(GeneralisedPetersenGraph, "for integer, integer", [IsInt, IsInt],
{n, k} -> GeneralisedPetersenGraphCons(IsImmutableDigraph, n, k));

InstallMethod(LollipopGraphCons,
"for IsMutableDigraph and two positive integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(filt, m, n)
  local D;
  D := DigraphDisjointUnion(CompleteDigraph(IsMutableDigraph, m),
  DigraphSymmetricClosure(ChainDigraph(IsMutableDigraph, n)));
  DigraphAddEdges(D, [[m, m + 1], [m + 1, m]]);
  return D;
end);

InstallMethod(LollipopGraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(filt, m, n)
  local D;
  D := MakeImmutable(LollipopGraphCons(IsMutableDigraph, m, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsConnectedDigraph(D, true);
  SetDigraphHasLoops(D, false);
  SetChromaticNumber(D, Maximum(2, m));
  SetCliqueNumber(D, Maximum(2, m));
  if m <= 2 then
    SetDigraphUndirectedGirth(D, infinity);
  else
    SetDigraphUndirectedGirth(D, 3);
  fi;
  return D;
end);

InstallMethod(LollipopGraph, "for two pos int",
[IsPosInt, IsPosInt],
{m, n} -> LollipopGraphCons(IsImmutableDigraph, m, n));

InstallMethod(LollipopGraph, "for a function and two pos int",
[IsFunction, IsPosInt, IsPosInt],
{filt, m, n} -> LollipopGraphCons(filt, m, n));

InstallMethod(KingsGraphCons,
"for IsMutableDigraph and two positive integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(filt, n, k)
  local D, a, b, i, j;
  D := TriangularGridGraph(IsMutableDigraph, n, k);
  for i in [1 .. (k - 1)] do
    for j in [1 .. (n - 1)] do
      a := ((i - 1) * n) + j;
      b := ((i - 1) * n) + j + n + 1;
      DigraphAddEdge(D, a, b);
      DigraphAddEdge(D, b, a);
    od;
  od;
  return D;
end);

InstallMethod(KingsGraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(filt, n, k)
  local D;
  D := MakeImmutable(KingsGraphCons(IsMutableDigraph, n, k));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsConnectedDigraph(D, true);
  SetIsBipartiteDigraph(D, n * k in Difference([n, k], [1]));
  SetIsPlanarDigraph(D, n <= 2 or k <= 2 or n = 3 and k = 3);
  SetDigraphHasLoops(D, false);
  return D;
end);

InstallMethod(KingsGraph, "for a function and two positive integers",
[IsFunction, IsPosInt, IsPosInt],
KingsGraphCons);

InstallMethod(KingsGraph, "two positive integers",
[IsPosInt, IsPosInt],
{n, k} -> KingsGraphCons(IsImmutableDigraph, n, k));

# This function constructs an n by k square grid graph.

InstallMethod(SquareGridGraphCons,
"for IsMutableDigraph and two positive integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(filt, n, k)
  local D1, D2;
  D1 := DigraphSymmetricClosure(ChainDigraph(IsMutableDigraph, n));
  D2 := DigraphSymmetricClosure(ChainDigraph(IsMutableDigraph, k));
  return DigraphCartesianProduct(D1, D2);
end);

InstallMethod(SquareGridGraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(filt, n, k)
  local D;
  D := MakeImmutable(SquareGridGraphCons(IsMutableDigraph, n, k));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsBipartiteDigraph(D, n > 1 or k > 1);
  SetIsPlanarDigraph(D, true);
  SetIsConnectedDigraph(D, true);
  SetDigraphHasLoops(D, false);
  return D;
end);

InstallMethod(SquareGridGraph, "for a function and two positive integers",
[IsFunction, IsPosInt, IsPosInt],
SquareGridGraphCons);

InstallMethod(SquareGridGraph, "for two integers", [IsPosInt, IsPosInt],
{n, k} -> SquareGridGraphCons(IsImmutableDigraph, n, k));

#  This function constructs an n by k triangular grid graph. It is the same as
#  the square grid graph except that it adds diagonal edges.

InstallMethod(TriangularGridGraphCons,
"for IsMutableDigraph and two integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(filt, n, k)
  local D, a, b, i, j;
  D := SquareGridGraph(IsMutableDigraph, n, k);
  for i in [1 .. (k - 1)] do
    for j in [1 .. (n - 1)] do
      a := ((i - 1) * n) + j + 1;
      b := ((i - 1) * n) + j + n;
      DigraphAddEdge(D, a, b);
      DigraphAddEdge(D, b, a);
    od;
  od;
  return D;
end);

InstallMethod(TriangularGridGraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(filt, n, k)
  local D;
  D := MakeImmutable(TriangularGridGraphCons(IsMutableDigraph, n, k));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsBipartiteDigraph(D, n * k in Difference([n, k], [1]));
  SetIsPlanarDigraph(D, true);
  SetIsConnectedDigraph(D, true);
  SetDigraphHasLoops(D, false);
  return D;
end);

InstallMethod(TriangularGridGraph, "for a function and two positive integers",
[IsFunction, IsPosInt, IsPosInt],
TriangularGridGraphCons);

InstallMethod(TriangularGridGraph, "for two positive integers",
[IsPosInt, IsPosInt],
{n, k} -> TriangularGridGraphCons(IsImmutableDigraph, n, k));

InstallMethod(StarDigraphCons, "for IsMutableDigraph and a positive integer",
[IsMutableDigraph, IsPosInt],
function(filt, k)
  local j, graph;
  graph := EmptyDigraph(IsMutable, k);
  for j in [2 .. k] do
    DigraphAddEdges(graph, [[1, j], [j, 1]]);
  od;
  return graph;
end);

InstallMethod(StarDigraph, "for a function and a positive integer",
[IsFunction, IsPosInt],
StarDigraphCons);

InstallMethod(StarDigraph, "for integer", [IsPosInt],
{k} -> StarDigraphCons(IsImmutableDigraph, k));

InstallMethod(StarDigraphCons,
"for IsImmutableDigraph and a positive integer",
[IsImmutableDigraph, IsPosInt],
function(filt, k)
  local D;
  D := MakeImmutable(StarDigraph(IsMutableDigraph, k));
  SetIsMultiDigraph(D, false);
  SetIsEmptyDigraph(D, k = 1);
  SetIsCompleteBipartiteDigraph(D, k > 1);
  return D;
end);

InstallMethod(KnightsGraphCons,
"for IsMutableDigraph and two positive integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(filt, m, n)
  local D, moveOffSets, coordinates, target, i, j, iPos;
  D := EmptyDigraph(IsMutableDigraph, m * n);
  moveOffSets := [[2, 1], [-2, 1], [2, -1], [-2, -1],
  [1, 2], [-1, 2], [1, -2], [-1, -2]];
  coordinates := [];
  for i in [1 .. n] do
    for j in [1 .. m] do
      Add(coordinates, [i, j]);
    od;
  od;
  iPos := 0;
  for i in coordinates do
    iPos := iPos + 1;
    for j in moveOffSets do
      target := [i[1] + j[1], i[2] + j[2]];
      if target[1] in [1 .. n] and target[2] in [1 .. m] then
        DigraphAddEdge(D, [iPos, (target[1] - 1) * m + target[2]]);
      fi;
    od;
  od;
  return D;
end);

InstallMethod(KnightsGraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(filt, m, n)
  local D;
  D := MakeImmutable(KnightsGraphCons(IsMutableDigraph, m, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsConnectedDigraph(D, m > 2 and n > 2 and not (m = 3 and n = 3));
  return D;
end);

InstallMethod(KnightsGraph, "for a function and two positive integers",
[IsFunction, IsPosInt, IsPosInt],
KnightsGraphCons);

InstallMethod(KnightsGraph, "for two positive integers", [IsPosInt, IsPosInt],
{m, n} -> KnightsGraphCons(IsImmutableDigraph, m, n));

InstallMethod(HaarGraphCons,
"for IsMutableDigraph and a positive integer",
[IsMutableDigraph, IsPosInt],
function(filt, n)
  local m, binaryList, D, i, j;
  m := Log(n, 2) + 1;
  binaryList := DIGRAPHS_BlistNumber(n + 1, m);
  D := EmptyDigraph(IsMutableDigraph, 2 * m);

  for i in [1 .. m] do
    for j in [1 .. m] do
      if binaryList[((j - i) mod m) + 1] then
          DigraphAddEdge(D, [i, m + j]);
      fi;
    od;
  od;

  return DigraphSymmetricClosure(D);
end);

InstallMethod(HaarGraphCons,
"for IsImmutableDigraph and a positive integer",
[IsImmutableDigraph, IsPosInt],
function(filt, n)
  local D;
  D := MakeImmutable(HaarGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsRegularDigraph(D, true);
  SetIsVertexTransitive(D, true);
  SetIsBipartiteDigraph(D, true);
  return D;
end);

InstallMethod(HaarGraph, "for a function and a positive integer",
[IsFunction, IsPosInt],
HaarGraphCons);

InstallMethod(HaarGraph, "for a positive integer", [IsPosInt],
{n} -> HaarGraphCons(IsImmutableDigraph, n));

InstallMethod(BananaTreeCons,
  "for IsMutableDigraph and two positive integers",
  [IsMutableDigraph, IsPosInt, IsPosInt],
  function(filt, m, n)
    local D, j, list;
    if n = 1 then
      ErrorNoReturn("The second argument must be an integer",
      " greater than one");
    fi;
    D := EmptyDigraph(IsMutable, 1);
    list := Concatenation([D], ListWithIdenticalEntries(m, StarDigraph(n)));
    DigraphDisjointUnion(list);  # changes <D> in place
    for j in [0 .. (m - 1)] do
      DigraphAddEdges(D, [[1, (j * n + 3)], [(j * n + 3), 1]]);
    od;
    return D;
  end);
  
InstallMethod(BananaTreeCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(filt, m, n)
  local D;
  D := MakeImmutable(BananaTreeCons(IsMutableDigraph, m, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsUndirectedTree(D, true);
  return D;
end);

InstallMethod(BananaTree, "for a function and two pos ints",
[IsPosInt, IsPosInt],
{m, n} -> BananaTreeCons(IsImmutableDigraph, m, n));

InstallMethod(BananaTree, "for a function and two pos ints",
[IsFunction, IsPosInt, IsPosInt],
{filt, m, n} -> BananaTreeCons(filt, m, n));  

InstallMethod(TadpoleDigraphCons, "for IsMutableDigraph and two integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(filt, m, n)
  local tail, graph;
  if m < 3 then
    ErrorNoReturn("the first argument <m> must be an integer greater than 2");
  fi;
  graph := DigraphSymmetricClosure(CycleDigraph(IsMutableDigraph, m));
  tail := DigraphSymmetricClosure(ChainDigraph(IsMutable, n));
  DigraphDisjointUnion(graph, tail);
  DigraphAddEdges(graph, [[m, n + m], [n + m, m]]);
  return graph;
end);

InstallMethod(TadpoleDigraph, "for a function, integer, integer",
[IsFunction, IsInt, IsInt],
TadpoleDigraphCons);

InstallMethod(TadpoleDigraph, "for integer, integer", [IsInt, IsInt],
{m, n} -> TadpoleDigraphCons(IsImmutableDigraph, m, n));

InstallMethod(TadpoleDigraphCons,
"for IsImmutableDigraph, integer, integer",
[IsImmutableDigraph, IsInt, IsInt],
function(filt, m, n)
  local D;
  D := MakeImmutable(TadpoleDigraph(IsMutableDigraph, m, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  return D;
end);