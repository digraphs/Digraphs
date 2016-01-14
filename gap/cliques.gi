#############################################################################
##
#W  cliques.gi
#Y  Copyright (C) 2015-16                                Markus Pfeiffer
##                                                       Raghav Mehra
##                                                       Wilf Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# IsIndependentSet: Check that the set is a duplicate-free subset of vertices
#                   and that no vertex is an out-neighbour of another.

InstallMethod(IsIndependentSet, "for a digraph and a homogeneous list",
[IsDigraph, IsHomogeneousList],
function(gr, set)
  if not IsDuplicateFreeList(set)
      or not ForAll(set, x -> x in DigraphVertices(gr)) then
    ErrorMayQuit("Digraphs: IsIndependentSet: usage,\n",
                 "the second argument <set> must be a duplicate-free list of ",
                 "vertices of the\ndigraph <gr>,");
  fi;
  return ForAll(set, x -> IsEmpty(Intersection(OutNeighboursOfVertex(gr, x),
                                               set)));
end);

# IsMaximalIndependentSet: Check that the set is indeed an independent set.
#                          Then repeatedly look through a vertex which is
#                          not out-neighbours of the set, and see whether it
#                          has an out-neighbour in the set.

InstallMethod(IsMaximalIndependentSet, "for a digraph and a homogeneous list",
[IsDigraph, IsHomogeneousList],
function(gr, set)
  local nbs, try, v;

  if not IsIndependentSet(gr, set) then
    return false;
  fi;

  nbs := Unique(Concatenation(List(set, v -> OutNeighboursOfVertex(gr, v))));
  nbs := Concatenation(nbs, set);
  try := Difference(DigraphVertices(gr), nbs);
  while not IsEmpty(try) do
    v := Remove(try);
    if IsEmpty(Intersection(set, OutNeighboursOfVertex(gr, v))) then
      return false;
    fi;
    try := Difference(try, OutNeighboursOfVertex(gr, v));
  od;
  return true;
end);

# IsClique: Check that the set is a duplicate-free subset of vertices
#           and that every vertex is an out-neighbour of the others.

InstallMethod(IsClique, "for a digraph and a homogeneous list",
[IsDigraph, IsHomogeneousList],
function(gr, clique)
  local nbs, v;

  if not IsDuplicateFreeList(clique)
      or not ForAll(clique, x -> x in DigraphVertices(gr)) then
    ErrorMayQuit("Digraphs: IsClique: usage,\n",
                 "the second argument <clique> must be a duplicate-free list ",
                 "of vertices of the\ndigraph <gr>,");
  fi;
  nbs := OutNeighbours(gr);
  for v in clique do
    if not ForAll(clique, x -> x = v or x in nbs[v]) then
      return false;
    fi;
  od;
  return true;
end);

# IsMaximalClique: Check that the set is indeed a clique.
#                  Then find the intersection of the out-neighbours of the
#                  vertices of the clique. If there are no vertices; it's a max
#                  clique. Otherwise check for any vertex whose out-neighbours
#                  include the clique: the clique is maximal if and only if
#                  there are no such vertices.

