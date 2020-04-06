////////////////////////////////////////////////////////////////////////////////
//
// cliques.c               di/cliques                        Julius Jonusas
//
// Copyright (C) 2020 - Julius Jonusas 
//
// This file is free software, see the digraphs/LICENSE.


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
#include "cliques.h"

////////////////////////////////////////////////////////////////////////////////
// Forward declarations
////////////////////////////////////////////////////////////////////////////////

// Defined in digraphs.h
Int DigraphNrVertices(Obj);
Obj FuncOutNeighbours(Obj, Obj);
Obj FuncADJACENCY_MATRIX(Obj, Obj);

// Defined in homos.c
void set_automorphisms(Obj, PermColl*);
void get_automorphism_group_from_gap(Obj, PermColl*);

// GAP level things, imported in digraphs.c
extern Obj IsDigraph;
extern Obj DIGRAPHS_ValidateVertexColouring;
extern Obj Infinity;
extern Obj IsSymmetricDigraph;
extern Obj GeneratorsOfGroup;
extern Obj AutomorphismGroup;
extern Obj IsPermGroup;
extern Obj IsDigraphAutomorphism;
extern Obj LargestMovedPointPerms;
extern Obj IsClique;

////////////////////////////////////////////////////////////////////////////////
// Global variables
////////////////////////////////////////////////////////////////////////////////

static Obj GAP_FUNC;  // Variable to hold a GAP level hook function

static Obj (*HOOK)(void*,  // HOOK function applied to every homo found
                   const BitArray*,
                   const uint16_t);
static void* USER_PARAM;  // a USER_PARAM for the hook

// Values in MAP are restricted to those positions in IMAGE_RESTRICT
static jmp_buf OUTOFHERE;  // so we can jump out of the deepest

static Graph* GRAPH;  // Graphs to hold incoming GAP symmetric digraphs

static BitArray*  CLIQUE;
static Conditions*  TRY;
static Conditions*  BAN;

static uint16_t ORB[MAXVERTS];    // Array for containing nodes in an orbit.
static BitArray* ORB_LOOKUP;                  // points in orbit
static PermColl* STAB_GENS[MAXVERTS];  // stabiliser generators
static SchreierSims* SCHREIER_SIMS;

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

// Update a BitArray to only include one vertex per orbit of a group generated
// by STAB_GENS[rep_depth]
static void get_orbit_reps_bitarray(BitArray* bit_array, uint16_t const rep_depth) {
  if (STAB_GENS[rep_depth]->size == 0) {
    return;
  }

  uint16_t nr = GRAPH->nr_vertices;
  uint16_t pt = 0;
  init_bit_array(ORB_LOOKUP, false, nr);
  while (pt < nr) {
    if (get_bit_array(bit_array, pt)) {
      // Find the orbit of pt and remove all other points of the orbit from bit_array
      
      set_bit_array(ORB_LOOKUP, pt, true);
      ORB[0] = pt;
      uint16_t n = 1; // lenght of the orbit of pt

      for (uint16_t i = 0; i < n; ++i) {
        for (uint16_t j = 0; j < STAB_GENS[rep_depth]->size; ++j) {
          Perm gen = STAB_GENS[rep_depth]->perms[j];
          uint16_t const img = gen[ORB[i]];
          if (!get_bit_array(ORB_LOOKUP, img)) {
            ORB[n++] = img;
            set_bit_array(ORB_LOOKUP, img, true);
            set_bit_array(bit_array, img, false);
          }
        }
      }
    }
    pt++;
  }
}


