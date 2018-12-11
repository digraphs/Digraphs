/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include <stdlib.h>

#include "graphDrawPlanar.private.h"
#include "graphDrawPlanar.h"

extern void _ClearVertexVisitedFlags(graphP theGraph, int);

extern void _CollectDrawingData(DrawPlanarContext *context, int RootVertex, int W, int WPrevLink);
extern int  _BreakTie(DrawPlanarContext *context, int BicompRoot, int W, int WPrevLink);

extern int  _ComputeVisibilityRepresentation(DrawPlanarContext *context);
extern int  _CheckVisibilityRepresentationIntegrity(DrawPlanarContext *context);

/* Forward declarations of local functions */

void _DrawPlanar_ClearStructures(DrawPlanarContext *context);
int  _DrawPlanar_CreateStructures(DrawPlanarContext *context);
int  _DrawPlanar_InitStructures(DrawPlanarContext *context);

void _DrawPlanar_InitEdgeRec(DrawPlanarContext *context, int v);
void _DrawPlanar_InitVertexInfo(DrawPlanarContext *context, int v);

/* Forward declarations of overloading functions */

int  _DrawPlanar_MergeBicomps(graphP theGraph, int v, int RootVertex, int W, int WPrevLink);
int  _DrawPlanar_HandleInactiveVertex(graphP theGraph, int BicompRoot, int *pW, int *pWPrevLink);
int  _DrawPlanar_EmbedPostprocess(graphP theGraph, int v, int edgeEmbeddingResult);
int  _DrawPlanar_CheckEmbeddingIntegrity(graphP theGraph, graphP origGraph);
int  _DrawPlanar_CheckObstructionIntegrity(graphP theGraph, graphP origGraph);

int  _DrawPlanar_InitGraph(graphP theGraph, int N);
void _DrawPlanar_ReinitializeGraph(graphP theGraph);
int  _DrawPlanar_EnsureArcCapacity(graphP theGraph, int requiredArcCapacity);
int  _DrawPlanar_SortVertices(graphP theGraph);

int  _DrawPlanar_ReadPostprocess(graphP theGraph, void *extraData, long extraDataSize);
int  _DrawPlanar_WritePostprocess(graphP theGraph, void **pExtraData, long *pExtraDataSize);

/* Forward declarations of functions used by the extension system */

void *_DrawPlanar_DupContext(void *pContext, void *theGraph);
void _DrawPlanar_FreeContext(void *);

/****************************************************************************
 * DRAWPLANAR_ID - the variable used to hold the integer identifier for this
 * extension, enabling this feature's extension context to be distinguished
 * from other features' extension contexts that may be attached to a graph.
 ****************************************************************************/

int DRAWPLANAR_ID = 0;

/****************************************************************************
 gp_AttachDrawPlanar()

 This function adjusts the graph data structure to attach the planar graph
 drawing feature.

 To activate this feature during gp_Embed(), use EMBEDFLAGS_DRAWPLANAR.

 This method may be called immediately after gp_New() in the case of
 invoking gp_Read().  For generating graphs, gp_InitGraph() can be invoked
 before or after this enabling method.  This method detects if the core
 graph has already been initialized, and if so, it will initialize the
 additional data structures specific to planar graph drawing.  This makes
 it possible to invoke gp_New() and gp_InitGraph() together, and then attach
 this feature only if it is requested at run-time.

 Returns OK for success, NOTOK for failure.
 ****************************************************************************/

