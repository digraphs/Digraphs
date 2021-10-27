[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4763272.svg)](https://doi.org/10.5281/zenodo.4763272)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/digraphs/digraphs/master)
[![Build status](https://github.com/digraphs/Digraphs/workflows/CI/badge.svg?branch=master)](https://github.com/digraphs/Digraphs/actions?query=workflow%3ACI+branch%3Amaster)
[![Code coverage](https://codecov.io/gh/digraphs/Digraphs/branch/master/graphs/badge.svg)](https://codecov.io/gh/digraphs/Digraphs/branch/master)

## README

### Digraphs package for GAP

#### Copyright (C) 2014-21 by Jan De Beule, Julius Jonušas, James D. Mitchell, Wilf A. Wilson, Michael Young et al.
## Getting Digraphs

To get the latest version of the package, download the archive file
`digraphs-x.x.x.tar.gz` from the [Digraphs webpage][]. Then, inside the `pkg`
subdirectory of your GAP installation, unpack the archive
`digraphs-x.x.x.tar.gz`, using

    gunzip digraphs-x.x.x.tar.gz; tar xvf digraphs-x.x.x.tar

for example.  This will create a subdirectory `digraphs-x.x.x`.

## Issues

For questions, remarks, suggestions, and issues please use the
[issue tracker](https://github.com/digraphs/Digraphs/issues).

## Installation

It is assumed that you have a working copy of [GAP][] with version number
4.10.0 or higher.  The most up-to-date version of GAP, and instructions on how
to install it, can be obtained from the 
[main GAP webpage](https://www.gap-system.org).

The following is a summary of the steps that should lead to a successful
installation of Digraphs:

* get the [IO](https://gap-packages.github.io/io) package version 4.5.1 or
  higher.
* get the [orb](https://gap-packages.github.io/orb) package version 4.8.2 or
  higher.
* get the [datastructures](https://gap-packages.github.io/datastructures)
  package version 0.2.5 or higher.
* **this step is optional:** certain methods in Digraphs require the
  [Grape](https://gap-packages.github.io/grape/) package to be available; a
  full list of these functions can be found in the first chapter of the manual.
  To use these functions make sure that the Grape package version 4.8.1 or
  higher is available.
* **this step is optional**: get the
  [NautyTracesInterface](https://github.com/gap-packages/NautyTracesInterface)
  package version 0.2 or higher.
* download the package archive `digraphs-x.x.x.tar.gz` from the
  [Digraphs webpage][].
* unzip and untar the file `digraphs-x.x.x.tar.gz` using, for example,
  ```
    gunzip digraphs-x.x.x.tar.gz; tar xvf digraphs-x.x.x.tar
  ```
  which should create a directory called `digraphs-x.x.x`.
* locate the `pkg` directory of your GAP directory, which contains the
  directories `lib`, `doc` and so on. Move the directory `digraphs-x.x.x` into
  the `pkg` directory (if it is not there already).
* compile the kernel module; more details are given below.
* start GAP in the usual way.
* type `LoadPackage("digraphs");`

## Compiling the kernel module

The Digraphs package has a GAP kernel component written in C, which has to be
compiled in order for the package to work.  This component contains certain
low-level functions that the package requires.

It is not possible to use the Digraphs package without compiling it.

To compile the kernel component inside the `digraphs-x.x.x` directory, type

    ./configure
    make

If you installed the package in a `pkg` directory other than the standard `pkg`
directory in your GAP installation, then you have to do two things. Firstly,
during compilation you have to use the option `--with-gaproot=PATH` of the
`configure` script where `PATH` is a path to the main GAP root directory (if
not given, the default `../..` is assumed).

If you installed GAP on several architectures, then you must execute the
configure/make step for each of the architectures. You can either do this
immediately after configuring and compiling GAP itself on this architecture, or
alternatively set the environment variable `CONFIGNAME` to the name of the
configuration you used when compiling GAP before running `./configure`.  Note
however that your compiler choice and flags (environment variables `CC` and
`CFLAGS`) need to be chosen to match the setup of the original GAP compilation.
For example, you have to specify 32-bit or 64-bit mode correctly!

### Configuration options

In addition to the usual autoconf generated configuration flags, the following
flags are provided.

Option                        | Meaning
----------------------------- | ------------------------------------------------
--enable-code-coverage        | enable code coverage support
--enable-compile-warnings     | enable compiler warnings
--enable-debug                | enable debug mode
--with-external-bliss         | use external `bliss`
--with-external-planarity     | use external `planarity`
--with-gaproot                | specify root of GAP installation
--without-intrinsics          | do not use compiler intrinsics even if available

Digraphs vendors the `bliss` and `planarity` libraries in the `extern` directory.
If you wish to use your system copy of `bliss` or `planarity`, please use the
configure options `--with-external-bliss` or `--with-external-planarity`, as
appropriate.

If you wish to install a
[development version of the Digraphs package](https://github.com/digraphs/Digraphs),
then you must first run the command `./autogen.sh` before compilation. However,
development versions of the package may be unstable, and we recommend using the
most recently released version of the package when possible.

Enjoy!

[Digraphs webpage]: https://digraphs.github.io/Digraphs
[GAP]: https://www.gap-system.org
