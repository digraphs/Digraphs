/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#define GRAPHDFSUTILS_C

#include "graph.h"

extern void _ClearVertexVisitedFlags(graphP theGraph, int);

/********************************************************************
 gp_CreateDFSTree
 Assigns Depth First Index (DFI) to each vertex.  Also records parent
 of each vertex in the DFS tree, and marks DFS tree edges that go from
 parent to child.  Forward arc cycle edges are also distinguished from
 edges leading from a DFS tree descendant to an ancestor-- both DFS tree
 edges and back arcs.  The forward arcs are moved to the end of the
 adjacency list to make the set easier to find and process.

 NOTE: This is a utility function provided for general use of the graph
 library. The core planarity algorithm uses its own DFS in order to build
 up related data structures at the same time as the DFS tree is created.
 ********************************************************************/

#include "platformTime.h"

int  gp_CreateDFSTree(graphP theGraph)
{
stackP theStack;
int N, DFI, v, uparent, u, e;

#ifdef PROFILE
platform_time start, end;
platform_GetTime(start);
#endif

     if (theGraph==NULL) return NOTOK;
     if (theGraph->internalFlags & FLAGS_DFSNUMBERED) return OK;

     gp_LogLine("\ngraphDFSUtils.c/gp_CreateDFSTree() start");

     N = theGraph->N;
     theStack  = theGraph->theStack;

/* There are 2M edge records (arcs) and for each we can push 2 integers,
        so a stack of 2 * arcCapacity integers suffices.
        This is already in theGraph structure, so we make sure it's empty,
        then clear all visited flags in prep for the Depth first search. */

     if (sp_GetCapacity(theStack) < 2*gp_GetArcCapacity(theGraph))
    	 return NOTOK;

     sp_ClearStack(theStack);

     _ClearVertexVisitedFlags(theGraph, FALSE);

/* This outer loop causes the connected subgraphs of a disconnected
        graph to be numbered */

     for (DFI = v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, DFI); v++)
     {
          if (gp_IsNotDFSTreeRoot(theGraph, v))
              continue;

          sp_Push2(theStack, NIL, NIL);
          while (sp_NonEmpty(theStack))
          {
              sp_Pop2(theStack, uparent, e);
              u = gp_IsNotVertex(uparent) ? v : gp_GetNeighbor(theGraph, e);

              if (!gp_GetVertexVisited(theGraph, u))
              {
            	  gp_LogLine(gp_MakeLogStr3("V=%d, DFI=%d, Parent=%d", u, DFI, uparent));

            	  gp_SetVertexVisited(theGraph, u);
                  gp_SetVertexIndex(theGraph, u, DFI++);
                  gp_SetVertexParent(theGraph, u, uparent);
                  if (gp_IsArc(e))
                  {
                      gp_SetEdgeType(theGraph, e, EDGE_TYPE_CHILD);
                      gp_SetEdgeType(theGraph, gp_GetTwinArc(theGraph, e), EDGE_TYPE_PARENT);
                  }

                  /* Push edges to all unvisited neighbors. These will be either
                        tree edges to children or forward arcs of back edges */

                  e = gp_GetFirstArc(theGraph, u);
                  while (gp_IsArc(e))
                  {
                      if (!gp_GetVertexVisited(theGraph, gp_GetNeighbor(theGraph, e)))
                          sp_Push2(theStack, u, e);
                      e = gp_GetNextArc(theGraph, e);
                  }
              }
              else
              {
                  // If the edge leads to a visited vertex, then it is
            	  // the forward arc of a back edge.
                  gp_SetEdgeType(theGraph, e, EDGE_TYPE_FORWARD);
                  gp_SetEdgeType(theGraph, gp_GetTwinArc(theGraph, e), EDGE_TYPE_BACK);
              }
          }
     }

     gp_LogLine("graphDFSUtils.c/gp_CreateDFSTree() end\n");

     theGraph->internalFlags |= FLAGS_DFSNUMBERED;

