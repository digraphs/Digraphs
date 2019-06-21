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
  DigraphEdgeLabelAddVertex(D);
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
    ErrorNoReturn("the 2nd argument <m> must be a non-negative integer,");
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
  RemoveDigraphVertexLabel(D, u);
  DigraphEdgeLabelRemoveVertex(D, u);
  Remove(D!.OutNeighbours, u);
  for v in DigraphVertices(D) do
    pos := 1;
    while pos <= Length(D!.OutNeighbours[v]) do
      w := D!.OutNeighbours[v][pos];
      if w = u then
        Remove(D!.OutNeighbours[v], pos);
        RemoveDigraphEdgeLabel(D, v, pos);
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
    ErrorNoReturn("the 2nd argument <list> must be a ",
                  "duplicate-free list,");
  elif not ForAll(list, IsPosInt) then
    ErrorNoReturn("the 2nd argument <list> must be a list ",
                  "consisting of positive integers,");
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
      if not IsMultiDigraph(D) then
        SetDigraphEdgeLabel(D, v, v, 1);
      fi;
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
    ErrorNoReturn("the 2nd argument <src> must be a vertex of the ",
                  "digraph <D> that is the 1st argument,");
  elif not ran in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <ran> must be a vertex of the ",
                  "digraph <D> that is the 1st argument,");
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
    ErrorNoReturn("the 2nd argument <edge> must be a list of length 2,");
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
    ErrorNoReturn("the 1st argument <D> must be a digraph with no multiple ",
                  "edges,");
  elif not (IsPosInt(src) and src in DigraphVertices(D)) then
    ErrorNoReturn("the 2nd argument <src> must be a vertex of the ",
                  "digraph <D> that is the 1st argument,");
  elif not (IsPosInt(ran) and ran in DigraphVertices(D)) then
    ErrorNoReturn("the 3rd argument <ran> must be a vertex of the ",
                  "digraph <D> that is the 1st argument,");
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
    ErrorNoReturn("the 2nd argument <edge> must be a list of length 2,");
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
    ErrorNoReturn("the 1st argument <D> must be a symmetric digraph with no ",
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
  ClearDigraphEdgeLabels(D);
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
  local D, copy, offset, n, i;

  # Allow the possibility of supplying arguments in a list.
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;

  if not IsList(arg) or IsEmpty(arg) or not ForAll(arg, IsDenseDigraphRep) then
    ErrorNoReturn("the arguments must be dense digraphs, or a single ",
                  "list of dense digraphs,");
  fi;

  D := arg[1];
  if IsMutableDigraph(arg[1]) then
    for i in [2 .. Length(arg)] do
      if IsIdenticalObj(arg[1], arg[i]) then
        if not IsBound(copy) then
          copy := OutNeighboursMutableCopy(arg[1]);
        fi;
        arg[i] := copy;
      else
        arg[i] := OutNeighbours(arg[i]);
      fi;
    od;
    arg[1] := arg[1]!.OutNeighbours;
  else
    arg[1] := OutNeighboursMutableCopy(arg[1]);
    for i in [2 .. Length(arg)] do
      arg[i] := OutNeighbours(arg[i]);
    od;
  fi;

  offset := Length(arg[1]);

  for i in [2 .. Length(arg)] do
    n := Length(arg[i]);
    arg[1]{[offset + 1 .. offset + n]} := arg[i] + offset;
    offset := offset + n;
  od;

  if IsMutableDigraph(D) then
    ClearDigraphEdgeLabels(D);
    return D;
  else
    return DigraphNC(arg[1]);
  fi;
end);

