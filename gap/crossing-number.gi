# Crossing Number of a tournament
InstallMethod(DIGRAPHS_TournamentCrossingNumber, "for a tournament",
    [IsTournament],
    function(D)
    local KnownCrossingNumberArray, n;
    if not IsTournament(D) then
        ErrorNoReturn("argument must be a tournament");
    fi;
    # Array of known crossing numbers for tournaments from 0 - 14 vertices
    KnownCrossingNumberArray :=
        [0, 0, 0, 0, 0, 1, 3, 9, 18, 36, 60, 100, 150, 225, 315];
    n := DigraphNrVertices(D);
    if n < 15 then
        SetDigraphCrossingNumber(D, KnownCrossingNumberArray[n + 1]);
        return KnownCrossingNumberArray[n + 1];
    elif n >= 15 then
        return -1;
    fi;
end);

# Crossing Number Inequality
InstallGlobalFunction(DIGRAPHS_CrossingNumberInequality,
    function(D)
        local res, n, e, nrLoops, temp;
        # If digraph has loops remove them first
        e := DigraphNrEdges(D);
        nrLoops := DigraphNrLoops(D);
        if nrLoops > 0 then
            e := e - DigraphNrLoops(D);
        fi;

        # If digraph is Planar crossing number is 0
        if IsPlanarDigraph(D) then
            SetDigraphCrossingNumber(D, 0);
            return 0;
        fi;

        n := DigraphNrVertices(D);
        res := -1;

        if DIGRAPHS_IsK22FreeDigraph(D) and (e >= 1000 * n) then
            temp := 1 / (10 ^ 8) * (Float(e)) ^ 4 / (Float(n) ^ 3);
            if temp > res then
                res := temp;
            fi;
        fi;
        # If digraph has e >= 6.95n use one equation
        if Float(e) >= 6.95 * Float(n) then
            temp := (Float(e) ^ 3) / (29 * (n ^ 2));
            # Deal with division errors
            temp := DIGRAPHS_CrossingNumberRound(temp);
            if temp > res then
                res := temp;
            fi;
        # Otherwise we use a different one
        else
            temp :=
                ((Float(e ^ 3)) / (29 * (Float(n) ^ 2))) -
                (35 / 29) * Float(n);
            temp := DIGRAPHS_CrossingNumberRound(temp);
            if temp > res then
                res := temp;
            fi;
        fi;
        return res;
end);

# Private Helper function to deal with division errors in the CNI
InstallGlobalFunction(DIGRAPHS_CrossingNumberRound,
    function(val)
    local tolerance;
    tolerance := 0.0001;
    if val - Trunc(val) < tolerance then
        return Int(Trunc(val));
    else
        return Int(Ceil(val));
    fi;
end);

# Get the known crossing number for a comple digraph on n vertices
InstallGlobalFunction(DIGRAPHS_GetCompleteDigraphCrossingNumber,
    function(n)
    local KnownCrossingNumberArray;
    if n > 15 then
        ErrorNoReturn("Crossing number unknown for digraph on this number",
            "of vertices");
    fi;
    KnownCrossingNumberArray :=
        [0, 0, 0, 0, 0, 4, 12, 36, 72, 144, 240, 400, 600, 900, 1260];
    # +1 due to first array index being 1 representing n=0
    return KnownCrossingNumberArray[n + 1];
end);

# Crossing number for a complete digraph
InstallMethod(DIGRAPHS_CompleteDigraphCrossingNumber,
    "for a complete digraph", [IsCompleteDigraph],
    function(D)
    local n, completeDigraphCrossingNumber;
    if not IsCompleteDigraph(D) then
        ErrorNoReturn("the 1st argument must be a complete digraph,");
    fi;
    n := DigraphNrVertices(D);
    if n < 15 then
        # 1 due to list's indexing at 1 and the complete
        # graph of 0 vertices being included
        completeDigraphCrossingNumber :=
            DIGRAPHS_GetCompleteDigraphCrossingNumber(n);
        SetDigraphCrossingNumber(D, completeDigraphCrossingNumber);
        return completeDigraphCrossingNumber;
    elif n >= 15 then
        ErrorNoReturn("Complete Digraph contains too many vertices",
            " for known crossing number");
    fi;
end);

