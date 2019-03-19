
##  AutomorphismGroup: for a digraph with multiple edges
#
## An edge union of complete digraphs
# gap> gr := DigraphEdgeUnion(CompleteDigraph(4), CompleteDigraph(4));
# <multidigraph with 4 vertices, 24 edges>
# gap> G := AutomorphismGroup(gr);;
# gap> Image(Projection(G, 1)) = SymmetricGroup(4);
# true
# gap> StructureDescription(Image(Projection(G, 2)));
# "C2 x C2 x C2 x C2 x C2 x C2 x C2 x C2 x C2 x C2 x C2"
# 
# # A small example
# gap> gr := Digraph([[2], [1, 3], [], [3, 3]]);
# <multidigraph with 4 vertices, 5 edges>
# gap> G := AutomorphismGroup(gr);
# Group([ (), (1,2) ])
# gap> IsTrivial(Image(Projection(G, 1)));
# true
# gap> Image(Projection(G, 2));
# Group([ (4,5) ])
# 
# # A larger example
# gap> gr := Digraph([
# >   [5, 7, 8, 4, 6, 1], [3, 1, 7, 2, 7, 9], [1, 5, 2, 3, 9],
# >   [1, 3, 3, 9, 9], [6, 3, 5, 7, 9], [3, 9],
# >   [8, 3, 6, 8, 8, 7, 7, 8, 9], [6, 1, 6, 7, 8, 4, 2, 5, 4],
# >   [1, 5, 2, 3, 9]]);
# <multidigraph with 9 vertices, 52 edges>
# gap> G := AutomorphismGroup(gr);;
# gap> Size(G);
# 3072
# gap> Image(Projection(G, 1)) = Group((3, 9));
# true
# gap> Image(Projection(G, 2)) = Group([(21, 22), (34, 37), (35, 36), (39, 41),
# > (44, 47), (9, 11)(33, 37, 34), (19, 20)(30, 34)(33, 37)]);
# true
# gap> BlissCanonicalLabelling(gr)
# > = BlissCanonicalLabelling(DigraphCopy(gr));
# true
# 
# # A random example
# gap> gr := Digraph([
# >   [5, 7, 8, 4, 6, 1], [3, 1, 7, 2, 7, 9], [1, 5, 2, 3, 9],
# >   [1, 3, 3, 9, 9], [6, 3, 5, 7, 9], [3, 9],
# >   [8, 3, 6, 8, 8, 7, 7, 8, 9], [6, 1, 6, 7, 8, 4, 2, 5, 4],
# >   [1, 5, 2, 3, 9]]);
# <multidigraph with 9 vertices, 52 edges>
# gap> IsIsomorphicDigraph(gr, gr);
# true
# gap> gr1 := OnDigraphs(gr, (3, 9)(1, 2, 7, 5));;
# gap> IsIsomorphicDigraph(gr, gr1);
# true
# gap> gr2 := OnDigraphs(gr, (3, 9));;
# gap> IsIsomorphicDigraph(gr, gr2);
# true
# 
# #  IsIsomorphicDigraph: for multidigraphs with colourings
# gap> gr1 := Digraph([[2, 1, 2], []]);;
# gap> gr2 := Digraph([[], [2, 1, 1]]);;
# gap> IsIsomorphicDigraph(gr1, gr1, [1, 1], [1, 1]);
# true
# gap> IsIsomorphicDigraph(gr1, gr1, [1, 1], [1, 2]);
# false
# gap> IsIsomorphicDigraph(gr1, gr2, [1, 2], [2, 1]);
# true
# gap> IsIsomorphicDigraph(gr1, gr2, [1, 2], [1, 2]);
# false
# 
# #  IsomorphismDigraphs: for digraphs with multiple edges
# 
# # An example used in previous tests
# gap> gr := Digraph([
# >   [5, 7, 8, 4, 6, 1], [3, 1, 7, 2, 7, 9], [1, 5, 2, 3, 9],
# >   [1, 3, 3, 9, 9], [6, 3, 5, 7, 9], [3, 9],
# >   [8, 3, 6, 8, 8, 7, 7, 8, 9], [6, 1, 6, 7, 8, 4, 2, 5, 4],
# >   [1, 5, 2, 3, 9]]);
# <multidigraph with 9 vertices, 52 edges>
# gap> IsomorphismDigraphs(gr, gr);
# [ (), () ]
# gap> BlissCanonicalLabelling(gr);
# [ (1,5,4,2,3,7,9,6), (1,30,49)(2,34,47,35,45,39,38,51,8,12,18,24,21,28,23,13,
#     4,29,22,27,20,25,14)(3,33,48)(5,31,52,7,19,26,17,9,16,10,11,15,6,32,
#     50)(36,44)(37,46,40,41)(42,43) ]
# gap> NautyCanonicalLabelling(gr);
# fail
# gap> AutomorphismGroup(gr);
# <permutation group with 10 generators>
# gap> p := (1, 8, 2)(3, 5, 4, 9, 7);;
# gap> gr1 := OnDigraphs(gr, p);
# <multidigraph with 9 vertices, 52 edges>
# gap> iso := IsomorphismDigraphs(gr, gr1);
# [ (1,8,2)(3,5,4,9,7), (1,42,10,4,45,13,30,16,33,19,49,38,24,26,28,35,21,51,40,
#     8,2,43,11,5,46,14,31,17,34,20,50,39,7)(3,44,12,6,47,15,32,18,48,37,23,25,
#     27,29,36,22,52,41,9) ]
# gap> OnMultiDigraphs(gr, iso) = gr1;
# true
# gap> iso[1] = p;
# true
# gap> p := (1, 7, 8, 4)(2, 6, 5);;
# gap> gr1 := OnDigraphs(gr, p);
# <multidigraph with 9 vertices, 52 edges>
# gap> iso := IsomorphismDigraphs(gr, gr1);
# [ (1,7,8,4)(2,6,5), (1,33,42,19,2,34,43,20,3,35,44,21,4,36,45,22,5,37,46,23,6,
#     38,47,24,7,27,10,30,39,16,14,12,32,41,18)(8,28,25)(9,29,26)(11,31,40,17,
#     15,13) ]
# gap> OnMultiDigraphs(gr, iso) = gr1;
# true
# gap> iso[1] = p;
# true
# 
# #  IsomorphismDigraphs: for multidigraphs with colourings
# gap> gr1 := Digraph([[2, 1, 2], []]);;
# gap> gr2 := Digraph([[], [2, 1, 1]]);;
# gap> IsomorphismDigraphs(gr1, gr1, [1, 1], [1, 1]);
# [ (), () ]
# gap> IsomorphismDigraphs(gr1, gr1, [1, 1], [1, 2]);
# fail
# gap> IsomorphismDigraphs(gr1, gr2, [1, 2], [2, 1]);
# [ (1,2), (1,2) ]
# gap> IsomorphismDigraphs(gr1, gr2, [1, 2], [1, 2]);
# fail
# gap> IsomorphismDigraphs(gr1, gr2, [1, 1], [1, 1]);
# [ (1,2), (1,2) ]
# 
# 
# #  CanonicalLabelling: for a digraph with multiple edges
# 
# # A small example: check that all isomorphic copies have same canonical image
# gap> gr := Digraph([[2, 2], [1, 1], [2]]);
# <multidigraph with 3 vertices, 5 edges>
# gap> BlissCanonicalLabelling(gr);
# [ (1,2,3), (1,3,5) ]
# gap> canon := OutNeighbours(OnMultiDigraphs(gr, last));
# [ [ 3 ], [ 3, 3 ], [ 2, 2 ] ]
# gap> for i in SymmetricGroup(DigraphNrVertices(gr)) do
# > for j in SymmetricGroup(DigraphNrEdges(gr)) do
# >   new := OnMultiDigraphs(gr, [i, j]);
# >   if not OutNeighbours(OnMultiDigraphs(new,
# >       BlissCanonicalLabelling(new))) = canon then
# >     Print("fail");
# >   fi;
# > od; od;
# gap> gr1 := Digraph([[2, 2], [1, 3], [2]]);
# <multidigraph with 3 vertices, 5 edges>
# gap> gr = gr1;
# false
# gap> IsIsomorphicDigraph(gr, gr1);
# false
# gap> canon = OnMultiDigraphs(gr1, BlissCanonicalLabelling(gr1));
# false
# gap> NautyCanonicalLabelling(gr);
# fail
# 
# #  AutomorphismGroup: for a multidigraph
# gap> gr := Digraph([[2, 2], []]);
# <multidigraph with 2 vertices, 2 edges>
# gap> AutomorphismGroup(gr, [1, 2]);
# Group([ (), (1,2) ])
# gap> NautyAutomorphismGroup(gr);
# fail
# gap> NautyAutomorphismGroup(gr, [1, 2]);
# fail
# 
# #  CanonicalLabelling: for a multidigraph
# gap> gr := Digraph([[2, 2], []]);
# <multidigraph with 2 vertices, 2 edges>
# gap> BlissCanonicalLabelling(gr, [1, 2]);
# [ (), (1,2) ]
# gap> NautyCanonicalLabelling(gr, [1, 2]);
# fail
# 
# # Canonical digraph
# gap> gr4 := Digraph([[3, 4], [2, 2, 3], [2, 2, 4], [2, 2, 3]]);;
# gap> gr5 := BlissCanonicalDigraph(gr4);;
# gap> gr5 = gr4;
# false
# gap> IsIsomorphicDigraph(gr4, gr5);
# true
# gap> gr5 = BlissCanonicalDigraph(gr4, [1, 1, 1, 1]);
# true
# gap> BlissCanonicalDigraph(gr4, [1, 2, 1, 2])
# > = BlissCanonicalDigraph(gr4, [[1, 3], [2, 4]]);
# true
# gap> gr5 = BlissCanonicalDigraph(gr5);
# true
# gap> gr6 := OnMultiDigraphs(gr4, [(1, 2), (5, 6)]);;
# gap> IsIsomorphicDigraph(gr4, gr6);
# true
# gap> gr5 = BlissCanonicalDigraph(gr6);
# true
# 
# #  AutomorphismGroup: for a multidigraph
# # CanonicalLabelling was being set incorrectly by AutomorphismGroup for
# # a multidigraph
# gap> gr := Digraph([
# >   [5, 7, 8, 4, 6, 1], [3, 1, 7, 2, 7, 9], [1, 5, 2, 3, 9],
# >   [1, 3, 3, 9, 9], [6, 3, 5, 7, 9], [3, 9],
# >   [8, 3, 6, 8, 8, 7, 7, 8, 9], [6, 1, 6, 7, 8, 4, 2, 5, 4],
# >   [1, 5, 2, 3, 9]]);
# <multidigraph with 9 vertices, 52 edges>
# gap> G := AutomorphismGroup(gr);;
# gap> HasBlissCanonicalLabelling(gr);
# true
# gap> BlissCanonicalLabelling(gr);
# [ (1,5,4,2,3,7,9,6), (1,30,49)(2,34,47,35,45,39,38,51,8,12,18,24,21,28,23,13,
#     4,29,22,27,20,25,14)(3,33,48)(5,31,52,7,19,26,17,9,16,10,11,15,6,32,
#     50)(36,44)(37,46,40,41)(42,43) ]
# gap> BlissCanonicalLabelling(gr) = BlissCanonicalLabelling(DigraphCopy(gr));
# true
# 

# gap> gr := Digraph([[2, 2, 4, 4], [1, 1, 3], [2], [1, 1, 5], [4]]);
# <multidigraph with 5 vertices, 12 edges>
# gap> DigraphGroup(gr);
# Group([ (2,4)(3,5) ])
# gap> DigraphDiameter(gr);
# 4
# gap> DigraphUndirectedGirth(gr);
# 2
# gap> gr := EmptyDigraph(0);;
# gap> DigraphUndirectedGirth(gr);
# infinity
# gap> DigraphDiameter(gr);
# fail

#  DistanceDigraph on multidigraph with known automorphisms
# gap> gr := Digraph([[1, 2, 2], [], [2, 2, 3]]);;
# gap> DigraphGroup(gr) = Group((1, 3));
# true
# gap> OutNeighbours(DistanceDigraph(gr, 0));
# [ [ 1 ], [ 2 ], [ 3 ] ]
# gap> OutNeighbours(DistanceDigraph(gr, 1));
# [ [ 2 ], [  ], [ 2 ] ]
# gap> OutNeighbours(DistanceDigraph(gr, 2));
# [ [  ], [  ], [  ] ]
