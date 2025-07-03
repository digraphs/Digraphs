/*
Copyright (c) 1997-2025, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "../graph.h"

/* Private functions (exported to system) */

int _ReadGraph(graphP theGraph, strOrFileP inputContainer);
int _ReadAdjMatrix(graphP theGraph, strOrFileP inputContainer);
int _ReadAdjList(graphP theGraph, strOrFileP inputContainer);
int _ReadLEDAGraph(graphP theGraph, strOrFileP inputContainer);

int _WriteGraph(graphP theGraph, strOrFileP *outputContainer, char **pOutputStr, int Mode);
int _WriteAdjList(graphP theGraph, strOrFileP outputContainer);
int _WriteAdjMatrix(graphP theGraph, strOrFileP outputContainer);
int _WriteDebugInfo(graphP theGraph, strOrFileP outputContainer);

/********************************************************************
 _ReadAdjMatrix()

 This function reads the undirected graph in upper triangular matrix format.
 Though O(N^2) time is required, this routine is useful during
 reliability testing due to the wealth of graph generating software
 that uses this format for output.
 Returns: OK, NOTOK on internal error, NONEMBEDDABLE if too many edges
 ********************************************************************/

int _ReadAdjMatrix(graphP theGraph, strOrFileP inputContainer)

{
    int N = -1;
    int v, w, Flag;

    if (sf_ValidateStrOrFile(inputContainer) != OK)
        return NOTOK;

    // Read the number of vertices from the first line of the file
    if (sf_ReadSkipWhitespace(inputContainer) != OK)
        return NOTOK;

    if (sf_ReadInteger(&N, inputContainer) != OK)
        return NOTOK;

    // Initialize the graph based on the number of vertices
    if (gp_InitGraph(theGraph, N) != OK)
        return NOTOK;

    // Read an upper-triangular matrix row for each vertex
    // Note that for the last vertex, zero flags are read, per the upper triangular format
    for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
    {
        gp_SetVertexIndex(theGraph, v, v);
        for (w = v + 1; gp_VertexInRange(theGraph, w); w++)
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

 NOTE:  This routine supports digraphs.  For a directed arc (v -> W),
        an edge record is created in both vertices, v and W, and the
        edge record in v's adjacency list is marked OUTONLY while the
        edge record in W's list is marked INONLY.
        This makes it easy to used edge directedness when appropriate
        but also seamlessly process the corresponding undirected graph.

 Returns: OK on success, NONEMBEDDABLE if success except too many edges
          NOTOK on file content error (or internal error)
 ********************************************************************/

int _ReadAdjList(graphP theGraph, strOrFileP inputContainer)
{
    int N = -1;
    int v, W, adjList, e, indexValue, ErrorCode;
    int zeroBased = FALSE;

    if (sf_ValidateStrOrFile(inputContainer) != OK)
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
    if (gp_InitGraph(theGraph, N) != OK)
        return NOTOK;

    // Clear the visited members of the vertices so they can be used
    // during the adjacency list read operation
    for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
        gp_SetVertexVisitedInfo(theGraph, v, NIL);

    // Do the adjacency list read operation for each vertex in order
    for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
    {
        // Read the vertex number
        if (sf_ReadSkipWhitespace(inputContainer) != OK)
            return NOTOK;
        if (sf_ReadInteger(&indexValue, inputContainer) != OK)
            return NOTOK;
        if (sf_ReadSkipWhitespace(inputContainer) != OK)
            return NOTOK;

        if (indexValue == 0 && v == gp_GetFirstVertex(theGraph))
            zeroBased = TRUE;
        indexValue += zeroBased ? gp_GetFirstVertex(theGraph) : 0;

        gp_SetVertexIndex(theGraph, v, indexValue);

        // The vertices are expected to be in numeric ascending order
        if (gp_GetVertexIndex(theGraph, v) != v)
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
        adjList = gp_GetFirstArc(theGraph, v);
        if (gp_IsArc(adjList))
        {
            // Store the adjacency node location in the visited member of each
            // of the preceding vertices to which v is adjacent so that we can
            // efficiently detect the adjacency during the read operation and
            // efficiently find the adjacency node.
            e = gp_GetFirstArc(theGraph, v);
            while (gp_IsArc(e))
            {
                gp_SetVertexVisitedInfo(theGraph, gp_GetNeighbor(theGraph, e), e);
                e = gp_GetNextArc(theGraph, e);
            }

            // Make the adjacency list circular, for later ease of processing
            gp_SetPrevArc(theGraph, adjList, gp_GetLastArc(theGraph, v));
            gp_SetNextArc(theGraph, gp_GetLastArc(theGraph, v), adjList);

            // Remove the list from the vertex
            gp_SetFirstArc(theGraph, v, NIL);
            gp_SetLastArc(theGraph, v, NIL);
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

            W += zeroBased ? gp_GetFirstVertex(theGraph) : 0;

            // A value below the valid range indicates the adjacency list end
            if (W < gp_GetFirstVertex(theGraph))
                break;

            // A value above the valid range is an error
            if (W > gp_GetLastVertex(theGraph))
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
                // If the adjacency node (arc) already exists, then we add it
                // as the new first arc of the vertex and delete it from adjList
                if (gp_IsArc(gp_GetVertexVisitedInfo(theGraph, W)))
                {
                    e = gp_GetVertexVisitedInfo(theGraph, W);

                    // Remove the arc e from the adjList construct
                    gp_SetVertexVisitedInfo(theGraph, W, NIL);
                    if (adjList == e)
                    {
                        if ((adjList = gp_GetNextArc(theGraph, e)) == e)
                            adjList = NIL;
                    }
                    gp_SetPrevArc(theGraph, gp_GetNextArc(theGraph, e), gp_GetPrevArc(theGraph, e));
                    gp_SetNextArc(theGraph, gp_GetPrevArc(theGraph, e), gp_GetNextArc(theGraph, e));

                    gp_AttachFirstArc(theGraph, v, e);
                }

                // If an adjacency node to the lower numbered vertex W does not
                // already exist, then we make a new directed arc from the current
                // vertex v to W.
                else
                {
                    // It is added as the new first arc in both vertices
                    if ((ErrorCode = gp_DynamicAddEdge(theGraph, v, 0, W, 0)) != OK)
                        return ErrorCode;

                    // Note that this call also sets OUTONLY on the twin arc
                    gp_SetDirection(theGraph, gp_GetFirstArc(theGraph, W), EDGEFLAG_DIRECTION_INONLY);
                }
            }
        }

        // If there are still adjList entries after the read operation
        // then those entries are not representative of full undirected edges.
        // Rather, they represent incoming directed arcs from other vertices
        // into vertex v. They need to be added back into v's adjacency list but
        // marked as "INONLY", while the twin is marked "OUTONLY" (by the same function).
        while (gp_IsArc(adjList))
        {
            e = adjList;

            gp_SetVertexVisitedInfo(theGraph, gp_GetNeighbor(theGraph, e), NIL);

            if ((adjList = gp_GetNextArc(theGraph, e)) == e)
                adjList = NIL;

            gp_SetPrevArc(theGraph, gp_GetNextArc(theGraph, e), gp_GetPrevArc(theGraph, e));
            gp_SetNextArc(theGraph, gp_GetPrevArc(theGraph, e), gp_GetNextArc(theGraph, e));

            gp_AttachFirstArc(theGraph, v, e);
            gp_SetDirection(theGraph, e, EDGEFLAG_DIRECTION_INONLY);
        }
    }

    if (zeroBased)
        theGraph->internalFlags |= FLAGS_ZEROBASEDIO;

    return OK;
}

/********************************************************************
 _ReadLEDAGraph()
 Reads the edge list from a LEDA file containing a simple undirected graph.
 LEDA files use a one-based numbering system, which is converted to
 zero-based numbers if the graph reports starting at zero as the first vertex.

 Returns: OK on success, NONEMBEDDABLE if success except too many edges
          NOTOK on file content error (or internal error)
 ********************************************************************/

int _ReadLEDAGraph(graphP theGraph, strOrFileP inputContainer)
{
    char Line[MAXLINE + 1];
    int N = -1;
    int graphType, M, m, u, v, ErrorCode;
    int zeroBasedOffset = gp_GetFirstVertex(theGraph) == 0 ? 1 : 0;

    if (sf_ValidateStrOrFile(inputContainer) != OK)
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

    if (gp_InitGraph(theGraph, N) != OK)
        return NOTOK;

    for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
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
    for (m = 0; m < M; m++)
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
        theGraph->internalFlags |= FLAGS_ZEROBASEDIO;

    return OK;
}

/********************************************************************
 gp_Read()

 Populates theGraph from the contents of the input file with path
 FileName.

 Pass "stdin" for the FileName to read from the stdin stream.

 Returns: OK, NOTOK on internal error, NONEMBEDDABLE if too many edges
 ********************************************************************/

int gp_Read(graphP theGraph, char *FileName)
{
    strOrFileP inputContainer = sf_New(NULL, FileName, READTEXT);
    if (inputContainer == NULL)
        return NOTOK;

    return _ReadGraph(theGraph, inputContainer);
}

/********************************************************************
 gp_ReadFromString()

 Populates theGraph using the information stored in inputStr.

 The ownership of inputStr is transferred from the caller; it is
 assigned to a strOrFile container and ownership is transferred to
 the internal helper function _ReadGraph(), which then handles
 freeing this memory.

 Returns NOTOK for any error, or OK otherwise
 ********************************************************************/

int gp_ReadFromString(graphP theGraph, char *inputStr)
{
    strOrFileP inputContainer = sf_New(inputStr, NULL, READTEXT);
    if (inputContainer == NULL)
    {
        if (inputStr != NULL)
            free(inputStr);
        inputStr = NULL;
        return NOTOK;
    }

    return _ReadGraph(theGraph, inputContainer);
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

int _ReadGraph(graphP theGraph, strOrFileP inputContainer)
{
    int RetVal = OK;
    bool extraDataAllowed = false;
    char lineBuff[MAXLINE + 1];

    if (sf_ValidateStrOrFile(inputContainer) != OK)
        return NOTOK;

    if (sf_fgets(lineBuff, MAXLINE, inputContainer) == NULL)
    {
        sf_Free(&inputContainer);
        return NOTOK;
    }

    if (sf_ungets(lineBuff, inputContainer) != OK)
    {
        sf_Free(&inputContainer);
        return NOTOK;
    }

    if (strncmp(lineBuff, "LEDA.GRAPH", strlen("LEDA.GRAPH")) == 0)
    {
        RetVal = _ReadLEDAGraph(theGraph, inputContainer);
    }
    else if (strncmp(lineBuff, "N=", strlen("N=")) == 0)
    {
        RetVal = _ReadAdjList(theGraph, inputContainer);
        if (RetVal == OK)
            extraDataAllowed = true;
    }
    else if (isdigit(lineBuff[0]))
    {
        RetVal = _ReadAdjMatrix(theGraph, inputContainer);
        if (RetVal == OK)
            extraDataAllowed = true;
    }
    else
    {
        RetVal = _ReadGraphFromG6StrOrFile(theGraph, inputContainer);
        // N.B. Unlike the other _Read functions, we are relinquishing
        // ownership of inputContainer to the G6ReadIterator, which
        // calls sf_Free() when ending iteration. This assignment
        // prevents calling free on alread-freed memory.
        inputContainer = NULL;
    }

    // The possibility of "extra data" is not allowed for .g6 format:
    // .g6 files may contain multiple graphs, which are not valid input
    // for the extra data readers (i.e. fpReadPostProcess) Additionally,
    // we don't want to add extra data if the graph is nonembeddable, as
    // the FILE pointer isn't necessarily advanced past the graph
    // encoding unless OK is returned.
    if (extraDataAllowed)
    {
        char charAfterGraphRead = EOF;
        if ((charAfterGraphRead = sf_getc(inputContainer)) != EOF)
        {
            if (sf_ungetc(charAfterGraphRead, inputContainer) != charAfterGraphRead)
                RetVal = NOTOK;
            else
            {
                strBufP extraData = sb_New(0);
                if (extraData == NULL)
                    RetVal = NOTOK;
                else
                {
                    // FIXME: how do I distinguish between "there's no more content on input stream" and "I've hit an error state"
                    while (sf_fgets(lineBuff, MAXLINE, inputContainer) != NULL)
                    {
                        if (sb_ConcatString(extraData, lineBuff) != OK)
                        {
                            RetVal = NOTOK;
                            break;
                        }
                    }

                    if (sb_GetSize(extraData) > 0)
                        RetVal = theGraph->functions.fpReadPostprocess(theGraph, sb_GetReadString(extraData));

                    sb_Free(&extraData);
                    extraData = NULL;
                }
            }
        }
    }

    if (inputContainer != NULL)
        sf_Free(&inputContainer);
    inputContainer = NULL;

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
 adjacency nodes (arcs) in its adjacency list.

 Returns: NOTOK for parameter errors; OK otherwise.
 ********************************************************************/

int _WriteAdjList(graphP theGraph, strOrFileP outputContainer)
{
    int v, e;
    int zeroBasedOffset = (theGraph->internalFlags & FLAGS_ZEROBASEDIO) ? gp_GetFirstVertex(theGraph) : 0;
    char numberStr[MAXCHARSFOR32BITINT + 1];
    memset(numberStr, '\0', (MAXCHARSFOR32BITINT + 1) * sizeof(char));

    if (theGraph == NULL || sf_ValidateStrOrFile(outputContainer) != OK)
        return NOTOK;

    // Write the number of vertices of the graph to the file or string buffer
    if (sprintf(numberStr, "N=%d\n", theGraph->N) < 1)
        return NOTOK;
    if (sf_fputs(numberStr, outputContainer) == EOF)
        return NOTOK;

    // Write the adjacency list of each vertex
    for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
    {
        if (sprintf(numberStr, "%d:", v - zeroBasedOffset) < 1)
            return NOTOK;
        if (sf_fputs(numberStr, outputContainer) == EOF)
            return NOTOK;

        e = gp_GetLastArc(theGraph, v);
        while (gp_IsArc(e))
        {
            if (gp_GetDirection(theGraph, e) != EDGEFLAG_DIRECTION_INONLY)
            {
                if (sprintf(numberStr, " %d", gp_GetNeighbor(theGraph, e) - zeroBasedOffset) < 1)
                    return NOTOK;
                if (sf_fputs(numberStr, outputContainer) == EOF)
                    return NOTOK;
            }

            e = gp_GetPrevArc(theGraph, e);
        }

        // Write NIL at the end of the adjacency list (in zero-based I/O, NIL was -1)
        if (sprintf(numberStr, " %d\n", (theGraph->internalFlags & FLAGS_ZEROBASEDIO) ? -1 : NIL) < 1)
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
    int v, e, K;
    char *Row = NULL;
    char numberStr[MAXCHARSFOR32BITINT + 1];
    memset(numberStr, '\0', (MAXCHARSFOR32BITINT + 1) * sizeof(char));

    if (theGraph == NULL || sf_ValidateStrOrFile(outputContainer) != OK)
        return NOTOK;

    // Write the number of vertices in the graph to the file or string buffer
    if (sprintf(numberStr, "%d\n", theGraph->N) < 1)
        return NOTOK;
    if (sf_fputs(numberStr, outputContainer) == EOF)
        return NOTOK;

    // Allocate memory for storing a string expression of one row at a time
    Row = (char *)malloc((theGraph->N + 2) * sizeof(char));
    if (Row == NULL)
        return NOTOK;

    // Construct the upper triangular matrix representation one row at a time
    for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
    {
        for (K = gp_GetFirstVertex(theGraph); K <= v; K++)
            Row[K - gp_GetFirstVertex(theGraph)] = ' ';
        for (K = v + 1; gp_VertexInRange(theGraph, K); K++)
            Row[K - gp_GetFirstVertex(theGraph)] = '0';

        e = gp_GetFirstArc(theGraph, v);
        while (gp_IsArc(e))
        {
            if (gp_GetDirection(theGraph, e) == EDGEFLAG_DIRECTION_INONLY)
                return NOTOK;

            if (gp_GetNeighbor(theGraph, e) > v)
                Row[gp_GetNeighbor(theGraph, e) - gp_GetFirstVertex(theGraph)] = '1';

            e = gp_GetNextArc(theGraph, e);
        }

        Row[theGraph->N] = '\n';
        Row[theGraph->N + 1] = '\0';

        // Write the row to the file or string buffer
        if (sf_fputs(Row, outputContainer) == EOF)
            return NOTOK;
    }

    free(Row);
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
    else if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_RANDOMTREE)
        type = 'T';

    return type;
}

/********************************************************************
 ********************************************************************/

char _GetVertexObstructionTypeChar(graphP theGraph, int v)
{
    char type = 'U';

    if (gp_GetVertexObstructionType(theGraph, v) == VERTEX_OBSTRUCTIONTYPE_HIGH_RXW)
        type = 'X';
    else if (gp_GetVertexObstructionType(theGraph, v) == VERTEX_OBSTRUCTIONTYPE_LOW_RXW)
        type = 'x';
    if (gp_GetVertexObstructionType(theGraph, v) == VERTEX_OBSTRUCTIONTYPE_HIGH_RYW)
        type = 'Y';
    else if (gp_GetVertexObstructionType(theGraph, v) == VERTEX_OBSTRUCTIONTYPE_LOW_RYW)
        type = 'y';

    return type;
}

/********************************************************************
 _WriteDebugInfo()
 Writes adjacency list, but also includes the type value of each
 edge (e.g. is it DFS child  arc, forward arc or back arc?), and
 the L, A and DFSParent of each vertex.
 ********************************************************************/

int _WriteDebugInfo(graphP theGraph, strOrFileP outputContainer)
{
    int v, e, EsizeOccupied;
    char lineBuf[MAXLINE + 1];
    memset(lineBuf, '\0', (MAXLINE + 1) * sizeof(char));

    if (theGraph == NULL || sf_ValidateStrOrFile(outputContainer) != OK)
        return NOTOK;

    /* Print parent copy vertices and their adjacency lists */
    if (sprintf(lineBuf, "DEBUG N=%d M=%d\n", theGraph->N, theGraph->M) < 1)
        return NOTOK;
    if (sf_fputs(lineBuf, outputContainer) == EOF)
        return NOTOK;

    for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
    {
        if (sprintf(lineBuf, "%d(P=%d,lA=%d,LowPt=%d,v=%d):",
                    v, gp_GetVertexParent(theGraph, v),
                    gp_GetVertexLeastAncestor(theGraph, v),
                    gp_GetVertexLowpoint(theGraph, v),
                    gp_GetVertexIndex(theGraph, v)) < 1)
            return NOTOK;
        if (sf_fputs(lineBuf, outputContainer) == EOF)
            return NOTOK;

        e = gp_GetFirstArc(theGraph, v);
        while (gp_IsArc(e))
        {
            if (sprintf(lineBuf, " %d(e=%d)", gp_GetNeighbor(theGraph, e), e) < 1)
                return NOTOK;
            if (sf_fputs(lineBuf, outputContainer) == EOF)
                return NOTOK;
            e = gp_GetNextArc(theGraph, e);
        }

        if (sprintf(lineBuf, " %d\n", NIL) < 1)
            return NOTOK;
        if (sf_fputs(lineBuf, outputContainer) == EOF)
            return NOTOK;
    }

    /* Print any root copy vertices and their adjacency lists */

    for (v = gp_GetFirstVirtualVertex(theGraph); gp_VirtualVertexInRange(theGraph, v); v++)
    {
        if (!gp_VirtualVertexInUse(theGraph, v))
            continue;

        if (sprintf(lineBuf, "%d(copy of=%d, DFS child=%d):",
                    v, gp_GetVertexIndex(theGraph, v),
                    gp_GetDFSChildFromRoot(theGraph, v)) < 1)
            return NOTOK;
        if (sf_fputs(lineBuf, outputContainer) == EOF)
            return NOTOK;

        e = gp_GetFirstArc(theGraph, v);
        while (gp_IsArc(e))
        {
            if (sprintf(lineBuf, " %d(e=%d)", gp_GetNeighbor(theGraph, e), e) < 1)
                return NOTOK;
            if (sf_fputs(lineBuf, outputContainer) == EOF)
                return NOTOK;

            e = gp_GetNextArc(theGraph, e);
        }

        if (sprintf(lineBuf, " %d\n", NIL) < 1)
            return NOTOK;
        if (sf_fputs(lineBuf, outputContainer) == EOF)
            return NOTOK;
    }

    /* Print information about vertices and root copy (virtual) vertices */
    if (sf_fputs("\nVERTEX INFORMATION\n", outputContainer) == EOF)
        return NOTOK;

    for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
    {
        if (sprintf(lineBuf, "V[%3d] index=%3d, type=%c, first arc=%3d, last arc=%3d\n",
                    v,
                    gp_GetVertexIndex(theGraph, v),
                    (gp_IsVirtualVertex(theGraph, v) ? 'X' : _GetVertexObstructionTypeChar(theGraph, v)),
                    gp_GetFirstArc(theGraph, v),
                    gp_GetLastArc(theGraph, v)) < 1)
            return NOTOK;
        if (sf_fputs(lineBuf, outputContainer) == EOF)
            return NOTOK;
    }
    for (v = gp_GetFirstVirtualVertex(theGraph); gp_VirtualVertexInRange(theGraph, v); v++)
    {
        if (gp_VirtualVertexNotInUse(theGraph, v))
            continue;

        if (sprintf(lineBuf, "V[%3d] index=%3d, type=%c, first arc=%3d, last arc=%3d\n",
                    v,
                    gp_GetVertexIndex(theGraph, v),
                    (gp_IsVirtualVertex(theGraph, v) ? 'X' : _GetVertexObstructionTypeChar(theGraph, v)),
                    gp_GetFirstArc(theGraph, v),
                    gp_GetLastArc(theGraph, v)) < 1)
            return NOTOK;
        if (sf_fputs(lineBuf, outputContainer) == EOF)
            return NOTOK;
    }

    /* Print information about edges */

    if (sf_fputs("\nEDGE INFORMATION\n", outputContainer) == EOF)
        return NOTOK;

    EsizeOccupied = gp_EdgeInUseIndexBound(theGraph);
    for (e = gp_GetFirstEdge(theGraph); e < EsizeOccupied; e++)
    {
        if (gp_EdgeInUse(theGraph, e))
        {
            if (sprintf(lineBuf, "E[%3d] neighbor=%3d, type=%c, next arc=%3d, prev arc=%3d\n",
                        e,
                        gp_GetNeighbor(theGraph, e),
                        _GetEdgeTypeChar(theGraph, e),
                        gp_GetNextArc(theGraph, e),
                        gp_GetPrevArc(theGraph, e)) < 1)
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
 Pass "stdout" or "stderr" to FileName to write to the corresponding stream
 Pass WRITE_G6, WRITE_ADJLIST, WRITE_ADJMATRIX, or WRITE_DEBUGINFO for the Mode

 NOTE: For digraphs, it is an error to use a mode other than WRITE_ADJLIST

 Returns NOTOK on error, OK on success.
 ********************************************************************/

int gp_Write(graphP theGraph, char *FileName, int Mode)
{
    int RetVal;

    if (theGraph == NULL || FileName == NULL)
        return NOTOK;

    if (strcmp(FileName, "nullwrite") == 0)
        return OK;

    strOrFileP outputContainer = sf_New(NULL, FileName, WRITETEXT);
    if (outputContainer == NULL)
        return NOTOK;

    RetVal = _WriteGraph(theGraph, &outputContainer, NULL, Mode);

    if (outputContainer != NULL)
        sf_Free(&outputContainer);
    outputContainer = NULL;

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
 * on the Mode parameter: WRITE_G6, WRITE_ADJLIST, or WRITE_ADJMATRIX
 * (the WRITE_DEBUGINFO Mode is not supported at this time)

 NOTE: For digraphs, it is an error to use a mode other than WRITE_ADJLIST

 Returns NOTOK on error, or OK on success along with an allocated string
         *pOutputStr that the caller must free()
 ********************************************************************/
int gp_WriteToString(graphP theGraph, char **pOutputStr, int Mode)
{
    int RetVal;

    if (theGraph == NULL || pOutputStr == NULL)
        return NOTOK;

    strOrFileP outputContainer = sf_New(NULL, NULL, WRITETEXT);
    if (outputContainer == NULL)
        return NOTOK;

    RetVal = _WriteGraph(theGraph, &outputContainer, pOutputStr, Mode);

    // N.B. Since we pass ownership of the outputContainer to the
    // G6WriteIterator when we WRITE_G6, we make sure to take the string *before*
    // we endG6WriteIteration(), since that calls sf_Free() on the g6Output
    // (i.e. outputContainer) and therefore sb_Free() on theStr. This means
    // that we need to make sure outputContainer and theStr it contains are
    // both non-NULL before trying to take the string, as WRITE_ADJLIST,
    // WRITE_ADJMATRIX, and WRITE_DEBUGINFO do *not* clean up the outputContainer.
    if (RetVal == OK && outputContainer != NULL)
    {
        (*pOutputStr) = sf_takeTheStr(outputContainer);
    }

    if ((*pOutputStr) == NULL || strlen(*pOutputStr) == 0)
        RetVal = NOTOK;

    if (outputContainer != NULL)
        sf_Free(&outputContainer);
    outputContainer = NULL;

    return RetVal;
}

/********************************************************************
 _WriteGraph()
 Writes theGraph into the strOrFile container.

 Pass WRITE_G6, WRITE_ADJLIST, WRITE_ADJMATRIX, or WRITE_DEBUGINFO for the Mode

 NOTE: For digraphs, it is an error to use a mode other than WRITE_ADJLIST

 Returns NOTOK on error, OK on success.
 ********************************************************************/

int _WriteGraph(graphP theGraph, strOrFileP *outputContainer, char **pOutputStr, int Mode)
{
    int RetVal = OK;

    switch (Mode)
    {
    case WRITE_G6:
        RetVal = _WriteGraphToG6StrOrFile(theGraph, (*outputContainer), pOutputStr);
        // Since G6WriteIterator owns the outputContainer, it'll
        // free it, so don't want to try to double-free
        (*outputContainer) = NULL;
        break;
    case WRITE_ADJLIST:
        RetVal = _WriteAdjList(theGraph, (*outputContainer));
        break;
    case WRITE_ADJMATRIX:
        RetVal = _WriteAdjMatrix(theGraph, (*outputContainer));
        break;
    case WRITE_DEBUGINFO:
        RetVal = _WriteDebugInfo(theGraph, (*outputContainer));
        break;
    default:
        RetVal = NOTOK;
        break;
    }

    if (RetVal == OK)
    {
        char *extraData = NULL;

        RetVal = theGraph->functions.fpWritePostprocess(theGraph, &extraData);

        if (extraData != NULL)
        {
            if (sf_fputs(extraData, (*outputContainer)) == EOF)
                RetVal = NOTOK;
            free(extraData);
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

/********************************************************************
 _Log()

 When the project is compiled with LOGGING enabled, this method writes
 a string to the file PLANARITY.LOG in the current working directory.
 On first write, the file is created or cleared.
 Call this method with NULL to close the log file.
 ********************************************************************/

void _Log(char *Str)
{
    static FILE *logfile = NULL;

    if (logfile == NULL)
    {
        if ((logfile = fopen("PLANARITY.LOG", WRITETEXT)) == NULL)
            return;
    }

    if (Str != NULL)
    {
        fprintf(logfile, "%s", Str);
        fflush(logfile);
    }
    else
        fclose(logfile);
}

void _LogLine(char *Str)
{
    _Log(Str);
    _Log("\n");
}

static char LogStr[MAXLINE + 1];

char *_MakeLogStr1(char *format, int one)
{
    sprintf(LogStr, format, one);
    return LogStr;
}

char *_MakeLogStr2(char *format, int one, int two)
{
    sprintf(LogStr, format, one, two);
    return LogStr;
}

char *_MakeLogStr3(char *format, int one, int two, int three)
{
    sprintf(LogStr, format, one, two, three);
    return LogStr;
}

char *_MakeLogStr4(char *format, int one, int two, int three, int four)
{
    sprintf(LogStr, format, one, two, three, four);
    return LogStr;
}

char *_MakeLogStr5(char *format, int one, int two, int three, int four, int five)
{
    sprintf(LogStr, format, one, two, three, four, five);
    return LogStr;
}
