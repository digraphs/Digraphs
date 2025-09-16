/*******************************************************************************
**
*A  dfs.c                  GAP package Digraphs               Lea Racine
**                                                            James Mitchell
**
**  Copyright (C) 2014-21 - Julius Jonusas, James Mitchell, Michael Torpey,
**  Wilf A. Wilson et al.
**
**  This file is free software, see the digraphs/LICENSE.
**
*******************************************************************************/

#include <stdint.h>      // for uint64_t
#include <stdlib.h>      // for NULL, free

#include "dfs.h"
#include "digraphs-debug.h"
#include "safemalloc.h"  // for safe_malloc

Int DigraphNrVertices(Obj);
Obj FuncOutNeighbours(Obj, Obj);

// Iterative stack helpers

#define STACK_PUSH(stack, size, val) AssPlist(stack, ++size, val)

#define STACK_POP(stack, size) ELM_PLIST(stack, size--)

// The index recursive DFS starts with (indicating to visit the current node)
#define PREORDER_IDX 0

// Call either PreorderFunc, PostorderFunc, CrossFunc or AncestorFunc,
// then return if the stop element was set

#define CALL_CHECK_STOP(f, RNamStop, record, data) \
  CALL_2ARGS(f, record, data);                     \
  if (ElmPRec(record, RNamStop) == True) {         \
    CHANGED_BAG(record);                           \
    return false;                                  \
  }

/* --- Macros for getting / setting partial / full lists in dfs_args struct
       depending on dfs_args.conf

       e.g. use dfs_args.preorder if dfs_args.dfs_conf.use_preorder, otherwise
       use dfs_args.partial_preorder --- */

// Preorder / Partial Preorder getters and setters

#define GET_PREORDER(args, idx)                                            \
  args->dfs_conf->use_preorder ? INT_INTOBJ(ELM_LIST(args->preorder, idx)) \
                               : args->preorder_partial[idx]

#define SET_PREORDER(args, idx)                                         \
  if (args->dfs_conf->use_preorder) {                                   \
    ASS_LIST(args->preorder, idx, INTOBJ_INT(++(*args->preorder_num))); \
  } else {                                                              \
    args->preorder_partial[idx] = true;                                 \
  }

#define UNSET_PREORDER(args, idx)                  \
  if (args->dfs_conf->use_preorder) {              \
    ASS_LIST(args->preorder, idx, INTOBJ_INT(-1)); \
  } else {                                         \
    args->preorder_partial[idx] = false;           \
  }

#define IS_VISITED(args, idx)                           \
  args->dfs_conf->use_preorder                          \
      ? INT_INTOBJ(ELM_LIST(args->preorder, idx)) != -1 \
      : args->preorder_partial[idx]

// --- Postorder / Partial Postorder getters and setters ---

#define GET_POSTORDER(args, idx)                                             \
  args->dfs_conf->use_postorder ? INT_INTOBJ(ELM_LIST(args->postorder, idx)) \
                                : args->postorder_partial[idx]

#define SET_POSTORDER(args, idx)                                          \
  if (args->dfs_conf->use_postorder) {                                    \
    ASS_LIST(args->postorder, idx, INTOBJ_INT(++(*args->postorder_num))); \
  } else if (args->dfs_conf->partial_postorder) {                         \
    args->postorder_partial[idx] = true;                                  \
  }

#define IS_BACKTRACKED(args, idx)                        \
  args->dfs_conf->use_postorder                          \
      ? INT_INTOBJ(ELM_LIST(args->postorder, idx)) != -1 \
      : args->postorder_partial[idx]

#define ON_PREORDER(current, args)                                    \
  SET_PREORDER(args, current);                                        \
  AssPRec(args->record, args->RNamCurrent, INTOBJ_INT(current));      \
  CHANGED_BAG(args->record);                                          \
  if (args->CallPreorder) {                                           \
    CALL_CHECK_STOP(                                                  \
        args->PreorderFunc, args->RNamStop, args->record, args->data) \
  }

/* --- Macros for back edge, cross edge, successor adding, and backtracking
       used by ExecuteDFSIter and ExecuteDFSRec --- */


