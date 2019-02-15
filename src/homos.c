//
// homos.c               di/graph homomorphisms              Julius Jonusas
//                                                           J. D. Mitchell
//
// Copyright (C) 2014-19 - Julius Jonusas and J. D. Mitchell
//
// This file is free software, see the digraphs/LICENSE.

////////////////////////////////////////////////////////////////////////////////
//
// This file is organised as follows:
//
// 1. Macros
// 2. Forward declarations
// 3. Global variables
// 4. Hook functions
// 5. Static helper functions
// 6. The main recursive functions (and helpers)
// 7. The GAP-level function (and helpers)
//
////////////////////////////////////////////////////////////////////////////////

// TODO(later)
// 0. remove final arg from push_conditions
// 1. Try other bit hacks for iterating through set bits

#include "homos.h"

// C headers
#include <limits.h>   // for CHAR_BIT
#include <setjmp.h>   // for longjmp, setjmp, jmp_buf
#include <stdbool.h>  // for true, false, bool
#include <stddef.h>   // for NULL
#include <stdint.h>   // for uint16_t, uint64_t
#include <stdlib.h>   // for malloc, NULL
#include <time.h>     // for time

// GAP headers
#include "src/compiled.h"

// Digraphs package headers
#include "bitarray.h"         // for BitArray
#include "conditions.h"       // for Conditions
#include "digraphs-config.h"  // for DIGRAPHS_HAVE___BUILTIN_CTZLL
#include "digraphs-debug.h"   // for DIGRAPHS_ASSERT
#include "homos-graphs.h"     // for Digraph, Graph, . . .
#include "perms.h"            // for MAXVERTS, UNDEFINED, PermColl, Perm
#include "schreier-sims.h"    // for PermColl, . . .

////////////////////////////////////////////////////////////////////////////////
// 1. Macros
////////////////////////////////////////////////////////////////////////////////

#define MAX(a, b) (a < b ? b : a)
#define MIN(a, b) (a < b ? a : b)

#define NUMBER_BITS_PER_BLOCK (sizeof(Block) * CHAR_BIT)

// The next line can be used instead of the first line of STORE_MIN to
// randomise which vertex of minimum degree is used next, but I didn't find any
// cases where this made things faster.

// if (x < current_x || (x == current_x && (rand() & 1))) {

#define STORE_MIN(current_x, current_y, x, y) \
  if (x < current_x) {                        \
    current_x = x;                            \
    current_y = y;                            \
  }

// See the comment before STORE_MIN

// if (x < current_x || (x == current_x && (rand() & 1))) {

#define STORE_MIN_BREAK(current_x, current_y, x, y) \
  if (x < current_x) {                              \
    current_x = x;                                  \
    current_y = y;                                  \
    if (current_x == 1) {                           \
      break;                                        \
    }                                               \
  }

#if SIZEOF_VOID_P == 4 && DIGRAPHS_HAVE___BUILTIN_CTZLL
#undef DIGRAPHS_HAVE___BUILTIN_CTZLL
#endif

// The following macro is bitmap_decode_ctz_callpack from https://git.io/fho4p
#ifdef DIGRAPHS_HAVE___BUILTIN_CTZLL
#define FOR_SET_BITS(__bit_array, __nr_bits, __variable)     \
  for (size_t k = 0; k < NR_BLOCKS_LOOKUP[__nr_bits]; ++k) { \
    Block block = __bit_array->blocks[k];                    \
    while (block != 0) {                                     \
      uint64_t t = block & -block;                           \
      int      r = __builtin_ctzll(block);                   \
      __variable = k * 64 + r;                               \
      if (__variable >= __nr_bits) {                         \
        break;                                               \
      }

#define END_FOR_SET_BITS \
  block ^= t;            \
  }                      \
  }

#else
#define FOR_SET_BITS(__bit_array, __nr_bits, __variable)       \
  for (__variable = 0; __variable < __nr_bits; ++__variable) { \
    if (get_bit_array(__bit_array, __variable)) {
#define END_FOR_SET_BITS \
  }                      \
  }
#endif

////////////////////////////////////////////////////////////////////////////////
// 2. Forward declarations
////////////////////////////////////////////////////////////////////////////////

// Defined in digraphs.h
Int DigraphNrVertices(Obj);
Obj OutNeighbours(Obj);

// GAP level things, imported in digraphs.c
extern Obj IsDigraph;
extern Obj DIGRAPHS_ValidateVertexColouring;
extern Obj Infinity;
extern Obj IsSymmetricDigraph;
extern Obj GeneratorsOfGroup;
extern Obj AutomorphismGroup;

////////////////////////////////////////////////////////////////////////////////
// 3. Global variables
////////////////////////////////////////////////////////////////////////////////

static Obj GAP_FUNC;  // Variable to hold a GAP level hook function

static void (*HOOK)(void*,  // HOOK function applied to every homo found
                    const uint16_t,
                    const uint16_t*);
static void* USER_PARAM;  // a USER_PARAM for the hook

// Values in MAP are restricted to those positions in IMAGE_RESTRICT
static jmp_buf OUTOFHERE;  // so we can jump out of the deepest

static bool ORDERED;  // true if the vertices of the domain/source digraph
                      // should be considered in a different order than they are
                      // given, false otherwise.

static BitArray* BIT_ARRAY_BUFFER[MAXVERTS];  // A buffer
static BitArray* IMAGE_RESTRICT;              // Values in MAP must be in this
static BitArray* MAP_UNDEFINED[MAXVERTS];     // Undefined positions in MAP
static BitArray* ORB_LOOKUP;                  // points in orbit
static BitArray* VALS;                        // Values in MAP already

static BitArray** REPS;  // orbit reps organised by depth

static Conditions* CONDITIONS;

static Digraph* DIGRAPH1;  // Digraphs to hold incoming GAP digraphs
static Digraph* DIGRAPH2;

static Graph* GRAPH1;  // Graphs to hold incoming GAP symmetric digraphs
static Graph* GRAPH2;

static uint16_t MAP[MAXVERTS];            // partial image list
static uint16_t COLORS2[MAXVERTS];        // colors of range (di)graph
static uint16_t INVERSE_ORDER[MAXVERTS];  // external -> internal
static uint16_t MAP_BUFFER[MAXVERTS];     // For converting from internal ->
                                          // external and back when calling the
                                          // hook functions.
static uint16_t ORB[MAXVERTS];    // Array for containing nodes in an orbit.
static uint16_t ORDER[MAXVERTS];  // internal -> external

static PermColl*     STAB_GENS[MAXVERTS];  // stabiliser generators
static SchreierSims* SCHREIER_SIMS;

#ifdef DIGRAPHS_ENABLE_STATS
struct homo_stats_struct {
  time_t last_print;
  size_t max_depth;
  double mean_depth;
  size_t nr_calls;
  size_t nr_dead_branches;
  time_t start_time;
};

typedef struct homo_stats_struct HomoStats;

static HomoStats* STATS;

static inline void clear_stats(HomoStats* stats) {
  stats->last_print       = time(0);
  stats->max_depth        = 0;
  stats->mean_depth       = 0;
  stats->nr_calls         = 0;
  stats->nr_dead_branches = 0;
  stats->start_time       = time(0);
}

static void print_stats(HomoStats* stats) {
  printf("Running for %0.0fs . . .\n", difftime(time(0), stats->start_time));
  printf("Number of function calls = %*lu\n", 20, stats->nr_calls);
  printf("Mean depth               = %*.2f\n", 20, stats->mean_depth);
  printf("Max depth                = %*lu\n", 20, stats->max_depth);
  printf("Number of dead branches  = %*lu\n\n", 20, stats->nr_dead_branches);
}

static inline void update_stats(HomoStats* stats, uint64_t depth) {
  if (depth > stats->max_depth) {
    stats->max_depth = depth;
  }
  stats->nr_calls++;
  stats->mean_depth += (depth - stats->mean_depth) / stats->nr_calls;
  if (difftime(time(0), stats->last_print) > 0.9) {
    print_stats(stats);
    stats->last_print = time(0);
  }
}
#endif  // DIGRAPHS_ENABLE_STATS

////////////////////////////////////////////////////////////////////////////////
// 4. Hook functions
////////////////////////////////////////////////////////////////////////////////

static void
homo_hook_gap(void* user_param, uint16_t const nr, uint16_t const* map) {
  UInt2* ptr;
  Obj    t;
  UInt   i;

  // copy map into new trans2
  t   = NEW_TRANS2(nr);
  ptr = ADDR_TRANS2(t);

  for (i = 0; i < nr; i++) {
    ptr[i] = map[i];
  }
  CALL_2ARGS(GAP_FUNC, user_param, t);
}

static void
homo_hook_collect(void* user_param, uint16_t const nr, uint16_t const* map) {
  UInt2* ptr;
  Obj    t;
  UInt   i;

  if (TNUM_OBJ((Obj) user_param) == T_PLIST_EMPTY) {
    RetypeBag(user_param, T_PLIST);
  }

  // copy map into new trans2
  t   = NEW_TRANS2(nr);
  ptr = ADDR_TRANS2(t);

  for (i = 0; i < nr; i++) {
    ptr[i] = map[i];
  }

  ASS_LIST(user_param, LEN_LIST(user_param) + 1, t);
}

////////////////////////////////////////////////////////////////////////////////
// 5. Static helper functions
////////////////////////////////////////////////////////////////////////////////

// print_array is not used, but can be useful for debugging.

// static void print_array(uint16_t const* const array, uint16_t const len) {
//   if (array == NULL) {
//     printf("NULL");
//     return;
//   }
//   printf("<array {");
//   for (uint16_t i = 0; i < len; i++) {
//     printf(" %d", array[i]);
//   }
//   printf(" }>");
// }

