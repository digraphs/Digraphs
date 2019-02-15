/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#ifndef STACK_H
#define STACK_H

#ifdef __cplusplus
extern "C" {
#endif

// includes mem functions like memcpy
#include <string.h>

typedef struct
{
        int *S;
        int size, capacity;
} stack;

typedef stack * stackP;

stackP sp_New(int);
void sp_Free(stackP *);

int  sp_Copy(stackP, stackP);

int  sp_CopyContent(stackP stackDst, stackP stackSrc);
stackP sp_Duplicate(stackP theStack);

#define sp_GetCapacity(theStack) (theStack->capacity)

#ifndef SPEED_MACROS

int  sp_ClearStack(stackP);
int  sp_GetCurrentSize(stackP theStack);
int  sp_SetCurrentSize(stackP theStack, int top);

int  sp_IsEmpty(stackP);
int  sp_NonEmpty(stackP);

#define sp_Push(theStack, a) { if (sp__Push(theStack, (a)) != OK) return NOTOK; }
#define sp_Push2(theStack, a, b) { if (sp__Push2(theStack, (a), (b)) != OK) return NOTOK; }

int  sp__Push(stackP, int);
int  sp__Push2(stackP, int, int);

#define sp_Pop(theStack, a) { if (sp__Pop(theStack, &(a)) != OK) return NOTOK; }
#define sp_Pop2(theStack, a, b) { if (sp__Pop2(theStack, &(a), &(b)) != OK) return NOTOK; }

int  sp__Pop(stackP, int *);
int  sp__Pop2(stackP, int *, int *);

int  sp_Top(stackP);
int  sp_Get(stackP, int);
int  sp_Set(stackP, int, int);

#else

#define sp_ClearStack(theStack) theStack->size=0
#define sp_GetCurrentSize(theStack) (theStack->size)
#define sp_SetCurrentSize(theStack, Size) ((Size) > theStack->capacity ? NOTOK : (theStack->size = (Size), OK))

#define sp_IsEmpty(theStack) !theStack->size
#define sp_NonEmpty(theStack) theStack->size

#define sp_Push(theStack, a) theStack->S[theStack->size++] = a
#define sp_Push2(theStack, a, b) {sp_Push(theStack, a); sp_Push(theStack, b);}

#define sp_Pop(theStack, a) a=theStack->S[--theStack->size]
#define sp_Pop2(theStack, a, b) {sp_Pop(theStack, b);sp_Pop(theStack, a);}

#define sp_Top(theStack) (theStack->size ? theStack->S[theStack->size-1] : NIL)
#define sp_Get(theStack, pos) (theStack->S[pos])
#define sp_Set(theStack, pos, val) (theStack->S[pos] = val)

#endif

#ifdef __cplusplus
}
#endif

#endif
