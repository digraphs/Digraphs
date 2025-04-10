#############################################################################
##
##  io.gi
##  Copyright (C) 2014-19                                James D. Mitchell
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
  elif Length(substring) = 1 then
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
function(file, D)
  local g, out;
  g := DigraphGroup(D);
  if IsTrivial(g) then
    TryNextMethod();
  elif IO_Write(file, "DIGG") = fail then
    return IO_Error;
  fi;
  out := [GeneratorsOfGroup(g),
          RepresentativeOutNeighbours(D),
          DigraphSchreierVector(D)];
  return IO_Pickle(file, out);
end);

IO_Unpicklers.DIGG := function(file)
  local list, gens, rep_out, sch, out, trace, word, D, i, w;

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

  D := ConvertToImmutableDigraphNC(out);
  SetDigraphGroup(D, Group(gens));
  SetDigraphSchreierVector(D, sch);
  SetRepresentativeOutNeighbours(D, rep_out);
  return D;
end;

InstallMethod(IO_Pickle, "for a digraph",
[IsFile, IsDigraph],
function(file, D)
  if IO_Write(file, "DIGT") = fail then
    return IO_Error;
  fi;
  return IO_Pickle(file, OutNeighbours(D));
end);

IO_Unpicklers.DIGT := function(file)
  local out;
  out := IO_Unpickle(file);
  if out = IO_Error then
    return IO_Error;
  fi;
  return ConvertToImmutableDigraphNC(out);
end;

################################################################################
# 2. ReadDigraphs and WriteDigraphs
################################################################################

InstallGlobalFunction(IteratorFromDigraphFile,
function(arg...)
  local filename, decoder, file, record;

  if Length(arg) = 1 then
    filename := arg[1];
    decoder  := fail;
  elif Length(arg) = 2 then
    filename := arg[1];
    decoder  := arg[2];
  else
    ErrorNoReturn("there must be 1 or 2 arguments,");
  fi;

  if not IsString(filename) then
    ErrorNoReturn("the 1st argument must be a string,");
  elif decoder <> fail and not IsFunction(decoder) then
    ErrorNoReturn("the 2nd argument must be a function or fail,");
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

  # TODO store filename, decoder in iter?
  record.ShallowCopy := function(_)
    local file;
    file := DigraphFile(UserHomeExpand(filename), decoder, "r");
    return rec(file := file, current := file!.coder(file));
  end;

  return IteratorByFunctions(record);
end);

BindGlobal("WholeFileDecoders", HashSet());
AddSet(WholeFileDecoders, "DigraphFromDreadnautString");
AddSet(WholeFileDecoders, "DigraphFromDIMACSString");

BindGlobal("WholeFileEncoders", HashSet());
AddSet(WholeFileEncoders, "DreadnautString");
AddSet(WholeFileEncoders, "DIMACSString");

InstallGlobalFunction(IsWholeFileDecoder,
  decoder -> NameFunction(decoder) in WholeFileDecoders);

InstallGlobalFunction(IsWholeFileEncoder,
  encoder -> NameFunction(encoder) in WholeFileEncoders);

# these functions wrap the various line encoders/decoders in this file so that
# they behave like IO_Pickle.

BindGlobal("DIGRAPHS_EncoderWrapper",
function(encoder)
  if encoder = IO_Pickle or NameFunction(encoder) in WholeFileEncoders then
    return encoder;
  elif NameFunction(encoder) = "WriteDIMACSDigraph" then
    return DIMACSString;  # edge case (legacy function)
  fi;
  return {file, D} -> IO_WriteLine(file, encoder(D));
end);

BindGlobal("DIGRAPHS_DecoderWrapper",
function(decoder)
  if decoder = IO_Unpickle or NameFunction(decoder) in WholeFileDecoders then
    return decoder;
  elif NameFunction(decoder) = "ReadDIMACSDigraph" then
    return DigraphFromDIMACSString;  # edge case (legacy function)
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
    ErrorNoReturn("the argument <filename> must be a string,");
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
  elif extension = "dre" then
    return DigraphFromDreadnautString;
  elif extension = "dimacs" then
    return DigraphFromDIMACSString;
  fi;

  return fail;
end);

# if we are choosing the decoder, then the file extension is used.

BindGlobal("DIGRAPHS_ChooseFileEncoder",
function(filename)
  local splitname, extension;

  if not IsString(filename) then
    ErrorNoReturn("the argument <filename> must be a string,");
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
  elif extension = "dre" then
    return DreadnautString;
  elif extension = "dimacs" then
    return DIMACSString;
  fi;
  return fail;
end);

InstallGlobalFunction(DigraphFile,
function(arg...)
  local coder, mode, name, file;

  # defaults
  coder       := fail;
  mode        := "r";
  if Length(arg) = 1 then
    name  := arg[1];
  elif Length(arg) = 2 then
    name  := arg[1];
    if IsString(arg[2]) then
      mode := arg[2];
    else
      coder := arg[2];
    fi;
  elif Length(arg) = 3 then
    name  := arg[1];
    coder := arg[2];
    mode  := arg[3];
  else
    ErrorNoReturn("there must be 1, 2, or 3 arguments,");
  fi;

  # TODO check that the mode and the coder are compatible

  if not IsString(name) then
    ErrorNoReturn("the 1st argument <name> must be a string,");
  elif not (IsFunction(coder) or coder = fail) then
    ErrorNoReturn("the 2nd argument <coder> must be a function or fail,");
  elif not mode in ["a", "w", "r"] then
    ErrorNoReturn("the 3rd argument <mode> must be one of \"a\", ",
                  "\"w\", or \"r\"");
  fi;

  if coder = fail then  # <coder> not specified by the user
    if mode = "r" then
      coder := DIGRAPHS_ChooseFileDecoder(name);
    else
      coder := DIGRAPHS_ChooseFileEncoder(name);
    fi;
  fi;

  if coder = fail then
    ErrorNoReturn("cannot determine the file format,");
  elif mode = "r" then
    coder := DIGRAPHS_DecoderWrapper(coder);
  else
    coder := DIGRAPHS_EncoderWrapper(coder);
  fi;

  file := IO_CompressedFile(UserHomeExpand(name), mode);

  if file = fail then
    ErrorNoReturn("cannot open the file given as the 1st argument <name>,");
  fi;
  file!.coder := coder;
  file!.mode := mode;
  return file;
end);

