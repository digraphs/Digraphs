/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include <ctype.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "../lowLevelUtils/appconst.h"
#include "strOrFile.h"

/********************************************************************
 sf_NewInputContainer()

 The string-or-file object supports two IO modes: reading input (ioMode ==
 READTEXT), and writing output (ioMode == WRITETEXT). The string-or-file object
 also may only contain a string (stored using a strBufP to leverage its string
 manipulation functions) XOR a FILE *.

 For the input mode, sf_NewInputContainer() should either receive a non-NULL and
 nonempty input string (which the container *does not own*, but rather copies
 into the internal strBufP) XOR a non-NULL and nonempty fileName (which may
 correspond to stdin).

 Returns the allocated string-or-file container, or NULL on error.
 ********************************************************************/

strOrFileP sf_NewInputContainer(char const *const inputStr, char const *const fileName)
{
    strOrFileP theStrOrFile;

    if (
        ((fileName != NULL) && (inputStr != NULL)) ||
        ((fileName == NULL) && (inputStr == NULL)))
        return NULL;

    theStrOrFile = (strOrFileP)calloc(1, sizeof(strOrFileStruct));
    if (theStrOrFile != NULL)
    {
        theStrOrFile->containerType = INPUT_CONTAINER;

        if (fileName != NULL)
        {
            // N.B. If the fileName indicates a stream, then input containers
            // may only contain stdin.
            if (strcmp(fileName, "stdin") == 0)
                theStrOrFile->pFile = stdin;
            else if (
                (strcmp(fileName, "stdout") == 0) ||
                (strcmp(fileName, "stderr") == 0))
            {
                sf_Free(&theStrOrFile);
                theStrOrFile = NULL;
                return NULL;
            }
            else
            {
                if ((theStrOrFile->pFile = fopen(fileName, READTEXT)) == NULL)
                {
                    sf_Free(&theStrOrFile);
                    theStrOrFile = NULL;
                    return NULL;
                }
            }
        }
        else
        {
            if ((theStrOrFile->theStrBuf = sb_New(0)) == NULL)
            {
                sf_Free(&theStrOrFile);
                theStrOrFile = NULL;
                return NULL;
            }
            if (
                (inputStr == NULL || (strlen(inputStr) == 0)) ||
                sb_ConcatString(theStrOrFile->theStrBuf, inputStr) != OK)
            {
                sf_Free(&theStrOrFile);
                theStrOrFile = NULL;
                return NULL;
            }
        }

        theStrOrFile->ungetBuf = sp_New(MAXLINE);
        if (theStrOrFile->ungetBuf == NULL)
        {
            sf_Free(&theStrOrFile);
            theStrOrFile = NULL;
            return NULL;
        }
    }

    return theStrOrFile;
}

/********************************************************************
 sf_NewOutputContainer()

 The string-or-file object supports two IO modes: reading input (ioMode ==
 READTEXT), and writing output (ioMode == WRITETEXT). The string-or-file object
 also may only contain a string (stored using a strBufP to leverage its string
 manipulation functions) XOR a FILE *.

 For the output mode, sf_NewOutputContainer() should receive either a non-NULL
 pointer-pointer that initially points to NULL (to which we will assign the
 output string upon freeing the container) XOR a non-NULL and nonempty fileName
 (which may correspond to stdout or stderr). If theStr is not NULL, then the
 desired output string will be constructed internally in the string-or-file
 object, which will only be returned to the caller when freeing the strOrFile
 via this pointer-pointer. Note that if the fileName is not NULL, then the
 internal
 strBufP will not be constructed.

 Returns the allocated string-or-file container, or NULL on error.
 ********************************************************************/

