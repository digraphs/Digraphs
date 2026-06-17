/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "graphIO.h"

#include "strOrFile.h"

#include "../extensionSystem/graphExtensions.private.h"

// To help with writing debug info
#include "../planarityRelated/graphPlanarity.private.h"
#include "../graphDFSUtils.h"

// To help with graph construction
#include "../graph.private.h"

/* Imported functions */
extern int _g6_ReadGraphFromStrOrFile(graphP theGraph, strOrFileP *pG6InputContainer);
extern int _g6_WriteGraphToStrOrFile(graphP theGraph, strOrFileP *pOutputContainer);

/* Private functions (exported to system) */

int _ReadGraph(graphP theGraph, strOrFileP *pInputContainer);
int _ReadAdjMatrix(graphP theGraph, strOrFileP inputContainer);
int _ReadAdjList(graphP theGraph, strOrFileP inputContainer);
int _ReadLEDAGraph(graphP theGraph, strOrFileP inputContainer);
int _ReadPostprocess(graphP theGraph, char *extraData);

int _WriteGraph(graphP theGraph, strOrFileP *outputContainer, int Mode);
int _WriteAdjList(graphP theGraph, strOrFileP outputContainer);
int _WriteAdjMatrix(graphP theGraph, strOrFileP outputContainer);
int _WriteDebugInfo(graphP theGraph, strOrFileP outputContainer);
int _WritePostprocess(graphP theGraph, char **pExtraData);

/* Private functions */
char _GetEdgeTypeChar(graphP theGraph, int e);
char _GetObstructionMarkChar(graphP theGraph, int v);

/********************************************************************
 _ReadAdjMatrix()

 This function reads the undirected graph in upper triangular matrix format.
 Though O(N^2) time is required, this routine is useful during
 reliability testing due to the wealth of graph generating software
 that uses this format for output.
 Returns: OK, NOTOK on internal error
 ********************************************************************/

int _ReadAdjMatrix(graphP theGraph, strOrFileP inputContainer)

{
    int N = 0;
    int v = NIL, w = NIL, Flag = NIL;

    if (!sf_IsValidStrOrFile(inputContainer))
        return NOTOK;

    // Read the number of vertices from the first line of the file
    if (sf_ReadSkipWhitespace(inputContainer) != OK)
        return NOTOK;

    if (sf_ReadInteger(&N, inputContainer) != OK)
        return NOTOK;

    // Initialize the graph based on the number of vertices
    if (gp_EnsureVertexCapacity(theGraph, N) != OK)
        return NOTOK;

    // Read an upper-triangular matrix row for each vertex
    // Note that for the last vertex, zero flags are read, per the upper triangular format
    for (v = gp_LowerBoundVertices(theGraph); v < gp_UpperBoundVertices(theGraph); ++v)
    {
        gp_SetIndex(theGraph, v, v);
        for (w = v + 1; w < gp_UpperBoundVertices(theGraph); w++)
        {
            // Read each of v's w-neighbor flags
            if (sf_ReadSkipWhitespace(inputContainer) != OK)
                return NOTOK;

            if (sf_ReadSingleDigit(&Flag, inputContainer) != OK)
                return NOTOK;
            // N.B. Currently do not allow edge-weights in Adjacency
            // Matrix format
            if (Flag != 0 && Flag != 1)
                return NOTOK;

            // Add the edge (v, w) if the flag is raised
            if (Flag)
            {
                if (gp_DynamicAddEdge(theGraph, v, 0, w, 0) != OK)
                    return NOTOK;
            }
        }
    }

    return OK;
}

/********************************************************************
 _ReadAdjList()
 This function reads the graph in adjacency list format.

 The graph format is:
    On the first line    : N=<number of vertices>
    On N subsequent lines: #: a b c ... -1
        where # is a vertex number and a, b, c, ... are its neighbors.

 NOTE:  The vertex number is for file documentation only. It is an
        error if the vertices are not in sorted order in the file.

 NOTE:  If a loop edge is found, it is ignored without error.

 NOTE:  This routine supports digraphs.  For a directed edge (v -> W),
        an edge record is created in both vertices, v and W, and the
        edge record in v's adjacency list is marked OUTONLY while the
        edge record in W's list is marked INONLY.
        This makes it easy to used edge directedness when appropriate
        but also seamlessly process the corresponding undirected graph.

 Returns: OK on success,
          NOTOK on file content error (or internal error)
 ********************************************************************/

