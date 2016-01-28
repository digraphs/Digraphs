#############################################################################
##
#W  oper.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# graph algorithms

InstallMethod(IsSubdigraph, "for a digraph and digraph",
[IsDigraph, IsDigraph],
function(super, sub)
  if DigraphNrVertices(super) <> DigraphNrVertices(sub) then
    return false;
  fi;
  return ForAll([1 .. DigraphNrVertices(super)], i ->
                IsSubset(OutNeighbours(super)[i], OutNeighbours(sub)[i]));
end);

#

InstallGlobalFunction(DigraphEdgeUnion, "for digraphs or a list of digraphs",
function(arg)
  local n, out, nbs, new, gr, i;

  # allow user the possibility of supplying arguments in a list
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;

  if not IsList(arg) or IsEmpty(arg) or not ForAll(arg, IsDigraph) then
    ErrorNoReturn("Digraphs: DigraphEdgeUnion: usage,\n",
                  "the arguments must be digraphs, or the argument must be a ",
                  "list of digraphs,");
  fi;

  n := Maximum(List(arg, DigraphNrVertices));
  out := List([1 .. n], x -> []);

  for gr in arg do
    nbs := OutNeighbours(gr);
    for i in DigraphVertices(gr) do
      if not IsEmpty(nbs[i]) then
        out[i] := Concatenation(out[i], nbs[i]);
      fi;
    od;
  od;

  new := DigraphNC(out);
  if ForAll(arg, HasDigraphNrEdges) then
    SetDigraphNrEdges(new, Sum(arg, DigraphNrEdges));
  fi;
  return new;
end);

#

InstallMethod(DigraphFloydWarshall, "for a digraph",
[IsDigraph, IsFunction, IsObject, IsObject],
function(graph, func, nopath, edge)
  local vertices, n, mat, out, i, j, k;

  vertices := DigraphVertices(graph);
  n := DigraphNrVertices(graph);
  mat := EmptyPlist(n);

  for i in vertices do
    mat[i] := EmptyPlist(n);
    for j in vertices do
      mat[i][j] := nopath;
    od;
  od;

  out := OutNeighbours(graph);
  for i in vertices do
    for j in out[i] do
      mat[i][j] := edge;
    od;
  od;

  for k in vertices do
    for i in vertices do
      for j in vertices do
        func(mat, i, j, k);
      od;
    od;
  od;

  return mat;
end);

#

InstallMethod(DigraphReverse, "for a digraph",
[IsDigraph],
function(digraph)
  local old, new, i, j;

  if HasIsSymmetricDigraph(digraph) and IsSymmetricDigraph(digraph) then
    return DigraphCopy(digraph);
  fi;

  old := OutNeighbours(digraph);
  new := List(DigraphVertices(digraph), x -> []);

  for i in DigraphVertices(digraph) do
    for j in old[i] do
      Add(new[j], i);
    od;
  od;

  return DigraphNC(new);
end);

#

InstallMethod(DigraphReverseEdges, "for a digraph and a rectangular table",
[IsDigraph, IsRectangularTable],
function(digraph, edges)

  if IsMultiDigraph(digraph) then
    ErrorNoReturn("Digraphs: DigraphReverseEdges: usage,\n",
                  "the first argument <digraph> must not be a multigraph,");
  fi;

  # A rectangular table is always non-empty so

  if not IsPosInt(edges[1][1]) or
      not ForAll(edges, x -> IsDigraphEdge(digraph, x)) then
    ErrorNoReturn("Digraphs: DigraphReverseEdges: usage,\n",
                  "the second argument <edges> must be a list of edges of ",
                  "<digraph>,");
  fi;

  return DigraphReverseEdgesNC(digraph, edges);
end);

InstallMethod(DigraphReverseEdgesNC, "for a digraph and a rectangular table",
[IsDigraph, IsRectangularTable],
function(digraph, edges)
  local current, nredges, out, new, i;

  Sort(edges); # Why are we sorting these edges?

  current := 1;
  nredges := Length(edges);
  out := OutNeighbours(digraph);
  new := OutNeighboursCopy(digraph);
  for i in DigraphVertices(digraph) do
    while current <= nredges and edges[current][1] = i do
      Remove(new[i], Position(new[i], edges[current][2]));
      current := current + 1;
    od;
  od;

  for i in [1 .. nredges]  do
    Add(new[edges[i][2]], edges[i][1]);
  od;

  return DigraphNC(new);
end);

#

# can we use IsListOf... jj
InstallMethod(DigraphReverseEdges, "for a digraph and a list",
[IsDigraph, IsList],
function(digraph, edges)
  local nredges;

  if IsMultiDigraph(digraph) then
    ErrorNoReturn("Digraphs: DigraphReverseEdges: usage,\n",
                  "the first argument <digraph> must not be a multigraph,");
  fi;

  if Length(edges) = 0 then
    return DigraphCopy(digraph);
  fi;

  nredges := DigraphNrEdges(digraph);
  if not IsPosInt(edges[1]) or
      not IsHomogeneousList(edges) or
      not ForAll(edges, x -> x <= nredges) then
    ErrorNoReturn("Digraphs: DigraphReverseEdges: usage,\n",
                  "the second argument <edge> ",
                  "must be a list of edges of <digraph>,");
  fi;

  return DigraphReverseEdgesNC(digraph, edges);
end);

