//
// Digraphs package for GAP
// Copyright (C) 2017 James D. Mitchell
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// This file declares kernel debugging functionality.

#ifndef DIGRAPHS_SRC_DIGRAPHS_DEBUG_H_
#define DIGRAPHS_SRC_DIGRAPHS_DEBUG_H_

// C headers
#include <assert.h>  // for assert

// Digraphs package headers
#include "digraphs-config.h"  // for DIGRAPHS_KERNEL_DEBUG

// DIGRAPHS_ASSERT is a version of 'assert' which is enabled by the
// configure option --enable-debug

#ifdef DIGRAPHS_KERNEL_DEBUG
#define DIGRAPHS_ASSERT(x) assert(x)
#else
#define DIGRAPHS_ASSERT(x)
#endif

#endif  // DIGRAPHS_SRC_DIGRAPHS_DEBUG_H_
