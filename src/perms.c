/*******************************************************************************
**
*A  perms.c                     GAP package Digraphs          Julius Jonusas
**                                                            James Mitchell
**                                                            Michael Torpey
**                                                            Wilf A. Wilson
**
**  Copyright (C) 2014-15 - Julius Jonusas, James Mitchell, Michael Torpey,
**  Wilf A. Wilson
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
  DIGRAPHS_ASSERT(degree <= MAXVERTS);
  return malloc(degree * sizeof(uint16_t));
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

// free_perm_coll is not currently used, but kept in case it is required in the
// future. JDM 2019

// void free_perm_coll(PermColl* coll) {
//   for (uint16_t i = 0; i < coll->size; i++) {
//     free(coll->perms[i]);
//   }
//   free(coll->perms);
//   free(coll);
// }
