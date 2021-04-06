#############################################################################
##
##  named-digraphs-test-database.g
##  Copyright (C) 2021                        Tom Conti-Leslie
##                                            Reinis Cirpons     
##                                            Murray Whyte    
##                                            Maria Tsalakou     
##                                            Marina Anagnostopoulou-Merkouri
##                                            Lea Racine         
##                                            James D. Mitchell  
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

#############################################################################
# This is the NAMED DIGRAPHS TEST DATABASE.
#
# This is for use only in Digraphs tests. Running this file will
# populate the global Digraphs variable DIGRAPHS_NamedDigraphsTests
# with record components where each name is the name of a "famous" digraph,
# and each value is itself a record indicating the expected output of running
# certain Digraphs functions on the named digraph.
#
# Every named digraph added to the main database must have a corresponding
# entry in this test database, for testing purposes.
#
# See the NAMED DIGRAPHS MAIN DATABASE at
# /data/named-digraphs-main-database.g for more information, as well as the
# documentation on Digraphs(obj) where obj is a string, and the
# documentation on ListNamedDigraphs.
#############################################################################

DIGRAPHS_NamedDigraphsTests.("diamond") := rec(
  DigraphNrEdges := 10,
  DigraphDiameter := 2,
  DigraphNrVertices := 4,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("fork") := rec(
  DigraphNrEdges := 8,
  DigraphDiameter := 3,
  DigraphNrVertices := 5,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("tetrahedral") := rec(
  DigraphNrEdges := 12,
  DigraphDiameter := 1,
  DigraphNrVertices := 4,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("utility") := rec(
  DigraphNrEdges := 18,
  DigraphDiameter := 2,
  DigraphNrVertices := 6,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("twotriangles") := rec(
  DigraphNrEdges := 12,
  DigraphNrVertices := 6,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("sixteencell") := rec(
  DigraphNrEdges := 48,
  DigraphDiameter := 2,
  DigraphNrVertices := 8,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("banner") := rec(
  DigraphNrEdges := 10,
  DigraphDiameter := 3,
  DigraphNrVertices := 5,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("cross") := rec(
  DigraphNrEdges := 10,
  DigraphDiameter := 3,
  DigraphNrVertices := 6,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("octahedral") := rec(
  DigraphNrEdges := 24,
  DigraphDiameter := 2,
  DigraphNrVertices := 6,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("threetriangles") := rec(
  DigraphNrEdges := 18,
  DigraphNrVertices := 9,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("bull") := rec(
  DigraphNrEdges := 10,
  DigraphDiameter := 3,
  DigraphNrVertices := 5,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("hgraph") := rec(
  DigraphNrEdges := 10,
  DigraphDiameter := 3,
  DigraphNrVertices := 6,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("rgraph") := rec(
  DigraphNrEdges := 12,
  DigraphDiameter := 3,
  DigraphNrVertices := 6,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("pentatope") := rec(
  DigraphNrEdges := 20,
  DigraphDiameter := 1,
  DigraphNrVertices := 5,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("longhorn") := rec(
  DigraphNrEdges := 14,
  DigraphDiameter := 5,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("egraph") := rec(
  DigraphNrEdges := 10,
  DigraphDiameter := 4,
  DigraphNrVertices := 6,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("claw") := rec(
  DigraphNrEdges := 6,
  DigraphDiameter := 2,
  DigraphNrVertices := 4,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("net") := rec(
  DigraphNrEdges := 12,
  DigraphDiameter := 3,
  DigraphNrVertices := 6,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("isobutane") := rec(
  DigraphNrEdges := 26,
  DigraphDiameter := 4,
  DigraphNrVertices := 14,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("ethane") := rec(
  DigraphNrEdges := 14,
  DigraphDiameter := 3,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("paw") := rec(
  DigraphNrEdges := 8,
  DigraphDiameter := 2,
  DigraphNrVertices := 4,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("petersen") := rec(
  DigraphNrEdges := 30,
  DigraphDiameter := 2,
  DigraphNrVertices := 10,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("square") := rec(
  DigraphNrEdges := 8,
  DigraphDiameter := 2,
  DigraphNrVertices := 4,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("moserspindle") := rec(
  DigraphNrEdges := 22,
  DigraphDiameter := 2,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("butterfly") := rec(
  DigraphNrEdges := 12,
  DigraphDiameter := 2,
  DigraphNrVertices := 5,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("kite") := rec(
  DigraphNrEdges := 12,
  DigraphDiameter := 3,
  DigraphNrVertices := 5,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("housex") := rec(
  DigraphNrEdges := 16,
  DigraphDiameter := 2,
  DigraphNrVertices := 5,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("eiffeltower") := rec(
  DigraphNrEdges := 14,
  DigraphDiameter := 4,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("fish") := rec(
  DigraphNrEdges := 14,
  DigraphDiameter := 3,
  DigraphNrVertices := 6,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("trianglesquare") := rec(
  DigraphNrEdges := 14,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("agraph") := rec(
  DigraphNrEdges := 12,
  DigraphDiameter := 3,
  DigraphNrVertices := 6,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("antenna") := rec(
  DigraphNrEdges := 14,
  DigraphDiameter := 3,
  DigraphNrVertices := 6,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("balaban10cage") := rec(
  DigraphNrEdges := 210,
  DigraphDiameter := 6,
  DigraphNrVertices := 70,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 10,
);

DIGRAPHS_NamedDigraphsTests.("balaban11cage") := rec(
  DigraphNrEdges := 336,
  DigraphDiameter := 8,
  DigraphNrVertices := 112,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 11,
);

DIGRAPHS_NamedDigraphsTests.("barnettebosaklederberg") := rec(
  DigraphNrEdges := 114,
  DigraphDiameter := 9,
  DigraphNrVertices := 38,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("biggssmith") := rec(
  DigraphNrEdges := 306,
  DigraphDiameter := 7,
  DigraphNrVertices := 102,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 9,
);

DIGRAPHS_NamedDigraphsTests.("bislitcube") := rec(
  DigraphNrEdges := 28,
  DigraphDiameter := 2,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("brinkmann") := rec(
  DigraphNrEdges := 84,
  DigraphDiameter := 3,
  DigraphNrVertices := 21,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("brouwerhaemers") := rec(
  DigraphNrEdges := 1620,
  DigraphDiameter := 2,
  DigraphNrVertices := 81,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("butane") := rec(
  DigraphNrEdges := 26,
  DigraphDiameter := 5,
  DigraphNrVertices := 14,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("celminsswartsnark1") := rec(
  DigraphNrEdges := 78,
  DigraphDiameter := 6,
  DigraphNrVertices := 26,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("celminsswartsnark2") := rec(
  DigraphNrEdges := 78,
  DigraphDiameter := 5,
  DigraphNrVertices := 26,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("chvatal") := rec(
  DigraphNrEdges := 48,
  DigraphDiameter := 2,
  DigraphNrVertices := 12,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("clebsch") := rec(
  DigraphNrEdges := 80,
  DigraphDiameter := 2,
  DigraphNrVertices := 16,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("contiguoususa") := rec(
  DigraphNrEdges := 214,
  DigraphDiameter := 11,
  DigraphNrVertices := 49,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("conwaysmith") := rec(
  DigraphNrEdges := 630,
  DigraphDiameter := 4,
  DigraphNrVertices := 63,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("coxeter") := rec(
  DigraphNrEdges := 84,
  DigraphDiameter := 4,
  DigraphNrVertices := 28,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 7,
);

DIGRAPHS_NamedDigraphsTests.("cremonarichmondconfiguration") := rec(
  DigraphNrEdges := 60,
  DigraphDiameter := 3,
  DigraphNrVertices := 15,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("cricket") := rec(
  DigraphNrEdges := 10,
  DigraphDiameter := 2,
  DigraphNrVertices := 5,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("cubical") := rec(
  DigraphNrEdges := 24,
  DigraphDiameter := 3,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("cuboctahedral") := rec(
  DigraphNrEdges := 48,
  DigraphDiameter := 3,
  DigraphNrVertices := 12,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("dart") := rec(
  DigraphNrEdges := 12,
  DigraphDiameter := 2,
  DigraphNrVertices := 5,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("decane") := rec(
  DigraphNrEdges := 62,
  DigraphDiameter := 11,
  DigraphNrVertices := 32,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("deltoidalhexecontahedral") := rec(
  DigraphNrEdges := 240,
  DigraphDiameter := 8,
  DigraphNrVertices := 62,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("deltoidalicositetrahedral") := rec(
  DigraphNrEdges := 96,
  DigraphDiameter := 6,
  DigraphNrVertices := 26,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("desarguesconfiguration") := rec(
  DigraphNrEdges := 40,
  DigraphDiameter := 2,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("desargues") := rec(
  DigraphNrEdges := 60,
  DigraphDiameter := 5,
  DigraphNrVertices := 20,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("disdyakisdodecahedral") := rec(
  DigraphNrEdges := 144,
  DigraphDiameter := 4,
  DigraphNrVertices := 26,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("disdyakistriacontahedral") := rec(
  DigraphNrEdges := 360,
  DigraphDiameter := 6,
  DigraphNrVertices := 62,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("dodecahedral") := rec(
  DigraphNrEdges := 60,
  DigraphDiameter := 5,
  DigraphNrVertices := 20,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("domino") := rec(
  DigraphNrEdges := 14,
  DigraphDiameter := 3,
  DigraphNrVertices := 6,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("doro") := rec(
  DigraphNrEdges := 816,
  DigraphDiameter := 3,
  DigraphNrVertices := 68,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("doublestarsnark") := rec(
  DigraphNrEdges := 90,
  DigraphDiameter := 4,
  DigraphNrVertices := 30,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("doyle") := rec(
  DigraphNrEdges := 108,
  DigraphDiameter := 3,
  DigraphNrVertices := 27,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("dyck") := rec(
  DigraphNrEdges := 96,
  DigraphDiameter := 5,
  DigraphNrVertices := 32,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("edgeexcisedcoxeter") := rec(
  DigraphNrEdges := 78,
  DigraphDiameter := 4,
  DigraphNrVertices := 26,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("ellinghamhortongraph54") := rec(
  DigraphNrEdges := 162,
  DigraphDiameter := 10,
  DigraphNrVertices := 54,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("ellinghamhortongraph78") := rec(
  DigraphNrEdges := 234,
  DigraphDiameter := 13,
  DigraphNrVertices := 78,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("errera") := rec(
  DigraphNrEdges := 90,
  DigraphDiameter := 4,
  DigraphNrVertices := 17,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("faulkneryoungergraph42") := rec(
  DigraphNrEdges := 126,
  DigraphDiameter := 9,
  DigraphNrVertices := 42,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("faulkneryoungergraph44") := rec(
  DigraphNrEdges := 132,
  DigraphDiameter := 9,
  DigraphNrVertices := 44,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("fivesquares") := rec(
  DigraphNrEdges := 40,
  DigraphNrVertices := 20,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("fivetriangles") := rec(
  DigraphNrEdges := 30,
  DigraphNrVertices := 15,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("folkman") := rec(
  DigraphNrEdges := 80,
  DigraphDiameter := 4,
  DigraphNrVertices := 20,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("foursquares") := rec(
  DigraphNrEdges := 32,
  DigraphNrVertices := 16,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("fourtriangles") := rec(
  DigraphNrEdges := 24,
  DigraphNrVertices := 12,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("franklin") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 3,
  DigraphNrVertices := 12,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("fritsch") := rec(
  DigraphNrEdges := 42,
  DigraphDiameter := 2,
  DigraphNrVertices := 9,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("frucht") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 4,
  DigraphNrVertices := 12,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("gardner") := rec(
  DigraphNrEdges := 662,
  DigraphDiameter := 20,
  DigraphNrVertices := 222,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("gem") := rec(
  DigraphNrEdges := 14,
  DigraphDiameter := 2,
  DigraphNrVertices := 5,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("georges") := rec(
  DigraphNrEdges := 150,
  DigraphDiameter := 11,
  DigraphNrVertices := 50,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("gewirtzbipartitedouble") := rec(
  DigraphNrEdges := 1120,
  DigraphDiameter := 5,
  DigraphNrVertices := 112,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("gewirtzcone") := rec(
  DigraphNrEdges := 672,
  DigraphDiameter := 2,
  DigraphNrVertices := 57,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("gewirtz") := rec(
  DigraphNrEdges := 560,
  DigraphDiameter := 2,
  DigraphNrVertices := 56,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("goldnerharary") := rec(
  DigraphNrEdges := 54,
  DigraphDiameter := 2,
  DigraphNrVertices := 11,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("golomb") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 3,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("gosset") := rec(
  DigraphNrEdges := 1512,
  DigraphDiameter := 3,
  DigraphNrVertices := 56,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("graphcartesianproductofk33andk3") := rec(
  DigraphNrEdges := 90,
  DigraphDiameter := 3,
  DigraphNrVertices := 18,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("grayconfigurationmengerdual") := rec(
  DigraphNrEdges := 162,
  DigraphDiameter := 3,
  DigraphNrVertices := 27,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("gray") := rec(
  DigraphNrEdges := 162,
  DigraphDiameter := 6,
  DigraphNrVertices := 54,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 8,
);

DIGRAPHS_NamedDigraphsTests.("greatrhombicosidodecahedral") := rec(
  DigraphNrEdges := 360,
  DigraphDiameter := 15,
  DigraphNrVertices := 120,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("greatrhombicuboctahedral") := rec(
  DigraphNrEdges := 144,
  DigraphDiameter := 9,
  DigraphNrVertices := 48,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("grinberggraph42") := rec(
  DigraphNrEdges := 126,
  DigraphDiameter := 7,
  DigraphNrVertices := 42,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("grinberggraph44") := rec(
  DigraphNrEdges := 132,
  DigraphDiameter := 8,
  DigraphNrVertices := 44,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("grinberggraph46") := rec(
  DigraphNrEdges := 138,
  DigraphDiameter := 8,
  DigraphNrVertices := 46,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("groetzsch") := rec(
  DigraphNrEdges := 40,
  DigraphDiameter := 2,
  DigraphNrVertices := 11,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("gruenbaumgraph121") := rec(
  DigraphNrEdges := 360,
  DigraphDiameter := 15,
  DigraphNrVertices := 121,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("gruenbaumgraph124") := rec(
  DigraphNrEdges := 372,
  DigraphDiameter := 15,
  DigraphNrVertices := 124,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("gruenbaumgraph25") := rec(
  DigraphNrEdges := 100,
  DigraphDiameter := 4,
  DigraphNrVertices := 25,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("halljanko") := rec(
  DigraphNrEdges := 3600,
  DigraphDiameter := 2,
  DigraphNrVertices := 100,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("halvedfoster") := rec(
  DigraphNrEdges := 270,
  DigraphDiameter := 4,
  DigraphNrVertices := 45,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("harborth") := rec(
  DigraphNrEdges := 208,
  DigraphDiameter := 9,
  DigraphNrVertices := 52,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("harries") := rec(
  DigraphNrEdges := 210,
  DigraphDiameter := 6,
  DigraphNrVertices := 70,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 10,
);

DIGRAPHS_NamedDigraphsTests.("harrieswong") := rec(
  DigraphNrEdges := 210,
  DigraphDiameter := 6,
  DigraphNrVertices := 70,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 10,
);

DIGRAPHS_NamedDigraphsTests.("hatzel") := rec(
  DigraphNrEdges := 176,
  DigraphDiameter := 8,
  DigraphNrVertices := 57,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("heawoodfourcolor") := rec(
  DigraphNrEdges := 138,
  DigraphDiameter := 5,
  DigraphNrVertices := 25,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("heawood") := rec(
  DigraphNrEdges := 42,
  DigraphDiameter := 3,
  DigraphNrVertices := 14,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("heptane") := rec(
  DigraphNrEdges := 44,
  DigraphDiameter := 8,
  DigraphNrVertices := 23,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("herschel") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 4,
  DigraphNrVertices := 11,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("hexane") := rec(
  DigraphNrEdges := 38,
  DigraphDiameter := 7,
  DigraphNrVertices := 20,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("higmansimsbipartitedouble") := rec(
  DigraphNrEdges := 4400,
  DigraphDiameter := 5,
  DigraphNrVertices := 200,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("higmansims") := rec(
  DigraphNrEdges := 2200,
  DigraphDiameter := 2,
  DigraphNrVertices := 100,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("hoffman") := rec(
  DigraphNrEdges := 64,
  DigraphDiameter := 4,
  DigraphNrVertices := 16,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("hoffmansingletonbipartitedouble") := rec(
  DigraphNrEdges := 700,
  DigraphDiameter := 5,
  DigraphNrVertices := 100,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("hoffmansingletoncomplement") := rec(
  DigraphNrEdges := 2100,
  DigraphDiameter := 2,
  DigraphNrVertices := 50,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("hoffmansingleton") := rec(
  DigraphNrEdges := 350,
  DigraphDiameter := 2,
  DigraphNrVertices := 50,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("hoffmansingletonline") := rec(
  DigraphNrEdges := 2100,
  DigraphDiameter := 3,
  DigraphNrVertices := 175,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("hoffmansingletonminusstar") := rec(
  DigraphNrEdges := 252,
  DigraphDiameter := 3,
  DigraphNrVertices := 42,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("hortongraph92") := rec(
  DigraphNrEdges := 276,
  DigraphDiameter := 12,
  DigraphNrVertices := 92,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("hortongraph96") := rec(
  DigraphNrEdges := 288,
  DigraphDiameter := 10,
  DigraphNrVertices := 96,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("house") := rec(
  DigraphNrEdges := 12,
  DigraphDiameter := 2,
  DigraphNrVertices := 5,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("icosahedral") := rec(
  DigraphNrEdges := 60,
  DigraphDiameter := 3,
  DigraphNrVertices := 12,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("icosahedralline") := rec(
  DigraphNrEdges := 240,
  DigraphDiameter := 3,
  DigraphNrVertices := 30,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("icosidodecahedral") := rec(
  DigraphNrEdges := 120,
  DigraphDiameter := 5,
  DigraphNrVertices := 30,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("kittell") := rec(
  DigraphNrEdges := 126,
  DigraphDiameter := 4,
  DigraphNrVertices := 23,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("kleindistance2") := rec(
  DigraphNrEdges := 336,
  DigraphDiameter := 2,
  DigraphNrVertices := 24,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("klein") := rec(
  DigraphNrEdges := 168,
  DigraphDiameter := 3,
  DigraphNrVertices := 24,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("krackhardtkite") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 4,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("kroneckerproductoficosahedralgraphcomplementandonesmatrixj2") := rec(
  DigraphNrEdges := 288,
  DigraphDiameter := 2,
  DigraphNrVertices := 24,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("kroneckerproductofpetersenlinegraphcomplementandonesmatrixj2") := rec(
  DigraphNrEdges := 600,
  DigraphDiameter := 2,
  DigraphNrVertices := 30,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("kummer") := rec(
  DigraphNrEdges := 192,
  DigraphDiameter := 3,
  DigraphNrVertices := 32,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("levi") := rec(
  DigraphNrEdges := 90,
  DigraphDiameter := 4,
  DigraphNrVertices := 30,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 8,
);

DIGRAPHS_NamedDigraphsTests.("ljubljana") := rec(
  DigraphNrEdges := 336,
  DigraphDiameter := 8,
  DigraphNrVertices := 112,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 10,
);

DIGRAPHS_NamedDigraphsTests.("localmclaughlin") := rec(
  DigraphNrEdges := 9072,
  DigraphDiameter := 2,
  DigraphNrVertices := 162,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("loupekinessnark1") := rec(
  DigraphNrEdges := 66,
  DigraphDiameter := 4,
  DigraphNrVertices := 22,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("loupekinessnark2") := rec(
  DigraphNrEdges := 66,
  DigraphDiameter := 4,
  DigraphNrVertices := 22,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("m22bipartitedouble") := rec(
  DigraphNrEdges := 2464,
  DigraphDiameter := 5,
  DigraphNrVertices := 154,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("m22") := rec(
  DigraphNrEdges := 1232,
  DigraphDiameter := 2,
  DigraphNrVertices := 77,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("mcgee") := rec(
  DigraphNrEdges := 72,
  DigraphDiameter := 4,
  DigraphNrVertices := 24,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 7,
);

DIGRAPHS_NamedDigraphsTests.("meredith") := rec(
  DigraphNrEdges := 280,
  DigraphDiameter := 8,
  DigraphNrVertices := 70,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("meringer") := rec(
  DigraphNrEdges := 150,
  DigraphDiameter := 3,
  DigraphNrVertices := 30,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("moebiuskantor") := rec(
  DigraphNrEdges := 48,
  DigraphDiameter := 4,
  DigraphNrVertices := 16,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("moth") := rec(
  DigraphNrEdges := 14,
  DigraphDiameter := 2,
  DigraphNrVertices := 6,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("nauru") := rec(
  DigraphNrEdges := 72,
  DigraphDiameter := 4,
  DigraphNrVertices := 24,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("nonane") := rec(
  DigraphNrEdges := 56,
  DigraphDiameter := 10,
  DigraphNrVertices := 29,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("nonuniquelythreecolorablegraph1") := rec(
  DigraphNrEdges := 44,
  DigraphDiameter := 3,
  DigraphNrVertices := 12,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("nonuniquelythreecolorablegraph2") := rec(
  DigraphNrEdges := 40,
  DigraphDiameter := 3,
  DigraphNrVertices := 12,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("noperfectmatching") := rec(
  DigraphNrEdges := 54,
  DigraphDiameter := 6,
  DigraphNrVertices := 16,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("octane") := rec(
  DigraphNrEdges := 50,
  DigraphDiameter := 9,
  DigraphNrVertices := 26,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("pappus") := rec(
  DigraphNrEdges := 54,
  DigraphDiameter := 4,
  DigraphNrVertices := 18,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("parachute") := rec(
  DigraphNrEdges := 24,
  DigraphDiameter := 3,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("parapluie") := rec(
  DigraphNrEdges := 18,
  DigraphDiameter := 3,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("pasch") := rec(
  DigraphNrEdges := 24,
  DigraphDiameter := 4,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("pentagonalhexecontahedral") := rec(
  DigraphNrEdges := 300,
  DigraphDiameter := 10,
  DigraphNrVertices := 92,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("pentagonalicositetrahedral") := rec(
  DigraphNrEdges := 120,
  DigraphDiameter := 7,
  DigraphNrVertices := 38,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("pentakisdodecahedral") := rec(
  DigraphNrEdges := 180,
  DigraphDiameter := 5,
  DigraphNrVertices := 32,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("pentane") := rec(
  DigraphNrEdges := 32,
  DigraphDiameter := 6,
  DigraphNrVertices := 17,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("perkel") := rec(
  DigraphNrEdges := 342,
  DigraphDiameter := 3,
  DigraphNrVertices := 57,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("petersencone") := rec(
  DigraphNrEdges := 50,
  DigraphDiameter := 2,
  DigraphNrVertices := 11,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("pgammau34onnonisotropicpoints") := rec(
  DigraphNrEdges := 2496,
  DigraphDiameter := 3,
  DigraphNrVertices := 208,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("poussin") := rec(
  DigraphNrEdges := 78,
  DigraphDiameter := 3,
  DigraphNrVertices := 15,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("propane") := rec(
  DigraphNrEdges := 20,
  DigraphDiameter := 4,
  DigraphNrVertices := 11,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("reye") := rec(
  DigraphNrEdges := 144,
  DigraphDiameter := 3,
  DigraphNrVertices := 24,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("reyeline") := rec(
  DigraphNrEdges := 96,
  DigraphDiameter := 4,
  DigraphNrVertices := 28,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("rhombicdodecahedral") := rec(
  DigraphNrEdges := 48,
  DigraphDiameter := 4,
  DigraphNrVertices := 14,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("rhombictriacontahedral") := rec(
  DigraphNrEdges := 120,
  DigraphDiameter := 6,
  DigraphNrVertices := 32,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("risingsun") := rec(
  DigraphNrEdges := 24,
  DigraphDiameter := 3,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("robertson") := rec(
  DigraphNrEdges := 76,
  DigraphDiameter := 3,
  DigraphNrVertices := 19,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("robertsonwegner") := rec(
  DigraphNrEdges := 150,
  DigraphDiameter := 3,
  DigraphNrVertices := 30,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("rollingcube") := rec(
  DigraphNrEdges := 96,
  DigraphDiameter := 4,
  DigraphNrVertices := 24,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("roylegraph1") := rec(
  DigraphNrEdges := 34,
  DigraphDiameter := 2,
  DigraphNrVertices := 8,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("roylegraph2") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 2,
  DigraphNrVertices := 8,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("schlaeflidoublesixes") := rec(
  DigraphNrEdges := 120,
  DigraphDiameter := 6,
  DigraphNrVertices := 42,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 8,
);

DIGRAPHS_NamedDigraphsTests.("schlaefli") := rec(
  DigraphNrEdges := 432,
  DigraphDiameter := 2,
  DigraphNrVertices := 27,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("selfdualgraph1") := rec(
  DigraphNrEdges := 24,
  DigraphDiameter := 2,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("selfdualgraph2") := rec(
  DigraphNrEdges := 24,
  DigraphDiameter := 2,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("selfdualgraph3") := rec(
  DigraphNrEdges := 24,
  DigraphDiameter := 2,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("shrikhande") := rec(
  DigraphNrEdges := 96,
  DigraphDiameter := 2,
  DigraphNrVertices := 16,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("singleton") := rec(
  DigraphNrEdges := 0,
  DigraphDiameter := 0,
  DigraphNrVertices := 1,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
);

DIGRAPHS_NamedDigraphsTests.("sixhundredcell") := rec(
  DigraphNrEdges := 1440,
  DigraphDiameter := 5,
  DigraphNrVertices := 120,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("smallestcyclicgroup") := rec(
  DigraphNrEdges := 30,
  DigraphDiameter := 3,
  DigraphNrVertices := 9,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("smallrhombicosidodecahedral") := rec(
  DigraphNrEdges := 240,
  DigraphDiameter := 8,
  DigraphNrVertices := 60,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("smallrhombicuboctahedral") := rec(
  DigraphNrEdges := 96,
  DigraphDiameter := 5,
  DigraphNrVertices := 24,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("smalltriakisoctahedral") := rec(
  DigraphNrEdges := 72,
  DigraphDiameter := 3,
  DigraphNrVertices := 14,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("snubcubical") := rec(
  DigraphNrEdges := 120,
  DigraphDiameter := 4,
  DigraphNrVertices := 24,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("snubdodecahedral") := rec(
  DigraphNrEdges := 300,
  DigraphDiameter := 7,
  DigraphNrVertices := 60,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("soifer") := rec(
  DigraphNrEdges := 40,
  DigraphDiameter := 2,
  DigraphNrVertices := 9,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("sousselier") := rec(
  DigraphNrEdges := 54,
  DigraphDiameter := 3,
  DigraphNrVertices := 16,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("squarehexagon") := rec(
  DigraphNrEdges := 20,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("squarepentagon") := rec(
  DigraphNrEdges := 18,
  DigraphNrVertices := 9,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("sylvester") := rec(
  DigraphNrEdges := 180,
  DigraphDiameter := 3,
  DigraphNrVertices := 36,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("szekeressnark") := rec(
  DigraphNrEdges := 150,
  DigraphDiameter := 7,
  DigraphNrVertices := 50,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("tesseract") := rec(
  DigraphNrEdges := 64,
  DigraphDiameter := 4,
  DigraphNrVertices := 16,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("tetrakishexahedral") := rec(
  DigraphNrEdges := 72,
  DigraphDiameter := 3,
  DigraphNrVertices := 14,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("thetazero") := rec(
  DigraphNrEdges := 16,
  DigraphDiameter := 3,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("thomassengraph105") := rec(
  DigraphNrEdges := 340,
  DigraphDiameter := 9,
  DigraphNrVertices := 105,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("thomassengraph20") := rec(
  DigraphNrEdges := 66,
  DigraphDiameter := 4,
  DigraphNrVertices := 20,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("thomassengraph32") := rec(
  DigraphNrEdges := 106,
  DigraphDiameter := 6,
  DigraphNrVertices := 32,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("thomassengraph34") := rec(
  DigraphNrEdges := 104,
  DigraphDiameter := 7,
  DigraphNrVertices := 34,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("thomassengraph41") := rec(
  DigraphNrEdges := 128,
  DigraphDiameter := 8,
  DigraphNrVertices := 41,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("thomassengraph60") := rec(
  DigraphNrEdges := 198,
  DigraphDiameter := 8,
  DigraphNrVertices := 60,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("thomassengraph94") := rec(
  DigraphNrEdges := 282,
  DigraphDiameter := 12,
  DigraphNrVertices := 94,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("threehexagons") := rec(
  DigraphNrEdges := 36,
  DigraphNrVertices := 18,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("threepentagons") := rec(
  DigraphNrEdges := 30,
  DigraphNrVertices := 15,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("threesquares") := rec(
  DigraphNrEdges := 24,
  DigraphNrVertices := 12,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("tietzes") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 3,
  DigraphNrVertices := 12,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("triakisicosahedral") := rec(
  DigraphNrEdges := 180,
  DigraphDiameter := 4,
  DigraphNrVertices := 32,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("triakistetrahedral") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 2,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("triangle") := rec(
  DigraphNrEdges := 6,
  DigraphDiameter := 1,
  DigraphNrVertices := 3,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("triangleheptagon") := rec(
  DigraphNrEdges := 20,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("trianglehexagon") := rec(
  DigraphNrEdges := 18,
  DigraphNrVertices := 9,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("trianglepentagon") := rec(
  DigraphNrEdges := 16,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("trianglereplacedcoxeter") := rec(
  DigraphNrEdges := 252,
  DigraphDiameter := 9,
  DigraphNrVertices := 84,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("truncatedcubical") := rec(
  DigraphNrEdges := 72,
  DigraphDiameter := 6,
  DigraphNrVertices := 24,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("truncateddodecahedral") := rec(
  DigraphNrEdges := 180,
  DigraphDiameter := 10,
  DigraphNrVertices := 60,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("truncatedicosahedral") := rec(
  DigraphNrEdges := 180,
  DigraphDiameter := 9,
  DigraphNrVertices := 60,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("truncatedoctahedral") := rec(
  DigraphNrEdges := 72,
  DigraphDiameter := 6,
  DigraphNrVertices := 24,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("truncatedprism") := rec(
  DigraphNrEdges := 54,
  DigraphDiameter := 5,
  DigraphNrVertices := 18,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("truncatedtetrahedral") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 3,
  DigraphNrVertices := 12,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("tutte12cage") := rec(
  DigraphNrEdges := 378,
  DigraphDiameter := 6,
  DigraphNrVertices := 126,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 12,
);

DIGRAPHS_NamedDigraphsTests.("tuttes") := rec(
  DigraphNrEdges := 138,
  DigraphDiameter := 8,
  DigraphNrVertices := 46,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("twentyfourcell") := rec(
  DigraphNrEdges := 192,
  DigraphDiameter := 3,
  DigraphNrVertices := 24,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("twocubes") := rec(
  DigraphNrEdges := 48,
  DigraphNrVertices := 16,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("twodecagons") := rec(
  DigraphNrEdges := 40,
  DigraphNrVertices := 20,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 10,
);

DIGRAPHS_NamedDigraphsTests.("twoheptagons") := rec(
  DigraphNrEdges := 28,
  DigraphNrVertices := 14,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 7,
);

DIGRAPHS_NamedDigraphsTests.("twohexagons") := rec(
  DigraphNrEdges := 24,
  DigraphNrVertices := 12,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("twooctagons") := rec(
  DigraphNrEdges := 32,
  DigraphNrVertices := 16,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 8,
);

DIGRAPHS_NamedDigraphsTests.("twopentagons") := rec(
  DigraphNrEdges := 20,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("twosquares") := rec(
  DigraphNrEdges := 16,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("twotrianglessquare") := rec(
  DigraphNrEdges := 20,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("u33") := rec(
  DigraphNrEdges := 504,
  DigraphDiameter := 2,
  DigraphNrVertices := 36,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("uniquelythreecolorable") := rec(
  DigraphNrEdges := 44,
  DigraphDiameter := 3,
  DigraphNrVertices := 12,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("walther") := rec(
  DigraphNrEdges := 62,
  DigraphDiameter := 8,
  DigraphNrVertices := 25,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("watkinssnark") := rec(
  DigraphNrEdges := 150,
  DigraphDiameter := 7,
  DigraphNrVertices := 50,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("wells") := rec(
  DigraphNrEdges := 160,
  DigraphDiameter := 4,
  DigraphNrVertices := 32,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("wieneraraya") := rec(
  DigraphNrEdges := 134,
  DigraphDiameter := 7,
  DigraphNrVertices := 42,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("wong") := rec(
  DigraphNrEdges := 150,
  DigraphDiameter := 3,
  DigraphNrVertices := 30,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("zamfirescugraph36") := rec(
  DigraphNrEdges := 108,
  DigraphDiameter := 7,
  DigraphNrVertices := 36,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("zamfirescugraph48") := rec(
  DigraphNrEdges := 152,
  DigraphDiameter := 7,
  DigraphNrVertices := 48,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("zamfirescugraph75") := rec(
  DigraphNrEdges := 240,
  DigraphDiameter := 9,
  DigraphNrVertices := 75,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("9-lace-1-14-13-13-13-1-13-13-13") := rec(
  DigraphNrEdges := 198,
  DigraphDiameter := 3,
  DigraphNrVertices := 34,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("kalbfleisch") := rec(
  DigraphNrEdges := 280,
  DigraphDiameter := 2,
  DigraphNrVertices := 35,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("pointgraphofsplitcayleyhexagonh(2)") := rec(
  DigraphNrEdges := 378,
  DigraphDiameter := 3,
  DigraphNrVertices := 63,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("changgraph1") := rec(
  DigraphNrEdges := 336,
  DigraphDiameter := 2,
  DigraphNrVertices := 28,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("changgraph2") := rec(
  DigraphNrEdges := 336,
  DigraphDiameter := 2,
  DigraphNrVertices := 28,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("changgraph3") := rec(
  DigraphNrEdges := 336,
  DigraphDiameter := 2,
  DigraphNrVertices := 28,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("bidiakiscube") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 3,
  DigraphNrVertices := 12,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("counterexample") := rec(
  DigraphNrEdges := 66,
  DigraphDiameter := 3,
  DigraphNrVertices := 12,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("orthogonalitygraphofmagiccube") := rec(
  DigraphNrEdges := 48,
  DigraphDiameter := 2,
  DigraphNrVertices := 13,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("gapbetweenschrijver,lovasz,szegedy") := rec(
  DigraphNrEdges := 24,
  DigraphDiameter := 3,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("bipartiteclassic") := rec(
  DigraphNrEdges := 8,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("w(3)") := rec(
  DigraphNrEdges := 480,
  DigraphDiameter := 2,
  DigraphNrVertices := 40,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("q4(3)") := rec(
  DigraphNrEdges := 480,
  DigraphDiameter := 2,
  DigraphNrVertices := 40,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("kapnigsbergbridges,vertexforeachbridgeandeachlandarea") := rec(
  DigraphNrEdges := 28,
  DigraphDiameter := 4,
  DigraphNrVertices := 11,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("kapnigsbergbridges,vertexforeachbridge") := rec(
  DigraphNrEdges := 34,
  DigraphDiameter := 2,
  DigraphNrVertices := 7,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("kapnigsbergbridges,vertexateachbridgeend,landascliques") := rec(
  DigraphNrEdges := 52,
  DigraphDiameter := 4,
  DigraphNrVertices := 14,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("trellis") := rec(
  DigraphNrEdges := 42,
  DigraphDiameter := 4,
  DigraphNrVertices := 14,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("hamptoncourtmaze") := rec(
  DigraphNrEdges := 30,
  DigraphDiameter := 8,
  DigraphNrVertices := 15,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("hamptoncourtmaze,twoislands") := rec(
  DigraphNrEdges := 28,
  DigraphDiameter := 8,
  DigraphNrVertices := 13,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("beinekenon-linegraphg7") := rec(
  DigraphNrEdges := 16,
  DigraphDiameter := 2,
  DigraphNrVertices := 6,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("beinekenon-linegraphg8") := rec(
  DigraphNrEdges := 18,
  DigraphDiameter := 3,
  DigraphNrVertices := 6,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("beinekenon-linegraphg5") := rec(
  DigraphNrEdges := 18,
  DigraphDiameter := 3,
  DigraphNrVertices := 6,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("aolta(c)snon-linegraphh1") := rec(
  DigraphNrEdges := 22,
  DigraphDiameter := 3,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("aolta(c)snon-linegraphh2") := rec(
  DigraphNrEdges := 24,
  DigraphDiameter := 3,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("aolta(c)snon-linegraphh3") := rec(
  DigraphNrEdges := 30,
  DigraphDiameter := 3,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("aolta(c)snon-linegraphj2") := rec(
  DigraphNrEdges := 22,
  DigraphDiameter := 4,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("aolta(c)snon-linegraphj3") := rec(
  DigraphNrEdges := 20,
  DigraphDiameter := 3,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("thomassen24non-planarcubichypohamiltonian") := rec(
  DigraphNrEdges := 72,
  DigraphDiameter := 5,
  DigraphNrVertices := 24,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("treewiener(g)=wiener(l(l(g)))") := rec(
  DigraphNrEdges := 16,
  DigraphDiameter := 5,
  DigraphNrVertices := 9,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("treewiener(g)=wiener(l(l(g)))") := rec(
  DigraphNrEdges := 18,
  DigraphDiameter := 6,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("treewiener(g)=wiener(l(l(g)))") := rec(
  DigraphNrEdges := 20,
  DigraphDiameter := 6,
  DigraphNrVertices := 11,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("treecontainingall5-edgesubtrees") := rec(
  DigraphNrEdges := 18,
  DigraphDiameter := 5,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("tricorn") := rec(
  DigraphNrEdges := 30,
  DigraphDiameter := 3,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("subgraphrelationsamongbeinekesnon-linegraphs") := rec(
  DigraphNrEdges := 40,
  DigraphDiameter := 2,
  DigraphNrVertices := 9,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("rocket") := rec(
  DigraphNrEdges := 14,
  DigraphDiameter := 3,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("subgraphrelationsamongall4-vertexgraphs,1edgedelta") := rec(
  DigraphNrEdges := 28,
  DigraphDiameter := 6,
  DigraphNrVertices := 11,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("complementofsubgraphrelationsamongall4-vertexgraphs") := rec(
  DigraphNrEdges := 18,
  DigraphNrVertices := 11,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("tesseractinducedsubgraph,distance<=2fromonecorner") := rec(
  DigraphNrEdges := 32,
  DigraphDiameter := 4,
  DigraphNrVertices := 11,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("cubeplex") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 3,
  DigraphNrVertices := 12,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("twinplex") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 3,
  DigraphNrVertices := 12,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("ramseycomponent") := rec(
  DigraphNrEdges := 40,
  DigraphDiameter := 3,
  DigraphNrVertices := 12,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("3triangles,connectedtofirst") := rec(
  DigraphNrEdges := 22,
  DigraphDiameter := 4,
  DigraphNrVertices := 9,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("gosperisland2") := rec(
  DigraphNrEdges := 348,
  DigraphDiameter := 19,
  DigraphNrVertices := 126,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("triangle-replacedpetersen,ct66") := rec(
  DigraphNrEdges := 90,
  DigraphDiameter := 5,
  DigraphNrVertices := 30,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("smallestpseudosimilar") := rec(
  DigraphNrEdges := 18,
  DigraphDiameter := 5,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("vertexremovalofsmallestpseudosimilar") := rec(
  DigraphNrEdges := 12,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("pseudosimilarfromthreek4-e") := rec(
  DigraphNrEdges := 20,
  DigraphDiameter := 4,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("fourcolouraprilfoolshoax") := rec(
  DigraphNrEdges := 648,
  DigraphDiameter := 10,
  DigraphNrVertices := 110,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("linegraphn=8pseudosimilarmostedges") := rec(
  DigraphNrEdges := 34,
  DigraphDiameter := 2,
  DigraphNrVertices := 8,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("linegraphn=8pseudosimilarsecondmostedges") := rec(
  DigraphNrEdges := 24,
  DigraphDiameter := 3,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("linegraphn=8pseudosimilarsecondfewestedges") := rec(
  DigraphNrEdges := 20,
  DigraphDiameter := 4,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("quartettree2") := rec(
  DigraphNrEdges := 50,
  DigraphDiameter := 12,
  DigraphNrVertices := 26,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("quartettree3") := rec(
  DigraphNrEdges := 250,
  DigraphDiameter := 36,
  DigraphNrVertices := 126,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("as4s4molecular") := rec(
  DigraphNrEdges := 20,
  DigraphDiameter := 3,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("self-complementarygraphwithintegralspectrum") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 2,
  DigraphNrVertices := 9,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("(3,3)-graphwith20vertices") := rec(
  DigraphNrEdges := 60,
  DigraphDiameter := 3,
  DigraphNrVertices := 20,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("circulant17steps1,2,4,8") := rec(
  DigraphNrEdges := 136,
  DigraphDiameter := 2,
  DigraphNrVertices := 17,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("alternateterdragon2") := rec(
  DigraphNrEdges := 18,
  DigraphDiameter := 3,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("alternateterdragon3") := rec(
  DigraphNrEdges := 54,
  DigraphDiameter := 7,
  DigraphNrVertices := 18,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("sevensegmentleddigits,immediatesubsets,7withoutleft,9withlow") := rec(
  DigraphNrEdges := 24,
  DigraphDiameter := 4,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("distancepalindromictree21") := rec(
  DigraphNrEdges := 40,
  DigraphDiameter := 8,
  DigraphNrVertices := 21,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("doubleladderofdesa!etal") := rec(
  DigraphNrEdges := 60,
  DigraphDiameter := 8,
  DigraphNrVertices := 23,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("subtreerelationsofasymmetrictreesn<=10") := rec(
  DigraphNrEdges := 28,
  DigraphDiameter := 4,
  DigraphNrVertices := 11,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("subtreerelationsofasymmetrictreesn<=11") := rec(
  DigraphNrEdges := 84,
  DigraphDiameter := 6,
  DigraphNrVertices := 26,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("windmilltreeofdesa!etal") := rec(
  DigraphNrEdges := 40,
  DigraphDiameter := 6,
  DigraphNrVertices := 21,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("threeplugtreeofdesa!etal") := rec(
  DigraphNrEdges := 62,
  DigraphDiameter := 8,
  DigraphNrVertices := 32,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("mostminimaldominatingsets8,connected") := rec(
  DigraphNrEdges := 28,
  DigraphDiameter := 2,
  DigraphNrVertices := 8,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("mostminimaldominatingsets9,connected,18edges") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 2,
  DigraphNrVertices := 9,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("mostminimaldominatingsets9,connected,19edges") := rec(
  DigraphNrEdges := 38,
  DigraphDiameter := 2,
  DigraphNrVertices := 9,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("mostminimaldominatingsets9,connected,20edges") := rec(
  DigraphNrEdges := 40,
  DigraphDiameter := 2,
  DigraphNrVertices := 9,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("mostminimaldominatingsets9") := rec(
  DigraphNrEdges := 22,
  DigraphNrVertices := 9,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("mostminimaldominatingsets10,connected") := rec(
  DigraphNrEdges := 32,
  DigraphDiameter := 5,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("mostminimaldominatingsets10") := rec(
  DigraphNrEdges := 32,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("4-cycleswithvertexbetween") := rec(
  DigraphNrEdges := 20,
  DigraphDiameter := 6,
  DigraphNrVertices := 9,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("mapofsumofcubes5") := rec(
  DigraphNrEdges := 280,
  DigraphDiameter := 10,
  DigraphNrVertices := 60,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("mostminimaldominatingsets,11,connected,19edges") := rec(
  DigraphNrEdges := 38,
  DigraphDiameter := 5,
  DigraphNrVertices := 11,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("mostminimaldominatingsets,11,connected,21edges") := rec(
  DigraphNrEdges := 42,
  DigraphDiameter := 4,
  DigraphNrVertices := 11,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("mostminimaldominatingsets11") := rec(
  DigraphNrEdges := 38,
  DigraphNrVertices := 11,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("nodisjointminimumdominatingsetsthoughnovertexcommontoall,19") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 8,
  DigraphNrVertices := 19,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("nodisjointminimumdominatingsetsthoughnovertexcommontoall,16") := rec(
  DigraphNrEdges := 30,
  DigraphDiameter := 8,
  DigraphNrVertices := 16,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("subdividedbi-stars4,5and4,4connectedat4-starmiddles") := rec(
  DigraphNrEdges := 62,
  DigraphDiameter := 9,
  DigraphNrVertices := 32,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("twosubdividedbi-star4,5connectedat4-starmiddles") := rec(
  DigraphNrEdges := 66,
  DigraphDiameter := 9,
  DigraphNrVertices := 34,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("twosubdividedbi-star4,5connectedat5-starmiddles") := rec(
  DigraphNrEdges := 66,
  DigraphDiameter := 9,
  DigraphNrVertices := 34,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("3-regularmatchnumber(4n-1)/9,n=34") := rec(
  DigraphNrEdges := 102,
  DigraphDiameter := 8,
  DigraphNrVertices := 34,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("3-regularmatchnumber(4n-1)/9,n=88") := rec(
  DigraphNrEdges := 264,
  DigraphDiameter := 14,
  DigraphNrVertices := 88,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("planar4-connectednonpancyclic") := rec(
  DigraphNrEdges := 118,
  DigraphDiameter := 5,
  DigraphNrVertices := 30,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("bridgelesswhosesquareisnonhamiltonian") := rec(
  DigraphNrEdges := 90,
  DigraphDiameter := 6,
  DigraphNrVertices := 31,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("doyle") := rec(
  DigraphNrEdges := 90,
  DigraphDiameter := 4,
  DigraphNrVertices := 27,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("levy") := rec(
  DigraphNrEdges := 90,
  DigraphDiameter := 5,
  DigraphNrVertices := 30,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("bistar3,4withextramiddlevertex") := rec(
  DigraphNrEdges := 14,
  DigraphDiameter := 4,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("mostmaximummatchings,tree181") := rec(
  DigraphNrEdges := 360,
  DigraphDiameter := 28,
  DigraphNrVertices := 181,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("mostmaximummatchingstree34") := rec(
  DigraphNrEdges := 66,
  DigraphDiameter := 10,
  DigraphNrVertices := 34,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("mostmaximummatchingstree34other") := rec(
  DigraphNrEdges := 66,
  DigraphDiameter := 10,
  DigraphNrVertices := 34,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("dogsbone1,3,1,1,3") := rec(
  DigraphNrEdges := 18,
  DigraphDiameter := 7,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("dogsbone1,1,1,2,4") := rec(
  DigraphNrEdges := 18,
  DigraphDiameter := 6,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("twindragonareatree5") := rec(
  DigraphNrEdges := 62,
  DigraphDiameter := 17,
  DigraphNrVertices := 32,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("disjointdominationnumbermostways,tree12") := rec(
  DigraphNrEdges := 22,
  DigraphDiameter := 6,
  DigraphNrVertices := 12,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("path7withleaves3,4") := rec(
  DigraphNrEdges := 16,
  DigraphDiameter := 6,
  DigraphNrVertices := 9,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("stararms1,3,4") := rec(
  DigraphNrEdges := 16,
  DigraphDiameter := 7,
  DigraphNrVertices := 9,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("stararms1,2,4") := rec(
  DigraphNrEdges := 14,
  DigraphDiameter := 6,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("tree5differentdominationquantities") := rec(
  DigraphNrEdges := 38,
  DigraphDiameter := 9,
  DigraphNrVertices := 20,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("mapbiusstripoflength5,width2") := rec(
  DigraphNrEdges := 50,
  DigraphDiameter := 3,
  DigraphNrVertices := 15,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("bistar3,5withextramiddlevertex") := rec(
  DigraphNrEdges := 16,
  DigraphDiameter := 4,
  DigraphNrVertices := 9,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("automorphismc3,n=10,e=15") := rec(
  DigraphNrEdges := 30,
  DigraphDiameter := 3,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("automorphismc3,n=10,e=15") := rec(
  DigraphNrEdges := 30,
  DigraphDiameter := 3,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("complementofsmallestasymmetrictree") := rec(
  DigraphNrEdges := 30,
  DigraphDiameter := 2,
  DigraphNrVertices := 7,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("erdasandra(c)nyifigure5") := rec(
  DigraphNrEdges := 38,
  DigraphDiameter := 3,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("erdasandra(c)nyifigure5,edgedelete") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 3,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("erdasandra(c)nyifigure5,otheredgedelete") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 3,
  DigraphNrVertices := 10,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("erdasandra(c)nyifigure5,otheredgeadd") := rec(
  DigraphNrEdges := 40,
  DigraphDiameter := 3,
  DigraphNrVertices := 10,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("asymmetric,deleteedgetosymmetric,noaddedge,n=9") := rec(
  DigraphNrEdges := 38,
  DigraphDiameter := 2,
  DigraphNrVertices := 9,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("asymmetric,deleteedgetosymmetric,noaddedge,n=9") := rec(
  DigraphNrEdges := 38,
  DigraphDiameter := 2,
  DigraphNrVertices := 9,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("tri-hex9,3symmetricconfigurationlines") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 2,
  DigraphNrVertices := 9,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("dudeneypuzzlethecycliststour") := rec(
  DigraphNrEdges := 32,
  DigraphDiameter := 5,
  DigraphNrVertices := 12,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("dudeneypuzzlevisitingthetowns") := rec(
  DigraphNrEdges := 46,
  DigraphDiameter := 5,
  DigraphNrVertices := 16,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("bulgariansolitairetreen=6") := rec(
  DigraphNrEdges := 20,
  DigraphDiameter := 8,
  DigraphNrVertices := 11,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("bulgariansolitairen=8") := rec(
  DigraphNrEdges := 42,
  DigraphNrVertices := 22,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("bulgariansolitairetreen=10") := rec(
  DigraphNrEdges := 82,
  DigraphDiameter := 17,
  DigraphNrVertices := 42,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("bulgariansolitairetreen=15") := rec(
  DigraphNrEdges := 350,
  DigraphDiameter := 29,
  DigraphNrVertices := 176,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("truncatedk33") := rec(
  DigraphNrEdges := 54,
  DigraphDiameter := 4,
  DigraphNrVertices := 18,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("bulgariansolitairen=7") := rec(
  DigraphNrEdges := 30,
  DigraphDiameter := 9,
  DigraphNrVertices := 15,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("bulgariansolitairen=9") := rec(
  DigraphNrEdges := 60,
  DigraphDiameter := 12,
  DigraphNrVertices := 30,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("bulgariansolitairen=11") := rec(
  DigraphNrEdges := 112,
  DigraphDiameter := 17,
  DigraphNrVertices := 56,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("bulgariansolitairen=12") := rec(
  DigraphNrEdges := 154,
  DigraphNrVertices := 77,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("bulgariansolitairen=13") := rec(
  DigraphNrEdges := 202,
  DigraphNrVertices := 101,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("bulgariansolitairen=14") := rec(
  DigraphNrEdges := 270,
  DigraphDiameter := 23,
  DigraphNrVertices := 135,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("bulgariansolitairen=16") := rec(
  DigraphNrEdges := 462,
  DigraphDiameter := 28,
  DigraphNrVertices := 231,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("cospectralmates") := rec(
  DigraphNrEdges := 48,
  DigraphDiameter := 2,
  DigraphNrVertices := 12,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("twinalternateareatreelevel7") := rec(
  DigraphNrEdges := 254,
  DigraphDiameter := 59,
  DigraphNrVertices := 128,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("seidelcospectraltreen=12") := rec(
  DigraphNrEdges := 22,
  DigraphDiameter := 8,
  DigraphNrVertices := 12,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("seidelcospectraltreen=12") := rec(
  DigraphNrEdges := 22,
  DigraphDiameter := 8,
  DigraphNrVertices := 12,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("kreweraslatticen=4") := rec(
  DigraphNrEdges := 56,
  DigraphDiameter := 3,
  DigraphNrVertices := 14,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("kreweraslatticen=5") := rec(
  DigraphNrEdges := 240,
  DigraphDiameter := 4,
  DigraphNrVertices := 42,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("kreweraslatticen=6") := rec(
  DigraphNrEdges := 990,
  DigraphDiameter := 5,
  DigraphNrVertices := 132,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("binarytreefirstrotaten=4") := rec(
  DigraphNrEdges := 26,
  DigraphDiameter := 6,
  DigraphNrVertices := 14,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("binarytreefirstrotaten=5") := rec(
  DigraphNrEdges := 82,
  DigraphDiameter := 8,
  DigraphNrVertices := 42,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("binarytreefirstrotaten=6") := rec(
  DigraphNrEdges := 262,
  DigraphDiameter := 10,
  DigraphNrVertices := 132,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("binarytreelastrotaten=4") := rec(
  DigraphNrEdges := 26,
  DigraphDiameter := 9,
  DigraphNrVertices := 14,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("binarytreelastrotaten=5") := rec(
  DigraphNrEdges := 82,
  DigraphDiameter := 16,
  DigraphNrVertices := 42,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("binarytreelastrotaten=6") := rec(
  DigraphNrEdges := 262,
  DigraphDiameter := 25,
  DigraphNrVertices := 132,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("alternateterdragon4") := rec(
  DigraphNrEdges := 162,
  DigraphDiameter := 9,
  DigraphNrVertices := 44,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("alternateterdragon5") := rec(
  DigraphNrEdges := 486,
  DigraphDiameter := 19,
  DigraphNrVertices := 114,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("twindragonareatree6") := rec(
  DigraphNrEdges := 126,
  DigraphDiameter := 29,
  DigraphNrVertices := 64,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("twindragonareatree7") := rec(
  DigraphNrEdges := 254,
  DigraphDiameter := 49,
  DigraphNrVertices := 128,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("excessconfigurationstepsn=3") := rec(
  DigraphNrEdges := 16,
  DigraphDiameter := 3,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("excessconfigurationstepsn=4") := rec(
  DigraphNrEdges := 34,
  DigraphDiameter := 4,
  DigraphNrVertices := 12,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("balancedbinaryfillingn=4") := rec(
  DigraphNrEdges := 26,
  DigraphDiameter := 4,
  DigraphNrVertices := 14,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("balancedbinaryfillingn=5") := rec(
  DigraphNrEdges := 82,
  DigraphDiameter := 6,
  DigraphNrVertices := 42,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("balancedbinaryfillingn=6") := rec(
  DigraphNrEdges := 262,
  DigraphDiameter := 8,
  DigraphNrVertices := 132,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("binarytreerotateb-emptyn=4") := rec(
  DigraphNrEdges := 30,
  DigraphDiameter := 9,
  DigraphNrVertices := 14,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("binarytreerotateb-emptyn=5") := rec(
  DigraphNrEdges := 112,
  DigraphDiameter := 16,
  DigraphNrVertices := 42,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("binarytreerotateb-emptyn=6") := rec(
  DigraphNrEdges := 420,
  DigraphDiameter := 25,
  DigraphNrVertices := 132,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("binarytreerotatea-emptyn=4") := rec(
  DigraphNrEdges := 30,
  DigraphDiameter := 9,
  DigraphNrVertices := 14,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("binarytreerotatea-emptyn=5") := rec(
  DigraphNrEdges := 112,
  DigraphDiameter := 16,
  DigraphNrVertices := 42,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("binarytreerotatea-emptyn=6") := rec(
  DigraphNrEdges := 420,
  DigraphDiameter := 25,
  DigraphNrVertices := 132,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("binarytreerotateright-armn=4") := rec(
  DigraphNrEdges := 28,
  DigraphDiameter := 6,
  DigraphNrVertices := 14,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("binarytreerotateright-armn=5") := rec(
  DigraphNrEdges := 96,
  DigraphDiameter := 8,
  DigraphNrVertices := 42,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("binarytreerotateright-armn=6") := rec(
  DigraphNrEdges := 330,
  DigraphDiameter := 10,
  DigraphNrVertices := 132,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("dextern=4") := rec(
  DigraphNrEdges := 42,
  DigraphDiameter := 5,
  DigraphNrVertices := 14,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("dextern=5") := rec(
  DigraphNrEdges := 168,
  DigraphDiameter := 7,
  DigraphNrVertices := 42,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("dextern=6") := rec(
  DigraphNrEdges := 660,
  DigraphDiameter := 9,
  DigraphNrVertices := 132,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("transpositiongraphn=5") := rec(
  DigraphNrEdges := 1200,
  DigraphDiameter := 4,
  DigraphNrVertices := 120,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("gra$?tzerexamplelattice") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 4,
  DigraphNrVertices := 12,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("transposecoversn=4") := rec(
  DigraphNrEdges := 116,
  DigraphDiameter := 6,
  DigraphNrVertices := 24,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("transposecoversn=5") := rec(
  DigraphNrEdges := 888,
  DigraphDiameter := 10,
  DigraphNrVertices := 120,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("fibonaccilatticeton=6") := rec(
  DigraphNrEdges := 116,
  DigraphDiameter := 6,
  DigraphNrVertices := 33,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("pappustheoremgeometricconfiguration") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 2,
  DigraphNrVertices := 9,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("21,3symmetricconfigurationincidence") := rec(
  DigraphNrEdges := 126,
  DigraphDiameter := 6,
  DigraphNrVertices := 42,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 8,
);

DIGRAPHS_NamedDigraphsTests.("dragoncurvelevel4") := rec(
  DigraphNrEdges := 32,
  DigraphDiameter := 12,
  DigraphNrVertices := 16,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("dragoncurvelevel5") := rec(
  DigraphNrEdges := 64,
  DigraphDiameter := 18,
  DigraphNrVertices := 29,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("dragoncurvelevel6") := rec(
  DigraphNrEdges := 128,
  DigraphDiameter := 26,
  DigraphNrVertices := 54,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("dragoncurvelevel7") := rec(
  DigraphNrEdges := 256,
  DigraphDiameter := 36,
  DigraphNrVertices := 101,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("dragoncurvelevel8") := rec(
  DigraphNrEdges := 512,
  DigraphDiameter := 52,
  DigraphNrVertices := 190,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("dragoncurveblob6") := rec(
  DigraphNrEdges := 44,
  DigraphDiameter := 8,
  DigraphNrVertices := 17,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("dragoncurveblob7") := rec(
  DigraphNrEdges := 94,
  DigraphDiameter := 12,
  DigraphNrVertices := 34,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("dragoncurveblob8") := rec(
  DigraphNrEdges := 200,
  DigraphDiameter := 18,
  DigraphNrVertices := 68,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("two4-cycleswithcommonvertex") := rec(
  DigraphNrEdges := 16,
  DigraphDiameter := 4,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("twindragonlevel5") := rec(
  DigraphNrEdges := 256,
  DigraphDiameter := 22,
  DigraphNrVertices := 89,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("twindragonlevel6") := rec(
  DigraphNrEdges := 512,
  DigraphDiameter := 30,
  DigraphNrVertices := 171,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("terdragonlevel4") := rec(
  DigraphNrEdges := 162,
  DigraphDiameter := 13,
  DigraphNrVertices := 44,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("terdragonlevel5") := rec(
  DigraphNrEdges := 486,
  DigraphDiameter := 22,
  DigraphNrVertices := 114,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("hypercube6") := rec(
  DigraphNrEdges := 384,
  DigraphDiameter := 6,
  DigraphNrVertices := 64,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("hypercube7") := rec(
  DigraphNrEdges := 896,
  DigraphDiameter := 7,
  DigraphNrVertices := 128,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("gardnerdigit-placingpuzzle") := rec(
  DigraphNrEdges := 34,
  DigraphDiameter := 3,
  DigraphNrVertices := 8,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("gardnerdigit-placingpuzzle,complement") := rec(
  DigraphNrEdges := 22,
  DigraphDiameter := 3,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("alternatepaperfoldingcurvelevel6") := rec(
  DigraphNrEdges := 128,
  DigraphDiameter := 15,
  DigraphNrVertices := 44,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("alternatepaperfoldingcurvelevel7") := rec(
  DigraphNrEdges := 256,
  DigraphDiameter := 17,
  DigraphNrVertices := 80,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("alternatepaperfoldingcurvelevel8") := rec(
  DigraphNrEdges := 512,
  DigraphDiameter := 31,
  DigraphNrVertices := 152,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("la(c)vyccurvelevel4") := rec(
  DigraphNrEdges := 30,
  DigraphDiameter := 14,
  DigraphNrVertices := 16,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("la(c)vyccurvelevel5") := rec(
  DigraphNrEdges := 60,
  DigraphDiameter := 24,
  DigraphNrVertices := 30,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("la(c)vyccurvelevel6") := rec(
  DigraphNrEdges := 118,
  DigraphDiameter := 38,
  DigraphNrVertices := 57,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("la(c)vyccurvelevel7") := rec(
  DigraphNrEdges := 236,
  DigraphDiameter := 60,
  DigraphNrVertices := 111,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("la(c)vyccurvelevel8") := rec(
  DigraphNrEdges := 466,
  DigraphDiameter := 90,
  DigraphNrVertices := 214,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("tri-hex9,3symmetricconfigurationincidence") := rec(
  DigraphNrEdges := 54,
  DigraphDiameter := 4,
  DigraphNrVertices := 18,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("9,3symmetricconfigurationlines") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 3,
  DigraphNrVertices := 9,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("9,3symmetricconfigurationcliques") := rec(
  DigraphNrEdges := 54,
  DigraphDiameter := 2,
  DigraphNrVertices := 9,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("9,3symmetricconfigurationincidence") := rec(
  DigraphNrEdges := 54,
  DigraphDiameter := 4,
  DigraphNrVertices := 18,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("bicorn") := rec(
  DigraphNrEdges := 24,
  DigraphDiameter := 3,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("udeltaadjacency") := rec(
  DigraphNrEdges := 26,
  DigraphDiameter := 7,
  DigraphNrVertices := 14,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("largeniel") := rec(
  DigraphNrEdges := 132,
  DigraphDiameter := 9,
  DigraphNrVertices := 44,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("specialc3") := rec(
  DigraphNrEdges := 24,
  DigraphDiameter := 3,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("dragoncurveblob9") := rec(
  DigraphNrEdges := 406,
  DigraphDiameter := 26,
  DigraphNrVertices := 133,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("cubicintegralg10") := rec(
  DigraphNrEdges := 60,
  DigraphDiameter := 5,
  DigraphNrVertices := 20,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 6,
);

DIGRAPHS_NamedDigraphsTests.("knuth7.2.1.6exampleforest") := rec(
  DigraphNrEdges := 26,
  DigraphNrVertices := 15,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("integraltreen=31(brouwers#17)") := rec(
  DigraphNrEdges := 60,
  DigraphDiameter := 6,
  DigraphNrVertices := 31,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("da1/4rer") := rec(
  DigraphNrEdges := 36,
  DigraphDiameter := 4,
  DigraphNrVertices := 12,
  IsPlanarDigraph := true,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("kochol74") := rec(
  DigraphNrEdges := 222,
  DigraphDiameter := 11,
  DigraphNrVertices := 74,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("vo_6^-(2)") := rec(
  DigraphNrEdges := 1728,
  DigraphDiameter := 2,
  DigraphNrVertices := 64,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("two4-cyclescross-connectedat2opposingvertices") := rec(
  DigraphNrEdges := 20,
  DigraphDiameter := 3,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("opticalillusion,filledavatar") := rec(
  DigraphNrEdges := 24,
  DigraphDiameter := 4,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("treerelatedtoquaternary3/2-power-freestrings") := rec(
  DigraphNrEdges := 178,
  DigraphDiameter := 38,
  DigraphNrVertices := 90,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("complete4-arytree,height2(3rows,21vertices)") := rec(
  DigraphNrEdges := 40,
  DigraphDiameter := 4,
  DigraphNrVertices := 21,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("complete4-arytree,height3(4rows,85vertices)") := rec(
  DigraphNrEdges := 168,
  DigraphDiameter := 6,
  DigraphNrVertices := 85,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
);

DIGRAPHS_NamedDigraphsTests.("xf_3^2") := rec(
  DigraphNrEdges := 30,
  DigraphDiameter := 3,
  DigraphNrVertices := 8,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("x_{31}") := rec(
  DigraphNrEdges := 20,
  DigraphDiameter := 3,
  DigraphNrVertices := 7,
  IsPlanarDigraph := true,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("associativity,filledavatar") := rec(
  DigraphNrEdges := 26,
  DigraphDiameter := 3,
  DigraphNrVertices := 9,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 4,
);

DIGRAPHS_NamedDigraphsTests.("cospectralmatea1") := rec(
  DigraphNrEdges := 54,
  DigraphDiameter := 4,
  DigraphNrVertices := 18,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("cospectralmatea2") := rec(
  DigraphNrEdges := 54,
  DigraphDiameter := 4,
  DigraphNrVertices := 18,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("cospectralmateb1") := rec(
  DigraphNrEdges := 54,
  DigraphDiameter := 4,
  DigraphNrVertices := 18,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("cospectralmateb2") := rec(
  DigraphNrEdges := 54,
  DigraphDiameter := 4,
  DigraphNrVertices := 18,
  IsPlanarDigraph := false,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("whythoffgamestates,starting3,2") := rec(
  DigraphNrEdges := 52,
  DigraphDiameter := 2,
  DigraphNrVertices := 9,
  IsPlanarDigraph := false,
  IsRegularDigraph := false,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("97-cyclotomic") := rec(
  DigraphNrEdges := 3104,
  DigraphNrVertices := 97,
);

DIGRAPHS_NamedDigraphsTests.("fostercage") := rec(
  DigraphNrEdges := 150,
  DigraphNrVertices := 30,
);

DIGRAPHS_NamedDigraphsTests.("(2,1)-generalizeddodecagon") := rec(
  DigraphNrEdges := 756,
  DigraphNrVertices := 189,
);

DIGRAPHS_NamedDigraphsTests.("(3,9)-generalizedquadrangle") := rec(
  DigraphNrEdges := 3360,
  DigraphNrVertices := 112,
);

DIGRAPHS_NamedDigraphsTests.("hundredtwentycell") := rec(
  DigraphNrEdges := 2400,
  DigraphNrVertices := 600,
);

DIGRAPHS_NamedDigraphsTests.("110-iofinovaivanov") := rec(
  DigraphNrEdges := 330,
  DigraphNrVertices := 110,
);

DIGRAPHS_NamedDigraphsTests.("4-largestcubicnonplanardiameter") := rec(
  DigraphNrEdges := 114,
  DigraphNrVertices := 38,
);

DIGRAPHS_NamedDigraphsTests.("(4,4)-latticecomplement") := rec(
  DigraphNrEdges := 144,
  DigraphDiameter := 2,
  DigraphNrVertices := 16,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("moores") := rec(
  DigraphNrEdges := 2034,
  DigraphNrVertices := 341,
);

DIGRAPHS_NamedDigraphsTests.("moorespartial") := rec(
  DigraphNrEdges := 1972,
  DigraphNrVertices := 341,
);

DIGRAPHS_NamedDigraphsTests.("truncatedwitt") := rec(
  DigraphNrEdges := 7590,
  DigraphNrVertices := 506,
);

DIGRAPHS_NamedDigraphsTests.("truncatedheawood") := rec(
  DigraphNrEdges := 126,
  DigraphDiameter := 6,
  DigraphNrVertices := 42,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("truncatedmapbius-kantor") := rec(
  DigraphNrEdges := 144,
  DigraphDiameter := 8,
  DigraphNrVertices := 48,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("truncatedpappus") := rec(
  DigraphNrEdges := 162,
  DigraphDiameter := 8,
  DigraphNrVertices := 54,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("truncatedgreatdodecahedron") := rec(
  DigraphNrEdges := 180,
  DigraphDiameter := 6,
  DigraphNrVertices := 60,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);

DIGRAPHS_NamedDigraphsTests.("truncateddesargues") := rec(
  DigraphNrEdges := 180,
  DigraphDiameter := 10,
  DigraphNrVertices := 60,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("truncatednauru") := rec(
  DigraphNrEdges := 216,
  DigraphDiameter := 8,
  DigraphNrVertices := 72,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("truncatedf26a") := rec(
  DigraphNrEdges := 234,
  DigraphDiameter := 9,
  DigraphNrVertices := 78,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("truncatedtutte-coxeter") := rec(
  DigraphNrEdges := 270,
  DigraphDiameter := 8,
  DigraphNrVertices := 90,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("truncateddyck") := rec(
  DigraphNrEdges := 288,
  DigraphDiameter := 10,
  DigraphNrVertices := 96,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("truncatedcubicklein") := rec(
  DigraphNrEdges := 504,
  DigraphDiameter := 12,
  DigraphNrVertices := 168,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("truncatedfoster") := rec(
  DigraphNrEdges := 810,
  DigraphDiameter := 16,
  DigraphNrVertices := 270,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("truncatedbiggs-smith") := rec(
  DigraphNrEdges := 918,
  DigraphDiameter := 14,
  DigraphNrVertices := 306,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("latinsquaregraphfromz4") := rec(
  DigraphNrEdges := 144,
  DigraphDiameter := 2,
  DigraphNrVertices := 16,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("orthogonalarraygraphoa(4,5)") := rec(
  DigraphNrEdges := 400,
  DigraphDiameter := 2,
  DigraphNrVertices := 25,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 3,
);

DIGRAPHS_NamedDigraphsTests.("dodecadodecahedron") := rec(
  DigraphNrEdges := 120,
  DigraphDiameter := 3,
  DigraphNrVertices := 30,
  IsRegularDigraph := true,
  DigraphUndirectedGirth := 5,
);
