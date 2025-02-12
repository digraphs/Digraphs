#############################################################################
##
##  cliques.gd
##  Copyright (C) 2015-17                                Markus Pfeiffer
##                                                       Raghav Mehra
##                                                       Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareOperation("IsIndependentSet", [IsDigraph, IsHomogeneousList]);
DeclareOperation("IsMaximalIndependentSet", [IsDigraph, IsHomogeneousList]);
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
DeclareAttribute("DigraphCliquesAttr", IsDigraph);
DeclareAttribute("DigraphMaximalCliquesAttr", IsDigraph);
DeclareAttribute("DigraphMaximalCliquesRepsAttr", IsDigraph);

# Functions to calculate independent sets
DeclareGlobalFunction("DigraphIndependentSet");
DeclareGlobalFunction("DigraphMaximalIndependentSet");

DeclareGlobalFunction("DigraphIndependentSets");
DeclareGlobalFunction("DigraphIndependentSetsReps");
DeclareGlobalFunction("DigraphMaximalIndependentSets");
DeclareGlobalFunction("DigraphMaximalIndependentSetsReps");
DeclareAttribute("DigraphIndependentSetsAttr", IsDigraph);
DeclareAttribute("DigraphMaximalIndependentSetsAttr", IsDigraph);
DeclareAttribute("DigraphMaximalIndependentSetsRepsAttr", IsDigraph);

DeclareAttribute("CliqueNumber", IsDigraph);
