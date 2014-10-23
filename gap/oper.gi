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

#

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

InstallMethod(DigraphReverseEdge, "for a digraph and an edge",
[IsDigraph and HasDigraphSource, IsList],
function(digraph, edge)
  local edge_src, edge_rng, source, range, i;

  if IsMultiDigraph(digraph) then
    Error("Digraphs: DigraphReverseEdge: usage,\n",
    "the first argument <digraph> must not be a multigraph,");
    return;
  fi;

  if not IsDigraphEdge(digraph, edge) then
    Error("Digraphs: DigraphReverseEdge: usage,\n",
    "the second argument <edge> must be an edge of <digraph>,");
    return;
  fi;
 
  edge_src := edge[1];
  edge_rng := edge[2];
  source := ShallowCopy(DigraphSource(digraph));
  range := ShallowCopy(DigraphRange(digraph));
  
  for i in [ 1 .. Length(source) ] do
    if source[i] = edge_src and range[i] = edge_rng then
      # swap source[i] and range[i]
      source[i] := range[i] + source[i]; 
      range[i] := source[i] - range[i];
      source[i] := source[i] - range[i];
      break;
    fi;
  od;

  range := Permuted(range, Sortex(source));
  return DigraphNC(rec( source:=source, 
                        range:=range,
                        nrvertices:=DigraphNrVertices(digraph)));
end);

#

InstallMethod(DigraphReverseEdge, "for a digraph and an edge",
[IsDigraph and HasOutNeighbours, IsList],
function(digraph, edge)
  local edge_src, edge_rng, out, new, i;

  if IsMultiDigraph(digraph) then
    Error("Digraphs: DigraphReverseEdge: usage,\n",
    "the first argument <digraph> must not be a multigraph,");
    return;
  fi;

  if not IsDigraphEdge(digraph, edge) then
    Error("Digraphs: DigraphReverseEdge: usage,\n",
    "the second argument <edge> must be an edge of <digraph>,");
    return;
  fi;
 
  edge_src := edge[1];
  edge_rng := edge[2];

  out := OutNeighbours(digraph);
  new := [];
  for i in [ 1 .. Length(DigraphVertices(digraph)) ] do
    if i = edge_src then
      new[i] := ShallowCopy(out[i]);
      Remove(new[i], Position(new[i], edge_rng));
    else
      new[i] := ShallowCopy(out[i]);
    fi;
  od;
  Add(new[edge_rng], edge_src);

  return DigraphNC(new);
end);

#

InstallMethod(DigraphRemoveLoops, "for a digraph with source",
[IsDigraph and HasDigraphSource],
function(graph)
  local source, range, newsource, newrange, nr, out, i;

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

  out := DigraphNC(rec( source := newsource, range := newrange,
                        nrvertices := DigraphNrVertices(graph) ) );
  SetDigraphHasLoops(out, false);
  return out;
end);

InstallMethod(DigraphRemoveLoops, "for a digraph by adjacency",
[IsDigraph and HasOutNeighbours],
function(graph)
  local old, new, nr, out, i, j;
  
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

  out := DigraphNC(new);
  SetDigraphHasLoops(out, false);
  return out;
end);

#

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
    if IsMultiDigraph(graph) then
      Error("Digraphs: DigraphRemoveEdges: usage,\n",
      "the first argument <graph> must not have multiple edges\n",
      "when the second argument <edges> is a list of edges,");
      return;
    fi;
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

#

InstallMethod(DigraphAddEdge, "for a digraph and an edge",
[IsDigraph, IsList],
function(digraph, edge)
  local verts;

  verts := DigraphVertices(digraph);
  if Length(edge) <> 2
    or not IsPosInt(edge[1])
    or not IsPosInt(edge[2])
    or not edge[1] in verts
    or not edge[2] in verts then
    Error("Digraphs: DigraphAddEdge: usage,\n",
          "the second argument <edge> must be a pair of vertices of ",
          "<digraph>,");
    return;
  fi;

  return DigraphAddEdgesNC(digraph, [ edge ]);
end);