int _ReadAdjList(graphP theGraph, strOrFileP inputContainer)
{
    int ErrorCode = OK;

    int N = 0, v = NIL, W = NIL, adjList = NIL, e = NIL, indexValue = NIL;
    int zeroBased = FALSE;

    if (!sf_IsValidStrOrFile(inputContainer))
        return NOTOK;

    // Skip the "N=" and then read the N value for number of vertices
    if (sf_ReadSkipChar(inputContainer) != OK)
        return NOTOK;

    if (sf_ReadSkipChar(inputContainer) != OK)
        return NOTOK;

    if (sf_ReadSkipWhitespace(inputContainer) != OK)
        return NOTOK;

    if (sf_ReadInteger(&N, inputContainer) != OK)
        return NOTOK;

    if (sf_ReadSkipWhitespace(inputContainer) != OK)
        return NOTOK;

    // Initialize theGraph based on the number of vertices in the input
    if (gp_EnsureVertexCapacity(theGraph, N) != OK)
        return NOTOK;

    // Clear the visited members of the vertices so they can be used
    // during the adjacency list read operation
    for (v = gp_LowerBoundVertices(theGraph); v < gp_UpperBoundVertices(theGraph); ++v)
        gp_SetVertexVisitedInfo(theGraph, v, NIL);

    // Do the adjacency list read operation for each vertex in order
    for (v = gp_LowerBoundVertices(theGraph); v < gp_UpperBoundVertices(theGraph); ++v)
    {
        // Read the vertex number
        if (sf_ReadSkipWhitespace(inputContainer) != OK)
            return NOTOK;
        if (sf_ReadInteger(&indexValue, inputContainer) != OK)
            return NOTOK;
        if (sf_ReadSkipWhitespace(inputContainer) != OK)
            return NOTOK;

        if (indexValue == 0 && v == gp_LowerBoundVertexStorage(theGraph))
            zeroBased = TRUE;

        // If we are reading a zero-based input file, then we have to add to the
        // indexValue for v the offset of the first vertex in storage, which is
        // usually 1 (because we compile with USE_1BASEDARRAYS by default) but
        // which may be 0 if this library was compiled with USE_0BASEDARRAYS.
        if (zeroBased)
            indexValue += gp_LowerBoundVertexStorage(theGraph);

        gp_SetIndex(theGraph, v, indexValue);

        // The vertices are expected to be in numeric ascending order
        if (gp_GetIndex(theGraph, v) != v)
            return NOTOK;

        // Skip the colon after the vertex number
        if (sf_ReadSkipChar(inputContainer) != OK)
            return NOTOK;

        // If the vertex already has a non-empty adjacency list, then it is
        // the result of adding edges during processing of preceding vertices.
        // The list is removed from the current vertex v and saved for use
        // during the read operation for v.  Adjacencies to preceding vertices
        // are pulled from this list, if present, or added as directed edges
        // if not.  Adjacencies to succeeding vertices are added as undirected
        // edges, and will be corrected later if the succeeding vertex does not
        // have the matching adjacency using the following mechanism.  After the
        // read operation for a vertex v, any adjacency nodes left in the saved
        // list are converted to directed edges from the preceding vertex to v.
        adjList = gp_GetFirstEdge(theGraph, v);
        if (gp_IsEdge(theGraph, adjList))
        {
            // Store the adjacency node location in the visited member of each
            // of the preceding vertices to which v is adjacent so that we can
            // efficiently detect the adjacency during the read operation and
            // efficiently find the adjacency node.
            e = gp_GetFirstEdge(theGraph, v);
            while (gp_IsEdge(theGraph, e))
            {
                gp_SetVertexVisitedInfo(theGraph, gp_GetNeighbor(theGraph, e), e);
                e = gp_GetNextEdge(theGraph, e);
            }

            // Make the adjacency list circular, for later ease of processing
            gp_SetPrevEdge(theGraph, adjList, gp_GetLastEdge(theGraph, v));
            gp_SetNextEdge(theGraph, gp_GetLastEdge(theGraph, v), adjList);

            // Remove the list from the vertex
            gp_SetFirstEdge(theGraph, v, NIL);
            gp_SetLastEdge(theGraph, v, NIL);
        }

        // Read the adjacency list.
        while (1)
        {
            // Read the value indicating the next adjacent vertex (or the list end)
            if (sf_ReadSkipWhitespace(inputContainer) != OK)
                return NOTOK;
            if (sf_ReadInteger(&W, inputContainer) != OK)
                return NOTOK;
            if (sf_ReadSkipWhitespace(inputContainer) != OK)
                return NOTOK;

            // If we are reading a zero-based input file, then we have to add to W
            // the offset of the first vertex in storage, which is usually 1
            // (because we compile with USE_1BASEDARRAYS by default) but which may
            // be 0 if this library was compiled with USE_0BASEDARRAYS.
            if (zeroBased)
                W += gp_LowerBoundVertexStorage(theGraph);

            // A value below the valid range indicates the adjacency list end
            // This was written before gp_IsNotVertex() existed
            if (W < gp_LowerBoundVertices(theGraph))
                break;

            // A value above the valid range is an error
            if (W >= gp_UpperBoundVertices(theGraph))
                return NOTOK;

            // Loop edges are not supported
            else if (W == v)
                return NOTOK;

            // If the adjacency is to a succeeding, higher numbered vertex,
            // then we'll add an undirected edge for now
            else if (v < W)
            {
                if ((ErrorCode = gp_DynamicAddEdge(theGraph, v, 0, W, 0)) != OK)
                    return ErrorCode;
            }

            // If the adjacency is to a preceding, lower numbered vertex, then
            // we have to pull the adjacency node from the preexisting adjList,
            // if it is there, and if not then we have to add a directed edge.
            else
            {
                // If the directed edge already exists, then we add it
                // as the new first edge of the vertex and delete it from adjList
                if (gp_IsEdge(theGraph, gp_GetVertexVisitedInfo(theGraph, W)))
                {
                    e = gp_GetVertexVisitedInfo(theGraph, W);

                    // Remove the directed edge  e from the adjList construct
                    gp_SetVertexVisitedInfo(theGraph, W, NIL);
                    if (adjList == e)
                    {
                        if ((adjList = gp_GetNextEdge(theGraph, e)) == e)
                            adjList = NIL;
                    }
                    gp_SetPrevEdge(theGraph, gp_GetNextEdge(theGraph, e), gp_GetPrevEdge(theGraph, e));
                    gp_SetNextEdge(theGraph, gp_GetPrevEdge(theGraph, e), gp_GetNextEdge(theGraph, e));

                    gp_AttachFirstEdge(theGraph, v, e);
                }

                // If an adjacency node to the lower numbered vertex W does not
                // already exist, then we make a new directed edge from the current
                // vertex v to W.
                else
                {
                    // It is added as the new first edge in both vertices
                    if ((ErrorCode = gp_DynamicAddEdge(theGraph, v, 0, W, 0)) != OK)
                        return ErrorCode;

                    // Note that this call also sets OUTONLY on the twin edge record
                    gp_SetDirection(theGraph, gp_GetFirstEdge(theGraph, W), EDGEFLAG_DIRECTION_INONLY);
                    // This macro expands to constant conditional expression, but it's the proper use of the API
                }
            }
        }

        // If there are still adjList entries after the read operation
        // then those entries are not representative of full undirected edges.
        // Rather, they represent incoming directed edge from other vertices
        // into vertex v. They need to be added back into v's adjacency list but
        // marked as "INONLY", while the twin is marked "OUTONLY" (by the same function).
        while (gp_IsEdge(theGraph, adjList))
        {
            e = adjList;

            gp_SetVertexVisitedInfo(theGraph, gp_GetNeighbor(theGraph, e), NIL);

            if ((adjList = gp_GetNextEdge(theGraph, e)) == e)
                adjList = NIL;

            gp_SetPrevEdge(theGraph, gp_GetNextEdge(theGraph, e), gp_GetPrevEdge(theGraph, e));
            gp_SetNextEdge(theGraph, gp_GetPrevEdge(theGraph, e), gp_GetNextEdge(theGraph, e));

            gp_AttachFirstEdge(theGraph, v, e);
            gp_SetDirection(theGraph, e, EDGEFLAG_DIRECTION_INONLY);
            // This macro expands to constant conditional expression, but it's the proper use of the API
        }
    }

    if (zeroBased)
        theGraph->graphFlags |= GRAPHFLAGS_ZEROBASEDIO;

    return OK;
}

