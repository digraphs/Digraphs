/*******************************************************************************
**
*A  digraphs.c                  GAP package Digraphs          Julius Jonusas
**                                                            James Mitchell
**                                                            Michael Torpey
**                                                            Wilf A. Wilson
**
**  Copyright (C) 2014-17 - Julius Jonusas, James Mitchell, Michael Torpey,
**  Wilf A. Wilson
**
**  This file is free software, see the digraphs/LICENSE.
**
*******************************************************************************/

#include "digraphs.h"
#include "digraphs-config.h"

#include <stdbool.h>  // for false, true, bool
#include <stdint.h>   // for uint64_t
#include <stdlib.h>   // for NULL, free

#include "digraphs-debug.h"  // for DIGRAPHS_ASSERT
#include "homos.h"           // for FuncHomomorphismDigraphsFinder
#include "planar.h"          // for FUNC_IS_PLANAR, . . .

#ifdef DIGRAPHS_WITH_INCLUDED_BLISS
#include "bliss-0.73/bliss_C.h"  // for bliss_digraphs_release, . . .
#else
#include "bliss/bliss_C.h"
#define bliss_digraphs_add_edge bliss_add_edge
#define bliss_digraphs_new bliss_new
#define bliss_digraphs_add_vertex bliss_add_vertex
#define bliss_digraphs_find_canonical_labeling bliss_find_canonical_labeling
#define bliss_digraphs_release bliss_release
#endif

#undef PACKAGE
#undef PACKAGE_BUGREPORT
#undef PACKAGE_NAME
#undef PACKAGE_STRING
#undef PACKAGE_TARNAME
#undef PACKAGE_URL
#undef PACKAGE_VERSION

// GAP level things, imported in InitKernel below
Obj IsDigraph;
Obj IsDigraphEdge;
Obj DIGRAPHS_ValidateVertexColouring;
Obj Infinity;
Obj IsSymmetricDigraph;
Obj GeneratorsOfGroup;
Obj AutomorphismGroup;
Obj IsAttributeStoringRepObj;
Obj IsPermGroup;
Obj IsDigraphAutomorphism;
Obj LargestMovedPointPerms;

static inline bool IsAttributeStoringRep(Obj o) {
  return (CALL_1ARGS(IsAttributeStoringRepObj, o) == True ? true : false);
}

/*************************************************************************/

Obj FuncDigraphNrVertices(Obj self, Obj D) {
  return INTOBJ_INT(DigraphNrVertices(D));
}

Int DigraphNrVertices(Obj D) {
  return LEN_LIST(FuncOutNeighbours(0L, D));
}

static Int RNamOutNeighbours = 0;

Obj FuncOutNeighbours(Obj self, Obj D) {
  if (!RNamOutNeighbours) {
    RNamOutNeighbours = RNamName("OutNeighbours");
  }
  if (IsbPRec(D, RNamOutNeighbours)) {
    return ElmPRec(D, RNamOutNeighbours);
  } else {
    ErrorQuit(
        "the `OutNeighbours` component is not set for this digraph,", 0L, 0L);
  }
}

Obj FuncOutNeighboursFromSourceRange(Obj self, Obj N, Obj src, Obj ran) {
  DIGRAPHS_ASSERT(LEN_LIST(src) == LEN_LIST(ran));
  Int n = INT_INTOBJ(N);
  if (n == 0) {
    return NEW_PLIST(T_PLIST_EMPTY, 0);
  }
  Obj ret = NEW_PLIST(T_PLIST_TAB, n);
  SET_LEN_PLIST(ret, n);

  for (Int i = 1; i <= n; i++) {
    Obj next = NEW_PLIST(T_PLIST_EMPTY, 0);
    SET_LEN_PLIST(next, 0);
    SET_ELM_PLIST(ret, i, next);
    CHANGED_BAG(ret);
  }

  for (Int i = 1; i <= LEN_LIST(src); i++) {
    Obj list = ELM_PLIST(ret, INT_INTOBJ(ELM_LIST(src, i)));
    ASS_LIST(list, LEN_PLIST(list) + 1, ELM_LIST(ran, i));
    CHANGED_BAG(ret);
  }
  return ret;
}

Int DigraphNrEdges(Obj D) {
  Int nr = 0;
  if (IsbPRec(D, RNamName("DigraphNrEdges"))) {
    return INT_INTOBJ(ElmPRec(D, RNamName("DigraphNrEdges")));
  } else if (IsbPRec(D, RNamName("DigraphSource"))) {
    nr = LEN_LIST(ElmPRec(D, RNamName("DigraphSource")));
  } else {
    Int n    = DigraphNrVertices(D);
    Obj list = FuncOutNeighbours(0L, D);
    for (Int i = 1; i <= n; i++) {
      nr += LEN_LIST(ELM_PLIST(list, i));
    }
  }
  if (IsAttributeStoringRep(D)) {
    AssPRec(D, RNamName("DigraphNrEdges"), INTOBJ_INT(nr));
  }
  return nr;
}

static Obj FuncDIGRAPH_NREDGES(Obj self, Obj D) {
  return INTOBJ_INT(DigraphNrEdges(D));
}

/****************************************************************************
**
*F  FuncGABOW_SCC
**
** `digraph' should be a list whose entries and the lists of out-neighbours
** of the vertices. So [[2,3],[1],[2]] represents the graph whose edges are
** 1->2, 1->3, 2->1 and 3->2.
**
** returns a newly constructed record with two components 'comps' and 'id' the
** elements of 'comps' are lists representing the strongly connected components
** of the directed graph, and in the component 'id' the following holds:
** id[i]=PositionProperty(comps, x-> i in x);
** i.e. 'id[i]' is the index in 'comps' of the component containing 'i'.
** Neither the components, nor their elements are in any particular order.
**
** The algorithm is that of Gabow, based on the implementation in Sedgwick:
**   http://algs4.cs.princeton.edu/42directed/GabowSCC.java.html
** (made non-recursive to avoid problems with stack limits) and
** the implementation of STRONGLY_CONNECTED_COMPONENTS_DIGRAPH in listfunc.c.
*/

static Obj FuncGABOW_SCC(Obj self, Obj digraph) {
  UInt end1, end2, count, level, w, v, n, nr, idw, *frames, *stack2;
  Obj  id, stack1, out, comp, comps, adj;

  PLAIN_LIST(digraph);
  n = LEN_PLIST(digraph);
  if (n == 0) {
    out = NEW_PREC(2);
    AssPRec(out, RNamName("id"), NEW_PLIST_IMM(T_PLIST_EMPTY, 0));
    AssPRec(out, RNamName("comps"), NEW_PLIST_IMM(T_PLIST_EMPTY, 0));
    return out;
  }

  end1   = 0;
  stack1 = NEW_PLIST(T_PLIST_CYC, n);
  // stack1 is a plist so we can use memcopy below
  SET_LEN_PLIST(stack1, n);

  id = NEW_PLIST_IMM(T_PLIST_CYC, n);
  SET_LEN_PLIST(id, n);

  // init id
  for (v = 1; v <= n; v++) {
    SET_ELM_PLIST(id, v, INTOBJ_INT(0));
  }

  count = n;

  comps = NEW_PLIST_IMM(T_PLIST_TAB, n);

  stack2 = malloc((4 * n + 2) * sizeof(UInt));
  frames = stack2 + n + 1;
  end2   = 0;

  for (v = 1; v <= n; v++) {
    if (INT_INTOBJ(ELM_PLIST(id, v)) == 0) {
      adj = ELM_PLIST(digraph, v);
      PLAIN_LIST(adj);
      level     = 1;
      frames[0] = v;  // vertex
      frames[1] = 1;  // index
      frames[2] = (UInt) adj;
      SET_ELM_PLIST(stack1, ++end1, INTOBJ_INT(v));
      stack2[++end2] = end1;
      SET_ELM_PLIST(id, v, INTOBJ_INT(end1));

      while (1) {
        if (frames[1] > (UInt) LEN_PLIST((Obj) frames[2])) {
          if (stack2[end2] == (UInt) INT_INTOBJ(ELM_PLIST(id, frames[0]))) {
            end2--;
            count++;
            nr = 0;
            do {
              nr++;
              w = INT_INTOBJ(ELM_PLIST(stack1, end1--));
              SET_ELM_PLIST(id, w, INTOBJ_INT(count));
            } while (w != frames[0]);

            comp = NEW_PLIST_IMM(T_PLIST_CYC, nr);
            SET_LEN_PLIST(comp, nr);

            memcpy(ADDR_OBJ(comp) + 1,
                   CONST_ADDR_OBJ(stack1) + (end1 + 1),
                   nr * sizeof(Obj));

            nr = LEN_PLIST(comps) + 1;
            SET_ELM_PLIST(comps, nr, comp);
            SET_LEN_PLIST(comps, nr);
            CHANGED_BAG(comps);
          }
          level--;
          if (level == 0) {
            break;
          }
          frames -= 3;
        } else {
          w   = INT_INTOBJ(ELM_PLIST((Obj) frames[2], frames[1]++));
          idw = INT_INTOBJ(ELM_PLIST(id, w));

          if (idw == 0) {
            adj = ELM_PLIST(digraph, w);
            PLAIN_LIST(adj);
            level++;
            frames += 3;
            frames[0] = w;  // vertex
            frames[1] = 1;  // index
            frames[2] = (UInt) adj;
            SET_ELM_PLIST(stack1, ++end1, INTOBJ_INT(w));
            stack2[++end2] = end1;
            SET_ELM_PLIST(id, w, INTOBJ_INT(end1));
          } else {
            while (stack2[end2] > idw) {
              end2--;  // pop from stack2
            }
          }
        }
      }
    }
  }

  for (v = 1; v <= n; v++) {
    SET_ELM_PLIST(id, v, INTOBJ_INT(INT_INTOBJ(ELM_PLIST(id, v)) - n));
  }

  out = NEW_PREC(2);
  SHRINK_PLIST(comps, LEN_PLIST(comps));
  AssPRec(out, RNamName("id"), id);
  AssPRec(out, RNamName("comps"), comps);
  free(stack2);
  return out;
}

static UInt UF_FIND(UInt* id, UInt i) {
  while (i != id[i])
    i = id[i];
  return i;
}

static void UF_COMBINE_CLASSES(UInt* id, UInt i, UInt j) {
  i = UF_FIND(id, i);
  j = UF_FIND(id, j);
  if (i < j)
    id[j] = i;
  else if (j < i)
    id[i] = j;
  // if i = j then there is nothing to combine
}

