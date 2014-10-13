/***************************************************************************
**
*A  grahom.c                                     
**                                                        by Max Neunhoeffer
**
**  Copyright (C) 2010  Max Neunhoeffer
**  This file is free software, see license information at the end.
**  
*/

const char * Revision_grahom_c =
   "$Id: grahom.c,v$";

#include "src/compiled.h"          /* GAP headers                */

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

static void dowork(num *try, num depth)
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
            if (IS_PLIST(results)) {
                ASS_LIST(results,LEN_PLIST(results)+1,tmp);
            } else {
                CALL_1ARGS(results,tmp);
            }
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
        if (gra1[i] & oneone[depth]) {   /* if depth adjacent to try[i] */
            todo &= gra2[try[i]];    /* Only these images are possible */
            if (todo == 0) return;
        }
    }
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
    nrvert1 = LEN_PLIST(gra1obj);
    nrvert2 = LEN_PLIST(gra2obj);
    for (i = 0; i < MAXVERT; i++) constraints[i] = ones[nrvert2-1];
    up = (num) LEN_PLIST(gra1obj);
    for (i = 0; i < up; i++) {
        tmp = ELM_PLIST(gra1obj,(Int) i+1);
        for (j = 0; j < (num) LEN_PLIST(tmp); j++) {
            k = (num) INT_INTOBJ(ELM_PLIST(tmp,(Int) j + 1)) - 1;
            gra1[i] |= oneone[k];
            gra1[k] |= oneone[i];
        }
    }
    up = (num) LEN_PLIST(gra2obj);
    for (i = 0; i < up; i++) {
        tmp = ELM_PLIST(gra2obj,(Int) i+1);
        for (j = 0; j < (num) LEN_PLIST(tmp); j++) {
            k = (num) INT_INTOBJ(ELM_PLIST(tmp,(Int) j + 1)) - 1;
            gra2[i] |= oneone[k];
            gra2[k] |= oneone[i];
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

/*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * */

/******************************************************************************
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

  { "GRAPH_HOMOMORPHISMS", 8, 
    "gra1obj, gra2obj, tryinit, maxdepth, constraintsobj, maxanswers, result, onlyinjective",
    FuncGRAPH_HOMOMORPHISMS,
    "grahom.c:FuncGRAPH_HOMOMORPHISMS" },

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

    /* init filters and functions */
    for ( i = 0;  GVarFuncs[i].name != 0;  i++ ) {
      gvar = GVarName(GVarFuncs[i].name);
      AssGVar(gvar,NewFunctionC( GVarFuncs[i].name, GVarFuncs[i].nargs,
                                 GVarFuncs[i].args, GVarFuncs[i].handler ) );
      MakeReadOnlyGVar(gvar);
    }

    /* return success                                                      */
    return 0;
}

/******************************************************************************
*F  InitInfopl()  . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
#ifdef GRAHOMSTATIC
 /* type        = */ MODULE_STATIC,
#else
 /* type        = */ MODULE_DYNAMIC,
#endif
 /* name        = */ "grahom",
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

#ifndef GRAHOMSTATIC
StructInitInfo * Init__Dynamic ( void )
{
  module.revision_c = Revision_grahom_c;
  return &module;
}
#endif

StructInitInfo * Init__grahom ( void )
{
  module.revision_c = Revision_grahom_c;
  return &module;
}

/*
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; version 3 of the License.
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