InstallMethod(DigraphReverseEdgesNC, "for a digraph and a list",
[IsDigraph, IsList],
function(digraph, edges)
  local nredges, current, out, new, pos_l, pos_h, toadd, pos, temp, i, edge;

  nredges := DigraphNrEdges(digraph);
  Sort(edges); # Why are we sorting the edges?
  current := edges[1];
  out := OutNeighbours(digraph);
  new := [];
  pos_l := 0;
  pos_h := 0;

  toadd := [];
  pos := 1;
  for i in DigraphVertices(digraph) do
    pos_h := pos_h + Length(out[i]);
    new[i] := ShallowCopy(out[i]);
    while pos_l < current and current <= pos_h do
      temp := current - pos_l;
      toadd[pos] := [i, new[i][temp]];
      pos := pos + 1;
      Unbind(new[i][temp]);
      if IsBound(edges[pos]) then
        current := edges[pos];
      else
        break;
      fi;
    od;
    new[i] := Flat(new[i]);
    pos_l := pos_l + Length(out[i]);
  od;

  for edge in toadd do
    Add(new[edge[2]], edge[1]);
  od;

  return DigraphNC(new);
end);

#

InstallMethod(DigraphReverseEdge, "for a digraph and an edge",
[IsDigraph, IsList],
function(digraph, edge)
  return DigraphReverseEdges(digraph, [edge]);
end);

#

InstallMethod(DigraphReverseEdge, "for a digraph and an edge",
[IsDigraph, IsPosInt],
function(digraph, edge)
  return DigraphReverseEdges(digraph, [edge]);
end);

#

InstallMethod(DigraphRemoveLoops, "for a digraph",
[IsDigraph],
function(digraph)
  local old, new, nr, out, i, j, tot;

  old := OutNeighbours(digraph);
  new := [];
  tot := 0;

  for i in DigraphVertices(digraph) do
    new[i] := [];
    nr := 0;
    for j in old[i] do
      if i <> j then
        nr := nr + 1;
        new[i][nr] := j;
      fi;
    od;
    tot := tot + nr;
  od;

  out := DigraphNC(new);
  SetDigraphHasLoops(out, false);
  SetDigraphNrEdges(out, tot);
  SetDigraphVertexLabels(out, DigraphVertexLabels(digraph));
  return out;
end);

#

InstallMethod(DigraphRemoveEdge, "for a digraph and a list of two pos ints",
[IsDigraph, IsHomogeneousList],
function(digraph, edge)
  local verts, out;

  if IsMultiDigraph(digraph) then
      ErrorNoReturn("Digraphs: DigraphRemoveEdge: usage,\nthe ",
                    "first argument <digraph> must not have multiple edges\n",
                    "when the second argument <edges> is a pair of vertices,");
  fi;
  verts := DigraphVertices(digraph);
  if Length(edge) <> 2
      or not IsPosInt(edge[1])
      or not edge[1] in verts
      or not edge[2] in verts then
    ErrorNoReturn("Digraphs: DigraphRemoveEdge: usage,\n",
                  "the second argument <edge> must be a pair of vertices of ",
                  "<digraph>,");
  fi;
  out := DigraphRemoveEdges(digraph, [edge]);
  SetDigraphVertexLabels(out, DigraphVertexLabels(digraph));
  return out;
end);

InstallMethod(DigraphRemoveEdge, "for a digraph and a pos int",
[IsDigraph, IsPosInt],
function(digraph, edge)
  local m, out;

  m := DigraphNrEdges(digraph);
  if edge > m then
    ErrorNoReturn("Digraphs: DigraphRemoveEdge: usage,\n",
                  "the second argument <edge> must be the index of an edge in ",
                  "<digraph>,");
  fi;
  out := DigraphRemoveEdgesNC(digraph, [edge]);
  SetDigraphVertexLabels(out, DigraphVertexLabels(digraph));
  return out;
end);

InstallMethod(DigraphRemoveEdges, "for a digraph and a list",
[IsDigraph, IsHomogeneousList],
function(digraph, edges)
  local m, verts, remove, n, old_adj, count, offsets, pos, i, x, out;

  if IsEmpty(edges) then
    return DigraphCopy(digraph);
  fi;

  m := DigraphNrEdges(digraph);
  verts := DigraphVertices(digraph);

  if IsPosInt(edges[1]) and ForAll(edges, x -> 0 < x and x <= m) then
    # Remove edges by index
    remove := edges;
  elif IsRectangularTable(edges) and Length(edges[1]) = 2
      and ForAll(edges, x -> x[1] in verts and x[2] in verts) then
    # Remove edges by [ source, range ]
    if IsMultiDigraph(digraph) then
      ErrorNoReturn("Digraphs: DigraphRemoveEdges: usage,\n",
                    "the first argument <digraph> must not have ",
                    "multiple edges\nwhen the second argument <edges> ",
                    "is a list of edges,");
    fi;
    n := DigraphNrVertices(digraph);
    old_adj := OutNeighbours(digraph);
    count := 0;
    remove := [];
    offsets := EmptyPlist(n);
    offsets[1] := 0;
    for i in [2 .. n] do
      offsets[i] := offsets[i - 1] + Length(old_adj[i - 1]);
    od;
    for x in edges do
      pos := Position(old_adj[x[1]], x[2]);
      if pos <> fail then
        count := count + 1;
        remove[count] := offsets[x[1]] + pos;
      fi;
    od;
  else
    ErrorNoReturn("Digraphs: DigraphRemoveEdges: usage,\n",
                  "the second argument <edges> must be a list of indices of\n",
                  "edges or a list of edges of the first argument <digraph>,");
  fi;
  out := DigraphRemoveEdgesNC(digraph, remove);
  SetDigraphVertexLabels(out, DigraphVertexLabels(digraph));
  return out;
end);

# DigraphRemoveEdgesNC assumes you are removing edges by index