static Obj FuncDIGRAPH_CONNECTED_COMPONENTS(Obj self, Obj digraph) {
  UInt n, *id, *nid, i, e, len, f, nrcomps;
  Obj  adj, adji, gid, gcomps, comp, out;

  out = NEW_PREC(2);
  n   = DigraphNrVertices(digraph);
  if (n == 0) {
    gid    = NEW_PLIST_IMM(T_PLIST_EMPTY, 0);
    gcomps = NEW_PLIST_IMM(T_PLIST_EMPTY, 0);
  } else {
    id = malloc(n * sizeof(UInt));
    for (i = 0; i < n; i++) {
      id[i] = i;
    }

    adj = FuncOutNeighbours(self, digraph);
    for (i = 0; i < n; i++) {
      adji = ELM_PLIST(adj, i + 1);
      PLAIN_LIST(adji);
      len = LEN_PLIST(adji);
      for (e = 1; e <= len; e++) {
        UF_COMBINE_CLASSES(id, i, INT_INTOBJ(ELM_PLIST(adji, e)) - 1);
      }
    }

    // "Normalise" id, giving it sensible labels
    nid     = malloc(n * sizeof(UInt));
    nrcomps = 0;
    for (i = 0; i < n; i++) {
      f      = UF_FIND(id, i);
      nid[i] = (f == i) ? ++nrcomps : nid[f];
    }
    free(id);

    // Make GAP object from nid
    gid    = NEW_PLIST_IMM(T_PLIST_CYC, n);
    gcomps = NEW_PLIST_IMM(T_PLIST_CYC, nrcomps);
    SET_LEN_PLIST(gid, n);
    SET_LEN_PLIST(gcomps, nrcomps);
    for (i = 1; i <= nrcomps; i++) {
      SET_ELM_PLIST(gcomps, i, NEW_PLIST_IMM(T_PLIST_CYC, 0));
      CHANGED_BAG(gcomps);
    }
    for (i = 1; i <= n; i++) {
      SET_ELM_PLIST(gid, i, INTOBJ_INT(nid[i - 1]));
      comp = ELM_PLIST(gcomps, nid[i - 1]);
      len  = LEN_PLIST(comp);
      AssPlist(comp, len + 1, INTOBJ_INT(i));
    }
    free(nid);
  }
  AssPRec(out, RNamName("id"), gid);
  AssPRec(out, RNamName("comps"), gcomps);
  return out;
}

static Obj FuncIS_ACYCLIC_DIGRAPH(Obj self, Obj adj) {
  UInt  nr, i, j, k, level;
  Obj   nbs;
  UInt *stack, *ptr;

  nr = LEN_PLIST(adj);

  // init the buf
  ptr   = calloc(nr + 1, sizeof(UInt));
  stack = malloc((2 * nr + 2) * sizeof(UInt));

  for (i = 1; i <= nr; i++) {
    nbs = ELM_PLIST(adj, i);
    if (LEN_LIST(nbs) == 0) {
      ptr[i] = 1;
    } else if (ptr[i] == 0) {
      level    = 1;
      stack[0] = i;
      stack[1] = 1;
      while (1) {
        j = stack[0];
        k = stack[1];
        if (ptr[j] == 2) {
          free(ptr);
          stack -= (2 * level) - 2;  // put the stack back to the start
          free(stack);
          return False;  // We have just travelled around a cycle
        }
        // Check whether:
        // 1. We've previously finished with this vertex, OR
        // 2. Whether we've now investigated all descendant branches
        nbs = ELM_PLIST(adj, j);
        if (ptr[j] == 1 || k > (UInt) LEN_LIST(nbs)) {
          ptr[j] = 1;
          level--;
          if (level == 0) {
            break;
          }
          // Backtrack and choose next available branch
          stack -= 2;
          ptr[stack[0]] = 0;
          stack[1]++;
        } else {  // Otherwise move onto the next available branch
          ptr[j] = 2;
          level++;
          nbs = ELM_PLIST(adj, j);
          stack += 2;
          stack[0] = INT_INTOBJ(CONST_ADDR_OBJ(nbs)[k]);
          stack[1] = 1;
        }
      }
    }
  }
  free(ptr);
  free(stack);
  return True;
}

static Obj FuncDIGRAPH_LONGEST_DIST_VERTEX(Obj self, Obj adj, Obj start) {
  UInt  nr, i, j, k, level, x, prev;
  Obj   nbs;
  UInt *stack, *ptr, *depth;

  nr = LEN_PLIST(adj);
  i  = INT_INTOBJ(start);

  if (i > nr || i < 1) {
    ErrorQuit("Digraphs: DIGRAPH_LONGEST_DIST_VERTEX: usage,\nthe second "
              "argument must be a vertex of the first argument,",
              0L,
              0L);
  }

  nbs = ELM_PLIST(adj, i);
  if (LEN_LIST(nbs) == 0) {
    return INTOBJ_INT(0);
  }

  ptr   = calloc(nr + 1, sizeof(UInt));
  depth = calloc(nr + 1, sizeof(UInt));
  stack = malloc((2 * nr + 2) * sizeof(UInt));

  level    = 1;
  stack[0] = i;
  stack[1] = 1;
  prev     = 0;
  while (1) {
    j = stack[0];
    k = stack[1];
    if (ptr[j] == 2) {  // we have identified a cycle
      stack -= (2 * level) - 2;
      free(stack);
      free(ptr);
      free(depth);
      return INTOBJ_INT(-2);  // We have just travelled around a cycle
    }

    if (prev > depth[j]) {
      depth[j] = prev;
    }
    // Check whether:
    // 1. We've previously finished with this vertex, OR
    // 2. Whether we've now investigated all descendant branches
    nbs = ELM_PLIST(adj, j);
    if (ptr[j] == 1 || k > (UInt) LEN_LIST(nbs)) {
      ptr[j] = 1;
      level--;
      prev = depth[j];
      if (level == 0) {
        // finished the search
        break;
      }
      // Backtrack and choose next available branch
      stack -= 2;
      ptr[stack[0]] = 0;
      prev++;
      stack[1]++;
    } else {  // Otherwise move onto the next available branch
      ptr[j] = 2;
      level++;
      nbs = ELM_PLIST(adj, j);
      stack += 2;
      stack[0] = INT_INTOBJ(CONST_ADDR_OBJ(nbs)[k]);
      stack[1] = 1;
      prev     = 0;
    }
  }

  x = depth[INT_INTOBJ(start)];
  free(ptr);
  free(depth);
  free(stack);
  return INTOBJ_INT(x);
}

// Forward decl
static Obj FuncDIGRAPH_IN_OUT_NBS(Obj, Obj);

// Takes in-neighbours (Obj adj) of a topologically sorted non-multi digraph
// Returns the out-neighbours of its transitive reduction.
// If (Obj loops) == False, loops are removed (transitive reflexive reduction)
static Obj FuncDIGRAPH_TRANS_REDUCTION(Obj self, Obj D) {
  DIGRAPHS_ASSERT(CALL_1ARGS(IsDigraph, D) == True);
  if (!IS_MUTABLE_OBJ(D)) {
    ErrorQuit("the argument (a digraph) must be mutable", 0L, 0L);
  }

  UInt const n = DigraphNrVertices(D);

  // Special case for n = 0
  if (n == 0) {
    return D;
  }

  // Create the GAP out-neighbours strcture of the result
  Obj ot_list = NEW_PLIST(T_PLIST_TAB, n);
  SET_LEN_PLIST(ot_list, n);
  for (UInt i = 1; i <= n; i++) {
    SET_ELM_PLIST(ot_list, i, NEW_PLIST(T_PLIST_EMPTY, 0));
    CHANGED_BAG(ot_list);
  }

  Obj const in_list = FuncDIGRAPH_IN_OUT_NBS(self, FuncOutNeighbours(self, D));

  // Create data structures needed for computation
  UInt* ptr   = calloc(n + 1, sizeof(UInt));
  bool* mat   = calloc(n * n, sizeof(bool));
  UInt* stack = malloc((2 * n + 2) * sizeof(UInt));

  // Start a depth-first search from each source of the digraph
  for (UInt i = 1; i <= n; i++) {
    if (ptr[i] == 0) {
      // Remember which vertex was the source
      UInt source = i;
      // not sure if this next line is necessary
      bool backtracking = false;
      UInt level        = 1;

      stack[0] = i;
      stack[1] = 1;
      while (1) {
        UInt j = stack[0];
        UInt k = stack[1];

        // We have found a loop on vertex j
        if (ptr[j] == 2) {
          if (stack[-2] != j) {
            ErrorQuit(
                "the argument (a digraph) must be acyclic except for loops,",
                0L,
                0L);
          }
          backtracking = true;
          level--;
          stack -= 2;
          stack[1]++;
          ptr[j] = 0;
          // Store the loop
          Obj list = ELM_PLIST(ot_list, j);
          ASS_LIST(list, LEN_PLIST(list) + 1, INTOBJ_INT(j));
          CHANGED_BAG(ot_list);
          continue;
        }

        // Calculate if we need to add an edge from j -> (previous vertex)
        if (!backtracking && j != source && !mat[(stack[-2] - 1) * n + j - 1]) {
          Obj list = ELM_PLIST(ot_list, j);
          ASS_LIST(list, LEN_PLIST(list) + 1, INTOBJ_INT(stack[-2]));
          CHANGED_BAG(ot_list);
        }

        Obj nbs = ELM_PLIST(in_list, j);

        // Do we need to backtrack?
        if (ptr[j] == 1 || k > (UInt) LEN_LIST(nbs)) {
          if (level == 1)
            break;

          backtracking = true;
          level--;
          stack -= 2;
          ptr[stack[0]] = 0;
          stack[1]++;
          ptr[j] = 1;

          // w is the vertex we are backtracking to (-1)
          UInt w = stack[0] - 1;
          // Record which vertices we have discovered 'above' w
          for (UInt m = 0; m < n; m++) {
            mat[w * n + m] = mat[w * n + m] + mat[(j - 1) * n + m];
          }
          mat[w * n + (j - 1)] = true;
        } else {
          backtracking = false;
          level++;
          stack += 2;
          stack[0] = INT_INTOBJ(CONST_ADDR_OBJ(nbs)[k]);
          stack[1] = 1;
          ptr[j]   = 2;
        }
      }
    }
  }
  free(mat);
  free(ptr);
  free(stack);
  AssPRec(D, RNamName("OutNeighbours"), ot_list);
  return D;
}

