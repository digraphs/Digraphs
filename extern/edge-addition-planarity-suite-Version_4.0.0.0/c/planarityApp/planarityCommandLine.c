/*
Copyright (c) 1997-2025, John M. Boyer
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

/****************************************************************************
 Command Line Processor
 ****************************************************************************/

int commandLine(int argc, char *argv[])
{
    int Result = OK;

    if (argc >= 3 && strcmp(argv[2], "-q") == 0)
        setQuietModeSetting(TRUE);

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
        ErrorMessage("Unsupported command line.  Here is the help for this program.\n");
        helpMessage(NULL);
        Result = NOTOK;
    }

#ifdef DEBUG
    // When one builds and runs the executable in an external console from an IDE
    // such as VSCode, the external console window will close immediately upon
    // exit 0 being returned. This means that one may miss Messages and
    // ErrorMessages that are crucial to the debugging process. Hence, if we compile
    // with the DDEBUG flag, this means that in appconst.h we #define DEBUG. That way,
    // this prompt will appear only for debug builds, and will ensure the console
    // window stays open until the user proceeds.
    printf("\n\tPress return key to exit...\n");
    fflush(stdout);
    fflush(stdin);
    getc(stdin);
#endif
    return Result == OK ? 0 : (Result == NONEMBEDDABLE ? 1 : -1);
}

/****************************************************************************
 Legacy Command Line Processor from version 1.x
 ****************************************************************************/

int legacyCommandLine(int argc, char *argv[])
{
    graphP theGraph = gp_New();
    int Result;

    Result = gp_Read(theGraph, argv[1]);
    if (Result != OK)
    {
        if (Result != NONEMBEDDABLE)
        {
            char *messageFormat = "Failed to read graph \"%.*s\"";
            char messageContents[MAXLINE + 1];
            int charsAvailForFilename = (int)(MAXLINE - strlen(messageFormat));
            sprintf(messageContents, messageFormat, charsAvailForFilename, argv[1]);
            ErrorMessage(messageContents);
            return -2;
        }
    }

    Result = gp_Embed(theGraph, EMBEDFLAGS_PLANAR);

    if (Result == OK)
    {
        gp_SortVertices(theGraph);
        gp_Write(theGraph, argv[2], WRITE_ADJLIST);
    }

    else if (Result == NONEMBEDDABLE)
    {
        if (argc >= 5 && strcmp(argv[3], "-n") == 0)
        {
            gp_SortVertices(theGraph);
            gp_Write(theGraph, argv[4], WRITE_ADJLIST);
        }
    }
    else
        Result = NOTOK;

    gp_Free(&theGraph);

    // In the legacy 1.x versions, OK/NONEMBEDDABLE was 0 and NOTOK was -2
    return Result == OK || Result == NONEMBEDDABLE ? 0 : -2;
}

/****************************************************************************
 Quick regression test
 ****************************************************************************/

int runSpecificGraphTests(char *);
int runSpecificGraphTest(char *command, char *infileName, int inputInMemFlag);
int runGraphTransformationTest(char *command, char *infileName, int inputInMemFlag);

int runQuickRegressionTests(int argc, char *argv[])
{
    char *samplesDir = "samples";
    int samplesDirArgLocation = 2;

    // Skip optional -q quiet mode command-line paramater, if present
    if (argc > samplesDirArgLocation && strcmp(argv[samplesDirArgLocation], "-q") == 0)
        samplesDirArgLocation++;

    // Accept overriding sample directory command-line parameter, if present
    if (argc > samplesDirArgLocation)
        samplesDir = argv[samplesDirArgLocation];

    if (runSpecificGraphTests(samplesDir) < 0)
        return NOTOK;

    return OK;
}

