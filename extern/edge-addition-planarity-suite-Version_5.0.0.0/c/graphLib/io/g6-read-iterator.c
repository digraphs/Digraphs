/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include <stdlib.h>
#include <string.h>

#include "strOrFile.h"

#include "g6-read-iterator.h"

// For definition of zero-based IO flag
#include "graphIO.h"

/* Imported functions */
extern size_t _g6_GetNumCharsForEncoding(int order);
extern int _g6_GetNumCharsForOrder(int order);
extern size_t _g6_GetExpectedNumPaddingZeroes(const int order, const size_t numChars);
extern int _g6_ValidateOrderOfEncodedGraph(char *graphBuff, int order);
extern int _g6_ValidateGraphEncoding(char *graphBuff, const int order, const size_t numChars);

/* Private function declarations (exported within system) */
int _g6_ReadGraphFromStrOrFile(graphP theGraph, strOrFileP *pInputContainer);

/* Private functions */
int _g6_InitReaderWithStrOrFile(G6ReadIteratorP theG6ReadIterator, strOrFileP *pInputContainer);
int _g6_InitReader(G6ReadIteratorP theG6ReadIterator);
int _g6_IsReaderInitialized(G6ReadIteratorP theG6ReadIterator, int reportUninitializedParts);
int _g6_ValidateHeader(strOrFileP inputContainer);
int _g6_ValidateFirstChar(char c, const int lineNum);
int _g6_DetermineOrderFromInput(strOrFileP inputContainer, int *order);

int _g6_DecodeGraph(char *graphBuff, const int order, const int numChars, graphP theGraph);

int _g6_ReadGraphFromFile(graphP theGraph, char *pathToG6File);
int _g6_ReadGraphFromString(graphP theGraph, char *g6EncodedString);

/********************************************************************
 Package private structure declaration for read iterator
 ********************************************************************/
typedef struct strOrFileStruct strOrFileStruct;
typedef strOrFileStruct *strOrFileP;

struct G6ReadIteratorStruct
{
    strOrFileP inputContainer;
    int numGraphsRead;

    int order;
    int numCharsForOrder;
    size_t numCharsForGraphEncoding;
    size_t currGraphBuffSize;
    char *currGraphBuff;

    graphP currGraph;

    int endReached;
};

/********************************************************************
 Public and package private method implementations for read iterator
 ********************************************************************/

int g6_NewReader(G6ReadIteratorP *pG6ReadIterator, graphP theGraph)
{
    int exitCode = OK;

    if (pG6ReadIterator == NULL)
    {
        gp_ErrorMessage("Unable to allocate G6ReadIterator, as pointer to "
                        "which to assign address of memory allocated for "
                        "G6ReadIterator is NULL.");
        return NOTOK;
    }

    if (pG6ReadIterator != NULL && (*pG6ReadIterator) != NULL)
    {
        gp_ErrorMessage("G6ReadIterator is not NULL and therefore can't be "
                        "allocated.");
        return NOTOK;
    }

    // numGraphsRead, order, numCharsForOrder, numCharsForGraphEncoding, and
    // currGraphBuffSize all set to 0
    (*pG6ReadIterator) = (G6ReadIteratorP)calloc(1, sizeof(G6ReadIteratorStruct));

    if ((*pG6ReadIterator) == NULL)
    {
        gp_ErrorMessage("Unable to allocate memory for G6ReadIterator.");
        return NOTOK;
    }

    (*pG6ReadIterator)->inputContainer = NULL;

    if (theGraph == NULL)
    {
        gp_ErrorMessage("Must allocate graph to be used by G6ReadIterator.");

        g6_FreeReader(pG6ReadIterator);
    }
    else
    {
        (*pG6ReadIterator)->currGraph = theGraph;
    }

    return exitCode;
}