InstallMethod(DigraphRemoveEdgesNC, "for a digraph and a list",
[IsDigraph, IsHomogeneousList],
function(digraph, edges)
  local m, n, old_adj, new_adj, edge_count, degree_count, gr, i, j;

  if IsEmpty(edges) then
    return DigraphCopy(digraph);
  fi;

  m := DigraphNrEdges(digraph);
  n := DigraphNrVertices(digraph);
  old_adj := OutNeighbours(digraph);
  new_adj := EmptyPlist(n);
  edges := BlistList([1 .. m], edges);
  edge_count := 0;
  degree_count := 0;
  for i in DigraphVertices(digraph) do # Loop over each vertex
    new_adj[i] := [];
    degree_count := 0;
    for j in old_adj[i] do
      edge_count := edge_count + 1;
      if not edges[edge_count] then # Keep this edge
        degree_count := degree_count + 1;
        new_adj[i][degree_count] := j;
      fi;
    od;
  od;
  gr := DigraphNC(new_adj);
  SetDigraphVertexLabels(gr, DigraphVertexLabels(digraph));
  return gr;
end);

#

InstallMethod(DigraphAddEdge, "for a digraph and an edge",
[IsDigraph, IsList],
function(digraph, edge)
  local verts, out;

  verts := DigraphVertices(digraph);
  if Length(edge) <> 2
      or not IsPosInt(edge[1])
      or not IsPosInt(edge[2])
      or not edge[1] in verts
      or not edge[2] in verts then
    ErrorNoReturn("Digraphs: DigraphAddEdge: usage,\n",
                  "the second argument <edge> must be a pair of vertices of ",
                  "<digraph>,");
  fi;

  out := DigraphAddEdgesNC(digraph, [edge]);
  SetDigraphVertexLabels(out, DigraphVertexLabels(digraph));
  return out;
end);

InstallMethod(DigraphAddEdges, "for a digraph and a list",
[IsDigraph, IsList],
function(digraph, edges)
  local vertices, edge, out;

  if not IsEmpty(edges) and
      (not IsList(edges[1])
       or not Length(edges[1]) = 2
       or not IsPosInt(edges[1][1])
       or not IsRectangularTable(edges)) then
    ErrorNoReturn("Digraphs: DigraphAddEdges: usage,\n",
                  "the second argument <edges> must be a list of pairs of ",
                  "vertices\nof the first argument <digraph>,");
  fi;

  vertices := DigraphVertices(digraph);
  for edge in edges do
    if not (edge[1] in vertices and edge[2] in vertices) then
      ErrorNoReturn("Digraphs: DigraphAddEdges: usage,\n",
                    "the second argument <edges> must be a list of pairs of ",
                    "vertices\nof the first argument <digraph>,");
    fi;
  od;

  out := DigraphAddEdgesNC(digraph, edges);
  SetDigraphVertexLabels(out, DigraphVertexLabels(digraph));
  return out;
end);

InstallMethod(DigraphAddEdgesNC, "for a digraph and a list",
[IsDigraph, IsList],
function(digraph, edges)
  local new, verts, edge;

  new := OutNeighboursCopy(digraph);
  verts := DigraphVertices(digraph);
  for edge in edges do
    Add(new[edge[1]], edge[2]);
  od;
  return DigraphNC(new);
end);
#

InstallMethod(DigraphAddVertex, "for a digraph",
[IsDigraph],
function(digraph)
  return DigraphAddVerticesNC(digraph, 1, []);
end);

InstallMethod(DigraphAddVertex, "for a digraph and an object",
[IsDigraph, IsObject],
function(digraph, name)
  return DigraphAddVerticesNC(digraph, 1, [name]);
end);

#

InstallMethod(DigraphAddVertices, "for a digraph and a pos int",
[IsDigraph, IsInt],
function(digraph, m)
  if m < 0 then
    ErrorNoReturn("Digraphs: DigraphAddVertices: usage,\n",
                  "the second argument <m> (the number of vertices to add) ",
                  "must be non-negative,");
  fi;
  return DigraphAddVerticesNC(digraph, m, []);
end);

InstallMethod(DigraphAddVertices, "for a digraph, a pos int and a list",
[IsDigraph, IsInt, IsList],
function(digraph, m, names)
  if m < 0 then
    ErrorNoReturn("Digraphs: DigraphAddVertices: usage,\n",
                  "the second argument <m> (the number of vertices to add) ",
                  "must be non-negative,");
  elif Length(names) <> m then
    ErrorNoReturn("Digraphs: DigraphAddVertices: usage,\n",
                  "the number of new vertex names (the length of the third ",
                  "argument <names>)\nmust match the number of new vertices ",
                  "( the value of the second argument <m>),");
  fi;
  return DigraphAddVerticesNC(digraph, m, names);
end);

#

InstallMethod(DigraphAddVerticesNC, "for a digraph, a pos int and a list",
[IsDigraph, IsInt, IsList],
function(digraph, m, names)
  local n, new, newverts, out, nam, i;

  n := DigraphNrVertices(digraph);
  new := OutNeighboursCopy(digraph);
  newverts := [(n + 1) .. (n + m)];
  for i in newverts do
    new[i] := [];
  od;
  out := DigraphNC(new);
  # Transfer known data
  if IsEmpty(names) then
    names := newverts;
  fi;
  nam := Concatenation(DigraphVertexLabels(digraph), names);
  SetDigraphVertexLabels(out, nam);
  return out;
end);

#

InstallMethod(DigraphRemoveVertex, "for a digraph and a pos int",
[IsDigraph, IsPosInt],
function(digraph, m)
  if m > DigraphNrVertices(digraph) then
    ErrorNoReturn("Digraphs: DigraphRemoveVertex: usage,\n",
                  "the second argument <m> is not a ",
                  "vertex of the first argument <digraph>,");
  fi;
  return DigraphRemoveVerticesNC(digraph, [m]);
end);

#

