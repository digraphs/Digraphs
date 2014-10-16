#############################################################################
##
#W  oper.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# graph algorithms

#

InstallMethod(DigraphFloydWarshall, "for a digraph",
[IsDigraph, IsFunction, IsObject, IsObject],
function(graph, func, nopath, edge)
  local vertices, n, m, dist, out, i, j, k;

  vertices := DigraphVertices(graph);
  n := DigraphNrVertices(graph);
  dist := EmptyPlist(n);

  for i in vertices do
    dist[i] := EmptyPlist(n);
    for j in vertices do 
      dist[i][j] := nopath;
    od;
  od;
  
  if HasDigraphSource(graph) then 
    m := Length(DigraphSource(graph));
    for i in [ 1 .. m ] do
      dist[ DigraphSource(graph)[i] ][ DigraphRange(graph)[i] ] := edge;
    od;
  else
    out := OutNeighbours(graph);
    for i in vertices do 
      for j in out[i] do 
        dist[i][j] := edge;
      od;
    od;
  fi;
  
  for k in vertices do
    for i in vertices do
      for j in vertices do
        func(dist, i, j, k);
      od;
    od;
  od;

  return dist;
end);

#

InstallMethod(DigraphReverse, "for a digraph with source",
[IsDigraph and HasDigraphSource],
function(graph)
  local source, range;

    source := ShallowCopy(DigraphRange(graph));
    range := Permuted(DigraphSource(graph), Sortex(source));

    return DigraphNC(rec( source:=source, 
                                range:=range,
                                nrvertices:=DigraphNrVertices(graph)));
end);

# the following doesn't apply to non-simple digraphs, and so we use
# IsDigraph and HasOutNeighbours

InstallMethod(DigraphReverse, "for a digraph by adjacency",
[IsDigraph and HasOutNeighbours],
function(graph)
  local old, new, i, j;

  old := OutNeighbours(graph);
  new := List(DigraphVertices(graph), x -> []);

  for i in DigraphVertices(graph) do 
    for j in old[i] do 
      Add(new[j], i);
    od;
  od;

  return DigraphNC(new);
end);

#

InstallMethod(DigraphRemoveLoops, "for a digraph with source",
[IsDigraph and HasDigraphSource],
function(graph)
  local source, range, newsource, newrange, nr, i;

  source := DigraphSource(graph);
  range := DigraphRange(graph);

  newsource := [];
  newrange := [];
  nr := 0;

  for i in [ 1 .. Length(source) ] do
    if range[i] <> source[i] then
      nr := nr + 1;
      newrange[nr] := range[i];
      newsource[nr] := source[i];
    fi;
  od;

  return DigraphNC(rec( source := newsource, range := newrange,
                              nrvertices := DigraphNrVertices(graph) ) );
end);

InstallMethod(DigraphRemoveLoops, "for a digraph by adjacency",
[IsDigraph and HasOutNeighbours],
function(graph)
  local old, new, nr, i, j;
  
  old := OutNeighbours(graph);
  new := [];

  for i in DigraphVertices(graph) do 
    new[i] := []; 
    nr := 0;
    for j in old[i] do 
      if i <> j then 
        nr := nr + 1;
        new[i][nr] := j;
      fi;
    od;
  od;

  return DigraphNC(new);
end);

InstallMethod(DigraphRemoveEdges, "for a digraph and a list",
[IsDigraph, IsList],
function(graph, edges)
  local range, nrvertices, source, newsource, newrange, pos, i;

  if Length(edges) > 0 and IsPosInt(edges[1]) then # remove edges by index
    edges := Difference( [ 1 .. Length(DigraphSource(graph)) ], edges );

    return DigraphNC(rec(
      source     := DigraphSource(graph){edges},
      range      := DigraphRange(graph){edges},
      nrvertices := DigraphNrVertices(graph)));
  else
    source := DigraphSource(graph);;
    range := DigraphRange(graph);;
    newsource := [ ];
    newrange := [ ];

    for i in [ 1 .. Length(source) ] do
      pos := Position(edges, [ source[i], range[i] ]); 
      if pos = fail then
        Add(newrange, range[i]);
        Add(newsource, source[i]);
      else 
        Remove(edges, pos);
      fi;
    od;

    return DigraphNC(rec( source := newsource, range := newrange,
                          nrvertices := DigraphNrVertices(graph) ) );
  fi;
end);

