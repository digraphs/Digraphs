#############################################################################
##
#W  bliss.gi
#Y  Copyright (C) 2014-17                                James D. Mitchell
##                                                          Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# methods using bliss . . .

InstallMethod(DigraphCanonicalLabelling, "for a digraph",
[IsDigraph],
function(digraph)
  if IsMultiDigraph(digraph) then
    return MULTIDIGRAPH_CANONICAL_LABELLING(digraph, fail);
  fi;
  return DIGRAPH_CANONICAL_LABELLING(digraph, fail);
end);

#

InstallMethod(DigraphCanonicalLabelling, "for a digraph and homogeneous list",
[IsDigraph, IsHomogeneousList],
function(digraph, list)
  local n, colours;

  n := DigraphNrVertices(digraph);
  colours := DIGRAPHS_ValidateVertexColouring(n, list,
                                              "DigraphCanonicalLabelling");
  if IsMultiDigraph(digraph) then
    return MULTIDIGRAPH_CANONICAL_LABELLING(digraph, colours);
  fi;
  return DIGRAPH_CANONICAL_LABELLING(digraph, colours);
end);

#

InstallMethod(IsIsomorphicDigraph, "for digraphs",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local act;

  if gr1 = gr2 then
    return true;
  fi;

  # check some invariants
  if DigraphNrVertices(gr1) <> DigraphNrVertices(gr2)
      or DigraphNrEdges(gr1) <> DigraphNrEdges(gr2)
      or IsMultiDigraph(gr1) <> IsMultiDigraph(gr2) then
    return false;
  fi; #JDM more!

  if IsMultiDigraph(gr1) then
    act := OnMultiDigraphs;
  else
    act := OnDigraphs;
  fi;

  return act(gr1, DigraphCanonicalLabelling(gr1))
    = act(gr2, DigraphCanonicalLabelling(gr2));
end);

#

InstallMethod(IsIsomorphicDigraph, "for digraphs and homogeneous lists",
[IsDigraph, IsDigraph, IsHomogeneousList, IsHomogeneousList],
function(gr1, gr2, c1, c2)
  local m, colour1, n, colour2, max, class_sizes, act, i;

  m := DigraphNrVertices(gr1);
  colour1 := DIGRAPHS_ValidateVertexColouring(m, c1, "IsIsomorphicDigraph");
  n := DigraphNrVertices(gr2);
  colour2 := DIGRAPHS_ValidateVertexColouring(n, c2, "IsIsomorphicDigraph");

  max := Maximum(colour1);
  if max <> Maximum(colour2) then
    return false;
  fi;

  # check some invariants
  if m <> n
      or DigraphNrEdges(gr1) <> DigraphNrEdges(gr2)
      or IsMultiDigraph(gr1) <> IsMultiDigraph(gr2) then
    return false;
  fi; #JDM more!

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

  return act(gr1, DigraphCanonicalLabelling(gr1, colour1))
    = act(gr2, DigraphCanonicalLabelling(gr2, colour2));
end);

#

InstallMethod(AutomorphismGroup, "for a digraph",
[IsDigraph],
function(digraph)
  local x, G;

  if IsMultiDigraph(digraph) then
    x := MULTIDIGRAPH_AUTOMORPHISMS(digraph, fail);
  else
    x := DIGRAPH_AUTOMORPHISMS(digraph, fail);
  fi;

  SetDigraphCanonicalLabelling(digraph, x[1]);
  G := Group(x[2]);
  if not HasDigraphGroup(digraph) then
    SetDigraphGroup(digraph, G);
  fi;

  if IsMultiDigraph(digraph) then
    return DirectProduct(G, Group(x[3]));
  fi;
  return G;
end);

InstallMethod(AutomorphismGroup, "for a digraph and homogeneous list",
[IsDigraph, IsHomogeneousList],
function(digraph, list)
  local n, colours, x;

  n := DigraphNrVertices(digraph);
  colours := DIGRAPHS_ValidateVertexColouring(n, list, "AutomorphismGroup");

  if IsMultiDigraph(digraph) then
    x := MULTIDIGRAPH_AUTOMORPHISMS(digraph, colours);
    return DirectProduct(Group(x[2]), Group(x[3]));
  fi;
  return Group(DIGRAPH_AUTOMORPHISMS(digraph, colours)[2]);
end);

#

InstallMethod(IsomorphismDigraphs, "for digraphs",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local label1, label2;

  if not IsIsomorphicDigraph(gr1, gr2) then
    return fail;
  fi;

  if IsMultiDigraph(gr1) then
    if gr1 = gr2 then
      return [(), ()];
    fi;
    label1 := DigraphCanonicalLabelling(gr1);
    label2 := DigraphCanonicalLabelling(gr2);
    return [label1[1] / label2[1], label1[2] / label2[2]];
  fi;

  if gr1 = gr2 then
    return ();
  fi;
  return DigraphCanonicalLabelling(gr1) / DigraphCanonicalLabelling(gr2);
end);

