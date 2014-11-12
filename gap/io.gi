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
          "ReadDigraphs( filename [,decoder][,pos] ),");
    return;
  fi;

  if (not IsString(name)) or (not (IsFunction(decoder) or decoder = fail))
    or (not (IsPosInt(nr) or nr = infinity)) then
    Error("Digraphs: ReadDigraphs: usage,\n",
          "ReadDigraphs( filename [,decoder][,pos] ),");
    return;
  fi;

  file := IO_CompressedFile(name, "r");

  if file = fail then
    Error("Digraphs: ReadDigraphs: usage,\n",
          "can't open file ", name, ",");
    return;
  fi;

  if decoder = fail then
    splitname := SplitString(name, ".");
    extension := splitname[Length(splitname)];

    if extension in [ "gz", "bzip2", "xz"] then
      if Length(splitname) = 2 then
        Error("Digraphs: ReadDigraphs: usage,\n",
              "can't determine the file format,");
        return;
      fi;
      extension := splitname[Length(splitname)-1];
    fi;

    if extension = "txt" then
      decoder := DigraphPlainTextLineDecoder("  ", " ", 1);
    elif extension = "g6" then
      decoder := DigraphFromGraph6String;
    elif extension = "s6" then
      decoder := DigraphFromSparse6String;
    elif extension = "d6" then
      decoder := DigraphFromDigraph6String;
    elif extension = "ds6" then
      decoder := DigraphFromDiSparse6String;
    else
      Error("Digraphs: ReadDigraphs: usage,\n",
            "can't determine the file format,");
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
  local FindCoord, list, n, start, maxedges, out, pos, i, bpos, edge, graph, j;

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
          "the input string has to be non-empty,");
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
          "<s> is not a valid graph6 input,");
    return;
  fi;

  maxedges := n * ( n - 1 ) / 2;
  if list <> [0] and not (Int((maxedges - 1) / 6) +  start = Length(list) and
     list[Length(list)] mod 2 ^ ((0 - maxedges) mod 6) = 0) then
    Error("Digraphs: DigraphFromGraph6String: usage,\n",
          "<s> is not a valid graph6 input,");
    return;
  fi;

  out := EmptyPlist(n);
  for i in [ 1 .. n ] do
    out[i] := [];
  od;

  # Obtaining the adjacency vector
  pos := 1;
  for j in [start .. Length(list)] do # Every integer corresponds to 6 bits
    i := list[j];
    bpos := 1;
    while i > 0 do
      if i mod 2  = 0 then
        i := i / 2;
      else
        edge := FindCoord(pos + 6 - bpos, 0);
	out[edge[1]][LEN_LIST(out[edge[1]]) + 1] := edge[2];
	out[edge[2]][LEN_LIST(out[edge[2]]) + 1] := edge[1];
        i := (i - 1) / 2;
      fi;
      bpos := bpos + 1;
    od;
    pos := pos + 6;
  od;
  graph := DigraphNC(out);
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
          "<s> must be a string in Digraph6 format,");
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
          "<s> must be a string in Digraph6 format,");
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

InstallMethod(DigraphFromSparse6String, "for a string",
[IsString],
function(s)
  local list, n, start, blist, pos, num, bpos, k, range, source, len, v, i,
  finish, x, j;


  # Check for the special ':' character
  if s[1] <> ':' then
    Error("Digraphs: DigraphFromSparse6String: usage,\n",
          "<s> must be a string in Sparse6 format,");
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
            "<s> must be a string in Sparse6 format,");
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
          "<s> must be a string in Sparse6 format,");
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
      if v = n then # We have reached the end
        break;
      fi;
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
      len := len + 1;
      if x <> v then
        range[len] := v;
        source[len] := x;
        len := len + 1;
      fi;
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

BindGlobal("SplitStringBySubstring",
function(string, substring)
  local m, n, i, j, out, nr;

  if Length(string) = 0 then
    return [];
  fi;
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
end);

# one graph per line

