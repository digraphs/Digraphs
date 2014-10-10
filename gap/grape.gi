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
    return IsIsomorphicGraph( AsGraph(g1), AsGraph(g2) );
  fi;
  Error("not yet implemented,");
  return;
end);

#

InstallMethod(AutomorphismGroup, "for a digraph",
[IsDigraph],
function(graph)
  if IsSimpleDigraph(graph) then 
    # TODO: convert back to digraphs
    return AutomorphismGroup(AsGraph(graph));
  fi;
  Error("not yet implemented,");
end);

#

InstallMethod(DigraphIsomorphism, "for two digraphs",
[IsDigraph, IsDigraph],
function(g1, g2)
  if IsSimpleDigraph(g1) and IsSimpleDigraph(g2) then   
    # TODO: convert back to digraphs
    return GraphIsomorphism( AsGraph(g1), AsGraph(g2) );
  fi;
end);

#

InstallMethod(Girth, "for a digraph",
[IsDigraph],
function(graph)
  return Girth( AsGraph(graph) );
end);

#

InstallMethod(Diameter, "for a digraph",
[IsDigraph],
function(graph)
  return Diameter( AsGraph(graph) );
end);

#

InstallMethod(IsConnectedDigraph, "for a digraph",
[IsDigraph],
function(graph)
  return IsConnectedGraph( AsGraph(graph) );
end);