/********************************************************************
 _ReadLEDAGraph()
 Reads the edge list from a LEDA file containing a simple undirected graph.
 LEDA files use a one-based numbering system, which is converted to
 zero-based numbers if the graph reports starting at zero as the first vertex.

 Returns: OK on success,
          NOTOK on file content error (or internal error)
 ********************************************************************/

int _ReadLEDAGraph(graphP theGraph, strOrFileP inputContainer)
{
    int ErrorCode = OK;

    int graphType = 0;
    int N = 0, M = 0, u = NIL, v = NIL;
    int zeroBasedOffset = gp_LowerBoundVertexStorage(theGraph) == 0 ? 1 : 0;
    char Line[MAXLINE + 1];

    memset(Line, '\0', (MAXLINE + 1));

    if (!sf_IsValidStrOrFile(inputContainer))
        return NOTOK;

    /*
        N.B. Skip the lines that say LEDA.GRAPH and give the node and
        edge types then determine if graph is directed (-1) or
        undirected (-2); we only support undirected graphs at this time.
    */
    for (int i = 0; i < 3; i++)
        if (sf_ReadSkipLineRemainder(inputContainer) != OK)
            return NOTOK;

    if (sf_ReadInteger(&graphType, inputContainer) != OK)
        return NOTOK;

    // N.B. We currently only support undirected graphs
    if (graphType != -2)
        return NOTOK;

    /*
        Skip any preceding whitespace, read the number of vertices N,
        and skip any subsequent whitespace.
    */
    if (sf_ReadSkipWhitespace(inputContainer) != OK)
        return NOTOK;
    if (sf_ReadInteger(&N, inputContainer) != OK)
        return NOTOK;
    if (sf_ReadSkipWhitespace(inputContainer) != OK)
        return NOTOK;

    if (gp_EnsureVertexCapacity(theGraph, N) != OK)
        return NOTOK;

    for (v = gp_LowerBoundVertices(theGraph); v < gp_UpperBoundVertices(theGraph); ++v)
        if (sf_fgets(Line, MAXLINE, inputContainer) == NULL)
            return NOTOK;

    /* Read the number of edges */
    if (sf_ReadSkipWhitespace(inputContainer) != OK)
        return NOTOK;
    if (sf_ReadInteger(&M, inputContainer) != OK)
        return NOTOK;
    if (sf_ReadSkipWhitespace(inputContainer) != OK)
        return NOTOK;

    /* Read and add each edge, omitting loops and parallel edges */
    for (int m = 0; m < M; m++)
    {
        if (sf_ReadSkipWhitespace(inputContainer) != OK)
            return NOTOK;
        if (sf_ReadInteger(&u, inputContainer) != OK)
            return NOTOK;
        if (sf_ReadSkipWhitespace(inputContainer) != OK)
            return NOTOK;
        if (sf_ReadInteger(&v, inputContainer) != OK)
            return NOTOK;
        if (sf_ReadSkipLineRemainder(inputContainer) != OK)
            return NOTOK;

        if (u != v && !gp_IsNeighbor(theGraph, u - zeroBasedOffset, v - zeroBasedOffset))
        {
            if ((ErrorCode = gp_DynamicAddEdge(theGraph, u - zeroBasedOffset, 0, v - zeroBasedOffset, 0)) != OK)
                return ErrorCode;
        }
    }

    if (zeroBasedOffset)
        theGraph->graphFlags |= GRAPHFLAGS_ZEROBASEDIO;

    return OK;
}

