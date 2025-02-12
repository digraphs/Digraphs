/*******************************************************************************
**
*A  bliss-includes.h                GAP package Digraphs      Julius Jonusas
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

#ifndef DIGRAPHS_SRC_BLISS_INCLUDES_H_
#define DIGRAPHS_SRC_BLISS_INCLUDES_H_

#include "digraphs-config.h"

#if defined(__clang__)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
#elif defined(__GNUC__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wformat-nonliteral"
#endif

// GAP headers
#ifdef DIGRAPHS_WITH_INCLUDED_BLISS
#include "bliss-0.73/bliss_C.h"  // for bliss_digraphs_release, . . .
#else
#include "bliss/bliss_C.h"
#define bliss_digraphs_add_edge bliss_add_edge
#define bliss_digraphs_new bliss_new
#define bliss_digraphs_add_vertex bliss_add_vertex
#define bliss_digraphs_find_canonical_labeling bliss_find_canonical_labeling
#define bliss_digraphs_release bliss_release
#define bliss_digraphs_find_automorphisms bliss_find_automorphisms
#endif

#if defined(__clang__)
#pragma clang diagnostic pop
#elif defined(__GNUC__)
#pragma GCC diagnostic pop
#endif

#endif  // DIGRAPHS_SRC_BLISS_INCLUDES_H_
