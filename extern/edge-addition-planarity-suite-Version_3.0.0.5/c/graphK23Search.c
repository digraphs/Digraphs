/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#include "graph.h"

/* Imported functions */

extern void _ClearVisitedFlags(graphP);

extern int  _GetNeighborOnExtFace(graphP theGraph, int curVertex, int *pPrevLink);
extern int  _OrientVerticesInBicomp(graphP theGraph, int BicompRoot, int PreserveSigns);
extern int  _JoinBicomps(graphP theGraph);

extern int  _MarkHighestXYPath(graphP theGraph);

extern int  _FindUnembeddedEdgeToAncestor(graphP theGraph, int cutVertex, int *pAncestor, int *pDescendant);
extern int  _FindUnembeddedEdgeToCurVertex(graphP theGraph, int cutVertex, int *pDescendant);
extern int  _FindUnembeddedEdgeToSubtree(graphP theGraph, int ancestor, int SubtreeRoot, int *pDescendant);

extern int  _MarkPathAlongBicompExtFace(graphP theGraph, int startVert, int endVert);

extern int  _AddAndMarkEdge(graphP theGraph, int ancestor, int descendant);

extern int  _DeleteUnmarkedVerticesAndEdges(graphP theGraph);

extern int  _ChooseTypeOfNonOuterplanarityMinor(graphP theGraph, int v, int R);
extern int  _IsolateOuterplanarityObstructionA(graphP theGraph);
extern int  _IsolateOuterplanarityObstructionB(graphP theGraph);

/* Private function declarations for K_{2,3} searching */

int  _SearchForK23InBicomp(graphP theGraph, int v, int R);
int  _IsolateOuterplanarityObstructionE1orE2(graphP theGraph);
int  _IsolateOuterplanarityObstructionE3orE4(graphP theGraph);

/****************************************************************************
 _SearchForK23InBicomp()
 ****************************************************************************/

int  _SearchForK23InBicomp(graphP theGraph, int v, int R)
{
isolatorContextP IC = &theGraph->IC;
int X, Y, XPrevLink, YPrevLink;

/* Begin by determining whether minor A, B or E is detected */

     if (_ChooseTypeOfNonOuterplanarityMinor(theGraph, v, R) != OK)
         return NOTOK;

/* Minors A and B result in the desired K_{2,3} homeomorph,
    so we isolate it and return NONEMBEDDABLE. */

     if (theGraph->IC.minorType & (MINORTYPE_A|MINORTYPE_B))
     {
         _ClearVisitedFlags(theGraph);

         if (theGraph->IC.minorType & MINORTYPE_A)
         {
             if (_FindUnembeddedEdgeToCurVertex(theGraph, IC->w, &IC->dw) != TRUE)
                 return NOTOK;

             if (_IsolateOuterplanarityObstructionA(theGraph) != OK)
                 return NOTOK;
         }
         else if (theGraph->IC.minorType & MINORTYPE_B)
         {
        	 int SubtreeRoot = gp_GetVertexLastPertinentRootChild(theGraph, IC->w);

             if (_FindUnembeddedEdgeToSubtree(theGraph, IC->v, SubtreeRoot, &IC->dw) != TRUE)
                 return NOTOK;

             if (_IsolateOuterplanarityObstructionB(theGraph) != OK)
                 return NOTOK;
         }

         if (_DeleteUnmarkedVerticesAndEdges(theGraph) != OK)
             return NOTOK;

         return NONEMBEDDABLE;
     }

/* For minor E (a K_4) , we run the additional tests to see if a K_{2,3} is
    entangled with the K_4.  If not, then we return OK to indicate that
    the outerplanarity embedder should proceed as if the K_4 had not
    been found. */

    /* If any vertices other than R, X, Y and W exist along the
        external face, then we can obtain a K_{2,3} by minor E1 or E2 */

     X = IC->x;
     Y = IC->y;
     XPrevLink = 1;
     YPrevLink = 0;
     if (IC->w != _GetNeighborOnExtFace(theGraph, X, &XPrevLink) ||
         IC->w != _GetNeighborOnExtFace(theGraph, Y, &YPrevLink))
     {
         _ClearVisitedFlags(theGraph);

         if (_IsolateOuterplanarityObstructionE1orE2(theGraph) != OK)
             return NOTOK;

         if (_DeleteUnmarkedVerticesAndEdges(theGraph) != OK)
             return NOTOK;

         return NONEMBEDDABLE;
     }

 /* If X, Y or W make either a direct back edge connection or a
        connection through a separated child bicomp to an ancestor of
        the current vertex v, then we can obtain a K_{2,3} by minor
        E3 or E4. Note that this question is query on X, Y and W is
        equivalent to the planarity version of external activity. */

     gp_UpdateVertexFuturePertinentChild(theGraph, X, v);
     gp_UpdateVertexFuturePertinentChild(theGraph, Y, v);
     gp_UpdateVertexFuturePertinentChild(theGraph, IC->w, v);
     if (FUTUREPERTINENT(theGraph, X, v) ||
         FUTUREPERTINENT(theGraph, Y, v) ||
         FUTUREPERTINENT(theGraph, IC->w, v))
     {
         _ClearVisitedFlags(theGraph);

         if (_IsolateOuterplanarityObstructionE3orE4(theGraph) != OK)
             return NOTOK;

         if (_DeleteUnmarkedVerticesAndEdges(theGraph) != OK)
             return NOTOK;

         return NONEMBEDDABLE;
     }

/* The extra cases for finding a K_{2,3} failed, so the bicomp rooted
    by R is a separable subgraph of the input that is isomorphic
    to K_4.  So, we restore the original vertex orientation of
    the bicomp (because it's polite, not because we really have to).
    Then, we return OK to tell the outerplanarity embedder that it
    can ignore this K_4 and keep processing. */

    if (_OrientVerticesInBicomp(theGraph, R, 1) != OK)
    	return NOTOK;

    return OK;
}

