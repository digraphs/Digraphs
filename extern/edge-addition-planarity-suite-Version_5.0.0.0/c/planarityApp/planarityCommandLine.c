/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "planarity.h"

#if defined(_MSC_VER) && !defined(__llvm__) && !defined(__INTEL_COMPILER)
// MSVC under Windows doesn't have unistd.h, but does define functions like getcwd and chdir
#include <direct.h>
#define getcwd _getcwd
#define chdir _chdir
#else
#include <unistd.h>
#endif

int runQuickRegressionTests(int argc, char *argv[]);
int callRandomGraphs(int argc, char *argv[]);
int callSpecificGraph(int argc, char *argv[]);
int callRandomMaxPlanarGraph(int argc, char *argv[]);
int callRandomNonplanarGraph(int argc, char *argv[]);
int callTestAllGraphs(int argc, char *argv[]);
int callTransformGraph(int argc, char *argv[]);

int runSpecificGraphTests(void);
int runGraphTransformationTests(void);
int runTestAllGraphsTests(void);
int runSpecificGraphTest(char const *command, char const *infileName, int inputInMemFlag);
int runGraphTransformationTest(char const *command, char const *infileName, int inputInMemFlag);
int runTestAllGraphsTest(char const *commandString, char const *infileName);

/****************************************************************************
 Command Line Processor
 ****************************************************************************/

int commandLine(int argc, char *argv[])
{
    int Result = OK;

#ifdef DEBUG
    char lineBuff[MAXLINE + 1];
#endif

    if (argc >= 3 && strcmp(argv[2], "-q") == 0)
        gp_SetQuietMode(QUIETMODE_ALL);

    if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "-help") == 0)
    {
        Result = helpMessage(argc >= 3 ? argv[2] : NULL);
    }

    else if (strcmp(argv[1], "-i") == 0 || strcmp(argv[1], "-info") == 0)
    {
        Result = helpMessage(argv[1]);
    }

    else if (strcmp(argv[1], "-test") == 0)
        Result = runQuickRegressionTests(argc, argv);

    else if (strcmp(argv[1], "-r") == 0)
        Result = callRandomGraphs(argc, argv);

    else if (strcmp(argv[1], "-s") == 0)
        Result = callSpecificGraph(argc, argv);

    else if (strcmp(argv[1], "-rm") == 0)
        Result = callRandomMaxPlanarGraph(argc, argv);

    else if (strcmp(argv[1], "-rn") == 0)
        Result = callRandomNonplanarGraph(argc, argv);

    else if (strncmp(argv[1], "-x", 2) == 0)
        Result = callTransformGraph(argc, argv);

    else if (strncmp(argv[1], "-t", 2) == 0)
        Result = callTestAllGraphs(argc, argv);

    else
    {
        gp_ErrorMessage("Unsupported command line.  Here is the help for this "
                        "program.");
        helpMessage(NULL);
        Result = NOTOK;
    }

#ifdef DEBUG
    // When one builds and runs the executable in an external console from an IDE
    // such as VSCode, the external console window will close immediately upon
    // exit 0 being returned. This means that one may miss gp_Message() and
    // gp_ErrorMessage() outputs that are crucial to the debugging process.
    // Hence, if we compile with the DDEBUG flag, this means that in appconst.h
    // we #define DEBUG. That way, this prompt will appear only for debug builds,
    // and will ensure the console window stays open until the user proceeds.
    printf("\n\tPress return key to exit...\n");
    fflush(stdout);
    if (GetLineFromStdin(lineBuff, MAXLINE) != OK)
    {
        gp_ErrorMessage("Unable to fetch from stdin; exiting.");
        Result = NOTOK;
    }
#endif

    // NOTE: Translates internal planarity codes to appropriate exit codes
    return Result == OK ? 0 : (Result == NONEMBEDDABLE ? 1 : -1);
}

/****************************************************************************
 Legacy Command Line Processor from version 1.x
 ****************************************************************************/

