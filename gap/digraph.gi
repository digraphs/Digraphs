#############################################################################
##
##  digraph.gi
##  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

########################################################################
# This file is organised as follows:
#
# 1.  Types
# 2.  Digraph no-check constructors
# 3.  Digraph copies
# 4.  MakeImmutableDigraph
# 5.  Digraph constructors
# 6.  Printing, viewing, strings
# 7.  Operators
# 8.  Digraph by-something constructors
# 9.  Converters to/from other types -> digraph
# 10. Random digraphs
#
########################################################################

########################################################################
# 1. Digraph types
########################################################################

BindGlobal("DenseDigraphType", NewType(DigraphFamily,
                                       IsDenseDigraphRep));

########################################################################
# 2. Digraph no-check constructors
########################################################################

InstallMethod(ConvertToMutableDigraphNC, "for a record", [IsRecord],
function(record)
  local D;
  Assert(1, IsBound(record.OutNeighbours));
  Assert(1, Length(NamesOfComponents(record)) = 1);
  D := Objectify(DenseDigraphType, record);
  SetFilterObj(D, IsMutable);
  return D;
end);

InstallMethod(ConvertToMutableDigraphNC, "for a dense list of out-neighbours",
[IsDenseList],
function(list)
  local record;
  record := rec(OutNeighbours := list);
  Perform(record.OutNeighbours, IsSet);
  return ConvertToMutableDigraphNC(record);
end);

InstallMethod(ConvertToImmutableDigraphNC,
"for a dense list of out-neighbours",
[IsDenseList],
function(list)
  return MakeImmutableDigraph(ConvertToMutableDigraphNC(list));
end);

InstallMethod(ConvertToImmutableDigraphNC,
"for a dense list of out-neighbours",
[IsRecord],
function(record)
  return MakeImmutableDigraph(ConvertToMutableDigraphNC(record));
end);

InstallMethod(MutableDigraphNC, "for a dense mutable list of out-neighbours",
[IsDenseList and IsMutable],
function(list)
  return ConvertToMutableDigraphNC(StructuralCopy(list));
end);

InstallMethod(MutableDigraphNC, "for a dense list of out-neighbours",
[IsDenseList],
function(list)
  Assert(1, not IsMutable(list));
  return ConvertToMutableDigraphNC(List(list, ShallowCopy));
end);

InstallMethod(MutableDigraphNC, "for a record", [IsRecord],
function(record)
  local out;
  Assert(1, IsBound(record.DigraphNrVertices));
  Assert(1, IsBound(record.DigraphRange));
  Assert(1, IsBound(record.DigraphSource));
  out := DIGRAPH_OUT_NEIGHBOURS_FROM_SOURCE_RANGE(record.DigraphNrVertices,
                                                  record.DigraphSource,
                                                  record.DigraphRange);
  return ConvertToMutableDigraphNC(out);
end);

InstallMethod(DigraphNC, "for a record", [IsRecord],
function(record)
  local D, nm;
  Assert(1, IsBound(record.DigraphNrVertices));
  Assert(1, IsBound(record.DigraphRange));
  Assert(1, IsBound(record.DigraphSource));
  for nm in RecNames(record) do
    if not nm in ["DigraphRange", "DigraphSource", "DigraphNrVertices"] then
      Info(InfoWarning, 1, "ignoring record component \"", nm, "\"!");
    fi;
  od;
  D := MakeImmutableDigraph(MutableDigraphNC(record));
  SetDigraphSource(D, StructuralCopy(record.DigraphSource));
  SetDigraphRange(D, StructuralCopy(record.DigraphRange));
  return D;
end);

InstallMethod(DigraphNC, "for a dense list of adjacencies", [IsDenseList],
function(list)
  return MakeImmutableDigraph(MutableDigraphNC(list));
end);

########################################################################
# 3. Digraph copies
########################################################################

InstallMethod(DigraphCopy, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local copy;
  copy := ConvertToImmutableDigraphNC(OutNeighboursMutableCopy(D));
  SetDigraphVertexLabels(copy, StructuralCopy(DigraphVertexLabels(D)));
  SetDigraphEdgeLabelsNC(copy, StructuralCopy(DigraphEdgeLabelsNC(D)));
  return copy;
end);

InstallMethod(DigraphMutableCopy, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local copy;
  copy := ConvertToMutableDigraphNC(OutNeighboursMutableCopy(D));
  SetDigraphVertexLabels(copy, StructuralCopy(DigraphVertexLabels(D)));
  SetDigraphEdgeLabelsNC(copy, StructuralCopy(DigraphEdgeLabelsNC(D)));
  return copy;
end);

InstallMethod(DigraphCopyIfMutable, "for a mutable digraph",
[IsMutableDigraph], DigraphMutableCopy);

