#############################################################################
##
##  io.gd
##  Copyright (C) 2014-16                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

#  TODO Document the optional (e.g.) `IsMutableDigraph` first argument for
#       many of these operations.

# Read/WriteDigraphs (the main functions) . . .
DeclareGlobalFunction("ReadDigraphs");
DeclareGlobalFunction("WriteDigraphs");

DeclareGlobalFunction("DigraphFile");
DeclareGlobalFunction("IteratorFromDigraphFile");

# Decoders . . .
DeclareConstructor("DigraphFromGraph6StringCons", [IsDigraph, IsString]);
DeclareOperation("DigraphFromGraph6String", [IsFunction, IsString]);
DeclareOperation("DigraphFromGraph6String", [IsString]);
DeclareConstructor("DigraphFromDigraph6StringCons", [IsDigraph, IsString]);
DeclareOperation("DigraphFromDigraph6String", [IsFunction, IsString]);
DeclareOperation("DigraphFromDigraph6String", [IsString]);
DeclareOperation("DigraphFromSparse6String", [IsString]);
DeclareOperation("DigraphFromDiSparse6String", [IsString]);
DeclareOperation("DigraphFromPlainTextString", [IsString]);
DeclareOperation("ReadDIMACSDigraph", [IsString]);
DeclareOperation("TournamentLineDecoder", [IsString]);

DeclareOperation("DigraphPlainTextLineDecoder",
                 [IsString, IsString, IsInt]);
DeclareOperation("ReadPlainTextDigraph",
                 [IsString, IsString, IsInt, IsString]);
DeclareOperation("AdjacencyMatrixUpperTriangleLineDecoder",
                 [IsString]);

DeclareOperation("TCodeDecoder", [IsString]);
DeclareGlobalFunction("TCodeDecoderNC");

# Encoders . . .
DeclareOperation("Graph6String", [IsDigraph]);
DeclareOperation("Digraph6String", [IsDigraph]);
DeclareOperation("Sparse6String", [IsDigraph]);
DeclareOperation("DiSparse6String", [IsDigraph]);
DeclareOperation("PlainTextString", [IsDigraph]);
DeclareOperation("WriteDIMACSDigraph", [IsString, IsDigraph]);
DeclareGlobalFunction("WritePlainTextDigraph");
DeclareGlobalFunction("DigraphPlainTextLineEncoder");
