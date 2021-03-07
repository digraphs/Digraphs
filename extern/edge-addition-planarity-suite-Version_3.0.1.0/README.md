# Edge Addition Planarity Suite

The primary purpose of this repository is to provide implementations of the edge addition planar graph embedding algorithm and related algorithms, including a planar graph drawing method, an isolator for a minimal subgraph obstructing planarity in non-planar graphs, outerplanar graph embedder and obstruction isolator algorithms, and tester/isolator algorithms for subgraphs homeomorphic to _K<sub>2,3</sub>_, _K<sub>4</sub>_, and _K<sub>3,3</sub>_. The C implementations in this repository are the reference implementations of algorithms appearing in the following papers:

* [Subgraph Homeomorphism via the Edge Addition Planarity Algorithm](http://dx.doi.org/10.7155/jgaa.00268)

* [A New Method for Efficiently Generating Planar Graph Visibility Representations](http://dx.doi.org/10.1007/11618058_47)

* [On the Cutting Edge: Simplified O(n) Planarity by Edge Addition](http://dx.doi.org/10.7155/jgaa.00091)

* [Simplified O(n) Algorithms for Planar Graph Embedding, Kuratowski Subgraph Isolation, and Related Problems](https://dspace.library.uvic.ca/handle/1828/9918)

As secondary purpose of this repository is to provide a generalized graph API that enables implementation of a very wide range of in-memory graph algorithms including basic methods for reading, writing, depth first search, and lowpoint as well as advanced methods for solving planarity, outerplanarity, drawing, and selected subgraph homeomorphism problems. An extension mechanism is also provided to enable implementation of planarity-related algorithms by overriding and augmenting data structures and methods of the core planarity algorithm.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. 

### Pre-compiled Executable Releases for Non-Developers

This repository includes releases of already compiled versions of an application for non-developers to use the algorithm implementations. Download and decompress planarity._Platform_.zip. If you execute the _planarity.exe_ program with a "-test" parameter, the algorithms will be performed on the graphs in the files in the _samples_ directory, and a success result will be reported. 

The application includes a menu driven mode that lets a user manually select algorithms to run and, where appropriate, files containing graphs on which to run the algorithms. To access the menu mode, execute _planarity.exe_ without any command line parameters.

The application also supports an extensive list of command-line parameters that make it possible to automate the execution of any of the algorithms included in the application. Execute _planarity.exe_ with the "-h" command-line parameter to get more information about the command line options, and use "-h -menu" for more extensive information about command-line mode.

### Setting up a Development Environment

A development environment for the C reference implementations can be set up based on Eclipse.

1. Install a recent version of the Java JDK (such as Java version 14 or higher)
2. Ensure that you set the JAVA_HOME system environment variable (e.g. to c:\Program Files\Java\jdk-14.0.1)
3. Ensure that you add %JAVA_HOME%\bin to your system PATH
4. Install Eclipse, such as the "Eclipse IDE for Enterprise Java Developers"
5. Install gcc, gdb, and msys (e.g. download and run mingw-get-setup.exe from [here](https://osdn.net/projects/mingw/releases/) and then use the package installer to install C and C++, GDB, MSYS, and any other packages you may want.)
6. Ensure your gcc is accessible from the command line (e.g. add C:\MinGW\bin to the system PATH)
7. In Eclipse, and install the C Development Tools (CDT)
    1. In Eclipse, choose the menu option Help > Install New Software
    2. Choose to work with the main repository (e.g. 2020 - 06 - http://download.eclipse.org/releases)
    3. Under Programming Languages, choose C/C++ Autotools, C/C++ Development Tools, C/C++ Development Tools SDK, C/C++ Library API Documentation Hover Help, and C/C++ Unit Testing Support
    
### Working with the Code in the Development Environment

In this repository, the "Code" button provides the [HTTPS clone](https://github.com/graph-algorithms/edge-addition-planarity-suite.git) link to use to get the code. 

1. In Eclipse, use the Open Perspectives button (or Window | Perspective | Open Perspective | Git)
2. In the web browser, go to the "Code" button, HTTPS clone, and get the URL into the copy/paste clipboard.
3. Go to the Eclipse Git Repositories panel, and clic "Clone a Git repository"
4. The URI, Host, and Repository are pre-filled correctly from the copy/paste clipboard.
5. Leave the User/Password blank, and hit Next
6. The master branch is selected by default, so just hit Next again
7. Change the destination directory to a subdirectory where you want to store the project code (e.g. c:\Users\_you_\Documents\eclipse\workspaces-cpp\graph-algorithms\edge-addition-planarity-suite)
8. Hit Finish

Once you have the code, you will be able to import the project, build the _planarity.exe_ application and use the run and debug features of Eclipse.

1. Use the Open Perspectives button (or Windows | Perspective | Open Perspective | Other…)
2. Select C/C++
3. In the Project Explorer window, click Import projects...
4. Choose General | Existing Projects into Workspace and hit Next >
5. For "Select root directory:" choose "Browse..."
6. Navigate to .../edge-addition-planarity-suite/c (This autofills and selects Planarity-C in Projects list)
7. Hit Finish (do not select "Copy projects into workspace")
8. Right-click Planarity-C project, Build Configurations, Build All
9. Right-click Planarity-C project, Build Configurations, Set Active, Release
10. Right-click Planarity-C project, Run As, Local Application, planarity.exe (release)

## Contributing

Subject to your acceptance of the license agreement, contributions can be made via a pull request. Before submitting a pull request, please ensure that you have set your github user name and email within your development environment. For Eclipse, you can use the following steps:

1. Window > Preferences > Team > Git > Configuration
2. Add Entry... user.name (set the value to your github identity)
3. Add Entry... user.email (set the value to the primary email of your github identity)
4. Hit Apply and Close

## Versioning

The APIs for the graph library and the planarity algorithm implementations are versioned using the method documented in [configure.ac](configure.ac).

The _planarity.exe_ application, which provides command-line and menu-driven interfaces for the graph library and planarity algorithms, is versioned according to the _Major.Minor.Maintenance.Tweak_ numbering system documented in the comments in [planarity.c](c/planarity.c). 

## License

This project is licensed under a 3-clause BSD License appearing in [LICENSE.TXT](LICENSE.TXT).

## Related Works and Further Documentation

There have been successful technology transfers of the implementation code and/or algorithms of this project into other projects. To see a list of the related projects and for further documentation about this project, please see the [project wiki](https://github.com/graph-algorithms/edge-addition-planarity-suite/wiki).
