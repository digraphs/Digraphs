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
# 2.  Adding, removing, and reversing edges
# 3.  Ways of combining digraphs
# 4.  Actions
# 5.  Substructures and quotients
# 6.  In and out degrees, neighbours, and edges of vertices
# 7.  Copies of out/in-neighbours
# 8.  IsSomething
# 9.  Connectivity
# 10. Operations for vertices
#############################################################################

#############################################################################
# 1. Adding and removing vertices
#############################################################################

InstallMethod(DigraphAddVertex,
"for a mutable digraph by out-neighbours and an object",
[IsMutableDigraph and IsDigraphByOutNeighboursRep, IsObject],
function(D, label)
  Add(D!.OutNeighbours, []);
  SetDigraphVertexLabel(D, DigraphNrVertices(D), label);
  if IsBound(D!.edgelabels) then
    Add(D!.edgelabels, []);
  fi;
  return D;
end);

InstallMethod(DigraphAddVertex, "for a immutable digraph and an object",
[IsImmutableDigraph, IsObject],
{D, label} -> MakeImmutable(DigraphAddVertex(DigraphMutableCopy(D), label)));

InstallMethod(DigraphAddVertex, "for a mutable digraph",
[IsMutableDigraph],
D -> DigraphAddVertex(D, DigraphNrVertices(D) + 1));

InstallMethod(DigraphAddVertex, "for an immutable digraph",
[IsImmutableDigraph],
D -> MakeImmutable(DigraphAddVertex(DigraphMutableCopy(D))));

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
  if IsEmpty(labels) then
    return D;
  fi;
  return MakeImmutable(DigraphAddVertices(DigraphMutableCopy(D), labels));
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
  if m = 0 then
    return D;
  fi;
  return MakeImmutable(DigraphAddVertices(DigraphMutableCopy(D), m));
end);

# Included for backwards compatibility, even though the 2nd arg is redundant.
# See https://github.com/digraphs/Digraphs/issues/264
# This is deliberately kept undocumented.
InstallMethod(DigraphAddVertices, "for a digraph, an integer, and a list",
[IsDigraph, IsInt, IsList],
function(D, m, labels)
  if m <> Length(labels) then
    ErrorNoReturn("the list <labels> (3rd argument) must have length <m> ",
                  "(2nd argument),");
  fi;
  return DigraphAddVertices(D, labels);
end);

InstallMethod(DigraphRemoveVertex,
"for a mutable digraph by out-neighbours and positive integer",
[IsMutableDigraph and IsDigraphByOutNeighboursRep, IsPosInt],
function(D, u)
  local pos, w, v;
  if u > DigraphNrVertices(D) then
    return D;
  fi;
  RemoveDigraphVertexLabel(D, u);
  if IsBound(D!.edgelabels) then
    Remove(D!.edgelabels, u);
  fi;
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
function(D, u)
  if u > DigraphNrVertices(D) then
    return D;
  fi;
  return MakeImmutable(DigraphRemoveVertex(DigraphMutableCopy(D), u));
end);

InstallMethod(DigraphRemoveVertices, "for a mutable digraph and a list",
[IsMutableDigraph, IsList],
function(D, list)
  local v;
  if not IsDuplicateFreeList(list) or not ForAll(list, IsPosInt) then
    ErrorNoReturn("the 2nd argument <list> must be a ",
                  "duplicate-free list of positive integers,");
  elif not IsMutable(list) then
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
{D, list} -> MakeImmutable(DigraphRemoveVertices(DigraphMutableCopy(D), list)));

#############################################################################
# 2. Adding and removing edges
#############################################################################

InstallMethod(DigraphAddEdge,
"for a mutable digraph by out-neighbours, a two positive integers",
[IsMutableDigraph and IsDigraphByOutNeighboursRep, IsPosInt, IsPosInt],
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
"for an immutable digraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(D, src, ran)
  return MakeImmutable(DigraphAddEdge(DigraphMutableCopy(D), src, ran));
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
{D, edge} -> MakeImmutable(DigraphAddEdge(DigraphMutableCopy(D), edge)));

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
{D, edges} -> MakeImmutable(DigraphAddEdges(DigraphMutableCopy(D), edges)));

InstallMethod(DigraphRemoveEdge,
"for a mutable digraph by out-neighbours and two positive integers",
[IsMutableDigraph and IsDigraphByOutNeighboursRep, IsPosInt, IsPosInt],
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
"for a immutable digraph and two positive integers",
[IsImmutableDigraph, IsPosInt, IsPosInt],
function(D, src, ran)
  return MakeImmutable(DigraphRemoveEdge(DigraphMutableCopy(D), src, ran));
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
{D, edge} -> MakeImmutable(DigraphRemoveEdge(DigraphMutableCopy(D), edge)));

InstallMethod(DigraphRemoveEdges, "for a digraph and a list",
[IsMutableDigraph, IsList],
function(D, edges)
  Perform(edges, edge -> DigraphRemoveEdge(D, edge));
  return D;
end);

