#############################################################################
##
##  nauty.g
##  Copyright (C) 2014-19                                James D. Mitchell
##                                                          Wilf A. Wilson
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# Package extension, read by GAP once NautyTracesInterface is loaded.

MakeReadWriteGlobal("NAUTY_DATA");
NAUTY_DATA := function(D, colors)
  local data;
  if colors <> false then
    colors := DIGRAPHS_ValidateVertexColouring(DigraphNrVertices(D),
                                               colors);
    colors := NautyColorData(colors);
  fi;
  if DigraphHasNoVertices(D) then
    # This circumvents Issue #17 in NautyTracesInterface, whereby a graph
    # with 0 vertices causes a seg fault.
    return [Group(()), ()];
  fi;
  data := NautyDense(DigraphSource(D),
                     DigraphRange(D),
                     DigraphNrVertices(D),
                     not IsSymmetricDigraph(D),
                     colors);
  if IsEmpty(data[1]) then
    data[1] := [()];
  fi;
  data[1] := Group(data[1]);
  data[2] := data[2] ^ -1;
  return data;
end;
MakeReadOnlyGlobal("NAUTY_DATA");

MakeReadWriteGlobal("DIGRAPHS_NautyAvailable");
DIGRAPHS_NautyAvailable := true;
MakeReadOnlyGlobal("DIGRAPHS_NautyAvailable");
