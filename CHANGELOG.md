# CHANGELOG – Digraphs package for GAP
Copyright © 2014-24 by Jan De Beule, Julius Jonušas, James D. Mitchell,
Wilf A. Wilson, Michael Young et al.

Licensing information can be found in the `LICENSE` file.

## Version 1.9.0 (released 06/09/2024)

## What's Changed
* Update my web-address by @markuspf in
https://github.com/digraphs/Digraphs/pull/674
* Fix off by one error by @james-d-mitchell in
https://github.com/digraphs/Digraphs/pull/677
* Resolve issue #676 by @james-d-mitchell in
https://github.com/digraphs/Digraphs/pull/678
* Add hash function for digraphs by @reiniscirpons in
https://github.com/digraphs/Digraphs/pull/675
* kernel: use GAP's GVAR_FUNC macro by @fingolfin in
https://github.com/digraphs/Digraphs/pull/682
* Add DigraphAllChordlessCycles by @MeikeWeiss in
https://github.com/digraphs/Digraphs/pull/679
* Add DomainForAction mock for actions on digraphs by @reiniscirpons in
https://github.com/digraphs/Digraphs/pull/686
* doc: start using autodoc by @james-d-mitchell in
https://github.com/digraphs/Digraphs/pull/684
* Make Orb use digraph hashes by @reiniscirpons in
https://github.com/digraphs/Digraphs/pull/687
* Fix startup bug by @james-d-mitchell in
https://github.com/digraphs/Digraphs/pull/688
* Add comment to remove rank by @reiniscirpons in
https://github.com/digraphs/Digraphs/pull/692
* Lint for new version of gaplint by @james-d-mitchell in
https://github.com/digraphs/Digraphs/pull/691
* Add `SubdigraphsMonomorphisms` by @james-d-mitchell in
https://github.com/digraphs/Digraphs/pull/690
* Added method AllUndirectedSimpleCircuits by @MeikeWeiss in
https://github.com/digraphs/Digraphs/pull/689
* Update for recent gaplint by @james-d-mitchell in
https://github.com/digraphs/Digraphs/pull/693
* Add a test for issue #676 by @wilfwilson in
https://github.com/digraphs/Digraphs/pull/695
* Fix edge placement in HanoiGraph by @Joseph-Edwards in
https://github.com/digraphs/Digraphs/pull/699
* Fix planarity by @Joseph-Edwards in
https://github.com/digraphs/Digraphs/pull/696
* Clarify homomorphisms finder with specified image by @james-d-mitchell in
https://github.com/digraphs/Digraphs/pull/700

## New Contributors
* @MeikeWeiss made their first contribution in https://github.com/digraphs/Digraphs/pull/679

**Full Changelog**: https://github.com/digraphs/Digraphs/compare/v1.8.0...v1.9.0

## Version 1.8.0 (released 27/08/2024)

This release contains several improvements and bug fixes:

* Update Joe's info by @Joseph-Edwards in https://github.com/digraphs/Digraphs/pull/621
* Fix Issue #617: DigraphRemoveEdge now removes appropriate edge label by @mtorpey in https://github.com/digraphs/Digraphs/pull/619
* Implement IsOrderIdeal by @DanielPointon in https://github.com/digraphs/Digraphs/pull/609
* DigraphCycleBasis by @Jun2M in https://github.com/digraphs/Digraphs/pull/610
* Fix compiler warnings by @james-d-mitchell in https://github.com/digraphs/Digraphs/pull/633
* Add IsModularLatticeDigraph by @james-d-mitchell in https://github.com/digraphs/Digraphs/pull/629
* Abort if malloc fails by @DanielPointon in https://github.com/digraphs/Digraphs/pull/627
* Add DigraphContractEdge by @saffronmciver in https://github.com/digraphs/Digraphs/pull/618
* cliques: some perf improvements by @james-d-mitchell in https://github.com/digraphs/Digraphs/pull/635
* Add custom CSS to documentation by @mtorpey in https://github.com/digraphs/Digraphs/pull/640
* Fix compile warnings by @Joseph-Edwards in https://github.com/digraphs/Digraphs/pull/648
* Edge-weights #3: minimum spanning trees by @mtorpey in https://github.com/digraphs/Digraphs/pull/650
* weights.gi: correct whitespace by @mtorpey in https://github.com/digraphs/Digraphs/pull/652
* Refactor Floyd–Warshall C implementation by @mtorpey in https://github.com/digraphs/Digraphs/pull/657
* Added requested clique and independent attributes - #634 by @mpan322 in https://github.com/digraphs/Digraphs/pull/655
* Doc fixes by @james-d-mitchell in https://github.com/digraphs/Digraphs/pull/658
* Reduce Memory Usage by @DanielPointon in https://github.com/digraphs/Digraphs/pull/626

## New Contributors
* @DanielPointon made their first contribution in https://github.com/digraphs/Digraphs/pull/609
* @Jun2M made their first contribution in https://github.com/digraphs/Digraphs/pull/610
* @saffronmciver made their first contribution in https://github.com/digraphs/Digraphs/pull/618
* @mpan322 made their first contribution in https://github.com/digraphs/Digraphs/pull/655

**Full Changelog**: https://github.com/digraphs/Digraphs/compare/v1.7.1...v1.8.0

## Version 1.7.1 (released 19/02/2024)

This is a minor release with some changes related to forthcoming changes in
GAP. These changes were implemented by Fabian Zickgraf.

## Version 1.7.0 (released 14/02/2024)

This is a minor release with some new features, and some other improvements in
code quality.

## What's Changed
* Change test that relies on xpdf not being installed by @mtorpey in
  https://github.com/digraphs/Digraphs/pull/578
* DigraphAbsorptionProbabilities by @mtorpey in
  https://github.com/digraphs/Digraphs/pull/548
* Fix test files: strings and unbinds by @mtorpey in
  https://github.com/digraphs/Digraphs/pull/579
* Add immediate methods for connected and strongly connected graphs by @mtorpey
  in https://github.com/digraphs/Digraphs/pull/583
* kernel: fix mem leaks for permutations allocated but not freed. by
  @james-d-mitchell in https://github.com/digraphs/Digraphs/pull/589
* Remove references to bin/gap.sh by @fingolfin in
  https://github.com/digraphs/Digraphs/pull/597