InstallMethod(DigraphCopyIfMutable, "for an immutable digraph",
[IsImmutableDigraph], IdFunc);

########################################################################
# 4. MakeImmutableDigraph
########################################################################

InstallMethod(MakeImmutableDigraph, "for a mutable dense digraph",
[IsMutableDigraph and IsDenseDigraphRep],
function(D)
  MakeImmutable(D);
  SetFilterObj(D, IsAttributeStoringRep);
  SetFilterObj(D, IsImmutableDigraph);
  MakeImmutable(OutNeighbours(D));
  return D;
end);

########################################################################
# 5. Digraph constructors
########################################################################

InstallMethod(MutableDigraph, "for a record", [IsRecord],
function(record)
  local D, cmp, labels, i;

  if IsGraph(record) then
    # IsGraph is a function not a filter, so we cannot have a separate method
    D := MutableDigraphNC(List(Vertices(record), x -> Adjacency(record, x)));
    if IsBound(record.names) then
      SetDigraphVertexLabels(D, StructuralCopy(record.names));
    fi;
    return D;
  fi;

  if not (IsBound(record.DigraphSource)
          and IsBound(record.DigraphRange)
          and (IsBound(record.DigraphVertices) or
               IsBound(record.DigraphNrVertices))) then
    ErrorNoReturn("the argument <record> must be a record with components ",
                  "'DigraphSource', 'DigraphRange', and either ",
                  "'DigraphVertices' or 'DigraphNrVertices' (but not both),");
  elif not IsList(record.DigraphSource)
      or not IsList(record.DigraphRange) then
    ErrorNoReturn("the record components 'DigraphSource' and 'DigraphRange' ",
                  "must be lists,");
  elif Length(record.DigraphSource) <> Length(record.DigraphRange) then
    ErrorNoReturn("the record components 'DigraphSource' and 'DigraphRange' ",
                  "must have equal length,");
  elif IsBound(record.DigraphVertices)
      and IsBound(record.DigraphNrVertices) then
    ErrorNoReturn("the record must only have one of the components ",
                  "'DigraphVertices' and 'DigraphNrVertices', not both,");
  fi;

  if IsBound(record.DigraphNrVertices) then
    if (not IsInt(record.DigraphNrVertices))
        or record.DigraphNrVertices < 0 then
      ErrorNoReturn("the record component 'DigraphNrVertices' ",
                    "must be a non-negative integer,");
    fi;
    cmp := x -> x < record.DigraphNrVertices + 1 and x > 0;
  else
    Assert(1, IsBound(record.DigraphVertices));
    if not IsList(record.DigraphVertices) then
      ErrorNoReturn("the record component 'DigraphVertices' must be a list,");
    elif not IsDuplicateFreeList(record.DigraphVertices) then
      ErrorNoReturn("the record component 'DigraphVertices' must be ",
                    "duplicate-free,");
    fi;
    cmp := x -> x in record.DigraphVertices;
    record.DigraphNrVertices := Length(record.DigraphVertices);
  fi;

  if not ForAll(record.DigraphSource, x -> cmp(x)) then
    ErrorNoReturn("the record component 'DigraphSource' is invalid,");
  elif not ForAll(record.DigraphRange, x -> cmp(x)) then
    ErrorNoReturn("the record component 'DigraphRange' is invalid,");
  fi;

  record := StructuralCopy(record);

  # Rewrite the vertices to numbers
  if IsBound(record.DigraphVertices) then
    if record.DigraphVertices <> [1 .. record.DigraphNrVertices] then
      for i in [1 .. Length(record.DigraphSource)] do
        record.DigraphRange[i]  := Position(record.DigraphVertices,
                                            record.DigraphRange[i]);
        record.DigraphSource[i] := Position(record.DigraphVertices,
                                            record.DigraphSource[i]);
      od;
      labels := record.DigraphVertices;
      Unbind(record.DigraphVertices);
    fi;
  fi;

  record.DigraphRange := Permuted(record.DigraphRange,
                                  Sortex(record.DigraphSource));
  D := MutableDigraphNC(record);
  if IsBound(labels) then
    SetDigraphVertexLabels(D, labels);
  fi;
end);

InstallMethod(ConvertToImmutableDigraphNC,
"for a dense list of out-neighbours",
[IsRecord],
function(record)
  return MakeImmutableDigraph(ConvertToMutableDigraphNC(record));
end);

InstallMethod(MutableDigraphNC, "for a dense mutable list of out-neighbours",
[IsDenseList and IsMutable],
function(list)
  return ConvertToMutableDigraphNC(StructuralCopy(list));
end);

