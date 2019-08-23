#############################################################################
##
##  grape.gd
##  Copyright (C) 2019                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareOperation("Graph", [IsDigraph]);

#  Cayley digraphs
DeclareOperation("CayleyDigraph", [IsGroup]);
DeclareOperation("CayleyDigraph", [IsGroup, IsList]);
DeclareAttribute("GroupOfCayleyDigraph", IsCayleyDigraph);
DeclareAttribute("SemigroupOfCayleyDigraph", IsCayleyDigraph);
DeclareAttribute("GeneratorsOfCayleyDigraph", IsCayleyDigraph);

DeclareOperation("Digraph", [IsFunction,
                             IsGroup,
                             IsListOrCollection,
                             IsFunction,
                             IsFunction]);
DeclareOperation("Digraph", [IsGroup,
                             IsListOrCollection,
                             IsFunction,
                             IsFunction]);

DeclareOperation("EdgeOrbitsDigraph", [IsPermGroup, IsList, IsInt]);
DeclareOperation("EdgeOrbitsDigraph", [IsPermGroup, IsList]);
DeclareOperation("DigraphAddEdgeOrbit", [IsDigraph, IsList]);
DeclareOperation("DigraphRemoveEdgeOrbit", [IsDigraph, IsList]);
