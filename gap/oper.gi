#############################################################################
##
##  oper.gi
##  Copyright (C) 2014-19                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

#############################################################################
# This file is organised as follows:
#
# 1.  Adding and removing vertices
# 2.  Adding and removing loops
# 3.  Adding and removing edges
# 4.  Actions
# 5.  Substructures and quotients
# 6.  In and out degrees and edges of vertices
# 7.  Copies of out/in-neighbours
# 8.  IsSomething
# 9.  Connectivity
# 10. Operations for vertices
#############################################################################

#############################################################################
# 1. Adding and removing vertices
#############################################################################

InstallMethod(DigraphAddVertex, "for a mutable dense digraph and an object",
[IsMutableDigraph and IsDenseDigraphRep, IsObject],
function(D, label)
  Add(D!.OutNeighbours, []);
  SetDigraphVertexLabel(D, DigraphNrVertices(D), label);
  return D;
end);

InstallMethod(DigraphAddVertex, "for a immutable digraph and an object",
[IsImmutableDigraph, IsObject],
function(D, label)
  return MakeImmutableDigraph(DigraphAddVertex(DigraphMutableCopy(D), label));
end);

InstallMethod(DigraphAddVertex, "for a mutable digraph",
[IsMutableDigraph],
function(D)
  return DigraphAddVertex(D, DigraphNrVertices(D) + 1);
end);

InstallMethod(DigraphAddVertex, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  return MakeImmutableDigraph(DigraphAddVertex(DigraphMutableCopy(D)));
end);

InstallMethod(DigraphAddVertices, "for a mutable digraph and list",
[IsMutableDigraph, IsList],
function(D, labels)
  local label;
  for label in labels do
    DigraphAddVertex(D, label);
  od;
  return D;
end);

InstallMethod(DigraphAddVertices, "for an immutable digraph and list",
[IsImmutableDigraph, IsList],
function(D, labels)
  return MakeImmutableDigraph(DigraphAddVertices(DigraphMutableCopy(D),
                                                 labels));
end);

InstallMethod(DigraphAddVertices, "for a mutable digraph and an integer",
[IsMutableDigraph, IsInt],
function(D, m)
  local N;
  if m < 0 then
    ErrorNoReturn("the 2nd argument (the number of vertices to add) ",
                  "must be non-negative,");
  fi;
  N := DigraphNrVertices(D);
  return DigraphAddVertices(D, [N + 1 .. N + m]);
end);

InstallMethod(DigraphAddVertices, "for an immutable digraph and an integer",
[IsImmutableDigraph, IsInt],
function(D, m)
  return MakeImmutableDigraph(DigraphAddVertices(DigraphMutableCopy(D), m));
end);

InstallMethod(DigraphRemoveVertex,
"for a mutable dense digraph and positive integer",
[IsMutableDigraph and IsDenseDigraphRep, IsPosInt],
function(D, u)
  local pos, w, v;
  if u > DigraphNrVertices(D) then
    return D;
  fi;
  Remove(D!.OutNeighbours, u);
  RemoveDigraphVertexLabel(D, u);
  for v in DigraphVertices(D) do
    pos := 1;
    while pos <= Length(D!.OutNeighbours[v]) do
      w := D!.OutNeighbours[v][pos];
      if w = u then
        Remove(D!.OutNeighbours[v], pos);
      elif w > u then
         D!.OutNeighbours[v][pos] := w - 1;
         pos := pos + 1;
      else
         pos := pos + 1;
      fi;
    od;
  od;
  return D;
end);

InstallMethod(DigraphRemoveVertex,
"for an immutable digraph and positive integer",
[IsImmutableDigraph, IsPosInt],
function(D, m)
  return MakeImmutableDigraph(DigraphRemoveVertex(DigraphMutableCopy(D), m));
end);

InstallMethod(DigraphRemoveVertices, "for a mutable digraph and a list",
[IsMutableDigraph, IsList],
function(D, list)
  local v;
  if not IsDuplicateFreeList(list) then
    ErrorNoReturn("the 2nd argument (list of vertices to remove) must be ",
                  "duplicate-free,");
  elif not ForAll(list, IsPosInt) then
    ErrorNoReturn("the 2nd argument (list of vertices to remove) must ",
                  "consist of positive integers,");
  fi;

  if not IsMutable(list) then
    list := ShallowCopy(list);
  fi;
  # The next line is essential since otherwise removing the 1st node,
  # the 2nd node becomes the 1st node, and so removing the 2nd node we
  # actually remove the 3rd node instead.
  Sort(list, {x, y} -> x > y);
  for v in list do
    DigraphRemoveVertex(D, v);
  od;
  return D;
end);

InstallMethod(DigraphRemoveVertices, "for an immutable digraph and a list",
[IsImmutableDigraph, IsList],
function(D, list)
  D := DigraphRemoveVertices(DigraphMutableCopy(D), list);
  return MakeImmutableDigraph(D);
end);

#############################################################################
# 2. Adding and removing loops
#############################################################################

InstallMethod(DigraphAddAllLoops, "for a mutable dense digraph",
[IsMutableDigraph and IsDenseDigraphRep],
function(D)
  local list, v;
  list := D!.OutNeighbours;
  Assert(1, IsMutable(list));
  for v in DigraphVertices(D) do
    if not v in list[v] then
      Add(list[v], v);
    fi;
  od;
  return D;
end);

InstallMethod(DigraphAddAllLoops, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  local E;
  E := MakeImmutableDigraph(DigraphAddAllLoops(DigraphMutableCopy(D)));
  SetDigraphHasLoops(E, DigraphNrVertices(E) > 1);
  return E;
end);

InstallMethod(DigraphRemoveLoops, "for a mutable dense digraph",
[IsMutableDigraph and IsDenseDigraphRep],
function(D)
  local out, lbl, pos, v;
  out := D!.OutNeighbours;
  lbl := DigraphEdgeLabelsNC(D);
  for v in DigraphVertices(D) do
    pos := Position(out[v], v);
    while pos <> fail do
      Remove(out[v], pos);
      Remove(lbl[v], pos);
      pos := Position(out[v], v);
    od;
  od;
  return D;
end);

InstallMethod(DigraphRemoveLoops, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  local E;
  E := MakeImmutableDigraph(DigraphRemoveLoops(DigraphMutableCopy(D)));
  SetDigraphHasLoops(E, false);
  return E;
end);

#############################################################################
# 3. Adding and removing edges
#############################################################################

