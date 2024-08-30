#############################################################################
##
##  cliques.gi
##  Copyright (C) 2015-19                                Markus Pfeiffer
##                                                       Raghav Mehra
##                                                       Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallMethod(CliqueNumber, "for a digraph", [IsDigraph],
D -> Maximum(List(DigraphMaximalCliquesReps(D), Length)));

InstallMethod(IsIndependentSet,
"for a digraph by out-neighbours and a homogeneous list",
[IsDigraphByOutNeighboursRep, IsHomogeneousList],
function(D, list)
  local x;
  if not IsDuplicateFreeList(list)
      or not ForAll(list, x -> x in DigraphVertices(D)) then
    ErrorNoReturn("the 2nd argument <list> must be a duplicate-free list of ",
                  "vertices of the digraph <D> that is the 1st argument,");
  fi;
  for x in list do
    if not IsSubset([x], Intersection(OutNeighboursOfVertex(D, x), list)) then
      return false;
    fi;
  od;
  return true;
end);

InstallMethod(IsMaximalIndependentSet,
"for a digraph by out-neighbours and a homogeneous list",
[IsDigraphByOutNeighboursRep, IsHomogeneousList],
function(D, set)
  local nbs, vtx, try, i;

  if not IsIndependentSet(D, set) then
    return false;
  fi;

  nbs := OutNeighbours(D);
  vtx := DigraphVertices(D);
  try := Difference(vtx, set);
  i := 0;
  while i < Length(set) and not IsEmpty(try) do
    i := i + 1;
    try := Intersection(try, Difference(vtx, nbs[set[i]]));
  od;

  if IsEmpty(try) then
    return true;
  fi;

  return not ForAny(try, x -> IsEmpty(Intersection(set, nbs[x])));
end);

InstallMethod(IsClique, "for a digraph by out-neighbours and a homogeneous list",
[IsDigraphByOutNeighboursRep, IsHomogeneousList],
function(D, clique)
  local nbs, v;
  if not IsDuplicateFreeList(clique)
      or not ForAll(clique, x -> x in DigraphVertices(D)) then
    ErrorNoReturn("the 2nd argument <clique> must be a duplicate-free list ",
                  "of vertices of the digraph <D> that is the 1st argument,");
  fi;
  nbs := OutNeighbours(D);
  for v in clique do
    if not ForAll(clique, x -> x = v or x in nbs[v]) then
      return false;
    fi;
  od;
  return true;
end);

InstallMethod(IsMaximalClique,
"for a digraph by out-neighbours and a homogeneous list",
[IsDigraphByOutNeighboursRep, IsHomogeneousList],
function(D, clique)
  local nbs, try, n, i;

  if not IsClique(D, clique) then
    return false;
  fi;

  nbs := OutNeighbours(D);
  try := DigraphVertices(D);
  n := Length(clique);
  i := 0;
  while i < n and Length(try) > 0 do
    i := i + 1;
    try := Intersection(try, nbs[clique[i]]);
  od;
  if IsSubset(clique, try) then
    return true;
  fi;

  return not ForAny(Difference(try, clique),
                    v -> ForAll(clique, x -> x = v or x in nbs[v]));
end);

################################################################################
# Independent sets
################################################################################

InstallGlobalFunction(DigraphMaximalIndependentSet,
function(arg...)
  if IsEmpty(arg) then
    ErrorNoReturn("at least 1 argument is required,");
  elif not IsDigraph(arg[1]) then
    ErrorNoReturn("the 1st argument must be a digraph,");
  fi;
  arg[1] := DigraphMutableCopyIfMutable(arg[1]);
  arg[1] := DigraphDual(DigraphRemoveAllMultipleEdges(arg[1]));
  return MakeImmutable(CallFuncList(DIGRAPHS_Clique,
                                    Concatenation([true],
                                                  [arg[1]],
                                                  arg{[2 .. Length(arg)]})));
end);

InstallGlobalFunction(DigraphIndependentSet,
function(arg...)
  if IsEmpty(arg) then
    ErrorNoReturn("at least 1 argument is required,");
  elif not IsDigraph(arg[1]) then
    ErrorNoReturn("the 1st argument must be a digraph,");
  fi;
  arg[1] := DigraphMutableCopyIfMutable(arg[1]);
  arg[1] := DigraphDual(DigraphRemoveAllMultipleEdges(arg[1]));
  return MakeImmutable(CallFuncList(DIGRAPHS_Clique,
                                    Concatenation([false],
                                                  [arg[1]],
                                                  arg{[2 .. Length(arg)]})));
end);

