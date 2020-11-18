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

// GAP headers
#include "compiled.h"  // for Obj, Int

Int DigraphNrVertices(Obj D);
Obj FuncOutNeighbours(Obj self, Obj D);
Obj FuncIS_ANTISYMMETRIC_DIGRAPH(Obj self, Obj D);

Int DigraphNrEdges(Obj digraph);
Obj DigraphSource(Obj digraph);
Obj DigraphRange(Obj digraph);

extern Obj AutomorphismGroup;
extern Obj DIGRAPHS_ValidateVertexColouring;
extern Obj GeneratorsOfGroup;
extern Obj IsDigraph;
extern Obj IsDigraphEdge;

#endif  // DIGRAPHS_SRC_DIGRAPHS_H_
