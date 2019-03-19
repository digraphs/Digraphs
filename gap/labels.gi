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
    return ShallowCopy(DigraphVertices(D));
end);

InstallMethod(SetDigraphVertexLabel,
"for a digraph, pos int, object",
[IsDigraph, IsPosInt, IsObject],
function(D, v, name)
  if not IsBound(D!.vertexlabels) then
    D!.vertexlabels := [1 .. DigraphNrVertices(D)];
  fi;
  if v > DigraphNrVertices(D) then
    ErrorNoReturn("Digraphs: SetDigraphVertexLabel: usage,\n",
                  "there are only ", DigraphNrVertices(D), " vertices,");
  fi;
  D!.vertexlabels[v] := name;
end);

InstallMethod(DigraphVertexLabel, "for a digraph and pos int",
[IsDigraph, IsPosInt],
function(D, v)
  if not IsBound(D!.vertexlabels) then
    D!.vertexlabels := [1 .. DigraphNrVertices(D)];
  fi;
  if IsBound(D!.vertexlabels[v]) then
    return ShallowCopy(D!.vertexlabels[v]);
  fi;
  ErrorNoReturn("Digraphs: DigraphVertexLabel: usage,\n", v,
                " is nameless or not a vertex,");
end);

InstallMethod(RemoveDigraphVertexLabel, "for a digraph and positive integer",
[IsDigraph, IsPosInt],
function(D, v)
  if not IsBound(D!.vertexlabels) then
    return;
  fi;
  Remove(D!.vertexlabels, v);
end);

InstallMethod(SetDigraphVertexLabels, "for a digraph and list",
[IsDigraph, IsList],
function(D, names)
  if Length(names) <> DigraphNrVertices(D) then
    ErrorNoReturn("Digraphs: SetDigraphVertexLabels: usage,\n",
                  "the 2nd arument <names> must be a list with length equal ",
                  "to the number of\nvertices of the digraph,");
  fi;
  D!.vertexlabels := names;
end);

InstallMethod(DigraphVertexLabels, "for a digraph and pos int",
[IsDigraph],
function(D)
  if not IsBound(D!.vertexlabels) then
    D!.vertexlabels := [1 .. DigraphNrVertices(D)];
  fi;
  return StructuralCopy(D!.vertexlabels);
end);

InstallMethod(SetDigraphEdgeLabel,
"for a digraph, a pos int, a pos int, and an object",
[IsDigraph, IsPosInt, IsPosInt, IsObject],
function(D, v, w, label)
  local p, list;
  if IsMultiDigraph(D) then
    ErrorNoReturn("Digraphs: SetDigraphEdgeLabel: usage,\n",
                  "edge labels are not supported on digraphs with ",
                  "multiple edges,");
  fi;
  p := Position(OutNeighboursOfVertex(D, v), w);
  if p = fail then
    ErrorNoReturn("Digraphs: SetDigraphEdgeLabel:\n",
                  "[", v, ", ", w, "] is not an edge of <D>,");
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
    ErrorNoReturn("Digraphs: DigraphEdgeLabel: usage,\n",
                  "edge labels are not supported on digraphs with ",
                  "multiple edges,");
  fi;
  p := Position(OutNeighboursOfVertex(D, v), w);
  if p = fail then
    ErrorNoReturn("Digraphs: DigraphEdgeLabel:\n",
                  "[", v, ", ", w, "] is not an edge of <D>,");
  fi;
  DIGRAPHS_InitEdgeLabels(D);
  return ShallowCopy(D!.edgelabels[v][p]);
end);

InstallMethod(DigraphEdgeLabelsNC, "for a digraph",
[IsDigraph],
function(D)
  DIGRAPHS_InitEdgeLabels(D);
  return StructuralCopy(D!.edgelabels);
end);

InstallMethod(DigraphEdgeLabels, "for a digraph",
[IsDigraph],
function(D)
  if IsMultiDigraph(D) then
    ErrorNoReturn("Digraphs: DigraphEdgeLabels: usage,\n",
                  "edge labels are not supported on digraphs with ",
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
    ErrorNoReturn("Digraphs: SetDigraphEdgeLabels: usage,\n",
                  "edge labels are not supported on digraphs with ",
                  "multiple edges,");
  fi;

  if Length(labels) <> DigraphNrVertices(D) or
      ForAny(DigraphVertices(D),
             i -> Length(labels[i]) <> OutDegreeOfVertex(D, i)) then
    ErrorNoReturn("Digraphs: SetDigraphEdgeLabels: usage,\n",
                  "the list <labels> has the wrong shape, it is required to ",
                  "have the same shape\nas the return value of ",
                  "OutNeighbours(<D>),");
  fi;
  SetDigraphEdgeLabelsNC(D, labels);
end);

InstallMethod(SetDigraphEdgeLabels, "for a digraph, and a function",
[IsDigraph, IsFunction],
function(D, wtf)
  local adj, i, j;
  if IsMultiDigraph(D) then
    ErrorNoReturn("Digraphs: SetDigraphEdgeLabels: usage,\n",
                  "edge labels are not supported on digraphs with ",
                  "multiple edges,");
  fi;
  DIGRAPHS_InitEdgeLabels(D);
  adj := OutNeighbours(D);
  for i in DigraphVertices(D) do
    for j in [1 .. Length(adj[i])] do
      D!.edgelabels[i][j] := wtf(i, adj[i][j]);
    od;
  od;
end);