static void BronKerbosch(uint16_t  depth, 
                         uint16_t  rep_depth,
                         uint16_t  limit,
                         uint16_t* nr_found,
                         bool      max,
                         uint16_t  size) {

  uint16_t nr = GRAPH->nr_vertices;
  BitArray* try = get_conditions(TRY, 0);
  BitArray* ban = get_conditions(BAN, 0);

  if (depth > 0 && !max && ( size == 0 || size == depth)) {
    // We are not looking for maximal cliques
    HOOK(USER_PARAM, CLIQUE, nr);
    *nr_found += 1;
    if (*nr_found >= limit) {
      longjmp(OUTOFHERE, 1);
    }
  } else if (size_bit_array(try, nr) == 0 && size_bit_array(ban, nr) == 0) {
    // <CLIQUE> is a maximal clique
    if (size == 0 || size == depth) {
      HOOK(USER_PARAM, CLIQUE, nr);
      *nr_found += 1;
      if (*nr_found >= limit) {
        longjmp(OUTOFHERE, 1);
      }
    } 
    return;
  } 

  BitArray* to_try = new_bit_array(MAXVERTS);
  if (max) {
    // Choose a pivot with as many neighbours in <try> as possible 
    uint16_t pivot = 0;
    int max_neighbours = -1; 
    for (uint16_t i = 0; i < nr; i++){
      if (get_bit_array(try, i) || get_bit_array(ban, i)){
        BitArray* copy_try = new_bit_array(MAXVERTS); // reuse it!
        copy_bit_array(copy_try, try, nr);
        intersect_bit_arrays(copy_try, GRAPH->neighbours[i], nr);
        uint16_t num_neighbours = size_bit_array(copy_try, nr);
        if (num_neighbours > max_neighbours) {
          pivot = i;
          max_neighbours = num_neighbours;
        }
      }
    }

    // Try adding vertices from <try> minus neighbours of <pivot> 
    init_bit_array(to_try, 1, nr);
    complement_bit_arrays(to_try, GRAPH->neighbours[pivot], nr);
    intersect_bit_arrays(to_try, try, nr); 
  } else {
    // If we are not looking for maximal cliques, a pivot cannot be used
    copy_bit_array(to_try, try, nr); 
  }

  // Get orbit representatives of <to_try>
  get_orbit_reps_bitarray(to_try, rep_depth);

  for (uint16_t pt = 0; pt < nr; pt++) {
    if (get_bit_array(to_try, pt)){
      set_bit_array(CLIQUE, pt, true);

      push_conditions(TRY, depth + 1, 0, GRAPH->neighbours[pt]);
      push_conditions(BAN, depth + 1, 0, GRAPH->neighbours[pt]);

      // recurse
      if (STAB_GENS[rep_depth]->size == 0) {
        BronKerbosch(depth + 1, rep_depth, limit, nr_found, max, size);
      } else {
        // the point_stabilizer is very SLOW!
        point_stabilizer(SCHREIER_SIMS, STAB_GENS[rep_depth],
            STAB_GENS[rep_depth + 1], pt);
        BronKerbosch(depth + 1, rep_depth + 1, limit, nr_found, max, size);
      }

      pop_conditions(TRY, depth + 1);
      pop_conditions(BAN, depth + 1);
      set_bit_array(CLIQUE, pt, false);

      if (STAB_GENS[rep_depth]->size == 0) {
        set_bit_array(get_conditions(TRY, 0), pt, false);
        set_bit_array(get_conditions(BAN, 0), pt, true);
      } else {
        init_bit_array(ORB_LOOKUP, false, nr);
        set_bit_array(ORB_LOOKUP, pt, true);
        ORB[0] = pt;
        uint16_t n = 1; // lenght of the orbit of pt

        for (uint16_t i = 0; i < n; ++i) {
          for (uint16_t j = 0; j < STAB_GENS[rep_depth]->size; ++j) {
            Perm gen = STAB_GENS[rep_depth]->perms[j];
            uint16_t const img = gen[ORB[i]];
            if (!get_bit_array(ORB_LOOKUP, img)) {
              ORB[n++] = img;
              set_bit_array(ORB_LOOKUP, img, true);
            }
          }
        }
        complement_bit_arrays(get_conditions(TRY,0), ORB_LOOKUP, nr);
        union_bit_arrays(get_conditions(BAN,0), ORB_LOOKUP, nr);
      }
    }
 
  }
}


static Obj clique_hook_collect(void* user_param, const BitArray* clique, const uint16_t nr) {
  UInt   i;
  Obj    c;

  if (TNUM_OBJ((Obj) user_param) == T_PLIST_EMPTY) {
    RetypeBag(user_param, T_PLIST);
  }

  c = NEW_PLIST(T_PLIST, nr); 
  for(i = 1; i <= nr; i++) {
    if (get_bit_array(clique, i - 1)){ 
      PushPlist(c, ObjInt_UInt(i));
    }
  }

  ASS_LIST(user_param, LEN_LIST(user_param) + 1, c);
  return False;
}

static Obj clique_hook_gap(void* user_param, const BitArray* clique, const uint16_t nr) {
  UInt   i;
  Obj    c;
  
  c = NEW_PLIST(T_PLIST, nr); 
  for(i = 1; i <= nr; i++) {
    if (get_bit_array(clique, i-1)) {
      PushPlist(c, ObjInt_UInt(i + 1));
    }
  }

  return CALL_2ARGS(GAP_FUNC, user_param, c);
}

