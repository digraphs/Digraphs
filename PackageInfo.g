#############################################################################
##  
##  Demo PackageInfo.g for the GitHubPagesForGAP
##

SetPackageInfo( rec(

PackageName := "GitHubPagesForGAP",

Subtitle := "A GitHub Pages generator for GAP packages",
Version := "0.4",
Date := "10/04/2025", # dd/mm/yyyy format
License := "0BSD",

Persons := [
  rec(
    LastName      := "Horn",
    FirstNames    := "Max",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "mhorn@rptu.de",
    WWWHome       := "https://www.quendi.de/math",
    GitHubUsername:= "fingolfin",
    PostalAddress := Concatenation(
                       "Fachbereich Mathematik\n",
                       "RPTU Kaiserslautern-Landau\n",
                       "Gottlieb-Daimler-Straße 48\n",
                       "67663 Kaiserslautern\n",
                       "Germany" ),
    Place         := "Kaiserslautern, Germany",
    Institution   := "RPTU Kaiserslautern-Landau"
  ),

  rec(
    LastName      := "Thor",
    FirstNames    := "A. U.",
    IsAuthor      := true,
    IsMaintainer  := false,
    #Email         := "author@example.com",
  ),

  rec(
    LastName      := "Itor",
    FirstNames    := "Jan",
    IsAuthor      := false,
    IsMaintainer  := true,
    #Email         := "janitor@example.com",
  ),
],

Status := "other",

# The following are not strictly necessary in your own PackageInfo.g
# (in the sense that update.g only looks at the usual fields
# like PackageWWWHome, ArchiveURL etc.). But they are convenient
# if you use exactly the scheme for your package website that we propose.
GithubUser := "gap-system",
GithubRepository := ~.PackageName,
GithubWWW := Concatenation("https://github.com/", ~.GithubUser, "/", ~.GithubRepository),

PackageWWWHome := Concatenation("https://", ~.GithubUser, ".github.io/", ~.GithubRepository, "/"),
README_URL     := Concatenation( ~.PackageWWWHome, "README.md" ),
PackageInfoURL := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),
# The following assumes you are using the Github releases system. If not, adjust
# it accordingly.
ArchiveURL     := Concatenation(~.GithubWWW,
                    "/releases/download/v", ~.Version, "/",
                    ~.GithubRepository, "-", ~.Version),

ArchiveFormats := ".tar.gz .tar.bz2",

AbstractHTML := 
  "This is a pseudo package that contains no actual\
  <span class=\"pkgname\">GAP</span> code. Instead, it is a template for other\
  GAP packages that allows to quickly setup GitHub Pages.",

PackageDoc := rec(
  BookName  := "GitHubPagesForGAP",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "A GitHub Pages generator for GAP packages",
),

# The following dependencies are fake and for testing / demo purposes
Dependencies := rec(
  GAP := ">=4.8.1",
  NeededOtherPackages := [
    ["GAPDoc", ">= 1.2"],
    ["IO", ">= 4.1"],
  ],
  SuggestedOtherPackages := [["orb", ">= 4.2"]],
  ExternalConditions := []
),

AvailabilityTest := ReturnTrue,

Keywords := ["GitHub Pages", "GAP"]

));


