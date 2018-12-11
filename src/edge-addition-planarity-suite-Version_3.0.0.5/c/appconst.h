#ifndef APPCONST_H
#define APPCONST_H

/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

// When PROFILE is defined, prints out run-time stats on a number of subordinate
// routines in the embedder

//#define PROFILE
#ifdef PROFILE
#include "platformTime.h"
#endif

/* Define DEBUG to get additional debugging. The default is to define it when MSC does */

#ifdef _DEBUG
#define DEBUG
#endif

/* Some low-level functions are replaced by faster macros, except when debugging */

#define SPEED_MACROS
#ifdef DEBUG
#undef SPEED_MACROS
#endif

/* Return status values; OK/NOTOK behave like Boolean true/false,
   not like program exit codes. */

#define OK              1
#define NOTOK           0

#ifdef DEBUG
#undef NOTOK
extern int debugNOTOK();
#include <stdio.h>
#define NOTOK           (printf("NOTOK on Line %d of %s\n", __LINE__, __FILE__), debugNOTOK())
#endif

#ifndef TRUE
#define TRUE            1
#endif

#ifndef FALSE
#define FALSE           0
#endif

#ifndef NULL
#define NULL			0L
#endif

/* Array indices are used as pointers, and NIL means bad pointer */

// This definition is used with 1-based array indexing
#define NIL			0
#define NIL_CHAR	0x00

// This definition is used in combination with 0-based array indexing
//#define NIL		-1
//#define NIL_CHAR	0xFF

/* Defines fopen strings for reading and writing text files on PC and UNIX */

#ifdef WINDOWS
#define READTEXT        "rt"
#define WRITETEXT       "wt"
#else
#define READTEXT        "r"
#define WRITETEXT       "w"
#endif

/********************************************************************
 A few simple integer selection macros
 ********************************************************************/

#define MIN(x, y) ((x) < (y) ? (x) : (y))
#define MAX(x, y) ((x) > (y) ? (x) : (y))

#define MIN3(x, y, z) MIN(MIN((x), (y)), MIN((y), (z)))
#define MAX3(x, y, z) MAX(MAX((x), (y)), MAX((y), (z)))

#endif
