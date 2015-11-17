/********************************************************************************
**
*A  homos.h               di/graph homomorphisms              Julius Jonusas
**                                                            J. D. Mitchell 
**                                                            
**  Copyright (C) 2014-15 - Julius Jonusas and J. D. Mitchell 
**
**  This file is free software, see the digraphs/LICENSE.
**  
********************************************************************************/

#ifndef HOMOS_HOMOS_H
#define HOMOS_HOMOS_H 1

#include "src/schreier-sims.h"
#include "bliss-0.73/bliss_C.h"
#include <setjmp.h>
#include <limits.h>
#include <config.h>

void homo_hook_print ();
typedef UIntS Vertex;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// BitArrays
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

typedef unsigned long int Block;

struct bit_array_struct {
  UIntS  nr_bits;   // number of bits
  UIntS  nr_blocks; // number of blocks
  Block* blocks;    // the blocks themselves
};

typedef struct bit_array_struct BitArray;

////////////////////////////////////////////////////////////////////////////////
// new_bit_array: get a pointer to a new BitArray with space for <nr_bits>
// bits, and with every bit set to false.
////////////////////////////////////////////////////////////////////////////////

BitArray* new_bit_array (UIntS nr_bits);

////////////////////////////////////////////////////////////////////////////////
// free_bit_array: free the BitArray pointed to by bit_array.
////////////////////////////////////////////////////////////////////////////////

void free_bit_array (BitArray* bit_array);

////////////////////////////////////////////////////////////////////////////////
// init_bit_array: set every value in the BitArray pointed to by <bit_array> to
// the value <val>.
////////////////////////////////////////////////////////////////////////////////

void init_bit_array(BitArray* bit_array, bool val);

////////////////////////////////////////////////////////////////////////////////
// set_bit_array: set the <pos>th bit of the BitArray pointed to by <bit_array>
// to the value <val>.
////////////////////////////////////////////////////////////////////////////////

void set_bit_array (BitArray* bit_array, UIntS pos, bool val);

////////////////////////////////////////////////////////////////////////////////
// get_bit_array: get the value in position <pos> of the BitArray pointer
// <bit_array>.
////////////////////////////////////////////////////////////////////////////////

bool get_bit_array (BitArray* bit_array, UIntS pos);

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Digraphs (undirected)
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

struct digraph_struct {
  BitArray** in_neighbours;
  BitArray** out_neighbours;
  UIntS      nr_vertices;
};

typedef struct digraph_struct Digraph;

////////////////////////////////////////////////////////////////////////////////
// new_digraph: returns a pointer to a Digraph with <nr_verts> vertices and no
// edges.
////////////////////////////////////////////////////////////////////////////////

Digraph* new_digraph (UIntS nr_verts);

////////////////////////////////////////////////////////////////////////////////
// free_digraph: free the Digraph pointed to by <digraph>.
////////////////////////////////////////////////////////////////////////////////

void free_digraph (Digraph* digraph);

////////////////////////////////////////////////////////////////////////////////
// add_edge_digraph: add an edge from Vertex <i> to Vertex <j> in the Digraph
// pointed to by <digraph>.
////////////////////////////////////////////////////////////////////////////////

void add_edge_digraph (Digraph* digraph, Vertex i, Vertex j);

////////////////////////////////////////////////////////////////////////////////
// DigraphHomomorphisms: TODO add description of args
////////////////////////////////////////////////////////////////////////////////

void DigraphHomomorphisms (Digraph* digraph1,
                           Digraph* digraph2,
                           void     (*hook_arg)(void*        user_param,
	                                        const UIntS  nr,
	                                        const UIntS  *map       ),
                           void*     user_param_arg,
                           UIntL     max_results_arg,
                           int       hint_arg,
                           BitArray* image,
                           UIntS*    partial_map,
                           UIntS*    colors1, 
                           UIntS*    colors2                           );

////////////////////////////////////////////////////////////////////////////////
// DigraphMonomorphisms: TODO add description of args
////////////////////////////////////////////////////////////////////////////////

void DigraphMonomorphisms (Digraph* digraph1,
                           Digraph* digraph2,
                           void     (*hook_arg)(void*        user_param,
	                                        const UIntS  nr,
	                                        const UIntS  *map       ),
                           void*     user_param_arg,
                           UIntL     max_results_arg,
                           BitArray* image,
                           UIntS*    partial_map,
                           UIntS*    colors1, 
                           UIntS*    colors2                           );

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Graphs (undirected)
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

struct graph_struct {
  BitArray** neighbours;
  UIntS      nr_vertices;
};

typedef struct graph_struct Graph;

////////////////////////////////////////////////////////////////////////////////
// new_graph: returns a pointer to a Graph with nr_verts vertices and no
// edges.
////////////////////////////////////////////////////////////////////////////////

Graph* new_graph (UIntS nr_verts);

////////////////////////////////////////////////////////////////////////////////
// free_graph: frees the Graph pointed to by <graph>.
////////////////////////////////////////////////////////////////////////////////

void free_graph (Graph* graph);

////////////////////////////////////////////////////////////////////////////////
// add_edge_graph: add an edge from Vertex <i> to Vertex <j> in the Graph
// pointed to by <graph>.
////////////////////////////////////////////////////////////////////////////////

void add_edge_graph (Graph* graph, Vertex i, Vertex j);

////////////////////////////////////////////////////////////////////////////////
// GraphHomomorphisms: TODO add description of args
////////////////////////////////////////////////////////////////////////////////

void GraphHomomorphisms (Graph* graph1,
                         Graph* graph2,
                         void     (*hook_arg)(void*        user_param,
	                                      const UIntS  nr,
	                                      const UIntS  *map       ),
                         void*     user_param_arg,
                         UIntL     max_results_arg,
                         int       hint_arg,
                         BitArray* image,
                         UIntS*    partial_map,
                         UIntS*    colors1, 
                         UIntS*    colors2                           );

////////////////////////////////////////////////////////////////////////////////
// GraphMonomorphisms: TODO add description of args
////////////////////////////////////////////////////////////////////////////////

void GraphMonomorphisms (Graph*   graph1,
                         Graph*   graph2,
                         void     (*hook_arg)(void*        user_param,
	                                      const UIntS  nr,
	                                      const UIntS  *map       ),
                         void*     user_param_arg,
                         UIntL     max_results_arg,
                         BitArray* image_arg,
                         UIntS     *partial_map_arg,
                         UIntS*    colors1, 
                         UIntS*    colors2                           );
#endif