InstallMethod(MutableDigraphNC, "for a dense list of out-neighbours",
[IsDenseList],
function(list)
  Assert(1, not IsMutable(list));
  return ConvertToMutableDigraphNC(List(list, ShallowCopy));
end);

InstallMethod(MutableDigraphNC, "for a record", [IsRecord],
function(record)
  local out;
  Assert(1, IsBound(record.DigraphNrVertices));
  Assert(1, IsBound(record.DigraphRange));
  Assert(1, IsBound(record.DigraphSource));
  out := DIGRAPH_OUT_NEIGHBOURS_FROM_SOURCE_RANGE(record.DigraphNrVertices,
                                                  record.DigraphSource,
                                                  record.DigraphRange);
  return ConvertToMutableDigraphNC(out);
end);

InstallMethod(DigraphNC, "for a record", [IsRecord],
function(record)
  local D, nm;
  Assert(1, IsBound(record.DigraphNrVertices));
  Assert(1, IsBound(record.DigraphRange));
  Assert(1, IsBound(record.DigraphSource));
  for nm in RecNames(record) do
    if not nm in ["DigraphRange", "DigraphSource", "DigraphNrVertices"] then
      Info(InfoWarning, 1, "ignoring record component \"", nm, "\"!");
    fi;
  od;
  D := MakeImmutableDigraph(MutableDigraphNC(record));
  SetDigraphSource(D, StructuralCopy(record.DigraphSource));
  SetDigraphRange(D, StructuralCopy(record.DigraphRange));
  return D;
end);

InstallMethod(DigraphNC, "for a dense list of adjacencies", [IsDenseList],
function(list)
  return MakeImmutableDigraph(MutableDigraphNC(list));
end);

########################################################################
# 3. Digraph copies
########################################################################

InstallMethod(DigraphCopy, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local copy;
  copy := ConvertToImmutableDigraphNC(OutNeighboursMutableCopy(D));
  SetDigraphVertexLabels(copy, StructuralCopy(DigraphVertexLabels(D)));
  SetDigraphEdgeLabelsNC(copy, StructuralCopy(DigraphEdgeLabelsNC(D)));
  return copy;
end);

InstallMethod(DigraphMutableCopy, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local copy;
  copy := ConvertToMutableDigraphNC(OutNeighboursMutableCopy(D));
  SetDigraphVertexLabels(copy, StructuralCopy(DigraphVertexLabels(D)));
  SetDigraphEdgeLabelsNC(copy, StructuralCopy(DigraphEdgeLabelsNC(D)));
  return copy;
end);

InstallMethod(DigraphCopyIfMutable, "for a mutable digraph",
[IsMutableDigraph], DigraphMutableCopy);

InstallMethod(DigraphCopyIfMutable, "for an immutable digraph",
[IsImmutableDigraph], IdFunc);

InstallMethod(DigraphCopyIfImmutable, "for a mutable digraph",
[IsMutableDigraph], IdFunc);

InstallMethod(DigraphCopyIfImmutable, "for an immutable digraph",
[IsImmutableDigraph], DigraphMutableCopy);

########################################################################
# 4. MakeImmutableDigraph
########################################################################

InstallMethod(MakeImmutableDigraph, "for a mutable dense digraph",
[IsMutableDigraph and IsDenseDigraphRep],
function(D)
  MakeImmutable(D);
  SetFilterObj(D, IsAttributeStoringRep);
  SetFilterObj(D, IsImmutableDigraph);
  MakeImmutable(OutNeighbours(D));
  return D;
end);

########################################################################
# 5. Digraph constructors
########################################################################

