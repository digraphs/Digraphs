#############################################################################
##
#W  utils.gi
#Y  Copyright (C) 2013-17                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
## This file contains some utilities for use with the Digraphs package.

#############################################################################
# Internal stuff
#############################################################################

BindGlobal("DIGRAPHS_DocXMLFiles", ["attr.xml",
                                    "bliss.xml",
                                    "cliques.xml",
                                    "digraph.xml",
                                    "display.xml",
                                    "grahom.xml",
                                    "grape.xml",
                                    "io.xml",
                                    "oper.xml",
                                    "orbits.xml",
                                    "prop.xml",
                                    "utils.xml",
                                    "../PackageInfo.g"]);

BindGlobal("DIGRAPHS_TestRec", rec());
MakeReadWriteGlobal("DIGRAPHS_TestRec");

InstallGlobalFunction(DIGRAPHS_StartTest,
function()
  DIGRAPHS_TestRec.InfoLevelInfoWarning  := InfoLevel(InfoWarning);
  DIGRAPHS_TestRec.InfoLevelInfoDigraphs := InfoLevel(InfoDigraphs);

  SetInfoLevel(InfoWarning, 0);
  SetInfoLevel(InfoDigraphs, 0);
  return;
end);

InstallGlobalFunction(DIGRAPHS_StopTest,
function()
  SetInfoLevel(InfoWarning, DIGRAPHS_TestRec.InfoLevelInfoWarning);
  SetInfoLevel(InfoDigraphs, DIGRAPHS_TestRec.InfoLevelInfoDigraphs);
  return;
end);

InstallGlobalFunction(DIGRAPHS_TestDir,
function(arg)
  local dir, args, file_ext, is_testable, contents, passed, elapsed, filename,
  split, print_file, pos, range, opts, start, str;

  dir  := arg[1];
  args := arg{[2 .. Length(arg)]};

  file_ext := function(str)
    local split;
    split := SplitString(str, ".");
    if Length(split) > 1 then
      return split[Length(split)];
    else
      return "";
    fi;
  end;

  is_testable := function(dir, file)
    local stringfile, str;
    file := Concatenation(dir, "/", file);
    stringfile := StringFile(file);
    for str in DIGRAPHS_OmitFromTests do
      if PositionSublist(stringfile, str) <> fail then
        Print("not testing ", file, ", it contains a test involving ",
              str, ", which will not work . . .\n\n");
        return false;
      fi;
    od;
    return true;
  end;

  if Length(DIGRAPHS_OmitFromTests) > 0 then
    Print("not testing files containing the strings");
    for str in DIGRAPHS_OmitFromTests do
      Print(PRINT_STRINGIFY(", \"", str, "\""));
    od;
    Print(PRINT_STRINGIFY(" . . .\n\n"));
  fi;

  contents := ["../testinstall.tst"];
  Append(contents, DirectoryContents(dir));

  passed := true;
  elapsed := 0;
  for filename in contents do
    if file_ext(filename) = "tst" and is_testable(dir, filename) then
      filename := Filename(Directory(dir), filename);
      if Length(args) > 0 and IsBool(args[1]) and args[1] then
        split  := SplitString(filename, "/");
        if split[Length(split)] = "testinstall.tst" then
          print_file := "tst/testinstall.tst";
        else
          pos    := Position(split, "tst");
          if pos <> fail then
            range := [pos .. Length(split)];
          else
            range := [Length(split) - 2 .. Length(split)];
          fi;
          print_file := JoinStringsWithSeparator(split{range}, "/");
        fi;
        opts := rec(showProgress := "some");
        Print("Testing file: ", print_file, " . . .\n");
      else
        opts := rec(showProgress := false);
      fi;
      start := Runtime();
      if not Test(filename, opts) then
        passed := false;
      fi;
      elapsed := elapsed + Runtime() - start;
    fi;
  od;
  Print("Total: ", String(elapsed), " msecs\n");
  return passed;
end);

InstallGlobalFunction(DIGRAPHS_ManualExamples,
function()
  return ExtractExamples(DirectoriesPackageLibrary("digraphs", "doc"),
                         "main.xml", DIGRAPHS_DocXMLFiles, "Single");
end);

InstallGlobalFunction(DIGRAPHS_Dir,
function()
  return PackageInfo("digraphs")[1]!.InstallationPath;
end);

#############################################################################
# User facing stuff
#############################################################################

InstallGlobalFunction(DigraphsTestAll,
function()

  DigraphsMakeDoc();
  Print("\n");

  if not DigraphsTestStandard() then
    Print("Abort: DigraphsTestAll failed . . . \n");
    return false;
  fi;

  DigraphsTestManualExamples();
  return;
end);