InstallGlobalFunction(DigraphJoin,
function(arg)
  local D, copy, tot, offset, n, i, list, v;
  # Allow the possibility of supplying arguments in a list.
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;

  if not IsList(arg) or IsEmpty(arg) or not ForAll(arg, IsDenseDigraphRep) then
    ErrorNoReturn("the arguments must be dense digraphs, or a single ",
                  "list of dense digraphs,");
  fi;

  D := arg[1];
  if IsMutableDigraph(arg[1]) then
    for i in [2 .. Length(arg)] do
      if IsIdenticalObj(arg[1], arg[i]) then
        if not IsBound(copy) then
          copy := OutNeighboursMutableCopy(arg[1]);
        fi;
        arg[i] := copy;
      else
        arg[i] := OutNeighbours(arg[i]);
      fi;
    od;
    arg[1] := arg[1]!.OutNeighbours;
  else
    arg[1] := OutNeighboursMutableCopy(arg[1]);
    for i in [2 .. Length(arg)] do
      arg[i] := OutNeighbours(arg[i]);
    od;
  fi;

  tot    := Sum(arg, Length);
  offset := Length(arg[1]);

  for list in arg[1] do
    Append(list, [offset + 1 .. tot]);
  od;

  for i in [2 .. Length(arg)] do
    n := Length(arg[i]);
    for v in [1 .. n] do
      arg[1][v + offset] := Concatenation([1 .. offset],
                                          arg[i][v] + offset,
                                          [offset + n + 1 .. tot]);
    od;
    offset := offset + n;
  od;

  if IsMutableDigraph(D) then
    ClearDigraphEdgeLabels(D);
    return D;
  else
    return DigraphNC(arg[1]);
  fi;
end);

InstallGlobalFunction(DigraphEdgeUnion,
function(arg)
  local D, n, copy, i, v;

  # Allow the possibility of supplying arguments in a list.
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;

  if not IsList(arg) or IsEmpty(arg) or not ForAll(arg, IsDenseDigraphRep) then
    ErrorNoReturn("the arguments must be dense digraphs, or a single ",
                  "list of dense digraphs,");
  fi;

  D := arg[1];
  n := Maximum(List(arg, DigraphNrVertices));
  if IsMutableDigraph(arg[1]) then
    DigraphAddVertices(arg[1], n - DigraphNrVertices(arg[1]));
    for i in [2 .. Length(arg)] do
      if IsIdenticalObj(arg[1], arg[i]) then
        if not IsBound(copy) then
          copy := OutNeighboursMutableCopy(arg[1]);
        fi;
        arg[i] := copy;
      else
        arg[i] := OutNeighbours(arg[i]);
      fi;
    od;
    arg[1] := arg[1]!.OutNeighbours;
  else
    arg[1] := OutNeighboursMutableCopy(arg[1]);
    Append(arg[1], List([1 .. n - Length(arg[1])], x -> []));
    for i in [2 .. Length(arg)] do
      arg[i] := OutNeighbours(arg[i]);
    od;
  fi;

  for i in [2 .. Length(arg)] do
    for v in [1 .. Length(arg[i])] do
      if not IsEmpty(arg[i][v]) then
        Append(arg[1][v], arg[i][v]);
      fi;
    od;
  od;
  if IsMutableDigraph(D) then
    ClearDigraphEdgeLabels(D);
    return D;
  else
    return DigraphNC(arg[1]);
  fi;
end);

# For a topologically sortable digraph G, this returns the least subgraph G'
# of G such that the (reflexive) transitive closures of G and G' are equal.
InstallMethod(DigraphReflexiveTransitiveReduction, "for a mutable digraph",
[IsMutableDigraph],
function(D)
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no ",
                  "multiple edges,");
  elif DigraphTopologicalSort(D) = fail then
    ErrorNoReturn("not yet implemented for non-topologically sortable ",
                  "digraphs,");
  elif IsNullDigraph(D) then
    return D;
  fi;
  return DigraphTransitiveReduction(DigraphRemoveLoops(D));
end);

InstallMethod(DigraphReflexiveTransitiveReduction, "for an immutable digraph",
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
    ErrorNoReturn("the argument <D> must be a digraph with no ",
                  "multiple edges,");
  elif DigraphTopologicalSort(D) = fail then
    ErrorNoReturn("not yet implemented for non-topologically sortable ",
                  "digraphs,");
  fi;
  topo := DigraphTopologicalSort(D);
  p    := Permutation(Transformation(topo), topo);
  OnDigraphs(D, p ^ -1);       # changes D in-place
  DIGRAPH_TRANS_REDUCTION(D);  # changes D in-place
  ClearDigraphEdgeLabels(D);
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
  ClearDigraphEdgeLabels(D);
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
    ErrorNoReturn("the 1st argument <D> must be a digraph with no ",
                  "multiple edges,");
  fi;
  pos := Position(D!.OutNeighbours[u], v);
  if pos = fail then
    ErrorNoReturn("there is no edge from ", u, " to ", v,
                  " in the digraph <D> that is the 1st argument,");
  elif u = v then
    return D;
  fi;
  Add(D!.OutNeighbours[v], u);
  Remove(D!.OutNeighbours[u], pos);
  ClearDigraphEdgeLabels(D);
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
    ErrorNoReturn("the 2nd argument <e> must be a list of length 2,");
  fi;
  return DigraphReverseEdge(D, e[1], e[2]);
end);

