#############################################################################
##
##  isomorph.gi
##  Copyright (C) 2014-18                                James D. Mitchell
##                                                          Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# This file contains methods using bliss or nauty, for computing isomorphisms,
# automorphisms, and canonical labellings of digraphs.

InstallGlobalFunction(DigraphsUseBliss,
function()
  # Just do nothing if NautyTracesInterface is not available.
  if DIGRAPHS_NautyAvailable then
    Info(InfoWarning,
         1,
         "Using bliss by default for AutomorphismGroup . . .");
    if not DIGRAPHS_UsingBliss then
      InstallMethod(AutomorphismGroup, "for a digraph", [IsDigraph],
      BlissAutomorphismGroup);
      MakeReadWriteGlobal("DIGRAPHS_UsingBliss");
      DIGRAPHS_UsingBliss := true;
      MakeReadOnlyGlobal("DIGRAPHS_UsingBliss");
    fi;
  fi;
end);

InstallGlobalFunction(DigraphsUseNauty,
function()
  if DIGRAPHS_NautyAvailable then
    if DIGRAPHS_UsingBliss then
      InstallMethod(AutomorphismGroup, "for a digraph", [IsDigraph],
      NautyAutomorphismGroup);
      MakeReadWriteGlobal("DIGRAPHS_UsingBliss");
      DIGRAPHS_UsingBliss := false;
      MakeReadOnlyGlobal("DIGRAPHS_UsingBliss");
    fi;
    Info(InfoWarning,
         1,
         "Using nauty by default for AutomorphismGroup . . .");
  else
    Info(InfoWarning,
         1,
         "NautyTracesInterface is not available!");
    Info(InfoWarning,
         1,
         "Using bliss by default for AutomorphismGroup . . .");
  fi;
end);

# Wrappers for the C-level functions

# The argument <colors> should be a coloring of type 1, as described before
# ValidateVertexColouring in isomorph.gd.
#
# Returns a list where the first position is the automorphism group, and the
# second is the canonical labelling.
BindGlobal("BLISS_DATA",
function(D, colors)
  local data;
  if colors <> false then
    colors := DIGRAPHS_ValidateVertexColouring(DigraphNrVertices(D),
                                               colors);
  fi;
  if IsMultiDigraph(D) then
    data := MULTIDIGRAPH_AUTOMORPHISMS(D, colors);
    if IsEmpty(data[1]) then
      data[1] := [()];
    fi;
    # Note that data[3] cannot ever be empty since there are multiple edges,
    # and since they are indistinguishable, they can be swapped by an
    # automorphism.
    data[1] := DirectProduct(Group(data[1]), Group(data[3]));
    return data;
  else
    data := DIGRAPH_AUTOMORPHISMS(D, colors);
    if IsEmpty(data[1]) then
      data[1] := [()];
    fi;
    data[1] := Group(data[1]);
  fi;

  return data;
end);

BindGlobal("BLISS_DATA_NO_COLORS",
function(D)
  return BLISS_DATA(D, false);
end);

if DIGRAPHS_NautyAvailable then
  BindGlobal("NAUTY_DATA",
  function(D, colors)
    local data;
    if colors <> false then
      colors := DIGRAPHS_ValidateVertexColouring(DigraphNrVertices(D),
                                                 colors);
      colors := NautyColorData(colors);
    fi;
    if DigraphNrVertices(D) = 0 then
      # This circumvents Issue #17 in NautyTracesInterface, whereby a graph
      # with 0 vertices causes a seg fault.
      return [Group(()), ()];
    fi;
    data := NautyDense(DigraphSource(D),
                       DigraphRange(D),
                       DigraphNrVertices(D),
                       not IsSymmetricDigraph(D),
                       colors);
    if IsEmpty(data[1]) then
      data[1] := [()];
    fi;
    data[1] := Group(data[1]);
    data[2] := data[2] ^ -1;
    return data;
  end);

  BindGlobal("NAUTY_DATA_NO_COLORS",
  function(D)
    return NAUTY_DATA(D, false);
  end);
else
  BindGlobal("NAUTY_DATA", ReturnFail);
  BindGlobal("NAUTY_DATA_NO_COLORS", ReturnFail);
fi;

# Canonical labellings

