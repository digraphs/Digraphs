#############################################################################
##
#W  read.g
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

if not GRAPHS_IsGrapeLoaded then 
  Add(GRAPHS_OmitFromTestManualExamples, "Graph(");
fi;

ReadPackage("graphs/gap/digraph.gi");
ReadPackage("graphs/gap/attr.gi");
ReadPackage("graphs/gap/prop.gi");
ReadPackage("graphs/gap/oper.gi");
ReadPackage("graphs/gap/display.gi");
ReadPackage("graphs/gap/bliss.gi");
ReadPackage("graphs/gap/util.gi");
ReadPackage("graphs/gap/io.gi");
ReadPackage("graphs/gap/grahom.gi");
ReadPackage("graphs/gap/stabs.gi");
