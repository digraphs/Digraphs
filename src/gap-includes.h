/*******************************************************************************
**
*A  gap-includes.h                  GAP package Digraphs      Julius Jonusas
**                                                            James Mitchell
**                                                            Wilf A. Wilson
**                                                            Michael Young
**
**  Copyright (C) 2014-24 - Julius Jonusas, James Mitchell, Wilf A. Wilson,
**  Michael Young
**
**  This file is free software, see the digraphs/LICENSE.
**
*******************************************************************************/

#ifndef DIGRAPHS_SRC_GAP_INCLUDES_H_
#define DIGRAPHS_SRC_GAP_INCLUDES_H_

#if defined(__clang__)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeclaration-after-statement"
#elif defined(__GNUC__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeclaration-after-statement"
#pragma GCC diagnostic ignored "-Wpedantic"
#pragma GCC diagnostic ignored "-Winline"
#endif
// GAP headers
#include "gap_all.h"  // for Obj, Int
                      //
#ifdef GAP410_OR_OLDER
#include "compiled.h"  // FIXME Remove include when we don't support GAP 4.10
#endif

#endif  // DIGRAPHS_SRC_GAP_INCLUDES_H_
