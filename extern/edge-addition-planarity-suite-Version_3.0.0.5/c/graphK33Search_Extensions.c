/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include <stdlib.h>

#include "graphK33Search.private.h"
#include "graphK33Search.h"

extern int  _SearchForMergeBlocker(graphP theGraph, K33SearchContext *context, int v, int *pMergeBlocker);
extern int  _FindK33WithMergeBlocker(graphP theGraph, K33SearchContext *context, int v, int mergeBlocker);
extern int  _SearchForK33InBicomp(graphP theGraph, K33SearchContext *context, int v, int R);

extern int  _TestForK33GraphObstruction(graphP theGraph, int *degrees, int *imageVerts);
extern int  _getImageVertices(graphP theGraph, int *degrees, int maxDegree,
                              int *imageVerts, int maxNumImageVerts);
extern int  _TestSubgraph(graphP theSubgraph, graphP theGraph);

/* Forward declarations of local functions */

void _K33Search_ClearStructures(K33SearchContext *context);
int  _K33Search_CreateStructures(K33SearchContext *context);
int  _K33Search_InitStructures(K33SearchContext *context);

void _K33Search_InitEdgeRec(K33SearchContext *context, int e);
void _K33Search_InitVertexInfo(K33SearchContext *context, int v);

/* Forward declarations of overloading functions */

int  _K33Search_EmbeddingInitialize(graphP theGraph);
void _CreateBackArcLists(graphP theGraph, K33SearchContext *context);
void _CreateSeparatedDFSChildLists(graphP theGraph, K33SearchContext *context);
void _K33Search_EmbedBackEdgeToDescendant(graphP theGraph, int RootSide, int RootVertex, int W, int WPrevLink);
int  _K33Search_MergeBicomps(graphP theGraph, int v, int RootVertex, int W, int WPrevLink);
void _K33Search_MergeVertex(graphP theGraph, int W, int WPrevLink, int R);
int  _K33Search_HandleBlockedBicomp(graphP theGraph, int v, int RootVertex, int R);
int  _K33Search_EmbedPostprocess(graphP theGraph, int v, int edgeEmbeddingResult);
int  _K33Search_CheckEmbeddingIntegrity(graphP theGraph, graphP origGraph);
int  _K33Search_CheckObstructionIntegrity(graphP theGraph, graphP origGraph);

int  _K33Search_InitGraph(graphP theGraph, int N);
void _K33Search_ReinitializeGraph(graphP theGraph);
int  _K33Search_EnsureArcCapacity(graphP theGraph, int requiredArcCapacity);

/* Forward declarations of functions used by the extension system */

void *_K33Search_DupContext(void *pContext, void *theGraph);
void _K33Search_FreeContext(void *);

/****************************************************************************
 * K33SEARCH_ID - the variable used to hold the integer identifier for this
 * extension, enabling this feature's extension context to be distinguished
 * from other features' extension contexts that may be attached to a graph.
 ****************************************************************************/

int K33SEARCH_ID = 0;

/****************************************************************************
 gp_AttachK33Search()

 This function adjusts the graph data structure to attach the K3,3 search
 feature.
 ****************************************************************************/

