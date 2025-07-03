/*
Copyright (c) 1997-2025, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include <limits.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdlib.h>

#include "apiutils.h"
#include "appconst.h"

int quietMode = FALSE;

int getQuietModeSetting(void)
{
    return quietMode;
}

void setQuietModeSetting(int newQuietModeSetting)
{
    quietMode = newQuietModeSetting;
}

void Message(char *message)
{
    if (!getQuietModeSetting())
    {
        fprintf(stdout, "%s", message);
        fflush(stdout);
    }
}

void ErrorMessage(char *message)
{
    if (!getQuietModeSetting())
    {
        fprintf(stderr, "%s", message);
        fflush(stderr);
    }
}

int GetNumCharsToReprInt(int theNum, int *numCharsRequired)
{
    if (numCharsRequired == NULL)
        return NOTOK;

    int charCount = 0;

    if (theNum < 0)
    {
        charCount++;
        // N.B. since 32-bit signed integers are represented using twos-complement,
        // the absolute value of INT_MIN is not defined; however, adding 1 to this
        // min value before taking the absolute value will still require the same
        // number of digits.
        if ((theNum == INT_MIN) || (theNum == INT8_MAX) || (theNum == INT16_MIN) || (theNum == INT32_MIN))
            theNum++;
        theNum = abs(theNum);
    }

    while (theNum > 0)
    {
        theNum /= 10;
        charCount++;
    }

    (*numCharsRequired) = charCount;

    return OK;
}
