#ifndef GRAPH_H
#define GRAPH_H

/*
Copyright (c) 1997-2020, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#ifdef __cplusplus
extern "C" {
#endif

#include "graphStructures.h"

#include "graphExtensions.h"

///////////////////////////////////////////////////////////////////////////////
// Definitions for higher-order operations at the vertex, edge and graph levels
///////////////////////////////////////////////////////////////////////////////

graphP	gp_New(void);

int		gp_InitGraph(graphP theGraph, int N);
void	gp_ReinitializeGraph(graphP theGraph);
int		gp_CopyAdjacencyLists(graphP dstGraph, graphP srcGraph);
int		gp_CopyGraph(graphP dstGraph, graphP srcGraph);
graphP	gp_DupGraph(graphP theGraph);

int		gp_CreateRandomGraph(graphP theGraph);
int		gp_CreateRandomGraphEx(graphP theGraph, int numEdges);

void	gp_Free(graphP *pGraph);

int		gp_Read(graphP theGraph, char *FileName);
#define WRITE_ADJLIST   1
#define WRITE_ADJMATRIX 2
#define WRITE_DEBUGINFO 3
int		gp_Write(graphP theGraph, char *FileName, int Mode);

int		gp_IsNeighbor(graphP theGraph, int u, int v);
int		gp_GetNeighborEdgeRecord(graphP theGraph, int u, int v);
int		gp_GetVertexDegree(graphP theGraph, int v);
int		gp_GetVertexInDegree(graphP theGraph, int v);
int		gp_GetVertexOutDegree(graphP theGraph, int v);

int		gp_GetArcCapacity(graphP theGraph);
int		gp_EnsureArcCapacity(graphP theGraph, int requiredArcCapacity);

int		gp_AddEdge(graphP theGraph, int u, int ulink, int v, int vlink);
int     gp_InsertEdge(graphP theGraph, int u, int e_u, int e_ulink,
                                       int v, int e_v, int e_vlink);

void	gp_HideEdge(graphP theGraph, int e);
void	gp_RestoreEdge(graphP theGraph, int e);
int		gp_HideVertex(graphP theGraph, int vertex);
int		gp_DeleteEdge(graphP theGraph, int e, int nextLink);

int		gp_ContractEdge(graphP theGraph, int e);
int		gp_IdentifyVertices(graphP theGraph, int u, int v, int eBefore);
int		gp_RestoreVertices(graphP theGraph);

int		gp_CreateDFSTree(graphP theGraph);
int		gp_SortVertices(graphP theGraph);
int 	gp_LowpointAndLeastAncestor(graphP theGraph);
int		gp_PreprocessForEmbedding(graphP theGraph);

int		gp_Embed(graphP theGraph, int embedFlags);
int		gp_TestEmbedResultIntegrity(graphP theGraph, graphP origGraph, int embedResult);

/* Possible Flags for gp_Embed.  The planar and outerplanar settings are supported
   natively.  The rest require extension modules. */

#define EMBEDFLAGS_PLANAR       1
#define EMBEDFLAGS_OUTERPLANAR  2

#define EMBEDFLAGS_DRAWPLANAR   (4|EMBEDFLAGS_PLANAR)

#define EMBEDFLAGS_SEARCHFORK23 (16|EMBEDFLAGS_OUTERPLANAR)
#define EMBEDFLAGS_SEARCHFORK4  (32|EMBEDFLAGS_OUTERPLANAR)
#define EMBEDFLAGS_SEARCHFORK33 (64|EMBEDFLAGS_PLANAR)

#define EMBEDFLAGS_SEARCHFORK5  (128|EMBEDFLAGS_PLANAR)

#define EMBEDFLAGS_MAXIMALPLANARSUBGRAPH    256
#define EMBEDFLAGS_PROJECTIVEPLANAR         512
#define EMBEDFLAGS_TOROIDAL                 1024

/* If LOGGING is defined, then write to the log, otherwise no-op
   By default, neither release nor DEBUG builds including LOGGING.
   Logging is useful for seeing details of how various algorithms
   handle a particular graph. */

//#define LOGGING
#ifdef LOGGING

#define gp_LogLine _LogLine
#define gp_Log _Log

void _LogLine(char *Line);
void _Log(char *Line);

#define gp_MakeLogStr1 _MakeLogStr1
#define gp_MakeLogStr2 _MakeLogStr2
#define gp_MakeLogStr3 _MakeLogStr3
#define gp_MakeLogStr4 _MakeLogStr4
#define gp_MakeLogStr5 _MakeLogStr5

char *_MakeLogStr1(char *format, int);
char *_MakeLogStr2(char *format, int, int);
char *_MakeLogStr3(char *format, int, int, int);
char *_MakeLogStr4(char *format, int, int, int, int);
char *_MakeLogStr5(char *format, int, int, int, int, int);

#else
#define gp_LogLine(Line)
#define gp_Log(Line)
#define gp_MakeLogStr1(format, one)
#define gp_MakeLogStr2(format, one, two)
#define gp_MakeLogStr3(format, one, two, three)
#define gp_MakeLogStr4(format, one, two, three, four)
#define gp_MakeLogStr5(format, one, two, three, four, five)
#endif

#ifdef __cplusplus
}
#endif

#endif
