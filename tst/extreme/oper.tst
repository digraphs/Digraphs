#############################################################################
##
#W  extreme/oper.tst
#Y  Copyright (C) 2015                                   James D. Mitchell
##                                                       Michael C. Young
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: extreme/oper.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

#  OutNeighboursMutableCopy 1
# For a digraph with lots of edges: digraphs-lib/extreme.d6.gz
gap> gr := ReadDigraphs(Concatenation(DIGRAPHS_Dir(),
>                       "/digraphs-lib/extreme.d6.gz"), 1);
<immutable digraph with 5000 vertices, 4211332 edges>
gap> out := OutNeighboursMutableCopy(gr);;
gap> out := OutNeighborsMutableCopy(gr);;
gap> IsMutable(out);
true
gap> ForAll(out, IsMutable);
true
gap> out[1] := "a";
"a"
gap> SortedList(OutNeighbours(gr)[1]);
[ 3, 6, 8, 26, 28, 37, 42, 43, 49, 52, 56, 60, 67, 71, 80, 82, 87, 88, 92, 
  96, 98, 101, 105, 111, 118, 120, 121, 123, 129, 130, 135, 145, 148, 170, 
  173, 189, 195, 204, 208, 212, 214, 216, 220, 229, 232, 233, 237, 239, 245, 
  253, 264, 270, 275, 276, 282, 295, 297, 301, 304, 306, 308, 312, 320, 324, 
  331, 336, 346, 347, 351, 352, 354, 360, 363, 381, 388, 392, 395, 407, 414, 
  416, 419, 420, 426, 435, 438, 446, 449, 454, 455, 457, 459, 467, 470, 477, 
  478, 483, 495, 501, 507, 510, 524, 533, 543, 544, 550, 551, 553, 555, 558, 
  569, 579, 583, 593, 595, 600, 610, 617, 618, 620, 625, 637, 644, 651, 662, 
  663, 665, 675, 678, 683, 685, 691, 696, 727, 728, 740, 743, 745, 746, 751, 
  767, 772, 781, 785, 786, 787, 796, 807, 815, 817, 823, 834, 845, 857, 866, 
  870, 876, 889, 890, 903, 908, 910, 911, 930, 936, 948, 952, 965, 975, 1026, 
  1033, 1048, 1056, 1059, 1070, 1071, 1075, 1078, 1083, 1084, 1091, 1097, 
  1107, 1108, 1113, 1124, 1126, 1127, 1136, 1139, 1148, 1157, 1165, 1166, 
  1197, 1202, 1221, 1228, 1229, 1234, 1244, 1254, 1258, 1275, 1277, 1279, 
  1281, 1285, 1289, 1293, 1294, 1307, 1316, 1338, 1341, 1342, 1346, 1356, 
  1357, 1359, 1363, 1367, 1370, 1379, 1381, 1382, 1385, 1390, 1398, 1401, 
  1403, 1405, 1415, 1420, 1431, 1437, 1438, 1447, 1448, 1455, 1463, 1465, 
  1467, 1473, 1478, 1490, 1494, 1504, 1548, 1565, 1578, 1584, 1587, 1588, 
  1594, 1602, 1606, 1627, 1629, 1633, 1634, 1643, 1651, 1653, 1665, 1666, 
  1674, 1676, 1679, 1687, 1689, 1692, 1693, 1694, 1703, 1708, 1715, 1727, 
  1745, 1746, 1751, 1752, 1773, 1776, 1777, 1779, 1782, 1796, 1824, 1830, 
  1839, 1843, 1849, 1855, 1856, 1867, 1871, 1873, 1877, 1881, 1884, 1888, 
  1893, 1909, 1910, 1913, 1923, 1931, 1933, 1935, 1938, 1943, 1948, 1952, 
  1958, 1962, 1964, 1971, 1972, 1973, 1975, 1981, 1998, 2006, 2007, 2008, 
  2009, 2013, 2017, 2019, 2022, 2025, 2030, 2038, 2063, 2077, 2100, 2103, 
  2112, 2113, 2122, 2127, 2141, 2153, 2171, 2173, 2178, 2185, 2187, 2189, 
  2190, 2202, 2208, 2213, 2221, 2226, 2230, 2233, 2238, 2239, 2242, 2268, 
  2273, 2276, 2281, 2285, 2301, 2303, 2305, 2308, 2323, 2327, 2334, 2336, 
  2342, 2347, 2350, 2351, 2354, 2362, 2364, 2367, 2375, 2385, 2395, 2400, 
  2403, 2404, 2409, 2411, 2441, 2442, 2454, 2455, 2476, 2481, 2500, 2504, 
  2507, 2508, 2517, 2518, 2523, 2524, 2529, 2541, 2542, 2546, 2552, 2554, 
  2557, 2558, 2564, 2567, 2568, 2573, 2576, 2577, 2578, 2581, 2584, 2588, 
  2589, 2590, 2591, 2599, 2607, 2616, 2627, 2637, 2644, 2650, 2659, 2662, 
  2665, 2678, 2680, 2692, 2693, 2697, 2712, 2713, 2719, 2739, 2740, 2744, 
  2753, 2755, 2767, 2772, 2775, 2778, 2791, 2792, 2794, 2796, 2803, 2807, 
  2808, 2811, 2812, 2813, 2827, 2831, 2843, 2853, 2857, 2867, 2871, 2872, 
  2879, 2880, 2887, 2897, 2900, 2901, 2903, 2907, 2913, 2916, 2926, 2929, 
  2938, 2940, 2941, 2964, 2973, 2976, 2977, 2996, 3001, 3008, 3009, 3010, 
  3031, 3043, 3044, 3050, 3052, 3055, 3058, 3065, 3066, 3070, 3074, 3084, 
  3102, 3113, 3114, 3118, 3126, 3130, 3135, 3137, 3140, 3144, 3153, 3168, 
  3169, 3172, 3176, 3177, 3178, 3191, 3194, 3195, 3211, 3218, 3227, 3235, 
  3237, 3239, 3241, 3242, 3248, 3249, 3250, 3251, 3252, 3275, 3283, 3287, 
  3292, 3295, 3322, 3325, 3327, 3331, 3336, 3341, 3345, 3348, 3352, 3358, 
  3362, 3367, 3371, 3382, 3390, 3391, 3398, 3425, 3432, 3434, 3453, 3465, 
  3466, 3468, 3472, 3481, 3483, 3486, 3494, 3497, 3501, 3502, 3504, 3509, 
  3512, 3520, 3523, 3536, 3538, 3540, 3551, 3561, 3567, 3573, 3574, 3579, 
  3584, 3612, 3614, 3617, 3623, 3625, 3626, 3631, 3635, 3636, 3647, 3658, 
  3659, 3661, 3662, 3672, 3673, 3686, 3691, 3694, 3699, 3709, 3729, 3730, 
  3733, 3739, 3744, 3746, 3748, 3756, 3757, 3759, 3763, 3765, 3772, 3775, 
  3788, 3789, 3790, 3807, 3816, 3820, 3830, 3842, 3853, 3854, 3855, 3864, 
  3874, 3877, 3891, 3894, 3899, 3903, 3909, 3910, 3919, 3923, 3937, 3944, 
  3946, 3947, 3957, 3963, 3966, 3973, 3976, 3979, 3988, 3992, 3993, 3994, 
  3995, 3996, 4002, 4010, 4015, 4017, 4021, 4026, 4030, 4039, 4043, 4052, 
  4056, 4060, 4074, 4075, 4079, 4081, 4089, 4090, 4092, 4104, 4111, 4114, 
  4120, 4130, 4144, 4146, 4147, 4149, 4151, 4152, 4166, 4167, 4175, 4177, 
  4180, 4182, 4183, 4192, 4202, 4210, 4217, 4237, 4252, 4253, 4254, 4257, 
  4265, 4269, 4273, 4276, 4280, 4283, 4284, 4287, 4288, 4289, 4293, 4299, 
  4305, 4308, 4313, 4315, 4322, 4325, 4326, 4336, 4348, 4356, 4358, 4361, 
  4364, 4373, 4375, 4382, 4391, 4396, 4401, 4407, 4408, 4413, 4421, 4425, 
  4426, 4432, 4438, 4439, 4457, 4464, 4465, 4485, 4506, 4508, 4510, 4518, 
  4519, 4531, 4534, 4544, 4545, 4547, 4548, 4549, 4550, 4553, 4555, 4556, 
  4562, 4564, 4569, 4572, 4573, 4574, 4576, 4579, 4586, 4587, 4596, 4601, 
  4604, 4615, 4638, 4640, 4644, 4649, 4657, 4662, 4666, 4672, 4674, 4683, 
  4687, 4691, 4697, 4698, 4703, 4705, 4715, 4716, 4717, 4721, 4728, 4731, 
  4739, 4740, 4746, 4754, 4766, 4767, 4771, 4774, 4779, 4783, 4784, 4788, 
  4795, 4802, 4813, 4817, 4819, 4826, 4832, 4833, 4835, 4841, 4842, 4847, 
  4850, 4853, 4855, 4859, 4863, 4866, 4871, 4872, 4880, 4882, 4885, 4886, 
  4892, 4893, 4894, 4900, 4903, 4905, 4908, 4909, 4912, 4921, 4928, 4935, 
  4942, 4944, 4945, 4947, 4950, 4953, 4955, 4969, 4970, 4972, 4975, 4982, 
  4983, 4990, 4991, 4997 ]

