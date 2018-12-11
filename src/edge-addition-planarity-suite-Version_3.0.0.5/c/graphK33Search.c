/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "graphK33Search.h"
#include "graphK33Search.private.h"

//extern int K33SEARCH_ID;

#include "graph.h"

/* Imported functions */

//extern void _ClearVisitedFlags(graphP);
extern int  _ClearVisitedFlagsInBicomp(graphP theGraph, int BicompRoot);
extern int  _ClearVisitedFlagsInOtherBicomps(graphP theGraph, int BicompRoot);
extern void _ClearVisitedFlagsInUnembeddedEdges(graphP theGraph);
extern int  _FillVertexVisitedInfoInBicomp(graphP theGraph, int BicompRoot, int FillValue);

//extern int  _GetBicompSize(graphP theGraph, int BicompRoot);
extern int  _HideInternalEdges(graphP theGraph, int vertex);
extern int  _RestoreInternalEdges(graphP theGraph, int stackBottom);
extern int  _ClearInvertedFlagsInBicomp(graphP theGraph, int BicompRoot);
extern int  _ComputeArcType(graphP theGraph, int a, int b, int edgeType);
extern int  _SetEdgeType(graphP theGraph, int u, int v);

extern int  _GetNeighborOnExtFace(graphP theGraph, int curVertex, int *pPrevLink);
extern int  _JoinBicomps(graphP theGraph);
extern int  _OrientVerticesInBicomp(graphP theGraph, int BicompRoot, int PreserveSigns);
extern int  _OrientVerticesInEmbedding(graphP theGraph);
//extern void _InvertVertex(graphP theGraph, int V);
extern int  _ClearVisitedFlagsOnPath(graphP theGraph, int u, int v, int w, int x);
extern int  _SetVisitedFlagsOnPath(graphP theGraph, int u, int v, int w, int x);
extern int  _OrientExternalFacePath(graphP theGraph, int u, int v, int w, int x);

extern int  _ChooseTypeOfNonplanarityMinor(graphP theGraph, int v, int R);
extern int  _MarkHighestXYPath(graphP theGraph);

extern int  _IsolateKuratowskiSubgraph(graphP theGraph, int v, int R);

extern int  _GetLeastAncestorConnection(graphP theGraph, int cutVertex);
extern int  _FindUnembeddedEdgeToCurVertex(graphP theGraph, int cutVertex, int *pDescendant);
extern int  _FindUnembeddedEdgeToSubtree(graphP theGraph, int ancestor, int SubtreeRoot, int *pDescendant);

extern int  _MarkPathAlongBicompExtFace(graphP theGraph, int startVert, int endVert);

extern int  _AddAndMarkEdge(graphP theGraph, int ancestor, int descendant);

extern int  _DeleteUnmarkedVerticesAndEdges(graphP theGraph);

extern int  _IsolateMinorE1(graphP theGraph);
//extern int  _IsolateMinorE2(graphP theGraph);
extern int  _IsolateMinorE3(graphP theGraph);
extern int  _IsolateMinorE4(graphP theGraph);

extern int  _MarkDFSPathsToDescendants(graphP theGraph);
extern int  _AddAndMarkUnembeddedEdges(graphP theGraph);

extern void _K33Search_InitEdgeRec(K33SearchContext *context, int e);

/* Private functions for K_{3,3} searching. */

int  _SearchForK33InBicomp(graphP theGraph, K33SearchContext *context, int v, int R);

int  _RunExtraK33Tests(graphP theGraph, K33SearchContext *context);
int  _SearchForMinorE1(graphP theGraph);
int  _FinishIsolatorContextInitialization(graphP theGraph, K33SearchContext *context);
int  _SearchForDescendantExternalConnection(graphP theGraph, K33SearchContext *context, int cutVertex, int u_max);
int  _Fast_GetLeastAncestorConnection(graphP theGraph, K33SearchContext *context, int cutVertex);
int  _GetAdjacentAncestorInRange(graphP theGraph, K33SearchContext *context, int vertex,
                                int closerAncestor, int fartherAncestor);
int  _FindExternalConnectionDescendantEndpoint(graphP theGraph, int ancestor,
                                               int cutVertex, int *pDescendant);
int  _SearchForMergeBlocker(graphP theGraph, K33SearchContext *context, int v, int *pMergeBlocker);
int  _FindK33WithMergeBlocker(graphP theGraph, K33SearchContext *context, int v, int mergeBlocker);

int  _TestForLowXYPath(graphP theGraph);
int  _TestForZtoWPath(graphP theGraph);
int  _TestForStraddlingBridge(graphP theGraph, K33SearchContext *context, int u_max);
int  _K33Search_DeleteUnmarkedEdgesInBicomp(graphP theGraph, K33SearchContext *context, int BicompRoot);
int  _K33Search_DeleteEdge(graphP theGraph, K33SearchContext *context, int e, int nextLink);
int  _ReduceBicomp(graphP theGraph, K33SearchContext *context, int R);
int  _ReduceExternalFacePathToEdge(graphP theGraph, K33SearchContext *context, int u, int x, int edgeType);
int  _ReduceXYPathToEdge(graphP theGraph, K33SearchContext *context, int u, int x, int edgeType);
int  _RestoreReducedPath(graphP theGraph, K33SearchContext *context, int e);
int  _RestoreAndOrientReducedPaths(graphP theGraph, K33SearchContext *context);

int  _IsolateMinorE5(graphP theGraph);
int  _IsolateMinorE6(graphP theGraph, K33SearchContext *context);
int  _IsolateMinorE7(graphP theGraph, K33SearchContext *context);

/****************************************************************************
 _SearchForK33InBicomp()
 ****************************************************************************/

int  _SearchForK33InBicomp(graphP theGraph, K33SearchContext *context, int v, int R)
{
isolatorContextP IC = &theGraph->IC;
int tempResult;

/* Begin by determining which non-planarity minor is detected */

     if (_ChooseTypeOfNonplanarityMinor(theGraph, v, R) != OK)
         return NOTOK;

/* If minor A is selected, then the root of the oriented bicomp has been changed */

     else R = IC->r;

/* Minors A to D result in the desired K_{3,3} homeomorph,
    so we isolate it and return NONEMBEDDABLE. */

     if (theGraph->IC.minorType & (MINORTYPE_A|MINORTYPE_B|MINORTYPE_C|MINORTYPE_D))
     {
        /* First we restore the orientations of the vertices in the
            one bicomp we have messed with so that there is no confusion. */

        if (_OrientVerticesInBicomp(theGraph, R, 1) != OK)
        	return NOTOK;

        /* Next we restore the orientation of the embedding so we
           can restore the reduced paths (because we avoid modifying
           the Kuratowski subgraph isolator to restore reduced paths,
           which are a construct of the K_{3,3} search). */

        if (_OrientVerticesInEmbedding(theGraph) != OK ||
        	_RestoreAndOrientReducedPaths(theGraph, context) != OK)
            return NOTOK;

        /* Next we simply call the Kuratowski subgraph isolation since
            we know now that it will isolate a K_{3,3}.
            For minor A, we need to set up the stack that would be
            available immediately after a Walkdown failure. */

        if (theGraph->IC.minorType & MINORTYPE_A)
        {
            sp_ClearStack(theGraph->theStack);
            sp_Push2(theGraph->theStack, R, NIL);
        }

        if (_IsolateKuratowskiSubgraph(theGraph, v, R) != OK)
            return NOTOK;

        return NONEMBEDDABLE;
     }

/* For minor E (a K5 minor), we run the additional tests to see if minors E1 to E4 apply
   since these minors isolate a K_{3,3} entangled with the K5.
   This is the key location where GetLeastAncestorConnection() must be constant time. */

     IC->ux = _Fast_GetLeastAncestorConnection(theGraph, context, IC->x);
     IC->uy = _Fast_GetLeastAncestorConnection(theGraph, context, IC->y);
     IC->uz = _Fast_GetLeastAncestorConnection(theGraph, context, IC->z);

     if (IC->z != IC->w ||
         IC->uz > MAX(IC->ux, IC->uy) ||
         (IC->uz < MAX(IC->ux, IC->uy) && IC->ux != IC->uy) ||
         (IC->x != IC->px || IC->y != IC->py))
     {
        if (_OrientVerticesInBicomp(theGraph, R, 1) != OK)
        	return NOTOK;

        if (_OrientVerticesInEmbedding(theGraph) != OK ||
        	_RestoreAndOrientReducedPaths(theGraph, context) != OK)
            return NOTOK;

        if (_IsolateKuratowskiSubgraph(theGraph, v, R) != OK)
            return NOTOK;

        return NONEMBEDDABLE;
     }

/* If the Kuratowski subgraph isolator will not isolate a K_{3,3} based on minor E,
    then a K5 homeomorph could be isolated.  However, a K_{3,3} may still be tangled
    with the K5, so we now run the additional tests of the K_{3,3} search algorithm.

    If the search finds a K_{3,3} (tempResult of NONEMBEDDABLE), then we remove unwanted
    edges from the graph and return NONEMBEDDABLE.  If the search has a fault (NOTOK),
    then we return.  If the result is OK, then a K_{3,3} was not found at this time
    and we proceed with some clean-up work below. */

     if ((tempResult = _RunExtraK33Tests(theGraph, context)) != OK)
     {
         if (tempResult == NONEMBEDDABLE)
            if (_DeleteUnmarkedVerticesAndEdges(theGraph) != OK)
                return NOTOK;

         return tempResult;
     }

/* The extra cases for finding a K_{3,3} did not succeed, so the bicomp rooted by R
    is either a K5 homeomorph (with at most a superficially entangled K_{3,3}) or
    we have made the special setting that allows us to detect the one "merge blocker"
    case that would be too costly to try now.  Either way, we can safely reduce the
    bicomp to the 4-cycle (R, X, W, Y, R) and proceed with the planarity algorithm.
    We also restore the mixed orientation of the bicomp (i.e. the proper
    orientation in the context of the edge signs) because this code can work
    when ReduceBicomp doesn't do any actual work. */

     if (_OrientVerticesInBicomp(theGraph, R, 1) != OK)
    	 return NOTOK;

     if (_ReduceBicomp(theGraph, context, R) != OK)
         return NOTOK;

/* Set visitedInfo values in the bicomp to the initialized state so the planarity
	algorithm can properly do the Walkup procedure in future steps */

     if (_FillVertexVisitedInfoInBicomp(theGraph, IC->r, theGraph->N) != OK)
    	 return NOTOK;

/* We now intend to ignore the pertinence of W (conceptually eliminating
    the connection from W to the current vertex).  Note that none of the
    bicomp roots in the pertinentRootsList (nor their respective subtrees)
    will be visited again by the planarity algorithm because they must've
    been only pertinent.  If they were future pertinent and pertinent,
    then we would've found a K_{3,3} by non-planarity minor B. Thus, the original
    Walkup costs that identified the pertinent bicomps we intend to ignore are
    one-time costs, preserving linear time. */

     gp_SetVertexPertinentEdge(theGraph, IC->w, NIL);
     gp_SetVertexPertinentRootsList(theGraph, IC->w, NIL);

     return OK;
}

