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
DeclareAttribute("MaximalSymmetricSubMultiDigraph", IsDigraph);
DeclareAttribute("MaximalSymmetricSubMultiDigraphWithoutLoops", IsDigraph);
DeclareAttribute("MaximalSymmetricSubDigraph", IsDigraph);
DeclareAttribute("MaximalSymmetricSubDigraphWithoutLoops", IsDigraph);
DeclareOperation("DIGRAPHS_MaximalSymmetricSubDigraph", [IsDigraph, IsBool]);
DeclareAttribute("DigraphDegeneracy", IsDigraph);
DeclareAttribute("DigraphDegeneracyOrdering", IsDigraph);
DeclareAttribute("DIGRAPHS_Degeneracy", IsDigraph);

#
DeclareOperation("IsIndependentSet", [IsDigraph, IsHomogeneousList]);
DeclareOperation("IsClique", [IsDigraph, IsHomogeneousList]);
DeclareOperation("IsMaximalIndependentSet", [IsDigraph, IsHomogeneousList]);
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
DeclareAttribute("MaximalIndependentSets", IsDigraph);
DeclareOperation("MaximalIndependentSets", [IsDigraph, IsHomogeneousList]);
DeclareOperation("MaximalIndependentSets", [IsDigraph, IsHomogeneousList,
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
# Functions to return all maximal cliques
DeclareAttribute("MaximalCliques", IsDigraph);
DeclareOperation("MaximalCliques", [IsDigraph, IsHomogeneousList]);
DeclareOperation("MaximalCliques", [IsDigraph, IsHomogeneousList,
                                    IsHomogeneousList]);

# Temporary functions to calculate maximal cliques
DeclareGlobalFunction("BronKerbosch");