static void init_clique_graph_from_digraph_obj(Graph* const graph,
                                        Obj          digraph_obj) {
  DIGRAPHS_ASSERT(graph != NULL);
  DIGRAPHS_ASSERT(CALL_1ARGS(IsDigraph, digraph_obj) == True);
  UInt const nr  = DigraphNrVertices(digraph_obj);
  Obj        out = FuncOutNeighbours(0L, digraph_obj);
  Obj    adj_mat = FuncADJACENCY_MATRIX(0L, digraph_obj);
  DIGRAPHS_ASSERT(nr < MAXVERTS);
  DIGRAPHS_ASSERT(IS_PLIST(out));
  clear_graph(graph, nr);

  // Only include symmetric edges
  for (uint16_t i = 1; i <= nr; i++) {
    Obj row = ELM_PLIST(adj_mat, i);
    DIGRAPHS_ASSERT(IS_LIST(row));
    for (uint16_t j = 1; j <= nr; j++) {
      if (ELM_PLIST(row, j) != INTOBJ_INT(0) && ELM_PLIST(ELM_PLIST(adj_mat,j) ,i) != INTOBJ_INT(0)){
        add_edge_graph(graph, i - 1, j - 1);
      }
    }
  }
}

static bool init_clique_data_from_args(Obj digraph_obj, 
                                       Obj hook_obj, 
                                       Obj user_param_obj, 
                                       Obj include_obj, 
                                       Obj exclude_obj, 
                                       Obj max_obj, 
                                       Obj aut_grp_obj) { 
  static bool is_initialized = false;
  if (!is_initialized) {
    is_initialized = true;

    GRAPH = new_graph(MAXVERTS);

    // Currently Conditions are a nr1 x nr1 array of BitArrays, so both
    // values have to be set to MAXVERTS
    CLIQUE = new_bit_array(MAXVERTS); 
    TRY    = new_conditions(MAXVERTS, MAXVERTS); 
    BAN    = new_conditions(MAXVERTS, MAXVERTS); 

    ORB_LOOKUP     = new_bit_array(MAXVERTS);
    for (uint16_t i = 0; i < MAXVERTS; i++) { 
      STAB_GENS[i] = new_perm_coll(MAXVERTS, MAXVERTS);
    }
    SCHREIER_SIMS = new_schreier_sims();
  }

  init_clique_graph_from_digraph_obj(GRAPH, digraph_obj);

  uint16_t nr = DigraphNrVertices(digraph_obj);
  clear_conditions(TRY, nr + 1, nr);
  clear_conditions(BAN, nr + 1, nr);
  init_bit_array(BAN->bit_array[0], false, nr);

  // Update and CLIQUE and TRY using include_obj
  if (include_obj != Fail) {
    init_bit_array(CLIQUE, false, nr);
    set_bit_array_from_gap_list(CLIQUE, include_obj);
    complement_bit_arrays(get_conditions(TRY, 0), CLIQUE, nr);
    for (uint16_t i = 1; i <= LEN_LIST(include_obj); ++i) {
      intersect_bit_arrays(get_conditions(TRY, 0),
                           GRAPH->neighbours[INT_INTOBJ(ELM_LIST(include_obj, i)) - 1],
                           nr);
    }
  }


  if (hook_obj != Fail) {
    GAP_FUNC = hook_obj;
    HOOK     = clique_hook_gap;
  } else {
    HOOK = clique_hook_collect;
  }
  USER_PARAM = user_param_obj;


  // Get generators of the automorphism group the graph
  PERM_DEGREE = nr;
  if (aut_grp_obj == Fail) {
    // TODO: should we use BLISS instead? Otherwise drop digraph directions in GAP
    get_automorphism_group_from_gap(digraph_obj, STAB_GENS[0]);
  } else {
    set_automorphisms(aut_grp_obj, STAB_GENS[0]);
  }

  return true;
}

