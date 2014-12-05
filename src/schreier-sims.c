#include "src/schreier-sims.h"

// Schreier-Sims set up

static perm * strong_gens[MAXVERTS];      // strong generators
static perm   transversal[MAXVERTS * MAXVERTS];
static perm   transversal_inv[MAXVERTS * MAXVERTS];
static bool   first_ever_call = true;
static UIntS  size_strong_gens[MAXVERTS];
static UIntS  orbits[MAXVERTS * MAXVERTS];
static UIntS  size_orbits[MAXVERTS];
static bool   borbits[MAXVERTS * MAXVERTS];
static UIntS  lmp;
static UIntS  base[MAXVERTS];
static UIntS  size_base;

static inline void add_strong_gens (UIntS const pos, perm const value) {
  size_strong_gens[pos]++;
  strong_gens[pos] = realloc(strong_gens[pos], size_strong_gens[pos] * sizeof(perm));
  strong_gens[pos][size_strong_gens[pos] - 1] = value;
}

static inline perm get_strong_gens (UIntS const i, UIntS const j) {
  return strong_gens[i][j];
}

static inline perm get_transversal (UIntS const i, UIntS const j) {
  return transversal[i * MAXVERTS + j];
}

static inline perm get_transversal_inv (UIntS const i, UIntS const j) {
  return transversal_inv[i * MAXVERTS + j];
}

static inline void set_transversal (UIntS const i, UIntS const j, 
    perm const value) {
  transversal[i * MAXVERTS + j] = value;
  transversal_inv[i * MAXVERTS + j] = invert_perm(value);
}

static bool perm_fixes_all_base_points ( perm const x ) {
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
  orbits[size_base * MAXVERTS] = pt;
  borbits[size_base * nr2 + pt] = true;
  set_transversal(size_base, pt, id_perm());
  size_base++;
}

static void remove_base_points (UIntS const depth) {
  UIntS i, j;

  assert( depth <= size_base );

  for (i = depth; i < size_base; i++) {
    size_base--;
    //free(strong_gens[i + 1]);
    size_strong_gens[i + 1] = 0;
    size_orbits[i] = 0;
    
    for (j = 0; j < nr2; j++) {//TODO double-check nr2!
      borbits[i * nr2 + j] = false;
    }
  }
}

static inline void first_ever_init () {
  UIntS i;

  first_ever_call = false;

  memset((void *) size_strong_gens, 0, MAXVERTS * sizeof(UIntS));
  memset((void *) size_orbits, 0, MAXVERTS * sizeof(UIntS));
}

static void init_stab_chain () {
  UIntS  i;

  if (first_ever_call) {
    first_ever_init();
  }

  memset((void *) borbits, false, nr2 * nr2 * sizeof(bool)); 
  size_base = 0;
}

static void init_endos_base_points() {
  UIntS  i;

  for (i = 0; i < nr2 - 1; i++) {
    add_base_point(i);
  }
}

static void free_stab_chain () {
  UIntS i;

  memset((void *) size_strong_gens, 0, size_base * sizeof(UIntS));
  memset((void *) size_orbits, 0, size_base * sizeof(UIntS));
}

static void orbit_stab_chain (UIntS const depth, UIntS const init_pt) {
  UIntS i, j, pt, img;
  perm         x;

  assert( depth <= size_base ); // Should this be strict?

  for (i = 0; i < size_orbits[depth]; i++) {
    pt = orbits[depth * MAXVERTS + i];
    for (j = 0; j < size_strong_gens[depth]; j++) {
      x = get_strong_gens(depth, j);
      img = x[pt];
      if (! borbits[depth * nr2 + img]) {
        orbits[depth * MAXVERTS + size_orbits[depth]] = img;
        size_orbits[depth]++;
        borbits[depth * nr2 + img] = true;
        set_transversal(depth, img, prod_perms(get_transversal(depth, pt), x));
      }
    }
  }
}

static void add_gen_orbit_stab_chain (UIntS const depth, perm const gen) {
  UIntS  i, j, pt, img;
  perm          x;

  assert( depth <= size_base );

  // apply the new generator to existing points in orbits[depth]
  UIntS nr = size_orbits[depth];
  for (i = 0; i < nr; i++) {
    pt = orbits[depth * MAXVERTS + i];
    img = gen[pt];
    if (! borbits[depth * nr2 + img]) {
      orbits[depth * MAXVERTS + size_orbits[depth]] = img;
      size_orbits[depth]++;
      borbits[depth * nr2 + img] = true;
      set_transversal(depth, img, 
        prod_perms(get_transversal(depth, pt), gen));
    }
  }

  for (i = nr; i < size_orbits[depth]; i++) {
    pt = orbits[depth * MAXVERTS + i];
    for (j = 0; j < size_strong_gens[depth]; j++) {
      x = get_strong_gens(depth, j);
      img = x[pt];
      if (! borbits[depth * nr2 + img]) {
        orbits[depth * MAXVERTS + size_orbits[depth]] = img;
        size_orbits[depth]++;
        borbits[depth * nr2 + img] = true;
        set_transversal(depth, img, prod_perms(get_transversal(depth, pt), x));
      }
    }
  }
}

