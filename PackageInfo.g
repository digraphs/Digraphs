#############################################################################
##
##  PackageInfo.g
##  Copyright (C) 2015-24                                  James D. Mitchell
##
##  Licensing information can be found in the README.md file of this package.
##
#############################################################################
##

BindGlobal("_RecogsFunnyNameFormatterFunction",
function(st)
  if IsEmpty(st) then
    return st;
  else
    return Concatenation(" (", st, ")");
  fi;
end);

BindGlobal("_RecogsFunnyWWWURLFunction",
function(re)
  if IsBound(re.WWWHome) then
    return re.WWWHome;
  else
    return "";
  fi;
end);

_STANDREWSMATHS := Concatenation(["Mathematical Institute, North Haugh, ",
                                  "St Andrews, Fife, KY16 9SS, Scotland"]);
_STANDREWSCS := Concatenation(["Jack Cole Building, North Haugh, ",
                               "St Andrews, Fife, KY16 9SX, Scotland"]);

if not CompareVersionNumbers(GAPInfo.Version, "4.12") then
  IsKernelExtensionAvailable := fail;
fi;

SetPackageInfo(rec(
PackageName := "Digraphs",
Subtitle := "Graphs, digraphs, and multidigraphs in GAP",
Version := "1.13.1",
Date := "27/09/2025",  # dd/mm/yyyy format
License := "GPL-3.0-or-later",
ArchiveFormats := ".tar.gz",

SourceRepository := rec(
    Type := "git",
    URL := Concatenation("https://github.com/digraphs/",
                         ~.PackageName),
),

Persons := [

 # The 5 main authors come first
 rec(
    LastName       := "De Beule",
    FirstNames     := "Jan",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "jdebeule@cage.ugent.be",
    GithubUsername := "jdebeule",
    WWWHome        := "https://researchportal.vub.be/en/persons/jan-de-beule",
    PostalAddress  := Concatenation([
                      "Vrije Universiteit Brussel, ",
                      " Vakgroep Wiskunde, ",
                      " Pleinlaan 2, ",
                      " B - 1050 Brussels, ",
                      " Belgium"]),
    Place          := "Brussels",
    Institution    := "Vrije Universiteit Brussel"),

  rec(
    LastName       := "Jonusas",
    FirstNames     := "Julius",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "j.jonusas@gmail.com",
    GithubUsername := "jjonusas",
    WWWHome        := "http://julius.jonusas.work",
    Place          := "Brussels, Belgium"),

  rec(
    LastName       := "Mitchell",
    FirstNames     := "James",
    IsAuthor       := true,
    IsMaintainer   := true,
    Email          := "jdm3@st-andrews.ac.uk",
    GithubUsername := "james-d-mitchell",
    WWWHome        := "https://jdbm.me",
    PostalAddress  := _STANDREWSMATHS,
    Place          := "St Andrews",
    Institution    := "University of St Andrews"),

  rec(
    LastName       := "Wilson",
    FirstNames     := "Wilf A.",
    IsAuthor       := true,
    IsMaintainer   := true,
    Email          := "gap@wilf-wilson.net",
    GithubUsername := "wilfwilson",
    WWWHome        := "https://wilf.me"),

  rec(
    LastName       := "Young",
    FirstNames     := "Michael",
    IsAuthor       := true,
    IsMaintainer   := true,
    Email          := "mct25@st-andrews.ac.uk",
    GithubUsername := "mtorpey",
    WWWHome        := "https://myoung.uk/work/",
    PostalAddress  := _STANDREWSCS,
    Place          := "St Andrews",
    Institution    := "University of St Andrews"),

 # All other contributors from here on...
  rec(
    LastName       := "Anagnostopoulou-Merkouri",
    FirstNames     := "Marina",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "mam49@st-andrews.ac.uk",
    GithubUsername := "marinaanagno",
    PostalAddress  := _STANDREWSMATHS,
    Place          := "St Andrews",
    Institution    := "University of St Andrews"),

  rec(
    LastName       := "Buck",
    FirstNames     := "Finn",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "finneganlbuck@gmail.com",
    GithubUsername := "finnbuck",
    PostalAddress  := _STANDREWSMATHS,
    Place          := "St Andrews",
    Institution    := "University of St Andrews"),

  rec(
    LastName       := "Burrell",
    FirstNames     := "Stuart",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "stuartburrell1994@gmail.com",
    GithubUsername := "stuartburrell",
    WWWHome        := "https://stuartburrell.github.io"),

  rec(
    LastName       := "Campbell",
    FirstNames     := "Graham",
    IsAuthor       := true,
    IsMaintainer   := false,
    GithubUsername := "GrahamCampbell"),

  rec(
    LastName       := "Chowdhury",
    FirstNames     := "Raiyan",
    IsAuthor       := true,
    IsMaintainer   := false,
    GithubUsername := "RaiyanC"),

  rec(
    LastName       := "Cirpons",
    FirstNames     := "Reinis",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "rc234@st-andrews.ac.uk",
    GithubUsername := "reiniscirpons",
    PostalAddress  := _STANDREWSMATHS,
    Place          := "St Andrews",
    Institution    := "University of St Andrews"),

  rec(
    LastName       := "Clayton",
    FirstNames     := "Ashley",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "ac323@st-andrews.ac.uk",
    GithubUsername := "AshleyClayton",
    PostalAddress  := _STANDREWSMATHS,
    Place          := "St Andrews",
    Institution    := "University of St Andrews"),

  rec(
    LastName       := "Conti-Leslie",
    FirstNames     := "Tom",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "tom.contileslie@gmail.com",
    GithubUsername := "tomcontileslie",
    WWWHome        := "https://tomcontileslie.com"),

  rec(
    LastName       := "Edwards",
    FirstNames     := "Joseph",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "jde1@st-andrews.ac.uk",
    GithubUsername := "Joseph-Edwards",
    PostalAddress  := _STANDREWSMATHS,
    Place          := "St Andrews",
    Institution    := "University of St Andrews",
    WWWHome        := "https://github.com/Joseph-Edwards"),

  rec(
    LastName       := "Elliott",
    FirstNames     := "Luna",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "luna.elliott142857@gmail.com",
    GithubUsername := "le27",
    Institution    := "University of Manchester",
    WWWHome        := Concatenation("https://research.manchester.ac.uk/",
                                    "en/persons/luna-elliott")),

  rec(
    LastName       := "Engelhardt",
    FirstNames     := "Jan",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "jengelh@inai.de",
    GithubUsername := "jengelh",
    WWWHome        := "https://inai.de"),

  rec(
    LastName       := "Fernando",
    FirstNames     := "Isuru",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "isuruf@gmail.com",
    GithubUsername := "isuruf"),

  rec(
    LastName       := "Gilligan",
    FirstNames     := "Ewan",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "eg207@st-andrews.ac.uk",
    GithubUsername := "EwanGilligan"),

  rec(
    LastName       := "Frankie",
    FirstNames     := "Gillis",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "fotg1@st-andrews.ac.uk",
    GithubUsername := "frankiegillis"),

  rec(
    LastName       := "Gutsche",
    FirstNames     := "Sebastian",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "gutsche@momo.math.rwth-aachen.de",
    GithubUsername := "sebasguts"),

  rec(
    LastName       := "Harper",
    FirstNames     := "Samantha",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "seh25@st-andrews.ac.uk",
    GithubUsername := "samanthaharper"),

  rec(
    LastName       := "Horn",
    FirstNames     := "Max",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "mhorn@rptu.de",
    GithubUsername := "fingolfin",
    WWWHome        := "https://www.quendi.de/math",
    PostalAddress  := Concatenation(
                        "Fachbereich Mathematik, ",
                        "RPTU Kaiserslautern-Landau, ",
                        "Gottlieb-Daimler-Straße 48, ",
                        "67663 Kaiserslautern, ",
                        "Germany"),
    Place          := "Kaiserslautern, Germany",
    Institution    := "RPTU Kaiserslautern-Landau"),

  rec(
    LastName       := "Jack",
    FirstNames     := "Harry",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "hrj4@st-andrews.ac.uk",
    GithubUsername := "hrj4"),

  rec(
    LastName       := "Jefferson",
    FirstNames     := "Christopher",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "caj21@st-andrews.ac.uk",
    GithubUsername := "ChrisJefferson",
    WWWHome        := "https://heather.cafe/",
    PostalAddress  := _STANDREWSCS,
    Place          := "St Andrews",
    Institution    := "University of St Andrews"),

  rec(
    LastName       := "Johns",
    FirstNames     := "Malachi",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "zlj1@st-andrews.ac.uk",
    GithubUsername := "zljlzljlz"),

  rec(
    LastName       := "Konovalov",
    FirstNames     := "Olexandr",
    IsAuthor       := true,
    IsMaintainer   := false,
    PostalAddress  := _STANDREWSCS,
    Email          := "obk1@st-andrews.ac.uk",
    GithubUsername := "olexandr-konovalov",
    WWWHome        := "https://olexandr-konovalov.github.io/",
    Place          := "St Andrews",
    Institution    := "University of St Andrews"),

  rec(
    LastName       := "Kwon",
    FirstNames     := "Hyeokjun",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "hk78@st-andrews.ac.uk",
    GithubUsername := "Jun2M"),

  rec(
    LastName       := "Lau",
    FirstNames     := "Aidan",
    IsAuthor       := true,
    IsMaintainer   := false,
    GithubUsername := "forktree"),

  rec(
    LastName       := "Lee",
    FirstNames     := "Andrea",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "ahwl1@st-andrews.ac.uk",
    GithubUsername := "baydrea"),

  rec(
    LastName       := "McIver",
    FirstNames     := "Saffron",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "sm544@st-andrews.ac.uk",
    GithubUsername := "saffronmciver"),

  rec(
    LastName       := "Mohammadiyeh",
    FirstNames     := "Seyyed Ali",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "MaxBaseCode@Gmail.Com",
    GithubUsername := "BaseMax"),

  rec(
    LastName       := "Orlitzky",
    FirstNames     := "Michael",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "michael@orlitzky.com",
    GithubUsername := "orlitzky",
    WWWHome        := "https://michael.orlitzky.com/"),

  rec(
    LastName       := "Pancer",
    FirstNames     := "Matthew",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "mp322@st-andrews.ac.uk",
    GithubUsername := "mpan322"),

  rec(
    LastName       := "Pfeiffer",
    FirstNames     := "Markus",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "markus.pfeiffer@morphism.de",
    GithubUsername := "markuspf",
    WWWHome        := "https://markusp.morphism.de/"),

  rec(
    LastName       := "Pointon",
    FirstNames     := "Daniel",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "dp211@st-andrews.ac.uk",
    GithubUsername := "DanielPointon"),

  rec(
    LastName       := "Ragavan",
    FirstNames     := "Pramoth",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "107881923+pramothragavan@users.noreply.github.com",
    GithubUsername := "pramothragavan"),

  rec(
    LastName       := "Racine",
    FirstNames     := "Lea",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "lr217@st-andrews.ac.uk",
    GithubUsername := "LRacine",
    PostalAddress  := _STANDREWSCS,
    Place          := "St Andrews",
    Institution    := "University of St Andrews"),

  rec(
    LastName       := "Russell",
    FirstNames     := "Christopher",
    IsAuthor       := true,
    IsMaintainer   := false,
    GithubUsername := "ChristopherRussell"),

  rec(
    LastName       := "Schaefer",
    FirstNames     := "Artur",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "as305@st-and.ac.uk"),

  rec(
    LastName       := "Scott",
    FirstNames     := "Isabella",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "iscott@uchicago.edu",
    GithubUsername := "AlanMT",
    Place          := "Chicago",
    Institution    := "University of Chicago"),

  rec(
    LastName       := "Sharma",
    FirstNames     := "Kamran",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "kks4@st-andrews.ac.uk",
    GithubUsername := "KamranKSharma",
    PostalAddress  := _STANDREWSCS,
    Place          := "St Andrews",
    Institution    := "University of St Andrews"),

  rec(
    LastName       := "Smith",
    FirstNames     := "Finn",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "fls3@st-andrews.ac.uk",
    GithubUsername := "flsmith",
    PostalAddress  := _STANDREWSMATHS,
    Place          := "St Andrews",
    Institution    := "University of St Andrews"),

  rec(
    LastName       := "Spiers",
    FirstNames     := "Ben",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "bspiers972@outlook.com",
    GithubUsername := "bspiers"),

  rec(
    LastName       := "Tsalakou",
    FirstNames     := "Maria",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "mt200@st-andrews.ac.uk",
    GithubUsername := "mariatsalakou",
    WWWHome        := "https://mariatsalakou.github.io/",
    PostalAddress  := _STANDREWSMATHS,
    Place          := "St Andrews",
    Institution    := "University of St Andrews"),

  rec(
    LastName       := "Vishvanath",
    FirstNames     := "Agastyaa",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "av215@st-andrews.ac.uk",
    GithubUsername := "BlueRidingHood"),

  rec(
    LastName       := "Weiss",
    FirstNames     := "Meike",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "weiss@art.rwth-aachen.de",
    GithubUsername := "MeikeWeiss",
    WWWHome        := "https://bit.ly/4e6pUeP",
    PostalAddress  := Concatenation("Chair of Algebra and Representation ",
                      "Theory, Pontdriesch 10-16, 52062 Aachen"),
    Place          := "Aachen",
    Institution    := "RWTH-Aachen University"),

  rec(
    LastName       := "Whyte",
    FirstNames     := "Murray",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "mw231@st-andrews.ac.uk",
    GithubUsername := "MTWhyte",
    PostalAddress  := _STANDREWSMATHS,
    Place          := "St Andrews",
    Institution    := "University of St Andrews"),

  rec(
    LastName       := "Zickgraf",
    FirstNames     := "Fabian",
    IsAuthor       := true,
    IsMaintainer   := false,
    Email          := "f.zickgraf@dashdos.com",
    GithubUsername := "zickgraf")],

Status := "deposited",

IssueTrackerURL := Concatenation(~.SourceRepository.URL, "/issues"),
PackageWWWHome  := Concatenation("https://digraphs.github.io/",
                                 ~.PackageName),
README_URL      := Concatenation(~.PackageWWWHome, "/README.md"),
CHANGES_URL     := Concatenation(~.PackageWWWHome, "/CHANGELOG.md"),
PackageInfoURL  := Concatenation(~.PackageWWWHome, "/PackageInfo.g"),
ArchiveURL      := Concatenation(~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/", "digraphs-", ~.Version),

PackageDoc := rec(
  BookName  := "Digraphs",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0_mj.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Digraphs - Methods for digraphs",
  Autoload  := true,
),

Dependencies := rec(
  GAP := ">=4.10.0",
  NeededOtherPackages := [["IO", ">=4.5.1"],
                          ["orb", ">=4.8.2"],
                          ["datastructures", ">=0.2.5"]],
  SuggestedOtherPackages := [["GAPDoc", ">=1.6.3"],
                             ["GRAPE", ">=4.8.1"],
                             ["NautyTracesInterface", ">=0.2"],
                             ["AutoDoc", ">=2020.08.11"]],
  ExternalConditions := [],
),

BannerString := Concatenation(
  "----------------------------------------------------------------------",
  "-------\n",
  "Loading Digraphs ", ~.Version, "\n",
  "by:\n",
  "     ", ~.Persons[1].FirstNames, " ", ~.Persons[1].LastName,
  " (", ~.Persons[1].WWWHome, "),\n",
  "     ", ~.Persons[2].FirstNames, " ", ~.Persons[2].LastName,
  " (", ~.Persons[2].WWWHome, "),\n",
  "     ", ~.Persons[3].FirstNames, " ", ~.Persons[3].LastName,
  " (", ~.Persons[3].WWWHome, "),\n",
  "     ", ~.Persons[4].FirstNames, " ", ~.Persons[4].LastName,
  " (", ~.Persons[4].WWWHome, "),\n",
  "     ", ~.Persons[5].FirstNames, " ", ~.Persons[5].LastName,
       " (", ~.Persons[5].WWWHome, ")\n",
  "with contributions by:\n",
  Concatenation(Concatenation(List(~.Persons{[6 .. Length(~.Persons) - 1]},
       p -> ["     ", p.FirstNames, " ", p.LastName,
       _RecogsFunnyNameFormatterFunction(
         _RecogsFunnyWWWURLFunction(p)), ",\n"]))),
  " and ", ~.Persons[Length(~.Persons)].FirstNames, " ",
  ~.Persons[Length(~.Persons)].LastName,
  _RecogsFunnyNameFormatterFunction(
    _RecogsFunnyWWWURLFunction(~.Persons[Length(~.Persons)])), ".\n",
  "-----------------------------------------------------------------------",
  "------\n"),

AvailabilityTest := function()
  local digraphs_so;

  if CompareVersionNumbers(GAPInfo.Version, "4.12") then
    if not IsKernelExtensionAvailable("digraphs") then
      LogPackageLoadingMessage(PACKAGE_WARNING,
                              ["the kernel module is not compiled, ",
                               "the package cannot be loaded."]);
      return fail;
    fi;
  else
    # TODO this clause can be removed once Digraphs requires GAP>=4.12.1
    digraphs_so := Filename(DirectoriesPackagePrograms("digraphs"),
                            "digraphs.so");
    if (not "digraphs" in SHOW_STAT()) and digraphs_so = fail then
       LogPackageLoadingMessage(PACKAGE_WARNING,
                                ["the kernel module is not compiled, ",
                                 "the package cannot be loaded."]);
      return fail;
    fi;
  fi;
  return true;
end,

Autoload := false,
TestFile := "tst/teststandard.g",

Keywords := [],

AutoDoc := rec(
    TitlePage := rec(
        Copyright := """Jan De Beule, Julius Jonu&#353;as, James D. Mitchell,
          Wilf A. Wilson, Michael Young et al.<P/>

          &Digraphs; is free software; you can redistribute it and/or modify
          it under the terms of the <URL Text="GNU General Public License">
          https://www.fsf.org/licenses/gpl.html</URL> as published by the
          Free Software Foundation; either version 3 of the License, or (at
          your option) any later version.""",
        Abstract := """The &Digraphs; package is a &GAP; package containing
          methods for graphs, digraphs, and multidigraphs.""",
        Acknowledgements := """
          We would like to thank Christopher Jefferson for his help in including
          &BLISS; in &Digraphs;.

          We also gratefully acknowledge the encouragement and assistance of
          Leonard Soicher, and the inspiration of his &GRAPE; package, at many
          points throughout the development of &Digraphs;.

          This package's methods for computing digraph homomorphisms are based
          on work by Max Neunh&#246;ffer, and independently Artur Sch&#228;fer.
        """)),

        AbstractHTML := ReplacedString(ReplacedString(
            ~.AutoDoc.TitlePage.Abstract,
            "&Digraphs;", "<Strong>Digraphs</Strong>"),
            "&GAP;", "<Strong>GAP</Strong>")));

if not CompareVersionNumbers(GAPInfo.Version, "4.12") then
  Unbind(IsKernelExtensionAvailable);
fi;

MakeReadWriteGlobal("_RecogsFunnyWWWURLFunction");
MakeReadWriteGlobal("_RecogsFunnyNameFormatterFunction");
Unbind(_RecogsFunnyWWWURLFunction);
Unbind(_RecogsFunnyNameFormatterFunction);
Unbind(_STANDREWSMATHS);
Unbind(_STANDREWSCS);