int _g6_IsReaderInitialized(G6ReadIteratorP theG6ReadIterator, int reportUninitializedParts)
{
    int readerInitialized = TRUE;

    if (theG6ReadIterator == NULL)
    {
        if (reportUninitializedParts)
            gp_ErrorMessage("G6ReadIterator is NULL.");
        readerInitialized = FALSE;
    }
    else
    {
        if (!sf_IsValidStrOrFile(theG6ReadIterator->inputContainer))
        {
            if (reportUninitializedParts)
                gp_ErrorMessage("G6ReadIterator's inputContainer string-or-file "
                                "container is not valid.");
            readerInitialized = FALSE;
        }
        if (theG6ReadIterator->currGraphBuff == NULL)
        {
            if (reportUninitializedParts)
                gp_ErrorMessage("G6ReadIterator's currGraphBuff is NULL.");
            readerInitialized = FALSE;
        }
        if (theG6ReadIterator->currGraph == NULL)
        {
            if (reportUninitializedParts)
                gp_ErrorMessage("G6ReadIterator's currGraph is NULL.");
            readerInitialized = FALSE;
        }
    }

    return readerInitialized;
}

int g6_EndReached(G6ReadIteratorP theG6ReadIterator)
{
    if (theG6ReadIterator == NULL)
        return TRUE;

    return theG6ReadIterator->endReached;
}

int g6_InitReaderWithString(G6ReadIteratorP theG6ReadIterator, char *inputString)
{
    strOrFileP inputContainer = NULL;

    if (theG6ReadIterator == NULL)
    {
        gp_ErrorMessage("Invalid parameter: theG6ReadIterator must be non-NULL.");
        return NOTOK;
    }

    if (_g6_IsReaderInitialized(theG6ReadIterator, FALSE))
    {
        gp_ErrorMessage("Unable to initialize reader, as it was already "
                        "previously initialized.");
        return NOTOK;
    }

    if (inputString == NULL || strlen(inputString) == 0)
    {
        gp_ErrorMessage("Unable to initialize reader with empty input string.");
        return NOTOK;
    }

    if ((inputContainer = sf_NewInputContainer(inputString, NULL)) == NULL)
    {
        gp_ErrorMessage("Unable to initialize reader with string, as we failed "
                        "to allocate the inputContainer.");
        return NOTOK;
    }

    return _g6_InitReaderWithStrOrFile(
        theG6ReadIterator,
        (&inputContainer));
}

int g6_InitReaderWithFileName(G6ReadIteratorP theG6ReadIterator, char const *const infileName)
{
    strOrFileP inputContainer = NULL;

    if (theG6ReadIterator == NULL)
    {
        gp_ErrorMessage("Invalid parameter: theG6ReadIterator must be non-NULL.");
        return NOTOK;
    }

    if (_g6_IsReaderInitialized(theG6ReadIterator, FALSE))
    {
        gp_ErrorMessage(
            "Unable to initialize reader, as it was already previously "
            "initialized.\n");
        return NOTOK;
    }

    if (infileName == NULL || strlen(infileName) == 0)
    {
        gp_ErrorMessage("Unable to initialize reader with empty infile name.");
        return NOTOK;
    }

    if ((inputContainer = sf_NewInputContainer(NULL, infileName)) == NULL)
    {
        gp_ErrorMessage("Unable to initialize reader with file name, as we "
                        "failed to allocate the inputContainer.");
        return NOTOK;
    }

    return _g6_InitReaderWithStrOrFile(
        theG6ReadIterator,
        (&inputContainer));
}

int _g6_InitReaderWithStrOrFile(G6ReadIteratorP theG6ReadIterator, strOrFileP *pInputContainer)
{
    if (theG6ReadIterator == NULL)
    {
        gp_ErrorMessage("Invalid parameter: theG6ReadIterator must be non-NULL.");
        return NOTOK;
    }

    if (pInputContainer == NULL || !sf_IsValidStrOrFile((*pInputContainer)))
    {
        gp_ErrorMessage("Unable to initialize reader with invalid strOrFile "
                        "input container.");
        return NOTOK;
    }

    theG6ReadIterator->inputContainer = (*pInputContainer);
    // We have taken ownership of the inputContainer, and so we have set the
    // caller's pointer to NULL. The reader is responsible for freeing this
    // input container.
    (*pInputContainer) = NULL;

    return _g6_InitReader(theG6ReadIterator);
}