int legacyCommandLine(int argc, char *argv[])
{
    int Result = OK;

    graphP theGraph = gp_New();

    if (theGraph == NULL)
    {
        gp_ErrorMessage("Unable to allocate memory for theGraph.");
        Result = NOTOK;
    }

    if (Result == OK)
    {
        Result = gp_Read(theGraph, argv[1]);
        if (Result != OK)
        {
            gp_ErrorMessage("Failed to read graph \"%.*s\"",
                            FILENAME_MAX, argv[1]);
            Result = NOTOK;
        }
    }

    if (Result == OK)
    {
        Result = gp_Embed(theGraph, EMBEDFLAGS_PLANAR);
        if (Result == OK)
        {
            if ((Result = gp_SortVertices(theGraph)) != OK)
                gp_ErrorMessage("Failed to restore original vertex labelling.");

            if (Result == OK && (Result = gp_Write(theGraph, argv[2], WRITE_ADJLIST)) != OK)
                gp_ErrorMessage("Failed to write embedding.");
        }

        else if (Result == NONEMBEDDABLE)
        {
            if (argc >= 5 && strcmp(argv[3], "-n") == 0)
            {
                if ((Result = gp_SortVertices(theGraph)) != OK)
                    gp_ErrorMessage("Failed to restore original vertex "
                                    "labelling.");

                if (Result == OK && (Result = gp_Write(theGraph, argv[4], WRITE_ADJLIST)) != OK)
                    gp_ErrorMessage("Failed to write obstruction.");
            }
        }
        else
            Result = NOTOK;
    }

    gp_Free(&theGraph);

    // In the legacy 1.x versions, OK/NONEMBEDDABLE was 0 and NOTOK was -2
    return Result == OK || Result == NONEMBEDDABLE ? 0 : -2;
}

/****************************************************************************
 Quick regression test
 ****************************************************************************/

int runQuickRegressionTests(int argc, char *argv[])
{
    char const *samplesDir = "samples";
    int samplesDirArgLocation = 2;
    int retVal = OK;
    char origDir[2 * MAXLINE + 1];

    // Skip optional -q quiet mode command-line parameter, if present
    if (argc > samplesDirArgLocation && strcmp(argv[samplesDirArgLocation], "-q") == 0)
        samplesDirArgLocation++;

    // Accept overriding sample directory command-line parameter, if present
    if (argc > samplesDirArgLocation)
        samplesDir = argv[samplesDirArgLocation];

    memset(origDir, '\0', (2 * MAXLINE + 1));

    if (!getcwd(origDir, 2 * MAXLINE))
        return NOTOK;

    // Preserve original behavior before the samplesDir command-line parameter was available
    if (strcmp(samplesDir, "samples") == 0)
    {
        if (chdir(samplesDir) != 0)
        {
            if (chdir("..") != 0 || chdir(samplesDir) != 0)
            {
                // Give success result, but Warn if no samples (except no warning if in quiet mode)
                gp_Message("WARNING: Unable to change to samples directory to "
                           "run tests on samples.");
                chdir(origDir);

                return OK;
            }
        }
    }
    else
    {
        // New behavior if samplesDir command-line parameter was specified
        if (chdir(samplesDir) != 0)
        {
            gp_Message("WARNING: Unable to change to samples directory to run "
                       "tests on samples.");

            return OK;
        }
    }

    if (runSpecificGraphTests() != OK)
        retVal = NOTOK;
    else if (runGraphTransformationTests() != OK)
        retVal = NOTOK;
    else if (runTestAllGraphsTests() != OK)
        retVal = NOTOK;

    // All done.
    if (retVal == OK)
        gp_Message("============\n\nAll tests have succeeded.");
    else
        gp_Message("============\n\nOne or more tests FAILED.");

    chdir(origDir);
    FlushConsole(stdout);

    return retVal;
}

