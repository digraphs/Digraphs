/*******************************************************************************
**
*A  schreier-sims.h        A rudimentary Schreier-Sims        Julius Jonusas
**                                                            James Mitchell
**                                                            Wilf A. Wilson
**                                                            Michael Young
**
**  Copyright (C) 2014-15 - Julius Jonusas, James Mitchell, Wilf A. Wilson,
**  Michael Young
**
**  This file is free software, see the digraphs/LICENSE.
**
*******************************************************************************/

#include "schreier-sims.h"

// C headers
#include "stdlib.h"  // for NULL
#include "string.h"  // for memset

// Digraphs package headers
#include "digraphs-debug.h"  // for DIGRAPHS_ASSERT

uint16_t PERM_DEGREE = 0;

// Schreier-Sims set up

SchreierSims* new_schreier_sims() {
  SchreierSims* ss = malloc(sizeof(SchreierSims));
  ss->tmp_perm     = new_perm(MAXVERTS);
  for (uint16_t i = 0; i < MAXVERTS; ++i) {
    ss->strong_gens[i] = new_perm_coll(MAXVERTS, MAXVERTS);
  }
  for (size_t i = 0; i < MAXVERTS * MAXVERTS; ++i) {
    ss->transversal[i] = new_perm(MAXVERTS);
    ss->inversal[i]    = new_perm(MAXVERTS);
  }
  return ss;
}

void init_ss(SchreierSims* ss, uint16_t degree) {
  DIGRAPHS_ASSERT(degree <= MAXVERTS);
  for (uint16_t i = 0; i < degree; ++i) {
    clear_perm_coll(ss->strong_gens[i]);
    ss->strong_gens[i]->degree = degree;
  }
  memset((void*) ss->orb_lookup, false, degree * degree * sizeof(bool));
  memset((void*) ss->size_orbits, 0, degree * sizeof(uint16_t));
  ss->size_base = 0;
  ss->degree    = degree;
}

static inline void
add_strong_gen_ss(SchreierSims* ss, uint16_t const pos, Perm const p) {
  DIGRAPHS_ASSERT(pos < ss->degree);
  add_perm_coll(ss->strong_gens[pos], p);
}

static inline Perm get_strong_gen_ss(SchreierSims const* const ss,
                                     uint16_t const            i,
                                     uint16_t const            j) {
  DIGRAPHS_ASSERT(i < ss->degree);
  DIGRAPHS_ASSERT(j < ss->degree);
  return ss->strong_gens[i]->perms[j];
}

static inline Perm get_transversal_ss(SchreierSims const* const ss,
                                      uint16_t const            i,
                                      uint16_t const            j) {
  DIGRAPHS_ASSERT(i < ss->degree);
  DIGRAPHS_ASSERT(j < ss->degree);
  return ss->transversal[i * MAXVERTS + j];
}

static inline Perm get_inversal_ss(SchreierSims const* const ss,
                                   uint16_t const            i,
                                   uint16_t const            j) {
  DIGRAPHS_ASSERT(i < ss->degree);
  DIGRAPHS_ASSERT(j < ss->degree);
  return ss->inversal[i * MAXVERTS + j];
}

static inline void add_base_point_ss(SchreierSims* ss, uint16_t const pt) {
  ss->base[ss->size_base]                         = pt;
  ss->size_orbits[ss->size_base]                  = 1;
  ss->orbits[ss->size_base * ss->degree]          = pt;
  ss->orb_lookup[ss->size_base * ss->degree + pt] = true;
  id_perm(get_transversal_ss(ss, ss->size_base, pt), ss->degree);
  id_perm(get_inversal_ss(ss, ss->size_base, pt), ss->degree);
  ss->size_base++;
}

static void
orbit_ss(SchreierSims* ss, uint16_t const depth, uint16_t const init_pt) {
  DIGRAPHS_ASSERT(depth <= ss->size_base);
  for (uint16_t i = 0; i < ss->size_orbits[depth]; i++) {
    uint16_t pt = ss->orbits[depth * ss->degree + i];
    for (uint16_t j = 0; j < ss->strong_gens[depth]->size; j++) {
      Perm     x   = ss->strong_gens[depth]->perms[j];
      uint16_t img = x[pt];
      if (!ss->orb_lookup[depth * ss->degree + img]) {
        ss->orbits[depth * ss->degree + ss->size_orbits[depth]] = img;
        ss->size_orbits[depth]++;
        ss->orb_lookup[depth * ss->degree + img] = true;
        prod_perms(get_transversal_ss(ss, depth, img),
                   get_transversal_ss(ss, depth, pt),
                   x,
                   ss->degree);
        invert_perm(get_inversal_ss(ss, depth, img),
                    get_transversal_ss(ss, depth, img),
                    ss->degree);
      }
    }
  }
}

