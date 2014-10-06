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
DeclareOperation("ReadGraph6Line", [IsString]);
DeclareOperation("ReadDigraph6Line", [IsString]);
DeclareOperation("ReadSparse6Line", [IsString]);
DeclareOperation("ReadDiSparse6Line", [IsString]);
DeclareGlobalFunction("ReadPlainTextDigraph");
DeclareGlobalFunction("DigraphPlainTextLineDecoder");

DeclareGlobalFunction("WriteDigraph");
DeclareOperation("WriteGraph6", [IsDigraph]);
DeclareOperation("WriteDigraph6", [IsDigraph]);
DeclareOperation("WriteSparse6", [IsDigraph]);
DeclareOperation("WriteDiSparse6", [IsDigraph]);