InstallMethod(DigraphAddEdge,
"for a mutable dense digraph, a positive integer, and a positive integer",
[IsMutableDigraph and IsDenseDigraphRep, IsPosInt, IsPosInt],
function(D, src, ran)
  if not src in DigraphVertices(D)then
    ErrorNoReturn("the 2nd argument must be a vertex of the ",
                  "1st argument (a digraph), ");
  elif not ran in DigraphVertices(D) then
    ErrorNoReturn("the 3rd argument must be a vertex of the ",
                  "1st argument (a digraph), ");
  fi;
  Add(D!.OutNeighbours[src], ran);
  if not IsMultiDigraph(D) then
    SetDigraphEdgeLabel(D, src, ran, 1);
  fi;
  return D;
end);

InstallMethod(DigraphAddEdge,
"for an immutable digraph, a positive integer, and a positive integer",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(D, src, ran)
  return MakeImmutableDigraph(DigraphAddEdge(DigraphMutableCopy(D), src, ran));
end);

InstallMethod(DigraphAddEdge, "for a mutable digraph and a list",
[IsMutableDigraph, IsList],
function(D, edge)
  if Length(edge) <> 2 then
    ErrorNoReturn("the 2nd argument must be a list of length 2,");
  fi;
  return DigraphAddEdge(D, edge[1], edge[2]);
end);

InstallMethod(DigraphAddEdge, "for a mutable digraph and a list",
[IsImmutableDigraph, IsList],
function(D, edge)
  return MakeImmutableDigraph(DigraphAddEdge(DigraphMutableCopy(D), edge));
end);

InstallMethod(DigraphAddEdges, "for a mutable digraph and a list",
[IsMutableDigraph, IsList],
function(D, edges)
  local edge;
  for edge in edges do
    DigraphAddEdge(D, edge);
  od;
  return D;
end);

InstallMethod(DigraphAddEdges, "for an immutable digraph and a list",
[IsImmutableDigraph, IsList],
function(D, edges)
  return MakeImmutableDigraph(DigraphAddEdges(DigraphMutableCopy(D), edges));
end);

InstallMethod(DigraphRemoveEdge,
"for a mutable dense digraph, a positive integer, and a positive integer",
[IsMutableDigraph and IsDenseDigraphRep, IsPosInt, IsPosInt],
function(D, src, ran)
  local pos;
  if IsMultiDigraph(D) then
    ErrorNoReturn("the 1st argument (a digraph) must not have multiple ",
                  "edges when the 2nd argument is a list,");
  elif not (IsPosInt(src) and src in DigraphVertices(D)) then
    ErrorNoReturn("the 2nd argument must be a vertex of the ",
                  "1st argument (a digraph),");
  elif not (IsPosInt(ran) and ran in DigraphVertices(D)) then
    ErrorNoReturn("the 3rd argument must be a vertex of the ",
                  "1st argument (a digraph),");
  fi;
  pos := Position(D!.OutNeighbours[src], ran);
  if pos <> fail then
    Remove(D!.OutNeighbours[src], pos);
    Remove(DigraphEdgeLabels(D)[src], pos);
  fi;
  return D;
end);

InstallMethod(DigraphRemoveEdge,
"for a immutable digraph, a positive integer, and a positive integer",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(D, src, ran)
  D := DigraphRemoveEdge(DigraphMutableCopy(D), src, ran);
  return MakeImmutableDigraph(D);
end);

InstallMethod(DigraphRemoveEdge, "for a mutable digraph and a list",
[IsMutableDigraph, IsList],
function(D, edge)
  if Length(edge) <> 2 then
    ErrorNoReturn("the 2nd argument must be a list of length 2,");
  fi;
  return DigraphRemoveEdge(D, edge[1], edge[2]);
end);

InstallMethod(DigraphRemoveEdge,
"for a immutable digraph and a list",
[IsImmutableDigraph, IsList],
function(D, edge)
  D := DigraphRemoveEdge(DigraphMutableCopy(D), edge);
  return MakeImmutableDigraph(D);
end);

InstallMethod(DigraphRemoveEdges, "for a digraph and a list",
[IsMutableDigraph, IsList],
function(D, edges)
  local edge;
  for edge in edges do
    DigraphRemoveEdge(D, edge);
  od;
  return D;
end);

InstallMethod(DigraphRemoveEdges, "for an immutable digraph and a list",
[IsImmutableDigraph, IsList],
function(D, edges)
  return MakeImmutableDigraph(DigraphRemoveEdges(DigraphMutableCopy(D),
                                                 edges));
end);

InstallMethod(DigraphRemoveAllMultipleEdges, "for a mutable dense digraph",
[IsMutableDigraph and IsDenseDigraphRep],
function(D)
  local nodes, list, empty, seen, keep, v, u, pos;

  nodes := DigraphVertices(D);
  list  := D!.OutNeighbours;
  empty := BlistList(nodes, []);
  seen  := BlistList(nodes, []);
  for u in nodes do
    keep := [];
    for pos in [1 .. Length(list[u])] do
      v := list[u][pos];
      if not seen[v] then
        seen[v] := true;
        Add(keep, pos);
      fi;
    od;
    list[u] := list[u]{keep};
    IntersectBlist(seen, empty);
  od;
  # Multidigraphs did not have edge labels
  SetDigraphVertexLabels(D, DigraphVertexLabels(D));
  return D;
end);

InstallMethod(DigraphRemoveAllMultipleEdges, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  D := DigraphMutableCopy(D);
  D := MakeImmutableDigraph(DigraphRemoveAllMultipleEdges(D));
  SetIsMultiDigraph(D, false);
  return D;
end);

InstallMethod(DigraphClosure,
"for a mutable dense digraph and a positive integer",
[IsMutableDigraph and IsDenseDigraphRep, IsPosInt],
function(D, k)
  local list, mat, deg, n, stop, i, j;

  if not IsSymmetricDigraph(D) or DigraphHasLoops(D) or IsMultiDigraph(D) then
    ErrorNoReturn("the 1st argument (a digraph) must by symmetric, without ",
                  "loops, and no multiple edges,");
  fi;

  list := D!.OutNeighbours;
  mat  := BooleanAdjacencyMatrixMutableCopy(D);
  deg  := ShallowCopy(InDegrees(D));
  n    := DigraphNrVertices(D);

  repeat
    stop := true;
    for i in [1 .. n] do
      for j in [1 .. n] do
        if j <> i and (not mat[i][j]) and deg[i] + deg[j] >= k then
          Add(list[i], j);
          Add(list[j], i);
          mat[i][j] := true;
          mat[j][i] := true;
          deg[i]    := deg[i] + 1;
          deg[j]    := deg[j] + 1;
          stop      := false;
        fi;
      od;
    od;
  until stop;
  return D;
end);

InstallMethod(DigraphClosure,
"for an immutable dense digraph and a positive integer",
[IsImmutableDigraph, IsPosInt],
function(D, k)
  return MakeImmutableDigraph(DigraphClosure(DigraphMutableCopy(D), k));
end);

