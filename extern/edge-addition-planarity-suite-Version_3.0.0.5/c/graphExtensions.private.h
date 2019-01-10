#ifndef GRAPH_EXTENSIONS_PRIVATE_H
#define GRAPH_EXTENSIONS_PRIVATE_H

/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "graphFunctionTable.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
    int  moduleID;
    void *context;
    void *(*dupContext)(void *, void *);
    void (*freeContext)(void *);

    graphFunctionTableP functions;

    struct graphExtension *next;
} graphExtension;

typedef graphExtension * graphExtensionP;

#ifdef __cplusplus
}
#endif

#endif
