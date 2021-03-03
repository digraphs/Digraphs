/*
Copyright (c) 1997-2020, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include <stdlib.h>

#include "graph.h"

/* Imported functions */

extern void _ClearVertexVisitedFlags(graphP theGraph, int);

extern int _IsolateKuratowskiSubgraph(graphP theGraph, int v, int R);
extern int _IsolateOuterplanarObstruction(graphP theGraph, int v, int R);

extern void _InitVertexRec(graphP theGraph, int v);

/* Private functions (some are exported to system only) */

int  _EmbeddingInitialize(graphP theGraph);

void _EmbedBackEdgeToDescendant(graphP theGraph, int RootSide, int RootVertex, int W, int WPrevLink);

void _InvertVertex(graphP theGraph, int V);
void _MergeVertex(graphP theGraph, int W, int WPrevLink, int R);
int  _MergeBicomps(graphP theGraph, int v, int RootVertex, int W, int WPrevLink);

void _WalkUp(graphP theGraph, int v, int e);
int  _WalkDown(graphP theGraph, int v, int RootVertex);

int  _HandleBlockedBicomp(graphP theGraph, int v, int RootVertex, int R);
void _AdvanceFwdArcList(graphP theGraph, int v, int child, int nextChild);

int  _EmbedPostprocess(graphP theGraph, int v, int edgeEmbeddingResult);
int  _OrientVerticesInEmbedding(graphP theGraph);
int  _OrientVerticesInBicomp(graphP theGraph, int BicompRoot, int PreserveSigns);
int  _JoinBicomps(graphP theGraph);

/********************************************************************
 gp_Embed()

  Either a planar embedding is created in theGraph, or a Kuratowski
  subgraph is isolated.  Either way, theGraph remains sorted by DFI
  since that is the most common desired result.  The original vertex
  numbers are available in the 'index' members of the vertex records.
  Moreover, gp_SortVertices() can be invoked to put the vertices in
  the order of the input graph, at which point the 'index' members of
  the vertex records will contain the vertex DFIs.

 return OK if the embedding was successfully created or no subgraph
            homeomorphic to a topological obstruction was found.

        NOTOK on internal failure

        NONEMBEDDABLE if the embedding couldn't be created due to
                the existence of a subgraph homeomorphic to a
                topological obstruction.

  For core planarity, OK is returned when theGraph contains a planar
  embedding of the input graph, and NONEMBEDDABLE is returned when a
  subgraph homeomorphic to K5 or K3,3 has been isolated in theGraph.

  Extension modules can overload functions used by gp_Embed to achieve
  alternate algorithms.  In those cases, the return results are
  similar.  For example, a K3,3 search algorithm would return
  NONEMBEDDABLE if it finds the K3,3 obstruction, and OK if the graph
  is planar or only contains K5 homeomorphs.  Similarly, an
  outerplanarity module can return OK for an outerplanar embedding or
  NONEMBEDDABLE when a subgraph homeomorphic to K2,3 or K4 has been
  isolated.

  The algorithm extension for gp_Embed() is encoded in the embedFlags,
  and the details of the return value can be found in the extension
  module that defines the embedding flag.
 ********************************************************************/

int gp_Embed(graphP theGraph, int embedFlags)
{
int v, e, c;
int RetVal = OK;

    // Basic parameter checks
    if (theGraph==NULL)
    	return NOTOK;

    // Preprocessing
    theGraph->embedFlags = embedFlags;

    // Allow extension algorithms to postprocess the DFS
    if (theGraph->functions.fpEmbeddingInitialize(theGraph) != OK)
    	return NOTOK;

    // In reverse DFI order, embed the back edges from each vertex to its DFS descendants.
    for (v = gp_GetLastVertex(theGraph); gp_VertexInRangeDescending(theGraph, v); v--)
    {
          RetVal = OK;

          // Walkup calls establish Pertinence in Step v
          // Do the Walkup for each cycle edge from v to a DFS descendant W.
          e = gp_GetVertexFwdArcList(theGraph, v);
          while (gp_IsArc(e))
          {
        	  theGraph->functions.fpWalkUp(theGraph, v, e);

              e = gp_GetNextArc(theGraph, e);
              if (e == gp_GetVertexFwdArcList(theGraph, v))
                  e = NIL;
          }
          gp_SetVertexPertinentRootsList(theGraph, v, NIL);

          // Work systematically through the DFS children of vertex v, using Walkdown
          // to add the back edges from v to its descendants in each of the DFS subtrees
          c = gp_GetVertexSortedDFSChildList(theGraph, v);
          while (gp_IsVertex(c))
          {
        	  if (gp_IsVertex(gp_GetVertexPertinentRootsList(theGraph, c)))
        	  {
        		  RetVal = theGraph->functions.fpWalkDown(theGraph, v, gp_GetRootFromDFSChild(theGraph, c));
        		  // If Walkdown returns OK, then it is OK to proceed with edge addition.
        		  // Otherwise, if Walkdown returns NONEMBEDDABLE then we stop edge addition.
				  if (RetVal != OK)
					  break;
        	  }
        	  c = gp_GetVertexNextDFSChild(theGraph, v, c);
          }

          // If the Walkdown determined that the graph is NONEMBEDDABLE,
          // then the guiding embedder loop can be stopped now.
          if (RetVal != OK)
        	  break;
    }

    // Postprocessing to orient the embedding and merge any remaining separated bicomps.
    // Some extension algorithms may overload this function, e.g. to do nothing if they
    // have no need of an embedding.
    return theGraph->functions.fpEmbedPostprocess(theGraph, v, RetVal);
}

/********************************************************************
 _EmbeddingInitialize()

 This method performs the following tasks:
 (1) Assign depth first index (DFI) and DFS parentvalues to vertices
 (2) Assign DFS edge types
 (3) Create a sortedDFSChildList for each vertex, sorted by child DFI
 (4) Create a sortedFwdArcList for each vertex, sorted by descendant DFI
 (5) Assign leastAncestor values to vertices
 (6) Sort the vertices by their DFIs
 (7) Initialize for pertinence and future pertinence management
 (8) Embed each tree edge as a singleton biconnected component

 The first five of these are performed in a single-pass DFS of theGraph.
 Afterward, the vertices are sorted by their DFIs, the lowpoint values
 are assigned and then the DFS tree edges stored in virtual vertices
 during the DFS are used to create the DFS tree embedding.
 ********************************************************************/