InstallGlobalFunction(DigraphsTestInstall,
function(arg)
  return Test(Filename(DirectoriesPackageLibrary("digraphs", "tst"),
              "testinstall.tst"));
end);

InstallGlobalFunction(DigraphsTestStandard,
function()
  return DIGRAPHS_TestDir(Concatenation(DIGRAPHS_Dir(), "/tst/standard"));
end);

InstallGlobalFunction(DigraphsTestExtreme,
function()
  local file, dir;
  file := Filename(DirectoriesPackageLibrary("digraphs", "digraphs-lib"),
                   "extreme.d6.gz");
  if file = fail then
    ErrorNoReturn("Digraphs: DigraphsTestExtreme:\n",
                  "the file pkg/digraphs/digraphs-lib/extreme.d6.gz is ",
                  "required\nfor these tests to run. Please install the ",
                  "'digraphs-lib'\narchive from:\n\n",
                  "http://gap-packages.github.io/Digraphs/",
                  "\n\nand try again,");
  fi;
  dir  := Concatenation(PackageInfo("digraphs")[1]!.InstallationPath,
                                    "/tst/extreme");
  return DIGRAPHS_TestDir(Concatenation(DIGRAPHS_Dir(), "/tst/extreme"), true);
end);

InstallGlobalFunction(DigraphsMakeDoc,
function()
  MakeGAPDocDoc(Concatenation(PackageInfo("digraphs")[1]!.
                              InstallationPath, "/doc"),
                "main.xml", DIGRAPHS_DocXMLFiles, "Digraphs", "MathJax",
                "../../..");
  return;
end);

InstallGlobalFunction(DigraphsTestManualExamples,
function(arg)
  local exlists, indices, omit, oldscr, passed, pad, total, l, sp, bad, s,
  start_time, test, end_time, elapsed, pex, str, j, ex, i;

  exlists := DIGRAPHS_ManualExamples();
  if Length(arg) > 0 then
    if Length(arg) = 1 and IsList(arg[1]) then
      return CallFuncList(DigraphsTestManualExamples, arg[1]);
    elif ForAll(arg, x -> IsPosInt(x) and x <= Length(exlists)) then
      indices := arg;
    else
      ErrorNoReturn("DigraphsTestManualExamples: the arguments must be ",
                    "positive integers or a list of positive integers ",
                    "not greater than ", Length(exlists), ",");
    fi;
  else
    omit := DIGRAPHS_OmitFromTests;
    if Length(omit) > 0 then
      Print("# not testing examples containing the strings:");
      for str in omit do
        exlists := Filtered(exlists,
                            x -> PositionSublist(x[1][1], str) = fail);
        Print(", \"", str, "\"");
      od;
      Print(" . . .\n");
    fi;
    indices := [1 .. Length(exlists)];
  fi;

  DIGRAPHS_StartTest();

  oldscr := SizeScreen();
  SizeScreen([72, oldscr[2]]);
  passed := true;
  pad := function(nr)
    nr := Length(String(Length(exlists))) - Length(String(nr)) + 1;
    return List([1 .. nr], x -> ' ');
  end;
  total := 0;
  for j in indices do
    l := exlists[j];
    Print("# Running example ", j, pad(j), " . . .");
    START_TEST("");
    for ex in l do
      sp := SplitString(ex[1], "\n", "");
      bad := Filtered([1 .. Length(sp)], i -> Length(sp[i]) > 72);
      s := InputTextString(ex[1]);

      start_time := IO_gettimeofday();
      test := Test(s, rec(ignoreComments := false,
                          width := 72,
                          EQ := EQ,
                          reportDiff := Ignore,
                          showProgress := false));
      end_time := IO_gettimeofday();
      CloseStream(s);
      elapsed := (end_time.tv_sec - start_time.tv_sec) * 1000
                 + Int((end_time.tv_usec - start_time.tv_usec) / 1000);
      total := total + elapsed;
      pex := TEST.lastTestData;

      Print(" msecs: ", elapsed, "\n");

      if Length(bad) > 0 then
        Print("\033[31m# WARNING: Overlong lines ", bad, " in\n",
              ex[2][1], ":", ex[2][2], "\033[0m\n");
        passed := false;
      fi;

      if test = false then
        for i in [1 .. Length(pex[1])] do
          if EQ(pex[2][i], pex[4][i]) <> true then
            Print("\033[31m########> Diff in:\n",
                  "# ", ex[2][1], ":", ex[2][2],
                  "\n# Input is:\n");
            PrintFormattedString(pex[1][i]);
            Print("# Expected output:\n");
            PrintFormattedString(pex[2][i]);
            Print("# But found:\n");
            PrintFormattedString(pex[4][i]);
            Print("########\033[0m\n");
            passed := false;
          fi;
        od;
      fi;
    od;
  od;
  SizeScreen(oldscr);
  DIGRAPHS_StopTest();
  if Length(indices) > 1 then
    Print("Total: ", total, " msecs\n");
  fi;
  return passed;
end);

