/*******************************************************************************
**
*A  perms.h                  permutations                     Julius Jonusas
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

#ifndef DIGRAPHS_SRC_PERMS_H_
#define DIGRAPHS_SRC_PERMS_H_

#include <stdbool.h>  // for bool, false, true
#include <stdint.h>   // for uint16_t, uint64_t
#include <string.h>   // memcpy, size_t

#include "digraphs-debug.h"  // for DIGRAPHS_ASSERT

#define MAXVERTS 512
#define UNDEFINED MAXVERTS + 1

#if SIZEOF_VOID_P == 8
#define SMALLINTLIMIT 1152921504606846976
#else
#define SMALLINTLIMIT 268435456
#endif

typedef uint16_t* Perm;

Perm new_perm(uint16_t const);

static inline void id_perm(Perm x, uint16_t const degree) {
  DIGRAPHS_ASSERT(degree <= MAXVERTS);
  for (uint16_t i = 0; i < degree; i++) {
    x[i] = i;
  }
}

static inline bool is_one(Perm const x, uint16_t const degree) {
  DIGRAPHS_ASSERT(degree <= MAXVERTS);
  for (uint16_t i = 0; i < degree; i++) {
    if (x[i] != i) {
      return false;
    }
  }
  return true;
}

static inline bool eq_perms(Perm const x, Perm const y, uint16_t const degree) {
  DIGRAPHS_ASSERT(degree <= MAXVERTS);
  for (uint16_t i = 0; i < degree; i++) {
    if (x[i] != y[i]) {
      return false;
    }
  }
  return true;
}

static inline void
prod_perms(Perm xy, Perm const x, Perm const y, uint16_t const degree) {
  DIGRAPHS_ASSERT(x != y);
  DIGRAPHS_ASSERT(xy != y);
  for (uint16_t i = 0; i < degree; i++) {
    xy[i] = y[x[i]];
  }
}

static inline void invert_perm(Perm x, Perm const y, uint16_t const degree) {
  DIGRAPHS_ASSERT(degree <= MAXVERTS);
  for (uint16_t i = 0; i < degree; i++) {
    x[y[i]] = i;
  }
}

static inline void copy_perm(Perm x, Perm const y, uint16_t const degree) {
  memcpy((void*) x, (void*) y, (size_t) degree * sizeof(uint16_t));
}

struct perm_coll {
  Perm*    perms;
  uint16_t size;
  uint16_t degree;
  uint16_t capacity;
};

typedef struct perm_coll PermColl;

PermColl* new_perm_coll(uint16_t const, uint16_t const);

static inline void clear_perm_coll(PermColl* coll) {
  coll->size = 0;
}

static inline void add_perm_coll(PermColl* coll, Perm const gen) {
  DIGRAPHS_ASSERT(coll->size < coll->capacity);
  DIGRAPHS_ASSERT(coll->size < coll->degree);
  copy_perm(coll->perms[(coll->size)++], gen, coll->degree);
}

static inline void copy_perm_coll(PermColl* coll1, PermColl const* coll2) {
  DIGRAPHS_ASSERT(coll1->capacity >= coll2->size);
  clear_perm_coll(coll1);
  coll1->degree = coll2->degree;
  for (uint16_t i = 0; i < coll2->size; i++) {
    add_perm_coll(coll1, coll2->perms[i]);
  }
}

void free_perm_coll(PermColl* coll);

#endif  // DIGRAPHS_SRC_PERMS_H_
