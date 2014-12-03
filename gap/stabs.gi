# calculates the stabilizer chain data structure completely.

init_stab_chain := function(gens)
  local lmp;
  if IsGroup(gens) then
    gens := GeneratorsOfGroup(gens);
  fi;

  lmp := LargestMovedPoint(gens);
  return rec(
     S := [gens],
     orbits := [],
     borbits := [],
     transversal := [],
     lmp := lmp,
     base := [],
   );
end;

orbit_stab_chain := function(stab_chain, depth, pt)
  local orbits, borbits, transversal, S, img, i, x;
 
  orbits := stab_chain.orbits[depth];
  borbits := stab_chain.borbits[depth];
  transversal := stab_chain.transversal[depth];
  S := stab_chain.S[depth];

  for pt in orbits do
    for x in S do
      img := pt ^ x;
      if borbits[img] = false then
        Add(orbits, img);
        borbits[img] := true;
        transversal[img] := transversal[pt] * x;
      fi;
    od;
  od;
end;

add_gen_orbit_stab_chain := function(stab_chain, depth, gen)
  local orbits, borbits, transversal, S, len, img, pt, i, x;
  orbits := stab_chain.orbits[depth];
  borbits := stab_chain.borbits[depth];
  transversal := stab_chain.transversal[depth];
  S := stab_chain.S[depth];

  len := Length(orbits);
  for i in [1..Length(orbits)] do
    img := orbits[i] ^ gen;
    if borbits[img] = false then
      Add(orbits, img);
      borbits[img] := true;
      transversal[img] := transversal[orbits[i]] * gen;
    fi;
  od;

  if len < Length(orbits) then
    i := len;
    while i < Length(orbits) do
      i := i + 1;
      pt := orbits[i];
      for x in S do
        img := pt ^ x;
        if borbits[img] = false then
          Add(orbits, img);
          borbits[img] := true;
          transversal[img] := transversal[pt] * x;
        fi;
      od;
    od;
  fi;
end;

sift_stab_chain := function (stab_chain, g)
  local base, borbits, transversal, beta, i;
  
  base := stab_chain.base;
  borbits := stab_chain.borbits;
  transversal := stab_chain.transversal;
  
  for i in [1 .. Length(base)] do
    beta := base[i] ^ g;
    if not borbits[i][beta] then
      return [g, i];
    fi;
    g := g * transversal[i][beta] ^ -1;
  od;

  return [g, Length(stab_chain.base) + 1];
end;

add_base_point := function(stab_chain, k)
  Add(stab_chain.base, k);
  stab_chain.S[Length(stab_chain.base) + 1] := [];
  Add(stab_chain.orbits, [k]);
  Add(stab_chain.borbits, BlistList([1 .. stab_chain.lmp], [k]));
  Add(stab_chain.transversal, []);
  stab_chain.transversal[Length(stab_chain.transversal)][k] := ();
end;

remove_base_point := function(stab_chain, depth)
  local i;

  for i in [depth .. Length(stab_chain.base)] do 
    Unbind(stab_chain.S[i + 1]);
    Unbind(stab_chain.base[i]);
    Unbind(stab_chain.orbits[i]);
    Unbind(stab_chain.borbits[i]);
    Unbind(stab_chain.transversal[i]);
  od;
end;

schreier_sims_stab_chain := function(stab_chain, depth)
  local base, transversal, orbits, borbits, lmp, S, beta, i, escape, y, tmp, h, jj, T, x, j, k, l;

  base := stab_chain.base;
  transversal := stab_chain.transversal;
  orbits := stab_chain.orbits;
  borbits := stab_chain.borbits;
  lmp := stab_chain.lmp;
  S := stab_chain.S;

  for T in S do
    for x in T do 
      if ForAll(base, i -> i ^ x = i) then
        for i in [1 .. lmp] do
          if i ^ x <> i then
            add_base_point(stab_chain, i);
            break;
          fi;
        od;
      fi;
    od;
  od;
  
  for i in [depth + 1 .. Length(base) + 1] do
    beta := base[i - 1];
    # set up the strong generators
    for x in S[i - 1] do
      if beta ^ x = beta then
        Add(S[i], x);
      fi;
    od;

    # find the orbit of <beta> under S[i - 1]
    orbit_stab_chain(stab_chain, i - 1, beta);
  od;

  i := Length(base);

  while i >= depth do
    escape := false;
    for j in [1 .. Length(orbits[i])] do
      beta := orbits[i][j];
      for x in S[i] do
        if transversal[i][beta] * x <> transversal[i][beta ^ x] then
          y := true;
          tmp := sift_stab_chain(stab_chain, transversal[i][beta] * x *
            transversal[i][beta ^ x] ^ - 1);
          h := tmp[1];
          jj := tmp[2];
          if jj <= Length(base) then 
            y := false;
          elif not IsOne(h) then
            y := false;
            for k in [1 .. lmp] do
              if k ^ h <> k then
                add_base_point(stab_chain, k);
                break;
              fi;
            od;
          fi;
    
          if y = false then
            for l in [i + 1 .. jj] do
              Add(S[l], h);
              add_gen_orbit_stab_chain(stab_chain, l, h);
              # add generator to <h> to orbit of base[l]
            od;
            i := jj;
            escape := true;
            break;
          fi;
        fi;
      od;
      if escape then
        break;
      fi;
    od;
    if escape then
      continue;
    fi;
    i := i - 1;
  od;

  return stab_chain;
end;

schreier_sims_stab_chain_default := function(stab_chain) 
  return schreier_sims_stab_chain(stab_chain, 1);
end;

size_stab_chain := function(stab_chain)
  return Product(List(stab_chain.orbits, Length));
end;
