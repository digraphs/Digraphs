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

#include "src/compiled.h"          /* GAP headers                */

#undef PACKAGE
#undef PACKAGE_BUGREPORT
#undef PACKAGE_NAME
#undef PACKAGE_STRING
#undef PACKAGE_TARNAME
#undef PACKAGE_URL
#undef PACKAGE_VERSION

//#include "pkgconfig.h"             /* our own configure results */

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
  out = NEW_PLIST(T_PLIST_CYC, nr);
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

static Obj FuncDIGRAPH_OUT_NBS(Obj self, Obj digraph) { 
  Obj   range, source, adj, adjj;
  UInt  n, i, j, len;
  
  
  n = INT_INTOBJ(ElmPRec(digraph, RNamName("nrvertices")));

  if (n == 0) {
    return NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE, 0);
  }
  
  range = ElmPRec(digraph, RNamName("range")); 
  PLAIN_LIST(range);
  source = ElmPRec(digraph, RNamName("source"));
  PLAIN_LIST(source);

  adj = NEW_PLIST(T_PLIST_TAB+IMMUTABLE, n);
  SET_LEN_PLIST(adj, n);
  
  // fill adj with empty plists 
  for (i = 1; i <= n; i++) {
    SET_ELM_PLIST(adj, i, NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE, 0));
    SET_LEN_PLIST(ELM_PLIST(adj, i), 0);
    CHANGED_BAG(adj);
  }
  
  n = LEN_PLIST(source);
  for (i = 1; i <= n; i++) {
    j = INT_INTOBJ(ELM_PLIST(source, i));
    adjj = ELM_PLIST(adj, j);
    len = LEN_PLIST(adjj); 
    if(len == 0){
      RetypeBag(adjj, T_PLIST_CYC+IMMUTABLE);
      CHANGED_BAG(adj);
    }
    AssPlist(adjj, len + 1,  ELM_PLIST(range, i));
  }
  AssPRec(digraph, RNamName("adj"), adj);
  return adj;
}

static Obj FuncIS_MULTI_DIGRAPH(Obj self, Obj digraph) {
  Obj   range, adj, source, adji;
  UInt  nam;
  int   n, i, k, *marked, current, j, jj;
 
  nam = RNamName("source");
  if (IsbPRec(digraph, nam)) {
    source = ElmPRec(digraph, nam);
    PLAIN_LIST(source);
  
    if (LEN_PLIST(source) == 0) {
      return False;
    }
    
    range = ElmPRec(digraph, RNamName("range"));
    PLAIN_LIST(range);
    n = INT_INTOBJ(ElmPRec(digraph, RNamName("nrvertices"))); 

    current = INT_INTOBJ(ELM_PLIST(source, 1));
    marked = calloc(n + 1, sizeof(UInt));
    marked[INT_INTOBJ(ELM_PLIST(range, 1))] = current;
    
    for (i = 2; i <= LEN_PLIST(source); i++) {
      j = INT_INTOBJ(ELM_PLIST(source, i));
      if (j != current) {
        current = j;
        marked[INT_INTOBJ(ELM_PLIST(range, i))] = j;
      } else {
        k = INT_INTOBJ(ELM_PLIST(range, i));
        if(marked[k] == current){
          free(marked);
          return True;
        } else {
          marked[k] = j;
        }
      }
    }
     
    free(marked);
    return False;
  } else {
    adj = ElmPRec(digraph, RNamName("adj"));
    n = INT_INTOBJ(ElmPRec(digraph, RNamName("nrvertices"))); 
    for (i = 1; i <= n; i++) {
      adji = ELM_PLIST(adj, i);
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
} 

// bliss 

void hook_function(void *user_param,
	      unsigned int N,
	      const unsigned int *aut) {
   UInt4* pt;
   Obj prod;
   
   prod = NEW_PERM4(N);
   pt = ADDR_PERM4(prod);
   
   for(UInt i = 0; i < N; ++i)
       pt[i] = aut[i];
   
   AssPlist(user_param, LEN_PLIST(user_param)+1, prod);
   CHANGED_BAG(user_param);
 }

BlissGraph* buildGraph(Obj digraph) {
    UInt n, nam, i, j, nr, len;
    Obj adji, adj;
    BlissGraph *graph;
  
    n = INT_INTOBJ(ElmPRec(digraph, RNamName("nrvertices")));
  
    graph = bliss_new(n);
  
    nam = RNamName("adj");
    adj = ElmPRec(digraph, nam);
    len = LEN_PLIST(adj);
    nr = 0;
    for (i = 1; i <= len; i++) {
        nr = LEN_PLIST(ELM_PLIST(adj, i));
        adji = ELM_PLIST(adj, i);
        for(j = 1; j <= nr; j++) {
            bliss_add_edge(graph, i-1, INT_INTOBJ(ELM_PLIST(adji, j))-1);
        }
    }
    
    return graph;
}

static Obj FuncGRAPH_AUTOMORPHISM(Obj self, Obj digraph) {
  Obj   automorphs;
  BlissGraph *graph;
  
  graph = buildGraph(digraph);
  
  automorphs = NEW_PLIST(T_PLIST, 0);
  SET_LEN_PLIST(automorphs, 0);
  
  bliss_find_automorphisms(graph,hook_function,automorphs,0);
  bliss_release(graph);
  
  return automorphs;
} 

/*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * */

/******************************************************************************
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/

static StructGVarFunc GVarFuncs [] = {

  { "GABOW_SCC", 1, "adj",
    FuncGABOW_SCC, 
    "src/digraphs.c:GABOW_SCC" },

  { "IS_ACYCLIC_DIGRAPH", 1, "adj",
    FuncIS_ACYCLIC_DIGRAPH, 
    "src/digraphs.c:FuncIS_ACYCLIC_DIGRAPH" },
  
  { "IS_STRONGLY_CONNECTED_DIGRAPH", 1, "adj",
    FuncIS_STRONGLY_CONNECTED_DIGRAPH, 
    "src/digraphs.c:FuncIS_STRONGLY_CONNECTED_DIGRAPH" },

  { "DIGRAPH_TOPO_SORT", 1, "adj",
    FuncDIGRAPH_TOPO_SORT, 
    "src/digraphs.c:FuncDIGRAPH_TOPO_SORT" },

  { "DIGRAPH_OUT_NBS", 1, "digraph",
    FuncDIGRAPH_OUT_NBS, 
    "src/digraphs.c:FuncDIGRAPH_OUT_NBS" },

  { "IS_MULTI_DIGRAPH", 1, "digraph",
    FuncIS_MULTI_DIGRAPH, 
    "src/digraphs.c:FuncIS_MULTI_DIGRAPH" },
  
  { "GRAPH_AUTOMORPHISM", 1, "digraph",
    FuncGRAPH_AUTOMORPHISM, 
    "src/digraphs.c:FuncGRAPH_AUTOMORPHISM" },
      
 
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