# Independent sets orbit representatives

InstallGlobalFunction(DigraphIndependentSetsReps,
function(arg...)
  if IsEmpty(arg) then
    ErrorNoReturn("at least 1 argument is required,");
  elif not IsDigraph(arg[1]) then
    ErrorNoReturn("the 1st argument must be a digraph,");
  fi;
  arg[1] := DigraphMutableCopyIfMutable(arg[1]);
  arg[1] := DigraphDual(DigraphRemoveAllMultipleEdges(arg[1]));
  return CallFuncList(DigraphCliquesReps, arg);
end);

# Independent sets

InstallMethod(DigraphIndependentSetsAttr, "for a digraph", [IsDigraph],
DigraphIndependentSets);

InstallGlobalFunction(DigraphIndependentSets,
function(arg...)
  local D, out;
  if IsEmpty(arg) then
    ErrorNoReturn("at least 1 argument is required,");
  elif not IsDigraph(arg[1]) then
    ErrorNoReturn("the 1st argument must be a digraph,");
  elif not IsBound(arg[2])
      and HasDigraphIndependentSetsAttr(arg[1]) then
    return DigraphIndependentSetsAttr(arg[1]);
  fi;
  D      := arg[1];
  arg[1] := DigraphMutableCopyIfMutable(arg[1]);
  arg[1] := DigraphDual(DigraphRemoveAllMultipleEdges(arg[1]));
  out    := CallFuncList(DigraphCliques, arg);
  # Store the result if appropriate
  if not IsBound(arg[2]) and IsImmutableDigraph(D) then
    SetDigraphIndependentSetsAttr(D, out);
  fi;
  return out;
end);

# Maximal independent sets orbit representatives

InstallMethod(DigraphMaximalIndependentSetsRepsAttr, "for a digraph",
[IsDigraph], DigraphMaximalIndependentSetsReps);

InstallGlobalFunction(DigraphMaximalIndependentSetsReps,
function(arg...)
  local out, D;
  if IsEmpty(arg) then
    ErrorNoReturn("at least 1 argument is required,");
  elif not IsDigraph(arg[1]) then
    ErrorNoReturn("the 1st argument must be a digraph,");
  elif not IsBound(arg[2])
      and HasDigraphMaximalIndependentSetsRepsAttr(arg[1]) then
    return DigraphMaximalIndependentSetsRepsAttr(arg[1]);
  fi;
  D      := arg[1];
  arg[1] := DigraphMutableCopyIfMutable(arg[1]);
  arg[1] := DigraphDual(DigraphRemoveAllMultipleEdges(arg[1]));
  out    := CallFuncList(DigraphMaximalCliquesReps, arg);
  # Store the result if appropriate
  if not IsBound(arg[2]) and IsImmutableDigraph(D) then
    SetDigraphMaximalIndependentSetsRepsAttr(D, out);
  fi;
  return out;
end);

# Maximal cliques

InstallMethod(DigraphMaximalIndependentSetsAttr, "for a digraph", [IsDigraph],
DigraphMaximalIndependentSets);

InstallGlobalFunction(DigraphMaximalIndependentSets,
function(arg...)
  local D, out;
  if IsEmpty(arg) then
    ErrorNoReturn("at least 1 argument is required,");
  elif not IsDigraph(arg[1]) then
    ErrorNoReturn("the 1st argument must be a digraph,");
  elif not IsBound(arg[2])
      and HasDigraphMaximalIndependentSetsAttr(arg[1]) then
    return DigraphMaximalIndependentSetsAttr(arg[1]);
  fi;
  D      := arg[1];
  arg[1] := DigraphMutableCopyIfMutable(arg[1]);
  arg[1] := DigraphDual(DigraphRemoveAllMultipleEdges(arg[1]));
  out := CallFuncList(DigraphMaximalCliques, arg);
  # Store the result if appropriate
  if not IsBound(arg[2]) and IsImmutableDigraph(D) then
    SetDigraphMaximalIndependentSetsAttr(D, out);
  fi;
  return out;
end);

