/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include <stdlib.h>

#include "graphK33Search.h"
#include "graphK33Search.private.h"

// Need to save and restore a graph flag related to IO
#include "../io/graphIO.h"

extern int _SearchForMergeBlocker(graphP theGraph, K33SearchContext *context, int v, int *pMergeBlocker);
extern int _FindK33WithMergeBlocker(graphP theGraph, K33SearchContext *context, int v, int mergeBlocker);
extern int _SearchForK33InBicomp(graphP theGraph, K33SearchContext *context, int v, int R);

extern int _TestForK33GraphObstruction(graphP theGraph, int *degrees, int *imageVerts);
extern int _getImageVertices(graphP theGraph, int *degrees, int maxDegree,
                             int *imageVerts, int maxNumImageVerts);
extern int _TestSubgraph(graphP theSubgraph, graphP theGraph);

/* Forward declarations of local functions */

void _K33Search_ClearStructures(K33SearchContext *context);
int _K33Search_CreateStructures(K33SearchContext *context);
int _K33Search_InitStructures(K33SearchContext *context);

void _K33Search_InitEdgeRec(K33SearchContext *context, int e);
void _K33Search_InitVertexInfo(K33SearchContext *context, int v);

/* Forward declarations of overloading functions */

int _K33Search_EmbeddingInitialize(graphP theGraph);
void _CreateBackEdgeLists(graphP theGraph, K33SearchContext *context);
void _CreateSeparatedDFSChildLists(graphP theGraph, K33SearchContext *context);
void _K33Search_EmbedBackEdgeToDescendant(graphP theGraph, int RootSide, int RootVertex, int W, int WPrevLink);
int _K33Search_MergeBicomps(graphP theGraph, int v, int RootVertex, int W, int WPrevLink);
void _K33Search_MergeVertex(graphP theGraph, int W, int WPrevLink, int R);
int _K33Search_HandleBlockedBicomp(graphP theGraph, int v, int RootVertex, int R);
int _K33Search_EmbedPostprocess(graphP theGraph, int v, int edgeEmbeddingResult);
int _K33Search_CheckEmbeddingIntegrity(graphP theGraph, graphP origGraph);
int _K33Search_CheckObstructionIntegrity(graphP theGraph, graphP origGraph);

int _K33Search_EnsureVertexCapacity(graphP theGraph, int N);
void _K33Search_ResetGraphStorage(graphP theGraph);
int _K33Search_EnsureEdgeCapacity(graphP theGraph, int requiredEdgeCapacity);

/* Forward declarations of functions used by the extension system */

void *_K33Search_DupContext(void *pContext, void *theGraph);
int _K33Search_CopyData(void *dstContext, void *srcContext);
void _K33Search_FreeContext(void *);

/****************************************************************************
 * K33SEARCH_ID - the variable used to hold the integer identifier for this
 * extension, enabling this feature's extension context to be distinguished
 * from other features' extension contexts that may be attached to a graph.
 ****************************************************************************/

int K33SEARCH_ID = 0;

/****************************************************************************
 gp_ExtendWith_K33Search()

 This function adjusts the graph data structure to attach the K3,3 search
 feature.
 ****************************************************************************/

