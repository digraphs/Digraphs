/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#define GRAPHNONPLANAR_C

#include "graph.h"

/* Imported functions */

extern void _InitIsolatorContext(graphP theGraph);
extern int  _ClearVisitedFlagsInBicomp(graphP theGraph, int BicompRoot);
extern int  _ClearVertexTypeInBicomp(graphP theGraph, int BicompRoot);
extern int  _HideInternalEdges(graphP theGraph, int vertex);
extern int  _RestoreInternalEdges(graphP theGraph, int stackBottom);

//extern int  _OrientVerticesInEmbedding(graphP theGraph);
extern int  _OrientVerticesInBicomp(graphP theGraph, int BicompRoot, int PreserveSigns);

/* Private functions (exported to system) */

int  _ChooseTypeOfNonplanarityMinor(graphP theGraph, int v, int R);
int  _InitializeNonplanarityContext(graphP theGraph, int v, int R);

int  _GetNeighborOnExtFace(graphP theGraph, int curVertex, int *pPrevLink);
void _FindActiveVertices(graphP theGraph, int R, int *pX, int *pY);
int  _FindPertinentVertex(graphP theGraph);
int  _SetVertexTypesForMarkingXYPath(graphP theGraph);

int  _PopAndUnmarkVerticesAndEdges(graphP theGraph, int Z, int stackBottom);

int  _MarkHighestXYPath(graphP theGraph);
int  _MarkZtoRPath(graphP theGraph);
int  _FindFuturePertinenceBelowXYPath(graphP theGraph);

/****************************************************************************
 _ChooseTypeOfNonplanarityMinor()
 ****************************************************************************/

int  _ChooseTypeOfNonplanarityMinor(graphP theGraph, int v, int R)
{
int  X, Y, W, Px, Py, Z;

/* Create the initial non-planarity minor state in the isolator context */

     if (_InitializeNonplanarityContext(theGraph, v, R) != OK)
         return NOTOK;

     R = theGraph->IC.r;
     X = theGraph->IC.x;
     Y = theGraph->IC.y;
     W = theGraph->IC.w;

/* If the root copy is not a root copy of the current vertex v,
        then the Walkdown terminated because it couldn't find
        a viable path along a child bicomp, which is Minor A. */

     if (gp_GetPrimaryVertexFromRoot(theGraph, R) != v)
     {
         theGraph->IC.minorType |= MINORTYPE_A;
         return OK;
     }

/* If W has a pertinent and future pertinent child bicomp, then we've found Minor B */

     if (gp_IsVertex(gp_GetVertexPertinentRootsList(theGraph, W)))
     {
         if (gp_GetVertexLowpoint(theGraph, gp_GetVertexLastPertinentRootChild(theGraph, W)) < v)
         {
             theGraph->IC.minorType |= MINORTYPE_B;
             return OK;
         }
     }

/* Find the highest obstructing X-Y path */

     if (_MarkHighestXYPath(theGraph) != TRUE)
         return NOTOK;

     Px = theGraph->IC.px;
     Py = theGraph->IC.py;

/* If either point of attachment is 'high' (P_x closer to R than X
     or P_y closer to R than Y along external face), then we've
     matched Minor C. */

     if (gp_GetVertexObstructionType(theGraph, Px) == VERTEX_OBSTRUCTIONTYPE_HIGH_RXW ||
         gp_GetVertexObstructionType(theGraph, Py) == VERTEX_OBSTRUCTIONTYPE_HIGH_RYW)
     {
            theGraph->IC.minorType |= MINORTYPE_C;
            return OK;
     }

/* For Minor D, we search for a path from an internal
     vertex Z along the X-Y path up to the root R of the bicomp. */

     if (_MarkZtoRPath(theGraph) != OK)
         return NOTOK;

     if (gp_IsVertex(theGraph->IC.z))
     {
         theGraph->IC.minorType |= MINORTYPE_D;
         return OK;
     }

/* For Minor E, we search for an future pertinent vertex Z
     below the points of attachment of the X-Y path */

     Z = _FindFuturePertinenceBelowXYPath(theGraph);
     if (gp_IsVertex(Z))
     {
         theGraph->IC.z = Z;
         theGraph->IC.minorType |= MINORTYPE_E;
         return OK;
     }

     return NOTOK;
}

