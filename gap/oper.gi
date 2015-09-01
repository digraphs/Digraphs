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

#

InstallMethod(DigraphEdgeUnion, "for digraphs",
[IsDigraph, IsDigraph],
function(graph1, graph2)
  local m, n, outm, outn, out, i;

  if DigraphNrVertices(graph1) > DigraphNrVertices(graph2) then
    m := DigraphNrVertices(graph2); # smaller graph
    n := DigraphNrVertices(graph1);
    outm := OutNeighbours(graph2); # out neighbours of smaller graph
    outn := OutNeighbours(graph1);
  else
    m := DigraphNrVertices(graph1);
    n := DigraphNrVertices(graph2);
    outm := OutNeighbours(graph1);
    outn := OutNeighbours(graph2);
  fi;

  out := EmptyPlist(n);

  for i in [1 .. m] do
    out[i] := Concatenation(outm[i], outn[i]);
  od;

  for i in [m + 1 .. n] do
    out[i] := ShallowCopy(outn[i]);
  od;

  if HasDigraphNrEdges(graph1) and HasDigraphNrEdges(graph2) then
    return DigraphNC(out, DigraphNrEdges(graph1) + DigraphNrEdges(graph2));
  fi;
  return DigraphNC(out);
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
    ErrorMayQuit("Digraphs: DigraphReverseEdges: usage,\n",
                 "the first argument <digraph> must not be a multigraph,");
  fi;

  # A rectangular table is always non-empty so

  if not IsPosInt(edges[1][1]) or
      not ForAll(edges, x -> IsDigraphEdge(digraph, x)) then
    ErrorMayQuit("Digraphs: DigraphReverseEdges: usage,\n",
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
    ErrorMayQuit("Digraphs: DigraphReverseEdges: usage,\n",
                 "the first argument <digraph> must not be a multigraph,");
  fi;

  if Length(edges) = 0 then
    return DigraphCopy(digraph);
  fi;

  nredges := DigraphNrEdges(digraph);
  if not IsPosInt(edges[1]) or
      not IsHomogeneousList(edges) or
      not ForAll(edges, x -> x <= nredges) then
    ErrorMayQuit("Digraphs: DigraphReverseEdges: usage,\n",
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
  return out;
end);

#

InstallMethod(DigraphRemoveEdge, "for a digraph and a list of two pos ints",
[IsDigraph, IsHomogeneousList],
function(digraph, edge)
  local verts;

  if IsMultiDigraph(digraph) then
      ErrorMayQuit("Digraphs: DigraphRemoveEdge: usage,\nthe ",
                   "first argument <digraph> must not have multiple edges\n",
                   "when the second argument <edges> is a pair of vertices,");
  fi;
  verts := DigraphVertices(digraph);
  if Length(edge) <> 2
      or not IsPosInt(edge[1])
      or not edge[1] in verts
      or not edge[2] in verts then
    ErrorMayQuit("Digraphs: DigraphRemoveEdge: usage,\n",
                 "the second argument <edge> must be a pair of vertices of ",
                 "<digraph>,");
  fi;
  return DigraphRemoveEdges(digraph, [edge]);
end);

InstallMethod(DigraphRemoveEdge, "for a digraph and a pos int",
[IsDigraph, IsPosInt],
function(digraph, edge)
  local m;

  m := DigraphNrEdges(digraph);
  if edge > m then
    ErrorMayQuit("Digraphs: DigraphRemoveEdge: usage,\n",
                 "the second argument <edge> must be the index of an edge in ",
                 "<digraph>,");
  fi;
  return DigraphRemoveEdgesNC(digraph, [edge]);
end);

InstallMethod(DigraphRemoveEdges, "for a digraph and a list",
[IsDigraph, IsHomogeneousList],
function(digraph, edges)
  local m, verts, remove, n, old_adj, count, offsets, pos, i, x;

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
      ErrorMayQuit("Digraphs: DigraphRemoveEdges: usage,\n",
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
    ErrorMayQuit("Digraphs: DigraphRemoveEdges: usage,\n",
                 "the second argument <edges> must be a list of indices of\n",
                 "edges or a list of edges of the first argument <digraph>,");
  fi;
  return DigraphRemoveEdgesNC(digraph, remove);
end);

# DigraphRemoveEdgesNC assumes you are removing edges by index

InstallMethod(DigraphRemoveEdgesNC, "for a digraph and a list",
[IsDigraph, IsHomogeneousList],
function(digraph, edges)
  local m, n, old_adj, new_adj, old_edge_count, new_edge_count, degree_count,
  old_labs, new_labs, gr, i, j;

  if IsEmpty(edges) then
    return DigraphCopy(digraph);
  fi;

  m := DigraphNrEdges(digraph);
  n := DigraphNrVertices(digraph);
  old_adj := OutNeighbours(digraph);
  new_adj := EmptyPlist(n);
  edges := BlistList([1 .. m], edges);
  old_edge_count := 0;
  new_edge_count := 0;
  degree_count := 0;
  old_labs := DigraphEdgeLabels(digraph);
  new_labs := [];
  for i in DigraphVertices(digraph) do # Loop over each vertex
    new_adj[i] := [];
    degree_count := 0;
    for j in old_adj[i] do
      old_edge_count := old_edge_count + 1;
      if not edges[old_edge_count] then # Keep this edge
        new_edge_count := new_edge_count + 1;
        degree_count := degree_count + 1;
        new_adj[i][degree_count] := j;
        new_labs[new_edge_count] := old_labs[old_edge_count];
      fi;
    od;
  od;
  gr := DigraphNC(new_adj);
  SetDigraphVertexLabels(gr, DigraphVertexLabels(digraph));
  SetDigraphEdgeLabels(gr, new_labs);
  return gr;
end);

#

InstallMethod(DigraphAddEdge, "for a digraph and an edge",
[IsDigraph, IsList],
function(digraph, edge)
  local verts;

  verts := DigraphVertices(digraph);
  if Length(edge) <> 2
      or not IsPosInt(edge[1])
      or not IsPosInt(edge[2])
      or not edge[1] in verts
      or not edge[2] in verts then
    ErrorMayQuit("Digraphs: DigraphAddEdge: usage,\n",
                 "the second argument <edge> must be a pair of vertices of ",
                 "<digraph>,");
  fi;

  return DigraphAddEdgesNC(digraph, [edge]);
end);

InstallMethod(DigraphAddEdges, "for a digraph and a list",
[IsDigraph, IsList],
function(digraph, edges)
  local vertices, edge;

  if not IsEmpty(edges) and
      (not IsList(edges[1])
       or not Length(edges[1]) = 2
       or not IsPosInt(edges[1][1])
       or not IsRectangularTable(edges)) then
    ErrorMayQuit("Digraphs: DigraphAddEdges: usage,\n",
                 "the second argument <edges> must be a list of pairs of ",
                 "vertices\nof the first argument <digraph>,");
  fi;

  vertices := DigraphVertices(digraph);
  for edge in edges do
    if not (edge[1] in vertices and edge[2] in vertices) then
      ErrorMayQuit("Digraphs: DigraphAddEdges: usage,\n",
                   "the second argument <edges> must be a list of pairs of ",
                   "vertices\nof the first argument <digraph>,");
    fi;
  od;

  return DigraphAddEdgesNC(digraph, edges);
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
    ErrorMayQuit("Digraphs: DigraphAddVertices: usage,\n",
                 "the second argument <m> (the number of vertices to add) ",
                 "must be non-negative,");
  fi;
  return DigraphAddVerticesNC(digraph, m, []);
end);

InstallMethod(DigraphAddVertices, "for a digraph, a pos int and a list",
[IsDigraph, IsInt, IsList],
function(digraph, m, names)
  if m < 0 then
    ErrorMayQuit("Digraphs: DigraphAddVertices: usage,\n",
                 "the second argument <m> (the number of vertices to add) ",
                 "must be non-negative,");
  elif Length(names) <> m then
    ErrorMayQuit("Digraphs: DigraphAddVertices: usage,\n",
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
  SetDigraphEdgeLabels(out, DigraphEdgeLabels(digraph));
  return out;
end);

#

InstallMethod(DigraphRemoveVertex, "for a digraph and a pos int",
[IsDigraph, IsPosInt],
function(digraph, m)
  if m > DigraphNrVertices(digraph) then
    ErrorMayQuit("Digraphs: DigraphRemoveVertex: usage,\n",
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
    ErrorMayQuit("Digraphs: DigraphRemoveVertices: usage,\n",
                 "the second argument <verts> should be a duplicate free ",
                 "list of vertices of\nthe first argument <digraph>,");
  fi;
  return DigraphRemoveVerticesNC(digraph, verts);
end);

#

InstallMethod(DigraphRemoveVerticesNC, "for a digraph and a list",
[IsDigraph, IsList],
function(digraph, verts)
  local n, len, new_nrverts, m, log, diff, j, lookup, old_edge_count,
  old_labels, new_edge_count, new_labels, new_vertex_count, old_nbs, new_nbs,
  gr, i, x;

  if IsEmpty(verts) then
    return DigraphCopy(digraph);
  fi;

  n := DigraphNrVertices(digraph);
  len := Length(verts);
  new_nrverts := n - len;
  if new_nrverts = 0 then
    return EmptyDigraph(0);
  fi;
  m     := DigraphNrEdges(digraph);
  log   := LogInt(len, 2);
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

  old_edge_count   := 0;
  old_labels       := DigraphEdgeLabels(digraph);
  new_edge_count   := 0;
  new_labels       := [];
  new_vertex_count := 0;

  old_nbs := OutNeighbours(digraph);
  new_nbs := EmptyPlist(new_nrverts);
  for i in DigraphVertices(digraph) do
    if IsBound(lookup[i]) then
      new_vertex_count := new_vertex_count + 1;
      new_nbs[new_vertex_count] := [];
      j := 0;
      for x in old_nbs[i] do
        old_edge_count := old_edge_count + 1;
        if not x in verts then # Can search through diff if |diff| < |verts|
          j := j + 1;
          new_nbs[new_vertex_count][j] := lookup[x];
          new_edge_count := new_edge_count + 1;
          new_labels[new_edge_count] := old_labels[old_edge_count];
        fi;
      od;
    else
      old_edge_count := old_edge_count + Length(old_nbs[i]);
    fi;
  od;

  gr := DigraphNC(new_nbs);
  SetDigraphVertexLabels(gr, DigraphVertexLabels(digraph){diff});
  SetDigraphEdgeLabels(gr, new_labels);
  return gr;
end);

#

InstallMethod(OnDigraphs, "for a digraph and a perm",
[IsDigraph, IsPerm],
function(graph, perm)
  local adj;

  if ForAny(DigraphVertices(graph),
            i -> i ^ perm > DigraphNrVertices(graph)) then
    ErrorMayQuit("Digraphs: OnDigraphs: usage,\n",
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
    ErrorMayQuit("Digraphs: OnDigraphs: usage,\n",
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
    ErrorMayQuit("Digraphs: OnMultiDigraphs: usage,\n",
                 "the 2nd argument must be a pair of permutations,");
  fi;

  if ForAny([1 .. DigraphNrEdges(graph)],
            i -> i ^ perms[2] > DigraphNrEdges(graph)) then
    ErrorMayQuit("Digraphs: OnMultiDigraphs: usage,\n",
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
  local nr, n, old_labs, old_adj, new_labs, new_adj, offsets, lookup,
  new_edge_count, adji, j, l, gr, i, k;

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
    ErrorMayQuit("Digraphs: InducedSubdigraph: usage,\n",
                 "the second argument <subverts> must be a duplicate-free ",
                 "subset\nof the vertices of the first argument <digraph>,");
  fi;

  old_labs := DigraphEdgeLabels(digraph);
  old_adj  := OutNeighbours(digraph);
  new_labs := [];
  new_adj  := EmptyPlist(nr);

  offsets := EmptyPlist(n);
  offsets[1] := 0;
  for i in [2 .. Maximum(subverts)] do
    offsets[i] := offsets[i - 1] + Length(old_adj[i - 1]);
  od;

  lookup := [1 .. n] * 0;
  lookup{subverts} := [1 .. nr];
  new_edge_count := 0;

  for i in [1 .. nr] do
    adji := [];
    j := 0;
    for k in [1 .. Length(old_adj[subverts[i]])] do
      l := lookup[old_adj[subverts[i]][k]];
      if l <> 0 then
        j := j + 1;
        adji[j] := l;
        new_edge_count := new_edge_count + 1;
        new_labs[new_edge_count] := old_labs[offsets[subverts[i]] + k];
      fi;
    od;
    new_adj[i] := adji;
  od;

  gr := DigraphNC(new_adj);
  SetDigraphVertexLabels(gr, DigraphVertexLabels(digraph){subverts});
  SetDigraphEdgeLabels(gr, new_labs);
  return gr;
end);

#

InstallMethod(InNeighborsOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  return InNeighboursOfVertex(digraph, v);
end);

InstallMethod(InNeighboursOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  if not v in DigraphVertices(digraph) then
    ErrorMayQuit("Digraphs: InNeighboursOfVertex: usage,\n",
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

InstallMethod(OutNeighborsOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  return OutNeighboursOfVertex(digraph, v);
end);

InstallMethod(OutNeighboursOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  if not v in DigraphVertices(digraph) then
    ErrorMayQuit("Digraphs: OutNeighboursOfVertex: usage,\n",
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
    ErrorMayQuit("Digraphs: InDegreeOfVertex: usage,\n",
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
    ErrorMayQuit("Digraphs: OutDegreeOfVertex: usage,\n",
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
    ErrorMayQuit("Digraphs: QuotientDigraph: usage,\n",
                 "the second argument <partition> is not a valid partition ",
                 "of the\nvertices of the null digraph <digraph>. The only ",
                 "valid partition\nof <digraph> is the empty list,");
  fi;
  nr := Length(partition);
  if n = 0 or nr = 0 or not IsList(partition[1])
      or IsEmpty(partition[1]) or not IsPosInt(partition[1][1]) then
    ErrorMayQuit("Digraphs: QuotientDigraph: usage,\n",
                 "the second argument <partition> is not a valid partition\n",
                 "of the vertices of <digraph>, [ 1 .. ", n, " ],");
  fi;

  check := BlistList(DigraphVertices(digraph), []);
  lookup := EmptyPlist(n);

  for x in [1 .. Length(partition)] do
    for i in partition[x] do
      if i < 1 or i > n or check[i] then
        ErrorMayQuit("Digraphs: QuotientDigraph: usage,\n",
                     "the second argument <partition> is not a valid\n",
                     "partition of the vertices of <digraph>, ",
                     "[ 1 .. ", n, " ],");
      fi;
      check[i] := true;
      lookup[i] := x;
    od;
  od;

  if ForAny(check, x -> not x) then
    ErrorMayQuit("Digraphs: QuotientDigraph: usage,\n",
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
    ErrorMayQuit("Digraphs: DigraphOutEdges: usage,\n",
                 v, " is not a vertex of the digraph,");
  fi;

  return List(OutNeighboursOfVertex(digraph, v), x -> [v, x]);
end);

#

InstallMethod(DigraphInEdges, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  if not v in DigraphVertices(digraph) then
    ErrorMayQuit("Digraphs: DigraphInEdges: usage,\n",
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
    ErrorMayQuit("Digraphs: DigraphStronglyConnectedComponent: usage,\n",
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
    ErrorMayQuit("Digraphs: DigraphConnectedComponent: usage,\n",
                 v, " is not a vertex of the digraph,");
  fi;

  wcc := DigraphConnectedComponents(digraph);
  return wcc.comps[wcc.id[v]];
end);

#

InstallMethod(IsDigraphEdge, "for a digraph and a list",
[IsDigraph, IsList],
function(digraph, edge)
  local n;

  n := DigraphNrVertices(digraph);
  if Length(edge) <> 2 or not IsPosInt(edge[1]) or not IsPosInt(edge[2])
      or n < edge[1] or n < edge[2] then
    return false;
  fi;
  if HasAdjacencyMatrix(digraph) then
    return AdjacencyMatrix(digraph)[edge[1]][edge[2]] <> 0;
  fi;
  if edge[2] in OutNeighboursOfVertex(digraph, edge[1]) then
    return true;
  fi;
  return false;
end);

#

InstallMethod(AsBinaryRelation, "for a digraph",
[IsDigraph],
function(digraph)
  local rel;

  if DigraphNrVertices(digraph) = 0 then
    ErrorMayQuit("Digraphs: AsBinaryRelation: usage,\n",
                 "the argument <digraph> must have at least one vertex,");
  elif IsMultiDigraph(digraph) then
    ErrorMayQuit("Digraphs: AsBinaryRelation: usage,\n",
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

InstallMethod(DigraphDisjointUnion, "for two digraphs",
[IsDigraph, IsDigraph],
function(digraph1, digraph2)
  local nrvertices1, out2;

  nrvertices1 := DigraphNrVertices(digraph1);
  out2 := List(OutNeighbours(digraph2), x -> x + nrvertices1);

  return DigraphNC(Concatenation(OutNeighbours(digraph1), out2));
end);

#

InstallMethod(DigraphJoin, "for two digraphs",
[IsDigraph, IsDigraph],
function(digraph1, digraph2)
  local out1, out2, n, m, new, i;

  out1 := OutNeighbours(digraph1);
  out2 := OutNeighbours(digraph2);
  n    := DigraphNrVertices(digraph1);
  m    := DigraphNrVertices(digraph2);
  new  := EmptyPlist(n + m);

  for i in DigraphVertices(digraph1) do
    new[i] := Concatenation(out1[i], [n + 1 .. n + m]);
  od;
  for i in [n + 1 .. n +  m] do
    new[i] := Concatenation([1 .. n], out2[i - n] + n);
  od;

  return DigraphNC(new);
end);

#

InstallMethod(IsReachable, "for a digraph and two pos ints",
[IsDigraph, IsPosInt, IsPosInt],
function(digraph, u, v)
  local verts, scc;

  verts := DigraphVertices(digraph);
  if not (u in verts and v in verts) then
    ErrorMayQuit("Digraphs: IsReachable: usage,\n",
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

InstallMethod(OutNeighborsCopy, "for a digraph",
[IsDigraph], OutNeighboursCopy);

InstallMethod(DigraphLongestDistanceFromVertex, "for a digraph and a pos int",
[IsDigraph, IsPosInt],
function(digraph, v)
  local dist;

  if not v in DigraphVertices(digraph) then
    ErrorMayQuit("Digraphs: DigraphLongestDistanceFromVertex: usage,\n",
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
    ErrorMayQuit("Digraphs: DigraphReflexiveTransitiveReduction: usage,\n",
                 "this method does not work for MultiDigraphs,");
  fi;
  if DigraphTopologicalSort(digraph) = fail then
    ErrorMayQuit("Digraphs: DigraphReflexiveTransitiveReduction:\n",
                 "not yet implemented for non-topologically sortable ",
                 "digraphs,");
  fi;
  return DigraphTransitiveReductionNC(digraph, false);
end);

InstallMethod(DigraphTransitiveReduction, "for a digraph",
[IsDigraph],
function(digraph)
  if IsMultiDigraph(digraph) then
    ErrorMayQuit("Digraphs: DigraphTransitiveReduction: usage,\n",
                 "this method does not work for MultiDigraphs,");
  fi;
  if DigraphTopologicalSort(digraph) = fail then
    ErrorMayQuit("Digraphs: DigraphTransitiveReduction:\n",
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