InstallGlobalFunction(DigraphDisjointUnion,
function(arg)
  local out, offset, n, i;

  # Allow the possibility of supplying arguments in a list.
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;

  if not IsList(arg) or IsEmpty(arg) or not ForAll(arg, IsDenseDigraphRep) then
    ErrorNoReturn("the arguments must be dense digraphs, or a single ",
                  "list of dense digraphs,");
  fi;

  if IsMutableDigraph(arg[1]) then
    out := arg[1]!.OutNeighbours;
    # Note that if arg[1] is mutable, and arg[1] occurs elsewhere in the arg
    # list, then the output of this function is a bit unexpected! Same for
    # DigraphJoin and DigraphEdgeUnion
  else
    out := OutNeighboursMutableCopy(arg[1]);
  fi;

  offset := DigraphNrVertices(arg[1]);

  for i in [2 .. Length(arg)] do
    n := DigraphNrVertices(arg[i]);
    out{[offset + 1 .. offset + n]} := OutNeighbours(arg[i]) + offset;
    offset := offset + n;
  od;

  if IsMutableDigraph(arg[1]) then
    return arg[1];
  else
    return DigraphNC(out);
  fi;
end);

InstallGlobalFunction(DigraphJoin,
function(arg)
  local out, tot, offset, n, nbs, i, v;
  # Allow the possibility of supplying arguments in a list.
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;

  if not IsList(arg) or IsEmpty(arg) or not ForAll(arg, IsDenseDigraphRep) then
    ErrorNoReturn("the arguments must be dense digraphs, or a single ",
                  "list of dense digraphs,");
  fi;

  if IsMutableDigraph(arg[1]) then
    out := arg[1]!.OutNeighbours;
  else
    out := OutNeighboursMutableCopy(arg[1]);
  fi;

  tot    := Sum(arg, DigraphNrVertices);
  offset := DigraphNrVertices(arg[1]);

  for nbs in out do
    Append(nbs, [offset + 1 .. tot]);
  od;

  for i in [2 .. Length(arg)] do
    n   := DigraphNrVertices(arg[i]);
    nbs := OutNeighbours(arg[i]);
    for v in DigraphVertices(arg[i]) do
      out[v + offset] := Concatenation([1 .. offset], nbs[v] + offset,
                                       [offset + n + 1 .. tot]);
    od;
    offset := offset + n;
  od;

  if IsMutableDigraph(arg[1]) then
    return arg[1];
  else
    return DigraphNC(out);
  fi;
end);

InstallGlobalFunction(DigraphEdgeUnion,
function(arg)
  local n, out, nbs, i, v;

  # Allow the possibility of supplying arguments in a list.
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;

  if not IsList(arg) or IsEmpty(arg) or not ForAll(arg, IsDenseDigraphRep) then
    ErrorNoReturn("the arguments must be dense digraphs, or a single ",
                  "list of dense digraphs,");
  fi;

  n := Maximum(List(arg, DigraphNrVertices));
  if IsMutableDigraph(arg[1]) then
    DigraphAddVertices(arg[1], n - DigraphNrVertices(arg[1]));
    out := arg[1]!.OutNeighbours;
  else
    out := OutNeighboursMutableCopy(arg[1]);
    Append(out, List([1 .. n - DigraphNrVertices(arg[1])], x -> []));
  fi;

  for i in [2 .. Length(arg)] do
    nbs := OutNeighbours(arg[i]);
    for v in DigraphVertices(arg[i]) do
      if not IsEmpty(nbs[v]) then
        Append(out[v], nbs[v]);
      fi;
    od;
  od;
  if IsMutableDigraph(arg[1]) then
    return arg[1];
  else
    return DigraphNC(out);
  fi;
end);

# For a topologically sortable digraph G, this returns the least subgraph G'
# of G such that the (reflexive) transitive closures of G and G' are equal.
InstallMethod(DigraphReflexiveTransitiveReduction, "for a mutable digraph",
[IsMutableDigraph],
function(D)
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument (a digraph) must not have multiple edges,");
  elif DigraphTopologicalSort(D) = fail then
    ErrorNoReturn("not yet implemented for non-topologically sortable ",
                  "digraphs,");
  elif IsNullDigraph(D) then
    return D;
  fi;
  return DigraphTransitiveReduction(DigraphRemoveLoops(D));
end);

InstallMethod(DigraphReflexiveTransitiveReduction,
"for an immutable digraph",
[IsImmutableDigraph],
function(D)
  D := DigraphReflexiveTransitiveReduction(DigraphMutableCopy(D));
  return MakeImmutableDigraph(D);
end);

InstallMethod(DigraphTransitiveReduction, "for a dense mutable digraph",
[IsDenseDigraphRep and IsMutableDigraph],
function(D)
  local topo, p;
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument (a digraph) must not have multiple edges,");
  elif DigraphTopologicalSort(D) = fail then
    ErrorNoReturn("not yet implemented for non-topologically sortable ",
                  "digraphs,");
  fi;
  topo := DigraphTopologicalSort(D);
  # p := MappingPermListList(DigraphVertices(D), topo);
  p    := Permutation(Transformation(topo), topo);
  OnDigraphs(D, p ^ -1);       # changes D in-place
  DIGRAPH_TRANS_REDUCTION(D);  # changes D in-place
  return OnDigraphs(D, p);
end);

InstallMethod(DigraphTransitiveReduction, "for an immutable digraph",
[IsImmutableDigraph],
function(D)
  D := DigraphTransitiveReduction(DigraphMutableCopy(D));
  return MakeImmutableDigraph(D);
end);

InstallMethod(DigraphReverse, "for a mutable dense digraph",
[IsMutableDigraph and IsDenseDigraphRep],
function(D)
  if IsSymmetricDigraph(D) then
    return D;
  fi;
  D!.OutNeighbours{DigraphVertices(D)} := InNeighboursMutableCopy(D);
  return D;
end);

InstallMethod(DigraphReverse, "for a immutable digraph",
[IsImmutableDigraph],
function(D)
  return MakeImmutableDigraph(DigraphReverse(DigraphMutableCopy(D)));
end);

InstallMethod(DigraphReverseEdge,
"for a mutable dense digraph, positive integer, and positive integer",
[IsMutableDigraph and IsDenseDigraphRep, IsPosInt, IsPosInt],
function(D, u, v)
  local pos;
  if IsMultiDigraph(D) then
    ErrorNoReturn("the 1st argument (a digraph) must not have ",
                  "multiple edges,");
  fi;
  pos := Position(D!.OutNeighbours[u], v);
  if pos = fail then
    ErrorNoReturn("there is no edge from ", u, " to ", v,
                  " in the 1st argument (a digraph)");
  elif u = v then
    return D;
  fi;
  Add(D!.OutNeighbours[v], u);
  Remove(D!.OutNeighbours[u], pos);
  # TODO(later) edge labels
  return D;
end);