/****************************************************************************
 _InitializeNonplanarityContext()

 This method finds the stopping vertices X and Y, and the pertinent vertex W
 of a bicomp rooted by vertex R.

 If R is NIL, the routine first determines which bicomp produced non-planarity
 condition.  If the stack is non-empty, then R is on the top of the stack.
 Otherwise, an unembedded fwdArc from the fwdArcList of vertex v is used in
 combination with the sortedDFSChildList of v to determine R.

 If the parameter R was not NIL, then this method assumes it must operate
 only on the bicomp rooted by R, and it also assumes that the caller has
 not cleared the visited flags in the bicomp, so they are cleared.

 This routine imparts consistent orientation to all vertices in bicomp R
 since several subroutines count on this. The edge signs are preserved so that
 the original orientations of all vertices can be restored.  If the vertices
 of the embedding are already consistently oriented, then this operation
 simply has no effect.

 Finally, in the bicomp R, the vertex types of all non-root vertices on the
 external face are classified according to whether or not they are closer to
 the root R than X and Y along the external face paths (R X W) and (R Y W).
 ****************************************************************************/

int  _InitializeNonplanarityContext(graphP theGraph, int v, int R)
{
	 // Blank out the isolator context, then assign the input graph reference
     // and the current vertext v into the context.
     _InitIsolatorContext(theGraph);
     theGraph->IC.v = v;

     // The bicomp root provided was the one on which the WalkDown was performed,
     // but in the case of Minor A, the central bicomp of the minor is at the top
     // of the stack, so R must be changed to that value.
	 if (sp_NonEmpty(theGraph->theStack))
	 {
		 int dummy;
		 sp_Pop2(theGraph->theStack, R, dummy);
	 }

     theGraph->IC.r = R;

     // A number of subroutines require the main bicomp of the minor to be
     // consistently oriented and its visited flags clear.
     if (_OrientVerticesInBicomp(theGraph, R, 1) != OK)
    	 return NOTOK;

	 if (_ClearVisitedFlagsInBicomp(theGraph, R) != OK)
		 return NOTOK;

     // Now we find the active vertices along both external face paths
     // extending from R.
     _FindActiveVertices(theGraph, R, &theGraph->IC.x, &theGraph->IC.y);

     // Now, we obtain the pertinent vertex W on the lower external face
     // path between X and Y (that path that does not include R).
     theGraph->IC.w = _FindPertinentVertex(theGraph);

 	 // Now we can classify the vertices along the external face of the bicomp
 	 // rooted at R as 'high RXW', 'low RXW', 'high RXY', 'low RXY'
     if (_SetVertexTypesForMarkingXYPath(theGraph) != OK)
    	 return NOTOK;

     // All work is done, so return success
     return OK;
}

/********************************************************************
 _GetNeighborOnExtFace()

 Each vertex contains two 'link' index pointers that indicate the
 first and last adjacency list arc.  If the vertex is on the external face,
 then these two arcs are also on the external face.  We want to take one of
 those edges to get to the next vertex on the external face.
 On input *pPrevLink indicates which link we followed to arrive at
 curVertex.  On output *pPrevLink will be set to the link we follow to
 get into the next vertex.
 To get to the next vertex, we use the opposite link from the one used
 to get into curVertex.  This takes us to an edge node.  The twinArc
 of that edge node, carries us to an edge node in the next vertex.
 At least one of the two links in that edge node will lead to a vertex
 node in G, which is the next vertex.  Once we arrive at the next
 vertex, at least one of its links will lead back to the edge node, and
 that link becomes the output value of *pPrevLink.

 NOTE: This method intentionally ignores the extFace optimization
       links. It is invoked when the "real" external face must be
       traversed and hence when the constant time guarantee is not
       needed from the extFace short-circuit that connects the
       bicomp root to the first active vertices along each external
       face path emanating from the bicomp root.
 ********************************************************************/

