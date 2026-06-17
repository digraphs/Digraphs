/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "planarity.h"

typedef struct
{
    double duration;
    int numGraphsTested;
    int numOK;
    int numNONEMBEDDABLE;
    int errorFlag;
} testAllStats;

typedef testAllStats *testAllStatsP;

int testAllGraphs(char command, char modifier, char const *const infileName, testAllStatsP stats);
int outputTestAllGraphsResults(char command, char modifier, testAllStatsP stats, char const *const infileName, char *outfileName, char **pOutputStr);

// #define TESTALLGRAPHS_MEMORY_TIMING_TEST

#ifdef TESTALLGRAPHS_MEMORY_TIMING_TEST
int testAllGraphsN8(char command, char modifier, char const *const infileName, testAllStatsP stats);
#endif

/****************************************************************************
 TestAllGraphs()
 commandString - command to run; e.g.`-(pdo234)` (plus optional modifier
    character) to perform the corresponding algorithm on each graph in .g6 file
 infileName - non-NULL and nonempty string containing name of .g6 input file
 outfileName - name of primary output file, or NULL
 pOutputStr - pointer to string which we wish to use to store the result of
    applying the chosen graph algorithm extension to all graphs in the .g6 file
 ****************************************************************************/
int TestAllGraphs(char const *const commandString, char const *const infileName, char *outfileName, char **pOutputStr)
{
    int Result = OK;

    char command = '\0', modifier = '\0';
    platform_time start, end;
    testAllStats stats;

    memset(&stats, 0, sizeof(testAllStats));

    if (GetCommandAndOptionalModifier(commandString, &command, &modifier) != OK)
    {
        gp_ErrorMessage("Unable to determine command (and optional modifier) from "
                        "command string.\n");
        return NOTOK;
    }

    if (infileName == NULL)
    {
        gp_ErrorMessage("No input file provided.");
        return NOTOK;
    }

    gp_Message("Starting to test all graphs in \"%.*s\" for command=\"%s\".",
               FILENAME_MAX, infileName, commandString);

    // Start the timer
    platform_GetTime(start);

#ifndef TESTALLGRAPHS_MEMORY_TIMING_TEST
    Result = testAllGraphs(command, modifier, infileName, &stats);
#else
    Result = testAllGraphsN8(command, modifier, infileName, &stats);
#endif

    // Stop the timer
    platform_GetTime(end);
    stats.duration = platform_GetDuration(start, end);

    if (Result != OK)
    {
        gp_ErrorMessage("Encountered error while running command '%c' on all "
                        "graphs in \"%.*s\".",
                        command, FILENAME_MAX, infileName);
        Result = NOTOK;
    }
    else
    {
        gp_Message("Done testing all graphs (%.3lf seconds).", stats.duration);
    }

    if (outputTestAllGraphsResults(command, modifier, &stats, infileName, outfileName, pOutputStr) != OK)
    {
        gp_ErrorMessage("Error outputting results running command '%c' on all "
                        "graphs in \"%.*s\".\n",
                        command, FILENAME_MAX, infileName);
        Result = NOTOK;
    }

    return Result;
}

