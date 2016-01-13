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

# This function returns a symmetric digraph without loops and without multiples
# edges with the same maximal cliques. Using this speeds up clique finding

InstallMethod(MaximalSymmetricSubMultiDigraph, "for a digraph",
[IsDigraph],
function(gr)
  if not IsMultiDigraph(gr) then
    return MaximalSymmetricSubDigraph(gr);
  fi;
  ErrorMayQuit("Digraphs: MaximalSymmetricSubMultiDigraph: usage,\n",
               "not yet implemented,");
end);

# Need to make this more generic, naming more specific
# loops/no loops; multiple edges/no multiple edges
InstallMethod(MaximalSymmetricSubDigraph, "for a digraph",
[IsDigraph],
function(gr)
  local out_nbs, in_nbs, new_out, new_in, new_gr, i, j;

  out_nbs := OutNeighbours(gr);
  in_nbs  := InNeighbours(gr);
  new_out := List(DigraphVertices(gr), x -> []);
  new_in  := List(DigraphVertices(gr), x -> []);

  for i in DigraphVertices(gr) do
    for j in Intersection(out_nbs[i], in_nbs[i]) do
      if i <> j then
        Add(new_out[i], j);
        Add(new_in[j], i);
      fi;
    od;
  od;

  new_gr := DigraphNC(new_out);
  SetInNeighbors(new_gr, new_in);
  SetIsSymmetricDigraph(new_gr, true);
  return new_gr;
end);

#

InstallMethod(DigraphDegeneracy,
"for a digraph",
[IsDigraph],
function(gr)
  return DIGRAPHS_Degeneracy(gr)[1];
end);

InstallMethod(DigraphDegeneracyOrdering,
"for a digraph",
[IsDigraph],
function(gr)
  return DIGRAPHS_Degeneracy(gr)[2];
end);

# Calculates [ degeneracy, degeneracy ordering ]

InstallMethod(DIGRAPHS_Degeneracy,
"for a digraph",
[IsDigraph],
function(gr)
  local nbs, n, out, deg_vert, m, verts_deg, k, i, v, d, w;

  # The code assumes undirected, no multiple edges, no loops
  gr := MaximalSymmetricSubDigraph(gr);
  nbs := OutNeighbours(gr);
  n := DigraphNrVertices(gr);
  out := EmptyPlist(n);
  deg_vert := ShallowCopy(OutDegrees(gr));
  m := Maximum(deg_vert);
  verts_deg := List([1 .. m], x -> []);

  # Prepare the set verts_deg
  for v in DigraphVertices(gr) do
    if deg_vert[v] = 0 then
      Add(out, v);
    else
      Add(verts_deg[deg_vert[v]], v);
    fi;
  od;

  k := 0;
  while Length(out) < n do
    i := First([1 .. m], x -> not IsEmpty(verts_deg[x]));
    k := Maximum(k, i);
    v := Remove(verts_deg[i]);
    Add(out, v);
    for w in Difference(nbs[v], out) do
      d := deg_vert[w];
      Remove(verts_deg[d], Position(verts_deg[d], w));
      d := d - 1;
      deg_vert[w] := d;
      if d = 0 then
        Add(out, w);
      else
        Add(verts_deg[d], w);
      fi;
    od;
  od;

  return [k, out];
end);

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
    try := Difference(try, OutNeighbours(gr, v));
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
  while i < n and Length(try) > n do
    i := i + 1;
    try := Intersection(try, nbs[clique[i]]);
  od;
  if Length(try) = n then
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

#

# This is a basic implementation of the Bron-Kerbosch algorithm for finding all
# maximal cliques in a digraph. The main purpose of this being here is for

# checking results and better understanding of the more complicated algorithm.

InstallGlobalFunction(BronKerbosch,
function(gr)
  local nbs, count, recurse, cliques;

  nbs := OutNeighbours(MaximalSymmetricSubDigraph(gr));

  count := 0;
  recurse := function(clique, try_arg, forbid_arg)
    local v, try, forbid;

    count := count + 1;
    if IsEmpty(try_arg) and IsEmpty(forbid_arg) then
      Add(cliques, clique);
    else
      try := ShallowCopy(try_arg);
      forbid := ShallowCopy(forbid_arg);
      while not IsEmpty(try) do
        v := Remove(try);
        recurse(Concatenation(clique, [v]),
                Intersection(try, nbs[v]),
                Intersection(forbid, nbs[v]));
        Add(forbid, v);
      od;
    fi;
  end;

  cliques := [];
  recurse([], ShallowCopy(DigraphVertices(gr)), []);
  Print(count, " recursions\n");
  return cliques;
end);

# BooleanAdjacencyMatrix

InstallMethod(BooleanAdjacencyMatrix,
"for a digraph",
[IsDigraph],
function(gr)
  local n, nbs, mat, i, j;

  n := DigraphNrVertices(gr);
  nbs := OutNeighbours(gr);
  mat := List(DigraphVertices(gr), x -> BlistList([1 .. n], []));
  for i in DigraphVertices(gr) do
    for j in nbs[i] do
      mat[j][i] := true;
      mat[i][j] := true;
    od;
  od;
  return mat;
end);

