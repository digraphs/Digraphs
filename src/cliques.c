////////////////////////////////////////////////////////////////////////////////
//
// cliques.c               cliques                           Julius Jonusas
//
// Copyright (C) 2020 - Julius Jonusas
//
// This file is free software, see the digraphs/LICENSE.

#include <cliques.h>

// C headers
#include <stdbool.h>  // for true, false, bool
#include <stddef.h>   // for NULL
#include <stdint.h>   // for uint16_t, uint64_t
#include <stdlib.h>   // for malloc, NULL

// GAP headers
#include "compiled.h"

// Digraphs package headers
#include "bitarray.h"        // for BitArray
#include "conditions.h"      // for Conditions
#include "digraphs-debug.h"  // for DIGRAPHS_ASSERT
#include "homos-graphs.h"    // for Digraph, Graph, . . .
#include "perms.h"           // for MAXVERTS, UNDEFINED, PermColl, Perm

////////////////////////////////////////////////////////////////////////////////
// Macros
////////////////////////////////////////////////////////////////////////////////

#define MIN(a, b) (a < b ? a : b)
#define EXIT 0

////////////////////////////////////////////////////////////////////////////////
// Forward declarations
////////////////////////////////////////////////////////////////////////////////

// Defined in digraphs.h
Int DigraphNrVertices(Obj);
Obj FuncOutNeighbours(Obj, Obj);
Obj FuncADJACENCY_MATRIX(Obj, Obj);

// GAP level things, imported in digraphs.c
extern Obj IsDigraph;
extern Obj Infinity;
extern Obj IsSymmetricDigraph;
extern Obj GeneratorsOfGroup;
extern Obj AutomorphismGroup;
extern Obj IsPermGroup;
extern Obj IsDigraphAutomorphism;
extern Obj LargestMovedPointPerms;
extern Obj SmallestMovedPointPerm;
extern Obj IsClique;
extern Obj IsTrivial;
extern Obj Orbit;
extern Obj Stabilizer;
extern Obj IsSubset;
extern Obj OnTuples;
extern Obj Group;
extern Obj ClosureGroup;

////////////////////////////////////////////////////////////////////////////////
// Global variables
////////////////////////////////////////////////////////////////////////////////

struct clique_data {
  void* user_param;    // A USER_PARAM for the hook
  Obj   gap_func;      // Variable to hold a GAP level hook function
  UInt (*hook)(void*,  // HOOK function applied to every homo found
               const BitArray*,
               const uint16_t,
               Obj);

  Graph*    graph;  // Graphs to hold incoming GAP symmetric digraphs
  BitArray* clique;

  Conditions* ban;
  Conditions* to_try;

  Conditions* try_;

  BitArray* temp_bitarray;
  Obj       orbit;
};

typedef struct clique_data CliqueData;

////////////////////////////////////////////////////////////////////////////////
// Hook functions
////////////////////////////////////////////////////////////////////////////////

static UInt clique_hook_collect(void*           user_param,
                                const BitArray* clique,
                                const uint16_t  nr,
                                Obj             gap_func) {
  UInt i;
  Obj  c;

  c = NEW_PLIST(T_PLIST, nr);
  for (i = 1; i <= nr; ++i) {
    if (get_bit_array(clique, i - 1)) {
      PushPlist(c, INTOBJ_INT(i));
    }
  }

  ASS_LIST(user_param, LEN_LIST(user_param) + 1, c);
  return 1;
}

static UInt
clique_hook_gap_list(void* user_param, Obj clique_list, Obj gap_func) {
  Obj n = CALL_2ARGS(gap_func, user_param, clique_list);
  if (!IS_INTOBJ(n)) {
    ErrorQuit("the 2rd argument <hook> must be a function which returns "
              "an integer,",
              0L,
              0L);
  }
  return INT_INTOBJ(n);
}

