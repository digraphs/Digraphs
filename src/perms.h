#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>

// FIXME detect if we are on a 32-bit machine
#define MAXVERTS 512
typedef unsigned long int UIntL;
#define SMALLINTLIMIT 1152921504606846976
#define SYS_BITS 64

typedef unsigned short int UIntS;
typedef UIntS* Perm;

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
//void reset_perm_coll(PermColl* coll);
void free_perm_coll(PermColl* coll);

// TODO remove this
extern UIntS deg;

Perm new_perm();
Perm id_perm ();
bool is_one (Perm x);
bool eq_perms (Perm x, Perm y);
Perm prod_perms (Perm const x, Perm const y);
void prod_perms_in_place (Perm x, Perm const y);
Perm invert_perm (Perm const x);

