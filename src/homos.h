/***************************************************************************
**
*A  homos.h                  graph homomorphisms              Julius Jonusas
**                                                            J. D. Mitchell 
**                                                            
**  Copyright (C) 2014 - Julius Jonusas and J. D. Mitchell 
**  This file is free software, see license information at the end.
**  
*/

#include "src/schreier-sims.h"
#include "bliss-0.72/bliss_C.h"
#include <setjmp.h>
#include <limits.h>
#include <config.h>

void homo_hook_print ();

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

BitArray* new_bit_array (UIntS nr_bits);
void set_bit_array (BitArray* bit_array, UIntS pos, bool val);
bool get_bit_array (BitArray* bit_array, UIntS pos);
void init_bit_array(BitArray* bit_array, bool val);

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Vertex
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

typedef UIntS Vertex;

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

Digraph* new_digraph (UIntS nr_verts);
void free_digraph (Digraph* digraph);
void add_edge_digraph (Digraph* digraph, Vertex i, Vertex j);

void DigraphHomomorphisms (Digraph* digraph1,
                           Digraph* digraph2,
                           void     (*hook_arg)(void*        user_param,
	                                        const UIntS  nr,
	                                        const UIntS  *map       ),
                           void*     user_param_arg,
                           UIntL     max_results_arg,
                           int       hint_arg,
                           bool      isinjective,
                           BitArray* image,
                           UIntS*    partial_map                           );

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

Graph* new_graph (UIntS nr_verts);
void free_graph (Graph* graph);
void add_edge_graph (Graph* graph, Vertex i, Vertex j);

void GraphHomomorphisms (Graph* graph1,
                         Graph* graph2,
                         void     (*hook_arg)(void*        user_param,
	                                      const UIntS  nr,
	                                      const UIntS  *map       ),
                         void*     user_param_arg,
                         UIntL     max_results_arg,
                         int       hint_arg,
                         bool      isinjective,
                         BitArray* image,
                         UIntS*    partial_map                           );
