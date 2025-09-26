#ifndef GRAPHLIB_H
#define GRAPHLIB_H

/*
Copyright (c) 1997-2025, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#ifdef __cplusplus
extern "C"
{
#endif

#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>

#include "graph.h"

#include "lowLevelUtils/platformTime.h"

#include "homeomorphSearch/graphK23Search.h"
#include "homeomorphSearch/graphK33Search.h"
#include "homeomorphSearch/graphK4Search.h"
#include "planarityRelated/graphDrawPlanar.h"

    // This is the main location for the project and shared library version numbering.
    // Changes here must be mirrored in configure.ac
    //
    // The overall project version numbering format is major.minor.maintenance.tweak
    // Major is for an overhaul (e.g. many features, data structure change, change of backward compatibility)
    // Minor is for feature addition (e.g. a new algorithm implementation added, new interface)
    // Maintenance is for functional revision (e.g. bug fix to existing algorithm implementation)
    // Tweak is for a non-functional revision (e.g. change of build scripts or testing code, user-facing string changes)

#define GP_PROJECTVERSION_MAJOR 4
#define GP_PROJECTVERSION_MINOR 0
#define GP_PROJECTVERSION_MAINT 0
#define GP_PROJECTVERSION_TWEAK 0

    char *gp_GetProjectVersionFull(void);

// Any change to the project version numbers should also affect the
// shared library version numbers below.
//
// See configure.ac for how to update these version numbers
#define GP_LIBPLANARITYVERSION_CURRENT 2
#define GP_LIBPLANARITYVERSION_REVISION 0
#define GP_LIBPLANARITYVERSION_AGE 0

    char *gp_GetLibPlanarityVersionFull(void);

#ifdef __cplusplus
}
#endif

#endif