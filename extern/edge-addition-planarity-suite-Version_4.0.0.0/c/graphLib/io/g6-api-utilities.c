/*
Copyright (c) 1997-2025, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "g6-api-utilities.h"

int _getMaxEdgeCount(int graphOrder)
{
    return (graphOrder * (graphOrder - 1)) / 2;
}

int _getNumCharsForGraphEncoding(int graphOrder)
{
    int maxNumEdges = _getMaxEdgeCount(graphOrder);

    return (maxNumEdges / 6) + (maxNumEdges % 6 ? 1 : 0);
}

int _getNumCharsForGraphOrder(int graphOrder)
{
    if (graphOrder > 0 && graphOrder < 63)
    {
        return 1;
    }
    else if (graphOrder >= 63 && graphOrder <= 100000)
    {
        return 4;
    }

    return -1;
}

int _getExpectedNumPaddingZeroes(const int graphOrder, const int numChars)
{
    int maxNumEdges = _getMaxEdgeCount(graphOrder);
    int expectedNumPaddingZeroes = numChars * 6 - maxNumEdges;

    return expectedNumPaddingZeroes;
}