// TODO(*) use generic DFS, when we have one.

static Obj FuncDIGRAPH_PATH(Obj self, Obj adj, Obj u, Obj v) {
  UInt  nr, i, j, k, level, target;
  Obj   nbs, out, path, edge;
  UInt *stack, *ptr;

  i   = INT_INTOBJ(u);
  nbs = ELM_PLIST(adj, i);
  if (LEN_LIST(nbs) == 0) {
    return Fail;
  }
  target = INT_INTOBJ(v);
  nr     = LEN_PLIST(adj);

  // init the buf
  ptr   = calloc(nr + 1, sizeof(UInt));
  stack = malloc((2 * nr + 2) * sizeof(UInt));

  level    = 1;
  stack[0] = i;
  stack[1] = 1;
  while (1) {
    j = stack[0];
    k = stack[1];
    // Check whether:
    // 1. We've previously visited with this vertex, OR
    // 2. Whether we've now investigated all descendant branches
    nbs = ELM_PLIST(adj, j);
    if (ptr[j] != 0 || k > (UInt) LEN_LIST(nbs)) {
      ptr[j] = 1;
      if (--level == 0) {
        break;
      }
      // Backtrack and choose next available branch
      stack -= 2;
      ptr[stack[0]] = 0;
      stack[1]++;
    } else {  // Otherwise move onto the next available branch
      ptr[j] = 2;
      level++;
      nbs = ELM_PLIST(adj, j);
      stack += 2;
      stack[0] = INT_INTOBJ(CONST_ADDR_OBJ(nbs)[k]);
      if (stack[0] == target) {
        // Create output lists
        path = NEW_PLIST_IMM(T_PLIST_CYC, level);
        SET_LEN_PLIST(path, level);
        SET_ELM_PLIST(path, level--, INTOBJ_INT(stack[0]));
        edge = NEW_PLIST_IMM(T_PLIST_CYC, level);
        SET_LEN_PLIST(edge, level);
        out = NEW_PLIST_IMM(T_PLIST_CYC, 2);
        SET_LEN_PLIST(out, 2);

        // Fill output lists
        while (level > 0) {
          stack -= 2;
          SET_ELM_PLIST(edge, level, INTOBJ_INT(stack[1]));
          SET_ELM_PLIST(path, level--, INTOBJ_INT(stack[0]));
        }
        SET_ELM_PLIST(out, 1, path);
        SET_ELM_PLIST(out, 2, edge);
        free(ptr);
        free(stack);
        return out;
      }
      stack[1] = 1;
    }
  }
  free(ptr);
  free(stack);
  return Fail;
}

Obj FuncIS_ANTISYMMETRIC_DIGRAPH(Obj self, Obj adj) {
  Int   nr, i, j, k, l, level, last1, last2;
  Obj   nbs;
  UInt *stack, *ptr;

  nr = LEN_PLIST(adj);
  if (nr <= 1) {
    return True;
  }

  // init the buf (is this correct length?)
  ptr   = calloc(nr + 1, sizeof(UInt));
  stack = malloc((4 * nr + 4) * sizeof(UInt));

  for (i = 1; i <= nr; i++) {
    nbs = ELM_PLIST(adj, i);
    if (LEN_LIST(nbs) == 0) {
      ptr[i] = 1;
    } else if (ptr[i] == 0) {
      level    = 1;
      stack[0] = i;
      stack[1] = 1;
      stack[2] = 0;
      stack[3] = 0;
      while (1) {
        j     = stack[0];
        k     = stack[1];
        last1 = stack[2];
        last2 = stack[3];
        if (j == last2 && j != last1) {
          free(ptr);
          stack -= (4 * level) - 4;  // put the stack back to the start
          free(stack);
          return False;  // Found a non-loop cycle of length 2
        }
        // Check whether:
        // 1. We've previously finished with this vertex, OR
        // 2. Whether we've now investigated all descendant branches
        nbs = ELM_PLIST(adj, j);
        if (ptr[j] == 2) {
          PLAIN_LIST(nbs);
          for (l = 1; l <= LEN_PLIST(nbs); l++) {
            if (last1 != j && INT_INTOBJ(CONST_ADDR_OBJ(nbs)[l]) == last1) {
              free(ptr);
              stack -= (4 * level) - 4;  // put the stack back to the start
              free(stack);
              return False;
            }
          }
        }
        if (k > LEN_LIST(nbs)) {
          ptr[j] = 1;
        }
        if (ptr[j] >= 1) {
          level--;
          if (level == 0) {
            break;
          }
          // Backtrack and choose next available branch
          stack -= 4;
          ptr[stack[0]] = 0;
          stack[1]++;
        } else {  // Otherwise move onto the next available branch
          ptr[j] = 2;
          level++;
          nbs = ELM_PLIST(adj, j);
          stack += 4;
          stack[0] = INT_INTOBJ(ELM_LIST(nbs, k));
          stack[1] = 1;
          stack[2] = j;  // I am wasting memory here, duplicating info
          stack[3] = last1;
        }
      }
    }
  }
  free(ptr);
  free(stack);
  return True;
}

static Obj FuncIS_STRONGLY_CONNECTED_DIGRAPH(Obj self, Obj digraph) {
  UInt n, nextid, *bag, *ptr1, *ptr2, *fptr, *id, w;

  n = LEN_PLIST(digraph);
  if (n == 0) {
    return True;
  }

  nextid = 1;
  bag    = malloc(n * 4 * sizeof(UInt));
  ptr1   = bag;
  ptr2   = bag + n;
  fptr   = bag + n * 2;
  id     = calloc(n + 1, sizeof(UInt));

  // first vertex v=1
  PLAIN_LIST(ELM_PLIST(digraph, 1));
  fptr[0] = 1;  // vertex
  fptr[1] = 1;  // index
  *ptr1   = 1;
  *ptr2   = nextid;
  id[1]   = nextid;

  while (1) {  // we always return before level = 0
    if (fptr[1] > (UInt) LEN_PLIST(ELM_PLIST(digraph, fptr[0]))) {
      if (*ptr2 == id[fptr[0]]) {
        do {
          n--;
        } while (*(ptr1--) != fptr[0]);
        free(bag);
        free(id);
        return n == 0 ? True : False;
      }
      fptr -= 2;
    } else {
      w = INT_INTOBJ(ELM_PLIST(ELM_PLIST(digraph, fptr[0]), fptr[1]++));
      if (id[w] == 0) {
        PLAIN_LIST(ELM_PLIST(digraph, w));
        fptr += 2;
        fptr[0] = w;  // vertex
        fptr[1] = 1;  // index
        nextid++;
        *(++ptr1) = w;
        *(++ptr2) = nextid;
        id[w]     = nextid;
      } else {
        while ((*ptr2) > id[w]) {
          ptr2--;
        }
      }
    }
  }
  // this should never happen, just to keep the compiler happy
  return Fail;
}

static Obj FuncDIGRAPH_TOPO_SORT(Obj self, Obj adj) {
  UInt  nr, i, j, k, count;
  UInt  level;
  Obj   nbs, out;
  UInt *stack, *ptr;

  nr = LEN_PLIST(adj);

  if (nr == 0) {
    return NEW_PLIST_IMM(T_PLIST_EMPTY, 0);
  }
  out = NEW_PLIST_IMM(T_PLIST_CYC, nr);
  SET_LEN_PLIST(out, nr);
  if (nr == 1) {
    SET_ELM_PLIST(out, 1, INTOBJ_INT(1));
    return out;
  }

  // init the buf
  ptr   = calloc(nr + 1, sizeof(UInt));
  stack = malloc((2 * nr + 2) * sizeof(UInt));
  count = 0;

  for (i = 1; i <= nr; i++) {
    nbs = ELM_PLIST(adj, i);
    if (LEN_LIST(nbs) == 0) {
      if (ptr[i] == 0) {
        count++;
        SET_ELM_PLIST(out, count, INTOBJ_INT(i));
      }
      ptr[i] = 1;
    } else if (ptr[i] == 0) {
      level    = 1;
      stack[0] = i;
      stack[1] = 1;
      while (1) {
        j = stack[0];
        k = stack[1];
        if (ptr[j] == 2) {
          // SetIsAcyclicDigraph(graph, false);
          stack -= 2;
          level--;
          if (stack[0] != j) {  // Cycle is not just a loop
            free(ptr);
            stack -= (2 * level) - 2;
            free(stack);
            return Fail;
          }
          stack[1]++;
          ptr[j] = 0;
          continue;
        }
        nbs = ELM_PLIST(adj, j);
        if (ptr[j] == 1 || k > (UInt) LEN_LIST(nbs)) {
          if (ptr[j] == 0) {
            // ADD J TO THE END OF OUR LIST
            count++;
            SET_ELM_PLIST(out, count, INTOBJ_INT(j));
          }
          ptr[j] = 1;
          level--;
          if (level == 0) {
            break;
          }
          // Backtrack and choose next available branch
          stack -= 2;
          ptr[stack[0]] = 0;
          stack[1]++;
        } else {  // Otherwise move onto the next available branch
          ptr[j] = 2;
          level++;
          nbs = ELM_PLIST(adj, j);
          stack += 2;
          stack[0] = INT_INTOBJ(ELM_LIST(nbs, k));
          stack[1] = 1;
        }
      }
    }
  }
  free(ptr);
  free(stack);
  return out;
}

// WW. This function performs a depth first search on the digraph defined by
// <adj> and returns the adjacency list <out> of a spanning forest. This is a
// forest rather than a tree since <adj> is not required to be connected. Each
// time a new vertex <j> is discovered (from the previous vertex <i>), the edges
// i <-> j are added to <out>.

// TODO(*) use generic DFS, when we have one.

