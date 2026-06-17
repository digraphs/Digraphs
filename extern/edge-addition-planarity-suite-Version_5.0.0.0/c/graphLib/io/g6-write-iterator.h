/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#ifndef G6_WRITE_ITERATOR
#define G6_WRITE_ITERATOR

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdio.h>

#include "../graph.h"

    typedef struct G6WriteIteratorStruct G6WriteIteratorStruct;
    typedef G6WriteIteratorStruct *G6WriteIteratorP;

    int g6_NewWriter(G6WriteIteratorP *pG6WriteIterator, graphP theGraph);

    int g6_InitWriterWithString(G6WriteIteratorP theG6WriteIterator, char **pOutputString);
    int g6_InitWriterWithFileName(G6WriteIteratorP theG6WriteIterator, char *outputFileName);

    int g6_WriteGraph(G6WriteIteratorP theG6WriteIterator);

    void g6_FreeWriter(G6WriteIteratorP *pG6WriteIterator);

#ifdef __cplusplus
}
#endif

#endif /* G6_WRITE_ITERATOR */
