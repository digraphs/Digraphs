#include "src/perms.h"

// new_perm_coll takes ownership of gens
PermColl* new_perm_coll (perm* gens, UIntL ne_gens) {
  PermColl coll;
  coll->gens = gens;
  coll->nr_gens = nr_gens;
  return coll;
}

PermColl* copy_perm_coll (PermColl* coll) {

  return newcoll;
}

void free_perm_coll (PermColl* coll) {
  if (coll->gens != NULL) {
    free(coll->gens);
  }
}

static perm new_perm () {
  return malloc(nr2 * sizeof(UIntS));
}

static perm id_perm () {
  UIntS i;
  perm id = new_perm();
  for (i = 0; i < nr2; i++) {
    id[i] = i;
  }
  return id;
}

static bool is_one (perm x) {
  UIntS i;

  for (i = 0; i < nr2; i++) {
    if (x[i] != i) {
      return false;
    }
  }
  return true;
}

static bool eq_perms (perm x, perm y) {
  UIntS i;

  for (i = 0; i < nr2; i++) {
    if (x[i] != y[i]) {
      return false;
    }
  }
  return true;
}

static perm prod_perms (perm const x, perm const y) {
  UIntS i;
  perm z = new_perm();

  for (i = 0; i < nr2; i++) {
    z[i] = y[x[i]];
  }
  return z;
}

static perm quo_perms (perm const x, perm const y) {
  UIntS i;

  // invert y into the buf
  for (i = 0; i < nr2; i++) {
    perm_buf[y[i]] = i;
  }
  return prod_perms(x, perm_buf);
}

// changes the lhs

static void quo_perms_in_place (perm x, perm const y) {
  UIntS i;

  // invert y into the buf
  for (i = 0; i < nr2; i++) {
    perm_buf[y[i]] = i;
  }

  for (i = 0; i < nr2; i++) {
    x[i] = perm_buf[x[i]];
  }
}

static void prod_perms_in_place (perm x, perm const y) {
  UIntS i;

  for (i = 0; i < nr2; i++) {
    x[i] = y[x[i]];
  }
}

static perm invert_perm (perm const x) {
  UIntS i;

  perm y = new_perm();
  for (i = 0; i < nr2; i++) {
    y[x[i]] = i;
  }
  return y;
}

/*static UIntS* print_perm (perm x) {
  UIntS i;

  Pr("(", 0L, 0L);
  for (i = 0; i < nr2; i++) {
    Pr("x[%d]=%d,", (Int) i, (Int) x[i]);
  }
  Pr(")\n", 0L, 0L);

}*/

/*static UIntS IMAGE_PERM (UIntS const pt, Obj const perm) {

  if (TUIntL_OBJ(perm) == T_PERM2) {
    return (UIntS) IMAGE(pt, ADDR_PERM2(perm), DEG_PERM2(perm));
  } else if (TUIntL_OBJ(perm) == T_PERM4) {
    return (UIntS) IMAGE(pt, ADDR_PERM4(perm), DEG_PERM4(perm));
  } else {
    ErrorQuit("orbit_stab_chain: expected a perm, didn't get one", 0L, 0L);
  }
  return 0; // keep compiler happy!
}*/

/*static UIntS LargestMovedPointPermCollOld (Obj const gens) {
  Obj           gen;
  UIntS  i, j;
  UInt2*        ptr2;
  UInt4*        ptr4;
  Int           nrgens = LEN_PLIST(gens);
  UIntS  max = 0;

  if (! IS_PLIST(gens)) {
    ErrorQuit("LargestMovedPointPermColl: expected a plist, didn't get one", 0L, 0L);
  }

  // get the largest moved point + 1
  for (i = 1; i <= (UIntS) nrgens; i++) {
    gen = ELM_PLIST(gens, i);
    if (TUIntL_OBJ(gen) == T_PERM2) {
      j = DEG_PERM2(gen);
      ptr2 = ADDR_PERM2(gen);
      while (j > max && ptr2[j - 1] == j - 1){
        j--;
      }
      if (j > max) {
        max = j;
      }
    } else if (TUIntL_OBJ(gen) == T_PERM4) {
      j = DEG_PERM4(gen);
      ptr4 = ADDR_PERM4(gen);
      while (j > max && ptr4[j - 1] == j - 1){
        j--;
      }
      if (j > max) {
        max = j;
      }
    } else {
      ErrorQuit("LargestMovedPointPermColl: expected a perm, didn't get one", 0L, 0L);
    }
  }

  return max;
}*/

static UIntS LargestMovedPointPermColl ( perm* const gens, UIntS const nrgens ) {
  perm          gen;
  UIntS  max = 0, i, j;

  for (i = 0; i < nrgens; i++) {
    gen = gens[i];
    j = nr2;
    while ( j > max && gen[j - 1] == j - 1 ) {
      j--;
    }
    if (j > max) {
      max = j;
    }
  }
  return max;
}