static UInt clique_hook_gap(void*           user_param,
                            const BitArray* clique,
                            const uint16_t  nr,
                            Obj             gap_func) {
  UInt i;
  Obj  c;

  c = NEW_PLIST(T_PLIST, nr);
  for (i = 1; i <= nr; ++i) {
    if (get_bit_array(clique, i - 1)) {
      PushPlist(c, INTOBJ_INT(i));
    }
  }
  return clique_hook_gap_list(user_param, c, gap_func);
}

////////////////////////////////////////////////////////////////////////////////
// Static helper functions
////////////////////////////////////////////////////////////////////////////////

// Update a BitArray to only include one vertex per orbit with respect to
// the group <group>
static void get_orbit_reps_bitarray(BitArray*   bit_array,
                                    Obj const   group,
                                    CliqueData* data) {
  if (group == Fail) {
    return;
  }

  uint16_t nr = data->graph->nr_vertices;
  for (uint16_t v = 0; v < nr; ++v) {
    if (get_bit_array(bit_array, v)) {
      // Find the orbit of pt and remove all other points of the orbit from
      // <bit_array>

      data->orbit = CALL_2ARGS(Orbit, group, INTOBJ_INT(v + 1));
      DIGRAPHS_ASSERT(IS_LIST(data->orbit));

      for (Int i = 1; i <= LEN_LIST(data->orbit); ++i) {
        set_bit_array(
            bit_array, INT_INTOBJ(ELM_LIST(data->orbit, i)) - 1, false);
      }
      set_bit_array(bit_array, v, true);
    }
  }
}

// Initialise the graph from GAP digraph and discard non-symmetric edges and
// loops
static void init_graph_from_digraph_obj(Graph* const graph, Obj digraph_obj) {
  DIGRAPHS_ASSERT(graph != NULL);
  DIGRAPHS_ASSERT(CALL_1ARGS(IsDigraph, digraph_obj) == True);
  UInt const nr      = DigraphNrVertices(digraph_obj);
  Obj        out     = FuncOutNeighbours(0L, digraph_obj);
  Obj        adj_mat = FuncADJACENCY_MATRIX(0L, digraph_obj);
  DIGRAPHS_ASSERT(nr < MAXVERTS);
  DIGRAPHS_ASSERT(IS_PLIST(adj_mat));
  DIGRAPHS_ASSERT(IS_PLIST(out));
  clear_graph(graph, nr);

  // Only include symmetric edges
  for (Int i = 1; i < nr; ++i) {
    Obj row = ELM_PLIST(adj_mat, i);
    DIGRAPHS_ASSERT(IS_LIST(row));
    Obj zero_obj = INTOBJ_INT(0);
    for (Int j = i + 1; j <= nr; ++j) {
      if (ELM_PLIST(row, j) != zero_obj
          && ELM_PLIST(ELM_PLIST(adj_mat, j), i) != zero_obj) {
        add_edge_graph(graph, i - 1, j - 1);
        add_edge_graph(graph, j - 1, i - 1);
      }
    }
  }
}

