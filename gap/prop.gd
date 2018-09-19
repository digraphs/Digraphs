#############################################################################
##
##  prop.gd
##  Copyright (C) 2014-17                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareProperty("IsAcyclicDigraph", IsDigraph);
DeclareProperty("IsBipartiteDigraph", IsDigraph);
DeclareProperty("IsBiconnectedDigraph", IsDigraph);
DeclareProperty("IsChainDigraph", IsDigraph);
DeclareProperty("IsCompleteDigraph", IsDigraph);
DeclareProperty("IsCompleteBipartiteDigraph", IsDigraph);
DeclareProperty("IsConnectedDigraph", IsDigraph);
DeclareProperty("IsEmptyDigraph", IsDigraph);
DeclareSynonym("IsNullDigraph", IsEmptyDigraph);
DeclareProperty("IsFunctionalDigraph", IsDigraph);
DeclareProperty("IsReflexiveDigraph", IsDigraph);
DeclareProperty("IsStronglyConnectedDigraph", IsDigraph);
DeclareProperty("IsSymmetricDigraph", IsDigraph);
DeclareProperty("IsAntisymmetricDigraph", IsDigraph);
DeclareProperty("IsTournament", IsDigraph);
DeclareProperty("IsTransitiveDigraph", IsDigraph);
DeclareProperty("DigraphHasLoops", IsDigraph);
DeclareProperty("IsAperiodicDigraph", IsDigraph);
DeclareProperty("IsInRegularDigraph", IsDigraph);
DeclareProperty("IsOutRegularDigraph", IsDigraph);
DeclareProperty("IsRegularDigraph", IsDigraph);
DeclareProperty("IsDistanceRegularDigraph", IsDigraph);
DeclareProperty("IsDirectedTree", IsDigraph);
DeclareProperty("IsUndirectedTree", IsDigraph);
DeclareProperty("IsUndirectedForest", IsDigraph);
DeclareProperty("IsEulerianDigraph", IsDigraph);
DeclareProperty("IsHamiltonianDigraph", IsDigraph);
DeclareProperty("IsMeetSemilatticeDigraph", IsDigraph);
DeclareProperty("IsJoinSemilatticeDigraph", IsDigraph);
DeclareProperty("IsCycleDigraph", IsDigraph);

DeclareOperation("DIGRAPHS_IsMeetJoinSemilatticeDigraph",
                 [IsHomogeneousList]);

InstallTrueMethod(IsAntisymmetricDigraph, IsTournament);
InstallTrueMethod(IsAntisymmetricDigraph, IsAcyclicDigraph);
InstallTrueMethod(IsTransitiveDigraph, IsTournament and IsAcyclicDigraph);
InstallTrueMethod(IsAcyclicDigraph, IsTournament and IsTransitiveDigraph);
InstallTrueMethod(IsSymmetricDigraph, IsCompleteDigraph);
InstallTrueMethod(IsSymmetricDigraph, IsUndirectedForest);
InstallTrueMethod(IsAcyclicDigraph, IsEmptyDigraph);
InstallTrueMethod(IsRegularDigraph, IsInRegularDigraph and IsOutRegularDigraph);
InstallTrueMethod(IsStronglyConnectedDigraph,
                  IsConnectedDigraph and IsSymmetricDigraph);
InstallTrueMethod(IsStronglyConnectedDigraph, IsUndirectedTree);
InstallTrueMethod(IsUndirectedForest, IsUndirectedTree);

DeclareSynonymAttr("IsPartialOrderDigraph",
                   IsReflexiveDigraph and IsAntisymmetricDigraph
                   and IsTransitiveDigraph);
DeclareSynonymAttr("IsLatticeDigraph",
                    IsMeetSemilatticeDigraph and IsJoinSemilatticeDigraph);
DeclareSynonymAttr("IsPreorderDigraph",
                   IsReflexiveDigraph and IsTransitiveDigraph);
DeclareSynonymAttr("IsQuasiorderDigraph", IsPreorderDigraph);
