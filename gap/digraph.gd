#############################################################################
##
##  digraph.gd
##  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# Categories
DeclareCategory("IsDigraph", IsObject);
DeclareCategory("IsDigraphWithAdjacencyFunction", IsDigraph);

DeclareSynonym("IsMutableDigraph", IsDigraph and IsMutable);
DeclareCategory("IsImmutableDigraph", IsDigraph);

DeclareGlobalFunction("IsValidDigraph");

# Family
BindGlobal("DigraphFamily", NewFamily("DigraphFamily", IsDigraph));

# Representations
DeclareRepresentation("IsDenseDigraphRep",
                      IsDigraph and IsComponentObjectRep,
                      ["OutNeighbours"]);

# No check constructors
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

# Copies
DeclareOperation("DigraphMutableCopy", [IsDigraph]);
DeclareOperation("DigraphCopy", [IsDigraph]);
DeclareSynonym("DigraphImmutableCopy", DigraphCopy);
DeclareOperation("DigraphCopyIfMutable", [IsDigraph]);
DeclareOperation("DigraphCopyIfImmutable", [IsDigraph]);

# Converter
DeclareOperation("MakeImmutableDigraph", [IsDigraph]);

# Constructors
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

# Constructors "by" something . . .
DeclareConstructor("DigraphByAdjacencyMatrixCons",
                  [IsDigraph, IsHomogeneousList]);
DeclareConstructor("DigraphByAdjacencyMatrixConsNC",
                   [IsDigraph, IsHomogeneousList]);

DeclareOperation("DigraphByAdjacencyMatrix", [IsFunction, IsHomogeneousList]);
DeclareOperation("DigraphByAdjacencyMatrixNC", [IsFunction, IsHomogeneousList]);

DeclareOperation("DigraphByAdjacencyMatrix", [IsHomogeneousList]);
DeclareOperation("DigraphByAdjacencyMatrixNC", [IsHomogeneousList]);

DeclareConstructor("DigraphByEdgesCons",
                   [IsDigraph, IsList]);
DeclareConstructor("DigraphByEdgesCons",
                   [IsDigraph, IsList, IsInt]);

DeclareOperation("DigraphByEdges", [IsFunction, IsList]);
DeclareOperation("DigraphByEdges", [IsFunction, IsList, IsInt]);
DeclareOperation("DigraphByEdges", [IsList]);
DeclareOperation("DigraphByEdges", [IsList, IsInt]);

DeclareConstructor("DigraphByInNeighboursCons", [IsDigraph, IsList]);
DeclareConstructor("DigraphByInNeighboursConsNC", [IsDigraph, IsList]);

DeclareOperation("DigraphByInNeighbours", [IsFunction, IsList]);
DeclareOperation("DigraphByInNeighbours", [IsList]);

DeclareSynonym("DigraphByInNeighbors", DigraphByInNeighbours);

# Converters to and from other types . . .
DeclareConstructor("AsDigraphCons", [IsDigraph, IsBinaryRelation]);
DeclareConstructor("AsDigraphCons", [IsDigraph, IsTransformation]);
DeclareConstructor("AsDigraphCons", [IsDigraph, IsTransformation, IsInt]);

DeclareOperation("AsDigraph", [IsFunction, IsBinaryRelation]);
DeclareOperation("AsDigraph", [IsFunction, IsTransformation]);
DeclareOperation("AsDigraph", [IsFunction, IsTransformation, IsInt]);

DeclareOperation("AsDigraph", [IsBinaryRelation]);
DeclareOperation("AsDigraph", [IsTransformation]);
DeclareOperation("AsDigraph", [IsTransformation, IsInt]);

DeclareOperation("AsBinaryRelation", [IsDigraph]);
DeclareOperation("AsSemigroup", [IsFunction, IsDigraph]);
DeclareOperation("AsMonoid", [IsFunction, IsDigraph]);

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

# No mutable analogues of the following because we will withdraw multidigraphs
# the not too distant future!
DeclareOperation("RandomMultiDigraph", [IsPosInt]);
DeclareOperation("RandomMultiDigraph", [IsPosInt, IsPosInt]);
