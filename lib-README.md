# README for digraphs-lib

### Library of digraphs for the Digraphs package of GAP ###

In this directory is a collection of various types of digraphs, which can be
loaded into the GAP computational algebra system using the [Digraphs
package](https://digraphs.github.io/Digraphs).  It is a
completely optional addition to the package, which can be used to produce
examples of digraphs for use in the package.


Getting digraphs-lib
--------------------
The latest version of this library is available at
<https://digraphs.github.io/Digraphs>.

Simply download the archive, and extract it into the root directory of your
Digraphs installation.  This should result in a `digraphs-lib` directory inside
your `digraphs` directory.


Using digraphs-lib
------------------
Once the library is installed, simply launch GAP, load the Digraphs package, and
use the `ReadDigraphs` function on one of the files in the `digraph-lib`
directory.  This will return a list of digraphs which can be used as required.

Here is an example GAP session:

```
gap> LoadPackage("digraphs", false);;
gap> filename := Concatenation(DIGRAPHS_Dir(), "/digraphs-lib/latin.g6.gz");;
gap> latin_graphs := ReadDigraphs(filename);
[ <immutable symmetric digraph with 100 vertices, 2700 edges>,
  <immutable symmetric digraph with 121 vertices, 3630 edges>,
  <immutable symmetric digraph with 144 vertices, 4752 edges>,
  <immutable symmetric digraph with 169 vertices, 6084 edges>,
  <immutable symmetric digraph with 196 vertices, 7644 edges>,
  <immutable symmetric digraph with 225 vertices, 9450 edges>,
  <immutable symmetric digraph with 256 vertices, 11520 edges>,
  <immutable symmetric digraph with 289 vertices, 13872 edges>,
  <immutable symmetric digraph with 324 vertices, 16524 edges>,
  <immutable symmetric digraph with 361 vertices, 19494 edges>,
  <immutable symmetric digraph with 4 vertices, 12 edges>,
  <immutable symmetric digraph with 400 vertices, 22800 edges>,
  <immutable symmetric digraph with 441 vertices, 26460 edges>,
  <immutable symmetric digraph with 484 vertices, 30492 edges>,
  <immutable symmetric digraph with 529 vertices, 34914 edges>,
  <immutable symmetric digraph with 576 vertices, 39744 edges>,
  <immutable symmetric digraph with 625 vertices, 45000 edges>,
  <immutable symmetric digraph with 676 vertices, 50700 edges>,
  <immutable symmetric digraph with 729 vertices, 56862 edges>,
  <immutable symmetric digraph with 784 vertices, 63504 edges>,
  <immutable symmetric digraph with 841 vertices, 70644 edges>,
  <immutable symmetric digraph with 9 vertices, 54 edges>,
  <immutable symmetric digraph with 900 vertices, 78300 edges>,
  <immutable symmetric digraph with 16 vertices, 144 edges>,
  <immutable symmetric digraph with 25 vertices, 300 edges>,
  <immutable symmetric digraph with 36 vertices, 540 edges>,
  <immutable symmetric digraph with 49 vertices, 882 edges>,
  <immutable symmetric digraph with 64 vertices, 1344 edges>,
  <immutable symmetric digraph with 81 vertices, 1944 edges> ]
```


Types of digraph available
--------------------------
The following files were created by the authors of the Digraphs package:

  * `acyclic.ds6.gz` - Acyclic graphs
  * `complete.g6.gz` - Complete graphs
  * `cyclic.ds6.gz` - Cyclic graphs
  * `empty.s6` - Empty graphs (graphs with no edges)
  * `extreme.d6.gz` - Required for DigraphsTestExtreme
  * `extreme.ds6.gz` - Required for DigraphsTestExtreme
  * `multi.ds6.gz` - Multigraphs
  * `random.d6.gz` - A few randomly generated digraphs
  * `sparse.ds6.gz` - Sparse graphs (few edges per vertex)
  * `tournament.d6.gz` - Tournaments

The following files contain symmetric digraphs (i.e. graphs) taken from the
[nauty and Traces website](http://pallini.di.uniroma1.it/Graphs.html), by
Brendan McKay and Adolfo Piperno:

  * `ag.s6.gz` - Affine geometry graphs
  * `cfi.s6.gz` - Cai, Fuerer and Immerman graphs
  * `cmz.s6.gz` - Miyazaki graphs
  * `grid.s6.gz` - Grid graphs
  * `grid-sw.s6.gz` - Grid graphs with switched edges
  * `had.g6.gz` - Hadamard matrix graphs
  * `had-sw.g6.gz` - Hadamard matrix graphs with switched edges
  * `k.g6.gz` - Complete graphs
  * `latin.g6.gz` - Latin square graphs
  * `latin-sw.g6.gz` - Latin square graphs with switched edges
  * `lattice.g6.gz` - Lattice graphs
  * `mz.s6.gz` - Miyazaki graphs
  * `mz-aug.s6.gz` - Augmented Miyazaki graphs
  * `mz-aug2.s6.gz` - Augmented Miyazaki graphs 2
  * `paley.g6.gz` - Paley graphs
  * `pg.s6.gz` - Desarguesian projective plane graphs
  * `rnd-3-reg.s6.gz` - Random cubic graphs
  * `sts.g6.gz` - Steiner triple system graphs
  * `sts-sw.g6.gz` - Steiner triple system graphs with switched edges
  * `triang.g6.gz` - Triangular graphs

There are also some additional files, added by Jan De Beule, which containing
graphs that come from finite geometry, which were

  * `fining.p.gz` contains some graphs coming from finite geometries:
    1. The vertices are the generators of the hermitian polar space `H(5,4)`,
       two vertices are adjacent iff they are skew.
    2. The vertices are the generators of the hermitian quadrangle `H(4,4)`, two
       vertices are adjacent iff they are skew.
    3. The vertices are the points and lines of the classical generalised
       quadrangle `Q(4,8)`, two vertices are adjacent iff they are distinct and
       incident (no loops!). This is a bipartite graph with diameter 4 and
       undirected girth 8.
    4. The bipartite graph (see (3)) of an elation generalised quadrangle.  This
       one was constructed as a coset geometry.
    5. The bipartite graph of the split Cayley hexagon of order 4, the diameter
       is 6 and the girth is 12.
    6. The bipartite graph of the Ree-Tits generalised octagon. This has
       diameter 8 and girth 16!
  
  * `polar_graphs.p.gz` A polar graph is by definition the point graph of a
    finite classical polar space. Note that such a geometry is a partial linear
    space, so not every pair of points is a pair of collinear points. Two points
    are adjacent iff they are distinct and collinear. The diameter of these
    graphs is 2, their undirected girth 3, the latter since these spaces contain
    lines.  Reading in this file requires around 4 Gb of memory.

  * `dual_polar_graphs.p.gz` We consider again finite classical polar spaces.
    Such geometries contain points, lines, etc., up to maximal subspaces, which
    all have the same projective dimension. The vertices of a dual polar graph
    are these maximal subspaces, of dimension, say, `d`, and they are adjacent
    iff they are distinct and meet in a `d-1` dimensional projective subspace.
    Reading in this file requires around 5 Gb of memory.
     
  * `generators_graphs.p.gz` (Parts 1, 2, and 3). We again consider finite
    classical polar spaces. The vertices are the maximal subspaces and they are
    adjacent iff they are distinct and skew. Reading part 2 requires almost 6 Gb
    of memory, and reading part 3 requires another 6 Gb. Reading part 1 requires
    much less memory, around 1.5 Gb.
      
  * `incidence_graphs.p.gz` A generalised polygon of gonality n is a point line
    geometry, such that if one considers the incidence graph, i.e. the vertices
    are the points and adjacency is incidence (without loops), then it has
    diameter n and girth 2n. All graphs in this file are incidence graphs of
    generalised polygons. Note that by a famous theorem, thick GPs (i.e. at
    least three points on a line and dually, at least three lines on a point),
    have gonality 3, 4, 6, or 8. This file contains the incidence graph of the
    smallest generalised octogon, some generalised hexagons, and a lot of
    generalised quadrangles, and some projective planes.  To read it completely,
    around 1.5 Gb of memory is required.