/****************************************************************************
 _RunExtraK33Tests()
 ****************************************************************************/

#define USE_MERGEBLOCKER

int  _RunExtraK33Tests(graphP theGraph, K33SearchContext *context)
{
isolatorContextP IC = &theGraph->IC;
int u_max = MAX3(IC->ux, IC->uy, IC->uz);

#ifndef USE_MERGEBLOCKER
int u;
#endif

/* Case 1: If there is a pertinent or future pertinent vertex other than W
            on the lower external face path between X and Y (the points of
            attachment of the x-y path), then we can isolate a K_{3,3} homeomorph
            by Minor E1. */

    if (_SearchForMinorE1(theGraph) != OK)
        return NOTOK;

    if (IC->w != IC->z)
    {
        if (_FinishIsolatorContextInitialization(theGraph, context) != OK ||
            _IsolateMinorE1(theGraph) != OK)
            return NOTOK;

        return NONEMBEDDABLE;
    }

/* Case 2: If W/Z can make an external connection to an ancestor of V
            that is descendant to u_{max}, then a K_{3,3} homeomorph can
            be isolated with Minor E2.

            OPTIMIZATION: We do not need to check for this case.
            We avoid doing so because in very specially crafted cases
            it could be too costly if the connection doesn't exist.
            However, if the highest numbered ancestor H of the current vertex
            that has an external connection from W is a descendant u_{max}
            then we will discover a K_{3,3} by Minor A or B in step H
            (unless some other test succeeds at finding a K_{3,3} first),
            so we just let the non-planarity detector do its work since
            Minors A and B both provide a K_{3,3} when found.

            This happens because w is pertinent to H and future pertinent
            to u_max or an ancestor of u_max.

            Minor A will happen if, in step H, Walkdown descends to the
            bicomp containing the current vertex, x, y and w.  Since x
            and y would still be future pertinent (they connect to u_max
            or higher, i.e. with lesser DFI, than u_max).

            Minor B will happen if the bicomp containing the current vertex,
            x, y and w is a descendant of a bicomp that blocks planarity
            in step H.  The bicomp would be both pertinent (due to w's
            connection to H) and future pertinent(due to connections to
            ancestors of H by w, x and y).
*/

#ifndef USE_MERGEBLOCKER
	u = _SearchForDescendantExternalConnection(theGraph, context, IC->w, u_max);
	if (u > u_max)
	{
		IC->uz = u;
		if (_FinishIsolatorContextInitialization(theGraph, context) != OK ||
			_IsolateMinorE2(theGraph) != OK)
			return NOTOK;

		return NONEMBEDDABLE;
	}
#endif

/* Case 3: If X or Y can make an external connection to an ancestor of V
            that is descendant to u_{max}, then a K_{3,3} homeomorph
            can be isolated with Minor E3.

            NOTE: Due to the prior use of the Kuratowski subgraph
            isolator, we know that at most one of X, Y or W/Z could have an
            external connection to an ancestor of u_{max} = MAX(ux, uy, uz).

            OPTIMIZATION:  We do not check for the lower connection required
            to find Minor E3 because it might ultimately be too costly.
            Instead, we mark the vertex with a 'merge blocker' of u_{max}.
            If the planar embedder attempts to merge the vertex prior to step
            u_{max}, then the embedder has found the desired connection and a
            K_{3,3} homeomorph is isolated at that time.
*/

#ifdef USE_MERGEBLOCKER
	context->VI[IC->x].mergeBlocker = u_max;
#endif
#ifndef USE_MERGEBLOCKER
	u = _SearchForDescendantExternalConnection(theGraph, context, IC->x, u_max);
	if (u > u_max)
	{
		IC->ux = u;
		if (_FinishIsolatorContextInitialization(theGraph, context) != OK ||
			_IsolateMinorE3(theGraph) != OK)
			return NOTOK;

		return NONEMBEDDABLE;
	}
#endif

#ifdef USE_MERGEBLOCKER
	context->VI[IC->y].mergeBlocker = u_max;
#endif
#ifndef USE_MERGEBLOCKER
	u = _SearchForDescendantExternalConnection(theGraph, context, IC->y, u_max);
	if (u > u_max)
	{
		IC->uy = u;
		if (_FinishIsolatorContextInitialization(theGraph, context) != OK ||
			_IsolateMinorE3(theGraph) != OK)
			return NOTOK;

		return NONEMBEDDABLE;
	}
#endif

/* Case 4: If there exists any x-y path with points of attachment px and py
            such that px!=x or py!=y, then a K_{3,3} homeomorph can be isolated
            with Minor E4. */

    if (_TestForLowXYPath(theGraph) != OK)
        return NOTOK;

    if (IC->px != IC->x || IC->py != IC->y)
    {
        if (_FinishIsolatorContextInitialization(theGraph, context) != OK ||
            _IsolateMinorE4(theGraph) != OK)
            return NOTOK;

        return NONEMBEDDABLE;
    }

/* Case 5: If the x-y path contains an internal vertex that starts a second
            internal path from the internal vertex to W/Z, then a K_{3,3} homeomorph
            can be isolated with Minor E5. */

    if (_TestForZtoWPath(theGraph) != OK)
        return NOTOK;

    if (gp_GetVertexVisited(theGraph, IC->w))
    {
        if (_FinishIsolatorContextInitialization(theGraph, context) != OK ||
            _IsolateMinorE5(theGraph) != OK)
            return NOTOK;

        return NONEMBEDDABLE;
    }

/* Case 6: If uz < u_{max} and there is an external connection (other than external
            connections involving X, Y and W/Z) between an ancestor of u_{max} and a
            vertex in the range [V...u_{max}), then a K_{3,3} homeomorph can be
            isolated with Minor E6.

            OPTIMIZATION:  See _TestForStraddlingBridge() */

    if (IC->uz < u_max)
    {
        if (gp_IsVertex(_TestForStraddlingBridge(theGraph, context, u_max)))
        {
            if (_FinishIsolatorContextInitialization(theGraph, context) != OK ||
                _IsolateMinorE6(theGraph, context) != OK)
                return NOTOK;

            return NONEMBEDDABLE;
        }
    }

/* Case 7: If ux < u_{max} or uy < u_{max} and there is an external connection
            between an ancestor of u_{max} and a vertex in the range [V...u_{max})
            (except for external connections involving X, Y and W/Z), then a K_{3,3}
            homeomorph can be isolated with Minor E7.

            OPTIMIZATION: Same as Case 6.*/

    if (IC->ux < u_max || IC->uy < u_max)
    {
        if (gp_IsVertex(_TestForStraddlingBridge(theGraph, context, u_max)))
        {
            if (_FinishIsolatorContextInitialization(theGraph, context) != OK ||
                _IsolateMinorE7(theGraph, context) != OK)
                return NOTOK;

            return NONEMBEDDABLE;
        }
    }

/* If none of the tests found a K_{3,3}, then we return OK to indicate that nothing
    went wrong, but a K_{3,3} was not found. */

    return OK;
}

/****************************************************************************
 _SearchForMinorE1()
 Search along the external face below the x-y path for a vertex Z other
 than W that is future pertinent or pertinent.
 ****************************************************************************/

int _SearchForMinorE1(graphP theGraph)
{
int  Z=theGraph->IC.px, ZPrevLink=1;

     Z = _GetNeighborOnExtFace(theGraph, Z, &ZPrevLink);

     while (Z != theGraph->IC.py)
     {
         if (Z != theGraph->IC.w)
         {
        	gp_UpdateVertexFuturePertinentChild(theGraph, Z, theGraph->IC.v);
            if (FUTUREPERTINENT(theGraph, Z, theGraph->IC.v))
            {
                theGraph->IC.z = Z;
                theGraph->IC.uz = _GetLeastAncestorConnection(theGraph, Z);
                return OK;
            }
            else if (PERTINENT(theGraph, Z))
            {
                /* Swap the roles of W and Z */

                theGraph->IC.z = theGraph->IC.w;
                theGraph->IC.w = Z;

                /* If the new W (indicated by Z) was on the path (R, X, old W) then
                    the new Z (the old W, which has no type mark) is on the path
                    (X, new W, new Z, Y) so we change the type new Z to being on the
                    RYW path. Otherwise, the order is (X, new Z, new W, Y), so the
                    new Z (old W with no type) is type changed to be on the RXW path.*/

                if (gp_GetVertexObstructionType(theGraph, Z) == VERTEX_OBSTRUCTIONTYPE_LOW_RXW)
                     gp_ResetVertexObstructionType(theGraph, theGraph->IC.z, VERTEX_OBSTRUCTIONTYPE_LOW_RYW);
                else gp_ResetVertexObstructionType(theGraph, theGraph->IC.z, VERTEX_OBSTRUCTIONTYPE_LOW_RXW);

                /* For completeness, we change the new W to type unknown */

                gp_ClearVertexObstructionType(theGraph, theGraph->IC.w);

                /* The external activity ancestor connection of the new Z must be obtained */

                theGraph->IC.uz = _GetLeastAncestorConnection(theGraph, theGraph->IC.z);

                return OK;
            }
         }

         Z = _GetNeighborOnExtFace(theGraph, Z, &ZPrevLink);
     }

     return OK;
}