int _g6_InitReader(G6ReadIteratorP theG6ReadIterator)
{
    char charConfirmation = EOF;
    int firstChar = '\0';
    int lineNum = 1;
    int order = NIL;
    strOrFileP inputContainer = theG6ReadIterator->inputContainer;

    if ((firstChar = sf_getc(inputContainer)) == EOF)
    {
        gp_ErrorMessage("Unable to initialize reader: .g6 infile is empty.");
        return NOTOK;
    }
    else
    {
        charConfirmation = sf_ungetc((char)firstChar, inputContainer);

        if (charConfirmation != firstChar)
        {
            gp_ErrorMessage("Unable to initialize reader due to failure to "
                            "ungetc first character.");
            return NOTOK;
        }

        if (firstChar == '>')
        {
            if (_g6_ValidateHeader(inputContainer) != OK)
            {
                gp_ErrorMessage("Unable to initialize reader due to inability "
                                "to process and check .g6 infile header.");
                return NOTOK;
            }
        }
    }

    firstChar = sf_getc(inputContainer);
    charConfirmation = sf_ungetc((char)firstChar, inputContainer);

    if (charConfirmation != firstChar)
    {
        gp_ErrorMessage("Unable to initialize reader due to failure to ungetc "
                        "first character.");
        return NOTOK;
    }

    if (_g6_ValidateFirstChar((char)firstChar, lineNum) != OK)
        return NOTOK;

    // Despite the general specification indicating that n \in [0, 68,719,476,735],
    // in practice n will be limited such that an integer will suffice in storing it.
    if (_g6_DetermineOrderFromInput(inputContainer, &order) != OK)
    {
        gp_ErrorMessage("Unable to initialize reader due to invalid graph "
                        "order on line %d of .g6 file.",
                        lineNum);
        return NOTOK;
    }

    if (gp_GetN(theG6ReadIterator->currGraph) == 0)
    {
        if (gp_EnsureVertexCapacity(theG6ReadIterator->currGraph, order) != OK)
        {
            gp_ErrorMessage("Unable to initialize reader due to failure "
                            "initializing graph datastructure with order %d "
                            "for graph on line %d of the .g6 file.",
                            order, lineNum);
            return NOTOK;
        }

        theG6ReadIterator->order = order;
    }
    else
    {
        if (gp_GetN(theG6ReadIterator->currGraph) != order)
        {
            gp_ErrorMessage("Unable to initialize reader, as graph structure "
                            "passed in was already initialized with order "
                            "%d, which doesn't match the graph order %d "
                            "specified in the file.",
                            gp_GetN(theG6ReadIterator->currGraph), order);
            return NOTOK;
        }
        else
        {
            gp_ResetGraphStorage(theG6ReadIterator->currGraph);
            theG6ReadIterator->order = order;
        }
    }

    // Ensures zero-based flag is set regardless of whether the graph was initialized or reinitialized.
    theG6ReadIterator->currGraph->graphFlags |= GRAPHFLAGS_ZEROBASEDIO;

    theG6ReadIterator->numCharsForOrder = _g6_GetNumCharsForOrder(order);
    theG6ReadIterator->numCharsForGraphEncoding = _g6_GetNumCharsForEncoding(order);
    // Must add 3 bytes for newline, possible carriage return, and null terminator
    theG6ReadIterator->currGraphBuffSize = theG6ReadIterator->numCharsForOrder + theG6ReadIterator->numCharsForGraphEncoding + 3;
    theG6ReadIterator->currGraphBuff = (char *)calloc(theG6ReadIterator->currGraphBuffSize, sizeof(char));

    if (theG6ReadIterator->currGraphBuff == NULL)
    {
        gp_ErrorMessage("Unable to allocate memory for currGraphBuff.");
        return NOTOK;
    }

    return OK;
}

