#############################################################################
##
##  io.gi
##  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

#############################################################################
## This file contains methods for reading and writing digraphs from and to
## files.
##
## It is organized as follows:
##
##   0. Internal functions
##
##   1. Picklers for IO
##
##   2. Read/WriteDigraphs (the main functions)
##
##   3. Decoders
##
##   4. Encoders
##
#############################################################################

#############################################################################
# 0. Internal functions
#############################################################################

BindGlobal("DIGRAPHS_SplitStringBySubstring",
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
    if string{[i .. i + n - 1]} = substring then
      if i <> 1 then
        nr := nr + 1;
        out[nr] := string{[j .. i - 1]};
        j := i + n;
        i := i + n;
      fi;
    else
      i := i + 1;
    fi;
  od;
  nr := nr + 1;
  out[nr] := string{[j .. Length(string)]};
  return out;
end);

BindGlobal("DIGRAPHS_Graph6Length",
function(n)
  local list;
  list := [];
  if n < 0 then
    return fail;
  elif n < 63 then
    Add(list, n);
  elif n < 258248 then
    Add(list, 63);
    Add(list, Int(n / 64 ^ 2));
    Add(list, Int(n / 64) mod 64);
    Add(list, n mod 64);
  elif n < 68719476736 then
    Add(list, 63);
    Add(list, 63);
    Add(list, Int(n / 64 ^ 5));
    Add(list, Int(n / 64 ^ 4) mod 64);
    Add(list, Int(n / 64 ^ 3) mod 64);
    Add(list, Int(n / 64 ^ 2) mod 64);
    Add(list, Int(n / 64 ^ 1) mod 64);
    Add(list, n mod 64);
  else
    return fail;
  fi;
  return list;
end);

################################################################################
# 1. Picklers
################################################################################

InstallMethod(IO_Pickle, "for a digraph with known digraph group",
[IsFile, IsDigraph and HasDigraphGroup],
function(file, gr)
  local g, out;
  g := DigraphGroup(gr);
  if IsTrivial(g) then
    TryNextMethod();
  fi;
  if IO_Write(file, "DIGG") = fail then
    return IO_Error;
  fi;
  out := [GeneratorsOfGroup(g),
          RepresentativeOutNeighbours(gr),
          DigraphSchreierVector(gr)];
  return IO_Pickle(file, out);
end);

IO_Unpicklers.DIGG := function(file)
  local list, gens, rep_out, sch, out, trace, word, digraph, i, w;

  list := IO_Unpickle(file);
  if list = IO_Error then
    return IO_Error;
  fi;

  gens    := list[1];
  rep_out := list[2];
  sch     := list[3];

  out  := [];
  for i in [1 .. Length(sch)] do
    if sch[i] < 0 then
      out[i] := rep_out[-sch[i]];
    fi;

    trace := DIGRAPHS_TraceSchreierVector(gens, sch, i);
    out[i] := rep_out[trace.representative];
    word := trace.word;
    for w in word do
       out[i] := OnTuples(out[i], gens[w]);
    od;
  od;

  digraph := DigraphNC(out);

  SetDigraphGroup(digraph, Group(gens));
  SetDigraphSchreierVector(digraph, sch);
  SetRepresentativeOutNeighbours(digraph, rep_out);
  return digraph;
end;

InstallMethod(IO_Pickle, "for a digraph",
[IsFile, IsDigraph],
function(file, gr)
  if IO_Write(file, "DIGT") = fail then
    return IO_Error;
  fi;
  return IO_Pickle(file, OutNeighbours(gr));
end);

IO_Unpicklers.DIGT := function(file)
  local out;
  out := IO_Unpickle(file);
  if out = IO_Error then
    return IO_Error;
  fi;
  return DigraphNC(out);
end;

################################################################################
# 2. ReadDigraphs and WriteDigraphs
################################################################################

InstallGlobalFunction(IteratorFromDigraphFile,
function(arg)
  local filename, decoder, file, record;

  if Length(arg) = 1 then
    filename := arg[1];
    decoder := fail;
  elif Length(arg) = 2 then
    filename := arg[1];
    decoder := arg[2];
  else
    ErrorNoReturn("Digraphs: IteratorFromDigraphFile: usage,\n",
                  "there should be 1 or 2 arguments,");
  fi;

  if not IsString(filename) then
    ErrorNoReturn("Digraphs: IteratorFromDigraphFile: usage,\n",
                  "the first argument must be a string,");
  elif decoder <> fail and not IsFunction(decoder) then
    ErrorNoReturn("Digraphs: IteratorFromDigraphFile: usage,\n",
                  "the second argument must be a function,");
  fi;

  file := DigraphFile(UserHomeExpand(filename), decoder, "r");

  record := rec(file := file, current := file!.coder(file));

  record.NextIterator := function(iter)
    local next;
    next := iter!.current;
    iter!.current := iter!.file!.coder(iter!.file);
    return next;
  end;

  record.IsDoneIterator := function(iter)
    if iter!.current = IO_Nothing then
      if not iter!.file!.closed then
        IO_Close(iter!.file);
      fi;
      return true;
    else
      return false;
    fi;
  end;

  record.ShallowCopy := function(iter)
    local file;
    file := DigraphFile(UserHomeExpand(filename), decoder, "r");
    return rec(file := file, current := file!.coder(file));
  end;

  return IteratorByFunctions(record);
end);

# these functions wrap the various line encoders/decoders in this file so that
# they behave like IO_Pickle.

BindGlobal("DIGRAPHS_EncoderWrapper",
function(encoder)
  if encoder = IO_Pickle then
    return IO_Pickle;
  fi;
  return
    function(file, digraph)
      return IO_WriteLine(file, encoder(digraph));
    end;
end);

