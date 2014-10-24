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
function(g, n)
  return HomomorphismDigraphs(g, DigraphRemoveLoops(CompleteDigraph(n)));
end);

# formerly GraphEndomorphismsTrivial
InstallMethod(HomomorphismDigraphs, "for digraphs",
[IsDigraph, IsDigraph],
function(g, h)
  # g a graph with OutNeighbours information
  local number,result;
  result := [];
  number := GRAPH_HOMOMORPHISMS(OutNeighbours(g), OutNeighbours(h),
                                [],    # this is the initial try
                                Length(OutNeighbours(g)),   # maxdepth
                                fail,  # no further known constraints
                                fail,  # no limit on maxanswers
                                result,   # this is modified
                                false);   # allow non-injective ones
  return result;
end);

InstallMethod(DigraphEndomorphisms, "for a digraph",
[IsDigraph],
function(g)
  local Dowork,aut,n,result,try;

  if IsMultiDigraph(g) then 
    return fail;
  fi;

  Dowork := function(g,try,depth,auts,result)
    # This computes generators for the semigroup of all graph endomorphisms
    # of g which map the first depth-1 points according to the vector try
    # auts is a known subgroup of the automorphism group which fixes
    # the points occurring in try and thus can be used to break symmetry.
    # All resulting generators are appended to the plain list result.
    local ad,d,i,o,s,todo;
    Print("GAP: at depth ", depth, "\n");
    if depth > DigraphNrVertices(g) then
        Add(result,TransformationNC(try));
        return;
    fi;
    ad := OutNeighbours(g);
    if Size(auts) = 1 then
        GRAPH_HOMOMORPHISMS(ad, ad, try, DigraphNrVertices(g), fail, fail, result, false);
        return;
    fi;

    s := Set(try);
    d := Difference([1..DigraphNrVertices(g)],s);
    o := List(Orbits(auts,d,OnPoints),x->x[1]);
    todo := Intersection(ad[depth],[1..depth-1]);
    if Length(todo) = 0 then
        todo := [1..DigraphNrVertices(g)];
    else
        todo := Intersection(List(todo,x->ad[try[x]]));
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