InstallMethod(DigraphReverseEdge,
"for an immutable digraph, positive integer, and positive integer",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(D, u, v)
  return MakeImmutableDigraph(DigraphReverseEdge(DigraphMutableCopy(D), u, v));
end);

InstallMethod(DigraphReverseEdge, "for a mutable digraph and list",
[IsMutableDigraph, IsList],
function(D, e)
  if Length(e) <> 2 then
    ErrorNoReturn("the 2nd argument must be a list of length 2,");
  fi;
  return DigraphReverseEdge(D, e[1], e[2]);
end);

InstallMethod(DigraphReverseEdge,
"for an immutable digraph and a list",
[IsImmutableDigraph, IsList],
function(D, e)
  return MakeImmutableDigraph(DigraphReverseEdge(DigraphMutableCopy(D), e));
end);

InstallMethod(DigraphReverseEdges, "for a mutable digraph and a list",
[IsMutableDigraph, IsList],
function(D, E)
  local e;
  for e in E do
    DigraphReverseEdge(D, e);
  od;
  return D;
end);

InstallMethod(DigraphReverseEdges, "for an immutable digraph and a list",
[IsImmutableDigraph, IsList],
function(D, E)
  return MakeImmutableDigraph(DigraphReverseEdges(DigraphMutableCopy(D), E));
end);

###############################################################################
# 4. Actions
###############################################################################

InstallMethod(OnDigraphs, "for a mutable dense digraph and a perm",
[IsMutableDigraph and IsDenseDigraphRep, IsPerm],
function(D, p)
  local out;
  if ForAny(DigraphVertices(D), i -> i ^ p > DigraphNrVertices(D)) then
    ErrorNoReturn("the 2nd argument (a perm) must permute the vertices ",
                  "of the 1st argument (a digraph),");
  fi;
  out := D!.OutNeighbours;
  out{DigraphVertices(D)} := Permuted(out, p);
  Apply(out, x -> OnTuples(x, p));
  return D;
end);

InstallMethod(OnDigraphs, "for a immutable digraph and a perm",
[IsImmutableDigraph, IsPerm],
function(D, p)
  return MakeImmutableDigraph(OnDigraphs(DigraphMutableCopy(D), p));
end);

InstallMethod(OnDigraphs, "for a mutable dense digraph and a transformation",
[IsMutableDigraph and IsDenseDigraphRep, IsTransformation],
function(D, t)
  local old, new, v;
  if ForAny(DigraphVertices(D), i -> i ^ t > DigraphNrVertices(D)) then
    ErrorNoReturn("the 2nd argument (a transformation) must map every ",
                  "vertex of the 1st argument (a digraph) to a vertex of ",
                  "the 1st argument,");
  fi;
  old := D!.OutNeighbours;
  new := List(DigraphVertices(D), x -> []);
  for v in DigraphVertices(D) do
    Append(new[v ^ t], OnTuples(old[v], t));
  od;
  old{DigraphVertices(D)} := new;
  return D;
end);

InstallMethod(OnDigraphs, "for a immutable digraph and a transformation",
[IsImmutableDigraph, IsTransformation],
function(D, t)
  return MakeImmutableDigraph(OnDigraphs(DigraphMutableCopy(D), t));
end);

# Not revising the following because multi-digraphs are being withdrawn in the
# near future.

InstallMethod(OnMultiDigraphs, "for a digraph, perm and perm",
[IsDigraph, IsPerm, IsPerm],
function(D, perm1, perm2)
  return OnMultiDigraphs(D, [perm1, perm2]);
end);

InstallMethod(OnMultiDigraphs, "for a digraph and perm coll",
[IsDigraph, IsPermCollection],
function(D, perms)
  if Length(perms) <> 2 then
    ErrorNoReturn("the 2nd argument must be a pair of permutations,");
  fi;

  if ForAny([1 .. DigraphNrEdges(D)],
            i -> i ^ perms[2] > DigraphNrEdges(D)) then
    ErrorNoReturn("the <perms[2]> must permute the edges ",
                  "of the 1st argument <D>,");
  fi;

  return OnDigraphs(D, perms[1]);
end);

#############################################################################
# 5. Substructures and quotients
#############################################################################

InstallMethod(InducedSubdigraph, "for a dense digraph and a homogeneous list",
[IsDenseDigraphRep, IsHomogeneousList],
function(D, list)
  local ConstructDigraph, N, M, new, new_edl, old, old_edl, lookup, v_old,
        w_old, E, v_new, i;

  if IsMutableDigraph(D) then
    ConstructDigraph := ConvertToMutableDigraphNC;
  else
    ConstructDigraph := ConvertToImmutableDigraphNC;
  fi;

  M := Length(list);
  if M = 0 then
    return ConstructDigraph([]);
  fi;
  N := DigraphNrVertices(D);
  if (IsRange(list) and not
      (IsPosInt(list[1]) and list[1] <= N and
       list[Length(list)] <= N))
      or not IsDuplicateFree(list)
      or not ForAll(list, x -> IsPosInt(x) and x <= N) then
    ErrorNoReturn("the 2nd argument (a list) must be a duplicate-free ",
                  "subset of the vertices of the 1st argument (a digraph),");
  fi;

  old     := OutNeighbours(D);
  new     := List([1 .. M], x -> []);
  old_edl := DigraphEdgeLabelsNC(D);
  new_edl := List([1 .. M], x -> []);

  lookup := ListWithIdenticalEntries(N, 0);
  lookup{list} := [1 .. M];

  for v_new in [1 .. M] do
    v_old := list[v_new];
    for i in [1 .. Length(old[v_old])] do
      w_old := old[v_old][i];
      if lookup[w_old] <> 0 then
        Add(new[v_new], lookup[w_old]);
        Add(new_edl[v_new], old_edl[v_old][i]);
      fi;
    od;
  od;

  E := ConstructDigraph(new);
  SetDigraphVertexLabels(E, DigraphVertexLabels(D){list});
  SetDigraphEdgeLabelsNC(E, new_edl);
  return E;
end);

