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

static perm new_perm();

struct perm_coll {
  perm* gens;
  UIntL nr_gens;
  UIntS lmp;
};

typedef struct perm_col PermColl;

PermColl* new_perm_coll(perm* gens, UIntL nr_gens); 
PermColl* copy_perm_coll(PermColl* coll);
void free_perm_coll(PermColl* coll);