int  _EmbeddingInitialize(graphP theGraph)
{
	stackP theStack;
	int DFI, v, R, uparent, u, uneighbor, e, f, eTwin, ePrev, eNext;
	int leastValue, child;

#ifdef PROFILE
platform_time start, end;
platform_GetTime(start);
#endif

	gp_LogLine("graphEmbed.c/_EmbeddingInitialize() start\n");

	theStack  = theGraph->theStack;

	// At most we push 2 integers per edge from a vertex to each *unvisited* neighbor
	// plus one additional integer to help detect post-processing.  This is less
	// than the 2 * arcCapacity integer stack that is already in theGraph structure,
	// so we make sure it's still there and cleared, then we clear all vertex
	// visited flags in prep for the Depth first search operation. */

	if (sp_GetCapacity(theStack) < 2*gp_GetArcCapacity(theGraph))
		return NOTOK;

	sp_ClearStack(theStack);

	_ClearVertexVisitedFlags(theGraph, FALSE);

	// This outer loop processes each connected component of a disconnected graph
	// No need to compare v < N since DFI will reach N when inner loop processes the
	// last connected component in the graph
	for (DFI = v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, DFI); v++)
	{
		// Skip numbered vertices to cause the outerloop to find the
		// next DFS tree root in a disconnected graph
		if (gp_IsVertex(gp_GetVertexParent(theGraph, v)))
		  continue;

		// DFS a connected component
		sp_Push2(theStack, NIL, NIL);
		while (sp_NonEmpty(theStack))
		{
			sp_Pop2(theStack, uparent, e);

			// For vertex uparent and edge e, obtain the opposing endpoint u of e
			// If uparent is NIL, then e is also NIL and we have encountered the
			// false edge to the DFS tree root as pushed above.
			u = gp_IsNotVertex(uparent) ? v : gp_GetNeighbor(theGraph, e);

			// We popped an edge to an unvisited vertex, so it is either a DFS tree edge
			// or a false edge to the DFS tree root (u).
			if (!gp_GetVertexVisited(theGraph, u))
			{
				gp_LogLine(gp_MakeLogStr3("v=%d, DFI=%d, parent=%d", u, DFI, uparent));

				// (1) Set the DFI and DFS parent
				gp_SetVertexVisited(theGraph, u);
				gp_SetVertexIndex(theGraph, u, DFI++);
				gp_SetVertexParent(theGraph, u, uparent);

				if (gp_IsArc(e))
				{
					// (2) Set the edge type values for tree edges
					gp_SetEdgeType(theGraph, e, EDGE_TYPE_CHILD);
					gp_SetEdgeType(theGraph, gp_GetTwinArc(theGraph, e), EDGE_TYPE_PARENT);

					// (3) Record u in the sortedDFSChildList of uparent
                    gp_SetVertexSortedDFSChildList(theGraph, uparent,
                    		gp_AppendDFSChild(theGraph, uparent, gp_GetVertexIndex(theGraph, u)));

					// (8) Record e as the first and last arc of the virtual vertex R,
					//     a root copy of uparent uniquely associated with child u
                    R = gp_GetRootFromDFSChild(theGraph, gp_GetVertexIndex(theGraph, u));
                	gp_SetFirstArc(theGraph, R, e);
                	gp_SetLastArc(theGraph, R, e);
				}

				// (5) Initialize the least ancestor value
				gp_SetVertexLeastAncestor(theGraph, u, gp_GetVertexIndex(theGraph, u));

				// Push edges to all unvisited neighbors. These will be either
				// tree edges to children or forward arcs of back edges
				// Edges not pushed are marked as back edges here, except the
				// edge leading back to the immediate DFS parent.
				e = gp_GetFirstArc(theGraph, u);
				while (gp_IsArc(e))
				{
					if (!gp_GetVertexVisited(theGraph, gp_GetNeighbor(theGraph, e)))
					{
						sp_Push2(theStack, u, e);
					}
					else if (gp_GetEdgeType(theGraph, e) != EDGE_TYPE_PARENT)
					{
						// (2) Set the edge type values for back edges
						gp_SetEdgeType(theGraph, e, EDGE_TYPE_BACK);
						eTwin = gp_GetTwinArc(theGraph, e);
						gp_SetEdgeType(theGraph, eTwin, EDGE_TYPE_FORWARD);

						// (4) Move the twin of back edge record e to the sortedFwdArcList of the ancestor
						uneighbor = gp_GetNeighbor(theGraph, e);
						ePrev = gp_GetPrevArc(theGraph, eTwin);
						eNext = gp_GetNextArc(theGraph, eTwin);

						if (gp_IsArc(ePrev))
							 gp_SetNextArc(theGraph, ePrev, eNext);
						else gp_SetFirstArc(theGraph, uneighbor, eNext);
						if (gp_IsArc(eNext))
							 gp_SetPrevArc(theGraph, eNext, ePrev);
						else gp_SetLastArc(theGraph, uneighbor, ePrev);

						if (gp_IsArc(f = gp_GetVertexFwdArcList(theGraph, uneighbor)))
						{
							ePrev = gp_GetPrevArc(theGraph, f);
							gp_SetPrevArc(theGraph, eTwin, ePrev);
							gp_SetNextArc(theGraph, eTwin, f);
							gp_SetPrevArc(theGraph, f, eTwin);
							gp_SetNextArc(theGraph, ePrev, eTwin);
						}
						else
						{
							gp_SetVertexFwdArcList(theGraph, uneighbor, eTwin);
							gp_SetPrevArc(theGraph, eTwin, eTwin);
							gp_SetNextArc(theGraph, eTwin, eTwin);
						}

						// (5) Update the leastAncestor value for the vertex u
						uneighbor = gp_GetVertexIndex(theGraph, uneighbor);
						if (uneighbor < gp_GetVertexLeastAncestor(theGraph, u))
							gp_SetVertexLeastAncestor(theGraph, u, uneighbor);
					}

					e = gp_GetNextArc(theGraph, e);
				}
			}
		}
	}

	// The graph is now DFS numbered
    theGraph->internalFlags |= FLAGS_DFSNUMBERED;

	// (6) Now that all vertices have a DFI in the index member, we can sort vertices
    if (gp_SortVertices(theGraph) != OK)
        return NOTOK;

    // Loop through the vertices and virtual vertices to...
    for (v = gp_GetLastVertex(theGraph); gp_VertexInRangeDescending(theGraph, v); v--)
    {
    	// (7) Initialize for pertinence management
        gp_SetVertexVisitedInfo(theGraph, v, theGraph->N);

        // (7) Initialize for future pertinence management
        child = gp_GetVertexSortedDFSChildList(theGraph, v);
        gp_SetVertexFuturePertinentChild(theGraph, v, child);
		leastValue = gp_GetVertexLeastAncestor(theGraph, v);
	    while (gp_IsVertex(child))
	    {
	    	if (leastValue > gp_GetVertexLowpoint(theGraph, child))
	    		leastValue = gp_GetVertexLowpoint(theGraph, child);

	    	child = gp_GetVertexNextDFSChild(theGraph, v, child);
	    }
		gp_SetVertexLowpoint(theGraph, v, leastValue);

		// (8) Create the DFS tree embedding using the child edge records stored in the virtual vertices
    	//     For each vertex v that is a DFS child, the virtual vertex R that will represent v's parent
    	//     in the singleton bicomp with v is at location v + N in the vertex array.
        if (gp_IsDFSTreeRoot(theGraph, v))
        {
        	gp_SetFirstArc(theGraph, v, NIL);
        	gp_SetLastArc(theGraph, v, NIL);
        }
        else
        {
        	R = gp_GetRootFromDFSChild(theGraph, v);

        	// Make the child edge the only edge in the virtual vertex adjacency list
        	e = gp_GetFirstArc(theGraph, R);
        	gp_SetPrevArc(theGraph, e, NIL);
        	gp_SetNextArc(theGraph, e, NIL);

        	// Reset the twin's neighbor value to point to the virtual vertex
        	eTwin = gp_GetTwinArc(theGraph, e);
        	gp_SetNeighbor(theGraph, eTwin, R);

        	// Make its twin the only edge in the child's adjacency list
        	gp_SetFirstArc(theGraph, v, eTwin);
        	gp_SetLastArc(theGraph, v, eTwin);
        	gp_SetPrevArc(theGraph, eTwin, NIL);
        	gp_SetNextArc(theGraph, eTwin, NIL);

        	// Set up the external face management data structure to match
            gp_SetExtFaceVertex(theGraph, R, 0, v);
            gp_SetExtFaceVertex(theGraph, R, 1, v);
            gp_SetExtFaceVertex(theGraph, v, 0, R);
            gp_SetExtFaceVertex(theGraph, v, 1, R);
        }
    }

	gp_LogLine("graphEmbed.c/_EmbeddingInitialize() end\n");

