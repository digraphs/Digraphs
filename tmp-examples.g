#a so called dual polar graph: the vertices are the set of totally isotropic
#spaces with relation to a sesquilinear form. Two vertices are adjacent iff they
#have only the zero vector in common.
#in this easy example the polar space comes from a hermitian form on a five
#dimensional projective space. We know that cliques should have size at most q ^
#3 + 1.
q := 2;
ps := HermitianPolarSpace(5, q ^ 2);
planes := Set(AsList(Planes(ps))); #will be the set of vertices
group := CollineationGroup(ps);
# the full automorphism group of this hermitian polar space
adj := function(x, y)
  return ProjectiveDimension(Meet(x, y)) = -1;
end;
digraph := Digraph(group, planes, OnProjSubspaces, adj);

#again a dual polar graph: in this case the vertices are the set of totally
#isotropic spaces with relation to a hermitian form on a four dimensional
#projective space.  #if you can show that this graph has no clique of size 3 ^ 5
#+ 1 = 244, you become very famous in the empire of finite geometry!
q := 3;
ps := HermitianPolarSpace(4, q ^ 2);
lines := Set(AsList(Lines(ps))); #will be the set of vertices
group := CollineationGroup(ps);
# the full automorphism group of this hermitian polar space
adj := function(x, y)
  return ProjectiveDimension(Meet(x, y)) = -1;
end;
digraph := Digraph(group, lines, OnProjSubspaces, adj);

#A bipartite graph coming from a generalized quadrangle. So this graph must
# have diameter 4 and grith 8.
q := 8;
ps := ParabolicQuadric(4, q);
pts := Set(AsList(Points(ps)));
lines := Set(AsList(Lines(ps)));
vertices := Union(pts, lines);
group := CollineationGroup(ps);
adj := function(x, y)
  if x in pts and y in pts then
    return false;
  elif x in lines and y in lines then
    return false;
  else
    return x * y;
  fi;
end;
digraph := Digraph(group, vertices, \ ^ , adj);

#another bipartite graph coming from a GQ, but now the GQ is constructed as a
# coset geometry.
#note that in this case the group used to construct the graph is much smaller
# than the complete automorphism group.
q := 3 ^ 3;
g := ElementaryAbelianGroup(q);
flist1 := [Group(g.1), Group(g.2), Group(g.3), Group(g.1 * g.2 * g.3)];
flist2 := [Group([g.1, g.2 ^ 2 * g.3]), Group([g.2, g.1 ^ 2 * g.3]),
           Group([g.3, g.1 ^ 2 * g.2]), Group([g.1 ^ 2 * g.2, g.1 ^ 2 * g.3])];
egq := EGQByKantorFamily(g, flist1, flist2);
pts := Set(AsList(Points(egq)));
lines := Set(AsList(Lines(egq)));
vertices := Union(pts, lines);
group := ElationGroup(egq);
adj := function(x, y)
  if x in pts and y in pts then
    return false;
  elif x in lines and y in lines then
    return false;
  else
    return x * y;
  fi;
end;
digraph := Digraph(group, vertices, OnKantorFamily, adj);

#A bipartite graph coming from a generalized hexagon. So this graph must have
#diameter 6 and grith 12.
q := 4;
gp := SplitCayleyHexagon(q);
pts := Set(Points(gp));
lines := Set(Lines(gp));
vertices := Union(pts, lines);
group := CollineationGroup(gp);
adj := function(x, y)
  if x in pts and y in pts then
    return false;
  elif x in lines and y in lines then
    return false;
  else
    return x * y;
  fi;
end;
digraph := Digraph(group, vertices, \^, adj);

#my favorite: a generalized octagon. Girth is a problem for this example.
LoadPackage( "AtlasRep" );
titsgroup:=AtlasGroup("2F4(2)'");
g1:=AtlasSubgroup(titsgroup,3);
g2:=AtlasSubgroup(titsgroup,5);
conj:=ConjugacyClassSubgroups(titsgroup,g1);;
g1:=First(conj, sg -> Size(Intersection(sg,g2))=2048);
cg:=CosetGeometry(titsgroup,[g1,g2]);;
pts := Set(ElementsOfIncidenceStructure(cg,1));;
lines := Set(ElementsOfIncidenceStructure(cg,2));;
vertices := Union(pts,lines);;
adj := function(x,y)
return x * y and x!.type <> y!.type;
end;
digraph := Digraph(titsgroup,vertices,OnCosetGeometryElement,adj);



