/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "graphLib.h"

#include <stdlib.h>

/********************************************************************
 gp_GetProjectVersionFull()
 Return full major.minor.maint.tweak version string for the graph planarity project
 ********************************************************************/

const char *gp_GetProjectVersionFull(void)
{
    static char projectVersionStr[MAXLINE + 1];
    sprintf(projectVersionStr, "%d.%d.%d.%d",
            GP_PROJECTVERSION_MAJOR,
            GP_PROJECTVERSION_MINOR,
            GP_PROJECTVERSION_MAINT,
            GP_PROJECTVERSION_TWEAK);
    return projectVersionStr;
}

/********************************************************************
 gp_GetLibPlanarityVersionFull()
 Returns full current:revision:age version string for the graph planarity shared library
 ********************************************************************/

const char *gp_GetLibPlanarityVersionFull(void)
{
    static char libPlanarityVersionStr[MAXLINE + 1];
    sprintf(libPlanarityVersionStr, "%d:%d:%d",
            GP_LIBPLANARITYVERSION_CURRENT,
            GP_LIBPLANARITYVERSION_REVISION,
            GP_LIBPLANARITYVERSION_AGE);
    return libPlanarityVersionStr;
}
