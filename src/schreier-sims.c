/*******************************************************************************
**
*A  schreier-sims.h        A rudimentary Schreier-Sims        Julius Jonusas
**                                                            James Mitchell
**                                                            Michael Torpey
**                                                            Wilfred Wilson
**
**  Copyright (C) 2014-15 - Julius Jonusas, James Mitchell, Michael Torpey,
**  Wilfred Wilson
**
**  This file is free software, see the digraphs/LICENSE.
**
*******************************************************************************/

#include "src/schreier-sims.h"

// Schreier-Sims set up

static PermColl * strong_gens[MAXVERTS];                // strong generators
static Perm       transversal[MAXVERTS * MAXVERTS];
static Perm       transversal_inv[MAXVERTS * MAXVERTS];
static bool       first_ever_call = true;
static bool       borbits[MAXVERTS * MAXVERTS];
static UIntS      orbits[MAXVERTS * MAXVERTS];
static UIntS      size_orbits[MAXVERTS];
//static UIntS    lmp;
static UIntS      base[MAXVERTS];
static UIntS      size_base;

static inline void add_strong_gens (UIntS const pos, Perm const value) {
  if (strong_gens[pos] == NULL) {
    strong_gens[pos] = new_perm_coll(1);
  }
  add_perm_coll(strong_gens[pos], value);
}

static inline Perm get_strong_gens (UIntS const i, UIntS const j) {
  return strong_gens[i]->gens[j];
}

static inline Perm get_transversal (UIntS const i, UIntS const j) {
  return transversal[i * MAXVERTS + j];
}

static inline Perm get_transversal_inv (UIntS const i, UIntS const j) {
  return transversal_inv[i * MAXVERTS + j];
}

static inline void set_transversal (UIntS const i, UIntS const j, 
    Perm const value) {

  // free the perm in this position if there is one already
  if (transversal[i * MAXVERTS + j] != NULL) {
    free(transversal[i * MAXVERTS + j]);
    nr_ss_frees++;
    free(transversal_inv[i * MAXVERTS + j]);
    nr_ss_frees++;
  }
  transversal[i * MAXVERTS + j] = value;
  transversal_inv[i * MAXVERTS + j] = invert_perm(value);
}

static bool perm_fixes_all_base_points ( Perm const x ) {
  UIntS i;

  for (i = 0; i < size_base; i++) {
    if (x[base[i]] != base[i]) {
      return false;
    }
  }
  return true;
}

static inline void add_base_point (UIntS const pt) {
  base[size_base] = pt;
  size_orbits[size_base] = 1;
  orbits[size_base * deg] = pt;
  borbits[size_base * deg + pt] = true;
  set_transversal(size_base, pt, id_perm());
  size_base++;
}

/*static void remove_base_points (UIntS const depth) {
  UIntS i, j;

  printf("this is not yet used...\n");
  assert( depth <= size_base );

  for (i = depth; i < size_base; i++) {
    size_base--;
    //free(strong_gens[i + 1]);
    //size_strong_gens[i + 1] = 0;
    free_perm_coll(strong_gens[i + 1]); // TODO: not sure if necessary or even wise
    size_orbits[i] = 0;
    
    for (j = 0; j < deg; j++) {//TODO double-check deg!
      borbits[i * deg + j] = false;
    }
  }
}*/

static inline void first_ever_init () {
  /*UIntL i;

  for (i = 0; i < MAXVERTS; i++) {
    strong_gens[i] = NULL;
  }
  for (i = 0; i < MAXVERTS * MAXVERTS; i++) {
    transversal[i] = NULL;
    transversal_inv[i] = NULL;
  }*/

  first_ever_call = false;
  memset((void *) size_orbits, 0, MAXVERTS * sizeof(UIntS));
}

static void init_stab_chain () {

  if (first_ever_call) {
    first_ever_init();
  }

  memset((void *) borbits, false, deg * deg * sizeof(bool)); 
  size_base = 0;
}

/*static void init_endos_base_points() {
  UIntS  i;

  for (i = 0; i < deg - 1; i++) {
    add_base_point(i);
  }
}*/

