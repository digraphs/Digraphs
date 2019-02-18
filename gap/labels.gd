#############################################################################
##
##  labels.gd
##  Copyright (C) 2019                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareOperation("DigraphVertexLabel", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphVertexLabels", [IsDigraph]);
DeclareOperation("SetDigraphVertexLabel", [IsDigraph, IsPosInt, IsObject]);
DeclareOperation("RemoveDigraphVertexLabel", [IsDigraph, IsPosInt]);
DeclareOperation("SetDigraphVertexLabels", [IsDigraph, IsList]);

# Edge labels
DeclareOperation("DigraphEdgeLabel", [IsDigraph, IsPosInt, IsPosInt]);

DeclareOperation("DigraphEdgeLabelsNC", [IsDigraph]);
DeclareOperation("DigraphEdgeLabels", [IsDigraph]);
DeclareOperation("SetDigraphEdgeLabel",
                 [IsDigraph, IsPosInt, IsPosInt, IsObject]);

DeclareOperation("SetDigraphEdgeLabelsNC", [IsDigraph, IsList]);
DeclareOperation("SetDigraphEdgeLabels", [IsDigraph, IsList]);
DeclareOperation("SetDigraphEdgeLabels", [IsDigraph, IsFunction]);
