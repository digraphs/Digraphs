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

#include "bitarray.h"
#include "digraphs-config.h"
#include "digraphs-debug.h"
#include "digraphs.h"
#include "safemalloc.h"

// Extreme examples are on the pull request #459

bool CallCheckStop(Obj f, Int RNamStop, Obj record, Obj data) {
    CALL_2ARGS(f, record, data);
    if (ElmPRec(record, RNamStop) == True) {
      return true;
    }
    return false;
}

bool ExecuteDFSRec(Int current, Int prev, Int idx, struct dfs_args* args,
                   struct dfs_rec_flags* flags) {
  if (idx == 1) {  // visit
    ASS_LIST(args -> preorder, current, INTOBJ_INT(++(*args -> preorder_num)));
    AssPRec(args -> record, args -> RNamCurrent, INTOBJ_INT(current));

    args -> visited[current] = true;

    if (args -> CallPreorder &&
        CallCheckStop(args -> PreorderFunc, args -> RNamStop, args -> record,
                      args -> data)) {
      return args -> record;
    }
  }

  Obj succ = ELM_PLIST(args -> neighbors, current);
  if (idx > LEN_LIST(succ)) {  // Backtrack on current (all successors explored)
      AssPRec(args -> record, args -> RNamChild, INTOBJ_INT(current));
      AssPRec(args -> record, args -> RNamCurrent, INTOBJ_INT(prev));
      args -> backtracked[current] = true;
      ASS_LIST(args -> postorder, current,
               INTOBJ_INT(++(*args -> postorder_num)));

      if (args -> CallPostorder &&
          CallCheckStop(args -> PostorderFunc, args -> RNamStop, args -> record,
                        args -> data)) {
        return false;  // Stop execution
      }
      Int out_neighbor = INT_INTOBJ(ELM_PLIST(args -> edge, current));
      Int parents_parent = INT_INTOBJ(ELM_PLIST(args -> parents, prev));

      if (prev == current) return true;  // At root

      return ExecuteDFSRec(prev, parents_parent, out_neighbor + 1, args, flags);
  } else {
    Int v = INT_INTOBJ(ELM_LIST(succ, idx));

    if (flags -> revisit && args -> backtracked[v]) {
        args -> visited[v] = false;
        ASS_LIST(args -> preorder, v, INTOBJ_INT(-1));
    }

    bool visited = args -> visited[v];

    if (!visited) {
      ASS_LIST(args -> parents, v, INTOBJ_INT(current));
      ASS_LIST(args -> edge, v, INTOBJ_INT(idx));
      return ExecuteDFSRec(v, current, 1, args, flags);
    } else {
      AssPRec(args -> record, args -> RNamChild, INTOBJ_INT(v));

      if (args -> CallAncestor || args -> CallCross) {
        bool backtracked = args -> backtracked[v];
        if (args -> CallAncestor && !backtracked) {  // Back edge
          if (CallCheckStop(args -> AncestorFunc, args -> RNamStop,
                            args -> record, args -> data)) {
            return false;
          }
        } else if (args -> CallCross && (backtracked &&
                   INT_INTOBJ(ELM_PLIST(args -> preorder, v))
                  < INT_INTOBJ(ELM_PLIST(args -> preorder, current)))) {
          // v was visited before current
          if (CallCheckStop(args -> CrossFunc, args -> RNamStop, args -> record,
                            args -> data)) {
            return false;
          }
        }
      }
      return ExecuteDFSRec(current, prev, idx + 1, args, flags);
    }
  }
}


Obj FuncExecuteDFS_C(Obj self, Obj args) {
  DIGRAPHS_ASSERT(LEN_PLIST(args) == 7);
  Obj record        = ELM_PLIST(args, 1);
  Obj flags         = ElmPRec(record, RNamName("config"));
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
  bool* visited_boolarr = (bool*) safe_malloc((N + 1) * sizeof(bool));
  bool* backtracked_boolarr = (bool*) safe_malloc((N + 1) * sizeof(bool));

  if (visited_boolarr == NULL || backtracked_boolarr == NULL) {
    ErrorQuit(
        "the given graph is too large for memory to be allocated", 0L, 0L);
  }
  memset(visited_boolarr, false, (N + 1) * sizeof(bool));
  memset(backtracked_boolarr, false, (N + 1) * sizeof(bool));

  struct dfs_rec_flags dfs_flags =
    {ElmPRec(flags, RNamName("revisit")) == True};

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
    .visited = visited_boolarr, .backtracked = backtracked_boolarr,
    .RNamChild = RNamName("child"), .RNamCurrent = RNamName("current"),
    .RNamStop = RNamStop, .CallPreorder = PreorderFunc != Fail,
    .CallPostorder = PostorderFunc != Fail,
    .CallAncestor = AncestorFunc != Fail, .CallCross = CrossFunc != Fail};

  ASS_LIST(rec_args.parents, INT_INTOBJ(start), start);

  Int current = INT_INTOBJ(start);
  Int init_idx = 1;
  ExecuteDFSRec(current, current, init_idx, &rec_args, &dfs_flags);

  if (ElmPRec(flags, RNamName("forest")) == True) {
    for (Int i = 1; i <= N; i++) {
      bool visited = rec_args.visited[i];
      if (!visited) {
        ASS_LIST(rec_args.parents, i, INTOBJ_INT(i));
        ExecuteDFSRec(i, i, 1, &rec_args, &dfs_flags);
      }
    }
  }

  free(rec_args.backtracked);
  free(rec_args.visited);

  CHANGED_BAG(record);
  return record;
}