static void free_stab_chain () {
  int i, j, k;

  memset((void *) size_orbits, 0, size_base * sizeof(UIntS));

  // free the transversal
  // free the transversal_inv
  for (i = 0; i < (int) deg; i++) {
    for (j = 0; j < (int) deg; j++) {
      k = i * MAXVERTS + j;
      if (transversal[k] != NULL) {
        free(transversal[k]);
        transversal[k] = NULL;
        nr_ss_frees++;
        free(transversal_inv[k]);
        transversal_inv[k] = NULL;
        nr_ss_frees++;
      }
    }
  }

  // free the strong_gens
  for (i = 0; i < (int) size_base; i++) {
    if (strong_gens[i] != NULL) {
      free_perm_coll(strong_gens[i]);
      strong_gens[i] = NULL;
    }
  }
}

static void orbit_stab_chain (UIntS const depth, UIntS const init_pt) {
  UIntS i, j, pt, img;
  Perm  x;

  assert( depth <= size_base ); // Should this be strict?

  for (i = 0; i < size_orbits[depth]; i++) {
    pt = orbits[depth * deg + i];
    for (j = 0; j < strong_gens[depth]->nr_gens; j++) {
      x = get_strong_gens(depth, j);
      img = x[pt];
      if (! borbits[depth * deg + img]) {
        orbits[depth * deg + size_orbits[depth]] = img;
        size_orbits[depth]++;
        borbits[depth * deg + img] = true;
        set_transversal(depth, img, prod_perms(get_transversal(depth, pt), x));
      }
    }
  }
}

static void add_gen_orbit_stab_chain (UIntS const depth, Perm const gen) {
  UIntS  i, j, pt, img;
  Perm   x;

  assert( depth <= size_base );

  // apply the new generator to existing points in orbits[depth]
  UIntS nr = size_orbits[depth];
  for (i = 0; i < nr; i++) {
    pt = orbits[depth * deg + i];
    img = gen[pt];
    if (! borbits[depth * deg + img]) {
      orbits[depth * deg + size_orbits[depth]] = img;
      size_orbits[depth]++;
      borbits[depth * deg + img] = true;
      set_transversal(depth, img, 
        prod_perms(get_transversal(depth, pt), gen));
    }
  }

  for (i = nr; i < size_orbits[depth]; i++) {
    pt = orbits[depth * deg + i];
    for (j = 0; j < strong_gens[depth]->nr_gens; j++) {
      x = get_strong_gens(depth, j);
      img = x[pt];
      if (! borbits[depth * deg + img]) {
        orbits[depth * deg + size_orbits[depth]] = img;
        size_orbits[depth]++;
        borbits[depth * deg + img] = true;
        set_transversal(depth, img, prod_perms(get_transversal(depth, pt), x));
      }
    }
  }
}

static void sift_stab_chain (Perm* g, UIntS* depth) {
  UIntS beta;

  assert(*depth == 0);
  
  for (; *depth < size_base; (*depth)++) {
    beta = (*g)[base[*depth]];
    if (! borbits[*depth * deg + beta]) {
      return;
    }
    prod_perms_in_place(*g, get_transversal_inv(*depth, beta));
  }
}

