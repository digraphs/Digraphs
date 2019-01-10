#ifndef PLATFORM_TIME
#define PLATFORM_TIME

/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#ifdef WIN32

#include <windows.h>
#include <winbase.h>

#define platform_time DWORD
#define platform_GetTime(timeVar) (timeVar = GetTickCount())
#define platform_GetDuration(startTime, endTime) ((double) (endTime-startTime) / 1000.0)

#else

#include <time.h>

typedef struct {
	clock_t hiresTime;
	time_t lowresTime;
} platform_time;

#define platform_GetTime(timeVar) (timeVar.hiresTime = clock(), timeVar.lowresTime = time(NULL))

// Many flavors of Unix have CLOCKS_PER_SEC at 1 million, and clock_t as a 4 byte long integer
// which means that the clock() construct has a resolution of only about 2000 seconds
// If we're getting a duration longer than that, then we fall back to the coarser time() measure

#define platform_GetDuration(startTime, endTime) ( \
		( (double) (endTime.lowresTime - startTime.lowresTime) ) > 2000 ? \
		( (double) (endTime.lowresTime - startTime.lowresTime) ) : \
		( (double) (endTime.hiresTime - startTime.hiresTime)) / CLOCKS_PER_SEC)

/*
#define platform_time clock_t
#define platform_GetTime() clock()
#define platform_GetDuration(startTime, endTime) (((double) (endTime - startTime)) / CLOCKS_PER_SEC)
*/

/*
#define platform_time time_t
#define platform_GetTime() time((time_t *)NULL)
#define platform_GetDuration(startTime, endTime) ((double) (endTime - startTime))
*/

#endif

#endif