InstallMethod(DigraphReverseEdge, "for an immutable digraph and a list",
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
    ErrorNoReturn("the 2nd argument <p> must be a permutation that permutes ",
                  "of the digraph <D> that is the 1st argument,");
  fi;
  out := D!.OutNeighbours;
  out{DigraphVertices(D)} := Permuted(out, p);
  Apply(out, x -> OnTuples(x, p));
  ClearDigraphEdgeLabels(D);
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
    ErrorNoReturn("the 2nd argument <t> must be a transformation that ",
                  "maps every vertex of the digraph <D> that is the 1st ",
                  "argument, to another vertex.");
  fi;
  old := D!.OutNeighbours;
  new := List(DigraphVertices(D), x -> []);
  for v in DigraphVertices(D) do
    Append(new[v ^ t], OnTuples(old[v], t));
  od;
  old{DigraphVertices(D)} := new;
  ClearDigraphEdgeLabels(D);
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
  IsValidDigraph(D);
  return OnMultiDigraphs(D, [perm1, perm2]);
end);

InstallMethod(OnMultiDigraphs, "for a digraph and perm coll",
[IsDigraph, IsPermCollection],
function(D, perms)
  IsValidDigraph(D);
  if Length(perms) <> 2 then
    ErrorNoReturn("the 2nd argument <perms> must be a pair of permutations,");
  fi;

  if ForAny([1 .. DigraphNrEdges(D)],
            i -> i ^ perms[2] > DigraphNrEdges(D)) then
    ErrorNoReturn("the 2nd entry of the 2nd argument <perms> must ",
                  "permute the edges of the digraph <D> that is the 1st ",
                  "argument,");
  fi;

  return OnDigraphs(D, perms[1]);
end);

#############################################################################
# 5. Substructures and quotients
#############################################################################

InstallMethod(InducedSubdigraph,
"for a dense mutable digraph and a homogeneous list",
[IsDenseDigraphRep and IsMutableDigraph, IsHomogeneousList],
function(D, list)
  local M, N, old, old_edl, new_edl, lookup, next, vv, w, old_labels, v, i;

  M := Length(list);
  if M = 0 then
    D!.OutNeighbours := [];
    return D;
  fi;
  N := DigraphNrVertices(D);
  if (IsRange(list) and not
      (IsPosInt(list[1]) and list[1] <= N and
       list[Length(list)] <= N))
      or not IsDuplicateFree(list)
      or not ForAll(list, x -> IsPosInt(x) and x <= N) then
    ErrorNoReturn("the 2nd argument <list> must be a duplicate-free ",
                  "subset of the vertices of the digraph <D> that is ",
                  "the 1st argument,");
  fi;

  old := D!.OutNeighbours;
  old_edl := DigraphEdgeLabelsNC(D);
  new_edl := List([1 .. M], x -> []);

  lookup := ListWithIdenticalEntries(N, 0);
  lookup{list} := [1 .. M];

  for v in [1 .. M] do
    next := [];
    vv := list[v];  # old vertex corresponding to vertex v in new subdigraph
    for i in [1 .. Length(old[vv])] do
      w := old[vv][i];
      if lookup[w] <> 0 then
        Add(next, lookup[w]);
        Add(new_edl[v], old_edl[vv][i]);
      fi;
    od;
    old[vv] := next;
  od;
  old_labels := DigraphVertexLabels(D);
  D!.OutNeighbours := old{list};
  SetDigraphEdgeLabelsNC(D, new_edl);
  SetDigraphVertexLabels(D, old_labels{list});
  return D;
end);

InstallMethod(InducedSubdigraph,
"for an immutable digraph and a homogeneous list",
[IsImmutableDigraph, IsHomogeneousList],
function(D, list)
  return MakeImmutableDigraph(InducedSubdigraph(DigraphMutableCopy(D), list));
end);

