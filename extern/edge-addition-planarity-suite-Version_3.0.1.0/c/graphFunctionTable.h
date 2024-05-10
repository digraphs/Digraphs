#ifndef GRAPHFUNCTIONTABLE_H
#define GRAPHFUNCTIONTABLE_H

/*
Copyright (c) 1997-2020, John M. Boyer
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

#if defined(__clang__)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#pragma clang diagnostic ignored "-Wmissing-prototypes"
#pragma clang diagnostic ignored "-Wdeprecated-non-prototype"
#elif defined(__GNUC__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wstrict-prototypes"
#pragma GCC diagnostic ignored "-Wmissing-prototypes"

#endif

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

#if defined(__clang__)
#pragma clang diagnostic pop
#elif defined(__GNUC__)
#pragma GCC diagnostic pop
#endif

#ifdef __cplusplus
}
#endif

#endif