BindGlobal("DIGRAPHS_DecoderWrapper",
function(decoder)
  if decoder = IO_Unpickle then
    return IO_Unpickle;
  fi;
  return
    function(file)
      local line;
      line := IO_ReadLine(file);
      if line = "" then
        return IO_Nothing;
      fi;
      return decoder(line);
    end;
end);

# if we are choosing the decoder, then the file extension is used.

BindGlobal("DIGRAPHS_ChooseFileDecoder",
function(filename)
  local splitname, extension;

  if not IsString(filename) then
    ErrorNoReturn("Digraphs: DIGRAPHS_ChooseFileDecoder: usage,\n",
                  "the argument must be a string,");
  fi;

  splitname := SplitString(filename, ".");
  extension := splitname[Length(splitname)];

  if extension in ["gz", "bz2", "xz"] then
    extension := splitname[Length(splitname) - 1];
  fi;

  if extension = "txt" then
    return DigraphPlainTextLineDecoder("  ", " ", 1);
  elif extension = "g6" then
    return DigraphFromGraph6String;
  elif extension = "s6" then
    return DigraphFromSparse6String;
  elif extension = "d6" then
    return DigraphFromDigraph6String;
  elif extension = "ds6" then
    return DigraphFromDiSparse6String;
  elif extension = "p" or extension = "pickle" then
    return IO_Unpickle;
  fi;

  return fail;
end);

# if we are choosing the decoder, then the file extension is used.

BindGlobal("DIGRAPHS_ChooseFileEncoder",
function(filename)
  local splitname, extension;

  if not IsString(filename) then
    ErrorNoReturn("Digraphs: DIGRAPHS_ChooseFileEncoder: usage,\n",
                  "the argument must be a string,");
  fi;

  splitname := SplitString(filename, ".");
  extension := splitname[Length(splitname)];

  if extension in ["gz", "bz2", "xz"] then
    extension := splitname[Length(splitname) - 1];
  fi;

  if extension = "txt" then
    return DigraphPlainTextLineEncoder("  ", " ", -1);
  elif extension = "g6" then
    return Graph6String;
  elif extension = "s6" then
    return Sparse6String;
  elif extension = "d6" then
    return Digraph6String;
  elif extension = "ds6" then
    return DiSparse6String;
  elif extension = "p" or extension = "pickle" then
    return IO_Pickle;
  fi;
  return fail;
end);

InstallGlobalFunction(DigraphFile,
function(arg)
  local name, coder, mode, file;

  if Length(arg) = 1 then
    name := arg[1];
    coder := fail;
    mode := "r";
  elif Length(arg) = 2 then
    name := arg[1];
    if IsFunction(arg[2]) then
      coder := arg[2];
      mode := "r";
    else
      coder := fail;
      mode := arg[2];
    fi;
  elif Length(arg) = 3 then
    name := arg[1];
    coder := arg[2];
    mode := arg[3];
  else
    ErrorNoReturn("Digraphs: DigraphFile: usage,\n",
                  "DigraphFile( filename [, coder][, mode] ),");
  fi;

  # TODO check that the mode and the coder are compatible

  if not IsString(name) or (not (IsFunction(coder) or coder = fail))
      or (not mode in ["a", "w", "r"]) then
    ErrorNoReturn("Digraphs: DigraphFile: usage,\n",
                  "DigraphFile( filename [, coder][, mode] ),");
  fi;

  if coder = fail then  # <coder> not specified by the user
    if mode = "r" then
      coder := DIGRAPHS_ChooseFileDecoder(name);
    else
      coder := DIGRAPHS_ChooseFileEncoder(name);
    fi;
  fi;

  if coder = fail then
    ErrorNoReturn("Digraphs: DigraphFile:\n",
                  "cannot determine the file format,");
  elif mode = "r" then
    coder := DIGRAPHS_DecoderWrapper(coder);
  else
    coder := DIGRAPHS_EncoderWrapper(coder);
  fi;

  file := IO_CompressedFile(UserHomeExpand(name), mode);

  if file = fail then
    ErrorNoReturn("Digraphs: DigraphFile:\n",
                  "cannot open file ", name, ",");
  fi;

  file!.coder := coder;

  return file;
end);

InstallGlobalFunction(ReadDigraphs,
function(arg)
  local name, decoder, nr, file, read, i, next, out;

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
    ErrorNoReturn("Digraphs: ReadDigraphs: usage,\n",
                  "ReadDigraphs( filename [, decoder][, pos] ),");
  fi;

  if (not (IsString(name) or IsFile(name)))
      or (not (IsFunction(decoder) or decoder = fail))
      or (not (IsPosInt(nr) or nr = infinity)) then
    ErrorNoReturn("Digraphs: ReadDigraphs: usage,\n",
                  "ReadDigraphs( filename [, decoder][, pos] ),");
  fi;

  if IsString(name) then
    file := DigraphFile(name, decoder, "r");
  else
    file := name;
    if file!.closed then
      ErrorNoReturn("Digraphs: ReadDigraphs: usage,\n",
                    "the file is closed,");
    elif file!.rbufsize = false then
      ErrorNoReturn("Digraphs: ReadDigraphs: usage,\n",
                    "the mode of the file must be \"r\",");
    fi;
  fi;

  decoder := file!.coder;

  if nr < infinity then
    if decoder = IO_Unpickle then
      read := IO_Unpickle;
    else
      read := IO_ReadLine;
    fi;
    i := 0;
    next := fail;
    while i < nr - 1 and next <> IO_Nothing do
      i := i + 1;
      next := read(file);
    od;
    if next <> IO_Nothing then
      out := decoder(file);
    else
      out := IO_Nothing;
    fi;
    if IsString(arg[1]) then
      IO_Close(file);
    fi;
    return out;
  fi;

  out := [];
  next := decoder(file);

  while next <> IO_Nothing do
    Add(out, next);
    next := decoder(file);
  od;

  if IsString(arg[1]) then
    IO_Close(file);
  fi;

  return out;
end);

