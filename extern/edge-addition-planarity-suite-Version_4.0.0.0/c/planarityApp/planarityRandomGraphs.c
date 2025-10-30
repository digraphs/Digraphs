/*
Copyright (c) 1997-2025, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "planarity.h"

void GetNumberIfZero(int *pNum, char *prompt, int min, int max);
void ReinitializeGraph(graphP *pGraph, int ReuseGraphs, char command);
graphP MakeGraph(int Size, char command);

/****************************************************************************
 RandomGraphs()
 Top-level method to randomly generate graphs to test the algorithm given by
 the command parameter.
 The number of graphs to generate, and the number of vertices for each graph,
 can be sent as the second and third params.  For each that is sent as zero,
 this method will prompt the user for a value.
 ****************************************************************************/

#define NUM_MINORS 9

int RandomGraphs(char command, int NumGraphs, int SizeOfGraphs, char *outfileName)
{
    char theFileName[MAXLINE + 1];
    strOrFileP outputContainer = NULL;
    int K, countUpdateFreq;
    int Result = OK, MainStatistic = 0;
    int ObstructionMinorFreqs[NUM_MINORS];
    graphP theGraph = NULL, origGraph = NULL;
    platform_time start, end;
    int embedFlags = GetEmbedFlags(command);
    int ReuseGraphs = TRUE;
    int writeResult;
    int writeErrorReported_Random = FALSE, writeErrorReported_Embedded = FALSE,
        writeErrorReported_AdjList = FALSE, writeErrorReported_Obstructed = FALSE,
        writeErrorReported_Error = FALSE;

    char *messageFormat = NULL;
    char messageContents[MAXLINE + 1];
    int charsAvailForStr = 0;

    GetNumberIfZero(&NumGraphs, "Enter number of graphs to generate:", 1, 1000000000);
    GetNumberIfZero(&SizeOfGraphs, "Enter size of graphs:", 1, 10000);

    theGraph = MakeGraph(SizeOfGraphs, command);
    origGraph = MakeGraph(SizeOfGraphs, command);
    if (theGraph == NULL || origGraph == NULL)
    {
        gp_Free(&theGraph);
        return NOTOK;
    }

    // Initialize a secondary statistics array
    for (K = 0; K < NUM_MINORS; K++)
        ObstructionMinorFreqs[K] = 0;

    G6WriteIterator *pG6WriteIterator = NULL;
    if (outfileName != NULL || (tolower(OrigOut) == 'y' && tolower(OrigOutFormat) == 'g'))
    {
        if (allocateG6WriteIterator(&pG6WriteIterator, theGraph) != OK)
        {
            ErrorMessage("Unable to allocate G6WriteIterator.\n");
            gp_Free(&theGraph);
            return NOTOK;
        }
    }

    messageFormat = "Unable to allocate strOrFile container for outfile \"%.*s\".\n";
    charsAvailForStr = (int)(MAXLINE - strlen(messageFormat));
    if (outfileName != NULL)
    {
        outputContainer = sf_New(NULL, outfileName, WRITETEXT);
        if (outputContainer == NULL)
        {
            sprintf(messageContents, messageFormat, charsAvailForStr, outfileName);
            ErrorMessage(messageContents);

            if (freeG6WriteIterator(&pG6WriteIterator) != OK)
                ErrorMessage("Unable to free G6WriteIterator.\n");

            gp_Free(&theGraph);

            return NOTOK;
        }
    }
    else if (tolower(OrigOut) == 'y' && tolower(OrigOutFormat) == 'g')
    {
        // If outfileName is NULL, then the only case in which we would want to
        // output the generated random graphs to .g6 is if we Reconfigure() and
        // choose these options; in that case, need to set a default output filename.
        sprintf(theFileName, "random%cn%d.k%d.g6", FILE_DELIMITER, SizeOfGraphs, NumGraphs);
        outputContainer = sf_New(NULL, theFileName, WRITETEXT);
        if (outputContainer == NULL)
        {
            sprintf(messageContents, messageFormat, charsAvailForStr, theFileName);
            ErrorMessage(messageContents);

            if (freeG6WriteIterator(&pG6WriteIterator) != OK)
                ErrorMessage("Unable to free G6WriteIterator.\n");

            gp_Free(&theGraph);

            return NOTOK;
        }
    }

    if (pG6WriteIterator != NULL && outputContainer != NULL)
    {
        if (beginG6WriteIterationToG6StrOrFile(pG6WriteIterator, outputContainer) != OK)
        {
            ErrorMessage("Unable to begin writing random graphs to G6WriteIterator.\n");

            if (freeG6WriteIterator(&pG6WriteIterator) != OK)
                ErrorMessage("Unable to free G6WriteIterator.\n");

            gp_Free(&theGraph);
            return NOTOK;
        }
    }

    // Seed the random number generator with "now". Do it after any prompting
    // to tie randomness to human process of answering the prompt.
    srand(time(NULL));

    // Select a counter update frequency that updates more frequently with larger graphs
    // and which is relatively prime with 10 so that all digits of the count will change
    // even though we aren't showing the count value on every iteration
    countUpdateFreq = 3579 / SizeOfGraphs;
    countUpdateFreq = countUpdateFreq < 1 ? 1 : countUpdateFreq;
    countUpdateFreq = countUpdateFreq % 2 == 0 ? countUpdateFreq + 1 : countUpdateFreq;
    countUpdateFreq = countUpdateFreq % 5 == 0 ? countUpdateFreq + 2 : countUpdateFreq;

    // Start the count
    fprintf(stdout, "0\r");
    fflush(stdout);

    // Start the timer
    platform_GetTime(start);

    messageFormat = "Failed to write graph \"%.*s\"\nMake the directory if not present\n";
    charsAvailForStr = (int)(MAXLINE - strlen(messageFormat));
    // Generate and process the number of graphs requested
    for (K = 0; K < NumGraphs; K++)
    {
        if ((Result = gp_CreateRandomGraph(theGraph)) == OK)
        {
            if (pG6WriteIterator != NULL)
            {
                writeResult = writeGraphUsingG6WriteIterator(pG6WriteIterator);
                if (writeResult != OK)
                {
                    sprintf(messageContents, "Unable to write graph number %d using G6WriteIterator.\n", K);
                    ErrorMessage(messageContents);
                }
            }
            if (tolower(OrigOut) == 'y' && tolower(OrigOutFormat) == 'a')
            {
                sprintf(theFileName, "random%c%d.txt", FILE_DELIMITER, K % 10);
                writeResult = gp_Write(theGraph, theFileName, WRITE_ADJLIST);
                if (writeResult != OK && !writeErrorReported_Random)
                {
                    sprintf(messageContents, messageFormat, charsAvailForStr, theFileName);
                    ErrorMessage(messageContents);
                    writeErrorReported_Random = TRUE;
                }
            }

            gp_CopyGraph(origGraph, theGraph);

            if (strchr(GetAlgorithmChoices(), command))
            {
                Result = gp_Embed(theGraph, embedFlags);

                if (gp_TestEmbedResultIntegrity(theGraph, origGraph, Result) != Result)
                    Result = NOTOK;

                if (Result == OK)
                {
                    MainStatistic++;

                    if (tolower(EmbeddableOut) == 'y')
                    {
                        sprintf(theFileName, "embedded%c%d.txt", FILE_DELIMITER, K % 10);
                        writeResult = gp_Write(theGraph, theFileName, WRITE_ADJMATRIX);
                        if (writeResult != OK && !writeErrorReported_Embedded)
                        {
                            sprintf(messageContents, messageFormat, charsAvailForStr, theFileName);
                            ErrorMessage(messageContents);
                            writeErrorReported_Embedded = TRUE;
                        }
                    }

                    if (tolower(AdjListsForEmbeddingsOut) == 'y')
                    {
                        sprintf(theFileName, "adjlist%c%d.txt", FILE_DELIMITER, K % 10);
                        writeResult = gp_Write(theGraph, theFileName, WRITE_ADJLIST);
                        if (writeResult != OK && !writeErrorReported_AdjList)
                        {
                            sprintf(messageContents, messageFormat, charsAvailForStr, theFileName);
                            ErrorMessage(messageContents);
                            writeErrorReported_AdjList = TRUE;
                        }
                    }
                }
                else if (Result == NONEMBEDDABLE)
                {
                    if (embedFlags == EMBEDFLAGS_PLANAR || embedFlags == EMBEDFLAGS_OUTERPLANAR)
                    {
                        if (theGraph->IC.minorType & MINORTYPE_A)
                            ObstructionMinorFreqs[0]++;
                        else if (theGraph->IC.minorType & MINORTYPE_B)
                            ObstructionMinorFreqs[1]++;
                        else if (theGraph->IC.minorType & MINORTYPE_C)
                            ObstructionMinorFreqs[2]++;
                        else if (theGraph->IC.minorType & MINORTYPE_D)
                            ObstructionMinorFreqs[3]++;
                        else if (theGraph->IC.minorType & MINORTYPE_E)
                            ObstructionMinorFreqs[4]++;

                        if (theGraph->IC.minorType & MINORTYPE_E1)
                            ObstructionMinorFreqs[5]++;
                        else if (theGraph->IC.minorType & MINORTYPE_E2)
                            ObstructionMinorFreqs[6]++;
                        else if (theGraph->IC.minorType & MINORTYPE_E3)
                            ObstructionMinorFreqs[7]++;
                        else if (theGraph->IC.minorType & MINORTYPE_E4)
                            ObstructionMinorFreqs[8]++;

                        if (tolower(ObstructedOut) == 'y')
                        {
                            sprintf(theFileName, "obstructed%c%d.txt", FILE_DELIMITER, K % 10);
                            writeResult = gp_Write(theGraph, theFileName, WRITE_ADJMATRIX);
                            if (writeResult != OK && !writeErrorReported_Obstructed)
                            {
                                sprintf(messageContents, messageFormat, charsAvailForStr, theFileName);
                                ErrorMessage(messageContents);
                                writeErrorReported_Obstructed = TRUE;
                            }
                        }
                    }
                }
            }

            // If there is an error in processing, then write the file for debugging
            if (Result != OK && Result != NONEMBEDDABLE)
            {
                sprintf(theFileName, "error%c%d.txt", FILE_DELIMITER, K % 10);
                writeResult = gp_Write(origGraph, theFileName, WRITE_ADJLIST);
                if (writeResult != OK && !writeErrorReported_Error)
                {
                    sprintf(messageContents, messageFormat, charsAvailForStr, theFileName);
                    ErrorMessage(messageContents);
                    writeErrorReported_Error = TRUE;
                }
            }
        }

        // Reinitialize or recreate graphs for next iteration
        ReinitializeGraph(&theGraph, ReuseGraphs, command);
        ReinitializeGraph(&origGraph, ReuseGraphs, command);

        // Show progress, but not so often that it bogs down progress
        if (!getQuietModeSetting() && (K + 1) % countUpdateFreq == 0)
        {
            fprintf(stdout, "%d\r", K + 1);
            fflush(stdout);
        }

        // Terminate loop on error
        if (Result != OK && Result != NONEMBEDDABLE)
        {
            ErrorMessage("\nError found\n");
            Result = NOTOK;
            break;
        }
    }

    // Stop the timer
    platform_GetTime(end);

    // Finish the count
    fprintf(stdout, "%d\n", NumGraphs);
    fflush(stdout);

    if (pG6WriteIterator != NULL)
    {
        if (endG6WriteIteration(pG6WriteIterator) != OK && freeG6WriteIterator(&pG6WriteIterator) != OK)
        {
            ErrorMessage("Unable to properly terminate .g6 write iteration.\n");
        }
    }
    // Free the graph structures created before the loop
    gp_Free(&theGraph);
    gp_Free(&origGraph);

    // Print some demographic results
    if (Result == OK || Result == NONEMBEDDABLE)
        Message("\nNo Errors Found.");

    sprintf(messageContents, "\nDone (%.3lf seconds).\n", platform_GetDuration(start, end));
    Message(messageContents);

    // Report statistics for planar or outerplanar embedding
    if (embedFlags == EMBEDFLAGS_PLANAR || embedFlags == EMBEDFLAGS_OUTERPLANAR)
    {
        sprintf(messageContents, "Num Embedded=%d.\n", MainStatistic);
        Message(messageContents);

        for (K = 0; K < 5; K++)
        {
            // Outerplanarity does not produces minors C and D
            if (embedFlags == EMBEDFLAGS_OUTERPLANAR && (K == 2 || K == 3))
                continue;

            sprintf(messageContents, "Minor %c = %d\n", K + 'A', ObstructionMinorFreqs[K]);
            Message(messageContents);
        }

        if (!(embedFlags & ~EMBEDFLAGS_PLANAR))
        {
            sprintf(messageContents, "\nNote: E1 are added to C, E2 are added to A, and E=E3+E4+K5 homeomorphs.\n");
            Message(messageContents);

            for (K = 5; K < NUM_MINORS; K++)
            {
                sprintf(messageContents, "Minor E%d = %d\n", K - 4, ObstructionMinorFreqs[K]);
                Message(messageContents);
            }
        }
    }

    // Report statistics for graph drawing
    else if (embedFlags == EMBEDFLAGS_DRAWPLANAR)
    {
        sprintf(messageContents, "Num Graphs Embedded and Drawn=%d.\n", MainStatistic);
        Message(messageContents);
    }

    // Report statistics for subgraph homeomorphism algorithms
    else if (embedFlags == EMBEDFLAGS_SEARCHFORK23)
    {
        sprintf(messageContents, "Of the generated graphs, %d did not contain a K_{2,3} homeomorph as a subgraph.\n", MainStatistic);
        Message(messageContents);
    }
    else if (embedFlags == EMBEDFLAGS_SEARCHFORK33)
    {
        sprintf(messageContents, "Of the generated graphs, %d did not contain a K_{3,3} homeomorph as a subgraph.\n", MainStatistic);
        Message(messageContents);
    }
    else if (embedFlags == EMBEDFLAGS_SEARCHFORK4)
    {
        sprintf(messageContents, "Of the generated graphs, %d did not contain a K_4 homeomorph as a subgraph.\n", MainStatistic);
        Message(messageContents);
    }

    FlushConsole(stdout);

    return Result == OK || Result == NONEMBEDDABLE ? OK : NOTOK;
}

