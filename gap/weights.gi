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
      ErrorNoReturn("the sizes of the out neighbours and weights for vertex ",
                    u, " must be equal,");
    fi;

    # check all elements of out neighbours are appropriate
    for idx in [1 .. Size(outNeighbours)] do
      if not (IsInt(outNeighbourWeights[idx])
              or IsFloat(outNeighbourWeights[idx])
              or IsRat(outNeighbourWeights[idx])) then
        ErrorNoReturn("out neighbour weight must be ",
                      "an integer, float or rational,");
      fi;
    od;
  od;

  SetEdgeWeights(digraph, weights);
  return digraph;
end);

InstallMethod(IsNegativeEdgeWeightedDigraph, "for a digraph with edge weights",
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

InstallMethod(EdgeWeightedDigraphTotalWeight,
"for a digraph with edge weights",
[IsDigraph and HasEdgeWeights],
D -> Sum(EdgeWeights(D), Sum));

#############################################################################
# 2. Copies of edge weights
#############################################################################

InstallMethod(EdgeWeightsMutableCopy, "for a digraph with edge weights",
[IsDigraph and HasEdgeWeights],
D -> List(EdgeWeights(D), ShallowCopy));

#############################################################################
# 3. Minimum Spanning Trees
#############################################################################

InstallMethod(EdgeWeightedDigraphMinimumSpanningTree,
"for a digraph with edge weights",
[IsDigraph and HasEdgeWeights],
function(digraph)
  local weights, numberOfVertices, edgeList, u, outNeighbours, idx, v, w, mst,
        mstWeights, partition, i, nrEdges, total, node, x, y, out;

  # check graph is connected
  if not IsConnectedDigraph(digraph) then
    ErrorNoReturn("the argument <digraph> must be a connected digraph,");
  fi;

  weights := EdgeWeights(digraph);

  # create a list of edges containing u-v
  # w: the weight of the edge
  # u: the start vertex
  # v: the finishing vertex of that edge
  numberOfVertices := DigraphNrVertices(digraph);
  edgeList := [];
  for u in DigraphVertices(digraph) do
    outNeighbours := OutNeighboursOfVertex(digraph, u);
    for idx in [1 .. Size(outNeighbours)] do
      v := outNeighbours[idx];  # the out neighbour
      w := weights[u][idx];     # the weight to the out neighbour
      Add(edgeList, [w, u, v]);
    od;
  od;

  # sort edge weights by their weight
  StableSortBy(edgeList, x -> x[1]);

  mst        := EmptyPlist(numberOfVertices);
  mstWeights := EmptyPlist(numberOfVertices);

  partition := PartitionDS(IsPartitionDS, numberOfVertices);

  for v in [1 .. numberOfVertices] do
    Add(mst, []);
    Add(mstWeights, []);
  od;

  i := 1;
  nrEdges := 0;
  total := 0;
  while nrEdges < numberOfVertices - 1 do
    node := edgeList[i];

    w := node[1];
    u := node[2];
    v := node[3];

    i := i + 1;

    x := Representative(partition, u);
    y := Representative(partition, v);

    # if cycle doesn't exist
    if x <> y then
      Add(mst[u], v);
      Add(mstWeights[u], w);
      nrEdges := nrEdges + 1;
      total := total + w;
      Unite(partition, x, y);
    fi;
  od;

  out := EdgeWeightedDigraph(mst, mstWeights);
  SetEdgeWeightedDigraphTotalWeight(out, total);
  return out;
end);

#############################################################################
# 4. Shortest Path
#############################################################################
#
# Three different "shortest path" problems are solved:
# - All pairs:              DigraphShortestPaths(digraph)
# - Single source:          DigraphShortestPaths(digraph, source)
# - Source and destination: DigraphShortestPath (digraph, source, dest)
#
# The "all pairs" problem has two algorithms:
# - Johnson: better for sparse digraphs
# - Floyd-Warshall: better for dense graphs
#
# The "single source" problem has three algorithms:
# - If "all pairs" is already known, extract information for the given source
# - Dijkstra: faster, but cannot handle negative weights
# - Bellman-Ford: slower, but handles negative weights
#
# The "source and destination" problem calls the "single source" problem and
# extracts information for the given destination.
#
# Justification and benchmarks are in Raiyan's MSci thesis, Chapter 6.
#

InstallMethod(EdgeWeightedDigraphShortestPaths,
"for a digraph with edge weights",
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

InstallMethod(EdgeWeightedDigraphShortestPaths,
"for a digraph with edge weights and known shortest paths and a pos int",
[IsDigraph and HasEdgeWeights and HasEdgeWeightedDigraphShortestPaths, IsPosInt],
function(digraph, source)
  local all_paths;
  if not source in DigraphVertices(digraph) then
    ErrorNoReturn("the 2nd argument <source> must be a vertex of the ",
                  "digraph <digraph> that is the 1st argument,");
  fi;
  # Shortest paths are known for all vertices. Extract the one we want.
  all_paths := EdgeWeightedDigraphShortestPaths(digraph);
  return rec(distances := all_paths.distances[source],
             edges     := all_paths.edges[source],
             parents   := all_paths.parents[source]);
end);

InstallMethod(EdgeWeightedDigraphShortestPaths,
"for a digraph with edge weights and a pos int",
[IsDigraph and HasEdgeWeights, IsPosInt],
function(digraph, source)
  if not source in DigraphVertices(digraph) then
    ErrorNoReturn("the 2nd argument <source> must be a vertex of the ",
                  "digraph <digraph> that is the 1st argument,");
  fi;

  if IsNegativeEdgeWeightedDigraph(digraph) then
    return DIGRAPHS_Edge_Weighted_Bellman_Ford(digraph, source);
  else
    return DIGRAPHS_Edge_Weighted_Dijkstra(digraph, source);
  fi;
end);

InstallMethod(EdgeWeightedDigraphShortestPath,
"for a digraph with edge weights and two pos ints",
[IsDigraph and HasEdgeWeights, IsPosInt, IsPosInt],
function(digraph, source, dest)
  local paths, v, a, current, edge_index;
  if not source in DigraphVertices(digraph) then
    ErrorNoReturn("the 2nd argument <source> must be a vertex of the ",
                  "digraph <digraph> that is the 1st argument,");
  elif not dest in DigraphVertices(digraph) then
    ErrorNoReturn("the 3rd argument <dest> must be a vertex of the ",
                  "digraph <digraph> that is the 1st argument,");
  fi;

  # No trivial paths
  if source = dest then
    return fail;
  fi;

  # Get shortest paths information for this source vertex
  paths := EdgeWeightedDigraphShortestPaths(digraph, source);

  # Convert to DigraphPath's [v, a] format by exploring backwards from dest
  v := [dest];
  a := [];
  current := dest;
  while current <> source do
    edge_index := paths.edges[current];
    current := paths.parents[current];
    if edge_index = fail or current = fail then
      return fail;
    fi;
    Add(a, edge_index);
    Add(v, current);
  od;

  return [Reversed(v), Reversed(a)];
end);

InstallGlobalFunction(DIGRAPHS_Edge_Weighted_Johnson,
function(digraph)
  local vertices, nrVertices, mutableOuts, mutableWeights, new, v, bellman,
        bellmanDistances, u, outNeighbours, idx, w, distances, parents, edges,
        dijkstra;
  vertices := DigraphVertices(digraph);
  nrVertices := Size(vertices);
  mutableOuts := OutNeighborsMutableCopy(digraph);
  mutableWeights := EdgeWeightsMutableCopy(digraph);

  # add new u that connects to all other v with weight 0
  new := nrVertices + 1;
  mutableOuts[new] := [];
  mutableWeights[new] := [];

  # fill new u
  for v in [1 .. nrVertices] do
    mutableOuts[new][v] := v;
    mutableWeights[new][v] := 0;
  od;

  # calculate shortest paths from the new vertex (could be negative)
  digraph := EdgeWeightedDigraph(mutableOuts, mutableWeights);
  bellman := DIGRAPHS_Edge_Weighted_Bellman_Ford(digraph, new);
  bellmanDistances := bellman.distances;

  # new copy of neighbours and weights
  mutableOuts := OutNeighborsMutableCopy(digraph);
  mutableWeights := EdgeWeightsMutableCopy(digraph);

  # set weight(u, v) equal to weight(u, v) + bell_dist(u) - bell_dist(v)
  # for each edge (u, v)
  for u in vertices do
    outNeighbours := mutableOuts[u];
    for idx in [1 .. Size(outNeighbours)] do
      v                      := outNeighbours[idx];
      w                      := mutableWeights[u][idx];
      mutableWeights[u][idx] := w +
                                bellmanDistances[u] - bellmanDistances[v];
    od;
  od;

  Remove(mutableOuts, new);
  Remove(mutableWeights, new);

  digraph   := EdgeWeightedDigraph(mutableOuts, mutableWeights);
  distances := EmptyPlist(nrVertices);
  parents   := EmptyPlist(nrVertices);
  edges     := EmptyPlist(nrVertices);

  # run dijkstra
  for u in vertices do
    dijkstra     := DIGRAPHS_Edge_Weighted_Dijkstra(digraph, u);
    distances[u] := dijkstra.distances;
    parents[u]   := dijkstra.parents;
    edges[u]     := dijkstra.edges;
  od;

  # correct distances
  for u in vertices do
    for v in vertices do
      if distances[u][v] = fail then
        continue;
      fi;
      distances[u][v] := distances[u][v] +
                         bellmanDistances[v] - bellmanDistances[u];
    od;
  od;

  return rec(distances := distances, parents := parents, edges := edges);
end);

InstallGlobalFunction(DIGRAPHS_Edge_Weighted_FloydWarshall,
function(digraph)
  local weights, adjMatrix, vertices, nrVertices, u, v, edges, outs, idx,
        outNeighbours, w, i, k, distances, parents;
  weights    := EdgeWeights(digraph);
  vertices   := DigraphVertices(digraph);
  nrVertices := Size(vertices);
  outs       := OutNeighbours(digraph);

  # Create adjacency matrix with (minimum weight, edge index), or a hole
  adjMatrix := EmptyPlist(nrVertices);
  for u in vertices do
    adjMatrix[u] := EmptyPlist(nrVertices);
    outNeighbours := outs[u];
    for idx in [1 .. Size(outNeighbours)] do
      v := outNeighbours[idx];  # the out neighbour
      w := weights[u][idx];     # the weight to the out neighbour
      # Use minimum weight edge
      if (not IsBound(adjMatrix[u][v])) or (w < adjMatrix[u][v][1]) then
        adjMatrix[u][v] := [w, idx];
      fi;
    od;
  od;

  # Store shortest paths for single edges
  distances := EmptyPlist(nrVertices);
  parents   := EmptyPlist(nrVertices);
  edges     := EmptyPlist(nrVertices);
  for u in vertices do
    distances[u] := EmptyPlist(nrVertices);
    parents[u]   := EmptyPlist(nrVertices);
    edges[u]     := EmptyPlist(nrVertices);

    for v in vertices do
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

  # try every triple: distance from u to v via k
  for k in vertices do
    for u in vertices do
      if distances[u][k] < infinity then
        for v in vertices do
          if distances[k][v] < infinity then
            if distances[u][k] + distances[k][v] < distances[u][v] then
              distances[u][v] := distances[u][k] + distances[k][v];
              parents[u][v]   := parents[u][k];
              edges[u][v]     := edges[k][v];
            fi;
          fi;
        od;
      fi;
    od;
  od;

  # detect negative cycles
  for i in vertices do
    if distances[i][i] < 0 then
      ErrorNoReturn("1st arg <digraph> contains a negative-weighted cycle,");
    fi;
  od;

  # replace infinity with fails
  for u in vertices do
    for v in vertices do
      if distances[u][v] = infinity then
        distances[u][v] := fail;
      fi;
    od;
  od;

  return rec(distances := distances, parents := parents, edges := edges);
end);

InstallGlobalFunction(DIGRAPHS_Edge_Weighted_Dijkstra,
function(digraph, source)
  local weights, vertices, nrVertices, adj, u, outNeighbours, idx, v, w,
        distances, parents, edges, visited, queue, node, currDist, neighbour,
        edgeInfo, distance, i;

  weights    := EdgeWeights(digraph);
  vertices   := DigraphVertices(digraph);
  nrVertices := Size(vertices);

  # Create an adjacency map for the shortest edges: index and weight
  adj := HashMap();
  for u in vertices do
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

  distances := ListWithIdenticalEntries(nrVertices, infinity);
  parents   := EmptyPlist(nrVertices);
  edges     := EmptyPlist(nrVertices);

  distances[source] := 0;
  parents[source]   := fail;
  edges[source]     := fail;

  visited := BlistList(vertices, []);

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

  # show fail if no path is possible
  for i in vertices do
    if distances[i] = infinity then
      distances[i] := fail;
      parents[i]   := fail;
      edges[i]     := fail;
    fi;
  od;

  return rec(distances := distances, parents := parents, edges := edges);
end);

InstallGlobalFunction(DIGRAPHS_Edge_Weighted_Bellman_Ford,
function(digraph, source)
  local edgeList, weights, vertices, nrVertices, distances, u, outNeighbours,
        idx, v, w, edge, parents, edges, i, flag, _;

  weights    := EdgeWeights(digraph);
  vertices   := DigraphVertices(digraph);
  nrVertices := Size(vertices);

  edgeList := [];
  for u in DigraphVertices(digraph) do
    outNeighbours := OutNeighbours(digraph)[u];
    for idx in [1 .. Size(outNeighbours)] do
      v := outNeighbours[idx];  # the out neighbour
      w := weights[u][idx];     # the weight to the out neighbour
      Add(edgeList, [w, u, v, idx]);
    od;
  od;

  distances := ListWithIdenticalEntries(nrVertices, infinity);
  parents   := EmptyPlist(nrVertices);
  edges     := EmptyPlist(nrVertices);

  distances[source] := 0;
  parents[source]   := fail;
  edges[source]     := fail;

  # relax all edges: update weight with smallest edges
  flag := true;
  for _ in vertices do
    for edge in edgeList do
      w := edge[1];
      u := edge[2];
      v := edge[3];
      idx := edge[4];

      if distances[u] <> infinity
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

    if distances[u] <> infinity
        and Float(distances[u]) + Float(w) < Float(distances[v]) then
      ErrorNoReturn("1st arg <digraph> contains a negative-weighted cycle,");
    fi;
  od;

  # fill lists with fail if no path is possible
  for i in vertices do
    if distances[i] = infinity then
      distances[i] := fail;
      parents[i]   := fail;
      edges[i]     := fail;
    fi;
  od;

  return rec(distances := distances, parents := parents, edges := edges);
end);