#ifdef PROFILE
platform_GetTime(end);
printf("Initialize embedding in %.3lf seconds.\n", platform_GetDuration(start,end));
#endif

	return OK;
}

/********************************************************************
 _EmbedBackEdgeToDescendant()
 The Walkdown has found a descendant vertex W to which it can
 attach a back edge up to the root of the bicomp it is processing.
 The RootSide and WPrevLink indicate the parts of the external face
 that will be replaced at each endpoint of the back edge.
 ********************************************************************/

void _EmbedBackEdgeToDescendant(graphP theGraph, int RootSide, int RootVertex, int W, int WPrevLink)
{
int fwdArc, backArc, parentCopy;

    /* We get the two edge records of the back edge to embed.
        The Walkup recorded in W's adjacentTo the index of the forward arc
        from the root's parent copy to the descendant W. */

    fwdArc = gp_GetVertexPertinentEdge(theGraph, W);
    backArc = gp_GetTwinArc(theGraph, fwdArc);

    /* The forward arc is removed from the fwdArcList of the root's parent copy. */

    parentCopy = gp_GetPrimaryVertexFromRoot(theGraph, RootVertex);

    gp_LogLine(gp_MakeLogStr5("graphEmbed.c/_EmbedBackEdgeToDescendant() V=%d, R=%d, R_out=%d, W=%d, W_in=%d",
    		parentCopy, RootVertex, RootSide, W, WPrevLink));

    if (gp_GetVertexFwdArcList(theGraph, parentCopy) == fwdArc)
    {
    	gp_SetVertexFwdArcList(theGraph, parentCopy, gp_GetNextArc(theGraph, fwdArc));
        if (gp_GetVertexFwdArcList(theGraph, parentCopy) == fwdArc)
            gp_SetVertexFwdArcList(theGraph, parentCopy, NIL);
    }

    gp_SetNextArc(theGraph, gp_GetPrevArc(theGraph, fwdArc), gp_GetNextArc(theGraph, fwdArc));
    gp_SetPrevArc(theGraph, gp_GetNextArc(theGraph, fwdArc), gp_GetPrevArc(theGraph, fwdArc));

    // The forward arc is added to the adjacency list of the RootVertex.
    // Note that we're guaranteed that the RootVertex adjacency list is non-empty,
    // so tests for NIL are not needed
    gp_SetAdjacentArc(theGraph, fwdArc, 1^RootSide, NIL);
    gp_SetAdjacentArc(theGraph, fwdArc, RootSide, gp_GetArc(theGraph, RootVertex, RootSide));
    gp_SetAdjacentArc(theGraph, gp_GetArc(theGraph, RootVertex, RootSide), 1^RootSide, fwdArc);
    gp_SetArc(theGraph, RootVertex, RootSide, fwdArc);

    // The back arc is added to the adjacency list of W.
    // The adjacency list of W is also guaranteed non-empty
    gp_SetAdjacentArc(theGraph, backArc, 1^WPrevLink, NIL);
    gp_SetAdjacentArc(theGraph, backArc, WPrevLink, gp_GetArc(theGraph, W, WPrevLink));
    gp_SetAdjacentArc(theGraph, gp_GetArc(theGraph, W, WPrevLink), 1^WPrevLink, backArc);
    gp_SetArc(theGraph, W, WPrevLink, backArc);

    gp_SetNeighbor(theGraph, backArc, RootVertex);

    /* Link the two endpoint vertices together on the external face */

    gp_SetExtFaceVertex(theGraph, RootVertex, RootSide, W);
    gp_SetExtFaceVertex(theGraph, W, WPrevLink, RootVertex);
}

/********************************************************************
 _InvertVertex()
 This function flips the orientation of a single vertex such that
 instead of using link successors to go clockwise (or counterclockwise)
 around a vertex's adjacency list, link predecessors would be used.
 ********************************************************************/

void _InvertVertex(graphP theGraph, int W)
{
int e, temp;

	 gp_LogLine(gp_MakeLogStr1("graphEmbed.c/_InvertVertex() W=%d", W));

     // Swap the links in all the arcs of the adjacency list
     e = gp_GetFirstArc(theGraph, W);
     while (gp_IsArc(e))
     {
    	 temp = gp_GetNextArc(theGraph, e);
    	 gp_SetNextArc(theGraph, e, gp_GetPrevArc(theGraph, e));
    	 gp_SetPrevArc(theGraph, e, temp);

         e = temp;
     }

     // Swap the first/last edge record indicators in the vertex
     temp = gp_GetFirstArc(theGraph, W);
     gp_SetFirstArc(theGraph, W, gp_GetLastArc(theGraph, W));
     gp_SetLastArc(theGraph, W, temp);

     // Swap the first/last external face indicators in the vertex
     temp = gp_GetExtFaceVertex(theGraph, W, 0);
     gp_SetExtFaceVertex(theGraph, W, 0, gp_GetExtFaceVertex(theGraph, W, 1));
     gp_SetExtFaceVertex(theGraph, W, 1, temp);
}

/********************************************************************
 _MergeVertex()
 The merge step joins the vertex W to the root R of a child bicompRoot,
 which is a root copy of W appearing in the region N to 2N-1.

 Actually, the first step of this is to redirect all of the edges leading
 into R so that they indicate W as the neighbor instead of R.
 For each edge node pointing to R, we set the 'v' field to W.  Once an
 edge is redirected from a root copy R to a parent copy W, the edge is
 never redirected again, so we associate the cost of the redirection
 as constant per edge, which maintains linear time performance.

 After this is done, a regular circular list union occurs. The only
 consideration is that WPrevLink is used to indicate the two edge
 records e_w and e_r that will become consecutive in the resulting
 adjacency list of W.  We set e_w to W's link [WPrevLink] and e_r to
 R's link [1^WPrevLink] so that e_w and e_r indicate W and R with
 opposing links, which become free to be cross-linked.  Finally,
 the edge record e_ext, set equal to R's link [WPrevLink], is the edge
 that, with e_r, held R to the external face.  Now, e_ext will be the
 new link [WPrevLink] edge record for W.  If e_w and e_r become part
 of a proper face, then e_ext and W's link [1^WPrevLink] are the two
 edges that attach W to the external face cycle of the containing bicomp.
 ********************************************************************/

