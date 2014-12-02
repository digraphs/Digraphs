#############################################################################
##
#W  grahom.gi
#Y  Copyright (C) 2014                                     Max Nuenhoeffer
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallMethod(DigraphColoring, "for a digraph and pos int",
[IsDigraph, IsPosInt],
function(digraph, n)
  if IsMultiDigraph(digraph) then 
    Error("Digraphs: DigraphColoring: usage,\n",
    "the argument <digraph> must not be a  multigraph,");
    return;
  fi;
  return DigraphHomomorphism(digraph, CompleteDigraph(n)); 
end);

# formerly GraphEndomorphismsTrivial
InstallMethod(HomomorphismDigraphs, "for digraphs",
[IsDigraph, IsDigraph],
function(g, h)
  local n, result;
  
  if IsMultiDigraph(g) or IsMultiDigraph(h) then 
    Error("Digraphs: HomomorphismDigraphs: usage,\n",
    "the arguments must not be multigraphs,");
    return;
  fi;

  n := DigraphNrVertices(g);
  result := [];
 # GRAPH_HOMOMORPHISMS(OutNeighbours(g), OutNeighbours(h),
 #                               [],       # this is the initial try
 #                               n,        # maxdepth
 #                               fail,     # no further known constraints
 #                              fail,     # no limit on maxanswers
 #                               result,   # this is modified
 #                               false);   # allow non-injective ones
  return result; 
end);

InstallMethod(DigraphHomomorphism, "for digraphs",
[IsDigraph, IsDigraph],
function(digraph1, digraph2)
  local n, result;

  if IsMultiDigraph(digraph1) or IsMultiDigraph(digraph2) then 
    Error("Digraphs: DigraphHomomorphism: usage,\n",
    "the arguments must not be multigraphs,");
    return;
  fi;

  n := DigraphNrVertices(digraph1);
  result := [];
  #GRAPH_HOMOMORPHISMS(OutNeighbours(digraph1), OutNeighbours(digraph2),
  #                              [],       # this is the initial try
  #                              n,        # maxdepth
  #                              fail,     # no further known constraints
  #                              1,        # no limit on maxanswers
  #                              result,   # this is modified
  #                              false);   # allow non-injective ones
  if IsEmpty(result) then
    return fail;
  else
    return result[1]; 
  fi;
end);

#InstallMethod(DigraphEndomorphisms, "for a digraph",
#[IsDigraph],
#function(g)
#   local DigraphVerticesWithLoops, Dowork, n, aut, result, try;
#
#  if IsMultiDigraph(g) then 
#    Error("Digraphs: DigraphEndomorphisms: usage,\n",
#    "the argument <digraph> must not be a multigraph,");
#    return;
#  fi;
#
#  DigraphVerticesWithLoops := function(digraph)
#    local out, output, len, i;
#
#    out := OutNeighbours(digraph);
#    output := [];
#    len := 1;
#    for i in [1 .. DigraphNrVertices(digraph)] do
#      if i in out[i] then
#	output[len] := i;
#	len := len + 1;
#      fi;
#    od;
#    return output;
#  end;
#
#
#  Dowork := function(g,try,depth,auts,result)
#    local out, inn, loops, s, d, o, todoo, todoi, todo, i;
#    # This computes generators for the semigroup of all graph endomorphisms
#    # of g which map the first depth-1 points according to the vector try
#    # auts is a known subgroup of the automorphism group which fixes
#    # the points occurring in try and thus can be used to break symmetry.
#    # All resulting generators are appended to the plain list result.
#    Print("GAP: at depth ", depth, "\n");
#    if depth > DigraphNrVertices(g) then
#        Add(result,TransformationNC(try));
#        return;
#    fi;
#    out := OutNeighbours(g);
#    inn := InNeighbours(g);
#    loops := DigraphVerticesWithLoops(g);
#    if Size(auts) = 1 then
#        GRAPH_HOMOMORPHISMS(out, out, try, DigraphNrVertices(g), fail, fail, result, false);
#        return;
#    fi;
#
#    s := Set(try);
#    d := Difference([1..DigraphNrVertices(g)],s);
#    o := List(Orbits(auts,d,OnPoints),x->x[1]);
#    todoo := Intersection(out[depth],[1..depth - 1]);
#    todoi := Intersection(inn[depth],[1..depth - 1]);
#    if Length(todoo) = 0 and Length(todoi) = 0 then
#      if depth in loops then
#        todo := loops;
#      else
#        todo := Difference([1 .. DigraphNrVertices(g)], loops);
#      fi;
#    else
#      todoo := List(todoo, x -> out[try[x]]);
#      todoi := List(todoi, x -> inn[try[x]]);
#      todo := Intersection(todoo, todoi);
#    fi;
#    for i in Intersection(todo,o) do
#        try[depth] := i;
#        Dowork(g,try,depth+1,Stabilizer(auts,i),result);
#        Unbind(try[depth]);
#    od;
#    for i in Intersection(todo,s) do
#        try[depth] := i;
#        Dowork(g,try,depth+1,auts,result);
#        Unbind(try[depth]);
#    od;
#  end;
#
#	
#  n := DigraphNrVertices(g);
#  aut := AutomorphismGroup(g);
#  result := EmptyPlist(100000);
#  Append(result,List(GeneratorsOfGroup(aut),AsTransformation));
#  try := EmptyPlist(n);
#  Dowork(g,try,1,aut,result);
#  return result; 
#end);

