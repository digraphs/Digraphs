#############################################################################
##
##  doc.g
##  Copyright (C) 2021                                   James D. Mitchell
##                                                          Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
## This file contains the information required to build the Digraphs package
## documentation, it is used by makedoc.g.

BindGlobal("DIGRAPHS_DocXMLFiles",
           ["../PackageInfo.g",
            "attr.xml",
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
            "utils.xml"]);

BindGlobal("DIGRAPHS_MakeDoc",
function(pkgdir)
  local PKG, temp, version, args;

  PKG := "Digraphs";

  # Get the GAP version from PackageInfo.g and write it to .VERSION
  temp := SplitString(StringFile(Filename(pkgdir, "PackageInfo.g")), "\n");
  version := SplitString(First(temp, x -> StartsWith(x, "Version")), "\"")[2];
  PrintTo(Filename(pkgdir, ".VERSION"), version, "\n");

  args := [Filename(pkgdir, "doc"),
           "main.xml",
           DIGRAPHS_DocXMLFiles,
           PKG,
           "MathJax",
           "../../.."];
  # If pdflatex is not available, but we call MakeGAPDocDoc implicitly asking
  # for GAPDoc to compile a PDF version of the manual, then GAPDoc fails to
  # create the doc/manual.six file, which we need later. This file however is
  # still created if we explicitly say that we don't want a PDF
  if Filename(DirectoriesSystemPrograms(), "pdflatex") = fail then
    Add(args, "nopdf");
  fi;
  LoadPackage("GAPDoc");
  SetGapDocLaTeXOptions("utf8");
  CallFuncList(MakeGAPDocDoc, args);
  CopyHTMLStyleFiles(Filename(pkgdir, "doc"));
  GAPDocManualLabFromSixFile(PKG, Filename(pkgdir, "doc/manual.six"));
end);