// Assumes that <adj> is the list of adjacencies of a symmetric digraph
// Multiple edges and loops are allowed
static Obj FuncDIGRAPH_SYMMETRIC_SPANNING_FOREST(Obj self, Obj adj) {
  UInt  nr, i, j, k, next, len, level;
  Obj   nbs, out, out_j, new;
  UInt *stack, *ptr;

  nr = LEN_PLIST(adj);

  if (nr == 0) {
    return NEW_PLIST_IMM(T_PLIST_EMPTY, 0);
  }

  // init the adjacencies of the spanning forest
  out = NEW_PLIST(T_PLIST_TAB, nr);
  SET_LEN_PLIST(out, nr);
  for (i = 1; i <= nr; i++) {
    SET_ELM_PLIST(out, i, NEW_PLIST(T_PLIST_EMPTY, 0));
    CHANGED_BAG(out);
  }

  // init the buffer
  ptr   = calloc(nr + 1, sizeof(UInt));
  stack = malloc((2 * nr + 2) * sizeof(UInt));

  for (i = 1; i <= nr; i++) {
    // perform DFS only on still-undiscovered non-trivial connected components
    if (!ptr[i] && LEN_LIST(ELM_PLIST(adj, i)) > 0) {
      level    = 1;
      stack[0] = i;
      stack[1] = 1;

      while (1) {
        j   = stack[0];
        k   = stack[1];
        nbs = ELM_PLIST(adj, j);

        // idea: is <nbs[k]> a new vertex? add edges <j> <-> <nbs[k]> if so

        // if we're finished with <j>, or <nbs[k]> doesn't exist, then backtrack
        if (ptr[j] || k > (UInt) LEN_LIST(nbs)) {
          ptr[j] = 1;  // vertex <j> and its descendents are now fully explored
          if (--level == 0) {
            break;  // we've explored the whole connected component
          }
          stack -= 2;
          ptr[stack[0]] = 0;
          stack[1]++;
        } else {
          ptr[j] = 1;
          next   = INT_INTOBJ(CONST_ADDR_OBJ(nbs)[k]);
          level++;
          stack += 2;
          stack[0] = next;
          stack[1] = 1;
          // if <next> is a brand new vertex, add it to the spanning tree
          if (ptr[next] == 0) {
            // create the edge <j> -> <next>
            out_j = ELM_PLIST(out, j);
            len   = LEN_PLIST(out_j);
            ASS_LIST(out_j, len + 1, INTOBJ_INT(next));
            // create the edge <next> -> <j>
            // since <next> is new, <out[next]> is still a T_PLIST_EMPTY
            new = ELM_PLIST(out, next);
            ASS_LIST(new, 1, INTOBJ_INT(j));
          }
        }
      }
    }
  }
  free(ptr);
  free(stack);
  return out;
}

static Obj FuncDIGRAPH_SOURCE_RANGE(Obj self, Obj D) {
  Obj src, ran, adj, adji;
  Int i, j, k, m, n, len;

  m   = DigraphNrEdges(D);
  n   = DigraphNrVertices(D);
  adj = FuncOutNeighbours(self, D);

  if (m == 0) {
    src = NEW_PLIST_IMM(T_PLIST_EMPTY, m);
    ran = NEW_PLIST_IMM(T_PLIST_EMPTY, m);
  } else {
    src = NEW_PLIST_IMM(T_PLIST_CYC, m);
    ran = NEW_PLIST_IMM(T_PLIST_CYC, m);
    k   = 0;
    for (i = 1; i <= n; i++) {
      adji = ELM_PLIST(adj, i);
      len  = LEN_LIST(adji);
      for (j = 1; j <= len; j++) {
        k++;
        SET_ELM_PLIST(src, k, INTOBJ_INT(i));
        SET_ELM_PLIST(ran, k, ELM_LIST(adji, j));
      }
    }
  }

  SET_LEN_PLIST(src, m);
  SET_LEN_PLIST(ran, m);
  if (IsAttributeStoringRep(D)) {
    AssPRec(D, RNamName("DigraphSource"), src);
    AssPRec(D, RNamName("DigraphRange"), ran);
    return D;
  } else {
    Obj tmp = NEW_PREC(2);
    SET_LEN_PREC(tmp, 2);
    AssPRec(tmp, RNamName("DigraphSource"), src);
    AssPRec(tmp, RNamName("DigraphRange"), ran);
    return tmp;
  }
}

// Assume we are passed a GAP Int nrvertices
// Two GAP lists of PosInts (all <= nrvertices) of equal length

// Function to change Out-Neighbours to In-Neighbours, and vice versa
static Obj FuncDIGRAPH_IN_OUT_NBS(Obj self, Obj adj) {
  Obj  inn, innk, adji;
  UInt n, i, j, k, len, len2;

  n = LEN_PLIST(adj);
  if (n == 0) {
    return NEW_PLIST_IMM(T_PLIST_EMPTY, 0);
  }
  inn = NEW_PLIST(T_PLIST_TAB, n);
  SET_LEN_PLIST(inn, n);

  // fill adj with empty plists
  for (i = 1; i <= n; i++) {
    SET_ELM_PLIST(inn, i, NEW_PLIST(T_PLIST_EMPTY, 0));
    CHANGED_BAG(inn);
  }

  for (i = 1; i <= n; i++) {
    adji = ELM_PLIST(adj, i);
    PLAIN_LIST(adji);
    len = LEN_PLIST(adji);
    for (j = 1; j <= len; j++) {
      k    = INT_INTOBJ(ELM_PLIST(adji, j));
      innk = ELM_PLIST(inn, k);
      len2 = LEN_PLIST(innk);
      ASS_LIST(innk, len2 + 1, INTOBJ_INT(i));
    }
  }
  return inn;
}

Obj FuncADJACENCY_MATRIX(Obj self, Obj digraph) {
  Int n, i, j, val, len, outj;
  Obj adj, mat, adji, next;

  n = DigraphNrVertices(digraph);
  if (n == 0) {
    return NEW_PLIST_IMM(T_PLIST_EMPTY, 0);
  }

  adj = FuncOutNeighbours(self, digraph);
  mat = NEW_PLIST_IMM(T_PLIST_TAB, n);
  SET_LEN_PLIST(mat, n);

  for (i = 1; i <= n; i++) {
    // Set up the i^th row of the adjacency matrix
    next = NEW_PLIST_IMM(T_PLIST_CYC, n);
    SET_LEN_PLIST(next, n);
    for (j = 1; j <= n; j++) {
      SET_ELM_PLIST(next, j, INTOBJ_INT(0));
    }
    // Fill in the correct values of the matrix
    adji = ELM_PLIST(adj, i);
    len  = LEN_LIST(adji);
    for (j = 1; j <= len; j++) {
      outj = INT_INTOBJ(ELM_LIST(adji, j));
      val  = INT_INTOBJ(ELM_PLIST(next, outj)) + 1;
      SET_ELM_PLIST(next, outj, INTOBJ_INT(val));
    }
    SET_ELM_PLIST(mat, i, next);
    CHANGED_BAG(mat);
  }
  SET_FILT_LIST(mat, FN_IS_RECT);
  return mat;
}

static Obj FuncIS_MULTI_DIGRAPH(Obj self, Obj digraph) {
  Obj  adj, adji;
  UInt n, i, k, j, *seen;

  adj  = FuncOutNeighbours(self, digraph);
  n    = DigraphNrVertices(digraph);
  seen = calloc(n + 1, sizeof(UInt));

  for (i = 1; i <= n; i++) {
    adji = ELM_PLIST(adj, i);
    if ((UInt) LEN_LIST(adji) > n) {
      free(seen);
      return True;
    }
    PLAIN_LIST(adji);
    for (j = 1; j <= (UInt) LEN_PLIST(adji); j++) {
      k = INT_INTOBJ(ELM_PLIST(adji, j));
      if (seen[k] != i) {
        seen[k] = i;
      } else {
        free(seen);
        return True;
      }
    }
  }
  free(seen);
  return False;
}

/***************** GENERAL FLOYD_WARSHALL ALGORITHM***********************
 * This function accepts 5 arguments:
 *   1. A digraph.
 *   2. A special function which takes 5 arguments:
 *       - The matrix dist
 *       - 3 integers i, j, k
 *       - An integer n (the number of vertices of digraph)
 *      and modifies the matrix dist according to the values of i, j, k.
 *   3. Int val1 s.t initially dist[i][j] = val1 if [ i, j ] isn't an edge.
 *   4. Int val2 s.t initially dist[i][j] = val2 if [ i, j ] is an edge.
 *   5. bool copy:
 *      - If true, FLOYD_WARSHALL stores the initialised dist, and
 *        compares it with dist after it has gone through the 3 for-loops,
 *        and returns true iff it is unchanged.
 *      - If false, proceeds as usual Floyd-Warshall algorithm and returns
 *        a GAP object matrix as the result.
 *   6. bool diameter: // TODO wouldn't it be better to just take a
 *                        "post-processing" function. JDM
 *      - If true, FLOYD_WARSHALL goes through dist after the 3 for-loops,
 *        returns -1 if dist contains the value -1, else it returns the
 *        maximum value of dist
 *      - If false, proceeds as usual
 *   7. bool shortest:
 *      - If true, for each vertex i, dist[i][i] is initially set to 0
 *      - If false, this step is skipped
 */
