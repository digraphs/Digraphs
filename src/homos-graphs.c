/********************************************************************************
**
**  homos-graphs.h  (Di)graphs for the homomorphism finder J. D. Mitchell
**
**  Copyright (C) 2019 - J. D. Mitchell
**
**  This file is free software, see the digraphs/LICENSE.
**
********************************************************************************/

#include "homos-graphs.h"

// C headers
#include <stdlib.h>  // for free, malloc, NULL

// GAP headers
#include "src/compiled.h"  // for Obj, Int

// Digraphs headers
#include "digraphs-config.h"  // for DIGRAPHS_WITH_INCLUDED_BLISS
#include "digraphs-debug.h"   // for DIGRAPHS_ASSERT
#include "schreier-sims.h"    // for PERM_DEGREE

// Bliss headers
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

extern Obj GeneratorsOfGroup;

Digraph* new_digraph(uint16_t const nr_verts) {
  DIGRAPHS_ASSERT(nr_verts <= MAXVERTS);
  Digraph* digraph        = malloc(sizeof(Digraph));
  digraph->in_neighbours  = malloc(nr_verts * sizeof(BitArray));
  digraph->out_neighbours = malloc(nr_verts * sizeof(BitArray));
  for (uint16_t i = 0; i < nr_verts; i++) {
    digraph->in_neighbours[i]  = new_bit_array(nr_verts);
    digraph->out_neighbours[i] = new_bit_array(nr_verts);
  }
  digraph->nr_vertices = nr_verts;
  return digraph;
}

Graph* new_graph(uint16_t const nr_verts) {
  DIGRAPHS_ASSERT(nr_verts <= MAXVERTS);
  Graph* graph      = malloc(sizeof(Graph));
  graph->neighbours = malloc(nr_verts * sizeof(BitArray));
  for (uint16_t i = 0; i < nr_verts; i++) {
    graph->neighbours[i] = new_bit_array(nr_verts);
  }
  graph->nr_vertices = nr_verts;
  return graph;
}

// free_digraph is not currently used, but kept in case it is required in
// the future. JDM 2019

// void free_digraph(Digraph* const digraph) {
//   DIGRAPHS_ASSERT(digraph != NULL);
//   uint16_t const nr = digraph->nr_vertices;
//   for (uint16_t i = 0; i < nr; i++) {
//     free_bit_array(digraph->in_neighbours[i]);
//     free_bit_array(digraph->out_neighbours[i]);
//   }
//   free(digraph->in_neighbours);
//   free(digraph->out_neighbours);
//   free(digraph);
// }

// free_graph is not currently used, but kept in case it is required in
// the future. JDM 2019

// void free_graph(Graph* const graph) {
//   DIGRAPHS_ASSERT(graph != NULL);
//   uint16_t const nr = graph->nr_vertices;
//   for (uint16_t i = 0; i < nr; i++) {
//     free_bit_array(graph->neighbours[i]);
//   }
//   free(graph->neighbours);
//   free(graph);
// }

void clear_digraph(Digraph* const digraph, uint16_t const nr_verts) {
  DIGRAPHS_ASSERT(digraph != NULL);
  DIGRAPHS_ASSERT(nr_verts <= MAXVERTS);
  for (uint16_t i = 0; i < nr_verts; i++) {
    init_bit_array(digraph->in_neighbours[i], false, nr_verts);
    init_bit_array(digraph->out_neighbours[i], false, nr_verts);
  }
  digraph->nr_vertices = nr_verts;
}

void clear_graph(Graph* const graph, uint16_t const nr_verts) {
  DIGRAPHS_ASSERT(graph != NULL);
  DIGRAPHS_ASSERT(nr_verts <= MAXVERTS);
  for (uint16_t i = 0; i < nr_verts; i++) {
    init_bit_array(graph->neighbours[i], false, nr_verts);
  }
  graph->nr_vertices = nr_verts;
}

