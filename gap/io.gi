#############################################################################
##
#W  io.gi
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallGlobalFunction(ReadDigraphs,
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
    Error("Digraphs: ReadDigraphs: usage,\n",
          "ReadDigraphs( filename [,decoder][,pos] ),\n");
    return;
  fi;

  if (not IsString(name)) or (not (IsFunction(decoder) or decoder = fail))
    or (not (IsPosInt(nr) or nr = infinity)) then
    Error("Digraphs: ReadDigraphs: usage,\n",
          "ReadDigraphs( filename [,decoder][,pos] ),\n");
    return;
  fi;

  file := IO_CompressedFile(name, "r");

  if file = fail then
    Error("Digraphs: ReadDigraphs: usage,\n",
          "can't open file ", name, ",\n");
    return;
  fi;

  if decoder = fail then
    splitname := SplitString(name, ".");
    extension := splitname[Length(splitname)];

    if extension in [ "gz", "bzip2", "xz"] then
      if Length(splitname) = 2 then
        Error("Digraphs: ReadDigraphs: usage,\n",
              "can't determine the file format,\n");
        return;
      fi;
      extension := splitname[Length(splitname)-1];
    fi;

    if extension = "txt" then
      decoder := DigraphPlainTextLineDecoder("  ", " ", 1);
    elif extension = "g6" then
      decoder := DigraphFromGraph6String;
    elif extension = "d6" then
      decoder := DigraphFromDigraph6String;
    else
      Error("Digraphs: ReadDigraphs: usage,\n",
            "can't determine the file format,\n");
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

InstallMethod(DigraphFromGraph6String, "for a string",
[IsString],
function(s)
  local FindCoord, list, n, start, maxedges, range, source, pos, len, i, bpos, edge, graph, j;

  # find a position in the adj matrix from the vector
  # knowing a lower bound for pos_y
  FindCoord := function(pos, bound)
    local i, sum;
      i := bound;
      sum := i * (i + 1) / 2;
      while sum < pos do
        i := i + 1;
        sum := sum + i;
      od;
    return [ pos - sum + i, i + 1 ];
  end;

  if Length(s) = 0 then
    Error("Digraphs: DigraphFromGraph6String: usage,\n",
          "the input string has to be non-empty,\n");
    return;
  fi;

  # Convert ASCII chars to integers
  list := List(s, i -> IntChar(i) - 63);

  # Get n the number of vertices of the graph
  if list[1] <> 63 then
    n := list[1];
    start := 2;
  elif Length(list) > 300 then
    if list[2] = 63 then
      n := 0;
      for i in [ 0 .. 5 ] do
        n := n + 2 ^ (6 * i) * list[8 - i];
      od;
      start := 9;
    else
      n := 0;
      for i in [ 0 .. 2 ] do
        n := n + 2 ^ (6 * i) * list[4 - i];
      od;
      start :=  5;
    fi;
  else
    Error("Digraphs: DigraphFromGraph6String: usage,\n",
          "<s> is not a valid graph6 input,\n");
    return;
  fi;

  maxedges := n * ( n - 1 ) / 2;
  if list <> [0] and not (Int((maxedges - 1) / 6) +  start = Length(list) and
     list[Length(list)] mod 2 ^ ((0 - maxedges) mod 6) = 0) then
    Error("Digraphs: DigraphFromGraph6String: usage,\n",
          "<s> is not a valid graph6 input,\n");
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
        edge := FindCoord(pos + 6 - bpos, 0);
	range[len] := edge[1];
	source[len] := edge[2];
	range[len + 1] := edge[2];
	source[len + 1] := edge[1];
	len := len + 2;
        i := (i - 1) / 2;
      fi;
      bpos := bpos + 1;
    od;
    pos := pos + 6;
  od;

  graph := Digraph(rec(nrvertices := n, range := range,
    source := source ));
  SetIsSymmetricDigraph(graph, true);
  return graph;
end);

#

InstallMethod(DigraphFromDigraph6String, "for a string",
[IsString],
function(s)
  local list, i, n, start, range, source, pos, len, j, bpos, tabpos;

  # Check for the special '+' character
  if s[1] <> '+' then
    Error("Digraphs: DigraphFromDigraph6String: usage,\n",
          "<s> must be a string in Digraph6 format,\n");
    return;
  fi;

  # Convert ASCII chars to integers
  list := List(s, i -> IntChar(i) - 63);

  # Get n the number of vertices of the graph
  if list[2] <> 63 then
    n := list[2];
    start := 3;
  elif Length(list) > 300 then
    if list[3] = 63 then
      n := 0;
      for i in [0..5] do
        n := n + 2^(6*i)*list[9-i];
      od;
      start := 10;
    else
      n := 0;
      for i in [0..2] do
        n := n + 2^(6*i)*list[5-i];
      od;
      start := 6;
    fi;
  else
    Error("Digraphs: DigraphFromDigraph6String: usage,\n",
          "<s> must be a string in Digraph6 format,\n");
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

  return Digraph( rec( nrvertices := n, range := range,
    source := source ) );
end);

#

BindGlobal("DIGRAPHS_LogCeiling",
function(n, k)
  local pow;
  pow := LogInt(n,k);
  if k^pow < n then
    pow := pow + 1;
  fi;
  return pow;
end);

#

InstallMethod(DigraphFromSparse6String, "for a string",
[IsString],
function(s)
  local list, n, start, blist, pos, num, bpos, k, range, source, len, v, i,
  finish, x, j;


  # Check for the special ':' character
  if s[1] <> ':' then
    Error("Digraphs: DigraphFromSparse6String: usage,\n",
          "<s> must be a string in Sparse6 format,\n");
    return;
  fi;

  # Convert ASCII chars to integers
  list := [];
  for i in s do
    Add(list, IntChar(i) - 63);
  od;

  # Get n the number of vertices of the graph
  if list[2] <> 63 then
    n := list[2];
    start := 3;
  elif list[3] = 63 then
    if Length(list) <= 8 then
      Error("Digraphs: DigraphFromSparse6String: usage,\n",
            "<s> must be a string in Sparse6 format,\n");
      return;
    fi;
    n := 0;
    for i in [ 0 .. 5 ] do
      n := n + 2^(6 * i) * list[9 - i];
    od;
    start := 10;
  elif Length(list) > 4 then
      n := 0; 
      for i in [ 0 .. 2 ] do
        n := n + 2^(6 * i) * list[5 - i];
      od;
      start := 6;
  else
    Error("Digraphs: DigraphFromSparse6String: usage,\n",
          "<s> must be a string in Sparse6 format,\n");
    return;
  fi;

  # convert list into a list of bits;
  blist := BlistList([1 .. (Length(list) - start + 1) * 6], []);
  pos := 1;
  for i in [start .. Length(list)] do
    num := list[i];
    bpos := 1;
    while num > 0 do
      if num mod 2 = 0 then
	num := num / 2;
      else
        num := (num - 1) / 2;
	blist[pos + 6 - bpos] := true;
      fi;
      bpos :=  bpos + 1;
    od;
    pos := pos + 6;
  od;

  if n > 1 then
    k := LogInt(n - 1, 2) + 1;
  else
    k := 1;
  fi;

  range := [];
  source := [];

  len := 1;
  v := 0;
  i := 1;
  # remove some of the padding 
  finish := Length(blist) - (Length(blist) mod (k + 1));
  while i <= finish - k do
    if blist[i] then
      v := v + 1;
    fi;
    x := 0;
    for j in [ 1 .. k ] do
      if blist[i + j] then
        x := x + 2^(k - j);
      fi;
    od;
    if x = n then # We have reached the end
      break;
    elif x > v then
      v := x;
    else
      range[len] := x; 
      source[len] := v;
      range[len + 1] := v;
      source[len + 1] := x;
      len  := len + 2;
    fi;
    i := i + k + 1;
  od;

  # JDM bad!
  range := range + 1;
  source := source + 1;
  return Digraph( rec( nrvertices := n, range := range,
   source := source  ) );
end);

#

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
        return DigraphByEdges(edges);
      end;
  else
    Error("Digraphs: DigraphPlainTextLineDecoder: usage,\n",
          "DigraphPlainTextLineDecoder(delimiter, [,delimiter], offset),\n");
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
    Error("Digraphs: ReadPlainTextDigraph: usage,\n",
          "ReadPlainTextDigraph( filename, delimiter, offset, ignore ),\n");
    return;
  fi;

  if IsChar(ignore) then
    ignore := [ignore];
  fi;

  file := IO_CompressedFile(name, "r");

  if file = fail then
    Error("Digraphs: ReadPlainTextDigraph: usage,\n",
          "can't open file ", name, ",\n");
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

  return DigraphByEdges(edges);
end);

