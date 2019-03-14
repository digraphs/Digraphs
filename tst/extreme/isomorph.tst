#############################################################################
##
#W  extreme/isomorph.tst
#Y  Copyright (C) 2014-15                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: extreme/isomorph.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#  AutomorphismGroup: for a digraph, 1
# All graphs of 5 vertices, compare with GRAPE
gap> graph5 := ReadDigraphs(Concatenation(DIGRAPHS_Dir(),
>                                         "/data/graph5.g6.gz"));
[ <immutable digraph with 5 vertices, 0 edges>, 
  <immutable digraph with 5 vertices, 2 edges>, 
  <immutable digraph with 5 vertices, 4 edges>, 
  <immutable digraph with 5 vertices, 6 edges>, 
  <immutable digraph with 5 vertices, 8 edges>, 
  <immutable digraph with 5 vertices, 4 edges>, 
  <immutable digraph with 5 vertices, 6 edges>, 
  <immutable digraph with 5 vertices, 6 edges>, 
  <immutable digraph with 5 vertices, 6 edges>, 
  <immutable digraph with 5 vertices, 8 edges>, 
  <immutable digraph with 5 vertices, 8 edges>, 
  <immutable digraph with 5 vertices, 10 edges>, 
  <immutable digraph with 5 vertices, 10 edges>, 
  <immutable digraph with 5 vertices, 8 edges>, 
  <immutable digraph with 5 vertices, 10 edges>, 
  <immutable digraph with 5 vertices, 10 edges>, 
  <immutable digraph with 5 vertices, 12 edges>, 
  <immutable digraph with 5 vertices, 12 edges>, 
  <immutable digraph with 5 vertices, 14 edges>, 
  <immutable digraph with 5 vertices, 8 edges>, 
  <immutable digraph with 5 vertices, 8 edges>, 
  <immutable digraph with 5 vertices, 10 edges>, 
  <immutable digraph with 5 vertices, 12 edges>, 
  <immutable digraph with 5 vertices, 12 edges>, 
  <immutable digraph with 5 vertices, 12 edges>, 
  <immutable digraph with 5 vertices, 14 edges>, 
  <immutable digraph with 5 vertices, 10 edges>, 
  <immutable digraph with 5 vertices, 12 edges>, 
  <immutable digraph with 5 vertices, 14 edges>, 
  <immutable digraph with 5 vertices, 16 edges>, 
  <immutable digraph with 5 vertices, 14 edges>, 
  <immutable digraph with 5 vertices, 16 edges>, 
  <immutable digraph with 5 vertices, 18 edges>, 
  <immutable digraph with 5 vertices, 20 edges> ]
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
[ <immutable digraph with 9 vertices, 8 edges>, 
  <immutable digraph with 9 vertices, 8 edges>, 
  <immutable digraph with 9 vertices, 8 edges>, 
  <immutable digraph with 9 vertices, 8 edges>, 
  <immutable digraph with 9 vertices, 8 edges>, 
  <immutable digraph with 9 vertices, 8 edges>, 
  <immutable digraph with 9 vertices, 8 edges>, 
  <immutable digraph with 9 vertices, 8 edges>, 
  <immutable digraph with 9 vertices, 8 edges>, 
  <immutable digraph with 9 vertices, 8 edges>, 
  <immutable digraph with 9 vertices, 8 edges>, 
  <immutable digraph with 9 vertices, 8 edges>, 
  <immutable digraph with 9 vertices, 8 edges>, 
  <immutable digraph with 9 vertices, 8 edges> ]
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

#  AutomorphismGroup: for a digraph, 2
# PJC example, 45 vertices.
# This example is broken if we use Digraphs rather than Graphs in the bliss
# code
gap> gr := DigraphFromDigraph6String(Concatenation(
> "+l??O?C?A_@???CE????GAAG?C??M?????@_?OO??G??@?IC???_C?G?o??C?AO???c_??A?",
> "A?S???OAA???OG???G_A??C?@?cC????_@G???S??C_?C???[??A?A?OA?O?@?A?@A???GGO",
> "??`?_O??G?@?A??G?@AH????AA?O@??_??b???Cg??C???_??W?G????d?G?C@A?C???GC?W",
> "?????K???__O[??????O?W???O@??_G?@?CG??G?@G?C??@G???_Q?O?O?c???OAO?C??C?G",
> "?O??A@??D??G?C_?A??O?_GA??@@?_?G???E?IW??????_@G?C??"));
<immutable digraph with 45 vertices, 180 edges>
gap> H := AutomorphismGroup(gr);
<permutation group with 4 generators>

