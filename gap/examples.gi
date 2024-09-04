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
function(_, n)
  if n < 0 then
    ErrorNoReturn("the argument <n> must be a non-negative integer,");
  fi;
  return ConvertToMutableDigraphNC(List([1 .. n], x -> []));
end);

InstallMethod(EmptyDigraphCons, "for IsImmutableDigraph and an integer",
[IsImmutableDigraph, IsInt],
function(_, n)
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
function(_, m, n)
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
function(_, m, n)
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
function(_, list)
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
function(_, list)
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
function(_, n)
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
function(_, n)
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
function(_, n)
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
function(_, n)
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
function(_, n)
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
function(_, n)
  local D;
  D := MakeImmutable(CycleDigraphCons(IsMutableDigraph, n));
  SetIsAcyclicDigraph(D, false);
  SetIsCycleDigraph(D, true);
  SetIsEmptyDigraph(D, false);
  SetIsMultiDigraph(D, false);
  SetDigraphNrEdges(D, n);
  SetIsTournament(D, n = 3);
  SetIsTransitiveDigraph(D, n = 1);
  SetAutomorphismGroup(D, CyclicGroup(IsPermGroup, n));
  SetDigraphHasLoops(D, n = 1);
  SetIsBipartiteDigraph(D, n mod 2 = 0);
  if n > 1 then
    SetChromaticNumber(D, 2 + (n mod 2));
  fi;
  return D;
end);

InstallMethod(CycleDigraph, "for a function and a positive integer",
[IsFunction, IsPosInt], CycleDigraphCons);

InstallMethod(CycleDigraph, "for a positive integer", [IsPosInt],
n -> CycleDigraphCons(IsImmutableDigraph, n));

InstallMethod(JohnsonDigraphCons,
"for IsMutableDigraph and two integers",
[IsMutableDigraph, IsInt, IsInt],
function(_, n, k)
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
function(_, n, k)
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
function(_)
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
_ -> MakeImmutable(PetersenGraphCons(IsMutableDigraph)));

InstallMethod(PetersenGraph, "for a function", [IsFunction],
PetersenGraphCons);

InstallMethod(PetersenGraph, [], {} -> PetersenGraphCons(IsImmutableDigraph));

InstallMethod(GeneralisedPetersenGraphCons,
"for IsMutableDigraph, positive integer, integer",
[IsMutableDigraph, IsPosInt, IsInt],
function(filt, n, k)
  local D, i;
  if k < 0 then
    ErrorNoReturn("the argument <k> must be a non-negative integer,");
  elif k > n / 2 then
    ErrorNoReturn("the argument <k> must be less than or equal to <n> / 2,");
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
"for IsImmutableDigraph, positive integer, int",
[IsImmutableDigraph, IsPosInt, IsInt],
function(_, n, k)
  local D;
  D := MakeImmutable(GeneralisedPetersenGraphCons(IsMutableDigraph, n, k));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  return D;
end);

InstallMethod(GeneralisedPetersenGraph,
"for a function, positive integer, integer", [IsFunction, IsPosInt, IsInt],
GeneralisedPetersenGraphCons);

InstallMethod(GeneralisedPetersenGraph, "for a positive integer and integer",
[IsPosInt, IsInt],
{n, k} -> GeneralisedPetersenGraphCons(IsImmutableDigraph, n, k));

InstallMethod(LollipopGraphCons,
"for IsMutableDigraph and two positive integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(_, m, n)
  local D;
  D := DigraphDisjointUnion(CompleteDigraph(IsMutableDigraph, m),
  DigraphSymmetricClosure(ChainDigraph(IsMutableDigraph, n)));
  DigraphAddEdges(D, [[m, m + 1], [m + 1, m]]);
  return D;
end);

