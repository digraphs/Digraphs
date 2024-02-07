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

#############################################################################
# 4. Shortest Path
#############################################################################

DIGRAPHS_Edge_Weighted_Dijkstra := function(digraph, source)
    local weights, digraphVertices, nrVertices, adj, u, outNeighbours, idx, v, w,
    distances, parents, edges, vertex, visited, queue, node, currDist, neighbour,
    edgeInfo, distance, i, d;

    weights := EdgeWeights(digraph);

    digraphVertices := DigraphVertices(digraph);
    nrVertices      := Size(digraphVertices);

    # Create an adjacency map for the edges with their associated weight
    adj := HashMap();
    for u in digraphVertices do
        adj[u] := HashMap();
        outNeighbours := OutNeighbors(digraph)[u];
        for idx in [1 .. Size(outNeighbours)] do
            v := outNeighbours[idx];  # the out neighbour
            w := weights[u][idx];     # the weight to the out neighbour

            # an edge to v already exists
            if v in adj[u] then
                # check if edge weight is less than current weight,
                # and keep track of edge idx
                if w < adj[u][v][1] then
                    adj[u][v] := [w, idx];
                fi;
            else  # edge doesn't exist already, so add it
                adj[u][v] := [w, idx];
            fi;
        od;

    od;

    distances := EmptyPlist(nrVertices);
    parents   := EmptyPlist(nrVertices);
    edges     := EmptyPlist(nrVertices);

    for vertex in digraphVertices do
        distances[vertex] := infinity;
    od;

    distances[source] := 0;
    parents[source]   := fail;
    edges[source]     := fail;

    visited := BlistList(digraphVertices, []);

    # make binary heap by priority of
    # index 1 of each element (the cost to get to the node)
    queue := BinaryHeap({x, y} -> x[1] > y[1]);
    Push(queue, [0, source]);  # the source vertex with cost 0

    while not IsEmpty(queue) do
        node := Pop(queue);

        currDist := node[1];
        u        := node[2];

        if visited[u] then
            continue;
        fi;

        visited[u] := true;

        for neighbour in KeyValueIterator(adj[u]) do
            v        := neighbour[1];
            edgeInfo := neighbour[2];
            w        := edgeInfo[1];
            idx      := edgeInfo[2];

            distance := currDist + w;

            if Float(distance) < Float(distances[v]) then
                distances[v] := distance;

                parents[v] := u;
                edges[v]   := idx;

                if not visited[v] then
                    Push(queue, [distance, v]);
                fi;
            fi;
        od;
    od;

    # fill lists with -1 if no path is possible
    for i in [1 .. Size(distances)] do
        d := distances[i];
        if Float(d) = Float(infinity) then
            distances[i] := fail;
            parents[i]   := fail;
            edges[i]     := fail;
        fi;
    od;

    return rec(distances := distances, parents := parents, edges := edges);
end;

DIGRAPHS_Edge_Weighted_Bellman_Ford := function(digraph, source)
    local edgeList, weights, digraphVertices, distances, u,
    outNeighbours, idx, v, w, _,
    vertex, edge, parents, edges, d, i, flag;

    weights := EdgeWeights(digraph);

    digraphVertices := DigraphVertices(digraph);
    edgeList := [];
    for u in DigraphVertices(digraph) do
        outNeighbours := OutNeighbors(digraph)[u];
        for idx in [1 .. Size(outNeighbours)] do
            v := outNeighbours[idx];  # the out neighbour
            w := weights[u][idx];     # the weight to the out neighbour

            Add(edgeList, [w, u, v, idx]);
        od;
    od;

    distances := [digraphVertices];
    parents   := [digraphVertices];
    edges     := [digraphVertices];

    for vertex in digraphVertices do
        distances[vertex] := infinity;
    od;

    distances[source] := 0;
    parents[source]   := fail;
    edges[source]     := fail;

    flag := true;

    # relax all edges: update weight with smallest edges
    for _ in digraphVertices do
        for edge in edgeList do
            w := edge[1];
            u := edge[2];
            v := edge[3];
            idx := edge[4];

            if Float(distances[u]) <> Float(infinity)
            and Float(distances[u]) + Float(w) < Float(distances[v]) then
                distances[v] := distances[u] + w;

                parents[v] := u;
                edges[v]   := idx;
                flag       := false;
            fi;
        od;

        if flag then
            break;
        fi;
    od;

    # check for negative cycles
    for edge in edgeList do
        w := edge[1];
        u := edge[2];
        v := edge[3];

        if Float(distances[u]) <> Float(infinity)
        and Float(distances[u]) + Float(w) < Float(distances[v]) then
            ErrorNoReturn("negative cycle exists,");
        fi;
    od;

    # fill lists with fail if no path is possible
    for i in [1 .. Size(distances)] do
        d := distances[i];
        if Float(d) = Float(infinity) then
            distances[i] := fail;
            parents[i]   := fail;
            edges[i]     := fail;
        fi;
    od;

    return rec(distances := distances, parents := parents, edges := edges);
