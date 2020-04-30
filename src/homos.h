/********************************************************************************
**
*A  homos.h               di/graph homomorphisms              Julius Jonusas
**                                                            J. D. Mitchell
**
**  Copyright (C) 2014-19 - Julius Jonusas and J. D. Mitchell
**
**  This file is free software, see the digraphs/LICENSE.
**
********************************************************************************/

#ifndef DIGRAPHS_SRC_HOMOS_H_
#define DIGRAPHS_SRC_HOMOS_H_

#define MAX(a, b) (a < b ? b : a)
#define MIN(a, b) (a < b ? a : b)

// GAP headers
#include "compiled.h"

Obj FuncHomomorphismDigraphsFinder(Obj self, Obj args);

#endif  // DIGRAPHS_SRC_HOMOS_H_
