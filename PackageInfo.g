############################################################################
##
#W  PackageInfo.g
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

##  <#GAPDoc Label="PKGVERSIONDATA">
##  <!ENTITY VERSION "0.1">
##  <!ENTITY GAPVERS "4.7.5">
##  <!ENTITY GRAPEVERS "4.5">
##  <!ENTITY IOVERS "4.4.4">
##  <!ENTITY ARCHIVENAME "graphs-0.1">
##  <!ENTITY COPYRIGHTYEARS "2014">
##  <#/GAPDoc>

SetPackageInfo( rec(
PackageName := "Graphs",
Subtitle := "Methods for graphs",
Version := "0.1",
Date := "??",
ArchiveURL := "http://tinyurl.com/jdmitchell/graphs/graphs-0.1",
ArchiveFormats := ".tar.gz",
Persons := [
  rec( 
    LastName      := "Mitchell",
    FirstNames    := "J. D.",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "jdm3@st-and.ac.uk",
    WWWHome       := "tinyurl.com/jdmitchell",
    PostalAddress := Concatenation( [
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,", 
                       " Scotland"] ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
  ),
  
  rec( 
    LastName      := "Jonusas",
    FirstNames    := "J.",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "jj252@st-and.ac.uk",
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
    Email         := "mct25@st-and.ac.uk",
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
    Email         := "waw7@st-and.ac.uk",
    WWWHome       := "http://www-groups.mcs.st-and.ac.uk/~waw7/",
    PostalAddress := Concatenation( [
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,", 
                       " Scotland"] ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
  )],

Status := "deposited",

README_URL := 
  "http://www-groups.mcs.st-andrews.ac.uk/~jamesm/graphs/README",
PackageInfoURL := 
  "http://www-groups.mcs.st-andrews.ac.uk/~jamesm/graphs/PackageInfo.g",

AbstractHTML := "",

PackageWWWHome := "http://www-groups.mcs.st-andrews.ac.uk/~jamesm/graphs.php",
               
PackageDoc := rec(
  BookName  := "Graphs",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",  
  SixFile   := "doc/manual.six",
  LongTitle := "Graphs - Methods for graphs",
  Autoload  := true,
),

Dependencies := rec(
  GAP := ">=4.7.5",
  NeededOtherPackages := [["io", ">=4.4.4"]],
  SuggestedOtherPackages := [["gapdoc", ">=1.5.1"], ["grape", ">=4.5"]], 
  ExternalConditions := [],
),

  AvailabilityTest := function()
    if (not "graphs" in SHOW_STAT()) and
      (Filename(DirectoriesPackagePrograms("graphs"), "graphs.so") = fail)
     then
      Info(InfoWarning, 1, "Graphs: the kernel module is not compiled, ",
      "the package cannot be loaded.");
      return fail;
    fi;
    return true;
  end,
  Autoload := false,
  TestFile := "tst/testinstall.tst",
  Keywords := []
));
