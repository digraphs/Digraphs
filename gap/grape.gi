#############################################################################
##
##  grape.gi
##  Copyright (C) 2019-21                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# TODO (later) revise this for mutable digraphs, if it makes sense to do so.

# <G> is a group, <obj> a set of points on which <act> acts, and <adj> is a
# function which for 2 elements u, v of <obj> returns <true> if and only if
# u and v should be adjacent in the digraph we are constructing.

InstallImmediateMethod(SemigroupOfCayleyDigraph,
IsCayleyDigraph and HasGroupOfCayleyDigraph, 0, GroupOfCayleyDigraph);

InstallMethod(Digraph,
"for a group, list or collection, function, and function",
[IsGroup, IsListOrCollection, IsFunction, IsFunction],
{G, obj, act, adj} -> Digraph(IsImmutableDigraph, G, obj, act, adj));

InstallMethod(Digraph,
"for a group, list or collection, function, and function",
[IsFunction, IsGroup, IsListOrCollection, IsFunction, IsFunction],
function(imm, G, obj, act, adj)
  local hom, dom, sch, orbits, reps, stabs, rep_out, out, gens, trace, word,
  D, adj_func, i, o, w;

  if not imm in [IsMutableDigraph, IsImmutableDigraph] then
    ErrorNoReturn("<imm> must be IsMutableDigraph or IsImmutableDigraph");
  fi;

  hom    := ActionHomomorphism(G, obj, act, "surjective");
  dom    := [1 .. Size(obj)];

  sch    := DIGRAPHS_Orbits(Range(hom), dom);
  orbits := sch.orbits;
  sch    := sch.schreier;
  reps   := List(orbits, Representative);
  stabs  := List(reps, i -> Stabilizer(Range(hom), i));

  rep_out := EmptyPlist(Length(reps));

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

  D := DigraphNC(imm, out);

  if IsImmutableDigraph(D) then
    adj_func := {u, v} -> adj(obj[u], obj[v]);
    SetFilterObj(D, IsDigraphWithAdjacencyFunction);
    SetDigraphAdjacencyFunction(D, adj_func);
    SetDigraphGroup(D, Range(hom));
    SetDigraphOrbits(D, orbits);
    SetDIGRAPHS_Stabilizers(D, stabs);
    SetDigraphSchreierVector(D, sch);
    SetRepresentativeOutNeighbours(D, rep_out);
  fi;
  return D;
end);

InstallMethod(CayleyDigraph, "for a group with generators",
[IsGroup, IsHomogeneousList],
function(G, gens)
  local elts, adj, D, edge_labels;

  if not IsFinite(G) then
    ErrorNoReturn("the 1st argument <G> must be a finite group,");
  elif not ForAll(gens, x -> x in G) then
    ErrorNoReturn("the 2nd argument <gens> must consist of elements of the ",
                  "1st argument,");
  fi;

  # vertex i in the Cayley digraph corresponds to elts[i].
  elts := AsSet(G);
  adj := {x, y} -> LeftQuotient(x, y) in gens;

  D := Digraph(IsImmutableDigraph, G, elts, OnLeftInverse, adj);
  SetFilterObj(D, IsCayleyDigraph);
  SetGroupOfCayleyDigraph(D, G);
  SetGeneratorsOfCayleyDigraph(D, gens);
  SetDigraphVertexLabels(D, elts);
  # Out-neighbours of identity give the correspondence between edges & gens
  edge_labels := elts{OutNeighboursOfVertex(D, Position(elts, One(G)))};
  SetDigraphEdgeLabels(D, ListWithIdenticalEntries(Size(G), edge_labels));

  return D;
end);

InstallMethod(CayleyDigraph, "for a group with generators",
[IsGroup and HasGeneratorsOfGroup],
G -> CayleyDigraph(G, GeneratorsOfGroup(G)));

InstallMethod(Graph, "for a digraph", [IsDigraph],
function(D)
  local gamma, i, n;

  if IsMultiDigraph(D) then
    Info(InfoWarning, 1, "Grape does not support multiple edges, so ",
         "the Grape graph will have fewer\n#I  edges than the original,");
  fi;

  if not DIGRAPHS_IsGrapeLoaded() then
    Info(InfoWarning, 1, "Grape is not loaded,");
  fi;

  n := DigraphNrVertices(D);
  if HasDigraphGroup(D) then
    gamma := rec(order := n,
                 group := DigraphGroup(D),
                 isGraph := true,
                 representatives := DigraphOrbitReps(D),
                 schreierVector := DigraphSchreierVector(D));
    gamma.adjacencies := ShallowCopy(RepresentativeOutNeighbours(D));
    Apply(gamma.adjacencies, AsSet);
  else
    gamma := rec(order := n,
                 group := Group(()),
                 isGraph := true,
                 representatives := [1 .. n] * 1,
                 schreierVector := [1 .. n] * -1);
    gamma.adjacencies := EmptyPlist(n);

    for i in [1 .. gamma.order] do
      gamma.adjacencies[i] := Set(OutNeighbours(D)[i]);
    od;

  fi;
  gamma.names := Immutable(DigraphVertexLabels(D));
  return gamma;
end);