int runSpecificGraphTests(char *samplesDir)
{
    char origDir[2049];
    int retVal = 0;

    if (!getcwd(origDir, 2048))
        return -1;

    // Preserve original behavior before the samplesDir command-line parameter was available
    if (strcmp(samplesDir, "samples") == 0)
    {
        if (chdir(samplesDir) != 0)
        {
            if (chdir("..") != 0 || chdir(samplesDir) != 0)
            {
                // Give success result, but Warn if no samples (except no warning if in quiet mode)
                Message("WARNING: Unable to change to samples directory to run tests on samples.\n");
                return 0;
            }
        }
    }
    else
    {
        // New behavior if samplesDir command-line parameter was specified
        if (chdir(samplesDir) != 0)
        {
            Message("WARNING: Unable to change to samples directory to run tests on samples.\n");
            return 0;
        }
    }

#ifdef USE_FASTER_1BASEDARRAYS
    Message("\n\tStarting 1-based Array Index Tests\n\n");

    if (runSpecificGraphTest("-p", "maxPlanar5.txt", TRUE) < 0)
    {
        retVal = -1;
        Message("Planarity test on maxPlanar5.txt failed.\n");
    }

    if (runSpecificGraphTest("-d", "maxPlanar5.txt", FALSE) < 0)
    {
        retVal = -1;
        Message("Graph drawing test maxPlanar5.txt failed.\n");
    }

    if (runSpecificGraphTest("-d", "drawExample.txt", TRUE) < 0)
    {
        retVal = -1;
        Message("Graph drawing on drawExample.txt failed.\n");
    }

    if (runSpecificGraphTest("-p", "Petersen.txt", FALSE) < 0)
    {
        retVal = -1;
        Message("Planarity test on Petersen.txt failed.\n");
    }

    if (runSpecificGraphTest("-o", "Petersen.txt", TRUE) < 0)
    {
        retVal = -1;
        Message("Outerplanarity test on Petersen.txt failed.\n");
    }

    if (runSpecificGraphTest("-2", "Petersen.txt", FALSE) < 0)
    {
        retVal = -1;
        Message("K_{2,3} search on Petersen.txt failed.\n");
    }

    if (runSpecificGraphTest("-3", "Petersen.txt", TRUE) < 0)
    {
        retVal = -1;
        Message("K_{3,3} search on Petersen.txt failed.\n");
    }

    if (runSpecificGraphTest("-4", "Petersen.txt", FALSE) < 0)
    {
        retVal = -1;
        Message("K_4 search on Petersen.txt failed.\n");
    }

    Message("\tFinished 1-based Array Index Tests.\n\n");
#endif

    if (runSpecificGraphTest("-p", "maxPlanar5.0-based.txt", FALSE) < 0)
    {
        retVal = -1;
        Message("Planarity test on maxPlanar5.0-based.txt failed.\n");
    }

    if (runSpecificGraphTest("-d", "maxPlanar5.0-based.txt", TRUE) < 0)
    {
        retVal = -1;
        Message("Graph drawing test maxPlanar5.0-based.txt failed.\n");
    }

    if (runSpecificGraphTest("-d", "drawExample.0-based.txt", FALSE) < 0)
    {
        retVal = -1;
        Message("Graph drawing on drawExample.0-based.txt failed.\n");
    }

    if (runSpecificGraphTest("-p", "Petersen.0-based.txt", TRUE) < 0)
    {
        retVal = -1;
        Message("Planarity test on Petersen.0-based.txt failed.\n");
    }

    if (runSpecificGraphTest("-o", "Petersen.0-based.txt", FALSE) < 0)
    {
        retVal = -1;
        Message("Outerplanarity test on Petersen.0-based.txt failed.\n");
    }

    if (runSpecificGraphTest("-2", "Petersen.0-based.txt", TRUE) < 0)
    {
        retVal = -1;
        Message("K_{2,3} search on Petersen.0-based.txt failed.\n");
    }

    if (runSpecificGraphTest("-3", "Petersen.0-based.txt", FALSE) < 0)
    {
        retVal = -1;
        Message("K_{3,3} search on Petersen.0-based.txt failed.\n");
    }

    if (runSpecificGraphTest("-4", "Petersen.0-based.txt", TRUE) < 0)
    {
        retVal = -1;
        Message("K_4 search on Petersen.0-based.txt failed.\n");
    }

    /*
        GRAPH TRANSFORMATION TESTS
    */
    //  TRANSFORM TO ADJACENCY LIST

    // runGraphTransformationTest by reading file contents into string
    if (runGraphTransformationTest("-a", "nauty_example.g6", TRUE) < 0)
    {
        retVal = -1;
        Message("Transforming nauty_example.g6 file contents as string to adjacency list failed.\n");
    }

    // runGraphTransformationTest by reading from file
    if (runGraphTransformationTest("-a", "nauty_example.g6", FALSE) < 0)
    {
        retVal = -1;
        Message("Transforming nauty_example.g6 using file pointer to adjacency list failed.\n");
    }

    // runGraphTransformationTest by reading first graph from file into string
    if (runGraphTransformationTest("-a", "N5-all.g6", TRUE) < 0)
    {
        retVal = -1;
        Message("Transforming first graph in N5-all.g6 (read as string) to adjacency list failed.\n");
    }

    // runGraphTransformationTest by reading first graph from file pointer
    if (runGraphTransformationTest("-a", "N5-all.g6", FALSE) < 0)
    {
        retVal = -1;
        Message("Transforming first graph in N5-all.g6 (read from file pointer) to adjacency list failed.\n");
    }

    // runGraphTransformationTest by reading file contents corresponding to dense graph into string
    if (runGraphTransformationTest("-a", "K10.g6", TRUE) < 0)
    {
        retVal = -1;
        Message("Transforming K10.g6 file contents as string to adjacency list failed.\n");
    }

    // runGraphTransformationTest by reading dense graph from file
    if (runGraphTransformationTest("-a", "K10.g6", FALSE) < 0)
    {
        retVal = -1;
        Message("Transforming K10.g6 using file pointer to adjacency list failed.\n");
    }

    //  TRANSFORM TO ADJACENCY MATRIX

    // runGraphTransformationTest by reading file contents into string
    if (runGraphTransformationTest("-m", "nauty_example.g6", TRUE) < 0)
    {
        retVal = -1;
        Message("Transforming nauty_example.g6 file contents as string to adjacency matrix failed.\n");
    }

    // runGraphTransformationTest by reading from file
    if (runGraphTransformationTest("-m", "nauty_example.g6", FALSE) < 0)
    {
        retVal = -1;
        Message("Transforming nauty_example.g6 using file pointer to adjacency matrix failed.\n");
    }

    // runGraphTransformationTest by reading first graph from file into string
    if (runGraphTransformationTest("-m", "N5-all.g6", TRUE) < 0)
    {
        retVal = -1;
        Message("Transforming first graph in N5-all.g6 (read as string) to adjacency matrix failed.\n");
    }

    // runGraphTransformationTest by reading first graph from file pointer
    if (runGraphTransformationTest("-m", "N5-all.g6", FALSE) < 0)
    {
        retVal = -1;
        Message("Transforming first graph in N5-all.g6 (read from file pointer) to adjacency matrix failed.\n");
    }

    // runGraphTransformationTest by reading file contents corresponding to dense graph into string
    if (runGraphTransformationTest("-m", "K10.g6", TRUE) < 0)
    {
        retVal = -1;
        Message("Transforming K10.g6 file contents as string to adjacency matrix failed.\n");
    }

    // runGraphTransformationTest by reading dense graph from file
    if (runGraphTransformationTest("-m", "K10.g6", FALSE) < 0)
    {
        retVal = -1;
        Message("Transforming K10.g6 using file pointer to adjacency matrix failed.\n");
    }

    //  TRANSFORM TO .G6

    // runGraphTransformationTest by reading from file
    if (runGraphTransformationTest("-g", "nauty_example.g6.0-based.AdjList.out.txt", TRUE) < 0)
    {
        retVal = -1;
        Message("Transforming nauty_example.g6.0-based.AdjList.out.txt using file pointer to .g6 failed.\n");
    }

    // runGraphTransformationTest by reading from file
    if (runGraphTransformationTest("-g", "K10.g6.0-based.AdjList.out.txt", TRUE) < 0)
    {
        retVal = -1;
        Message("Transforming K10.g6.0-based.AdjList.out.txt using file pointer to .g6 failed.\n");
    }

    if (retVal == 0)
        Message("Tests of all specific graphs succeeded.\n");
    else
        Message("One or more specific graph tests FAILED.\n");

    chdir(origDir);
    FlushConsole(stdout);
    return retVal;
}

