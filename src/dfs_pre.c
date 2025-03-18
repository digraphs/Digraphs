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

#include "digraphs-config.h"
#include "digraphs-debug.h"
#include "digraphs.h"

// Extreme examples are on the pull request #459

/* Obj ExecuteDFS(Obj self, Obj args) { */
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
/*   Int top   = 0; */
/*   Obj stack = NEW_PLIST(T_PLIST_CYC, 0); */
/*   AssPlist(stack, ++top, start); */

/*   UInt preorder_num  = 0; */
/*   UInt postorder_num = 0; */

/*   // current vertex being visited */
/*   Int current = 0; */

/*   // parent of each vertex visited stored */
/*   Obj parent    = ElmPRec(record, RNamName("parent")); */
/*   // postorder number (backtrack order) */
/*   Obj postorder = ElmPRec(record, RNamName("postorder")); */
/*   // preorder number (order visited) */
/*   Obj preorder  = ElmPRec(record, RNamName("preorder")); */
/*   Obj edge      = ElmPRec(record, RNamName("edge")); // ??? */

/*   // FIXME edge needs to be off by 1, so that the first entry is bound */
/*   // FIXME use hash maps for parent, postorder, preorder, and edge */

/*   DIGRAPHS_ASSERT(LEN_PLIST(parent) == 1); */
/*   DIGRAPHS_ASSERT(LEN_PLIST(postorder) == 1); */
/*   DIGRAPHS_ASSERT(LEN_PLIST(preorder) == 1); */
/*   DIGRAPHS_ASSERT(LEN_PLIST(edge) == 1); */

/*   ASS_LIST(parent, INT_INTOBJ(start), start); */

/*   Obj neighbors = FuncOutNeighbours(self, D); */
/*   DIGRAPHS_ASSERT(IS_PLIST(neighbors)); */

/*   Int RNamChild   = RNamName("child"); */
/*   Int RNamCurrent = RNamName("current"); // ?? */
/*   Int RNamStop    = RNamName("stop"); */

/*   // PostOrderFunc :: called when a vertex has no more unvisited children */

/*   // PreOrderFunc :: When a vertex is first visited */

/*   // AncestorFunc :: When current, child is an edge and */
/*   // child is an ancestor of current */

/*   // TODO why does the record need child or current */
/*   while (top > 0) { // top init 1 */
/*     if (ElmPRec(record, RNamStop) == True) { */
/*       break; */
/*     } */
/*     current = INT_INTOBJ(ELM_PLIST(stack, top--)); // current init start (stack init [start]) */
/*     DIGRAPHS_ASSERT(current != 0); */
/*     if (current < 0) { // No more unvisited children, backtrack (postorder) */
/*       Int child = -1 * current; // positive vertex number of node to backtrack from */
/*       AssPRec(record, RNamChild, INTOBJ_INT(child)); */
/*       AssPRec(record, RNamCurrent, ELM_PLIST(parent, child)); // record current = parent of backtracked node */
/*       CALL_2ARGS(PostOrderFunc, record, data); */
/*       ASS_LIST(postorder, child, INTOBJ_INT(++postorder_num)); */
/*       CHANGED_BAG(record); */
/*       continue; // backtracked, < 0 indicates backtrack from this node */
/*     } else if (current <= LEN_PLIST(preorder) */
/*                && ELM_PLIST(preorder, current) != 0) { */
/*       continue; // TODO is this needed when we check this before adding to the stack */
/*     } else { // Vertex first visit (preorder) */
/*       AssPRec(record, RNamCurrent, INTOBJ_INT(current)); // visit this node */
/*       CALL_2ARGS(PreorderFunc, record, data); */
/*       ASS_LIST(preorder, current, INTOBJ_INT(++preorder_num)); */
/*       CHANGED_BAG(record); */
/*       ASS_LIST(stack, ++top, INTOBJ_INT(-1 * current)); */
/*     } */

/*     if (ElmPRec(record, RNamStop) == True) { */
/*       break; */
/*     } */

