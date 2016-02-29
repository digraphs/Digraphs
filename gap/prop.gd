#############################################################################
##
#W  props.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareProperty("IsAcyclicDigraph", IsDigraph);
DeclareProperty("IsBipartiteDigraph", IsDigraph);
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

InstallTrueMethod(IsAntisymmetricDigraph, IsTournament);
InstallTrueMethod(IsAntisymmetricDigraph, IsAcyclicDigraph);
InstallTrueMethod(IsTransitiveDigraph, IsTournament and IsAcyclicDigraph);
InstallTrueMethod(IsAcyclicDigraph, IsTournament and IsTransitiveDigraph);
InstallTrueMethod(IsSymmetricDigraph, IsCompleteDigraph);
InstallTrueMethod(IsTransitiveDigraph, IsCompleteDigraph);
InstallTrueMethod(IsAcyclicDigraph, IsEmptyDigraph);
InstallTrueMethod(IsRegularDigraph, IsInRegularDigraph and IsOutRegularDigraph);
