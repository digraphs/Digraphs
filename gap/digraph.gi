#############################################################################
##
##  digraph.gi
##  Copyright (C) 2014-21                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

########################################################################
# This file is organised as follows:
#
# 1.  Digraph types
# 2.  Digraph no-check constructors
# 3.  Digraph copies
# 4.  PostMakeImmutable
# 5.  Digraph constructors
# 6.  Printing, viewing, strings
# 7.  Operators
# 8.  Digraph by-something constructors
# 9.  Converters to/from other types -> digraph
# 10. Random digraphs
#
########################################################################

BindGlobal("DIGRAPHS_NamedDigraphs", fail);
BindGlobal("DIGRAPHS_NamedDigraphsTests", fail);

BindGlobal("DIGRAPHS_LoadNamedDigraphs", function()
  # Check if the database has already been loaded
  if DIGRAPHS_NamedDigraphs = fail then
    MakeReadWriteGlobal("DIGRAPHS_NamedDigraphs");
    UnbindGlobal("DIGRAPHS_NamedDigraphs");

    # Initialise empty record
    BindGlobal("DIGRAPHS_NamedDigraphs", rec());

    # Populate record with entries from the named digraphs main database
    Read(Concatenation(DIGRAPHS_Dir(), "/data/named-digraphs-main-database.g"));
  fi;
end);

BindGlobal("DIGRAPHS_LoadNamedDigraphsTests", function()
  # INTENDED ONLY FOR TESTING PURPOSES
  # Check if the database has already been loaded
  if DIGRAPHS_NamedDigraphsTests = fail then
    MakeReadWriteGlobal("DIGRAPHS_NamedDigraphsTests");
    UnbindGlobal("DIGRAPHS_NamedDigraphsTests");

    # Initialise empty record
    BindGlobal("DIGRAPHS_NamedDigraphsTests", rec());

    # Populate record with entries from the named digraphs test database
    Read(Concatenation(DIGRAPHS_Dir(), "/data/named-digraphs-test-database.g"));
  fi;
end);

InstallMethod(DigraphMutabilityFilter, "for a digraph", [IsDigraph],
function(D)
  if IsMutableDigraph(D) then
    return IsMutableDigraph;
  else
    return IsImmutableDigraph;
  fi;
end);

########################################################################
# 1. Digraph types
########################################################################

BindGlobal("DigraphByOutNeighboursType", NewType(DigraphFamily,
                                         IsDigraphByOutNeighboursRep));

########################################################################
# 2. Digraph no-check constructors
########################################################################

InstallMethod(ConvertToMutableDigraphNC, "for a record", [IsRecord],
function(record)
  local D;
  Assert(1, IsBound(record.OutNeighbours));
  Assert(1, Length(NamesOfComponents(record)) = 1);
  D := Objectify(DigraphByOutNeighboursType, record);
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
record -> MakeImmutable(ConvertToMutableDigraphNC(record)));

InstallMethod(ConvertToImmutableDigraphNC,
"for a dense list of out-neighbours",
[IsDenseList],
list -> MakeImmutable(ConvertToMutableDigraphNC(list)));

InstallMethod(DigraphConsNC, "for IsMutableDigraph and a record",
[IsMutableDigraph, IsRecord],
function(_, record)
  local required, out, name;
  required := ["DigraphRange", "DigraphSource", "DigraphNrVertices"];
  for name in required do
    Assert(1, IsBound(record.(name)));
  od;
  for name in Difference(RecNames(record), required) do
    Info(InfoWarning, 1, "ignoring record component \"", name, "\"!");
  od;
  out := DIGRAPH_OUT_NEIGHBOURS_FROM_SOURCE_RANGE(record.DigraphNrVertices,
                                                  record.DigraphSource,
                                                  record.DigraphRange);
  return ConvertToMutableDigraphNC(out);
end);

InstallMethod(DigraphConsNC,
"for IsMutableDigraph and a dense list of out-neighbours",
[IsMutableDigraph, IsDenseList],
function(_, list)
  Assert(1, not IsMutable(list));
  return ConvertToMutableDigraphNC(List(list, ShallowCopy));
end);

InstallMethod(DigraphConsNC,
"for IsMutableDigraph and a dense mutable list of out-neighbours",
[IsMutableDigraph, IsDenseList and IsMutable],
{_, list} -> ConvertToMutableDigraphNC(StructuralCopy(list)));

InstallMethod(DigraphConsNC, "for IsImmutableDigraph and a record",
[IsImmutableDigraph, IsRecord],
function(_, record)
  local D;
  D := MakeImmutable(DigraphConsNC(IsMutableDigraph, record));
  SetDigraphSource(D, StructuralCopy(record.DigraphSource));
  SetDigraphRange(D, StructuralCopy(record.DigraphRange));
  return D;
end);

InstallMethod(DigraphConsNC, "for IsImmutableDigraph and a dense list",
[IsImmutableDigraph, IsDenseList],
{_, list} -> MakeImmutable(DigraphConsNC(IsMutableDigraph, list)));

InstallMethod(DigraphNC, "for a function and a dense list",
[IsFunction, IsDenseList], DigraphConsNC);

InstallMethod(DigraphNC, "for a dense list", [IsDenseList],
list -> DigraphConsNC(IsImmutableDigraph, list));

InstallMethod(DigraphNC, "for a function and a record",
[IsFunction, IsRecord], DigraphConsNC);

InstallMethod(DigraphNC, "for a record", [IsRecord],
record -> DigraphConsNC(IsImmutableDigraph, record));

########################################################################
# 3. Digraph copies
########################################################################

InstallMethod(DigraphMutableCopy, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
  local copy;
  copy := ConvertToMutableDigraphNC(OutNeighboursMutableCopy(D));
  SetDigraphVertexLabels(copy, StructuralCopy(DigraphVertexLabels(D)));
  if HaveEdgeLabelsBeenAssigned(D) then
    SetDigraphEdgeLabelsNC(copy, StructuralCopy(DigraphEdgeLabelsNC(D)));
  fi;
  return copy;
end);

InstallMethod(DigraphImmutableCopy, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
  local copy;
  copy := ConvertToImmutableDigraphNC(OutNeighboursMutableCopy(D));
  SetDigraphVertexLabels(copy, StructuralCopy(DigraphVertexLabels(D)));
  if HaveEdgeLabelsBeenAssigned(D) then
    SetDigraphEdgeLabelsNC(copy, StructuralCopy(DigraphEdgeLabelsNC(D)));
  fi;
  return copy;
end);

InstallMethod(DigraphCopySameMutability, "for a mutable digraph",
[IsMutableDigraph], DigraphMutableCopy);