# The following is based on doc/ref/testconsistency.g

# Detect which ManSection should be used to document obj. Returns one of
# "Func", "Oper", "Meth", "Filt", "Prop", "Attr", "Var", "Fam", "InfoClass"
#
# See PRINT_OPERATION where some of the code below is borrowed

DIGRAPHS_ManSectionType := function(op)
  local   class, flags, types, catok, repok, propok, seenprop, t;
  if IsInfoClass(op) then
    return "InfoClass";
  elif IsFamily(op) then
    return "Fam";
  elif not IsFunction(op) then
    return "Var";
  elif IsFunction(op) and not IsOperation(op) then
    return "Func";
  elif IsOperation(op) then
    class := "Oper";
    if IS_IDENTICAL_OBJ(op, IS_OBJECT) then
      class := "Filt";
    elif op in CONSTRUCTORS then
      class := "Constructor";
      # seem to never get one
    elif IsFilter(op) then
      class := "Filt";
      flags := TRUES_FLAGS(FLAGS_FILTER(op));
      types := INFO_FILTERS{flags};
      catok := true;
      repok := true;
      propok := true;
      seenprop := false;
      for t in types do
        if not t in FNUM_REPS then
          repok := false;
        fi;
        if not t in FNUM_CATS then
          catok := false;
        fi;
        if not t in FNUM_PROS and not t in FNUM_TPRS then
          propok := false;
        fi;
        if t in FNUM_PROS then
          seenprop := true;
        fi;
      od;
      if seenprop and propok then
        class := "Prop";
      elif catok then
        class := "Filt";
        # in PRINT_OPERATION - "Category";
      elif repok then
        class := "Filt";
        # in PRINT_OPERATION - "Representation";
      fi;
    elif Tester(op) <> false  then
      # op is an attribute
      class := "Attr";
    fi;
    return class;
  else
    return fail;
  fi;
end;

# Checks whether ManSections are using the right kind of elements

