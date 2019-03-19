#############################################################################
##
##  exmpl.gi
##  Copyright (C) 2019                                     Murray T. Whyte
##                                                       James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallMethod(EmptyDigraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsInt],
function(filt, n)
  if n < 0 then
    ErrorNoReturn("the argument must be a non-negative integer,");
  fi;
  return MutableDigraphNC(List([1 .. n], x -> []));
end);

InstallMethod(EmptyDigraphCons, "for IsImmutableDigraph and an integer",
[IsImmutableDigraph, IsInt],
function(filt, n)
  local D;
  if n < 0 then
    ErrorNoReturn("the argument must be a non-negative integer,");
  fi;
  D := MakeImmutableDigraph(EmptyDigraph(IsMutableDigraph, n));
  SetIsEmptyDigraph(D, true);
  SetIsMultiDigraph(D, false);
  SetAutomorphismGroup(D, SymmetricGroup(n));
  return D;
end);

InstallMethod(EmptyDigraph, "for an integer", [IsInt],
function(n)
  return EmptyDigraphCons(IsImmutableDigraph, n);
end);

InstallMethod(EmptyDigraph, "for a function and an integer",
[IsFunction, IsInt],
function(func, n)
  return EmptyDigraphCons(func, n);
end);

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
  return MutableDigraphNC(rec(DigraphNrVertices := m + n,
                              DigraphSource     := src,
                              DigraphRange      := ran));
end);

InstallMethod(CompleteBipartiteDigraphCons,
"for IsImmutableDigraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(filt, m, n)
  local D, aut;
  D := MakeImmutableDigraph(CompleteBipartiteDigraph(IsMutableDigraph, m, n));
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
function(m, n)
  return CompleteBipartiteDigraph(IsImmutableDigraph, m, n);
end);

InstallMethod(CompleteBipartiteDigraph,
"for a functions and two positive integers",
[IsFunction, IsPosInt, IsPosInt],
function(filt, m, n)
  return CompleteBipartiteDigraphCons(filt, m, n);
end);

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
    ErrorNoReturn("the argument must be a list of positive integers,");
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
  return MutableDigraphNC(out);
end);

InstallMethod(CompleteMultipartiteDigraphCons,
"for IsImmutableDigraph and a list",
[IsImmutableDigraph, IsList],
function(filt, list)
  local D;
  D := CompleteMultipartiteDigraph(IsMutableDigraph, list);
  D := MakeImmutableDigraph(D);
  SetIsSymmetricDigraph(D, true);
  SetIsBipartiteDigraph(D, Length(list) = 2);
  return D;
end);

InstallMethod(CompleteMultipartiteDigraph, "for a list", [IsList],
function(list)
  return CompleteMultipartiteDigraphCons(IsImmutableDigraph, list);
end);

InstallMethod(CompleteMultipartiteDigraph, "for a list", [IsFunction, IsList],
function(filt, list)
  return CompleteMultipartiteDigraphCons(filt, list);
end);

InstallMethod(ChainDigraphCons, "for IsMutableDigraph and a positive integer",
[IsMutableDigraph, IsPosInt],
function(filt, n)
  local list, i;
  list := EmptyPlist(n);
  for i in [1 .. n - 1] do
    list[i] := [i + 1];
  od;
  list[n] := [];
  return MutableDigraphNC(list);
end);

InstallMethod(ChainDigraphCons,
"for IsImmutableDigraph and a positive integer",
[IsImmutableDigraph, IsPosInt],
function(filt, n)
  local D;
  D := MakeImmutableDigraph(ChainDigraphCons(IsMutableDigraph, n));
  if n = 2 then
    SetIsTransitiveDigraph(D, true);
  else
    SetIsTransitiveDigraph(D, false);
  fi;
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
function(func, n)
  return ChainDigraphCons(func, n);
end);

InstallMethod(ChainDigraph, "for a positive integer", [IsPosInt],
function(n)
  return ChainDigraphCons(IsImmutableDigraph, n);
end);

InstallMethod(CompleteDigraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsInt],
function(filt, n)
  local verts, out, i;
  if n < 0 then
    ErrorNoReturn("the argument must be a non-negative integer,");
  elif n = 0 then
    return EmptyDigraph(IsMutableDigraph, 0);
  fi;
  verts := [1 .. n];
  out := EmptyPlist(n);
  for i in verts do
    out[i] := Concatenation([1 .. (i - 1)], [(i + 1) .. n]);
  od;
  return MutableDigraphNC(out);
