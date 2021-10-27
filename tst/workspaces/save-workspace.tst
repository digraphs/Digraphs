#############################################################################
##
#W  workspaces/save-workspace.tst
#Y  Copyright (C) 2017                                      Wilf A. Wilson
##                                                          Michael Young
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
##  This file, together with load-workspace.tst, tests the ability to save
##  and load workspaces which include Digraph objects.  Objects should be
##  created and stored in save-workspace.tst, and then loaded and tested in
##  load-workspace.tst to ensure that they work correctly after being saved.
##
#############################################################################

# Set up testing environment
gap> START_TEST("Digraphs package: workspaces/save-workspace.tst");
gap> SetInfoLevel(InfoDebug, 0);
gap> LoadPackage("digraphs", false);;
gap> DIGRAPHS_StartTest();

#############################################################################
##  Create objects below here, and add tests to load-workspace.tst to ensure
##  that they are saved to disk correctly.  Do not reuse variable names.
#############################################################################

#T# Temporary
gap> gr := Digraph([[1]]);
<immutable digraph with 1 vertex, 1 edge>

#############################################################################
##  Tests end here
#############################################################################

# Save the workspace
gap> SaveWorkspace(Concatenation(DIGRAPHS_Dir(),
>                                "/tst/workspaces/test-output.w"));
true

# DIGRAPHS_UnbindVariables
gap> Unbind(gr);

#
gap> STOP_TEST("Digraphs package: workspaces/save-workspace.tst", 0);
