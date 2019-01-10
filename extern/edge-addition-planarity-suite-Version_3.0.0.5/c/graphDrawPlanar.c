/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "graphDrawPlanar.h"
#include "graphDrawPlanar.private.h"

extern int DRAWPLANAR_ID;

#include "graph.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

extern void _ClearVisitedFlags(graphP theGraph);

/* Private functions exported to system */

void _CollectDrawingData(DrawPlanarContext *context, int RootVertex, int W, int WPrevLink);
int  _BreakTie(DrawPlanarContext *context, int BicompRoot, int W, int WPrevLink);

int  _ComputeVisibilityRepresentation(DrawPlanarContext *context);
int  _CheckVisibilityRepresentationIntegrity(DrawPlanarContext *context);

/* Private functions */
int _ComputeVertexPositions(DrawPlanarContext *context);
int _ComputeVertexPositionsInComponent(DrawPlanarContext *context, int root, int *pIndex);
int _ComputeEdgePositions(DrawPlanarContext *context);
int _ComputeVertexRanges(DrawPlanarContext *context);
int _ComputeEdgeRanges(DrawPlanarContext *context);

/********************************************************************
 _ComputeVisibilityRepresentation()

  Compute vertex positions
  Compute edge positions
  Assign horizontal ranges of vertices
  Assign vertical ranges of edges

 ********************************************************************/

int _ComputeVisibilityRepresentation(DrawPlanarContext *context)
{
    if (sp_NonEmpty(context->theGraph->edgeHoles))
        return NOTOK;

    if (_ComputeVertexPositions(context) != OK)
        return NOTOK;

    if (_ComputeEdgePositions(context) != OK)
        return NOTOK;

    if (_ComputeVertexRanges(context) != OK)
        return NOTOK;

    if (_ComputeEdgeRanges(context) != OK)
        return NOTOK;

    return OK;
}

/********************************************************************
 _ComputeVertexPositions()

  Computes the vertex positions in the graph.  This method accounts
  for disconnected graphs by finding the DFS tree roots and then,
  for each, invoking _ComputeVertexPositionsInComponent().
  The index variable for the positioning is maintained by this method
  so that the vertices in separate components still get distinct
  vertex positions.
 ********************************************************************/

int _ComputeVertexPositions(DrawPlanarContext *context)
{
	graphP theEmbedding = context->theGraph;
	int v, vertpos;

	vertpos = 0;
	for (v = gp_GetFirstVertex(theEmbedding); gp_VertexInRange(theEmbedding, v); v++)
    {
        // For each DFS tree root in the embedding, we
        // compute the vertex positions
        if (gp_IsDFSTreeRoot(theEmbedding, v))
        {
            if (_ComputeVertexPositionsInComponent(context, v, &vertpos) != OK)
                return NOTOK;
        }
    }

    return OK;
}

/********************************************************************
 _ComputeVertexPositionsInComponent()

  The vertical positions of the vertices are computed based in part
  on the information compiled during the planar embedding.

  Each vertex is marked as being between its parent and some ancestor
  or beyond the parent relative to the ancestor.  The localized,
  intuitive notion is that the vertex is either below the parent
  or above the parent, but the bicomp containing the vertex, its
  parent and the ancestor may be turned upside-down as the result
  of a global sequence of operations, resulting in a between or beyond
  generalization.

  As the core planarity algorithm constructs successively larger
  bicomps out of smaller ones, the bicomp root and its DFS child
  are marked as 'tied' in vertex position using markers along the
  external face.  The marking of the DFS child may be indirect.
  Since the child may not be on the external face, its descendant
  that is next along the external face is marked instead.

  Later (possibly in the same step or possibly many vertices later),
  the Walkdown proceeds around the bicomp and returns to each merge
  point, and the tie is broken based on the direction of approach.

  As the Walkdown passes a vertex to its successor, the external
  face is short-circuited to remove the vertex from it.  Immediately
  before this occurs, the new drawing method resolves the tie.  Since
  the vertex is going to the internal face, its vertex position should
  be 'between' its successor and the current vertex being processed
  by the Walkdown.

  If the vertex is a child of its external face successor, then it
  is simply marked as being 'between' that successor and the current
  vertex being processed by the planarity method.  But if the vertex
  is the parent of its external face successor, then the successor
  is placed 'beyond' the vertex.  Recall that the successor is either
  the DFS child of the vertex or a descendant of that DFS child that
  was specially marked because it, not the DFS child, was on the
  external face.

  This explains the information that has been collected by the
  planarity embedder, which will now be turned into a vertex ordering
  system.  The idea is to proceed with a pre-order traversal of
  the DFS tree, determining the relative orders of the ancestors of
  a vertex by the time we get to a vertex.  This will allow us to
  convert between/beyond into above/below based on the known relative
  order of the parent and some given ancestor of the vertex.  A vertex
  would then be added immediately above or below its parent in the
  total ordering, and then the algorithm proceeds to the descendants.

  Consider a depth-first pre-order visitation of vertices.  If the
  full order of all vertices visited so far is dynamically maintained,
  then it is easy to decide whether a vertex goes above or below
  its parent based on the between/beyond indicator and the relative
  positions in the order of the parent and given ancestor of the
  vertex.  If the ancestor is above the parent, then 'between' means
  put the vertex immediately above its parent and 'beyond' means put
  the vertex immediately below its parent in the order.  And if the
  ancestor is below the parent, then the meaning of between and
  beyond are simply reversed.

  Once a vertex is known to be above or below its parent, the drawing
  flag is changed from between/beyond to above/below, and processing
  proceeds to the next vertex in pre-order depth first search.

  The difficulty lies in keeping an up-to-date topological ordering
  that can be queried in constant time to find the relative positions
  of two vertices.  By itself, this is an instance of "online" or
  dynamic topological sorting and has been proven not to be achievable
  in linear total time.  But this is a special case of the problem and
  is therefore solvable through the collection and maintenance of some
  additional information.

  Recall that the ancestor V of a vertex is recorded when the setting
  for between/beyond is made for a vertex. However, the Walkdown is
  invoked on the bicomp rooted by edge (V', C), so the child C of V
  that roots the subtree containing the vertex being marked is known.

  Note that when a DFS child is placed above its parent, the entire
  DFS subtree of vertices is placed above the parent.  Hence, to
  determine whether the parent P of a vertex W is above the ancestor
  V, where W is marked either between or beyond P and V, we need
  only determine the relationship between V and C, which has already
  been directly determined due to previous steps of the algorithm
  (because V and C are ancestors of P and W).  If C is above/below V
  then so is P.

  As mentioned above, once the position of P is known relative to V,
  it is a simple matter to decide whether to put W above or below P
  based on the between/beyond indicator stored in W during embedding.
 ********************************************************************/

