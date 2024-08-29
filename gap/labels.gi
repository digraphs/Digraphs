#############################################################################
##
##  labels.gi
##  Copyright (C) 2019                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

BindGlobal("DIGRAPHS_InitEdgeLabels",
function(D)
  if not IsBound(D!.edgelabels) then
    D!.edgelabels := List(OutNeighbours(D),
                          x -> ListWithIdenticalEntries(Length(x), 1));
  fi;
end);

BindGlobal("DIGRAPHS_InitVertexLabels",
function(D)
  if not IsBound(D!.vertexlabels) then
    D!.vertexlabels := [1 .. DigraphNrVertices(D)];
  fi;
end);

InstallMethod(SetDigraphVertexLabel,
"for a digraph, pos int, object",
[IsDigraph, IsPosInt, IsObject],
function(D, v, name)
  DIGRAPHS_InitVertexLabels(D);
  if v > DigraphNrVertices(D) then
    ErrorNoReturn("the 2nd argument <v> is not a vertex",
                  " of the digraph <D> that is the 1st argument,");
  fi;
  D!.vertexlabels[v] := name;
end);

InstallMethod(DigraphVertexLabel, "for a digraph and pos int",
[IsDigraph, IsPosInt],
function(D, v)
  DIGRAPHS_InitVertexLabels(D);
  if IsBound(D!.vertexlabels[v]) then
    return ShallowCopy(D!.vertexlabels[v]);
  fi;
  ErrorNoReturn("the 2nd argument <v> has no label or ",
                "is not a vertex of the digraph <D> that is the 1st argument");
end);

InstallMethod(HaveVertexLabelsBeenAssigned, "for a digraph", [IsDigraph],
D -> IsBound(D!.vertexlabels));

InstallMethod(RemoveDigraphVertexLabel, "for a digraph and positive integer",
[IsDigraph, IsPosInt],
function(D, v)
  DIGRAPHS_InitVertexLabels(D);
  Remove(D!.vertexlabels, v);
end);

InstallMethod(SetDigraphVertexLabels, "for a digraph and list",
[IsDigraph, IsList],
function(D, names)
  if Length(names) <> DigraphNrVertices(D) then
    ErrorNoReturn("the 2nd argument <names> must be a list with length equal ",
                  "to the number of vertices of the digraph <D> that is the ",
                  "1st argument,");
  fi;
  if not IsMutable(names) then
    names := ShallowCopy(names);
  fi;
  D!.vertexlabels := names;
end);

InstallMethod(DigraphVertexLabels, "for a digraph", [IsDigraph],
function(D)
  DIGRAPHS_InitVertexLabels(D);
  return StructuralCopy(D!.vertexlabels);
end);

InstallMethod(ClearDigraphVertexLabels, "for a digraph", [IsDigraph],
function(D)
  Unbind(D!.vertexlabels);
end);

InstallMethod(HaveEdgeLabelsBeenAssigned, "for a digraph", [IsDigraph],
D -> IsBound(D!.edgelabels));

InstallMethod(SetDigraphEdgeLabel,
"for a digraph, a pos int, a pos int, and an object",
[IsDigraph, IsPosInt, IsPosInt, IsObject],
function(D, v, w, label)
  local p, list;
  if IsMultiDigraph(D) then
    ErrorNoReturn("the 1st argument <D> must be a digraph with no multiple ",
                  "edges, edge labels are not supported on digraphs with ",
                  "multiple edges,");
  fi;
  p := Position(OutNeighboursOfVertex(D, v), w);
  if p = fail then
    ErrorNoReturn("there is no edge from ", v, " to ", w,
                  " in the digraph <D> that is the 1st argument,");
  fi;
  DIGRAPHS_InitEdgeLabels(D);
  if not IsBound(D!.edgelabels[v]) then
    list := OutNeighboursOfVertex(D, v);
    D!.edgelabels[v] := ListWithIdenticalEntries(Length(list), 1);
  fi;
  D!.edgelabels[v][p] := ShallowCopy(label);
end);

InstallMethod(DigraphEdgeLabel, "for a digraph, a pos int, and a pos int",
[IsDigraph, IsPosInt, IsPosInt],
function(D, v, w)
  local p;
  if IsMultiDigraph(D) then
    ErrorNoReturn("the 1st argument <D> must be a digraph with no multiple ",
                  "edges, edge labels are not supported on digraphs with ",
                  "multiple edges,");
  fi;
  p := Position(OutNeighboursOfVertex(D, v), w);
  if p = fail then
    ErrorNoReturn("there is no edge from ", v, " to ", w,
                  " in the digraph <D> that is the 1st argument,");
  fi;
  DIGRAPHS_InitEdgeLabels(D);
  return ShallowCopy(D!.edgelabels[v][p]);
end);

InstallMethod(DigraphEdgeLabelsNC, "for a digraph", [IsDigraph],
function(D)
  DIGRAPHS_InitEdgeLabels(D);
  return StructuralCopy(D!.edgelabels);
end);

InstallMethod(DigraphEdgeLabels, "for a digraph",
[IsDigraph],
function(D)
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no multiple ",
                  "edges, edge labels are not supported on digraphs with ",
                  "multiple edges,");
  fi;
  return DigraphEdgeLabelsNC(D);
end);

# markuspf: this is mainly because we do not support edge labels
# on multidigraphs and need the SetDigraphEdgeLabels function
# to fail silently in some places
InstallMethod(SetDigraphEdgeLabelsNC, "for a digraph and a list",
[IsDigraph, IsList],
function(D, labels)
  if not IsMultiDigraph(D) then
    D!.edgelabels := List(labels, ShallowCopy);
  fi;
end);

InstallMethod(SetDigraphEdgeLabels, "for a digraph and a list",
[IsDigraph, IsList],
function(D, labels)
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no multiple ",
                  "edges, edge labels are not supported on digraphs with ",
                  "multiple edges,");
  fi;

  if Length(labels) <> DigraphNrVertices(D) or
      ForAny(DigraphVertices(D),
             i -> Length(labels[i]) <> OutDegreeOfVertex(D, i)) then
    ErrorNoReturn("the 2nd argument <labels> must be a list with ",
                  "the same shape as the out-neighbours of ",
                  "the digraph <D> that is the 1st argument,");
  fi;
  SetDigraphEdgeLabelsNC(D, labels);
end);

InstallMethod(SetDigraphEdgeLabels, "for a digraph, and a function",
[IsDigraph, IsFunction],
function(D, f)
  local adj, i, j;
  if IsMultiDigraph(D) then
    ErrorNoReturn("the argument <D> must be a digraph with no multiple ",
                  "edges, edge labels are not supported on digraphs with ",
                  "multiple edges,");
  fi;
  DIGRAPHS_InitEdgeLabels(D);
  adj := OutNeighbours(D);
  for i in DigraphVertices(D) do
    for j in [1 .. Length(adj[i])] do
      D!.edgelabels[i][j] := f(i, adj[i][j]);
    od;
  od;
end);

InstallMethod(ClearDigraphEdgeLabels, "for a digraph", [IsDigraph],
function(D)
  Unbind(D!.edgelabels);
end);

InstallMethod(RemoveDigraphEdgeLabel,
"for a digraph, positive integer, and positive integer",
[IsDigraph, IsPosInt, IsPosInt],
function(D, v, pos)
  if IsBound(D!.edgelabels) and IsBound(D!.edgelabels[v]) then
    Remove(D!.edgelabels[v], pos);
  fi;
end);