void _MergeVertex(graphP theGraph, int W, int WPrevLink, int R)
{
int  e, eTwin, e_w, e_r, e_ext;

	 gp_LogLine(gp_MakeLogStr4("graphEmbed.c/_MergeVertex() W=%d, W_in=%d, R=%d, R_out=%d",
			 W, WPrevLink, R, 1^WPrevLink));

     // All arcs leading into R from its neighbors must be changed
     // to say that they are leading into W
     e = gp_GetFirstArc(theGraph, R);
     while (gp_IsArc(e))
     {
         eTwin = gp_GetTwinArc(theGraph, e);
         gp_GetNeighbor(theGraph, eTwin) = W;

    	 e = gp_GetNextArc(theGraph, e);
     }

     // Obtain the edge records involved in the list union
     e_w = gp_GetArc(theGraph, W, WPrevLink);
     e_r = gp_GetArc(theGraph, R, 1^WPrevLink);
     e_ext = gp_GetArc(theGraph, R, WPrevLink);

     // If W has any edges, then join the list with that of R
     if (gp_IsArc(e_w))
     {
         // The WPrevLink arc of W is e_w, so the 1^WPrevLink arc in e_w leads back to W.
         // Now it must lead to e_r.  Likewise, e_r needs to lead back to e_w with the
         // opposing link, which is WPrevLink
         // Note that the adjacency lists of W and R are guaranteed non-empty, which is
         // why these linkages can be made without NIL tests.
         gp_SetAdjacentArc(theGraph, e_w, 1^WPrevLink, e_r);
         gp_SetAdjacentArc(theGraph, e_r, WPrevLink, e_w);

         // Cross-link W's WPrevLink arc and the 1^WPrevLink arc in e_ext
         gp_SetArc(theGraph, W, WPrevLink, e_ext);
         gp_SetAdjacentArc(theGraph, e_ext, 1^WPrevLink, NIL);
     }
     // Otherwise, W just receives R's list.  This happens, for example, on a
     // DFS tree root vertex during JoinBicomps()
     else
     {
         // Cross-link W's 1^WPrevLink arc and the WPrevLink arc in e_r
         gp_SetArc(theGraph, W, 1^WPrevLink, e_r);
         gp_SetAdjacentArc(theGraph, e_r, WPrevLink, NIL);

         // Cross-link W's WPrevLink arc and the 1^WPrevLink arc in e_ext
         gp_SetArc(theGraph, W, WPrevLink, e_ext);
         gp_SetAdjacentArc(theGraph, e_ext, 1^WPrevLink, NIL);
     }

     // Erase the entries in R, which is a root copy that is no longer needed
     _InitVertexRec(theGraph, R);
}

/********************************************************************
 _MergeBicomps()

 Merges all biconnected components at the cut vertices indicated by
 entries on the stack.

 theGraph contains the stack of bicomp roots and cut vertices to merge

 v, RootVertex, W and WPrevLink are not used in this routine, but are
          used by overload extensions

 Returns OK, but an extension function may return a value other than
         OK in order to cause Walkdown to terminate immediately.
********************************************************************/

int  _MergeBicomps(graphP theGraph, int v, int RootVertex, int W, int WPrevLink)
{
int  R, Rout, Z, ZPrevLink, e, extFaceVertex;

     while (sp_NonEmpty(theGraph->theStack))
     {
         sp_Pop2(theGraph->theStack, R, Rout);
         sp_Pop2(theGraph->theStack, Z, ZPrevLink);

         /* The external faces of the bicomps containing R and Z will
            form two corners at Z.  One corner will become part of the
            internal face formed by adding the new back edge. The other
            corner will be the new external face corner at Z.
            We first want to update the links at Z to reflect this. */

         extFaceVertex = gp_GetExtFaceVertex(theGraph, R, 1^Rout);
         gp_SetExtFaceVertex(theGraph, Z, ZPrevLink, extFaceVertex);

         if (gp_GetExtFaceVertex(theGraph, extFaceVertex, 0) == gp_GetExtFaceVertex(theGraph, extFaceVertex, 1))
        	 // When (R, extFaceVertex) form a singleton bicomp, they have the same orientation, so the Rout link in extFaceVertex
        	 // is the one that has to now point back to Z
        	 gp_SetExtFaceVertex(theGraph, extFaceVertex, Rout, Z);
         else
        	 // When R and extFaceVertex are not alone in the bicomp, then they may not have the same orientation, so the
        	 // ext face link that should point to Z is whichever one pointed to R, since R is a root copy of Z.
             gp_SetExtFaceVertex(theGraph, extFaceVertex, gp_GetExtFaceVertex(theGraph, extFaceVertex, 0) == R ? 0 : 1, Z);

         /* If the path used to enter Z is opposed to the path
            used to exit R, then we have to flip the bicomp
            rooted at R, which we signify by inverting R
            then setting the sign on its DFS child edge to
            indicate that its descendants must be flipped later */

         if (ZPrevLink == Rout)
         {
             Rout = 1^ZPrevLink;

             if (gp_GetFirstArc(theGraph, R) != gp_GetLastArc(theGraph, R))
                _InvertVertex(theGraph, R);

             e = gp_GetFirstArc(theGraph, R);
             while (gp_IsArc(e))
             {
                 if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_CHILD)
                 {
                	 // The core planarity algorithm could simply "set" the inverted flag
                	 // because a bicomp root edge cannot be already inverted in the core
                	 // planarity algorithm at the time of this merge.
                	 // However, extensions may perform edge reductions on tree edges, resulting
                	 // in an inversion sign being promoted to the root edge of a bicomp before
                	 // it gets merged.  So, xor is used to reverse the inversion flag on the
                	 // root edge if the bicomp root must be inverted before it is merged.
                	 gp_XorEdgeFlagInverted(theGraph, e);
                     break;
                 }

                 e = gp_GetNextArc(theGraph, e);
             }
         }

         // R is no longer pertinent to Z since we are about to merge R into Z, so we delete R
         // from Z's pertinent bicomp list (Walkdown gets R from the head of the list).
         gp_DeleteVertexPertinentRoot(theGraph, Z, R);

         // If the merge will place the current future pertinence child into the same bicomp as Z,
         // then we advance to the next child (or NIL) because future pertinence is
         if (gp_GetDFSChildFromRoot(theGraph, R) == gp_GetVertexFuturePertinentChild(theGraph, Z))
         {
        	 gp_SetVertexFuturePertinentChild(theGraph, Z,
        			 gp_GetVertexNextDFSChild(theGraph, Z, gp_GetVertexFuturePertinentChild(theGraph, Z)));
         }

         // Now we push R into Z, eliminating R
         theGraph->functions.fpMergeVertex(theGraph, Z, ZPrevLink, R);
     }

     return OK;
}

/********************************************************************
 _WalkUp()
 v is the vertex currently being embedded
 e is the forward arc of the back edge to a descendant W of v

 The Walkup establishes pertinence for step v.  It marks W with e
 as a way of indicating it is pertinent because it should be made
 'adjacent to' v by adding a back edge (v', W), which will occur when
 the Walkdown encounters W.

 The Walkup also determines the pertinent child bicomps that should be
 set up as a result of the need to embed edge (v, W). It does this by
 recording the pertinent child biconnected components of all cut
 vertices between W and the child of v that is an ancestor of W.
 Note that it stops the traversal if it finds a visited info value set
 to v, which indicates that a prior walkup call in step v has already
 done the work. This ensures work is not duplicated.

 A second technique used to maintain a total linear time bound for the
 whole planarity method is that of parallel external face traversal.
 This ensures that the cost of determining pertinence in step v is
 linearly commensurate with the length of the path that ultimately
 is removed from the external face.

 Zig and Zag are so named because one goes around one side of a bicomp
 and the other goes around the other side, yet we have as yet no notion
 of orientation for the bicomp. The edge record e from vertex v gestures
 to a descendant vertex W in some other bicomp.  Zig and Zag start out
 at W. They go around alternate sides of the bicomp until its root is
 found.  We then hop from the root copy to the parent copy of the vertex
 in order to record which bicomp we just came from and also to continue
 the walk-up at the parent copy as if it were the new W.  We reiterate
 this process until the parent copy actually is v, at which point the
 Walkup is done.
 ********************************************************************/

