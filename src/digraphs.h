/***************************************************************************
**
*A  digraphs.h                  GAP package digraphs          Julius Jonusas
**                                                            James Mitchell 
**                                                            Michael Torpey
**                                                            Wilfred Wilson
**
**  Copyright (C) 2014 - Julius Jonusas, James Mitchell, Michael Torpey, 
**  Wilfred Wilson 
**  This file is free software, see license information at the end.
**  
*/

#include "bliss-0.72/bliss_C.h"

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
