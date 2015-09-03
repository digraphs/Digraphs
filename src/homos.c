/***************************************************************************
**
*A  homos.c                  graph homomorphisms              Julius Jonusas
**                                                            J. D. Mitchell
**
**  Copyright (C) 2014 - Julius Jonusas and J. D. Mitchell
**  This file is free software, see license information at the end.
**
*/

#include "src/homos.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Global variables
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


// globals for the recursive find_graph_homos
static UIntS  nr1;                         // nr of vertices in graph1
static UIntS  nr1_d;                       // nr1 - 1 / SYS_BITS
static UIntS  nr1_m;                       // nr1 - 1 % SYS_BITS
static UIntS  nr2;                         // nr of vertices in graph2
static UIntS  nr2_d;                       // nr2 - 1 / SYS_BITS
static UIntS  nr2_m;                       // nr2 - 1 % SYS_BITS
static UIntS  len_nr1;                     // number of UIntL to store all neighbours1
static UIntS  len_nr2;                     // number of UIntL to store all neighbours2
static UIntS  hint;                        // wanted nr of distinct values in map
static UIntL  maxresults;                  // upper bound for the nr of returned homos
static UIntS  map[MAXVERTS];               // partial image list
static UIntS  sizes[MAXVERTS * MAXVERTS];  // sizes[depth * nr1 + i] = |condition[i]| at <depth>
static UIntL  vals[MAXVERTS / SYS_BITS];                     // blist for values in map
static UIntL  neighbours1[MAXVERTS / SYS_BITS * MAXVERTS];   // the neighbours of the graph1
static UIntL  neighbours2[MAXVERTS / SYS_BITS * MAXVERTS];   // the neighbours of the graph2

static void*  user_param;                  // a user_param for the hook
void          (*hook)(void* user_param,    // hook function applied to every homo found
	              const UIntS nr,
	              const UIntS *map);

// globals for the orbit reps calculation  // TODO remove this whole section
static UIntS     orb[MAXVERTS];            // to hold the orbits in orbit_reps
static UIntL     domain[MAXVERTS / SYS_BITS];                // for finding orbit reps
static UIntL     orb_lookup[MAXVERTS / SYS_BITS];            // for finding orbit reps
static UIntL     reps[MAXVERTS / SYS_BITS * MAXVERTS];       // orbit reps
static PermColl* stab_gens[MAXVERTS];      // stabiliser generators

// globals for statics
static UIntL count;                        // nr of homos found so far
static unsigned long long calls1;          // calls1 is the nr of calls to find_graph_homos
static unsigned long long calls2;          // calls2 is the nr of stabs calculated
static UIntL last_report = 0;              // the last value of calls1 when we reported
static UIntL report_interval = 999999;     // the interval when we report
static unsigned long long nr_allocs;
static unsigned long long nr_frees;

// globals for bitwise operations
static bool    are_bit_tabs_init = false;  // did we call init_bit_tabs already?
static UIntL   oneone[SYS_BITS];           // bit lists for intersection etc.
static UIntL   ones[SYS_BITS];             // bit lists for intersection etc.
static jmp_buf outofhere;                  // so we can jump out of the deepest level of recursion

////////////////////////////////////////////////////////////////////////////////
// initial the bit tabs
////////////////////////////////////////////////////////////////////////////////

static void init_bit_tabs (void) {
  assert(false);
  if (! are_bit_tabs_init) {
    UIntL i;
    UIntL v = 1;
    UIntL w = 1;
    for (i = 0; i < SYS_BITS; i++) {
        oneone[i] = w;
        ones[i] = v;
        w <<= 1;
        v |= w;
    }
    are_bit_tabs_init = true;
  }
}

////////////////////////////////////////////////////////////////////////////////
// number of 1s in the binary expansion of an array consisting of <m> UIntLs
////////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// creating graphs for homomorphism finder. . .
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// new_homos_graph:
////////////////////////////////////////////////////////////////////////////////

HomosGraph* new_homos_graph (UIntS const nr_verts) {
  HomosGraph* graph = malloc(sizeof(HomosGraph));
  graph->neighbours = calloc(((nr_verts - 1) / SYS_BITS + 1) * nr_verts,
                             sizeof(UIntL));
  graph->nr_verts = nr_verts;
  init_bit_tabs();
  return graph;
}

////////////////////////////////////////////////////////////////////////////////
// free_homos_graph:
////////////////////////////////////////////////////////////////////////////////

void free_homos_graph (HomosGraph* graph) {
  if (graph->neighbours != NULL) {
    free(graph->neighbours);
  }
}

////////////////////////////////////////////////////////////////////////////////
// add_edge_homos_graph:
////////////////////////////////////////////////////////////////////////////////

