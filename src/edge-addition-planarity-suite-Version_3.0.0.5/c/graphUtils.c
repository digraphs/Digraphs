/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include <stdlib.h>

#include "graphStructures.h"
#include "graph.h"

/* Imported functions for FUNCTION POINTERS */

extern int  _EmbeddingInitialize(graphP theGraph);
extern int  _SortVertices(graphP theGraph);
extern void _EmbedBackEdgeToDescendant(graphP theGraph, int RootSide, int RootVertex, int W, int WPrevLink);
extern void _WalkUp(graphP theGraph, int v, int e);
extern int  _WalkDown(graphP theGraph, int v, int RootVertex);
extern int  _MergeBicomps(graphP theGraph, int v, int RootVertex, int W, int WPrevLink);
extern void _MergeVertex(graphP theGraph, int W, int WPrevLink, int R);
extern int  _HandleBlockedBicomp(graphP theGraph, int v, int RootVertex, int R);
extern int  _HandleInactiveVertex(graphP theGraph, int BicompRoot, int *pW, int *pWPrevLink);
extern int  _MarkDFSPath(graphP theGraph, int ancestor, int descendant);
extern int  _EmbedPostprocess(graphP theGraph, int v, int edgeEmbeddingResult);
extern int  _CheckEmbeddingIntegrity(graphP theGraph, graphP origGraph);
extern int  _CheckObstructionIntegrity(graphP theGraph, graphP origGraph);
extern int  _ReadPostprocess(graphP theGraph, void *extraData, long extraDataSize);
extern int  _WritePostprocess(graphP theGraph, void **pExtraData, long *pExtraDataSize);

/* Internal util functions for FUNCTION POINTERS */

int  _HideVertex(graphP theGraph, int vertex);
void _HideEdge(graphP theGraph, int arcPos);
void _RestoreEdge(graphP theGraph, int arcPos);
int  _ContractEdge(graphP theGraph, int e);
int  _IdentifyVertices(graphP theGraph, int u, int v, int eBefore);
int  _RestoreVertex(graphP theGraph);

/********************************************************************
 Private functions, except exported within library
 ********************************************************************/

void _InitIsolatorContext(graphP theGraph);
void _ClearVisitedFlags(graphP theGraph);
void _ClearVertexVisitedFlags(graphP theGraph, int);
void _ClearEdgeVisitedFlags(graphP theGraph);
int  _ClearVisitedFlagsInBicomp(graphP theGraph, int BicompRoot);
int  _ClearVisitedFlagsInOtherBicomps(graphP theGraph, int BicompRoot);
void _ClearVisitedFlagsInUnembeddedEdges(graphP theGraph);
int  _FillVertexVisitedInfoInBicomp(graphP theGraph, int BicompRoot, int FillValue);
int  _ClearVertexTypeInBicomp(graphP theGraph, int BicompRoot);

int  _HideInternalEdges(graphP theGraph, int vertex);
int  _RestoreInternalEdges(graphP theGraph, int stackBottom);
int  _RestoreHiddenEdges(graphP theGraph, int stackBottom);

int  _GetBicompSize(graphP theGraph, int BicompRoot);
int  _DeleteUnmarkedEdgesInBicomp(graphP theGraph, int BicompRoot);
int  _ClearInvertedFlagsInBicomp(graphP theGraph, int BicompRoot);

void _InitFunctionTable(graphP theGraph);

/********************************************************************
 Private functions.
 ********************************************************************/

void _InitVertices(graphP theGraph);
void _InitEdges(graphP theGraph);

void _ClearGraph(graphP theGraph);

int  _GetRandomNumber(int NMin, int NMax);

/* Private functions for which there are FUNCTION POINTERS */

void _InitVertexRec(graphP theGraph, int v);
void _InitVertexInfo(graphP theGraph, int v);
void _InitEdgeRec(graphP theGraph, int e);

int  _InitGraph(graphP theGraph, int N);
void _ReinitializeGraph(graphP theGraph);
int  _EnsureArcCapacity(graphP theGraph, int requiredArcCapacity);

/********************************************************************
 gp_New()
 Constructor for graph object.
 Can create two graphs if restricted to no dynamic memory.
 ********************************************************************/

graphP gp_New()
{
graphP theGraph = (graphP) malloc(sizeof(baseGraphStructure));

     if (theGraph != NULL)
     {
         theGraph->E = NULL;
         theGraph->V = NULL;
         theGraph->VI = NULL;

         theGraph->BicompRootLists = NULL;
         theGraph->sortedDFSChildLists = NULL;
         theGraph->theStack = NULL;

         theGraph->extFace = NULL;

         theGraph->edgeHoles = NULL;

         theGraph->extensions = NULL;

         _InitFunctionTable(theGraph);

         _ClearGraph(theGraph);
     }

     return theGraph;
}

/********************************************************************
 _InitFunctionTable()

 If you add functions to the function table, then they must be
 initialized here, but you must also add the new function pointer
 to the definition of the graphFunctionTable in graphFunctionTable.h

 Function headers for the functions used to initialize the table are
 classified at the top of this file as either imported from other
 compilation units (extern) or private to this compilation unit.
 Search for FUNCTION POINTERS in this file to see where to add the
 function header.
 ********************************************************************/

void _InitFunctionTable(graphP theGraph)
{
     theGraph->functions.fpEmbeddingInitialize = _EmbeddingInitialize;
     theGraph->functions.fpEmbedBackEdgeToDescendant = _EmbedBackEdgeToDescendant;
     theGraph->functions.fpWalkUp = _WalkUp;
     theGraph->functions.fpWalkDown = _WalkDown;
     theGraph->functions.fpMergeBicomps = _MergeBicomps;
     theGraph->functions.fpMergeVertex = _MergeVertex;
     theGraph->functions.fpHandleBlockedBicomp = _HandleBlockedBicomp;
     theGraph->functions.fpHandleInactiveVertex = _HandleInactiveVertex;
     theGraph->functions.fpEmbedPostprocess = _EmbedPostprocess;
     theGraph->functions.fpMarkDFSPath = _MarkDFSPath;
     theGraph->functions.fpCheckEmbeddingIntegrity = _CheckEmbeddingIntegrity;
     theGraph->functions.fpCheckObstructionIntegrity = _CheckObstructionIntegrity;

     theGraph->functions.fpInitGraph = _InitGraph;
     theGraph->functions.fpReinitializeGraph = _ReinitializeGraph;
     theGraph->functions.fpEnsureArcCapacity = _EnsureArcCapacity;
     theGraph->functions.fpSortVertices = _SortVertices;

     theGraph->functions.fpReadPostprocess = _ReadPostprocess;
     theGraph->functions.fpWritePostprocess = _WritePostprocess;

     theGraph->functions.fpHideEdge = _HideEdge;
     theGraph->functions.fpRestoreEdge = _RestoreEdge;
     theGraph->functions.fpHideVertex = _HideVertex;
     theGraph->functions.fpRestoreVertex = _RestoreVertex;
     theGraph->functions.fpContractEdge = _ContractEdge;
     theGraph->functions.fpIdentifyVertices = _IdentifyVertices;
}

/********************************************************************
 gp_InitGraph()
 Allocates memory for vertex and edge records now that N is known.
 The arcCapacity is set to (2 * DEFAULT_EDGE_LIMIT * N) unless it
	 has already been set by gp_EnsureArcCapacity()

 For V, we need 2N vertex records, N for vertices and N for virtual vertices (root copies).

 For VI, we need N vertexInfo records.

 For E, we need arcCapacity edge records.

 The BicompRootLists and sortedDFSChildLists are of size N and start out empty.

 The stack, initially empty, is made big enough for a pair of integers
	 per edge record (2 * arcCapacity), or 6N integers if the arcCapacity
	 was set below the default value.

 The edgeHoles stack, initially empty, is set to arcCapacity / 2,
	 which is big enough to push every edge (to indicate an edge
	 you only need to indicate one of its two edge records)

  Returns OK on success, NOTOK on all failures.
          On NOTOK, graph extensions are freed so that the graph is
          returned to the post-condition of gp_New().
 ********************************************************************/

int gp_InitGraph(graphP theGraph, int N)
{
	// valid params check
	if (theGraph == NULL || N <= 0)
        return NOTOK;

	// Should not call init a second time; use reinit
	if (theGraph->N)
		return NOTOK;

    return theGraph->functions.fpInitGraph(theGraph, N);
}

int  _InitGraph(graphP theGraph, int N)
{
	 int  Vsize, VIsize, Esize, stackSize;

	 // Compute the vertex and edge capacities of the graph
     theGraph->N = N;
     theGraph->NV = N;
     theGraph->arcCapacity = theGraph->arcCapacity > 0 ? theGraph->arcCapacity : 2*DEFAULT_EDGE_LIMIT*N;
	 VIsize = gp_PrimaryVertexIndexBound(theGraph);
     Vsize = gp_VertexIndexBound(theGraph);
     Esize = gp_EdgeIndexBound(theGraph);

     // Stack size is 2 integers per arc, or 6 integers per vertex in case of small arcCapacity
     stackSize = 2 * Esize;
     stackSize = stackSize < 6*N ? 6*N : stackSize;

     // Allocate memory as described above
     if ((theGraph->V = (vertexRecP) calloc(Vsize, sizeof(vertexRec))) == NULL ||
    	 (theGraph->VI = (vertexInfoP) calloc(VIsize, sizeof(vertexInfo))) == NULL ||
    	 (theGraph->E = (edgeRecP) calloc(Esize, sizeof(edgeRec))) == NULL ||
         (theGraph->BicompRootLists = LCNew(VIsize)) == NULL ||
         (theGraph->sortedDFSChildLists = LCNew(VIsize)) == NULL ||
         (theGraph->theStack = sp_New(stackSize)) == NULL ||
         (theGraph->extFace = (extFaceLinkRecP) calloc(Vsize, sizeof(extFaceLinkRec))) == NULL ||
         (theGraph->edgeHoles = sp_New(Esize / 2)) == NULL ||
         0)
     {
         _ClearGraph(theGraph);
         return NOTOK;
     }

     // Initialize memory
     _InitVertices(theGraph);
     _InitEdges(theGraph);
     _InitIsolatorContext(theGraph);

     return OK;
}

/********************************************************************
 _InitVertices()
 ********************************************************************/
void _InitVertices(graphP theGraph)
{
#if NIL == 0
	memset(theGraph->V, NIL_CHAR, gp_VertexIndexBound(theGraph) * sizeof(vertexRec));
	memset(theGraph->VI, NIL_CHAR, gp_PrimaryVertexIndexBound(theGraph) * sizeof(vertexInfo));
	memset(theGraph->extFace, NIL_CHAR, gp_VertexIndexBound(theGraph) * sizeof(extFaceLinkRec));
#elif NIL == -1
	int v;

	memset(theGraph->V, NIL_CHAR, gp_VertexIndexBound(theGraph) * sizeof(vertexRec));
	memset(theGraph->VI, NIL_CHAR, gp_PrimaryVertexIndexBound(theGraph) * sizeof(vertexInfo));
	memset(theGraph->extFace, NIL_CHAR, gp_VertexIndexBound(theGraph) * sizeof(extFaceLinkRec));

	for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
	    gp_InitVertexFlags(theGraph, v);

#else
	int v;

    // Initialize primary vertices
	for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
    {
         _InitVertexRec(theGraph, v);
         _InitVertexInfo(theGraph, v);
         gp_SetExtFaceVertex(theGraph, v, 0, NIL);
         gp_SetExtFaceVertex(theGraph, v, 1, NIL);
    }

    // Initialize virtual vertices
	for (v = gp_GetFirstVirtualVertex(theGraph); gp_VirtualVertexInRange(theGraph, v); v++)
    {
         _InitVertexRec(theGraph, v);
         gp_SetExtFaceVertex(theGraph, v, 0, NIL);
         gp_SetExtFaceVertex(theGraph, v, 1, NIL);
    }
#endif
}