static void get_automorphism_group_from_gap(Obj digraph_obj, PermColl* out) {
  DIGRAPHS_ASSERT(CALL_1ARGS(IsDigraph, digraph_obj) == True);
  Obj o = CALL_1ARGS(AutomorphismGroup, digraph_obj);
  o     = CALL_1ARGS(GeneratorsOfGroup, o);
  DIGRAPHS_ASSERT(IS_LIST(o));
  clear_perm_coll(out);
  out->degree = PERM_DEGREE;
  DIGRAPHS_ASSERT(out->capacity >= LEN_LIST(o));
  for (Int i = 1; i <= LEN_LIST(o); ++i) {
    DIGRAPHS_ASSERT(ISB_LIST(o, i));
    DIGRAPHS_ASSERT(IS_PERM2(ELM_LIST(o, i)) || IS_PERM4(ELM_LIST(o, i)));
    Obj p = ELM_LIST(o, i);
    DIGRAPHS_ASSERT(LargestMovedPointPerm(p) <= PERM_DEGREE);
    if (LargestMovedPointPerm(p) == 0) {
      continue;
    }
    Perm q = out->perms[i - 1];
    out->size++;
    DIGRAPHS_ASSERT(out->size == i);
    size_t dep;
    if (IS_PERM2(p)) {
      UInt2 const* ptp2 = CONST_ADDR_PERM2(p);
      dep               = MIN((uint16_t) DEG_PERM2(p), PERM_DEGREE);
      for (uint16_t j = 0; j < dep; ++j) {
        q[j] = (uint16_t) ptp2[j];
      }
    } else {
      DIGRAPHS_ASSERT(IS_PERM4(p));
      UInt4 const* ptp4 = CONST_ADDR_PERM4(p);
      dep               = MIN((uint16_t) DEG_PERM4(p), PERM_DEGREE);
      for (uint16_t j = 0; j < dep; ++j) {
        q[j] = (uint16_t) ptp4[j];
      }
    }
    for (uint16_t j = dep; j < PERM_DEGREE; ++j) {
      q[j] = j;
    }
  }
}

static void init_digraph_from_digraph_obj(Digraph* const digraph,
                                          Obj            digraph_obj,
                                          bool const     reorder) {
  DIGRAPHS_ASSERT(digraph != NULL);
  DIGRAPHS_ASSERT(CALL_1ARGS(IsDigraph, digraph_obj) == True);
  UInt const nr  = DigraphNrVertices(digraph_obj);
  Obj        out = OutNeighbours(digraph_obj);
  DIGRAPHS_ASSERT(nr < MAXVERTS);
  DIGRAPHS_ASSERT(IS_PLIST(out));
  clear_digraph(digraph, nr);

  if (!reorder) {
    for (uint16_t i = 1; i <= nr; i++) {
      Obj nbs = ELM_PLIST(out, i);
      DIGRAPHS_ASSERT(IS_LIST(nbs));
      for (uint16_t j = 1; j <= LEN_LIST(nbs); j++) {
        DIGRAPHS_ASSERT(IS_INTOBJ(ELM_LIST(nbs, j)));
        add_edge_digraph(digraph, i - 1, INT_INTOBJ(ELM_LIST(nbs, j)) - 1);
      }
    }
  } else {
    DIGRAPHS_ASSERT(ORDERED);
    for (uint16_t i = 1; i <= nr; i++) {
      Obj nbs = ELM_PLIST(out, ORDER[i - 1] + 1);
      DIGRAPHS_ASSERT(IS_LIST(nbs));
      for (uint16_t j = 1; j <= LEN_LIST(nbs); j++) {
        DIGRAPHS_ASSERT(IS_INTOBJ(ELM_LIST(nbs, j)));
        add_edge_digraph(
            digraph, i - 1, INVERSE_ORDER[INT_INTOBJ(ELM_LIST(nbs, j)) - 1]);
      }
    }
  }
}

static void init_graph_from_digraph_obj(Graph* const graph,
                                        Obj          digraph_obj,
                                        bool const   reorder) {
  DIGRAPHS_ASSERT(graph != NULL);
  DIGRAPHS_ASSERT(CALL_1ARGS(IsDigraph, digraph_obj) == True);
  DIGRAPHS_ASSERT(CALL_1ARGS(IsSymmetricDigraph, digraph_obj) == True);
  UInt const nr  = DigraphNrVertices(digraph_obj);
  Obj        out = OutNeighbours(digraph_obj);
  DIGRAPHS_ASSERT(nr < MAXVERTS);
  DIGRAPHS_ASSERT(IS_PLIST(out));
  clear_graph(graph, nr);

  if (!reorder) {
    for (uint16_t i = 1; i <= nr; i++) {
      Obj nbs = ELM_PLIST(out, i);
      DIGRAPHS_ASSERT(IS_LIST(nbs));
      for (uint16_t j = 1; j <= LEN_LIST(nbs); j++) {
        DIGRAPHS_ASSERT(IS_INTOBJ(ELM_LIST(nbs, j)));
        add_edge_graph(graph, i - 1, INT_INTOBJ(ELM_LIST(nbs, j)) - 1);
      }
    }
  } else {
    DIGRAPHS_ASSERT(ORDERED);
    for (uint16_t i = 1; i <= nr; i++) {  // Nodes in the new graph
      Obj nbs = ELM_PLIST(out, ORDER[i - 1] + 1);
      DIGRAPHS_ASSERT(IS_LIST(nbs));
      for (uint16_t j = 1; j <= LEN_LIST(nbs); j++) {
        DIGRAPHS_ASSERT(IS_INTOBJ(ELM_LIST(nbs, j)));
        add_edge_graph(
            graph, i - 1, INVERSE_ORDER[INT_INTOBJ(ELM_LIST(nbs, j)) - 1]);
      }
    }
  }
}

// Find orbit representatives of the group generated by STAB_GENS[rep_depth]
// and store them in REPS[rep_depth], only values in IMAGE_RESTRICT will be
// chosen as orbit representatives.
static bool compute_stabs_and_orbit_reps(uint16_t const nr_nodes_1,
                                         uint16_t const nr_nodes_2,
                                         uint16_t const rep_depth,
                                         uint16_t const depth,
                                         uint16_t const pt) {
  DIGRAPHS_ASSERT(rep_depth <= depth + 1);

  if (depth == nr_nodes_1 - 1) {
    return false;  // This doesn't really say anything about the stabiliser
  } else if (rep_depth > 0) {
    point_stabilizer(
        SCHREIER_SIMS, STAB_GENS[rep_depth - 1], STAB_GENS[rep_depth], pt);
    if (STAB_GENS[rep_depth]->size == 0) {
      // the stabiliser of pt in STAB_GENS[rep_depth - 1] is trivial
      copy_bit_array(REPS[rep_depth], IMAGE_RESTRICT, nr_nodes_2);
      complement_bit_arrays(REPS[rep_depth], VALS, nr_nodes_2);
      // REPS[rep_depth] is a set of orbit representatives of the stabiliser of
      // the existing values in MAP, which belong to VALS, and since the
      // stabiliser is trivial, we take valid choice as the set of
      // representatives.
      return true;  // the stabiliser is trivial
    }
  }

  init_bit_array(REPS[rep_depth], false, nr_nodes_2);
  copy_bit_array(ORB_LOOKUP, VALS, nr_nodes_2);
  uint16_t fst = 0;
  while (fst < PERM_DEGREE
         && (get_bit_array(ORB_LOOKUP, fst)
             || !get_bit_array(IMAGE_RESTRICT, fst))) {
    fst++;
  }

  while (fst < PERM_DEGREE) {
    ORB[0]     = fst;
    uint16_t n = 1;  // length of ORB

    set_bit_array(REPS[rep_depth], fst, true);
    set_bit_array(ORB_LOOKUP, fst, true);

    for (uint16_t i = 0; i < n; ++i) {
      for (uint16_t j = 0; j < STAB_GENS[rep_depth]->size; ++j) {
        Perm           gen = STAB_GENS[rep_depth]->perms[j];
        uint16_t const img = gen[ORB[i]];
        if (!get_bit_array(ORB_LOOKUP, img)) {
          ORB[n++] = img;
          set_bit_array(ORB_LOOKUP, img, true);
        }
      }
    }
    while (fst < PERM_DEGREE
           && (get_bit_array(ORB_LOOKUP, fst)
               || !get_bit_array(IMAGE_RESTRICT, fst))) {
      fst++;
    }
  }
  return false;  // the stabiliser is not trivial
}

// Rewrite the global variable MAP so that it contains a homomorphism of the
// original GAP level (di)graph, and not the possibly distinct (but isomorphic)
// copy in the homomorphism search.  This should be called before any calls to
// the hook functions (i.e. after an entire homomorphism is found).
static void external_order_map_digraph(Digraph* digraph) {
  if (!ORDERED) {
    return;
  }
  for (uint16_t i = 0; i < digraph->nr_vertices; ++i) {
    MAP_BUFFER[ORDER[i]] = MAP[i];
  }
  for (uint16_t i = 0; i < digraph->nr_vertices; ++i) {
    MAP[i] = MAP_BUFFER[i];
  }
}

static void external_order_map_graph(Graph* graph) {
  if (!ORDERED) {
    return;
  }
  for (uint16_t i = 0; i < graph->nr_vertices; ++i) {
    MAP_BUFFER[ORDER[i]] = MAP[i];
  }
  for (uint16_t i = 0; i < graph->nr_vertices; ++i) {
    MAP[i] = MAP_BUFFER[i];
  }
}

// Rewrite the global variable MAP so that it contains a homomorphism of the
// internal (di)graph, and not the possibly distinct (but isomorphic) GAP level
// (di)graph.  This should be called after any calls to the hook functions
// (i.e. after an entire homomorphism is found).
static void internal_order_map_digraph(Digraph const* const digraph) {
  if (!ORDERED) {
    return;
  }
  for (uint16_t i = 0; i < digraph->nr_vertices; ++i) {
    MAP_BUFFER[INVERSE_ORDER[i]] = MAP[i];
  }
  for (uint16_t i = 0; i < digraph->nr_vertices; ++i) {
    MAP[i] = MAP_BUFFER[i];
  }
}

static void internal_order_map_graph(Graph const* const graph) {
  if (!ORDERED) {
    return;
  }
  for (uint16_t i = 0; i < graph->nr_vertices; ++i) {
    MAP_BUFFER[INVERSE_ORDER[i]] = MAP[i];
  }
  for (uint16_t i = 0; i < graph->nr_vertices; ++i) {
    MAP[i] = MAP_BUFFER[i];
  }
}

////////////////////////////////////////////////////////////////////////////////
// 6. The main recursive functions (and helpers)
////////////////////////////////////////////////////////////////////////////////

// Helper for the main recursive homomorphism function.
static ALWAYS_INLINE uint16_t
                     graph_homo_update_conditions(uint16_t const depth,
                                                  uint16_t const last_defined,
                                                  uint16_t const vertex) {
  push_conditions(
      CONDITIONS, depth, vertex, GRAPH2->neighbours[MAP[last_defined]]);
  store_size_conditions(CONDITIONS, vertex);
  return size_conditions(CONDITIONS, vertex);
}

