#ifndef GRAPHFUNCTIONTABLE_H
#define GRAPHFUNCTIONTABLE_H

/*
Copyright (c) 1997-2025, John M. Boyer
All rights reserved.
See the LICENSE.TXT file for licensing information.
*/

#ifdef __cplusplus
extern "C"
{
#endif

    /*
     NOTE: If you add any FUNCTION POINTERS to this function table, then you must
           also initialize them in _InitFunctionTable() in graphUtils.c.
    */
    typedef struct baseGraphStructure baseGraphStructure;
    typedef baseGraphStructure *graphP;

    typedef struct
    {
        // These function pointers allow extension modules to overload some of
        // the behaviors of protected functions.  Only advanced applications
        // will overload these functions
        int (*fpEmbeddingInitialize)(graphP);
        void (*fpEmbedBackEdgeToDescendant)(graphP, int, int, int, int);
        void (*fpWalkUp)(graphP, int, int);
        int (*fpWalkDown)(graphP, int, int);
        int (*fpMergeBicomps)(graphP, int, int, int, int);
        void (*fpMergeVertex)(graphP, int, int, int);
        int (*fpHandleInactiveVertex)(graphP, int, int *, int *);
        int (*fpHandleBlockedBicomp)(graphP, int, int, int);
        int (*fpEmbedPostprocess)(graphP, int, int);
        int (*fpMarkDFSPath)(graphP, int, int);

        int (*fpCheckEmbeddingIntegrity)(graphP, graphP);
        int (*fpCheckObstructionIntegrity)(graphP, graphP);

        // These function pointers allow extension modules to overload some
        // of the behaviors of gp_* function in the public API
        int (*fpInitGraph)(graphP, int);
        void (*fpReinitializeGraph)(graphP);
        int (*fpEnsureArcCapacity)(graphP, int);
        int (*fpSortVertices)(graphP);

        int (*fpReadPostprocess)(graphP, char *);
        int (*fpWritePostprocess)(graphP, char **);

        void (*fpHideEdge)(graphP, int);
        void (*fpRestoreEdge)(graphP, int);
        int (*fpHideVertex)(graphP, int);
        int (*fpRestoreVertex)(graphP);
        int (*fpContractEdge)(graphP, int);
        int (*fpIdentifyVertices)(graphP, int, int, int);

    } graphFunctionTable;

    typedef graphFunctionTable *graphFunctionTableP;

#ifdef __cplusplus
}
#endif

#endif
