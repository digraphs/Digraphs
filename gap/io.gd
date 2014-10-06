#############################################################################
##
#W  io.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareGlobalFunction("ReadDigraphs");
DeclareOperation("DigraphFromGraph6String", [IsString]);
DeclareOperation("DigraphFromDigraph6String", [IsString]);
DeclareOperation("DigraphFromSparse6String", [IsString]);
DeclareOperation("DigraphFromDiSparse6String", [IsString]);
DeclareGlobalFunction("ReadPlainTextDigraph");
DeclareGlobalFunction("DigraphPlainTextLineDecoder");

DeclareGlobalFunction("WriteDigraph");
DeclareOperation("WriteGraph6", [IsDigraph]);
DeclareOperation("WriteDigraph6", [IsDigraph]);
DeclareOperation("WriteSparse6", [IsDigraph]);
DeclareOperation("WriteDiSparse6", [IsDigraph]);