end;

InstallMethod(DigraphEdgeWeightedShortestPath, "for an edge weighted digraph",
[IsDigraph and HasEdgeWeights, IsPosInt],
function(digraph, source)
    local nrVertices;
    # must be strongly connected
    # if not IsStronglyConnectedDigraph(digraph) then
    #     ErrorNoReturn("digraph must be strongly connected,");
    # fi;

    # sources must exist in graph
    nrVertices := DigraphNrVertices(digraph);
    if source < 1 or source > nrVertices then
        ErrorNoReturn("source vertex does not exist within digraph");
    fi;

    if IsNegativeEdgeWeightedDigraph(digraph) then
        return DIGRAPHS_Edge_Weighted_Bellman_Ford(digraph, source);
    else
        return DIGRAPHS_Edge_Weighted_Dijkstra(digraph, source);
    fi;
end);

DIGRAPHS_Edge_Weighted_FloydWarshall := function(digraph)
    local weights, adjMatrix, digraphVertices,
    nrVertices, u, v, edges, outs, idx,
    outNeighbours, w, i, k, distances, parents, pathParents;

    weights         := EdgeWeights(digraph);
    digraphVertices := DigraphVertices(digraph);
    nrVertices      := Size(digraphVertices);
    outs            := OutNeighbors(digraph);

    # Create adjacency matrix
    adjMatrix := EmptyPlist(nrVertices);
    parents   := EmptyPlist(nrVertices);
    edges     := EmptyPlist(nrVertices);

    for u in digraphVertices do
        adjMatrix[u] := EmptyPlist(nrVertices);
        outNeighbours := outs[u];
        for idx in [1 .. Size(outNeighbours)] do
            v := outNeighbours[idx];  # the out neighbour
            w := weights[u][idx];     # the weight to the out neighbour

            # only put min edge in if multiple edges exists
            if IsBound(adjMatrix[u][v]) then
                if w < adjMatrix[u][v][1] then
                    adjMatrix[u][v] := [w, idx];
                fi;
            else
                adjMatrix[u][v] := [w, idx];
            fi;
        od;
    od;

    # Create distances adj matrix
    distances := EmptyPlist(nrVertices);
    for u in digraphVertices do
        distances[u] := EmptyPlist(nrVertices);
        parents[u]   := EmptyPlist(nrVertices);
        edges[u]     := EmptyPlist(nrVertices);

        for v in digraphVertices do
            distances[u][v] := infinity;
            parents[u][v] := fail;
            edges[u][v] := fail;

            if u = v then
                distances[u][v] := 0;
                # if the same node, then the node has no parents
                parents[u][v] := fail;
                edges[u][v]   := fail;
            elif IsBound(adjMatrix[u][v]) then
                w   := adjMatrix[u][v][1];
                idx := adjMatrix[u][v][2];

                distances[u][v] := w;
                parents[u][v]   := u;
                edges[u][v]     := idx;

            fi;
        od;
    od;

    for k in [1 .. nrVertices] do
        for u in [1 .. nrVertices] do
            for v in [1 .. nrVertices] do
                if distances[u][k] < infinity and distances[k][v] < infinity then
                    if distances[u][k] + distances[k][v] < distances[u][v] then
                        distances[u][v] := distances[u][k] + distances[k][v];
                        parents[u][v]   := parents[u][k];
                        edges[u][v]     := edges[k][v];
                    fi;
                fi;
            od;
        od;
    od;

    # detect negative cycles
    for i in [1 .. nrVertices] do
        if distances[i][i] < 0 then
            ErrorNoReturn("negative cycle exists,");
        fi;
    od;

    # replace infinity with fails
    for u in [1 .. nrVertices] do
        for v in [1 .. nrVertices] do
            if distances[u][v] = infinity then
                distances[u][v] := fail;
            fi;
        od;
    od;

    pathParents := EmptyPlist(nrVertices);

    for u in [1 .. nrVertices] do
        pathParents[u] := EmptyPlist(nrVertices);
        for v in [1 .. nrVertices] do
            pathParents[u][v] := parents[u][v];
        od;
    od;

    return rec(distances := distances, parents := pathParents, edges := edges);