int _ComputeVertexPositionsInComponent(DrawPlanarContext *context, int root, int *pVertpos)
{
graphP theEmbedding = context->theGraph;
listCollectionP theOrder = LCNew(gp_PrimaryVertexIndexBound(theEmbedding));
int W, P, C, V, e;

    if (theOrder == NULL)
        return NOTOK;

    // Determine the vertex order using a depth first search with
    // pre-order visitation.

    sp_ClearStack(theEmbedding->theStack);
    sp_Push(theEmbedding->theStack, root);
    while (!sp_IsEmpty(theEmbedding->theStack))
    {
        sp_Pop(theEmbedding->theStack, W);

        P = gp_GetVertexParent(theEmbedding, W);
        V = context->VI[W].ancestor;
        C = context->VI[W].ancestorChild;

        // For the special case that we just popped the DFS tree root,
        // we simply add the root to its own position.
        if (gp_IsNotVertex(P))
        {
            // Put the DFS root in the list by itself
            LCAppend(theOrder, NIL, W);
            // The children of the DFS root have the root as their
            // ancestorChild and 'beyond' as the drawingFlag, so this
            // causes the root's children to be placed below the root
            context->VI[W].drawingFlag = DRAWINGFLAG_BELOW;
        }

        // Determine vertex W position relative to P
        else
        {
            // An unresolved tie is an error
            if (context->VI[W].drawingFlag == DRAWINGFLAG_TIE)
                return NOTOK;

            // If W is the child of a DFS root, then there is no vertex C
            // between it and some ancestor V.  Both V and C are not a vertex,
            // and W will simply take the default of being below its parent.
            // If C is a vertex, then it has already been absolutely positioned
            // and can be used to help position W relative to its parent P,
            // which is equal to or descendant to C. If C below V, then P below V,
            // so interpret 'W between P and V' as 'W above P', and interpret
            // 'W beyond P relative to V' as 'W below P'.
            if (gp_IsNotVertex(C) || context->VI[C].drawingFlag == DRAWINGFLAG_BELOW)
            {
                if (context->VI[W].drawingFlag == DRAWINGFLAG_BETWEEN)
                    context->VI[W].drawingFlag = DRAWINGFLAG_ABOVE;
                else
                    context->VI[W].drawingFlag = DRAWINGFLAG_BELOW;
            }

            // If C above V, then P above V, so interpret W between
            // P and V as W below P, and interpret W beyond P relative
            // to V as W above P.
            else
            {
                if (context->VI[W].drawingFlag == DRAWINGFLAG_BETWEEN)
                    context->VI[W].drawingFlag = DRAWINGFLAG_BELOW;
                else
                    context->VI[W].drawingFlag = DRAWINGFLAG_ABOVE;
            }

            if (context->VI[W].drawingFlag == DRAWINGFLAG_BELOW)
                LCInsertAfter(theOrder, P, W);
            else
                LCInsertBefore(theOrder, P, W);
        }

        // Push DFS children
        e = gp_GetFirstArc(theEmbedding, W);
        while (gp_IsArc(e))
        {
            if (gp_GetEdgeType(theEmbedding, e) == EDGE_TYPE_CHILD)
                sp_Push(theEmbedding->theStack, gp_GetNeighbor(theEmbedding, e));

            e = gp_GetNextArc(theEmbedding, e);
        }
    }

    // Use the order to assign vertical positions
    V = root;
    while (gp_IsVertex(V))
    {
        context->VI[V].pos = *pVertpos;
        (*pVertpos)++;
        V = LCGetNext(theOrder, root, V);
    }

    // Clean up and return

    LCFree(&theOrder);
    return OK;
}