int  gp_AttachK33Search(graphP theGraph)
{
     K33SearchContext *context = NULL;

     // If the K3,3 search feature has already been attached to the graph,
     // then there is no need to attach it again
     gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);
     if (context != NULL)
     {
         return OK;
     }

     // Allocate a new extension context
     context = (K33SearchContext *) malloc(sizeof(K33SearchContext));
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

     context->functions.fpEmbeddingInitialize = _K33Search_EmbeddingInitialize;
     context->functions.fpEmbedBackEdgeToDescendant = _K33Search_EmbedBackEdgeToDescendant;
     context->functions.fpMergeBicomps = _K33Search_MergeBicomps;
     context->functions.fpMergeVertex = _K33Search_MergeVertex;
     context->functions.fpHandleBlockedBicomp = _K33Search_HandleBlockedBicomp;
     context->functions.fpEmbedPostprocess = _K33Search_EmbedPostprocess;
     context->functions.fpCheckEmbeddingIntegrity = _K33Search_CheckEmbeddingIntegrity;
     context->functions.fpCheckObstructionIntegrity = _K33Search_CheckObstructionIntegrity;

     context->functions.fpInitGraph = _K33Search_InitGraph;
     context->functions.fpReinitializeGraph = _K33Search_ReinitializeGraph;
     context->functions.fpEnsureArcCapacity = _K33Search_EnsureArcCapacity;

     _K33Search_ClearStructures(context);

     // Store the K33 search context, including the data structure and the
     // function pointers, as an extension of the graph
     if (gp_AddExtension(theGraph, &K33SEARCH_ID, (void *) context,
                         _K33Search_DupContext, _K33Search_FreeContext,
                         &context->functions) != OK)
     {
         _K33Search_FreeContext(context);
         return NOTOK;
     }

     // Create the K33-specific structures if the size of the graph is known
     // Attach functions are always invoked after gp_New(), but if a graph
     // extension must be attached before gp_Read(), then the attachment
     // also happens before gp_InitGraph(), which means N==0.
     // However, sometimes a feature is attached after gp_InitGraph(), in
     // which case N > 0
     if (theGraph->N > 0)
     {
         if (_K33Search_CreateStructures(context) != OK ||
             _K33Search_InitStructures(context) != OK)
         {
             _K33Search_FreeContext(context);
             return NOTOK;
         }
     }

     return OK;
}

/********************************************************************
 gp_DetachK33Search()
 ********************************************************************/

int gp_DetachK33Search(graphP theGraph)
{
    return gp_RemoveExtension(theGraph, K33SEARCH_ID);
}

/********************************************************************
 _K33Search_ClearStructures()
 ********************************************************************/

void _K33Search_ClearStructures(K33SearchContext *context)
{
    if (!context->initialized)
    {
        // Before initialization, the pointers are stray, not NULL
        // Once NULL or allocated, free() or LCFree() can do the job
        context->E = NULL;
        context->VI = NULL;

        context->separatedDFSChildLists = NULL;
        context->buckets = NULL;
        context->bin = NULL;

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

        LCFree(&context->separatedDFSChildLists);
		if (context->buckets != NULL)
		{
			free(context->buckets);
			context->buckets = NULL;
		}
		LCFree(&context->bin);
    }
}

/********************************************************************
 _K33Search_CreateStructures()
 Create uninitialized structures for the vertex and edge
 levels, and initialized structures for the graph level
 ********************************************************************/
int  _K33Search_CreateStructures(K33SearchContext *context)
{
     int VIsize = gp_PrimaryVertexIndexBound(context->theGraph);
     int Esize = gp_EdgeIndexBound(context->theGraph);

     if (context->theGraph->N <= 0)
         return NOTOK;

     if ((context->E = (K33Search_EdgeRecP) malloc(Esize*sizeof(K33Search_EdgeRec))) == NULL ||
         (context->VI = (K33Search_VertexInfoP) malloc(VIsize*sizeof(K33Search_VertexInfo))) == NULL ||
		 (context->separatedDFSChildLists = LCNew(VIsize)) == NULL ||
		 (context->buckets = (int *) malloc(VIsize * sizeof(int))) == NULL ||
		 (context->bin = LCNew(VIsize)) == NULL
        )
     {
         return NOTOK;
     }

     return OK;
}

/********************************************************************
 _K33Search_InitStructures()
 ********************************************************************/
int  _K33Search_InitStructures(K33SearchContext *context)
{
#if NIL == 0 || NIL == -1
	memset(context->VI, NIL_CHAR, gp_PrimaryVertexIndexBound(context->theGraph) * sizeof(K33Search_VertexInfo));
	memset(context->E, NIL_CHAR, gp_EdgeIndexBound(context->theGraph) * sizeof(K33Search_EdgeRec));
#else
	 graphP theGraph = context->theGraph;
     int v, e, Esize;

     if (theGraph->N <= 0)
         return OK;

     for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
          _K33Search_InitVertexInfo(context, v);

     Esize = gp_EdgeIndexBound(theGraph);
     for (e = gp_GetFirstEdge(theGraph); e < Esize; e++)
          _K33Search_InitEdgeRec(context, e);
#endif

     return OK;
}