InstallGlobalFunction(ReadDigraphs,
function(arg...)
  local nr, decoder, name, file, i, next, out, line;

  # defaults
  nr      := infinity;
  decoder := fail;

  if Length(arg) = 1 then
    name := arg[1];
  elif Length(arg) = 2 then
    name    := arg[1];
    if IsInt(arg[2]) then
      nr      := arg[2];
    else
      decoder := arg[2];
    fi;
  elif Length(arg) = 3 then
    name    := arg[1];
    decoder := arg[2];
    nr      := arg[3];
  else
    ErrorNoReturn("there must be 1, 2, or 3 arguments,");
  fi;

  if not (IsString(name) or IsFile(name)) then
    ErrorNoReturn("the 1st argument <filename> must be a string or IO ",
                  "file object,");
  elif not (IsFunction(decoder) or decoder = fail) then
    ErrorNoReturn("the argument <decoder> must be a function or fail,");
  elif not (IsPosInt(nr) or IsInfinity(nr)) then
    ErrorNoReturn("the argument <nr> must be a positive integer or ",
                  "infinity");
  fi;

  if IsString(name) then
    file := DigraphFile(name, decoder, "r");
  else
    file := name;
    if file!.closed then
      ErrorNoReturn("the 1st argument <filename> is a closed file,");
    elif file!.rbufsize = false then
      ErrorNoReturn("the mode of the 1st argument <filename> must be \"r\",");
    fi;
  fi;

  decoder := file!.coder;

  if nr < infinity then
    if NameFunction(decoder) in WholeFileDecoders then
      Info(InfoWarning, 1, NameFunction(decoder), " is a whole file decoder ",
           " and so only one digraph should be specified. If possible, the ",
           "final digraph will be returned, or else an error.");
    else
      i := 0;
      next := fail;
      while i < nr - 1 and next <> IO_Nothing do
        i := i + 1;
        next := IO_ReadLine(file);
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
  fi;

  out := [];
  if NameFunction(decoder) in WholeFileDecoders then
    line := IO_ReadUntilEOF(file);
    if IsString(arg[1]) then
      IO_Close(file);
    fi;
    Add(out, decoder(line));
    return out;
  else
    next := decoder(file);
  fi;

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
function(arg...)
  local name, digraphs, encoder, mode, splitname, compext, g6sum, s6sum, v, e,
  dg6sum, ds6sum, file, i, D, oldOnBreak, CloseAndCleanup, OnBreakWithCleanup;

  # defaults
  encoder := fail;
  mode    := "a";
  if Length(arg) = 2 then
    name     := arg[1];
    digraphs := arg[2];
  elif IsFile(arg[1]) then
    ErrorNoReturn("the 1st argument <filename> is a file, and so there must ",
                  "only be 2 arguments,");
  elif Length(arg) = 3 then
    name     := arg[1];
    digraphs := arg[2];
    if IsString(arg[3]) then
      mode := arg[3];
    else
      encoder := arg[3];
    fi;
  elif Length(arg) = 4 then
    name     := arg[1];
    digraphs := arg[2];
    encoder  := arg[3];
    mode     := arg[4];
  else
    ErrorNoReturn("there must be 2, 3, or 4 arguments,");
  fi;

  if not IsList(digraphs) then
    digraphs := [digraphs];
  fi;

  if not (IsString(name) or IsFile(name)) then
    ErrorNoReturn("the 1st argument <filename> must be a string or a file,");
  elif not ForAll(digraphs, IsDigraph) then
    ErrorNoReturn("the 2nd argument <digraphs> must be a digraph or list of ",
                  "digraphs,");
  elif not (IsFunction(encoder) or encoder = fail) then
    ErrorNoReturn("the argument <encoder> must be a function or fail,");
  elif not mode in ["a", "w"] then
    ErrorNoReturn("the argument <mode> must be \"a\" or \"w\",");
  elif IsString(name) and not IsExistingFile(name) then
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
          for D in digraphs do
            v := DigraphNrVertices(D);
            e := DigraphNrEdges(D);
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
          for D in digraphs do
            v := DigraphNrVertices(D);
            e := DigraphNrEdges(D);
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
    if NameFunction(file!.coder) in WholeFileEncoders and file!.mode <> "w" then
      if IsString(arg[1]) then
        IO_Close(file);
      fi;
      ErrorNoReturn(NameFunction(file!.coder), " is a whole file ",
                    "encoder and so the argument <mode> must be \"w\".");
    fi;
  else
    file := name;
    if file!.closed then
      ErrorNoReturn("the 1st argument <filename> is closed,");
    elif file!.wbufsize = false then
      ErrorNoReturn("the mode of the 1st argument <filename> must be ",
                    "\"w\" or \"a\",");
    fi;
  fi;

  oldOnBreak := OnBreak;
  CloseAndCleanup := function()
    if IsString(arg[1]) then
      IO_Close(file);
    fi;
    OnBreak := oldOnBreak;
  end;

  OnBreakWithCleanup := function()
    CloseAndCleanup();
    OnBreak();
  end;
  OnBreak := OnBreakWithCleanup;

  encoder := file!.coder;
  if NameFunction(encoder) in WholeFileEncoders then
    if Length(digraphs) > 1 then
      Info(InfoWarning, 1, "the encoder ", NameFunction(encoder),
          " is a whole file encoder, and so only one digraph should be ",
          "specified. Only the last digraph will be encoded.");
    fi;
    IO_Write(file, encoder(digraphs[Length(digraphs)]));
  else
    for i in [1 .. Length(digraphs)] do
      encoder(file, digraphs[i]);
    od;
  fi;

  CloseAndCleanup();
  return IO_OK;
end);

################################################################################
# 3. Decoders
################################################################################

InstallMethod(DigraphFromGraph6StringCons, "for IsMutableDigraph and a string",
[IsMutableDigraph, IsString],
function(filt, s)
  local FindCoord, list, n, start, maxedges, out, pos, nredges, i, bpos, edge,
  j;

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
    ErrorNoReturn("the 2nd argument <s> must be a non-empty string,");
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
    ErrorNoReturn("the 2nd argument <s> is not a valid graph6 string,");
  fi;

  maxedges := n * (n - 1) / 2;
  if list <> [0] and list <> [1] and
      not (Int((maxedges - 1) / 6) + start = Length(list) and
           list[Length(list)] mod 2 ^ ((0 - maxedges) mod 6) = 0) then
    ErrorNoReturn("the 2nd argument <s> is not a valid graph6 string,");
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
        out[edge[1]][Length(out[edge[1]]) + 1] := edge[2];
        out[edge[2]][Length(out[edge[2]]) + 1] := edge[1];
        nredges := nredges + 1;
        i := (i - 1) / 2;
      fi;
      bpos := bpos + 1;
    od;
    pos := pos + 6;
  od;
  return DigraphNC(filt, out);
end);

InstallMethod(DigraphFromGraph6StringCons,
"for IsImmutableDigraph and a string",
[IsImmutableDigraph, IsString],
function(_, s)
  local D;
  D := MakeImmutable(DigraphFromGraph6StringCons(IsMutableDigraph, s));
  SetIsSymmetricDigraph(D, true);
  SetIsMultiDigraph(D, false);
  SetDigraphHasLoops(D, false);
  return D;
end);

InstallMethod(DigraphFromGraph6String, "for a function and a string",
[IsFunction, IsString],
DigraphFromGraph6StringCons);

InstallMethod(DigraphFromGraph6String, "for a string", [IsString],
s -> DigraphFromGraph6String(IsImmutableDigraph, s));