InstallMethod(DigraphRemoveVertices, "for a digraph and a list",
[IsDigraph, IsList],
function(digraph, verts)
  local n;

  n := DigraphNrVertices(digraph);
  if not IsEmpty(verts) and
      (not IsPosInt(verts[1]) or
       not IsHomogeneousList(verts) or
       not IsDuplicateFreeList(verts) or
       ForAny(verts, x -> x < 1 or n < x)) then
    ErrorNoReturn("Digraphs: DigraphRemoveVertices: usage,\n",
                  "the second argument <verts> should be a duplicate free ",
                  "list of vertices of\nthe first argument <digraph>,");
  fi;
  return DigraphRemoveVerticesNC(digraph, verts);
end);

#

InstallMethod(DigraphRemoveVerticesNC, "for a digraph and a list",
[IsDigraph, IsList],
function(digraph, verts)
  local n, len, new_nrverts, m, log, diff, j, lookup, new_vertex_count,
  old_nbs, new_nbs, gr, i, x;

  if IsEmpty(verts) then
    return DigraphCopy(digraph);
  fi;

  n := DigraphNrVertices(digraph);
  len := Length(verts);
  new_nrverts := n - len;
  if new_nrverts = 0 then
    return EmptyDigraph(0);
  fi;
  m := DigraphNrEdges(digraph);
  log := LogInt(len, 2);
  if (2 * m * log) + (len * log) < (2 * m * len) then # Sort verts if sensible
    Sort(verts);
  fi;
  diff := Difference(DigraphVertices(digraph), verts);

  j := 0;
  lookup := EmptyPlist(n);
  for i in diff do
    j := j + 1;
    lookup[i] := j;
  od;

  new_vertex_count := 0;
  old_nbs := OutNeighbours(digraph);
  new_nbs := EmptyPlist(new_nrverts);
  for i in DigraphVertices(digraph) do
    if IsBound(lookup[i]) then
      new_vertex_count := new_vertex_count + 1;
      new_nbs[new_vertex_count] := [];
      j := 0;
      for x in old_nbs[i] do
        if not x in verts then # Can search through diff if |diff| < |verts|
          j := j + 1;
          new_nbs[new_vertex_count][j] := lookup[x];
        fi;
      od;
    fi;
  od;

  gr := DigraphNC(new_nbs);
  SetDigraphVertexLabels(gr, DigraphVertexLabels(digraph){diff});
  return gr;
end);

#

InstallMethod(OnDigraphs, "for a digraph and a perm",
[IsDigraph, IsPerm],
function(graph, perm)
  local adj;

  if ForAny(DigraphVertices(graph),
            i -> i ^ perm > DigraphNrVertices(graph)) then
    ErrorNoReturn("Digraphs: OnDigraphs: usage,\n",
                  "the 2nd argument <perm> must permute the vertices ",
                  "of the 1st argument <graph>,");
  fi;

  adj := OutNeighboursCopy(graph);
  adj := Permuted(adj, perm);
  Apply(adj, x -> OnTuples(x, perm));

  # don't set the vertex or edge labels . . .
  return DigraphNC(adj);
end);

#

InstallMethod(OnDigraphs, "for a digraph and a transformation",
[IsDigraph, IsTransformation],
function(digraph, trans)
  local n, adj, new, i;

  n := DigraphNrVertices(digraph);
  if ForAny(DigraphVertices(digraph), i -> i ^ trans > n) then
    ErrorNoReturn("Digraphs: OnDigraphs: usage,\n",
                  "the 2nd argument <trans> must transform the vertices of ",
                  "the 1st argument\n<digraph>,");
  fi;
  adj := OutNeighbours(digraph);
  new := List(DigraphVertices(digraph), i -> []);
  for i in DigraphVertices(digraph) do
    new[i ^ trans] := Unique(Concatenation(new[i ^ trans], adj[i]));
  od;
  return DigraphNC(List(new, x -> Unique(OnTuples(x, trans))));
end);

#

InstallMethod(OnMultiDigraphs, "for a digraph, perm and perm",
[IsDigraph, IsPerm, IsPerm],
function(graph, perm1, perm2)
  return OnMultiDigraphs(graph, [perm1, perm2]);
end);

InstallMethod(OnMultiDigraphs, "for a digraph and perm coll",
[IsDigraph, IsPermCollection],
function(graph, perms)
  if Length(perms) <> 2 then
    ErrorNoReturn("Digraphs: OnMultiDigraphs: usage,\n",
                  "the 2nd argument must be a pair of permutations,");
  fi;

  if ForAny([1 .. DigraphNrEdges(graph)],
            i -> i ^ perms[2] > DigraphNrEdges(graph)) then
    ErrorNoReturn("Digraphs: OnMultiDigraphs: usage,\n",
                  "the argument <perms[2]> must permute the edges ",
                  "of the 1st argument <graph>,");
  fi;

  return OnDigraphs(graph, perms[1]);
end);

#

InstallMethod(InducedSubdigraph,
"for a digraph and a homogeneous list",
[IsDigraph, IsHomogeneousList],
function(digraph, subverts)
  local nr, n, old_adj, new_adj, lookup, adji, j, l, gr, i, k;

  nr := Length(subverts);
  if nr = 0 then
    return DigraphNC([]);
  fi;

  n := DigraphNrVertices(digraph);
  if (IsRange(subverts) and not
      (IsPosInt(subverts[1]) and subverts[1] <= n and
       subverts[Length(subverts)] <= n))
      or not IsDuplicateFree(subverts)
      or not ForAll(subverts, x -> IsPosInt(x) and x < (n + 1)) then
    ErrorNoReturn("Digraphs: InducedSubdigraph: usage,\n",
                  "the second argument <subverts> must be a duplicate-free ",
                  "subset\nof the vertices of the first argument <digraph>,");
  fi;

  old_adj := OutNeighbours(digraph);
  new_adj := EmptyPlist(nr);

  lookup := [1 .. n] * 0;
  lookup{subverts} := [1 .. nr];

  for i in [1 .. nr] do
    adji := [];
    j := 0;
    for k in [1 .. Length(old_adj[subverts[i]])] do
      l := lookup[old_adj[subverts[i]][k]];
      if l <> 0 then
        j := j + 1;
        adji[j] := l;
      fi;
    od;
    new_adj[i] := adji;
  od;

  gr := DigraphNC(new_adj);
  SetDigraphVertexLabels(gr, DigraphVertexLabels(digraph){subverts});
  return gr;
end);

