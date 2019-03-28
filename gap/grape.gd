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

DeclareCategory("IsCayleyDigraph", IsDigraph);

DeclareAttribute("GroupOfCayleyDigraph", IsCayleyDigraph);
DeclareAttribute("SemigroupOfCayleyDigraph", IsCayleyDigraph);
DeclareAttribute("GeneratorsOfCayleyDigraph", IsCayleyDigraph);

DeclareConstructor("DigraphCons", [IsImmutableDigraph,
                                   IsGroup,
                                   IsListOrCollection,
                                   IsFunction,
                                   IsFunction]);

DeclareOperation("CayleyDigraph", [IsGroup]);
DeclareOperation("CayleyDigraph", [IsGroup, IsList]);

DeclareOperation("EdgeOrbitsDigraph", [IsPermGroup, IsList, IsInt]);
DeclareOperation("EdgeOrbitsDigraph", [IsPermGroup, IsList]);
DeclareOperation("DigraphAddEdgeOrbit", [IsDigraph, IsList]);
DeclareOperation("DigraphRemoveEdgeOrbit", [IsDigraph, IsList]);
