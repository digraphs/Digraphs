/*
Copyright (c) 1997-2025, John M. Boyer
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
#include <stdbool.h>

#include "../graph.h"
#include "strOrFile.h"

    typedef struct
    {
        strOrFileP g6Output;
        int numGraphsWritten;

        int graphOrder;
        int numCharsForGraphOrder;
        int numCharsForGraphEncoding;
        int currGraphBuffSize;
        char *currGraphBuff;

        int *columnOffsets;

        graphP currGraph;
    } G6WriteIterator;

    int allocateG6WriteIterator(G6WriteIterator **, graphP);
    bool _isG6WriteIteratorAllocated(G6WriteIterator *);

    int getNumGraphsWritten(G6WriteIterator *, int *);
    int getOrderOfGraphToWrite(G6WriteIterator *, int *);
    int getPointerToGraphToWrite(G6WriteIterator *, graphP *);

    int beginG6WriteIterationToG6StrOrFile(G6WriteIterator *pG6WriteIterator, strOrFileP outputContainer);
    int _beginG6WriteIteration(G6WriteIterator *pG6WriteIterator);
    void _precomputeColumnOffsets(int *, int);

    int writeGraphUsingG6WriteIterator(G6WriteIterator *);

    int _encodeAdjMatAsG6(G6WriteIterator *);
    int _getFirstEdge(graphP, int *, int *, int *);
    int _getNextEdge(graphP, int *, int *, int *);
    int _getNextInUseEdge(graphP theGraph, int *e, int *u, int *v);

    int _printEncodedGraph(G6WriteIterator *);

    int endG6WriteIteration(G6WriteIterator *);

    int freeG6WriteIterator(G6WriteIterator **);

    int _WriteGraphToG6FilePath(graphP pGraph, char *g6OutputFilename);
    int _WriteGraphToG6String(graphP pGraph, char **g6OutputStr);
    int _WriteGraphToG6StrOrFile(graphP pGraph, strOrFileP outputContainer, char **outputStr);

#ifdef __cplusplus
}
#endif

#endif /* G6_WRITE_ITERATOR */
