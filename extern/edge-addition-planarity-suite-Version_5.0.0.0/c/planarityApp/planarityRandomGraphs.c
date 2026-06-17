/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "planarity.h"

int GetNumberIfZero(int *pNum, char const *prompt, int min, int max);
void ResetGraphStorage(graphP *pGraph, int ReuseGraphs, char command);
graphP MakeGraph(int Size, char command);
int PromptSaveGraph(graphP theGraph, graphP origGraph, int extraEdges, int saveMode);

/****************************************************************************
 * RandomGraphs()
 *
 * Top-level method to randomly generate graphs to test the algorithm given by
 * the command parameter.
 * The number of graphs to generate, and the number of vertices for each graph,
 * can be sent as the second and third params.  For each that is sent as zero,
 * this method will prompt the user for a value.
 ****************************************************************************/

#define NUM_MINORS 9

int RandomGraphs(char const *const commandString, int NumGraphs, int SizeOfGraphs, char *outfileName)
{
    int Result = OK;
    int writeResult = OK;

    int K = 0, countUpdateFreq = 0, embedFlags = 0, MainStatistic = 0;
    int ReuseGraphs = TRUE;

    char command = '\0', modifier = '\0';

    int ObstructionMinorFreqs[NUM_MINORS];

    graphP theGraph = NULL, origGraph = NULL;

    platform_time start, end;

    G6WriteIteratorP theG6WriteIterator = NULL;

    char const g6WriterInitializationgp_ErrorMessage[] = "Unable to write random graphs to G6 outfile \"%.*s\" due to failure initializing G6WriteIterator.";
    char const writegp_ErrorMessage[] = "Failed to write graph \"%.*s\".\nMake the directory if not present.";

    char theFileName[FILENAMEMAXLENGTH + 1];

    memset(ObstructionMinorFreqs, 0, NUM_MINORS * sizeof(int));
    memset(theFileName, '\0', (FILENAMEMAXLENGTH + 1));

    if ((Result = GetCommandAndOptionalModifier(commandString, &command, &modifier)) != OK)
    {
        gp_ErrorMessage("Unable to extract command and optional modifier "
                        "character from commandString.\n");
        return Result;
    }

    if ((Result = GetEmbedFlags(command, modifier, &embedFlags)) != OK)
    {
        gp_ErrorMessage("Unable to derive embedFlags from command and optional "
                        "modifier character.\n");
        return Result;
    }

    if ((Result = GetNumberIfZero(&NumGraphs, "Enter number of graphs to generate:", 1, 1000000000)) != OK)
    {
        gp_ErrorMessage("Encountered unrecoverable error when prompting for "
                        "NumGraphs.\n");
        return Result;
    }

    if ((Result = GetNumberIfZero(&SizeOfGraphs, "Enter size of graphs:", 1, 10000000)) != OK)
    {
        gp_ErrorMessage("Encountered unrecoverable error when prompting for "
                        "SizeOfGraphs.\n");
        return Result;
    }

    theGraph = MakeGraph(SizeOfGraphs, command);
    // The origGraph no longer needs extensions, so we just use a null terminator for the command
    origGraph = MakeGraph(SizeOfGraphs, '\0');
    if (theGraph == NULL || origGraph == NULL)
    {
        gp_ErrorMessage("Unable to allocate and initialize graph datastructures "
                        "to contain randomly generated graphs.\n");
        gp_Free(&theGraph);
        gp_Free(&origGraph);
        return NOTOK;
    }

    if (outfileName != NULL || (tolower(OrigOut) == 'y' && tolower(OrigOutFormat) == 'g'))
    {
        if (g6_NewWriter((&theG6WriteIterator), theGraph) != OK)
        {
            gp_ErrorMessage("Unable to allocate G6WriteIterator.");
            gp_Free(&theGraph);
            gp_Free(&origGraph);
            return NOTOK;
        }
    }

    if (outfileName != NULL)
    {
        if (g6_InitWriterWithFileName(theG6WriteIterator, outfileName) != OK)
        {
            gp_ErrorMessage(g6WriterInitializationgp_ErrorMessage, FILENAME_MAX, outfileName);
            g6_FreeWriter((&theG6WriteIterator));
            gp_Free(&theGraph);
            gp_Free(&origGraph);
            return NOTOK;
        }
    }
    else if (tolower(OrigOut) == 'y' && tolower(OrigOutFormat) == 'g')
    {
        // If outfileName is NULL, then the only case in which we would want to
        // output the generated random graphs to .g6 is if we Reconfigure() and
        // choose these options; in that case, need to set a default output file name.
        sprintf(theFileName, "random%cn%d.k%d.g6", FILE_DELIMITER, SizeOfGraphs, NumGraphs);
        if (g6_InitWriterWithFileName(theG6WriteIterator, theFileName) != OK)
        {
            gp_ErrorMessage(g6WriterInitializationgp_ErrorMessage,
                            FILENAME_MAX, theFileName);
            g6_FreeWriter((&theG6WriteIterator));
            gp_Free(&theGraph);
            gp_Free(&origGraph);
            return NOTOK;
        }
    }

    // Seed the random number generator with "now". Do it after any prompting
    // to tie randomness to human process of answering the prompt.
    // Acceptable downcast of time_t to unsigned int (seeding benefits from the lower bits of now)
    srand((unsigned int)time(NULL));

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

    // Generate and process the number of graphs requested
    for (K = 0; K < NumGraphs; K++)
    {
        if ((Result = gp_CreateRandomGraph(theGraph)) == OK)
        {
            if (theG6WriteIterator != NULL)
            {
                if ((writeResult = g6_WriteGraph(theG6WriteIterator)) != OK)
                {
                    gp_ErrorMessage("Unable to write graph number %d using "
                                    "G6WriteIterator.",
                                    K);
                    Result = writeResult;
                    break;
                }
            }
            else if (tolower(OrigOut) == 'y' && tolower(OrigOutFormat) == 'a')
            {
                sprintf(theFileName, "random%c%d.txt", FILE_DELIMITER, K % 10);
                if ((writeResult = gp_Write(theGraph, theFileName, WRITE_ADJLIST)) != OK)
                {
                    gp_ErrorMessage(writegp_ErrorMessage,
                                    FILENAME_MAX, theFileName);
                    Result = writeResult;
                    break;
                }
            }

            if ((Result = gp_CopyGraph(origGraph, theGraph)) != OK)
            {
                gp_ErrorMessage("Unable to make a copy of graph number %d "
                                "before embedding.",
                                K);
                gp_Free(&theGraph);
                gp_Free(&origGraph);
                g6_FreeWriter((&theG6WriteIterator));
                return Result;
            }

            Result = gp_Embed(theGraph, embedFlags);

            if (gp_TestEmbedResultIntegrity(theGraph, origGraph, Result) != Result)
                Result = NOTOK;

            if (Result == OK)
            {
                MainStatistic++;

                if (tolower(EmbeddableOut) == 'y')
                {
                    sprintf(theFileName, "embedded%c%d.txt", FILE_DELIMITER, K % 10);

                    if ((writeResult = gp_Write(theGraph, theFileName, WRITE_ADJMATRIX)) != OK)
                    {
                        gp_ErrorMessage(writegp_ErrorMessage,
                                        FILENAME_MAX, theFileName);
                        Result = writeResult;
                    }
                }

                if (tolower(AdjListsForEmbeddingsOut) == 'y')
                {
                    sprintf(theFileName, "adjlist%c%d.txt", FILE_DELIMITER, K % 10);

                    if ((writeResult = gp_Write(theGraph, theFileName, WRITE_ADJLIST)) != OK)
                    {
                        gp_ErrorMessage(writegp_ErrorMessage,
                                        FILENAME_MAX, theFileName);
                        Result = writeResult;
                    }
                }
            }
            else if (Result == NONEMBEDDABLE)
            {
                if (embedFlags == EMBEDFLAGS_PLANAR || embedFlags == EMBEDFLAGS_OUTERPLANAR)
                {
                    if (gp_GetObstructionMinorType(theGraph) & MINORTYPE_A)
                        ObstructionMinorFreqs[0]++;
                    else if (gp_GetObstructionMinorType(theGraph) & MINORTYPE_B)
                        ObstructionMinorFreqs[1]++;
                    else if (gp_GetObstructionMinorType(theGraph) & MINORTYPE_C)
                        ObstructionMinorFreqs[2]++;
                    else if (gp_GetObstructionMinorType(theGraph) & MINORTYPE_D)
                        ObstructionMinorFreqs[3]++;
                    else if (gp_GetObstructionMinorType(theGraph) & MINORTYPE_E)
                        ObstructionMinorFreqs[4]++;

                    if (gp_GetObstructionMinorType(theGraph) & MINORTYPE_E1)
                        ObstructionMinorFreqs[5]++;
                    else if (gp_GetObstructionMinorType(theGraph) & MINORTYPE_E2)
                        ObstructionMinorFreqs[6]++;
                    else if (gp_GetObstructionMinorType(theGraph) & MINORTYPE_E3)
                        ObstructionMinorFreqs[7]++;
                    else if (gp_GetObstructionMinorType(theGraph) & MINORTYPE_E4)
                        ObstructionMinorFreqs[8]++;

                    if (tolower(ObstructedOut) == 'y')
                    {
                        sprintf(theFileName, "obstructed%c%d.txt", FILE_DELIMITER, K % 10);

                        if ((writeResult = gp_Write(theGraph, theFileName, WRITE_ADJMATRIX)) != OK)
                        {
                            gp_ErrorMessage(writegp_ErrorMessage,
                                            FILENAME_MAX, theFileName);
                            Result = writeResult;
                        }
                    }
                }
            }

            // If there is an error in processing, then write the file for debugging
            if (Result != OK && Result != NONEMBEDDABLE)
            {
                sprintf(theFileName, "error%c%d.txt", FILE_DELIMITER, K % 10);
                if ((writeResult = gp_Write(origGraph, theFileName, WRITE_ADJLIST)) != OK)
                {
                    gp_ErrorMessage(writegp_ErrorMessage, FILENAME_MAX, theFileName);
                    Result = writeResult;
                }
            }
        }

        // Terminate loop on error
        if (Result != OK && Result != NONEMBEDDABLE)
        {
            gp_ErrorMessage("\nError found");
            Result = NOTOK;
            break;
        }

        // Reset (or recreate) graph for next iteration
        ResetGraphStorage(&theGraph, ReuseGraphs, command);

        // Show progress, but not so often that it bogs down progress
        if (!(gp_GetQuietMode() & QUIETMODE_MESSAGES))
        {
            if ((K + 1) % countUpdateFreq == 0)
            {
                fprintf(stdout, "%d\r", K + 1);
                fflush(stdout);
            }
        }
    }

    // Stop the timer
    platform_GetTime(end);

    // Finish the count
    fprintf(stdout, "%d\n", NumGraphs);
    fflush(stdout);

    gp_Message("Done (%.3lf seconds).", platform_GetDuration(start, end));

    // Print some demographic results
    if (Result == OK || Result == NONEMBEDDABLE)
    {
        gp_Message("No Errors Found.");
        // Report statistics for planar or outerplanar embedding
        if (embedFlags == EMBEDFLAGS_PLANAR || embedFlags == EMBEDFLAGS_OUTERPLANAR)
        {
            gp_Message("Num Embedded=%d.", MainStatistic);

            for (K = 0; K < 5; K++)
            {
                // Outerplanarity does not produces minors C and D
                if (embedFlags == EMBEDFLAGS_OUTERPLANAR && (K == 2 || K == 3))
                    continue;

                gp_Message("Minor %c = %d", K + 'A', ObstructionMinorFreqs[K]);
            }

            if (!(embedFlags & ~EMBEDFLAGS_PLANAR))
            {
                gp_Message("\nNote: E1 are added to C, E2 are added to A, and "
                           "E=E3+E4+K5 homeomorphs.\n");

                for (K = 5; K < NUM_MINORS; K++)
                {
                    gp_Message("Minor E%d = %d",
                               K - 4, ObstructionMinorFreqs[K]);
                }
            }
        }

        // Report statistics for graph drawing
        else if (embedFlags == EMBEDFLAGS_DRAWPLANAR)
        {
            gp_Message("Num Graphs Embedded and Drawn=%d.", MainStatistic);
        }

        // Report statistics for subgraph homeomorphism algorithms
        else if (embedFlags == EMBEDFLAGS_SEARCHFORK23)
        {
            gp_Message("Of the generated graphs, %d did not contain a K_{2,3} "
                       "homeomorph as a subgraph.",
                       MainStatistic);
        }
        else if (embedFlags == EMBEDFLAGS_SEARCHFORK33)
        {
            gp_Message("Of the generated graphs, %d did not contain a K_{3,3} "
                       "homeomorph as a subgraph.",
                       MainStatistic);
        }
        else if (embedFlags == EMBEDFLAGS_SEARCHFORK4)
        {
            gp_Message("Of the generated graphs, %d did not contain a K_4 "
                       "homeomorph as a subgraph.",
                       MainStatistic);
        }
    }

    FlushConsole(stdout);

    g6_FreeWriter((&theG6WriteIterator));

    // Free the graph structures created before the loop
    gp_Free(&theGraph);
    gp_Free(&origGraph);

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

int GetNumberIfZero(int *pNum, char const *prompt, int min, int max)
{
    char lineBuff[MAXLINE + 1];

    memset(lineBuff, '\0', (MAXLINE + 1));

    if (pNum == NULL)
    {
        gp_ErrorMessage("Unable to get number, as pointer to int is NULL.");
        return NOTOK;
    }

    if (prompt == NULL || strlen(prompt) == 0)
    {
        gp_ErrorMessage("Invalid prompt supplied.");
        return NOTOK;
    }

    while (*pNum == 0)
    {
        gp_MessagePrompt("%s", prompt);
        if (GetLineFromStdin(lineBuff, MAXLINE) != OK)
        {
            gp_ErrorMessage("Unable to read integer choice from stdin.");
            return NOTOK;
        }

        if (strlen(lineBuff) == 0 ||
            sscanf(lineBuff, " %d", pNum) != 1)
        {
            gp_ErrorMessage("Invalid integer choice.");
            (*pNum) = 0;
        }
    }

    if (min < 1)
        min = 1;
    if (max < min)
        max = min;

    if (*pNum < min || *pNum > max)
    {
        *pNum = (max + min) / 2;
        gp_Message("Number out of range [%d, %d]; changed to %d.",
                   min, max, *pNum);
    }

    return OK;
}

/****************************************************************************
 MakeGraph()
 Internal function that makes a new graph, initializes it, and attaches an
 algorithm to it based on the command.
 ****************************************************************************/

graphP MakeGraph(int Size, char command)
{
    graphP theGraph = NULL;

    if ((theGraph = gp_New()) == NULL || gp_EnsureVertexCapacity(theGraph, Size) != OK)
    {
        gp_ErrorMessage("Error creating space for a graph of the given size.");
        gp_Free(&theGraph);
        return NULL;
    }

    if (command != '\0')
    {
        if (ExtendGraph(theGraph, command) != OK)
        {
            gp_ErrorMessage("Unable to extend graph based on command '%c'",
                            command);
            gp_Free(&theGraph);
        }
    }

    return theGraph;
}

/****************************************************************************
 ResetGraphStorage()
 Internal function that will either reset the given graph or free it
 and make a new one just like it.
 ****************************************************************************/

void ResetGraphStorage(graphP *pGraph, int ReuseGraphs, char command)
{
    if (ReuseGraphs)
        gp_ResetGraphStorage(*pGraph);
    else
    {
        graphP newGraph = MakeGraph(gp_GetN(*pGraph), command);
        gp_Free(pGraph);
        *pGraph = newGraph;
    }
}

/****************************************************************************
 Creates a random maximal planar graph, then adds 'extraEdges' edges to it.
 ****************************************************************************/

int RandomGraph(char const *const commandString, int extraEdges, int numVertices, char *outfileName, char *outfile2Name)
{
    int Result = OK;

    platform_time start, end;
    graphP theGraph = NULL, origGraph = NULL;
    int embedFlags = 0;
    char command = '\0', modifier = '\0';

    if ((Result = GetCommandAndOptionalModifier(commandString, &command, &modifier)) != OK)
    {
        gp_ErrorMessage("Unable to extract command and optional modifier "
                        "character from commandString.");
        return Result;
    }

    if ((Result = GetEmbedFlags(command, modifier, &embedFlags)) != OK)
    {
        gp_ErrorMessage("Unable to derive embedFlags from command and optional "
                        "modifier character.");
        return Result;
    }

    if ((Result = GetNumberIfZero(&numVertices, "Enter number of vertices:", 1, 10000000) != OK))
    {
        gp_ErrorMessage("Encountered unrecoverable error when prompting for "
                        "numVertices.");
        return Result;
    }

    if ((theGraph = MakeGraph(numVertices, command)) == NULL)
        return NOTOK;

    // Acceptable downcast of time_t to unsigned int (seeding benefits from the lower bits of now)
    srand((unsigned int)time(NULL));

    gp_Message("Creating the random graph...");
    platform_GetTime(start);
    if (gp_CreateRandomGraphEx(theGraph, 3 * numVertices - 6 + extraEdges) != OK)
    {
        gp_ErrorMessage("gp_CreateRandomGraphEx() failed");
        gp_Free(&theGraph);
        return NOTOK;
    }
    platform_GetTime(end);

    gp_Message("Created random graph with %d edges in %.3lf seconds.",
               gp_GetM(theGraph), platform_GetDuration(start, end));

    // The user may have requested a copy of the random graph before processing
    if (outfile2Name != NULL)
    {
        if (gp_Write(theGraph, outfile2Name, WRITE_ADJLIST) != OK)
        {
            gp_ErrorMessage("Unable to write generated random graph before "
                            "embedding.");
            gp_Free(&theGraph);
            return NOTOK;
        }
    }

    if ((origGraph = gp_DupGraph(theGraph)) == NULL)
    {
        gp_ErrorMessage("Unable to create copy of generated random graph before "
                        "embedding.");
        gp_Free(&theGraph);
        return NOTOK;
    }

    // Do the requested algorithm on the randomly generated graph
    gp_Message("Now processing...");
    FlushConsole(stdout);

    platform_GetTime(start);
    Result = gp_Embed(theGraph, embedFlags);
    platform_GetTime(end);

    if (Result != OK && Result != NONEMBEDDABLE)
    {
        gp_ErrorMessage("Failed to embed or find embedding obstruction in "
                        "randomly generated graph.");

        gp_Free(&theGraph);
        gp_Free(&origGraph);

        return NOTOK;
    }

    if (gp_SortVertices(theGraph) != OK)
    {
        gp_ErrorMessage("Unable to sort vertices of graph after processing");

        gp_Free(&theGraph);
        gp_Free(&origGraph);

        return NOTOK;
    }

    if (gp_TestEmbedResultIntegrity(theGraph, origGraph, Result) != Result)
        Result = NOTOK;

    // Write what the algorithm determined and how long it took
    WriteAlgorithmResults(theGraph, Result, command, start, end, NULL);

    // On successful algorithm result, write the output file and see if the
    // user wants the edge list formatted file.
    if (Result == OK || Result == NONEMBEDDABLE)
    {
        // If an outfileName was given on the command-line, then we write only to it.
        if (outfileName != NULL)
        {
            if (gp_Write(theGraph, outfileName, WRITE_ADJLIST) != OK)
            {
                gp_ErrorMessage("Unable to write embedded graph as adjacency "
                                "list.");
                Result = NOTOK;
            }
        }

        // If no outfileName was given and not quiet mode (i.e., if in menu mode),
        // then we ask the user if they want to save in various formats.
        else if (!(gp_GetQuietMode() & QUIETMODE_MESSAGES))
        {
            if (PromptSaveGraph(theGraph, origGraph, extraEdges, 0) != OK)
            {
                gp_ErrorMessage("Error saving graph in edge list format.");
                Result = NOTOK;
            }
            if (PromptSaveGraph(theGraph, origGraph, extraEdges, WRITE_ADJLIST) != OK)
            {
                gp_ErrorMessage("Error saving graph in adjacency list format.");
                Result = NOTOK;
            }
            if (PromptSaveGraph(theGraph, origGraph, extraEdges, WRITE_G6) != OK)
            {
                gp_ErrorMessage("Error saving graph in G6 format.");
                Result = NOTOK;
            }
        }
    }
    else
        gp_ErrorMessage("Failure occurred.");

    gp_Free(&theGraph);
    gp_Free(&origGraph);

    FlushConsole(stdout);

    return Result;
}

int PromptSaveGraph(graphP theGraph, graphP origGraph, int extraEdges, int saveMode)
{
    char saveGraph = '\0';
    char theFileName[MAXLINE + 1];
    char lineBuff[MAXLINE + 1];

    memset(theFileName, '\0', (MAXLINE + 1));
    memset(lineBuff, '\0', (MAXLINE + 1));

    // Select the prompt string
    switch (saveMode)
    {
    case WRITE_ADJLIST:
        gp_MessagePrompt("Do you want to save the generated graph in adjacency "
                         "list format (y/n)?");
        break;
    case WRITE_ADJMATRIX:
        gp_MessagePrompt("Do you want to save the generated graph in adjacency "
                         "matrix format (y/n)?");
        break;
    case WRITE_G6:
        gp_MessagePrompt("Do you want to save the generated graph in G6 format "
                         "(y/n)?");
        break;
    default:
        gp_MessagePrompt("Do you want to save the generated graph in edge list "
                         "format (y/n)?");
        break;
    }
    // Prompt the user
    while (1)
    {
        if (GetLineFromStdin(lineBuff, MAXLINE) != OK)
        {
            gp_ErrorMessage("Unable to read user input.");
            return NOTOK;
        }

        if (strlen(lineBuff) != 1 ||
            sscanf(lineBuff, " %c", &saveGraph) != 1 ||
            !strchr(YESNOCHOICECHARS, saveGraph))
            gp_Message("Invalid choice, please try again (enter y/n).");
        else
        {
            saveGraph = (char)tolower(lineBuff[0]);

            // If no, then bail out, reporting function success
            if (saveGraph == 'n')
                return OK;

            // Otherwise proceed to the file save logic
            break;
        }
    }

    // Construct theFileName for saving
    if (extraEdges > 0)
        strcpy(theFileName, "nonPlanar");
    else
        strcpy(theFileName, "maxPlanar");

    switch (saveMode)
    {
    case WRITE_ADJLIST:
        strcat(theFileName, "AdjList.txt");
        break;
    case WRITE_ADJMATRIX:
        strcat(theFileName, "AdjMatrix.txt");
        break;
    case WRITE_G6:
        strcat(theFileName, ".g6");
        break;
    default:
        strcat(theFileName, "EdgeList.txt");
        break;
    }

    gp_Message("Saving edge list format of original graph to \"%.*s\"",
               FILENAME_MAX, theFileName);
    SaveAsciiGraph(origGraph, theFileName);

    strcat(theFileName, ".out.txt");
    gp_Message("Saving edge list format of result to \"%.*s\"",
               FILENAME_MAX, theFileName);
    SaveAsciiGraph(theGraph, theFileName);

    // Save the original graph
    gp_Message("Saving original graph to \"%.*s\"",
               FILENAME_MAX, theFileName);

    if (saveMode)
    {
        if (gp_Write(origGraph, theFileName, saveMode) != OK)
        {
            gp_ErrorMessage("Failed to save original graph.");
            return NOTOK;
        }

        if (saveMode == WRITE_ADJLIST)
        {
            char zeroBasedFileName[MAXLINE + 1];
            strcpy(zeroBasedFileName, theFileName);
            strcat(zeroBasedFileName, ".0-based.txt");
            origGraph->graphFlags |= GRAPHFLAGS_ZEROBASEDIO;
            gp_Message("Also saving original graph in 0-based adjacency "
                       "list format.");
            gp_Write(origGraph, zeroBasedFileName, saveMode);
            origGraph->graphFlags &= ~GRAPHFLAGS_ZEROBASEDIO;
        }
    }
    else
        SaveAsciiGraph(origGraph, theFileName);

    // Save the result graph
    if (saveMode == WRITE_G6)
        strcat(theFileName, ".out.g6");
    else
        strcat(theFileName, ".out.txt");

    gp_Message("Saving result graph to \"%.*s\"",
               FILENAME_MAX, theFileName);

    if (saveMode)
    {
        if (gp_Write(theGraph, theFileName, saveMode) != OK)
        {
            gp_ErrorMessage("Failed to save result graph.");
            return NOTOK;
        }
    }
    else
        SaveAsciiGraph(theGraph, theFileName);

    return OK;
}
