#ifndef GRAPH_K23SEARCH_PRIVATE_H
#define GRAPH_K23SEARCH_PRIVATE_H

/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "graph.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
    // Overloaded function pointers
    graphFunctionTable functions;

} K23SearchContext;

#ifdef __cplusplus
}
#endif

#endif