/*  Back Edge / Cross Edges

    v is a visited node. The edge (current -> v) may be:
  - a back edge (v is an ancestor of current) - if v has not been backtracked on
  - a cross edge (v is neither an ancestor or a descendant of current) - if
    v has been backtracked on and v was visited before current

  - Otherwise, a forward edge (v is a descendant of current) - Unused case


  Set the child and current record elements for use in CrossFunc / AncestorFunc,
  and call the appropriate function if (current -> v) is a back or cross edge
*/

#define ANCESTOR_CROSS(current, v, v_backtracked, args)                 \
  if (args->CallAncestor || args->CallCross) {                          \
    AssPRec(args->record, args->RNamChild, INTOBJ_INT(v));              \
    AssPRec(args->record, args->RNamCurrent, INTOBJ_INT(current));      \
    CHANGED_BAG(args->record);                                          \
    if (args->CallAncestor && !v_backtracked) {                         \
      CALL_CHECK_STOP(                                                  \
          args->AncestorFunc, args->RNamStop, args->record, args->data) \
    } else if (args->CallCross                                          \
               && (v_backtracked                                        \
                   && ((GET_PREORDER(args, v))                          \
                       < (GET_PREORDER(args, current))))) {             \
      CALL_CHECK_STOP(                                                  \
          args->CrossFunc, args->RNamStop, args->record, args->data)    \
    }                                                                   \
    CHANGED_BAG(args->record);                                          \
  }

/*  Backtracking edge (parent -> current)

    Set a node as backtracked, then call the PostorderFunc if one exists
    setting the current and child elements of the DFS record
*/

#define ON_BACKTRACK(current, parent, args)                                  \
  if (args->dfs_conf->use_postorder || args->dfs_conf->partial_postorder) {  \
    SET_POSTORDER(args, current);                                            \
    CHANGED_BAG(args->record);                                               \
  }                                                                          \
  if (args->CallPostorder) {                                                 \
    /* When CallPostorder is true, use_parents must be true, parent is valid
     */                                                                      \
    AssPRec(args->record, args->RNamChild, INTOBJ_INT(current));             \
    AssPRec(args->record, args->RNamCurrent, INTOBJ_INT(parent));            \
    CHANGED_BAG(args->record);                                               \
    CALL_CHECK_STOP(                                                         \
        args->PostorderFunc, args->RNamStop, args->record, args->data)       \
    CHANGED_BAG(args->record);                                               \
  }

/*  Adding a successor succ of current. idx is the index
    of succ in OutNeighbours[current]

    For iterative: When pushing succ to the stack
    For recursive: Before recursing on succ
*/

#define ON_ADD_SUCC(current, succ, idx, args)           \
  if (args->dfs_conf->use_parents) {                    \
    AssPlist(args->parents, succ, INTOBJ_INT(current)); \
  }                                                     \
  if (args->dfs_conf->use_edge) {                       \
    AssPlist(args->edge, succ, INTOBJ_INT(idx));        \
  }                                                     \
  CHANGED_BAG(args->record);

#define RECURSE_FOREST(dfs_args, v)                     \
  bool visited = IS_VISITED(dfs_args, v);               \
  if (!visited) {                                       \
    if (dfs_args->dfs_conf->use_parents) {              \
      AssPlist(dfs_args->parents, v, INTOBJ_INT(v));    \
      CHANGED_BAG(record);                              \
    }                                                   \
    if (!ExecuteDFSRec(v, v, PREORDER_IDX, dfs_args)) { \
      CHANGED_BAG(record);                              \
      recordCleanup(dfs_args);                          \
      return record;                                    \
    }                                                   \
  }

#define ITER_FOREST(args, stack, v)              \
  bool visited = IS_VISITED(args, v);            \
                                                 \
  if (!visited) {                                \
    if (args->dfs_conf->use_parents) {           \
      AssPlist(args->parents, v, INTOBJ_INT(v)); \
    }                                            \
    CHANGED_BAG(args->record);                   \
    AssPlist(stack, 1, INTOBJ_INT(v));           \
                                                 \
    if (!iter_loop(stack, 1, args))              \
      return false;                              \
  }

void recordCleanup(struct dfs_args* args) {
  struct dfs_config* dfs_conf = args->dfs_conf;

  if (!dfs_conf->use_preorder) {
    free(args->preorder_partial);
  }

  if (dfs_conf->partial_postorder) {
    free(args->postorder_partial);
  }
}