/********************************************************************
 _InitEdges()
 ********************************************************************/
void _InitEdges(graphP theGraph)
{
#if NIL == 0
	memset(theGraph->E, NIL_CHAR, gp_EdgeIndexBound(theGraph) * sizeof(edgeRec));
#elif NIL == -1
	int e, Esize;

	memset(theGraph->E, NIL_CHAR, gp_EdgeIndexBound(theGraph) * sizeof(edgeRec));

	Esize = gp_EdgeIndexBound(theGraph);
    for (e = gp_GetFirstEdge(theGraph); e < Esize; e++)
        gp_InitEdgeFlags(theGraph, e);

#else
	int e, Esize;

	Esize = gp_EdgeIndexBound(theGraph);
    for (e = gp_GetFirstEdge(theGraph); e < Esize; e++)
         _InitEdgeRec(theGraph, e);
#endif
}

/********************************************************************
 gp_ReinitializeGraph()
 Reinitializes a graph, restoring it to the state it was in immediately
 after gp_InitGraph() processed it.
 ********************************************************************/

void gp_ReinitializeGraph(graphP theGraph)
{
	if (theGraph == NULL || theGraph->N <= 0)
		return;

    theGraph->functions.fpReinitializeGraph(theGraph);
}

void _ReinitializeGraph(graphP theGraph)
{
     theGraph->M = 0;
     theGraph->internalFlags = theGraph->embedFlags = 0;

     _InitVertices(theGraph);
     _InitEdges(theGraph);
     _InitIsolatorContext(theGraph);

     LCReset(theGraph->BicompRootLists);
     LCReset(theGraph->sortedDFSChildLists);
     sp_ClearStack(theGraph->theStack);
     sp_ClearStack(theGraph->edgeHoles);
}

/********************************************************************
 gp_GetArcCapacity()
 Returns the arcCapacity of theGraph, which is twice the maximum
 number of edges that can be added to the theGraph.
 ********************************************************************/
int gp_GetArcCapacity(graphP theGraph)
{
	return theGraph->arcCapacity - gp_GetFirstEdge(theGraph);
}

/********************************************************************
 gp_EnsureArcCapacity()
 This method ensures that theGraph is or will be capable of storing
 at least requiredArcCapacity edge records.  Two edge records are
 needed per edge.

 This method is most performant when invoked immediately after
 gp_New(), since it must only set the arcCapacity and then let
 normal initialization to occur through gp_InitGraph().

 This method is also a constant time operation if the graph already
 has at least the requiredArcCapacity, since it will return OK
 without making any structural changes.

 This method is generally more performant if it is invoked before
 attaching extensions to the graph.  Some extensions associate
 parallel data with edge records, which is a faster operation if
 the associated data is created and initialized only after the
 proper arcCapacity is specified.

 If the graph has been initialized and has a lower arc capacity,
 then the array of edge records is reallocated to satisfy the
 requiredArcCapacity.  The new array contains the old edges and
 edge holes at the same locations, and all newly created edge records
 are initialized.

 Also, if the arc capacity must be increased, then the
 arcCapacity member of theGraph is changed and both
 theStack and edgeHoles are expanded (since the sizes of both
 are based on the arc capacity).

 Extensions that add to data associated with edges must overload
 this method to ensure capacity in the parallel extension data
 structures.  An extension can return NOTOK if it does not
 support arc capacity expansion.  The extension function will
 not be called if arcCapacity is expanded before the graph is
 initialized, and it is assumed that extensions will allocate
 parallel data structures according to the arc capacity.

 If an extension supports arc capacity expansion, then higher
 performance can be obtained by using the method of unhooking
 the initializers for individual edge records before invoking
 the superclass version of fpEnsureArcCapacity().  Ideally,
 application authors should ensure the proper arc capacity before
 attaching extensions to achieve better performance.

 Returns NOTOK on failure to reallocate the edge record array to
         satisfy the requiredArcCapacity, or if the requested
         capacity is odd
         OK if reallocation is not required or if reallocation succeeds
 ********************************************************************/
int gp_EnsureArcCapacity(graphP theGraph, int requiredArcCapacity)
{
	if (theGraph == NULL || requiredArcCapacity <= 0)
		return NOTOK;

	// Train callers to only ask for an even number of arcs, since
	// two are required per edge or directed edge.
	if (requiredArcCapacity & 1)
		return NOTOK;

    if (theGraph->arcCapacity >= requiredArcCapacity)
    	return OK;

    // In the special case where gp_InitGraph() has not yet been called,
    // we can simply set the higher arcCapacity since normal initialization
    // will then allocate the correct number of edge records.
    if (theGraph->N == 0)
    {
    	theGraph->arcCapacity = requiredArcCapacity;
    	return OK;
    }

    // Try to expand the arc capacity
    return theGraph->functions.fpEnsureArcCapacity(theGraph, requiredArcCapacity);
}

int _EnsureArcCapacity(graphP theGraph, int requiredArcCapacity)
{
stackP newStack;
int e, Esize = gp_EdgeIndexBound(theGraph),
	newEsize = gp_GetFirstEdge(theGraph) + requiredArcCapacity;

	// If the new size is less than or equal to the old size, then
	// the graph already has the required arc capacity
	if (newEsize <= Esize)
		return OK;

    // Expand theStack
    if (sp_GetCapacity(theGraph->theStack) < 2 * requiredArcCapacity)
    {
    	int stackSize = 2 * requiredArcCapacity;

    	if (stackSize < 6*theGraph->N)
    	{
			// NOTE: Since this routine only makes the stack bigger, this
    		//       calculation is not needed here because we already ensured
			//       we had stack capacity of the greater of 2*arcs and 6*N
    		//       But we do it for clarity and consistency (e.g. so this rule
    		//       is not forgotten whenever a "SetArcCapacity" method or a
    		//       "reduceArcCapacity" method is added)
    		stackSize = 6*theGraph->N;
    	}

    	if ((newStack = sp_New(stackSize)) == NULL)
    		return NOTOK;

    	sp_CopyContent(newStack, theGraph->theStack);
    	sp_Free(&theGraph->theStack);
    	theGraph->theStack = newStack;
    }

	// Expand edgeHoles
    if ((newStack = sp_New(requiredArcCapacity / 2)) == NULL)
    	return NOTOK;

	sp_CopyContent(newStack, theGraph->edgeHoles);
    sp_Free(&theGraph->edgeHoles);
    theGraph->edgeHoles = newStack;

	// Reallocate the edgeRec array to the new size,
    theGraph->E = (edgeRecP) realloc(theGraph->E, newEsize*sizeof(edgeRec));
    if (theGraph->E == NULL)
    	return NOTOK;

    // Initialize the new edge records
    for (e = Esize; e < newEsize; e++)
         _InitEdgeRec(theGraph, e);

    // The new arcCapacity has been successfully achieved
	theGraph->arcCapacity = requiredArcCapacity;
	return OK;
}

/********************************************************************
 _InitVertexRec()
 Sets the fields in a single vertex record to initial values
 ********************************************************************/

void _InitVertexRec(graphP theGraph, int v)
{
    gp_SetFirstArc(theGraph, v, NIL);
    gp_SetLastArc(theGraph, v, NIL);
    gp_SetVertexIndex(theGraph, v, NIL);
    gp_InitVertexFlags(theGraph, v);
}

/********************************************************************
 _InitVertexInfo()
 Sets the fields in a single vertex record to initial values
 ********************************************************************/

void _InitVertexInfo(graphP theGraph, int v)
{
    gp_SetVertexParent(theGraph, v, NIL);
    gp_SetVertexLeastAncestor(theGraph, v, NIL);
    gp_SetVertexLowpoint(theGraph, v, NIL);

    gp_SetVertexVisitedInfo(theGraph, v, NIL);
    gp_SetVertexPertinentEdge(theGraph, v, NIL);
    gp_SetVertexPertinentRootsList(theGraph, v, NIL);
    gp_SetVertexFuturePertinentChild(theGraph, v, NIL);
    gp_SetVertexSortedDFSChildList(theGraph, v, NIL);
    gp_SetVertexFwdArcList(theGraph, v, NIL);
}

/********************************************************************
 _InitEdgeRec()
 Sets the fields in a single edge record structure to initial values
 ********************************************************************/

void _InitEdgeRec(graphP theGraph, int e)
{
     gp_SetNeighbor(theGraph, e, NIL);
     gp_SetPrevArc(theGraph, e, NIL);
     gp_SetNextArc(theGraph, e, NIL);
     gp_InitEdgeFlags(theGraph, e);
}

/********************************************************************
 _InitIsolatorContext()
 ********************************************************************/

void _InitIsolatorContext(graphP theGraph)
{
isolatorContextP IC = &theGraph->IC;

     IC->minorType = 0;
     IC->v = IC->r = IC->x = IC->y = IC->w = IC->px = IC->py = IC->z =
     IC->ux = IC->dx = IC->uy = IC->dy = IC->dw = IC->uz = IC->dz = NIL;
}

/********************************************************************
 _ClearVisitedFlags()
 ********************************************************************/

void _ClearVisitedFlags(graphP theGraph)
{
	 _ClearVertexVisitedFlags(theGraph, TRUE);
	 _ClearEdgeVisitedFlags(theGraph);
}

/********************************************************************
 _ClearVertexVisitedFlags()
 ********************************************************************/

void _ClearVertexVisitedFlags(graphP theGraph, int includeVirtualVertices)
{
	int  v;

	for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
        gp_ClearVertexVisited(theGraph, v);

	if (includeVirtualVertices)
		for (v = gp_GetFirstVirtualVertex(theGraph); gp_VirtualVertexInRange(theGraph, v); v++)
	        gp_ClearVertexVisited(theGraph, v);
}

/********************************************************************
 _ClearEdgeVisitedFlags()
 ********************************************************************/

void _ClearEdgeVisitedFlags(graphP theGraph)
{
	 int  e, EsizeOccupied;

	 EsizeOccupied = gp_EdgeInUseIndexBound(theGraph);
     for (e = gp_GetFirstEdge(theGraph); e < EsizeOccupied; e++)
    	 gp_ClearEdgeVisited(theGraph, e);
}

/********************************************************************
 _ClearVisitedFlagsInBicomp()

 Clears the visited flag of the vertices and arcs in the bicomp rooted
 by BicompRoot.

 This method uses the stack but preserves whatever may have been
 on it.  In debug mode, it will return NOTOK if the stack overflows.
 This method pushes at most one integer per vertex in the bicomp.

 Returns OK on success, NOTOK on implementation failure.
 ********************************************************************/