SearchForEndomorphisms:=function(nr, map, condition, neighbours, results, limit, G,
depth, pos, vals, reps)
  local x, r, nbs, min, todo, pts, j, i;
  
  if depth = nr then 
    x :=  TransformationNC(map);
    Add(results, x);
    Print(map, "\n");
    return;
  fi;
  
  if Size(results) >= limit then 
    return;
  fi;

  condition:=StructuralCopy(condition);
  
  if pos <> 0 then 
    nbs := neighbours[pos];
    for j in [ 1 .. nr] do
      if nbs[j] and not IsBound(map[j]) then 
        INTER_BLIST(condition[j], neighbours[map[pos]]);
        if SIZE_BLIST(condition[j]) = 0 then 
          return;
        fi;
      fi;
    od;
  fi;

  min := Length(neighbours) + 1;
  pos := 0;

  for i in [ 1 .. nr ] do 
    if (not IsBound(map[i])) and SizeBlist(condition[i]) < min then
      min := SizeBlist(condition[i]);
      pos := i;
    fi;
  od;
  
  todo := condition[pos];
  pts := [1..nr];
  SubtractSet(pts, Set(map));
  if reps = fail then 
    reps := BlistList([1..nr], List(Orbits(G, pts), x-> x[1]));
  fi;
  
  for i in [1..nr] do 
    if todo[i] and reps[i] and not vals[i] then 
      map[pos] := i;
      vals[i] := true;
      SearchForEndomorphisms(nr, map, condition, neighbours, results, limit, 
       Stabilizer(G, i), depth + 1, pos, vals, fail);
      Unbind(map[pos]);
      vals[i] := false;
    fi;
  od;
  
  for i in [1..nr] do 
    if todo[i] and vals[i] then 
      map[pos] := i;
      SearchForEndomorphisms(nr, map, condition, neighbours, results, limit, 
       Stabilizer(G, i), depth + 1, pos, vals, reps);
      Unbind(map[pos]);
    fi;
  od;

  return;
end;

# make this an attribute

InstallMethod(GeneratorsOfEndomorphismMonoidAttr, "for a digraph",
[IsDigraph], 
function(digraph)
  return GeneratorsOfEndomorphismMonoid(digraph);
end);

