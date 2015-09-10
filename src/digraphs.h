/*******************************************************************************
**
*A  digraphs.h                  GAP package Digraphs          Julius Jonusas
**                                                            James Mitchell 
**                                                            Michael Torpey
**                                                            Wilfred Wilson
**
**  Copyright (C) 2014-15 - Julius Jonusas, James Mitchell, Michael Torpey, 
**  Wilfred Wilson 
**
**  This file is free software, see the digraphs/LICENSE.
**  
*******************************************************************************/

#ifndef DIGRAPHS_DIGRAPHS_H
#define DIGRAPHS_DIGRAPHS_H 1

#include "bliss-0.73/bliss_C.h"

#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

#include "src/compiled.h"          /* GAP headers                */
#include "src/homos.h"     

Int DigraphNrVertices(Obj digraph);
Int DigraphNrEdges(Obj digraph);

Obj OutNeighbours(Obj digraph);
Obj DigraphSource(Obj digraph);
Obj DigraphRange(Obj digraph);

#endif