/********************************************************************
 gp_Read()

 Populates theGraph from the contents of the input file with path
 and name given by fileName.

 Pass "stdin" for the fileName to read from the stdin stream.

 Returns: OK, NOTOK on internal error
 ********************************************************************/

int gp_Read(graphP theGraph, char const *fileName)
{
    strOrFileP inputContainer = NULL;

    if (theGraph == NULL || fileName == NULL || strlen(fileName) == 0)
        return NOTOK;

    if ((inputContainer = sf_NewInputContainer(NULL, fileName)) == NULL)
        return NOTOK;

    return _ReadGraph(theGraph, (&inputContainer));
}

/********************************************************************
 gp_ReadFromString()

 Populates theGraph using the information stored in inputStr.

 The caller owns the memory of inputStr, as the contents of inputStr are copied
 into the inputContainer's internal strBuf, and therefore is responsible for
 freeing the inputStr after gp_ReadFromString().

 Returns NOTOK for any error, or OK otherwise
 ********************************************************************/

int gp_ReadFromString(graphP theGraph, char *inputStr)
{
    strOrFileP inputContainer = NULL;

    if (theGraph == NULL || inputStr == NULL || strlen(inputStr) == 0)
        return NOTOK;

    if ((inputContainer = sf_NewInputContainer(inputStr, NULL)) == NULL)
        return NOTOK;

    return _ReadGraph(theGraph, (&inputContainer));
}

/********************************************************************
 _ReadGraph()

 Determines the graph input format by parsing the first line of the
 input stream or string contained by the inputContainer and calling the
 appropriate read function, then then cleans up the inputContainer and
 returns the graph.

 Digraphs and loop edges are not supported in the adjacency matrix
 format, which is upper triangular.

 In the adjacency list format, digraphs are supported. Loop edges are
 ignored without producing an error.
 ********************************************************************/