# Computes if a digraph has K2,2 subgraph
InstallGlobalFunction(DIGRAPHS_IsK22FreeDigraph,
    function(D)
        local i, j, k, l, intersect, adjacencyMatrix,
            vertices, neighbours, numberVertices, jCount, lCount;
        if not IsDigraph(D) then
            ErrorNoReturn("the 1st argument must be a digraph,");
        fi;
        numberVertices := DigraphNrVertices(D);
        # If the digraph is a complete bipartite digraph with m>=2 and n>=2
        # then it has K2,2 as a subgraph
        if IsCompleteBipartiteDigraph(D) and
            Length(DigraphBicomponents(D)[1]) > 1 and
            Length(DigraphBicomponents(D)[2]) > 1 then
            return false;
        # If the digraph has fewer than 4 vertices then it is is
        # trivially K2,2 free
        elif numberVertices < 4 then
            return true;
        # If a digraph is a complete digraph or tournament it is K2,2
        # free as as there are no unconnected nodes
        elif IsCompleteDigraph(D) or IsTournament(D) then
            return true;
        fi;
        # Check if for every pair of distinct unconnected vertices (x1,x2)
        # (x1 <-!-> x2, x1!=x2) that their intersection contains
        # two distinct unconnected vertices. This means there is K2,2 subgraph
        # Create boolean adjacency matrix
        adjacencyMatrix := BooleanAdjacencyMatrix(D);
        neighbours := OutNeighbours(D);
        vertices := DigraphVertices(D);
        for i in vertices do
            for jCount in [i + 1 .. numberVertices] do
                j := vertices[jCount];
                # If there are more than 1 vertex that both i and j
                # connect to and i and j are not connected
                intersect := Intersection(neighbours[i], neighbours[j]);
                if Length(intersect) >= 2 and adjacencyMatrix[i][j] = false
                    and adjacencyMatrix[j][i] = false then
                    # For every pair of vertices in the intersection
                    for k in intersect do
                        for lCount in [k + 1 .. Length(intersect)] do
                            l := intersect[lCount];
                            # if k and l are unconnected
                            if adjacencyMatrix[k][l] = false and
                                adjacencyMatrix[l][k] = false then
                                return false;
                            fi;
                        od;
                    od;
                fi;
            od;
        od;
        return true;
end);

# Semicomplete Digraph generator
InstallMethod(RandomDigraphCons,
"for SemicompleteDigraph, a positive integer, and a float",
[IsSemicompleteDigraph, IsPosInt, IsFloat],
function(_, n, p)
    local adjacencyList, vertices, probability, i, j;

    adjacencyList := EmptyPlist(n);

    vertices := [1 .. n];
    probability := [0 .. 99];

    for i in vertices do
        Add(adjacencyList, []);
    od;

    for i in vertices do
        for j in [i + 1 .. n] do
            # Decide if there should be a second vertex using some probability p
            # Random number < p means it should be added
            if Float(Random(probability) / 100) < p then
                Add(adjacencyList[j], i);
                Add(adjacencyList[i], j);
            # Create only one edge between each vertex
            # Decide orientation from a random number
            elif Random([1 .. 2]) < 2 then
                Add(adjacencyList[i], j);
            else
                Add(adjacencyList[j], i);
            fi;
        od;
    od;
    return DigraphNC(adjacencyList);

end);

# Random cubic digraph generation
InstallMethod(RandomDigraphCons,
"for CubicDigraph and a positive integer",
[IsCubicDigraph, IsPosInt],
function(_, n)
    local edge1, edge2, edges, edgeList, i, D, edgeIndex, numberVertices;
    if n = 0 then
        return EmptyDigraph(0);
    elif n < 4 then
        ErrorNoReturn("Cubic Digraphs must have at least 4 vertices");
    elif n mod 2 = 1 then
        ErrorNoReturn("Cubic Digraphs exist only for even vertices");
    fi;

    # Create a tournament on 4 vertices
    D := RandomTournament(4);

    # For i in range from 4 to n
    for i in [1 .. n - 4] do
        # Skip odd i as no cubic digraph can exist with odd number of vertices
        if i mod 2 = 1 then
            continue;
        fi;
        # Select two random edges
        edgeList := DigraphEdges(D);
        edges := [1 .. DigraphNrEdges(D)];
        edgeIndex := Random(edges);
        edge1 := edgeList[edgeIndex];
        # Remove edge1 so edge2 != edge1
        Remove(edges, edgeIndex);
        edge2 := edgeList[Random(edges)];

        # Split the edges by adding a new vertex in between each
        D := DigraphRemoveEdge(D, edge1);
        D := DigraphRemoveEdge(D, edge2);
        numberVertices := DigraphNrVertices(D);
        D := DigraphAddVertices(D, 2);
        D := DigraphAddEdge(D, [edge1[1], numberVertices + 1]);
        D := DigraphAddEdge(D, [numberVertices + 1, edge1[2]]);
        D := DigraphAddEdge(D, [edge2[1], numberVertices + 2]);
        D := DigraphAddEdge(D, [numberVertices + 2, edge2[2]]);
        # Determine orientation of link between new vertices
        if Random([1 .. 2]) < 2 then
            D := DigraphAddEdge(D, [numberVertices + 1, numberVertices + 2]);
        else
            D := DigraphAddEdge(D, [numberVertices + 2, numberVertices + 1]);
        fi;
    od;

    return D;
end);

