/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include <stdlib.h>

#include "graphK4Search.private.h"
#include "graphK4Search.h"

extern int  _SearchForK4InBicomp(graphP theGraph, K4SearchContext *context, int v, int R);

extern int _TestForCompleteGraphObstruction(graphP theGraph, int numVerts,
                                            int *degrees, int *imageVerts);

extern int  _getImageVertices(graphP theGraph, int *degrees, int maxDegree,
                              int *imageVerts, int maxNumImageVerts);

extern int  _TestSubgraph(graphP theSubgraph, graphP theGraph);

/* Forward declarations of local functions */

void _K4Search_ClearStructures(K4SearchContext *context);
int  _K4Search_CreateStructures(K4SearchContext *context);
int  _K4Search_InitStructures(K4SearchContext *context);

void _K4Search_InitEdgeRec(K4SearchContext *context, int e);

/* Forward declarations of overloading functions */
int  _K4Search_HandleBlockedBicomp(graphP theGraph, int v, int RootVertex, int R);
int  _K4Search_EmbedPostprocess(graphP theGraph, int v, int edgeEmbeddingResult);
int  _K4Search_CheckEmbeddingIntegrity(graphP theGraph, graphP origGraph);
int  _K4Search_CheckObstructionIntegrity(graphP theGraph, graphP origGraph);

int  _K4Search_InitGraph(graphP theGraph, int N);
void _K4Search_ReinitializeGraph(graphP theGraph);
int  _K4Search_EnsureArcCapacity(graphP theGraph, int requiredArcCapacity);

/* Forward declarations of functions used by the extension system */

void *_K4Search_DupContext(void *pContext, void *theGraph);
void _K4Search_FreeContext(void *);

/****************************************************************************
 * K4SEARCH_ID - the variable used to hold the integer identifier for this
 * extension, enabling this feature's extension context to be distinguished
 * from other features' extension contexts that may be attached to a graph.
 ****************************************************************************/

int K4SEARCH_ID = 0;

/****************************************************************************
 gp_AttachK4Search()

 This function adjusts the graph data structure to attach the K4 search
 feature.
 ****************************************************************************/

int  gp_AttachK4Search(graphP theGraph)
{
     K4SearchContext *context = NULL;

     // If the K4 search feature has already been attached to the graph,
     // then there is no need to attach it again
     gp_FindExtension(theGraph, K4SEARCH_ID, (void *)&context);
     if (context != NULL)
     {
         return OK;
     }

     // Allocate a new extension context
     context = (K4SearchContext *) malloc(sizeof(K4SearchContext));
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
     context->functions.fpHandleBlockedBicomp = _K4Search_HandleBlockedBicomp;
     context->functions.fpEmbedPostprocess = _K4Search_EmbedPostprocess;
     context->functions.fpCheckEmbeddingIntegrity = _K4Search_CheckEmbeddingIntegrity;
     context->functions.fpCheckObstructionIntegrity = _K4Search_CheckObstructionIntegrity;

     context->functions.fpInitGraph = _K4Search_InitGraph;
     context->functions.fpReinitializeGraph = _K4Search_ReinitializeGraph;
     context->functions.fpEnsureArcCapacity = _K4Search_EnsureArcCapacity;

     _K4Search_ClearStructures(context);

     // Store the K4 search context, including the data structure and the
     // function pointers, as an extension of the graph
     if (gp_AddExtension(theGraph, &K4SEARCH_ID, (void *) context,
                         _K4Search_DupContext, _K4Search_FreeContext,
                         &context->functions) != OK)
     {
         _K4Search_FreeContext(context);
         return NOTOK;
     }

     // Create the K4-specific structures if the size of the graph is known
     // Attach functions are always invoked after gp_New(), but if a graph
     // extension must be attached before gp_Read(), then the attachment
     // also happens before gp_InitGraph(), which means N==0.
     // However, sometimes a feature is attached after gp_InitGraph(), in
     // which case N > 0
     if (theGraph->N > 0)
     {
         if (_K4Search_CreateStructures(context) != OK ||
             _K4Search_InitStructures(context) != OK)
         {
             _K4Search_FreeContext(context);
             return NOTOK;
         }
     }

     return OK;
}

/********************************************************************
 gp_DetachK4Search()
 ********************************************************************/

int gp_DetachK4Search(graphP theGraph)
{
    return gp_RemoveExtension(theGraph, K4SEARCH_ID);
}

/********************************************************************
 _K4Search_ClearStructures()
 ********************************************************************/

void _K4Search_ClearStructures(K4SearchContext *context)
{
    if (!context->initialized)
    {
        // Before initialization, the pointers are stray, not NULL
        // Once NULL or allocated, free() or LCFree() can do the job
        context->E = NULL;

        context->handlingBlockedBicomp = FALSE;

        context->initialized = 1;
    }
    else
    {
        if (context->E != NULL)
        {
            free(context->E);
            context->E = NULL;
        }
        context->handlingBlockedBicomp = FALSE;
    }
}

/********************************************************************
 _K4Search_CreateStructures()
 Create uninitialized structures for the vertex and edge levels, and
 initialized structures for the graph level
 ********************************************************************/