#ifdef LOGGING
/********************************************************************
 _LogEdgeList()
 Used to show the progressive calculation of the edge position list.
 ********************************************************************/
void _LogEdgeList(graphP theEmbedding, listCollectionP edgeList, int edgeListHead)
{
    int eIndex = edgeListHead, e, eTwin;

    gp_Log("EdgeList: [ ");

    while (gp_IsArc(eIndex))
    {
        e = (eIndex << 1);
        eTwin = gp_GetTwinArc(theEmbedding, e);

        gp_Log(gp_MakeLogStr2("(%d, %d) ",
        		gp_GetVertexIndex(theEmbedding, gp_GetNeighbor(theEmbedding, e)),
        		gp_GetVertexIndex(theEmbedding, gp_GetNeighbor(theEmbedding, eTwin))));

        eIndex = LCGetNext(edgeList, edgeListHead, eIndex);
    }

    gp_LogLine("]");
}
#endif

/********************************************************************
 _ComputeEdgePositions()

  Performs a vertical sweep of the combinatorial planar embedding,
  developing the edge order in the horizontal sweep line as it
  advances through the vertices according to their assigned
  vertical positions.

  The 'visitedInfo' member of each vertex is used to indicate the
  location in the edge order list of the generator edge for the vertex.
  The generator edge is the first edge used to visit the vertex from
  a higher vertex in the drawing (i.e. a vertex with an earlier, or
  lower, position number).

  All edges added from this vertex to the neighbors below it are
  added immediately after the generator edge for the vertex.
 ********************************************************************/

