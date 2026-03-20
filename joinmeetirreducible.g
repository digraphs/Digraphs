IsJoinIrreducible := function(G, v)
    local joinTable, row, x, y;
    joinTable := DigraphJoinTable(G);

    for y in [1..Length(joinTable)] do
        if y = v then
            continue;
        fi;
        row := joinTable[y];
        for x in [1..Length(row)] do
            if x = v then
                continue;
            fi;
            if row[x] = v then
                return false;
            fi;
        od;
    od;

    return true;
end;


IsMeetIrreducible := function(G, v)
    local meetTable, row, x, y;
    meetTable := DigraphMeetTable(G);

    for y in [1..Length(meetTable)] do
        if y = v then
            continue;
        fi;
        row := meetTable[y];
        for x in [1..Length(row)] do
            if x = v then
                continue;
            fi;
            if row[x] = v then
                return false;
            fi;
        od;
    od;

    return true;
end;
