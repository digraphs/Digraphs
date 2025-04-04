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

bool CallCheckStop(Obj f, Int RNamStop, Obj record, Obj data);

struct dfs_args {
  Obj record;
  Int* preorder_num;
  Int* postorder_num;

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

  Int RNamChild;
  Int RNamCurrent;
  Int RNamStop;

  bool CallPreorder;
  bool CallPostorder;
  bool CallAncestor;
  bool CallCross;
};

struct dfs_config {
  bool revisit;
  bool iter;
  bool forest;
};



bool iter_loop(Obj stack, Int stack_size, struct dfs_args* args,
               struct dfs_config* conf);
bool ExecuteDFSRec(Int current, Int prev, Int idx, struct dfs_args* args);
bool ExecuteDFSIter(Int start, struct dfs_args* args, struct dfs_config* conf);
Obj FuncExecuteDFS_C(Obj self, Obj args);

void parseConfig(struct dfs_config*, Obj conf_record);

#endif  // DIGRAPHS_SRC_DFS_H_