int  _K4Search_CreateStructures(K4SearchContext *context)
{
     int Esize = gp_EdgeIndexBound(context->theGraph);

     if (context->theGraph->N <= 0)
         return NOTOK;

     if ((context->E = (K4Search_EdgeRecP) malloc(Esize*sizeof(K4Search_EdgeRec))) == NULL ||
        0)
     {
         return NOTOK;
     }

     return OK;
}

/********************************************************************
 _K4Search_InitStructures()
 ********************************************************************/
int  _K4Search_InitStructures(K4SearchContext *context)
{
#if NIL == 0 || NIL == -1
	memset(context->E, NIL_CHAR, gp_EdgeIndexBound(context->theGraph) * sizeof(K4Search_EdgeRec));
#else
    int e, Esize;

     Esize = gp_EdgeIndexBound(context->theGraph);
     for (e = gp_GetFirstEdge(context->theGraph); e < Esize; e++)
          _K4Search_InitEdgeRec(context, e);
#endif

     return OK;
}

/********************************************************************
 ********************************************************************/

int  _K4Search_InitGraph(graphP theGraph, int N)
{
    K4SearchContext *context = NULL;
    gp_FindExtension(theGraph, K4SEARCH_ID, (void *)&context);

    if (context == NULL)
        return NOTOK;

    theGraph->N = N;
	theGraph->NV = N;
	if (theGraph->arcCapacity == 0)
		theGraph->arcCapacity = 2*DEFAULT_EDGE_LIMIT*N;

	if (_K4Search_CreateStructures(context) != OK ||
		_K4Search_InitStructures(context) != OK)
		return NOTOK;

	context->functions.fpInitGraph(theGraph, N);

    return OK;
}

/********************************************************************
 ********************************************************************/

