/*
Copyright (c) 1997-2025, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "planarity.h"

/****************************************************************************
 SpecificGraph()
 command - a menu letter (e.g. p,d,o,2,3,4) indicating the algorithm to run on the specific graph
 infilename - name of file to read, or NULL to cause the program to prompt the user for a filename
 outfilename - name of primary output file, or NULL to construct an output filename based on the input
 outfile2Name - name of a secondary output file, or NULL to suppress secondary output, or empty string
                to construct the secondary output filename based on the output filename.
                For p=planarity and o=outerplanarity, empty string means that the planarity or outerplanarity
                    obstruction will be written to outfilename, rather than only an embedding
                For d=drawing a planar graph, empty string means the visibility representation will be
                    written to outfilename+".render.txt"
 inputStr - if non-NULL, overrides infilename and provides the input graph within a string
 pOutputStr - if non-NULL, overrides outfilename and provides a pointer pointer where a string containing
                the primary output should go.
                For p=planarity, o=outerplanarity, and d=drawing, the primary output is the graph embedding
                For p=planarity and o=outerplanarity, if the graph is not embeddable, then the primary
                    output will contain the planarity or outerplanarity obstruction subgraph
                For 2,3,4=subgraph homeomorphism, the primary output is the homeomorphic subgraph, if found
 pOutput2Str - if non-NULL, overrides outfile2Name and provides a pointer pointer where a string containing
                the secondary output should go.
                For d=drawing a planar graph, the visibility representation will be written to this
                    secondary output
 ****************************************************************************/

int SpecificGraph(
    char command,
    char *infileName, char *outfileName, char *outfile2Name,
    char *inputStr, char **pOutputStr, char **pOutput2Str)
{
    graphP theGraph, origGraph;
    platform_time start, end;
    int Result = OK;

    // Get the filename of the graph to test
    if (inputStr == NULL)
    {
        if (infileName != NULL)
        {
            if ((infileName = ConstructInputFilename(infileName)) == NULL)
                return NOTOK;
        }
        else
        {
            do
            {
                infileName = ConstructInputFilename(infileName);
                if (infileName != NULL && strncmp(infileName, "stdin", strlen("stdin")) == 0)
                {
                    ErrorMessage("\n\tPlease choose an input file path: stdin not supported from menu.\n\n");
                    infileName = NULL;
                }
            } while (infileName == NULL || strlen(infileName) == 0);
        }
    }

    // Create the graph and, if needed, attach the correct algorithm to it
    theGraph = gp_New();

    // Read the graph into memory
    if (inputStr == NULL)
    {
        Result = gp_Read(theGraph, infileName);
    }
    else
    {
        Result = gp_ReadFromString(theGraph, inputStr);
    }

    // If there was an unrecoverable error, report it
    if (Result != OK)
    {
        ErrorMessage("Failed to read graph\n");
    }
    // Otherwise, call the correct algorithm on it
    else
    {
        // Copy the graph for integrity checking
        origGraph = gp_DupGraph(theGraph);

        // Run the algorithm
        if (strchr(GetAlgorithmChoices(), command))
        {
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

            int embedFlags = GetEmbedFlags(command);
            platform_GetTime(start);

            //          gp_CreateDFSTree(theGraph);
            //          gp_SortVertices(theGraph);
            //          gp_Write(theGraph, "debug.before.txt", WRITE_DEBUGINFO);
            //          gp_SortVertices(theGraph);

            Result = gp_Embed(theGraph, embedFlags);
            platform_GetTime(end);
            Result = gp_TestEmbedResultIntegrity(theGraph, origGraph, Result);
        }
        else
        {
            platform_GetTime(start);
            Result = NOTOK;
            platform_GetTime(end);
        }

        // Write what the algorithm determined and how long it took
        WriteAlgorithmResults(theGraph, Result, command, start, end, infileName);

        // Free the graph obtained for integrity checking.
        gp_Free(&origGraph);
    }

    // Report an error, if there was one, free the graph, and return
    if (Result != OK && Result != NONEMBEDDABLE)
    {
        ErrorMessage("AN ERROR HAS BEEN DETECTED\n");
        Result = NOTOK;
        //      gp_Write(theGraph, "debug.after.txt", WRITE_DEBUGINFO);
    }

    // Provide the output file(s)
    else
    {
        // Restore the vertex ordering of the original graph (undo DFS numbering)
        if (strchr(GetAlgorithmChoices(), command))
            gp_SortVertices(theGraph);

        // Determine the name of the primary output file
        outfileName = ConstructPrimaryOutputFilename(infileName, outfileName, command);

        // For some algorithms, the primary output file is not always written
        if ((strchr("pdo", command) && Result == NONEMBEDDABLE) ||
            (strchr("234", command) && Result == OK))
        {
            // Do not write the file
        }

        // Write the primary output file, if appropriate to do so
        else
        {
            int writeResult = OK;

            if (pOutputStr == NULL)
                writeResult = gp_Write(theGraph, outfileName, WRITE_ADJLIST);
            else
                writeResult = gp_WriteToString(theGraph, pOutputStr, WRITE_ADJLIST);

            if (writeResult != OK)
                Result = NOTOK;
        }

        // NOW WE WANT TO WRITE THE SECONDARY OUTPUT to a FILE or STRING

        // When called from the menu system, we want to write the planar or outerplanar
        // obstruction, if one exists. For planar graph drawing, we want the character
        // art rendition.
        if (outfile2Name != NULL || pOutput2Str != NULL)
        {
            int writeResult = OK;

            if (pOutput2Str != NULL)
            {
                // A non-embeddable obstruction subgraph also goes into the primary output, not the secondary
                if ((command == 'p' || command == 'o') && Result == NONEMBEDDABLE)
                    writeResult = gp_WriteToString(theGraph, pOutputStr, WRITE_ADJLIST);

                // Only the planar visibility representation goes into the secondary output
                else if (command == 'd' && Result == OK)
                    writeResult = gp_DrawPlanar_RenderToString(theGraph, pOutput2Str);
            }
            else if (outfile2Name != NULL)
            {
                if ((command == 'p' || command == 'o') && Result == NONEMBEDDABLE)
                {
                    // By default, use the same name as the primary output filename
                    if (strlen(outfile2Name) == 0)
                        outfile2Name = outfileName;
                    writeResult = gp_Write(theGraph, outfile2Name, WRITE_ADJLIST);
                }
                else if (command == 'd' && Result == OK)
                {
                    // An empty but non-NULL string is passed to indicate the necessity
                    // of selecting a default name for the second output file.
                    // By default, add ".render.txt" to the primary output filename
                    if (strlen(outfile2Name) == 0)
                        strcat((outfile2Name = outfileName), ".render.txt");
                    writeResult = gp_DrawPlanar_RenderToFile(theGraph, outfile2Name);
                }
            }

            if (writeResult != OK)
                Result = NOTOK;
        }
    }

    // Free the graph
    gp_Free(&theGraph);

    // Flush any remaining message content to the user, and return the result
    FlushConsole(stdout);
    return Result;
}

