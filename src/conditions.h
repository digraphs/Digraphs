/********************************************************************************
**
**  conditions.h  Data structure for homomorphisms search     J. D. Mitchell
**
**  Copyright (C) 2019 - J. D. Mitchell
**
**  This file is free software, see the digraphs/LICENSE.
**
********************************************************************************/

#ifndef DIGRAPHS_SRC_CONDITIONS_H_
#define DIGRAPHS_SRC_CONDITIONS_H_

// C headers
#include <stdbool.h>  // for false, true
#include <stdint.h>   // for uint16_t, uint64_t
#include <string.h>   // for NULL, memcpy, size_t

// GAP headers
#include "src/system.h"  // for ALWAYS_INLINE

// Digraphs headers
#include "bitarray.h"        // for BitArray, intersect_bit_arrays, size_b...
#include "digraphs-debug.h"  // for DIGRAPHS_ASSERT

// This file contains a data structure for keeping track of what possible
// values a uint16_t can be mapped to by a partially defined homomorphism, given
// the existing values of the homomorphism.
//
// If <nr1> is the number of vertices in the source di/graph and <nr2> is the
// number of vertices in the range di/graph, then a Conditions object looks
// like:
//
//  ^
//  |
//  |
//
//  n                +------------+
//  r                | BitArray*  |
//  1                | length nr2 |
//                   +------------+                    +------------+
//  r                | BitArray*  |                    | BitArray*  |
//  o                | length nr2 |                    | length nr2 |
//  w                +------------+------------+       +------------+
//  s                | BitArray*  | BitArray*  |       | BitArray*  |
//                   | length nr2 | length nr2 |       | length nr2 |
//  |   +------------+------------+------------+ - -  -+------------+
//  |   | BitArray*  | BitArray*  | BitArray*  |       | BitArray*  |
//  |   | length nr2 | length nr2 | length nr2 |       | length nr2 |
//  v   +------------+------------+------------+ - -  -+------------+
//
//      <----------------------- nr1 columns ----------------------->
//
//  The BitArray pointed to in row <i+1> and column <j> row is the intersection
//  of the BitArray pointed to in row <i> and column <j> with some other
//  BitArray (the things adjacent to some uint16_t in di/graph2).
//

struct conditions_struct {
  BitArray** bit_array;  // nr1 * nr1 array of bit arrays of length nr2
  uint16_t*  changed;
  uint16_t*  height;
  uint16_t*  sizes;
  uint16_t   nr1;
  uint16_t   nr2;
};

typedef struct conditions_struct Conditions;

//! Returns a pointer to a Conditions with one complete row where every bit is
//! set to true.
Conditions* new_conditions(uint16_t const nr1, uint16_t const nr2);

//! Clears all the information in the Conditions object, and puts it back into
//! the state it was when it was initially created. The second and third
//! arguments indicate how much of the Conditions object is to be cleared. I.e.
//! if we want to use the Conditions object in a homomorphism search for graphs
//! with 5 and 19 vertices, then we clear the Conditions object with 2nd and
//! 3rd parameters 5, and 19.
static inline void clear_conditions(Conditions* const conditions,
                                    uint16_t const    nr1,
                                    uint16_t const    nr2) {
  DIGRAPHS_ASSERT(conditions != NULL);
  DIGRAPHS_ASSERT(nr1 != 0);
  DIGRAPHS_ASSERT(nr2 != 0);

  for (uint64_t i = 0; i < nr1 * nr1; i++) {
    init_bit_array(conditions->bit_array[i], false, nr2);
  }

  for (uint64_t i = 0; i < nr1; i++) {
    init_bit_array(conditions->bit_array[i], true, nr2);
    conditions->changed[i + 1]         = i;
    conditions->changed[(nr1 + 1) * i] = 0;
    conditions->height[i]              = 1;
  }
  conditions->changed[0] = nr1;
  conditions->nr1        = nr1;
  conditions->nr2        = nr2;
}

//! Free an entire Conditions object pointed to by
void free_conditions(Conditions* const conditions);

//! Returns the top most BitArray* in column \p i.
static inline BitArray* get_conditions(Conditions const* const conditions,
                                       uint16_t const          i) {
  DIGRAPHS_ASSERT(conditions != NULL);
  DIGRAPHS_ASSERT(i < conditions->nr1);
  return conditions
      ->bit_array[conditions->nr1 * (conditions->height[i] - 1) + i];
}

//! Store the size of the BitArray pointed to at the top of column \p i.
static inline void store_size_conditions(Conditions* const conditions,
                                         uint16_t const    i) {
  DIGRAPHS_ASSERT(conditions != NULL);
  DIGRAPHS_ASSERT(i < conditions->nr1);
  uint16_t const nr1 = conditions->nr1;
  conditions->sizes[nr1 * (conditions->height[i] - 1) + i] =
      size_bit_array(get_conditions(conditions, i), conditions->nr2);
}

//! Copy the top of the <i>th column of the <conditions> and intersect it with
//! <bit_array> and then push this onto the top of the <i>th column.
static ALWAYS_INLINE void push_conditions(Conditions* const     conditions,
                                          uint16_t const        depth,
                                          uint16_t const        i,
                                          BitArray const* const bit_array) {
  DIGRAPHS_ASSERT(conditions != NULL);
  DIGRAPHS_ASSERT(i < conditions->nr1);
  DIGRAPHS_ASSERT(depth < conditions->nr1);

  uint16_t const nr1 = conditions->nr1;

  memcpy((void*) conditions->bit_array[nr1 * conditions->height[i] + i]->blocks,
         (void*) conditions->bit_array[nr1 * (conditions->height[i] - 1) + i]
             ->blocks,
         (size_t) conditions->bit_array[0]->nr_blocks * sizeof(Block));

  conditions->changed[(nr1 + 1) * depth]++;
  conditions
      ->changed[(nr1 + 1) * depth + conditions->changed[(nr1 + 1) * depth]] = i;

  conditions->height[i]++;

  if (bit_array != NULL) {
    intersect_bit_arrays(
        get_conditions(conditions, i), bit_array, conditions->nr2);
  }
}

//! Pop the tops off all of the columns which were pushed on at depth \p depth.
static inline void pop_conditions(Conditions* const conditions,
                                  uint16_t const    depth) {
  DIGRAPHS_ASSERT(conditions != NULL);
  DIGRAPHS_ASSERT(depth < conditions->nr1);

  uint16_t const nr1 = conditions->nr1;

  for (uint16_t i = 1; i < conditions->changed[(nr1 + 1) * depth] + 1; i++) {
    conditions->height[conditions->changed[(nr1 + 1) * depth + i]]--;
  }
  conditions->changed[(nr1 + 1) * depth] = 0;
}

//! Return the size of the BitArray pointed to by the top of the \p i-th
//! column.
static inline uint16_t size_conditions(Conditions const* const conditions,
                                       uint16_t const          i) {
  DIGRAPHS_ASSERT(conditions != NULL);
  DIGRAPHS_ASSERT(i < conditions->nr1);
  return conditions->sizes[conditions->nr1 * (conditions->height[i] - 1) + i];
}

#endif  // DIGRAPHS_SRC_CONDITIONS_H_
