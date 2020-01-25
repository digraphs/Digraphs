##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##
##  Call this with GAP in the package directory:
##
##      gap makedoc.g
##

PACKAGE := "Digraphs";
PrintTo(".VERSION", PackageInfo(PACKAGE)[1].Version, "\n");
LoadPackage("GAPDoc");

_DocXMLFiles := ["attr.xml",
                 "cliques.xml",
                 "constructors.xml",
                 "digraph.xml",
                 "display.xml",
                 "examples.xml",
                 "grahom.xml",
                 "grape.xml",
                 "io.xml",
                 "isomorph.xml",
                 "labels.xml",
                 "oper.xml",
                 "orbits.xml",
                 "planar.xml",
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