/****************************************************************************
 GetNumberIfZero()
 Internal function that gets a number if the given *pNum is zero.
 The prompt is displayed if the number must be obtained from the user.
 Whether the given number is used or obtained from the user, the function
 ensures it is in the range [min, max] and assigns the midpoint value if
 it is not.
 ****************************************************************************/

void GetNumberIfZero(int *pNum, char *prompt, int min, int max)
{
    if (*pNum == 0)
    {
        Prompt(prompt);
        scanf(" %d", pNum);
    }

    if (min < 1)
        min = 1;
    if (max < min)
        max = min;

    if (*pNum < min || *pNum > max)
    {
        *pNum = (max + min) / 2;
        char messageContents[MAXLINE + 1];
        sprintf(messageContents, "Number out of range [%d, %d]; changed to %d\n", min, max, *pNum);
        ErrorMessage(messageContents);
    }
}

/****************************************************************************
 MakeGraph()
 Internal function that makes a new graph, initializes it, and attaches an
 algorithm to it based on the command.
 ****************************************************************************/

graphP MakeGraph(int Size, char command)
{
    graphP theGraph;
    if ((theGraph = gp_New()) == NULL || gp_InitGraph(theGraph, Size) != OK)
    {
        ErrorMessage("Error creating space for a graph of the given size.\n");
        gp_Free(&theGraph);
        return NULL;
    }

    // Enable the appropriate feature. Although the same code appears in SpecificGraph,
    // it is deliberately not separated to a common utility because SpecificGraph is
    // used as a self-contained tutorial.  It is not that hard to update both locations
    // when new algorithms are added.

    switch (command)
    {
    case 'd':
        gp_AttachDrawPlanar(theGraph);
        break;
    case '2':
        gp_AttachK23Search(theGraph);
        break;
    case '3':
        gp_AttachK33Search(theGraph);
        break;
    case '4':
        gp_AttachK4Search(theGraph);
        break;
    }

    return theGraph;
}