/****************************************************************************
 _FinishIsolatorContextInitialization()
 Once it has been decided that a desired subgraph can be isolated, it
 becomes safe to finish the isolator context initialization.
 ****************************************************************************/

int  _FinishIsolatorContextInitialization(graphP theGraph, K33SearchContext *context)
{
isolatorContextP IC = &theGraph->IC;

/* Restore the orientation of the bicomp on which we're working, then
    perform orientation of all vertices in graph. (An unnecessary but
    polite step that simplifies the description of key states of the
    data structures). */

     if (_OrientVerticesInBicomp(theGraph, IC->r, 1) != OK)
    	 return NOTOK;

     if (_OrientVerticesInEmbedding(theGraph) != OK)
    	 return NOTOK;

/* Restore any paths that were reduced to single edges */

     if (_RestoreAndOrientReducedPaths(theGraph, context) != OK)
         return NOTOK;

/* We assume that the current bicomp has been marked appropriately,
     but we must now clear the visitation flags of all other bicomps. */

     if (_ClearVisitedFlagsInOtherBicomps(theGraph, IC->r) != OK)
    	 return NOTOK;

/* To complete the normal behavior of _ClearVisitedFlags() in the
    normal isolator context initialization, we also have to clear
    the visited flags on all edges that have not yet been embedded */

     _ClearVisitedFlagsInUnembeddedEdges(theGraph);

/* Now we can find the descendant ends of unembedded back edges based on
     the ancestor settings ux, uy and uz. */

     if (_FindExternalConnectionDescendantEndpoint(theGraph, IC->ux, IC->x, &IC->dx) != OK ||
         _FindExternalConnectionDescendantEndpoint(theGraph, IC->uy, IC->y, &IC->dy) != OK ||
         _FindExternalConnectionDescendantEndpoint(theGraph, IC->uz, IC->z, &IC->dz) != OK)
         return NOTOK;

/* Finally, we obtain the descendant end of an unembedded back edge to
     the current vertex. */

     if (_FindUnembeddedEdgeToCurVertex(theGraph, IC->w, &IC->dw) != TRUE)
         return NOTOK;

     return OK;
}

/****************************************************************************
 _Fast_GetLeastAncestorConnection()

 This function searches for an ancestor of the current vertex v adjacent by a
 cycle edge to the given cutVertex or one of its DFS descendants appearing in
 a separated bicomp. The given cutVertex is assumed to be future pertinent
 such that either the leastAncestor or the lowpoint of a separated DFS child
 is less than v.  We obtain the minimum possible connection from the cutVertex
 to an ancestor of v.

 This function performs the same operation as _GetLeastAncestorConnection(),
 except in constant time.
 ****************************************************************************/

int  _Fast_GetLeastAncestorConnection(graphP theGraph, K33SearchContext *context, int cutVertex)
{
	int ancestor = gp_GetVertexLeastAncestor(theGraph, cutVertex);
	int child = context->VI[cutVertex].separatedDFSChildList;

	if (gp_IsVertex(child) && ancestor > gp_GetVertexLowpoint(theGraph, child))
		ancestor = gp_GetVertexLowpoint(theGraph, child);

    return ancestor;
}

/****************************************************************************
 _GetAdjacentAncestorInRange()
 Returns the ancestor of theVertex that is adjacent to theVertex by an
 unembedded back edge and has a DFI strictly between closerAncestor and
 fartherAncestor.
 Returns NIL if theVertex has no such neighboring ancestor.
 ****************************************************************************/

int _GetAdjacentAncestorInRange(graphP theGraph, K33SearchContext *context, int theVertex,
                                int closerAncestor, int fartherAncestor)
{
int e = context->VI[theVertex].backArcList;

    while (gp_IsArc(e))
    {
        if (gp_GetNeighbor(theGraph, e) < closerAncestor &&
            gp_GetNeighbor(theGraph, e) > fartherAncestor)
            return gp_GetNeighbor(theGraph, e);

        e = gp_GetNextArc(theGraph, e);
        if (e == context->VI[theVertex].backArcList)
            e = NIL;
    }
    return NIL;
}

/****************************************************************************
 _SearchForDescendantExternalConnection()
 Search the cutVertex and each separated child subtree for an external
 connection to a vertex ancestor to the current vertex V and descendant to u_max.

 The function returns the descendant of u_max found to have an external
 connection to the given cut vertex.
 ****************************************************************************/

int  _SearchForDescendantExternalConnection(graphP theGraph, K33SearchContext *context, int cutVertex, int u_max)
{
isolatorContextP IC = &theGraph->IC;
int  u2 = _GetAdjacentAncestorInRange(theGraph, context, cutVertex, IC->v, u_max);
int  child, descendant;

	 // Test cutVertex for an external connection to descendant of u_max via direct back edge
     if (gp_IsVertex(u2))
         return u2;

     // If there is no direct back edge connection from the cut vertex
     // to a vertex on the path between V and u_max, then we will
     // look for such a connection in the DFS subtrees rooted by
     // separated DFS children of the vertex (ignoring those whose
     // lowpoint indicates that they make no external connections)

     // Begin by pushing the separated DFS children of the cut vertex with
     // lowpoints indicating connections to ancestors of the current vertex.
     sp_ClearStack(theGraph->theStack);
     child = gp_GetVertexSortedDFSChildList(theGraph, cutVertex);
     while (gp_IsVertex(child))
     {
         if (gp_GetVertexLowpoint(theGraph, child) < IC->v && gp_IsSeparatedDFSChild(theGraph, child))
        	 sp_Push(theGraph->theStack, child);
         child = gp_GetVertexNextDFSChild(theGraph, cutVertex, child);
     }

     // Now process the stack until it is empty or until we've found the desired connection.
     while (!sp_IsEmpty(theGraph->theStack))
     {
         sp_Pop(theGraph->theStack, descendant);

         // If the vertex has a lowpoint indicating that it makes no external connections,
         // then skip the subtree rooted by the vertex
         if (gp_GetVertexLowpoint(theGraph, descendant) < IC->v)
         {
			 // Check the subtree root for the desired connection.
			 u2 = _GetAdjacentAncestorInRange(theGraph, context, descendant, IC->v, u_max);
			 if (gp_IsVertex(u2))
				 return u2;

			 // Push each child as a new subtree root to be considered, except skip those whose lowpoint is too great.
			 child = gp_GetVertexSortedDFSChildList(theGraph, descendant);
			 while (gp_IsVertex(child))
			 {
				 if (gp_GetVertexLowpoint(theGraph, child) < IC->v)
					 sp_Push(theGraph->theStack, child);

				 child = gp_GetVertexNextDFSChild(theGraph, descendant, child);
			 }
         }
     }

     // The only external connections from the cutVertex lead to u_max, so return it.
     return u_max;
}

/****************************************************************************
 _FindExternalConnectionDescendantEndpoint()

 This operation is similar to _FindUnembeddedEdgeToAncestor() except that
 we need to be more precise in this case, finding an external connection
 from a given cut vertex to a *particular* given ancestor.

 NOTE: By external we don't mean externall active so much as not embedded in
       the bicomp containing the cut vertex.

 Returns OK if it finds that either the given cutVertex or one of its
    descendants in a separated bicomp has an unembedded back edge
    connection to the given ancestor vertex.
 Returns NOTOK otherwise (it is an error to not find the descendant because
    this function is only called if _SearchForDescendantExternalConnection()
    has already determined the existence of the descendant).
 ****************************************************************************/

int  _FindExternalConnectionDescendantEndpoint(graphP theGraph, int ancestor,
                                               int cutVertex, int *pDescendant)
{
int  child, e;

     // Check whether the cutVertex is directly adjacent to the ancestor
     // by an unembedded back edge.

     e = gp_GetVertexFwdArcList(theGraph, ancestor);
     while (gp_IsArc(e))
     {
         if (gp_GetNeighbor(theGraph, e) == cutVertex)
         {
             *pDescendant = cutVertex;
             return OK;
         }

         e = gp_GetNextArc(theGraph, e);
         if (e == gp_GetVertexFwdArcList(theGraph, ancestor))
             e = NIL;
     }

     // Now check the descendants of the cut vertex to see if any make
     // a connection to the ancestor.
     child = gp_GetVertexSortedDFSChildList(theGraph, cutVertex);
     while (gp_IsVertex(child))
     {
         if (gp_GetVertexLowpoint(theGraph, child) < theGraph->IC.v && gp_IsSeparatedDFSChild(theGraph, child))
         {
			 if (_FindUnembeddedEdgeToSubtree(theGraph, ancestor, child, pDescendant) == TRUE)
				 return OK;
         }
         child = gp_GetVertexNextDFSChild(theGraph, cutVertex, child);
     }

     return NOTOK;
}

/****************************************************************************
 _SearchForMergeBlocker()

 This function helps to implement the merge blocking optimization of
 _SearchForDescendantExternalConnection().  The function RunExtraK33Tests()
 sets a mergeBlocker rather than run _SearchForDescendantExternalConnection()
 in certain cases.  This procedure is called by MergeBicomps to test the
 embedding stack for a merge blocker before merging any biconnected components.
 If a merge blocker is found, then FindK33WithMergeBlocker() is called and
 ultimately the embedder's Walkdown function is terminated since a K_{3,3}
 is isolated.

 Returns OK on success (whether or not the search found a merge blocker)
         NOTOK on internal function failure
         pMergeBlocker is set to NIL unless a merge blocker is found.
 ****************************************************************************/