# G = PrimitiveGroup(45, 3);
gap> G := Group([
> (1, 2, 18, 20)(3, 40, 25, 19)(4, 33, 35, 30)(5, 29, 43, 9)(6, 36, 12, 26)
> (7, 27, 39, 13)(8, 17)(10, 41, 31, 32)(14, 37, 45, 22)(15, 28, 38, 21)
> (16, 34, 24, 42)(23, 44),
> (1, 44, 16, 25, 33, 40, 31, 39, 34, 38)(2, 14, 12, 37, 28, 6, 13, 9, 42, 30)
> (3, 45, 5, 41, 11, 36, 4, 27, 15, 10)(7, 19, 43, 8, 35)
> (17, 23, 26, 24, 22, 20, 29, 21, 18, 32)]);;
gap> IsomorphismGroups(G, H) <> fail;
true

#  AutomorphismGroup: for a digraph, 3
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
<immutable digraph with 1000 vertices, 1000 edges>
gap> AutomorphismGroup(gr);
<permutation group of size 1000 with 1 generators>
gap> Size(last);
1000
gap> AutomorphismGroup(CompleteDigraph(6)) = SymmetricGroup(6);
true

#  AutomorphismGroup: for a MultiDigraph, 1
gap> gr := DigraphEdgeUnion(CycleDigraph(3), CycleDigraph(3));
<immutable multidigraph with 3 vertices, 6 edges>
gap> AutomorphismGroup(gr);
Group([ (1,2,3), (8,9), (6,7), (4,5) ])
gap> Size(last);
24
gap> gr := DigraphEdgeUnion(CycleDigraph(50), CycleDigraph(50));
<immutable multidigraph with 50 vertices, 100 edges>
gap> AutomorphismGroup(gr);
<permutation group with 51 generators>
gap> Size(last);
56294995342131200

#  CanonicalLabelling: for a digraph, 1
# PJC example, 45 vertices
gap> gr := DigraphFromDigraph6String(Concatenation(
> "+l??O?C?A_@???CE????GAAG?C??M?????@_?OO??G??@?IC???_C?G?o??C?AO???c_??A?",
> "A?S???OAA???OG???G_A??C?@?cC????_@G???S??C_?C???[??A?A?OA?O?@?A?@A???GGO",
> "??`?_O??G?@?A??G?@AH????AA?O@??_??b???Cg??C???_??W?G????d?G?C@A?C???GC?W",
> "?????K???__O[??????O?W???O@??_G?@?CG??G?@G?C??@G???_Q?O?O?c???OAO?C??C?G",
> "?O??A@??D??G?C_?A??O?_GA??@@?_?G???E?IW??????_@G?C??"));
<immutable digraph with 45 vertices, 180 edges>
gap> BlissCanonicalLabelling(gr);
(1,45,24,25,39,37,31,15,35,5,12,19,28,44,21,20,7,14,43,41,42,38,32,34,23,4,13,
11,8,29,22,3,9,40,33,6,10,30)(2,16,27,18)(17,36)
gap> not DIGRAPHS_NautyAvailable or NautyCanonicalLabelling(gr) =
> (2, 22, 33, 35, 34, 8, 13, 37, 6, 28)(3, 29, 15, 45, 9, 38, 7, 24, 17, 44,
> 14)(4, 25, 39, 40, 42, 41, 5, 36, 19, 21, 11, 31, 23, 32, 43)(10, 12)(16,
> 20, 30, 26)(18, 27);
true