/*     Obj succ = ELM_PLIST(neighbors, current); */
/*     for (UInt j = 0; j < LEN_LIST(succ); ++j) { */
/*       UInt v = INT_INTOBJ(ELM_LIST(succ, LEN_LIST(succ) - j)); */
/*       AssPRec(record, RNamChild, INTOBJ_INT(v)); */
/*       if (v > LEN_PLIST(preorder) || ELM_PLIST(preorder, v) == 0) { // unvisited */
/*         ASS_LIST(parent, v, INTOBJ_INT(current)); */
/*         ASS_LIST(edge, v, INTOBJ_INT(LEN_LIST(succ) - j)); */
// edge is a list of the index in neighbours for each child when they are visited
/*         CHANGED_BAG(record); */
/*         ASS_LIST(stack, ++top, INTOBJ_INT(v)); */
/*       } else if (v > LEN_PLIST(postorder) || ELM_PLIST(postorder, v) == 0) { */
/*         CALL_2ARGS(AncestorFunc, record, data); */
/*       } else if (INT_INTOBJ(ELM_PLIST(preorder, v)) */
/*                  < INT_INTOBJ(ELM_PLIST(preorder, current))) { */
/*         CALL_2ARGS(CrossFunc, record, data); */
/*       } */
/*       if (ElmPRec(record, RNamStop) == True) { // Functions can set this */
/*         break; */
/*       } */
/*     } */
/*   } */
/*   return record; */
/* } */






          /*   AncestorFunc is called when a child of an */
          /*   edge has been visited prior, and has not */
          /*   been backtracked on yet */

          /* CrossFunc is called for an edge (current, child [v]) */
          /* without any descendent ancestor connection, */
          /* so when child has been visited before (with */
          /* a different parent) */


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
/*   Int top   = 0; */
/*   Obj stack = NEW_PLIST(T_PLIST_CYC, 0); */
/*   AssPlist(stack, ++top, start); */

/*   UInt preorder_num  = 0; */
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

/*   while (top > 0) { */
/*     if (ElmPRec(record, RNamStop) == True) { */
/*       break; */
/*     } */
/*     current = INT_INTOBJ(ELM_PLIST(stack, top--)); */
/*     DIGRAPHS_ASSERT(current != 0); */
/*     if (current < 0) { */
/*       Int child = -1 * current; */
/*       AssPRec(record, RNamChild, INTOBJ_INT(child)); */
/*       AssPRec(record, RNamCurrent, ELM_PLIST(parent, child)); */
/*       CALL_2ARGS(PostOrderFunc, record, data); */
/*       ASS_LIST(postorder, child, INTOBJ_INT(++postorder_num)); */
/*       CHANGED_BAG(record); */
/*       continue; */
/*     } else if (current <= LEN_PLIST(preorder) */
/*                && INT_INTOBJ(ELM_PLIST(preorder, current)) != -1) { */
/*       continue; */
/*     } else { */
/*       AssPRec(record, RNamCurrent, INTOBJ_INT(current)); */
/*       CALL_2ARGS(PreorderFunc, record, data); */
/*       ASS_LIST(preorder, current, INTOBJ_INT(++preorder_num)); */
/*       CHANGED_BAG(record); */
/*       ASS_LIST(stack, ++top, INTOBJ_INT(-1 * current)); */
/*     } */

/*     if (ElmPRec(record, RNamStop) == True) { */
/*       break; */
/*     } */

/*     Obj succ = ELM_PLIST(neighbors, current); */
/*     for (UInt j = 0; j < LEN_LIST(succ); ++j) { */
/*       UInt v = INT_INTOBJ(ELM_LIST(succ, LEN_LIST(succ) - j)); */
/*       AssPRec(record, RNamChild, INTOBJ_INT(v)); */
/*       if (v > LEN_PLIST(preorder) || INT_INTOBJ(ELM_PLIST(preorder, v)) == -1) { */
/*         ASS_LIST(parent, v, INTOBJ_INT(current)); */
/*         // ASS_LIST(edge, v, INTOBJ_INT(LEN_LIST(succ) - j)); */
/*         CHANGED_BAG(record); */
/*         ASS_LIST(stack, ++top, INTOBJ_INT(v)); */
/*       } else if (v > LEN_PLIST(postorder) || INT_INTOBJ(ELM_PLIST(postorder, v)) == -1) { */
/*         CALL_2ARGS(AncestorFunc, record, data); */
/*       } else if (INT_INTOBJ(ELM_PLIST(preorder, v)) */
/*                  < INT_INTOBJ(ELM_PLIST(preorder, current))) { */
/*         CALL_2ARGS(CrossFunc, record, data); */
/*       } */
/*       if (ElmPRec(record, RNamStop) == True) { */
/*         break; */
/*       } */
/*     } */
/*   } */
/*   return record; */
/* } */