InstallMethod(DigraphFromDigraph6StringCons,
"for IsMutableDigraph and a string",
[IsMutableDigraph, IsString],
function(filt, s)
  local legacy, list, n, start, i, range, source, pos, len, j, bpos, tabpos;
  # NOTE: this package originally used a version of digraph6 that reads down
  # the columns of an adjacency matrix, and appends a '+' to the start.  This
  # has been replaced by the Nauty standard, which reads across the rows of the
  # matrix, and appends a '&' to the start.  For backwards compatibility, this
  # now accepts both formats, sending an info warning if the old format is used.

  s := Chomp(s);
  # Check non-emptiness
  if Length(s) = 0 then
    ErrorNoReturn("the 2nd argument <s> must be a non-empty string,");
  fi;

  # Check for the special '&' character (or the deprecated '+')
  if s[1] = '&' then
    legacy := false;
  elif s[1] = '+' then
    legacy := true;
    Info(InfoDigraphs, 1, "Digraph6 strings beginning with '+' use an old");
    Info(InfoDigraphs, 1, "specification of the Digraph6 format that is");
    Info(InfoDigraphs, 1, "incompatible with the present standard.  They can");
    Info(InfoDigraphs, 1, "still be read by the Digraphs package, but are");
    Info(InfoDigraphs, 1, "unlikely to be recognised by other programs.");
    Info(InfoDigraphs, 1, "Please consider re-encoding with the new format.");
  else
    ErrorNoReturn("the 2nd argument <s> is not a valid digraph6 string,");
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
    ErrorNoReturn("the 2nd argument <s> is not a valid digraph6 string,");
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
        range[len] := (tabpos - 1) mod n + 1;
        source[len] := (tabpos - range[len]) / n + 1;
        len := len + 1;
        i := (i - 1) / 2;
      fi;
      bpos := bpos + 1;
    od;
    pos := pos + 6;
  od;

  if legacy then  # source and range are reversed
    return DigraphNC(filt,
                 rec(DigraphNrVertices := n,
                     DigraphSource     := range,
                     DigraphRange      := source));
  fi;
  return DigraphNC(filt,
               rec(DigraphNrVertices := n,
                   DigraphRange      := range,
                   DigraphSource     := source));
end);

InstallMethod(DigraphFromDigraph6StringCons,
"for IsImmutableDigraph and a string",
[IsImmutableDigraph, IsString],
{filt, s} -> MakeImmutable(DigraphFromDigraph6StringCons(IsMutableDigraph, s)));

InstallMethod(DigraphFromDigraph6String, "for a function and a string",
[IsFunction, IsString],
DigraphFromDigraph6StringCons);

InstallMethod(DigraphFromDigraph6String, "for a string",
[IsString], s -> DigraphFromDigraph6String(IsImmutableDigraph, s));

InstallMethod(DigraphFromSparse6StringCons, "for IsMutableDigraph and a string",
[IsMutableDigraph, IsString],
function(filt, s)
  local list, n, start, blist, pos, num, bpos, k, range, source, len, v, i,
  finish, x, j;

  s := Chomp(s);
  # Check non-emptiness
  if Length(s) = 0 then
    ErrorNoReturn("the 2nd argument <s> must be a non-empty string,");
  fi;

  # Check for the special ':' character
  if s[1] <> ':' then
    ErrorNoReturn("the 2nd argument <s> is not a valid sparse6 string,");
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
      ErrorNoReturn("the 2nd argument <s> is not a valid sparse6 string,");
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
    ErrorNoReturn("the 2nd argument <s> is not a valid sparse6 string,");
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

  range := range + 1;
  source := source + 1;
  return DigraphNC(filt, (rec(DigraphNrVertices := n,
                                      DigraphRange := range,
                                      DigraphSource := source)));
end);

InstallMethod(DigraphFromSparse6StringCons,
"for IsImmutableDigraph and a string",
[IsImmutableDigraph, IsString],
function(_, s)
  local D;
  D := MakeImmutable(DigraphFromSparse6String(IsMutableDigraph, s));
  SetIsSymmetricDigraph(D, true);
  return D;
end);

InstallMethod(DigraphFromSparse6String, "for a function and a string",
[IsFunction, IsString], DigraphFromSparse6StringCons);

InstallMethod(DigraphFromSparse6String, "for a string",
[IsString],
s -> DigraphFromSparse6String(IsImmutableDigraph, s));

InstallMethod(DigraphFromDiSparse6StringCons,
"for IsMutableDigraph and a string",
[IsMutableDigraph, IsString],
function(func, s)
  local list, n, start, blist, pos, num, bpos, k, range, source, len, v, i, x,
  finish, j;

  s := Chomp(s);

  # Check non-emptiness
  if Length(s) = 0 then
    ErrorNoReturn("the 2nd argument <s> must be a non-empty string,");
  fi;

  # Check for the special ':' character
  if s[1] <> '.' then
    ErrorNoReturn("the 2nd argument <s> is not a valid disparse6 string,");
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
      ErrorNoReturn("the 2nd argument <s> is not a valid disparse6 string,");
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
    ErrorNoReturn("the 2nd argument <s> is not a valid disparse6 string,");
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
  range := range + 1;
  source := source + 1;
  return DigraphNC(func, (rec(DigraphNrVertices := n,
                              DigraphRange      := range,
                              DigraphSource     := source)));
end);

InstallMethod(DigraphFromDiSparse6StringCons,
"for IsImmutableDigraph and a string",
[IsImmutableDigraph, IsString],
{filt, s} -> MakeImmutable(DigraphFromDiSparse6String(IsMutableDigraph, s)));

InstallMethod(DigraphFromDiSparse6String,
"for a function and a string",
[IsFunction, IsString],
DigraphFromDiSparse6StringCons);

InstallMethod(DigraphFromDiSparse6String,
"for a string",
[IsString],
s -> DigraphFromDiSparse6String(IsImmutableDigraph, s));

# one graph per line
BindGlobal("DIGRAPHS_PlainTextLineDecoder",
function(func, delimiter1, delimiter2, offset)
  local retval;
  retval := function(s)
    local edges, x;
    s := DIGRAPHS_SplitStringBySubstring(Chomp(s), delimiter1);
    Apply(s, x -> DIGRAPHS_SplitStringBySubstring(x, delimiter2));
    edges := EmptyPlist(Length(s));
    for x in s do
      Apply(x, Int);
      x := x + offset;
      Add(edges, x);
    od;
    return func(edges);
  end;
  return retval;
end);

InstallMethod(DigraphFromPlainTextStringCons,
"for IsMutableDigraph and a string", [IsMutableDigraph, IsString],
function(filt, s)
  local f;
  f := x -> DigraphByEdges(filt, x);
  return DIGRAPHS_PlainTextLineDecoder(f, "  ", " ", 1)(Chomp(s));
end);

InstallMethod(DigraphFromPlainTextStringCons,
"for IsImmutableDigraph and a string", [IsImmutableDigraph, IsString],
{_, s} -> MakeImmutable(DigraphFromPlainTextStringCons(IsMutableDigraph, s)));

InstallMethod(DigraphFromPlainTextString, "for a function and a string",
[IsFunction, IsString], DigraphFromPlainTextStringCons);

InstallMethod(DigraphFromPlainTextString, "for a string",
[IsString], s -> DigraphFromPlainTextString(IsImmutableDigraph, s));

# DIMACS format: for symmetric digraphs, one per file, can have loops and
# multiple edges.,

