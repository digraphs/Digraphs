#############################################################################
##
#W  props.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

#

if IsBound(IS_STRONGLY_CONNECTED_DIGRAPH) then
  InstallMethod(IsStronglyConnectedDigraph, "for a digraph",
  [IsDigraph],
  function(digraph)
    local conn;
    if HasIsAcyclicDigraph(digraph)
     and IsAcyclicDigraph(digraph)
     and DigraphNrVertices(digraph) > 1 then
      return false;
    fi;
    conn := IS_STRONGLY_CONNECTED_DIGRAPH(OutNeighbours(digraph));
    if conn and DigraphNrVertices(digraph) > 1 then
      SetIsAcyclicDigraph(digraph, false);
    fi;
    return conn;
  end);
else
  InstallMethod(IsStronglyConnectedDigraph, "for a digraph",
  [IsDigraph],
  function(graph)
    local adj, n, stack1, len1, stack2, len2, id, count, fptr, level, l, w, v;

    adj := OutNeighbours(graph);
    n := Length(adj);

    if n = 0 then
      return true;
    fi;

    stack1 := EmptyPlist(n); len1 := 1;
    stack2 := EmptyPlist(n); len2 := 1;
    id:=[ 1 .. n ] * 0;
    level := 1;
    fptr := [];

    fptr[1] := 1; # vertex
    fptr[2] := 1; # adjacency index
    stack1[len1] := 1;
    stack2[len2] := len1;
    id[1] := len1;

    while true do # we always return before level = 0
      if fptr[2 * level] > Length(adj[fptr[2 * level - 1]]) then
        if stack2[len2] = id[fptr[2 * level - 1]] then
          repeat
            n := n - 1;
            w := stack1[len1];
            len1 := len1 - 1;
          until w = fptr[2 * level - 1];
          return (n = 0);
        fi;
        level := level - 1;
      else
        w := adj[fptr[2 * level - 1]][fptr[2 * level]];
        fptr[2 * level] := fptr[2 * level] + 1;

        if id[ w ] = 0 then
          level := level + 1;
          fptr[2 * level - 1] := w; #fptr[0], vertex
          fptr[2 * level ] := 1;   #fptr[2], index
          len1 := len1 + 1;
          stack1[ len1 ] := w;
          len2 := len2 + 1;
          stack2[ len2 ] := len1;
          id[ w ] := len1;
        else # we saw <w> earlier in this run
          while stack2[ len2 ] > id[ w ] do
            len2 := len2 - 1; # pop from stack2
          od;
        fi;
      fi;
    od;
  end);
fi;

#

InstallMethod(IsCompleteDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  local n;

  n := DigraphNrVertices(digraph);
  if n = 0 then
    return true;
  elif IsMultiDigraph(digraph) then
    return false;
  elif DigraphNrEdges(digraph) <> (n * (n - 1) ) then
    return false;
  fi;
  return not DigraphHasLoops(digraph);
end);

#

InstallMethod(IsConnectedDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  # Check for easy answers
  if DigraphNrVertices(digraph) < 2 then
    return true;
  elif HasIsStronglyConnectedDigraph(digraph)
   and IsStronglyConnectedDigraph(digraph) then
    return true;
  elif DigraphNrEdges(digraph) < DigraphNrVertices(digraph) - 1 then
    return false;
  fi;
  # DigraphSymmetricClosure is not yet implemented!
  return IsStronglyConnectedDigraph( DigraphSymmetricClosure(digraph) );
end);

#

InstallImmediateMethod(IsAcyclicDigraph, "for a reflexive digraph", IsReflexiveDigraph, 0,
function(digraph)
  if IsEmptyDigraph(digraph) then
    return true;
  else
    return false;
  fi;
end);

#

