/*
Copyright (c) 1997-2025, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#ifndef STRBUF_H
#define STRBUF_H

#ifdef __cplusplus
extern "C"
{
#endif

// includes mem functions like memcpy
#include <string.h>

        typedef struct
        {
                char *buf;
                int size, capacity, readPos;
        } strBuf;

        typedef strBuf *strBufP;

        strBufP sb_New(int);
        void sb_Free(strBufP *);

        void sb_ClearBuf(strBufP);
        int sb_Copy(strBufP, strBufP);
        strBufP sb_Duplicate(strBufP);

#define sb_GetFullString(theStrBuf) (theStrBuf->buf)
#define sb_GetSize(theStrBuf) (theStrBuf->size)
#define sb_GetCapacity(theStrBuf) (theStrBuf->capacity)
#define sb_GetUnreadCharCount(theStrBuf) (theStrBuf->size - theStrBuf->readPos)
#define sb_GetReadString(theStrBuf) ((theStrBuf != NULL && theStrBuf->buf != NULL) ? (theStrBuf->buf + theStrBuf->readPos) : NULL)

#define sb_GetReadPos(theStrBuf) (theStrBuf->readPos)
#define sb_SetReadPos(theStrBuf, theReadPos)     \
        {                                        \
                theStrBuf->readPos = theReadPos; \
        }

        void sb_ReadSkipWhitespace(strBufP);
        void sb_ReadSkipInteger(strBufP);
#define sb_ReadSkipChar(theStrBuf)    \
        {                             \
                theStrBuf->readPos++; \
        }

        int sb_ConcatString(strBufP, char *);
        int sb_ConcatChar(strBufP, char);

        char *sb_TakeString(strBufP);

#ifndef SPEED_MACROS
// Optimized SPEED_MACROS versions of larger methods are not used in this module
#else
// Optimized SPEED_MACROS versions of larger methods are not used in this module
#endif

#ifdef __cplusplus
}
#endif

#endif /* STRBUF_H */