end;

DIGRAPHS_Edge_Weighted_Johnson := function(digraph)
    local digraphVertices, nrVertices, u, v, edges,
    idx, outNeighbours, w, distances,
    mutableWeights, mutableOuts, bellmanDistances,
    distance, parents, dijkstra, bellman;

    mutableWeights := EdgeWeightsMutableCopy(digraph);

    digraphVertices := DigraphVertices(digraph);
    nrVertices := Size(digraphVertices);
    mutableOuts := OutNeighborsMutableCopy(digraph);

    # add new u that connects to all other v with weight 0
    Add(mutableOuts, [], 1);
    Add(mutableWeights, [], 1);

    # fill new u
    for v in [1 .. nrVertices] do
        Add(mutableOuts[1], v + 1);
        Add(mutableWeights[1], 0);
    od;

    # update v to v + 1
    for u in [2 .. nrVertices + 1] do
        for v in [1 .. Size(mutableOuts[u])] do
            mutableOuts[u][v] := mutableOuts[u][v] + 1;
        od;
    od;

    digraph := EdgeWeightedDigraph(mutableOuts, mutableWeights);
    bellman := DIGRAPHS_Edge_Weighted_Bellman_Ford(digraph, 1);
    bellmanDistances := bellman.distances;

    mutableWeights := EdgeWeightsMutableCopy(digraph);
    digraphVertices := DigraphVertices(digraph);
    nrVertices := Size(digraphVertices);
    mutableOuts := OutNeighborsMutableCopy(digraph);

    # set weight(u, v)
    # equal to weight(u, v) + bell_dist(u) - bell_dist(v) for each edge (u, v)
    for u in digraphVertices do
        outNeighbours := mutableOuts[u];
        for idx in [1 .. Size(outNeighbours)] do
            v                      := outNeighbours[idx];
            w                      := mutableWeights[u][idx];
            mutableWeights[u][idx] := w +
            bellmanDistances[u] - bellmanDistances[v];
        od;
    od;

    Remove(mutableOuts, 1);
    Remove(mutableWeights, 1);

    # update v to v - 1
    for u in [1 .. Size(mutableOuts)] do
        for v in [1 .. Size(mutableOuts[u])] do
            mutableOuts[u][v] := mutableOuts[u][v] - 1;
        od;
    od;

    digraph         := EdgeWeightedDigraph(mutableOuts, mutableWeights);
    digraphVertices := DigraphVertices(digraph);

    distance := EmptyPlist(nrVertices);
    parents  := EmptyPlist(nrVertices);
    edges    := EmptyPlist(nrVertices);

    # run dijkstra
    for u in digraphVertices do
        dijkstra    := DIGRAPHS_Edge_Weighted_Dijkstra(digraph, u);
        distance[u] := dijkstra.distances;
        parents[u]  := dijkstra.parents;
        edges[u]    := dijkstra.edges;
    od;

    # correct distances
    for u in digraphVertices do
        for v in digraphVertices do
            if distance[u][v] = fail then
                continue;
            fi;
            distance[u][v] := distance[u][v] +
            (bellmanDistances[v + 1] - bellmanDistances[u + 1]);
        od;
    od;

    return rec(distances := distance, parents := parents, edges := edges);
