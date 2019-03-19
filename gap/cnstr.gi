#############################################################################
##
##  cnstr.gi
##  Copyright (C) 2019                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# This file contains constructions of certain types of digraphs, from other
# digraphs.

InstallMethod(BipartiteDoubleDigraph, "for a dense mutable digraph",
[IsMutableDigraph and IsDenseDigraphRep],
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
  C := MakeImmutableDigraph(BipartiteDoubleDigraph(DigraphMutableCopy(D)));
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

InstallMethod(DoubleDigraph, "for a dense mutable digraph",
[IsMutableDigraph and IsDenseDigraphRep],
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
  C := MakeImmutableDigraph(DoubleDigraph(DigraphMutableCopy(D)));
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
"for a dense mutable digraph and a list of distances",
[IsMutableDigraph and IsDenseDigraphRep, IsList],
function(D, distances)
  local list, group, orbitreps, rem, sch, gens, record, rep, g, x;
  list := EmptyPlist(DigraphNrVertices(D));
  if HasDigraphGroup(D) and not IsTrivial(DigraphGroup(D)) then
    group := DigraphGroup(D);
    orbitreps := DigraphOrbitReps(D);
    for x in orbitreps do
      list[x] := DigraphDistanceSet(D, x, distances);
    od;
    rem := Difference(DigraphVertices(D), orbitreps);
    sch := DigraphSchreierVector(D);
    group := DigraphGroup(D);
    gens := GeneratorsOfGroup(group);
    for x in rem do
      record := DIGRAPHS_TraceSchreierVector(gens, sch, x);
      rep := record.representative;
      g := DIGRAPHS_EvaluateWord(gens, record.word);
      list[x] := List(list[rep], x -> x ^ g);
    od;
  else
    for x in DigraphVertices(D) do
      list[x] := DigraphDistanceSet(D, x, distances);
    od;
  fi;
  D!.OutNeighbours := list;
  return D;
end);

InstallMethod(DistanceDigraph,
"for an immutable digraph and a list of distances",
[IsImmutableDigraph, IsList],
function(D, list)
  local C;
  C := MakeImmutableDigraph(DistanceDigraph(DigraphMutableCopy(D), list));
  SetDigraphGroup(C, DigraphGroup(D));
  return C;
end);

InstallMethod(DistanceDigraph, "for a digraph and an integer",
[IsDigraph, IsInt],
function(D, distance)
  if distance < 0 then
    ErrorNoReturn("the 2nd argument must be a non-negative integer,");
  fi;
  return DistanceDigraph(D, [distance]);
end);

# Warning: unlike the other methods the next two do not change their arguments
# in place, and always return an immutable digraph. There is currently no
# method for creating a mutable digraph with 4 arguments, as required by the
# next two methods.

InstallMethod(LineDigraph, "for a digraph", [IsDigraph],
function(D)
  local G;
  if HasDigraphGroup(D) then
    G := DigraphGroup(D);
  else
    G := Group(());
  fi;
  return Digraph(G,
                 DigraphEdges(D),
                 OnPairs,
                 {x, y} -> x <> y and x[2] = y[1]);
end);

InstallMethod(LineUndirectedDigraph, "for a digraph", [IsDigraph],
function(D)
  local G;
  if not IsSymmetricDigraph(D) then
    ErrorNoReturn("the argument must be a symmetric digraph,");
  fi;
  if HasDigraphGroup(D) then
    G := DigraphGroup(D);
  else
    G := Group(());
  fi;
  return Digraph(G,
                 Set(DigraphEdges(D), x -> Set(x)),
                 OnSets,
                 {x, y} -> x <> y and not IsEmpty(Intersection(x, y)));
end);