int runSpecificGraphTests(void)
{
    int retVal = OK;

#ifdef USE_1BASEDARRAYS
    gp_Message("\n\tStarting 1-based Array Index Tests\n");

    if (runSpecificGraphTest("-p", "maxPlanar5.txt", TRUE) != OK)
    {
        gp_ErrorMessage("Planarity test on maxPlanar5.txt failed.");
        retVal = NOTOK;
    }

    if (runSpecificGraphTest("-d", "maxPlanar5.txt", FALSE) != OK)
    {
        gp_ErrorMessage("Graph drawing test maxPlanar5.txt failed.");
        retVal = NOTOK;
    }

    if (runSpecificGraphTest("-d", "drawExample.txt", TRUE) != OK)
    {
        gp_ErrorMessage("Graph drawing on drawExample.txt failed.");
        retVal = NOTOK;
    }

    if (runSpecificGraphTest("-p", "Petersen.txt", FALSE) != OK)
    {
        gp_ErrorMessage("Planarity test on Petersen.txt failed.");
        retVal = NOTOK;
    }

    if (runSpecificGraphTest("-o", "Petersen.txt", TRUE) != OK)
    {
        gp_ErrorMessage("Outerplanarity test on Petersen.txt failed.");
        retVal = NOTOK;
    }

    if (runSpecificGraphTest("-2", "Petersen.txt", FALSE) != OK)
    {
        gp_ErrorMessage("K_{2,3} search on Petersen.txt failed.");
        retVal = NOTOK;
    }

    if (runSpecificGraphTest("-3", "Petersen.txt", TRUE) != OK)
    {
        gp_ErrorMessage("K_{3,3} search on Petersen.txt failed.");
        retVal = NOTOK;
    }

    if (runSpecificGraphTest("-4", "Petersen.txt", FALSE) != OK)
    {
        gp_ErrorMessage("K_4 search on Petersen.txt failed.");
        retVal = NOTOK;
    }

    gp_Message("\tFinished 1-based Array Index Tests.\n");
#endif

    if (runSpecificGraphTest("-p", "maxPlanar5.0-based.txt", FALSE) != OK)
    {
        gp_ErrorMessage("Planarity test on maxPlanar5.0-based.txt failed.");
        retVal = NOTOK;
    }

    if (runSpecificGraphTest("-d", "maxPlanar5.0-based.txt", TRUE) != OK)
    {
        gp_ErrorMessage("Graph drawing test maxPlanar5.0-based.txt failed.");
        retVal = NOTOK;
    }

    if (runSpecificGraphTest("-d", "drawExample.0-based.txt", FALSE) != OK)
    {
        gp_ErrorMessage("Graph drawing on drawExample.0-based.txt failed.");
        retVal = NOTOK;
    }

    if (runSpecificGraphTest("-p", "Petersen.0-based.txt", TRUE) != OK)
    {
        gp_ErrorMessage("Planarity test on Petersen.0-based.txt failed.");
        retVal = NOTOK;
    }

    if (runSpecificGraphTest("-o", "Petersen.0-based.txt", FALSE) != OK)
    {
        gp_ErrorMessage("Outerplanarity test on Petersen.0-based.txt failed.");
        retVal = NOTOK;
    }

    if (runSpecificGraphTest("-2", "Petersen.0-based.txt", TRUE) != OK)
    {
        gp_ErrorMessage("K_{2,3} search on Petersen.0-based.txt failed.");
        retVal = NOTOK;
    }

    if (runSpecificGraphTest("-3", "Petersen.0-based.txt", FALSE) != OK)
    {
        gp_ErrorMessage("K_{3,3} search on Petersen.0-based.txt failed.");
        retVal = NOTOK;
    }

    if (runSpecificGraphTest("-4", "Petersen.0-based.txt", TRUE) != OK)
    {
        gp_ErrorMessage("K_4 search on Petersen.0-based.txt failed.");
        retVal = NOTOK;
    }

    return retVal;
}

