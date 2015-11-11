is_bipart := function(digraph)

  local n,colour,neighbours,queue,i,node,node_neighbours,root;
  #We want to explore out and in neighbours
  digraph := DigraphSymmetricClosure(digraph);
  #number of vertices of digraph
  n := DigraphNrVertices(digraph);
  #Gives colouring of vertices
  colour := ListWithIdenticalEntries(n,0);
  
  #This means there is a vertex we haven't visited yet
  while 0 in colour do    
    root := Position(colour,0);
    colour[root] := 1;
    queue := [root];
    #These are all the vertices we have yet to explore
    Append(queue,OutNeighboursOfVertex(digraph,root)); 
    while queue <> [] do
      #Explore the first element of queue
      node := queue[1];
      node_neighbours := OutNeighboursOfVertex(digraph,node);
      for i in node_neighbours do
        #If node and its neighbour have the same colour, graph is not bipartite
        if colour[node] = colour[i] then         
          return false;
        #Give i opposite colour to node
        elif colour[i] = 0 then
          if colour[node] = 1 then
            colour[i] := 2;
          else
            colour[i] := 1;
          fi;
          #Add i to the queue to be explored
          Add(queue,i);
        fi;
        #Remove the node we just explored from the queue
        Remove(queue,1);
      od;
    od;
  od;
  return true;
end;      