InstallMethod(DigraphCopySameMutability, "for an immutable digraph",
[IsImmutableDigraph], DigraphImmutableCopy);

InstallMethod(DigraphImmutableCopyIfMutable, "for a mutable digraph",
[IsMutableDigraph], DigraphImmutableCopy);

InstallMethod(DigraphImmutableCopyIfMutable, "for an immutable digraph",
[IsImmutableDigraph], IdFunc);

InstallMethod(DigraphImmutableCopyIfImmutable, "for a mutable digraph",
[IsMutableDigraph], IdFunc);

InstallMethod(DigraphImmutableCopyIfImmutable, "for an immutable digraph",
[IsImmutableDigraph], DigraphImmutableCopy);

InstallMethod(DigraphMutableCopyIfImmutable, "for a mutable digraph",
[IsMutableDigraph], IdFunc);

InstallMethod(DigraphMutableCopyIfImmutable, "for an immutable digraph",
[IsImmutableDigraph], DigraphMutableCopy);

InstallMethod(DigraphMutableCopyIfMutable, "for a mutable digraph",
[IsMutableDigraph], DigraphMutableCopy);

InstallMethod(DigraphMutableCopyIfMutable, "for an immutable digraph",
[IsImmutableDigraph], IdFunc);

########################################################################
# 4. PostMakeImmutable
########################################################################

InstallMethod(PostMakeImmutable, "for a digraph",
[IsDigraph and IsDigraphByOutNeighboursRep],
function(D)
  MakeImmutable(D!.OutNeighbours);
  SetFilterObj(D, IsImmutableDigraph);
  SetFilterObj(D, IsAttributeStoringRep);
end);

########################################################################
# 5. Digraph constructors
########################################################################

InstallMethod(DigraphCons, "for IsMutableDigraph and a record",
[IsMutableDigraph, IsRecord],
function(_, record)
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

  if not ForAll(record.DigraphSource, cmp) then
    ErrorNoReturn("the record component 'DigraphSource' is invalid,");
  elif not ForAll(record.DigraphRange, cmp) then
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
function(_, list)
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
function(_, list, func)
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
function(_, N, src, ran)
  return DigraphCons(IsMutableDigraph, rec(DigraphNrVertices := N,
                                           DigraphSource     := src,
                                           DigraphRange      := ran));
end);

InstallMethod(DigraphCons,
"for IsMutableDigraph, a list of vertices, source, and range",
[IsMutableDigraph, IsList, IsList, IsList],
function(_, domain, src, ran)
  local D;
  D := DigraphCons(IsMutableDigraph, rec(DigraphVertices := domain,
                                         DigraphSource   := src,
                                         DigraphRange    := ran));
  SetDigraphVertexLabels(D, domain);
  return D;
end);

InstallMethod(DigraphCons, "for IsImmutableDigraph and a record",
[IsImmutableDigraph, IsRecord],
function(_, record)
  local D;
  D := MakeImmutable(DigraphCons(IsMutableDigraph, record));
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
{_, list} -> MakeImmutable(DigraphCons(IsMutableDigraph, list)));

InstallMethod(DigraphCons, "for IsImmutableDigraph, a list, and function",
[IsImmutableDigraph, IsList, IsFunction],
function(_, list, func)
  local D;
  D := MakeImmutable(DigraphCons(IsMutableDigraph, list, func));
  SetDigraphAdjacencyFunction(D, {u, v} -> func(list[u], list[v]));
  SetFilterObj(D, IsDigraphWithAdjacencyFunction);
  SetDigraphVertexLabels(D, list);
  return D;
end);

InstallMethod(DigraphCons,
"for IsImmutableDigraph, a number of vertices, source, and range",
[IsImmutableDigraph, IsInt, IsList, IsList],
{_, N, src, ran}
-> MakeImmutable(DigraphCons(IsMutableDigraph, N, src, ran)));

InstallMethod(DigraphCons,
"for IsImmutableDigraph, a list of vertices, source, and range",
[IsImmutableDigraph, IsList, IsList, IsList],
{_, domain, src, ran} ->
MakeImmutable(DigraphCons(IsMutableDigraph, domain, src, ran)));

InstallMethod(Digraph, "for a filter and a record", [IsFunction, IsRecord],
DigraphCons);

InstallMethod(Digraph, "for a record", [IsRecord],
record -> DigraphCons(IsImmutableDigraph, record));

InstallMethod(Digraph, "for a filter and a list", [IsFunction, IsList],
DigraphCons);

InstallMethod(Digraph, "for a list", [IsList],
list -> DigraphCons(IsImmutableDigraph, list));

InstallMethod(Digraph, "for a filter, a list, and a function",
[IsFunction, IsList, IsFunction],
DigraphCons);

InstallMethod(Digraph, "for a list and a function", [IsList, IsFunction],
{list, func} -> DigraphCons(IsImmutableDigraph, list, func));

InstallMethod(Digraph, "for a filter, integer, list, and list",
[IsFunction, IsInt, IsList, IsList],
DigraphCons);

InstallMethod(Digraph, "for an integer, list, and list",
[IsInt, IsList, IsList],
{n, src, ran} -> DigraphCons(IsImmutableDigraph, n, src, ran));

InstallMethod(Digraph, "for a filter, list, list, and list",
[IsFunction, IsList, IsList, IsList],
DigraphCons);

InstallMethod(Digraph, "for a list, list, and list", [IsList, IsList, IsList],
{dom, src, ran} -> DigraphCons(IsImmutableDigraph, dom, src, ran));

InstallMethod(Digraph, "for a string naming a digraph", [IsString],
function(name)
  # edge case to avoid interfering with Digraph([])
  if name = "" then
    TryNextMethod();
  fi;

  # standardise string format to search database
  name := LowercaseString(name);
  RemoveCharacters(name, " \n\t\r");

  # load database if not already done
  DIGRAPHS_LoadNamedDigraphs();

  if not name in RecNames(DIGRAPHS_NamedDigraphs) then
    ErrorNoReturn("named digraph <name> not found; see ListNamedDigraphs,");
  fi;
  return DigraphFromDiSparse6String(DIGRAPHS_NamedDigraphs.(name));
end);

