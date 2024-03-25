/********************************************************************************
**
*A  safemalloc.h              Safer memory allocation
**
**
**  Copyright (C) 2024 - Daniel Pointon, J. D. Mitchell
**
**  This file is free software, see the digraphs/LICENSE.
**
********************************************************************************/

#ifndef DIGRAPHS_SRC_SAFEMALLOC_H_
#define DIGRAPHS_SRC_SAFEMALLOC_H_

#include <stdlib.h>
#include "digraphs-debug.h"

void* safe_malloc(size_t size);
void* safe_calloc(size_t nitems, size_t size);

#endif  // DIGRAPHS_SRC_SAFEMALLOC_H_