static void sift_stab_chain (perm* g, UIntS* depth) {
  UIntS beta;

  assert(*depth == 0);
  
  for (; *depth < size_base; (*depth)++) {
    beta = (*g)[base[*depth]];
    if (! borbits[*depth * nr2 + beta]) {
      return;
    }
    prod_perms_in_place(*g, get_transversal_inv(*depth, beta));
  }
}

static void schreier_sims_stab_chain ( UIntS const depth ) {

  perm          x, h, prod;
  bool          escape, y;
  int           i;
  UIntS  j, jj, k, l, m, beta, betax;

  for (i = 0; i < (int) size_base; i++) { 
    for (j = 0; j < size_strong_gens[i]; j++) { 
      x = get_strong_gens(i, j);
      if ( perm_fixes_all_base_points( x ) ) {
        for (k = 0; k < lmp; k++) {
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
    for (j = 0; j < size_strong_gens[i - 1]; j++) {
      x = get_strong_gens(i - 1, j);
      if (beta == x[beta]) {
        add_strong_gens(i, x);
      }
    }

    // find the orbit of <beta> under strong_gens[i - 1]
    orbit_stab_chain(i - 1, beta);
  }

  i = size_base - 1; // Unsure about this

  while (i >= (int) depth) {
    escape = false;
    for (j = 0; j < size_orbits[i] && !escape; j++) {
      beta = orbits[i * MAXVERTS + j];
      for (m = 0; m < size_strong_gens[i] && !escape; m++) {
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
            for (k = 0; k < lmp; k++) {
              if (k != h[k]) {
                add_base_point(k);
                break;
              }
            }
          }
    
          if ( !y ) {
            for (l = i + 1; l <= jj; l++) {
              add_strong_gens(l, h);
              add_gen_orbit_stab_chain(l, h);
              // add generator to <h> to orbit of base[l]
            }
            i = jj;
            escape = true;
          }
        }
      }
    }
    if (! escape) {
      i--;
    }
  }
  
}

extern *perm point_stabilizer( *perm const gens, UIntS const pt ) {

  UIntS  i, len;
  perm*  ptr;
  // I want to work out the Stabiliser of pt in the group   <gens>
  // I want to store the generators of the resulting Stab in stab_gens[depth + 1]
  // I want to use the schreier-sims stuff

  lmp = // get the lmp 
  init_stab_chain();

  // put gens into strong_gens[0]
  if (strong_gens[0] != NULL) {
    free(strong_gens[0]);
  }
  len = // get the number of gens
  strong_gens[0] = malloc(len * sizeof(perm));
  memcpy(strong_gens[0], gens[depth], len * sizeof(perm));
  size_strong_gens[0] = len;
  
  add_base_point(pt);
  schreier_sims_stab_chain(0);

  // the s§tabiliser we want is <strong_gens[1]>
  // store these new generators in the correct place in stab_gens that we want
  if (stab_gens[depth + 1] != NULL) {
    free(stab_gens[depth + 1]);
  }
  len = size_strong_gens[1];  // number of new gens
  ptr = malloc(len * sizeof(perm));
  memcpy(ptr, strong_gens[1], len * sizeof(perm)); // set the new gens
  size_stab_gens[depth + 1] = len; // set the nr new gens
  lmp_stab_gens[depth + 1] = LargestMovedPointPermColl( strong_gens[1], len ); // set the new lmp
  // put everything in the struct

  free_stab_chain();
  return ptr;
}

/*static Obj size_stab_chain () {
  UIntS  i;
  Obj           tot;
  
  tot = INTOBJ_INT(1);
  for (i = 0; i < size_base; i++) {
    tot = ProdInt(tot, INTOBJ_INT((Int) size_orbits[i]));
  }
  return tot;
}

static Obj FuncC_STAB_CHAIN ( Obj self, Obj gens ) {
  Obj           size;
  UIntS  nrgens, i;

  nr2 = LargestMovedPointPermCollOld(gens);
  lmp = nr2;
  init_stab_chain();
  nrgens = (UIntS) LEN_PLIST(gens);
  for (i = 1; i <= nrgens; i++) {
    add_strong_gens(0, as_perm(ELM_PLIST(gens, i)));
  }
  init_endos_base_points();
  schreier_sims_stab_chain(0);
  size = size_stab_chain();
  free_stab_chain();
  return size;
}

static Obj FuncSTAB( Obj self, Obj gens, Obj pt ) {
  UIntS  nrgens, i, len;
  Obj           out;

  nr2 = LargestMovedPointPermCollOld(gens);
  lmp_stab_gens[0] = nr2;
  nrgens = (UIntS) LEN_PLIST(gens);
  size_stab_gens[0] = nrgens;
  stab_gens[0] = realloc( stab_gens[0], nrgens * sizeof(perm));
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
}
*/

// returns a bool array representing the orbit reps of the group generated by
// <gens> not including any values already in <map> (i.e. those with vals[i] =
// true)

void OrbitReps_md (UIntS rep_depth) {
  UIntS  nrgens, i, j, fst, m, img, n, max;
  perm*  gens;
  perm   gen;
 
  gens = stab_gens[rep_depth];
  for (i = rep_depth * nr2; i < (rep_depth + 1) * nr2; i++) {
    reps_md[i] = false;
  }

  nrgens  = size_stab_gens[rep_depth];
  max     = lmp_stab_gens[rep_depth];

  // special case in case there are no gens, or just the identity.

  memset((void *) dom1_md, false, max * sizeof(bool)); 
  memset((void *) dom2_md, false, max * sizeof(bool)); 
  
  m = 0; //UIntLber of orbit reps

  for (i = 0; i < nr2; i++) {
    if (! vals_md[i]) {
      if (i < max) {
        dom1_md[i] = true;
      } else {
        reps_md[(rep_depth * nr2) + i] = true;
      }
    }      
  }

  fst = 0; 
  while (! dom1_md[fst] && fst < max) fst++;

  while (fst < max) {
    reps_md[(rep_depth * nr2) + fst] = true;
    orb[0] = fst;
    n = 1; //length of orb
    dom2_md[fst] = true;
    dom1_md[fst] = false;

    for (i = 0; i < n; i++) {
      for (j = 0; j < nrgens; j++) {
        gen = gens[j];
        img = gen[orb[i]];
        if (! dom2_md[img]) {
          orb[n++] = img;
          dom2_md[img] = true;
          dom1_md[img] = false;
        }
      }
    }
    while (! dom1_md[fst] && fst < max) fst++; 
  }
  return;
}

void OrbitReps_sm (UIntS depth, UIntS rep_depth) {
  UIntS  nrgens, i, j, fst, m, img, n, max, d;
  perm*  gens;
  perm   gen;
 
  gens = stab_gens[depth];
  for (i = 8 * rep_depth; i < 8 * (rep_depth + 1); i++) {
    reps_sm[i] = 0;
  }

  nrgens  = size_stab_gens[depth];
  max     = lmp_stab_gens[depth];

  // special case in case there are no gens, or just the identity.

  //memset((void *) dom1_md, false, max * sizeof(bool)); 
  //memset((void *) dom2_md, false, max * sizeof(bool)); 

  for (i = 0; i < 8; i++){
    dom1_sm[i] = 0;
    dom2_sm[i] = 0;
  }
  
  for (i = 0; i < nr2; i++) {
    d = i / SYS_BITS;
    m = i % SYS_BITS;
    if ((vals_sm[d] & oneone[m]) == 0) {
      if (i < max) {
        dom1_sm[d] |= oneone[m];
      } else {
        reps_sm[(8 * rep_depth) + d] |= oneone[m];
      }
    }      
  }

  fst = 0; 
  while ( ((dom1_sm[fst / SYS_BITS] & oneone[fst % SYS_BITS]) == 0) && fst < max) fst++;

  while (fst < max) {
    d = fst / SYS_BITS;
    m = fst % SYS_BITS;
    reps_sm[(8 * rep_depth) + d] |= oneone[m];
    orb[0] = fst;
    n = 1; //length of orb
    dom2_sm[d] |= oneone[m];
    dom1_sm[d] ^= oneone[m];

    for (i = 0; i < n; i++) {
      for (j = 0; j < nrgens; j++) {
        gen = gens[j];
        img = gen[orb[i]];
	d = img / SYS_BITS;
	m = img % SYS_BITS;
        if ((dom2_sm[d] & oneone[m]) == 0) {
          orb[n++] = img;
          dom2_sm[d] |= oneone[m];
          dom1_sm[d] ^= oneone[m];
        }
      }
    }
    while ( ((dom1_sm[fst / SYS_BITS] & oneone[fst % SYS_BITS]) == 0) && fst < max) fst++;
  }
  return;
}