InstallMethod(BlissCanonicalLabelling, "for a digraph",
[IsDigraph],
function(D)
  local data;
  data := BLISS_DATA_NO_COLORS(D);
  SetBlissAutomorphismGroup(D, data[1]);
  return data[2];
end);

InstallMethod(BlissCanonicalLabelling, "for a digraph and vertex coloring",
[IsDigraph, IsHomogeneousList],
function(D, colors)
  return BLISS_DATA(D, colors)[2];
end);

InstallMethod(NautyCanonicalLabelling, "for a digraph",
[IsDigraph],
function(D)
  local data;
  if not DIGRAPHS_NautyAvailable or IsMultiDigraph(D) then
    Info(InfoWarning, 1, "NautyTracesInterface is not available");
    return fail;
  fi;
  data := NAUTY_DATA_NO_COLORS(D);
  SetNautyAutomorphismGroup(D, data[1]);
  return data[2];
end);

InstallMethod(NautyCanonicalLabelling,
"for a digraph and vertex coloring",
[IsDigraph, IsHomogeneousList],
function(D, colors)
  if not DIGRAPHS_NautyAvailable or IsMultiDigraph(D) then
    Info(InfoWarning, 1, "NautyTracesInterface is not available");
    return fail;
  fi;
  return NAUTY_DATA(D, colors)[2];
end);

# Canonical digraphs

InstallMethod(BlissCanonicalDigraph, "for a digraph", [IsDigraph],
function(D)
  if IsMultiDigraph(D) then
    return OnMultiDigraphs(D, BlissCanonicalLabelling(D));
  fi;
  return OnDigraphs(D, BlissCanonicalLabelling(D));
end);

InstallMethod(BlissCanonicalDigraph, "for a digraph and vertex coloring",
[IsDigraph, IsHomogeneousList],
function(D, colors)
  if IsMultiDigraph(D) then
    return OnMultiDigraphs(D, BlissCanonicalLabelling(D, colors));
  fi;
  return OnDigraphs(D, BlissCanonicalLabelling(D, colors));
end);

InstallMethod(NautyCanonicalDigraph, "for a digraph", [IsDigraph],
function(D)
  if not DIGRAPHS_NautyAvailable or IsMultiDigraph(D) then
    Info(InfoWarning, 1, "NautyTracesInterface is not available");
    return fail;
  fi;
  return OnDigraphs(D, NautyCanonicalLabelling(D));
end);

InstallMethod(NautyCanonicalDigraph, "for a digraph and vertex coloring",
[IsDigraph, IsHomogeneousList],
function(D, colors)
  if not DIGRAPHS_NautyAvailable or IsMultiDigraph(D) then
    Info(InfoWarning, 1, "NautyTracesInterface is not available");
    return fail;
  fi;
  return OnDigraphs(D, NautyCanonicalLabelling(D, colors));
end);

# Automorphism group

InstallMethod(BlissAutomorphismGroup, "for a digraph", [IsDigraph],
function(D)
  local data;
  data := BLISS_DATA_NO_COLORS(D);
  SetBlissCanonicalLabelling(D, data[2]);
  if not HasDigraphGroup(D) then
    if IsMultiDigraph(D) then
      SetDigraphGroup(D, Range(Projection(data[1], 1)));
    else
      SetDigraphGroup(D, data[1]);
    fi;
  fi;
  return data[1];
end);

InstallMethod(NautyAutomorphismGroup, "for a digraph", [IsDigraph],
function(D)
  local data;
  if not DIGRAPHS_NautyAvailable or IsMultiDigraph(D) then
    Info(InfoWarning, 1, "NautyTracesInterface is not available");
    return fail;
  fi;

  data := NAUTY_DATA_NO_COLORS(D);
  SetNautyCanonicalLabelling(D, data[2]);
  if not HasDigraphGroup(D) then
    # Multidigraphs not allowed
    SetDigraphGroup(D, data[1]);
  fi;
  return data[1];
end);

InstallMethod(BlissAutomorphismGroup, "for a digraph and vertex coloring",
[IsDigraph, IsHomogeneousList],
function(D, colors)
  return BLISS_DATA(D, colors)[1];
end);

