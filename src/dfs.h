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
Obj HASH_GET(Obj map, Obj key);
bool HASH_CONTAINS(Obj map, Obj key);

Obj FuncExecuteDFS_C(Obj self, Obj args);
Obj FuncExecuteDFSIter_C(Obj self, Obj args);  // TODO remove?

#endif  // DIGRAPHS_SRC_DFS_H_