end;

InstallMethod(DigraphEdgeWeightedShortestPaths, "for an edge weighted digraph",
[IsDigraph and HasEdgeWeights],
function(digraph)
    local maxNodes, threshold, digraphVertices, nrVertices, nrEdges;

    digraphVertices := DigraphVertices(digraph);
    nrVertices := Size(digraphVertices);
    nrEdges := DigraphNrEdges(digraph);

    maxNodes := nrVertices * (nrVertices - 1);

    # the boundary for performance is edge weight 0.125
    # so if nr edges for vertices v is less
    # than total number of edges in a connected
    # graph we use johnson's algorithm
    # which performs better on sparse graphs, otherwise
    # we use floyd warshall algorithm.
    # This information is gathered from benchmarking tests.
    threshold := Int(maxNodes / 8);
    if nrEdges <= threshold then
        return DIGRAPHS_Edge_Weighted_Johnson(digraph);
    else
        return DIGRAPHS_Edge_Weighted_FloydWarshall(digraph);
    fi;
end);

#############################################################################
# 5. Maximum Flow
#############################################################################

InstallMethod(DigraphMaximumFlow, "for an edge weighted digraph",
[IsDigraph and HasEdgeWeights, IsPosInt, IsPosInt],
function(digraph, source, sink)
    local push, relabel, discharge, GetFlowInformation, PushRelabel;

    push := function(capacityMatrix, flowMatrix, excess, queue, u, v)
        local d;

        d := Minimum(excess[u], capacityMatrix[u][v] - flowMatrix[u][v]);

        flowMatrix[u][v] := flowMatrix[u][v] + d;
        flowMatrix[v][u] := flowMatrix[v][u] - d;
        excess[u]        := excess[u] - d;
        excess[v]        := excess[v] + d;

        if d = 1 and excess[v] = d then
            PlistDequePushBack(queue, v);
        fi;
    end;

    relabel := function(capacityMatrix, flowMatrix, height, u)
        local d, v;

        d := infinity;
        for v in [1 .. Size(capacityMatrix)] do
            if capacityMatrix[u][v] - flowMatrix[u][v] > 0 then
                d := Minimum(d, height[v]);
            fi;
        od;
        if d < infinity then
            height[u] := d + 1;
        fi;

    end;

    discharge := function(
        capacityMatrix, flowMatrix, excess, seen, height, queue, u)
        local v;

        while excess[u] > 0 do
            if seen[u] <= Size(capacityMatrix) then
                v := seen[u];
                if capacityMatrix[u][v] - flowMatrix[u][v] > 0
                and height[u] > height[v] then
                    push(capacityMatrix, flowMatrix, excess, queue, u, v);
                else
                    seen[u] := seen[u] + 1;
                fi;
            else
                relabel(capacityMatrix, flowMatrix, height, u);
                seen[u] := 1;
            fi;
        od;
    end;

    GetFlowInformation := function(digraph, flowMatrix, source)
        local parents, flows, u, v, f, outs, outNeighbours,
        nrVertices, maxFlow, _, idx, weights, w;

        outs    := OutNeighbors(digraph);
        weights := EdgeWeights(digraph);

        nrVertices := Size(flowMatrix);

        parents := EmptyPlist(nrVertices);
        flows   := EmptyPlist(nrVertices);
        maxFlow := 0;

        # create empty 2D list for output
        for _ in [1 .. nrVertices] do
            Add(parents, []);
            Add(flows, []);
        od;

        # initialise source values
        parents[source] := [];
        flows[source]   := [];

        for u in [1 .. nrVertices] do
            for v in [1 .. nrVertices] do
                f := flowMatrix[u][v];
                if Float(f) > Float(0) then
                    outNeighbours := outs[u];
                    if u = source then
                        maxFlow := maxFlow + f;
                    fi;

                    for idx in [1 .. Size(outNeighbours)] do
                        w := weights[u][idx];
                        if outNeighbours[idx] = v then
                            if f >= w then
                                Add(flows[v], w);
                                f := f - w;
                            elif f >= 0 then
                                Add(flows[v], f);
                                f := 0;
                            fi;
                            Add(parents[v], u);
                        fi;
                    od;

                fi;
            od;
        od;

        return [parents, flows, maxFlow];
    end;

    PushRelabel := function(digraph, source, sink)
        local weights, capacityMatrix, digraphVertices,
        nrVertices, u, v, outs, idx, outNeighbours, w, queue, flowMatrix, seen,
        excess, height, flowInformation;

        weights         := EdgeWeights(digraph);
        digraphVertices := DigraphVertices(digraph);
        nrVertices      := Size(digraphVertices);
        outs            := OutNeighbors(digraph);
        capacityMatrix  := EmptyPlist(nrVertices);
        flowMatrix      := EmptyPlist(nrVertices);
        seen            := EmptyPlist(nrVertices);
        height          := EmptyPlist(nrVertices);
        excess          := EmptyPlist(nrVertices);
        queue           := PlistDeque();

        if source < 1 or source > nrVertices then
            ErrorNoReturn("invalid source,");
        fi;

        if sink < 1 or sink > nrVertices then
            ErrorNoReturn("invalid sink,");
        fi;

        # fill adj and max flow with zeroes
        for u in digraphVertices do
            capacityMatrix[u] := EmptyPlist(nrVertices);
            flowMatrix[u]     := EmptyPlist(nrVertices);
            seen[u]           := 1;
            height[u]         := 0;
            excess[u]         := 0;

            if u <> source and u <> sink then
                PlistDequePushBack(queue, u);
            fi;

            for v in digraphVertices do
                capacityMatrix[u][v] := 0;
                flowMatrix[u][v]     := 0;
            od;
        od;

        for u in digraphVertices do
            outNeighbours := outs[u];
            for idx in [1 .. Size(outNeighbours)] do
                v := outNeighbours[idx];  # the out neighbour
                w := weights[u][idx];     # the weight to the out neighbour

                capacityMatrix[u][v] := capacityMatrix[u][v] + w;
            od;
        od;

        height[source] := nrVertices;
        excess[source] := infinity;

        for v in [1 .. nrVertices] do
            if v <> source then
                push(capacityMatrix, flowMatrix, excess, queue, source, v);
            fi;
        od;

        while not IsEmpty(queue) do
            u := PlistDequePopFront(queue);
            if u <> source and u <> sink then
                discharge(capacityMatrix, flowMatrix,
                excess, seen, height, queue, u);
            fi;
        od;

        flowInformation := GetFlowInformation(digraph, flowMatrix, source);

        return rec(parents := flowInformation[1],
                    flows := flowInformation[2],
                maxFlow := flowInformation[3]);
    end;

    return PushRelabel(digraph, source, sink);
end);