InstallMethod(DigraphRemoveEdges, "for an immutable digraph and a list",
[IsImmutableDigraph, IsList],
{D, edges} -> MakeImmutable(DigraphRemoveEdges(DigraphMutableCopy(D), edges)));

InstallMethod(DigraphReverseEdge,
"for a mutable digraph by out-neighbours and two positive integers",
[IsMutableDigraph and IsDigraphByOutNeighboursRep, IsPosInt, IsPosInt],
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
  Remove(D!.OutNeighbours[u], pos);
  Add(D!.OutNeighbours[v], u);
  if Length(Positions(D!.OutNeighbours[v], u)) > 1 then
    # output is a multidigraph
    ClearDigraphEdgeLabels(D);
  elif IsBound(D!.edgelabels)
      and IsBound(D!.edgelabels[u])
      and IsBound(D!.edgelabels[u][pos]) then
    SetDigraphEdgeLabel(D, v, u, D!.edgelabels[u][pos]);
    RemoveDigraphEdgeLabel(D, u, pos);
  fi;
  return D;
end);

InstallMethod(DigraphReverseEdge,
"for an immutable digraph, positive integer, and positive integer",
[IsImmutableDigraph, IsPosInt, IsPosInt],
{D, u, v} -> MakeImmutable(DigraphReverseEdge(DigraphMutableCopy(D), u, v)));

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
{D, e} -> MakeImmutable(DigraphReverseEdge(DigraphMutableCopy(D), e)));

InstallMethod(DigraphReverseEdges, "for a mutable digraph and a list",
[IsMutableDigraph, IsList],
function(D, E)
  Perform(E, e -> DigraphReverseEdge(D, e));
  return D;
end);

InstallMethod(DigraphReverseEdges, "for an immutable digraph and a list",
[IsImmutableDigraph, IsList],
{D, E} -> MakeImmutable(DigraphReverseEdges(DigraphMutableCopy(D), E)));

InstallMethod(DigraphClosure,
"for a mutable digraph by out-neighbours and a positive integer",
[IsMutableDigraph and IsDigraphByOutNeighboursRep, IsPosInt],
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
"for an immutable digraph by out-neighbours and a positive integer",
[IsImmutableDigraph, IsPosInt],
{D, k} -> MakeImmutable(DigraphClosure(DigraphMutableCopy(D), k)));

#############################################################################
# 3. Ways of combining digraphs
#############################################################################

InstallGlobalFunction(DIGRAPHS_CombinationOperProcessArgs,
function(arg)
  local copy, i;
  arg := arg[1];
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
end);

InstallGlobalFunction(DigraphDisjointUnion,
function(arg)
  local D, offset, n, i, j;

  # Allow the possibility of supplying arguments in a list.
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;

  if not IsList(arg) or IsEmpty(arg)
      or not ForAll(arg, IsDigraphByOutNeighboursRep) then
    ErrorNoReturn("the arguments must be digraphs by out-neighbours, or a ",
                  "single non-empty list of digraphs by out-neighbours,");
  fi;

  D := arg[1];
  DIGRAPHS_CombinationOperProcessArgs(arg);
  offset := DigraphNrVertices(D);
  for i in [2 .. Length(arg)] do
    n := Length(arg[i]);
    for j in [1 .. n] do
      arg[1][offset + j] := ShallowCopy(arg[i][j]) + offset;
    od;
    offset := offset + n;
  od;

  if IsMutableDigraph(D) then
    SetDigraphVertexLabels(D, DigraphVertices(D));
    # This above stops D keeping its old vertex labels after being changed
    ClearDigraphEdgeLabels(D);
    return D;
  fi;
  return ConvertToImmutableDigraphNC(arg[1]);
end);

InstallGlobalFunction(DigraphJoin,
function(arg)
  local D, tot, offset, n, list, i, v;
  # Allow the possibility of supplying arguments in a list.
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;

  if not IsList(arg) or IsEmpty(arg)
      or not ForAll(arg, IsDigraphByOutNeighboursRep) then
    ErrorNoReturn("the arguments must be digraphs by out-neighbours, or a ",
                  "single list of digraphs by out-neighbours,");
  fi;

  D      := arg[1];
  tot    := Sum(arg, DigraphNrVertices);
  offset := DigraphNrVertices(D);
  DIGRAPHS_CombinationOperProcessArgs(arg);

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
  fi;
  return ConvertToImmutableDigraphNC(arg[1]);
end);

InstallGlobalFunction(DigraphEdgeUnion,
function(arg)
  local D, n, i, v;

  # Allow the possibility of supplying arguments in a list.
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;

  if not IsList(arg) or IsEmpty(arg)
      or not ForAll(arg, IsDigraphByOutNeighboursRep) then
    ErrorNoReturn("the arguments must be digraphs by out-neighbours, or a ",
                  "single list of digraphs by out-neighbours,");
  fi;

  D := arg[1];
  n := Maximum(List(arg, DigraphNrVertices));
  DIGRAPHS_CombinationOperProcessArgs(arg);

  if IsMutableDigraph(D) then
    DigraphAddVertices(D, n - DigraphNrVertices(D));
  else
    Append(arg[1], List([1 .. n - Length(arg[1])], x -> []));
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
  fi;
  return ConvertToImmutableDigraphNC(arg[1]);
end);

