#############################################################################
##
##  constructors.gi
##  Copyright (C) 2019                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# This file contains constructions of certain types of digraphs, from other
# digraphs.

InstallMethod(BipartiteDoubleDigraph, "for a mutable digraph by out-neighbours",
[IsMutableDigraph and IsDigraphByOutNeighboursRep],
function(D)
  local list, N, i, j;
  list := D!.OutNeighbours;
  N    := Length(list);
  Append(list, List([1 .. N], x -> []));
  for i in [1 .. N] do
    for j in [1 .. Length(list[i])] do
      list[i + N][j] := list[i][j];
      list[i][j]     := list[i][j] + N;
    od;
  od;
  return D;
end);

InstallMethod(BipartiteDoubleDigraph, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  local C, X, N, p;
  C := MakeImmutable(BipartiteDoubleDigraph(DigraphMutableCopy(D)));
  if HasDigraphGroup(D) then
    X := GeneratorsOfGroup(DigraphGroup(D));
    N := DigraphNrVertices(D);
    p := PermList(Concatenation([1 .. N] + N, [1 .. N]));
    X := List(X, x -> x * (x ^ p));
    Add(X, p);
    SetDigraphGroup(C, Group(X));
  fi;
  return C;
end);

InstallMethod(DoubleDigraph, "for a mutable digraph by out-neighbours",
[IsMutableDigraph and IsDigraphByOutNeighboursRep],
function(D)
  local list, N, i, j;
  list := D!.OutNeighbours;
  N    := Length(list);
  Append(list, list + N);
  for i in [1 .. N] do
    for j in [1 .. Length(list[i])] do
      Add(list[i + N], list[i][j]);
      Add(list[i], list[i][j] + N);
    od;
  od;
  return D;
end);

InstallMethod(DoubleDigraph, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  local C, X, N, p;
  C := MakeImmutable(DoubleDigraph(DigraphMutableCopy(D)));
  if HasDigraphGroup(D) then
    X := GeneratorsOfGroup(DigraphGroup(D));
    N := DigraphNrVertices(D);
    p := PermList(Concatenation([1 .. N] + N, [1 .. N]));
    X := List(X, x -> x * (x ^ p));
    Add(X, p);
    SetDigraphGroup(C, Group(X));
  fi;
  return C;
end);

InstallMethod(DistanceDigraph,
"for a mutable digraph by out-neighbours and a list of distances",
[IsMutableDigraph and IsDigraphByOutNeighboursRep, IsList],
function(D, distances)
  local list, x;
  # Can't change D!.OutNeighbours in-place, since it is used by
  # DigraphDistanceSet
  list := EmptyPlist(DigraphNrVertices(D));
  for x in DigraphVertices(D) do
    list[x] := DigraphDistanceSet(D, x, distances);
  od;
  D!.OutNeighbours := list;
  return D;
end);

InstallMethod(DistanceDigraph,
"for an immutable digraph and a list of distances",
[IsImmutableDigraph, IsList],
function(D, distances)
  local list, G, o, rem, sch, gen, record, rep, g, C, x;
  if HasDigraphGroup(D) and not IsTrivial(DigraphGroup(D)) then
    list := EmptyPlist(DigraphNrVertices(D));
    G := DigraphGroup(D);
    o := DigraphOrbitReps(D);
    for x in o do
      list[x] := DigraphDistanceSet(D, x, distances);
    od;
    rem := Difference(DigraphVertices(D), o);
    sch := DigraphSchreierVector(D);
    gen := GeneratorsOfGroup(G);
    for x in rem do
      record  := DIGRAPHS_TraceSchreierVector(gen, sch, x);
      rep     := o[record.representative];
      g       := DIGRAPHS_EvaluateWord(gen, record.word);
      list[x] := List(list[rep], x -> x ^ g);
    od;
    C := DigraphNC(list);
  else
    C := MakeImmutable(DistanceDigraph(DigraphMutableCopy(D), distances));
  fi;
  SetDigraphGroup(C, DigraphGroup(D));
  return C;
end);

InstallMethod(DistanceDigraph, "for a digraph and an integer",
[IsDigraph, IsInt],
function(D, distance)
  if distance < 0 then
    ErrorNoReturn("the 2nd argument <distance> must be a non-negative ",
                  "integer,");
  fi;
  return DistanceDigraph(D, [distance]);
end);

# Warning: unlike the other methods the next two do not change their arguments
# in place, and always return an immutable digraph. There is currently no
# method for creating a mutable digraph with 4 arguments, as required by the
# next two methods.

InstallMethod(LineDigraph, "for a digraph", [IsDigraph],
function(D)
  local G, opt;
  if HasDigraphGroup(D) then
    G := DigraphGroup(D);
  else
    G := Group(());
  fi;
  if IsMutableDigraph(D) then
    opt := IsMutableDigraph;
  else
    opt := IsImmutableDigraph;
  fi;
  return Digraph(opt,
                 G,
                 DigraphEdges(D),
                 OnPairs,
                 {x, y} -> x <> y and x[2] = y[1]);
end);

InstallMethod(LineUndirectedDigraph, "for a digraph", [IsDigraph],
function(D)
  local G, opt;
  if not IsSymmetricDigraph(D) then
    ErrorNoReturn("the argument <D> must be a symmetric digraph,");
  elif HasDigraphGroup(D) then
    G := DigraphGroup(D);
  else
    G := Group(());
  fi;
  if IsMutableDigraph(D) then
    opt := IsMutableDigraph;
  else
    opt := IsImmutableDigraph;
  fi;
  return Digraph(opt,
                 G,
                 Set(DigraphEdges(D), Set),
                 OnSets,
                 {x, y} -> x <> y and not IsEmpty(Intersection(x, y)));
end);
