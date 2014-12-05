
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

#ifdef SYS_IS_64_BIT
#define MAXVERTS 512
typedef unsigned long int UIntL;
#define SMALLINTLIMIT 1152921504606846976
#define SYS_BITS 64
#else
#define MAXVERTS 256
typedef unsigned int UIntL;
#define SMALLINTLIMIT 268435456
#define SYS_BITS 32
#endif

typedef unsigned short int UIntS;

struct homos_graph_struct {
  UIntL* neighbours;
  UIntS  nr_verts;
};

typedef struct homos_graph_struct HomosGraph;

void homo_hook_print ();

void GraphHomomorphisms (HomosGraph*  graph1, 
                         HomosGraph*  graph2,
                         void         hook_arg (),
                         void*        user_param_arg,
                         UIntL        max_results_arg,
                         int          hint_arg, 
                         bool         isinjective     );

HomosGraph* new_homos_graph (UIntS nr_verts);
void  add_edges_homos_graph (HomosGraph* graph, UIntS from_vert, UIntS to_vert);
void  free_homos_graph (HomosGraph* graph);


