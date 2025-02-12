/********************************************************************************
**
*A  bitarray.h               bit arrays                           J. D. Mitchell
**
**  Copyright (C) 2019 - J. D. Mitchell
**
**  This file is free software, see the digraphs/LICENSE.
**
********************************************************************************/

#ifndef DIGRAPHS_SRC_BITARRAY_H_
#define DIGRAPHS_SRC_BITARRAY_H_

// C headers
#include <limits.h>   // for CHAR_BIT
#include <stdbool.h>  // for bool
#include <stddef.h>   // for size_t
#include <stdint.h>   // for uint16_t
#include <string.h>   // for memset

// GAP headers
#include "gap-includes.h"  // for COUNT_TRUES_BLOCKS, Obj, . . .

// Digraphs headers
#include "digraphs-debug.h"  // for DIGRAPHS_ASSERT

typedef UInt Block;

#define NR_BITS_PER_BLOCK (sizeof(Block) * CHAR_BIT)

extern size_t*  NR_BLOCKS_LOOKUP;
extern size_t*  QUOTIENT_LOOKUP;
extern size_t*  REMAINDER_LOOKUP;
extern Block*   MASK_LOOKUP;
extern uint16_t LOOKUP_SIZE;

static inline size_t number_of_blocks(size_t N) {
  DIGRAPHS_ASSERT(N < LOOKUP_SIZE);
  return NR_BLOCKS_LOOKUP[N];
}

static inline size_t remainder_lookup(size_t N) {
  DIGRAPHS_ASSERT(N < LOOKUP_SIZE);
  return REMAINDER_LOOKUP[N];
}

static inline size_t quotient_lookup(size_t N) {
  DIGRAPHS_ASSERT(N < LOOKUP_SIZE);
  return QUOTIENT_LOOKUP[N];
}

static inline Block mask_lookup(size_t N) {
  DIGRAPHS_ASSERT(N < NR_BITS_PER_BLOCK);
  return MASK_LOOKUP[N];
}

struct bit_array_struct {
  uint16_t nr_bits;    // number of bits
  uint16_t nr_blocks;  // number of blocks
  Block*   blocks;     // the blocks themselves
};

typedef struct bit_array_struct BitArray;

//! New BitArray with space for \p nr_bits bits, and with every bit set to \c
//! false.
BitArray* new_bit_array(uint16_t const nr_bits);

//! Free all the memory associated with a BitArray false.
void free_bit_array(BitArray* const);

//! Set every value in the BitArray pointed to by \p bit_array to the value \p
//! val.
static inline void init_bit_array(BitArray* const bit_array,
                                  bool const      val,
                                  uint16_t const  nr_bits) {
  DIGRAPHS_ASSERT(bit_array != NULL);
  DIGRAPHS_ASSERT(nr_bits <= bit_array->nr_bits);

  uint16_t const nr_blocks = number_of_blocks(nr_bits);

  if (val) {
    memset((void*) bit_array->blocks, ~0, (size_t) sizeof(Block) * nr_blocks);
  } else {
    memset((void*) bit_array->blocks, 0, (size_t) sizeof(Block) * nr_blocks);
  }
}

//! Set position \p pos in the BitArray pointed to by \p bit_array
//! to the value \p val.
static inline void
set_bit_array(BitArray* const bit_array, uint16_t const pos, bool const val) {
  DIGRAPHS_ASSERT(bit_array != NULL);
  DIGRAPHS_ASSERT(pos < bit_array->nr_bits);
  if (val) {
    bit_array->blocks[quotient_lookup(pos)] |=
        mask_lookup(remainder_lookup(pos));
  } else {
    bit_array->blocks[quotient_lookup(pos)] &=
        ~mask_lookup(remainder_lookup(pos));
  }
}

//! Get the value in position \p pos of the BitArray pointer
//! \p bit_array.
static inline bool get_bit_array(BitArray const* const bit_array,
                                 uint16_t const        pos) {
  DIGRAPHS_ASSERT(bit_array != NULL);
  DIGRAPHS_ASSERT(pos < bit_array->nr_bits);
  return bit_array->blocks[quotient_lookup(pos)]
         & mask_lookup(remainder_lookup(pos));
}