strOrFileP sf_NewOutputContainer(char **pOutputStr, char const *const fileName)
{
    strOrFileP theStrOrFile;

    if (
        ((fileName != NULL) && (pOutputStr != NULL)) ||
        ((fileName == NULL) && (pOutputStr == NULL)) ||
        ((pOutputStr != NULL) && ((*pOutputStr) != NULL)))
        return NULL;

    theStrOrFile = (strOrFileP)calloc(1, sizeof(strOrFileStruct));
    if (theStrOrFile != NULL)
    {
        theStrOrFile->containerType = OUTPUT_CONTAINER;

        if (fileName != NULL)
        {
            if (strcmp(fileName, "stdin") == 0)
            {
                sf_Free(&theStrOrFile);
                theStrOrFile = NULL;
                return NULL;
            }
            else if (strcmp(fileName, "stdout") == 0)
                theStrOrFile->pFile = stdout;
            else if (strcmp(fileName, "stderr") == 0)
                theStrOrFile->pFile = stderr;
            else
            {
                if (
                    (theStrOrFile->pFile = fopen(fileName, WRITETEXT)) == NULL)
                {
                    sf_Free(&theStrOrFile);
                    theStrOrFile = NULL;
                    return NULL;
                }
            }
        }
        else
        {
            if ((theStrOrFile->theStrBuf = sb_New(0)) == NULL)
            {
                sf_Free(&theStrOrFile);
                theStrOrFile = NULL;
                return NULL;
            }

            theStrOrFile->pOutputStr = pOutputStr;
        }
    }

    return theStrOrFile;
}

/********************************************************************
 sf_ValidateStrOrFile()

 Ensures that theStrOrFile:
 1. Is not NULL
 2. Has ungetBuf allocated
 3. Both pFile and theStrBuf are not NULL
 4. Both pFile and theStrBuf are not both assigned (since this container
    should only contain one source).
 5. containerType is either set to INPUT_CONTAINER or OUTPUT_CONTAINER

 Returns FALSE if any of these conditions are not met, otherwise TRUE.
 ********************************************************************/

int sf_IsValidStrOrFile(strOrFileP theStrOrFile)
{
    if (theStrOrFile == NULL ||
        (theStrOrFile->pFile == NULL && theStrOrFile->theStrBuf == NULL) ||
        (theStrOrFile->pFile != NULL && theStrOrFile->theStrBuf != NULL) ||
        (theStrOrFile->containerType != INPUT_CONTAINER &&
         theStrOrFile->containerType != OUTPUT_CONTAINER))
        return FALSE;

    if (theStrOrFile->containerType == INPUT_CONTAINER)
    {
        if (
            (theStrOrFile->ungetBuf == NULL) ||
            (theStrOrFile->theStrBuf != NULL && sb_GetSize(theStrOrFile->theStrBuf) == 0))

        {
            return FALSE;
        }
    }
    else // Otherwise, due to the above validation, can only be an output container
    {
        if (theStrOrFile->ungetBuf != NULL)
        {
            return FALSE;
        }
    }

    return TRUE;
}

/********************************************************************
 sf_getc()

 If strOrFileP has a non-empty ungetBuf, pop and return the character.
 If the ungetBuf is empty, then we'll read from pFile using getc() OR
 from theStrBuf by fetching the character at theStrPos and incrementing
 theStrPos.
 ********************************************************************/

char sf_getc(strOrFileP theStrOrFile)
{
    char theChar = EOF;

    if (!sf_IsValidStrOrFile(theStrOrFile) ||
        theStrOrFile->containerType != INPUT_CONTAINER)
        return EOF;

    if ((theStrOrFile->ungetBuf != NULL) && (sp_GetCurrentSize(theStrOrFile->ungetBuf) > 0))
    {
        int currChar = 0;
        // Technically, this returns NOTOK on error, but the error is underflow, which is
        // checked above and so cannot happen. Therefore, safe to use sp_Pop() here.

#ifndef DEBUG
        sp_Pop(theStrOrFile->ungetBuf, currChar);
#else
        // In DEBUG, MSVC cl is misreading the printf() generated by sp_Pop(),
        // so we cut to the underlying debug method to stop its warnings
        sp__Pop(theStrOrFile->ungetBuf, &(currChar));
#endif
        theChar = (char)currChar;
    }
    else if (theStrOrFile->pFile != NULL)
        theChar = (char)getc(theStrOrFile->pFile);
    else if (theStrOrFile->theStrBuf != NULL && sb_GetUnreadCharCount(theStrOrFile->theStrBuf) > 0)
    {
        theChar = sb_GetReadString(theStrOrFile->theStrBuf) != NULL
                      ? sb_GetReadString(theStrOrFile->theStrBuf)[0]
                      : EOF;
        if (theChar != EOF)
            sb_ReadSkipChar(theStrOrFile->theStrBuf);
    }

    return theChar;
}