InstallMethod(QuotientDigraph,
"for a dense mutable digraph and a homogeneous list",
[IsDenseDigraphRep and IsMutableDigraph, IsHomogeneousList],
function(D, partition)
  local N, M, check, lookup, new, new_vl, new_el, old, old_vl, old_el, x, i, u,
  v;
  N := DigraphNrVertices(D);
  if N = 0 then
    if IsEmpty(partition) then
      return D;
    else
      ErrorNoReturn("the 2nd argument <partition> is not a valid ",
                    "partition of the vertices of 1st argument <D>.",
                    "The only valid partition of a null digraph is ",
                    "the empty list,");
    fi;
  fi;
  M := Length(partition);
  if M = 0 or M = 0 or not IsList(partition[1])
      or IsEmpty(partition[1]) or not IsPosInt(partition[1][1]) then
    ErrorNoReturn("the 2nd argument <partition> is not a valid ",
                  "partition of the vertices [1 .. ", N, "] of the 1st ",
                  "argument <D>,");
  fi;
  check := BlistList(DigraphVertices(D), []);
  lookup := EmptyPlist(N);
  for x in [1 .. Length(partition)] do
    for i in partition[x] do
      if i < 1 or i > N or check[i] then
        ErrorNoReturn("the 2nd argument <partition> is not a valid ",
                      "partition of the vertices [1 .. ", N, "] of the 1st ",
                      "argument <D>,");
      fi;
      check[i] := true;
      lookup[i] := x;
    od;
  od;
  if ForAny(check, x -> not x) then
      ErrorNoReturn("the 2nd argument <partition> is not a valid ",
                    "partition of the vertices [1 .. ", N, "] of the 1st ",
                    "argument <D>,");
  fi;
  new    := List([1 .. M], x -> []);
  new_vl := List([1 .. M], x -> []);
  new_el := List([1 .. M], x -> []);
  old    := D!.OutNeighbours;
  old_vl := DigraphVertexLabels(D);
  old_el := DigraphEdgeLabelsNC(D);
  for u in DigraphVertices(D) do
    Add(new_vl[lookup[u]], old_vl[u]);
    for v in old[u] do
      Add(new[lookup[u]], lookup[v]);
      Add(new_el[lookup[u]], old_el[v]);
    od;
  od;
  D!.OutNeighbours := new;
  SetDigraphVertexLabels(D, new_vl);
  SetDigraphEdgeLabelsNC(D, new_el);
  return D;
end);

InstallMethod(QuotientDigraph,
"for an immutable digraph and a homogeneous list",
[IsImmutableDigraph, IsHomogeneousList],
function(D, partition)
  return MakeImmutableDigraph(QuotientDigraph(DigraphMutableCopy(D),
                                              partition));
end);

#############################################################################
# 6. In and out degrees and edges of vertices
#############################################################################

InstallMethod(InNeighboursOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(D, v)
  IsValidDigraph(D);
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> is not a vertex of the ",
                  "1st argument <D>,");
  fi;
  return InNeighboursOfVertexNC(D, v);
end);

InstallMethod(InNeighboursOfVertexNC,
"for a digraph with in-neighbours and a vertex",
[IsDigraph and HasInNeighbours, IsPosInt],
2,  # to beat the next method for IsDenseDigraphRep
function(D, v)
  IsValidDigraph(D);
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
  IsValidDigraph(D);
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> is not a vertex of the ",
                  "1st argument <D>,");
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
  IsValidDigraph(D);
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> is not a vertex of the ",
                  "1st argument <D>,");
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
  IsValidDigraph(D);
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> is not a vertex of the ",
                  "1st argument <D>,");
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
  IsValidDigraph(D);
  return Length(OutNeighbours(D)[v]);
end);

InstallMethod(DigraphOutEdges, "for a dense digraph and a vertex",
[IsDenseDigraphRep, IsPosInt],
function(D, v)
  IsValidDigraph(D);
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> is not a vertex of the ",
                  "1st argument <D>,");
  fi;
  return List(OutNeighboursOfVertex(D, v), x -> [v, x]);
end);

InstallMethod(DigraphInEdges, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(D, v)
  IsValidDigraph(D);
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> is not a vertex of the ",
                  "1st argument <D>,");
  fi;
  return List(InNeighboursOfVertex(D, v), x -> [x, v]);
