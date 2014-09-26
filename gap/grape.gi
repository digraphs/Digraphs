#############################################################################
##
#W  grape.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# methods using Grape . . . 

InstallMethod(IsIsomorphicDirectedGraph, "for digraphs",
[IsDirectedGraph, IsDirectedGraph],
function(g1, g2)
  if IsSimpleDirectedGraph(g1) and IsSimpleDirectedGraph(g2) then 
    return IsIsomorphicGraph( GrapeGraph(g1), GrapeGraph(g2) );
  fi;
  Error("not yet implemented,");
  return;
end);

#

InstallMethod(AutomorphismGroup, "for a digraph",
[IsDirectedGraph],
function(graph)
  if IsSimpleDirectedGraph(graph) then 
    # TODO: convert back to directed graphs
    return AutomorphismGroup(GrapeGraph(graph));
  fi;
  Error("not yet implemented,");
end);

#

InstallMethod(DirectedGraphIsomorphism, "for two digraphs",
[IsDirectedGraph, IsDirectedGraph],
function(g1, g2)
  if IsSimpleDirectedGraph(g1) and IsSimpleDirectedGraph(g2) then   
    # TODO: convert back to directed graphs
    return GraphIsomorphism( GrapeGraph(g1), GrapeGraph(g2) );
  fi;
end);

#

InstallMethod(Girth, "for a digraph",
[IsDirectedGraph],
function(graph)
  return Girth( GrapeGraph(graph) );
end);

#

InstallMethod(Diameter, "for a digraph",
[IsDirectedGraph],
function(graph)
  return Diameter( GrapeGraph(graph) );
end);

#

InstallMethod(IsConnectedDigraph, "for a digraph",
[IsDirectedGraph],
function(graph)
  return IsConnectedGraph( GrapeGraph(graph) );
end);

