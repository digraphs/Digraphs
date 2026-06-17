#ifndef PLANARITY_H
#define PLANARITY_H

/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#ifdef __cplusplus
extern "C"
{
#endif

#include "../graphLib/graphLib.h"

#include "platformTime.h"

#define FILENAMEMAXLENGTH 128
#define ALGORITHMNAMEMAXLENGTH 32
#define SUFFIXMAXLENGTH 32
#define COMMANDSTRINGMAXLENGTH 2

#define YESNOCHOICECHARS "yYnN"

    char const *GetProjectTitle(void);
    char const *GetAlgorithmFlags(void);
    char const *GetAlgorithmSpecifiers(void);
    char const *GetAlgorithmChoices(void);
    char const *GetSupportedOutputChoices(void);
    char const *GetSupportedOutputFormats(void);

    int helpMessage(char *param);

    /* Functions that call the Graph Library */
    int SpecificGraph(
        char const *const commandString,
        char const *infileName, char *outfileName, char *outfile2Name,
        char *inputStr, char **pOutputStr, char **pOutput2Str);
    int RandomGraph(char const *const commandString, int extraEdges, int numVertices, char *outfileName, char *outfile2Name);
    int RandomGraphs(char const *const commandString, int NumGraphs, int SizeOfGraphs, char *outfileName);
    int TransformGraph(char const *const commandString, char const *const infileName, char *inputStr, int *outputBase, char const *outfileName, char **pOutputStr);
    int TestAllGraphs(char const *const commandString, char const *const infileName, char *outfileName, char **pOutputStr);

    /* Command line, Menu, and Configuration */
    int menu(void);
    int commandLine(int argc, char *argv[]);
    int legacyCommandLine(int argc, char *argv[]);

    extern char Mode,
        OrigOut,
        OrigOutFormat,
        EmbeddableOut,
        ObstructedOut,
        AdjListsForEmbeddingsOut;

    int Reconfigure(void);

    /* Low-level Utilities */
    int GetLineFromStdin(char *lineBuff, int lineBuffSize);
    void FlushConsole(FILE *f);

    void SaveAsciiGraph(graphP theGraph, char *fileName);

    char *ReadTextFileIntoString(char const *infileName);
    int TextFileMatchesString(char const *theFileName, char const *theString);
    int TextFilesEqual(char *file1Name, char *file2Name);
    int BinaryFilesEqual(char *file1Name, char *file2Name);

    int GetCommandAndOptionalModifier(const char *commandString, char *command, char *modifier);
    int GetEmbedFlags(char command, char modifier, int *embedFlags);

    char const *GetAlgorithmName(char command);

    char const *GetTransformationName(char command);
    char const *GetBaseName(int baseFlag);

    int ExtendGraph(graphP theGraph, char command);

    char *ConstructInputFileName(char const *infileName);

    char *ConstructPrimaryOutputFileName(char const *infileName, char const *outfileName, char command);

    int ConstructTransformationExpectedResultFileName(char const *infileName, char **outfileName, char command, int actualOrExpectedFlag);
    void WriteAlgorithmResults(graphP theGraph, int Result, char command, platform_time start, platform_time end, char const *infileName);

    int GetNumCharsToReprInt(int theNum, int *numCharsRequired);

#ifdef __cplusplus
}
#endif

#endif
