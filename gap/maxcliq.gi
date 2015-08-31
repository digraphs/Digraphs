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
    local i, rg, c1, c2, d, t, t1, t2;

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


        d := Difference(c1,c2);

        if not IsEmpty(d) then
            Print("  difference: ", d, "\n");
        fi;

    od;
end;
