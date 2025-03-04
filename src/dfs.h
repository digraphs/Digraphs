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

// GAP headers
#include "gap-includes.h"  // for Obj, Int

Obj FuncExecuteDFS_C(Obj self, Obj args);
Obj FuncExecuteDFSIter_C(Obj self, Obj args);  // TODO remove?

#endif  // DIGRAPHS_SRC_DFS_H_