int  gp_AttachDrawPlanar(graphP theGraph)
{
     DrawPlanarContext *context = NULL;

     // If the drawing feature has already been attached to the graph,
     // then there is no need to attach it again
     gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);
     if (context != NULL)
     {
         return OK;
     }

     // Allocate a new extension context
     context = (DrawPlanarContext *) malloc(sizeof(DrawPlanarContext));
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
     memset(&context->functions, 0, sizeof(graphFunctionTable));

     context->functions.fpMergeBicomps = _DrawPlanar_MergeBicomps;
     context->functions.fpHandleInactiveVertex = _DrawPlanar_HandleInactiveVertex;
     context->functions.fpEmbedPostprocess = _DrawPlanar_EmbedPostprocess;
     context->functions.fpCheckEmbeddingIntegrity = _DrawPlanar_CheckEmbeddingIntegrity;
     context->functions.fpCheckObstructionIntegrity = _DrawPlanar_CheckObstructionIntegrity;

     context->functions.fpInitGraph = _DrawPlanar_InitGraph;
     context->functions.fpReinitializeGraph = _DrawPlanar_ReinitializeGraph;
     context->functions.fpEnsureArcCapacity = _DrawPlanar_EnsureArcCapacity;
     context->functions.fpSortVertices = _DrawPlanar_SortVertices;

     context->functions.fpReadPostprocess = _DrawPlanar_ReadPostprocess;
     context->functions.fpWritePostprocess = _DrawPlanar_WritePostprocess;

     _DrawPlanar_ClearStructures(context);

     // Store the Draw context, including the data structure and the
     // function pointers, as an extension of the graph
     if (gp_AddExtension(theGraph, &DRAWPLANAR_ID, (void *) context,
                         _DrawPlanar_DupContext, _DrawPlanar_FreeContext,
                         &context->functions) != OK)
     {
         _DrawPlanar_FreeContext(context);
         return NOTOK;
     }

     // Create the Draw-specific structures if the size of the graph is known
     // Attach functions are typically invoked after gp_New(), but if a graph
     // extension must be attached before gp_Read(), then the attachment
     // also happens before gp_InitGraph() because gp_Read() invokes init only
     // after it reads the order N of the graph.  Hence, this attach call would
     // occur when N==0 in the case of gp_Read().
     // But if a feature is attached after gp_InitGraph(), then N > 0 and so we
     // need to create and initialize all the custom data structures
     if (theGraph->N > 0)
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
 gp_DetachDrawPlanar()
 ********************************************************************/

int gp_DetachDrawPlanar(graphP theGraph)
{
    return gp_RemoveExtension(theGraph, DRAWPLANAR_ID);
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
int  _DrawPlanar_CreateStructures(DrawPlanarContext *context)
{
	 graphP theGraph = context->theGraph;
     int VIsize = gp_PrimaryVertexIndexBound(theGraph);
     int Esize = gp_EdgeIndexBound(theGraph);

     if (theGraph->N <= 0)
         return NOTOK;

     if ((context->E = (DrawPlanar_EdgeRecP) malloc(Esize*sizeof(DrawPlanar_EdgeRec))) == NULL ||
         (context->VI = (DrawPlanar_VertexInfoP) malloc(VIsize*sizeof(DrawPlanar_VertexInfo))) == NULL
        )
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
int  _DrawPlanar_InitStructures(DrawPlanarContext *context)
{
#if NIL == 0
	memset(context->VI, NIL_CHAR, gp_PrimaryVertexIndexBound(context->theGraph) * sizeof(DrawPlanar_VertexInfo));
	memset(context->E, NIL_CHAR, gp_EdgeIndexBound(context->theGraph) * sizeof(DrawPlanar_EdgeRec));
#else
     int v, e, Esize;
     graphP theGraph = context->theGraph;

     if (theGraph->N <= 0)
         return NOTOK;

     for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
          _DrawPlanar_InitVertexInfo(context, v);

     Esize = gp_EdgeIndexBound(theGraph);
     for (e = gp_GetFirstEdge(theGraph); e < Esize; e++)
          _DrawPlanar_InitEdgeRec(context, e);
#endif

     return OK;
}

/********************************************************************
 _DrawPlanar_DupContext()
 ********************************************************************/

void *_DrawPlanar_DupContext(void *pContext, void *theGraph)
{
     DrawPlanarContext *context = (DrawPlanarContext *) pContext;
     DrawPlanarContext *newContext = (DrawPlanarContext *) malloc(sizeof(DrawPlanarContext));

     if (newContext != NULL)
     {
         int VIsize = gp_PrimaryVertexIndexBound((graphP) theGraph);
         int Esize = gp_EdgeIndexBound((graphP) theGraph);

         *newContext = *context;

         newContext->theGraph = (graphP) theGraph;

         newContext->initialized = 0;
         _DrawPlanar_ClearStructures(newContext);
         if (((graphP) theGraph)->N > 0)
         {
             if (_DrawPlanar_CreateStructures(newContext) != OK)
             {
                 _DrawPlanar_FreeContext(newContext);
                 return NULL;
             }

             // Initialize custom data structures by copying
             memcpy(newContext->E, context->E, Esize*sizeof(DrawPlanar_EdgeRec));
             memcpy(newContext->VI, context->VI, VIsize*sizeof(DrawPlanar_VertexInfo));
         }
     }

     return newContext;
}

/********************************************************************
 _DrawPlanar_FreeContext()
 ********************************************************************/

void _DrawPlanar_FreeContext(void *pContext)
{
     DrawPlanarContext *context = (DrawPlanarContext *) pContext;

     _DrawPlanar_ClearStructures(context);
     free(pContext);
}

/********************************************************************
 ********************************************************************/

int  _DrawPlanar_InitGraph(graphP theGraph, int N)
{
    DrawPlanarContext *context = NULL;
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);

    if (context == NULL)
        return NOTOK;

	theGraph->N = N;
	theGraph->NV = N;
	if (theGraph->arcCapacity == 0)
		theGraph->arcCapacity = 2*DEFAULT_EDGE_LIMIT*N;

	if (_DrawPlanar_CreateStructures(context) != OK ||
		_DrawPlanar_InitStructures(context) != OK)
		return NOTOK;

	context->functions.fpInitGraph(theGraph, N);

    return OK;
}

/********************************************************************
 ********************************************************************/

void _DrawPlanar_ReinitializeGraph(graphP theGraph)
{
    DrawPlanarContext *context = NULL;
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);

    if (context != NULL)
    {
		// Reinitialize the graph
		context->functions.fpReinitializeGraph(theGraph);

		// Do the reinitialization that is specific to this module
		_DrawPlanar_InitStructures(context);
    }
}