#  DigraphReverseEdges 1
# For a digraph with lots of edges: digraphs-lib/extreme.d6.gz
gap> d := ReadDigraphs(Concatenation(DIGRAPHS_Dir(),
>                      "/digraphs-lib/extreme.ds6.gz"))[1];;
gap> DigraphReverseEdges(d, [[3, 16], [502, 1629], [100369, 54196]]);
<immutable digraph with 113082 vertices, 451854 edges>
gap> DigraphReverseEdge(d, [95000, 4067]);
<immutable digraph with 113082 vertices, 451854 edges>

#  DigraphLayers
gap> list := ReadDigraphs(Concatenation(DIGRAPHS_Dir(),
> "/digraphs-lib/fining.p.gz"));;
gap> gr := list[4];;
gap> gr2 := DigraphCopy(gr);;
gap> layers1 := List(DigraphLayers(gr, 1), Set);;
gap> layers2 := List(DigraphLayers(gr2, 1), Set);;
gap> layers1 = layers2;
true
gap> layers := [];;
gap> for i in list do
> Add(layers, DigraphLayers(i, 1));
> od;
gap> List(layers, Size);
[ 3, 3, 5, 5, 7, 9 ]
gap> gr := list[4];;
gap> DigraphLayers(gr, 1);
[ [ 1 ], [ 41, 50, 59, 68 ], [ 2, 3, 4, 5, 8, 10, 14, 27, 28, 31, 34, 37 ], 
  [ 42, 43, 44, 45, 46, 47, 48, 49, 51, 52, 53, 54, 55, 56, 57, 58, 60, 61, 
      62, 63, 64, 65, 66, 67, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80 ]
    , [ 6, 7, 9, 11, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 
      29, 30, 32, 33, 35, 36, 38, 39, 40 ] ]