InstallMethod(ListNamedDigraphs,
"for a string and a pos int",
[IsString, IsPosInt],
function(s, level)
  local l, cands, func;
  # standardise request
  s := LowercaseString(s);
  RemoveCharacters(s, " \n\t\r");
  l := Length(s);

  # load database if not already done
  DIGRAPHS_LoadNamedDigraphs();

  # retrieve candidates
  cands := RecNames(DIGRAPHS_NamedDigraphs);
  if l = 0 then
    return cands;
  fi;

  # print warning if level higher than ones here that have methods
  if level > 3 then
    Info(InfoWarning, 1, "ListNamedDigraphs: second argument <level> is");
    Info(InfoWarning, 1, "greater than level of greatest flexibility.");
    Info(InfoWarning, 1, "Using <level> = 3 instead.");
    level := 3;
  fi;

  if level = 1 then
    func := c -> Length(c) >= l and c{[1 .. l]} = s;
  elif level = 2 then
    func := c -> PositionSublist(c, s) <> fail;
  else
    s := Filtered(s, x -> IsDigitChar(x) or IsAlphaChar(x));
    func := c -> PositionSublist(Filtered(c, x -> IsDigitChar(x) or
                                                  IsAlphaChar(x)), s) <> fail;
  fi;
  return Filtered(cands, func);
end);

# if search function called with no level, assume a substring search with
# special chars
InstallMethod(ListNamedDigraphs, "for a string", [IsString],
x -> ListNamedDigraphs(x, 2));

########################################################################
# 6. Printing, viewing, strings
########################################################################

InstallMethod(ViewString, "for a digraph", [IsDigraph],
function(D)
  local n, m, display_nredges, displayed_bipartite, str, x;

  n := DigraphNrVertices(D);
  m := DigraphNrEdges(D);
  display_nredges := true;
  displayed_bipartite := false;

  str := "<";
  if IsMutableDigraph(D) then
    Append(str, "mutable ");
  elif IsImmutableDigraph(D) then
    Append(str, "immutable ");
  fi;

  Assert(1, IsMutableDigraph(D) or IsImmutableDigraph(D));

  if m = 0 then
    if IsImmutableDigraph(D) then
      SetIsEmptyDigraph(D, true);
    fi;
    Append(str, "empty ");
    display_nredges := false;
  elif n > 1 then
    if HasIsCycleDigraph(D) and IsCycleDigraph(D) then
      Append(str, "cycle ");
      display_nredges := false;
    elif HasIsChainDigraph(D) and IsChainDigraph(D) then
      Append(str, "chain ");
      display_nredges := false;
    elif HasIsCompleteDigraph(D) and IsCompleteDigraph(D) then
      Append(str, "complete ");
      display_nredges := false;
    elif HasIsCompleteBipartiteDigraph(D) and IsCompleteBipartiteDigraph(D) then
      Append(str, "complete bipartite ");
      displayed_bipartite := true;
    elif HasIsCompleteMultipartiteDigraph(D)
        and IsCompleteMultipartiteDigraph(D) then
      Append(str, "complete multipartite ");
    elif HasIsLatticeDigraph(D) and IsLatticeDigraph(D) then
      Append(str, "lattice ");
    elif HasIsJoinSemilatticeDigraph(D) and IsJoinSemilatticeDigraph(D) then
      Append(str, "join semilattice ");
    elif HasIsMeetSemilatticeDigraph(D) and IsMeetSemilatticeDigraph(D) then
      Append(str, "meet semilattice ");
    elif HasIsUndirectedTree(D) and IsUndirectedTree(D) then
      Append(str, "undirected tree ");
      display_nredges := false;
    elif HasIsUndirectedForest(D) and IsUndirectedForest(D) then
      Append(str, "undirected forest ");
    elif HasIsDirectedTree(D) and IsDirectedTree(D) then
      Append(str, "directed tree ");
      display_nredges := false;
    else
      if HasIsEulerianDigraph(D) and IsEulerianDigraph(D) then
        Append(str, "Eulerian ");
        if HasIsHamiltonianDigraph(D) and IsHamiltonianDigraph(D) then
          Append(str, "and ");
        fi;
      fi;
      if HasIsHamiltonianDigraph(D) and IsHamiltonianDigraph(D) then
        Append(str, "Hamiltonian ");
      fi;
      if HasIsStronglyConnectedDigraph(D) and IsStronglyConnectedDigraph(D)
          and not (HasIsEulerianDigraph(D) and IsEulerianDigraph(D))
          and not (HasIsHamiltonianDigraph(D) and IsHamiltonianDigraph(D))
          and not (HasIsSymmetricDigraph(D) and IsSymmetricDigraph(D)) then
        Append(str, "strongly connected ");
      fi;
      if HasIsBiconnectedDigraph(D) and IsBiconnectedDigraph(D) then
        Append(str, "biconnected ");
      elif ((HasIsSymmetricDigraph(D) and IsSymmetricDigraph(D))
            or not (HasIsStronglyConnectedDigraph(D)
                    and IsStronglyConnectedDigraph(D)))
          and not (HasIsTournament(D) and IsTournament(D))
          and HasIsConnectedDigraph(D) and IsConnectedDigraph(D) then
        Append(str, "connected ");
      fi;
      if HasIsBipartiteDigraph(D) and IsBipartiteDigraph(D) then
        Append(str, "bipartite ");
        displayed_bipartite := true;
      fi;
      if HasIsEdgeTransitive(D) and IsEdgeTransitive(D) and
          HasIsVertexTransitive(D) and IsVertexTransitive(D) then
        Append(str, "edge- and vertex-transitive ");
      elif HasIsEdgeTransitive(D) and IsEdgeTransitive(D) then
        Append(str, "edge-transitive ");
      elif HasIsVertexTransitive(D) and IsVertexTransitive(D) then
        Append(str, "vertex-transitive ");
      elif HasIsRegularDigraph(D) and IsRegularDigraph(D) then
        Append(str, "regular ");
      elif HasIsOutRegularDigraph(D) and IsOutRegularDigraph(D) then
        Append(str, "out-regular ");
      elif HasIsInRegularDigraph(D) and IsInRegularDigraph(D) then
        Append(str, "in-regular ");
      fi;
      if HasIsAcyclicDigraph(D) and IsAcyclicDigraph(D) then
        Append(str, "acyclic ");
      elif HasIsPartialOrderDigraph(D) and IsPartialOrderDigraph(D) then
        Append(str, "partial order ");
      elif HasIsEquivalenceDigraph(D) and IsEquivalenceDigraph(D) then
        Append(str, "equivalence ");
      elif HasIsFunctionalDigraph(D) and IsFunctionalDigraph(D) then
        Append(str, "functional ");
        display_nredges := false;
      elif HasIsPreorderDigraph(D) and IsPreorderDigraph(D) then
        Append(str, "preorder ");
      else
        if HasIsReflexiveDigraph(D) and IsReflexiveDigraph(D) then
          Append(str, "reflexive ");
        fi;
        if HasIsSymmetricDigraph(D) and IsSymmetricDigraph(D) then
          Append(str, "symmetric ");
        elif HasIsAntisymmetricDigraph(D) and IsAntisymmetricDigraph(D)
            and not (HasIsTournament(D) and IsTournament(D)) then
          Append(str, "antisymmetric ");
        fi;
        if HasIsTransitiveDigraph(D) and IsTransitiveDigraph(D) then
          Append(str, "transitive ");
        fi;
      fi;
    fi;
  fi;

  if IsMultiDigraph(D) then
    Append(str, "multi");
  fi;

  if not (HasIsCycleDigraph(D) and IsCycleDigraph(D))
      and HasIsTournament(D) and IsTournament(D) and n > 1 then
    Append(str, "tournament ");
    display_nredges := false;
  else
    Append(str, "digraph ");
  fi;
  Append(str, "with ");

  if displayed_bipartite then
    x := List(DigraphBicomponents(D), Length);
    Append(str, "bicomponent sizes ");
    Append(str, String(x[1]));
    Append(str, " and ");
    Append(str, String(x[2]));
    Append(str, ">");
    return str;
  fi;

  Append(str, String(n));
  if n = 1 then
    Append(str, " vertex");
  else
    Append(str, " vertices");
  fi;
  if display_nredges then
    Append(str, ", ");
    Append(str, String(m));
    if m = 1 then
      Append(str, " edge");
    else
      Append(str, " edges");
    fi;
  fi;
  Append(str, ">");
  return str;
end);