// The main recursive function for homomorphisms of graphs.
//
// The arguments are:
//
// 1. depth             The current depth of the search (i.e. number of
//                      positions in MAP that are assigned).
// 2. pos               The last position in MAP that was filled
// 3. rep_depth         The depth of the stabilisers of points in MAP already.
//                      This is different than depth because we stop increasing
//                      the rep_depth when we first encounter a trivial
//                      stabiliser.
// 4. has_trivial_stab  true if the stabiliser of the values already in MAP is
//                      trivial, false otherwise.
// 5. rank              The current number of distinct values in MAP.
// 6. max_results       The maximum number of results to find.
// 7. hint              The desired number of distinct points in a (full)
//                      homomorphism.
// 8. count             The number of homomorphisms found so far.
static void find_graph_homos(uint16_t        depth,
                             uint16_t        pos,
                             uint16_t        rep_depth,
                             bool            has_trivial_stab,
                             uint16_t        rank,
                             uint64_t const  max_results,
                             uint64_t const  hint,
                             uint64_t* const count) {
#ifdef DIGRAPHS_ENABLE_STATS
  update_stats(STATS, depth);
#endif
  if (depth == GRAPH1->nr_vertices) {
    // Every position in MAP is assigned . . .
    if (hint != UNDEFINED && rank != hint) {
#ifdef DIGRAPHS_ENABLE_STATS
      STATS->nr_dead_branches++;
#endif
      return;
    }
    external_order_map_graph(GRAPH1);
    HOOK(USER_PARAM, MAX(GRAPH1->nr_vertices, GRAPH2->nr_vertices), MAP);
    internal_order_map_graph(GRAPH1);
    (*count)++;
    if (*count >= max_results) {
      longjmp(OUTOFHERE, 1);
    }
    return;
  }

  uint16_t next = 0;          // the next position to fill
  uint16_t min  = UNDEFINED;  // the minimum number of candidates for MAP[next]
  uint16_t i;

  BitArray* possible = BIT_ARRAY_BUFFER[depth];

  if (depth > 0) {  // this is not the first call of the function
    copy_bit_array(
        MAP_UNDEFINED[depth], MAP_UNDEFINED[depth - 1], GRAPH1->nr_vertices);
    copy_bit_array(possible, MAP_UNDEFINED[depth], GRAPH1->nr_vertices);
    intersect_bit_arrays(
        possible, GRAPH1->neighbours[pos], GRAPH1->nr_vertices);
    FOR_SET_BITS(possible, GRAPH1->nr_vertices, i) {
      size_t const n = graph_homo_update_conditions(depth, pos, i);
      if (n == 0) {
#ifdef DIGRAPHS_ENABLE_STATS
        STATS->nr_dead_branches++;
#endif
        pop_conditions(CONDITIONS, depth);
        return;
      }
      STORE_MIN(min, next, n, i);
    }
    END_FOR_SET_BITS
    if (min > 1) {
      copy_bit_array(possible, MAP_UNDEFINED[depth], GRAPH1->nr_vertices);
      complement_bit_arrays(
          possible, GRAPH1->neighbours[pos], GRAPH1->nr_vertices);
      FOR_SET_BITS(possible, GRAPH1->nr_vertices, i) {
        size_t const n = size_conditions(CONDITIONS, i);
        STORE_MIN_BREAK(min, next, n, i);
      }
      END_FOR_SET_BITS
    }
  } else {
    for (i = 0; i < GRAPH1->nr_vertices; ++i) {
      size_t const n = size_conditions(CONDITIONS, i);
      STORE_MIN_BREAK(min, next, n, i);
    }
  }
  DIGRAPHS_ASSERT(get_bit_array(MAP_UNDEFINED[depth], next));

  if (rank < hint) {
    copy_bit_array(
        possible, get_conditions(CONDITIONS, next), GRAPH2->nr_vertices);
    complement_bit_arrays(possible, VALS, GRAPH2->nr_vertices);
    intersect_bit_arrays(possible, REPS[rep_depth], GRAPH2->nr_vertices);
    FOR_SET_BITS(possible, GRAPH2->nr_vertices, i) {
      MAP[next] = i;
      set_bit_array(VALS, i, true);
      set_bit_array(MAP_UNDEFINED[depth], next, false);
      if (!has_trivial_stab) {
        find_graph_homos(depth + 1,
                         next,
                         rep_depth + 1,
                         compute_stabs_and_orbit_reps(GRAPH1->nr_vertices,
                                                      GRAPH2->nr_vertices,
                                                      rep_depth + 1,
                                                      depth,
                                                      i),
                         rank + 1,
                         max_results,
                         hint,
                         count);
      } else {
        find_graph_homos(depth + 1,
                         next,
                         rep_depth,
                         true,
                         rank + 1,
                         max_results,
                         hint,
                         count);
      }
      MAP[next] = UNDEFINED;
      set_bit_array(VALS, i, false);
      set_bit_array(MAP_UNDEFINED[depth], next, true);
    }
    END_FOR_SET_BITS
  }
  copy_bit_array(
      possible, get_conditions(CONDITIONS, next), GRAPH2->nr_vertices);
  intersect_bit_arrays(possible, VALS, GRAPH2->nr_vertices);
  FOR_SET_BITS(possible, GRAPH2->nr_vertices, i) {
    MAP[next] = i;
    set_bit_array(MAP_UNDEFINED[depth], next, false);
    find_graph_homos(depth + 1,
                     next,
                     rep_depth,
                     has_trivial_stab,
                     rank,
                     max_results,
                     hint,
                     count);
    MAP[next] = UNDEFINED;
    set_bit_array(MAP_UNDEFINED[depth], next, true);
  }
  END_FOR_SET_BITS
  pop_conditions(CONDITIONS, depth);
}

// Helper for the main recursive monomorphism function.
static ALWAYS_INLINE uint16_t
                     graph_mono_update_conditions(uint16_t const depth,
                                                  uint16_t const last_defined,
                                                  uint16_t const vertex) {
  push_conditions(
      CONDITIONS, depth, vertex, GRAPH2->neighbours[MAP[last_defined]]);
  set_bit_array(get_conditions(CONDITIONS, vertex), MAP[last_defined], false);
  store_size_conditions(CONDITIONS, vertex);
  return size_conditions(CONDITIONS, vertex);
}

// The main recursive function for monomorphisms of graphs.
//
// The arguments are:
//
// 1. depth             The current depth of the search (i.e. number of
//                      positions in MAP that are assigned).
// 2. pos               The last position in MAP that was filled
// 3. rep_depth         The depth of the stabilisers of points in MAP already.
//                      This is different than depth because we stop increasing
//                      the rep_depth when we first encounter a trivial
//                      stabiliser.
// 4. has_trivial_stab  true if the stabiliser of the values already in MAP is
//                      trivial, false otherwise.
// 5. max_results       The maximum number of results to find.
// 6. count             The number of embeddings found so far.
static void find_graph_monos(uint16_t        depth,
                             uint16_t        pos,
                             uint16_t        rep_depth,
                             bool            has_trivial_stab,
                             uint64_t const  max_results,
                             uint64_t* const count) {
#ifdef DIGRAPHS_ENABLE_STATS
  update_stats(STATS, depth);
#endif
  if (depth == GRAPH1->nr_vertices) {
    // we've assigned every position in <MAP>
    external_order_map_graph(GRAPH1);
    HOOK(USER_PARAM, MAX(GRAPH1->nr_vertices, GRAPH2->nr_vertices), MAP);
    internal_order_map_graph(GRAPH1);
    (*count)++;
    if (*count >= max_results) {
      longjmp(OUTOFHERE, 1);
    }
    return;
  }

  uint16_t next = 0;          // the next position to fill
  uint16_t min  = UNDEFINED;  // the minimum number of candidates for MAP[next]
  uint16_t i;

  BitArray* possible = BIT_ARRAY_BUFFER[depth];

  if (depth > 0) {  // this is not the first call of the function
    copy_bit_array(
        MAP_UNDEFINED[depth], MAP_UNDEFINED[depth - 1], GRAPH1->nr_vertices);
    copy_bit_array(possible, MAP_UNDEFINED[depth], GRAPH1->nr_vertices);
    intersect_bit_arrays(
        possible, GRAPH1->neighbours[pos], GRAPH1->nr_vertices);
    FOR_SET_BITS(possible, GRAPH1->nr_vertices, i) {
      size_t const n = graph_mono_update_conditions(depth, pos, i);
      if (n == 0) {
#ifdef DIGRAPHS_ENABLE_STATS
        STATS->nr_dead_branches++;
#endif
        pop_conditions(CONDITIONS, depth);
        return;
      }
      STORE_MIN(min, next, n, i);
    }
    END_FOR_SET_BITS
    if (min > 1) {
      copy_bit_array(possible, MAP_UNDEFINED[depth], GRAPH1->nr_vertices);
      complement_bit_arrays(
          possible, GRAPH1->neighbours[pos], GRAPH1->nr_vertices);
      FOR_SET_BITS(possible, GRAPH1->nr_vertices, i) {
        size_t const n = size_conditions(CONDITIONS, i);
        STORE_MIN_BREAK(min, next, n, i);
      }
      END_FOR_SET_BITS
    }
  } else {
    for (i = 0; i < GRAPH1->nr_vertices; ++i) {
      size_t const n = size_conditions(CONDITIONS, i);
      STORE_MIN_BREAK(min, next, n, i);
    }
  }
  copy_bit_array(
      possible, get_conditions(CONDITIONS, next), GRAPH2->nr_vertices);
  intersect_bit_arrays(possible, REPS[rep_depth], GRAPH2->nr_vertices);
  FOR_SET_BITS(possible, GRAPH2->nr_vertices, i) {
    MAP[next] = i;
    set_bit_array(VALS, i, true);
    set_bit_array(MAP_UNDEFINED[depth], next, false);
    if (!has_trivial_stab) {
      find_graph_monos(depth + 1,
                       next,
                       rep_depth + 1,
                       compute_stabs_and_orbit_reps(GRAPH1->nr_vertices,
                                                    GRAPH2->nr_vertices,
                                                    rep_depth + 1,
                                                    depth,
                                                    i),
                       max_results,
                       count);
    } else {
      find_graph_monos(depth + 1, next, rep_depth, true, max_results, count);
    }
    MAP[next] = UNDEFINED;
    set_bit_array(VALS, i, false);
    set_bit_array(MAP_UNDEFINED[depth], next, true);
  }
  END_FOR_SET_BITS
  pop_conditions(CONDITIONS, depth);
}

// Helper for the main recursive embedding function.
static ALWAYS_INLINE uint16_t graph_embed_update_conditions(
    uint16_t const depth,
    uint16_t const last_defined,
    uint16_t const vertex,
    void (*oper)(BitArray* const, BitArray const* const, uint16_t const)) {
  push_conditions(CONDITIONS, depth, vertex, NULL);
  oper(get_conditions(CONDITIONS, vertex),
       GRAPH2->neighbours[MAP[last_defined]],
       GRAPH2->nr_vertices);
  store_size_conditions(CONDITIONS, vertex);
  return size_conditions(CONDITIONS, vertex);
}

