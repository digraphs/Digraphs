/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "graphDrawPlanar.h"
#include "graphDrawPlanar.private.h"

// Need to save and restore a graph flag related to IO
#include "../io/graphIO.h"

#include <stdlib.h>

extern void _ClearVertexVisitedFlags(graphP theGraph, int);

extern void _CollectDrawingData(DrawPlanarContext *context, int RootVertex, int W, int WPrevLink);
extern int _BreakTie(DrawPlanarContext *context, int BicompRoot, int W, int WPrevLink);

extern int _ComputeVisibilityRepresentation(DrawPlanarContext *context);
extern int _CheckVisibilityRepresentationIntegrity(DrawPlanarContext *context);

/* Forward declarations of local functions */

void _DrawPlanar_ClearStructures(DrawPlanarContext *context);
int _DrawPlanar_CreateStructures(DrawPlanarContext *context);
int _DrawPlanar_InitStructures(DrawPlanarContext *context);

void _DrawPlanar_InitEdgeRec(DrawPlanarContext *context, int v);
void _DrawPlanar_InitVertexInfo(DrawPlanarContext *context, int v);

/* Forward declarations of overloading functions */

int _DrawPlanar_MergeBicomps(graphP theGraph, int v, int RootVertex, int W, int WPrevLink);
int _DrawPlanar_HandleInactiveVertex(graphP theGraph, int BicompRoot, int *pW, int *pWPrevLink);
int _DrawPlanar_EmbedPostprocess(graphP theGraph, int v, int edgeEmbeddingResult);
int _DrawPlanar_CheckEmbeddingIntegrity(graphP theGraph, graphP origGraph);
int _DrawPlanar_CheckObstructionIntegrity(graphP theGraph, graphP origGraph);

int _DrawPlanar_EnsureVertexCapacity(graphP theGraph, int N);
void _DrawPlanar_ResetGraphStorage(graphP theGraph);
int _DrawPlanar_EnsureEdgeCapacity(graphP theGraph, int requiredEdgeCapacity);
int _DrawPlanar_SortVertices(graphP theGraph);

int _DrawPlanar_ReadPostprocess(graphP theGraph, char *extraData);
int _DrawPlanar_WritePostprocess(graphP theGraph, char **pExtraData);

/* Forward declarations of functions used by the extension system */

void *_DrawPlanar_DupContext(void *pContext, void *theGraph);
int _DrawPlanar_CopyData(void *dstContext, void *srcContext);
void _DrawPlanar_FreeContext(void *);

/****************************************************************************
 * DRAWPLANAR_ID - the variable used to hold the integer identifier for this
 * extension, enabling this feature's extension context to be distinguished
 * from other features' extension contexts that may be attached to a graph.
 ****************************************************************************/

int DRAWPLANAR_ID = 0;

/****************************************************************************
 gp_ExtendWith_DrawPlanar()

 This function adjusts the graph data structure to attach the planar graph
 drawing feature.

 To activate this feature during gp_Embed(), use EMBEDFLAGS_DRAWPLANAR.

 This method may be called immediately after gp_New() in the case of
 invoking gp_Read().  For generating graphs, gp_EnsureVertexCapacity() can
 be invoked before or after this enabling method.  This method detects if
 the vertex capacity has already been set, and if so, it will also create
 the additional data structures specific to planar graph drawing.  This makes
 it possible to invoke gp_New() and gp_EnsureVertexCapacity() together, and
 then attach this feature only if it is requested at run-time.

 Returns OK for success, NOTOK for failure.
 ****************************************************************************/