InstallMethod(DigraphAddEdges, "for a digraph and a list",
[IsDigraph, IsList],
function(digraph, edges)
  local vertices, newsource, newrange, m, edge;

  if not IsEmpty(edges) and
   (not IsList(edges[1])
    or not Length(edges[1]) = 2 
    or not IsPosInt(edges[1][1]) 
    or not IsRectangularTable(edges)) then
    Error("Digraphs: DigraphAddEdges: usage,\n",
          "the second argument <edges> must be a list of pairs of vertices\n",
          "of the first argument <digraph>,");
    return;
  fi;

  vertices := DigraphVertices(digraph);
  for edge in edges do
    if not (edge[1] in vertices and edge[2] in vertices) then
      Error("Digraphs: DigraphAddEdges: usage,\n",
          "the second argument <edges> must be a list of pairs of vertices\n",
          "of the first argument <digraph>,");
      return;
    fi;
  od;

  return DigraphAddEdgesNC(digraph, edges);
end);

InstallMethod(DigraphAddEdgesNC, "for a digraph and a list",
[IsDigraph, IsList],
function(digraph, edges)
  local newsource, newrange, m, edge;

  newsource := ShallowCopy(DigraphSource(digraph));
  newrange  := ShallowCopy(DigraphRange(digraph));
  m := Length(newsource);
  for edge in edges do
    m := m + 1;
    newsource[m] := edge[1];
    newrange[m] := edge[2];
  od;

  newrange := Permuted(newrange, Sortex(newsource));
  return DigraphNC(rec( source     := newsource,
                        range      := newrange,
                        nrvertices := DigraphNrVertices(digraph) ) );
end);

#

InstallMethod(OnDigraphs, "for a digraph by adjacency and perm",
[IsDigraph and HasOutNeighbours, IsPerm],
function(graph, perm)
  local adj;

  if ForAny(DigraphVertices(graph), i-> i^perm > DigraphNrVertices(graph)) then
    Error("Digraphs: OnDigraphs: usage,\n",
    "the 2nd argument <perm> must permute the vertices ",
    "of the 1st argument <graph>,");
    return;
  fi;
  
  adj := Permuted(OutNeighbours(graph), perm);
  Apply(adj, x-> OnTuples(x, perm));

  return DigraphNC(adj);
end);

InstallMethod(OnDigraphs, "for a digraph and perm",
[IsDigraph and HasDigraphRange, IsPerm],
function(graph, perm)
  local source, range;

  if ForAny(DigraphVertices(graph), i-> i^perm > DigraphNrVertices(graph)) then
    Error("Digraphs: OnDigraphs: usage,\n",
    "the 2nd argument <perm> must permute the vertices ",
    "of the 1st argument <graph>,");
    return;
  fi;
  source := ShallowCopy(OnTuples(DigraphSource(graph), perm));
  range := ShallowCopy(OnTuples(DigraphRange(graph), perm));
  range := Permuted(range, Sortex(source));
  return DigraphNC(rec(
    source := source,
    range := range,
    nrvertices:=DigraphNrVertices(graph)));
end);

#

InstallMethod(DigraphSymmetricClosure, "for a digraph",
[IsDigraph],
function(graph)
  Error("Digraphs: DigraphSymmetricClosure, not yet implemented,");
end);

#

InstallMethod(DigraphTransitiveClosure, "for a digraph",
[IsDigraph],
function(graph)
  
  if IsMultiDigraph(graph) then
    Error("Digraphs: DigraphTransitiveClosure: usage,\n",
    "the argument <graph> cannot have multiple edges,");
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
    "the argument <graph> cannot have multiple edges,");
    return;
  fi;

  return DigraphTransitiveClosure(graph, true); 
end);

#

InstallMethod(DigraphTransitiveClosure, "for a digraph and a boolean", 
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
  else # Non-acyclic: C method
    if reflexive then
      mat := DIGRAPH_REFLEX_TRANS_CLOSURE(graph);
    else
      mat := DIGRAPH_TRANS_CLOSURE(graph);
    fi;
    out := DigraphByAdjacencyMatrixNC(mat);
  fi;
  SetIsMultiDigraph(out, false);
  SetIsTransitiveDigraph(out, true);
  return out;
end);

