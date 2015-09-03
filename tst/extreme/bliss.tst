#############################################################################
##
#W  extreme/bliss.tst
#Y  Copyright (C) 2014-15                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: extreme/bliss.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#T# AutomorphismGroup: for a digraph, 1
# All graphs of 5 vertices, compare with GRAPE
gap> graph5 := ReadDigraphs(Concatenation(DIGRAPHS_Dir(),
>                                         "/data/graph5.g6.gz"));
[ <digraph with 5 vertices, 0 edges>, <digraph with 5 vertices, 2 edges>, 
  <digraph with 5 vertices, 4 edges>, <digraph with 5 vertices, 6 edges>, 
  <digraph with 5 vertices, 8 edges>, <digraph with 5 vertices, 4 edges>, 
  <digraph with 5 vertices, 6 edges>, <digraph with 5 vertices, 6 edges>, 
  <digraph with 5 vertices, 6 edges>, <digraph with 5 vertices, 8 edges>, 
  <digraph with 5 vertices, 8 edges>, <digraph with 5 vertices, 10 edges>, 
  <digraph with 5 vertices, 10 edges>, <digraph with 5 vertices, 8 edges>, 
  <digraph with 5 vertices, 10 edges>, <digraph with 5 vertices, 10 edges>, 
  <digraph with 5 vertices, 12 edges>, <digraph with 5 vertices, 12 edges>, 
  <digraph with 5 vertices, 14 edges>, <digraph with 5 vertices, 8 edges>, 
  <digraph with 5 vertices, 8 edges>, <digraph with 5 vertices, 10 edges>, 
  <digraph with 5 vertices, 12 edges>, <digraph with 5 vertices, 12 edges>, 
  <digraph with 5 vertices, 12 edges>, <digraph with 5 vertices, 14 edges>, 
  <digraph with 5 vertices, 10 edges>, <digraph with 5 vertices, 12 edges>, 
  <digraph with 5 vertices, 14 edges>, <digraph with 5 vertices, 16 edges>, 
  <digraph with 5 vertices, 14 edges>, <digraph with 5 vertices, 16 edges>, 
  <digraph with 5 vertices, 18 edges>, <digraph with 5 vertices, 20 edges> ]
gap> group5 := [
>  Group([(4, 5), (3, 4), (2, 3), (1, 2)]), Group([(1, 5), (3, 4), (2, 3)]),
>  Group([(1, 2), (3, 4)]), Group([(2, 3), (1, 2)]), Group([(3, 4), (2, 3), (1,
>   2)]), Group([(2, 5), (1, 2)(4, 5)]), Group([(1, 4), (2, 3)]),
>  Group([(4, 5), (1, 4), (2, 3)]), Group([(1, 5)(2, 4)]), Group([(1, 4)]),
>  Group([(2, 3)]), Group([(1, 4), (2, 3)]), Group([(2, 3)(4, 5)]),
>  Group([(4, 5), (1, 2), (1, 4)(2, 5)]), Group([(4, 5), (1, 2)]),
>  Group([(1, 2)]), Group([(1, 2)]), Group([(4, 5), (2, 3), (1, 2)]),
>  Group([(4, 5), (2, 3), (1, 2)]), Group([(3, 5), (1, 3), (2, 4)]),
>  Group([(1, 2)(3, 4)]), Group([(1, 3)]), Group([(2, 4), (1, 2)(3, 4)]),
>  Group([(4, 5), (3, 4), (1, 3)]), Group([(1, 3)]), Group([(3, 4), (1, 3)]),
>  Group([(2, 5)(3, 4), (1, 2, 3, 4, 5)]), Group([(1, 5)(2, 4)]), Group([(1, 4)
>  (2, 3)]), Group([(4, 5), (1, 3)]), Group([(3, 5), (1, 2)]),
>  Group([(3, 4), (1, 2), (1, 3)(2, 4)]), Group([(4, 5), (3, 4), (1, 2)]),
>  Group([(4, 5), (3, 4), (2, 3), (1, 2)])];;
gap> List(graph5, AutomorphismGroup) = group5;
true
gap> trees := ReadDigraphs(Concatenation(DIGRAPHS_Dir(), "/data/tree9.4.txt"));
[ <digraph with 9 vertices, 8 edges>, <digraph with 9 vertices, 8 edges>, 
  <digraph with 9 vertices, 8 edges>, <digraph with 9 vertices, 8 edges>, 
  <digraph with 9 vertices, 8 edges>, <digraph with 9 vertices, 8 edges>, 
  <digraph with 9 vertices, 8 edges>, <digraph with 9 vertices, 8 edges>, 
  <digraph with 9 vertices, 8 edges>, <digraph with 9 vertices, 8 edges>, 
  <digraph with 9 vertices, 8 edges>, <digraph with 9 vertices, 8 edges>, 
  <digraph with 9 vertices, 8 edges>, <digraph with 9 vertices, 8 edges> ]