Obj FuncDigraphsCliqueFinder(Obj self, Obj args) {
  if (LEN_PLIST(args) != 8 && LEN_PLIST(args)  != 9) { 
    ErrorQuit(
        "there must be 8 or 9 arguments, found %d,", LEN_PLIST(args), 0L);
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
    ErrorQuit("the 1st argument <digraph> must have at most 512 vertices, "
              "found %d,",
              DigraphNrVertices(digraph_obj),
              0L);
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
      } else if (!IS_POS_INT(ELM_LIST(include_obj, i))) {
        ErrorQuit("the 5th argument <include> must only contain positive "
                  "integers, but found %s in position %d,",
                  (Int) TNAM_OBJ(ELM_LIST(include_obj, i)),
                  i);
      } else if (INT_INTOBJ(ELM_LIST(include_obj, i)) 
                 > DigraphNrVertices(digraph_obj)) {
        ErrorQuit("in the 5th argument <include> position %d is out of range, "
                  "must be in the range [1, %d],",
                  i,
                  DigraphNrVertices(digraph_obj));
      } else if (INT_INTOBJ(
                     POS_LIST(include_obj, ELM_LIST(include_obj, i), INTOBJ_INT(0)))
                 < i) {
        ErrorQuit("in the 5th argument <include> position %d is a duplicate,", i, 0L);
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
      } else if (!IS_POS_INT(ELM_LIST(exclude_obj, i))) {
        ErrorQuit("the 6th argument <exclude> must only contain positive "
                  "integers, but found %s in position %d,",
                  (Int) TNAM_OBJ(ELM_LIST(exclude_obj, i)),
                  i);
      } else if (INT_INTOBJ(ELM_LIST(exclude_obj, i)) 
                 > DigraphNrVertices(digraph_obj)) {
        ErrorQuit("in the 6th argument <exclude> position %d is out of range, "
                  "must be in the range [1, %d],",
                  i,
                  DigraphNrVertices(digraph_obj));
      } else if (INT_INTOBJ(
                     POS_LIST(exclude_obj, ELM_LIST(exclude_obj, i), INTOBJ_INT(0)))
                 < i) {
        ErrorQuit("in the 6th argument <exclude> position %d is a duplicate,", i, 0L);
      }
    }
  }
  if (max_obj != True && max_obj != False) {
    ErrorQuit("the 7th argument <max> must true or false, not %s,",
              (Int) TNAM_OBJ(max_obj),
              0L);
  }
  if (!IS_INTOBJ(size_obj) && size_obj != Fail) {
    ErrorQuit("the 8th argument <size> must be an integer "
              "or fail, not %s,",
              (Int) TNAM_OBJ(size_obj),
              0L);
  } else if (IS_INTOBJ(size_obj) && INT_INTOBJ(size_obj) <= 0) {
    ErrorQuit("the 8th argument <size> must be a positive integer, "
              "not %d,",
              INT_INTOBJ(size_obj),
              0L);
  }

  if (aut_grp_obj != Fail) {
    if (CALL_1ARGS(IsPermGroup, aut_grp_obj) != True) {
      ErrorQuit(
          "the 9th argument <aut_grp> must be a permutation group "
          "or fail, not %s,",
          (Int) TNAM_OBJ(aut_grp_obj),
          0L);
    }
    Obj gens = CALL_1ARGS(GeneratorsOfGroup, aut_grp_obj);
    DIGRAPHS_ASSERT(IS_LIST(gens));
    DIGRAPHS_ASSERT(LEN_LIST(gens) > 0);
    UInt lmp = INT_INTOBJ(CALL_1ARGS(LargestMovedPointPerms, gens));
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
  }

  uint16_t size  = (size_obj == Fail ? 0 : INT_INTOBJ(size_obj));
  uint16_t include_size = (include_obj == Fail ? 0 : LEN_LIST(include_obj));
  uint16_t exclude_size = (exclude_obj == Fail ? 0 : LEN_LIST(exclude_obj));
  uint16_t nr = DigraphNrVertices(digraph_obj);

  // Check the trivial cases:
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
    for (uint16_t i = 0; i < include_size; ++i) {
      lookup[INT_INTOBJ(ELM_LIST(include_obj, i)) - 1] = true;
    }
    for (uint16_t i = 0; i < exclude_size; ++i) {
      if (lookup[INT_INTOBJ(ELM_LIST(exclude_obj, i)) - 1]) { 
        return user_param_obj;
      }
    }
  }
  // Check if the set we are trying to extend is a clique
  if (include_obj != Fail && CALL_2ARGS(IsClique, digraph_obj, include_obj) == False) {
    return user_param_obj;
  }
  // 
  uint16_t nr_found = 0;
  uint16_t limit = (limit_obj == Infinity ? MAXVERTS : INT_INTOBJ(limit_obj));
  bool max = (max_obj == True ? true : false); 
  // Initialise all the variable which will be used to carry out the recursion
  if (!init_clique_data_from_args(digraph_obj, 
                                  hook_obj, 
                                  user_param_obj, 
                                  include_obj, 
                                  exclude_obj, 
                                  max_obj, 
                                  aut_grp_obj)) { 
    return user_param_obj;
  }


  // go!
  if (setjmp(OUTOFHERE) == 0) {
    BronKerbosch(0, 0, limit, &nr_found, max, (size == 0 ? size : size - include_size)); 
  }

  return user_param_obj;
}
