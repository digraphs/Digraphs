//
// Digraphs package for GAP
// Copyright (C) 2017 James D. Mitchell
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// For debugging access to GAP macros

#ifndef DIGRAPHS_SRC_GAP_DEBUG_H_
#define DIGRAPHS_SRC_GAP_DEBUG_H_

#include "src/compiled.h"

Bag* ADDR_OBJ_F(Obj x) {
  return ADDR_OBJ(x);
}

UInt SIZE_OBJ_F(Obj x) {
  return SIZE_OBJ(x);
}

Bag TYPE_COMOBJ_F(Obj x) {
  return TYPE_COMOBJ(x);
}

Bag TYPE_POSOBJ_F(Obj x) {
  return TYPE_POSOBJ(x);
}

uint64_t TNUM_OBJ_F(Obj x) {
  return TNUM_OBJ(x);
}

const char* TNAM_OBJ_F(Obj x) {
  return TNAM_OBJ(x);
}

uint64_t T_PLIST_F(Obj x) {
  return T_PLIST;
}

bool IS_PLIST_F(Obj x) {
  return IS_PLIST(x);
}

Int LEN_PLIST_F(Obj x) {
  return LEN_PLIST(x);
}

bool IS_LIST_F(Obj x) {
  return IS_LIST(x);
}

Int LEN_LIST_F(Obj x) {
  return LEN_LIST(x);
}

bool IS_COMOBJ_F(Obj x) {
  return IS_COMOBJ(x);
}

size_t LEN_BLIST_F(Obj blist) {
  return LEN_BLIST(blist);
}

bool IS_BLIST_REP_F(Obj blist) {
  return IS_BLIST_REP(blist);
}

Obj ELM_PLIST_F(Obj plist, size_t pos) {
  return ELM_PLIST(plist, pos);
}

size_t INT_INTOBJ_F(Obj int_obj) {
  return INT_INTOBJ(int_obj);
}

Obj INTOBJ_INT_F(UInt i) {
  return INTOBJ_INT(i);
}

bool IsbPRec_F(Obj rec, UInt rnam) {
  return IsbPRec(rec, rnam);
}

bool IS_PREC_REP_F(Obj o) {
  return IS_PREC_REP(o);
}

size_t LEN_PREC_F(Obj o) {
  return LEN_PREC(o);
}

Obj CALL_1ARGS_F(Obj func, Obj arg1) {
  return CALL_1ARGS(func, arg1);
}

Obj CALL_2ARGS_F(Obj func, Obj arg1, Obj arg2) {
  return CALL_2ARGS(func, arg1, arg2);
}

size_t DEG_TRANS_F(Obj t) {
  return DEG_TRANS(t);
}

size_t DEG_PERM4_F(Obj t) {
  return DEG_PERM4(t);
}

#endif  // DIGRAPHS_SRC_GAP_DEBUG_H_