# this is just temporary, until a better method is given, only works for single
# graphs

#JDM: should check arg[3]!

InstallGlobalFunction(WriteDigraph,
function(arg)
  local file;

  if not (Length(arg)=3 or Length(arg)=2) then
    Error("Digraphs: WriteDigraph: usage,\n",
          "there should be 2 or 3 arguments,\n");
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
    Error("Digraphs: WriteDigraph: usage,\n",
          "the 1st argument must be a string or a file,\n");
    return;
  fi;

  if file=fail then
    Error("Digraphs: WriteDigraph: usage,\n",
          "couldn't open the file ", file, ",\n");
    return;
  fi;

  if not IsDigraph(arg[2]) then
    Error("Digraphs: WriteDigraph: usage,\n",
          "the 2nd argument must be a digraph,\n");
    return;
  fi;

  if IsMultiDigraph(arg[2]) then
    Error("Digraphs: WriteDigraph: usage,\n",
          "not yet implemented,\n");
    return;
  fi;

  IO_WriteLine(file, String(arg[2]));

  if IsString(arg[1]) then
    IO_Close(file);
  fi;
  return true;
end);

#

BindGlobal("Graph6Length",
function(n)
  local list;
  list := [];
  if n < 0 then
    return fail;
  elif n < 63 then
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
    return fail;
  fi;
  return list;
end);



