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

static BitArray*  VALS;
static BitArray*  DOMAIN;
static BitArray*  ORB_LOOKUP;
static BitArray** REPS;
static UIntS      ORB[MAXVERTS];

static UIntS      NR1, NR2;                // the number of vertices in di/graph1/2
static UIntS      MAP[MAXVERTS];           // partial image list
static UIntS      HINT;                    // wanted nr of distinct values in MAP
static UIntL      MAX_RESULTS;             // upper bound for the nr of returned homos

static void*      USER_PARAM;              // a USER_PARAM for the hook

void          (*HOOK)(void*,               // HOOK function applied to every homo found
	              const UIntS,
	              const UIntS*);

// globals for the orbit reps calculation  
static PermColl* STAB_GENS[MAXVERTS];      // stabiliser generators

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
  //assert(false);
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
////////////////////////////////////////////////////////////////////////////////
// homomorphism HOOK functions
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

/*void homo_hook_print () {
  UIntS i;

  printf("endomorphism image list: { ");
  printf("%d", MAP[0] + 1);
  for (i = 1; i < nr1; i++) {
    printf(", %d", MAP[i] + 1);
  }
  printf(" }\n");
}*/

static void orbit_reps (UIntS rep_depth) {
  UIntS     nrgens, i, j, fst, m, img, n, max, d;
  Perm      gen;

  init_bit_array(REPS[rep_depth], false);
  init_bit_array(DOMAIN,          false);
  init_bit_array(ORB_LOOKUP,      false);

  // TODO special case in case there are no gens, or just the identity.
  for (i = 0; i < deg; i++) {
    if (!get_bit_array(VALS, i)) {
      set_bit_array(DOMAIN, i, true);
    }
  }

  fst = 0;
  while (fst < deg && !get_bit_array(DOMAIN, fst)) fst++;

  while (fst < deg) {
    ORB[0] = fst;
    n = 1;   //length of ORB
    
    set_bit_array(REPS[rep_depth], fst, true);
    set_bit_array(ORB_LOOKUP, fst, true);
    set_bit_array(DOMAIN, fst, false);

    for (i = 0; i < n; i++) {
      for (j = 0; j < STAB_GENS[rep_depth]->nr_gens; j++) {
        gen = STAB_GENS[rep_depth]->gens[j];
        img = gen[ORB[i]];
        if (!get_bit_array(ORB_LOOKUP, img)) {
          ORB[n++] = img;
          set_bit_array(ORB_LOOKUP, img, true);
          set_bit_array(DOMAIN, img, false);
        }
      }
    }
    while (fst < deg && !get_bit_array(DOMAIN, fst)) fst++;
  }
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


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// conditions: this is a data structure for keeping track of what possible
// values a vertex can be MAPped to by a partially defined homomorphism, given
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
// column.
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
  
  intersect_bit_arrays(get_conditions(conditions, i), bit_array);

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
// find_digraph_homos: the main recursive function for digraphs
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static void find_digraph_homos (Digraph*    digraph1,
                                Digraph*    digraph2, 
                                Conditions* conditions,
                                UIntS       depth,               // the number of filled positions in MAP
                                UIntS       pos,                 // the last position filled
                                UIntS       rep_depth,
                                bool        has_trivial_stab,
                                UIntS       rank             ) { // current number of distinct values in MAP

  UIntS   i, min, next;
  bool    is_trivial;
  
  if (depth == NR1) { // we've assigned every position in <MAP>
    if (HINT != UNDEFINED && rank != HINT) {
      return;
    }
    HOOK(USER_PARAM, NR1, MAP);
    count++;
    if (count >= MAX_RESULTS) {
      longjmp(outofhere, 1);
    }
    return;
  }

  next = 0;         // the next position to fill
  min  = UNDEFINED; // the minimum number of candidates for MAP[next]

  if (pos != UNDEFINED) { // this is not the first call of the function
    for (i = 0; i < NR1; i++) {
      if (MAP[i] == UNDEFINED) {
        if (is_adjacent_digraph(digraph1, pos, i)) {
          push_conditions(conditions, depth, i, digraph2->out_neighbours[MAP[pos]]);
          if (is_adjacent_digraph(digraph1, i, pos)) {
            intersect_bit_arrays(get_conditions(conditions, i),
                                 digraph2->in_neighbours[MAP[pos]]);
          }
          if (size_conditions(conditions, i) == 0) {
            pop_conditions(conditions, depth);
            return;
          }
        } else if (is_adjacent_digraph(digraph1, i, pos)) {
          push_conditions(conditions, depth, i, digraph2->in_neighbours[MAP[pos]]);
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
  } else {
    for (i = 0; i < NR1; i++) {
      if (size_conditions(conditions, i) < min) {
        next = i;
        min = size_conditions(conditions, i);
      }
    }
  }

  BitArray* possible = get_conditions(conditions, next);

  if (rank < HINT) {
    for (i = 0; i < NR2; i++) {
      if (get_bit_array(possible, i)
          && !get_bit_array(VALS, i)
          && get_bit_array(REPS[rep_depth], i)) {
        if (!has_trivial_stab) {
          // stabiliser of the point i in the stabiliser at current rep_depth
          is_trivial = point_stabilizer(STAB_GENS[rep_depth], i, &STAB_GENS[rep_depth + 1]);
        }
        MAP[next] = i;
        set_bit_array(VALS, i, true);
        if (!has_trivial_stab) {
          if (depth != NR1 - 1) {
            orbit_reps(rep_depth + 1);
          }
          find_digraph_homos(digraph1, digraph2, conditions, depth + 1, next,
                             rep_depth + 1, is_trivial, rank + 1);
        } else {
          find_digraph_homos(digraph1, digraph2, conditions, depth + 1, next,
                             rep_depth, true, rank + 1);
        }
        MAP[next] = UNDEFINED;
        set_bit_array(VALS, i, false);
      }
    }
  }

  for (i = 0; i < NR2; i++) {
    if (get_bit_array(possible, i) && get_bit_array(VALS, i)) {
      MAP[next] = i;
      find_digraph_homos(digraph1, digraph2, conditions, depth + 1, next,
                         rep_depth, has_trivial_stab, rank);
      MAP[next] = UNDEFINED;
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
                           void     (*hook_arg)(void*        USER_PARAM,
	                                        const UIntS  nr,
	                                        const UIntS  *MAP       ),
                           void*     user_param_arg,
                           UIntL     max_results_arg,
                           int       HINT_arg,
                           BitArray* image,
                           UIntS     *partial_MAP                          ) {
  PermColl* gens;
  UIntS     i, j;
  BitArray* mask;
  
  init_bit_tabs();
  
  NR1 = digraph1->nr_vertices;
  NR2 = digraph2->nr_vertices;

  assert(NR1 <= MAXVERTS && NR2 <= MAXVERTS);
  
  //TODO isinjective case
  
  // initialise the conditions . . .
  Conditions* conditions = new_conditions(NR1, NR2);
  
  if (image != NULL) { // image was specified
    for (i = 0; i < NR1; i++) {
      intersect_bit_arrays(get_conditions(conditions, i), image);
      // intersect everything in the first row of conditions with <image>
    }
  }

  if (partial_MAP != NULL) { // a partial MAP was defined
    for (i = 0; i < NR1; i++) {
      if (partial_MAP[i] != UNDEFINED) {
        mask = new_bit_array(NR2); // every position is false by default
        set_bit_array(mask, partial_MAP[i], true);
        intersect_bit_arrays(get_conditions(conditions, i), mask);
      }
    }
  }

  // find loops in digraph2
  BitArray* loops = new_bit_array(NR2);

  for (i = 0; i < NR2; i++) {
    if (is_adjacent_digraph(digraph2, i, i)) {
      set_bit_array(loops, i, true);
    }
  }
  
  // loops in digraph1 can only MAP to loops in digraph2
  for (i = 0; i < NR1; i++) {
    if (is_adjacent_digraph(digraph1, i, i)) {
      intersect_bit_arrays(get_conditions(conditions, i), loops);
    }
  }

  // store the values in <MAP>, this is initialised to every bit set to false,
  // by default.
  VALS       = new_bit_array(NR2);
  DOMAIN     = new_bit_array(NR2);
  ORB_LOOKUP = new_bit_array(NR2);
  REPS       = malloc(NR1 * sizeof(BitArray*));

  // initialise the <MAP> and store the sizes in the conditions. 
  for (i = 0; i < NR1; i++) {
    REPS[i] = new_bit_array(NR2);
    MAP[i] = UNDEFINED;
    store_size_conditions(conditions, i);
  }

  // get generators of the automorphism group of digraph2
  set_perms_degree(NR2);
  STAB_GENS[0] = automorphisms_digraph(digraph2);

  // get orbit reps
  orbit_reps(0);

  // misc parameters
  MAX_RESULTS = max_results_arg;
  USER_PARAM = user_param_arg;
  HINT = HINT_arg;
  HOOK = hook_arg;

  // statistics . . .
  count = 0;
  last_report = 0;

  // go!
  if (setjmp(outofhere) == 0) {
    find_digraph_homos(digraph1, digraph2, conditions, 0, UNDEFINED, 0, false,
                       0);
  }

  // free the STAB_GENS
  for (i = 0; i < MAXVERTS; i++) {
    if (STAB_GENS[i] != NULL) {
      free_perm_coll(STAB_GENS[i]);
      STAB_GENS[i] = NULL;
    }
  }
  free_conditions(conditions);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// graphs (undirected)
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
 
////////////////////////////////////////////////////////////////////////////////
// new_graph: returns a pointer to a Graph with nr_verts vertices and no
// edges.
////////////////////////////////////////////////////////////////////////////////

Graph* new_graph (UIntS const nr_verts) {
  UIntS i;
  Graph* graph      = malloc(sizeof(Graph));
  graph->neighbours = malloc(nr_verts * sizeof(BitArray));
  init_bit_tabs();
  for (i = 0; i < nr_verts; i++) {
    graph->neighbours[i] = new_bit_array(nr_verts);
  }
  graph->nr_vertices = nr_verts;
  return graph;
}

////////////////////////////////////////////////////////////////////////////////
// free_graph: frees the Graph pointed to by <graph>.
////////////////////////////////////////////////////////////////////////////////

void free_graph (Graph* graph) {
  UIntS i, nr = graph->nr_vertices;

  for (i = 0; i < nr; i++) {
    free(graph->neighbours[i]);
  }
  free(graph->neighbours);
  free(graph);
}

////////////////////////////////////////////////////////////////////////////////
// add_edge_graph: add an edge from Vertex <i> to Vertex <j> in the Graph
// pointed to by <graph>.
////////////////////////////////////////////////////////////////////////////////

void add_edge_graph (Graph* graph,
                     Vertex i,
                     Vertex j     ) {
  assert(i < graph->nr_vertices && j < graph->nr_vertices);
  set_bit_array(graph->neighbours[i], j, true);
  set_bit_array(graph->neighbours[j], i, true);
}

////////////////////////////////////////////////////////////////////////////////
// is_adjacent_graph: returns <true> if there is an edge from <i> to <j> in the
// Graph pointed to by <graph> and returns <false> if there is not.
////////////////////////////////////////////////////////////////////////////////

static bool inline is_adjacent_graph (Graph* graph,
                                      Vertex i,
                                      Vertex j     ) {
  assert(i < graph->nr_vertices && j < graph->nr_vertices);
  return get_bit_array(graph->neighbours[i], j);
}

////////////////////////////////////////////////////////////////////////////////
// new_bliss_graph_from_graph: get a new Bliss graph from the Graph pointed to
// by <graph>.
////////////////////////////////////////////////////////////////////////////////

static BlissGraph* new_bliss_graph_from_graph (Graph* graph) {
  UIntS  i, j;
  UIntS  n = graph->nr_vertices;

  BlissGraph* bliss_graph = bliss_new(n);

  for (i = 0; i < n; i++) {       // loop over vertices
    for (j = 0; j < n; j++) {
      if (is_adjacent_graph(graph, i, j)) {
        bliss_add_edge(bliss_graph, i, j);
      }
    }
  }
  return bliss_graph;
}

////////////////////////////////////////////////////////////////////////////////
// bliss_hook_graph: the HOOK for bliss_find_automorphism. 
////////////////////////////////////////////////////////////////////////////////

static void bliss_hook_graph (void               *user_param_arg,  // perm_coll!
                              unsigned int       N,
                              const unsigned int *aut            ) {
  
  assert(N <= deg);

  UIntS        i;
  Perm         p = new_perm();

  for (i = 0; i < N; i++) {
    p[i] = aut[i];
  }
  for (; i < deg; i++) {
    p[i] = i;
  }
  add_perm_coll((PermColl*) user_param_arg, p);
}

////////////////////////////////////////////////////////////////////////////////
// automorphisms_graph: get the automorphism group of the Graph pointed to by
// <graph>.
////////////////////////////////////////////////////////////////////////////////

static PermColl* automorphisms_graph (Graph* graph) {
  BlissGraph* bliss_graph = new_bliss_graph_from_graph(graph);
  PermColl*   gens  = new_perm_coll(graph->nr_vertices - 1);
  bliss_find_automorphisms(bliss_graph, bliss_hook_graph, gens, 0);
  bliss_release(bliss_graph);
  return gens;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// main algorithm recursive function for graphs
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static void find_graph_homos (Graph*      graph1,
                              Graph*      graph2, 
                              Conditions* conditions,
                              UIntS       depth,               // the number of filled positions in MAP
                              UIntS       pos,                 // the last position filled
                              UIntS       rep_depth,
                              bool        has_trivial_stab,
                              UIntS       rank             ) { // current number of distinct values in MAP

  UIntS   i, min, next;
  bool    is_trivial;

  if (depth == NR1) { // we've assigned every position in <MAP>
    if (HINT != UNDEFINED && rank != HINT) {
      return;
    }
    HOOK(USER_PARAM, NR1, MAP);
    count++;
    if (count >= MAX_RESULTS) {
      longjmp(outofhere, 1);
    }
    return;
  }

  next = 0;         // the next position to fill
  min  = UNDEFINED; // the minimum number of candidates for MAP[next]

  if (pos != UNDEFINED) { // this is not the first call of the function
    for (i = 0; i < NR1; i++) {
      if (MAP[i] == UNDEFINED) {
        if (is_adjacent_graph(graph1, pos, i)) {
          push_conditions(conditions, depth, i, graph2->neighbours[MAP[pos]]);
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
  } else {
    for (i = 0; i < NR1; i++) {
      if (size_conditions(conditions, i) < min) {
        next = i;
        min = size_conditions(conditions, i);
      }
    }
  }

  BitArray* possible = get_conditions(conditions, next);

  if (rank < HINT) {
    for (i = 0; i < NR2; i++) {
      if (get_bit_array(possible, i)
          && !get_bit_array(VALS, i)
          && get_bit_array(REPS[rep_depth], i)) {
        if (!has_trivial_stab) {
          // stabiliser of the point i in the stabiliser at current rep_depth
          is_trivial = point_stabilizer(STAB_GENS[rep_depth], i, &STAB_GENS[rep_depth + 1]);
        }
        MAP[next] = i;
        set_bit_array(VALS, i, true);
        if (!has_trivial_stab) {
          if (depth != NR1 - 1) {
            orbit_reps(rep_depth + 1);
          }
          find_graph_homos(graph1, graph2, conditions, depth + 1, next,
                             rep_depth + 1, is_trivial, rank + 1);
        } else {
          find_graph_homos(graph1, graph2, conditions, depth + 1, next,
                             rep_depth, true, rank + 1);
        }
        MAP[next] = UNDEFINED;
        set_bit_array(VALS, i, false);
      }
    }
  }

  for (i = 0; i < NR2; i++) {
    if (get_bit_array(possible, i) && get_bit_array(VALS, i)) {
      MAP[next] = i;
      find_graph_homos(graph1, graph2, conditions, depth + 1, next,
                         rep_depth, has_trivial_stab, rank);
      MAP[next] = UNDEFINED;
    }
  }
  pop_conditions(conditions, depth);
}

////////////////////////////////////////////////////////////////////////////////
// GraphHomomorphisms: the function which calls the main recursive function 
// <find_graph_homos>.
////////////////////////////////////////////////////////////////////////////////

void GraphHomomorphisms (Graph*    graph1,
                         Graph*    graph2,
                         void      (*hook_arg)(void*        USER_PARAM,
	                                       const UIntS  nr,
	                                       const UIntS  *MAP       ),
                         void*     user_param_arg,
                         UIntL     max_results_arg,
                         int       hint_arg,
                         BitArray* image_arg,
                         UIntS     *partial_map_arg                     ) {
  PermColl  *gens;
  UIntS     i, j;
  BitArray* bit_array; 

  NR1 = graph1->nr_vertices;
  NR2 = graph2->nr_vertices;

  assert(NR1 <= MAXVERTS && NR2 <= MAXVERTS);
  
  // initialise the conditions . . .
  Conditions* conditions = new_conditions(NR1, NR2);
 
  // image_arg is a pointer to a BitArray of possible image values for the
  // homomorphisms
  if (image_arg != NULL) { // image_arg was specified
    for (i = 0; i < NR1; i++) {
      intersect_bit_arrays(get_conditions(conditions, i), image_arg);
      // intersect everything in the first row of conditions with <image_arg>
    }
  }
  
  // partial_map_arg is an array of UIntS's partially defining a map from graph1
  // to graph2.
  bit_array = new_bit_array(NR2); // every position is false by default

  if (partial_map_arg != NULL) { // a partial MAP was defined
    for (i = 0; i < NR1; i++) {
      if (partial_map_arg[i] != UNDEFINED) {
        init_bit_array(bit_array, false);
        set_bit_array(bit_array, partial_map_arg[i], true);
        intersect_bit_arrays(get_conditions(conditions, i), bit_array);
      }
    }
  }

  // find loops in graph2
  for (i = 0; i < NR2; i++) {
    if (is_adjacent_graph(graph2, i, i)) {
      set_bit_array(bit_array, i, true);
    }
  }
  
  // loops in graph1 can only map to loops in graph2
  for (i = 0; i < NR1; i++) {
    if (is_adjacent_graph(graph1, i, i)) {
      intersect_bit_arrays(get_conditions(conditions, i), bit_array);
    }
    store_size_conditions(conditions, i);
  }
  
  free(bit_array);

  // store the values in MAP, this is initialised to every bit set to false,
  // by default
  VALS       = new_bit_array(NR2);
  DOMAIN     = new_bit_array(NR2);
  ORB_LOOKUP = new_bit_array(NR2);
  REPS       = malloc(NR1 * sizeof(BitArray*));

  // initialise the <MAP> and store the sizes in the conditions. 
  for (i = 0; i < NR1; i++) {
    REPS[i] = new_bit_array(NR2);
    MAP[i]  = UNDEFINED;
  }

  // get generators of the automorphism group of graph2
  set_perms_degree(NR2);
  STAB_GENS[0] = automorphisms_graph(graph2);

  // get orbit reps
  orbit_reps(0);

  // misc parameters . . .
  MAX_RESULTS = max_results_arg;
  USER_PARAM  = user_param_arg;
  HINT        = hint_arg;
  HOOK        = hook_arg;

  // statistics . . . FIXME not currently used for anything
  count       = 0;
  last_report = 0;

  // go!
  if (setjmp(outofhere) == 0) {
    find_graph_homos(graph1, graph2, conditions, 0, UNDEFINED, 0, false, 0);
  }

  // free everything! 
  for (i = 0; i < MAXVERTS; i++) {
    if (STAB_GENS[i] != NULL) {
      free_perm_coll(STAB_GENS[i]);
      STAB_GENS[i] = NULL;
    }
  }
  free_bit_array(VALS);
  free_bit_array(DOMAIN);
  for (i = 0; i < NR1; i++) {
    free_bit_array(REPS[i]);
  }
  free(REPS);
  free_conditions(conditions);
}