DIGRAPHS_CheckManSectionTypes := function(doc, verbose...)
  local display_warnings, types, r, x, errcount, name, pos, obj, man, y, yint,
  referrcount, warncount, type, matches, match, matches2, stats,
  elt, t, s;

  if Length(verbose) = 0 then
    display_warnings := false;
  else
    display_warnings := verbose[1];
  fi;
  types := ["Func", "Oper", "Meth", "Filt", "Prop", "Attr", "Var", "Fam",
            "InfoClass"];
  r := ParseTreeXMLString(doc[1]);
  CheckAndCleanGapDocTree(r);
  x := XMLElements(r, types);
  errcount := 0;
  Print("****************************************************************\n");
  Print("*** Checking types in ManSections \n");
  Print("****************************************************************\n");
  for elt in x do
    name := elt.attributes.Name;
    if not name in ["IsBound", "Unbind", "Info", "Assert", "TryNextMethod",
                    "QUIT", "-infinity"] then
      if EvalString(Concatenation("IsBound(", name, ")")) <> true then
        pos := OriginalPositionDocument(doc[2], elt.start);
        Print(pos[1], ":", pos[2], " : ", name, " is unbound \n");
        errcount := errcount + 1;
      else
        obj := EvalString(name);
        man := DIGRAPHS_ManSectionType(obj);
        # we allow to use "Meth" for "Oper" but probably should issue a warning
        # if there is no at least one "Oper" for any "Meth"
        if (man <> elt.name)
            and not (man in ["Attr", "Prop", "Oper"] and elt.name = "Meth") then
          pos := OriginalPositionDocument(doc[2], elt.start);
          Print(pos[1], ":", pos[2], " : ", name, " uses ", elt.name,
                " instead of ", man, "\n");
          errcount := errcount + 1;
        fi;
      fi;
    fi;
  od;

  Print("****************************************************************\n");
  Print("*** Checking types in cross-references \n");
  Print("****************************************************************\n");
  y := XMLElements(r, ["Ref"]);
  Print("Found ", Length(y), " Ref elements ");
  yint := Filtered(y, elt ->
                      not IsBound(elt.attributes.BookName)
                      or (IsBound(elt.attributes.BookName)
                          and elt.attributes.BookName = "ref"));
  Print("including ", Length(yint), " within the Reference manual\n");
  y := Filtered(yint, elt -> ForAny(types, t -> IsBound(elt.attributes.(t))));

  referrcount := 0;
  warncount := 0;
  for elt in y do
    type := First(types, t -> IsBound(elt.attributes.(t)));
    if type <> fail then
      matches := Filtered(x, t -> t.attributes.Name = elt.attributes.(type));
      if Length(matches) = 0 then
        pos := OriginalPositionDocument(doc[2], elt.start);
        Print(pos[1], ":", pos[2], " : no match for ", type, " := ",
              elt.attributes.(type), "\n");
        referrcount := referrcount + 1;
        continue;
      elif Length(matches) = 1 then
        match := matches[1];
      elif IsBound(elt.attributes.Label) then
        matches := Filtered(matches, t -> IsBound(t.attributes.Label));
        matches := Filtered(matches, t -> t.attributes.Label =
                                          elt.attributes.Label);
        if Length(matches) > 1 then
          ErrorNoReturn("Digraphs: DIGRAPHS_CheckManSectionTypes:\n",
                        "Multiple labels - this should not happen!");
        fi;
        match := matches[1];
      else
        matches2 := Filtered(matches, t -> not IsBound(t.attributes.Label));
        if Length(matches2) = 0 then
          pos := OriginalPositionDocument(doc[2], elt.start);
          Print(pos[1], ":", pos[2],
                " : no match (wrong type or missing label?) for ", type, " := ",
                elt.attributes.(type), "\n");
          Print("  Suggestions: \n");
          matches := Filtered(matches, t -> IsBound(t.attributes.Label));
          for t in matches do
            Print("Use ", t.name, " with Label := \"", t.attributes.Label,
                  "\" (for Arg := \"", t.attributes.Arg, "\")\n");
          od;

          referrcount := referrcount + 1;
          continue;
        elif Length(matches2) > 1 then
          ErrorNoReturn("Digraphs: DIGRAPHS_CheckManSectionTypes:\n",
                        "Multiple labels - this should not happen!");
        else
          match := matches[1];
        fi;
      fi;
      if match.name <> type then
        pos := OriginalPositionDocument(doc[2], elt.start);
        if display_warnings then
          Print(pos[1], ":", pos[2], "\n\tRef to ", elt.attributes.(type),
                " uses ", type, " instead of ", match.name, "\n");
        fi;
        warncount := warncount + 1;
      fi;
    fi;
  od;

  Print("****************************************************************\n");
  stats := Collected(List(x, elt -> elt.name));
  Print("Selected ", Length(x), " ManSections of the following types:\n");
  for s in stats do
    Print(s[1], " - ", s[2], "\n");
  od;
  Print("Found ", errcount, " errors in ManSection types \n");

  Print("Selected ", Length(y), " Ref elements referring to ManSections \n");
  Print("Found ", referrcount, " errors and ", warncount,
        " warnings in Ref elements \n");

  if display_warnings then
    Print("To suppress warnings, use DIGRAPHS_CheckManSectionTypes(doc,false) ",
          "or with one argument\n");
  else
    Print("To show warnings, use DIGRAPHS_CheckManSectionTypes(doc,true); \n");
  fi;
  Print("****************************************************************\n");
  return errcount = 0;
end;

DIGRAPHS_CheckDocCoverage := function(doc)
  local r, x, with, without, mansect, pos, y;
  r := ParseTreeXMLString(doc[1]);
  CheckAndCleanGapDocTree(r);
  x := XMLElements(r, ["ManSection"]);
  with := 0;
  without := 0;
  Print("****************************************************************\n");
  Print("*** Looking for ManSections having no examples \n");
  Print("****************************************************************\n");
  for mansect in x do
    pos := OriginalPositionDocument(doc[2], mansect.start);
    y := XMLElements(mansect, ["Example"]);
    if Length(y) = 0 then
      if IsBound(mansect.content[1].attributes) and
          IsBound(mansect.content[1].attributes.Name) then
        Print(pos[1], ":", pos[2], " : ", mansect.content[1].attributes.Name);
      elif IsBound(mansect.content[2].attributes) and
          IsBound(mansect.content[2].attributes.Name) then
        Print(pos[1], ":", pos[2], " : ", mansect.content[2].attributes.Name);
      else
        Print(pos[1], ":", pos[2], " : ",
              mansect.content[1].content[1].content);
      fi;
      without := without + 1;
      Print("\n");
    else
      with := with + 1;
    fi;
  od;
  Print("****************************************************************\n");
  Print("*** Doc coverage report \n");
  Print("****************************************************************\n");
  Print(Length(x), " mansections \n");
  Print(with, " with examples \n");
  Print(without, " without examples \n");
end;

DIGRAPHS_CheckManualConsistency := function()
  local doc;

  doc := ComposedXMLString(Concatenation(DIGRAPHS_Dir(), "/doc"),
                           "main.xml",
                           DIGRAPHS_DocXMLFiles,
                           true);
  DIGRAPHS_CheckDocCoverage(doc);
  return DIGRAPHS_CheckManSectionTypes(doc, true);
end;