// The main recursive function for embeddings of graphs.
//
// The arguments are:
//
// 1. depth             The current depth of the search (i.e. number of
//                      positions in MAP that are assigned).
// 2. pos               The last position in MAP that was filled
// 3. rep_depth         The depth of the stabilisers of points in MAP already.
//                      This is different than depth because we stop increasing
//                      the rep_depth when we first encounter a trivial
//                      stabiliser.
// 4. has_trivial_stab  true if the stabiliser of the values already in MAP is
//                      trivial, false otherwise.
// 5. max_results       The maximum number of results to find.
// 6. count             The number of embeddings found so far.
static void find_graph_embeddings(uint16_t        depth,
                                  uint16_t        pos,
                                  uint16_t        rep_depth,
                                  bool            has_trivial_stab,
                                  uint64_t const  max_results,
                                  uint64_t* const count) {
#ifdef DIGRAPHS_ENABLE_STATS
  update_stats(STATS, depth);
#endif
  if (depth == GRAPH1->nr_vertices) {
    // we've assigned every position in <MAP>
    external_order_map_graph(GRAPH1);
    HOOK(USER_PARAM, MAX(GRAPH1->nr_vertices, GRAPH2->nr_vertices), MAP);
    internal_order_map_graph(GRAPH1);
    (*count)++;
    if (*count >= max_results) {
      longjmp(OUTOFHERE, 1);
    }
    return;
  }

  uint16_t next = 0;          // the next position to fill
  uint16_t min  = UNDEFINED;  // the minimum number of candidates for MAP[next]
  uint16_t i;

  BitArray* possible = BIT_ARRAY_BUFFER[depth];

  if (depth > 0) {  // this is not the first call of the function
    copy_bit_array(
        MAP_UNDEFINED[depth], MAP_UNDEFINED[depth - 1], GRAPH1->nr_vertices);
    copy_bit_array(possible, MAP_UNDEFINED[depth], GRAPH1->nr_vertices);
    intersect_bit_arrays(
        possible, GRAPH1->neighbours[pos], GRAPH1->nr_vertices);
    FOR_SET_BITS(possible, GRAPH1->nr_vertices, i) {
      size_t const n =
          graph_embed_update_conditions(depth, pos, i, &intersect_bit_arrays);
      if (n == 0) {
#ifdef DIGRAPHS_ENABLE_STATS
        STATS->nr_dead_branches++;
#endif
        pop_conditions(CONDITIONS, depth);
        return;
      }
      STORE_MIN(min, next, n, i);
    }
    END_FOR_SET_BITS
    copy_bit_array(possible, MAP_UNDEFINED[depth], GRAPH1->nr_vertices);
    complement_bit_arrays(
        possible, GRAPH1->neighbours[pos], GRAPH1->nr_vertices);
    FOR_SET_BITS(possible, GRAPH1->nr_vertices, i) {
      size_t const n =
          graph_embed_update_conditions(depth, pos, i, &complement_bit_arrays);
      if (n == 0) {
#ifdef DIGRAPHS_ENABLE_STATS
        STATS->nr_dead_branches++;
#endif
        pop_conditions(CONDITIONS, depth);
        return;
      }
      STORE_MIN(min, next, n, i);
    }
    END_FOR_SET_BITS
  } else {
    for (i = 0; i < GRAPH1->nr_vertices; ++i) {
      size_t const n = size_conditions(CONDITIONS, i);
      STORE_MIN_BREAK(min, next, n, i);
    }
  }

  copy_bit_array(
      possible, get_conditions(CONDITIONS, next), GRAPH2->nr_vertices);
  intersect_bit_arrays(possible, REPS[rep_depth], GRAPH2->nr_vertices);

  FOR_SET_BITS(possible, GRAPH2->nr_vertices, i) {
    MAP[next] = i;
    set_bit_array(VALS, i, true);
    set_bit_array(MAP_UNDEFINED[depth], next, false);
    if (!has_trivial_stab) {
      find_graph_embeddings(depth + 1,
                            next,
                            rep_depth + 1,
                            compute_stabs_and_orbit_reps(GRAPH1->nr_vertices,
                                                         GRAPH2->nr_vertices,
                                                         rep_depth + 1,
                                                         depth,
                                                         MAP[next]),
                            max_results,
                            count);
    } else {
      find_graph_embeddings(
          depth + 1, next, rep_depth, true, max_results, count);
    }
    MAP[next] = UNDEFINED;
    set_bit_array(VALS, i, false);
    set_bit_array(MAP_UNDEFINED[depth], next, true);
  }
  END_FOR_SET_BITS
  pop_conditions(CONDITIONS, depth);
}

////////////////////////////////////////////////////////////////////////////////
// The next function should be called before find_graph_homos.  This function
// simulates the first steps of the recursion using the information in
// partial_map_obj (if any) so that the values specified in partial_map_obj are
// installed in MAP first.
////////////////////////////////////////////////////////////////////////////////

static void init_partial_map_and_find_graph_homos(Obj partial_map_obj,
                                                  uint64_t const  max_results,
                                                  uint64_t const  hint,
                                                  uint64_t* const count,
                                                  Obj injective_obj) {
  uint16_t depth                = 0;
  uint16_t rep_depth            = 0;
  uint16_t last_defined         = UNDEFINED;
  bool     last_stab_is_trivial = (STAB_GENS[0]->size == 0 ? true : false);
  uint16_t rank                 = 0;
  uint16_t next                 = UNDEFINED;

  if (partial_map_obj != Fail) {
    for (next = 0; next < LEN_LIST(partial_map_obj); ++next) {
      if (ISB_LIST(partial_map_obj, next + 1)) {
        if (depth > 0) {
          DIGRAPHS_ASSERT(last_defined != UNDEFINED);
          copy_bit_array(MAP_UNDEFINED[depth],
                         MAP_UNDEFINED[depth - 1],
                         GRAPH1->nr_vertices);
          BitArray* possible = BIT_ARRAY_BUFFER[0];
          copy_bit_array(possible, MAP_UNDEFINED[depth], GRAPH1->nr_vertices);
          intersect_bit_arrays(
              possible, GRAPH1->neighbours[last_defined], GRAPH1->nr_vertices);
          if (INT_INTOBJ(injective_obj) == 0) {
            uint16_t i;  // variable for the next for-loop
            FOR_SET_BITS(possible, GRAPH1->nr_vertices, i) {
              uint16_t n = graph_homo_update_conditions(depth, last_defined, i);
              if (n == 0) {
                return;
              }
            }
            END_FOR_SET_BITS
          } else if (INT_INTOBJ(injective_obj) == 1) {
            uint16_t i;  // variable for the next for-loop
            FOR_SET_BITS(possible, GRAPH1->nr_vertices, i) {
              uint16_t n = graph_mono_update_conditions(depth, last_defined, i);
              if (n == 0) {
                return;
              }
            }
            END_FOR_SET_BITS
          } else {
            DIGRAPHS_ASSERT(INT_INTOBJ(injective_obj) == 2);
            uint16_t i;  // variable for the next for-loop
            FOR_SET_BITS(possible, GRAPH1->nr_vertices, i) {
              uint16_t n = graph_embed_update_conditions(
                  depth, last_defined, i, &intersect_bit_arrays);
              if (n == 0) {
                return;
              }
              END_FOR_SET_BITS
            }
            copy_bit_array(possible, MAP_UNDEFINED[depth], GRAPH1->nr_vertices);
            complement_bit_arrays(possible,
                                  GRAPH1->neighbours[last_defined],
                                  GRAPH1->nr_vertices);
            FOR_SET_BITS(possible, GRAPH1->nr_vertices, i) {
              uint16_t n = graph_embed_update_conditions(
                  depth, last_defined, i, &complement_bit_arrays);
              if (n == 0) {
                return;
              }
            }
            END_FOR_SET_BITS
          }
        }
        uint16_t val = INT_INTOBJ(ELM_LIST(partial_map_obj, next + 1)) - 1;
        next         = (ORDERED ? INVERSE_ORDER[next] : next);
        MAP[next]    = val;
        if (!get_bit_array(VALS, MAP[next])) {
          rank++;
          if (rank > hint) {
            return;
          }
        }
        set_bit_array(VALS, MAP[next], true);
        set_bit_array(MAP_UNDEFINED[depth], next, false);
        if (!last_stab_is_trivial) {
          last_stab_is_trivial =
              compute_stabs_and_orbit_reps(GRAPH1->nr_vertices,
                                           GRAPH2->nr_vertices,
                                           rep_depth + 1,
                                           depth,
                                           MAP[next]);
          rep_depth++;
        }
        depth++;
        last_defined = next;
        next         = (ORDERED ? ORDER[next] : next);
      }
    }
  }
  if (INT_INTOBJ(injective_obj) == 0) {
    find_graph_homos(depth,
                     last_defined,
                     rep_depth,
                     last_stab_is_trivial,
                     rank,
                     max_results,
                     hint,
                     count);
  } else if (INT_INTOBJ(injective_obj) == 1) {
    find_graph_monos(depth,
                     last_defined,
                     rep_depth,
                     last_stab_is_trivial,
                     max_results,
                     count);
  } else if (INT_INTOBJ(injective_obj) == 2) {
    find_graph_embeddings(depth,
                          last_defined,
                          rep_depth,
                          last_stab_is_trivial,
                          max_results,
                          count);
  }
}

// Helper for the main recursive homomorphism of digraphs function.
static ALWAYS_INLINE uint16_t
                     digraph_homo_update_conditions(uint16_t const depth,
                                                    uint16_t const last_defined,
                                                    uint16_t const vertex) {
  if (is_adjacent_digraph(DIGRAPH1, last_defined, vertex)) {
    push_conditions(
        CONDITIONS, depth, vertex, DIGRAPH2->out_neighbours[MAP[last_defined]]);
    if (is_adjacent_digraph(DIGRAPH1, vertex, last_defined)) {
      intersect_bit_arrays(get_conditions(CONDITIONS, vertex),
                           DIGRAPH2->in_neighbours[MAP[last_defined]],
                           DIGRAPH2->nr_vertices);
    }
    store_size_conditions(CONDITIONS, vertex);
  } else if (is_adjacent_digraph(DIGRAPH1, vertex, last_defined)) {
    push_conditions(
        CONDITIONS, depth, vertex, DIGRAPH2->in_neighbours[MAP[last_defined]]);
    store_size_conditions(CONDITIONS, vertex);
  }
  return size_conditions(CONDITIONS, vertex);
}