################################################################################
# Cliques

InstallGlobalFunction(DigraphMaximalClique,
function(arg...)
  if IsEmpty(arg) then
    ErrorNoReturn("at least 1 argument is required,");
  fi;
  return MakeImmutable(CallFuncList(DIGRAPHS_Clique,
                                    Concatenation([true], arg)));
end);

InstallGlobalFunction(DigraphClique,
function(arg...)
  if IsEmpty(arg) then
    ErrorNoReturn("at least 1 argument is required,");
  fi;
  return MakeImmutable(CallFuncList(DIGRAPHS_Clique,
                                    Concatenation([false], arg)));
end);

InstallGlobalFunction(DIGRAPHS_Clique,
function(arg...)
  local maximal, D, include, exclude, size, out, try, include_copy, v;

  maximal := arg[1];

  # Validate arg[2]
  D := arg[2];
  if not IsDigraphByOutNeighboursRep(D) then
    ErrorNoReturn("the 1st argument <D> must be a digraph by out-neighbours,");
  fi;

  # Validate arg[3]
  if IsBound(arg[3]) then
    include := arg[3];
    if not IsHomogeneousList(include) or not IsDuplicateFreeList(include)
        or not IsSubset(DigraphVertices(D), include) then
      ErrorNoReturn("the optional 2nd argument <include> must be a ",
                    "duplicate-free list of vertices of the digraph <D> ",
                    "that is the 1st argument,");
    fi;
  else
    include := [];
  fi;

  # Validate arg[4]
  if IsBound(arg[4]) then
    exclude := arg[4];
    if not IsHomogeneousList(exclude) or not IsDuplicateFreeList(exclude)
        or not IsSubset(DigraphVertices(D), exclude) then
      ErrorNoReturn("the optional 3rd argument <exclude> must be a ",
                    "duplicate-free list of vertices of the digraph <D> ",
                    "that is the 1st argument,");
    fi;
  else
    exclude := [];
  fi;

  # Validate arg[5]
  if IsBound(arg[5]) then
    size := arg[5];
    if not IsPosInt(size) then
      ErrorNoReturn("the optional 4th argument <size> must be a positive ",
                    "integer,");
    fi;
  fi;

  if not IsClique(D, include) then
    return fail;
  elif not IsEmpty(Intersection(include, exclude)) then
    return fail;
  fi;

  # Perform 4-argument version of the function
  if IsBound(size) then
    if maximal then
      out := DigraphMaximalCliques(D, include, exclude, 1, size);
    else
      out := DigraphCliques(D, include, exclude, 1, size);
    fi;
    if IsEmpty(out) then
      return fail;
    fi;
    return out[1];
  fi;

  # Perform 3-argument version if maximal = true
  if IsBound(arg[4]) and maximal then
    out := DigraphMaximalCliques(D, include, exclude, 1);
    if IsEmpty(out) then
      return fail;
    fi;
    return out[1];
  fi;

  # Do a greedy search to find a clique of <D> containing <include> and
  # excluding <exclude> (which is necessarily maximal if <exclude> is empty)
  D := MaximalSymmetricSubdigraph(DigraphMutableCopyIfMutable(D));
  out := OutNeighbours(D);
  try := Difference(DigraphVertices(D), Concatenation(include, exclude));
  include_copy := ShallowCopy(include);

  while not IsEmpty(include_copy) and not IsEmpty(try) do
    v := Remove(include_copy);
    try := Intersection(try, out[v]);
  od;

  while not IsEmpty(try) do
    v := Remove(try);
    Add(include, v);
    try := Intersection(try, out[v]);
  od;
  return include;
end);

# Cliques orbit representatives

InstallGlobalFunction(DigraphCliquesReps,
function(arg...)
  local D, include, exclude, limit, size;

  if IsEmpty(arg) then
    ErrorNoReturn("there must be at least 1 argument,");
  fi;

  D := arg[1];

  if IsBound(arg[2]) then
    include := arg[2];
  else
    include := [];
  fi;

  if IsBound(arg[3]) then
    exclude := arg[3];
  else
    exclude := [];
  fi;

  if IsBound(arg[4]) then
    limit := arg[4];
  else
    limit := infinity;
  fi;

  if IsBound(arg[5]) then
    size := arg[5];
  else
    size := fail;
  fi;

  return CliquesFinder
          (D, fail, [], limit, include, exclude, false, size, true);
end);