int gp_ExtendWith_DrawPlanar(graphP theGraph)
{
    DrawPlanarContext *context = NULL;

    if (theGraph == NULL || gp_GetN(theGraph) <= 0)
        return NOTOK;

    // If the drawing feature has already been attached to the graph,
    // then there is no need to attach it again
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);
    if (context != NULL)
    {
        return OK;
    }

    // Ensure theGraph is a Planarity Graph
    if (gp_ExtendWith_Planarity(theGraph) != OK)
        return NOTOK;

    // Allocate a new extension context
    context = (DrawPlanarContext *)malloc(sizeof(DrawPlanarContext));
    if (context == NULL)
    {
        return NOTOK;
    }

    // First, tell the context that it is not initialized
    context->initialized = 0;

    // Save a pointer to theGraph in the context
    context->theGraph = theGraph;

    // Put the overload functions into the context function table.
    // gp_AddExtension will overload the graph's functions with these, and
    // return the base function pointers in the context function table
    memset(&context->functions, 0, sizeof(graphFunctionTableStruct));

    context->functions.fpMergeBicomps = _DrawPlanar_MergeBicomps;
    context->functions.fpHandleInactiveVertex = _DrawPlanar_HandleInactiveVertex;
    context->functions.fpEmbedPostprocess = _DrawPlanar_EmbedPostprocess;
    context->functions.fpCheckEmbeddingIntegrity = _DrawPlanar_CheckEmbeddingIntegrity;
    context->functions.fpCheckObstructionIntegrity = _DrawPlanar_CheckObstructionIntegrity;

    context->functions.fpEnsureVertexCapacity = _DrawPlanar_EnsureVertexCapacity;
    context->functions.fpResetGraphStorage = _DrawPlanar_ResetGraphStorage;
    context->functions.fpEnsureEdgeCapacity = _DrawPlanar_EnsureEdgeCapacity;
    context->functions.fpSortVertices = _DrawPlanar_SortVertices;

    context->functions.fpReadPostprocess = _DrawPlanar_ReadPostprocess;
    context->functions.fpWritePostprocess = _DrawPlanar_WritePostprocess;

    _DrawPlanar_ClearStructures(context);

    // Store the Draw context, including the data structure and the
    // function pointers, as an extension of the graph
    if (gp_AddExtension(theGraph, &DRAWPLANAR_ID, (void *)context,
                        _DrawPlanar_DupContext, 
                        _DrawPlanar_CopyData, 
                        _DrawPlanar_FreeContext,
                        &context->functions) != OK)
    {
        _DrawPlanar_FreeContext(context);
        return NOTOK;
    }

    // Create the Draw-specific structures if the size of the graph is known
    // Attach functions are typically invoked after gp_New(), but if a graph
    // extension must be attached before gp_Read(), then the attachment
    // also happens before gp_EnsureVertexCapacity(), which means N==0.
    // However, a feature can be attached after gp_EnsureVertexCapacity(),
    // in which case there is extra work to do when N > 0.
    if (gp_GetN(theGraph) > 0)
    {
        if (_DrawPlanar_CreateStructures(context) != OK ||
            _DrawPlanar_InitStructures(context) != OK)
        {
            _DrawPlanar_FreeContext(context);
            return NOTOK;
        }
    }

    return OK;
}

/********************************************************************
 gp_Detach_DrawPlanar()
 ********************************************************************/

int gp_Detach_DrawPlanar(graphP theGraph)
{
    return gp_RemoveExtension(theGraph, DRAWPLANAR_ID);
}

/********************************************************************
 gp_GetDrawPlanarExtensionIdentifier()
 A private function that returns the DRAWPLANAR_ID.
 ********************************************************************/

int gp_GetDrawPlanarExtensionIdentifier(void)
{
    return DRAWPLANAR_ID;
}

/********************************************************************
 _DrawPlanar_ClearStructures()
 ********************************************************************/

void _DrawPlanar_ClearStructures(DrawPlanarContext *context)
{
    if (!context->initialized)
    {
        // Before initialization, the pointers are stray, not NULL
        // Once NULL or allocated, free() or LCFree() can do the job
        context->E = NULL;
        context->VI = NULL;

        context->initialized = 1;
    }
    else
    {
        if (context->E != NULL)
        {
            free(context->E);
            context->E = NULL;
        }
        if (context->VI != NULL)
        {
            free(context->VI);
            context->VI = NULL;
        }
    }
}