int _ReadGraph(graphP theGraph, strOrFileP *pInputContainer)
{
    int RetVal = OK;

    int extraDataAllowed = FALSE;
    char lineBuff[MAXLINE + 1];

    memset(lineBuff, '\0', (MAXLINE + 1));

    if (!sf_IsValidStrOrFile((*pInputContainer)))
        return NOTOK;

    if (sf_fgets(lineBuff, MAXLINE, (*pInputContainer)) == NULL)
    {
        sf_Free(pInputContainer);
        return NOTOK;
    }

    if (sf_ungets(lineBuff, (*pInputContainer)) != OK)
    {
        sf_Free(pInputContainer);
        return NOTOK;
    }

    if (strncmp(lineBuff, "LEDA.GRAPH", strlen("LEDA.GRAPH")) == 0)
    {
        RetVal = _ReadLEDAGraph(theGraph, (*pInputContainer));
    }
    else if (strncmp(lineBuff, "N=", strlen("N=")) == 0)
    {
        RetVal = _ReadAdjList(theGraph, (*pInputContainer));
        if (RetVal == OK)
            extraDataAllowed = TRUE;
    }
    else if (isdigit(lineBuff[0]))
    {
        RetVal = _ReadAdjMatrix(theGraph, (*pInputContainer));
        if (RetVal == OK)
            extraDataAllowed = TRUE;
    }
    else
    {
        // N.B. Unlike the other _Read functions, we are relinquishing
        // ownership of inputContainer to the G6ReadIterator, which
        // calls sf_Free() when ending iteration. This will mean that
        // (*pInputContainer) is NULL after we return from this call.
        RetVal = _g6_ReadGraphFromStrOrFile(theGraph, pInputContainer);
    }

    // The possibility of "extra data" is not allowed for .g6 format:
    // .g6 files may contain multiple graphs, which are not valid input
    // for the extra data readers (i.e. fpReadPostProcess) Additionally,
    // we don't want to process extra data unless the graph reading
    // was OK.
    if (extraDataAllowed)
    {
        char charAfterGraphRead = EOF;
        if ((charAfterGraphRead = sf_getc((*pInputContainer))) != EOF)
        {
            if (sf_ungetc(charAfterGraphRead, (*pInputContainer)) != charAfterGraphRead)
                RetVal = NOTOK;
            else
            {
                strBufP extraData = sb_New(0);
                if (extraData == NULL)
                    RetVal = NOTOK;
                else
                {
                    while (sf_fgets(lineBuff, MAXLINE, (*pInputContainer)) != NULL)
                    {
                        if (sb_ConcatString(extraData, lineBuff) != OK)
                        {
                            RetVal = NOTOK;
                            break;
                        }
                    }

                    if (sb_GetSize(extraData) > 0)
                        RetVal = theGraph->functions->fpReadPostprocess(theGraph, sb_GetReadString(extraData));

                    sb_Free(&extraData);
                    extraData = NULL;
                }
            }
        }
    }

    // This is a no-op if pInputContainer or *pInputContainer is already NULL,
    // such as in the case of G6 file processing. This cleans up for the other
    // file types.
    sf_Free(pInputContainer);

    return RetVal;
}

int _ReadPostprocess(graphP theGraph, char *extraData)
{
    return OK;
}

/********************************************************************
 _WriteAdjList()
 For each vertex, we write its number, a colon, the list of adjacent
 vertices, then a NIL.  The vertices occupy the first N positions of
 theGraph. Each vertex is also has indicators of the first and last
 adjacency nodes (edge records) in its adjacency list.

 Returns: NOTOK for parameter errors; OK otherwise.
 ********************************************************************/

int _WriteAdjList(graphP theGraph, strOrFileP outputContainer)
{
    int v = NIL, e = NIL;
    int zeroBasedVertexOffset = 0, adjacencyListTerminator = NIL;
    char numberStr[MAXCHARSFOR32BITINT + 1];

    memset(numberStr, '\0', (MAXCHARSFOR32BITINT + 1) * sizeof(char));

    if (theGraph == NULL || !sf_IsValidStrOrFile(outputContainer))
        return NOTOK;

    // Write the number of vertices of the graph to the file or string buffer
    if (sprintf(numberStr, "N=%d\n", gp_GetN(theGraph)) < 1)
        return NOTOK;
    if (sf_fputs(numberStr, outputContainer) == EOF)
        return NOTOK;

    // If we are supposed to write 0-based output, then we have to adjust the vertex offset and the
    // adjacency list terminator based on whether this library has been compiled with 0-based or
    // 1-based array indexing for the in-memory data structure (i.e., compiled with
    // USE_1BASEDARRAYS USE_0BASEDARRAYS). The macro invoked is responsive to the difference.
    if (gp_GetGraphFlags(theGraph) & GRAPHFLAGS_ZEROBASEDIO)
    {
        zeroBasedVertexOffset = gp_LowerBoundVertexStorage(theGraph);
        // If the graph must be written 0-based, then the adjacency list terminator must be -1,
        // even if the internal representation is 1-based (i.e. when USE_1BASEDARRAYS, NIL == 0,
        // but the output needs to be -1 for 0-based output)
        adjacencyListTerminator = -1;
    }

    // Write the adjacency list of each vertex
    for (v = gp_LowerBoundVertices(theGraph); v < gp_UpperBoundVertices(theGraph); ++v)
    {
        if (sprintf(numberStr, "%d:", v - zeroBasedVertexOffset) < 1)
            return NOTOK;
        if (sf_fputs(numberStr, outputContainer) == EOF)
            return NOTOK;

        e = gp_GetLastEdge(theGraph, v);
        while (gp_IsEdge(theGraph, e))
        {
            if (gp_GetDirection(theGraph, e) != EDGEFLAG_DIRECTION_INONLY)
            {
                if (sprintf(numberStr, " %d", gp_GetNeighbor(theGraph, e) - zeroBasedVertexOffset) < 1)
                    return NOTOK;
                if (sf_fputs(numberStr, outputContainer) == EOF)
                    return NOTOK;
            }

            e = gp_GetPrevEdge(theGraph, e);
        }

        // Write NIL at the end of the adjacency list (in zero-based I/O, NIL was -1)
        if (sprintf(numberStr, " %d\n", adjacencyListTerminator) < 1)
            return NOTOK;
        if (sf_fputs(numberStr, outputContainer) == EOF)
            return NOTOK;
    }

    return OK;
}