end);

#############################################################################
# 7. Copies of out/in-neighbours
#############################################################################

InstallMethod(OutNeighboursMutableCopy, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  IsValidDigraph(D);
  return List(OutNeighbours(D), ShallowCopy);
end);

InstallMethod(InNeighboursMutableCopy, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return List(InNeighbours(D), ShallowCopy);
end);

InstallMethod(AdjacencyMatrixMutableCopy, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return List(AdjacencyMatrix(D), ShallowCopy);
end);

InstallMethod(BooleanAdjacencyMatrixMutableCopy, "for a digraph", [IsDigraph],
function(D)
  IsValidDigraph(D);
  return List(BooleanAdjacencyMatrix(D), ShallowCopy);
end);

#############################################################################
# 8.  IsSomething
#############################################################################

InstallMethod(IsDigraphEdge, "for a digraph and a list",
[IsDigraph, IsList],
function(D, edge)
  IsValidDigraph(D);
  if Length(edge) <> 2 or not IsPosInt(edge[1]) or not IsPosInt(edge[2]) then
    return false;
  fi;
  return IsDigraphEdge(D, edge[1], edge[2]);
end);

InstallMethod(IsDigraphEdge, "for a dense digraph, int, int",
[IsDenseDigraphRep, IsInt, IsInt],
function(D, u, v)
  local n;
  IsValidDigraph(D);

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
  IsValidDigraph(super, sub);

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
  IsValidDigraph(super, sub);

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
  IsValidDigraph(super, sub);
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
  IsValidDigraph(D);
  return DIGRAPHS_Matching(D, edges) <> false;
end);

InstallMethod(IsPerfectMatching, "for a digraph and a list",
[IsDigraph, IsHomogeneousList],
function(D, edges)
  local seen;
  IsValidDigraph(D);

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
  IsValidDigraph(D);

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
  IsValidDigraph(D);

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
  IsValidDigraph(D);
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> is not a vertex of the ",
                  "1st argument <D>,");
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
  IsValidDigraph(D);
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> is not a vertex of the ",
                  "1st argument <D>,");
  fi;
  wcc := DigraphConnectedComponents(D);
  return wcc.comps[wcc.id[v]];
end);

InstallMethod(IsReachable, "for a digraph and two pos ints",
[IsDigraph, IsPosInt, IsPosInt],
function(D, u, v)
  local verts, scc;
  IsValidDigraph(D);

  verts := DigraphVertices(D);
  if not (u in verts and v in verts) then
    ErrorNoReturn("the 2nd and 3rd arguments <u> and <v> must be ",
                  "vertices of the 1st argument <D>,");
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
  IsValidDigraph(D);

  verts := DigraphVertices(D);
  if not (u in verts and v in verts) then
    ErrorNoReturn("the 2nd and 3rd arguments <u> and <v> must be ",
                  "vertices of the 1st argument <D>,");
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
  IsValidDigraph(D);

  verts := DigraphVertices(D);
  if not (u in verts and v in verts) then
    ErrorNoReturn("the 2nd and 3rd arguments <u> and <v> must be ",
                  "vertices of the 1st argument <D>,");
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
  IsValidDigraph(D);
  if not (u in DigraphVertices(D) and v in DigraphVertices(D)) then
    ErrorNoReturn("the 2nd and 3rd arguments <u> and <v> must be ",
                  "vertices of the 1st argument <D>,");
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
    ErrorNoReturn("the 1st argument <out> must be a list of out-neighbours",
                  " of a digraph,");
  elif not (u <= n and v <= n) then
    ErrorNoReturn("the 2nd and 3rd arguments <u> and <v> must be vertices ",
                  "of the digraph defined by the 1st argument <out>,");
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
  IsValidDigraph(D);

  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> must be a vertex of the 1st ",
                  "argument <D>,");
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
  IsValidDigraph(D);

  # TODO: make use of known distances matrix
  if v > DigraphNrVertices(D) then
    ErrorNoReturn("the 2nd argument <v> must be a vertex of the 1st ",
                  "argument <D>,");
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

InstallMethod(DIGRAPHS_Layers, "for a digraph", [IsDigraph],
function(D)
  return [];
end);