// The main recursive function for homomorphisms of digraphs.
//
// The arguments are:
//
// 1. depth             The current depth of the search (i.e. number of
//                      positions in MAP that are assigned).
// 2. pos               The last position in MAP that was filled
// 3. rep_depth         The depth of the stabilisers of points in MAP already.
//                      This is different than depth because we stop increasing
//                      the rep_depth when we first encounter a trivial
//                      stabiliser.
// 4. has_trivial_stab  true if the stabiliser of the values already in MAP is
//                      trivial, false otherwise.
// 5. rank              The current number of distinct values in MAP.
// 6. max_results       The maximum number of results to find.
// 7. hint              The desired number of distinct points in a (full)
//                      homomorphism.
// 8. count             The number of homomorphisms found so far.
static void find_digraph_homos(uint16_t        depth,
                               uint16_t        pos,
                               uint16_t        rep_depth,
                               bool            has_trivial_stab,
                               uint16_t        rank,
                               uint64_t const  max_results,
                               uint64_t const  hint,
                               uint64_t* const count) {
#ifdef DIGRAPHS_ENABLE_STATS
  update_stats(STATS, depth);
#endif
  if (depth == DIGRAPH1->nr_vertices) {
    // we've assigned every position in <MAP>
    if (hint != UNDEFINED && rank != hint) {
#ifdef DIGRAPHS_ENABLE_STATS
      STATS->nr_dead_branches++;
#endif
      return;
    }
    external_order_map_digraph(DIGRAPH1);
    HOOK(USER_PARAM, MAX(DIGRAPH1->nr_vertices, DIGRAPH2->nr_vertices), MAP);
    internal_order_map_digraph(DIGRAPH1);
    (*count)++;
    if (*count >= max_results) {
      longjmp(OUTOFHERE, 1);
    }
    return;
  }

  uint16_t next = 0;          // the next position to fill
  uint16_t min  = UNDEFINED;  // the minimum number of candidates for MAP[next]
  uint16_t i;

  if (depth > 0) {  // this is not the first call of the function
    copy_bit_array(
        MAP_UNDEFINED[depth], MAP_UNDEFINED[depth - 1], DIGRAPH1->nr_vertices);
    FOR_SET_BITS(MAP_UNDEFINED[depth], DIGRAPH1->nr_vertices, i) {
      uint16_t const n = digraph_homo_update_conditions(depth, pos, i);
      if (n == 0) {
#ifdef DIGRAPHS_ENABLE_STATS
        STATS->nr_dead_branches++;
#endif
        pop_conditions(CONDITIONS, depth);
        return;
      }
      STORE_MIN(min, next, n, i);
    }
    END_FOR_SET_BITS
  } else {  // depth == 0
    for (i = 0; i < DIGRAPH1->nr_vertices; ++i) {
      size_t const n = size_conditions(CONDITIONS, i);
      STORE_MIN_BREAK(min, next, n, i);
    }
  }

  BitArray* possible = BIT_ARRAY_BUFFER[depth];

  if (rank < hint) {
    copy_bit_array(
        possible, get_conditions(CONDITIONS, next), DIGRAPH2->nr_vertices);
    complement_bit_arrays(possible, VALS, DIGRAPH2->nr_vertices);
    intersect_bit_arrays(possible, REPS[rep_depth], DIGRAPH2->nr_vertices);
    FOR_SET_BITS(possible, DIGRAPH2->nr_vertices, i) {
      MAP[next] = i;
      set_bit_array(VALS, i, true);
      set_bit_array(MAP_UNDEFINED[depth], next, false);
      if (!has_trivial_stab) {
        find_digraph_homos(depth + 1,
                           next,
                           rep_depth + 1,
                           compute_stabs_and_orbit_reps(DIGRAPH1->nr_vertices,
                                                        DIGRAPH2->nr_vertices,
                                                        rep_depth + 1,
                                                        depth,
                                                        i),
                           rank + 1,
                           max_results,
                           hint,
                           count);
      } else {
        find_digraph_homos(depth + 1,
                           next,
                           rep_depth,
                           true,
                           rank + 1,
                           max_results,
                           hint,
                           count);
      }
      MAP[next] = UNDEFINED;
      set_bit_array(VALS, i, false);
      set_bit_array(MAP_UNDEFINED[depth], next, true);
    }
    END_FOR_SET_BITS
  }
  copy_bit_array(
      possible, get_conditions(CONDITIONS, next), DIGRAPH2->nr_vertices);
  intersect_bit_arrays(possible, VALS, DIGRAPH2->nr_vertices);
  FOR_SET_BITS(possible, DIGRAPH2->nr_vertices, i) {
    MAP[next] = i;
    set_bit_array(MAP_UNDEFINED[depth], next, false);
    find_digraph_homos(depth + 1,
                       next,
                       rep_depth,
                       has_trivial_stab,
                       rank,
                       max_results,
                       hint,
                       count);
    MAP[next] = UNDEFINED;
    set_bit_array(MAP_UNDEFINED[depth], next, true);
  }
  END_FOR_SET_BITS
  pop_conditions(CONDITIONS, depth);
}

// Helper for the main recursive monomorphism of digraphs function.
static ALWAYS_INLINE uint16_t
                     digraph_mono_update_conditions(uint16_t const depth,
                                                    uint16_t const last_defined,
                                                    uint16_t const vertex) {
  push_conditions(CONDITIONS, depth, vertex, NULL);
  set_bit_array(get_conditions(CONDITIONS, vertex), MAP[last_defined], false);
  if (is_adjacent_digraph(DIGRAPH1, last_defined, vertex)) {
    intersect_bit_arrays(get_conditions(CONDITIONS, vertex),
                         DIGRAPH2->out_neighbours[MAP[last_defined]],
                         DIGRAPH2->nr_vertices);
  }
  if (is_adjacent_digraph(DIGRAPH1, vertex, last_defined)) {
    intersect_bit_arrays(get_conditions(CONDITIONS, vertex),
                         DIGRAPH2->in_neighbours[MAP[last_defined]],
                         DIGRAPH2->nr_vertices);
  }
  store_size_conditions(CONDITIONS, vertex);

  return size_conditions(CONDITIONS, vertex);
}

// The main recursive function for monomorphisms of digraphs.
//
// The arguments are:
//
// 1. depth             The current depth of the search (i.e. number of
//                      positions in MAP that are assigned).
// 2. pos               The last position in MAP that was filled
// 3. rep_depth         The depth of the stabilisers of points in MAP already.
//                      This is different than depth because we stop increasing
//                      the rep_depth when we first encounter a trivial
//                      stabiliser.
// 4. has_trivial_stab  true if the stabiliser of the values already in MAP is
//                      trivial, false otherwise.
// 5. max_results       The maximum number of results to find.
// 6. count             The number of embeddings found so far.
static void find_digraph_monos(uint16_t        depth,
                               uint16_t        pos,
                               uint16_t        rep_depth,
                               bool            has_trivial_stab,
                               uint64_t const  max_results,
                               uint64_t* const count) {
#ifdef DIGRAPHS_ENABLE_STATS
  update_stats(STATS, depth);
#endif
  if (depth == DIGRAPH1->nr_vertices) {
    // we've assigned every position in <MAP>
    external_order_map_digraph(DIGRAPH1);
    HOOK(USER_PARAM, MAX(DIGRAPH1->nr_vertices, DIGRAPH2->nr_vertices), MAP);
    internal_order_map_digraph(DIGRAPH1);
    (*count)++;
    if (*count >= max_results) {
      longjmp(OUTOFHERE, 1);
    }
    return;
  }

  uint16_t next = 0;          // the next position to fill
  uint16_t min  = UNDEFINED;  // the minimum number of candidates for MAP[next]
  uint16_t i;

  if (depth > 0) {  // this is not the first call of the function
    copy_bit_array(
        MAP_UNDEFINED[depth], MAP_UNDEFINED[depth - 1], DIGRAPH1->nr_vertices);
    FOR_SET_BITS(MAP_UNDEFINED[depth], DIGRAPH1->nr_vertices, i) {
      size_t const n = digraph_mono_update_conditions(depth, pos, i);
      if (n == 0) {
#ifdef DIGRAPHS_ENABLE_STATS
        STATS->nr_dead_branches++;
#endif
        pop_conditions(CONDITIONS, depth);
        return;
      }
      STORE_MIN(min, next, n, i);
    }
    END_FOR_SET_BITS
  } else {
    for (i = 0; i < DIGRAPH1->nr_vertices; i++) {
      size_t const n = size_conditions(CONDITIONS, i);
      STORE_MIN_BREAK(min, next, n, i);
    }
  }

  BitArray* possible = BIT_ARRAY_BUFFER[depth];
  copy_bit_array(
      possible, get_conditions(CONDITIONS, next), DIGRAPH2->nr_vertices);
  intersect_bit_arrays(possible, REPS[rep_depth], DIGRAPH2->nr_vertices);
  FOR_SET_BITS(possible, DIGRAPH2->nr_vertices, i) {
    MAP[next] = i;
    set_bit_array(VALS, i, true);
    set_bit_array(MAP_UNDEFINED[depth], next, false);
    if (!has_trivial_stab) {
      find_digraph_monos(depth + 1,
                         next,
                         rep_depth + 1,
                         compute_stabs_and_orbit_reps(DIGRAPH1->nr_vertices,
                                                      DIGRAPH2->nr_vertices,
                                                      rep_depth + 1,
                                                      depth,
                                                      i),
                         max_results,
                         count);
    } else {
      find_digraph_monos(depth + 1, next, rep_depth, true, max_results, count);
    }
    MAP[next] = UNDEFINED;
    set_bit_array(VALS, i, false);
    set_bit_array(MAP_UNDEFINED[depth], next, true);
  }
  END_FOR_SET_BITS
  pop_conditions(CONDITIONS, depth);
}

// Helper for the main recursive embedding digraphs function.
static ALWAYS_INLINE uint16_t
digraph_embed_update_conditions(uint16_t const depth,
                               uint16_t const last_defined,
                               uint16_t const vertex) {
  push_conditions(CONDITIONS, depth, vertex, NULL);
  if (is_adjacent_digraph(DIGRAPH1, last_defined, vertex)) {
    intersect_bit_arrays(get_conditions(CONDITIONS, vertex),
                         DIGRAPH2->out_neighbours[MAP[last_defined]],
                         DIGRAPH2->nr_vertices);
  } else {
    complement_bit_arrays(get_conditions(CONDITIONS, vertex),
                          DIGRAPH2->out_neighbours[MAP[last_defined]],
                          DIGRAPH2->nr_vertices);
  }
  if (is_adjacent_digraph(DIGRAPH1, vertex, last_defined)) {
    intersect_bit_arrays(get_conditions(CONDITIONS, vertex),
                         DIGRAPH2->in_neighbours[MAP[last_defined]],
                         DIGRAPH2->nr_vertices);
  } else {
    complement_bit_arrays(get_conditions(CONDITIONS, vertex),
                          DIGRAPH2->in_neighbours[MAP[last_defined]],
                          DIGRAPH2->nr_vertices);
  }
  store_size_conditions(CONDITIONS, vertex);
  return size_conditions(CONDITIONS, vertex);
}