#  CanonicalLabelling: for a digraph, 2
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
<immutable digraph with 100 vertices, 1011 edges>
gap> BlissCanonicalLabelling(gr);
(1,33,95,99,73,52,41,75,14,30,22,64,47,83,17,40,100,71,51,97,39,27,65,15,37,
80,10,8,59,92,49,7,68,28,98,29,38,90,34,31,79,3,72,43,16,96,21,91,44,87,74,4,
62,56,13,18,60,69,77,67,20,35,45,89,2,54,32,78,66,25,57,94,5,50,53,42,46)(6,
19,93,86)(9,55,70,63,82,81,48,85,88,58)(11,36,61,76,26,84,24,23)
gap> not DIGRAPHS_NautyAvailable or NautyCanonicalLabelling(gr) =
> (1, 89, 53, 28, 82, 96, 72, 37, 9, 12, 97, 18, 65, 44, 84, 66, 5, 77, 6, 62,
> 31, 76, 48, 50, 15, 7, 34, 25, 78, 38, 59, 91, 64, 83, 55, 8, 24, 29, 32, 40,
> 81, 4, 58, 45, 49, 99, 85, 17, 73)(2, 21, 10, 46, 57, 88, 20, 74, 70, 75, 51,
> 67, 79, 11, 71, 42, 90, 52, 14, 19, 93, 16, 47, 100, 60, 54, 41, 69, 61, 94,
> 30, 33, 26, 13, 86, 98, 95, 80, 27, 63, 43, 87, 3, 36, 39, 68)(35, 92, 56);
true

