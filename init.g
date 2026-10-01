#############################################################################
##
##  init.g
##  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

if not LoadKernelExtension("digraphs") then
  Error("failed to load the Digraphs package kernel extension");
fi;

BindGlobal("DIGRAPHS_IsGrapeLoaded",
           {} -> IsPackageMarkedForLoading("grape", "4.8.1"));

# IsGraph belongs to GRAPE, which need not be loaded
BindGlobal("DIGRAPHS_IsGrapeGraph",
           x -> DIGRAPHS_IsGrapeLoaded() and ValueGlobal("IsGraph")(x));

ReadPackage("digraphs", "gap/digraph.gd");
ReadPackage("digraphs", "gap/digraphs.g");
ReadPackage("digraphs", "gap/constructors.gd");
ReadPackage("digraphs", "gap/grape.gd");
ReadPackage("digraphs", "gap/labels.gd");
ReadPackage("digraphs", "gap/attr.gd");
ReadPackage("digraphs", "gap/prop.gd");
ReadPackage("digraphs", "gap/oper.gd");
ReadPackage("digraphs", "gap/display.gd");
ReadPackage("digraphs", "gap/isomorph.gd");
ReadPackage("digraphs", "gap/utils.gd");
ReadPackage("digraphs", "gap/io.gd");
ReadPackage("digraphs", "gap/grahom.gd");
ReadPackage("digraphs", "gap/orbits.gd");
ReadPackage("digraphs", "gap/cliques.gd");
ReadPackage("digraphs", "gap/planar.gd");
ReadPackage("digraphs", "gap/examples.gd");
ReadPackage("digraphs", "gap/weights.gd");

DeclareInfoClass("InfoDigraphs");