int _ComputeEdgePositions(DrawPlanarContext *context)
{
graphP theEmbedding = context->theGraph;
int *vertexOrder = NULL;
listCollectionP edgeList = NULL;
int edgeListHead, edgeListInsertPoint;
int e, eTwin, eCur, v, vpos, epos, eIndex;

	gp_LogLine("\ngraphDrawPlanar.c/_ComputeEdgePositions() start");

    // Sort the vertices by vertical position (in linear time)

    if ((vertexOrder = (int *) malloc(theEmbedding->N * sizeof(int))) == NULL)
        return NOTOK;

	for (v = gp_GetFirstVertex(theEmbedding); gp_VertexInRange(theEmbedding, v); v++)
        vertexOrder[context->VI[v].pos] = v;

    // Allocate the edge list of size M.
    //    This is an array of (prev, next) pointers.
    //    An edge at position X corresponds to the edge
    //    at position X in the graph structure, which is
    //    represented by a pair of adjacent edge records
    //    at index 2X.

    if (theEmbedding->M > 0 && (edgeList = LCNew(gp_GetFirstEdge(theEmbedding)/2+theEmbedding->M)) == NULL)
    {
        free(vertexOrder);
        return NOTOK;
    }

    edgeListHead = NIL;

    // Each vertex starts out with a NIL generator edge.

	for (v = gp_GetFirstVertex(theEmbedding); gp_VertexInRange(theEmbedding, v); v++)
        gp_SetVertexVisitedInfo(theEmbedding, v, NIL);

    // Perform the vertical sweep of the combinatorial embedding, using
    // the vertex ordering to guide the sweep.
    // For each vertex, each edge leading to a vertex with a higher number in
    // the vertex order is recorded as the "generator edge", or the edge of
    // first discovery of that higher numbered vertex, unless the vertex already has
    // a recorded generator edge
	for (vpos = 0; vpos < theEmbedding->N; vpos++)
    {
        // Get the vertex associated with the position
        v = vertexOrder[vpos];
        gp_LogLine(gp_MakeLogStr3("Processing vertex %d with DFI=%d at position=%d",
    				 gp_GetVertexIndex(theEmbedding, v), v, vpos));

        // The DFS tree root of a connected component is always the least
        // number vertex in the vertex ordering.  We have to give it a
        // false generator edge so that it is still "visited" and then
        // all of its edges are generators for its neighbor vertices because
        // they all have greater numbers in the vertex order.
        if (gp_IsDFSTreeRoot(theEmbedding, v))
        {
            // Set a false generator edge, so the vertex is distinguishable from
            // a vertex with no generator edge when its neighbors are visited
            // This way, an edge from a neighbor won't get recorded as the
            // generator edge of the DFS tree root.
            gp_SetVertexVisitedInfo(theEmbedding, v, NIL - 1);

            // Now we traverse the adjacency list of the DFS tree root and
            // record each edge as the generator edge of the neighbors
            e = gp_GetFirstArc(theEmbedding, v);
            while (gp_IsArc(e))
            {
                eIndex = (e >> 1); // div by 2 since each edge is a pair of arcs

                edgeListHead = LCAppend(edgeList, edgeListHead, eIndex);
                gp_LogLine(gp_MakeLogStr2("Append generator edge (%d, %d) to edgeList",
                		gp_GetVertexIndex(theEmbedding, v), gp_GetVertexIndex(theEmbedding, gp_GetNeighbor(theEmbedding, e))));

                // Set the generator edge for the root's neighbor
                gp_SetVertexVisitedInfo(theEmbedding, gp_GetNeighbor(theEmbedding, e), e);

                // Go to the next node of the root's adj list
                e = gp_GetNextArc(theEmbedding, e);
            }
        }

        // Else, if we are not on a DFS tree root...
        else
        {
            // Get the generator edge of the vertex
        	// Note that this never gets the false generator edge of a DFS tree root
        	eTwin = gp_GetVertexVisitedInfo(theEmbedding, v);
            if (gp_IsNotArc(eTwin))
                return NOTOK;
            e = gp_GetTwinArc(theEmbedding, eTwin);

            // Traverse the edges of the vertex, starting
            // from the generator edge and going counterclockwise...

            eIndex = (e >> 1);
            edgeListInsertPoint = eIndex;

            eCur = gp_GetNextArcCircular(theEmbedding, e);
            while (eCur != e)
            {
                // If the neighboring vertex's position is greater
                // than the current vertex (meaning it is lower in the
                // diagram), then add that edge to the edge order.

                if (context->VI[gp_GetNeighbor(theEmbedding, eCur)].pos > vpos)
                {
                    eIndex = eCur >> 1;
                    LCInsertAfter(edgeList, edgeListInsertPoint, eIndex);

                    gp_LogLine(gp_MakeLogStr4("Insert (%d, %d) after (%d, %d)",
                    		gp_GetVertexIndex(theEmbedding, v),
                    		gp_GetVertexIndex(theEmbedding, gp_GetNeighbor(theEmbedding, eCur)),
                    		gp_GetVertexIndex(theEmbedding, gp_GetNeighbor(theEmbedding, gp_GetTwinArc(theEmbedding, e))),
                    		gp_GetVertexIndex(theEmbedding, gp_GetNeighbor(theEmbedding, e))));

                    edgeListInsertPoint = eIndex;

                    // If the vertex does not yet have a generator edge, then set it.
                    // Note that a DFS tree root has a false generator edge, so this if
                    // test avoids setting a generator edge for a DFS tree root
                    if (gp_IsNotArc(gp_GetVertexVisitedInfo(theEmbedding, gp_GetNeighbor(theEmbedding, eCur))))
                    {
                        gp_SetVertexVisitedInfo(theEmbedding, gp_GetNeighbor(theEmbedding, eCur), eCur);
                        gp_LogLine(gp_MakeLogStr2("Generator edge (%d, %d)",
                        		gp_GetVertexIndex(theEmbedding, gp_GetNeighbor(theEmbedding, gp_GetTwinArc(theEmbedding, e))),
                        		gp_GetVertexIndex(theEmbedding, gp_GetNeighbor(theEmbedding, eCur))));
                    }
                }

                // Go to the next node in v's adjacency list
                eCur = gp_GetNextArcCircular(theEmbedding, eCur);
            }
        }

#ifdef LOGGING
        _LogEdgeList(theEmbedding, edgeList, edgeListHead);
#endif
    }

    // Now iterate through the edgeList and assign positions to the edges.
    epos = 0;
    eIndex = edgeListHead;
    while (gp_IsArc(eIndex))
    {
        e = (eIndex << 1);
        eTwin = gp_GetTwinArc(theEmbedding, e);

        context->E[e].pos = context->E[eTwin].pos = epos;

        epos++;

        eIndex = LCGetNext(edgeList, edgeListHead, eIndex);
    }

    // Clean up and return
    LCFree(&edgeList);
    free(vertexOrder);

	gp_LogLine("graphDrawPlanar.c/_ComputeEdgePositions() end\n");

    return OK;
}

/********************************************************************
 _ComputeVertexRanges()

   Assumes edge positions are known (see _ComputeEdgePositions()).
   A vertex spans horizontally the positions of the edges incident
   to it.
 ********************************************************************/

int _ComputeVertexRanges(DrawPlanarContext *context)
{
	graphP theEmbedding = context->theGraph;
	int v, e, min, max;

	for (v = gp_GetFirstVertex(theEmbedding); gp_VertexInRange(theEmbedding, v); v++)
    {
        min = theEmbedding->M + 1;
        max = -1;

        // Iterate the edges, except in the isolated vertex case we just
        // set the min and max to 1 since there no edges controlling where
        // it gets drawn.
        e = gp_GetFirstArc(theEmbedding, v);
        if (gp_IsNotArc(e))
        {
        	min = max = 0;
        }
        else
        {
            while (gp_IsArc(e))
            {
                if (min > context->E[e].pos)
                    min = context->E[e].pos;

                if (max < context->E[e].pos)
                    max = context->E[e].pos;

                e = gp_GetNextArc(theEmbedding, e);
            }
        }

        context->VI[v].start = min;
        context->VI[v].end = max;
    }

    return OK;
}