InstallMethod(DigraphFromDIMACSString, "for a string", [IsString],
function(s)
  local parts, x, int_from_string, next, split, first_char,
  nr_vertices, vertices, vertex_labels, nr_edges, directed_edges,
  symmetric_edges, nbs, vertex, label, i, j, D;

  if s = "" then
    ErrorNoReturn("the argument <s> must be a non-empty string");
  fi;

  # Helper function to read a string into a non-negative integer
  int_from_string := function(string)
    local int;
    int := Int(string);
    if int = fail or int < 0 then
      ErrorNoReturn("the format of the string <s> cannot be determined");
    fi;
    return int;
  end;

  parts := SplitString(s, "\n");
  x := 1;
  next := parts[x];

  while not IsEmpty(next) do
    NormalizeWhitespace(next);

    # the line is entirely whitespace or a comment
    if IsEmpty(next) or next[1] = 'c' then
      x := x + 1;
      if x > Length(parts) then
        next := "";
      else
        next := parts[x];
      fi;
      continue;
    fi;

    split := SplitString(next, " ");

    # the line doesn't have a `type'
    if Length(split[1]) <> 1 then
      ErrorNoReturn("the format of the string <s> cannot be determined");
    fi;

    first_char := next[1];

    # digraph definition line
    if first_char = 'p' then
      if IsBound(vertices) or Length(split) <> 4 or split[2] <> "edge" then
        ErrorNoReturn("the format of the string <s>",
                             " cannot be determined");
      fi;
      nr_vertices     := int_from_string(split[3]);
      vertices        := [1 .. nr_vertices];
      vertex_labels   := vertices * 0 + 1;
      nr_edges        := int_from_string(split[4]);
      directed_edges  := 0;
      symmetric_edges := 0;
      nbs := List(vertices, x -> []);
      x := x + 1;
      if x > Length(parts) then
        next := "";
      else
        next := parts[x];
      fi;
      continue;
    fi;

    if not IsBound(vertices) then
      # the problem definition line must precede all other types
      ErrorNoReturn("the format of the string <s> cannot be determined");
    elif first_char = 'n' then
      # type: vertex label
      if Length(split) <> 3 then
        ErrorNoReturn("the format of the string <s> cannot be determined");
      fi;
      vertex := int_from_string(split[2]);
      if not vertex in vertices then
        ErrorNoReturn("the format of the string <s> cannot be determined");
      fi;
      label := Int(split[3]);
      if label = fail then
        ErrorNoReturn("the format of the string <s> cannot be determined");
      fi;
      vertex_labels[vertex] := label;
    elif first_char = 'e' then
      # type: edge
      if Length(split) <> 3 then
        ErrorNoReturn("the format of the string <s> cannot be determined");
      fi;
      i := int_from_string(split[2]);
      j := int_from_string(split[3]);
      if not (i in vertices and j in vertices) then
        ErrorNoReturn("the format of the string <s> cannot be determined");
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
      ErrorNoReturn("the format of the string <s> cannot be determined");
    fi;
    x := x + 1;
    if x > Length(parts) then
      next := "";
    else
      next := parts[x];
    fi;
  od;

  if not IsBound(vertices) then
    ErrorNoReturn("the format of the string <s> cannot be determined");
  fi;

  if not nr_edges in [directed_edges, 2 * directed_edges, symmetric_edges] then
    Info(InfoDigraphs, 1, "An unexpected number of edges was found,");
  fi;

  D := ConvertToImmutableDigraphNC(nbs);
  if IsImmutableDigraph(D) then
    SetDigraphVertexLabels(D, vertex_labels);
  fi;
  return D;
end);

InstallMethod(ReadDIMACSDigraph, "for a string", [IsString],
s -> ReadDigraphs(s, DigraphFromDIMACSString)[1]);

BindGlobal("DIGRAPHS_TournamentLineDecoder",
function(func, s)
  local out, pos, n, i, j;
  pos := 0;
  s := Chomp(s);
  n := (Sqrt(8 * Length(s) + 1) + 1) / 2;
  out := List([1 .. n], x -> []);
  for i in [1 .. n - 1] do
    for j in [i + 1 .. n] do
      pos := pos + 1;
      if s[pos] = '1' then
        Add(out[i], j);
      else
        Add(out[j], i);
      fi;
    od;
  od;
  return func(out);
end);

InstallMethod(TournamentLineDecoder, "for a string", [IsString],
s -> DIGRAPHS_TournamentLineDecoder(ConvertToImmutableDigraphNC, s));

InstallMethod(DigraphPlainTextLineDecoder,
"for a string, string, and integer",
[IsString, IsString, IsInt],
function(delimiter1, delimiter2, offset)
  return DIGRAPHS_PlainTextLineDecoder(DigraphByEdges,
                                       delimiter1,
                                       delimiter2,
                                       offset);
end);

# one edge per line, one graph per file
BindGlobal("DIGRAPHS_ReadPlainTextDigraph",
function(func, name, delimiter, offset, ignore)
  local file, lines, edges, nr, decoder, line;

  file := IO_CompressedFile(UserHomeExpand(name), "r");
  if file = fail then
    ErrorNoReturn("cannot open the file given as the 2nd argument <name>,");
  fi;

  lines := IO_ReadLines(file);
  IO_Close(file);
  edges := EmptyPlist(Length(lines));
  nr := 0;

  decoder := function(string)
    string := DIGRAPHS_SplitStringBySubstring(Chomp(string), delimiter);
    Apply(string, Int);
    return string + offset;
  end;

  for line in lines do
    if Length(line) > 0 and not (line[1] in ignore) then
      nr := nr + 1;
      edges[nr] := decoder(Chomp(line));
    fi;
  od;

  return func(edges);
end);

InstallMethod(ReadPlainTextDigraph,
"for a string, string, integer, and string",
[IsString, IsString, IsInt, IsString],
function(name, delimiter, offset, ignore)
  return DIGRAPHS_ReadPlainTextDigraph(DigraphByEdges,
                                       name,
                                       delimiter,
                                       offset,
                                       ignore);
end);

BindGlobal("DIGRAPHS_AdjacencyMatUpperTriLineDecoder",
function(func, s)
  local out, pos, n, i, j;
  s := Chomp(s);
  pos := 0;
  n := (Sqrt(8 * Length(s) + 1) + 1) / 2;
  out := List([1 .. n], x -> []);
  for i in [1 .. n - 1] do
    for j in [i + 1 .. n] do
      pos := pos + 1;
      if s[pos] = '1' then
        Add(out[i], j);
      fi;
    od;
  od;
  return func(out);
end);

InstallMethod(AdjacencyMatrixUpperTriangleLineDecoder, "for a string",
[IsString],
s -> DIGRAPHS_AdjacencyMatUpperTriLineDecoder(ConvertToImmutableDigraphNC,
                                              s));

BindGlobal("DIGRAPHS_TCodeDecoder",
function(func, s)
  local out, i;

  s := SplitString(Chomp(s), " ");
  Apply(s, EvalString);

  if not ForAll(s, x -> IsInt(x) and x >= 0) then
    ErrorNoReturn("the 2nd argument <s> must be a string of ",
                  "space-separated non-negative integers,");
  elif not Length(s) >= 2 then
    ErrorNoReturn("the 2nd argument <s> must be a string of ",
                  "at least two integers,");
  elif not ForAll([3 .. Length(s)], i -> s[i] < s[1]) then
    ErrorNoReturn("the 2nd argument <s> must be a string consisting of ",
                  "integers in the range [0 .. ", s[1], "],");
  elif Length(s) < 2 * s[2] + 2 then
    ErrorNoReturn("the 2nd argument <s> must be a string of length ",
                  "at least ", 2 * s[2] + 2);
  fi;
  out := List([1 .. s[1]], x -> []);
  for i in [1 .. s[2]] do
    Add(out[s[2 * i + 1] + 1], s[2 * i + 2] + 1);
  od;

  return func(out);
end);

InstallMethod(TCodeDecoder, "for a string", [IsString],
s -> DIGRAPHS_TCodeDecoder(ConvertToImmutableDigraphNC, s));

InstallGlobalFunction(TCodeDecoderNC,
function(str)
  local out, i;
  str := SplitString(Chomp(str), " ");
  Apply(str, Int);
  out := List([1 .. str[1]], x -> []);
  for i in [1 .. str[2]] do
    Add(out[str[2 * i + 1] + 1], str[2 * i + 2] + 1);
  od;
  return ConvertToImmutableDigraphNC(out);
end);

