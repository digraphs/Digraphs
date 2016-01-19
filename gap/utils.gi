#############################################################################
##
#W  utils.gi
#Y  Copyright (C) 2013-15                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
## This file contains some utilities for use with the Digraphs package.

#############################################################################
# Internal stuff
#############################################################################

BindGlobal("DIGRAPHS_PF",
function(pass)
  if pass then
    return "\033[1;32mPASSED!\033[0m\n";
  else
    return "\033[1;31mFAILED!\033[0m\n";
  fi;
end);

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
  local record;

  record := DIGRAPHS_TestRec;

  record.timeofday := IO_gettimeofday();
  record.InfoLevelInfoWarning := InfoLevel(InfoWarning);
  record.InfoLevelInfoDigraphs := InfoLevel(InfoDigraphs);

  SetInfoLevel(InfoWarning, 0);
  SetInfoLevel(InfoDigraphs, 0);

  record.STOP_TEST := STOP_TEST;

  MakeReadWriteGlobal("STOP_TEST");
  UnbindGlobal("STOP_TEST");
  BindGlobal("STOP_TEST", DIGRAPHS_StopTest);

  return;
end);

InstallGlobalFunction(DIGRAPHS_StopTest,
function(file)
  local timeofday, record, elapsed, str;

  timeofday := IO_gettimeofday();

  record := DIGRAPHS_TestRec;

  elapsed := (timeofday.tv_sec - record.timeofday.tv_sec) * 1000
              + Int((timeofday.tv_usec - record.timeofday.tv_usec) / 1000);

  str := "elapsed time: ";
  Append(str, String(elapsed));
  Append(str, "ms\n");

  SetInfoLevel(InfoWarning, record.InfoLevelInfoWarning);
  SetInfoLevel(InfoDigraphs, record.InfoLevelInfoDigraphs);

  if not IsBound(GAPInfo.TestData.START_TIME) then
      ErrorNoReturn("Digraphs: DIGRAPHS_StopTest:\n",
                    "`STOP_TEST' command without `START_TEST' command for `",
                    file, "'");
  fi;
  Print(GAPInfo.TestData.START_NAME, "\n");

  SetAssertionLevel(GAPInfo.TestData.AssertionLevel);
  Unbind(GAPInfo.TestData.AssertionLevel);
  Unbind(GAPInfo.TestData.START_TIME);
  Unbind(GAPInfo.TestData.START_NAME);
  Print(str);
  MakeReadWriteGlobal("STOP_TEST");
  UnbindGlobal("STOP_TEST");
  BindGlobal("STOP_TEST", record.STOP_TEST);
  MakeReadWriteGlobal("STOP_TEST");
  return;
end);

