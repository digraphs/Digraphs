/*
Copyright (c) 1997-2026, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "planarity.h"

/****************************************************************************
 MAIN
 ****************************************************************************/

int main(int argc, char *argv[])
{
    int retVal = 0;

    // Although the graphLib is quiet by default, this planarity app is only quiet if
    // the user requests quiet mode on the command line
    gp_SetQuietMode(QUIETMODE_NONE);

    // If there are no command-line arguments, then the planarity app enters menu mode
    if (argc <= 1)
        retVal = menu();

    // If there are command-line arguments that start with hyphens, then
    // we enter command-line mode
    else if (argv[1][0] == '-')
        retVal = commandLine(argc, argv);

    // If there are command-line arguments not starting with a hyphen, then
    // we enter a very old backward compatibility command-line mode
    else
        retVal = legacyCommandLine(argc, argv);

    return retVal;
}