#

InstallMethod(InNeighboursOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  if not v in DigraphVertices(digraph) then
    ErrorNoReturn("Digraphs: InNeighboursOfVertex: usage,\n",
                  "the 2nd argument <v> is not a vertex of the first, ",
                  "<digraph>,");
  fi;
  return InNeighboursOfVertexNC(digraph, v);
end);

InstallMethod(InNeighboursOfVertexNC,
"for a digraph with in-neighbours and a vertex",
[IsDigraph and HasInNeighbours, IsPosInt],
function(digraph, v)
  return InNeighbours(digraph)[v];
end);

InstallMethod(InNeighboursOfVertexNC, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  local inn, pos, out, i, j;

  inn := [];
  pos := 1;
  out := OutNeighbours(digraph);
  for i in [1 .. Length(out)] do
    for j in [1 .. Length(out[i])] do
      if out[i][j] = v then
        inn[pos] := i;
        pos := pos + 1;
      fi;
    od;
  od;
  return inn;
end);

#

InstallMethod(OutNeighboursOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  if not v in DigraphVertices(digraph) then
    ErrorNoReturn("Digraphs: OutNeighboursOfVertex: usage,\n",
                  "the 2nd argument <v> is not a vertex of the 1st, ",
                  "<digraph>,");
  fi;
  return OutNeighboursOfVertexNC(digraph, v);
end);

InstallMethod(OutNeighboursOfVertexNC, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  return OutNeighbours(digraph)[v];
end);

#

InstallMethod(InDegreeOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  if not v in DigraphVertices(digraph) then
    ErrorNoReturn("Digraphs: InDegreeOfVertex: usage,\n",
                  "the 2nd argument <v> is not a vertex of the 1st, ",
                  "<digraph>,");
  fi;
  return InDegreeOfVertexNC(digraph, v);
end);

InstallMethod(InDegreeOfVertexNC, "for a digraph with in-degrees and a vertex",
[IsDigraph and HasInDegrees, IsPosInt], 4,
function(digraph, v)
  return InDegrees(digraph)[v];
end);

InstallMethod(InDegreeOfVertexNC,
"for a digraph with in-neighbours and a vertex",
[IsDigraph and HasInNeighbours, IsPosInt],
function(digraph, v)
  return Length(InNeighbours(digraph)[v]);
end);

InstallMethod(InDegreeOfVertexNC, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  local count, out, x, i;

  count := 0;
  out := OutNeighbours(digraph);
  for x in out do
    for i in x do
      if i = v then
        count := count + 1;
      fi;
    od;
  od;
  return count;
end);

#

InstallMethod(OutDegreeOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  if not v in DigraphVertices(digraph) then
    ErrorNoReturn("Digraphs: OutDegreeOfVertex: usage,\n",
                  "the 2nd argument <v> is not a vertex of the 1st, ",
                  "<digraph>,");
  fi;
   return OutDegreeOfVertexNC(digraph, v);
end);

InstallMethod(OutDegreeOfVertexNC,
"for a digraph with out-degrees and a vertex",
[IsDigraph and HasOutDegrees, IsPosInt],
function(digraph, v)
  return OutDegrees(digraph)[v];
end);

InstallMethod(OutDegreeOfVertexNC, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  return Length(OutNeighbours(digraph)[v]);
end);

#

InstallMethod(QuotientDigraph, "for a digraph and a homogeneous list",
[IsDigraph, IsHomogeneousList],
function(digraph, partition)
  local n, nr, check, lookup, out, new, x, i, j;

  n := DigraphNrVertices(digraph);
  if n = 0 and IsEmpty(partition) then
    return EmptyDigraph(0);
  elif n = 0 then
    ErrorNoReturn("Digraphs: QuotientDigraph: usage,\n",
                  "the second argument <partition> is not a valid partition ",
                  "of the\nvertices of the null digraph <digraph>. The only ",
                  "valid partition\nof <digraph> is the empty list,");
  fi;
  nr := Length(partition);
  if n = 0 or nr = 0 or not IsList(partition[1])
      or IsEmpty(partition[1]) or not IsPosInt(partition[1][1]) then
    ErrorNoReturn("Digraphs: QuotientDigraph: usage,\n",
                  "the second argument <partition> is not a valid partition\n",
                  "of the vertices of <digraph>, [ 1 .. ", n, " ],");
  fi;

  check := BlistList(DigraphVertices(digraph), []);
  lookup := EmptyPlist(n);

  for x in [1 .. Length(partition)] do
    for i in partition[x] do
      if i < 1 or i > n or check[i] then
        ErrorNoReturn("Digraphs: QuotientDigraph: usage,\n",
                      "the second argument <partition> is not a valid\n",
                      "partition of the vertices of <digraph>, ",
                      "[ 1 .. ", n, " ],");
      fi;
      check[i] := true;
      lookup[i] := x;
    od;
  od;

  if ForAny(check, x -> not x) then
    ErrorNoReturn("Digraphs: QuotientDigraph: usage,\n",
                  "the second argument <partition> does not partition\n",
                  "every vertex of the first argument, <digraph>,");
  fi;

  out := OutNeighbours(digraph);
  new := List([1 .. nr], x -> []);
  for i in DigraphVertices(digraph) do
    for j in out[i] do
      Add(new[lookup[i]], lookup[j]);
    od;
  od;
  return DigraphNC(new);
  # Pass on information about <digraph> which might be relevant to gr?
end);

#