int  _SearchForMergeBlocker(graphP theGraph, K33SearchContext *context, int v, int *pMergeBlocker)
{
stackP tempStack;
int  R, Rout, Z, ZPrevLink;

/* Set return result to 'not found' then return if there is no stack to inspect */

     *pMergeBlocker = NIL;

     if (sp_IsEmpty(theGraph->theStack))
         return OK;

/* Create a copy of the embedding stack */

     tempStack = sp_Duplicate(theGraph->theStack);
     if (tempStack == NULL)
         return NOTOK;

/* Search the copy of the embedding stack for a merge blocked vertex */

     while (!sp_IsEmpty(tempStack))
     {
         sp_Pop2(tempStack, R, Rout);
         sp_Pop2(tempStack, Z, ZPrevLink);

         if (gp_IsVertex(context->VI[Z].mergeBlocker) &&
             context->VI[Z].mergeBlocker < v)
         {
             *pMergeBlocker = Z;
             break;
         }
     }

     sp_Free(&tempStack);
     return OK;
}

/****************************************************************************
 _FindK33WithMergeBlocker()

 This function completes the merge blocking optimization by isolating a K_{3,3}
 based on minor E3 if a merge blocked vertex was previously found.

 Returns OK on success, NOTOK on internal function failure
 ****************************************************************************/

int  _FindK33WithMergeBlocker(graphP theGraph, K33SearchContext *context, int v, int mergeBlocker)
{
int  R, RPrevLink, u_max, u, e, W;
isolatorContextP IC = &theGraph->IC;

/* First, we orient the vertices so we can successfully restore all of the
    reduced paths.  This needs to be done before reconstructing the context
    for CASE 3 of RunExtraK33Tests() because the reconstruction involves
    using the Walkup to v from a descendant of v, which will not work if
    the descendant is in one of the reduced paths. */

     if (_OrientVerticesInEmbedding(theGraph) != OK ||
    	 _RestoreAndOrientReducedPaths(theGraph, context) != OK)
         return NOTOK;

/* Reconstruct the context that was present for CASE 3 of RunExtraK33Tests()
        when we decided to set a mergeBlocker rather than calling
        _SearchForDescendantExternalConnection() */

     /* Obtain the root of the bicomp containing the mergeBlocker. */

     RPrevLink = 1;
     R = mergeBlocker;
     while (gp_IsNotVirtualVertex(theGraph, R))
        R = _GetNeighborOnExtFace(theGraph, R, &RPrevLink);

     /* Switch the 'current step' variable v to be equal to the
       non-virtual counterpart of the bicomp root. */

     IC->v = gp_GetPrimaryVertexFromRoot(theGraph, R);

     /* Reinitialize the visitation, pertinence and future pertinence settings from step u_max for step v */

     for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
     {
    	 gp_SetVertexVisitedInfo(theGraph, v, theGraph->N);
         gp_SetVertexPertinentEdge(theGraph, v, NIL);
         gp_SetVertexPertinentRootsList(theGraph, v, NIL);

         // Any calls to actually determine FUTUREPERTINENT status for a vertex w will actually invoke
         // gp_UpdateVertexFuturePertinentChild(theGraph, w, v) beforehand, so only need to reinitialize here
         gp_SetVertexFuturePertinentChild(theGraph, v, gp_GetVertexSortedDFSChildList(theGraph, v));
     }

     /* Restore the pertinence settings of step v by doing the Walkup for each
        back edge that was not embedded when step v was originally performed. */

     e = gp_GetVertexFwdArcList(theGraph, IC->v);
     while (gp_IsArc(e))
     {
        W = gp_GetNeighbor(theGraph, e);
        theGraph->functions.fpWalkUp(theGraph, IC->v, e);

        e = gp_GetNextArc(theGraph, e);
        if (e == gp_GetVertexFwdArcList(theGraph, IC->v))
            e = NIL;
     }

/* Next, we make the standard initialization calls for when we have found
     a non-planarity condition. */

     sp_ClearStack(theGraph->theStack);

     if (_ChooseTypeOfNonplanarityMinor(theGraph, IC->v, R) != OK)
         return NOTOK;

     IC->ux = _GetLeastAncestorConnection(theGraph, IC->x);
     IC->uy = _GetLeastAncestorConnection(theGraph, IC->y);
     IC->uz = _GetLeastAncestorConnection(theGraph, IC->z);

     u_max = MAX3(IC->ux,IC->uy,IC->uz);

/* Perform the remainder of CASE 3 of RunExtraK33Tests() */

     if (mergeBlocker == IC->x)
     {
         u = _SearchForDescendantExternalConnection(theGraph, context, IC->x, u_max);
         if (u > u_max)
         {
             IC->ux = u;
             if (_FinishIsolatorContextInitialization(theGraph, context) != OK ||
                 _IsolateMinorE3(theGraph) != OK)
                 return NOTOK;
         }
         else return NOTOK;
     }
     else if (mergeBlocker == IC->y)
     {
         u = _SearchForDescendantExternalConnection(theGraph, context, IC->y, u_max);
         if (u > u_max)
         {
             IC->uy = u;
             if (_FinishIsolatorContextInitialization(theGraph, context) != OK ||
                 _IsolateMinorE3(theGraph) != OK)
                 return NOTOK;
         }
         else return NOTOK;
     }
     else return NOTOK;

/* Do the final clean-up to obtain the K_{3,3} */

     if (_DeleteUnmarkedVerticesAndEdges(theGraph) != OK)
         return NOTOK;

     return OK;
}

/****************************************************************************
 _TestForLowXYPath()
 Is there an x-y path that does not include X?
 If not, is there an x-y path that does not include Y?
 If not, then we restore the original x-y path.
 If such a low x-y path exists, then we adjust px or py accordingly,
    and we make sure that X or Y (whichever is excluded) and its edges are
    not marked visited.
 This method uses the stack, though it is called with an empty stack currently,
 it does happen to preserve any preceding stack content. This method pushes
 at most one integer per edge incident to the bicomp root plus two integers
 per vertex in the bicomp.
 ****************************************************************************/

int  _TestForLowXYPath(graphP theGraph)
{
isolatorContextP IC = &theGraph->IC;
int  result;
int  stackBottom;

/* Clear the previously marked X-Y path */

     if (_ClearVisitedFlagsInBicomp(theGraph, IC->r) != OK)
    	 return NOTOK;

/* Save the size of the stack before hiding any edges, so we will know
   how many edges to restore */

     stackBottom = sp_GetCurrentSize(theGraph->theStack);

/* Hide the internal edges of X */

     if (_HideInternalEdges(theGraph, IC->x) != OK)
    	 return NOTOK;

/* Try to find a low X-Y path that excludes X, then restore the
    internal edges of X. */

     result = _MarkHighestXYPath(theGraph);
     if (_RestoreInternalEdges(theGraph, stackBottom) != OK)
    	 return NOTOK;

/* If we found the low X-Y path, then return. */

     if (result == TRUE)
         return OK;

/* Hide the internal edges of Y */

     if (_HideInternalEdges(theGraph, IC->y) != OK)
    	 return NOTOK;

/* Try to find a low X-Y path that excludes Y, then restore the
    internal edges of Y. */

     result = _MarkHighestXYPath(theGraph);
     if (_RestoreInternalEdges(theGraph, stackBottom) != OK)
    	 return NOTOK;

/* If we found the low X-Y path, then return. */

     if (result == TRUE)
         return OK;

/* Restore the original X-Y path and return with no error
        (the search failure is reflected by no change to px and py */

     if (_MarkHighestXYPath(theGraph) != TRUE)
    	 return NOTOK;

     return OK;
}

/****************************************************************************
 _TestForZtoWPath()
 This function tests whether there is a path inside the bicomp leading from W
 to some internal node of the x-y path.  If there is, the path is marked (the
 visited flags of its vertices and edges are set).

 Upon function return, the marking (visited flag setting) of W distinguishes
 whether the path was found.

 The function returns NOTOK on internal error, OK otherwise.

 Preconditions: All internal vertices have an obstruction type setting of
 unknown, as do W and the bicomp root.  There is an X-Y path marked visited.
 So, we start a depth first search from W to find a visited vertex, except
 we prune the search to ignore vertices whose obstruction type is other than
 unknown.  This ensures the path found, if any, avoids external face vertices,
 including avoiding X and Y. Furthermore, the path search is completed without
 traversing to R due to the obstructing X-Y path.

 The depth first search has to "mark" the vertices it has seen as visited,
 but the visited flags are already in use to distinguish the X-Y path.
 So, we reuse the visitedInfo setting of each vertex. The core planarity
 algorithm makes settings between 0 and N, so we will regard all of those
 as indicating 'unvisited' by this method, and use -1 to indicate visited.
 These markings need not be cleaned up because, if the desired path is found
 the a K_{3,3} is isolated and if the desired path is not found then the
 bicomp is reduced and the visitedInfo in the remaining vertices are set
 appropriately for future Walkup processing of the core planarity algorithm.

 For each vertex we visit, if it is an internal vertex on the X-Y path
 (i.e. visited flag set and obstruction type unknown), then we want to stop
 and unroll the stack to obtain the desired path (described below). If the
 vertex is internal but not on the X-Y path (i.e. visited flag clear and
 obstruction type unknown), then we want to visit its neighbors, except
 those already marked visited by this method (i.e. those with visitedInfo
 of -1) and those with a known obstruction type.

 We want to manage the stack so that it when the desired vertex is found,
 the stack contains the desired path.  So, we do not simply push all the
 neighbors of the vertex being visited.  First, given that we have popped
 some vertex-edge pair (v, e), we push *only* the next edge after e in
 v's adjacency list (starting with the first if e is NIL) that leads to a
 new 'eligible' vertex.  An eligible vertex is one whose obstruction type
 is unknown and whose visitedInfo is other than -1 (so, internal and not
 yet processed by this method). Second, when we decide a new vertex w
 adjacent to v is eligible, we push not only (v, e) but also (w, NIL).
 When we later pop the vertex-edge pair containing NIL, we know that
 the vertex obstruction type is unknown so we test whether its visited
 flag is set (indicating an internal vertex on the X-Y path).  If so, then
 we can stop the depth first search, then use the vertices and edges
 remaining on the stack to mark the desired path from the external face
 vertex W to an internal vertex Z on the X-Y path.

 If we pop (v, NIL) and find that the visited flag of v is clear, then it
 is not the desired connection endpoint to the X-Y path.  We need to process
 all paths extending from it, but we don't want any of those paths to cycle
 back to this vertex, so we mark it as ineligible by putting -1 in its
 visitedInfo member.  This is also the case in which the _first_ edge record e
 leading from v to an eligible vertex w is obtained, whereupon we push both
 (v, e) and (w, NIL).  Eventually all paths leading from w to eligible
 vertices will be explored, and if none find the desired vertex connection
 to the X-Y path, then (v, e) is popped.  Now we search the adjacency list of
 v starting after e to find the _next_ edge record that indicates the an
 eligible vertex to visit.  None of the vertices processed while visiting paths
 extending from w will be eligible anymore, so it can be seen that this method
 is a depth first search. If no remaining edges from v indicate eligible
 vertices, then nothing is pushed and we simply go to the next iteration,
 which pops a 2-tuple containing the vertex u and the edge record e that
 points to v.  Finally, if the stack empties without finding the desired vertex,
 then the first loop ends, and the second main loop does not mark a path because
 the stack is empty.
 ****************************************************************************/