#############################################################################
# 6. Random Edge Weighted Digraph
#############################################################################

DIGRAPHS_Generate_Unique_Weights := function(digraph)
    local weights, digraphVertices,
    nrEdges, randomWeights, outNeighbours, u, idx, randWeightIdx;

    digraphVertices := DigraphVertices(digraph);
    nrEdges := DigraphNrEdges(digraph) + 1;

    randomWeights := Shuffle([1 .. nrEdges]);
    weights := [];
    randWeightIdx := 1;

    # Create random weights for each edge.
    # weights are unique [1..number of edges + 1]
    for u in digraphVertices do
        outNeighbours := OutNeighbors(digraph)[u];
        Add(weights, []);
        for idx in [1 .. Size(outNeighbours)] do
            weights[u][idx] := randomWeights[randWeightIdx];
            randWeightIdx   := randWeightIdx + 1;
        od;
    od;

    return weights;
end;

DIGRAPHS_Random_Edge_Weighted_Digraph_N := function(n)
    local digraph, weights;

    digraph := RandomDigraphCons(IsImmutableDigraph, n);
    weights := DIGRAPHS_Generate_Unique_Weights(digraph);

    return EdgeWeightedDigraph(digraph, weights);
end;

DIGRAPHS_Random_Edge_Weighted_Digraph_N_P := function(n, p)
    local digraph, weights;

    digraph := RandomDigraphCons(IsImmutableDigraph, n, p);
    weights := DIGRAPHS_Generate_Unique_Weights(digraph);

    return EdgeWeightedDigraph(digraph, weights);