InstallMethod(NautyAutomorphismGroup, "for a digraph and vertex coloring",
[IsDigraph, IsHomogeneousList],
function(D, colors)
  if not DIGRAPHS_NautyAvailable or IsMultiDigraph(D) then
    Info(InfoWarning, 1, "NautyTracesInterface is not available");
    return fail;
  fi;
  return NAUTY_DATA(D, colors)[1];
end);

InstallMethod(AutomorphismGroup, "for a digraph", [IsDigraph],
BlissAutomorphismGroup);

InstallMethod(AutomorphismGroup, "for a digraph and vertex coloring",
[IsDigraph, IsHomogeneousList], BlissAutomorphismGroup);

InstallMethod(AutomorphismGroup, "for a multidigraph", [IsMultiDigraph],
BlissAutomorphismGroup);

InstallMethod(AutomorphismGroup, "for a multidigraph and vertex coloring",
[IsMultiDigraph, IsHomogeneousList], BlissAutomorphismGroup);

# Check if two digraphs are isomorphic

InstallMethod(IsIsomorphicDigraph, "for digraphs",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local act;

  if gr1 = gr2 then
    return true;
  elif DigraphNrVertices(gr1) <> DigraphNrVertices(gr2)
      or DigraphNrEdges(gr1) <> DigraphNrEdges(gr2)
      or IsMultiDigraph(gr1) <> IsMultiDigraph(gr2) then
    return false;
  fi;  # JDM more!

  if IsMultiDigraph(gr1) then
    act := OnMultiDigraphs;
  else
    act := OnDigraphs;
  fi;

  if HasBlissCanonicalLabelling(gr1) and HasBlissCanonicalLabelling(gr2)
      or not ((HasNautyCanonicalLabelling(gr1)
               and NautyCanonicalLabelling(gr1) <> fail)
              or (HasNautyCanonicalLabelling(gr2)
                  and NautyCanonicalLabelling(gr2) <> fail)) then
    # Both digraphs either know their bliss canonical labelling or
    # neither know their Nauty canonical labelling.
    return act(gr1, BlissCanonicalLabelling(gr1))
           = act(gr2, BlissCanonicalLabelling(gr2));
  else
    return act(gr1, NautyCanonicalLabelling(gr1))
           = act(gr2, NautyCanonicalLabelling(gr2));
  fi;

end);

InstallMethod(IsIsomorphicDigraph, "for digraphs and homogeneous lists",
[IsDigraph, IsDigraph, IsHomogeneousList, IsHomogeneousList],
function(gr1, gr2, c1, c2)
  local m, colour1, n, colour2, max, class_sizes, act, i;

  m := DigraphNrVertices(gr1);
  colour1 := DIGRAPHS_ValidateVertexColouring(m, c1);
  n := DigraphNrVertices(gr2);
  colour2 := DIGRAPHS_ValidateVertexColouring(n, c2);

  max := Maximum(colour1);
  if max <> Maximum(colour2) then
    return false;
  fi;

  # check some invariants
  if m <> n
      or DigraphNrEdges(gr1) <> DigraphNrEdges(gr2)
      or IsMultiDigraph(gr1) <> IsMultiDigraph(gr2) then
    return false;
  fi;  # JDM more!

  class_sizes := ListWithIdenticalEntries(max, 0);
  for i in DigraphVertices(gr1) do
    class_sizes[colour1[i]] := class_sizes[colour1[i]] + 1;
    class_sizes[colour2[i]] := class_sizes[colour2[i]] - 1;
  od;
  if not ForAll(class_sizes, x -> x = 0) then
    return false;
  elif gr1 = gr2 and colour1 = colour2 then
    return true;
  fi;

  if IsMultiDigraph(gr1) then
    act := OnMultiDigraphs;
  else
    act := OnDigraphs;
  fi;

  if DIGRAPHS_UsingBliss or IsMultiDigraph(gr1) then
    return act(gr1, BlissCanonicalLabelling(gr1, colour1))
           = act(gr2, BlissCanonicalLabelling(gr2, colour2));
  else
    return act(gr1, NautyCanonicalLabelling(gr1, colour1))
           = act(gr2, NautyCanonicalLabelling(gr2, colour2));
  fi;
end);

# Isomorphisms between digraphs

