#############################################################################
##
#W  attrs.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallMethod(DigraphDual, "for a digraph", 
[IsDigraph], 
function(digraph)
  local verts, old, new, gr, i;
  
  if IsMultiDigraph(digraph) then 
    Error("Graphs: DigraphDual: usage,\n", 
      "the argument <graph> must not have multiple edges,");
    return;
  fi;
  
  verts := DigraphVertices(digraph);
  old := OutNeighbours(digraph);
  new := [  ];

  for i in verts do 
    new[i] := DifferenceLists(verts, old[i]);
  od;
  gr := DigraphNC(new);
  SetDigraphVertexLabels(gr, DigraphVertexLabels(digraph));
  return gr;
end);

#

InstallMethod(DigraphNrVertices, "for a digraph",
[IsDigraph],
function(graph)
  return graph!.nrvertices;
end);

#

InstallMethod(DigraphNrEdges, "for a digraph",
[IsDigraph], DIGRAPH_NREDGES);

#

InstallMethod(DigraphEdges, "for a digraph",
[IsDigraph],
function(graph)
  local out, adj, nr, i, j;

  out := EmptyPlist(DigraphNrEdges(graph));
  adj := OutNeighbours(graph);
  nr := 0;
  
  for i in DigraphVertices(graph) do 
    for j in adj[i] do 
      nr := nr + 1;
      out[nr] := [ i, j ];
    od;
  od;
  return out;   
end);

# attributes for digraphs . . .

InstallMethod(AsGraph, "for a digraph", [IsDigraph], Graph);

#

InstallMethod(DigraphVertices, "for a digraph",
[IsDigraph],
function(digraph)
  return [ 1 .. DigraphNrVertices(digraph) ];
end);

InstallMethod(DigraphRange, "for a digraph",
[IsDigraph],
function(digraph)
  DIGRAPH_SOURCE_RANGE(digraph);
  SetDigraphSource(digraph, digraph!.source);
  return digraph!.range;
end);

InstallMethod(DigraphSource, "for a digraph",
[IsDigraph],
function(digraph)
  DIGRAPH_SOURCE_RANGE(digraph);
  SetDigraphRange(digraph, digraph!.range);
  return digraph!.source;
end);

#

InstallMethod(OutNeighbours, "for a digraph",
[IsDigraph],
function(digraph)
  local out;
  if IsBound(digraph!.adj) then
    return digraph!.adj;
  fi;
  out := DIGRAPH_OUT_NBS(DigraphNrVertices(digraph),
                         DigraphSource(digraph),
                         DigraphRange(digraph));
  digraph!.adj := out;
  return out;
end);

InstallMethod(OutNeighbors, "for a digraph", [IsDigraph], OutNeighbours);

InstallImmediateMethod(OutNeighbors, "for a digraph", HasOutNeighbours, 0,
OutNeighbours);

InstallImmediateMethod(OutNeighbours, "for a digraph", HasOutNeighbors, 0,
OutNeighbors);

#

InstallMethod(InNeighbours, "for a digraph",
[IsDigraph],
function(digraph)
  return DIGRAPH_IN_OUT_NBS(OutNeighbours(digraph));
end);

InstallMethod(InNeighbors, "for a digraph", [IsDigraph], InNeighbours);

InstallImmediateMethod(InNeighbors, "for a digraph", HasInNeighbours, 0,
InNeighbours);

InstallImmediateMethod(InNeighbours, "for a digraph", HasInNeighbors, 0,
InNeighbors);

#

InstallMethod(AdjacencyMatrix, "for a digraph",
[IsDigraph], ADJACENCY_MATRIX);

#

InstallMethod(DigraphShortestDistances, "for a digraph",
[IsDigraph], DIGRAPH_SHORTEST_DIST);

# returns the vertices (i.e. numbers) of <digraph> ordered so that there are no
# edges from <out[j]> to <out[i]> for all <i> greater than <j>.

InstallMethod(DigraphTopologicalSort, "for a digraph",
[IsDigraph], function(graph)
  return DIGRAPH_TOPO_SORT(OutNeighbours(graph));
end);

# 

InstallMethod(DigraphStronglyConnectedComponents, "for a digraph",
[IsDigraph],
function(digraph)
  local verts;
  
  if HasIsAcyclicDigraph(digraph) and IsAcyclicDigraph(digraph) then
    verts := DigraphVertices(digraph);
    return rec( comps := List( verts, x -> [ x ] ), id := verts * 1 );

  elif HasIsStronglyConnectedDigraph(digraph)
   and IsStronglyConnectedDigraph(digraph) then
    verts := DigraphVertices(digraph);
    return rec( comps := [ verts * 1 ], id := verts * 0 + 1 );
  fi;

  return GABOW_SCC(OutNeighbours(digraph));
end);

#

InstallMethod(DigraphConnectedComponents, "for a digraph",
[IsDigraph],
DIGRAPH_CONNECTED_COMPONENTS);

#

InstallMethod(OutDegrees, "for a digraph",
[IsDigraph],
function(digraph)
  local adj, degs, i;
  
  adj := OutNeighbours(digraph);
  degs := EmptyPlist(  DigraphNrVertices(digraph) );
  for i in DigraphVertices(digraph) do
    degs[i] := Length(adj[i]);
  od;
  return degs;
end);