InstallMethod(LollipopGraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(_, m, n)
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

# This function constructs an n by k square grid graph.

InstallMethod(SquareGridGraphCons,
"for IsMutableDigraph and two positive integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(_, n, k)
  local D1, D2;
  D1 := DigraphSymmetricClosure(ChainDigraph(IsMutableDigraph, n));
  D2 := DigraphSymmetricClosure(ChainDigraph(IsMutableDigraph, k));
  return DigraphCartesianProduct(D1, D2);
end);

InstallMethod(SquareGridGraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(_, n, k)
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
function(_, n, k)
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
function(_, n, k)
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

InstallMethod(StarGraphCons, "for IsMutableDigraph and a positive integer",
[IsMutableDigraph, IsPosInt],
function(_, k)
  if k = 1 then
    return EmptyDigraph(IsMutable, 1);
  fi;
  return CompleteBipartiteDigraph(IsMutableDigraph, 1, k - 1);
end);

InstallMethod(StarGraph, "for a function and a positive integer",
[IsFunction, IsPosInt],
StarGraphCons);

InstallMethod(StarGraph, "for integer", [IsPosInt],
{k} -> StarGraphCons(IsImmutableDigraph, k));

InstallMethod(StarGraphCons,
"for IsImmutableDigraph and a positive integer",
[IsImmutableDigraph, IsPosInt],
function(_, k)
  local D;
  D := MakeImmutable(StarGraph(IsMutableDigraph, k));
  SetIsMultiDigraph(D, false);
  SetIsEmptyDigraph(D, k = 1);
  SetIsCompleteBipartiteDigraph(D, k > 1);
  return D;
end);

InstallMethod(KingsGraphCons,
"for IsMutableDigraph and two positive integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(_, n, k)
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
function(_, n, k)
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

InstallMethod(QueensGraphCons,
"for IsMutableDigraph and two integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(_, m, n)
  local D1, D2, labels;
  D1 := RooksGraphCons(IsMutableDigraph, m, n);
  D2 := BishopsGraphCons(IsMutableDigraph, m, n);
  labels := DigraphVertexLabels(D1);
  DigraphEdgeUnion(D1, D2);
  SetDigraphVertexLabels(D1, labels);
  return D1;
end);

InstallMethod(QueensGraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(_, m, n)
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

InstallMethod(RooksGraphCons,
"for IsMutableDigraph and two positive integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(_, m, n)
  local D1, D2;
  D1 := CompleteDigraph(IsMutableDigraph, m);
  D2 := CompleteDigraph(n);
  return DigraphCartesianProduct(D1, D2);
end);

InstallMethod(RooksGraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(_, m, n)
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

InstallMethod(BishopsGraphCons,
"for IsMutableDigraph, a string and two positive integers",
[IsMutableDigraph, IsString, IsPosInt, IsPosInt],
function(_, color, m, n)
  local both, dark, nr, D1, D2, upL, inc, step, labels, v, not_final_row, i, j,
        is_dark_square, range;

  if not color in ["dark", "light", "both"] then
    DError(["the argument <color> must be {}, {}, or {}"],
            "\"dark\"", "\"light\"", "\"both\"");
  fi;

  # Set up booleans for whether to include dark and/or light squares
  both  := color = "both";
  dark  := both or color = "dark";

  # Set up two empty digraphs to hold the differently oriented diagonal edges
  # "both" => return a digraph with all m * n vertices, else return only half
  if both then
    nr := m * n;
  else
    nr := EuclideanQuotient(m * n, 2);
    if dark and IsOddInt(m) and IsOddInt(n) then
      nr := nr + 1;
    fi;
  fi;
  D1 := EmptyDigraph(IsMutableDigraph, nr);  # bottom left/top right diagonal
  D2 := EmptyDigraph(IsMutableDigraph, nr);  # bottom right/top left diagonal

  # Set up a function for computing the increments from a vertex to its top-left
  # and top-right neighbours, based on the current position in the grid.
  if both then
    upL := {v, j, is_dark_square} -> v + m - 1;
    inc := 2;
  else
    if IsOddInt(m) then
      step := EuclideanQuotient(m - 1, 2);
      upL := {v, j, is_dark_square} -> v + step;
    else
      step := m / 2;
      upL := function(v, j, is_dark_square)
        if IsOddInt(j) = is_dark_square then
          return v + step - 1;
        else
          return v + step;
        fi;
      end;
    fi;
    inc := 1;
  fi;

  labels := [];
  v := 0;
  for j in [1 .. n] do
    not_final_row := j < n;
    is_dark_square := IsOddInt(j);
    for i in [1 .. m] do
      # Decide whether the square [i, j] appears in the digraph
      if both or (dark = is_dark_square) then
        Add(labels, [i, j]);
        v := v + 1;
        if not_final_row then  # Add edges from v to its neighbours in next row
          range := upL(v, j, is_dark_square);
          if i > 1 then
            DigraphAddEdge(D2, v, range);        # Diagonally up+left
          fi;
          if i < m then
            DigraphAddEdge(D1, v, range + inc);  # Diagonally up+right
          fi;
        fi;
      fi;
      is_dark_square := not is_dark_square;
    od;
  od;
  Assert(0, v = nr);

  DigraphTransitiveClosure(D1);
  DigraphTransitiveClosure(D2);
  DigraphEdgeUnion(D1, D2);
  SetDigraphVertexLabels(D1, labels);
  return DigraphSymmetricClosure(D1);
end);

InstallMethod(BishopsGraphCons,
"for IsImmutableDigraph, a string and two positive integers",
[IsImmutableDigraph, IsString, IsPosInt, IsPosInt],
function(_, color, m, n)
  local D;
  D := MakeImmutable(BishopsGraphCons(IsMutableDigraph, color, m, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsConnectedDigraph(D, color <> "both" and (m > 1 or n > 1));
  return D;
end);

InstallMethod(BishopsGraph,
"for a function, a string and two positive integers",
[IsFunction, IsString, IsPosInt, IsPosInt],
BishopsGraphCons);

InstallMethod(BishopsGraph, "for a string and two positive integers",
[IsString, IsPosInt, IsPosInt],
{color, m, n} -> BishopsGraphCons(IsImmutableDigraph, color, m, n));

InstallMethod(BishopsGraphCons,
"for IsMutableDigraph and two positive integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
{_, m, n} -> BishopsGraphCons(IsMutableDigraph, "both", m, n));

InstallMethod(BishopsGraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(_, m, n)
  local D;
  D := MakeImmutable(BishopsGraphCons(IsMutableDigraph, "both", m, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsConnectedDigraph(D, m * n = 1);
  return D;
end);

InstallMethod(BishopsGraph,
"for a function and two positive integers",
[IsFunction, IsPosInt, IsPosInt],
BishopsGraphCons);

InstallMethod(BishopsGraph, "for two positive integers",
[IsPosInt, IsPosInt],
{m, n} -> BishopsGraphCons(IsImmutableDigraph, m, n));

InstallMethod(KnightsGraphCons,
"for IsMutableDigraph and two positive integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(_, m, n)
  local D, moves, labels, v, r, s, range, j, i, move;

  D := EmptyDigraph(IsMutableDigraph, m * n);
  moves := [[2, 1], [-2, 1], [1, 2], [-1, 2]];
  labels := [];
  v := 0;
  for j in [1 .. n] do
    for i in [1 .. m] do
      Add(labels, [i, j]);  # Considering moves up from [i,j] or down to [i,j]
      v := v + 1;           # Square [i,j] <-> vertex v
      for move in moves do
        r := i + move[1];
        s := j + move[2];
        if r in [1 .. m] and s <= n then  # Does the move leave us on the board?
          range := (s - 1) * m + r;
          DigraphAddEdge(D, v, range);
          DigraphAddEdge(D, range, v);
        fi;
      od;
    od;
  od;
  SetDigraphVertexLabels(D, labels);
  return D;
end);

InstallMethod(KnightsGraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(_, m, n)
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
function(_, n)
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
function(_, n)
  local D;
  D := MakeImmutable(HaarGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsVertexTransitive(D, true);
  SetIsBipartiteDigraph(D, true);
  SetIsCompleteDigraph(D, n = 1);
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
function(_, m, n)
  local D, j, list;
  if n = 1 then
    ErrorNoReturn("The second argument must be an integer",
    " greater than one");
  fi;
  D := EmptyDigraph(IsMutable, 1);
  list := Concatenation([D], ListWithIdenticalEntries(m, StarGraph(n)));
  DigraphDisjointUnion(list);  # changes <D> in place
  for j in [0 .. (m - 1)] do
    DigraphAddEdges(D, [[1, (j * n + 3)], [(j * n + 3), 1]]);
  od;
  return D;
end);

InstallMethod(BananaTreeCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(_, m, n)
  local D;
  D := MakeImmutable(BananaTreeCons(IsMutableDigraph, m, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsUndirectedTree(D, true);
  return D;
end);

InstallMethod(BananaTree, "for a function and two positive integers",
[IsPosInt, IsPosInt],
{m, n} -> BananaTreeCons(IsImmutableDigraph, m, n));

InstallMethod(BananaTree, "for a function and two positive integers",
[IsFunction, IsPosInt, IsPosInt],
{filt, m, n} -> BananaTreeCons(filt, m, n));

InstallMethod(TadpoleGraphCons,
"for IsMutableDigraph and two positive integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(_, m, n)
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

InstallMethod(TadpoleGraph, "for a function and two positive integers",
[IsFunction, IsPosInt, IsPosInt],
TadpoleGraphCons);

InstallMethod(TadpoleGraph, "for two positive integers", [IsPosInt, IsPosInt],
{m, n} -> TadpoleGraphCons(IsImmutableDigraph, m, n));

InstallMethod(TadpoleGraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(_, m, n)
  local D;
  D := MakeImmutable(TadpoleGraph(IsMutableDigraph, m, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  return D;
end);

InstallMethod(BookGraphCons,
"for IsMutableDigraph and one positive integer",
[IsMutableDigraph, IsPosInt],
{filt, m} -> StackedBookGraph(filt, m, 2));

InstallMethod(BookGraph, "for a function and a positive integer",
[IsFunction, IsPosInt], BookGraphCons);

InstallMethod(BookGraph, "for a positive integer", [IsPosInt],
m -> BookGraphCons(IsImmutableDigraph, m));

InstallMethod(BookGraphCons,
"for IsImmutableDigraph and a positive integer",
[IsImmutableDigraph, IsPosInt],
function(_, m)
  local D;
  D := MakeImmutable(BookGraph(IsMutableDigraph, m));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsBipartiteDigraph(D, true);
  return D;
end);

InstallMethod(StackedBookGraphCons,
"for IsMutableDigraph and two positive integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(_, m, n)
  local book;
  book := DigraphSymmetricClosure(ChainDigraph(IsMutable, n));
  return DigraphCartesianProduct(book, StarGraph(IsMutable, m + 1));
end);

InstallMethod(StackedBookGraph, "for a function and two positive integers",
[IsFunction, IsPosInt, IsPosInt],
StackedBookGraphCons);

InstallMethod(StackedBookGraph, "for two positive integers",
[IsPosInt, IsPosInt],
{m, n} -> StackedBookGraphCons(IsImmutableDigraph, m, n));

InstallMethod(StackedBookGraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(_, m, n)
  local D;
  D := MakeImmutable(StackedBookGraph(IsMutableDigraph, m, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsBipartiteDigraph(D, true);
  return D;
end);

InstallMethod(BinaryTreeCons,
"for IsMutableDigraph and positive integer",
[IsMutableDigraph, IsPosInt],
function(_, depth)
  local D, x, i, j;
  D := [[]];
  for i in [1 .. depth - 1] do
    for j in [1 .. 2 ^ i] do
      x := DIGRAPHS_BlistNumber(j, i){[2 .. i]};
      Add(D, [DIGRAPHS_NumberBlist(x) + (2 ^ (i - 1)) - 1]);
    od;
  od;
  return Digraph(IsMutableDigraph, D);
end);

InstallMethod(BinaryTreeCons,
"for IsImmutableDigraph and positive integer",
[IsImmutableDigraph, IsPosInt],
function(_, depth)
  local D;
  D := BinaryTreeCons(IsMutableDigraph, depth);
  MakeImmutable(D);
  return D;
end);

InstallMethod(BinaryTree, "for a positive integer", [IsPosInt],
depth -> BinaryTreeCons(IsImmutableDigraph, depth));

InstallMethod(BinaryTree, "for a function and a positive integer",
[IsFunction, IsPosInt], BinaryTreeCons);

InstallMethod(AndrasfaiGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsPosInt],
function(_, n)
  local js;
  js := List([0 .. (n - 1)], x -> (3 * x) + 1);
  return CirculantGraph(IsMutableDigraph, (3 * n) - 1, js);
end);

InstallMethod(AndrasfaiGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsPosInt],
function(_, n)
  local D;
  D := MakeImmutable(AndrasfaiGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsUndirectedTree(D, false);
  SetIsRegularDigraph(D, true);
  SetIsVertexTransitive(D, true);
  SetIsHamiltonianDigraph(D, true);
  SetIsBiconnectedDigraph(D, true);
  return D;
end);

InstallMethod(AndrasfaiGraph, "for an integer", [IsPosInt],
n -> AndrasfaiGraphCons(IsImmutableDigraph, n));

InstallMethod(AndrasfaiGraph, "for a function and an integer",
[IsFunction, IsPosInt], AndrasfaiGraphCons);

InstallMethod(BinomialTreeGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsPosInt],
function(_, n)
  local bits, is2n, verts, D, rep, pos, parent, parVert, i;
  bits := Log(n, 2);
  is2n := IsEvenInt(n) and IsPrimePowerInt(n);
  if not is2n then
    bits := bits + 1;
  fi;
  verts := List(Tuples([0, 1], bits){[1 .. n]},
                x -> x{List([1 .. bits], y -> bits - y + 1)});
  D := Digraph(IsMutableDigraph, []);
  DigraphAddVertices(D, n);
  for i in [2 .. n] do  # 1 is the root vertex
    rep := StructuralCopy(verts[i]);
    pos := Position(rep, 1);
    parent := rep;
    parent[pos] := 0;
    parVert := Position(verts, parent);
    DigraphAddEdge(D, i, parVert);
  od;

  return DigraphSymmetricClosure(DigraphRemoveAllMultipleEdges(D));
end);

InstallMethod(BinomialTreeGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsPosInt],
function(_, n)
  local D;
  D := MakeImmutable(BinomialTreeGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsEmptyDigraph(D, n = 1);
  SetIsUndirectedTree(D, true);
  return D;
end);

InstallMethod(BinomialTreeGraph, "for an integer", [IsPosInt],
n -> BinomialTreeGraphCons(IsImmutableDigraph, n));

InstallMethod(BinomialTreeGraph, "for a function and an integer",
[IsFunction, IsPosInt], BinomialTreeGraphCons);

InstallMethod(BondyGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsInt],
function(_, n)
  if n < 0 then
    ErrorNoReturn("the argument <n> must be a non-negative integer,");
  fi;
  return GeneralisedPetersenGraph(IsMutableDigraph, 3 * (2 * n + 1) + 2, 2);
end);

InstallMethod(BondyGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsInt],
function(_, n)
  local D;
  D := MakeImmutable(BondyGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsHamiltonianDigraph(D, false);
  return D;
end);

InstallMethod(BondyGraph, "for an integer", [IsInt],
n -> BondyGraphCons(IsImmutableDigraph, n));

InstallMethod(BondyGraph, "for a function and an integer",
[IsFunction, IsInt], BondyGraphCons);

InstallMethod(CirculantGraphCons, "for IsMutableDigraph, an integer and a list",
[IsMutableDigraph, IsPosInt, IsList],
function(_, n, par)
  local D, i, j;
  if (n < 2) or (not ForAll(par, x -> IsInt(x) and x in [1 .. n])) then
    ErrorNoReturn("arguments must be an integer <n> greater ",
                  "than 1 and a list of integers between 1 and n,");
  fi;
  D := Digraph(IsMutableDigraph, []);
  DigraphAddVertices(D, n);
  for i in [1 .. n] do
    for j in par do
      if (i - j) mod n = 0 then
        DigraphAddEdge(D, i, n);
      else
        DigraphAddEdge(D, i, (i - j) mod n);
      fi;
      if (i + j) mod n = 0 then
        DigraphAddEdge(D, i, n);
      else
        DigraphAddEdge(D, i, (i + j) mod n);
      fi;
    od;
  od;
  return DigraphRemoveAllMultipleEdges(DigraphSymmetricClosure(D));
end);

InstallMethod(CirculantGraphCons,
"for IsImmutableDigraph, integer, list of integers",
[IsImmutableDigraph, IsPosInt, IsList],
function(_, n, par)
  local D;
  D := MakeImmutable(CirculantGraphCons(IsMutableDigraph, n, par));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsUndirectedTree(D, false);
  SetIsRegularDigraph(D, true);
  SetIsVertexTransitive(D, true);
  SetIsHamiltonianDigraph(D, true);
  SetIsBiconnectedDigraph(D, true);
  return D;
end);

InstallMethod(CirculantGraph, "for an integer and a list", [IsPosInt, IsList],
{n, par} -> CirculantGraphCons(IsImmutableDigraph, n, par));

InstallMethod(CirculantGraph, "for a function and an integer",
[IsFunction, IsPosInt, IsList], CirculantGraphCons);

InstallMethod(CycleGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsPosInt],
function(filt, n)
  if n < 3 then
    ErrorNoReturn("the argument <n> must be an integer greater than 2,");
  fi;
  return DigraphSymmetricClosure(CycleDigraph(filt, n));
end);

InstallMethod(CycleGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsPosInt],
function(_, n)
  local D;
  D := MakeImmutable(CycleGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  return D;
end);

InstallMethod(CycleGraph, "for an integer", [IsPosInt],
n -> CycleGraphCons(IsImmutableDigraph, n));

InstallMethod(CycleGraph, "for a function and an integer",
[IsFunction, IsPosInt], CycleGraphCons);

InstallMethod(GearGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsPosInt],
function(_, n)
  local D, i, central;
  if n < 3 then
    ErrorNoReturn("the argument <n> must be an integer greater than 2,");
  fi;
  central := 2 * n + 1;
  D := CycleGraph(IsMutableDigraph, central - 1);
  DigraphAddVertex(D);
  for i in [1 .. n] do
    DigraphAddEdge(D, 2 * i, central);
    DigraphAddEdge(D, central, 2 * i);
  od;
  return D;
end);

InstallMethod(GearGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsPosInt],
function(_, n)
  local D;
  D := MakeImmutable(GearGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  return D;
end);

InstallMethod(GearGraph, "for an integer", [IsPosInt],
n -> GearGraphCons(IsImmutableDigraph, n));

InstallMethod(GearGraph, "for a function and an integer",
[IsFunction, IsPosInt], GearGraphCons);

InstallMethod(HalvedCubeGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsPosInt],
function(_, n)
  local D, tuples, vertices, i, j;
  tuples := Tuples([0, 1], n);
  vertices := List([1 .. (2 ^ (n - 1))], x -> []);
  j := 1;
  for i in [1 .. Length(tuples)] do
    if Sum(tuples[i]) mod 2 = 0 then
      vertices[j] := tuples[i];
      j := j + 1;
    fi;
  od;
  D := EmptyDigraph(IsMutableDigraph, Length(vertices));
  for i in [1 .. Length(vertices) - 1] do
    for j in [i + 1 .. Length(vertices)] do
      if SizeBlist(List([1 .. Length(vertices[i])],
          x -> vertices[i][x] <> vertices[j][x])) = 2 then
        DigraphAddEdge(D, i, j);
        DigraphAddEdge(D, j, i);
      fi;
    od;
  od;
  return D;
end);

InstallMethod(HalvedCubeGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsPosInt],
function(_, n)
  local D;
  D := MakeImmutable(HalvedCubeGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsEmptyDigraph(D, n = 1);
  SetIsDistanceRegularDigraph(D, true);
  SetIsHamiltonianDigraph(D, true);
  return D;
end);

InstallMethod(HalvedCubeGraph, "for an integer", [IsPosInt],
n -> HalvedCubeGraphCons(IsImmutableDigraph, n));

InstallMethod(HalvedCubeGraph, "for a function and an integer",
[IsFunction, IsPosInt], HalvedCubeGraphCons);

InstallMethod(HanoiGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsPosInt],
function(_, n)
  local e, D, nrVert, prevNrVert, anchor1, anchor2, anchor3, i;
  D := Digraph(IsMutableDigraph, []);
  nrVert := 3 ^ n;
  DigraphAddVertices(D, nrVert);
  e := [[1, 2], [2, 3], [3, 1]];
  # Anchors correspond to the top, bottom left and bottom right node of the
  # current graph.
  anchor1 := 1;
  anchor2 := 2;
  anchor3 := 3;
  prevNrVert := 1;
  # Starting from the triangle graph G := C_3, iteratively triplicate G, and
  # connect each copy using their anchors.
  for i in [2 .. n] do
    prevNrVert := prevNrVert * 3;
    Append(e, Concatenation(e + prevNrVert, e + (2 * prevNrVert)));
    Add(e, [anchor2, anchor1 + prevNrVert]);
    Add(e, [anchor3, anchor1 + (2 * prevNrVert)]);
    Add(e, [anchor3 + prevNrVert, anchor2 + (2 * prevNrVert)]);
    anchor2 := anchor2 + prevNrVert;
    anchor3 := anchor3 + (2 * prevNrVert);
  od;
  DigraphAddEdges(D, e);

  return DigraphSymmetricClosure(D);
end);

InstallMethod(HanoiGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsPosInt],
function(_, n)
  local D;
  D := MakeImmutable(HanoiGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsPlanarDigraph(D, true);
  SetIsHamiltonianDigraph(D, true);
  return D;
end);

InstallMethod(HanoiGraph, "for an integer", [IsPosInt],
n -> HanoiGraphCons(IsImmutableDigraph, n));

InstallMethod(HanoiGraph, "for a function and an integer",
[IsFunction, IsPosInt], HanoiGraphCons);

InstallMethod(HelmGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsPosInt],
function(_, n)
  local D;
  if n < 3 then
    ErrorNoReturn("the argument <n> must be an integer greater than 2,");
  fi;
  D := WheelGraph(IsMutableDigraph, n + 1);
  DigraphAddVertices(D, n);
  DigraphAddEdges(D, List([1 .. n], x -> [x, x + n + 1]));
  DigraphSymmetricClosure(D);
  return D;
end);

InstallMethod(HelmGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsPosInt],
function(_, n)
  local D;
  D := MakeImmutable(HelmGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  return D;
end);

InstallMethod(HelmGraph, "for an integer", [IsPosInt],
n -> HelmGraphCons(IsImmutableDigraph, n));

InstallMethod(HelmGraph, "for a function and an integer",
[IsFunction, IsPosInt], HelmGraphCons);

InstallMethod(HypercubeGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsInt],
function(_, n)
  local D;
  D := MakeImmutable(HypercubeGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsEmptyDigraph(D, n = 0);
  SetIsHamiltonianDigraph(D, true);
  SetIsDistanceRegularDigraph(D, true);
  SetIsBipartiteDigraph(D, true);
  return D;
end);

InstallMethod(HypercubeGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsInt],
function(_, n)
  local D, vertices, i, j;
  if n < 0 then
    ErrorNoReturn("the argument <n> must be a non-negative integer,");
  fi;
  vertices := Tuples([0, 1], n);
  D := EmptyDigraph(IsMutableDigraph, Length(vertices));
  for i in [1 .. Length(vertices) - 1] do
    for j in [i + 1 .. Length(vertices)] do
      if SizeBlist(List([1 .. Length(vertices[i])],
          x -> vertices[i][x] <> vertices[j][x])) = 1 then
        DigraphAddEdge(D, i, j);
        DigraphAddEdge(D, j, i);
      fi;
    od;
  od;
  return D;
end);

InstallMethod(HypercubeGraph, "for an integer", [IsInt],
n -> HypercubeGraphCons(IsImmutableDigraph, n));

InstallMethod(HypercubeGraph, "for a function and an integer",
[IsFunction, IsInt], HypercubeGraphCons);

InstallMethod(KellerGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsInt],
function(_, n)
  local D, vertices, i, j;
  if n < 0 then
    ErrorNoReturn("the argument <n> must be a non-negative integer,");
  fi;
  vertices := Tuples([0, 1, 2, 3], n);
  D := Digraph(IsMutableDigraph, []);
  DigraphAddVertices(D, Length(vertices));
  for i in [1 .. Length(vertices) - 1] do
    for j in [i + 1 .. Length(vertices)] do
      if SizeBlist(List([1 .. Length(vertices[i])],
          x -> vertices[i][x] <> vertices[j][x])) > 1 and
          SizeBlist(List([1 .. Length(vertices[i])],
          x -> AbsInt(vertices[i][x] - vertices[j][x]) mod 4 = 2)) > 0 then
        DigraphAddEdge(D, i, j);
        DigraphAddEdge(D, j, i);
      fi;
    od;
  od;
  return D;
end);

InstallMethod(KellerGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsInt],
function(_, n)
  local D;
  D := MakeImmutable(KellerGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  if n > 1 then
    SetChromaticNumber(D, 2 ^ n);
    SetIsHamiltonianDigraph(D, true);
  else
    SetIsEmptyDigraph(D, true);
  fi;
  return D;
end);

InstallMethod(KellerGraph, "for an integer", [IsInt],
n -> KellerGraphCons(IsImmutableDigraph, n));

InstallMethod(KellerGraph, "for a function and an integer",
[IsFunction, IsInt], KellerGraphCons);

InstallMethod(KneserGraphCons, "for IsMutableDigraph and two integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(_, n, k)
  local D, vertices, i, j;
  if n < k then
    ErrorNoReturn("argument <n> must be greater than or equal to argument <k>,");
  fi;
  vertices := Combinations([1 .. n], k);
  D := EmptyDigraph(IsMutableDigraph, Length(vertices));
  for i in [1 .. Length(vertices) - 1] do
    for j in [i + 1 .. Length(vertices)] do
      if Length(Intersection(vertices[i], vertices[j])) = 0 then
        DigraphAddEdge(D, i, j);
        DigraphAddEdge(D, j, i);
      fi;
    od;
  od;
  return D;
end);

InstallMethod(KneserGraphCons,
"for IsImmutableDigraph, integer, integer",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(_, n, k)
  local D;
  D := MakeImmutable(KneserGraphCons(IsMutableDigraph, n, k));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsRegularDigraph(D, true);
  SetIsVertexTransitive(D, true);
  SetIsEdgeTransitive(D, true);
  if n >= 2 * k then
    SetChromaticNumber(D, n - 2 * k + 2);
  else
    SetChromaticNumber(D, 1);
    SetIsEmptyDigraph(D, true);
  fi;
  if Float(n) >= ((3 + 5 ^ 0.5) / 2) * Float(k) + 1 then
    SetIsHamiltonianDigraph(D, true);
  fi;
  SetCliqueNumber(D, Int(n / k));
  return D;
end);

InstallMethod(KneserGraph, "for two integers", [IsPosInt, IsPosInt],
{n, k} -> KneserGraphCons(IsImmutableDigraph, n, k));

InstallMethod(KneserGraph, "for a function and two integers",
[IsFunction, IsPosInt, IsPosInt], KneserGraphCons);

InstallMethod(LindgrenSousselierGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsPosInt],
function(_, n)
  local D, central, i, threei;
  central := 6 * n + 4;
  D := CycleGraph(IsMutableDigraph, central - 1);
  DigraphAddVertex(D);
  for i in [0 .. (2 * n)] do
    threei := 3 * i;
    DigraphAddEdge(D, central, threei + 1);
    DigraphAddEdge(D, threei + 1, central);
    if i <> 2 * n then
      DigraphAddEdge(D, 2 + threei, 6 + threei);
      DigraphAddEdge(D, 6 + threei, 2 + threei);
    fi;
  od;
  DigraphAddEdge(D, central - 2, 3);
  DigraphAddEdge(D, 3, central - 2);
  return D;
end);

InstallMethod(LindgrenSousselierGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsPosInt],
function(_, n)
  local D;
  D := MakeImmutable(LindgrenSousselierGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsHamiltonianDigraph(D, false);
  return D;
end);

InstallMethod(LindgrenSousselierGraph, "for an integer", [IsPosInt],
n -> LindgrenSousselierGraphCons(IsImmutableDigraph, n));

InstallMethod(LindgrenSousselierGraph, "for a function and an integer",
[IsFunction, IsPosInt], LindgrenSousselierGraphCons);

InstallMethod(MobiusLadderGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsPosInt],
function(_, n)
  local D, i;
  if n < 4 then
    ErrorNoReturn("the argument <n> must be an integer equal to 4 or more,");
  fi;
  D := CycleGraph(IsMutableDigraph, 2 * n);
  for i in [1 .. n] do
    DigraphAddEdge(D, i, i + n);
    DigraphAddEdge(D, i + n, i);
  od;
  return DigraphSymmetricClosure(D);
end);

InstallMethod(MobiusLadderGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsPosInt],
function(_, n)
  local D;
  D := MakeImmutable(MobiusLadderGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  return D;
end);

InstallMethod(MobiusLadderGraph, "for an integer", [IsPosInt],
n -> MobiusLadderGraphCons(IsImmutableDigraph, n));

InstallMethod(MobiusLadderGraph, "for a function and an integer",
[IsFunction, IsPosInt], MobiusLadderGraphCons);

InstallMethod(MycielskiGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsPosInt],
function(_, n)
  local D, i;
  if n < 2 then
    ErrorNoReturn("the argument <n> must be an integer greater than 1,");
  fi;
  D := Digraph(IsMutableDigraph, []);
  DigraphAddVertices(D, 2);
  DigraphAddEdges(D, [[1, 2], [2, 1]]);
  for i in [3 .. n] do
    D := DigraphMycielskian(D);
  od;
  return D;
end);

InstallMethod(MycielskiGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsPosInt],
function(_, n)
  local D;
  D := MakeImmutable(MycielskiGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetChromaticNumber(D, n);
  SetCliqueNumber(D, 2);
  SetIsHamiltonianDigraph(D, true);
  return D;
end);

InstallMethod(MycielskiGraph, "for an integer", [IsPosInt],
n -> MycielskiGraphCons(IsImmutableDigraph, n));

InstallMethod(MycielskiGraph, "for a function and an integer",
[IsFunction, IsPosInt], MycielskiGraphCons);

InstallMethod(OddGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsInt],
function(_, n)
  if n < 1 then
    ErrorNoReturn("the argument <n> must be an integer greater than 0,");
  fi;
  return KneserGraph(IsMutableDigraph, 2 * n - 1, n - 1);
end);

InstallMethod(OddGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsInt],
function(_, n)
  local D;
  D := MakeImmutable(OddGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsVertexTransitive(D, true);
  SetIsEdgeTransitive(D, true);
  SetIsRegularDigraph(D, true);
  SetIsDistanceRegularDigraph(D, true);
  SetChromaticNumber(D, 3);
  return D;
end);

InstallMethod(OddGraph, "for an integer", [IsInt],
n -> OddGraphCons(IsImmutableDigraph, n));

InstallMethod(OddGraph, "for a function and an integer",
[IsFunction, IsInt], OddGraphCons);

InstallMethod(PathGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsPosInt],
{_, n} -> DigraphSymmetricClosure(ChainDigraph(IsMutableDigraph, n)));

InstallMethod(PathGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsPosInt],
function(_, n)
  local D;
  D := MakeImmutable(PathGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsUndirectedTree(D, true);
  SetIsEmptyDigraph(D, n = 1);
  return D;
end);

InstallMethod(PathGraph, "for an integer", [IsPosInt],
n -> PathGraphCons(IsImmutableDigraph, n));

InstallMethod(PathGraph, "for a function and an integer",
[IsFunction, IsPosInt], PathGraphCons);

InstallMethod(PermutationStarGraphCons, "for IsMutableDigraph and two integers",
[IsMutableDigraph, IsPosInt, IsInt],
function(_, n, k)
  local D, permList, vertices, bList, pos, i, j;
  if k < 0 then
    ErrorNoReturn("the arguments <n> and <k> must be integers, ",
                  "with n greater than 0 and k non-negative,");
  fi;
  if k > n then
    Error("the argument <n> must be greater than or equal to <k>,");
  fi;
  permList := PermutationsList([1 .. n]);
  vertices := Unique(List(permList, x -> List([1 .. k], y -> x[y])));
  D := Digraph(IsMutableDigraph, []);
  DigraphAddVertices(D, Length(vertices));
  for i in [1 .. Length(vertices) - 1] do
    for j in [i + 1 .. Length(vertices)] do
      bList := List([1 .. Length(vertices[i])],
        x -> vertices[i][x] <> vertices[j][x]);
      pos := Positions(bList, true);
      if bList[1] then
        if (SizeBlist(bList) = 2 and
            vertices[j][pos[2]] = vertices[i][pos[1]] and
            vertices[j][pos[1]] = vertices[i][pos[2]]) or
            (SizeBlist(bList) = 1 and (not vertices[j][1] in vertices[i])) then
          DigraphAddEdge(D, i, j);
          DigraphAddEdge(D, j, i);
        fi;
      fi;
    od;
  od;
  return D;
end);

InstallMethod(PermutationStarGraphCons,
"for IsImmutableDigraph, integer, integer",
[IsImmutableDigraph, IsPosInt, IsInt],
function(_, n, k)
  local D;
  D := MakeImmutable(PermutationStarGraphCons(IsMutableDigraph, n, k));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsRegularDigraph(D, true);
  SetIsVertexTransitive(D, true);
  if k <= Int(n / 2) then
    SetDigraphDiameter(D, 2 * k - 1);
  else
    SetDigraphDiameter(D, Int((n - 1) / 2) + k);
  fi;
  return D;
end);

InstallMethod(PermutationStarGraph, "for two integers", [IsPosInt, IsInt],
{n, k} -> PermutationStarGraphCons(IsImmutableDigraph, n, k));

InstallMethod(PermutationStarGraph, "for a function and two integers",
[IsFunction, IsPosInt, IsInt], PermutationStarGraphCons);

InstallMethod(PrismGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsPosInt],
function(_, n)
  if n < 3 then
    ErrorNoReturn("the argument <n> must be an integer equal to 3 or more,");
  else
    return GeneralisedPetersenGraph(IsMutableDigraph, n, 1);
  fi;
end);

InstallMethod(PrismGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsPosInt],
function(_, n)
  local D;
  D := MakeImmutable(PrismGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  return D;
end);

InstallMethod(PrismGraph, "for an integer", [IsPosInt],
n -> PrismGraphCons(IsImmutableDigraph, n));

InstallMethod(PrismGraph, "for a function and an integer",
[IsFunction, IsPosInt], PrismGraphCons);

InstallMethod(StackedPrismGraphCons, "for IsMutableDigraph and two integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(_, n, k)
  if n < 3 then
    ErrorNoReturn("the arguments <n> and <k> must be integers, ",
                  "with <n> greater than 2 and <k> greater than 0,");
  fi;
  return DigraphCartesianProduct(CycleGraph(IsMutableDigraph, n),
          PathGraph(IsMutableDigraph, k));
end);

InstallMethod(StackedPrismGraphCons,
"for IsImmutableDigraph, integer, integer",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(_, n, k)
  local D;
  D := MakeImmutable(StackedPrismGraphCons(IsMutableDigraph, n, k));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  return D;
end);

InstallMethod(StackedPrismGraph, "for two integers", [IsPosInt, IsPosInt],
{n, k} -> StackedPrismGraphCons(IsImmutableDigraph, n, k));

InstallMethod(StackedPrismGraph, "for a function and two integers",
[IsFunction, IsPosInt, IsPosInt], StackedPrismGraphCons);

InstallMethod(WalshHadamardGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsPosInt],
function(_, n)
  local H_2, H_n, i, D, j, sideHn;
  H_2 := [[1, 1],
          [1, -1]];
  H_n := [[1]];
  if n > 1 then
    for i in [2 .. n] do
      H_n := KroneckerProduct(H_2, H_n);
    od;
  fi;
  sideHn := Length(H_n);
  D := EmptyDigraph(IsMutableDigraph, 4 * sideHn);
  for i in [1 .. sideHn] do
    for j in [1 .. sideHn] do
      if H_n[i][j] = 1 then
        DigraphAddEdge(D, i, 2 * sideHn + j);
        DigraphAddEdge(D, sideHn + i, 3 * sideHn + j);
      else
        DigraphAddEdge(D, i, 3 * sideHn + j);
        DigraphAddEdge(D, sideHn + i, 2 * sideHn + j);
      fi;
    od;
  od;
  return DigraphSymmetricClosure(D);
end);