void _WalkUp(graphP theGraph, int v, int e)
{
int  W = gp_GetNeighbor(theGraph, e);
int  Zig=W, Zag=W, ZigPrevLink=1, ZagPrevLink=0;
int  nextZig, nextZag, R;

	 // Start by marking W as being directly pertinent
     gp_SetVertexPertinentEdge(theGraph, W, e);

     // Zig and Zag are initialized at W, and we continue looping around
     // the external faces of bicomps up from W until we reach vertex v
     // (or until the visited info optimization breaks the loop)
     while (Zig != v)
     {
    	 // Obtain the next vertex in a first direction and determine if it is a bicomp root
         if (gp_IsVirtualVertex(theGraph, (nextZig = gp_GetExtFaceVertex(theGraph, Zig, 1^ZigPrevLink))))
         {
        	 // If the current vertex along the external face was visited in this step v,
        	 // then the bicomp root and its ancestor roots have already been added.
        	 if (gp_GetVertexVisitedInfo(theGraph, Zig) == v) break;

        	 // Store the bicomp root that was found
        	 R = nextZig;

        	 // Since the bicomp root was the next vertex on the path from Zig, determine the
        	 // vertex on the opposing path that enters the bicomp root.
        	 nextZag = gp_GetExtFaceVertex(theGraph, R,
										   gp_GetExtFaceVertex(theGraph, R, 0)==Zig ? 1 : 0);

        	 // If the opposing vertex was already marked visited in this step, then a prior
        	 // Walkup already recorded as pertinent the bicomp root and its ancestor roots.
        	 if (gp_GetVertexVisitedInfo(theGraph, nextZag) == v) break;
         }

         // Obtain the next vertex in the parallel direction and perform the analogous logic
         else if (gp_IsVirtualVertex(theGraph, (nextZag = gp_GetExtFaceVertex(theGraph, Zag, 1^ZagPrevLink))))
         {
        	 if (gp_GetVertexVisitedInfo(theGraph, Zag) == v) break;
        	 R = nextZag;
        	 nextZig = gp_GetExtFaceVertex(theGraph, R,
										   gp_GetExtFaceVertex(theGraph, R, 0)==Zag ? 1 : 0);
        	 if (gp_GetVertexVisitedInfo(theGraph, nextZig) == v) break;
         }

         // The bicomp root was not found in either direction.
         else
         {
        	 if (gp_GetVertexVisitedInfo(theGraph, Zig) == v) break;
        	 if (gp_GetVertexVisitedInfo(theGraph, Zag) == v) break;
        	 R = NIL;
         }

         // This Walkup has now finished with another vertex along each of the parallel
         // paths, so they are marked visited in step v so that future Walkups in this
         // step v can break if these vertices are encountered again.
         gp_SetVertexVisitedInfo(theGraph, Zig, v);
         gp_SetVertexVisitedInfo(theGraph, Zag, v);

         // If both directions found new non-root vertices, then proceed with parallel external face traversal
         if (gp_IsNotVertex(R))
         {
             ZigPrevLink = gp_GetExtFaceVertex(theGraph, nextZig, 0)==Zig ? 0 : 1;
             Zig = nextZig;

             ZagPrevLink = gp_GetExtFaceVertex(theGraph, nextZag, 0)==Zag ? 0 : 1;
             Zag = nextZag;
         }

         // The bicomp root was found and not previously recorded as pertinent,
         // so walk up to the parent bicomp and continue
         else
         {
        	 // Step up from the root (virtual) vertex to the primary (non-virtual) vertex
             Zig = Zag = gp_GetPrimaryVertexFromRoot(theGraph, R);
             ZigPrevLink = 1;
             ZagPrevLink = 0;

			 // Add the new root vertex to the list of pertinent bicomp roots of the primary vertex.
             // The new root vertex is appended if future pertinent and prepended if only pertinent
             // so that, by virtue of storage, the Walkdown will process all pertinent bicomps that
             // are not future pertinent before any future pertinent bicomps.

			 // NOTE: Unlike vertices, the activity status of a bicomp is computed solely using
			 //       the lowpoint of the DFS child in the bicomp's root edge, which indicates
             //       whether the DFS child or any of its descendants connect by a back edge to
             //       ancestors of v. If so, then the bicomp rooted at RootVertex must contain a
             //       future pertinent vertex that must be kept on the external face.
			 if (gp_GetVertexLowpoint(theGraph, gp_GetDFSChildFromRoot(theGraph, R)) < v)
				  gp_AppendVertexPertinentRoot(theGraph, Zig, R);
			 else gp_PrependVertexPertinentRoot(theGraph, Zag, R);
         }
     }
}

/********************************************************************
 _WalkDown()
 Consider a circular shape with small circles and squares along its perimeter.
 The small circle at the top is the root vertex of the bicomp.  The other small
 circles represent active vertices, and the squares represent future pertinent
 vertices.  The root vertex is a root copy of v, the vertex currently being processed.

 The Walkup previously marked all vertices adjacent to v by setting their
 pertinentEdge members with the forward arcs of the back edges to embed.
 Two Walkdown traversals are performed to visit all reachable vertices
 along each of the external face paths emanating from RootVertex (a root
 copy of vertex v) to embed back edges to descendants of vertex v that
 have their pertinentEdge members marked.

 During each Walkdown traversal, it is sometimes necessary to hop from a
 vertex to one of its child biconnected components in order to reach the
 desired vertices.  In such cases, the biconnected components are merged
 such that adding the back edge forms a new proper face in the biconnected
 component rooted at RootVertex (which, again, is a root copy of v).

 The outer loop performs both walks, unless the first walk got all the way
 around to RootVertex (only happens when bicomp contains no external activity,
 such as when processing the last vertex), or when non-planarity is
 discovered (in a pertinent child bicomp such that the stack is non-empty).

 For the inner loop, each iteration visits a vertex W.  If W is marked as
 requiring a back edge, then MergeBicomps is called to merge the biconnected
 components whose cut vertices have been collecting in merge stack.  Then,
 the back edge (RootVertex, W) is added, and the pertinentEdge of W is cleared.

 Next, we check whether W has a pertinent child bicomp.  If so, then we figure
 out which path down from the root of the child bicomp leads to the next vertex
 to be visited, and we push onto the stack information on the cut vertex and
 the paths used to enter into it and exit from it.  Alternately, if W
 had no pertinent child bicomps, then we check to see if it is inactive.
 If so, we find the next vertex along the external face, then short-circuit
 its inactive predecessor (under certain conditions).  Finally, if W is not
 inactive, but it has no pertinent child bicomps, then we already know its
 adjacentTo flag is clear so both criteria for internal activity also fail.
 Therefore, W must be a stopping vertex.

 A stopping vertex X is a future pertinent vertex that has no pertinent
 child bicomps and no unembedded back edge to the current vertex v.
 The inner loop of Walkdown stops walking when it reaches a stopping vertex X
 because if it were to proceed beyond X and embed a back edge, then X would be
 surrounded by the bounding cycle of the bicomp.  This would clearly be
 incorrect because X has a path leading from it to an ancestor of v, which
 would have to cross the bounding cycle.

 Either Walkdown traversal can halt the Walkdown and return if a pertinent
 child biconnected component to which the traversal has descended is blocked,
 i.e. has stopping vertices on both paths emanating from the root.  This
 indicates an obstruction to embedding. In core planarity it is evidence of
 a K_{3,3}, but some extension algorithms are able to clear the blockage and
 proceed with embedding.

 If both Walkdown traversals successfully completed, then the outer loop
 ends.  Post-processing code tests whether the Walkdown embedded all the
 back edges from v to its descendants in the subtree rooted by c, a DFS
 child of v uniquely associated with the RootVertex.  If not, then embedding
 was obstructed.  In core planarity it is evidence of a K_{3,3} or K_5, but some
 extension algorithms are able to clear the blockage and proceed with embedding.

  Returns OK if all possible edges were embedded,
  	  	  NONEMBEDDABLE if less than all possible edges were embedded,
  	  	  NOTOK for an internal code failure
 ********************************************************************/