# Cliques

InstallMethod(DigraphCliquesAttr, "for a digraph", [IsDigraph],
DigraphCliques);

InstallGlobalFunction(DigraphCliques,
function(arg...)
  local D, include, exclude, limit, size, out;

  if IsEmpty(arg) then
    ErrorNoReturn("there must be at least 1 argument,");
  fi;

  D := arg[1];

  if IsBound(arg[2]) then
    include := arg[2];
  else
    include := [];
  fi;

  if IsBound(arg[3]) then
    exclude := arg[3];
  else
    exclude := [];
  fi;

  if IsBound(arg[4]) then
    limit := arg[4];
  else
    limit := infinity;
  fi;

  if IsBound(arg[5]) then
    size := arg[5];
  else
    size := fail;
  fi;

  # use cached value is not special case due to exclusion / size / etc.
  if IsList(include) and IsEmpty(include) and IsList(exclude)
      and IsEmpty(exclude) and limit = infinity and size = fail
      and HasDigraphCliquesAttr(D) then
    return DigraphCliquesAttr(D);
  fi;

  out := CliquesFinder(D, fail, [], limit, include, exclude, false, size, false);
  # Store the result if appropriate (not special case due to params)
  if IsEmpty(include) and IsEmpty(exclude) and limit = infinity and size = fail
      and IsImmutableDigraph(D) then
    SetDigraphCliquesAttr(D, out);
  fi;
  return out;
end);

# Maximal cliques orbit representatives

InstallMethod(DigraphMaximalCliquesRepsAttr, "for a digraph", [IsDigraph],
DigraphMaximalCliquesReps);

InstallGlobalFunction(DigraphMaximalCliquesReps,
function(arg...)
  local D, include, exclude, limit, size, out;

  if IsEmpty(arg) then
    ErrorNoReturn("there must be at least 1 argument,");
  fi;

  D := arg[1];

  if IsBound(arg[2]) then
    include := arg[2];
  else
    include := [];
  fi;

  if IsBound(arg[3]) then
    exclude := arg[3];
  else
    exclude := [];
  fi;

  if IsBound(arg[4]) then
    limit := arg[4];
  else
    limit := infinity;
  fi;

  if IsBound(arg[5]) then
    size := arg[5];
  else
    size := fail;
  fi;

  if IsList(include) and IsEmpty(include) and IsList(exclude)
      and IsEmpty(exclude) and limit = infinity and size = fail
      and HasDigraphMaximalCliquesRepsAttr(D) then
    return DigraphMaximalCliquesRepsAttr(D);
  fi;

  out := CliquesFinder(D, fail, [], limit, include, exclude, true, size, true);
  # Store the result if appropriate
  if IsEmpty(include) and IsEmpty(exclude) and limit = infinity and size = fail
      and IsImmutableDigraph(D) then
    SetDigraphMaximalCliquesRepsAttr(D, out);
  fi;
  return out;
end);

# Maximal cliques

InstallMethod(DigraphMaximalCliquesAttr, "for a digraph", [IsDigraph],
DigraphMaximalCliques);

InstallGlobalFunction(DigraphMaximalCliques,
function(arg...)
  local D, include, exclude, limit, size, cliques, sub, G, out, orbits, c;

  if IsEmpty(arg) then
    ErrorNoReturn("there must be at least 1 argument,");
  fi;

  D := arg[1];

  if IsBound(arg[2]) then
    include := arg[2];
  else
    include := [];
  fi;

  if IsBound(arg[3]) then
    exclude := arg[3];
  else
    exclude := [];
  fi;

  if IsBound(arg[4]) then
    limit := arg[4];
  else
    limit := infinity;
  fi;

  if IsBound(arg[5]) then
    size := arg[5];
  else
    size := fail;
  fi;

  if IsList(include) and IsEmpty(include) and IsList(exclude) and
      IsEmpty(exclude) and limit = infinity and size = fail then
    if HasDigraphMaximalCliquesAttr(D) then
      return DigraphMaximalCliquesAttr(D);
    fi;
    cliques := DigraphMaximalCliquesReps(D);
    sub := DigraphMutableCopyIfMutable(D);
    sub := MaximalSymmetricSubdigraphWithoutLoops(sub);
    G := AutomorphismGroup(sub);
    if IsTrivial(G) then
      out := cliques;
    else
      # Act on the representatives to find all
      orbits := HashMap();
      for c in cliques do
        if not c in orbits then
          DIGRAPHS_AddOrbitToHashMap(G, c, orbits);
        fi;
      od;
      out := Keys(orbits);
    fi;
    if IsImmutableDigraph(D) then
      SetDigraphMaximalCliquesAttr(D, out);
    fi;
    return MakeImmutable(out);
  fi;

  return CliquesFinder(D, fail, [], limit, include, exclude, true, size, false);
end);