gap> treeAuts := [
>  Group([(6, 7), (5, 6), (4, 5), (3, 4)]), Group([(6, 7), (5, 6), (4, 5),
>  (2, 3)]), Group([(3, 4), (2, 3), (6, 7), (5, 6), (2, 5)(3, 6)(4, 7)(8, 9)]),
>  Group([(5, 6), (4, 5), (3, 4), (1, 2)(7, 8)]), Group([(5, 6), (4, 5),
>  (3, 4)]), Group([(5, 6), (4, 5), (2, 3)]), Group([(5, 6), (4, 5), (2, 3)]),
>  Group([(5, 6), (3, 4), (2, 3)]), Group([(5, 6), (4, 5), (2, 3)(7, 8)]),
>  Group([(5, 6), (3, 4), (1, 2), (1, 3)(2, 4)(7, 8)]), Group([(4, 5), (2, 3)
>  (7, 8), (1, 2)(6, 7)]), Group([(3, 4), (1, 2)(6, 7)]), Group([(4, 5),
>  (2, 3), (2, 4)(3, 5)(7, 8)]), Group([(3, 4)(7, 8), (2, 3)(6, 7),
>  (1, 2)(5, 6)])];;
gap> List(trees, AutomorphismGroup) = treeAuts;
true

#T# AutomorphismGroup: for a digraph, 2
# PJC example, 45 vertices.
# This example is broken if we use Digraphs rather than Graphs in the bliss
# code
gap> gr := DigraphFromDigraph6String(Concatenation(
> "+l??O?C?A_@???CE????GAAG?C??M?????@_?OO??G??@?IC???_C?G?o??C?AO???c_??A?",
> "A?S???OAA???OG???G_A??C?@?cC????_@G???S??C_?C???[??A?A?OA?O?@?A?@A???GGO",
> "??`?_O??G?@?A??G?@AH????AA?O@??_??b???Cg??C???_??W?G????d?G?C@A?C???GC?W",
> "?????K???__O[??????O?W???O@??_G?@?CG??G?@G?C??@G???_Q?O?O?c???OAO?C??C?G",
> "?O??A@??D??G?C_?A??O?_GA??@@?_?G???E?IW??????_@G?C??"));
<digraph with 45 vertices, 180 edges>
gap> H := AutomorphismGroup(gr);
<permutation group with 5 generators>
gap> IsomorphismGroups(PrimitiveGroup(45, 3), H) <> fail;
true

#T# AutomorphismGroup: for a digraph, 3
# Random examples
gap> AutomorphismGroup(Digraph([]));
Group(())
gap> gr := Digraph([[6, 7], [6, 9], [1, 3, 4, 5, 8, 9],
> [1, 2, 3, 4, 5, 6, 7, 10], [1, 5, 6, 7, 10], [2, 4, 5, 9, 10],
> [3, 4, 5, 6, 7, 8, 9, 10], [1, 3, 5, 7, 8, 9], [1, 2, 5],
> [1, 2, 4, 6, 7, 8]]);;
gap> AutomorphismGroup(gr);
Group(())
gap> gr := CycleDigraph(1000);
<digraph with 1000 vertices, 1000 edges>
gap> AutomorphismGroup(gr);
<permutation group with 1 generators>
gap> Size(last);
1000
gap> AutomorphismGroup(CompleteDigraph(6)) = SymmetricGroup(6);
true