# Check if a digraph is cubic
InstallMethod(IsCubicDigraph, "for a digraph", [IsDigraph],
    function(D)
        # If all nodes have degree three then the digraph is cubic
        local degrees;
        # If the digraph has an odd number of vertices it can never be cubic
        if DigraphNrVertices(D) mod 2 = 1 then
            return false;
        # If D is a multidigraph we are going to exclude
        # it from being a cubic digraph
        elif IsMultiDigraph(D) then
            return false;
        # Cubic digraphs cannot have loops
        elif DigraphHasLoops(D) then
            return false;
        fi;
        # Need to consider edges in and out of each vertex
        degrees := OutDegrees(D) + InDegrees(D);
        return ForAll(degrees, x -> x = 3);
end);

# Check if a digraph is semicomplete
InstallMethod(IsSemicompleteDigraph, "for a digraph", [IsDigraph],
    function(D)
        local i, j, adjacencyMatrix, numberVertices, jCount, vertices;
        # If a digraph is complete or a tournament
        # it is by definition semi-complete
        if IsTournament(D) or IsCompleteDigraph(D) then
            return true;
        fi;
        # Semicomplete digraphs cannot have loops
        if DigraphHasLoops(D) then
            return false;
        fi;
        if IsMultiDigraph(D) then
            return false;
        fi;
        # Check that for all vertices that do not have a
        # directed edge one way between them
        vertices := DigraphVertices(D);
        adjacencyMatrix := BooleanAdjacencyMatrix(D);
        numberVertices := DigraphNrVertices(D);
        for i in vertices do
            for jCount in [i + 1 .. numberVertices] do
                j := vertices[jCount];
                # If no edge exists from i -> j or j -> i
                # for all i,j then the digraph isn't semicomplete
                if adjacencyMatrix[i][j] = false and
                    adjacencyMatrix[j][i] = false then
                    return false;
                fi;
            od;
        od;
        return true;
end);

# Compute the crossing number of a digraph
InstallMethod(DigraphCrossingNumber, "for a digraph", [IsDigraph],
function(D)
    local n, temp;

    # If Digraph is planar return 0
    if IsPlanarDigraph(D) then
        SetDigraphCrossingNumber(D, 0);
        return 0;
    fi;

    n := DigraphNrVertices(D);

    # If Digraph is a complete graph with fewer than 15 vertices
    if IsCompleteDigraph(D) and (n < 15) then
        temp := DIGRAPHS_CompleteDigraphCrossingNumber(D);
        SetDigraphCrossingNumber(D, temp);
        return temp;
    fi;

    # If Digraph is a tournament with fewer than 15 vertices
    if IsTournament(D) and (n < 15) then
        temp := DIGRAPHS_TournamentCrossingNumber(D);
        SetDigraphCrossingNumber(D, temp);
        return temp;
    fi;

    # If Digraph is bipartite
    if IsCompleteBipartiteDigraph(D) then
        temp := DIGRAPHS_CompleteBipartiteDigraphCrossingNumber(D);
        if temp <> -1 then
            SetDigraphCrossingNumber(D, temp);
            return temp;
        fi;
    fi;

    # If Digraph is multipartite
    if IsCompleteMultipartiteDigraph(D) then
        temp := DIGRAPHS_CompleteMultipartiteDigraphCrossingNumber(D);
        if temp <> -1 then
            SetDigraphCrossingNumber(D, temp);
            return temp;
        fi;
    fi;

    # If its isomorphic to a circulant graph with known crossing number
    temp := DIGRAPHS_IsomorphicToCirculantGraphCrossingNumber(D);
    if temp <> -1 then
        SetDigraphCrossingNumber(D, temp);
        return temp;
    fi;

    return -1;
end);

