static UIntS perm_buf[MAXVERTS];
typedef UIntS* perm;

static perm new_perm () {
  return malloc(nr2 * sizeof(UIntS));
}

static perm id_perm () {
  UIntS i;
  perm id = new_perm();
  for (i = 0; i < nr2; i++) {
    id[i] = i;
  }
  return id;
}

static bool is_one (perm x) {
  UIntS i;

  for (i = 0; i < nr2; i++) {
    if (x[i] != i) {
      return false;
    }
  }
  return true;
}

static bool eq_perms (perm x, perm y) {
  UIntS i;

  for (i = 0; i < nr2; i++) {
    if (x[i] != y[i]) {
      return false;
    }
  }
  return true;
}

static perm prod_perms (perm const x, perm const y) {
  UIntS i;
  perm z = new_perm();

  for (i = 0; i < nr2; i++) {
    z[i] = y[x[i]];
  }
  return z;
}

static perm quo_perms (perm const x, perm const y) {
  UIntS i;

  // invert y into the buf
  for (i = 0; i < nr2; i++) {
    perm_buf[y[i]] = i;
  }
  return prod_perms(x, perm_buf);
}

// changes the lhs

static void quo_perms_in_place (perm x, perm const y) {
  UIntS i;

  // invert y into the buf
  for (i = 0; i < nr2; i++) {
    perm_buf[y[i]] = i;
  }

  for (i = 0; i < nr2; i++) {
    x[i] = perm_buf[x[i]];
  }
}

static void prod_perms_in_place (perm x, perm const y) {
  UIntS i;

  for (i = 0; i < nr2; i++) {
    x[i] = y[x[i]];
  }
}

static perm invert_perm (perm const x) {
  UIntS i;

  perm y = new_perm();
  for (i = 0; i < nr2; i++) {
    y[x[i]] = i;
  }
  return y;
}