int  _GetNeighborOnExtFace(graphP theGraph, int curVertex, int *pPrevLink)
{
     /* Exit curVertex from whichever link was not previously used to enter it */

     int arc = gp_GetArc(theGraph, curVertex, 1^(*pPrevLink));
     int nextVertex = gp_GetNeighbor(theGraph, arc);

     /* This if stmt assigns the new prev link that tells us which edge
        record was used to enter nextVertex (so that we exit from the
        opposing edge record).

        However, if we are in a singleton bicomp, then both links in nextVertex
        lead back to curVertex.  We want the two arcs of a singleton bicomp to
        act like a cycle, so we just don't change the prev link in this case.

        But when nextVertex has more than one edge, we need to figure out
        whether the first edge or last edge (which are the two on the external
        face) was used to enter nextVertex so we can exit from the other one
        as traversal of the external face continues later. */

     if (gp_GetFirstArc(theGraph, nextVertex) != gp_GetLastArc(theGraph, nextVertex))
         *pPrevLink = gp_GetTwinArc(theGraph, arc) == gp_GetFirstArc(theGraph, nextVertex) ? 0 : 1;

     return nextVertex;
}

/****************************************************************************
 _FindActiveVertices()

 Descends from the root of a bicomp R along both external face paths (which
 are indicated by the first and last arcs in R's adjacency list), returning
 the first active vertex appearing in each direction.
 ****************************************************************************/

void _FindActiveVertices(graphP theGraph, int R, int *pX, int *pY)
{
int  XPrevLink=1, YPrevLink=0, v=theGraph->IC.v;

     *pX = _GetNeighborOnExtFace(theGraph, R, &XPrevLink);
     *pY = _GetNeighborOnExtFace(theGraph, R, &YPrevLink);

     // For planarity algorithms, advance past inactive vertices
     // For outerplanarity algorithms, ignore the notion of inactive vertices
     // since all vertices must remain on the external face.
     if (!(theGraph->embedFlags & EMBEDFLAGS_OUTERPLANAR))
     {
         gp_UpdateVertexFuturePertinentChild(theGraph, *pX, v);
         while (INACTIVE(theGraph, *pX, v))
         {
            *pX = _GetNeighborOnExtFace(theGraph, *pX, &XPrevLink);
            gp_UpdateVertexFuturePertinentChild(theGraph, *pX, v);
         }

         gp_UpdateVertexFuturePertinentChild(theGraph, *pY, v);
         while (INACTIVE(theGraph, *pY, v))
         {
            *pY = _GetNeighborOnExtFace(theGraph, *pY, &YPrevLink);
            gp_UpdateVertexFuturePertinentChild(theGraph, *pY, v);
         }
     }
}

/****************************************************************************
 _FindPertinentVertex()

 Get the first vertex after x. Since x was obtained using a prevlink of 1 on r,
 we use the same prevlink so we don't go back to R.
 Then, we proceed around the lower path until we find a vertex W that either
 has pertinent child bicomps or is directly adjacent to the current vertex v.
 ****************************************************************************/

int  _FindPertinentVertex(graphP theGraph)
{
int  W=theGraph->IC.x, WPrevLink=1;

     W = _GetNeighborOnExtFace(theGraph, W, &WPrevLink);

     while (W != theGraph->IC.y)
     {
         if (PERTINENT(theGraph, W))
             return W;

         W = _GetNeighborOnExtFace(theGraph, W, &WPrevLink);
     }

     return NIL;
}

/****************************************************************************
 _SetVertexTypesForMarkingXYPath()

 Label the vertices along the external face of the bicomp rooted at R as
 'high RXW', 'low RXW', 'high RXY', 'low RXY'
 ****************************************************************************/

