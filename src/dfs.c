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

#include "dfs.h"

#include <stdint.h>   // for uint64_t
#include <stdlib.h>   // for NULL, free

#include "digraphs-config.h"
#include "digraphs-debug.h"
#include "digraphs.h"

// Macros used for both recursive and iterative

#define ON_PREORDER(args, current)                                         \
  ASS_LIST(args->preorder, current, INTOBJ_INT(++(*args->preorder_num)));  \
  AssPRec(args->record, args->RNamCurrent, INTOBJ_INT(current));           \
  CHANGED_BAG(args->record);                                               \
  if (args->CallPreorder                                                   \
      && CallCheckStop(                                                    \
          args->PreorderFunc, args->RNamStop, args->record, args->data)) { \
    return args->record;                                                   \
  }                                                                        \
  CHANGED_BAG(args->record);

#define ANCESTOR_CROSS(current, v, backtracked, args)                          \
  AssPRec(args->record, args->RNamChild, INTOBJ_INT(v));                       \
  AssPRec(args->record, args->RNamCurrent, INTOBJ_INT(current));               \
  CHANGED_BAG(args->record);                                                   \
  if (args->CallAncestor || args->CallCross) {                                 \
    if (args->CallAncestor && !backtracked) {                                  \
      if (CallCheckStop(                                                       \
              args->AncestorFunc, args->RNamStop, args->record, args->data)) { \
        return false;                                                          \
      }                                                                        \
    } else if (args->CallCross                                                 \
               && (backtracked                                                 \
                   && INT_INTOBJ(ELM_PLIST(args->preorder, v))                 \
                          < INT_INTOBJ(ELM_PLIST(args->preorder, current)))) { \
      if (CallCheckStop(                                                       \
              args->CrossFunc, args->RNamStop, args->record, args->data)) {    \
        return false;                                                          \
      }                                                                        \
    }                                                                          \
    CHANGED_BAG(args->record);                                                 \
  }

#define ON_BACKTRACK(current, prev, args)                                   \
  AssPRec(args->record, args->RNamChild, INTOBJ_INT(current));              \
  AssPRec(args->record, args->RNamCurrent, INTOBJ_INT(prev));               \
  ASS_LIST(args->postorder, current, INTOBJ_INT(++(*args->postorder_num))); \
  CHANGED_BAG(args->record);                                                \
  if (args->CallPostorder                                                   \
      && CallCheckStop(                                                     \
          args->PostorderFunc, args->RNamStop, args->record, args->data)) { \
    return false;                                                           \
  }                                                                         \
  CHANGED_BAG(args->record);

#define ON_ADD_SUCC(current, succ, idx, args)         \
  ASS_LIST(args->parents, succ, INTOBJ_INT(current)); \
  ASS_LIST(args->edge, succ, INTOBJ_INT(idx));        \
  CHANGED_BAG(args->record);

#define STACK_PUSH(stack, size, val) \
  AssPlist(stack, ++size, val)

#define STACK_POP(stack, size) \
  ELM_PLIST(stack, size--)

#define PREORDER_IDX 0

void parseConfig(struct dfs_config* conf, Obj conf_record) {
  conf -> iter = ElmPRec(conf_record, RNamName("iterative")) == True;
  conf -> revisit = ElmPRec(conf_record, RNamName("revisit")) == True;
  conf -> forest = ElmPRec(conf_record, RNamName("forest")) == True;
}

// Extreme examples are on the pull request #459

bool CallCheckStop(Obj f, Int RNamStop, Obj record, Obj data) {
    CALL_2ARGS(f, record, data);
    if (ElmPRec(record, RNamStop) == True) {
      return true;
    }
    return false;
}

// Iterative DFS (for revisiting vertices)

bool ExecuteDFSIter(Int start, struct dfs_args* args, struct dfs_config* conf) {
    Int N = LEN_LIST(args -> neighbors);
    Obj stack = NEW_PLIST(T_PLIST_CYC, N * 2);

    Int stack_size = 1;

    AssPlist(stack, 1, INTOBJ_INT(start));

    if (!iter_loop(stack, stack_size, args, conf)) return false;

    if (conf -> forest) {
      for (Int v = 1; v <= LEN_LIST(args -> neighbors); v++) {
        bool visited = INT_INTOBJ(ELM_LIST(args -> preorder, v)) != -1;

        if (!visited) {
          ASS_LIST(args -> parents, v, INTOBJ_INT(v));
          CHANGED_BAG(args -> record);
          AssPlist(stack, 1, INTOBJ_INT(v));

          if (!iter_loop(stack, 1, args, conf)) return false;
        }
      }
    }

    return true;
}

bool iter_loop(Obj stack, Int stack_size, struct dfs_args* args,
               struct dfs_config* conf) {
    while (stack_size > 0) {
        Int current = INT_INTOBJ(STACK_POP(stack, stack_size));

        if (current < 0) {
            Int bt_on = current * -1;
            Int parent = INT_INTOBJ(ELM_LIST(args -> parents, bt_on));
            ON_BACKTRACK(bt_on, parent, args);
            continue;
        } else if (INT_INTOBJ(ELM_LIST(args->preorder, current)) != -1) {
          continue;
        }

        ON_PREORDER(args, current);  // and push backtrack node
        STACK_PUSH(stack, stack_size, INTOBJ_INT(current * -1));

        Obj succ = ELM_PLIST(args -> neighbors, current);

        for (Int i = LEN_LIST(succ); i > 0; i--) {
            Int v = INT_INTOBJ(ELM_LIST(succ, i));
            bool visited = INT_INTOBJ(ELM_PLIST(args -> preorder, v)) != -1;
            bool backtracked = INT_INTOBJ(ELM_PLIST(args -> postorder,
                                                    v)) != -1;
            bool revisit = (conf -> revisit && backtracked);

            if (!visited || revisit) {
                if (revisit) ASS_LIST(args -> preorder, v, INTOBJ_INT(-1));
                ON_ADD_SUCC(current, v, i, args);
                STACK_PUSH(stack, stack_size, INTOBJ_INT(v));
            } else {
              ANCESTOR_CROSS(current, v, backtracked, args);
            }
        }
    }
    return true;
}