if IsBound(IS_ACYCLIC_DIGRAPH) then
  InstallMethod(IsAcyclicDigraph, "for a digraph",
  [IsDigraph],
  function(digraph)
    local n, scc, acyclic;

    n := DigraphNrVertices(digraph);

    # WW: I think condition can't be met w/o IsAcyclic already being set false:
    # if HasIsStronglyConnectedDigraph(digraph) and 
    #  IsStronglyConnectedDigraph(digraph) and n > 1 then
    #   return false; 
    # fi;
    if n = 0 then
      return true;
    elif HasDigraphHasLoops(digraph) and DigraphHasLoops(digraph) then
      return false;
    elif HasDigraphStronglyConnectedComponents(digraph) then
      scc := DigraphStronglyConnectedComponents(digraph);
      if not Length(scc.comps) = n then
        SetIsStronglyConnectedDigraph(digraph, false);
        return false;
      else
        SetIsStronglyConnectedDigraph(digraph, false);
        return not DigraphHasLoops(digraph);
      fi;
    fi;
    acyclic := IS_ACYCLIC_DIGRAPH(OutNeighbours(digraph));
    if acyclic and n > 1 then
      SetIsStronglyConnectedDigraph(digraph, false);
    fi;
    return acyclic;
  end);
else
  InstallMethod(IsAcyclicDigraph, "for a digraph",
  [IsDigraph],
  function(graph)
    local adj, nr, verts, vertex_complete, vertex_in_path, stack, level, j, 
    k, i;

    adj := OutNeighbours(graph);
    nr := DigraphNrVertices(graph);
    verts := DigraphVertices(graph);
    vertex_complete := BlistList( verts, [ ] );
    vertex_in_path := BlistList( verts, [ ] );
    stack:=EmptyPlist(2 * nr + 2);

    for i in verts do
      if Length(adj[i]) = 0 then
        vertex_complete[i] := true;
      elif not vertex_complete[i] then
        level := 1;
        stack[1] := i;
        stack[2] := 1;
        while true do
          j:=stack[2 * level - 1];
          k:=stack[2 * level];
          if vertex_in_path[j] then
            return false;  # We have just travelled around a cycle
          fi;
          # Check whether:
          # 1. We've previously finished with this vertex, OR
          # 2. Whether we've investigated all branches descending from it
          if vertex_complete[j] or k > Length(adj[j]) then
            vertex_complete[j] := true;
            level := level - 1 ;
            if level = 0 then
              break;
            fi;
            # Backtrack and choose next available branch
            stack[2 * level]:=stack[2 * level] + 1;
            vertex_in_path[stack[2 * level - 1]] := false;
          else # Otherwise move onto the next available branch
            vertex_in_path[j] := true;
            level := level + 1;
            stack[2 * level - 1] := adj[j][k];
            stack[2 * level] := 1;
          fi;
        od;
      fi;
    od;
    return true;
  end);
fi;


# Complexity O(number of edges)
# this could probably be improved further ! JDM

InstallMethod(IsSymmetricDigraph, "for a digraph",
[IsDigraph],
function(graph)
  local out, inn, new, i;
 
  out := OutNeighbours(graph);
  inn := InNeighbours(graph);

  if not ForAll(out, IsSortedList) then 
    new := EmptyPlist(Length(out));
    for i in DigraphVertices(graph) do
      new[i] := AsSortedList(ShallowCopy(out[i]));
    od;
    return inn = new;
  fi;

  return inn = out;
end);

# Functional means: for every vertex v there is exactly one edge with source v

InstallMethod(IsFunctionalDigraph, "for a digraph by adjacency",
[IsDigraph and HasOutNeighbours],
function(graph)
  return ForAll(OutNeighbours(graph), x -> Length(x) = 1);
end);

InstallMethod(IsFunctionalDigraph, "for a digraph",
[IsDigraph and HasDigraphSource],
function(graph)
  return DigraphSource(graph) = DigraphVertices(graph);
end);

#

InstallMethod(IsTournament, "for a digraph",
[IsDigraph], 
function(digraph)
  local n;
  
  if IsMultiDigraph(digraph) then
    return false;
  fi;

  n := DigraphNrVertices(digraph);

  if n = 0 then
    return true;
  fi;

  if DigraphNrEdges(digraph) <> n * (n - 1) / 2 then 
    return false;
  fi;

  if DigraphHasLoops(digraph) then
    return false;
  fi;

  if n <= 2 then
    return true;
  fi;

  if HasIsAcyclicDigraph(digraph) and IsAcyclicDigraph(digraph) then 
    return true;
  fi;

  return IsAntisymmetricDigraph(digraph);

end);