InstallMethod(MutableDigraph, "for a record", [IsRecord],
function(record)
  local D, cmp, labels, i;

  if IsGraph(record) then
    # IsGraph is a function not a filter, so we cannot have a separate method
    D := MutableDigraphNC(List(Vertices(record), x -> Adjacency(record, x)));
    if IsBound(record.names) then
      SetDigraphVertexLabels(D, StructuralCopy(record.names));
    fi;
    return D;
  fi;

  if not (IsBound(record.DigraphSource)
          and IsBound(record.DigraphRange)
          and (IsBound(record.DigraphVertices) or
               IsBound(record.DigraphNrVertices))) then
    ErrorNoReturn("the argument <record> must be a record with components ",
                  "'DigraphSource', 'DigraphRange', and either ",
                  "'DigraphVertices' or 'DigraphNrVertices' (but not both),");
  elif not IsList(record.DigraphSource)
      or not IsList(record.DigraphRange) then
    ErrorNoReturn("the record components 'DigraphSource' and 'DigraphRange' ",
                  "must be lists,");
  elif Length(record.DigraphSource) <> Length(record.DigraphRange) then
    ErrorNoReturn("the record components 'DigraphSource' and 'DigraphRange' ",
                  "must have equal length,");
  elif IsBound(record.DigraphVertices)
      and IsBound(record.DigraphNrVertices) then
    ErrorNoReturn("the record must only have one of the components ",
                  "'DigraphVertices' and 'DigraphNrVertices', not both,");
  fi;

  if IsBound(record.DigraphNrVertices) then
    if (not IsInt(record.DigraphNrVertices))
        or record.DigraphNrVertices < 0 then
      ErrorNoReturn("the record component 'DigraphNrVertices' ",
                    "must be a non-negative integer,");
    fi;
    cmp := x -> x < record.DigraphNrVertices + 1 and x > 0;
  else
    Assert(1, IsBound(record.DigraphVertices));
    if not IsList(record.DigraphVertices) then
      ErrorNoReturn("the record component 'DigraphVertices' must be a list,");
    elif not IsDuplicateFreeList(record.DigraphVertices) then
      ErrorNoReturn("the record component 'DigraphVertices' must be ",
                    "duplicate-free,");
    fi;
    cmp := x -> x in record.DigraphVertices;
    record.DigraphNrVertices := Length(record.DigraphVertices);
  fi;

  if not ForAll(record.DigraphSource, x -> cmp(x)) then
    ErrorNoReturn("the record component 'DigraphSource' is invalid,");
  elif not ForAll(record.DigraphRange, x -> cmp(x)) then
    ErrorNoReturn("the record component 'DigraphRange' is invalid,");
  fi;

  record := StructuralCopy(record);

  # Rewrite the vertices to numbers
  if IsBound(record.DigraphVertices) then
    if record.DigraphVertices <> [1 .. record.DigraphNrVertices] then
      for i in [1 .. Length(record.DigraphSource)] do
        record.DigraphRange[i]  := Position(record.DigraphVertices,
                                            record.DigraphRange[i]);
        record.DigraphSource[i] := Position(record.DigraphVertices,
                                            record.DigraphSource[i]);
      od;
      labels := record.DigraphVertices;
      Unbind(record.DigraphVertices);
    fi;
  fi;

  record.DigraphRange := Permuted(record.DigraphRange,
                                  Sortex(record.DigraphSource));
  D := MutableDigraphNC(record);
  if IsBound(labels) then
    SetDigraphVertexLabels(D, labels);
  fi;
  return D;
end);

InstallMethod(Digraph, "for a record", [IsRecord],
function(record)
  local D;
  D := MakeImmutableDigraph(MutableDigraph(record));
  if IsGraph(record) then
    # IsGraph is a function not a filter, so we cannot have a separate method
    # for this.
    if not IsTrivial(record.group) then
      Assert(1, IsPermGroup(record.group));
      SetDigraphGroup(D, record.group);
      SetDigraphSchreierVector(D, record.schreierVector);
      SetRepresentativeOutNeighbours(D, record.adjacencies);
    fi;
  else
    SetDigraphNrEdges(D, Length(record.DigraphSource));
  fi;
  return D;
end);

InstallMethod(MutableDigraph, "for a dense list of out-neighbours",
[IsDenseList],
function(list)
  local sublist, v;
  for sublist in list do
    if not IsHomogeneousList(sublist) then
      ErrorNoReturn("the argument must be a list of lists of positive ",
                    "integers not exceeding the length of the argument,");
    fi;
    for v in sublist do
      if not IsPosInt(v) or v > Length(list) then
        ErrorNoReturn("the argument must be a list of lists of positive ",
                      "integers not exceeding the length of the argument,");
      fi;
    od;
  od;
  return MutableDigraphNC(list);
end);

InstallMethod(Digraph, "for a dense list of out-neighbours", [IsDenseList],
function(list)
  return MakeImmutableDigraph(MutableDigraph(list));
end);

InstallMethod(Digraph, "for a list and function", [IsList, IsFunction],
function(list, func)
  local D;
  D := MakeImmutableDigraph(MutableDigraph(list, func));
  SetDigraphAdjacencyFunction(D, {u, v} -> func(list[u], list[v]));
  SetFilterObj(D, IsDigraphWithAdjacencyFunction);
  SetDigraphVertexLabels(D, list);
  return D;
end);

InstallMethod(MutableDigraph, "for a list and function", [IsList, IsFunction],
function(list, func)
  local N, out, x, i, j;
  N    := Size(list);  # number of vertices
  out := List([1 .. N], x -> []);
  for i in [1 .. N] do
    x := list[i];
    for j in [1 .. N] do
      if func(x, list[j]) then
        Add(out[i], j);
      fi;
    od;
  od;
  return ConvertToMutableDigraphNC(out);
end);