/********************************************************************
 _WriteAdjMatrix()
 Outputs upper triangular matrix representation capable of being
 read by _ReadAdjMatrix().

 theGraph and one of Outfile or theStrBuf must be non-NULL.

 Note: This routine does not support digraphs and will return an
       error if a directed edge is found.

 returns OK for success, NOTOK for failure
 ********************************************************************/

int _WriteAdjMatrix(graphP theGraph, strOrFileP outputContainer)
{
    int v = NIL, e = NIL;
    char *Row = NULL;
    char numberStr[MAXCHARSFOR32BITINT + 1];
    memset(numberStr, '\0', (MAXCHARSFOR32BITINT + 1) * sizeof(char));

    if (theGraph == NULL || !sf_IsValidStrOrFile(outputContainer))
        return NOTOK;

    // Write the number of vertices in the graph to the file or string buffer
    if (sprintf(numberStr, "%d\n", gp_GetN(theGraph)) < 1)
        return NOTOK;
    if (sf_fputs(numberStr, outputContainer) == EOF)
        return NOTOK;

    // Allocate memory for storing a string expression of one row at a time
    Row = (char *)malloc((gp_GetN(theGraph) + 2) * sizeof(char));
    if (Row == NULL)
        return NOTOK;

    // Construct the upper triangular matrix representation one row at a time
    for (v = gp_LowerBoundVertices(theGraph); v < gp_UpperBoundVertices(theGraph); ++v)
    {
        for (int i = gp_LowerBoundVertices(theGraph); i <= v; i++)
            Row[i - gp_LowerBoundVertices(theGraph)] = ' ';

        for (int i = v + 1; i < gp_UpperBoundVertices(theGraph); i++)
            Row[i - gp_LowerBoundVertices(theGraph)] = '0';

        e = gp_GetFirstEdge(theGraph, v);
        while (gp_IsEdge(theGraph, e))
        {
            if (gp_GetDirection(theGraph, e) == EDGEFLAG_DIRECTION_INONLY)
                return NOTOK;

            if (gp_GetNeighbor(theGraph, e) > v)
                Row[gp_GetNeighbor(theGraph, e) - gp_LowerBoundVertices(theGraph)] = '1';

            e = gp_GetNextEdge(theGraph, e);
        }

        Row[gp_GetN(theGraph)] = '\n';
        Row[gp_GetN(theGraph) + 1] = '\0';

        // Write the row to the file or string buffer
        if (sf_fputs(Row, outputContainer) == EOF)
            return NOTOK;
    }

    free(Row);
    Row = NULL;

    return OK;
}

/********************************************************************
 ********************************************************************/

char _GetEdgeTypeChar(graphP theGraph, int e)
{
    char type = 'U';

    if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_CHILD)
        type = 'C';
    else if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_FORWARD)
        type = 'F';
    else if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_PARENT)
        type = 'P';
    else if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_BACK)
        type = 'B';
    else if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_TREE)
        type = 'T';

    return type;
}

/********************************************************************
 ********************************************************************/

char _GetObstructionMarkChar(graphP theGraph, int v)
{
    char type = 'U';

    if (gp_GetObstructionMark(theGraph, v) == ANYVERTEX_OBSTRUCTIONMARK_HIGH_RXW)
        type = 'X';
    else if (gp_GetObstructionMark(theGraph, v) == ANYVERTEX_OBSTRUCTIONMARK_LOW_RXW)
        type = 'x';
    if (gp_GetObstructionMark(theGraph, v) == ANYVERTEX_OBSTRUCTIONMARK_HIGH_RYW)
        type = 'Y';
    else if (gp_GetObstructionMark(theGraph, v) == ANYVERTEX_OBSTRUCTIONMARK_LOW_RYW)
        type = 'y';

    return type;
}

/********************************************************************
 _WriteDebugInfo()
 Writes adjacency list, but also includes the type value of each edge,
 e.g. is it an edge record to a DFS child, a descendant (forward edge),
 or ancestor (back edge), and the L, A and DFSParent of each vertex.
 ********************************************************************/