InstallMethod(DigraphRelabel, "for a digraph by adjacency and perm",
[IsDigraph and HasOutNeighbours, IsPerm],
function(graph, perm)
  local adj;

  if ForAny(DigraphVertices(graph), i-> i^perm > DigraphNrVertices(graph)) then
    Error("Digraphs: DigraphRelabel: usage,\n",
    "the 2nd argument <perm> must permute the vertices ",
    "of the 1st argument <graph>,\n");
    return;
  fi;
  
  adj := Permuted(OutNeighbours(graph), perm);
  Apply(adj, x-> OnTuples(x, perm));

  return DigraphNC(adj);
end);

InstallMethod(DigraphRelabel, "for a digraph and perm",
[IsDigraph and HasDigraphSource, IsPerm],
function(graph, perm)

  if ForAny(DigraphVertices(graph), i-> i^perm > DigraphNrVertices(graph)) then
    Error("Digraphs: DigraphRelabel: usage,\n",
    "the 2nd argument <perm> must permute the vertices ",
    "of the 1st argument <graph>,\n");
    return;
  fi;
  return DigraphNC(rec(
    source := ShallowCopy(OnTuples(DigraphSource(graph), perm)),
    range:= ShallowCopy(OnTuples(DigraphRange(graph), perm)),
    nrvertices:=DigraphNrVertices(graph)));
end);

#

InstallMethod(DigraphTransitiveClosure, "for a digraph",
[IsDigraph],
function(graph)
  
  if IsMultiDigraph(graph) then
    Error("Digraphs: DigraphTransitiveClosure: usage,\n",
    "the argument <graph> cannot have multiple edges,\n");
    return;
  fi;

  return DigraphTransitiveClosure(graph, false);
end);

#

InstallMethod(DigraphReflexiveTransitiveClosure, "for a digraph",
[IsDigraph],
function(graph)

  if IsMultiDigraph(graph) then
    Error("Digraphs: DigraphReflexiveTransitiveClosure: usage,\n",
    "the argument <graph> cannot have multiple edges,\n");
    return;
  fi;

  return DigraphTransitiveClosure(graph, true); 
end);

#

InstallMethod(DigraphTransitiveClosure, "for a digraph and a record", 
[IsDigraph, IsBool],
function(graph, reflexive)
  local n, vertices, adj, sorted, out, trans, reflex, mat, v, u;

  n := DigraphNrVertices(graph);
  vertices := DigraphVertices(graph);
  adj := OutNeighbours(graph);
  sorted := DigraphTopologicalSort(graph);

  if sorted <> fail then # Easier method for acyclic graphs (loops allowed)
    out := EmptyPlist(n);
    trans := EmptyPlist(n);

    for v in sorted do
      trans[v] := BlistList( vertices, [v]);
      reflex := false;
      for u in adj[v] do
        trans[v] := UnionBlist(trans[v], trans[u]);
        if u = v then
          reflex := true;
        fi;
      od;
      if (not reflexive) and (not reflex) then
        trans[v][v] := false;
      fi;
      out[v] := ListBlist(vertices, trans[v]);
      trans[v][v] := true;
    od;

    out := DigraphNC(out);
    SetIsMultiDigraph(out, false);
    return out;
  else # Non-acyclic: C method
    if reflexive then
      mat := DIGRAPH_REFLEX_TRANS_CLOSURE(graph);
    else
      mat := DIGRAPH_TRANS_CLOSURE(graph);
    fi;
    out := DigraphByAdjacencyMatrixNC(mat);
    SetIsMultiDigraph(out, false);
    return out;
  fi;
end);

#