#ifdef PROFILE
platform_GetTime(end);
printf("DFS in %.3lf seconds.\n", platform_GetDuration(start,end));
#endif

     return OK;
}

/********************************************************************
 gp_SortVertices()
 Once depth first numbering has been applied to the graph, the index
 member of each vertex contains the DFI.  This routine can reorder the
 vertices in linear time so that they appear in ascending order by DFI.
 Note that the index field is then used to store the original number
 of the vertex. Therefore, a second call to this method will put the
 vertices back to the original order and put the DFIs back into the
 index fields of the vertices.

 NOTE: This function is used by the core planarity algorithm, once its
 custom DFS has assigned DFIs to the vertices.  Once gp_Embed() has
 finished creating an embedding or obstructing subgraph, this function
 can be called to restore the original vertex numbering, if needed.
 ********************************************************************/

int  gp_SortVertices(graphP theGraph)
{
     return theGraph->functions.fpSortVertices(theGraph);
}

int  _SortVertices(graphP theGraph)
{
int  v, EsizeOccupied, e, srcPos, dstPos;

#ifdef PROFILE
platform_time start, end;
platform_GetTime(start);
#endif

     if (theGraph == NULL) return NOTOK;
     if (!(theGraph->internalFlags&FLAGS_DFSNUMBERED))
         if (gp_CreateDFSTree(theGraph) != OK)
             return NOTOK;

     gp_LogLine("\ngraphDFSUtils.c/_SortVertices() start");

     /* Change labels of edges from v to DFI(v)-- or vice versa
        Also, if any links go back to locations 0 to n-1, then they
        need to be changed because we are reordering the vertices */

     EsizeOccupied = gp_EdgeInUseIndexBound(theGraph);
     for (e = gp_GetFirstEdge(theGraph); e < EsizeOccupied; e+=2)
     {
    	 if (gp_EdgeInUse(theGraph, e))
    	 {
    		 gp_SetNeighbor(theGraph, e, gp_GetVertexIndex(theGraph, gp_GetNeighbor(theGraph, e)));
    		 gp_SetNeighbor(theGraph, e+1, gp_GetVertexIndex(theGraph, gp_GetNeighbor(theGraph, e+1)));
    	 }
     }

     /* Convert DFSParent from v to DFI(v) or vice versa */

     for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
          if (gp_IsNotDFSTreeRoot(theGraph, v))
              gp_SetVertexParent(theGraph, v, gp_GetVertexIndex(theGraph, gp_GetVertexParent(theGraph, v)));

     /* Sort by 'v using constant time random access. Move each vertex to its
        destination 'v', and store its source location in 'v'. */

     /* First we clear the visitation flags.  We need these to help mark
        visited vertices because we change the 'v' field to be the source
        location, so we cannot use index==v as a test for whether the
        correct vertex is in location 'index'. */

     _ClearVertexVisitedFlags(theGraph, FALSE);

     /* We visit each vertex location, skipping those marked as visited since
        we've already moved the correct vertex into that location. The
        inner loop swaps the vertex at location v into the correct position,
        given by the index of the vertex at location v.  Then it marks that
        location as visited, then sets its index to be the location from
        whence we obtained the vertex record. */

     for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v); v++)
     {
          srcPos = v;
          while (!gp_GetVertexVisited(theGraph, v))
          {
              dstPos = gp_GetVertexIndex(theGraph, v);

              gp_SwapVertexRec(theGraph, dstPos, theGraph, v);
              gp_SwapVertexInfo(theGraph, dstPos, theGraph, v);

              gp_SetVertexVisited(theGraph, dstPos);
              gp_SetVertexIndex(theGraph, dstPos, srcPos);

              srcPos = dstPos;
          }
     }

     /* Invert the bit that records the sort order of the graph */

     theGraph->internalFlags ^= FLAGS_SORTEDBYDFI;

	 gp_LogLine("graphDFSUtils.c/_SortVertices() end\n");

