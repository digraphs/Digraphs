/********************************************************************************
**
*A  homos.c               di/graph homomorphisms              Julius Jonusas
**                                                            J. D. Mitchell
**
**  Copyright (C) 2014-15 - Julius Jonusas and J. D. Mitchell
**
**  This file is free software, see the digraphs/LICENSE.
**
********************************************************************************/

#include "src/homos.h"
#include "src/digraphs-config.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Macros
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// NUMBER_BITS_PER_BLOCK: the number of bits in every Block
////////////////////////////////////////////////////////////////////////////////

#define NUMBER_BITS_PER_BLOCK (sizeof(Block) * CHAR_BIT)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Global variables
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Arguments . . .
////////////////////////////////////////////////////////////////////////////////

static UIntS     NR1, NR2;       // the number of vertices in di/graph1/2
static UIntS     MAX_NR1_NR2;    //
static UIntS     MAP[MAXVERTS];  // partial image list
static BitArray* VALS;           // values in MAP already
static UIntS     HINT;           // wanted nr of distinct values in MAP
static UIntL     MAX_RESULTS;    // upper bound for the nr of returned homos
static void*     USER_PARAM;     // a USER_PARAM for the hook
void (*HOOK)(void*,              // HOOK function applied to every homo found
             const UIntS,
             const UIntS*);
static jmp_buf outofhere;  // so we can jump out of the deepest
                           // level of recursion

// Values in MAP are restricted to those positions in IMAGE_RESTRICT which are
// set to true.
static BitArray* IMAGE_RESTRICT;

////////////////////////////////////////////////////////////////////////////////
// For the orbit reps calculation, and stabiliser chain . . .
////////////////////////////////////////////////////////////////////////////////

static PermColl*  STAB_GENS[MAXVERTS];  // stabiliser generators
static BitArray*  DOMAIN;               // [1 .. NR2]
static BitArray*  ORB_LOOKUP;           // which point is in which orbit
static BitArray** REPS;      // orbit representatives organised by depth in
                             // the search
static UIntS ORB[MAXVERTS];  // array for containing individual orbits

////////////////////////////////////////////////////////////////////////////////
// globals for bitwise operations
////////////////////////////////////////////////////////////////////////////////

static bool  IS_MASK_INITIALIZED = false;  // did we call init_mask already?
static Block MASK[NUMBER_BITS_PER_BLOCK];  // MASK[i] is a Block with a 1 in
                                           // position i and 0s everywhere
                                           // else

////////////////////////////////////////////////////////////////////////////////
// Statistics - not currently used
////////////////////////////////////////////////////////////////////////////////

static UIntL count;  // nr of homos found so far
// static unsigned long long calls1;                   // calls1 is the nr of
// calls to find_graph_homos
// static unsigned long long calls2;                   // calls2 is the nr of
// stabs calculated
static UIntL last_report = 0;  // the last value of calls1 when we reported
// static UIntL              report_interval = 999999; // the interval when we
// report
// static unsigned long long nr_allocs;
// static unsigned long long nr_frees;

////////////////////////////////////////////////////////////////////////////////
// initial the bit tabs
////////////////////////////////////////////////////////////////////////////////