//! Intersect the BitArray's pointed to by \p bit_array1 and \p bit_array2. The
//! BitArray pointed to by \p bit_array1 is changed in place!
static inline void intersect_bit_arrays(BitArray* const       bit_array1,
                                        BitArray const* const bit_array2,
                                        uint16_t const        nr_bits) {
  DIGRAPHS_ASSERT(bit_array1 != NULL);
  DIGRAPHS_ASSERT(bit_array2 != NULL);
  DIGRAPHS_ASSERT(bit_array1->nr_bits == bit_array2->nr_bits);
  DIGRAPHS_ASSERT(bit_array1->nr_blocks == bit_array2->nr_blocks);
  DIGRAPHS_ASSERT(nr_bits <= bit_array1->nr_bits);
  DIGRAPHS_ASSERT(nr_bits <= bit_array2->nr_bits);
  uint16_t const nr_blocks = number_of_blocks(nr_bits);
  for (uint16_t i = 0; i < nr_blocks; i++) {
    bit_array1->blocks[i] &= bit_array2->blocks[i];
  }
}

//! Union the BitArray's pointed to by \p bit_array1 and \p bit_array2. The
//! BitArray pointed to by \p bit_array1 is changed in place!
static inline void union_bit_arrays(BitArray* const       bit_array1,
                                    BitArray const* const bit_array2,
                                    uint16_t const        nr_bits) {
  DIGRAPHS_ASSERT(bit_array1 != NULL);
  DIGRAPHS_ASSERT(bit_array2 != NULL);
  DIGRAPHS_ASSERT(bit_array1->nr_bits == bit_array2->nr_bits);
  DIGRAPHS_ASSERT(bit_array1->nr_blocks == bit_array2->nr_blocks);
  DIGRAPHS_ASSERT(nr_bits <= bit_array1->nr_bits);
  DIGRAPHS_ASSERT(nr_bits <= bit_array2->nr_bits);
  uint16_t const nr_blocks = number_of_blocks(nr_bits);
  for (uint16_t i = 0; i < nr_blocks; i++) {
    bit_array1->blocks[i] |= bit_array2->blocks[i];
  }
}

//! Sets \p bit_array1 to be 0 in every position that \p bit_array2 is 1.
static inline void complement_bit_arrays(BitArray* const       bit_array1,
                                         BitArray const* const bit_array2,
                                         uint16_t const        nr_bits) {
  DIGRAPHS_ASSERT(bit_array1 != NULL);
  DIGRAPHS_ASSERT(bit_array2 != NULL);
  DIGRAPHS_ASSERT(bit_array1->nr_bits == bit_array2->nr_bits);
  DIGRAPHS_ASSERT(bit_array1->nr_blocks == bit_array2->nr_blocks);
  DIGRAPHS_ASSERT(nr_bits <= bit_array1->nr_bits);
  DIGRAPHS_ASSERT(nr_bits <= bit_array2->nr_bits);
  uint16_t const nr_blocks = number_of_blocks(nr_bits);
  for (uint16_t i = 0; i < nr_blocks; i++) {
    bit_array1->blocks[i] &= ~bit_array2->blocks[i];
  }
}

//! This function copies \p bit_array2 into \p bit_array1
static inline void copy_bit_array(BitArray* const       bit_array1,
                                  BitArray const* const bit_array2,
                                  uint16_t const        nr_bits) {
  DIGRAPHS_ASSERT(bit_array1 != NULL);
  DIGRAPHS_ASSERT(bit_array2 != NULL);
  DIGRAPHS_ASSERT(bit_array1->nr_bits == bit_array2->nr_bits);
  DIGRAPHS_ASSERT(bit_array1->nr_blocks == bit_array2->nr_blocks);
  DIGRAPHS_ASSERT(nr_bits <= bit_array1->nr_bits);
  DIGRAPHS_ASSERT(nr_bits <= bit_array2->nr_bits);
  uint16_t const nr_blocks = number_of_blocks(nr_bits);
  for (uint16_t i = 0; i < nr_blocks; i++) {
    bit_array1->blocks[i] = bit_array2->blocks[i];
  }
}

//! Return the number of set bits among the first \p nr_bits of \p bit_array.
static inline uint16_t size_bit_array(BitArray const* const bit_array,
                                      uint16_t const        nr_bits) {
  DIGRAPHS_ASSERT(bit_array != NULL);
  DIGRAPHS_ASSERT(nr_bits <= bit_array->nr_bits);
  Block const*   blocks    = bit_array->blocks;
  uint16_t const nr_blocks = number_of_blocks(nr_bits);
  return COUNT_TRUES_BLOCKS(blocks, nr_blocks);
}

//! Set the bit array \p bit_array to be \c true in position INT_INTOBJ(o) - 1.
void set_bit_array_from_gap_int(BitArray* const bit_array, Obj o);

//! Set the bit array \p bit_array to be \c true for every integer valyue in
//! \p list_obj (which should be a list consisting of integers, not necessarily
//! plain or dense).
void set_bit_array_from_gap_list(BitArray* const bit_array, Obj list_obj);

// void print_bit_array(BitArray const* const bit_array);
#endif  //  DIGRAPHS_SRC_BITARRAY_H_