int testAllGraphs(char command, char modifier, char const *const infileName, testAllStatsP stats)
{
    int Result = OK;

    graphP origGraphRead = NULL;
    graphP graphForEmbedding = NULL;
    int embedFlags = 0, numOK = 0, numNONEMBEDDABLE = 0;
    int order = 0;
    int lineNum = 0;

    G6ReadIteratorP theG6ReadIterator = NULL;

    if (GetEmbedFlags(command, modifier, &embedFlags) != OK)
    {
        gp_ErrorMessage("Invalid command or modifier.");
        stats->errorFlag = TRUE;
        return NOTOK;
    }

    if ((origGraphRead = gp_New()) == NULL)
    {
        gp_ErrorMessage("Unable to allocate graph for reading.");
        stats->errorFlag = TRUE;
        return NOTOK;
    }

    if (g6_NewReader((&theG6ReadIterator), origGraphRead) != OK ||
        g6_InitReaderWithFileName(theG6ReadIterator, infileName) != OK)
    {
        gp_ErrorMessage("Unable to allocate or initialize G6 read iterator.");
        gp_Free(&origGraphRead);
        g6_FreeReader((&theG6ReadIterator));
        stats->errorFlag = TRUE;
        return NOTOK;
    }

    // The order of the graphs in the G6 source file or string was determined by
    // g6_InitReaderWithFileName() and we obtain it to initialize the graph for
    // embedding
    order = gp_GetN(origGraphRead);

    if ((graphForEmbedding = gp_New()) == NULL ||
        gp_EnsureVertexCapacity(graphForEmbedding, order) != OK)
    {
        gp_ErrorMessage("Unable allocate graph for embedding.");
        g6_FreeReader((&theG6ReadIterator));
        gp_Free(&origGraphRead);
        gp_Free(&graphForEmbedding);
        stats->errorFlag = TRUE;
        return NOTOK;
    }

    if (ExtendGraph(graphForEmbedding, command) != OK)
    {
        gp_ErrorMessage("Unable to extend graph for embedding operation.");
        g6_FreeReader(&theG6ReadIterator);
        gp_Free(&origGraphRead);
        gp_Free(&graphForEmbedding);
        stats->errorFlag = TRUE;
        return NOTOK;
    }

    while (TRUE)
    {
        lineNum++;
        if (g6_ReadGraph(theG6ReadIterator) != OK)
        {
            gp_ErrorMessage("Unable to read graph on line %d.",
                            lineNum);
            Result = NOTOK;
            break;
        }

        if (g6_EndReached(theG6ReadIterator))
            break;

        if (gp_CopyGraph(graphForEmbedding, origGraphRead) != OK)
        {
            gp_ErrorMessage("Unable to copy graph.");
            Result = NOTOK;
            break;
        }

        Result = gp_Embed(graphForEmbedding, embedFlags);
        if (Result != OK && Result != NONEMBEDDABLE)
        {
            gp_ErrorMessage("Failed to embed graph on line %d for command '%c'.",
                            lineNum, command);
            Result = NOTOK;
        }

        if (gp_TestEmbedResultIntegrity(graphForEmbedding, origGraphRead, Result) != Result)
        {
            gp_ErrorMessage("Embed integrity check failed for graph on line %d "
                            "for command '%c'.\n",
                            lineNum, command);
            Result = NOTOK;
        }

        if (Result == OK)
            numOK++;
        else if (Result == NONEMBEDDABLE)
        {
            numNONEMBEDDABLE++;
            // Now that we've processed the NONEMBEDDABLE result, we set the
            // Result to OK so that we exit the loop with an OK or NOTOK only
            Result = OK;
        }
        else
        {
            if (modifier == '\0')
            {
                gp_ErrorMessage("Command '%c' error on graph on line %d.",
                                command, lineNum);
            }
            else
            {
                gp_ErrorMessage("Command '%c%c' error on graph on line %d.",
                                command, modifier, lineNum);
            }
            Result = NOTOK;
            break;
        }
    }

    // Since we increment lineNum at the beginning of the loop, if an error
    // occurs during processing a graph on the current lineNum, or if we reach
    // the end of the input, then the number of graphs successfully tested is
    // lineNum - 1.
    stats->numGraphsTested = lineNum - 1;
    stats->numOK = numOK;
    stats->numNONEMBEDDABLE = numNONEMBEDDABLE;
    stats->errorFlag = (Result == OK) ? FALSE : TRUE;

    g6_FreeReader((&theG6ReadIterator));
    gp_Free(&origGraphRead);
    gp_Free(&graphForEmbedding);

    return Result;
}

