#############################################################################
##
##  init.g
##  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# load a method for UserHomeExpand if necessary
if not IsBound(UserHomeExpand) then
  BindGlobal("UserHomeExpand", USER_HOME_EXPAND);
fi;

if CompareVersionNumbers(GAPInfo.Version, "4.12") then
  if not LoadKernelExtension("digraphs") then
    Error("failed to load the Digraphs package kernel extension");
  fi;
else
  # TODO this clause can be removed once Digraphs requires GAP>=4.12.1
  # load kernel function if it is installed:
  if not IsBound(DIGRAPH_OUT_NBS) and "digraphs" in SHOW_STAT() then
    # try static module
    LoadStaticModule("digraphs");
  fi;
  if not IsBound(DIGRAPH_OUT_NBS) and
      Filename(DirectoriesPackagePrograms("digraphs"),
               "digraphs.so") <> fail then
    LoadDynamicModule(Filename(DirectoriesPackagePrograms("digraphs"),
                               "digraphs.so"));
  fi;
fi;

BindGlobal("DIGRAPHS_IsGrapeLoaded",
           {} -> IsPackageMarkedForLoading("grape", "4.8.1"));

# To avoid warnings when GRAPE is not loaded
if not IsBound(IsGraph) then
  IsGraph := ReturnFalse;
fi;
if not IsBound(Vertices) then
  DeclareOperation("Vertices", [IsRecord]);
fi;
if not IsBound(Adjacency) then
  Adjacency := IdFunc;
fi;
# Avoid warnings with GAP 4.10 for use of FlipBlist
# Can be removed once Digraphs requires GAP>=4.11
if not IsBound(FlipBlist) then
  FlipBlist := function(BList)
    Apply(BList, x -> not x);
  end;
fi;

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