void parseConfig(struct dfs_args* args, Obj conf_record) {
  struct dfs_config* conf = args->dfs_conf;
  conf->iter              = ElmPRec(conf_record, RNamName("iterative")) == True;
  conf->revisit           = ElmPRec(conf_record, RNamName("revisit")) == True;
  conf->forest            = ElmPRec(conf_record, RNamName("forest")) == True;
  conf->use_preorder  = ElmPRec(conf_record, RNamName("use_preorder")) == True;
  conf->use_postorder = ElmPRec(conf_record, RNamName("use_postorder")) == True;
  conf->use_parents   = ElmPRec(conf_record, RNamName("use_parents")) == True;
  conf->use_edge      = ElmPRec(conf_record, RNamName("use_edge")) == True;
  conf->forest_specific   = ElmPRec(conf_record, RNamName("forest_specific"));
  conf->partial_postorder = false;  // Updated when parsing the config (whether
                                    // to use a bitset for backtracked vertices)

  if (!conf->iter && (!conf->use_edge || !conf->use_parents)) {
    ErrorQuit(
        "In a DFSRecord where the config flag iterative is false, use_edge and "
        "use_parents must be true",
        0L,
        0L);
  }

  if (conf->revisit && !conf->iter) {
    ErrorQuit("In a DFSRecord where the config flag revisit is true, iterative "
              "must also be true",
              0L,
              0L);
  }

  if ((args->CallAncestor || args->CallCross || conf->revisit)
      && !conf->use_postorder) {
    // If AncestorFunc or CrossFunc are called, we need to be able to
    // detect whether a node has been backtracked
    // likewise for being able to revisit nodes without infinite traversal

    conf->partial_postorder = true;
  }

  if ((args->CallPostorder && conf->iter) && !conf->use_parents) {
    // use_parents is always required for recursive (only check for iter)
    ErrorQuit(
        "In a DFSRecord where a PostorderFunc exists and the config flag "
        "iter is true, the flag use_parents must also be true",
        0L,
        0L);
  }

  if ((args->CallPostorder && conf->iter) && !conf->use_postorder) {
    conf->partial_postorder = true;
  }

  if (conf->forest_specific != Fail && conf->forest) {
    ErrorQuit(
        "In a DFSRecord where the config flag forest_specific is not fail, "
        "forest cannot also be true",
        0L,
        0L);
  }

  if (args->CallCross && (!conf->use_preorder)) {
    ErrorQuit("In a DFSRecord where there is a CrossFunc, the config flag "
              "use_preorder must be true",
              0L,
              0L);
  }
}

// Extreme examples are on the pull request #459

/* Iterative DFS (used for revisiting vertices)
   Necessary record elements: none
   If CallPostorder, then parents is necessary

   Differences with recursive : edge and parents are updated
   when successors are pushed to the stack, whereas with
   recursive they are updated before visiting
*/

bool ExecuteDFSIter(Int start, struct dfs_args* args) {
  Int N     = LEN_LIST(args->neighbors);
  Obj stack = NEW_PLIST(T_PLIST_CYC, N * 2);

  Int stack_size = 1;

  AssPlist(stack, 1, INTOBJ_INT(start));

  if (!iter_loop(stack, stack_size, args))
    return false;

  if (args->dfs_conf->forest) {
    for (Int i = 1; i <= LEN_LIST(args->neighbors); i++) {
      ITER_FOREST(args, stack, i);
    }
  } else if (args->dfs_conf->forest_specific != Fail) {
    Int len = LEN_LIST(args->dfs_conf->forest_specific);
    for (Int i = 1; i <= len; i++) {
      ITER_FOREST(args, stack, i);
    }
  }
  return true;
}

/*
   Main loop for iterative DFS called by ITER_FOREST and ExecuteDFSIter.

   ON_PREORDER, ON_BACKTRACK and ANCESTOR_CROSS can return from this function
   if the record.stop attribute is set during a called PreOrderFunc,
   PostOrderFunc, CrossFunc, or AncestorFunc.
*/