// The main recursive function for embeddings of digraphs.
//
// The arguments are:
//
// 1. depth             The current depth of the search (i.e. number of
//                      positions in MAP that are assigned).
// 2. pos               The last position in MAP that was filled
// 3. rep_depth         The depth of the stabilisers of points in MAP already.
//                      This is different than depth because we stop increasing
//                      the rep_depth when we first encounter a trivial
//                      stabiliser.
// 4. has_trivial_stab  true if the stabiliser of the values already in MAP is
//                      trivial, false otherwise.
// 5. max_results       The maximum number of results to find.
// 6. count             The number of embeddings found so far.
static void find_digraph_embeddings(uint16_t        depth,
                                    uint16_t        pos,
                                    uint16_t        rep_depth,
                                    bool            has_trivial_stab,
                                    uint64_t const  max_results,
                                    uint64_t* const count) {
#ifdef DIGRAPHS_ENABLE_STATS
  update_stats(STATS, depth);
#endif
  if (depth == DIGRAPH1->nr_vertices) {
    // we've assigned every position in <MAP>
    external_order_map_digraph(DIGRAPH1);
    HOOK(USER_PARAM, MAX(DIGRAPH1->nr_vertices, DIGRAPH2->nr_vertices), MAP);
    internal_order_map_digraph(DIGRAPH1);
    (*count)++;
    if (*count >= max_results) {
      longjmp(OUTOFHERE, 1);
    }
    return;
  }

  uint16_t next = 0;          // the next position to fill
  uint16_t min  = UNDEFINED;  // the minimum number of candidates for MAP[next]
  uint16_t i;

  if (depth > 0) {  // this is not the first call of the function
    copy_bit_array(
        MAP_UNDEFINED[depth], MAP_UNDEFINED[depth - 1], DIGRAPH1->nr_vertices);
    FOR_SET_BITS(MAP_UNDEFINED[depth], DIGRAPH1->nr_vertices, i) {
      size_t const n = digraph_embed_update_conditions(depth, pos, i);
      if (n == 0) {
#ifdef DIGRAPHS_ENABLE_STATS
        STATS->nr_dead_branches++;
#endif
        pop_conditions(CONDITIONS, depth);
        return;
      }
      STORE_MIN(min, next, n, i);
    }
    END_FOR_SET_BITS
  } else {
    for (i = 0; i < DIGRAPH1->nr_vertices; i++) {
      size_t const n = size_conditions(CONDITIONS, i);
      STORE_MIN_BREAK(min, next, n, i);
    }
  }

  BitArray* possible = get_conditions(CONDITIONS, next);
  copy_bit_array(
      possible, get_conditions(CONDITIONS, next), DIGRAPH2->nr_vertices);
  intersect_bit_arrays(possible, REPS[rep_depth], DIGRAPH2->nr_vertices);

  FOR_SET_BITS(possible, DIGRAPH2->nr_vertices, i) {
    MAP[next] = i;
    set_bit_array(VALS, i, true);
    set_bit_array(MAP_UNDEFINED[depth], next, false);
    if (!has_trivial_stab) {
      find_digraph_embeddings(
          depth + 1,
          next,
          rep_depth + 1,
          compute_stabs_and_orbit_reps(DIGRAPH1->nr_vertices,
                                       DIGRAPH2->nr_vertices,
                                       rep_depth + 1,
                                       depth,
                                       i),
          max_results,
          count);
    } else {
      find_digraph_embeddings(
          depth + 1, next, rep_depth, true, max_results, count);
    }
    MAP[next] = UNDEFINED;
    set_bit_array(VALS, i, false);
    set_bit_array(MAP_UNDEFINED[depth], next, true);
  }
  END_FOR_SET_BITS
  pop_conditions(CONDITIONS, depth);
}

////////////////////////////////////////////////////////////////////////////////
// The next function should be called before find_digraph_homos.  This function
// simulates the first steps of the recursion using the information in
// partial_map_obj (if any) so that the values specified in partial_map_obj are
// installed in MAP first.
////////////////////////////////////////////////////////////////////////////////

static void init_partial_map_and_find_digraph_homos(Obj partial_map_obj,
                                                    uint64_t const  max_results,
                                                    uint64_t const  hint,
                                                    uint64_t* const count,
                                                    Obj injective_obj) {
  uint16_t depth                = 0;
  uint16_t rep_depth            = 0;
  uint16_t last_defined         = UNDEFINED;
  bool     last_stab_is_trivial = (STAB_GENS[0]->size == 0 ? true : false);
  uint16_t rank                 = 0;
  uint16_t next                 = UNDEFINED;

  if (partial_map_obj != Fail) {
    for (next = 0; next < LEN_LIST(partial_map_obj); ++next) {
      if (ISB_LIST(partial_map_obj, next + 1)) {
        if (depth > 0) {
          DIGRAPHS_ASSERT(last_defined != UNDEFINED);
          copy_bit_array(MAP_UNDEFINED[depth],
                         MAP_UNDEFINED[depth - 1],
                         DIGRAPH1->nr_vertices);
          uint16_t i;  // variable for the next for-loop
          FOR_SET_BITS(MAP_UNDEFINED[depth], DIGRAPH1->nr_vertices, i) {
            uint16_t n;
            if (INT_INTOBJ(injective_obj) == 0) {
              n = digraph_homo_update_conditions(depth, last_defined, i);
            } else if (INT_INTOBJ(injective_obj) == 1) {
              n = digraph_mono_update_conditions(depth, last_defined, i);
            } else {
              DIGRAPHS_ASSERT(INT_INTOBJ(injective_obj) == 2);
              n = digraph_embed_update_conditions(depth, last_defined, i);
            }
            if (n == 0) {
              return;
            }
          }
          END_FOR_SET_BITS
        }
        uint16_t val = INT_INTOBJ(ELM_LIST(partial_map_obj, next + 1)) - 1;
        next         = (ORDERED ? INVERSE_ORDER[next] : next);
        MAP[next]    = val;
        if (!get_bit_array(VALS, MAP[next])) {
          rank++;
          if (rank > hint) {
            return;
          }
        }
        set_bit_array(VALS, MAP[next], true);
        set_bit_array(MAP_UNDEFINED[depth], next, false);
        if (!last_stab_is_trivial) {
          last_stab_is_trivial =
              compute_stabs_and_orbit_reps(DIGRAPH1->nr_vertices,
                                           DIGRAPH2->nr_vertices,
                                           rep_depth + 1,
                                           depth,
                                           MAP[next]);
          rep_depth++;
        }
        depth++;
        last_defined = next;
        next         = (ORDERED ? ORDER[next] : next);
      }
    }
  }
  if (INT_INTOBJ(injective_obj) == 0) {
    find_digraph_homos(depth,
                       last_defined,
                       rep_depth,
                       last_stab_is_trivial,
                       rank,
                       max_results,
                       hint,
                       count);
  } else if (INT_INTOBJ(injective_obj) == 1) {
    find_digraph_monos(depth,
                       last_defined,
                       rep_depth,
                       last_stab_is_trivial,
                       max_results,
                       count);
  } else {
    DIGRAPHS_ASSERT(INT_INTOBJ(injective_obj) == 2);
    find_digraph_embeddings(depth,
                            last_defined,
                            rep_depth,
                            last_stab_is_trivial,
                            max_results,
                            count);
  }
  return;
}

////////////////////////////////////////////////////////////////////////////////
// 7. The GAP-level function (and helpers)
////////////////////////////////////////////////////////////////////////////////

