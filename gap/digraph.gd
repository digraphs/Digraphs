#############################################################################
##
##  digraph.gd
##  Copyright (C) 2014-19                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# Categories
DeclareCategory("IsDigraph", IsObject);
DeclareCategory("IsDigraphWithAdjacencyFunction", IsDigraph);
DeclareCategory("IsCayleyDigraph", IsDigraph);
DeclareCategory("IsImmutableDigraph", IsDigraph);
DeclareSynonym("IsMutableDigraph", IsDigraph and IsMutable);
DeclareCategoryCollections("IsDigraph");

DeclareAttribute("DigraphMutabilityFilter", IsDigraph);

# Family
BindGlobal("DigraphFamily", NewFamily("DigraphFamily", IsDigraph));

# Representations
DeclareRepresentation("IsDigraphByOutNeighboursRep",
                      IsDigraph and IsComponentObjectRep,
                      ["OutNeighbours"]);

# 2.  Digraph no-check constructors . . .
DeclareOperation("ConvertToMutableDigraphNC", [IsRecord]);
DeclareOperation("ConvertToMutableDigraphNC", [IsDenseList]);

DeclareOperation("ConvertToImmutableDigraphNC", [IsRecord]);
DeclareOperation("ConvertToImmutableDigraphNC", [IsList]);

DeclareConstructor("DigraphConsNC", [IsDigraph, IsRecord]);
DeclareConstructor("DigraphConsNC", [IsDigraph, IsDenseList]);

DeclareOperation("DigraphNC", [IsFunction, IsRecord]);
DeclareOperation("DigraphNC", [IsFunction, IsDenseList]);

DeclareOperation("DigraphNC", [IsRecord]);
DeclareOperation("DigraphNC", [IsDenseList]);

# 3.  Digraph copies . . .
DeclareOperation("DigraphMutableCopy", [IsDigraph]);
DeclareOperation("DigraphImmutableCopy", [IsDigraph]);
DeclareOperation("DigraphCopySameMutability", [IsDigraph]);
DeclareSynonym("DigraphCopy", DigraphCopySameMutability);
DeclareOperation("DigraphImmutableCopyIfMutable", [IsDigraph]);
DeclareOperation("DigraphImmutableCopyIfImmutable", [IsDigraph]);
DeclareOperation("DigraphMutableCopyIfImmutable", [IsDigraph]);
DeclareOperation("DigraphMutableCopyIfMutable", [IsDigraph]);

# 5.  Digraph constructors . . .
DeclareConstructor("DigraphCons", [IsDigraph, IsRecord]);
DeclareConstructor("DigraphCons", [IsDigraph, IsDenseList]);
DeclareConstructor("DigraphCons", [IsDigraph, IsList, IsFunction]);
DeclareConstructor("DigraphCons", [IsDigraph, IsInt, IsList, IsList]);
DeclareConstructor("DigraphCons", [IsDigraph, IsList, IsList, IsList]);

DeclareOperation("Digraph", [IsFunction, IsRecord]);
DeclareOperation("Digraph", [IsFunction, IsList]);
DeclareOperation("Digraph", [IsFunction, IsList, IsFunction]);
DeclareOperation("Digraph", [IsFunction, IsInt, IsList, IsList]);
DeclareOperation("Digraph", [IsFunction, IsList, IsList, IsList]);

DeclareOperation("Digraph", [IsRecord]);
DeclareOperation("Digraph", [IsList]);
DeclareOperation("Digraph", [IsList, IsFunction]);
DeclareOperation("Digraph", [IsInt, IsList, IsList]);
DeclareOperation("Digraph", [IsList, IsList, IsList]);

DeclareOperation("ListNamedDigraphs", [IsString]);
DeclareOperation("ListNamedDigraphs", [IsString, IsPosInt]);

# 8.  Digraph by-something constructors . . .
DeclareConstructor("DigraphByAdjacencyMatrixCons",
                  [IsDigraph, IsHomogeneousList]);
DeclareConstructor("DigraphByAdjacencyMatrixConsNC",
                   [IsDigraph, IsHomogeneousList]);

DeclareOperation("DigraphByAdjacencyMatrix", [IsFunction, IsHomogeneousList]);
DeclareOperation("DigraphByAdjacencyMatrix", [IsHomogeneousList]);