InstallMethod(QuotientDigraph, "for a dense digraph and a homogeneous list",
[IsDenseDigraphRep, IsHomogeneousList],
function(D, partition)
  local ConstructDigraph, N, M, check, lookup, out, new, x, i, u, v;
  if IsMutableDigraph(D) then
    ConstructDigraph := ConvertToMutableDigraphNC;
  else
    ConstructDigraph := ConvertToImmutableDigraphNC;
  fi;
  N := DigraphNrVertices(D);
  if N = 0 then
    if IsEmpty(partition) then
      return ConstructDigraph([]);
    else
      ErrorNoReturn("the 2nd argument (a homogeneous list) is not a valid ",
                    "partition of the vertices of 1st argument (a null ",
                    "digraph). The only valid partition of a null digraph is ",
                    "the empty list,");
    fi;
  fi;
  M := Length(partition);
  if M = 0 or M = 0 or not IsList(partition[1])
      or IsEmpty(partition[1]) or not IsPosInt(partition[1][1]) then
    ErrorNoReturn("the 2nd argument (a homogeneous list) is not a valid ",
                  "partition of the vertices [1 .. ", N, "] of the 1st ",
                  "argument (a digraph),");
  fi;
  check := BlistList(DigraphVertices(D), []);
  lookup := EmptyPlist(N);
  for x in [1 .. Length(partition)] do
    for i in partition[x] do
      if i < 1 or i > N or check[i] then
        ErrorNoReturn("the 2nd argument (a homogeneous list) is not a valid ",
                      "partition of the vertices [1 .. ", N, "] of the 1st ",
                      "argument (a digraph),");
      fi;
      check[i] := true;
      lookup[i] := x;
    od;
  od;
  if ForAny(check, x -> not x) then
      ErrorNoReturn("the 2nd argument (a homogeneous list) is not a valid ",
                    "partition of the vertices [1 .. ", N, "] of the 1st ",
                    "argument (a digraph),");
  fi;
  out := OutNeighbours(D);
  new := List([1 .. M], x -> []);
  for u in DigraphVertices(D) do
    for v in out[u] do
      Add(new[lookup[u]], lookup[v]);
    od;
  od;
  return ConstructDigraph(new);
end);

#############################################################################
# 6. In and out degrees and edges of vertices
#############################################################################

InstallMethod(InNeighboursOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(D, v)
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument (a positive int) is not a vertex of the ",
                  "1st argument (a digraph),");
  fi;
  return InNeighboursOfVertexNC(D, v);
end);

InstallMethod(InNeighboursOfVertexNC,
"for a digraph with in-neighbours and a vertex",
[IsDigraph and HasInNeighbours, IsPosInt],
2,  # to beat the next method for IsDenseDigraphRep
function(D, v)
  return InNeighbours(D)[v];
end);

InstallMethod(InNeighboursOfVertexNC, "for a dense digraph and a vertex",
[IsDenseDigraphRep, IsPosInt],
function(D, v)
  local inn, pos, out, i, j;

  inn := [];
  pos := 1;
  out := OutNeighbours(D);
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

InstallMethod(OutNeighboursOfVertex, "for a dense digraph and a vertex",
[IsDenseDigraphRep, IsPosInt],
function(D, v)
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument (a positive int) is not a vertex of the ",
                  "1st argument (a digraph),");
  fi;
  return OutNeighboursOfVertexNC(D, v);
end);

InstallMethod(OutNeighboursOfVertexNC, "for a dense digraph and a vertex",
[IsDenseDigraphRep, IsPosInt],
function(D, v)
  return OutNeighbours(D)[v];
end);

InstallMethod(InDegreeOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(D, v)
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument (a positive int) is not a vertex of the ",
                  "1st argument (a digraph),");
  fi;
  return InDegreeOfVertexNC(D, v);
end);

InstallMethod(InDegreeOfVertexNC, "for a digraph with in-degrees and a vertex",
[IsDigraph and HasInDegrees, IsPosInt], 4,
function(D, v)
  return InDegrees(D)[v];
end);

InstallMethod(InDegreeOfVertexNC,
"for a digraph with in-neighbours and a vertex",
[IsDigraph and HasInNeighbours, IsPosInt],
2,  # to beat the next method for IsDenseDigraphRep
function(D, v)
  return Length(InNeighbours(D)[v]);
end);

InstallMethod(InDegreeOfVertexNC, "for a digraph and a vertex",
[IsDenseDigraphRep, IsPosInt],
function(D, v)
  local count, out, x, i;
  count := 0;
  out := OutNeighbours(D);
  for x in out do
    for i in x do
      if i = v then
        count := count + 1;
      fi;
    od;
  od;
  return count;
end);

InstallMethod(OutDegreeOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(D, v)
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument (a positive int) is not a vertex of the ",
                  "1st argument (a digraph),");
  fi;
   return OutDegreeOfVertexNC(D, v);
end);

InstallMethod(OutDegreeOfVertexNC,
"for a digraph with out-degrees and a vertex",
[IsDigraph and HasOutDegrees, IsPosInt],
2,  # to beat the next method for IsDenseDigraphRep
function(D, v)
  return OutDegrees(D)[v];
end);

InstallMethod(OutDegreeOfVertexNC, "for a dense digraph and a vertex",
[IsDenseDigraphRep, IsPosInt],
function(D, v)
  return Length(OutNeighbours(D)[v]);
end);

InstallMethod(DigraphOutEdges, "for a dense digraph and a vertex",
[IsDenseDigraphRep, IsPosInt],
function(D, v)
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument (a positive int) is not a vertex of the ",
                  "1st argument (a digraph),");
  fi;
  return List(OutNeighboursOfVertex(D, v), x -> [v, x]);
end);

InstallMethod(DigraphInEdges, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(D, v)
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument (a positive int) is not a vertex of the ",
                  "1st argument (a digraph),");
  fi;
  return List(InNeighboursOfVertex(D, v), x -> [x, v]);
end);

#############################################################################
# 7. Copies of out/in-neighbours
#############################################################################

InstallMethod(OutNeighboursMutableCopy, "for a dense digraph",
[IsDenseDigraphRep], D -> List(OutNeighbours(D), ShallowCopy));

InstallMethod(InNeighboursMutableCopy, "for a digraph",
[IsDigraph], D -> List(InNeighbours(D), ShallowCopy));

InstallMethod(AdjacencyMatrixMutableCopy, "for a digraph",
[IsDigraph], D -> List(AdjacencyMatrix(D), ShallowCopy));

InstallMethod(BooleanAdjacencyMatrixMutableCopy, "for a digraph",
[IsDigraph], D -> List(BooleanAdjacencyMatrix(D), ShallowCopy));

#############################################################################
# 8.  IsSomething
#############################################################################

InstallMethod(IsDigraphEdge, "for a digraph and a list",
[IsDigraph, IsList],
function(D, edge)
  if Length(edge) <> 2 or not IsPosInt(edge[1]) or not IsPosInt(edge[2]) then
    return false;
  fi;
  return IsDigraphEdge(D, edge[1], edge[2]);
end);

InstallMethod(IsDigraphEdge, "for a dense digraph, int, int",
[IsDenseDigraphRep, IsInt, IsInt],
function(D, u, v)
  local n;

  n := DigraphNrVertices(D);

  if u > n or v > n or u <= 0 or v <= 0 then
    return false;
  elif HasAdjacencyMatrix(D) then
    return AdjacencyMatrix(D)[u][v] <> 0;
  elif IsDigraphWithAdjacencyFunction(D) then
    return DigraphAdjacencyFunction(D)(u, v);
  fi;
  return v in OutNeighboursOfVertex(D, u);
end);