int  _WalkDown(graphP theGraph, int v, int RootVertex)
{
int  RetVal, W, WPrevLink, R, X, XPrevLink, Y, YPrevLink, RootSide, e;
int  RootEdgeChild = gp_GetDFSChildFromRoot(theGraph, RootVertex);

     sp_ClearStack(theGraph->theStack);

     for (RootSide = 0; RootSide < 2; RootSide++)
     {
         W = gp_GetExtFaceVertex(theGraph, RootVertex, RootSide);

         // Determine the link used to enter W based on which side points back to RootVertex
         // Implicitly handled special case: In core planarity, the first Walkdown traversal
         // Will be on a singleton edge.  In this case, RootVertex and W are *consistently*
         // oriented, and the RootSide is 0, so WPrevLink should be 1. This calculation is
         // written to implicitly produce that result.
         WPrevLink = gp_GetExtFaceVertex(theGraph, W, 1) == RootVertex ? 1 : 0;

         while (W != RootVertex)
         {
             // Detect unembedded back edge descendant endpoint W
             if (gp_IsArc(gp_GetVertexPertinentEdge(theGraph, W)))
             {
                // Merge any bicomps whose cut vertices were traversed to reach W, then add the
            	// edge to W to form a new proper face in the embedding.
                if (sp_NonEmpty(theGraph->theStack))
                {
                    if ((RetVal = theGraph->functions.fpMergeBicomps(theGraph, v, RootVertex, W, WPrevLink)) != OK)
                        return RetVal;
                }
                theGraph->functions.fpEmbedBackEdgeToDescendant(theGraph, RootSide, RootVertex, W, WPrevLink);

                // Clear W's pertinentEdge since the forward arc it contained has been embedded
                gp_SetVertexPertinentEdge(theGraph, W, NIL);
             }

             // If W has a pertinent child bicomp, then we descend to the first one...
             if (gp_IsVertex(gp_GetVertexPertinentRootsList(theGraph, W)))
             {
            	 // Push the vertex W and the direction of entry, then descend to a root copy R of W
                 sp_Push2(theGraph->theStack, W, WPrevLink);
                 R = gp_GetVertexFirstPertinentRoot(theGraph, W);

                 // Get the next active vertices X and Y on the external face paths emanating from R
                 X = gp_GetExtFaceVertex(theGraph, R, 0);
                 XPrevLink = gp_GetExtFaceVertex(theGraph, X, 1)==R ? 1 : 0;
                 Y = gp_GetExtFaceVertex(theGraph, R, 1);
                 YPrevLink = gp_GetExtFaceVertex(theGraph, Y, 0)==R ? 0 : 1;

                 // Now we implement the Walkdown's simple path selection rules!
                 // Select a direction from the root to a pertinent vertex,
                 // preferentially toward a vertex that is not future pertinent
                 gp_UpdateVertexFuturePertinentChild(theGraph, X, v);
                 gp_UpdateVertexFuturePertinentChild(theGraph, Y, v);
                 if (PERTINENT(theGraph, X) && NOTFUTUREPERTINENT(theGraph, X, v))
				 {
					 W = X;
					 WPrevLink = XPrevLink;
					 sp_Push2(theGraph->theStack, R, 0);
				 }
                 else if (PERTINENT(theGraph, Y) && NOTFUTUREPERTINENT(theGraph, Y, v))
            	 {
                     W = Y;
                     WPrevLink = YPrevLink;
                     sp_Push2(theGraph->theStack, R, 1);
            	 }
                 else if (PERTINENT(theGraph, X))
				 {
					 W = X;
					 WPrevLink = XPrevLink;
					 sp_Push2(theGraph->theStack, R, 0);
				 }
                 else if (PERTINENT(theGraph, Y))
            	 {
                     W = Y;
                     WPrevLink = YPrevLink;
                     sp_Push2(theGraph->theStack, R, 1);
            	 }
                 else
                 {
                	 // Both the X and Y sides of the descendant bicomp are blocked.
                	 // Let the application decide whether it can unblock the bicomp.
                	 // The core planarity/outerplanarity embedder simply isolates a
                	 // planarity/outerplanary obstruction and returns NONEMBEDDABLE
                     if ((RetVal = theGraph->functions.fpHandleBlockedBicomp(theGraph, v, RootVertex, R)) != OK)
                         return RetVal;

                     // If an extension algorithm cleared the blockage, then we pop W and WPrevLink
                     // back off the stack and let the Walkdown traversal try descending again
                     sp_Pop2(theGraph->theStack, W, WPrevLink);
                 }
             }
             else
             {
                 // The vertex W is known to be non-pertinent, so if it is future pertinent
                 // (or if the algorithm is based on outerplanarity), then the vertex is
                 // a stopping vertex for the Walkdown traversal.
            	 gp_UpdateVertexFuturePertinentChild(theGraph, W, v);
                 if (FUTUREPERTINENT(theGraph, W, v) || (theGraph->embedFlags & EMBEDFLAGS_OUTERPLANAR))
                 {
                	 // Create an external face short-circuit between RootVertex and the stopping vertex W
                	 // so that future steps do not walk down a long path of inactive vertices between them.
                	 // As a special case, we ensure that the external face is not reduced to just two
                	 // vertices, W and RootVertex, because it would then become a challenge to determine
                	 // whether W has the same orientation as RootVertex.
                	 // So, if the other side of RootVertex is already attached to W, then we simply push
                	 // W back one vertex so that the external face will have at least three vertices.
                	 if (gp_GetExtFaceVertex(theGraph, RootVertex, 1^RootSide) == W)
                	 {
                	     X = W;
                	     W = gp_GetExtFaceVertex(theGraph, W, WPrevLink);
                	     WPrevLink = gp_GetExtFaceVertex(theGraph, W, 0) == X ? 1 : 0;
                	 }
                     gp_SetExtFaceVertex(theGraph, RootVertex, RootSide, W);
                     gp_SetExtFaceVertex(theGraph, W, WPrevLink, RootVertex);

                     // Terminate the Walkdown traversal since it encountered the stopping vertex
                     break;
                 }

                 // If the vertex is neither pertinent nor future pertinent, then it is inactive.
            	 // The default handler planarity handler simply skips inactive vertices by traversing
                 // to the next vertex on the external face.
                 // Once upon a time, false edges called short-circuit edges were added to eliminate
                 // inactive vertices, but the extFace links above achieve the same result with less work.
                 else
                 {
                     if (theGraph->functions.fpHandleInactiveVertex(theGraph, RootVertex, &W, &WPrevLink) != OK)
                         return NOTOK;
                 }
             }
         }
     }

     // Detect and handle the case in which Walkdown was blocked from embedding all the back edges from v
     // to descendants in the subtree of the child of v associated with the bicomp RootVertex.
	 if (gp_IsArc(e = gp_GetVertexFwdArcList(theGraph, v)) && RootEdgeChild < gp_GetNeighbor(theGraph, e))
	 {
	     int nextChild = gp_GetVertexNextDFSChild(theGraph, v, RootEdgeChild);

	     // The Walkdown was blocked from embedding all forward arcs into the RootEdgeChild subtree
	     // if there the next child's DFI is greater than the descendant endpoint of the next forward arc,
	     // or if there is no next child.
	     if (gp_IsNotVertex(nextChild) || nextChild > gp_GetNeighbor(theGraph, e))
	     {
	    	 // If an extension indicates it is OK to proceed despite the unembedded forward arcs, then
	    	 // advance to the forward arcs for the next child, if any
	    	 if ((RetVal = theGraph->functions.fpHandleBlockedBicomp(theGraph, v, RootVertex, RootVertex)) == OK)
	    		 _AdvanceFwdArcList(theGraph, v, RootEdgeChild, nextChild);

	    	 return RetVal;
	     }
	 }

     return OK;
}

