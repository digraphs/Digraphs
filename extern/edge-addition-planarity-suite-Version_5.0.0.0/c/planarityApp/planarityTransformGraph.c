/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "planarity.h"

int transformFile(graphP theGraph, char const *infileName);
int transformString(graphP theGraph, char *inputStr);

/****************************************************************************
 TransformGraph()
 commandString - command to run; i.e. `-(gam)` to transform graph to .g6, adjacency list, or
 adjacency matrix format
 infileName - name of file to read, or NULL to cause the program to prompt the user for a file name
 inputStr - string containing input graph, or NULL to cause the program to fall back on reading from file
 outputBase - pointer to the flag set for whether output is 0- or 1-based
 outputFormat - output format
 outfileName - name of primary output file, or NULL to construct an output file name based on the input
 pOutputStr - pointer to string which we wish to use to store the transformation output
 ****************************************************************************/
int TransformGraph(char const *const commandString, char const *const infileName, char *inputStr, int *outputBase, char const *outfileName, char **pOutputStr)
{
    int Result = OK;

    int outputFormat = -1;

    graphP theGraph = NULL;

    theGraph = gp_New();

    if (theGraph == NULL)
    {
        gp_ErrorMessage("Unable to allocate graphP for input graph "
                        "transformation target.");
        return NOTOK;
    }

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
            gp_ErrorMessage("Invalid argument; only -(gam) is allowed.");
            gp_Free(&theGraph);
            return NOTOK;
        }

        if (inputStr)
            Result = transformString(theGraph, inputStr);
        else
            Result = transformFile(theGraph, infileName);

        if (Result != OK)
        {
            gp_ErrorMessage("Unable to transform input graph.");
        }
        else
        {
            // Want to know whether the output is 0- or 1-based; will always be
            // 0-based for transformations of .g6 input
            if (outputBase != NULL)
                (*outputBase) = (gp_GetGraphFlags(theGraph) & GRAPHFLAGS_ZEROBASEDIO) ? 1 : 0;

            if (pOutputStr != NULL)
                Result = gp_WriteToString(theGraph, pOutputStr, outputFormat);
            else
                Result = gp_Write(theGraph, outfileName, outputFormat);

            if (Result != OK)
                gp_ErrorMessage("Unable to write graph.");
        }
    }
    else
    {
        gp_ErrorMessage("Invalid argument; must start with '-'.");
        Result = NOTOK;
    }

    gp_Free(&theGraph);

    return Result;
}

int transformFile(graphP theGraph, char const *infileName)
{
    if (infileName == NULL)
    {
        if ((infileName = ConstructInputFileName(infileName)) == NULL)
        {
            gp_ErrorMessage("Unable to construct input file name for graph to "
                            "transform.");
            return NOTOK;
        }
    }

    return gp_Read(theGraph, infileName);
}

int transformString(graphP theGraph, char *inputStr)
{
    if (inputStr == NULL || strlen(inputStr) == 0)
    {
        gp_ErrorMessage("Input string is null or empty.");
        return NOTOK;
    }

    return gp_ReadFromString(theGraph, inputStr);
}
