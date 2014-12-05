

#include "src/homos.h"

static bool tables_init = false;
static UIntL oneone[SYS_BITS];
static UIntL ones[SYS_BITS];
static jmp_buf outofhere;

static void inittabs(void)
{ 
  if(!tables_init) {
    UIntL i;
    UIntL v = 1;
    UIntL w = 1;
    for (i = 0; i < SYS_BITS; i++) {
        oneone[i] = w;
        ones[i] = v;
        w <<= 1;
        v |= w;
    }
    tables_init = true;
  }
}

static inline UIntS sizeUIntL (UIntL n, int m) {
  int out = 0;
  int i;
  for (i = 0; i < m; i++) {
    if (n & oneone[i]) {
      out++;
    }
  }
  return out;
}

HomosGraph* new_homos_graph (UIntS nr_verts) {
  HomosGraph* graph;
  graph->neighbours = malloc(8 * nr_verts * sizeof(UIntL));
  graph->nr_verts = nr_verts;
  inittabs();
  return graph;
}

void free_homos_graph (HomosGraph* graph) {
  if (graph->neighbours != NULL) {
    free(graph->neighbours);
  }
}

void add_edges_homos_graph (HomosGraph* graph, UIntS from_vert, UIntS to_vert) {
  graph->neighbours[8 * from_vert + (to_vert / SYS_BITS)] |= oneone[to_vert % SYS_BITS];
}

static UIntS nr1;             // nr of vertices in graph1
static UIntS nr2;             // nr of vertices in graph2
static UIntS nr2_d;           // nr2 / SYS_BITS 
static UIntS nr2_m;           // nr2 % SYS_BITS 
static UIntL  count;                   // the UIntLber of endos found so far
static UIntS  hint;           // an upper bound for the UIntLber of distinct values in map
static UIntL  maxresults;              // upper bound for the UIntLber of returned homos
/*static UInt orb[MAXVERTS];                 // to hold the orbits in OrbitReps
static UIntS sizes[MAXVERTS * MAXVERTS];  // sizes[depth * nr1 + i] = |condition[i]| at depth <depth>
static int  map[MAXVERTS];                 // partial image list
static bool reps_md[MAXVERTS * MAXVERTS];        // blist for orbit reps
static bool vals_md[MAXVERTS];             // blist for values in map
static bool neighbours1_md[MAXVERTS * MAXVERTS]; // the neighbours of the graph1
static bool neighbours2_md[MAXVERTS * MAXVERTS]; // the neighbours of the graph2
static bool dom1_md[MAXVERTS];             
static bool dom2_md[MAXVERTS];*/

static UIntL   vals_sm[8];                 // blist for values in map
static UIntL   neighbours1[8 * MAXVERTS];      // the neighbours of the graph1
static UIntL   neighbours2[8 * MAXVERTS];      // the neighbours of the graph2
static UIntL   dom1_sm[8];               
static UIntL   dom2_sm[8];
static UIntL   reps_sm[8 * MAXVERTS];

static void*  user_param;              // a user_param for the hook
static void  (*hook)();               // hook function applied to every homom. found

static UIntL   calls1;                  // UIntLber of function call statistics 
static UIntL   calls2;                  // calls1 is the UIntLber of calls to the search function
                                     // calls2 is the UIntLber of stabilizers
                                     // calculated
                                    
static UIntL last_report = 0;          // the last value of calls1 when we reported
static UIntL report_interval = 999999; // the interval when we report

// perms

static UIntS perm_buf[MAXVERTS];
typedef UIntS* perm;

static perm * stab_gens[MAXVERTS];              // GRAPH_HOMOS stabiliser gens
static UIntS size_stab_gens[MAXVERTS];   // GRAPH_HOMOS
static UIntS lmp_stab_gens[MAXVERTS];    // GRAPH_HOMOS

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

// convert GAP perms to perms
static perm as_perm (Obj const x) {
  UInt  deg, i;
  UInt2 *ptr2;
  UInt4 *ptr4;
  perm  out = new_perm();

  if (TNUM_OBJ(x) == T_PERM2) {
    deg = DEG_PERM2(x); 
    ptr2 = ADDR_PERM2(x);
    for (i = 0; i < deg; i++) {
      out[i] = (UIntS) ptr2[i];
    }
  } else if (TNUM_OBJ(x) == T_PERM4) {
    deg = DEG_PERM4(x); 
    ptr4 = ADDR_PERM4(x);
    for (i = 0; i < deg; i++) {
      out[i] = (UIntS) ptr4[i];
    }
  }

  for (; i < nr2; i++) {
    out[i] = i;
  }
  return out;
}

