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

static UIntS perm_buf[MAXVERTS];
typedef UIntS* perm;

static Perm new_perm();

struct perm_coll {
  perm* gens;
  UIntS nr_gens;
  UIntS deg;
  UIntS alloc_size;
};

typedef struct perm_coll PermColl;

PermColl* new_perm_coll(UIntS deg, UIntS upper_bound);
PermColl* add_perm_coll(PermColl* coll, Perm gen);
PermColl* copy_perm_coll(PermColl* coll);
void free_perm_coll(PermColl* coll);
