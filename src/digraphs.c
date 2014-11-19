/***************************************************************************
**
*A  digraphs.c               Digraphs package             J. D. Mitchell 
**
**  Copyright (C) 2014 - J. D. Mitchell 
**  This file is free software, see license information at the end.
**  
*/

#include "bliss-0.72/bliss_C.h"

#include <stdlib.h>
#include <stdbool.h>

#include "src/compiled.h"          /* GAP headers                */
#include "src/digraphs.h"

#undef PACKAGE
#undef PACKAGE_BUGREPORT
#undef PACKAGE_NAME
#undef PACKAGE_STRING
#undef PACKAGE_TARNAME
#undef PACKAGE_URL
#undef PACKAGE_VERSION


//#include "pkgconfig.h"             /* our own configure results */

/*************************************************************************/

/* These functions are now unnecessary/invalid
bool HasOutNeighbours(Obj digraph) {
  return IsbPRec(digraph, RNamName("adj"));
}

bool HasDigraphSourceAndRange(Obj digraph) {
  return (IsbPRec(digraph, RNamName("source")) 
          &&
          IsbPRec(digraph, RNamName("range")));
}

bool HasDigraphSource(Obj digraph) {
  return IsbPRec(digraph, RNamName("source"));
}

bool HasDigraphRange(Obj digraph) {
  return IsbPRec(digraph, RNamName("range"));
}

Obj DigraphSource(Obj digraph) {
  if (!HasDigraphSource(digraph)) {
    FuncDIGRAPH_SOURCE_RANGE( NULL, digraph );
  }
  return ElmPRec(digraph, RNamName("source"));
}

Obj DigraphRange(Obj digraph) {
  if (!HasDigraphRange(digraph)) {
    FuncDIGRAPH_SOURCE_RANGE( NULL, digraph );
  }
  return ElmPRec(digraph, RNamName("range"));
}*/

Int DigraphNrVertices(Obj digraph) {
  if (IsbPRec(digraph, RNamName("nrvertices"))) {
    return INT_INTOBJ(ElmPRec(digraph, RNamName("nrvertices")));
  }
  // The record comp should always be set so this should never be triggered
  ErrorQuit(
  "Digraphs: DigraphNrVertices (C):\nrec comp <nrvertices> is not set,",
  0L, 0L);
  return 0;
}

Int DigraphNrEdges(Obj digraph) {
  Obj   adj;
  Int  nr, i, n;
  if (IsbPRec(digraph, RNamName("nredges"))) {
    return INT_INTOBJ(ElmPRec(digraph, RNamName("nredges")));
  }
  n   = DigraphNrVertices(digraph);
  adj = OutNeighbours(digraph); 
  nr  = 0;
  for (i = 1; i <= n; i++) {
    nr += LEN_PLIST(ELM_PLIST(adj, i));
  }
  AssPRec(digraph, RNamName("nredges"), INTOBJ_INT(nr));
  return nr;
}

static Obj FuncDIGRAPH_NREDGES(Obj self, Obj digraph) {
  return INTOBJ_INT(DigraphNrEdges(digraph));
}

// Need to decide what we're doing with all this
Obj OutNeighbours(Obj digraph) {
  Obj adj;

  if (IsbPRec(digraph, RNamName("adj"))) {
    return ElmPRec(digraph, RNamName("adj"));
  } else if (IsbPRec(digraph, RNamName("source"))
          && IsbPRec(digraph, RNamName("range"))) {

    adj = FuncDIGRAPH_OUT_NBS( NULL,
                               ElmPRec(digraph, RNamName("nrvertices")),
                               ElmPRec(digraph, RNamName("source")),
                               ElmPRec(digraph, RNamName("range")) );
    AssPRec(digraph, RNamName("adj"), adj);
    return adj;
  }
  ErrorQuit("Digraphs: OutNeighbours (C): not enough record components set,", 0L, 0L);
  return False;
}