int runGraphTransformationTests(void)
{
    int retVal = OK;

    /*
        GRAPH TRANSFORMATION TESTS
    */
    //  TRANSFORM TO ADJACENCY LIST

    // runGraphTransformationTest by reading file contents into string
    if (runGraphTransformationTest("-a", "nauty_example.g6", TRUE) != OK)
    {
        gp_ErrorMessage("Transforming nauty_example.g6 file contents as string "
                        "to adjacency list failed.");
        retVal = NOTOK;
    }

    // runGraphTransformationTest by reading from file
    if (runGraphTransformationTest("-a", "nauty_example.g6", FALSE) != OK)
    {
        gp_ErrorMessage("Transforming nauty_example.g6 using file pointer to "
                        "adjacency list failed.");
        retVal = NOTOK;
    }

    // runGraphTransformationTest by reading first graph from file into string
    if (runGraphTransformationTest("-a", "N5-all.g6", TRUE) != OK)
    {
        gp_ErrorMessage("Transforming first graph in N5-all.g6 (read as "
                        "string) to adjacency list failed.");
        retVal = NOTOK;
    }

    // runGraphTransformationTest by reading first graph from file pointer
    if (runGraphTransformationTest("-a", "N5-all.g6", FALSE) != OK)
    {
        gp_ErrorMessage("Transforming first graph in N5-all.g6 (read from file "
                        "pointer) to adjacency list failed.");
        retVal = NOTOK;
    }

    // runGraphTransformationTest by reading file contents corresponding to dense graph into string
    if (runGraphTransformationTest("-a", "K10.g6", TRUE) != OK)
    {
        gp_ErrorMessage("Transforming K10.g6 file contents as string to "
                        "adjacency list failed.");
        retVal = NOTOK;
    }

    // runGraphTransformationTest by reading dense graph from file
    if (runGraphTransformationTest("-a", "K10.g6", FALSE) != OK)
    {
        gp_ErrorMessage("Transforming K10.g6 using file pointer to adjacency "
                        "list failed.");
        retVal = NOTOK;
    }

    //  TRANSFORM TO ADJACENCY MATRIX

    // runGraphTransformationTest by reading file contents into string
    if (runGraphTransformationTest("-m", "nauty_example.g6", TRUE) != OK)
    {
        gp_ErrorMessage("Transforming nauty_example.g6 file contents as string "
                        "to adjacency matrix failed.");
        retVal = NOTOK;
    }

    // runGraphTransformationTest by reading from file
    if (runGraphTransformationTest("-m", "nauty_example.g6", FALSE) != OK)
    {
        gp_ErrorMessage("Transforming nauty_example.g6 using file pointer to "
                        "adjacency matrix failed.");
        retVal = NOTOK;
    }

    // runGraphTransformationTest by reading first graph from file into string
    if (runGraphTransformationTest("-m", "N5-all.g6", TRUE) != OK)
    {
        gp_ErrorMessage("Transforming first graph in N5-all.g6 (read as "
                        "string) to adjacency matrix failed.");
        retVal = NOTOK;
    }

    // runGraphTransformationTest by reading first graph from file pointer
    if (runGraphTransformationTest("-m", "N5-all.g6", FALSE) != OK)
    {
        gp_ErrorMessage("Transforming first graph in N5-all.g6 (read from file "
                        "pointer) to adjacency matrix failed.");

        retVal = NOTOK;
    }

    // runGraphTransformationTest by reading file contents corresponding to dense graph into string
    if (runGraphTransformationTest("-m", "K10.g6", TRUE) != OK)
    {
        gp_ErrorMessage("Transforming K10.g6 file contents as string to "
                        "adjacency matrix failed.");
        retVal = NOTOK;
    }

    // runGraphTransformationTest by reading dense graph from file
    if (runGraphTransformationTest("-m", "K10.g6", FALSE) != OK)
    {
        gp_ErrorMessage("Transforming K10.g6 using file pointer to adjacency "
                        "matrix failed.");
        retVal = NOTOK;
    }

    //  TRANSFORM TO .G6

    // runGraphTransformationTest by reading from file
    if (runGraphTransformationTest("-g", "nauty_example.g6.0-based.AdjList.out.txt", TRUE) != OK)
    {
        gp_ErrorMessage("Transforming nauty_example.g6.0-based.AdjList.out.txt "
                        "using file pointer to .g6 failed.");
        retVal = NOTOK;
    }

    // runGraphTransformationTest by reading from file
    if (runGraphTransformationTest("-g", "K10.g6.0-based.AdjList.out.txt", TRUE) != OK)
    {
        gp_ErrorMessage("Transforming K10.g6.0-based.AdjList.out.txt using "
                        "file pointer to .g6 failed.");
        retVal = NOTOK;
    }

    return retVal;
}

