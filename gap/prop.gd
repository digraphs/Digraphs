#############################################################################
##
#W  props.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareProperty("IsSimpleDirectedGraph", IsDirectedGraph);
DeclareProperty("IsUndirectedGraph", IsDirectedGraph);
DeclareProperty("IsFunctionalDirectedGraph", IsDirectedGraph);
DeclareProperty("IsStronglyConnectedDirectedGraph", IsDirectedGraph);
DeclareProperty("IsAcyclicDirectedGraph", IsDirectedGraph);
DeclareProperty("IsTournament", IsDirectedGraph);

InstallTrueMethod(IsSimpleDirectedGraph, IsUndirectedGraph);
