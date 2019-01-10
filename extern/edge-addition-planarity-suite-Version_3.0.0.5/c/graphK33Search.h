#ifndef GRAPH_K33SEARCH_H
#define GRAPH_K33SEARCH_H

/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "graphStructures.h"

#ifdef __cplusplus
extern "C" {
#endif

#define K33SEARCH_NAME "K33Search"

int gp_AttachK33Search(graphP theGraph);
int gp_DetachK33Search(graphP theGraph);

#ifdef __cplusplus
}
#endif

#endif

