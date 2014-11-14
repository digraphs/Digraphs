

SearchForEndomorphisms:=function(map, condition, neighbours, result, limit)
  local nr, min, pos, i, j;
  
  if Length(result) = limit then 
    return;
  fi;
  #Print("at depth: ", Length(map), "\n");
  condition:=StructuralCopy(condition);
  nr := Length(condition[1]);

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
  #Print(map,condition,"\n");
  if ForAll(condition, x-> SizeBlist(x) = 1) then 
    Add(result, Transformation(List(condition, x-> ListBlist([1..nr], x)[1])));
    Print("found ", Length(result), "\n");
    if RankOfTransformation(result[Length(result)], 153) = 7 then 
      Error();
    fi;
    return;
  fi;

  min := Length(neighbours) + 1;
  pos := 0;

  for i in [ 1 .. nr ] do 
    if (not IsBound(map[i])) and SizeBlist(condition[i]) < min then
      min := SizeBlist(condition[i]);
      pos := i;
    fi;
  od;
  map := ShallowCopy(map);
  for i in ListBlist([1..nr], condition[pos]) do
     map[pos] := i;
    SearchForEndomorphisms(map, condition, neighbours, result, limit);
  od;
  return;
end;

GraphEndomorphisms := function(digraph, limit)
  local result, nr, nbs;

  result := [];
  nr := DigraphNrVertices(digraph);
  nbs := List(OutNeighbours(digraph), x -> BlistList([ 1 .. nr ], x));
  SearchForEndomorphisms([], List([ 1 .. nr ], x -> BlistList([ 1 .. nr ], 
  [ 1 .. nr ])), nbs, result, limit);
  return result;
end;

endocandidate:=function(digraph,t)
  local o;
  o:=DigraphEdges(digraph);
  return IsSubset(o,OnSetsTuples(o,t));
end;

