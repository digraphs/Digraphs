D := Digraph([[2,4],[],[1],[1],[4]]);
is_bipart(D);
#returns true

D := Digraph([]);
is_bipart(D);
#returns true

D := CycleDigraph(89);
is_bipart(D);
#returns false

D := CycleDigraph(314);
is_bipart(D);
#returns true

D := CompleteDigraph(4);
is_bipart(D);
#returns false

D := Digraph([[2,4],[],[1],[1],[4],[7],[]]);
is_bipart(D);
#returns true

D := Digraph([[2],[3],[1],[6],[6],[]]);
is_bipart(D);
#returns false

D := Digraph([[1],[2]]);
is_bipart(D);
#returns false

D := Digraph([[3],[2],[1,2]]);
is_bipart(D);
#returns false

D := Digraph([[3],[3],[1,2]]);
is_bipart(D);
#returns true

D := Digraph([[2,3,4],[5,6],[],[7],[],[],[]]);
is_bipart(D);
#returns true

D := Digraph([[2,3,4],[5,6],[],[7],[],[],[],[9],[]]);
is_bipart(D);
#returns true

D := Digraph([]);
is_bipart(D);
#returns true

