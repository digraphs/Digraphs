#Digraphs package for GAP - CHANGELOG
Copyright (C) 2014-16 Jan De Beule, Julius Jonusas, James D. Mitchell, Michael Torpey & Wilf Wilson

Licensing information can be found in the LICENSE file.

## Version 0.5 (released 03/03/2016)
This release contains some bugfixes, as well as new and changed functionality.
Digraphs now requires the [Orb package](http://gap-packages.github.io/orb/),
version 4.7.5 or higher.

###New Features in Version 0.5
* `DigraphFile` and `IteratorFromDigraphFile` are introduced. [[James D. Mitchell](http://tinyurl.com/jdmitchell)]
* `WriteDigraphs` and `ReadDigraphs` can now take a file as a first argument. [[James D. Mitchell](http://tinyurl.com/jdmitchell)]
* The operation `DigraphPath` is introduced to find a path between two vertices
  in a digraph. [[Wilf Wilson](http://wilf.me)]
* The operation `IteratorOfPaths` is introduced to iterate over the paths
  between two vertices in a digraph. [[Wilf Wilson](http://wilf.me)]
* The property `IsCompleteBipartiteDigraph` is introduced. [[Wilf Wilson](http://wilf.me)]

###Issues Resolved in Version 0.5
Several bugs related to clique finding have been resolved. [[Wilf
Wilson](http://wilf.me)]
* Files with extension `bz2` were previously not (un)compressed when used with
  `ReadDigraphs` and `WriteDigraphs`. [[James D. Mitchell](http://tinyurl.com/jdmitchell)]
* The documentation in Chapter 8 "Finding cliques and independent sets" has been
  corrected to accurately reflect the functionality of the package.
* A bug which led to too few cliques and independent sets being found for some
  digraphs has been resolved.
* A bug which led to duplicate cliques and independent sets being found for some
  digraphs has been resolved.

## Version 0.4.2 (released 28/01/2016)
This is a minor release to fix a bug in `DigraphAllSimpleCircuits` that failed to
return all simple circuits in some cases [Issue 13](https://bitbucket.org/james-d-mitchell/digraphs/issues/13). Some documentation was also updated.

## Version 0.4.1 (released 22/01/2016)
This is a very minor release to change the version of GAP required.

## Version 0.4 (released 19/01/2016)
This is a major release, primarily aimed at incorporating more of the
functionality of Grape into Digraphs, as well as fixing some bugs.  In this
version, we welcomed Jan De Beule to the development team.

### New Features in Version 0.4
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

[[Jan De Beule](http://homepages.vub.ac.be/~jdbeule/), [Julius Jonusas](http://www-circa.mcs.st-and.ac.uk/~julius),
[James D. Mitchell](http://tinyurl.com/jdmitchell),
[Michael Torpey](http://www-circa.mcs.st-and.ac.uk/~mct25),
[Wilf Wilson](http://wilf.me)]

## Version 0.3.2 (released 14/01/2016)
This is another minor release due to some missing build files in the Version
0.3.1 archive.

## Version 0.3.1 (released 13/01/2016)
This is a minor release due to some missing build files in the Version 0.3 archive.

## Version 0.3 (released 12/01/2016)
This release contains a number of bugfixes and performance improvements.

###New Features in Version 0.3
* The attribute `DigraphAllSimpleCircuits` based
on the algorithm in [this paper](http://epubs.siam.org/doi/abs/10.1137/0204007?journalCode=smjcat) by Donald B. Johnson. [Stuart Burrell and [Wilf Wilson](http://wilf.me)]
* Improve efficiency of the algorithm for coloring a graph with 2 colours, a method for `IsBipartiteDigraph` and `DigraphBicomponents`. [Isabella Scott and [Wilf Wilson](http://wilf.me)]
* `AutomorphismGroup` and `DigraphCanonicalLabelling` can now be used with color classes that are preserved by the permutations acting on a digraph. [[James D. Mitchell](http://tinyurl.com/jdmitchell)]
* The `TCodeDecoder` was made more efficient. [[James D. Mitchell](http://tinyurl.com/jdmitchell)]
* `AsTransformation` is introduced for digraphs in `IsFunctionalDigraph`. [[James D. Mitchell](http://tinyurl.com/jdmitchell)]
* The tests and their code coverage were improved.

###Issues Resolved in Version 0.3
* There was a memory leak in bliss-0.73, which is fixed in the copy of bliss included with Digraphs, but not in the official release of bliss. [[James D. Mitchell](http://tinyurl.com/jdmitchell)]
* Some bits of code that caused compiler warnings were improved. [[James D. Mitchell](http://tinyurl.com/jdmitchell)]
* Some memory leaks were resolved in the Digraphs kernel module. [[Michael Torpey](http://www-circa.mcs.st-and.ac.uk/~mct25)]


## Version 0.2 (released 04/09/2015)
The first release.

## Version 0.1
Pre-release version that was not made publicly available.
