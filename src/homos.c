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

static bool tables_init = false;
static UIntL oneone[SYS_BITS];
static UIntL ones[SYS_BITS];
static jmp_buf outofhere;

static void inittabs(void) { 
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

HomosGraph* new_homos_graph (UIntS const nr_verts) {
  HomosGraph* graph = malloc(sizeof(HomosGraph));
  graph->neighbours = calloc(8 * nr_verts, sizeof(UIntL));
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

// automorphism group 

static BlissGraph* as_bliss_graph (HomosGraph* graph) {
  UIntS  i, j, k;
  UIntS  n = graph->nr_verts;
  UIntS  m = (n / SYS_BITS);
  
  BlissGraph* bliss_graph = bliss_new(n);

  for (i = 0; i < n; i++) {   // loop over vertices
    for (j = 0; j < m; j++) { // loop over neighbours of vertex <i>
      for (k = 0; k < SYS_BITS; k++) {
        if (graph->neighbours[8 * i + j] & oneone[k]) {
          bliss_add_edge(bliss_graph, i, SYS_BITS * j + k);
        }
      }
    }
    for (k = 0; k < (n % SYS_BITS); k++) {
      if (graph->neighbours[8 * i + j] & oneone[k]) {
        bliss_add_edge(bliss_graph, i, SYS_BITS * j + k);
      }
    }
  }
  return bliss_graph;
}

void auto_hook (void               *user_param,  // perm_coll!
	        unsigned int       N,
	        const unsigned int *aut        ) {
  
  UIntS i;
  Perm  p = new_perm();
   
  for (i = 0; i < (UIntS) N; i++) {
    p[i] = aut[i];
  }
  for (; i < deg; i++) {
    p[i] = i;
  }
  add_perm_coll((PermColl*) user_param, p);
}

static PermColl* homos_find_automorphisms (HomosGraph* homos_graph) {
  
  BlissGraph* graph = as_bliss_graph(homos_graph);
  PermColl*   gens  = new_perm_coll(homos_graph->nr_verts - 1);
  bliss_find_automorphisms(graph, auto_hook, gens, 0);
  bliss_release(graph);
  return gens;
}

static UIntS  nr1;             // nr of vertices in graph1
static UIntS  nr2;             // nr of vertices in graph2
static UIntS  nr2_d;           // nr2 / SYS_BITS 
static UIntS  nr2_m;           // nr2 % SYS_BITS 
static UIntL  count;                   // the UIntLber of endos found so far
static UIntS  hint;           // an upper bound for the UIntLber of distinct values in map
static UIntL  maxresults;              // upper bound for the UIntLber of returned homos
static UIntS  map[MAXVERTS];                 // partial image list
static UIntS  sizes[MAXVERTS * MAXVERTS];  // sizes[depth * nr1 + i] = |condition[i]| at depth <depth>
static UIntS  orb[MAXVERTS];                 // to hold the orbits in OrbitReps

static UIntL   vals[8];                 // blist for values in map
static UIntL   neighbours1[8 * MAXVERTS];      // the neighbours of the graph1
static UIntL   neighbours2[8 * MAXVERTS];      // the neighbours of the graph2
static UIntL   domain[8];                     // for finding orbit reps               
static UIntL   orb_lookup[8];                 // for finding orbit reps
static UIntL   reps[8 * MAXVERTS];

static void*  user_param;              // a user_param for the hook
void         (*hook)(void*        user_param,
	                                      const UIntS  nr,
	                                      const UIntS  *map       );
                  // hook function applied to every homom. found

static UIntL   calls1;                  // UIntLber of function call statistics 
static UIntL   calls2;                  // calls1 is the UIntLber of calls to the search function
                                     // calls2 is the UIntLber of stabilizers
                                     // calculated
                                    
static UIntL last_report = 0;          // the last value of calls1 when we reported
static UIntL report_interval = 999999; // the interval when we report

static PermColl * stab_gens[MAXVERTS]; // GRAPH_HOMOS stabiliser gens

// algorithm for graphs with between SM and MD vertices . . .

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

static void orbit_reps (UIntS rep_depth) {
  UIntS     nrgens, i, j, fst, m, img, n, max, d;
  Perm      gen;
 
  for (i = 8 * rep_depth; i < 8 * (rep_depth + 1); i++) {
    reps[i] = 0;
  }

  // TODO special case in case there are no gens, or just the identity.

  for (i = 0; i < 8; i++){
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
    reps[(8 * rep_depth) + d] |= oneone[m];
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

void SEARCH_HOMOS_SM (UIntS depth,        // the number of filled positions in map
                      UIntS   pos,        // the last position filled
                      UIntL*  condition,  // blist of possible values for map[i]
                      UIntS rep_depth,    
                      UIntS   rank){      // current number of distinct values in map

  UIntS  i, j, k, l, min, next, m, sum, w;
  UIntL  copy[8 * nr1];
  
  calls1++;
  if (calls1 > last_report + report_interval) {
    printf("calls to search = %d\n", (int) calls1);
    printf("stabs computed = %d\n", (int) calls2);
    //printf("nr allocs = %d\n", (int) nr_allocs);
    //printf("nr frees = %d\n", (int) nr_frees);

    last_report = calls1;
  }

  if (depth == nr1) {
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

  memcpy((void *) copy, (void *) condition, (size_t) nr1 * 8 * sizeof(UIntL));
  next = 0;      // the next position to fill
  min = nr2 + 1; // the minimum number of candidates for map[next]

  if (pos != UNDEFINED) {
    for (j = 0; j < nr1; j++){
      i = j / SYS_BITS;
      m = j % SYS_BITS;
      if (map[j] == UNDEFINED) {
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
      sizes[(depth + 1) * nr1 + j] = sizes[(depth * nr1) + j]; 
    }
  } else {
    memcpy(&sizes[(depth + 1) * nr1], &sizes[depth * nr1], (size_t) nr1 * sizeof(UIntS));
  }

  if (rank < hint) {
    for (i = 0; i < nr2; i++) {
      j = i / SYS_BITS;
      m = i % SYS_BITS;
      if ((copy[8 * next + j] & reps[(8 * rep_depth) + j] & oneone[m]) 
          && (vals[j] & oneone[m]) == 0) { 
        calls2++;

        // stabiliser of the point i in the stabiliser at the current rep_depth
        point_stabilizer(stab_gens[rep_depth], i, &stab_gens[rep_depth + 1]);
        map[next] = i;
        vals[j] |= oneone[m];
        orbit_reps(rep_depth + 1);
        // blist of orbit reps of things not in vals
        SEARCH_HOMOS_SM(depth + 1, next, copy, rep_depth + 1, rank + 1);
        map[next] = UNDEFINED;
        vals[j] ^= oneone[m];
      }
    }
  } 
  for (i = 0; i < nr2; i++) {
    j = i / SYS_BITS;
    m = i % SYS_BITS;
    if (copy[8 * next + j] & vals[j] & oneone[m]) {
      map[next] = i;
      SEARCH_HOMOS_SM(depth + 1, next, copy, rep_depth, rank);
      map[next] = UNDEFINED;
    }
  }
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
  UIntS     i, j, k, d, m, len;

  // debugging memory leaks
  nr_ss_allocs = 0;
  nr_ss_frees = 0;
  nr_new_perm_coll = 0;
  nr_free_perm_coll = 0;

  nr1 = graph1->nr_verts;
  nr2 = graph2->nr_verts;
  nr2_d = nr2 / SYS_BITS;
  nr2_m = nr2 % SYS_BITS;

  assert(nr1 <= MAXVERTS && nr2 <= MAXVERTS);
  
  if (isinjective) {// && nr2 < nr1) { TODO uncomment when we have sm method for injective
    return;
  }

  // initialise everything . . .
  inittabs();
  
  UIntL condition[8 * nr1];
  d = nr1 / SYS_BITS;
  m = nr1 % SYS_BITS;
  for (i = 0; i < nr1; i++) {
    map[i] = UNDEFINED;
    sizes[i] = nr2;
    for (j = 0; j < d; j++){
      condition[8 * i + j] = ones[63];
    }
    condition[8 * i + d] = ones[m];
  }
  
  for (i = 0; i < 8; i++){
    vals[i] = 0;
  }

  memcpy((void *) neighbours1, graph1->neighbours, nr1 * 8 * sizeof(UIntL));
  memcpy((void *) neighbours2, graph2->neighbours, nr2 * 8 * sizeof(UIntL));

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
  
  // go! 
  if (setjmp(outofhere) == 0) {
    if (isinjective) {
      //SEARCH_INJ_HOMOS_MD(0, -1, condition, gens, reps, hook, Stabilizer);
    } else {
      SEARCH_HOMOS_SM(0, UNDEFINED, condition, 0, 0);
    }
  }
  printf("calls to search = %d\n", (int) calls1);
  printf("stabs computed = %d\n", (int) calls2);

  
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
}
