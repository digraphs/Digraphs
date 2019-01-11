#############################################################################
##
##  digraph.gi
##  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

BindGlobal("DigraphType", NewType(DigraphFamily,
                                  IsDigraph and IsComponentObjectRep
                                  and IsAttributeStoringRep
                                  and HasDigraphNrVertices));

BindGlobal("DIGRAPHS_InitEdgeLabels",
function(graph)
  if not IsBound(graph!.edgelabels) then
    graph!.edgelabels := StructuralCopy(OutNeighbours(graph));
    graph!.edgelabels := List(graph!.edgelabels, l -> List(l, n -> 1));
  fi;
end);

InstallMethod(Digraph,
"for a list and function",
[IsList, IsFunction],
function(obj, adj)
  local N, out_nbs, in_nbs, x, digraph, i, j, adj_func;

  N       := Size(obj);  # number of vertices
  out_nbs := List([1 .. N], x -> []);
  in_nbs  := List([1 .. N], x -> []);

  for i in [1 .. N] do
    x := obj[i];
    for j in [1 .. N] do
      if adj(x, obj[j]) then
        Add(out_nbs[i], j);
        Add(in_nbs[j], i);
      fi;
    od;
  od;

  # Function that acts on [1..n] rather than obj
  adj_func := function(u, v)
    return adj(obj[u], obj[v]);
  end;

  digraph := DigraphNC(out_nbs);
  SetDigraphAdjacencyFunction(digraph, adj_func);
  SetFilterObj(digraph, IsDigraphWithAdjacencyFunction);
  SetInNeighbours(digraph, in_nbs);

  return digraph;
end);

# for a group and representative out neighbours

# InstallMethod(Digraph, "for a group, list, and list",
# [IsGroup, IsList, IsList],
# function(G, vertices, rep)
#   local digraph;
#
#   #TODO add checks!
#
#   digraph := Objectify(DigraphType, rec());
#
#   SetDigraphGroup(digraph, G);
#   SetRepresentativeOutNeighbours(digraph, rep);
#   SetDigraphVertices(digraph, vertices);
#   SetDigraphNrVertices(digraph, Length(vertices));
#   #TODO remove this, requires changing the OutNeighbours C function
#
#   digraph!.adj := OutNeighbours(digraph);
#   digraph!.nrvertices := DigraphNrVertices(digraph);
#
#   return digraph;
# end);

# <G> is a group, <obj> a set of points on which <act> acts, and <adj> is a
# function which for 2 elements u, v of <obj> returns <true> if and only if
# u and v should be adjacent in the digraph we are constructing.

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

InstallMethod(Digraph, "for a binary relation",
[IsBinaryRelation],
function(rel)
  local d, out, gr, i;

  d := GeneratorsOfDomain(UnderlyingDomainOfBinaryRelation(rel));
  if not IsRange(d) or d[1] <> 1 then
    ErrorNoReturn("Digraphs: Digraph: usage,\n",
                  "the argument <rel> must be a binary relation\n",
                  "on the domain [ 1 .. n ] for some positive integer n,");
  fi;
  out := EmptyPlist(Length(d));
  for i in d do
    out[i] := ImagesElm(rel, i);
  od;
  gr := DigraphNC(out);
  SetIsMultiDigraph(gr, false);
  if HasIsReflexiveBinaryRelation(rel) then
    SetIsReflexiveDigraph(gr, IsReflexiveBinaryRelation(rel));
  fi;
  if HasIsSymmetricBinaryRelation(rel) then
    SetIsSymmetricDigraph(gr, IsSymmetricBinaryRelation(rel));
  fi;
  if HasIsTransitiveBinaryRelation(rel) then
    SetIsTransitiveDigraph(gr, IsTransitiveBinaryRelation(rel));
  fi;
  if HasIsAntisymmetricBinaryRelation(rel) then
    SetIsAntisymmetricDigraph(gr, IsAntisymmetricBinaryRelation(rel));
  fi;
  return gr;
end);

