#############################################################################
##
#W  init.g
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
  
# load kernel function if it is installed:
if (not IsBound(GRAPHS_C)) and ("graphs" in SHOW_STAT()) then
  # try static module
  LoadStaticModule("graphs");
fi;
if (not IsBound(GRAPHS_C)) and
   (Filename(DirectoriesPackagePrograms("graphs"), "graphs.so") <> fail) then
  LoadDynamicModule(Filename(DirectoriesPackagePrograms("graphs"),
  "graphs.so"));
fi;

BindGlobal("GRAPHS_IsGrapeLoaded", IsPackageMarkedForLoading("grape", "4.5"));

if not GRAPHS_IsGrapeLoaded then 
  IsGraph := ReturnFalse;
  Vertices := IdFunc;
  Adjacency := IdFunc;
fi;

ReadPackage("graphs/gap/graph.gd");
ReadPackage("graphs/gap/attr.gd");
ReadPackage("graphs/gap/prop.gd");
ReadPackage("graphs/gap/oper.gd");
ReadPackage("graphs/gap/display.gd");
ReadPackage("graphs/gap/bliss.gd");
ReadPackage("graphs/gap/util.gd");
ReadPackage("graphs/gap/io.gd");
ReadPackage("graphs/gap/grahom.gd");
ReadPackage("graphs/gap/stabs.gd");

DeclareInfoClass("InfoGraphs");;