int  _TestForZtoWPath(graphP theGraph)
{
isolatorContextP IC = &theGraph->IC;
int  v, e, w;

     sp_ClearStack(theGraph->theStack);
     sp_Push2(theGraph->theStack, IC->w, NIL);

     while (!sp_IsEmpty(theGraph->theStack))
     {
          sp_Pop2(theGraph->theStack, v, e);

          if (gp_IsNotArc(e))
          {
        	  // If the vertex is visited, then it is a member of the X-Y path
        	  // Because it is being popped, its obstruction type is unknown because
        	  // that is the only kind of vertex pushed.
        	  // Hence, we break because we've found the desired path.
              if (gp_GetVertexVisited(theGraph, v))
                  break;

              // Mark this vertex as being visited by this method (i.e. ineligible
              // to have processing started on it again)
              gp_SetVertexVisitedInfo(theGraph, v, -1);

              e = gp_GetFirstArc(theGraph, v);
          }
          else
              e = gp_GetNextArc(theGraph, e);

          // This while loop breaks on the first edge it finds that is eligible to be
          // pushed.  Once that happens, we break. The successive edges of a vertex are
          // only pushed (see the else clause above) once all paths extending from v
          // through e have been explored and found not to contain the desired path
          while (gp_IsArc(e))
          {
              w = gp_GetNeighbor(theGraph, e);

              // The test for w being a virtual vertex is just safeguarding the two subsequent calls,
              // but it can never happen due to the obstructing X-Y path.
              if (gp_IsNotVirtualVertex(theGraph, w) &&
            	  gp_GetVertexVisitedInfo(theGraph, w) != -1 &&
                  gp_GetVertexObstructionType(theGraph, w) == VERTEX_OBSTRUCTIONTYPE_UNKNOWN)
              {
                  sp_Push2(theGraph->theStack, v, e);
                  sp_Push2(theGraph->theStack, w, NIL);

                  break;
              }

              e = gp_GetNextArc(theGraph, e);
          }
     }

     while (!sp_IsEmpty(theGraph->theStack))
     {
         sp_Pop2(theGraph->theStack, v, e);
         gp_SetVertexVisited(theGraph, v);
         gp_SetEdgeVisited(theGraph, e);
         gp_SetEdgeVisited(theGraph, gp_GetTwinArc(theGraph, e));
     }

     return OK;
}

/****************************************************************************
 _TestForStraddlingBridge()
 We proceed on the path [V...u_{max}) from the current vertex V up to and
 excluding u_{max}.  For each vertex p, we test whether p has a least
 ancestor less than u_{max} and whether p has a DFS child c that is not an
 ancestor of X, Y and W and that has a connection to an ancestor of u_{max}
 (in other words, whether the child C has a lowpoint less than u_{max}).

 The sortedDFSChildLIst of the vertex p is scanned for the separated DFS
 child c of least lowpoint, excluding the ancestor of X, Y and W.

 If no bridge straddling u_{max} is found, the function returns NIL.
 If a straddling bridge is found, the function returns a descendant d
 of p in the subtree rooted by c such that d has a leastAncestor less
 than u_{max}.  Given the vertex d, the path through the straddling
 bridge required in Minors E6 and E7 is easy to identify:  Mark the
 DFS tree path from d to p, and add and mark the edge from d to its
 least ancestor.

 OPTIMIZATION: If a straddling bridge is not found, then in each tree edge of
        the path [V...u_{max}) we set the member noStraddle equal to u_{max}.
        Then, we modify the above stated routine so that if it is testing
        for a straddling bridge of u_{max} along this path, it will stop
        if it encounters an edge with noStraddle equal to u_{max}.
        Also, the optimization will only set noStraddle equal to
        u_{max} on the portion of the path that is traversed.  Finally, if
        noStraddle is set to a value other than NIL, the setting will be
        ignored and it will not be changed.

        Due to this optimization, we do not traverse a path more than once
        to find out whether a vertex on the path has a bridge that straddles
        u_{max}.  This leaves two questions:
            1) What if a future step must determine whether there is a
                straddling bridge of an ancestor of u_{max}?
            2) What if a future step must determine whether there is a
                straddling bridge of a descendant of u_{max}?

        The condition described in the first question cannot occur because it
        would imply the ability to detect a straddling bridge now.
        The condition described by the second question may occur, but in the
        future step, the bicomp now being tested for a K_{3,3} will be part of
        a straddling bridge in that future step.  Thus, the straddling
        bridge query is asked at most twice along any DFS tree path.
 ****************************************************************************/

int  _TestForStraddlingBridge(graphP theGraph, K33SearchContext *context, int u_max)
{
isolatorContextP IC = &theGraph->IC;
int  p, c, d, excludedChild, e;

     p = IC->v;
     excludedChild = gp_GetDFSChildFromRoot(theGraph, IC->r);
     d = NIL;

     // Starting at V, traverse the ancestor path to u_max looking for a straddling bridge
     while (p > u_max)
     {
         // If we find a direct edge from p to an ancestor of u_max, the break.
         if (gp_GetVertexLeastAncestor(theGraph, p) < u_max)
         {
             d = p;
             break;
         }

         // Check for a path from p to an ancestor of u_max using the child of p
         // with the least Lowpoint, except the child that is an ancestor of X, Y and W.
         // It is possible to do this just using the sortedDFSChildList, but no point
         // in not using the separatedDFSChildList
         /*
         {
         int c = gp_GetVertexSortedDFSChildList(theGraph, p);
         while (gp_IsVertex(c))
         {
        	 if (c != excludedChild && gp_IsSeparatedDFSChild(theGraph, c))
        	 {
        		 if (gp_GetVertexLowpoint(theGraph, c) < u_max)
        			 break;
        	 }

             c = gp_GetVertexNextDFSChild(theGraph, p, c);
         }
         }
         */
      	 c = context->VI[p].separatedDFSChildList;
      	 if (c == excludedChild)
      		 c = LCGetNext(context->separatedDFSChildLists, c, c);

         if (gp_IsVertex(c) && gp_GetVertexLowpoint(theGraph, c) < u_max)
         {
             _FindUnembeddedEdgeToSubtree(theGraph, gp_GetVertexLowpoint(theGraph, c), c, &d);
             break;
         }

         // Check for noStraddle of u_max, break if found
         e = gp_GetFirstArc(theGraph, p);
         if (context->E[e].noStraddle == u_max)
             break;

         // Go to the next ancestor
         excludedChild = p;
         p = gp_GetVertexParent(theGraph, p);
     }

     // If d is NIL, then no straddling bridge was found, so we do the noStraddle optimization.
     if (gp_IsNotVertex(d))
     {
         c = IC->v;
         while (c != p)
         {
             e = gp_GetFirstArc(theGraph, c);
             if (gp_IsVertex(context->E[e].noStraddle))
                 break;

             context->E[e].noStraddle = u_max;

             c = gp_GetVertexParent(theGraph, c);
         }
     }

     // Return either NIL indicating no bridge straddling u_max or the descendant d
     // used to help mark a straddling bridge that was found by this test.
     return d;
}

/****************************************************************************
 _ReduceBicomp()

 We want to reduce the given biconnected component to a 4-cycle plus an
 internal edge connecting X and Y.  Each edge is to be associated with a
 path from the original graph, preserving the depth first search tree
 paths that help connect the vertices R, X, Y, and W.  If a K_{3,3} is later found,
 the paths are restored, but it is necessary to preserve the DFS tree so that
 functions like MarkDFSPath() will be able to pass through the restored bicomp.
 Also, if a K_{3,3} is later found due to the merge blocker optimization, then the
 internal X-Y path may be needed and, once the bicomp reduction is reversed,
 a full DFS subtree connecting all vertices in the bicomp will need to be
 restored or else functions that traverse the bicomp will not work.

 For example, _FindK33WithMergeBlocker() invokes ChooseTypeOfNonplanarityMinor()
 to help reconstruct the context under which the mergeBlocker was set.
 ChooseTypeOfNonplanarityMinor() calls _ClearVisitedFlagsInBicomp(), which
 depends on the DFS tree.

 NOTE: The following are some general steps taken in this method:
       1) All edges in the bicomp are marked unvisited
       2) selected paths are marked visited
       3) unvisited edges are deleted
       4) the edges of the bicomp are marked unvisited again
       5) the remaining paths of the bicomp are reduced
       Some of the edges that get deleted in step 3 above may represent
       paths that were reduced in prior embedder iterations.  We delete
       the reduction edge but not the path it represents.
       If a K_{3,3} is ever found, then the edges of these reduced paths
       are still in the graph, though not connected to anything important.
       The desired K_{3,3} is marked visited, but step 4 above ensures that
       these reduction paths are not marked visited. Hence, they will be
       deleted when the K_{3,3} is isolated, and this routine does not
       need to restore any reduced paths on the edges it deletes.
       We also don't (and don't have the time to) restore any reduction
       edges along the paths we intend to keep.
 ****************************************************************************/

