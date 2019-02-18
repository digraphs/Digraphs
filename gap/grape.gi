#############################################################################
##
##  grape.gi
##  Copyright (C) 2019                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# <G> is a group, <obj> a set of points on which <act> acts, and <adj> is a
# function which for 2 elements u, v of <obj> returns <true> if and only if
# u and v should be adjacent in the digraph we are constructing.

InstallImmediateMethod(SemigroupOfCayleyDigraph,
IsCayleyDigraph and HasGroupOfCayleyDigraph, 0,
function(digraph)
  return GroupOfCayleyDigraph(digraph);
end);

InstallMethod(Digraph,
"for a group, list or collection, function, and function",
[IsGroup, IsListOrCollection, IsFunction, IsFunction],
function(G, obj, act, adj)
  local hom, dom, sch, orbits, reps, stabs, rep_out, out, gens, trace, word,
  digraph, adj_func, i, o, w;

  hom    := ActionHomomorphism(G, obj, act, "surjective");
  dom    := [1 .. Size(obj)];

  sch    := DIGRAPHS_Orbits(Range(hom), dom);
  orbits := sch.orbits;
  sch    := sch.schreier;
  reps   := List(orbits, Representative);
  stabs  := List(reps, i -> Stabilizer(Range(hom), i));

  rep_out     := EmptyPlist(Length(reps));

  for i in [1 .. Length(reps)] do
    if IsTrivial(stabs[i]) then
      rep_out[i] := Filtered(dom, j -> adj(obj[reps[i]], obj[j]));
    else
      rep_out[i] := [];
      for o in DIGRAPHS_Orbits(stabs[i], dom).orbits do
        if adj(obj[reps[i]], obj[o[1]]) then
          Append(rep_out[i], o);
        fi;
      od;
    fi;
  od;
  # TODO comment this out, use method for OutNeighbours for digraph with group
  # instead.
  out  := EmptyPlist(Size(obj));
  gens := GeneratorsOfGroup(Range(hom));

  for i in [1 .. Length(sch)] do
    if sch[i] < 0 then
      out[i] := rep_out[-sch[i]];
    fi;

    trace := DIGRAPHS_TraceSchreierVector(gens, sch, i);
    out[i] := rep_out[trace.representative];
    word := trace.word;
    for w in word do
       out[i] := OnTuples(out[i], gens[w]);
    od;
  od;

  digraph := DigraphNC(out);

  adj_func := function(u, v)
    return adj(obj[u], obj[v]);
  end;

  SetFilterObj(digraph, IsDigraphWithAdjacencyFunction);
  SetDigraphAdjacencyFunction(digraph, adj_func);
  SetDigraphGroup(digraph, Range(hom));
  SetDigraphOrbits(digraph, orbits);
  SetDIGRAPHS_Stabilizers(digraph, stabs);
  SetDigraphSchreierVector(digraph, sch);
  SetRepresentativeOutNeighbours(digraph, rep_out);

  return digraph;
end);

InstallMethod(CayleyDigraph, "for a group with generators",
[IsGroup, IsHomogeneousList],
function(G, gens)
  local adj, digraph;

  if not IsFinite(G) then
    ErrorNoReturn(
                  "the first argument <G> must be a finite group,");
  elif not ForAll(gens, x -> x in G) then
    ErrorNoReturn(
                  "elements in the 2nd argument <gens> must ",
                  "all belong to the 1st argument <G>,");
  fi;

  adj := function(x, y)
    return x ^ -1 * y in gens;
  end;
  digraph := Digraph(G, AsList(G), OnRight, adj);
  SetFilterObj(digraph, IsCayleyDigraph);
  SetGroupOfCayleyDigraph(digraph, G);
  SetGeneratorsOfCayleyDigraph(digraph, gens);

  return digraph;
end);

InstallMethod(CayleyDigraph, "for a group with generators",
[IsGroup and HasGeneratorsOfGroup],
function(G)
  return CayleyDigraph(G, GeneratorsOfGroup(G));
end);

InstallMethod(Graph, "for a digraph", [IsDigraph],
function(digraph)
  local gamma, i, n;

  if IsMultiDigraph(digraph) then
    Info(InfoWarning, 1, "Grape does not support multiple edges, so ",
         "the Grape graph will have fewer\n#I  edges than the original,");
  fi;

  if not DIGRAPHS_IsGrapeLoaded then
    Info(InfoWarning, 1, "Grape is not loaded,");
  fi;

  n := DigraphNrVertices(digraph);
  if HasDigraphGroup(digraph) then
    gamma := rec(order := n,
                 group := DigraphGroup(digraph),
                 isGraph := true,
                 representatives := DigraphOrbitReps(digraph),
                 schreierVector := DigraphSchreierVector(digraph));
    gamma.adjacencies := ShallowCopy(RepresentativeOutNeighbours(digraph));
    Apply(gamma.adjacencies, AsSet);
  else
    gamma := rec(order := n,
                 group := Group(()),
                 isGraph := true,
                 representatives := [1 .. n] * 1,
                 schreierVector := [1 .. n] * -1);
    gamma.adjacencies := EmptyPlist(n);

    for i in [1 .. gamma.order] do
      gamma.adjacencies[i] := Set(OutNeighbours(digraph)[i]);
    od;

  fi;
  gamma.names := Immutable(DigraphVertexLabels(digraph));
  return gamma;
end);

