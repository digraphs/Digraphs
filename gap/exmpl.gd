#############################################################################
##
##  exmpl.gd
##  Copyright (C) 2019                                     Murray T. Whyte
##                                                       James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# This file contains constructors for certain standard examples of digraphs.

DeclareOperation("EmptyDigraph", [IsInt]);
DeclareOperation("EmptyMutableDigraph", [IsInt]);
DeclareSynonym("NullDigraph", EmptyDigraph);
DeclareSynonym("NullMutableDigraph", EmptyMutableDigraph);

DeclareOperation("CompleteBipartiteDigraph", [IsPosInt, IsPosInt]);
DeclareOperation("CompleteMultipartiteDigraph", [IsList]);
DeclareOperation("CompleteDigraph", [IsInt]);
DeclareOperation("CycleDigraph", [IsPosInt]);
DeclareOperation("ChainDigraph", [IsPosInt]);
DeclareOperation("JohnsonDigraph", [IsInt, IsInt]);
DeclareOperation("PetersenGraph", []);