int  _ReduceBicomp(graphP theGraph, K33SearchContext *context, int R)
{
isolatorContextP IC = &theGraph->IC;
int  min, mid, max, A, A_edge, B, B_edge;
int  rxType, xwType, wyType, yrType, xyType;

/* The vertices in the bicomp need to be oriented so that functions
    like MarkPathAlongBicompExtFace() will work. */

     if (_OrientVerticesInBicomp(theGraph, R, 0) != OK)
    	 return NOTOK;

/* The reduced edges start with a default type of 'tree' edge. The
     tests below, which identify the additional non-tree paths
     needed to complete the reduced bicomp, also identify which
     reduced edges need to be cycle edges.*/

     rxType = xwType = wyType = yrType = xyType = EDGE_TYPE_PARENT;

/* Now we calculate some values that help figure out the shape of the
    DFS subtree whose structure will be retained in the bicomp. */

     min = MIN3(IC->x, IC->y, IC->w);
     max = MAX3(IC->x, IC->y, IC->w);
     mid = MAX3(MIN(IC->x, IC->y), MIN(IC->x, IC->w), MIN(IC->y, IC->w));

/* If the order of descendendancy from V goes first to X, then it can
    proceed either to W then Y or to Y then W */

     if (min == IC->x)
     {
         /* A is a descendant adjacent to the current vertex by a cycle edge
            whose DFS tree path to either mid or max is combined with the
            cycle edge to form the path that will be reduced to the
            external face cycle edge (V, max). */

         A_edge = gp_GetLastArc(theGraph, IC->r);
         A = gp_GetNeighbor(theGraph, A_edge);
         yrType = EDGE_TYPE_BACK;

         /* If Y is max, then a path parallel to the X-Y path will be a
            second path reduced to a cycle edge.  We find the neighbor B
            of min=X on the X-Y path.  The edge (B, min) is a cycle edge
            that, along with the DFS tree path (B, ..., max), will be
            retained and reduced to a cycle edge. */

         if (max == IC->y)
         {
             B_edge = gp_GetLastArc(theGraph, IC->x);
             while (B_edge != gp_GetFirstArc(theGraph, IC->x))
             {
                 if (gp_GetEdgeVisited(theGraph, B_edge)) break;
                 B_edge = gp_GetPrevArc(theGraph, B_edge);
             }

             if (!gp_GetEdgeVisited(theGraph, B_edge))
                 return NOTOK;

             B = gp_GetNeighbor(theGraph, B_edge);
             xyType = EDGE_TYPE_BACK;
         }

         /* Otherwise, W is max so we find the neighbor B of min=X on the
            lower external face path (X, ..., W), which excludes V.  The
            cycle edge (B, min) and the DFS tree path (B, max) will be
            retained and reduced to a cycle edge.*/

         else if (max == IC->w)
         {
             B_edge = gp_GetFirstArc(theGraph, IC->x);
             B = gp_GetNeighbor(theGraph, B_edge);
             xwType = EDGE_TYPE_BACK;
         }

         else return NOTOK;
     }

/* Otherwise, the order of descendancy from V goes first to Y, then it
     proceeds to either W then X or to X then W. The */

     else
     {
         A_edge = gp_GetFirstArc(theGraph, IC->r);
         A = gp_GetNeighbor(theGraph, A_edge);
         rxType = EDGE_TYPE_BACK;

         if (max == IC->x)
         {
             B_edge = gp_GetFirstArc(theGraph, IC->y);
             while (B_edge != gp_GetLastArc(theGraph, IC->y))
             {
                 if (gp_GetEdgeVisited(theGraph, B_edge)) break;
                 B_edge = gp_GetNextArc(theGraph, B_edge);
             }

             if (!gp_GetEdgeVisited(theGraph, B_edge))
                 return NOTOK;

             B = gp_GetNeighbor(theGraph, B_edge);
             xyType = EDGE_TYPE_BACK;
         }

         else if (max == IC->w)
         {
             B_edge = gp_GetLastArc(theGraph, IC->y);
             B = gp_GetNeighbor(theGraph, B_edge);
             wyType = EDGE_TYPE_BACK;
         }

         else return NOTOK;
     }

/* Now that we have collected the information on which cycle edge and
    which tree paths will actually be retained, we clear the visited
    flags so the current X-Y path will not be retained (an X-Y path
    formed mostly or entirely from DFS tree edges is retained). */

     if (_ClearVisitedFlagsInBicomp(theGraph, R) != OK)
    	 return NOTOK;

/* Now we mark the tree path from the maximum numbered vertex up
      to the bicomp root. This marks one of the following four paths:
      Case 1. (V, ..., X=min, ..., W=mid, ..., Y=max)
      Case 2. (V, ..., X=min, ..., Y=mid, ..., W=max)
      Case 3. (V, ..., Y=min, ..., W=mid, ..., X=max)
      Case 4. (V, ..., Y=min, ..., X=mid, ..., W=max) */

     if (theGraph->functions.fpMarkDFSPath(theGraph, R, max) != OK)
         return NOTOK;

/* Now we use A to mark a path on the external face corresponding to:
      Case 1. (V, ..., Y=max)
      Case 2. (V, ..., Y=mid)
      Case 3. (V, ..., X=max)
      Case 4. (V, ..., X=mid) */

     if (theGraph->functions.fpMarkDFSPath(theGraph, min==IC->x ? IC->y : IC->x, A) != OK)
         return NOTOK;

     gp_SetEdgeVisited(theGraph, A_edge);
     gp_SetEdgeVisited(theGraph, gp_GetTwinArc(theGraph, A_edge));

/* Now we use B to mark either an X-Y path or a path of the external face
      corresponding to:
      Case 1. (X=min, ..., B, ..., Y=max)
      Case 2. (X=min, ..., B, ..., W=max)
      Case 3. (Y=min, ..., B, ..., X=max)
      Case 4. (Y=min, ..., B, ..., W=max) */

     if (theGraph->functions.fpMarkDFSPath(theGraph, max, B) != OK)
         return NOTOK;

     gp_SetEdgeVisited(theGraph, B_edge);
     gp_SetEdgeVisited(theGraph, gp_GetTwinArc(theGraph, B_edge));

/* Delete the unmarked edges in the bicomp. Note that if an unmarked edge
 * represents a reduced path, then only the reduction edge is deleted here.
 * The path it represents is only deleted later (see NOTE above) */

     if (_K33Search_DeleteUnmarkedEdgesInBicomp(theGraph, context, R) != OK)
    	 return NOTOK;

/* Clear all visited flags in the bicomp.
     This is the important "step 4" mentioned in the NOTE above */

     if (_ClearVisitedFlagsInBicomp(theGraph, R) != OK)
    	 return NOTOK;

/* Clear all orientation signs in the bicomp.
	Note that the whole bicomp may not be properly oriented at this point
	because we may have exchanged external face paths for internal
	DFS tree paths.  However, the reduced bicomp will be properly
	oriented, and the paths of degree 2 vertices will have their
	orientations fixed if/when reduction edges are restored. */

     if (_ClearInvertedFlagsInBicomp(theGraph, R) != OK)
    	 return NOTOK;

/* Reduce the paths to single edges.
	 Note that although the whole bicomp may not be properly oriented at this
	 point (as noted above), the four principal vertices R, X, W and Y still
	 are consistently oriented with one another, e.g. R's link[0] indicates
	 the external face path toward X that excludes W and Y, and X's link[1]
	 indicates that same path. */

     if (_ReduceExternalFacePathToEdge(theGraph, context, R, IC->x, rxType) != OK ||
         _ReduceExternalFacePathToEdge(theGraph, context, IC->x, IC->w, xwType) != OK ||
         _ReduceExternalFacePathToEdge(theGraph, context, IC->w, IC->y, wyType) != OK ||
         _ReduceExternalFacePathToEdge(theGraph, context, IC->y, R, yrType) != OK)
         return NOTOK;

     if (_ReduceXYPathToEdge(theGraph, context, IC->x, IC->y, xyType) != OK)
         return NOTOK;

     return OK;
}

/********************************************************************
 Edge deletion that occurs during a reduction or restoration of a
 reduction is augmented by clearing the K_{3,3} search-specific
 data members.  This is augmentation is not needed in the delete edge
 operations that happen once a K_{3,3} homeomorph has been found and
 marked for isolation.
 ********************************************************************/

int  _K33Search_DeleteEdge(graphP theGraph, K33SearchContext *context, int e, int nextLink)
{
	_K33Search_InitEdgeRec(context, e);
	_K33Search_InitEdgeRec(context, gp_GetTwinArc(theGraph, e));

	return gp_DeleteEdge(theGraph, e, nextLink);
}

/********************************************************************
 _K33Search_DeleteUnmarkedEdgesInBicomp()

 This function deletes from a given biconnected component all edges
 whose visited member is zero.

 The stack is used but preserved. In debug mode, NOTOK can result if
 there is a stack overflow. This method pushes at most one integer
 per vertex in the bicomp.

 This is the same as _DeleteUnmarkedEdgesInBicomp(), except it calls
 the overloaded _K33_DeleteEdge() rather than gp_DeleteEdge()

 Returns OK on success, NOTOK on implementation failure
 ********************************************************************/

int  _K33Search_DeleteUnmarkedEdgesInBicomp(graphP theGraph, K33SearchContext *context, int BicompRoot)
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

             e = gp_GetEdgeVisited(theGraph, e)
            		 ? gp_GetNextArc(theGraph, e)
            		 : _K33Search_DeleteEdge(theGraph, context, e, 0);
          }
     }
     return OK;
}

/****************************************************************************
 _ReduceExternalFacePathToEdge()
 ****************************************************************************/