/********************************************************************
 sf_ReadSkipChar()

 Calls sf_getc() and does nothing with the returned character
 ********************************************************************/

int sf_ReadSkipChar(strOrFileP theStrOrFile)
{
    if (!sf_IsValidStrOrFile(theStrOrFile) ||
        theStrOrFile->containerType != INPUT_CONTAINER)
        return NOTOK;

    if (sf_getc(theStrOrFile) == EOF)
        return NOTOK;

    return OK;
}

/********************************************************************
 sf_ReadSkipWhitespace()

 Repeatedly calls sf_getc() to find the next non-space character
 before hitting EOF
 ********************************************************************/

int sf_ReadSkipWhitespace(strOrFileP theStrOrFile)
{
    char currChar = EOF;

    if (!sf_IsValidStrOrFile(theStrOrFile) ||
        theStrOrFile->containerType != INPUT_CONTAINER)
        return NOTOK;

    while ((currChar = sf_getc(theStrOrFile)) != EOF && isspace(currChar))
    {
        continue;
    }

    if (sf_ungetc(currChar, theStrOrFile) != currChar)
        return NOTOK;

    return OK;
}

/********************************************************************
 sf_ReadSingleDigit()

 Calls sf_getc() and tests whether the character read corresponds to
 a digit.

 Returns NOTOK if the character returned from sf_getc() is not a digit.
 Assigns the digit read to the int * and returns OK upon success.
 ********************************************************************/

int sf_ReadSingleDigit(int *digitToRead, strOrFileP theStrOrFile)
{
    int candidateDigit = EOF;

    if (!sf_IsValidStrOrFile(theStrOrFile) ||
        theStrOrFile->containerType != INPUT_CONTAINER)
        return NOTOK;

    candidateDigit = sf_getc(theStrOrFile);
    if (!isdigit(candidateDigit))
        return NOTOK;

    // N.B. Subtract '0' = 48 to convert the digit
    // char to the corresponding int
    (*digitToRead) = candidateDigit - '0';
    return OK;
}

/********************************************************************
 sf_ReadInteger()

 Repeatedly calls sf_getc() to obtain the characters corresponding to
 an int, then parses that char* using sscanf() to extract the integer.

 Returns OK if successfully extracted the digits of and produced the
 int from theStrOrFile, or NOTOK otherwise.
 ********************************************************************/