#

InstallMethod(InducedSubdigraph, 
"for a digraph with out neighbours and a homogeneous list",
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
    "of the vertices of the first argument <digraph>,");
    return;
  fi;
  
  Sort(subverts); # Sorting for consistency with Source/Range version
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
  
  new := DigraphNC(new);
  SetDigraphVertexNames(new, DigraphVertexNames(digraph){subverts});
  return new;
end);

#

InstallMethod(InducedSubdigraph, "for a digraph with digraph source and a list",
[IsDigraph and HasDigraphSource, IsHomogeneousList], 1,
function( digraph, subverts )
  local n, lookup, nr, source, range, news, newr, current, count, source_in,
  allowed, new, i;

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
    "of the vertices of the first argument <digraph>,");
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

  new := DigraphNC( rec ( nrvertices := nr, source := news, range := newr ) );
  SetDigraphVertexNames(new, DigraphVertexNames(digraph){subverts});
  return new;

end);

#

InstallMethod(InNeighborsOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  return InNeighboursOfVertex(digraph, v);
end);

InstallMethod(InNeighboursOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  if not v in DigraphVertices(digraph) then
    Error("Digraphs: InNeighboursOfVertex: usage,\n",
          "the second argument <v> is not a vertex of the first, <digraph>,");
    return;
  fi;
  return InNeighboursOfVertexNC(digraph, v);
end);

InstallMethod(InNeighboursOfVertexNC, "for a digraph with in-neighbours and a vertex",
[IsDigraph and HasInNeighbours, IsPosInt], 3,
function(digraph, v)
  return InNeighbours(digraph)[v];
end);