/********************************************************************
 _ComputeEdgeRanges()

    Assumes vertex positions are known (see _ComputeVertexPositions()).
    An edges spans the vertical range of its endpoints.
 ********************************************************************/

int _ComputeEdgeRanges(DrawPlanarContext *context)
{
	graphP theEmbedding = context->theGraph;
	int e, eTwin, EsizeOccupied, v1, v2, pos1, pos2;

	// Deleted edges are not supported, nor should they be in the embedding, so
	// this is just a reality check that avoids an in-use test inside the loop
    if (sp_NonEmpty(theEmbedding->edgeHoles))
		return NOTOK;

	EsizeOccupied = gp_EdgeInUseIndexBound(theEmbedding);
    for (e = gp_GetFirstEdge(theEmbedding); e < EsizeOccupied; e+=2)
    {
        eTwin = gp_GetTwinArc(theEmbedding, e);

        v1 = gp_GetNeighbor(theEmbedding, e);
        v2 = gp_GetNeighbor(theEmbedding, eTwin);

        pos1 = context->VI[v1].pos;
        pos2 = context->VI[v2].pos;

        if (pos1 < pos2)
        {
            context->E[e].start = pos1;
            context->E[e].end = pos2;
        }
        else
        {
            context->E[e].start = pos2;
            context->E[e].end = pos1;
        }

        context->E[eTwin].start = context->E[e].start;
        context->E[eTwin].end = context->E[e].end;
    }

    return OK;
}

/********************************************************************
 _GetNextExternalFaceVertex()
 Uses the extFace links to traverse to the next vertex on the external
 face given a current vertex and the link that points to its predecessor.
 ********************************************************************/
int _GetNextExternalFaceVertex(graphP theGraph, int curVertex, int *pPrevLink)
{
    int nextVertex = gp_GetExtFaceVertex(theGraph, curVertex, 1 ^ *pPrevLink);

    // If the two links in the new vertex are not equal, then only one points
    // back to the current vertex, and it is the new prev link.
    // Otherwise, the vertex is in a consistently oriented single-edge bicomp, so
    // no adjustment of the prev link is needed (due to the consistent orientation).
    if (gp_GetExtFaceVertex(theGraph, nextVertex, 0) != gp_GetExtFaceVertex(theGraph, nextVertex, 1))
    {
    	*pPrevLink = gp_GetExtFaceVertex(theGraph, nextVertex, 0)==curVertex ? 0 : 1;
    }

    return nextVertex;
}

/********************************************************************
 _CollectDrawingData()
 To be called by core planarity Walkdown immediately before merging
 bicomps and embedding a new back edge.

 Each bicomp is rooted by a DFS tree edge.  The parent vertex in
 that edge is the bicomp root, and the bicomp contains one DFS child
 of the vertex, which is on the child end of the 'root edge'.

 Here we decide whether the DFS child is to be embedded between or
 beyond its parent relative to vertex v, the one currently being
 processed (and the ancestor endpoint of a back edge being embedded,
 where the descendant endpoint is also an endpoint of the bicomp
 root being merged).
 ********************************************************************/

void _CollectDrawingData(DrawPlanarContext *context, int RootVertex, int W, int WPrevLink)
{
graphP theEmbedding = context->theGraph;
int K, Parent, BicompRoot, DFSChild, direction, descendant;

    gp_LogLine("\ngraphDrawPlanar.c/_CollectDrawingData() start");
    gp_LogLine(gp_MakeLogStr3("_CollectDrawingData(RootVertex=%d, W=%d, W_in=%d)",
				 RootVertex, W, WPrevLink));

    /* Process all of the merge points to set their drawing flags. */

    for (K = 0; K < sp_GetCurrentSize(theEmbedding->theStack); K += 4)
    {
         /* Get the parent and child that are about to be merged from
            the 4-tuple in the merge stack */
         Parent = theEmbedding->theStack->S[K];
         BicompRoot = theEmbedding->theStack->S[K+2];
         DFSChild = gp_GetDFSChildFromRoot(theEmbedding, BicompRoot);

         /* We get the active descendant vertex in the child bicomp that
            will be adjacent to the parent along the external face.
            This vertex is guaranteed to be found in one step
            due to external face 'short-circuiting' that was done in
            step 'Parent' of the planarity algorithm.
            We pass theEmbedding->N for the second parameter because
            of this; we use this function to signify need of extFace
            links in the other implementation.*/

         direction = theEmbedding->theStack->S[K+3];
         descendant = _GetNextExternalFaceVertex(theEmbedding, BicompRoot, &direction);

         /* Now we set the tie flag in the DFS child, and mark the
            descendant and parent with non-NIL pointers to the child
            whose tie flag is to be resolved as soon as one of the
            two is connected to by an edge or child bicomp merge. */

         context->VI[DFSChild].drawingFlag = DRAWINGFLAG_TIE;

         context->VI[descendant].tie[direction] = DFSChild;

         direction = theEmbedding->theStack->S[K+1];
         context->VI[Parent].tie[direction] = DFSChild;

         gp_LogLine(gp_MakeLogStr5("V[Parent=%d]=.tie[%d] = V[descendant=%d].tie[%d] = (child=%d)",
					 Parent, direction, descendant, theEmbedding->theStack->S[K+3], DFSChild));
    }

    gp_LogLine("graphDrawPlanar.c/_CollectDrawingData() end\n");
}

