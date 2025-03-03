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

#include <stdbool.h>  // for false, true, bool
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
      CHANGED_BAG(record);
      return true;
    }
    return false;
}

/* Obj FuncExecuteDFS_C(Obj self, Obj args) { */
/*   DIGRAPHS_ASSERT(LEN_PLIST(args) == 7); */
/*   Obj record        = ELM_PLIST(args, 1); */
/*   Obj data          = ELM_PLIST(args, 2); */
/*   Obj start         = ELM_PLIST(args, 3); */
/*   Obj PreorderFunc  = ELM_PLIST(args, 4); */
/*   Obj PostOrderFunc = ELM_PLIST(args, 5); */
/*   Obj AncestorFunc  = ELM_PLIST(args, 6); */
/*   Obj CrossFunc     = ELM_PLIST(args, 7); */

/*   DIGRAPHS_ASSERT(IS_PREC(record)); */
/*   DIGRAPHS_ASSERT(IS_INTOBJ(start)); */
/*   // DIGRAPHS_ASSERT(NARG_FUNC(PreorderFunc) == 2); */
/*   DIGRAPHS_ASSERT(IS_FUNC(PreorderFunc)); */
/*   DIGRAPHS_ASSERT(IS_FUNC(PostOrderFunc)); */
/*   // DIGRAPHS_ASSERT(NARG_FUNC(PostOrderFunc) == 2); */
/*   DIGRAPHS_ASSERT(IS_FUNC(AncestorFunc)); */
/*   // DIGRAPHS_ASSERT(NARG_FUNC(AncestorFunc) == 2); */
/*   DIGRAPHS_ASSERT(IS_FUNC(CrossFunc)); */
/*   // DIGRAPHS_ASSERT(NARG_FUNC(CrossFunc) == 2); */

/*   Obj D = ElmPRec(record, RNamName("graph")); */
/*   Int N = DigraphNrVertices(D); */

/*   if (INT_INTOBJ(start) > N) { */
/*     ErrorQuit( */
/*         "the third argument <start> must be a vertex in your graph,", 0L, 0L); */
/*   } */
/*   Int top   = 0; // referencing the last element in stack */
/*   // Length of stack fixed, since no vertices are added to it more than once */
/*   Obj stack = NEW_PLIST(T_PLIST_CYC, N * 2); */

/*   AssPlist(stack, ++top, start); */

/*   UInt preorder_num  = 1; */
/*   UInt postorder_num = 0; */

/*   Int current = 0; */

/*   Obj parent    = ElmPRec(record, RNamName("parent")); */
/*   Obj postorder = ElmPRec(record, RNamName("postorder")); */
/*   Obj preorder  = ElmPRec(record, RNamName("preorder")); */
/*   // Obj edge      = ElmPRec(record, RNamName("edge")); */

/*   // FIXME edge needs to be off by 1, so that the first entry is bound */
/*   // FIXME use hash maps for parent, postorder, preorder, and edge */

/*   ASS_LIST(parent, INT_INTOBJ(start), start); */

/*   Obj neighbors = FuncOutNeighbours(self, D); */
/*   DIGRAPHS_ASSERT(IS_PLIST(neighbors)); */

/*   Int RNamChild   = RNamName("child"); */
/*   Int RNamCurrent = RNamName("current"); */
/*   Int RNamStop    = RNamName("stop"); */

/*   if (ElmPRec(record, RNamStop) == True) return record; */

/*   while (top > 0) { */
/*       // visit current */
/*       current = INT_INTOBJ(ELM_PLIST(stack, top--)); // an unvisited node */
/*       if (current < 0) { */
/*           Int child = current * -1; */
/*           // backtracking on current */
/*           AssPRec(record, RNamChild, INTOBJ_INT(child)); */
/*           AssPRec(record, RNamCurrent, ELM_PLIST(parent, child)); */
/*           ASS_LIST(postorder, child, INTOBJ_INT(++postorder_num)); */
/*           CHANGED_BAG(record); */
/*           if (CallCheckStop(PostOrderFunc, RNamStop, record, data)) { */
/*             return record; */
/*           } */
/*           continue; */
/*       } */

