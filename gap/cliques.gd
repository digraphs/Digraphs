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

#
DeclareOperation("IsIndependentSet", [IsDigraph, IsHomogeneousList]);
DeclareOperation("IsMaximalIndependentSet", [IsDigraph, IsHomogeneousList]);
DeclareOperation("IsClique", [IsDigraph, IsHomogeneousList]);
DeclareOperation("IsMaximalClique", [IsDigraph, IsHomogeneousList]);

## Independent sets

# Functions to return a single independent set or a single maximal ind set
DeclareAttribute("DigraphIndependentSet", IsDigraph);
DeclareOperation("DigraphIndependentSet", [IsDigraph, IsHomogeneousList]);
DeclareOperation("DigraphIndependentSet", [IsDigraph, IsHomogeneousList,
                                           IsHomogeneousList]);
DeclareAttribute("DigraphMaximalIndependentSet", IsDigraph);
DeclareOperation("DigraphMaximalIndependentSet", [IsDigraph,
                                                  IsHomogeneousList]);
DeclareOperation("DigraphMaximalIndependentSet", [IsDigraph, IsHomogeneousList,
                                                  IsHomogeneousList]);
# Functions to return all maximal independent sets
DeclareAttribute("DigraphMaximalIndependentSets", IsDigraph);
DeclareOperation("DigraphMaximalIndependentSets", [IsDigraph,
                                                   IsHomogeneousList]);
DeclareOperation("DigraphMaximalIndependentSets", [IsDigraph, IsHomogeneousList,
                                                   IsHomogeneousList]);

## Cliques

# Functions to return a single clique or a single maximal clique
DeclareOperation("DigraphClique", [IsDigraph]);
DeclareOperation("DigraphClique", [IsDigraph, IsHomogeneousList]);
DeclareOperation("DigraphClique", [IsDigraph, IsHomogeneousList,
                                   IsHomogeneousList]);
DeclareOperation("DigraphMaximalClique", [IsDigraph]);
DeclareOperation("DigraphMaximalClique", [IsDigraph, IsHomogeneousList]);
DeclareOperation("DigraphMaximalClique", [IsDigraph, IsHomogeneousList,
                                          IsHomogeneousList]);
# Functions to calculate cliques
DeclareGlobalFunction("DigraphMaximalCliquesReps");
DeclareGlobalFunction("DigraphMaximalCliques");
DeclareAttribute("DigraphMaximalCliquesRepsAttr", IsDigraph);
DeclareAttribute("DigraphMaximalCliquesAttr", IsDigraph);
DeclareGlobalFunction("DIGRAPHS_BronKerbosch");