#T# AutomorphismGroup: for a MultiDigraph, 1
gap> gr := DigraphEdgeUnion(CycleDigraph(3), CycleDigraph(3));
<multidigraph with 3 vertices, 6 edges>
gap> AutomorphismGroup(gr);
Group([ (1,2,3), (8,9), (6,7), (4,5) ])
gap> Size(last);
24
gap> gr := DigraphEdgeUnion(CycleDigraph(50), CycleDigraph(50));
<multidigraph with 50 vertices, 100 edges>
gap> AutomorphismGroup(gr);
<permutation group with 51 generators>
gap> Size(last);
56294995342131200

#T# DigraphCanonicalLabelling: for a digraph, 1
# PJC example, 45 vertices
gap> gr := DigraphFromDigraph6String(Concatenation(
> "+l??O?C?A_@???CE????GAAG?C??M?????@_?OO??G??@?IC???_C?G?o??C?AO???c_??A?",
> "A?S???OAA???OG???G_A??C?@?cC????_@G???S??C_?C???[??A?A?OA?O?@?A?@A???GGO",
> "??`?_O??G?@?A??G?@AH????AA?O@??_??b???Cg??C???_??W?G????d?G?C@A?C???GC?W",
> "?????K???__O[??????O?W???O@??_G?@?CG??G?@G?C??@G???_Q?O?O?c???OAO?C??C?G",
> "?O??A@??D??G?C_?A??O?_GA??@@?_?G???E?IW??????_@G?C??"));
<digraph with 45 vertices, 180 edges>
gap> DigraphCanonicalLabelling(gr);
(1,45,23,34,3,13,26,22,27,2,9,31,10,8,17,41,44,18,36,21,24)(4,15,38,20,28,40,
37,5,35,14,39,30,25,32,42,29,7,16,6,11,33,12)