int  _SetVertexTypesForMarkingXYPath(graphP theGraph)
{
	int  v, R, X, Y, W, Z, ZPrevLink, ZType;

	// Unpack the context for efficiency of loops
	v = theGraph->IC.v;
	R = theGraph->IC.r;
	X = theGraph->IC.x;
	Y = theGraph->IC.y;
	W = theGraph->IC.w;

	// Ensure basic preconditions of this routine are met
	if (gp_IsNotVertex(R) || gp_IsNotVertex(X) || gp_IsNotVertex(Y) || gp_IsNotVertex(W))
		return NOTOK;

	// Clear the type member of each vertex in the bicomp
	if (_ClearVertexTypeInBicomp(theGraph, R) != OK)
		return NOTOK;

	// Traverse from R to W in the X direction
	ZPrevLink = 1;
	Z = _GetNeighborOnExtFace(theGraph, R, &ZPrevLink);
	ZType = VERTEX_OBSTRUCTIONTYPE_HIGH_RXW;
	while (Z != W)
	{
		if (Z == X) ZType = VERTEX_OBSTRUCTIONTYPE_LOW_RXW;
		gp_ResetVertexObstructionType(theGraph, Z, ZType);
		Z = _GetNeighborOnExtFace(theGraph, Z, &ZPrevLink);
	}

	// Traverse from R to W in the Y direction
	ZPrevLink = 0;
	Z = _GetNeighborOnExtFace(theGraph, R, &ZPrevLink);
	ZType = VERTEX_OBSTRUCTIONTYPE_HIGH_RYW;
	while (Z != W)
	{
		if (Z == Y) ZType = VERTEX_OBSTRUCTIONTYPE_LOW_RYW;
		gp_ResetVertexObstructionType(theGraph, Z, ZType);
		Z = _GetNeighborOnExtFace(theGraph, Z, &ZPrevLink);
	}

	return OK;
}

/****************************************************************************
 _PopAndUnmarkVerticesAndEdges()

 Pop all vertex/edge pairs from the top of the stack up to a terminating
 vertex Z and mark as unvisited.  If Z is NIL, then all vertex/edge pairs
 are popped and marked as unvisited.
 The stackBottom indicates where other material besides the vertex/edge
 pairs may appear.
 ****************************************************************************/

int  _PopAndUnmarkVerticesAndEdges(graphP theGraph, int Z, int stackBottom)
{
int  V, e;

     // Pop vertex/edge pairs until all have been popped from the stack,
     // and all that's left is what was under the pairs, or until...
     while (sp_GetCurrentSize(theGraph->theStack) > stackBottom)
     {
         sp_Pop(theGraph->theStack, V);

         // If we pop the terminating vertex Z, then put it back and break
         if (V == Z)
         {
             sp_Push(theGraph->theStack, V);
             break;
         }

         // Otherwise, pop the edge part of the vertex/edge pair
         sp_Pop(theGraph->theStack, e);

         // Now unmark the vertex and edge (i.e. revert to "unvisited")
         gp_ClearVertexVisited(theGraph, V);
         gp_ClearEdgeVisited(theGraph, e);
         gp_ClearEdgeVisited(theGraph, gp_GetTwinArc(theGraph, e));
     }

     return OK;
}