# helper function for DigraphFromDreadnautString
# gets or ungets (ug = 1 or -1 respectively)
# the next character in the string and updates
# the line number if necessary
# returns the character or fail for getchar
# returns nothing for ungetchar
BindGlobal("DIGRAPHS_GetUngetChar",
function(r, D, ug)
  if ug = 1 then  # GetChar
    r.i := r.i + 1;
    if r.i > Length(D) then
      return fail;
    else
      if D[r.i] = '\n' then
        r.newline := r.newline + 1;
      fi;
      return D[r.i];
    fi;
  else  # ug = -1, UngetChar
    if r.i > Length(D) then
      r.i := r.i - 1;
      return;
    fi;
    if D[r.i] = '\n' then
      r.newline := r.newline - 1;
    fi;
    r.i := r.i - 1;
    return;
  fi;
end);

# helper function for DigraphFromDreadnautString
# (returns the first character not in s)
BindGlobal("DIGRAPHS_GETNWCL",
function(r, D, s)
  local char;
  char := DIGRAPHS_GetUngetChar(r, D, 1);
  while char <> fail and char in s do
    char := DIGRAPHS_GetUngetChar(r, D, 1);
  od;

  return char;
end);

#  helper function for DigraphFromDreadnautString
#  return the next full integer in the string
BindGlobal("DIGRAPHS_readinteger",
function(r, D)
  local char, res, minus;
  char := DIGRAPHS_GETNWCL(r, D, " \n\t\r");

  if not IsDigitChar(char) and char <> '-' and char <> '+' then
    DIGRAPHS_GetUngetChar(r, D, -1);
    return fail;
  fi;

  minus := char = '-';
  if char = '-' or char = '+' then
    res := 0;
  else
    res := Int([char]);
  fi;

  char := DIGRAPHS_GetUngetChar(r, D, 1);

  while IsDigitChar(char) do
    res := res * 10 + Int([char]);
    char := DIGRAPHS_GetUngetChar(r, D, 1);
  od;

  if char <> fail then
    DIGRAPHS_GetUngetChar(r, D, -1);
  fi;

  if minus then
    res := -res;
  fi;

  return res;
end);

# helper function for DigraphFromDreadnautString
# reads in and stores graph adjacency data
# returns nothing
BindGlobal("DIGRAPHS_readgraph",
function(r, D)
  local c, w, v, neg;

  v := 1;
  neg := false;
  c := ' ';

  if r.n = fail then
    ErrorNoReturn("Vertex number must be declared before `g' ",
                  "on line ", r.newline);
  else
    r.edgeList := List([1 .. r.n], x -> []);
  fi;

  while c <> fail do
    c := DIGRAPHS_GETNWCL(r, D, " ,\t");
    if IsDigitChar(c) then
      DIGRAPHS_GetUngetChar(r, D, -1);
      w := DIGRAPHS_readinteger(r, D);
      w := w - r.labelorg + 1;

      if neg then
        neg := false;

        if (w < 1) or (w > r.n) or (w = v and not r.digraph) then
          Info(InfoWarning, 1, StringFormatted(
               Concatenation("Ignoring illegal edge ({}, {}) ",
               "(vertices {}-indexed, on line {}) "),
               v + r.labelorg - 1, w + r.labelorg - 1,
               r.labelorg, r.newline));
        else
          RemoveSet(r.edgeList[v], w);
          if not r.digraph then
            RemoveSet(r.edgeList[w], v);
          fi;
        fi;
      else
        c := DIGRAPHS_GETNWCL(r, D, " ,\t");
        if c = ':' then
          if w < 1 or w > r.n then
            Info(InfoWarning, 1, StringFormatted(
                 Concatenation("Ignoring illegal vertex {} ",
                 "({}-indexed), on line {})"),
                 w + r.labelorg - 1, r.labelorg, r.newline));
          else
            v := w;
          fi;
        else
          DIGRAPHS_GetUngetChar(r, D, -1);
          if w < 1 or w > r.n or (w = v and not r.digraph) then
            Info(InfoWarning, 1, StringFormatted(
                 Concatenation("Ignoring illegal edge ({}, {}) ",
                 "(vertices {}-indexed, on line {}) "),
                 v + r.labelorg - 1, w + r.labelorg - 1,
                 r.labelorg, r.newline));
          else
            AddSet(r.edgeList[v], w);
            if not r.digraph then
              AddSet(r.edgeList[w], v);
            fi;
          fi;
        fi;
      fi;
    elif c = ';' then
      neg := false;
      v := v + 1;
      if v > r.n then
        return;
      fi;
    elif c in "?\n" then
      neg := false;
    elif c = '.' then
      return;
    elif c = '-' then
      neg := true;
    elif c = '!' then
      while c <> '\n' and c <> fail do
        c := DIGRAPHS_GetUngetChar(r, D, 1);
      od;
    else
      if c = fail then
        return;
      else
        ErrorNoReturn("Illegal character ", c, " on line ", r.newline);
      fi;
    fi;
  od;
end);

# helper function for DigraphFromDreadnautString
# returns the next full integer from the string,
# allowing for an optional '=' before the integer
BindGlobal("DIGRAPHS_GetInt",
function(r, D)
  local ch;

  ch := DIGRAPHS_GETNWCL(r, D, " \n\t\r");
  if ch <> '=' then
    DIGRAPHS_GetUngetChar(r, D, -1);
  fi;
  return DIGRAPHS_readinteger(r, D);
end);