int _WriteDebugInfo(graphP theGraph, strOrFileP outputContainer)
{
    int v = NIL, e = NIL;
    char lineBuf[MAXLINE + 1];

    memset(lineBuf, '\0', (MAXLINE + 1) * sizeof(char));

    if (theGraph == NULL || !sf_IsValidStrOrFile(outputContainer))
        return NOTOK;

    /* Print parent copy vertices and their adjacency lists */
    if (sprintf(lineBuf, "DEBUG N=%d M=%d\n", gp_GetN(theGraph), gp_GetM(theGraph)) < 1)
        return NOTOK;
    if (sf_fputs(lineBuf, outputContainer) == EOF)
        return NOTOK;

    for (v = gp_LowerBoundVertices(theGraph); v < gp_UpperBoundVertices(theGraph); ++v)
    {
        if (sprintf(lineBuf, "%d(P=%d,lA=%d,LowPt=%d,v=%d):",
                    v, gp_GetVertexParent(theGraph, v),
                    gp_GetVertexLeastAncestor(theGraph, v),
                    gp_GetVertexLowpoint(theGraph, v),
                    gp_GetIndex(theGraph, v)) < 1)
            return NOTOK;
        if (sf_fputs(lineBuf, outputContainer) == EOF)
            return NOTOK;

        e = gp_GetFirstEdge(theGraph, v);
        while (gp_IsEdge(theGraph, e))
        {
            if (sprintf(lineBuf, " %d(e=%d)", gp_GetNeighbor(theGraph, e), e) < 1)
                return NOTOK;
            if (sf_fputs(lineBuf, outputContainer) == EOF)
                return NOTOK;
            e = gp_GetNextEdge(theGraph, e);
        }

        if (sprintf(lineBuf, " %d\n", NIL) < 1)
            return NOTOK;
        if (sf_fputs(lineBuf, outputContainer) == EOF)
            return NOTOK;
    }

    /* Print any root copy vertices and their adjacency lists */

    for (v = gp_LowerBoundVirtualVertices(theGraph); v < gp_UpperBoundVirtualVertices(theGraph); ++v)
    {
        if (!gp_VirtualVertexInUse(theGraph, v))
            continue;

        if (sprintf(lineBuf, "%d(copy of=%d, DFS child=%d):",
                    v, gp_GetIndex(theGraph, v),
                    gp_GetDFSChildFromBicompRoot(theGraph, v)) < 1)
            return NOTOK;
        if (sf_fputs(lineBuf, outputContainer) == EOF)
            return NOTOK;

        e = gp_GetFirstEdge(theGraph, v);
        while (gp_IsEdge(theGraph, e))
        {
            if (sprintf(lineBuf, " %d(e=%d)", gp_GetNeighbor(theGraph, e), e) < 1)
                return NOTOK;
            if (sf_fputs(lineBuf, outputContainer) == EOF)
                return NOTOK;

            e = gp_GetNextEdge(theGraph, e);
        }

        if (sprintf(lineBuf, " %d\n", NIL) < 1)
            return NOTOK;
        if (sf_fputs(lineBuf, outputContainer) == EOF)
            return NOTOK;
    }

    /* Print information about vertices and root copy (virtual) vertices */
    if (sf_fputs("\nVERTEX INFORMATION\n", outputContainer) == EOF)
        return NOTOK;

    for (v = gp_LowerBoundVertices(theGraph); v < gp_UpperBoundVertices(theGraph); ++v)
    {
        if (sprintf(lineBuf, "V[%3d] index=%3d, type=%c, first edge=%3d, last edge=%3d\n",
                    v,
                    gp_GetIndex(theGraph, v),
                    (gp_IsVirtualVertex(theGraph, v) ? 'X' : _GetObstructionMarkChar(theGraph, v)),
                    gp_GetFirstEdge(theGraph, v),
                    gp_GetLastEdge(theGraph, v)) < 1)
            return NOTOK;
        if (sf_fputs(lineBuf, outputContainer) == EOF)
            return NOTOK;
    }
    for (v = gp_LowerBoundVirtualVertices(theGraph); v < gp_UpperBoundVirtualVertices(theGraph); ++v)
    {
        if (gp_VirtualVertexNotInUse(theGraph, v))
            continue;

        if (sprintf(lineBuf, "V[%3d] index=%3d, type=%c, first edge=%3d, last edge=%3d\n",
                    v,
                    gp_GetIndex(theGraph, v),
                    (gp_IsVirtualVertex(theGraph, v) ? 'X' : _GetObstructionMarkChar(theGraph, v)),
                    gp_GetFirstEdge(theGraph, v),
                    gp_GetLastEdge(theGraph, v)) < 1)
            return NOTOK;
        if (sf_fputs(lineBuf, outputContainer) == EOF)
            return NOTOK;
    }

    /* Print information about edges */

    if (sf_fputs("\nEDGE INFORMATION\n", outputContainer) == EOF)
        return NOTOK;

    for (e = gp_LowerBoundEdges(theGraph); e < gp_UpperBoundEdges(theGraph); ++e)
    {
        if (gp_EdgeInUse(theGraph, e))
        {
            if (sprintf(lineBuf, "E[%3d] neighbor=%3d, type=%c, next edge=%3d, prev edge=%3d\n",
                        e,
                        gp_GetNeighbor(theGraph, e),
                        _GetEdgeTypeChar(theGraph, e),
                        gp_GetNextEdge(theGraph, e),
                        gp_GetPrevEdge(theGraph, e)) < 1)
                return NOTOK;
            if (sf_fputs(lineBuf, outputContainer) == EOF)
                return NOTOK;
        }
    }

    return OK;
}