int gp_ExtendWith_K33Search(graphP theGraph)
{
    K33SearchContext *context = NULL;

    if (theGraph == NULL || gp_GetN(theGraph) <= 0)
        return NOTOK;

    // If the K3,3 search feature has already been attached to the graph,
    // then there is no need to attach it again
    gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);
    if (context != NULL)
    {
        return OK;
    }

    // Ensure theGraph is a Planarity Graph
    if (gp_ExtendWith_Planarity(theGraph) != OK)
        return NOTOK;

    // Allocate a new extension context
    context = (K33SearchContext *)malloc(sizeof(K33SearchContext));
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

    context->functions.fpEmbeddingInitialize = _K33Search_EmbeddingInitialize;
    context->functions.fpEmbedBackEdgeToDescendant = _K33Search_EmbedBackEdgeToDescendant;
    context->functions.fpMergeBicomps = _K33Search_MergeBicomps;
    context->functions.fpMergeVertex = _K33Search_MergeVertex;
    context->functions.fpHandleBlockedBicomp = _K33Search_HandleBlockedBicomp;
    context->functions.fpEmbedPostprocess = _K33Search_EmbedPostprocess;
    context->functions.fpCheckEmbeddingIntegrity = _K33Search_CheckEmbeddingIntegrity;
    context->functions.fpCheckObstructionIntegrity = _K33Search_CheckObstructionIntegrity;

    context->functions.fpEnsureVertexCapacity = _K33Search_EnsureVertexCapacity;
    context->functions.fpResetGraphStorage = _K33Search_ResetGraphStorage;
    context->functions.fpEnsureEdgeCapacity = _K33Search_EnsureEdgeCapacity;

    _K33Search_ClearStructures(context);

    // Store the K33 search context, including the data structure and the
    // function pointers, as an extension of the graph
    if (gp_AddExtension(theGraph, &K33SEARCH_ID, (void *)context,
                        _K33Search_DupContext, 
                        _K33Search_CopyData, 
                        _K33Search_FreeContext,
                        &context->functions) != OK)
    {
        _K33Search_FreeContext(context);
        context = NULL;

        return NOTOK;
    }

    // Create the K33-specific structures if the size of the graph is known
    // Attach functions are always invoked after gp_New(), but if a graph
    // extension must be attached before gp_Read(), then the attachment
    // also happens before gp_EnsureVertexCapacity(), which means N==0.
    // However, a feature can be attached after gp_EnsureVertexCapacity(),
    // in which case there is extra work to do when N > 0.
    if (gp_GetN(theGraph) > 0)
    {
        if (_K33Search_CreateStructures(context) != OK ||
            _K33Search_InitStructures(context) != OK)
        {
            _K33Search_FreeContext(context);
            context = NULL;

            return NOTOK;
        }
    }

    return OK;
}

/********************************************************************
 gp_Detach_K33Search()
 ********************************************************************/

int gp_Detach_K33Search(graphP theGraph)
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
int _K33Search_CreateStructures(K33SearchContext *context)
{
    int VIsize = gp_UpperBoundVertices(context->theGraph);
    int Esize = gp_UpperBoundEdgeStorage(context->theGraph);

    if (gp_GetN(context->theGraph) <= 0)
        return NOTOK;

    if ((context->E = (K33Search_EdgeRecP)malloc(Esize * sizeof(K33Search_EdgeRec))) == NULL ||
        (context->VI = (K33Search_VertexInfoP)malloc(VIsize * sizeof(K33Search_VertexInfo))) == NULL ||
        (context->separatedDFSChildLists = LCNew(VIsize)) == NULL ||
        (context->buckets = (int *)malloc(VIsize * sizeof(int))) == NULL ||
        (context->bin = LCNew(VIsize)) == NULL)
    {
        return NOTOK;
    }

    return OK;
}

/********************************************************************
 _K33Search_InitStructures()
 ********************************************************************/
int _K33Search_InitStructures(K33SearchContext *context)
{
    memset(context->VI, NIL_CHAR, gp_UpperBoundVertices(context->theGraph) * sizeof(K33Search_VertexInfo));
    memset(context->E, NIL_CHAR, gp_UpperBoundEdgeStorage(context->theGraph) * sizeof(K33Search_EdgeRec));

    return OK;
}

/********************************************************************
 ********************************************************************/

int _K33Search_EnsureVertexCapacity(graphP theGraph, int N)
{
    K33SearchContext *context = NULL;
    gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);

    if (context == NULL)
    {
        return NOTOK;
    }

    theGraph->N = N;
    theGraph->NV = N;
    if (theGraph->edgeCapacity == 0)
        theGraph->edgeCapacity = DEFAULT_EDGE_CAPACITY_FACTOR * N;

    if (_K33Search_CreateStructures(context) != OK ||
        _K33Search_InitStructures(context) != OK)
        return NOTOK;

    context->functions.fpEnsureVertexCapacity(theGraph, N);

    return OK;
}

/********************************************************************
 ********************************************************************/

void _K33Search_ResetGraphStorage(graphP theGraph)
{
    K33SearchContext *context = NULL;
    gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);

    if (context != NULL)
    {
        // Reset the graph storage in base class(es)
        context->functions.fpResetGraphStorage(theGraph);

        // Do the reset that is specific to this module
        _K33Search_InitStructures(context);
        LCReset(context->separatedDFSChildLists);
        LCReset(context->bin);
    }
}

/********************************************************************
 _K33Search_EnsureEdgeCapacity()
 ********************************************************************/

