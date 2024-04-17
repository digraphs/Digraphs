##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##
##  Call this with GAP in the package directory:
##
##      gap makedoc.g
##

if not IsDirectoryPath("gap")
    or not "doc.g" in DirectoryContents("gap") then
  Print("Error: GAP must be run from the package directory ",
        "when reading makedoc.g\n");
  FORCE_QUIT_GAP(1);
fi;

for global in ["DIGRAPHS_DocXMLFiles",
               "DIGRAPHS_MakeDoc",
               "DIGRAPHS_CustomCSSFile"] do
  if IsBoundGlobal(global) then
    MakeReadWriteGlobal(global);
    UnbindGlobal(global);
  fi;
od;
Unbind(global);

Read("gap/doc.g");
DIGRAPHS_MakeDoc(DirectoryCurrent());
FORCE_QUIT_GAP();