InstallGlobalFunction(DIGRAPHS_TestDir,
function(dir, opts)
  local start_time, file_ext, is_testable, tst_dir, contents, farm, nr_tests,
    out, stop_time, elapsed, str, filename;

  start_time := IO_gettimeofday();

  if IsRecord(opts) then
    if not IsBound(opts.parallel) or not IsBool(opts.parallel) then
      opts.parallel := false;
    fi; #TODO add printing of ignored options
  else
    ErrorNoReturn("Digraphs: DIGRAPHS_TestDir: usage,\n",
                  "the argument must be a record,");
  fi;

  Print("\n");

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

  tst_dir  := Concatenation(PackageInfo("digraphs")[1]!.InstallationPath,
                            "/tst/", dir);
  contents := DirectoryContents(tst_dir);

  DigraphsTestInstall(rec(silent := false));

  if opts.parallel then
    farm := ParWorkerFarmByFork(DIGRAPHS_Test,
                                rec(NumberJobs := 3));
    nr_tests := 0;
  else
    out := true;
  fi;

  for filename in contents do
    if file_ext(filename) = "tst" and is_testable(tst_dir, filename) then
      if opts.parallel then
          nr_tests := nr_tests + 1;
          Submit(farm, [Filename(Directory(tst_dir), filename),
                        rec(silent := false)]);
      else
        if not DIGRAPHS_Test(Filename(Directory(tst_dir), filename),
                                      rec(silent := false)) then
          out := false;
        fi;
      fi;
    fi;
  od;

  if opts.parallel then
    while Length(farm!.outqueue) < nr_tests do
      DoQueues(farm, false);
    od;

    out := Pickup(farm);
    Kill(farm);
  fi;

  stop_time := IO_gettimeofday();
  elapsed := (stop_time.tv_sec - start_time.tv_sec) * 1000
              + Int((stop_time.tv_usec - start_time.tv_usec) / 1000);

  str := "TOTAL elapsed time: ";
  Append(str, String(elapsed));
  Append(str, "ms\n\n");
  Print(str);

  return out;
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

InstallGlobalFunction(DIGRAPHS_Test,
function(arg)
  local file, opts, split, print_file, width, test_output;

  if Length(arg) = 0 then
    ErrorNoReturn("Digraphs: DIGRAPHS_Test: usage,\n",
                  "there should be at least 1 argument,");
  fi;

  file := arg[1];

  if Length(arg) = 1 then
    opts := rec();
  else
    opts := arg[2];
  fi;

  # TODO process opts
  if not IsBound(opts.silent) then
    opts.silent := true;
  fi;

  split := SplitString(file, "/");
  print_file := JoinStringsWithSeparator(split{[Length(split) - 2 ..
                                                Length(split)]}, "/");
  width := SizeScreen()[1] - 3;

  if not opts.silent then
    Print(Concatenation(ListWithIdenticalEntries(width, "#")), "\n");
  fi;

  Print(PRINT_STRINGIFY("testing ", print_file, " . . ."), "\n");

  if not opts.silent then
    Print(Concatenation(ListWithIdenticalEntries(width, "#")), "\n\n");
  fi;

  test_output := Test(file);
  if not opts.silent then
    Print("\n", DIGRAPHS_PF(test_output));
  fi;
  Print("\n");

  return test_output;
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

InstallGlobalFunction(DigraphsTestStandard,
function()
  return DIGRAPHS_TestDir("standard", rec());
end);

InstallGlobalFunction(DigraphsTestExtreme,
function()
  local file;

  file := Filename(DirectoriesPackageLibrary("digraphs", "digraphs-lib"),
                   "extreme.d6.gz");

  if file = fail then
    ErrorNoReturn("Digraphs: DigraphsTestExtreme:\n",
                  "the file pkg/digraphs/digraphs-lib/extreme.d6.gz is ",
                  "required\nfor these tests to run. Please download the ",
                  "'digraphs-lib.tar.gz'\narchive from:\n\n",
                  "http://bitbucket.org/james-d-mitchell/digraphs/downloads",
                  "\n\nand try again,");
  fi;

  return DIGRAPHS_TestDir("extreme", rec());
end);

InstallGlobalFunction(DigraphsMakeDoc,
function()
  MakeGAPDocDoc(Concatenation(PackageInfo("digraphs")[1]!.
                              InstallationPath, "/doc"),
                "main.xml", DIGRAPHS_DocXMLFiles, "Digraphs", "MathJax",
                "../../..");
  return;
end);

InstallGlobalFunction(DigraphsTestInstall,
function(arg)
  local opts;

  if Length(arg) = 0 then
    opts := rec();
  else
    opts := arg[1];
  fi;
  #TODO check args
  return DIGRAPHS_Test(Filename(DirectoriesPackageLibrary("digraphs", "tst"),
                       "testinstall.tst"), opts);
end);

InstallGlobalFunction(DigraphsTestManualExamples,
function()
  local ex, omit, str;

  ex := DIGRAPHS_ManualExamples();
  omit := DIGRAPHS_OmitFromTests;
  if Length(omit) > 0 then
    Print("# not testing examples containing the strings:");
    for str in omit do
      ex := Filtered(ex, x -> PositionSublist(x[1][1], str) = fail);
      Print(", \"", str, "\"");
    od;
    Print(" . . .\n");
  fi;

  DIGRAPHS_StartTest();
  RunExamples(ex);
  DIGRAPHS_StopTest("");
  return;
end);
