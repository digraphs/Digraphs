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

// C headers
#include <stdlib.h>  // for malloc, . . .

// Digraphs package headers
#include "digraphs-debug.h"  // for DIGRAPHS_ASSERT

Perm new_perm(uint16_t const degree) {
  DIGRAPHS_ASSERT(degree <= MACHINE_MAXVERTS);
  return malloc(degree * sizeof(uint16_t));
}

Perm new_perm_from_gap(Obj gap_perm_obj, uint16_t const degree) {
  UInt lmp = LargestMovedPointPerm(gap_perm_obj);
  DIGRAPHS_ASSERT(lmp <= MACHINE_MAXVERTS);
  if (lmp > MACHINE_MAXVERTS) {
    ErrorQuit("expected permutations of degree at most %d, but got a "
              "permutation of degree %d",
              MACHINE_MAXVERTS,
              lmp);
  }

  DIGRAPHS_ASSERT(lmp <= degree);

  Perm p = new_perm(degree > 0 ? degree : 1);

  if (IS_PERM2(gap_perm_obj)) {
    UInt2* gap_perm_ptr = ADDR_PERM2(gap_perm_obj);
    for (UInt i = 0; i < lmp; ++i) {
      p[i] = gap_perm_ptr[i];
    }
    for (UInt i = lmp; i < degree; ++i) {
      p[i] = i;
    }
  } else {
    DIGRAPHS_ASSERT(IS_PERM4(gap_perm_obj));
    UInt4* gap_perm_ptr = ADDR_PERM4(gap_perm_obj);
    for (UInt i = 0; i < lmp; ++i) {
      p[i] = gap_perm_ptr[i];
    }
    for (UInt i = lmp; i < degree; ++i) {
      p[i] = i;
    }
  }
  return p;
}

PermColl* new_perm_coll(uint16_t const capacity, uint16_t const degree) {
  PermColl* coll = malloc(sizeof(PermColl));
  coll->perms    = malloc(capacity * sizeof(Perm));
  for (uint16_t i = 0; i < capacity; ++i) {
    coll->perms[i] = new_perm(degree);
  }
  coll->size     = 0;
  coll->degree   = degree;
  coll->capacity = capacity;
  return coll;
}

void free_perm_coll(PermColl* coll) {
  for (uint16_t i = 0; i < coll->size; i++) {
    free(coll->perms[i]);
  }
  free(coll->perms);
  free(coll);
}