# helper function for DigraphFromDreadnautString
# parses partitions and stores them as vertex labels
# returns nothing
BindGlobal("DIGRAPHS_ParsePartition",
function(r, minus, D)
  local c, x, tempNewline, v1, v2, part, partition;

  part := 1;
  if r.n = fail then
    ErrorNoReturn("Vertex number must be declared ",
                  "before partition on line ", r.newline);
  fi;
  partition := List([1 .. r.n], x -> 0);

  if minus then
    return;
  fi;

  c := DIGRAPHS_GETNWCL(r, D, " ,\t");
  if c = '=' then
    c := DIGRAPHS_GETNWCL(r, D, " ,\t");
  fi;

  if IsDigitChar(c) then
    DIGRAPHS_GetUngetChar(r, D, -1);
    v1 := DIGRAPHS_readinteger(r, D);
    if v1 - r.labelorg + 1 < 1 or v1 - r.labelorg + 1 > r.n then
      Info(InfoWarning, 1, "Ignoring illegal vertex in partition", v1,
           " on line ", r.newline);
    else
      partition[v1] := 1;
    fi;
    r.partition := partition;
    return;
  elif c <> '[' then
    ErrorNoReturn("Partitions should be specified",
                  " as either a single number (e.g. 'f=3')",
                  " a list of cells (e.g. 'f=[...]') or",
                  " using '-f'");
  else
    tempNewline := r.newline;
    while c <> fail and c <> ']' do
      c := DIGRAPHS_GETNWCL(r, D, " \n\t\r");
      if c = '|' then
        part := part + 1;
      elif c = ',' then
        continue;
      elif IsDigitChar(c) then
        DIGRAPHS_GetUngetChar(r, D, -1);
        v1 := DIGRAPHS_readinteger(r, D);
        if v1 - r.labelorg + 1 < 1 or v1 - r.labelorg + 1 > r.n then
          ErrorNoReturn("Vertex ", v1,
                        " out of range in partition specification (line ",
                        tempNewline, ")");
        fi;

        v2 := DIGRAPHS_GETNWCL(r, D, " \n\t\r");
        if v2 = ':' then
          v2 := DIGRAPHS_GETNWCL(r, D, " \n\t\r");
          if not IsDigitChar(v2) then
            ErrorNoReturn("Invalid range ", v1, " : ", v2,
                          " in partition specification (line ",
                          tempNewline, ")");
          fi;
          DIGRAPHS_GetUngetChar(r, D, -1);
          v2 := DIGRAPHS_readinteger(r, D);
          if v2 < r.labelorg or v2 > r.n - r.labelorg + 1 then
            ErrorNoReturn("Vertex ", v2,
                          " out of range in partition specification (line ",
                          tempNewline, ")");
          fi;
          for x in [v1 - r.labelorg + 1 .. v2 - r.labelorg + 1] do
            if partition[x] = 0 then
              partition[x] := part;
            else
              Info(InfoWarning, 1, "Vertex ", x + r.labelorg - 1,
                   " (", r.labelorg,
                   "-indexed is in multiple partitions (line ",
                   tempNewline, ")");
            fi;
          od;
          else
            DIGRAPHS_GetUngetChar(r, D, -1);
            if partition[v1 - r.labelorg + 1] = 0 then
              partition[v1 - r.labelorg + 1] := part;
            else
              Info(InfoWarning, 1, "Vertex ", v1,
                   " (", r.labelorg, "-indexed) ",
                   " is in multiple partitions (line ",
                   tempNewline, ")");
            fi;
          fi;
      else
        if c = fail then
          ErrorNoReturn("Unterminated partition specification (line ",
                        tempNewline, ")");
        elif c = ']' then
          break;
        else
          ErrorNoReturn("Unexpected character ", c,
                        " in partition specification (line ", r.newline, ")");
        fi;
      fi;
    od;
  fi;
  r.partition := partition;
  return;
end);

InstallMethod(DigraphFromDreadnautString, "for a digraph", [IsString],
function(D)
  local r, c, minus, backslash, temp, out, underscore, doubleUnderscore;
  r := rec(n := fail, digraph := false, labelorg := 0, i := 0,
           newline := 1, edgeList := fail, partition := fail);
  underscore := false;
  doubleUnderscore := false;

  minus := false;
  c := ' ';

  if D = "" then
    ErrorNoReturn("the argument <s> must be a non-empty string");
  fi;

  while c <> fail do
    c := DIGRAPHS_GetUngetChar(r, D, 1);
    if c = fail then
      break;
    elif c in " \t\r" then
    elif c = '-' then
      minus := true;
    elif c in "+,;\n" then
      minus := false;
    elif c = 'A' then
      minus := false;
      temp := DIGRAPHS_GetUngetChar(r, D, 1);
      if (temp in "nNdDtTsS") = false then
        ErrorNoReturn("Operation 'A' (line ", r.newline,
                      ") is not recognised");
      fi;
      temp := DIGRAPHS_GetUngetChar(r, D, 1);
      if temp <> '+' then
        DIGRAPHS_GetUngetChar(r, D, -1);
      fi;
    elif c in "B@#jv\%IixtTobzamp?Hc" then
      minus := false;
      Info(InfoWarning, 1, "Operation ", c, " (line ", r.newline,
           ") is not supported");
    elif c = '_' then
      temp := DIGRAPHS_GetUngetChar(r, D, 1);
      if temp = '_' then
        doubleUnderscore := true;
      else
        underscore := true;
        DIGRAPHS_GetUngetChar(r, D, -1);
      fi;
    elif c in "<eq" then
      ErrorNoReturn("Operation ", c, " (line ", r.newline,
                    ") is not supported");
    elif c = 'd' then
      if not minus then
        r.digraph := true;
      else
        minus := false;
        r.digraph := false;
      fi;
    elif c in ">" then
      ErrorNoReturn("Operation '>' (line ", r.newline,
                    ") is not supported.",
                    " Please use 'WriteDigraphs'.");
    elif c = '!' then
      while c <> '\n' and c <> fail do
        c := DIGRAPHS_GetUngetChar(r, D, 1);
      od;
    elif c = 'n' then
      minus := false;
      r.n := DIGRAPHS_GetInt(r, D);
      if r.n = fail then
        ErrorNoReturn("Expected integer on line ", r.newline,
                      " following ", c, " but was not found");
      elif r.n <= 0 then
        ErrorNoReturn("Vertex number given as ", r.n, " (line ",
                      r.newline,
                      "), but should be positive.");
      fi;
    elif c = 'g' then
      minus := false;
      if r.edgeList <> fail then
        Info(InfoWarning, 1, "Multiple graphs have been declared.",
             " Only the last one will be read in.");
      fi;
      DIGRAPHS_readgraph(r, D);
    elif c = 's' then
      minus := false;
      if DIGRAPHS_GetUngetChar(r, D, 1) <> 'r' then
        DIGRAPHS_GetUngetChar(r, D, -1);
      fi;
      Info(InfoWarning, 1, "Operation 's' or 'sr' (line ", r.newline,
           ") is not supported");
      DIGRAPHS_GetInt(r, D);
    elif c = '\"' then
      minus := false;
      c := DIGRAPHS_GetUngetChar(r, D, 1);
      temp := r.newline;
      backslash := false;
      while c <> fail do
        c := DIGRAPHS_GetUngetChar(r, D, 1);
        if c = '\\' then
          backslash := true;
        elif backslash then
          backslash := false;
        elif c = '\"' then
          if backslash then
            backslash := false;
          else
            break;
          fi;
        fi;
      od;
      if c = fail then
        ErrorNoReturn("Unterminated comment beginning on line ",
                      temp);
      fi;
    elif c = 'f' then
      DIGRAPHS_ParsePartition(r, minus, D);
      if minus then
        minus := false;
      fi;
    elif c in "lwyK*" then
      Info(InfoWarning, 1, "Operation ", c, " (line ",
           r.newline, ") is not supported");
      minus := false;
      DIGRAPHS_GetInt(r, D);
    elif c = 'F' then
      minus := false;
      temp := DIGRAPHS_GetUngetChar(r, D, 1);
      if temp = 'F' then
        Info(InfoWarning, 1, "Operation 'FF' (line ", r.newline,
             ") is not supported");
      else
        DIGRAPHS_GetUngetChar(r, D, -1);
        Info(InfoWarning, 1, "Operation 'F' (line ", r.newline,
             ") is not supported");
        DIGRAPHS_GetInt(r, D);
      fi;
    elif c = 'O' then
      if DIGRAPHS_GetUngetChar(r, D, 1) <> 'O' then
        DIGRAPHS_GetUngetChar(r, D, -1);
        Info(InfoWarning, 1, "Operation 'O' (line ", r.newline,
             ") is not supported");
      else
        Info(InfoWarning, 1, "Operation 'OO' (line ", r.newline,
             ") is not supported");
      fi;
    elif c = 'M' then
      Info(InfoWarning, 1, "Operation 'M' (line ",
           r.newline, ") is not supported");
      if minus then
        minus := false;
      else
        DIGRAPHS_GetInt(r, D);
        if DIGRAPHS_GetUngetChar(r, D, 1) = '/' then
          DIGRAPHS_GetInt(r, D);
        else
          DIGRAPHS_GetUngetChar(r, D, -1);
        fi;
      fi;
    elif c = 'k' then
      Info(InfoWarning, 1, "Operation 'k' (line ",
           r.newline, ") is not supported");
      minus := false;
      DIGRAPHS_GetInt(r, D);
      DIGRAPHS_GetInt(r, D);
    elif c in "VSGu" then
      Info(InfoWarning, 1, "Operation ", c,
           " (line ", r.newline, ") is not supported");
      if minus then
        minus := false;
      else
        DIGRAPHS_GetInt(r, D);
      fi;
    elif c = 'P' then
      if minus then
        minus := false;
        Info(InfoWarning, 1, "Operation -", c,
             " (line ", r.newline, ") is not supported");
      else
        if DIGRAPHS_GetUngetChar(r, D, 1) = 'P' then
          temp := r.newline;
          while c <> fail and c <> ';' do
            c := DIGRAPHS_GetUngetChar(r, D, 1);
          od;
          if c = fail then
            ErrorNoReturn("Unterminated 'PP' operation beginning ",
                          "on line ", temp);
          fi;
          Info(InfoWarning, 1, "Operation PP (line ",
               r.newline, ") is not supported");
        else
          DIGRAPHS_GetUngetChar(r, D, -1);
          Info(InfoWarning, 1, "Operation ", c, " (line ",
               r.newline, ") is not supported");
        fi;
      fi;
    elif c = '$' then
      temp := DIGRAPHS_GetUngetChar(r, D, 1);
      if temp <> '$' then
        DIGRAPHS_GetUngetChar(r, D, -1);
        r.labelorg := DIGRAPHS_GetInt(r, D);
        if r.labelorg < 0 then
          ErrorNoReturn("Label origin ", r.labelorg, " on line ",
                        r.newline, " must be non-negative.");
        elif r.labelorg = fail then
          ErrorNoReturn("Expected integer on line ", r.newline,
                        " following $ but was not found");
        fi;
      fi;
      if r.labelorg <> 1 then
        Info(InfoWarning, 1, "Vertices will be 1-indexed");
      fi;
    elif c in "rR" then
      Info(InfoWarning, 1, "Operations ['r', 'r&', 'R']",
           " (line ", r.newline, ") is not supported");
      minus := false;
      if (c = 'r' and DIGRAPHS_GetUngetChar(r, D, 1) <> '&') or c = 'R' then
        DIGRAPHS_GetUngetChar(r, D, -1);
        temp := r.newline;
        while c <> fail and c <> ';' do
          c := DIGRAPHS_GetUngetChar(r, D, 1);
        od;
        if c = fail then
          ErrorNoReturn("Unterminated operation (either 'r' or 'R')",
                        " beginning on line ", temp);
        fi;
      fi;
    elif c = '&' then
      minus := false;
      temp := DIGRAPHS_GetUngetChar(r, D, 1);
      if temp <> '&' then
        DIGRAPHS_GetUngetChar(r, D, -1);
        Info(InfoWarning, 1, "Operation '& (line ",
             r.newline, ") is not supported");
      else
        Info(InfoWarning, 1, "Operation '&&' (line ",
             r.newline, ") is not supported");
      fi;
    else
      ErrorNoReturn("Illegal character ", c, " on line ", r.newline);
    fi;
  od;

  if r.edgeList = fail then
    ErrorNoReturn("No graph was declared.");
  fi;
  out := Digraph(r.edgeList);
  if not r.digraph then
    Info(InfoWarning, 1, "Graph is not directed and",
         " so will be symmetrised.");
  fi;
  if r.partition <> fail then
    SetDigraphVertexLabels(out, r.partition);
  fi;
  if doubleUnderscore then
    if not r.digraph then
      underscore := true;
    else
      out := DigraphReverse(out);
    fi;
  fi;
  if underscore then
    if DigraphHasLoops(out) then
      out := DigraphDual(out);
    else
      out := DigraphRemoveLoops(DigraphDual(out));
    fi;
  fi;
  return out;
end);