/*Obj OutNeighboursOfVertex(Obj digraph, Int v) { 
  Obj out;

  // Do all kinds of safety checking
  out = OutNeighbours(digraph);
  return ELM_PLIST( out, v );
}*/

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
  if (n == 0){
    out = NEW_PREC(2);
    AssPRec(out, RNamName("id"), NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE,0));
    AssPRec(out, RNamName("comps"), NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE,0));
    CHANGED_BAG(out);
    return out;
  }

  end1 = 0; 
  stack1 = NEW_PLIST(T_PLIST_CYC, n); 
  //stack1 is a plist so we can use memcopy below
  SET_LEN_PLIST(stack1, n);
  
  id = NEW_PLIST(T_PLIST_CYC+IMMUTABLE, n);
  SET_LEN_PLIST(id, n);
  
  //init id
  for(v=1;v<=n;v++){
    SET_ELM_PLIST(id, v, INTOBJ_INT(0));
  }
  
  count = n;
  
  comps = NEW_PLIST(T_PLIST_TAB+IMMUTABLE, n);
  SET_LEN_PLIST(comps, 0);
  
  stack2 = malloc( (4 * n + 2) * sizeof(UInt) );
  frames = stack2 + n + 1;
  end2 = 0;
  
  for (v = 1; v <= n; v++) {
    if(INT_INTOBJ(ELM_PLIST(id, v)) == 0){
      adj =  ELM_PLIST(digraph, v);
      PLAIN_LIST(adj);
      level = 1;
      frames[0] = v; // vertex
      frames[1] = 1; // index
      frames[2] = (UInt)adj; 
      SET_ELM_PLIST(stack1, ++end1, INTOBJ_INT(v));
      stack2[++end2] = end1;
      SET_ELM_PLIST(id, v, INTOBJ_INT(end1)); 
      
      while (1) {
        if (frames[1] > (UInt) LEN_PLIST(frames[2])) {
          if (stack2[end2] == (UInt) INT_INTOBJ(ELM_PLIST(id, frames[0]))) {
            end2--;
            count++;
            nr = 0;
            do{
              nr++;
              w = INT_INTOBJ(ELM_PLIST(stack1, end1--));
              SET_ELM_PLIST(id, w, INTOBJ_INT(count));
            }while (w != frames[0]);
            
            comp = NEW_PLIST(T_PLIST_CYC+IMMUTABLE, nr);
            SET_LEN_PLIST(comp, nr);
           
            memcpy( (void *)((char *)(ADDR_OBJ(comp)) + sizeof(Obj)), 
                    (void *)((char *)(ADDR_OBJ(stack1)) + (end1 + 1) * sizeof(Obj)), 
                    (size_t)(nr * sizeof(Obj)));

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
          
          w = INT_INTOBJ(ELM_PLIST(frames[2], frames[1]++));
          idw = INT_INTOBJ(ELM_PLIST(id, w));
          
          if(idw==0){
            adj = ELM_PLIST(digraph, w);
            PLAIN_LIST(adj);
            level++;
            frames += 3; 
            frames[0] = w; // vertex
            frames[1] = 1; // index
            frames[2] = (UInt) adj;
            SET_ELM_PLIST(stack1, ++end1, INTOBJ_INT(w));
            stack2[++end2] = end1;
            SET_ELM_PLIST(id, w, INTOBJ_INT(end1)); 
          } else {
            while (stack2[end2] > idw) {
              end2--; // pop from stack2
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
  CHANGED_BAG(out);
  free(stack2);
  return out;
}

static UInt UF_FIND(UInt *id, UInt i) {
  while (i != id[i])
    i = id[i];
  return i;
}

static void UF_COMBINE_CLASSES(UInt *id, UInt i, UInt j) {
  i = UF_FIND(id, i);
  j = UF_FIND(id, j);
  if (i < j)
    id[j] = i;
  else if (j < i)
    id[i] = j;
  // if i = j then there is nothing to combine
}


static Obj FuncDIGRAPH_CONNECTED_COMPONENTS(Obj self, Obj digraph) {
  UInt n, *id, *nid, i, j, e, len, f, nrcomps;
  Obj  adj, adji, source, range, gid, gcomps, comp, out;

  out = NEW_PREC(2);
  n = DigraphNrVertices(digraph);
  if (n == 0) {
    gid = NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE,0);
    gcomps = NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE,0);
  } else {

    id = malloc( n * sizeof(UInt) );
    for (i = 0; i < n; i++) {
      id[i] = i;
    }

    adj = OutNeighbours(digraph);
    for (i = 0; i < n; i++) {
      adji = ELM_PLIST(adj, i + 1);
      PLAIN_LIST(adji);
      len = LEN_PLIST(adji);
      for (e = 1; e <= len; e++) {
        UF_COMBINE_CLASSES(id, i, INT_INTOBJ(ELM_PLIST( adji, e )) - 1);
      }
    }

    // "Normalise" id, giving it sensible labels
    nid = malloc(n * sizeof(UInt));
    nrcomps = 0;
    for (i = 0; i < n; i++) {
      f = UF_FIND(id, i);
      nid[i] = (f == i) ? ++nrcomps : nid[f];
    }
    free(id);

    // Make GAP object from nid
    gid = NEW_PLIST(T_PLIST_CYC+IMMUTABLE, n);
    gcomps = NEW_PLIST(T_PLIST_CYC+IMMUTABLE, nrcomps);
    SET_LEN_PLIST(gid, n);
    SET_LEN_PLIST(gcomps, nrcomps);
    for (i = 1; i <= nrcomps; i++) {
      SET_ELM_PLIST(gcomps, i, NEW_PLIST(T_PLIST_CYC+IMMUTABLE,0));
      CHANGED_BAG(gcomps);
      SET_LEN_PLIST(ELM_PLIST(gcomps, i), 0);
    }
    for (i = 1; i <= n; i++) {
      SET_ELM_PLIST(gid, i, INTOBJ_INT(nid[i - 1]));
      comp = ELM_PLIST(gcomps, nid[i - 1]);
      len = LEN_PLIST(comp);
      AssPlist(comp, len + 1, INTOBJ_INT(i));
    }
    free(nid);

  }
  AssPRec(out, RNamName("id"), gid);
  AssPRec(out, RNamName("comps"), gcomps);
  CHANGED_BAG(out);
  return out;
}

static Obj FuncIS_ACYCLIC_DIGRAPH(Obj self, Obj adj) { 
  UInt  nr, i, j, k, level;
  Obj   nbs;
  UInt  *stack, *ptr;
  
  nr = LEN_PLIST(adj);

  //init the buf
  ptr = calloc( nr + 1, sizeof(UInt) );
  stack =  malloc( (2 * nr + 2) * sizeof(UInt) );
  
  for (i = 1; i <= nr; i++) {
    nbs = ELM_PLIST(adj, i);
    if (LEN_LIST(nbs) == 0) {
      ptr[i] = 1;
    } else if (ptr[i] == 0) {
      level = 1;
      stack[0] = i;
      stack[1] = 1;
      while (1) {
        j = stack[0];
        k = stack[1];
        if (ptr[j] == 2) {
          free(ptr);
          stack -= (2 * level) - 2; // put the stack back to the start
          free(stack);
          return False;  // We have just travelled around a cycle
        }
        // Check whether:
        // 1. We've previously finished with this vertex, OR 
        // 2. Whether we've now investigated all descendant branches
        nbs = ELM_PLIST(adj, j);
        if( ptr[j] == 1 || k > (UInt) LEN_LIST(nbs)) {
          ptr[j] = 1;
          level--;
          if (level == 0) { 
            break;
          }
          // Backtrack and choose next available branch
          stack -= 2;
          ptr[stack[0]] = 0; 
          stack[1]++;
        } else { //Otherwise move onto the next available branch
          ptr[j] = 2; 
          level++;
          nbs = ELM_PLIST(adj, j);
          stack += 2;
          stack[0] = INT_INTOBJ(ADDR_OBJ(nbs)[k]);
          stack[1] = 1;
        }
      }
    }
  }
  free(ptr);
  free(stack);
  return True;
}

static Obj FuncDIGRAPHS_IS_REACHABLE(Obj self, Obj adj, Obj u, Obj v) { 
  UInt  nr, i, j, k, level, target;
  Obj   nbs;
  UInt  *stack, *ptr;

  i      = INT_INTOBJ(u);
  nbs    = ELM_PLIST(adj, i);
  if (LEN_LIST(nbs) == 0) {
    return False;
  }
  target = INT_INTOBJ(v);
  nr     = LEN_PLIST(adj);

  //init the buf
  ptr = calloc( nr + 1, sizeof(UInt) );
  stack =  malloc( (2 * nr + 2) * sizeof(UInt) );

  level = 1;
  stack[0] = i;
  stack[1] = 1;
  while (1) {
    j = stack[0];
    k = stack[1];
    // Check whether:
    // 1. We've previously visited with this vertex, OR 
    // 2. Whether we've now investigated all descendant branches
    nbs = ELM_PLIST(adj, j);
    if( ptr[j] != 0 || k > (UInt) LEN_LIST(nbs)) {
      ptr[j] = 1;
      level--;
      if (level == 0) { 
        break;
      }
      // Backtrack and choose next available branch
      stack -= 2;
      ptr[stack[0]] = 0; 
      stack[1]++;
    } else { //Otherwise move onto the next available branch
      ptr[j] = 2; 
      level++;
      nbs = ELM_PLIST(adj, j);
      stack += 2;
      stack[0] = INT_INTOBJ(ADDR_OBJ(nbs)[k]);
      if (stack[0] == target) {
        free(ptr);
        stack -= (2 * level) - 2; // put the stack back to the start
        free(stack);
        return True;
      }
      stack[1] = 1;
    }
  }
  free(ptr);
  free(stack);
  return False;
}

static Obj FuncIS_ANTISYMMETRIC_DIGRAPH(Obj self, Obj adj) {
  Int  nr, i, j, k, l, level, last1, last2;
  Obj   nbs;
  UInt  *stack, *ptr;
  
  nr = LEN_PLIST(adj);
  if (nr <= 1) {
    return True;
  }

  //init the buf (is this correct length?)
  ptr = calloc( nr + 1, sizeof(UInt) );
  stack =  malloc( (4 * nr + 4) * sizeof(UInt) );
  
  for (i = 1; i <= nr; i++) {
    nbs = ELM_PLIST(adj, i);
    if (LEN_LIST(nbs) == 0) {
      ptr[i] = 1;
    } else if (ptr[i] == 0) {
      level = 1;
      stack[0] = i;
      stack[1] = 1;
      stack[2] = 0;
      stack[3] = 0;
      while (1) {
        j = stack[0];
        k = stack[1];
        last1 = stack[2];
        last2 = stack[3];
        if (j == last2 && j != last1) {
          free(ptr);
          stack -= (4 * level) - 4; // put the stack back to the start
          free(stack);
          return False;  // Found a non-loop cycle of length 2 
        }
        // Check whether:
        // 1. We've previously finished with this vertex, OR 
        // 2. Whether we've now investigated all descendant branches
        nbs = ELM_PLIST(adj, j);
        if( ptr[j] == 2 ) {
          PLAIN_LIST(nbs);
          for ( l = 1; l <= LEN_PLIST(nbs); l++ ) {
            if ( last1 != j && INT_INTOBJ(ADDR_OBJ(nbs)[l]) == last1 ) {
              return False;
            }
          }
        }
        if ( k > LEN_LIST(nbs) ) {
          ptr[j] = 1;
        }
        if( ptr[j] >= 1 ) {
          level--;
          if (level == 0) { 
            break;
          }
          // Backtrack and choose next available branch
          stack -= 4;
          ptr[stack[0]] = 0; 
          stack[1]++;
        } else { //Otherwise move onto the next available branch
          ptr[j] = 2;
          level++;
          nbs = ELM_PLIST(adj, j);
          stack += 4;
          stack[0] = INT_INTOBJ(ADDR_OBJ(nbs)[k]);
          stack[1] = 1;
          stack[2] = j; // I am wasting memory here, duplicating info
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
  if (n == 0){
    return True;
  }

  nextid = 1;
  bag = malloc(n * 4 * sizeof(UInt));
  ptr1 = bag;
  ptr2 = bag + n;
  fptr = bag + n * 2;
  id = calloc(n + 1, sizeof(UInt));

  // first vertex v=1
  PLAIN_LIST(ELM_PLIST(digraph, 1));
  fptr[0] = 1; // vertex
  fptr[1] = 1; // index
  *ptr1 = 1; 
  *ptr2 = nextid;
  id[1] = nextid;
  
  while (1) { // we always return before level = 0
    if (fptr[1] > (UInt) LEN_PLIST(ELM_PLIST(digraph, fptr[0]))) {
      if (*ptr2 == id[fptr[0]]) {
        do {
          n--;
        } while (*(ptr1--) != fptr[0]);
        free(bag);
        free(id);
        return n==0 ? True : False;
      }
      fptr -= 2;
    } else {
      w = INT_INTOBJ(ELM_PLIST(ELM_PLIST(digraph, fptr[0]), fptr[1]++));
      if(id[w] == 0){
        PLAIN_LIST(ELM_PLIST(digraph, w));
        fptr += 2; 
        fptr[0] = w; // vertex
        fptr[1] = 1; // index
        nextid++;
        *(++ptr1) = w; 
        *(++ptr2) = nextid;
        id[w] = nextid;
      } else {
        while ((*ptr2) > id[w]) {
          ptr2--;
        }
      }
    }
  }
  //this should never happen, just to keep the compiler happy
  return Fail;
}

static Obj FuncDIGRAPH_TOPO_SORT(Obj self, Obj adj) {
  UInt  nr, i, j, k, count;
  UInt  level;
  Obj   buf, nbs, out;
  UInt  *stack, *ptr;
  
  nr = LEN_PLIST(adj);
  
  if (nr == 0) {
    return adj;
  }
  out = NEW_PLIST(T_PLIST_CYC+IMMUTABLE, nr);
  SET_LEN_PLIST(out, nr);
  if (nr == 1) {
    SET_ELM_PLIST(out, 1, INTOBJ_INT(1));
    return out;
  }

  //init the buf
  ptr = calloc( nr + 1, sizeof(UInt) );
  stack =  malloc( (2 * nr + 2) * sizeof(UInt) );
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
      level = 1;
      stack[0] = i;
      stack[1] = 1;
      while (1) {
        j = stack[0];
        k = stack[1];
        if (ptr[j] == 2) {
          //SetIsAcyclicDigraph(graph, false);
          stack -= 2;
          level--;
          if ( stack[0] != j ) { //Cycle is not just a loop
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
        if( ptr[j] == 1 || k > (UInt) LEN_LIST(nbs)) {
          if ( ptr[j] == 0 ) {
            // ADD J TO THE END OF OUR LIST
            count++;
            SET_ELM_PLIST(out, count, INTOBJ_INT(j));
          }
          ptr[j] = 1;
          level--;
          if (level==0) {
            break;
          }
          // Backtrack and choose next available branch
          stack -= 2;
          ptr[stack[0]] = 0;
          stack[1]++;
        } else { //Otherwise move onto the next available branch
          ptr[j] = 2;
          level++;
          nbs = ELM_PLIST(adj, j);
          stack += 2;
          stack[0] = INT_INTOBJ(ADDR_OBJ(nbs)[k]);
          stack[1] = 1;
        }
      }
    } 
  }
  free(ptr);
  free(stack);
  return out;
}

static Obj FuncDIGRAPH_SOURCE_RANGE(Obj self, Obj digraph) {
  Obj   source, range, adj, adji;
  Int   i, j, k, m, n, len;

  m      = DigraphNrEdges(digraph);
  n      = DigraphNrVertices(digraph);
  adj    = OutNeighbours(digraph); 
  source = NEW_PLIST(T_PLIST_CYC+IMMUTABLE, m);
  range  = NEW_PLIST(T_PLIST_CYC+IMMUTABLE, m);
  SET_LEN_PLIST(source, m);
  SET_LEN_PLIST(range, m);

  k = 0;
  for ( i = 1; i <= n; i++ ) {
    adji = ELM_PLIST( adj, i );
    len    = LEN_LIST( adji );
    for ( j = 1; j <= len; j++ ) {
      k++;
      SET_ELM_PLIST( source, k, INTOBJ_INT( i ) );
      SET_ELM_PLIST( range,  k, ELM_LIST( adji, j ) );
    }
  }
  AssPRec(digraph, RNamName("source"), source);
  AssPRec(digraph, RNamName("range"),  range);
  return True;
}

// Assume we are passed a GAP Int nrvertices
// Two GAP lists of PosInts (all <= nrvertices) of equal length
static Obj FuncDIGRAPH_OUT_NBS(Obj self, Obj nrvertices, Obj source, Obj range) { 
  Obj   adj, adjj;
  UInt  n, m, i, j, len, m1, m2;
 
  m1 = LEN_LIST(source);
  m2 = LEN_LIST(range);
  if (m1 != m2) {
    ErrorQuit("Digraphs: DIGRAPH_OUT_NBS: usage,\n<source> and <range> must be lists of equal length,", 0L, 0L);
  }
  n = INT_INTOBJ(nrvertices);
  if (n == 0) {
    adj = NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE, 0);
  } else {
 
    PLAIN_LIST(source);
    PLAIN_LIST(range);

    adj = NEW_PLIST(T_PLIST_TAB+IMMUTABLE, n);
    SET_LEN_PLIST(adj, n);
    
    // fill adj with empty plists 
    for (i = 1; i <= n; i++) {
      SET_ELM_PLIST(adj, i, NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE, 0));
      SET_LEN_PLIST(ELM_PLIST(adj, i), 0);
      CHANGED_BAG(adj);
    }
    
    n = m1;
    for (i = 1; i <= n; i++) {
      j = INT_INTOBJ(ELM_PLIST(source, i));
      adjj = ELM_PLIST(adj, j);
      len = LEN_PLIST(adjj); 
      if (len == 0){
        RetypeBag(adjj, T_PLIST_CYC+IMMUTABLE);
        CHANGED_BAG(adj);
      }
      AssPlist(adjj, len + 1,  ELM_PLIST(range, i));
    }
  }

  //AssPRec(digraph, RNamName("adj"), adj);
  return adj;
}

// Function to change Out-Neighbours to In-Neighbours, and vice versa
static Obj FuncDIGRAPH_IN_OUT_NBS(Obj self, Obj adj) { 
  Obj   inn, innk, innj, adji;
  UInt  n, m, i, j, k, len, len2;
  
  n = LEN_PLIST(adj);
  if (n == 0) {
    inn = NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE, 0);
  } else {
    inn = NEW_PLIST(T_PLIST_TAB+IMMUTABLE, n);
    SET_LEN_PLIST(inn, n);

    // fill adj with empty plists 
    for (i = 1; i <= n; i++) {
      SET_ELM_PLIST(inn, i, NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE, 0));
      SET_LEN_PLIST(ELM_PLIST(inn, i), 0);
      CHANGED_BAG(inn);
    }

    for (i = 1; i <= n; i++){
      adji = ELM_PLIST(adj, i);
      len = LEN_PLIST(adji);
      for (j = 1; j <= len; j++){
        k = INT_INTOBJ(ELM_PLIST(adji, j));
        innk = ELM_PLIST(inn, k);
        len2 = LEN_PLIST(innk); 
        if(len2 == 0){
          RetypeBag(innk, T_PLIST_CYC+IMMUTABLE);
          CHANGED_BAG(inn);
        }
        AssPlist(innk, len2 + 1, INTOBJ_INT(i));
      }
    }
  }
  return inn;
}

static Obj FuncADJACENCY_MATRIX(Obj self, Obj digraph) {
  Int   n, i, j, val, len, outj;
  Obj   adj, mat, adji, next;

  n = DigraphNrVertices(digraph);
  if (n == 0) {
    return NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE, 0);
  }
  
  adj = OutNeighbours(digraph);
  mat = NEW_PLIST(T_PLIST_TAB+IMMUTABLE, n);
  SET_LEN_PLIST(mat, n);

  for (i = 1; i <= n; i++) {
    // Set up the i^th row of the adjacency matrix
    next = NEW_PLIST(T_PLIST_CYC+IMMUTABLE, n);
    SET_LEN_PLIST(next, n);
    for (j = 1; j <= n; j++) {
      SET_ELM_PLIST(next, j, INTOBJ_INT(0));
    }
    // Fill in the correct values of the matrix
    adji = ELM_PLIST(adj, i);
    len = LEN_LIST(adji);
    for (j = 1; j <= len; j++) {
      outj = INT_INTOBJ( ELM_LIST( adji, j ) );
      val = INT_INTOBJ( ELM_PLIST(next, outj ) ) + 1;
      SET_ELM_PLIST(next, outj, INTOBJ_INT(val));
    }
    SET_ELM_PLIST(mat, i, next);
    CHANGED_BAG(mat);
  }
  SET_FILT_LIST(mat, FN_IS_RECT);
  return mat;
}

static Obj FuncIS_MULTI_DIGRAPH(Obj self, Obj digraph) {
  Obj   adj, adji;
  int   n, i, k, j, jj;
 
  adj = OutNeighbours(digraph); 
  n = DigraphNrVertices(digraph);
  for (i = 1; i <= n; i++) {
    adji = ELM_PLIST(adj, i);
    PLAIN_LIST(adji);
    for (j = 2; j <= LEN_PLIST(adji); j++) {
      jj = INT_INTOBJ(ELM_PLIST(adji, j));
      for (k = 1; k < j; k++) {
        if (INT_INTOBJ(ELM_PLIST(adji, k)) == jj) {
          return True;
        }
      }
    }
  }
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
 *      - If false, proceeds as usual Floyd-Warshall algorithm and returns
 *        a GAP object matrix as the result.
 *      - If true, FLOYD_WARSHALL stores the initialised dist, and
 *        compares it with dist after it has gone through the 3 for loops,
 *        and returns true iff it is unchanged.
 */
static Obj FLOYD_WARSHALL(Obj digraph, 
                          void (*func)(Int** dist,
                                       Int   i,
                                       Int   j,
                                       Int   k, 
                                       Int   n),
                          Int  val1, 
                          Int  val2,
                          bool copy) {
  Int   n, i, j, k, *dist, *adj;
  Obj   next, out, outi, val;

  n = DigraphNrVertices(digraph);

  if (n == 0) {
    return NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE, 0);
  }
  dist = malloc( n * n * sizeof(Int) );

  for (i = 0; i < n * n; i++) {
    dist[i] = val1;
  }

  out = OutNeighbours(digraph); 
  for (i = 1; i <= n; i++) {
    outi = ELM_PLIST(out, i);
    PLAIN_LIST(outi);
    for (j = 1; j <= LEN_PLIST(outi); j++) {
      k = (i - 1) * n + INT_INTOBJ(ELM_PLIST(outi, j)) - 1;
      dist[k] = val2;
    } 
  }

  if ( copy ) {
    // This is the special case for IS_TRANSITIVE_DIGRAPH
    adj = malloc( n * n * sizeof(Int) );
    for ( i = 0; i < n * n; i++ ) {
      adj[i] = dist[i];
    }
    // memcpy( (void*)adj, (void*)dist, n * n * sizeof(Int) );
  }
  
  for (k = 0; k < n; k++) {
    for (i = 0; i < n; i++) {
      for (j = 0; j < n; j++) {
        func(&dist, i, j, k, n);
      }
    }
  }

  if ( copy ) {
    // This is the special case for IS_TRANSITIVE_DIGRAPH
    for ( i = 0; i < n * n; i++) {
      if ( adj[ i ] != dist[ i ] ) {
        free(dist);
        free(adj);
        return False;
      }
    }
    free(dist);
    free(adj);
    return True;
  }
  
  out = NEW_PLIST(T_PLIST_TAB, n);
  SET_LEN_PLIST(out, n);

  for (i = 1; i <= n; i++) {
    next = NEW_PLIST(T_PLIST_CYC, n);
    SET_LEN_PLIST(next, n);
    for (j = 1; j <= n; j++) {
      val = INTOBJ_INT(dist[ (i - 1) * n + (j - 1) ]);
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
  if((*dist)[i * n + k] != -1 && (*dist)[k * n + j] != -1){
    if ((*dist)[i * n + j] == -1 || 
        (*dist)[i * n + j] > (*dist)[i * n + k] + (*dist)[k * n + j]) {
      (*dist)[i * n + j] = (*dist)[i * n + k] + (*dist)[k * n + j];
    }
  }
}
 
static Obj FuncDIGRAPH_SHORTEST_DIST(Obj self, Obj digraph) {
  return FLOYD_WARSHALL(digraph, FW_FUNC_SHORTEST_DIST, -1, 1, false);
}

void FW_FUNC_TRANS_CLOSURE(Int** dist, Int i, Int j, Int k, Int n) {
  if ((*dist)[i * n + k] != 0 && (*dist)[k * n + j] != 0) {
    (*dist)[i * n + j] = 1;
  }
}

static Obj FuncIS_TRANSITIVE_DIGRAPH(Obj self, Obj digraph) {
  return FLOYD_WARSHALL(digraph, FW_FUNC_TRANS_CLOSURE, 0, 1, true);
}

static Obj FuncDIGRAPH_TRANS_CLOSURE(Obj self, Obj digraph) {
  return FLOYD_WARSHALL(digraph, FW_FUNC_TRANS_CLOSURE, 0, 1, false);
}

void FW_FUNC_REFLEX_TRANS_CLOSURE(Int** dist, Int i, Int j, Int k, Int n) {
  if ((i == j) || ((*dist)[i * n + k] != 0 && (*dist)[k * n + j] != 0)) {
    (*dist)[i * n + j] = 1;
  }
}

static Obj FuncDIGRAPH_REFLEX_TRANS_CLOSURE(Obj self, Obj digraph) {
  return FLOYD_WARSHALL(digraph, FW_FUNC_REFLEX_TRANS_CLOSURE, 0, 1, false);
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
    SET_LEN_PLIST(ELM_PLIST(adj, i), 0);
    CHANGED_BAG(adj);
  }

  for (i = 1; i <= n; i++) {
    for (j = 1; j <= n; j++) {
      k = rand() % 10000;
      if (k < lim) {
        adji  = ELM_PLIST(adj, i);
        len   = LEN_PLIST(adji);
        if (len == 0) {
          RetypeBag(adji, T_PLIST_CYC);
          CHANGED_BAG(adj);
        }
        AssPlist(adji, len + 1,  INTOBJ_INT(j));
      }
    }
  }
  return adj;
}

static Obj FuncRANDOM_MULTI_DIGRAPH(Obj self, Obj nn, Obj mm) {
  UInt n, m, i, j, k;
  Int  len;
  Obj  adj, adjj;

  n = INT_INTOBJ(nn);
  m = INT_INTOBJ(mm);
  adj = NEW_PLIST(T_PLIST_TAB, n);
  SET_LEN_PLIST(adj, n);
  
  for (i = 1; i <= n; i++) {
    SET_ELM_PLIST(adj, i, NEW_PLIST(T_PLIST_EMPTY, 0));
    SET_LEN_PLIST(ELM_PLIST(adj, i), 0);
    CHANGED_BAG(adj);
  }

  for (i = 1; i <= m; i++) {
    j = (rand() % n) + 1;
    k = (rand() % n) + 1;
    adjj  = ELM_PLIST(adj, j);
    len   = LEN_PLIST(adjj);
    if (len == 0) {
      RetypeBag(adjj, T_PLIST_CYC);
      CHANGED_BAG(adj);
    }
    AssPlist(adjj, len + 1,  INTOBJ_INT(k));
  }
  return adj;
}

bool EqJumbledPlists(Obj l, Obj r, Int nr, Int *buf ) {
  bool eq;
  Int  j, jj;

  // Check first whether the lists are identical
  eq = true;
  for (j = 1; j <= nr; j++) {
    jj = INT_INTOBJ(ELM_PLIST( l, j ));
    if ( jj != INT_INTOBJ(ELM_PLIST( r, j ) ) ) {
      eq = false;
      break;
    }
  }
  
  // Otherwise check that they have equal content
  if (!eq) {

    for (j = 1; j <= nr; j++) {
      jj = INT_INTOBJ(ELM_PLIST(l, j)) - 1 ;
      buf[jj]++;
      jj = INT_INTOBJ(ELM_PLIST(r, j)) - 1;
      buf[jj]--;
    }

    for ( j = 1; j <= nr; j++ ) {
      jj = INT_INTOBJ(ELM_PLIST(l, j)) - 1;
      if (buf[jj] != 0) {
        return false;
      }
    }
 
  }
  return true;
}

static Obj FuncDIGRAPH_EQUALS(Obj self, Obj digraph1, Obj digraph2) {
  UInt  i, n1, n2, m1, m2;
  Obj   out1, out2, a, b;
  Int   nr, *buf;

  // Check NrVertices is equal
  n1 = DigraphNrVertices(digraph1);
  n2 = DigraphNrVertices(digraph2);
  if (n1 != n2) {
    return False;
  }

  // Check NrEdges is equal
  m1 = DigraphNrEdges(digraph1);
  m2 = DigraphNrEdges(digraph2);

  if ( m1 != m2 ) {
    return False;
  }

  out1 = OutNeighbours(digraph1);
  out2 = OutNeighbours(digraph2);

  buf = calloc(n1, sizeof(Int));

  // Compare OutNeighbours of each vertex in turn
  for ( i = 1; i <= n1; i++ ) {
    a = ELM_PLIST( out1, i );
    b = ELM_PLIST( out2, i );
    PLAIN_LIST(a);
    PLAIN_LIST(b);

    nr = LEN_PLIST(a);
    // Check that the OutDegrees match
    if ( nr != LEN_PLIST( b ) ) {
      free(buf);
      return False;
    }

    if (!EqJumbledPlists( a, b, nr, buf ) ) {
      free(buf);
      return False;
    }
  }
  free(buf);
  return True;
}

Int LTJumbledPlists(Obj l, Obj r, Int nr1, Int nr2, Int *buf, Int n ) {
  bool eq;
  Int  j, jj, min;

  // Check first whether the lists are identical
  if ( nr1 == nr2 ) {
    eq = true;
    for (j = 1; j <= nr1; j++) {
      jj = INT_INTOBJ(ELM_PLIST( l, j ));
      if ( jj != INT_INTOBJ(ELM_PLIST( r, j ) ) ) {
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
      jj = INT_INTOBJ(ELM_PLIST(l, j)) - 1 ;
      buf[jj]++;
      jj = INT_INTOBJ(ELM_PLIST(r, j)) - 1;
      buf[jj]--;
    }

    for (j = min + 1; j <= nr1; j++) {
      jj = INT_INTOBJ(ELM_PLIST(l, j)) - 1 ;
      buf[jj]++;
    }

    for (j = min + 1; j <= nr2; j++) {
      jj = INT_INTOBJ(ELM_PLIST(r, j)) - 1 ;
      buf[jj]--;
    }

    for ( j = 0; j < n; j++ ) {
      if (buf[j] < 0) {
        //Pr("Found difference: range: %d, number: %d\n", j + 1, buf[j]);
        return 2;
      } else if (buf[j] > 0) {
        //Pr("Found difference: range: %d, number: %d\n", j + 1, buf[j]);
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
  UInt  i, n1, n2, m1, m2;
  Obj   out1, out2, a, b;
  Int   nr1, nr2, *buf, comp, max, min;

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

  if ( m1 < m2 ) {
    return True;
  } else if ( m2 < m1 ) {
    return False;
  }

  out1 = OutNeighbours(digraph1);
  out2 = OutNeighbours(digraph2); 

  buf = calloc(n1, sizeof(Int));

  // Compare Sorted(out1[i]) and Sorted(out2[i]) for each vertex i
  for ( i = 1; i <= n1; i++ ) {
    a = ELM_PLIST( out1, i );
    b = ELM_PLIST( out2, i );
    PLAIN_LIST(a);
    PLAIN_LIST(b);

    nr1 = LEN_PLIST(a);
    nr2 = LEN_PLIST(b);
    max = nr1 < nr2 ? nr2 : nr1;

    // Check whether both vertices have 0 out-degree
    if ( max != 0 ) {
      if ( nr1 == 0 ) {
        free(buf);
        return False;
      } else if ( nr2 == 0 ) {
        free(buf);
        return True;
      }
      // Both vertices have positive out-degree

      // Compare out1[i] and out2[i]
      comp = LTJumbledPlists( a, b, nr1, nr2, buf, n1 );
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
  BlissGraph  *graph;

  n = DigraphNrVertices(digraph);
  graph = bliss_new(n);

  adj = OutNeighbours(digraph);
  for (i = 1; i <= n; i++) {
    adji = ELM_PLIST(adj, i);
    nr = LEN_PLIST(adji);
    for(j = 1; j <= nr; j++) {
      k = bliss_add_vertex(graph, 1);
      l = bliss_add_vertex(graph, 2);
      bliss_add_edge(graph, i - 1, k);
      bliss_add_edge(graph, k, l);
      bliss_add_edge(graph, l, INT_INTOBJ(ELM_PLIST(adji, j)) - 1);
    }
  }
  return graph;
}

void digraph_hook_function(void               *user_param,
	                   unsigned int       N,
	                   const unsigned int *aut        ) {
  UInt4*  ptr;
  Obj     p, gens;
  UInt    i, n;
  
  n   = INT_INTOBJ(ELM_PLIST(user_param, 1));  //the degree
  p   = NEW_PERM4(n);
  ptr = ADDR_PERM4(p);
  
  for(i = 0; i < n; i++){
    ptr[i] = aut[i];
  }
  
  gens = ELM_PLIST(user_param, 2);
  AssPlist(gens, LEN_PLIST(gens) + 1, p);
  CHANGED_BAG(user_param);
}

static Obj FuncDIGRAPH_AUTOMORPHISMS(Obj self, Obj digraph) {
  Obj                 autos, p, out, n;
  BlissGraph          *graph;
  UInt4               *ptr;
  const unsigned int  *canon;
  Int                 i, nr;
  
  graph = buildBlissMultiDigraph(digraph);
  
  autos = NEW_PLIST(T_PLIST, 2);
  n = INTOBJ_INT(DigraphNrVertices(digraph));

  SET_ELM_PLIST(autos, 1, n);
  SET_ELM_PLIST(autos, 2, NEW_PLIST(T_PLIST, 0)); // perms of the vertices
  CHANGED_BAG(autos);
  SET_LEN_PLIST(autos, 2);
  canon = bliss_find_canonical_labeling(graph, digraph_hook_function, autos, 0);
  
  p   = NEW_PERM4(INT_INTOBJ(n));
  ptr = ADDR_PERM4(p);
 
  for(i = 0; i < INT_INTOBJ(n); i++){
    ptr[i] = canon[i];
  }
  
  bliss_release(graph);

  SET_ELM_PLIST(autos, 1, p);

  if (LEN_PLIST(ELM_PLIST(autos, 2)) == 0) {
    AssPlist(ELM_PLIST(autos, 2), 1, IdentityPerm);
  } else {
    SortDensePlist(ELM_PLIST(autos, 2));
    RemoveDupsDensePlist(ELM_PLIST(autos, 2));
  }
  CHANGED_BAG(autos);

  return autos;
}

void multidigraph_hook_function(void               *user_param,
	                        unsigned           int N,
	                        const unsigned int *aut        ) {
  UInt4   *ptr;
  Obj     p, gens;
  UInt    i, n, m;
  bool    stab;
 
  m   = INT_INTOBJ(ELM_PLIST(user_param, 1));  //the nr of vertices

  stab = true;
  for (i = 0; i < m; i++) {
    if (aut[i] != i) {
      stab = false;
    }
  }
  if (stab) { // permutation of the edges
    n   = INT_INTOBJ(ELM_PLIST(user_param, 2));  //the nr of edges
    p   = NEW_PERM4(n);
    ptr = ADDR_PERM4(p);
    for (i = 0; i < n; i++) {
      ptr[i] = (aut[2 * i + m] - m) / 2;
    }
    gens = ELM_PLIST(user_param, 4);
  } else { // permutation of the vertices
    p   = NEW_PERM4(m);
    ptr = ADDR_PERM4(p);
    for (i = 0; i < m; i++) {
      ptr[i] = aut[i];
    }
    gens = ELM_PLIST(user_param, 3);
  }

  AssPlist(gens, LEN_PLIST(gens) + 1, p);
  CHANGED_BAG(user_param);
}

static Obj FuncMULTIDIGRAPH_AUTOMORPHISMS(Obj self, Obj digraph) {
  Obj                 autos, p, out;
  BlissGraph          *graph;
  UInt4               *ptr;
  const unsigned int  *canon;
  Int                 i, n;
  
  graph = buildBlissMultiDigraph(digraph);
  
  autos = NEW_PLIST(T_PLIST, 4);
  SET_ELM_PLIST(autos, 1, INTOBJ_INT(DigraphNrVertices(digraph)));
  CHANGED_BAG(autos);
  SET_ELM_PLIST(autos, 2, INTOBJ_INT(DigraphNrEdges(digraph)));
  SET_ELM_PLIST(autos, 3, NEW_PLIST(T_PLIST, 0)); // perms of the vertices
  CHANGED_BAG(autos);
  SET_ELM_PLIST(autos, 4, NEW_PLIST(T_PLIST, 0)); // perms of the edges
  CHANGED_BAG(autos);

  canon = bliss_find_canonical_labeling(graph, multidigraph_hook_function, autos, 0);
  
  n   = DigraphNrVertices(digraph);
  p   = NEW_PERM4(n);
  ptr = ADDR_PERM4(p);
 
  for(i = 0; i < n; i++){
    ptr[i] = canon[i];
  }
  
  bliss_release(graph);

  SET_ELM_PLIST(autos, 1, p); 
  
  // remove 2nd entry of autos . . .
  memmove((void *) (ADDR_OBJ(autos) + 2), //destination
          (void *) (ADDR_OBJ(autos) + 3), //source
          (size_t) 2 * sizeof(Obj));
  SET_LEN_PLIST(autos, 3);
  CHANGED_BAG(autos);

  if (LEN_PLIST(ELM_PLIST(autos, 2)) == 0) {
    AssPlist(ELM_PLIST(autos, 2), 1, IdentityPerm);
  } else {
    SortDensePlist(ELM_PLIST(autos, 2));
    RemoveDupsDensePlist(ELM_PLIST(autos, 2));
  }
  if (LEN_PLIST(ELM_PLIST(autos, 3)) == 0) {
    AssPlist(ELM_PLIST(autos, 3), 1, IdentityPerm);
  } else {
    SortDensePlist(ELM_PLIST(autos, 3));
    RemoveDupsDensePlist(ELM_PLIST(autos, 3));
  }
  CHANGED_BAG(autos);

  return autos;
}

static Obj FuncDIGRAPH_CANONICAL_LABELING(Obj self, Obj digraph) {
  Obj   p;
  UInt4 *ptr;
  BlissGraph *graph;
  Int   n, i; 
  const unsigned int *canon;
     
  graph = buildBlissMultiDigraph(digraph);
  
  canon = bliss_find_canonical_labeling(graph, 0, 0, 0); 
  
  n   = DigraphNrVertices(digraph);
  p   = NEW_PERM4(n);
  ptr = ADDR_PERM4(p);
 
  for(i = 0; i < n; i++){
      ptr[i] = canon[i];
  }
  bliss_release(graph);

  return p;
} 

static Obj FuncMULTIDIGRAPH_CANONICAL_LABELING(Obj self, Obj digraph) {
  Obj                 p, q, out;
  UInt4               *ptr;
  BlissGraph          *graph;
  Int                 m, n, i; 
  const unsigned int  *canon;
     
  graph = buildBlissMultiDigraph(digraph);
  
  canon = bliss_find_canonical_labeling(graph, 0, 0, 0); 
  
  m   = DigraphNrVertices(digraph);
  p   = NEW_PERM4(m);  // perm of vertices
  ptr = ADDR_PERM4(p);
 
  for(i = 0; i < m; i++){
    ptr[i] = canon[i];
  }
  
  n = DigraphNrEdges(digraph);
  q   = NEW_PERM4(n);  // perm of edges
  ptr = ADDR_PERM4(q);

  for (i = 0; i < n; i++ ) {
    ptr[i] = canon[2 * i + m] - m;
  }
  
  bliss_release(graph);
  
  out = NEW_PLIST(T_PLIST, 2);
  SET_ELM_PLIST(out, 1, p);
  SET_ELM_PLIST(out, 2, q);
  SET_LEN_PLIST(out, 2);
  CHANGED_BAG(out);

  return out;
}

// graph homomorphisms . . . by Max Neunhoeffer

#ifdef SYS_IS_64_BIT
#define MAXVERT 64
typedef UInt8 num;
#define SMALLINTLIMIT 1152921504606846976
#else
#define MAXVERT 32
typedef UInt4 num;
#define SMALLINTLIMIT 268435456
#endif

static num gra1[MAXVERT];
static num nrvert1;
static num gra2[MAXVERT];
static num gra2inn[MAXVERT];
static num gra2hasloops;
static num nrvert2;
static num constraints[MAXVERT];
static num maxdepth;
static Obj results;

static num tablesinitialised = 0;
static num oneone[MAXVERT];
static num ones[MAXVERT];
static num count;
static num maxresults;
static num overflow;

static jmp_buf outofhere;

static void inittabs(void)
{
    num i;
    num v = 1;
    num w = 1;
    for (i = 0;i < MAXVERT;i++) {
        oneone[i] = w;
        ones[i] = v;
        w <<= 1;
        v |= w;
    }
}

static void dowork(num *try, num depth){
    num   i, todo;
    Obj   t;
    UInt2 *pt;
    //Pr("C: at depth %d\n", (Int) depth, 0L);
    if (depth == maxdepth) {
        if (results != Fail) {
            t  = NEW_TRANS2(depth);
            pt = ADDR_TRANS2(t);
            for (i = 0; i < depth; i++) {
              pt[i] = (UInt2) try[i];
            }
            Pr("found endomorphism of rank %d\n", (Int) RANK_TRANS2(t), 0L); 
            if (IS_PLIST(results)) {
                ASS_LIST(results,LEN_PLIST(results)+1, t);
            } /*else {
                CALL_1ARGS(results,tmp);
            }*/
        }
        count++;
        if (count >= maxresults) {
            if (count >= SMALLINTLIMIT) overflow = 1;
            longjmp(outofhere,1);
        }
        return;
    }
    todo = constraints[depth];
    for (i = 0;i < depth;i++) {
        if (gra1[i] & oneone[depth]){    /* if depth adjacent to try[i] */
            todo &= gra2[try[i]];        /* Only these images are possible */
        }
	if (gra1[depth] & oneone[i]) {
           todo &= gra2inn[try[i]];
        }
    }
    if (gra1[depth] & oneone[depth]) {   /* if depth has a loop in gra1 */
       todo &= gra2hasloops;
    } 
    if (todo == 0 ) return;
    for (i = 0;i < nrvert2 && todo;i++, todo >>= 1) {
        if (todo & 1) {
            try[depth] = i;
            dowork(try,depth+1);
        }
    }
}

static void doworkinj(num *try, num depth, num used)
{
    num i, todo;
    Obj tmp;
    if (depth == maxdepth) {
        if (results != Fail) {
            tmp = NEW_PLIST(T_PLIST_CYC,depth);
            SET_LEN_PLIST(tmp,depth);
            for (i = 0; i < depth; i++) {
                SET_ELM_PLIST(tmp,i+1,INTOBJ_INT((Int) (try[i]+1)));
            }
            ASS_LIST(results,LEN_PLIST(results)+1,tmp);
        }
        count++;
        if (count >= maxresults) {
            if (count >= SMALLINTLIMIT) overflow = 1;
            longjmp(outofhere,1);
        }
        return;
    }
    todo = constraints[depth] & ~(used);
    for (i = 0;i < depth;i++) {
        if (gra1[i] & oneone[depth]) {   /* if depth adjacent to try[i] */
            todo &= gra2[try[i]];    /* Only these images are possible */
            if (todo == 0) return;
        }
    }
    for (i = 0;i < nrvert2 && todo;i++, todo >>= 1) {
        if (todo & 1) {
            try[depth] = i;
            doworkinj(try,depth+1,used | oneone[i]);
        }
    }
}

Obj FuncGRAPH_HOMOMORPHISMS( Obj self, Obj args )
{
    Obj gra1obj = ELM_PLIST(args,1); 
    Obj gra2obj = ELM_PLIST(args,2);
    Obj tryinit = ELM_PLIST(args,3);
    Obj mymaxdepth = ELM_PLIST(args,4);
    Obj constraintsobj = ELM_PLIST(args,5);
    Obj maxanswers = ELM_PLIST(args,6);
    Obj myresult = ELM_PLIST(args,7);
    Obj onlyinj = ELM_PLIST(args,8);
    num try[MAXVERT];
    num used;
    num depth;
    num i,j,k,up;
    Obj tmp;

    if (!tablesinitialised) inittabs();
    count = 0;
    overflow = 0;
    if (maxanswers == Fail || !IS_INTOBJ(maxanswers))
        maxresults = SMALLINTLIMIT;
    else
        maxresults = (num) INT_INTOBJ(maxanswers);
    /* now fill our data structures: */
    memset(gra1,0,sizeof(num)*MAXVERT);
    memset(gra2,0,sizeof(num)*MAXVERT);
    memset(gra2inn,0,sizeof(num)*MAXVERT);
    gra2hasloops = (num) 0;
    nrvert1 = LEN_PLIST(gra1obj);
    nrvert2 = LEN_PLIST(gra2obj);
    for (i = 0; i < MAXVERT; i++) constraints[i] = ones[nrvert2-1];
    up = (num) LEN_PLIST(gra1obj);
    for (i = 0; i < up; i++) {
        tmp = ELM_PLIST(gra1obj,(Int) i+1);
        for (j = 0; j < (num) LEN_PLIST(tmp); j++) {
            k = (num) INT_INTOBJ(ELM_PLIST(tmp,(Int) j + 1)) - 1;
            gra1[i] |= oneone[k];
            //gra1[k] |= oneone[i];
        }
    }
    up = (num) LEN_PLIST(gra2obj);
    for (i = 0; i < up; i++) {
        tmp = ELM_PLIST(gra2obj,(Int) i+1);
        for (j = 0; j < (num) LEN_PLIST(tmp); j++) {
            k = (num) INT_INTOBJ(ELM_PLIST(tmp,(Int) j + 1)) - 1;
            gra2[i] |= oneone[k];
            gra2inn[k] |= oneone[i];
	    if (i == k) {
	      gra2hasloops |= oneone[k];
	    }
        }
    }
    if (constraintsobj != Fail) {
        up = (num) LEN_PLIST(constraintsobj);
        for (i = 0; i < up; i++) {
            tmp = ELM_PLIST(constraintsobj,(Int) i + 1);
            if (tmp && tmp != Fail) {
                constraints[i] = 0;
                for (j = 0; j < (num) LEN_PLIST(tmp); j++) {
                    k = (num) INT_INTOBJ(ELM_PLIST(tmp,(Int) j + 1)) - 1;
                    constraints[i] |= oneone[k];
                }
            }
        }
    }
    depth = (num) LEN_PLIST(tryinit);
    used = 0;
    for (i = 0; i < depth; i++) {
        try[i] = (num) INT_INTOBJ(ELM_PLIST(tryinit,(Int) i + 1)) - 1;
        used |= oneone[try[i]];
    }
    maxdepth = (num) INT_INTOBJ(mymaxdepth);
    results = myresult;
    if (setjmp(outofhere) == 0) {
        if (onlyinj == True) {
            doworkinj(try,depth,used);
        } else {
            dowork(try,depth);
        }
    }
    if (overflow) return Fail;
    else return INTOBJ_INT(count);
}

Obj FuncORBIT_REPS_PERMS (Obj self, Obj gens, Obj D) {
  Int   nrgens, i, j, max, fst, m, img, n;
  Obj   reps, gen;
  UInt2 *ptr2;
  UInt4 *ptr4;

  nrgens = LEN_PLIST(gens);
  max = 0;
  for (i = 1; i <= nrgens; i++) {
    gen = ELM_PLIST(gens, i);
    if (TNUM_OBJ(gen) == T_PERM2) {
      j = DEG_PERM2(gen);
      ptr2 = ADDR_PERM2(gen);
      while (j > max && ptr2[j - 1] == j - 1){
        j--;
      }
      if (j > max) {
        max = j;
      }
    } else if (TNUM_OBJ(gen) == T_PERM4) {
      j = DEG_PERM4(gen);
      ptr4 = ADDR_PERM4(gen);
      while (j > max && ptr4[j - 1] == j - 1){
        j--;
      }
      if (j > max) {
        max = j;
      }
    } else {
      ErrorQuit("expected a perm, didn't get one", 0L, 0L);
    }
  }
  
  int  dom1[max]; // = calloc(max, sizeof(int));
  int  dom2[max]; // = calloc(max, sizeof(int));
  UInt orb[max]; // malloc(max * sizeof(int));

  memset(dom1, 0, max * sizeof(int)); 
  memset(dom2, 0, max * sizeof(int)); 

  reps = NEW_PLIST(T_PLIST_CYC, 0);
  SET_LEN_PLIST(reps, 0);
  m = 0; //number of orbit reps

  PLAIN_LIST(D);
  for (i = 1; i <= LEN_PLIST(D); i++) {
    j = INT_INTOBJ(ELM_PLIST(D, i));
    if (j <= max) {
      dom1[j - 1] = 1;
    } else {
      AssPlist(reps, ++m, INTOBJ_INT(j));
    }
  }      

  fst = 0; 
  while (dom1[fst] != 1 && fst < max) fst++;

  while (fst < max) {
    AssPlist(reps, ++m, INTOBJ_INT(fst + 1));
    orb[0] = fst;
    n = 1; //length of orb
    dom2[fst] = 1;
    dom1[fst] = 0;

    for (i = 0; i < n; i++) {
      for (j = 1; j <= nrgens; j++) {
        gen = ELM_PLIST(gens, j);
        if (TNUM_OBJ(gen) == T_PERM2){
          img = IMAGE(orb[i], ADDR_PERM2(gen), DEG_PERM2(gen));
        } else {
          img = IMAGE(orb[i], ADDR_PERM4(gen), DEG_PERM4(gen));
        }
        //Pr("img = %d\n", (Int) img, 0L);
        if (dom2[img] == 0) {
          
          orb[n++] = img;
          dom2[img] = 1;
          dom1[img] = 0;
        }
      }
    }
    while (dom1[fst] != 1 && fst < max) fst++; 
  }
  //free(dom1);
  //free(dom2);
  //free(orb);
  return reps;
}

// vals is a blist corresponding to the complement of the domain we are acting
// on. 

void OrbitReps (Obj gens, int* vals, int sizeVals, int* reps) {
  Int    nrgens, i, j, max, fst, m, img, n;
  Obj    gen;
  UInt2  *ptr2;
  UInt4  *ptr4;

  nrgens = LEN_PLIST(gens);
  max = 0;
  for (i = 1; i <= nrgens; i++) {
    gen = ELM_PLIST(gens, i);
    if (TNUM_OBJ(gen) == T_PERM2) {
      j = DEG_PERM2(gen);
      ptr2 = ADDR_PERM2(gen);
      while (j > max && ptr2[j - 1] == j - 1){
        j--;
      }
      if (j > max) {
        max = j;
      }
    } else if (TNUM_OBJ(gen) == T_PERM4) {
      j = DEG_PERM4(gen);
      ptr4 = ADDR_PERM4(gen);
      while (j > max && ptr4[j - 1] == j - 1){
        j--;
      }
      if (j > max) {
        max = j;
      }
    } else {
      ErrorQuit("expected a perm, didn't get one", 0L, 0L);
    }
  }
  // special case in case there are no gens, or just the identity.

  int dom1[max]; 
  int dom2[max];
  UInt orb[max];

  memset(dom1, 0, max * sizeof(int)); 
  memset(dom2, 0, max * sizeof(int)); 
  
  m = 0; //number of orbit reps

  for (i = 0; i < sizeVals; i++) {
    if (! vals[i]) {
      if (i <= max) {
        dom1[i] = 1;
      } else {
        reps[i] = 1;
      }
    }      
  }

  fst = 0; 
  while (dom1[fst] != 1 && fst < max) fst++;

  while (fst < max) {
    reps[fst] = 1;
    orb[0] = fst;
    n = 1; //length of orb
    dom2[fst] = 1;
    dom1[fst] = 0;

    for (i = 0; i < n; i++) {
      for (j = 1; j <= nrgens; j++) {
        gen = ELM_PLIST(gens, j);
        if (TNUM_OBJ(gen) == T_PERM2){
          img = IMAGE(orb[i], ADDR_PERM2(gen), DEG_PERM2(gen));
        } else {
          img = IMAGE(orb[i], ADDR_PERM4(gen), DEG_PERM4(gen));
        }
        if (dom2[img] == 0) {
          orb[n++] = img;
          dom2[img] = 1;
          dom1[img] = 0;
        }
      }
    }
    while (dom1[fst] != 1 && fst < max) fst++; 
  }
}

void SEARCH_ENDOS (Obj   map,          // a transformation 2
                   int  *vals,        // blist for values in map
                   int   nr,           // nr of vertices
                   int   rank,         // nr distinct vals in map 
                   int  *condition, 
                   int  *neighbours, 
                   Obj   gens, 
                   int   depth, 
                   void (*hook)(Obj map,
                                void *user_param),  
                   void  *user_param, 
                   Obj   Stabilizer) {
  UInt2 *ptr;
  int   i, j, k, l;
  int  *copy;
  bool isEmpty;
  
  if (depth == nr) {
    hook(map, user_param);
    return;
  }

  copy = malloc((nr * nr) * sizeof(int));
  memcpy((void *) copy, 
         (void *) condition, 
         (size_t) (nr * nr) * sizeof(int));
  
  ptr = ADDR_TRANS2(map);
  if (depth != 0) {
    for (j = depth; j < nr; j++){
      if (neighbours[nr * (depth - 1) + j] != 0) {
        isEmpty = true;
        for (k = 0; k < nr; k++) {
          copy[nr * j + k] *= neighbours[nr * ptr[depth - 1] + k];
          if (copy[nr * j + k] == 1) {
            isEmpty = false;
          }
        }
        if (isEmpty) {
          free(copy);
          return;
        }
      }
    }
  }

  // blist of orbit reps of things not in vals
  int reps[nr];
  memset(reps, 0, sizeof(int) * nr);
  OrbitReps(gens, vals, nr, reps);
  
  //find smallest list here!
  for (i = 0; i < nr; i++) {
    if (vals[i] == 0) {
      for (j = 0; j < nr; j++) {
        if (copy
  
  
  for (i = 0; i < nr; i++) {
    if (copy[nr * depth + i] && reps[i] == 1) {
      (ADDR_TRANS2(map))[depth] = i;
      vals[i] = 1;
      SEARCH_ENDOS(map, vals, nr, rank + 1, copy, neighbours,
          CALL_2ARGS(Stabilizer, gens, INTOBJ_INT(i + 1)), 
          depth + 1, hook, user_param, Stabilizer);
      vals[i] = 0;
    }
  }
  for (i = 0; i < nr; i++) {
    if (copy[nr * depth + i] && vals[i] == 1) {
      (ADDR_TRANS2(map))[depth] = i;
      // could pass reps here!
      SEARCH_ENDOS(map, vals, nr, rank, copy, neighbours, gens, depth + 1, hook,
          user_param, Stabilizer);
    }
  }
  free(copy);
  return;
}

UInt2 TransVal (Obj t, int i) {
  return ADDR_TRANS2(t)[i];
}

void endo_hook_function(Obj map, 
                        void *user_param) {
  UInt2   *ptr1, *ptr2;
  Obj     t;
  UInt    i, n;

  // copy map into new trans2 
  n    = DEG_TRANS2(map);  
  ptr1 = ADDR_TRANS2(map);
  t    = NEW_TRANS2(n);
  ptr2  = ADDR_TRANS2(t);
  
  for(i = 0; i < n; i++){
    ptr2[i] = ptr1[i];
  }
   
  AssPlist(user_param, LEN_PLIST(user_param) + 1, t);
  CHANGED_BAG(user_param);
  Pr("found %d endomorphism so far\n", (Int) LEN_PLIST(user_param), 0L);
}

Obj FuncGRAPH_ENDOS (Obj self, Obj graph, Obj gens, Obj Stabilizer) {
  Obj   user_param, map, nbs, nbsi;
  int   nr, i, j, k;
  int  *condition, *neighbours;

  user_param = NEW_PLIST(T_PLIST, 0);
  SET_LEN_PLIST(user_param, 0);
  nr = DigraphNrVertices(graph);
  map = NEW_TRANS2(nr);
  int vals[nr];

  for (i = 0; i < nr; i++) {
    vals[i] = 0;
  }

  condition  = malloc((nr * nr) * sizeof(int));
  neighbours = calloc((nr * nr),  sizeof(int));
  
  for (i = 0; i < (nr * nr); i++) {
    condition[i] = 1;
  }

  nbs = OutNeighbours(graph);
  
  for (i = 0; i < nr; i++) {
    nbsi = ELM_PLIST(nbs, i + 1);
    for (j = 0; j < LEN_LIST(nbsi); j++) {
      k = INT_INTOBJ(ELM_LIST(nbsi, j + 1)) - 1;
      neighbours[nr * i + k] = 1;
    }
  }

  SEARCH_ENDOS(map, vals, nr, 0, condition, neighbours, gens, 
        0, endo_hook_function, user_param, Stabilizer);

  free(condition);
  free(neighbours);
  return user_param;
}

/*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * */

/******************************************************************************
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/

static StructGVarFunc GVarFuncs [] = {

  { "DIGRAPH_NREDGES", 1, "digraph",
    FuncDIGRAPH_NREDGES, 
    "src/digraphs.c:DIGRAPH_NREDGES" },
  
  { "GABOW_SCC", 1, "adj",
    FuncGABOW_SCC, 
    "src/digraphs.c:GABOW_SCC" },

  { "DIGRAPH_CONNECTED_COMPONENTS", 1, "digraph",
    FuncDIGRAPH_CONNECTED_COMPONENTS,
    "src/digraphs.c:DIGRAPH_CONNECTED_COMPONENTS" },

  { "IS_ACYCLIC_DIGRAPH", 1, "adj",
    FuncIS_ACYCLIC_DIGRAPH, 
    "src/digraphs.c:FuncIS_ACYCLIC_DIGRAPH" },
 
  { "IS_ANTISYMMETRIC_DIGRAPH", 1, "adj",
    FuncIS_ANTISYMMETRIC_DIGRAPH, 
    "src/digraphs.c:FuncIS_ANTISYMMETRIC_DIGRAPH" },
 
  { "IS_STRONGLY_CONNECTED_DIGRAPH", 1, "adj",
    FuncIS_STRONGLY_CONNECTED_DIGRAPH, 
    "src/digraphs.c:FuncIS_STRONGLY_CONNECTED_DIGRAPH" },

  { "DIGRAPH_TOPO_SORT", 1, "adj",
    FuncDIGRAPH_TOPO_SORT, 
    "src/digraphs.c:FuncDIGRAPH_TOPO_SORT" },

  { "DIGRAPH_SOURCE_RANGE", 1, "digraph",
    FuncDIGRAPH_SOURCE_RANGE, 
    "src/digraphs.c:FuncDIGRAPH_SOURCE_RANGE" },

  { "DIGRAPH_OUT_NBS", 3, "nrvertices, source, range",
    FuncDIGRAPH_OUT_NBS, 
    "src/digraphs.c:FuncDIGRAPH_OUT_NBS" },
  
  { "DIGRAPH_IN_OUT_NBS", 1, "adj",
    FuncDIGRAPH_IN_OUT_NBS, 
    "src/digraphs.c:FuncDIGRAPH_IN_OUT_NBS" },

  { "ADJACENCY_MATRIX", 1, "digraph",
    FuncADJACENCY_MATRIX, 
    "src/digraphs.c:FuncADJACENCY_MATRIX" },

  { "IS_MULTI_DIGRAPH", 1, "digraph",
    FuncIS_MULTI_DIGRAPH, 
    "src/digraphs.c:FuncIS_MULTI_DIGRAPH" },

  { "DIGRAPH_SHORTEST_DIST", 1, "digraph",
    FuncDIGRAPH_SHORTEST_DIST, 
    "src/digraphs.c:FuncDIGRAPH_SHORTEST_DIST" },

  { "IS_TRANSITIVE_DIGRAPH", 1, "digraph",
    FuncIS_TRANSITIVE_DIGRAPH,
    "src/digraphs.c:FuncIS_TRANSITIVE_DIGRAPH" },
  
  { "DIGRAPH_TRANS_CLOSURE", 1, "digraph",
    FuncDIGRAPH_TRANS_CLOSURE,
    "src/digraphs.c:FuncDIGRAPH_TRANS_CLOSURE" },

  { "DIGRAPH_REFLEX_TRANS_CLOSURE", 1, "digraph",
    FuncDIGRAPH_REFLEX_TRANS_CLOSURE,
    "src/digraphs.c:FuncDIGRAPH_REFLEX_TRANS_CLOSURE" },

  { "RANDOM_DIGRAPH", 2, "nn, limm",
    FuncRANDOM_DIGRAPH,
    "src/digraphs.c:FuncRANDOM_DIGRAPH" },
 
  { "RANDOM_MULTI_DIGRAPH", 2, "nn, mm",
    FuncRANDOM_MULTI_DIGRAPH,
    "src/digraphs.c:FuncRANDOM_MULTI_DIGRAPH" },

  { "DIGRAPH_EQUALS", 2, "digraph1, digraph2",
    FuncDIGRAPH_EQUALS,
    "src/digraphs.c:FuncDIGRAPH_EQUALS" },
  
  { "DIGRAPH_LT", 2, "digraph1, digraph2",
    FuncDIGRAPH_LT,
    "src/digraphs.c:FuncDIGRAPH_LT" },

  { "DIGRAPHS_IS_REACHABLE", 3, "digraph, u, v",
    FuncDIGRAPHS_IS_REACHABLE,
    "src/digraphs.c:FuncDIGRAPHS_IS_REACHABLE" },

  { "DIGRAPH_AUTOMORPHISMS", 1, "digraph",
    FuncDIGRAPH_AUTOMORPHISMS, 
    "src/digraphs.c:FuncDIGRAPH_AUTOMORPHISMS" },
 
  { "MULTIDIGRAPH_AUTOMORPHISMS", 1, "digraph",
    FuncMULTIDIGRAPH_AUTOMORPHISMS, 
    "src/digraphs.c:FuncMULTIDIGRAPH_AUTOMORPHISMS" },

  { "DIGRAPH_CANONICAL_LABELING", 1, "digraph",
    FuncDIGRAPH_CANONICAL_LABELING, 
    "src/digraphs.c:FuncDIGRAPH_CANONICAL_LABELING" },
  
  { "MULTIDIGRAPH_CANONICAL_LABELING", 1, "digraph",
    FuncMULTIDIGRAPH_CANONICAL_LABELING, 
    "src/digraphs.c:FuncMULTIDIGRAPH_CANONICAL_LABELING" },

  { "GRAPH_HOMOMORPHISMS", 8, 
    "gra1obj, gra2obj, tryinit, maxdepth, constraintsobj, maxanswers, result, onlyinjective",
    FuncGRAPH_HOMOMORPHISMS,
    "grahom.c:FuncGRAPH_HOMOMORPHISMS" },
  
  { "ORBIT_REPS_PERMS", 2, "gens, D",
    FuncORBIT_REPS_PERMS,
    "src/digraphs.c:FuncORBIT_REPS_PERMS" },

  { "GRAPH_ENDOS", 3, "graph, gens, Stabilizer",
    FuncGRAPH_ENDOS,
    "src/digraphs.c:FuncGRAPH_ENDOS" },

  { 0 }

};

/******************************************************************************
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel ( StructInitInfo *module )
{
    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}

/******************************************************************************
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary ( StructInitInfo *module )
{
    Int             i, gvar;
    Obj             tmp;

    /* init filters and functions */
    for ( i = 0;  GVarFuncs[i].name != 0;  i++ ) {
      gvar = GVarName(GVarFuncs[i].name);
      AssGVar(gvar,NewFunctionC( GVarFuncs[i].name, GVarFuncs[i].nargs,
                                 GVarFuncs[i].args, GVarFuncs[i].handler ) );
      MakeReadOnlyGVar(gvar);
    }

    tmp = NEW_PREC(0);
    gvar = GVarName("DIGRAPHS_C"); 
    AssGVar( gvar, tmp ); 
    MakeReadOnlyGVar(gvar);

    /* return success                                                      */
    return 0;
}

/******************************************************************************
*F  InitInfopl()  . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
#ifdef DIGRAPHSSTATIC
 /* type        = */ MODULE_STATIC,
#else
 /* type        = */ MODULE_DYNAMIC,
#endif
 /* name        = */ "digraphs",
 /* revision_c  = */ 0,
 /* revision_h  = */ 0,
 /* version     = */ 0,
 /* crc         = */ 0,
 /* initKernel  = */ InitKernel,
 /* initLibrary = */ InitLibrary,
 /* checkInit   = */ 0,
 /* preSave     = */ 0,
 /* postSave    = */ 0,
 /* postRestore = */ 0
};

#ifndef DIGRAPHSSTATIC
StructInitInfo * Init__Dynamic ( void )
{
  return &module;
}
#endif

StructInitInfo * Init__digraphs ( void )
{
  return &module;
}

/*
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; version 2 of the License.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */


