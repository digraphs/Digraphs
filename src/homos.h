/***************************************************************************
**
*A  homos.h                  graph homomorphisms              Julius Jonusas
**                                                            J. D. Mitchell 
**                                                            
**  Copyright (C) 2014-15 - Julius Jonusas and J. D. Mitchell 
**  This file is free software, see license information at the end.
**  
*/

#include "src/schreier-sims.h"
#include "bliss-0.72/bliss_C.h"
#include <setjmp.h>

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

void  add_edges_homos_graph (HomosGraph* graph, 
                             UIntS from_vert, 
                             UIntS to_vert);

void  free_homos_graph      (HomosGraph* graph);

////////////////////////////////////////////////////////////////////////////////
// new stuff
////////////////////////////////////////////////////////////////////////////////

typedef unsigned long int Block;

struct bit_array_struct {
  UIntS  nr_bits;   // number of bits
  UIntS  nr_blocks; // number of blocks
  UIntS  last_bit;  // the position of the last bit used in the last block
  Block* blocks;    // the blocks themselves
};

typedef struct bit_array_struct BitArray;

struct digraph_struct {
  BitArray** in_neighbours;
  BitArray** out_neighbours;
  UIntS      nr_vertices;
};

typedef struct digraph_struct Digraph;
typedef UIntS Vertex;
