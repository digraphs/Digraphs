#############################################################################
##
##  PackageInfo.g
##  Copyright (C) 2015-19                                James D. Mitchell
##
##  Licensing information can be found in the README.md file of this package.
##
#############################################################################
##

##  <#GAPDoc Label="PKGVERSIONDATA">
##  <!ENTITY VERSION        "0.15.2">
##  <!ENTITY GAPVERS        "4.9.0">
##  <!ENTITY GRAPEVERS      "4.8.1">
##  <!ENTITY IOVERS         "4.5.1">
##  <!ENTITY ORBVERS        "4.8.2">
##  <!ENTITY ARCHIVENAME    "digraphs-0.15.2">
##  <!ENTITY COPYRIGHTYEARS "2014-19">
##  <#/GAPDoc>

SetPackageInfo(rec(
PackageName := "Digraphs",
Subtitle := "Graphs, digraphs, and multidigraphs in GAP",
Version := "0.15.2",
Date := "17/04/2019",  # dd/mm/yyyy format
License := "GPL-3.0-or-later",
ArchiveFormats := ".tar.gz",

SourceRepository := rec(
    Type := "git",
    URL := Concatenation("https://github.com/gap-packages/",
                         ~.PackageName),
),

Persons := [

  rec(
    LastName      := "De Beule",
    FirstNames    := "Jan",
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
    FirstNames    := "Stuart",
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
    FirstNames    := "Luke",
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
    LastName      := "Horn",
    FirstNames    := "Max",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "max.horn@math.uni-giessen.de",
    WWWHome       := "https://www.quendi.de/math",
    PostalAddress := Concatenation([
                       "AG Algebra,",
                       " Mathematisches Institut,",
                       " Justus-Liebig-Universität Gießen,",
                       " Arndtstraße 2,",
                       " 35392 Gießen,",
                       " Germany"]),
    Place         := "Gießen",
    Institution   := "Justus-Liebig-Universität Gießen"),

  rec(
    LastName      := "Jefferson",
    FirstNames    := "Christopher",
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
    FirstNames    := "Julius",
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
    FirstNames    := "James",
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
    FirstNames    := "Markus",
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
    FirstNames    := "Christopher",
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
    FirstNames    := "Finn",
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
    FirstNames    := "Michael",
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
    LastName      := "Whyte",
    FirstNames    := "Murray",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "mw231@st-andrews.ac.uk",
    PostalAddress := Concatenation([
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,",
                       " Scotland"]),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Wilson",
    FirstNames    := "Wilf",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "gap@wilf-wilson.net",
    WWWHome       := "http://wilf.me",
    PostalAddress := Concatenation(["Theodor-Lieser-Straße 5, ",
                                    "06120 Halle (Saale), ",
                                    "Germany"]),
    Place         := "Halle (Saale), Germany",
    Institution   := "University of Halle-Wittenberg")],

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
  GAP := ">=4.9.0",
  NeededOtherPackages := [["io", ">=4.5.1"],
                          ["orb", ">=4.8.2"]],
  SuggestedOtherPackages := [["gapdoc", ">=1.5.1"],
                             ["grape", ">=4.8.1"],
                             ["nautytracesinterface", ">=0.2"]],
  ExternalConditions := [],
),

AvailabilityTest := function()
  local digraphs_so;
  digraphs_so := Filename(DirectoriesPackagePrograms("digraphs"),
                          "digraphs.so");
  if (not "digraphs" in SHOW_STAT()) and digraphs_so = fail then
     LogPackageLoadingMessage(PACKAGE_WARNING,
                              ["the kernel module is not compiled, ",
                               "the package cannot be loaded."]);
    return fail;
  fi;
  return true;
end,

Autoload := false,
TestFile := "tst/testinstall.tst",
Keywords := []
));