gap> DigraphLayers(gr, 2);
[ [ 2 ], [ 41, 51, 60, 76 ], [ 5, 6, 7, 1, 13, 15, 19, 23, 29, 32, 34, 38 ], 
  [ 42, 43, 44, 45, 46, 47, 48, 49, 53, 54, 50, 56, 57, 52, 58, 55, 62, 63, 
      59, 65, 66, 61, 67, 64, 73, 71, 75, 68, 74, 69, 70, 72, 77, 78, 79, 80 ]
    , [ 11, 12, 14, 3, 4, 18, 20, 21, 22, 8, 9, 10, 24, 25, 26, 16, 17, 27, 
      30, 28, 33, 31, 35, 36, 39, 37, 40 ] ]
gap> DigraphLayers(gr, 8);
[ [ 8 ], [ 44, 50, 64, 71 ], [ 13, 1, 16, 18, 3, 23, 7, 25, 28, 33, 36, 39 ], 
  [ 41, 47, 42, 43, 49, 45, 46, 48, 51, 52, 53, 54, 55, 56, 57, 58, 66, 59, 
      67, 60, 61, 62, 63, 65, 68, 74, 69, 70, 76, 72, 73, 75, 77, 78, 79, 80 ]
    , [ 2, 21, 4, 5, 24, 6, 26, 9, 10, 11, 12, 27, 14, 15, 17, 19, 20, 22, 
      29, 30, 31, 32, 34, 35, 37, 38, 40 ] ]
