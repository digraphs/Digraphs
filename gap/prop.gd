#############################################################################
##
##  prop.gd
##  Copyright (C) 2014-19                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# meaning it really has multiple edges!!
DeclareProperty("IsMultiDigraph", IsDigraph);

DeclareProperty("DigraphHasLoops", IsDigraph);
DeclareProperty("IsAcyclicDigraph", IsDigraph);
DeclareProperty("IsAperiodicDigraph", IsDigraph);
DeclareProperty("IsStronglyConnectedDigraph", IsDigraph);
DeclareProperty("IsConnectedDigraph", IsDigraph);
DeclareProperty("IsBiconnectedDigraph", IsDigraph);
DeclareProperty("IsBridgelessDigraph", IsDigraph);
DeclareProperty("IsBipartiteDigraph", IsDigraph);
DeclareProperty("IsCompleteBipartiteDigraph", IsDigraph);
DeclareProperty("IsCompleteMultipartiteDigraph", IsDigraph);
DeclareProperty("IsCompleteDigraph", IsDigraph);
DeclareProperty("IsTournament", IsDigraph);
DeclareProperty("IsChainDigraph", IsDigraph);
DeclareProperty("IsCycleDigraph", IsDigraph);
DeclareProperty("IsDigraphCore", IsDigraph);
DeclareProperty("IsDirectedTree", IsDigraph);
DeclareProperty("IsUndirectedTree", IsDigraph);
DeclareProperty("IsUndirectedForest", IsDigraph);
DeclareProperty("IsEdgeTransitive", IsDigraph);
DeclareProperty("IsVertexTransitive", IsDigraph);
DeclareProperty("IsEmptyDigraph", IsDigraph);
DeclareProperty("IsEulerianDigraph", IsDigraph);
DeclareProperty("IsFunctionalDigraph", IsDigraph);
DeclareProperty("IsHamiltonianDigraph", IsDigraph);
DeclareProperty("IsRegularDigraph", IsDigraph);
DeclareProperty("IsInRegularDigraph", IsDigraph);
DeclareProperty("IsOutRegularDigraph", IsDigraph);
DeclareProperty("IsDistanceRegularDigraph", IsDigraph);
DeclareProperty("IsReflexiveDigraph", IsDigraph);
DeclareProperty("IsSymmetricDigraph", IsDigraph);
DeclareProperty("IsAntisymmetricDigraph", IsDigraph);
DeclareProperty("IsTransitiveDigraph", IsDigraph);
DeclareProperty("IsJoinSemilatticeDigraph", IsDigraph);
DeclareProperty("IsMeetSemilatticeDigraph", IsDigraph);
DeclareSynonymAttr("IsLatticeDigraph",
                   IsMeetSemilatticeDigraph and IsJoinSemilatticeDigraph);
DeclareSynonymAttr("IsPreorderDigraph",
                   IsReflexiveDigraph and IsTransitiveDigraph);
DeclareSynonymAttr("IsPartialOrderDigraph",
                   IsReflexiveDigraph
                   and IsAntisymmetricDigraph
                   and IsTransitiveDigraph);
DeclareSynonymAttr("IsEquivalenceDigraph",
                   IsReflexiveDigraph
                   and IsSymmetricDigraph
                   and IsTransitiveDigraph);

DeclareSynonymAttr("IsAntiSymmetricDigraph", IsAntisymmetricDigraph);
DeclareSynonymAttr("IsNullDigraph", IsEmptyDigraph);
DeclareSynonymAttr("IsQuasiorderDigraph", IsPreorderDigraph);

DeclareOperation("DIGRAPHS_IsMeetJoinSemilatticeDigraph",
                 [IsHomogeneousList]);

InstallTrueMethod(IsAcyclicDigraph, IsEmptyDigraph);
InstallTrueMethod(IsAcyclicDigraph, IsTournament and IsTransitiveDigraph);
InstallTrueMethod(IsAntisymmetricDigraph, IsAcyclicDigraph);
InstallTrueMethod(IsAntisymmetricDigraph, IsTournament);
InstallTrueMethod(IsBipartiteDigraph, IsCompleteBipartiteDigraph);
InstallTrueMethod(IsCompleteMultipartiteDigraph, IsCompleteBipartiteDigraph);
InstallTrueMethod(IsConnectedDigraph, IsBiconnectedDigraph);
InstallTrueMethod(IsConnectedDigraph, IsStronglyConnectedDigraph);
InstallTrueMethod(IsInRegularDigraph, IsRegularDigraph);
InstallTrueMethod(IsOutRegularDigraph, IsRegularDigraph);
InstallTrueMethod(IsPreorderDigraph, IsPartialOrderDigraph);
InstallTrueMethod(IsRegularDigraph, IsInRegularDigraph and IsOutRegularDigraph);
InstallTrueMethod(IsRegularDigraph, IsVertexTransitive);
InstallTrueMethod(IsStronglyConnectedDigraph,
                  IsConnectedDigraph and IsSymmetricDigraph);
InstallTrueMethod(IsStronglyConnectedDigraph, IsEulerianDigraph);
InstallTrueMethod(IsStronglyConnectedDigraph, IsHamiltonianDigraph);
InstallTrueMethod(IsStronglyConnectedDigraph, IsUndirectedTree);
InstallTrueMethod(IsSymmetricDigraph, IsCompleteDigraph);
InstallTrueMethod(IsSymmetricDigraph, IsUndirectedForest);
InstallTrueMethod(IsTransitiveDigraph, IsTournament and IsAcyclicDigraph);
InstallTrueMethod(IsUndirectedForest, IsUndirectedTree);
