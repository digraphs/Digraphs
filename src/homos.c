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
  
  unsigned int i;
  perm* p = new_perm(((PermColl*)user_param)->deg);
   
  for(i = 0; i < N; i++){
    p[i] = aut[i];
  }
  add_perm_coll(p);
}

static PermColl* homos_find_automorphisms (HomosGraph* homos_graph) {
  
  BlissGraph* graph = as_bliss_graph(homos_graph);
  PermColl*   gens  = new_perm_coll(graph->nr_verts, graph->nr_verts - 1);
  bliss_find_automorphisms(graph, auto_hook, gens, 0);
  bliss_release(graph);
  return gens;
}

static UIntS nr1;             // nr of vertices in graph1
static UIntS nr2;             // nr of vertices in graph2
static UIntS nr2_d;           // nr2 / SYS_BITS 
static UIntS nr2_m;           // nr2 % SYS_BITS 
static UIntL  count;                   // the UIntLber of endos found so far
static UIntS  hint;           // an upper bound for the UIntLber of distinct values in map
static UIntL  maxresults;              // upper bound for the UIntLber of returned homos
static UIntS  map[MAXVERTS];                 // partial image list
static UIntS sizes[MAXVERTS * MAXVERTS];  // sizes[depth * nr1 + i] = |condition[i]| at depth <depth>
/*static UInt orb[MAXVERTS];                 // to hold the orbits in OrbitReps
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
static perm * new_gens;

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


// condition handling

/*static bool* conditions[MAXVERTS * MAXVERTS];
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

static inline void free_conditions_jmp() {
  unsigned int i, depth;
  for (depth = 0; depth < nr1; depth++) {
    free_conditions(depth);
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
}*/

// the main recursive search algorithm

/*void SEARCH_HOMOS_MD (UIntS const depth,     // the UIntLber of filled positions in map
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
      free_conditions_jmp();
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
          free_conditions(depth); 
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
}*/

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
    hook(user_param, nr1, map);
    count++;
    if (count >= maxresults) {
      longjmp(outofhere, 1);
    }
    return;
  }

  memcpy((void *) copy, (void *) condition, (size_t) nr1 * 8 * sizeof(UIntL));
  next = 0;      // the next position to fill
  min = nr2 + 1; // the minimum UIntLber of candidates for map[next]

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
    }
  }

  for (i = 0; i < nr1; i++) {
    sizes[(depth + 1) * nr1 + i] = sizes[depth * nr1 + i]; 
  }
  
  if (rank < hint) {
    for (i = 0; i < nr2; i++) {
      j = i / SYS_BITS;
      m = i % SYS_BITS;
      if ((copy[8 * next + j] & reps_sm[(8 * rep_depth) + j] & oneone[m]) 
          && (vals_sm[j] & oneone[m]) == 0) { 
        calls2++;

        // stabiliser of the point i in the stabiliser at the current rep_depth
        //stab_gens[rep_depth + 1] = point_stabilizer(stab_gens[rep_depth], i);
        //TODO
        map[next] = i;
        vals_sm[j] |= oneone[m];
        orbit_reps(rep_depth + 1);
        // blist of orbit reps of things not in vals_sm
        SEARCH_HOMOS_SM(depth + 1, next, copy, rep_depth + 1, rank + 1);
        map[next] = UNDEFINED;
        vals_sm[j] ^= oneone[m];
      }
    }
  } 
  for (i = 0; i < nr2; i++) {
    j = i / SYS_BITS;
    m = i % SYS_BITS;
    if (copy[8 * next + j] & vals_sm[j] & oneone[m]) {
      map[next] = i;
      SEARCH_HOMOS_SM(depth + 1, next, copy, rep_depth, rank);
      map[next] = UNDEFINED;
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
                         void         (*hook_arg)(void*        user_param,
	                                          const UIntS  nr,
	                                          const UIntS  *map       ),
                         void*        user_param_arg,
                         UIntL        max_results_arg,
                         int          hint_arg, 
                         bool         isinjective     ) {

  UIntS   i, j, k, d, m, len;
  
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
    for (j = 0; j < d; j++){
      condition[8 * i + j] = ones[63];
    }
    condition[8 * i + d] = ones[m];
  }

  memset((void *) map, UNDEFINED, nr1 * sizeof(UIntS)); //everything is undefined
  
  for (i = 0; i < 8; i++){
    vals_sm[i] = 0;
  }

  memcpy((void *) neighbours1, graph1->neighbours, nr1 * 8 * sizeof(UIntL));
  memcpy((void *) neighbours2, graph2->neighbours, nr2 * 8 * sizeof(UIntL));

  for (i = 0; i < nr1; i++) {
    sizes[i] = nr2;
  }

  // get generators of the automorphism group
  gens = homos_find_automorphisms(graph2);

  // convert generators to our perm type
  len = (UIntS) LEN_PLIST(gens);

  // get pointer to where we want the new generators to go
  if (stab_gens[0] == NULL) {
    new_gens = malloc(len * sizeof(perm));
  } else {
    new_gens = realloc(stab_gens[0]->gens, len * sizeof(perm));
  }

  // populate the new generators
  for (i = 1; i <= len; i++) {
    new_gens[i - 1] = as_perm(ELM_PLIST(gens, i));
  }

  // store the info in our struct
  if (stab_gens[0] == NULL) {
    stab_gens[0] = new_perm_coll(new_gens, len);
  } else {
    stab_gens[0]->gens = new_gens;
    stab_gens[0]->nr_gens = len;
    stab_gens[0]->lmp = largest_moved_point(new_gens, len);
  }

  // get orbit reps
  orbit_reps(0);

  // misc parameters
  count = 0;
  maxresults = max_results_arg;
  user_param = user_param_arg;
  hint = hint_arg;
  hook = hook_arg;
  last_report = 0;

  // get orbit reps 
  //UIntL reps = orbit_reps(gens);
  
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
      SEARCH_HOMOS_SM(0, UNDEFINED, condition, 0, 0);
    }
  }
}