/********************************************************************
 ********************************************************************/

int  _K33Search_InitGraph(graphP theGraph, int N)
{
    K33SearchContext *context = NULL;
    gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);

    if (context == NULL)
        return NOTOK;

	theGraph->N = N;
	theGraph->NV = N;
	if (theGraph->arcCapacity == 0)
		theGraph->arcCapacity = 2*DEFAULT_EDGE_LIMIT*N;

	if (_K33Search_CreateStructures(context) != OK ||
		_K33Search_InitStructures(context) != OK)
		return NOTOK;

	context->functions.fpInitGraph(theGraph, N);

    return OK;
}

/********************************************************************
 ********************************************************************/

void _K33Search_ReinitializeGraph(graphP theGraph)
{
    K33SearchContext *context = NULL;
    gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);

    if (context != NULL)
    {
		// Reinitialize the graph
		context->functions.fpReinitializeGraph(theGraph);

		// Do the reinitialization that is specific to this module
		_K33Search_InitStructures(context);
		LCReset(context->separatedDFSChildLists);
		LCReset(context->bin);
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

int  _K33Search_EnsureArcCapacity(graphP theGraph, int requiredArcCapacity)
{
	return NOTOK;
}

/********************************************************************
 _K33Search_DupContext()
 ********************************************************************/

void *_K33Search_DupContext(void *pContext, void *theGraph)
{
     K33SearchContext *context = (K33SearchContext *) pContext;
     K33SearchContext *newContext = (K33SearchContext *) malloc(sizeof(K33SearchContext));

     if (newContext != NULL)
     {
         int VIsize = gp_PrimaryVertexIndexBound((graphP) theGraph);
         int Esize = gp_EdgeIndexBound((graphP) theGraph);

         *newContext = *context;

         newContext->theGraph = (graphP) theGraph;

         newContext->initialized = 0;
         _K33Search_ClearStructures(newContext);
         if (((graphP) theGraph)->N > 0)
         {
             if (_K33Search_CreateStructures(newContext) != OK)
             {
                 _K33Search_FreeContext(newContext);
                 return NULL;
             }

             memcpy(newContext->E, context->E, Esize*sizeof(K33Search_EdgeRec));
             memcpy(newContext->VI, context->VI, VIsize*sizeof(K33Search_VertexInfo));
             LCCopy(newContext->separatedDFSChildLists, context->separatedDFSChildLists);
         }
     }

     return newContext;
}

/********************************************************************
 _K33Search_FreeContext()
 ********************************************************************/

void _K33Search_FreeContext(void *pContext)
{
     K33SearchContext *context = (K33SearchContext *) pContext;

     _K33Search_ClearStructures(context);
     free(pContext);
}

/********************************************************************
 _K33Search_EmbeddingInitialize()

 This method overloads the embedding initialization phase of the
 core planarity algorithm to provide post-processing that creates
 the back arcs list and separated DFS child list (sorted by
 lowpoint) for each vertex.
 ********************************************************************/

int  _K33Search_EmbeddingInitialize(graphP theGraph)
{
    K33SearchContext *context = NULL;
    gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);

    if (context != NULL)
    {
    	if (context->functions.fpEmbeddingInitialize(theGraph) != OK)
    		return NOTOK;

        if (theGraph->embedFlags == EMBEDFLAGS_SEARCHFORK33)
        {
        	_CreateBackArcLists(theGraph, context);
        	_CreateSeparatedDFSChildLists(theGraph, context);
        }

        return OK;
    }

    return NOTOK;
}

/********************************************************************
 _CreateBackArcLists()
 ********************************************************************/