InstallMethod(IsSubdigraph, "for a dense digraph and dense digraph",
[IsDenseDigraphRep, IsDenseDigraphRep],
function(super, sub)
  local n, x, y, i, j;

  n := DigraphNrVertices(super);
  if n <> DigraphNrVertices(sub)
      or DigraphNrEdges(super) < DigraphNrEdges(sub) then
    return false;
  elif not IsMultiDigraph(sub) then
    return ForAll(DigraphVertices(super), i ->
                  IsSubset(OutNeighboursOfVertex(super, i),
                           OutNeighboursOfVertex(sub, i)));
  elif not IsMultiDigraph(super) then
    return false;
  fi;

  x := [1 .. n];
  y := [1 .. n];
  for i in DigraphVertices(super) do
    if OutDegreeOfVertex(super, i) < OutDegreeOfVertex(sub, i) then
      return false;
    fi;
    x := x * 0;
    y := y * 0;
    for j in OutNeighboursOfVertex(super, i) do
      x[j] := x[j] + 1;
    od;
    for j in OutNeighboursOfVertex(sub, i) do
      y[j] := y[j] + 1;
    od;
    if not ForAll(DigraphVertices(super), k -> y[k] <= x[k]) then
      return false;
    fi;
  od;
  return true;
end);

InstallMethod(IsUndirectedSpanningForest, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(super, sub)
  local sym, comps1, comps2;

  if not IsUndirectedForest(sub) then
    return false;
  fi;

  sym := MaximalSymmetricSubdigraph(DigraphCopyIfMutable(super));

  if not IsSubdigraph(sym, sub) then
    return false;
  fi;

  comps1 := DigraphConnectedComponents(sym).comps;
  comps2 := DigraphConnectedComponents(sub).comps;

  if Length(comps1) <> Length(comps2) then
    return false;
  fi;

  return Set(comps1, SortedList) = Set(comps2, SortedList);
end);

InstallMethod(IsUndirectedSpanningTree, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(super, sub)
  super := DigraphCopyIfMutable(super);
  return IsConnectedDigraph(MaximalSymmetricSubdigraph(super))
    and IsUndirectedSpanningForest(super, sub);
end);

# The following function performs almost all of the calculations necessary for
# IsMatching, IsPerfectMatching, and IsMaximalMatching, without duplicating work

BindGlobal("DIGRAPHS_Matching",
function(D, edges)
  local seen, e;
  Assert(1, IsDigraph(D));
  Assert(1, IsHomogeneousList(edges));

  if not IsDuplicateFreeList(edges)
      or not ForAll(edges, e -> IsDigraphEdge(D, e)) then
    return false;
  fi;

  seen := BlistList(DigraphVertices(D), []);

  for e in edges do
    if seen[e[1]] or seen[e[2]] then
      return false;
    fi;
    seen[e[1]] := true;
    seen[e[2]] := true;
  od;

  return seen;
end);

InstallMethod(IsMatching, "for a digraph and a list",
[IsDigraph, IsHomogeneousList],
function(D, edges)
  return DIGRAPHS_Matching(D, edges) <> false;
end);

InstallMethod(IsPerfectMatching, "for a digraph and a list",
[IsDigraph, IsHomogeneousList],
function(D, edges)
  local seen;

  seen := DIGRAPHS_Matching(D, edges);
  if seen = false then
    return false;
  fi;
  return SizeBlist(seen) = DigraphNrVertices(D);
end);

InstallMethod(IsMaximalMatching, "for a digraph and a list",
[IsDenseDigraphRep, IsHomogeneousList],
function(D, edges)
  local seen, nbs, i, j;

  seen := DIGRAPHS_Matching(D, edges);
  if seen = false then
    return false;
  fi;
  nbs := OutNeighbours(D);
  for i in DigraphVertices(D) do
    if not seen[i] then
      for j in nbs[i] do
        if not seen[j] then
          return false;
        fi;
      od;
    fi;
  od;
  return true;
end);

#############################################################################
# 9.  Connectivity
#############################################################################

InstallMethod(DigraphFloydWarshall,
"for a dense digraph, function, object, and object",
[IsDenseDigraphRep, IsFunction, IsObject, IsObject],
function(D, func, nopath, edge)
  local vertices, n, mat, out, i, j, k;

  vertices := DigraphVertices(D);
  n := DigraphNrVertices(D);
  mat := EmptyPlist(n);

  for i in vertices do
    mat[i] := EmptyPlist(n);
    for j in vertices do
      mat[i][j] := nopath;
    od;
  od;

  out := OutNeighbours(D);
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

InstallMethod(DigraphStronglyConnectedComponent, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(D, v)
  local scc;
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument (a positive int) is not a vertex of the ",
                  "1st argument (a digraph),");
  fi;

  # TODO check if strongly connected components are known and use them if they
  # are and don't use them if they are not.
  scc := DigraphStronglyConnectedComponents(D);
  return scc.comps[scc.id[v]];
end);

InstallMethod(DigraphConnectedComponent, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(D, v)
  local wcc;
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument (a positive int) is not a vertex of the ",
                  "1st argument (a digraph),");
  fi;
  wcc := DigraphConnectedComponents(D);
  return wcc.comps[wcc.id[v]];
end);

InstallMethod(IsReachable, "for a digraph and two pos ints",
[IsDigraph, IsPosInt, IsPosInt],
function(D, u, v)
  local verts, scc;

  verts := DigraphVertices(D);
  if not (u in verts and v in verts) then
    ErrorNoReturn("the 2nd and 3rd arguments must be ",
                  "vertices of the 1st argument (a digraph),");
  elif IsDigraphEdge(D, u, v) then
    return true;
  elif HasDigraphStronglyConnectedComponents(D) then
    # Glean information from SCC if we have it
    scc := DigraphStronglyConnectedComponents(D);
    if u <> v then
      if scc.id[u] = scc.id[v] then
        return true;
      fi;
    else
      return Length(scc.comps[scc.id[u]]) > 1;
    fi;
  fi;
  return DigraphPath(D, u, v) <> fail;
end);

