#############################################################################
##
#W  cliques.gi
#Y  Copyright (C) 2015                                   Markus Pfeiffer
##                                                       Raghav Mehra
##                                                       Wilf Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# This function returns a symmetric digraph without loops and without multiples
# edges with the same maximal cliques. This preprocessing speeds up clique finding

UnderlyingSymmetricGraphOfDigraph := function(gr)
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
end;

# This is a basic implementation of the Bron-Kerbosch algorithm for finding all
# maximal cliques in a digraph. The main purpose of this being here is for
# checking results and better understanding of the more complicated algorithm.

InstallGlobalFunction(DigraphBronKerbosch,
function(gr)
  local nbs, count, recurse, cliques;

  nbs := OutNeighbours(UnderlyingSymmetricGraphOfDigraph(gr));

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

#

InstallGlobalFunction(DigraphBronKerboschWithPivot,
function(gr)
  local nbs, degrees, count, recurse, cliques;

  gr := UnderlyingSymmetricGraphOfDigraph(gr);
  nbs := OutNeighbours(gr);
  degrees := OutDegrees(gr);

  count := 0;
  recurse := function(clique, try_arg, forbid_arg)
    local pivot, max, forbid, ptry, try, v;

    count := count + 1;
    if IsEmpty(try_arg) and IsEmpty(forbid_arg) then
      Add(cliques, clique);
    else

      # TODO choose a better pivot than this
      #   Try one with largest number of outneighbours in 
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

DigraphDegeneracyOrdering := function(gr)
  local nbs, n, out, deg_vert, m, verts_deg, k, i, v, d, count, w;

  # Assumes undirected, no multiple edges, no loops
  gr := UnderlyingSymmetricGraphOfDigraph(gr);
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

  # degeneracy = k
  Print("degeneracy = ", k, "\n");
  return out; 
end;

InstallGlobalFunction(DigraphBronKerboschWithPivotAndOrdering,
function(gr)
  local nbs, degrees, count, recurse, forbid1, try1, cliques,
  w, o_neighbours;

  gr := UnderlyingSymmetricGraphOfDigraph(gr);
  nbs := OutNeighbours(gr);
  degrees := OutDegrees(gr);

  count := 0;
  recurse := function(clique, try_arg, forbid_arg)
    local v, ptry, try, neighbours, forbid, n, max, pivot;

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

InstallGlobalFunction(DigraphBronKerboschIter,
function(gr)
  local nbs, cliques, stack, state, try, forbid, v;

  nbs := OutNeighbours(UnderlyingSymmetricGraphOfDigraph(gr));
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
