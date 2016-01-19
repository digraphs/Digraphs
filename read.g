#############################################################################
##
#W  read.g
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

if not DIGRAPHS_IsGrapeLoaded then
  Add(DIGRAPHS_OmitFromTests, "Graph(");
fi;

ReadPackage("digraphs/gap/utils.gi");
ReadPackage("digraphs/gap/digraph.gi");
ReadPackage("digraphs/gap/attr.gi");
ReadPackage("digraphs/gap/prop.gi");
ReadPackage("digraphs/gap/oper.gi");
ReadPackage("digraphs/gap/display.gi");
ReadPackage("digraphs/gap/bliss.gi");
ReadPackage("digraphs/gap/io.gi");
ReadPackage("digraphs/gap/grahom.gi");
ReadPackage("digraphs/gap/orbits.gi");
ReadPackage("digraphs/gap/cliques.gi");