int _g6_ValidateHeader(strOrFileP inputContainer)
{
    char const *g6Header = ">>graph6<<";
    char const *sparse6Header = ">>sparse6<";
    char const *digraph6Header = ">>digraph6";

    char headerCandidateChars[11];
    headerCandidateChars[0] = '\0';

    if (inputContainer == NULL)
    {
        gp_ErrorMessage("Invalid .g6 string-or-file container.");
        return NOTOK;
    }

    for (int i = 0; i < 10; i++)
    {
        headerCandidateChars[i] = sf_getc(inputContainer);
    }

    headerCandidateChars[10] = '\0';

    if (strcmp(g6Header, headerCandidateChars) != 0)
    {
        if (strcmp(sparse6Header, headerCandidateChars) == 0)
            gp_ErrorMessage("Graph file is sparse6 format, which is not "
                            "supported.");
        else if (strcmp(digraph6Header, headerCandidateChars) == 0)
            gp_ErrorMessage("Graph file is digraph6 format, which is not "
                            "supported.");
        else
            gp_ErrorMessage("Invalid header for .g6 file.");

        return NOTOK;
    }

    return OK;
}

int _g6_ValidateFirstChar(char c, const int lineNum)
{
    if (strchr(":;&", c) != NULL)
    {
        gp_ErrorMessage("Invalid first character on line %d, i.e. one of ':', "
                        "';', or '&'.",
                        lineNum);

        return NOTOK;
    }

    return OK;
}

int _g6_DetermineOrderFromInput(strOrFileP inputContainer, int *order)
{
    int n = 0;
    int graphChar = '\0';

    if (inputContainer == NULL)
    {
        gp_ErrorMessage("Invalid string-or-file container for .g6 input.");
        return NOTOK;
    }

    // Since geng: n must be in the range 1..32, and since edge-addition-planarity-suite
    // processing of random graphs may only handle up to n = 100,000, we will only check
    // if 1 or 4 bytes are necessary
    if ((graphChar = sf_getc(inputContainer)) == 126)
    {
        if ((graphChar = sf_getc(inputContainer)) == 126)
        {
            gp_ErrorMessage("Graphs of order n > 100000 are not supported at "
                            "this time.");
            return NOTOK;
        }

        sf_ungetc((char)graphChar, inputContainer);

        for (int i = 2; i >= 0; i--)
        {
            graphChar = sf_getc(inputContainer) - 63;
            n |= graphChar << (6 * i);
        }

        if (n > 100000)
        {
            gp_ErrorMessage("Graph order greater than 100000 not supported.");
            return NOTOK;
        }
    }
    else if (graphChar > 62 && graphChar < 126)
        n = graphChar - 63;
    else
    {
        gp_ErrorMessage("Graph order is too small; character doesn't "
                        "correspond to a printable ASCII character.");
        return NOTOK;
    }

    (*order) = n;

    return OK;
}

