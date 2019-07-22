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
# 0.  IsValidDigraph
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
# 0. IsValidDigraph
########################################################################

InstallGlobalFunction(IsValidDigraph,
function(arg)
  local D;
  for D in arg do
    if not (IsMutableDigraph(D) or IsImmutableDigraph(D)) then
      ErrorNoReturn("digraph in an invalid state! Did you return a ",
                    "mutable digraph from a method for an attribute, ",
                    "or MakeImmutable(a mutable digraph)??");
    fi;
  od;
end);

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

InstallMethod(ConvertToImmutableDigraphNC, "for a record", [IsRecord],
function(record)
  return MakeImmutableDigraph(ConvertToMutableDigraphNC(record));
end);

InstallMethod(ConvertToImmutableDigraphNC,
"for a dense list of out-neighbours",
[IsDenseList],
function(list)
  return MakeImmutableDigraph(ConvertToMutableDigraphNC(list));
end);

InstallMethod(DigraphConsNC, "for IsMutableDigraph and a record",
[IsMutableDigraph, IsRecord],
function(filt, record)
  local out;
  Assert(1, IsBound(record.DigraphNrVertices));
  Assert(1, IsBound(record.DigraphRange));
  Assert(1, IsBound(record.DigraphSource));
  out := DIGRAPH_OUT_NEIGHBOURS_FROM_SOURCE_RANGE(record.DigraphNrVertices,
                                                  record.DigraphSource,
                                                  record.DigraphRange);
  return ConvertToMutableDigraphNC(out);
end);

InstallMethod(DigraphConsNC,
"for IsMutableDigraph and a dense list of out-neighbours",
[IsMutableDigraph, IsDenseList],
function(filt, list)
  Assert(1, not IsMutable(list));
  return ConvertToMutableDigraphNC(List(list, ShallowCopy));
end);

InstallMethod(DigraphConsNC,
"for IsMutableDigraph and a dense mutable list of out-neighbours",
[IsMutableDigraph, IsDenseList and IsMutable],
function(filt, list)
  return ConvertToMutableDigraphNC(StructuralCopy(list));
end);

InstallMethod(DigraphConsNC, "for IsImmutableDigraph and a record",
[IsImmutableDigraph, IsRecord],
function(filt, record)
  local D, nm;
  Assert(1, IsBound(record.DigraphNrVertices));
  Assert(1, IsBound(record.DigraphRange));
  Assert(1, IsBound(record.DigraphSource));
  for nm in RecNames(record) do
    if not nm in ["DigraphRange", "DigraphSource", "DigraphNrVertices"] then
      Info(InfoWarning, 1, "ignoring record component \"", nm, "\"!");
    fi;
  od;
  D := MakeImmutableDigraph(DigraphConsNC(IsMutableDigraph, record));
  SetDigraphSource(D, StructuralCopy(record.DigraphSource));
  SetDigraphRange(D, StructuralCopy(record.DigraphRange));
  return D;
end);

InstallMethod(DigraphConsNC,
"for IsImmutableDigraph and a dense list of adjacencies",
[IsImmutableDigraph, IsDenseList],
function(filt, list)
  return MakeImmutableDigraph(DigraphConsNC(IsMutableDigraph, list));
end);

InstallMethod(DigraphNC, "for a function and a dense list",
[IsFunction, IsDenseList],
function(func, list)
  return DigraphConsNC(func, list);
end);

InstallMethod(DigraphNC, "for a dense list", [IsDenseList],
function(list)
  return DigraphConsNC(IsImmutableDigraph, list);
end);

InstallMethod(DigraphNC, "for a function and a record",
[IsFunction, IsRecord],
function(func, record)
  return DigraphConsNC(func, record);
end);

InstallMethod(DigraphNC, "for a record", [IsRecord],
function(record)
  return DigraphConsNC(IsImmutableDigraph, record);
end);

########################################################################
# 3. Digraph copies
########################################################################

InstallMethod(DigraphMutableCopy, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local copy;
  IsValidDigraph(D);
  copy := ConvertToMutableDigraphNC(OutNeighboursMutableCopy(D));
  SetDigraphVertexLabels(copy, StructuralCopy(DigraphVertexLabels(D)));
  SetDigraphEdgeLabelsNC(copy, StructuralCopy(DigraphEdgeLabelsNC(D)));
  return copy;
end);

