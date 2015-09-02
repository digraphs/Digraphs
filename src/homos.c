/***************************************************************************
**
*A  homos.c                  graph homomorphisms              Julius Jonusas
**                                                            J. D. Mitchell 
**                                                            
**  Copyright (C) 2014-15 - Julius Jonusas and J. D. Mitchell 
**  This file is free software, see license information at the end.
**  
*/

#include "src/homos.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Global variables
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

typedef UIntS Vertex;

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

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

static PermColl* homos_find_automorphisms (HomosGraph* homos_graph) {
  
  BlissGraph* graph = as_bliss_graph(homos_graph);
  PermColl*   gens  = new_perm_coll(homos_graph->nr_verts - 1);
  bliss_find_automorphisms(graph, auto_hook, gens, 0);
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

static inline void pop_condition(UIntS const depth) {
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

static void init_conditions(UIntL* cond) {
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

//bool is_adjacent (HomosGraph* graph,
//                  Vertex      i,
//                  Vertex      j) {
//  graph->neighbours

                  

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
