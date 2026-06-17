/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#ifndef G6_READ_ITERATOR
#define G6_READ_ITERATOR

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdio.h>

#include "../graph.h"

    typedef struct G6ReadIteratorStruct G6ReadIteratorStruct;
    typedef G6ReadIteratorStruct *G6ReadIteratorP;

    int g6_NewReader(G6ReadIteratorP *pG6ReadIterator, graphP theGraph);

    int g6_InitReaderWithString(G6ReadIteratorP theG6ReadIterator, char *inputString);
    int g6_InitReaderWithFileName(G6ReadIteratorP theG6ReadIterator, char const *const infileName);

    int g6_ReadGraph(G6ReadIteratorP theG6ReadIterator);

    int g6_EndReached(G6ReadIteratorP theG6ReadIterator);
    void g6_FreeReader(G6ReadIteratorP *pG6ReadIterator);

#ifdef __cplusplus
}
#endif

#endif /* G6_READ_ITERATOR */