InstallMethod(DigraphCopy, "for a dense digraph", [IsDenseDigraphRep],
function(D)
  local copy;
  IsValidDigraph(D);
  copy := ConvertToImmutableDigraphNC(OutNeighboursMutableCopy(D));
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
[IsImmutableDigraph], DigraphCopy);

########################################################################
# 4. MakeImmutableDigraph
########################################################################

InstallMethod(MakeImmutableDigraph, "for a mutable dense digraph",
[IsMutableDigraph and IsDenseDigraphRep],
function(D)
  MakeImmutable(D);
  SetFilterObj(D, IsAttributeStoringRep);
  SetFilterObj(D, IsImmutableDigraph);
  MakeImmutable(D!.OutNeighbours);
  return D;
end);

########################################################################
# 5. Digraph constructors
########################################################################

InstallMethod(DigraphCons, "for IsMutableDigraph and a record",
[IsMutableDigraph, IsRecord],
function(filt, record)
  local D, cmp, labels, i;

  if IsGraph(record) then
    # IsGraph is a function not a filter, so we cannot have a separate method
    D := DigraphNC(IsMutableDigraph,
                   List(Vertices(record), x -> Adjacency(record, x)));
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
    cmp := x -> IsPosInt(x) and x < record.DigraphNrVertices + 1;
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
  D := DigraphNC(IsMutableDigraph, record);
  if IsBound(labels) then
    SetDigraphVertexLabels(D, labels);
  fi;
  return D;
end);

InstallMethod(DigraphCons,
"for IsMutableDigraph and a dense list of out-neighbours",
[IsMutableDigraph, IsDenseList],
function(filt, list)
  local sublist, v;
  for sublist in list do
    if not IsHomogeneousList(sublist) then
      ErrorNoReturn("the argument <list> must be a list of lists of positive ",
                    "integers not exceeding the length of the argument,");
    fi;
    for v in sublist do
      if not IsPosInt(v) or v > Length(list) then
        ErrorNoReturn("the argument <list> must be a list of lists of ",
                      "positive integers not exceeding the length of ",
                      "the argument,");
      fi;
    od;
  od;
  return DigraphNC(IsMutableDigraph, list);
end);