DeclareConstructor("DigraphByEdgesCons", [IsDigraph, IsList]);
DeclareConstructor("DigraphByEdgesCons", [IsDigraph, IsList, IsInt]);

DeclareOperation("DigraphByEdges", [IsFunction, IsList]);
DeclareOperation("DigraphByEdges", [IsFunction, IsList, IsInt]);
DeclareOperation("DigraphByEdges", [IsList]);
DeclareOperation("DigraphByEdges", [IsList, IsInt]);

DeclareConstructor("DigraphByInNeighboursCons", [IsDigraph, IsList]);
DeclareConstructor("DigraphByInNeighboursConsNC", [IsDigraph, IsList]);

DeclareOperation("DigraphByInNeighbours", [IsFunction, IsList]);
DeclareOperation("DigraphByInNeighbours", [IsList]);

DeclareSynonym("DigraphByInNeighbors", DigraphByInNeighbours);

# 9.  Converters to/from other types -> digraph . . .
DeclareConstructor("AsDigraphCons", [IsDigraph, IsBinaryRelation]);
DeclareConstructor("AsDigraphCons", [IsDigraph, IsTransformation]);
DeclareConstructor("AsDigraphCons", [IsDigraph, IsTransformation, IsInt]);
DeclareConstructor("AsDigraphCons", [IsDigraph, IsPartialPerm]);
DeclareConstructor("AsDigraphCons", [IsDigraph, IsPartialPerm, IsInt]);

DeclareOperation("AsDigraph", [IsFunction, IsBinaryRelation]);
DeclareOperation("AsDigraph", [IsFunction, IsTransformation]);
DeclareOperation("AsDigraph", [IsFunction, IsTransformation, IsInt]);
DeclareOperation("AsDigraph", [IsFunction, IsPerm]);
DeclareOperation("AsDigraph", [IsFunction, IsPerm, IsInt]);
DeclareOperation("AsDigraph", [IsFunction, IsPartialPerm]);
DeclareOperation("AsDigraph", [IsFunction, IsPartialPerm, IsInt]);

DeclareOperation("AsDigraph", [IsBinaryRelation]);
DeclareOperation("AsDigraph", [IsTransformation]);
DeclareOperation("AsDigraph", [IsTransformation, IsInt]);
DeclareOperation("AsDigraph", [IsPerm]);
DeclareOperation("AsDigraph", [IsPerm, IsInt]);
DeclareOperation("AsDigraph", [IsPartialPerm]);
DeclareOperation("AsDigraph", [IsPartialPerm, IsInt]);

DeclareOperation("AsBinaryRelation", [IsDigraph]);
DeclareOperation("AsSemigroup", [IsFunction, IsDigraph]);
DeclareOperation("AsMonoid", [IsFunction, IsDigraph]);
DeclareOperation("AsSemigroup",
                 [IsFunction, IsDigraph, IsDenseList, IsDenseList]);

# 10. Random digraphs . . .
DeclareConstructor("RandomDigraphCons", [IsDigraph, IsInt]);
DeclareConstructor("RandomDigraphCons", [IsDigraph, IsInt, IsRat]);
DeclareConstructor("RandomDigraphCons", [IsDigraph, IsInt, IsFloat]);

DeclareOperation("RandomDigraph", [IsInt]);
DeclareOperation("RandomDigraph", [IsInt, IsRat]);
DeclareOperation("RandomDigraph", [IsInt, IsFloat]);
DeclareOperation("RandomDigraph", [IsFunction, IsInt]);
DeclareOperation("RandomDigraph", [IsFunction, IsInt, IsRat]);
DeclareOperation("RandomDigraph", [IsFunction, IsInt, IsFloat]);

DeclareConstructor("RandomTournamentCons", [IsDigraph, IsInt]);
DeclareOperation("RandomTournament", [IsInt]);
DeclareOperation("RandomTournament", [IsFunction, IsInt]);

DeclareConstructor("RandomLatticeCons", [IsDigraph, IsPosInt]);
DeclareOperation("RandomLattice", [IsPosInt]);
DeclareOperation("RandomLattice", [IsFunction, IsPosInt]);

# No mutable analogues of the following because we will withdraw multidigraphs
# in the not-too-distant future!
DeclareOperation("RandomMultiDigraph", [IsPosInt]);
DeclareOperation("RandomMultiDigraph", [IsPosInt, IsPosInt]);