static void schreier_sims_stab_chain ( UIntS const depth ) {

  Perm          x, h, prod;
  bool          escape, y;
  int           i;
  UIntS         j, jj, k, l, m, beta, betax;

  for (i = 0; i <= (int) depth; i++) { 
    for (j = 0; j < strong_gens[i]->nr_gens; j++) { 
      x = get_strong_gens(i, j);
      if ( perm_fixes_all_base_points( x ) ) {
        for (k = 0; k < deg; k++) {
          if (k != x[k]) {
            add_base_point(k);
            break;
          }
        }
      }
    }
  }
  
  for (i = depth + 1; i < (int) size_base + 1; i++) {
    beta = base[i - 1];
    // set up the strong generators
    for (j = 0; j < strong_gens[i - 1]->nr_gens; j++) {
      x = get_strong_gens(i - 1, j);
      if (beta == x[beta]) {
        add_strong_gens(i, copy_perm(x));
      }
    }

    // find the orbit of <beta> under strong_gens[i - 1]
    orbit_stab_chain(i - 1, beta);
  }

  i = size_base - 1; 
  
  while (i >= (int) depth) {
    escape = false;
    for (j = 0; j < size_orbits[i] && !escape; j++) {
      beta = orbits[i * deg + j];
      for (m = 0; m < strong_gens[i]->nr_gens && !escape; m++) {
        x = get_strong_gens(i, m);
        prod  = prod_perms(get_transversal(i, beta), x );
        betax = x[beta];
        if ( ! eq_perms(prod, get_transversal(i, betax)) ) {
          y = true;
          h = prod_perms(prod, get_transversal_inv(i, betax));
          jj = 0;
          sift_stab_chain(&h, &jj);
          if ( jj < size_base ) {
            y = false;
          } else if ( ! is_one(h) ) { // better method? IsOne(h)?
            y = false;
            for (k = 0; k < deg; k++) {
              if (k != h[k]) {
                add_base_point(k);
                break;
              }
            }
          }
          
          if ( !y ) {
            for (l = i + 1; l <= jj; l++) {
              add_strong_gens(l, copy_perm(h));
              add_gen_orbit_stab_chain(l, h);
              // add generator to <h> to orbit of base[l]
            }
            i = jj;
            escape = true;
          }
          free(h);
          nr_ss_frees++;
        }
        free(prod);
        nr_ss_frees++;
      }
    }
    if (! escape) {
      i--;
    }
  }
  
}

extern bool point_stabilizer( PermColl* gens, UIntS const pt, PermColl** out) {
  init_stab_chain();

  strong_gens[0] = copy_perm_coll(gens);
  add_base_point(pt);
  schreier_sims_stab_chain(0);

  // The stabiliser we want is the PermColl pointed to by <strong_gens[1]>
  // UNLESS <strong_gens[1]> doesn't exists - this means that <strong_gens[0]>
  // is the stabilizer itself (????)
  if (*out != NULL) {
    free_perm_coll(*out);
  }
  if (strong_gens[1] == NULL) {
    // this means that the stabilizer of pt under <gens> is trivial
    *out = new_perm_coll(1);
    add_perm_coll(*out, id_perm());
    free_stab_chain();
    return true;
  }
  *out = copy_perm_coll(strong_gens[1]);
  free_stab_chain();
  return false;
}

/*static Obj size_stab_chain () {
  UIntS  i;
  Obj           tot;
  
  tot = INTOBJ_INT(1);
  for (i = 0; i < size_base; i++) {
    tot = ProdInt(tot, INTOBJ_INT((Int) size_orbits[i]));
  }
  return tot;
}*/

/*static Obj FuncC_STAB_CHAIN ( Obj self, Obj gens, Obj lmp ) {
  Obj           size;
  UIntS  nrgens, i;

  deg = (UIntS) INT_INTOBJ(lmp);
  init_stab_chain();
  strong_gens[0] = new_perm_coll(nrgens);
  nrgens = (UIntS) LEN_PLIST(gens);
  for (i = 1; i <= nrgens; i++) {
    add_perm_coll(strong_gens[0], as_perm(ELM_PLIST(gens, i)));
  }
  init_endos_base_points();
  schreier_sims_stab_chain(0);
  size = size_stab_chain();
  free_stab_chain();
  return size;
}*/

/*static Obj FuncSTAB( Obj self, Obj gens, Obj pt ) {
  UIntS  nrgens, i, len;
  Obj           out;

  deg = LargestMovedPointPermCollOld(gens);
  lmp_stab_gens[0] = deg;
  nrgens = (UIntS) LEN_PLIST(gens);
  size_stab_gens[0] = nrgens;
  stab_gens[0] = realloc( stab_gens[0], nrgens * sizeof(Perm));
  for (i = 0; i < nrgens; i++) {
    stab_gens[0][i] = as_perm(ELM_PLIST(gens, i + 1));
  }
  point_stabilizer( 0, ((UIntS) INT_INTOBJ(pt)) - 1 );
  len = size_stab_gens[1];
  out = NEW_PLIST(T_PLIST, (Int) len);
  SET_LEN_PLIST(out, (Int) len);
  for (i = 0; i < len; i++) {
    SET_ELM_PLIST(out, i + 1, as_PERM4(stab_gens[1][i]));
  }
  CHANGED_BAG(out);
  return out;
}*/