int g6_ReadGraph(G6ReadIteratorP theG6ReadIterator)
{
    strOrFileP inputContainer = NULL;
    int lineNum = 0;
    char *currGraphBuff = NULL;
    char firstChar = '\0';
    char *graphEncodingChars = NULL;
    graphP currGraph = NULL;
    const int order = theG6ReadIterator == NULL ? 0 : theG6ReadIterator->order;
    const int numCharsForOrder = theG6ReadIterator == NULL ? 0 : theG6ReadIterator->numCharsForOrder;
    const int numCharsForGraphEncoding = theG6ReadIterator == NULL ? 0 : theG6ReadIterator->numCharsForGraphEncoding;
    const int currGraphBuffSize = theG6ReadIterator == NULL ? 0 : theG6ReadIterator->currGraphBuffSize;

    if (!_g6_IsReaderInitialized(theG6ReadIterator, TRUE))
    {
        gp_ErrorMessage("G6ReadIterator is not initialized.");
        return NOTOK;
    }

    inputContainer = theG6ReadIterator->inputContainer;
    lineNum = theG6ReadIterator->numGraphsRead + 1;
    currGraphBuff = theG6ReadIterator->currGraphBuff;
    currGraph = theG6ReadIterator->currGraph;

    if (sf_fgets(currGraphBuff, currGraphBuffSize, inputContainer) != NULL)
    {
        firstChar = currGraphBuff[0];

        if (_g6_ValidateFirstChar(firstChar, lineNum) != OK)
            return NOTOK;

        // From https://stackoverflow.com/a/28462221, strcspn finds the index of the first
        // char in charset; this way, I replace the char at that index with the null-terminator
        currGraphBuff[strcspn(currGraphBuff, "\n\r")] = '\0'; // works for LF, CR, CRLF, LFCR, ...

        // If the line was too long, then we would have placed the null terminator at the final
        // index (where it already was; see strcpn docs), and the length of the string will be
        // longer than the line should have been, i.e. orderOffset + numCharsForGraphRepr
        if ((int)strlen(currGraphBuff) != (((lineNum == 1) ? 0 : numCharsForOrder) + numCharsForGraphEncoding))
        {
            gp_ErrorMessage("Invalid line length read on line %d",
                            lineNum);
            return NOTOK;
        }

        if (lineNum > 1)
        {
            if (_g6_ValidateOrderOfEncodedGraph(currGraphBuff, order) != OK)
            {
                gp_ErrorMessage("Order of graph on line %d is incorrect.",
                                lineNum);
                return NOTOK;
            }
        }

        // On first line, we have already processed the characters corresponding to the graph
        // order, so there's no need to apply the offset. On subsequent lines, the orderOffset
        // must be applied so that we are only starting validation on the byte corresponding to
        // the encoding of the adjacency matrix.
        graphEncodingChars = (lineNum == 1) ? currGraphBuff : currGraphBuff + numCharsForOrder;

        if (_g6_ValidateGraphEncoding(graphEncodingChars, order, numCharsForGraphEncoding) != OK)
        {
            gp_ErrorMessage("Graph on line %d is invalid.", lineNum);
            return NOTOK;
        }

        if (lineNum > 1)
        {
            gp_ResetGraphStorage(currGraph);
            // Ensures zero-based flag is set after reinitializing graph.
            currGraph->graphFlags |= GRAPHFLAGS_ZEROBASEDIO;
        }

        if (_g6_DecodeGraph(graphEncodingChars, order, numCharsForGraphEncoding, currGraph) != OK)
        {
            gp_ErrorMessage("Unable to interpret bits on line %d to populate "
                            "adjacency matrix.",
                            lineNum);
            return NOTOK;
        }

        theG6ReadIterator->numGraphsRead = lineNum;
    }
    else
    {
        theG6ReadIterator->endReached = TRUE;
    }

    return OK;
}

// Takes the character array graphBuff, the derived number of vertices order,
// and the numChars corresponding to the number of characters after the first byte
// and performs the inverse transformation of the graph encoding: we subtract 63 from
// each byte, then only process the 6 least significant bits of the resulting byte. For
// the final byte, we determine how many padding zeroes to expect, and exclude them
// from being processed. We index into the adjacency matrix by row and column, which
// are incremented such that row ranges from 0 to one less than the column index.
int _g6_DecodeGraph(char *graphBuff, const int order, const int numChars, graphP theGraph)
{
    int numPaddingZeroes = _g6_GetExpectedNumPaddingZeroes(order, numChars);

    char currByte = '\0';
    int bitValue = 0;
    int row = 0;
    int col = 1;

    if (theGraph == NULL)
    {
        gp_ErrorMessage("Must initialize graph datastructure before decoding "
                        "the graph representation.");
        return NOTOK;
    }

    for (int i = 0; i < numChars; i++)
    {
        currByte = graphBuff[i] - 63;
        // j corresponds to the number of places one must bitshift the byte by
        // to read the next bit in the byte
        for (int j = sizeof(char) * 5; j >= 0; j--)
        {
            // If we are on the final byte, we know that the final
            // numPaddingZeroes bits can be ignored, so we break out of the loop
            if ((i == numChars) && j == numPaddingZeroes - 1)
                break;

            if (row == col)
            {
                row = 0;
                col++;
            }

            bitValue = ((currByte >> j) & 1u) ? 1 : 0;
            if (bitValue == 1)
            {
                // Also add the offset to the first vertex in in-memory storage,
                // because the G6 file is 0-based, but im-memory storage may not be.
                if (gp_DynamicAddEdge(theGraph,
                                      row + gp_LowerBoundVertexStorage(theGraph), 0,
                                      col + gp_LowerBoundVertexStorage(theGraph), 0) != OK)
                    return NOTOK;
            }

            row++;
        }
    }

    return OK;
}

