#############################################################################
##
#W  orbits.gd
#Y  Copyright (C) 2016                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareGlobalFunction("DIGRAPHS_Orbits");
DeclareGlobalFunction("DIGRAPHS_TraceSchreierVector");

DeclareAttribute("DigraphGroup", IsDigraph);
DeclareAttribute("DigraphOrbits", IsDigraph);
DeclareAttribute("DigraphOrbitReps", IsDigraph);
DeclareAttribute("DigraphStabilizers", IsDigraph, "mutable");
DeclareOperation("DigraphStabilizer", [IsDigraph, IsPosInt]);
DeclareAttribute("DigraphSchreierVector", IsDigraph);
DeclareAttribute("RepresentativeOutNeighbours", IsDigraph);
