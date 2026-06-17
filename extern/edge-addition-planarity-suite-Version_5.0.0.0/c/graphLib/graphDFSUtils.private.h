/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#ifndef GRAPHDFSUTILS_PRIVATE_H
#define GRAPHDFSUTILS_PRIVATE_H

#include "graph.private.h"

#ifdef __cplusplus
extern "C"
{
#endif

    /********************************************************************
     Vertex Info Structure Definition.

     This structure equips the non-virtual vertices with additional
     information needed for DFS-related and planarity-related algorithms.

        parent: The DFI of the DFS tree parent of this vertex
        leastAncestor: min(DFI of neighbors connected by backedge)
        lowpoint: min(leastAncestor, min(lowpoint of DFS Children))
    */

    struct DFSUtils_VertexInfo
    {
        int parent, leastAncestor, lowpoint;
    };

    typedef struct DFSUtils_VertexInfo DFSUtils_VertexInfo;
    typedef DFSUtils_VertexInfo *DFSUtils_VertexInfoP;

    struct vertexInfoRec
    {
        int parent, leastAncestor, lowpoint;

        int visitedInfo;

        int pertinentEdge,
            pertinentRoots,
            futurePertinentChild,
            sortedDFSChildList,
            fwdEdgeList;
    };

    typedef struct vertexInfoRec vertexInfoRec;
    typedef vertexInfoRec *vertexInfoP;

#define gp_GetVertexParent(theGraph, v) (theGraphDVI(theGraph)[v].parent)
#define gp_SetVertexParent(theGraph, v, theParent) (theGraphDVI(theGraph)[v].parent = theParent)

#define gp_GetVertexLeastAncestor(theGraph, v) (theGraphDVI(theGraph)[v].leastAncestor)
#define gp_SetVertexLeastAncestor(theGraph, v, theLeastAncestor) (theGraphDVI(theGraph)[v].leastAncestor = theLeastAncestor)

#define gp_GetVertexLowpoint(theGraph, v) (theGraphDVI(theGraph)[v].lowpoint)
#define gp_SetVertexLowpoint(theGraph, v, theLowpoint) (theGraphDVI(theGraph)[v].lowpoint = theLowpoint)

#ifdef __cplusplus
}
#endif

#endif /* GRAPHPDFSUTILS_PRIVATE_H */