void _K4Search_ReinitializeGraph(graphP theGraph)
{
    K4SearchContext *context = NULL;
    gp_FindExtension(theGraph, K4SEARCH_ID, (void *)&context);

    if (context != NULL)
    {
		// Reinitialize the graph
		context->functions.fpReinitializeGraph(theGraph);

		// Do the reinitialization that is specific to this module
		_K4Search_InitStructures(context);
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

int  _K4Search_EnsureArcCapacity(graphP theGraph, int requiredArcCapacity)
{
	return NOTOK;
}

/********************************************************************
 _K4Search_DupContext()
 ********************************************************************/

void *_K4Search_DupContext(void *pContext, void *theGraph)
{
     K4SearchContext *context = (K4SearchContext *) pContext;
     K4SearchContext *newContext = (K4SearchContext *) malloc(sizeof(K4SearchContext));

     if (newContext != NULL)
     {
         int Esize = gp_EdgeIndexBound((graphP) theGraph);

         *newContext = *context;

         newContext->theGraph = (graphP) theGraph;

         newContext->initialized = 0;
         _K4Search_ClearStructures(newContext);
         if (((graphP) theGraph)->N > 0)
         {
             if (_K4Search_CreateStructures(newContext) != OK)
             {
                 _K4Search_FreeContext(newContext);
                 return NULL;
             }

             memcpy(newContext->E, context->E, Esize*sizeof(K4Search_EdgeRec));
         }
     }

     return newContext;
}

/********************************************************************
 _K4Search_FreeContext()
 ********************************************************************/

void _K4Search_FreeContext(void *pContext)
{
     K4SearchContext *context = (K4SearchContext *) pContext;

     _K4Search_ClearStructures(context);
     free(pContext);
}

/********************************************************************
 ********************************************************************/

void _K4Search_InitEdgeRec(K4SearchContext *context, int e)
{
    context->E[e].pathConnector = NIL;
}

/********************************************************************
 _K4Search_HandleBlockedBicomp()
 Returns OK if no K4 homeomorph found and blockage cleared (OK to
 	 	 	 proceed with Walkdown embedding)
 	 	 NONEMBEDDABLE if K4 homeomorph found, and Walkdown embedding
 	 	 	 should be terminated.
 	 	 NOTOK on internal error
 ********************************************************************/

int  _K4Search_HandleBlockedBicomp(graphP theGraph, int v, int RootVertex, int R)
{
	K4SearchContext *context = NULL;

	gp_FindExtension(theGraph, K4SEARCH_ID, (void *)&context);
	if (context == NULL)
		return NOTOK;

    if (theGraph->embedFlags == EMBEDFLAGS_SEARCHFORK4)
    {
    	int RetVal = OK;

    	// If invoked on a descendant bicomp, then we push its root then search once
    	// since not finding a K4 homeomorph will also clear the blockage and allow
    	// the Walkdown to continue walking down
    	if (R != RootVertex)
    	{
    	    sp_Push2(theGraph->theStack, R, 0);
            if ((RetVal = _SearchForK4InBicomp(theGraph, context, v, R)) == OK)
            {
            	// If the Walkdown will be told it is OK to continue, then we have to take the descendant
            	// bicomp root back off the stack so the Walkdown can try to descend to it again.
            	int dummy;
            	sp_Pop2(theGraph->theStack, R, dummy);

            	// And we have to clear the indicator of the minor A that was reduced, since it was eliminated.
            	theGraph->IC.minorType = 0;
            }
    	}

    	// Otherwise, if invoked on a child bicomp rooted by a virtual copy of v,
    	// then we search for a K4 homeomorph, and if OK is returned, then that indicates
    	// the blockage has been cleared and it is OK to Walkdown the bicomp.
    	// But the Walkdown finished, already, so we launch it again.
    	// If the Walkdown returns OK then all forward arcs were embedded.  If NONEMBEDDABLE
    	// is returned, then the bicomp got blocked again, so we have to reiterate the K4 search
    	else
    	{
    		// If Walkdown has recursively called this handler on the bicomp rooted by RootVertex,
    		// then it is still blocked, so we just return NONEMBEDDABLE, which causes Walkdown to
    		// return to the loop below and signal that the loop should invoke the Walkdown again.
    		if (context->handlingBlockedBicomp)
    			return NONEMBEDDABLE;

    		context->handlingBlockedBicomp = TRUE;
    		do {
    			// Detect whether bicomp can be used to find a K4 homeomorph.  It it does, then
    			// it returns NONEMBEDDABLE so we break the search because we found the desired K4
    			// If OK is returned, then the blockage was cleared and it is OK to Walkdown again.
    			if ((RetVal = _SearchForK4InBicomp(theGraph, context, v, RootVertex)) != OK)
    				break;

    			// Walkdown again to embed more edges.  If Walkdown returns OK, then all remaining
    			// edges to its descendants are embedded, so we'll get out of this loop. If Walkdown
    			// detects that it still has not embedded all the edges to descendants of the bicomp's
    			// root edge child, then Walkdown calls this routine again, and the above non-reentrancy
    			// code returns NONEMBEDDABLE, causing this loop to search again for a K4.
    			theGraph->IC.minorType = 0;
    			RetVal = theGraph->functions.fpWalkDown(theGraph, v, RootVertex);

    			// Except if the Walkdown returns NONEMBEDDABLE due to finding a K4 homeomorph entangled
    			// with a descendant bicomp (the R != RootVertex case above), then it was found
    			// entangled with Minor A, so we can stop the search if minor A is detected
    			if (theGraph->IC.minorType & MINORTYPE_A)
    				break;

    		} while (RetVal == NONEMBEDDABLE);
			context->handlingBlockedBicomp = FALSE;
    	}

    	return RetVal;
    }
    else
    {
    	return context->functions.fpHandleBlockedBicomp(theGraph, v, RootVertex, R);
    }

    return NOTOK;
}

/********************************************************************
 ********************************************************************/

int  _K4Search_EmbedPostprocess(graphP theGraph, int v, int edgeEmbeddingResult)
{
     // For K4 search, we just return the edge embedding result because the
     // search result has been obtained already.
     if (theGraph->embedFlags == EMBEDFLAGS_SEARCHFORK4)
     {
         return edgeEmbeddingResult;
     }

     // When not searching for K4, we let the superclass do the work
     else
     {
        K4SearchContext *context = NULL;
        gp_FindExtension(theGraph, K4SEARCH_ID, (void *)&context);

        if (context != NULL)
        {
            return context->functions.fpEmbedPostprocess(theGraph, v, edgeEmbeddingResult);
        }
     }

     return NOTOK;
}

/********************************************************************
 ********************************************************************/

int  _K4Search_CheckEmbeddingIntegrity(graphP theGraph, graphP origGraph)
{
     if (theGraph->embedFlags == EMBEDFLAGS_SEARCHFORK4)
     {
         return OK;
     }

     // When not searching for K4, we let the superclass do the work
     else
     {
        K4SearchContext *context = NULL;
        gp_FindExtension(theGraph, K4SEARCH_ID, (void *)&context);

        if (context != NULL)
        {
            return context->functions.fpCheckEmbeddingIntegrity(theGraph, origGraph);
        }
     }

     return NOTOK;
}

/********************************************************************
 ********************************************************************/

int  _K4Search_CheckObstructionIntegrity(graphP theGraph, graphP origGraph)
{
     // When searching for K4, we ensure that theGraph is a subgraph of
     // the original graph and that it contains a K4 homeomorph
     if (theGraph->embedFlags == EMBEDFLAGS_SEARCHFORK4)
     {
		int  degrees[4], imageVerts[4];

        if (_TestSubgraph(theGraph, origGraph) != TRUE)
            return NOTOK;

		if (_getImageVertices(theGraph, degrees, 3, imageVerts, 4) != OK)
			return NOTOK;

		if (_TestForCompleteGraphObstruction(theGraph, 4, degrees, imageVerts) == TRUE)
		{
			return OK;
		}

		return NOTOK;
     }

     // When not searching for K4, we let the superclass do the work
     else
     {
        K4SearchContext *context = NULL;
        gp_FindExtension(theGraph, K4SEARCH_ID, (void *)&context);

        if (context != NULL)
        {
            return context->functions.fpCheckObstructionIntegrity(theGraph, origGraph);
        }
     }

     return NOTOK;
}