/********************************************************************
 _DrawPlanar_CreateStructures()
 Create uninitialized structures for the vertex and edge levels,
 and initialized structures for the graph level
 ********************************************************************/
int _DrawPlanar_CreateStructures(DrawPlanarContext *context)
{
    graphP theGraph = context->theGraph;
    int VIsize = gp_UpperBoundVertices(theGraph);
    int Esize = gp_UpperBoundEdgeStorage(theGraph);

    if (gp_GetN(theGraph) <= 0)
        return NOTOK;

    if ((context->E = (DrawPlanar_EdgeRecP)malloc(Esize * sizeof(DrawPlanar_EdgeRec))) == NULL ||
        (context->VI = (DrawPlanar_VertexInfoP)malloc(VIsize * sizeof(DrawPlanar_VertexInfo))) == NULL)
    {
        return NOTOK;
    }

    return OK;
}

/********************************************************************
 _DrawPlanar_InitStructures()
 Intended to be called when N>0.
 Initializes vertex and edge levels only. Graph level is
 already initialized in _CreateStructures()
 ********************************************************************/
int _DrawPlanar_InitStructures(DrawPlanarContext *context)
{
#ifdef USE_1BASEDARRAYS
    memset(context->VI, NIL_CHAR, gp_UpperBoundVertices(context->theGraph) * sizeof(DrawPlanar_VertexInfo));
#else
    graphP theGraph = context->theGraph;

    if (gp_GetN(theGraph) <= 0)
        return NOTOK;

    for (int v = gp_LowerBoundVertices(theGraph); v < gp_UpperBoundVertices(theGraph); ++v)
        _DrawPlanar_InitVertexInfo(context, v);
#endif

    memset(context->E, 0, gp_UpperBoundEdgeStorage(context->theGraph) * sizeof(DrawPlanar_EdgeRec));

    return OK;
}

/********************************************************************
 _DrawPlanar_DupContext()
 ********************************************************************/

void *_DrawPlanar_DupContext(void *pContext, void *theGraph)
{
    DrawPlanarContext *context = (DrawPlanarContext *)pContext;
    DrawPlanarContext *newContext = (DrawPlanarContext *)malloc(sizeof(DrawPlanarContext));

    if (newContext != NULL)
    {
        int VIsize = gp_UpperBoundVertices((graphP)theGraph);
        int Esize = gp_UpperBoundEdgeStorage((graphP)theGraph);

        *newContext = *context;

        newContext->theGraph = (graphP)theGraph;

        newContext->initialized = 0;
        _DrawPlanar_ClearStructures(newContext);
        if (((graphP)theGraph)->N > 0)
        {
            if (_DrawPlanar_CreateStructures(newContext) != OK)
            {
                _DrawPlanar_FreeContext(newContext);
                return NULL;
            }

            // Initialize custom data structures by copying
            memcpy(newContext->E, context->E, Esize * sizeof(DrawPlanar_EdgeRec));
            memcpy(newContext->VI, context->VI, VIsize * sizeof(DrawPlanar_VertexInfo));
        }
    }

    return newContext;
}

/********************************************************************
 _DrawPlanar_CopyData()
 ********************************************************************/
