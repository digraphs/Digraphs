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

InstallMethod(IsIsomorphicDigraph, "for digraphs",
[IsDigraph, IsDigraph],
function(g1, g2)
  if IsSimpleDigraph(g1) and IsSimpleDigraph(g2) then 
    return IsIsomorphicGraph( GrapeGraph(g1), GrapeGraph(g2) );
  fi;
  Error("not yet implemented,");
  return;
end);

#

InstallMethod(AutomorphismGroup, "for a digraph",
[IsDigraph],
function(graph)
  if IsSimpleDigraph(graph) then 
    # TODO: convert back to directed graphs
    return AutomorphismGroup(GrapeGraph(graph));
  fi;
  Error("not yet implemented,");
end);

#

InstallMethod(DigraphIsomorphism, "for two digraphs",
[IsDigraph, IsDigraph],
function(g1, g2)
  if IsSimpleDigraph(g1) and IsSimpleDigraph(g2) then   
    # TODO: convert back to directed graphs
    return GraphIsomorphism( GrapeGraph(g1), GrapeGraph(g2) );
  fi;
end);

#

InstallMethod(Girth, "for a digraph",
[IsDigraph],
function(graph)
  return Girth( GrapeGraph(graph) );
end);

#

InstallMethod(Diameter, "for a digraph",
[IsDigraph],
function(graph)
  return Diameter( GrapeGraph(graph) );
end);

#

InstallMethod(IsConnectedDigraph, "for a digraph",
[IsDigraph],
function(graph)
  return IsConnectedGraph( GrapeGraph(graph) );
end);

