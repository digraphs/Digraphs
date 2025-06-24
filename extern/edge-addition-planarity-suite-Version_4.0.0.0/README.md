# Edge Addition Planarity Suite

The primary purpose of this repository is to provide implementations of the edge addition planar graph embedding algorithm and related algorithms, including a planar graph drawing method, an isolator for a minimal subgraph obstructing planarity in non-planar graphs, outerplanar graph embedder and obstruction isolator algorithms, and tester/isolator algorithms for subgraphs homeomorphic to _K<sub>2,3</sub>_, _K<sub>4</sub>_, and _K<sub>3,3</sub>_. The C implementations in this repository are the reference implementations of algorithms appearing in the following papers:

* [Subgraph Homeomorphism via the Edge Addition Planarity Algorithm](http://dx.doi.org/10.7155/jgaa.00268)

* [A New Method for Efficiently Generating Planar Graph Visibility Representations](http://dx.doi.org/10.1007/11618058_47)

* [On the Cutting Edge: Simplified O(n) Planarity by Edge Addition](http://dx.doi.org/10.7155/jgaa.00091)

* [Simplified O(n) Algorithms for Planar Graph Embedding, Kuratowski Subgraph Isolation, and Related Problems](https://dspace.library.uvic.ca/handle/1828/9918)

A secondary purpose of this repository is to provide a generalized graph API that enables implementation of a very wide range of in-memory graph algorithms including basic methods for reading, writing, depth first search, and lowpoint as well as advanced methods for solving planarity, outerplanarity, drawing, and selected subgraph homeomorphism problems. An extension mechanism is also provided to enable implementation of planarity-related algorithms by overriding and augmenting data structures and methods of the core planarity algorithm.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. 

### Pre-compiled Executable Releases for Non-Developers

On several (Debian-based) distributions of Linux, you may be able to get the planarity executable with `sudo apt install planarity`, or you may already have access to its key functionality if you have SageMath or MATLAB. For non-developer users on an operating system _Platform_ supported by the release, a pre-compiled executable version of the `planarity` executable can be obtained by downloading from the release tag and then decompressing the `planarity-N.N.N.N.`_Platform_`Exe.zip` file. 

If you run the `planarity` executable program, it will offer an interactive, menu-driven mode that lets a user manually select algorithms to run and, where appropriate, files containing graphs on which to run the algorithms. 

The `planarity` executable program also supports an extensive list of command-line parameters that make it possible to automate the execution of any of the algorithms included in the application. Run `planarity` with the `-h` command-line parameter to get more information about the command line options, and use `-h -menu` for more extensive information about command-line mode. Essentially, all functionality available in the interactive, menu-driven mode is also available via the command-line parameters.

### Setting up a Development Environment

Please refer to the [2. Dev Setup](https://github.com/graph-algorithms/edge-addition-planarity-suite/wiki/2.-Dev-Setup) wiki page for instructions on how to install development dependencies on various supported platforms, as well as how to get started working with the project in Visual Studio Code.

### Making the Distribution

Once one has set up the development environment and is able to work with the code in the development environment, it is possible to make the distribution with the following additional steps:

1. Ensure that the `autotools`, `configure`, and `make` are available on the command-line (e.g. add `C:\msys64\usr\bin` to the system `PATH` before Windows Program Files to ensure that the `find` program is the one from `MSYS2` rather than the one from Windows (e.g. adjust the `PATH` variable as needed)). 
2. Open `bash` (e.g., on Windows, open the start menu and start typing "MSYS2 UCRT64" to open the correct terminal app), then within `bash` navigate to the root of the `edge-addition-planarity-suite` repository (i.e., the directory containing `configure.ac` and the `c` subdirectory)
3. Enter the following commands:
    1. `autoreconf -fi`
    2. `./configure`
    3. `make dist`
    4. `make distcheck`

The result is a validated `planarity-N.N.N.N.tar.gz` distribution, where `N.N.N.N` is the version number expressed in the `AC_INIT` line of the `configure.ac` file. 

### Making and Running the Software from the Distribution

If you have done the steps to set up the development environment and work with the code, then you can make and run the software using the development environment, so you don't necessarily need to make or run the software using the process below.

You also don't necessarily need to `make` and `make install` the planarity software on Linux if you are able to get it using `sudo apt planarity` (i.e. using a Debian-based Linux distribution, which uses [`apt`](https://en.wikipedia.org/wiki/APT_(software)) for package management)

However, you may have only downloaded the distribution (i.e., `planarity-N.N.N.N.tar.gz`) from a Release tag of this project. Once you have decompressed the distribution into a directory, you can make it by getting into `bash` (e.g., on Windows, open the start menu and start typing "MSYS2 UCRT64" to open the correct terminal app) and then entering the following commands: 
1. `./configure`
2. `make`

At this point, the `planarity` executable can be run from within the distribution directory. For example, on Windows, go to the `.libs/` subdirectory containing the `planarity` executuable and the `libplanarity` DLL and run `planarity -test ../c/samples` on the command-line. 

On Linux, the planarity program can also be installed by entering `sudo make install` on the command-line. Note that the `libplanarity` shared object and symlinks will be installed to `/usr/local/lib` so it will be necessary to set `LD_LIBRARY_PATH` accordingly. For one session, this can be done with `export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib`. To make it more permanent, you could use:
1. Create a new file `/etc/ld.so.conf.d/planarity.conf` containing `/usr/local/lib`
2. Run `sudo ldconfig`

## Versioning

The overall project and the APIs for the graph library and the planarity-related algorithm implementations are versioned using the methods documented in [`configure.ac`](configure.ac) and [`graphLib.h`](c/graphLib/graphLib.h). The overall project version adheres to a `Major.Minor.Maintenance.Tweak` numbering system, and the `libPlanarity` shared library, which contains the graph library and planarity-related algorithm implementations, is versioned using the _current:revision:age_ system from `LibTool`.

The `planarity.exe` application, which provides command-line and menu-driven interfaces for the graph library and planarity-related algorithms, is versioned using the overall project version defined in [`graphLib.h`](c/graphLib/graphLib.h) (see [`planarityHelp.c`](c/planarityApp/planarityHelp.c)). 

## License

This project is licensed under a 3-clause BSD License appearing in [`LICENSE.TXT`](LICENSE.TXT).

## Related Works and Further Documentation

There have been successful technology transfers of the implementation code and/or algorithms of this project into other projects. To see a list of the related projects and for further documentation about this project, please see the [project wiki](https://github.com/graph-algorithms/edge-addition-planarity-suite/wiki).