int _DrawPlanar_CopyData(void *dstContext, void *srcContext)
{
    DrawPlanarContext *dstDrawPlanarContext = (DrawPlanarContext *)dstContext;
    DrawPlanarContext *srcDrawPlanarContext = (DrawPlanarContext *)srcContext;
    int dstEdgeStorage, srcEdgeStorage;

    if (dstContext == NULL)
        return NOTOK;

    // If the srcContext is NULL, then the caller wants the data
    // structures in the dstContext to be reset/reinitialized

    if (srcContext == NULL)
        return _DrawPlanar_InitStructures(dstDrawPlanarContext);

    // ELSE: If there is also a srcContext, then we copy data from it
    dstEdgeStorage = gp_UpperBoundEdgeStorage(dstDrawPlanarContext->theGraph);
    srcEdgeStorage = gp_UpperBoundEdgeStorage(srcDrawPlanarContext->theGraph);

    // The caller (ultimately gp_CopyGraph()) is responsible for making sure that the
    // destination graph has enough edge capacity to receive the source graph content
    if (dstEdgeStorage < srcEdgeStorage)
        return NOTOK;

    // If the destination graph has more edge capacity, then we make sure that the
    // extra edge capacity is reinitialized
    if (dstEdgeStorage > srcEdgeStorage)
    {
        memset(dstDrawPlanarContext->E, NIL_CHAR, gp_UpperBoundEdgeStorage(dstDrawPlanarContext->theGraph) * sizeof(DrawPlanar_EdgeRec));
    }

    memcpy(dstDrawPlanarContext->E, srcDrawPlanarContext->E, gp_UpperBoundEdgeStorage(dstDrawPlanarContext->theGraph) * sizeof(DrawPlanar_EdgeRec));

    memcpy(dstDrawPlanarContext->VI, srcDrawPlanarContext->VI, gp_UpperBoundVertices(dstDrawPlanarContext->theGraph) * sizeof(DrawPlanar_VertexInfo));

    return OK;
}

/********************************************************************
 _DrawPlanar_FreeContext()
 ********************************************************************/

void _DrawPlanar_FreeContext(void *pContext)
{
    DrawPlanarContext *context = (DrawPlanarContext *)pContext;

    _DrawPlanar_ClearStructures(context);
    free(pContext);
}

/********************************************************************
 ********************************************************************/

int _DrawPlanar_EnsureVertexCapacity(graphP theGraph, int N)
{
    DrawPlanarContext *context = NULL;
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);

    if (context == NULL)
    {
        return NOTOK;
    }

    theGraph->N = N;
    theGraph->NV = N;
    if (theGraph->edgeCapacity == 0)
        theGraph->edgeCapacity = DEFAULT_EDGE_CAPACITY_FACTOR * N;

    if (_DrawPlanar_CreateStructures(context) != OK ||
        _DrawPlanar_InitStructures(context) != OK)
        return NOTOK;

    context->functions.fpEnsureVertexCapacity(theGraph, N);

    return OK;
}

/********************************************************************
 ********************************************************************/

void _DrawPlanar_ResetGraphStorage(graphP theGraph)
{
    DrawPlanarContext *context = NULL;
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);

    if (context != NULL)
    {
        // Reset the graph storage in base class(es)
        context->functions.fpResetGraphStorage(theGraph);

        // Do the reset that is specific to this module
        _DrawPlanar_InitStructures(context);
    }
}

/********************************************************************
 _DrawPlanar_EnsureEdgeCapacity()
 ********************************************************************/

int _DrawPlanar_EnsureEdgeCapacity(graphP theGraph, int requiredEdgeCapacity)
{
    DrawPlanarContext *context = NULL;
    DrawPlanar_EdgeRecP oldE = NULL, newE = NULL;
    int oldEsize = gp_UpperBoundEdgeStorage(theGraph), newEsize = 0;

    // If the requirement is already satisfied, then no work to do
    if (gp_GetEdgeCapacity(theGraph) >= requiredEdgeCapacity)
        return OK;

    // Get the graph's extension context so we can work on it
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);
    if (context == NULL)
        return NOTOK;

    // Call the superclass function to make sure lower levels of parallel
    // edge arrays can successfully meet the new capacity requirement
    if (context->functions.fpEnsureEdgeCapacity(theGraph, requiredEdgeCapacity) != OK)
        return NOTOK;

    // Save the current E so it can be freed once we replace it
    oldE = context->E;

    // The superclass EnsureEdgeCapacity method succeeded, so the graph's
    // new edge capacity is already set, which means we the upper bound of
    // the graph's edge storage gives the new parallel array size we need.
    newEsize = gp_UpperBoundEdgeStorage(theGraph);

    // We must successfully allocate the new parallel edge array
    newE = (DrawPlanar_EdgeRecP)malloc(newEsize * sizeof(DrawPlanar_EdgeRec));
    if (newE == NULL)
        return NOTOK;

    // Clear all new edge records
    memset(newE, NIL_CHAR, newEsize * sizeof(DrawPlanar_EdgeRec));

    // Copy the old edge records to the new edge records
    memcpy(newE, oldE, oldEsize * sizeof(DrawPlanar_EdgeRec));

    // Set the new edge array into the context and free the old one
    context->E = newE;
    free(oldE);

    return OK;
}