int runTestAllGraphsTests(void)
{
    int retVal = OK;

    // Run TestAllGraphs Tests
    if (runTestAllGraphsTest("-p", "n8.mALL.g6") != OK)
    {
        gp_ErrorMessage("Planarity test on all graphs failed.");
        retVal = NOTOK;
    }
    if (runTestAllGraphsTest("-d", "n8.mALL.g6") != OK)
    {
        gp_ErrorMessage("Planar graph drawing test on all graphs failed.");
        retVal = NOTOK;
    }
    if (runTestAllGraphsTest("-o", "n8.mALL.g6") != OK)
    {
        gp_ErrorMessage("Outerplanarity test on all graphs failed.");
        retVal = NOTOK;
    }
    if (runTestAllGraphsTest("-2", "n8.mALL.g6") != OK)
    {
        gp_ErrorMessage("K2,3 homeomorph search test on all graphs failed.");
        retVal = NOTOK;
    }
    if (runTestAllGraphsTest("-3", "n8.mALL.g6") != OK)
    {
        gp_ErrorMessage("K3,3 homeomorph search test on all graphs failed.");
        retVal = NOTOK;
    }
    if (runTestAllGraphsTest("-4", "n8.mALL.g6") != OK)
    {
        gp_ErrorMessage("K4 homeomorph search test on all graphs failed.");
        retVal = NOTOK;
    }

    return retVal;
}

int runTestAllGraphsTest(char const *commandString, char const *infileName)
{
    char *outputStr = NULL;
    int Result = OK;
    char command = '\0', modifier = '\0';

    if (GetCommandAndOptionalModifier(commandString, &command, &modifier) != OK)
    {
        gp_ErrorMessage("Unable to extract command (or optional modifier) from "
                        "command string.");
        return NOTOK;
    }

    Result = TestAllGraphs(commandString, infileName, NULL, &outputStr);

    if (Result == OK)
    {
        const char *planarityValidationStr = "-p 12346 6966 5380 SUCCESS";
        const char *drawPlanarValidationStr = "-d 12346 6966 5380 SUCCESS";
        const char *outerplanarityValidationStr = "-o 12346 1150 11196 SUCCESS";
        const char *K23SearchValidationStr = "-2 12346 1251 11095 SUCCESS";
        const char *K33SearchValidationStr = "-3 12346 7200 5146 SUCCESS";
        const char *K4SearchValidationStr = "-4 12346 1715 10631 SUCCESS";
        const char *theValidationStr = NULL;

        switch (command)
        {
        case 'p':
            theValidationStr = planarityValidationStr;
            break;
        case 'd':
            theValidationStr = drawPlanarValidationStr;
            break;
        case 'o':
            theValidationStr = outerplanarityValidationStr;
            break;
        case '2':
            theValidationStr = K23SearchValidationStr;
            break;
        case '3':
            theValidationStr = K33SearchValidationStr;
            break;
        case '4':
            theValidationStr = K4SearchValidationStr;
            break;
        default:
            Result = NOTOK;
            break;
        }

        if (theValidationStr != NULL)
            Result = strstr(outputStr, theValidationStr) ? OK : NOTOK;
    }

    gp_Message(" ");

    if (outputStr != NULL)
    {
        free(outputStr);
        outputStr = NULL;
    }

    return Result == OK ? OK : NOTOK;
}