InstallMethod(DigraphDistanceSet,
"for a digraph, a vertex, and a non-negative integers",
[IsDigraph, IsPosInt, IsInt],
function(D, vertex, distance)
  IsValidDigraph(D);
  if vertex > DigraphNrVertices(D) then
    ErrorNoReturn("the 2nd argument <vertex> must be a vertex of the ",
                  "digraph,");
  elif distance < 0 then
    ErrorNoReturn("the 3rd argument <distance> must be a non-negative ",
                  "integer,");
  fi;
  return DigraphDistanceSet(D, vertex, [distance]);
end);

InstallMethod(DigraphDistanceSet,
"for a digraph, a vertex, and a list of non-negative integers",
[IsDigraph, IsPosInt, IsList],
function(D, vertex, distances)
  local layers;
  IsValidDigraph(D);
  if vertex > DigraphNrVertices(D) then
    ErrorNoReturn("the 2nd argument <vertex> must be a vertex of ",
                  "the digraph,");
  elif not ForAll(distances, x -> IsInt(x) and x >= 0) then
    ErrorNoReturn("the 3rd argument <distances> must be a list of ",
                  "non-negative integers,");
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
  IsValidDigraph(D);

  if u > DigraphNrVertices(D) or v > DigraphNrVertices(D) then
    ErrorNoReturn("the 2nd and 3rd arguments <u> and <v> must be ",
                  "vertices of the 1st argument <D>,");
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
  IsValidDigraph(D);

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

InstallMethod(DigraphShortestDistance, "for a digraph, and a list",
[IsDigraph, IsList],
function(D, list)
  IsValidDigraph(D);

  if Length(list) <> 2 then
    ErrorNoReturn("the 2nd argument <list> must be a list of length 2,");
  fi;

  if list[1] > DigraphNrVertices(D) or
      list[2] > DigraphNrVertices(D) then
      ErrorNoReturn("the 2nd argument <list> must consist of vertices of ",
                    "the 1st argument <D>,");
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

  IsValidDigraph(D);
  if not IsPartialOrderDigraph(D) then
    ErrorNoReturn("the 1st argument <D> must satisfy ",
                  "IsPartialOrderDigraph,");
  elif not i in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <i> must be a vertex of the ",
                  "1st argument <D>,");
  elif not j in DigraphVertices(D) then
    ErrorNoReturn("the 3rd argument <j> must be a vertex of the ",
                  "1st argument <D>,");
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
  IsValidDigraph(D);

  if not IsPartialOrderDigraph(D) then
    ErrorNoReturn("the 1st argument <D> must satisfy ",
                  "IsPartialOrderDigraph,");
  elif not i in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <i> must be a vertex of the ",
                  "1st argument <D>,");
  elif not j in DigraphVertices(D) then
    ErrorNoReturn("the 3rd argument <j> must be a vertex of the ",
                  "1st argument <D>,");
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

