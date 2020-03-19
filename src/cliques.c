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


static Digraph* DIGRAPH;  // Digraphs to hold incoming GAP digraphs

static Graph* GRAPH;  // Graphs to hold incoming GAP symmetric digraphs

static BitArray*  CLIQUE;
static Conditions*  TRY;
static Conditions*  BAN;


////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

static void BronKerbosch(uint16_t depth) {

  uint16_t nr = GRAPH->nr_vertices;
  BitArray* try = get_conditions(TRY, 0);
  BitArray* ban = get_conditions(BAN, 0);

  if (size_bit_array(try, nr) == 0 && size_bit_array(ban, nr) ==0) {
    // <CLIQUE> is a maximal clique
    HOOK(USER_PARAM, CLIQUE, nr);
    return;
  } 

  // Choose a pivot with as a many neighbours in <try> as possible 
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
  BitArray* to_try = new_bit_array(MAXVERTS);
  init_bit_array(to_try, 1, nr);
  complement_bit_arrays(to_try, GRAPH->neighbours[pivot], nr);
  intersect_bit_arrays(to_try, try, nr); 
  for (uint16_t i = 0; i < nr; i++) {
    if (get_bit_array(to_try, i)){
      set_bit_array(CLIQUE, i, true);

      push_conditions(TRY, depth + 1, 0, GRAPH->neighbours[i]);
      push_conditions(BAN, depth + 1, 0, GRAPH->neighbours[i]);

      // recurse
      BronKerbosch(depth + 1);

      pop_conditions(TRY, depth + 1);
      pop_conditions(BAN, depth + 1);
      set_bit_array(CLIQUE, i, false);

      set_bit_array(get_conditions(TRY, 0), i , false);
      set_bit_array(get_conditions(BAN, 0), i , true);
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
  DIGRAPHS_ASSERT(CALL_1ARGS(IsSymmetricDigraph, digraph_obj) == True);
  UInt const nr  = DigraphNrVertices(digraph_obj);
  Obj        out = FuncOutNeighbours(0L, digraph_obj);
  DIGRAPHS_ASSERT(nr < MAXVERTS);
  DIGRAPHS_ASSERT(IS_PLIST(out));
  clear_graph(graph, nr);

  for (uint16_t i = 1; i <= nr; i++) {
    Obj nbs = ELM_PLIST(out, i);
    DIGRAPHS_ASSERT(IS_LIST(nbs));
    for (uint16_t j = 1; j <= LEN_LIST(nbs); j++) {
      DIGRAPHS_ASSERT(IS_INTOBJ(ELM_LIST(nbs, j)));
      add_edge_graph(graph, i - 1, INT_INTOBJ(ELM_LIST(nbs, j)) - 1);
    }
  }
}

static void init_clique_digraph_from_digraph_obj(Digraph* const digraph,
                                          Obj            digraph_obj) {
  DIGRAPHS_ASSERT(digraph != NULL);
  DIGRAPHS_ASSERT(CALL_1ARGS(IsDigraph, digraph_obj) == True);
  UInt const nr  = DigraphNrVertices(digraph_obj);
  Obj        out = FuncOutNeighbours(0L, digraph_obj);
  DIGRAPHS_ASSERT(nr < MAXVERTS);
  DIGRAPHS_ASSERT(IS_PLIST(out));
  clear_digraph(digraph, nr);

  for (uint16_t i = 1; i <= nr; i++) {
    Obj nbs = ELM_PLIST(out, i);
    DIGRAPHS_ASSERT(IS_LIST(nbs));
    for (uint16_t j = 1; j <= LEN_LIST(nbs); j++) {
      DIGRAPHS_ASSERT(IS_INTOBJ(ELM_LIST(nbs, j)));
      add_edge_digraph(digraph, i - 1, INT_INTOBJ(ELM_LIST(nbs, j)) - 1);
    }
  }
}

static bool init_clique_data_from_args(Obj digraph_obj, 
                                       Obj hook_obj, 
                                       Obj user_param_obj, 
                                       Obj limit_obj, 
                                       Obj include_obj, 
                                       Obj exclude_obj, 
                                       Obj max_obj, 
                                       Obj size_obj) { 
  static bool is_initialized = false;
  if (!is_initialized) {
    is_initialized = true;

    DIGRAPH = new_digraph(MAXVERTS);

    GRAPH = new_graph(MAXVERTS);

    // Currently Conditions are a nr1 x nr1 array of BitArrays, so both
    // values have to be set to MAXVERTS
    CLIQUE = new_bit_array(MAXVERTS); 
    TRY    = new_conditions(MAXVERTS, MAXVERTS); 
    BAN    = new_conditions(MAXVERTS, MAXVERTS); 
  }

  uint16_t nr = DigraphNrVertices(digraph_obj);
  init_bit_array(CLIQUE, false, nr);
  clear_conditions(TRY, nr + 1, nr);
  clear_conditions(BAN, nr + 1, nr);
  init_bit_array(BAN->bit_array[0], false, nr);


  bool is_undirected;
  if (CALL_1ARGS(IsSymmetricDigraph, digraph_obj) == True) {
    init_clique_graph_from_digraph_obj(GRAPH, digraph_obj);
    is_undirected = true;
  } else {
    init_clique_digraph_from_digraph_obj(DIGRAPH, digraph_obj);
    is_undirected = false;
  }

  if (hook_obj != Fail) {
    GAP_FUNC = hook_obj;
    HOOK     = clique_hook_gap;
  } else {
    HOOK = clique_hook_collect;
  }
  USER_PARAM = user_param_obj;

  return true;
}

Obj FuncDigraphsCliqueFinder(Obj self, Obj args) {
  if (LEN_PLIST(args) != 8) { 
    ErrorQuit(
        "there must be 8 arguments, found %d,", LEN_PLIST(args), 0L);
  }
  Obj digraph_obj    = ELM_PLIST(args, 1);
  Obj hook_obj       = ELM_PLIST(args, 2);
  Obj user_param_obj = ELM_PLIST(args, 3);
  Obj limit_obj      = ELM_PLIST(args, 4);
  Obj include_obj    = ELM_PLIST(args, 5);
  Obj exclude_obj    = ELM_PLIST(args, 6);
  Obj max_obj        = ELM_PLIST(args, 7);
  Obj size_obj       = ELM_PLIST(args, 8);

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
  if (!IS_INTOBJ(limit_obj) && limit_obj != Fail) {
    ErrorQuit("the 4th argument <limit_obj> must be an integer "
              "or fail, not %s,",
              (Int) TNAM_OBJ(limit_obj),
              0L);
  } else if (IS_INTOBJ(limit_obj) && INT_INTOBJ(limit_obj) <= 0) {
    ErrorQuit("the 4th argument <limit_obj> must be a positive integer, "
              "not %d,",
              INT_INTOBJ(limit_obj),
              0L);
  }
  if (max_obj != True && max_obj != False) {
    ErrorQuit("the 7th argument <max_obj> must true or false, not %s,",
              (Int) TNAM_OBJ(max_obj),
              0L);
  }
  if (!IS_INTOBJ(size_obj) && size_obj != Fail) {
    ErrorQuit("the 8th argument <size_obj> must be an integer "
              "or fail, not %s,",
              (Int) TNAM_OBJ(size_obj),
              0L);
  } else if (IS_INTOBJ(size_obj) && INT_INTOBJ(size_obj) <= 0) {
    ErrorQuit("the 8th argument <size_obj> must be a positive integer, "
              "not %d,",
              INT_INTOBJ(size_obj),
              0L);
  }

  // Initialise all the variable which will be used to carry out the recursion
  if (!init_clique_data_from_args(digraph_obj, 
                                  hook_obj, 
                                  user_param_obj, 
                                  limit_obj, 
                                  include_obj, 
                                  exclude_obj, 
                                  max_obj, 
                                  size_obj)) { 
    return user_param_obj;
  }


  // go!

  if (setjmp(OUTOFHERE) == 0) {
    BronKerbosch(0); 
  }

  return user_param_obj;
}


