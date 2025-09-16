/*
Copyright (c) 1997-2025, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#ifndef G6_API_UTILITIES
#define G6_API_UTILITIES

#ifdef __cplusplus
extern "C"
{
#endif

    int _getMaxEdgeCount(int);
    int _getNumCharsForGraphEncoding(int);
    int _getNumCharsForGraphOrder(int);
    int _getExpectedNumPaddingZeroes(const int, const int);

#ifdef __cplusplus
}
#endif

#endif /* G6_API_UTILITIES */