// Initialises the data structures required by the recursive functions for
// finding homomorphisms. If true is returned everything was initialised ok, if
// false is returned, then the arguments already imply that there can be no
// homomorphisms.
static bool init_data_from_args(Obj digraph1_obj,
                                Obj digraph2_obj,
                                Obj hook_obj,
                                Obj user_param_obj,
                                Obj max_results_obj,
                                Obj hint_obj,
                                Obj injective_obj,
                                Obj image_obj,
                                Obj partial_map_obj,
                                Obj colors1_obj,
                                Obj colors2_obj,
                                Obj order_obj) {
  static bool is_initialized = false;  // did we call this method before?
  if (!is_initialized) {
    // srand(time(0));
    is_initialized = true;
#ifdef DIGRAPHS_ENABLE_STATS
    STATS = malloc(sizeof(HomoStats));
#endif

    DIGRAPH1 = new_digraph(MAXVERTS);
    DIGRAPH2 = new_digraph(MAXVERTS);

    GRAPH1 = new_graph(MAXVERTS);
    GRAPH2 = new_graph(MAXVERTS);

    IMAGE_RESTRICT = new_bit_array(MAXVERTS);
    ORB_LOOKUP     = new_bit_array(MAXVERTS);
    REPS           = malloc(MAXVERTS * sizeof(BitArray*));
    for (uint16_t i = 0; i < MAXVERTS; i++) {
      REPS[i]             = new_bit_array(MAXVERTS);
      BIT_ARRAY_BUFFER[i] = new_bit_array(MAXVERTS);
      MAP_UNDEFINED[i]    = new_bit_array(MAXVERTS);
      STAB_GENS[i]        = new_perm_coll(MAXVERTS, MAXVERTS);
    }
    VALS          = new_bit_array(MAXVERTS);
    CONDITIONS    = new_conditions(MAXVERTS, MAXVERTS);
    SCHREIER_SIMS = new_schreier_sims();
  }
#ifdef DIGRAPHS_ENABLE_STATS
  clear_stats(STATS);
#endif

  uint16_t nr1 = DigraphNrVertices(digraph1_obj);
  uint16_t nr2 = DigraphNrVertices(digraph2_obj);

  init_bit_array(MAP_UNDEFINED[0], true, nr1);
  init_bit_array(VALS, false, nr2);

  if (IS_LIST(order_obj)) {
    ORDERED = true;
    for (uint16_t i = 0; i < nr1; i++) {
      ORDER[i]                = INT_INTOBJ(ELM_LIST(order_obj, i + 1)) - 1;
      INVERSE_ORDER[ORDER[i]] = i;
    }
  } else {
    ORDERED = false;
  }

  bool is_undirected;
  if (CALL_1ARGS(IsSymmetricDigraph, digraph1_obj) == True
      && CALL_1ARGS(IsSymmetricDigraph, digraph2_obj) == True) {
    init_graph_from_digraph_obj(GRAPH1, digraph1_obj, ORDERED);
    init_graph_from_digraph_obj(GRAPH2, digraph2_obj, false);
    is_undirected = true;
  } else {
    init_digraph_from_digraph_obj(DIGRAPH1, digraph1_obj, ORDERED);
    init_digraph_from_digraph_obj(DIGRAPH2, digraph2_obj, false);
    is_undirected = false;
  }

  if (hook_obj != Fail) {
    GAP_FUNC = hook_obj;
    HOOK     = homo_hook_gap;
  } else {
    HOOK = homo_hook_collect;
  }
  USER_PARAM = user_param_obj;

  clear_conditions(CONDITIONS, nr1, nr2);

  // IMAGE_RESTRICT is a pointer to a BitArray of possible image values for the
  // homomorphisms, it is also used by orbit_reps so that orbit reps are chosen
  // from among the restricted values of the image . . .
  set_bit_array_from_gap_list(IMAGE_RESTRICT, image_obj);
  if (INT_INTOBJ(injective_obj) > 0
      && size_bit_array(IMAGE_RESTRICT, nr1) < nr1) {
    // homomorphisms should be injective (by injective_obj) but are not since
    // the image is too restricted.
    return false;
  }

  init_bit_array(BIT_ARRAY_BUFFER[0], false, nr2);
  if (partial_map_obj != Fail) {
    for (uint16_t i = 1; i <= LEN_LIST(partial_map_obj); i++) {
      if (ISB_LIST(partial_map_obj, i)) {
        Obj o = ELM_LIST(partial_map_obj, i);
        DIGRAPHS_ASSERT(IS_INTOBJ(o));
        DIGRAPHS_ASSERT(INT_INTOBJ(o) > 0);
        DIGRAPHS_ASSERT(INT_INTOBJ(o) <= nr2);
        if (INT_INTOBJ(injective_obj) > 0) {
          if (get_bit_array(BIT_ARRAY_BUFFER[0], INT_INTOBJ(o) - 1)) {
            // partial_map_obj should be injective, but is not
            return false;
          }
          set_bit_array(BIT_ARRAY_BUFFER[0], INT_INTOBJ(o) - 1, true);
        }
        // The only value that vertex `i` can have is `o`!
        if (ORDERED) {
          init_bit_array(
              get_conditions(CONDITIONS, INVERSE_ORDER[i - 1]), false, nr2);
          set_bit_array_from_gap_int(
              get_conditions(CONDITIONS, INVERSE_ORDER[i - 1]), o);
        } else {
          init_bit_array(get_conditions(CONDITIONS, i - 1), false, nr2);
          set_bit_array_from_gap_int(get_conditions(CONDITIONS, i - 1), o);
        }
      }
      // Intersect everything in the first row of the conditions with <image>,
      intersect_bit_arrays(
          get_conditions(CONDITIONS, i - 1), IMAGE_RESTRICT, nr2);
    }
  }

  init_bit_array(BIT_ARRAY_BUFFER[0], false, nr2);
  if (is_undirected) {
    for (uint16_t i = 0; i < nr2; i++) {
      if (is_adjacent_graph(GRAPH2, i, i)) {
        set_bit_array(BIT_ARRAY_BUFFER[0], i, true);
      }
    }
    // Loops in digraph1 can only MAP to loops in digraph2
    for (uint16_t i = 0; i < nr1; i++) {
      if (is_adjacent_graph(GRAPH1, i, i)) {
        intersect_bit_arrays(
            get_conditions(CONDITIONS, i), BIT_ARRAY_BUFFER[0], nr2);
      }
    }
  } else {
    for (uint16_t i = 0; i < nr2; i++) {
      if (is_adjacent_digraph(DIGRAPH2, i, i)) {
        set_bit_array(BIT_ARRAY_BUFFER[0], i, true);
      }
    }
    // Loops in digraph1 can only MAP to loops in digraph2
    for (uint16_t i = 0; i < nr1; i++) {
      if (is_adjacent_digraph(DIGRAPH1, i, i)) {
        intersect_bit_arrays(
            get_conditions(CONDITIONS, i), BIT_ARRAY_BUFFER[0], nr2);
      }
    }
  }

  // Process the vertex colours . . .
  uint16_t* colors;
  if (colors1_obj != Fail && colors2_obj != Fail) {
    DIGRAPHS_ASSERT(IS_LIST(colors1_obj));
    DIGRAPHS_ASSERT(IS_LIST(colors2_obj));
    DIGRAPHS_ASSERT(LEN_LIST(colors1_obj) == nr1);
    DIGRAPHS_ASSERT(LEN_LIST(colors2_obj) == nr2);

    for (uint16_t i = 1; i <= LEN_LIST(colors2_obj); i++) {
      DIGRAPHS_ASSERT(ISB_LIST(colors2_obj, i));
      DIGRAPHS_ASSERT(IS_INTOBJ(ELM_LIST(colors2_obj, i)));
      COLORS2[i - 1] = INT_INTOBJ(ELM_LIST(colors2_obj, i)) - 1;
    }
    for (uint16_t i = 1; i <= LEN_LIST(colors1_obj); i++) {
      init_bit_array(BIT_ARRAY_BUFFER[0], false, nr2);
      DIGRAPHS_ASSERT(ISB_LIST(colors1_obj, i));
      DIGRAPHS_ASSERT(IS_INTOBJ(ELM_LIST(colors1_obj, i)));
      for (uint16_t j = 1; j <= LEN_LIST(colors2_obj); j++) {
        if (INT_INTOBJ(ELM_LIST(colors1_obj, i))
            == INT_INTOBJ(ELM_LIST(colors2_obj, j))) {
          set_bit_array(BIT_ARRAY_BUFFER[0], j - 1, true);
        }
      }
      if (ORDERED) {
        intersect_bit_arrays(get_conditions(CONDITIONS, INVERSE_ORDER[i - 1]),
                             BIT_ARRAY_BUFFER[0],
                             nr2);
      } else {
        intersect_bit_arrays(
            get_conditions(CONDITIONS, i - 1), BIT_ARRAY_BUFFER[0], nr2);
      }
      // can only map vertices of color i to vertices of color i
    }
    colors = COLORS2;
  } else {
    colors = NULL;
  }

  // Ensure that the sizes of all conditions are known before we start and
  // define the MAP

  for (uint16_t i = 0; i < nr1; i++) {
    store_size_conditions(CONDITIONS, i);
    MAP[i] = UNDEFINED;
  }
  for (uint16_t i = nr1; i < MAX(nr1, nr2); i++) {
    MAP[i] = i;
  }

  // Get generators of the automorphism group of the second (di)graph, and the
  // orbit reps
  PERM_DEGREE = nr2;
  if (colors == NULL) {
    get_automorphism_group_from_gap(digraph2_obj, STAB_GENS[0]);
  } else if (is_undirected) {
    automorphisms_graph(GRAPH2, colors, STAB_GENS[0]);
  } else {
    automorphisms_digraph(DIGRAPH2, colors, STAB_GENS[0]);
  }
  compute_stabs_and_orbit_reps(nr1, nr2, 0, 0, UNDEFINED);
  return true;
}

// The next function is the main function for accessing the homomorphisms code.
//
// The arguments are:
//
// 1. digraph1_obj     the source/domain of the homomorphisms sought
// 2. digraph2_obj     the range/codomain of the homomorphisms sought
// 3. hook_obj         apply this function to every homomorphism found, or Fail
//                     for no function.
// 4. user_param_obj   GAP variable that can be used in the hook_obj, must be a
//                     plist if hook_obj is Fail.
// 5. max_results_obj  the maximum number of homomorphisms to find
// 6. hint_obj         the rank of any homomorphisms found
// 7. injective_obj    should be 0 for non-injective, 1 for injective, 2 for
//                     embedding, or (for backwards compatibility, true for
//                     injective, or false for non-injective).
// 8. image_obj        a list of vertices in digraph2_obj from which the images
//                     of any homomorphism will be taken.
// 9. partial_map_obj  a partial map from digraph1_obj to digraph2_obj, only
//                     homomorphisms extending this partial map are found (if
//                     any). Can also be fail to indicate no partial mapping is
//                     defined.
// 10. colors1_obj     a coloring of digraph1_obj
// 11. colors2_obj     a coloring of digraph2_obj, only homomorphisms that
//                     respect these colorings are found.
// 12. order_obj       an optional argument that can specify the order the
//                     vertices in digraph1_obj should be installed in the
//                     Graph or Digraph used in the recursive search. This does
//                     not directly specify which order vertices are visited in
//                     the search, but can have a large impact on the run time
//                     of the function. It seems in many cases to be a good
//                     idea for this to be the DigraphWelshPowellOrder, i.e.
//                     vertices ordered from highest to lowest degree.