# Compute a lower bound for the crossing number of a digraph
InstallGlobalFunction(DigraphCrossingNumberLowerBound,
function(D)
    local temp, res;

    if not IsDigraph(D) then
        ErrorNoReturn("Argument must be a digraph");
    fi;
    res := 0;
    # Check if there is an exact way to compute the crossing number
    if DigraphCrossingNumber(D) <> -1 then
        return DigraphCrossingNumber(D);
    fi;
    # The Albertson conjecture
    temp := DIGRAPHS_CrossingNumberAlbertson(D);
    if temp <> -1 then
        res := temp;
    fi;

    # The Crossing Number Inequality
    temp := DIGRAPHS_CrossingNumberInequality(D);
    if temp <> -1 then
        res := temp;
    fi;

    return res;
end);

# Compute an upper bound for the crossing number of a digraph
InstallGlobalFunction(DigraphCrossingNumberUpperBound,
function(D)
    local res, temp, componentsSize, n, e;

    if not IsDigraph(D) then
        ErrorNoReturn("Argument must be a digraph");
    fi;

    if IsPlanarDigraph(D) then
        return 0;
    fi;

    # Check if there is an exact way to compute the crossing number
    res := DigraphCrossingNumber(D);
    if res <> -1 then
        return res;
    fi;

    res := infinity;

    n := DigraphNrVertices(D);

    # Zarankiewicz's theorem for bipartite digraphs
    if IsBipartiteDigraph(D) then
        componentsSize := CompleteMultipartiteDigraphPartitionSize(D);
        temp := DIGRAPHS_ZarankiewiczTheorem(componentsSize[1],
            componentsSize[2]);
        if temp < res then
            res := temp;
        fi;
    fi;

    # Guy's Theorem (Valid for all non-multi digraphs)
    if not IsMultiDigraph(D) then
        n := Float(n);
        temp := Trunc(n / 2) * Trunc((n - 1) / 2) *
            Trunc((n - 2) / 2) * Trunc((n - 3) / 2);
        if temp < res then
            res := temp;
        fi;
    else
        e := DigraphNrEdges(D);
        temp := e ^ e;
        if temp < res then
            res := temp;
        fi;
    fi;

    return res;
end);

# Compute the bounds for the crossing number of a semicomplete digraph
InstallMethod(SemicompleteDigraphCrossingNumber,
"for a semicomplete digraph", [IsSemicompleteDigraph],
    function(D)
        local n, crossingNumberCompleteDigraph, crossingNumberTournament, x;
        if IsPlanarDigraph(D) then
            SetDigraphCrossingNumber(D, 0);
            return 0;
        fi;

        n := DigraphNrVertices(D);
        if n < 15 then
            # Get the crossing number of the tournament equal vertices
            crossingNumberTournament :=
            DIGRAPHS_GetCompleteDigraphCrossingNumber(n) / 4;
            # Get the crossing number of the complete graph with equal vertices
            crossingNumberCompleteDigraph :=
            DIGRAPHS_GetCompleteDigraphCrossingNumber(n);
        else
            # Get lower bound for tournament with equal vertices using CNI
            crossingNumberTournament :=
            DIGRAPHS_CrossingNumberInequality(RandomTournament(n));
            # Get upper bound for complete digraph
            # with equal number of vertices using Guy's Theorem
            x := Float(n);
            crossingNumberCompleteDigraph := Int(Trunc(x / 2) *
            Trunc((x - 1) / 2) * Trunc((x - 2) / 2) * Trunc((x - 3) / 2));
        fi;
        # If the cn of tournament and complete digraph
        # are equal crossing number is known
        if crossingNumberCompleteDigraph = crossingNumberTournament then
            SetDigraphCrossingNumber(D, crossingNumberCompleteDigraph);
            return crossingNumberCompleteDigraph;
        elif crossingNumberCompleteDigraph < crossingNumberTournament then
            # This code should never run
            ErrorNoReturn("Error, lower bound higher than upper bound");
        else
            return [crossingNumberTournament, crossingNumberCompleteDigraph];
        fi;
        return;
end);