/********************************************************************
 ********************************************************************/

int _DrawPlanar_SortVertices(graphP theGraph)
{
    DrawPlanarContext *context = NULL;
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);

    if (context != NULL)
    {
        // If this is a planarity-based algorithm to which graph drawing has been attached,
        // and if the embedding process has already been completed
        if (gp_GetEmbedFlags(theGraph) == EMBEDFLAGS_DRAWPLANAR)
        {
            int v, vIndex;
            DrawPlanar_VertexInfo temp;

            // Relabel the context data members that indicate vertices
            for (v = gp_LowerBoundVertices(theGraph); v < gp_UpperBoundVertices(theGraph); ++v)
            {
                if (gp_IsVertex(theGraph, context->VI[v].ancestor))
                {
                    context->VI[v].ancestor = gp_GetIndex(theGraph, context->VI[v].ancestor);
                    context->VI[v].ancestorChild = gp_GetIndex(theGraph, context->VI[v].ancestorChild);
                }
            }

            // "Sort" the extra vertex info associated with each vertex so that it is rearranged according
            // to the index values of the vertices.  This could be done very easily with an extra array in
            // which, for each v, newVI[index of v] = VI[v].  However, this loop avoids memory allocation
            // by performing the operation (almost) in-place, except for the pre-existing visitation flags.
            _ClearVertexVisitedFlags(theGraph, FALSE);
            for (v = gp_LowerBoundVertices(theGraph); v < gp_UpperBoundVertices(theGraph); ++v)
            {
                // If the correct data has already been placed into position v
                // by prior steps, then skip to the next vertex
                if (gp_GetVisited(theGraph, v))
                    continue;

                // At the beginning of processing position v, the data in position v
                // corresponds to data that belongs at the index of v.
                vIndex = gp_GetIndex(theGraph, v);

                // Iterate on position v until it receives the correct data
                while (!gp_GetVisited(theGraph, v))
                {
                    // Place the data at position v into its proper location at position
                    // vIndex, and move vIndex's data into position v.
                    temp = context->VI[v];
                    context->VI[v] = context->VI[vIndex];
                    context->VI[vIndex] = temp;

                    // The data at position vIndex is now marked as being correct.
                    gp_SetVisited(theGraph, vIndex);

                    // The data now in position v is the data from position vIndex,
                    // whose index we now take as the new vIndex
                    vIndex = gp_GetIndex(theGraph, vIndex);
                }
            }
        }

        if (context->functions.fpSortVertices(theGraph) != OK)
            return NOTOK;

        return OK;
    }

    return NOTOK;
}

/********************************************************************
  Returns OK for a successful merge, NOTOK on an internal failure,
          or NONEMBEDDABLE if the merge is blocked
 ********************************************************************/

int _DrawPlanar_MergeBicomps(graphP theGraph, int v, int RootVertex, int W, int WPrevLink)
{
    DrawPlanarContext *context = NULL;
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);

    if (context != NULL)
    {
        if (gp_GetEmbedFlags(theGraph) == EMBEDFLAGS_DRAWPLANAR)
        {
            _CollectDrawingData(context, RootVertex, W, WPrevLink);
        }

        return context->functions.fpMergeBicomps(theGraph, v, RootVertex, W, WPrevLink);
    }

    return NOTOK;
}

