/*

Header file for the digraphs.c file.

*/

//bool HasOutNeighbours(Obj digraph);
//bool HasDigraphSourceAndRange(Obj digraph);
//bool HasDigraphSource(Obj digraph);
//bool HasDigraphRange(Obj digraph);

Int DigraphNrVertices(Obj digraph);
Int DigraphNrEdges(Obj digraph);

Obj OutNeighbours(Obj digraph);
//Obj OutNeighboursOfVertex(Obj digraph, Int v);
Obj DigraphSource(Obj digraph);
Obj DigraphRange(Obj digraph);

static Obj FuncDIGRAPH_OUT_NBS(Obj self, Obj digraph, Obj source, Obj range);
static Obj FuncDIGRAPH_IN_NBS(Obj self, Obj digraph);
static Obj FuncDIGRAPH_SOURCE_RANGE(Obj self, Obj digraph);
