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


struct homos_graph_struct {
  UIntL* neighbours;
  UIntS  nr_verts;
};

typedef struct homos_graph_struct HomosGraph;


void homo_hook_print ();

void GraphHomomorphisms (HomosGraph*  graph1, 
                         HomosGraph*  graph2,
                         void         (*hook)(void*        user_param,
	                                      const UIntS  nr,
	                                      const UIntS  *map       ),
                         void*        user_param_arg,
                         UIntL        max_results_arg,
                         int          hint_arg, 
                         bool         isinjective, 
                         int*         image,
                         UIntS*       map     );

HomosGraph* new_homos_graph (UIntS nr_verts);

void  add_edge_homos_graph (HomosGraph* graph, 
                            UIntS from_vert, 
                            UIntS to_vert);

void  free_homos_graph     (HomosGraph* graph);

////////////////////////////////////////////////////////////////////////////////
// new stuff
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

struct digraph_struct {
  BitArray** in_neighbours;
  BitArray** out_neighbours;
  UIntS      nr_vertices;
};

typedef struct digraph_struct Digraph;
typedef UIntS Vertex;

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
