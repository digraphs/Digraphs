/********************************************************************************
**
**  conditions.c  - Data structure for homomorphisms search       J. D. Mitchell
**
**  Copyright (C) 2019 - J. D. Mitchell
**
**  This file is free software, see the digraphs/LICENSE.
**
********************************************************************************/

#include "conditions.h"

// C headers
#include <stdbool.h>  // for true, false
#include <stdint.h>   // for uint16_t, uint64_t
#include <stdlib.h>   // for free, malloc

// Digraphs headers
#include "digraphs-debug.h"  // for DIGRAPHS_ASSERT

Conditions* new_conditions(uint16_t const nr1, uint16_t const nr2) {
  DIGRAPHS_ASSERT(nr1 != 0);
  DIGRAPHS_ASSERT(nr2 != 0);
  Conditions* conditions = malloc(sizeof(Conditions));

  conditions->bit_array = malloc(sizeof(BitArray*) * nr1 * nr1);
  conditions->changed   = malloc(nr1 * (nr1 + 1) * sizeof(uint16_t));
  conditions->height    = malloc(nr1 * sizeof(uint16_t));
  conditions->sizes     = malloc(nr1 * nr1 * sizeof(uint16_t));
  conditions->nr1       = nr1;
  conditions->nr2       = nr2;

  for (uint64_t i = 0; i < ((uint64_t) nr1 * nr1); i++) {
    conditions->bit_array[i] = new_bit_array(nr2);
  }

  for (uint64_t i = 0; i < nr1; i++) {
    init_bit_array(conditions->bit_array[i], true, nr1);
    conditions->changed[i + 1]         = i;
    conditions->changed[(nr1 + 1) * i] = 0;
    conditions->height[i]              = 1;
  }
  conditions->changed[0] = nr1;
  return conditions;
}

// free_conditions is not currently used, but kept in case it is required in
// the future. JDM 2019

// void free_conditions(Conditions* const conditions) {
//   DIGRAPHS_ASSERT(conditions != NULL);
//   for (uint64_t i = 0; i < ((uint64_t) conditions->nr1 * conditions->nr1);
//        i++) {
//     free_bit_array(conditions->bit_array[i]);
//   }
//   free(conditions->bit_array);
//   free(conditions->changed);
//   free(conditions->height);
//   free(conditions->sizes);
//   free(conditions);
// }