int  _ReduceExternalFacePathToEdge(graphP theGraph, K33SearchContext *context, int u, int x, int edgeType)
{
int  prevLink, v, w, e;

     /* If the path is a single edge, then no need for a reduction */

     prevLink = 1;
     v = _GetNeighborOnExtFace(theGraph, u, &prevLink);
     if (v == x)
     {
         gp_SetExtFaceVertex(theGraph, u, 0, x);
         gp_SetExtFaceVertex(theGraph, x, 1, u);
         return OK;
     }

     /* We have the endpoints u and x of the path, and we just computed the
        first vertex internal to the path and a neighbor of u.  Now we
        compute the vertex internal to the path and a neighbor of x. */

     prevLink = 0;
     w = _GetNeighborOnExtFace(theGraph, x, &prevLink);

     /* Delete the two edges that connect the path to the bicomp.
        If either edge is a reduction edge, then we have to restore
        the path it represents. We can only afford to visit the
        endpoints of the path.
        Note that in the restored path, the edge incident to each
        endpoint of the original path is a newly added edge,
        not a reduction edge. */

     e = gp_GetFirstArc(theGraph, u);
     if (gp_IsVertex(context->E[e].pathConnector))
     {
         if (_RestoreReducedPath(theGraph, context, e) != OK)
             return NOTOK;
         e = gp_GetFirstArc(theGraph, u);
         v = gp_GetNeighbor(theGraph, e);
     }
     _K33Search_DeleteEdge(theGraph, context, e, 0);

     e = gp_GetLastArc(theGraph, x);
     if (gp_IsVertex(context->E[e].pathConnector))
     {
         if (_RestoreReducedPath(theGraph, context, e) != OK)
             return NOTOK;
         e = gp_GetLastArc(theGraph, x);
         w = gp_GetNeighbor(theGraph, e);
     }
     _K33Search_DeleteEdge(theGraph, context, e, 0);

     /* Add the reduction edge, then set its path connectors so the original
        path can be recovered and set the edge type so the essential structure
        of the DFS tree can be maintained (The 'Do X to Bicomp' functions
        and functions like MarkDFSPath(0 depend on this). */

     gp_AddEdge(theGraph, u, 0, x, 1);

     e = gp_GetFirstArc(theGraph, u);
     context->E[e].pathConnector = v;
     gp_SetEdgeType(theGraph, e, _ComputeArcType(theGraph, u, x, edgeType));

     e = gp_GetLastArc(theGraph, x);
     context->E[e].pathConnector = w;
     gp_SetEdgeType(theGraph, e, _ComputeArcType(theGraph, x, u, edgeType));

     /* Set the external face info */

     gp_SetExtFaceVertex(theGraph, u, 0, x);
     gp_SetExtFaceVertex(theGraph, x, 1, u);

     return OK;
}

/****************************************************************************
 _ReduceXYPathToEdge()
 ****************************************************************************/

int  _ReduceXYPathToEdge(graphP theGraph, K33SearchContext *context, int u, int x, int edgeType)
{
int  e, v, w;

     e = gp_GetFirstArc(theGraph, u);
     e = gp_GetNextArc(theGraph, e);
     v = gp_GetNeighbor(theGraph, e);

     /* If the XY-path is a single edge, then no reduction is needed */

     if (v == x)
         return OK;

     /* Otherwise, remove the two edges that join the XY-path to the bicomp */

     if (gp_IsVertex(context->E[e].pathConnector))
     {
         if (_RestoreReducedPath(theGraph, context, e) != OK)
             return NOTOK;
         e = gp_GetFirstArc(theGraph, u);
         e = gp_GetNextArc(theGraph, e);
         v = gp_GetNeighbor(theGraph, e);
     }
     _K33Search_DeleteEdge(theGraph, context, e, 0);

     e = gp_GetFirstArc(theGraph, x);
     e = gp_GetNextArc(theGraph, e);
     w = gp_GetNeighbor(theGraph, e);
     if (gp_IsVertex(context->E[e].pathConnector))
     {
         if (_RestoreReducedPath(theGraph, context, e) != OK)
             return NOTOK;
         e = gp_GetFirstArc(theGraph, x);
         e = gp_GetNextArc(theGraph, e);
         w = gp_GetNeighbor(theGraph, e);
     }
     _K33Search_DeleteEdge(theGraph, context, e, 0);

     /* Now add a single edge to represent the XY-path */
     gp_InsertEdge(theGraph, u, gp_GetFirstArc(theGraph, u), 0,
    		                 x, gp_GetFirstArc(theGraph, x), 0);

     /* Now set up the path connectors so the original XY-path can be recovered if needed.
        Also, set the reduction edge's type to preserve the DFS tree structure */

     e = gp_GetFirstArc(theGraph, u);
     e = gp_GetNextArc(theGraph, e);
     context->E[e].pathConnector = v;
     gp_SetEdgeType(theGraph, e, _ComputeArcType(theGraph, u, x, edgeType));

     e = gp_GetFirstArc(theGraph, x);
     e = gp_GetNextArc(theGraph, e);
     context->E[e].pathConnector = w;
     gp_SetEdgeType(theGraph, e, _ComputeArcType(theGraph, x, u, edgeType));

     return OK;
}

/****************************************************************************
 _RestoreReducedPath()
 Given an edge record of an edge used to reduce a path, we want to restore
 the path in constant time.
 The path may contain more reduction edges internally, but we do not
 search for and process those since it would violate the constant time
 bound required of this function.
 return OK on success, NOTOK on failure
 ****************************************************************************/

int  _RestoreReducedPath(graphP theGraph, K33SearchContext *context, int e)
{
int  eTwin, u, v, w, x;
int  e0, e1, eTwin0, eTwin1;

     if (gp_IsNotVertex(context->E[e].pathConnector))
         return OK;

     eTwin = gp_GetTwinArc(theGraph, e);

     u = gp_GetNeighbor(theGraph, eTwin);
     v = context->E[e].pathConnector;
     w = context->E[eTwin].pathConnector;
     x = gp_GetNeighbor(theGraph, e);

     /* Get the locations of the edge records between which the new
        edge records must be added in order to reconnect the path
        parallel to the edge. */

     e0 = gp_GetNextArc(theGraph, e);
     e1 = gp_GetPrevArc(theGraph, e);
     eTwin0 = gp_GetNextArc(theGraph, eTwin);
     eTwin1 = gp_GetPrevArc(theGraph, eTwin);

     /* We first delete the edge represented by e and eTwin. We do so before
        restoring the path to ensure we do not exceed the maximum arc capacity. */

     _K33Search_DeleteEdge(theGraph, context, e, 0);

     /* Now we add the two edges to reconnect the reduced path represented
        by the edge [e, eTwin].  The edge record in u is added between e0 and e1.
        Likewise, the new edge record in x is added between eTwin0 and eTwin1. */

     if (gp_IsArc(e0))
     {
    	 if (gp_InsertEdge(theGraph, u, e0, 1, v, NIL, 0) != OK)
    		 return NOTOK;
     }
     else
     {
    	 if (gp_InsertEdge(theGraph, u, e1, 0, v, NIL, 0) != OK)
    		 return NOTOK;
     }

     if (gp_IsArc(eTwin0))
     {
    	 if (gp_InsertEdge(theGraph, x, eTwin0, 1, w, NIL, 0) != OK)
    		 return NOTOK;
     }
     else
     {
    	 if (gp_InsertEdge(theGraph, x, eTwin1, 0, w, NIL, 0) != OK)
    		 return NOTOK;
     }

     // Set the types of the newly added edges. In both cases, the first of the two
     // vertex parameters is known to be degree 2 because they are internal to the
     // path being restored, so this operation is constant time.
     if (_SetEdgeType(theGraph, v, u) != OK ||
         _SetEdgeType(theGraph, w, x) != OK)
         return NOTOK;

     return OK;
}

/****************************************************************************
 _RestoreAndOrientReducedPaths()
 This function searches the embedding for any edges that are specially marked
 as being representative of a path that was previously reduced to a
 single edge by _ReduceBicomp().  The edge is replaced by the path.
 Note that the new path may contain more reduction edges, and these will be
 iteratively expanded by the outer for loop.

 If the edge records of an edge being expanded are the first or last arcs
 of the edge's vertex endpoints, then the edge may be along the external face.
 If so, then the vertices along the path being restored must be given a
 consistent orientation with the endpoints.  It is expected that the embedding
 will have been oriented prior to this operation.
 ****************************************************************************/