#ifdef PROFILE
platform_GetTime(end);
printf("SortVertices in %.3lf seconds.\n", platform_GetDuration(start,end));
#endif

     return OK;
}

/********************************************************************
 gp_LowpointAndLeastAncestor()
        leastAncestor(v): min(v, ancestor neighbors of v, excluding parent)
        Lowpoint(v): min(leastAncestor(v), Lowpoint of DFS children of v)

 Lowpoint is computed via a post-order traversal of the DFS tree.
 We push the root of the DFS tree, then we loop while the stack is not empty.
 We pop a vertex; if it is not marked, then we are on our way down the DFS
 tree, so we mark it and push it back on, followed by pushing its
 DFS children.  The next time we pop the node, all of its children
 will have been popped, marked+children pushed, and popped again.  On
 the second pop of the vertex, we can therefore compute the lowpoint
 values based on the childrens' lowpoints and the least ancestor from
 among the edges in the vertex's adjacency list.

 If they have not already been performed, gp_CreateDFSTree() and
 gp_SortVertices() are invoked on the graph, and it is left in the
 sorted state on completion of this method.

 NOTE: This is a utility function provided for general use of the graph
 library. The core planarity algorithm computes leastAncestor during its
 initial DFS, and it computes the lowpoint of a vertex as it embeds the
 tree edges to its children.
 ********************************************************************/

int  gp_LowpointAndLeastAncestor(graphP theGraph)
{
stackP theStack = theGraph->theStack;
int v, u, uneighbor, e, L, leastAncestor;

	 if (theGraph == NULL) return NOTOK;

	 if (!(theGraph->internalFlags&FLAGS_DFSNUMBERED))
		 if (gp_CreateDFSTree(theGraph) != OK)
			 return NOTOK;

     if (!(theGraph->internalFlags & FLAGS_SORTEDBYDFI))
    	 if (gp_SortVertices(theGraph) != OK)
    		 return NOTOK;

#ifdef PROFILE
platform_time start, end;
platform_GetTime(start);
#endif

	 gp_LogLine("\ngraphDFSUtils.c/gp_LowpointAndLeastAncestor() start");

	 // A stack of size N suffices because at maximum every vertex is pushed only once
	 // However, since a larger stack is needed for the main DFS, this is mainly documentation
	 if (sp_GetCapacity(theStack) < theGraph->N)
		 return NOTOK;

     sp_ClearStack(theStack);

     _ClearVertexVisitedFlags(theGraph, FALSE);

     // This outer loop causes the connected subgraphs of a disconnected graph to be processed
     for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v);)
     {
          if (gp_GetVertexVisited(theGraph, v))
          {
        	  ++v;
              continue;
          }

          sp_Push(theStack, v);
          while (sp_NonEmpty(theStack))
          {
              sp_Pop(theStack, u);

              // If not visited, then we're on the pre-order visitation, so push u and its DFS children
              if (!gp_GetVertexVisited(theGraph, u))
              {
                  // Mark u as visited, then push it back on the stack
                  gp_SetVertexVisited(theGraph, u);
                  ++v;
                  sp_Push(theStack, u);

                  // Push the DFS children of u
                  e = gp_GetFirstArc(theGraph, u);
                  while (gp_IsArc(e))
                  {
                      if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_CHILD)
                      {
                          sp_Push(theStack, gp_GetNeighbor(theGraph, e));
                      }

                      e = gp_GetNextArc(theGraph, e);
                  }
              }

              // If u has been visited before, then this is the post-order visitation
              else
              {
                  // Start with high values because we are doing a min function
                  leastAncestor = L = u;

                  // Compute leastAncestor and L, the least lowpoint from the DFS children
                  e = gp_GetFirstArc(theGraph, u);
                  while (gp_IsArc(e))
                  {
                      uneighbor = gp_GetNeighbor(theGraph, e);
                      if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_CHILD)
                      {
                          if (L > gp_GetVertexLowpoint(theGraph, uneighbor))
                              L = gp_GetVertexLowpoint(theGraph, uneighbor);
                      }
                      else if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_BACK)
                      {
                          if (leastAncestor > uneighbor)
                              leastAncestor = uneighbor;
                      }

                      e = gp_GetNextArc(theGraph, e);
                  }

                  /* Assign leastAncestor and Lowpoint to the vertex */
                  gp_SetVertexLeastAncestor(theGraph, u, leastAncestor);
                  gp_SetVertexLowpoint(theGraph, u, leastAncestor < L ? leastAncestor : L);
              }
         }
     }

	 gp_LogLine("graphDFSUtils.c/gp_LowpointAndLeastAncestor() end\n");

