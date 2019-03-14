#############################################################################
##
##  exmpl.gi
##  Copyright (C) 2019                                Murray T. Whyte
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

InstallMethod(PetersenGraph, [],
function()
  local admat;
  admat := [[0, 1, 0, 0, 1, 1, 0, 0, 0, 0],
            [1, 0, 1, 0, 0, 0, 1, 0, 0, 0],
            [0, 1, 0, 1, 0, 0, 0, 1, 0, 0],
            [0, 0, 1, 0, 1, 0, 0, 0, 1, 0],
            [1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
            [1, 0, 0, 0, 0, 0, 0, 1, 1, 0],
            [0, 1, 0, 0, 0, 0, 0, 0, 1, 1],
            [0, 0, 1, 0, 0, 1, 0, 0, 0, 1],
            [0, 0, 0, 1, 0, 1, 1, 0, 0, 0],
            [0, 0, 0, 0, 1, 0, 1, 1, 0, 0]];
  # the above is an adjacency matrix of the Petersen graph
  return DigraphByAdjacencyMatrix(admat);
end);
