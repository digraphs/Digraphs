#############################################################################
##
#W  maxcliq.gi
#Y  Copyright (C) 2015                                   Markus Pfeiffer
##                                                       Raghav Mehra
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##


#
# This is just a basic implementation of the Bron-Kerbosch algorithm
# for finding all maximal cliques in a digraph.
# The main purpose of this being here is for checking results and better
# understanding of the more complicated algorithm.
#
InstallGlobalFunction(DigraphBronKerbosch,
function(g)
    local recurse, cliques, verts, empty;

    cliques := [];

    recurse := function(try_in, forbidden_in, clique_in)
        local v, try, neighbours, forbidden;

        if IsEmpty(try_in) and IsEmpty(forbidden_in) then
            Add(cliques, clique_in);
        else
            forbidden := ShallowCopy(forbidden_in);
            try := ShallowCopy(try_in);

            while not IsEmpty(try) do
                v := Remove(try);

                neighbours := Intersection(InNeighboursOfVertex(g,v), OutNeighboursOfVertex(g,v));
                if Position(neighbours,v) <> fail then
                    Remove(neighbours, Position(neighbours,v));
                fi;

                recurse(Intersection(try, neighbours), Intersection(forbidden, neighbours), Union(clique_in, [v]));

                Add(forbidden, v);
            od;
        fi;
    end;

    recurse(ShallowCopy(DigraphVertices(g)), [], []);

    return cliques;
end);

# Iterative version
InstallGlobalFunction(DigraphBronKerboschIter,
function(g)
    local clique, cliques, forbidden, pivot,
          neighbours, state, statestack, try,
          v;

    cliques := [];
    #                 P,  X,  R
    statestack := [ [[], [], []]
                  , [ShallowCopy(DigraphVertices(g)), [], []]];

    repeat
        state := Remove(statestack);

        if IsEmpty(state[1]) and IsEmpty(state[2]) then
            Add(cliques, state[3]);
        else
            try := ShallowCopy(state[1]);
            while not IsEmpty(try) do
                v := Remove(try);

                neighbours := Intersection(InNeighboursOfVertex(g,v), OutNeighboursOfVertex(g,v));
                Add(statestack, [Intersection(try, neighbours), Intersection(state[2], neighbours), Union(state[3], [v])] );
                Add(state[2], v);
            od;
        fi;
    until state = [[],[],[]];

    return cliques;
end);


PrintId := function(arg)
    local a;

    Print(Concatenation(List([1..arg[1]], x->" ")));
    for a in arg{[2..Length(arg)]} do
        Print(a);
    od;
end;

InstallGlobalFunction(DigraphBronKerboschPivot,
function(g)
    local recurse, cliques;

    cliques := [];

    recurse := function(try_in, forbidden_in, clique_in, l)
        local v, ptry, try, neighbours, forbidden, n, max, pivot;

        if IsEmpty(try_in) and IsEmpty(forbidden_in) then
            Add(cliques, clique_in);
        else
            # Choosing a pivot
            pivot := fail;
            max := 0;
            for v in Union(try_in, forbidden_in) do
                n := InDegreeOfVertex(g,v) + OutDegreeOfVertex(g,v);
                if n > max then
                    pivot := v;
                    max := n;
                fi;
            od;
            forbidden := ShallowCopy(forbidden_in);
            neighbours := Intersection(InNeighboursOfVertex(g,pivot), OutNeighboursOfVertex(g,pivot));
            if pivot in neighbours then
                Remove(neighbours, Position(neighbours, pivot));
            fi;

            ptry := Difference(try_in, neighbours);
            try := ShallowCopy(try_in);

            if IsEmpty(ptry) then
            fi;


            for v in ptry do
                neighbours := Intersection(InNeighboursOfVertex(g,v), OutNeighboursOfVertex(g,v));
                if v in neighbours then
                    Remove(neighbours, Position(neighbours, v));
                fi;

                recurse(Intersection(try, neighbours), Intersection(forbidden, neighbours), Union(clique_in, [v]), l+1);

                Remove(try, Position(try,v));
                Add(forbidden, v);
            od;
        fi;
    end;

    recurse(ShallowCopy(DigraphVertices(g)), [], [], 1);

    return cliques;
end);

