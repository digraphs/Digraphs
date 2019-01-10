#ifndef GRAPH_K23SEARCH_H
#define GRAPH_K23SEARCH_H

/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "graphStructures.h"

#ifdef __cplusplus
extern "C" {
#endif

#define K23SEARCH_NAME "K23Search"

int gp_AttachK23Search(graphP theGraph);
int gp_DetachK23Search(graphP theGraph);

#ifdef __cplusplus
}
#endif

#endif

