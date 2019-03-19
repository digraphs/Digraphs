#############################################################################
##
##  orbits.gi
##  Copyright (C) 2016                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallGlobalFunction(DIGRAPHS_TraceSchreierVector,
function(gens, sch, r)
  local word, w;
  word := [];
  w := sch[r];
  while w > 0 do
    Add(word, w);
    r := r / gens[w];
    w := sch[r];
  od;
  return rec(word := Reversed(word), representative := -w);
end);

InstallGlobalFunction(DIGRAPHS_EvaluateWord,
function(gens, word)
  local out, i;
  out := ();
  for i in word do
    out := out * gens[i];
  od;
  return out;
end);

# This is arranged like this in case we want to change the method in future,
# and also to allow its use **before** the creation of a digraph (such as when
# the group is given as an argument to the constructor).

InstallGlobalFunction(DIGRAPHS_Orbits,
function(G, domain)
  local N, sch, orbs, lookup, gens, genstoapply, o, l, i, j, k;

  N      := Length(domain);
  sch    := [1 .. N] * 0;
  orbs   := [];
  lookup := [];

  gens        := GeneratorsOfGroup(G);
  genstoapply := [1 .. Length(gens)];

  for i in domain do
    if sch[i] = 0 then  # new orbit
      o := [i];
      Add(orbs, o);
      sch[i] := -Length(orbs);
      lookup[i] := Length(orbs);
      for j in o do
        for k in genstoapply do
          l := j ^ gens[k];
          if sch[l] = 0 then  # new point in the orbit
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

InstallMethod(RepresentativeOutNeighbours, "for a dense digraph",
[IsDenseDigraphRep],
function(D)
  local reps, out, nbs, i;

  if IsTrivial(DigraphGroup(D)) then
    return OutNeighbours(D);
  fi;

  reps := DigraphOrbitReps(D);
  out  := EmptyPlist(Length(reps));
  nbs  := OutNeighbours(D);

  for i in [1 .. Length(reps)] do
    out[i] := nbs[reps[i]];
  od;
  return out;
end);

InstallImmediateMethod(DigraphGroup, IsDigraph and HasAutomorphismGroup,
0, function(D)
  if IsMultiDigraph(D) then
    return Range(Projection(AutomorphismGroup(D), 1));
  fi;
  return AutomorphismGroup(D);
end);

InstallMethod(DigraphGroup, "for a digraph",
[IsDigraph],
function(D)
  if IsMultiDigraph(D) then
    return Range(Projection(AutomorphismGroup(D), 1));
  fi;
  return AutomorphismGroup(D);
end);

InstallMethod(DigraphOrbits, "for a digraph",
[IsDigraph],
function(D)
  local record;
  record := DIGRAPHS_Orbits(DigraphGroup(D),
                            DigraphVertices(D));
  SetDigraphSchreierVector(D, record.schreier);
  return record.orbits;
end);

InstallMethod(DigraphSchreierVector, "for a digraph",
[IsDigraph],
function(D)
  local record;
  record := DIGRAPHS_Orbits(DigraphGroup(D),
                            DigraphVertices(D));
  SetDigraphOrbits(D, record.orbits);
  return record.schreier;
end);

InstallMethod(DigraphOrbitReps, "for a digraph",
[IsDigraph],
function(D)
  return List(DigraphOrbits(D), Representative);
end);

InstallMethod(DigraphStabilizer, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(D, v)
  local pos, gens, sch, trace, word, stabs;

  if v > DigraphNrVertices(D) then
    ErrorNoReturn("Digraphs: DigraphStabilizer: usage,\n",
                  "the second argument must not exceed ",
                  DigraphNrVertices(D), ",");
  fi;

  pos := DigraphSchreierVector(D)[v];
  if pos < 0 then  # rep is one of the orbit reps
    word := ();
    pos := pos * -1;
  else
    gens  := GeneratorsOfGroup(DigraphGroup(D));
    sch   := DigraphSchreierVector(D);
    trace := DIGRAPHS_TraceSchreierVector(gens, sch, v);
    pos   := trace.representative;
    word  := DIGRAPHS_EvaluateWord(gens, trace.word);
  fi;

  stabs := DIGRAPHS_Stabilizers(D);

  if not IsBound(stabs[pos]) then
    stabs[pos] := Stabilizer(DigraphGroup(D),
                             DigraphOrbitReps(D)[pos]);
  fi;
  return stabs[pos] ^ word;
end);

InstallMethod(DIGRAPHS_Stabilizers, "for a D", [IsDigraph],
function(D);
  return [];
end);