InstallGlobalFunction(WriteDigraphs,
function(arg)
  local name, digraphs, encoder, mode, splitname, compext, g6sum, s6sum, v, e,
  dg6sum, ds6sum, file, digraph, i;

  if Length(arg) = 2 then
    name := arg[1];
    digraphs := arg[2];
    encoder := fail;
    mode := "a";
  elif Length(arg) = 3 then
    name := arg[1];
    digraphs := arg[2];
    if IsFunction(arg[3]) then
      encoder := arg[3];
      mode := "a";
    else
      encoder := fail;
      mode := arg[3];
      if IsFile(name) then
        ErrorNoReturn("Digraphs: WriteDigraphs: usage,\n",
                      "the mode is specified by the file in the first ",
                      "argument and cannot be given as\nan argument,");
      fi;
    fi;
  elif Length(arg) = 4 then
    name := arg[1];
    digraphs := arg[2];
    encoder := arg[3];
    mode := arg[4];
    if IsFile(name) then
      ErrorNoReturn("Digraphs: WriteDigraphs: usage,\n",
                    "the mode is specified by the file in the first ",
                    "argument and cannot be given as\nan argument,");
    fi;
  else
    ErrorNoReturn("Digraphs: WriteDigraphs: usage,\n",
                  "there must be 2, 3, or 4 arguments,");
  fi;

  if not IsList(digraphs) then
    digraphs := [digraphs];
  fi;

  if not (IsString(name) or IsFile(name)) then
    ErrorNoReturn("Digraphs: WriteDigraphs: usage,\n",
                  "the argument <name> must be a string or a file,");
  elif not ForAll(digraphs, IsDigraph) then
    ErrorNoReturn("Digraphs: WriteDigraphs: usage,\n",
                  "the argument <digraphs> must be a list of digraphs,");
  elif not (IsFunction(encoder) or encoder = fail) then
    ErrorNoReturn("Digraphs: WriteDigraphs: usage,\n",
                  "the argument <encoder> must be a function,");
  elif not mode in ["a", "w"] then
    ErrorNoReturn("Digraphs: WriteDigraphs: usage,\n",
                  "the argument <mode> must be \"a\" or \"w\",");
  fi;

  if IsString(name) and not IsExistingFile(name) then
    mode := "w";
  fi;

  if IsString(name) then
    if encoder = fail and DIGRAPHS_ChooseFileEncoder(name) = fail then
      # the file encoder was not specified and cannot be deduced from the
      # filename, so we try to make a guess based on the digraphs themselves
      splitname := SplitString(name, ".");
      if splitname[Length(splitname)] in ["xz", "gz", "bz2"] then
        compext := splitname[Length(splitname)];
        splitname := splitname{[1 .. Length(splitname) - 1]};
      fi;

      # Do we know all the graphs to be symmetric?
      if ForAll(digraphs, g -> HasIsSymmetricDigraph(g)
                               and IsSymmetricDigraph(g)) then
        if ForAny(digraphs, IsMultiDigraph) then
          encoder := DiSparse6String;
          Add(splitname, "ds6");
        else
          # Find the sum of length estimates using Graph6 and Sparse6
          g6sum := 0;
          s6sum := 0;
          for digraph in digraphs do
            v := DigraphNrVertices(digraph);
            e := DigraphNrEdges(digraph);
            g6sum := g6sum + (v * (v - 1) / 2);
            s6sum := s6sum + (e / 2 * (Log2Int(v - 1) + 2) * 3 / 2);
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
            dg6sum := dg6sum + v ^ 2;
            ds6sum := ds6sum + (e * (Log2Int(v) + 2) * 3 / 2);
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
      name := JoinStringsWithSeparator(splitname, ".");
      if IsBound(compext) then
        Append(name, ".");
        Append(name, compext);
      fi;
      Info(InfoWarning, 1, "Writing to ", name);
    fi;
    file := DigraphFile(name, encoder, mode);
  else
    file := name;
    if file!.closed then
      ErrorNoReturn("Digraphs: WriteDigraphs: usage,\n",
                    "the argument <file> is closed,");
    elif file!.wbufsize = false then
      ErrorNoReturn("Digraphs: WriteDigraphs: usage,\n",
                    "the mode of the argument <file> must be \"w\" or \"a\",");
    fi;
  fi;

  encoder := file!.coder;

  for i in [1 .. Length(digraphs)] do
    encoder(file, digraphs[i]);
  od;

  if IsString(arg[1]) then
    IO_Close(file);
  fi;

  return IO_OK;
end);

################################################################################
# 3. Decoders
################################################################################

InstallGlobalFunction(TournamentLineDecoder,
function(str)
  local out, pos, n, i, j;

  pos := 0;
  n := (Sqrt(8 * Length(str) + 1) + 1) / 2;
  out := List([1 .. n], x -> []);
  for i in [1 .. n - 1] do
    for j in [i + 1 .. n] do
      pos := pos + 1;
      if str[pos] = '1' then
        Add(out[i], j);
      else
        Add(out[j], i);
      fi;
    od;
  od;

  return Digraph(out);
end);

InstallGlobalFunction(AdjacencyMatrixUpperTriangleLineDecoder,
function(str)
  local out, pos, n, i, j;
  str := Chomp(str);
  pos := 0;
  n := (Sqrt(8 * Length(str) + 1) + 1) / 2;
  out := List([1 .. n], x -> []);
  for i in [1 .. n - 1] do
    for j in [i + 1 .. n] do
      pos := pos + 1;
      if str[pos] = '1' then
        Add(out[i], j);
      fi;
    od;
  od;

  return Digraph(out);
end);

