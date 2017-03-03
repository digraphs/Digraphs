/*******************************************************************************
**
*A  schreier-sims.h        A rudimentary Schreier-Sims        Julius Jonusas
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

#ifndef DIGRAPHS_SRC_SCHREIER_SIMS_H_
#define DIGRAPHS_SRC_SCHREIER_SIMS_H_

#include "src/perms.h"

extern bool point_stabilizer(PermColl* gens, UIntS const pt, PermColl** out);

#endif  // DIGRAPHS_SRC_SCHREIER_SIMS_H_