gap> DigraphLayers(gr, 12);
[ [ 12 ], [ 43, 56, 62, 75 ], [ 4, 19, 20, 7, 24, 5, 17, 13, 28, 33, 35, 37 ],
  [ 45, 46, 47, 48, 41, 49, 42, 44, 52, 58, 54, 55, 53, 57, 50, 51, 59, 65, 
      60, 61, 67, 63, 64, 66, 76, 69, 73, 71, 72, 68, 74, 70, 77, 78, 79, 80 ]
    , [ 9, 10, 25, 14, 15, 16, 1, 27, 11, 21, 22, 2, 23, 3, 18, 26, 6, 8, 29, 
      30, 31, 32, 36, 34, 38, 39, 40 ] ]
gap> DigraphLayers(gr, 28);
[ [ 28 ], [ 50, 56, 57, 77 ], [ 1, 3, 12, 8, 19, 15, 24, 22, 26, 29, 30, 40 ],
  [ 41, 42, 43, 44, 45, 46, 47, 48, 49, 51, 52, 58, 53, 54, 55, 59, 61, 62, 
      64, 65, 60, 67, 63, 66, 68, 69, 75, 71, 76, 74, 73, 70, 72, 78, 79, 80 ]
    , [ 2, 6, 4, 13, 9, 20, 16, 25, 27, 5, 11, 7, 18, 14, 10, 21, 17, 23, 31, 
      32, 33, 34, 35, 36, 37, 38, 39 ] ]
gap> gr := list[5];
<immutable digraph with 2730 vertices, 13650 edges>
gap> DigraphOrbitReps(gr);
[ 1, 1366 ]
gap> Size(DigraphLayers(gr, 1));
7
gap> Size(DigraphLayers(gr, 1366));
7
gap> Size(DigraphLayers(gr, 7));
7
gap> SortedList(DigraphLayers(gr, 1)[2]);
[ 1366, 1367, 1368, 1369, 1370 ]
gap> SortedList(DigraphLayers(gr, 1366)[2]);
[ 1, 9, 341, 343, 351 ]
gap> SortedList(DigraphLayers(gr, 6)[2]);
[ 1391, 2144, 2395, 2544, 2645 ]
gap> SortedList(DigraphLayers(gr, 1500)[2]);
[ 81, 82, 169, 253, 254 ]

# DigraphCycleBasis
gap> gr := CompleteDigraph(800);
<immutable complete digraph with 800 vertices>
gap> DigraphCycleBasis(g);;
#I  The resulting matrix is going to be very large.

#  DIGRAPHS_UnbindVariables
gap> Unbind(d);
gap> Unbind(gr);
gap> Unbind(gr2);
gap> Unbind(i);
gap> Unbind(layers);
gap> Unbind(layers1);
gap> Unbind(layers2);
gap> Unbind(list);
gap> Unbind(out);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: extreme/oper.tst", 0);
