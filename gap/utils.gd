#############################################################################
##
#W  utils.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareGlobalFunction("DigraphsStartTest");
DeclareGlobalFunction("DigraphsStopTest");
DeclareGlobalFunction("DigraphsMakeDoc");
DeclareGlobalFunction("DigraphsTestAll");
DeclareGlobalFunction("DigraphsTestInstall");
DeclareGlobalFunction("DigraphsTestManualExamples");
DeclareGlobalFunction("DigraphsManualExamples");
DeclareGlobalFunction("DigraphsDir");

DeclareGlobalFunction("ReadDirectedGraphs");
DeclareOperation("ReadGraph6Line", [IsString]);
DeclareOperation("ReadDigraph6Line", [IsString]);
DeclareOperation("ReadSparse6Line", [IsString]);
DeclareGlobalFunction("ReadPlainTextDigraph");
DeclareGlobalFunction("DigraphPlainTextLineDecoder");

DeclareGlobalFunction("WriteDirectedGraph");
DeclareOperation("WriteGraph6", [IsDirectedGraph]);
DeclareOperation("WriteDigraph6", [IsDirectedGraph]);
DeclareOperation("WriteSparse6", [IsDirectedGraph]);