end;

DIGRAPHS_Random_Edge_Weighted_Digraph_Filt_N_P := function(filt, n, p)
    local digraph, weights;

    digraph := RandomDigraphCons(filt, n, p);
    weights := DIGRAPHS_Generate_Unique_Weights(digraph);

    return EdgeWeightedDigraph(digraph, weights);
end;

InstallMethod(RandomUniqueEdgeWeightedDigraph,
"for a pos int", [IsPosInt],
DIGRAPHS_Random_Edge_Weighted_Digraph_N);

InstallMethod(RandomUniqueEdgeWeightedDigraph,
"for a pos int and a float", [IsPosInt, IsFloat],
{n, p} -> DIGRAPHS_Random_Edge_Weighted_Digraph_N_P(n, p));

InstallMethod(RandomUniqueEdgeWeightedDigraph,
"for a pos int and a rational", [IsPosInt, IsRat],
{n, p} -> DIGRAPHS_Random_Edge_Weighted_Digraph_N_P(n, p));

InstallMethod(RandomUniqueEdgeWeightedDigraph,
"for a func, a pos int, and a float", [IsFunction, IsPosInt, IsFloat],
{filt, n, p} -> DIGRAPHS_Random_Edge_Weighted_Digraph_Filt_N_P(filt, n, p));

InstallMethod(RandomUniqueEdgeWeightedDigraph,
"for a func, a pos int, and a rational", [IsFunction, IsPosInt, IsRat],
{filt, n, p} -> DIGRAPHS_Random_Edge_Weighted_Digraph_Filt_N_P(filt, n, p));

#############################################################################
# 7. Painting Edge Weighted Digraph
#############################################################################
InstallMethod(DigraphFromPath, "for a digraph, a record, and a pos int",
[IsDigraph, IsRecord, IsPosInt],
function(_, record, destination)
    # TODO: digraph is not used, which is surprising and may suggest
    # confusion in design.  We should work this out.
    local idx, distances, edges, p, parents,
    nrVertices, outNeighbours, vertex;

    distances  := record.distances;
    edges      := record.edges;
    parents    := record.parents;
    nrVertices := Size(distances);

    outNeighbours := EmptyPlist(nrVertices);

    # fill out neighbours with empty lists
    for idx in [1 .. nrVertices] do
        Add(outNeighbours, []);
    od;

    vertex := destination;
    # while vertex isn't the start vertex
    while parents[vertex] <> fail do
        p := parents[vertex];  # parent of vertex is p

        Add(outNeighbours[p], vertex);
        vertex := p;
    od;

    return Digraph(outNeighbours);
end);

InstallMethod(DigraphFromPaths,
"for a digraph, and a record", [IsDigraph, IsRecord],
function(_, record)
    # TODO: digraph is not used - see DigraphFromPath
    local idx, distances, edges, parents, nrVertices, outNeighbours,
    u, v;

    distances  := record.distances;
    edges      := record.edges;
    parents    := record.parents;
    nrVertices := Size(distances);

    outNeighbours := EmptyPlist(nrVertices);

    # fill out neighbours with empty lists
    for idx in [1 .. nrVertices] do
        Add(outNeighbours, []);
    od;

    for idx in [1 .. Size(parents)] do
        u := parents[idx];
        v := idx;

        # this is the start vertex
        if u = fail then
            continue;
        fi;

        Add(outNeighbours[u], v);
    od;

    return Digraph(outNeighbours);
end);