int  _ClearVisitedFlagsInBicomp(graphP theGraph, int BicompRoot)
{
int  stackBottom = sp_GetCurrentSize(theGraph->theStack);
int  v, e;

     sp_Push(theGraph->theStack, BicompRoot);
     while (sp_GetCurrentSize(theGraph->theStack) > stackBottom)
     {
          sp_Pop(theGraph->theStack, v);
          gp_ClearVertexVisited(theGraph, v);

          e = gp_GetFirstArc(theGraph, v);
          while (gp_IsArc(e))
          {
             gp_ClearEdgeVisited(theGraph, e);

             if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_CHILD)
                 sp_Push(theGraph->theStack, gp_GetNeighbor(theGraph, e));

             e = gp_GetNextArc(theGraph, e);
          }
     }
     return OK;
}

/********************************************************************
 _ClearVisitedFlagsInOtherBicomps()
 Typically, we want to clear all visited flags in the graph
 (see _ClearVisitedFlags).  However, in some algorithms this would be
 too costly, so it is necessary to clear the visited flags only
 in one bicomp (see _ClearVisitedFlagsInBicomp), then do some processing
 that sets some of the flags then performs some tests.  If the tests
 are positive, then we can clear all the visited flags in the
 other bicomps (the processing may have set the visited flags in the
 one bicomp in a particular way that we want to retain, so we skip
 the given bicomp).
 ********************************************************************/

int  _ClearVisitedFlagsInOtherBicomps(graphP theGraph, int BicompRoot)
{
	 int  R;

	 for (R = gp_GetFirstVirtualVertex(theGraph); gp_VirtualVertexInRange(theGraph, R); R++)
     {
          if (R != BicompRoot && gp_VirtualVertexInUse(theGraph, R))
          {
              if (_ClearVisitedFlagsInBicomp(theGraph, R) != OK)
            	  return NOTOK;
          }
     }
     return OK;
}

/********************************************************************
 _ClearVisitedFlagsInUnembeddedEdges()
 Unembedded edges aren't part of any bicomp yet, but it may be
 necessary to clear their visited flags.
 ********************************************************************/

void _ClearVisitedFlagsInUnembeddedEdges(graphP theGraph)
{
	int v, e;

	for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
    {
        e = gp_GetVertexFwdArcList(theGraph, v);
        while (gp_IsArc(e))
        {
            gp_ClearEdgeVisited(theGraph, e);
            gp_ClearEdgeVisited(theGraph, gp_GetTwinArc(theGraph, e));

            e = gp_GetNextArc(theGraph, e);
            if (e == gp_GetVertexFwdArcList(theGraph, v))
                e = NIL;
        }
    }
}

/****************************************************************************
 _ClearVisitedFlagsOnPath()
 This method clears the visited flags on the vertices and edges on the path
 (u, v, ..., w, x) in which all vertices except the endpoints u and x
 are degree 2.  This method avoids performing more than constant work at the
 path endpoints u and x, so the total work is on the order of the path length.

 Returns OK on success, NOTOK on internal failure
 ****************************************************************************/

int  _ClearVisitedFlagsOnPath(graphP theGraph, int u, int v, int w, int x)
{
	 int  e, eTwin;

     // We want to exit u from e, but we get eTwin first here in order to avoid
     // work, in case the degree of u is greater than 2.
     eTwin = gp_GetNeighborEdgeRecord(theGraph, v, u);
     if (gp_IsNotArc(eTwin))
    	 return NOTOK;
     e = gp_GetTwinArc(theGraph, eTwin);

     v = u;

     do {
    	 // Mark the vertex and the exiting edge
         gp_ClearVertexVisited(theGraph, v);
         gp_ClearEdgeVisited(theGraph, e);
         gp_ClearEdgeVisited(theGraph, eTwin);

    	 // Get the next vertex
         v = gp_GetNeighbor(theGraph, e);
         e = gp_GetNextArcCircular(theGraph, eTwin);
         eTwin = gp_GetTwinArc(theGraph, e);
     } while (v != x);

     // Mark the last vertex with 'visited'
     gp_ClearVertexVisited(theGraph, x);

     return OK;
}

/****************************************************************************
 _SetVisitedFlagsOnPath()
 This method sets the visited flags on the vertices and edges on the path
 (u, v, ..., w, x) in which all vertices except the endpoints u and x
 are degree 2.  This method avoids performing more than constant work at the
 path endpoints u and x, so the total work is on the order of the path length.

 Returns OK on success, NOTOK on internal failure
 ****************************************************************************/

int  _SetVisitedFlagsOnPath(graphP theGraph, int u, int v, int w, int x)
{
	 int  e, eTwin;

     // We want to exit u from e, but we get eTwin first here in order to avoid
     // work, in case the degree of u is greater than 2.
     eTwin = gp_GetNeighborEdgeRecord(theGraph, v, u);
     if (gp_IsNotArc(eTwin))
    	 return NOTOK;
     e = gp_GetTwinArc(theGraph, eTwin);

     v = u;

     do {
    	 // Mark the vertex and the exiting edge
         gp_SetVertexVisited(theGraph, v);
         gp_SetEdgeVisited(theGraph, e);
         gp_SetEdgeVisited(theGraph, eTwin);

    	 // Get the next vertex
         v = gp_GetNeighbor(theGraph, e);
         e = gp_GetNextArcCircular(theGraph, eTwin);
         eTwin = gp_GetTwinArc(theGraph, e);
     } while (v != x);

     // Mark the last vertex with 'visited'
     gp_SetVertexVisited(theGraph, x);

     return OK;
}

/********************************************************************
 _FillVertexVisitedInfoInBicomp()

 Places the FillValue into the visitedInfo of the non-virtual vertices
 in the bicomp rooted by BicompRoot.

 This method uses the stack but preserves whatever may have been
 on it.  In debug mode, it will return NOTOK if the stack overflows.
 This method pushes at most one integer per vertex in the bicomp.

 Returns OK on success, NOTOK on implementation failure.
 ********************************************************************/

int  _FillVertexVisitedInfoInBicomp(graphP theGraph, int BicompRoot, int FillValue)
{
int  v, e;
int  stackBottom = sp_GetCurrentSize(theGraph->theStack);

     sp_Push(theGraph->theStack, BicompRoot);
     while (sp_GetCurrentSize(theGraph->theStack) > stackBottom)
     {
          sp_Pop(theGraph->theStack, v);

          if (gp_IsNotVirtualVertex(theGraph, v))
        	  gp_SetVertexVisitedInfo(theGraph, v, FillValue);

          e = gp_GetFirstArc(theGraph, v);
          while (gp_IsArc(e))
          {
             if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_CHILD)
                 sp_Push(theGraph->theStack, gp_GetNeighbor(theGraph, e));

             e = gp_GetNextArc(theGraph, e);
          }
     }
     return OK;
}

/********************************************************************
 _ClearVertexTypeInBicomp()

 Clears the 'obstruction type' bits for each vertex in the bicomp
 rooted by BicompRoot.

 This method uses the stack but preserves whatever may have been
 on it.  In debug mode, it will return NOTOK if the stack overflows.
 This method pushes at most one integer per vertex in the bicomp.

 Returns OK on success, NOTOK on implementation failure.
 ********************************************************************/

int  _ClearVertexTypeInBicomp(graphP theGraph, int BicompRoot)
{
int  V, e;
int  stackBottom = sp_GetCurrentSize(theGraph->theStack);

     sp_Push(theGraph->theStack, BicompRoot);
     while (sp_GetCurrentSize(theGraph->theStack) > stackBottom)
     {
          sp_Pop(theGraph->theStack, V);
          gp_ClearVertexObstructionType(theGraph, V);

          e = gp_GetFirstArc(theGraph, V);
          while (gp_IsArc(e))
          {
             if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_CHILD)
                 sp_Push(theGraph->theStack, gp_GetNeighbor(theGraph, e));

             e = gp_GetNextArc(theGraph, e);
          }
     }
     return OK;
}

/********************************************************************
 _ClearGraph()
 Clears all memory used by the graph, restoring it to the state it
 was in immediately after gp_New() created it.
 ********************************************************************/

void _ClearGraph(graphP theGraph)
{
     if (theGraph->V != NULL)
     {
          free(theGraph->V);
          theGraph->V = NULL;
     }
     if (theGraph->VI != NULL)
     {
          free(theGraph->VI);
          theGraph->V = NULL;
     }
     if (theGraph->E != NULL)
     {
          free(theGraph->E);
          theGraph->E = NULL;
     }

     theGraph->N = 0;
     theGraph->NV = 0;
     theGraph->M = 0;
     theGraph->arcCapacity = 0;
     theGraph->internalFlags = 0;
     theGraph->embedFlags = 0;

     _InitIsolatorContext(theGraph);

     LCFree(&theGraph->BicompRootLists);
     LCFree(&theGraph->sortedDFSChildLists);

     sp_Free(&theGraph->theStack);

     if (theGraph->extFace != NULL)
     {
         free(theGraph->extFace);
         theGraph->extFace = NULL;
     }

     sp_Free(&theGraph->edgeHoles);

     gp_FreeExtensions(theGraph);
}

/********************************************************************
 gp_Free()
 Frees G and V, then the graph record.  Then sets your pointer to NULL
 (so you must pass the address of your pointer).
 ********************************************************************/

void gp_Free(graphP *pGraph)
{
     if (pGraph == NULL) return;
     if (*pGraph == NULL) return;

     _ClearGraph(*pGraph);

     free(*pGraph);
     *pGraph = NULL;
}

/********************************************************************
 gp_CopyAdjacencyLists()
 Copies the adjacency lists from the srcGraph to the dstGraph.
 This method intentionally copies only the adjacency lists of the
 first N vertices, so the adjacency lists of virtual vertices are
 excluded (unless the caller temporarily resets the value of N to
 include NV).

 Returns OK on success, NOTOK on failures, e.g. if the two graphs
 have different orders N or if the arcCapacity of dstGraph cannot
 be increased to match that of srcGraph.
 ********************************************************************/
int  gp_CopyAdjacencyLists(graphP dstGraph, graphP srcGraph)
{
	int v, e, EsizeOccupied;

	if (dstGraph == NULL || srcGraph == NULL)
		return NOTOK;

	if (dstGraph->N != srcGraph->N || dstGraph->N == 0)
		return NOTOK;

    if (gp_EnsureArcCapacity(dstGraph, srcGraph->arcCapacity) != OK)
    	return NOTOK;

	// Copy the links that hook each owning vertex to its adjacency list
    for (v = gp_GetFirstVertex(srcGraph); gp_VertexInRange(srcGraph, v); v++)
	{
		gp_SetFirstArc(dstGraph, v, gp_GetFirstArc(srcGraph, v));
		gp_SetLastArc(dstGraph, v, gp_GetLastArc(srcGraph, v));
	}

	// Copy the adjacency links and neighbor pointers for each arc
	EsizeOccupied = gp_EdgeInUseIndexBound(srcGraph);
	for (e = gp_GetFirstEdge(theGraph); e < EsizeOccupied; e++)
	{
		gp_SetNeighbor(dstGraph, e, gp_GetNeighbor(srcGraph, e));
		gp_SetNextArc(dstGraph, e, gp_GetNextArc(srcGraph, e));
		gp_SetPrevArc(dstGraph, e, gp_GetPrevArc(srcGraph, e));
	}

	// Tell the dstGraph how many edges it now has and where the edge holes are
	dstGraph->M = srcGraph->M;
    sp_Copy(dstGraph->edgeHoles, srcGraph->edgeHoles);

	return OK;
}