bool iter_loop(Obj stack, Int stack_size, struct dfs_args* args) {
  while (stack_size > 0) {
    Int current = INT_INTOBJ(STACK_POP(stack, stack_size));

    if (current < 0) {  // Backtrack node
      Int bt_on  = current * -1;
      Int parent = !args->dfs_conf->use_parents
                       ? -1
                       : INT_INTOBJ(ELM_LIST(args->parents, bt_on));
      ON_BACKTRACK(bt_on, parent, args);
      continue;
    } else if (IS_VISITED(args, current)) {
      continue;
    }

    ON_PREORDER(current, args);

    if (args->dfs_conf->use_postorder || args->dfs_conf->partial_postorder
        || args->CallPostorder) {  // push backtrack node if needed
      STACK_PUSH(stack, stack_size, INTOBJ_INT(current * -1));
    }

    Obj succ = ELM_LIST(args->neighbors, current);

    // idx 1 at the top of the stack,
    // (visit order consistent with recursive dfs)
    for (Int i = LEN_LIST(succ); i > 0; i--) {
      Int v = INT_INTOBJ(ELM_LIST(succ, i));

      bool v_backtracked =
          (args->dfs_conf->use_postorder || args->dfs_conf->partial_postorder)
          && (IS_BACKTRACKED(args, v));
      bool revisit = (args->dfs_conf->revisit && v_backtracked);
      if (revisit) {
        UNSET_PREORDER(args, v);
        CHANGED_BAG(args->record);
      }
      bool visited = IS_VISITED(args, v);

      if (!visited) {
        ON_ADD_SUCC(current, v, i, args);
        STACK_PUSH(stack, stack_size, INTOBJ_INT(v));
      } else {
        ANCESTOR_CROSS(current, v, v_backtracked, args);
      }
    }
  }
  return true;
}

/* Recursive DFS
 Necessary record elements: edge, parents
 goto used to force tail call optimization

 ON_PREORDER, ON_BACKTRACK and ANCESTOR_CROSS can return from this function
 if the record.stop attribute is set during a called PreOrderFunc,
 PostOrderFunc, CrossFunc, or AncestorFunc.
*/

bool ExecuteDFSRec(Int current, Int parent, Int idx, struct dfs_args* args) {
// "goto recurse" used to prevent stack overflows for deep trees regardless of
// optimisation level
recurse:
  if (idx == PREORDER_IDX) {  // visit current
    ON_PREORDER(current, args);

    // Start recursing on successors of vertex <current>, with parent <parent>
    idx += 1;
    goto recurse;
  }

  Obj successors = ELM_LIST(args->neighbors, current);

  if (idx > LEN_LIST(successors)) {
    // Backtrack on current (all successors explored)
    ON_BACKTRACK(current, parent, args);

    Int prev_idx       = INT_INTOBJ(ELM_LIST(args->edge, current));
    Int parents_parent = INT_INTOBJ(ELM_LIST(args->parents, parent));

    if (parent == current) {
      return true;  // At root
    }

    // Continue exploration of <parent>'s successors

    current = parent;          // Backtrack to parent of <current> vertex
    parent  = parents_parent;  // The parent is now the new <current> vertex's
                               // previously assigned parent
    idx = prev_idx + 1;        // Index is the next successor to visit
                               // continuing previous exploration of
                               // <current>'s successors
    goto recurse;
  } else {
    // Visit successor successors[idx] of current
    Int  v       = INT_INTOBJ(ELM_LIST(successors, idx));
    bool visited = IS_VISITED(args, v);

    if (!visited) {
      ON_ADD_SUCC(current, v, idx, args);

      parent  = current;  // Explore successor v with parent <current>
      current = v;
      idx     = PREORDER_IDX;  // Initial index to indicate v is being visited

      goto recurse;

    } else {
      bool backtracked =
          (args->dfs_conf->use_postorder || args->dfs_conf->partial_postorder)
          && (IS_BACKTRACKED(args, v));
      ANCESTOR_CROSS(current, v, backtracked, args);

      idx += 1;  // Skip this successor of <current>
                 // since it has already been visited
      goto recurse;
    }
  }
}

