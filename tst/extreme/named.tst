#############################################################################
##
#W  extreme/named.tst
#Y  Copyright (C) 2021                                Tom D. Conti-Leslie
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
## This tests attributes of all digraphs stored in the named graphs list
## against known values. Attributes tested are largely from House of Graphs
## at hog.grinvin.org.
##
gap> START_TEST("Digraphs package: extreme/named.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

# Load the record of stored test values
gap> f := Concatenation(DIGRAPHS_Dir(), "/data/named-g6-test.p.gz");;
gap> f := IO_CompressedFile(f, "r");;
gap> r := IO_Unpickle(f);;
gap> IO_Close(f);;

# For each graph, test Digraphs-generated properties against stored values.
# "failed" is a list of pairs [name, prop] where the digraph called "name"
# did not coincide with the test record on property "prop". The test is
# passed if this list remains empty. If it contains graphs, you should check
# those graphs for errors.
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
gap> Unbind(f);
gap> Unbind(r);
gap> Unbind(names);
gap> Unbind(name);
gap> Unbind(properties);
gap> Unbind(failed);
gap> Unbind(D);
gap> Unbind(prop);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: extreme/named.tst", 0);