static Obj FLOYD_WARSHALL(Obj digraph,
                          void (*func)(Int** dist, Int i, Int j, Int k, Int n),
                          Int  val1,
                          Int  val2,
                          bool copy,
                          bool diameter,
                          bool shortest) {
  Int n, i, j, k, *dist, *adj;
  Obj next, out, outi, val;

  n = DigraphNrVertices(digraph);

  // Special case for 0-vertex graph
  if (n == 0) {
    if (diameter) {
      return Fail;
    }
    if (copy) {
      return True;
    }
    return NEW_PLIST_IMM(T_PLIST_EMPTY, 0);
  }

  // Initialise the n x n matrix with val1 and val2
  dist = malloc(n * n * sizeof(Int));
  for (i = 0; i < n * n; i++) {
    dist[i] = val1;
  }
  out = FuncOutNeighbours(0L, digraph);
  for (i = 1; i <= n; i++) {
    outi = ELM_PLIST(out, i);
    PLAIN_LIST(outi);
    for (j = 1; j <= LEN_PLIST(outi); j++) {
      k       = (i - 1) * n + INT_INTOBJ(ELM_PLIST(outi, j)) - 1;
      dist[k] = val2;
    }
  }

  if (shortest) {
    // This is the special case for DIGRAPH_SHORTEST_DIST
    for (i = 0; i < n; i++) {
      dist[i * n + i] = 0;
    }
  }

  if (copy) {
    // This is the special case for IS_TRANSITIVE_DIGRAPH
    adj = malloc(n * n * sizeof(Int));
    for (i = 0; i < n * n; i++) {
      adj[i] = dist[i];
    }
  }

  for (k = 0; k < n; k++) {
    for (i = 0; i < n; i++) {
      for (j = 0; j < n; j++) {
        func(&dist, i, j, k, n);
      }
    }
  }

  // the following is a horrible hack
  if (diameter) {
    // This is the special case for DIGRAPH_DIAMETER
    Int maximum = -1;
    for (i = 0; i < n; i++) {
      for (j = 0; j < n; j++) {
        if (dist[i * n + j] > maximum) {
          maximum = dist[i * n + j];
        } else if (dist[i * n + j] == -1) {
          free(dist);
          if (copy) {
            free(adj);
          }
          return Fail;
        }
      }
    }
    free(dist);
    return INTOBJ_INT(maximum);
  }

  if (copy) {
    // This is the special case for IS_TRANSITIVE_DIGRAPH
    for (i = 0; i < n * n; i++) {
      if (adj[i] != dist[i]) {
        free(dist);
        free(adj);
        return False;
      }
    }
    free(dist);
    free(adj);
    return True;
  }

  // Create GAP matrix to return
  out = NEW_PLIST(T_PLIST_TAB, n);
  SET_LEN_PLIST(out, n);

  for (i = 1; i <= n; i++) {
    next = NEW_PLIST(T_PLIST_CYC, n);
    SET_LEN_PLIST(next, n);
    for (j = 1; j <= n; j++) {
      val = INTOBJ_INT(dist[(i - 1) * n + (j - 1)]);
      if (val == INTOBJ_INT(-1)) {
        val = Fail;
      }
      SET_ELM_PLIST(next, j, val);
    }
    SET_ELM_PLIST(out, i, next);
    CHANGED_BAG(out);
  }
  SET_FILT_LIST(out, FN_IS_RECT);

  free(dist);
  return out;
}

void FW_FUNC_SHORTEST_DIST(Int** dist, Int i, Int j, Int k, Int n) {
  if ((*dist)[i * n + k] != -1 && (*dist)[k * n + j] != -1) {
    if ((*dist)[i * n + j] == -1
        || (*dist)[i * n + j] > (*dist)[i * n + k] + (*dist)[k * n + j]) {
      (*dist)[i * n + j] = (*dist)[i * n + k] + (*dist)[k * n + j];
    }
  }
}

static Obj FuncDIGRAPH_SHORTEST_DIST(Obj self, Obj digraph) {
  return FLOYD_WARSHALL(
      digraph, FW_FUNC_SHORTEST_DIST, -1, 1, false, false, true);
}

static Obj FuncDIGRAPH_DIAMETER(Obj self, Obj digraph) {
  return FLOYD_WARSHALL(
      digraph, FW_FUNC_SHORTEST_DIST, -1, 1, false, true, true);
}

void FW_FUNC_TRANS_CLOSURE(Int** dist, Int i, Int j, Int k, Int n) {
  if ((*dist)[i * n + k] != 0 && (*dist)[k * n + j] != 0) {
    (*dist)[i * n + j] = 1;
  }
}

static Obj FuncIS_TRANSITIVE_DIGRAPH(Obj self, Obj digraph) {
  return FLOYD_WARSHALL(
      digraph, FW_FUNC_TRANS_CLOSURE, 0, 1, true, false, false);
}

static Obj FuncDIGRAPH_TRANS_CLOSURE(Obj self, Obj digraph) {
  return FLOYD_WARSHALL(
      digraph, FW_FUNC_TRANS_CLOSURE, 0, 1, false, false, false);
}

void FW_FUNC_REFLEX_TRANS_CLOSURE(Int** dist, Int i, Int j, Int k, Int n) {
  if ((i == j) || ((*dist)[i * n + k] != 0 && (*dist)[k * n + j] != 0)) {
    (*dist)[i * n + j] = 1;
  }
}

static Obj FuncDIGRAPH_REFLEX_TRANS_CLOSURE(Obj self, Obj digraph) {
  return FLOYD_WARSHALL(
      digraph, FW_FUNC_REFLEX_TRANS_CLOSURE, 0, 1, false, false, false);
}

static Obj FuncRANDOM_DIGRAPH(Obj self, Obj nn, Obj limm) {
  UInt n, i, j, k, lim;
  Int  len;
  Obj  adj, adji;

  n   = INT_INTOBJ(nn);
  lim = INT_INTOBJ(limm);
  adj = NEW_PLIST(T_PLIST_TAB, n);
  SET_LEN_PLIST(adj, n);

  for (i = 1; i <= n; i++) {
    SET_ELM_PLIST(adj, i, NEW_PLIST(T_PLIST_EMPTY, 0));
    CHANGED_BAG(adj);
  }

  for (i = 1; i <= n; i++) {
    for (j = 1; j <= n; j++) {
      k = rand() % 10000;
      if (k < lim) {
        adji = ELM_PLIST(adj, i);
        len  = LEN_PLIST(adji);
        ASS_LIST(adji, len + 1, INTOBJ_INT(j));
      }
    }
  }
  return adj;
}

static Obj FuncRANDOM_MULTI_DIGRAPH(Obj self, Obj nn, Obj mm) {
  UInt n, m, i, j, k;
  Int  len;
  Obj  adj, adjj;

  n   = INT_INTOBJ(nn);
  m   = INT_INTOBJ(mm);
  adj = NEW_PLIST(T_PLIST_TAB, n);
  SET_LEN_PLIST(adj, n);

  for (i = 1; i <= n; i++) {
    SET_ELM_PLIST(adj, i, NEW_PLIST(T_PLIST_EMPTY, 0));
    CHANGED_BAG(adj);
  }

  for (i = 1; i <= m; i++) {
    j    = (rand() % n) + 1;
    k    = (rand() % n) + 1;
    adjj = ELM_PLIST(adj, j);
    len  = LEN_PLIST(adjj);
    ASS_LIST(adjj, len + 1, INTOBJ_INT(k));
  }
  return adj;
}

bool EqJumbledPlists(Obj l, Obj r, Int nr, Int* buf) {
  bool eq;
  Int  j, jj;

  // Check first whether the lists are identical
  eq = true;
  for (j = 1; j <= nr; j++) {
    jj = INT_INTOBJ(ELM_PLIST(l, j));
    if (jj != INT_INTOBJ(ELM_PLIST(r, j))) {
      eq = false;
      break;
    }
  }

  // Otherwise check that they have equal content
  if (!eq) {
    for (j = 1; j <= nr; j++) {
      jj = INT_INTOBJ(ELM_PLIST(l, j)) - 1;
      buf[jj]++;
      jj = INT_INTOBJ(ELM_PLIST(r, j)) - 1;
      buf[jj]--;
    }

    for (j = 1; j <= nr; j++) {
      jj = INT_INTOBJ(ELM_PLIST(l, j)) - 1;
      if (buf[jj] != 0) {
        return false;
      }
    }
  }
  return true;
}

static Obj FuncDIGRAPH_EQUALS(Obj self, Obj digraph1, Obj digraph2) {
  UInt i, n1, n2, m1, m2;
  Obj  out1, out2, a, b;
  Int  nr, *buf;

  // Check NrVertices is equal
  n1 = DigraphNrVertices(digraph1);
  n2 = DigraphNrVertices(digraph2);
  if (n1 != n2) {
    return False;
  }

  // Check NrEdges is equal
  m1 = DigraphNrEdges(digraph1);
  m2 = DigraphNrEdges(digraph2);

  if (m1 != m2) {
    return False;
  }

  out1 = FuncOutNeighbours(self, digraph1);
  out2 = FuncOutNeighbours(self, digraph2);

  buf = calloc(n1, sizeof(Int));

  // Compare OutNeighbours of each vertex in turn
  for (i = 1; i <= n1; i++) {
    a = ELM_PLIST(out1, i);
    b = ELM_PLIST(out2, i);
    PLAIN_LIST(a);
    PLAIN_LIST(b);

    nr = LEN_PLIST(a);
    // Check that the OutDegrees match
    if (nr != LEN_PLIST(b)) {
      free(buf);
      return False;
    }

    if (!EqJumbledPlists(a, b, nr, buf)) {
      free(buf);
      return False;
    }
  }
  free(buf);
  return True;
}

Int LTJumbledPlists(Obj l, Obj r, Int nr1, Int nr2, Int* buf, Int n) {
  bool eq;
  Int  j, jj, min;

  // Check first whether the lists are identical
  if (nr1 == nr2) {
    eq = true;
    for (j = 1; j <= nr1; j++) {
      jj = INT_INTOBJ(ELM_PLIST(l, j));
      if (jj != INT_INTOBJ(ELM_PLIST(r, j))) {
        eq = false;
        break;
      }
    }
  } else {
    eq = false;
  }

  // Otherwise compare their content
  if (!eq) {
    min = nr1 < nr2 ? nr1 : nr2;

    for (j = 1; j <= min; j++) {
      jj = INT_INTOBJ(ELM_PLIST(l, j)) - 1;
      buf[jj]++;
      jj = INT_INTOBJ(ELM_PLIST(r, j)) - 1;
      buf[jj]--;
    }

    for (j = min + 1; j <= nr1; j++) {
      jj = INT_INTOBJ(ELM_PLIST(l, j)) - 1;
      buf[jj]++;
    }

    for (j = min + 1; j <= nr2; j++) {
      jj = INT_INTOBJ(ELM_PLIST(r, j)) - 1;
      buf[jj]--;
    }

    for (j = 0; j < n; j++) {
      if (buf[j] < 0) {
        // Pr("Found difference: range: %d, number: %d\n", j + 1, buf[j]);
        return 2;
      } else if (buf[j] > 0) {
        // Pr("Found difference: range: %d, number: %d\n", j + 1, buf[j]);
        return 1;
      }
    }
  }
  return 0;
  // Return 0: l = r (as multisets)
  // Return 1: l < r
  // Return 2: r < l
}