# InstallMethod(PrintString,
# "for a digraph with group and representative out neighbours",
# [IsDigraph and HasDigraphGroup and HasRepresentativeOutNeighbours],
# function(digraph)
#   return Concatenation("Digraph( ",
#                        PrintString(DigraphGroup(digraph)), ", ",
#                        PrintString(DigraphVertices(digraph)), ", ",
#                        PrintString(RepresentativeOutNeighbours(digraph)), ")");
# end);

# Returns the digraph with vertex - set {1, .. ., n} and edge-set
# the union over e in E  of  e ^ G.
# (E can consist of just a singleton edge.)

# Note: if at some point we don't store all of the out neighbours, then this
# can be improved. JDM

InstallMethod(EdgeOrbitsDigraph, "for a perm group, list, and int",
[IsPermGroup, IsList, IsInt],
function(G, edges, n)
  local out, o, digraph, e, f;

  if n < 0 then
    ErrorNoReturn(
                  "the third argument must be a non-negative integer,");
  elif n = 0 then
    return EmptyDigraph(0);
  fi;

  if IsPosInt(edges[1]) then   # E consists of a single edge
    edges := [edges];
  fi;

  if not ForAll(edges, e -> Length(e) = 2 and ForAll(e, IsPosInt)) then
    ErrorNoReturn(
                  "the second argument must be a list of pairs of pos ints,");
  fi;

  out := List([1 .. n], x -> []);
  for e in edges do
    o := Orbit(G, e, OnTuples);
    for f in o do
      AddSet(out[f[1]], f[2]);
    od;
  od;

  digraph := DigraphNC(out);
  SetDigraphGroup(digraph, G);

  return digraph;
end);

InstallMethod(EdgeOrbitsDigraph, "for a group and list",
[IsPermGroup, IsList],
function(G, E)
  return EdgeOrbitsDigraph(G, E, LargestMovedPoint(G));
end);

# Note: if at some point we don't store all of the out neighbours, then this
# can be improved. JDM

InstallMethod(DigraphAddEdgeOrbit, "for a digraph and edge",
[IsDigraph, IsList],
function(digraph, edge)
  local out, G, o, e;

  if not (Length(edge) = 2 and ForAll(edge, IsPosInt)) then
    ErrorNoReturn(
                  "the second argument must be a pair of pos ints,");
  elif not (edge[1] in DigraphVertices(digraph)
            and edge[2] in DigraphVertices(digraph)) then
    ErrorNoReturn(
                  "the second argument must be a ",
                  "pair of vertices of the first argument,");
  elif IsDigraphEdge(digraph, edge) then
    return digraph;
  fi;

  out := OutNeighboursMutableCopy(digraph);
  G   := DigraphGroup(digraph);
  o   := Orbit(G, edge, OnTuples);

  for e in o do
    Add(out[e[1]], e[2]);
  od;

  digraph := DigraphNC(out);
  SetDigraphGroup(digraph, G);

  return digraph;
end);

# Note: if at some point we don't store all of the out neighbours, then this
# can be improved. JDM

InstallMethod(DigraphRemoveEdgeOrbit, "for a digraph and edge",
[IsDigraph, IsList],
function(digraph, edge)
  local out, G, o, pos, e;

  if not (Length(edge) = 2 and ForAll(edge, IsPosInt)) then
    ErrorNoReturn("the second argument must be a pair of pos ints,");
  elif not (edge[1] in DigraphVertices(digraph)
            and edge[2] in DigraphVertices(digraph)) then
    ErrorNoReturn("the second argument must be a ",
                  "pair of vertices of the first argument,");
  elif not IsDigraphEdge(digraph, edge) then
    return digraph;
  fi;

  out := OutNeighboursMutableCopy(digraph);
  G   := DigraphGroup(digraph);
  o   := Orbit(G, edge, OnTuples);

  for e in o do
    pos := Position(out[e[1]], e[2]);
    if pos <> fail then
      Remove(out[e[1]], pos);
    fi;
  od;

  digraph := DigraphNC(out);
  SetDigraphGroup(digraph, G);

  return digraph;
end);