/********************************************************************
 gp_Write()
 Writes theGraph into the file.
 Pass "stdout" or "stderr" to fileName to write to the corresponding stream
 Pass WRITE_G6, WRITE_ADJLIST, WRITE_ADJMATRIX, or WRITE_DEBUGINFO for writeMode

 NOTE: For digraphs, it is an error to use a writeMode other than WRITE_ADJLIST

 Returns NOTOK on error, OK on success.
 ********************************************************************/

int gp_Write(graphP theGraph, char const *fileName, int writeMode)
{
    int RetVal = OK;
    strOrFileP outputContainer = NULL;

    if (theGraph == NULL || fileName == NULL || strlen(fileName) == 0)
        return NOTOK;

    if (strcmp(fileName, "nullwrite") == 0)
        return OK;

    if ((outputContainer = sf_NewOutputContainer(NULL, fileName)) == NULL)
        return NOTOK;

    RetVal = _WriteGraph(theGraph, &outputContainer, writeMode);

    sf_Free(&outputContainer);

    return RetVal;
}

/********************************************************************
 * gp_WriteToString()
 *
 * Writes the information of theGraph into a string that is returned
 * to the caller via the pointer pointer pOutputStr.
 * The string is owned by the caller and should be released with
 * free() when the caller doesn't need the string anymore.
 * The format of the content written into the returned string is based
 * on writeMode: WRITE_G6, WRITE_ADJLIST, or WRITE_ADJMATRIX
 * (the WRITE_DEBUGINFO writeMode is not supported at this time)

 NOTE: For digraphs, it is an error to use a mode other than WRITE_ADJLIST

 Returns NOTOK on error, or OK on success along with an allocated string
         *pOutputStr that the caller must free()
 ********************************************************************/
int gp_WriteToString(graphP theGraph, char **pOutputStr, int writeMode)
{
    int RetVal = OK;

    strOrFileP outputContainer = NULL;

    if (theGraph == NULL || pOutputStr == NULL || (*pOutputStr) != NULL)
        return NOTOK;

    if ((outputContainer = sf_NewOutputContainer(pOutputStr, NULL)) == NULL)
        return NOTOK;

    RetVal = _WriteGraph(theGraph, &outputContainer, writeMode);

    sf_Free(&outputContainer);

    // NOTE: (#56) If an error was encountered when we _WriteGraph(), we do not
    // want to return garbage to the caller. When we free the output container,
    // if writing to string, this means that we will have taken the string from
    // the internal theStrBuf and have assigned it to the container's
    // pointer-pointer pOutputStr for output; if the RetVal is not OK, we
    // must free the string and set the pointer-pointer to NULL.
    if (RetVal != OK)
    {
        if (pOutputStr != NULL && (*pOutputStr) != NULL)
        {
            free((*pOutputStr));
            pOutputStr = NULL;
        }
    }

    // NOTE: If the output string is NULL or empty, need to report NOTOK
    if (pOutputStr != NULL && (*pOutputStr) == NULL)
        RetVal = NOTOK;
    else if (pOutputStr != NULL && strlen(*pOutputStr) == 0)
    {
        free((*pOutputStr));
        pOutputStr = NULL;
        RetVal = NOTOK;
    }

    return RetVal;
}

/********************************************************************
 _WriteGraph()
 Writes theGraph into the strOrFile container.

 Pass WRITE_G6, WRITE_ADJLIST, WRITE_ADJMATRIX, or WRITE_DEBUGINFO for the Mode

 NOTE: For digraphs, it is an error to use a mode other than WRITE_ADJLIST

 Returns NOTOK on error, OK on success.
 ********************************************************************/

int _WriteGraph(graphP theGraph, strOrFileP *pOutputContainer, int Mode)
{
    int RetVal = OK;

    switch (Mode)
    {
    case WRITE_G6:
        // This call takes ownership of the outputContainer, so (*pOutputContainer)
        // will be NULL upon return from this function.
        RetVal = _g6_WriteGraphToStrOrFile(theGraph, pOutputContainer);
        break;
    case WRITE_ADJLIST:
        RetVal = _WriteAdjList(theGraph, (*pOutputContainer));
        break;
    case WRITE_ADJMATRIX:
        RetVal = _WriteAdjMatrix(theGraph, (*pOutputContainer));
        break;
    case WRITE_DEBUGINFO:
        RetVal = _WriteDebugInfo(theGraph, (*pOutputContainer));
        break;
    default:
        RetVal = NOTOK;
        break;
    }

    if (RetVal == OK)
    {
        char *extraData = NULL;

        RetVal = theGraph->functions->fpWritePostprocess(theGraph, &extraData);

        if (extraData != NULL)
        {
            if (sf_fputs(extraData, (*pOutputContainer)) == EOF)
                RetVal = NOTOK;

            free(extraData);
            extraData = NULL;
        }
    }

    return RetVal;
}

/********************************************************************
 _WritePostprocess()

 By default, no additional information is written.
 ********************************************************************/

int _WritePostprocess(graphP theGraph, char **pExtraData)
{
    return OK;
}