# The Albertson Conjecture for lower bound of crossing numbers
InstallGlobalFunction(DIGRAPHS_CrossingNumberAlbertson,
    function(D)
        local chromaticNumber;
        if not IsDigraph(D) then
            ErrorNoReturn("the 1st argument must be a digraph,");
        fi;
        chromaticNumber := ChromaticNumber(D);
        # Chromatic number must be less than 16 as that is
        # the highest complete digraph we have a known cn for
        if chromaticNumber < 15 then
            return DIGRAPHS_GetCompleteDigraphCrossingNumber(chromaticNumber) /
                4;
        else
            # Chromatic number too large for known crossing number
            return -1;
        fi;
end);

InstallMethod(RandomDigraphCons, "for SemicompleteDigraph and an integer",
[IsSemicompleteDigraph, IsInt],
{_, n}
-> RandomDigraphCons(IsSemicompleteDigraph, n, Float(Random([0 .. n])) / n));

InstallMethod(RandomDigraphCons,
"for SemicompleteDigraph, an integer, and a rational",
[IsSemicompleteDigraph, IsInt, IsRat],
{_, n, p} -> RandomDigraphCons(IsSemicompleteDigraph, n, Float(p)));

# Compute a large planar subdigraph of a non-planar digeaph
InstallMethod(DigraphLargePlanarSubdigraph, "for a digraph", [IsDigraph],
    function(D)
        local E1, spanningSubdigraph, triangle, triangles, antisymmetric, edge;
        if not IsDigraph(D) then
            ErrorNoReturn("the 1st argument must be a digraph,");
        fi;
        # Starting with E1 = Empty Set
        E1 := [[], []];
        # Make digraph antisymmetric
        antisymmetric := MaximalAntiSymmetricSubdigraph(D);
        # For as long as possible find triangles T whose vertices
        # are in different components of G[E1]
        # Find all triangles in the digraph
        triangles := DigraphAllTriangles(antisymmetric);

        # Get G[E1]
        spanningSubdigraph := Digraph(DigraphNrVertices(D), E1[1], E1[2]);
        for triangle in triangles do
            # Check if triangle's vertices are in different components of G[E1]
            if (DigraphConnectedComponent(spanningSubdigraph, triangle[1]) <>
            DigraphConnectedComponent(spanningSubdigraph, triangle[2])) and
            (DigraphConnectedComponent(spanningSubdigraph, triangle[1]) <>
            DigraphConnectedComponent(spanningSubdigraph, triangle[3])) then
                # If they are add the edges of each vertex to E1
                Add(E1[1], triangle[1]);
                Add(E1[2], triangle[2]);
                Add(E1[1], triangle[2]);
                Add(E1[2], triangle[3]);
                Add(E1[1], triangle[1]);
                Add(E1[2], triangle[3]);
                # Recompute G[E1]f
                spanningSubdigraph := Digraph(DigraphNrVertices(D),
                E1[1], E1[2]);

            fi;
        od;
        # Repeatedly find edges in G whose endpoints are in
        # different components of G[E2] and add e to E2
        for edge in DigraphEdges(antisymmetric) do
            if DigraphConnectedComponent(spanningSubdigraph, edge[1]) <>
            DigraphConnectedComponent(spanningSubdigraph, edge[2]) then
                spanningSubdigraph := DigraphAddEdge(spanningSubdigraph, edge);
            fi;
        od;
        for edge in DigraphEdges(spanningSubdigraph) do
            if IsDigraphEdge(D, edge[2], edge[1]) then
                spanningSubdigraph := DigraphAddEdge(spanningSubdigraph,
                [edge[2], edge[1]]);
            fi;
        od;
        return spanningSubdigraph;
end);

