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
if IsBoundGlobal("DIGRAPHS_DocXMLFiles") then
  MakeReadWriteGlobal("DIGRAPHS_DocXMLFiles");
  UnbindGlobal("DIGRAPHS_DocXMLFiles");
fi;
if IsBoundGlobal("DIGRAPHS_MakeDoc") then
  MakeReadWriteGlobal("DIGRAPHS_MakeDoc");
  UnbindGlobal("DIGRAPHS_MakeDoc");
fi;
Read("gap/doc.g");
DIGRAPHS_MakeDoc(DirectoryCurrent());
FORCE_QUIT_GAP();
