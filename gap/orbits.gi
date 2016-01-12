#############################################################################
##
#W  orbits.gi
#Y  Copyright (C) 2016                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# This is arranged like this in case we want to change the method in future,
# and also to allow its use **before** the creation of a digraph (such as when
# the group is given as an argument to the constructor).

InstallGlobalFunction(DIGRAPHS_Orbits,
function(G, domain)
  local N, sch, orbs, reps, lookup, gens, genstoapply, o, l, i, j, k;

  N      := Length(domain);
  sch    := [1 .. N] * 0;
  orbs   := [];
  reps   := []; #maybe not necessary
  lookup := [];

  gens        := GeneratorsOfGroup(G);
  genstoapply := [1 .. Length(gens)];

  for i in domain do
    if sch[i] = 0 then # new orbit
      o := [i];
      Add(orbs, o);
      sch[i] := -Length(orbs);
      lookup[i] := Length(orbs);
      for j in o do
        for k in genstoapply do
          l := j ^ gens[k];
          if sch[l] = 0 then # new point in the orbit
            Add(o, l);
            sch[l] := k;
            lookup[l] := Length(orbs);
          fi;
        od;
      od;
    fi;
  od;
  return rec(orbits := orbs, schreier := sch, lookup := lookup);
end);

InstallMethod(DigraphOrbits, "for a digraph",
[IsDigraph],
function(digraph)
  local record;

  record := DIGRAPHS_Orbits(DigraphGroup(digraph),
                            DigraphVertices(digraph));

  SetDigraphSchreierVector(digraph, record.schreier);

  return record.orbits;
end);

InstallMethod(DigraphSchreierVector, "for a digraph",
[IsDigraph],
function(digraph)
  local record;

  record := DIGRAPHS_Orbits(DigraphGroup(digraph),
                            DigraphVertices(digraph));

  SetDigraphOrbits(digraph, record.orbits);

  return record.schreier;
end);

InstallMethod(DigraphOrbitReps, "for a digraph",
[IsDigraph],
function(digraph)
  return List(DigraphOrbits(digraph), Representative);
end);

InstallMethod(DigraphStabilizer, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, rep)
  local pos, stabs;

  pos := -1 * DigraphSchreierVector(digraph)[rep];
  if pos < 0 then
    ErrorMayQuit("Digraphs: DigraphStabilizer: usage,\n");
  fi;
  stabs := DigraphStabilizers(digraph);
  if not IsBound(DigraphStabilizers(digraph)[pos]) then
    stabs[pos] := Stabilizer(DigraphGroup(digraph),
                             DigraphOrbitReps(digraph)[pos]);
  fi;
  return DigraphStabilizers(digraph)[pos];
end);

InstallMethod(DigraphStabilizers, "for a digraph",
[IsDigraph],
function(digraph);
  return [];
end);