/********************************************************************
 _BreakTie()

 The given vertex W has just been arrived at by the core planarity
 algorithm.  Using WPrevLink, we seek its predecessor WPred on the
 external face and test whether the two are involved in a tie that
 can be resolved.

 Since the planarity algorithm has just passed by WPred, it is
 safe to conclude that WPred can go between W and the current vertex.

 Of course, if W was the parent to some DFS child whose subtree
 contains WPred, then the DFS child is marked 'between', placing
 the whole subtree including WPred between W and the current vertex.
 On the other hand, if WPred was the parent of some DFS child whose
 subtree contained W, then we achieve the same effect of putting WPred
 'between' W and the curent vertex by marking the DFS child 'beyond'.
 Since the DFS child and hence W are beyond W relative to the current
 vertex, WPred is also between W and the current vertex.

 Thus the certain positional relationship between W and WPred
 relative to a specific ancestor, the current vertex, is used to
 indirectly break the positional tie between MIN(W, WPred) and the
 DFS child of MIN(W, WPred) whose subtree contains MAX(W, WPred).

 The ancestorChild is the DFS child of the current vertex whose DFS
 subtree contains W and WPred, and it is recorded here in order to
 optimize the post-processing calculation of vertex positions.
 ********************************************************************/

int _BreakTie(DrawPlanarContext *context, int BicompRoot, int W, int WPrevLink)
{
graphP theEmbedding = context->theGraph;

    /* First we get the predecessor of W. */

int WPredNextLink = 1^WPrevLink,
    WPred = _GetNextExternalFaceVertex(theEmbedding, W, &WPredNextLink);

	gp_LogLine("\ngraphDrawPlanar.c/::_BreakTie() start");
    gp_LogLine(gp_MakeLogStr4("_BreakTie(BicompRoot=%d, W=%d, W_in=%d) WPred=%d",
				 BicompRoot, W, WPrevLink, WPred));

    /* Ties happen only within a bicomp (i.e. between two non-root vertices) */
    if (gp_IsVirtualVertex(theEmbedding, W) || gp_IsVirtualVertex(theEmbedding, WPred))
    {
    	gp_LogLine("graphDrawPlanar.c/_BreakTie() end\n");
        return OK;
    }

    /* The two vertices are either tied or not; having one tied and the other
        not is an error */

    if (context->VI[W].tie[WPrevLink] != context->VI[WPred].tie[WPredNextLink])
        return NOTOK;

    /* If there is a tie, it can now be resolved. */
    if (gp_IsVertex(context->VI[W].tie[WPrevLink]))
    {
        int DFSChild = context->VI[W].tie[WPrevLink];

        /* Set the two ancestor variables that contextualize putting W 'between'
            or 'beyond' its parent relative to what. */

        context->VI[DFSChild].ancestorChild = gp_GetDFSChildFromRoot(theEmbedding, BicompRoot);
        context->VI[DFSChild].ancestor = gp_GetPrimaryVertexFromRoot(theEmbedding, BicompRoot);

        gp_LogLine(gp_MakeLogStr4("V[child=%d]=.ancestorChild = %d, V[child=%d]=.ancestor = %d",
					 DFSChild, context->VI[DFSChild].ancestorChild, DFSChild, context->VI[DFSChild].ancestor));

        /* If W is the ancestor of WPred, then the DFSChild subtree contains
            WPred, and so must go between W and some ancestor. */
        if (W < WPred)
        {
            context->VI[DFSChild].drawingFlag = DRAWINGFLAG_BETWEEN;
            gp_LogLine(gp_MakeLogStr3("Child=%d is 'between' ancestorChild=%d and ancestor=%d",
    					 DFSChild, context->VI[DFSChild].ancestorChild, context->VI[DFSChild].ancestor));
        }

        /* If W is the descendant, so we achieve the effect of putting WPred
           between DFSChild and ancestor by putting the DFSChild 'beyond' WPred. */
        else
        {
            context->VI[DFSChild].drawingFlag = DRAWINGFLAG_BEYOND;
            gp_LogLine(gp_MakeLogStr3("Child=%d is 'beyond' ancestorChild=%d relative to ancestor=%d",
    					 DFSChild, context->VI[DFSChild].ancestorChild, context->VI[DFSChild].ancestor));
        }

        /* The tie is resolved so clear the flags*/
        context->VI[W].tie[WPrevLink] = NIL;
        context->VI[WPred].tie[WPredNextLink] = NIL;
    }

	gp_LogLine("graphDrawPlanar.c/_BreakTie() end\n");
    return OK;
}