int outputTestAllGraphsResults(char command, char modifier, testAllStatsP stats, char const *const infileName, char *outfileName, char **pOutputStr)
{
    int Result = OK;

    char *finalSlash = strrchr(infileName, FILE_DELIMITER);
    char const *infileBasename = finalSlash ? (finalSlash + 1) : infileName;

    char const *headerFormat = "FILENAME=\"%s\" DURATION=\"%.3lf\"\n";
    int numCharsToReprNumGraphsTested = 0, numCharsToReprNumOK = 0, numCharsToReprNumNONEMBEDDABLE = 0;

    char *theOutputStr = NULL;
    int headerStrLen = 0, resultStrLen = 0;
    char *resultsStr = NULL;

    if (outfileName == NULL && (pOutputStr == NULL || *pOutputStr != NULL))
    {
        gp_ErrorMessage("Invalid parameters: Must be able to output to file or "
                        "memory.");
        return NOTOK;
    }

    headerStrLen =
        strlen(headerFormat) +
        strlen(infileBasename) +
        strlen("-1.7976931348623158e+308") + // -DBL_MAX from float.h
        3;

    if (GetNumCharsToReprInt(stats->numGraphsTested, &numCharsToReprNumGraphsTested) != OK ||
        GetNumCharsToReprInt(stats->numOK, &numCharsToReprNumOK) != OK ||
        GetNumCharsToReprInt(stats->numNONEMBEDDABLE, &numCharsToReprNumNONEMBEDDABLE) != OK)
    {
        gp_ErrorMessage("Unable to determine the number of characters required "
                        "to represent testAllGraphs stat values.");
        return NOTOK;
    }

    resultStrLen =
        1 + // - char
        1 + // command char
        1 + // optional modifier char
        1 + // space char
        numCharsToReprNumGraphsTested +
        1 + // space char
        numCharsToReprNumOK +
        1 + // space char
        numCharsToReprNumNONEMBEDDABLE +
        1 + // space char
        7 + // either ERROR or SUCCESS, so the longer of which is 7 chars
        3   // (carriage return,) newline and null terminator;
        ;

    theOutputStr = (char *)malloc((headerStrLen + resultStrLen + 1) * sizeof(char));
    if (theOutputStr == NULL)
    {
        gp_ErrorMessage("Unable allocate memory for the output.");
        return NOTOK;
    }

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wformat-nonliteral"
    sprintf(theOutputStr, headerFormat, infileBasename, stats->duration);
#pragma GCC diagnostic pop

    resultsStr = theOutputStr + strlen(theOutputStr);

    if (modifier == '\0')
        sprintf(resultsStr, "-%c %d %d %d %s\n",
                command, stats->numGraphsTested, stats->numOK, stats->numNONEMBEDDABLE, stats->errorFlag ? "ERROR" : "SUCCESS");
    else
        sprintf(resultsStr, "-%c%c %d %d %d %s\n",
                command, modifier, stats->numGraphsTested, stats->numOK, stats->numNONEMBEDDABLE, stats->errorFlag ? "ERROR" : "SUCCESS");

    if (outfileName != NULL)
    {
        FILE *outfile = strcmp(outfileName, "stdout") == 0 ? stdout : fopen(outfileName, WRITETEXT);
        if (outfile != NULL)
        {
            fprintf(outfile, "%s", theOutputStr);
            if (strcmp(outfileName, "stdout") != 0)
                fclose(outfile);
            outfile = NULL;
            Result = OK;
        }
        else
            Result = NOTOK;

        free(theOutputStr);
        theOutputStr = NULL;
    }
    else
    {
        *pOutputStr = theOutputStr;
        theOutputStr = NULL;
        Result = OK;
    }

    return Result;
}

#ifdef TESTALLGRAPHS_MEMORY_TIMING_TEST

/*******************************************************************************
 * An alternative version of testAllGraphs() that can be used for timing tests
 *******************************************************************************/

#define NUM8VERTEXTGRAPHS 12346

