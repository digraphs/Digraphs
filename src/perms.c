/*******************************************************************************
**
*A  perms.c                     GAP package Digraphs          Julius Jonusas
**                                                            James Mitchell
**                                                            Wilf A. Wilson
**                                                            Michael Young
**
**  Copyright (C) 2014-15 - Julius Jonusas, James Mitchell, Wilf A. Wilson,
**  Michael Young
**
**  This file is free software, see the digraphs/LICENSE.
**
*******************************************************************************/

#include "perms.h"

// Digraphs package headers
#include "digraphs-debug.h"  // for DIGRAPHS_ASSERT
#include "gap-includes.h"    // for ErrorQuit, ADDR_PERM2, ..
#include "safemalloc.h"      // for safe_malloc

Perm new_perm(uint16_t const degree) {
  DIGRAPHS_ASSERT(degree <= MAXVERTS);
  return safe_malloc(degree * sizeof(uint16_t));
}

Perm new_perm_from_gap(Obj gap_perm_obj, uint16_t const degree) {
  Perm p = new_perm(degree > 0 ? degree : 1);

  size_t copy_up_to = degree;
  size_t lmp        = LargestMovedPointPerm(gap_perm_obj);
  if (degree > lmp) {
    copy_up_to = lmp;
  }

  if (IS_PERM2(gap_perm_obj)) {
    UInt2* gap_perm_ptr = ADDR_PERM2(gap_perm_obj);
    for (UInt i = 0; i < copy_up_to; ++i) {
      p[i] = gap_perm_ptr[i];
    }
    for (UInt i = copy_up_to; i < degree; ++i) {
      p[i] = i;
    }
  } else {
    DIGRAPHS_ASSERT(IS_PERM4(gap_perm_obj));
    UInt4* gap_perm_ptr = ADDR_PERM4(gap_perm_obj);
    for (UInt i = 0; i < copy_up_to; ++i) {
      p[i] = gap_perm_ptr[i];
    }
    for (UInt i = copy_up_to; i < degree; ++i) {
      p[i] = i;
    }
  }
  return p;
}

PermColl* new_perm_coll(uint16_t const capacity, uint16_t const degree) {
  PermColl* coll = safe_malloc(sizeof(PermColl));
  coll->perms    = safe_malloc(capacity * sizeof(Perm));
  for (uint16_t i = 0; i < capacity; ++i) {
    coll->perms[i] = new_perm(degree);
  }
  coll->size     = 0;
  coll->degree   = degree;
  coll->capacity = capacity;
  return coll;
}

void free_perm_coll(PermColl* coll) {
  for (uint16_t i = 0; i < coll->capacity; i++) {
    free(coll->perms[i]);
  }
  free(coll->perms);
  free(coll);
}
