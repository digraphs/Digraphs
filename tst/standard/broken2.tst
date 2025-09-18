#@local gr
gap> START_TEST("Digraphs package: standard/broken2.tst");
gap> LoadPackage("digraphs", false);;

#
gap> DIGRAPHS_StartTest();

# Runs fine
gap> gr := TCodeDecoder(3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `TCodeDecoder' on 1 arguments

# Gives a different error if <gr> does not exist as a global variable!
gap> TCodeDecoder("gr 5");
Error, the 2nd argument <s> must be a string of space-separated non-negative i\
ntegers,

# Let's see if assigning to <gr> helps
gap> gr := CycleDigraph(5);;

# Gives a different error if <xd> does not exist as a global variable!
gap> TCodeDecoder("xd 5");
Error, the 2nd argument <s> must be a string of space-separated non-negative i\
ntegers,

# Gives a different error if <gr> does not exist as a global variable!
gap> TCodeDecoder("gr 5");
Error, the 2nd argument <s> must be a string of space-separated non-negative i\
ntegers,

#
gap> DIGRAPHS_StopTest();
gap> STOP_TEST("Digraphs package: standard/broken2.tst", 0);