/****************************************************************************
 _MarkHighestXYPath()

 An X-Y path in the bicomp rooted by R is a path attached to the external
 face at points Px and Py that separates W from R such that a back edge (R, W)
 cannot be embedded within the bicomp. Recall that R is a root copy of v, so
 (R, W) is the representative of (v, W).  Also, note that W is pertinent if
 either W *or* one of its descendants in a separate bicomp has, in the input
 graph, a back edge to v.

 If no X-Y path separating W from R is found, then NOTOK is returned because
 the proof of correctness guarantees that one exists (although this routine
 can also be used to help test for the existence of an X-Y path, and NOTOK
 means 'no' in that case).

 The desired output is to set the 'visited' flags of the X-Y path with
 highest points of attachment to the external face (i.e. the points of
 attachment that are closest to R along the external face).  This includes
 marking both the vertices and edges along the X-Y path.

 Previously, during non-planarity context initialization, the vertices along
 the external face (other than R and W) have been classified as 'high RXW',
 'low RXW', 'high RXY', or 'low RXY'. Once the vertices have been categorized,
 we proceed with trying to set the visitation flags in the way described above.
 First, we remove all edges incident to R except the two edges that join R to
 the external face. The result is that R and its two remaining edges are a
 'corner' in the external face but also in a single proper face whose boundary
 includes the X-Y path with the highest attachment points. Thus, we simply need
 to walk this proper face to find the desired X-Y path. Note, however, that the
 resulting face boundary may have attached cut vertices.  Any such separable
 component contains a vertex neighbor of R, but the edge to R has been
 temporarily removed.  The algorithm removes loop of vertices and edges along
 the proper face so that only a path is identified.

 To walk the proper face containing R, we begin with its first arc successor,
 then take the *predecessor* arc at every subsequent corner.  For each vertex,
 we mark as visited the vertex as well as the edge used to enter the vertex
 (except for the edge used to enter the RXW vertex).  We also push the visited
 vertices and edges onto a stack.

 As we walk the proper face, we keep track of the last vertex P_x we visited of
 type RXW (high or low).  Each time we encounter a vertex of type RXW (high or
 low), we pop the stack and unmark all of the edges and vertices visited because
 they were part of a path parallel to the external face that does not obstruct
 W from reaching R within the bicomp.  If we encounter vertex W, then there is
 no obstructing X-Y path since we removed only edges incident to R, so we pop
 the stack unmarking everything then return NOTOK as stated above.  If we
 encounter a vertex Z previously visited, then we pop the stack, unmarking the
 vertices and edges popped, until we find the prior occurence of Z on the stack.

 Otherwise, the first time we encounter a vertex P_y of type 'RYW', we stop
 because the obstructing X-Y path has been marked visited and its points of
 connection P_x and P_y have been found.

 Once the X-Y path is identified, we restore the edges incident to R.

 This method uses the stack, but it preserves any prior content.
 The stack space used is no greater than 3N.  The first N accounts for removing
 the edges incident to R.  The other 2N accounts for the fact that each
 iteration of the main loop visits a vertex, pushing its index and the
 location of an edge record.  If a vertex is encountered that is already
 on the stack, then it is not pushed again (and in fact part of the stack
 is removed).

 Returns TRUE if the X-Y path is found, FALSE otherwise.
 In debug mode it can also return NOTOK. This is equivalent to FALSE, but
 NOTOK is better for documenting the error condition in the code, and
 it produces a debug message. Also, in many cases the equivalent-to-FALSE
 result is an error condition for the caller, so NOTOK usually percolates up.
 ****************************************************************************/