InstallGlobalFunction(DigraphCartesianProduct,
function(arg)
  local D, n, i, j, proj, m, labs;

  # Allow the possibility of supplying arguments in a list.
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;

  if not IsList(arg) or IsEmpty(arg)
      or not ForAll(arg, IsDigraphByOutNeighboursRep) then
    ErrorNoReturn("the arguments must be digraphs by out-neighbours, or a ",
                  "single list of digraphs by out-neighbours,");
  fi;

  labs := List(Cartesian(Reversed(List(arg, DigraphVertexLabels))), Reversed);

  D := arg[1];
  DIGRAPHS_CombinationOperProcessArgs(arg);

  m := Product(List(arg, Length));
  proj := [Transformation([1 .. m], x -> RemInt(x - 1, Length(arg[1])) + 1)];
  for i in [2 .. Length(arg)] do
    n := Length(arg[1]);
    Add(proj, Transformation([1 .. m],
              x -> RemInt(QuoInt(x - 1, n), Length(arg[i])) * n + 1));
    for j in [2 .. Length(arg[i])] do
      arg[1]{[1 + n * (j - 1) .. n * j]} := List([1 .. n],
        x -> Concatenation(arg[1][x] + n * (j - 1),
                            x + n * (arg[i][j] - 1)));
    od;
    for j in [1 .. n] do
      Append(arg[1][j], j + n * (arg[i][1] - 1));
    od;
  od;

  if IsMutableDigraph(D) then
    ClearDigraphEdgeLabels(D);
  else
    D := DigraphNC(arg[1]);
  fi;
  SetDigraphCartesianProductProjections(D, proj);
  SetDigraphVertexLabels(D, labs);
  return D;
end);

InstallGlobalFunction(DigraphDirectProduct,
function(arg)
  local D, n, i, j, proj, m, labs;

  # Allow the possibility of supplying arguments in a list.
  if Length(arg) = 1 and IsList(arg[1]) then
    arg := arg[1];
  fi;

  if not IsList(arg) or IsEmpty(arg)
      or not ForAll(arg, IsDigraphByOutNeighboursRep) then
    ErrorNoReturn("the arguments must be digraphs by out-neighbours, or a ",
                  "single list of digraphs by out-neighbours,");
  fi;

  labs := List(Cartesian(Reversed(List(arg, DigraphVertexLabels))), Reversed);

  D := arg[1];
  DIGRAPHS_CombinationOperProcessArgs(arg);

  m := Product(List(arg, Length));
  proj := [Transformation([1 .. m], x -> RemInt(x - 1, Length(arg[1])) + 1)];
  for i in [2 .. Length(arg)] do
    n := Length(arg[1]);
    Add(proj, Transformation([1 .. m],
              x -> RemInt(QuoInt(x - 1, n), Length(arg[i])) * n + 1));
    for j in [2 .. Length(arg[i])] do
      arg[1]{[1 + n * (j - 1) .. n * j]} := List([1 .. n],
        x -> List(Cartesian(arg[1][x], n * (arg[i][j] - 1)), Sum));
    od;
    for j in [1 .. n] do
      arg[1][j] := List(Cartesian(arg[1][j], n * (arg[i][1] - 1)), Sum);
    od;
  od;

  if IsMutableDigraph(D) then
    ClearDigraphEdgeLabels(D);
  else
    D := DigraphNC(arg[1]);
  fi;
  SetDigraphDirectProductProjections(D, proj);
  SetDigraphVertexLabels(D, labs);
  return D;
end);

InstallMethod(ModularProduct, "for a digraph and digraph",
[IsDigraph, IsDigraph],
function(D1, D2)
  local m, n, E1, E2, edges, next, map, u, v, w, x;

  if IsMultiDigraph(D1) or IsMultiDigraph(D2) then
    ErrorNoReturn("ModularProduct does not support multidigraphs,");
  fi;

  m := DigraphNrVertices(D1);
  n := DigraphNrVertices(D2);

  E1 := DigraphDual(D1);
  E2 := DigraphDual(D2);

  edges := EmptyPlist(m * n);
  next  := 0;

  map := function(a, b)
    return (a - 1) * n + b;
  end;

  for u in [1 .. m] do
    for v in [1 .. n] do
      next := next + 1;
      edges[next] := [];
      for w in OutNeighbours(D1)[u] do
        for x in OutNeighbours(D2)[v] do
          if (u = w) = (v = x) then
            Add(edges[next], map(w, x));
          fi;
        od;
      od;
      for w in OutNeighbours(E1)[u] do
        for x in OutNeighbours(E2)[v] do
          if (u = w) = (v = x) then
            Add(edges[next], map(w, x));
          fi;
        od;
      od;
    od;
  od;
  return DigraphNC(edges);
end);

###############################################################################
# 4. Actions
###############################################################################

