/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "graphK4Search.h"
#include "graphK4Search.private.h"

extern int K4SEARCH_ID;

#include "graph.h"

/* Imported functions */

extern void _InitIsolatorContext(graphP theGraph);
extern void _ClearVisitedFlags(graphP);
extern int  _ClearVisitedFlagsInBicomp(graphP theGraph, int BicompRoot);
//extern int  _ClearVisitedFlagsInOtherBicomps(graphP theGraph, int BicompRoot);
//extern void _ClearVisitedFlagsInUnembeddedEdges(graphP theGraph);
extern int  _ClearVertexTypeInBicomp(graphP theGraph, int BicompRoot);
//extern int  _DeleteUnmarkedEdgesInBicomp(graphP theGraph, int BicompRoot);
extern int  _ComputeArcType(graphP theGraph, int a, int b, int edgeType);
extern int  _SetEdgeType(graphP theGraph, int u, int v);

extern int  _GetNeighborOnExtFace(graphP theGraph, int curVertex, int *pPrevLink);
extern int  _JoinBicomps(graphP theGraph);
//extern void _FindActiveVertices(graphP theGraph, int R, int *pX, int *pY);
extern int  _OrientVerticesInBicomp(graphP theGraph, int BicompRoot, int PreserveSigns);
extern int  _OrientVerticesInEmbedding(graphP theGraph);
//extern void _InvertVertex(graphP theGraph, int V);
extern int  _ClearVisitedFlagsOnPath(graphP theGraph, int u, int v, int w, int x);
extern int  _SetVisitedFlagsOnPath(graphP theGraph, int u, int v, int w, int x);
extern int  _OrientExternalFacePath(graphP theGraph, int u, int v, int w, int x);

extern int  _FindUnembeddedEdgeToAncestor(graphP theGraph, int cutVertex, int *pAncestor, int *pDescendant);
extern int  _FindUnembeddedEdgeToCurVertex(graphP theGraph, int cutVertex, int *pDescendant);
extern int  _GetLeastAncestorConnection(graphP theGraph, int cutVertex);

extern int  _SetVertexTypesForMarkingXYPath(graphP theGraph);
extern int  _MarkHighestXYPath(graphP theGraph);
extern int  _MarkPathAlongBicompExtFace(graphP theGraph, int startVert, int endVert);
extern int  _AddAndMarkEdge(graphP theGraph, int ancestor, int descendant);
extern int  _DeleteUnmarkedVerticesAndEdges(graphP theGraph);

extern int  _IsolateOuterplanarityObstructionA(graphP theGraph);
//extern int  _IsolateOuterplanarityObstructionB(graphP theGraph);
extern int  _IsolateOuterplanarityObstructionE(graphP theGraph);

extern void _K4Search_InitEdgeRec(K4SearchContext *context, int e);


/* Private functions for K4 searching (exposed to the extension). */

int  _SearchForK4InBicomp(graphP theGraph, K4SearchContext *context, int v, int R);

/* Private functions for K4 searching. */

int  _K4_ChooseTypeOfNonOuterplanarityMinor(graphP theGraph, int v, int R);

int  _K4_FindSecondActiveVertexOnLowExtFacePath(graphP theGraph);
int  _K4_FindPlanarityActiveVertex(graphP theGraph, int v, int R, int prevLink, int *pW);
int  _K4_FindSeparatingInternalEdge(graphP theGraph, int R, int prevLink, int A, int *pW, int *pX, int *pY);
void _K4_MarkObstructionTypeOnExternalFacePath(graphP theGraph, int R, int prevLink, int A);
void _K4_UnmarkObstructionTypeOnExternalFacePath(graphP theGraph, int R, int prevLink, int A);

int  _K4_IsolateMinorA1(graphP theGraph);
int  _K4_IsolateMinorA2(graphP theGraph);
int  _K4_IsolateMinorB1(graphP theGraph);
int  _K4_IsolateMinorB2(graphP theGraph);

int  _K4_ReduceBicompToEdge(graphP theGraph, K4SearchContext *context, int R, int W);
int  _K4_ReducePathComponent(graphP theGraph, K4SearchContext *context, int R, int prevLink, int A);
int  _K4_ReducePathToEdge(graphP theGraph, K4SearchContext *context, int edgeType, int R, int e_R, int A, int e_A);

int  _K4_GetCumulativeOrientationOnDFSPath(graphP theGraph, int ancestor, int descendant);
int  _K4_TestPathComponentForAncestor(graphP theGraph, int R, int prevLink, int A);
void _K4_ClearVisitedInPathComponent(graphP theGraph, int R, int prevLink, int A);
int  _K4_DeleteUnmarkedEdgesInPathComponent(graphP theGraph, int R, int prevLink, int A);
int  _K4_DeleteUnmarkedEdgesInBicomp(graphP theGraph, K4SearchContext *context, int BicompRoot);

int  _K4_RestoreReducedPath(graphP theGraph, K4SearchContext *context, int e);
int  _K4_RestoreAndOrientReducedPaths(graphP theGraph, K4SearchContext *context);

//int _MarkEdge(graphP theGraph, int x, int y);

/****************************************************************************
 _SearchForK4InBicomp()
 ****************************************************************************/