################################################################################
# 4. Encoders
################################################################################
InstallMethod(WriteDIMACSDigraph, "for a digraph", [IsString, IsDigraph],
              {name, D} -> WriteDigraphs(name, D, DIMACSString, "w"));

InstallMethod(DIMACSString, "for a digraph", [IsDigraph],
function(D)
  local n, verts, nbs, nr_loops, m, labels, i, j, out;

  if not IsSymmetricDigraph(D) then
    ErrorNoReturn("the argument <D> must be a symmetric digraph,");
  fi;

  n := DigraphNrVertices(D);
  verts := DigraphVertices(D);
  nbs := OutNeighbours(D);

  nr_loops := 0;
  if not HasDigraphHasLoops(D) or DigraphHasLoops(D) then
    for i in verts do
      for j in nbs[i] do
        if i = j then
          nr_loops := nr_loops + 1;
        fi;
      od;
    od;
    if IsImmutableDigraph(D) then
      SetDigraphHasLoops(D, nr_loops <> 0);
    fi;
  fi;
  m := ((DigraphNrEdges(D) - nr_loops) / 2) + nr_loops;

  # Problem definition
  out := Concatenation("p edge ", String(n), " ", String(m));

  # Edges
  for i in verts do
    for j in nbs[i] do
      if i <= j then
        out := Concatenation(out, "\ne ", String(i), " ", String(j));
      fi;
      # In the case that j < i, the edge will be written elsewhere in the file
    od;
  od;

  # Vertex labels
  if n > 0 then
    labels := DigraphVertexLabels(D);
    if not (IsHomogeneousList(labels) and IsInt(labels[1])) then
      Info(InfoDigraphs, 1,
           "Only integer vertex labels are supported by the DIMACS format.");
      Info(InfoDigraphs, 1,
           "The vertex labels of the argument <D> will not be",
           " saved.");
    else
      for i in verts do
        out := Concatenation(out, "\nn ", String(i), " ", String(labels[i]));
      od;
    fi;
  fi;

  return out;
end);

InstallGlobalFunction(DreadnautString,
function(args...)
  local n, verts, nbs, i, degs, filteredVerts, partition, partitionString,
        out, positions, joinedPositions, adj, D, dflabels;

  if Length(args) = 1 then
    D := args[1];
  elif Length(args) = 2 then
    D := args[1];
    partition := args[2];
  else
    ErrorNoReturn("there must be 1 or 2 arguments");
  fi;

  if not IsDigraph(D) then
    ErrorNoReturn("the first argument <D> must be a digraph");
  elif IsBound(partition) then
    if not IsList(partition) then
      ErrorNoReturn("the second argument <partition> must be a list");
    elif Length(partition) <> DigraphNrVertices(D) then
      ErrorNoReturn("the second argument <partition> must be a list of ",
                    "length equal to the number of vertices in <D>");
    fi;
  fi;

  if IsMultiDigraph(D) then
    Info(InfoWarning, 1,
         "Multidigraphs are not supported in this file format.",
         " Multiple edges will be reduced to a single edge.");
    D := DigraphRemoveAllMultipleEdges(D);
  fi;

  n := DigraphNrVertices(D);
  verts := DigraphVertices(D);
  nbs := OutNeighbours(D);
  degs := OutDegrees(D);

  if n = 0 then
    ErrorNoReturn("the argument <D> must be a digraph with at",
                  " least one vertex");
  fi;

  out := Concatenation("n=", String(n));
  out := Concatenation(out, " $=1 d g");

  filteredVerts := Filtered(verts, x -> degs[x] > 0);
  for i in filteredVerts do
    adj := List(nbs[i], String);
    if i <> n then
      out := Concatenation(out, "\n", String(i), " : ",
                           JoinStringsWithSeparator(adj, " "), ";");
    else
      out := Concatenation(out, "\n", String(i), " : ",
                           JoinStringsWithSeparator(adj, " "));
    fi;
  od;
  out := Concatenation(out, ".");
  if IsBound(partition) then
    dflabels := DuplicateFreeList(partition);
    partitionString := "\nf = [";

    for i in dflabels do
      positions := PositionsProperty(partition, x -> x = i);
      joinedPositions := JoinStringsWithSeparator(positions, " ");
      partitionString := Concatenation(partitionString, joinedPositions);
      if i <> dflabels[Length(dflabels)] then
        partitionString := Concatenation(partitionString, " | ");
      fi;
    od;
    out := Concatenation(out, partitionString, "]");
  fi;

  return out;
end);