// Initialise the global variables
static bool init_data_from_args(Obj         digraph_obj,
                                Obj         hook_obj,
                                Obj         user_param_obj,
                                Obj         include_obj,
                                Obj         exclude_obj,
                                Obj         max_obj,
                                Obj*        group,
                                CliqueData* data) {
  static bool is_initialised = false;
  if (!is_initialised) {
    is_initialised = true;

    data->graph = new_graph(MAXVERTS);

    // Currently Conditions are a nr1 x nr1 array of BitArrays, so both
    // values have to be set to MAXVERTS
    data->clique = new_bit_array(MAXVERTS);
    data->try_   = new_conditions(MAXVERTS, MAXVERTS);
    data->ban    = new_conditions(MAXVERTS, MAXVERTS);
    data->to_try = new_conditions(MAXVERTS, MAXVERTS);

    data->orbit         = Fail;
    data->temp_bitarray = new_bit_array(MAXVERTS);
  }

  uint16_t nr = DigraphNrVertices(digraph_obj);
  init_graph_from_digraph_obj(data->graph, digraph_obj);

  clear_conditions(data->try_, nr + 1, nr);
  clear_conditions(data->ban, nr + 1, nr);
  clear_conditions(data->to_try, nr + 1, nr);
  init_bit_array(data->ban->bit_array[0], false, nr);

  init_bit_array(data->clique, false, nr);
  // Update CLIQUE and try_ using include_obj
  if (include_obj != Fail) {
    set_bit_array_from_gap_list(data->clique, include_obj);
    complement_bit_arrays(get_conditions(data->try_, 0), data->clique, nr);
    for (uint16_t i = 1; i <= LEN_LIST(include_obj); ++i) {
      intersect_bit_arrays(
          get_conditions(data->try_, 0),
          data->graph->neighbours[INT_INTOBJ(ELM_LIST(include_obj, i)) - 1],
          nr);
    }
  }
  // Update try_ using exclude_obj
  if (exclude_obj != Fail) {
    set_bit_array_from_gap_list(data->temp_bitarray, exclude_obj);
    complement_bit_arrays(
        get_conditions(data->try_, 0), data->temp_bitarray, nr);
  }

  // Get the isolated vertices of the graph
  // temp_bitarray now represents isolated vertices
  init_bit_array(data->temp_bitarray, false, nr);
  Int first_isolated = -1;
  for (uint16_t i = 0; i < nr; ++i) {
    if (size_bit_array(data->graph->neighbours[i], nr) == 0) {
      if (first_isolated == -1
          && get_bit_array(get_conditions(data->try_, 0), i)) {
        first_isolated = i;
      }
      set_bit_array(data->temp_bitarray, i, true);
    }
  }
  // Update try_ using isolated, only one isolated vertex is used
  if (first_isolated != -1) {
    complement_bit_arrays(
        get_conditions(data->try_, 0), data->temp_bitarray, nr);
    set_bit_array(get_conditions(data->try_, 0), first_isolated, true);
  }

  // Discard the generators of aut_grp_obj which act on the isolated vertices
  if (size_bit_array(data->temp_bitarray, nr) > 0) {
    Obj new_group = Fail;
    Obj gens      = CALL_1ARGS(GeneratorsOfGroup, *group);
    DIGRAPHS_ASSERT(IS_LIST(gens));
    for (Int i = 1; i <= LEN_LIST(gens); ++i) {
      Obj s = CALL_1ARGS(SmallestMovedPointPerm, ELM_LIST(gens, i));
      if (s != Infinity
          && !get_bit_array(data->temp_bitarray, INT_INTOBJ(s) - 1)) {
        if (new_group == Fail) {
          new_group = CALL_1ARGS(Group, ELM_LIST(gens, i));
        } else {
          new_group = CALL_2ARGS(ClosureGroup, new_group, ELM_LIST(gens, i));
        }
      }
    }
    *group = new_group;
  }

  if (hook_obj != Fail) {
    data->gap_func = hook_obj;
    data->hook     = clique_hook_gap;
  } else {
    data->gap_func = Fail;
    data->hook     = clique_hook_collect;
  }
  data->user_param = user_param_obj;

  return true;
}

////////////////////////////////////////////////////////////////////////////////
// Main functions
////////////////////////////////////////////////////////////////////////////////