InstallGlobalFunction(TCodeDecoder,
function(str)
  local out, i;
  if not IsString(str) then
    ErrorNoReturn("Digraphs: TCodeDecoder: usage,\n",
                  "first argument <str> must be a string,");
  fi;

  str := SplitString(Chomp(str), " ");
  Apply(str, EvalString);

  if not ForAll(str, x -> IsInt(x) and x >= 0) then
    ErrorNoReturn("Digraphs: TCodeDecoder: usage,\n",
                  "1st argument <str> must be a string of ",
                  "space-separated non-negative integers,");
  fi;
  if not Length(str) >= 2 then
    ErrorNoReturn("Digraphs: TCodeDecoder: usage,\n",
                  "first argument <str> must be a string of ",
                  "at least two integers,");
  fi;
  if not ForAll([3 .. Length(str)], i -> str[i] < str[1]) then
    ErrorNoReturn("Digraphs: TCodeDecoder: usage,\n",
                  "vertex numbers must be in the range [0 .. n - 1], ",
                  "where\nn = ", str[1], " is the first entry in <str>,");
  fi;
  if Length(str) < 2 * str[2] + 2 then
    ErrorNoReturn("Digraphs: TCodeDecoder: usage,\n",
                  "<str> must contain at least 2e + 2 entries,\n",
                  "where e is the number of edges (the 2nd entry in <str>),");
  fi;

  out := List([1 .. str[1]], x -> []);
  for i in [1 .. str[2]] do
    Add(out[str[2 * i + 1] + 1], str[2 * i + 2] + 1);
  od;

  return Digraph(out);
end);

InstallGlobalFunction(TCodeDecoderNC,
function(str)
  local out, i;

  str := SplitString(Chomp(str), " ");
  Apply(str, Int);
  out := List([1 .. str[1]], x -> []);
  for i in [1 .. str[2]] do
    Add(out[str[2 * i + 1] + 1], str[2 * i + 2] + 1);
  od;
  return DigraphNC(out);
end);

InstallMethod(DigraphFromGraph6String, "for a string",
[IsString],
function(s)
  local FindCoord, list, n, start, maxedges, out, pos, nredges, i, bpos, edge,
  gr, j;

  s := Chomp(s);

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
    return [pos - sum + i, i + 1];
  end;

  if Length(s) = 0 then
    ErrorNoReturn("Digraphs: DigraphFromGraph6String: usage,\n",
                  "the input string <s> should be non-empty,");
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
      for i in [0 .. 5] do
        n := n + 2 ^ (6 * i) * list[8 - i];
      od;
      start := 9;
    else
      n := 0;
      for i in [0 .. 2] do
        n := n + 2 ^ (6 * i) * list[4 - i];
      od;
      start := 5;
    fi;
  else
    ErrorNoReturn("Digraphs: DigraphFromGraph6String: usage,\n",
                  "the input string <s> is not in valid graph6 format,");
  fi;

  maxedges := n * (n - 1) / 2;
  if list <> [0] and list <> [1] and
      not (Int((maxedges - 1) / 6) + start = Length(list) and
           list[Length(list)] mod 2 ^ ((0 - maxedges) mod 6) = 0) then
    ErrorNoReturn("Digraphs: DigraphFromGraph6String: usage,\n",
                  "the input string <s> is not in valid graph6 format,");
  fi;

  out := List([1 .. n], x -> []);

  # Obtaining the adjacency vector
  pos := 1;
  nredges := 0;
  for j in [start .. Length(list)] do  # Every integer corresponds to 6 bits
    i := list[j];
    bpos := 1;
    while i > 0 do
      if i mod 2 = 0 then
        i := i / 2;
      else
        edge := FindCoord(pos + 6 - bpos, 0);
        out[edge[1]][LEN_LIST(out[edge[1]]) + 1] := edge[2];
        out[edge[2]][LEN_LIST(out[edge[2]]) + 1] := edge[1];
        nredges := nredges + 1;
        i := (i - 1) / 2;
      fi;
      bpos := bpos + 1;
    od;
    pos := pos + 6;
  od;
  gr := DigraphNC(out, 2 * nredges);
  SetIsSymmetricDigraph(gr, true);
  SetIsMultiDigraph(gr, false);
  SetDigraphHasLoops(gr, false);
  return gr;
end);

InstallMethod(DigraphFromDigraph6String, "for a string",
[IsString],
function(s)
  local list, i, n, start, range, source, pos, len, j, bpos, tabpos;

  s := Chomp(s);
  # Check non-emptiness
  if Length(s) = 0 then
    ErrorNoReturn("Digraphs: DigraphFromDigraph6String: usage,\n",
                  "the input string <s> should be non-empty,");
  fi;

  # Check for the special '+' character
  if s[1] <> '+' then
    ErrorNoReturn("Digraphs: DigraphFromDigraph6String: usage,\n",
                  "the input string <s> is not in valid digraph6 format,");
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
      for i in [0 .. 5] do
        n := n + 2 ^ (6 * i) * list[9 - i];
      od;
      start := 10;
    else
      n := 0;
      for i in [0 .. 2] do
        n := n + 2 ^ (6 * i) * list[5 - i];
      od;
      start := 6;
    fi;
  else
    ErrorNoReturn("Digraphs: DigraphFromDigraph6String: usage,\n",
                  "the input string <s> is not in valid digraph6 format,");
  fi;

  range := [];
  source := [];

  # Obtaining the adjacency vector
  pos := 1;
  len := 1;
  for j in [start .. Length(list)] do  # Every integer corresponds to 6 bits
    i := list[j];
    bpos := 1;
    while i > 0 do
      if i mod 2 = 0 then
        i := i / 2;
      else
        tabpos := pos + 6 - bpos;
        source[len] := (tabpos - 1) mod n + 1;
        range[len] := (tabpos - source[len]) / n + 1;
        len := len + 1;
        i := (i - 1) / 2;
      fi;
      bpos := bpos + 1;
    od;
    pos := pos + 6;
  od;

  return Digraph(rec(nrvertices := n, range := range, source := source));
end);