/*       if (INT_INTOBJ(ELM_PLIST(preorder, current)) != -1) continue; */

/*       // otherwise, visit this node */

/*       AssPRec(record, RNamCurrent, INTOBJ_INT(current)); */
/*       ASS_LIST(preorder, current, INTOBJ_INT(preorder_num++)); */
/*       CHANGED_BAG(record); */

/*       if (CallCheckStop(PreorderFunc, RNamStop, record, data)) { */
/*         return record; */
/*       } */

/*       // Add back to the stack for backtracking */
/*       ASS_LIST(stack, ++top, INTOBJ_INT(current * -1)); */
/*       CHANGED_BAG(record); */

/*       Obj succ = ELM_PLIST(neighbors, current); */
/*       for (UInt j = LEN_LIST(succ); j >= 1; j--) { */
/*         // Push so that the top of the stack is the first vertex in succ */
/*         UInt v = INT_INTOBJ(ELM_LIST(succ, j)); */
/*         bool visited = INT_INTOBJ(ELM_PLIST(preorder, v)) != -1; */
/*         AssPRec(record, RNamChild, INTOBJ_INT(v)); */
/*         CHANGED_BAG(record); */

/*         if (!visited) { // v is unvisited */
/*           ASS_LIST(parent, v, INTOBJ_INT(current)); */
/*           ASS_LIST(stack, ++top, INTOBJ_INT(v)); */
/*         } */
/*         else { // v is either visited, or in the stack to be visited */
/*           // If v was visited prior, but has not been backtracked on */
/*           bool backtracked = INT_INTOBJ(ELM_PLIST(postorder, v)) != -1; */
/*           if (!backtracked) { // Back edge */
/*             if (CallCheckStop(AncestorFunc, RNamStop, record, data)) { */
/*               return record; */
/*             } */
/*           } */
/*           // v has been visited and backtracked on */
/*           else { */
/*             if (CallCheckStop(CrossFunc, RNamStop, record, data)) { */
/*               return record; */
/*             } */
/*           } */
/*         } */
/*       } */
/*   } */
/*   return record; */
/* } */


struct dfs_args {
  Int RNamChild;
  Int RNamCurrent;
  Int RNamStop;

  Obj record;
  UInt* preorder_num;
  UInt* postorder_num;

  Obj parent;
  Obj postorder;
  Obj preorder;

  Obj neighbors;

  Obj data;
  Obj PreorderFunc;
  Obj PostorderFunc;
  Obj AncestorFunc;
  Obj CrossFunc;
};

bool ExecuteDFSRec(UInt current, struct dfs_args* args) {
  AssPRec(args -> record, args -> RNamCurrent, INTOBJ_INT(current));
  ASS_LIST(args -> preorder, current, INTOBJ_INT((*args -> preorder_num)++));
  CHANGED_BAG(args -> record);

  if (CallCheckStop(args -> PreorderFunc, args -> RNamStop, args -> record, args -> data)) {
    return args -> record;
  }

  Obj succ = ELM_PLIST(args -> neighbors, current);
  for (UInt j = 1; j <= LEN_LIST(succ); j++) {
    UInt v = INT_INTOBJ(ELM_LIST(succ, j));
    bool visited = INT_INTOBJ(ELM_PLIST(args -> preorder, v)) != -1;
    AssPRec(args -> record, args -> RNamChild, INTOBJ_INT(v));
    CHANGED_BAG(args -> record);

    if (!visited) {
      ASS_LIST(args -> parent, v, INTOBJ_INT(current));
      bool rec_res = ExecuteDFSRec(v, args);
      if (!rec_res) return false; // Stop
    }
    else {
      bool backtracked = INT_INTOBJ(ELM_PLIST(args -> postorder, v)) != -1;
      if (!backtracked) { // Back edge
        if (CallCheckStop(args -> AncestorFunc, args -> RNamStop, args -> record, args -> data)) {
          return false;
        }
      }
      // v has been visited and backtracked on
      else {
        if (CallCheckStop(args -> CrossFunc, args -> RNamStop, args -> record, args -> data)) {
          return false;
        }
      }
    }
  }

  // backtracking on current
  AssPRec(args -> record, args -> RNamChild, INTOBJ_INT(current));
  AssPRec(args -> record, args -> RNamCurrent, ELM_PLIST(args -> parent, current));
  ASS_LIST(args -> postorder, current, INTOBJ_INT(++(*args -> postorder_num)));
  CHANGED_BAG(args -> record);
  if (CallCheckStop(args -> PostorderFunc, args -> RNamStop, args -> record, args -> data)) {
    return false; // Stop execution
  }
  return true; // Continue
}