InstallMethod(DigraphOutEdges, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  if not v in DigraphVertices(digraph) then
    ErrorNoReturn("Digraphs: DigraphOutEdges: usage,\n",
                  v, " is not a vertex of the digraph,");
  fi;

  return List(OutNeighboursOfVertex(digraph, v), x -> [v, x]);
end);

#

InstallMethod(DigraphInEdges, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  if not v in DigraphVertices(digraph) then
    ErrorNoReturn("Digraphs: DigraphInEdges: usage,\n",
                  v, " is not a vertex of the digraph,");
  fi;

  return List(InNeighboursOfVertex(digraph, v), x -> [x, v]);
end);

#

InstallMethod(DigraphStronglyConnectedComponent, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  local scc;

  if not v in DigraphVertices(digraph) then
    ErrorNoReturn("Digraphs: DigraphStronglyConnectedComponent: usage,\n",
                  v, " is not a vertex of the digraph,");
  fi;

  # TODO check if strongly connected components are known and use them if they
  # are and don't use them if they are not.
  scc := DigraphStronglyConnectedComponents(digraph);
  return scc.comps[scc.id[v]];
end);

#

InstallMethod(DigraphConnectedComponent, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  local wcc;

  if not v in DigraphVertices(digraph) then
    ErrorNoReturn("Digraphs: DigraphConnectedComponent: usage,\n",
                  v, " is not a vertex of the digraph,");
  fi;

  wcc := DigraphConnectedComponents(digraph);
  return wcc.comps[wcc.id[v]];
end);

#

InstallMethod(IsDigraphEdge, "for a digraph and a list",
[IsDigraph, IsList],
function(digraph, edge)
  if Length(edge) <> 2 or not IsPosInt(edge[1]) or not IsPosInt(edge[2]) then
    return false;
  fi;
  return IsDigraphEdge(digraph, edge[1], edge[2]);
end);

InstallMethod(IsDigraphEdge, "for a digraph, pos int, pos int",
[IsDigraph, IsPosInt, IsPosInt],
function(digraph, u, v)
  local n;

  n := DigraphNrVertices(digraph);

  if u > n or v > n then
    return false;
  elif HasAdjacencyMatrix(digraph) then
    return AdjacencyMatrix(digraph)[u][v] <> 0;
  elif IsDigraphWithAdjacencyFunction(digraph) then
    return DigraphAdjacencyFunction(digraph)(u, v);
  fi;

  return v in OutNeighboursOfVertex(digraph, u);
end);

#

InstallMethod(AsBinaryRelation, "for a digraph",
[IsDigraph],
function(digraph)
  local rel;

  if DigraphNrVertices(digraph) = 0 then
    ErrorNoReturn("Digraphs: AsBinaryRelation: usage,\n",
                  "the argument <digraph> must have at least one vertex,");
  elif IsMultiDigraph(digraph) then
    ErrorNoReturn("Digraphs: AsBinaryRelation: usage,\n",
                  "the argument <digraph> must be a digraph with ",
                  "no multiple edges,");
  fi;
  # Can translate known attributes of <digraph> to the relation, e.g. symmetry
  rel := BinaryRelationOnPointsNC(OutNeighbours(digraph));
  if HasIsReflexiveDigraph(digraph) then
    SetIsReflexiveBinaryRelation(rel, IsReflexiveDigraph(digraph));
  fi;
  if HasIsSymmetricDigraph(digraph) then
    SetIsSymmetricBinaryRelation(rel, IsSymmetricDigraph(digraph));
  fi;
  if HasIsTransitiveDigraph(digraph) then
    SetIsTransitiveBinaryRelation(rel, IsTransitiveDigraph(digraph));
  fi;
  if HasIsAntisymmetricDigraph(digraph) then
    SetIsAntisymmetricBinaryRelation(rel, IsAntisymmetricDigraph(digraph));
  fi;
  return rel;
end);

#

InstallGlobalFunction(DigraphDisjointUnion,
"for digraphs or a list of digraphs",
function(arg)
  local out, offset, n, new, gr;

  # allow user the possibility of supplying arguments in a list
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;

  if not IsList(arg) or IsEmpty(arg) or not ForAll(arg, IsDigraph) then
    ErrorNoReturn("Digraphs: DigraphDisjointUnion: usage,\n",
                  "the arguments must be digraphs, or the argument must be a ",
                  "list of digraphs,");
  fi;

  out := EmptyPlist(Sum(arg, DigraphNrVertices));
  offset := 0;

  for gr in arg do
    n := DigraphNrVertices(gr);
    out{[offset + 1 .. offset + n]} := OutNeighbours(gr) + offset;
    offset := offset + n;
  od;

  new := DigraphNC(out);
  if ForAll(arg, HasDigraphNrEdges) then
    SetDigraphNrEdges(new, Sum(arg, DigraphNrEdges));
  fi;
  return new;
end);

#

InstallGlobalFunction(DigraphJoin, "for digraphs or a list of digraphs",
function(arg)
  local tot, out, offset, n, nbs, gr, i;

  # allow user the possibility of supplying arguments in a list
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;

  if not IsList(arg) or IsEmpty(arg) or not ForAll(arg, IsDigraph) then
    ErrorNoReturn("Digraphs: DigraphJoin: usage,\n",
                  "the arguments must be digraphs, or the argument must be a ",
                  "list of digraphs,");
  fi;

  tot := Sum(arg, DigraphNrVertices);
  out := EmptyPlist(tot);
  offset := 0;

  for gr in arg do
    n := DigraphNrVertices(gr);
    nbs := OutNeighbours(gr);
    for i in DigraphVertices(gr) do
      out[i + offset] := Concatenation([1 .. offset], nbs[i] + offset,
                                       [offset + n + 1 .. tot]);
    od;
    offset := offset + n;
  od;

  return DigraphNC(out);
end);