InstallMethod(WalshHadamardGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsPosInt],
function(_, n)
  local D;
  D := MakeImmutable(WalshHadamardGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsDistanceRegularDigraph(D, true);
  return D;
end);

InstallMethod(WalshHadamardGraph, "for an integer", [IsPosInt],
n -> WalshHadamardGraphCons(IsImmutableDigraph, n));

InstallMethod(WalshHadamardGraph, "for a function and an integer",
[IsFunction, IsPosInt], WalshHadamardGraphCons);

InstallMethod(WebGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsPosInt],
function(_, n)
  local D, i;
  if n < 3 then
    ErrorNoReturn("the argument <n> must be an integer greater than 2,");
  fi;
  D := StackedPrismGraph(IsMutableDigraph, n, 3);
  for i in [1 .. (n - 1)] do
    D := DigraphRemoveEdge(D, i, i + 1);
    D := DigraphRemoveEdge(D, i + 1, i);
  od;
  D := DigraphRemoveEdge(D, n, 1);
  return DigraphRemoveEdge(D, 1, n);
end);

InstallMethod(WebGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsPosInt],
function(_, n)
  local D;
  D := MakeImmutable(WebGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  return D;
end);

InstallMethod(WebGraph, "for an integer", [IsPosInt],
n -> WebGraphCons(IsImmutableDigraph, n));