#ifdef PROFILE
platform_GetTime(end);
printf("Lowpoint in %.3lf seconds.\n", platform_GetDuration(start,end));
#endif

     return OK;
}

/********************************************************************
 gp_LeastAncestor()

 By simple pre-order visitation, compute the least ancestor of each
 vertex that is directly adjacent to the vertex by a back edge.

 If they have not already been performed, gp_CreateDFSTree() and
 gp_SortVertices() are invoked on the graph, and it is left in the
 sorted state on completion of this method.

 NOTE: This method is not called by gp_LowpointAndLeastAncestor(),
 which computes both values at the same time.

 NOTE: This method is useful in core planarity initialization when
 a graph has already been DFS numbered and sorted by DFI. For example,
 this allows the core planarity embedder to avoid perturbing unit test
 graphs that may be designed and stored in a DFI sorted format.
 ********************************************************************/

int  gp_LeastAncestor(graphP theGraph)
{
stackP theStack = theGraph->theStack;
int v, u, uneighbor, e, leastAncestor;

	 if (theGraph == NULL) return NOTOK;

	 if (!(theGraph->internalFlags&FLAGS_DFSNUMBERED))
		 if (gp_CreateDFSTree(theGraph) != OK)
			 return NOTOK;

	 if (!(theGraph->internalFlags & FLAGS_SORTEDBYDFI))
		 if (gp_SortVertices(theGraph) != OK)
			 return NOTOK;

#ifdef PROFILE
platform_time start, end;
platform_GetTime(start);
#endif

	 gp_LogLine("\ngraphDFSUtils.c/gp_LeastAncestor() start");

	 // A stack of size N suffices because at maximum every vertex is pushed only once
	 if (sp_GetCapacity(theStack) < theGraph->N)
		 return NOTOK;

	 sp_ClearStack(theStack);

	 // This outer loop causes the connected subgraphs of a disconnected graph to be processed
	 for (v = gp_GetFirstVertex(theGraph); gp_VertexInRange(theGraph, v);)
	 {
		  if (gp_GetVertexVisited(theGraph, v))
		  {
			  ++v;
			  continue;
		  }

		  sp_Push(theStack, v);
		  while (sp_NonEmpty(theStack))
		  {
			  sp_Pop(theStack, u);

			  if (!gp_GetVertexVisited(theGraph, u))
			  {
				  gp_SetVertexVisited(theGraph, u);
				  ++v;
				  leastAncestor = u;

				  e = gp_GetFirstArc(theGraph, u);
				  while (gp_IsArc(e))
				  {
                      uneighbor = gp_GetNeighbor(theGraph, e);
					  if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_CHILD)
					  {
						  sp_Push(theStack, uneighbor);
					  }
					  else if (gp_GetEdgeType(theGraph, e) == EDGE_TYPE_BACK)
					  {
						  if (leastAncestor > uneighbor)
							  leastAncestor = uneighbor;
					  }

					  e = gp_GetNextArc(theGraph, e);
				  }
				  gp_SetVertexLeastAncestor(theGraph, u, leastAncestor);
			  }
		 }
	 }

	 gp_LogLine("graphDFSUtils.c/gp_LeastAncestor() end\n");

#ifdef PROFILE
platform_GetTime(end);
printf("LeastAncestor in %.3lf seconds.\n", platform_GetDuration(start,end));
#endif

	 return OK;
}