# Find all 3-cycles within a digraph
InstallMethod(DigraphAllThreeCycles, "for a digraph", [IsDigraph],
    function(D)
    local threeCycles, adjacencyList, edge, min, vertex;
    if not IsDigraph(D) then
        ErrorNoReturn("the 1st argument must be a digraph,");
    fi;
    threeCycles := [];
    adjacencyList := AdjacencyMatrix(D);
    for edge in DigraphEdges(D) do
        for vertex in DigraphVertices(D) do
            # if u != w, v != w,
            # u is connected to w and v is connected to w
            # where u,v distinct to prevent errors due to loops
            if edge[1] <> edge[2] and vertex <> edge[1] and vertex <> edge[2]
            and adjacencyList[vertex][edge[1]] = 1 and
            adjacencyList[edge[2]][vertex] = 1 then
                # Sort to prevent multiple cycles with same vertices
                # lowest vertex first
                min := Minimum(edge[1], edge[2], vertex);
                if min = vertex then
                    Add(threeCycles, [min, edge[1], edge[2]]);
                elif min = edge[1] then
                    Add(threeCycles, [min, edge[2], vertex]);
                else
                    Add(threeCycles, [min, vertex, edge[1]]);
                fi;
            fi;
        od;
    od;
    SetDigraphAllThreeCycles(D, threeCycles);
    return Set(threeCycles);
end);

# Find all triangles within a digraph
InstallMethod(DigraphAllTriangles, "for a digraph", [IsDigraph],
    function(D)
    local triangles, adjacencyList, edge, temp, vertex;
    if not IsDigraph(D) then
        ErrorNoReturn("the 1st argument must be a digraph,");
    fi;
    triangles := [];
    adjacencyList := AdjacencyMatrix(D);
    for edge in DigraphEdges(D) do
        for vertex in DigraphVertices(D) do
            # if u != w, v != w, u is connected to w and v is connected to w
            # where u,v distinct to prevent errors due to loop
            if edge[1] <> edge[2] and vertex <> edge[1]
            and vertex <> edge[2] and
                (adjacencyList[vertex][edge[1]] = 1 or
                adjacencyList[edge[1]][vertex] = 1) and
                (adjacencyList[edge[2]][vertex] = 1 or
                adjacencyList[vertex][edge[2]] = 1) then
                temp := [edge[1], edge[2], vertex];
                # Sort to prevent multiple triangles with same vertices
                Sort(temp);
                Add(triangles, temp);
            fi;
        od;
    od;
    return Set(triangles);
end);

# Add an artificial vertex between two given edges
InstallMethod(DigraphAddVertexCrossingPoint, "for a digraph, list, and list",
    [IsDigraph, IsList, IsList],
    function(arg...)
    local n, D, Edge1, Edge2;
    if IsEmpty(arg) then
        ErrorNoReturn("at least 3 arguments required,");
    elif not IsDigraph(arg[1]) then
        ErrorNoReturn("the 1st argument must be a digraph,");
    elif not IsDigraphEdge(arg[1], arg[2]) then
        ErrorNoReturn("the 2nd argument must be an edge on the digraph,");
    elif not IsDigraphEdge(arg[1], arg[3]) then
        ErrorNoReturn("the 3rd argument must be an edge on the digraph,");
    fi;

    D := arg[1];
    Edge1 := arg[2];
    Edge2 := arg[3];

    if Edge1[1] = Edge1[2] or  Edge2[1] = Edge2[2] then
        ErrorNoReturn("the function is not suitable for self-loop edges");
    elif Edge1 = Edge2 then
        ErrorNoReturn("the function is not suitable for identical edges");
    fi;

    # Add a new artificial vertex to the graph
    D := DigraphAddVertices(D, 1);
    n := DigraphNrVertices(D);
    # Remove the existing edges
    D := DigraphRemoveEdge(D, Edge1);
    D := DigraphRemoveEdge(D, Edge2);
    # Add the new edges in (between E1 source and artificial vertex,
    # artificial vertex and E1 destination. Same for E2)
    return DigraphAddEdges(D, [[Edge1[1], n], [n, Edge1[2]], [Edge2[1], n],
        [n, Edge2[2]]]);
end);