InstallMethod(DigraphCons, "for IsMutableDigraph, a list, and function",
[IsMutableDigraph, IsList, IsFunction],
function(filt, list, func)
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

InstallMethod(DigraphCons,
"for IsMutableDigraph, a number of vertices, source, and range",
[IsMutableDigraph, IsInt, IsList, IsList],
function(filt, N, src, ran)
  return DigraphCons(IsMutableDigraph, rec(DigraphNrVertices := N,
                                           DigraphSource     := src,
                                           DigraphRange      := ran));
end);

InstallMethod(DigraphCons,
"for IsMutableDigraph, a list of vertices, source, and range",
[IsMutableDigraph, IsList, IsList, IsList],
function(filt, domain, src, ran)
  local D;
  D := DigraphCons(IsMutableDigraph, rec(DigraphVertices := domain,
                                         DigraphSource   := src,
                                         DigraphRange    := ran));
  SetDigraphVertexLabels(D, domain);
  return D;
end);

InstallMethod(DigraphCons, "for IsImmutableDigraph and a record",
[IsImmutableDigraph, IsRecord],
function(filt, record)
  local D;
  D := MakeImmutableDigraph(DigraphCons(IsMutableDigraph, record));
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

InstallMethod(DigraphCons,
"for IsImmutableDigraph and a dense list of out-neighbours",
[IsImmutableDigraph, IsDenseList],
function(filt, list)
  return MakeImmutableDigraph(DigraphCons(IsMutableDigraph, list));
end);

InstallMethod(DigraphCons, "for IsImmutableDigraph, a list, and function",
[IsImmutableDigraph, IsList, IsFunction],
function(filt, list, func)
  local D;
  D := MakeImmutableDigraph(DigraphCons(IsMutableDigraph, list, func));
  SetDigraphAdjacencyFunction(D, {u, v} -> func(list[u], list[v]));
  SetFilterObj(D, IsDigraphWithAdjacencyFunction);
  SetDigraphVertexLabels(D, list);
  return D;
end);

InstallMethod(DigraphCons,
"for IsImmutableDigraph, a number of vertices, source, and range",
[IsImmutableDigraph, IsInt, IsList, IsList],
function(filt, N, src, ran)
  return MakeImmutableDigraph(DigraphCons(IsMutableDigraph, N, src, ran));
end);

InstallMethod(DigraphCons,
"for IsImmutableDigraph, a list of vertices, source, and range",
[IsImmutableDigraph, IsList, IsList, IsList],
function(filt, domain, src, ran)
  return MakeImmutableDigraph(DigraphCons(IsMutableDigraph, domain, src, ran));
end);

InstallMethod(Digraph, "for a filter and a record", [IsFunction, IsRecord],
function(filt, record)
  return DigraphCons(filt, record);
end);

InstallMethod(Digraph, "for a record", [IsRecord],
function(record)
  return DigraphCons(IsImmutableDigraph, record);
end);

InstallMethod(Digraph, "for a filter and a list", [IsFunction, IsList],
function(func, list)
  return DigraphCons(func, list);
end);

InstallMethod(Digraph, "for a list", [IsList],
function(list)
  return DigraphCons(IsImmutableDigraph, list);
end);

InstallMethod(Digraph, "for a filter, a list, and a function",
[IsFunction, IsList, IsFunction],
function(filt, list, func)
  return DigraphCons(filt, list, func);
end);

InstallMethod(Digraph, "for a list and a function", [IsList, IsFunction],
function(list, func)
  return DigraphCons(IsImmutableDigraph, list, func);
end);

InstallMethod(Digraph, "for a filter, integer, list, and list",
[IsFunction, IsInt, IsList, IsList],
function(filt, n, src, ran)
  return DigraphCons(filt, n, src, ran);
end);

InstallMethod(Digraph, "for an integer, list, and list",
[IsInt, IsList, IsList],
function(n, src, ran)
  return DigraphCons(IsImmutableDigraph, n, src, ran);
end);

InstallMethod(Digraph, "for a filter, list, list, and list",
[IsFunction, IsList, IsList, IsList],
function(filt, dom, src, ran)
  return DigraphCons(filt, dom, src, ran);
end);

InstallMethod(Digraph, "for a list, list, and list", [IsList, IsList, IsList],
function(dom, src, ran)
  return DigraphCons(IsImmutableDigraph, dom, src, ran);
end);

########################################################################
# 6. Printing, viewing, strings
########################################################################

InstallMethod(ViewString, "for a digraph", [IsDigraph],
function(D)
  local str, n, m;
  IsValidDigraph(D);
  str := "<";
  if IsMutableDigraph(D) then
    Append(str, "mutable ");
  elif IsImmutableDigraph(D) then
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
  return Concatenation("Digraph( IsImmutableDigraph, ",
                       PrintString(OutNeighbours(D)),
                       " )");
end);

InstallMethod(PrintString, "for a dense mutable digraph",
[IsMutableDigraph and IsDenseDigraphRep],
function(D)
  return Concatenation("Digraph( IsMutableDigraph, ",
                       PrintString(OutNeighbours(D)),
                       " )");
end);

InstallMethod(String, "for a dense immutable digraph",
[IsImmutableDigraph and IsDenseDigraphRep],
function(D)
  return Concatenation("Digraph( IsImmutableDigraph, ",
                       String(OutNeighbours(D)),
                       " )");
end);

InstallMethod(String, "for a dense mutable digraph",
[IsMutableDigraph and IsDenseDigraphRep],
function(D)
  return Concatenation("Digraph( IsMutableDigraph, ",
                       String(OutNeighbours(D)),
                       " )");
end);

########################################################################
# 7. Operators
########################################################################

InstallMethod(\=, "for two digraphs", [IsDigraph, IsDigraph],
function(C, D)
  IsValidDigraph(C);
  IsValidDigraph(D);
  return DIGRAPH_EQUALS(C, D);
end);

InstallMethod(\<, "for two digraphs", [IsDigraph, IsDigraph],
function(C, D)
  IsValidDigraph(C);
  IsValidDigraph(D);
  return DIGRAPH_LT(C, D);
end);

########################################################################
# 8. Digraph by-something constructors
########################################################################

InstallMethod(DigraphByAdjacencyMatrixConsNC,
"for IsMutableDigraph and a homogeneous list",
[IsMutableDigraph, IsHomogeneousList],
function(filt, mat)
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
  return DigraphNC(IsMutableDigraph, list);
end);

InstallMethod(DigraphByAdjacencyMatrixCons,
"for IsMutableDigraph and a homogeneous list",
[IsMutableDigraph, IsHomogeneousList],
function(filt, mat)
  local n, i, j;
  n := Length(mat);
  if not IsRectangularTable(mat) or Length(mat[1]) <> n then
    ErrorNoReturn("the argument <mat> must be a square matrix,");
  elif not IsBool(mat[1][1]) then
    for i in [1 .. n] do
      for j in [1 .. n] do
        if not (IsInt(mat[i][j]) and mat[i][j] >= 0) then
          ErrorNoReturn("the argument <mat> must be a matrix of ",
                        "non-negative integers,");
        fi;
      od;
    od;
  fi;
  return DigraphByAdjacencyMatrixConsNC(IsMutableDigraph, mat);
end);

InstallMethod(DigraphByAdjacencyMatrixCons,
"for IsMutableDigraph and an empty list",
[IsMutableDigraph, IsList and IsEmpty], DigraphByAdjacencyMatrixConsNC);

InstallMethod(DigraphByAdjacencyMatrixConsNC,
"for IsMutableDigraph and an empty list",
[IsMutableDigraph, IsList and IsEmpty],
function(filt, dummy)
  return EmptyDigraph(IsMutableDigraph, 0);
end);

InstallMethod(DigraphByAdjacencyMatrixCons,
"for IsImmutableDigraph and a homogeneous list",
[IsImmutableDigraph, IsHomogeneousList],
function(filt, mat)
  local D;
  D := MakeImmutableDigraph(
         DigraphByAdjacencyMatrixCons(IsMutableDigraph, mat));
  if IsEmpty(mat) or IsInt(mat[1][1]) then
    SetAdjacencyMatrix(D, mat);
  else
    Assert(1, IsBool(mat[1][1]));
    SetBooleanAdjacencyMatrix(D, mat);
  fi;
  return D;
end);

InstallMethod(DigraphByAdjacencyMatrix,
"for a function and a homogeneous list",
[IsFunction, IsHomogeneousList],
function(func, mat)
  return DigraphByAdjacencyMatrixCons(func, mat);
end);

InstallMethod(DigraphByAdjacencyMatrix, "for a homogeneous list",
[IsHomogeneousList],
function(mat)
  return DigraphByAdjacencyMatrixCons(IsImmutableDigraph, mat);
end);

InstallMethod(DigraphByEdgesCons,
"for IsMutableDigraph, a list, and an integer",
[IsMutableDigraph, IsList, IsInt],
function(filt, edges, n)
  local list, edge;
  if IsEmpty(edges) then
    return NullDigraph(IsMutableDigraph, n);
  fi;
  for edge in edges do
    if Length(edge) <> 2 then
      ErrorNoReturn("the 1st argument <edges> must be a list of pairs,");
    elif ForAny(edge, x -> not (IsPosInt(x) and x <= n)) then
      ErrorNoReturn("the 1st argument <edges> must not contain values ",
                    "greater than ", n, ", the 2nd argument <n>,");
    fi;
  od;
  list := List([1 .. n], x -> []);
  for edge in edges do
    Add(list[edge[1]], edge[2]);
  od;
  return DigraphNC(IsMutableDigraph, list);
end);

InstallMethod(DigraphByEdgesCons, "for IsMutableDigraph and a list",
[IsMutableDigraph, IsList],
function(filt, edges)
  local n;
  if IsEmpty(edges) then
    n := 0;
  else
    n := Maximum(List(edges, Maximum));
  fi;
  return DigraphByEdgesCons(IsMutableDigraph, edges, n);
end);

InstallMethod(DigraphByEdgesCons, "for an ImmutableDigraph and a list",
[IsImmutableDigraph, IsList],
function(filt, edges)
  local D;
  D := MakeImmutableDigraph(DigraphByEdges(IsMutableDigraph, edges));
  SetDigraphEdges(D, edges);
  SetDigraphNrEdges(D, Length(edges));
  return D;
end);

InstallMethod(DigraphByEdgesCons,
"for IsImmutableDigraph, a list, and an integer",
[IsImmutableDigraph, IsList, IsInt],
function(filt, edges, n)
  local D;
  D := MakeImmutableDigraph(DigraphByEdges(IsMutableDigraph, edges, n));
  SetDigraphEdges(D, edges);
  SetDigraphNrEdges(D, Length(edges));
  return D;
end);

InstallMethod(DigraphByEdges, "for a list and an integer",
[IsList, IsInt],
function(edges, n)
  return DigraphByEdgesCons(IsImmutableDigraph, edges, n);
end);

InstallMethod(DigraphByEdges, "for a list", [IsList],
function(edges)
  return DigraphByEdgesCons(IsImmutableDigraph, edges);
end);

InstallMethod(DigraphByEdges, "for a function, a list, and an integer",
[IsFunction, IsList, IsInt],
function(func, edges, n)
  return DigraphByEdgesCons(func, edges, n);
end);

InstallMethod(DigraphByEdges, "for a function and a list",
[IsFunction, IsList],
function(func, edges)
  return DigraphByEdgesCons(func, edges);
end);

InstallMethod(DigraphByInNeighboursCons, "for IsMutableDigraph, and a list",
[IsMutableDigraph, IsList],
function(filt, list)
  local n, x;
  n := Length(list);  # number of vertices
  for x in list do
    if not ForAll(x, i -> IsPosInt(i) and i <= n) then
      ErrorNoReturn("the argument <list> must be a list of lists of positive ",
                    "integers not exceeding the length of the argument,");
    fi;
  od;
  return DigraphByInNeighboursConsNC(IsMutableDigraph, list);
end);

InstallMethod(DigraphByInNeighboursCons, "for IsImmutableDigraph and a list",
[IsImmutableDigraph, IsList],
function(filt, list)
  local D;
  D := MakeImmutableDigraph(DigraphByInNeighboursCons(IsMutableDigraph, list));
  SetInNeighbours(D, list);
  return D;
end);

InstallMethod(DigraphByInNeighboursConsNC, "for IsMutableDigraph and a list",
[IsMutableDigraph, IsList],
function(filt, list)
  return DigraphNC(IsMutableDigraph, DIGRAPH_IN_OUT_NBS(list));
end);

InstallMethod(DigraphByInNeighboursConsNC, "for IsImmutableDigraph and a list",
[IsImmutableDigraph, IsList],
function(filt, list)
  local D;
  D := MakeImmutableDigraph(DigraphByInNeighboursConsNC(IsMutableDigraph,
                                                        list));
  SetInNeighbours(D, list);
  return D;
end);

InstallMethod(DigraphByInNeighbours, "for a list", [IsList],
function(list)
  return DigraphByInNeighboursCons(IsImmutableDigraph, list);
end);

InstallMethod(DigraphByInNeighbours, "for a function and a list",
[IsFunction, IsList],
function(func, list)
  return DigraphByInNeighboursCons(func, list);
end);

########################################################################
# 9. Converters to/from other types -> digraph . . .
########################################################################

InstallMethod(AsDigraphCons, "for IsMutableDigraph and a binary relation",
[IsMutableDigraph, IsBinaryRelation],
function(filt, rel)
  local dom, list, i;
  dom := GeneratorsOfDomain(UnderlyingDomainOfBinaryRelation(rel));
  if not IsRange(dom) or dom[1] <> 1 then
    ErrorNoReturn("the argument <rel> must be a binary relation ",
                  "on the domain [1 .. n] for some positive integer n,");
  fi;
  list := EmptyPlist(Length(dom));
  for i in dom do
    list[i] := ImagesElm(rel, i);
  od;
  return Digraph(IsMutableDigraph, list);
end);

InstallMethod(AsDigraphCons, "for IsImmutableDigraph and a binary relation",
[IsImmutableDigraph, IsBinaryRelation],
function(filt, rel)
  local D;
  D := MakeImmutableDigraph(AsDigraph(IsMutableDigraph, rel));
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

InstallMethod(AsDigraph, "for a binary relation", [IsBinaryRelation],
function(rel)
  return AsDigraphCons(IsImmutableDigraph, rel);
end);

InstallMethod(AsDigraph, "for a function and a binary relation",
[IsFunction, IsBinaryRelation],
function(func, rel)
  return AsDigraphCons(func, rel);
end);

InstallMethod(AsDigraphCons,
"for IsMutableDigraph, a transformation, and an integer",
[IsMutableDigraph, IsTransformation, IsInt],
function(filt, f, n)
  local list, x, i;
  if n < 0 then
    ErrorNoReturn("the 2nd argument <n> should be a non-negative integer,");
  fi;

  list := EmptyPlist(n);
  for i in [1 .. n] do
    x := i ^ f;
    if x > n then
      return fail;
    fi;
    list[i] := [x];
  od;
  return DigraphNC(IsMutableDigraph, list);
end);

InstallMethod(AsDigraphCons,
"for IsImmutableDigraph, a transformation, and an integer",
[IsImmutableDigraph, IsTransformation, IsInt],
function(filt, f, n)
  local D;
  D := AsDigraph(IsMutableDigraph, f, n);
  if D <> fail then
    D := MakeImmutableDigraph(D);
    SetDigraphNrEdges(D, n);
    SetIsMultiDigraph(D, false);
    SetIsFunctionalDigraph(D, true);
  fi;
  return D;
end);

InstallMethod(AsDigraph,
"for a function, a transformation, and an integer",
[IsFunction, IsTransformation, IsInt],
function(func, t, n)
  return AsDigraphCons(func, t, n);
end);

InstallMethod(AsDigraph, "for a transformation and an integer",
[IsTransformation, IsInt],
function(t, n)
  return AsDigraphCons(IsImmutableDigraph, t, n);
end);

InstallMethod(AsDigraph, "for a function and a transformation",
[IsFunction, IsTransformation],
function(func, t)
  return AsDigraphCons(func, t, DegreeOfTransformation(t));
end);

InstallMethod(AsDigraph, "for a transformation", [IsTransformation],
function(t)
  return AsDigraphCons(IsImmutableDigraph, t, DegreeOfTransformation(t));
end);

InstallMethod(AsBinaryRelation, "for a digraph", [IsDenseDigraphRep],
function(D)
  local rel;
  if DigraphNrVertices(D) = 0 then
    ErrorNoReturn("the argument <D> must be a digraph with at least 1 ",
                  "vertex,");
  elif IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no multiple edges");
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
    ErrorNoReturn("the 2nd argument <D> must be digraph that is a join or ",
                  "meet semilattice,");
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

InstallMethod(AsMonoid, "for a function and a digraph",
[IsFunction, IsDigraph],
function(filt, D)
  if not (filt = IsPartialPermMonoid or filt = IsPartialPermSemigroup) then
    ErrorNoReturn("the 1st argument <filt> must be IsPartialPermMonoid or ",
                  "IsPartialPermSemigroup,");
  elif not IsLatticeDigraph(D) then
    ErrorNoReturn("the 2nd argument <D> must be a lattice digraph,");
  fi;
  return AsSemigroup(IsPartialPermSemigroup, D);
end);

########################################################################
# 10. Random digraphs
########################################################################

InstallMethod(RandomDigraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsInt],
function(filt, n)
  return RandomDigraphCons(IsMutableDigraph, n, Float(Random([0 .. n])) / n);
end);

InstallMethod(RandomDigraphCons, "for IsMutableDigraph and an integer",
[IsImmutableDigraph, IsInt],
function(filt, n)
  return RandomDigraphCons(IsImmutableDigraph, n, Float(Random([0 .. n])) / n);
end);

InstallMethod(RandomDigraphCons,
"for IsMutableDigraph, an integer, and a rational",
[IsMutableDigraph, IsInt, IsRat],
function(filt, n, p)
  return RandomDigraphCons(IsMutableDigraph, n, Float(p));
end);

InstallMethod(RandomDigraphCons,
"for IsImmutableDigraph, an integer, and a rational",
[IsImmutableDigraph, IsInt, IsRat],
function(filt, n, p)
  return RandomDigraphCons(IsImmutableDigraph, n, Float(p));
end);

InstallMethod(RandomDigraphCons,
"for IsMutableDigraph, a positive integer, and a float",
[IsMutableDigraph, IsPosInt, IsFloat],
function(filt, n, p)
  if p < 0.0 or 1.0 < p then
    ErrorNoReturn("the 2nd argument <p> must be between 0 and 1,");
  fi;
  return DigraphNC(IsMutableDigraph, RANDOM_DIGRAPH(n, Int(p * 10000)));
end);

InstallMethod(RandomDigraphCons,
"for IsImmutableDigraph, a positive integer, and a float",
[IsImmutableDigraph, IsPosInt, IsFloat],
function(filt, n, p)
  local D;
  D := MakeImmutableDigraph(RandomDigraphCons(IsMutableDigraph, n, p));
  SetIsMultiDigraph(D, false);
  return D;
end);

InstallMethod(RandomDigraph, "for a pos int", [IsPosInt],
function(n)
  return RandomDigraphCons(IsImmutableDigraph, n);
end);

InstallMethod(RandomDigraph, "for a pos int and a rational",
[IsPosInt, IsRat],
function(n, p)
  return RandomDigraphCons(IsImmutableDigraph, n, p);
end);

InstallMethod(RandomDigraph, "for a pos int and a float",
[IsPosInt, IsFloat],
function(n, p)
  return RandomDigraphCons(IsImmutableDigraph, n, p);
end);

InstallMethod(RandomDigraph, "for a func and a pos int", [IsFunction, IsPosInt],
function(func, n)
  return RandomDigraphCons(func, n);
end);

InstallMethod(RandomDigraph, "for a func, a pos int, and a rational",
[IsFunction, IsPosInt, IsRat],
function(func, n, p)
  return RandomDigraphCons(func, n, p);
end);

InstallMethod(RandomDigraph, "for a func, a pos int, and a float",
[IsFunction, IsPosInt, IsFloat],
function(func, n, p)
  return RandomDigraphCons(func, n, p);
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

InstallMethod(RandomTournamentCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsInt],
function(filt, n)
  local choice, nodes, list, v, w;
  if n < 0 then
    ErrorNoReturn("the argument <n> must be a non-negative integer,");
  elif n = 0 then
    return EmptyDigraph(IsMutableDigraph, 0);
  fi;
  choice := [true, false];
  nodes  := [1 .. n];
  list   := List(nodes, x -> []);
  for v in nodes do
    for w in [(v + 1) .. n] do
      if Random(choice) then
        Add(list[v], w);
      else
        Add(list[w], v);
      fi;
    od;
  od;
  return DigraphNC(IsMutableDigraph, list);
end);

InstallMethod(RandomTournamentCons, "for IsImmutableDigraph and an integer",
[IsImmutableDigraph, IsInt],
function(filt, n)
  return MakeImmutableDigraph(RandomTournamentCons(IsMutableDigraph, n));
end);

InstallMethod(RandomTournament, "for an integer", [IsInt],
function(n)
  return RandomTournamentCons(IsImmutableDigraph, n);
end);

InstallMethod(RandomTournament, "for a func and an integer",
[IsFunction, IsInt],
function(func, n)
  return RandomTournamentCons(func, n);
end);

InstallMethod(RandomLatticeCons, "for IsMutableDigraph and a pos int",
[IsMutableDigraph, IsPosInt],
function(filt, n)
  local fam, rand_blist;

  fam := [BlistList([1 .. n], [])];

  while Length(fam) < n do
    rand_blist := List([1 .. n], x -> Random([true, false]));
    UniteSet(fam, List(fam, x -> UnionBlist(x, rand_blist)));
  od;

  return Digraph(IsMutableDigraph, fam, IsSubsetBlist);
end);

InstallMethod(RandomLatticeCons, "for IsImmutableDigraph and a pos int",
[IsImmutableDigraph, IsPosInt],
function(filt, n)
  return MakeImmutableDigraph(RandomLatticeCons(IsMutableDigraph, n));
end);

InstallMethod(RandomLattice, "for a pos int",
[IsPosInt],
function(n)
  return RandomLatticeCons(IsImmutableDigraph, n);
end);

InstallMethod(RandomLattice, "for a func and a pos int",
[IsFunction, IsPosInt],
function(func, n)
  return RandomLatticeCons(func, n);
end);
