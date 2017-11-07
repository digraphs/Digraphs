/*******************************************************************************
**
*A  digraphs.h                  GAP package Digraphs          Julius Jonusas
**                                                            James Mitchell
**                                                            Michael Torpey
**                                                            Wilf A. Wilson
**
**  Copyright (C) 2014-15 - Julius Jonusas, James Mitchell, Michael Torpey,
**  Wilf A. Wilson
**
**  This file is free software, see the digraphs/LICENSE.
**
*******************************************************************************/

#ifndef DIGRAPHS_SRC_DIGRAPHS_H_
#define DIGRAPHS_SRC_DIGRAPHS_H_

#include <digraphs-debug.h>
#include <stdbool.h>
#include <stdlib.h>

#include "bliss-0.73/bliss_C.h"

#include "src/compiled.h" /* GAP headers                */
#include "src/homos.h"

Int DigraphNrVertices(Obj digraph);
Int DigraphNrEdges(Obj digraph);

Obj OutNeighbours(Obj digraph);
Obj DigraphSource(Obj digraph);
Obj DigraphRange(Obj digraph);

#endif  // DIGRAPHS_SRC_DIGRAPHS_H_
