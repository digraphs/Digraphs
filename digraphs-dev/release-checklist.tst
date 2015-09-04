#29/05/13 JDM

#make sure you are in the version branch (1.1 or whatever) and that there are
#no outstanding commits

# review JDM/TODO/FIXME comment in GAP files!

# gaplint! !

# run the profiling tool from Wilf

# update the readme, versions, changelog, and packageinfo.g

# compile the documentation 

# change the version numbers in this file! 

# ValidatePackageInfo("pkg/digraphs/PackageInfo.g");
# LoadAllPackages();
# LoadAllPackages(:Reversed);

# gap -N -A -x 80 -r -m 100m -o 512m
DigraphsTestInstall();
DigraphsTestStandard();
DigraphsTestManualExamples();
Read("tst/testinstall.g");  
Test("tst/bugfix.tst"); 

# run the Digraphs tests with Orb compiled/uncompiled do:

gap -A
LoadPackage("digraphs" : OnlyNeeded);
DigraphsTestInstall();
DigraphsTestManualExamples();
DigraphsTestAll();

# check that digraphs and smallsemi can be loaded in either order with no
# errors

# check that digraphs can be loaded with and without GRAPE, compiled and not
# compiled

# check that digraphs can be loaded with Orb not compiled.

# make teststandard
# make testpackagesload

# Test that the package:

## does not break testinstall.g and testall.g and does not slow them down
## noticeably (see A.14-4);

## the following when compiled and when not.

# Package documentation:
## is built and included in the package archive together with its source files;
## is searchable using the GAP help system;
## is clear about the license under which the package is distributed;

# compile the documentation,
hg tag 0.2-release
hg commit

hg archive /tmp/digraphs
cp doc/* /tmp/digraphs/doc

cd /tmp/digraphs

rm .hgignore
rm .hgtags
rm code-coverage-test.py
rm configure.ac
rm Makefile.am

cd /tmp
ditto --norsrc digraphs digraphs_copy
rm -r digraphs
mv digraphs_copy digraphs-0.2

tar -cpf digraphs-0.2.tar digraphs-0.2 ; gzip -9 digraphs-0.2.tar
rm -r digraphs-0.2
cp digraphs-0.2.tar.gz ~/Desktop
cp digraphs-0.2.tar.gz ~/Sites/public_html/digraphs

cd
cd ~/Sites/public_html/digraphs
hg add digraphs-0.2.tar.gz
cp ~/digraphs/README.md .
cp ~/digraphs/PackageInfo.g .
cp ~/digraphs/CHANGELOG.md .

cp ~/digraphs/doc/* doc/

# update the info in the webpage!
# make sure to hg commit and push

# check links on webpage, check package info at
# http://www.gap-system.org/Packages/Authors/authors.html

# download archive, start gap, and run test install and manual exampels

# Package availability:

## not only the package archive(s), but also the PackageInfo.g and README files 
## are available online;

cd ; cd digraphs

#merge the version branch into default

#close the 0.2 branch

#change the default branch number/milestone on bitbucket

# open the next release branch