Obj FuncHomomorphismDigraphsFinder(Obj self, Obj args) {
  if (LEN_PLIST(args) != 11 && LEN_PLIST(args) != 12) {
    ErrorQuit(
        "there must be 11 or 12 arguments, found %d", LEN_PLIST(args), 0L);
  }
  Obj digraph1_obj    = ELM_PLIST(args, 1);
  Obj digraph2_obj    = ELM_PLIST(args, 2);
  Obj hook_obj        = ELM_PLIST(args, 3);
  Obj user_param_obj  = ELM_PLIST(args, 4);
  Obj max_results_obj = ELM_PLIST(args, 5);
  Obj hint_obj        = ELM_PLIST(args, 6);
  Obj injective_obj   = ELM_PLIST(args, 7);
  Obj image_obj       = ELM_PLIST(args, 8);
  Obj partial_map_obj = ELM_PLIST(args, 9);
  Obj colors1_obj     = ELM_PLIST(args, 10);
  Obj colors2_obj     = ELM_PLIST(args, 11);
  Obj order_obj       = Fail;
  if (LEN_PLIST(args) == 12) {
    order_obj = ELM_PLIST(args, 12);
  }

  // Validate the arguments
  if (CALL_1ARGS(IsDigraph, digraph1_obj) != True) {
    ErrorQuit("the 1st argument (digraph1) must be a digraph, not %s",
              (Int) TNAM_OBJ(digraph1_obj),
              0L);
  } else if (DigraphNrVertices(digraph1_obj) > MAXVERTS) {
    ErrorQuit("the 1st argument (digraph1) must have at most 512 vertices, "
              "found %d",
              DigraphNrVertices(digraph1_obj),
              0L);
  }
  if (CALL_1ARGS(IsDigraph, digraph2_obj) != True) {
    ErrorQuit("the 2nd argument (digraph2) must be a digraph, not %s",
              (Int) TNAM_OBJ(digraph2_obj),
              0L);
  } else if (DigraphNrVertices(digraph2_obj) > MAXVERTS) {
    ErrorQuit("the 2nd argument (digraph2) must have at most 512 vertices, "
              "found %d",
              DigraphNrVertices(digraph2_obj),
              0L);
  }
  if (hook_obj == Fail) {
    if (!IS_LIST(user_param_obj) || !IS_MUTABLE_OBJ(user_param_obj)) {
      ErrorQuit("the 3rd argument (hook) is fail and so the 4th argument must "
                "be a mutable list, not %s",
                (Int) TNAM_OBJ(user_param_obj),
                0L);
    }
  } else if (!IS_FUNC(hook_obj) || NARG_FUNC(hook_obj) != 2) {
    ErrorQuit(
        "the 3rd argument (hook) must be a function with 2 arguments", 0L, 0L);
  }
  if (!IS_INTOBJ(max_results_obj) && max_results_obj != Infinity) {
    ErrorQuit("the 5th argument (max_results) must be an integer "
              "or infinity, not %s",
              (Int) TNAM_OBJ(max_results_obj),
              0L);
  }
  if (!IS_INTOBJ(hint_obj) && hint_obj != Fail) {
    ErrorQuit("the 6th argument (hint) must be an integer "
              "or fail, not %s",
              (Int) TNAM_OBJ(hint_obj),
              0L);
  } else if (IS_INTOBJ(hint_obj) && INT_INTOBJ(hint_obj) <= 0) {
    ErrorQuit("the 6th argument (hint) must be a positive integer, "
              "not %d",
              INT_INTOBJ(hint_obj),
              0L);
  }

  if (!IS_INTOBJ(injective_obj) && injective_obj != True
      && injective_obj != False) {
    ErrorQuit("the 7th argument (injective) must be an integer "
              "or true or false, not %s",
              (Int) TNAM_OBJ(injective_obj),
              0L);
  } else if (IS_INTOBJ(injective_obj)) {
    if (INT_INTOBJ(injective_obj) < 0 || INT_INTOBJ(injective_obj) > 2) {
      ErrorQuit("the 7th argument (injective) must 0, 1, or 2, not %d",
                INT_INTOBJ(injective_obj),
                0L);
    }
  } else if (injective_obj == True) {
    injective_obj = INTOBJ_INT(1);
  } else {
    injective_obj = INTOBJ_INT(0);
  }

  if (!IS_LIST(image_obj) && image_obj != Fail) {
    ErrorQuit("the 8th argument (image) must be a list or fail, not %s",
              (Int) TNAM_OBJ(image_obj),
              0L);
  } else if (IS_LIST(image_obj)) {
    for (Int i = 1; i <= LEN_LIST(image_obj); ++i) {
      if (!ISB_LIST(image_obj, i)) {
        ErrorQuit("the 8th argument (image) must be a dense list", 0L, 0L);
      } else if (!IS_POS_INT(ELM_LIST(image_obj, i))) {
        ErrorQuit("the 8th argument (image) must only contain positive "
                  "integers, but found %s in position %d",
                  (Int) TNAM_OBJ(ELM_LIST(image_obj, i)),
                  i);
      } else if (INT_INTOBJ(ELM_LIST(image_obj, i))
                 > DigraphNrVertices(digraph2_obj)) {
        ErrorQuit("in the 8th argument (image) position %d is out of range, "
                  "must be in the range [1, %d]",
                  i,
                  DigraphNrVertices(digraph2_obj));
      } else if (INT_INTOBJ(
                     POS_LIST(image_obj, ELM_LIST(image_obj, i), INTOBJ_INT(0)))
                 < i) {
        ErrorQuit(
            "in the 8th argument (image) position %d is a duplicate", i, 0L);
      }
    }
  }
  if (!IS_LIST(partial_map_obj) && partial_map_obj != Fail) {
    ErrorQuit("the 9th argument (partial_map) must be a list or fail, not %s",
              (Int) TNAM_OBJ(partial_map_obj),
              0L);
  } else if (IS_LIST(partial_map_obj)) {
    if (LEN_LIST(partial_map_obj) > DigraphNrVertices(digraph1_obj)) {
      ErrorQuit("the 9th argument (partial_map) is too long, must be at most "
                "%d, found %d",
                DigraphNrVertices(digraph1_obj),
                LEN_LIST(partial_map_obj));
    }
    for (Int i = 1; i <= LEN_LIST(partial_map_obj); ++i) {
      if (ISB_LIST(partial_map_obj, i)
          && POS_LIST(image_obj, ELM_LIST(partial_map_obj, i), INTOBJ_INT(0))
                 == Fail) {
        ErrorQuit("in the 9th argument (partial_map) the value %d in position "
                  "%d does not belong to the 7th argument (image)",
                  INT_INTOBJ(ELM_LIST(partial_map_obj, i)),
                  i);
      }
    }
  }

  Obj str;
  C_NEW_STRING(str, 26, "HomomorphismDigraphsFinder");
  if (!IS_LIST(colors1_obj) && colors1_obj != Fail) {
    ErrorQuit("the 10th argument (colors1) must be a list or fail, not %s",
              (Int) TNAM_OBJ(colors1_obj),
              0L);
  } else if (IS_LIST(colors1_obj)) {
    colors1_obj = CALL_3ARGS(DIGRAPHS_ValidateVertexColouring,
                             INTOBJ_INT(DigraphNrVertices(digraph1_obj)),
                             colors1_obj,
                             str);
  }
  if (!IS_LIST(colors2_obj) && colors2_obj != Fail) {
    ErrorQuit("the 11th argument (colors2) must be a list or fail, not %s",
              (Int) TNAM_OBJ(colors2_obj),
              0L);
  } else if (IS_LIST(colors2_obj)) {
    colors2_obj = CALL_3ARGS(DIGRAPHS_ValidateVertexColouring,
                             INTOBJ_INT(DigraphNrVertices(digraph2_obj)),
                             colors2_obj,
                             str);
  }
  if ((IS_LIST(colors1_obj) && !IS_LIST(colors2_obj))
      || (colors1_obj == Fail && colors2_obj != Fail)) {
    ErrorQuit("the 10th and 11th arguments must both be lists or both be fail",
              0L,
              0L);
  }
  if (!IS_LIST(order_obj) && order_obj != Fail) {
    ErrorQuit("the 12th argument (order) must be a list or fail, not %s",
              (Int) TNAM_OBJ(order_obj),
              0L);
  } else if (IS_LIST(order_obj)) {
    if (LEN_LIST(order_obj) != DigraphNrVertices(digraph1_obj)) {
      ErrorQuit("the 12th argument (order) must be a list of length %d, not %d",
                DigraphNrVertices(digraph1_obj),
                LEN_LIST(order_obj));
    }
    for (Int i = 1; i <= LEN_LIST(order_obj); ++i) {
      if (!ISB_LIST(order_obj, i)) {
        ErrorQuit("the 12th argument (order) must be a dense list, but "
                  "position %d is not bound",
                  i,
                  0L);
      } else if (!IS_INTOBJ(ELM_LIST(order_obj, i))) {
        ErrorQuit("the 12th argument (order) must consist of integers, but "
                  "found %s in position %d",
                  (Int) TNAM_OBJ(order_obj),
                  i);
      } else if (INT_INTOBJ(ELM_LIST(order_obj, i)) <= 0
                 || INT_INTOBJ(ELM_LIST(order_obj, i))
                        > DigraphNrVertices(digraph1_obj)) {
        ErrorQuit("the 12th argument (order) must consist of integers, in the "
                  "range [1, %d] but found %d",
                  DigraphNrVertices(digraph1_obj),
                  INT_INTOBJ(ELM_LIST(order_obj, i)));
      } else if (INT_INTOBJ(
                     POS_LIST(order_obj, ELM_LIST(order_obj, i), INTOBJ_INT(0)))
                 < i) {
        ErrorQuit("the 12th argument (order) must be duplicate-free, but "
                  "the value %d in position %d is a duplicate",
                  INT_INTOBJ(ELM_LIST(order_obj, i)),
                  i);
      }
    }
  }

  // Some conditions that immediately rule out there being any homomorphisms.
  if (((INT_INTOBJ(injective_obj) == 1 || INT_INTOBJ(injective_obj) == 2)
       && ((hint_obj != Fail
            && INT_INTOBJ(hint_obj) != DigraphNrVertices(digraph1_obj))
           || DigraphNrVertices(digraph1_obj)
                  > DigraphNrVertices(digraph2_obj)))
      || (hint_obj != Fail
          && (INT_INTOBJ(hint_obj) > DigraphNrVertices(digraph1_obj)
              || INT_INTOBJ(hint_obj) > DigraphNrVertices(digraph2_obj)))
      || LEN_LIST(image_obj) == 0
      || (hint_obj != Fail && INT_INTOBJ(hint_obj) > LEN_LIST(image_obj))) {
    // Can't print stats here because they are not initialised, also why would
    // we want to, nothing has actually happened yet!
    return user_param_obj;
  }

  // Initialise all of the global variables that are used in the recursion.
  // Returns false if the arguments somehow rule out there being any
  // homomorphisms (i.e. if injective_obj indicates that the homomorphisms
  // should be injective, and image_obj is too small).
  if (!init_data_from_args(digraph1_obj,
                           digraph2_obj,
                           hook_obj,
                           user_param_obj,
                           max_results_obj,
                           hint_obj,
                           injective_obj,
                           image_obj,
                           partial_map_obj,
                           colors1_obj,
                           colors2_obj,
                           order_obj)) {
#ifdef DIGRAPHS_ENABLE_STATS
    print_stats(STATS);
#endif
    return user_param_obj;
  }

  uint64_t max_results =
      (max_results_obj == Infinity ? SMALLINTLIMIT
                                   : INT_INTOBJ(max_results_obj));
  uint16_t hint  = (IS_INTOBJ(hint_obj) ? INT_INTOBJ(hint_obj) : UNDEFINED);
  uint64_t count = 0;

  // go!
  if (setjmp(OUTOFHERE) == 0) {
    if (CALL_1ARGS(IsSymmetricDigraph, digraph1_obj) == True
        && CALL_1ARGS(IsSymmetricDigraph, digraph2_obj) == True) {
      init_partial_map_and_find_graph_homos(
          partial_map_obj, max_results, hint, &count, injective_obj);
    } else {
      init_partial_map_and_find_digraph_homos(
          partial_map_obj, max_results, hint, &count, injective_obj);
    }
  }
#ifdef DIGRAPHS_ENABLE_STATS
  print_stats(STATS);
#endif
  return user_param_obj;
}