void g6_FreeReader(G6ReadIteratorP *pG6ReadIterator)
{
    if (pG6ReadIterator != NULL && (*pG6ReadIterator) != NULL)
    {
        if ((*pG6ReadIterator)->inputContainer != NULL)
            sf_Free(&((*pG6ReadIterator)->inputContainer));

        (*pG6ReadIterator)->numGraphsRead = 0;
        (*pG6ReadIterator)->order = 0;

        if ((*pG6ReadIterator)->currGraphBuff != NULL)
        {
            free((*pG6ReadIterator)->currGraphBuff);
            (*pG6ReadIterator)->currGraphBuff = NULL;
        }

        (*pG6ReadIterator)->currGraph = NULL;

        free((*pG6ReadIterator));
        (*pG6ReadIterator) = NULL;
    }
}

int _g6_ReadGraphFromFile(graphP theGraph, char *pathToG6File)
{
    strOrFileP inputContainer = NULL;

    if (pathToG6File == NULL || strlen(pathToG6File) == 0)
    {
        gp_ErrorMessage("Unable to read graph from file, as pathToG6File is "
                        "NULL or empty string.");
        return NOTOK;
    }

    if ((inputContainer = sf_NewInputContainer(NULL, pathToG6File)) == NULL)
    {
        gp_ErrorMessage("Unable to allocate strOrFile container for infile "
                        "\"%.*s\".",
                        FILENAME_MAX, pathToG6File);
        return NOTOK;
    }

    return _g6_ReadGraphFromStrOrFile(theGraph, (&inputContainer));
}

int _g6_ReadGraphFromString(graphP theGraph, char *g6EncodedString)
{
    strOrFileP inputContainer = NULL;

    if (g6EncodedString == NULL || strlen(g6EncodedString) == 0)
    {
        gp_ErrorMessage("Unable to proceed with empty .g6 input string.");
        return NOTOK;
    }

    if ((inputContainer = sf_NewInputContainer(g6EncodedString, NULL)) == NULL)
    {
        gp_ErrorMessage("Unable to allocate strOrFile container for .g6 input "
                        "string.");
        return NOTOK;
    }

    return _g6_ReadGraphFromStrOrFile(theGraph, (&inputContainer));
}

int _g6_ReadGraphFromStrOrFile(graphP theGraph, strOrFileP *pInputContainer)
{
    G6ReadIteratorP theG6ReadIterator = NULL;

    if (!sf_IsValidStrOrFile((*pInputContainer)))
    {
        gp_ErrorMessage("Invalid G6 output container.");
        return NOTOK;
    }

    if (g6_NewReader((&theG6ReadIterator), theGraph) != OK)
    {
        gp_ErrorMessage("Unable to allocate G6ReadIterator.");
        return NOTOK;
    }

    // NOTE: (*pInputContainer) will be NULL after we return from this call,
    // since the read iterator will take ownership of the input container.
    if (_g6_InitReaderWithStrOrFile(theG6ReadIterator, pInputContainer) != OK)
    {
        gp_ErrorMessage("Unable to initialize G6ReadIterator.");
        g6_FreeReader((&theG6ReadIterator));
        return NOTOK;
    }

    if (g6_ReadGraph(theG6ReadIterator) != OK)
        gp_ErrorMessage("Unable to read graph from .g6 read iterator.");

    g6_FreeReader((&theG6ReadIterator));

    return OK;
}