void _CreateBackArcLists(graphP theGraph, K33SearchContext *context)
{
	int v, e, eTwin, ancestor;

	for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
    {
    	e = gp_GetVertexFwdArcList(theGraph, v);
        while (gp_IsArc(e))
        {
        	// Get the ancestor endpoint and the associated back arc
        	ancestor = gp_GetNeighbor(theGraph, e);
        	eTwin = gp_GetTwinArc(theGraph, e);

        	// Put it into the back arc list of the ancestor
            if (gp_IsNotArc(context->VI[ancestor].backArcList))
            {
                context->VI[ancestor].backArcList = eTwin;
                gp_SetPrevArc(theGraph, eTwin, eTwin);
                gp_SetNextArc(theGraph, eTwin, eTwin);
            }
            else
            {
            	int eHead = context->VI[ancestor].backArcList;
            	int eTail = gp_GetPrevArc(theGraph, eHead);
        		gp_SetPrevArc(theGraph, eTwin, eTail);
        		gp_SetNextArc(theGraph, eTwin, eHead);
        		gp_SetPrevArc(theGraph, eHead, eTwin);
        		gp_SetNextArc(theGraph, eTail, eTwin);
            }

        	// Advance to the next forward edge
			e = gp_GetNextArc(theGraph, e);
			if (e == gp_GetVertexFwdArcList(theGraph, v))
				e = NIL;
        }
    }
}

/********************************************************************
 _CreateSeparatedDFSChildLists()

 Each vertex gets a list of its DFS children, sorted by lowpoint.
 ********************************************************************/

void _CreateSeparatedDFSChildLists(graphP theGraph, K33SearchContext *context)
{
int *buckets;
listCollectionP bin;
int v, L, DFSParent, theList;

     buckets = context->buckets;
     bin = context->bin;

     // Initialize the bin and all the buckets to be empty
     LCReset(bin);
     for (L = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, L); L++)
          buckets[L] = NIL;

     // For each vertex, add it to the bucket whose index is equal to the lowpoint of the vertex.

     for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
     {
          L = gp_GetVertexLowpoint(theGraph, v);
          buckets[L] = LCAppend(bin, buckets[L], v);
     }

     // For each bucket, add each vertex in the bucket to the separatedDFSChildList of its DFSParent.
     // Since lower numbered buckets are processed before higher numbered buckets, vertices with lower
     // lowpoint values are added before those with higher lowpoint values, so the separatedDFSChildList
     // of each vertex is sorted by lowpoint
     for (L = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, L); L++)
     {
    	  v = buckets[L];

    	  // Loop through all the vertices with lowpoint L, putting each in the list of its parent
		  while (gp_IsVertex(v))
		  {
			  DFSParent = gp_GetVertexParent(theGraph, v);

			  if (gp_IsVertex(DFSParent) && DFSParent != v)
			  {
				  theList = context->VI[DFSParent].separatedDFSChildList;
				  theList = LCAppend(context->separatedDFSChildLists, theList, v);
				  context->VI[DFSParent].separatedDFSChildList = theList;
			  }

			  v = LCGetNext(bin, buckets[L], v);
		  }
     }
}

/********************************************************************
 _K33Search_EmbedBackEdgeToDescendant()

 The forward and back arcs of the cycle edge are embedded by the planarity
 version of this function.
 However, for K_{3,3} subgraph homeomorphism, we also maintain the
 list of unembedded back arcs, so we need to remove the back arc from
 that list since it is now being put back into the adjacency list.
 ********************************************************************/

void _K33Search_EmbedBackEdgeToDescendant(graphP theGraph, int RootSide, int RootVertex, int W, int WPrevLink)
{
    K33SearchContext *context = NULL;
    gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);

    if (context != NULL)
    {
        // K33 search may have been attached, but not enabled
        if (theGraph->embedFlags == EMBEDFLAGS_SEARCHFORK33)
        {
        	// Get the fwdArc from the adjacentTo field, and use it to get the backArc
            int backArc = gp_GetTwinArc(theGraph, gp_GetVertexPertinentEdge(theGraph, W));

            // Remove the backArc from the backArcList
            if (context->VI[W].backArcList == backArc)
            {
                if (gp_GetNextArc(theGraph, backArc) == backArc)
                     context->VI[W].backArcList = NIL;
                else context->VI[W].backArcList = gp_GetNextArc(theGraph, backArc);
            }

            gp_SetNextArc(theGraph, gp_GetPrevArc(theGraph, backArc), gp_GetNextArc(theGraph, backArc));
            gp_SetPrevArc(theGraph, gp_GetNextArc(theGraph, backArc), gp_GetPrevArc(theGraph, backArc));
        }

        // Invoke the superclass version of the function
        context->functions.fpEmbedBackEdgeToDescendant(theGraph, RootSide, RootVertex, W, WPrevLink);
    }
}

