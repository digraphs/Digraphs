#############################################################################
##
##  weights.gi
##  Copyright (C) 2023                                Raiyan Chowdhury
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

#############################################################################
# 1. Edge Weights
#############################################################################

InstallGlobalFunction(EdgeWeightedDigraph,
function(digraph, weights)
  local digraphVertices, nrVertices, u, outNeighbours,
  outNeighbourWeights, idx;

  if IsDigraph(digraph) then
      digraph := DigraphCopy(digraph);
  else
      digraph := Digraph(digraph);
  fi;

  # check all elements of weights is a list
  if not ForAll(weights, IsListOrCollection) then
      ErrorNoReturn("the 2nd argument (list) must be a list of lists,");
  fi;

  digraphVertices := DigraphVertices(digraph);

  nrVertices := Size(digraphVertices);

  # check number there is an edge weight list for vertex u
  if nrVertices <> Size(weights) then
      ErrorNoReturn("the number of out neighbours and weights must be equal,");
  fi;

  # check all elements of weights is a list and size/shape is correct
  for u in digraphVertices do
      outNeighbours := OutNeighbors(digraph)[u];

      outNeighbourWeights := weights[u];

      # check number of out neighbours for u
      # and number of weights given is the same
      if Size(outNeighbours) <> Size(outNeighbourWeights) then
          ErrorNoReturn(
              "the sizes of the out neighbours and weights for vertex ",
               u, " must be equal,");
      fi;

      # check all elements of out neighbours are appropriate
      for idx in [1 .. Size(outNeighbours)] do

          if not (IsInt(outNeighbourWeights[idx])
          or IsFloat(outNeighbourWeights[idx])
          or IsRat(outNeighbourWeights[idx])) then
              ErrorNoReturn(
            "out neighbour weight must be an integer, float or rational,");
          fi;
      od;
  od;

  SetEdgeWeights(digraph, weights);
  return digraph;
end);

InstallMethod(IsNegativeEdgeWeightedDigraph, "for an edge weighted digraph",
[IsDigraph and HasEdgeWeights],
function(digraph)
  local weights, u, w;

  weights := EdgeWeights(digraph);

  for u in weights do
      for w in u do
          if Float(w) < Float(0) then
              return true;
          fi;
      od;
  od;
  return false;
end);

#############################################################################
# 2. Copies of edge weights
#############################################################################

InstallMethod(EdgeWeightsMutableCopy, "for a digraph with edge weights",
[IsDigraph and HasEdgeWeights],
D -> List(EdgeWeights(D), ShallowCopy));

#############################################################################
# 3. Minimum Spanning Trees
#############################################################################

DIGRAPHS_Find := function(parent, i)
    if parent[i] = i then
        return i;
    fi;

    parent[i] := DIGRAPHS_Find(parent, parent[i]);
    return parent[i];
end;

DIGRAPHS_Union := function(parent, rank, x, y)
    local xroot, yroot;

    xroot := DIGRAPHS_Find(parent, x);
    yroot := DIGRAPHS_Find(parent, y);

    if rank[xroot] < rank[yroot] then
        parent[xroot] := yroot;
    elif rank[xroot] > rank[yroot] then
        parent[yroot] := xroot;
    else
        parent[yroot] := xroot;
        rank[xroot]   := rank[xroot] + 1;
    fi;
end;

InstallMethod(DigraphEdgeWeightedMinimumSpanningTree,
"for an edge weighted digraph",
[IsDigraph and HasEdgeWeights],
function(digraph)
    local weights, numberOfVertices, edgeList, u,
    outNeigbours, idx, v, w, mst, mstWeights, i, e,
    parent, rank, total, node, x, y;

    # check graph is connected
    if not IsConnectedDigraph(digraph) then
        ErrorNoReturn("digraph must be connected,");
    fi;

    weights := EdgeWeights(digraph);

    # create a list of edges containing u-v
    # w: the weight of the edge
    # u: the start vertex
    # v: the finishing vertex of that edge
    numberOfVertices := DigraphNrVertices(digraph);

    edgeList := [];
    for u in DigraphVertices(digraph) do
        outNeigbours := OutNeighbors(digraph)[u];
        for idx in [1 .. Size(outNeigbours)] do
            v := outNeigbours[idx];  # the out neighbour
            w := weights[u][idx];    # the weight to the out neighbour

            Add(edgeList, [w, u, v]);
        od;
    od;

    mst        := [];
    mstWeights := [];

    i := 1;
    e := 1;

    # sort edge weights by their weight
    StableSortBy(edgeList, x -> x[1]);

    parent := [];
    rank   := [];

    for v in [1 .. numberOfVertices] do
        Add(parent, v);
        Add(rank, 1);
        Add(mst, []);
        Add(mstWeights, []);
    od;

    total := 0;
    while e < (numberOfVertices) do
        node := edgeList[i];

        w := node[1];
        u := node[2];
        v := node[3];

        i := i + 1;

        x := DIGRAPHS_Find(parent, u);
        y := DIGRAPHS_Find(parent, v);

        # if cycle doesn't exist
        if x <> y then
            e     := e + 1;
            total := total + w;

            Add(mst[u], v);
            Add(mstWeights[u], w);

            DIGRAPHS_Union(parent, rank, x, y);
        fi;
    od;

    return rec(total := total, mst := EdgeWeightedDigraph(mst, mstWeights));
end);
