#ifndef GRAPHFUNCTIONTABLE_H
#define GRAPHFUNCTIONTABLE_H

/*
Copyright (c) 1997-2015, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#ifdef __cplusplus
extern "C" {
#endif

/*
 NOTE: If you add any FUNCTION POINTERS to this function table, then you must
       also initialize them in _InitFunctionTable() in graphUtils.c.
*/

typedef struct
{
        // These function pointers allow extension modules to overload some of
        // the behaviors of protected functions.  Only advanced applications
        // will overload these functions
    	int  (*fpEmbeddingInitialize)();
        void (*fpEmbedBackEdgeToDescendant)();
        void (*fpWalkUp)();
        int  (*fpWalkDown)();
        int  (*fpMergeBicomps)();
        void (*fpMergeVertex)();
        int  (*fpHandleInactiveVertex)();
        int  (*fpHandleBlockedBicomp)();
        int  (*fpEmbedPostprocess)();
        int  (*fpMarkDFSPath)();

        int  (*fpCheckEmbeddingIntegrity)();
        int  (*fpCheckObstructionIntegrity)();

        // These function pointers allow extension modules to overload some
        // of the behaviors of gp_* function in the public API
        int  (*fpInitGraph)();
        void (*fpReinitializeGraph)();
        int  (*fpEnsureArcCapacity)();
        int  (*fpSortVertices)();

        int  (*fpReadPostprocess)();
        int  (*fpWritePostprocess)();

        void (*fpHideEdge)();
        void (*fpRestoreEdge)();
        int  (*fpHideVertex)();
        int  (*fpRestoreVertex)();
        int  (*fpContractEdge)();
        int  (*fpIdentifyVertices)();

} graphFunctionTable;

typedef graphFunctionTable * graphFunctionTableP;

#ifdef __cplusplus
}
#endif

#endif