InstallGlobalFunction(BronKerboschWithPivot,
function(gr)
  local nbs, degrees, count, recurse, cliques;

  gr := MaximalSymmetricSubDigraph(gr);
  nbs := OutNeighbours(gr);
  #mat := BooleanAdjacencyMatrix(gr);
  degrees := OutDegrees(gr);

  count := 0;
  recurse := function(clique, try_arg, forbid_arg)
    local pivot, max, forbid, ptry, try, v;

    count := count + 1;
    if IsEmpty(try_arg) and IsEmpty(forbid_arg) then
      Add(cliques, clique);
    else

      # Choose a pivot
      max := 0;
      for v in Concatenation(try_arg, forbid_arg) do
        if degrees[v] > max then
          pivot := v;
          max := degrees[v];
        fi;
      od;
      if max = 0 then
        Print("fail - this is bad,\n");
      fi;

      try := ShallowCopy(try_arg);
      forbid := ShallowCopy(forbid_arg);
      ptry := Difference(try, nbs[pivot]);
      while not IsEmpty(ptry) do
        v := Remove(ptry);
        recurse(Union(clique, [v]),
                Intersection(try, nbs[v]),
                Intersection(forbid, nbs[v]));
        Remove(try, Position(try, v)); # is there a way of getting rid of this?
        Add(forbid, v);
      od;
    fi;
  end;

  cliques := [];
  recurse([], DigraphVertices(gr), []);
  Print(count, " recursions\n");
  return cliques;
end);

#

InstallGlobalFunction(BronKerboschWithPivotBlist,
function(gr)
  local nbs, mat, degrees, count, recurse, cliques;

  gr := MaximalSymmetricSubDigraph(gr);
  nbs := OutNeighbours(gr);
  mat := BooleanAdjacencyMatrix(gr);
  degrees := OutDegrees(gr);

  count := 0;
  recurse := function(clique, try_arg, forbid_arg)
    local try, forbid, max, pivot, ptry, v, new_clique;

    count := count + 1;
    if not ForAny(try_arg, x -> x) and not ForAny(forbid_arg, x -> x) then
      Add(cliques, clique);
    else
      try := ShallowCopy(try_arg);
      forbid := ShallowCopy(forbid_arg);

      # Choose a pivot
      max := -1;
      pivot := 0;
      for v in ListBlist(DigraphVertices(gr), UnionBlist(try, forbid)) do
        #if SizeBlist(Intersection(mat[v], try)) > max then
        if degrees[v] > max then
          pivot := v;
          max := degrees[v];
        fi;
      od;
      if max = -1 then
        Print("fail - this is bad,\n");
      fi;

      ptry := ListBlist(DigraphVertices(gr), DifferenceBlist(try, mat[pivot]));
      ptry := ShallowCopy(ptry);
      while not IsEmpty(ptry) do
        v := Remove(ptry);
        new_clique := ShallowCopy(clique);
        new_clique := true;
        recurse(new_clique,
                IntersectionBlist(try, mat[v]),
                IntersectionBlist(forbid, mat[v]));
        try[v] := false;
        forbid[v] := true;
      od;
    fi;
  end;

  cliques := [];
  recurse(BlistList(DigraphVertices(gr), []),
          BlistList(DigraphVertices(gr), DigraphVertices(gr)),
          BlistList(DigraphVertices(gr), []));
  Print(count, " recursions\n");
  return cliques;
end);

#

InstallGlobalFunction(BronKerboschWithPivotAndOrdering,
function(gr)
  local nbs, degrees, count, recurse, try1, forbid1, cliques, w;

  gr := MaximalSymmetricSubDigraph(gr);
  nbs := OutNeighbours(gr);
  degrees := OutDegrees(gr);

  count := 0;
  recurse := function(clique, try_arg, forbid_arg)
    local max, pivot, try, forbid, ptry, v;

    count := count + 1;
    if IsEmpty(try_arg) and IsEmpty(forbid_arg) then
      Add(cliques, clique);
    else
      # Choose a pivot
      max := -1;
      for v in Concatenation(try_arg, forbid_arg) do
        if degrees[v] > max then
          pivot := v;
          max := degrees[v];
        fi;
      od;
      if max = -1 then
        Print("fail - this is bad,\n");
      fi;

      try := ShallowCopy(try_arg);
      forbid := ShallowCopy(forbid_arg);
      ptry := Difference(try, nbs[pivot]);
      while not IsEmpty(ptry) do
        v := Remove(ptry);
        recurse(Union(clique, [v]),
                Intersection(try, nbs[v]),
                Intersection(forbid, nbs[v]));
        Remove(try, Position(try, v)); # is there a way of getting rid of this?
        Add(forbid, v);
      od;
    fi;
  end;

  try1 := ShallowCopy(DigraphDegeneracyOrdering(gr));
  forbid1 := [];
  cliques := [];
  while not IsEmpty(try1) do
    w := Remove(try1, 1);
    recurse([w],
            Intersection(try1, nbs[w]),
            Intersection(forbid1, nbs[w]));
    Add(forbid1, w);
  od;

  Print(count, " recursions\n");
  return cliques;
end);

# Version of basic algorithm, non-recursive with stack

InstallGlobalFunction(BronKerboschIter,
function(gr)
  local nbs, cliques, stack, state, try, forbid, v;

  nbs := OutNeighbours(MaximalSymmetricSubDigraph(gr));
  cliques := [];
  stack := [[[], ShallowCopy(DigraphVertices(gr)), []]];
  while not IsEmpty(stack) do
    state := Remove(stack);
    if IsEmpty(state[2]) and IsEmpty(state[3]) then
      Add(cliques, state[1]);
    else
      try := state[2];
      forbid := state[3];
      while not IsEmpty(try) do
        v := Remove(try);
        Add(stack, [Union(state[1], [v]),
                    Intersection(try, nbs[v]),
                    Intersection(forbid, nbs[v])]);
        Add(forbid, v);
      od;
    fi;
  od;

  return cliques;
end);