#

InstallMethod(InDegrees, "for a digraph with in neighbours",
[IsDigraph and HasInNeighbours], 
function(digraph)
  local inn, degs, i;
  
  inn := InNeighbours(digraph);
  degs := EmptyPlist( DigraphNrVertices(digraph) );
  for i in DigraphVertices(digraph) do
    degs[i] := Length(inn[i]);
  od;
  return degs;
end);

#

InstallMethod(InDegrees, "for a digraph",
[IsDigraph],
function(digraph)
  local adj, degs, x, i;
  
  adj := OutNeighbours(digraph);
  degs := [ 1 .. DigraphNrVertices(digraph)] * 0;
  for x in adj do
    for i in x do
      degs[i] := degs[i] + 1;
    od;
  od;
  return degs;
end);

#

InstallMethod(OutDegreeSequence, "for a digraph",
[IsDigraph],
function(digraph)
  local out;

  out := ShallowCopy(OutDegrees(digraph));
  Sort(out, function(a,b) return b < a; end);
  return out;
end);

#

InstallMethod(InDegreeSequence, "for a digraph",
[IsDigraph],
function(digraph)
  local out;

  out := ShallowCopy(InDegrees(digraph));
  Sort(out, function(a,b) return b < a; end);
  return out;
end);

#

InstallMethod(DigraphSources, "for a digraph with in-degrees",
[IsDigraph and HasInDegrees], 3,
function(digraph)
  local degs;

  degs := InDegrees(digraph);
  return Filtered( DigraphVertices(digraph), x -> degs[x] = 0 );
end);

InstallMethod(DigraphSources, "for a digraph with in-neighbours",
[IsDigraph and HasInNeighbours],
function(digraph)
  local inn, sources, count, i;

  inn := InNeighbours(digraph);
  sources := EmptyPlist( DigraphNrVertices(digraph) );
  count := 0;
  for i in DigraphVertices(digraph) do
    if IsEmpty(inn[i]) then
      count := count + 1;
      sources[count] := i;
    fi;
  od;
  ShrinkAllocationPlist(sources);
  return sources;
end);

InstallMethod(DigraphSources, "for a digraph",
[IsDigraph],
function(digraph)
  local verts, out, seen, v, i;

  verts := DigraphVertices(digraph);
  out := OutNeighbours(digraph);
  seen := BlistList( verts, [  ] );
  for v in out do
    for i in v do
      seen[i] := true;
    od;
  od;
  return Filtered( verts, x -> not seen[x] );
end);

#

InstallMethod(DigraphSinks, "for a digraph with out-degrees",
[IsDigraph and HasOutDegrees],
function(digraph)
  local degs;

  degs := OutDegrees(digraph);
  return Filtered( DigraphVertices(digraph), x -> degs[x] = 0 );
end);

InstallMethod(DigraphSinks, "for a digraph",
[IsDigraph],
function(digraph)
  local out, sinks, count, i;

  out   := OutNeighbours(digraph);
  sinks := [  ];
  count := 0;
  for i in DigraphVertices(digraph) do
    if IsEmpty(out[i]) then
      count := count + 1;
      sinks[count] := i;
    fi;
  od;
  return sinks;
end);

#

InstallMethod(DigraphPeriod, "for a digraph",
[IsDigraph],
function(digraph)
  local comps, out, deg, nrvisited, period, current, stack, len, depth,
  olddepth, i;

  if HasIsAcyclicDigraph(digraph) and IsAcyclicDigraph(digraph) then
    return 0;
  fi;

  comps := DigraphStronglyConnectedComponents(digraph)!.comps;
  out := OutNeighbours(digraph);
  deg := OutDegrees(digraph);

  nrvisited := [ 1 .. Length(DigraphVertices(digraph)) ] * 0;
  period := 0;

  for i in [ 1 .. Length(comps) ] do
    stack := [comps[i][1]];
    len := 1;
    depth := EmptyPlist(Length(DigraphVertices(digraph)));
    depth[comps[i][1]] := 1;
    while len <> 0 do
      current := stack[len];
      if nrvisited[current] = deg[current] then
        len := len - 1;
      else
        nrvisited[current] := nrvisited[current] + 1;
        len := len + 1;
        stack[len] := out[current][nrvisited[current]];
        olddepth := depth[current];
        if IsBound(depth[stack[len]]) then
          period := GcdInt(period, depth[stack[len]] - olddepth - 1);
          if period = 1 then
            return period;
          fi;
        else
          depth[stack[len]] := olddepth + 1;
        fi;
      fi;
    od;
  od;

  if period = 0 then
    SetIsAcyclicDigraph(digraph, true);
  fi;

  return period;
end);

#

InstallMethod(DigraphDiameter, "for a digraph",
[IsDigraph],
function(digraph)
  if DigraphNrVertices(digraph) = 0 then
    return -1;
  elif HasIsStronglyConnectedDigraph(digraph)
   and not IsStronglyConnectedDigraph(digraph) then
    return -1;
  fi;
  return DIGRAPH_DIAMETER(digraph);
end);

#EOF
