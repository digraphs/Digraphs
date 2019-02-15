/********************************************************************************
**
*A  bitarray.c               bit arrays                           J. D. Mitchell
**
**  Copyright (C) 2019 - J. D. Mitchell
**
**  This file is free software, see the digraphs/LICENSE.
**
********************************************************************************/

#include "bitarray.h"

// C headers
#include <stdlib.h>  // for free, calloc, malloc

// GAP headers
#include "src/compiled.h"  // for Obj, ELM_LIST, ISB_LIST, Fail

// Digraphs headers
#include "digraphs-debug.h"  // for DIGRAPHS_ASSERT

BitArray* new_bit_array(uint16_t const nr_bits) {
  BitArray* bit_array  = malloc(sizeof(BitArray));
  bit_array->nr_bits   = nr_bits;
  bit_array->nr_blocks = ((nr_bits % NUMBER_BITS_PER_BLOCK) == 0
                              ? nr_bits / NUMBER_BITS_PER_BLOCK
                              : nr_bits / NUMBER_BITS_PER_BLOCK + 1);
  // The previous line is not tested since all the bit arrays we use are
  // currently of length MAXVERTS = 512.
  bit_array->blocks = calloc(bit_array->nr_blocks, NUMBER_BITS_PER_BLOCK);
  return bit_array;
}

// free_bit_array is not currently used, but kept in case it is required in the
// future. JDM 2019

// void free_bit_array(BitArray* const bit_array) {
//   DIGRAPHS_ASSERT(bit_array != NULL);
//   free(bit_array->blocks);
//   free(bit_array);
// }

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
