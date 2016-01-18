#############################################################################
##
#W  cliques.gd
#Y  Copyright (C) 2015-16                                Markus Pfeiffer
##                                                       Raghav Mehra
##                                                       Wilf Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

## Independent sets
DeclareOperation("IsIndependentSet", [IsDigraph, IsHomogeneousList]);
DeclareOperation("IsMaximalIndependentSet", [IsDigraph, IsHomogeneousList]);

# Functions to calculate independent sets
DeclareGlobalFunction("DigraphIndependentSet");
DeclareGlobalFunction("DigraphMaximalIndependentSet");
DeclareGlobalFunction("DigraphIndependentSetsOfSize");
DeclareGlobalFunction("DigraphIndependentSetsRepsOfSize");
DeclareGlobalFunction("DigraphMaximalIndependentSetsReps");
DeclareGlobalFunction("DigraphMaximalIndependentSets");
DeclareAttribute("DigraphMaximalIndependentSetsRepsAttr", IsDigraph);
DeclareAttribute("DigraphMaximalIndependentSetsAttr", IsDigraph);

## Cliques
DeclareOperation("IsClique", [IsDigraph, IsHomogeneousList]);
DeclareOperation("IsMaximalClique", [IsDigraph, IsHomogeneousList]);

# Functions to calculate cliques
DeclareGlobalFunction("CliquesFinder");
DeclareGlobalFunction("DIGRAPHS_BronKerbosch");

DeclareGlobalFunction("DigraphClique");
DeclareGlobalFunction("DigraphMaximalClique");
DeclareGlobalFunction("DIGRAPHS_Clique");

DeclareGlobalFunction("DigraphCliques");
DeclareGlobalFunction("DigraphCliquesReps");
DeclareGlobalFunction("DigraphMaximalCliques");
DeclareGlobalFunction("DigraphMaximalCliquesReps");
DeclareAttribute("DigraphMaximalCliquesAttr", IsDigraph);
DeclareAttribute("DigraphMaximalCliquesRepsAttr", IsDigraph);
