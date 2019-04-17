# Digraphs package for GAP - CHANGELOG
Copyright (C) 2014-19 by Jan De Beule, Julius Jonušas, James D. Mitchell, Michael Torpey, Wilf A. Wilson et al.

Licensing information can be found in the LICENSE file.

## Version 0.15.2 (released 17/04/2019)

This is a minor release that updates Digraphs for compatibility with the
upcoming GAP 4.11, and resolves a bug in `IsHamiltonianDigraph` that could have
lead to the boolean adjacency matrix of a digraph being accidentally modified;
see [Issue #191](https://github.com/gap-packages/Digraphs/issues/191) and
[PR #192](https://github.com/gap-packages/Digraphs/pull/192).

## Version 0.15.1 (released 26/03/2019)

This is a minor release of the Digraphs package, which improves the
compatibility of Digraphs with cygwin. In particular, in the Windows installer
of the next release of GAP, Digraphs should be included in a pre-compiled and
working state. See
[Issue #177](https://github.com/gap-packages/Digraphs/issues/177) and
[PR #178](https://github.com/gap-packages/Digraphs/pull/178) for more details.

Digraphs now requires version 4.8.2 of the [orb
package](https://gap-packages.github.io/orb), or newer.


## Version 0.15.0 (released 15/02/2019)

This release contains several substantial new features, and some changes to
previous functionality.

The most significant change in behaviour is related to the Digraph6 format used
in previous versions of the Digraphs package. This method of encoding directed
graphs was developed independently from, but concurrently with, the
[Digraph6 format introduced by
nauty](https://users.cecs.anu.edu.au/~bdm/data/formats.txt); see
[Issue #158](https://github.com/gap-packages/Digraphs/issues/158) for more
information.  The Digraphs package now uses the nauty format, although digraphs
encoded using the old format can still be read in.  This incompatibility was
reported by
[Jukka Kohonen](https://tuhat.helsinki.fi/portal/en/persons/jukka-kohonen(a6f3f037-4918-4bf5-a114-ac417f94beb5).html), and the changes were made by
[Michael Torpey](http://www-groups.mcs.st-and.ac.uk/~mct25) in
[PR #162](https://github.com/gap-packages/Digraphs/pull/162).

Other additions and changes are listed below:

* A copy of the [Edge Addition Planarity
  Suite](https://github.com/graph-algorithms/edge-addition-planarity-suite)
  is now included in Digraphs, and so it is now possible to test digraphs for
  planarity, and to perform related computations.  This was added by [James D.
  Mitchell](http://goo.gl/ZtViV6) in [PR
  #156](https://github.com/gap-packages/Digraphs/pull/156).  The new
  functionality can be accessed via:
  * `Is(Outer)PlanarDigraph`,
  * `(Outer)PlanarEmbedding`,
  * `Kuratowski(Outer)PlanarSubdigraph`,
  * `SubdigraphHomeomorphicToK(23/4/33)`, and
  * `MaximalAntiSymmetricSubdigraph`.
* The functionality and performance for computing homomorphisms of digraphs was
  significantly improved by [James D.  Mitchell](http://goo.gl/ZtViV6) in [PR
  #160](https://github.com/gap-packages/Digraphs/pull/160). This PR also
  introduced the operations `EmbeddingsDigraphs` and
  `EmbeddingsDigraphsRepresentatives`.
* The one-argument attribute `DigraphColouring` was renamed to
  `DigraphGreedyColouring`, and its performance was improved; it now uses
  the Welsh-Powell algorithm, which can be accessed directly via
  `DigraphWelshPowellOrder`. The behaviour of `DigraphGreedyColouring` can be
  modified by including an optional second argument; see the
  documentation for more information. This work was done by [James D.
  Mitchell](http://goo.gl/ZtViV6) in [PR
  #144](https://github.com/gap-packages/Digraphs/pull/144).
* `DigraphShortestPath` was introduced by Murray Whyte in [PR
  #148](https://github.com/gap-packages/Digraphs/pull/148).
* `IsAntiSymmetricDigraph` (with a capital S) was added as a synonym for
  `IsAntisymmetricDigraph`.
* `RandomDigraph` now allows a float as its second argument; by [James D.
  Mitchell](http://goo.gl/ZtViV6) in [PR
  #159](https://github.com/gap-packages/Digraphs/pull/159).
* The attribute `CharacteristcPolynomial` for a digraph was added by Luke
  Elliott in [PR #164](https://github.com/gap-packages/Digraphs/pull/164).
* The properties `IsVertexTransitive` and `IsEdgeTransitive` for digraphs
  were added by Graham Campbell in
  [PR #165](https://github.com/gap-packages/Digraphs/pull/165).

## Version 0.14.0 (released 23/11/2018)

This release contains bugfixes and a couple of new features.

* The operations `AsSemigroup` and `AsMonoid` for lattice and semilattice
  digraphs were added by Chris Russell in [PR
  #136](https://github.com/gap-packages/Digraphs/pull/136).
* The operation `IsDigraphColouring` was added by [James D.
  Mitchell](http://goo.gl/ZtViV6) in [PR
  #145](https://github.com/gap-packages/Digraphs/pull/145).
* In previous versions of the package, the output of `ArticulationPoints` would
  sometimes contain repeated vertices (reported by Luke Elliott in [Issue
  #140](https://github.com/gap-packages/Digraphs/issues/140), and fixed by
  [James D.  Mitchell](http://goo.gl/ZtViV6) in [PR
  #142](https://github.com/gap-packages/Digraphs/pull/142)).
* In previous versions of the package, an unexpected error was sometimes caused
  when removing an immutable set of vertices from a digraph (reported and fixed
  by [James D.  Mitchell](http://goo.gl/ZtViV6) in [PR
  #146](https://github.com/gap-packages/Digraphs/pull/146)).
* The header file `x86intrin.h` was unnecessarily being included by the kernel
  module of Digraphs (reported by [Wilf A. Wilson](http://wilf.me) in [Issue
  #147](https://github.com/gap-packages/Digraphs/issues/147), and fixed by
  [James D.  Mitchell](http://goo.gl/ZtViV6) in [PR
  #152](https://github.com/gap-packages/Digraphs/pull/152)).

[Max Horn](https://www.quendi.de/math) also contributed various compatibility
and correctness changes to the kernel module of the package, including in PRs
[#149](https://github.com/gap-packages/Digraphs/pull/149),
[#150](https://github.com/gap-packages/Digraphs/pull/150), and
[#151](https://github.com/gap-packages/Digraphs/pull/151).

Digraphs now requires version 4.8.1 of the [orb
package](https://gap-packages.github.io/orb), or newer.

## Version 0.13.0 (released 19/09/2018)

This release of Digraphs contains some bugfixes, along with the following new features:

* The GraphViz engine used by `Splash` is now configurable, thanks to [Markus Pfeiffer](https://www.morphism.de/~markusp).
* The properties `IsPartialOrderDigraph`, `IsPreorderDigraph`, and `IsQuasiorderDigraph` were introduced by Chris Russell, along with the following functions for visualising these kinds of digraphs:
  * `DotPartialOrderDigraph`
  * `DotPreorderDigraph`
  * `DotQuasiorderDigraph`
* The following functions for transformations and permutations were added by [James D. Mitchell](http://goo.gl/ZtViV6):
  * `IsDigraphHomomorphism`
  * `IsDigraphEpimorphism`
  * `IsDigraphMonomorphism`
  * `IsDigraphEndomorphism`
  * `IsDigraphEmbedding`
  * `IsDigraphIsomorphism`

Digraphs now requires version 4.9.0 of GAP, or newer.

## Version 0.12.2 (released 24/08/2018)

This is a minor release which contains some small adjustments to the build
system of the package.

## Version 0.12.1 (released 26/04/2018)

This is a minor release, which contains several bugfixes. The following problems
were resolved by [James D. Mitchell](http://goo.gl/ZtViV6):

* `HomomorphismDigraphFinder` sometimes failed to find a homomorphism when one existsed [[Issue #111](https://github.com/gap-packages/Digraphs/issues/111), reported by Gordon Royle];
* the documentation for `HomomorphismDigraphFinder` was
  incomplete [[Issue #112](https://github.com/gap-packages/Digraphs/issues/112)]; and
* a segmentation fault could be caused when using Digraphs with
  NautyTracesInterface, in certain cases [[Issue #114](https://github.com/gap-packages/Digraphs/issues/114)].

## Version 0.12.0 (released 31/01/2018)

This release contains bugfixes and new features. In particular, it:

* fixes [a bug in `ArticulationPoints` and `IsBiconnectedDigraph`](https://github.com/gap-packages/Digraphs/issues/102) [[Wilf A. Wilson](http://wilf.me)];
* adds the property `IsChainDigraph` [Ashley Clayton]; and
* adds the operation `IsDigraphAutomorphism` [Chris Russell].

Digraphs now requires version 4.5.1 of the IO package.

## Version 0.11.0 (released 22/11/2017)

The principal change in Digraphs version 0.11.0 is the addition of
support for computing automorphisms, canonical labellings, and isomorphisms of
digraphs with [nauty](http://pallini.di.uniroma1.it/). This
functionality requires the [NautyTracesInterface
package](https://github.com/sebasguts/NautyTracesInterface) for GAP, version 0.2
or newer. However, this is not a required package, and the default engine
remains [bliss](http://www.tcs.hut.fi/Software/bliss/). It is possible to
specify the engine that is used by Digraphs. These changes to Digraphs were made
by [James D. Mitchell](http://goo.gl/ZtViV6)].

In particular, version 0.11.0 includes the following changes:

* `BlissAutomorphismGroup` and `NautyAutomorphismGroup` are introduced.
* `DigraphCanonicalLabelling` is replaced by `BlissCanonicalLabelling` and
  `NautyCanonicalLabelling`.
* `BlissCanonicalDigraph` and `NautyCanonicalDigraph` are introduced [Chris
  Russell and [James D. Mitchell](http://goo.gl/ZtViV6)].
* `DigraphsUseNauty` and `DigraphsUseBliss` are introduced.

The property `IsHamiltonianDigraph` and the attribute `HamiltonianPath` were
added by Luke Elliott.  Additionally, this release fixes several bugs, including
one in `DigraphSymmetricClosure` and one in `CompleteDigraph`.

Digraphs now requires version 4.4.6 of the IO package.

## Version 0.10.1 (released 16/08/2017)
This is a minor release, which contains performance improvements, and fixes a
bug in `Digraph` that could cause a segmentation fault.

## Version 0.10.0 (released 20/07/2017)
This release contains new features, bugfixes, and minor improvements to the
documentation.  There is a new method for `ChromaticNumber`, which has better
performance than the previous method
[[Julius Jonusas](http://www-groups.mcs.st-and.ac.uk/~julius)
and [James D.  Mitchell](http://goo.gl/ZtViV6)].
A bug in the code for calculating homomorphisms of digraphs, which could cause
a crash, was resolved [[James D.  Mitchell](http://goo.gl/ZtViV6)].

### New Features in Version 0.10.0

* Vertex labelled digraphs can now be visualised in a way that displays vertex
labels, by using the new operation `DotVertexLabelledDigraph`.
* The attribute `CliqueNumber` is introduced.
*  The following new attributes for Cayley digraphs are introduced:
    * `GroupOfCayleyDigraph`
    * `SemigroupOfCayleyDigraph`
    * `GeneratorsOfCayleyDigraph`

All of the new features were added by [James D. Mitchell](http://goo.gl/ZtViV6).

## Version 0.9.0 (released 12/07/2017)
This release introduces several new features.

### New Features in Version 0.9.0
The following attributes and properties were added by
[James D. Mitchell](http://goo.gl/ZtViV6):

* `ArticulationPoints` (and its synonym `CutVertices`)
* `IsBiconnectedDigraph`
* `IsCycleDigraph`

The following operations related to matchings were added by Isabella Scott and
[Wilf A. Wilson](http://wilf.me):

* `IsMatching`
* `IsPerfectMatching`
* `IsMaximalMatching`

## Version 0.8.1 (released 18/05/2017)
This is a minor release, which updates the README file and updates the list of
package authors and contributors.

## Version 0.8.0 (released 17/05/2017)
This release contains new features, several minor bugfixes, and minor
improvements to the documentation of the package.

### New Features in Version 0.8.0

This release introduces the new operations `DigraphClosure`
[[Julius Jonusas](http://www-groups.mcs.st-and.ac.uk/~julius)]
and `BooleanAdjacencyMatrixMutableCopy`
[[Wilf A. Wilson](http://wilf.me)],
along with the following properties and operations related to semilattices
[Chris Russell]:

* `IsPartialOrderDigraph`
* `IsMeetSemilatticeDigraph`
* `IsJoinSemilatticeDigraph`
* `IsLatticeDigraph`
* `PartialOrderDigraphMeetOfVertices`
* `PartialOrderDigraphJoinOfVertices`

## Version 0.7.1 (released 22/03/2017)
This is a minor release, which fixes bugs in `DigraphTopologicalSort` and
`IsAntisymmetricDigraph` that could trigger segmentation faults.

## Version 0.7.0 (released 14/03/2017)
This release introduces several new features, changes some existing
functionality, and improves the documentation. The changes in this release were
made by [Wilf A. Wilson](http://wilf.me).

### New Features in Version 0.7.0
* This release contains a new technique for encoding a vertex-coloured
  *multidigraph* as a vertex-coloured (undirected) graph while preserving the
  automorphism group, in order to calculate the automorphism group and canonical
  labelling using bliss. This enables the following functionality:
  * the operations `AutomorphismGroup` and `DigraphCanonicalLabelling` for a
    digraph and a vertex-colouring now accept a multidigraph as their first
    argument;
  * the operations `IsIsomorphicDigraph` and `IsomorphismDigraphs` now accept
    multidigraphs, and they also accept vertex-colourings as optional arguments.

* This release add new functionality related to undirected spanning trees and
  undirected spanning forests:
  * the property `IsUndirectedForest` is introduced;
  * the attributes `UndirectedSpanningTree` and `UndirectedSpanningForest` are
    introduced; and
  * the operations `IsUndirectedSpanningTree` and `IsUndirectedSpanningForest`
    are introduced.

### Altered Behaviour in Version 0.7.0
* The behaviour of `IsSubdigraph` is changed in the case that it is given one or
  two multidigraphs.
* The one-argument version of the operation `DigraphColouring` (and its synonym,
  `DigraphColoring`) is now an attribute.

## Version 0.6.1 (released 01/03/2017)
This is a minor release. This release fixes a bug in `AsDigraph` for a
transformation and an integer. The operations `OutNeighboursCopy` and
`OutNeighborsCopy` are renamed to `OutNeighboursMutableCopy` and
`OutNeighborsMutableCopy`, respectively, and new operations
`InNeighboursMutableCopy` and `InNeighborsMutableCopy` are introduced.

## Version 0.6.0 (released 09/12/2016)
This is a major release, adding a variety of new operations and attributes
for Digraphs, as well as improving some functions and improving the
package's documentation.  In this version, we welcome Luke Elliott and
Markus Pfeiffer as new authors.

### New Features in Version 0.6.0
* The ability to label the edges of digraphs is introduced. [[Markus Pfeiffer](https://www.morphism.de/~markusp)]
* The operation `CompleteMultipartiteDigraph` is introduced. [Stuart Burrell and [Wilf A. Wilson](http://wilf.me)]
* The operations `ReadDIMACSDigraph` and `WriteDIMACSDigraph` are introduced.
  [[Wilf A. Wilson](http://wilf.me)]
* The operation `ChromaticNumber` is introduced. [[James D. Mitchell](http://goo.gl/ZtViV6) and [Wilf A. Wilson](http://wilf.me)]
* The operations `IsDirectedTree` and `IsUndirectedTree` are introduced. [Luke Elliott]
* The operation `IsEulerianDigraph`is introduced. [Luke Elliott]

## Version 0.5.2 (released 20/06/2016)
This is a minor release containing one bugfix and several other minor changes.
Digraphs now works when it and GAP are compiled in 32 bit mode.

## Version 0.5.1 (released 08/06/2016)
This release contains some bugfixes, some minor new features, and some
performance improvements. The package has moved to GitHub and we welcome Finn
Smith as an author.

This release contains a new technique for encoding a vertex-coloured digraph as a vertex-coloured (undirected) graph while preserving the automorphism group, in order to calculate the automorphism group using bliss. These changes were made by Finn Smith. The previous technique involved adding two intermediate vertices for every edge; on a digraph with `n` vertices this could add `2n(n-1)` new vertices. The new technique encodes a digraph with `n` vertices as a graph with `3n` vertices. In certain cases, this can lead to a dramatic improvement in the time taken to calculate the automorphism group.

The new reduction is based on two techniques in: 

> David Bremner, Mathieu Dutour Sikiric, Dmitrii V. Pasechnik, Thomas Rehn, Achill Schürmann. Computing symmetry groups of polyhedra. https://arxiv.org/abs/1210.0206v3

Namely, "Dealing with digraphs" followed by "Reduction by superposition". From the graph obtained by these techniques, `n` vertices which are irrelevant to automorphism finding are removed.

The actual reduction used is as follows: Given a digraph `D=(V=[]1 .. n],E,c)`, create three copies `V1`, `V2`, `V3` of the vertex set `V`. Colour `V1` according to the colouring `c` of `D`, and `V2`, `V3` with two distinct colours that do not occur in `D`. Connect each vertex in `V1` to the corresponding vertices in `V2`, `V3`. For every arc `(x,y)` in `E`, put an edge between the copy of `x` in `V2`, and the copy of `y` in `V3`. Automorphisms of this graph, when restricted to `V`, are precisely the automorphisms of `D`. 
Because this changes the graph used to calculate automorphisms, the results sometimes nominally differ from the previous version - especially in the case of canonical labelling, where unrecognisably different results may appear. Generators also often appear in different orders. 

The performance improvements are most noticeable on large, quite dense digraphs. On random digraphs with 5000 vertices and 0.5 edge probability, 200-400x speedups were common. When calculating the automorphism group of the complete digraph on 1000 vertices, with vertex `i` having colour `i mod 2 + 1`, we obtain a 66x speedup. When the vertex `i` is assigned colour `i mod 7 + 1`, this becomes a 400x speedup.

Minor changes include:

* a better method for `DigraphReverse` [[Wilf A. Wilson](http://wilf.me)]
* automorphism groups of complete, empty, cycle, chain, and complete bipartite
digraphs are set at creation [[Michael Torpey](http://www-groups.mcs.st-and.ac.uk/~mct25)]
* a minor improvement in performance in the `DigraphMaximalCliques` [[Wilf A. Wilson](http://wilf.me)]
* a new operation `AdjacencyMatrixMutableCopy` [[James D. Mitchell](http://goo.gl/ZtViV6)]

## Version 0.5.0 (released 03/03/2016)
This release contains some bugfixes, as well as new and changed functionality.
Digraphs now requires the [Orb package](http://gap-packages.github.io/orb/),
version 4.7.5 or higher.

### New Features in Version 0.5.0
* `DigraphFile` and `IteratorFromDigraphFile` are introduced. [[James D. Mitchell](http://goo.gl/ZtViV6)]
* `WriteDigraphs` and `ReadDigraphs` can now take a file as a first argument. [[James D. Mitchell](http://goo.gl/ZtViV6)]
* The operation `DigraphPath` is introduced to find a path between two vertices
  in a digraph. [[Wilf A. Wilson](http://wilf.me)]
* The operation `IteratorOfPaths` is introduced to iterate over the paths
  between two vertices in a digraph. [[Wilf A. Wilson](http://wilf.me)]
* The property `IsCompleteBipartiteDigraph` is introduced. [[Wilf A. Wilson](http://wilf.me)]

### Issues Resolved in Version 0.5.0
Several bugs related to clique finding have been resolved. [[Wilf A.
Wilson](http://wilf.me)]

* Files with extension `bz2` were previously not (un)compressed when used with
  `ReadDigraphs` and `WriteDigraphs`. [[James D. Mitchell](http://goo.gl/ZtViV6)]
* The documentation in Chapter 8 "Finding cliques and independent sets" has been
  corrected to accurately reflect the functionality of the package.
* A bug which led to too few cliques and independent sets being found for some
  digraphs has been resolved.
* A bug which led to duplicate cliques and independent sets being found for some
  digraphs has been resolved.

## Version 0.4.2 (released 28/01/2016)
This is a minor release to fix a bug in `DigraphAllSimpleCircuits` that failed to
return all simple circuits in some cases [Issue 13](https://github.com/gap-packages/Digraphs/issues/13). Some documentation was also updated.

## Version 0.4.1 (released 22/01/2016)
This is a very minor release to change the version of GAP required.

## Version 0.4.0 (released 19/01/2016)
This is a major release, primarily aimed at incorporating more of the
functionality of Grape into Digraphs, as well as fixing some bugs.  In this
version, we welcomed Jan De Beule to the development team.

### New Features in Version 0.4.0
* Functionality to calculate cliques and independent sets
* New methods for the constructor function `Digraph`
* `ReadDigraphs` and `WriteDigraphs` now have a new output format `.p` or
  `.pickle`, which allows known automorphisms to be stored with the digraph
* The following functions now use known automorphisms:
  - `DigraphDiameter`
  - `DigraphDual`
  - `DigraphShortestDistances`
  - `Digraph` method for a Grape graph
  - `Graph`
  - `InDegreeSequence`
  - `OutDegreeSequence`
* The following new functions were added:
  - `BipartiteDoubleDigraph`
  - `BooleanAdjacencyMatrix`
  - `CayleyDigraph`
  - `DigraphAddAllLoops`
  - `DigraphAddEdgeOrbit`
  - `DigraphAdjacencyFunction`
  - `DigraphColoring` for a digraph
  - `DigraphDegeneracyOrdering`
  - `DigraphDegeneracy`
  - `DigraphDistanceSet`
  - `DigraphGirth`
  - `DigraphGroup`
  - `DigraphLayers`
  - `DigraphLongestSimpleCircuit`
  - `DigraphOrbitReps`
  - `DigraphOrbits`
  - `DigraphRemoveEdgeOrbit`
  - `DigraphSchreierVector`
  - `DigraphShortestDistance`
  - `DigraphStabilizer`
  - `DigraphUndirectedGirth`
  - `DistanceDigraph`
  - `DoubleDigraph`
  - `EdgeOrbitsDigraph`
  - `InDegreeSet`
  - `IsDigraphEdge` for a digraph and a list
  - `IsDistanceRegularDigraph`
  - `IsInRegularDigraph`
  - `IsOutRegularDigraph`
  - `IsRegularDigraph`
  - `JohnsonDigraph`
  - `LineDigraph`
  - `LineUndirectedDigraph`
  - `MaximalSymmetricSubdigraphWithoutLoops`
  - `MaximalSymmetricSubdigraph`
  - `OutDegreeSet`
  - `RepresentativeOutNeighbours`

[[Jan De Beule](http://homepages.vub.ac.be/~jdbeule/), [Julius Jonusas](http://www-groups.mcs.st-and.ac.uk/~julius),
[James D. Mitchell](http://goo.gl/ZtViV6),
[Michael Torpey](http://www-groups.mcs.st-and.ac.uk/~mct25),
[Wilf A. Wilson](http://wilf.me)]

## Version 0.3.2 (released 14/01/2016)
This is another minor release due to some missing build files in the Version
0.3.1 archive.

## Version 0.3.1 (released 13/01/2016)
This is a minor release due to some missing build files in the Version 0.3 archive.

## Version 0.3.0 (released 12/01/2016)
This release contains a number of bugfixes and performance improvements.

### New Features in Version 0.3.0
* The attribute `DigraphAllSimpleCircuits` based
on the algorithm in [this paper](http://epubs.siam.org/doi/abs/10.1137/0204007?journalCode=smjcat) by Donald B. Johnson. [Stuart Burrell and [Wilf A. Wilson](http://wilf.me)]
* Improve efficiency of the algorithm for coloring a graph with 2 colours, a method for `IsBipartiteDigraph` and `DigraphBicomponents`. [Isabella Scott and [Wilf A. Wilson](http://wilf.me)]
* `AutomorphismGroup` and `DigraphCanonicalLabelling` can now be used with color classes that are preserved by the permutations acting on a digraph. [[James D. Mitchell](http://goo.gl/ZtViV6)]
* The `TCodeDecoder` was made more efficient. [[James D. Mitchell](http://goo.gl/ZtViV6)]
* `AsTransformation` is introduced for digraphs in `IsFunctionalDigraph`. [[James D. Mitchell](http://goo.gl/ZtViV6)]
* The tests and their code coverage were improved.

### Issues Resolved in Version 0.3.0
* There was a memory leak in bliss-0.73, which is fixed in the copy of bliss included with Digraphs, but not in the official release of bliss. [[James D. Mitchell](http://goo.gl/ZtViV6)]
* Some bits of code that caused compiler warnings were improved. [[James D. Mitchell](http://goo.gl/ZtViV6)]
* Some memory leaks were resolved in the Digraphs kernel module. [[Michael Torpey](http://www-groups.mcs.st-and.ac.uk/~mct25)]

## Version 0.2.0 (released 04/09/2015)
The first release.

## Version 0.1.0
Pre-release version that was not made publicly available.