int  _SearchForK4InBicomp(graphP theGraph, K4SearchContext *context, int v, int R)
{
isolatorContextP IC = &theGraph->IC;

	if (context == NULL)
	{
		gp_FindExtension(theGraph, K4SEARCH_ID, (void *)&context);
		if (context == NULL)
			return NOTOK;
	}

	// Begin by determining whether minor A, B or E is detected
	if (_K4_ChooseTypeOfNonOuterplanarityMinor(theGraph, v, R) != OK)
		return NOTOK;

    // Minor A indicates the existence of K_{2,3} homeomorphs, but
    // we run additional tests to see whether we can either find an
    // entwined K4 homeomorph or reduce the bicomp so that the WalkDown
	// is enabled to continue to resolve pertinence
    if (theGraph->IC.minorType & MINORTYPE_A)
    {
    	// Now that we know we have minor A, we can afford to orient the
    	// bicomp because we will either find the desired K4 or we will
    	// reduce the bicomp to an edge. The tests for A1 and A2 are easier
    	// to implement on an oriented bicomp.
    	// NOTE: We're in the midst of the WalkDown, so the stack may be
    	//       non-empty, and it has to be preserved with constant cost.
    	//       The stack will have at most 4 integers per cut vertex
    	//       merge point, and this operation will push at most two
    	//       integers per tree edge in the bicomp, so the stack
    	//       will not overflow.
        if (sp_GetCapacity(theGraph->theStack) < 6*theGraph->N)
    		return NOTOK;

        if (_OrientVerticesInBicomp(theGraph, R, 1) != OK)
        	return NOTOK;

    	// Case A1: Test whether there is an active vertex Z other than W
    	// along the external face path [X, ..., W, ..., Y]
    	if (_K4_FindSecondActiveVertexOnLowExtFacePath(theGraph) == TRUE)
    	{
    		// Now that we know we can find a K4, the Walkdown will not continue
    		// and we can do away with the stack content.
    		sp_ClearStack(theGraph->theStack);

        	// Restore the orientations of the vertices in the bicomp, then orient
    		// the whole embedding, so we can restore and orient the reduced paths
            if (_OrientVerticesInBicomp(theGraph, R, 1) != OK ||
                _OrientVerticesInEmbedding(theGraph) != OK ||
                _K4_RestoreAndOrientReducedPaths(theGraph, context) != OK)
                return NOTOK;

            // Set up to isolate K4 homeomorph
            _ClearVisitedFlags(theGraph);

            if (_FindUnembeddedEdgeToCurVertex(theGraph, IC->w, &IC->dw) != TRUE)
                return NOTOK;

            if (IC->uz < IC->v)
            {
            	if (_FindUnembeddedEdgeToAncestor(theGraph, IC->z, &IC->uz, &IC->dz) != TRUE)
            		return NOTOK;
            }
            else
            {
                if (_FindUnembeddedEdgeToCurVertex(theGraph, IC->z, &IC->dz) != TRUE)
                    return NOTOK;
            }

    		// Isolate the K4 homeomorph
    		if (_K4_IsolateMinorA1(theGraph) != OK  ||
    			_DeleteUnmarkedVerticesAndEdges(theGraph) != OK)
    			return NOTOK;

            // Indicate success by returning NONEMBEDDABLE
    		return NONEMBEDDABLE;
    	}

    	// Case A2: Test whether the bicomp has an XY path
    	// NOTE: As mentioned above, the stack is also preserved here.
    	//       It will have at most 4 integers per cut vertex merge point,
    	//       and this operation will push at most one integer per tree
    	//       edge in the bicomp, so the stack will not overflow.
    	if (_SetVertexTypesForMarkingXYPath(theGraph) != OK)
    		return NOTOK;

    	// Marking the X-Y path relies on the bicomp visited flags being cleared
    	if (_ClearVisitedFlagsInBicomp(theGraph, R) != OK)
    		return NOTOK;

    	// NOTE: This call preserves the stack and does not overflow. There
    	//       are at most 4 integers per cut vertex merge point, all of which
    	//       are not in the bicomp, and this call pushes at most 3 integers
    	//       per bicomp vertex, so the maximum stack requirement is 4N
        if (_MarkHighestXYPath(theGraph) == TRUE)
        {
    		// Now that we know we can find a K4, the Walkdown will not continue
    		// and we can do away with the stack content.
    		sp_ClearStack(theGraph->theStack);

        	// Restore the orientations of the vertices in the bicomp, then orient
    		// the whole embedding, so we can restore and orient the reduced paths
            if (_OrientVerticesInBicomp(theGraph, R, 1) != OK ||
                _OrientVerticesInEmbedding(theGraph) != OK ||
                _K4_RestoreAndOrientReducedPaths(theGraph, context) != OK)
                return NOTOK;

            // Set up to isolate K4 homeomorph
            _ClearVisitedFlags(theGraph);

            if (_FindUnembeddedEdgeToCurVertex(theGraph, IC->w, &IC->dw) != TRUE)
                return NOTOK;

    		// Isolate the K4 homeomorph
    		if (_MarkHighestXYPath(theGraph) != TRUE ||
    			_K4_IsolateMinorA2(theGraph) != OK ||
    			_DeleteUnmarkedVerticesAndEdges(theGraph) != OK)
    			return NOTOK;

            // Indicate success by returning NONEMBEDDABLE
    		return NONEMBEDDABLE;
        }

        // else if there was no X-Y path, then we restore the vertex types to
        // unknown (though it would suffice to do it just to R and W)
		if (_ClearVertexTypeInBicomp(theGraph, R) != OK)
			return NOTOK;

        // Since neither A1 nor A2 is found, then we reduce the bicomp to the
        // tree edge (R, W).
		// NOTE: The visited flags for R and W are restored to values appropriate
		//       for continuing with future embedding steps
        // NOTE: This method invokes several routines that use the stack, but
        //       all of them preserve the stack and each pushes at most one
        //       integer per bicomp vertex and pops all of them before returning.
        //       Again, this means the stack will not overflow.
    	if (_K4_ReduceBicompToEdge(theGraph, context, R, IC->w) != OK)
    		return NOTOK;

        // Return OK so that the WalkDown can continue resolving the pertinence of v.
    	return OK;
    }

    // Minor B also indicates the existence of K_{2,3} homeomorphs, but
    // we run additional tests to see whether we can either find an
    // entwined K4 homeomorph or reduce a portion of the bicomp so that
    // the WalkDown can be reinvoked on the bicomp
    else if (theGraph->IC.minorType & MINORTYPE_B)
    {
    	int a_x, a_y;

    	// Reality check on stack state
    	if (sp_NonEmpty(theGraph->theStack))
    		return NOTOK;

    	// Find the vertices a_x and a_y that are active (pertinent or future pertinent)
    	// and also first along the external face paths emanating from the bicomp root
    	if (_K4_FindPlanarityActiveVertex(theGraph, v, R, 1, &a_x) != OK ||
    		_K4_FindPlanarityActiveVertex(theGraph, v, R, 0, &a_y) != OK)
    		return NOTOK;

    	// Case B1: If both a_x and a_y are future pertinent, then we can stop and
    	// isolate a subgraph homeomorphic to K4.
    	gp_UpdateVertexFuturePertinentChild(theGraph, a_x, v);
    	gp_UpdateVertexFuturePertinentChild(theGraph, a_y, v);
    	if (a_x != a_y && FUTUREPERTINENT(theGraph, a_x, v) && FUTUREPERTINENT(theGraph, a_y, v))
    	{
            if (_OrientVerticesInEmbedding(theGraph) != OK ||
                _K4_RestoreAndOrientReducedPaths(theGraph, context) != OK)
                return NOTOK;

            // Set up to isolate K4 homeomorph
            _ClearVisitedFlags(theGraph);

            IC->x = a_x;
            IC->y = a_y;

           	if (_FindUnembeddedEdgeToAncestor(theGraph, IC->x, &IC->ux, &IC->dx) != TRUE ||
           		_FindUnembeddedEdgeToAncestor(theGraph, IC->y, &IC->uy, &IC->dy) != TRUE)
           		return NOTOK;

    		// Isolate the K4 homeomorph
    		if (_K4_IsolateMinorB1(theGraph) != OK  ||
    			_DeleteUnmarkedVerticesAndEdges(theGraph) != OK)
    			return NOTOK;

            // Indicate success by returning NONEMBEDDABLE
    		return NONEMBEDDABLE;
    	}

    	// Reality check: The bicomp with root R is pertinent, and the only
    	// pertinent or future pertinent vertex on the external face is a_x,
    	// so it must also be pertinent.
    	if (a_x == a_y && !PERTINENT(theGraph, a_x))
    		return NOTOK;

    	// Case B2: Determine whether there is an internal separating X-Y path for a_x or for a_y
    	// The method makes appropriate isolator context settings if the separator edge is found
    	if (_K4_FindSeparatingInternalEdge(theGraph, R, 1, a_x, &IC->w, &IC->px, &IC->py) == TRUE ||
    		_K4_FindSeparatingInternalEdge(theGraph, R, 0, a_y, &IC->w, &IC->py, &IC->px) == TRUE)
    	{
            if (_OrientVerticesInEmbedding(theGraph) != OK ||
                _K4_RestoreAndOrientReducedPaths(theGraph, context) != OK)
                return NOTOK;

            // Set up to isolate K4 homeomorph
            _ClearVisitedFlags(theGraph);

            if (PERTINENT(theGraph, IC->w))
            {
                if (_FindUnembeddedEdgeToCurVertex(theGraph, IC->w, &IC->dw) != TRUE)
                    return NOTOK;
            }
            else
            {
            	IC->z = IC->w;
            	if (_FindUnembeddedEdgeToAncestor(theGraph, IC->z, &IC->uz, &IC->dz) != TRUE)
            		return NOTOK;
            }

            // The X-Y path doesn't have to be the same one that was associated with the
            // separating internal edge.
        	if (_SetVertexTypesForMarkingXYPath(theGraph) != OK ||
        		_MarkHighestXYPath(theGraph) != TRUE)
        		return NOTOK;

    		// Isolate the K4 homeomorph
    		if (_K4_IsolateMinorB2(theGraph) != OK  ||
    			_DeleteUnmarkedVerticesAndEdges(theGraph) != OK)
    			return NOTOK;

            // Indicate success by returning NONEMBEDDABLE
    		return NONEMBEDDABLE;
    	}

    	// If K_4 homeomorph not found, make reductions along a_x and a_y paths.
    	if (a_x == a_y)
    	{
        	// In the special case where both paths lead to the same vertex, we can
        	// reduce the bicomp to a single edge, which avoids issues of reversed
        	// orientation between the bicomp root and the vertex.
        	if (_K4_ReduceBicompToEdge(theGraph, context, R, a_x) != OK)
        		return NOTOK;
    	}
    	else
    	{
    		// When a_x and a_y are distinct, we reduce each path from root to the vertex
        	if (_K4_ReducePathComponent(theGraph, context, R, 1, a_x) != OK ||
        		_K4_ReducePathComponent(theGraph, context, R, 0, a_y) != OK)
        		return NOTOK;
    	}

    	// Return OK to indicate that WalkDown processing may proceed to resolve
    	// more of the pertinence of this bicomp.
		return OK;
    }

	// Minor E indicates the desired K4 homeomorph, so we isolate it and return NONEMBEDDABLE
    else if (theGraph->IC.minorType & MINORTYPE_E)
    {
    	// Reality check on stack state
    	if (sp_NonEmpty(theGraph->theStack))
    		return NOTOK;

        // Impose consistent orientation on the embedding so we can then
        // restore the reduced paths.
        if (_OrientVerticesInEmbedding(theGraph) != OK ||
            _K4_RestoreAndOrientReducedPaths(theGraph, context) != OK)
            return NOTOK;

        // Set up to isolate minor E
        _ClearVisitedFlags(theGraph);

        if (_FindUnembeddedEdgeToCurVertex(theGraph, IC->w, &IC->dw) != TRUE)
            return NOTOK;

    	if (_SetVertexTypesForMarkingXYPath(theGraph) != OK)
    		return NOTOK;
        if (_MarkHighestXYPath(theGraph) != TRUE)
             return NOTOK;

        // Isolate the K4 homeomorph
        if (_IsolateOuterplanarityObstructionE(theGraph) != OK ||
        	_DeleteUnmarkedVerticesAndEdges(theGraph) != OK)
            return NOTOK;

        // Return indication that K4 homeomorph has been found
        return NONEMBEDDABLE;
    }

    // You never get here in an error-free implementation like this one
    return NOTOK;
}