# Compute crossing number of a complete multipartite digraphs
InstallMethod(DIGRAPHS_CompleteMultipartiteDigraphCrossingNumber,
    "for a multipartite digraph", [IsCompleteMultipartiteDigraph],
    function(D)
    local componentsSize, crossingNumber;
    if not IsCompleteMultipartiteDigraph(D) then
        ErrorNoReturn("method only applicable for complete",
            "multipartite digraphs");
    fi;
    componentsSize := CompleteMultipartiteDigraphPartitionSize(D);
    if Length(componentsSize) = 3 then
        crossingNumber :=
        DIGRAPHS_CompleteTripartiteDigraphCrossingNumber(componentsSize);
        SetDigraphCrossingNumber(D, crossingNumber);
        return crossingNumber;
    elif Length(componentsSize) = 4 then
        crossingNumber :=
        DIGRAPHS_Complete4partiteDigraphCrossingNumber(componentsSize);
        SetDigraphCrossingNumber(D, crossingNumber);
        return crossingNumber;
    elif Length(componentsSize) = 5 then
        crossingNumber :=
        DIGRAPHS_Complete5partiteDigraphCrossingNumber(componentsSize);
        SetDigraphCrossingNumber(D, crossingNumber);
        return crossingNumber;
    elif Length(componentsSize) = 6 then
        crossingNumber :=
        DIGRAPHS_Complete6partiteDigraphCrossingNumber(componentsSize);
        SetDigraphCrossingNumber(D, crossingNumber);
        return crossingNumber;
    fi;
end);

# Compute the crossing number of a complete 4-partite digraph
InstallGlobalFunction(DIGRAPHS_Complete4partiteDigraphCrossingNumber,
    function(arg...)
    local k, l, m, n;
    k := arg[1][1];
    l := arg[1][2];
    m := arg[1][3];
    n := Float(arg[1][4]);
    if k = 2 and l = 2 and m = 2 then
        return Int(4 * (6 * (Trunc(n / 2) * Trunc((n - 1) / 2)) + 3 * n));
    fi;
    return -1;
end);

# Compute the crossing number of a complete 5-partite digraph
InstallGlobalFunction(DIGRAPHS_Complete5partiteDigraphCrossingNumber,
    function(arg...)
    local j, k, l, m, n;
    j := arg[1][1];
    k := arg[1][2];
    l := arg[1][3];
    m := arg[1][4];
    n := Float(arg[1][5]);
    # Ho (2009)
    if j = 1 and k = 1 and l = 1 and m = 1 then
        return Int(4 * (2 * (Trunc(n / 2) * Trunc((n - 1) / 2)) + n));
    elif j = 1 and k = 1 and l = 1 and m = 2 then
        return Int(4 * (4 * (Trunc(n / 2) * Trunc((n - 1) / 2)) + 2 * n));
    fi;
    return -1;
end);

# Compute the crossing number of a complete 6-partite digraph
InstallGlobalFunction(DIGRAPHS_Complete6partiteDigraphCrossingNumber,
    function(arg...)
    local i, j, k, l, m, n;
    i := arg[1][1];
    j := arg[1][2];
    k := arg[1][3];
    l := arg[1][4];
    m := arg[1][5];
    n := Float(arg[1][6]);
    # Lu and Huang
    if i = 1 and j = 1 and k = 1 and l = 1 and m = 1 then
        return Int(4 * (4 * (Trunc(n / 2) * Trunc((n - 1) / 2)) +
            2 * n + 1 + Trunc(n / 2)));
    fi;
    return -1;
end);

# Compute the crossing number of a complete tripartite digraph
InstallGlobalFunction(DIGRAPHS_CompleteTripartiteDigraphCrossingNumber,
    function(arg...)
    local l, m, n;
    l := arg[1][1];
    m := arg[1][2];
    n := Float(arg[1][3]);
    if l > 2 or m > 4 then
        return -1;
    elif l = 1 and m > 1 then
        if m = 2 then
            # Ho (2008)
            return Int(4 * Trunc(n / 2) *
                Trunc((n - 1) / 2));
        elif m = 3 then
            # Asano
            return Int(4 * (2 * Trunc(n / 2) * Trunc((n - 1) / 2) +
                Trunc(n / 2)));
        elif m = 4 then
            # Huang and Zhao
            return Int(4 * (4 * Trunc(n / 2) * Trunc((n - 1) / 2) +
                2 * Trunc(n / 2)));
        fi;
    elif l = 2 then
        if m = 2 then
            # Klesc and Schrotter
            return Int(4 * 2 * Trunc(n / 2) * Trunc((n - 1) / 2));
        elif m = 3 then
            # Asano
            return Int(4 * (4 * Trunc(n / 2) *
                Trunc((n - 1) / 2) + n));
        elif m = 4 then
            # Ho (2013)
            return Int(4 * (6 * Trunc(n / 2) *
                Trunc((n - 1) / 2) + 2 * n));
        fi;
    fi;
    return -1;
end);