InstallMethod(OnDigraphs, "for a mutable digraph by out-neighbours and a perm",
[IsMutableDigraph and IsDigraphByOutNeighboursRep, IsPerm],
function(D, p)
  local out;
  if ForAll(DigraphVertices(D), i -> i ^ p = i) then
    return D;
  elif ForAny(DigraphVertices(D), i -> i ^ p > DigraphNrVertices(D)) then
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
  if ForAll(DigraphVertices(D), i -> i ^ p = i) then
    return D;
  fi;
  return MakeImmutable(OnDigraphs(DigraphMutableCopy(D), p));
end);

InstallMethod(OnDigraphs,
"for a mutable digraph by out-neighbours and a transformation",
[IsMutableDigraph and IsDigraphByOutNeighboursRep, IsTransformation],
function(D, t)
  local old, new, v;
  if ForAll(DigraphVertices(D), i -> i ^ t = i) then
    return D;
  elif ForAny(DigraphVertices(D), i -> i ^ t > DigraphNrVertices(D)) then
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
  if ForAll(DigraphVertices(D), i -> i ^ t = i) then
    return D;
  fi;
  return MakeImmutable(OnDigraphs(DigraphMutableCopy(D), t));
end);

# Not revising the following because multi-digraphs are being withdrawn in the
# near future.

InstallMethod(OnMultiDigraphs, "for a digraph, perm and perm",
[IsDigraph, IsPerm, IsPerm],
{D, perm1, perm2} -> OnMultiDigraphs(D, [perm1, perm2]));

InstallMethod(OnMultiDigraphs, "for a digraph and perm coll",
[IsDigraph, IsPermCollection],
function(D, perms)
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
"for a mutable digraph by out-neighbours and a homogeneous list",
[IsDigraphByOutNeighboursRep and IsMutableDigraph, IsHomogeneousList],
function(D, list)
  local M, N, old, old_edl, new_edl, lookup, next, vv, w, old_labels, v, i;

  M := Length(list);
  N := DigraphNrVertices(D);
  if M = 0 then
    D!.OutNeighbours := [];
    return D;
  elif M = DigraphVertices(D) then
    return D;
  elif not IsDuplicateFree(list)
      or ForAny(list, x -> not IsPosInt(x) or x > N) then
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
  # Note that the following line means multidigraphs have wrong edge labels set.
  SetDigraphEdgeLabelsNC(D, new_edl);
  SetDigraphVertexLabels(D, old_labels{list});
  return D;
end);

InstallMethod(InducedSubdigraph,
"for an immutable digraph and a homogeneous list",
[IsImmutableDigraph, IsHomogeneousList],
function(D, list)
  if Length(list) = 0 then
    return EmptyDigraph(0);
  elif list = DigraphVertices(D) then
    return D;
  fi;
  return MakeImmutable(InducedSubdigraph(DigraphMutableCopy(D), list));
end);

InstallMethod(QuotientDigraph,
"for a mutable digraph by out-neighbours and a homogeneous list",
[IsDigraphByOutNeighboursRep and IsMutableDigraph, IsHomogeneousList],
function(D, partition)
  local N, M, check, lookup, new, new_vl, old, old_vl, x, i, u, v;

  N := DigraphNrVertices(D);
  M := Length(partition);
  if N = 0 then
    if IsEmpty(partition) then
      return D;
    fi;
    ErrorNoReturn("the 2nd argument <partition> should be an empty list, which",
                  " is the only valid partition of the vertices of 1st",
                  " argument <D> because it has no vertices,");
  elif M = 0 or not IsList(partition[1])
      or IsEmpty(partition[1]) or not IsPosInt(partition[1][1]) then
    ErrorNoReturn("the 2nd argument <partition> is not a valid ",
                  "partition of the vertices [1 .. ", N, "] of the 1st ",
                  "argument <D>,");
  fi;
  check := ListWithIdenticalEntries(DigraphNrVertices(D), false);
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
  if not ForAll(check, IdFunc) then
    ErrorNoReturn("the 2nd argument <partition> is not a valid ",
                  "partition of the vertices [1 .. ", N, "] of the 1st ",
                  "argument <D>,");
  fi;
  new    := List([1 .. M], x -> []);
  new_vl := List([1 .. M], x -> []);
  old    := D!.OutNeighbours;
  old_vl := DigraphVertexLabels(D);
  for u in DigraphVertices(D) do
    Add(new_vl[lookup[u]], old_vl[u]);
    for v in old[u] do
      AddSet(new[lookup[u]], lookup[v]);
    od;
  od;
  D!.OutNeighbours := new;
  SetDigraphVertexLabels(D, new_vl);
  ClearDigraphEdgeLabels(D);
  return D;
end);

InstallMethod(QuotientDigraph,
"for an immutable digraph and a homogeneous list",
[IsImmutableDigraph, IsHomogeneousList],
function(D, partition)
  return MakeImmutable(QuotientDigraph(DigraphMutableCopy(D), partition));
end);

#############################################################################
# 6. In and out degrees, neighbours, and edges of vertices
#############################################################################

InstallMethod(InNeighboursOfVertex, "for a digraph and a positive integer",
[IsDigraph, IsPosInt],
function(D, v)
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> is not a vertex of the ",
                  "1st argument <D>,");
  fi;
  return InNeighboursOfVertexNC(D, v);
