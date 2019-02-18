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

InstallMethod(DoubleDigraph, "for a digraph", [IsDigraph],
function(digraph)
  local out, vertices, newvertices, allvertices, shiftedout, newout1,
  newout2, newout, crossedouts, doubleout, shift, double, group,
  newgens, gens, conj;
  # Note that this method is also applicable for digraphs with an adjacency
  # function. however, the resulting double graph will not have an adjacency
  # function anymore, since the original function may take arbitrary objects as
  # argument,  while the double graph has simply integers as vertices. So
  # relying on the original adjacency function is meaningless  unless this
  # function would also be a function on integers.   if DigraphGroup is set, a
  # subgroup of the automoraphism group  of the bipartite double is computed and
  # set.
  out := OutNeighbours(digraph);
  vertices := DigraphVertices(digraph);
  shift := DigraphNrVertices(digraph);
  newvertices := [shift + 1 .. 2 * DigraphNrVertices(digraph)];
  allvertices := [1 .. 2 * DigraphNrVertices(digraph)];
  # "duplicate" of the outs for the new vertices:
  shiftedout := List(out, x -> List(x, y -> y + shift));
  newout1 := List(vertices, x -> List(out[x], y -> y + shift));
  # new out neighbours for vertices
  newout2 := List(newvertices, x -> out[x - shift]);
  # out neighbours for new vertices
  newout := Concatenation(out, shiftedout);
  # collect out neighbours between vertices and new vertices
  crossedouts := Concatenation(newout1, newout2);
  doubleout := List(allvertices, x -> Concatenation(newout[x], crossedouts[x]));
  # collect all out neighbours.
  double := DigraphNC(doubleout);
  if HasDigraphGroup(digraph) then
    group := DigraphGroup(digraph);
    gens := GeneratorsOfGroup(group);
    conj := PermList(Concatenation(List([1 .. shift],
                     x -> x + shift), [1 .. shift]));
    newgens := List([1 .. Length(gens)], i -> gens[i] * (gens[i] ^ conj));
    Add(newgens, conj);
    SetDigraphGroup(double, Group(newgens));
  fi;
  return double;

end);

InstallMethod(BipartiteDoubleDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  local out, vertices, newvertices, newout1,
    newout2, crossedouts, shift, double, group, conj, gens,
    newgens;
  # Note that this method is also applicable for digraphs with
  # an adjacency function. However, the resulting double graph
  # will not have an adjacency function anymore, since the
  # original function may take arbitrary objects as argument,
  # while the double graph has simply integers as vertices.
  # So relying on the original adjacency function is meaningless
  # unless this function would also be a function on integers.
  # compared with DoubleDigraph, we only need the "crossed adjacencies".
  # if DigraphGroup is set, a subgroup of the automoraphism group
  # of the bipartite double is computed and set.
  out := OutNeighbours(digraph);
  vertices := DigraphVertices(digraph);
  shift := DigraphNrVertices(digraph);
  newvertices := [shift + 1 .. 2 * DigraphNrVertices(digraph)];
  newout1 := List(vertices, x -> List(out[x], y -> y + shift));
  newout2 := List(newvertices, x -> out[x - shift]);
  crossedouts := Concatenation(newout1, newout2);
  double := DigraphNC(crossedouts);
  if HasDigraphGroup(digraph) then
    group := DigraphGroup(digraph);
    gens := GeneratorsOfGroup(group);
    conj := PermList(Concatenation(List([1 .. shift],
                     x -> x + shift), [1 .. shift]));
    newgens := List([1 .. Length(gens)], i -> gens[i] * (gens[i] ^ conj));
    Add(newgens, conj);
    SetDigraphGroup(double, Group(newgens));
  fi;
  return double;
end);

InstallMethod(DistanceDigraph,
"for a digraph and a list of distances",
[IsDigraph, IsList],
function(digraph, distances)
  local n, orbitreps, group, sch, g, rep, rem, gens,
    record, new, x, out, vertices;
  n := DigraphNrVertices(digraph);
  new := EmptyDigraph(n);
  vertices := [1 .. n];
  out := [];
  if HasDigraphGroup(digraph) and not IsTrivial(DigraphGroup(digraph)) then
    group := DigraphGroup(digraph);
    orbitreps := DigraphOrbitReps(digraph);
    for x in orbitreps do
      out[x] := DigraphDistanceSet(digraph, x, distances);
    od;
    rem := Difference(vertices, orbitreps);
    sch := DigraphSchreierVector(digraph);
    group := DigraphGroup(digraph);
    gens := GeneratorsOfGroup(group);
    for x in rem do
      record := DIGRAPHS_TraceSchreierVector(gens, sch, x);
      rep := record.representative;
      g := DIGRAPHS_EvaluateWord(gens, record.word);
      out[x] := List(out[rep], x -> x ^ g);
    od;
    new := DigraphNC(out);
    SetDigraphGroup(new, DigraphGroup(digraph));
  else
    for x in vertices do
      out[x] := DigraphDistanceSet(digraph, x, distances);
    od;
    new := DigraphNC(out);
  fi;
  return new;
end);

InstallMethod(DistanceDigraph, "for a digraph and an integer",
[IsDigraph, IsInt],
function(digraph, distance)
  if distance < 0 then
    ErrorNoReturn(
                  "second arg <distance> must be a non-negative integer,");
  fi;
  return DistanceDigraph(digraph, [distance]);
end);

InstallMethod(LineDigraph, "for a symmetric digraph",
[IsDigraph],
function(digraph)
  local edges, G, adj;

  edges := DigraphEdges(digraph);

  if HasDigraphGroup(digraph) then
    G := DigraphGroup(digraph);
  else
    G := Group(());
  fi;

  adj := function(edge1, edge2)
    if edge1 = edge2 then
      return false;
    else
      return edge1[2] = edge2[1];
    fi;
  end;

  return Digraph(G, edges, OnPairs, adj);
end);

InstallMethod(LineUndirectedDigraph, "for a symmetric digraph",
[IsDigraph],
function(digraph)
  local edges, G, adj;

  if not IsSymmetricDigraph(digraph) then
    ErrorNoReturn(
                  "the argument <digraph> must be a symmetric digraph,");
  fi;

  edges := Set(List(DigraphEdges(digraph), x -> Set(x)));

  if HasDigraphGroup(digraph) then
    G := DigraphGroup(digraph);
  else
    G := Group(());
  fi;

  adj := function(edge1, edge2)
    if edge1 = edge2 then
      return false;
    else
      return not IsEmpty(Intersection(edge1, edge2));
    fi;
  end;

  return Digraph(G, edges, OnSets, adj);
end);
