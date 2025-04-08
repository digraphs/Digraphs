/*
Copyright (c) 1997-2025, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#ifndef STR_OR_FILE_H
#define STR_OR_FILE_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdio.h>

#include "../lowLevelUtils/stack.h"
#include "strbuf.h"

#define INPUT_CONTAINER 1
#define OUTPUT_CONTAINER 2
    typedef struct
    {
        strBufP theStr;
        FILE *pFile;
        int containerType;
        stackP ungetBuf;

    } strOrFile;

    typedef strOrFile *strOrFileP;

    strOrFileP sf_New(char *theStr, char *fileName, char *ioMode);
    int sf_ValidateStrOrFile(strOrFileP theStrOrFile);

    char sf_getc(strOrFileP theStrOrFile);
    int sf_ReadSkipChar(strOrFileP theStrOrFile);
    int sf_ReadSkipWhitespace(strOrFileP theStrOrFile);
    int sf_ReadSingleDigit(int *digitToRead, strOrFileP theStrOrFile);
    int sf_ReadInteger(int *intToRead, strOrFileP theStrOrFile);
    int sf_ReadSkipInteger(strOrFileP theStrOrFile);
    int sf_ReadSkipLineRemainder(strOrFileP theStrOrFile);

    char sf_ungetc(char theChar, strOrFileP theStrOrFile);
    int sf_ungets(char *contentsToUnget, strOrFileP theStrOrFile);

    char *sf_fgets(char *str, int count, strOrFileP theStrOrFile);

    int sf_fputs(char *strToWrite, strOrFileP theStrOrFile);

    char *sf_takeTheStr(strOrFileP theStrOrFile);

    int sf_closeFile(strOrFileP theStrOrFile);

    void sf_Free(strOrFileP *pStrOrFile);

#ifdef __cplusplus
}
#endif

#endif /* STR_OR_FILE_H */
