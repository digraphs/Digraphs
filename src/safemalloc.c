/********************************************************************************
**
*A  safemalloc.c              Safer memory allocation
**
**
**  Copyright (C) 2024 - Daniel Pointon, J. D. Mitchell
**
**  This file is free software, see the digraphs/LICENSE.
**
********************************************************************************/

#include "safemalloc.h"

#include <stdlib.h>  // for malloc

#include "gap-includes.h"

void* safe_malloc(size_t size) {
  void* allocation = malloc(size);
  if (allocation == NULL) {
    ErrorQuit("Call to malloc(%d) failed, giving up!", (Int) size, 0L);
  }
  return allocation;
}

void* safe_calloc(size_t nitems, size_t size) {
  void* allocation = calloc(nitems, size);
  if (allocation == NULL) {
    ErrorQuit(
        "Call to calloc(%d, %d) failed, giving up!", (Int) nitems, (Int) size);
  }

  return allocation;
}