/********************************************************************
 _RenderToString()
 Draws the previously calculated visibility representation in a
 string of size (M+1)*2N + 1 characters, which should be deallocated
 with free().

 Returns NULL on failure, or the string containing the visibility
 representation otherwise.  The string can be printed using %s,
 ********************************************************************/

char *_RenderToString(graphP theEmbedding)
{
    DrawPlanarContext *context = NULL;
    gp_FindExtension(theEmbedding, DRAWPLANAR_ID, (void *) &context);

    if (context != NULL)
    {
        int N = theEmbedding->N;
        int M = theEmbedding->M;
        int zeroBasedVertexOffset = (theEmbedding->internalFlags & FLAGS_ZEROBASEDIO) ? gp_GetFirstVertex(theEmbedding) : 0;
        int n, m, EsizeOccupied, v, vRange, e, eRange, Mid, Pos;
        char *visRep = (char *) malloc(sizeof(char) * ((M+1) * 2*N + 1));
        char numBuffer[32];

        if (visRep == NULL)
            return NULL;

        if (sp_NonEmpty(context->theGraph->edgeHoles))
        {
            free(visRep);
            return NULL;
        }

        // Clear the space
    	for (n = 0; n < N; n++)
        {
            for (m=0; m < M; m++)
            {
                visRep[(2*n) * (M+1) + m] = ' ';
                visRep[(2*n+1) * (M+1) + m] = ' ';
            }

            visRep[(2*n) * (M+1) + M] = '\n';
            visRep[(2*n+1) * (M+1) + M] = '\n';
        }

        // Draw the vertices
    	for (v = gp_GetFirstVertex(theEmbedding); gp_VertexInRange(theEmbedding, v); v++)
        {
            Pos = context->VI[v].pos;
            for (vRange=context->VI[v].start; vRange <= context->VI[v].end; vRange++)
                visRep[(2*Pos) * (M+1) + vRange] = '-';

            // Draw vertex label
            Mid = (context->VI[v].start + context->VI[v].end) / 2;
            sprintf(numBuffer, "%d", v - zeroBasedVertexOffset);
            if ((unsigned)(context->VI[v].end - context->VI[v].start + 1) >= strlen(numBuffer))
            {
                strncpy(visRep + (2*Pos) * (M+1) + Mid, numBuffer, strlen(numBuffer));
            }
            // If the vertex width is less than the label width, then fail gracefully
            else
            {
                if (strlen(numBuffer)==2)
                    visRep[(2*Pos) * (M+1) + Mid] = numBuffer[0];
                else
                    visRep[(2*Pos) * (M+1) + Mid] = '*';

                visRep[(2*Pos+1) * (M+1) + Mid] = numBuffer[strlen(numBuffer)-1];
            }
        }

        // Draw the edges
    	EsizeOccupied = gp_EdgeInUseIndexBound(theEmbedding);
        for (e = gp_GetFirstEdge(theEmbedding); e < EsizeOccupied; e+=2)
        {
            Pos = context->E[e].pos;
            for (eRange=context->E[e].start; eRange < context->E[e].end; eRange++)
            {
                if (eRange > context->E[e].start)
                    visRep[(2*eRange) * (M+1) + Pos] = '|';
                visRep[(2*eRange+1) * (M+1) + Pos] = '|';
            }
        }

        // Null terminate string and return it
        visRep[(M+1) * 2*N] = '\0';
        return visRep;
    }

    return NULL;
}

/********************************************************************
 gp_DrawPlanar_RenderToFile()
 Creates a rendition of the planar graph visibility representation
 as a string, then dumps the string to the file.
 ********************************************************************/
int gp_DrawPlanar_RenderToFile(graphP theEmbedding, char *theFileName)
{
    if (sp_IsEmpty(theEmbedding->edgeHoles))
    {
        FILE *outfile;
        char *theRendition;

        if (strcmp(theFileName, "stdout") == 0)
             outfile = stdout;
        else if (strcmp(theFileName, "stderr") == 0)
             outfile = stderr;
        else outfile = fopen(theFileName, WRITETEXT);

        if (outfile == NULL)
            return NOTOK;

        theRendition = _RenderToString(theEmbedding);
        if (theRendition != NULL)
        {
            fprintf(outfile, "%s", theRendition);
            free(theRendition);
        }

        if (strcmp(theFileName, "stdout") == 0 || strcmp(theFileName, "stderr") == 0)
            fflush(outfile);

        else if (fclose(outfile) != 0)
            return NOTOK;

        return theRendition ? OK : NOTOK;
    }

    return NOTOK;
}

