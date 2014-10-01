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
if (not IsBound(DIGRAPHS_C)) and ("digraphs" in SHOW_STAT()) then
  # try static module
  LoadStaticModule("digraphs");
fi;
if (not IsBound(DIGRAPHS_C)) and
   (Filename(DirectoriesPackagePrograms("digraphs"), "digraphs.so") <> fail) then
  LoadDynamicModule(Filename(DirectoriesPackagePrograms("digraphs"),
  "digraphs.so"));
fi;

ReadPackage("digraphs/gap/digraph.gd");

ReadPackage("digraphs/gap/attr.gd");
ReadPackage("digraphs/gap/prop.gd");
ReadPackage("digraphs/gap/oper.gd");
ReadPackage("digraphs/gap/display.gd");
ReadPackage("digraphs/gap/grape.gd");
ReadPackage("digraphs/gap/util.gd");
ReadPackage("digraphs/gap/io.gd");

DeclareInfoClass("InfoDigraphs");;