/********************************************************************
 gp_CopyGraph()
 Copies the content of the srcGraph into the dstGraph.  The dstGraph
 must have been previously initialized with the same number of
 vertices as the srcGraph (e.g. gp_InitGraph(dstGraph, srcGraph->N).

 Returns OK for success, NOTOK for failure.
 ********************************************************************/

int  gp_CopyGraph(graphP dstGraph, graphP srcGraph)
{
int  v, e, Esize;

     // Parameter checks
     if (dstGraph == NULL || srcGraph == NULL)
     {
         return NOTOK;
     }

     // The graphs need to be the same order and initialized
     if (dstGraph->N != srcGraph->N || dstGraph->N == 0)
     {
         return NOTOK;
     }

     // Ensure dstGraph has the required arc capacity; this expands
     // dstGraph if needed, but does not contract.  An error is only
     // returned if the expansion fails.
     if (gp_EnsureArcCapacity(dstGraph, srcGraph->arcCapacity) != OK)
     {
    	 return NOTOK;
     }

     // Copy the primary vertices.  Augmentations to vertices created
     // by extensions are copied below by gp_CopyExtensions()
     for (v = gp_GetFirstVertex(srcGraph); gp_VertexInRange(srcGraph, v); v++)
     {
    	 gp_CopyVertexRec(dstGraph, v, srcGraph, v);
    	 gp_CopyVertexInfo(dstGraph, v, srcGraph, v);
    	 gp_SetExtFaceVertex(dstGraph, v, 0, gp_GetExtFaceVertex(srcGraph, v, 0));
    	 gp_SetExtFaceVertex(dstGraph, v, 1, gp_GetExtFaceVertex(srcGraph, v, 1));
     }

     // Copy the virtual vertices.  Augmentations to virtual vertices created
     // by extensions are copied below by gp_CopyExtensions()
     for (v = gp_GetFirstVirtualVertex(srcGraph); gp_VirtualVertexInRange(srcGraph, v); v++)
     {
    	 gp_CopyVertexRec(dstGraph, v, srcGraph, v);
    	 gp_SetExtFaceVertex(dstGraph, v, 0, gp_GetExtFaceVertex(srcGraph, v, 0));
    	 gp_SetExtFaceVertex(dstGraph, v, 1, gp_GetExtFaceVertex(srcGraph, v, 1));
     }

     // Copy the basic EdgeRec structures.  Augmentations to the edgeRec structure
     // created by extensions are copied below by gp_CopyExtensions()
     Esize = gp_EdgeIndexBound(srcGraph);
     for (e = gp_GetFirstEdge(theGraph); e < Esize; e++)
    	 gp_CopyEdgeRec(dstGraph, e, srcGraph, e);

     // Give the dstGraph the same size and intrinsic properties
     dstGraph->N = srcGraph->N;
     dstGraph->NV = srcGraph->NV;
     dstGraph->M = srcGraph->M;
     dstGraph->internalFlags = srcGraph->internalFlags;
     dstGraph->embedFlags = srcGraph->embedFlags;

     dstGraph->IC = srcGraph->IC;

     LCCopy(dstGraph->BicompRootLists, srcGraph->BicompRootLists);
     LCCopy(dstGraph->sortedDFSChildLists, srcGraph->sortedDFSChildLists);
     sp_Copy(dstGraph->theStack, srcGraph->theStack);
     sp_Copy(dstGraph->edgeHoles, srcGraph->edgeHoles);

     // Copy the set of extensions, which includes copying the
     // extension data as well as the function overload tables
     if (gp_CopyExtensions(dstGraph, srcGraph) != OK)
    	 return NOTOK;

     // Copy the graph's function table, which has the pointers to
     // the most recent extension overloads of each function (or
     // the original function pointer if a particular function has
     // not been overloaded).
     // This must be done after copying the extension because the
     // first step of copying the extensions is to delete the
     // dstGraph extensions, which clears its function table.
     // Therefore, no good to assign the srcGraph functions *before*
     // copying the extensions because the assignment would be wiped out
     // This, in turn, means that the DupContext function of an extension
     // *cannot* depend on any extension function overloads; the extension
     // must directly invoke extension functions only.
     dstGraph->functions = srcGraph->functions;

     return OK;
}

/********************************************************************
 gp_DupGraph()
 ********************************************************************/

graphP gp_DupGraph(graphP theGraph)
{
graphP result;

     if ((result = gp_New()) == NULL) return NULL;

     if (gp_InitGraph(result, theGraph->N) != OK ||
         gp_CopyGraph(result, theGraph) != OK)
     {
         gp_Free(&result);
         return NULL;
     }

     return result;
}

/********************************************************************
 gp_CreateRandomGraph()

 Creates a randomly generated graph.  First a tree is created by
 connecting each vertex to some successor.  Then a random number of
 additional random edges are added.  If an edge already exists, then
 we retry until a non-existent edge is picked.

 This function assumes the caller has already called srand().

 Returns OK on success, NOTOK on failure
 ********************************************************************/

int  gp_CreateRandomGraph(graphP theGraph)
{
int N, M, u, v, m;

     N = theGraph->N;

/* Generate a random tree; note that this method virtually guarantees
        that the graph will be renumbered, but it is linear time.
        Also, we are not generating the DFS tree but rather a tree
        that simply ensures the resulting random graph is connected. */

 	for (v = gp_GetFirstVertex(theGraph)+1; gp_VertexInRange(theGraph, v); v++)
 	{
 		 u = _GetRandomNumber(gp_GetFirstVertex(theGraph), v-1);
         if (gp_AddEdge(theGraph, u, 0, v, 0) != OK)
             return NOTOK;
 	}

/* Generate a random number of additional edges
        (actually, leave open a small chance that no
        additional edges will be added). */

     M = _GetRandomNumber(7*N/8, theGraph->arcCapacity/2);

     if (M > N*(N-1)/2)
    	 M = N*(N-1)/2;

     for (m = N-1; m < M; m++)
     {
          u = _GetRandomNumber(gp_GetFirstVertex(theGraph), gp_GetLastVertex(theGraph)-1);
          v = _GetRandomNumber(u+1, gp_GetLastVertex(theGraph));

          // If the edge (u,v) exists, decrement eIndex to try again
          if (gp_IsNeighbor(theGraph, u, v))
        	  m--;

          // If the edge (u,v) doesn't exist, add it
          else
          {
              if (gp_AddEdge(theGraph, u, 0, v, 0) != OK)
                  return NOTOK;
          }
     }

     return OK;
}

/********************************************************************
 _GetRandomNumber()
 This function generates a random number between NMin and NMax
 inclusive.  It assumes that the caller has called srand().
 It calls rand(), but before truncating to the proper range,
 it adds the high bits of the rand() result into the low bits.
 The result of this is that the randomness appearing in the
 truncated bits also has an affect on the non-truncated bits.
 ********************************************************************/

int  _GetRandomNumber(int NMin, int NMax)
{
int  N = rand();

     if (NMax < NMin) return NMin;

     N += ((N&0xFFFF0000)>>16);
     N += ((N&0x0000FF00)>>8);
     N &= 0x7FFFFFF;
     N %= (NMax-NMin+1);
     return N+NMin;
}

/********************************************************************
 _getUnprocessedChild()
 Support routine for gp_Create RandomGraphEx(), this function
 obtains a child of the given vertex in the randomly generated
 tree that has not yet been processed.  NIL is returned if the
 given vertex has no unprocessed children

 ********************************************************************/

int _getUnprocessedChild(graphP theGraph, int parent)
{
int e = gp_GetFirstArc(theGraph, parent);
int eTwin = gp_GetTwinArc(theGraph, e);
int child = gp_GetNeighbor(theGraph, e);

    // The tree edges were added to the beginning of the adjacency list,
    // and we move processed tree edge records to the end of the list,
    // so if the immediate next arc (edge record) is not a tree edge
    // then we return NIL because the vertex has no remaining
    // unprocessed children
    if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_NOTDEFINED)
        return NIL;

    // If the child has already been processed, then all children
    // have been pushed to the end of the list, and we have just
    // encountered the first child we processed, so there are no
    // remaining unprocessed children */
    if (gp_GetEdgeVisited(theGraph, e))
        return NIL;

    // We have found an edge leading to an unprocessed child, so
    // we mark it as processed so that it doesn't get returned
    // again in future iterations.
    gp_SetEdgeVisited(theGraph, e);
    gp_SetEdgeVisited(theGraph, eTwin);

    // Now we move the edge record in the parent vertex to the end
    // of the adjacency list of that vertex.
    gp_MoveArcToLast(theGraph, parent, e);

    // Now we move the edge record in the child vertex to the
    // end of the adjacency list of the child.
    gp_MoveArcToLast(theGraph, child, eTwin);

    // Now we set the child's parent and return the child.
    gp_SetVertexParent(theGraph, child, parent);

    return child;
}

/********************************************************************
 _hasUnprocessedChild()
 Support routine for gp_Create RandomGraphEx(), this function
 obtains a child of the given vertex in the randomly generated
 tree that has not yet been processed.  False (0) is returned
 unless the given vertex has an unprocessed child.
 ********************************************************************/

int _hasUnprocessedChild(graphP theGraph, int parent)
{
int e = gp_GetFirstArc(theGraph, parent);

    if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_NOTDEFINED)
        return 0;

    if (gp_GetEdgeVisited(theGraph, e))
        return 0;

    return 1;
}

/********************************************************************
 gp_CreateRandomGraphEx()
 Given a graph structure with a pre-specified number of vertices N,
 this function creates a graph with the specified number of edges.

 If numEdges <= 3N-6, then the graph generated is planar.  If
 numEdges is larger, then a maximal planar graph is generated, then
 (numEdges - 3N + 6) additional random edges are added.

 This function assumes the caller has already called srand().
 ********************************************************************/