#  CanonicalLabelling: for a digraph, 3
gap> gr := ReadDigraphs(
> Concatenation(DIGRAPHS_Dir(), "/data/test-1.d6"))[1];
<immutable digraph with 1000 vertices, 100368 edges>
gap> BlissCanonicalLabelling(gr);
(1,697,942,320,810,418,950,461,926,984,379,840,907,380,819,973,50,991,664,345,
877,128,896,565,53,637,444,987,967,629,9,362,39,242,353,512,723,431,172,874,
143,612,963,586,84,752,200,25,23,535,190,216,419,159,406,562,731,385,758,463,
738,462,147,891,610,882,928,876,424,44,786,869,509,906,675,649,831,440,57,316,
346,590,844,938,201,213,546,33,799,634,972,454,235,438,185,284,772,447,732,
239,244,777,227,209,270,740,61,899,976,837,73,763,32,404,328,931,98,99,352,
276,716,952,178,577,978,543,944,87,108,803,630,306,790,21,88,295,489,599,726,
232,826,132,70,65,860,859,764,54,223,208,189,596,529,734,970,356,875,494,775,
569,625,38,255,148,315,904,56,574,34,949,981,488,218,581,847,393,55,31,304,
474,739,69,911,594,426,507,707,402,933,759,714,914,90,989,669,222,265,382,491,
104,871,78,576,340,131,41,939,821,286,666,935,35,479,323,667,886,198,303,74,
960,619,604,193,212,815,690,430,219,771,2,788,451,289,155,833,988,614,319,394,
119,285,127,187,344,278,888,81,975,492,651,435,609,713,660,915,538,17,986,364,
930,294,999,237,120,240,703,301,572,980,851,834,795,873,166,700,792,858,332,
711,478,779,898,82,350,611,234,161,249,111,760,387,49,154,272,663,733,373,206,
937,311,167,671,655,957,349,800,151,823,269,686,92,191,918,854,825,638,658,
229,661,7,145,207,28,912,636,66,648,516,389,215,561,72,407,499,829,856,341,
584,20,357,698,156,521,135,541,397,268,701,578,900,588,691,785,146,587,470,
540,483,784,141,422,710,8,434,106,979,30,203,122,296,417,890,351,411,133,936,
866,570,855,468,381,471,951,126,903,477,808,195,267,798,448,248,377,736,347,
291,80,946,654,358,864,324,961,536,123,264,678,413,721,370,602,64,273,450,985,
853,26,982,802,288,681,539,993,889,277,238,503,188,445,465,363,257,52,475,245,
192,725,508,846,868,996,849,724,403,256,966,443,298,279,89,250,12,679,553,560,
446,652,226,575,735,687,862,129,517,761,150,893,365,16,421,170,274,727,13,839,
794,524,811,5,812,852,211,310,458,480,835,600,680,302,566,342,179,321,498,130,
945,110,656,597,814,391,473,395,677,592,559,225,797,757,482,932,102,199,251,
857,618,221,994,749,537,423,117,359,287,756,197,563,355,214,485,95,77,4,544,
626,628,789,689,816,549,369,186,719,705,769,741,10,472,149,224,954,449,676,
202,668,872,688,830,6,684,71,97,14,917,476,863,501,401,500,502,184,633,386,
333,620,325,969,384,405,755,137,230,22,953,708,314,702,801,523,210,293,275,
228,169,75,177,205,85,530,484,573,913,263,456,841,436,93,183,564,653,692,317,
307,947,372,585,624,527,754,861,623,453,640,693,657,603,496,867,519,144,631,
908,290,513,464,695,138,37,722,901,878,832,252,706,168,729,361,91,58,838,753,
415,388,1000,968,897,46,905,783,971,650,457,48,921,109,375,850,965,511,29,780,
79,329,3,220,460,266,767,36,642,776,348,236,525,750,258,902,118,532,892,142,
495,645,641,554,429,533,51,121,646,998,974,467,809,817,59,884,412,550,396,843,
271,254,105,696,948,160,125,845,820,601,793,545,280,743,593,662,441,672,196,
925,704,76,520,233,608,63,305,318,605,717,977,231,173,469,409,490,558,112,699,
582,115,958,643,934,378,547,737)( [...] )
gap> not DIGRAPHS_NautyAvailable or NautyCanonicalLabelling(gr) =
> (1, 200, 900, 668, 405, 108, 934, 891, 56, 488, 995, 648, 428, 833, 241,
>   942, 22, 817, 690, 337, 986, 204, 373, 930, 644, 299, 261, 801, 699, 809,
>   768, 952, 11, 114, 467, 662, 747, 476, 103, 568, 324, 959, 292, 598, 302,
>   221, 957, 531, 596, 47, 715, 947, 709, 469, 273, 943, 621, 750, 805, 360,
>   551, 253, 12, 511, 295, 96, 84, 422, 53, 914, 992, 972, 91, 706, 987,
>   755, 244, 951, 89, 961, 605, 601, 14, 50, 997, 752, 782, 246, 734, 713,
>   525, 433, 219, 486, 710, 293, 197, 194, 30, 925, 632, 665, 213, 161, 620,
>   238, 922, 515, 478, 264, 5, 897, 377, 853, 599, 509, 869, 220, 359, 814,
>   196, 625, 504, 76, 524, 832, 698, 998, 3, 426, 153, 948, 128, 112, 336,
>   703, 847, 571, 903, 840, 548, 143, 156, 517, 654, 370, 75, 464, 159, 366,
>   184, 830, 674, 303, 858, 655, 865, 489, 275, 276, 281, 880, 936, 226, 498,
>   328, 201, 371, 468, 761, 364, 110, 431, 989, 919, 931, 590, 99, 693, 458,
>   135, 384, 744, 733, 751, 528, 307, 927, 719, 748, 32, 420, 650, 217, 692,
>   890, 874, 889, 258, 720, 630, 635, 944, 13, 639, 339, 306, 864, 206, 634,
>   164, 330, 234, 139, 863, 841, 673, 946, 415, 849, 317, 27, 622, 803, 309,
>   966, 60, 701, 651, 149, 54, 878, 589, 871, 732, 521, 175, 758, 418, 434,
>   762, 845, 536, 166, 372, 544, 738, 392, 254, 534, 280, 821, 778, 807, 574,
>   657, 92, 98, 680, 495, 225, 271, 956, 342, 396, 173, 579, 965, 308, 487,
>   388, 532, 899, 212, 831, 210, 402, 555, 567, 255, 797, 286, 770, 704, 789,
>   712, 409, 117, 763, 115, 945, 145, 608, 236, 788, 671, 457, 700, 911, 896,
>   190, 981, 147, 154, 82, 352, 242, 575, 838, 451, 836, 62, 729, 39, 578,
>   565, 962, 119, 721, 614, 443, 385, 539, 971, 232, 218, 792, 285, 885, 628,
>   735, 178, 661, 611, 410, 185, 561, 387, 780, 466, 950, 407, 86, 855, 563,
>   559, 87, 976, 584, 193, 708, 985, 705, 369, 728, 629, 848, 195, 158, 222,
>   316, 772, 46, 179, 61, 494, 381, 647, 202, 851, 542, 685, 186, 344, 296,
>   430, 35, 877, 134, 262, 109, 819, 932, 58, 793, 290, 338, 585, 682, 739,
>   938, 879, 707, 684, 101, 284, 95, 736, 121, 169, 822, 252, 399, 660, 272,
>   606, 416, 368, 616, 799, 146, 984, 913, 266, 345, 257, 499, 663, 779, 485,
>   245, 168, 609, 610, 380, 954, 435, 17, 150, 291, 267, 327, 753, 461, 126,
>   818, 558, 624, 953, 642, 785, 894, 689, 137, 320, 808, 375, 470, 627, 294,
>   990, 520, 403, 688, 714, 496, 587, 556, 603, 503, 9, 389, 566, 502, 837,
>   960, 395, 20, 535, 38, 37, 215, 140, 806, 97, 268, 447, 669, 783, 917,
>   852, 68, 412, 331, 820, 278, 569, 774, 85, 314, 473, 760, 804, 270, 484,
>   439, 216, 465, 174, 631, 100, 513, 453, 155, 866, 319, 935, 554, 335, 125,
>   116, 21, 8, 340, 235, 408, 122, 617, 479, 191, 176, 157, 239, 872, 183,
>   198, 404, 456, 130, 926, 227, 857, 350, 69, 471, 633, 36, 727, 483, 549,
>   580, 425, 649, 886, 741, 764, 940, 600, 861, 659, 786, 683, 993, 749, 765,
>   664, 730, 446, 237, 347, 996, 362, 390, 429, 906, 162, 902, 26, 138, 163,
>    83, 638, 427, 259, 66, 862, 790, 160, 623, 70, 144, 411, 905, 450, 978,
>   573, 607, 526, 133, 636, 777, 211, 357, 287, 247, 318, 203, 812, 152, 967,
>   854, 148, 423, 643, 480, 189, 42, 15, 594, 781, 455, 825, 582, 51, 588,
>    23, 301, 417, 132, 93, 545, 355, 233, 474, 300, 560, 773, 351, 326, 676,
>   867, 501, 229, 522, 859, 844, 118, 59, 28, 737, 771, 438, 448, 843, 915,
>   363, 406, 181, 57, 367, 641, 107, 442, 523, 929, 289, 72, 19, 868, 440,
>   856, 937, 798, 182, 691, 576, 939, 510, 40, 493, 743, 248, 860, 398, 414,
>   968, 477, 653, 44, 645, 80, 361, 994, 979, 269, 613, 586, 33, 717, 912,
>   243, 45, 527, 626, 802, 811, 41, 127, 24, 982, 251, 969, 963, 716, 754,
>   497, 310, 348, 500, 209, 279, 6, 983, 949, 980, 757, 540, 591, 516, 519,
>   916, 71, 888, 180, 343, 923, 208, 31, 43, 975, 557, 533, 745, 846, 612,
>   887, 505, 492, 214, 766, 512, 274, 475, 884, 397, 619, 775, 313, 452, 106,
>   958, 514, 16, 618, 120, 546, 79, 436, 835, 311, 970, 322, 672, 507, 724,
>   842, 167, 7, 205, 25, 711, 875, 151, 604, 325, 941, 199, 928, 321, 230,
>   695, 365, 918, 679, 876, 702, 304, 726, 374, 88, 892, 791, 171, 29, 333,
>   394, 55, 240, 481, 681, 955, 597, 904, 883, 393, 908, 131, 767, 506, 530,
>   334, 577, 670, 1000, 746, 988, 207, 354, 74, 595, 677, 815, 10, 640, 52,
>   826, 256, 697, 282, 298, 341, 881, 482, 823, 376, 901, 382, 18, 541, 924,
>   895, 421, 686, 999, 508, 170, 177, 667, 460, 562, 615, 731, 73, 742, 459,
>   796, 129, 463, 104, 759, 827, 696, 795, 386, 666, 538, 305, 472, 277, 490,
>    78, 564, 297, 349, 250, 283, 136, 332)(2, 723, 834, 383, 991, 646, 898,
>   124, 64, 90, 973, 816, 656, 907, 964, 113, 909, 111, 583, 263, 223, 933,
>   581, 224, 784, 658, 329, 570, 810, 432, 740, 48, 228, 550, 537, 637, 882,
>   265, 529, 794, 718, 910, 346, 829, 687, 462, 188, 172, 553, 105, 187, 378,
>   445, 454, 424, 401, 787, 231)(4, 543, 920, 444, 974, 547, 192, 353, 312,
>   419, 81, 977, 358, 141, 602, 356, 249, 722, 678, 391, 694, 437, 379, 491,
>   400, 592, 67, 572)(34, 800, 165, 839, 65)(49, 873, 850, 921, 769, 63,
>  315, 756, 518, 652, 123, 552, 288, 441)(77, 413, 94, 323, 813, 725, 142,
>   449, 675)(102, 776, 893, 260, 870, 824, 828);;