InstallGlobalFunction(DigraphPlainTextLineDecoder,
function(arg)
  local delimiter, offset, delimiter1, delimiter2;

  if Length(arg) = 2 then
    delimiter := arg[1]; # what delineates the range of an edge from its source
    offset := arg[2];    # indexing starts at 0 or 1? or what?
    return
      function(string)
        string := SplitStringBySubstring(string, delimiter);
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
          "DigraphPlainTextLineDecoder(delimiter, [,delimiter], offset),");
    return;
  fi;
end);

InstallGlobalFunction(DigraphPlainTextLineEncoder,
function(delimiter1, delimiter2, offset)
  return function(digraph)
    local str, i, edges;
    edges := DigraphEdges(digraph);

    if Length(edges) = 0 then 
      return "";
    fi;

    str := Concatenation(String(edges[1][1] + offset), 
             delimiter2, String(edges[1][2] + offset));

    for i in [2 .. Length(edges)] do 
      Append(str, 
       Concatenation(delimiter1, String(edges[i][1] + offset), 
                     delimiter2, String(edges[i][2] + offset)));
    od;
    return str;
  end;
end);

# one edge per line, one graph per file

InstallGlobalFunction(ReadPlainTextDigraph,
function(name, delimiter, offset, ignore)
  local file, lines, edges, nr, decoder, line;

  if IsChar(delimiter) then
    delimiter := [delimiter];
  fi;

  if (not IsString(name)) or (not IsString(delimiter))
    or (not IsInt(offset))
    or (not (IsString(ignore) or IsChar(ignore))) then
    Error("Digraphs: ReadPlainTextDigraph: usage,\n",
          "ReadPlainTextDigraph( filename, delimiter, offset, ignore ),");
    return;
  fi;

  if IsChar(ignore) then
    ignore := [ignore];
  fi;

  file := IO_CompressedFile(name, "r");

  if file = fail then
    Error("Digraphs: ReadPlainTextDigraph,\n",
          "can't open file ", name, ",");
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

#

InstallGlobalFunction(WritePlainTextDigraph,
function(name, digraph, delimiter, offset)
  local file, encoder, edge;

  if IsChar(delimiter) then
    delimiter := [delimiter];
  fi;

  if (not IsString(name)) or (not IsString(delimiter))
    or (not IsInt(offset)) then
    Error("Digraphs: WritePlainTextDigraph: usage,\n",
          "WritePlainTextDigraph( filename, digraph, delimiter, offset ),");
    return;
  fi;

  file := IO_CompressedFile(name, "w");

  if file = fail then
    Error("Digraphs: WritePlainTextDigraph,\n",
          "can't open file ", name, ",");
    return;
  fi;

  for edge in DigraphEdges(digraph) do
    IO_WriteLine(file, Concatenation(
            String(edge[1]+offset),
            delimiter,
            String(edge[2]+offset) ));
  od;
  IO_Close(file);
end);

#

InstallGlobalFunction(WriteDigraphs,
function(name, digraphs)
  local splitpath, splitname, compext, ext, encoder, g6sum, s6sum, digraph, v, 
        e, dg6sum, ds6sum, filepath, file, s;
  if not ForAll(digraphs, IsDigraph) then
    Error("Digraphs: WriteDigraphs: usage,\n",
          "<digraphs> must be a list of digraphs,");
    return;
  fi;
  
  # Look for extension
  splitpath := SplitString(name, "/");
  splitname := SplitString(Remove(splitpath), ".");
  compext := fail;
  
  if Length(splitname) >= 2 then
    ext := splitname[Length(splitname)];
    # Compression extensions
    if ext in [ "gz", "bzip2", "xz"] then
      compext := Remove(splitname);
      if Length(splitname) >= 2 then
        ext := splitname[Length(splitname)];
      fi;
    else
      compext := fail;
    fi;
    # Format extensions
    if ext = "g6" then
      encoder := Graph6String;
    elif ext = "s6" then
      encoder := Sparse6String;
    elif ext = "d6" then
      encoder := Digraph6String;
    elif ext = "ds6" then
      encoder := DiSparse6String;
    elif ext = "txt" then
      encoder := DigraphPlainTextLineEncoder("  ", " ", -1);
    else
      encoder := fail;
    fi;
  else
    encoder := fail;
  fi;  
  
  if encoder = fail then
    # CHOOSE A GOOD ENCODER:
    # Do we know all the graphs to be symmetric?
    if ForAll(digraphs, g-> HasIsSymmetricDigraph(g) and IsSymmetricDigraph(g)) then
      if ForAll(digraphs, IsMultiDigraph) then
        encoder := DiSparse6String;
        Add(splitname, "ds6");
      else
        # Find the sum of length estimates using Graph6 and Sparse6
        g6sum := 0;
        s6sum := 0;
        for digraph in digraphs do
          v := DigraphNrVertices(digraph);
          e := DigraphNrEdges(digraph);
          g6sum := g6sum + (v * (v-1) / 2);
          s6sum := s6sum + (e/2 * (Log2Int(v-1) + 2) * 3/2);
        od;
        if g6sum < s6sum and not ForAny(digraphs, DigraphHasLoops) then
          encoder := Graph6String;
          Add(splitname, "g6");
        else
          encoder := Sparse6String;
          Add(splitname, "s6");
        fi;
      fi;
    else
      if ForAny(digraphs, IsMultiDigraph) then
        encoder := DiSparse6String;
        Add(splitname, "ds6");
      else
        # Find the sum of length estimates using Digraph6 and DiSparse6
        dg6sum := 0;
        ds6sum := 0;
        for digraph in digraphs do
          v := DigraphNrVertices(digraph);
          e := DigraphNrEdges(digraph);
          dg6sum := dg6sum + v^2;
          ds6sum := ds6sum + (e * (Log2Int(v) + 2) * 3/2);
        od;
        if dg6sum < ds6sum then
          encoder := Digraph6String;
          Add(splitname, "d6");
        else
          encoder := DiSparse6String;
          Add(splitname, "ds6");
        fi;
      fi;
    fi;
  fi;
  
  # Rebuild the filename
  if compext <> fail then
    Add(splitname, compext);
  fi;
  Add(splitpath, JoinStringsWithSeparator(splitname, "."));
  filepath := JoinStringsWithSeparator(splitpath, "/");
  
  if filepath <> name then
    Info(InfoWarning, 1, "Writing to ", filepath);
  fi;
  file := IO_CompressedFile(filepath, "w");

  if file = fail then
    Error("Digraphs: WriteDigraphs: usage,\n",
          "can't open file ", filepath, ",\n");
    return;
  fi;

  for digraph in digraphs do
    s := encoder(digraph);
    ConvertToStringRep(s);
    IO_WriteLine(file, s);
  od;
  
  IO_Close(file);
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

#

InstallMethod(Graph6String, "for a digraph",
[IsDigraph],
function(graph)
  local list, adj, n, lenlist, tablen, blist, i, j, pos, block;
  if ( IsMultiDigraph(graph)
       or not IsSymmetricDigraph(graph)
       or DigraphHasLoops(graph) ) then
    Error("Digraphs: Graph6String: usage,\n",
          "<graph> must be symmetric and have no loops or multiple edges,");
    return;
  fi;
  
  list := [];
  adj := OutNeighbours(graph);
  n := Length(DigraphVertices(graph));

  # First write the number of vertices
  lenlist := Graph6Length(n);
  if lenlist = fail then
    Error("Digraphs: Graph6String: usage,\n",
          "<graph> must have between 0 and 68719476736 vertices,");
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

InstallMethod(Digraph6String, "for a digraph",
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
    Error("Digraphs: Digraph6String: usage,\n",
          "<graph> must have between 0 and 68719476736 vertices,");
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

InstallMethod(Sparse6String, "for a digraph",
[IsDigraph],
function(graph)
  local list, n, lenlist, adj, nredges, k, blist, v, nextbit, AddBinary, i, j,
        bitstopad, pos, block;
  if not IsSymmetricDigraph(graph) then
    Error("Digraphs: Sparse6String: usage,\n",
          "the argument <graph> must be a symmetric digraph,");
    return;
  fi;

  list := [];
  n := Length(DigraphVertices(graph));

  # First write the special character ':'
  Add(list,-5);

  # Now write the number of vertices
  lenlist := Graph6Length(n);
  if lenlist = fail then
    Error("Digraphs: Sparse6String: usage,\n",
          "<graph> must have between 0 and 68719476736 vertices,");
    return;
  fi;
  Append(list, lenlist);

  # Get the out-neighbours - half these edges will be discarded
  adj := OutNeighbours(graph);
  nredges := DigraphNrEdges(graph);

  # k is the number of bits in a vertex label
  if n > 1 then
    k := Log2Int(n-1) + 1;
  else
    k := 1;
  fi;

  # Add the edges one by one
  blist := BlistList([1..nredges*(k+1)/2],[]);
  v := 0;
  nextbit := 1;
  AddBinary := function(blist, i)
    local b;
    for b in [1..k] do
      blist[nextbit] := Int((i mod (2^(k-b+1))) / (2^(k-b))) = 1;
      nextbit := nextbit + 1;
    od;
  end;
  for i in [1..Length(adj)] do
  for j in adj[i] do
    if i < j then
      continue;
    elif i-1 = v then
      blist[nextbit] := false;
      nextbit := nextbit + 1;
    elif i-1 = v+1 then
      blist[nextbit] := true;
      nextbit := nextbit + 1;
      v := v + 1;
    elif i-1 > v+1 then
      blist[nextbit] := true;
      nextbit := nextbit + 1;
      AddBinary(blist, i-1);
      v := i-1;
      blist[nextbit] := false;
      nextbit := nextbit + 1;
    fi;
    AddBinary(blist, j-1);
  od;
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

InstallMethod(DiSparse6String, "for a digraph",
[IsDigraph],
function(graph)
  local list, n, lenlist, adj, source_i, range_i, source_d, range_d, len1, len2, 
        i, j, sort_d, perm, sort_i, k, blist, v, nextbit, AddBinary, bitstopad, 
        pos, block;
  
  list := [];
  n := Length(DigraphVertices(graph));

  # First write the special character '.'
  list[1] := -17;

  # Now write the number of vertices
  lenlist := Graph6Length(n);
  if lenlist = fail then
    Error("Digraphs: DiSparse6String: usage,\n",
          "<graph> must have between 0 and 68719476736 vertices,");
    return;
  fi;
  Append(list, lenlist);

  # Separate edges into increasing and decreasing
  adj := OutNeighbours(graph);
  source_i := [];
  range_i := [];
  source_d := [];
  range_d := [];
  len1 := 1;
  len2 := 1;
  for i in DigraphVertices(graph) do
    for j in adj[i] do
      if i <= j then
        source_i[len1] := i-1;
        range_i[len1] := j-1;
        len1 := len1 + 1;
      else
        source_d[len2] := i-1;
        range_d[len2] := j-1;
        len2 := len2 + 1;
      fi;
    od;
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
          "<s> must be a string in disparse6 format,");
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
            s, " is not a valid disparse6 input,");
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
          s, " is not a valid disparse6 input,");
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
  # BAD!! JDM
  range := range + 1;
  source := source + 1;

  return Digraph( rec( nrvertices := n, range := range,
    source := source  ) );
end);

#

InstallMethod(PlainTextString, "for a digraph",
[IsDigraph], 
function(digraph)
  local encoder;
  encoder := DigraphPlainTextLineEncoder("  ", " ", -1);
  return encoder(digraph);
end);

InstallMethod(DigraphFromPlainTextString, "for a string",
[IsString], 
function(digraph)
  local decoder;
  decoder := DigraphPlainTextLineDecoder("  ", " ", 1);
  return decoder(digraph);
end);


#EOF