int sf_ReadInteger(int *intToRead, strOrFileP theStrOrFile)
{
    int exitCode = OK;

    int intCandidate = 0, intCandidateIndex = 0;
    char currChar = '\0', nextChar = '\0';
    int startedReadingInt = FALSE, isNegative = FALSE;
    char intCandidateStr[MAXCHARSFOR32BITINT + 1];
    memset(intCandidateStr, '\0', (MAXCHARSFOR32BITINT + 1) * sizeof(char));

    if (!sf_IsValidStrOrFile(theStrOrFile) ||
        theStrOrFile->containerType != INPUT_CONTAINER)
        return NOTOK;

    do
    {
        currChar = sf_getc(theStrOrFile);
        if (currChar == '-')
        {
            if (startedReadingInt)
            {
                exitCode = NOTOK;
                break;
            }
            else
            {
                nextChar = sf_getc(theStrOrFile);
                if (sf_ungetc(nextChar, theStrOrFile) != nextChar)
                {
                    exitCode = NOTOK;
                    break;
                }

                if (!isdigit(nextChar))
                {
                    exitCode = NOTOK;
                    break;
                }
                else
                {
                    intCandidateStr[intCandidateIndex++] = currChar;
                    isNegative = TRUE;
                }
            }
        }
        else if (isdigit(currChar))
        {
            intCandidateStr[intCandidateIndex++] = currChar;
            startedReadingInt = TRUE;
        }
        else
        {
            if (sf_ungetc(currChar, theStrOrFile) != currChar)
                exitCode = NOTOK;
            break;
        }

        if (
            (!isNegative && (intCandidateIndex == (MAXCHARSFOR32BITINT - 2))) ||
            (isNegative && (intCandidateIndex == (MAXCHARSFOR32BITINT - 1))))
        {
            if (sscanf(intCandidateStr, "%d", &intCandidate) != 1)
                exitCode = NOTOK;
            else
            {
                nextChar = sf_getc(theStrOrFile);
                if (isdigit(nextChar))
                {
                    // N.B. The only way we could be here is if `i` is less than the max possible
                    // length of the string representation of a signed 32-bit integer (10 for
                    // positive and 11 for negative)
                    int underflowThreshold = (INT32_MIN / 10), overflowThreshold = (INT32_MAX / 10);
                    if (isNegative)
                    {
                        if (intCandidate < underflowThreshold)
                            exitCode = NOTOK;
                        else if (intCandidate == underflowThreshold && nextChar == '9')
                            exitCode = NOTOK;
                    }
                    else
                    {
                        if (intCandidate > overflowThreshold)
                            exitCode = NOTOK;
                        else if (intCandidate == overflowThreshold && (nextChar == '8' || nextChar == '9'))
                            exitCode = NOTOK;
                    }

                    if (exitCode == OK)
                    {
                        intCandidateStr[intCandidateIndex++] = nextChar;
                    }
                }
                else if (sf_ungetc(nextChar, theStrOrFile) != nextChar)
                    exitCode = NOTOK;
            }
            break;
        }
    } while (currChar != EOF);

    if (exitCode == OK)
    {
        if (sscanf(intCandidateStr, "%d", &intCandidate) != 1)
            exitCode = NOTOK;
        else
            (*intToRead) = intCandidate;
    }

    return exitCode;
}

/********************************************************************
 sf_ReadSkipInteger()

 Calls sf_ReadInteger() and discards the result.
 ********************************************************************/

int sf_ReadSkipInteger(strOrFileP theStrOrFile)
{
    int temp = 0;

    if (sf_ReadInteger(&temp, theStrOrFile) != OK)
        return NOTOK;

    return OK;
}

/********************************************************************
 sf_ReadSkipLineRemainder()

 Calls sf_fgets() and discards the result.
 ********************************************************************/

int sf_ReadSkipLineRemainder(strOrFileP theStrOrFile)
{
    char lineRemainderToSkip[MAXLINE + 1];
    memset(lineRemainderToSkip, '\0', (MAXLINE + 1));

    if (sf_fgets(lineRemainderToSkip, MAXLINE, theStrOrFile) == NULL)
        return NOTOK;

    return OK;
}

/********************************************************************
 sf_ungetc()

 Order of parameters matches stdio ungetc().

 For both the case where the strOrFile contains a FILE * and the case
 where it contains a strBufP, we unget to the ungetBuf; this ungetBuf
 is consumed first when we sf_getc(), sf_fgets(), etc.

 Like ungetc() in stdio, on success theChar is returned. On failure,
 EOF is returned.
 ********************************************************************/

char sf_ungetc(char theChar, strOrFileP theStrOrFile)
{
    if (theChar == EOF ||
        !sf_IsValidStrOrFile(theStrOrFile) ||
        theStrOrFile->containerType != INPUT_CONTAINER ||
        sp_GetCurrentSize(theStrOrFile->ungetBuf) >= sp_GetCapacity(theStrOrFile->ungetBuf))
        return EOF; // Acceptable downcast, allowing char rather than int return type

#ifndef DEBUG
    sp_Push(theStrOrFile->ungetBuf, theChar);
#else
    // In DEBUG, MSVC cl is misreading the printf() generated by sp_Push(),
    // so we cut to the underlying debug method to stop its warnings
    sp__Push(theStrOrFile->ungetBuf, theChar);
#endif

    return theChar;
}

