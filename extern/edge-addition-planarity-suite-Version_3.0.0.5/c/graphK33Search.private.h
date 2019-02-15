#ifndef GRAPH_K33SEARCH_PRIVATE_H
#define GRAPH_K33SEARCH_PRIVATE_H

/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "graph.h"

#ifdef __cplusplus
extern "C" {
#endif

// Additional equipment for each EdgeRec
typedef struct
{
     int  noStraddle, pathConnector;
} K33Search_EdgeRec;

typedef K33Search_EdgeRec * K33Search_EdgeRecP;

// Additional equipment for each primary vertex
typedef struct
{
        int separatedDFSChildList, backArcList, mergeBlocker;
} K33Search_VertexInfo;

typedef K33Search_VertexInfo * K33Search_VertexInfoP;


typedef struct
{
    // Helps distinguish initialize from re-initialize
    int initialized;

    // The graph that this context augments
    graphP theGraph;

    // Parallel array for additional edge level equipment
    K33Search_EdgeRecP E;

    // Parallel array for additional vertex info level equipment
    K33Search_VertexInfoP VI;

    // Storage for the separatedDFSChildLists, and
    // to help with linear time sorting of same by lowpoints
    listCollectionP separatedDFSChildLists;
    int *buckets;
    listCollectionP bin;

    // Overloaded function pointers
    graphFunctionTable functions;

} K33SearchContext;

#ifdef __cplusplus
}
#endif

#endif

