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

InstallMethod(DirectedGraphReverse, "for a digraph",
[IsDirectedGraph],
function(graph)
  local source, range, old, new, nr, i, j;

  if HasSource(graph) then 
    source := ShallowCopy(Range(graph));
    range := Permuted(Source(graph), Sortex(source));

    return DirectedGraphNC(rec( source:=source, 
                                range:=range,
                                nrvertices:=NrVertices(graph)));
  fi;

  old := Adjacencies(graph);
  new := List(Vertices(graph), x -> []);
  nr := 0;

  for i in Vertices(graph) do 
    for j in old[i] do 
      Add(new[j], i);
    od;
  od;

  return DirectedGraphNC(new);
end);

InstallMethod(DirectedGraphRemoveLoops, "for a digraph",
[IsDirectedGraph],
function(graph)
  local source, range, newsource, newrange, i;

  source := Source(graph);
  range := Range(graph);

  newsource := [];
  newrange := [];

  for i in [ 1 .. Length(source) ] do
    if range[i] <> source[i] then
      Add(newrange, range[i]);
      Add(newsource, source[i]);
    fi;
  od;

  return DirectedGraphNC(rec( source:=newsource, range:=newrange,
                              nrvertices:=NrVertices(graph)));
end);

InstallMethod(DirectedGraphRemoveEdges, "for a digraph and a list",
[IsDirectedGraph, IsList],
function(graph, edges)
  local range, vertices, source, newsource, newrange, i;

  if Length(edges) > 0 and IsPosInt(edges[1]) then # remove edges by index
    edges := Difference( [ 1 .. Length(Source(graph)) ], edges );

    return DirectedGraphNC(rec(
      source := Source(graph){edges},
      range := Range(graph){edges},
      nrvertices := NrVertices(graph)));
  else
    if not IsSimpleDirectedGraph(graph) then
      Error("usage: to remove edges given as pairs of vertices,",
      " the graph must be simple,");
      return;
    fi;
    source := Source(graph);;
    range := Range(graph);;
    newsource := [ ];
    newrange := [ ];

    for i in [ 1 .. Length(source) ] do
      if not [ source[i], range[i] ] in edges then
        Add(newrange, range[i]);
        Add(newsource, source[i]);
      fi;
    od;

    return DirectedGraphNC(rec( source:=newsource, range:=newrange,
                                nrvertices:=NrVertices(graph)));
  fi;
end);

InstallMethod(DirectedGraphRelabel, "for a digraph and perm",
[IsDirectedGraph, IsPerm],
function(graph, perm)

  if ForAny(Vertices(graph), i-> i^perm > NrVertices(graph)) then
    Error("usage: the 2nd argument <perm> must permute ",
    "the vertices of the 1st argument <graph>,");
    return;
  fi;

  return DirectedGraphNC(rec(
    source := ShallowCopy(OnTuples(Source(graph), perm)),
    range:= ShallowCopy(OnTuples(Range(graph), perm)),
    nrvertices:=NrVertices(graph)));
end);


InstallMethod(DirectedGraphFloydWarshall, "for a digraph",
[IsDirectedGraph],
function(graph)
  local dist, i, j, k, n, m;

  # Firstly assuming no multiple edges or loops. Will be easy to include.
  # Also not dealing with graph weightings.
  # Need discussions on suitability of data structures, etc

  n:=NrVertices(graph);
  m:=Length(Edges(graph));
  dist:=List([1..n],x->List([1..n],x->infinity));

  for i in [1..n] do
    dist[i][i]:=0;
  od;

  for i in [1..m] do
    dist[Source(graph)[i]][Range(graph)[i]]:=1;
  od;

  for k in [1..n] do
    for i in [1..n] do
      for j in [1..n] do
        if dist[i][k] <> infinity and dist[k][j] <> infinity and dist[i][j] > dist[i][k] + dist[k][j] then
          dist[i][j]:= dist[i][k] + dist[k][j];
        fi;
      od;
    od;
  od;

  return dist;

end);

# returns the vertices (i.e. numbers) of <digraph> ordered so that there are no
# edges from <out[j]> to <out[i]> for all <i> greater than <j>.


# JDM: requires a method for non-acyclic graphs

InstallMethod(DirectedGraphReflexiveTransitiveClosure,
"for a digraph", [IsDirectedGraph],
function(graph)
  local sorted, vertices, n, adj, out, trans, mat, flip, v, u, w;

  if not IsSimpleDirectedGraph(graph) then
    Error("usage: the argument should be a simple directed graph,");
    return;
  fi;

  vertices := Vertices(graph);
  n := Length(vertices);
  adj := Adjacencies(graph);
  sorted := DirectedGraphTopologicalSort(graph);

  if sorted <> fail then # Easier method for acyclic graphs (loops allowed)
    out := EmptyPlist(n);
    trans := EmptyPlist(n);

    for v in sorted do
      trans[v] := BlistList(vertices, [v]);
      for u in adj[v] do
        trans[v] := UnionBlist(trans[v], trans[u]);
      od;
      out[v] := ListBlist(vertices, trans[v]);
    od;

    out := DirectedGraphNC(out);
    SetIsSimpleDirectedGraph(out, true);
    return out;
  else # Non-acyclic method
    mat := List( vertices, x -> List( vertices, y -> infinity ) ); 

    for v in [ 1 .. n ] do # Make graph reflexive
      mat[v][v] := 1;
    od;

    for v in vertices do # Record edges
      for u in adj[v] do
        mat[v][u] := 1;
      od;
    od;

    for w in vertices do # Variation of Floyd Warshall
      for u in vertices do
        for v in vertices do
          if mat[u][w] <> infinity and mat[w][v] <> infinity then
            mat[u][v] := 1;
          fi;
        od;
      od;
    od;

    flip:=function(x)
      if x = infinity then
        return 0;
      else
        return 1;
      fi;
    end;

    mat := List( mat, x -> List( x, flip ) ); # Create adjacency matrix
    out := DirectedGraphByAdjacencyMatrix(mat);
    SetIsSimpleDirectedGraph(out, true);
    return out;
  fi;
end);