/********************************************************************
 sf_ungets()

 Pushes characters of strToUnget in reverse order to the ungetBuf so
 that they can be fetched from the ungetBuf in the order of the
 original string.

 Returns OK on success and NOTOK on failure.
 ********************************************************************/

int sf_ungets(char *strToUnget, strOrFileP theStrOrFile)
{
    if (!sf_IsValidStrOrFile(theStrOrFile) ||
        theStrOrFile->containerType != INPUT_CONTAINER ||
        (int)strlen(strToUnget) > (sp_GetCapacity(theStrOrFile->ungetBuf) - sp_GetCurrentSize(theStrOrFile->ungetBuf)))
        return NOTOK;

    for (int i = (strlen(strToUnget) - 1); i >= 0; i--)
        sp_Push(theStrOrFile->ungetBuf, strToUnget[i]);

    return OK;
}

/********************************************************************
 sf_fgets()

 Order of parameters matches stdio fgets().

 First param is the string to populate (assumes allocated (count + 1)
 bytes), second param is the max number of characters to read, and
 third param is the pointer to the string-or-file container from which
 we wish to read count characters (or up to and including \n).

 Like fgets() in stdio, this function doesn't check that enough memory
 is allocated for str to contain count characters plus \0.

 Like fgets() in stdio, on success the pointer to the buffer is returned.
 On failure, NULL is returned.
 ********************************************************************/

char *sf_fgets(char *str, int count, strOrFileP theStrOrFile)
{
    int charsToReadFromUngetBuf = 0;
    int charsToReadFromStrOrFile = count;

    if (str == NULL || count < 0 ||
        !sf_IsValidStrOrFile(theStrOrFile) ||
        theStrOrFile->containerType != INPUT_CONTAINER)
        return NULL;

    if (theStrOrFile->ungetBuf != NULL)
    {
        int numCharsInUngetBuf = sp_GetCurrentSize(theStrOrFile->ungetBuf);
        if (numCharsInUngetBuf > 0)
        {
            char currChar = '\0';
            int encounteredNewline = FALSE;

            charsToReadFromUngetBuf = (count > numCharsInUngetBuf) ? numCharsInUngetBuf : count;
            for (int i = 0; i < charsToReadFromUngetBuf; i++)
            {
                currChar = sf_getc(theStrOrFile);
                if (currChar == EOF)
                    return NULL;
                str[i] = currChar;
                str[i + 1] = '\0';
                // N.B. fgets() includes the \n in the string returned, and
                // no further characters shall be read
                if (currChar == '\n')
                {
                    encounteredNewline = TRUE;
                    break;
                }
            }
            // N.B. If we broke out of the loop early due to \n, do not read
            // any further characters from stream
            charsToReadFromStrOrFile = (encounteredNewline) ? 0 : ((count > numCharsInUngetBuf) ? (count - charsToReadFromUngetBuf) : 0);
        }
    }

    if (charsToReadFromStrOrFile > 0)
    {
        if (theStrOrFile->pFile != NULL)
        {
            // N.B. if fgets() returns NULL (can't read more characters) AND the ungetBuf was empty,
            // then return NULL (error trying to read from empty stream). Otherwise, return str (that
            // was read from ungetBuf)
            if (fgets(str + charsToReadFromUngetBuf, charsToReadFromStrOrFile, theStrOrFile->pFile) == NULL)
            {
                if (charsToReadFromUngetBuf == 0)
                    return NULL;
            }
        }
        else if (theStrOrFile->theStrBuf != NULL)
        {
            char *theStrBuf = sb_GetReadString(theStrOrFile->theStrBuf);
            if (theStrBuf != NULL && sb_GetUnreadCharCount(theStrOrFile->theStrBuf) > 0)
            {
                if (strncpy(
                        str + charsToReadFromUngetBuf,
                        theStrBuf,
                        charsToReadFromStrOrFile) == NULL)
                    return NULL;

                sb_SetReadPos(theStrOrFile->theStrBuf, (sb_GetReadPos(theStrOrFile->theStrBuf) + charsToReadFromStrOrFile));
            }
            else if (charsToReadFromUngetBuf == 0)
                return NULL;
        }
    }

    return str;
}