#

InstallMethod(IsReachable, "for a digraph and two pos ints",
[IsDigraph, IsPosInt, IsPosInt],
function(digraph, u, v)
  local verts, scc;

  verts := DigraphVertices(digraph);
  if not (u in verts and v in verts) then
    ErrorNoReturn("Digraphs: IsReachable: usage,\n",
                  "the second and third arguments <u> and <v> must be\n",
                  "vertices of the first argument <digraph>,");
  fi;

  if IsDigraphEdge(digraph, [u, v]) then
    return true;
  elif HasIsTransitiveDigraph(digraph) and IsTransitiveDigraph(digraph) then
    # If it's a known transitive digraph, just check whether the edge exists
    return false;
    # Glean information from WCC if we have it
  elif HasDigraphConnectedComponents(digraph)
      and DigraphConnectedComponents(digraph).id[u] <>
          DigraphConnectedComponents(digraph).id[v] then
    return false;
    # Glean information from SCC if we have it
  elif HasDigraphStronglyConnectedComponents(digraph) then
    scc := DigraphStronglyConnectedComponents(digraph);
    if u <> v then
      if scc.id[u] = scc.id[v] then
        return true;
      fi;
    else
      return Length(scc.comps[scc.id[u]]) > 1;
    fi;
  fi;

  return DIGRAPHS_IS_REACHABLE(OutNeighbours(digraph), u, v);
end);

#

InstallMethod(DigraphRemoveAllMultipleEdges, "for a digraph",
[IsDigraph],
function(digraph)
  local n, verts, old_adj, new_adj, tot, seen, count, gr, i, j;

  n := DigraphNrVertices(digraph);
  verts := DigraphVertices(digraph);
  old_adj := OutNeighbours(digraph);
  new_adj := EmptyPlist(n);
  tot := 0;
  for i in verts do
    seen := BlistList(verts, []);
    count := 0;
    new_adj[i] := [];
    for j in old_adj[i] do
      if not seen[j] then
        seen[j] := true;
        count := count + 1;
        tot := tot + 1;
        new_adj[i][count] := j;
      fi;
    od;
  od;
  gr := DigraphNC(new_adj, tot);
  SetDigraphVertexLabels(gr, DigraphVertexLabels(digraph));
  SetIsMultiDigraph(gr, false);
  return gr;
end);

InstallMethod(OutNeighboursCopy, "for a digraph",
[IsDigraph],
function(digraph)
  return List(OutNeighbours(digraph), ShallowCopy);
end);

InstallMethod(DigraphLongestDistanceFromVertex, "for a digraph and a pos int",
[IsDigraph, IsPosInt],
function(digraph, v)
  local dist;

  if not v in DigraphVertices(digraph) then
    ErrorNoReturn("Digraphs: DigraphLongestDistanceFromVertex: usage,\n",
                  "the second argument <v> must be a vertex of the first ",
                  "argument, <digraph>,");
  fi;
  dist := DIGRAPH_LONGEST_DIST_VERTEX(OutNeighbours(digraph), v);
  if dist = -2 then
    return infinity;
  fi;
  return dist;
end);

# For a topologically sortable digraph G
# This returns the least subgraph G' of G such that
# the (reflexive) transitive closures of G and G' are equal

InstallMethod(DigraphReflexiveTransitiveReduction, "for a digraph",
[IsDigraph],
function(digraph)
  if IsMultiDigraph(digraph) then
    ErrorNoReturn("Digraphs: DigraphReflexiveTransitiveReduction: usage,\n",
                  "this method does not work for MultiDigraphs,");
  fi;
  if DigraphTopologicalSort(digraph) = fail then
    ErrorNoReturn("Digraphs: DigraphReflexiveTransitiveReduction:\n",
                  "not yet implemented for non-topologically sortable ",
                  "digraphs,");
  fi;
  return DigraphTransitiveReductionNC(digraph, false);
end);

InstallMethod(DigraphTransitiveReduction, "for a digraph",
[IsDigraph],
function(digraph)
  if IsMultiDigraph(digraph) then
    ErrorNoReturn("Digraphs: DigraphTransitiveReduction: usage,\n",
                  "this method does not work for MultiDigraphs,");
  fi;
  if DigraphTopologicalSort(digraph) = fail then
    ErrorNoReturn("Digraphs: DigraphTransitiveReduction:\n",
                  "not yet implemented for non-topologically sortable ",
                  "digraphs,");
  fi;
  return DigraphTransitiveReductionNC(digraph, true);
end);

InstallMethod(DigraphTransitiveReductionNC, "for a digraph and a bool",
[IsDigraph, IsBool],
function(gr, loops)
  local topo, p, new, inn, out;

  if DigraphNrVertices(gr) = 0 then
    return gr;
  fi;

  topo := DigraphTopologicalSort(gr);
  p := Permutation(Transformation(topo), topo);
  new := OnDigraphs(gr, p ^ -1);
  inn := InNeighbours(new);
  out := DIGRAPH_TRANS_REDUCTION(inn, loops);
  return OnDigraphs(Digraph(out), p);
end);

#

