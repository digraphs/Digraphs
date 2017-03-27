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

#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXVERTS 512
#define UNDEFINED MAXVERTS + 1

#if SIZEOF_VOID_P == 8
#define SMALLINTLIMIT 1152921504606846976
#else
#define SMALLINTLIMIT 268435456
#endif

typedef unsigned short int UIntS;
typedef UIntS*             Perm;
typedef unsigned long int  UIntL;

struct perm_coll {
  Perm* gens;
  UIntS nr_gens;
  UIntS deg;
  UIntS alloc_size;
};

typedef struct perm_coll PermColl;

void set_perms_degree(UIntS deg_arg);
PermColl* new_perm_coll(UIntS upper_bound);
void add_perm_coll(PermColl* coll, Perm gen);
PermColl* copy_perm_coll(PermColl* coll);
// void reset_perm_coll(PermColl* coll);
void free_perm_coll(PermColl* coll);

// TODO(WW) remove this
extern UIntS deg;

Perm new_perm();
Perm id_perm();
bool is_one(Perm x);
bool eq_perms(Perm x, Perm y);
Perm prod_perms(Perm const x, Perm const y);
void prod_perms_in_place(Perm x, Perm const y);
Perm copy_perm(Perm const x);
Perm invert_perm(Perm const x);

// variables for debugging memory leaks
extern UIntL nr_ss_allocs;
extern UIntL nr_ss_frees;
extern UIntL nr_new_perm_coll;
extern UIntL nr_free_perm_coll;

#endif  // DIGRAPHS_SRC_PERMS_H_
