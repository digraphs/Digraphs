/*
Copyright (c) 1997-2025, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "planarity.h"

int transformFile(graphP theGraph, char *infileName);
int transformString(graphP theGraph, char *inputStr);

/****************************************************************************
 TransformGraph()
 commandString - command to run; i.e. `-(gam)` to transform graph to .g6, adjacency list, or
 adjacency matrix format
 infileName - name of file to read, or NULL to cause the program to prompt the user for a filename
 inputStr - string containing input graph, or NULL to cause the program to fall back on reading from file
 outputBase - pointer to the flag set for whether output is 0- or 1-based
 outputFormat - output format
 outfileName - name of primary output file, or NULL to construct an output filename based on the input
 outputStr - pointer to string which we wish to use to store the transformation output
 ****************************************************************************/
int TransformGraph(char *commandString, char *infileName, char *inputStr, int *outputBase, char *outfileName, char **outputStr)
{
    int Result = OK;

    graphP theGraph;

    theGraph = gp_New();

    int outputFormat = -1;

    if (commandString[0] == '-')
    {
        if (commandString[1] == 'g')
            outputFormat = WRITE_G6;
        else if (commandString[1] == 'a')
            outputFormat = WRITE_ADJLIST;
        else if (commandString[1] == 'm')
            outputFormat = WRITE_ADJMATRIX;
        else
        {
            ErrorMessage("Invalid argument; only -(gam) is allowed.\n");
            return NOTOK;
        }

        if (inputStr)
            Result = transformString(theGraph, inputStr);
        else
            Result = transformFile(theGraph, infileName);

        if (Result != OK)
        {
            ErrorMessage("Unable to transform input graph.\n");
        }
        else
        {
            // Want to know whether the output is 0- or 1-based; will always be
            // 0-based for transformations of .g6 input
            if (outputBase != NULL)
                (*outputBase) = (theGraph->internalFlags & FLAGS_ZEROBASEDIO) ? 1 : 0;

            if (outputStr != NULL)
                Result = gp_WriteToString(theGraph, outputStr, outputFormat);
            else
                Result = gp_Write(theGraph, outfileName, outputFormat);

            if (Result != OK)
                ErrorMessage("Unable to write graph.\n");
        }
    }
    else
    {
        ErrorMessage("Invalid argument; must start with '-'.\n");
        Result = NOTOK;
    }

    gp_Free(&theGraph);
    return Result;
}

int transformFile(graphP theGraph, char *infileName)
{
    if (infileName == NULL)
    {
        if ((infileName = ConstructInputFilename(infileName)) == NULL)
            return NOTOK;
    }

    return gp_Read(theGraph, infileName);
}

int transformString(graphP theGraph, char *inputStr)
{
    if (inputStr == NULL || strlen(inputStr) == 0)
    {
        ErrorMessage("Input string is null or empty.\n");
        return NOTOK;
    }

    return gp_ReadFromString(theGraph, inputStr);
}