/****************************************************************************
 ReinitializeGraph()
 Internal function that will either reinitialize the given graph or free it
 and make a new one just like it.
 ****************************************************************************/

void ReinitializeGraph(graphP *pGraph, int ReuseGraphs, char command)
{
    if (ReuseGraphs)
        gp_ReinitializeGraph(*pGraph);
    else
    {
        graphP newGraph = MakeGraph((*pGraph)->N, command);
        gp_Free(pGraph);
        *pGraph = newGraph;
    }
}

/****************************************************************************
 Creates a random maximal planar graph, then adds 'extraEdges' edges to it.
 ****************************************************************************/

int RandomGraph(char command, int extraEdges, int numVertices, char *outfileName, char *outfile2Name)
{
    int Result;
    platform_time start, end;
    graphP theGraph = NULL, origGraph;
    int embedFlags = GetEmbedFlags(command);
    char saveEdgeListFormat;

    char *messageFormat = NULL;
    char messageContents[MAXLINE + 1];
    int charsAvailForStr = 0;

    GetNumberIfZero(&numVertices, "Enter number of vertices:", 1, 1000000);
    if ((theGraph = MakeGraph(numVertices, command)) == NULL)
        return NOTOK;

    srand(time(NULL));

    Message("Creating the random graph...\n");
    platform_GetTime(start);
    if (gp_CreateRandomGraphEx(theGraph, 3 * numVertices - 6 + extraEdges) != OK)
    {
        ErrorMessage("gp_CreateRandomGraphEx() failed\n");
        return NOTOK;
    }
    platform_GetTime(end);

    sprintf(messageContents, "Created random graph with %d edges in %.3lf seconds. ", theGraph->M, platform_GetDuration(start, end));
    Message(messageContents);
    FlushConsole(stdout);

    // The user may have requested a copy of the random graph before processing
    if (outfile2Name != NULL)
    {
        gp_Write(theGraph, outfile2Name, WRITE_ADJLIST);
    }

    origGraph = gp_DupGraph(theGraph);

    // Do the requested algorithm on the randomly generated graph
    Message("Now processing\n");
    FlushConsole(stdout);

    if (strchr(GetAlgorithmChoices(), command))
    {
        platform_GetTime(start);
        Result = gp_Embed(theGraph, embedFlags);
        platform_GetTime(end);

        gp_SortVertices(theGraph);

        if (gp_TestEmbedResultIntegrity(theGraph, origGraph, Result) != Result)
            Result = NOTOK;
    }
    else
        Result = NOTOK;

    // Write what the algorithm determined and how long it took
    WriteAlgorithmResults(theGraph, Result, command, start, end, NULL);

    // On successful algorithm result, write the output file and see if the
    // user wants the edge list formatted file.
    if (Result == OK || Result == NONEMBEDDABLE)
    {
        if (outfileName != NULL)
            gp_Write(theGraph, outfileName, WRITE_ADJLIST);

        if (!getQuietModeSetting())
        {
            Prompt("Do you want to save the generated graph in edge list format (y/n)? ");
            fflush(stdin);
            scanf(" %c", &saveEdgeListFormat);
        }
        else
            saveEdgeListFormat = 'n';

        if (tolower(saveEdgeListFormat) == 'y')
        {
            char theFileName[MAXLINE + 1];

            if (extraEdges > 0)
                strcpy(theFileName, "nonPlanarEdgeList.txt");
            else
                strcpy(theFileName, "maxPlanarEdgeList.txt");

            messageFormat = "Saving edge list format of original graph to \"%.*s\"\n";
            charsAvailForStr = (int)(MAXLINE - strlen(messageFormat));
            sprintf(messageContents, messageFormat, charsAvailForStr, theFileName);
            Message(messageContents);
            SaveAsciiGraph(origGraph, theFileName);

            strcat(theFileName, ".out.txt");
            messageFormat = "Saving edge list format of result to \"%.*s\"\n";
            charsAvailForStr = (int)(MAXLINE - strlen(messageFormat));
            sprintf(messageContents, messageFormat, charsAvailForStr, theFileName);
            Message(messageContents);
            SaveAsciiGraph(theGraph, theFileName);
        }
    }
    else
        ErrorMessage("Failure occurred");

    gp_Free(&theGraph);
    gp_Free(&origGraph);

    FlushConsole(stdout);
    return Result;
}