static Obj FuncDIGRAPH_LT(Obj self, Obj digraph1, Obj digraph2) {
  UInt i, n1, n2, m1, m2;
  Obj  out1, out2, a, b;
  Int  nr1, nr2, *buf, comp, max;

  // Compare NrVertices
  n1 = DigraphNrVertices(digraph1);
  n2 = DigraphNrVertices(digraph2);
  if (n1 < n2) {
    return True;
  } else if (n2 < n1) {
    return False;
  }

  // Compare NrEdges
  m1 = DigraphNrEdges(digraph1);
  m2 = DigraphNrEdges(digraph2);

  if (m1 < m2) {
    return True;
  } else if (m2 < m1) {
    return False;
  }

  out1 = FuncOutNeighbours(self, digraph1);
  out2 = FuncOutNeighbours(self, digraph2);

  buf = calloc(n1, sizeof(Int));

  // Compare Sorted(out1[i]) and Sorted(out2[i]) for each vertex i
  for (i = 1; i <= n1; i++) {
    a = ELM_PLIST(out1, i);
    b = ELM_PLIST(out2, i);
    PLAIN_LIST(a);
    PLAIN_LIST(b);

    nr1 = LEN_PLIST(a);
    nr2 = LEN_PLIST(b);
    max = nr1 < nr2 ? nr2 : nr1;

    // Check whether both vertices have 0 out-degree
    if (max != 0) {
      if (nr1 == 0) {
        free(buf);
        return False;
      } else if (nr2 == 0) {
        free(buf);
        return True;
      }
      // Both vertices have positive out-degree

      // Compare out1[i] and out2[i]
      comp = LTJumbledPlists(a, b, nr1, nr2, buf, n1);
      if (comp == 1) {
        free(buf);
        return True;
      } else if (comp == 2) {
        free(buf);
        return False;
      }
      // if comp == 0 then the lists are equal, so continue
    }
  }
  free(buf);
  return False;
}

// bliss

BlissGraph* buildBlissMultiDigraph(Obj digraph) {
  UInt        n, i, j, k, l, nr;
  Obj         adji, adj;
  BlissGraph* graph;

  n     = DigraphNrVertices(digraph);
  graph = bliss_digraphs_new(n);

  adj = FuncOutNeighbours(0L, digraph);
  for (i = 1; i <= n; i++) {
    adji = ELM_PLIST(adj, i);
    nr   = LEN_PLIST(adji);
    for (j = 1; j <= nr; j++) {
      k = bliss_digraphs_add_vertex(graph, 1);
      l = bliss_digraphs_add_vertex(graph, 2);
      bliss_digraphs_add_edge(graph, i - 1, k);
      bliss_digraphs_add_edge(graph, k, l);
      bliss_digraphs_add_edge(graph, l, INT_INTOBJ(ELM_PLIST(adji, j)) - 1);
    }
  }
  return graph;
}

// TODO: document mult (and everything else)
BlissGraph* buildBlissDigraph(Obj digraph, Obj vert_colours, Obj edge_colours) {
  uint64_t    colour, mult, num_vc, num_ec, n, i, j, k, nr;
  Obj         adjj, adj;
  BlissGraph* graph;

  n      = DigraphNrVertices(digraph);
  num_vc = 0;
  num_ec = 0;

  // TODO: make a decision about this
  // mult = (orientation_double == True) ? 2 : 1;

  mult = 2;

  if (vert_colours != Fail) {
    DIGRAPHS_ASSERT(n == (uint64_t) LEN_LIST(vert_colours));
    for (i = 1; i <= n; i++) {
      num_vc = MAX(num_vc, (uint64_t) INT_INTOBJ(ELM_LIST(vert_colours, i)));
    }
  }

  adj = FuncOutNeighbours(0L, digraph);

  if (edge_colours != Fail) {
    DIGRAPHS_ASSERT(n == (uint64_t) LEN_LIST(edge_colours));
    for (i = 1; i <= n; i++) {
      Int len = LEN_LIST(ELM_PLIST(edge_colours, i));
      DIGRAPHS_ASSERT(LEN_LIST(ELM_PLIST(adj, i)) == len);
      for (Int l = 1; l <= len; l++) {
        uint64_t x = INT_INTOBJ(ELM_LIST(ELM_LIST(edge_colours, i), l));
        num_ec     = MAX(num_ec, x);
      }
    }
  } else if (DigraphNrEdges(digraph) > 0) {
    num_ec = 1;
  }

  graph = bliss_digraphs_new(0);

  // TODO: make this safe
  uint64_t num_layers = 64 - __builtin_clzll(num_ec);

  // Take care of the case where there are no edges in the digraph
  if (DigraphNrEdges(digraph) == 0) {
    num_layers = 1;
    mult       = 1;
  }

  if (vert_colours == Fail) {
    num_vc = 1;
  }

  // TODO: is duplicating the best idea here?
  for (i = 1; i <= mult * num_layers; i += mult) {
    for (j = 1; j <= n; j++) {
      colour = (vert_colours != Fail)
                   ? (i - 1) * num_vc + INT_INTOBJ(ELM_LIST(vert_colours, j))
                   : i - 1;
      bliss_digraphs_add_vertex(graph, colour);
    }
    if (mult == 2) {
      for (j = 1; j <= n; j++) {
        colour = (vert_colours != Fail)
                     ? i * num_vc + INT_INTOBJ(ELM_LIST(vert_colours, j))
                     : i;
        bliss_digraphs_add_vertex(graph, colour);
      }
    }
  }

  if (mult == 2) {
    for (i = 0; i < n; i++) {
      j = bliss_digraphs_add_vertex(graph, num_vc * num_layers * mult + 2);
      bliss_digraphs_add_edge(graph, j, i);
      bliss_digraphs_add_edge(graph, j, i + n);
      for (k = 0; k < num_layers; k++) {
        bliss_digraphs_add_edge(graph, j, i + k * mult * n);
        bliss_digraphs_add_edge(graph, j, i + (k * mult + 1) * n);
      }
    }
  }

  for (i = 1; i < num_layers; i++) {
    for (j = 1; j <= mult * n; j++) {
      bliss_digraphs_add_edge(
          graph, (i - 1) * mult * n + (j - 1), i * mult * n + (j - 1));
    }
  }

  for (j = 1; j <= n; j++) {
    adjj = ELM_PLIST(adj, j);
    nr   = LEN_PLIST(adjj);
    for (k = 1; k <= nr; k++) {
      uint64_t w = INT_INTOBJ(ELM_PLIST(adjj, k));
      for (i = 0; i < num_layers; i++) {
        uint64_t colour =
            edge_colours != Fail
                ? INT_INTOBJ(ELM_LIST(ELM_LIST(edge_colours, j), k))
                : 1;
        if ((1 << i) & colour) {
          bliss_digraphs_add_edge(graph,
                                  i * mult * n + (j - 1),
                                  ((i + 1) * mult - 1) * n + (w - 1));
        }
      }
    }
  }
  return graph;
}

BlissGraph* buildBlissMultiDigraphWithColours(Obj digraph, Obj colours) {
  UInt        n, i, j, k, l, nr;
  Obj         adji, adj;
  BlissGraph* graph;

  n = DigraphNrVertices(digraph);
  DIGRAPHS_ASSERT(n == (UInt) LEN_LIST(colours));
  graph = bliss_digraphs_new(0);
  adj   = FuncOutNeighbours(0L, digraph);

  for (i = 1; i <= n; i++) {
    bliss_digraphs_add_vertex(graph, INT_INTOBJ(ELM_LIST(colours, i)));
  }
  for (i = 1; i <= n; i++) {
    bliss_digraphs_add_vertex(graph, n + 1);
  }
  for (i = 1; i <= n; i++) {
    bliss_digraphs_add_vertex(graph, n + 2);
  }

  for (i = 1; i <= n; i++) {
    bliss_digraphs_add_edge(graph, i - 1, n + i - 1);
    bliss_digraphs_add_edge(graph, i - 1, 2 * n + i - 1);
    adji = ELM_PLIST(adj, i);
    nr   = LEN_PLIST(adji);
    for (j = 1; j <= nr; j++) {
      k = bliss_digraphs_add_vertex(graph, n + 3);
      l = bliss_digraphs_add_vertex(graph, n + 4);
      bliss_digraphs_add_edge(graph, n + i - 1, k);
      bliss_digraphs_add_edge(graph, k, l);
      bliss_digraphs_add_edge(
          graph, l, 2 * n + INT_INTOBJ(ELM_PLIST(adji, j)) - 1);
    }
  }

  return graph;
}

void digraph_hook_function(void*               user_param,
                           unsigned int        N,
                           const unsigned int* aut) {
  UInt4* ptr;
  Obj    p, gens;
  UInt   i, n;

  n = INT_INTOBJ(ELM_PLIST(user_param, 2));  // the degree
  DIGRAPHS_ASSERT(n <= N);
  p   = NEW_PERM4(n);
  ptr = ADDR_PERM4(p);

  for (i = 0; i < n; i++) {
    ptr[i] = aut[i];
  }

  gens = ELM_PLIST(user_param, 1);
  AssPlist(gens, LEN_PLIST(gens) + 1, p);
}

// Take a list of C integers, and multiply them together into a GAP int
static Obj MultiplyList(int* vals, int length) {
  Obj res = INTOBJ_INT(1);
  for (int i = 0; i < length; ++i) {
    res = ProdInt(res, INTOBJ_INT(vals[i]));
  }
  return res;
}

static Obj FuncDIGRAPH_AUTOMORPHISMS(Obj self,
                                     Obj digraph,
                                     Obj vert_colours,
                                     Obj edge_colours) {
  Obj                 autos, p, n;
  BlissGraph*         graph;
  UInt4*              ptr;
  const unsigned int* canon;
  Int                 i;

  graph = buildBlissDigraph(digraph, vert_colours, edge_colours);

  autos = NEW_PLIST(T_PLIST, 3);
  n     = INTOBJ_INT(DigraphNrVertices(digraph));

  SET_ELM_PLIST(autos, 1, NEW_PLIST(T_PLIST, 0));  // perms of the vertices
  CHANGED_BAG(autos);
  SET_ELM_PLIST(autos, 2, n);
  SET_LEN_PLIST(autos, 2);

  BlissStats stats;

  canon = bliss_digraphs_find_canonical_labeling(
      graph, digraph_hook_function, autos, &stats);

  p   = NEW_PERM4(INT_INTOBJ(n));
  ptr = ADDR_PERM4(p);

  for (i = 0; i < INT_INTOBJ(n); i++) {
    ptr[i] = canon[i];
  }
  SET_ELM_PLIST(autos, 2, p);
  CHANGED_BAG(autos);

  bliss_digraphs_release(graph);
  if (LEN_PLIST(ELM_PLIST(autos, 1)) != 0) {
    SortDensePlist(ELM_PLIST(autos, 1));
    RemoveDupsDensePlist(ELM_PLIST(autos, 1));
  }

#ifdef DIGRAPHS_WITH_INCLUDED_BLISS
  Obj size = MultiplyList(stats.group_size, stats.group_size_len);
  bliss_digraphs_free_blissstats(&stats);

  SET_LEN_PLIST(autos, 3);
  SET_ELM_PLIST(autos, 3, size);
#endif

  return autos;
}