InstallMethod(DigraphFromSparse6String, "for a string",
[IsString],
function(s)
  local list, n, start, blist, pos, num, bpos, k, range, source, len, v, i,
  finish, x, gr, j;

  s := Chomp(s);
  # Check non-emptiness
  if Length(s) = 0 then
    ErrorNoReturn("Digraphs: DigraphFromSparse6String: usage,\n",
                  "the input string <s> should be non-empty,");
  fi;

  # Check for the special ':' character
  if s[1] <> ':' then
    ErrorNoReturn("Digraphs: DigraphFromSparse6String: usage,\n",
                  "the input string <s> is not in valid sparse6 format,");
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
      ErrorNoReturn("Digraphs: DigraphFromSparse6String: usage,\n",
                    "the input string <s> is not in valid sparse6 format,");
    fi;
    n := 0;
    for i in [0 .. 5] do
      n := n + 2 ^ (6 * i) * list[9 - i];
    od;
    start := 10;
  elif Length(list) > 4 then
      n := 0;
      for i in [0 .. 2] do
        n := n + 2 ^ (6 * i) * list[5 - i];
      od;
      start := 6;
  else
    ErrorNoReturn("Digraphs: DigraphFromSparse6String: usage,\n",
                  "the input string <s> is not in valid sparse6 format,");
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
      bpos := bpos + 1;
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
      if v = n then  # We have reached the end
        break;
      fi;
    fi;
    x := 0;
    for j in [1 .. k] do
      if blist[i + j] then
        x := x + 2 ^ (k - j);
      fi;
    od;
    if x = n then  # We have reached the end
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
  gr := Digraph(rec(nrvertices := n,
                    nredges := len - 1,
                    range := range,
                    source := source));
  SetIsSymmetricDigraph(gr, true);
  SetIsMultiDigraph(gr, false);
  return gr;
end);

# one graph per line

InstallGlobalFunction(DigraphPlainTextLineDecoder,
function(arg)
  local delimiter, offset, delimiter1, delimiter2;

  if Length(arg) = 2 then
    delimiter := arg[1];  # what delineates the range of an edge from its source
    offset := arg[2];     # indexing starts at 0 or 1? or what?
    return
      function(string)
        string := DIGRAPHS_SplitStringBySubstring(Chomp(string), delimiter);
        Apply(string, Int);
        return string + offset;
      end;
  elif Length(arg) = 3 then
    delimiter1 := arg[1];  # what delineates one edge from the next
    delimiter2 := arg[2];  # what delineates the range of an edge from its source
    offset := arg[3];      # indexing starts at 0 or 1? or what?
    return
      function(string)
        local edges, x;
        string := DIGRAPHS_SplitStringBySubstring(Chomp(string), delimiter1);
        Apply(string, x -> DIGRAPHS_SplitStringBySubstring(x, delimiter2));
        edges := EmptyPlist(Length(string));
        for x in string do
          Apply(x, Int);
          x := x + offset;
          Add(edges, x);
        od;
        return DigraphByEdges(edges);
      end;
  fi;
  ErrorNoReturn("Digraphs: DigraphPlainTextLineDecoder: usage,\n",
                "DigraphPlainTextLineDecoder(delimiter, [,delimiter], ",
                "offset),");
end);

# DIMACS format: for symmetric digraphs, one per file.
#                Can have loops and multiple edges.

InstallMethod(ReadDIMACSDigraph, "for a string", [IsString],
function(name)
  local file, malformed_file, int_from_string, next, split, first_char,
  nr_vertices, vertices, vertex_labels, nr_edges, directed_edges,
  symmetric_edges, nbs, vertex, label, i, j, digraph;

  file := IO_CompressedFile(UserHomeExpand(name), "r");
  if file = fail then
    ErrorNoReturn("Digraphs: ReadDIMACSDigraph:\n",
                  "cannot open the file <name>,");
  fi;

  # Helper function for when an error is found in the file's formatting
  malformed_file := function()
    IO_Close(file);
    ErrorNoReturn("Digraphs: ReadDIMACSDigraph:\n",
                  "the format of the file <name> cannot be understood,");
  end;

  # Helper function to read a string into a non-negative integer
  int_from_string := function(string)
    local int;
    int := Int(string);
    if int = fail or int < 0 then
      malformed_file();
    fi;
    return int;
  end;

  next := IO_ReadLine(file);
  while not IsEmpty(next) do
    NormalizeWhitespace(next);

    # the line is entirely whitespace or a comment
    if IsEmpty(next) or next[1] = 'c' then
      next := IO_ReadLine(file);
      continue;
    fi;

    split := SplitString(next, " ");

    # the line doesn't have a `type'
    if Length(split[1]) <> 1 then
      malformed_file();
    fi;

    first_char := next[1];

    # digraph definition line
    if first_char = 'p' then
      if IsBound(vertices) or Length(split) <> 4 or split[2] <> "edge" then
        malformed_file();
      fi;
      nr_vertices     := int_from_string(split[3]);
      vertices        := [1 .. nr_vertices];
      vertex_labels   := vertices * 0 + 1;
      nr_edges        := int_from_string(split[4]);
      directed_edges  := 0;
      symmetric_edges := 0;
      nbs := List(vertices, x -> []);
      next := IO_ReadLine(file);
      continue;
    fi;

    if not IsBound(vertices) then
      # the problem definition line must precede all other types
      malformed_file();
    elif first_char = 'n' then
      # type: vertex label
      if Length(split) <> 3 then
        malformed_file();
      fi;
      vertex := int_from_string(split[2]);
      if not vertex in vertices then
        malformed_file();
      fi;
      label := Int(split[3]);
      if label = fail then
        malformed_file();
      fi;
      vertex_labels[vertex] := label;
    elif first_char = 'e' then
      # type: edge
      if Length(split) <> 3 then
        malformed_file();
      fi;
      i := int_from_string(split[2]);
      j := int_from_string(split[3]);
      if not (i in vertices and j in vertices) then
        malformed_file();
      fi;
      Add(nbs[i], j);
      directed_edges := directed_edges + 1;
      symmetric_edges := symmetric_edges + 1;
      if i <> j then
        Add(nbs[j], i);
        directed_edges := directed_edges + 1;
      fi;
    elif first_char in "dvx" then
      # type: unsupported lines
      Info(InfoDigraphs, 1,
           "Lines beginning with 'd', 'v', or 'x' are not supported,");
    else
      # type: unknown
      malformed_file();
    fi;
    next := IO_ReadLine(file);
  od;

  if not IsBound(vertices) then
    malformed_file();
  fi;

  if not nr_edges in [directed_edges, 2 * directed_edges, symmetric_edges] then
    Info(InfoDigraphs, 1,
         "An unexpected number of edges was found,");
  fi;

  IO_Close(file);

  digraph := Digraph(nbs);
  SetDigraphNrEdges(digraph, nr_edges);
  SetIsSymmetricDigraph(digraph, true);
  SetDigraphVertexLabels(digraph, vertex_labels);
  return digraph;
end);

