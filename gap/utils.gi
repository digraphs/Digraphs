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

BindGlobal("DigraphsDocXMLFiles", ["digraph.xml", "attrs.xml", "display.xml", "utils.xml", "../PackageInfo.g"]);

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

InstallGlobalFunction(DigraphsDir,
function()
  return PackageInfo("digraphs")[1]!.InstallationPath;
end);

#

InstallGlobalFunction(ReadDirectedGraphs,
function(arg)
  local name, decoder, nr, file, splitname, extension, i, line, lines;

  if Length(arg) = 1 then 
    name := arg[1];
    decoder := fail;
    nr := infinity;
  elif Length(arg) = 2 then 
    name := arg[1];
    if IsFunction(arg[2]) then 
      decoder := arg[2];
      nr := infinity;
    else 
      decoder := fail;
      nr := arg[2];
    fi;
  elif Length(arg) = 3 then 
    name := arg[1];
    decoder := arg[2];
    nr := arg[3];
  else 
    Error("Digraphs: usage: ReadDirectedGraphs( filename [,decoder][,pos] )\n");
    return;
  fi;

  if (not IsString(name)) or (not (IsFunction(decoder) or decoder = fail)) 
    or (not (IsPosInt(nr) or nr = infinity)) then 
    Error("Digraphs: usage: ReadDirectedGraphs( filename [,decoder][,pos] )\n");
    return;
  fi;

  file := IO_CompressedFile(name, "r");
  
  if file = fail then 
    Error("Digraphs: ReadDirectedGraphs: can't open file ", name, "\n");
    return;
  fi;

  if decoder = fail then 
    splitname := SplitString(name, ".");
    extension := splitname[Length(splitname)];
    
    if extension in [ "gz", "bzip2", "xz"] then 
      if Length(splitname) = 2 then 
        Error("Digraphs: ReadDirectedGraphs: can't determine the file format\n");
        return;
      fi;
      extension := splitname[Length(splitname)-1];
    fi;
   
    if extension = "txt" then 
      decoder := DigraphPlainTextLineDecoder("  ", " ", 1);
    elif extension = "g6" then 
      decoder := ReadGraph6Line;
    elif extension = "d6" then 
      decoder := ReadDigraph6Line;
    else 
      Error("Digraphs: ReadDirectedGraphs: can't determine the file format,");
      return;
    fi;
    # JDM: could also try to determine the type of the file by looking into it 
  fi;

  if nr < infinity then 
    i:=0;
    repeat
      i:=i+1; 
      line:=IO_ReadLine(file);
    until i=nr or line="";
    IO_Close(file);
    return decoder(Chomp(line));
  fi;

  lines:=IO_ReadLines(file);
  IO_Close(file);
  Apply(lines, x-> decoder(Chomp(x)));
  return lines;
end);

#

InstallMethod(ReadGraph6Line, "for a string",
[IsString],
function(s)
  local FindCoord, list, n, start, maxedges, range, source, pos, len, i, bpos, temp, j;

  # find a position in the adj matrix from the vector
  # knowing a lower bound for pos_y
  FindCoord := function(pos, bound)
    local i, sum;
      i := bound;
      sum := Sum([1..i]);
      while sum < pos do
        i := i + 1;
        sum := sum + i;
      od;
    return [ pos - sum + i - 1, i ];
  end;

  if Length(s) = 0 then
    Error("the input string has to be non empty");
    return;
  fi;

  # Convert ASCII chars to integers
  list := [];
  for i in s do
    Add(list, IntChar(i) - 63);
  od;

  # Get n the number of vertices of the graph
  if list[1] <> 63 then
    n := list[1];
    start := 2;
  elif Length(list) > 300 then
    if list[2] = 63 and Length(list) <= 8 then
      n := 0;
      for i in [0..5] do
        n := n + 2^(6*i)*list[8-i];
      od;
      start := 9;
    else
      n := 0;
      for i in [0..2] do
        n := n + 2^(6*i)*list[4-i];
      od;
      start :=  5;
    fi;
  else
     Error(s, " is not a valid graph6 input");
     return;
  fi;

  maxedges := n*(n-1)/2;
  if list <> [0] and not (Int((maxedges-1)/6) +  start = Length(list) and
     list[Length(list)] mod 2^((0 - maxedges) mod 6) = 0) then
       Error(s, " is not a valid graph6 input");
       return;
  fi;

  range := [];
  source := [];

  # Obtaining the adjacency vector
  pos := 1;
  len := 1;
  for j in [start .. Length(list)] do # Every integer corresponds to 6 bits
    i := list[j];
    bpos := 1;
    while i > 0 do
      if i mod 2  = 0 then
        i := i / 2;
      else
        temp := FindCoord(pos + 6 - bpos, 0);
	range[len] := temp[1];
	source[len] := temp[2];
	range[len + 1] := temp[2];
	source[len + 1] := temp[1];
	len := len + 2;
        i := (i - 1) / 2;
      fi;
      bpos := bpos + 1;
    od;
    pos := pos + 6;
  od;

  return DirectedGraph(rec(vertices := [ 1 .. n ], range := range + 1,
    source := source + 1 ));
end);

