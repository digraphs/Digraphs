# Function that identifies a cograph from a symmetric digraph

# Created from the algorithm described in the paper "A Simple 
# Linear Time Recognition Algorithm for Cographs"

# Habib, M & Paul, C & Viennot (2005). A Simple Linear Time 
# Recognition Algorithm for Cographs. Discrete Applied Mathematics. 
# 145(2). 183-197. https://doi.org/10.1016/j.dam.2004.01.011.

IsCograph := function(D)
  local verts, P, origin, adj, part, neighbours, used_parts, unused_parts, 
  k, M, p, m, ma, j, n, v, zl, zr, prevorigin, new_P, t, current_part, zrpart, 
  pivot, zlpart, upd_m, pivotset, sigma, succz, precz, z, N_z, N_precz,
  N_succz, options, list, subpart;

    # input must be symmetric
    if not IsSymmetricDigraph(D) then;
    Error("IsCograph: argument must be a symmetric digraph");
    fi;

    verts := DigraphVertices(D);
    P := [verts];

    # a graph with fewer than 4 vertices cannot contain a P4 graph
    if Length(verts) < 4 then
        return true;
    fi;

    origin := 1;
    adj := OutNeighboursOfVertex(D, origin);
    if Length(adj) = 0 or Length(adj) = Length(verts) - 1 then
        return IsCograph(InducedSubdigraph(D, Filtered(verts, v -> v <> origin)));
    fi;

    # Algorithm 3: Partition Refinement
    while ForAll(P, part -> Length(part) <= 1) = false do
        k := PositionProperty(P, part -> origin in part);
        if Length(P[k]) > 1 then
            part := Remove(P, k);
            neighbours := OutNeighboursOfVertex(D, origin);
            part := [Filtered(neighbours, p -> p in part), [origin], 
            Difference(part, Union([origin], neighbours))];
            unused_parts := [part[1], part[3]];
            used_parts := [origin];
            for p in Filtered(part, u -> u <> []) do
                Add(P, p, k);
            od;
        fi;

    # Procedure 3
        new_P := ShallowCopy(P);
        if ForAll(new_P, part -> Length(part) <= 1) = true then
         break;
        fi;

        while Length(Filtered(unused_parts, u -> u <> [])) > 0 do
            options := Filtered(unused_parts, part -> Length(part) > 0);
            list := List(options, j -> Minimum(j));
            subpart := unused_parts[Position(list, Minimum(list))];

            if Filtered(subpart, u -> u in used_parts) = [] then
                pivot := Minimum(subpart);
            else
                pivot := subpart[part -> p in used_parts][1];
            fi;

            # Procedure 4
            M := [];
            current_part := ShallowCopy(new_P[PositionProperty(new_P, 
            part -> pivot in part)]);
            pivotset := OutNeighboursOfVertex(D, pivot); 

            for p in Difference(new_P, [current_part]) do
                if Intersection(p, pivotset) <> [] and 
                Intersection(p, pivotset) <> p 
                and Intersection(p, pivotset) <> [origin] then
                    k := ShallowCopy(Position(new_P, p));
                    Remove(new_P, k);
                    Add(M, p);
                fi;
            od;
    
            if M <> [] then
                for m in M do
                    ma := Filtered(m, p -> p in pivotset);
                    upd_m := [ma, Difference(m, ma)];
                    for t in Filtered(upd_m, x -> x <> []) do
                        Add(new_P, t, k);
                    od;
                    if m in unused_parts then
                        Remove(unused_parts, Position(unused_parts, m));
                        if not ma in unused_parts and ma <> [] then
                            Add(unused_parts, ma);
                        fi;
                        if not Difference(m, ma) in unused_parts and 
                        Difference(m,ma) <> [] then
                            Add(unused_parts, Difference(m, ma));
                        fi;
                    else
                        if Minimum(m) in upd_m[1] then
                            Add(unused_parts, upd_m[2]);
                        else
                            Add(unused_parts, upd_m[1]);
                        fi;
                    fi;
                    Add(used_parts, m);
                    Add(used_parts, pivot);
                od;
            fi;
            if current_part in unused_parts then
                Remove(unused_parts, Position(unused_parts, current_part));
            fi;
            Add(used_parts, current_part); 
        od;
        
        P := ShallowCopy(new_P);

        zlpart := PositionProperty(P, part -> Length(part) > 1 
        and Position(P, [origin]) > Position(P, part));
        zrpart := PositionProperty(P, part -> Length(part) > 1 
        and Position(P, [origin]) < Position(P, part));

        if zlpart = fail or zrpart = fail then
            if zlpart = fail and zrpart = fail then
                continue;
            elif zrpart = fail then 
                zl := ShallowCopy(Minimum(P[zlpart]));
                origin := ShallowCopy(zl);
            else
                zr := ShallowCopy(Minimum(P[zrpart]));
                origin := ShallowCopy(zr);
            fi;
        else
            zl := ShallowCopy(Minimum(P[zlpart]));
            zr := ShallowCopy(Minimum(P[zrpart]));
            if zl in OutNeighboursOfVertex(D, zr) then
                origin := ShallowCopy(zl);
            else 
                origin := ShallowCopy(zr);
            fi;
        fi;
    od;
  
  # Algorithm 5: Recognition Test

  sigma := [0];
  for p in P do
    for v in p do
      Add(sigma, v);
    od;
  od;
  Add(sigma, Length(verts) + 1);
  z := sigma[2];
  while z <> Length(verts) + 1 do
    succz := sigma[Position(sigma, z) + 1];
    precz := sigma[Position(sigma, z) - 1];
    N_z := Filtered(sigma, n -> n in 
    OutNeighboursOfVertex(D, z));
    if precz <> 0 then
      N_precz := Filtered(sigma, n -> n in 
      OutNeighboursOfVertex(D, precz));
    else
      N_precz := [0];
    fi;
    if succz <> Length(verts) + 1 then
      N_succz := Filtered(sigma, n -> n in 
      OutNeighboursOfVertex(D, succz));
    else
      N_succz := [0];
    fi;
    if N_z = N_precz or Union(N_z, [z]) = 
    Union(N_precz, [precz]) then
      Remove(sigma, Position(sigma, precz));
    elif N_z = N_succz or Union(N_z, [z]) = 
    Union(N_succz, [succz]) then
      z := succz;
      Remove(sigma, Position(sigma, precz) + 1);
    else
      z := succz;
    fi;
  od;
  return Length(Difference(sigma, [0, Length(verts)+1])) = 1;
end;