InstallMethod(PrintString, "for a digraph", [IsDigraph], String);

InstallMethod(String, "for a digraph",
[IsDigraph],
function(D)
  local n, N, i, mut, streps, outnbs_rep, lengths, strings,
        out_neighbours_string, creators_streps, creators_props, props;
  if IsMutableDigraph(D) then
    mut := "IsMutableDigraph, ";
  else
    mut := "";
  fi;
  if IsSymmetricDigraph(D) and not DigraphHasLoops(D) then
    streps := [Graph6String, Sparse6String];
    creators_streps := ["DigraphFromGraph6String",
                        "DigraphFromSparse6String"];
  else
    streps := [Digraph6String, DiSparse6String];
    creators_streps := ["DigraphFromDigraph6String",
                        "DigraphFromDiSparse6String"];
  fi;
  streps  := List(streps, f -> f(D));
  strings := [];
  for n in [1 .. Length(streps)] do
    Add(strings, Concatenation(creators_streps[n], "(", mut, "\"",
                 ReplacedString(streps[n], "\\", "\\\\"), "\"", ")"));
  od;

  out_neighbours_string := String(OutNeighbours(D));
  # print empty lists with two spaces for consistency
  # see https://github.com/gap-system/gap/pull/5418
  out_neighbours_string := ReplacedString(out_neighbours_string, "[ ]", "[  ]");
  outnbs_rep := Concatenation("Digraph(", mut, out_neighbours_string, ")");
  Add(strings, String(outnbs_rep));

  N              := DigraphNrVertices(D);
  props          := [x -> IsCycleDigraph(x)
                          and x = CycleDigraph(DigraphNrVertices(x)),
                     IsCompleteDigraph,
                     x -> IsChainDigraph(x)
                          and x = ChainDigraph(DigraphNrVertices(x)),
                     IsEmptyDigraph];
  creators_props := ["CycleDigraph",
                     "CompleteDigraph",
                     "ChainDigraph",
                     "EmptyDigraph"];
  for i in [1 .. Length(props)] do
    if props[i](D) then
      Add(strings, Concatenation(creators_props[i], "(", mut, String(N), ")"));
    fi;
  od;

  lengths := List(strings, Length);
  return strings[Position(lengths, Minimum(lengths))];
end);

########################################################################
# 7. Operators
########################################################################

InstallMethod(\=, "for two digraphs", [IsDigraph, IsDigraph], DIGRAPH_EQUALS);

InstallMethod(\<, "for two digraphs", [IsDigraph, IsDigraph], DIGRAPH_LT);

########################################################################
# 8. Digraph by-something constructors
########################################################################

InstallMethod(DigraphByAdjacencyMatrixConsNC,
"for IsMutableDigraph and a homogeneous list",
[IsMutableDigraph, IsHomogeneousList],
function(_, mat)
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

  n := Length(mat);
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
function(_, mat)
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
{_, dummy} -> EmptyDigraph(IsMutableDigraph, 0));

InstallMethod(DigraphByAdjacencyMatrixCons,
"for IsImmutableDigraph and a homogeneous list",
[IsImmutableDigraph, IsHomogeneousList],
function(_, mat)
  local D;
  D := MakeImmutable(DigraphByAdjacencyMatrixCons(IsMutableDigraph, mat));
  if IsEmpty(mat) or IsInt(mat[1][1]) then
    SetAdjacencyMatrix(D, mat);
  else
    Assert(1, IsBool(mat[1][1]));
    SetBooleanAdjacencyMatrix(D, mat);
  fi;
  return D;
end);

InstallMethod(DigraphByAdjacencyMatrix, "for a function and a homogeneous list",
[IsFunction, IsHomogeneousList],
DigraphByAdjacencyMatrixCons);

InstallMethod(DigraphByAdjacencyMatrix, "for a homogeneous list",
[IsHomogeneousList],
mat -> DigraphByAdjacencyMatrixCons(IsImmutableDigraph, mat));

InstallMethod(DigraphByEdgesCons,
"for IsMutableDigraph, a list, and an integer",
[IsMutableDigraph, IsList, IsInt],
function(_, edges, n)
  local pos, list, edge;
  if IsEmpty(edges) then
    return NullDigraph(IsMutableDigraph, n);
  fi;
  pos := 0;
  for edge in edges do
    pos := pos + 1;
    if not IsList(edge) then
      ErrorNoReturn("the 1st argument (list of edges) must be a list of lists, ",
                    "but found ", TNAM_OBJ(edge), " in position ", pos);
    elif Length(edge) <> 2 then
      ErrorNoReturn("the 1st argument (list of edges) must be a list of lists ",
                    "of length 2, found ", edge, " (length ", Length(edge),
                    " in position ", pos, ")");
    elif not IsPosInt(edge[1]) or not IsPosInt(edge[2]) then
      ErrorNoReturn("the 1st argument (list of edges) must be pairs of ",
                    "positive integers but found ", edge, " in position ", pos);
    elif edge[1] > n or edge[2] > n then
      ErrorNoReturn("the 1st argument (list of edges) must be pairs of ",
                    "positive integers <= ", n, " but found ", edge,
                    " in position ", pos);
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
function(_, edges)
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
function(_, edges)
  local D;
  D := MakeImmutable(DigraphByEdges(IsMutableDigraph, edges));
  SetDigraphEdges(D, edges);
  SetDigraphNrEdges(D, Length(edges));
  return D;
end);