end);

InstallMethod(CompleteDigraphCons, "for IsImmutableDigraph and an integer",
[IsImmutableDigraph, IsInt],
function(filt, n)
  local D;
  D := MakeImmutableDigraph(CompleteDigraphCons(IsMutableDigraph, n));
  SetIsEmptyDigraph(D, false);
  SetIsAcyclicDigraph(D, false);
  if n > 1 then
    SetIsAntisymmetricDigraph(D, false);
  fi;
  SetIsMultiDigraph(D, false);
  SetIsCompleteDigraph(D, true);
  SetAutomorphismGroup(D, SymmetricGroup(n));
  return D;
end);

InstallMethod(CompleteDigraph, "for a function and an integer",
[IsFunction, IsInt],
function(func, n)
  return CompleteDigraphCons(func, n);
end);

InstallMethod(CompleteDigraph, "for an integer",
[IsInt],
function(n)
  return CompleteDigraphCons(IsImmutableDigraph, n);
end);

InstallMethod(CycleDigraphCons, "for IsMutableDigraph and a positive integer",
[IsMutableDigraph, IsPosInt],
function(filt, n)
  local list, i;
  list := EmptyPlist(n);
  for i in [1 .. n - 1] do
    list[i] := [i + 1];
  od;
  list[n] := [1];
  return MutableDigraphNC(list);
end);

InstallMethod(CycleDigraphCons,
"for IsImmutableDigraph and a positive integer",
[IsImmutableDigraph, IsPosInt],
function(filt, n)
  local D;
  D := MakeImmutableDigraph(CycleDigraphCons(IsMutableDigraph, n));
  if n = 1 then
    SetIsTransitiveDigraph(D, true);
    SetDigraphHasLoops(D, true);
  else
    SetIsTransitiveDigraph(D, false);
    SetDigraphHasLoops(D, false);
  fi;
  SetIsAcyclicDigraph(D, false);
  SetIsEmptyDigraph(D, false);
  SetIsMultiDigraph(D, false);
  SetDigraphNrEdges(D, n);
  SetIsFunctionalDigraph(D, true);
  SetIsStronglyConnectedDigraph(D, true);
  SetAutomorphismGroup(D, CyclicGroup(IsPermGroup, n));
  return D;
end);

InstallMethod(CycleDigraph, "for a function and a positive integer",
[IsFunction, IsPosInt],
function(func, n)
  return CycleDigraphCons(func, n);
end);

InstallMethod(CycleDigraph, "for a function and a positive integer",
[IsFunction, IsPosInt],
function(func, n)
  return CycleDigraphCons(func, n);
end);

InstallMethod(CycleDigraph, "for a positive integer", [IsPosInt],
function(n)
  return CycleDigraphCons(IsImmutableDigraph, n);
end);

InstallMethod(JohnsonDigraphCons,
"for IsMutableDigraph, integer, integer",
[IsMutableDigraph, IsInt, IsInt],
function(filt, n, k)
  if n < 0 or k < 0 then
    ErrorNoReturn("both arguments must be non-negative integers,");
  fi;
  return MutableDigraph(Combinations([1 .. n], k),
                        {u, v} -> Length(Intersection(u, v)) = k - 1);
end);

InstallMethod(JohnsonDigraphCons,
"for IsImmutableDigraph, integer, integer",
[IsImmutableDigraph, IsInt, IsInt],
function(filt, n, k)
  local D;
  D := MakeImmutableDigraph(JohnsonDigraphCons(IsMutableDigraph, n, k));
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, true);
  return D;
end);

InstallMethod(JohnsonDigraph, "for a function, integer, integer",
[IsFunction, IsInt, IsInt],
function(func, n, k)
  return JohnsonDigraphCons(func, n, k);
end);

InstallMethod(JohnsonDigraph, "for integer, integer", [IsInt, IsInt],
function(n, k)
  return JohnsonDigraphCons(IsImmutableDigraph, n, k);
end);

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
  return MutableDigraphByAdjacencyMatrix(mat);
end);

InstallMethod(PetersenGraphCons, "for IsImmutableDigraph",
[IsImmutableDigraph],
function(filt)
  return MakeImmutableDigraph(PetersenGraphCons(IsMutableDigraph));
end);

InstallMethod(PetersenGraph, "for a function", [IsFunction],
function(func)
  return PetersenGraphCons(func);
end);

InstallMethod(PetersenGraph, [],
function()
  return PetersenGraphCons(IsImmutableDigraph);
end);
