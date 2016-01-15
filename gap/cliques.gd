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
DeclareGlobalFunction("DIGRAPHS_Clique");
DeclareGlobalFunction("DigraphClique");
DeclareGlobalFunction("DigraphMaximalClique");
DeclareGlobalFunction("DigraphCliquesOfSize");
DeclareGlobalFunction("DigraphCliquesRepsOfSize");
DeclareGlobalFunction("DigraphMaximalCliquesReps");
DeclareGlobalFunction("DigraphMaximalCliques");
DeclareAttribute("DigraphMaximalCliquesRepsAttr", IsDigraph);
DeclareAttribute("DigraphMaximalCliquesAttr", IsDigraph);
DeclareGlobalFunction("DIGRAPHS_BronKerbosch");