InstallMethod(WriteGraph6, "for a digraph",
[IsDigraph],
function(graph)
  local list, adj, n, lenlist, tablen, blist, i, j, pos, block;
  list := [];
  adj := OutNeighbours(graph);
  n := Length(DigraphVertices(graph));

  # First write the number of vertices
  lenlist := Graph6Length(n);
  if lenlist = fail then
    Error("Digraphs: WriteGraph6: usage,\n",
          "<graph> must have between 0 and 68719476736 vertices,\n");
    return;
  fi;
  Append(list, lenlist);

  # Find adjacencies (non-directed)
  tablen := n * (n-1) / 2;
  blist := BlistList([1..tablen+6], []);
  for i in DigraphVertices(graph) do
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

InstallMethod(WriteDigraph6, "for a digraph",
[IsDigraph],
function(graph)
  local list, adj, n, lenlist, tablen, blist, i, j, pos, block;
  list := [];
  adj := OutNeighbours(graph);
  n := Length(DigraphVertices(graph));

  # First write the special character '+'
  Add(list,-20);

  # Now write the number of vertices
  lenlist := Graph6Length(n);
  if lenlist = fail then
    Error("Digraphs: WriteDigraph6: usage,\n",
          "<graph> must have between 0 and 68719476736 vertices,\n");
    return;
  fi;
  Append(list, lenlist);

  # Find adjacencies (non-directed)
  tablen := n ^ 2;
  blist := BlistList([1..tablen+6], []);
  for i in DigraphVertices(graph) do
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

#

InstallMethod(WriteSparse6, "for a digraph",
[IsDigraph],
function(graph)
  local list, n, lenlist, source, range, k, blist, v, nextbit, AddBinary, i,
        bitstopad, pos, block;
  if not IsSymmetricDigraph(graph) then
    Error("Digraphs: WriteSparse6: usage,\n",
          "the argument <graph> must be a symmetric digraph,\n");
    return;
  fi;

  list := [];
  n := Length(DigraphVertices(graph));

  # First write the special character ':'
  Add(list,-5);

  # Now write the number of vertices
  lenlist := Graph6Length(n);
  if lenlist = fail then
    Error("Digraphs: WriteSparse6: usage,\n",
          "<graph> must have between 0 and 68719476736 vertices,\n");
    return;
  fi;
  Append(list, lenlist);

  # Get the source and range - half these edges will be discarded
  source := DigraphSource(graph) - 1;
  range := DigraphRange(graph) - 1;

  # k is the number of bits in a vertex label
  if n > 1 then
    k := Log2Int(n-1) + 1;
  else
    k := 1;
  fi;

  # Add the edges one by one
  blist := BlistList([1..Length(source)*(k+1)/2],[]);
  v := 0;
  nextbit := 1;
  AddBinary := function(blist, i)
    local b;
    for b in [1..k] do
      blist[nextbit] := Int((i mod (2^(k-b+1))) / (2^(k-b))) = 1;
      nextbit := nextbit + 1;
    od;
  end;
  for i in [1..Length(source)] do
    if source[i] < range[i] then
      continue;
    elif source[i] = v then
      blist[nextbit] := false;
      nextbit := nextbit + 1;
    elif source[i] = v+1 then
      blist[nextbit] := true;
      nextbit := nextbit + 1;
      v := v + 1;
    elif source[i] > v+1 then
      blist[nextbit] := true;
      nextbit := nextbit + 1;
      AddBinary(blist, source[i]);
      v := source[i];
      blist[nextbit] := false;
      nextbit := nextbit + 1;
    fi;
    AddBinary(blist, range[i]);
  od;

  # Add padding bits:
  #  1. If (n,k) = (2,1), (4,2), (8,3) or (16,4), and vertex
  #     n-2 has an edge but n-1 doesn't have an edge, and
  #     there are k+1 or more bits to pad, then pad with one
  #     0-bit and enough 1-bits to complete the multiple of 6.
  #  2. Otherwise, pad with enough 1-bits to complete the
  #     multiple of 6.

  bitstopad := 5 - ((nextbit-2) mod 6);
  if ((n=2 and k=1) or
      (n=4 and k=2) or
      (n=8 and k=3) or
      (n=16 and k=4)) and
     (v = n-2) and
     (bitstopad > k) then
    blist[nextbit] := false;
    bitstopad := bitstopad - 1;
  fi;
  for i in [1..bitstopad] do
    Add(blist, true);
  od;
  if Length(blist) mod 6 <> 0 then
    Error("Padding problem,");
    return;
  fi;

  # Read blist into list, 6 bits at a time
  pos := 0;
  while pos < Length(blist) do
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

InstallMethod(WriteDiSparse6, "for a digraph",
[IsDigraph],
function(graph)
  local list, n, lenlist, source, range, source_i, range_i, source_d, range_d,
  len1, len2, sort_d, perm, sort_i, k, blist, v, nextbit, AddBinary, bitstopad,
  pos, block, i;

  list := [];
  n := Length(DigraphVertices(graph));

  # First write the special character '.'
  list[1] := -17;

  # Now write the number of vertices
  lenlist := Graph6Length(n);
  if lenlist = fail then
    Error("Digraphs: WriteDiSparse6: usage,\n",
          "<graph> must have between 0 and 68719476736 vertices,\n");
    return;
  fi;
  Append(list, lenlist);

  source := DigraphSource(graph) - 1;
  range := DigraphRange(graph) - 1;

  # Separate edges into increasing and decreasing
  source_i := [];
  range_i := [];
  source_d := [];
  range_d := [];
  len1 := 1;
  len2 := 1;
  for i in [ 1 .. Length(source) ] do
    if source[i] <= range[i] then
      source_i[len1] := source[i];
      range_i[len1] := range[i];
      len1 := len1 + 1;
    else
      source_d[len2] := source[i];
      range_d[len2] := range[i];
      len2 := len2 + 1;
    fi;
  od;

  # Sort decresing edges according to source and then range
  sort_d := function(i, j)
    if source_d[i] < source_d[j] or (source_d[i] = source_d[j]
      and range_d[i] <= range_d[j]) then
      return true;
    else
      return false;
     fi;
  end;

  perm := Sortex([ 1 .. Length(source_d) ], sort_d);
  source_d := Permuted(source_d, perm);
  range_d := Permuted(range_d, perm);

  # Sort increasing edges according to range and then source 
  sort_i := function(i, j)
    if range_i[i] < range_i[j] or (range_i[i] = range_i[j]
      and source_i[i] <= source_i[j]) then
      return true;
    else
      return false;
     fi;
  end;

  perm := Sortex([ 1 .. Length(range_i) ], sort_i);
  source_i := Permuted(source_i, perm);
  range_i := Permuted(range_i, perm);

  # k is the number of bits in a vertex label we also want to be able to encode
  # n as a separation symbol between increasing and decreasing edges
  if n > 1 then
    k := LogInt(n, 2) + 1;
  else
    k := 1;
  fi;

  # Add the edges one by one
  blist := [];
  v := 0;
  nextbit := 1;
  AddBinary := function(blist, i)
    local b;
    for b in [1..k] do
      blist[nextbit] := Int((i mod (2^(k - b + 1))) / (2^(k - b))) = 1;
      nextbit := nextbit + 1;
    od;
  end;
  for i in [ 1 .. Length(source_d) ] do
    if source_d[i] = v then
      blist[nextbit] := false;
      nextbit := nextbit + 1;
    elif source_d[i] = v + 1 then
      blist[nextbit] := true;
      nextbit := nextbit + 1;
      v := v + 1;
    elif source_d[i] > v + 1 then # is this check necessary
      blist[nextbit] := true;
      nextbit := nextbit + 1;
      AddBinary(blist, source_d[i]);
      v := source_d[i];
      blist[nextbit] := false;
      nextbit := nextbit + 1;
    fi;
    AddBinary(blist, range_d[i]);
  od;

  # Add a separation symbol (1 n).
  blist[nextbit] := true;
  nextbit := nextbit + 1;
  AddBinary(blist, n);

  # Repeat everything for increasing edges
  v := 0;
  for i in [ 1 .. Length(range_i) ] do
    if range_i[i] = v then
      blist[nextbit] := false;
      nextbit := nextbit + 1;
    elif range_i[i] = v + 1 then
      blist[nextbit] := true;
      nextbit := nextbit + 1;
      v := v + 1;
    elif range_i[i] > v + 1 then # is this check necessary
      blist[nextbit] := true;
      nextbit := nextbit + 1;
      AddBinary(blist, range_i[i]);
      v := range_i[i];
      blist[nextbit] := false;
      nextbit := nextbit + 1;
    fi;
    AddBinary(blist, source_i[i]);
  od;

  # Add padding bits:
  #  1. If (n,k) = (2,1), (4,2), (8,3) or (16,4), and vertex
  #     n-2 has an edge but n-1 doesn't have an edge, and
  #     there are k+1 or more bits to pad, then pad with one
  #     0-bit and enough 1-bits to complete the multiple of 6.
  #  2. Otherwise, pad with enough 1-bits to complete the
  #     multiple of 6.

  bitstopad := 5 - ((nextbit - 2) mod 6);
  if ((n = 2 and k = 1) or
     (n = 4 and k = 2) or
     (n = 8 and k = 3) or
     (n = 16 and k = 4)) and
     (v = n - 2) and
     (bitstopad > k) then
    blist[nextbit] := false;
    bitstopad := bitstopad - 1;
  fi;
  for i in [ 1 .. bitstopad ] do
    Add(blist, true);
  od;
  if Length(blist) mod 6 <> 0 then
    Error("Padding problem,");
    return;
  fi;

  # Read blist into list, 6 bits at a time
  pos := 0;
  while pos < Length(blist) do
    block := 0;
    for i in [1 .. 6] do
      if blist[pos + i] then
        block := block + 2^(6 - i);
      fi;
    od;
    Add(list, block);
    pos := pos + 6;
  od;

  # Create string to return
  return List(list, i -> CharInt(i + 63));
end);
  
#

InstallMethod(DigraphFromDiSparse6String, "for a directed graph",
[IsString],
function(s)
  local list, n, start, blist, pos, num, bpos, k, range, source, len, v, i, x,
  finish, j;

  # Check for the special ':' character
  if s[1] <> '.' then
    Error("Digraphs: DigraphFromDiSparse6String: usage,\n",
          "<s> must be a string in disparse6 format,\n");
    return;
  fi;

  # Convert ASCII chars to integers
  list := [];
  for i in s do
    Add(list, IntChar(i) - 63);
  od;

  # Get n the number of vertices of the graph
  if list[2] <> 63 then
    n := list[2];
    start := 3;
  elif list[3] = 63 then
    if Length(list) <= 8 then
      Error("Digraphs: DigraphFromDiSparse6String: usage,\n",
            s, " is not a valid disparse6 input,\n");
      return;
    fi;
    n := 0;
    for i in [ 0 .. 5 ] do
      n := n + 2^(6 * i) * list[9 - i];
    od;
    start := 10;
  elif Length(list) > 4 then
      n := 0; 
      for i in [ 0 .. 2 ] do
        n := n + 2^(6 * i) * list[5 - i];
      od;
      start := 6;
  else
    Error("Digraphs: DigraphFromDiSparse6String: usage,\n",
          s, " is not a valid disparse6 input,\n");
    return;
  fi;

  # convert list into a list of bits;
  blist := BlistList([ 1 .. (Length(list) - start + 1) * 6 ], []);
  pos := 1;
  for i in [ start .. Length(list) ] do
    num := list[i];
    bpos := 1;
    while num > 0 do
      if num mod 2 = 0 then
	num := num / 2;
      else
        num := (num - 1) / 2;
	blist[pos + 6 - bpos] := true;
      fi;
      bpos := bpos + 1;
    od;
    pos := pos + 6;
  od;

  if n > 1 then
    k := LogInt(n, 2) + 1;
  else 
    k := 1;
  fi;

  range := [];
  source := [];
  # Get the decreasing edges first
  len := 1;
  v := 0;
  i := 1;
  while true do
    if blist[i] then
      v := v + 1;
    fi;
    x := 0;
    for j in [ 1 .. k ] do
      if blist[i + j] then
        x := x + 2^(k - j);
      fi;
    od;
    if x >= n then
      break;
    elif x > v then
      v := x;
    else
      range[len] := x;
      source[len] := v;
      len  := len + 1;
    fi;
    i := i + k + 1;
  od;
  
  i := i + k + 1;

  # Get the increasing edges
  finish := Length(blist) - (Length(blist) mod (k + 1));
  v := 0;
  while i <= finish - k do
    if blist[i] then
      v := v + 1;
    fi;
    x := 0;
    for j in [ 1 .. k ] do
      if blist[i + j] then
        x := x + 2^(k - j);
      fi;
    od;
    if x >= n then
      break;
    elif x > v then
      v := x;
    else
      range[len] := v;
      source[len] := x;
      len  := len + 1;
    fi;
    i := i + k + 1;
  od;

  range := range + 1;
  source := source + 1;

  return Digraph( rec( nrvertices := n, range := range,
    source := source  ) );
end);

#EOF