int  gp_CreateRandomGraphEx(graphP theGraph, int numEdges)
{
int N, arc, M, root, v, c, p, last, u, e, EsizeOccupied;

     N = theGraph->N;

     if (numEdges > theGraph->arcCapacity/2)
         numEdges = theGraph->arcCapacity/2;

/* Generate a random tree. */

 	for (v = gp_GetFirstVertex(theGraph)+1; gp_VertexInRange(theGraph, v); v++)
    {
        u = _GetRandomNumber(gp_GetFirstVertex(theGraph), v-1);
        if (gp_AddEdge(theGraph, u, 0, v, 0) != OK)
            return NOTOK;

        else
	    {
            arc = 2*theGraph->M - 2;
            gp_SetEdgeType(theGraph, arc, EDGE_TYPE_RANDOMTREE);
            gp_SetEdgeType(theGraph, gp_GetTwinArc(theGraph, arc), EDGE_TYPE_RANDOMTREE);
            gp_ClearEdgeVisited(theGraph, arc);
            gp_ClearEdgeVisited(theGraph, gp_GetTwinArc(theGraph, arc));
	    }
    }

/* Add edges up to the limit or until the graph is maximal planar. */

    M = numEdges <= 3*N - 6 ? numEdges : 3*N - 6;

    root = 0;
    v = last = _getUnprocessedChild(theGraph, root);

    while (v != root && theGraph->M < M)
    {
	     c = _getUnprocessedChild(theGraph, v);

	     if (gp_IsVertex(c))
	     {
             if (last != v)
             {
		         if (gp_AddEdge(theGraph, last, 1, c, 1) != OK)
			         return NOTOK;
             }

		     if (gp_AddEdge(theGraph, root, 1, c, 1) != OK)
			     return NOTOK;

		     v = last = c;
	     }

	     else
	     {
		     p = gp_GetVertexParent(theGraph, v);
		     while (gp_IsVertex(p) && gp_IsNotVertex(c = _getUnprocessedChild(theGraph, p)))
		     {
			     v = p;
			     p = gp_GetVertexParent(theGraph, v);
			     if (gp_IsVertex(p) && p != root)
			     {
				     if (gp_AddEdge(theGraph, last, 1, p, 1) != OK)
					     return NOTOK;
			     }
		     }

		     if (gp_IsVertex(p))
		     {
                 if (p == root)
                 {
                     if (gp_AddEdge(theGraph, v, 1, c, 1) != OK)
				         return NOTOK;

                     if (v != last)
                     {
			             if (gp_AddEdge(theGraph, last, 1, c, 1) != OK)
				             return NOTOK;
                     }
                 }
                 else
                 {
			         if (gp_AddEdge(theGraph, last, 1, c, 1) != OK)
				         return NOTOK;
                 }

                 if (p != root)
                 {
			        if (gp_AddEdge(theGraph, root, 1, c, 1) != OK)
				         return NOTOK;
                    last = c;
                 }

			     v = c;
		     }
	     }
    }

/* Add additional edges if the limit has not yet been reached. */

    while (theGraph->M < numEdges)
    {
        u = _GetRandomNumber(gp_GetFirstVertex(theGraph), gp_GetLastVertex(theGraph));
        v = _GetRandomNumber(gp_GetFirstVertex(theGraph), gp_GetLastVertex(theGraph));

        if (u != v && !gp_IsNeighbor(theGraph, u, v))
            if (gp_AddEdge(theGraph, u, 0, v, 0) != OK)
                return NOTOK;
    }

/* Clear the edge types back to 'unknown' */

    EsizeOccupied = gp_EdgeInUseIndexBound(theGraph);
    for (e = 0; e < EsizeOccupied; e++)
    {
        gp_ClearEdgeType(theGraph, e);
        gp_ClearEdgeVisited(theGraph, e);
    }

/* Put all DFSParent indicators back to NIL */

    for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
        gp_SetVertexParent(theGraph, v, NIL);

    return OK;
}

/********************************************************************
 gp_IsNeighbor()

 Checks whether v is already in u's adjacency list, i.e. does the arc
 u -> v exist.
 If there is an edge record for v in u's list, but it is marked INONLY,
 then it represents the arc v->u but not u->v, so it is ignored.

 Returns TRUE or FALSE.
 ********************************************************************/

int  gp_IsNeighbor(graphP theGraph, int u, int v)
{
int  e = gp_GetFirstArc(theGraph, u);

     while (gp_IsArc(e))
     {
          if (gp_GetNeighbor(theGraph, e) == v)
          {
              if (gp_GetDirection(theGraph, e) != EDGEFLAG_DIRECTION_INONLY)
            	  return TRUE;
          }
          e = gp_GetNextArc(theGraph, e);
     }
     return FALSE;
}

/********************************************************************
 gp_GetNeighborEdgeRecord()
 Searches the adjacency list of u to obtains the edge record for v.

 NOTE: The caller should check whether the edge record is INONLY;
       This method returns any edge record representing a connection
       between vertices u and v, so this method can return an
       edge record even if gp_IsNeighbor(theGraph, u, v) is false (0).
       To filter out INONLY edge records, use gp_GetDirection() on
       the edge record returned by this method.

 Returns NIL if there is no edge record indicating v in u's adjacency
         list, or the edge record location otherwise.
 ********************************************************************/

int  gp_GetNeighborEdgeRecord(graphP theGraph, int u, int v)
{
int  e;

     if (gp_IsNotVertex(u) || gp_IsNotVertex(v))
    	 return NIL + NOTOK - NOTOK;

     e = gp_GetFirstArc(theGraph, u);
     while (gp_IsArc(e))
     {
          if (gp_GetNeighbor(theGraph, e) == v)
        	  return e;

          e = gp_GetNextArc(theGraph, e);
     }
     return NIL;
}

/********************************************************************
 gp_GetVertexDegree()

 Counts the number of edge records in the adjacency list of a given
 vertex V.

 Note: For digraphs, this method returns the total degree of the
       vertex, including outward arcs (undirected and OUTONLY)
       as well as INONLY arcs.  Other functions are defined to get
       the in-degree or out-degree of the vertex.

 Note: This function determines the degree by counting.  An extension
       could cache the degree value of each vertex and update the
       cached value as edges are added and deleted.
 ********************************************************************/

int  gp_GetVertexDegree(graphP theGraph, int v)
{
int  e, degree;

     if (theGraph==NULL || gp_IsNotVertex(v))
    	 return 0 + NOTOK - NOTOK;

     degree = 0;

     e = gp_GetFirstArc(theGraph, v);
     while (gp_IsArc(e))
     {
         degree++;
         e = gp_GetNextArc(theGraph, e);
     }

     return degree;
}

/********************************************************************
 gp_GetVertexInDegree()

 Counts the number of edge records in the adjacency list of a given
 vertex V that represent arcs from another vertex into V.
 This includes undirected edges and INONLY arcs, so it only excludes
 edges records that are marked as OUTONLY arcs.

 Note: This function determines the in-degree by counting.  An extension
       could cache the in-degree value of each vertex and update the
       cached value as edges are added and deleted.
 ********************************************************************/

int  gp_GetVertexInDegree(graphP theGraph, int v)
{
int  e, degree;

     if (theGraph==NULL || gp_IsNotVertex(v))
    	 return 0 + NOTOK - NOTOK;

     degree = 0;

     e = gp_GetFirstArc(theGraph, v);
     while (gp_IsArc(e))
     {
         if (gp_GetDirection(theGraph, e) != EDGEFLAG_DIRECTION_OUTONLY)
             degree++;
         e = gp_GetNextArc(theGraph, e);
     }

     return degree;
}

/********************************************************************
 gp_GetVertexOutDegree()

 Counts the number of edge records in the adjacency list of a given
 vertex V that represent arcs from V to another vertex.
 This includes undirected edges and OUTONLY arcs, so it only excludes
 edges records that are marked as INONLY arcs.

 Note: This function determines the out-degree by counting.  An extension
       could cache the out-degree value of each vertex and update the
       cached value as edges are added and deleted.
 ********************************************************************/

int  gp_GetVertexOutDegree(graphP theGraph, int v)
{
int  e, degree;

     if (theGraph==NULL || gp_IsNotVertex(v))
    	 return 0 + NOTOK - NOTOK;

     degree = 0;

     e = gp_GetFirstArc(theGraph, v);
     while (gp_IsArc(e))
     {
         if (gp_GetDirection(theGraph, e) != EDGEFLAG_DIRECTION_INONLY)
             degree++;
         e = gp_GetNextArc(theGraph, e);
     }

     return degree;
}

/********************************************************************
 gp_AttachArc()

 This routine adds newArc into v's adjacency list at a position
 adjacent to the edge record for e, either before or after e,
 depending on link.  If e is not an arc (e.g. if e is NIL),
 then link is assumed to indicate whether the new arc is to be
 placed at the beginning or end of v's adjacency list.

 NOTE: The caller can pass NIL for v if e is not NIL, since the
       vertex is implied (gp_GetNeighbor(theGraph, eTwin))

 The arc is assumed to already exist in the data structure (i.e.
 the storage of edges), as only a whole edge (two arcs) can be
 inserted into or deleted from the data structure.  Hence there is
 no such thing as gp_InsertArc() or gp_DeleteArc().

 See also gp_DetachArc(), gp_InsertEdge() and gp_DeleteEdge()
 ********************************************************************/

void gp_AttachArc(graphP theGraph, int v, int e, int link, int newArc)
{
     if (gp_IsArc(e))
     {
    	 int e2 = gp_GetAdjacentArc(theGraph, e, link);

         // e's link is newArc, and newArc's 1^link is e
    	 gp_SetAdjacentArc(theGraph, e, link, newArc);
    	 gp_SetAdjacentArc(theGraph, newArc, 1^link, e);

    	 // newArcs's link is e2
    	 gp_SetAdjacentArc(theGraph, newArc, link, e2);

    	 // if e2 is an arc, then e2's 1^link is newArc, else v's 1^link is newArc
    	 if (gp_IsArc(e2))
    		 gp_SetAdjacentArc(theGraph, e2, 1^link, newArc);
    	 else
    		 gp_SetArc(theGraph, v, 1^link, newArc);
     }
     else
     {
    	 int e2 = gp_GetArc(theGraph, v, link);

    	 // v's link is newArc, and newArc's 1^link is NIL
    	 gp_SetArc(theGraph, v, link, newArc);
    	 gp_SetAdjacentArc(theGraph, newArc, 1^link, NIL);

    	 // newArcs's elink is e2
    	 gp_SetAdjacentArc(theGraph, newArc, link, e2);

    	 // if e2 is an arc, then e2's 1^link is newArc, else v's 1^link is newArc
    	 if (gp_IsArc(e2))
    		 gp_SetAdjacentArc(theGraph, e2, 1^link, newArc);
    	 else
    		 gp_SetArc(theGraph, v, 1^link, newArc);
     }
}

/****************************************************************************
 gp_DetachArc()

 This routine detaches arc from its adjacency list, but it does not delete
 it from the data structure (only a whole edge can be deleted).

 Some algorithms must temporarily detach an edge, perform some calculation,
 and eventually put the edge back. This routine supports that operation.
 The neighboring adjacency list nodes are cross-linked, but the two link
 members of the arc are retained, so the arc can be reattached later by
 invoking _RestoreArc().  A sequence of detached arcs can only be restored
 in the exact opposite order of their detachment.  Thus, algorithms do not
 directly use this method to implement the temporary detach/restore method.
 Instead, gp_HideEdge() and gp_RestoreEdge are used, and algorithms push
 edge hidden edge onto the stack.  One example of this stack usage is
 provided by detaching edges with gp_ContractEdge() or gp_IdentifyVertices(),
 and reattaching with gp_RestoreIdentifications(), which unwinds the stack
 by invoking gp_RestoreVertex().
 ****************************************************************************/