/****************************************************************************
 WriteAlgorithmResults()
 ****************************************************************************/

void WriteAlgorithmResults(graphP theGraph, int Result, char command, platform_time start, platform_time end, char *infileName)
{
    char *messageFormat = NULL;
    char messageContents[MAXLINE + 1];
    int charsAvailForStr = 0;

    if (infileName)
    {
        messageFormat = "The graph \"%.*s\" ";
        charsAvailForStr = (int)(MAXLINE - strlen(messageFormat));
        sprintf(messageContents, messageFormat, charsAvailForStr, infileName);
    }
    else
        sprintf(messageContents, "The graph ");
    Message(messageContents);

    switch (command)
    {
    case 'p':
        sprintf(messageContents, "is%s planar.\n", Result == OK ? "" : " not");
        break;
    case 'd':
        sprintf(messageContents, "is%s planar.\n", Result == OK ? "" : " not");
        break;
    case 'o':
        sprintf(messageContents, "is%s outerplanar.\n", Result == OK ? "" : " not");
        break;
    case '2':
        sprintf(messageContents, "has %s subgraph homeomorphic to K_{2,3}.\n", Result == OK ? "no" : "a");
        break;
    case '3':
        sprintf(messageContents, "has %s subgraph homeomorphic to K_{3,3}.\n", Result == OK ? "no" : "a");
        break;
    case '4':
        sprintf(messageContents, "has %s subgraph homeomorphic to K_4.\n", Result == OK ? "no" : "a");
        break;
    default:
        sprintf(messageContents, "has not been processed due to unrecognized command.\n");
        break;
    }
    Message(messageContents);

    sprintf(messageContents, "Algorithm '%s' executed in %.3lf seconds.\n",
            GetAlgorithmName(command), platform_GetDuration(start, end));
    Message(messageContents);
}