int runSpecificGraphTest(char const *commandString, char const *infileName, int inputInMemFlag)
{
    int Result = OK;

    char *inputString = NULL, *actualOutput = NULL, *actualOutput2 = NULL;
    char const *expectedPrimaryResultFileName = "";

    char command = '\0', modifier = '\0';

    if (GetCommandAndOptionalModifier(commandString, &command, &modifier) != OK)
    {
        gp_ErrorMessage("Unable to extract command (or optional modifier) from "
                        "command string.");
        return NOTOK;
    }

    // The algorithm, indicated by algorithmCode, operating on 'infileName' is expected to produce
    // an output that is stored in the file named 'expectedResultFileName' (return string not owned)
    expectedPrimaryResultFileName = ConstructPrimaryOutputFileName(infileName, NULL, command);

    // SpecificGraph() can invoke gp_Read() if the graph is to be read from a file, or it can invoke
    // gp_ReadFromString() if the inputInMemFlag is set.
    if (inputInMemFlag)
    {
        inputString = ReadTextFileIntoString(infileName);
        if (inputString == NULL)
        {
            gp_ErrorMessage("Failed to read input file into string.");
            Result = NOTOK;
        }
    }

    if (Result == OK)
    {
        // Perform the indicated algorithm on the graph in the input file or string.
        Result = SpecificGraph(commandString,
                               infileName, NULL, NULL,
                               inputString, &actualOutput, &actualOutput2);
    }

    if (Result != OK && Result != NONEMBEDDABLE)
    {
        gp_ErrorMessage("Test failed (graph processor returned failure "
                        "result).");
        Result = NOTOK;
    }
    else
    {
        // Test that the primary actual output matches the primary expected output
        if (TextFileMatchesString(expectedPrimaryResultFileName, actualOutput) == TRUE)
            gp_Message("Test succeeded (result equal to exemplar).");
        else
        {
            gp_ErrorMessage("Test failed (result not equal to exemplar).");
            Result = NOTOK;
        }
    }

    // Test that the secondary actual output matches the secondary expected output
    if (command == 'd' && (Result == OK || Result == NONEMBEDDABLE))
    {
        char *expectedSecondaryResultFileName = (char *)malloc(strlen(expectedPrimaryResultFileName) + strlen(".render.txt") + 1);

        if (expectedSecondaryResultFileName == NULL)
        {
            gp_ErrorMessage("Unable to allocate memory for expected secondary "
                            "output file name.");
            Result = NOTOK;
        }
        else
        {
            sprintf(expectedSecondaryResultFileName, "%s%s", expectedPrimaryResultFileName, ".render.txt");

            if (TextFileMatchesString(expectedSecondaryResultFileName, actualOutput2) == TRUE)
                gp_Message("Test succeeded (secondary result equal to "
                           "exemplar).");
            else
            {
                gp_ErrorMessage("Test failed (secondary result not equal to "
                                "exemplar).");
                Result = NOTOK;
            }

            if (expectedSecondaryResultFileName != NULL)
            {
                free(expectedSecondaryResultFileName);
                expectedSecondaryResultFileName = NULL;
            }
        }
    }

    gp_Message(" ");

    if (inputString != NULL)
    {
        free(inputString);
        inputString = NULL;
    }

    if (actualOutput != NULL)
    {
        free(actualOutput);
        actualOutput = NULL;
    }

    if (actualOutput2 != NULL)
    {
        free(actualOutput2);
        actualOutput2 = NULL;
    }

    // NOTE: Test run successfully if OK or NONEMBEDDABLE result; Result is only
    // NOTOK when an error occurs during one of the subordinate function calls,
    // or if the output does not match what is expected.
    return (Result == OK || Result == NONEMBEDDABLE) ? OK : Result;
}