void gp_DetachArc(graphP theGraph, int arc)
{
	int nextArc = gp_GetNextArc(theGraph, arc),
	    prevArc = gp_GetPrevArc(theGraph, arc);

	    if (gp_IsArc(nextArc))
	    	gp_SetPrevArc(theGraph, nextArc, prevArc);
	    else
	    	gp_SetLastArc(theGraph, gp_GetNeighbor(theGraph, gp_GetTwinArc(theGraph, arc)), prevArc);

	    if (gp_IsArc(prevArc))
	    	gp_SetNextArc(theGraph, prevArc, nextArc);
	    else
	    	gp_SetFirstArc(theGraph, gp_GetNeighbor(theGraph, gp_GetTwinArc(theGraph, arc)), nextArc);
}

/********************************************************************
 gp_AddEdge()
 Adds the undirected edge (u,v) to the graph by placing edge records
 representing u into v's circular edge record list and v into u's
 circular edge record list.

 upos receives the location in G where the u record in v's list will be
        placed, and vpos is the location in G of the v record we placed in
 u's list.  These are used to initialize the short circuit links.

 ulink (0|1) indicates whether the edge record to v in u's list should
        become adjacent to u by its 0 or 1 link, i.e. u[ulink] == vpos.
 vlink (0|1) indicates whether the edge record to u in v's list should
        become adjacent to v by its 0 or 1 link, i.e. v[vlink] == upos.

 ********************************************************************/

int  gp_AddEdge(graphP theGraph, int u, int ulink, int v, int vlink)
{
int  upos, vpos;

     if (theGraph==NULL || u < gp_GetFirstVertex(theGraph) || v < gp_GetFirstVertex(theGraph) ||
    		 !gp_VirtualVertexInRange(theGraph, u) || !gp_VirtualVertexInRange(theGraph, v))
         return NOTOK;

     /* We enforce the edge limit */

     if (theGraph->M >= theGraph->arcCapacity/2)
         return NONEMBEDDABLE;

     if (sp_NonEmpty(theGraph->edgeHoles))
     {
         sp_Pop(theGraph->edgeHoles, vpos);
     }
     else
         vpos = gp_EdgeInUseIndexBound(theGraph);

     upos = gp_GetTwinArc(theGraph, vpos);

     gp_SetNeighbor(theGraph, upos, v);
     gp_AttachArc(theGraph, u, NIL, ulink, upos);
     gp_SetNeighbor(theGraph, vpos, u);
     gp_AttachArc(theGraph, v, NIL, vlink, vpos);

     theGraph->M++;
     return OK;
}

/********************************************************************
 gp_InsertEdge()

 This function adds the edge (u, v) such that the edge record added
 to the adjacency list of u is adjacent to e_u and the edge record
 added to the adjacency list of v is adjacent to e_v.
 The direction of adjacency is given by e_ulink for e_u and e_vlink
 for e_v. Specifically, the new edge will be comprised of two arcs,
 n_u and n_v.  In u's (v's) adjacency list, n_u (n_v) will be added
 so that it is indicated by e_u's (e_v's) e_ulink (e_vlink).
 If e_u (or e_v) is not an arc, then e_ulink (e_vlink) indicates
 whether to prepend or append to the adjacency list for u (v).
 ********************************************************************/

int  gp_InsertEdge(graphP theGraph, int u, int e_u, int e_ulink,
                                    int v, int e_v, int e_vlink)
{
int vertMax = gp_GetLastVirtualVertex(theGraph),
    edgeMax = gp_EdgeInUseIndexBound(theGraph) - 1,
    upos, vpos;

     if (theGraph==NULL || u < gp_GetFirstVertex(theGraph) || v < gp_GetFirstVertex(theGraph) ||
    	 u > vertMax || v > vertMax ||
         e_u > edgeMax || (e_u < gp_GetFirstEdge(theGraph) && gp_IsArc(e_u)) ||
         e_v > edgeMax || (e_v < gp_GetFirstEdge(theGraph) && gp_IsArc(e_v)) ||
         e_ulink < 0 || e_ulink > 1 || e_vlink < 0 || e_vlink > 1)
         return NOTOK;

     if (theGraph->M >= theGraph->arcCapacity/2)
         return NONEMBEDDABLE;

     if (sp_NonEmpty(theGraph->edgeHoles))
     {
         sp_Pop(theGraph->edgeHoles, vpos);
     }
     else
         vpos = gp_EdgeInUseIndexBound(theGraph);

     upos = gp_GetTwinArc(theGraph, vpos);

     gp_SetNeighbor(theGraph, upos, v);
     gp_AttachArc(theGraph, u, e_u, e_ulink, upos);

     gp_SetNeighbor(theGraph, vpos, u);
     gp_AttachArc(theGraph, v, e_v, e_vlink, vpos);

     theGraph->M++;

     return OK;
}

/****************************************************************************
 gp_DeleteEdge()

 This function deletes the given edge record e and its twin, reducing the
 number of edges M in the graph.
 Before the e^th record is deleted, its 'nextLink' adjacency list neighbor
 is collected as the return result.  This is useful when iterating through
 an edge list and making deletions because the nextLink arc is the 'next'
 arc in the iteration, but it is hard to obtain *after* deleting e.
 ****************************************************************************/

int  gp_DeleteEdge(graphP theGraph, int e, int nextLink)
{
	 // Calculate the nextArc after e so that, when e is deleted, the return result
	 // informs a calling loop of the next edge to be processed.
	 int  nextArc = gp_GetAdjacentArc(theGraph, e, nextLink);

	 // Delete the edge records e and eTwin from their adjacency lists.
     gp_DetachArc(theGraph, e);
     gp_DetachArc(theGraph, gp_GetTwinArc(theGraph, e));

     // Clear the two edge records
     // (the bit twiddle (e & ~1) chooses the lesser of e and its twin arc)
#if NIL == 0
     memset(theGraph->E + (e & ~1), NIL_CHAR, sizeof(edgeRec) << 1);
#else
     _InitEdgeRec(theGraph, e);
     _InitEdgeRec(theGraph, gp_GetTwinArc(theGraph, e));
#endif

     // Now we reduce the number of edges in the data structure
     theGraph->M--;

     // If records e and eTwin were not the last in the edge record array,
     // then record a new hole in the edge array. */
     if (e < gp_EdgeInUseIndexBound(theGraph))
     {
         sp_Push(theGraph->edgeHoles, e);
     }

     // Return the previously calculated successor of e.
     return nextArc;
}

/********************************************************************
 _RestoreArc()
 This routine reinserts an arc into the edge list from which it
 was previously removed by gp_DetachArc().

 The assumed processing model is that arcs will be restored in reverse
 of the order in which they were hidden, i.e. it is assumed that the
 hidden arcs will be pushed on a stack and the arcs will be popped
 from the stack for restoration.
 ********************************************************************/

void _RestoreArc(graphP theGraph, int arc)
{
int nextArc = gp_GetNextArc(theGraph, arc),
	prevArc = gp_GetPrevArc(theGraph, arc);

	if (gp_IsArc(nextArc))
		gp_SetPrevArc(theGraph, nextArc, arc);
	else
		gp_SetLastArc(theGraph, gp_GetNeighbor(theGraph, gp_GetTwinArc(theGraph, arc)), arc);

    if (gp_IsArc(prevArc))
    	gp_SetNextArc(theGraph, prevArc, arc);
    else
    	gp_SetFirstArc(theGraph, gp_GetNeighbor(theGraph, gp_GetTwinArc(theGraph, arc)), arc);
}

/********************************************************************
 gp_HideEdge()
 This routine removes the two arcs of an edge from the adjacency lists
 of its endpoint vertices, but does not delete them from the storage
 data structure.

 Many algorithms must temporarily remove an edge, perform some
 calculation, and eventually put the edge back. This routine supports
 that operation.

 For each arc, the neighboring adjacency list nodes are cross-linked,
 but the links in the arc are retained because they indicate the
 neighbor arcs to which the arc can be reattached by gp_RestoreEdge().
 ********************************************************************/

void gp_HideEdge(graphP theGraph, int e)
{
	theGraph->functions.fpHideEdge(theGraph, e);
}

void _HideEdge(graphP theGraph, int e)
{
	gp_DetachArc(theGraph, e);
	gp_DetachArc(theGraph, gp_GetTwinArc(theGraph, e));
}

/********************************************************************
 gp_RestoreEdge()
 This routine reinserts two two arcs of an edge into the adjacency
 lists of the edge's endpoints, the arcs having been previously
 removed by gp_HideEdge().

 The assumed processing model is that edges will be restored in
 reverse of the order in which they were hidden, i.e. it is assumed
 that the hidden edges will be pushed on a stack and the edges will
 be popped from the stack for restoration.

 Note: Since both arcs of an edge are restored, only one arc need
        be pushed on the stack for restoration.  This routine
        restores the two arcs in the opposite order from the order
        in which they are hidden by gp_HideEdge().
 ********************************************************************/

void gp_RestoreEdge(graphP theGraph, int e)
{
	theGraph->functions.fpRestoreEdge(theGraph, e);
}

void _RestoreEdge(graphP theGraph, int e)
{
     _RestoreArc(theGraph, gp_GetTwinArc(theGraph, e));
     _RestoreArc(theGraph, e);
}

/********************************************************************
 _HideInternalEdges()
 Pushes onto the graph's stack and hides all arc nodes of the vertex
 except the first and last arcs in the adjacency list of the vertex.
 This method is typically called on a vertex that is on the external
 face of a biconnected component, because the first and last arcs are
 the ones that attach the vertex to the external face cycle, and any
 other arcs in the adjacency list are inside that cycle.

 This method uses the stack. The caller is expected to clear the stack
 or save the stack size before invocation, since the stack size is
 needed to _RestoreInternalEdges().
 ********************************************************************/

int  _HideInternalEdges(graphP theGraph, int vertex)
{
int e = gp_GetFirstArc(theGraph, vertex);

    // If the vertex adjacency list is empty or if it contains
    // only one edge, then there are no *internal* edges to hide
    if (e == gp_GetLastArc(theGraph, vertex))
    	return OK;

    // Start with the first internal edge
    e = gp_GetNextArc(theGraph, e);

    // Cycle through all the edges, pushing each except stop
    // before pushing the last edge, which is not internal
    while (e != gp_GetLastArc(theGraph, vertex))
    {
        sp_Push(theGraph->theStack, e);
        gp_HideEdge(theGraph, e);
        e = gp_GetNextArc(theGraph, e);
    }

    return OK;
}

/********************************************************************
 _RestoreInternalEdges()
 Reverses the effects of _HideInternalEdges()
 ********************************************************************/

int  _RestoreInternalEdges(graphP theGraph, int stackBottom)
{
	return _RestoreHiddenEdges(theGraph, stackBottom);
}

/********************************************************************
 _RestoreHiddenEdges()

 Each entry on the stack, down to stackBottom, is assumed to be an
 edge record (arc) pushed in concert with invoking gp_HideEdge().
 Each edge is restored using gp_RestoreEdge() in exact reverse of the
 hiding order.  The stack is reduced in size to stackBottom.

 Returns OK on success, NOTOK on internal failure.
 ********************************************************************/

int  _RestoreHiddenEdges(graphP theGraph, int stackBottom)
{
	int  e;

	 while (sp_GetCurrentSize(theGraph->theStack) > stackBottom)
	 {
		  sp_Pop(theGraph->theStack, e);
		  if (gp_IsNotArc(e))
			  return NOTOK;
		  gp_RestoreEdge(theGraph, e);
	 }

	 return OK;
}