# Compute the crossing number of a complete bipartite digraph
InstallMethod(DIGRAPHS_CompleteBipartiteDigraphCrossingNumber,
    "for a bipartite digraph", [IsCompleteBipartiteDigraph],
    function(D)
    local componentsSize, crossingNumber;
    if not IsCompleteBipartiteDigraph(D) then
        ErrorNoReturn("method only applicable for complete bipartite digraphs");
    fi;
    componentsSize := CompleteMultipartiteDigraphPartitionSize(D);
    # Zarankiewicz's theorem holds with equality for all m < 7
    # for Km,n where m <= n
    if componentsSize[1] < 7 then
        crossingNumber :=
        DIGRAPHS_ZarankiewiczTheorem(componentsSize[1], componentsSize[2]);
        SetDigraphCrossingNumber(D, crossingNumber);
        return crossingNumber;
    # Zarankiewicz's theorem is also known to hold for K7,7-10 and K8,8-10
    elif componentsSize[1] < 9 and componentsSize[2] < 11 then
        crossingNumber :=
        DIGRAPHS_ZarankiewiczTheorem(componentsSize[1], componentsSize[2]);
        SetDigraphCrossingNumber(D, crossingNumber);
        return crossingNumber;
    else
        return -1;
    fi;
end);

# Implementation of Zarankiewicz's theorem
InstallGlobalFunction(DIGRAPHS_ZarankiewiczTheorem,
    function(arg...)
    local m, n;
    m := Float(arg[1]);
    n := Float(arg[2]);
    return Int(4 * Trunc(n / 2) * Trunc((n - 1) / 2) *
        Trunc(m / 2) * Trunc((m - 1) / 2));
end);

# Compute the partition sizes of a complete multipartite digraph
InstallMethod(CompleteMultipartiteDigraphPartitionSize,
    "for a complete multipartite digraph", [IsCompleteMultipartiteDigraph],
    function(D)
    local i, neighbours, typesSeen, dictionary, componentsSize;
    # Create a dictionary for the set of outneighbours
    dictionary := NewDictionary(Set(OutNeighbours(D)), true);
    neighbours := OutNeighbours(D);
    typesSeen := [];
    componentsSize := [];
    for i in [1 .. Length(neighbours)] do
        # If we've already seen the outneighbours for a given vertex
        # increment the number of times we've seen it
        if neighbours[i] in typesSeen then
            AddDictionary(dictionary, neighbours[i],
                LookupDictionary(dictionary, neighbours[i]) + 1);
        else
            # Otherwise add the outneighbours to the seen array
            # and add it to the dictionary
            Append(typesSeen, [neighbours[i]]);
            AddDictionary(dictionary, neighbours[i], 1);
        fi;
    od;
    # Add the number of times we have seen each neighbour set to an array
    for i in [1 .. Length(typesSeen)] do
        Add(componentsSize, LookupDictionary(dictionary, typesSeen[i]));
    od;
    # Sort the array due to conventional notation of CompleteMultidigraphs
    componentsSize := AsSortedList(componentsSize);
    SetCompleteMultipartiteDigraphPartitionSize(D, componentsSize);
    return componentsSize;
end);

# Compute the crossing number of a digraph if
# it is isomorphic to a circulant digraph with known crossing number
InstallGlobalFunction(DIGRAPHS_IsomorphicToCirculantGraphCrossingNumber,
    function(D)
    local n;
    n := DigraphNrVertices(D);
    if n >= 8 and IsIsomorphicDigraph(D, CirculantGraph(n, [1, 3])) then
        return Trunc(Float(n) / 3) + (n mod 3);
    elif n >= 8 and n mod 2 = 0 and
        IsIsomorphicDigraph(D, CirculantGraph(n, [1, (n / 2) - 1])) then
        return n / 2;
    elif n >= 3 and IsIsomorphicDigraph(D, CirculantGraph(3 * n, [1, n])) then
        return n;
    elif n >= 3 and
        IsIsomorphicDigraph(D, CirculantGraph(2 * n + 2, [1, n])) then
        return n + 1;
    elif n >= 3 and
        IsIsomorphicDigraph(D, CirculantGraph(3 * n + 1, [1, n])) then
        return n + 1;
    fi;
    return -1;
end);
