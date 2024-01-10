#############################################################################
##
##  read.g
##  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

if not DIGRAPHS_IsGrapeLoaded() then
  Add(DIGRAPHS_OmitFromTests, "Graph(");
fi;

_NautyTracesInterfaceVersion :=
  First(PackageInfo("digraphs")[1].Dependencies.SuggestedOtherPackages,
        x -> x[1] = "nautytracesinterface")[2];

BindGlobal("DIGRAPHS_NautyAvailable",
  IsPackageMarkedForLoading("NautyTracesInterface",
                            _NautyTracesInterfaceVersion));

Unbind(_NautyTracesInterfaceVersion);

ReadPackage("digraphs", "gap/doc.g");

ReadPackage("digraphs", "gap/utils.gi");
ReadPackage("digraphs", "gap/digraph.gi");
ReadPackage("digraphs", "gap/constructors.gi");
ReadPackage("digraphs", "gap/grape.gi");
ReadPackage("digraphs", "gap/labels.gi");
ReadPackage("digraphs", "gap/attr.gi");
ReadPackage("digraphs", "gap/prop.gi");
ReadPackage("digraphs", "gap/oper.gi");
ReadPackage("digraphs", "gap/display.gi");
ReadPackage("digraphs", "gap/isomorph.gi");
ReadPackage("digraphs", "gap/io.gi");
ReadPackage("digraphs", "gap/grahom.gi");
ReadPackage("digraphs", "gap/orbits.gi");
ReadPackage("digraphs", "gap/cliques.gi");
ReadPackage("digraphs", "gap/planar.gi");
ReadPackage("digraphs", "gap/examples.gi");
ReadPackage("digraphs", "gap/weights.gi");
