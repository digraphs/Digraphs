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

#define UNDEFINED MAXVERTS + 1

// globals for the recursive find_homos
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
static unsigned long long calls1;          // calls1 is the nr of calls to find_homos
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

// initial the bit tabs

static void init_bit_tabs (void) { 
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

// number of 1s in the binary expansion of an array consisting of <m> UIntLs

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

// creating graphs . . . 

HomosGraph* new_homos_graph (UIntS const nr_verts) {
  HomosGraph* graph = malloc(sizeof(HomosGraph));
  graph->neighbours = calloc(((nr_verts - 1) / SYS_BITS + 1) * nr_verts, sizeof(UIntL));
  graph->nr_verts = nr_verts;
  init_bit_tabs();
  return graph;
}

void free_homos_graph (HomosGraph* graph) {
  if (graph->neighbours != NULL) {
    free(graph->neighbours);
  }
}

void add_edges_homos_graph (HomosGraph* graph, UIntS from_vert, UIntS to_vert) {
  graph->neighbours[((graph->nr_verts - 1) / SYS_BITS + 1) * from_vert + (to_vert / SYS_BITS)] |= oneone[to_vert % SYS_BITS];
}

// automorphism group . . . 

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

void auto_hook (void               *user_param_arg,  // perm_coll!
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

static PermColl* homos_find_automorphisms (HomosGraph* homos_graph) {
  
  BlissGraph* graph = as_bliss_graph(homos_graph);
  PermColl*   gens  = new_perm_coll(homos_graph->nr_verts - 1);
  bliss_find_automorphisms(graph, auto_hook, gens, 0);
  bliss_release(graph);
  return gens;
}

// homomorphism hook funcs

void homo_hook_print () {
  UIntS i;

  printf("endomorphism image list: { ");
  printf("%d", map[0] + 1);
  for (i = 1; i < nr1; i++) {
    printf(", %d", map[i] + 1);
  }
  printf(" }\n");
}

// TODO this should become redundant

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

// for handling the conditions
static UIntL* condition; // keep track of what's available for assigning
static bool   alloc_condition[MAXVERTS * MAXVERTS]; 
                                              // alloc_conditions[depth * i + j] = true if we allocated 
                                              // condition[depth * i + j] at <depth> 
static UIntS  len_condition[MAXVERTS * MAXVERTS / SYS_BITS];

static inline UIntL* get_condition(UIntS const i) {   // vertex in graph1
  return &condition[nr1 * (len_condition[i] - 1) + i];
}

static inline UIntL* push_condition(UIntS const depth, 
                                    UIntS const i,         // vertex in graph1
                                    UIntL*      data  ) {  // len_nr2 * UIntL
  alloc_condition[nr1 * depth + i] = true;
  memcpy((void *)condition[nr1 * len_condition[i] + i], (void *) data, (size_t) len_nr2 * sizeof(UIntL));
  len_condition[i]++;
  return &condition[nr1 * (len_condition[i] - 1) + i];
}

static inline void pop_condition(UIntS const depth) {
  UIntS i;
  for (i = 0; i < nr1; i++) {
    if (alloc_condition[nr1 * depth + i]) {
      len_condition[i]--;
      alloc_condition[nr1 * depth + i] = false;
    }
  }
}

static void init_conditions() {
  UIntS i, j; 

  condition = malloc(nr1 * nr1 * len_nr2 * sizeof(UIntL)); //JJ: calloc?
  nr_allocs++;
  for (i = 0; i < nr1; i++) {
    alloc_condition[i] = true;
    len_condition[i] = 1;

    for (j = 0; j < len_nr2 - 1; j++) {
      condition[nr1 * i + j] = ones[SYS_BITS - 1];
    }
    condition[nr1 * i + len_nr2 - 1] = ones[nr2_m];

    for (j = 1; j < nr1; j++) {
      alloc_condition[nr1 * j + i] = false;
    }
  }
}

static inline void free_conditions_jmp() {
  unsigned int i, depth;
  for (depth = nr1; depth > 0; depth--) { //JJ: delete
    pop_condition(depth - 1);
  }
  free(condition);
  nr_frees++;
}

// the main recursive algorithm

void find_homos (UIntS   depth,       // the number of filled positions in map
                 UIntS   pos,         // the last position filled
                 UIntS   rep_depth,   // TODO remove this
                 bool    has_trivial_stab,
                 UIntS   rank      ){ // current number of distinct values in map

  UIntS   i, j, k, l, min, next, m, sum, w;
  UIntL*  copy;
  bool    is_trivial;
  
  calls1++;
  if (calls1 > last_report + report_interval) {
    printf("calls to search = %llu\n", calls1);
    printf("stabs computed = %llu\n", calls2);
    printf("nr allocs = %llu\n", nr_allocs);
    printf("nr frees = %llu\n", nr_frees);
    last_report = calls1;
  }

  if (depth == nr1) {
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

  //memcpy((void *) copy, (void *) condition, (size_t) nr1 * len_nr2 * sizeof(UIntL));
  next = 0;      // the next position to fill
  min = nr2 + 1; // the minimum number of candidates for map[next]

  if (pos != UNDEFINED) {
    for (j = 0; j < nr1; j++){
      i = j / SYS_BITS;
      m = j % SYS_BITS;
      if (map[j] == UNDEFINED) {
        if (neighbours1[pos * len_nr1 + i] & oneone[m]) { // vertex j is adjacent to vertex pos in graph1
          copy = push_condition(depth, j, get_condition(j));
          sizes[depth * nr1 + j] = 0;
	  for (k = 0; k < nr2_d; k++){
            copy[k] &= neighbours2[len_nr2 * map[pos] + k];
            sizes[depth * nr1 + j] += sizeUIntL(copy[len_nr2 * j + k], SYS_BITS);
	  }
          copy[nr2_d] &= neighbours2[len_nr2 * map[pos] + nr2_d];
          sizes[depth * nr1 + j] += sizeUIntL(copy[nr2_d], nr2_m + 1);
          if (sizes[depth * nr1 + j] == 0) {
            pop_condition(depth);
            return;
          }
        }
        if (sizes[depth * nr1 + j] < min) {
          next = j;
          min = sizes[depth * nr1 + j];
        }
      }
      sizes[(depth + 1) * nr1 + j] = sizes[(depth * nr1) + j]; 
    }
  } else {
    memcpy(&sizes[(depth + 1) * nr1], &sizes[depth * nr1], (size_t) nr1 * sizeof(UIntS));
  }

  copy = get_condition(next);

  if (rank < hint) {
    for (i = 0; i < nr2; i++) {
      j = i / SYS_BITS;
      m = i % SYS_BITS;
      if ((copy[j] & reps[(len_nr2 * rep_depth) + j] & oneone[m]) 
          && (vals[j] & oneone[m]) == 0) { 
        calls2++;

        if (!has_trivial_stab) {
          // stabiliser of the point i in the stabiliser at the current rep_depth
          is_trivial = point_stabilizer(stab_gens[rep_depth], i, &stab_gens[rep_depth + 1]);
        }
        map[next] = i;
        vals[j] |= oneone[m];
        if (!has_trivial_stab) {
          // blist of orbit reps of things not in vals
          orbit_reps(rep_depth + 1);
          find_homos(depth + 1, next, rep_depth + 1, is_trivial, rank + 1);
        } else {
          find_homos(depth + 1, next, rep_depth, true, rank + 1);
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
      find_homos(depth + 1, next, rep_depth, has_trivial_stab, rank);
      map[next] = UNDEFINED;
    }
  }
  pop_condition(depth);
}

// prepare the graphs for SEARCH_HOMOS
void GraphHomomorphisms (HomosGraph*  graph1, 
                         HomosGraph*  graph2,
                         void         (*hook_arg)(void*        user_param,
	                                          const UIntS  nr,
	                                          const UIntS  *map       ),
                         void*        user_param_arg,
                         UIntL        max_results_arg,
                         int          hint_arg, 
                         bool         isinjective     ) {
  PermColl* gens;
  UIntS     i, j, k, len;

  // debugging memory leaks
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

  init_conditions();

  for (i = 0; i < nr1; i++) {
    map[i] = UNDEFINED;
    sizes[i] = nr2;
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
      find_homos(0, UNDEFINED, 0, false, 0);
    }
  }

  // free the stab_gens
  for (i = 0; i < MAXVERTS; i++) {
    if (stab_gens[i] != NULL) {
      free_perm_coll(stab_gens[i]);
      nr_ss_frees++;
      stab_gens[i] = NULL;
    }
  }

  // debugging memory leaks
  printf("\n");
  printf("nr ss-related allocs = %llu\n", (unsigned long long int) nr_ss_allocs );
  printf("nr ss-related frees = %llu\n", (unsigned long long int) nr_ss_frees );
  printf("nr new perm colls = %llu\n", (unsigned long long int) nr_new_perm_coll );
  printf("nr perm colls freed = %llu\n", (unsigned long long int) nr_free_perm_coll );
  printf("calls to search = %llu\n", calls1);
  printf("stabs computed = %llu\n",  calls2);
}