InstallMethod(IsomorphismDigraphs, "for digraphs",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local label1, label2;

  if not IsIsomorphicDigraph(gr1, gr2) then
    return fail;
  elif IsMultiDigraph(gr1) then
    if gr1 = gr2 then
      return [(), ()];
    fi;
    label1 := BlissCanonicalLabelling(gr1);
    label2 := BlissCanonicalLabelling(gr2);
    return [label1[1] / label2[1], label1[2] / label2[2]];
  elif gr1 = gr2 then
    return ();
  fi;

  if HasBlissCanonicalLabelling(gr1) and HasBlissCanonicalLabelling(gr2)
      or not ((HasNautyCanonicalLabelling(gr1)
               and NautyCanonicalLabelling(gr1) <> fail)
              or (HasNautyCanonicalLabelling(gr2)
                  and NautyCanonicalLabelling(gr2) <> fail)) then
    # Both digraphs either know their bliss canonical labelling or
    # neither know their Nauty canonical labelling.
    return BlissCanonicalLabelling(gr1) / BlissCanonicalLabelling(gr2);
  else
    return NautyCanonicalLabelling(gr1) / NautyCanonicalLabelling(gr2);
  fi;
end);

InstallMethod(IsomorphismDigraphs, "for digraphs and homogeneous lists",
[IsDigraph, IsDigraph, IsHomogeneousList, IsHomogeneousList],
function(gr1, gr2, c1, c2)
  local m, colour1, n, colour2, max, class_sizes, label1, label2, i;

  m := DigraphNrVertices(gr1);
  colour1 := DIGRAPHS_ValidateVertexColouring(m, c1);
  n := DigraphNrVertices(gr2);
  colour2 := DIGRAPHS_ValidateVertexColouring(n, c2);

  max := Maximum(colour1);
  if max <> Maximum(colour2) then
    return fail;
  fi;

  # check some invariants
  if m <> n
      or DigraphNrEdges(gr1) <> DigraphNrEdges(gr2)
      or IsMultiDigraph(gr1) <> IsMultiDigraph(gr2) then
    return fail;
  fi;

  class_sizes := ListWithIdenticalEntries(max, 0);
  for i in DigraphVertices(gr1) do
    class_sizes[colour1[i]] := class_sizes[colour1[i]] + 1;
    class_sizes[colour2[i]] := class_sizes[colour2[i]] - 1;
  od;
  if not ForAll(class_sizes, x -> x = 0) then
    return fail;
  elif gr1 = gr2 and colour1 = colour2 then
    if IsMultiDigraph(gr1) then
      return [(), ()];
    fi;
    return ();
  fi;

  if DIGRAPHS_UsingBliss or IsMultiDigraph(gr1) then
    label1 := BlissCanonicalLabelling(gr1, colour1);
    label2 := BlissCanonicalLabelling(gr2, colour2);
  else
    label1 := NautyCanonicalLabelling(gr1, colour1);
    label2 := NautyCanonicalLabelling(gr2, colour2);
  fi;

  if IsMultiDigraph(gr1) then
    if OnMultiDigraphs(gr1, label1) <> OnMultiDigraphs(gr2, label2) then
      return fail;
    fi;
    return [label1[1] / label2[1], label1[2] / label2[2]];
  fi;

  if OnDigraphs(gr1, label1) <> OnDigraphs(gr2, label2) then
    return fail;
  fi;
  return label1 / label2;
end);

# Given a non-negative integer <n> and a homogeneous list <partition>,
# this global function tests whether <partition> is a valid partition
# of the list [1 .. n]. A valid partition of [1 .. n] is either:
#
# 1. A list of length <n> consisting of a numbers, such that the set of these
#    numbers is [1 .. m] for some m <= n.
# 2. A list of non-empty disjoint lists whose union is [1 .. n].
#
# If <partition> is a valid partition of [1 .. n] then this global function
# returns the partition, in form 1 (converting it to this form if necessary).
# If <partition> is invalid, then the function returns <fail>.

