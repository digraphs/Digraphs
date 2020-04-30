/********************************************************************************
**
*A  planar.h               Planarity testing
**
**
**  Copyright (C) 2018 - J. D. Mitchell
**
**  This file is free software, see the digraphs/LICENSE.
**
********************************************************************************/

#ifndef DIGRAPHS_SRC_PLANAR_H_
#define DIGRAPHS_SRC_PLANAR_H_

// GAP headers
#include "compiled.h"

Obj FuncIS_PLANAR(Obj self, Obj digraph);
Obj FuncKURATOWSKI_PLANAR_SUBGRAPH(Obj self, Obj digraph);
Obj FuncPLANAR_EMBEDDING(Obj self, Obj digraph);

Obj FuncIS_OUTER_PLANAR(Obj self, Obj digraph);
Obj FuncKURATOWSKI_OUTER_PLANAR_SUBGRAPH(Obj self, Obj digraph);
Obj FuncOUTER_PLANAR_EMBEDDING(Obj self, Obj digraph);

Obj FuncSUBGRAPH_HOMEOMORPHIC_TO_K23(Obj self, Obj digraph);
Obj FuncSUBGRAPH_HOMEOMORPHIC_TO_K33(Obj self, Obj digraph);
Obj FuncSUBGRAPH_HOMEOMORPHIC_TO_K4(Obj self, Obj digraph);

#endif  // DIGRAPHS_SRC_PLANAR_H_