int _K33Search_EnsureEdgeCapacity(graphP theGraph, int requiredEdgeCapacity)
{
    K33SearchContext *context = NULL;
    K33Search_EdgeRecP oldE = NULL, newE = NULL;
    int oldEsize = gp_UpperBoundEdgeStorage(theGraph), newEsize = 0;

    // If the requirement is already satisfied, then no work to do
    if (gp_GetEdgeCapacity(theGraph) >= requiredEdgeCapacity)
        return OK;

    // Get the graph's extension context so we can work on it
    gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);
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
    newE = (K33Search_EdgeRecP)malloc(newEsize * sizeof(K33Search_EdgeRec));
    if (newE == NULL)
        return NOTOK;

    // Clear all new edge records
    memset(newE, NIL_CHAR, newEsize * sizeof(K33Search_EdgeRec));

    // Copy the old edge records to the new edge records
    memcpy(newE, oldE, oldEsize * sizeof(K33Search_EdgeRec));

    // Set the new edge array into the context and free the old one
    context->E = newE;
    free(oldE);

    return OK;
}

/********************************************************************
 _K33Search_DupContext()
 ********************************************************************/

void *_K33Search_DupContext(void *pContext, void *theGraph)
{
    K33SearchContext *context = (K33SearchContext *)pContext;
    K33SearchContext *newContext = (K33SearchContext *)malloc(sizeof(K33SearchContext));

    if (newContext != NULL)
    {
        int VIsize = gp_UpperBoundVertices((graphP)theGraph);
        int Esize = gp_UpperBoundEdgeStorage((graphP)theGraph);

        *newContext = *context;

        newContext->theGraph = (graphP)theGraph;

        newContext->initialized = 0;
        _K33Search_ClearStructures(newContext);
        if (((graphP)theGraph)->N > 0)
        {
#ifdef INCLUDE_K33SEARCH_EMBEDDER
            if (_K33Search_TestForEOTreeChildren(context->associatedEONode) == TRUE)
            {
                ErrorMessage("_K33Search_DupContext(): Duplicating an embedding obstruction tree is unsupported.\n");
                _K33Search_FreeContext(newContext);
                return NULL;
            }
#endif

            if (_K33Search_CreateStructures(newContext) != OK)
            {
                _K33Search_FreeContext(newContext);
                newContext = NULL;

                return NULL;
            }

            memcpy(newContext->E, context->E, Esize * sizeof(K33Search_EdgeRec));
            memcpy(newContext->VI, context->VI, VIsize * sizeof(K33Search_VertexInfo));
            LCCopy(newContext->separatedDFSChildLists, context->separatedDFSChildLists);
        }
    }

    return newContext;
}

/********************************************************************
 _K33Search_CopyData()
 ********************************************************************/
int _K33Search_CopyData(void *dstContext, void *srcContext)
{
    K33SearchContext *dstK33Context = (K33SearchContext *)dstContext;
    K33SearchContext *srcK33Context = (K33SearchContext *)srcContext;
    int dstEdgeStorage, srcEdgeStorage;

    if (dstContext == NULL)
        return NOTOK;

    // If the srcContext is NULL, then the caller wants the data
    // structures in the dstContext to be reset/reinitialized

    if (srcContext == NULL)
        return _K33Search_InitStructures(dstK33Context);

    // ELSE: If there is also a srcContext, then we copy data from it
    dstEdgeStorage = gp_UpperBoundEdgeStorage(dstK33Context->theGraph);
    srcEdgeStorage = gp_UpperBoundEdgeStorage(srcK33Context->theGraph);

    // The caller (ultimately gp_CopyGraph()) is responsible for making sure that the
    // destination graph has enough edge capacity to receive the source graph content
    if (dstEdgeStorage < srcEdgeStorage)
        return NOTOK;

    // If the destination graph has more edge capacity, then we make sure that the
    // extra edge capacity is reinitialized
    if (dstEdgeStorage > srcEdgeStorage)
    {
        memset(dstK33Context->E, NIL_CHAR, gp_UpperBoundEdgeStorage(dstK33Context->theGraph) * sizeof(K33Search_EdgeRec));
    }

    memcpy(dstK33Context->E, srcK33Context->E, gp_UpperBoundEdgeStorage(dstK33Context->theGraph) * sizeof(K33Search_EdgeRec));

    memcpy(dstK33Context->VI, srcK33Context->VI, gp_UpperBoundVertices(dstK33Context->theGraph) * sizeof(K33Search_VertexInfo));

    return OK;
}

/********************************************************************
 _K33Search_FreeContext()
 ********************************************************************/

void _K33Search_FreeContext(void *pContext)
{
    K33SearchContext *context = (K33SearchContext *)pContext;

    _K33Search_ClearStructures(context);
    free(pContext);
}