static Obj as_PERM4 (perm const x) {
  Obj           p;
  UIntS  i;
  UInt4         *ptr;
  
  p   = NEW_PERM4(nr2);
  ptr = ADDR_PERM4(p);
 
  for (i = 0; i < nr2; i++) {
    ptr[i] = (UInt4) x[i];
  }
  return p;
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

// Schreier-Sims set up

static perm *        strong_gens[MAXVERTS];      // strong generators
static perm          transversal[MAXVERTS * MAXVERTS];
static perm          transversal_inv[MAXVERTS * MAXVERTS];
static bool          first_ever_call = true;
static UIntS  size_strong_gens[MAXVERTS];
static UIntS  orbits[MAXVERTS * MAXVERTS];
static UIntS  size_orbits[MAXVERTS];
static bool          borbits[MAXVERTS * MAXVERTS];
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

static UIntS LargestMovedPointPermCollOld (Obj gens);
static UIntS LargestMovedPointPermColl ( perm* const gens, UIntS const nrgens); 

// 

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

static Obj size_stab_chain () {
  UIntS  i;
  Obj           tot;
  
  tot = INTOBJ_INT(1);
  for (i = 0; i < size_base; i++) {
    tot = ProdInt(tot, INTOBJ_INT((Int) size_orbits[i]));
  }
  return tot;
}

static UIntS LargestMovedPointPermCollOld (Obj const gens) {
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
}

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

static void point_stabilizer( UIntS const depth, UIntS const pt ) {

  UIntS  i, len;
  // I want to work out the Stabiliser of pt in the group   <stab_gens[depth]>
  // I want to store the generators of the resulting Stab in stab_gens[depth + 1]
  // I want to use the schreier-sims stuff

  lmp = lmp_stab_gens[depth]; // the lmp <stab_gens[depth]>
  init_stab_chain();

  // put stab_gens[depth] into strong_gens[0]
  if (strong_gens[0] != NULL) {
    free(strong_gens[0]);
  }
  len = size_stab_gens[depth];
  strong_gens[0] = malloc(len * sizeof(perm));
  memcpy(strong_gens[0], stab_gens[depth], len * sizeof(perm));
  size_strong_gens[0] = len;
  
  add_base_point(pt);
  schreier_sims_stab_chain(0);

  // the Stabiliser we want is <strong_gens[1]>
  // store these new generators in the correct place in stab_gens that we want
  if (stab_gens[depth + 1] != NULL) {
    free(stab_gens[depth + 1]);
  }
  len = size_strong_gens[1];
  stab_gens[depth + 1] = malloc(len * sizeof(perm));
  memcpy(stab_gens[depth + 1], strong_gens[1], len * sizeof(perm));
  size_stab_gens[depth + 1] = len;
  lmp_stab_gens[depth + 1] = LargestMovedPointPermColl( strong_gens[1], len );
  
  free_stab_chain();
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

// returns a UIntL representing the orbit reps of the group generated by <gens>
// not including any values already in <map> (i.e. those with vals[i] = true)

//UIntL OrbitReps_sm (Obj gens) {
//  Int    nrgens, i, j, max, fst, m, img, n;
//  Obj    gen;
//  UInt2  *ptr2;
//  UInt4  *ptr4;
//  UIntL    reps = 0;
//
//  nrgens = LEN_PLIST(gens);
//  max = 0;
//  // get the largest moved point + 1
//  for (i = 1; i <= nrgens; i++) {
//    gen = ELM_PLIST(gens, i);
//    if (TUIntL_OBJ(gen) == T_PERM2) {
//      j = DEG_PERM2(gen);
//      ptr2 = ADDR_PERM2(gen);
//      while (j > max && ptr2[j - 1] == j - 1){
//        j--;
//      }
//      if (j > max) {
//        max = j;
//      }
//    } else if (TUIntL_OBJ(gen) == T_PERM4) {
//      j = DEG_PERM4(gen);
//      ptr4 = ADDR_PERM4(gen);
//      while (j > max && ptr4[j - 1] == j - 1){
//        j--;
//      }
//      if (j > max) {
//        max = j;
//      }
//    } else {
//      ErrorQuit("expected a perm, didn't get one", 0L, 0L);
//    }
//  }
//  // special case in case there are no gens, or just the identity.
//
//  dom1_sm = 0; 
//  dom2_sm = 0;
//  m = 0; //UIntLber of orbit reps
//
//  for (i = 0; i < nr2; i++) {
//    if ((vals_sm & oneone[i]) == 0) {
//      if (i < max) {
//        dom1_sm |= oneone[i];
//      } else {
//        reps |= oneone[i];
//      }
//    }      
//  }
//
//  fst = 0; 
//  while ((dom1_sm & oneone[fst]) == 0 && fst < max) fst++;
//
//  while (fst < max) {
//    reps |= oneone[fst];
//    orb[0] = fst;
//    n = 1; //length of orb
//    dom2_sm |= oneone[fst];
//    dom1_sm ^= oneone[fst];
//
//    for (i = 0; i < n; i++) {
//      for (j = 1; j <= nrgens; j++) {
//        gen = ELM_PLIST(gens, j);
//        if (TUIntL_OBJ(gen) == T_PERM2){
//          img = IMAGE(orb[i], ADDR_PERM2(gen), DEG_PERM2(gen));
//        } else {
//          img = IMAGE(orb[i], ADDR_PERM4(gen), DEG_PERM4(gen));
//        }
//        if ((dom2_sm & oneone[img]) == 0) {
//          orb[n++] = img;
//          dom2_sm |= oneone[img];
//          dom1_sm ^= oneone[img];
//        }
//      }
//    }
//    while ((dom1_sm & oneone[fst]) == 0 && fst < max) fst++;
//  }
//  return reps;
//}

// algorithm for graphs with between SM and MD vertices . . .

// homomorphism hook funcs

void homo_hook_print () {
  UInt i;

  Pr("Transformation( [ ", 0L, 0L);
  Pr("%d", (Int) map[0] + 1, 0L);
  for (i = 1; i < nr1; i++) {
    Pr(", %d", (Int) map[i] + 1, 0L);
  }
  Pr(" ] )\n", 0L, 0L);
}


// condition handling

static bool* conditions[MAXVERTS * MAXVERTS];
static bool  alloc_conditions[MAXVERTS * MAXVERTS];

static inline bool* get_condition(UIntS const depth, 
                                  UIntS const i     ) {  // vertex in graph1
  return conditions[depth * nr1 + i];
}

static inline void set_condition(UIntS const depth, 
                                 UIntS const i,         // vertex in graph1
                                 bool*              data  ) {
  conditions[depth * nr1 + i] = data;
  alloc_conditions[depth * nr1 + i] = false;
}

static void init_conditions() {
  UIntS i, j; 

  for (i = 0; i < nr1; i++) {
    conditions[i] = malloc(nr2 * sizeof(bool));
    alloc_conditions[i] = true;
    for (j = 0; j < nr2; j++) {
      conditions[i][j] = true;
    }
  }

  for (i = nr1; i < nr1 * nr1; i++) {
    alloc_conditions[i] = false;
  }
}

static inline void free_conditions(UIntS const depth) {
  UIntS i;
  for (i = 0; i < nr1; i++) {
    if (alloc_conditions[depth * nr1 + i]) {
      free(conditions[depth * nr1 + i]);
    }
    conditions[depth * nr1 + i] = NULL;
  }
}

// copy from <depth> to <depth + 1> 
static inline bool* copy_condition(UIntS const depth, 
                                   UIntS const i     ) { // vertex in graph1
  conditions[(depth + 1) * nr1 + i] = malloc(nr2 * sizeof(bool));
  alloc_conditions[(depth + 1) * nr1 + i] = true;
  memcpy((void *) conditions[(depth + 1) * nr1 + i], 
         (void *) get_condition(depth, i), 
         (size_t) nr2 * sizeof(bool));
  return conditions[(depth + 1) * nr1 + i];
}

// the main recursive search algorithm

void SEARCH_HOMOS_MD (UIntS const depth,     // the UIntLber of filled positions in map
                      UIntS const pos,       // the last position filled
                      UIntS const rep_depth,
                      UIntS const rank){     // current UIntLber of distinct values in map

  UIntS   i, j, k, min, next, w;
  bool           *copy;

  calls1++;
  if (calls1 > last_report + report_interval) {
    Pr("calls to search = %d\n", (Int) calls1, 0L);
    Pr("stabs computed = %d\n", (Int) calls2, 0L);
    last_report = calls1;
  }

  if (depth == nr1) {
    hook();
    count++;
    if (count >= maxresults) {
      longjmp(outofhere, 1);
    }
    return;
  }

  next = 0;      // the next position to fill
  min = nr2 + 1; // the minimum UIntLber of candidates for map[next]

  if (pos != MAXVERTS + 1) {
    for (j = 0; j < nr1; j++){
      set_condition(depth, j, get_condition(depth - 1, j));
      if (map[j] == -1) {
        if (neighbours1_md[nr1 * pos + j]) { // vertex j is adjacent to vertex pos in graph1
          copy = copy_condition(depth - 1, j);
          sizes[depth * nr1 + j] = 0;
          for (k = 0; k < nr2; k++) {
            copy[k] &= neighbours2_md[nr2 * map[pos] + k];
            if (copy[k]) {
              sizes[depth * nr1 + j]++;
            }
          }
        } 
        if (sizes[depth * nr1 + j] == 0) {
          return;
        }
        if (sizes[depth * nr1 + j] < min) {
          next = j;
          min = sizes[depth * nr1 + j];
        }
      }
      sizes[(depth + 1) * nr1 + j] = sizes[(depth * nr1) + j]; 
    }
  } else {
    for (j = 0; j < nr1; j++){
      sizes[(depth + 1) * nr1 + j] = sizes[(depth * nr1) + j]; 
    }
  }
  
  if (rank < hint) {
    for (i = 0; i < nr2; i++) {
      copy = get_condition(depth, next);
      if (copy[i] && reps_md[(rep_depth * nr2) + i] && ! vals_md[i]) {
        calls2++;
        point_stabilizer(rep_depth, i); // Calculate the stabiliser of the point i
                                    // in the stabiliser at the current depth
        OrbitReps_md(rep_depth + 1);
        map[next] = i;
        vals_md[i] = true;
        SEARCH_HOMOS_MD(depth + 1, next, rep_depth + 1, rank + 1);
        map[next] = -1;
        vals_md[i] = false;
      }
    }
  }
  for (i = 0; i < nr2; i++) {
    copy = get_condition(depth, next);
    if (copy[i] && vals_md[i]) {
      map[next] = i;
      SEARCH_HOMOS_MD(depth + 1, next, rep_depth, rank);
      map[next] = -1;
    }
  }
  free_conditions(depth); 
  return;
}

void SEARCH_HOMOS_SM (UIntS depth,  // the UIntLber of filled positions in map
                      UIntS   pos,  // the last position filled
                      UIntL*  condition,     // blist of possible values for map[i]
                      // Obj   gens,       // generators for
                                           // Stabilizer(AsSet(map)) subgroup
                                           // of automorphism group of graph2
                      UIntS rep_depth,
                      UIntS   rank){// current UIntLber of distinct values in map
                      

  UIntS  i, j, k, l, min, next, m, sum, w;
  UIntL  copy[8 * nr1];
  
  calls1++;
  if (depth == nr1) {
    hook();
    count++;
    if (count >= maxresults) {
      longjmp(outofhere, 1);
    }
    return;
  }

  memcpy((void *) copy, (void *) condition, (size_t) nr1 * 8 * sizeof(UIntL));
  next = 0;      // the next position to fill
  min = nr2 + 1; // the minimum UIntLber of candidates for map[next]

  if (pos != MAXVERTS + 1) {
    for (j = 0; j < nr1; j++){
      i = j / SYS_BITS;
      m = j % SYS_BITS;
      if (map[j] == -1) {
        if (neighbours1[pos * 8 + i] & oneone[m]) { // vertex j is adjacent to vertex pos in graph1
          sizes[depth * nr1 + j] = 0;
	  for (k = 0; k < nr2_d; k++){
            copy[8 * j + k] &= neighbours2[8 * map[pos] + k];
            sizes[depth * nr1 + j] += sizeUIntL(copy[8 * j + k], SYS_BITS);
	  }
          copy[8 * j + nr2_d] &= neighbours2[8 * map[pos] + nr2_d];
          sizes[depth * nr1 + j] += sizeUIntL(copy[8 * j + nr2_d], nr2_m);
          if (sizes[depth * nr1 + j] == 0) {
            return;
          }
        }
        if (sizes[depth * nr1 + j] < min) {
          next = j;
          min = sizes[depth * nr1 + j];
        }
      }
    }
  }

  for (i = 0; i < nr1; i++) {
    sizes[(depth + 1) * nr1 + i] = sizes[depth * nr1 + i]; 
  }
  
  if (rank < hint) {
    for (i = 0; i < nr2; i++) {
      j = i / SYS_BITS;
      m = i % SYS_BITS;
      if ((copy[8 * next + j] & reps_sm[(8 * rep_depth) + j] & oneone[m]) && (vals_sm[j] & oneone[m]) == 0) { 
        calls2++;
        //Obj newGens = CALL_2ARGS(Stabilizer, gens, INTOBJ_INT(i + 1));//TODO remove
	//Obj newGens; //= point_stabilizer(gens, i); // TODO: fix this to use the new perms
        point_stabilizer(depth, i); // Calculate the stabiliser of the point i
                                    // in the stabiliser at the current depth
        map[next] = i;
        vals_sm[j] |= oneone[m];
        OrbitReps_sm(depth + 1, rep_depth + 1);
        // blist of orbit reps of things not in vals_sm
        SEARCH_HOMOS_SM(depth + 1, next, copy, rep_depth + 1, rank + 1);
        map[next] = -1;
        vals_sm[j] ^= oneone[m];
      }
    }
  } 
  for (i = 0; i < nr2; i++) {
    j = i / SYS_BITS;
    m = i % SYS_BITS;
    if (copy[8 * next + j] & vals_sm[j] & oneone[m]) {
      map[next] = i;

      //start of: make sure the next level knows that we have the same stabiliser
      size_stab_gens[depth + 1] = size_stab_gens[depth];
      stab_gens[depth + 1] = realloc(stab_gens[depth + 1], size_stab_gens[depth] * sizeof(perm));
      for (w = 0; w < size_stab_gens[depth]; w++) {
        stab_gens[depth + 1][w] = stab_gens[depth][w];
      }
      lmp_stab_gens[depth + 1] = lmp_stab_gens[depth];
      //end of that

      SEARCH_HOMOS_SM(depth + 1, next, copy, rep_depth, rank);
      map[next] = -1;
    }
  }
  return;
}

// prepare the graphs for SEARCH_HOMOS_MD

/*void GraphHomomorphisms_md (Obj  graph1, 
                            Obj  graph2,
                            void hook_arg (),
                            Obj  user_param_arg, 
                            UIntL  max_results_arg,
                            int  hint_arg, 
                            bool isinjective) {
  Obj             out, nbs, gens;
  UIntS    i, j, k, len;
  
  nr1 = DigraphNrVertices(graph1);
  nr2 = DigraphNrVertices(graph2);

  if (nr1 > MAXVERTS || nr2 > MAXVERTS) {
    ErrorQuit("too many vertices!", 0L, 0L);
  }
  
  if (isinjective && nr2 < nr1) {
    return;
  }

  // initialise everything . . .
  init_conditions();
  memset((void *) map, -1, nr1 * sizeof(int));
  memset((void *) vals_md, false, nr2 * sizeof(bool));
  memset((void *) neighbours1_md, false, nr1 * nr1 * sizeof(bool));
  memset((void *) neighbours2_md, false, nr2 * nr2 * sizeof(bool));
 
  for (i = 0; i < nr1; i++) {
    sizes[i] = nr2;
  }

  // install out-neighbours for graph1 
  out = OutNeighbours(graph1);
  for (i = 0; i < nr1; i++) {
    nbs = ELM_PLIST(out, i + 1);
    for (j = 0; j < LEN_LIST(nbs); j++) {
      k = INT_INTOBJ(ELM_LIST(nbs, j + 1)) - 1;
      neighbours1_md[nr1 * i + k] = true;
    }
  }

  // install out-neighbours for graph2
  out = OutNeighbours(graph2);
  for (i = 0; i < nr2; i++) {
    nbs = ELM_PLIST(out, i + 1);
    for (j = 0; j < LEN_LIST(nbs); j++) {
      k = INT_INTOBJ(ELM_LIST(nbs, j + 1)) - 1;
      neighbours2_md[nr2 * i + k] = true;
    }
  }

  // get generators of the automorphism group
  gens = ELM_PLIST(FuncDIGRAPH_AUTOMORPHISMS(0L, graph2), 2);
  // convert generators to our perm type
  len = (UIntS) LEN_PLIST(gens);
  stab_gens[0] = realloc(stab_gens[0], len * sizeof(perm));
  for (i = 1; i <= len; i++) {
    stab_gens[0][i - 1] = as_perm(ELM_PLIST(gens, i));
  }
  size_stab_gens[0] = len;
  lmp_stab_gens[0] = LargestMovedPointPermColl( stab_gens[0], len );
  
  // get orbit reps
  OrbitReps_md(0);
  
  // misc parameters
  count = 0;
  maxresults = max_results_arg;
  user_param = user_param_arg; 
  hint = hint_arg;
  hook = hook_arg;
  last_report = 0;
  
  // go! 
  if (setjmp(outofhere) == 0) {
    if (isinjective) {
     // SEARCH_INJ_HOMOS_MD(0, -1, condition, gens, reps, hook);
    } else {
      SEARCH_HOMOS_MD(0, MAXVERTS + 1, 0, 0);
    }
  }
}*/

// prepare the graphs for SEARCH_HOMOS

void GraphHomomorphisms (HomosGraph*  graph1, 
                         HomosGraph*  graph2,
                         void         hook_arg (void*        user_param,
	                                        const UIntS  nr,
	                                        const UIntS  *map       ),
                         void*        user_param_arg,
                         UIntL        max_results_arg,
                         int          hint_arg, 
                         bool         isinjective     ) {

  UIntS   i, j, k, d, m, len;
  
  Pr("GraphHomomorphisms_sm!\n", 0L, 0L);

  nr1 = graph1->nr_verts;
  nr2 = graph2->nr_verts;
  nr2_d = nr2 / SYS_BITS;
  nr2_m = nr2 % SYS_BITS;

  if (nr1 > MAXVERTS || nr2 > MAXVERTS) {
    ErrorQuit("too many vertices!", 0L, 0L);
  }
  
  if (isinjective) {// && nr2 < nr1) { TODO uncomment when we have sm method for injective
    return;
  }

  // initialise everything . . .
  if (!tablesinitialised) {
    inittabs();
    tablesinitialised = true;
  }
  
  UIntL condition[8 * nr1];
  d = nr1 / SYS_BITS;
  m = nr1 % SYS_BITS;
  for (i = 0; i < nr1; i++) {
    for (j = 0; j < d; j++){
      condition[8 * i + j] = ones[63];
    }
    condition[8 * i + d] = ones[m];
  }

  memset((void *) map, -1, nr1 * sizeof(int)); //everything is undefined
  
  for (i = 0; i < 8; i++){
    vals_sm[i] = 0;
  }

  memcpy((void *) neighbours1, graph1->neighbours, nr1 * 8 * sizeof(UIntL));
  memcpy((void *) neighbours2, graph2->neighbours, nr2 * 8 * sizeof(UIntL));

  for (i = 0; i < nr1; i++) {
    sizes[i] = nr2;
  }

  // get generators of the automorphism group
  gens = ELM_PLIST(FuncDIGRAPH_AUTOMORPHISMS(0L, graph2), 2);
  // convert generators to our perm type
  len = (UIntS) LEN_PLIST(gens);
  stab_gens[0] = realloc(stab_gens[0], len * sizeof(perm));
  for (i = 1; i <= len; i++) {
    stab_gens[0][i - 1] = as_perm(ELM_PLIST(gens, i));
  }
  size_stab_gens[0] = len;
  lmp_stab_gens[0] = LargestMovedPointPermColl( stab_gens[0], len );

  // get orbit reps
  OrbitReps_sm(0, 0);

  // misc parameters
  count = 0;
  maxresults = max_results_arg;
  user_param = user_param_arg;
  hint = hint_arg;
  hook = hook_arg;
  last_report = 0;

  // get orbit reps 
  //UIntL reps = OrbitReps_sm(gens);
  
  // misc parameters
  //count = 0;
  //maxresults = max_results_arg;
  //user_param = user_param_arg; 
  //hint = hint_arg;
 
  // go! 
  if (setjmp(outofhere) == 0) {
    if (isinjective) {
      //SEARCH_INJ_HOMOS_MD(0, -1, condition, gens, reps, hook, Stabilizer);
    } else {
      SEARCH_HOMOS_SM(0, MAXVERTS + 1, condition, 0, 0);
    }
  }
}
