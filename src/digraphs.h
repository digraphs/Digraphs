/*

Header file for the digraphs.c file.

*/

#include "bliss-0.72/bliss_C.h"

#include <stdlib.h>
#include <stdbool.h>

#include "src/compiled.h"          /* GAP headers                */


Int DigraphNrVertices(Obj digraph);
Int DigraphNrEdges(Obj digraph);

Obj OutNeighbours(Obj digraph);
Obj DigraphSource(Obj digraph);
Obj DigraphRange(Obj digraph);