#T# DigraphCanonicalLabelling: for a digraph, 2
gap> gr := DigraphFromDiSparse6String(Concatenation(
> ".~?@caOa??gGEA?e@?oOIb_SIc?MQBhOQCwIV?PY@B@IRDGgL__sYao{ODWCNC@MKBOwUEHG",
> "TdPmEBwkXFGoV_ogNCGCIBO{ZGGGFD@U?APGUDwW_GWGGFAU??PKUE@eDA`?TFAi?A_{da@G",
> "gaosVEQciIwOJC@eCA_oVE@wbHH}IApGlb`caGq{p`@WXEqCq_pS]HQ{oepo^JHKdHwSHC`O",
> "VEps_GxWibPGSHQclKbQD@_kMEaou`OcYEpo\\HagmMGKDA?kcKWsRDakwNBu@E@srMRuEEq",
> "CaJb?xapGT`OkKBPG]GqmcNwOFE@{oNCABAOkMCPo`IQkqbpo_Lbc}eQswMbpBPW{[MwCFAO",
> "kUFQ?bbP?ZJWOFB@O\\IWWLGQiUEq_yNcUJErdHRG{cHacvMCyKNRy@AO{VFQOhJBCqNc@EQ",
> "CeTFa?kJrk|NsiHB@SbHA{vMSHJ_qGdHsY?@__\\Ha_hJBGrMblFQstOb`CWQg[HDpsxPg[G",
> "APO\\ISHEQspR_@SVIR?|QDQ@B?sQCpc]Fq{vRwGYEpo`HbCwNb|XgAstQC|SUw{gKBhESdP",
> "TaooPDPcZGq[nOCdOcqCdHbSuOcPHRt\\X_occKbOtQGCGB`glJbGvNCDRVTx___gLB`CQLR",
> "lFTddYWWGEDBKuPCTHRDTYxGO?a?AK?g{GA_kKBwGCAGMGBOyB_O[PCgCD@woPaOgNCwMJ_@",
> "[W`PGYEwQJC@QKCPGV`?gMFg?KBp]J``W\\_`GUcp_]FqECBPG^GQINC`SYi?{OGwg^_OkNE",
> "QIHCpOWFaeBIamDA`OVEgWTIG_KkO?CAPgkJW?NC@KZFa?iJbEC@`okKBINEpohIbIEA_oQF",
> "aGeKGWKBP[p_?CA@?WJBqY@?_kZIA{oKhKWEQeA@r]DBPCRFa[jJbe??_KPDA?`Ga_z_aWhJ",
> "gOMC`cZHawu`OcLGQKgJb[~c@SZFQclKbSyNwOPD`kaGrOy`okTJraQEa_qLsIOGqSfIAklN",
> "sQLCQ{yNwo_KCAE@p?ZF`{fJAszNxSWGaoxaPgeIbE??oS[HackNW{_HQxI_?SOGq{s`@KYG",
> "A[qRGSIDa[jKCPH`OgPDasmMcTFQw?CEB?wNC@Ma?cXGaO}NshO`@?_JRCrOgkUGQgmKBGwM",
> "RlA`_[ICp_\\GQkkLbuEApCRE@c^HR[xOchJapCRGqOgIasoNCDDPsu?AOoRFQGbHQ[gISLH",
> "_okZGagvMSLJ_ocLMCdL`O_OC`gZGa[hPCYHDbCyMseMFAknKBCtMcXISx?QDPg^Jb|APCXI",
> "RtHUTte@@O[PCp_eIRpSTWK\\FqGgIRGwNDM?CA{xRTHS_OKQIb[}Qd@]WWKGCaWjJQx@Qw?",
> "AA`[dHrSxU^"));
<digraph with 100 vertices, 1011 edges>
gap> DigraphCanonicalLabelling(gr);
(1,53,16,92,26,17,60,85,64,87,51,96,76,35,50,19,98,93,30,55,7,22,67,57,94,89,
48,27,45,29,32,20,62,18,15,6,33,36,41,46,69,73,2,24,49,71,28,97,9,11,70,47,80,
68)(3,34,14,44,79,8)(4,42,90,37,31,65,78,23,25,38,86,100,52,13,82,83,39,61,95,
91,81,10,59,58,43,84,88,66)(5,40,12,99,75,54,56,63,74,72,77)

