#############################################################################
##
#W  cliques.gi
#Y  Copyright (C) 2015-16                                Markus Pfeiffer
##                                                       Raghav Mehra
##                                                       Wilfred A. Wilson
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

################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################

InstallGlobalFunction(DigraphMaximalClique,
function(arg)
  if IsEmpty(arg) then
    ErrorMayQuit("Digraphs: DigraphMaximalClique: usage,\n",
                 "this function takes at least one argument,");
  fi;
  return DIGRAPHS_Clique(Concatenation([true], arg));
end);

#

InstallGlobalFunction(DigraphClique,
function(arg)
  if IsEmpty(arg) then
    ErrorMayQuit("Digraphs: DigraphClique: usage,\n",
                 "this function takes at least one argument,");
  fi;
  return DIGRAPHS_Clique(Concatenation([false], arg));
end);

#

InstallGlobalFunction(DIGRAPHS_Clique,
function(arg)
  local maximal, gr, G, include, exclude, size, out, try, include_copy, v;

  arg := arg[1];
  maximal := arg[1];

  # Validate arg[2]
  gr := arg[2];
  if not IsDigraph(gr) then
    ErrorMayQuit("Digraphs: DIGRAPHS_Clique: usage,\n",
                 "the first argument <gr> must be a digraph,");
  fi;

  G := DigraphGroup(gr);

  # Validate arg[3]
  if IsBound(arg[3]) then
    include := arg[3];
    if not IsHomogeneousList(include)
        or not IsSubset(DigraphVertices(gr), include) then
      ErrorMayQuit("Digraphs: DIGRAPHS_Clique: usage,\n",
                   "the optional second argument <include> must be a ",
                   "duplicate-free set of vertices\nof <gr>,");
    fi;
    include := Unique(include);
  else
    include := [];
  fi;

  if not IsClique(gr, include) then
    return fail;
  fi;

  # Validate arg[4]
  if IsBound(arg[4]) then
    exclude := arg[4];
    if not IsHomogeneousList(exclude)
        or not IsSubset(DigraphVertices(gr), exclude) then
      ErrorMayQuit("Digraphs: DIGRAPHS_Clique: usage,\n",
                   "the optional third argument <exclude> must be a ",
                   "duplicate-free set of verticies\nof <gr>,");
    fi;
    exclude := Unique(exclude);
  else
    exclude := [];
  fi;
  
  if not IsEmpty(Intersection(include, exclude)) then
    return fail;
  fi;

  # Validate arg[5]
  if IsBound(arg[5]) then
    size := arg[5];
    if not IsPosInt(size) then
      ErrorMayQuit("Digraphs: DIGRAPHS_Clique: usage,\n",
                   "the optional fourth argument <size> must be a positive ",
                   "integer,");
    fi;
    # Perform 4-argument version of the function
    if maximal then
      out := DigraphMaximalCliques(gr, include, exclude, 1, size);
      if IsEmpty(out) then
        return fail;
      fi;
      return out[1];
    fi;
    out := DigraphCliquesOfSize(gr, size, include, exclude, 1);
    if IsEmpty(out) then
      return fail;
    fi;
    return out[1];
  fi;

  if IsBound(arg[4]) then
    # Perform 3-argument version of the function
    if maximal then
      out := DigraphMaximalCliques(gr, include, exclude, 1);
      if IsEmpty(out) then
        return false;
      fi;
      return out[1];
    fi;
  fi;
  
  # Do a greedy search to find a clique of <gr> containing <include> and
  # excluding <exclude> (which is necessarily maximal if <exclude> is empty)
  gr := MaximalSymmetricSubdigraph(gr);
  out := OutNeighbours(gr);
  try := Difference(DigraphVertices(gr), Concatenation(include, exclude));
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

#

InstallMethod(DigraphMaximalCliquesRepsAttr,
"for a digraph",
[IsDigraph],
function(gr)
  return DigraphMaximalCliquesReps(gr);
end);

#

InstallGlobalFunction(DigraphMaximalCliquesReps,
function(arg)
  local gr, G, include, exclude, limit, size, out;

  if IsEmpty(arg) then
    ErrorMayQuit("Digraphs: DigraphMaximalCliquesReps: usage,\n",
                 "this function takes at least one argument,");
  fi;

  # Validate arg[1]: gr
  gr := arg[1];
  if not IsDigraph(gr) then
    ErrorMayQuit("Digraphs: DigraphMaximalCliquesReps: usage,\n",
                 "the first argument <gr> must be a digraph,");
  fi;

  G := DigraphGroup(gr);

  # Validate arg[2]: include
  if IsBound(arg[2]) then
    include := arg[2];
    if not IsHomogeneousList(include)
        or not IsSubset(DigraphVertices(gr), include)
        or not ForAll(GeneratorsOfGroup(G),
                      x -> IsSubset(OnTuples(include, x), include)) then
      ErrorMayQuit("Digraphs: DigraphMaximalCliquesReps: usage,\n",
                   "the optional second argument <include> must be a ",
                   "duplicate-free set of vertices\nof <gr> which is ",
                   "invariant under the action of the DigraphGroup <G>,");
    fi;
    include := Unique(include);
  elif HasDigraphMaximalCliquesRepsAttr(gr) then
    return DigraphMaximalCliquesRepsAttr(gr);
  else
    include := [];
  fi;

  # Validate arg[3]: exclude
  if IsBound(arg[3]) then
    exclude := arg[3];
    if not IsHomogeneousList(exclude)
        or not IsSubset(DigraphVertices(gr), exclude)
        or not ForAll(GeneratorsOfGroup(G),
                      x -> IsSubset(OnTuples(exclude, x), exclude)) then
      ErrorMayQuit("Digraphs: DigraphMaximalCliquesReps: usage,\n",
                   "the optional third argument <exclude> must be a ",
                   "duplicate-free set of verticies\nof <gr> which is ",
                   "invariant under the action of the DigraphGroup <G>,");
    fi;
    exclude := Unique(exclude);
  else
    exclude := [];
  fi;

  # Validate arg[4]: limit
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

  # Validate arg[5]: size
  if IsBound(arg[5]) then
    size := arg[5];
    if not IsPosInt(size) then
      ErrorMayQuit("Digraphs: DigraphMaximalCliquesReps: usage,\n",
                   "the optional fifth argument <size> must be a positive ",
                   "integer,");
    fi;
  else
    size := fail;
  fi;

  out := DIGRAPHS_BronKerbosch(gr, include, [], exclude, [], limit, G, false,
                               size);

  # Store the result if appropriate
  if IsEmpty(include) and IsEmpty(exclude) and Length(out) < limit then
    SetDigraphMaximalCliquesRepsAttr(gr, out);
    if not HasDigraphMaximalCliquesAttr(gr) and IsTrivial(G) then
      SetDigraphMaximalCliquesAttr(gr, out);
    fi;
  fi;

  return out;
end);

# Maximal cliques

InstallMethod(DigraphMaximalCliquesAttr,
"for a digraph",
[IsDigraph],
function(gr)
  return DigraphMaximalCliques(gr);
end);

#

#InstallGlobalFunction(DIGRAPHS_Cliques,
#function(arg)
#  arg := arg[1];
#  all := arg[1]; # are we finding all cliques (<all> = true) or orbit reps
#  gr := arg[2];
#  grp := DigraphGroup(gr);
#  inc := arg[3];
#  if not all then
#    # check that inc is invariant grp
#  fi;
#  exc := arg[4];
#  if not all then
#    # check that exc is invariant under grp
#  fi;
#  lim := arg[5];
#  size := arg[6];
#  calculate cliques
#  store cliques if applicable
#  return cliques;
#end);

InstallGlobalFunction(DigraphMaximalCliques,
function(arg)
  local gr, G, include, reps, out, exclude, limit, size, exclude_invariant,
  exclude_variant, v, orb, int, include_invariant, include_variant, all, c;

  if IsEmpty(arg) then
    ErrorMayQuit("Digraphs: DigraphMaximalCliques: usage,\n",
                 "this function takes at least one argument,");
  fi;

  # Validate arg[1]: gr
  gr := arg[1];
  if not IsDigraph(gr) then
    ErrorMayQuit("Digraphs: DigraphMaximalCliques: usage,\n",
                 "the first argument <gr> must be a digraph,");
  fi;

  G := DigraphGroup(gr);

  # Validate arg[2]: include
  if IsBound(arg[2]) then
    include := arg[2];
    if not IsHomogeneousList(include)
        or not IsSubset(DigraphVertices(gr), include) then
      ErrorMayQuit("Digraphs: DigraphMaximalCliques: usage,\n",
                   "the optional second argument <include> must be a ",
                   "duplicate-free set of vertices\nof <gr>,");
    fi;
    include := Unique(include);
  elif HasDigraphMaximalCliquesAttr(gr) then
    return DigraphMaximalCliquesAttr(gr);
  elif HasDigraphMaximalCliquesRepsAttr(gr) then
    reps := DigraphMaximalCliquesRepsAttr(gr);
    out := Concatenation(List(c, x -> Orbit(G, x, OnSets)));
    SetDigraphMaximalCliquesAttr(gr, out);
    return out;

  else
    include := [];
  fi;

  # Validate arg[3]: exclude
  if IsBound(arg[3]) then
    exclude := arg[3];
    if not IsHomogeneousList(exclude)
        or not IsSubset(DigraphVertices(gr), exclude) then
      ErrorMayQuit("Digraphs: DigraphMaximalCliques: usage,\n",
                   "the optional third argument <exclude> must be a ",
                   "duplicate-free set of verticies\nof <gr>,");
    fi;
    exclude := Unique(exclude);
  else
    exclude := [];
  fi;

  # Validate arg[4]: limit
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

  # Validate arg[5]: size
  if IsBound(arg[5]) then
    size := arg[5];
    if not IsPosInt(size) then
      ErrorMayQuit("Digraphs: DigraphMaximalCliques: usage,\n",
                   "the optional fifth argument <size> must be a positive ",
                   "integer,");
    fi;
  else
    size := fail;
  fi;


  # Decide whether we need to collect all results as we go
  # Or just orbit representatives
  all := limit < infinity
           or not IsEmpty(include_variant)
           or not IsEmpty(exclude_variant);
  c := DIGRAPHS_BronKerbosch(gr, include_invariant, include_variant,
                             exclude_invariant, exclude_variant, limit, G, all,
                             size);

  # did we already compute *all* results?
  if all then
    out := c;
  else
    out := Concatenation(List(c, x -> Orbit(G, x, OnSets)));
  fi;

  # Store the result if appropriate
  if IsEmpty(include_invariant) and IsEmpty(include_variant)
      and IsEmpty(exclude_invariant) and IsEmpty(exclude_variant)
      and Length(out) < limit then
    SetDigraphMaximalCliquesAttr(gr, out);
    if not all
        and not HasDigraphMaximalCliquesRepsAttr(gr)
        and IsTrivial(G) then
      SetDigraphMaximalCliquesRepsAttr(gr, out);
    fi;
  fi;
  return out;
end);

################################################################################

InstallGlobalFunction(DIGRAPHS_BronKerbosch,
function(gr, inc, exc, lim, size, max, reps)
  local vtx, grp, invariant_inc, invariant_exc, inc_var, exc_var, x, v, o, i,
  invariant, adj, deg, all, exc_inv, start, possible, add, bk, out, num;

  # Arguments should be:
  # gr   - a digraph
  # inc  - a duplicate-free list of vertices of <gr>
  # exc  - a duplicate-free list of vertices of <gr>
  # lim  - a positive integer or infinity
  # size - a positive integer
  # max  - do we care whether the results are maximal?
  # reps - do we want to return all valid results or orbit representatives?


  ##############################################################################
  # Validate arguments
  if not IsDigraph(gr) then
    Error("needs to be a digraph");
  fi;

  vtx := DigraphVertices(gr);
  grp := DigraphGroup(gr);

  if not (IsList(inc) and IsDuplicateFreeList(inc) and IsSubset(vtx, inc))
      or not (IsList(exc) and IsDuplicateFreeList(exc) and IsSubset(vtx, exc))
      then
    Error("must be duplicate-free subset of the vertices");
  fi;

  if not IsClique(gr, inc) then # the set we wish to extend is not a clique
    return [];
  elif ForAny(exc, x -> x in inc) then # the clique contains excluded vertices
    return [];
  fi;

  if not (lim = infinity or IsPosInt(lim)) then
    Error("lim must be a posint or inifinity");
  fi;

  if not (size = fail or IsPosInt(size)) then
    Error("size must be a posint or fail");
  fi;

  if not (max = true or max = false) then
    Error("max must be true or false");
  fi;

  gr := MaximalSymmetricSubdigraphWithoutLoops(gr);

  # Investigate whether <inc> and <exc> are invariant under <grp>
  invariant_inc := true;
  invariant_exc := true;
  inc_var := [];
  exc_var := [];

  if IsTrivial(grp) then
    grp := fail;
  else
    if not ForAll(GeneratorsOfGroup(grp), x -> IsSubset(inc, OnTuples(inc, x)))
        then 
      invariant_inc := false;
      if not reps then
        x := ShallowCopy(inc);
        while not IsEmpty(x) do
          v := x[1];
          o := List(Orbit(grp, v));
          i := Intersection(x, o);
          if not IsSubset(x, o) then
            Append(inc_var, i);
          fi;
          x := Difference(x, i);
        od;
      fi;
    fi;
    if not ForAll(GeneratorsOfGroup(grp), x -> IsSubset(exc, OnTuples(exc, x)))
         then
      invariant_exc := false;
      if not reps then
        x := ShallowCopy(exc);
        while not IsEmpty(x) do
          v := x[1];
          o := List(Orbit(grp, v));
          i := Intersection(x, o);
          if not IsSubset(x, o) then
            Append(exc_var, i);
          fi;
          x := Difference(x, i);
        od;
      fi;
    fi;
    if reps and not (invariant_inc and invariant_exc) then
      Error("inv and exc must be invariant if you want reps");
    fi;
  fi;
  invariant := invariant_inc and invariant_exc;

  adj := BooleanAdjacencyMatrix(gr);
  deg := OutDegrees(gr);

  ##############################################################################
  # Test for easy cases
  if Length(inc) = DigraphNrVertices(gr) then # the clique is all of <gr>
    return [inc];
  elif size <> fail
      and size > DigraphNrVertices(gr) then # the desired clique size is too big
    return [];
  fi;

  # Variables
  # gr    - a symmetric digraph without loops and multiple edges whose cliques
  #         coincide with those of the original digraph
  # adj   - boolean adjacency matrix of <gr>
  # vtx   - DigraphVertices(gr)
  # deg   - OutDegrees(gr)
  # num   - number of results found so far
  # out   - the list of results
  # grp   - a perm group, a subgroup of the automorphism group of <gr>
  # invariant_inc - is inc invariant under grp?
  # invariant_exc - is exc invariant under grp?
  # inc_var - the subset of inc whose orbit is not contained in inc
  # exc_var - the subset of exc whose orbit is not contained in exc
  # exc_inv - the subset of exc whose orbit is contained in exc

  ##############################################################################
  # Preparation, and processing of variables

  # Decide whether we enumerate clique orbits as we find new results
  all := not reps and (not invariant or lim < infinity);

  inc_var  := BlistList(vtx, inc_var);
  exc_var  := BlistList(vtx, exc_var);
  exc_inv  := DifferenceBlist(BlistList(vtx, exc), exc_var);
  start    := BlistList(vtx, inc);
  possible := BlistList(vtx, vtx);
  SubtractBlist(possible, start);
  for x in inc do
    IntersectBlist(possible, adj[x]);
  od;
  
  # Function to find the valid cliques of an orbit given an orbit rep
  add := function(c)
    local orb, n, i;

    c := ListBlist(vtx, c);
    if not all then # we are only looking for orbit reps, so add the rep
      Add(out, c);
      num := num + 1;
      return;
    fi;

    orb := Orbit(grp, c, OnSets);
    n := Length(orb);
    if invariant then # we're not just looking for orbit reps, but there is
                      # nothing extra to check
      n := Minimum(lim - num, n);
      Append(out, orb{[1 .. n]});
      num := num + n;
      return;
    fi;

    if invariant_inc then
      # Cliques in the orbit might contain forbidden vertices
      i := 0;
      while i < n and num < lim do
        i := i + 1;
        c := BlistList(vtx, orb[i]);
        if not ForAny(IntersectionBlist(exc_var, c)) then
          Add(out, orb[i]);
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
          Add(out, orb[i]);
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
        if not ForAny(IntersectionBlist(exc_var, c))
            and IsSubsetBlist(c, inc_var) then
          Add(out, orb[i]);
          num := num + 1;
        fi;
      od;
    fi;
    return;
  end;

  # Main recursive function
  bk := function(c, try, ban, G, d)
    local orb, try_orb, top, piv, m, to_try, C, g, v;

    # <c> is a new clique rep
    if not max and size <> fail and size = d then
      # <c> has the desired size and we don't care about maximality
      add(c);
      return;
    fi;

    if not ForAny(ban, x -> x) and not ForAny(try, x -> x) then
      if (size = fail or size = d) then
        # <c> is a new maximal clique rep and it has the right size
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
    orb := ListBlist(vtx, UnionBlist(try, ban));
    if not G = fail then # Use the group <G> to prune the vertices to try
      orb := Orbits(G, orb);
      orb := List(orb, x -> x[1]);
      try_orb := IntersectionBlist(BlistList(vtx, orb), try);
    else
      try_orb := ShallowCopy(try);
    fi;

    # If we are searching for *maximal* cliques then choose a pivot
    if max then
      # Choose a pivot: choose a vertex with maximum out-degree in try or ban
      # TODO optimise choice of pivot

      # Strategy 1: choose vertex in orb (try union ban, mod G) of max degree
      #top := -1;
      #piv := 0;
      #for v in orb do
      #  if deg[v] > top then
      #    piv := v;
      #    top := deg[v];
      #  fi;
      #od;

      # Is this a better way of choosing a pivot?
      # Strategy 2: choose vertex in orb (try union ban, mod G) with max number
      #             of neighbours in try_orb (try mod G)
      top := -1;
      piv := 0;
      for v in orb do
        m := SizeBlist(IntersectionBlist(try_orb, adj[v]));
        if m > top then
          piv := v;
          top := m;
        fi;
      od;

      # Strategy 3: choose vertex in orb (try union ban, mod G) with max number
      #             of neighbours in try
      # NOT YET IMPLEMENTED OR TESTED

      to_try := ShallowCopy(ListBlist(vtx, DifferenceBlist(try_orb,
                                                           adj[piv])));
    else
      # If we are searching for cliques (not necessarily maximal) of a given
      # size then the logic of using a pivot doesn't work
      to_try := ListBlist(vtx, try_orb);
    fi;

    # Try to extend <c> and recurse
    for v in to_try do
      if not exc_inv[v] then # We are allowed to add <v> to <c>
        C := ShallowCopy(c);
        C[v] := true;
        if G = fail then
          g := fail;
        else
          g := Stabilizer(G, v); # Calculate the stabilizer of <v> in <G>
          if IsTrivial(g) then
            g := fail; # Discard the group from this point as it is trivial
          fi;
        fi;
        bk(C, IntersectionBlist(try, adj[v]), IntersectionBlist(ban, adj[v]),
           g, d); # Recurse
      fi;
      try[v] := false;
      ban[v] := true;
      if lim = num then
        return; # The limit of cliques has been reached
      fi;
    od;
  end;

  out := [];
  num := 0;
  bk(start, possible, BlistList(vtx, []), grp, Length(inc));

  if not reps and not all then
    out := Concatenation(List(out, x -> Orbit(grp, x, OnSets))); 
  fi;
  return out;
end);
