# https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/posets/hasse_diagram.html#sage.combinat.posets.hasse_diagram.HasseDiagram.find_nontrivial_congruence

IsJoinIrreducible := function(G, v)
    local hasse;
    hasse := DigraphReflexiveTransitiveReduction(G);
    # join-irreducible iff at most one lower cover
    return InDegreeOfVertex(hasse, v) <= 1;
end;

IsMeetIrreducible := function(G, v)
    local hasse;
    # meet-irreducible iff at most one upper cover
    hasse := DigraphReflexiveTransitiveReduction(G);
    return OutDegreeOfVertex(hasse, v) <= 1;
end;