#T# DigraphCanonicalLabelling: for a digraph, 3
gap> gr := ReadDigraphs(
> Concatenation(DIGRAPHS_Dir(), "/data/test-1.d6"))[1];
<digraph with 1000 vertices, 100368 edges>
gap> DigraphCanonicalLabelling(gr);
(1,894,760,546,212,603,466,938,837,802,929,717,865,809,599,672,859,937,816,
747,675,441,10,504,108,916,315,869,340,676,720,678,233,844,142,419,82,238,917,
372,207,385,306,321,311,893,423,980,600,813,953,350,85,96,433,275,898,460,757,
167,4,559,174,735,368,764,895,696,924,790,209,730,405,116,236,377,483,921,509,
797,796,184,522,939,468,201,447,673,912,180,565,647,461,202,523,828,139,945,
128,480,186,577,989,962,183,610,331,354,130,926,752,770,514,240,535,283,27,
686,972,479,28,271,833,855,329,502,910,46,67,743,250,431,840,499,740,326,631,
241,975,451,312,358,414,957,318,490,81,951,45,107,756,506,536,14,457,853,473,
711,310,110,177,144,196,570,547,75,386,395,71,394,80,583,725,53,749,544,560,
774,84,648,697,304,169,789,860,407,193,668,274,665,249,719,780,590,117,826,
758,615,942,43,818,750,742,897,798,378,584,297,639,529,841,440,751,667,298,
418,870,376,771,230,885,371,825,512,456,255,454,534,830,899,620,289,334,345,
76,172,627,406,744,540,214,388,991,280,679,922,726,640,653,330,211,465,287,
708,988,242,467,827,974,778,571,934,958,651,92,192,36,754,553,218,666,507,390,
245,251,887,649,562,412,533,650,491,276,264,35,578,815,8,178,439,896,52,949,
960,381,243,564,226,94,31,138,115,976,505,257,220,384,914,952,90,997,543,987,
436,77,285,664,353,221,999,270,281,617,500,413,32,785,389,656,845,470,503,21,
450,902,99,580,709,573,370,296,576,782,146,800,149,225,208,152,900,365,783,
618,488,992,998,286,548,323,694,244,944,49,810,703,737,731,33,692,931,165,513,
95,765,420,642,850,575,932,42,157,219,508,125,563,596,11,445,103,973,804,453,
187,131,191,459,741,416,733,847,558,658,162,807,428,519,905,486,586,229,722,
985,247,690,98,940,572,303,549,449,348,293,20,684,25,471,197,151,791,288,494,
555,624,812,18,525,561,105,695,585,761,259,66,936,72,123,714,886,875,182,409,
93,710,145,267,332,3,762,685,367,597,636,868,963,317,100,918,373,411,994,943,
772,171,24,857,277,801,478,170,263,188,302,102,552,215,269,759,702,421,272,
362,135,387,803,64,621,383,808,498,698,993,517,861,430,294,928,671,682,724,
907,862,873,688,538,721,357,319,872,438,716,904,866,382,56,786,755,29,677,707,
823,781,526,363,434,602,739,661,851,415,605,593,475,766,113,822,38,60,254,300,
753,179,141,595,609,410,852,147,239,521,78,474,161,88,693,426,582,669,941,83,
510,127,670,1000,876,763,58,700,829,515,166,47,643,527,777,581,396,401,779,
689,132,26,838,638,746,959,69,645,223,769,65,129,537,819,961,408,458,12,442,
623,284,216,592,279,337,984,947,680,444,574,831,213,333,136,324,817,901,614,
792,301,204,336,805,227,715,977,79,181,40,589,933,727,346,608,848,305,773,393,
971,655,516,364,261,729,262,338,969,662,606,530,124,185,925,120,619,881,497,
342,556,718,856,948,48,222,532,892,930,351,820,435,13,612,728,54,970,493,268,
273,968,168,706,915,266,265,109,520,622,983,913,443,322,768,903,935,566,164,
232,59,104,476,206,501,492,776,632,511,313,531,472,143,87,745,258,360,628,738,
839,16,863,864,424,663,524,635,723,429,681,832,347,883,228,37,399,659,909,217,
849,234,292,713,148,657,325,919,990,588,7,30,417,122,432,927,734,906,86,874,
793,422,51,41,487,343,821,806,291,17,654,568,137,462,39,591,469,118,34,767,
344,824,601,2,518,446,74,891,106,920,587,884,248,477,594,854,119,843,982,392,
134,252,173,194)( [...] )

#T# DigraphCanonicalLabelling: for a MultiDigraph, 1
gap> gr1 := DigraphEdgeUnion(CycleDigraph(3), CycleDigraph(3));
<multidigraph with 3 vertices, 6 edges>
gap> perms := DigraphCanonicalLabelling(gr1);
[ (1,3), (1,6)(2,3,5) ]
gap> gr2 := OnMultiDigraphs(gr1, perms);
<multidigraph with 3 vertices, 6 edges>
gap> DigraphCanonicalLabelling(gr2);
[ (1,3,2), (1,6,4)(2,3) ]
gap> OnMultiDigraphs(gr2, last) = gr2;
true
gap> gr2 = gr1;
false

#T# IsIsomorphicDigraph: for digraphs, 1
gap> p := Random(SymmetricGroup(1000));;
gap> gr2 := OnDigraphs(gr, p);
<digraph with 1000 vertices, 100368 edges>
gap> gr = gr2;
false
gap> IsIsomorphicDigraph(gr, gr2);
true
gap> IsIsomorphicDigraph(gr2, gr);
true
gap> ForAny(graph5, x -> Number(graph5, y -> IsIsomorphicDigraph(x, y)) <> 1);
false

