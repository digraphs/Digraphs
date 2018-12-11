#############################################################################
##
##  planar.gd
##  Copyright (C) 2018                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# The methods in this file utilise the kernel module functions that wrap
# Boyer's reference implementation (in C) of the planarity and subgraph
# homeomorphism algorithms from:
#
# John M. Boyer and Wendy J. Myrvold, On the Cutting Edge: Simplified O(n)
# Planarity by Edge Addition. Journal of Graph Algorithms and Applications, Vol.
# 8, No. 3, pp. 241-273, 2004.

# Attributes . . .

DeclareAttribute("PlanarEmbedding", IsDigraph);
DeclareAttribute("OuterPlanarEmbedding", IsDigraph);
DeclareAttribute("KuratowskiPlanarSubdigraph", IsDigraph);
DeclareAttribute("KuratowskiOuterPlanarSubdigraph", IsDigraph);
DeclareAttribute("SubdigraphHomeomorphicToK23", IsDigraph);
DeclareAttribute("SubdigraphHomeomorphicToK4", IsDigraph);
DeclareAttribute("SubdigraphHomeomorphicToK33", IsDigraph);

# Properties . . .

DeclareProperty("IsPlanarDigraph", IsDigraph);
DeclareProperty("IsOuterPlanarDigraph", IsDigraph);

# True methods . . .

InstallTrueMethod(IsBiconnectedDigraph,
                  IsOuterPlanarDigraph and IsHamiltonianDigraph);
InstallTrueMethod(IsHamiltonianDigraph,
                  IsOuterPlanarDigraph and IsBiconnectedDigraph);
InstallTrueMethod(IsPlanarDigraph, IsOuterPlanarDigraph);
