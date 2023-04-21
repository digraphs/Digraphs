#############################################################################
##
#W  extreme/named.tst
#Y  Copyright (C) 2021                                Tom D. Conti-Leslie
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
## This tests attributes of all digraphs stored in the named digraphs main
## database against known values. Attributes tested are largely from House
## of Graphs at hog.grinvin.org.
##
gap> START_TEST("Digraphs package: extreme/named.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

# Load the record of stored test values
gap> DIGRAPHS_LoadNamedDigraphsTests();
gap> r := DIGRAPHS_NamedDigraphsTests;;

# For each graph, test Digraphs-generated properties against stored values.
# "failed" is a list of pairs [name, prop] where the digraph called "name"
# did not coincide with the test record on property "prop". The test is
# passed if this list remains empty. If it contains digraphs, you should check
# those digraphs for errors.
gap> names := RecNames(r);;
gap> failed := [];;
gap> for name in names do
>      D := Digraph(name);;
>      properties := r.(name);;
>      for prop in RecNames(properties) do
>        if ValueGlobal(prop)(D) <> properties.(prop) then
>          Add(failed, [name, prop]);;
>        fi;
>      od;
>    od;
gap> failed;
[  ]

#  DIGRAPHS_UnbindVariables
gap> Unbind(D);
gap> Unbind(failed);
gap> Unbind(name);
gap> Unbind(names);
gap> Unbind(prop);
gap> Unbind(properties);
gap> Unbind(r);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: extreme/named.tst", 0);
