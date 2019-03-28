#############################################################################
##
##  io.gd
##  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# Read/WriteDigraphs (the main functions) . . .
DeclareGlobalFunction("ReadDigraphs");
DeclareGlobalFunction("WriteDigraphs");

DeclareGlobalFunction("DigraphFile");
DeclareGlobalFunction("IteratorFromDigraphFile");

# Decoders . . .
DeclareOperation("DigraphFromGraph6String", [IsFunction, IsString]);
DeclareOperation("DigraphFromDigraph6String", [IsFunction, IsString]);
DeclareOperation("DigraphFromSparse6String", [IsFunction, IsString]);
DeclareOperation("DigraphFromDiSparse6String", [IsFunction, IsString]);
DeclareOperation("DigraphFromPlainTextString", [IsFunction, IsString]);
DeclareOperation("ReadDIMACSDigraph", [IsFunction, IsString]);

DeclareOperation("DigraphFromGraph6String", [IsString]);
DeclareOperation("DigraphFromDigraph6String", [IsString]);
DeclareOperation("DigraphFromSparse6String", [IsString]);
DeclareOperation("DigraphFromDiSparse6String", [IsString]);
DeclareOperation("DigraphFromPlainTextString", [IsString]);
DeclareOperation("ReadDIMACSDigraph", [IsString]);
DeclareOperation("TournamentLineDecoder", [IsFunction, IsString]);
DeclareOperation("TournamentLineDecoder", [IsString]);

DeclareOperation("DigraphPlainTextLineDecoder",
                 [IsFunction, IsString, IsString, IsInt]);
DeclareOperation("DigraphPlainTextLineDecoder",
                 [IsString, IsString, IsInt]);
DeclareOperation("ReadPlainTextDigraph",
                 [IsFunction, IsString, IsString, IsInt, IsString]);
DeclareOperation("ReadPlainTextDigraph",
                 [IsString, IsString, IsInt, IsString]);

DeclareOperation("AdjacencyMatrixUpperTriangleLineDecoder",
                 [IsFunction, IsString]);
DeclareOperation("AdjacencyMatrixUpperTriangleLineDecoder",
                 [IsString]);

DeclareOperation("TCodeDecoder", [IsFunction, IsString]);
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