InstallMethod(DigraphLayers, "for a digraph, and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  local layers, gens, sch, trace, rep, word, orbs, layers_with_orbnums,
        layers_of_v, i, x;

  # TODO: make use of known distances matrix
  if v > DigraphNrVertices(digraph) then
    ErrorNoReturn("Digraphs: DigraphLayers: usage,\n",
                  "the argument <v> must be a vertex of <digraph>,");
  fi;

  layers := DIGRAPHS_Layers(digraph);

  if IsBound(layers[v]) then
    return layers[v];
  fi;

  if HasDigraphGroup(digraph) then
    gens  := GeneratorsOfGroup(DigraphGroup(digraph));
    sch   := DigraphSchreierVector(digraph);
    trace := DIGRAPHS_TraceSchreierVector(gens, sch, v);
    rep   := DigraphOrbitReps(digraph)[trace.representative];
    word  := DIGRAPHS_EvaluateWord(gens, trace.word);
    if rep <> v then
      layers[v] := List(DigraphLayers(digraph, rep),
                        x -> OnTuples(x, word));
      return layers[v];
    fi;
    orbs := DIGRAPHS_Orbits(DigraphStabilizer(digraph, v),
                            DigraphVertices(digraph)).orbits;
  else
    rep  := v;
    orbs := List(DigraphVertices(digraph), x -> [x]);
  fi;

  # from now on rep = v
  layers_with_orbnums := DIGRAPH_ConnectivityDataForVertex(digraph, v).layers;

  layers_of_v := [[v]];
  for i in [2 .. Length(layers_with_orbnums)] do
    Add(layers_of_v, []);
    for x in layers_with_orbnums[i] do
      Append(layers_of_v[i], orbs[x]);
    od;
  od;

  layers[v] := layers_of_v;
  return layers[v];
end);

#

InstallMethod(DIGRAPHS_Layers, "for a digraph",
[IsDigraph],
function(digraph)
  return [];
end);
#

InstallMethod(DigraphDistanceSet,
"for a digraph, a vertex, and a non-negative integers",
[IsDigraph, IsPosInt, IsInt],
function(digraph, vertex, distance)

  if vertex > DigraphNrVertices(digraph) then
    ErrorNoReturn("Digraphs: DigraphDistanceSet: usage,\n",
                  "the second argument must be a vertex of the digraph,");
  fi;
  if distance < 0 then
    ErrorNoReturn("Digraphs: DigraphDistanceSet: usage,\n",
                  "the third argument must be a non-negative integer,");
  fi;

  return DigraphDistanceSet(digraph, vertex, [distance]);
end);

#

InstallMethod(DigraphDistanceSet,
"for a digraph, a vertex, and a list of non-negative integers",
[IsDigraph, IsPosInt, IsList],
function(digraph, vertex, distances)
  local layers;

  if vertex > DigraphNrVertices(digraph) then
    ErrorNoReturn("Digraphs: DigraphDistanceSet: usage,\n",
                  "the second argument must be a vertex of the digraph,");
  fi;

  if not ForAll(distances, x -> IsInt(x) and x >= 0) then
    ErrorNoReturn("Digraphs: DigraphDistanceSet: usage,\n",
                  "the third argument must be a list of non-negative ",
                  "integers,");
  fi;

  distances := distances + 1;
  layers := DigraphLayers(digraph, vertex);
  distances := Intersection(distances, [1 .. Length(layers)]);
  return Concatenation(layers{distances});
end);

#

InstallMethod(DigraphShortestDistance,
"for a digraph, a vertex, and a vertex",
[IsDigraph, IsPosInt, IsPosInt],
function(digraph, u, v)
  local dist;

  if u > DigraphNrVertices(digraph) or v > DigraphNrVertices(digraph) then
    ErrorNoReturn("Digraphs: DigraphShortestDistance: usage,\n",
                  "the second argument and third argument must be\n",
                  "vertices of the digraph,");
  fi;

  if HasDigraphShortestDistances(digraph) then
    return DigraphShortestDistances(digraph)[u][v];
  fi;

  dist := DIGRAPH_ConnectivityDataForVertex(digraph, u).layerNumbers[v] - 1;
  if dist = -1 then
    dist := fail;
  fi;
  return dist;
end);

#

InstallMethod(DigraphShortestDistance,
"for a digraph, a list, and a list",
[IsDigraph, IsList, IsList],
function(digraph, list1, list2)
  local shortest, u, v;

  # TODO: can this be improved?
  shortest := infinity;
  for u in list1 do
    for v in list2 do
      if shortest > DigraphShortestDistance(digraph, u, v) then
        shortest := DigraphShortestDistance(digraph, u, v);
      fi;
    od;
  od;
  return shortest;
end);

#

InstallMethod(DigraphShortestDistance,
"for a digraph, and a list",
[IsDigraph, IsList],
function(digraph, list)

  if Length(list) <> 2 then
    ErrorNoReturn("Digraphs: DigraphShortestDistance: usage,\n",
                  "the second argument must be of length 2,");
  fi;

  if list[1] > DigraphNrVertices(digraph) or
      list[2] > DigraphNrVertices(digraph) then
    ErrorNoReturn("Digraphs: DigraphShortestDistance: usage,\n",
                  "elements of the list must be vertices of the digraph,");
  fi;

  return DigraphShortestDistance(digraph, list[1], list[2]);
end);

#

InstallMethod(DigraphColoring, "for a digraph", [IsDigraph],
function(digraph)
  local vertices, maxcolour, out_nbs, in_nbs, colouring, usedcolours,
        nextcolour, v, u;

  if DigraphNrVertices(digraph) = 0  then
    return fail;
  fi;

  vertices  := DigraphVertices(digraph);
  maxcolour := 0;
  out_nbs   := OutNeighbours(digraph);
  in_nbs    := InNeighbours(digraph);

  colouring := [];

  for v in vertices do
    usedcolours := BlistList([1 .. maxcolour + 1], []);
    for u in out_nbs[v] do
      if IsBound(colouring[u]) then
        usedcolours[colouring[u]] := true;
      fi;
    od;
    for u in in_nbs[v] do
      if IsBound(colouring[u]) then
        usedcolours[colouring[u]] := true;
      fi;
    od;
    nextcolour := 1;
    while usedcolours[nextcolour] do
      nextcolour := nextcolour + 1;
    od;
    colouring[v] := nextcolour;
    if colouring[v] > maxcolour then
      maxcolour := colouring[v];
    fi;
  od;

  return Transformation(colouring);
end);
