/*******************************************************************************
**
*A  dfs.h                  GAP package Digraphs               Lea Racine
**                                                            James Mitchell
**
**  Copyright (C) 2014-21 - Julius Jonusas, James Mitchell, Michael Torpey,
**  Wilf A. Wilson et al.
**
**  This file is free software, see the digraphs/LICENSE.
**
*******************************************************************************/

#ifndef DIGRAPHS_SRC_DFS_H_
#define DIGRAPHS_SRC_DFS_H_

#include <stdbool.h>  // for false, true, bool
// GAP headers
#include "gap-includes.h"  // for Obj, Int

#include "bitarray.h"

bool CallCheckStop(Obj f, Int RNamStop, Obj record, Obj data);

struct dfs_args {
  Obj record;
  UInt* preorder_num;
  UInt* postorder_num;

  Obj parents;
  Obj postorder;
  Obj preorder;
  Obj edge;

  Obj neighbors;

  Obj data;
  Obj PreorderFunc;
  Obj PostorderFunc;
  Obj AncestorFunc;
  Obj CrossFunc;

  // Checking if visited from a bit array is faster for large digraphs than
  // using the preorder HashMap
  bool* visited;     // Using bool* rather than bitarray for more than
                     // 16 bit vertex counts
  bool* backtracked;

  Int RNamChild;
  Int RNamCurrent;
  Int RNamStop;

  bool CallPreorder;
  bool CallPostorder;
  bool CallAncestor;
  bool CallCross;
};

struct dfs_rec_flags {
  bool revisit;
};

bool ExecuteDFSRec(UInt current, UInt prev, struct dfs_args* args,
                   struct dfs_rec_flags* flags);
Obj FuncExecuteDFS_C(Obj self, Obj args);

#endif  // DIGRAPHS_SRC_DFS_H_