InstallMethod(MutableDigraph, "for a number of vertices, source, and range",
[IsInt, IsHomogeneousList, IsHomogeneousList],
function(N, src, ran)
  return MutableDigraph(rec(DigraphNrVertices := N,
                            DigraphSource     := src,
                            DigraphRange      := ran));
end);

InstallMethod(Digraph, "for a number of vertices, source, and range",
[IsInt, IsHomogeneousList, IsHomogeneousList],
function(N, src, ran)
  return MakeImmutableDigraph(MutableDigraph(N, src, ran));
end);

InstallMethod(MutableDigraph, "for a list of vertices, source, and range",
[IsDenseList, IsDenseList, IsDenseList],
function(domain, src, ran)
  local D;
  D := MutableDigraph(rec(DigraphVertices := domain,
                          DigraphSource   := src,
                          DigraphRange    := ran));
  SetDigraphVertexLabels(D, domain);
  return D;
end);

InstallMethod(Digraph, "for a list of vertices, source, and ran",
[IsDenseList, IsDenseList, IsDenseList],
function(domain, src, ran)
  return MakeImmutableDigraph(MutableDigraph(domain, src, ran));
end);

########################################################################
# 6. Printing, viewing, strings
########################################################################

InstallMethod(ViewString, "for a digraph", [IsDigraph],
function(D)
  local str, n, m;

  str := "<";
  if IsMutable(D) then
    Append(str, "mutable ");
  else
    Append(str, "immutable ");
  fi;

  if IsMultiDigraph(D) then
    Append(str, "multi");
  fi;

  n := DigraphNrVertices(D);
  m := DigraphNrEdges(D);

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

InstallMethod(PrintString, "for a dense immutable digraph",
[IsImmutableDigraph and IsDenseDigraphRep],
function(D)
  return Concatenation("Digraph( ",
                       PrintString(OutNeighbours(D)),
                       " )");
end);

InstallMethod(PrintString, "for a dense mutable digraph",
[IsMutableDigraph and IsDenseDigraphRep],
function(D)
  return Concatenation("MutableDigraph( ",
                       PrintString(OutNeighbours(D)),
                       " )");
end);

InstallMethod(String, "for a dense immutable digraph",
[IsImmutableDigraph and IsDenseDigraphRep],
function(D)
  return Concatenation("Digraph( ",
                       String(OutNeighbours(D)),
                       " )");
end);

InstallMethod(String, "for a dense mutable digraph",
[IsMutableDigraph and IsDenseDigraphRep],
function(D)
  return Concatenation("MutableDigraph( ",
                       String(OutNeighbours(D)),
                       " )");
end);

########################################################################
# 7. Operators
########################################################################

InstallMethod(\=, "for two digraphs", [IsDigraph, IsDigraph], DIGRAPH_EQUALS);

InstallMethod(\<, "for two digraphs", [IsDigraph, IsDigraph], DIGRAPH_LT);

########################################################################
# 8. Digraph by-something constructors
########################################################################

InstallMethod(DigraphByAdjacencyMatrix, "for an empty list",
[IsList and IsEmpty], DigraphByAdjacencyMatrixNC);

InstallMethod(DigraphByAdjacencyMatrixNC, "for an empty list",
[IsList and IsEmpty],
function(dummy)
  return EmptyDigraph(0);
end);

InstallMethod(MutableDigraphByAdjacencyMatrix, "for an empty list",
[IsList and IsEmpty], MutableDigraphByAdjacencyMatrixNC);

InstallMethod(MutableDigraphByAdjacencyMatrixNC, "for an empty list",
[IsList and IsEmpty],
function(dummy)
  return EmptyDigraph(IsMutableDigraph, 0);
end);

InstallMethod(MutableDigraphByAdjacencyMatrix, "for a homogeneous list",
[IsHomogeneousList],
function(mat)
  local n, i, j;
  n := Length(mat);
  if not IsRectangularTable(mat) or Length(mat[1]) <> n then
    ErrorNoReturn("the argument must be a square matrix,");
  elif not IsBool(mat[1][1]) then
    for i in [1 .. n] do
      for j in [1 .. n] do
        if not (IsInt(mat[i][j]) and mat[i][j] >= 0) then
          ErrorNoReturn("the argument must be a matrix of ",
                        "non-negative integers,");
        fi;
      od;
    od;
  fi;
  return MutableDigraphByAdjacencyMatrixNC(mat);
end);

InstallMethod(DigraphByAdjacencyMatrix, "for a homogeneous list",
[IsHomogeneousList],
function(mat)
  local D;
  D := MakeImmutableDigraph(MutableDigraphByAdjacencyMatrix(mat));
  if IsInt(mat[1][1]) then
    SetAdjacencyMatrix(D, mat);
  else
    Assert(1, IsBool(mat[1][1]));
    SetBooleanAdjacencyMatrix(D, mat);
  fi;
  return D;
end);

InstallMethod(MutableDigraphByAdjacencyMatrixNC, "for a homogeneous list",
[IsHomogeneousList],
function(mat)
  local add_edge, n, list, i, j;

  if IsInt(mat[1][1]) then
    add_edge := function(i, j)
      local k;
      for k in [1 .. mat[i][j]] do
        Add(list[i], j);
      od;
    end;
  else  # boolean matrix
    add_edge := function(i, j)
      if mat[i][j] then
        Add(list[i], j);
      fi;
    end;
  fi;

  n    := Length(mat);
  list := EmptyPlist(n);
  for i in [1 .. n] do
    list[i] := [];
    for j in [1 .. n] do
      add_edge(i, j);
    od;
  od;
  return MutableDigraphNC(list);
end);

InstallMethod(DigraphByAdjacencyMatrixNC, "for a homogeneous list",
[IsHomogeneousList],
function(mat)
  local D;
  D := MakeImmutableDigraph(MutableDigraphByAdjacencyMatrixNC(mat));
  if IsInt(mat[1][1]) then
    SetAdjacencyMatrix(D, mat);
  else
    SetBooleanAdjacencyMatrix(D, mat);
    SetIsMultiDigraph(D, false);
  fi;
  return D;
end);

InstallMethod(DigraphByEdges, "for an empty list",
[IsList and IsEmpty],
function(edges)
  return EmptyDigraph(0);
end);

InstallMethod(MutableDigraphByEdges, "for an empty list",
[IsList and IsEmpty],
function(edges)
  return EmptyDigraph(IsMutableDigraph, 0);
end);

InstallMethod(DigraphByEdges, "for an empty list, and a pos int",
[IsList and IsEmpty, IsPosInt],
function(edges, n)
  return EmptyDigraph(n);
end);

InstallMethod(MutableDigraphByEdges, "for an empty list, and a pos int",
[IsList and IsEmpty, IsPosInt],
function(edges, n)
  return EmptyDigraph(IsMutableDigraph, n);
end);

InstallMethod(MutableDigraphByEdges, "for a rectangular table",
[IsRectangularTable],
function(edges)
  local n, edge;
  if not Length(edges[1]) = 2 then
    ErrorNoReturn("the argument must be a list of pairs,");
  elif not (IsPosInt(edges[1][1]) and IsPosInt(edges[1][2])) then
    ErrorNoReturn("the argument must be a list of pairs of ",
                  "positive integers,");
  fi;
  n := 0;
  for edge in edges do
    if edge[1] > n then
      n := edge[1];
    fi;
    if edge[2] > n then
      n := edge[2];
    fi;
  od;
  return MutableDigraphByEdges(edges, n);
end);

InstallMethod(DigraphByEdges, "for a rectangular table",
[IsRectangularTable],
function(edges)
  local D;
  D := MakeImmutableDigraph(MutableDigraphByEdges(edges));
  SetDigraphEdges(D, edges);
  SetDigraphNrEdges(D, Length(edges));
  return D;
end);

InstallMethod(MutableDigraphByEdges,
"for a rectangular table and a pos int",
[IsRectangularTable, IsPosInt],
function(edges, n)
  local list, edge;
  if not Length(edges[1]) = 2 then
    ErrorNoReturn("the first argument must be a list of pairs,");
  elif not (IsPosInt(edges[1][1]) and IsPosInt(edges[1][2])) then
    ErrorNoReturn("the first argument must be a list of pairs of pos ints,");
  fi;
  for edge in edges do
    if edge[1] > n or edge[2] > n then
      ErrorNoReturn("the first argument must not contain values greater than ",
                    n, ",");
    fi;
  od;
  list := List([1 .. n], x -> []);
  for edge in edges do
    Add(list[edge[1]], edge[2]);
  od;
  return MutableDigraphNC(list);
end);

InstallMethod(DigraphByEdges, "for a rectangular table",
[IsRectangularTable, IsPosInt],
function(edges, n)
  local D;
  D := MakeImmutableDigraph(MutableDigraphByEdges(edges, n));
  SetDigraphEdges(D, edges);
  SetDigraphNrEdges(D, Length(edges));
  return D;
end);

InstallMethod(MutableDigraphByInNeighbours, "for a list", [IsList],
function(list)
  local n, x;
  n := Length(list);  # number of vertices
  for x in list do
    if not ForAll(x, i -> IsPosInt(i) and i <= n) then
      ErrorNoReturn("the argument must be a list of lists of positive ",
                    "integers not exceeding the length of the argument,");
    fi;
  od;
  return MutableDigraphByInNeighboursNC(list);
end);

InstallMethod(DigraphByInNeighbours, "for a list", [IsList],
function(list)
  local D;
  D := MakeImmutableDigraph(MutableDigraphByInNeighbours(list));
  SetInNeighbours(D, list);
  return D;
end);

InstallMethod(MutableDigraphByInNeighboursNC, "for a list", [IsList],
function(list)
  return MutableDigraphNC(DIGRAPH_IN_OUT_NBS(list));
end);

InstallMethod(DigraphByInNeighboursNC, "for a list", [IsList],
function(list)
  local D;
  D := MakeImmutableDigraph(MutableDigraphByInNeighboursNC(list));
  SetInNeighbours(D, list);
  return D;
end);

########################################################################
# 9. Converters from other types -> digraph . . .
########################################################################

InstallMethod(AsMutableDigraph, "for a binary relation",
[IsBinaryRelation],
function(rel)
  local dom, list, i;
  dom := GeneratorsOfDomain(UnderlyingDomainOfBinaryRelation(rel));
  if not IsRange(dom) or dom[1] <> 1 then
    ErrorNoReturn("the argument must be a binary relation ",
                  "on the domain [1 .. n] for some positive integer n,");
  fi;
  list := EmptyPlist(Length(dom));
  for i in dom do
    list[i] := ImagesElm(rel, i);
  od;
  return MutableDigraph(list);
end);

InstallMethod(AsDigraph, "for a binary relation",
[IsBinaryRelation],
function(rel)
  local D;
  D := MakeImmutableDigraph(AsMutableDigraph(rel));
  SetIsMultiDigraph(D, false);
  if HasIsReflexiveBinaryRelation(rel) then
    SetIsReflexiveDigraph(D, IsReflexiveBinaryRelation(rel));
  fi;
  if HasIsSymmetricBinaryRelation(rel) then
    SetIsSymmetricDigraph(D, IsSymmetricBinaryRelation(rel));
  fi;
  if HasIsTransitiveBinaryRelation(rel) then
    SetIsTransitiveDigraph(D, IsTransitiveBinaryRelation(rel));
  fi;
  if HasIsAntisymmetricBinaryRelation(rel) then
    SetIsAntisymmetricDigraph(D, IsAntisymmetricBinaryRelation(rel));
  fi;
  return D;
end);

InstallMethod(AsDigraph, "for a transformation",
[IsTransformation],
function(trans)
  return AsDigraph(trans, DegreeOfTransformation(trans));
end);

InstallMethod(AsMutableDigraph, "for a transformation",
[IsTransformation],
function(trans)
  return AsMutableDigraph(trans, DegreeOfTransformation(trans));
end);

InstallMethod(AsMutableDigraph, "for a transformation and an integer",
[IsTransformation, IsInt],
function(f, n)
  local list, x, i;
  if n < 0 then
    ErrorNoReturn("the second argument should be a non-negative integer,");
  fi;

  list := EmptyPlist(n);
  for i in [1 .. n] do
    x := i ^ f;
    if x > n then
      return fail;
    fi;
    list[i] := [x];
  od;
  return MutableDigraphNC(list);
end);

InstallMethod(AsDigraph, "for a transformation and an integer",
[IsTransformation, IsInt],
function(f, n)
  local D;
  D := AsMutableDigraph(f, n);
  if D <> fail then
    D := MakeImmutableDigraph(D);
    SetDigraphNrEdges(D, n);
    SetIsMultiDigraph(D, false);
    SetIsFunctionalDigraph(D, true);
  fi;
  return D;
end);

InstallMethod(AsBinaryRelation, "for a digraph", [IsDenseDigraphRep],
function(D)
  local rel;
  if DigraphNrVertices(D) = 0 then
    ErrorNoReturn("the argument (a digraph) must have at least one vertex,");
  elif IsMultiDigraph(D) then
    ErrorNoReturn("the argument (a digraph) must not have multiple edges");
  fi;
  # Can translate known attributes of <D> to the relation, e.g. symmetry
  rel := BinaryRelationOnPointsNC(OutNeighbours(D));
  if HasIsReflexiveDigraph(D) then
    SetIsReflexiveBinaryRelation(rel, IsReflexiveDigraph(D));
  fi;
  if HasIsSymmetricDigraph(D) then
    SetIsSymmetricBinaryRelation(rel, IsSymmetricDigraph(D));
  fi;
  if HasIsTransitiveDigraph(D) then
    SetIsTransitiveBinaryRelation(rel, IsTransitiveDigraph(D));
  fi;
  if HasIsAntisymmetricDigraph(D) then
    SetIsAntisymmetricBinaryRelation(rel, IsAntisymmetricDigraph(D));
  fi;
  return rel;
end);

InstallMethod(AsSemigroup, "for a function and a digraph",
[IsFunction, IsDigraph],
function(filt, D)
  local red, top, im, max, n, gens, i;

  if filt <> IsPartialPermSemigroup then
    TryNextMethod();
  elif not IsJoinSemilatticeDigraph(D) then
    if IsMeetSemilatticeDigraph(D) then
      return AsSemigroup(IsPartialPermSemigroup,
                         DigraphReverse(DigraphCopyIfMutable(D)));
    fi;
    ErrorNoReturn("the second argument (a digraph) must be a join or ",
                  " meet semilattice,");
  fi;

  D   := DigraphCopyIfMutable(D);
  red := DigraphReflexiveTransitiveReduction(D);
  top := DigraphTopologicalSort(D);
  # im[i] will store the image of the idempotent partial perm corresponding to
  # vertex i of the arugment <D>
  im         := [];
  im[top[1]] := [];
  max        := 1;

  n := DigraphNrVertices(D);
  # For each vertex, the corresponding idempotent has an image
  # containing all images of idempotents below it.
  for i in [2 .. n] do
    im[top[i]] := Union(List(OutNeighboursOfVertex(red, top[i]), j -> im[j]));
    # When there is only one neighbour, we must add a point to the image to
    # distinguish the two idempotent partial perms.
    if Length(OutNeighboursOfVertex(red, top[i])) = 1 then
      Add(im[top[i]], max);
      max := max + 1;
    fi;
  od;

  # Determine a small generating set
  gens := Filtered([1 .. n], j -> Size(InNeighboursOfVertex(red, j)) < 2);
  return Semigroup(List(gens, g -> PartialPerm(im[g], im[g])));
end);

InstallMethod(AsMonoid,
"for a function and a digraph", [IsFunction, IsDigraph],
function(filt, digraph)
  if not (filt = IsPartialPermMonoid or filt = IsPartialPermSemigroup) then
      ErrorNoReturn("Digraphs: AsMonoid usage,\n",
                    "the first argument must be IsPartialPermMonoid or ",
                    "IsPartialPermSemigroup,");
  elif not IsLatticeDigraph(digraph) then
      ErrorNoReturn("Digraphs: AsMonoid usage,\n",
                    "the second argument must be a lattice digraph,");
  fi;
  return AsSemigroup(IsPartialPermSemigroup, digraph);
end);

########################################################################
# 10. Random digraphs
########################################################################

InstallMethod(RandomMutableDigraph, "for a positive integer", [IsPosInt],
function(n)
  return RandomMutableDigraph(n, Float(Random([0 .. n])) / n);
end);

InstallMethod(RandomMutableDigraph, "for a positive integer and a rational",
[IsPosInt, IsRat],
function(n, p)
  return RandomMutableDigraph(n, Float(p));
end);

InstallMethod(RandomMutableDigraph, "for a positive integer and a float",
[IsPosInt, IsFloat],
function(n, p)
  if p < 0.0 or 1.0 < p then
    ErrorNoReturn("the second argument must be between 0 and 1,");
  fi;
  return MutableDigraphNC(RANDOM_DIGRAPH(n, Int(p * 10000)));
end);

InstallMethod(RandomDigraph, "for a pos int", [IsPosInt],
function(n)
  return MakeImmutableDigraph(RandomMutableDigraph(n));
end);

InstallMethod(RandomDigraph, "for a pos int and a rational",
[IsPosInt, IsRat],
function(n, p)
  return MakeImmutableDigraph(RandomMutableDigraph(n, p));
end);

InstallMethod(RandomDigraph, "for a pos int and a float",
[IsPosInt, IsFloat],
function(n, p)
  local D;
  D := MakeImmutableDigraph(RandomMutableDigraph(n, p));
  SetIsMultiDigraph(D, false);
  return D;
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

InstallMethod(RandomMutableTournament, "for an integer", [IsInt],
function(n)
  local choice, nodes, list, v, w;
  if n < 0 then
    ErrorNoReturn("the argument must be a non-negative integer,");
  elif n = 0 then
    return EmptyDigraph(IsMutableDigraph, 0);
  fi;
  choice := [true, false];
  nodes  := [1 .. n];
  list    := List(nodes, x -> []);
  for v in nodes do
    for w in [(v + 1) .. n] do
      if Random(choice) then
        Add(list[v], w);
      else
        Add(list[w], v);
      fi;
    od;
  od;
  return MutableDigraphNC(list);
end);

InstallMethod(RandomTournament, "for an integer", [IsInt],
function(n)
  return MakeImmutableDigraph(RandomMutableTournament(n));
end);
