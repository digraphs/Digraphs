#############################################################################
##
#W  maxcliq.gd
#Y  Copyright (C) 2015                                   Markus Pfeiffer
##                                                       Raghav Mehra
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareAttribute("MaximalCliques", IsDigraph);

DeclareGlobalFunction("DigraphBronKerbosch");
DeclareGlobalFunction("DigraphBronKerboschWithPivot");
DeclareGlobalFunction("DigraphBronKerboschWithPivotAndOrdering");
DeclareGlobalFunction("DigraphBronKerboschIter");