InstallMethod(InNeighboursOfVertexNC, "for a digraph with out-neighbours and a vertex",
[IsDigraph and HasOutNeighbours, IsPosInt],
function(digraph, v)
  local inn, pos, out, i, j;

  inn := [];
  pos := 1;
  out := OutNeighbours(digraph);
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

InstallMethod(InNeighboursOfVertexNC, "for a digraph with range/source and a vertex",
[IsDigraph and HasDigraphRange, IsPosInt], 1,
function(digraph, v)
  local inn, pos, source, range, i;

  inn := [];
  pos := 1;
  source := DigraphSource(digraph);
  range := DigraphRange(digraph);
  for i in [ 1 .. Length(range) ] do
    if range[i] = v then
      inn[pos] := source[i];
      pos := pos + 1;
    fi;
  od;
  return inn;
end);

#

InstallMethod(OutNeighborsOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  return OutNeighboursOfVertex(digraph, v);
end);

InstallMethod(OutNeighboursOfVertex, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  if not v in DigraphVertices(digraph) then
    Error("Digraphs: OutNeighboursOfVertex: usage,\n",
          "the second argument <v> is not a vertex of the first, <digraph>,");
    return;
  fi;
  return OutNeighboursOfVertexNC(digraph, v);
end);

InstallMethod(OutNeighboursOfVertexNC, "for a digraph with out-neighbours and a vertex",
[IsDigraph and HasOutNeighbours, IsPosInt],
function(digraph, v)
  return OutNeighbours(digraph)[v];
end);

InstallMethod(OutNeighboursOfVertexNC, "for a digraph with only source/range and a vertex",
[IsDigraph and HasDigraphRange, IsPosInt], 1,
function(digraph, v)
  local out, pos, source, range, m, i;

  out := [];
  pos := 1;
  source := DigraphSource(digraph);
  range := DigraphRange(digraph);
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
function(digraph, v)
  if not v in DigraphVertices(digraph) then
    Error("Digraphs: InDegreeOfVertex: usage,\n",
          "the second argument <v> is not a vertex of the first, <digraph>,");
    return;
  fi;
  return InDegreeOfVertexNC(digraph, v);
end);

InstallMethod(InDegreeOfVertexNC, "for a digraph with in-degrees and a vertex",
[IsDigraph and HasInDegrees, IsPosInt], 4,
function(digraph, v)
  return InDegrees(digraph)[v];
end);

InstallMethod(InDegreeOfVertexNC, "for a digraph with in-neighbours and a vertex",
[IsDigraph and HasInNeighbours, IsPosInt], 3,
function(digraph, v)
  return Length(InNeighbours(digraph)[v]);
end);

InstallMethod(InDegreeOfVertexNC, "for a digraph with out-neighbours and a vertex",
[IsDigraph and HasOutNeighbours, IsPosInt],
function(digraph, v)
  local count, out, x, i;

  count := 0;
  out := OutNeighbours(digraph);
  for x in out do
    for i in x do
      if i = v then
        count := count + 1;
      fi;
    od;
  od;
  return count;
end);

InstallMethod(InDegreeOfVertexNC, "for a digraph (with only source/range) and a vertex",
[IsDigraph and HasDigraphRange, IsPosInt],
function(digraph, v)
  local range, count, i;

  range := DigraphRange(digraph);
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
function(digraph, v)
  if not v in DigraphVertices(digraph) then
    Error("Digraphs: OutDegreeOfVertex: usage,\n",
          "the second argument <v> is not a vertex of the first, <digraph>,");
    return;
  fi;
   return OutDegreeOfVertexNC(digraph, v);
end);

InstallMethod(OutDegreeOfVertexNC, "for a digraph with out-degrees and a vertex",
[IsDigraph and HasOutDegrees, IsPosInt], 3,
function(digraph, v)
  return OutDegrees(digraph)[v];
end);

InstallMethod(OutDegreeOfVertexNC, "for a digraph with out-neighbours and a vertex",
[IsDigraph and HasOutNeighbours, IsPosInt],
function(digraph, v)
  return Length(OutNeighbours(digraph)[v]);
end);

InstallMethod(OutDegreeOfVertexNC, "for a digraph with source/range and a vertex",
[IsDigraph and HasDigraphSource, IsPosInt], 1,
function(digraph, v)
  local count, source, m, i;

  source := DigraphSource(digraph);
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

#

InstallMethod(QuotientDigraph, "for a digraph and a homogeneous list",
[IsDigraph, IsHomogeneousList],
function(digraph, partition)
  local n, nr, check, lookup, out, new, gr, source, range, m, newsource,
  newrange, x, i, j;

  n := DigraphNrVertices(digraph);
  if n = 0 and IsEmpty(partition) then
    return EmptyDigraph(0);
  elif n = 0 then
    Error("Digraphs: QuotientDigraph: usage,\n",
          "the second argument <partition> is not a valid partition of the\n",
          "vertices of the null digraph <digraph>. The only valid partition\n",
          "of <digraph> is the empty list,");
    return;
  fi;
  nr := Length(partition);
  if n = 0 or
   nr = 0 or
   not IsList(partition[1]) or
   IsEmpty(partition[1]) or
   not IsPosInt(partition[1][1]) then
    Error("Digraphs: QuotientDigraph: usage,\n",
          "the second argument <partition> is not a valid partition\n",
          "of the vertices of <digraph>, [ 1 .. ", n, " ],");
    return;
  fi;

  check := BlistList( DigraphVertices(digraph), [  ] );
  lookup := EmptyPlist(n);
  
  for x in [ 1 .. Length(partition) ] do
    for i in partition[x] do
      if i < 1 or i > n or check[i]  then
        Error("Digraphs: QuotientDigraph: usage,\n",
          "the second argument <partition> is not a valid partition\n",
          "of the vertices of <digraph>, [ 1 .. ", n, " ],");
        return;
      fi;
      check[i] := true;
      lookup[i] := x;
    od;
  od;
  
  if ForAny( check, x -> not x ) then
    Error("Digraphs: QuotientDigraph: usage,\n",
          "the second argument <partition> does not partition\n",
          "every vertex of the first argument, <digraph>,");
    return;
  fi;

  if HasOutNeighbours(digraph) then
    out := OutNeighbours(digraph);
    new := List( [ 1 .. nr ], x -> [ ] );
    for i in DigraphVertices(digraph) do
      for j in out[i] do
        Add(new[lookup[i]], lookup[j]);
      od;
    od;
    gr := DigraphNC(new);
  elif HasDigraphRange(digraph) then
    source := DigraphSource(digraph);
    range := DigraphRange(digraph);
    m := Length(source);
    newsource := EmptyPlist(m);
    newrange := EmptyPlist(m);
    for i in [ 1 .. m ] do
      newsource[i] := lookup[source[i]];
      newrange[i] := lookup[range[i]];
    od;
    newrange := Permuted(newrange, Sortex(newsource));
    gr := DigraphNC( rec( nrvertices := nr,
                          source     := newsource,
                          range      := newrange ) );
  fi;

  # Pass on information about <digraph> which might be relevant to gr?
  return gr;
end);

#

InstallMethod(DigraphOutEdges, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  if not v in DigraphVertices(digraph) then
    Error("Digraphs: DigraphOutEdges: usage,\n",
          v, " is not a vertex of the digraph,");
    return;
  fi;

  return List(OutNeighboursOfVertex(digraph, v), x -> [v, x]);
end);

#

InstallMethod(DigraphInEdges, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  if not v in DigraphVertices(digraph) then
    Error("Digraphs: DigraphInEdges: usage,\n",
          v, " is not a vertex of the digraph,");
    return;
  fi;

  return List(InNeighboursOfVertex(digraph, v), x -> [x, v]);
end);

#

InstallMethod(DigraphStronglyConnectedComponent, "for a digraph and a vertex",
[IsDigraph, IsPosInt],
function(digraph, v)
  local scc;

  if not v in DigraphVertices(digraph) then
    Error("Digraphs: DigraphStronglyConnectedComponent: usage,\n",
          v, " is not a vertex of the digraph,");
    return;
  fi;

  scc := DigraphStronglyConnectedComponents(digraph);
  return scc.comps[scc.id[v]];
end);

#

InstallMethod(IsDigraphEdge, "for a digraph with out-neighbours and a list",
[IsDigraph and HasOutNeighbours, IsList], 1,
function(digraph, edge)
  local n;

  n := DigraphNrVertices(digraph);
  if Length(edge) <> 2 or
   not IsPosInt(edge[1]) or
   not IsPosInt(edge[2]) or
   n < edge[1] or
   n < edge[2] then
    return false;
  elif edge[2] in OutNeighboursOfVertex(digraph, edge[1]) then
    return true;
  fi;
  return false;
end);

#

InstallMethod(IsDigraphEdge, "for a digraph and a list",
[IsDigraph and HasDigraphRange, IsList],
function(digraph, edge)
  local edge_src, edge_rng, n, source, range, pos, i;

  if Length(edge) <> 2 then
    return false;
  fi;

  edge_src := edge[1];
  edge_rng := edge[2];
  n := DigraphNrVertices(digraph);

  if not IsPosInt(edge_src) or
   not IsPosInt(edge_rng) or
   n < edge_src or
   n < edge_rng then
    return false;
  fi;

  source := DigraphSource(digraph);
  range := DigraphRange(digraph);
  pos := PositionSorted(source, edge_src);
  if pos <> fail then
    for i in [ pos .. Length(source) ] do
      if source[i] = edge_src and range[i] = edge_rng then
        return true;
      elif source[i] > edge_src then
        return false;
      fi;
    od;
  fi;
  return false;
end);

#

InstallMethod(AsBinaryRelation, "for a digraph",
[IsDigraph],
function(digraph)
  if DigraphNrVertices(digraph) = 0 then
    Error("Digraphs: AsBinaryRelation: usage,\n",
          "the argument <digraph> must have at least one vertex,");
    return;
  elif IsMultiDigraph(digraph) then
    Error("Digraphs: AsBinaryRelation: usage,\n",
          "this function does not apply to digraphs with multiple edges,");
    return;
  fi;
  # Can translate known attributes of <digraph> to the relation, e.g. symmetry
  return BinaryRelationOnPointsNC(OutNeighbours(digraph));
end);

#EOF