end);

InstallMethod(InNeighboursOfVertexNC,
"for a digraph with in-neighbours and a positive integer",
[IsDigraph and HasInNeighbours, IsPosInt],
2,  # to beat the next method for IsDigraphByOutNeighboursRep
{D, v} -> InNeighbours(D)[v]);

InstallMethod(InNeighboursOfVertexNC,
"for a digraph by out-neighbours and a positive integer",
[IsDigraphByOutNeighboursRep, IsPosInt],
function(D, v)
  local inn, out, i, j;

  inn := [];
  out := OutNeighbours(D);
  for i in [1 .. Length(out)] do
    for j in [1 .. Length(out[i])] do
      if out[i][j] = v then
        Add(inn, i);
      fi;
    od;
  od;
  return inn;
end);

InstallMethod(OutNeighboursOfVertex,
"for a digraph by out-neighbours and a positive integer",
[IsDigraphByOutNeighboursRep, IsPosInt],
function(D, v)
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> is not a vertex of the ",
                  "1st argument <D>,");
  fi;
  return OutNeighboursOfVertexNC(D, v);
end);

InstallMethod(OutNeighboursOfVertexNC,
"for a digraph by out-neighbours and a positive integer",
[IsDigraphByOutNeighboursRep, IsPosInt],
{D, v} -> OutNeighbours(D)[v]);

InstallMethod(InDegreeOfVertex, "for a digraph and a positive integer",
[IsDigraph, IsPosInt],
function(D, v)
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> is not a vertex of the ",
                  "1st argument <D>,");
  fi;
  return InDegreeOfVertexNC(D, v);
end);

InstallMethod(InDegreeOfVertexNC,
"for a digraph with in-degrees and a positive integer",
[IsDigraph and HasInDegrees, IsPosInt], 4,
{D, v} -> InDegrees(D)[v]);

InstallMethod(InDegreeOfVertexNC,
"for a digraph with in-neighbours and a positive integer",
[IsDigraph and HasInNeighbours, IsPosInt],
2,  # to beat the next method for IsDigraphByOutNeighboursRep
{D, v} -> Length(InNeighbours(D)[v]));

InstallMethod(InDegreeOfVertexNC, "for a digraph and a positive integer",
[IsDigraphByOutNeighboursRep, IsPosInt],
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

InstallMethod(OutDegreeOfVertex, "for a digraph and a positive integer",
[IsDigraph, IsPosInt],
function(D, v)
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> is not a vertex of the ",
                  "1st argument <D>,");
  fi;
  return OutDegreeOfVertexNC(D, v);
end);

InstallMethod(OutDegreeOfVertexNC,
"for a digraph with out-degrees and a positive integer",
[IsDigraph and HasOutDegrees, IsPosInt],
2,  # to beat the next method for IsDigraphByOutNeighboursRep
{D, v} -> OutDegrees(D)[v]);

InstallMethod(OutDegreeOfVertexNC,
"for a digraph by out-neighbours and a positive integer",
[IsDigraphByOutNeighboursRep, IsPosInt],
{D, v} -> Length(OutNeighbours(D)[v]));

InstallMethod(DigraphOutEdges,
"for a digraph by out-neighbours and a positive integer",
[IsDigraphByOutNeighboursRep, IsPosInt],
function(D, v)
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> is not a vertex of the ",
                  "1st argument <D>,");
  fi;
  return List(OutNeighboursOfVertex(D, v), x -> [v, x]);
end);

InstallMethod(DigraphInEdges, "for a digraph and a positive integer",
[IsDigraph, IsPosInt],
function(D, v)
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> is not a vertex of the ",
                  "1st argument <D>,");
  fi;
  return List(InNeighboursOfVertex(D, v), x -> [x, v]);
end);

#############################################################################
# 7. Copies of out/in-neighbours
#############################################################################

InstallMethod(OutNeighboursMutableCopy, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
D -> List(OutNeighbours(D), ShallowCopy));

InstallMethod(InNeighboursMutableCopy, "for a digraph", [IsDigraph],
D -> List(InNeighbours(D), ShallowCopy));

InstallMethod(AdjacencyMatrixMutableCopy, "for a digraph", [IsDigraph],
D -> List(AdjacencyMatrix(D), ShallowCopy));

InstallMethod(BooleanAdjacencyMatrixMutableCopy, "for a digraph", [IsDigraph],
D -> List(BooleanAdjacencyMatrix(D), ShallowCopy));

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