InstallGlobalFunction(DigraphPlainTextLineEncoder,
{delimiter1, delimiter2, offset} ->
function(D)
  local str, i, edges;
  edges := DigraphEdges(D);

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
end);

InstallGlobalFunction(WritePlainTextDigraph,
function(name, D, delimiter, offset)
  local file, edge;

  if not IsString(name) then
    ErrorNoReturn("the 1st argument <name> must be a string,");
  elif not IsString(delimiter) then
    ErrorNoReturn("the 3rd argument <delimiter> must be a string,");
  elif not IsInt(offset) then
    ErrorNoReturn("the 4th argument <offset> must be an integer,");
  fi;
  file := IO_CompressedFile(UserHomeExpand(name), "w");

  if file = fail then
    ErrorNoReturn("cannot open the file given as the 1st argument <name>,");
  fi;

  for edge in DigraphEdges(D) do
    IO_WriteLine(file, Concatenation(String(edge[1] + offset),
                                     delimiter,
                                     String(edge[2] + offset)));
  od;
  IO_Close(file);
end);

InstallMethod(Graph6String, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
  local list, adj, n, lenlist, tablen, blist, i, j, pos, block;
  if (IsMultiDigraph(D) or not IsSymmetricDigraph(D)
      or DigraphHasLoops(D)) then
    ErrorNoReturn("the argument <D> must be a symmetric digraph ",
                  "with no loops or multiple edges,");
  fi;

  list := [];
  adj := OutNeighbours(D);
  n := Length(DigraphVertices(D));

  # First write the number of vertices
  lenlist := DIGRAPHS_Graph6Length(n);
  if lenlist = fail then
    ErrorNoReturn("the argument <D> must be a digraph with between 0 and ",
                  "68719476736 vertices,");
  fi;
  Append(list, lenlist);

  # Find adjacencies (non-directed)
  tablen := n * (n - 1) / 2;
  blist := BlistList([1 .. tablen + 6], []);
  for i in DigraphVertices(D) do
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

InstallMethod(Digraph6String, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
  local list, adj, n, lenlist, tablen, blist, i, j, pos, block;
  # NOTE: this package originally used a version of digraph6 that reads down
  # the columns of an adjacency matrix, and appends a '+' to the start.  This
  # has been replaced by the Nauty standard, which reads across the rows of the
  # matrix, and appends a '&' to the start.  The old '+' format can be read by
  # DigraphFromDigraph6String, but can no longer be written by this function.

  list := [];
  adj := OutNeighbours(D);
  n := Length(DigraphVertices(D));

  # First write the special character '&'
  Add(list, -25);

  # Now write the number of vertices
  lenlist := DIGRAPHS_Graph6Length(n);
  if lenlist = fail then
    ErrorNoReturn("the argument <D> must be a digraph with between 0 and ",
                  "68719476736 vertices,");
  fi;
  Append(list, lenlist);

  # Find adjacencies
  tablen := n ^ 2;
  blist := BlistList([1 .. tablen + 6], []);
  for i in DigraphVertices(D) do
    for j in adj[i] do
      blist[j + n * (i - 1)] := true;
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

BindGlobal("DIGRAPHS_AddBinary",
function(blist, k, nextbit, i)
  local b;
  for b in [1 .. k] do
    blist[nextbit] := Int((i mod (2 ^ (k - b + 1))) / (2 ^ (k - b))) = 1;
    nextbit := nextbit + 1;
  od;
  return nextbit;
end);

InstallMethod(Sparse6String, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
  local list, n, lenlist, adj, nredges, k, blist, v, nextbit, i, j,
        bitstopad, pos, block;
  if not IsSymmetricDigraph(D) then
    ErrorNoReturn("the argument <D> must be a symmetric digraph,");
  fi;

  list := [];
  n := Length(DigraphVertices(D));

  # First write the special character ':'
  Add(list, -5);

  # Now write the number of vertices
  lenlist := DIGRAPHS_Graph6Length(n);
  if lenlist = fail then
    ErrorNoReturn("the argument <D> must be a digraph with between 0 and ",
                  "68719476736 vertices,");
  fi;
  Append(list, lenlist);

  # Get the out-neighbours - half these edges will be discarded
  adj := OutNeighbours(D);
  nredges := DigraphNrEdges(D);

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
        nextbit := DIGRAPHS_AddBinary(blist, k, nextbit + 1, i - 1);
        v := i - 1;
        blist[nextbit] := false;
        nextbit := nextbit + 1;
      fi;
      nextbit := DIGRAPHS_AddBinary(blist, k, nextbit, j - 1);
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

InstallMethod(DiSparse6String, "for a digraph by out-neighbours",
[IsDigraphByOutNeighboursRep],
function(D)
  local list, n, lenlist, adj, source_i, range_i, source_d, range_d, len1,
  len2, sort_d, perm, sort_i, k, blist, v, nextbit, bitstopad,
  pos, block, i, j;

  list := [];
  n := Length(DigraphVertices(D));

  # First write the special character '.'
  list[1] := -17;

  # Now write the number of vertices
  lenlist := DIGRAPHS_Graph6Length(n);
  if lenlist = fail then
    ErrorNoReturn("the argument <D> must be a digraph with between 0 and ",
                  "68719476736 vertices,");
  fi;
  Append(list, lenlist);

  # Separate edges into increasing and decreasing
  adj := OutNeighbours(D);
  source_i := [];
  range_i := [];
  source_d := [];
  range_d := [];
  len1 := 1;
  len2 := 1;
  for i in DigraphVertices(D) do
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
      nextbit := DIGRAPHS_AddBinary(blist, k, nextbit + 1, source_d[i]);
      v := source_d[i];
      blist[nextbit] := false;
      nextbit := nextbit + 1;
    fi;
    nextbit := DIGRAPHS_AddBinary(blist, k, nextbit, range_d[i]);
  od;

  # Add a separation symbol (1 n).
  blist[nextbit] := true;
  nextbit := DIGRAPHS_AddBinary(blist, k, nextbit + 1, n);

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
      nextbit := DIGRAPHS_AddBinary(blist, k, nextbit + 1, range_i[i]);
      v := range_i[i];
      blist[nextbit] := false;
      nextbit := nextbit + 1;
    fi;
    nextbit := DIGRAPHS_AddBinary(blist, k, nextbit, source_i[i]);
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

InstallMethod(PlainTextString, "for a digraph", [IsDigraph],
D -> DigraphPlainTextLineEncoder("  ", " ", -1)(D));
