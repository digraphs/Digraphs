#ifndef GRAPH_K4SEARCH_H
#define GRAPH_K4SEARCH_H

/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "graphStructures.h"

#ifdef __cplusplus
extern "C" {
#endif

#define K4SEARCH_NAME "K4Search"

int gp_AttachK4Search(graphP theGraph);
int gp_DetachK4Search(graphP theGraph);

#ifdef __cplusplus
}
#endif

#endif