/********************************************************************
 _CheckVisibilityRepresentationIntegrity()
 ********************************************************************/

int _CheckVisibilityRepresentationIntegrity(DrawPlanarContext *context)
{
graphP theEmbedding = context->theGraph;
int v, e, eTwin, EsizeOccupied, epos, eposIndex;

    if (sp_NonEmpty(context->theGraph->edgeHoles))
        return NOTOK;

    _ClearVisitedFlags(theEmbedding);

/* Test whether the vertex values make sense and
        whether the vertex positions are unique. */

	for (v = gp_GetFirstVertex(theEmbedding); gp_VertexInRange(theEmbedding, v); v++)
    {
    	if (theEmbedding->M > 0)
    	{
            if (context->VI[v].pos < 0 ||
                context->VI[v].pos >= theEmbedding->N ||
                context->VI[v].start < 0 ||
                context->VI[v].start > context->VI[v].end ||
                context->VI[v].end >= theEmbedding->M)
                return NOTOK;
    	}

        // Has the vertex position been used by a vertex before vertex v?
        if (gp_GetVertexVisited(theEmbedding, context->VI[v].pos + gp_GetFirstVertex(theEmbedding)))
            return NOTOK;

        // Mark the vertex position as used by vertex v.
        // Note that this marking is made on some other vertex unrelated to v
        // We're just reusing the vertex visited array as cheap storage for a
        // detector of reusing vertex position integers.
        gp_SetVertexVisited(theEmbedding, context->VI[v].pos + gp_GetFirstVertex(theEmbedding));
    }

/* Test whether the edge values make sense and
        whether the edge positions are unique */

	EsizeOccupied = gp_EdgeInUseIndexBound(theEmbedding);
    for (e = gp_GetFirstEdge(theEmbedding); e < EsizeOccupied; e+=2)
    {
        /* Each edge has two index locations in the edge information array */
        eTwin = gp_GetTwinArc(theEmbedding, e);

        if (context->E[e].pos != context->E[eTwin].pos ||
            context->E[e].start != context->E[eTwin].start ||
            context->E[e].end != context->E[eTwin].end ||
            context->E[e].pos < 0 ||
            context->E[e].pos >= theEmbedding->M ||
            context->E[e].start < 0 ||
            context->E[e].start > context->E[e].end ||
            context->E[e].end >= theEmbedding->N)
            return NOTOK;

        /* Get the recorded horizontal position of that edge,
            a number between 0 and M-1 */

        epos = context->E[e].pos;

        /* Convert that to an index in the graph structure so we
            can use the visited flags in the graph's edges to
            tell us whether the positions are being reused. */

        eposIndex = (epos<<1) + gp_GetFirstEdge(theEmbedding);
        eTwin = gp_GetTwinArc(theEmbedding, eposIndex);

        if (gp_GetEdgeVisited(theEmbedding, eposIndex) || gp_GetEdgeVisited(theEmbedding, eTwin))
            return NOTOK;

        gp_SetEdgeVisited(theEmbedding, eposIndex);
        gp_SetEdgeVisited(theEmbedding, eTwin);
    }

/* Test whether any edge intersects any vertex position
    for a vertex that is not an endpoint of the edge. */

	EsizeOccupied = gp_EdgeInUseIndexBound(theEmbedding);
    for (e = gp_GetFirstEdge(theEmbedding); e < EsizeOccupied; e+=2)
    {
        eTwin = gp_GetTwinArc(theEmbedding, e);

    	for (v = gp_GetFirstVertex(theEmbedding); gp_VertexInRange(theEmbedding, v); v++)
        {
            /* If the vertex is an endpoint of the edge, then... */

            if (gp_GetNeighbor(theEmbedding, e) == v || gp_GetNeighbor(theEmbedding, eTwin) == v)
            {
                /* The vertical position of the vertex must be
                   at the top or bottom of the edge,  */
                if (context->E[e].start != context->VI[v].pos &&
                    context->E[e].end != context->VI[v].pos)
                    return NOTOK;

                /* The horizontal edge position must be in the range of the vertex */
                if (context->E[e].pos < context->VI[v].start ||
                    context->E[e].pos > context->VI[v].end)
                    return NOTOK;
            }

            /* If the vertex is not an endpoint of the edge... */

            else // if (gp_GetNeighbor(theEmbedding, e) != v && gp_GetNeighbor(theEmbedding, eTwin) != v)
            {
                /* If the vertical position of the vertex is in the
                    vertical range of the edge ... */

                if (context->E[e].start <= context->VI[v].pos &&
                    context->E[e].end >= context->VI[v].pos)
                {
                    /* And if the horizontal position of the edge is in the
                        horizontal range of the vertex, then return an error. */

                    if (context->VI[v].start <= context->E[e].pos &&
                        context->VI[v].end >= context->E[e].pos)
                        return NOTOK;
                }
            }
        }
    }


/* All tests passed */

    return OK;
}