# A wrapper for DigraphsCliquesFinder
# This is very hacky at the moment, so we could test C code with GAP tests
InstallGlobalFunction(CliquesFinder,
function(digraph, hook, user_param, limit, include, exclude, max, size, reps)
  local n, subgraph, group, vertices, include_variant, exclude_variant,
        invariant_include, include_invariant, invariant_exclude,
        exclude_invariant, x, v, o, i, out, found_orbits, num_found,
        hook_wrapper;

  if not IsDigraph(digraph) then
    ErrorNoReturn("the 1st argument <D> must be a digraph,");
  elif hook <> fail then
    if not (IsFunction(hook) and NumberArgumentsFunction(hook) = 2) then
      ErrorNoReturn("the 2nd argument <hook> must be fail, or a ",
                    "function with 2 arguments,");
    fi;
  elif not IsList(user_param) then
    ErrorNoReturn("when the 2nd argument <hook> is fail, the 3rd ",
                  "argument <user_param> must be a list,");
  fi;

  if limit <> infinity and not IsPosInt(limit) then
    ErrorNoReturn("the 4th argument <limit> must be infinity, or ",
                  "a positive integer,");
  fi;

  n := DigraphNrVertices(digraph);
  if not (IsHomogeneousList(include)
          and ForAll(include, x -> IsPosInt(x) and x <= n)
          and IsDuplicateFreeList(include))
      or not (IsHomogeneousList(exclude)
              and ForAll(exclude, x -> IsPosInt(x) and x <= n)
              and IsDuplicateFreeList(exclude))
      then
    ErrorNoReturn("the 5th argument <include> and the 6th argument ",
                  "<exclude> must be (possibly empty) duplicate-free ",
                  "lists of vertices of the 1st argument <D>");
  fi;

  if not max in [true, false] then
    ErrorNoReturn("the 7th argument <max> must be true or false,");
  elif size <> fail and not IsPosInt(size) then
    ErrorNoReturn("the 8th argument <size> must be fail, or a ",
                  "positive integer,");
  elif not reps in [true, false] then
    ErrorNoReturn("the 9th argument <reps> must be true or false,");
  fi;

  subgraph := DigraphMutableCopyIfMutable(digraph);
  subgraph := MaximalSymmetricSubdigraphWithoutLoops(subgraph);
  group := AutomorphismGroup(subgraph);

  # Investigate whether <include> and <exclude> are invariant under <group>
  vertices := DigraphVertices(digraph);
  include_variant := BlistList(vertices, []);
  exclude_variant := BlistList(vertices, []);
  invariant_include := true;
  include_invariant := include;
  invariant_exclude := true;
  exclude_invariant := exclude;

  if not IsTrivial(group)
      and (not IsEmpty(include) or not IsEmpty(exclude)) then
    if not ForAll(GeneratorsOfGroup(group),
                  x -> IsSubset(include, OnTuples(include, x))) then
      invariant_include := false;
      include_invariant := [];
      if not reps then
        x := ShallowCopy(include);
        while not IsEmpty(x) do
          v := x[1];
          o := List(Orbit(group, v));
          i := Intersection(x, o);
          if not IsSubset(x, o) then
            UniteBlist(include_variant, BlistList(vertices, i));
          else
            Append(include_invariant, i);
          fi;
          x := Difference(x, i);
        od;
      fi;
    fi;
    if not ForAll(GeneratorsOfGroup(group),
                  x -> IsSubset(exclude, OnTuples(exclude, x))) then
      invariant_exclude := false;
      exclude_invariant := [];
      if not reps then
        x := ShallowCopy(exclude);
        while not IsEmpty(x) do
          v := x[1];
          o := List(Orbit(group, v));
          i := Intersection(x, o);
          if not IsSubset(x, o) then
            UniteBlist(exclude_variant, BlistList(vertices, i));
          else
            Append(exclude_invariant, i);
          fi;
          x := Difference(x, i);
        od;
      fi;
    fi;

    if reps and not (invariant_include and invariant_exclude) then
      ErrorNoReturn("if the 9th argument <reps> is true, then the 4th and ",
                    "5th arguments <include> and <exclude> must be ",
                    "invariant under the action of the automorphism group of ",
                    "the maximal symmetric subdigraph without loops,");
    fi;
  fi;

  if DigraphNrVertices(digraph) < 512 then
    if reps then

      if hook = fail then
        hook_wrapper := fail;
      else
        hook_wrapper := function(usr_param, clique)
          hook(usr_param, clique);
          return 1;
        end;
      fi;

      out := DigraphsCliquesFinder(subgraph,
                                   hook_wrapper,
                                   user_param,
                                   limit,
                                   include,
                                   exclude,
                                   max,
                                   size);
      return MakeImmutable(out);
    else

      # Function to find the valid cliques of an orbit given an orbit rep
      found_orbits := HashMap();
      num_found := 0;
      if hook = fail then
        hook := Add;
      fi;

      hook_wrapper := function(usr_param, clique)
        local orbit, n, new_found, i;

        new_found := 0;
        if not clique in found_orbits then
          orbit := DIGRAPHS_AddOrbitToHashMap(group, clique, found_orbits);
          n := Length(orbit);

          if invariant_include and invariant_exclude then
            # we're not just looking for orbit reps, but inc and exc are
            # invariant so there is nothing extra to check
            new_found := Minimum(limit - num_found, n);
            for clique in orbit{[1 .. new_found]} do
              hook(usr_param, clique);
            od;
            num_found := num_found + new_found;
            return new_found;
          fi;

          if invariant_include then
            # Cliques in the orbit might contain forbidden vertices
            i := 0;
            while i < n and num_found < limit do
              i := i + 1;
              clique := BlistList(vertices, orbit[i]);
              if SizeBlist(IntersectionBlist(exclude_variant, clique)) = 0 then
                hook(usr_param, orbit[i]);
                num_found := num_found + 1;
                new_found := new_found + 1;
              fi;
            od;
          elif invariant_exclude then
            # Cliques in the orbit might not contain all required vertices
            i := 0;
            while i < n and num_found < limit do
              i := i + 1;
              clique := BlistList(vertices, orbit[i]);
              if IsSubsetBlist(clique, include_variant) then
                hook(usr_param, orbit[i]);
                num_found := num_found + 1;
                new_found := new_found + 1;
              fi;
            od;
          else
            # Cliques in the orbit might contain forbidden vertices and
            # might not contain all required vertices
            i := 0;
            while i < n and num_found < limit do
              i := i + 1;
              clique := BlistList(vertices, orbit[i]);
              if SizeBlist(IntersectionBlist(exclude_variant, clique)) = 0
                  and IsSubsetBlist(clique, include_variant) then
                hook(usr_param, orbit[i]);
                num_found := num_found + 1;
                new_found := new_found + 1;
              fi;
            od;
          fi;
        fi;
        return new_found;
      end;

      DigraphsCliquesFinder(subgraph,
                            hook_wrapper,
                            user_param,
                            limit,
                            include_invariant,
                            exclude_invariant,
                            max,
                            size);

      return MakeImmutable(user_param);
    fi;
  else
    include_variant := ListBlist(vertices, include_variant);
    exclude_variant := ListBlist(vertices, exclude_variant);

    out := DIGRAPHS_BronKerbosch(digraph,
                                 hook,
                                 user_param,
                                 limit,
                                 include,
                                 exclude,
                                 max,
                                 size,
                                 reps,
                                 include_variant,
                                 exclude_variant);
    return MakeImmutable(out);
  fi;
end);