/********************************************************************
 gp_HideVertex()

 Pushes onto the graph's stack and hides all arc nodes of the vertex.
 Additional integers are then pushed so that the result is reversible
 by gp_RestoreVertex().  See that method for details on the expected
 stack segment.

 Returns OK for success, NOTOK for internal failure.
 ********************************************************************/

int  gp_HideVertex(graphP theGraph, int vertex)
{
	if (gp_IsNotVertex(vertex))
		return NOTOK;

	return theGraph->functions.fpHideVertex(theGraph, vertex);
}

int  _HideVertex(graphP theGraph, int vertex)
{
	int hiddenEdgeStackBottom = sp_GetCurrentSize(theGraph->theStack);
	int e = gp_GetFirstArc(theGraph, vertex);

    // Cycle through all the edges, pushing and hiding each
    while (gp_IsArc(e))
    {
        sp_Push(theGraph->theStack, e);
        gp_HideEdge(theGraph, e);
        e = gp_GetNextArc(theGraph, e);
    }

    // Push the additional integers needed by gp_RestoreVertex()
	sp_Push(theGraph->theStack, hiddenEdgeStackBottom);
	sp_Push(theGraph->theStack, NIL);
	sp_Push(theGraph->theStack, NIL);
	sp_Push(theGraph->theStack, NIL);
	sp_Push(theGraph->theStack, NIL);
	sp_Push(theGraph->theStack, NIL);
	sp_Push(theGraph->theStack, vertex);

    return OK;
}

/********************************************************************
 gp_ContractEdge()

 Contracts the edge e=(u,v).  This hides the edge (both e and its
 twin arc), and it also identifies vertex v with u.
 See gp_IdentifyVertices() for further details.

 Returns OK for success, NOTOK for internal failure.
 ********************************************************************/

int gp_ContractEdge(graphP theGraph, int e)
{
	if (gp_IsNotArc(e))
		return NOTOK;

	return theGraph->functions.fpContractEdge(theGraph, e);
}

int _ContractEdge(graphP theGraph, int e)
{
	int eBefore, u, v;

	if (gp_IsNotArc(e))
		return NOTOK;

	u = gp_GetNeighbor(theGraph, gp_GetTwinArc(theGraph, e));
	v = gp_GetNeighbor(theGraph, e);

	eBefore = gp_GetNextArc(theGraph, e);
	sp_Push(theGraph->theStack, e);
	gp_HideEdge(theGraph, e);

	return gp_IdentifyVertices(theGraph, u, v, eBefore);
}

/********************************************************************
 gp_IdentifyVertices()

 Identifies vertex v with vertex u by transferring all adjacencies
 of v to u.  Any duplicate edges are removed as described below.
 The non-duplicate edges of v are added to the adjacency list of u
 without disturbing their relative order, and they are added before
 the edge record eBefore in u's list. If eBefore is NIL, then the
 edges are simply appended to u's list.

 If u and v are adjacent, then gp_HideEdge() is invoked to remove
 the edge e=(u,v). Then, the edges of v that indicate neighbors of
 u are also hidden.  This is done by setting the visited flags of
 u's neighbors, then traversing the adjacency list of v.  For each
 visited neighbor of v, the edge is hidden because it would duplicate
 an adjacency already expressed in u's list. Finally, the remaining
 edges of v are moved to u's list, and each twin arc is adjusted
 to indicate u as a neighbor rather than v.

 This routine assumes that the visited flags are clear beforehand,
 and visited flag settings made herein are cleared before returning.

 The following are pushed, in order, onto the graph's built-in stack:
 1) an integer for each hidden edge
 2) the stack size before any hidden edges were pushed
 3) six integers that indicate u, v and the edges moved from v to u

 An algorithm that identifies a series of vertices, either through
 directly calling this method or via gp_ContractEdge(), can unwind
 the identifications using gp_RestoreIdentifications(), which
 invokes gp_RestoreVertex() repeatedly.

 Returns OK on success, NOTOK on internal failure
 ********************************************************************/

int gp_IdentifyVertices(graphP theGraph, int u, int v, int eBefore)
{
	return theGraph->functions.fpIdentifyVertices(theGraph, u, v, eBefore);
}

int _IdentifyVertices(graphP theGraph, int u, int v, int eBefore)
{
	int e = gp_GetNeighborEdgeRecord(theGraph, u, v);
	int hiddenEdgeStackBottom, eBeforePred;

	// If the vertices are adjacent, then the identification is
	// essentially an edge contraction with a bit of fixup.
	if (gp_IsArc(e))
	{
		int result = gp_ContractEdge(theGraph, e);

		// The edge contraction operation pushes one hidden edge then
	    // recursively calls this method. This method then pushes K
	    // hidden edges then an integer indicating where the top of
	    // stack was before the edges were hidden. That integer
	    // indicator must be decremented, thereby incrementing the
		// number of hidden edges to K+1.
		// After pushing the K hidden edges and the stackBottom of
		// the hidden edges, the recursive call to this method pushes
		// six more integers to indicate edges that were moved from
		// v to u, so the "hidden edges stackBottom" is in the next
		// position down.
		int hiddenEdgesStackBottomIndex = sp_GetCurrentSize(theGraph->theStack)-7;
		int hiddenEdgesStackBottomValue = sp_Get(theGraph->theStack, hiddenEdgesStackBottomIndex);

		sp_Set(theGraph->theStack, hiddenEdgesStackBottomIndex,	hiddenEdgesStackBottomValue - 1);

		return result;
	}

	// Now, u and v are not adjacent. Before we do any edge hiding or
	// moving, we record the current stack size, as this is the
	// stackBottom for the edges that will be hidden next.
	hiddenEdgeStackBottom = sp_GetCurrentSize(theGraph->theStack);

	// Mark as visited all neighbors of u
    e = gp_GetFirstArc(theGraph, u);
    while (gp_IsArc(e))
    {
    	 if (gp_GetVertexVisited(theGraph, gp_GetNeighbor(theGraph, e)))
    		 return NOTOK;

         gp_SetVertexVisited(theGraph, gp_GetNeighbor(theGraph, e));
         e = gp_GetNextArc(theGraph, e);
    }

	// For each edge record of v, if the neighbor is visited, then
	// push and hide the edge.
    e = gp_GetFirstArc(theGraph, v);
    while (gp_IsArc(e))
    {
         if (gp_GetVertexVisited(theGraph, gp_GetNeighbor(theGraph, e)))
         {
             sp_Push(theGraph->theStack, e);
             gp_HideEdge(theGraph, e);
         }
         e = gp_GetNextArc(theGraph, e);
    }

	// Mark as unvisited all neighbors of u
    e = gp_GetFirstArc(theGraph, u);
    while (gp_IsArc(e))
    {
    	 gp_ClearVertexVisited(theGraph, gp_GetNeighbor(theGraph, e));
         e = gp_GetNextArc(theGraph, e);
    }

	// Push the hiddenEdgeStackBottom as a record of how many hidden
	// edges were pushed (also, see above for Contract Edge adjustment)
	sp_Push(theGraph->theStack, hiddenEdgeStackBottom);

	// Moving v's adjacency list to u is aided by knowing the predecessor
	// of u's eBefore (the edge record in u's list before which the
	// edge records of v will be added).
	eBeforePred = gp_IsArc(eBefore)
	              ? gp_GetPrevArc(theGraph, eBefore)
	              : gp_GetLastArc(theGraph, u);

	// Turns out we only need to record six integers related to the edges
	// being moved in order to easily restore them later.
	sp_Push(theGraph->theStack, eBefore);
	sp_Push(theGraph->theStack, gp_GetLastArc(theGraph, v));
	sp_Push(theGraph->theStack, gp_GetFirstArc(theGraph, v));
	sp_Push(theGraph->theStack, eBeforePred);
	sp_Push(theGraph->theStack, u);
	sp_Push(theGraph->theStack, v);

	// For the remaining edge records of v, reassign the 'v' member
	//    of each twin arc to indicate u rather than v.
    e = gp_GetFirstArc(theGraph, v);
    while (gp_IsArc(e))
    {
         gp_SetNeighbor(theGraph, gp_GetTwinArc(theGraph, e), u);
         e = gp_GetNextArc(theGraph, e);
    }

    // If v has any edges left after hiding edges, indicating common neighbors with u, ...
    if (gp_IsArc(gp_GetFirstArc(theGraph, v)))
    {
    	// Then perform the list union of v into u between eBeforePred and eBefore
        if (gp_IsArc(eBeforePred))
        {
        	if (gp_IsArc(gp_GetFirstArc(theGraph, v)))
        	{
            	gp_SetNextArc(theGraph, eBeforePred, gp_GetFirstArc(theGraph, v));
            	gp_SetPrevArc(theGraph, gp_GetFirstArc(theGraph, v), eBeforePred);
        	}
        }
        else
        {
        	gp_SetFirstArc(theGraph, u, gp_GetFirstArc(theGraph, v));
        }

        if (gp_IsArc(eBefore))
        {
        	if (gp_IsArc(gp_GetLastArc(theGraph, v)))
        	{
            	gp_SetNextArc(theGraph, gp_GetLastArc(theGraph, v), eBefore);
            	gp_SetPrevArc(theGraph, eBefore, gp_GetLastArc(theGraph, v));
        	}
        }
        else
        {
        	gp_SetLastArc(theGraph, u, gp_GetLastArc(theGraph, v));
        }

        gp_SetFirstArc(theGraph, v, NIL);
        gp_SetLastArc(theGraph, v, NIL);
    }

    return OK;
}

/********************************************************************
 gp_RestoreVertex()

 This method assumes the built-in graph stack contents are the result
 of vertex hide, vertex identify and edge contract operations.
 This content consists of segments of integers, each segment
 corresponding to the removal of a vertex during an edge contraction
 or vertex identification in which a vertex v was merged into a
 vertex u.  The segment contains two blocks of integers.
 The first block contains information about u, v, the edge records
 in v's adjacency list that were added to u, and where in u's
 adjacency list they were added.  The second block of integers
 contains a list of edges incident to v that were hidden from the
 graph because they were incident to neighbors of v that were also
 neighbors of u (so they would have produced duplicate edges had
 they been left in v's adjacency list when it was merged with u's
 adjacency list).

 This method pops the first block of the segment off the stack and
 uses the information to help remove v's adjacency list from u and
 restore it into v.  Then, the second block is removed from the
 stack, and each indicated edge is restored from the hidden state.

 It is anticipated that this method will be overloaded by extension
 algorithms to perform some processing as each vertex is restored.
 Before restoration, the topmost segment has the following structure:

 ... FHE ... LHE HESB e_u_succ e_v_last e_v_first e_u_pred u v
      ^------------|

 FHE = First hidden edge
 LHE = Last hidden edge
 HESB = Hidden edge stack bottom
 e_u_succ, e_u_pred = The edges of u between which the edges of v
                      were inserted. NIL can appear if the edges of v
                      were added to the beginning or end of u's list
 e_v_first, e_v_last = The first and last edges of v's list, once
                       the hidden edges were removed

 Returns OK for success, NOTOK for internal failure.
 ********************************************************************/