int runSpecificGraphTest(char *command, char *infileName, int inputInMemFlag)
{
    int Result = OK;
    char algorithmCode = command[1];

    // The algorithm, indicated by algorithmCode, operating on 'infilename' is expected to produce
    // an output that is stored in the file named 'expectedResultFileName' (return string not owned)
    char *expectedPrimaryResultFileName = ConstructPrimaryOutputFilename(infileName, NULL, command[1]);

    char *inputString = NULL;
    char *actualOutput = NULL;
    char *actualOutput2 = NULL;

    // SpecificGraph() can invoke gp_Read() if the graph is to be read from a file, or it can invoke
    // gp_ReadFromString() if the inputInMemFlag is set.
    if (inputInMemFlag)
    {
        inputString = ReadTextFileIntoString(infileName);
        if (inputString == NULL)
        {
            ErrorMessage("Failed to read input file into string.\n");
            Result = NOTOK;
        }
    }

    if (Result == OK)
    {
        // Perform the indicated algorithm on the graph in the input file or string. gp_ReadFromString()
        // will handle freeing inputString.
        Result = SpecificGraph(algorithmCode,
                               infileName, NULL, NULL,
                               inputString, &actualOutput, &actualOutput2);
    }

    // Change from internal OK/NONEMBEDDABLE/NOTOK result to a command-line style 0/-1 result
    if (Result == OK || Result == NONEMBEDDABLE)
        Result = 0;
    else
    {
        ErrorMessage("Test failed (graph processor returned failure result).\n");
        Result = -1;
    }

    // Test that the primary actual output matches the primary expected output
    if (Result == 0)
    {
        if (TextFileMatchesString(expectedPrimaryResultFileName, actualOutput) == TRUE)
            Message("Test succeeded (result equal to exemplar).\n");
        else
        {
            ErrorMessage("Test failed (result not equal to exemplar).\n");
            Result = -1;
        }
    }

    // Test that the secondary actual output matches the secondary expected output
    if (algorithmCode == 'd' && Result == 0)
    {
        char *expectedSecondaryResultFileName = (char *)malloc(strlen(expectedPrimaryResultFileName) + strlen(".render.txt") + 1);

        if (expectedSecondaryResultFileName != NULL)
        {
            sprintf(expectedSecondaryResultFileName, "%s%s", expectedPrimaryResultFileName, ".render.txt");

            if (TextFileMatchesString(expectedSecondaryResultFileName, actualOutput2) == TRUE)
                Message("Test succeeded (secondary result equal to exemplar).\n");
            else
            {
                ErrorMessage("Test failed (secondary result not equal to exemplar).\n");
                Result = -1;
            }

            free(expectedSecondaryResultFileName);
        }
        else
        {
            Result = -1;
        }
    }

    // Cleanup and then return the command-line style result code
    Message("\n");

    if (actualOutput != NULL)
        free(actualOutput);
    if (actualOutput2 != NULL)
        free(actualOutput2);

    return Result;
}

