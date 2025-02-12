#############################################################################
##
##  orbits.gd
##  Copyright (C) 2016                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareGlobalFunction("DIGRAPHS_Orbits");
DeclareGlobalFunction("DIGRAPHS_TraceSchreierVector");
DeclareGlobalFunction("DIGRAPHS_EvaluateWord");
DeclareAttribute("DIGRAPHS_Stabilizers", IsDigraph, "mutable");
DeclareGlobalFunction("DIGRAPHS_AddOrbitToHashMap");

DeclareAttribute("DigraphGroup", IsDigraph);
DeclareAttribute("DigraphOrbits", IsDigraph);
DeclareAttribute("DigraphOrbitReps", IsDigraph);
DeclareOperation("DigraphStabilizer", [IsDigraph, IsPosInt]);
DeclareAttribute("DigraphSchreierVector", IsDigraph);
DeclareAttribute("RepresentativeOutNeighbours", IsDigraph);