int  _RestoreAndOrientReducedPaths(graphP theGraph, K33SearchContext *context)
{
	 int  EsizeOccupied, e, eTwin, u, v, w, x, visited;
	 int  e0, eTwin0, e1, eTwin1;

	 EsizeOccupied = gp_EdgeInUseIndexBound(theGraph);
     for (e = gp_GetFirstEdge(theGraph); e < EsizeOccupied;)
     {
         if (gp_IsVertex(context->E[e].pathConnector))
         {
             visited = gp_GetEdgeVisited(theGraph, e);

             eTwin = gp_GetTwinArc(theGraph, e);
             u = gp_GetNeighbor(theGraph, eTwin);
             v = context->E[e].pathConnector;
             w = context->E[eTwin].pathConnector;
             x = gp_GetNeighbor(theGraph, e);

             /* Now we need the predecessor and successor edge records
                of e and eTwin.  The edge (u, v) will be inserted so
                that the record in u's adjacency list that indicates v
                will be between e0 and e1.  Likewise, the edge record
                (x -> w) will be placed between eTwin0 and eTwin1. */

             e0 = gp_GetNextArc(theGraph, e);
             e1 = gp_GetPrevArc(theGraph, e);
             eTwin0 = gp_GetNextArc(theGraph, eTwin);
             eTwin1 = gp_GetPrevArc(theGraph, eTwin);

             /* We first delete the edge represented by e and eTwin. We do so before
                restoring the path to ensure we do not exceed the maximum arc capacity. */

             _K33Search_DeleteEdge(theGraph, context, e, 0);

             /* Now we add the two edges to reconnect the reduced path represented
                by the edge [e, eTwin].  The edge record in u is added between e0 and e1.
                Likewise, the new edge record in x is added between eTwin0 and eTwin1. */

             if (gp_IsArc(e0))
             {
            	 if (gp_InsertEdge(theGraph, u, e0, 1, v, NIL, 0) != OK)
            		 return NOTOK;
             }
             else
             {
            	 if (gp_InsertEdge(theGraph, u, e1, 0, v, NIL, 0) != OK)
            		 return NOTOK;
             }

             if (gp_IsArc(eTwin0))
             {
            	 if (gp_InsertEdge(theGraph, x, eTwin0, 1, w, NIL, 0) != OK)
            		 return NOTOK;
             }
             else
             {
            	 if (gp_InsertEdge(theGraph, x, eTwin1, 0, w, NIL, 0) != OK)
            		 return NOTOK;
             }

             /* Set the types of the newly added edges */

             if (_SetEdgeType(theGraph, u, v) != OK ||
                 _SetEdgeType(theGraph, w, x) != OK)
                 return NOTOK;

             /* We determine whether the reduction edge may be on the external face,
                in which case we will need to ensure that the vertices on the path
                being restored are consistently oriented.  This will accommodate
                future invocations of MarkPathAlongBicompExtFace().
                Note: If e0, e1, eTwin0 or eTwin1 is not an edge, then it is
                      because we've walked off the end of the edge record list,
                      which happens when e and eTwin are either the first or
                      last edge of the containing vertex.  In turn, the first
                      and last edges of a vertex are the ones that hold it onto
                      the external face, if it is on the external face. */

             if ((gp_IsNotArc(e0) && gp_IsNotArc(eTwin1)) || (gp_IsNotArc(e1) && gp_IsNotArc(eTwin0)))
             {
                 if (_OrientExternalFacePath(theGraph, u, v, w, x) != OK)
                     return NOTOK;
             }

             /* The internal XY path was already marked as part of the decision logic
                that made us decide we could find a K_{3,3} and hence that we should
                reverse all of the reductions.  Subsequent code counts on the fact
                that the X-Y path is already marked, so if we replace a marked edge
                with a path, then we need to mark the path. Similarly, for an unmarked
                edge, the replacement path should be unmarked. */

             if (visited)
             {
                 if (_SetVisitedFlagsOnPath(theGraph, u, v, w, x) != OK)
                	 return NOTOK;
             }
             else
             {
                 if (_ClearVisitedFlagsOnPath(theGraph, u, v, w, x) != OK)
                	 return NOTOK;
             }
         }
         else e+=2;
     }

     return OK;
}

/****************************************************************************
 _MarkStraddlingBridgePath()
 ****************************************************************************/

int  _MarkStraddlingBridgePath(graphP theGraph, int u_min, int u_max, int u_d, int d)
{
isolatorContextP IC = &theGraph->IC;
int p, e;

/* Find the point of intersection p between the path (v ... u_max)
       and the path (d ... u_max). */

     if (theGraph->functions.fpMarkDFSPath(theGraph, u_max, IC->r) != OK)
         return NOTOK;

     p = d;
     while (!gp_GetVertexVisited(theGraph, p))
     {
         gp_SetVertexVisited(theGraph, p);

         e = gp_GetFirstArc(theGraph, p);
         while (gp_IsArc(e))
         {
              if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_PARENT)
                  break;

              e = gp_GetNextArc(theGraph, e);
         }

         gp_SetEdgeVisited(theGraph, e);
         gp_SetEdgeVisited(theGraph, gp_GetTwinArc(theGraph, e));

         p = gp_GetNeighbor(theGraph, e);

         /* If p is a root copy, mark it visited and skip to the parent copy */
         if (gp_IsVirtualVertex(theGraph, p))
         {
             gp_SetVertexVisited(theGraph, p);
             p = gp_GetPrimaryVertexFromRoot(theGraph, p);
         }
     }

/* Unmark the path (p ... u_max), which was marked to help find p.
    The path from v to u_{max} is not needed to form a K_{3,3} except
    for the portion of the path up to p that, with the straddling
    bridge path, comprises part of the connection to u_d. In the
    minor, the path between v and p is edge contracted. */

     while (p != u_max)
     {
         e = gp_GetFirstArc(theGraph, p);
         while (gp_IsArc(e))
         {
              if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_PARENT)
                  break;

              e = gp_GetNextArc(theGraph, e);
         }

         gp_ClearEdgeVisited(theGraph, e);
         gp_ClearEdgeVisited(theGraph, gp_GetTwinArc(theGraph, e));

         p = gp_GetNeighbor(theGraph, e);
         gp_ClearVertexVisited(theGraph, p);

         /* If p is a root copy, clear its visited flag and skip to the
                parent copy */

         if (gp_IsVirtualVertex(theGraph, p))
         {
             p = gp_GetPrimaryVertexFromRoot(theGraph, p);
             gp_ClearVertexVisited(theGraph, p);
         }
     }

/* The straddling bridge must join the path (u_max ... u_min).  If u_d is an
    ancestor of u_min, then mark the path that joins u_d to u_min. */

     if (u_d < u_min)
        if (theGraph->functions.fpMarkDFSPath(theGraph, u_d, u_min) != OK)
            return NOTOK;

     return OK;
}

/****************************************************************************
 _IsolateMinorE5()
 The paths (x, w), (y, w) and (v, u_{max}) are not needed.
 The x-y path and the internal w-z path are already marked.
 ****************************************************************************/

int  _IsolateMinorE5(graphP theGraph)
{
isolatorContextP IC = &theGraph->IC;

     if (_MarkPathAlongBicompExtFace(theGraph, IC->r, IC->x) != OK ||
         _MarkPathAlongBicompExtFace(theGraph, IC->y, IC->r) != OK ||
         theGraph->functions.fpMarkDFSPath(theGraph, MIN3(IC->ux,IC->uy,IC->uz),
                                                     MAX3(IC->ux,IC->uy,IC->uz)) != OK ||
         _MarkDFSPathsToDescendants(theGraph) != OK ||
         _JoinBicomps(theGraph) != OK ||
         _AddAndMarkUnembeddedEdges(theGraph) != OK)
         return NOTOK;

     return OK;
}

/****************************************************************************
 _IsolateMinorE6()
 The paths (x, y), (v, w) and (v, u_{max}) are not needed.
 The path through the straddling bridge that connects from an ancestor of
 u_{max} to v is required, but it may connnect to an ancestor p of v.
 In such a case, the path (v, p) is required, while (p, u_{max}) is not.
 ****************************************************************************/

int  _IsolateMinorE6(graphP theGraph, K33SearchContext *context)
{
isolatorContextP IC = &theGraph->IC;
int u_min, u_max, d, u_d;

/* Clear the previously marked x-y path */

     if (_ClearVisitedFlagsInBicomp(theGraph, IC->r) != OK)
    	 return NOTOK;

/* Clear dw to stop the marking of path (v, w) */

     IC->dw = NIL;

/* Mark (v, ..., x, ..., w, ..., y, ... v) */

     if (_MarkPathAlongBicompExtFace(theGraph, IC->r, IC->r) != OK)
         return NOTOK;

/* Mark the path through the straddling bridge (except for the final
     edge (u_d, d) which is added last by convention). */

     u_min = MIN3(IC->ux,IC->uy,IC->uz);
     u_max = MAX3(IC->ux,IC->uy,IC->uz);
     d = _TestForStraddlingBridge(theGraph, context, u_max);
     u_d = gp_GetVertexLeastAncestor(theGraph, d);

     if (_MarkStraddlingBridgePath(theGraph, u_min, u_max, u_d, d) != OK)
         return NOTOK;

/* Make the final markings and edge additions */

     if (theGraph->functions.fpMarkDFSPath(theGraph, u_min, u_max) != OK ||
         _MarkDFSPathsToDescendants(theGraph) != OK ||
         _JoinBicomps(theGraph) != OK ||
         _AddAndMarkUnembeddedEdges(theGraph) != OK ||
         _AddAndMarkEdge(theGraph, u_d, d) != OK)
         return NOTOK;

     return OK;
}

/****************************************************************************
 _IsolateMinorE7()
 ****************************************************************************/

int  _IsolateMinorE7(graphP theGraph, K33SearchContext *context)
{
isolatorContextP IC = &theGraph->IC;
int u_min, u_max, d, u_d;

/* Mark the appropriate two portions of the external face depending on
    symmetry condition */

     if (IC->uy < IC->ux)
     {
         if (_MarkPathAlongBicompExtFace(theGraph, IC->r, IC->x) != OK ||
             _MarkPathAlongBicompExtFace(theGraph, IC->w, IC->y) != OK)
             return NOTOK;
     }
     else
     {
         if (_MarkPathAlongBicompExtFace(theGraph, IC->x, IC->w) != OK ||
             _MarkPathAlongBicompExtFace(theGraph, IC->y, IC->r) != OK)
             return NOTOK;
     }

/* Mark the path through the straddling bridge (except for the final
     edge (u_d, d) which is added last by convention). */

     u_min = MIN3(IC->ux,IC->uy,IC->uz);
     u_max = MAX3(IC->ux,IC->uy,IC->uz);
     d = _TestForStraddlingBridge(theGraph, context, u_max);
     u_d = gp_GetVertexLeastAncestor(theGraph, d);

     if (_MarkStraddlingBridgePath(theGraph, u_min, u_max, u_d, d) != OK)
         return NOTOK;

/* Make the final markings and edge additions */

     if (theGraph->functions.fpMarkDFSPath(theGraph, u_min, u_max) != OK ||
         _MarkDFSPathsToDescendants(theGraph) != OK ||
         _JoinBicomps(theGraph) != OK ||
         _AddAndMarkUnembeddedEdges(theGraph) != OK ||
         _AddAndMarkEdge(theGraph, u_d, d) != OK)
         return NOTOK;

     return OK;
}