# InstallMethod(PrintString,
# "for a digraph with group and representative out neighbours",
# [IsDigraph and HasDigraphGroup and HasRepresentativeOutNeighbours],
# function(D)
#   return Concatenation("D< ",
#                        PrintString(DigraphGroup(D)), ", ",
#                        PrintString(DigraphVertices(D)), ", ",
#                        PrintString(RepresentativeOutNeighbours(D)), ">");
# end);

# Returns the digraph with vertex - set {1, .. ., n} and edge-set
# the union over e in E  of  e ^ G.
# (E can consist of just a singleton edge.)

# Note: if at some point we don't store all of the out neighbours, then this
# can be improved. JDM

InstallMethod(EdgeOrbitsDigraph, "for a perm group, list, and int",
[IsPermGroup, IsList, IsInt],
function(G, edges, n)
  local out, o, D, e, f;

  if n < 0 then
    ErrorNoReturn("the 3rd argument <n> must be a non-negative integer,");
  elif n = 0 then
    return EmptyDigraph(0);
  elif IsPosInt(edges[1]) then   # E consists of a single edge
    edges := [edges];
  fi;

  if not ForAll(edges, e -> Length(e) = 2 and ForAll(e, IsPosInt)) then
    ErrorNoReturn("the 2nd argument <edges> must be a list of pairs of ",
                  "positive integers,");
  fi;

  out := List([1 .. n], x -> []);
  for e in edges do
    o := Orbit(G, e, OnTuples);
    for f in o do
      AddSet(out[f[1]], f[2]);
    od;
  od;

  D := DigraphNC(out);
  SetDigraphGroup(D, G);
  return D;
end);

InstallMethod(EdgeOrbitsDigraph, "for a group and list",
[IsPermGroup, IsList],
{G, E} -> EdgeOrbitsDigraph(G, E, LargestMovedPoint(G)));

# Note: if at some point we don't store all of the out neighbours, then this
# can be improved. JDM

InstallMethod(DigraphAddEdgeOrbit, "for a digraph and list",
[IsDigraph, IsList],
function(D, edge)
  local G, o, imm, e;

  if not (Length(edge) = 2 and ForAll(edge, IsPosInt)) then
    ErrorNoReturn("the 2nd argument <edge> must be a list of 2 ",
                  "positive integers,");
  elif not (edge[1] in DigraphVertices(D)
            and edge[2] in DigraphVertices(D)) then
    ErrorNoReturn("the 2nd argument <edge> must be a list of 2 vertices of ",
                  "the 1st argument <D>,");
  elif IsDigraphEdge(D, edge) then
    return D;
  fi;

  G := DigraphGroup(D);
  o := Orbit(G, edge, OnTuples);

  if IsImmutableDigraph(D) then
    imm := true;
    D := DigraphMutableCopy(D);
  fi;

  for e in o do
    DigraphAddEdge(D, e);
  od;

  if imm then
    MakeImmutable(D);
    SetDigraphGroup(D, G);
  fi;

  return D;
end);

# Note: if at some point we don't store all of the out neighbours, then this
# can be improved. JDM

InstallMethod(DigraphRemoveEdgeOrbit, "for a digraph and list",
[IsDigraph, IsList],
function(D, edge)
  local G, o, imm, e;

  if not (Length(edge) = 2 and ForAll(edge, IsPosInt)) then
    ErrorNoReturn("the 2nd argument <edge> must be a pair of ",
                  "positive integers,");
  elif not (edge[1] in DigraphVertices(D)
            and edge[2] in DigraphVertices(D)) then
    ErrorNoReturn("the 2nd argument <edge> must be a ",
                  "pair of vertices of the 1st argument <D>,");
  elif not IsDigraphEdge(D, edge) then
    return D;
  fi;

  G := DigraphGroup(D);
  o := Orbit(G, edge, OnTuples);

  if IsImmutableDigraph(D) then
    imm := true;
    D := DigraphMutableCopy(D);
  fi;

  for e in o do
    DigraphRemoveEdge(D, e);
  od;

  if imm then
    MakeImmutable(D);
    SetDigraphGroup(D, G);
  fi;

  return D;
end);