static int BronKerbosch(uint16_t    depth,
                        uint16_t    rep_depth,
                        uint64_t    limit,
                        uint64_t*   nr_found,
                        bool        max,
                        uint16_t    size,
                        Obj         group,
                        CliqueData* data) {
  uint16_t  nr   = data->graph->nr_vertices;
  BitArray* try_ = get_conditions(data->try_, 0);
  BitArray* ban  = get_conditions(data->ban, 0);

  if (depth > 0 && !max && (size == 0 || size == depth)) {
    // We are not looking for maximal cliques
    *nr_found += data->hook(data->user_param, data->clique, nr, data->gap_func);
    if (*nr_found >= limit) {
      return EXIT;
    }
  } else if (size_bit_array(try_, nr) == 0 && size_bit_array(ban, nr) == 0
             && (size == 0 || size == depth)) {
    // <CLIQUE> is a maximal clique
    *nr_found += data->hook(data->user_param, data->clique, nr, data->gap_func);
    if (*nr_found >= limit) {
      return EXIT;
    }
  }

  BitArray* to_try = get_conditions(data->to_try, 0);
  if (max) {
    // Choose a pivot with as many neighbours in <try_> as possible
    uint16_t pivot          = 0;
    int16_t  max_neighbours = -1;

    for (uint16_t i = 0; i < nr; ++i) {
      if (get_bit_array(try_, i) || get_bit_array(ban, i)) {
        copy_bit_array(data->temp_bitarray, try_, nr);
        intersect_bit_arrays(
            data->temp_bitarray, data->graph->neighbours[i], nr);
        uint16_t num_neighbours = size_bit_array(data->temp_bitarray, nr);
        if (num_neighbours > max_neighbours) {
          pivot          = i;
          max_neighbours = num_neighbours;
        }
      }
    }

    // try_ adding vertices from <try_> minus neighbours of <pivot>
    init_bit_array(to_try, true, nr);
    complement_bit_arrays(to_try, data->graph->neighbours[pivot], nr);
    intersect_bit_arrays(to_try, try_, nr);
  } else {
    // If we are not looking for maximal cliques, a pivot cannot be used
    copy_bit_array(to_try, try_, nr);
  }
  // Update the height of the condition data->to_try, since we didn't use
  // push_condition
  data->to_try->height[0]++;

  // Get orbit representatives of <to_try>
  get_orbit_reps_bitarray(to_try, group, data);

  for (uint16_t v = 0; v < nr; ++v) {
    if (get_bit_array(to_try, v)) {
      set_bit_array(data->clique, v, true);

      push_conditions(data->try_, depth + 1, 0, data->graph->neighbours[v]);
      push_conditions(data->ban, depth + 1, 0, data->graph->neighbours[v]);

      // recurse
      if (group == Fail) {
        if (EXIT
            == BronKerbosch(depth + 1,
                            rep_depth,
                            limit,
                            nr_found,
                            max,
                            size,
                            group,
                            data)) {
          return EXIT;
        }
      } else {
        Obj stabiliser = CALL_2ARGS(Stabilizer, group, INTOBJ_INT(v + 1));
        if (CALL_1ARGS(IsTrivial, stabiliser) == True) {
          stabiliser = Fail;
        }
        if (EXIT
            == BronKerbosch(depth + 1,
                            rep_depth + 1,
                            limit,
                            nr_found,
                            max,
                            size,
                            stabiliser,
                            data)) {
          return EXIT;
        }
      }

      pop_conditions(data->try_, depth + 1);
      pop_conditions(data->ban, depth + 1);
      data->to_try->height[0]--;
      set_bit_array(data->clique, v, false);

      if (group == Fail) {
        set_bit_array(get_conditions(data->try_, 0), v, false);
        set_bit_array(get_conditions(data->ban, 0), v, true);
      } else {
        data->orbit = CALL_2ARGS(Orbit, group, INTOBJ_INT(v + 1));
        set_bit_array_from_gap_list(data->temp_bitarray, data->orbit);
        complement_bit_arrays(
            get_conditions(data->try_, 0), data->temp_bitarray, nr);
        union_bit_arrays(get_conditions(data->ban, 0), data->temp_bitarray, nr);
      }
    }
  }
  return EXIT + 1;
}