/****************************************************************************
 _IsolateOuterplanarityObstructionE1orE2()
 ****************************************************************************/

int  _IsolateOuterplanarityObstructionE1orE2(graphP theGraph)
{
isolatorContextP IC = &theGraph->IC;
int XPrevLink = 1;

     if (_MarkHighestXYPath(theGraph) != TRUE)
         return NOTOK;

/* Isolate E1 */

     if (theGraph->IC.px != theGraph->IC.x)
     {
         if (_MarkPathAlongBicompExtFace(theGraph, IC->r, IC->w) != OK ||
             _MarkPathAlongBicompExtFace(theGraph, IC->py, IC->r) != OK)
             return NOTOK;
     }
     else if (theGraph->IC.py != theGraph->IC.y)
     {
         if (_MarkPathAlongBicompExtFace(theGraph, IC->r, IC->x) != OK ||
             _MarkPathAlongBicompExtFace(theGraph, IC->w, IC->r) != OK)
             return NOTOK;
     }

/* Isolate E2 */

     else if (IC->w != _GetNeighborOnExtFace(theGraph, IC->x, &XPrevLink))
     {
         if (_MarkPathAlongBicompExtFace(theGraph, IC->r, IC->y) != OK)
             return NOTOK;
     }

     else
     {
         if (_MarkPathAlongBicompExtFace(theGraph, IC->x, IC->r) != OK)
             return NOTOK;
     }

/* Final bits are in common */

     if (_FindUnembeddedEdgeToCurVertex(theGraph, IC->w, &IC->dw) != TRUE ||
         theGraph->functions.fpMarkDFSPath(theGraph, IC->w, IC->dw) != OK ||
         _JoinBicomps(theGraph) != OK ||
         _AddAndMarkEdge(theGraph, IC->v, IC->dw) != OK)
         return NOTOK;

     return OK;
}

/****************************************************************************
 _IsolateOuterplanarityObstructionE3orE4()
 ****************************************************************************/

int  _IsolateOuterplanarityObstructionE3orE4(graphP theGraph)
{
isolatorContextP IC = &theGraph->IC;
int u, d, XorY;

	 // Minor E3
	 gp_UpdateVertexFuturePertinentChild(theGraph, theGraph->IC.x, theGraph->IC.v);
     gp_UpdateVertexFuturePertinentChild(theGraph, theGraph->IC.y, theGraph->IC.v);
     if (FUTUREPERTINENT(theGraph, theGraph->IC.x, theGraph->IC.v) ||
         FUTUREPERTINENT(theGraph, theGraph->IC.y, theGraph->IC.v))
     {
         if (_MarkHighestXYPath(theGraph) != TRUE)
             return NOTOK;

         gp_UpdateVertexFuturePertinentChild(theGraph, theGraph->IC.x, theGraph->IC.v);
         if (FUTUREPERTINENT(theGraph, theGraph->IC.x, theGraph->IC.v))
              XorY = theGraph->IC.x;
         else XorY = theGraph->IC.y;

         /* The cases of X future pertinent and Y future pertinent
                are the same except for the bicomp external face marking
                (because parameter order is important) */

         if (XorY == theGraph->IC.x)
         {
             if (_MarkPathAlongBicompExtFace(theGraph, IC->x, IC->w) != OK ||
                 _MarkPathAlongBicompExtFace(theGraph, IC->y, IC->r) != OK)
                 return NOTOK;
         }
         else
         {
             if (_MarkPathAlongBicompExtFace(theGraph, IC->r, IC->x) != OK ||
                 _MarkPathAlongBicompExtFace(theGraph, IC->w, IC->y) != OK)
                 return NOTOK;
         }

         if (_FindUnembeddedEdgeToCurVertex(theGraph, IC->w, &IC->dw) != TRUE)
             return NOTOK;

         if (_FindUnembeddedEdgeToAncestor(theGraph, XorY, &u, &d) != TRUE)
             return NOTOK;

         if (theGraph->functions.fpMarkDFSPath(theGraph, u, IC->v) != OK ||
             theGraph->functions.fpMarkDFSPath(theGraph, XorY, d) != OK ||
             theGraph->functions.fpMarkDFSPath(theGraph, IC->w, IC->dw) != OK ||
             _JoinBicomps(theGraph) != OK ||
             _AddAndMarkEdge(theGraph, u, d) != OK ||
             _AddAndMarkEdge(theGraph, IC->v, IC->dw) != OK)
             return NOTOK;

         return OK;
     }

/* Otherwise, isolate Minor E4 (reduce to minor A) */

     if (_FindUnembeddedEdgeToAncestor(theGraph, IC->w, &u, &d) != TRUE)
         return NOTOK;

     IC->v = u;
     IC->dw = d;
     return _IsolateOuterplanarityObstructionA(theGraph);
}