BronKerboschTest := function(k, n)
    local i, rg, c1, c2, c3, d1, d2, t, t1, t2, t3;

    Print("Testing BronKerbosch implementation in ", k, " runs on ", n, " vertices\n");

    for i in [1..k] do
        Print("Run: ", i, "\n");

        rg := RandomDigraph(n);
        Print(" BronKerbosch...");
        t := Runtime();
        c1 := DigraphBronKerbosch(rg);
        t1 := Runtime() - t;
        Print(" ", t1, "\n");
        Print(" BronKerboschPivot...");
        t := Runtime();
        c2 := DigraphBronKerboschPivot(rg);
        t2 := Runtime() - t;
        Print(" ", t2, "\n");
        Print(" BronKerboschWithOrdering...");
        t := Runtime();
        c3 := DigraphBronKerboschWithOrdering(rg);
        t3 := Runtime() - t;
        Print(" ", t3, "\n");

        d1 := Difference(c1,c2);
        d2 := Difference(c1,c3);

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
        degs[v] := InDegreeOfVertex(g,v) + OutDegreeOfVertex(g,v);
        if degs[v] > maxdeg then
            maxdeg := degs[v];
        fi;
        if not IsBound(verts[degs[v] + 1]) then
            # GAP lists are 1-based...
            verts[degs[v] + 1] := [v];
        else
            Add(verts[degs[v] + 1], v);
        fi;
    od;

    k := 0;

    for n in [1..Length(degs)] do
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
        k := Maximum(k,i);

        v := Remove(verts[i+1]);
        Add(ordering, v);
        Add(order_set, v);

        for w in InNeighboursOfVertex(g,v) do
            if not (w in order_set) then
                Remove(verts[degs[w] + 1], Position(verts[degs[w]+1], w));
                if not IsBound(verts[degs[w]]) then
                    verts[degs[w]] := [w];
                else
                    Add(verts[degs[w]], w);
                fi;

                degs[w] := degs[w] - 1;
            fi;
        od;
        for w in OutNeighboursOfVertex(g,v) do
            if not (w in order_set) then
                Remove(verts[degs[w] + 1], Position(verts[degs[w]+1], w));
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
    local recurse, cliques, outer_try, outer_v, outer_neighbours, outer_forbidden;

    cliques := [];

    recurse := function(try_in, forbidden_in, clique_in, l)
        local v, ptry, try, neighbours, forbidden, n, max, pivot;

        if IsEmpty(try_in) and IsEmpty(forbidden_in) then
            Add(cliques, clique_in);
        else
            # Choosing a pivot
            pivot := fail;
            max := 0;
            for v in Union(try_in, forbidden_in) do
                n := InDegreeOfVertex(g,v) + OutDegreeOfVertex(g,v);
                if n > max then
                    pivot := v;
                    max := n;
                fi;
            od;
            forbidden := ShallowCopy(forbidden_in);
            neighbours := Intersection(InNeighboursOfVertex(g,pivot), OutNeighboursOfVertex(g,pivot));
            if pivot in neighbours then
                Remove(neighbours, Position(neighbours, pivot));
            fi;

            ptry := Difference(try_in, neighbours);
            try := ShallowCopy(try_in);

            if IsEmpty(ptry) then
            fi;


            for v in ptry do
                neighbours := Intersection(InNeighboursOfVertex(g,v), OutNeighboursOfVertex(g,v));
                if v in neighbours then
                    Remove(neighbours, Position(neighbours, v));
                fi;

                recurse(Intersection(try, neighbours), Intersection(forbidden, neighbours), Union(clique_in, [v]), l+1);

                Remove(try, Position(try,v));
                Add(forbidden, v);
            od;
        fi;
    end;

    outer_forbidden := [];
    outer_try := Reversed(DigraphDegeneracyOrdering(g));

    while not IsEmpty(outer_try) do
        outer_v := Remove(outer_try);

        outer_neighbours := Intersection(InNeighboursOfVertex(g, outer_v), OutNeighboursOfVertex(g, outer_v));
        if outer_v in outer_neighbours then
            Remove(outer_neighbours, Position(outer_neighbours, outer_v));
        fi;

        recurse(Intersection(outer_try, outer_neighbours), Intersection(outer_forbidden, outer_neighbours), [outer_v], 1);

        Add(outer_forbidden, outer_v);
    od;

    return cliques;
end);