# JDM: requires a method for non-acyclic graphs

InstallMethod(DirectedGraphTransitiveClosure, "for a digraph",
[IsDirectedGraph],
function(graph)
  local sorted, vertices, n, adj, out, trans, reflex, mat, flip, v, u, w;

  if not IsSimpleDirectedGraph(graph) then
    Error("usage: the argument should be a simple directed graph,");
    return;
  fi;

  vertices := Vertices(graph);
  n := Length(vertices);
  adj := Adjacencies(graph);
  sorted := DirectedGraphTopologicalSort(graph);

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
      if not reflex then
        trans[v][v] := false;
      fi;
      out[v] := ListBlist(vertices, trans[v]);
      trans[v][v] := true;
    od;

    out := DirectedGraphNC(out);
    SetIsSimpleDirectedGraph(out, true);
    return out;
  else # Non-acyclic method

    mat := List( vertices, x -> List( vertices, y -> infinity ) ); 
    reflex := [ 1 .. n ] * 0;
    
    for v in vertices do # Assume graph reflexive for now
      mat[v][v] := 1;
    od;

    for v in vertices do # Record edges and remember loops
      for u in adj[v] do
        mat[v][u] := 1;
        if u = v then
          reflex[v] := 1;
        fi;
      od;
    od;

    for w in vertices do # Variation of Floyd Warshall
      for u in vertices do
        for v in vertices do
          if mat[u][w] <> infinity and mat[w][v] <> infinity then
            mat[u][v] := 1;
          fi;
        od;
      od;
    od;

    flip:=function(x)
      if x = infinity then
        return 0;
      else
        return 1;
      fi;
    end;

    mat := List( mat, x -> List( x, flip ) ); # Create adjacency matrix
    for v in vertices do # Only include original loops
      mat[v][v] := reflex[v]; 
    od;
    out := DirectedGraphByAdjacencyMatrix(mat);
    SetIsSimpleDirectedGraph(out, true);
    return out;
  fi;
end);

# the scc index 1 corresponds to the "deepest" scc, i.e. the minimal ideal in
# our case...

if IsBound(GABOW_SCC) then
  InstallMethod(StronglyConnectedComponents, "for a directed graph",
  [IsDirectedGraph],
  function(digraph)
    return GABOW_SCC(Adjacencies(digraph));
  end);
else
  InstallMethod(StronglyConnectedComponents, "for a directed graph",
  [IsDirectedGraph],
  function(digraph)
    local n, stack1, len1, stack2, len2, id, count, comps, fptr, level, l, comp, w, v;

    digraph := Adjacencies(digraph);
    n := Length(digraph);

    if n = 0 then
      return rec( comps := [], id := []);
    fi;

    stack1 := EmptyPlist(n); len1 := 0;
    stack2 := EmptyPlist(n); len2 := 0;
    id := [ 1 .. n ] * 0;
    count := Length(digraph);
    comps := [];
    fptr := [];

    for v in [ 1 .. Length(digraph) ] do
      if id[v] = 0 then
        level := 1;
        fptr[1] := v; #fptr[0], vertex
        fptr[2] := 1; #fptr[2], index
        len1 := len1 + 1;
        stack1[len1] := v;
        len2 := len2 + 1;
        stack2[len2] := len1;
        id[v] := len1;

        while level > 0 do
          if fptr[ 2 * level] > Length(digraph[fptr[2 * level - 1]]) then
            if stack2[len2]=id[fptr[2 * level - 1]] then
              len2 := len2 - 1;
              count := count + 1;
              l := 0;
              comp := [];
              repeat
                w := stack1[len1];
                id[w] := count;
                len1 := len1 - 1; #pop from stack1
                l := l + 1;
                comp[l] := w;
              until w = fptr[2 * level - 1];
              ShrinkAllocationPlist(comp);
              MakeImmutable(comp);
              Add(comps, comp);
            fi;
            level := level - 1;
          else
            w := digraph[fptr[2 * level - 1]][fptr[2 * level]];
            fptr[2 * level] := fptr[2 * level] + 1;

            if id[w] = 0 then
              level := level + 1;
              fptr[2 * level - 1 ] := w; #fptr[0], vertex
              fptr[2 * level] := 1;   #fptr[2], index
              len1 := len1 + 1;
              stack1[len1] := w;
              len2 := len2 + 1;
              stack2[len2] := len1;
              id[w] := len1;

            else # we saw <w> earlier in this run
              while stack2[len2] > id[w] do
                len2 := len2 - 1; # pop from stack2
              od;
            fi;
          fi;
        od;
      fi;
    od;

    MakeImmutable(id);
    ShrinkAllocationPlist(comps);
    MakeImmutable(comps);
    return rec(id := id - Length(digraph), comps := comps);
  end);
fi;