/********************************************************************
 sf_fputs()

 Order of parameters matches stdio fputs().

 First param is the string to append, and the second param is the
 string-or-file container to which we wish to append.

 On success, returns the number of characters written.
 On failure, returns EOF.
 ********************************************************************/

int sf_fputs(char const *strToWrite, strOrFileP theStrOrFile)
{
    int outputLen = EOF;

    if (strToWrite == NULL ||
        !sf_IsValidStrOrFile(theStrOrFile) ||
        theStrOrFile->containerType != OUTPUT_CONTAINER)
        return EOF;

    // N.B. fputs() will fail and return EOF if pFile doesn't correspond
    // to an output stream
    if (theStrOrFile->pFile != NULL)
        outputLen = fputs(strToWrite, theStrOrFile->pFile);
    else if (theStrOrFile->theStrBuf != NULL)
    {
        if (sb_ConcatString(theStrOrFile->theStrBuf, strToWrite) == OK)
            outputLen = strlen(strToWrite);
        else
            outputLen = EOF;
    }

    return outputLen;
}

/********************************************************************
 sf_closeFile()

 If the strOrFile container contains a string, degenerately returns OK.

 If the strOrFile container contains a FILE pointer:
   - if the FILE pointer is one of stdin, stdout, or stderr, calls
   fflush() on the stream and captures the errorCode
   - else, closes pFile and sets the internal pointer to NULL, then
   captures the errorCode from fclose()
 If the errorCode is less than 0, returns NOTOK, otherwise returns OK.
 ********************************************************************/

int sf_closeFile(strOrFileP theStrOrFile)
{
    FILE *pFile = theStrOrFile->pFile;
    theStrOrFile->pFile = NULL;
    if (pFile != NULL)
    {
        int errorCode = 0;

        if (pFile == stdin || pFile == stdout || pFile == stderr)
            errorCode = fflush(pFile);
        else
            errorCode = fclose(pFile);

        if (errorCode < 0)
            return NOTOK;
    }

    sp_Free(&(theStrOrFile->ungetBuf));

    return OK;
}

/********************************************************************
 sf_Free()

 Receives a pointer-pointer to a string-or-file container.

 If the strOrFile contains a string which has not yet been "taken"
 using sf_takeTheStr() (i.e. we want inputStr to be freed, and in an
 error state we want to free pOutputStr), the string is freed, the
 internal pointer is set to NULL, and theStrPos is set to 0.

 If the strOrFile contains a FILE pointer, we call sf_closeFile()
 and set the internal pointer to NULL. Note that unless we are in an
 error state when sf_Free() is called, sf_closeFile should have already
 been called.

 Finally, we use the indirection operator to free the strOrFile
 container and set the pointer to NULL.
 ********************************************************************/

void sf_Free(strOrFileP *pStrOrFile)
{
    if (pStrOrFile != NULL && (*pStrOrFile) != NULL)
    {
        if ((*pStrOrFile)->theStrBuf != NULL)
        {
            // TODO: (#56) If in an error state, just don't sb_TakeString()
            // before freeing it
            if ((*pStrOrFile)->pOutputStr != NULL)
            {
                (*((*pStrOrFile)->pOutputStr)) = sb_TakeString((*pStrOrFile)->theStrBuf);
                (*pStrOrFile)->pOutputStr = NULL;
            }
            sb_Free(&((*pStrOrFile)->theStrBuf));
        }

        // TODO: (#56) if the strOrFile container's FILE pointer
        // corresponds to an output file, i.e. ioMode is 'w',
        // we should try to remove the file since the error state
        // means the contents are invalid
        if ((*pStrOrFile)->pFile != NULL)
            sf_closeFile((*pStrOrFile));
        (*pStrOrFile)->pFile = NULL;

        if ((*pStrOrFile)->ungetBuf != NULL)
        {
            sp_Free(&((*pStrOrFile)->ungetBuf));
        }
        (*pStrOrFile)->ungetBuf = NULL;

        free(*pStrOrFile);
        (*pStrOrFile) = NULL;
    }
}
