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

_NautyTracesInterfaceVersion :=
  First(PackageInfo("digraphs")[1].Dependencies.SuggestedOtherPackages,
        x -> x[1] = "NautyTracesInterface")[2];

BindGlobal("DIGRAPHS_NautyAvailable",
  IsPackageMarkedForLoading("NautyTracesInterface",
                            _NautyTracesInterfaceVersion));

Unbind(_NautyTracesInterfaceVersion);

# Delete this when we no longer support GAP 4.10
if not CompareVersionNumbers(ReplacedString(GAPInfo.Version, "dev", ""), "4.11")
    and not IsBound(INTOBJ_MAX) then
  BindGlobal("INTOBJ_MAX", 1152921504606846975);
fi;

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