DIGRAPHS_Get_Least_Weight_Edge := function(digraph, u, v)
    local weights, edgeWeights, smallestEdgeIdx, minWeight, w, outs, idx;

    outs    := OutNeighbours(digraph)[u];
    weights := EdgeWeights(digraph);

    edgeWeights := weights[u];

    smallestEdgeIdx := 1;
    minWeight       := infinity;
    for idx in [1 .. Size(edgeWeights)] do
        w := edgeWeights[idx];
        if w < minWeight and outs[idx] = v then
            minWeight       := w;
            smallestEdgeIdx := idx;
        fi;
    od;

    return smallestEdgeIdx;
end;

InstallMethod(DotEdgeWeightedDigraph, "for a digraph, a digraph, and a record",
[IsDigraph, IsDigraph, IsRecord],
function(digraph, subdigraph, options)
    local digraphVertices, outsOriginal,
    outNeighboursOriginal, nrVertices, outsSubdigraph,
    outNeighboursSubdigraph, edgeColours,
    vertColours, u, v, idxOfSmallestEdge, opts,
    edgeColour, sourceColour, destColour, vertColour, weights, default, name;

    default             := rec(
        highlightColour := "blue",
        edgeColour      := "black",
        vertColour      := "lightpink",
        sourceColour    := "green",
        destColour      := "red");

    if IsRecord(options) then
        opts := ShallowCopy(options);
    fi;

    for name in RecNames(default) do
        if IsBound(opts.(name)) then
            default.(name) := opts.(name);
        fi;
    od;

    digraphVertices := DigraphVertices(subdigraph);
    nrVertices := Size(digraphVertices);
    outsOriginal := OutNeighbors(digraph);
    outsSubdigraph := OutNeighbors(subdigraph);

    edgeColours := EmptyPlist(nrVertices);
    vertColours := EmptyPlist(nrVertices);

    for u in digraphVertices do
        vertColours[u] := default.vertColour;
        edgeColours[u] := [];
        outNeighboursSubdigraph := outsSubdigraph[u];
        outNeighboursOriginal := outsOriginal[u];

        # make everything black
        for v in outNeighboursOriginal do
            Add(edgeColours[u], default.edgeColour);
        od;

        # paint mst edges
        for v in outNeighboursSubdigraph do
            idxOfSmallestEdge := DIGRAPHS_Get_Least_Weight_Edge(digraph, u, v);
            edgeColours[u][idxOfSmallestEdge] := default.highlightColour;
        od;
    od;

    # set source and dest colours
    if IsBound(opts.source) then
        if 1 <= opts.source and opts.source <= nrVertices then
            vertColours[opts.source] := default.sourceColour;
        else
            ErrorNoReturn("source vertex does not exist,");
        fi;
    fi;

    if IsBound(opts.dest) then
        if 1 <= opts.dest and opts.dest <= nrVertices then
            vertColours[opts.dest] := default.destColour;
        else
            ErrorNoReturn("destination vertex does not exist,");
        fi;
    fi;

    weights := EdgeWeights(digraph);

   return DotColoredEdgeWeightedDigraph(
    digraph, vertColours, edgeColours, weights);
end);

# InstallMethod(DigraphMinimumCuts, "for a digraph",
# [IsDigraph],
# function(digraph)
#     local contract, minCut, fastMinCut, KargerStein;

#     contract := function(digraph, options)
#         local digraphVertices, nrVertices, nrV, nrEdges, i, u, v,
#         edgeList, outNeigbours, idx, randomEdgeIdx, cuts, edgesCut, parent,
#         x, y, rank, opts, default, name;

#         default := rec(minV := 2);

#         if IsRecord(options) then
#             opts := ShallowCopy(options);
#         else
#             opts := rec();
#         fi;

#         for name in RecNames(default) do
#             if IsBound(opts.(name)) then
#                 default.(name) := opts.(name);
#             fi;
#         od;