InstallMethod(CayleyDigraph, "for a group with generators",
[IsGroup, IsHomogeneousList],
function(G, gens)
  local adj, digraph;

  if not IsFinite(G) then
    ErrorNoReturn("Digraphs: CayleyDigraph: usage,\n",
                  "the first argument <G> must be a finite group,");
  elif not ForAll(gens, x -> x in G) then
    ErrorNoReturn("Digraphs: CayleyDigraph: usage,\n",
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

InstallImmediateMethod(SemigroupOfCayleyDigraph,
IsCayleyDigraph and HasGroupOfCayleyDigraph, 0,
function(digraph)
  return GroupOfCayleyDigraph(digraph);
end);

InstallMethod(DoubleDigraph, "for a digraph",
[IsDigraph],
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

InstallMethod(DistanceDigraph,
"for a digraph and an integer",
[IsDigraph, IsInt],
function(digraph, distance)
  if distance < 0 then
    ErrorNoReturn("Digraphs: DistanceDigraph: usage,\n",
                  "second arg <distance> must be a non-negative integer,");
  fi;
  return DistanceDigraph(digraph, [distance]);
end);

InstallMethod(SetDigraphVertexLabel, "for a digraph, pos int, object",
[IsDigraph, IsPosInt, IsObject],
function(graph, i, name)

  if not IsBound(graph!.vertexlabels) then
    graph!.vertexlabels := [1 .. DigraphNrVertices(graph)];
  fi;

  if i > DigraphNrVertices(graph) then
    ErrorNoReturn("Digraphs: SetDigraphVertexLabel: usage,\n",
                  "there are only ", DigraphNrVertices(graph), " vertices,");
  fi;
  graph!.vertexlabels[i] := name;
  return;
end);

InstallMethod(DigraphVertexLabel, "for a digraph and pos int",
[IsDigraph, IsPosInt],
function(graph, i)

  if not IsBound(graph!.vertexlabels) then
    graph!.vertexlabels := [1 .. DigraphNrVertices(graph)];
  fi;

  if IsBound(graph!.vertexlabels[i]) then
    return ShallowCopy(graph!.vertexlabels[i]);
  fi;
  # JDM is this a good idea?
  ErrorNoReturn("Digraphs: DigraphVertexLabel: usage,\n", i,
                " is nameless or not a vertex,");
end);

InstallMethod(SetDigraphVertexLabels, "for a digraph and list",
[IsDigraph, IsList],
function(graph, names)

  if not Length(names) = DigraphNrVertices(graph) then
    ErrorNoReturn("Digraphs: SetDigraphVertexLabels: usage,\n",
                  "the 2nd arument <names> must be a list with length equal ",
                  "to the number of\nvertices of the digraph,");
  fi;

  graph!.vertexlabels := names;
  return;
end);

InstallMethod(DigraphVertexLabels, "for a digraph and pos int",
[IsDigraph],
function(graph)

  if not IsBound(graph!.vertexlabels) then
    graph!.vertexlabels := [1 .. DigraphNrVertices(graph)];
  fi;
  return StructuralCopy(graph!.vertexlabels);
end);

# edge labels
InstallMethod(DigraphEdgeLabel, "for a digraph, a pos int, and a pos int",
[IsDigraph, IsPosInt, IsPosInt],
function(graph, i, j)
  local p;

  if IsMultiDigraph(graph) then
    ErrorNoReturn("Digraphs: DigraphEdgeLabel: usage,\n",
                  "edge labels are not supported on digraphs with ",
                  "multiple edges,");
  fi;

  DIGRAPHS_InitEdgeLabels(graph);

  p := Position(OutNeighboursOfVertex(graph, i), j);
  if p = fail then
    ErrorNoReturn("Digraphs: DigraphEdgeLabel:\n",
                  "[", i, ", ", j, "] is not an edge of <graph>,");
  fi;

  return ShallowCopy(graph!.edgelabels[i][p]);
end);

InstallMethod(DigraphEdgeLabelsNC, "for a digraph",
[IsDigraph],
function(graph)
  DIGRAPHS_InitEdgeLabels(graph);
  return StructuralCopy(graph!.edgelabels);
end);

InstallMethod(DigraphEdgeLabels, "for a digraph",
[IsDigraph],
function(graph)
  if IsMultiDigraph(graph) then
    ErrorNoReturn("Digraphs: DigraphEdgeLabels: usage,\n",
                  "edge labels are not supported on digraphs with ",
                  "multiple edges,");
  fi;

  DIGRAPHS_InitEdgeLabels(graph);

  return StructuralCopy(graph!.edgelabels);
end);

InstallMethod(SetDigraphEdgeLabel,
              "for a digraph, a pos int, a pos int, and an object",
[IsDigraph, IsPosInt, IsPosInt, IsObject],
function(graph, i, j, label)
  local p;

  if IsMultiDigraph(graph) then
    ErrorNoReturn("Digraphs: SetDigraphEdgeLabel: usage,\n",
                  "edge labels are not supported on digraphs with ",
                  "multiple edges,");
  fi;

  DIGRAPHS_InitEdgeLabels(graph);

  p := Position(OutNeighboursOfVertex(graph, i), j);
  if p = fail then
    ErrorNoReturn("Digraphs: SetDigraphEdgeLabel:\n",
                  "[", i, ", ", j, "] is not an edge of <graph>,");
  fi;

  graph!.edgelabels[i][p] := ShallowCopy(label);
end);

# markuspf: this is mainly because we do not support edge labels
# on multidigraphs and need the SetDigraphEdgeLabels function
# to fail silently in some places
InstallMethod(SetDigraphEdgeLabelsNC, "for a digraph, and a list",
[IsDigraph, IsList],
function(graph, labels)
  if not IsMultiDigraph(graph) then
    graph!.edgelabels := List(labels, ShallowCopy);
  fi;
end);

InstallMethod(SetDigraphEdgeLabels, "for a digraph, and a list",
[IsDigraph, IsList],
function(graph, labels)
  if IsMultiDigraph(graph) then
    ErrorNoReturn("Digraphs: SetDigraphEdgeLabels: usage,\n",
                  "edge labels are not supported on digraphs with ",
                  "multiple edges,");
  fi;

  if Length(labels) <> DigraphNrVertices(graph) or
      ForAny(DigraphVertices(graph),
             i -> Length(labels[i]) <> OutDegreeOfVertex(graph, i)) then
    ErrorNoReturn("Digraphs: SetDigraphEdgeLabels: usage,\n",
                  "the list <labels> has the wrong shape, it is required to ",
                  "have the same shape\nas the return value of ",
                  "OutNeighbours(<graph>),");
  fi;

  SetDigraphEdgeLabelsNC(graph, labels);
end);

InstallMethod(SetDigraphEdgeLabels, "for a digraph, and a function",
[IsDigraph, IsFunction],
function(graph, wtf)
  local adj, i, j;

  if IsMultiDigraph(graph) then
    ErrorNoReturn("Digraphs: SetDigraphEdgeLabels: usage,\n",
                  "edge labels are not supported on digraphs with ",
                  "multiple edges,");
  fi;

  DIGRAPHS_InitEdgeLabels(graph);

  adj := OutNeighbours(graph);
  for i in DigraphVertices(graph) do
    for j in [1 .. Length(adj[i])] do
      graph!.edgelabels[i][j] := wtf(i, adj[i][j]);
    od;
  od;
end);

# multi means it has at least one multiple edges

InstallMethod(IsMultiDigraph, "for a digraph",
[IsDigraph], IS_MULTI_DIGRAPH);

# Constructors . . .

InstallMethod(AsDigraph, "for a transformation",
[IsTransformation],
function(trans)
  return AsDigraph(trans, DegreeOfTransformation(trans));
end);

InstallMethod(AsDigraph, "for a transformation and an integer",
[IsTransformation, IsInt],
function(f, n)
  local out, x, gr, i;

  if n < 0 then
    ErrorNoReturn("Digraphs: AsDigraph: usage,\n",
                  "the second argument <n> should be a non-negative integer,");
  fi;

  out := EmptyPlist(n);
  for i in [1 .. n] do
    x := i ^ f;
    if x > n then
      return fail;
    fi;
    out[i] := [x];
  od;
  gr := DigraphNC(out, n);
  SetIsMultiDigraph(gr, false);
  SetIsFunctionalDigraph(gr, true);
  return gr;
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

InstallMethod(RandomDigraph, "for a pos int",
[IsPosInt],
function(n)
  return RandomDigraph(n, Float(Random([0 .. 10000])) / 10000);
end);

InstallMethod(RandomDigraph, "for a pos int and a rational",
[IsPosInt, IsRat],
function(n, p)
  return RandomDigraph(n, Float(p));
end);

InstallMethod(RandomDigraph, "for a pos int and a float",
[IsPosInt, IsFloat],
function(n, p)
  local out;

  if p < 0.0 or 1.0 < p then
    ErrorNoReturn("Digraphs: RandomDigraph: usage,\n",
                  "the second argument <p> must be between 0 and 1,");
  fi;
  out := DigraphNC(RANDOM_DIGRAPH(n, Int(p * 10000)));
  SetIsMultiDigraph(out, false);
  return out;
end);

InstallMethod(RandomMultiDigraph, "for a pos int",
[IsPosInt],
function(n)
  return RandomMultiDigraph(n, Random([1 .. (n * (n - 1)) / 2]));
end);

InstallMethod(RandomMultiDigraph, "for two pos ints",
[IsPosInt, IsPosInt],
function(n, m)
  return DigraphNC(RANDOM_MULTI_DIGRAPH(n, m));
end);

InstallMethod(RandomTournament, "for an integer",
[IsInt],
function(n)
  local gr, choice, nr, verts, out, i, j;

  if n < 0 then
    ErrorNoReturn("Digraphs: RandomTournament: usage,\n",
                  "the argument <n> must be a non-negative integer,");
  elif n = 0 then
    gr := EmptyDigraph(0);
  else
    choice := [true, false];
    nr := n * (n - 1) / 2;
    verts := [1 .. n];
    out := List(verts, x -> []);
    for i in verts do
      for j in [(i + 1) .. n] do
        if Random(choice) then
          Add(out[i], j);
        else
          Add(out[j], i);
        fi;
      od;
    od;
    gr := DigraphNC(out);
    SetDigraphNrEdges(gr, nr);
  fi;
  SetIsTournament(gr, true);
  return gr;
end);

InstallMethod(CompleteDigraph, "for an integer",
[IsInt],
function(n)
  local verts, out, gr, i;

  if n < 0 then
    ErrorNoReturn("Digraphs: CompleteDigraph: usage,\n",
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

InstallMethod(EmptyDigraph, "for an integer",
[IsInt],
function(n)
  local gr;

  if n < 0 then
    ErrorNoReturn("Digraphs: EmptyDigraph: usage,\n",
                  "the argument <n> must be a non-negative integer,");
  fi;
  gr := DigraphNC(List([1 .. n], x -> []));
  SetIsEmptyDigraph(gr, true);
  SetIsMultiDigraph(gr, false);
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

InstallMethod(CompleteBipartiteDigraph, "for two positive integers",
[IsPosInt, IsPosInt],
function(m, n)
  local source, range, count, i, j, k, r, gr, aut;

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
  r := rec(nrvertices := m + n, source := source, range := range);
  gr := DigraphNC(r);
  SetIsSymmetricDigraph(gr, true);
  SetDigraphNrEdges(gr, 2 * m * n);
  SetIsCompleteBipartiteDigraph(gr, true);
  if m = n then
    aut := WreathProduct(SymmetricGroup(m), Group((1, 2)));
  else
    aut := DirectProduct(SymmetricGroup(m), SymmetricGroup(n));
  fi;
  SetAutomorphismGroup(gr, aut);
  return gr;
end);

InstallMethod(Digraph, "for a record", [IsRecord],
function(graph)
  local digraph, m, check_source, cmp, obj, i;

  if IsGraph(graph) then
    digraph := DigraphNC(List(Vertices(graph), x -> Adjacency(graph, x)));
    if IsBound(graph.names) then
      SetDigraphVertexLabels(digraph, StructuralCopy(graph.names));
    fi;
    if not IsTrivial(graph.group) then
      Assert(1, IsPermGroup(graph.group));
      SetDigraphGroup(digraph, graph.group);
      SetDigraphSchreierVector(digraph, graph.schreierVector);
      SetRepresentativeOutNeighbours(digraph, graph.adjacencies);
    fi;
    return digraph;
  fi;

  if not (IsBound(graph.source) and IsBound(graph.range) and
          (IsBound(graph.vertices) or IsBound(graph.nrvertices))) then
    ErrorNoReturn("Digraphs: Digraph: usage,\n",
                  "the argument must be a record with components:\n",
                  "'source', 'range', and either 'vertices' or 'nrvertices',");
  fi;

  if not (IsList(graph.source) and IsList(graph.range)) then
    ErrorNoReturn("Digraphs: Digraph: usage,\n",
                  "the graph components 'source' and 'range' should be lists,");
  fi;

  m := Length(graph.source);
  if m <> Length(graph.range) then
    ErrorNoReturn("Digraphs: Digraph: usage,\n",
                  "the record components ",
                  "'source' and 'range' should have equal length,");
  fi;
  graph!.nredges := m;

  check_source := true;

  if IsBound(graph.nrvertices) then
    if not (IsInt(graph.nrvertices) and graph.nrvertices >= 0) then
      ErrorNoReturn("Digraphs: Digraph: usage,\n",
                    "the record component 'nrvertices' ",
                    "should be a non-negative integer,");
    fi;
    if IsBound(graph.vertices) and not
        (IsList(graph.vertices) and
         Length(graph.vertices) = graph.nrvertices) then
      ErrorNoReturn("Digraphs: Digraph: usage,\n",
                    "the record components 'nrvertices' and 'vertices' are ",
                    "inconsistent,");
    fi;
    cmp := LT;
    obj := graph.nrvertices + 1;

    if IsRange(graph.source) then
      if not IsEmpty(graph.source) and
          (graph.source[1] < 1 or
           graph.source[Length(graph.source)] > graph.nrvertices) then
        ErrorNoReturn("Digraphs: Digraph: usage,\n",
                      "the record component 'source' is invalid,");
      fi;
      check_source := false;
    fi;

  elif IsBound(graph.vertices) then
    if not IsList(graph.vertices) then
      ErrorNoReturn("Digraphs: Digraph: usage,\n",
                    "the record component 'vertices' should be a list,");
    fi;
    cmp := \in;
    obj := graph.vertices;
    graph.nrvertices := Length(graph.vertices);
  fi;

  if check_source and not ForAll(graph.source, x -> cmp(x, obj)) then
    ErrorNoReturn("Digraphs: Digraph: usage,\n",
                  "the record component 'source' is invalid,");
  fi;

  if not ForAll(graph.range, x -> cmp(x, obj)) then
    ErrorNoReturn("Digraphs: Digraph: usage,\n",
                  "the record component 'range' is invalid,");
  fi;

  graph := StructuralCopy(graph);

  # rewrite the vertices to numbers
  if IsBound(graph.vertices) then
    if not IsDuplicateFreeList(graph.vertices) then
      ErrorNoReturn("Digraphs: Digraph: usage,\n",
                    "the record component 'vertices' must be duplicate-free,");
    fi;
    if graph.vertices <> [1 .. graph.nrvertices] then
      for i in [1 .. m] do
        graph.range[i] := Position(graph.vertices, graph.range[i]);
        graph.source[i] := Position(graph.vertices, graph.source[i]);
      od;
      graph.vertexlabels := graph.vertices;
      Unbind(graph.vertices);
    fi;
  fi;

  # make sure that the graph.source is sorted, and range is too
  graph.range := Permuted(graph.range, Sortex(graph.source));

  return DigraphNC(graph);
end);

InstallMethod(DigraphNC, "for a record", [IsRecord],
function(graph)
  local new;

  new := rec();
  ObjectifyWithAttributes(new, DigraphType,
                          DigraphRange, graph.range,
                          DigraphSource, graph.source,
                          DigraphNrVertices, graph.nrvertices);
  if IsBound(graph!.nredges) then
    SetDigraphNrEdges(new, graph!.nredges);
  fi;
  if IsBound(graph!.vertexlabels) then
    SetDigraphVertexLabels(new, graph!.vertexlabels);
  fi;
  return new;
end);

InstallMethod(Digraph, "for a dense list", [IsDenseList],
function(adj)
  local nrvertices, nredges, x, y;

  nrvertices := Length(adj);
  nredges := 0;

  for x in adj do
    if not IsHomogeneousList(x) then
      ErrorNoReturn("Digraphs: Digraph: usage,\n",
                    "the argument must be a list of lists of positive ",
                    "integers not exceeding the\nlength of the argument,");
    fi;
    for y in x do
      if not IsPosInt(y) or y > nrvertices then
        ErrorNoReturn("Digraphs: Digraph: usage,\n",
                      "the argument must be a list of lists of positive ",
                      "integers not exceeding the\nlength of the argument,");
      fi;
      nredges := nredges + 1;
    od;
  od;

  return DigraphNC(adj, nredges);
end);

InstallMethod(DigraphNC, "for a dense list", [IsDenseList],
function(adj)
  local graph, adj_copy;

  graph := rec();
  adj_copy := StructuralCopy(adj);
  Perform(adj_copy, IsSet);
  ObjectifyWithAttributes(graph, DigraphType,
                          OutNeighbours, adj_copy,
                          DigraphNrVertices, Length(adj_copy));
  return graph;
end);

InstallMethod(DigraphNC, "for a dense list and an integer",
[IsDenseList, IsInt],
function(adj, nredges)
  local graph;
  graph := DigraphNC(adj);
  SetDigraphNrEdges(graph, nredges);
  return graph;
end);

InstallMethod(Digraph, "for an int and two homogeneous lists",
[IsInt, IsHomogeneousList, IsHomogeneousList],
function(nrvertices, source, range)
  local m;

  if nrvertices < 0 then
    ErrorNoReturn("Digraphs: Digraph: usage,\n",
                  "the first argument <nrvertices> must be a non-negative",
                  " integer,");
  fi;
  m := Length(source);
  if m <> Length(range) then
    ErrorNoReturn("Digraphs: Digraph: usage,\n",
                  "the second and third arguments <source> and <range> ",
                  "must be lists\nof equal length,");
  fi;

  source := ShallowCopy(source);
  range := ShallowCopy(range);

  if m <> 0 then
    if not IsPosInt(source[1])
        or not IsPosInt(range[1])
        or ForAny(source, x -> x < 1 or x > nrvertices)
        or ForAny(range, x -> x < 1 or x > nrvertices) then
      ErrorNoReturn("Digraphs: Digraph: usage,\n",
                    "the second and third arguments <source> and <range> must ",
                    "be lists\nof positive integers no greater than the first ",
                    "argument <nrvertices>,");
    fi;
    range := Permuted(range, Sortex(source));
  fi;
  return DigraphNC(rec(nrvertices := nrvertices,
                       source := source,
                       range := range,
                       nredges := m));
end);

InstallMethod(Digraph, "for three dense lists",
[IsDenseList, IsDenseList, IsDenseList],
function(vertices, source, range)
  local m, n, i;

  m := Length(source);
  if m <> Length(range) then
    ErrorNoReturn("Digraphs: Digraph: usage,\n",
                  "the second and third arguments <source> and <range> ",
                  "must be lists of\nequal length,");
  fi;

  if not IsDuplicateFreeList(vertices) then
    ErrorNoReturn("Digraphs: Digraph: usage,\n",
                  "the first argument <vertices> must be a duplicate-free ",
                  "list,");
  fi;

  if ForAny(source, x -> not x in vertices) then
    ErrorNoReturn("Digraphs: Digraph: usage,\n",
                  "the second argument <source> must be a list of elements of ",
                  "<vertices>,");
  fi;

  if ForAny(range, x -> not x in vertices) then
    ErrorNoReturn("Digraphs: Digraph: usage,\n",
                  "the third argument <range> must be a list of elements of ",
                  "<vertices>,");
  fi;

  vertices := StructuralCopy(vertices);
  source   := StructuralCopy(source);
  range    := StructuralCopy(range);
  n        := Length(vertices);

  # rewrite the vertices to numbers
  if vertices <> [1 .. n] then
    for i in [1 .. m] do
      source[i] := Position(vertices, source[i]);
      range[i] := Position(vertices, range[i]);
    od;
  fi;

  range := Permuted(range, Sortex(source));
  return DigraphNC(rec(nrvertices   := n,
                       nredges      := m,
                       vertexlabels := vertices,
                       source       := source,
                       range        := range));
end);

# JDM: could set IsMultigraph here if we check if mat[i][j] > 1

InstallMethod(DigraphByAdjacencyMatrix, "for a rectangular table",
[IsHomogeneousList],
function(mat)
  local n, verts, out, count, i, j, k;

  n := Length(mat);
  if not IsRectangularTable(mat) or Length(mat[1]) <> n then
    ErrorNoReturn("Digraphs: DigraphByAdjacencyMatrix: usage,\n",
                  "the matrix is not square,");
  fi;

  if IsBool(mat[1][1]) then
    return DigraphByAdjacencyMatrixNC(mat);
  fi;

  verts := [1 .. n];
  out := EmptyPlist(n);
  for i in verts do
    out[i] := [];
    count := 0;
    for j in verts do
      if not (IsPosInt(mat[i][j]) or mat[i][j] = 0) then
        ErrorNoReturn("Digraphs: DigraphByAdjacencyMatrix: usage,\n",
                      "the argument must be a matrix of non-negative integers,",
                      " or a boolean matrix,");
      fi;
      for k in [1 .. mat[i][j]] do
        count := count + 1;
        out[i][count] := j;
      od;
    od;
  od;

  out := DigraphNC(out);
  SetAdjacencyMatrix(out, mat);
  return out;
end);

InstallMethod(DigraphByAdjacencyMatrix, "for an empty list",
[IsList and IsEmpty],
function(mat)
  return DigraphByAdjacencyMatrixNC(mat);
end);

InstallMethod(DigraphByAdjacencyMatrixNC, "for a rectangular table",
[IsHomogeneousList],
function(mat)
  local create_func, n, verts, out, count, i, j;

  if IsInt(mat[1][1]) then
    create_func := function(i, j)
      local k;
      for k in [1 .. mat[i][j]] do
        count := count + 1;
        out[i][count] := j;
      od;
    end;
  else  # boolean matrix
    create_func := function(i, j)
      if mat[i][j] then
        count := count + 1;
        out[i][count] := j;
      fi;
    end;
  fi;

  n := Length(mat);
  verts := [1 .. n];
  out := EmptyPlist(n);
  for i in verts do
    out[i] := [];
    count := 0;
    for j in verts do
      create_func(i, j);
    od;
  od;

  out := DigraphNC(out);
  if IsInt(mat[1][1]) then
    SetAdjacencyMatrix(out, mat);
  else  # boolean matrix
    SetBooleanAdjacencyMatrix(out, mat);
    SetIsMultiDigraph(out, false);
  fi;

  return out;
end);

InstallMethod(DigraphByAdjacencyMatrixNC, "for an empty list",
[IsList and IsEmpty],
function(mat)
  return EmptyDigraph(0);
end);

InstallMethod(DigraphByEdges, "for a rectangular table",
[IsRectangularTable],
function(edges)
  local adj, max_range, gr, edge, i;

  if not Length(edges[1]) = 2 then
    ErrorNoReturn("Digraphs: DigraphByEdges: usage,\n",
                  "the argument <edges> must be a list of pairs,");
  fi;

  if not (IsPosInt(edges[1][1]) and IsPosInt(edges[1][2])) then
    ErrorNoReturn("Digraphs: DigraphByEdges: usage,\n",
                  "the argument <edges> must be a list of pairs of pos ints,");
  fi;

  adj := [];
  max_range := 0;

  for edge in edges do
    if not IsBound(adj[edge[1]]) then
      adj[edge[1]] := [edge[2]];
    else
      Add(adj[edge[1]], edge[2]);
    fi;
    max_range := Maximum(max_range, edge[2]);
  od;

  for i in [1 .. Maximum(Length(adj), max_range)] do
    if not IsBound(adj[i]) then
      adj[i] := [];
    fi;
  od;

  gr := DigraphNC(adj);
  SetDigraphEdges(gr, edges);
  return gr;
end);

# <n> is the number of vertices

InstallMethod(DigraphByEdges, "for a rectangular table, and a pos int",
[IsRectangularTable, IsPosInt],
function(edges, n)
  local adj, gr, edge;

  if not Length(edges[1]) = 2 then
    ErrorNoReturn("Digraphs: DigraphByEdges: usage,\n",
                  "the argument <edges> must be a list of pairs,");
  fi;

  if not (IsPosInt(edges[1][1]) and IsPosInt(edges[1][2])) then
    ErrorNoReturn("Digraphs: DigraphByEdges: usage,\n",
                  "the argument <edges> must be a list of pairs of pos ints,");
  fi;

  adj := List([1 .. n], x -> []);

  for edge in edges do
    if edge[1] > n or edge[2] > n then
      ErrorNoReturn("Digraphs: DigraphByEdges: usage,\n",
                    "the specified edges must not contain values greater than ",
                    n, ",");
    fi;
    Add(adj[edge[1]], edge[2]);
  od;

  gr := DigraphNC(adj);
  SetDigraphEdges(gr, edges);
  return gr;
end);

InstallMethod(DigraphByEdges, "for an empty list",
[IsList and IsEmpty],
function(edges)
  return EmptyDigraph(0);
end);

InstallMethod(DigraphByEdges, "for an empty list, and a pos int",
[IsList and IsEmpty, IsPosInt],
function(edges, n)
  return EmptyDigraph(n);
end);

InstallMethod(DigraphByInNeighbors, "for a list", [IsList],
DigraphByInNeighbours);

InstallMethod(DigraphByInNeighbours, "for a list",
[IsList],
function(nbs)
  local n, m, x;

  n := Length(nbs);  # number of vertices
  m := 0;            # number of edges

  for x in nbs do
    if not ForAll(x, i -> IsPosInt(i) and i <= n) then
      ErrorNoReturn("Digraphs: DigraphByInNeighbours: usage,\n",
                    "the argument must be a list of lists of positive ",
                    "integers\nnot exceeding the length of the argument,");
    fi;
    m := m + Length(x);
  od;

  return DigraphByInNeighboursNC(nbs, m);
end);

InstallMethod(DigraphByInNeighboursNC, "for a list", [IsList],
function(inn)
  local out, gr;

  out := DIGRAPH_IN_OUT_NBS(inn);
  gr := DigraphNC(out);
  SetInNeighbours(gr, inn);
  return gr;
end);

InstallMethod(DigraphByInNeighboursNC, "for a list and an int",
[IsList, IsInt],
function(inn, nredges)
  local out, gr;

  out := DIGRAPH_IN_OUT_NBS(inn);
  gr := DigraphNC(out, nredges);
  SetInNeighbours(gr, inn);
  return gr;
end);

# operators . . .

InstallMethod(\=, "for two digraphs",
[IsDigraph, IsDigraph],
DIGRAPH_EQUALS);

InstallMethod(\<, "for two digraphs",
[IsDigraph, IsDigraph], DIGRAPH_LT);

InstallMethod(DigraphCopy, "for a digraph",
[IsDigraph],
function(digraph)
  local out, gr;

  out := List(OutNeighbours(digraph), ShallowCopy);
  gr := DigraphNC(out);
  SetDigraphVertexLabels(gr, StructuralCopy(DigraphVertexLabels(digraph)));
  SetDigraphEdgeLabelsNC(gr, StructuralCopy(DigraphEdgeLabelsNC(digraph)));
  return gr;
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
    ErrorNoReturn("Digraphs: LineUndirectedDigraph: usage,\n",
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
    ErrorNoReturn("Digraphs: EdgeOrbitsDigraph: usage,\n",
                  "the third argument must be a non-negative integer,");
  elif n = 0 then
    return EmptyDigraph(0);
  fi;

  if IsPosInt(edges[1]) then   # E consists of a single edge
    edges := [edges];
  fi;

  if not ForAll(edges, e -> Length(e) = 2 and ForAll(e, IsPosInt)) then
    ErrorNoReturn("Digraphs: EdgeOrbitsDigraph: usage,\n",
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
    ErrorNoReturn("Digraphs: DigraphAddEdgeOrbit: usage,\n",
                  "the second argument must be a pair of pos ints,");
  elif not (edge[1] in DigraphVertices(digraph)
            and edge[2] in DigraphVertices(digraph)) then
    ErrorNoReturn("Digraphs: DigraphAddEdgeOrbit: usage,\n",
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
    ErrorNoReturn("Digraphs: DigraphRemoveEdgeOrbit: usage,\n",
                  "the second argument must be a pair of pos ints,");
  elif not (edge[1] in DigraphVertices(digraph)
            and edge[2] in DigraphVertices(digraph)) then
    ErrorNoReturn("Digraphs: DigraphRemoveEdgeOrbit: usage,\n",
                  "the second argument must be a ",
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

# Printing, and viewing . . .

InstallMethod(ViewString, "for a digraph",
[IsDigraph],
function(graph)
  local str, n, m;

  str := "<";

  if IsMultiDigraph(graph) then
    Append(str, "multi");
  fi;

  n := DigraphNrVertices(graph);
  m := DigraphNrEdges(graph);

  Append(str, "digraph with ");
  Append(str, String(n));
  if n = 1 then
    Append(str, " vertex, ");
  else
    Append(str, " vertices, ");
  fi;
  Append(str, String(m));
  if m = 1 then
    Append(str, " edge>");
  else
    Append(str, " edges>");
  fi;
  return str;
end);

InstallMethod(PrintString, "for a digraph",
[IsDigraph],
function(graph)
  return Concatenation("Digraph( ", PrintString(OutNeighbours(graph)), " )");
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

InstallMethod(String, "for a digraph",
[IsDigraph],
function(graph)
  return Concatenation("Digraph( ", String(OutNeighbours(graph)), " )");
end);

InstallMethod(DigraphAddAllLoops, "for a digraph",
[IsDigraph],
function(digraph)
  local out_nbs, adj, v;

  out_nbs  := OutNeighbours(digraph);
  adj      := [];
  for v in DigraphVertices(digraph) do
    adj[v] := ShallowCopy(out_nbs[v]);
    if not v in adj[v] then
      Add(adj[v], v);
    fi;
  od;
  return Digraph(adj);
end);

InstallMethod(JohnsonDigraph, "for two ints",
[IsInt, IsInt],
function(n, k)
  local verts, adj, digraph;
  if n < 0 or k < 0 then
    ErrorNoReturn("Digraphs: JohnsonDigraph: usage,\n",
                  "both arguments must be non-negative integers,");
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

# For input list <sizes> of length nr_parts, CompleteMultipartiteDigraph
# returns the complete multipartite digraph containing parts 1, 2, ..., n
# of orders sizes[1], sizes[2], ..., sizes[n], where each vertex is adjacent
# to every other not contained in the same part.

InstallMethod(CompleteMultipartiteDigraph, "for a digraph", [IsList],
function(sizes)
  local nr_parts, nr_vertices, out, start, nbs, i, v;

  if not ForAll(sizes, IsPosInt) then
    ErrorNoReturn("Digraphs: CompleteMultipartiteDigraph: usage,\n",
                  "the argument <sizes> must be a list of positive integers,");
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
