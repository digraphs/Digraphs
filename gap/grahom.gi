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
  GRAPH_HOMOMORPHISMS(OutNeighbours(g), OutNeighbours(h),
                                [],       # this is the initial try
                                n,        # maxdepth
                                fail,     # no further known constraints
                                fail,     # no limit on maxanswers
                                result,   # this is modified
                                false);   # allow non-injective ones
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
  GRAPH_HOMOMORPHISMS(OutNeighbours(digraph1), OutNeighbours(digraph2),
                                [],       # this is the initial try
                                n,        # maxdepth
                                fail,     # no further known constraints
                                1,        # no limit on maxanswers
                                result,   # this is modified
                                false);   # allow non-injective ones
  if IsEmpty(result) then
    return fail;
  else
    return result[1]; 
  fi;
end);

InstallMethod(DigraphEndomorphisms, "for a digraph",
[IsDigraph],
function(g)
   local DigraphVerticesWithLoops, Dowork, n, aut, result, try;

  if IsMultiDigraph(g) then 
    Error("Digraphs: DigraphEndomorphisms: usage,\n",
    "the argument <digraph> must not be a multigraph,");
    return;
  fi;

  DigraphVerticesWithLoops := function(digraph)
    local out, output, len, i;

    out := OutNeighbours(digraph);
    output := [];
    len := 1;
    for i in [1 .. DigraphNrVertices(digraph)] do
      if i in out[i] then
	output[len] := i;
	len := len + 1;
      fi;
    od;
    return output;
  end;


  Dowork := function(g,try,depth,auts,result)
    local out, inn, loops, s, d, o, todoo, todoi, todo, i;
    # This computes generators for the semigroup of all graph endomorphisms
    # of g which map the first depth-1 points according to the vector try
    # auts is a known subgroup of the automorphism group which fixes
    # the points occurring in try and thus can be used to break symmetry.
    # All resulting generators are appended to the plain list result.
    Print("GAP: at depth ", depth, "\n");
    if depth > DigraphNrVertices(g) then
        Add(result,TransformationNC(try));
        return;
    fi;
    out := OutNeighbours(g);
    inn := InNeighbours(g);
    loops := DigraphVerticesWithLoops(g);
    if Size(auts) = 1 then
        GRAPH_HOMOMORPHISMS(out, out, try, DigraphNrVertices(g), fail, fail, result, false);
        return;
    fi;

    s := Set(try);
    d := Difference([1..DigraphNrVertices(g)],s);
    o := List(Orbits(auts,d,OnPoints),x->x[1]);
    todoo := Intersection(out[depth],[1..depth - 1]);
    todoi := Intersection(inn[depth],[1..depth - 1]);
    if Length(todoo) = 0 and Length(todoi) = 0 then
      if depth in loops then
        todo := loops;
      else
        todo := Difference([1 .. DigraphNrVertices(g)], loops);
      fi;
    else
      todoo := List(todoo, x -> out[try[x]]);
      todoi := List(todoi, x -> inn[try[x]]);
      todo := Intersection(todoo, todoi);
    fi;
    for i in Intersection(todo,o) do
        try[depth] := i;
        Dowork(g,try,depth+1,Stabilizer(auts,i),result);
        Unbind(try[depth]);
    od;
    for i in Intersection(todo,s) do
        try[depth] := i;
        Dowork(g,try,depth+1,auts,result);
        Unbind(try[depth]);
    od;
  end;

	
  n := DigraphNrVertices(g);
  aut := AutomorphismGroup(g);
  result := EmptyPlist(100000);
  Append(result,List(GeneratorsOfGroup(aut),AsTransformation));
  try := EmptyPlist(n);
  Dowork(g,try,1,aut,result);
  return result; 
end);

InstallMethod(EndomorphismMonoid, "for a digraph",
[IsDigraph],
function(digraph)
  if IsMultiDigraph(digraph) then 
    Error("Digraphs: EndomorphismMonoid: usage,\n",
    "the argument <digraph> must not be a multigraph,");
    return;
  fi;
  if IsSemigroupsLoaded() then 
    return Monoid(DigraphEndomorphisms(digraph), rec(small := true));
  else
    return Monoid(DigraphEndomorphisms(digraph));
  fi; 
 
end);

SearchForEndomorphisms:=function(map, condition, neighbours, S, limit, G, depth)
  local nr, x, min, pos, todo, vals, pts, reps, i, j;
  
  #Print(map,condition,"\n");
  nr := Length(condition[1]);
  if depth = nr then 
    x :=  Transformation(List(condition, x-> ListBlist([1..nr], x)[1]));
    S[1] := ClosureSemigroup(S[1], x); 
    max := Maximum(max, RankOfTransformation(x,
    DegreeOfTransformationSemigroup(S[1])));

    #Add(result, Transformation(List(condition, x-> ListBlist([1..nr], x)[1])));
    Print("found ", Size(S[1]), ", ", Length(Generators(S[1])), 
    " generators, max rank is ", max, "\n");
    return;
  fi;
  
  if Size(S[1]) >= limit then 
    return;
  fi;

  #Print("at depth: ", Length(map), "\n");
  condition:=StructuralCopy(condition);

  for i in [1..Length(map)] do
    if IsBound(map[i]) then 
      for j in ListBlist([1..nr], neighbours[i]) do
        INTER_BLIST(condition[j], neighbours[map[i]]);
        if SIZE_BLIST(condition[j]) = 0 then 
          return;
        fi;
      od;
    fi;
  od;

  for i in [ 1 .. nr ] do
    if IsBound(map[i]) then
      condition[i]:=BlistList([1..nr], [map[i]]);
    fi;
  od;

  min := Length(neighbours) + 1;
  pos := 0;

  for i in [ 1 .. nr ] do 
    if (not IsBound(map[i])) and SizeBlist(condition[i]) < min then
      min := SizeBlist(condition[i]);
      pos := i;
    fi;
  od;
  
  todo := condition[pos];
  vals := BlistList([1..nr], map);
  pts := [1..nr];
  SubtractSet(pts, Set(map));
  reps := BlistList([1..nr], ORBIT_REPS_PERMS(GeneratorsOfGroup(G), pts));
  #reps2 := BlistList([1..nr], List(Orbits(G, Difference([1..nr], Set(map)), OnPoints), x -> x[1]));
  
  for i in [1..nr] do 
    if todo[i] then 
      map[pos] := i;
      if vals[i] then 
        SearchForEndomorphisms(map, condition, neighbours, S, limit, G, depth + 1);
      elif reps[i] then 
        SearchForEndomorphisms(map, condition, neighbours, S, limit, 
         Stabilizer(G, i), depth + 1);
      fi;
      Unbind(map[pos]);
    fi;
  od;

  return;
end;

GraphEndomorphisms := function(digraph, limit)
  local S, nr, nbs;
  
  S := [AsTransformationSemigroup(AutomorphismGroup(digraph))];
  nr := DigraphNrVertices(digraph);
  nbs := List(OutNeighbours(digraph), x -> BlistList([ 1 .. nr ], x));
  SearchForEndomorphisms([], List([ 1 .. nr ], x -> BlistList([ 1 .. nr ], 
  [ 1 .. nr ])), nbs, S, limit, AutomorphismGroup(digraph), 0);
  return S;
end;

IsEndomorphism:=function(digraph,t)
  local o;
  o:=DigraphEdges(digraph);
  return IsSubset(o,OnSetsTuples(o,t));
end;
