##Digraphs package for GAP - CHANGELOG
Copyright (C) 2014-16 Julius Jonusas, James D. Mitchell, Michael Torpey & Wilf Wilson

Licensing information can be found in the LICENSE file.

## Version 0.4 (released 16/01/2016)

###New Features in Version 0.4


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

###Issue Resolved in Version 0.3
* There was a memory leak in bliss-0.73, which is fixed in the copy of bliss included with Digraphs, but not in the official release of bliss. [[James D. Mitchell](http://tinyurl.com/jdmitchell)]
* Some bits of code that caused compiler warnings were improved. [[James D. Mitchell](http://tinyurl.com/jdmitchell)]
* Some memory leaks were resolved in the Digraphs kernel module. [[Michael Torpey](http://www-circa.mcs.st-and.ac.uk/~mct25)]


## Version 0.2 (released 04/09/2015)
The first release.

## Version 0.1 ##
Pre-release version that was not made publicly available.