/****************************************************************************
 _K4_ChooseTypeOfNonOuterplanarityMinor()
 This is an overload of the function _ChooseTypeOfNonOuterplanarityMinor()
 that avoids processing the whole bicomp rooted by R, e.g. to orient its
 vertices or label the vertices of its external face.
 This is necessary in particular because of the reduction processing on
 MINORTYPE_B.  When a K2,3 is found by minor B, we may not be able to find
 an entangled K4, so a reduction is performed, but it only eliminates
 part of the bicomp and the operations here need to avoid touching parts
 of the bicomp that won't be reduced, except by a constant amount of course.
 ****************************************************************************/

int  _K4_ChooseTypeOfNonOuterplanarityMinor(graphP theGraph, int v, int R)
{
    int  XPrevLink=1, YPrevLink=0;
    int  Wx, WxPrevLink, Wy, WyPrevLink;

    _InitIsolatorContext(theGraph);

    theGraph->IC.v = v;
    theGraph->IC.r = R;

    // Reality check on data structure integrity
    if (!gp_VirtualVertexInUse(theGraph, R))
    	return NOTOK;

    // We are essentially doing a _FindActiveVertices() here, except two things:
    // 1) for outerplanarity we know the first vertices along the paths from R
    //    are the desired vertices because no vertices are "inactive"
    // 2) We have purposely not oriented the bicomp, so the XPrevLink result is
    //    needed to help find the pertinent vertex W
    theGraph->IC.x = _GetNeighborOnExtFace(theGraph, R, &XPrevLink);
    theGraph->IC.y = _GetNeighborOnExtFace(theGraph, R, &YPrevLink);

    // We are essentially doing a _FindPertinentVertex() here, except two things:
    // 1) It is not known whether the reduction of the path through X or the path
    //    through Y will enable the pertinence of W to be resolved, so it is
    //    necessary to perform parallel face traversal to find W with a cost no
    //    more than twice what it will take to resolve the W's pertinence
    //    (assuming we have to do a reduction rather than finding an entangled K4)
    // 2) In the normal _FindPertinentVertex(), the bicomp is already oriented, so
    //    the "prev link" is hard coded to traverse down the X side.  In this
    //    implementation, the  bicomp is purposely not oriented, so we need to know
    //    XPrevLink and YPrevLink in order to set off in the correct directions.
    Wx = theGraph->IC.x;
    WxPrevLink = XPrevLink;
    Wy = theGraph->IC.y;
    WyPrevLink = YPrevLink;
    theGraph->IC.w = NIL;

    while (Wx != theGraph->IC.y)
    {
        Wx = _GetNeighborOnExtFace(theGraph, Wx, &WxPrevLink);
        if (PERTINENT(theGraph, Wx))
        {
        	theGraph->IC.w = Wx;
        	break;
        }
        Wy = _GetNeighborOnExtFace(theGraph, Wy, &WyPrevLink);
        if (PERTINENT(theGraph, Wy))
        {
        	theGraph->IC.w = Wy;
        	break;
        }
    }

    if (gp_IsNotVertex(theGraph->IC.w))
    	return NOTOK;

    // If the root copy is not a root copy of the current vertex v,
    // then the Walkdown terminated on a descendant bicomp, which is Minor A.
	if (gp_GetPrimaryVertexFromRoot(theGraph, R) != v)
		theGraph->IC.minorType |= MINORTYPE_A;

    // If W has a pertinent child bicomp, then we've found Minor B.
    // Notice this is different from planarity, in which minor B is indicated
    // only if the pertinent child bicomp is also future pertinent.
	else if (gp_IsVertex(gp_GetVertexPertinentRootsList(theGraph, theGraph->IC.w)))
		theGraph->IC.minorType |= MINORTYPE_B;

    // The only other result is minor E (we will search for the X-Y path later)
	else
		theGraph->IC.minorType |= MINORTYPE_E;

	return OK;
}

