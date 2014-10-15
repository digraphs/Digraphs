#############################################################################
##
#W  grahom.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

#MakeReadWriteGlobal("ListPerm");

#BIND_GLOBAL( "ListPerm", function( arg )
#    local n;
#    if Length(arg)=2 then
#        n := arg[2];
#    else
#        n := LargestMovedPoint(arg[1]);
#    fi;
#    if IsOne(arg[1]) then
#        return [1..n];
#    else
#        return OnTuples( [1..n], arg[1] );
#    fi;
#end );

InstallGlobalFunction(GraphEndomorphismsTrivial,
function(g)
  # g a graph with OutNeighbours information
  local number,result;
  result := [];
  number := GRAPH_HOMOMORPHISMS(OutNeighbours(g), OutNeighbours(g),
                                [],    # this is the initial try
                                Length(OutNeighbours(g)),   # maxdepth
                                fail,  # no further known constraints
                                fail,  # no limit on maxanswers
                                result,   # this is modified
                                false);   # allow non-injective ones
  return result;
end);

ReorderVertices := function(g)
  local ad,l,max,n,new,p,pos,s,val;
  ad := OutNeighbours(g);
  val := List(ad,Length);
  max := Maximum(val);
  pos := Position(val,max);  # this is the first vertex
  n := Length(ad);
  l := [pos];
  s := [pos];
  new := [fail];
  while Length(l) < n do
    if Length(new) = 0 then
      new := Difference([1..n],s){[1]};
    else
      new := Difference(Union(ad{l}),s);
    fi;
    Append(l,new);
    UniteSet(s,new);
  od;
  p := PermList(l);
  return rec( perm := p, verts := l, g := g, 
              newadj := List(ad{l},v->OnTuples(v,p)) );
end;

InstallGlobalFunction(GraphEndomorphisms,
function(g)
  local Dowork,aut,n,result,try;
  Dowork := function(g,try,depth,auts,result)
    # This computes generators for the semigroup of all graph endomorphisms
    # of g which map the first depth-1 points according to the vector try
    # auts is a known subgroup of the automorphism group which fixes
    # the points occurring in try and thus can be used to break symmetry.
    # All resulting generators are appended to the plain list result.
    local ad,d,i,o,s,todo;
    if depth > DigraphNrVertices(g) then
        Add(result,ShallowCopy(try));
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
  Append(result,List(GeneratorsOfGroup(aut),x->ListPerm(x,n)));
  try := EmptyPlist(n);
  Dowork(g,try,1,aut,result);
  return result;
end);