/********************************************************************
 ********************************************************************/

int _DrawPlanar_HandleInactiveVertex(graphP theGraph, int BicompRoot, int *pW, int *pWPrevLink)
{
    DrawPlanarContext *context = NULL;
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);

    if (context != NULL)
    {
        int RetVal = context->functions.fpHandleInactiveVertex(theGraph, BicompRoot, pW, pWPrevLink);

        if (gp_GetEmbedFlags(theGraph) == EMBEDFLAGS_DRAWPLANAR)
        {
            if (_BreakTie(context, BicompRoot, *pW, *pWPrevLink) != OK)
                return NOTOK;
        }

        return RetVal;
    }

    return NOTOK;
}

/********************************************************************
 ********************************************************************/

void _DrawPlanar_InitEdgeRec(DrawPlanarContext *context, int e)
{
    context->E[e].pos = 0;
    context->E[e].start = 0;
    context->E[e].end = 0;
}

/********************************************************************
 ********************************************************************/

void _DrawPlanar_InitVertexInfo(DrawPlanarContext *context, int v)
{
    context->VI[v].pos = 0;
    context->VI[v].start = 0;
    context->VI[v].end = 0;

    context->VI[v].drawingFlag = DRAWINGFLAG_BEYOND;
    context->VI[v].ancestorChild = NIL;
    context->VI[v].ancestor = NIL;
    context->VI[v].tie[0] = NIL;
    context->VI[v].tie[1] = NIL;
}

/********************************************************************
 ********************************************************************/

int _DrawPlanar_EmbedPostprocess(graphP theGraph, int v, int edgeEmbeddingResult)
{
    DrawPlanarContext *context = NULL;
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);

    if (context != NULL)
    {
        int RetVal = context->functions.fpEmbedPostprocess(theGraph, v, edgeEmbeddingResult);

        if (gp_GetEmbedFlags(theGraph) == EMBEDFLAGS_DRAWPLANAR)
        {
            if (RetVal == OK)
            {
                RetVal = _ComputeVisibilityRepresentation(context);
            }
        }

        return RetVal;
    }

    return NOTOK;
}

/********************************************************************
 ********************************************************************/

int _DrawPlanar_CheckEmbeddingIntegrity(graphP theGraph, graphP origGraph)
{
    DrawPlanarContext *context = NULL;
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);

    if (context != NULL)
    {
        if (context->functions.fpCheckEmbeddingIntegrity(theGraph, origGraph) != OK)
            return NOTOK;

        return _CheckVisibilityRepresentationIntegrity(context);
    }

    return NOTOK;
}

/********************************************************************
 ********************************************************************/

int _DrawPlanar_CheckObstructionIntegrity(graphP theGraph, graphP origGraph)
{
    return OK;
}

/********************************************************************
 ********************************************************************/

int _DrawPlanar_ReadPostprocess(graphP theGraph, char *extraData)
{
    DrawPlanarContext *context = NULL;
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);

    if (context != NULL)
    {
        if (context->functions.fpReadPostprocess(theGraph, extraData) != OK)
            return NOTOK;

        else if (extraData != NULL && strlen(extraData) > 0)
        {
            int v, tempInt, e;
            char line[64], tempChar;

            sprintf(line, "<%s>", DRAWPLANAR_NAME);

            // Find the start of the data for this feature
            extraData = strstr(extraData, line);
            if (extraData == NULL)
                return NOTOK;

            // Advance past the start tag
            extraData = extraData + strlen(line) + 1;

            // Read the N lines of vertex information
            for (v = gp_LowerBoundVertices(theGraph); v < gp_UpperBoundVertices(theGraph); ++v)
            {
                sscanf(extraData, " %d%c %d %d %d", &tempInt, &tempChar,
                       &context->VI[v].pos,
                       &context->VI[v].start,
                       &context->VI[v].end);

                extraData = strchr(extraData, '\n') + 1;
            }

            // Read the lines that contain edge information
            for (e = gp_LowerBoundEdges(theGraph); e < gp_UpperBoundEdges(theGraph); ++e)
            {
                sscanf(extraData, " %d%c %d %d %d", &tempInt, &tempChar,
                       &context->E[e].pos,
                       &context->E[e].start,
                       &context->E[e].end);

                extraData = strchr(extraData, '\n') + 1;
            }
        }

        return OK;
    }

    return NOTOK;
}