InstallMethod(WriteDIMACSDigraph, "for a digraph", [IsString, IsDigraph],
function(name, digraph)
  local file, n, verts, nbs, nr_loops, m, labels, i, j;

  if not IsSymmetricDigraph(digraph) then
    ErrorNoReturn("Digraphs: WriteDIMACSDigraph: usage,\n",
                  "the digraph <digraph> must be symmetric,");
  fi;

  file := IO_CompressedFile(UserHomeExpand(name), "w");
  if file = fail then
    ErrorNoReturn("Digraphs: WriteDIMACSDigraph:\n",
                  "cannot open the file <name>,");
  fi;

  n := DigraphNrVertices(digraph);
  verts := DigraphVertices(digraph);
  nbs := OutNeighbours(digraph);

  nr_loops := 0;
  if not HasDigraphHasLoops(digraph) or DigraphHasLoops(digraph) then
    for i in verts do
      for j in nbs[i] do
        if i = j then
          nr_loops := nr_loops + 1;
        fi;
      od;
    od;
    SetDigraphHasLoops(digraph, not nr_loops = 0);
  fi;
  m := ((DigraphNrEdges(digraph) - nr_loops) / 2) + nr_loops;

  # Problem definition
  IO_WriteLine(file, Concatenation("p edge ", String(n), " ", String(m)));

  # Edges
  for i in verts do
    for j in nbs[i] do
      if i <= j then
        IO_WriteLine(file, Concatenation("e ", String(i), " ", String(j)));
      fi;
      # In the case that j < i, the edge will be written elsewhere in the file
    od;
  od;

  # Vertex labels
  if n > 0 then
    labels := DigraphVertexLabels(digraph);
    if not (IsHomogeneousList(labels) and IsInt(labels[1])) then
      Info(InfoDigraphs, 1,
           "Only integer vertex labels are supported by the DIMACS format.");
      Info(InfoDigraphs, 1,
           "The vertex labels of <digraph> will not be saved.");
    else
      for i in verts do
        IO_WriteLine(file,
                     Concatenation("n ", String(i), " ", String(labels[i])));
      od;
    fi;
  fi;

  IO_Close(file);
  return IO_OK;
end);

# one edge per line, one graph per file

