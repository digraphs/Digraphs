#############################################################################
##
##  prop.gd
##  Copyright (C) 2014-21                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# meaning it really has multiple edges!!
DeclareProperty("IsMultiDigraph", IsDigraph);

DeclareProperty("DigraphHasAVertex", IsDigraph);
DeclareProperty("DigraphHasNoVertices", IsDigraph);

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
DeclareProperty("IsNonemptyDigraph", IsDigraph);
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
DeclareProperty("IsPermutationDigraph", IsDigraph);
DeclareProperty("IsDistributiveLatticeDigraph", IsDigraph);
DeclareProperty("IsModularLatticeDigraph", IsDigraph);
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

DeclareOperation("DIGRAPHS_IsJoinSemilatticeAndJoinTable", [IsDigraph]);
DeclareOperation("DIGRAPHS_IsMeetSemilatticeAndMeetTable", [IsDigraph]);

InstallTrueMethod(IsAcyclicDigraph, IsChainDigraph);
InstallTrueMethod(IsAcyclicDigraph, IsDigraph and IsDirectedTree);
InstallTrueMethod(IsAcyclicDigraph, IsEmptyDigraph);
InstallTrueMethod(IsAcyclicDigraph, IsTournament and IsTransitiveDigraph);
InstallTrueMethod(IsAntisymmetricDigraph, IsAcyclicDigraph);
InstallTrueMethod(IsAntisymmetricDigraph, IsDigraph and IsTournament);
InstallTrueMethod(IsBipartiteDigraph, IsCompleteBipartiteDigraph);
InstallTrueMethod(IsBipartiteDigraph, IsDigraph and IsUndirectedForest);
InstallTrueMethod(IsCompleteMultipartiteDigraph, IsCompleteBipartiteDigraph);
InstallTrueMethod(IsConnectedDigraph, IsBiconnectedDigraph);
InstallTrueMethod(IsConnectedDigraph, IsStronglyConnectedDigraph);
InstallTrueMethod(IsFunctionalDigraph, IsCycleDigraph);
InstallTrueMethod(IsFunctionalDigraph, IsPermutationDigraph);
InstallTrueMethod(IsHamiltonianDigraph,
                  IsTournament and IsStronglyConnectedDigraph);
InstallTrueMethod(IsInRegularDigraph, IsRegularDigraph);
InstallTrueMethod(IsOutRegularDigraph, IsRegularDigraph);
InstallTrueMethod(IsPreorderDigraph, IsPartialOrderDigraph);
InstallTrueMethod(IsReflexiveDigraph,
                  IsDigraph and IsVertexTransitive and DigraphHasLoops);
InstallTrueMethod(IsRegularDigraph, IsInRegularDigraph and IsOutRegularDigraph);
InstallTrueMethod(IsRegularDigraph, IsDigraph and IsVertexTransitive);
InstallTrueMethod(IsStronglyConnectedDigraph,
                  IsConnectedDigraph and IsSymmetricDigraph);
InstallTrueMethod(IsStronglyConnectedDigraph, IsCycleDigraph);
InstallTrueMethod(IsStronglyConnectedDigraph, IsEulerianDigraph);
InstallTrueMethod(IsStronglyConnectedDigraph, IsHamiltonianDigraph);
InstallTrueMethod(IsStronglyConnectedDigraph, IsDigraph and IsUndirectedTree);
InstallTrueMethod(IsSymmetricDigraph, IsCompleteDigraph);
InstallTrueMethod(IsSymmetricDigraph, IsDigraph and IsUndirectedForest);
InstallTrueMethod(IsTransitiveDigraph, IsTournament and IsAcyclicDigraph);
InstallTrueMethod(IsUndirectedForest, IsDigraph and IsUndirectedTree);

InstallTrueMethod(IsNonemptyDigraph, IsDigraph and DigraphHasLoops);
InstallTrueMethod(DigraphHasLoops, IsReflexiveDigraph and DigraphHasAVertex);
InstallTrueMethod(DigraphHasAVertex, IsDigraph and IsNonemptyDigraph);
InstallTrueMethod(DigraphHasAVertex, IsDigraph and IsDirectedTree);

# Implications that something is false

InstallTrueMethod(HasDigraphHasLoops, IsAcyclicDigraph);
InstallTrueMethod(HasDigraphHasLoops, IsTournament);
InstallTrueMethod(HasDigraphHasLoops, IsUndirectedForest);
InstallTrueMethod(HasDigraphHasLoops, IsDirectedTree);
InstallTrueMethod(HasDigraphHasLoops, IsEmptyDigraph);
InstallTrueMethod(HasDigraphHasLoops, IsCompleteDigraph and IsNonemptyDigraph);
InstallTrueMethod(HasDigraphHasLoops, IsBipartiteDigraph);

InstallTrueMethod(HasIsNonemptyDigraph, IsEmptyDigraph);
InstallTrueMethod(HasIsEmptyDigraph, IsNonemptyDigraph);
InstallTrueMethod(HasDigraphHasAVertex, DigraphHasNoVertices);
InstallTrueMethod(HasDigraphHasNoVertices, DigraphHasAVertex);

InstallTrueMethod(HasIsAcyclicDigraph, IsCompleteDigraph and IsNonemptyDigraph);
InstallTrueMethod(HasIsAcyclicDigraph, IsDigraph and DigraphHasLoops);
InstallTrueMethod(HasIsAcyclicDigraph,
                  IsStronglyConnectedDigraph and IsNonemptyDigraph);
InstallTrueMethod(HasIsAntisymmetricDigraph,
                  IsCompleteDigraph and IsNonemptyDigraph);
InstallTrueMethod(HasIsChainDigraph, IsDigraph and DigraphHasLoops);
InstallTrueMethod(HasIsChainDigraph, IsSymmetricDigraph and IsNonemptyDigraph);
InstallTrueMethod(HasIsCompleteDigraph, IsDigraph and DigraphHasLoops);
InstallTrueMethod(HasIsReflexiveDigraph,
                  IsAcyclicDigraph and DigraphHasAVertex);

InstallTrueMethod(HasIsSymmetricDigraph, IsDirectedTree and IsNonemptyDigraph);
InstallTrueMethod(HasIsSymmetricDigraph, IsTournament and IsNonemptyDigraph);
InstallTrueMethod(HasIsSymmetricDigraph,
                  IsAcyclicDigraph and IsNonemptyDigraph);

InstallTrueMethod(HasIsMultiDigraph, IsChainDigraph);
InstallTrueMethod(HasIsMultiDigraph, IsCompleteDigraph);
InstallTrueMethod(HasIsMultiDigraph, IsCompleteMultipartiteDigraph);
InstallTrueMethod(HasIsMultiDigraph, IsCycleDigraph);
InstallTrueMethod(HasIsMultiDigraph, IsEmptyDigraph);
InstallTrueMethod(HasIsMultiDigraph, IsFunctionalDigraph);
InstallTrueMethod(HasIsMultiDigraph, IsTournament);
InstallTrueMethod(HasIsMultiDigraph, IsUndirectedForest);