static void
add_gen_orbit_ss(SchreierSims* ss, uint16_t const depth, Perm const gen) {
  DIGRAPHS_ASSERT(depth <= ss->size_base);
  // apply the new generator to existing points in ss->orbits[depth]
  uint16_t nr = ss->size_orbits[depth];
  for (uint16_t i = 0; i < nr; i++) {
    uint16_t pt  = ss->orbits[depth * ss->degree + i];
    uint16_t img = gen[pt];
    if (!ss->orb_lookup[depth * ss->degree + img]) {
      ss->orbits[depth * ss->degree + ss->size_orbits[depth]] = img;
      ss->size_orbits[depth]++;
      ss->orb_lookup[depth * ss->degree + img] = true;
      prod_perms(get_transversal_ss(ss, depth, img),
                 get_transversal_ss(ss, depth, pt),
                 gen,
                 ss->degree);
      invert_perm(get_inversal_ss(ss, depth, img),
                  get_transversal_ss(ss, depth, img),
                  ss->degree);
    }
  }

  for (uint16_t i = nr; i < ss->size_orbits[depth]; i++) {
    uint16_t pt = ss->orbits[depth * ss->degree + i];
    for (uint16_t j = 0; j < ss->strong_gens[depth]->size; j++) {
      Perm     x   = get_strong_gen_ss(ss, depth, j);
      uint16_t img = x[pt];
      if (!ss->orb_lookup[depth * ss->degree + img]) {
        ss->orbits[depth * ss->degree + ss->size_orbits[depth]] = img;
        ss->size_orbits[depth]++;
        ss->orb_lookup[depth * ss->degree + img] = true;
        prod_perms(get_transversal_ss(ss, depth, img),
                   get_transversal_ss(ss, depth, pt),
                   x,
                   ss->degree);
        invert_perm(get_inversal_ss(ss, depth, img),
                    get_transversal_ss(ss, depth, img),
                    ss->degree);
      }
    }
  }
}

static uint16_t sift_ss(SchreierSims* ss, Perm g) {
  uint16_t depth;
  for (depth = 0; depth < ss->size_base; depth++) {
    uint16_t beta = g[ss->base[depth]];
    if (!ss->orb_lookup[depth * ss->degree + beta]) {
      return depth;
    }
    prod_perms(g, g, get_inversal_ss(ss, depth, beta), ss->degree);
  }
  return depth;
}

static bool perm_fixes_all_base_points(SchreierSims* ss, Perm const x) {
  for (uint16_t i = 0; i < ss->size_base; i++) {
    if (x[ss->base[i]] != ss->base[i]) {
      return false;
    }
  }
  return true;
}

static void run_ss(SchreierSims* ss) {
  uint16_t depth = 0;
  for (uint16_t j = 0; j < ss->strong_gens[depth]->size; j++) {
    Perm x = get_strong_gen_ss(ss, depth, j);
    if (perm_fixes_all_base_points(ss, x)) {
      for (uint16_t k = 0; k < ss->degree; k++) {
        if (k != x[k]) {
          add_base_point_ss(ss, k);
          break;
        }
      }
    }
  }

  for (uint16_t i = depth + 1; i < ss->size_base + 1; i++) {
    uint16_t beta = ss->base[i - 1];
    // set up the strong generators
    for (uint16_t j = 0; j < ss->strong_gens[i - 1]->size; j++) {
      Perm x = get_strong_gen_ss(ss, i - 1, j);
      if (beta == x[beta]) {
        add_strong_gen_ss(ss, i, x);
      }
    }
    // find the orbit of <beta> under ss->strong_gens[i - 1]
    orbit_ss(ss, i - 1, beta);
  }

  int i = ss->size_base - 1;

  while (i >= (int) depth) {
    bool escape = false;
    for (uint16_t j = 0; j < ss->size_orbits[i] && !escape; j++) {
      uint16_t beta = ss->orbits[i * ss->degree + j];
      for (uint16_t m = 0; m < ss->strong_gens[i]->size && !escape; m++) {
        Perm x = get_strong_gen_ss(ss, i, m);
        prod_perms(
            ss->tmp_perm, get_transversal_ss(ss, i, beta), x, ss->degree);
        uint16_t betax = x[beta];
        if (!eq_perms(
                ss->tmp_perm, get_transversal_ss(ss, i, betax), ss->degree)) {
          bool y = true;
          prod_perms(ss->tmp_perm,
                     ss->tmp_perm,
                     get_inversal_ss(ss, i, betax),
                     ss->degree);
          uint16_t jj = sift_ss(ss, ss->tmp_perm);
          if (jj < ss->size_base) {
            y = false;
          } else if (!is_one(ss->tmp_perm, ss->degree)) {
            y = false;
            for (uint16_t k = 0; k < ss->degree; k++) {
              if (k != ss->tmp_perm[k]) {
                add_base_point_ss(ss, k);
                break;
              }
            }
          }
          if (!y) {
            for (uint16_t l = i + 1; l <= jj; l++) {
              add_strong_gen_ss(ss, l, ss->tmp_perm);
              add_gen_orbit_ss(ss, l, ss->tmp_perm);
              // add generator to <h> to orbit of ss->base[l]
            }
            i      = jj;
            escape = true;
          }
        }
      }
    }
    if (!escape) {
      i--;
    }
  }
}

void point_stabilizer(SchreierSims*  ss,
                      PermColl*      src,
                      PermColl*      dst,
                      uint16_t const pt) {
  init_ss(ss, src->degree);
  copy_perm_coll(ss->strong_gens[0], src);
  add_base_point_ss(ss, pt);
  run_ss(ss);
  copy_perm_coll(dst, ss->strong_gens[1]);
}