int runGraphTransformationTest(char const *command, char const *infileName, int inputInMemFlag)
{
    int Result = OK;

    char *inputString = NULL;
    char transformationCode = '\0';

    // runGraphTransformationTest will not test performing an algorithm on a given
    // input graph; it will only support "-(gam)"
    if (command == NULL || strlen(command) < 2)
    {
        gp_ErrorMessage("runGraphTransformationTest only supports -(gam).");
        return NOTOK;
    }
    else if (strlen(command) == 2)
        transformationCode = command[1];

    // SpecificGraph() can invoke gp_Read() if the graph is to be read from a file, or it can invoke
    // gp_ReadFromString() if the inputInMemFlag is set.
    if (inputInMemFlag)
    {
        inputString = ReadTextFileIntoString(infileName);
        if (inputString == NULL)
        {
            gp_ErrorMessage("Failed to read input file into string.");
            Result = NOTOK;
        }
    }

    if (Result == OK)
    {
        // We need to capture whether output is 0- or 1-based to construct the name of the file to compare actualOutput with
        int zeroBasedOutputFlag = 0;
        char *actualOutput = NULL;
        // We want to handle the test being run when we read from an input file or read from a string,
        // so pass both infileName and inputString.
        // We want to output to string, so we pass in the address of the actualOutput string.
        Result = TransformGraph(command, infileName, inputString, &zeroBasedOutputFlag, NULL, &actualOutput);

        if (Result != OK || actualOutput == NULL)
        {
            gp_ErrorMessage("Failed to perform transformation.");
            Result = NOTOK;
        }
        else
        {
            char *expectedOutfileName = NULL;
            // Final arg is baseFlag, which is dependent on whether the FLAGS_ZEROBASEDIO is set in a graph's graphFlags
            Result = ConstructTransformationExpectedResultFileName(infileName, &expectedOutfileName, transformationCode, zeroBasedOutputFlag ? 0 : 1);

            if (Result != OK || expectedOutfileName == NULL)
            {
                gp_ErrorMessage("Unable to construct output file name for "
                                "expected transformation output.");
                Result = NOTOK;
            }
            else
            {
                Result = TextFileMatchesString(expectedOutfileName, actualOutput);

                if (Result == TRUE)
                {
                    gp_Message("For the transformation %s on file \"%.*s\", "
                               "actual output matched expected output file.",
                               command, FILENAME_MAX, infileName);
                    Result = OK;
                }
                else
                {
                    gp_ErrorMessage("For the transformation %s on file \"%.*s\", "
                                    "actual output did not match expected "
                                    "output file.",
                                    command, FILENAME_MAX, infileName);
                    Result = NOTOK;
                }

                if (expectedOutfileName != NULL)
                {
                    free(expectedOutfileName);
                    expectedOutfileName = NULL;
                }

                if (actualOutput != NULL)
                {
                    free(actualOutput);
                    actualOutput = NULL;
                }
            }
        }
    }

    gp_Message(" ");

    if (inputString != NULL)
    {
        free(inputString);
        inputString = NULL;
    }

    return Result;
}

/****************************************************************************
 callRandomGraphs()
 ****************************************************************************/

// 'planarity -r [-q] C K N [O]': Random graphs
int callRandomGraphs(int argc, char *argv[])
{
    int offset = 0, NumGraphs = 0, SizeOfGraphs = 0;
    char *commandString = NULL, *outfileName = NULL;

    if (argc < 5 || argc > 7)
        return NOTOK;

    if (strncmp(argv[2], "-q", 2) == 0)
    {
        if (argc < 6)
            return NOTOK;

        offset = 1;
    }

    if (argc > (6 + offset))
        return NOTOK;

    commandString = argv[2 + offset];
    NumGraphs = atoi(argv[3 + offset]);
    SizeOfGraphs = atoi(argv[4 + offset]);

    if (argc == (6 + offset))
        outfileName = argv[5 + offset];

    return RandomGraphs(commandString, NumGraphs, SizeOfGraphs, outfileName);
}

/****************************************************************************
 callSpecificGraph()
 ****************************************************************************/

// 'planarity -s [-q] C I O [O2]': Specific graph
int callSpecificGraph(int argc, char *argv[])
{
    int offset = 0;
    char *commandString = NULL;
    char *infileName = NULL, *outfileName = NULL, *outfile2Name = NULL;

    if (argc < 5)
        return NOTOK;

    if (strncmp(argv[2], "-q", 2) == 0)
    {
        if (argc < 6)
            return NOTOK;

        offset = 1;
    }

    if (argc > (6 + offset))
        return NOTOK;

    commandString = argv[2 + offset];
    infileName = argv[3 + offset];
    outfileName = argv[4 + offset];

    if (argc == 6 + offset)
        outfile2Name = argv[5 + offset];

    return SpecificGraph(commandString, infileName, outfileName, outfile2Name, NULL, NULL, NULL);
}