void add_edge_digraph(Digraph* const digraph,
                      uint16_t const i,
                      uint16_t const j) {
  DIGRAPHS_ASSERT(digraph != NULL);
  DIGRAPHS_ASSERT(i < digraph->nr_vertices);
  DIGRAPHS_ASSERT(j < digraph->nr_vertices);
  set_bit_array(digraph->out_neighbours[i], j, true);
  set_bit_array(digraph->in_neighbours[j], i, true);
}

void add_edge_graph(Graph* const graph, uint16_t const i, uint16_t const j) {
  DIGRAPHS_ASSERT(graph != NULL);
  DIGRAPHS_ASSERT(i < graph->nr_vertices);
  DIGRAPHS_ASSERT(j < graph->nr_vertices);
  set_bit_array(graph->neighbours[i], j, true);
  set_bit_array(graph->neighbours[j], i, true);
}

#ifdef DIGRAPHS_WITH_INCLUDED_BLISS
static void init_bliss_graph_from_digraph(Digraph const* const  digraph,
                                          uint16_t const* const colors,
                                          BlissGraph*           bg) {
  DIGRAPHS_ASSERT(digraph != NULL);
  DIGRAPHS_ASSERT(colors != NULL);
  bliss_digraphs_clear(bg);
  uint16_t       out_color = 0;
  uint16_t const n         = digraph->nr_vertices;
  for (uint16_t i = 0; i < n; i++) {
    out_color = (colors[i] >= out_color ? colors[i] + 1 : out_color);
    bliss_digraphs_change_color(bg, i, colors[i]);
  }
  uint16_t const in_color = out_color + 1;
  for (uint16_t i = 0; i < n; i++) {
    bliss_digraphs_change_color(bg, i + n, out_color);
    bliss_digraphs_change_color(bg, i + 2 * n, in_color);
    bliss_digraphs_add_edge(bg, i, i + n);
    bliss_digraphs_add_edge(bg, i + 2 * n, i);
  }
  for (uint16_t i = 0; i < n; i++) {
    for (uint16_t j = 0; j < n; j++) {
      if (is_adjacent_digraph(digraph, i, j)) {
        bliss_digraphs_add_edge(bg, i + n, j + 2 * n);
      }
    }
  }
}
#else
static BlissGraph* new_bliss_graph_from_digraph(Digraph const* const  digraph,
                                                uint16_t const* const colors) {
  DIGRAPHS_ASSERT(digraph != NULL);
  DIGRAPHS_ASSERT(colors != NULL);
  BlissGraph*    bg;
  uint16_t       out_color = 0;
  uint16_t const n         = digraph->nr_vertices;
  bg                       = bliss_digraphs_new(0);
  for (uint16_t i = 0; i < n; i++) {
    out_color = (colors[i] >= out_color ? colors[i] + 1 : out_color);
    bliss_digraphs_add_vertex(bg, colors[i]);
  }
  uint16_t const in_color = out_color + 1;
  for (uint16_t i = n; i < 2 * n; i++) {
    bliss_digraphs_add_vertex(bg, out_color);
  }
  for (uint16_t i = 0; i < n; i++) {
    bliss_digraphs_add_vertex(bg, in_color);
    bliss_digraphs_add_edge(bg, i, i + n);
    bliss_digraphs_add_edge(bg, i + 2 * n, i);
  }
  for (uint16_t i = 0; i < n; i++) {
    for (uint16_t j = 0; j < n; j++) {
      if (is_adjacent_digraph(digraph, i, j)) {
        bliss_digraphs_add_edge(bg, i + n, j + 2 * n);
      }
    }
  }
  return bg;
}
#endif

