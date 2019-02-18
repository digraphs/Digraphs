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

InstallMethod(EmptyMutableDigraph, "for an integer", [IsInt],
function(n)
  if n < 0 then
    ErrorNoReturn("the argument must be a non-negative integer,");
  fi;
  return MutableDigraphNC(List([1 .. n], x -> []));
end);

InstallMethod(EmptyDigraph, "for an integer", [IsInt],
function(n)
  local D;
  D := MakeImmutableDigraph(EmptyMutableDigraph(n));
  SetIsEmptyDigraph(D, true);
  SetIsMultiDigraph(D, false);
  SetAutomorphismGroup(D, SymmetricGroup(n));
  return D;
end);

InstallMethod(CompleteBipartiteDigraph, "for two positive integers",
[IsPosInt, IsPosInt],
function(m, n)
  local source, range, count, k, D, aut, i, j;

  source := EmptyPlist(2 * m * n);
  range := EmptyPlist(2 * m * n);
  count := 0;
  for i in [1 .. m] do
    for j in [1 .. n] do
      count := count + 1;
      source[count] := i;
      range[count] := m + j;
      k := (m * n) + ((j - 1) * m) + i;  # Ensures that source is sorted
      source[k] := m + j;
      range[k] := i;
    od;
  od;
  D := DigraphNC(rec(DigraphNrVertices := m + n,
                     DigraphSource     := source,
                     DigraphRange      := range));
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

# For input list <sizes> of length nr_parts, CompleteMultipartiteDigraph
# returns the complete multipartite digraph containing parts 1, 2, ..., n
# of orders sizes[1], sizes[2], ..., sizes[n], where each vertex is adjacent
# to every other not contained in the same part.

InstallMethod(CompleteMultipartiteDigraph, "for a digraph", [IsList],
function(sizes)
  local nr_parts, nr_vertices, out, start, nbs, i, v;

  if not ForAll(sizes, IsPosInt) then
    ErrorNoReturn("the argument <sizes> must be a list of positive integers,");
  fi;

  nr_parts := Length(sizes);
  nr_vertices := Sum(sizes);

  if nr_parts <= 1 then
    return EmptyDigraph(nr_vertices);
  fi;

  out := EmptyPlist(nr_vertices);

  start := 1;
  for i in [1 .. nr_parts] do
    nbs := Concatenation([1 .. start - 1], [start + sizes[i] .. nr_vertices]);
    for v in [start .. start + sizes[i] - 1] do
      out[v] := nbs;
    od;
    start := start + sizes[i];
  od;

  out := Digraph(out);
  SetIsSymmetricDigraph(out, true);
  SetIsBipartiteDigraph(out, nr_parts = 2);
  return out;
end);

InstallMethod(ChainDigraph, "for a positive integer",
[IsPosInt],
function(n)
  local gr, i, out;

  if n = 1 then
    return EmptyDigraph(1);
  fi;

  out := EmptyPlist(n);
  for i in [1 .. n - 1] do
    out[i] := [i + 1];
  od;
  out[n] := [];
  gr := DigraphNC(out);
  if n = 2 then
    SetIsTransitiveDigraph(gr, true);
  else
    SetIsTransitiveDigraph(gr, false);
  fi;
  SetDigraphHasLoops(gr, false);
  SetIsAcyclicDigraph(gr, true);
  SetIsMultiDigraph(gr, false);
  SetDigraphNrEdges(gr, n - 1);
  SetIsConnectedDigraph(gr, true);
  SetIsStronglyConnectedDigraph(gr, false);
  SetIsFunctionalDigraph(gr, false);
  SetAutomorphismGroup(gr, Group(()));
  return gr;
end);

InstallMethod(CompleteDigraph, "for an integer",
[IsInt],
function(n)
  local verts, out, gr, i;

  if n < 0 then
    ErrorNoReturn(
                  "the argument <n> must be a non-negative integer,");
  elif n = 0 then
    gr := EmptyDigraph(0);
  else
    verts := [1 .. n];
    out := EmptyPlist(n);
    for i in verts do
      out[i] := Concatenation([1 .. (i - 1)], [(i + 1) .. n]);
    od;
    gr := DigraphNC(out);
    SetIsEmptyDigraph(gr, false);
    SetIsAcyclicDigraph(gr, false);
    if n > 1 then
      SetIsAntisymmetricDigraph(gr, false);
    fi;
  fi;
  SetIsMultiDigraph(gr, false);
  SetIsCompleteDigraph(gr, true);
  SetAutomorphismGroup(gr, SymmetricGroup(n));
  return gr;
end);

InstallMethod(CycleDigraph, "for a positive integer",
[IsPosInt],
function(n)
  local gr, i, out;

  out := EmptyPlist(n);
  for i in [1 .. n - 1] do
    out[i] := [i + 1];
  od;
  out[n] := [1];
  gr := DigraphNC(out);
  if n = 1 then
    SetIsTransitiveDigraph(gr, true);
    SetDigraphHasLoops(gr, true);
  else
    SetIsTransitiveDigraph(gr, false);
    SetDigraphHasLoops(gr, false);
  fi;
  SetIsAcyclicDigraph(gr, false);
  SetIsEmptyDigraph(gr, false);
  SetIsMultiDigraph(gr, false);
  SetDigraphNrEdges(gr, n);
  SetIsFunctionalDigraph(gr, true);
  SetIsStronglyConnectedDigraph(gr, true);
  SetAutomorphismGroup(gr, CyclicGroup(IsPermGroup, n));
  return gr;
end);

InstallMethod(JohnsonDigraph, "for two ints",
[IsInt, IsInt],
function(n, k)
  local verts, adj, digraph;
  if n < 0 or k < 0 then
    ErrorNoReturn("both arguments must be non-negative integers,");
  fi;

  # Vertices are all the k-subsets of [1 .. n]
  verts := Combinations([1 .. n], k);
  adj := function(u, v)
    return Length(Intersection(u, v)) = k - 1;
  end;

  digraph := Digraph(verts, adj);

  # Known properties
  SetIsMultiDigraph(digraph, false);
  SetIsSymmetricDigraph(digraph, true);
  return digraph;
end);

InstallMethod(PetersenGraph, [], function()
  local admat;
  admat := [[0, 1, 0, 0, 1, 1, 0, 0, 0, 0],
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
  return DigraphByAdjacencyMatrix(admat);
end);