#

InstallMethod(IsEmptyDigraph, "for a digraph",
[IsDigraph and HasDigraphSource],
function(digraph)
  return DigraphSource(digraph) = [];
end);

#

InstallMethod(IsEmptyDigraph, "for a digraph",
[IsDigraph and HasOutNeighbours],
function(digraph)
  local adj, e;

  adj := OutNeighbours(digraph);
  for e in adj do
    if not IsEmpty(e) then
      return false;
    fi;
  od;
  return true;
end);

#

InstallMethod(IsEmptyDigraph, "for a digraph with known number of edges",
[IsDigraph and HasDigraphNrEdges], 3,
function(digraph)
  return DigraphNrEdges(digraph) = 0;
end);

#

InstallMethod(IsReflexiveDigraph, "for a digraph with adjacency matrix",
[IsDigraph and HasAdjacencyMatrix], 3,
function(digraph)
  local verts, mat, i;
  
  verts := DigraphVertices(digraph);
  mat := AdjacencyMatrix(digraph);

  for i in verts do
    if mat[i][i] = 0 then
      return false;
    fi;
  od;
  return true;
end);

#

InstallMethod(IsReflexiveDigraph, "for a digraph with out neighbours",
[IsDigraph and HasOutNeighbours],
function(digraph)
  local adj;
  
  adj := OutNeighbours(digraph);
  return ForAll( DigraphVertices(digraph), x -> x in adj[x] );
end);

#

InstallMethod(IsReflexiveDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  local source, range, current, bool, i;
  
  source := DigraphSource(digraph);
  range := DigraphRange(digraph);
  current := 1;

  bool := false;
  for i in [ 1 .. Length(source) ] do
    if source[i] <> current then
      current := current + 1;
      if not bool or source[i] > current then
        return false;
      fi;
      bool := false;
    fi;
    if source[i] = range[i] then
      bool := true;
    fi;
  od;
  return bool;
end);

#

InstallMethod(DigraphHasLoops, "for a digraph with out-neighbours",
[IsDigraph and HasOutNeighbours],
function(digraph)
  local on, i;
  on := OutNeighbours(digraph);
  for i in DigraphVertices(digraph) do
    if i in on[i] then
      return true;
    fi;
  od;
  return false;
end);

#

InstallMethod(DigraphHasLoops, "for a digraph (with only range and source)",
[IsDigraph],
function(digraph)
  local src, rng, i;
  src := DigraphSource(digraph);
  rng := DigraphRange(digraph);
  for i in [ 1 .. Length(src) ] do
    if src[i] = rng[i] then
      return true;
    fi;
  od;
  return false;
end);

#

InstallMethod(IsAperiodicDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  return DigraphPeriod(digraph) = 1;
end);

#

if IsBound(IS_ANTISYMMETRIC_DIGRAPH) then
  InstallMethod(IsAntisymmetricDigraph, "for a digraph",
  [IsDigraph], function(digraph)
    return IS_ANTISYMMETRIC_DIGRAPH(OutNeighbours(digraph));
  end);
else 
  InstallMethod(IsAntisymmetricDigraph, "for a digraph",
  [IsDigraph],
  function(digraph)
    local out, verts, i, x;
    
    out := OutNeighbours(digraph);
    verts := DigraphVertices(digraph);

    for i in verts do
      for x in InNeighboursOfVertex(digraph, i) do
        if x <> i and x in out[i] then
          return false;
        fi;
      od;
    od;
    return true;
  end);
fi;

#

InstallMethod(IsTransitiveDigraph, "for a digraph",
[IsDigraph],
function(digraph)
  local closure, adjmat;

  # I want to be able to do this whole thing in C, so that there is
  # no need to pass things back to GAP, and no need to duplicate work
  # calculating the adjacency matrix
  closure := DIGRAPH_TRANS_CLOSURE(digraph);
  adjmat := AdjacencyMatrix(digraph);
  if closure = adjmat then
    return true;
  else
    return false;
  fi;
end);

#EOF
