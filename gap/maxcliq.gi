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
    local recurse, forbidden, cliques, verts, empty, pivot;

    cliques := [];

    recurse := function(try_in, forbidden_in, clique_in)
        local v, try, neighbours;

        if IsEmpty(try_in) and IsEmpty(forbidden_in) then
            Add(cliques, clique_in);
        else
            forbidden := ShallowCopy(forbidden_in);
            try := ShallowCopy(try_in);

            while not IsEmpty(try) do
                v := Remove(try,1);
                neighbours := Intersection(InNeighboursOfVertex(g,v), OutNeighboursOfVertex(g,v));
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
    #                P,  X,  R
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