InstallMethod(DigraphPath, "for a dense digraph and two pos ints",
[IsDenseDigraphRep, IsPosInt, IsPosInt],
function(D, u, v)
  local verts;

  verts := DigraphVertices(D);
  if not (u in verts and v in verts) then
    ErrorNoReturn("the 2nd and 3rd arguments must be",
                  "vertices of the 1st argument (a digraph),");
  elif IsDigraphEdge(D, u, v) then
    return [[u, v], [Position(OutNeighboursOfVertex(D, u), v)]];
  elif HasIsTransitiveDigraph(D) and IsTransitiveDigraph(D) then
    # If it's a known transitive digraph, just check whether the edge exists
    return fail;
    # Glean information from WCC if we have it
  elif HasDigraphConnectedComponents(D)
      and DigraphConnectedComponents(D).id[u] <>
          DigraphConnectedComponents(D).id[v] then
    return fail;
  fi;
  return DIGRAPH_PATH(OutNeighbours(D), u, v);
end);

InstallMethod(DigraphShortestPath, "for a dense digraph and two pos ints",
[IsDenseDigraphRep, IsPosInt, IsPosInt],
function(D, u, v)
  local current, next, parent, distance, falselist, verts, nbs, path, edge,
  n, a, b, i;

  verts := DigraphVertices(D);
  if not (u in verts and v in verts) then
    ErrorNoReturn("the 2nd and 3rd arguments must be ",
                  "vertices of the 1st argument (a digraph),");
  fi;

  if IsDigraphEdge(D, u, v) then
    return [[u, v], [Position(OutNeighboursOfVertex(D, u), v)]];
  elif HasIsTransitiveDigraph(D) and IsTransitiveDigraph(D) then
    # If it's a known transitive digraph, just check whether the edge exists
    return fail;
    # Glean information from WCC if we have it
  elif HasDigraphConnectedComponents(D)
      and DigraphConnectedComponents(D).id[u] <>
          DigraphConnectedComponents(D).id[v] then
    return fail;
  fi;

  nbs      := OutNeighbours(D);
  distance := ListWithIdenticalEntries(Length(verts), -1);

  #  Setting up objects useful in the function.
  parent    := [];
  current   := [u];
  edge      := [];
  next      := BlistList([1 .. Length(verts)], []);
  falselist := BlistList([1 .. Length(verts)], []);

  n := 0;
  while current <> [] do
    n := n + 1;
    for a in current do
        for i in [1 .. Length(nbs[a])] do
          b := nbs[a][i];
          if distance[b] = -1 then
            distance[b] := n;
            next[b]     := true;
            parent[b]   := a;
            edge[b]     := i;
          fi;

          if b = v then
            path := [[], []];
            # Finds the path
            for i in [1 .. n] do
              Add(path[1], b);
              Add(path[2], edge[b]);
              b := parent[b];
            od;
            Add(path[1], u);  # Adds the starting vertex to the list of vertices.
            return [Reversed(path[1]), Reversed(path[2])];
          fi;
        od;
      od;
      current := ListBlist(verts, next);
      IntersectBlist(next, falselist);
    od;
    return fail;
end);

InstallMethod(IteratorOfPaths, "for a dense digraph and two pos ints",
[IsDenseDigraphRep, IsPosInt, IsPosInt],
function(D, u, v)
  if not (u in DigraphVertices(D) and v in DigraphVertices(D)) then
    ErrorNoReturn("the 2nd and 3rd arguments must be ",
                  "vertices of the 1st argument (a digraph),");
  fi;
  return IteratorOfPathsNC(OutNeighbours(D), u, v);
end);

InstallMethod(IteratorOfPaths, "for a list and two pos ints",
[IsList, IsPosInt, IsPosInt],
function(out, u, v)
  local n;

  n := Length(out);
  if not ForAll(out, x -> IsHomogeneousList(x)
      and ForAll(x, y -> IsPosInt(y) and y <= n)) then
    ErrorNoReturn("the 1st argument (a list) must be a list of out-neighbours",
                  " of a digraph,");
  elif not (u <= n and v <= n) then
    ErrorNoReturn("the 2nd and 3rd arguments must be vertices of the digraph ",
                  "defined by the 1st argument (a list of out-neighbours),");
  fi;
  return IteratorOfPathsNC(out, u, v);
end);

InstallMethod(IteratorOfPathsNC, "for a list and two pos ints",
[IsList, IsPosInt, IsPosInt],
function(D, u, v)
  local n, record;

  n := Length(D);
  # can assume that n >= 1 since u and v are extant vertices of digraph

  record := rec(adj := D,
                start := u,
                stop := v,
                onpath := BlistList([1 .. n], []),
                nbs := ListWithIdenticalEntries(n, 1));

  record.NextIterator := function(iter)
    local adj, path, ptr, nbs, level, stop, onpath, backtracked, j, k, current,
    new, next, x;

    adj := iter!.adj;
    path := [iter!.start];
    ptr := ListWithIdenticalEntries(n, 0);
    nbs := iter!.nbs;
    level := 1;
    stop := iter!.stop;
    onpath := iter!.onpath;

    backtracked := false;
    while true do
      j := path[level];
      k := nbs[j];

      # Backtrack if vertex j is already in path, or it has no k^th neighbour
      if (not ptr[j] = 0 or k > Length(adj[j])) then
        if k > Length(adj[j]) then
          nbs[j] := 1;
        fi;
        if k > Length(adj[j]) and onpath[j] then
          ptr[j] := 0;
        else
          ptr[j] := 1;
        fi;
        level := level - 1;
        backtracked := true;
        if level = 0 then
          # No more paths to be found
          current := fail;
          break;
        fi;
        # Backtrack and choose next available branch
        Remove(path);
        ptr[path[level]] := 0;
        nbs[path[level]] := nbs[path[level]] + 1;
        continue;
      fi;

      # Otherwise move into next available branch

      # Check if new branch is a valid complete path
      if adj[j][k] = stop then
        current := [Concatenation(path, [adj[j][k]]), List(path, x -> nbs[x])];
        nbs[j] := nbs[j] + 1;
        # Everything in the path should keep its nbs
        # but everything else should be back to 1
        new := ListWithIdenticalEntries(n, 1);
        for x in path do
          onpath[x] := true;
          new[x] := nbs[x];
        od;
        iter!.nbs := new;
        iter!.onpath := onpath;
        break;
      fi;
      ptr[j] := 2;
      level := level + 1;
      path[level] := adj[j][k];
      # this is the troublesome line
      if ptr[path[level]] = 0 and backtracked then
        nbs[path[level]] := 1;
      fi;
    od;

    if not IsBound(iter!.current) then
      return current;
    fi;

    next := iter!.current;
    iter!.current := current;
    return next;
  end;

  record.current := record.NextIterator(record);

  record.IsDoneIterator := function(iter)
    if iter!.current = fail then
      return true;
    fi;
    return false;
  end;

  record.ShallowCopy := function(iter)
    return rec(adj := iter!.adj,
               start := iter!.start,
               stop := iter!.stop,
               nbs := ShallowCopy(iter!.nbs),
               onpath := ShallowCopy(iter!.onpath),
               current := ShallowCopy(iter!.current));
  end;

  return IteratorByFunctions(record);
end);