int  _MarkHighestXYPath(graphP theGraph)
{
int e, Z;
int R, X, Y, W;
int stackBottom1, stackBottom2;

/* Initialization */

     R = theGraph->IC.r;
     X = theGraph->IC.x;
     Y = theGraph->IC.y;
     W = theGraph->IC.w;
     theGraph->IC.px = theGraph->IC.py = NIL;

/* Save the stack bottom before we start hiding internal edges, so
   we will know how many edges to restore */

     stackBottom1 = sp_GetCurrentSize(theGraph->theStack);

/* Remove the internal edges incident to vertex R */

     if (_HideInternalEdges(theGraph, R) != OK)
    	 return NOTOK;

/* Now we're going to use the stack to collect the vertices of potential
 * X-Y paths, so we need to store where the hidden internal edges are
 * located because we must, at times, pop the collected vertices if
 * the path being collected doesn't work out. */

     stackBottom2 = sp_GetCurrentSize(theGraph->theStack);

/* Walk the proper face containing R to find and mark the highest
        X-Y path. Note that if W is encountered, then there is no
        intervening X-Y path, so we would return FALSE in that case. */

     Z = R;
     // This setting of e is the arc equivalent of prevLink=1
     // As loop progresses, e indicates the arc used to enter Z, not the exit arc
     e = gp_GetLastArc(theGraph, R);

     while (gp_GetVertexObstructionType(theGraph, Z) != VERTEX_OBSTRUCTIONTYPE_HIGH_RYW &&
    		gp_GetVertexObstructionType(theGraph, Z) != VERTEX_OBSTRUCTIONTYPE_LOW_RYW)
     {
          /* Advance e and Z along the proper face containing R */

    	  e = gp_GetPrevArcCircular(theGraph, e);
          Z = gp_GetNeighbor(theGraph, e);
          e = gp_GetTwinArc(theGraph, e);

          /* If Z is already visited, then pop everything since the last time
                we visited Z because its all part of a separable component. */

          if (gp_GetVertexVisited(theGraph, Z))
          {
              if (_PopAndUnmarkVerticesAndEdges(theGraph, Z, stackBottom2) != OK)
            	  return NOTOK;
          }

          /* If we have not visited this vertex before... */

          else
          {
              /* If we find W, then there is no X-Y path. Never happens
                 for Kuratowski subgraph isolator, but this routine is
                 also used to test for certain X-Y paths.
                 So, we clean up and bail out in that case. */

              if (Z == W)
              {
                  if (_PopAndUnmarkVerticesAndEdges(theGraph, NIL, stackBottom2) != OK)
                	  return NOTOK;
                  break;
              }

              /* If we found another vertex along the RXW path, then blow off
                 all the vertices we visited so far because they're not part of
                 the obstructing path */

              if (gp_GetVertexObstructionType(theGraph, Z) == VERTEX_OBSTRUCTIONTYPE_HIGH_RXW ||
                  gp_GetVertexObstructionType(theGraph, Z) == VERTEX_OBSTRUCTIONTYPE_LOW_RXW)
              {
                  theGraph->IC.px = Z;
                  if (_PopAndUnmarkVerticesAndEdges(theGraph, NIL, stackBottom2) != OK)
                	  return NOTOK;
              }

              /* Push the current vertex onto the stack of vertices visited
                 since the last RXW vertex was encountered */

              sp_Push(theGraph->theStack, e);
              sp_Push(theGraph->theStack, Z);

              /* Mark the vertex Z as visited as well as its edge of entry
                 (except the entry edge for P_x).*/

              gp_SetVertexVisited(theGraph, Z);
              if (Z != theGraph->IC.px)
              {
                  gp_SetEdgeVisited(theGraph, e);
                  gp_SetEdgeVisited(theGraph, gp_GetTwinArc(theGraph, e));
              }

              /* If we found an RYW vertex, then we have successfully finished
                 identifying the highest X-Y path, so we record the point of
                 attachment and break the loop. */

              if (gp_GetVertexObstructionType(theGraph, Z) == VERTEX_OBSTRUCTIONTYPE_HIGH_RYW ||
                  gp_GetVertexObstructionType(theGraph, Z) == VERTEX_OBSTRUCTIONTYPE_LOW_RYW)
              {
                 theGraph->IC.py = Z;
                 break;
              }
          }
     }

/* Remove any remaining vertex-edge pairs on the top of the stack, then
    Restore the internal edges incident to R that were previously removed. */

     sp_SetCurrentSize(theGraph->theStack, stackBottom2);

     if (_RestoreInternalEdges(theGraph, stackBottom1) != OK)
    	 return NOTOK;

/* Return the result */

     return gp_IsVertex(theGraph->IC.py) ? TRUE : FALSE;
}

/****************************************************************************
 _MarkZtoRPath()

 This function assumes that _MarkHighestXYPath() has already been called,
 which marked as visited the vertices and edges along the X-Y path.

 We begin at the point of attachment P_x, take the last arc and traverse
 the predecessor arcs until we find one marked visited, which leads to the
 first internal vertex along the X-Y path.  We begin with this vertex
 (and its edge of entry), and we run until we find P_y. For each internal
 vertex Z and its edge of entry ZPrevArc, we take the predecessor edge record
 of ZPrevArc.  This is called ZNextArc.  If ZNextArc is marked visited
 then it is along the X-Y path, so we use it to exit Z and go to the next
 vertex on the X-Y path.

 If ZNextArc is not visited, then when _MarkHighestXYPath() ran, it exited
 Z from ZNextArc, then eventually reentered Z.  In other words, Z became a
 cut vertex when we removed the internal edges incident to R. Thus, ZNextArc
 indicates the first edge in an internal path to R.

 When we find an unvisited ZNextArc, we stop running the X-Y path and instead
 begin marking the Z to R path.  We move to successive vertices using a
 twin arc then its predecessor arc in the adjacency list, only this time
 we have not removed the internal edges incident to R, so this technique does
 eventually lead us all the way to R.

 If we do not find an unvisited ZNextArc for any vertex Z on the X-Y path and
 inside the bicomp, then there is no Z to R path, so we return.
 ****************************************************************************/

