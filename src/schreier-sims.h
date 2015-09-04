/*******************************************************************************
**
*A  schreier-sims.h        A rudimentary Schreier-Sims        Julius Jonusas
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

#ifndef HOMOS_SS_H
#define HOMOS_SS_H 1

#include "src/perms.h"

extern bool point_stabilizer( PermColl* gens, UIntS const pt, PermColl** out);

#endif