Obj FuncExecuteDFS_C(Obj self, Obj args) {
  DIGRAPHS_ASSERT(LEN_PLIST(args) == 7);
  Obj record        = ELM_PLIST(args, 1);
  Obj data          = ELM_PLIST(args, 2);
  Obj start         = ELM_PLIST(args, 3);
  Obj PreorderFunc  = ELM_PLIST(args, 4);
  Obj PostorderFunc = ELM_PLIST(args, 5);
  Obj AncestorFunc  = ELM_PLIST(args, 6);
  Obj CrossFunc     = ELM_PLIST(args, 7);

  DIGRAPHS_ASSERT(IS_PREC(record));
  DIGRAPHS_ASSERT(IS_INTOBJ(start));
  // DIGRAPHS_ASSERT(NARG_FUNC(PreorderFunc) == 2);
  DIGRAPHS_ASSERT(IS_FUNC(PreorderFunc));
  DIGRAPHS_ASSERT(IS_FUNC(PostorderFunc));
  // DIGRAPHS_ASSERT(NARG_FUNC(PostOrderFunc) == 2);
  DIGRAPHS_ASSERT(IS_FUNC(AncestorFunc));
  // DIGRAPHS_ASSERT(NARG_FUNC(AncestorFunc) == 2);
  DIGRAPHS_ASSERT(IS_FUNC(CrossFunc));
  // DIGRAPHS_ASSERT(NARG_FUNC(CrossFunc) == 2);

  Obj D = ElmPRec(record, RNamName("graph"));
  Int N = DigraphNrVertices(D);

  if (INT_INTOBJ(start) > N) {
    ErrorQuit(
        "the third argument <start> must be a vertex in your graph,", 0L, 0L);
  }

  Int RNamStop    = RNamName("stop");

  if (ElmPRec(record, RNamStop) == True) return record;

  struct dfs_args* rec_args = (struct dfs_args*) safe_malloc(sizeof(struct dfs_args));

  UInt preorder_num  = 1;
  UInt postorder_num = 0;

  rec_args -> RNamChild = RNamName("child");
  rec_args -> RNamCurrent = RNamName("current");
  rec_args -> RNamStop = RNamStop;
  rec_args -> record = record;
  rec_args -> preorder_num = &preorder_num;
  rec_args -> postorder_num = &postorder_num;
  rec_args -> parent = ElmPRec(record, RNamName("parent"));
  rec_args -> postorder = ElmPRec(record, RNamName("postorder"));
  rec_args -> preorder = ElmPRec(record, RNamName("preorder"));
  rec_args -> neighbors = FuncOutNeighbours(self, D);
  rec_args -> data = data;
  rec_args -> PreorderFunc = PreorderFunc;
  rec_args -> PostorderFunc = PostorderFunc;
  rec_args -> CrossFunc = CrossFunc;
  rec_args -> AncestorFunc = AncestorFunc;

  ASS_LIST(rec_args -> parent, INT_INTOBJ(start), start);

  DIGRAPHS_ASSERT(IS_PLIST(rec_args -> neighbors));
  UInt current = INT_INTOBJ(start);
  ExecuteDFSRec(current, rec_args);

  free(rec_args);
  return record;

}