// FuncDigraphsCliquesFinder is the main function to use the C implementation
// of Bron-Kerbosch algorithm
//
// The arguments are as follows:
//
// 1. digraphs_obj    the digraph to search for cliques in
// 2. hook_obj        a funtion to apply to every clique found, or Fail if no
//                    such function is needed
// 3. user_param_obj  GAP variable that can be used in the hook_obj, must be a
//                    plist if hook_obj is Fail
// 4. limit_obj       the maximum number of cliques to find
// 5. include_obj     a list of vertices of digraph_obj to required to be
// present in
//                    every clique found. The list needs to be invariant under
//                    aut_grp_obj or the full automorphism group if aut_grp_obj
//                    is Fail
// 6. exclude_obj     a list of vertices of digraph_obj which cannot be present
//                    in any of the cliques found. The list needs to be
//                    invariant under aut_grp_obj or the full automorphism
//                    group if aut_grp_obj is Fail
// 7. max_obj         True if only maximal cliques need to be found and False
//                    otherwise
// 8. size_obj        an integer specifying the size of cliques to be found
// 9. aut_grp_obj     an optional argument that can specifiy the automorphisms
//                    of the graph that will be used in the recursive search.
//                    If not given, the full automorphism group will be used.
//
// Remarks:
// 1. The function returns orbit representatives of cliques rather than all of
// the
//    cliques themselves.
// 2. Only one isolated vertex will be returned even if aut_grp_obj does not
//    act transitevely on all isolated vertices.

