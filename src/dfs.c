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

// Datastructures Functions TODO use GAP level functions
extern Obj DS_Hash_SetValue;
extern Obj DS_Hash_Contains;
extern Obj DS_Hash_Value;
extern Obj IsBound;
extern Obj DS_Hash_Reserve;
extern Obj DS_Hash_Delete;

// Macros

#define HASH_SET(map, key, val) \
  ASS_LIST(map, key, val)
  // CALL_3ARGS(DS_Hash_SetValue, map, key, val)

#define HASH_GET(map, key) \
  ELM_PLIST(map, key)
  // CALL_2ARGS(DS_Hash_Value, map, key)

#define HASH_CONTAINS(map, key) \
  INT_INTOBJ(ELM_PLIST(map, key)) != -1
  // CALL_2ARGS(DS_Hash_Contains, map, key) == True

#define HASH_DELETE(map, key) \
  HASH_SET(map, key, INTOBJ_INT(-1))
  /* CALL_2ARGS(DS_Hash_Delete, map, key) */

// Global Variables

// Extreme examples are on the pull request #459

bool CallCheckStop(Obj f, Int RNamStop, Obj record, Obj data) {
    CALL_2ARGS(f, record, data);
    if (ElmPRec(record, RNamStop) == True) {
      // CHANGED_BAG(record);
      return true;
    }
    return false;
}

bool ExecuteDFSRec(UInt current, UInt prev, struct dfs_args* args,
                   struct dfs_rec_flags* flags) {
  Int cur_preorder_num = *args -> preorder_num;
  HASH_SET(args -> preorder, current,
           INTOBJ_INT((*args -> preorder_num)++));
  // args -> visited[current] = true;
  AssPRec(args -> record, args -> RNamCurrent, INTOBJ_INT(current));

  if (args -> CallPreorder &&
      CallCheckStop(args -> PreorderFunc, args -> RNamStop, args -> record,
                    args -> data)) {
    return args -> record;
  }

  Obj succ = ELM_PLIST(args -> neighbors, current);
  for (Int j = 1; j <= LEN_LIST(succ); j++) {
    UInt v = INT_INTOBJ(ELM_LIST(succ, j));

    if (flags -> revisit &&
        INT_INTOBJ(HASH_GET(args -> postorder, v)) != -1) {
        // args -> visited[v] = false;
        HASH_DELETE(args -> preorder, v);
    }

    bool visited = HASH_GET(args -> preorder, v) != INTOBJ_INT(-1);

    if (!visited) {
      HASH_SET(args -> parents, v, INTOBJ_INT(current));
      HASH_SET(args -> edge, v, INTOBJ_INT(j));
      bool rec_res = ExecuteDFSRec(v, current, args, flags);
      if (!rec_res) return false;  // Stop
    } else {
      AssPRec(args -> record, args -> RNamChild, INTOBJ_INT(v));
      // CHANGED_BAG(args -> record);
      if (args -> CallAncestor || args -> CallCross) {
        bool backtracked = INT_INTOBJ(HASH_GET(args -> postorder, v)) != -1;
        if (args -> CallAncestor && !backtracked) {  // Back edge
          if (CallCheckStop(args -> AncestorFunc, args -> RNamStop,
                            args -> record, args -> data)) {
            return false;
          }
        } else if (args -> CallCross && backtracked &&
                   INT_INTOBJ(HASH_GET(args -> preorder, v))
                  < cur_preorder_num) {
          // v was visited before current
          if (CallCheckStop(args -> CrossFunc, args -> RNamStop, args -> record,
                            args -> data)) {
            return false;
          }
        }
      }
    }
  }

  // backtracking on current
  AssPRec(args -> record, args -> RNamChild, INTOBJ_INT(current));
  AssPRec(args -> record, args -> RNamCurrent, INTOBJ_INT(prev));
  HASH_SET(args -> postorder, current,
           INTOBJ_INT(++(*args -> postorder_num)));
  /* CHANGED_BAG(args -> record); */
  if (args -> CallPostorder &&
      CallCheckStop(args -> PostorderFunc, args -> RNamStop, args -> record,
                    args -> data)) {
    return false;  // Stop execution
  }
  return true;  // Continue
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
  Int N = DigraphNrVertices(D);

  if (INT_INTOBJ(start) > N) {
    ErrorQuit(
        "the third argument <start> must be a vertex in your graph,", 0L, 0L);
  }

  Int RNamStop    = RNamName("stop");

  if (ElmPRec(record, RNamStop) == True) return record;

  UInt preorder_num  = 1;
  UInt postorder_num = 0;
  // bool* visited_boolarr = (bool*) safe_malloc((N + 1) * sizeof(bool));
  // bool* backtracked_boolarr = (bool*) safe_malloc((N + 1) * sizeof(bool));
  // memset(visited_boolarr, false, (N + 1) * sizeof(bool));
  // memset(backtracked_boolarr, false, (N + 1) * sizeof(bool));

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
    .neighbors = FuncOutNeighbours(self, D), .data = data,
    .PreorderFunc = PreorderFunc, .PostorderFunc = PostorderFunc,
    .AncestorFunc = AncestorFunc, .CrossFunc = CrossFunc,
    /* .visited = visited_boolarr, .backtracked = backtracked_boolarr, */
    .RNamChild = RNamName("child"), .RNamCurrent = RNamName("current"),
    .RNamStop = RNamStop, .CallPreorder = PreorderFunc != Fail,
    .CallPostorder = PostorderFunc != Fail,
    .CallAncestor = AncestorFunc != Fail, .CallCross = CrossFunc != Fail};

  // TODO handle errors with setting values in HashMaps

  HASH_SET(rec_args.parents, INT_INTOBJ(start), start);

  UInt current = INT_INTOBJ(start);
  ExecuteDFSRec(current, current, &rec_args, &dfs_flags);

  if (ElmPRec(flags, RNamName("forest")) == True) {
    for (int i = 1; i <= N; i++) {
      bool visited = INT_INTOBJ(HASH_GET(rec_args.preorder, i)) != -1;
      if (!visited) {
        HASH_SET(rec_args.parents, i, INTOBJ_INT(i));
        ExecuteDFSRec(i, i, &rec_args, &dfs_flags);
      }
    }
  }

  CHANGED_BAG(record);
  return record;
}
