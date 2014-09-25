#############################################################################
##
#W  attrs.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# attributes for directed graphs . . .

InstallMethod(AdjacencyMatrix, "for a directed graph",
[IsDirectedGraph], 
function(graph)
  local n, out, verts, adj, source, range, i;
  
  n := Length(Vertices(graph));
  out := EmptyPlist(n);
  verts := [ 1 .. n ];

  if HasIsSimpleDirectedGraph(graph) and HasAdjacencies(graph) then 
    adj := Adjacencies(graph);
    for i in verts do 
      out[i] := verts * 0;
      out[i]{adj[i]} := ( [1 .. Length(adj[i])] * 0 ) + 1;
    od;
    return out;
  fi;
  
  source := Source(graph);
  range := Range(graph);

  out := EmptyPlist(n);
  
  for i in verts do 
    out[i] := verts * 0;
  od;
  
  for i in [1..Length(source)] do 
    out[source[i]][range[i]] := out[source[i]][range[i]] + 1;
  od;
  
  return out;  
end);