InstallGlobalFunction(GeneratorsOfEndomorphismMonoid, 
function(arg)
  local digraph, limit, nr, STAB, gens, out, nbs, results;

  digraph := arg[1];

  if HasGeneratorsOfEndomorphismMonoidAttr(digraph) then 
    return GeneratorsOfEndomorphismMonoidAttr(digraph);
  fi;
  
  if not (IsDigraph(digraph) and IsSymmetricDigraph(digraph)) then 
    Error("not yet implemented");
  fi;

  if IsBound(arg[2]) and (IsPosInt(arg[2]) or arg[2] = infinity) then 
    limit := arg[2];
  else 
    limit := infinity;
  fi;

  nr := DigraphNrVertices(digraph);
  
  if nr <= 512 then
    STAB := function(gens, pt)
      if gens = [] then 
        return [];
      fi;
      return GeneratorsOfGroup(Stabilizer(Group(gens), pt));
    end;
    gens := List(GeneratorsOfGroup(AutomorphismGroup(digraph)), AsTransformation);
    if limit = infinity then 
      limit := fail;
    else 
      limit := limit - Length(gens);
    fi;

    if limit <= 0 then 
      return gens;
    fi;
    out := GRAPH_HOMOS(digraph, digraph, fail, gens, limit, fail, false, STAB);
    if limit = infinity then # if limit = fail TODO
      SetGeneratorsOfEndomorphismMonoidAttr(digraph, out);
    fi;
    return out;
  fi;
  
  nbs := List(OutNeighbours(digraph), x -> BlistList([ 1 .. nr ], x));
  results := [];
  SearchForEndomorphisms(nr, [], List([ 1 .. nr ], x -> BlistList([ 1 .. nr ], 
  [ 1 .. nr ])), nbs, results, limit, AutomorphismGroup(digraph), 0, 0, 
  BlistList( [ 1 .. nr ], [] ), fail);
  return results ;
end);

## Finds a single homomorphism of highest rank from graph1 to graph2
InstallMethod(HomomorphismGraphs, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local nr1, nr2, STAB, out;
  
  if not (IsSymmetricDigraph(gr1) and IsSymmetricDigraph(gr2)) then 
    Error("not yet implemented");
  fi;

  nr1 := DigraphNrVertices(gr1);
  nr2 := DigraphNrVertices(gr2);
  
  if nr1 <= 512 and nr2 <= 512 then
    STAB:= function(gens, pt)
      if gens = [] then 
        return fail;
      fi;
      return GeneratorsOfGroup(Stabilizer(Group(gens), pt));
    end;
    out := GRAPH_HOMOS(gr1, gr2, fail, fail, 1, nr2, false, STAB);
    if IsEmpty(out) then
      return fail;
    else
      return out[1];
    fi;
  else 
    Error("not yet implemented");
    return;
  fi;
end);

## Finds a set S of homomorphism from graph1 to graph2 such that every homomorphism
## between the two graphs can expressed as a composition of an element in S
## and an automorphism of graph2.
InstallMethod(HomomorphismGraphsRepresetatives, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2) 
  local nr1, nr2, STAB, out;

  if not (IsSymmetricDigraph(gr1) and IsSymmetricDigraph(gr2)) then 
    Error("not yet implemented");
  fi;

  nr1 := DigraphNrVertices(gr1);
  nr2 := DigraphNrVertices(gr2);

  if nr1 <= 512 and nr2 <= 512 then
    STAB:= function(gens, pt)
      if gens = [] then 
        return fail;
      fi;
      return GeneratorsOfGroup(Stabilizer(Group(gens), pt));
    end;
    out := GRAPH_HOMOS(gr1, gr2, fail, fail, fail, nr2, false, STAB);
    return out;
  else 
    Error("not yet implemented");
    return;
  fi;
end);

## Wrapper for C function GRAPH_HOMOS
InstallGlobalFunction(HomomorphismGraphsFinder, 
function(gr1, gr2, hook, user_param, limit, hint, isinjective) 
  local nr1, nr2, STAB, out;

  if not (IsDigraph(gr1) and IsDigraph(gr2) and IsSymmetricDigraph(gr1)
    and IsSymmetricDigraph(gr2)) then 
    Error("not yet implemented");
  fi;

  if hook <> fail and not IsFunction(hook) then
    Error("Digraphs: HomomorphismGraphsFinder: usage,\n",
          "<hook> has to be a function,");
    return;
  fi;

  if limit = infinity then
    limit := fail;
  elif limit <> fail and not IsPosInt(limit) then
    Error("Digraphs: HomomorphismGraphsFinder: usage,\n",
          "<limit> has to be a positive integer or infinity,");
    return;
  fi;

  if hint = infinity then
    hint := fail;
  elif hint <> fail and not IsPosInt(hint) then
    Error("Digraphs: HomomorphismGraphsFinder: usage,\n",
          "<hint> has to be a positive integer or infinity,");
    return;
  fi;

  if not IsBool(isinjective) then
    Error("Digraphs: HomomorphismGraphsFinder: usage,\n",
          "<isinjective> has to be a bool,");
    return;
  fi;
  
  nr1 := DigraphNrVertices(gr1);
  nr2 := DigraphNrVertices(gr2);

  if nr1 <= 512 and nr2 <= 512 then
    STAB:= function(gens, pt)
      if gens = [] then 
        return fail;
      fi;
      return GeneratorsOfGroup(Stabilizer(Group(gens), pt));
    end;
    out := GRAPH_HOMOS(gr1, gr2, hook, user_param, limit, hint, isinjective, STAB);
    return out;
  else 
    Error("not yet implemented");
    return;
  fi;
end);