/****************************************************************************
 _K4_FindSecondActiveVertexOnLowExtFacePath()

 This method is used in the processing of obstruction A, so it can take
 advantage of the bicomp being oriented beforehand.

 This method determines whether there is an active vertex Z other than W on
 the path [X, ..., W, ..., Y].  By active, we mean a vertex that connects
 by an unembedded edge to either v or an ancestor of v.  That is, a vertex
 that is pertinent or future pertinent (would be pertinent in a future step
 of the embedder).
 ****************************************************************************/

int _K4_FindSecondActiveVertexOnLowExtFacePath(graphP theGraph)
{
    int Z=theGraph->IC.r, ZPrevLink=1;

	// First we test X for future pertinence only (if it were pertinent, then
	// we wouldn't have been blocked up on this bicomp)
	Z = _GetNeighborOnExtFace(theGraph, Z, &ZPrevLink);
	gp_UpdateVertexFuturePertinentChild(theGraph, Z, theGraph->IC.v);
    if (FUTUREPERTINENT(theGraph, Z, theGraph->IC.v))
	{
		theGraph->IC.z = Z;
		theGraph->IC.uz = _GetLeastAncestorConnection(theGraph, Z);
		return TRUE;
	}

	// Now we move on to test all the vertices strictly between X and Y on
	// the lower external face path, except W, for either pertinence or
	// future pertinence.
	Z = _GetNeighborOnExtFace(theGraph, Z, &ZPrevLink);

	while (Z != theGraph->IC.y)
	{
		if (Z != theGraph->IC.w)
		{
			gp_UpdateVertexFuturePertinentChild(theGraph, Z, theGraph->IC.v);
		    if (FUTUREPERTINENT(theGraph, Z, theGraph->IC.v))
			{
				theGraph->IC.z = Z;
				theGraph->IC.uz = _GetLeastAncestorConnection(theGraph, Z);
				return TRUE;
			}
			else if (PERTINENT(theGraph, Z))
			{
				theGraph->IC.z = Z;
				theGraph->IC.uz = theGraph->IC.v;
				return TRUE;
			}
		}

		Z = _GetNeighborOnExtFace(theGraph, Z, &ZPrevLink);
	}

	// Now we test Y for future pertinence (same explanation as for X above)
	gp_UpdateVertexFuturePertinentChild(theGraph, Z, theGraph->IC.v);
    if (FUTUREPERTINENT(theGraph, Z, theGraph->IC.v))
	{
		theGraph->IC.z = Z;
		theGraph->IC.uz = _GetLeastAncestorConnection(theGraph, Z);
		return TRUE;
	}

	// We didn't find the desired second vertex, so report FALSE
	return FALSE;
}

/****************************************************************************
 _K4_FindPlanarityActiveVertex()
 This service routine starts out at R and heads off in the direction opposite
 the prevLink to find the first "planarity active" vertex, i.e. the first one
 that is pertinent or future pertinent.
 ****************************************************************************/

int  _K4_FindPlanarityActiveVertex(graphP theGraph, int v, int R, int prevLink, int *pW)
{
	int W = R, WPrevLink = prevLink;

	W = _GetNeighborOnExtFace(theGraph, R, &WPrevLink);

	while (W != R)
	{
	    if (PERTINENT(theGraph, W))
		{
	    	*pW = W;
	    	return OK;
		}
	    else
	    {
	    	gp_UpdateVertexFuturePertinentChild(theGraph, W, v);
	    	if (FUTUREPERTINENT(theGraph, W, v))
	    	{
		    	*pW = W;
		    	return OK;
	    	}
	    }

		W = _GetNeighborOnExtFace(theGraph, W, &WPrevLink);
	}

	return NOTOK;
}

/****************************************************************************
 _K4_FindSeparatingInternalEdge()

 Logically, this method is similar to calling MarkHighestXYPath() to
 see if there is an internal separator between R and A.
 However, that method cannot be called because the bicomp is not oriented.

 Because this is an outerplanarity related algorithm, there are no internal
 vertices to contend with, so it is easier to inspect the internal edges
 incident to each vertex internal to the path (R ... A), i.e. excluding endpoints,
 to see whether any of the edges connects outside of the path [R ... A],
 including endpoints.

 In order to avoid adding cost to the core planarity algorithm, we'll just use
 the fact that the vertex obstruction types are pre-initialized to the unmarked
 state.  Until we know if there is a separating internal edge, we cannot be sure
 that we can isolate a K4 homeomorph, so we can't afford to initialize the whole
 bicomp. The obstruction type of each vertex along the path [R ... A] is marked.
 Then, for each vertex in the range (R ... A), if there is any edge that is also
 incident to a vertex whose obstruction type is still unmarked, then that edge
 is the desired separator edge between R and W (i.e. A), and so we save information
 about it.

 If the separator edge is found, then this method sets the *pW to A, and it
 sets *pX and *pY values with the endpoints of the separator edge.
 The visited flags of the separator edge and its endpoint vertices are not set
 at this time because it is easier to set them later as part of the overall K4
 homeomorph isolation.

 Lastly, we restore the unmarked obstruction type settings on the path [R ... A].

 Returns TRUE if separator edge found or FALSE otherwise
 ****************************************************************************/

int _K4_FindSeparatingInternalEdge(graphP theGraph, int R, int prevLink, int A, int *pW, int *pX, int *pY)
{
	int Z, ZPrevLink, e, neighbor;

	// Mark the vertex obstruction type settings along the path [R ... A]
	_K4_MarkObstructionTypeOnExternalFacePath(theGraph, R, prevLink, A);

	// Search each of the vertices in the range (R ... A)
	*pX = *pY = NIL;
	ZPrevLink = prevLink;
	Z = _GetNeighborOnExtFace(theGraph, R, &ZPrevLink);
	while (Z != A)
	{
		// Search for a separator among the edges of Z
		// It is OK to not bother skipping the external face edges, since we
		// know they are marked visited and so are ignored
	    e = gp_GetFirstArc(theGraph, Z);
	    while (gp_IsArc(e))
	    {
	        neighbor = gp_GetNeighbor(theGraph, e);
	        if (gp_GetVertexObstructionType(theGraph, neighbor) == VERTEX_OBSTRUCTIONTYPE_UNMARKED)
	        {
	        	*pW = A;
	        	*pX = Z;
	        	*pY = neighbor;
	        	break;
	        }
	        e = gp_GetNextArc(theGraph, e);
	    }

	    // If we found the separator edge, then we don't need to go on
	    if (gp_IsVertex(*pX))
	    	break;

		// Go to the next vertex
		Z = _GetNeighborOnExtFace(theGraph, Z, &ZPrevLink);
	}

	// Restore the unmarked obstruction type settings on the path [R ... A]
	_K4_UnmarkObstructionTypeOnExternalFacePath(theGraph, R, prevLink, A);

	return gp_IsVertex(*pX) ? TRUE : FALSE;
}

/****************************************************************************
 _K4_MarkObstructionTypeOnExternalFacePath()

 Assumes A is a vertex along the external face of the bicomp rooted by R.
 Marks the obstruction type of vertices along the path (R ... A) that begins
 with R's link[1^prevLink] arc.
 ****************************************************************************/