/********************************************************************
 _HandleBlockedBicomp()

 A biconnected component has blocked the Walkdown from embedding
 back edges.  Each external face path emanating from the root is
 blocked by a stopping vertex.

 The core planarity/outerplanarity algorithm handles the blockage
 by isolating an embedding obstruction (a subgraph homeomorphic to
 K_{3,3} or K_5 for planarity, or a subgraph homeomorphic to K_{2,3}
 or K_4 for outerplanarity). Then NONEMBEDDABLE is returned so that
 the WalkDown can terminate.

 Extension algorithms are able to clear some of the blockages, in
 which case OK is returned to indicate that the WalkDown can proceed.

 Returns OK to proceed with WalkDown at W,
         NONEMBEDDABLE to terminate WalkDown of Root Vertex
         NOTOK for internal error
 ********************************************************************/

int  _HandleBlockedBicomp(graphP theGraph, int v, int RootVertex, int R)
{
	int RetVal = NONEMBEDDABLE;

	if (R != RootVertex)
	    sp_Push2(theGraph->theStack, R, 0);

    if (theGraph->embedFlags == EMBEDFLAGS_PLANAR)
    {
        if (_IsolateKuratowskiSubgraph(theGraph, v, RootVertex) != OK)
            RetVal = NOTOK;
    }
    else if (theGraph->embedFlags == EMBEDFLAGS_OUTERPLANAR)
    {
        if (_IsolateOuterplanarObstruction(theGraph, v, RootVertex) != OK)
            RetVal = NOTOK;
    }

	return RetVal;
}

/********************************************************************
 _AdvanceFwdArcList()

 If an extension determines that it is OK to leave some forward arcs
 unembedded, then we advance the forward arc list head pointer past
 the unembedded arcs for the current child so that it points to the
 first forward arc for the next child, if any.

 There are two meanings of the phrase "if any".  First, there may be
 no next child, in which case nextChild is NIL, and the forward arc
 list need not be advanced.

 If there is a next child, then the forward arc list head needs to
 be advanced to the first arc whose descendant endpoint is greater
 than the nextChild, if any. However, the tail end of the forward arc
 list may include unembedded forward arcs to a preceding sibling
 of the child vertex.  So, we advance an edge pointer e until one of
 the following happens:

 1) e gets all the way around to the forward arc list head
 2) e finds an edge whose descendant endpoint is less than the child
 3) e finds an edge whose descendant endpoint is greater than the next child

 In case 1, all the forward arcs belong in the subtree of the child, so
 there is no need to change the forward arc list head.

 In case 2, there are no more forward arcs to any following siblings of
 the child, only left-behind unembedded forward arcs that we advanced
 past in previous calls to this method from Walkdowns of the preceding
 children of v.  So the forward arc list head should be set to e so that
 it is set to the forward arc with the least numbered descendant endpoint.

 In case 3, the desired forward arc into the subtree of a following sibling
 of the child has been found, so again the forward arc list head should be
 set to e to indicate that edge.

 After all Walkdowns of the children of a vertex, the forward arc list will
 be NIL if all edges were embedded, or it will indicate the unembedded
 forward arc whose descendant endpoint has the least number.  Cases 1 and 2
 directly implement this in cases where a Walkdown for the given child
 fails to embed an edge, and case 3 indirectly finishes the job by making
 sure the forward arc list head has the right value at the beginning of
 a Walkdown for a particular child.  If the Walkdown of that child succeeds
 at embedding all the forward edges into that child's subtree, then each
 embedding advances the forward arc list head.  So, even if the Walkdown
 of the last pertinent child embeds all forward arcs, then the Walkdown
 itself advances the forward arc list head to the first unembedded forward
 arc, or to NIL.
 ********************************************************************/

void _AdvanceFwdArcList(graphP theGraph, int v, int child, int nextChild)
{
	int e = gp_GetVertexFwdArcList(theGraph, v);

	while (gp_IsArc(e))
	{
		// 2) e finds an edge whose descendant endpoint is less than the child
		if (gp_GetNeighbor(theGraph, e) < child)
		{
			gp_SetVertexFwdArcList(theGraph, v, e);
			break;
		}

		// 3) e finds an edge whose descendant endpoint is greater than the next child
		else if (gp_IsVertex(nextChild) && nextChild < gp_GetNeighbor(theGraph, e))
		{
			gp_SetVertexFwdArcList(theGraph, v, e);
			break;
		}

		e = gp_GetNextArc(theGraph, e);
		// 1) e gets all the way around to the forward arc list head
		if (e == gp_GetVertexFwdArcList(theGraph, v))
			e = NIL;
	}
}

/********************************************************************
 _HandleInactiveVertex()

 Although it is possible to short-circuit every inactive vertex from
 the external face, for efficiency the Walkdown traversal now just does
 a single short-circuit between the bicomp root and a stopping vertex.
 This is because the main thing that short-circuiting needs to optimize
 is the Walkdown's choice of direction after descending to the root
 of a pertinent biconnected component.  So, the Walkdown just optimizes
 the external face of a biconnected component as it finishes processing
 it so it will be ready in future steps when it becomes pertinent.
 Hence, when traversing the face of a bicomp during the current step,
 we only need to skip an inactive vertex and traverse to the next vertex
 on the external face.
 ********************************************************************/

int  _HandleInactiveVertex(graphP theGraph, int BicompRoot, int *pW, int *pWPrevLink)
{
     int X = gp_GetExtFaceVertex(theGraph, *pW, 1^*pWPrevLink);
     *pWPrevLink = gp_GetExtFaceVertex(theGraph, X, 0) == *pW ? 0 : 1;
     *pW = X;

     return OK;
}

/********************************************************************
 _EmbedPostprocess()

 After the loop that embeds the cycle edges from each vertex to its
 DFS descendants, this method is invoked to postprocess the graph.
 If the graph is planar or outerplanar, then a consistent orientation
 is imposed on the vertices of the embedding, and any remaining
 separated biconnected components are joined together.
 If the graph is non-planar or non-outerplanar, then an obstruction
 to planarity or outerplanarity has already been isolated.
 Extensions may override this function to provide alternate behavior.

  @param theGraph - the graph ready for postprocessing
  @param v - the last vertex processed by the edge embedding loop
  @param edgeEmbeddingResult -
         OK if all edge embedding iterations returned OK
         NONEMBEDDABLE if an embedding iteration failed to embed
             all edges for a vertex

  @return NOTOK on internal failure
          NONEMBEDDABLE if a subgraph homeomorphic to a topological
              obstruction is isolated in the graph
          OK otherwise (e.g. if the graph contains an embedding)
 *****************************************************************/