/********************************************************************
  This override of _MergeBicomps() detects a special merge block
  that indicates a K3,3 can be found.  The merge blocker is an
  optimization needed for one case for which detecting a K3,3
  could not be done in linear time by direct searching of a
  path of ancestors that is naturally explored eventually by
  the core planarity algorithm.

  Returns OK for a successful merge, NOTOK on an internal failure,
          or NONEMBEDDABLE if the merge was blocked, in which case
          a K_{3,3} homeomorph was isolated.
 ********************************************************************/

int  _K33Search_MergeBicomps(graphP theGraph, int v, int RootVertex, int W, int WPrevLink)
{
    K33SearchContext *context = NULL;
    gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);

    if (context != NULL)
    {
        /* If the merge is blocked, then a K_{3,3} homeomorph is isolated,
           and NONEMBEDDABLE is returned so that the Walkdown terminates */

        if (theGraph->embedFlags == EMBEDFLAGS_SEARCHFORK33)
        {
        int mergeBlocker;

            // We want to test all merge points on the stack
            // as well as W, since the connection will go
            // from W.  So we push W as a 'degenerate' merge point.
            sp_Push2(theGraph->theStack, W, WPrevLink);
            sp_Push2(theGraph->theStack, NIL, NIL);

			if (_SearchForMergeBlocker(theGraph, context, v, &mergeBlocker) != OK)
				return NOTOK;

			if (gp_IsVertex(mergeBlocker))
			{
				if (_FindK33WithMergeBlocker(theGraph, context, v, mergeBlocker) != OK)
					return NOTOK;

				return NONEMBEDDABLE;
			}

            // If no merge blocker was found, then remove W from the stack.
            sp_Pop2(theGraph->theStack, W, WPrevLink);
            sp_Pop2(theGraph->theStack, W, WPrevLink);
        }

        // If the merge was not blocked, then we perform the merge
        // When not doing a K3,3 search, then the merge is not
        // blocked as far as the K3,3 search method is concerned
        // Another algorithms could overload MergeBicomps and block
        // merges under certain conditions, but those would be based
        // on data maintained by the extension that implements the
        // other algorithm-- if *that* algorithm is the one being run
        return context->functions.fpMergeBicomps(theGraph, v, RootVertex, W, WPrevLink);
    }

    return NOTOK;
}

/********************************************************************
 _K33Search_MergeVertex()

 Overload of merge vertex that does basic behavior but also removes
 the DFS child associated with R from the separatedDFSChildList of W.
 ********************************************************************/
void _K33Search_MergeVertex(graphP theGraph, int W, int WPrevLink, int R)
{
    K33SearchContext *context = NULL;
    gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);

    if (context != NULL)
    {
        if (theGraph->embedFlags == EMBEDFLAGS_SEARCHFORK33)
        {
            int theList = context->VI[W].separatedDFSChildList;
            theList = LCDelete(context->separatedDFSChildLists, theList, gp_GetDFSChildFromRoot(theGraph, R));
            context->VI[W].separatedDFSChildList = theList;
        }

        context->functions.fpMergeVertex(theGraph, W, WPrevLink, R);
    }
}

/********************************************************************
 ********************************************************************/

void _K33Search_InitEdgeRec(K33SearchContext *context, int e)
{
    context->E[e].noStraddle = NIL;
    context->E[e].pathConnector = NIL;
}