void _K4_MarkObstructionTypeOnExternalFacePath(graphP theGraph, int R, int prevLink, int A)
{
	int Z, ZPrevLink;

	gp_SetVertexObstructionType(theGraph, R, VERTEX_OBSTRUCTIONTYPE_MARKED);
	ZPrevLink = prevLink;
	Z = R;
	while (Z != A)
	{
		Z = _GetNeighborOnExtFace(theGraph, Z, &ZPrevLink);
		gp_SetVertexObstructionType(theGraph, Z, VERTEX_OBSTRUCTIONTYPE_MARKED);
	}
}

/****************************************************************************
 _K4_UnmarkObstructionTypeOnExternalFacePath()

 Assumes A is a vertex along the external face of the bicomp rooted by R.
 Unmarks the obstruction type of vertices along the path (R ... A) that begins
 with R's link[1^prevLink] arc.
 ****************************************************************************/

void _K4_UnmarkObstructionTypeOnExternalFacePath(graphP theGraph, int R, int prevLink, int A)
{
	int Z, ZPrevLink;

	gp_ClearVertexObstructionType(theGraph, R);
	ZPrevLink = prevLink;
	Z = R;
	while (Z != A)
	{
		Z = _GetNeighborOnExtFace(theGraph, Z, &ZPrevLink);
		gp_ClearVertexObstructionType(theGraph, Z);
	}
}

/****************************************************************************
 _K4_IsolateMinorA1()

 This pattern is essentially outerplanarity minor A, a K_{2,3}, except we get
 a K_4 via the additional path from some vertex Z to the current vertex.
 This path may be via some descendant of Z, and it may be a future pertinent
 connection to an ancestor of the current vertex.
 ****************************************************************************/

int  _K4_IsolateMinorA1(graphP theGraph)
{
	isolatorContextP IC = &theGraph->IC;

	if (IC->uz < IC->v)
	{
		if (theGraph->functions.fpMarkDFSPath(theGraph, IC->uz, IC->v) != OK)
			return NOTOK;
	}

	if (theGraph->functions.fpMarkDFSPath(theGraph, IC->z, IC->dz) != OK)
    	return NOTOK;

	if (_IsolateOuterplanarityObstructionA(theGraph) != OK)
		return NOTOK;

    if (_AddAndMarkEdge(theGraph, IC->uz, IC->dz) != OK)
        return NOTOK;

	return OK;
}

/****************************************************************************
 _K4_IsolateMinorA2()

 This pattern is essentially outerplanarity minor A, a K_{2,3}, except we get
 a K_4 via an additional X-Y path within the main bicomp, which is guaranteed
 to exist by the time this method is invoked.
 One might think to simply invoke _MarkHighestXYPath() to obtain the path,
 but the IC->px and IC->py values are already set before invoking this method,
 and the bicomp is outerplanar, so the XY path is just an edge. Also, one
 subcase of pattern B2 reduces to this pattern, except that the XY path is
 determined by the B2 isolator.
 ****************************************************************************/

int  _K4_IsolateMinorA2(graphP theGraph)
{
	isolatorContextP IC = &theGraph->IC;

	// We assume the X-Y path was already marked
	if (!gp_GetVertexVisited(theGraph, IC->px) || !gp_GetVertexVisited(theGraph, IC->py))
    	return NOTOK;

	return _IsolateOuterplanarityObstructionA(theGraph);
}

/****************************************************************************
 _K4_IsolateMinorB1()

 It is possible to get a K_4 based on the pertinence of w, but we don't do it
 that way.  If we use the pertinence of w, then we have to eliminate part of
 the bicomp external face, which has special cases if a_x==w or a_y==w.
 Typically we would mark (r ... a_x ... w ... a_y), which works even when a_y==w,
 but if instead a_x==w, then we'd have to mark (w ... a_y ... r).

 Since a_x and a_y are guaranteed to be distinct, it is easier to just ignore
 the pertinence of w, and instead use the lower bicomp external face path
 as the connection between a_x and a_y.  This includes w, but then the
 isolation process is the same even if a_x==w or a_y==w.  The other two
 connections for a_x and a_y are to v and MAX(ux, uy).
 ****************************************************************************/

int  _K4_IsolateMinorB1(graphP theGraph)
{
	isolatorContextP IC = &theGraph->IC;

	if (theGraph->functions.fpMarkDFSPath(theGraph, IC->x, IC->dx) != OK)
    	return NOTOK;

	if (theGraph->functions.fpMarkDFSPath(theGraph, IC->y, IC->dy) != OK)
    	return NOTOK;

	// The path from the bicomp root to MIN(ux,uy) is marked to ensure the
	// connection from the image vertices v and MAX(ux,uy) as well as the
	// connection from MAX(ux,uy) through MIN(ux,uy) to (ux==MIN(ux,uy)?x:y)
	if (theGraph->functions.fpMarkDFSPath(theGraph, MIN(IC->ux, IC->uy), IC->r) != OK)
    	return NOTOK;

	// This makes the following connections (a_x ... v), (a_y ... v), and
	// (a_x ... w ... a_y), the last being tolerant of a_x==w or a_y==w
	if (_MarkPathAlongBicompExtFace(theGraph, IC->r, IC->r) != OK)
		return NOTOK;

    if (_JoinBicomps(theGraph) != OK)
    	return NOTOK;

    if (_AddAndMarkEdge(theGraph, IC->ux, IC->dx) != OK)
        return NOTOK;

    if (_AddAndMarkEdge(theGraph, IC->uy, IC->dy) != OK)
        return NOTOK;

	return OK;
}

/****************************************************************************
 _K4_IsolateMinorB2()

 The first subcase of B2 can be reduced to outerplanarity obstruction E
 The second subcase of B2 can be reduced to A2 by changing v to u
 ****************************************************************************/

int  _K4_IsolateMinorB2(graphP theGraph)
{
	isolatorContextP IC = &theGraph->IC;

	// First subcase, the active vertex is pertinent
    if (PERTINENT(theGraph, IC->w))
    {
    	// We assume the X-Y path was already marked
    	if (!gp_GetVertexVisited(theGraph, IC->px) || !gp_GetVertexVisited(theGraph, IC->py))
        	return NOTOK;

    	return _IsolateOuterplanarityObstructionE(theGraph);
    }

    // Second subcase, the active vertex is future pertinent
    else if (FUTUREPERTINENT(theGraph, IC->w, IC->v))
    {
    	IC->v = IC->uz;
    	IC->dw = IC->dz;

    	return _K4_IsolateMinorA2(theGraph);
    }

	return OK;
}

/****************************************************************************
 _K4_ReduceBicompToEdge()

 This method is used when reducing the main bicomp of obstruction A to a
 single edge (R, W).  We first delete all edges from the bicomp except
 those on the DFS tree path W to R, then we reduce that DFS tree path to
 a DFS tree edge.

 After the reduction, the outerplanarity Walkdown traversal can continue
 R to W without being blocked as was the case when R was adjacent to X and Y.

 Returns OK for success, NOTOK for internal (implementation) error.
 ****************************************************************************/