int  _EmbedPostprocess(graphP theGraph, int v, int edgeEmbeddingResult)
{
int  RetVal = edgeEmbeddingResult;

    // If an embedding was found, then post-process the embedding structure give
	// a consistent orientation to all vertices then eliminate virtual vertices
    if (edgeEmbeddingResult == OK)
    {
    	if (_OrientVerticesInEmbedding(theGraph) != OK ||
    		_JoinBicomps(theGraph) != OK)
    		RetVal = NOTOK;
    }

    // If the graph is embedded (OK) or NONEMBEDDABLE, we pass the result back
    return RetVal;
}

/********************************************************************
 _OrientVerticesInEmbedding()

 Each vertex will then have an orientation, either clockwise or
 counterclockwise.  All vertices in each bicomp need to have the
 same orientation.
 This method clears the stack, and the stack is clear when it
 is finished.
 Returns OK on success, NOTOK on implementation failure.
 ********************************************************************/

int  _OrientVerticesInEmbedding(graphP theGraph)
{
int  R;

     sp_ClearStack(theGraph->theStack);

     // For each vertex, obtain the associated bicomp root location and,
     // if it is still in use as a bicomp root, orient the vertices in the bicomp
	 for (R = gp_GetFirstVirtualVertex(theGraph); gp_VirtualVertexInRange(theGraph, R); R++)
     {
          if (gp_VirtualVertexInUse(theGraph, R))
          {
        	  if (_OrientVerticesInBicomp(theGraph, R, 0) != OK)
        		  return NOTOK;
          }
     }
     return OK;
}

/********************************************************************
 _OrientVerticesInBicomp()
  As a result of the work done so far, the edges around each vertex have
 been put in order, but the orientation may be counterclockwise or
 clockwise for different vertices within the same bicomp.
 We need to reverse the orientations of those vertices that are not
 oriented the same way as the root of the bicomp.

 During embedding, a bicomp with root edge (v', c) may need to be flipped.
 We do this by inverting the root copy v' and implicitly inverting the
 orientation of the vertices in the subtree rooted by c by assigning -1
 to the sign of the DFSCHILD edge record leading to c.

 We now use these signs to help propagate a consistent vertex orientation
 throughout all vertices that have been merged into the given bicomp.
 The bicomp root contains the orientation to be imposed on all parent
 copy vertices.  We perform a standard depth first search to visit each
 vertex.  A vertex must be inverted if the product of the edge signs
 along the tree edges between the bicomp root and the vertex is -1.

 Finally, the PreserveSigns flag, if set, performs the inversions
 but does not change any of the edge signs.  This allows a second
 invocation of this function to restore the state of the bicomp
 as it was before the first call.

 This method uses the stack but preserves whatever may have been
 on it.  In debug mode, it will return NOTOK if the stack overflows.
 This method pushes at most two integers per vertext in the bicomp.

 Returns OK on success, NOTOK on implementation failure.
 ********************************************************************/

int  _OrientVerticesInBicomp(graphP theGraph, int BicompRoot, int PreserveSigns)
{
int  W, e, invertedFlag;
int  stackBottom = sp_GetCurrentSize(theGraph->theStack);

     sp_Push2(theGraph->theStack, BicompRoot, 0);

     while (sp_GetCurrentSize(theGraph->theStack) > stackBottom)
     {
         /* Pop a vertex to orient */
         sp_Pop2(theGraph->theStack, W, invertedFlag);

         /* Invert the vertex if the inverted flag is set */
         if (invertedFlag)
             _InvertVertex(theGraph, W);

         /* Push the vertex's DFS children that are in the bicomp */
         e = gp_GetFirstArc(theGraph, W);
         while (gp_IsArc(e))
         {
             if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_CHILD)
             {
                 sp_Push2(theGraph->theStack, gp_GetNeighbor(theGraph, e),
                		  invertedFlag ^ gp_GetEdgeFlagInverted(theGraph, e));

                 if (!PreserveSigns)
                	 gp_ClearEdgeFlagInverted(theGraph, e);
             }

             e = gp_GetNextArc(theGraph, e);
         }
     }
     return OK;
}

/********************************************************************
 _JoinBicomps()
 The embedding algorithm works by only joining bicomps once the result
 forms a larger bicomp.  However, if the original graph was separable
 or disconnected, then the result of the embed function will be a
 graph that contains each bicomp as a distinct entity.  This function
 merges the bicomps into one connected graph.
 ********************************************************************/

int  _JoinBicomps(graphP theGraph)
{
	 int  R;

	 for (R = gp_GetFirstVirtualVertex(theGraph); gp_VirtualVertexInRange(theGraph, R); R++)
     {
    	  // If the root is still active (i.e. an in-use virtual vertex)
		  // then merge it with its primary (non-virtual) counterpart
          if (gp_VirtualVertexInUse(theGraph, R))
        	  _MergeVertex(theGraph, gp_GetPrimaryVertexFromRoot(theGraph, R), 0, R);
     }

     return OK;
}

/****************************************************************************
 _OrientExternalFacePath()

 The vertices along the path (v ... w) are assumed to be degree two vertices
 in an external face path connecting u and x.  This method imparts the
 orientation of u and x onto the vertices v ... w.
 The work done is on the order of the path length.
 Returns OK if the external face path was oriented, NOTOK on implementation
 error (i.e. if a condition arises providing the path is not on the
 external face).
 ****************************************************************************/

int  _OrientExternalFacePath(graphP theGraph, int u, int v, int w, int x)
{
int  e_u, e_v, e_ulink, e_vlink;

    // Get the edge record in u that indicates v; uses the twinarc method to
    // ensure the cost is dominated by the degree of v (which is 2), not u
    // (which can be any degree).
    e_u = gp_GetTwinArc(theGraph, gp_GetNeighborEdgeRecord(theGraph, v, u));

    do {
        // Get the external face link in vertex u that indicates the
        // edge e_u which connects to the next vertex v in the path
    	// As a sanity check, we determine whether e_u is an
    	// external face edge, because there would be an internal
    	// implementation error if not
    	if (gp_GetFirstArc(theGraph, u) == e_u)
    		e_ulink = 0;
    	else if (gp_GetLastArc(theGraph, u) == e_u)
    		e_ulink = 1;
    	else return NOTOK;

        v = gp_GetNeighbor(theGraph, e_u);

        // Now get the external face link in vertex v that indicates the
        // edge e_v which connects back to the prior vertex u.
        e_v = gp_GetTwinArc(theGraph, e_u);

    	if (gp_GetFirstArc(theGraph, v) == e_v)
    		e_vlink = 0;
    	else if (gp_GetLastArc(theGraph, v) == e_v)
    		e_vlink = 1;
    	else return NOTOK;

        // The vertices u and v are inversely oriented if they
        // use the same link to indicate the edge [e_u, e_v].
        if (e_vlink == e_ulink)
        {
            _InvertVertex(theGraph, v);
            e_vlink = 1^e_vlink;
        }

        // This update of the extFace short-circuit is polite but unnecessary.
        // This orientation only occurs once we know we can isolate a K_{3,3},
        // at which point the extFace data structure is not used.
        gp_SetExtFaceVertex(theGraph, u, e_ulink, v);
        gp_SetExtFaceVertex(theGraph, v, e_vlink, u);

        u = v;
        e_u = gp_GetArc(theGraph, v, 1^e_vlink);
    } while (u != x);

    return OK;
}
