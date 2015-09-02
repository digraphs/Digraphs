##README
### Digraphs package for GAP
#### Copyright (C) 2014-15 Julius Jonusas, James Mitchell, Michael Torpey, Wilfred Wilson

## Getting Digraphs

To get the latest version of the package, download the archive file
`digraphs-x.x.tar.gz` from the
[Digraphs](https://bitbucket.org/james-d-mitchell/digraphs) webpage, and inside
the `pkg` subdirectory of your GAP installation unpack `digraphs-x.x.tar.gz`
using, for example:
```
gunzip digraphs-x.x.tar.gz; tar xvf digraphs-x.x.tar
```
This will create a subdirectory `digraphs-x.x`.

## Installation

It is assumed that you have a working copy of GAP with version number 4.7.3 or
higher.  The most up-to-date version of GAP and instructions on how to install
it can be obtained from the [main GAP webpage](http://www.gap-system.org).

The following is a summary of the steps that should lead to a successful
installation of Digraphs:

* download the package archive `digraphs-x.x.tar.gz` from the
  [Digraphs](https://bitbucket.org/james-d-mitchell/digraphs) webpage.

* unzip and untar the file `digraphs-x.x.tar.gz` using, for example,
```
gunzip digraphs-x.x.tar.gz; tar xvf digraphs-x.x.tar
```
  which should create a directory called `digraphs-x.x`.

* locate the `pkg` directory of your GAP directory, which contains the
  directories `lib`, `doc` and so on. Move the directory `digraphs-x.x` into the
  `pkg` directory (if it is not there already).

* start GAP in the usual way.

* type `LoadPackage("digraphs");`

* compile the documentation by typing `DigraphsMakeDoc();`

## Further Information

For questions, remarks, suggestions, and issues please use the
[issue tracker](http://bitbucket.org/james-d-mitchell/digraphs/issues).

# Julius Jonusas, James Mitchell, Michael Torpey, Wilfred Wilson
# 2nd of September 2015
