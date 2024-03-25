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
#include <stdlib.h>   // for calloc
// GAP headers
#include "compiled.h"  // for COUNT_TRUES_BLOCKS, Obj, . . .

// Digraphs headers
#include "digraphs-debug.h"  // for DIGRAPHS_ASSERT
typedef UInt Block;

#define NUMBER_BITS_PER_BLOCK (sizeof(Block) * CHAR_BIT)

static bool   lookups_initialised = false;

#if SYS_IS_64_BIT
#define SYSTEM_BIT_COUNT 64
#else
#define SYSTEM_BIT_COUNT 32
#endif

extern size_t* nr_blocks_lookup;
extern size_t* quotient_lookup;
extern size_t* remainder_lookup;
extern Block*  mask_lookup;
extern uint16_t lookup_size;

#include <stdio.h>  // Include the standard I/O header for file operations

static size_t calculate_quotient(size_t N) {
  return (size_t) N / SYSTEM_BIT_COUNT;
}

static size_t calculate_number_of_blocks(size_t N) {
  return (N + SYSTEM_BIT_COUNT - 1) / SYSTEM_BIT_COUNT;
}

static size_t calculate_remainder(size_t N) {
  return (size_t) N % SYSTEM_BIT_COUNT;
}

static Block calculate_mask(size_t N) {
  return (Block) 1 << N;
}

static void allocateNrBlocksLookup(uint16_t lookup_size) {
  nr_blocks_lookup = (size_t*) calloc(lookup_size, sizeof(size_t));

  for (uint16_t i = 0; i < lookup_size; i++) {
    nr_blocks_lookup[i] = calculate_number_of_blocks(i);
  }
}

static void allocateQuotientLookup(uint16_t lookup_size) {
  quotient_lookup = (size_t*) calloc(lookup_size, sizeof(size_t));

  for (uint16_t i = 0; i < lookup_size; i++) {
    quotient_lookup[i] = calculate_quotient(i);
  }
}

static void allocateRemainderLookup(uint16_t lookup_size) {
  remainder_lookup = (size_t*) calloc(lookup_size, sizeof(size_t));

  for (uint16_t i = 0; i < lookup_size; i++) {
    remainder_lookup[i] = calculate_remainder(i);
  }
}

static void allocateMaskLookup(uint16_t lookup_size) {
  mask_lookup = (Block*) calloc(lookup_size, sizeof(Block));

  for (uint16_t i = 0; i < lookup_size; i++) {
    mask_lookup[i] = calculate_mask(i);
  }
}

static void free_bitarray_lookups(){
  free(mask_lookup);
  free(remainder_lookup);
  free(quotient_lookup);

  lookups_initialised = false;
}

static void initialize_bitarray_lookups() {
  if (!lookups_initialised) {
    allocateNrBlocksLookup(lookup_size);
    allocateQuotientLookup(lookup_size);
    allocateRemainderLookup(lookup_size);
    allocateMaskLookup(NUMBER_BITS_PER_BLOCK);

    lookups_initialised = true;
  }
}

// Allow users to set the bit array calculation lookup size
Obj FuncSetBitArrayLookupSize(Obj self, Obj args) {
  if (LEN_PLIST(args) != 1) {
    ErrorQuit(
        "there must be 1 argument, found %d,", LEN_PLIST(args), 0L);
  }

  Obj lookup_size_obj    = ELM_PLIST(args, 1);

  if (!IS_INTOBJ(lookup_size_obj)) {
    ErrorQuit("the 1st argument <lookup_size> must be an integer "
              ", not %s,",
              (Int) TNAM_OBJ(lookup_size_obj),
              0L);
  }

  lookup_size = INT_INTOBJ(lookup_size_obj);
}

static size_t get_number_of_blocks(size_t N) {
  if (N < lookup_size) {
    return nr_blocks_lookup[N];
  } else {
    return calculate_number_of_blocks(N);
  }
}

static size_t get_remainder(size_t number) {
  if (number < lookup_size) {
    return remainder_lookup[number];
  } else {
    return calculate_remainder(number);
  }
}

static size_t get_quotient(size_t number) {
  if (number < lookup_size) {
    return quotient_lookup[number];
  } else {
    return calculate_quotient(number);
  }
}

static const Block get_mask(size_t N) {
  DIGRAPHS_ASSERT(N < NUMBER_BITS_PER_BLOCK);
  return mask_lookup[N];
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
  uint16_t const nr_blocks = get_number_of_blocks(nr_bits);
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
    bit_array->blocks[get_quotient(pos)] |= get_mask(get_remainder(pos));
  } else {
    bit_array->blocks[get_quotient(pos)] &= ~get_mask(get_remainder(pos));
  }
}

//! Get the value in position \p pos of the BitArray pointer
//! \p bit_array.
static inline bool get_bit_array(BitArray const* const bit_array,
                                 uint16_t const        pos) {
  DIGRAPHS_ASSERT(bit_array != NULL);
  DIGRAPHS_ASSERT(pos < bit_array->nr_bits);
  return bit_array->blocks[get_quotient(pos)] & get_mask(get_remainder(pos));
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
  uint16_t const nr_blocks = get_number_of_blocks(nr_bits);
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
  uint16_t const nr_blocks = get_number_of_blocks(nr_bits);
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
  uint16_t const nr_blocks = get_number_of_blocks(nr_bits);
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
  uint16_t const nr_blocks = get_number_of_blocks(nr_bits);
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
  uint16_t const nr_blocks = get_number_of_blocks(nr_bits);
  return COUNT_TRUES_BLOCKS(blocks, nr_blocks);
}

//! Set the bit array \p bit_array to be \c true in position INT_INTOBJ(o) - 1.
void set_bit_array_from_gap_int(BitArray* const bit_array, Obj o);

//! Set the bit array \p bit_array to be \c true for every integer valyue in
//! \p list_obj (which should be a list consisting of integers, not necessarily
//! plain or dense).
void set_bit_array_from_gap_list(BitArray* const bit_array, Obj list_obj);

#endif  //  DIGRAPHS_SRC_BITARRAY_H_
