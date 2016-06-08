## README

### Digraphs package for GAP

#### Copyright (C) 2014-16 Jan De Beule, Julius Jonusas, James D. Mitchell, Finn Smith, Michael Torpey, Wilf Wilson

## Getting Digraphs

To get the latest version of the package, download the archive file
`digraphs-x.x.x.tar.gz` from the
[Digraphs](https://gap-packages.github.io/Digraphs) webpage, and inside
the `pkg` subdirectory of your GAP installation unpack `digraphs-x.x.x.tar.gz`
using, for example:

    gunzip digraphs-x.x.x.tar.gz; tar xvf digraphs-x.x.x.tar

This will create a subdirectory `digraphs-x.x.x`.

## Issues

For questions, remarks, suggestions, and issues please use the
[issue tracker](https://github.com/gap-packages/Digraphs/issues).

## Installation

It is assumed that you have a working copy of [GAP](http://www.gap-system.org)
with version number 4.7.8 or higher.  The most up-to-date version of
[GAP](http://www.gap-system.org) and instructions on how to install it can be
obtained from the [main GAP webpage](http://www.gap-system.org).

The following is a summary of the steps that should lead to a successful
installation of [Digraphs](https://gap-packages.github.io/Digraphs):

* get the [IO](http://gap-system.github.io/io/) package version 4.4.4 or higher

* **this step is optional:** certain methods in [Digraphs](https://gap-packages.github.io/Digraphs) require the [Grape](http://www.maths.qmul.ac.uk/~leonard/grape/) package to be available; a full list of these functions can be found in the first chapter of the manual.  To use these functions make sure that the [Grape](http://www.maths.qmul.ac.uk/~leonard/grape/) package version 4.5 or higher is available.

* download the package archive `digraphs-x.x.x.tar.gz` from the
  [Digraphs](https://gap-packages.github.io/Digraphs) webpage.

* unzip and untar the file `digraphs-x.x.x.tar.gz` using, for example,
  ```
    gunzip digraphs-x.x.x.tar.gz; tar xvf digraphs-x.x.x.tar
  ```
  which should create a directory called `digraphs-x.x.x`.

* locate the `pkg` directory of your GAP directory, which contains the
  directories `lib`, `doc` and so on. Move the directory `digraphs-x.x.x` into the
  `pkg` directory (if it is not there already).
  
* compile the kernel module; more details below.

* start [GAP](http://www.gap-system.org) in the usual way.

* type `LoadPackage("digraphs");`

## Compiling the kernel module

The [Digraphs](https://gap-packages.github.io/Digraphs)
package has a [GAP](http://www.gap-system.org) kernel component written in 
C which has to be compiled for the package to work.  This component contains
certain low-level functions required by [Digraphs](https://gap-packages.github.io/Digraphs).

It is not possible to use the [Digraphs](https://gap-packages.github.io/Digraphs) package without compiling it.

To compile the kernel component inside the `digraphs-x.x.x` directory, type

    ./configure
    make

If you installed the package in a `pkg` directory other than the standard `pkg`
directory in your [GAP](http://www.gap-system.org) installation, then you have
to do two things. Firstly during compilation you have to use the option
`--with-gaproot=PATH` of the `configure` script where `PATH` is a path to the
main [GAP](http://www.gap-system.org) root directory (if not given the default
`../..` is assumed).

If you installed [GAP](http://www.gap-system.org) on several architectures, you
must execute the configure/make step for each of the architectures. You can
either do this immediately after configuring and compiling
[GAP](http://www.gap-system.org) itself on this architecture, or alternatively
(when using version 4.5 of [GAP](http://www.gap-system.org) or newer) set the
environment variable `CONFIGNAME` to the name of the configuration you used
when compiling [GAP](http://www.gap-system.org) before running `./configure`.
Note however that your compiler choice and flags (environment variables `CC`
and `CFLAGS`) need to be chosen to match the setup of the original
[GAP](http://www.gap-system.org) compilation. For example you have to specify
32-bit or 64-bit mode correctly!

Enjoy!
