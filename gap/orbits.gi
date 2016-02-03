#############################################################################
##
#W  orbits.gi
#Y  Copyright (C) 2016                                   James D. Mitchell
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

InstallMethod(RepresentativeOutNeighbours, "for a digraph", [IsDigraph],
function(digraph)
  local reps, out, nbs, i;

  if IsTrivial(DigraphGroup(digraph)) then
    return OutNeighbours(digraph);
  fi;

  reps  := DigraphOrbitReps(digraph);

  out := EmptyPlist(Length(reps));
  nbs := OutNeighbours(digraph);

  for i in [1 .. Length(reps)] do
    out[i] := nbs[reps[i]];
  od;
  return out;
end);

InstallImmediateMethod(DigraphGroup, IsDigraph and HasAutomorphismGroup,
0, function(digraph)
  if IsMultiDigraph(digraph) then
    return Range(Projection(AutomorphismGroup(digraph), 1));
  fi;
  return AutomorphismGroup(digraph);
end);

InstallMethod(DigraphGroup, "for a digraph",
[IsDigraph],
function(digraph)
  if IsMultiDigraph(digraph) then
    return Range(Projection(AutomorphismGroup(digraph), 1));
  fi;
  return AutomorphismGroup(digraph);
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
function(digraph, v)
  local pos, gens, sch, trace, word, stabs;

  if v > DigraphNrVertices(digraph) then
    ErrorNoReturn("Digraphs: DigraphStabilizer: usage,\n",
                  "the second argument must not exceed ",
                  DigraphNrVertices(digraph), ",");
  fi;

  pos := DigraphSchreierVector(digraph)[v];
  if pos < 0 then # rep is one of the orbit reps
    word := ();
    pos := pos * - 1;
  else
    gens  := GeneratorsOfGroup(DigraphGroup(digraph));
    sch   := DigraphSchreierVector(digraph);
    trace := DIGRAPHS_TraceSchreierVector(gens, sch, v);
    pos   := trace.representative;
    word  := DIGRAPHS_EvaluateWord(gens, trace.word);
  fi;

  stabs := DIGRAPHS_Stabilizers(digraph);

  if not IsBound(stabs[pos]) then
    stabs[pos] := Stabilizer(DigraphGroup(digraph),
                             DigraphOrbitReps(digraph)[pos]);
  fi;
  return stabs[pos] ^ word;
end);

InstallMethod(DIGRAPHS_Stabilizers, "for a digraph", [IsDigraph],
function(digraph);
  return [];
end);
