#############################################################################
##  
##  Demo PackageInfo.g for the GitHubPagesForGAP
##

SetPackageInfo( rec(

PackageName := "GitHubPagesForGAP",

Subtitle := "A GitHubPages generator for GAP packages",
Version := "0.1",
Date := "21/03/2014", # dd/mm/yyyy format

Persons := [
  rec(
    LastName      := "Horn",
    FirstNames    := "Max",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "max.horn@math.uni-giessen.de",
    WWWHome       := "http://www.quendi.de/math",
    PostalAddress := Concatenation(
                       "AG Algebra\n",
                       "Mathematisches Institut\n",
                       "Justus-Liebig-Universität Gießen\n",
                       "Arndtstraße 2\n",
                       "35392 Gießen\n",
                       "Germany" ),
    Place         := "Gießen",
    Institution   := "Justus-Liebig-Universität Gießen"
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
GithubUser := "fingolfin",
GithubRepository := ~.PackageName,
GithubWWW := Concatenation("https://github.com/", ~.GithubUser, "/", ~.GithubRepository),

PackageWWWHome := Concatenation("http://", ~.GithubUser, ".github.io/", ~.GithubRepository, "/"),
README_URL     := Concatenation( ~.PackageWWWHome, "README" ),
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
  GAP packages that allows to quickly setup GitHub pages.",

PackageDoc := rec(
  BookName  := "GitHubPagesForGAP",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "A GitHubPages generator for GAP packages",
),

# The following dependencies are fake and for testing / demo purposes
Dependencies := rec(
  GAP := ">=4.5.5",
  NeededOtherPackages := [
    ["GAPDoc", ">= 1.2"],
    ["IO", ">= 4.1"],
  ],
  SuggestedOtherPackages := [["orb", ">= 4.2"]],
  ExternalConditions := []
),

AvailabilityTest := ReturnTrue,

Keywords := ["GitHub pages", "GAP"]

));