/****************************************************************************
 callRandomMaxPlanarGraph()
 ****************************************************************************/

// 'planarity -rm [-q] N O [O2]': Maximal planar random graph
int callRandomMaxPlanarGraph(int argc, char *argv[])
{
    int offset = 0, numVertices = 0;
    char *outfileName = NULL, *outfile2Name = NULL;

    if (argc < 4)
        return NOTOK;

    if (strncmp(argv[2], "-q", 2) == 0)
    {
        if (argc < 5)
            return NOTOK;

        offset = 1;
    }

    if (argc > (5 + offset))
        return NOTOK;

    numVertices = atoi(argv[2 + offset]);
    outfileName = argv[3 + offset];

    if (argc == 5 + offset)
        outfile2Name = argv[4 + offset];

    return RandomGraph("-p", 0, numVertices, outfileName, outfile2Name);
}

/****************************************************************************
 callRandomNonplanarGraph()
 ****************************************************************************/

// 'planarity -rn [-q] N O [O2]': Non-planar random graph (maximal planar plus edge)
int callRandomNonplanarGraph(int argc, char *argv[])
{
    int offset = 0, numVertices = 0;
    char *outfileName = NULL, *outfile2Name = NULL;

    if (argc < 4)
        return NOTOK;

    if (strncmp(argv[2], "-q", 2) == 0)
    {
        if (argc < 5)
            return NOTOK;

        offset = 1;
    }

    if (argc > (5 + offset))
        return NOTOK;

    numVertices = atoi(argv[2 + offset]);
    outfileName = argv[3 + offset];

    if (argc == 5 + offset)
        outfile2Name = argv[4 + offset];

    return RandomGraph("-p", 1, numVertices, outfileName, outfile2Name);
}

/****************************************************************************
 callTransformGraph()
 ****************************************************************************/

// 'planarity -x [-q] -(gam) I O': Input file I is transformed from its given
// format to the format given by the g (g6), a (adjacency list) or m (matrix),
// and written to output file O.
int callTransformGraph(int argc, char *argv[])
{
    int offset = 0;
    char *commandString = NULL;
    char *infileName = NULL, *outfileName = NULL;

    if (argc < 5)
        return NOTOK;

    if (argv[2][0] == '-' && argv[2][1] == 'q')
    {
        if (argc < 6)
            return NOTOK;

        offset = 1;
    }

    if (argc > (5 + offset))
        return NOTOK;

    commandString = argv[2 + offset];

    infileName = argv[3 + offset];
    outfileName = argv[4 + offset];

    // We don't want to read from string, so inputStr is NULL
    // We don't want to write to string, so pOutputStr is NULL
    // We don't need to capture whether output is 0- or 1-based, so zeroBasedOutputFlag arg is NULL
    return TransformGraph(commandString, infileName, NULL, NULL, outfileName, NULL);
}

/****************************************************************************
 callTestAllGraphs()
 ****************************************************************************/

// 'planarity -t [-q] C I O': If the command line argument after -t [-q] is a
// recognized algorithm command C, then the input file I must be in ".g6" format
// (report an error otherwise), and the algorithm(s) indicated by C are executed
// on the graph(s) in the input file, with the results of the execution stored
// in output file O.
int callTestAllGraphs(int argc, char *argv[])
{
    int offset = 0;
    char *commandString = NULL;
    char *infileName = NULL, *outfileName = NULL;

    if (argc < 5)
        return NOTOK;

    if (argv[2][0] == '-' && argv[2][1] == 'q')
    {
        if (argc < 6)
            return NOTOK;

        offset = 1;
    }

    if (argc > (5 + offset))
        return NOTOK;

    commandString = argv[2 + offset];

    infileName = argv[3 + offset];
    outfileName = argv[4 + offset];

    // NOTE: We don't want to write to string, so pOutputStr is NULL
    return TestAllGraphs(commandString, infileName, outfileName, NULL);
}