Obj FuncExecuteDFS_C(Obj self, Obj args) {
  DIGRAPHS_ASSERT(LEN_PLIST(args) == 7);
  Obj record        = ELM_PLIST(args, 1);
  Obj config        = ElmPRec(record, RNamName("config"));
  Obj data          = ELM_PLIST(args, 2);
  Obj start         = ELM_PLIST(args, 3);
  Obj PreorderFunc  = ELM_PLIST(args, 4);
  Obj PostorderFunc = ELM_PLIST(args, 5);
  Obj AncestorFunc  = ELM_PLIST(args, 6);
  Obj CrossFunc     = ELM_PLIST(args, 7);

  // Check if function args are fail or 2 argument functions
#define CHECK_FUNCTION(function)                                             \
  if (!((IS_FUNC(function) && NARG_FUNC(function) == 2)                      \
        || function == Fail)) {                                              \
    ErrorQuit("arguments 4-7 (PreorderFunc, PostorderFunc, AncestorFunc, "   \
              "CrossFunc)"                                                   \
              "must be either a function taking arguments (record, data) or" \
              "Fail,",                                                       \
              0L,                                                            \
              0L);                                                           \
  }

  CHECK_FUNCTION(PreorderFunc);
  CHECK_FUNCTION(PostorderFunc);
  CHECK_FUNCTION(AncestorFunc);
  CHECK_FUNCTION(CrossFunc);

  Obj D             = ElmPRec(record, RNamName("graph"));
  Obj outNeighbours = FuncOutNeighbours(self, D);
  Int N             = DigraphNrVertices(D);

  if (!IS_INTOBJ(start) || INT_INTOBJ(start) > N || INT_INTOBJ(start) <= 0) {
    ErrorQuit(
        "the third argument <start> must be a vertex in your graph,", 0L, 0L);
  }

  Int RNamStop = RNamName("stop");

  if (ElmPRec(record, RNamStop) == True)
    return record;

  Int preorder_num  = 0;
  Int postorder_num = 0;

  struct dfs_config dfs_conf = {0};

  struct dfs_args dfs_args_ = {
      .dfs_conf      = &dfs_conf,
      .record        = record,
      .preorder_num  = &preorder_num,
      .postorder_num = &postorder_num,
      .parents       = ElmPRec(record, RNamName("parents")),
      .postorder     = ElmPRec(record, RNamName("postorder")),
      .preorder      = ElmPRec(record, RNamName("preorder")),
      .edge          = ElmPRec(record, RNamName("edge")),
      .neighbors     = outNeighbours,
      .data          = data,
      .PreorderFunc  = PreorderFunc,
      .PostorderFunc = PostorderFunc,
      .AncestorFunc  = AncestorFunc,
      .CrossFunc     = CrossFunc,
      .RNamChild     = RNamName("child"),
      .RNamCurrent   = RNamName("current"),
      .RNamStop      = RNamStop,
      .CallPreorder  = PreorderFunc != Fail,
      .CallPostorder = PostorderFunc != Fail,
      .CallAncestor  = AncestorFunc != Fail,
      .CallCross     = CrossFunc != Fail};

  parseConfig(&dfs_args_, config);

  if (!dfs_conf.use_preorder) {
    dfs_args_.preorder_partial = (bool*) safe_malloc((N + 1) * sizeof(bool));
    memset(dfs_args_.preorder_partial, false, (N + 1) * sizeof(bool));
  }

  if (dfs_conf.partial_postorder) {
    dfs_args_.postorder_partial = (bool*) safe_malloc((N + 1) * sizeof(bool));
    memset(dfs_args_.postorder_partial, false, (N + 1) * sizeof(bool));
  }

  if (dfs_conf.use_parents) {
    AssPlist(dfs_args_.parents, INT_INTOBJ(start), start);
    CHANGED_BAG(record);
  }

  Int current = INT_INTOBJ(start);

  if (dfs_conf.iter || dfs_conf.revisit) {
    ExecuteDFSIter(current, &dfs_args_);
  } else {
    if (dfs_conf.forest || (dfs_conf.forest_specific != Fail)) {
      // Initial DFS with specified start index
      if (ExecuteDFSRec(current, current, PREORDER_IDX, &dfs_args_)) {
        if (dfs_conf.forest) {
          for (Int i = 1; i <= N; i++) {
            RECURSE_FOREST((&dfs_args_), i);  // Returns
          }
        } else if (dfs_conf.forest_specific != Fail) {
          for (Int i = 1; i <= LEN_LIST(dfs_conf.forest_specific); i++) {
            RECURSE_FOREST((&dfs_args_),  // Returns
                           INT_INTOBJ(ELM_LIST(dfs_conf.forest_specific, i)));
          }
        }
      }
    } else {
      ExecuteDFSRec(current, current, PREORDER_IDX, &dfs_args_);
    }
  }

  recordCleanup(&dfs_args_);

  CHANGED_BAG(record);
  return record;
}