InstallMethod(IsMaximalClique, "for a digraph and a homogeneous list",
[IsDigraph, IsHomogeneousList],
function(gr, clique)
  local nbs, try, n, i;

  if not IsClique(gr, clique) then
    return false;
  fi;

  nbs := OutNeighbours(gr);
  try := DigraphVertices(gr);
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

# DigraphIndependentSet: Guaranteed to return a maximal clique if no third
#                        argument is supplied

# 1 argument version: equal results

InstallMethod(DigraphIndependentSet, "for a digraph",
[IsDigraph],
function(gr)
  return DigraphIndependentSet(gr, [], []);
end);

InstallMethod(DigraphMaximalIndependentSet, "for a digraph",
[IsDigraph],
function(gr)
  return DigraphIndependentSet(gr, [], []);
end);

# 2 argument version: equal results

InstallMethod(DigraphIndependentSet, "for a digraph and a homogeneous list",
[IsDigraph, IsHomogeneousList],
function(gr, set)
  return DigraphIndependentSet(gr, set, []);
end);

InstallMethod(DigraphMaximalIndependentSet,
"for a digraph and a homogeneous list",
[IsDigraph, IsHomogeneousList],
function(gr, set)
  return DigraphIndependentSet(gr, set, []);
end);

# 3 argument version: DigraphIndependentSet is not necessarily maximal

InstallMethod(DigraphIndependentSet, "for a digraph and two homogeneous lists",
[IsDigraph, IsHomogeneousList, IsHomogeneousList],
function(gr, set, exclude)
  local out, try, inn, v;

  # Verify the arguments
  if not IsDuplicateFreeList(set)
      or not ForAll(set, x -> x in DigraphVertices(gr)) then
    ErrorMayQuit("Digraphs: DigraphIndependentSet: usage,\n",
                 "the second argument <set> must be a duplicate-free list of ",
                 "vertices of the\ndigraph <gr>,");
  fi;
  exclude := Unique(exclude);
  if not ForAll(exclude, x -> x in DigraphVertices(gr)) then
    ErrorMayQuit("Digraphs: DigraphIndependentSet: usage,\n",
                 "the third argument <exclude> must be a list of vertices of ",
                 "the digraph <gr>,\n");
  fi;

  # Check that <set> and <exclude> are disjoint
  if not IsEmpty(Intersection(set, exclude)) then
    return fail;

  elif not IsIndependentSet(gr, set) then # Check that <set> is independent
    return fail;
  fi;

  # Try to extend the independent set
  try := Difference(DigraphVertices(gr), Concatenation(set, exclude));
  if not IsEmpty(try) then
    # Calculate InNeighbours for the efficiency of the following
    out := OutNeighbours(gr);
    inn := InNeighbours(gr);
  fi;

  while not IsEmpty(try) do
    v := Remove(try);
    if IsEmpty(Intersection(out[v], set))
        and IsEmpty(Intersection(inn[v], set)) then
      Add(set, v);
    fi;
  od;
end);

# 3 argument version: to ensure maximality, DigraphIndependentSet must use
#                     maximal clique code

InstallMethod(DigraphMaximalIndependentSet,
"for a digraph and two homogeneous lists",
[IsDigraph, IsHomogeneousList, IsHomogeneousList],
function(gr, set, exclude)
  ErrorMayQuit("Digraphs: DigraphMaximalIndependentSet: usage,\n",
               "not yet implemented,");
end);

################################################################################
################################################################################
################################################################################

InstallGlobalFunction(DIGRAPHS_BronKerbosch,
function(gr, include_invariant, include_variant, exclude_invariant, exclude_variant, limit, group, all)
  local recurse, mat, verts, degrees, clique_start, try_start, cliques, count,
  found, x, include;

  # Check that our initial `clique` is actually a clique
  include := Concatenation(include_invariant, include_variant);
  if not IsClique(gr, include) then
    return [];
  fi;

  # Main recursive algorithm
  recurse := function(clique, try_arg, forbid_arg, G)
    local try, forbid, trivial, orbits, try_blist, max, pivot, ptry, v,
    new_clique, H, orb, n;

    count := count + 1;
    trivial := G = fail or IsTrivial(G);

    # Has a maximal clique representative been found?
    if not ForAny(try_arg, x -> x) and not ForAny(forbid_arg, x -> x) then
      clique := ListBlist(verts, clique);

      if all then
        # We are returning *all* maximal cliques, not just representatives
        orb := Orbit(group, clique, OnSets);

        if not exclude_variant = fail or not include_variant = fail then
          # The orbit may contain forbidden vertices or
          # The orbit may not contain all the required vertices
          orb := List(orb);
          if not exclude_variant = fail and not include_variant = fail then
            while not IsEmpty(orb) and found < limit do
              clique := Remove(orb);
              if IsEmpty(Intersection(exclude_variant, clique))
                  and IsSubset(clique, include_variant) then
                Add(cliques, clique);
                found := found + 1;
              fi;
            od;
          elif not exclude_variant = fail then
            while not IsEmpty(orb) and found < limit do
              clique := Remove(orb);
              if IsEmpty(Intersection(exclude_variant, clique)) then
                Add(cliques, clique);
                found := found + 1;
              fi;
            od;
          else
            while not IsEmpty(orb) and found < limit do
              clique := Remove(orb);
              if IsSubset(clique, include_variant) then
                Add(cliques, clique);
                found := found + 1;
              fi;
            od;
          fi;
        else
          # limit < infinity so the orbit may give us too many results
          n := Minimum(limit - found, Length(orb));
          Append(cliques, orb{[1 .. n]});
          found := found + n;
        fi;
      else
        Add(cliques, clique);
        found := found + 1;
      fi;
      return;
    fi;

    try := ShallowCopy(try_arg);
    forbid := ShallowCopy(forbid_arg);
    if not trivial then
      orbits := Orbits(G, ListBlist(verts, try));
      try_blist := BlistList(verts, List(orbits, x -> x[1]));
    else
      try_blist := try;
    fi;

    # Choose a pivot: vertex with maximum outdegree
    #                 vertex with maximum outdegree amongst try might be
    #                 faster but is more expensive - perhaps take a sample?
    max := -1;
    pivot := 0;
    for v in ListBlist(verts, UnionBlist(try_blist, forbid)) do
      if degrees[v] > max then
        pivot := v;
        max := degrees[v];
      fi;
    od;

    # Try to extend clique
    ptry := ListBlist(verts, DifferenceBlist(try_blist, mat[pivot]));
    ptry := ShallowCopy(ptry);
    while not IsEmpty(ptry) do
      v := Remove(ptry);
      new_clique := ShallowCopy(clique);
      new_clique[v] := true;
      if trivial then
        H := fail;
      else
        H := Stabilizer(G, v);
      fi;
      # Are we allowed to add [v] to our clique?
      if not exclude_invariant[v] then
        recurse(new_clique,
                IntersectionBlist(try, mat[v]),
                IntersectionBlist(forbid, mat[v]),
                H);
      fi;
      try[v] := false;
      forbid[v] := true;
      # Have we found enough cliques?
      if limit = found then
        return;
      fi;
    od;
  end;

  if IsEmpty(include_variant) then
    include_variant := fail;
  fi;
  if IsEmpty(exclude_variant) then
    exclude_variant := fail;
  fi;
  mat := BooleanAdjacencyMatrix(gr);
  verts := DigraphVertices(gr);
  gr := MaximalSymmetricSubdigraphWithoutLoops(gr);
  degrees := OutDegrees(gr);

  # I need to check that the next 10 or so lines are correct
  # Prepare the initial sets
  clique_start := BlistList(verts, include);
  exclude_invariant := BlistList(verts, exclude_invariant);
  include_invariant := BlistList(verts, include_invariant);
  try_start := BlistList(verts, verts);
  SubtractBlist(try_start, clique_start);
  for x in include do
    IntersectBlist(try_start, mat[x]);
  od;

  cliques := [];
  count := 0;
  found := 0;
  recurse(clique_start, try_start, BlistList(verts, []), group);
  Print(count, " recursions, found ", found, " valid result\n");
  return cliques;
end);

InstallMethod(DigraphMaximalCliquesRepsAttr,
"for a digraph",
[IsDigraph],
function(gr)
  return DigraphMaximalCliquesReps(gr);
end);

InstallGlobalFunction(DigraphMaximalCliquesReps,
function(arg)
  local gr, G, include, exclude, limit;
  
  if IsEmpty(arg) then
    ErrorMayQuit("Digraphs: DigraphMaximalCliquesReps: usage,\n",
                 "this function takes at least one argument,");
  fi;

  # Validate arg[1]
  gr := arg[1];
  if not IsDigraph(gr) then
    ErrorMayQuit("Digraphs: DigraphMaximalCliquesReps: usage,\n",
                 "the first argument <gr> must be a digraph,");
  fi;

  #G := DigraphGroup(gr);
  G := AutomorphismGroup(gr);

  # Validate arg[2]
  if IsBound(arg[2]) then
    include := arg[2];
    if not IsHomogeneousList(include)
        or not IsDuplicateFreeList(include)
        or not IsSubset(DigraphVertices(gr), include)
        or not ForAll(GeneratorsOfGroup(G),
                      x -> IsSubset(OnTuples(include, x), include)) then
      ErrorMayQuit("Digraphs: DigraphMaximalCliquesReps: usage,\n",
                   "the optional second argument <include> must be a ",
                   "duplicate-free set of vertices\nof <gr> which is ",
                   "invariant under the action of the DigraphGroup <G>,");
    fi;
  elif HasDigraphMaximalCliquesRepsAttr(gr) then
    return DigraphMaximalCliquesRepsAttr(gr);
  else
    include := [];
  fi;

  # Validate arg[3]
  if IsBound(arg[3]) then
    exclude := arg[3];
    if not IsHomogeneousList(exclude)
        or not IsDuplicateFreeList(exclude)
        or not IsSubset(DigraphVertices(gr), exclude)
        or not ForAll(GeneratorsOfGroup(G),
                      x -> IsSubset(OnTuples(exclude, x), exclude)) then
      ErrorMayQuit("Digraphs: DigraphMaximalCliquesReps: usage,\n",
                   "the optional third argument <exclude> must be a ",
                   "duplicate-free set of verticies\nof <gr> which is ",
                   "invariant under the action of the DigraphGroup <G>,");
    fi;
  else
    exclude := [];
  fi;

  if not IsEmpty(Intersection(include, exclude)) then
    ErrorMayQuit("Digraphs: DigraphMaximalCliquesReps: usage,\n",
                 "the optional second and third arguments <include> and ",
                 "<exclude> must be disjoint,");
  fi;

  # Validate arg[4]
  if IsBound(arg[4]) then
    limit := arg[4];
    if limit <> infinity and not IsPosInt(limit) then
      ErrorMayQuit("Digraphs: DigraphMaximalCliquesReps: usage,\n",
                   "the optional fourth argument <limit> must be a positive ",
                   "integer or infinity,");
    fi;
  else
    limit := infinity;
  fi;

  return DIGRAPHS_BronKerbosch(gr, include, [], exclude, [], limit, G, false);
end);

# Maximal cliques

InstallMethod(DigraphMaximalCliquesAttr,
"for a digraph",
[IsDigraph],
function(gr)
  return DigraphMaximalCliques(gr);
end);

#

InstallGlobalFunction(DigraphMaximalCliques,
function(arg)
  local gr, G, include, reps, exclude, exclude_invariant, exclude_variant, v,
  orb, int, include_invariant, include_variant, limit, all, c;
  
  if IsEmpty(arg) then
    ErrorMayQuit("Digraphs: DigraphMaximalCliques: usage,\n",
                 "this function takes at least one argument,");
  fi;

  # Validate arg[1]
  gr := arg[1];
  if not IsDigraph(gr) then
    ErrorMayQuit("Digraphs: DigraphMaximalCliques: usage,\n",
                 "the first argument <gr> must be a digraph,");
  fi;

  #G := DigraphGroup(gr);
  G := AutomorphismGroup(gr);

  # Validate arg[2]
  if IsBound(arg[2]) then
    include := arg[2];
    if not IsHomogeneousList(include)
        or not IsDuplicateFreeList(include)
        or not IsSubset(DigraphVertices(gr), include) then
      ErrorMayQuit("Digraphs: DigraphMaximalCliques: usage,\n",
                   "the optional second argument <include> must be a ",
                   "duplicate-free set of vertices\nof <gr>,");
    fi;
  elif HasDigraphMaximalCliquesAttr(gr) then
    return DigraphMaximalCliquesAttr(gr);
  elif HasDigraphMaximalCliquesRepsAttr(gr) then
    reps := DigraphMaximalCliquesRepsAttr(gr);
  else
    include := [];
  fi;

  # Validate arg[3]
  if IsBound(arg[3]) then
    exclude := arg[3];
    if not IsHomogeneousList(exclude)
        or not IsDuplicateFreeList(exclude)
        or not IsSubset(DigraphVertices(gr), exclude) then
      ErrorMayQuit("Digraphs: DigraphMaximalCliques: usage,\n",
                   "the optional third argument <exclude> must be a ",
                   "duplicate-free set of verticies\nof <gr>,");
    fi;
  else
    exclude := [];
  fi;

  if not IsEmpty(Intersection(include, exclude)) then
    ErrorMayQuit("Digraphs: DigraphMaximalCliquesReps: usage,\n",
                 "the optional second and third arguments <include> and ",
                 "<exclude> must be disjoint,");
  fi;

  exclude_invariant := [];
  exclude_variant := [];
  # Calculate which orbits (if any) exclude contains
  while not IsEmpty(exclude) do
    v := exclude[1];
    orb := List(Orbit(G, v));
    int := Intersection(exclude, orb);
    if IsSubset(int, orb) then # int = orb
      Append(exclude_invariant, int);
    else
      Append(exclude_variant, int);
    fi;
    exclude := Difference(exclude, int);
  od;

  include_invariant := [];
  include_variant := [];
  # Calculate which orbits (if any) include contains
  while not IsEmpty(include) do
    v := include[1];
    orb := List(Orbit(G, v));
    int := Intersection(include, orb);
    if IsSubset(int, orb) then # int = orb
      Append(include_invariant, int);
    else
      Append(include_variant, int);
    fi;
    include := Difference(include, int);
  od;

  # Validate arg[4]
  if IsBound(arg[4]) then
    limit := arg[4];
    if limit <> infinity and not IsPosInt(limit) then
      ErrorMayQuit("Digraphs: DigraphMaximalCliquesReps: usage,\n",
                   "the optional fourth argument <limit> must be a positive ",
                   "integer or infinity,");
    fi;
  else
    limit := infinity;
  fi;

  all := limit < infinity or not IsEmpty(include_variant)
         or not IsEmpty(exclude_variant);
  c := DIGRAPHS_BronKerbosch(gr, include_invariant, include_variant,
                             exclude_invariant, exclude_variant, limit, G, all);
  if all then
    return c;
  fi;
  return Concatenation(List(c, x -> Orbit(G, x, OnSets)));
end);

# if the limit is less than infinity, then act as we go
# if there are variant exclude vertices, then act as we go
# otherwise return the reps