InstallGlobalFunction(DIGRAPHS_BronKerbosch,
function(D, hook, param, lim, inc, exc, max, size, reps, inc_var, exc_var)
  local vtx, invariant_inc, invariant_exc, invariant, adj, exc_inv, start,
  possible, isolated, grp, found_orbits, add, bk, num, x, gen;

  # Arguments must be:
  # D   - a digraph
  # hook - fail or a function
  # user-param - a list or the 1st argument of hook
  # inc  - a duplicate-free list of vertices of <D>
  # exc  - a duplicate-free list of vertices of <D>
  # lim  - a positive integer or infinity
  # size - a positive integer
  # max  - do we care whether the results are maximal?
  # reps - do we want to return all valid results or orbit representatives?

  # Test for easy cases
  if size <> fail and Length(inc) > size then
    return [];
  elif not IsEmpty(Intersection(exc, inc)) then
    # the clique contains excluded vertices
    return [];
  elif size <> fail
      and size > DigraphNrVertices(D) - Length(exc) then
    # the desired clique size is too big
    return [];
  elif not IsClique(D, inc) then
    # the set we wish to extend is not a clique
    return [];
  fi;

  if hook = fail then
    hook := Add;
  fi;

  D := MaximalSymmetricSubdigraphWithoutLoops(DigraphMutableCopyIfMutable(D));
  MakeImmutable(D);
  vtx := DigraphVertices(D);

  invariant_inc := Length(inc_var) = 0;
  invariant_exc := Length(exc_var) = 0;
  invariant := invariant_inc and invariant_exc;

  adj := BooleanAdjacencyMatrix(D);

  # Variables
  # D    - a symmetric digraph without loops and multiple edges whose cliques
  #         coincide with those of the original digraph
  # adj   - boolean adjacency matrix of <D>
  # vtx   - DigraphVertices(D)
  # num   - number of results found so far
  # grp   - a perm group, a subgroup of the automorphism group of <D>
  # invariant_inc - is inc invariant under grp?
  # invariant_exc - is exc invariant under grp?
  # inc_var - the subset of inc whose orbit is not contained in inc
  # exc_var - the subset of exc whose orbit is not contained in exc
  # exc_inv - the subset of exc whose orbit is contained in exc

  ##############################################################################
  # Preparation, and processing of variables

  inc_var  := BlistList(vtx, inc_var);
  exc_var  := BlistList(vtx, exc_var);
  exc_inv  := DifferenceBlist(BlistList(vtx, exc), exc_var);
  start    := BlistList(vtx, inc);
  possible := BlistList(vtx, vtx);
  SubtractBlist(possible, start);
  for x in inc do
    IntersectBlist(possible, adj[x]);
  od;

  isolated := DigraphSources(D);  # sources = sinks = isolated vertices
  if reps and not IsEmpty(isolated) then
    # Optimisation for when there are isolated vertices
    grp := Group(());
    for gen in GeneratorsOfGroup(AutomorphismGroup(D)) do
      # Discard generators which act on the isolated points
      if not SmallestMovedPoint(gen) in isolated then
        grp := ClosureGroup(grp, gen);
      fi;
    od;
    SubtractBlist(possible, BlistList(vtx, isolated));
    possible[isolated[1]] := true;
  else
    grp := AutomorphismGroup(D);
  fi;

  found_orbits := HashMap();

  # Function to find the valid cliques of an orbit given an orbit rep
  add := function(c)
    local orb, n, i;

    c := ListBlist(vtx, c);
    if reps then  # we are only looking for orbit reps, so add the rep
      hook(param, c);
      num := num + 1;
      return;
    elif not c in found_orbits then
      orb := DIGRAPHS_AddOrbitToHashMap(grp, c, found_orbits);
      n := Length(orb);

      if invariant then  # we're not just looking for orbit reps, but inc and
                         # exc are invariant so there is nothing extra to check
        n := Minimum(lim - num, n);
        for c in orb{[1 .. n]} do
          hook(param, c);
        od;
        num := num + n;
        return;
      fi;

      if invariant_inc then
        # Cliques in the orbit might contain forbidden vertices
        i := 0;
        while i < n and num < lim do
          i := i + 1;
          c := BlistList(vtx, orb[i]);
          if SizeBlist(IntersectionBlist(exc_var, c)) = 0 then
            hook(param, orb[i]);
            num := num + 1;
          fi;
        od;
      elif invariant_exc then
        # Cliques in the orbit might not contain all required vertices
        i := 0;
        while i < n and num < lim do
          i := i + 1;
          c := BlistList(vtx, orb[i]);
          if IsSubsetBlist(c, inc_var) then
            hook(param, orb[i]);
            num := num + 1;
          fi;
        od;
      else
        # Cliques in the orbit might contain forbidden vertices
        # Cliques in the orbit might not contain all required vertices
        i := 0;
        while i < n and num < lim do
          i := i + 1;
          c := BlistList(vtx, orb[i]);
          if SizeBlist(IntersectionBlist(exc_var, c)) = 0
              and IsSubsetBlist(c, inc_var) then
            hook(param, orb[i]);
            num := num + 1;
          fi;
        od;
      fi;
    fi;
    return;
  end;

  # Main recursive function
  bk := function(c, try, ban, G, d)
    local orb, top, piv, m, to_try, C, g, v;

    # <c> is a new clique rep
    if d > 0 and not max and (size = fail or size = d) then
      # <c> has the desired size (if any) and we don't care about maximality
      add(c);
      if max or size <> fail then
        return;
      fi;
      # we continue if we're looking for all cliques, not just maximal

    elif SizeBlist(ban) = 0 and SizeBlist(try) = 0 then
      # <c> is a new maximal clique
      if (size = fail or size = d) then
        # <c> is a new maximal clique rep and it has the right size (if req)
        add(c);
        return;
      fi;
      return;
    fi;

    d := d + 1;
    if size <> fail and size < d then
      return;
    fi;

    # TODO should this come after choosing the pivot or before?
    # orb := ListBlist(vtx, UnionBlist(try, ban));
    # if not G = fail then
    #   orb := Orbits(G, orb);
    #   orb := List(orb, x -> x[1]);
    #   try_orb := IntersectionBlist(BlistList(vtx, orb), try);
    # else
    #   try_orb := ShallowCopy(try);
    # fi;

    # If we are searching for *maximal* cliques then choose a pivot
    if max then
      # Choose a pivot: choose a vertex with maximum out-degree in try or ban
      # TODO optimise choice of pivot

      # Strategy 1: choose vertex in orb (try union ban, mod G) of max degree
      # top := -1;
      # piv := 0;
      # for v in orb do
      #   if deg[v] > top then # where #deg = OutDegrees(D)
      #     piv := v;
      #     top := deg[v];
      #   fi;
      # od;

      # Is this a better way of choosing a pivot?
      # Strategy 2: choose vertex in orb (try union ban, mod G) with max number
      #             of neighbours in try (try mod G)
      top := -1;
      piv := 0;
      for v in ListBlist(vtx, UnionBlist(try, ban)) do
        m := SizeBlist(IntersectionBlist(try, adj[v]));
        if m > top then
          piv := v;
          top := m;
        fi;
      od;

      to_try := ShallowCopy(ListBlist(vtx, DifferenceBlist(try, adj[piv])));
    else
      # If we are searching for cliques (not necessarily maximal) of a given
      # size then the logic of using a pivot doesn't work
      to_try := ListBlist(vtx, try);
    fi;

    if G <> fail then
      to_try := List(Orbits(G, to_try), x -> x[1]);
    fi;

    # Try to extend <c> and recurse
    for v in to_try do
      if not exc_inv[v] then  # We are allowed to add <v> to <c>
        C := ShallowCopy(c);
        C[v] := true;
        if G = fail then
          g := fail;
        else
          g := Stabilizer(G, v);  # Calculate the stabilizer of <v> in <G>
          if IsTrivial(g) then
            g := fail;  # Discard the group from this point as it is trivial
          fi;
        fi;
        bk(C, IntersectionBlist(try, adj[v]), IntersectionBlist(ban, adj[v]),
           g, d);  # Recurse
      fi;
      if lim = num then
        return;  # The limit of cliques has been reached
      fi;
      # need to prune the tree to prevent any repeated work:
      # do not need to search further for any cliques containing anything in
      # Orbit(G, v)
      if G = fail then
        try[v] := false;
        ban[v] := true;
      else
        orb := BlistList(vtx, Orbit(G, v));
        UniteBlist(ban, orb);
        SubtractBlist(try, orb);
      fi;
    od;
  end;
  num := 0;
  bk(start, possible, BlistList(vtx, []), grp, Length(inc));
  return param;
end);
