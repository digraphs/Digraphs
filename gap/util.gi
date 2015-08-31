#############################################################################
##
#W  utils.gi
#Y  Copyright (C) 2013-14                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
## this file contains utilies for use with the Digraphs package.

BindGlobal("DigraphsDocXMLFiles", ["attr.xml", "bliss.xml", "digraph.xml",
"display.xml", "grahom.xml", "grape.xml", "io.xml", "oper.xml",
"prop.xml", "util.xml", "../PackageInfo.g"]);

BindGlobal("DigraphsTestRec", rec());
MakeReadWriteGlobal("DigraphsTestRec");

InstallGlobalFunction(DigraphsStartTest,
function()
  local record;

  record := DigraphsTestRec;

  record.timeofday := IO_gettimeofday();
  record.InfoLevelInfoWarning := InfoLevel(InfoWarning);
  record.InfoLevelInfoDigraphs := InfoLevel(InfoDigraphs);

  SetInfoLevel(InfoWarning, 0);
  SetInfoLevel(InfoDigraphs, 0);

  record.STOP_TEST := STOP_TEST;

  MakeReadWriteGlobal("STOP_TEST");
  UnbindGlobal("STOP_TEST");
  BindGlobal("STOP_TEST", DigraphsStopTest);

  return;
end);

InstallGlobalFunction(DigraphsStopTest,
function(file)
  local timeofday, record, elapsed, str;

  timeofday := IO_gettimeofday();

  record := DigraphsTestRec;

  elapsed := (timeofday.tv_sec - record.timeofday.tv_sec) * 1000
              + Int((timeofday.tv_usec - record.timeofday.tv_usec) / 1000);

  str := "elapsed time: ";
  Append(str, String(elapsed));
  Append(str, "ms\n");

  SetInfoLevel(InfoWarning, record.InfoLevelInfoWarning);
  SetInfoLevel(InfoDigraphs, record.InfoLevelInfoDigraphs);

  if not IsBound(GAPInfo.TestData.START_TIME) then
      ErrorMayQuit("Digraphs: DigraphsStopTest:\n",
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
  return;
end);

InstallGlobalFunction(DigraphsMakeDoc,
function()
  MakeGAPDocDoc(Concatenation(PackageInfo("digraphs")[1]!.
                              InstallationPath, "/doc"),
                "main.xml", DigraphsDocXMLFiles, "Digraphs", "MathJax",
                "../../..");
  return;
end);

InstallGlobalFunction(DigraphsTestAll,
function()
  local dir_str, tst, dir, passed, filesplit, test, stringfile, filename;

  Print("Reading all .tst files in the directory digraphs/tst/...\n\n");
  dir_str := Concatenation(PackageInfo("digraphs")[1]!.InstallationPath,
                           "/tst");
  tst := DirectoryContents(dir_str);
  dir := Directory(dir_str);

  passed := true;

  for filename in tst do
    filesplit := SplitString(filename, ".");
    if Length(filesplit) >= 2 and filesplit[Length(filesplit)] = "tst" then
      test := true;
      stringfile := StringFile(Concatenation(dir_str, "/", filename));
      if test then
        Print("reading ", dir_str, "/", filename, " . . .\n");
        passed := passed and Test(Filename(dir, filename));
        Print("\n");
      fi;
    fi;
  od;
  return passed;
end);

InstallGlobalFunction(DigraphsTestInstall,
function()
  return Test(Filename(DirectoriesPackageLibrary("digraphs", "tst"),
                       "testinstall.tst"));
end);

InstallGlobalFunction(DIGRAPHS_ManualExamples,
function()
  return ExtractExamples(DirectoriesPackageLibrary("digraphs", "doc"),
                         "main.xml", DigraphsDocXMLFiles, "Single");
end);

InstallGlobalFunction(DigraphsTestManualExamples,
function()
  local ex, omit, str;

  ex := DIGRAPHS_ManualExamples();
  omit := DIGRAPHS_OmitFromTestManualExamples;
  if Length(omit) > 0 then
    Print("# not testing examples containing the strings");
    for str in omit do
      ex := Filtered(ex, x -> PositionSublist(x[1][1], str) = fail);
      Print(", \"", str, "\"");
    od;
    Print(" . . .\n");
  fi;

  DigraphsStartTest();
  RunExamples(ex);
  DigraphsStopTest("");
  return;
end);

InstallGlobalFunction(DigraphsDir,
function()
  return PackageInfo("digraphs")[1]!.InstallationPath;
end);

InstallGlobalFunction(DigraphsTestEverything,
function()

  DigraphsMakeDoc();
  Print("\n");

  if not DigraphsTestInstall() then
    Print("Abort: testinstall.tst failed . . . \n");
    return false;
  fi;
  Print("\n");

  if not DigraphsTestAll() then
    Print("Abort: DigraphsTestAll failed . . . \n");
    return false;
  fi;

  DigraphsTestManualExamples();
  return;
end);

InstallGlobalFunction(IsSemigroupsLoaded,
function()
  return IsPackageMarkedForLoading("semigroups", "2.1");
end);