InstallMethod(InducedSubdigraph, "for a digraph with out neighbours and a list",
[IsDigraph and HasOutNeighbours, IsHomogeneousList],
function( digraph, subverts )
  local n, old, nr, lookup, adj, j, l, i, k, new;

  if IsEmpty(subverts) then
    return DigraphNC( [ ] );
  fi;

  n := DigraphNrVertices(digraph);
  if (IsRange(subverts) and not (IsPosInt(subverts[1]) and subverts[1] <= n and
    subverts[Length(subverts)] <= n))
    or not IsDuplicateFree(subverts)
    or not ForAll( subverts, x -> IsPosInt(x) and x < (n + 1)) then
    Error("Digraphs: InducedSubdigraph: usage,\n",
    "the second argument <subverts> must be a duplicate-free subset\n",
    "of the vertices of the first argument <digraph>,\n");
    return;
  fi;
  
  Sort(subverts);              # Sorting for consistency with Source/Range version
  nr := Length(subverts);
  old := OutNeighbours(digraph);
  new := EmptyPlist(nr);
  lookup := [ 1 .. n ] * 0;
  lookup{subverts} := [ 1 .. nr ];

  for i in [ 1 .. nr ] do 
    adj := [ ];
    j := 0;
    for k in old[ subverts[i] ] do
      l := lookup[k];
      if l <> 0 then
        j := j + 1;
        adj[j] := l;
      fi;
    od;
    new[i] := adj;
  od;

  return DigraphNC(new);
end);

#

InstallMethod(InducedSubdigraph, "for a digraph with digraph source and a list",
[IsDigraph and HasDigraphSource, IsHomogeneousList], 1,
function( digraph, subverts )
  local n, lookup, nr, source, range, news, newr, current, count, source_in, 
  allowed, i;

  if IsEmpty(subverts) then
    return DigraphNC( [ ] );
  fi;

  n := DigraphNrVertices(digraph);
  if (IsRange(subverts) and not (IsPosInt(subverts[1]) and subverts[1] <= n and
    subverts[Length(subverts)] <= n))
    or not IsDuplicateFree(subverts)
    or not ForAll( subverts, x -> IsPosInt(x) and x < (n + 1)) then
    Error("Digraphs: InducedSubdigraph: usage,\n",
    "the second argument <subverts> must be a duplicate-free subset\n",
    "of the vertices of the first argument <digraph>,\n");
    return;
  fi;

  Sort(subverts); # Sorting to ensure new source will be sorted
  lookup := EmptyPlist( n );
  nr := Length(subverts);
  for i in [ 1 .. nr ] do
    lookup[ subverts[i] ] := i;
  od;

  source  := DigraphSource(digraph);
  range   := DigraphRange(digraph);
  news      := [ ];
  newr      := [ ];
  current   := 0;
  count     := 0;
  source_in := false;
  allowed   := BlistList( DigraphVertices(digraph), subverts );

  for i in [ 1 .. Length(source) ] do
    if source[i] <> current then
      current   := source[i];
      source_in := allowed[current];
    fi;
    if source_in and allowed[range[i]] then
      count        := count + 1;
      news[count]  := lookup[current];
      newr[count]  := lookup[range[i]];
    fi;
  od;

  return DigraphNC( rec ( nrvertices := nr, source := news, range := newr ) );

end);

#

InstallMethod(InNeighboursOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(graph, v)
  if not v in DigraphVertices(graph) then
    Error("Digraphs: InNeighboursOfVertex: usage,\n",
          v, " is not a vertex of the digraph,\n");
    return;
  fi;
  return InNeighboursOfVertexNC(graph, v);
end);

InstallMethod(InNeighboursOfVertexNC, "for a digraph and a vertex",
[IsDigraph and HasInNeighbours, IsPosInt], 3,
function(graph, v)
  return InNeighbours(graph)[v];
end);

InstallMethod(InNeighboursOfVertexNC, "for a digraph and a vertex",
[IsDigraph and HasOutNeighbours, IsPosInt],
function(graph, v)
  local inn, pos, out, i, j;

  inn := [];
  pos := 1;
  out := OutNeighbours(graph);
  for i in [ 1 .. Length(out) ] do
    for j in [ 1 .. Length(out[i]) ] do
      if out[i][j] = v then
        inn[pos] := i;
        pos := pos + 1;
      fi;
    od;
  od;
  return inn;
end);