int testAllGraphsN8(char command, char modifier, char const *const infileName, testAllStatsP stats)
{
    int Result = OK;

    graphP origGraphRead[NUM8VERTEXTGRAPHS + 1];
    graphP graphForEmbedding = NULL;
    int embedFlags = 0, numOK = 0, numNONEMBEDDABLE = 0;
    int order = 0;
    int lineNum = 0;
    platform_time start, end;

    G6ReadIteratorP theG6ReadIterator = NULL;

    if (infileName == NULL || !strstr(infileName, "n8.mALL.g6"))
    {
        gp_ErrorMessage("testAllGraphsN8() is coded just for processing all 8-vertex graphs");
        return NOTOK;
    }

    if (GetEmbedFlags(command, modifier, &embedFlags) != OK)
    {
        gp_ErrorMessage("Invalid command or modifier.\n");
        stats->errorFlag = TRUE;
        return NOTOK;
    }

    // Initialize all pointer and allocate a graph structure that is
    // needed to read all graphs from the file into memory
    for (lineNum = 0; lineNum <= NUM8VERTEXTGRAPHS; lineNum++)
        origGraphRead[lineNum] = NULL;

    if ((origGraphRead[0] = gp_New()) == NULL)
    {
        gp_ErrorMessage("Unable to allocate graph for reading.\n");
        stats->errorFlag = TRUE;
        return NOTOK;
    }

    // The 0th origGraph will be used by the read iterator, and then the
    // graphs will be copied into locations 1 through NUM8VERTEXTGRAPHS
    if (g6_NewReader((&theG6ReadIterator), origGraphRead[0]) != OK ||
        g6_InitReaderWithFileName(theG6ReadIterator, infileName) != OK)
    {
        gp_ErrorMessage("Unable to allocate or initialize G6 read iterator.\n");
        gp_Free(&origGraphRead[0]);
        g6_FreeReader((&theG6ReadIterator));
        stats->errorFlag = TRUE;
        return NOTOK;
    }

    // The order of the graphs in the G6 source file or string was determined by
    // g6_InitReaderWithFileName(), and we obtain it to ensure vertex capacity in
    // the graphs that will receive copies origGraphRead[0] from each line of the
    // g6 file and also to help initialize the graph for embedding
    order = gp_GetN(origGraphRead[0]);

    for (lineNum = 1; lineNum <= NUM8VERTEXTGRAPHS; lineNum++)
    {
        if ((origGraphRead[lineNum] = gp_New()) == NULL ||
            gp_EnsureVertexCapacity(origGraphRead[lineNum], order) != OK)
        {
            gp_ErrorMessage("Unable allocate graphs for reading.\n");
            g6_FreeReader((&theG6ReadIterator));
            for (lineNum = 0; lineNum <= NUM8VERTEXTGRAPHS; lineNum++)
                gp_Free(&origGraphRead[lineNum]);
            stats->errorFlag = TRUE;
            return NOTOK;
        }
    }

    if ((graphForEmbedding = gp_New()) == NULL ||
        gp_EnsureVertexCapacity(graphForEmbedding, order) != OK ||
        ExtendGraph(graphForEmbedding, command) != OK)
    {
        gp_ErrorMessage("Unable allocate graph for embedding.\n");
        g6_FreeReader((&theG6ReadIterator));
        for (lineNum = 0; lineNum <= NUM8VERTEXTGRAPHS; lineNum++)
            gp_Free(&origGraphRead[lineNum]);
        gp_Free(&graphForEmbedding);
        stats->errorFlag = TRUE;
        return NOTOK;
    }

    // Read the graphs into memory
    lineNum = 0;
    while (lineNum <= NUM8VERTEXTGRAPHS)
    {
        lineNum++;
        if (g6_ReadGraph(theG6ReadIterator) != OK)
        {
            gp_ErrorMessage("Unable to read graph on line %d.\n", lineNum);
            Result = NOTOK;
            break;
        }

        if (g6_EndReached(theG6ReadIterator))
            break;

        if (gp_CopyGraph(origGraphRead[lineNum], origGraphRead[0]) != OK)
        {
            gp_ErrorMessage("Unable to copy graph.\n");
            Result = NOTOK;
            break;
        }
    }

    g6_FreeReader((&theG6ReadIterator));

    if (Result != OK)
    {
        for (lineNum = 0; lineNum <= NUM8VERTEXTGRAPHS; lineNum++)
            gp_Free(&origGraphRead[lineNum]);
        gp_Free(&graphForEmbedding);
        return NOTOK;
    }

    // Since we increment lineNum at the beginning of the loop, if an error
    // occurs during processing a graph on the current lineNum, or if we reach
    // the end of the input, then the number of graphs successfully read is
    // lineNum - 1.
    stats->numGraphsTested = lineNum - 1;

    // Start a timer, and we will iterate the work many times to
    // get a more reliable reading.

    platform_GetTime(start);

    for (int i = 0; i < 1000; ++i)
    {
        numOK = numNONEMBEDDABLE = 0;
        for (lineNum = 1; lineNum <= NUM8VERTEXTGRAPHS; lineNum++)
        {
            if (gp_CopyGraph(graphForEmbedding, origGraphRead[lineNum]) != OK)
            {
                gp_ErrorMessage("Unable to copy graph.\n");
                Result = NOTOK;
                break;
            }

            Result = gp_Embed(graphForEmbedding, embedFlags);
            if (Result != OK && Result != NONEMBEDDABLE)
            {
                gp_ErrorMessage("Failed to embed graph on line %d", lineNum);
                Result = NOTOK;
                break;
            }

            if (gp_TestEmbedResultIntegrity(graphForEmbedding, origGraphRead[lineNum], Result) != Result)
            {
                gp_ErrorMessage("Embed integrity check failed for graph on line %d", lineNum);
                Result = NOTOK;
                break;
            }

            if (Result == OK)
                numOK++;
            else if (Result == NONEMBEDDABLE)
            {
                numNONEMBEDDABLE++;
                Result = OK;
            }
        }

        if (Result != OK)
            break;
    }

    platform_GetTime(end);
    gp_Message("In-memory graph processing test executed in %.3lf seconds.\n",
               platform_GetDuration(start, end));

    stats->numOK = numOK;
    stats->numNONEMBEDDABLE = numNONEMBEDDABLE;
    stats->errorFlag = (Result == OK) ? FALSE : TRUE;

    for (lineNum = 0; lineNum <= NUM8VERTEXTGRAPHS; lineNum++)
        gp_Free(&origGraphRead[lineNum]);
    gp_Free(&graphForEmbedding);

    return Result == OK ? OK : NOTOK;
}

#endif
