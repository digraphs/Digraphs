/********************************************************************************
**
**  bit_array.c               bit arrays                       J. D. Mitchell
**
**  Copyright (C) 2019-2024
**
**  This file is free software, see the digraphs/LICENSE.
**
********************************************************************************/

#include "bitarray.h"

// C headers
#include <stdbool.h>  // for true and false
#include <stddef.h>   // for size_t, NULL
#include <stdlib.h>   // for free, calloc, malloc

// GAP headers
#include "gap-includes.h"  // for Obj, ELM_LIST, ISB_LIST, Fail

// Digraphs headers
#include "digraphs-debug.h"  // for DIGRAPHS_ASSERT
#include "safemalloc.h"      // for safe_malloc

////////////////////////////////////////////////////////////////////////
// Macros
////////////////////////////////////////////////////////////////////////

#define NR_BITS_IN_SIZE_T (sizeof(size_t) * 8)

////////////////////////////////////////////////////////////////////////
// Global variables
////////////////////////////////////////////////////////////////////////

bool     LOOKUPS_INITIALISED = false;
size_t*  NR_BLOCKS_LOOKUP    = NULL;
size_t*  QUOTIENT_LOOKUP     = NULL;
size_t*  REMAINDER_LOOKUP    = NULL;
Block*   MASK_LOOKUP         = NULL;
uint16_t LOOKUP_SIZE         = 65535;

////////////////////////////////////////////////////////////////////////
// Static functions
////////////////////////////////////////////////////////////////////////

static size_t calculate_quotient(size_t N) {
  return (size_t) N / NR_BITS_IN_SIZE_T;
}

static size_t calculate_number_of_blocks(size_t N) {
  return (N + NR_BITS_IN_SIZE_T - 1) / NR_BITS_IN_SIZE_T;
}

static size_t calculate_remainder(size_t N) {
  return (size_t) N % NR_BITS_IN_SIZE_T;
}

static Block calculate_mask(size_t N) {
  return (Block) 1 << N;
}

static void allocate_num_blocks_lookup(uint16_t new_lookup_size) {
  NR_BLOCKS_LOOKUP = (size_t*) safe_calloc(new_lookup_size, sizeof(size_t));

  for (uint16_t i = 0; i < new_lookup_size; i++) {
    NR_BLOCKS_LOOKUP[i] = calculate_number_of_blocks(i);
  }
}

static void allocate_quotient_lookup(uint16_t new_lookup_size) {
  QUOTIENT_LOOKUP = (size_t*) safe_calloc(new_lookup_size, sizeof(size_t));

  for (uint16_t i = 0; i < new_lookup_size; i++) {
    QUOTIENT_LOOKUP[i] = calculate_quotient(i);
  }
}

static void allocate_remainder_lookup(uint16_t new_lookup_size) {
  REMAINDER_LOOKUP = (size_t*) safe_calloc(new_lookup_size, sizeof(size_t));

  for (uint16_t i = 0; i < new_lookup_size; i++) {
    REMAINDER_LOOKUP[i] = calculate_remainder(i);
  }
}

static void allocate_mask_lookup(uint16_t new_lookup_size) {
  MASK_LOOKUP = (Block*) safe_calloc(new_lookup_size, sizeof(Block));

  for (uint16_t i = 0; i < new_lookup_size; i++) {
    MASK_LOOKUP[i] = calculate_mask(i);
  }
}

static void initialize_bit_array_lookups(void) {
  if (!LOOKUPS_INITIALISED) {
    allocate_num_blocks_lookup(LOOKUP_SIZE);
    allocate_quotient_lookup(LOOKUP_SIZE);
    allocate_remainder_lookup(LOOKUP_SIZE);
    allocate_mask_lookup(NR_BITS_PER_BLOCK);

    LOOKUPS_INITIALISED = true;
  }
}

////////////////////////////////////////////////////////////////////////
// Non-static functions
////////////////////////////////////////////////////////////////////////

BitArray* new_bit_array(uint16_t const nr_bits) {
  initialize_bit_array_lookups();
  BitArray* bit_array = safe_malloc(sizeof(BitArray));

  bit_array->nr_bits = nr_bits;
  bit_array->nr_blocks =
      ((nr_bits % NR_BITS_PER_BLOCK) == 0 ? nr_bits / NR_BITS_PER_BLOCK
                                          : nr_bits / NR_BITS_PER_BLOCK + 1);
  bit_array->blocks = safe_calloc(bit_array->nr_blocks, NR_BITS_PER_BLOCK);

  return bit_array;
}

void free_bit_array(BitArray* const bit_array) {
  DIGRAPHS_ASSERT(bit_array != NULL);
  free(bit_array->blocks);
  free(bit_array);
}

void set_bit_array_from_gap_int(BitArray* const bit_array, Obj o) {
  DIGRAPHS_ASSERT(bit_array != NULL);
  DIGRAPHS_ASSERT(IS_INTOBJ(o));
  DIGRAPHS_ASSERT(INT_INTOBJ(o) > 0);
  DIGRAPHS_ASSERT(INT_INTOBJ(o) <= bit_array->nr_bits);
  set_bit_array(bit_array, INT_INTOBJ(o) - 1, true);
}

void set_bit_array_from_gap_list(BitArray* const bit_array, Obj list_obj) {
  DIGRAPHS_ASSERT(bit_array != NULL);
  DIGRAPHS_ASSERT(IS_LIST(list_obj) || list_obj == Fail);

  if (list_obj == Fail) {
    return;
  }
  init_bit_array(bit_array, false, bit_array->nr_bits);
  // TODO assert that bit_array->nr_bits > LEN_LIST(list_obj)?
  for (int i = 1; i <= LEN_LIST(list_obj); i++) {
    if (ISB_LIST(list_obj, i)) {
      set_bit_array_from_gap_int(bit_array, ELM_LIST(list_obj, i));
    }
  }
}

// print_bit_array is not used, but can be useful for debugging.

// static void print_bit_array(BitArray const* const bit_array) {
//   if (bit_array == NULL) {
//     printf("NULL");
//     return;
//   }
//   printf("<bit array {");
//   for (uint16_t i = 0; i < bit_array->nr_bits; i++) {
//     if (get_bit_array(bit_array, i)) {
//       printf(" %d", i);
//     }
//   }
//   printf(" }>\n");
// }