int runGraphTransformationTest(char *command, char *infileName, int inputInMemFlag)
{
    int Result = OK;

    char transformationCode = '\0';
    // runGraphTransformationTest will not test performing an algorithm on a given
    // input graph; it will only support "-(gam)"
    if (command == NULL || strlen(command) < 2)
    {
        ErrorMessage("runGraphTransformationTest only supports -(gam).\n");
        return NOTOK;
    }
    else if (strlen(command) == 2)
        transformationCode = command[1];

    // SpecificGraph() can invoke gp_Read() if the graph is to be read from a file, or it can invoke
    // gp_ReadFromString() if the inputInMemFlag is set.
    char *inputString = NULL;
    if (inputInMemFlag)
    {
        inputString = ReadTextFileIntoString(infileName);
        if (inputString == NULL)
        {
            ErrorMessage("Failed to read input file into string.\n");
            Result = NOTOK;
        }
    }

    if (Result == OK)
    {
        // We need to capture whether output is 0- or 1-based to construct the name of the file to compare actualOutput with
        int zeroBasedOutputFlag = 0;
        char *actualOutput = NULL;
        // We want to handle the test being run when we read from an input file or read from a string,
        // so pass both infileName and inputString. Ownership of inputString is relinquished to TransformGraph(),
        // and gp_ReadFromString() will handle freeing it.
        // We want to output to string, so we pass in the address of the actualOutput string.
        Result = TransformGraph(command, infileName, inputString, &zeroBasedOutputFlag, NULL, &actualOutput);

        if (Result != OK || actualOutput == NULL)
        {
            ErrorMessage("Failed to perform transformation.\n");
        }
        else
        {
            // Final arg is baseFlag, which is dependent on whether the FLAGS_ZEROBASEDIO is set in a graphP's internalFlags
            char *expectedOutfileName = NULL;
            Result = ConstructTransformationExpectedResultFilename(infileName, &expectedOutfileName, transformationCode, zeroBasedOutputFlag ? 0 : 1);

            if (Result != OK || expectedOutfileName == NULL)
            {
                ErrorMessage("Unable to construct output filename for expected transformation output.\n");
                return -1;
            }

            Result = TextFileMatchesString(expectedOutfileName, actualOutput);

            char *messageFormat = NULL;
            char messageContents[MAXLINE + 1];
            int charsAvailForFilename = 0;
            if (Result == TRUE)
            {
                messageFormat = "For the transformation %s on file \"%.*s\", actual output file matched expected output file.\n";
                charsAvailForFilename = (int)(MAXLINE - strlen(messageFormat));
                sprintf(messageContents, messageFormat, command, charsAvailForFilename, infileName);
                Message(messageContents);
                Result = OK;
            }
            else
            {
                messageFormat = "For the transformation %s on file \"%.*s\", actual output file did not match expected output file.\n";
                charsAvailForFilename = (int)(MAXLINE - strlen(messageFormat));
                sprintf(messageContents, messageFormat, command, charsAvailForFilename, infileName);
                ErrorMessage(messageContents);
                Result = NOTOK;
            }

            if (expectedOutfileName != NULL)
            {
                free(expectedOutfileName);
                expectedOutfileName = NULL;
            }
        }
    }

    Message("\n");

    return (Result == OK) ? 0 : -1;
}

