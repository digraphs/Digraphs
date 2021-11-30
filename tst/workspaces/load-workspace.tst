#############################################################################
##
#W  workspaces/load-workspace.tst
#Y  Copyright (C) 2017                                      Wilf A. Wilson
##                                                          Michael Young
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
##  This file, together with save-workspace.tst, tests the ability to save
##  and load workspaces which include Digraph objects.  Objects should be
##  created and stored in save-workspace.tst, and then loaded and tested in
##  load-workspace.tst to ensure that they work correctly after being saved.
##
#############################################################################

# Set up testing environment
gap> START_TEST("Digraphs package: workspaces/load-workspace.tst");
gap> DIGRAPHS_StartTest();

#############################################################################
##  Test objects that were created in save-workspace.tst, using the same
##  variable names.
#############################################################################

#T# Temporary
gap> DigraphNrVertices(gr);
1

#############################################################################
##  Tests end here
#############################################################################

# DIGRAPHS_UnbindVariables
gap> Unbind(gr);

#
gap> STOP_TEST("Digraphs package: workspaces/load-workspace.tst", 0);
