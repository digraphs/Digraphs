/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/
#include <string.h>

#include "../lowLevelUtils/appconst.h"

/* Private function declarations (exported within system) */
size_t _g6_GetNumCharsForEncoding(int order);
int _g6_GetNumCharsForOrder(int order);
size_t _g6_GetExpectedNumPaddingZeroes(const int order, const size_t numChars);
// NOTE: this method is used by g6_ReadGraph() to ensure that graphs after the
// first one in the file have the same order, and by g6_WriteGraph() to ensure
// that the encoding of the graph order at the beginning of the graph encoding
// is correct. The G6 format specification does not have this restriction, but
// the docs for Nauty's geng utility indicate that its output files will only
// contain all graphs up to isomorphism for the single graph order specified
// with the positional command line argument.
int _g6_ValidateOrderOfEncodedGraph(char *graphBuff, int order);
// NOTE: this method is now used to validate each graph we're reading in, as
// well as to check the validity of the encoding produced before attempting to
// write.
int _g6_ValidateGraphEncoding(char *graphBuff, const int order, const size_t numChars);

/* Private functions */
size_t _g6_GetMaxEdgeCount(int);

size_t _g6_GetMaxEdgeCount(int order)
{
    return ((size_t)order * (order - 1)) / 2;
}

size_t _g6_GetNumCharsForEncoding(int order)
{
    size_t maxNumEdges = _g6_GetMaxEdgeCount(order);

    return (maxNumEdges / 6) + (maxNumEdges % 6 ? 1 : 0);
}

int _g6_GetNumCharsForOrder(int order)
{
    if (order > 0 && order < 63)
    {
        return 1;
    }
    else if (order >= 63 && order <= 100000)
    {
        return 4;
    }

    return -1;
}

size_t _g6_GetExpectedNumPaddingZeroes(const int order, const size_t numChars)
{
    size_t maxNumEdges = _g6_GetMaxEdgeCount(order);
    size_t expectedNumPaddingZeroes = numChars * 6 - maxNumEdges;

    return expectedNumPaddingZeroes;
}

int _g6_ValidateOrderOfEncodedGraph(char *graphBuff, int order)
{
    int n = 0;
    char currChar = graphBuff[0];

    if (currChar == 126)
    {
        if (graphBuff[1] == 126)
        {
            gp_ErrorMessage("Can only handle graphs of order <= 100,000.");
            return NOTOK;
        }
        else if (graphBuff[1] > 126)
        {
            gp_ErrorMessage("Invalid graph order signifier.");
            return NOTOK;
        }
        else
        {
            int orderCharIndex = 2;
            for (int i = 1; i < 4; i++)
                n |= (graphBuff[i] - 63) << (6 * orderCharIndex--);
        }
    }
    else if (currChar > 62 && currChar < 126)
        n = currChar - 63;
    else
    {
        gp_ErrorMessage("Character doesn't correspond to a printable ASCII "
                        "character.");
        return NOTOK;
    }

    if (n != order)
    {
        gp_ErrorMessage("Graph order %d doesn't match expected graph order %d",
                        n, order);
        return NOTOK;
    }

    return OK;
}

int _g6_ValidateGraphEncoding(char *graphBuff, const int order, const size_t numChars)
{
    int exitCode = OK;

    size_t numPaddingZeroes = 0, numCharsForGraphEncoding = 0;
    size_t expectedNumPaddingZeroes = 0, expectedNumChars = 0;
    char finalByte = '\0';

    if (graphBuff == NULL || strlen(graphBuff) == 0)
    {
        gp_ErrorMessage("Invalid encoding: graphBuff is NULL or empty.");
        return NOTOK;
    }

    expectedNumPaddingZeroes = _g6_GetExpectedNumPaddingZeroes(order, numChars);
    finalByte = graphBuff[numChars - 1] - 63;

    // Num edges of the graph (and therefore the number of bits) is (n * (n-1))/2, and
    // since each resulting byte needs to correspond to an ascii character between 63 and 126,
    // each group is only comprised of 6 bits (to which we add 63 for the final byte value)
    expectedNumChars = _g6_GetNumCharsForEncoding(order);
    numCharsForGraphEncoding = strlen(graphBuff);

    if (expectedNumChars != numCharsForGraphEncoding)
    {
        gp_ErrorMessage("Invalid number of bytes for graph of order %d; got %d "
                        "but expected %d",
                        order,
                        (int)numCharsForGraphEncoding,
                        (int)expectedNumChars);
        return NOTOK;
    }

    // Check that characters are valid ASCII characters between 62 and 126
    for (size_t i = 0; i < numChars; i++)
    {
        if (graphBuff[i] < 63 || graphBuff[i] > 126)
        {
            gp_ErrorMessage("Invalid character at index %d: '%c'",
                            (int)i, graphBuff[i]);
            return NOTOK;
        }
    }

    // Check that there are no extraneous bits in representation (since we pad out to a
    // multiple of 6 before splitting into bytes and adding 63 to each byte)
    for (size_t i = 0; i < expectedNumPaddingZeroes; i++)
    {
        if (finalByte & (1 << i))
            break;

        numPaddingZeroes++;
    }

    if (numPaddingZeroes != expectedNumPaddingZeroes)
    {
        gp_ErrorMessage("Expected %d padding zeroes, but got %d.",
                        (int)expectedNumPaddingZeroes, (int)numPaddingZeroes);
        exitCode = NOTOK;
    }

    return exitCode;
}