/****************************************************************************
 callRandomGraphs()
 ****************************************************************************/

// 'planarity -r [-q] C K N [O]': Random graphs
int callRandomGraphs(int argc, char *argv[])
{
    char Choice = 0;
    int offset = 0, NumGraphs, SizeOfGraphs;
    char *outfileName = NULL;

    if (argc < 5 || argc > 7)
        return -1;

    if (argv[2][0] == '-' && (Choice = argv[2][1]) == 'q')
    {
        Choice = argv[3][1];
        if (argc < 6)
            return -1;
        offset = 1;
    }

    NumGraphs = atoi(argv[3 + offset]);
    SizeOfGraphs = atoi(argv[4 + offset]);

    if (argc == (6 + offset))
    {
        outfileName = argv[5 + offset];
    }

    return RandomGraphs(Choice, NumGraphs, SizeOfGraphs, outfileName);
}

/****************************************************************************
 callSpecificGraph()
 ****************************************************************************/

// 'planarity -s [-q] C I O [O2]': Specific graph
int callSpecificGraph(int argc, char *argv[])
{
    char Choice = 0, *infileName = NULL, *outfileName = NULL, *outfile2Name = NULL;
    int offset = 0;

    if (argc < 5)
        return -1;

    if (argv[2][0] == '-' && (Choice = argv[2][1]) == 'q')
    {
        Choice = argv[3][1];
        if (argc < 6)
            return -1;
        offset = 1;
    }

    infileName = argv[3 + offset];
    outfileName = argv[4 + offset];
    if (argc == 6 + offset)
        outfile2Name = argv[5 + offset];

    return SpecificGraph(Choice, infileName, outfileName, outfile2Name, NULL, NULL, NULL);
}

/****************************************************************************
 callRandomMaxPlanarGraph()
 ****************************************************************************/

// 'planarity -rm [-q] N O [O2]': Maximal planar random graph
int callRandomMaxPlanarGraph(int argc, char *argv[])
{
    int offset = 0, numVertices;
    char *outfileName = NULL, *outfile2Name = NULL;

    if (argc < 4)
        return -1;

    if (argv[2][0] == '-' && argv[2][1] == 'q')
    {
        if (argc < 5)
            return -1;
        offset = 1;
    }

    numVertices = atoi(argv[2 + offset]);
    outfileName = argv[3 + offset];
    if (argc == 5 + offset)
        outfile2Name = argv[4 + offset];

    return RandomGraph('p', 0, numVertices, outfileName, outfile2Name);
}

/****************************************************************************
 callRandomNonplanarGraph()
 ****************************************************************************/

// 'planarity -rn [-q] N O [O2]': Non-planar random graph (maximal planar plus edge)
int callRandomNonplanarGraph(int argc, char *argv[])
{
    int offset = 0, numVertices;
    char *outfileName = NULL, *outfile2Name = NULL;

    if (argc < 4)
        return -1;

    if (argv[2][0] == '-' && argv[2][1] == 'q')
    {
        if (argc < 5)
            return -1;
        offset = 1;
    }

    numVertices = atoi(argv[2 + offset]);
    outfileName = argv[3 + offset];
    if (argc == 5 + offset)
        outfile2Name = argv[4 + offset];

    return RandomGraph('p', 1, numVertices, outfileName, outfile2Name);
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
        return -1;

    if (argv[2][0] == '-' && argv[2][1] == 'q')
    {
        if (argc < 6)
            return -1;
        offset = 1;
    }

    commandString = argv[2 + offset];

    infileName = argv[3 + offset];
    outfileName = argv[4 + offset];

    // We don't want to read from string, so inputStr is NULL
    // We don't want to write to string, so outputStr is NULL
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
        return -1;

    if (argv[2][0] == '-' && argv[2][1] == 'q')
    {
        if (argc < 6)
            return -1;
        offset = 1;
    }

    commandString = argv[2 + offset];

    infileName = argv[3 + offset];
    outfileName = argv[4 + offset];

    // NOTE: We don't want to write to string, so outputStr is NULL
    return TestAllGraphs(commandString, infileName, outfileName, NULL);
}
