/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#ifndef GRAPHIO_H
#define GRAPHIO_H

#ifdef __cplusplus
extern "C"
{
#endif

#include "../graph.h"

    int gp_Read(graphP theGraph, char const *fileName);
    int gp_ReadFromString(graphP theGraph, char *inputStr);

    int gp_Write(graphP theGraph, char const *fileName, int writeMode);
    int gp_WriteToString(graphP theGraph, char **pOutputStr, int writeMode);

// Mode values for gp_Write() and gp_WriteToString()
#define WRITE_ADJLIST 1
#define WRITE_ADJMATRIX 2
#define WRITE_DEBUGINFO 3
#define WRITE_G6 4

// Graph Flags: see gp_GetGraphFlags()
//       GRAPHFLAGS_ZEROBASEDIO is typically set by gp_Read() to indicate that the
//                  adjacency list representation in a file began with index 0.
#define GRAPHFLAGS_ZEROBASEDIO 16

#ifdef __cplusplus
}
#endif

#endif /* GRAPHIO_H */
