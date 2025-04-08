/*
Copyright (c) 1997-2025, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include <stdlib.h>
#include <string.h>

#include "g6-read-iterator.h"
#include "g6-api-utilities.h"

int allocateG6ReadIterator(G6ReadIterator **ppG6ReadIterator, graphP pGraph)
{
    int exitCode = OK;

    if (ppG6ReadIterator != NULL && (*ppG6ReadIterator) != NULL)
    {
        ErrorMessage("G6ReadIterator is not NULL and therefore can't be allocated.\n");
        return NOTOK;
    }

    // numGraphsRead, graphOrder, numCharsForGraphOrder,
    // numCharsForGraphEncoding, and currGraphBuffSize all set to 0
    (*ppG6ReadIterator) = (G6ReadIterator *)calloc(1, sizeof(G6ReadIterator));

    if ((*ppG6ReadIterator) == NULL)
    {
        ErrorMessage("Unable to allocate memory for G6ReadIterator.\n");
        return NOTOK;
    }

    (*ppG6ReadIterator)->g6Input = NULL;

    if (pGraph == NULL)
    {
        ErrorMessage("Must allocate graph to be used by G6ReadIterator.\n");

        exitCode = freeG6ReadIterator(ppG6ReadIterator);

        if (exitCode != OK)
            ErrorMessage("Unable to free the G6ReadIterator.\n");
    }
    else
    {
        (*ppG6ReadIterator)->currGraph = pGraph;
    }

    return exitCode;
}

bool _isG6ReadIteratorAllocated(G6ReadIterator *pG6ReadIterator)
{
    bool g6ReadIteratorIsAllocated = true;

    if (pG6ReadIterator == NULL || pG6ReadIterator->currGraph == NULL)
    {
        g6ReadIteratorIsAllocated = false;
    }

    return g6ReadIteratorIsAllocated;
}

int getNumGraphsRead(G6ReadIterator *pG6ReadIterator, int *pNumGraphsRead)
{
    if (pG6ReadIterator == NULL)
    {
        ErrorMessage("G6ReadIterator is not allocated.\n");
        return NOTOK;
    }

    (*pNumGraphsRead) = pG6ReadIterator->numGraphsRead;

    return OK;
}

int getOrderOfGraphToRead(G6ReadIterator *pG6ReadIterator, int *pGraphOrder)
{
    if (pG6ReadIterator == NULL)
    {
        ErrorMessage("G6ReadIterator is not allocated.\n");
        return NOTOK;
    }

    (*pGraphOrder) = pG6ReadIterator->graphOrder;

    return OK;
}

int getPointerToGraphReadIn(G6ReadIterator *pG6ReadIterator, graphP *ppGraph)
{
    if (pG6ReadIterator == NULL)
    {
        ErrorMessage("G6ReadIterator is not allocated.\n");
        return NOTOK;
    }

    (*ppGraph) = pG6ReadIterator->currGraph;

    return OK;
}

int beginG6ReadIterationFromG6StrOrFile(G6ReadIterator *pG6ReadIterator, strOrFileP g6InputContainer)
{
    if (
        sf_ValidateStrOrFile(g6InputContainer) != OK ||
        (g6InputContainer->theStr != NULL && sb_GetSize(g6InputContainer->theStr) == 0))
    {
        ErrorMessage("Invalid g6InputContainer; must contain either valid input stream or non-empty string.\n");
        return NOTOK;
    }

    pG6ReadIterator->g6Input = g6InputContainer;

    return _beginG6ReadIteration(pG6ReadIterator);
}

int _beginG6ReadIteration(G6ReadIterator *pG6ReadIterator)
{
    int exitCode = OK;
    char charConfirmation = EOF;

    char messageContents[MAXLINE + 1];

    strOrFileP g6Input = pG6ReadIterator->g6Input;

    int firstChar = sf_getc(g6Input);
    if (firstChar == EOF)
    {
        ErrorMessage(".g6 infile is empty.\n");
        return NOTOK;
    }
    else
    {
        charConfirmation = sf_ungetc((char)firstChar, g6Input);

        if (charConfirmation != firstChar)
        {
            ErrorMessage("Unable to ungetc first character.\n");
            return NOTOK;
        }

        if (firstChar == '>')
        {
            exitCode = _processAndCheckHeader(g6Input);
            if (exitCode != OK)
            {
                ErrorMessage("Unable to process and check .g6 infile header.\n");
                return exitCode;
            }
        }
    }

    int lineNum = 1;
    firstChar = sf_getc(g6Input);
    charConfirmation = sf_ungetc((char)firstChar, g6Input);

    if (charConfirmation != firstChar)
    {
        ErrorMessage("Unable to ungetc first character.\n");
        return NOTOK;
    }

    if (!_firstCharIsValid((char)firstChar, lineNum))
        return NOTOK;

    // Despite the general specification indicating that n \in [0, 68,719,476,735],
    // in practice n will be limited such that an integer will suffice in storing it.
    int graphOrder = -1;
    exitCode = _getGraphOrder(g6Input, &graphOrder);

    if (exitCode != OK)
    {
        sprintf(messageContents, "Invalid graph order on line %d of .g6 file.\n", lineNum);
        ErrorMessage(messageContents);
        return exitCode;
    }

    if (pG6ReadIterator->currGraph->N == 0)
    {
        exitCode = gp_InitGraph(pG6ReadIterator->currGraph, graphOrder);

        if (exitCode != OK)
        {
            sprintf(messageContents, "Unable to initialize graph datastructure with order %d for graph on line %d of the .g6 file.\n", graphOrder, lineNum);
            ErrorMessage(messageContents);
            return exitCode;
        }

        pG6ReadIterator->graphOrder = graphOrder;
    }
    else
    {
        if (pG6ReadIterator->currGraph->N != graphOrder)
        {
            sprintf(messageContents, "Graph datastructure passed to G6ReadIterator already initialized with graph order %d,\n", pG6ReadIterator->currGraph->N);
            ErrorMessage(messageContents);
            sprintf(messageContents, "\twhich doesn't match the graph order %d specified in the file.\n", graphOrder);
            ErrorMessage(messageContents);
            return NOTOK;
        }
        else
        {
            gp_ReinitializeGraph(pG6ReadIterator->currGraph);
            pG6ReadIterator->graphOrder = graphOrder;
        }
    }

    // Ensures zero-based flag is set regardless of whether the graph was initialized or reinitialized.
    pG6ReadIterator->currGraph->internalFlags |= FLAGS_ZEROBASEDIO;

    pG6ReadIterator->numCharsForGraphOrder = _getNumCharsForGraphOrder(graphOrder);
    pG6ReadIterator->numCharsForGraphEncoding = _getNumCharsForGraphEncoding(graphOrder);
    // Must add 3 bytes for newline, possible carriage return, and null terminator
    pG6ReadIterator->currGraphBuffSize = pG6ReadIterator->numCharsForGraphOrder + pG6ReadIterator->numCharsForGraphEncoding + 3;
    pG6ReadIterator->currGraphBuff = (char *)calloc(pG6ReadIterator->currGraphBuffSize, sizeof(char));

    if (pG6ReadIterator->currGraphBuff == NULL)
    {
        ErrorMessage("Unable to allocate memory for currGraphBuff.\n");
        exitCode = NOTOK;
    }

    return exitCode;
}

int _processAndCheckHeader(strOrFileP g6Input)
{
    int exitCode = OK;

    if (g6Input == NULL)
    {
        ErrorMessage("Invalid .g6 string-or-file container.\n");
        return NOTOK;
    }

    char *correctG6Header = ">>graph6<<";
    char *sparse6Header = ">>sparse6<";
    char *digraph6Header = ">>digraph6";

    char headerCandidateChars[11];
    headerCandidateChars[0] = '\0';

    for (int i = 0; i < 10; i++)
    {
        headerCandidateChars[i] = sf_getc(g6Input);
    }

    headerCandidateChars[10] = '\0';

    if (strcmp(correctG6Header, headerCandidateChars) != 0)
    {
        if (strcmp(sparse6Header, headerCandidateChars) == 0)
            ErrorMessage("Graph file is sparse6 format, which is not supported.\n");
        else if (strcmp(digraph6Header, headerCandidateChars) == 0)
            ErrorMessage("Graph file is digraph6 format, which is not supported.\n");
        else
            ErrorMessage("Invalid header for .g6 file.\n");

        exitCode = NOTOK;
    }

    return exitCode;
}

bool _firstCharIsValid(char c, const int lineNum)
{
    bool isValidFirstChar = false;

    if (strchr(":;&", c) != NULL)
    {
        char messageContents[MAXLINE + 1];
        sprintf(messageContents, "Invalid first character on line %d, i.e. one of ':', ';', or '&'; aborting.\n", lineNum);
        ErrorMessage(messageContents);
    }
    else
        isValidFirstChar = true;

    return isValidFirstChar;
}

int _getGraphOrder(strOrFileP g6Input, int *graphOrder)
{
    int exitCode = OK;

    if (g6Input == NULL)
    {
        ErrorMessage("Invalid string-or-file container for .g6 input.\n");
        return NOTOK;
    }

    // Since geng: n must be in the range 1..32, and since edge-addition-planarity-suite
    // processing of random graphs may only handle up to n = 100,000, we will only check
    // if 1 or 4 bytes are necessary
    int n = 0;
    int graphChar = sf_getc(g6Input);
    if (graphChar == 126)
    {
        if ((graphChar = sf_getc(g6Input)) == 126)
        {
            ErrorMessage("Graph order is too large; format suggests that 258048 <= n <= 68719476735, but we only support n <= 100000.\n");
            return NOTOK;
        }

        sf_ungetc((char)graphChar, g6Input);

        for (int i = 2; i >= 0; i--)
        {
            graphChar = sf_getc(g6Input) - 63;
            n |= graphChar << (6 * i);
        }

        if (n > 100000)
        {
            ErrorMessage("Graph order is too large; we only support n <= 100000.\n");
            return NOTOK;
        }
    }
    else if (graphChar > 62 && graphChar < 126)
        n = graphChar - 63;
    else
    {
        ErrorMessage("Graph order is too small; character doesn't correspond to a printable ASCII character.\n");
        return NOTOK;
    }

    (*graphOrder) = n;

    return exitCode;
}

int readGraphUsingG6ReadIterator(G6ReadIterator *pG6ReadIterator)
{
    int exitCode = OK;

    char messageContents[MAXLINE + 1];

    if (!_isG6ReadIteratorAllocated(pG6ReadIterator))
    {
        ErrorMessage("G6ReadIterator is not allocated.\n");
        return NOTOK;
    }

    strOrFileP g6Input = pG6ReadIterator->g6Input;

    if (g6Input == NULL)
    {
        ErrorMessage("Pointer to .g6 string-or-file container is NULL.\n");
        return NOTOK;
    }

    int numGraphsRead = pG6ReadIterator->numGraphsRead;

    char *currGraphBuff = pG6ReadIterator->currGraphBuff;

    if (currGraphBuff == NULL)
    {
        ErrorMessage("currGraphBuff string is null.\n");
        return NOTOK;
    }

    const int graphOrder = pG6ReadIterator->graphOrder;
    const int numCharsForGraphOrder = pG6ReadIterator->numCharsForGraphOrder;
    const int numCharsForGraphEncoding = pG6ReadIterator->numCharsForGraphEncoding;
    const int currGraphBuffSize = pG6ReadIterator->currGraphBuffSize;

    graphP currGraph = pG6ReadIterator->currGraph;

    char firstChar = '\0';
    char *graphEncodingChars = NULL;
    if (sf_fgets(currGraphBuff, currGraphBuffSize, g6Input) != NULL)
    {
        numGraphsRead++;
        firstChar = currGraphBuff[0];

        if (!_firstCharIsValid(firstChar, numGraphsRead))
            return NOTOK;

        // From https://stackoverflow.com/a/28462221, strcspn finds the index of the first
        // char in charset; this way, I replace the char at that index with the null-terminator
        currGraphBuff[strcspn(currGraphBuff, "\n\r")] = '\0'; // works for LF, CR, CRLF, LFCR, ...

        // If the line was too long, then we would have placed the null terminator at the final
        // index (where it already was; see strcpn docs), and the length of the string will be
        // longer than the line should have been, i.e. orderOffset + numCharsForGraphRepr
        if ((int)strlen(currGraphBuff) != (((numGraphsRead == 1) ? 0 : numCharsForGraphOrder) + numCharsForGraphEncoding))
        {
            sprintf(messageContents, "Invalid line length read on line %d\n", numGraphsRead);
            ErrorMessage(messageContents);
            return NOTOK;
        }

        if (numGraphsRead > 1)
        {
            exitCode = _checkGraphOrder(currGraphBuff, graphOrder);

            if (exitCode != OK)
            {
                sprintf(messageContents, "Order of graph on line %d is incorrect.\n", numGraphsRead);
                ErrorMessage(messageContents);
                return exitCode;
            }
        }

        // On first line, we have already processed the characters corresponding to the graph
        // order, so there's no need to apply the offset. On subsequent lines, the orderOffset
        // must be applied so that we are only starting validation on the byte corresponding to
        // the encoding of the adjacency matrix.
        graphEncodingChars = (numGraphsRead == 1) ? currGraphBuff : currGraphBuff + numCharsForGraphOrder;

        exitCode = _validateGraphEncoding(graphEncodingChars, graphOrder, numCharsForGraphEncoding);

        if (exitCode != OK)
        {
            sprintf(messageContents, "Graph on line %d is invalid.", numGraphsRead);
            ErrorMessage(messageContents);
            return exitCode;
        }

        if (numGraphsRead > 1)
        {
            gp_ReinitializeGraph(currGraph);
            // Ensures zero-based flag is set after reinitializing graph.
            currGraph->internalFlags |= FLAGS_ZEROBASEDIO;
        }

        exitCode = _decodeGraph(graphEncodingChars, graphOrder, numCharsForGraphEncoding, currGraph);

        if (exitCode != OK)
        {
            sprintf(messageContents, "Unable to interpret bits on line %d to populate adjacency matrix.\n", numGraphsRead);
            ErrorMessage(messageContents);
            return exitCode;
        }

        pG6ReadIterator->numGraphsRead = numGraphsRead;
    }
    else
        pG6ReadIterator->currGraph = NULL;

    return exitCode;
}

int _checkGraphOrder(char *graphBuff, int graphOrder)
{
    int exitCode = OK;

    int n = 0;
    char currChar = graphBuff[0];
    if (currChar == 126)
    {
        if (graphBuff[1] == 126)
        {
            ErrorMessage("Can only handle graphs of order <= 100,000.\n");
            return NOTOK;
        }
        else if (graphBuff[1] > 126)
        {
            ErrorMessage("Invalid graph order signifier.\n");
            return NOTOK;
        }

        int orderCharIndex = 2;

        for (int i = 1; i < 4; i++)
            n |= (graphBuff[i] - 63) << (6 * orderCharIndex--);
    }
    else if (currChar > 62 && currChar < 126)
        n = currChar - 63;
    else
    {
        ErrorMessage("Character doesn't correspond to a printable ASCII character.\n");
        return NOTOK;
    }

    if (n != graphOrder)
    {
        char messageContents[MAXLINE + 1];
        sprintf(messageContents, "Graph order %d doesn't match expected graph order %d", n, graphOrder);
        ErrorMessage(messageContents);
        exitCode = NOTOK;
    }

    return exitCode;
}

int _validateGraphEncoding(char *graphBuff, const int graphOrder, const int numChars)
{
    int exitCode = OK;

    char messageContents[MAXLINE + 1];

    // Num edges of the graph (and therefore the number of bits) is (n * (n-1))/2, and
    // since each resulting byte needs to correspond to an ascii character between 63 and 126,
    // each group is only comprised of 6 bits (to which we add 63 for the final byte value)
    int expectedNumChars = _getNumCharsForGraphEncoding(graphOrder);
    int numCharsForGraphEncoding = strlen(graphBuff);
    if (expectedNumChars != numCharsForGraphEncoding)
    {
        sprintf(messageContents, "Invalid number of bytes for graph of order %d; got %d but expected %d\n", graphOrder, numCharsForGraphEncoding, expectedNumChars);
        ErrorMessage(messageContents);
        return NOTOK;
    }

    // Check that characters are valid ASCII characters between 62 and 126
    for (int i = 0; i < numChars; i++)
    {
        if (graphBuff[i] < 63 || graphBuff[i] > 126)
        {
            sprintf(messageContents, "Invalid character at index %d: \"%c\"\n", i, graphBuff[i]);
            ErrorMessage(messageContents);
            return NOTOK;
        }
    }

    // Check that there are no extraneous bits in representation (since we pad out to a
    // multiple of 6 before splitting into bytes and adding 63 to each byte)
    int expectedNumPaddingZeroes = _getExpectedNumPaddingZeroes(graphOrder, numChars);
    char finalByte = graphBuff[numChars - 1] - 63;
    int numPaddingZeroes = 0;
    for (int i = 0; i < expectedNumPaddingZeroes; i++)
    {
        if (finalByte & (1 << i))
            break;

        numPaddingZeroes++;
    }

    if (numPaddingZeroes != expectedNumPaddingZeroes)
    {
        sprintf(messageContents, "Expected %d padding zeroes, but got %d.\n", expectedNumPaddingZeroes, numPaddingZeroes);
        ErrorMessage(messageContents);
        exitCode = NOTOK;
    }

    return exitCode;
}

// Takes the character array graphBuff, the derived number of vertices graphOrder,
// and the numChars corresponding to the number of characters after the first byte
// and performs the inverse transformation of the graph encoding: we subtract 63 from
// each byte, then only process the 6 least significant bits of the resulting byte. For
// the final byte, we determine how many padding zeroes to expect, and exclude them
// from being processed. We index into the adjacency matrix by row and column, which
// are incremented such that row ranges from 0 to one less than the column index.
int _decodeGraph(char *graphBuff, const int graphOrder, const int numChars, graphP pGraph)
{
    int exitCode = OK;

    if (pGraph == NULL)
    {
        ErrorMessage("Must initialize graph datastructure before invoking _decodeGraph.\n");
        return NOTOK;
    }

    int numPaddingZeroes = _getExpectedNumPaddingZeroes(graphOrder, numChars);

    char currByte = '\0';
    int bitValue = 0;
    int row = 0;
    int col = 1;
    for (int i = 0; i < numChars; i++)
    {
        currByte = graphBuff[i] - 63;
        // j corresponds to the number of places one must bitshift the byte by to read
        // the next bit in the byte
        for (int j = sizeof(char) * 5; j >= 0; j--)
        {
            // If we are on the final byte, we know that the final numPaddingZeroes bits
            // can be ignored, so we break out of the loop
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
                // Add gp_GetFirstVertex(pGraph), which is 1 if NIL == 0 (i.e. internal 1-based labelling) and 0 if NIL == -1 (internally 0-based)
                exitCode = gp_DynamicAddEdge(pGraph, row + gp_GetFirstVertex(pGraph), 0, col + gp_GetFirstVertex(pGraph), 0);
                if (exitCode != OK)
                    return exitCode;
            }

            row++;
        }
    }

    return exitCode;
}

int endG6ReadIteration(G6ReadIterator *pG6ReadIterator)
{
    int exitCode = OK;

    if (pG6ReadIterator != NULL)
    {
        if (pG6ReadIterator->g6Input != NULL)
            sf_Free(&(pG6ReadIterator->g6Input));

        if (pG6ReadIterator->currGraphBuff != NULL)
        {
            free(pG6ReadIterator->currGraphBuff);
            pG6ReadIterator->currGraphBuff = NULL;
        }
    }

    return exitCode;
}

int freeG6ReadIterator(G6ReadIterator **ppG6ReadIterator)
{
    int exitCode = OK;

    if (ppG6ReadIterator != NULL && (*ppG6ReadIterator) != NULL)
    {
        if ((*ppG6ReadIterator)->g6Input != NULL)
            sf_Free(&((*ppG6ReadIterator)->g6Input));

        (*ppG6ReadIterator)->numGraphsRead = 0;
        (*ppG6ReadIterator)->graphOrder = 0;

        if ((*ppG6ReadIterator)->currGraphBuff != NULL)
        {
            free((*ppG6ReadIterator)->currGraphBuff);
            (*ppG6ReadIterator)->currGraphBuff = NULL;
        }

        (*ppG6ReadIterator)->currGraph = NULL;

        free((*ppG6ReadIterator));
        (*ppG6ReadIterator) = NULL;
    }

    return exitCode;
}

int _ReadGraphFromG6FilePath(graphP pGraphToRead, char *pathToG6File)
{
    char *messageFormat = NULL;
    char messageContents[MAXLINE + 1];
    messageContents[MAXLINE] = '\0';
    int charsAvailForStr = 0;

    strOrFileP inputContainer = sf_New(NULL, pathToG6File, READTEXT);
    if (inputContainer == NULL)
    {
        messageFormat = "Unable to allocate strOrFile container for infile \"%.*s\".\n";
        charsAvailForStr = (int)(MAXLINE - strlen(messageFormat));
        sprintf(messageContents, messageFormat, charsAvailForStr, pathToG6File);
        ErrorMessage(messageContents);

        return NOTOK;
    }

    return _ReadGraphFromG6StrOrFile(pGraphToRead, inputContainer);
}

int _ReadGraphFromG6String(graphP pGraphToRead, char *g6EncodedString)
{
    if (g6EncodedString == NULL || strlen(g6EncodedString) == 0)
    {
        ErrorMessage("Unable to proceed with empty .g6 input string.\n");
        return NOTOK;
    }

    strOrFileP inputContainer = sf_New(g6EncodedString, NULL, READTEXT);
    if (inputContainer == NULL)
    {
        ErrorMessage("Unable to allocate strOrFile container for .g6 input string.\n");
        return NOTOK;
    }

    return _ReadGraphFromG6StrOrFile(pGraphToRead, inputContainer);
}

int _ReadGraphFromG6StrOrFile(graphP pGraphToRead, strOrFileP g6InputContainer)
{
    int exitCode = OK;

    G6ReadIterator *pG6ReadIterator = NULL;

    if (sf_ValidateStrOrFile(g6InputContainer) != OK)
    {
        ErrorMessage("Invalid G6 output container.\n");
        return NOTOK;
    }

    if (allocateG6ReadIterator(&pG6ReadIterator, pGraphToRead) != OK)
    {
        ErrorMessage("Unable to allocate G6ReadIterator.\n");
        return NOTOK;
    }

    if (beginG6ReadIterationFromG6StrOrFile(pG6ReadIterator, g6InputContainer) != OK)
    {
        ErrorMessage("Unable to begin .g6 read iteration.\n");

        if (freeG6ReadIterator(&pG6ReadIterator) != OK)
            ErrorMessage("Unable to free G6ReadIterator.\n");

        return NOTOK;
    }

    exitCode = readGraphUsingG6ReadIterator(pG6ReadIterator);
    if (exitCode != OK)
        ErrorMessage("Unable to read graph from .g6 read iterator.\n");

    int endG6ReadIterationCode = endG6ReadIteration(pG6ReadIterator);
    if (endG6ReadIterationCode != OK)
    {
        ErrorMessage("Unable to end G6ReadIterator.\n");
        exitCode = endG6ReadIterationCode;
    }

    int freeG6ReadIteratorCode = freeG6ReadIterator(&pG6ReadIterator);
    if (freeG6ReadIteratorCode != OK)
    {
        ErrorMessage("Unable to free G6ReadIterator.\n");
        exitCode = freeG6ReadIteratorCode;
    }

    return exitCode;
}