InstallMethod(InNeighboursOfVertexNC, "for a digraph and a vertex",
[IsDigraph and HasDigraphSource, IsPosInt], 1,
function(graph, v)
  local inn, pos, source, range,, i;

  inn := [];
  pos := 1;
  source := DigraphSource(graph);
  range := DigraphRange(graph);
  for i in [ 1 .. Length(range) ] do
    if range[i] = v then
      inn[pos] := source[i];
      pos := pos + 1;
    fi;
  od;
  return inn;
end);

#

InstallMethod(OutNeighboursOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(graph, v)
  if not v in DigraphVertices(graph) then
    Error("Digraphs: OutNeighboursOfVertex: usage,\n",
          v, " is not a vertex of the digraph,\n");
    return;
  fi;
  return OutNeighboursOfVertexNC(graph, v);
end);

InstallMethod(OutNeighboursOfVertexNC, "for a digraph and a vertex",
[IsDigraph and HasOutNeighbours, IsPosInt],
function(graph, v)
  return OutNeighbours(graph)[v];
end);

InstallMethod(OutNeighboursOfVertexNC, "for a digraph and a vertex",
[IsDigraph and HasDigraphSource, IsPosInt], 1,
function(graph, v)
  local out, pos, source, range, m, i;

  out := [];
  pos := 1;
  source := DigraphSource(graph);
  range := DigraphRange(graph);
  m := Length(source);
  i := Position(source, v);
  if i <> fail then
    while i <= m and source[i] = v do
      out[pos] := range[i];
      pos := pos + 1;
      i := i + 1;
    od;
  fi;
  return out;
end);

#

InstallMethod(InDegreeOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(graph, v)
  if not v in DigraphVertices(graph) then
    Error("Digraphs: InDegreeOfVertex: usage,\n",
          v, " is not a vertex of the digraph,\n");
    return;
  fi;
  return InDegreeOfVertexNC(graph, v);
end);

InstallMethod(InDegreeOfVertexNC, "for a digraph and a vertex",
[IsDigraph and HasInDegrees, IsPosInt], 4,
function(graph, v)
  return InDegrees(graph)[v];
end);

InstallMethod(InDegreeOfVertexNC, "for a digraph and a vertex",
[IsDigraph and HasInNeighbours, IsPosInt], 3,
function(graph, v)
  return Length(InNeighbours(graph)[v]);
end);

InstallMethod(InDegreeOfVertexNC, "for a digraph and a vertex",
[IsDigraph and HasOutNeighbours, IsPosInt],
function(graph, v)
  local count, out, i, j;

  count := 0;
  out := OutNeighbours(graph);
  for i in [ 1 .. Length(out) ] do
    for j in [ 1 .. Length(out[i]) ] do
      if out[i][j] = v then
        count := count + 1;
      fi;
    od;
  od;
  return count;
end);

InstallMethod(InDegreeOfVertexNC, "for a digraph and a vertex",
[IsDigraph and HasDigraphSource, IsPosInt],
function(graph, v)
  local range, count, i;

  range := DigraphRange(graph);
  count := 0;
  for i in [ 1 .. Length(range) ] do
    if range[i] = v then
      count := count + 1;
    fi;
  od;
  return count;
end);

#

InstallMethod(OutDegreeOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(graph, v)
  if not v in DigraphVertices(graph) then
    Error("Digraphs: OutDegreeOfVertex: usage,\n",
          v, " is not a vertex of the digraph,\n");
    return;
  fi;
  return OutDegreeOfVertexNC(graph, v);
end);

InstallMethod(OutDegreeOfVertexNC, "for a digraph and a vertex",
[IsDigraph and HasOutDegrees, IsPosInt], 3,
function(graph, v)
  return OutDegrees(graph)[v];
end);

InstallMethod(OutDegreeOfVertexNC, "for a digraph and a vertex",
[IsDigraph and HasOutNeighbours, IsPosInt],
function(graph, v)
  return Length(OutNeighbours(graph)[v]);
end);

InstallMethod(OutDegreeOfVertexNC, "for a digraph and a vertex",
[IsDigraph and HasDigraphSource, IsPosInt], 1,
function(graph, v)
  local count, source, m, i;

  source := DigraphSource(graph);
  m := Length(source);
  i := Position(source, v);
  count := 0;
  if i <> fail then
    while i <= m and source[i] = v do
      i := i + 1;
      count := count + 1;
    od;
  fi;
  return count;
end);

#EOF
