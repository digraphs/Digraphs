#ifndef HELPERSTUB_GRAPHLIB_H
#define HELPERSTUB_GRAPHLIB_H

/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

// NOTE: This helper stub has been added to make it easier for downstream
// consumers to obtain access to all features in the graph library of
// the planarity project.

#ifdef __cplusplus
extern "C"
{
#endif

// The "c" directory appears in this include directive because this
// header file gets installed into the root of the planarity headers
// directory, so the directive must first enter the "c" subdirectory.
#include "c/graphLib/graphLib.h"

#ifdef __cplusplus
}
#endif

#endif
