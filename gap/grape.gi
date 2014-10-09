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
[IsMultiDigraph, IsMultiDigraph],
function(g1, g2)
  if IsDigraph(g1) and IsDigraph(g2) then 
    return IsIsomorphicGraph( GrapeGraph(g1), GrapeGraph(g2) );
  fi;
  Error("not yet implemented,");
  return;
end);

#

InstallMethod(AutomorphismGroup, "for a digraph",
[IsMultiDigraph],
function(graph)
  if IsDigraph(graph) then 
    # TODO: convert back to digraphs
    return AutomorphismGroup(GrapeGraph(graph));
  fi;
  Error("not yet implemented,");
end);

#

InstallMethod(DigraphIsomorphism, "for two digraphs",
[IsMultiDigraph, IsMultiDigraph],
function(g1, g2)
  if IsDigraph(g1) and IsDigraph(g2) then   
    # TODO: convert back to digraphs
    return GraphIsomorphism( GrapeGraph(g1), GrapeGraph(g2) );
  fi;
end);

#

InstallMethod(Girth, "for a digraph",
[IsMultiDigraph],
function(graph)
  return Girth( GrapeGraph(graph) );
end);

#

InstallMethod(Diameter, "for a digraph",
[IsMultiDigraph],
function(graph)
  return Diameter( GrapeGraph(graph) );
end);

#

InstallMethod(IsConnectedDigraph, "for a digraph",
[IsMultiDigraph],
function(graph)
  return IsConnectedGraph( GrapeGraph(graph) );
end);