* Fix prototype warnings by @fingolfin in
  https://github.com/digraphs/Digraphs/pull/598
* Added EdgeWeightedDigraph by @RaiyanC in
  https://github.com/digraphs/Digraphs/pull/575
* Add AbsorptionExpectedSteps by @mtorpey in
  https://github.com/digraphs/Digraphs/pull/585
* Fix a typo by @fingolfin in https://github.com/digraphs/Digraphs/pull/608
* configure.ac: fix bashism in string equality test by @orlitzky in
  https://github.com/digraphs/Digraphs/pull/613

## New Contributors
* @RaiyanC made their first contribution in https://github.com/digraphs/Digraphs/pull/575
* @orlitzky made their first contribution in https://github.com/digraphs/Digraphs/pull/613

**Full Changelog**: https://github.com/digraphs/Digraphs/compare/v1.6.3...v1.7.0

## Version 1.6.3 (released 13/09/2023)

This is a minor release with some bug fixes, and other issues resolved:

* There was a minor bug in the `RandomDigraph` method for `IsEulerianDigraph`,
  resolved by @mtorpey
* Joe Edwards and Maria Tsalakou were incorrectly listed as authors resolved
  partially by @james-d-mitchell in https://github.com/digraphs/Digraphs/pull/576
* Standardise the way that `UndirectedSpanningForest` works in relation to
  mutability by @wilfwilson in https://github.com/digraphs/Digraphs/pull/582
* Add immediate methods for connected and strongly connected digraphs by
  @mtorpey
* There was a minor memory leak in the kernel extension resolved by
  @james-d-mitchell

## Version 1.6.2 (released 05/04/2023)

* PackageInfo.g: link to Mathjax manual by default by @fingolfin in
  https://github.com/digraphs/Digraphs/pull/554
* PackageInfo.g: link to Mathjax manual by default by @fingolfin in
  https://github.com/digraphs/Digraphs/pull/558
* ci: change master to main on azure by @james-d-mitchell in
  https://github.com/digraphs/Digraphs/pull/567
* Rewrite buildsystem to use Makefile.gappkg by @fingolfin in
  https://github.com/digraphs/Digraphs/pull/566
* Update two M4 files, correct a comment by @fingolfin in
  https://github.com/digraphs/Digraphs/pull/568
* Fix some typos found by codespell by @fingolfin in
  https://github.com/digraphs/Digraphs/pull/569
* Avoid src/ prefix for GAP headers by @fingolfin in
  https://github.com/digraphs/Digraphs/pull/571
* Use same URL as in my other packages by @olexandr-konovalov in
  https://github.com/digraphs/Digraphs/pull/572

## Version 1.6.1 (released 06/12/2022)

This is a minor release fixing a number of minor issues:

* Use `compiled.h` instead of `src/compiled.h` by @fingolfin in https://github.com/digraphs/Digraphs/pull/560
* Fix tourn decoder by @james-d-mitchell in https://github.com/digraphs/Digraphs/pull/559
* Change `CayleyDigraph` to use `AsSet` by @fingolfin in https://github.com/digraphs/Digraphs/pull/564

## Version 1.6.0 (released 08/09/2022)

This is a minor release including a number of new features:

* Implement `IsPermutationDigraph` by @baydrea in
  https://github.com/digraphs/Digraphs/pull/513
* Add more implications (including some implications of falsity) by @wilfwilson
  in https://github.com/digraphs/Digraphs/pull/494
* Add `OnTuplesDigraphs` and `OnSetsDigraphs` by @wilfwilson in
  https://github.com/digraphs/Digraphs/pull/449
* Add checks for upper/lower semimodular lattices by @james-d-mitchell in
  https://github.com/digraphs/Digraphs/pull/375
* Add `AsDigraph` for partial perms by @james-d-mitchell in
  https://github.com/digraphs/Digraphs/pull/526
* Add `DigraphRandomWalk` by @mtorpey in
  https://github.com/digraphs/Digraphs/pull/543
* Add constructors for random digraphs with particular properties by
  @KamranKSharma in https://github.com/digraphs/Digraphs/pull/531
* Add `LatticeDigraphEmbedding` method by @MTWhyte in https://github.com/digraphs/Digraphs/pull/538
* Add `IsDistributiveLatticeDigraph` property by @MTWhyte in https://github.com/digraphs/Digraphs/pull/528

The following improvements were also made:

* Make improvements to `IsMeetSemilatticeDigraph` and
  `IsJoinSemilatticeDigraph`  by @MTWhyte in
  https://github.com/digraphs/Digraphs/pull/556
* Add a workaround for macOS code signing issues by @fingolfin in
  https://github.com/digraphs/Digraphs/pull/555

## Version 1.5.3 (released 20/05/2022)

This is a minor release including the following changes:

* digraph: fix String method for chains/cycles by @james-d-mitchell in https://github.com/digraphs/Digraphs/pull/542
* Disable edge labels if not already set in some cases by @james-d-mitchell in https://github.com/digraphs/Digraphs/pull/540
* build: remove the default flag -march=native by @james-d-mitchell in https://github.com/digraphs/Digraphs/pull/541
* doc: fix typos by @james-d-mitchell in https://github.com/digraphs/Digraphs/pull/544

## Version 1.5.2 (released 30/03/2022)

This is a very minor release containing technical changes for maintaining compatibility with other GAP packages.

## Version 1.5.1 (released 29/03/2022)

This minor release contains several bugfixes and technical changes. This includes:

* Bugfix: vertex labels are no longer wrongly retained when using `DigraphEdgeUnion`. This was reported by [Wilf A. Wilson][] in [Issue #496](https://github.com/digraphs/Digraphs/issues/496) and fixed by Joseph Edwards in [PR #507](https://github.com/digraphs/Digraphs/pull/507).
* Bugfix: a segfault could be caused by calling `OutNeighbours` with an inappropriate argument. This was reported by [Wilf A. Wilson][] in [Issue #518](https://github.com/digraphs/Digraphs/issues/518) and fixed by [James D. Mitchell][] in [PR #519](https://github.com/digraphs/Digraphs/pull/519).
* [Wilf A. Wilson][] improved the performance of `DigraphAddEdge` for digraphs without edge labels in [PR #509](https://github.com/digraphs/Digraphs/pull/509).
* [Max Horn][] changed the declaration of the variable `Vertices` to improve compatibility with  Grape in [PR #530](https://github.com/digraphs/Digraphs/pull/530).

## Version 1.5.0 (released 27/10/2021)

This is a fairly major release of the Digraphs package, containing some bugfixes and several new features.

In this version, we welcome Finn Buck, Tom Conti-Leslie, Ewan Gilligan, Lea
Racine, and Ben Spiers as contributors to the package.


### Bugfixes

* The edge labels of Cayley digraphs could sometimes be incorrect (Fixed by [Jan De Beule][] in [PR #452](https://github.com/digraphs/Digraphs/pull/452))
* Typos in the documentation of `IsDirectedTree` and an error message for `OnDigraphs` were fixed ([Wilf A. Wilson][] in PRs [#480](https://github.com/digraphs/Digraphs/pull/480) and [#498](https://github.com/digraphs/Digraphs/pull/498))

### A database of one-off named graphs and digraphs, and more families of standard examples

We especially wish to highlight the greatly expanded functionality for creating digraphs that are either famous one-off examples, or are part of a family of standard examples.

In particular, Marina Anagnostopoulou-Merkouri, Finn Buck, [James D. Mitchell][], Lea Racine, and Ben Spiers implemented functions to construct many more families of standard examples (currently documented in Section 3.5), which were added in in PRs
[#408](https://github.com/digraphs/Digraphs/pull/408),
[#409](https://github.com/digraphs/Digraphs/pull/409),
[#411](https://github.com/digraphs/Digraphs/pull/411),
[#415](https://github.com/digraphs/Digraphs/pull/415),
[#416](https://github.com/digraphs/Digraphs/pull/416),
[#417](https://github.com/digraphs/Digraphs/pull/417),
[#423](https://github.com/digraphs/Digraphs/pull/423),
[#424](https://github.com/digraphs/Digraphs/pull/424),
[#425](https://github.com/digraphs/Digraphs/pull/425),
[#445](https://github.com/digraphs/Digraphs/pull/445),
[#454](https://github.com/digraphs/Digraphs/pull/454),
[#456](https://github.com/digraphs/Digraphs/pull/456), and
[#490](https://github.com/digraphs/Digraphs/pull/490).

Furthermore, Marina Anagnostopoulou-Merkouri, Reinis Cirpons, Tom Conti-Leslie, Lea Racine, Maria Tsalakou, and Murray Whyte added a database of one-off named graphs and digraphs in [PR #404](https://github.com/digraphs/Digraphs/pull/404).
These digraphs can be constructed by calling `Digraph` with a string of appropriate name, e.g. `Digraph("brinkmann")`.
The available names can be accessed with the `ListNamedDigraphs` function.


### Other new features

* Tarjan and Lengauer's almost-linear time dominators algorithm was implemented, and is available via `Dominators` and `DominatorTree` ([James D. Mitchell][], Marina Anagnostopoulou-Merkouri,  Samantha Harper, and Finn Buck, in [PR #336](https://github.com/digraphs/Digraphs/pull/336))
* `MaximalCommonSubdigraph` and `MinimalCommonSuperdigraph` were introduced (Luke Elliot, [PR #361](https://github.com/digraphs/Digraphs/pull/361))
* `DigraphShortestPathSpanningTree` was introduced ([Jan De Beule][] and [Wilf A. Wilson][], in [PR #363](https://github.com/digraphs/Digraphs/pull/363))
* Lawler and Byskov's algorithms for chromatic number were implemented (Ewan Gilligan, [PR #382](https://github.com/digraphs/Digraphs/pull/382))
* Cayley digraphs now have pre-set vertex and edge labels ([Jan De Beule][] and [Wilf A. Wilson][], in [PR #385](https://github.com/digraphs/Digraphs/pull/385))
* `DigraphCycle` was added as a synonym for `CycleDigraph` ([Wilf A. Wilson][], [PR #441](https://github.com/digraphs/Digraphs/pull/441))
* Several new digraph product operations were introduced: `StrongProduct`, `ConormalProduct`, `HomomorphicProduct`, and `LexicographicProduct` (Finn Buck, [PR #460](https://github.com/digraphs/Digraphs/pull/460))
* The operation `IsDigraphPath` was introduced ([James D. Mitchell][], [PR #489](https://github.com/digraphs/Digraphs/pull/489))

### Other changes

* The `ViewString` and inherently known properties of trees, forests, cycle digraphs and tournaments were improved ([Wilf A. Wilson][] in PRs [#440](https://github.com/digraphs/Digraphs/pull/440) and [#447](https://github.com/digraphs/Digraphs/pull/447))
* Some technical changes to the package were made by [James D. Mitchell][] in [PR #488](https://github.com/digraphs/Digraphs/pull/488) and by [Max Horn][] in [PR #502](https://github.com/digraphs/Digraphs/pull/502)

## Version 1.4.1 (released 14/05/2021)

This minor release contains several bugfixes and technical changes,
and improvements to the documentation. These include the following:

* `OutNeighbours` is now a global function rather than an attribute
  ([James D. Mitchell][], [PR #413](https://github.com/digraphs/Digraphs/pull/419)).
* The configuration options for Digraphs are now described in the manual
  ([James D. Mitchell][], [PR #420](https://github.com/digraphs/Digraphs/pull/420)).
* The included version of the [Edge Addition Planarity Suite][] has been updated
  from version 3.0.0.5 to 3.0.1.0, and is now documented in the manual
  ([James D. Mitchell][], PRs [#421](https://github.com/digraphs/Digraphs/pull/421),
  [#422](https://github.com/digraphs/Digraphs/pull/422)).
* `SetDigraphVertexLabels` now accepts an immutable list of labels
  (Murray Whyte, [PR #427](https://github.com/digraphs/Digraphs/pull/427)).
* A bug was fixed in `DigraphCore` that could lead to wrong results
  ([Wilf A. Wilson][], [PR #437](https://github.com/digraphs/Digraphs/pull/437)).
* The performance of `ChromaticNumber` was improved in some cases by the
  use of Brooks' theorem
  ([Wilf A. Wilson][], [PR #446](https://github.com/digraphs/Digraphs/pull/446)).
* A bug, reported by Leonard Soicher, was fixed in `DigraphMaximumMatching`
  which affected digraphs with custom vertex labels
  ([Wilf A. Wilson][], [PR #462](https://github.com/digraphs/Digraphs/pull/462)).
* A bug was fixed that affected `DigraphEdgeUnion`, `DigraphJoin`,
  `DigraphDisjointUnion`, `DigraphDirectProduct`, and `DigraphCartesianProduct`
  when each was given a single list of digraphs as the argument.
  ([Wilf A. Wilson][], [PR #468](https://github.com/digraphs/Digraphs/pull/468)).

## Version 1.4.0 (released 27/01/2021)

In this release there are several new features and improvements.

The following improvements and bugfixes have been made:

* the clique finder was reimplemented in C by [Julius Jonusas][]
* a critical bug in `CayleyDigraph` was reported and fixed by [Jan De Beule][]
* a minor bug in `ReadDigraphs` was reported by [Wilf A. Wilson][] and
  fixed by [James D. Mitchell][]
* the performance of `BlissCanonicalLabelling` and `BlissAutomorphismGroup` was
  improved for multidigraphs by Marina Anagnostopoulou-Merkouri and Sam
  Harper.
* a bug in `GeneratorsOfEndomorphismMonoid` that caused GAP to crash when
  called with a multidigraph was reported by [Wilf A. Wilson][] and
  fixed by [James D. Mitchell][]
*  [Wilf A. Wilson][] made some improvements to the manual.
* the performance of `DigraphCopy` was improved by Marina
  Anagnostopoulou-Merkouri and Sam Harper.

The main new features are:

* the attribute `DigraphNrLoops` was introduced by Marina
  Anagnostopoulou-Merkouri and Sam Harper.
* the operations
  * `DotColoredDigraph`
  * `DotVertexColoredDigraph`
  * `DotEdgeColoredDigraph`
  * `DotSymmetricColoredDigraph`
  * `DotSymmetricVertexColoredDigraph`
  * `DotSymmetricEdgeColoredDigraph`
  were introduced by Marina Anagnostopoulou-Merkouri and Sam Harper.
* the operation `VerticesReachableFrom` was introduced by
  Marina Anagnostopoulou-Merkouri.
* the operation `ModularProduct` was introduced by Luke Elliott and
  [James D. Mitchell][]

## Version 1.3.1 (released 27/11/2020)

This is a minor release fixing some issues, some performance improvements, and
removing some deprecated code.  The changes in this release were made by [Max Horn][]
and [Wilf A. Wilson][].

## Version 1.3.0 (released 27/06/2020)

This is a minor release adding the new functionality `DigraphMutabilityFilter`,
`StrongOrientation`, `Bridges`, and `IsBridgeless` [James D. Mitchell][].

## Version 1.2.1 (released 27/05/2020)

This is a minor release where some of the documentation has been fixed and the
installation instructions have been improved [James D. Mitchell][], some
changes were made for compatibility with future versions of GAP [Max Horn][]
and [Wilf A. Wilson][].

## Version 1.2.0 (released 27/03/2020)

This is a minor release adding some new features to Digraphs, principally
functionality relating to computing matchings by Reinis Ciprons, and an
implementation of Dijkstra's algorithm for shortest paths by
[Markus Pfeiffer][] and [Maria Tsalakou][], and methods for producing a concise
string representation of a digraph by Murray Whyte.

As of this version, Digraphs requires the
[datastructures](https://gap-packages.github.io/datastructures) package to be
available, in version 0.2.5 or newer.

## Version 1.1.2 (released 16/03/2020)

This is a minor release adding the new configuration flag
`--without-intrinsics` and checking that the compiler is in C99 mode by using
`AC_PROG_CC_C99` in `configure.ac`.

## Version 1.1.1 (released 29/01/2020)

This release fixes a bug in `HomomorphismDigraphsFinder` that was introduced
in version 1.1.0.  The bug was found and fixed by [James D. Mitchell][];
see [PR #290](https://github.com/digraphs/Digraphs/pull/290).

## Version 1.1.0 (released 25/01/2020)

This is a minor release that includes some new features and some performance
improvements.

The following issues were resolved, pull requests merged, or new features added:

* [Issue #40](https://github.com/digraphs/Digraphs/issues/40): If [bliss][]
  is used to compute the automorphism group of a digraph, then the size of the
  automorphism group is returned from [bliss][] to GAP, and the group object in
  GAP immediately knows its size. In particular, it is not necessary to
  recalculate this size. This was reported and fixed in
  [PR #278](https://github.com/digraphs/Digraphs/pull/278) by
  [Chris Jefferson][].

* [Issue #279](https://github.com/digraphs/Digraphs/issues/279):
  In the function `HomomorphismDigraphsFinder`, it is now possible to specify a
  subgroup of the automorphism group of the range digraph. This way, the
  automorphism group of the range digraph is not computed by
  `HomomorphismDigraphsFinder`.  This can result in a performance improvement
  in some cases. This was reported and fixed in
  [PR #285](https://github.com/digraphs/Digraphs/pull/285) by
  Finn Smith.

* [Issue #284](https://github.com/digraphs/Digraphs/issues/284):
  The function `HomomorphismDigraphsFinder` sometimes did not return any
  homomorphisms when the source digraph had exactly one vertex. This was caused
  by the data structures used by `HomomorphismDigraphsFinder` not being
  correctly initialised in this case. This issue was reported by Finn Smith
  and fixed by [James D. Mitchell][] in
  [PR #286](https://github.com/digraphs/Digraphs/pull/286).

* In [PR #283](https://github.com/digraphs/Digraphs/pull/283), Finn Smith
  added the new operation `DigraphsRespectsColouring`, which can be used to
  check whether a transformation or permutation between digraphs respects given
  colourings. New versions of `IsDigraphHomomorphism`, and friends, were added
  that accept colourings as arguments and which use
  `DigraphsRespectsColouring`.

* The version of [bliss][] included in Digraphs was updated to allow all of its
  data structures to be modified in-place rather than allocated and deallocated
  repeatedly. The function `HomomorphismDigraphsFinder` was modified to make
  use of this new functionality in [bliss][], and subsequently the performance
  of `HomomorphismDigraphsFinder` has been improved (particularly in cases
  where many homomorphisms between distinct small digraphs are found).  This
  was done by [James D. Mitchell][] in
  [PR #282](https://github.com/digraphs/Digraphs/pull/282).

* Some further minor performance improvements were made, and a compiler warning
  was fixed.

## Version 1.0.3 (released 29/11/2019)

This is a minor release that fixes some bugs related to mutability in
`DigraphDisjointUnion` and `ViewString`.

These problems were reported and fixed by [Wilf A.  Wilson][] in
[Issue #276](https://github.com/digraphs/Digraphs/issues/276) and
[PR #277](https://github.com/digraphs/Digraphs/pull/277), respectively.

## Version 1.0.2 (released 28/11/2019)

This is a minor release that fixes several bugs:

* `GeneratorsOfEndomorphismMonoid` sometimes incorrectly stored its result.
  This was reported by [Chris Jefferson][] in
  [Issue #251](https://github.com/digraphs/Digraphs/issues/251)
  and fixed by [James D. Mitchell][] in
  [PR #265](https://github.com/digraphs/Digraphs/pull/265).
* Some warnings that occurred when compiling against GAP 4.9 were removed.
  The warnings were reported by [James D. Mitchell][] in
  [Issue #266](https://github.com/digraphs/Digraphs/issues/266)
  and fixed by [Wilf A. Wilson][] in
  [PR #274](https://github.com/digraphs/Digraphs/pull/274).
* There was a bug with the `ViewString` of known non-complete digraphs,
  where such digraphs were described as being complete.
  This was reported by Murray Whyte in
  [Issue #272](https://github.com/digraphs/Digraphs/issues/272)
  and fixed by [Wilf A. Wilson][] in
  [PR #273](https://github.com/digraphs/Digraphs/pull/273).


## Version 1.0.1 (released 05/10/2019)

This is a minor release of the Digraphs package.  The main change in this
release is the reintroduction of the three-argument version of
`DigraphAddVertices`, which accepts a digraph, a number of vertices to add, and
a list of labels for the new vertices.  The removal inadvertently broke
backwards compatibility with some third-party pre-existing code that relied on
this functionality in the Digraphs package (see
[Issue #264](https://github.com/digraphs/Digraphs/issues/264)).

The second argument of the three-argument version was redundant, and so a new
two-argument version of `DigraphAddVertices`, which accepts a digraph and a list
of new vertex labels, was introduced in v1.0.0. Unfortunately, the concurrent
removal of the three-argument version of `DigraphAddVertices` was not advertised
in the `CHANGELOG`.  Although the three-argument version has been reintroduced,
it will remain undocumented, since there is no good reason for any new code to
use the three-argument version.

The author contact data on the title page of the manual was also updated.

The changes in this version were made by [Wilf A. Wilson][].


## Version 1.0.0 (released 03/10/2019)

This is a major release of the Digraphs package that introduces significant new
functionality, some changes in behaviour, general improvements, and several
small bugfixes.  With this version, we welcome Reinis Cirpons as a contributor
to the package.

###  Changed functionality or names

* Perhaps the most immediately visible change is that the `ViewString` for
  immutable digraphs attempts to show more of the known information about the
  digraph. This will break tests that relied on the previous behaviour, that
  contained only the numbers of vertices and edges.
* The behaviour of `QuotientDigraph` has been changed so that it no longer
  returns digraphs with multiple edges.
* `IsEulerianDigraph` would previously return `true` for digraphs
  that are Eulerian when their isolated vertices were removed, which
  contradicted the documentation. `IsEulerianDigraph` now returns `false` for
  _all_ digraphs that are not strongly connected.
* The type of all digraphs has been renamed from `DigraphType` to
  `DigraphByOutNeighboursType`.
* The synonym `DigraphColoring` (American-style spelling) for `DigraphColouring`
  was removed.

###  Immutable and mutable digraphs

Previously, every digraph in the Digraphs package was an immutable,
attribute-storing digraph.  It is now possible to create mutable digraphs.
Mutable digraphs are not attribute-storing, but they can be altered in place -
by adding or removing vertices and edges - which, unlike with
immutable digraphs, does not require a new copy of the digraph to be made.
This can save time and memory.

This is particularly useful when one wants to create a digraph, alter the
digraph in some way, and then perform some computations. One can now typically
do this with fewer resources by creating a mutable digraph, modifying it in
place, and then converting it into an immutable digraph (which can store
attributes and properties), before finally performing the computations.

Every digraph now belongs to precisely one of the categories `IsMutableDigraph`
or `IsImmutableDigraph`, according to its mutability. A mutable digraph can be
converted in-place into an immutable digraph with `MakeImmutable`.  The are
various new and updated functions for creating mutable and immutable digraphs,
and for making mutable or immutable copies.

Most digraph-creation functions in the package now accept an optional first
argument, that can be either `IsMutableDigraph` or `IsImmutableDigraph`.  Given
one of these filters, the function will according create the digraph to be of
the appropriate mutability.  When this is option available, the default is
always to create an immutable digraph.

On the whole, for a function in the package that takes a digraph as its argument
and again returns a digraph, the function now returns a digraph of the same
mutability as its result, and moreover, given a mutable argument, it converts
the mutable digraph in-place into the result. However, please consult the
document to learn the exact behaviour of any specific function.

Old attributes `Foo` in the package that take and return a single digraph have
been converted into the operation `Foo`, with a corresponding new attribute,
`FooAttr`. This means that the getter and setter functions, `HasFoo` and
`SetFoo`, are renamed to `HasFooAttr` and `SetFooAttr`.  See `DigraphReverse`
for an example. For an immutable (and therefore attribute-storing) digraph,
calling `Foo` calls `FooAttr` and returns an immutable digraph, which it
stores, and so the effect is as before.  For an mutable digraph, calling `Foo`
modifies the digraph in-place, which remains mutable.

The majority of the changes in Digraphs relating to mutable and immutable
digraphs were made by [James D. Mitchell][], Finn Smith, and
[Wilf A. Wilson][], with some further contributions by Reinis
Cirpons, Luke Elliott, and Murray Whyte.

###  New and extended functions

The package now includes the following new functions:

* `AsSemigroup` can produce strong semilattices of groups (i.e. Clifford)
  from semilattice digraphs, groups, and homomorphisms. This functionality was
  added by Finn Smith in
  [PR #161](https://github.com/digraphs/Digraphs/pull/161).
* `AutomorphismGroup` and `BlissAutomorphismGroup` can now take an optional third
  argument that specifies an edge colouring for the digraph. In this case, the
  functions return only automorphisms of the digraph that preserve the edge
  colouring (and the vertex colouring, if one is given). This brilliant new
  functionality was added by Finn Smith in
  [PR #186](https://github.com/digraphs/Digraphs/pull/186).
* `DegreeMatrix`, `LaplacianMatrix`, and `NrSpanningTrees` were introduced by
  Reinis Cirpons in
  [PR #224](https://github.com/digraphs/Digraphs/pull/224).
* `DigraphCartesianProduct` and `DigraphDirectProduct`, along with the
  companion functions `DigraphCartesianProductProjections` and
  `DigraphDirectProductProjections`, were introduced by Reinis Cirpons in
  [PR #228](https://github.com/digraphs/Digraphs/pull/228).
* `DigraphMycielskian` was added by Murray Whyte in
  [PR #194](https://github.com/digraphs/Digraphs/pull/194).
* `DigraphNrStronglyConnectedComponents` was added by Murray Whyte in
  [PR #180](https://github.com/digraphs/Digraphs/pull/180).
* `DigraphOddGirth` was added by Murray Whyte in
  [PR #166](https://github.com/digraphs/Digraphs/pull/166)
* `DigraphCore` and `IsDigraphCore` were added by Murray Whyte in PRs
  [#221](https://github.com/digraphs/Digraphs/pull/221) and
  [#217](https://github.com/digraphs/Digraphs/pull/217), respectively.
* `DotHighlightedDigraph` was added by Finn Smith in
  [PR #169](https://github.com/digraphs/Digraphs/pull/169).
* `IsCompleteMultipartiteDigraph` was added by [Wilf A. Wilson][]
  in [PR #236](https://github.com/digraphs/Digraphs/pull/236).
* `IsEquivalenceDigraph` was added by [Wilf A. Wilson][] in
  [PR #234](https://github.com/digraphs/Digraphs/pull/234) as a synonym for
  `IsReflexiveDigraph and IsSymmetricDigraph and IsTransitiveDigraph`.
* `IsVertexTransitive` and `IsEdgeTransitive` were added by Graham Campbell
  in [PR #165](https://github.com/digraphs/Digraphs/pull/165).
* `PetersenGraph` and `GeneralisedPetersenGraph`
  were added by Murray Whyte in PRs
  [#181](https://github.com/digraphs/Digraphs/pull/181) and
  [#204](https://github.com/digraphs/Digraphs/pull/204),
  respectively.
* `RandomLattice` was added by Reinis Cirpons in
  [PR #175](https://github.com/digraphs/Digraphs/pull/175).

###  New technical functionality

* The ability to compile (with the flag `--with-external-bliss`) and use the
  Digraphs package with the system version of `bliss` was added
  by Isuru Fernando in
  [PR #225](https://github.com/digraphs/Digraphs/pull/225).
* The ability to compile (with the flag `--with-external-planarity`) and use
  the Digraphs package with the system version of the Edge Addition Planarity
  Suite was added by [James D. Mitchell][] in
  [PR #207](https://github.com/digraphs/Digraphs/pull/207).


## Version 0.15.4 (released 06/08/2019)

This is a minor release that fixes a few bugs.

In previous versions, the homomorphism-finding tools sometimes returned
purported ‘monomoprhisms’ that were not injective.  This problem was reported by
Gordon Royle, see
[Issue #222](https://github.com/digraphs/Digraphs/issues/222),
and fixed by [James D. Mitchell][] in
[PR #223](https://github.com/digraphs/Digraphs/pull/223).
In addition, [Wilf A. Wilson][]
[fixed a bug](https://github.com/digraphs/Digraphs/commit/458a10298b08881bf7ee9207534ce431378d2c4e)
in `DigraphNrEdges`. This function could previously lead to a crash when given a
digraph whose `OutNeighbours` contained entries not in `IsPlistRep`.

## Version 0.15.3 (released 12/06/2019)

This is a minor release that fixes a typo in the documentation of
`JohnsonDigraph`, and contains some minor tweaks for compatibility with
future versions of GAP.

## Version 0.15.2 (released 17/04/2019)

This is a minor release that updates Digraphs for compatibility with the
upcoming GAP 4.11, and resolves a bug in `IsHamiltonianDigraph` that could have
lead to the boolean adjacency matrix of a digraph being accidentally modified;
see [Issue #191](https://github.com/digraphs/Digraphs/issues/191) and
[PR #192](https://github.com/digraphs/Digraphs/pull/192).

## Version 0.15.1 (released 26/03/2019)

This is a minor release of the Digraphs package, which improves the
compatibility of Digraphs with cygwin. In particular, in the Windows installer
of the next release of GAP, Digraphs should be included in a pre-compiled and
working state. See
[Issue #177](https://github.com/digraphs/Digraphs/issues/177) and
[PR #178](https://github.com/digraphs/Digraphs/pull/178) for more details.

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
[Issue #158](https://github.com/digraphs/Digraphs/issues/158) for more
information.  The Digraphs package now uses the nauty format, although digraphs
encoded using the old format can still be read in.  This incompatibility was
reported by
[Jukka Kohonen](https://tuhat.helsinki.fi/portal/en/persons/jukka-kohonen(a6f3f037-4918-4bf5-a114-ac417f94beb5).html), and the changes were made by
[Michael Young][] in
[PR #162](https://github.com/digraphs/Digraphs/pull/162).

Other additions and changes are listed below:

* A copy of the [Edge Addition Planarity Suite][]
  is now included in Digraphs, and so it is now possible to test digraphs for
  planarity, and to perform related computations.  This was added by [James D.
  Mitchell][] in [PR
  #156](https://github.com/digraphs/Digraphs/pull/156).  The new
  functionality can be accessed via:
  * `Is(Outer)PlanarDigraph`,
  * `(Outer)PlanarEmbedding`,
  * `Kuratowski(Outer)PlanarSubdigraph`,
  * `SubdigraphHomeomorphicToK(23/4/33)`, and
  * `MaximalAntiSymmetricSubdigraph`.
* The functionality and performance for computing homomorphisms of digraphs was
  significantly improved by [James D. Mitchell][] in [PR
  #160](https://github.com/digraphs/Digraphs/pull/160). This PR also
  introduced the operations `EmbeddingsDigraphs` and
  `EmbeddingsDigraphsRepresentatives`.
* The one-argument attribute `DigraphColouring` was renamed to
  `DigraphGreedyColouring`, and its performance was improved; it now uses
  the Welsh-Powell algorithm, which can be accessed directly via
  `DigraphWelshPowellOrder`. The behaviour of `DigraphGreedyColouring` can be
  modified by including an optional second argument; see the
  documentation for more information. This work was done by [James D.
  Mitchell][] in [PR
  #144](https://github.com/digraphs/Digraphs/pull/144).
* `DigraphShortestPath` was introduced by Murray Whyte in [PR
  #148](https://github.com/digraphs/Digraphs/pull/148).
* `IsAntiSymmetricDigraph` (with a capital S) was added as a synonym for
  `IsAntisymmetricDigraph`.
* `RandomDigraph` now allows a float as its second argument; by [James D.
  Mitchell][] in [PR
  #159](https://github.com/digraphs/Digraphs/pull/159).
* The attribute `CharacteristcPolynomial` for a digraph was added by Luke
  Elliott in [PR #164](https://github.com/digraphs/Digraphs/pull/164).
* The properties `IsVertexTransitive` and `IsEdgeTransitive` for digraphs
  were added by Graham Campbell in
  [PR #165](https://github.com/digraphs/Digraphs/pull/165).

## Version 0.14.0 (released 23/11/2018)

This release contains bugfixes and a couple of new features.

* The operations `AsSemigroup` and `AsMonoid` for lattice and semilattice
  digraphs were added by Chris Russell in [PR
  #136](https://github.com/digraphs/Digraphs/pull/136).
* The operation `IsDigraphColouring` was added by [James D.
  Mitchell][] in [PR
  #145](https://github.com/digraphs/Digraphs/pull/145).
* In previous versions of the package, the output of `ArticulationPoints` would
  sometimes contain repeated vertices (reported by Luke Elliott in [Issue
  #140](https://github.com/digraphs/Digraphs/issues/140), and fixed by
  [James D. Mitchell][] in [PR
  #142](https://github.com/digraphs/Digraphs/pull/142)).
* In previous versions of the package, an unexpected error was sometimes caused
  when removing an immutable set of vertices from a digraph (reported and fixed
  by [James D. Mitchell][] in [PR
  #146](https://github.com/digraphs/Digraphs/pull/146)).
* The header file `x86intrin.h` was unnecessarily being included by the kernel
  module of Digraphs (reported by [Wilf A. Wilson][] in [Issue
  #147](https://github.com/digraphs/Digraphs/issues/147), and fixed by
  [James D. Mitchell][] in [PR
  #152](https://github.com/digraphs/Digraphs/pull/152)).

[Max Horn](https://www.quendi.de/math) also contributed various compatibility
and correctness changes to the kernel module of the package, including in PRs
[#149](https://github.com/digraphs/Digraphs/pull/149),
[#150](https://github.com/digraphs/Digraphs/pull/150), and
[#151](https://github.com/digraphs/Digraphs/pull/151).

Digraphs now requires version 4.8.1 of the [orb
package](https://gap-packages.github.io/orb), or newer.

## Version 0.13.0 (released 19/09/2018)

This release of Digraphs contains some bugfixes, along with the following new features:

* The GraphViz engine used by `Splash` is now configurable, thanks to [Markus Pfeiffer](https://www.morphism.de/~markusp).
* The properties `IsPartialOrderDigraph`, `IsPreorderDigraph`, and `IsQuasiorderDigraph` were introduced by Chris Russell, along with the following functions for visualising these kinds of digraphs:
  * `DotPartialOrderDigraph`
  * `DotPreorderDigraph`
  * `DotQuasiorderDigraph`
* The following functions for transformations and permutations were added by [James D. Mitchell][]:
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
were resolved by [James D. Mitchell][]:

* `HomomorphismDigraphFinder` sometimes failed to find a homomorphism when one existed [[Issue #111](https://github.com/digraphs/Digraphs/issues/111), reported by Gordon Royle];
* the documentation for `HomomorphismDigraphFinder` was
  incomplete [[Issue #112](https://github.com/digraphs/Digraphs/issues/112)]; and
* a segmentation fault could be caused when using Digraphs with
  NautyTracesInterface, in certain cases [[Issue #114](https://github.com/digraphs/Digraphs/issues/114)].

## Version 0.12.0 (released 31/01/2018)

This release contains bugfixes and new features. In particular, it:

* fixes [a bug in `ArticulationPoints` and `IsBiconnectedDigraph`](https://github.com/digraphs/Digraphs/issues/102) [[Wilf A. Wilson][]];
* adds the property `IsChainDigraph` [Ashley Clayton]; and
* adds the operation `IsDigraphAutomorphism` [Chris Russell].

Digraphs now requires version 4.5.1 of the IO package.

## Version 0.11.0 (released 22/11/2017)

The principal change in Digraphs version 0.11.0 is the addition of
support for computing automorphisms, canonical labellings, and isomorphisms of
digraphs with [nauty](https://pallini.di.uniroma1.it/). This
functionality requires the [NautyTracesInterface
package](https://github.com/gap-packages/NautyTracesInterface) for GAP, version 0.2
or newer. However, this is not a required package, and the default engine
remains [bliss][]. It is possible to
specify the engine that is used by Digraphs. These changes to Digraphs were made
by [James D. Mitchell][]].

In particular, version 0.11.0 includes the following changes:

* `BlissAutomorphismGroup` and `NautyAutomorphismGroup` are introduced.
* `DigraphCanonicalLabelling` is replaced by `BlissCanonicalLabelling` and
  `NautyCanonicalLabelling`.
* `BlissCanonicalDigraph` and `NautyCanonicalDigraph` are introduced [Chris
  Russell and [James D. Mitchell][]].
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
[[Julius Jonusas][]
and [James D. Mitchell][]].
A bug in the code for calculating homomorphisms of digraphs, which could cause
a crash, was resolved [[James D. Mitchell][]].

### New Features in Version 0.10.0

* Vertex labelled digraphs can now be visualised in a way that displays vertex
labels, by using the new operation `DotVertexLabelledDigraph`.
* The attribute `CliqueNumber` is introduced.
*  The following new attributes for Cayley digraphs are introduced:
    * `GroupOfCayleyDigraph`
    * `SemigroupOfCayleyDigraph`
    * `GeneratorsOfCayleyDigraph`

All of the new features were added by [James D. Mitchell][].

## Version 0.9.0 (released 12/07/2017)
This release introduces several new features.

### New Features in Version 0.9.0
The following attributes and properties were added by
[James D. Mitchell][]:

* `ArticulationPoints` (and its synonym `CutVertices`)
* `IsBiconnectedDigraph`
* `IsCycleDigraph`

The following operations related to matchings were added by Isabella Scott and
[Wilf A. Wilson][]:

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
[[Julius Jonusas][]]
and `BooleanAdjacencyMatrixMutableCopy`
[[Wilf A. Wilson][]],
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
made by [Wilf A. Wilson][].

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
* The ability to label the edges of digraphs is introduced. [[Markus Pfeiffer][]]
* The operation `CompleteMultipartiteDigraph` is introduced. [Stuart Burrell and [Wilf A. Wilson][]]
* The operations `ReadDIMACSDigraph` and `WriteDIMACSDigraph` are introduced.
  [[Wilf A. Wilson][]]
* The operation `ChromaticNumber` is introduced. [[James D. Mitchell][] and [Wilf A. Wilson][]]
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

* a better method for `DigraphReverse` [[Wilf A. Wilson][]]
* automorphism groups of complete, empty, cycle, chain, and complete bipartite
digraphs are set at creation [[Michael Young][]]
* a minor improvement in performance in the `DigraphMaximalCliques` [[Wilf A. Wilson][]]
* a new operation `AdjacencyMatrixMutableCopy` [[James D. Mitchell][]]

## Version 0.5.0 (released 03/03/2016)
This release contains some bugfixes, as well as new and changed functionality.
Digraphs now requires the [Orb package](https://gap-packages.github.io/orb),
version 4.7.5 or higher.

### New Features in Version 0.5.0
* `DigraphFile` and `IteratorFromDigraphFile` are introduced. [[James D. Mitchell][]]
* `WriteDigraphs` and `ReadDigraphs` can now take a file as a first argument. [[James D. Mitchell][]]
* The operation `DigraphPath` is introduced to find a path between two vertices
  in a digraph. [[Wilf A. Wilson][]]
* The operation `IteratorOfPaths` is introduced to iterate over the paths
  between two vertices in a digraph. [[Wilf A. Wilson][]]
* The property `IsCompleteBipartiteDigraph` is introduced. [[Wilf A. Wilson][]]

### Issues Resolved in Version 0.5.0
Several bugs related to clique finding have been resolved. [[Wilf A. Wilson][]]

* Files with extension `bz2` were previously not (un)compressed when used with
  `ReadDigraphs` and `WriteDigraphs`. [[James D. Mitchell][]]
* The documentation in Chapter 8 "Finding cliques and independent sets" has been
  corrected to accurately reflect the functionality of the package.
* A bug which led to too few cliques and independent sets being found for some
  digraphs has been resolved.
* A bug which led to duplicate cliques and independent sets being found for some
  digraphs has been resolved.

## Version 0.4.2 (released 28/01/2016)
This is a minor release to fix a bug in `DigraphAllSimpleCircuits` that failed to
return all simple circuits in some cases [Issue 13](https://github.com/digraphs/Digraphs/issues/13). Some documentation was also updated.

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

[[Jan De Beule][], [Julius Jonusas][], [James D. Mitchell][],
 [Michael Young][], [Wilf A. Wilson][]]

## Version 0.3.2 (released 14/01/2016)
This is another minor release due to some missing build files in the Version
0.3.1 archive.

## Version 0.3.1 (released 13/01/2016)
This is a minor release due to some missing build files in the Version 0.3 archive.

## Version 0.3.0 (released 12/01/2016)
This release contains a number of bugfixes and performance improvements.

### New Features in Version 0.3.0
* The attribute `DigraphAllSimpleCircuits` based
on the algorithm in [this paper](https://epubs.siam.org/doi/abs/10.1137/0204007) by Donald B. Johnson. [Stuart Burrell and [Wilf A. Wilson][]]
* Improve efficiency of the algorithm for coloring a graph with 2 colours, a method for `IsBipartiteDigraph` and `DigraphBicomponents`. [Isabella Scott and [Wilf A. Wilson][]]
* `AutomorphismGroup` and `DigraphCanonicalLabelling` can now be used with color classes that are preserved by the permutations acting on a digraph. [[James D. Mitchell][]]
* The `TCodeDecoder` was made more efficient. [[James D. Mitchell][]]
* `AsTransformation` is introduced for digraphs in `IsFunctionalDigraph`. [[James D. Mitchell][]]
* The tests and their code coverage were improved.

### Issues Resolved in Version 0.3.0
* There was a memory leak in bliss-0.73, which is fixed in the copy of bliss included with Digraphs, but not in the official release of bliss. [[James D. Mitchell][]]
* Some bits of code that caused compiler warnings were improved. [[James D. Mitchell][]]
* Some memory leaks were resolved in the Digraphs kernel module. [[Michael Young][]]

## Version 0.2.0 (released 04/09/2015)
The first release.

## Version 0.1.0
Pre-release version that was not made publicly available.

[James D. Mitchell]: https://jdbm.me
[Wilf A. Wilson]: https://wilf.me
[Michael Young]: https://mct25.host.cs.st-andrews.ac.uk
[Julius Jonusas]: http://julius.jonusas.work
[Jan De Beule]: http://homepages.vub.ac.be/~jdbeule
[Markus Pfeiffer]: https://www.morphism.de/~markusp
[Maria Tsalakou]: https://mariatsalakou.github.io
[Chris Jefferson]: https://caj.host.cs.st-andrews.ac.uk
[bliss]: http://www.tcs.hut.fi/Software/bliss/
[Max Horn]: https://www.quendi.de/math
[Edge Addition Planarity Suite]: https://github.com/graph-algorithms/edge-addition-planarity-suite