static void init_mask(void) {
  // DIGRAPHS_ASSERT(false);
  if (!IS_MASK_INITIALIZED) {
    UIntS i;
    Block w = 1;
    for (i = 0; i < NUMBER_BITS_PER_BLOCK; i++) {
      MASK[i] = w;
      w <<= 1;
    }
    IS_MASK_INITIALIZED = true;
  }
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// bit arrays
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// COUNT_TRUES_BLOCK: this is from gap/src/blister.h, it counts the number of
// bits in a block which are set to 1.
////////////////////////////////////////////////////////////////////////////////

static inline UInt COUNT_TRUES_BLOCK(UInt block) {
#if USE_POPCNT && defined(HAVE___BUILTIN_POPCOUNTL)
  return __builtin_popcountl(block);
#else
#ifdef SIZEOF_VOID_P == 8
  block = (block & 0x5555555555555555L) + ((block >> 1) & 0x5555555555555555L);
  block = (block & 0x3333333333333333L) + ((block >> 2) & 0x3333333333333333L);
  block = (block + (block >> 4)) & 0x0f0f0f0f0f0f0f0fL;
  block = (block + (block >> 8));
  block = (block + (block >> 16));
  block = (block + (block >> 32)) & 0x00000000000000ffL;
#else
  block = (block & 0x55555555) + ((block >> 1) & 0x55555555);
  block = (block & 0x33333333) + ((block >> 2) & 0x33333333);
  block = (block + (block >> 4)) & 0x0f0f0f0f;
  block = (block + (block >> 8));
  block = (block + (block >> 16)) & 0x000000ff;
#endif
  return block;
#endif
}

////////////////////////////////////////////////////////////////////////////////
// new_bit_array: get a pointer to a new BitArray with space for <nr_bits>
// bits, and with every bit set to false.
////////////////////////////////////////////////////////////////////////////////

BitArray* new_bit_array(UIntS nr_bits) {
  BitArray* bit_array = malloc(sizeof(BitArray));

  bit_array->nr_bits   = nr_bits;
  bit_array->nr_blocks = (nr_bits / NUMBER_BITS_PER_BLOCK) + 1;
  bit_array->blocks    = calloc(bit_array->nr_blocks, NUMBER_BITS_PER_BLOCK);
  return bit_array;
}

////////////////////////////////////////////////////////////////////////////////
// free_bit_array: free the BitArray pointed to by bit_array.
////////////////////////////////////////////////////////////////////////////////

void free_bit_array(BitArray* bit_array) {
  DIGRAPHS_ASSERT(bit_array != NULL);

  free(bit_array->blocks);
  free(bit_array);
}

////////////////////////////////////////////////////////////////////////////////
// init_bit_array: set every value in the BitArray pointed to by <bit_array> to
// the value <val>.
////////////////////////////////////////////////////////////////////////////////

inline void init_bit_array(BitArray* bit_array, bool val) {
  DIGRAPHS_ASSERT(bit_array != NULL);

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
// set_bit_array: set the <pos>th bit of the BitArray pointed to by <bit_array>
// to the value <val>.
////////////////////////////////////////////////////////////////////////////////

void set_bit_array(BitArray* bit_array, UIntS pos, bool val) {
  DIGRAPHS_ASSERT(bit_array != NULL);
  DIGRAPHS_ASSERT(pos < bit_array->nr_bits);

  if (val) {
    bit_array->blocks[pos / NUMBER_BITS_PER_BLOCK] |=
        MASK[pos % NUMBER_BITS_PER_BLOCK];
  } else {
    bit_array->blocks[pos / NUMBER_BITS_PER_BLOCK] &=
        ~MASK[pos % NUMBER_BITS_PER_BLOCK];
  }
}

////////////////////////////////////////////////////////////////////////////////
// get_bit_array: get the value in position <pos> of the BitArray pointer
// <bit_array>.
////////////////////////////////////////////////////////////////////////////////

inline static bool get_bit_array(BitArray* bit_array, UIntS pos) {
  DIGRAPHS_ASSERT(bit_array != NULL);
  DIGRAPHS_ASSERT(pos < bit_array->nr_bits);

  return bit_array->blocks[pos / NUMBER_BITS_PER_BLOCK]
         & MASK[pos % NUMBER_BITS_PER_BLOCK];
}

////////////////////////////////////////////////////////////////////////////////
// intersect_bit_arrays: interesect the BitArrays pointed to by <bit_array1>
// and <bit_array2>. The BitArray pointed to by <bit_array1> is changed in
// place!!
////////////////////////////////////////////////////////////////////////////////

static inline BitArray* intersect_bit_arrays(BitArray* bit_array1,
                                             BitArray* bit_array2) {
  DIGRAPHS_ASSERT(bit_array1 != NULL && bit_array2 != NULL);
  DIGRAPHS_ASSERT(bit_array1->nr_bits == bit_array2->nr_bits);
  DIGRAPHS_ASSERT(bit_array1->nr_blocks == bit_array2->nr_blocks);

  UIntS i;
  for (i = 0; i < bit_array1->nr_blocks; i++) {
    bit_array1->blocks[i] &= bit_array2->blocks[i];
  }
  return bit_array1;
}

////////////////////////////////////////////////////////////////////////////////
// size_bit_array: return the size of a bit array
////////////////////////////////////////////////////////////////////////////////

static inline UIntS size_bit_array(BitArray* bit_array) {
  UIntS  n, i;
  Block  m;
  UIntS  nrb    = bit_array->nr_blocks;
  Block* blocks = bit_array->blocks;

  n = 0;
  for (i = 1; i <= nrb; i++) {
    m = *blocks++;
    n += COUNT_TRUES_BLOCK(m);
  }
  return n;
}

#ifdef DIGRAPHS_KERNEL_DEBUG
static inline void print_bit_array(BitArray* bit_array) {
  printf("<bit array {");
  for (UIntS i = 0; i < bit_array->nr_bits; i++) {
    if (get_bit_array(bit_array, i)) {
      printf(" %d", i);
    }
  }
  printf(" }>");
}

static inline void print_array(UIntS* array, UIntS len) {
  printf("<array {");
  for (UIntS i = 0; i < len; i++) {
    printf(" %d", array[i]);
  }
  printf(" }>");
}
#endif

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
// di/graph, then a Conditions object looks like:
//
//  ^
//  |
//  |
//
//  n                +------------+
//  r                | BitArray*  |
//  1                | length nr2 |
//                   +------------+                    +------------+
//  r                | BitArray*  |                    | BitArray*  |
//  o                | length nr2 |                    | length nr2 |
//  w                +------------+------------+       +------------+
//  s                | BitArray*  | BitArray*  |       | BitArray*  |
//                   | length nr2 | length nr2 |       | length nr2 |
//  |   +------------+------------+------------+ - -  -+------------+
//  |   | BitArray*  | BitArray*  | BitArray*  |       | BitArray*  |
//  |   | length nr2 | length nr2 | length nr2 |       | length nr2 |
//  v   +------------+------------+------------+ - -  -+------------+
//
//      <----------------------- nr1 columns ----------------------->
//
//  The BitArray pointed to in row <i+1> and column <j> row is the intersection
//  of the BitArray pointed to in row <i> and column <j> with some other
//  BitArray (the things adjacent to some vertex in di/graph2).
//
////////////////////////////////////////////////////////////////////////////////

struct conditions_struct {
  BitArray** bit_array;  // nr1 * nr1 array of bit arrays of length nr2
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

static Conditions* new_conditions(UIntS nr1, UIntS nr2) {
  DIGRAPHS_ASSERT(nr1 != 0 && nr2 != 0);

  UIntL       i;
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
    conditions->changed[i + 1]         = i;
    conditions->changed[(nr1 + 1) * i] = 0;
    conditions->height[i]              = 1;
  }
  conditions->changed[0] = nr1;
  return conditions;
}

////////////////////////////////////////////////////////////////////////////////
// free_conditions: free the entire Conditions object pointed to by
// <conditions>.
////////////////////////////////////////////////////////////////////////////////

static void free_conditions(Conditions* conditions) {
  DIGRAPHS_ASSERT(conditions != NULL);

  UIntL i;
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

static inline BitArray* get_conditions(Conditions* conditions, Vertex const i) {
  DIGRAPHS_ASSERT(conditions != NULL);
  DIGRAPHS_ASSERT(i < conditions->nr1);

  return conditions
      ->bit_array[conditions->nr1 * (conditions->height[i] - 1) + i];
}

////////////////////////////////////////////////////////////////////////////////
// store_size_conditions: store the size of the BitArray pointed to at the top
// of column <i>.
////////////////////////////////////////////////////////////////////////////////

static inline void store_size_conditions(Conditions*  conditions,
                                         Vertex const i) {
  DIGRAPHS_ASSERT(conditions != NULL);
  DIGRAPHS_ASSERT(i < conditions->nr1);

  UIntS nr1 = conditions->nr1;
  conditions->sizes[nr1 * (conditions->height[i] - 1) + i] =
      size_bit_array(get_conditions(conditions, i));
}

////////////////////////////////////////////////////////////////////////////////
// push_conditions: copy the top of the <i>th column of the <conditions> and
// intersect it with <bit_array> and then push this onto the top of the <i>th
// column.
////////////////////////////////////////////////////////////////////////////////

static inline void push_conditions(Conditions*  conditions,
                                   UIntS const  depth,
                                   Vertex const i,
                                   BitArray*    bit_array) {
  DIGRAPHS_ASSERT(conditions != NULL);
  DIGRAPHS_ASSERT(i < conditions->nr1);
  DIGRAPHS_ASSERT(depth < conditions->nr1);

  UIntS nr1 = conditions->nr1;

  memcpy((void*) conditions->bit_array[nr1 * conditions->height[i] + i]->blocks,
         (void*) conditions->bit_array[nr1 * (conditions->height[i] - 1) + i]
             ->blocks,
         (size_t) conditions->bit_array[0]->nr_blocks * sizeof(Block));

  conditions->changed[(nr1 + 1) * depth]++;
  conditions
      ->changed[(nr1 + 1) * depth + conditions->changed[(nr1 + 1) * depth]] = i;

  conditions->height[i]++;

  if (bit_array != NULL) {
    intersect_bit_arrays(get_conditions(conditions, i), bit_array);
  }

  store_size_conditions(conditions, i);
}

////////////////////////////////////////////////////////////////////////////////
// pop_conditions: pop the tops off all of the columns which were last push on.
////////////////////////////////////////////////////////////////////////////////

static inline void pop_conditions(Conditions* conditions, UIntS const depth) {
  DIGRAPHS_ASSERT(conditions != NULL);
  DIGRAPHS_ASSERT(depth < conditions->nr1);

  UIntS i;
  UIntS nr1 = conditions->nr1;

  for (i = 1; i < conditions->changed[(nr1 + 1) * depth] + 1; i++) {
    conditions->height[conditions->changed[(nr1 + 1) * depth + i]]--;
  }
  conditions->changed[(nr1 + 1) * depth] = 0;
}

////////////////////////////////////////////////////////////////////////////////
// size_conditions: return the size of the BitArray pointed to by the top of
// the <i>th column.
////////////////////////////////////////////////////////////////////////////////

static inline UIntS size_conditions(Conditions* conditions, Vertex const i) {
  DIGRAPHS_ASSERT(conditions != NULL);
  DIGRAPHS_ASSERT(i < conditions->nr1);

  return conditions->sizes[conditions->nr1 * (conditions->height[i] - 1) + i];
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// orbits_reps: find orbit_reps at <rep_depth>
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static void orbit_reps(UIntS rep_depth) {
  UIntS i, j, fst, img, n;
  Perm  gen;

  init_bit_array(REPS[rep_depth], false);
  init_bit_array(DOMAIN, false);
  init_bit_array(ORB_LOOKUP, false);

  // TODO(*) special case in case there are no gens, or just the identity.
  for (i = 0; i < deg; i++) {
    if (!get_bit_array(VALS, i)) {
      set_bit_array(DOMAIN, i, true);
    }
  }

  fst = 0;
  if (IMAGE_RESTRICT != NULL) {
    while (fst < deg
           && (!get_bit_array(DOMAIN, fst)
               || !get_bit_array(IMAGE_RESTRICT, fst))) {
      fst++;
    }
  } else {
    while (fst < deg && !get_bit_array(DOMAIN, fst)) {
      fst++;
    }
  }

  while (fst < deg) {
    ORB[0] = fst;
    n      = 1;  // length of ORB

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
    if (IMAGE_RESTRICT != NULL) {
      while (fst < deg
             && (!get_bit_array(DOMAIN, fst)
                 || !get_bit_array(IMAGE_RESTRICT, fst))) {
        fst++;
      }
    } else {
      while (fst < deg && !get_bit_array(DOMAIN, fst)) {
        fst++;
      }
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// digraphs
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// new_digraph: returns a pointer to a Digraph with <nr_verts> vertices and no
// edges.
////////////////////////////////////////////////////////////////////////////////

Digraph* new_digraph(UIntS const nr_verts) {
  UIntS    i;
  Digraph* digraph        = malloc(sizeof(Digraph));
  digraph->in_neighbours  = malloc(nr_verts * sizeof(BitArray));
  digraph->out_neighbours = malloc(nr_verts * sizeof(BitArray));
  init_mask();
  for (i = 0; i < nr_verts; i++) {
    digraph->in_neighbours[i]  = new_bit_array(nr_verts);
    digraph->out_neighbours[i] = new_bit_array(nr_verts);
  }
  digraph->nr_vertices = nr_verts;
  return digraph;
}

////////////////////////////////////////////////////////////////////////////////
// free_digraph: free the Digraph pointed to by <digraph>.
////////////////////////////////////////////////////////////////////////////////

void free_digraph(Digraph* digraph) {
  DIGRAPHS_ASSERT(digraph != NULL);

  UIntS i, nr = digraph->nr_vertices;

  for (i = 0; i < nr; i++) {
    free_bit_array(digraph->in_neighbours[i]);
    free_bit_array(digraph->out_neighbours[i]);
  }
  free(digraph->in_neighbours);
  free(digraph->out_neighbours);
  free(digraph);
}

////////////////////////////////////////////////////////////////////////////////
// add_edge_digraph: add an edge from Vertex <i> to Vertex <j> in the Digraph
// pointed to by <digraph>.
////////////////////////////////////////////////////////////////////////////////

void add_edge_digraph(Digraph* digraph, Vertex i, Vertex j) {
  DIGRAPHS_ASSERT(digraph != NULL);
  DIGRAPHS_ASSERT(i < digraph->nr_vertices && j < digraph->nr_vertices);

  set_bit_array(digraph->out_neighbours[i], j, true);
  set_bit_array(digraph->in_neighbours[j], i, true);
}

////////////////////////////////////////////////////////////////////////////////
// is_adjacent_digraph: returns <true> if there is an edge from <i> to <j> in
// the Digraph pointed to by <digraph> and returns <false> if there is not.
////////////////////////////////////////////////////////////////////////////////

inline static bool is_adjacent_digraph(Digraph* digraph, Vertex i, Vertex j) {
  DIGRAPHS_ASSERT(digraph != NULL);
  DIGRAPHS_ASSERT(i < digraph->nr_vertices && j < digraph->nr_vertices);

  return get_bit_array(digraph->out_neighbours[i], j);
}

////////////////////////////////////////////////////////////////////////////////
// new_bliss_digraphs_graph: get a new bliss (undirected, vertex coloured)
// digraph from
// the Digraph pointed to by <digraph>.
////////////////////////////////////////////////////////////////////////////////

static BlissGraph* new_bliss_digraphs_graph_from_digraph(Digraph* digraph,
                                                         UIntS*   colors) {
  DIGRAPHS_ASSERT(digraph != NULL);

  UIntS       i, j, k, l;
  BlissGraph* bliss_digraphs_graph;
  UIntS       n = digraph->nr_vertices;

  if (colors == NULL) {
    bliss_digraphs_graph = bliss_digraphs_new(n);
  } else {
    bliss_digraphs_graph = bliss_digraphs_new(0);
    for (i = 0; i < n; i++) {
      bliss_digraphs_add_vertex(bliss_digraphs_graph, colors[i]);
    }
  }

  for (i = 0; i < n; i++) {  // loop over vertices
    for (j = 0; j < n; j++) {
      if (is_adjacent_digraph(digraph, i, j)) {
        k = bliss_digraphs_add_vertex(bliss_digraphs_graph, n + 1);
        l = bliss_digraphs_add_vertex(bliss_digraphs_graph, n + 2);
        bliss_digraphs_add_edge(bliss_digraphs_graph, i, k);
        bliss_digraphs_add_edge(bliss_digraphs_graph, k, l);
        bliss_digraphs_add_edge(bliss_digraphs_graph, l, j);
      }
    }
  }
  return bliss_digraphs_graph;
}

////////////////////////////////////////////////////////////////////////////////
// bliss_digraphs_hook_digraph: the hook function for
// bliss_digraphs_find_automorphisms to
// collect the generators of the automorphism group in a PermColl
////////////////////////////////////////////////////////////////////////////////

static void bliss_digraphs_hook_digraph(void* user_param_arg,  // perm_coll!
                                        unsigned int        N,
                                        const unsigned int* aut) {
  UIntS i;
  Perm  p = new_perm();

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
// automorphisms_digraph: get a PermColl* to the generators of the Digraph
// pointed to by <digraph>.
////////////////////////////////////////////////////////////////////////////////

static PermColl* automorphisms_digraph(Digraph* digraph, UIntS* colors) {
  DIGRAPHS_ASSERT(digraph != NULL);

  BlissGraph* bliss_digraphs_graph =
      new_bliss_digraphs_graph_from_digraph(digraph, colors);
  PermColl* gens = new_perm_coll(digraph->nr_vertices - 1);
  bliss_digraphs_find_automorphisms(
      bliss_digraphs_graph, bliss_digraphs_hook_digraph, gens, 0);
  bliss_digraphs_release(bliss_digraphs_graph);
  return gens;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// find_digraph_homos: the main recursive function for digraphs
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// TODO(*) describe the args

static void
find_digraph_homos(Digraph*    digraph1,
                   Digraph*    digraph2,
                   Conditions* conditions,
                   UIntS       depth,  // the number of filled positions in MAP
                   UIntS       pos,    // the last position filled
                   UIntS       rep_depth,
                   bool        has_trivial_stab,
                   // current number of distinct values in MAP
                   UIntS rank) {
  UIntS i, min, next;
  bool  is_trivial;

  if (depth == NR1) {  // we've assigned every position in <MAP>
    if (HINT != UNDEFINED && rank != HINT) {
      return;
    }
    HOOK(USER_PARAM, MAX_NR1_NR2, MAP);
    count++;
    if (count >= MAX_RESULTS) {
      longjmp(outofhere, 1);
    }
    return;
  }

  next = 0;          // the next position to fill
  min  = UNDEFINED;  // the minimum number of candidates for MAP[next]

  if (pos != UNDEFINED) {  // this is not the first call of the function
    for (i = 0; i < NR1; i++) {
      if (MAP[i] == UNDEFINED) {
        if (is_adjacent_digraph(digraph1, pos, i)) {
          push_conditions(
              conditions, depth, i, digraph2->out_neighbours[MAP[pos]]);
          if (is_adjacent_digraph(digraph1, i, pos)) {
            intersect_bit_arrays(get_conditions(conditions, i),
                                 digraph2->in_neighbours[MAP[pos]]);
          }
          if (size_conditions(conditions, i) == 0) {
            pop_conditions(conditions, depth);
            return;
          }
        } else if (is_adjacent_digraph(digraph1, i, pos)) {
          push_conditions(
              conditions, depth, i, digraph2->in_neighbours[MAP[pos]]);
          if (size_conditions(conditions, i) == 0) {
            pop_conditions(conditions, depth);
            return;
          }
        }
        if (size_conditions(conditions, i) < min) {
          next = i;
          min  = size_conditions(conditions, i);
        }
      }
    }
  } else {
    for (i = 0; i < NR1; i++) {
      if (size_conditions(conditions, i) < min) {
        next = i;
        min  = size_conditions(conditions, i);
      }
    }
  }

  BitArray* possible = get_conditions(conditions, next);

  if (rank < HINT) {
    for (i = 0; i < NR2; i++) {
      if (get_bit_array(possible, i) && !get_bit_array(VALS, i)
          && get_bit_array(REPS[rep_depth], i)) {
        if (!has_trivial_stab) {
          // stabiliser of the point i in the stabiliser at current rep_depth
          is_trivial = point_stabilizer(
              STAB_GENS[rep_depth], i, &STAB_GENS[rep_depth + 1]);
        }
        MAP[next] = i;
        set_bit_array(VALS, i, true);
        if (!has_trivial_stab) {
          if (depth != NR1 - 1) {
            orbit_reps(rep_depth + 1);
          }
          find_digraph_homos(digraph1,
                             digraph2,
                             conditions,
                             depth + 1,
                             next,
                             rep_depth + 1,
                             is_trivial,
                             rank + 1);
        } else {
          find_digraph_homos(digraph1,
                             digraph2,
                             conditions,
                             depth + 1,
                             next,
                             rep_depth,
                             true,
                             rank + 1);
        }
        MAP[next] = UNDEFINED;
        set_bit_array(VALS, i, false);
      }
    }
  }

  for (i = 0; i < NR2; i++) {
    if (get_bit_array(possible, i) && get_bit_array(VALS, i)) {
      MAP[next] = i;
      find_digraph_homos(digraph1,
                         digraph2,
                         conditions,
                         depth + 1,
                         next,
                         rep_depth,
                         has_trivial_stab,
                         rank);
      MAP[next] = UNDEFINED;
    }
  }
  pop_conditions(conditions, depth);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// DigraphHomomorphisms: the function which calls the main recursive function
// <find_digraph_homos>.
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

void DigraphHomomorphisms(Digraph* digraph1,
                          Digraph* digraph2,
                          void (*hook_arg)(void*        user_param,
                                           const UIntS  nr,
                                           const UIntS* map),
                          void*     user_param_arg,
                          UIntL     max_results_arg,
                          int       hint_arg,
                          BitArray* image_arg,
                          UIntS*    partial_map_arg,
                          UIntS*    colors1,
                          UIntS*    colors2) {
  DIGRAPHS_ASSERT(digraph1 != NULL && digraph2 != NULL);

  UIntS     i, j;
  BitArray* bit_array;

  NR1         = digraph1->nr_vertices;
  NR2         = digraph2->nr_vertices;
  MAX_NR1_NR2 = (NR1 < NR2 ? NR2 : NR1);

  DIGRAPHS_ASSERT(NR1 <= MAXVERTS && NR2 <= MAXVERTS);

  // initialise the conditions . . .
  Conditions* conditions = new_conditions(NR1, NR2);

  // image_arg is a pointer to a BitArray of possible image values for the
  // homomorphisms . . .
  if (image_arg != NULL) {  // image was specified
    for (i = 0; i < NR1; i++) {
      intersect_bit_arrays(get_conditions(conditions, i), image_arg);
      // intersect everything in the first row of conditions with <image>
    }
  }
  // Used by orbit_reps, so that orbit reps are chosen from among the
  // restricted values of the image.
  IMAGE_RESTRICT = image_arg;

  // partial_map_arg is an array of UIntS's partially defining a map from
  // digraph1 to digraph2.
  bit_array = new_bit_array(NR2);  // every position is false by default

  if (partial_map_arg != NULL) {  // a partial MAP was defined
    for (i = 0; i < NR1; i++) {
      if (partial_map_arg[i] != UNDEFINED) {
        init_bit_array(bit_array, false);
        set_bit_array(bit_array, partial_map_arg[i], true);
        intersect_bit_arrays(get_conditions(conditions, i), bit_array);
      }
    }
  }

  init_bit_array(bit_array, false);

  // find loops in digraph2
  for (i = 0; i < NR2; i++) {
    if (is_adjacent_digraph(digraph2, i, i)) {
      set_bit_array(bit_array, i, true);
    }
  }

  // bit_array in digraph1 can only MAP to bit_array in digraph2
  for (i = 0; i < NR1; i++) {
    if (is_adjacent_digraph(digraph1, i, i)) {
      intersect_bit_arrays(get_conditions(conditions, i), bit_array);
    }
    store_size_conditions(conditions, i);
  }

  if (colors1 != NULL) {  // colors1 and colors2 specified
    for (i = 0; i < NR1; i++) {
      init_bit_array(bit_array, false);
      for (j = 0; j < NR2; j++) {
        if (colors1[i] == colors2[j]) {
          set_bit_array(bit_array, j, true);
        }
      }
      intersect_bit_arrays(get_conditions(conditions, i), bit_array);
      // can only map vertices of color i to vertices of color i
    }
  }

  free_bit_array(bit_array);

  // store the values in <MAP>, this is initialised to every bit set to false,
  // by default.
  VALS       = new_bit_array(NR2);
  DOMAIN     = new_bit_array(NR2);
  ORB_LOOKUP = new_bit_array(NR2);
  REPS       = malloc(NR1 * sizeof(BitArray*));

  // initialise the <MAP> and store the sizes in the conditions.
  for (i = 0; i < NR1; i++) {
    REPS[i] = new_bit_array(NR2);
    MAP[i]  = UNDEFINED;
  }
  for (i = NR1; i < MAX_NR1_NR2; i++) {
    MAP[i] = i;
  }

  // get generators of the automorphism group of digraph2, and the orbit reps
  set_perms_degree(NR2);
  STAB_GENS[0] = automorphisms_digraph(digraph2, colors2);
  orbit_reps(0);

  // misc parameters
  MAX_RESULTS = max_results_arg;
  USER_PARAM  = user_param_arg;
  HINT        = hint_arg;
  HOOK        = hook_arg;

  // statistics . . . FIXME not currently used for anything
  count       = 0;
  last_report = 0;

  // go!
  if (setjmp(outofhere) == 0) {
    find_digraph_homos(
        digraph1, digraph2, conditions, 0, UNDEFINED, 0, false, 0);
  }

  // free the STAB_GENS
  for (i = 0; i < MAXVERTS; i++) {
    if (STAB_GENS[i] != NULL) {
      free_perm_coll(STAB_GENS[i]);
      STAB_GENS[i] = NULL;
    }
  }
  free_bit_array(VALS);
  free_bit_array(DOMAIN);
  free_bit_array(ORB_LOOKUP);
  for (i = 0; i < NR1; i++) {
    free_bit_array(REPS[i]);
  }
  free(REPS);
  free_conditions(conditions);
}

////////////////////////////////////////////////////////////////////////////////
// a version of new main algorithm for injective homomorphisms
////////////////////////////////////////////////////////////////////////////////

static void
find_digraph_monos(Digraph*    digraph1,
                   Digraph*    digraph2,
                   Conditions* conditions,
                   UIntS       depth,  // the number of filled positions in map
                   UIntS       pos,    // the last position filled
                   UIntS       rep_depth,
                   bool        has_trivial_stab) {
  UIntS i, min, next;
  bool  is_trivial;

  if (depth == NR1) {  // we've assigned every position in <MAP>
    HOOK(USER_PARAM, MAX_NR1_NR2, MAP);
    count++;
    if (count >= MAX_RESULTS) {
      longjmp(outofhere, 1);
    }
    return;
  }

  next = 0;          // the next position to fill
  min  = UNDEFINED;  // the minimum number of candidates for MAP[next]

  if (pos != UNDEFINED) {  // this is not the first call of the function
    for (i = 0; i < NR1; i++) {
      if (MAP[i] == UNDEFINED) {
        push_conditions(conditions, depth, i, NULL);
        set_bit_array(get_conditions(conditions, i), MAP[pos], false);
        // this could be optimised since MAP[pos] is fixed within the loop
        if (is_adjacent_digraph(digraph1, pos, i)) {
          intersect_bit_arrays(get_conditions(conditions, i),
                               digraph2->out_neighbours[MAP[pos]]);
        }
        if (is_adjacent_digraph(digraph1, i, pos)) {
          intersect_bit_arrays(get_conditions(conditions, i),
                               digraph2->in_neighbours[MAP[pos]]);
        }
        if (size_conditions(conditions, i) == 0) {
          pop_conditions(conditions, depth);
          return;
        }
        if (size_conditions(conditions, i) < min) {
          next = i;
          min  = size_conditions(conditions, i);
        }
      }
    }
  } else {
    for (i = 0; i < NR1; i++) {
      if (size_conditions(conditions, i) < min) {
        next = i;
        min  = size_conditions(conditions, i);
      }
    }
  }

  BitArray* possible = get_conditions(conditions, next);

  for (i = 0; i < NR2; i++) {
    if (get_bit_array(possible, i) && get_bit_array(REPS[rep_depth], i)) {
      if (!has_trivial_stab) {
        // stabiliser of the point i in the stabiliser at current rep_depth
        is_trivial = point_stabilizer(
            STAB_GENS[rep_depth], i, &STAB_GENS[rep_depth + 1]);
      }
      MAP[next] = i;
      set_bit_array(VALS, i, true);
      if (!has_trivial_stab) {
        if (depth != NR1 - 1) {
          orbit_reps(rep_depth + 1);
        }
        find_digraph_monos(digraph1,
                           digraph2,
                           conditions,
                           depth + 1,
                           next,
                           rep_depth + 1,
                           is_trivial);
      } else {
        find_digraph_monos(
            digraph1, digraph2, conditions, depth + 1, next, rep_depth, true);
      }
      MAP[next] = UNDEFINED;
      set_bit_array(VALS, i, false);
    }
  }

  pop_conditions(conditions, depth);
}

////////////////////////////////////////////////////////////////////////////////
// DigraphMonomorphisms: the function which calls the main recursive function
// <find_digraph_monos>.
////////////////////////////////////////////////////////////////////////////////

void DigraphMonomorphisms(Digraph* digraph1,
                          Digraph* digraph2,
                          void (*hook_arg)(void*        user_param,
                                           const UIntS  nr,
                                           const UIntS* map),
                          void*     user_param_arg,
                          UIntL     max_results_arg,
                          BitArray* image_arg,
                          UIntS*    partial_map_arg,
                          UIntS*    colors1,
                          UIntS*    colors2) {
  DIGRAPHS_ASSERT(digraph1 != NULL && digraph2 != NULL);

  UIntS     i, j;
  BitArray* bit_array;

  NR1         = digraph1->nr_vertices;
  NR2         = digraph2->nr_vertices;
  MAX_NR1_NR2 = (NR1 < NR2 ? NR2 : NR1);

  DIGRAPHS_ASSERT(NR1 <= MAXVERTS && NR2 <= MAXVERTS);

  // initialise the conditions . . .
  Conditions* conditions = new_conditions(NR1, NR2);

  // image_arg is a pointer to a BitArray of possible image values for the
  // homomorphisms . . .
  if (image_arg != NULL) {  // image was specified
    if (size_bit_array(image_arg) < NR1) {
      // there isn't enough points in the image_arg
      return;
    }
    for (i = 0; i < NR1; i++) {
      intersect_bit_arrays(get_conditions(conditions, i), image_arg);
      // intersect everything in the first row of conditions with <image>
    }
  }

  // Used by orbit_reps, so that orbit reps are chosen from among the
  // restricted values of the image.
  IMAGE_RESTRICT = image_arg;

  // partial_map_arg is an array of UIntS's partially defining a map from
  // digraph1 to digraph2.
  bit_array = new_bit_array(NR2);  // every position is false by default

  if (partial_map_arg != NULL) {  // a partial map was defined
    BitArray* partial_map_arg_image =
        new_bit_array(NR2);  // values in the image of partial_map
    for (i = 0; i < NR1; i++) {
      if (partial_map_arg[i] != UNDEFINED) {
        if (get_bit_array(partial_map_arg_image, partial_map_arg[i])) {
          return;  // partial_map is not injective
        } else {
          set_bit_array(partial_map_arg_image, partial_map_arg[i], true);
        }
        init_bit_array(bit_array, false);
        set_bit_array(bit_array, partial_map_arg[i], true);
        intersect_bit_arrays(get_conditions(conditions, i), bit_array);
      }
    }
    free_bit_array(partial_map_arg_image);
  }

  init_bit_array(bit_array, false);

  // find loops in digraph2
  for (i = 0; i < NR2; i++) {
    if (is_adjacent_digraph(digraph2, i, i)) {
      set_bit_array(bit_array, i, true);
    }
  }

  // loops in digraph1 can only MAP to bit_array in digraph2
  for (i = 0; i < NR1; i++) {
    if (is_adjacent_digraph(digraph1, i, i)) {
      intersect_bit_arrays(get_conditions(conditions, i), bit_array);
    }
    store_size_conditions(conditions, i);
  }

  if (colors1 != NULL) {  // colors1 and colors2 specified
    for (i = 0; i < NR1; i++) {
      init_bit_array(bit_array, false);
      for (j = 0; j < NR2; j++) {
        if (colors1[i] == colors2[j]) {
          set_bit_array(bit_array, j, true);
        }
      }
      intersect_bit_arrays(get_conditions(conditions, i), bit_array);
      // can only map vertices of color i to vertices of color i
    }
  }

  free_bit_array(bit_array);

  // store the values in <map>, this is initialised to every bit set to false,
  // by default.
  VALS       = new_bit_array(NR2);
  DOMAIN     = new_bit_array(NR2);
  ORB_LOOKUP = new_bit_array(NR2);
  REPS       = malloc(NR1 * sizeof(BitArray*));

  // initialise the <map> and store the sizes in the conditions.
  for (i = 0; i < NR1; i++) {
    REPS[i] = new_bit_array(NR2);
    MAP[i]  = UNDEFINED;
  }
  for (i = NR1; i < MAX_NR1_NR2; i++) {
    MAP[i] = i;
  }

  // get generators of the automorphism group of digraph2, and the orbit reps
  set_perms_degree(NR2);
  STAB_GENS[0] = automorphisms_digraph(digraph2, colors2);
  orbit_reps(0);

  // misc parameters
  MAX_RESULTS = max_results_arg;
  USER_PARAM  = user_param_arg;
  HOOK        = hook_arg;

  // statistics . . . FIXME not currently used for anything
  count       = 0;
  last_report = 0;

  // go!
  if (setjmp(outofhere) == 0) {
    find_digraph_monos(digraph1, digraph2, conditions, 0, UNDEFINED, 0, false);
  }

  // free the stab_gens
  for (i = 0; i < MAXVERTS; i++) {
    if (STAB_GENS[i] != NULL) {
      free_perm_coll(STAB_GENS[i]);
      STAB_GENS[i] = NULL;
    }
  }
  free_bit_array(VALS);
  free_bit_array(DOMAIN);
  free_bit_array(ORB_LOOKUP);
  for (i = 0; i < NR1; i++) {
    free_bit_array(REPS[i]);
  }
  free(REPS);
  free_conditions(conditions);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Graphs (undirected)
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// new_graph: returns a pointer to a Graph with nr_verts vertices and no
// edges.
////////////////////////////////////////////////////////////////////////////////

Graph* new_graph(UIntS const nr_verts) {
  UIntS  i;
  Graph* graph      = malloc(sizeof(Graph));
  graph->neighbours = malloc(nr_verts * sizeof(BitArray));
  init_mask();
  for (i = 0; i < nr_verts; i++) {
    graph->neighbours[i] = new_bit_array(nr_verts);
  }
  graph->nr_vertices = nr_verts;
  return graph;
}

////////////////////////////////////////////////////////////////////////////////
// free_graph: frees the Graph pointed to by <graph>.
////////////////////////////////////////////////////////////////////////////////

void free_graph(Graph* graph) {
  DIGRAPHS_ASSERT(graph != NULL);

  UIntS i, nr = graph->nr_vertices;

  for (i = 0; i < nr; i++) {
    free_bit_array(graph->neighbours[i]);
  }
  free(graph->neighbours);
  free(graph);
}

////////////////////////////////////////////////////////////////////////////////
// add_edge_graph: add an edge from Vertex <i> to Vertex <j> in the Graph
// pointed to by <graph>.
////////////////////////////////////////////////////////////////////////////////

void add_edge_graph(Graph* graph, Vertex i, Vertex j) {
  DIGRAPHS_ASSERT(graph != NULL);
  DIGRAPHS_ASSERT(i < graph->nr_vertices && j < graph->nr_vertices);

  set_bit_array(graph->neighbours[i], j, true);
  set_bit_array(graph->neighbours[j], i, true);
}

////////////////////////////////////////////////////////////////////////////////
// is_adjacent_graph: returns <true> if there is an edge from <i> to <j> in the
// Graph pointed to by <graph> and returns <false> if there is not.
////////////////////////////////////////////////////////////////////////////////

inline static bool is_adjacent_graph(Graph* graph, Vertex i, Vertex j) {
  DIGRAPHS_ASSERT(graph != NULL);
  DIGRAPHS_ASSERT(i < graph->nr_vertices && j < graph->nr_vertices);

  return get_bit_array(graph->neighbours[i], j);
}

////////////////////////////////////////////////////////////////////////////////
// new_bliss_digraphs_graph_from_graph: get a new Bliss graph from the Graph
// pointed to
// by <graph>.
////////////////////////////////////////////////////////////////////////////////

static BlissGraph* new_bliss_digraphs_graph_from_graph(Graph* graph,
                                                       UIntS* colors) {
  DIGRAPHS_ASSERT(graph != NULL);

  UIntS       i, j;
  BlissGraph* bliss_digraphs_graph;
  UIntS       n = graph->nr_vertices;

  if (colors == NULL) {
    bliss_digraphs_graph = bliss_digraphs_new(n);
  } else {
    bliss_digraphs_graph = bliss_digraphs_new(0);
    for (i = 0; i < n; i++) {
      bliss_digraphs_add_vertex(bliss_digraphs_graph, colors[i]);
    }
  }

  for (i = 0; i < n; i++) {  // loop over vertices
    for (j = 0; j < n; j++) {
      if (is_adjacent_graph(graph, i, j)) {
        bliss_digraphs_add_edge(bliss_digraphs_graph, i, j);
      }
    }
  }
  return bliss_digraphs_graph;
}

////////////////////////////////////////////////////////////////////////////////
// bliss_digraphs_hook_graph: the HOOK for bliss_digraphs_find_automorphism.
////////////////////////////////////////////////////////////////////////////////

static void bliss_digraphs_hook_graph(void* user_param_arg,  // perm_coll!
                                      unsigned int        N,
                                      const unsigned int* aut) {
  DIGRAPHS_ASSERT(N <= deg);

  UIntS i;
  Perm  p = new_perm();

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

static PermColl* automorphisms_graph(Graph* graph, UIntS* colors) {
  DIGRAPHS_ASSERT(graph != NULL);

  BlissGraph* bliss_digraphs_graph =
      new_bliss_digraphs_graph_from_graph(graph, colors);
  PermColl* gens = new_perm_coll(graph->nr_vertices - 1);
  bliss_digraphs_find_automorphisms(
      bliss_digraphs_graph, bliss_digraphs_hook_graph, gens, 0);
  bliss_digraphs_release(bliss_digraphs_graph);
  return gens;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// main algorithm recursive function for graphs
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// TODO(*) describe the args

static void
find_graph_homos(Graph*      graph1,
                 Graph*      graph2,
                 Conditions* conditions,
                 UIntS       depth,  // the number of filled positions in MAP
                 UIntS       pos,    // the last position filled
                 UIntS       rep_depth,
                 bool        has_trivial_stab,
                 // current number of distinct values in MAP
                 UIntS rank) {
  UIntS i, min, next;
  bool  is_trivial;

  if (depth == NR1) {  // we've assigned every position in <MAP>
    if (HINT != UNDEFINED && rank != HINT) {
      return;
    }
    HOOK(USER_PARAM, MAX_NR1_NR2, MAP);
    count++;
    if (count >= MAX_RESULTS) {
      longjmp(outofhere, 1);
    }
    return;
  }

  next = 0;          // the next position to fill
  min  = UNDEFINED;  // the minimum number of candidates for MAP[next]

  if (pos != UNDEFINED) {  // this is not the first call of the function
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
          min  = size_conditions(conditions, i);
        }
      }
    }
  } else {
    for (i = 0; i < NR1; i++) {
      if (size_conditions(conditions, i) < min) {
        next = i;
        min  = size_conditions(conditions, i);
      }
    }
  }

  BitArray* possible = get_conditions(conditions, next);

  if (rank < HINT) {
    for (i = 0; i < NR2; i++) {
      if (get_bit_array(possible, i) && !get_bit_array(VALS, i)
          && get_bit_array(REPS[rep_depth], i)) {
        if (!has_trivial_stab) {
          // stabiliser of the point i in the stabiliser at current rep_depth
          is_trivial = point_stabilizer(
              STAB_GENS[rep_depth], i, &STAB_GENS[rep_depth + 1]);
        }
        MAP[next] = i;
        set_bit_array(VALS, i, true);
        if (!has_trivial_stab) {
          if (depth != NR1 - 1) {
            orbit_reps(rep_depth + 1);
          }
          find_graph_homos(graph1,
                           graph2,
                           conditions,
                           depth + 1,
                           next,
                           rep_depth + 1,
                           is_trivial,
                           rank + 1);
        } else {
          find_graph_homos(graph1,
                           graph2,
                           conditions,
                           depth + 1,
                           next,
                           rep_depth,
                           true,
                           rank + 1);
        }
        MAP[next] = UNDEFINED;
        set_bit_array(VALS, i, false);
      }
    }
  }

  for (i = 0; i < NR2; i++) {
    if (get_bit_array(possible, i) && get_bit_array(VALS, i)) {
      MAP[next] = i;
      find_graph_homos(graph1,
                       graph2,
                       conditions,
                       depth + 1,
                       next,
                       rep_depth,
                       has_trivial_stab,
                       rank);
      MAP[next] = UNDEFINED;
    }
  }
  pop_conditions(conditions, depth);
}

////////////////////////////////////////////////////////////////////////////////
// GraphHomomorphisms: the function which calls the main recursive function
// <find_graph_homos>.
////////////////////////////////////////////////////////////////////////////////

void GraphHomomorphisms(Graph* graph1,
                        Graph* graph2,
                        void (*hook_arg)(void*        user_param,
                                         const UIntS  nr,
                                         const UIntS* map),
                        void*     user_param_arg,
                        UIntL     max_results_arg,
                        int       hint_arg,
                        BitArray* image_arg,
                        UIntS*    partial_map_arg,
                        UIntS*    colors1,
                        UIntS*    colors2) {
  DIGRAPHS_ASSERT(graph1 != NULL && graph2 != NULL);

  UIntS     i, j;
  BitArray* bit_array;

  NR1         = graph1->nr_vertices;
  NR2         = graph2->nr_vertices;
  MAX_NR1_NR2 = (NR1 < NR2 ? NR2 : NR1);

  DIGRAPHS_ASSERT(NR1 <= MAXVERTS && NR2 <= MAXVERTS);

  // initialise the conditions . . .
  Conditions* conditions = new_conditions(NR1, NR2);

  // image_arg is a pointer to a BitArray of possible image values for the
  // homomorphisms
  if (image_arg != NULL) {  // image_arg was specified
    for (i = 0; i < NR1; i++) {
      intersect_bit_arrays(get_conditions(conditions, i), image_arg);
      // intersect everything in the first row of conditions with <image_arg>
    }
  }
  // Used by orbit_reps, so that orbit reps are chosen from among the
  // restricted values of the image.
  IMAGE_RESTRICT = image_arg;

  // partial_map_arg is an array of UIntS's partially defining a map from graph1
  // to graph2.
  bit_array = new_bit_array(NR2);  // every position is false by default

  if (partial_map_arg != NULL) {  // a partial MAP was defined
    for (i = 0; i < NR1; i++) {
      if (partial_map_arg[i] != UNDEFINED) {
        init_bit_array(bit_array, false);
        set_bit_array(bit_array, partial_map_arg[i], true);
        intersect_bit_arrays(get_conditions(conditions, i), bit_array);
      }
    }
  }

  init_bit_array(bit_array, false);

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

  if (colors1 != NULL) {  // colors1 and colors2 specified
    DIGRAPHS_ASSERT(colors2 != NULL);
    for (i = 0; i < NR1; i++) {
      init_bit_array(bit_array, false);
      for (j = 0; j < NR2; j++) {
        if (colors1[i] == colors2[j]) {
          set_bit_array(bit_array, j, true);
        }
      }
      intersect_bit_arrays(get_conditions(conditions, i), bit_array);
      // can only map vertices of color i to vertices of color i
    }
  }

  free_bit_array(bit_array);

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
  for (i = NR1; i < MAX_NR1_NR2; i++) {
    MAP[i] = i;
  }

  // get generators of the automorphism group of graph2, and the orbit reps
  set_perms_degree(NR2);
  STAB_GENS[0] = automorphisms_graph(graph2, colors2);
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
  free_bit_array(ORB_LOOKUP);
  for (i = 0; i < NR1; i++) {
    free_bit_array(REPS[i]);
  }
  free(REPS);
  free_conditions(conditions);
}

////////////////////////////////////////////////////////////////////////////////
// a version of new main algorithm for injective homomorphisms
////////////////////////////////////////////////////////////////////////////////

static void
find_graph_monos(Graph*      graph1,
                 Graph*      graph2,
                 Conditions* conditions,
                 UIntS       depth,  // the number of filled positions in map
                 UIntS       pos,    // the last position filled
                 UIntS       rep_depth,
                 bool        has_trivial_stab) {
  UIntS i, min, next;
  bool  is_trivial;

  if (depth == NR1) {  // we've assigned every position in <MAP>
    HOOK(USER_PARAM, MAX_NR1_NR2, MAP);
    count++;
    if (count >= MAX_RESULTS) {
      longjmp(outofhere, 1);
    }
    return;
  }

  next = 0;          // the next position to fill
  min  = UNDEFINED;  // the minimum number of candidates for MAP[next]

  if (pos != UNDEFINED) {  // this is not the first call of the function
    for (i = 0; i < NR1; i++) {
      if (MAP[i] == UNDEFINED) {
        push_conditions(conditions, depth, i, NULL);
        set_bit_array(get_conditions(conditions, i), MAP[pos], false);
        // this could be optimised since MAP[pos] is fixed within the loop
        if (is_adjacent_graph(graph1, pos, i)) {
          intersect_bit_arrays(get_conditions(conditions, i),
                               graph2->neighbours[MAP[pos]]);
        }
        if (size_conditions(conditions, i) == 0) {
          pop_conditions(conditions, depth);
          return;
        }
        if (size_conditions(conditions, i) < min) {
          next = i;
          min  = size_conditions(conditions, i);
        }
      }
    }
  } else {
    for (i = 0; i < NR1; i++) {
      if (size_conditions(conditions, i) < min) {
        next = i;
        min  = size_conditions(conditions, i);
      }
    }
  }

  BitArray* possible = get_conditions(conditions, next);

  for (i = 0; i < NR2; i++) {
    if (get_bit_array(possible, i) && get_bit_array(REPS[rep_depth], i)) {
      if (!has_trivial_stab) {
        // stabiliser of the point i in the stabiliser at current rep_depth
        is_trivial = point_stabilizer(
            STAB_GENS[rep_depth], i, &STAB_GENS[rep_depth + 1]);
      }
      MAP[next] = i;
      set_bit_array(VALS, i, true);
      if (!has_trivial_stab) {
        if (depth != NR1 - 1) {
          orbit_reps(rep_depth + 1);
        }
        find_graph_monos(graph1,
                         graph2,
                         conditions,
                         depth + 1,
                         next,
                         rep_depth + 1,
                         is_trivial);
      } else {
        find_graph_monos(
            graph1, graph2, conditions, depth + 1, next, rep_depth, true);
      }
      MAP[next] = UNDEFINED;
      set_bit_array(VALS, i, false);
    }
  }

  pop_conditions(conditions, depth);
}

////////////////////////////////////////////////////////////////////////////////
// GraphMonomorphisms: the function which calls the main recursive function
// <find_graph_monos>.
////////////////////////////////////////////////////////////////////////////////

void GraphMonomorphisms(Graph* graph1,
                        Graph* graph2,
                        void (*hook_arg)(void*        user_param,
                                         const UIntS  nr,
                                         const UIntS* map),
                        void*     user_param_arg,
                        UIntL     max_results_arg,
                        BitArray* image_arg,
                        UIntS*    partial_map_arg,
                        UIntS*    colors1,
                        UIntS*    colors2) {
  DIGRAPHS_ASSERT(graph1 != NULL && graph2 != NULL);

  UIntS     i, j;
  BitArray* bit_array;

  NR1         = graph1->nr_vertices;
  NR2         = graph2->nr_vertices;
  MAX_NR1_NR2 = (NR1 < NR2 ? NR2 : NR1);

  DIGRAPHS_ASSERT(NR1 <= MAXVERTS && NR2 <= MAXVERTS);

  // initialise the conditions . . .
  Conditions* conditions = new_conditions(NR1, NR2);

  // image_arg is a pointer to a BitArray of possible image values for the
  // homomorphisms . . .
  if (image_arg != NULL) {  // image was specified
    if (size_bit_array(image_arg) < NR1) {
      // there isn't enough points in the image_arg
      return;
    }
    for (i = 0; i < NR1; i++) {
      intersect_bit_arrays(get_conditions(conditions, i), image_arg);
      // intersect everything in the first row of conditions with <image>
    }
  }
  // Used by orbit_reps, so that orbit reps are chosen from among the
  // restricted values of the image.
  IMAGE_RESTRICT = image_arg;

  // partial_map_arg is an array of UIntS's partially defining a map from
  // graph1 to graph2.
  bit_array = new_bit_array(NR2);  // every position is false by default

  if (partial_map_arg != NULL) {  // a partial map was defined
    BitArray* partial_map_arg_image =
        new_bit_array(NR2);  // values in the image of partial_map
    for (i = 0; i < NR1; i++) {
      if (partial_map_arg[i] != UNDEFINED) {
        if (get_bit_array(partial_map_arg_image, partial_map_arg[i])) {
          return;  // partial_map is not injective
        } else {
          set_bit_array(partial_map_arg_image, partial_map_arg[i], true);
        }
        init_bit_array(bit_array, false);
        set_bit_array(bit_array, partial_map_arg[i], true);
        intersect_bit_arrays(get_conditions(conditions, i), bit_array);
      }
    }
    free_bit_array(partial_map_arg_image);
  }

  init_bit_array(bit_array, false);

  // find loops in graph2
  for (i = 0; i < NR2; i++) {
    if (is_adjacent_graph(graph2, i, i)) {
      set_bit_array(bit_array, i, true);
    }
  }

  // loops in graph1 can only MAP to bit_array in graph2
  for (i = 0; i < NR1; i++) {
    if (is_adjacent_graph(graph1, i, i)) {
      intersect_bit_arrays(get_conditions(conditions, i), bit_array);
    }
    store_size_conditions(conditions, i);
  }

  if (colors1 != NULL) {  // colors1 and colors2 specified
    for (i = 0; i < NR1; i++) {
      init_bit_array(bit_array, false);
      for (j = 0; j < NR2; j++) {
        if (colors1[i] == colors2[j]) {
          set_bit_array(bit_array, j, true);
        }
      }
      intersect_bit_arrays(get_conditions(conditions, i), bit_array);
      // can only map vertices of color i to vertices of color i
    }
  }

  free_bit_array(bit_array);

  // store the values in <map>, this is initialised to every bit set to false,
  // by default.
  VALS       = new_bit_array(NR2);
  DOMAIN     = new_bit_array(NR2);
  ORB_LOOKUP = new_bit_array(NR2);
  REPS       = malloc(NR1 * sizeof(BitArray*));

  // initialise the <map> and store the sizes in the conditions.
  for (i = 0; i < NR1; i++) {
    REPS[i] = new_bit_array(NR2);
    MAP[i]  = UNDEFINED;
  }
  for (i = NR1; i < MAX_NR1_NR2; i++) {
    MAP[i] = i;
  }

  // get generators of the automorphism group of graph2, and the orbit reps
  set_perms_degree(NR2);
  STAB_GENS[0] = automorphisms_graph(graph2, colors2);
  orbit_reps(0);

  // misc parameters
  MAX_RESULTS = max_results_arg;
  USER_PARAM  = user_param_arg;
  HOOK        = hook_arg;

  // statistics . . . FIXME not currently used for anything
  count       = 0;
  last_report = 0;

  // go!
  if (setjmp(outofhere) == 0) {
    find_graph_monos(graph1, graph2, conditions, 0, UNDEFINED, 0, false);
  }

  // free the stab_gens
  for (i = 0; i < MAXVERTS; i++) {
    if (STAB_GENS[i] != NULL) {
      free_perm_coll(STAB_GENS[i]);
      STAB_GENS[i] = NULL;
    }
  }
  free_bit_array(VALS);
  free_bit_array(DOMAIN);
  free_bit_array(ORB_LOOKUP);
  for (i = 0; i < NR1; i++) {
    free_bit_array(REPS[i]);
  }
  free(REPS);
  free_conditions(conditions);
}
