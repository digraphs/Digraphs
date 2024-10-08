/********************************************************************************
**
*A  planar.c               Planarity testing
**
**
**  Copyright (C) 2018 - J. D. Mitchell
**
**  This file is free software, see the digraphs/LICENSE.
**
********************************************************************************/

#include "planar.h"

// C headers
#include <limits.h>   // for INT_MAX
#include <stdbool.h>  // for true and false

// Digraphs package headers
#include "digraphs-config.h"  // for DIGRAPHS_WITH_INCLUDED_PLANARITY
#include "digraphs-debug.h"   // for DIGRAPHS_ASSERT
#include "digraphs.h"         // for DigraphNrVertices, DigraphNrEdges, . . .
#include "gap-includes.h"     // for Fail, False, True

// edge-addition-planarity-suite headers
#if defined(__clang__)
#pragma clang diagnostic push
#pragma clang diagnostic ignored \
    "-Wincompatible-pointer-types-discards-qualifiers"
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#elif defined(__GNUC__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wstrict-prototypes"
#pragma GCC diagnostic ignored "-Wswitch-default"
#endif
#ifdef DIGRAPHS_WITH_INCLUDED_PLANARITY
#include "c/graph.h"
#include "c/graphK23Search.h"
#include "c/graphK33Search.h"
#include "c/graphK4Search.h"
#else
#include "planarity/graph.h"
#include "planarity/graphK23Search.h"
#include "planarity/graphK33Search.h"
#include "planarity/graphK4Search.h"
#endif
#if defined(__clang__)
#pragma clang diagnostic pop
#elif defined(__GNUC__)
#pragma GCC diagnostic pop
#endif

// Forward declaration of the main function in this file.
Obj trivial_planarity_output(Int V, bool krtwsk);

// Forward declaration of the main function in this file.
Obj boyers_planarity_check(Obj digraph, int flags, bool krtwsk);

// GAP level functions
Obj FuncIS_PLANAR(Obj self, Obj digraph) {
  return boyers_planarity_check(digraph, EMBEDFLAGS_PLANAR, false);
}

Obj FuncKURATOWSKI_PLANAR_SUBGRAPH(Obj self, Obj digraph) {
  Obj res = boyers_planarity_check(digraph, EMBEDFLAGS_PLANAR, true);
  return (ELM_PLIST(res, 1) == False ? ELM_PLIST(res, 2) : Fail);
}

Obj FuncPLANAR_EMBEDDING(Obj self, Obj digraph) {
  Obj res = boyers_planarity_check(digraph, EMBEDFLAGS_PLANAR, true);
  return (ELM_PLIST(res, 1) == True ? ELM_PLIST(res, 2) : Fail);
}

Obj FuncIS_OUTER_PLANAR(Obj self, Obj digraph) {
  return boyers_planarity_check(digraph, EMBEDFLAGS_OUTERPLANAR, false);
}

Obj FuncKURATOWSKI_OUTER_PLANAR_SUBGRAPH(Obj self, Obj digraph) {
  Obj res = boyers_planarity_check(digraph, EMBEDFLAGS_OUTERPLANAR, true);
  return (ELM_PLIST(res, 1) == False ? ELM_PLIST(res, 2) : Fail);
}

Obj FuncOUTER_PLANAR_EMBEDDING(Obj self, Obj digraph) {
  Obj res = boyers_planarity_check(digraph, EMBEDFLAGS_OUTERPLANAR, true);
  return (ELM_PLIST(res, 1) == True ? ELM_PLIST(res, 2) : Fail);
}

Obj FuncSUBGRAPH_HOMEOMORPHIC_TO_K23(Obj self, Obj digraph) {
  Obj res = boyers_planarity_check(digraph, EMBEDFLAGS_SEARCHFORK23, true);
  return (ELM_PLIST(res, 1) == False ? ELM_PLIST(res, 2) : Fail);
}

Obj FuncSUBGRAPH_HOMEOMORPHIC_TO_K33(Obj self, Obj digraph) {
  Obj res = boyers_planarity_check(digraph, EMBEDFLAGS_SEARCHFORK33, true);
  return (ELM_PLIST(res, 1) == False ? ELM_PLIST(res, 2) : Fail);
}

Obj FuncSUBGRAPH_HOMEOMORPHIC_TO_K4(Obj self, Obj digraph) {
  Obj res = boyers_planarity_check(digraph, EMBEDFLAGS_SEARCHFORK4, true);
  return (ELM_PLIST(res, 1) == False ? ELM_PLIST(res, 2) : Fail);
}

// The implementation of the main functions in this file.

Obj trivial_planarity_output(Int V, bool krtwsk) {
  Obj res;
  if (krtwsk) {
    Obj subgraph = NEW_PLIST_IMM(T_PLIST, V);
    SET_LEN_PLIST(subgraph, V);
    for (int i = 1; i <= V; ++i) {
      Obj list = NEW_PLIST_IMM(T_PLIST, 0);
      SET_LEN_PLIST(list, 0);
      SET_ELM_PLIST(subgraph, i, list);
      CHANGED_BAG(subgraph);
    }
    res = NEW_PLIST_IMM(T_PLIST, 2);
    SET_LEN_PLIST(res, 2);
    SET_ELM_PLIST(res, 1, True);
    SET_ELM_PLIST(res, 2, subgraph);
    CHANGED_BAG(res);
  } else {
    res = True;
  }
  return res;
}

// This function only accepts digraphs without multiple edges