/********************************************************************
 ********************************************************************/

int _DrawPlanar_WritePostprocess(graphP theGraph, char **pExtraData)
{
    DrawPlanarContext *context = NULL;
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);

    if (context != NULL)
    {
        (*pExtraData) = NULL;
        if (context->functions.fpWritePostprocess(theGraph, pExtraData) != OK)
            return NOTOK;
        else if ((*pExtraData) != NULL)
        {
            // NOTE: We currently do not support stacking WritePostprocess calls
            // from multiple extensions; it wouldn't be hard, we just don't ;)
            free((*pExtraData));
            (*pExtraData) = NULL;

            return NOTOK;
        }
        else
        {
            int v, e;
            char line[64];
            int maxLineSize = 64, extraDataPos = 0;
            char *extraData = (char *)calloc((1 + gp_GetN(theGraph) + 2 * gp_GetM(theGraph) + 1) * maxLineSize, sizeof(char));
            int zeroBasedVertexOffset = 0;
            int zeroBasedEdgeOffset = 0;

            if (extraData == NULL)
                return NOTOK;

            // If we are supposed to write 0-based output, then we have to set these two variables to indicate
            // how much to subtract from each vertex and edge index based on whether this library has been
            // compiled with 0-based or 1-based array indexing for the in-memory data structure (i.e., compiled
            // with USE_1BASEDARRAYS USE_0BASEDARRAYS). The macros invoked are responsive to the difference.
            if (gp_GetGraphFlags(theGraph) & GRAPHFLAGS_ZEROBASEDIO)
            {
                zeroBasedVertexOffset = gp_LowerBoundVertexStorage(theGraph);
                zeroBasedEdgeOffset = gp_LowerBoundEdgeStorage(theGraph);
            }

            // Bit of an unlikely case, but for safety, a bigger maxLineSize
            // and line array size are needed to handle very large graphs
            if (gp_GetN(theGraph) > 2000000000)
            {
                free(extraData);
                extraData = NULL;

                return NOTOK;
            }

            sprintf(line, "<%s>\n", DRAWPLANAR_NAME);
            strcpy(extraData + extraDataPos, line);
            extraDataPos += (int)strlen(line);

            for (v = gp_LowerBoundVertices(theGraph); v < gp_UpperBoundVertices(theGraph); ++v)
            {
                sprintf(line, "%d: %d %d %d\n", v - zeroBasedVertexOffset,
                        context->VI[v].pos,
                        context->VI[v].start,
                        context->VI[v].end);
                strcpy(extraData + extraDataPos, line);
                extraDataPos += (int)strlen(line);
            }

            for (e = gp_LowerBoundEdges(theGraph); e < gp_UpperBoundEdges(theGraph); e++)
            {
                if (gp_EdgeInUse(theGraph, e))
                {
                    sprintf(line, "%d: %d %d %d\n", e - zeroBasedEdgeOffset,
                            context->E[e].pos,
                            context->E[e].start,
                            context->E[e].end);
                    strcpy(extraData + extraDataPos, line);
                    extraDataPos += (int)strlen(line);
                }
            }

            sprintf(line, "</%s>\n", DRAWPLANAR_NAME);
            strcpy(extraData + extraDataPos, line);
            extraDataPos += (int)strlen(line);

            *pExtraData = extraData;
        }

        return OK;
    }

    return NOTOK;
}
