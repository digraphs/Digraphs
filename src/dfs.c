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

/*   // Tracks whether a vertex is visited, or in the stack to be visited so that */
/*   // it does not get added more than once for different ancestors */
/*   BitArray* will_visit = new_bit_array(N); */
/*   set_bit_array(will_visit, INT_INTOBJ(start) - 1, true); */

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
/*             free_bit_array(will_visit); */
/*             return record; */
/*           } */
/*           continue; */
/*       } */
/*       // otherwise, visit this node */

/*       AssPRec(record, RNamCurrent, INTOBJ_INT(current)); */
/*       CHANGED_BAG(record); */
/*       ASS_LIST(preorder, current, INTOBJ_INT(preorder_num++)); */

/*       if (CallCheckStop(PreorderFunc, RNamStop, record, data)) { */
/*         free_bit_array(will_visit); */
/*         return record; */
/*       } */

/*       // Add back to the stack for backtracking */
/*       ASS_LIST(stack, ++top, INTOBJ_INT(current * -1)); */
/*       CHANGED_BAG(record); */

/*       Obj succ = ELM_PLIST(neighbors, current); */
/*       for (UInt j = LEN_LIST(succ); j >= 1; j--) { */
/*         // Push so that the top of the stack is the first vertex in succ */
/*         UInt v = INT_INTOBJ(ELM_LIST(succ, j)); */
/*         AssPRec(record, RNamChild, INTOBJ_INT(v)); */
/*         CHANGED_BAG(record); */
/*         if (!get_bit_array(will_visit, v - 1)) { // v is unvisited */
/*           ASS_LIST(parent, v, INTOBJ_INT(current)); */
/*           ASS_LIST(stack, ++top, INTOBJ_INT(v)); */
/*           set_bit_array(will_visit, v - 1, true); */
/*         } */
/*         else { // v is either visited, or in the stack to be visited */
/*           // If v was visited prior, but has not been backtracked on */
/*           bool visited = INT_INTOBJ(ELM_PLIST(preorder, v)) != -1; */
/*           bool backtracked = INT_INTOBJ(ELM_PLIST(postorder, v)) == -1; */
/*           if (visited && backtracked) { */
/*             if (CallCheckStop(AncestorFunc, RNamStop, record, data)) { */
/*               free_bit_array(will_visit); */
/*               return record; */
/*             } */
/*           } */
/*           // v has been visited and backtracked on */
/*           else if (visited) { */
/*             if (CallCheckStop(CrossFunc, RNamStop, record, data)) { */
/*               free_bit_array(will_visit); */
/*               return record; */
/*             } */
/*           } */
/*         } */
/*       } */
/*   } */
/*   free_bit_array(will_visit); */
/*   return record; */
/* } */