int  _K4_ReduceBicompToEdge(graphP theGraph, K4SearchContext *context, int R, int W)
{
	int newEdge;

	if (_OrientVerticesInBicomp(theGraph, R, 0) != OK ||
		_ClearVisitedFlagsInBicomp(theGraph, R) != OK)
		return NOTOK;
    if (theGraph->functions.fpMarkDFSPath(theGraph, R, W) != OK)
        return NOTOK;
    if (_K4_DeleteUnmarkedEdgesInBicomp(theGraph, context, R) != OK)
    	return NOTOK;

    // Now we have to reduce the path W -> R to the DFS tree edge (R, W)
    newEdge =_K4_ReducePathToEdge(theGraph, context, EDGE_TYPE_PARENT,
					R, gp_GetFirstArc(theGraph, R), W, gp_GetFirstArc(theGraph, W));
    if (gp_IsNotArc(newEdge))
    	return NOTOK;

    // Finally, set the visited info state of W to unvisited so that
    // the core embedder (esp. Walkup) will not have any problems.
	gp_SetVertexVisitedInfo(theGraph, W, theGraph->N);

	return OK;
}

/****************************************************************************
 _K4_ReducePathComponent()

 This method is invoked when the bicomp rooted by R contains a component
 subgraph that is separable from the bicomp by the 2-cut (R, A). The K_4
 homeomorph isolator will have processed a significant fraction of the
 component, and so it must be reduced to an edge to ensure that said
 processing happens at most once on the component (except for future
 operations that are bound to linear time in total by other arguments).

 Because the bicomp is an outerplanar embedding, the component is known to
 consists of an external face path plus some internal edges that are parallel
 to that path. Otherwise, it wouldn't be separable by the 2-cut (R, A).

 The goal of this method is to reduce the component to the edge (R, A). This
 is done in such a way that, if the reduction must be restored, the DFS tree
 structure connecting the restored vertices is retained.

 The first step is to ensure that (R, A) is not already just an edge, in which
 case no reduction is needed. This can occur if A is future pertinent.

 Assuming a non-trivial reduction component, the next step is to determine
 the DFS tree structure within the component. Because it is separable by the
 2-cut (R, A), there are only two cases:

 Case 1: The DFS tree path from A to R is within the reduction component.

 In this case, the DFS tree path is marked, the remaining edges of the
 reduction component are eliminated, and then the DFS tree path is reduced to
 the the tree edge (R, A).

 Note that the reduction component may also contain descendants of A as well
 as vertices that are descendant to R but are neither ancestors nor
 descendants of A. This depends on where the tree edge from R meets the
 external face path (R ... A). However, the reduction component can only
 contribute one path to any future K_4, so it suffices to preserve only the
 DFS tree path (A --> R).

 Case 2: The DFS tree path from A to R is not within the reduction component.

 In this case, the external face edge from R leads to a descendant D of A.
 We mark that back edge (R, D) plus the DFS tree path (D --> A). The
 remaining edges of the reduction component can be removed, and then the
 path (R, D, ..., A) is reduced to the edge (R, A).

 For the sake of contradiction, suppose that only part of the DFS tree path
 from A to R were contained by the reduction component. Then, a DFS tree edge
 would have to exit the reduction component and connect to some vertex not
 on the external face path (R, ..., A). This contradicts the assumption that
 the reduction subgraph is separable from the bicomp by the 2-cut (R, A).

 Returns OK for success, NOTOK for internal (implementation) error.
 ****************************************************************************/

int  _K4_ReducePathComponent(graphP theGraph, K4SearchContext *context, int R, int prevLink, int A)
{
	int  e_R, e_A, Z, ZPrevLink, edgeType, invertedFlag=0;

	// Check whether the external face path (R, ..., A) is just an edge
	e_R = gp_GetArc(theGraph, R, 1^prevLink);
	if (gp_GetNeighbor(theGraph, e_R) == A)
	    return OK;

	// Check for Case 1: The DFS tree path from A to R is within the reduction component
	if (_K4_TestPathComponentForAncestor(theGraph, R, prevLink, A))
	{
		_K4_ClearVisitedInPathComponent(theGraph, R, prevLink, A);
	    if (theGraph->functions.fpMarkDFSPath(theGraph, R, A) != OK)
	        return NOTOK;
	    edgeType = EDGE_TYPE_PARENT;

	    invertedFlag = _K4_GetCumulativeOrientationOnDFSPath(theGraph, R, A);
	}

	// Otherwise Case 2: The DFS tree path from A to R is not within the reduction component
	else
	{
		_K4_ClearVisitedInPathComponent(theGraph, R, prevLink, A);
		Z = gp_GetNeighbor(theGraph, e_R);
		gp_SetEdgeVisited(theGraph, e_R);
		gp_SetEdgeVisited(theGraph, gp_GetTwinArc(theGraph, e_R));
	    if (theGraph->functions.fpMarkDFSPath(theGraph, A, Z) != OK)
	        return NOTOK;
		edgeType = EDGE_TYPE_BACK;
	}

	// The path to be kept/reduced is marked, so the other edges can go
	if (_K4_DeleteUnmarkedEdgesInPathComponent(theGraph, R, prevLink, A) != OK)
		return NOTOK;

	// Clear all the visited flags for safety, except the vertices R and A
	// will remain in the embedding, and the core embedder (Walkup) uses a
	// value greater than the current vertex to indicate an unvisited vertex
	_K4_ClearVisitedInPathComponent(theGraph, R, prevLink, A);
	gp_SetVertexVisitedInfo(theGraph, A, theGraph->N);

	// Find the component's remaining edges e_A and e_R incident to A and R
	ZPrevLink = prevLink;
	Z = R;
	while (Z != A)
	{
		Z = _GetNeighborOnExtFace(theGraph, Z, &ZPrevLink);
	}
	e_A = gp_GetArc(theGraph, A, ZPrevLink);
	e_R = gp_GetArc(theGraph, R, 1^prevLink);

	// Reduce the path (R ... A) to an edge
	e_R = _K4_ReducePathToEdge(theGraph, context, edgeType, R, e_R, A, e_A);
	if (gp_IsNotArc(e_R))
		return NOTOK;

	// Preserve the net orientation along the DFS path in the case of a tree edge
	if (gp_GetEdgeType(theGraph, e_R) == EDGE_TYPE_CHILD)
	{
		if (invertedFlag)
			gp_SetEdgeFlagInverted(theGraph, e_R);
	}

	return OK;
}

/********************************************************************
 Edge deletion that occurs during a reduction or restoration of a
 reduction is augmented by clearing the K_4 search-specific
 data members.  This is augmentation is not needed in the delete edge
 operations that happen once a K_4 homeomorph has been found and
 marked for isolation.
 ********************************************************************/

int  _K4_DeleteEdge(graphP theGraph, K4SearchContext *context, int e, int nextLink)
{
	_K4Search_InitEdgeRec(context, e);
	_K4Search_InitEdgeRec(context, gp_GetTwinArc(theGraph, e));

	return gp_DeleteEdge(theGraph, e, nextLink);
}

