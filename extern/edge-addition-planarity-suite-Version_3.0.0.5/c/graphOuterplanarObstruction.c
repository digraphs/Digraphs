/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "graph.h"

/* Imported functions */

extern void _ClearVisitedFlags(graphP);

extern int  _JoinBicomps(graphP theGraph);

extern int  _InitializeNonplanarityContext(graphP theGraph, int v, int R);
extern int  _MarkHighestXYPath(graphP theGraph);

//extern int  _FindUnembeddedEdgeToAncestor(graphP theGraph, int cutVertex, int *pAncestor, int *pDescendant);
extern int  _FindUnembeddedEdgeToCurVertex(graphP theGraph, int cutVertex, int *pDescendant);
extern int  _FindUnembeddedEdgeToSubtree(graphP theGraph, int ancestor, int SubtreeRoot, int *pDescendant);

extern int  _MarkPathAlongBicompExtFace(graphP theGraph, int startVert, int endVert);

extern int  _AddAndMarkEdge(graphP theGraph, int ancestor, int descendant);

extern int  _DeleteUnmarkedVerticesAndEdges(graphP theGraph);

/* Private function declarations (exported to system) */

int  _IsolateOuterplanarObstruction(graphP theGraph, int v, int R);

int  _ChooseTypeOfNonOuterplanarityMinor(graphP theGraph, int v, int R);

int  _IsolateOuterplanarityObstructionA(graphP theGraph);
int  _IsolateOuterplanarityObstructionB(graphP theGraph);
int  _IsolateOuterplanarityObstructionE(graphP theGraph);

/****************************************************************************
 _ChooseTypeOfNonOuterplanarityMinor()
 A constant time implementation is easily feasible but only constant amortized
 time is needed for the outerplanarity obstruction isolation, which also
 benefits from having the bicomp rooted by R oriented.
 If an extension algorithm requires constant actual time, then this function
 should not be used and instead the minor should be decided without orienting
 the bicomp.
 ****************************************************************************/

int  _ChooseTypeOfNonOuterplanarityMinor(graphP theGraph, int v, int R)
{
int  X, Y, W;

	 // Create the initial non-outerplanarity obstruction isolator state.
     if (_InitializeNonplanarityContext(theGraph, v, R) != OK)
         return NOTOK;

     R = theGraph->IC.r;
     X = theGraph->IC.x;
     Y = theGraph->IC.y;
     W = theGraph->IC.w;

     // If the root copy is not a root copy of the current vertex v,
     // then the Walkdown terminated on a descendant bicomp, which is Minor A.
     if (gp_GetPrimaryVertexFromRoot(theGraph, R) != v)
     {
         theGraph->IC.minorType |= MINORTYPE_A;
         return OK;
     }

     // If W has a pertinent child bicomp, then we've found Minor B.
     // Notice this is different from planarity, in which minor B is indicated
     // only if the pertinent child bicomp is also future pertinent.
     if (gp_IsVertex(gp_GetVertexPertinentRootsList(theGraph, W)))
     {
         theGraph->IC.minorType |= MINORTYPE_B;
         return OK;
     }

     // The only other result is minor E (we will search for the X-Y path later)
     theGraph->IC.minorType |= MINORTYPE_E;
     return OK;
}

/****************************************************************************
 _IsolateOuterplanarObstruction()
 ****************************************************************************/

int  _IsolateOuterplanarObstruction(graphP theGraph, int v, int R)
{
int  RetVal;

/* A subgraph homeomorphic to K_{2,3} or K_4 will be isolated by using the visited
   flags, set=keep edge/vertex and clear=omit. Here we initialize to omit all, then we
   subsequently set visited on all edges and vertices in the homeomorph. */

	 _ClearVisitedFlags(theGraph);

/* Next we determineg which of the non-outerplanarity Minors was encountered
        and the principal bicomp on which the isolator will focus attention. */

     if (_ChooseTypeOfNonOuterplanarityMinor(theGraph, v, R) != OK)
         return NOTOK;

/* Find the path connecting the pertinent vertex w with the current vertex v */

     if (theGraph->IC.minorType & MINORTYPE_B)
     {
    	 isolatorContextP IC = &theGraph->IC;
    	 int SubtreeRoot = gp_GetVertexLastPertinentRootChild(theGraph, IC->w);

         if (_FindUnembeddedEdgeToSubtree(theGraph, IC->v, SubtreeRoot, &IC->dw) != TRUE)
             return NOTOK;
     }
     else
     {
     isolatorContextP IC = &theGraph->IC;

         if (_FindUnembeddedEdgeToCurVertex(theGraph, IC->w, &IC->dw) != TRUE)
             return NOTOK;
     }

/* For minor E, we need to find and mark an X-Y path */

     if (theGraph->IC.minorType & MINORTYPE_E)
     {
        if (_MarkHighestXYPath(theGraph) != TRUE)
             return NOTOK;
     }

/* Call the appropriate isolator */

     if (theGraph->IC.minorType & MINORTYPE_A)
         RetVal = _IsolateOuterplanarityObstructionA(theGraph);
     else if (theGraph->IC.minorType & MINORTYPE_B)
         RetVal = _IsolateOuterplanarityObstructionB(theGraph);
     else if (theGraph->IC.minorType & MINORTYPE_E)
         RetVal = _IsolateOuterplanarityObstructionE(theGraph);
     else
    	 RetVal = NOTOK;

/* Delete the unmarked edges and vertices, and return */

     if (RetVal == OK)
         RetVal = _DeleteUnmarkedVerticesAndEdges(theGraph);

     return RetVal;
}

/****************************************************************************
 _IsolateOuterplanarityObstructionA(): Isolate a K2,3 homeomorph
 ****************************************************************************/

int  _IsolateOuterplanarityObstructionA(graphP theGraph)
{
isolatorContextP IC = &theGraph->IC;

     if (_MarkPathAlongBicompExtFace(theGraph, IC->r, IC->r) != OK ||
         theGraph->functions.fpMarkDFSPath(theGraph, IC->v, IC->r) != OK ||
         theGraph->functions.fpMarkDFSPath(theGraph, IC->w, IC->dw) != OK ||
         _JoinBicomps(theGraph) != OK ||
         _AddAndMarkEdge(theGraph, IC->v, IC->dw) != OK)
         return NOTOK;

     return OK;
}

/****************************************************************************
 _IsolateOuterplanarityObstructionB(): Isolate a K2,3 homeomorph
 ****************************************************************************/

int  _IsolateOuterplanarityObstructionB(graphP theGraph)
{
isolatorContextP IC = &theGraph->IC;

     if (_MarkPathAlongBicompExtFace(theGraph, IC->r, IC->r) != OK ||
         theGraph->functions.fpMarkDFSPath(theGraph, IC->w, IC->dw) != OK ||
         _JoinBicomps(theGraph) != OK ||
         _AddAndMarkEdge(theGraph, IC->v, IC->dw) != OK)
         return NOTOK;

     return OK;
}

/****************************************************************************
 _IsolateOuterplanarityObstructionE(): Isolate a K4 homeomorph
 ****************************************************************************/

int  _IsolateOuterplanarityObstructionE(graphP theGraph)
{
isolatorContextP IC = &theGraph->IC;

     if (_MarkPathAlongBicompExtFace(theGraph, IC->r, IC->r) != OK ||
         theGraph->functions.fpMarkDFSPath(theGraph, IC->w, IC->dw) != OK ||
         _JoinBicomps(theGraph) != OK ||
         _AddAndMarkEdge(theGraph, IC->v, IC->dw) != OK)
         return NOTOK;

     return OK;
}