void add_edge_homos_graph (HomosGraph* graph, UIntS from_vert, UIntS to_vert) {
  graph->neighbours[((graph->nr_verts - 1) / SYS_BITS + 1) * from_vert +
    (to_vert / SYS_BITS)] |= oneone[to_vert % SYS_BITS];
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// automorphism group . . .
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

static BlissGraph* as_bliss_graph (HomosGraph* graph) {
  UIntS  i, j, k;
  UIntS  n = graph->nr_verts;
  UIntS  d = ((n - 1) / SYS_BITS) + 1;

  BlissGraph* bliss_graph = bliss_new(n);

  for (i = 0; i < n; i++) {   // loop over vertices
    for (j = 0; j < d - 1; j++) { // loop over neighbours of vertex <i>
      for (k = 0; k < SYS_BITS; k++) {
        if (graph->neighbours[d * i + j] & oneone[k]) {
          bliss_add_edge(bliss_graph, i, SYS_BITS * j + k);
        }
      }
    }
    for (k = 0; k <=  ((n - 1) % SYS_BITS); k++) {
      if (graph->neighbours[d * i + j] & oneone[k]) {
        bliss_add_edge(bliss_graph, i, SYS_BITS * j + k);
      }
    }
  }
  return bliss_graph;
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

void bliss_hook (void               *user_param_arg,  // perm_coll!
	         unsigned int       N,
	         const unsigned int *aut            ) {

  UIntS i;
  Perm  p = new_perm();

  for (i = 0; i < (UIntS) N; i++) {
    p[i] = aut[i];
  }
  for (; i < deg; i++) {
    p[i] = i;
  }
  add_perm_coll((PermColl*) user_param_arg, p);
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

static PermColl* homos_find_automorphisms (HomosGraph* homos_graph) {

  BlissGraph* graph = as_bliss_graph(homos_graph);
  PermColl*   gens  = new_perm_coll(homos_graph->nr_verts - 1);
  bliss_find_automorphisms(graph, bliss_hook, gens, 0);
  bliss_release(graph);
  return gens;
}

////////////////////////////////////////////////////////////////////////////////
// homomorphism hook funcs
////////////////////////////////////////////////////////////////////////////////

void homo_hook_print () {
  UIntS i;

  printf("endomorphism image list: { ");
  printf("%d", map[0] + 1);
  for (i = 1; i < nr1; i++) {
    printf(", %d", map[i] + 1);
  }
  printf(" }\n");
}

////////////////////////////////////////////////////////////////////////////////
// TODO this should become redundant
////////////////////////////////////////////////////////////////////////////////

static void orbit_reps (UIntS rep_depth) {
  UIntS     nrgens, i, j, fst, m, img, n, max, d;
  Perm      gen;

  for (i = len_nr2 * rep_depth; i < len_nr2 * (rep_depth + 1); i++) {
    reps[i] = 0;
  }

  // TODO special case in case there are no gens, or just the identity.

  for (i = 0; i < len_nr2; i++){
    domain[i] = 0;
    orb_lookup[i] = 0;
  }

  for (i = 0; i < deg; i++) {
    d = i / SYS_BITS;
    m = i % SYS_BITS;
    if ((vals[d] & oneone[m]) == 0) {
      domain[d] |= oneone[m];
    }
  }

  fst = 0;
  while ( ((domain[fst / SYS_BITS] & oneone[fst % SYS_BITS]) == 0) && fst < deg) fst++;

  while (fst < deg) {
    d = fst / SYS_BITS;
    m = fst % SYS_BITS;
    reps[(len_nr2 * rep_depth) + d] |= oneone[m];
    orb[0] = fst;
    n = 1;   //length of orb
    orb_lookup[d] |= oneone[m];
    domain[d] ^= oneone[m];

    for (i = 0; i < n; i++) {
      for (j = 0; j < stab_gens[rep_depth]->nr_gens; j++) {
        gen = stab_gens[rep_depth]->gens[j];
        img = gen[orb[i]];
	d = img / SYS_BITS;
	m = img % SYS_BITS;
        if ((orb_lookup[d] & oneone[m]) == 0) {
          orb[n++] = img;
          orb_lookup[d] |= oneone[m];
          domain[d] ^= oneone[m];
        }
      }
    }
    while ( ((domain[fst / SYS_BITS] & oneone[fst % SYS_BITS]) == 0) && fst < deg) fst++;
  }
  return;
}

static BitArray* new_vals;
static BitArray* new_domain;
static BitArray* new_orb_lookup;

static BitArray** new_reps;

static void new_orbit_reps (UIntS rep_depth) {
  UIntS     nrgens, i, j, fst, m, img, n, max, d;
  Perm      gen;

  init_bit_array(new_reps[rep_depth], false);
  init_bit_array(new_domain, false);
  init_bit_array(new_orb_lookup, false);

  // TODO special case in case there are no gens, or just the identity.
  for (i = 0; i < deg; i++) {
    if (!get_bit_array(new_vals, i)) {
      set_bit_array(new_domain, i, true);
    }
  }

  fst = 0;
  while (fst < deg && !get_bit_array(new_domain, fst)) fst++;

  while (fst < deg) {
    orb[0] = fst;
    n = 1;   //length of orb
    
    set_bit_array(new_reps[rep_depth], fst, true);
    set_bit_array(new_orb_lookup, fst, true);
    set_bit_array(new_domain, fst, false);

    for (i = 0; i < n; i++) {
      for (j = 0; j < stab_gens[rep_depth]->nr_gens; j++) {
        gen = stab_gens[rep_depth]->gens[j];
        img = gen[orb[i]];
        if (!get_bit_array(new_orb_lookup, img)) {
          orb[n++] = img;
          set_bit_array(new_orb_lookup, img, true);
          set_bit_array(new_domain, img, false);
        }
      }
    }
    while (fst < deg && !get_bit_array(new_domain, fst)) fst++;
  }
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Conditions (for the homomorphism search)
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// keep track of what's available for assigning
////////////////////////////////////////////////////////////////////////////////

static UIntL* condition;

////////////////////////////////////////////////////////////////////////////////
// changed_condition[depth * i] the number of conditions updated at <depth>
// s.t. condition[depth * i + changed_condition[depth * i + j]] was updated
////////////////////////////////////////////////////////////////////////////////

static UIntS  changed_condition[MAXVERTS * (MAXVERTS + 1)];

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

static UIntS  len_condition[MAXVERTS * MAXVERTS / SYS_BITS];

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

static inline UIntL* get_condition (UIntS const i) {   // vertex in graph1
  return &condition[nr1 * len_nr2 * (len_condition[i] - 1) + len_nr2 * i];
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

static inline UIntL* push_condition(UIntS const depth,
                                    UIntS const i,         // vertex in graph1
                                    UIntL*      data  ) {  // len_nr2 * UIntL

  changed_condition[(nr1 + 1) * depth]++;
  changed_condition[(nr1 + 1) * depth + changed_condition[(nr1 + 1) * depth]] = i;
  memcpy((void *) &condition[nr1 * len_nr2 * len_condition[i] + len_nr2 * i],
         (void *) data,
	 (size_t) len_nr2 * sizeof(UIntL));
  len_condition[i]++;
  return &condition[nr1 * len_nr2 * (len_condition[i] - 1) + len_nr2 * i];
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

static inline void pop_condition (UIntS const depth) {
  UIntS i;
  for (i = 1; i < changed_condition[(nr1 + 1) * depth] + 1; i++) {
    len_condition[changed_condition[(nr1 + 1) * depth + i]]--;
  }
  changed_condition[(nr1 + 1) * depth] = 0;
}

////////////////////////////////////////////////////////////////////////////////
// initialises condition[i] to be cond for all i
// where cond is len_nr2 many UIntL's
////////////////////////////////////////////////////////////////////////////////

static void init_conditions (UIntL* cond) {
  UIntS i, j;

  condition = malloc(nr1 * nr1 * len_nr2 * sizeof(UIntL)); //JJ: calloc?
  nr_allocs++;
  for (i = 0; i < nr1; i++) {
    changed_condition[i + 1] = i;
    changed_condition[(nr1 + 1) * i] = 0;
    len_condition[i] = 1;

    for (j = 0; j < len_nr2; j++) {
      condition[len_nr2 * i + j] = cond[j];
    }
  }
  changed_condition[0] = nr1;
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

static inline void free_conditions_jmp() {
  unsigned int i, depth;
  free(condition);
  nr_frees++;
}

////////////////////////////////////////////////////////////////////////////////
// handling sizes
////////////////////////////////////////////////////////////////////////////////

static inline UIntS get_size_condition(UIntS const i) {   // vertex in graph1
  return sizes[nr1 * (len_condition[i] - 1) + i];
}

////////////////////////////////////////////////////////////////////////////////
// push_size_condition has to be used AFTER push_conditoin since it
// relies on len_condition to updated before
////////////////////////////////////////////////////////////////////////////////

static inline void push_size_condition(UIntS const i,       // vertex in graph1
                                       UIntS       size) {  // len_nr2 * UIntL

  sizes[nr1 * (len_condition[i] - 1) + i] = size;
}



#define IS_ADJACENT_1(i, j) neighbours1[i * len_nr1 + j / SYS_BITS] & oneone[j % SYS_BITS]

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// the main recursive algorithm
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static void find_graph_homos (UIntS   depth,        // the number of filled positions in map
                              UIntS   pos,          // the last position filled
                              UIntS   rep_depth,
                              bool    has_trivial_stab,
                              UIntS   rank      ) { // current number of distinct values in map

  UIntS   i, j, k, l, min, m, sum, w, size, next;
  UIntL*  copy;
  bool    is_trivial;

#if DEBUG
  calls1++;
  if (calls1 > last_report + report_interval) {
    printf("calls to search = %llu\n", calls1);
    printf("stabs computed = %llu\n", calls2);
    printf("nr allocs = %llu\n", nr_allocs);
    printf("nr frees = %llu\n", nr_frees);
    last_report = calls1;
  }
#endif

  if (depth == nr1) { // we've assigned every position in <map>
    if (hint != UNDEFINED && rank != hint) {
      return;
    }
    hook(user_param, nr1, map);
    count++;
    if (count >= maxresults) {
      free_conditions_jmp();
      longjmp(outofhere, 1);
    }
    return;
  }

  next = 0;      // the next position to fill
  min = nr2 + 1; // the minimum number of candidates for map[next]

  if (pos != UNDEFINED) {
    for (j = 0; j < nr1; j++) {
      i = j / SYS_BITS;
      m = j % SYS_BITS;
      if (map[j] == UNDEFINED) {
        if (IS_ADJACENT_1(pos, j)) {
          // vertex j is adjacent to vertex pos in graph1
          copy = push_condition(depth, j, get_condition(j));
          size = 0;
	  for (k = 0; k < nr2_d; k++){
            copy[k] &= neighbours2[len_nr2 * map[pos] + k];
            size += sizeUIntL(copy[k], SYS_BITS);
	  }
          copy[nr2_d] &= neighbours2[len_nr2 * map[pos] + nr2_d];
          size += sizeUIntL(copy[nr2_d], nr2_m + 1);
          if (size == 0) {
            pop_condition(depth);
            return;
          }
	  push_size_condition(j, size);
        }
        if (get_size_condition(j) < min) {
          next = j;
          min = get_size_condition(j);
        }
      }
    }
  }

  copy = get_condition(next);

  if (rank < hint) {
    for (i = 0; i < nr2; i++) {
      j = i / SYS_BITS;
      m = i % SYS_BITS;
      if ((copy[j] & reps[(len_nr2 * rep_depth) + j] & oneone[m])
          && (vals[j] & oneone[m]) == 0) {

        if (!has_trivial_stab) {
          calls2++;
          // stabiliser of the point i in the stabiliser at current rep_depth
          is_trivial = point_stabilizer(stab_gens[rep_depth], i, &stab_gens[rep_depth + 1]);
        }
        map[next] = i;
        vals[j] |= oneone[m];
        if (!has_trivial_stab) {
          // blist of orbit reps of things not in vals
          orbit_reps(rep_depth + 1);
          find_graph_homos(depth + 1, next, rep_depth + 1, is_trivial, rank + 1);
        } else {
          find_graph_homos(depth + 1, next, rep_depth, true, rank + 1);
        }
        map[next] = UNDEFINED;
        vals[j] ^= oneone[m];
      }
    }
  }
  for (i = 0; i < nr2; i++) {
    j = i / SYS_BITS;
    m = i % SYS_BITS;
    if (copy[j] & vals[j] & oneone[m]) {
      map[next] = i;
      find_graph_homos(depth + 1, next, rep_depth, has_trivial_stab, rank);
      map[next] = UNDEFINED;
    }
  }
  pop_condition(depth);
}

////////////////////////////////////////////////////////////////////////////////
// GraphHomomorphisms: prepare the graphs for find_graph_homos
////////////////////////////////////////////////////////////////////////////////

void GraphHomomorphisms (HomosGraph*  graph1,
                         HomosGraph*  graph2,
                         void         (*hook_arg)(void*        user_param,
	                                          const UIntS  nr,
	                                          const UIntS  *map       ),
                         void*        user_param_arg,
                         UIntL        max_results_arg,
                         int          hint_arg,
                         bool         isinjective,
                         int*         image,
                         UIntS        *partial_map           ) {
  PermColl* gens;
  UIntS     i, j, k, len, depth, pos, min, size, d, m, rep_depth, rank, next;
  UIntL*    copy;
  bool      has_trivial_stab, is_trivial;

  // debugging memory leaks in permutations & schreier-sims
  nr_ss_allocs = 0;
  nr_ss_frees = 0;
  nr_new_perm_coll = 0;
  nr_free_perm_coll = 0;

  nr1 = graph1->nr_verts;
  nr1_d = (nr1 - 1) / SYS_BITS;
  nr1_m = (nr1 - 1) % SYS_BITS;
  nr2 = graph2->nr_verts;
  nr2_d = (nr2 - 1) / SYS_BITS;
  nr2_m = (nr2 - 1) % SYS_BITS;
  len_nr1 = nr1_d + 1;
  len_nr2 = nr2_d + 1;

  assert(nr1 <= MAXVERTS && nr2 <= MAXVERTS);

  if (isinjective) {// && nr2 < nr1) { TODO uncomment when we have sm method for injective
    return;
  }

  UIntL new_image[len_nr2];
  if (image[0] == 0) { // image was not specified
    for (i = 0; i < nr2_d; i++) {
      new_image[i] = ones[SYS_BITS - 1];
    }
    new_image[nr2_d] = ones[nr2_m];
  } else {
    for (i = 0; i < nr2_d + 1; i++) {
      new_image[i] = 0;
      for (j = 0; j < image[0]; j++) {
        new_image[i] |= oneone[image[j + 1]];
      }
    }
  }
  init_conditions(new_image);

  for (i = 0; i < nr1; i++) {
    map[i] = UNDEFINED;
    push_size_condition(i, nr2);
  }

  for (i = 0; i < len_nr2; i++){
    vals[i] = 0;
  }

  memcpy((void *) neighbours1, graph1->neighbours, nr1 * len_nr1 * sizeof(UIntL));
  memcpy((void *) neighbours2, graph2->neighbours, nr2 * len_nr2 * sizeof(UIntL));

  // get generators of the automorphism group
  set_perms_degree(nr2);
  stab_gens[0] = homos_find_automorphisms(graph2);

  // get orbit reps
  orbit_reps(0);

  // misc parameters
  maxresults = max_results_arg;
  user_param = user_param_arg;
  hint = hint_arg;
  hook = hook_arg;

  // statistics . . .
  count = 0;
  last_report = 0;
  calls1 = 0;
  calls2 = 0;
  nr_allocs = 0;
  nr_frees = 0;

  // go!
  if (setjmp(outofhere) == 0) {
    if (isinjective) {
      //SEARCH_INJ_HOMOS_MD(0, -1, condition, gens, reps, hook,
      //Stabilizer);//TODO uncomment
    } else {
      // dealing with partial_map
      depth = 0;
      pos = UNDEFINED;
      rank = 0;
      rep_depth = 0;
      has_trivial_stab = false;

      for (next = 0; next < nr1; next++) {
        if (partial_map[next] != UNDEFINED) { // map[next] will get a new value
          if (pos != UNDEFINED) { // update conditions since
            for (j = 0; j < nr1; j++) {
              d = j / SYS_BITS;
              m = j % SYS_BITS;
              if (map[j] == UNDEFINED) {
                if (neighbours1[pos * len_nr1 + d] & oneone[m]) {
                  // vertex j is adjacent to vertex pos in graph1
                  copy = push_condition(depth, j, get_condition(j));
                  size = 0;
                  for (k = 0; k < nr2_d; k++){
                    copy[k] &= neighbours2[len_nr2 * map[pos] + k];
                    size += sizeUIntL(copy[k], SYS_BITS);
                  }
                  copy[nr2_d] &= neighbours2[len_nr2 * map[pos] + nr2_d];
                  size += sizeUIntL(copy[nr2_d], nr2_m + 1);
                  if (size == 0) {
                    pop_condition(depth);
                    return;
                  }
                  push_size_condition(j, size);
                }
              }
            }
	  }

          copy = get_condition(next);

          // calculate stabs
	  // JJ: should we check rank < hint?
          d = partial_map[next] / SYS_BITS;
          m = partial_map[next] % SYS_BITS;
          if ((vals[d] & oneone[m]) == 0) {
            rank++;
            if (!has_trivial_stab) {
              calls2++;
              // stabiliser of the point i in the stabiliser at current rep_depth
              is_trivial = point_stabilizer(stab_gens[rep_depth],
                                            partial_map[next],
                                            &stab_gens[rep_depth + 1]);
            }
      	    map[next] = partial_map[next];
	    depth++;
            vals[d] |= oneone[m];
            if (!has_trivial_stab) {
              // blist of orbit reps of things not in vals
              rep_depth++;
              orbit_reps(rep_depth);
            }
          } else {
      	    map[next] = partial_map[next];
	    depth++;
          }
	  pos = next;
        }
      }
      find_graph_homos(depth, pos, rep_depth, has_trivial_stab, rank);
    }
  }

  // free the stab_gens
  for (i = 0; i < MAXVERTS; i++) {
    if (stab_gens[i] != NULL) {
      free_perm_coll(stab_gens[i]);
      stab_gens[i] = NULL;
    }
  }

  // debugging memory leaks
#if DEBUG
  printf("\n");
  printf("nr ss allocs = %llu\n", (unsigned long long int) nr_ss_allocs );
  printf("nr ss frees = %llu\n", (unsigned long long int) nr_ss_frees );
  printf("new perm colls = %llu\n", (unsigned long long int) nr_new_perm_coll );
  printf("perm colls freed = %llu\n", (unsigned long long int) nr_free_perm_coll );
  printf("\n");
  printf("calls to search = %llu\n", calls1);
  printf("stabs computed = %llu\n",  calls2);
#endif
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// bit arrays
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// NUMBER_BITS_PER_BLOCK: the number of bits in every Block
////////////////////////////////////////////////////////////////////////////////

#define NUMBER_BITS_PER_BLOCK (sizeof(Block) * CHAR_BIT)

////////////////////////////////////////////////////////////////////////////////
// COUNT_TRUES_BLOCK: this is from gap/src/blister.h
////////////////////////////////////////////////////////////////////////////////

#if SIZEOF_VOID_P == 8
#define COUNT_TRUES_BLOCK( block )                                                          \
        do {                                                                                \
        (block) = ((block) & 0x5555555555555555L) + (((block) >> 1) & 0x5555555555555555L); \
        (block) = ((block) & 0x3333333333333333L) + (((block) >> 2) & 0x3333333333333333L); \
        (block) = ((block) + ((block) >>  4)) & 0x0f0f0f0f0f0f0f0fL;                        \
        (block) = ((block) + ((block) >>  8));                                              \
        (block) = ((block) + ((block) >> 16));                                              \
        (block) = ((block) + ((block) >> 32)) & 0x00000000000000ffL; } while (0)            

#else

#define COUNT_TRUES_BLOCK( block )                                        \
        do {                                                              \
        (block) = ((block) & 0x55555555) + (((block) >> 1) & 0x55555555); \
        (block) = ((block) & 0x33333333) + (((block) >> 2) & 0x33333333); \
        (block) = ((block) + ((block) >>  4)) & 0x0f0f0f0f;               \
        (block) = ((block) + ((block) >>  8));                            \
        (block) = ((block) + ((block) >> 16)) & 0x000000ff; } while (0)   
#endif

////////////////////////////////////////////////////////////////////////////////
// new_bit_array: get a pointer to a new BitArray with space for <nr_bits>
// bits, and with every bit set to false.
////////////////////////////////////////////////////////////////////////////////

BitArray* new_bit_array (UIntS nr_bits) {

  BitArray* bit_array = malloc(sizeof(BitArray));

  bit_array->nr_bits   = nr_bits;
  bit_array->nr_blocks = (nr_bits / NUMBER_BITS_PER_BLOCK) + 1;
  bit_array->blocks    = calloc(bit_array->nr_blocks, NUMBER_BITS_PER_BLOCK);
  return bit_array;
}

////////////////////////////////////////////////////////////////////////////////
// set_bit_array: set the <pos>th bit of the BitArray pointed to by <bit_array>
// to the value <val>.
////////////////////////////////////////////////////////////////////////////////

inline void set_bit_array (BitArray* bit_array, UIntS pos, bool val) {
  assert(pos < bit_array->nr_bits);
  if (val) {
    bit_array->blocks[pos / NUMBER_BITS_PER_BLOCK] |= oneone[pos % NUMBER_BITS_PER_BLOCK];
  } else {
    bit_array->blocks[pos / NUMBER_BITS_PER_BLOCK] &= ~oneone[pos % NUMBER_BITS_PER_BLOCK];
  }
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

static void free_bit_array (BitArray* bit_array) {
  free(bit_array->blocks);
  //free(bit_array); //TODO correct?
}

////////////////////////////////////////////////////////////////////////////////
// init_bit_array: set every value in the BitArray pointed to by <bit_array> to
// the value <val>.
////////////////////////////////////////////////////////////////////////////////

inline void init_bit_array (BitArray* bit_array, bool val) {
  assert(bit_array != NULL);
  UIntS i;
  if (val) {
    for (i = 0; i < bit_array->nr_blocks; i++) {
      bit_array->blocks[i] = (Block) -1;
    }
  } else {
    for (i = 0; i < bit_array->nr_blocks; i++) {
      bit_array->blocks[i] = 0;
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
// get_bit_array: get the value in position <pos> of the BitArray pointer
// <bit_array>.
////////////////////////////////////////////////////////////////////////////////

inline bool get_bit_array (BitArray* bit_array, UIntS pos) {
  assert(pos < bit_array->nr_bits);
  return bit_array->blocks[pos / NUMBER_BITS_PER_BLOCK] & oneone[pos % NUMBER_BITS_PER_BLOCK];
}

////////////////////////////////////////////////////////////////////////////////
// copy_bit_array: get a pointer to a new BitArray which is identical to the
// BitArray pointed to by <old>.
////////////////////////////////////////////////////////////////////////////////

static inline BitArray* copy_bit_array (BitArray* old) {
  UIntS i;
  BitArray* new = new_bit_array(old->nr_bits);
  for (i = 0; i < old->nr_blocks; i++) {
    new->blocks[i] = old->blocks[i];
  }
  return new;
}

////////////////////////////////////////////////////////////////////////////////
// intersect_bit_arrays: interesect the BitArrays pointed to by <bit_array1>
// and <bit_array2>. The BitArray pointed to by <bit_array1> is changed in
// place!!
////////////////////////////////////////////////////////////////////////////////

static inline BitArray* intersect_bit_arrays (BitArray* bit_array1,
                                       BitArray* bit_array2) {
  assert(bit_array1->nr_bits == bit_array2->nr_bits);
  assert(bit_array1->nr_blocks == bit_array2->nr_blocks);

  UIntS i;
  for (i = 0; i < bit_array1->nr_blocks; i++) {
    bit_array1->blocks[i] &= bit_array2->blocks[i];
  }
  return bit_array1;
}

////////////////////////////////////////////////////////////////////////////////
// size_bit_arrays: interesect the BitArrays pointed to by <bit_array1>
// and <bit_array2>. The BitArray pointed to by <bit_array1> is changed in
// place!!
////////////////////////////////////////////////////////////////////////////////

static inline UIntS size_bit_array (BitArray* bit_array) {
  UIntS  n, i;
  Block  m;
  UIntS  nrb    = bit_array->nr_blocks;
  Block* blocks = bit_array->blocks;

  /* loop over the blocks, adding the number of bits of each one         */
  n = 0;
  for ( i = 1; i <= nrb; i++ ) {
      m = *blocks++;
      COUNT_TRUES_BLOCK(m);
      n += m;
  }

  return n;
}

/*static inline UIntS size_bit_array (BitArray* bit_array) {
UIntS i, out = 0;
  for (i = 0; i < bit_array->nr_bits; i++) {
    if (get_bit_array(bit_array, i)) {
      out++;
    }
  }
  return out;
}*/

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// digraphs
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
 
////////////////////////////////////////////////////////////////////////////////
// new_digraph: returns a pointer to a Digraph with nr_verts vertices and no
// edges.
////////////////////////////////////////////////////////////////////////////////

Digraph* new_digraph (UIntS const nr_verts) {
  UIntS i;
  Digraph* digraph        = malloc(sizeof(Digraph));
  digraph->in_neighbours  = malloc(nr_verts * sizeof(BitArray));
  digraph->out_neighbours = malloc(nr_verts * sizeof(BitArray));
  init_bit_tabs();
  for (i = 0; i < nr_verts; i++) {
    digraph->in_neighbours[i] = new_bit_array(nr_verts);
    digraph->out_neighbours[i] = new_bit_array(nr_verts);
  }
  digraph->nr_vertices = nr_verts;
  return digraph;
}

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

void free_digraph (Digraph* digraph) {
  UIntS i, nr = digraph->nr_vertices;

  for (i = 0; i < nr; i++) {
    free(digraph->in_neighbours[i]);
    free(digraph->out_neighbours[i]);
  }
  free(digraph->in_neighbours);
  free(digraph->out_neighbours);
  free(digraph);
}

////////////////////////////////////////////////////////////////////////////////
// add_edge_digraph: add an edge from Vertex <i> to Vertex <j> in the Digraph
// pointed to by <digraph>.
////////////////////////////////////////////////////////////////////////////////

void add_edge_digraph (Digraph* digraph,
                       Vertex   i,
                       Vertex   j       ) {
  assert(i < digraph->nr_vertices && j < digraph->nr_vertices);
  set_bit_array(digraph->out_neighbours[i], j, true);
  set_bit_array(digraph->in_neighbours[j], i, true);
}

////////////////////////////////////////////////////////////////////////////////
// is_adjacent_digraph: returns <true> if there is an edge from <i> to <j> in the
// Digraph pointed to by <digraph> and returns <false> if there is not.
////////////////////////////////////////////////////////////////////////////////

static bool inline is_adjacent_digraph (Digraph* digraph,
                                 Vertex   i,
                                 Vertex   j       ) {
  assert(i < digraph->nr_vertices && j < digraph->nr_vertices);
  return get_bit_array(digraph->out_neighbours[i], j);
}

////////////////////////////////////////////////////////////////////////////////
// 
////////////////////////////////////////////////////////////////////////////////

static BlissGraph* new_bliss_graph_from_digraph (Digraph* digraph) {
  UIntS  i, j, k, l;
  UIntS  n = digraph->nr_vertices;

  BlissGraph* bliss_graph = bliss_new(n);

  for (i = 0; i < n; i++) {       // loop over vertices
    for (j = 0; j < n; j++) {
      if (is_adjacent_digraph(digraph, i, j)) {
        k = bliss_add_vertex(bliss_graph, 1);
        l = bliss_add_vertex(bliss_graph, 2);
        bliss_add_edge(bliss_graph, i, k);
        bliss_add_edge(bliss_graph, k, l);
        bliss_add_edge(bliss_graph, l, j);
      }
    }
  }
  return bliss_graph;
}

////////////////////////////////////////////////////////////////////////////////
// 
////////////////////////////////////////////////////////////////////////////////

static void bliss_hook_digraph (void               *user_param_arg,  // perm_coll!
         	                unsigned int       N,
	                        const unsigned int *aut            ) {

  UIntS        i;
  Perm         p = new_perm();
  // TODO should restrict to the vertices [1..n] only and not include the
  // vertices of colours 1 and 2 (which are only used to indicate the direct of
  // edges. Not sure how to do this.

  UIntS min = (N < deg ? N : deg); 

  for (i = 0; i < min; i++) {
    p[i] = aut[i];
  }
  for (; i < deg; i++) {
    p[i] = i;
  }
  add_perm_coll((PermColl*) user_param_arg, p);
}

////////////////////////////////////////////////////////////////////////////////
// 
////////////////////////////////////////////////////////////////////////////////

static PermColl* automorphisms_digraph (Digraph* digraph) {
  BlissGraph* bliss_graph = new_bliss_graph_from_digraph(digraph);
  PermColl*   gens  = new_perm_coll(digraph->nr_vertices - 1);
  bliss_find_automorphisms(bliss_graph, bliss_hook_digraph, gens, 0);
  bliss_release(bliss_graph);
  return gens;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// conditions: this is a data structure for keeping track of what possible
// values a vertex can be mapped to by a partially defined homomorphism, given
// the existing values where the homomorphism is defined.
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Conditions: struct to contain the data. If <nr1> is the number of vertices
// in the source di/graph and <nr2> is the number of vertices in the range
// di/graph, then
//
//  ^
//  |
//  |
//  |
//  |                +------------+
//                   | BitArray*  |
//  n                | length nr2 |
//  r                +------------+                    +------------+
//  1                | BitArray*  |                    | BitArray*  |
//                   | length nr2 |                    | length nr2 |
//  r                +------------+------------+       +------------+
//  o                | BitArray*  | BitArray*  |       | BitArray*  |
//  w                | length nr2 | length nr2 |       | length nr2 |
//  s   +------------+------------+------------+ - -  -+------------+
//      | BitArray*  | BitArray*  | BitArray*  |       | BitArray*  |
//  |   | length nr2 | length nr2 | length nr2 |       | length nr2 |
//  v   +------------+------------+------------+ - -  -+------------+
//
//      <--------------------------- nr1 columns ------------------->
//
//  The BitArray pointed to in row <i+1> and column <j> row is the intersection
//  of the BitArray pointed to in row <i> and column <j> with some other
//  BitArray (the things adjacent to some vertex in graph2).
//
////////////////////////////////////////////////////////////////////////////////

struct conditions_struct {
  BitArray** bit_array; // nr1 * nr1 array of bit arrays of length nr2
  UIntS*     changed;
  UIntS*     height;
  UIntS*     sizes;
  UIntS      nr1;
  UIntS      nr2;
};

typedef struct conditions_struct Conditions;

////////////////////////////////////////////////////////////////////////////////
// new_conditions: returns a pointer to a Conditions with one complete
// row where every bit is set to true.
////////////////////////////////////////////////////////////////////////////////

static Conditions* new_conditions (UIntS      nr1,
                                   UIntS      nr2) {
  UIntS i, j;
  Conditions* conditions = malloc(sizeof(Conditions));

  conditions->bit_array = malloc(sizeof(BitArray*) * nr1 * nr1);
  conditions->changed   = malloc(nr1 * (nr1 + 1) * sizeof(UIntS));
  conditions->height    = malloc(nr1 * sizeof(UIntS));
  conditions->sizes     = malloc(nr1 * nr1 * sizeof(UIntS));
  conditions->nr1       = nr1;
  conditions->nr2       = nr2;

  for (i = 0; i < nr1 * nr1; i++) {
    conditions->bit_array[i] = new_bit_array(nr2);
  }
  for (i = 0; i < nr1; i++) {
    init_bit_array(conditions->bit_array[i], true);
    conditions->changed[i + 1] = i;
    conditions->changed[(nr1 + 1) * i] = 0;
    conditions->height[i] = 1;
  }
  conditions->changed[0] = nr1;
  return conditions;
}

////////////////////////////////////////////////////////////////////////////////
// 
////////////////////////////////////////////////////////////////////////////////

static void free_conditions (Conditions* conditions) {
  UIntS i;
  for (i = 0; i < conditions->nr1 * conditions->nr1; i++) {
    free_bit_array(conditions->bit_array[i]);
  }
  free(conditions->bit_array);
  free(conditions->changed);
  free(conditions->height);
  free(conditions->sizes);
  free(conditions);
}

////////////////////////////////////////////////////////////////////////////////
// get_conditions: returns the top most BitArray* in column <i>.
////////////////////////////////////////////////////////////////////////////////

static inline BitArray* get_conditions (Conditions*  conditions,
                                        Vertex const i          ) {
  return conditions->bit_array[conditions->nr1 * (conditions->height[i] - 1) + i];
}

////////////////////////////////////////////////////////////////////////////////
// store_size_conditions: store the size of the BitArray pointed to at the top
// of column <i>.
////////////////////////////////////////////////////////////////////////////////

static inline void store_size_conditions (Conditions*  conditions,
                                          Vertex const i          ) {
  UIntS nr1 = conditions->nr1;
  conditions->sizes[nr1 * (conditions->height[i] - 1) + i]
    = size_bit_array(get_conditions(conditions, i));
  //FIXME why the -1 here???
}

////////////////////////////////////////////////////////////////////////////////
// push_conditions: copy the top of the <i>th column of the <conditions> and
// intersect it with <bit_array> and then push this onto the top of the <i>th
// column. If the argument <bit_array> is NULL, than the intersection
// does not happen.
////////////////////////////////////////////////////////////////////////////////

static inline void push_conditions (Conditions*  conditions,
                                    UIntS const  depth, //TODO remove this (as an argument here)
                                    Vertex const i,
                                    BitArray*    bit_array) {
  assert(conditions != NULL);
  //TODO add more asserts here
  UIntS j, k;
  UIntS nr1 = conditions->nr1;
  UIntS nr2 = conditions->nr2;

  memcpy((void *) conditions->bit_array[nr1 * conditions->height[i] + i]->blocks,
         (void *) conditions->bit_array[nr1 * (conditions->height[i] - 1) + i]->blocks, 
	 (size_t) conditions->bit_array[0]->nr_blocks * sizeof(Block));

  conditions->changed[(nr1 + 1) * depth]++;
  conditions->changed[(nr1 + 1) * depth + conditions->changed[(nr1 + 1) * depth]] = i;

  conditions->height[i]++;
  
  if (bit_array != NULL) {
    intersect_bit_arrays(get_conditions(conditions, i), bit_array);
  }

  store_size_conditions(conditions, i);
}

////////////////////////////////////////////////////////////////////////////////
// pop_conditions: pop the tops off all of the columns which were last push on.
////////////////////////////////////////////////////////////////////////////////

static inline void pop_conditions (Conditions* conditions,
                                   UIntS const depth      ) { //TODO remove this as an argument
  //TODO add asserts here
  UIntS i;
  UIntS nr1 = conditions->nr1;
  UIntS nr2 = conditions->nr2;

  for (i = 1; i < conditions->changed[(nr1 + 1) * depth] + 1; i++) {
    conditions->height[conditions->changed[(nr1 + 1) * depth + i]]--;
  }
  conditions->changed[(nr1 + 1) * depth] = 0;
}

////////////////////////////////////////////////////////////////////////////////
// size_conditions: return the size of the BitArray pointed to by the top of
// the <i>th column.
////////////////////////////////////////////////////////////////////////////////

static inline UIntS size_conditions (Conditions*  conditions,
                                     Vertex const i          ) {
  //TODO add asserts here
  return conditions->sizes[conditions->nr1 * (conditions->height[i] - 1) + i];
}

////////////////////////////////////////////////////////////////////////////////
// temporary
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// new main algorithm
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static void find_digraph_homos (Digraph*    digraph1,
                                Digraph*    digraph2, 
                                Conditions* conditions,
                                UIntS       depth,               // the number of filled positions in map
                                UIntS       pos,                 // the last position filled
                                UIntS       rep_depth,
                                bool        has_trivial_stab,
                                UIntS       rank             ) { // current number of distinct values in map

  UIntS   i, min, next;
  bool    is_trivial;

  if (depth == nr1) { // we've assigned every position in <map>
    if (hint != UNDEFINED && rank != hint) {
      return;
    }
    hook(user_param, nr1, map);
    count++;
    if (count >= maxresults) {
      longjmp(outofhere, 1);
    }
    return;
  }

  next = 0;         // the next position to fill
  min  = UNDEFINED; // the minimum number of candidates for map[next]

  if (pos != UNDEFINED) { // this is not the first call of the function
    for (i = 0; i < nr1; i++) {
      if (map[i] == UNDEFINED) {
        if (is_adjacent_digraph(digraph1, pos, i)) {
          push_conditions(conditions, depth, i, digraph2->out_neighbours[map[pos]]);
          if (is_adjacent_digraph(digraph1, i, pos)) {
            intersect_bit_arrays(get_conditions(conditions, i),
                                 digraph2->in_neighbours[map[pos]]);
          }
          if (size_conditions(conditions, i) == 0) {
            pop_conditions(conditions, depth);
            return;
          }
        } else if (is_adjacent_digraph(digraph1, i, pos)) {
          push_conditions(conditions, depth, i, digraph2->in_neighbours[map[pos]]);
          if (size_conditions(conditions, i) == 0) {
            pop_conditions(conditions, depth);
            return;
          }
        }
        if (size_conditions(conditions, i) < min) {
          next = i;
          min = size_conditions(conditions, i);
        }
      }
    }
  }
  BitArray* possible = get_conditions(conditions, next);

  if (rank < hint) {
    for (i = 0; i < nr2; i++) {
      if (get_bit_array(possible, i)
          && !get_bit_array(new_vals, i)
          && get_bit_array(new_reps[rep_depth], i)) {
        if (!has_trivial_stab) {
          // stabiliser of the point i in the stabiliser at current rep_depth
          is_trivial = point_stabilizer(stab_gens[rep_depth], i, &stab_gens[rep_depth + 1]);
        }
        map[next] = i;
        set_bit_array(new_vals, i, true);
        if (!has_trivial_stab) {
          if (depth != nr1 - 1) {
            new_orbit_reps(rep_depth + 1);
          }
          find_digraph_homos(digraph1, digraph2, conditions, depth + 1, next,
                             rep_depth + 1, is_trivial, rank + 1);
        } else {
          find_digraph_homos(digraph1, digraph2, conditions, depth + 1, next,
                             rep_depth, true, rank + 1);
        }
        map[next] = UNDEFINED;
        set_bit_array(new_vals, i, false);
      }
    }
  }

  for (i = 0; i < nr2; i++) {
    if (get_bit_array(possible, i) && get_bit_array(new_vals, i)) {
      map[next] = i;
      find_digraph_homos(digraph1, digraph2, conditions, depth + 1, next,
                         rep_depth, has_trivial_stab, rank);
      map[next] = UNDEFINED;
    }
  }
  pop_conditions(conditions, depth);
}

////////////////////////////////////////////////////////////////////////////////
// DigraphHomomorphisms: the function which calls the main recursive function 
// <find_digraph_homos>.
////////////////////////////////////////////////////////////////////////////////

void DigraphHomomorphisms (Digraph* digraph1,
                           Digraph* digraph2,
                           void     (*hook_arg)(void*        user_param,
	                                        const UIntS  nr,
	                                        const UIntS  *map       ),
                           void*     user_param_arg,
                           UIntL     max_results_arg,
                           int       hint_arg,
                           BitArray* image,
                           UIntS     *partial_map                          ) {
  PermColl* gens;
  UIntS     i, j;
  BitArray* mask;
  
  init_bit_tabs();
  
  nr1 = digraph1->nr_vertices;
  nr2 = digraph2->nr_vertices;

  assert(nr1 <= MAXVERTS && nr2 <= MAXVERTS);
  
  // initialise the conditions . . .
  Conditions* conditions = new_conditions(nr1, nr2);
  
  if (image != NULL) { // image was specified
    for (i = 0; i < nr1; i++) {
      intersect_bit_arrays(get_conditions(conditions, i), image);
      // intersect everything in the first row of conditions with <image>
    }
  }

  if (partial_map != NULL) { // a partial map was defined
    for (i = 0; i < nr1; i++) {
      if (partial_map[i] != UNDEFINED) {
        mask = new_bit_array(nr2); // every position is false by default
        set_bit_array(mask, partial_map[i], true);
        intersect_bit_arrays(get_conditions(conditions, i), mask);
      }
    }
  }

  // find loops in digraph2
  BitArray* loops = new_bit_array(nr2);

  for (i = 0; i < nr2; i++) {
    if (is_adjacent_digraph(digraph2, i, i)) {
      set_bit_array(loops, i, true);
    }
  }
  
  // loops in digraph1 can only map to loops in digraph2
  for (i = 0; i < nr1; i++) {
    if (is_adjacent_digraph(digraph1, i, i)) {
      intersect_bit_arrays(get_conditions(conditions, i), loops);
    }
  }

  // store the values in <map>, this is initialised to every bit set to false,
  // by default.
  new_vals       = new_bit_array(nr2);
  new_domain     = new_bit_array(nr2);
  new_orb_lookup = new_bit_array(nr2);
  new_reps       = malloc(nr1 * sizeof(BitArray*));

  // initialise the <map> and store the sizes in the conditions. 
  for (i = 0; i < nr1; i++) {
    new_reps[i] = new_bit_array(nr2);
    map[i] = UNDEFINED;
    store_size_conditions(conditions, i);
  }

  // get generators of the automorphism group of digraph2
  set_perms_degree(nr2);
  stab_gens[0] = automorphisms_digraph(digraph2);

  // get orbit reps
  new_orbit_reps(0);

  // misc parameters
  maxresults = max_results_arg;
  user_param = user_param_arg;
  hint = hint_arg;
  hook = hook_arg;

  // statistics . . .
  count = 0;
  last_report = 0;

  // go!
  if (setjmp(outofhere) == 0) {
    find_digraph_homos(digraph1, digraph2, conditions, 0, UNDEFINED, 0,
                         false, 0);
  }

  // free the stab_gens
  for (i = 0; i < MAXVERTS; i++) {
    if (stab_gens[i] != NULL) {
      free_perm_coll(stab_gens[i]);
      stab_gens[i] = NULL;
    }
  }
  free_conditions(conditions);
}

////////////////////////////////////////////////////////////////////////////////
// a version of new main algorithm for injective homomorphisms
////////////////////////////////////////////////////////////////////////////////

static void find_digraph_monos (Digraph*    digraph1,
                                Digraph*    digraph2, 
                                Conditions* conditions,
                                UIntS       depth,               // the number of filled positions in map
                                UIntS       pos,                 // the last position filled
                                UIntS       rep_depth,
                                bool        has_trivial_stab,
                                UIntS       rank             ) { // current number of distinct values in map

  UIntS   i, min, next;
  bool    is_trivial;

  if (depth == nr1) { // we've assigned every position in <map>
    hook(user_param, nr1, map);
    count++;
    if (count >= maxresults) {
      longjmp(outofhere, 1);
    }
    return;
  }

  next = 0;         // the next position to fill
  min  = UNDEFINED; // the minimum number of candidates for map[next]

  if (pos != UNDEFINED) { // this is not the first call of the function
    for (i = 0; i < nr1; i++) {
      if (map[i] == UNDEFINED) {
        push_conditions(conditions, depth, i, NULL);
	set_bit_array(get_conditions(conditions, i), map[pos], false); 
	  //this could be optimised since map[pos] is fixes within the loop
        if (is_adjacent_digraph(digraph1, pos, i)) {
          intersect_bit_arrays(get_conditions(conditions, i),
                               digraph2->in_neighbours[map[pos]]);
	}
        if (is_adjacent_digraph(digraph1, i, pos)) {
          intersect_bit_arrays(get_conditions(conditions, i),
                               digraph2->in_neighbours[map[pos]]);
        }
        if (size_conditions(conditions, i) == 0) {
          pop_conditions(conditions, depth);
          return;
        }
        if (size_conditions(conditions, i) < min) {
          next = i;
          min = size_conditions(conditions, i);
        }
      } 
    }
  }
  
  BitArray* possible = get_conditions(conditions, next);

  for (i = 0; i < nr2; i++) {
    if (get_bit_array(possible, i)
        && get_bit_array(new_reps[rep_depth], i)) {
      if (!has_trivial_stab) {
        // stabiliser of the point i in the stabiliser at current rep_depth
        is_trivial = point_stabilizer(stab_gens[rep_depth], i, &stab_gens[rep_depth + 1]);
      }
      map[next] = i;
      set_bit_array(new_vals, i, true);
      if (!has_trivial_stab) {
        if (depth != nr1 - 1) {
          new_orbit_reps(rep_depth + 1);
        }
        find_digraph_monos(digraph1, digraph2, conditions, depth + 1, next,
                           rep_depth + 1, is_trivial, rank + 1);
      } else {
        find_digraph_monos(digraph1, digraph2, conditions, depth + 1, next,
                           rep_depth, true, rank + 1);
      }
      map[next] = UNDEFINED;
      set_bit_array(new_vals, i, false);
    }
  }
  

  pop_conditions(conditions, depth);
}

////////////////////////////////////////////////////////////////////////////////
// DigraphMonomorphisms: the function which calls the main recursive function 
// <find_digraph_monos>.
////////////////////////////////////////////////////////////////////////////////
//
void DigraphMonomorphisms (Digraph* digraph1,
                           Digraph* digraph2,
                           void     (*hook_arg)(void*        user_param,
	                                        const UIntS  nr,
	                                        const UIntS  *map       ),
                           void*     user_param_arg,
                           UIntL     max_results_arg,
                           BitArray* image,
                           UIntS     *partial_map                          ) {
  PermColl* gens;
  UIntS     i, j;
  BitArray* mask;
  BitArray* image_vals;
  
  init_bit_tabs();
  
  nr1 = digraph1->nr_vertices;
  nr2 = digraph2->nr_vertices;

  assert(nr1 <= MAXVERTS && nr2 <= MAXVERTS);
  
  // initialise the conditions . . .
  Conditions* conditions = new_conditions(nr1, nr2);
  
  if (image != NULL) { // image was specified
    if (size_bit_array(image) < nr1) { 
      // there isn't enought points in the image
      return;
    } else {
      for (i = 0; i < nr1; i++) {
        intersect_bit_arrays(get_conditions(conditions, i), image);
        // intersect everything in the first row of conditions with <image>
      }
    }
  }

  if (partial_map != NULL) { // a partial map was defined
    image_vals = new_bit_array(nr2); // values in the image of partial_map
    for (i = 0; i < nr1; i++) {
      if (partial_map[i] != UNDEFINED) {
	if (get_bit_array(image_vals, partial_map[i])) {
	  return; // partial_map is not injective
	} else{
	  set_bit_array(image_vals, partial_map[i], true);
	}
        mask = new_bit_array(nr2); // every position is false by default
        set_bit_array(mask, partial_map[i], true);
        intersect_bit_arrays(get_conditions(conditions, i), mask);
      } 
    }
  }

  // find loops in digraph2
  BitArray* loops = new_bit_array(nr2);

  for (i = 0; i < nr2; i++) {
    if (is_adjacent_digraph(digraph2, i, i)) {
      set_bit_array(loops, i, true);
    }
  }
  
  // loops in digraph1 can only map to loops in digraph2
  for (i = 0; i < nr1; i++) {
    if (is_adjacent_digraph(digraph1, i, i)) {
      intersect_bit_arrays(get_conditions(conditions, i), loops);
    }
  }

  // store the values in <map>, this is initialised to every bit set to false,
  // by default.
  new_vals       = new_bit_array(nr2);
  new_domain     = new_bit_array(nr2);
  new_orb_lookup = new_bit_array(nr2);
  new_reps       = malloc(nr1 * sizeof(BitArray*));

  // initialise the <map> and store the sizes in the conditions. 
  for (i = 0; i < nr1; i++) {
    new_reps[i] = new_bit_array(nr2);
    map[i] = UNDEFINED;
    store_size_conditions(conditions, i);
  }

  // get generators of the automorphism group of digraph2
  set_perms_degree(nr2);
  stab_gens[0] = automorphisms_digraph(digraph2);

  // get orbit reps
  new_orbit_reps(0);

  // misc parameters
  maxresults = max_results_arg;
  user_param = user_param_arg;
  hook = hook_arg;

  // statistics . . .
  count = 0;
  last_report = 0;

  // go!
  if (setjmp(outofhere) == 0) {
    find_digraph_monos(digraph1, digraph2, conditions, 0, UNDEFINED, 0,
                       false, 0);
  }

  // free the stab_gens
  for (i = 0; i < MAXVERTS; i++) {
    if (stab_gens[i] != NULL) {
      free_perm_coll(stab_gens[i]);
      stab_gens[i] = NULL;
    }
  }
  free_conditions(conditions);
}