/********************************************************************
 ********************************************************************/

void _K33Search_InitVertexInfo(K33SearchContext *context, int v)
{
    context->VI[v].separatedDFSChildList = NIL;
    context->VI[v].backArcList = NIL;
    context->VI[v].mergeBlocker = NIL;
}

/********************************************************************
 ********************************************************************/

int  _K33Search_HandleBlockedBicomp(graphP theGraph, int v, int RootVertex, int R)
{
	K33SearchContext *context = NULL;

	gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);
	if (context == NULL)
		return NOTOK;

    if (theGraph->embedFlags == EMBEDFLAGS_SEARCHFORK33)
    {
		// If R is the root of a descendant bicomp of v, we push it, but then we know the search for K3,3
    	// will be successful and return NONEMBEDDABLE because this condition corresponds to minor A, which
    	// is a K3,3.  Thus, an "OK to proceed with Walkdown searching elsewhere" result cannot happen,
    	// so we don't have to test for it to detect if we have to pop these two back off the stack.
    	if (R != RootVertex)
    	    sp_Push2(theGraph->theStack, R, 0);

    	// The possible results here are NONEMBEDDABLE if a K3,3 homeomorph is found, or OK if only
    	// a K5 was found and unblocked such that it is OK for the Walkdown to continue searching
    	// elsewhere.  Note that the OK result can only happen if RootVertex==R since minor E can only
    	// happen on a child bicomp of vertex v, not a descendant bicomp.
    	return _SearchForK33InBicomp(theGraph, context, v, RootVertex);
    }
    else
    {
    	return context->functions.fpHandleBlockedBicomp(theGraph, v, RootVertex, R);
    }

    return NOTOK;
}

/********************************************************************
 ********************************************************************/

int  _K33Search_EmbedPostprocess(graphP theGraph, int v, int edgeEmbeddingResult)
{
     // For K3,3 search, we just return the edge embedding result because the
     // search result has been obtained already.
     if (theGraph->embedFlags == EMBEDFLAGS_SEARCHFORK33)
     {
         return edgeEmbeddingResult;
     }

     // When not searching for K3,3, we let the superclass do the work
     else
     {
        K33SearchContext *context = NULL;
        gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);

        if (context != NULL)
        {
            return context->functions.fpEmbedPostprocess(theGraph, v, edgeEmbeddingResult);
        }
     }

     return NOTOK;
}

/********************************************************************
 ********************************************************************/

int  _K33Search_CheckEmbeddingIntegrity(graphP theGraph, graphP origGraph)
{
     if (theGraph->embedFlags == EMBEDFLAGS_SEARCHFORK33)
     {
         return OK;
     }

     // When not searching for K3,3, we let the superclass do the work
     else
     {
        K33SearchContext *context = NULL;
        gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);

        if (context != NULL)
        {
            return context->functions.fpCheckEmbeddingIntegrity(theGraph, origGraph);
        }
     }

     return NOTOK;
}

/********************************************************************
 ********************************************************************/

int  _K33Search_CheckObstructionIntegrity(graphP theGraph, graphP origGraph)
{
     // When searching for K3,3, we ensure that theGraph is a subgraph of
     // the original graph and that it contains a K3,3 homeomorph
     if (theGraph->embedFlags == EMBEDFLAGS_SEARCHFORK33)
     {
         int  degrees[5], imageVerts[6];

         if (_TestSubgraph(theGraph, origGraph) != TRUE)
         {
             return NOTOK;
         }

         if (_getImageVertices(theGraph, degrees, 4, imageVerts, 6) != OK)
         {
             return NOTOK;
         }

         if (_TestForK33GraphObstruction(theGraph, degrees, imageVerts) == TRUE)
         {
             return OK;
         }

         return NOTOK;
     }

     // When not searching for K3,3, we let the superclass do the work
     else
     {
        K33SearchContext *context = NULL;
        gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);

        if (context != NULL)
        {
            return context->functions.fpCheckObstructionIntegrity(theGraph, origGraph);
        }
     }

     return NOTOK;
}

