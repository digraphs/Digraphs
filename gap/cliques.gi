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

PrintId := function(arg)
  local a;
  Print(Concatenation(List([1 .. arg[1]], x -> " ")));
  for a in arg{[2 .. Length(arg)]} do
    Print(a);
  od;
end;

# This function returns a symmetric digraph without loops and without multiples
# edges with the same maximal cliques.
# This preprocessing makes the clique finding quicker

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

# This is just a basic implementation of the Bron-Kerbosch algorithm
# for finding all maximal cliques in a digraph.
# The main purpose of this being here is for checking results and better
# understanding of the more complicated algorithm.

InstallGlobalFunction(DigraphBronKerbosch,
function(gr)
  local recurse, cliques, nbs;

  nbs := OutNeighbours(UnderlyingSymmetricGraphOfDigraph(gr));

  recurse := function(clique, try_arg, forbid_arg)
    local v, try, forbid;

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
  return cliques;
end);

# Iterative version
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
                    Intersection(forbit, nbs[v])]);
        Add(forbit, v);
      od;
    fi;
  od;

  return cliques;
end);

# Pivot version
InstallGlobalFunction(DigraphBronKerboschPivot,
function(gr)
  local nbs, degrees, recurse, cliques;

  gr := UnderlyingSymmetricGraphOfDigraph(gr);
  nbs := OutNeighbours(gr);
  degrees := OutDegrees(gr);

  recurse := function(try_arg, forbid_arg, clique, l)
    local v, ptry, try, neighbours, forbid, n, max, pivot;

    if IsEmpty(try_arg) and IsEmpty(forbid_arg) then
      Add(cliques, clique);
    else
      # Choosing a pivot
      pivot := fail;
      max := 0;
      for v in Union(try_arg, forbid_arg) do
        n := degrees[v];
        if n > max then
          pivot := v;
          max := n;
        fi;
      od;
      forbid := ShallowCopy(forbid_arg);
      neighbours := Intersection(InNeighboursOfVertex(gr, pivot),
                                 OutNeighboursOfVertex(gr, pivot));
      if pivot in neighbours then
        Remove(neighbours, Position(neighbours, pivot));
      fi;

      ptry := Difference(try_arg, neighbours);
      for v in ptry do
        try := ShallowCopy(try_arg);
        recurse(Intersection(try, nbs[v]),
                Intersection(forbid, nbs[v]),
                Union(clique, [v]), l + 1);
        Remove(try, Position(try, v));
        Add(forbid, v);
      od;
    fi;
  end;

  cliques := [];
  recurse(ShallowCopy(DigraphVertices(gr)), [], [], 1);
  return cliques;
end);

BronKerboschTest := function(k, n)
    local i, rg, c1, c2, c3, d1, d2, t, t1, t2, t3;

    Print("Testing BronKerbosch implementation in ", k, " runs on ", n,
          " vertices\n");

    for i in [1 .. k] do
        Print("Run: ", i, "\n");

        rg := RandomDigraph(n);
        Print(" BronKerbosch .. .");
        t := Runtime();
        c1 := DigraphBronKerbosch(rg);
        t1 := Runtime() - t;
        Print(" ", t1, "\n");
        Print(" BronKerboschPivot .. .");
        t := Runtime();
        c2 := DigraphBronKerboschPivot(rg);
        t2 := Runtime() - t;
        Print(" ", t2, "\n");
        Print(" BronKerboschWithOrdering .. .");
        t := Runtime();
        c3 := DigraphBronKerboschWithOrdering(rg);
        t3 := Runtime() - t;
        Print(" ", t3, "\n");

        d1 := Difference(c1, c2);
        d2 := Difference(c1, c3);

        if (not IsEmpty(d1)) or (not IsEmpty(d2)) then
            Print("  difference: ", d1, " ", d2, "\n");
        fi;

    od;
end;

#
DigraphDegeneracyOrdering := function(g)
    local ordering, order_set, degs, verts, v, w, maxdeg, n, k, i, cont;

    ordering := [];
    order_set := Set([]);

    degs := [];
    verts := [];
    maxdeg := -1;

    for v in DigraphVertices(g) do
        degs[v] := InDegreeOfVertex(g, v) + OutDegreeOfVertex(g, v);
        if degs[v] > maxdeg then
            maxdeg := degs[v];
        fi;
        if not IsBound(verts[degs[v] + 1]) then
            # GAP lists are 1-based .. .
            verts[degs[v] + 1] := [v];
        else
            Add(verts[degs[v] + 1], v);
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
        Add(ordering, v);
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

    return ordering;
end;

InstallGlobalFunction(DigraphBronKerboschWithOrdering,
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