InstallMethod(IsDigraphEdge, "for a digraph by out-neighbours, int, int",
[IsDigraphByOutNeighboursRep, IsInt, IsInt],
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

InstallMethod(IsSubdigraph,
"for two digraphs by out-neighbours",
[IsDigraphByOutNeighboursRep, IsDigraphByOutNeighboursRep],
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

InstallMethod(IsUndirectedSpanningForest, "for two digraphs",
[IsDigraph, IsDigraph],
function(super, sub)
  local sym, comps1, comps2;

  if not IsUndirectedForest(sub) then
    return false;
  fi;

  sym := MaximalSymmetricSubdigraph(DigraphMutableCopyIfMutable(super));

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
  super := DigraphMutableCopyIfMutable(super);
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
{D, edges} -> DIGRAPHS_Matching(D, edges) <> false);

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

InstallMethod(IsMaximumMatching, "for a digraph and a list",
[IsDigraph, IsHomogeneousList],
function(D, edges)
  return IsMatching(D, edges)
          and Length(edges) = Length(DigraphMaximumMatching(D));
end);

InstallMethod(IsMaximalMatching, "for a digraph and a list",
[IsDigraphByOutNeighboursRep, IsHomogeneousList],
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
"for a digraph by out-neighbours, function, object, and object",
[IsDigraphByOutNeighboursRep, IsFunction, IsObject, IsObject],
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

InstallMethod(DigraphStronglyConnectedComponent,
"for a digraph and a positive integer",
[IsDigraph, IsPosInt],
function(D, v)
  local scc;
  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> is not a vertex of the ",
                  "1st argument <D>,");
  fi;

  # TODO check if strongly connected components are known and use them if they
  # are and don't use them if they are not.
  scc := DigraphStronglyConnectedComponents(D);
  return scc.comps[scc.id[v]];
end);

InstallMethod(DigraphConnectedComponent, "for a digraph and a positive integer",
[IsDigraph, IsPosInt],
function(D, v)
  local wcc;
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

  verts := DigraphVertices(D);
  if not (u in verts and v in verts) then
    ErrorNoReturn("the 2nd and 3rd arguments <u> and <v> must be ",
                  "vertices of the 1st argument <D>,");
  elif IsDigraphEdge(D, u, v) then
    return true;
  elif HasDigraphStronglyConnectedComponents(D) then
    # Glean information from SCC if we have it
    scc := DigraphStronglyConnectedComponents(D);
    return (u <> v and scc.id[u] = scc.id[v])
        or (u = v and Length(scc.comps[scc.id[u]]) > 1);
  fi;
  return DigraphPath(D, u, v) <> fail;
end);

InstallMethod(DigraphPath, "for a digraph by out-neighbours and two pos ints",
[IsDigraphByOutNeighboursRep, IsPosInt, IsPosInt],
function(D, u, v)
  local verts;

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

InstallMethod(DigraphShortestPath,
"for a digraph by out-neighbours and two pos ints",
[IsDigraphByOutNeighboursRep, IsPosInt, IsPosInt],
function(D, u, v)
  local current, next, parent, distance, falselist, verts, nbs, path, edge,
  n, a, b, i;

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
            Add(path[1], u);  # Adds the starting vertex to the list of vertices
            return [Reversed(path[1]), Reversed(path[2])];
          fi;
        od;
      od;
      current := ListBlist(verts, next);
      IntersectBlist(next, falselist);
    od;
    return fail;
end);

BindGlobal("DIGRAPHS_DijkstraST",
function(digraph, source, target)
  local dist, prev, queue, u, v, alt;

  if not source in DigraphVertices(digraph) then
    ErrorNoReturn("the 2nd argument <source> must be a vertex of the ",
                  "1st argument <digraph>");
  elif target <> fail and not target in DigraphVertices(digraph) then
    ErrorNoReturn("the 3rd argument <target> must be a vertex of the ",
                  "1st argument <digraph>");
  fi;

  dist := [];
  prev := [];
  queue := BinaryHeap({x, y} -> x[1] < y[1]);

  for v in DigraphVertices(digraph) do
    dist[v] := infinity;
    prev[v] := -1;
  od;

  dist[source] := 0;
  Push(queue, [0, source]);

  while not IsEmpty(queue) do
    u := Pop(queue);
    u := u[2];
    # TODO: this has a small performance impact for DigraphDijkstraS,
    #       but do we care?
    if u = target then
      return [dist, prev];
    fi;
    for v in OutNeighbours(digraph)[u] do
      alt := dist[u] + DigraphEdgeLabel(digraph, u, v);
      if alt < dist[v] then
        dist[v] := alt;
        prev[v] := u;
        Push(queue, [dist[v], v]);
      fi;
    od;
  od;
  return [dist, prev];
end);

InstallMethod(DigraphDijkstra, "for a digraph, a vertex, and a vertex",
[IsDigraph, IsPosInt, IsPosInt], DIGRAPHS_DijkstraST);

InstallMethod(DigraphDijkstra, "for a digraph, and a vertex",
[IsDigraph, IsPosInt],
{digraph, source} -> DIGRAPHS_DijkstraST(digraph, source, fail));

InstallMethod(IteratorOfPaths,
"for a digraph by out-neighbours and two pos ints",
[IsDigraphByOutNeighboursRep, IsPosInt, IsPosInt],
function(D, u, v)
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
  # can assume that n > 0 since u and v are extant vertices of digraph
  Assert(1, n > 0);

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
[IsDigraphByOutNeighboursRep, IsPosInt],
function(D, v)
  local dist;

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

InstallMethod(DigraphLayers, "for a digraph, and a positive integer",
[IsDigraph, IsPosInt],
function(D, v)
  local layers, gens, sch, trace, rep, word, orbs, layers_with_orbnums,
        layers_of_v, i, x;

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
D -> EmptyPlist(0));

InstallMethod(DigraphDistanceSet,
"for a digraph, a vertex, and a non-negative integers",
[IsDigraph, IsPosInt, IsInt],
function(D, vertex, distance)
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
"for a digraph, a vertex, and a positive integer",
[IsDigraph, IsPosInt, IsPosInt],
function(D, u, v)
  local dist;

  if u > DigraphNrVertices(D) or v > DigraphNrVertices(D) then
    ErrorNoReturn("the 2nd and 3rd arguments <u> and <v> must be ",
                  "vertices of the 1st argument <D>,");
  fi;

  if HasDigraphShortestDistances(D) then
    return DigraphShortestDistances(D)[u][v];
  elif u = v then
    return 0;
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
  if not IsEmpty(Intersection(list1, list2)) then
    return 0;
  fi;
  for u in list1 do
    for v in list2 do
      if shortest > DigraphShortestDistance(D, u, v) then
        shortest := DigraphShortestDistance(D, u, v);
        if shortest = 1 then
          return 1;
        fi;
      fi;
    od;
  od;
  return shortest;
end);

InstallMethod(DigraphShortestDistance, "for a digraph, and a list",
[IsDigraph, IsList],
function(D, list)

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

InstallMethod(DigraphShortestPathSpanningTree,
"for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(D, v)
  local record, diam, tree, nbs, edgelabels, spanningtree, layers,
        layernumbers, nradjacencies, localparameters, adjnrs, data, i, k;

  if not v in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument <v> must be a vertex of the digraph <D>");
  fi;
  record := DIGRAPH_ConnectivityDataForVertex(D, v);
  diam := record.localDiameter;
  if diam = -1 then
    return fail;
  fi;

  # Construct out-neighbours of spanningtree
  tree := record.spstree;
  nbs := List(DigraphVertices(D), x -> []);
  for i in DigraphVertices(D) do
    if i <> v then
      Add(nbs[tree[i]], i);
    fi;
  od;

  # Create spanningtree according to mutability, retaining vertex labels
  if IsMutableDigraph(D) then
    spanningtree := D;
    spanningtree!.OutNeighbours := nbs;
  else
    spanningtree := Digraph(IsImmutableDigraph, nbs);
    SetDigraphVertexLabels(spanningtree, DigraphVertexLabels(D));
  fi;

  # Retain edge labels if appropriate
  if HaveEdgeLabelsBeenAssigned(D) then
    edgelabels := List(DigraphVertices(D), x -> []);
    for i in DigraphVertices(D) do
      for k in [1 .. Length(nbs[i])] do
        edgelabels[i][k] := DigraphEdgeLabel(D, i, nbs[i][k]);
      od;
    od;
    SetDigraphEdgeLabelsNC(spanningtree, edgelabels);
  fi;

  if IsMutableDigraph(spanningtree) then
    return spanningtree;
  fi;

  # JDB: we know almost all local parameters, except the b_i, 0 < i < diameter.
  # Note that for a spanningtree, all c_i and a_i are zero.
  # b_0 will be the number of out-neighbours of v, which is the sameas before.
  # b_d is of course zero.

  # first reconstruct the layers from record.layernumbers.
  layers := List([1 .. diam + 1], x -> []);
  layernumbers := ShallowCopy(record.layerNumbers);
  for i in [1 .. Length(layernumbers)] do
    Add(layers[layernumbers[i]], i);
  od;

  # now compute for each vertex v the number of vertices adjacent with v in the
  # next layer, using spstree.
  nradjacencies := ListWithIdenticalEntries(DigraphNrVertices(D), 0);
  for i in DigraphVertices(D) do
    if i <> v then
      nradjacencies[tree[i]] := nradjacencies[tree[i]] + 1;
    fi;
  od;

  # now we are ready to compute the local parameters b_i of the spanning tree
  localparameters := ShallowCopy(record.localParameters);
  for i in [1 .. diam + 1] do
    localparameters[i]{[1, 2]} := [0, 0];
  od;
  for i in [2 .. diam] do
    adjnrs := Set(nradjacencies{layers[i]});
    if Length(adjnrs) > 1 then
      localparameters[i][3] := -1;
    else
      localparameters[i][3] := adjnrs[1];
    fi;
  od;

  data := DIGRAPHS_ConnectivityData(spanningtree);
  data[v] := rec(layerNumbers    := layernumbers,
                 layers          := layers,
                 localDiameter   := record.localDiameter,
                 localGirth      := -1,
                 localParameters := localparameters,
                 spstree         := ShallowCopy(tree));

  SetIsDirectedTree(spanningtree, true);
  SetDigraphSources(spanningtree, [v]);
  return spanningtree;
end);

InstallMethod(VerticesReachableFrom, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(D, root)
  local N, index, current, succ, visited, prev, n, i, parent,
  have_visited_root;
  N := DigraphNrVertices(D);
  if 0 = root or root > N then
    ErrorNoReturn("the 2nd argument (root) is not a vertex of the 1st ",
                  "argument (a digraph)");
  fi;
  index := ListWithIdenticalEntries(N, 0);
  have_visited_root := false;
  index[root] := 1;
  current := root;
  succ := OutNeighbours(D);
  visited := [];
  parent := [];
  parent[root] := fail;
  repeat
    prev := current;
    for i in [index[current] .. Length(succ[current])] do
      n := succ[current][i];
      if n = root and not have_visited_root then
         Add(visited, root);
         have_visited_root := true;
      elif index[n] = 0 then
        Add(visited, n);
          parent[n] := current;
          index[current] := i + 1;
          current := n;
          index[current] := 1;
          break;
      fi;
    od;
    if prev = current then
      current := parent[current];
    fi;
  until current = fail;
  return visited;
end);

InstallMethod(DominatorTree, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(D, root)
  local M, node_to_preorder_num, preorder_num_to_node, parent, index, next,
  current, succ, prev, n, semi, lastlinked, label, bucket, idom,
  compress, eval, pred, N, w, y, x, i, v;
  M := DigraphNrVertices(D);

  if 0 = root or root > M then
    ErrorNoReturn("the 2nd argument (root) is not a vertex of the 1st ",
                  "argument (a digraph)");
  fi;

  node_to_preorder_num := [];
  node_to_preorder_num[root] := 1;
  preorder_num_to_node := [root];

  parent := [];
  parent[root] := fail;

  index := ListWithIdenticalEntries(M, 1);

  next := 2;
  current := root;
  succ := OutNeighbours(D);
  repeat
    prev := current;
    for i in [index[current] .. Length(succ[current])] do
      n := succ[current][i];
      if not IsBound(node_to_preorder_num[n]) then
        Add(preorder_num_to_node, n);
        parent[n] := current;
        index[current] := i + 1;
        node_to_preorder_num[n] := next;
        next := next + 1;
        current := n;
        break;
      fi;
    od;
    if prev = current then
      current := parent[current];
    fi;
  until current = fail;
  semi := [1 .. M];
  lastlinked := M + 1;
  label := [];
  bucket := List([1 .. M], x -> []);
  idom := [];
  idom[root] := root;

  compress := function(v)
    local u;
    u := parent[v];
    if u <> fail and lastlinked <= M and node_to_preorder_num[u] >=
        node_to_preorder_num[lastlinked] then
      compress(u);
      if node_to_preorder_num[semi[label[u]]]
          < node_to_preorder_num[semi[label[v]]] then
        label[v] := label[u];
      fi;
      parent[v] := parent[u];
    fi;
  end;

  eval := function(v)
    if lastlinked <= M and node_to_preorder_num[v] >=
        node_to_preorder_num[lastlinked] then
      compress(v);
      return label[v];
    else
      return v;
    fi;
  end;

  pred := InNeighbours(D);
  N := Length(preorder_num_to_node);
  for i in [N, N - 1 .. 2] do
    w := preorder_num_to_node[i];
    for v in bucket[w] do
      y := eval(v);
      if node_to_preorder_num[semi[y]] < node_to_preorder_num[w] then
        idom[v] := y;
      else
        idom[v] := w;
      fi;
    od;
    bucket[w] := [];
    for v in pred[w] do
      if IsBound(node_to_preorder_num[v]) then
        x := eval(v);
        if node_to_preorder_num[semi[x]] < node_to_preorder_num[semi[w]] then
          semi[w] := semi[x];
        fi;
      fi;
    od;
    if parent[w] = semi[w] then
      idom[w] := parent[w];
    else
      Add(bucket[semi[w]], w);
    fi;
    lastlinked := w;
    label[w] := semi[w];
  od;
  for v in bucket[root] do
    idom[v] := root;
  od;
  for i in [2 .. N] do
    w := preorder_num_to_node[i];
    if idom[w] <> semi[w] then
      idom[w] := idom[semi[w]];
    fi;
  od;
  idom[root] := fail;
  return rec(idom := idom, preorder := preorder_num_to_node);
end);

InstallMethod(Dominators, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(D, root)
  local tree, preorder, result, u, v;
  if not root in DigraphVertices(D) then
    ErrorNoReturn("the 2nd argument (a pos. int.) is not a vertex of ",
                  "the 1st argument (a digraph)");
  fi;
  tree := DominatorTree(D, root);
  preorder := tree.preorder;
  tree := tree.idom;
  result := [];
  for v in preorder do
    u := tree[v];
    if u <> fail then
      result[v] := [u];
      if IsBound(result[u]) then
        Append(result[v], result[u]);
      fi;
    fi;
  od;
  return result;
end);

#############################################################################
# 10. Operations for vertices
#############################################################################

InstallMethod(PartialOrderDigraphJoinOfVertices,
"for a digraph by out-neighbours and two positive integers",
[IsDigraphByOutNeighboursRep, IsPosInt, IsPosInt],
function(D, i, j)
  local x, nbs, intr;

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
