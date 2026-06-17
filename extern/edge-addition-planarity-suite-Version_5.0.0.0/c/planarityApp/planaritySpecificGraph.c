/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "planarity.h"

/****************************************************************************
 SpecificGraph()
 commandString - a string (e.g. p,d,o,2,3,3e,4) indicating the algorithm to run on the specific graph
 infileName - name of file to read, or NULL to cause the program to prompt the user for a file name
 outfileName - name of primary output file, or NULL to construct an output file name based on the input
 outfile2Name - name of a secondary output file, or NULL to suppress secondary output, or empty string
                to construct the secondary output file name based on the output file name.
                For p=planarity and o=outerplanarity, empty string means that the planarity or outerplanarity
                    obstruction will be written to outfileName, rather than only an embedding
                For d=drawing a planar graph, empty string means the visibility representation will be
                    written to outfileName+".render.txt"
 inputStr - if non-NULL, overrides infileName and provides the input graph within a string
 pOutputStr - if non-NULL, overrides outfileName and provides a pointer pointer where a string containing
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
    char const *const commandString,
    char const *infileName, char *outfileName, char *outfile2Name,
    char *inputStr, char **pOutputStr, char **pOutput2Str)
{
    int Result = OK;

    graphP theGraph = NULL, origGraph = NULL;
    platform_time start, end;

    char command = '\0', modifier = '\0';
    int embedFlags = 0;

    if (GetCommandAndOptionalModifier(commandString, &command, &modifier) != OK)
    {
        gp_ErrorMessage("Unable to derive command and modifier from "
                        "commandString.");
        return NOTOK;
    }

    if (GetEmbedFlags(command, modifier, &embedFlags) != OK)
    {
        gp_ErrorMessage("Unable to derive embedFlags from command and optional "
                        "modifier character.");
        return NOTOK;
    }

    // Get the file name of the graph to test
    if (inputStr == NULL)
    {
        if (infileName != NULL)
        {
            if ((infileName = ConstructInputFileName(infileName)) == NULL)
            {
                gp_ErrorMessage("Error constructing input file name.");
                Result = NOTOK;
            }
        }
        else
        {
            while (1)
            {
                infileName = ConstructInputFileName(infileName);
                if (infileName == NULL || strlen(infileName) == 0)
                {
                    gp_ErrorMessage("Error constructing input file name.");
                    Result = NOTOK;

                    break;
                }
                else if (strncmp(infileName, "stdin", strlen("stdin")) == 0)
                {
                    // NOTE: When run from command-line or test, it is not
                    // possible to have infileName being NULL and therefore
                    // prompting the user for the input file name, so there's no
                    // way you could have them enter stdin and reach this error
                    // from command-line
                    gp_Message("Please retry with an input file "
                               "path: stdin not supported from menu.");

                    infileName = NULL;
                }
                else
                    break;
            }
        }
    }

    if (Result == OK)
    {
        // Create the graph and, if needed, attach the correct algorithm to it
        if ((theGraph = gp_New()) == NULL)
        {
            gp_ErrorMessage("Unable to allocate graph.");
            return NOTOK;
        }

        // Read the graph into memory
        if (inputStr == NULL)
            Result = gp_Read(theGraph, infileName);
        else
            Result = gp_ReadFromString(theGraph, inputStr);
    }

    // If there was an unrecoverable error, report it and exit early.
    if (Result != OK)
    {
        gp_ErrorMessage("Failed to read graph.");

        gp_Free(&theGraph);

        return NOTOK;
    }

    // Copy the graph for integrity checking
    origGraph = gp_DupGraph(theGraph);

    if (origGraph == NULL)
    {
        gp_ErrorMessage("Unable to duplicate original graph.");
        gp_Free(&theGraph);
        return NOTOK;
    }

    // Extend theGraph so that it is equivalent to having created a new instance
    // of a graph subclass that supports the desired algorithm
    if (ExtendGraph(theGraph, command) == OK)
    {
        // Run the algorithm
        platform_GetTime(start);

        //          gp_DepthFirstSearch(theGraph);
        //          gp_SortVertices(theGraph);
        //          gp_Write(theGraph, "debug.before.txt", WRITE_DEBUGINFO);
        //          gp_SortVertices(theGraph);

        Result = gp_Embed(theGraph, embedFlags);

        platform_GetTime(end);

        if (Result != OK && Result != NONEMBEDDABLE)
        {
            gp_ErrorMessage("Failed to embed graph.");
            gp_Free(&theGraph);
            gp_Free(&origGraph);
            return NOTOK;
        }

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

    // Report an error, if there was one, free the graph, and return
    if (Result != OK && Result != NONEMBEDDABLE)
    {
        gp_ErrorMessage("AN ERROR HAS BEEN DETECTED");
        Result = NOTOK;
        //      gp_Write(theGraph, "debug.after.txt", WRITE_DEBUGINFO);
    }

    // Provide the output file(s)
    else
    {
        // Restore the vertex ordering of the original graph (undo DFS numbering)
        if (gp_SortVertices(theGraph) != OK)
        {
            gp_ErrorMessage("Unable to restore original vertex ordering.");
            gp_Free(&theGraph);
            return NOTOK;
        }

        // Determine the name of the primary output file
        outfileName = ConstructPrimaryOutputFileName(infileName, outfileName, command);

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
            {
                gp_ErrorMessage("Failed to write graph to primary output file.");
                Result = NOTOK;
            }
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
                    // By default, use the same name as the primary output file name
                    if (strlen(outfile2Name) == 0)
                        outfile2Name = outfileName;
                    writeResult = gp_Write(theGraph, outfile2Name, WRITE_ADJLIST);
                }
                else if (command == 'd' && Result == OK)
                {
                    // An empty but non-NULL string is passed to indicate the necessity
                    // of selecting a default name for the second output file.
                    // By default, add ".render.txt" to the primary output file name
                    if (strlen(outfile2Name) == 0)
                        strcat((outfile2Name = outfileName), ".render.txt");
                    writeResult = gp_DrawPlanar_RenderToFile(theGraph, outfile2Name);
                }
            }

            if (writeResult != OK)
            {
                gp_ErrorMessage("Failed to write secondary output file.");
                Result = NOTOK;
            }
        }
    }

    // Free the graph
    gp_Free(&theGraph);

    // Flush any remaining message content to the user, and return the result
    FlushConsole(stdout);

    return Result;
}