InstallGlobalFunction(DIGRAPHS_ValidateVertexColouring,
function(n, partition)
  local colours, i, missing, seen, x;

  if not IsInt(n) or n < 0 then
    ErrorNoReturn("the 1st argument (n) must be a non-negative integer,");
  elif not IsHomogeneousList(partition) then
    ErrorNoReturn("the 2nd argument (partition) must be a homogeneous list,");
  elif n = 0 then
    if IsEmpty(partition) then
      return partition;
    fi;
    ErrorNoReturn("the only valid partition of the vertices of the digraph ",
                  "with 0 vertices is the empty list,");
  elif not IsEmpty(partition) then
    if IsPosInt(partition[1]) and Length(partition) = n then
      # <partition> seems to be a list of colours
      colours := [];
      for i in partition do
        if not IsPosInt(i) then
          ErrorNoReturn("the 2nd argument (partition) does not define a ",
                        "colouring of the vertices [1 .. ", n, "], since it ",
                        "contains the element ", i, ", which is not a ",
                        "positive integer,");
        elif i > n then
          ErrorNoReturn("the 2nd argument (partition) does not define ",
                        "a colouring of the vertices [1 .. ", n, "], since ",
                        "it contains the integer ", i,
                        ", which is greater than ", n, ",");
        fi;
        AddSet(colours, i);
      od;
      i := Length(colours);
      missing := Difference([1 .. i], colours);
      if not IsEmpty(missing) then
        ErrorNoReturn("the 2nd argument (partition) does not define a ",
                      "colouring ",
                      "of the vertices [1 .. ", n, "], since it contains the ",
                      "colour ", colours[i], ", but it lacks the colour ",
                      missing[1], ". A colouring must use precisely the ",
                      "colours [1 .. m], for some positive integer m <= ", n,
                      ",");
      fi;
      return partition;
    elif IsList(partition[1]) then
      seen := BlistList([1 .. n], []);
      colours := EmptyPlist(n);
      for i in [1 .. Length(partition)] do
        # guaranteed to be non-empty since <partition> is homogeneous
        for x in partition[i] do
          if not IsPosInt(x) or x > n then
            ErrorNoReturn("the 2nd argument (partition) does not define a ",
                          "colouring of the vertices [1 .. ", n, "], since ",
                          "the entry in position ", i, " contains ", x,
                          " which is not an integer in the range [1 .. ", n,
                          "],");
          elif seen[x] then
            ErrorNoReturn("the 2nd argument (partition) does not define a ",
                          "colouring of the vertices [1 .. ", n, "], since ",
                          "it contains the vertex ", x, " more than once,");
          fi;
          seen[x] := true;
          colours[x] := i;
        od;
      od;
      i := First([1 .. n], x -> not seen[x]);
      if i <> fail then
        ErrorNoReturn("the 2nd argument (partition) does not define a ",
                      "colouring of the vertices [1 .. ", n, "], since ",
                      "it does not assign a colour to the vertex ", i, ",");
      fi;
      return colours;
    fi;
  fi;
  ErrorNoReturn("the 2nd argument (partition) does not define a ",
                "colouring of the vertices [1 .. ", n, "]. The 2nd ",
                "argument must have one of the following forms: ",
                "1. a list of length ", n, " consisting of ",
                "every integer in the range [1 .. m], for some m <= ", n,
                "; or 2. a list of non-empty disjoint lists ",
                "whose union is [1 .. ", n, "].");
end);

InstallMethod(IsDigraphIsomorphism, "for digraph, digraph, and permutation",
[IsDigraph, IsDigraph, IsPerm],
function(src, ran, x)
  if IsMultiDigraph(src) or IsMultiDigraph(ran) then
    ErrorNoReturn("the 1st and 2nd arguments (src and ran) must not have ",
                  "multiple edges,");
  fi;
  return IsDigraphHomomorphism(src, ran, x)
    and IsDigraphHomomorphism(ran, src, x ^ -1);
end);

InstallMethod(IsDigraphAutomorphism, "for a digraph and a permutation",
[IsDigraph, IsPerm],
function(D, x)
  return IsDigraphIsomorphism(D, D, x);
end);

InstallMethod(IsDigraphIsomorphism, "for digraph, digraph, and transformation",
[IsDigraph, IsDigraph, IsTransformation],
function(src, ran, x)
  local y;
  y := AsPermutation(RestrictedTransformation(x, DigraphVertices(src)));
  if y = fail then
    return false;
  fi;
  return IsDigraphIsomorphism(src, ran, y);
end);

InstallMethod(IsDigraphAutomorphism, "for a digraph and a transformation",
[IsDigraph, IsTransformation],
function(D, x)
  return IsDigraphIsomorphism(D, D, x);
end);