Obj FuncDigraphsCliquesFinder(Obj self, Obj args) {
  if (LEN_PLIST(args) != 8 && LEN_PLIST(args) != 9) {
    ErrorQuit("there must be 8 or 9 arguments, found %d,", LEN_PLIST(args), 0L);
  }
  Obj digraph_obj    = ELM_PLIST(args, 1);
  Obj hook_obj       = ELM_PLIST(args, 2);
  Obj user_param_obj = ELM_PLIST(args, 3);
  Obj limit_obj      = ELM_PLIST(args, 4);
  Obj include_obj    = ELM_PLIST(args, 5);
  Obj exclude_obj    = ELM_PLIST(args, 6);
  Obj max_obj        = ELM_PLIST(args, 7);
  Obj size_obj       = ELM_PLIST(args, 8);
  Obj aut_grp_obj    = Fail;
  if (LEN_PLIST(args) == 9) {
    aut_grp_obj = ELM_PLIST(args, 9);
  }

  // Validate the arguments
  if (CALL_1ARGS(IsDigraph, digraph_obj) != True) {
    ErrorQuit("the 1st argument <digraph> must be a digraph, not %s,",
              (Int) TNAM_OBJ(digraph_obj),
              0L);
  } else if (DigraphNrVertices(digraph_obj) > MAXVERTS) {
    ErrorQuit("the 1st argument <digraph> must have at most %d vertices, "
              "found %d,",
              MAXVERTS,
              DigraphNrVertices(digraph_obj));
  }
  if (hook_obj == Fail) {
    if (!IS_LIST(user_param_obj) || !IS_MUTABLE_OBJ(user_param_obj)) {
      ErrorQuit("the 2rd argument <hook> is fail and so the 3th argument must "
                "be a mutable list, not %s,",
                (Int) TNAM_OBJ(user_param_obj),
                0L);
    }
  } else if (!IS_FUNC(hook_obj) || NARG_FUNC(hook_obj) != 2) {
    ErrorQuit(
        "the 2rd argument <hook> must be a function with 2 arguments,", 0L, 0L);
  }
  if (!IS_INTOBJ(limit_obj) && limit_obj != Infinity) {
    ErrorQuit("the 4th argument <limit> must be an integer "
              "or infinity, not %s,",
              (Int) TNAM_OBJ(limit_obj),
              0L);
  } else if (IS_INTOBJ(limit_obj) && INT_INTOBJ(limit_obj) <= 0) {
    ErrorQuit("the 4th argument <limit> must be a positive integer, "
              "not %d,",
              INT_INTOBJ(limit_obj),
              0L);
  }
  if (!IS_LIST(include_obj) && include_obj != Fail) {
    ErrorQuit("the 5th argument <include> must be a list or fail, not %s,",
              (Int) TNAM_OBJ(include_obj),
              0L);
  } else if (IS_LIST(include_obj)) {
    for (Int i = 1; i <= LEN_LIST(include_obj); ++i) {
      if (!ISB_LIST(include_obj, i)) {
        ErrorQuit("the 5th argument <include> must be a dense list,", 0L, 0L);
      } else if (!IS_POS_INTOBJ(ELM_LIST(include_obj, i))) {
        ErrorQuit("the 5th argument <include> must only contain positive "
                  "small integers, but found %s in position %d,",
                  (Int) TNAM_OBJ(ELM_LIST(include_obj, i)),
                  i);
      } else if (INT_INTOBJ(ELM_LIST(include_obj, i))
                 > DigraphNrVertices(digraph_obj)) {
        ErrorQuit("in the 5th argument <include> position %d is out of range, "
                  "must be in the range [1, %d],",
                  i,
                  DigraphNrVertices(digraph_obj));
      } else if (INT_INTOBJ(POS_LIST(
                     include_obj, ELM_LIST(include_obj, i), INTOBJ_INT(0)))
                 < i) {
        ErrorQuit(
            "in the 5th argument <include> position %d is a duplicate,", i, 0L);
      }
    }
  }
  if (!IS_LIST(exclude_obj) && exclude_obj != Fail) {
    ErrorQuit("the 6th argument <exclude> must be a list or fail, not %s,",
              (Int) TNAM_OBJ(exclude_obj),
              0L);
  } else if (IS_LIST(exclude_obj)) {
    for (Int i = 1; i <= LEN_LIST(exclude_obj); ++i) {
      if (!ISB_LIST(exclude_obj, i)) {
        ErrorQuit("the 6th argument <exclude> must be a dense list,", 0L, 0L);
      } else if (!IS_POS_INTOBJ(ELM_LIST(exclude_obj, i))) {
        ErrorQuit("the 6th argument <exclude> must only contain positive "
                  "small integers, but found %s in position %d,",
                  (Int) TNAM_OBJ(ELM_LIST(exclude_obj, i)),
                  i);
      } else if (INT_INTOBJ(ELM_LIST(exclude_obj, i))
                 > DigraphNrVertices(digraph_obj)) {
        ErrorQuit("in the 6th argument <exclude> position %d is out of range, "
                  "must be in the range [1, %d],",
                  i,
                  DigraphNrVertices(digraph_obj));
      } else if (INT_INTOBJ(POS_LIST(
                     exclude_obj, ELM_LIST(exclude_obj, i), INTOBJ_INT(0)))
                 < i) {
        ErrorQuit(
            "in the 6th argument <exclude> position %d is a duplicate,", i, 0L);
      }
    }
  }
  if (max_obj != True && max_obj != False) {
    ErrorQuit("the 7th argument <max> must true or false, not %s,",
              (Int) TNAM_OBJ(max_obj),
              0L);
  }
  if (!IS_POS_INTOBJ(size_obj) && size_obj != Fail) {
    ErrorQuit("the 8th argument <size> must be a positive small integer "
              "or fail, not %s,",
              (Int) TNAM_OBJ(size_obj),
              0L);
  }

  if (aut_grp_obj != Fail) {
    if (CALL_1ARGS(IsPermGroup, aut_grp_obj) != True) {
      ErrorQuit("the 9th argument <aut_grp> must be a permutation group "
                "or fail, not %s,",
                (Int) TNAM_OBJ(aut_grp_obj),
                0L);
    }
    Obj  gens = CALL_1ARGS(GeneratorsOfGroup, aut_grp_obj);
    UInt lmp  = INT_INTOBJ(CALL_1ARGS(LargestMovedPointPerms, gens));
    if (lmp > 0 && LEN_LIST(gens) >= lmp) {
      ErrorQuit("expected at most %d generators in the 9th argument "
                "but got %d,",
                lmp - 1,
                LEN_LIST(gens));
    }
    for (UInt i = 1; i <= LEN_LIST(gens); ++i) {
      if (CALL_2ARGS(IsDigraphAutomorphism, digraph_obj, ELM_LIST(gens, i))
          != True) {
        ErrorQuit("expected group of automorphisms, but found a "
                  "non-automorphism in position %d of the group generators,",
                  i,
                  0L);
      }
    }
  } else {
    aut_grp_obj = CALL_1ARGS(AutomorphismGroup, digraph_obj);
  }

  // Check that include_obj and exclude_obj are invariant under aut_grp_obj
  Obj gens = CALL_1ARGS(GeneratorsOfGroup, aut_grp_obj);
  DIGRAPHS_ASSERT(IS_LIST(gens));
  DIGRAPHS_ASSERT(LEN_LIST(gens) > 0);
  for (UInt i = 1; i <= LEN_LIST(gens); ++i) {
    if (include_obj != Fail
        && CALL_2ARGS(IsSubset,
                      include_obj,
                      CALL_2ARGS(OnTuples, include_obj, ELM_LIST(gens, i)))
               != True) {
      ErrorQuit("the 5th argument <include> must be invaraint under <aut_grp>, "
                "or the full automorphism if <aut_grp> is not given,",
                0L,
                0L);
    }
    if (exclude_obj != Fail
        && CALL_2ARGS(IsSubset,
                      exclude_obj,
                      CALL_2ARGS(OnTuples, exclude_obj, ELM_LIST(gens, i)))
               != True) {
      ErrorQuit("the 6th argument <exclude> must be invaraint under <aut_grp>, "
                "or the full automorphism if <aut_grp> is not given,",
                0L,
                0L);
    }
  }

  uint16_t size         = (size_obj == Fail ? 0 : INT_INTOBJ(size_obj));
  uint16_t include_size = (include_obj == Fail ? 0 : LEN_LIST(include_obj));
  uint16_t exclude_size = (exclude_obj == Fail ? 0 : LEN_LIST(exclude_obj));
  uint16_t nr           = DigraphNrVertices(digraph_obj);

  // Check the trivial cases:
  // The digraph has 0 vertices
  if (nr == 0) {
    Obj c = NEW_PLIST(T_PLIST, 0);
    if (hook_obj != Fail) {
      clique_hook_gap_list(user_param_obj, c, hook_obj);
    } else {
      ASS_LIST(user_param_obj, LEN_LIST(user_param_obj) + 1, c);
    }
    return user_param_obj;
  }
  // The desired clique is too small
  if (size != 0 && include_size > size) {
    return user_param_obj;
  }
  // The desired clique is too big
  if (size != 0 && size > nr - exclude_size) {
    return user_param_obj;
  }
  // Check if include and exclude have empty intersection
  if (include_size != 0 && exclude_size != 0) {
    bool lookup[MAXVERTS] = {false};
    for (UInt i = 1; i <= include_size; ++i) {
      lookup[INT_INTOBJ(ELM_LIST(include_obj, i)) - 1] = true;
    }
    for (UInt i = 1; i <= exclude_size; ++i) {
      if (lookup[INT_INTOBJ(ELM_LIST(exclude_obj, i)) - 1]) {
        return user_param_obj;
      }
    }
  }
  // Check if the set we are trying to extend is a clique
  if (include_obj != Fail
      && CALL_2ARGS(IsClique, digraph_obj, include_obj) == False) {
    return user_param_obj;
  }
  uint64_t nr_found = 0;
  uint64_t limit =
      (limit_obj == Infinity ? SMALLINTLIMIT : INT_INTOBJ(limit_obj));
  bool max = (max_obj == True ? true : false);

  static CliqueData data = {};
  // Initialise all the variable which will be used to carry out the recursion
  if (!init_data_from_args(digraph_obj,
                           hook_obj,
                           user_param_obj,
                           include_obj,
                           exclude_obj,
                           max_obj,
                           &aut_grp_obj,
                           &data)) {
    return user_param_obj;
  }
  // The clique we are trying to extend is already big enough
  if (size != 0 && include_size == size) {
    data.hook(data.user_param, data.clique, nr, data.gap_func);
    return user_param_obj;
  }

  // go!
  BronKerbosch(0,
               0,
               limit,
               &nr_found,
               max,
               (size == 0 ? size : size - include_size),
               aut_grp_obj,
               &data);

  return user_param_obj;
}
