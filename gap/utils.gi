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

BindGlobal("DigraphsDocXMLFiles", ["digraph.xml", "../PackageInfo.g"]);

BindGlobal("DigraphsTestRec", rec());
MakeReadWriteGlobal("DigraphsTestRec");

InstallGlobalFunction(DigraphsStartTest, 
function()
  local record;

  record:=DigraphsTestRec;  
  
  record.InfoLevelInfoWarning:=InfoLevel(InfoWarning);;
  record.InfoLevelInfoDigraphs:=InfoLevel(InfoDigraphs);;
 
  SetInfoLevel(InfoWarning, 0);;
  SetInfoLevel(InfoDigraphs, 0);
  
  return; 
end);

InstallGlobalFunction(DigraphsStopTest, 
function()
  local record;

  record:=DigraphsTestRec;  
  
  SetInfoLevel(InfoWarning, record.InfoLevelInfoWarning);;
  SetInfoLevel(InfoDigraphs, record.InfoLevelInfoDigraphs);
  
  return;
end);

InstallGlobalFunction(DigraphsMakeDoc, 
function()
  MakeGAPDocDoc(Concatenation(PackageInfo("digraphs")[1]!.
   InstallationPath, "/doc"), "main.xml", DigraphsDocXMLFiles, "digraphs",
   "MathJax", "../../..");;
  return;
end);

InstallGlobalFunction(DigraphsTestAll, 
function()
  local dir_str, tst, dir, filesplit, test, stringfile, filename;
  
  Print("Reading all .tst files in the directory digraphs/tst/...\n\n"); 
  dir_str:=Concatenation(PackageInfo("digraphs")[1]!.InstallationPath,"/tst");
  tst:=DirectoryContents(dir_str);
  dir:=Directory(dir_str);

  for filename in tst do
    filesplit:=SplitString(filename, ".");
    if Length(filesplit)>=2 and filesplit[Length(filesplit)]="tst" then
      test:=true;
      stringfile:=StringFile(Concatenation(dir_str, "/", filename));
      if test then 
        Print("reading ", dir_str,"/", filename, " . . .\n");
        Test(Filename(dir, filename));
        Print("\n");
      fi;
    fi;
  od;  
  return;
end);

InstallGlobalFunction(DigraphsTestInstall, 
function()
  Test(Filename(DirectoriesPackageLibrary("digraphs","tst"),
   "testinstall.tst"));;
  return;
end);

InstallGlobalFunction(DigraphsManualExamples,
function()
return 
  ExtractExamples(DirectoriesPackageLibrary("digraphs","doc"), 
  "main.xml",  DigraphsDocXMLFiles, "Single" );
end);

InstallGlobalFunction(DigraphsTestManualExamples, 
function()
  local ex;

  ex:=DigraphsManualExamples(); 
  DigraphsStartTest();
  RunExamples(ex);
  DigraphsStopTest();
  return;
end);

InstallGlobalFunction(DirectedGraphWriteFile, 
function(arg)
  local mode, file;

  if IsString(arg[1]) then 
    if IsExistingFile(arg[1]) then 
      if not IsWritableFile(arg[1]) then 
        Error(arg[1], " exists and is not a writable file,");
        return;
      fi;
    else
      if not (IsExistingFile(Concatenation(arg[1], ".gz")) or 
        IsExistingFile(Concatenation(arg[1], ".xz"))) then 
        Exec("touch ", arg[1]);
      fi;
    fi;
  else
    Error("usage: the 1st argument must be a string,");
    return;
  fi;

  if Length(arg)=2 and not (IsString(arg[2]) and (arg[2]="a" or arg[2]="w"))
   then 
    Error("usage: the 2nd argument must be \"a\" or \"w\",");
    return;
  fi;

  if Length(arg)>2 then 
    Error("usage: there must be at most 2 arguments,");
    return;
  fi;
  
  if Length(arg)=1 then 
    mode:="a";
  else
    mode:=arg[2];
  fi;

  file:=SplitString(arg[1], ".");
  if file[Length(file)] = "gz" then 
    file:=IO_FilteredFile([["gzip", ["-9q"]]], arg[1], mode);
  elif file[Length(file)] = "xz" then 
    file:=IO_FilteredFile([["xz", ["-9q"]]], arg[1], mode);
  else  
    file:=IO_File(arg[1], mode);
  fi;
  return file;
end);

# this is just temporary, until a better method is given, only works for single
# graphs

#JDM: should check arg[3]!

InstallGlobalFunction(WriteDirectedGraph, 
function(arg)
  local file;
  
  if not (Length(arg)=3 or Length(arg)=2) then
    Error("usage: there should be 2 or 3 arguments,"); 
    return;
  fi;

  if IsString(arg[1]) then
    if IsBound(arg[3]) then 
      file:=DirectedGraphWriteFile(arg[1], arg[3]);
    else 
      file:=DirectedGraphWriteFile(arg[1]);
    fi;
  elif IsFile(arg[1]) then 
    file:=arg[1];
  else 
    Error("usage: the 1st argument must be a string or a file,");
    return;
  fi;

  if file=fail then 
    Error("couldn't open the file ", file, ",");
    return;
  fi;
  
  if not IsDirectedGraph(arg[2]) then 
    Error("usage: the 2nd argument must be directed graph,");
    return;
  fi;

  if not IsSimpleDirectedGraph(arg[2]) then 
    Error("not yet implemented,");
    return;
  fi;

  IO_WriteLine(file, String(arg[2]));
  
  if IsString(arg[1]) then  
    IO_Close(file);
  fi;
  return true;
end);

#EOF