#

InstallMethod(ReadDigraph6Line, "for a string",
[IsString],
function(s)
  local list, i, n, start, range, source, pos, len, j, bpos, tabpos;

  # Check for the special '+' character
  if s[1] <> '+' then
    Error("<s> must be a string in Digraph6 format,");
    return;
  fi;

  # Convert ASCII chars to integers
  list := [];
  for i in [2..Length(s)] do
    Add(list, IntChar(s[i]) - 63);
  od;

  # Get n the number of vertices of the graph
  if list[1] <> 63 then
    n := list[1];
    start := 2;
  else
    if list[2] = 63 then
      n := 0;
      for i in [0..5] do
        n := n + 2^(6*i)*list[8-i];
      od;
      start := 9;
    else
      n := 0;
      for i in [0..2] do
        n := n + 2^(6*i)*list[4-i];
      od;
      start := 5;
    fi;
  fi;

  range := [];
  source := [];

  # Obtaining the adjacency vector
  pos := 1;
  len := 1;
  for j in [start .. Length(list)] do # Every integer corresponds to 6 bits
    i := list[j];
    bpos := 1;
    while i > 0 do
      if i mod 2  = 0 then
        i := i / 2;
      else
        tabpos := pos + 6 - bpos;
        source[len] := (tabpos-1) mod n + 1;
	range[len] := (tabpos - source[len]) / n + 1;
	len := len + 1;
        i := (i - 1) / 2;
      fi;
      bpos := bpos + 1;
    od;
    pos := pos + 6;
  od;

  return DirectedGraph( rec( vertices := [ 1 .. n ], range := range,
    source := source ) );
end);

SplitStringBySubstring:=function(string, substring)
  local m, n, i, j, out, nr;
  
  if Length(substring) = 1 then 
    return SplitString(string, substring);
  fi;

  m := Length(string);
  n := Length(substring);
  i := 1;
  j := 1;
  out := [];
  nr := 0;

  while m - i >= n do 
    if string{ [ i .. i + n - 1 ]} = substring then 
      if i <> 1 then 
        nr := nr + 1;
        out[nr] := string{ [ j .. i - 1 ] };
        j := i + n;
        i := i + n;
      fi;
    else 
      i := i + 1;
    fi;
  od;
  nr := nr + 1;
  out[nr] := string{ [ j .. Length(string) ] };
  return out;
end;

# one graph per line

InstallGlobalFunction(DigraphPlainTextLineDecoder,
function(arg)
  local delimiter, offset, delimiter1, delimiter2;

  if Length(arg) = 2 then 
    delimiter := arg[1]; # what delineates the range of an edge from its source
    offset := arg[2];    # indexing starts at 0 or 1? or what? 
    return 
      function(string) 
        string := SplitString(string, delimiter);
        Apply(string, Int);  
        return string + offset;
      end;
  elif Length(arg) = 3 then 
    delimiter1 := arg[1]; # what delineates one edge from the next
    delimiter2 := arg[2]; # what delineates the range of an edge from its source
    offset := arg[3];     # indexing starts at 0 or 1? or what? 
    return 
      function(string) 
        local edges, x;
        string:=SplitStringBySubstring(string, delimiter1);
        Apply(string, x-> SplitStringBySubstring(x, delimiter2));  
        edges := EmptyPlist(Length(string)); 
        for x in string do 
          Apply(x, Int);
          x := x + offset;
          Add(edges, x);
        od;
        return DirectedGraphByEdges(edges);
      end;
  else 
    Error("usage: DigraphPlainTestLineDecoder(delimiter, [,delimiter], offset)");
    return;
  fi;
end);

# one edge per line, one graph per file 