// user_param = [vertex perms, nr vertices, edge perms, nr edges]
void multidigraph_hook_function(void*               user_param,
                                unsigned int        N,
                                const unsigned int* aut) {
  UInt4* ptr;
  Obj    p, gens;
  UInt   i, n, m;
  bool   stab;

  m = INT_INTOBJ(ELM_PLIST(user_param, 2));  // the nr of vertices
  DIGRAPHS_ASSERT(m <= N);

  stab = true;
  for (i = 0; i < m; i++) {
    if (aut[i] != i) {
      stab = false;
    }
  }
  if (stab) {                                    // permutation of the edges
    n   = INT_INTOBJ(ELM_PLIST(user_param, 4));  // the nr of edges
    p   = NEW_PERM4(n);
    ptr = ADDR_PERM4(p);
    DIGRAPHS_ASSERT(2 * (n - 1) + m <= N);
    for (i = 0; i < n; i++) {
      ptr[i] = (aut[2 * i + m] - m) / 2;
    }
    gens = ELM_PLIST(user_param, 3);
  } else {  // permutation of the vertices
    p   = NEW_PERM4(m);
    ptr = ADDR_PERM4(p);
    DIGRAPHS_ASSERT(m <= N);
    for (i = 0; i < m; i++) {
      ptr[i] = aut[i];
    }
    gens = ELM_PLIST(user_param, 1);
  }

  AssPlist(gens, LEN_PLIST(gens) + 1, p);
}

// user_param = [vertex perms, nr vertices, edge perms, nr edges]
void multidigraph_colours_hook_function(void*               user_param,
                                        unsigned int        N,
                                        const unsigned int* aut) {
  UInt4* ptr;
  Obj    p, gens;
  UInt   i, n, m;
  bool   stab;

  m = INT_INTOBJ(ELM_PLIST(user_param, 2));  // the nr of vertices
  DIGRAPHS_ASSERT(m <= N);

  stab = true;
  for (i = 0; i < m; i++) {
    if (aut[i] != i) {
      stab = false;
    }
  }
  if (stab) {                                    // permutation of the edges
    n   = INT_INTOBJ(ELM_PLIST(user_param, 4));  // the nr of edges
    p   = NEW_PERM4(n);
    ptr = ADDR_PERM4(p);
    DIGRAPHS_ASSERT(2 * (n - 1) + 3 * m <= N);
    for (i = 0; i < n; i++) {
      ptr[i] = (aut[2 * i + 3 * m] - 3 * m) / 2;
    }
    gens = ELM_PLIST(user_param, 3);
  } else {  // permutation of the vertices
    p   = NEW_PERM4(m);
    ptr = ADDR_PERM4(p);
    DIGRAPHS_ASSERT(m < N);
    for (i = 0; i < m; i++) {
      ptr[i] = aut[i];
    }
    gens = ELM_PLIST(user_param, 1);
  }

  AssPlist(gens, LEN_PLIST(gens) + 1, p);
}

static Obj FuncMULTIDIGRAPH_AUTOMORPHISMS(Obj self, Obj digraph, Obj colours) {
  Obj                 autos, p, q, out;
  BlissGraph*         graph;
  UInt4*              ptr;
  const unsigned int* canon;
  Int                 i, m, n;

  if (colours == False) {
    graph = buildBlissMultiDigraph(digraph);
  } else {
    graph = buildBlissMultiDigraphWithColours(digraph, colours);
  }
  autos = NEW_PLIST(T_PLIST, 4);
  SET_ELM_PLIST(autos, 1, NEW_PLIST(T_PLIST, 0));  // perms of the vertices
  CHANGED_BAG(autos);
  SET_ELM_PLIST(autos, 2, INTOBJ_INT(DigraphNrVertices(digraph)));
  SET_ELM_PLIST(autos, 3, NEW_PLIST(T_PLIST, 0));  // perms of the edges
  CHANGED_BAG(autos);
  SET_ELM_PLIST(autos, 4, INTOBJ_INT(DigraphNrEdges(digraph)));

  BlissStats stats;

  if (colours == False) {
    canon = bliss_digraphs_find_canonical_labeling(
        graph, multidigraph_hook_function, autos, &stats);
  } else {
    canon = bliss_digraphs_find_canonical_labeling(
        graph, multidigraph_colours_hook_function, autos, &stats);
  }

  // Get canonical labeling as GAP perms
  m   = DigraphNrVertices(digraph);
  p   = NEW_PERM4(m);  // perm of vertices
  ptr = ADDR_PERM4(p);

  for (i = 0; i < m; i++) {
    ptr[i] = canon[i];
  }

  n   = DigraphNrEdges(digraph);
  q   = NEW_PERM4(n);  // perm of edges
  ptr = ADDR_PERM4(q);

  if (colours == False) {
    for (i = 0; i < n; i++) {
      ptr[i] = canon[2 * i + m] - m;
    }
  } else {
    for (i = 0; i < n; i++) {
      ptr[i] = canon[2 * i + 3 * m] - 3 * m;
    }
  }

  bliss_digraphs_release(graph);

  // put the canonical labeling (as a list of two perms) into autos[2]
  out = NEW_PLIST(T_PLIST, 2);
  SET_ELM_PLIST(out, 1, p);
  SET_ELM_PLIST(out, 2, q);
  SET_LEN_PLIST(out, 2);
  CHANGED_BAG(out);

  SET_ELM_PLIST(autos, 2, out);
  CHANGED_BAG(autos);

  // remove 4th entry of autos (the number of edges) . . .
  SET_LEN_PLIST(autos, 3);

  if (LEN_PLIST(ELM_PLIST(autos, 1)) != 0) {
    SortDensePlist(ELM_PLIST(autos, 1));
    RemoveDupsDensePlist(ELM_PLIST(autos, 1));
  }
  if (LEN_PLIST(ELM_PLIST(autos, 3)) != 0) {
    SortDensePlist(ELM_PLIST(autos, 3));
    RemoveDupsDensePlist(ELM_PLIST(autos, 3));
  }

#ifdef DIGRAPHS_WITH_INCLUDED_BLISS
  Obj size = MultiplyList(stats.group_size, stats.group_size_len);
  bliss_digraphs_free_blissstats(&stats);

  SET_LEN_PLIST(autos, 4);
  SET_ELM_PLIST(autos, 4, size);
#endif

  return autos;
}

static Obj FuncDIGRAPH_CANONICAL_LABELLING(Obj self, Obj digraph, Obj colours) {
  Obj                 p;
  UInt4*              ptr;
  BlissGraph*         graph;
  Int                 n, i;
  const unsigned int* canon;

  if (colours == Fail) {
    graph = buildBlissDigraph(digraph, NULL, NULL);
  } else {
    graph = buildBlissDigraph(digraph, colours, NULL);
  }

  canon = bliss_digraphs_find_canonical_labeling(graph, 0, 0, 0);

  n   = DigraphNrVertices(digraph);
  p   = NEW_PERM4(n);
  ptr = ADDR_PERM4(p);

  for (i = 0; i < n; i++) {
    ptr[i] = canon[i];
  }
  bliss_digraphs_release(graph);

  return p;
}

static Obj
FuncMULTIDIGRAPH_CANONICAL_LABELLING(Obj self, Obj digraph, Obj colours) {
  Obj                 p, q, out;
  UInt4*              ptr;
  BlissGraph*         graph;
  Int                 m, n, i;
  const unsigned int* canon;

  if (colours == Fail) {
    graph = buildBlissMultiDigraph(digraph);
  } else {
    graph = buildBlissMultiDigraphWithColours(digraph, colours);
  }

  canon = bliss_digraphs_find_canonical_labeling(graph, 0, 0, 0);

  m   = DigraphNrVertices(digraph);
  p   = NEW_PERM4(m);  // perm of vertices
  ptr = ADDR_PERM4(p);

  for (i = 0; i < m; i++) {
    ptr[i] = canon[i];
  }

  n   = DigraphNrEdges(digraph);
  q   = NEW_PERM4(n);  // perm of edges
  ptr = ADDR_PERM4(q);

  if (colours == Fail) {
    for (i = 0; i < n; i++) {
      ptr[i] = canon[2 * i + m] - m;
    }
  } else {
    for (i = 0; i < n; i++) {
      ptr[i] = canon[2 * i + 3 * m] - 3 * m;
    }
  }

  bliss_digraphs_release(graph);

  out = NEW_PLIST(T_PLIST, 2);
  SET_ELM_PLIST(out, 1, p);
  SET_ELM_PLIST(out, 2, q);
  SET_LEN_PLIST(out, 2);
  CHANGED_BAG(out);

  return out;
}

/*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * */

/******************************************************************************
 *V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
 */