Obj boyers_planarity_check(Obj digraph, int flags, bool krtwsk) {
  DIGRAPHS_ASSERT(flags == EMBEDFLAGS_PLANAR || flags == EMBEDFLAGS_OUTERPLANAR
                  || flags == EMBEDFLAGS_SEARCHFORK23
                  || flags == EMBEDFLAGS_SEARCHFORK4
                  || flags == EMBEDFLAGS_SEARCHFORK33);

  if (CALL_1ARGS(IsDigraph, digraph) != True) {
    ErrorQuit("Digraphs: boyers_planarity_check (C): the 1st argument must be "
              "a digraph, not %s",
              (Int) TNAM_OBJ(digraph),
              0L);
  }
  if (CALL_1ARGS(IsMultiDigraph, digraph) == True) {
    ErrorQuit("expected a digraph without multiple edges!", 0L, 0L);
  }

  Int V = DigraphNrVertices(digraph);
  if (V == 0) {
    return trivial_planarity_output(0, krtwsk);
  }

  Int E = DigraphNrAdjacenciesWithoutLoops(digraph);
  if (E == 0) {
    return trivial_planarity_output(V, krtwsk);
  }
  if (V > INT_MAX) {
    // Cannot currently test this, it might always be true, depending on the
    // definition of Int.
    ErrorQuit("Digraphs: boyers_planarity_check (C): the maximum number of "
              "nodes is %d, found %d",
              INT_MAX,
              V);
    return 0L;
  } else if (2 * E > INT_MAX) {
    // Cannot currently test this
    ErrorQuit("Digraphs: boyers_planarity_check (C): the maximum number of "
              "edges is %d, found %d",
              INT_MAX / 2,
              E);
    return 0L;
  }

  graphP theGraph = gp_New();

  if (gp_InitGraph(theGraph, V) != OK) {
    gp_Free(&theGraph);
    ErrorQuit("Digraphs: boyers_planarity_check (C): invalid number of nodes!",
              0L,
              0L);
    return 0L;
  } else if (gp_EnsureArcCapacity(theGraph, 2 * E) != OK) {
    gp_Free(&theGraph);
    ErrorQuit("Digraphs: boyers_planarity_check (C): invalid number of edges!",
              0L,
              0L);
    return 0L;
  }

  switch (flags) {
    case EMBEDFLAGS_SEARCHFORK33:
      gp_AttachK33Search(theGraph);
      break;
    case EMBEDFLAGS_SEARCHFORK23:
      gp_AttachK23Search(theGraph);
      break;
    case EMBEDFLAGS_SEARCHFORK4:
      gp_AttachK4Search(theGraph);
      break;
    default:
      break;
  }

  int       status;
  Obj const out = FuncOutNeighbours(0L, digraph);

  // Construct the antisymmetric digraph with no loops
  for (Int v = 1; v <= LEN_LIST(out); ++v) {
    DIGRAPHS_ASSERT(gp_VertexInRange(theGraph, v));
    gp_SetVertexIndex(theGraph, v, v);
    Obj const out_v = ELM_LIST(out, v);
    for (Int w = 1; w <= LEN_LIST(out_v); ++w) {
      DIGRAPHS_ASSERT(gp_VertexInRange(theGraph, w));
      Int u = INT_INTOBJ(ELM_LIST(out_v, w));
      if (v < u
          || CALL_3ARGS(IsDigraphEdge, digraph, INTOBJ_INT(u), INTOBJ_INT(v))
                 == False) {
        status = gp_AddEdge(theGraph, v, 0, u, 0);
        if (status != OK) {
          // Cannot currently test this, i.e. it shouldn't happen (and
          // currently there is no example where it does happen)
          gp_Free(&theGraph);
          ErrorQuit("Digraphs: boyers_planarity_check (C): internal error, "
                    "can't add edge from %d to %d",
                    (Int) v,
                    (Int) u);
          return 0L;
        }
      }
    }
  }

  status = gp_Embed(theGraph, flags);
  if (status == NOTOK) {
    // Cannot currently test this, i.e. it shouldn't happen (and
    // currently there is no example where it does happen)
    gp_Free(&theGraph);
    ErrorQuit("Digraphs: boyers_planarity_check (C): status is not ok", 0L, 0L);
  }

  // Construct the return value
  Obj res;
  if (krtwsk) {
    // Kuratowski subgraph isolator
    gp_SortVertices(theGraph);
    Obj subgraph = NEW_PLIST_IMM(T_PLIST, theGraph->N);
    SET_LEN_PLIST(subgraph, theGraph->N);
    for (int i = 1; i <= theGraph->N; ++i) {
      int nr   = 0;
      Obj list = NEW_PLIST(T_PLIST, 0);
      int j    = theGraph->V[i].link[1];
      while (j) {
        if (CALL_3ARGS(IsDigraphEdge,
                       digraph,
                       INTOBJ_INT((Int) i),
                       INTOBJ_INT((Int) theGraph->E[j].neighbor))
            == True) {
          AssPlist(list, ++nr, INTOBJ_INT(theGraph->E[j].neighbor));
        }
        j = theGraph->E[j].link[1];
      }
      if (nr == 0) {
        SET_LEN_PLIST(list, 0);
      }
      MakeImmutable(list);
      SET_ELM_PLIST(subgraph, i, list);
      CHANGED_BAG(subgraph);
    }
    res = NEW_PLIST_IMM(T_PLIST, 2);
    SET_LEN_PLIST(res, 2);
    SET_ELM_PLIST(res, 1, (status == NONEMBEDDABLE ? False : True));
    SET_ELM_PLIST(res, 2, subgraph);
    CHANGED_BAG(res);
  } else if (status == NONEMBEDDABLE) {
    res = False;
  } else {
    res = True;
  }
  gp_Free(&theGraph);
  return res;
}