int  _MarkZtoRPath(graphP theGraph)
{
int ZPrevArc, ZNextArc, Z, R, Px, Py;

/* Initialize */

    R = theGraph->IC.r;
    Px = theGraph->IC.px;
    Py = theGraph->IC.py;
    theGraph->IC.z = NIL;

/* Begin at Px and search its adjacency list for the edge leading to
   the first internal vertex of the X-Y path. */

    Z = Px;
    ZNextArc = gp_GetLastArc(theGraph, Z);
    while (ZNextArc != gp_GetFirstArc(theGraph, Z))
    {
       if (gp_GetEdgeVisited(theGraph, ZNextArc)) break;

       ZNextArc = gp_GetPrevArc(theGraph, ZNextArc);
    }

    if (!gp_GetEdgeVisited(theGraph, ZNextArc))
        return NOTOK;

/* For each internal vertex Z, determine whether it has a path to root. */

    while (gp_GetEdgeVisited(theGraph, ZNextArc))
    {
        ZPrevArc = gp_GetTwinArc(theGraph, ZNextArc);
        ZNextArc = gp_GetPrevArcCircular(theGraph, ZPrevArc);
    }

    ZPrevArc = gp_GetTwinArc(theGraph, ZNextArc);
    Z = gp_GetNeighbor(theGraph, ZPrevArc);

/* If there is no Z to R path, return */

    if (Z == Py) return OK;

/* Otherwise, store Z in the isolation context */

    theGraph->IC.z = Z;

/* Walk the proper face starting with (Z, ZNextArc) until we reach R, marking
        the vertices and edges encountered along the way, then Return OK. */

    while (Z != R)
    {
        /* If we ever encounter a non-internal vertex (other than the root R),
                then corruption has occured, so we return NOTOK */

        if (gp_GetVertexObstructionType(theGraph, Z) != VERTEX_OBSTRUCTIONTYPE_UNKNOWN)
            return NOTOK;

        /* Go to the next vertex indicated by ZNextArc */

        Z = gp_GetNeighbor(theGraph, ZNextArc);

        /* Mark the next vertex and the edge leading to it as visited. */

        gp_SetEdgeVisited(theGraph, ZNextArc);
        gp_SetEdgeVisited(theGraph, ZPrevArc);
        gp_SetVertexVisited(theGraph, Z);

        /* Go to the next edge in the proper face */

        ZNextArc = gp_GetPrevArcCircular(theGraph, ZPrevArc);
        ZPrevArc = gp_GetTwinArc(theGraph, ZNextArc);
    }

/* Found Z to R path, so indicate as much to caller */

    return OK;
}

/****************************************************************************
 _FindFuturePertinenceBelowXYPath()

 Get a future pertinent vertex along the lower external face path between
 the points of attachment P_x and P_y of a 'low' X-Y Path.
 NOTE: By the time this function is called, Px and Py have already been found
        to be at or below X and Y.
 ****************************************************************************/

int  _FindFuturePertinenceBelowXYPath(graphP theGraph)
{
int  Z=theGraph->IC.px, ZPrevLink=1,
     Py=theGraph->IC.py, v=theGraph->IC.v;

     Z = _GetNeighborOnExtFace(theGraph, Z, &ZPrevLink);

     while (Z != Py)
     {
    	 gp_UpdateVertexFuturePertinentChild(theGraph, Z, v);
         if (FUTUREPERTINENT(theGraph, Z, v))
             return Z;

         Z = _GetNeighborOnExtFace(theGraph, Z, &ZPrevLink);
     }

     return NIL;
}