InstallGlobalFunction(ReadPlainTextDigraph,
function(name, delimiter, offset, ignore)
  local file, lines, edges, nr, decoder, line;

  if (not IsString(name)) or (not IsString(delimiter))
    or (not (IsInt(offset) and offset >= 0)) 
    or (not (IsString(ignore) or IsChar(ignore))) then 
    Error("Digraphs: usage: ReadPlainTextDigraph( filename, delimiter, offset, ignore )\n");
    return;
  fi;
  
  if IsChar(ignore) then
    ignore := [ignore];
  fi;

  file := IO_CompressedFile(name, "r");
  
  if file = fail then 
    Error("Digraphs: ReadPlainTextDigraph: can't open file ", name, "\n");
    return;
  fi;

  lines := IO_ReadLines(file);
  edges := EmptyPlist(Length(lines));
  nr := 0;
  decoder := DigraphPlainTextLineDecoder(delimiter, offset);
  
  for line in lines do 
    if Length(line) > 0 and not (line[1] in ignore) then 
      nr := nr + 1;
      edges[nr] := decoder(Chomp(line));
    fi;
  od;

  return DirectedGraphByEdges(edges);
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
    if IsBound(arg[3]) then # arg[3] is the mode 
      file:=IO_CompressedFile(arg[1], arg[3]);
    else
      file:=IO_CompressedFile(arg[1], "a");
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

#

InstallMethod(WriteGraph6, "for a directed graph",
[IsDirectedGraph],
function(graph)
  local list, adj, n, tablen, blist, i, j, pos, block;
  list := [];
  adj := Adjacencies(graph);
  n := Length(Vertices(graph));

  # First write the number of vertices
  if n < 63 then
    Add(list, n);
  elif n < 258248 then
    Add(list, 63);
    Add(list, Int(n / 64^2));
    Add(list, Int(n / 64) mod 64);
    Add(list, n mod 64);
  elif n < 68719476736 then
    Add(list, 63);
    Add(list, 63);
    Add(list, Int(n / 64^5));
    Add(list, Int(n / 64^4) mod 64);
    Add(list, Int(n / 64^3) mod 64);
    Add(list, Int(n / 64^2) mod 64);
    Add(list, Int(n / 64^1) mod 64);
    Add(list, n mod 64);
  else
    Error("<graph> must have no more than 68719476736 vertices,");
    return;
  fi;

  # Find adjacencies (non-directed)
  tablen := n * (n-1) / 2;
  blist := BlistList([1..tablen+6], []);
  for i in Vertices(graph) do
    for j in adj[i] do
      # Loops not allowed
      if j > i then
        blist[i + (j-2)*(j-1)/2] := true;
      elif i > j then
        blist[j + (i-2)*(i-1)/2] := true;
      fi;
    od;
  od;

  # Read these into list, 6 bits at a time
  pos := 0;
  while pos < tablen do
    block := 0;
    for i in [1..6] do
      if blist[pos+i] then
        block := block + 2^(6-i);
      fi;
    od;
    Add(list, block);
    pos := pos + 6;
  od;

  # Create string to return
  return List(list, i -> CharInt(i + 63));
end);

#

InstallMethod(WriteDigraph6, "for a directed graph",
[IsDirectedGraph],
function(graph)
  local list, adj, n, tablen, blist, i, j, pos, block;
  list := [];
  adj := Adjacencies(graph);
  n := Length(Vertices(graph));

  # First write the special character '+'
  Add(list,-20);

  # Now write the number of vertices
  if n < 63 then
    Add(list, n);
  elif n < 258248 then
    Add(list, 63);
    Add(list, Int(n / 64^2));
    Add(list, Int(n / 64) mod 64);
    Add(list, n mod 64);
  elif n < 68719476736 then
    Add(list, 63);
    Add(list, 63);
    Add(list, Int(n / 64^5));
    Add(list, Int(n / 64^4) mod 64);
    Add(list, Int(n / 64^3) mod 64);
    Add(list, Int(n / 64^2) mod 64);
    Add(list, Int(n / 64^1) mod 64);
    Add(list, n mod 64);
  else
    Error("<graph> must have no more than 68719476736 vertices,");
    return;
  fi;

  # Find adjacencies (non-directed)
  tablen := n ^ 2;
  blist := BlistList([1..tablen+6], []);
  for i in Vertices(graph) do
    for j in adj[i] do
      blist[i + n*(j-1)] := true;
    od;
  od;

  # Read these into list, 6 bits at a time
  pos := 0;
  while pos < tablen do
    block := 0;
    for i in [1..6] do
      if blist[pos+i] then
        block := block + 2^(6-i);
      fi;
    od;
    Add(list, block);
    pos := pos + 6;
  od;

  # Create string to return
  return List(list, i -> CharInt(i + 63));
end);

#EOF