/********************************************************************
 _K4_DeleteUnmarkedEdgesInBicomp()

 This function deletes from a given biconnected component all edges
 whose visited member is zero.

 The stack is used but preserved. In debug mode, NOTOK can result if
 there is a stack overflow. This method pushes at most one integer
 per vertex in the bicomp.

 This is the same as _DeleteUnmarkedEdgesInBicomp(), except it calls
 the overloaded _K4_DeleteEdge() rather than gp_DeleteEdge()

 Returns OK on success, NOTOK on implementation failure
 ********************************************************************/

int  _K4_DeleteUnmarkedEdgesInBicomp(graphP theGraph, K4SearchContext *context, int BicompRoot)
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
            		 : _K4_DeleteEdge(theGraph, context, e, 0);
          }
     }
     return OK;
}

/****************************************************************************
 _K4_GetCumulativeOrientationOnDFSPath()
 ****************************************************************************/
int  _K4_GetCumulativeOrientationOnDFSPath(graphP theGraph, int ancestor, int descendant)
{
int  e, parent;
int  invertedFlag=0;

     /* If we are marking from a root vertex upward, then go up to the parent
        copy before starting the loop */

     if (gp_IsVirtualVertex(theGraph, descendant))
         descendant = gp_GetPrimaryVertexFromRoot(theGraph, descendant);

     while (descendant != ancestor)
     {
          if (gp_IsNotVertex(descendant))
              return NOTOK;

          // If we are at a bicomp root, then ascend to its parent copy
          if (gp_IsVirtualVertex(theGraph, descendant))
          {
              parent = gp_GetPrimaryVertexFromRoot(theGraph, descendant);
          }

          // If we are on a regular, non-virtual vertex then get the edge to the parent
          else
          {
              // Scan the edges for the one marked as the DFS parent
              parent = NIL;
              e = gp_GetFirstArc(theGraph, descendant);
              while (gp_IsArc(e))
              {
                  if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_PARENT)
                  {
                      parent = gp_GetNeighbor(theGraph, e);
                      break;
                  }
                  e = gp_GetNextArc(theGraph, e);
              }

              // If the edge to the parent vertex was not found, then the data structure is corrupt
              if (gp_IsNotVertex(parent))
                  return NOTOK;

              // Add the inversion flag on the child arc to the cumulative result
              e = gp_GetTwinArc(theGraph, e);
              if (gp_GetEdgeType(theGraph, e) != EDGE_TYPE_CHILD || gp_GetNeighbor(theGraph, e) != descendant)
            	  return NOTOK;
              invertedFlag ^= gp_GetEdgeFlagInverted(theGraph, e);
          }

          // Hop to the parent and reiterate
          descendant = parent;
     }

     return invertedFlag;
}

/****************************************************************************
 _K4_TestPathComponentForAncestor()
 Tests the external face path between R and A for a DFS ancestor of A.
 Returns TRUE if found, FALSE otherwise.
 ****************************************************************************/

int _K4_TestPathComponentForAncestor(graphP theGraph, int R, int prevLink, int A)
{
	int Z, ZPrevLink;

	ZPrevLink = prevLink;
	Z = R;
	while (Z != A)
	{
		Z = _GetNeighborOnExtFace(theGraph, Z, &ZPrevLink);
		if (Z < A)
			return TRUE;
	}
	return FALSE;
}

/****************************************************************************
 _K4_ClearVisitedInPathComponent()

 There is a subcomponent of the bicomp rooted by R that is separable by the
 2-cut (R, A). The component contains the external face path from R to A.
 The 1^prevLink arc of R is contained in that path (i.e. the first arc if
 prevLink indicates the last, or the last arc if prevLink indicates the first).
 The prevLink is passed because _GetNeighborOnExtFace() uses the
 opposing link to traverse to the "next" vertex.

 All vertices in this desired component are along the external face, so we
 traverse along the external face vertices strictly between R and A and
 clear all the visited flags of the edges and their incident vertices.

 Note that the vertices along the path (R ... A) only have edges incident
 to each other and to R and A because the component is separable by the
 (R, A)-cut.
 ****************************************************************************/

void _K4_ClearVisitedInPathComponent(graphP theGraph, int R, int prevLink, int A)
{
	int Z, ZPrevLink, e;

	ZPrevLink = prevLink;
	Z = _GetNeighborOnExtFace(theGraph, R, &ZPrevLink);
	while (Z != A)
	{
		gp_ClearVertexVisited(theGraph, Z);
		e = gp_GetFirstArc(theGraph, Z);
		while (gp_IsArc(e))
		{
			gp_ClearEdgeVisited(theGraph, e);
			gp_ClearEdgeVisited(theGraph, gp_GetTwinArc(theGraph, e));
			gp_ClearVertexVisited(theGraph, gp_GetNeighbor(theGraph, e));

			e = gp_GetNextArc(theGraph, e);
		}

		Z = _GetNeighborOnExtFace(theGraph, Z, &ZPrevLink);
	}
}

/****************************************************************************
 _K4_DeleteUnmarkedEdgesInPathComponent()

 There is a subcomponent of the bicomp rooted by R that is separable by the
 2-cut (R, A) and contains the external face path from R to A that includes
 the arc gp_GetArc(theGraph, R, 1^prevLink), which is the first arc traversed
 by _GetNeighborOnExtFace(..., &prevLink).

 The edges in the component have been marked unvisited except for a path we
 intend to preserve. This routine deletes the unvisited edges.

 NOTE: This reduction invalidates the short-circuit extFace data structure,
       but it will be repaired for use by WalkUp and WalkDown when the path
       component reduction is completed.

 Returns OK on success, NOTOK on internal error
 ****************************************************************************/

int  _K4_DeleteUnmarkedEdgesInPathComponent(graphP theGraph, int R, int prevLink, int A)
{
	int Z, ZPrevLink, e;
    K4SearchContext *context = NULL;
    gp_FindExtension(theGraph, K4SEARCH_ID, (void *)&context);

    if (context == NULL)
    	return NOTOK;

	// We need to use the stack to store up the edges we're going to delete.
	// We want to make sure there is enough stack capacity to handle it,
	// which is of course true because the stack is supposed to be empty.
	// We're doing a reduction on a bicomp on which the WalkDown has completed,
	// so the stack contains no bicomp roots to merge.
	if (sp_NonEmpty(theGraph->theStack))
		return NOTOK;

	// Traverse all vertices internal to the path (R ... A) and push
	// all non-visited edges
	ZPrevLink = prevLink;
	Z = _GetNeighborOnExtFace(theGraph, R, &ZPrevLink);
	while (Z != A)
	{
		e = gp_GetFirstArc(theGraph, Z);
		while (gp_IsArc(e))
		{
			// The comparison of e to its twin is a useful way of ensuring we
			// don't push the edge twice, which is of course only applicable
			// when processing an edge whose endpoints are both internal to
			// the path (R ... A)
			if (!gp_GetEdgeVisited(theGraph, e) &&
					(e < gp_GetTwinArc(theGraph, e) ||
					 gp_GetNeighbor(theGraph, e) == R || gp_GetNeighbor(theGraph, e) == A))
			{
				sp_Push(theGraph->theStack, e);
			}

			e = gp_GetNextArc(theGraph, e);
		}

		Z = _GetNeighborOnExtFace(theGraph, Z, &ZPrevLink);
	}

	// Delete all the non-visited edges
	while (sp_NonEmpty(theGraph->theStack))
	{
		sp_Pop(theGraph->theStack, e);
		_K4_DeleteEdge(theGraph, context, e, 0);
	}

	return OK;
}