#         # weights := EdgeWeights(digraph);
#         digraphVertices := DigraphVertices(digraph);
#         nrVertices      := Size(digraphVertices);
#         nrEdges         := Size(DigraphEdges(digraph));

#         edgeList := [];
#         for u in digraphVertices do
#             outNeigbours := OutNeighbors(digraph)[u];
#             for idx in [1 .. Size(outNeigbours)] do
#                 v := outNeigbours[idx];  # the out neighbour

#                 Add(edgeList, [u, v]);
#             od;
#         od;

#         # sort edge weights by their weight
#         i := Size(edgeList);

#         parent := [];
#         rank   := [];

#         for v in [1 .. nrVertices] do
#             Add(parent, v);
#             Add(rank, 1);
#         od;

#         edgesCut := [];
#         nrV      := nrVertices;
#         while nrV > default.minV do
#             randomEdgeIdx := Random([1 .. Size(edgeList)]);

#             u := edgeList[randomEdgeIdx][1];
#             v := edgeList[randomEdgeIdx][2];

#             x := DIGRAPHS_Find(parent, u);
#             y := DIGRAPHS_Find(parent, v);

#             if x <> y then
#                 nrV := nrV - 1;
#                 DIGRAPHS_Union(parent, rank, x, y);
#             fi;
#         od;

#         cuts  := 0;

#         for i in [1 .. nrEdges] do
#             u := edgeList[i][1];
#             v := edgeList[i][2];

#             x := DIGRAPHS_Find(parent, u);
#             y := DIGRAPHS_Find(parent, v);

#             if x <> y then
#                 Add(edgesCut, [u, v]);
#                 cuts := cuts + 1;
#             fi;
#         od;

#         return rec(cuts := cuts, edgesCut := edgesCut);
#     end;

#     minCut := function(digraph)
#         local nrEdges, nrVertices, upperBound, i, cutInfo, edgesCut;

#         nrEdges := Size(DigraphEdges(digraph));
#         nrVertices := Size(DigraphVertices(digraph));

#         # upperBound := Int(nrVertices *
#         # (nrVertices - 1) * Log((nrVertices/2), 2));
#         upperBound := nrVertices;

#         for i in [1 .. upperBound] do
#             cutInfo := contract(digraph, rec());
#             if cutInfo.cuts <= nrEdges then
#                 nrEdges  := cutInfo.cuts;
#                 edgesCut := cutInfo.edgesCut;
#             fi;
#         od;

#         return rec(cuts := nrEdges, edgesCut := edgesCut);
#     end;

#     fastMinCut := function(digraph)
#         local nrVertices, g1, g2;

#         nrVertices := Size(DigraphVertices(digraph));
#         if (nrVertices <= 6) then
#             return minCut(digraph);
#         fi;

#         g1 := contract(digraph, rec(minV := 2));
#         g2 := contract(digraph, rec(minV := 2));

#         if g1.cuts <= g2.cuts then
#             return rec(cuts := g1.cuts, edgesCut := g1.edgesCut);
#         else
#             return rec(cuts := g2.cuts, edgesCut := g2.edgesCut);
#         fi;
#     end;

#     KargerStein := function(digraph)
#         local digraphVertices, nrVertices, nrEdges,
#         i, upperBound, edgesCut, cutInfo;

#         digraphVertices := DigraphVertices(digraph);
#         nrVertices      := Size(digraphVertices);
#         nrEdges         := Size(DigraphEdges(digraph));
#         edgesCut        := [];

#         # upperBound := Int(nrVertices * Log(nrVertices, 2)/(nrVertices - 1));
#         upperBound := nrVertices;

#         for i in [1 .. upperBound] do
#             cutInfo := fastMinCut(digraph);
#             if cutInfo.cuts <= nrEdges then
#                 nrEdges  := cutInfo.cuts;
#                 edgesCut := cutInfo.edgesCut;
#             fi;
#         od;

#         return  rec(cuts := nrEdges, edgesCut := edgesCut);
#     end;

#     return KargerStein(digraph);
# end);
