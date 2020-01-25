/********************************************************************************
**
**  homos-graphs.h  (Di)graphs for the homomorphism finder J. D. Mitchell
**
**  Copyright (C) 2019 - J. D. Mitchell
**
**  This file is free software, see the digraphs/LICENSE.
**
********************************************************************************/

#ifndef DIGRAPHS_SRC_HOMOS_GRAPHS_H_
#define DIGRAPHS_SRC_HOMOS_GRAPHS_H_

// C headers
#include <stdbool.h>  // for bool
#include <stdint.h>   // for uint16_t

// Digraphs headers
#include "bitarray.h"        // for BitArray
#include "digraphs-debug.h"  // for DIGRAPHS_ASSERT
#include "perms.h"           // for PermColl

#ifdef DIGRAPHS_WITH_INCLUDED_BLISS
#include "bliss-0.73/bliss_C.h"  // for bliss_digraphs_release, . . .
#else
#include "bliss/bliss_C.h"
#define bliss_digraphs_add_edge bliss_add_edge
#define bliss_digraphs_new bliss_new
#define bliss_digraphs_add_vertex bliss_add_vertex
#define bliss_digraphs_find_canonical_labeling bliss_find_canonical_labeling
#define bliss_digraphs_release bliss_release
#endif

////////////////////////////////////////////////////////////////////////
// Directed graphs (digraphs)
////////////////////////////////////////////////////////////////////////

struct digraph_struct {
  BitArray** in_neighbours;
  BitArray** out_neighbours;
  uint16_t   nr_vertices;
};

typedef struct digraph_struct Digraph;

Digraph* new_digraph(uint16_t const);

void free_digraph(Digraph* const);
void clear_digraph(Digraph* const, uint16_t const);
void add_edge_digraph(Digraph* const, uint16_t const, uint16_t const);

static inline bool is_adjacent_digraph(Digraph const* const digraph,
                                       uint16_t const       i,
                                       uint16_t const       j) {
  DIGRAPHS_ASSERT(digraph != NULL);
  DIGRAPHS_ASSERT(i < digraph->nr_vertices);
  DIGRAPHS_ASSERT(j < digraph->nr_vertices);
  return get_bit_array(digraph->out_neighbours[i], j);
}

#ifdef DIGRAPHS_WITH_INCLUDED_BLISS
void automorphisms_digraph(Digraph const* const,
                           uint16_t const* const,
                           PermColl*,
                           BlissGraph*);
#else
void automorphisms_digraph(Digraph const* const,
                           uint16_t const* const,
                           PermColl*);
#endif

////////////////////////////////////////////////////////////////////////
// Undirected graphs (graphs)
////////////////////////////////////////////////////////////////////////

struct graph_struct {
  BitArray** neighbours;
  uint16_t   nr_vertices;
};

typedef struct graph_struct Graph;

Graph* new_graph(uint16_t const);

void free_graph(Graph* const);
void clear_graph(Graph* const, uint16_t const);
void add_edge_graph(Graph* const, uint16_t const, uint16_t const);

static inline bool is_adjacent_graph(Graph const* const graph,
                                     uint16_t const     i,
                                     uint16_t const     j) {
  DIGRAPHS_ASSERT(graph != NULL);
  DIGRAPHS_ASSERT(i < graph->nr_vertices);
  DIGRAPHS_ASSERT(j < graph->nr_vertices);
  return get_bit_array(graph->neighbours[i], j);
}

#ifdef DIGRAPHS_WITH_INCLUDED_BLISS
void automorphisms_graph(Graph const* const,
                         uint16_t const* const,
                         PermColl*,
                         BlissGraph*);
#else
void automorphisms_graph(Graph const* const, uint16_t const* const, PermColl*);
#endif
#endif  // DIGRAPHS_SRC_HOMOS_GRAPHS_H_
