#############################################################################
##
#W  standard/named.tst
#Y  Copyright (C) 2021                                   Tom D. Conti-Leslie
##                       
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##
gap> START_TEST("Digraphs package: standard/named.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

# Unpickle the NAMED GRAPHS MAIN and NAMED GRAPHS TEST records.
# Check the entries match.
gap> f := Concatenation(DIGRAPHS_Dir(), "/data/named-g6.p.gz");;
gap> f := IO_CompressedFile(f, "r");;
gap> main := IO_Unpickle(f);;
gap> IO_Close(f);;
gap> f := Concatenation(DIGRAPHS_Dir(), "/data/named-g6-test.p.gz");;
gap> f := IO_CompressedFile(f, "r");;
gap> test := IO_Unpickle(f);;
gap> IO_Close(f);;
gap> Set(RecNames(main)) = Set(RecNames(test));
true

# NAMED GRAPHS MAIN:
# - ensure every name is lowercase with no spaces
# - ensure every value is a string
# if anything does not satisfy these conditions, goes in failed list.
gap> failed_names := [];;
gap> failed_values := [];;
gap> for name in RecNames(main) do
>      name2 := LowercaseString(name);;
>      RemoveCharacters(name2, " \n\t\r");;
>      if name <> name2 then
>        Add(failed_names, name);;
>      fi;
>      if not IsString(main.(name)) then
>        Add(failed_values, name);;
>      fi;
>    od;
gap> failed_names;
[  ]
gap> failed_values;
[  ]

# NAMED GRAPHS TEST:
# - ensure every value is a record
# - ensure every value has at least one component
# if any component doesn't satisfy these conditions, its name goes in "failed"
gap> failed := [];;
gap> for name in RecNames(test) do
>      if not IsRecord(test.(name)) then
>        Add(failed, name);;
>      else
>        if Length(RecNames(test.(name))) = 0 then
>          Add(failed, name);;
>        fi;
>      fi;
>    od;
gap> failed;
[  ]

# Check behaviour on some string inputs.
gap> Digraph("Surely no graph has this name");
Error, Named graph not found. Please check argument 'name',
or view list of available graphs with prefix p using
ListNamedGraphs(p).
gap> D := Digraph("folkman");
<immutable digraph with 20 vertices, 80 edges>
gap> D = Digraph("F \n  Ol k\tMA\r\r n");
true
gap> Digraph("");
<immutable empty digraph with 0 vertices>

# Check attributes of first few graphs (extreme/named.tst checks all).
# "failed" is a list of pairs [name, prop] where the digraph called "name"
# did not coincide with the test record on property "prop". The test is
# passed if this list remains empty. If it contains graphs, you should check
# those graphs for errors.
gap> m := Minimum(20, Length(RecNames(main)));;
gap> failed := [];;
>    for name in RecNames(main){[1 .. m]} do
>      D := Digraph(name);;
>      properties := test.(name);;
>      for prop in RecNames(properties) do
>        if ValueGlobal(prop)(D) <> properties.(prop) then
>          Add(failed, [name, prop]);;
>        fi;
>      od;
>    od;
gap> failed;
[  ]

# ListNamedDigraphs
gap> Length(RecNames(DIGRAPHS_NamedGraph6String))
>    = Length(ListNamedDigraphs(""));
true
gap> "folkman" in ListNamedDigraphs("F\n oL");
true
gap> ListNamedDigraphs("Surely no digraph has this name");
[  ]

#  DIGRAPHS_UnbindVariables
gap> Unbind(f);
gap> Unbind(main);
gap> Unbind(test);
gap> Unbind(failed_names);
gap> Unbind(failed_values);
gap> Unbind(failed);
gap> Unbind(name);
gap> Unbind(name2);
gap> Unbind(D);
gap> Unbind(m);
gap> Unbind(properties);
gap> Unbind(prop);

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/named.tst", 0);
