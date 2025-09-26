/*
Copyright (c) 1997-2025, John M. Boyer
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

    if (argc <= 1)
        retVal = menu();

    else if (argv[1][0] == '-')
        retVal = commandLine(argc, argv);

    else
        retVal = legacyCommandLine(argc, argv);

    // Close the log file if logging
    gp_Log(NULL);

    return retVal;
}