## Finds a single embedding of graph1 into graph2
InstallMethod(MonomorphismGraphs, "for a digraph and a digraph",
[IsDigraph, IsDigraph],
function(gr1, gr2)
  local nr1, nr2, STAB, out;
  
  if not (IsSymmetricDigraph(gr1) and IsSymmetricDigraph(gr2)) then 
    Error("not yet implemented");
  fi;

  nr1 := DigraphNrVertices(gr1);
  nr2 := DigraphNrVertices(gr2);
  
  # if nr1 = nr2 then
  #   return IsomorphismDigraphs(gr1, gr2);
  # fi;
  if nr1 <= 512 and nr2 <= 512 then
    STAB:= function(gens, pt)
      if gens = [] then 
        return fail;
      fi;
      return GeneratorsOfGroup(Stabilizer(Group(gens), pt));
    end;
    out := GRAPH_HOMOS(gr1, gr2, fail, fail, 1, nr2, true, STAB);
    if IsEmpty(out) then
      return fail;
    else
      return out[1];
    fi;
  else 
    Error("not yet implemented");
    return;
  fi; 
end);

#IsEndomorphism:=function(digraph,t)
#  local o;
#  o:=DigraphEdges(digraph);
#  return IsSubset(o,OnSetsTuples(o,t));
#end;

ReorderVertices := function(graph)
  local out, degs, max, pos, nr, l, s, new, p;

  out := OutNeighbours(graph); 
  degs := OutDegrees(graph);
  max := Maximum(degs);
  pos := Position(degs, max);  # this is the first vertex
  nr := DigraphNrVertices(graph);
  l := [pos];
  s := [pos];
  new := [fail];
  while Length(l) < nr do
    if Length(new) = 0 then
      new := Difference([1..nr],s){[1]};
    else
      new := Difference(Union(out{l}),s);
    fi;
    Append(l,new);
    UniteSet(s,new);
  od;
  p := PermList(l);
  return rec( perm := p, verts := l, graph := graph,
              newadj := List(out{l},v->OnTuples(v,p)) );

end;

# Choose vertices with higher degree first
ReorderVertices2 := function(graph)
  local out, degs, nr, l, s, choices, newdegs, max, pos, p, i;

  out := OutNeighbours(graph); 
  degs := OutDegrees(graph);
  nr := DigraphNrVertices(graph);
  l := [];
  s := [];
  choices := [];
 # i'th position gives the number of edges to already defined part of graph
  newdegs := [1 .. nr] * 0;
  while Length(l) < nr do
    if Length(choices) = 0 then # new connected component
      choices := Difference([1..nr],s);
      max := Maximum(degs{choices});
      pos := Position(degs, max); 
    else
      choices := Difference(Union(out{l}),s);
      max := 0;
      pos := 0;
      for i in choices do
        if newdegs[i] > max then
          max := newdegs[i];
          pos := i;
        fi;
      od;
    fi;
    Add(l,pos);
    UniteSet(s,[pos]);
    for i in out[pos] do
      newdegs[i] := newdegs[i] + 1;
    od;
  od;
  p := PermList(l);
  return rec( perm := p, verts := l, graph := graph,
              newadj := List(out{l},v->OnTuples(v,p)) );

end;
