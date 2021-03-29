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

InstallMethod(BishopsGraphCons,
"for IsMutableDigraph, a string and two positive integers",
[IsMutableDigraph, IsString, IsPosInt, IsPosInt],
function(filt, color, m, n)
  local D, i, multiple, position, upLeft, upRight, downLeft, downRight,
  j, collumn, row, leftBound, rightBound;

  if not (color = "black" or color = "white") then
    ErrorNoReturn("the argument <color> must be either \"black\" or \"white\".");
  fi;

  D := EmptyDigraph(filt, m * n);

  for i in [1 .. m * n] do
    multiple := i mod m = 0;
    if color = "black" and IsOddInt(i) or color = "white" and IsEvenInt(i) then
      collumn := QuoInt(i, m);
      if multiple then
        collumn := collumn - 1;
      fi;

      if not multiple and IsOddInt(collumn) then
        position := (collumn + 1) * m - (i mod m) + 1;
      elif multiple and IsOddInt(collumn) then
        position := collumn * m + 1;
      else
        position := i;
      fi;

      if not position mod m = 0 then
        row := position mod m;
      else
        row := m;
      fi;

      upLeft := position - (m - 1);
      upRight := position + (m + 1);
      downLeft := position - (m + 1);
      downRight := position + (m - 1);

      leftBound := true;
      rightBound := true;

      if not position mod m = 0 then
        for j in [1 .. m - row] do
          if upLeft > 0 then
            DigraphAddEdge(D, [position, upLeft]);
            upLeft := upLeft - (m - 1);
          else
            leftBound := false;
          fi;
          if upRight <= m * n then
            DigraphAddEdge(D, [position, upRight]);
            upRight := upRight + (m + 1);
          else
            rightBound := false;
          fi;
          if not (leftBound or rightBound) then
            break;
          fi;
        od;
      fi;

      leftBound := true;
      rightBound := true;

      if not row = 1 then
        for j in [1 .. row - 1] do
          if downLeft > 0 then
            DigraphAddEdge(D, [position, downLeft]);
            downLeft := downLeft - (m + 1);
          else
            leftBound := false;
          fi;
          if downRight <= m * n then
            DigraphAddEdge(D, [position, downRight]);
            downRight := downRight + (m - 1);
          else
            rightBound := false;
          fi;
          if not (leftBound or rightBound) then
            break;
          fi;
        od;
      fi;
    fi;
  od;
  return D;
end);

InstallMethod(BishopsGraphCons,
"for IsImmutableDigraph, a string and two positive integers",
[IsImmutableDigraph, IsString, IsPosInt, IsPosInt],
function(filt, color, m, n)
  local D;
  D := MakeImmutable(BishopsGraphCons(IsMutableDigraph, color, m, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsConnectedDigraph(D, m * n = 1);
  return D;
end);

InstallMethod(BishopsGraph,
"for a function, a string and two positive integers",
[IsFunction, IsString, IsPosInt, IsPosInt],
BishopsGraphCons);

InstallMethod(BishopsGraph, "for a string and two positive integers",
[IsString, IsPosInt, IsPosInt],
{color, m, n} -> BishopsGraphCons(IsImmutableDigraph, color, m, n));

InstallMethod(RooksGraphCons,
"for IsMutableDigraph and two positive integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(filt, m, n)
  local D, completeD1, completeD2, cartesianProduct;
  completeD1 := CompleteDigraph(m);
  completeD2 := CompleteDigraph(n);
  cartesianProduct := DigraphCartesianProduct(completeD1, completeD2);
  D := DigraphMutableCopy(cartesianProduct);
  return D;
end);

InstallMethod(RooksGraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(filt, m, n)
  local D;
  D := MakeImmutable(RooksGraphCons(IsMutableDigraph, m, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsConnectedDigraph(D, true);
  SetIsRegularDigraph(D, true);
  SetIsPlanarDigraph(D, m + n < 6);
  return D;
end);

InstallMethod(RooksGraph,
"for a function and two positive integers",
[IsFunction, IsPosInt, IsPosInt],
RooksGraphCons);

InstallMethod(RooksGraph, "for two positive integers",
[IsPosInt, IsPosInt],
{m, n} -> RooksGraphCons(IsImmutableDigraph, m, n));

InstallMethod(QueensGraphCons,
"for IsMutableDigraph and two integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(filt, n, k)
  local D, D1, D2, D3;
  D1 := RooksGraphCons(filt, n, k);
  D2 := BishopsGraphCons(filt, "black", n, k);
  D3 := BishopsGraphCons(filt, "white", n, k);
  D := DigraphEdgeUnion(D1, D2, D3);
  return D;
end);

InstallMethod(QueensGraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(filt, m, n)
  local D;
  D := MakeImmutable(QueensGraphCons(IsMutableDigraph, m, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsConnectedDigraph(D, true);
  return D;
end);

InstallMethod(QueensGraph,
"for a function and two positive integers",
[IsFunction, IsPosInt, IsPosInt],
QueensGraphCons);

InstallMethod(QueensGraph, "for two positive integers",
[IsPosInt, IsPosInt],
{m, n} -> QueensGraphCons(IsImmutableDigraph, m, n));