InstallGlobalFunction(ReadPlainTextDigraph,
function(name, delimiter, offset, ignore)
  local file, lines, edges, nr, decoder, line;

  if IsChar(delimiter) then
    delimiter := [delimiter];
  fi;

  if (not IsString(name)) or (not IsString(delimiter)) or (not IsInt(offset))
      or (not (IsString(ignore) or IsChar(ignore))) then
    ErrorNoReturn("Digraphs: ReadPlainTextDigraph: usage,\n",
                  "ReadPlainTextDigraph(filename, delimiter, offset, ignore",
                  "),");
  fi;

  if IsChar(ignore) then
    ignore := [ignore];
  fi;

  file := IO_CompressedFile(UserHomeExpand(name), "r");

  if file = fail then
    ErrorNoReturn("Digraphs: ReadPlainTextDigraph:\n",
                  "cannot open file <name>,");
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

InstallMethod(DigraphFromDiSparse6String, "for a directed graph",
[IsString],
function(s)
  local list, n, start, blist, pos, num, bpos, k, range, source, len, v, i, x,
  finish, j;

  s := Chomp(s);

  # Check non-emptiness
  if Length(s) = 0 then
    ErrorNoReturn("Digraphs: DigraphFromDiSparse6String: usage,\n",
                  "the input string <s> should be non-empty,");
  fi;

  # Check for the special ':' character
  if s[1] <> '.' then
    ErrorNoReturn("Digraphs: DigraphFromDiSparse6String: usage,\n",
                  "the input string <s> is not in valid disparse6 format,");
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
      ErrorNoReturn("Digraphs: DigraphFromDiSparse6String: usage,\n",
                    "the input string <s> is not in valid disparse6 format,");
    fi;
    n := 0;
    for i in [0 .. 5] do
      n := n + 2 ^ (6 * i) * list[9 - i];
    od;
    start := 10;
  elif Length(list) > 4 then
      n := 0;
      for i in [0 .. 2] do
        n := n + 2 ^ (6 * i) * list[5 - i];
      od;
      start := 6;
  else
    ErrorNoReturn("Digraphs: DigraphFromDiSparse6String: usage,\n",
                  "the input string <s> is not in valid disparse6 format,");
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
    for j in [1 .. k] do
      if blist[i + j] then
        x := x + 2 ^ (k - j);
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
    for j in [1 .. k] do
      if blist[i + j] then
        x := x + 2 ^ (k - j);
      fi;
    od;
    if x >= n then
      break;
    elif x > v then
      v := x;
    else
      range[len] := v;
      source[len] := x;
      len := len + 1;
    fi;
    i := i + k + 1;
  od;
  # BAD!! JDM
  range := range + 1;
  source := source + 1;

  return Digraph(rec(nrvertices := n, range := range, source := source));
end);

InstallMethod(DigraphFromPlainTextString, "for a string",
[IsString],
function(string)
  local decoder;
  decoder := DigraphPlainTextLineDecoder("  ", " ", 1);
  return decoder(Chomp(string));
end);

################################################################################
# 4. Encoders
################################################################################

InstallGlobalFunction(DigraphPlainTextLineEncoder,
function(delimiter1, delimiter2, offset)
  return function(digraph)
    local str, i, edges;
    edges := DigraphEdges(digraph);

    if Length(edges) = 0 then
      return "";
    fi;

    str := Concatenation(String(edges[1][1] + offset), delimiter2,
                         String(edges[1][2] + offset));

    for i in [2 .. Length(edges)] do
      Append(str, Concatenation(delimiter1, String(edges[i][1] + offset),
                                delimiter2, String(edges[i][2] + offset)));
    od;
    return str;
  end;
end);

InstallGlobalFunction(WritePlainTextDigraph,
function(name, digraph, delimiter, offset)
  local file, edge;

  if IsChar(delimiter) then
    delimiter := [delimiter];
  fi;

  if (not IsString(name)) or (not IsString(delimiter))
      or (not IsInt(offset)) then
    ErrorNoReturn("Digraphs: WritePlainTextDigraph: usage,\n",
                  "WritePlainTextDigraph(filename, digraph, delimiter, ",
                  "offset),");
  fi;

  file := IO_CompressedFile(UserHomeExpand(name), "w");

  if file = fail then
    ErrorNoReturn("Digraphs: WritePlainTextDigraph:\n",
                  "cannot open file ", name, ",");
  fi;

  for edge in DigraphEdges(digraph) do
    IO_WriteLine(file, Concatenation(String(edge[1] + offset),
                                     delimiter,
                                     String(edge[2] + offset)));
  od;
  IO_Close(file);
end);

InstallMethod(Graph6String, "for a digraph",
[IsDigraph],
function(graph)
  local list, adj, n, lenlist, tablen, blist, i, j, pos, block;
  if (IsMultiDigraph(graph)
      or not IsSymmetricDigraph(graph)
      or DigraphHasLoops(graph)) then
    ErrorNoReturn("Digraphs: Graph6String: usage,\n",
                  "<graph> must be symmetric and have no loops or multiple ",
                  "edges,");
  fi;

  list := [];
  adj := OutNeighbours(graph);
  n := Length(DigraphVertices(graph));

  # First write the number of vertices
  lenlist := DIGRAPHS_Graph6Length(n);
  if lenlist = fail then
    ErrorNoReturn("Digraphs: Graph6String: usage,\n",
                  "the argument <graph> must have between 0 and 68719476736 ",
                  "vertices,");
  fi;
  Append(list, lenlist);

  # Find adjacencies (non-directed)
  tablen := n * (n - 1) / 2;
  blist := BlistList([1 .. tablen + 6], []);
  for i in DigraphVertices(graph) do
    for j in adj[i] do
      # Loops not allowed
      if j > i then
        blist[i + (j - 2) * (j - 1) / 2] := true;
      elif i > j then
        blist[j + (i - 2) * (i - 1) / 2] := true;
      fi;
    od;
  od;

  # Read these into list, 6 bits at a time
  pos := 0;
  while pos < tablen do
    block := 0;
    for i in [1 .. 6] do
      if blist[pos + i] then
        block := block + 2 ^ (6 - i);
      fi;
    od;
    Add(list, block);
    pos := pos + 6;
  od;

  # Create string to return
  return List(list, i -> CharInt(i + 63));
end);

InstallMethod(Digraph6String, "for a digraph",
[IsDigraph],
function(digraph)
  local list, adj, n, lenlist, tablen, blist, i, j, pos, block;
  list := [];
  adj := OutNeighbours(digraph);
  n := Length(DigraphVertices(digraph));

  # First write the special character '+'
  Add(list, -20);

  # Now write the number of vertices
  lenlist := DIGRAPHS_Graph6Length(n);
  if lenlist = fail then
    ErrorNoReturn("Digraphs: Digraph6String: usage,\n",
                  "the argument <digraph> must have between 0 and 68719476736 ",
                  "vertices,");
  fi;
  Append(list, lenlist);

  # Find adjacencies (non-directed)
  tablen := n ^ 2;
  blist := BlistList([1 .. tablen + 6], []);
  for i in DigraphVertices(digraph) do
    for j in adj[i] do
      blist[i + n * (j - 1)] := true;
    od;
  od;

  # Read these into list, 6 bits at a time
  pos := 0;
  while pos < tablen do
    block := 0;
    for i in [1 .. 6] do
      if blist[pos + i] then
        block := block + 2 ^ (6 - i);
      fi;
    od;
    Add(list, block);
    pos := pos + 6;
  od;

  # Create string to return
  return List(list, i -> CharInt(i + 63));
end);

InstallMethod(Sparse6String, "for a digraph",
[IsDigraph],
function(graph)
  local list, n, lenlist, adj, nredges, k, blist, v, nextbit, AddBinary, i, j,
        bitstopad, pos, block;
  if not IsSymmetricDigraph(graph) then
    ErrorNoReturn("Digraphs: Sparse6String: usage,\n",
                  "the argument <graph> must be a symmetric digraph,");
  fi;

  list := [];
  n := Length(DigraphVertices(graph));

  # First write the special character ':'
  Add(list, -5);

  # Now write the number of vertices
  lenlist := DIGRAPHS_Graph6Length(n);
  if lenlist = fail then
    ErrorNoReturn("Digraphs: Sparse6String: usage,\n",
                  "the argument <graph> must have between 0 and 68719476736 ",
                  "vertices,");
  fi;
  Append(list, lenlist);

  # Get the out-neighbours - half these edges will be discarded
  adj := OutNeighbours(graph);
  nredges := DigraphNrEdges(graph);

  # k is the number of bits in a vertex label
  if n > 1 then
    k := Log2Int(n - 1) + 1;
  else
    k := 1;
  fi;

  # Add the edges one by one
  blist := BlistList([1 .. nredges * (k + 1) / 2], []);
  v := 0;
  nextbit := 1;
  AddBinary := function(blist, i)
    local b;
    for b in [1 .. k] do
      blist[nextbit] := Int((i mod (2 ^ (k - b + 1))) / (2 ^ (k - b))) = 1;
      nextbit := nextbit + 1;
    od;
  end;
  for i in [1 .. Length(adj)] do
    for j in adj[i] do
      if i < j then
        continue;
      elif i = v + 1 then
        blist[nextbit] := false;
        nextbit := nextbit + 1;
      elif i = v + 2 then
        blist[nextbit] := true;
        nextbit := nextbit + 1;
        v := v + 1;
      elif i > v + 2 then
        blist[nextbit] := true;
        nextbit := nextbit + 1;
        AddBinary(blist, i - 1);
        v := i - 1;
        blist[nextbit] := false;
        nextbit := nextbit + 1;
      fi;
      AddBinary(blist, j - 1);
    od;
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
  for i in [1 .. bitstopad] do
    Add(blist, true);
  od;

  # Read blist into list, 6 bits at a time
  pos := 0;
  while pos < Length(blist) do
    block := 0;
    for i in [1 .. 6] do
      if blist[pos + i] then
        block := block + 2 ^ (6 - i);
      fi;
    od;
    Add(list, block);
    pos := pos + 6;
  od;

  # Create string to return
  return List(list, i -> CharInt(i + 63));
end);

InstallMethod(DiSparse6String, "for a digraph",
[IsDigraph],
function(graph)
  local list, n, lenlist, adj, source_i, range_i, source_d, range_d, len1,
  len2, sort_d, perm, sort_i, k, blist, v, nextbit, AddBinary, bitstopad,
  pos, block, i, j;

  list := [];
  n := Length(DigraphVertices(graph));

  # First write the special character '.'
  list[1] := -17;

  # Now write the number of vertices
  lenlist := DIGRAPHS_Graph6Length(n);
  if lenlist = fail then
    ErrorNoReturn("Digraphs: DiSparse6String: usage,\n",
                  "<graph> must have between 0 and 68719476736 vertices,");
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
        source_i[len1] := i - 1;
        range_i[len1] := j - 1;
        len1 := len1 + 1;
      else
        source_d[len2] := i - 1;
        range_d[len2] := j - 1;
        len2 := len2 + 1;
      fi;
    od;
  od;

  # Sort decreasing edges according to source and then range
  sort_d := function(i, j)
    if source_d[i] < source_d[j]
        or (source_d[i] = source_d[j] and range_d[i] <= range_d[j]) then
      return true;
    else
      return false;
     fi;
  end;

  perm := Sortex([1 .. Length(source_d)], sort_d);
  source_d := Permuted(source_d, perm);
  range_d := Permuted(range_d, perm);

  # Sort increasing edges according to range and then source
  sort_i := function(i, j)
    if range_i[i] < range_i[j]
        or (range_i[i] = range_i[j] and source_i[i] <= source_i[j]) then
      return true;
    else
      return false;
     fi;
  end;

  perm := Sortex([1 .. Length(range_i)], sort_i);
  source_i := Permuted(source_i, perm);
  range_i := Permuted(range_i, perm);

  # k is the number of bits in a vertex label we also want to be able to
  # encode n as a separation symbol between increasing and decreasing edges
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
    for b in [1 .. k] do
      blist[nextbit] := Int((i mod (2 ^ (k - b + 1))) / (2 ^ (k - b))) = 1;
      nextbit := nextbit + 1;
    od;
  end;
  for i in [1 .. Length(source_d)] do
    if source_d[i] = v then
      blist[nextbit] := false;
      nextbit := nextbit + 1;
    elif source_d[i] = v + 1 then
      blist[nextbit] := true;
      nextbit := nextbit + 1;
      v := v + 1;
    elif source_d[i] > v + 1 then  # is this check necessary
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
  for i in [1 .. Length(range_i)] do
    if range_i[i] = v then
      blist[nextbit] := false;
      nextbit := nextbit + 1;
    elif range_i[i] = v + 1 then
      blist[nextbit] := true;
      nextbit := nextbit + 1;
      v := v + 1;
    elif range_i[i] > v + 1 then  # is this check necessary
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
  bitstopad := 5 - ((nextbit - 2) mod 6);
  for i in [1 .. bitstopad] do
    Add(blist, true);
  od;

  # Read blist into list, 6 bits at a time
  pos := 0;
  while pos < Length(blist) do
    block := 0;
    for i in [1 .. 6] do
      if blist[pos + i] then
        block := block + 2 ^ (6 - i);
      fi;
    od;
    Add(list, block);
    pos := pos + 6;
  od;

  # Create string to return
  return List(list, i -> CharInt(i + 63));
end);

InstallMethod(PlainTextString, "for a digraph",
[IsDigraph],
function(digraph)
  local encoder;
  encoder := DigraphPlainTextLineEncoder("  ", " ", -1);
  return encoder(digraph);
end);
