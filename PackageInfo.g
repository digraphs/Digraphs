#############################################################################
##
#W  PackageInfo.g
#Y  Copyright (C) 2015-17                                James D. Mitchell
##
##  Licensing information can be found in the README.md file of this package.
##
#############################################################################
##

##  <#GAPDoc Label="PKGVERSIONDATA">
##  <!ENTITY VERSION        "0.10.1">
##  <!ENTITY GAPVERS        "4.8.2">
##  <!ENTITY GRAPEVERS      "4.5">
##  <!ENTITY IOVERS         "4.4.4">
##  <!ENTITY ORBVERS        "4.7.5">
##  <!ENTITY ARCHIVENAME    "digraphs-0.10.1">
##  <!ENTITY COPYRIGHTYEARS "2014-17">
##  <#/GAPDoc>

SetPackageInfo(rec(
PackageName := "Digraphs",
Subtitle := "",
Version := "0.10.1",
Date := "16/08/2017",
ArchiveFormats := ".tar.gz",

SourceRepository := rec(
    Type := "git",
    URL := Concatenation("https://github.com/gap-packages/",
                         ~.PackageName),
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
    Institution   := "Vrije Universiteit Brussel"),

  rec(
    LastName      := "Burrell",
    FirstNames    := "S.",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "sb235@st-andrews.ac.uk",
    PostalAddress := Concatenation([
                       "CREEM,", " The Observatory,",
                       " Buchanan Gardens,", " St Andrews,", " Fife,",
                       " KY16 9LZ,", " Scotland"]),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Elliott",
    FirstNames    := "L.",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "le27@st-andrews.ac.uk",
    PostalAddress := Concatenation([
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,",
                       " Scotland"]),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Jefferson",
    FirstNames    := "C.",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "caj21@st-andrews.ac.uk",
    WWWHome       := "http://caj.host.cs.st-andrews.ac.uk",
    PostalAddress := Concatenation([
                       "Jack Cole Building,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SX,",
                       " Scotland"]),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Jonusas",
    FirstNames    := "J.",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "jj252@st-andrews.ac.uk",
    WWWHome       := "http://www-groups.mcs.st-andrews.ac.uk/~julius/",
    PostalAddress := Concatenation([
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,",
                       " Scotland"]),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Mitchell",
    FirstNames    := "J. D.",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "jdm3@st-andrews.ac.uk",
    WWWHome       := "http://goo.gl/ZtViV6",
    PostalAddress := Concatenation([
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,",
                       " Scotland"]),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Pfeiffer",
    FirstNames    := "M.",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "markus.pfeiffer@morphism.de",
    WWWHome       := "https://www.morphism.de/~markusp/",
    PostalAddress := Concatenation([
                       "School of Computer Science,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SX,",
                       " Scotland"]),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Russell",
    FirstNames    := "C.",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "cr66@st-andrews.ac.uk",
    PostalAddress := Concatenation([
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,",
                       " Scotland"]),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Smith",
    FirstNames    := "F.",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "fls3@st-andrews.ac.uk",
    PostalAddress := Concatenation([
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,",
                       " Scotland"]),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Torpey",
    FirstNames    := "M.",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "mct25@st-andrews.ac.uk",
    WWWHome       := "http://www-groups.mcs.st-andrews.ac.uk/~mct25/",
    PostalAddress := Concatenation([
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,",
                       " Scotland"]),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Wilson",
    FirstNames    := "W. A.",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "waw7@st-andrews.ac.uk",
    WWWHome       := "http://www-groups.mcs.st-andrews.ac.uk/~waw7/",
    PostalAddress := Concatenation([
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,",
                       " Scotland"]),
    Place         := "St Andrews",
    Institution   := "University of St Andrews")],

Status := "deposited",

IssueTrackerURL := Concatenation(~.SourceRepository.URL, "/issues"),
PackageWWWHome  := Concatenation("https://gap-packages.github.io/",
                                 ~.PackageName),
README_URL      := Concatenation(~.PackageWWWHome, "/README.md"),
PackageInfoURL  := Concatenation(~.PackageWWWHome, "/PackageInfo.g"),
ArchiveURL      := Concatenation(~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/", "digraphs-", ~.Version),

AbstractHTML := Concatenation("The <b>Digraphs</b> package is a <b>GAP</b> ",
                              "package for digraphs and multidigraphs."),

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
  NeededOtherPackages := [["io", ">=4.4.4"],
                          ["orb", ">=4.7.5"]],
  SuggestedOtherPackages := [["gapdoc", ">=1.5.1"],
                             ["grape", ">=4.5"]],
  ExternalConditions := [],
),

AvailabilityTest := function()
  local digraphs_so;
  digraphs_so := Filename(DirectoriesPackagePrograms("digraphs"),
                          "digraphs.so");
  if (not "digraphs" in SHOW_STAT()) and digraphs_so = fail then
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