#T# IsIsomorphicDigraph: for MultiDigraphs, 1
gap> gr1 := Digraph([[3, 1, 3], [1, 3], [2, 2, 1]]);
<multidigraph with 3 vertices, 8 edges>
gap> gr2 := Digraph([[3, 1, 3], [1, 3], [2, 2]]);
<multidigraph with 3 vertices, 7 edges>
gap> IsIsomorphicDigraph(gr1, gr2);
false
gap> gr3 := Digraph([[3, 1, 3], [1, 3], [2, 2], []]);
<multidigraph with 4 vertices, 7 edges>
gap> IsIsomorphicDigraph(gr1, gr3);
false
gap> IsIsomorphicDigraph(gr2, gr3);
false
gap> gr4 := Digraph([[2, 3, 3], [2, 1, 1], [1, 2]]);
<multidigraph with 3 vertices, 8 edges>
gap> IsIsomorphicDigraph(gr1, gr4);
true
gap> IsIsomorphicDigraph(gr2, gr4);
false
gap> IsIsomorphicDigraph(gr3, gr4);
false
gap> IsIsomorphicDigraph(gr4, gr4);
true

#T# IsomorphismDigraphs: for digraphs, 1
gap> gr1 := CompleteBipartiteDigraph(100, 50);
<digraph with 150 vertices, 10000 edges>
gap> gr2 := CompleteBipartiteDigraph(50, 100);
<digraph with 150 vertices, 10000 edges>
gap> p := IsomorphismDigraphs(gr1, gr2);
(1,51,101)(2,52,102)(3,53,103)(4,54,104)(5,55,105)(6,56,106)(7,57,107)(8,58,
108)(9,59,109)(10,60,110)(11,61,111)(12,62,112)(13,63,113)(14,64,114)(15,65,
115)(16,66,116)(17,67,117)(18,68,118)(19,69,119)(20,70,120)(21,71,121)(22,72,
122)(23,73,123)(24,74,124)(25,75,125)(26,76,126)(27,77,127)(28,78,128)(29,79,
129)(30,80,130)(31,81,131)(32,82,132)(33,83,133)(34,84,134)(35,85,135)(36,86,
136)(37,87,137)(38,88,138)(39,89,139)(40,90,140)(41,91,141)(42,92,142)(43,93,
143)(44,94,144)(45,95,145)(46,96,146)(47,97,147)(48,98,148)(49,99,149)(50,100,
150)
gap> OnDigraphs(gr1, p) = gr2;
true
gap> IsomorphismDigraphs(EmptyDigraph(1), gr1);
fail

#T# IsomorphismDigraphs: for MultiDigraphs, 1
gap> gr1 := Digraph([[3, 1, 3], [1, 3], [2, 2, 1]]);
<multidigraph with 3 vertices, 8 edges>
gap> gr4 := Digraph([[2, 3, 3], [2, 1, 1], [1, 2]]);
<multidigraph with 3 vertices, 8 edges>
gap> iso := IsomorphismDigraphs(gr1, gr4);
[ (1,2,3), (1,5,7,3,6,2,4,8) ]
gap> OnMultiDigraphs(gr1, iso) = gr4;
true
gap> iso := IsomorphismDigraphs(gr4, gr1);
[ (1,3,2), (1,8,4,2,6,3,7,5) ]
gap> OnMultiDigraphs(gr4, iso) = gr1;
true
gap> iso := IsomorphismDigraphs(gr1, gr1);
[ (), () ]
gap> OnMultiDigraphs(gr1, iso) = gr1;
true

#T# DIGRAPHS_UnbindVariables
gap> Unbind(gr4);
gap> Unbind(gr2);
gap> Unbind(gr);
gap> Unbind(p);
gap> Unbind(perms);
gap> Unbind(H);
gap> Unbind(gr1);
gap> Unbind(trees);
gap> Unbind(group5);
gap> Unbind(treeAuts);
gap> Unbind(iso);
gap> Unbind(graph5);
gap> Unbind(gr3);

#E#
gap> STOP_TEST("Digraphs package: extreme/bliss.tst");
