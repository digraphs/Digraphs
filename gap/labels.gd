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
DeclareOperation("ClearDigraphVertexLabels", [IsDigraph]);

# Edge labels
DeclareOperation("DigraphEdgeLabel", [IsDigraph, IsPosInt, IsPosInt]);

DeclareOperation("DigraphEdgeLabelsNC", [IsDigraph]);
DeclareOperation("DigraphEdgeLabels", [IsDigraph]);
DeclareOperation("SetDigraphEdgeLabel",
                 [IsDigraph, IsPosInt, IsPosInt, IsObject]);

DeclareOperation("SetDigraphEdgeLabelsNC", [IsDigraph, IsList]);
DeclareOperation("SetDigraphEdgeLabels", [IsDigraph, IsList]);
DeclareOperation("SetDigraphEdgeLabels", [IsDigraph, IsFunction]);
DeclareOperation("ClearDigraphEdgeLabels", [IsDigraph]);
DeclareOperation("RemoveDigraphEdgeLabel", [IsDigraph, IsPosInt, IsPosInt]);

DeclareOperation("DigraphEdgeLabelAddVertex", [IsDigraph]);
DeclareOperation("DigraphEdgeLabelRemoveVertex", [IsDigraph, IsPosInt]);