/********************************************************************
 _K33Search_EmbeddingInitialize()

 This method overloads the embedding initialization phase of the
 core planarity algorithm to provide post-processing that creates
 the back edges list and separated DFS child list (sorted by
 lowpoint) for each vertex.
 ********************************************************************/

int _K33Search_EmbeddingInitialize(graphP theGraph)
{
    K33SearchContext *context = NULL;
    gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);

    if (context != NULL)
    {
        if (context->functions.fpEmbeddingInitialize(theGraph) != OK)
            return NOTOK;

        if (gp_GetEmbedFlags(theGraph) == EMBEDFLAGS_SEARCHFORK33)
        {
            _CreateBackEdgeLists(theGraph, context);
            _CreateSeparatedDFSChildLists(theGraph, context);
        }

        return OK;
    }

    return NOTOK;
}

/********************************************************************
 _CreateBackEdgeLists()
 ********************************************************************/
void _CreateBackEdgeLists(graphP theGraph, K33SearchContext *context)
{
    int v, e, eTwin, ancestor;

    for (v = gp_LowerBoundVertices(theGraph); v < gp_UpperBoundVertices(theGraph); ++v)
    {
        e = gp_GetVertexFwdEdgeList(theGraph, v);
        while (gp_IsEdge(theGraph, e))
        {
            // Get the ancestor endpoint and the associated back edge record
            ancestor = gp_GetNeighbor(theGraph, e);
            eTwin = gp_GetTwin(theGraph, e);

            // Put it into the back edge list of the ancestor
            if (gp_IsNotEdge(theGraph, context->VI[ancestor].backEdgeList))
            {
                context->VI[ancestor].backEdgeList = eTwin;
                gp_SetPrevEdge(theGraph, eTwin, eTwin);
                gp_SetNextEdge(theGraph, eTwin, eTwin);
            }
            else
            {
                int eHead = context->VI[ancestor].backEdgeList;
                int eTail = gp_GetPrevEdge(theGraph, eHead);
                gp_SetPrevEdge(theGraph, eTwin, eTail);
                gp_SetNextEdge(theGraph, eTwin, eHead);
                gp_SetPrevEdge(theGraph, eHead, eTwin);
                gp_SetNextEdge(theGraph, eTail, eTwin);
            }

            // Advance to the next forward edge record of v (or NIL if done)
            e = gp_GetNextEdge(theGraph, e);
            if (e == gp_GetVertexFwdEdgeList(theGraph, v))
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
    for (L = gp_LowerBoundVertices(theGraph); L < gp_UpperBoundVertices(theGraph); L++)
        buckets[L] = NIL;

    // For each vertex, add it to the bucket whose index is equal to the lowpoint of the vertex.

    for (v = gp_LowerBoundVertices(theGraph); v < gp_UpperBoundVertices(theGraph); ++v)
    {
        L = gp_GetVertexLowpoint(theGraph, v);
        buckets[L] = LCAppend(bin, buckets[L], v);
    }

    // For each bucket, add each vertex in the bucket to the separatedDFSChildList of its DFSParent.
    // Since lower numbered buckets are processed before higher numbered buckets, vertices with lower
    // lowpoint values are added before those with higher lowpoint values, so the separatedDFSChildList
    // of each vertex is sorted by lowpoint
    for (L = gp_LowerBoundVertices(theGraph); L < gp_UpperBoundVertices(theGraph); L++)
    {
        v = buckets[L];

        // Loop through all the vertices with lowpoint L, putting each in the list of its parent
        while (gp_IsVertex(theGraph, v))
        {
            DFSParent = gp_GetVertexParent(theGraph, v);

            if (gp_IsVertex(theGraph, DFSParent) && DFSParent != v)
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

 The forward and back edge records of a back edge (cycle edge, co-tree
 edge, etc.) are embedded by the planarity version of this function.
 For K_{3,3} subgraph homeomorphism, we also maintain the list of
 unembedded back edges, so we need to remove the back edge from
 that list since it is now being put back into the adjacency list.
 ********************************************************************/

void _K33Search_EmbedBackEdgeToDescendant(graphP theGraph, int RootSide, int RootVertex, int W, int WPrevLink)
{
    K33SearchContext *context = NULL;
    gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);

    if (context != NULL)
    {
        // K33 search may have been attached, but not enabled
        if (gp_GetEmbedFlags(theGraph) == EMBEDFLAGS_SEARCHFORK33)
        {
            // Get the forward edge record from the adjacentTo field, and
            // use it to get the back edge record
            int backEdgeRec = gp_GetTwin(theGraph, gp_GetVertexPertinentEdge(theGraph, W));

            // Remove the backEdgeRecfrom the backEdgeList
            if (context->VI[W].backEdgeList == backEdgeRec)
            {
                if (gp_GetNextEdge(theGraph, backEdgeRec) == backEdgeRec)
                    context->VI[W].backEdgeList = NIL;
                else
                    context->VI[W].backEdgeList = gp_GetNextEdge(theGraph, backEdgeRec);
            }

            gp_SetNextEdge(theGraph, gp_GetPrevEdge(theGraph, backEdgeRec), gp_GetNextEdge(theGraph, backEdgeRec));
            gp_SetPrevEdge(theGraph, gp_GetNextEdge(theGraph, backEdgeRec), gp_GetPrevEdge(theGraph, backEdgeRec));
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

int _K33Search_MergeBicomps(graphP theGraph, int v, int RootVertex, int W, int WPrevLink)
{
    K33SearchContext *context = NULL;
    gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);

    if (context != NULL)
    {
        /* If the merge is blocked, then a K_{3,3} homeomorph is isolated,
           and NONEMBEDDABLE is returned so that the Walkdown terminates */

        if (gp_GetEmbedFlags(theGraph) == EMBEDFLAGS_SEARCHFORK33)
        {
            int mergeBlocker;

            // We want to test all merge points on the stack
            // as well as W, since the connection will go
            // from W.  So we push W as a 'degenerate' merge point.
            sp_Push2(theGraph->theStack, W, WPrevLink);
            sp_Push2(theGraph->theStack, NIL, NIL);

            if (_SearchForMergeBlocker(theGraph, context, v, &mergeBlocker) != OK)
                return NOTOK;

            if (gp_IsVertex(theGraph, mergeBlocker))
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
        if (gp_GetEmbedFlags(theGraph) == EMBEDFLAGS_SEARCHFORK33)
        {
            int theList = context->VI[W].separatedDFSChildList;
            theList = LCDelete(context->separatedDFSChildLists, theList, gp_GetDFSChildFromBicompRoot(theGraph, R));
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
    context->VI[v].backEdgeList = NIL;
    context->VI[v].mergeBlocker = NIL;
}

/********************************************************************
 ********************************************************************/

int _K33Search_HandleBlockedBicomp(graphP theGraph, int v, int RootVertex, int R)
{
    K33SearchContext *context = NULL;

    gp_FindExtension(theGraph, K33SEARCH_ID, (void *)&context);
    if (context == NULL)
        return NOTOK;

    if (gp_GetEmbedFlags(theGraph) == EMBEDFLAGS_SEARCHFORK33)
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

    // else if we are not doing a K3,3 homeomorph search, then call the superclass to handle
    return context->functions.fpHandleBlockedBicomp(theGraph, v, RootVertex, R);
}

/********************************************************************
 ********************************************************************/

int _K33Search_EmbedPostprocess(graphP theGraph, int v, int edgeEmbeddingResult)
{
    int savedEmbedFlags = 0, savedZEROBASEDIO = 0;

    // For K3,3 search, we just return the edge embedding result because the
    // search result has been obtained already.
    if (gp_GetEmbedFlags(theGraph) == EMBEDFLAGS_SEARCHFORK33)
    {
        if (edgeEmbeddingResult == OK)
        {
            // When a graph does not contain a K3,3 homeomorph, the embedding
            // is meaningless, so we empty it out. We preserve the embedFlags
            // to ensure post-processing continues as expected.
            savedEmbedFlags = gp_GetEmbedFlags(theGraph);
            savedZEROBASEDIO = gp_GetGraphFlags(theGraph) & GRAPHFLAGS_ZEROBASEDIO;
            gp_ResetGraphStorage(theGraph);
            theGraph->embedFlags = savedEmbedFlags;
            theGraph->graphFlags &= savedZEROBASEDIO;
        }

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

int _K33Search_CheckEmbeddingIntegrity(graphP theGraph, graphP origGraph)
{
    if (gp_GetEmbedFlags(theGraph) == EMBEDFLAGS_SEARCHFORK33)
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

int _K33Search_CheckObstructionIntegrity(graphP theGraph, graphP origGraph)
{
    // When searching for K3,3, we ensure that theGraph is a subgraph of
    // the original graph and that it contains a K3,3 homeomorph
    if (gp_GetEmbedFlags(theGraph) == EMBEDFLAGS_SEARCHFORK33)
    {
        int degrees[5], imageVerts[6];

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