#  CanonicalLabelling: for a MultiDigraph, 1
gap> gr1 := DigraphEdgeUnion(CycleDigraph(3), CycleDigraph(3));
<immutable multidigraph with 3 vertices, 6 edges>
gap> perms := BlissCanonicalLabelling(gr1);
[ (1,3), (1,6)(2,3,5) ]
gap> gr2 := OnMultiDigraphs(gr1, perms);
<immutable multidigraph with 3 vertices, 6 edges>
gap> BlissCanonicalLabelling(gr2);
[ (1,3,2), (1,6,4)(2,3) ]
gap> OnMultiDigraphs(gr2, last) = gr2;
true
gap> gr2 = gr1;
false

#  IsIsomorphicDigraph: for digraphs, 1
gap> p := Random(SymmetricGroup(1000));;
gap> gr2 := OnDigraphs(gr, p);
<immutable digraph with 1000 vertices, 100368 edges>
gap> gr = gr2;
false
gap> IsIsomorphicDigraph(gr, gr2);
true
gap> IsIsomorphicDigraph(gr2, gr);
true
gap> ForAny(graph5, x -> Number(graph5, y -> IsIsomorphicDigraph(x, y)) <> 1);
false

#  IsIsomorphicDigraph: for MultiDigraphs, 1
gap> gr1 := Digraph([[3, 1, 3], [1, 3], [2, 2, 1]]);
<immutable multidigraph with 3 vertices, 8 edges>
gap> gr2 := Digraph([[3, 1, 3], [1, 3], [2, 2]]);
<immutable multidigraph with 3 vertices, 7 edges>
gap> IsIsomorphicDigraph(gr1, gr2);
false
gap> gr3 := Digraph([[3, 1, 3], [1, 3], [2, 2], []]);
<immutable multidigraph with 4 vertices, 7 edges>
gap> IsIsomorphicDigraph(gr1, gr3);
false
gap> IsIsomorphicDigraph(gr2, gr3);
false
gap> gr4 := Digraph([[2, 3, 3], [2, 1, 1], [1, 2]]);
<immutable multidigraph with 3 vertices, 8 edges>
gap> IsIsomorphicDigraph(gr1, gr4);
true
gap> IsIsomorphicDigraph(gr2, gr4);
false
gap> IsIsomorphicDigraph(gr3, gr4);
false
gap> IsIsomorphicDigraph(gr4, gr4);
true

#  IsomorphismDigraphs: for digraphs, 1
gap> gr1 := CompleteBipartiteDigraph(100, 50);
<immutable digraph with 150 vertices, 10000 edges>
gap> gr2 := CompleteBipartiteDigraph(50, 100);
<immutable digraph with 150 vertices, 10000 edges>
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

#  IsomorphismDigraphs: for MultiDigraphs, 1
gap> gr1 := Digraph([[3, 1, 3], [1, 3], [2, 2, 1]]);
<immutable multidigraph with 3 vertices, 8 edges>
gap> gr4 := Digraph([[2, 3, 3], [2, 1, 1], [1, 2]]);
<immutable multidigraph with 3 vertices, 8 edges>
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

#  DIGRAPHS_UnbindVariables
gap> Unbind(H);
gap> Unbind(gr);
gap> Unbind(gr1);
gap> Unbind(gr2);
gap> Unbind(gr3);
gap> Unbind(gr4);
gap> Unbind(graph5);
gap> Unbind(group5);
gap> Unbind(iso);
gap> Unbind(p);
gap> Unbind(perms);
gap> Unbind(treeAuts);
gap> Unbind(trees);

#E#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: extreme/isomorph.tst", 0);