// Recursive DFS

bool ExecuteDFSRec(Int current, Int parent, Int idx, struct dfs_args* args) {
  if (idx == PREORDER_IDX) {  // visit current
    ON_PREORDER(args, current);
    // Start recursing on successors
    return ExecuteDFSRec(current, parent, idx + 1, args);
  }

  Obj succ = ELM_PLIST(args -> neighbors, current);

  if (idx > LEN_LIST(succ)) {  // Backtrack on current (all successors explored)
      ON_BACKTRACK(current, parent, args);

      Int out_neighbor = INT_INTOBJ(ELM_PLIST(args -> edge, current));
      Int parents_parent = INT_INTOBJ(ELM_PLIST(args -> parents, parent));

      if (parent == current) return true;  // At root

      return ExecuteDFSRec(parent, parents_parent, out_neighbor + 1, args);
  } else {
      Int v = INT_INTOBJ(ELM_LIST(succ, idx));
      bool visited = INT_INTOBJ(ELM_PLIST(args -> preorder, v)) != -1;
      bool backtracked = INT_INTOBJ(ELM_PLIST(args -> postorder, v)) != -1;

      if (!visited) {
        ON_ADD_SUCC(current, v, idx, args);
        return ExecuteDFSRec(v, current, 0, args);
      } else {
        ANCESTOR_CROSS(current, v, backtracked, args);
        return ExecuteDFSRec(current, parent, idx + 1, args);  // Skip
      }
  }
}


Obj FuncExecuteDFS_C(Obj self, Obj args) {
  DIGRAPHS_ASSERT(LEN_PLIST(args) == 7);
  Obj record        = ELM_PLIST(args, 1);
  Obj config         = ElmPRec(record, RNamName("config"));
  Obj data          = ELM_PLIST(args, 2);
  Obj start         = ELM_PLIST(args, 3);
  Obj PreorderFunc  = ELM_PLIST(args, 4);
  Obj PostorderFunc = ELM_PLIST(args, 5);
  Obj AncestorFunc  = ELM_PLIST(args, 6);
  Obj CrossFunc     = ELM_PLIST(args, 7);

  DIGRAPHS_ASSERT(IS_PREC(record));
  DIGRAPHS_ASSERT(IS_INTOBJ(start));

  PreorderFunc = !IS_FUNC(PreorderFunc) ? Fail : PreorderFunc;
  PostorderFunc = !IS_FUNC(PostorderFunc) ? Fail : PostorderFunc;
  AncestorFunc = !IS_FUNC(AncestorFunc) ? Fail : AncestorFunc;
  CrossFunc = !IS_FUNC(CrossFunc) ? Fail : CrossFunc;

  Obj D = ElmPRec(record, RNamName("graph"));
  Obj outNeighbours = FuncOutNeighbours(self, D);
  Int N = DigraphNrVertices(D);

  if (INT_INTOBJ(start) > N) {
    ErrorQuit(
        "the third argument <start> must be a vertex in your graph,", 0L, 0L);
  }

  Int RNamStop    = RNamName("stop");

  if (ElmPRec(record, RNamStop) == True) return record;

  Int preorder_num  = 0;
  Int postorder_num = 0;

  struct dfs_args rec_args = {
    .record = record,
    .preorder_num = &preorder_num,
    .postorder_num = &postorder_num,
    .parents = ElmPRec(record, RNamName("parents")),
    .postorder = ElmPRec(record, RNamName("postorder")),
    .preorder = ElmPRec(record, RNamName("preorder")),
    .edge = ElmPRec(record, RNamName("edge")),
    .neighbors = outNeighbours, .data = data,
    .PreorderFunc = PreorderFunc, .PostorderFunc = PostorderFunc,
    .AncestorFunc = AncestorFunc, .CrossFunc = CrossFunc,
    .RNamChild = RNamName("child"), .RNamCurrent = RNamName("current"),
    .RNamStop = RNamStop, .CallPreorder = PreorderFunc != Fail,
    .CallPostorder = PostorderFunc != Fail,
    .CallAncestor = AncestorFunc != Fail, .CallCross = CrossFunc != Fail};

  ASS_LIST(rec_args.parents, INT_INTOBJ(start), start);

  Int current = INT_INTOBJ(start);

  struct dfs_config dfs_conf = {0};
  parseConfig(&dfs_conf, config);

  if (dfs_conf.iter || dfs_conf.revisit) {
      ExecuteDFSIter(current, &rec_args, &dfs_conf);
  } else {
    if (ElmPRec(config, RNamName("forest")) == True) {
      for (Int i = 1; i <= N; i++) {
        bool visited = INT_INTOBJ(ELM_PLIST(rec_args.preorder, i)) != -1;
        if (!visited) {
          ASS_LIST(rec_args.parents, i, INTOBJ_INT(i));
          ExecuteDFSRec(i, i, PREORDER_IDX, &rec_args);
        }
      }
    } else {
      ExecuteDFSRec(current, current, PREORDER_IDX, &rec_args);
    }
  }

  CHANGED_BAG(record);
  return record;
}
