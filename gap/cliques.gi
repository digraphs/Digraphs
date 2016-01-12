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
  local n, out, deg_vert, verts_deg, k, i, cont, v, w;

  gr := UnderlyingSymmetricGraphOfDigraph(gr);

  n := DigraphNrVertices(gr);
  out := EmptyPlist(n);
  deg_vert := ShallowCopy(OutDegrees(gr));
  verts_deg := List([1 .. Maximum(deg_vert)], x -> []);

  # Prepare the set D
  for v in DigraphVertices(g) do
    if deg_vert[v] = 0 then
      Add(out, v);
    else
      Add(verts_deg[deg_vert[v]], v);
    fi;
  od;

  k := 0;

  for n in [1 .. Length(degs)] do
    i := 0;
    cont := true;
    while cont do
      if not IsBound(verts[i + 1]) then
        i := i + 1;
      elif IsEmpty(verts[i + 1]) then
        i := i + 1;
      else
        cont := false;
      fi;
    od;

    # We are actually computing the degeneracy
    k := Maximum(k, i);

    v := Remove(verts[i + 1]);
    Add(out, v);
    Add(order_set, v);

    for w in InNeighboursOfVertex(g, v) do
      if not (w in order_set) then
        Remove(verts[degs[w] + 1], Position(verts[degs[w] + 1], w));
        if not IsBound(verts[degs[w]]) then
          verts[degs[w]] := [w];
        else
          Add(verts[degs[w]], w);
        fi;

        degs[w] := degs[w] - 1;
      fi;
    od;
    for w in OutNeighboursOfVertex(g, v) do
      if not (w in order_set) then
        Remove(verts[degs[w] + 1], Position(verts[degs[w] + 1], w));
        if not IsBound(verts[degs[w]]) then
          verts[degs[w]] := [w];
        else
          Add(verts[degs[w]], w);
        fi;
        degs[w] := degs[w] - 1;
      fi;
    od;
  od;
  return out;
end;

InstallGlobalFunction(DigraphBronKerboschWithPivotAndOrdering,
function(g)
  local cliques, recurse, outer_forbid, outer_try, outer_v, outer_neighbours;

    cliques := [];

    recurse := function(try_arg, forbid_arg, clique_arg, l)
        local v, ptry, try, neighbours, forbid, n, max, pivot;

        if IsEmpty(try_arg) and IsEmpty(forbid_arg) then
            Add(cliques, clique_arg);
        else
            # Choosing a pivot
            pivot := fail;
            max := 0;
            for v in Union(try_arg, forbid_arg) do
                n := InDegreeOfVertex(g, v) + OutDegreeOfVertex(g, v);
                if n > max then
                    pivot := v;
                    max := n;
                fi;
            od;
            forbid := ShallowCopy(forbid_arg);
            neighbours := Intersection(InNeighboursOfVertex(g, pivot),
                                       OutNeighboursOfVertex(g, pivot));
            if pivot in neighbours then
                Remove(neighbours, Position(neighbours, pivot));
            fi;

            ptry := Difference(try_arg, neighbours);
            try := ShallowCopy(try_arg);

            if IsEmpty(ptry) then
            fi;

            for v in ptry do
                neighbours := Intersection(InNeighboursOfVertex(g, v),
                              OutNeighboursOfVertex(g, v));
                if v in neighbours then
                    Remove(neighbours, Position(neighbours, v));
                fi;

                recurse(Intersection(try, neighbours),
                        Intersection(forbid, neighbours),
                        Union(clique_arg, [v]),
                        l + 1);

                Remove(try, Position(try, v));
                Add(forbid, v);
            od;
        fi;
    end;

    outer_forbid := [];
    outer_try := Reversed(DigraphDegeneracyOrdering(g));

    while not IsEmpty(outer_try) do
        outer_v := Remove(outer_try);

        outer_neighbours := Intersection(InNeighboursOfVertex(g, outer_v),
        OutNeighboursOfVertex(g, outer_v));
        if outer_v in outer_neighbours then
            Remove(outer_neighbours, Position(outer_neighbours, outer_v));
        fi;

        recurse(Intersection(outer_try, outer_neighbours),
        Intersection(outer_forbid, outer_neighbours), [outer_v], 1);

        Add(outer_forbid, outer_v);
    od;

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