InstallMethod(DigraphByEdgesCons,
"for IsImmutableDigraph, a list, and an integer",
[IsImmutableDigraph, IsList, IsInt],
function(_, edges, n)
  local D;
  D := MakeImmutable(DigraphByEdges(IsMutableDigraph, edges, n));
  SetDigraphEdges(D, edges);
  SetDigraphNrEdges(D, Length(edges));
  return D;
end);

InstallMethod(DigraphByEdges, "for a list and an integer",
[IsList, IsInt],
{edges, n} -> DigraphByEdgesCons(IsImmutableDigraph, edges, n));

InstallMethod(DigraphByEdges, "for a list", [IsList],
edges -> DigraphByEdgesCons(IsImmutableDigraph, edges));

InstallMethod(DigraphByEdges, "for a function, a list, and an integer",
[IsFunction, IsList, IsInt], DigraphByEdgesCons);

InstallMethod(DigraphByEdges, "for a function and a list",
[IsFunction, IsList], DigraphByEdgesCons);

InstallMethod(DigraphByInNeighboursCons, "for IsMutableDigraph, and a list",
[IsMutableDigraph, IsList],
function(_, list)
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
function(_, list)
  local D;
  D := MakeImmutable(DigraphByInNeighboursCons(IsMutableDigraph, list));
  SetInNeighbours(D, list);
  return D;
end);

InstallMethod(DigraphByInNeighboursConsNC, "for IsMutableDigraph and a list",
[IsMutableDigraph, IsList],
{_, list} -> DigraphNC(IsMutableDigraph, DIGRAPH_IN_OUT_NBS(list)));

InstallMethod(DigraphByInNeighboursConsNC, "for IsImmutableDigraph and a list",
[IsImmutableDigraph, IsList],
function(_, list)
  local D;
  D := MakeImmutable(DigraphByInNeighboursConsNC(IsMutableDigraph, list));
  SetInNeighbours(D, list);
  return D;
end);

InstallMethod(DigraphByInNeighbours, "for a list", [IsList],
list -> DigraphByInNeighboursCons(IsImmutableDigraph, list));

InstallMethod(DigraphByInNeighbours, "for a function and a list",
[IsFunction, IsList],
DigraphByInNeighboursCons);

########################################################################
# 9. Converters to/from other types -> digraph . . .
########################################################################

InstallMethod(AsDigraphCons, "for IsMutableDigraph and a binary relation",
[IsMutableDigraph, IsBinaryRelation],
function(_, rel)
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
function(_, rel)
  local D;
  D := MakeImmutable(AsDigraph(IsMutableDigraph, rel));
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
rel -> AsDigraphCons(IsImmutableDigraph, rel));

InstallMethod(AsDigraph, "for a function and a binary relation",
[IsFunction, IsBinaryRelation], AsDigraphCons);

InstallMethod(AsDigraphCons,
"for IsMutableDigraph, a transformation, and an integer",
[IsMutableDigraph, IsTransformation, IsInt],
function(_, f, n)
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
function(_, f, n)
  local D;
  D := AsDigraph(IsMutableDigraph, f, n);
  if D <> fail then
    D := MakeImmutable(D);
    SetDigraphNrEdges(D, n);
    SetIsMultiDigraph(D, false);
    SetIsFunctionalDigraph(D, true);
  fi;
  return D;
end);

InstallMethod(AsDigraph, "for a function, a transformation, and an integer",
[IsFunction, IsTransformation, IsInt], AsDigraphCons);

InstallMethod(AsDigraph, "for a transformation and an integer",
[IsTransformation, IsInt],
{t, n} -> AsDigraphCons(IsImmutableDigraph, t, n));

InstallMethod(AsDigraph, "for a function and a transformation",
[IsFunction, IsTransformation],
{func, t} -> AsDigraphCons(func, t, DegreeOfTransformation(t)));

InstallMethod(AsDigraph, "for a transformation", [IsTransformation],
t -> AsDigraphCons(IsImmutableDigraph, t, DegreeOfTransformation(t)));

InstallMethod(AsDigraph, "for a function, a perm, and an integer",
[IsFunction, IsPerm, IsInt],
{func, p, n} -> AsDigraphCons(func, AsTransformation(p), n));

InstallMethod(AsDigraph, "for a perm and an integer",
[IsPerm, IsInt],
{p, n} -> AsDigraph(AsTransformation(p), n));

InstallMethod(AsDigraph, "for a function and a perm",
[IsFunction, IsPerm],
{func, p} -> AsDigraph(func, AsTransformation(p)));

InstallMethod(AsDigraph, "for a perm", [IsPerm],
p -> AsDigraph(AsTransformation(p)));

InstallMethod(AsDigraphCons,
"for IsMutableDigraph, a partial perm, and an integer",
[IsMutableDigraph, IsPartialPerm, IsInt],
function(_, f, n)
  local list, x, i;
  if n < 0 then
    ErrorNoReturn("the 2nd argument <n> should be a non-negative integer,");
  fi;

  list := EmptyPlist(n);
  for i in [1 .. n] do
    x := i ^ f;
    if x > n then
      return fail;
    elif x <> 0 then
      list[i] := [x];
    else
      list[i] := [];
    fi;
  od;
  return DigraphNC(IsMutableDigraph, list);
end);

InstallMethod(AsDigraphCons,
"for IsImmutableDigraph, a partial perm, and an integer",
[IsImmutableDigraph, IsPartialPerm, IsInt],
function(_, f, n)
  local D;
  D := AsDigraph(IsMutableDigraph, f, n);
  if D <> fail then
    D := MakeImmutable(D);
    SetIsMultiDigraph(D, false);
  fi;
  return D;
end);

InstallMethod(AsDigraph, "for a function, a partial perm, and an integer",
[IsFunction, IsPartialPerm, IsInt], AsDigraphCons);

InstallMethod(AsDigraph, "for a partial perm and an integer",
[IsPartialPerm, IsInt],
{t, n} -> AsDigraphCons(IsImmutableDigraph, t, n));

InstallMethod(AsDigraph, "for a function and a partial perm",
[IsFunction, IsPartialPerm],
{func, t} -> AsDigraphCons(func, t, Maximum(DegreeOfPartialPerm(t),
                                            CodegreeOfPartialPerm(t))));

InstallMethod(AsDigraph, "for a partial perm", [IsPartialPerm],
t -> AsDigraphCons(IsImmutableDigraph, t, Maximum(DegreeOfPartialPerm(t),
                                                  CodegreeOfPartialPerm(t))));

