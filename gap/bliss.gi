#############################################################################
##
#W  bliss.gi
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
  Error("not yet implemented,");
  return;
end);

#

InstallMethod(AutomorphismGroup, "for a digraph",
[IsDigraph],
function(graph)
  Error("not yet implemented,");
end);

#

InstallMethod(DigraphIsomorphism, "for two digraphs",
[IsDigraph, IsDigraph],
function(g1, g2)
  Error("not yet implemented,");
end);

#

InstallMethod(Girth, "for a digraph",
[IsDigraph],
function(graph)
end);

#

InstallMethod(Diameter, "for a digraph",
[IsDigraph],
function(graph)
end);

#

InstallMethod(IsConnectedDigraph, "for a digraph",
[IsDigraph],
function(graph)
end);

