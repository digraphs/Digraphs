#############################################################################
##
##  read.g
##  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallGlobalFunction(DIGRAPHS_OmitFromTests,
function()
  local omit;
  omit := [];
  if not DIGRAPHS_IsGrapeLoaded() then
    Add(omit, " Graph(");
    Add(omit, "(Graph(");
    Add(omit, "AsGraph(");
  fi;
  return omit;
end);

# set to true by gap/nauty.g once NautyTracesInterface is loaded
BindGlobal("DIGRAPHS_NautyAvailable", false);

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
