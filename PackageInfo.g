#############################################################################
##
##  PackageInfo.g
##  Copyright (C) 2015-21                                James D. Mitchell
##
##  Licensing information can be found in the README.md file of this package.
##
#############################################################################
##

##  <#GAPDoc Label="PKGVERSIONDATA">
##  <!ENTITY VERSION                  "1.5.0">
##  <!ENTITY GAPVERS                  "4.10.0">
##  <!ENTITY GRAPEVERS                "4.8.1">
##  <!ENTITY IOVERS                   "4.5.1">
##  <!ENTITY ORBVERS                  "4.8.2">
##  <!ENTITY DATASTRUCTURESVERS       "0.2.5">
##  <!ENTITY NAUTYTRACESINTERFACEVERS "0.2">
##  <!ENTITY ARCHIVENAME    "digraphs-1.5.0">
##  <!ENTITY COPYRIGHTYEARS "2014-21">
##  <#/GAPDoc>

_STANDREWSMATHS := Concatenation(["Mathematical Institute, North Haugh, ",
                                  "St Andrews, Fife, KY16 9SS, Scotland"]);
_STANDREWSCS := Concatenation(["Jack Cole Building, North Haugh, ",
                               "St Andrews, Fife, KY16 9SX, Scotland"]);

SetPackageInfo(rec(
PackageName := "Digraphs",
Subtitle := "Graphs, digraphs, and multidigraphs in GAP",
Version := "1.5.0",
Date := "27/10/2021",  # dd/mm/yyyy format
License := "GPL-3.0-or-later",
ArchiveFormats := ".tar.gz",

SourceRepository := rec(
    Type := "git",
    URL := Concatenation("https://github.com/digraphs/",
                         ~.PackageName),
),

Persons := [

  rec(
    LastName      := "Anagnostopoulou-Merkouri",
    FirstNames    := "Marina",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "mam49@st-andrews.ac.uk",
    PostalAddress := _STANDREWSMATHS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

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
    LastName      := "Buck",
    FirstNames    := "Finn",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "flb5@st-andrews.ac.uk",
    PostalAddress := _STANDREWSMATHS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Burrell",
    FirstNames    := "Stuart",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "sb235@st-andrews.ac.uk",
    PostalAddress := Concatenation([
                       "CREEM, The Observatory, Buchanan Gardens, ",
                       "St Andrews, Fife, KY16 9LZ, Scotland"]),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Cirpons",
    FirstNames    := "Reinis",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "rc234@st-andrews.ac.uk",
    PostalAddress := _STANDREWSMATHS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Conti-Leslie",
    FirstNames    := "Tom",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "tdcl@st-andrews.ac.uk",
    PostalAddress := _STANDREWSMATHS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Elliott",
    FirstNames    := "Luke",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "le27@st-andrews.ac.uk",
    PostalAddress := _STANDREWSMATHS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Gilligan",
    FirstNames    := "Ewan",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "eg207@st-andrews.ac.uk",
    PostalAddress := _STANDREWSMATHS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

rec(
    LastName      := "Harper",
    FirstNames    := "Samantha",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "seh25@st-andrews.ac.uk",
    PostalAddress := _STANDREWSMATHS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Horn",
    FirstNames    := "Max",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "horn@mathematik.uni-kl.de",
    WWWHome       := "https://www.quendi.de/math",
    PostalAddress := Concatenation(
                       "Fachbereich Mathematik, TU Kaiserslautern, ",
                       "Gottlieb-Daimler-Straße 48, 67663 Kaiserslautern, ",
                       "Germany"),
    Place         := "Kaiserslautern, Germany",
    Institution   := "TU Kaiserslautern"),

  rec(
    LastName      := "Jefferson",
    FirstNames    := "Christopher",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "caj21@st-andrews.ac.uk",
    WWWHome       := "https://caj.host.cs.st-andrews.ac.uk",
    PostalAddress := _STANDREWSCS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Jonusas",
    FirstNames    := "Julius",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "julius.jonusas@tuwien.ac.at",
    WWWHome       := "http://julius.jonusas.work",
    PostalAddress := Concatenation([
                       "Institut für Diskrete Mathematik und Geometrie, ",
                       "Wiedner Hauptstrasse 8-10, 1040 Wien, Austria"]),
    Place         := "Wien, Austria",
    Institution   := "TU Wien"),

  rec(
    LastName      := "Mitchell",
    FirstNames    := "James",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "jdm3@st-and.ac.uk",
    WWWHome       := "https://jdbm.me",
    PostalAddress := _STANDREWSMATHS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Pfeiffer",
    FirstNames    := "Markus",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "markus.pfeiffer@morphism.de",
    WWWHome       := "https://www.morphism.de/~markusp",
    PostalAddress := _STANDREWSCS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Racine",
    FirstNames    := "Lea",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "lr217@st-andrews.ac.uk",
    PostalAddress := _STANDREWSMATHS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Russell",
    FirstNames    := "Christopher",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "cr66@st-andrews.ac.uk",
    PostalAddress := _STANDREWSMATHS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Smith",
    FirstNames    := "Finn",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "fls3@st-andrews.ac.uk",
    PostalAddress := _STANDREWSMATHS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Spiers",
    FirstNames    := "Ben",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "bs201@st-andrews.ac.uk",
    PostalAddress := _STANDREWSMATHS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Tsalakou",
    FirstNames    := "Maria",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "mt200@st-andrews.ac.uk",
    WWWHome       := "https://mariatsalakou.github.io/",
    PostalAddress := _STANDREWSMATHS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Whyte",
    FirstNames    := "Murray",
    IsAuthor      := false,
    IsMaintainer  := false,
    Email         := "mw231@st-andrews.ac.uk",
    PostalAddress := _STANDREWSMATHS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews"),

  rec(
    LastName      := "Wilson",
    FirstNames    := "Wilf A.",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "gap@wilf-wilson.net",
    WWWHome       := "https://wilf.me"),

  rec(
    LastName      := "Young",
    FirstNames    := "Michael",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "mct25@st-andrews.ac.uk",
    WWWHome       := "https://mct25.host.cs.st-andrews.ac.uk",
    PostalAddress := _STANDREWSCS,
    Place         := "St Andrews",
    Institution   := "University of St Andrews")],

Status := "deposited",

IssueTrackerURL := Concatenation(~.SourceRepository.URL, "/issues"),
PackageWWWHome  := Concatenation("https://digraphs.github.io/",
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
  GAP := ">=4.10.0",
  NeededOtherPackages := [["io", ">=4.5.1"],
                          ["orb", ">=4.8.2"],
                          ["datastructures", ">=0.2.5"]],
  SuggestedOtherPackages := [["GAPDoc", ">=1.6.3"],
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
TestFile := "tst/teststandard.g",
Keywords := []
));
