#ifndef GRAPH_DRAWPLANAR_H
#define GRAPH_DRAWPLANAR_H

/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "graphStructures.h"

#ifdef __cplusplus
extern "C" {
#endif

#define DRAWPLANAR_NAME "DrawPlanar"

int gp_AttachDrawPlanar(graphP theGraph);
int gp_DetachDrawPlanar(graphP theGraph);

int  gp_DrawPlanar_RenderToFile(graphP theEmbedding, char *theFileName);

#ifdef __cplusplus
}
#endif

#endif

