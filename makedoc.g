#############################################################################
##
##  makedoc.g
##  Copyright (C) 2024                                  James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

LoadPackage("AutoDoc");

# Helper functions

RemovePrefixVersion := function(string)
  if StartsWith(string, ">=") then
    return string{[3 .. Length(string)]};
  fi;
  return string;
end;

UrlEntity := function(name, url)
  return StringFormatted("""<Alt Not="Text"><URL Text="{1}">{2}</URL></Alt>
    <Alt Only="Text"><Package>{1}</Package></Alt>""", name, url);
end;

PackageEntity := function(name)
  if TestPackageAvailability(name) <> fail then
    return UrlEntity(PackageInfo(name)[1].PackageName,
                     PackageInfo(name)[1].PackageWWWHome);
  fi;
  return StringFormatted("<Package>{1}</Package>", name);
end;

MathOrCode := function(string)
  return StringFormatted("""<Alt Not="Text"><M>{1}</M></Alt>
    <Alt Only="Text"><C>{1}</C></Alt>""", string);
end;

XMLEntities := rec();

# Programmatically determined entities

PkgInfo := PackageInfo("digraphs")[1];

XMLEntities.VERSION := PkgInfo.Version;
XMLEntities.GAPVERS := RemovePrefixVersion(PkgInfo.Dependencies.GAP);

for Pkg in Concatenation(PkgInfo.Dependencies.NeededOtherPackages,
                         PkgInfo.Dependencies.SuggestedOtherPackages) do
  entity_name := Concatenation(UppercaseString(Pkg[1]), "VERS");
  XMLEntities.(entity_name) := RemovePrefixVersion(Pkg[2]);
od;

ARCHIVENAME := SplitString(PkgInfo.ArchiveURL, "/");
ARCHIVENAME := Concatenation(Last(ARCHIVENAME), PkgInfo.ArchiveFormats);
XMLEntities.ARCHIVENAME := ARCHIVENAME;

XMLEntities.DIGRAPHS := PackageEntity("Digraphs");

for Pkg in Concatenation(PkgInfo.Dependencies.NeededOtherPackages,
                         PkgInfo.Dependencies.SuggestedOtherPackages) do
  entity_name := UppercaseString(Pkg[1]);
  XMLEntities.(entity_name) := PackageEntity(Pkg[1]);
od;

# The files containing the xml of the doc

DocDir := DirectoriesPackageLibrary("digraphs", "doc")[1];
Files := Filtered(DirectoryContents(DocDir),
                  x -> (not StartsWith(x, "."))
                       and (not StartsWith(x, "z-"))
                       and EndsWith(x, ".xml"));
Apply(Files, x -> Concatenation("doc/", x));
Add(Files, "PackageInfo.g");
Sort(Files);

# The scaffold files (chapters)

Includes := Filtered(DirectoryContents(DocDir),
                     x -> StartsWith(x, "z-") and EndsWith(x, ".xml") and not
                     StartsWith(x, "z-app"));
Sort(Includes);

# Hard coded entities

XMLEntities.BLISS := UrlEntity("bliss",
  "http://www.tcs.tkk.fi/Software/bliss/");
XMLEntities.NAUTY := UrlEntity("nauty",
  "https://pallini.di.uniroma1.it");
XMLEntities.NautyTracesInterface := UrlEntity("NautyTracesInterface",
  "https://github.com/gap-packages/NautyTracesInterface");
XMLEntities.EDGE_PLANARITY_SUITE := UrlEntity("edge-addition-planarity-suite",
"https://github.com/graph-algorithms/edge-addition-planarity-suite");

XMLEntities.MUTABLE_RECOMPUTED_ATTR := """If the argument <A>digraph</A> is
mutable, then the return value of this attribute is recomputed every time it is
called.<P/>""";
XMLEntities.MUTABLE_RECOMPUTED_PROP := """If the argument <A>digraph</A> is
mutable, then the return value of this property is recomputed every time it is
called.<P/>""";
XMLEntities.STANDARD_FILT_TEXT := """If the optional first argument <A>filt</A>
is present, then this should specify the category or representation the digraph
being created will belong to. For example, if <A>filt</A> is <Ref
Filt="IsMutableDigraph"/>, then the digraph being created will be mutable, if
<A>filt</A> is <Ref Filt="IsImmutableDigraph"/>, then the digraph will be
immutable.  If the optional first argument <A>filt</A> is not present, then
<Ref Filt="IsImmutableDigraph"/> is used by default.<P/>""";
XMLEntities.CHESSBOARD_LABELS := """The chosen correspondence between vertices
and chess squares is given by <Ref Oper="DigraphVertexLabels"/>.  In more
detail, the vertices of the digraph are labelled by elements of the Cartesian
product <C>[1..<A>m</A>] x [1..<A>n</A>]</C>, where the first entry indexes the
column (file) of the square in the chessboard, and the second entry indexes the
row (rank) of the square.  (Note that the files are traditionally indexed by
the lowercase letters of the alphabet).  The vertices are sorted in ascending
order, first by row (second component) and then column (first component).""";
XMLEntities.CHESSBOARD_DEFN := """An <A>m</A> by <A>n</A> chessboard is a grid
of <A>m</A> columns ("files") and <A>n</A> rows ("ranks") that intersect in
squares. Orthogonally adjacent squares are alternately colored light and dark,
with the square in the first rank and file being dark.<P/>""";

# The actual call to AutoDoc

AutoDoc("digraphs", rec(
    autodoc := rec(scan_dirs := []),
    gapdoc := rec(
        LaTeXOptions := rec(EarlyExtraPreamble := """
            \usepackage{a4wide}
            \newcommand{\bbZ}{\mathbb{Z}}
        """),
        main := "main",
        files := Files),

    scaffold := rec(
        includes := Includes,
        appendix := ["z-appA.xml"],
        bib := "digraphs.bib",
        entities := XMLEntities)));

# HTML styling
main_css := "doc/manual.css";
custom_css := "doc/digraphs.css";
if IsReadableFile(custom_css) and IsWritableFile(main_css) then
  AppendTo(main_css, StringFile(custom_css));
fi;

Unbind(RemovePrefixVersion);
Unbind(UrlEntity);
Unbind(PackageEntity);
Unbind(MathOrCode);
Unbind(XMLEntities);
Unbind(PkgInfo);
Unbind(Pkg);
Unbind(ARCHIVENAME);
Unbind(DocDir);
Unbind(Files);
Unbind(Includes);
