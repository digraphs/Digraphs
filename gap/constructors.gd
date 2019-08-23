#############################################################################
##
##  constructors.gd
##  Copyright (C) 2019                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# This file contains constructions of certain types of digraphs, from other
# digraphs.

DeclareOperation("BipartiteDoubleDigraph", [IsDigraph]);
DeclareOperation("DoubleDigraph", [IsDigraph]);

DeclareOperation("DistanceDigraph", [IsDigraph, IsInt]);
DeclareOperation("DistanceDigraph", [IsDigraph, IsList]);

DeclareOperation("LineDigraph", [IsDigraph]);
DeclareSynonym("EdgeDigraph", LineDigraph);
DeclareOperation("LineUndirectedDigraph", [IsDigraph]);
DeclareSynonym("EdgeUndirectedDigraph", LineUndirectedDigraph);