/********************************************************************
 The current implementation does not support an increase of arc
 (edge record) capacity once the extension is attached to the graph
 data structure.  This is only due to not being necessary to support.
 For now, it is easy to ensure the correct capacity before attaching
 the extension, but support could be added later if there is some
 reason to do so.
 ********************************************************************/

int  _DrawPlanar_EnsureArcCapacity(graphP theGraph, int requiredArcCapacity)
{
	return NOTOK;
}

/********************************************************************
 ********************************************************************/

int  _DrawPlanar_SortVertices(graphP theGraph)
{
    DrawPlanarContext *context = NULL;
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);

    if (context != NULL)
    {
    	// If this is a planarity-based algorithm to which graph drawing has been attached,
    	// and if the embedding process has already been completed
        if (theGraph->embedFlags == EMBEDFLAGS_DRAWPLANAR)
        {
        	int v, vIndex;
        	DrawPlanar_VertexInfo temp;

            // Relabel the context data members that indicate vertices
            for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
            {
            	if (gp_IsVertex(context->VI[v].ancestor))
            	{
                    context->VI[v].ancestor = gp_GetVertexIndex(theGraph, context->VI[v].ancestor);
                    context->VI[v].ancestorChild = gp_GetVertexIndex(theGraph, context->VI[v].ancestorChild);
            	}
            }

            // "Sort" the extra vertex info associated with each vertex so that it is rearranged according
            // to the index values of the vertices.  This could be done very easily with an extra array in
            // which, for each v, newVI[index of v] = VI[v].  However, this loop avoids memory allocation
            // by performing the operation (almost) in-place, except for the pre-existing visitation flags.
            _ClearVertexVisitedFlags(theGraph, FALSE);
            for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
            {
            	// If the correct data has already been placed into position v
            	// by prior steps, then skip to the next vertex
            	if (gp_GetVertexVisited(theGraph, v))
            		continue;

            	// At the beginning of processing position v, the data in position v
            	// corresponds to data that belongs at the index of v.
            	vIndex = gp_GetVertexIndex(theGraph, v);

            	// Iterate on position v until it receives the correct data
            	while (!gp_GetVertexVisited(theGraph, v))
                {
            		// Place the data at position v into its proper location at position
            		// vIndex, and move vIndex's data into position v.
            		temp = context->VI[v];
            		context->VI[v] = context->VI[vIndex];
            		context->VI[vIndex] = temp;

                    // The data at position vIndex is now marked as being correct.
                    gp_SetVertexVisited(theGraph, vIndex);

                    // The data now in position v is the data from position vIndex,
                    // whose index we now take as the new vIndex
                    vIndex = gp_GetVertexIndex(theGraph, vIndex);
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

int  _DrawPlanar_MergeBicomps(graphP theGraph, int v, int RootVertex, int W, int WPrevLink)
{
    DrawPlanarContext *context = NULL;
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);

    if (context != NULL)
    {
        if (theGraph->embedFlags == EMBEDFLAGS_DRAWPLANAR)
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

        if (theGraph->embedFlags == EMBEDFLAGS_DRAWPLANAR)
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

        if (theGraph->embedFlags == EMBEDFLAGS_DRAWPLANAR)
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

int  _DrawPlanar_CheckEmbeddingIntegrity(graphP theGraph, graphP origGraph)
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

int  _DrawPlanar_CheckObstructionIntegrity(graphP theGraph, graphP origGraph)
{
     return OK;
}

/********************************************************************
 ********************************************************************/

int  _DrawPlanar_ReadPostprocess(graphP theGraph, void *extraData, long extraDataSize)
{
    DrawPlanarContext *context = NULL;
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);

    if (context != NULL)
    {
        if (context->functions.fpReadPostprocess(theGraph, extraData, extraDataSize) != OK)
            return NOTOK;

        else if (extraData != NULL && extraDataSize > 0)
        {
            int v, e, tempInt, EsizeOccupied;
            char line[64], tempChar;

            sprintf(line, "<%s>", DRAWPLANAR_NAME);

            // Find the start of the data for this feature
            extraData = strstr(extraData, line);
            if (extraData == NULL)
                return NOTOK;

            // Advance past the start tag
            extraData = (void *) ((char *) extraData + strlen(line)+1);

            // Read the N lines of vertex information
            for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
            {
                sscanf(extraData, " %d%c %d %d %d", &tempInt, &tempChar,
                              &context->VI[v].pos,
                              &context->VI[v].start,
                              &context->VI[v].end);

                extraData = strchr(extraData, '\n') + 1;
            }

            // Read the lines that contain edge information
            EsizeOccupied = gp_EdgeInUseIndexBound(theGraph);
            for (e = gp_GetFirstEdge(theGraph); e < EsizeOccupied; e++)
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

int  _DrawPlanar_WritePostprocess(graphP theGraph, void **pExtraData, long *pExtraDataSize)
{
    DrawPlanarContext *context = NULL;
    gp_FindExtension(theGraph, DRAWPLANAR_ID, (void *)&context);

    if (context != NULL)
    {
        if (context->functions.fpWritePostprocess(theGraph, pExtraData, pExtraDataSize) != OK)
            return NOTOK;
        else
        {
            int v, e, EsizeOccupied;
            char line[64];
            int maxLineSize = 64, extraDataPos = 0;
            char *extraData = (char *) malloc((1 + theGraph->N + 2*theGraph->M + 1) * maxLineSize * sizeof(char));
            int zeroBasedVertexOffset = (theGraph->internalFlags & FLAGS_ZEROBASEDIO) ? gp_GetFirstVertex(theGraph) : 0;
            int zeroBasedEdgeOffset = (theGraph->internalFlags & FLAGS_ZEROBASEDIO) ? gp_GetFirstEdge(theGraph) : 0;

            if (extraData == NULL)
                return NOTOK;

            // Bit of an unlikely case, but for safety, a bigger maxLineSize
            // and line array size are needed to handle very large graphs
            if (theGraph->N > 2000000000)
            {
                free(extraData);
                return NOTOK;
            }

            sprintf(line, "<%s>\n", DRAWPLANAR_NAME);
            strcpy(extraData+extraDataPos, line);
            extraDataPos += (int) strlen(line);

            for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
            {
                sprintf(line, "%d: %d %d %d\n", v-zeroBasedVertexOffset,
                              context->VI[v].pos,
                              context->VI[v].start,
                              context->VI[v].end);
                strcpy(extraData+extraDataPos, line);
                extraDataPos += (int) strlen(line);
            }

            EsizeOccupied = gp_EdgeInUseIndexBound(theGraph);
            for (e = gp_GetFirstEdge(theGraph); e < EsizeOccupied; e++)
            {
                if (gp_EdgeInUse(theGraph, e))
                {
                    sprintf(line, "%d: %d %d %d\n", e-zeroBasedEdgeOffset,
                                  context->E[e].pos,
                                  context->E[e].start,
                                  context->E[e].end);
                    strcpy(extraData+extraDataPos, line);
                    extraDataPos += (int) strlen(line);
                }
            }

            sprintf(line, "</%s>\n", DRAWPLANAR_NAME);
            strcpy(extraData+extraDataPos, line);
            extraDataPos += (int) strlen(line);

            *pExtraData = (void *) extraData;
            *pExtraDataSize = extraDataPos * sizeof(char);
        }

        return OK;
    }

    return NOTOK;
}
