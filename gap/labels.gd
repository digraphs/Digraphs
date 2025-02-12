#############################################################################
##
##  labels.gd
##  Copyright (C) 2019                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

##  Vertex labels

#  Get vertex labels
DeclareOperation("DigraphVertexLabel", [IsDigraph, IsPosInt]);
DeclareOperation("DigraphVertexLabels", [IsDigraph]);
DeclareOperation("HaveVertexLabelsBeenAssigned", [IsDigraph]);

#  Set vertex labels
DeclareOperation("SetDigraphVertexLabel", [IsDigraph, IsPosInt, IsObject]);
DeclareOperation("SetDigraphVertexLabels", [IsDigraph, IsList]);

#  Unset vertex labels
#  TODO document these two operations
DeclareOperation("RemoveDigraphVertexLabel", [IsDigraph, IsPosInt]);
DeclareOperation("ClearDigraphVertexLabels", [IsDigraph]);

##  Edge labels

#  Get edge labels
DeclareOperation("DigraphEdgeLabel", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("DigraphEdgeLabels", [IsDigraph]);
DeclareOperation("DigraphEdgeLabelsNC", [IsDigraph]);
DeclareOperation("HaveEdgeLabelsBeenAssigned", [IsDigraph]);

#  Set edge labels
DeclareOperation("SetDigraphEdgeLabel",
                 [IsDigraph, IsPosInt, IsPosInt, IsObject]);
DeclareOperation("SetDigraphEdgeLabels", [IsDigraph, IsFunction]);
DeclareOperation("SetDigraphEdgeLabels", [IsDigraph, IsList]);
DeclareOperation("SetDigraphEdgeLabelsNC", [IsDigraph, IsList]);

#  Unset edge labels
#  TODO document these two operations
DeclareOperation("RemoveDigraphEdgeLabel", [IsDigraph, IsPosInt, IsPosInt]);
DeclareOperation("ClearDigraphEdgeLabels", [IsDigraph]);
