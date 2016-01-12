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
    (Filename(DirectoriesPackagePrograms("digraphs"), "digraphs.so") <> fail)
    then
  LoadDynamicModule(Filename(DirectoriesPackagePrograms("digraphs"),
                             "digraphs.so"));
fi;

BindGlobal("DIGRAPHS_IsGrapeLoaded",
           IsPackageMarkedForLoading("grape", "4.5"));

if not DIGRAPHS_IsGrapeLoaded then
  IsGraph := ReturnFalse;
  Vertices := IdFunc;
  Adjacency := IdFunc;
fi;

# Temporary binding (until the released version of GAP contains this)
if not IsBound(ErrorMayQuit) then
  BindGlobal("ErrorMayQuit",
  function(arg)
      ErrorInner(rec(context := ParentLVars(GetCurrentLVars()),
                     mayReturnVoid := false,
                     mayReturnObj := false,
                     lateMessage := "type 'quit;' to quit to outer loop",
                     printThisStatement := false),
                 arg);
    end);
fi;

ReadPackage("digraphs/gap/digraph.gd");
ReadPackage("digraphs/gap/attr.gd");
ReadPackage("digraphs/gap/prop.gd");
ReadPackage("digraphs/gap/oper.gd");
ReadPackage("digraphs/gap/display.gd");
ReadPackage("digraphs/gap/bliss.gd");
ReadPackage("digraphs/gap/utils.gd");
ReadPackage("digraphs/gap/io.gd");
ReadPackage("digraphs/gap/grahom.gd");
ReadPackage("digraphs/gap/cliques.gd");
ReadPackage("digraphs/gap/stabs.gd");

DeclareInfoClass("InfoDigraphs");