InstallMethod(AsSemigroup,
"for a function, a digraph, and a dense list",
[IsFunction, IsDigraph, IsDenseList, IsDenseList],
function(filt, digraph, gps, homs)
  local red, n, hom_table, reps, rep, top, doms, starts, degs, max, gens, img,
  start, deg, x, queue, j, k, g, y, hom, edge, i, gen;

  if not filt = IsPartialPermSemigroup then
    TryNextMethod();
  elif not IsJoinSemilatticeDigraph(digraph) then
    if IsMeetSemilatticeDigraph(digraph) then
      return AsSemigroup(IsPartialPermSemigroup,
                         DigraphReverse(digraph),
                         gps,
                         homs);
    else
      ErrorNoReturn("Digraphs: AsSemigroup usage,\n",
                    "the second argument must be a join semilattice ",
                    "digraph or a meet semilattice digraph,");
    fi;
  elif not ForAll(gps, x -> IsGroup(x)) then
    ErrorNoReturn("Digraphs: AsSemigroup usage,\n",
                  "the third argument must be a list of groups,");
  elif not Length(gps) = DigraphNrVertices(digraph) then
    ErrorNoReturn("Digraphs: AsSemigroup usage,\n",
                  "the third argument must have length equal to the number ",
                  "of vertices in the second argument,");
  fi;

  red := DigraphReflexiveTransitiveReduction(digraph);
  if not Length(homs) = DigraphNrEdges(red) or
       not ForAll(homs, x -> Length(x) = 3 and
                             IsPosInt(x[1]) and
                             IsPosInt(x[2]) and
                             IsDigraphEdge(red, [x[1], x[2]]) and
                             IsGroupHomomorphism(x[3]) and
                             Source(x[3]) = gps[x[1]] and
                             Range(x[3]) = gps[x[2]]) then
    ErrorNoReturn("Digraphs: AsSemigroup usage,\n",
                  "the third argument must be a list of triples [i, j, hom] ",
                  "of length equal to the number of edges in the reflexive ",
                  "transitive reduction of the second argument, where [i, j] ",
                  "is an edge in the reflex transitive reduction and hom is ",
                  "a group homomorphism from group i to group j,");
  fi;

  n := DigraphNrVertices(digraph);

  hom_table := List([1 .. n], x -> []);
  for hom in homs do
    hom_table[hom[1]][hom[2]] := hom[3];
  od;

  for edge in DigraphEdges(red) do
    if not IsBound(hom_table[edge[1]][edge[2]]) then
      ErrorNoReturn("Digraphs: AsSemigroup usage,\n",
                    "the fourth argument must contain a triple [i, j, hom] ",
                    "for each edge [i, j] in the reflexive transitive ",
                    "reduction of the second argument,");
    fi;
  od;

  reps := [];
  for i in [1 .. n] do
    rep := IsomorphismPermGroup(gps[i]);
    rep := rep * SmallerDegreePermutationRepresentation(Image(rep));
    Add(reps, rep);
  od;

  top     := DigraphTopologicalSort(digraph);
  doms    := [];
  starts  := [];
  degs    := List([1 .. n], i -> NrMovedPoints(Image(reps[i])));
  for i in [1 .. n] do
    if degs[i] = 0 then
      degs[i] := 1;
    fi;
  od;
  max             := degs[top[1]] + 1;
  doms[top[1]]    := [1 .. max - 1];
  starts[top[1]]  := 1;

  for i in [2 .. n] do
    doms[top[i]] := Union(List(OutNeighboursOfVertex(red, top[i]),
                               j -> doms[j]));
    Append(doms[top[i]], [max .. max + degs[top[i]] - 1]);
    starts[top[i]] := max;
    max := max + degs[top[i]];
  od;

  gens := [];
  for i in [1 .. n] do
    for gen in GeneratorsOfGroup(gps[top[i]]) do
      img := [];
      start := starts[top[i]];
      deg := degs[top[i]];
      x := ListPerm(gen ^ reps[top[i]]);

      # make sure the partial permutation is defined on the whole domain
      img{[start .. start + deg - 1]} := [1 .. deg] + start - 1;
      # now the actual representation
      img{[start .. start + Length(x) - 1]} := x + start - 1;

      # travel up all the paths from top[i], applying the homomorphisms
      # and storing the results as permutations on the appropriate set
      # of points
      queue := List(OutNeighboursOfVertex(red, top[i]), y -> [top[i], y, gen]);
      while Length(queue) > 0 do
        j     := queue[1][1];
        k     := queue[1][2];
        g     := queue[1][3];
        start := starts[k];
        deg   := degs[k];
        Remove(queue, 1);
        x := g ^ hom_table[j][k];
        Append(queue, List(OutNeighboursOfVertex(red, k), y -> [k, y, x]));
        x := x ^ reps[k];

        # Check that compositions of homomorphisms commute.
        # If img[start] is bound then we have already found some composition of
        # homomorphisms which takes us into gps[k], so we must ensure that this
        # agrees with the composition we are currently considering.
        if IsBound(img[start]) then
          y := PermList(img{[start .. start + deg - 1]} - start + 1);
          if not x = y then
            ErrorNoReturn("Digraphs: AsSemigroup usage,\n",
                          "the homomorphisms given must form a commutative",
                          " diagram,");
          fi;
        fi;
        x := ListPerm(x);
        img{[start .. start + deg - 1]} := [1 .. deg] + start - 1;
        img{[start .. start + Length(x) - 1]} := x + start - 1;
      od;
      img := Compacted(img);
      Add(gens, PartialPerm(doms[top[i]], img));
    od;
  od;
  return Semigroup(gens);
end);