#

InstallMethod(IsomorphismDigraphs, "for digraphs and homogeneous lists",
[IsDigraph, IsDigraph, IsHomogeneousList, IsHomogeneousList],
function(gr1, gr2, c1, c2)
  local m, colour1, n, colour2, max, class_sizes, label1, label2, i;

  m := DigraphNrVertices(gr1);
  colour1 := DIGRAPHS_ValidateVertexColouring(m, c1, "IsomorphismDigraphs");
  n := DigraphNrVertices(gr2);
  colour2 := DIGRAPHS_ValidateVertexColouring(n, c2, "IsomorphismDigraphs");

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

  label1 := DigraphCanonicalLabelling(gr1, colour1);
  label2 := DigraphCanonicalLabelling(gr2, colour2);

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
function(n, partition, method)
  local colours, i, missing, seen, x;

  if not IsInt(n) or n < 0 then
    ErrorNoReturn("Digraphs: DIGRAPHS_ValidateVertexColouring: usage,\n",
                  "the first argument <n> must be a non-negative integer,");
  elif not IsString(method) then
    ErrorNoReturn("Digraphs: DIGRAPHS_ValidateVertexColouring: usage,\n",
                  "the third argument <method> must be a string,");
  elif not IsHomogeneousList(partition) then
    ErrorNoReturn("Digraphs: ", method, ": usage,\n",
                  "in order to define a colouring, the argument <partition> ",
                  "must be a homogeneous\nlist,");
  elif n = 0 then
    if IsEmpty(partition) then
      return partition;
    fi;
    ErrorNoReturn("Digraphs: ", method, ": usage,\n",
                  "the only valid partition of the vertices of the digraph ",
                  "with 0 vertices is the\nempty list,");
  elif not IsEmpty(partition) then
    if IsPosInt(partition[1]) and Length(partition) = n then
      # <partition> seems to be a list of colours
      colours := [];
      for i in partition do
        if not IsPosInt(i) then
          ErrorNoReturn("Digraphs: ", method, ": usage,\n",
                        "the argument <partition> does not define a colouring ",
                        "of the vertices [1 .. ", n, "],\nsince it contains ",
                        "the element <i>, which is not a positive integer,");
        elif i > n then
          ErrorNoReturn("Digraphs: ", method, ": usage,\n",
                        "the argument <partition> does not define a colouring ",
                        "of the vertices [1 .. ", n, "],\nsince it contains ",
                        "the integer ", i, ", which is greater than ", n, ",");
        fi;
        AddSet(colours, i);
      od;
      i := Length(colours);
      missing := Difference([1 .. i], colours);
      if not IsEmpty(missing) then
        ErrorNoReturn("Digraphs: ", method, ": usage,\n",
                      "the argument <partition> does not define a colouring ",
                      "of the vertices [1 .. ", n, "],\nsince it contains the ",
                      "colour ", colours[i], ", but it lacks the colour ",
                      missing[1], ". A colouring must\nuse precisely the ",
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
            ErrorNoReturn("Digraphs: ", method, ": usage,\n",
                          "the argument <partition> does not define a ",
                          "colouring of the vertices [1 .. ", n, "],\nsince ",
                          "<partition[i]> contains <x>, which is not an ",
                          "integer in the range\n[1 .. ", n, "],");
          elif seen[x] then
            ErrorNoReturn("Digraphs: ", method, ": usage,\n",
                          "the argument <partition> does not define a ",
                          "colouring of the vertices [1 .. ", n, "],\nsince ",
                          "it contains the vertex ", x, " more than once,");
          fi;
          seen[x] := true;
          colours[x] := i;
        od;
      od;
      i := First([1 .. n], x -> not seen[x]);
      if i <> fail then
        ErrorNoReturn("Digraphs: ", method, ": usage,\n",
                      "the argument <partition> does not define a ",
                      "colouring of the vertices [1 .. ", n, "],\nsince ",
                      "it does not assign a colour to the vertex ", i, ",");
      fi;
      return colours;
    fi;
  fi;
  ErrorNoReturn("Digraphs: ", method, ": usage,\n",
                "the argument <partition> does not define a ",
                "colouring of the vertices [1 .. ", n, "].\nThe list ",
                "<partition> must have one of the following forms:\n",
                "1. <partition> is a list of length ", n, " consisting of ",
                "every integer in the range\n   [1 .. m], for some m <= ", n,
                ";\n2. <partition> is a list of non-empty disjoint lists ",
                "whose union is [1 .. ", n, "].\nIn the first form, ",
                "<partition[i]> is the colour of vertex i; in the second\n",
                "form, <partition[i]> is the list of vertices with colour i,");
end);