InstallMethod(WebGraph, "for a function and an integer",
[IsFunction, IsPosInt], WebGraphCons);

InstallMethod(WheelGraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsPosInt],
function(_, n)
  local D;
  if n < 4 then
    ErrorNoReturn("the argument <n> must be an integer greater than 3,");
  fi;
  D := CycleGraph(IsMutableDigraph, n - 1);
  DigraphAddVertex(D, 1);
  DigraphAddEdges(D, List([1 .. n - 1], x -> [x, n]));
  DigraphAddEdges(D, List([1 .. n - 1], x -> [n, x]));
  return D;
end);

InstallMethod(WheelGraphCons,
"for IsImmutableDigraph, integer",
[IsImmutableDigraph, IsPosInt],
function(_, n)
  local D;
  D := MakeImmutable(WheelGraphCons(IsMutableDigraph, n));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetIsHamiltonianDigraph(D, true);
  SetIsPlanarDigraph(D, true);
  if (n mod 2) = 1 then
    SetChromaticNumber(D, 3);
  else
    SetChromaticNumber(D, 4);
  fi;
  return D;
end);

InstallMethod(WheelGraph, "for an integer", [IsPosInt],
n -> WheelGraphCons(IsImmutableDigraph, n));

InstallMethod(WheelGraph, "for a function and an integer",
[IsFunction, IsPosInt], WheelGraphCons);