static StructGVarFunc GVarFuncs[] = {
    {"DIGRAPH_NREDGES",
     1,
     "digraph",
     FuncDIGRAPH_NREDGES,
     "src/digraphs.c:DIGRAPH_NREDGES"},

    {"GABOW_SCC", 1, "adj", FuncGABOW_SCC, "src/digraphs.c:GABOW_SCC"},

    {"DIGRAPH_CONNECTED_COMPONENTS",
     1,
     "digraph",
     FuncDIGRAPH_CONNECTED_COMPONENTS,
     "src/digraphs.c:DIGRAPH_CONNECTED_COMPONENTS"},

    {"IS_ACYCLIC_DIGRAPH",
     1,
     "adj",
     FuncIS_ACYCLIC_DIGRAPH,
     "src/digraphs.c:FuncIS_ACYCLIC_DIGRAPH"},

    {"DIGRAPH_LONGEST_DIST_VERTEX",
     2,
     "adj, start",
     FuncDIGRAPH_LONGEST_DIST_VERTEX,
     "src/digraphs.c:FuncDIGRAPH_LONGEST_DIST_VERTEX"},

    {"DIGRAPH_TRANS_REDUCTION",
     1,
     "list",
     FuncDIGRAPH_TRANS_REDUCTION,
     "src/digraphs.c:FuncDIGRAPH_TRANS_REDUCTION"},

    {"IS_ANTISYMMETRIC_DIGRAPH",
     1,
     "adj",
     FuncIS_ANTISYMMETRIC_DIGRAPH,
     "src/digraphs.c:FuncIS_ANTISYMMETRIC_DIGRAPH"},

    {"IS_STRONGLY_CONNECTED_DIGRAPH",
     1,
     "adj",
     FuncIS_STRONGLY_CONNECTED_DIGRAPH,
     "src/digraphs.c:FuncIS_STRONGLY_CONNECTED_DIGRAPH"},

    {"DIGRAPH_TOPO_SORT",
     1,
     "adj",
     FuncDIGRAPH_TOPO_SORT,
     "src/digraphs.c:FuncDIGRAPH_TOPO_SORT"},

    {"DIGRAPH_SYMMETRIC_SPANNING_FOREST",
     1,
     "adj",
     FuncDIGRAPH_SYMMETRIC_SPANNING_FOREST,
     "src/digraphs.c:FuncDIGRAPH_SYMMETRIC_SPANNING_FOREST"},

    {"DIGRAPH_SOURCE_RANGE",
     1,
     "digraph",
     FuncDIGRAPH_SOURCE_RANGE,
     "src/digraphs.c:FuncDIGRAPH_SOURCE_RANGE"},

    {"DIGRAPH_OUT_NEIGHBOURS",
     1,
     "D",
     FuncOutNeighbours,
     "src/digraphs.c:FuncOutNeighbours"},

    {"DIGRAPH_OUT_NEIGHBOURS_FROM_SOURCE_RANGE",
     3,
     "N, source, range",
     FuncOutNeighboursFromSourceRange,
     "src/digraphs.c:FuncOutNeighboursFromSourceRange"},

    {"DIGRAPH_NR_VERTICES",
     1,
     "D",
     FuncDigraphNrVertices,
     "src/digraphs.c:FuncDigraphNrVertices"},

    {"DIGRAPH_IN_OUT_NBS",
     1,
     "adj",
     FuncDIGRAPH_IN_OUT_NBS,
     "src/digraphs.c:FuncDIGRAPH_IN_OUT_NBS"},

    {"ADJACENCY_MATRIX",
     1,
     "digraph",
     FuncADJACENCY_MATRIX,
     "src/digraphs.c:FuncADJACENCY_MATRIX"},

    {"IS_MULTI_DIGRAPH",
     1,
     "digraph",
     FuncIS_MULTI_DIGRAPH,
     "src/digraphs.c:FuncIS_MULTI_DIGRAPH"},

    {"DIGRAPH_SHORTEST_DIST",
     1,
     "digraph",
     FuncDIGRAPH_SHORTEST_DIST,
     "src/digraphs.c:FuncDIGRAPH_SHORTEST_DIST"},

    {"DIGRAPH_DIAMETER",
     1,
     "digraph",
     FuncDIGRAPH_DIAMETER,
     "src/digraphs.c:FuncDIGRAPH_DIAMETER"},

    {"IS_TRANSITIVE_DIGRAPH",
     1,
     "digraph",
     FuncIS_TRANSITIVE_DIGRAPH,
     "src/digraphs.c:FuncIS_TRANSITIVE_DIGRAPH"},

    {"DIGRAPH_TRANS_CLOSURE",
     1,
     "digraph",
     FuncDIGRAPH_TRANS_CLOSURE,
     "src/digraphs.c:FuncDIGRAPH_TRANS_CLOSURE"},

    {"DIGRAPH_REFLEX_TRANS_CLOSURE",
     1,
     "digraph",
     FuncDIGRAPH_REFLEX_TRANS_CLOSURE,
     "src/digraphs.c:FuncDIGRAPH_REFLEX_TRANS_CLOSURE"},

    {"RANDOM_DIGRAPH",
     2,
     "nn, limm",
     FuncRANDOM_DIGRAPH,
     "src/digraphs.c:FuncRANDOM_DIGRAPH"},

    {"RANDOM_MULTI_DIGRAPH",
     2,
     "nn, mm",
     FuncRANDOM_MULTI_DIGRAPH,
     "src/digraphs.c:FuncRANDOM_MULTI_DIGRAPH"},

    {"DIGRAPH_EQUALS",
     2,
     "digraph1, digraph2",
     FuncDIGRAPH_EQUALS,
     "src/digraphs.c:FuncDIGRAPH_EQUALS"},

    {"DIGRAPH_LT",
     2,
     "digraph1, digraph2",
     FuncDIGRAPH_LT,
     "src/digraphs.c:FuncDIGRAPH_LT"},

    {"DIGRAPH_PATH",
     3,
     "digraph, u, v",
     FuncDIGRAPH_PATH,
     "src/digraphs.c:FuncDIGRAPH_PATH"},

    {"DIGRAPH_AUTOMORPHISMS",
     3,
     "digraph, vert_colours, edge_colours",
     FuncDIGRAPH_AUTOMORPHISMS,
     "src/digraphs.c:FuncDIGRAPH_AUTOMORPHISMS"},

    {"MULTIDIGRAPH_AUTOMORPHISMS",
     2,
     "digraph, colours",
     FuncMULTIDIGRAPH_AUTOMORPHISMS,
     "src/digraphs.c:FuncMULTIDIGRAPH_AUTOMORPHISMS"},

    {"DIGRAPH_CANONICAL_LABELLING",
     2,
     "digraph, colours",
     FuncDIGRAPH_CANONICAL_LABELLING,
     "src/digraphs.c:FuncDIGRAPH_CANONICAL_LABELLING"},

    {"MULTIDIGRAPH_CANONICAL_LABELLING",
     2,
     "digraph, colours",
     FuncMULTIDIGRAPH_CANONICAL_LABELLING,
     "src/digraphs.c:FuncMULTIDIGRAPH_CANONICAL_LABELLING"},

    {"HomomorphismDigraphsFinder",
     -1,
     "digraph1, digraph2, hook, user_param, max_results, hint, "
     "injective, image, partial_map, colors1, colors2",
     FuncHomomorphismDigraphsFinder,
     "src/homos.c:FuncHomomorphismDigraphsFinder"},

    {"IS_PLANAR", 1, "digraph", FuncIS_PLANAR, "src/planar.c:FuncIS_PLANAR"},

    {"PLANAR_EMBEDDING",
     1,
     "digraph",
     FuncPLANAR_EMBEDDING,
     "src/planar.c:FuncPLANAR_EMBEDDING"},

    {"KURATOWSKI_PLANAR_SUBGRAPH",
     1,
     "digraph",
     FuncKURATOWSKI_PLANAR_SUBGRAPH,
     "src/planar.c:FuncKURATOWSKI_PLANAR_SUBGRAPH"},

    {"IS_OUTER_PLANAR",
     1,
     "digraph",
     FuncIS_OUTER_PLANAR,
     "src/planar.c:FuncIS_OUTER_PLANAR"},

    {"OUTER_PLANAR_EMBEDDING",
     1,
     "digraph",
     FuncOUTER_PLANAR_EMBEDDING,
     "src/planar.c:FuncOUTER_PLANAR_EMBEDDING"},

    {"KURATOWSKI_OUTER_PLANAR_SUBGRAPH",
     1,
     "digraph",
     FuncKURATOWSKI_OUTER_PLANAR_SUBGRAPH,
     "src/planar.c:FuncKURATOWSKI_OUTER_PLANAR_SUBGRAPH"},

    {"SUBGRAPH_HOMEOMORPHIC_TO_K23",
     1,
     "digraph",
     FuncSUBGRAPH_HOMEOMORPHIC_TO_K23,
     "src/planar.c:FuncSUBGRAPH_HOMEOMORPHIC_TO_K23"},

    {"SUBGRAPH_HOMEOMORPHIC_TO_K33",
     1,
     "digraph",
     FuncSUBGRAPH_HOMEOMORPHIC_TO_K33,
     "src/planar.c:FuncSUBGRAPH_HOMEOMORPHIC_TO_K33"},

    {"SUBGRAPH_HOMEOMORPHIC_TO_K4",
     1,
     "digraph",
     FuncSUBGRAPH_HOMEOMORPHIC_TO_K4,
     "src/planar.c:FuncSUBGRAPH_HOMEOMORPHIC_TO_K4"},

    {0, 0, 0, 0, 0} /* Finish with an empty entry */
};

/******************************************************************************
 *F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
 */
static Int InitKernel(StructInitInfo* module) {
  /* init filters and functions                                          */
  InitHdlrFuncsFromTable(GVarFuncs);
  ImportGVarFromLibrary("IsDigraph", &IsDigraph);
  ImportGVarFromLibrary("IsDigraphEdge", &IsDigraphEdge);
  ImportGVarFromLibrary("DIGRAPHS_ValidateVertexColouring",
                        &DIGRAPHS_ValidateVertexColouring);
  ImportGVarFromLibrary("infinity", &Infinity);
  ImportGVarFromLibrary("IsSymmetricDigraph", &IsSymmetricDigraph);
  ImportGVarFromLibrary("AutomorphismGroup", &AutomorphismGroup);
  ImportGVarFromLibrary("GeneratorsOfGroup", &GeneratorsOfGroup);
  ImportGVarFromLibrary("IsAttributeStoringRep", &IsAttributeStoringRepObj);
  ImportGVarFromLibrary("IsPermGroup", &IsPermGroup);
  ImportGVarFromLibrary("IsDigraphAutomorphism", &IsDigraphAutomorphism);
  ImportGVarFromLibrary("LargestMovedPointPerms", &LargestMovedPointPerms);
  /* return success                                                      */
  return 0;
}

/******************************************************************************
 *F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
 */
static Int InitLibrary(StructInitInfo* module) {
  /* init filters and functions */
  InitGVarFuncsFromTable(GVarFuncs);

  /* return success                                                      */
  return 0;
}

/******************************************************************************
 *F  InitInfopl()  . . . . . . . . . . . . . . . . . table of init functions
 */
static StructInitInfo module = {
#ifdef DIGRAPHSSTATIC
    .type = MODULE_STATIC,
#else
    .type = MODULE_DYNAMIC,
#endif
    .name        = "digraphs",
    .initKernel  = InitKernel,
    .initLibrary = InitLibrary,
    .postRestore = 0};

#ifndef DIGRAPHSSTATIC
StructInitInfo* Init__Dynamic(void) {
  return &module;
}
#endif

StructInitInfo* Init__digraphs(void) {
  return &module;
}