InstallMethod(AsBinaryRelation, "for a digraph", [IsDigraphByOutNeighboursRep],
function(D)
  local rel;
  if DigraphHasNoVertices(D) then
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
                         DigraphReverse(DigraphMutableCopyIfMutable(D)));
    fi;
    ErrorNoReturn("the 2nd argument <D> must be digraph that is a join or ",
                  "meet semilattice,");
  fi;

  D   := DigraphMutableCopyIfMutable(D);
  red := DigraphReflexiveTransitiveReduction(D);
  top := DigraphTopologicalSort(D);
  # im[i] will store the image of the idempotent partial perm corresponding to
  # vertex i of the argument <D>
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

InstallMethod(AsSemigroup,
"for a function, a digraph, and a dense list",
[IsFunction, IsDigraph, IsDenseList, IsDenseList],
function(filt, digraph, gps, homs)
  local red, n, hom_table, reps, rep, top, doms, starts, degs, max, gens, img,
  start, deg, x, queue, j, k, g, y, hom, edge, i, gen;

  if filt <> IsPartialPermSemigroup then
    TryNextMethod();
  elif not IsJoinSemilatticeDigraph(digraph) then
    if IsMeetSemilatticeDigraph(digraph) then
      return AsSemigroup(IsPartialPermSemigroup,
                         DigraphReverse(DigraphMutableCopyIfMutable(digraph)),
                         gps,
                         homs);
    else
      ErrorNoReturn("the second argument must be a join semilattice ",
                    "digraph or a meet semilattice digraph,");
    fi;
  elif not ForAll(gps, IsGroup) then
    ErrorNoReturn("the third argument must be a list of groups,");
  elif not Length(gps) = DigraphNrVertices(digraph) then
    ErrorNoReturn("the third argument must have length equal to the number ",
                  "of vertices in the second argument,");
  fi;

  digraph := DigraphMutableCopyIfMutable(digraph);
  red := DigraphReflexiveTransitiveReduction(digraph);
  MakeImmutable(digraph);
  if not Length(homs) = DigraphNrEdges(red) or
       not ForAll(homs, x -> Length(x) = 3 and
                             IsPosInt(x[1]) and
                             IsPosInt(x[2]) and
                             IsDigraphEdge(red, [x[1], x[2]]) and
                             IsGroupHomomorphism(x[3]) and
                             Source(x[3]) = gps[x[1]] and
                             Range(x[3]) = gps[x[2]]) then
    ErrorNoReturn("the third argument must be a list of triples [i, j, hom] ",
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
      ErrorNoReturn("the fourth argument must contain a triple [i, j, hom] ",
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
          if x <> y then
            ErrorNoReturn("the homomorphisms given must form a commutative",
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

########################################################################
# 10. Random digraphs
########################################################################

InstallMethod(RandomDigraphCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsInt],
{_, n}
-> RandomDigraphCons(IsMutableDigraph, n, Float(Random([0 .. n])) / n));

InstallMethod(RandomDigraphCons, "for IsMutableDigraph and an integer",
[IsImmutableDigraph, IsInt],
{_, n}
-> RandomDigraphCons(IsImmutableDigraph, n, Float(Random([0 .. n])) / n));

InstallMethod(RandomDigraphCons, "for IsHamiltonianDigraph and an integer",
[IsHamiltonianDigraph, IsInt],
{_, n}
-> RandomDigraphCons(IsHamiltonianDigraph, n, Float(Random([0 .. n])) / n));

InstallMethod(RandomDigraphCons, "for IsEulerianDigraph and an integer",
[IsEulerianDigraph, IsInt],
{_, n}
-> RandomDigraphCons(IsEulerianDigraph, n, Float(Random([0 .. n])) / n));

InstallMethod(RandomDigraphCons, "for IsConnectedDigraph and an integer",
[IsConnectedDigraph, IsInt],
{_, n}
-> RandomDigraphCons(IsConnectedDigraph, n, Float(Random([0 .. n])) / n));

InstallMethod(RandomDigraphCons, "for IsAcyclicDigraph and an integer",
[IsAcyclicDigraph, IsInt],
{_, n}
-> RandomDigraphCons(IsAcyclicDigraph, n, Float(Random([0 .. n])) / n));

InstallMethod(RandomDigraphCons, "for IsSymmetricDigraph and an integer",
[IsSymmetricDigraph, IsInt],
{_, n}
-> RandomDigraphCons(IsSymmetricDigraph, n, Float(Random([0 .. n])) / n));

InstallMethod(RandomDigraphCons,
"for IsMutableDigraph, an integer, and a rational",
[IsMutableDigraph, IsInt, IsRat],
{_, n, p} -> RandomDigraphCons(IsMutableDigraph, n, Float(p)));

InstallMethod(RandomDigraphCons,
"for IsImmutableDigraph, an integer, and a rational",
[IsImmutableDigraph, IsInt, IsRat],
{_, n, p} -> RandomDigraphCons(IsImmutableDigraph, n, Float(p)));

InstallMethod(RandomDigraphCons,
"for IsHamiltonianDigraph, an integer, and a rational",
[IsHamiltonianDigraph, IsInt, IsRat],
{_, n, p} -> RandomDigraphCons(IsHamiltonianDigraph, n, Float(p)));

InstallMethod(RandomDigraphCons,
"for IsEulerianDigraph, an integer, and a rational",
[IsEulerianDigraph, IsInt, IsRat],
{_, n, p} -> RandomDigraphCons(IsEulerianDigraph, n, Float(p)));

InstallMethod(RandomDigraphCons,
"for IsConnectedDigraph, an integer, and a rational",
[IsConnectedDigraph, IsInt, IsRat],
{_, n, p} -> RandomDigraphCons(IsConnectedDigraph, n, Float(p)));

InstallMethod(RandomDigraphCons,
"for IsStronglyConnectedDigraph, an integer, and a rational",
[IsStronglyConnectedDigraph, IsInt, IsRat],
{filt, n, p} -> RandomDigraphCons(IsStronglyConnectedDigraph, n, Float(p)));

InstallMethod(RandomDigraphCons,
"for IsAcyclicDigraph, an integer, and a rational",
[IsAcyclicDigraph, IsInt, IsRat],
{_, n, p} -> RandomDigraphCons(IsAcyclicDigraph, n, Float(p)));

InstallMethod(RandomDigraphCons,
"for IsSymmetricDigraph, an integer, and a rational",
[IsSymmetricDigraph, IsInt, IsRat],
{_, n, p} -> RandomDigraphCons(IsSymmetricDigraph, n, Float(p)));

InstallMethod(RandomDigraphCons,
"for IsMutableDigraph, a positive integer, and a float",
[IsMutableDigraph, IsPosInt, IsFloat],
function(_, n, p)
  if p < 0.0 or 1.0 < p then
    ErrorNoReturn("the 2nd argument <p> must be between 0 and 1,");
  fi;
  return DigraphNC(IsMutableDigraph, RANDOM_DIGRAPH(n, Int(p * 10000)));
end);

# This function takes an existing adjacency list after solely creating
# a Hamiltonian cycle or tree, and randomly adds edges between all
# remaining vertices in the graph.
BindGlobal("DIGRAPHS_FillOutGraph", function(n, p, adjacencyList)
    local vertices, probability, i, j;

    vertices := [1 .. n];
    probability := [0 .. 99];

    for i in vertices do
        for j in vertices do
            if (not (j in adjacencyList[i])) then
                 if Float(Random(probability) / 100) < p then
                    Add(adjacencyList[i], j);
                 fi;
            fi;
        od;
    od;

    return adjacencyList;
end);

InstallMethod(RandomDigraphCons,
"for IsHamiltonianDigraph, a positive integer, and a float",
[IsHamiltonianDigraph, IsPosInt, IsFloat],
function(_, n, p)
    local adjacencyList, vertices, i, startVertex, hamiltonianCycle, x, j;

    adjacencyList := EmptyPlist(n);

    vertices := [1 .. n];

    for i in vertices do
        Add(adjacencyList, []);
    od;

    # Edge Case
    if n = 1 then
        if Float(Random([0 .. 99]) / 100) < p then
            Add(adjacencyList[1], 1);
        fi;
        return DigraphNC(adjacencyList);
    fi;

    # Starting from a random vertex, we create a Hamiltonian cycle
    startVertex := Remove(vertices, Random(vertices));
    hamiltonianCycle := EmptyPlist(n);
    hamiltonianCycle[1] := startVertex;

    # While there are remaining n-1 vertices to be added to the Hamiltonian
    # cycle
    for x in [1 .. n - 1] do
        # Create a random edge from the last vertex in the cycle
        # to a random vertex not in the cycle
        i := hamiltonianCycle[x];
        j := Remove(vertices, Random([1 .. Length(vertices)]));
        Add(hamiltonianCycle, j);
        Add(adjacencyList[i], j);
    od;

    Add(adjacencyList[hamiltonianCycle[n]], startVertex);

    # Once we have created a Hamiltonian cycle, fill out the rest of the graph
    # with random edges according to p
    adjacencyList := DIGRAPHS_FillOutGraph(n, p, adjacencyList);

    return DigraphNC(adjacencyList);
end);

InstallMethod(RandomDigraphCons,
"for IsEulerianDigraph, a positive integer, and a float",
[IsEulerianDigraph, IsPosInt, IsFloat],
function(_, n, p)
    local adjacencyList, vertices, probability, startVertex, circuitVertex, i,
    continueCircuit, verticesToConsider, connectedVertices, verticesToCheck;

    adjacencyList := EmptyPlist(n);

    vertices := [1 .. n];
    probability := [0 .. 99];

    for i in vertices do
        Add(adjacencyList, []);
    od;

    # Edge Case
    if n = 1 then
        if Float(Random(probability) / 100) < p then
            Add(adjacencyList[1], 1);
        fi;
        return DigraphNC(adjacencyList);
    fi;

    # Starting from a random vertex, we create an Eulerian circuit
    startVertex := Random(vertices);
    circuitVertex := startVertex;
    continueCircuit := true;

    # This will keep track of the vertices left to consider when deciding
    # whether to extend the cycle. For example, if we want to extend from the
    # current circuitVertex, we can check - verticesToConsider[circuitVertex] -
    # to see which vertices it hasn't previously considered.
    verticesToConsider := EmptyPlist(n);
    for i in vertices do
        Add(verticesToConsider, [1 .. n]);
    od;

    # Eulerian graphs must be connected, so we store a list of connected
    # vertices and check if a vertex isn't in the list
    connectedVertices := [startVertex];

    while continueCircuit do
        while Length(verticesToConsider[circuitVertex]) > 0 do
            # From the remaining vertices to check, select a random one to see
            # if an edge will be added
            i := Random(verticesToConsider[circuitVertex]);
            Remove(verticesToConsider[circuitVertex],
            Position(verticesToConsider[circuitVertex], i));

            # Check that the edge doesn't already exist
            if (not (i in adjacencyList[circuitVertex])) then
                # First we guarantee that we get a connected graph by checking
                # if the vertex isn't already connected
                if (not (i in connectedVertices)) then
                    Add(adjacencyList[circuitVertex], i);
                    Add(connectedVertices, i);
                    circuitVertex := i;
                    break;
                elif Float(Random(probability) / 100) < p then
                    Add(adjacencyList[circuitVertex], i);
                    circuitVertex := i;
                    break;
                fi;
            fi;
        od;

        # If there are not more vertices to consider, we can end the circuit
        if Length(verticesToConsider[circuitVertex]) = 0 then
            continueCircuit := false;
        fi;
    od;

    # Finish the circuit by adding an edge back to the start vertex
    # (if it isn't already at the start vertex)
    if circuitVertex <> startVertex then
        # If an edge already exists between the finish vertex and the start
        # vertex, we must find another path to the start vertex to avoid
        # generating a multidigraph.
        while (startVertex in adjacencyList[circuitVertex]) do
            # Here we consider all possible edges again, including previously
            # rejected edges, to guarantee a path back to the start
            verticesToCheck := [1 .. n];
            while Length(verticesToCheck) > 0 do
                i := Remove(verticesToCheck,
                            Random([1 .. Length(verticesToCheck)]));
                if (not (i in adjacencyList[circuitVertex])) then
                    Add(adjacencyList[circuitVertex], i);
                    circuitVertex := i;
                    break;
                fi;
            od;
        od;
        Add(adjacencyList[circuitVertex], startVertex);
    fi;

    return DigraphNC(adjacencyList);
end);

InstallMethod(RandomDigraphCons,
"for IsConnectedDigraph, a positive integer, and a float",
[IsConnectedDigraph, IsPosInt, IsFloat],
function(_, n, p)
    local adjacencyList, vertices, startVertex, tree, x, i, j;

    adjacencyList := EmptyPlist(n);

    vertices := [1 .. n];

    for i in vertices do
        Add(adjacencyList, []);
    od;

    # Starting from a random vertex, we first create a tree to guarantee
    # connectivity
    startVertex := Remove(vertices, Random(vertices));
    tree := [startVertex];

    # While there are n-1 remaining vertices to be added to the tree
    for x in [1 .. n - 1] do
        # Create an edge from a random vertex in the tree, to a random vertex
        # outside of it
        i := Random(tree);
        j := Remove(vertices, Random([1 .. Length(vertices)]));
        Add(tree, j);
        Add(adjacencyList[i], j);
    od;

    # Once the tree has been created, we fill out the rest of the graph with
    # random edges according to p
    adjacencyList := DIGRAPHS_FillOutGraph(n, p, adjacencyList);
    return DigraphNC(adjacencyList);
end);

InstallMethod(RandomDigraphCons,
"for IsStronglyConnectedDigraph, a positive integer, and a float",
[IsStronglyConnectedDigraph, IsPosInt, IsFloat],
function(_, n, p)
  local d, adjMatrix, stronglyConnectedComponents,
  scc_a, scc_b, i, random_u, random_v;

  d := RandomDigraph(n, p);

  stronglyConnectedComponents := DigraphStronglyConnectedComponents(d);

  adjMatrix := AdjacencyMatrixMutableCopy(d);

  for i in [1 .. Size(stronglyConnectedComponents.comps) - 1] do
      scc_a := stronglyConnectedComponents.comps[i];
      scc_b := stronglyConnectedComponents.comps[i + 1];

      # add a connection from u to v
      random_u := Random(scc_a);
      random_v := Random(scc_b);

      adjMatrix[random_u][random_v] := 1;
  od;

  # connect end scc to first scc
  scc_a := stronglyConnectedComponents.comps[
    Size(stronglyConnectedComponents.comps)];
  scc_b := stronglyConnectedComponents.comps[1];

  # add a connection from u to v
  random_u := Random(scc_a);
  random_v := Random(scc_b);

  adjMatrix[random_u][random_v] := 1;

  return DigraphByAdjacencyMatrix(adjMatrix);
end);

InstallMethod(RandomDigraphCons,
"for IsAcyclicDigraph, a positive integer, and a float",
[IsAcyclicDigraph, IsPosInt, IsFloat],
function(_, n, p)
    local adjacencyList, vertices, probability, i, j;

    adjacencyList := EmptyPlist(n);

    vertices := [1 .. n];
    probability := [0 .. 99];

    for i in vertices do
        Add(adjacencyList, []);
    od;

    # We shuffle the vertices and treat the order of the vertices as a
    # hierarchy where all vertices to the right of a vertex in the list are
    # potential edges. This idea is that the edges flow downwards in the
    # hierarchy, avoiding cycles.
    Shuffle(vertices);

    # From position i in the list, we consider all vertices j to the right of i
    for i in vertices do
        for j in [i + 1 .. n] do
            if Float(Random(probability) / 100) < p then
                Add(adjacencyList[vertices[i]], vertices[j]);
            fi;
        od;
    od;

    return DigraphNC(adjacencyList);
end);

InstallMethod(RandomDigraphCons,
"for IsSymmetricDigraph, a positive integer, and a float",
[IsSymmetricDigraph, IsPosInt, IsFloat],
function(_, n, p)
    local adjacencyList, vertices, probability, i, j;

    adjacencyList := EmptyPlist(n);

    vertices := [1 .. n];
    probability := [0 .. 99];

    for i in vertices do
        Add(adjacencyList, []);
    od;

    for i in vertices do
        for j in [i .. n] do
            if Float(Random(probability) / 100) < p then
                # If it's a self-loop, only add one edge otherwise we would
                # have a multi-edge.
                if i = j then
                    Add(adjacencyList[i], j);
                else
                    Add(adjacencyList[i], j);
                    Add(adjacencyList[j], i);
                fi;
            fi;
        od;
    od;

    return DigraphNC(adjacencyList);
end);

InstallMethod(RandomDigraphCons,
"for IsImmutableDigraph, a positive integer, and a float",
[IsImmutableDigraph, IsPosInt, IsFloat],
function(_, n, p)
  local D;
  D := MakeImmutable(RandomDigraphCons(IsMutableDigraph, n, p));
  SetIsMultiDigraph(D, false);
  return D;
end);

InstallMethod(RandomDigraph, "for a pos int", [IsPosInt],
n -> RandomDigraphCons(IsImmutableDigraph, n));

InstallMethod(RandomDigraph, "for a pos int and a rational", [IsPosInt, IsRat],
{n, p} -> RandomDigraphCons(IsImmutableDigraph, n, p));

InstallMethod(RandomDigraph, "for a pos int and a float", [IsPosInt, IsFloat],
{n, p} -> RandomDigraphCons(IsImmutableDigraph, n, p));

InstallMethod(RandomDigraph, "for a func and a pos int", [IsFunction, IsPosInt],
RandomDigraphCons);

InstallMethod(RandomDigraph, "for a func, a pos int, and a rational",
[IsFunction, IsPosInt, IsRat], RandomDigraphCons);

InstallMethod(RandomDigraph, "for a func, a pos int, and a float",
[IsFunction, IsPosInt, IsFloat], RandomDigraphCons);

InstallMethod(RandomMultiDigraph, "for a pos int", [IsPosInt],
n -> RandomMultiDigraph(n, Random([1 .. (n * (n - 1)) / 2])));

InstallMethod(RandomMultiDigraph, "for two pos ints", [IsPosInt, IsPosInt],
{n, m} -> DigraphNC(RANDOM_MULTI_DIGRAPH(n, m)));

InstallMethod(RandomTournamentCons, "for IsMutableDigraph and an integer",
[IsMutableDigraph, IsInt],
function(_, n)
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
function(_, n)
  local D;
  D := MakeImmutable(RandomTournamentCons(IsMutableDigraph, n));
  SetIsTournament(D, true);
  SetIsMultiDigraph(D, false);
  SetIsSymmetricDigraph(D, n <= 1);
  SetIsEmptyDigraph(D, n <= 1);
  SetDigraphHasLoops(D, false);
  SetDigraphNrEdges(D, Binomial(n, 2));
  return D;
end);

InstallMethod(RandomTournament, "for an integer", [IsInt],
n -> RandomTournamentCons(IsImmutableDigraph, n));

InstallMethod(RandomTournament, "for a func and an integer",
[IsFunction, IsInt], {func, n} -> RandomTournamentCons(func, n));

InstallMethod(RandomLatticeCons, "for IsMutableDigraph and a pos int",
[IsMutableDigraph, IsPosInt],
function(_, n)
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
function(_, n)
  local D;
  D := MakeImmutable(RandomLatticeCons(IsMutableDigraph, n));
  SetIsLatticeDigraph(D, true);
  return D;
end);

InstallMethod(RandomLattice, "for a pos int", [IsPosInt],
n -> RandomLatticeCons(IsImmutableDigraph, n));

InstallMethod(RandomLattice, "for a func and a pos int", [IsFunction, IsPosInt],
RandomLatticeCons);