#ifdef DIGRAPHS_WITH_INCLUDED_BLISS
static void init_bliss_graph_from_graph(Graph const* const    graph,
                                        uint16_t const* const colors,
                                        BlissGraph*           bg) {
  DIGRAPHS_ASSERT(graph != NULL);
  DIGRAPHS_ASSERT(colors != NULL);
  bliss_digraphs_clear(bg);
  uint16_t const n = graph->nr_vertices;
  for (uint16_t i = 0; i < n; i++) {
    bliss_digraphs_change_color(bg, i, colors[i]);
  }
  for (uint16_t i = 0; i < n; i++) {
    for (uint16_t j = 0; j < n; j++) {
      if (is_adjacent_graph(graph, i, j)) {
        bliss_digraphs_add_edge(bg, i, j);
      }
    }
  }
}
#else
static BlissGraph* new_bliss_graph_from_graph(Graph const* const    graph,
                                              uint16_t const* const colors) {
  DIGRAPHS_ASSERT(graph != NULL);
  DIGRAPHS_ASSERT(colors != NULL);
  BlissGraph*    bg;
  uint16_t const n = graph->nr_vertices;
  bg               = bliss_digraphs_new(0);
  for (uint16_t i = 0; i < n; i++) {
    bliss_digraphs_add_vertex(bg, colors[i]);
  }
  for (uint16_t i = 0; i < n; i++) {
    for (uint16_t j = 0; j < n; j++) {
      if (is_adjacent_graph(graph, i, j)) {
        bliss_digraphs_add_edge(bg, i, j);
      }
    }
  }
  return bg;
}
#endif

static void bliss_hook(void*               user_param_arg,  // perm_coll!
                       unsigned int        N,
                       const unsigned int* aut) {
  Perm               p   = new_perm(PERM_DEGREE);
  unsigned int const min = (N < PERM_DEGREE ? N : PERM_DEGREE);
  for (uint16_t i = 0; i < min; i++) {
    DIGRAPHS_ASSERT(aut[i] < min);
    p[i] = aut[i];
  }
  for (uint16_t i = min; i < PERM_DEGREE; i++) {
    p[i] = i;
  }
  add_perm_coll((PermColl*) user_param_arg, p);
}

#ifdef DIGRAPHS_WITH_INCLUDED_BLISS
void automorphisms_digraph(Digraph const* const  digraph,
                           uint16_t const* const colors,
                           PermColl*             out,
                           BlissGraph*           bg) {
  DIGRAPHS_ASSERT(digraph != NULL);
  DIGRAPHS_ASSERT(out != NULL);
  DIGRAPHS_ASSERT(bg != NULL);
  clear_perm_coll(out);
  out->degree = PERM_DEGREE;
  init_bliss_graph_from_digraph(digraph, colors, bg);
  bliss_digraphs_find_automorphisms(bg, bliss_hook, out, 0);
}
#else
void automorphisms_digraph(Digraph const* const  digraph,
                           uint16_t const* const colors,
                           PermColl*             out) {
  DIGRAPHS_ASSERT(digraph != NULL);
  DIGRAPHS_ASSERT(out != NULL);
  clear_perm_coll(out);
  out->degree    = PERM_DEGREE;
  BlissGraph* bg = new_bliss_graph_from_digraph(digraph, colors);
  bliss_digraphs_find_automorphisms(bg, bliss_hook, out, 0);
  bliss_digraphs_release(bg);
}
#endif

#ifdef DIGRAPHS_WITH_INCLUDED_BLISS
void automorphisms_graph(Graph const* const    graph,
                         uint16_t const* const colors,
                         PermColl*             out,
                         BlissGraph*           bg) {
  DIGRAPHS_ASSERT(graph != NULL);
  DIGRAPHS_ASSERT(out != NULL);
  DIGRAPHS_ASSERT(bg != NULL);
  clear_perm_coll(out);
  out->degree = PERM_DEGREE;
  init_bliss_graph_from_graph(graph, colors, bg);
  bliss_digraphs_find_automorphisms(bg, bliss_hook, out, 0);
}
#else
void automorphisms_graph(Graph const* const    graph,
                         uint16_t const* const colors,
                         PermColl*             out) {
  DIGRAPHS_ASSERT(graph != NULL);
  DIGRAPHS_ASSERT(out != NULL);
  clear_perm_coll(out);
  out->degree    = PERM_DEGREE;
  BlissGraph* bg = new_bliss_graph_from_graph(graph, colors);
  bliss_digraphs_find_automorphisms(bg, bliss_hook, out, 0);
  bliss_digraphs_release(bg);
}
#endif
