#############################################################################
##
#W  bliss.gi
#Y  Copyright (C) 2014-15                                James D. Mitchell
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
    return MULTIDIGRAPH_CANONICAL_LABELLING(digraph);
  fi;
  return DIGRAPH_CANONICAL_LABELLING(digraph);
end);

InstallMethod(DigraphCanonicalLabelling,
"for a digraph and homogeneous list",
[IsDigraph, IsHomogeneousList],
function(graph, list)
  local colors, i;

  if IsMultiDigraph(graph) then
    return fail;
  fi;
  if (not IsEmpty(list)) and IsList(list[1]) then # color classes
    colors := [1 .. DigraphNrVertices(graph)];
    if not (ForAll(list, IsDuplicateFreeList) and Union(list) = colors) then
      ErrorNoReturn("Digraphs: DigraphCanonicalLabelling: usage,\n",
                    "the union of the lists in the second arg should equal ",
                    "[1 .. ", DigraphNrVertices(graph), "],");
    fi;

    for i in [1 .. Length(list)] do
      colors{list[i]} := [1 .. Length(list[i])] * 0 + i;
    od;
  else
    if not (Length(list) = DigraphNrVertices(graph)
            and ForAll(list, c -> IsPosInt(c) and 1 <= c
                                  and c <= DigraphNrVertices(graph))) then
      ErrorNoReturn("Digraphs: DigraphCanonicalLabelling: usage,\n",
                    "the second arg must be a list of length ",
                    DigraphNrVertices(graph), " of integers in [1 .. ",
                    DigraphNrVertices(graph), "],");
    fi;
    colors := list;
  fi;

  return DIGRAPH_CANONICAL_LABELLING_COLOURS(graph, colors);
end);

#

InstallMethod(IsIsomorphicDigraph, "for digraphs",
[IsDigraph, IsDigraph],
function(g1, g2)

  # check some invariants
  if DigraphNrVertices(g1) <> DigraphNrVertices(g2)
      or DigraphNrEdges(g1) <> DigraphNrEdges(g2)
      or IsMultiDigraph(g1) <> IsMultiDigraph(g2) then
    return false;
  fi; #JDM more!

  if IsMultiDigraph(g1) then
    return OnMultiDigraphs(g1, DigraphCanonicalLabelling(g1))
      = OnMultiDigraphs(g2, DigraphCanonicalLabelling(g2));
  fi;
  return OnDigraphs(g1, DigraphCanonicalLabelling(g1))
    = OnDigraphs(g2, DigraphCanonicalLabelling(g2));
end);

#

InstallMethod(AutomorphismGroup, "for a digraph",
[IsDigraph],
function(graph)
  local x;

  if IsMultiDigraph(graph) then
    x := MULTIDIGRAPH_AUTOMORPHISMS(graph);
    SetDigraphCanonicalLabelling(graph, x[1]);
    return DirectProduct(Group(x[2]), Group(x[3]));
  fi;

  x := DIGRAPH_AUTOMORPHISMS(graph);
  SetDigraphCanonicalLabelling(graph, x[1]);
  if not HasDigraphGroup(graph) then
    SetDigraphGroup(graph, Group(x[2]));
  fi;
  return Group(x[2]);
end);

InstallMethod(AutomorphismGroup, "for a digraph and homogeneous list",
[IsDigraph, IsHomogeneousList],
function(graph, list)
  local colors, i;

  if IsMultiDigraph(graph) then
    return fail;
  fi;
  if (not IsEmpty(list)) and IsList(list[1]) then # color classes
    colors := [1 .. DigraphNrVertices(graph)];
    if not (ForAll(list, IsDuplicateFreeList) and Union(list) = colors) then
      ErrorNoReturn("Digraphs: AutomorphismGroup: usage,\n",
                    "the union of the lists in the second arg should equal ",
                    "[1 .. ", DigraphNrVertices(graph), "],");
    fi;

    for i in [1 .. Length(list)] do
      colors{list[i]} := [1 .. Length(list[i])] * 0 + i;
    od;
  else
    if not (Length(list) = DigraphNrVertices(graph)
            and ForAll(list, c -> IsPosInt(c) and 1 <= c
                                  and c <= DigraphNrVertices(graph))) then
      ErrorNoReturn("Digraphs: AutomorphismGroup: usage,\n",
                    "the second arg must be a list of length ",
                    DigraphNrVertices(graph), " of integers in [1 .. ",
                    DigraphNrVertices(graph), "],");
    fi;
    colors := list;
  fi;
  return Group(DIGRAPH_AUTOMORPHISMS_COLOURS(graph, colors));
end);

#

InstallMethod(IsomorphismDigraphs, "for digraphs",
[IsDigraph, IsDigraph],
function(g1, g2)
  local label1, label2;

  if not IsIsomorphicDigraph(g1, g2) then
    return fail;
  fi;

  if IsMultiDigraph(g1) then
    label1 := DigraphCanonicalLabelling(g1);
    label2 := DigraphCanonicalLabelling(g2);
    return [label1[1] / label2[1], label1[2] / label2[2]];
  fi;

  return DigraphCanonicalLabelling(g1) / DigraphCanonicalLabelling(g2);
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