InstallMethod(WindmillGraphCons, "for IsMutableDigraph and two integers",
[IsMutableDigraph, IsPosInt, IsPosInt],
function(_, n, m)
  local D, i, K, nrVert;
  if m < 2 or n < 2 then
    ErrorNoReturn("the arguments <n> and <m> must be integers greater than 1,");
  fi;
  D := Digraph(IsMutableDigraph, []);
  K := CompleteDigraph(n - 1);
  nrVert := 1 + DigraphNrVertices(K) * m;
  DigraphAddVertices(D, nrVert);
  for i in [0 .. (m - 1)] do
    DigraphAddEdges(D, DigraphEdges(K) + (i * DigraphNrVertices(K)));
  od;
  for i in [1 .. (DigraphNrVertices(D) - 1)] do
    DigraphAddEdge(D, i, nrVert);
    DigraphAddEdge(D, nrVert, i);
  od;
  return D;
end);

InstallMethod(WindmillGraphCons,
"for IsImmutableDigraph, integer, integer",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(_, n, m)
  local D;
  D := MakeImmutable(WindmillGraphCons(IsMutableDigraph, n, m));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  SetChromaticNumber(D, n);
  SetDigraphDiameter(D, 2);
  return D;
end);

InstallMethod(WindmillGraph, "for two integers", [IsPosInt, IsPosInt],
{n, m} -> WindmillGraphCons(IsImmutableDigraph, n, m));

InstallMethod(WindmillGraph, "for a function and two integers",
[IsFunction, IsPosInt, IsPosInt], WindmillGraphCons);
