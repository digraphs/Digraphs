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

Obj ExecuteDFS(Obj self, Obj args) {
  if (LEN_PLIST(args) != 7) {
    ErrorQuit("there must be 7 arguments, found %d,", LEN_PLIST(args), 0L);
  }
  Obj record = ELM_PLIST(args, 1);
  DIGRAPHS_ASSERT(IS_PREC(record));
  Obj data  = ELM_PLIST(args, 2);
  Obj start = ELM_PLIST(args, 3);
  DIGRAPHS_ASSERT(IS_INTOBJ(start));
  Obj PreorderFunc = ELM_PLIST(args, 4);
  DIGRAPHS_ASSERT(IS_FUNC(PreorderFunc));
  DIGRAPHS_ASSERT(NARG_FUNC(PreorderFunc) == 2);
  Obj PostOrderFunc = ELM_PLIST(args, 5);
  DIGRAPHS_ASSERT(IS_FUNC(PostOrderFunc));
  // DIGRAPHS_ASSERT(NARG_FUNC(PostOrderFunc) == 2);
  Obj AncestorFunc = ELM_PLIST(args, 6);
  DIGRAPHS_ASSERT(IS_FUNC(AncestorFunc));
  DIGRAPHS_ASSERT(NARG_FUNC(AncestorFunc) == 2);
  Obj CrossFunc = ELM_PLIST(args, 7);
  DIGRAPHS_ASSERT(IS_FUNC(CrossFunc));
  // DIGRAPHS_ASSERT(NARG_FUNC(CrossFunc) == 2);

  Obj D = ElmPRec(record, RNamName("graph"));
  Int N = DigraphNrVertices(D);

  Int top   = 0;
  Obj stack = NEW_PLIST(T_PLIST_CYC, N);
  AssPlist(stack, ++top, start);

  UInt preorder_num  = 0;
  UInt postorder_num = 0;

  Int current = 0;

  Obj parent    = ElmPRec(record, RNamName("parent"));
  Obj postorder = ElmPRec(record, RNamName("postorder"));
  Obj preorder  = ElmPRec(record, RNamName("preorder"));

  DIGRAPHS_ASSERT(LEN_PLIST(parent) == N);
  DIGRAPHS_ASSERT(LEN_PLIST(postorder) == N);
  DIGRAPHS_ASSERT(LEN_PLIST(preorder) == N);

  SET_ELM_PLIST(parent, INT_INTOBJ(start), start);

  Obj neighbors = FuncOutNeighbours(self, D);
  DIGRAPHS_ASSERT(IS_PLIST(neighbors));

  Int RNamChild   = RNamName("child");
  Int RNamCurrent = RNamName("current");

  while (top > 0) {
    current = INT_INTOBJ(ELM_PLIST(stack, top--));
    DIGRAPHS_ASSERT(current != 0);
    if (current < 0) {
      Int child = -1 * current;
      AssPRec(record, RNamChild, INTOBJ_INT(child));
      AssPRec(record, RNamCurrent, ELM_PLIST(parent, child));
      // CALL_2ARGS(PostOrderFunc, record, data);
      SET_ELM_PLIST(postorder, child, INTOBJ_INT(++postorder_num));
      CHANGED_BAG(record);
      continue;
    } else if (INT_INTOBJ(ELM_PLIST(preorder, current)) > 0) {
      continue;
    } else {
      AssPRec(record, RNamCurrent, INTOBJ_INT(current));
      CALL_2ARGS(PreorderFunc, record, data);
      SET_ELM_PLIST(preorder, current, INTOBJ_INT(++preorder_num));
      CHANGED_BAG(record);
      AssPlist(stack, ++top, INTOBJ_INT(-1 * current));
    }

    Obj succ = ELM_PLIST(neighbors, current);
    for (UInt j = 0; j < LEN_LIST(succ); ++j) {
      UInt v = INT_INTOBJ(ELM_LIST(succ, LEN_LIST(succ) - j));
      AssPRec(record, RNamChild, INTOBJ_INT(v));
      if (INT_INTOBJ(ELM_PLIST(preorder, v)) == -1) {
        SET_ELM_PLIST(parent, v, INTOBJ_INT(current));
        CHANGED_BAG(record);
        AssPlist(stack, ++top, INTOBJ_INT(v));
      } else if (INT_INTOBJ(ELM_PLIST(postorder, v)) == -1) {
        CALL_2ARGS(AncestorFunc, record, data);
      } else if (INT_INTOBJ(ELM_PLIST(preorder, v))
                 < INT_INTOBJ(ELM_PLIST(preorder, current))) {
        // CALL_2ARGS(CrossFunc, record, data);
      }
    }
  }
  // AssPRec(record, RNamName("current"), INTOBJ_INT(current));
  return record;
}

