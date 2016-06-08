##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##  
##  Call this with GAP in the package directory:
##    
##      gap makedoc.g
## 

PACKAGE := "Digraphs";
PrintTo("VERSION", PackageInfo(PACKAGE)[1].Version);
LoadPackage("GAPDoc");

_DocXMLFiles := ["attr.xml",
                 "bliss.xml",
                 "cliques.xml",
                 "digraph.xml",
                 "display.xml",
                 "grahom.xml",
                 "grape.xml",
                 "io.xml",
                 "oper.xml",
                 "orbits.xml",
                 "prop.xml",
                 "utils.xml",
                 "../PackageInfo.g"];

MakeGAPDocDoc(Concatenation(PackageInfo("digraphs")[1]!.
                            InstallationPath, "/doc"),
              "main.xml", _DocXMLFiles, "Digraphs", "MathJax",
              "../../..");
CopyHTMLStyleFiles("doc");
GAPDocManualLab(PACKAGE);

QUIT;