/****************************************************************************
 _K4_ReducePathToEdge()

 Returns an arc of the edge created on success, a non-arc (NOTOK) on failure
 On success, the arc is in the adjacency list of R. The result can be tested
 for success or failure using comparison with NIL (non-NIL being success)
 ****************************************************************************/

int  _K4_ReducePathToEdge(graphP theGraph, K4SearchContext *context, int edgeType, int R, int e_R, int A, int e_A)
{
	 // Find out the links used in vertex R for edge e_R and in vertex A for edge e_A
	 int Rlink = gp_GetFirstArc(theGraph, R) == e_R ? 0 : 1;
	 int Alink = gp_GetFirstArc(theGraph, A) == e_A ? 0 : 1;

	 // If the path is more than a single edge, then it must be reduced to an edge.
	 // Note that even if the path is a single edge, the external face data structure
	 // must still be modified since many edges connecting the external face have
	 // been deleted
	 if (gp_GetNeighbor(theGraph, e_R) != A)
	 {
		 int v_R, v_A;

		 // Prepare for removing each of the two edges that join the path to the bicomp by
		 // restoring it if it is a reduction edge (a constant time operation)
		 if (gp_IsVertex(context->E[e_R].pathConnector))
		 {
			 if (_K4_RestoreReducedPath(theGraph, context, e_R) != OK)
				 return NOTOK;

			 e_R = gp_GetArc(theGraph, R, Rlink);
		 }

		 if (gp_IsVertex(context->E[e_A].pathConnector))
		 {
			 if (_K4_RestoreReducedPath(theGraph, context, e_A) != OK)
				 return NOTOK;
			 e_A = gp_GetArc(theGraph, A, Alink);
		 }

		 // Save the vertex neighbors of R and A indicated by e_R and e_A for
		 // later use in setting up the path connectors.
		 v_R = gp_GetNeighbor(theGraph, e_R);
		 v_A = gp_GetNeighbor(theGraph, e_A);

		 // Now delete the two edges that join the path to the bicomp.
		 _K4_DeleteEdge(theGraph, context, e_R, 0);
		 _K4_DeleteEdge(theGraph, context, e_A, 0);

		 // Now add a single edge to represent the path
		 // We use 1^Rlink, for example, because Rlink was the link from R that indicated e_R,
		 // so 1^Rlink is the link that indicated e_R in the other arc that was adjacent to e_R.
		 // We want gp_InsertEdge to place the new arc where e_R was in R's adjacency list
		 gp_InsertEdge(theGraph, R, gp_GetArc(theGraph, R, Rlink), 1^Rlink,
								 A, gp_GetArc(theGraph, A, Alink), 1^Alink);

		 // Now set up the path connectors so the original path can be recovered if needed.
		 e_R = gp_GetArc(theGraph, R, Rlink);
		 context->E[e_R].pathConnector = v_R;

		 e_A = gp_GetArc(theGraph, A, Alink);
		 context->E[e_A].pathConnector = v_A;

		 // Also, set the reduction edge's type to preserve the DFS tree structure
		 gp_SetEdgeType(theGraph, e_R, _ComputeArcType(theGraph, R, A, edgeType));
		 gp_SetEdgeType(theGraph, e_A, _ComputeArcType(theGraph, A, R, edgeType));
	 }

	 // Set the external face data structure
     gp_SetExtFaceVertex(theGraph, R, Rlink, A);
     gp_SetExtFaceVertex(theGraph, A, Alink, R);

     // If the edge represents an entire bicomp, then more external face
     // settings are needed.
     if (gp_GetFirstArc(theGraph, R) == gp_GetLastArc(theGraph, R))
     {
         gp_SetExtFaceVertex(theGraph, R, 1^Rlink, A);
         gp_SetExtFaceVertex(theGraph, A, 1^Alink, R);
     }

	 return e_R;
}

/****************************************************************************
 _K4_RestoreReducedPath()

 Given an edge record of an edge used to reduce a path, we want to restore
 the path in constant time.
 The path may contain more reduction edges internally, but we do not
 search for and process those since it would violate the constant time
 bound required of this function.

 Note that we don't bother amending the external face data structure because
 a reduced path is only restored when it will shortly be reduced again or
 when we don't really need the external face data structure anymore.

 Return OK on success, NOTOK on failure
 ****************************************************************************/

int  _K4_RestoreReducedPath(graphP theGraph, K4SearchContext *context, int e)
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

     // Get the locations of the EdgeRecs between which the new EdgeRecs
     // must be added in order to reconnect the path parallel to the edge.
     e0 = gp_GetNextArc(theGraph, e);
     e1 = gp_GetPrevArc(theGraph, e);
     eTwin0 = gp_GetNextArc(theGraph, eTwin);
     eTwin1 = gp_GetPrevArc(theGraph, eTwin);

     // We first delete the edge represented by e and eTwin. We do so before
     // restoring the path to ensure we do not exceed the maximum arc capacity.
     _K4_DeleteEdge(theGraph, context, e, 0);

     // Now we add the two edges to reconnect the reduced path represented
     // by the edge [e, eTwin].  The edge record in u is added between e0 and e1.
     // Likewise, the new edge record in x is added between eTwin0 and eTwin1.
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
     if (_SetEdgeType(theGraph, v, u) != OK || _SetEdgeType(theGraph, w, x) != OK)
         return NOTOK;

     return OK;
}

/****************************************************************************
 _K4_RestoreAndOrientReducedPaths()

 This function searches the embedding for any edges that are specially marked
 as being representative of a path that was previously reduced to a single edge
 by _ReducePathToEdge().  This method restores the path by replacing the edge
 with the path.

 Note that the new path may contain more reduction edges, and these will be
 iteratively expanded by the outer for loop.  Equally, a reduced path may
 be restored into a path that itself is a reduction path that will only be
 attached to the embedding by some future step of the outer loop.

 The vertices along the path being restored must be given a consistent
 orientation with the endpoints.  It is expected that the embedding
 will have been oriented prior to this operation.
 ****************************************************************************/

int  _K4_RestoreAndOrientReducedPaths(graphP theGraph, K4SearchContext *context)
{
	 int  EsizeOccupied, e, eTwin, u, v, w, x, visited;

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

    		 if (_K4_RestoreReducedPath(theGraph, context, e) != OK)
    			 return NOTOK;

    		 // If the path is on the external face, orient it
    		 if (gp_GetNeighbor(theGraph, gp_GetFirstArc(theGraph, u)) == v ||
    		     gp_GetNeighbor(theGraph, gp_GetLastArc(theGraph, u)) == v)
    		 {
    			 // Reality check: ensure the path is connected to the
    			 // external face at both vertices.
        		 if (gp_GetNeighbor(theGraph, gp_GetFirstArc(theGraph, x)) != w &&
        		     gp_GetNeighbor(theGraph, gp_GetLastArc(theGraph, x)) != w)
        			 return NOTOK;

    			 if (_OrientExternalFacePath(theGraph, u, v, w, x) != OK)
    				 return NOTOK;
    		 }

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