InstallMethod(DigraphLongestDistanceFromVertex, "for a digraph and a pos int",
[IsDenseDigraphRep, IsPosInt],
function(D, v)
  local dist;

  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument must be a vertex of the 1st ",
                  "argument (a digraph),");
  fi;
  dist := DIGRAPH_LONGEST_DIST_VERTEX(OutNeighbours(D), v);
  if dist = -2 then
    return infinity;
  fi;
  return dist;
end);

InstallMethod(DigraphLayers, "for a digraph, and a vertex",
[IsDigraph, IsPosInt],
function(D, v)
  local layers, gens, sch, trace, rep, word, orbs, layers_with_orbnums,
        layers_of_v, i, x;

  # TODO: make use of known distances matrix
  if v > DigraphNrVertices(D) then
    ErrorNoReturn("the 2nd argument (a vertex) must be a vertex of the first ",
                  "argument (a digraph),");
  fi;

  layers := DIGRAPHS_Layers(D);

  if IsBound(layers[v]) then
    return layers[v];
  fi;

  if HasDigraphGroup(D) then
    gens  := GeneratorsOfGroup(DigraphGroup(D));
    sch   := DigraphSchreierVector(D);
    trace := DIGRAPHS_TraceSchreierVector(gens, sch, v);
    rep   := DigraphOrbitReps(D)[trace.representative];
    word  := DIGRAPHS_EvaluateWord(gens, trace.word);
    if rep <> v then
      layers[v] := List(DigraphLayers(D, rep),
                        x -> OnTuples(x, word));
      return layers[v];
    fi;
    orbs := DIGRAPHS_Orbits(DigraphStabilizer(D, v),
                            DigraphVertices(D)).orbits;
  else
    rep  := v;
    orbs := List(DigraphVertices(D), x -> [x]);
  fi;

  # from now on rep = v
  layers_with_orbnums := DIGRAPH_ConnectivityDataForVertex(D, v).layers;

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

InstallMethod(DIGRAPHS_Layers, "for a digraph",
[IsDigraph],
function(D)
  return [];
end);

InstallMethod(DigraphDistanceSet,
"for a digraph, a vertex, and a non-negative integers",
[IsDigraph, IsPosInt, IsInt],
function(D, vertex, distance)
  if vertex > DigraphNrVertices(D) then
    ErrorNoReturn("the 2nd argument must be a vertex of the digraph,");
  elif distance < 0 then
    ErrorNoReturn("the 3rd argument must be a non-negative integer,");
  fi;
  return DigraphDistanceSet(D, vertex, [distance]);
end);

InstallMethod(DigraphDistanceSet,
"for a digraph, a vertex, and a list of non-negative integers",
[IsDigraph, IsPosInt, IsList],
function(D, vertex, distances)
  local layers;
  if vertex > DigraphNrVertices(D) then
    ErrorNoReturn("the 2nd argument must be a vertex of the digraph,");
  elif not ForAll(distances, x -> IsInt(x) and x >= 0) then
    ErrorNoReturn("the 3rd argument must be a list of non-negative ",
                  "integers,");
  fi;
  distances := distances + 1;
  layers := DigraphLayers(D, vertex);
  distances := Intersection(distances, [1 .. Length(layers)]);
  return Concatenation(layers{distances});
end);

InstallMethod(DigraphShortestDistance,
"for a digraph, a vertex, and a vertex",
[IsDigraph, IsPosInt, IsPosInt],
function(D, u, v)
  local dist;

  if u > DigraphNrVertices(D) or v > DigraphNrVertices(D) then
    ErrorNoReturn("the 2nd and 3rd arguments must be ",
                  "vertices of the 1st argument (a digraph),");
  fi;

  if HasDigraphShortestDistances(D) then
    return DigraphShortestDistances(D)[u][v];
  fi;

  dist := DIGRAPH_ConnectivityDataForVertex(D, u).layerNumbers[v] - 1;
  if dist = -1 then
    dist := fail;
  fi;
  return dist;
end);

InstallMethod(DigraphShortestDistance, "for a digraph, a list, and a list",
[IsDigraph, IsList, IsList],
function(D, list1, list2)
  local shortest, u, v;

  # TODO: can this be improved?
  shortest := infinity;
  for u in list1 do
    for v in list2 do
      if shortest > DigraphShortestDistance(D, u, v) then
        shortest := DigraphShortestDistance(D, u, v);
      fi;
    od;
  od;
  return shortest;
end);

InstallMethod(DigraphShortestDistance,
"for a digraph, and a list",
[IsDigraph, IsList],
function(D, list)

  if Length(list) <> 2 then
    ErrorNoReturn("the 2nd argument must be of length 2,");
  fi;

  if list[1] > DigraphNrVertices(D) or
      list[2] > DigraphNrVertices(D) then
    ErrorNoReturn("elements of the list must be vertices of the digraph,");
  fi;

  return DigraphShortestDistance(D, list[1], list[2]);
end);

#############################################################################
# 10. Operations for vertices
#############################################################################

InstallMethod(PartialOrderDigraphJoinOfVertices,
"for a dense digraph and two positive integers",
[IsDenseDigraphRep, IsPosInt, IsPosInt],
function(D, i, j)
  local x, nbs, intr;

  if not IsPartialOrderDigraph(D) then
    ErrorNoReturn("the 1st argument (a digraph) must satisfy ",
                  "IsPartialOrderDigraph,");
  elif not i in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument must be a vertex of the ",
                  "1st argument (a digraph), ");
  elif not j in DigraphVertices(D) then
    ErrorNoReturn("the 3rd argument must be a vertex of the ",
                  "1st argument (a digraph), ");
  fi;

  nbs := OutNeighbours(D);
  intr := Intersection(nbs[i], nbs[j]);
  for x in intr do
    if intr = Set(nbs[x]) then
      return x;
    fi;
  od;

  return fail;
end);

InstallMethod(PartialOrderDigraphMeetOfVertices,
"for a digraph and two positive integers",
[IsDigraph, IsPosInt, IsPosInt],
function(D, i, j)
  local x, nbs, intr;

  if not IsPartialOrderDigraph(D) then
    ErrorNoReturn("the 1st argument (a digraph) must satisfy ",
                  "IsPartialOrderDigraph,");
  elif not i in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument must be a vertex of the ",
                  "1st argument (a digraph), ");
  elif not j in DigraphVertices(D) then
    ErrorNoReturn("the 3rd argument must be a vertex of the ",
                  "1st argument (a digraph), ");
  fi;

  nbs := InNeighbours(D);
  intr := Intersection(nbs[i], nbs[j]);
  for x in intr do
    if intr = Set(nbs[x]) then
      return x;
    fi;
  od;

  return fail;
end);