int gp_RestoreVertex(graphP theGraph)
{
	return theGraph->functions.fpRestoreVertex(theGraph);
}

int _RestoreVertex(graphP theGraph)
{
int u, v, e_u_succ, e_u_pred, e_v_first, e_v_last, HESB, e;

    if (sp_GetCurrentSize(theGraph->theStack) < 7)
    	return NOTOK;

    sp_Pop(theGraph->theStack, v);
    sp_Pop(theGraph->theStack, u);
	sp_Pop(theGraph->theStack, e_u_pred);
	sp_Pop(theGraph->theStack, e_v_first);
	sp_Pop(theGraph->theStack, e_v_last);
	sp_Pop(theGraph->theStack, e_u_succ);

	// If u is not NIL, then vertex v was identified with u.  Otherwise, v was
	// simply hidden, so we skip to restoring the hidden edges.
	if (gp_IsVertex(u))
	{
		// Remove v's adjacency list from u, including accounting for degree 0 case
		if (gp_IsArc(e_u_pred))
		{
			gp_SetNextArc(theGraph, e_u_pred, e_u_succ);
			// If the successor edge exists, link it to the predecessor,
			// otherwise the predecessor is the new last arc
			if (gp_IsArc(e_u_succ))
				gp_SetPrevArc(theGraph, e_u_succ, e_u_pred);
			else
				gp_SetLastArc(theGraph, u, e_u_pred);
		}
		else if (gp_IsArc(e_u_succ))
		{
			// The successor arc exists, but not the predecessor,
			// so the successor is the new first arc
			gp_SetPrevArc(theGraph, e_u_succ, NIL);
			gp_SetFirstArc(theGraph, u, e_u_succ);
		}
		else
		{
			// Just in case u was degree zero
			gp_SetFirstArc(theGraph, u, NIL);
			gp_SetLastArc(theGraph, u, NIL);
		}

		// Place v's adjacency list into v, including accounting for degree 0 case
		gp_SetFirstArc(theGraph, v, e_v_first);
		gp_SetLastArc(theGraph, v, e_v_last);
		if (gp_IsArc(e_v_first))
			gp_SetPrevArc(theGraph, e_v_first, NIL);
		if (gp_IsArc(e_v_last))
			gp_SetPrevArc(theGraph, e_v_last, NIL);

		// For each edge record restored to v's adjacency list, reassign the 'v' member
		//    of each twin arc to indicate v rather than u.
	    e = e_v_first;
	    while (gp_IsArc(e))
	    {
	         gp_SetNeighbor(theGraph, gp_GetTwinArc(theGraph, e), v);
	         e = (e == e_v_last ? NIL : gp_GetNextArc(theGraph, e));
	    }
	}

	// Restore the hidden edges of v, if any
	sp_Pop(theGraph->theStack, HESB);
	return _RestoreHiddenEdges(theGraph, HESB);
}

/********************************************************************
 gp_RestoreVertices()

 This method assumes the built-in graph stack has content consistent
 with numerous vertex identification or edge contraction operations.
 This method unwinds the stack, moving edges back to their original
 vertex owners and restoring hidden edges.
 This method is a simple iterator that invokes gp_RestoreVertex()
 until the stack is empty, so extension algorithms are more likely
 to overload gp_RestoreVertex().

 Returns OK for success, NOTOK for internal failure.
 ********************************************************************/

int gp_RestoreVertices(graphP theGraph)
{
    while (sp_NonEmpty(theGraph->theStack))
    {
    	if (gp_RestoreVertex(theGraph) != OK)
    		return NOTOK;
    }

    return OK;
}

/****************************************************************************
 _ComputeArcType()
 This is just a little helper function that automates a sequence of decisions
 that has to be made a number of times.
 An edge record is being added to the adjacency list of a; it indicates that
 b is a neighbor.  The edgeType can be either 'tree' (EDGE_TYPE_PARENT or
 EDGE_TYPE_CHILD) or 'cycle' (EDGE_TYPE_BACK or EDGE_TYPE_FORWARD).
 If a or b is a root copy, we translate to the non-virtual counterpart,
 then wedetermine which has the lesser DFI.  If a has the lower DFI then the
 edge record is a tree edge to a child (EDGE_TYPE_CHILD) if edgeType indicates
 a tree edge.  If edgeType indicates a cycle edge, then it is a forward cycle
 edge (EDGE_TYPE_FORWARD) to a descendant.
 Symmetric conditions define the types for a > b.
 ****************************************************************************/

int  _ComputeArcType(graphP theGraph, int a, int b, int edgeType)
{
     a = gp_IsVirtualVertex(theGraph, a) ? gp_GetPrimaryVertexFromRoot(theGraph, a) : a;
     b = gp_IsVirtualVertex(theGraph, b) ? gp_GetPrimaryVertexFromRoot(theGraph, b) : b;

     if (a < b)
         return edgeType == EDGE_TYPE_PARENT || edgeType == EDGE_TYPE_CHILD ? EDGE_TYPE_CHILD : EDGE_TYPE_FORWARD;

     return edgeType == EDGE_TYPE_PARENT || edgeType == EDGE_TYPE_CHILD ? EDGE_TYPE_PARENT : EDGE_TYPE_BACK;
}

/****************************************************************************
 _SetEdgeType()
 When we are restoring an edge, we must restore its type (tree edge or cycle edge).
 We can deduce what the type was based on other information in the graph. Each
 arc of the edge gets the appropriate type setting (parent/child or back/forward).
 This method runs in constant time plus the degree of vertex u, or constant
 time if u is known to have a degree bound by a constant.
 ****************************************************************************/

int  _SetEdgeType(graphP theGraph, int u, int v)
{
int  e, eTwin, u_orig, v_orig;

     // If u or v is a virtual vertex (a root copy), then get the non-virtual counterpart.
     u_orig = gp_IsVirtualVertex(theGraph, u) ? (gp_GetPrimaryVertexFromRoot(theGraph, u)) : u;
     v_orig = gp_IsVirtualVertex(theGraph, v) ? (gp_GetPrimaryVertexFromRoot(theGraph, v)) : v;

     // Get the edge for which we will set the type

     e = gp_GetNeighborEdgeRecord(theGraph, u, v);
     eTwin = gp_GetTwinArc(theGraph, e);

     // If u_orig is the parent of v_orig, or vice versa, then the edge is a tree edge

     if (gp_GetVertexParent(theGraph, v_orig) == u_orig ||
         gp_GetVertexParent(theGraph, u_orig) == v_orig)
     {
         if (u_orig > v_orig)
         {
             gp_ResetEdgeType(theGraph, e, EDGE_TYPE_PARENT);
             gp_ResetEdgeType(theGraph, eTwin, EDGE_TYPE_CHILD);
         }
         else
         {
             gp_ResetEdgeType(theGraph, eTwin, EDGE_TYPE_PARENT);
             gp_ResetEdgeType(theGraph, e, EDGE_TYPE_CHILD);
         }
     }

     // Otherwise it is a back edge

     else
     {
         if (u_orig > v_orig)
         {
             gp_ResetEdgeType(theGraph, e, EDGE_TYPE_BACK);
             gp_ResetEdgeType(theGraph, eTwin, EDGE_TYPE_FORWARD);
         }
         else
         {
             gp_ResetEdgeType(theGraph, eTwin, EDGE_TYPE_BACK);
             gp_ResetEdgeType(theGraph, e, EDGE_TYPE_FORWARD);
         }
     }

     return OK;
}

/********************************************************************
 _DeleteUnmarkedEdgesInBicomp()

 This function deletes from a given biconnected component all edges
 whose visited member is zero.

 The stack is used but preserved. In debug mode, NOTOK can result if
 there is a stack overflow. This method pushes at most one integer
 per vertex in the bicomp.

 Returns OK on success, NOTOK on implementation failure
 ********************************************************************/

int  _DeleteUnmarkedEdgesInBicomp(graphP theGraph, int BicompRoot)
{
int  V, e;
int  stackBottom = sp_GetCurrentSize(theGraph->theStack);

     sp_Push(theGraph->theStack, BicompRoot);
     while (sp_GetCurrentSize(theGraph->theStack) > stackBottom)
     {
          sp_Pop(theGraph->theStack, V);

          e = gp_GetFirstArc(theGraph, V);
          while (gp_IsArc(e))
          {
             if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_CHILD)
                 sp_Push(theGraph->theStack, gp_GetNeighbor(theGraph, e));

             e = gp_GetEdgeVisited(theGraph, e) ? gp_GetNextArc(theGraph, e) : gp_DeleteEdge(theGraph, e, 0);
          }
     }
     return OK;
}

/********************************************************************
 _ClearInvertedFlagsInBicomp()

 This function clears the inverted flag markers on any edges in a
 given biconnected component.

 The stack is used but preserved. In debug mode, NOTOK can result if
 there is a stack overflow. This method pushes at most one integer
 per vertex in the bicomp.

 Returns OK on success, NOTOK on implementation failure
 ********************************************************************/

int  _ClearInvertedFlagsInBicomp(graphP theGraph, int BicompRoot)
{
int  V, e;
int  stackBottom = sp_GetCurrentSize(theGraph->theStack);

     sp_Push(theGraph->theStack, BicompRoot);
     while (sp_GetCurrentSize(theGraph->theStack) > stackBottom)
     {
          sp_Pop(theGraph->theStack, V);

          e = gp_GetFirstArc(theGraph, V);
          while (gp_IsArc(e))
          {
             if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_CHILD)
             {
                 sp_Push(theGraph->theStack, gp_GetNeighbor(theGraph, e));
                 gp_ClearEdgeFlagInverted(theGraph, e);
             }

             e = gp_GetNextArc(theGraph, e);
          }
     }
     return OK;
}

/********************************************************************
 _GetBicompSize()

 Determine the number of vertices in the bicomp.

 The stack is used but preserved. In debug mode, NOTOK can result if
 there is a stack overflow. This method pushes at most one integer
 per vertex in the bicomp.

 Returns a positive number on success, NOTOK on implementation failure
 ********************************************************************/

int  _GetBicompSize(graphP theGraph, int BicompRoot)
{
int  V, e;
int  theSize = 0;
int  stackBottom = sp_GetCurrentSize(theGraph->theStack);

     sp_Push(theGraph->theStack, BicompRoot);
     while (sp_GetCurrentSize(theGraph->theStack) > stackBottom)
     {
          sp_Pop(theGraph->theStack, V);
          theSize++;
          e = gp_GetFirstArc(theGraph, V);
          while (gp_IsArc(e))
          {
             if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_CHILD)
                 sp_Push(theGraph->theStack, gp_GetNeighbor(theGraph, e));

             e = gp_GetNextArc(theGraph, e);
          }
     }
     return theSize;
}

/********************************************************************
 debugNOTOK()
 This function provides a non-void wrapper for exit().
 This is useful for debugging as it allows compilation of an exit
 command in places where NOTOK is returned.
 In exhaustive testing, we want to bail on the first NOTOK that occurs.
 Comment out the exit() call to get a stack trace.
 ********************************************************************/

int debugNOTOK()
{
	//exit(-1);
	return 0; // NOTOK is normally defined to be zero
}
