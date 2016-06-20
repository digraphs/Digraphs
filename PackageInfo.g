############################################################################
##
#W  PackageInfo.g
#Y  Copyright (C) 2015-16                                Jan J De Beule
##                                                       Julius Jonusas
##                                                       James Mitchell
##                                                       Michael Torpey
##                                                       Wilfred Wilson
##
##  Licensing information can be found in the README.md file of this package.
##
#############################################################################
##

##  <#GAPDoc Label="PKGVERSIONDATA">
##  <!ENTITY VERSION        "0.5.2">
##  <!ENTITY GAPVERS        "4.8.2">
##  <!ENTITY GRAPEVERS      "4.5">
##  <!ENTITY IOVERS         "4.4.4">
##  <!ENTITY ORBVERS        "4.7.5">
##  <!ENTITY ARCHIVENAME    "digraphs-0.5.2">
##  <!ENTITY COPYRIGHTYEARS "2014-16">
##  <#/GAPDoc>

SetPackageInfo(rec(
PackageName := "Digraphs",
Subtitle := "",
Version := "0.5.2",
Date := "20/06/2016",
ArchiveFormats := ".tar.gz",

SourceRepository := rec(
    Type := "git",
    URL := Concatenation( "https://github.com/gap-packages/", ~.PackageName ),
),

Persons := [

  rec(
    LastName      := "De Beule",
    FirstNames    := "J.",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "jdebeule@cage.ugent.be",
    WWWHome       := "http://homepages.vub.ac.be/~jdbeule/",
    PostalAddress := Concatenation([
                     "Vrije Universiteit Brussel, ",
                     " Vakgroep Wiskunde, ",
                     " Pleinlaan 2, ",
                     " B - 1050 Brussels, ",
                     " Belgium"]),
    Place         := "Brussels",
    Institution   := "Vrije Universiteit Brussel"
  ),

  rec(
    LastName      := "Jonusas",
    FirstNames    := "J.",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "jj252@st-andrews.ac.uk",
    WWWHome       := "http://www-circa.mcs.st-andrews.ac.uk/~julius/",
    PostalAddress := Concatenation( [
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,",
                       " Scotland"] ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
  ),

  rec(
    LastName      := "Mitchell",
    FirstNames    := "J. D.",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "jdm3@st-andrews.ac.uk",
    WWWHome       := "http://goo.gl/ZtViV6",
    PostalAddress := Concatenation( [
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,",
                       " Scotland"] ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
  ),
  
  rec(
    LastName      := "Smith",
    FirstNames    := "F.",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "fls3@st-andrews.ac.uk",
    PostalAddress := Concatenation( [
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,",
                       " Scotland"] ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
  ),

  rec(
    LastName      := "Torpey",
    FirstNames    := "M.",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "mct25@st-andrews.ac.uk",
    WWWHome       := "http://www-circa.mcs.st-andrews.ac.uk/~mct25/",
    PostalAddress := Concatenation( [
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,",
                       " Scotland"] ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
  ),

  rec(
    LastName      := "Wilson",
    FirstNames    := "W.",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "waw7@st-andrews.ac.uk",
    WWWHome       := "http://www-circa.mcs.st-andrews.ac.uk/~waw7/",
    PostalAddress := Concatenation( [
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,",
                       " Scotland"] ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
  )],

Status := "dev",

IssueTrackerURL := Concatenation(~.SourceRepository.URL, "/issues"),
PackageWWWHome  := Concatenation("https://gap-packages.github.io/",
                                 ~.PackageName),
README_URL      := Concatenation(~.PackageWWWHome, "/README.md"),
PackageInfoURL  := Concatenation(~.PackageWWWHome, "/PackageInfo.g"),
ArchiveURL      := Concatenation(~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/", "digraphs-", ~.Version),

AbstractHTML := "The <b>Digraphs</b> package is a <b>GAP</b> package for digraphs and multidigraphs.",

PackageDoc := rec(
  BookName  := "Digraphs",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Digraphs - Methods for digraphs",
  Autoload  := true,
),

Dependencies := rec(
  GAP := ">=4.8.2",
  NeededOtherPackages := [["io", ">=4.4.4"], ["orb", ">=4.7.5"]],
  SuggestedOtherPackages := [["gapdoc", ">=1.5.1"], ["grape", ">=4.5"]],
  ExternalConditions := [],
),

  AvailabilityTest := function()
    if (not "digraphs" in SHOW_STAT()) and
      (Filename(DirectoriesPackagePrograms("digraphs"), "digraphs.so") = fail)
     then
      Info(InfoWarning, 1, "Digraphs: the kernel module is not compiled, ",
           "the package cannot be loaded.");
      return fail;
    fi;
    return true;
  end,
  Autoload := false,
  TestFile := "tst/testinstall.tst",
  Keywords := []
));
