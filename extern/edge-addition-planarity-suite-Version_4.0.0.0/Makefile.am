SUBDIRS = c/samples

ACLOCAL_AMFLAGS = -I m4

lib_LTLIBRARIES = libplanarity.la

libplanarity_la_SOURCES = \
	c/graphLib/graphDFSUtils.c \
	c/graphLib/graphUtils.c \
	c/graphLib/extensionSystem/graphExtensions.c \
	c/graphLib/homeomorphSearch/graphK23Search.c \
	c/graphLib/homeomorphSearch/graphK23Search_Extensions.c \
	c/graphLib/homeomorphSearch/graphK33Search.c \
	c/graphLib/homeomorphSearch/graphK33Search_Extensions.c \
	c/graphLib/homeomorphSearch/graphK4Search.c \
	c/graphLib/homeomorphSearch/graphK4Search_Extensions.c \
	c/graphLib/io/g6-api-utilities.c \
	c/graphLib/io/g6-read-iterator.c \
	c/graphLib/io/g6-write-iterator.c \
	c/graphLib/io/graphIO.c \
	c/graphLib/io/strbuf.c \
	c/graphLib/io/strOrFile.c \
	c/graphLib/lowLevelUtils/apiutils.c \
	c/graphLib/lowLevelUtils/listcoll.c \
	c/graphLib/lowLevelUtils/stack.c \
	c/graphLib/planarityRelated/graphDrawPlanar.c \
	c/graphLib/planarityRelated/graphDrawPlanar_Extensions.c \
	c/graphLib/planarityRelated/graphEmbed.c \
	c/graphLib/planarityRelated/graphIsolator.c \
	c/graphLib/planarityRelated/graphNonplanar.c \
	c/graphLib/planarityRelated/graphOuterplanarObstruction.c \
	c/graphLib/planarityRelated/graphTests.c

libplanarity_la_LDFLAGS = -no-undefined $(AM_LDFLAGS) -version-info @LT_CURRENT@:@LT_REVISION@:@LT_AGE@

# These pkgincludes are added without "nobase_" so that the files will be copied to the
# root of the planarity project includedir (i.e. excluding the c subdirectory)
pkginclude_HEADERS = \
	c/graph.h \
	c/graphLib.h

# This is the full set of pkgincludes for which "nobase_" has been used to ensure that
# the directory structure is retained when installing the planarity headers.
nobase_pkginclude_HEADERS = \
	c/graphLib/graph.h \
	c/graphLib/graphLib.h \
	c/graphLib/graphStructures.h \
	c/graphLib/extensionSystem/graphExtensions.h \
	c/graphLib/extensionSystem/graphExtensions.private.h \
	c/graphLib/extensionSystem/graphFunctionTable.h \
	c/graphLib/homeomorphSearch/graphK23Search.h \
	c/graphLib/homeomorphSearch/graphK23Search.private.h \
	c/graphLib/homeomorphSearch/graphK33Search.h \
	c/graphLib/homeomorphSearch/graphK33Search.private.h \
	c/graphLib/homeomorphSearch/graphK4Search.h \
	c/graphLib/homeomorphSearch/graphK4Search.private.h \
	c/graphLib/io/g6-api-utilities.h \
	c/graphLib/io/g6-read-iterator.h \
	c/graphLib/io/g6-write-iterator.h \
	c/graphLib/io/strbuf.h \
	c/graphLib/io/strOrFile.h \
	c/graphLib/lowLevelUtils/apiutils.h \
	c/graphLib/lowLevelUtils/appconst.h \
	c/graphLib/lowLevelUtils/listcoll.h \
	c/graphLib/lowLevelUtils/platformTime.h \
	c/graphLib/lowLevelUtils/stack.h \
	c/graphLib/planarityRelated/graphDrawPlanar.h \
	c/graphLib/planarityRelated/graphDrawPlanar.private.h \
	c/planarityApp/planarity.h

bin_PROGRAMS = planarity
planarity_LDADD  = libplanarity.la
planarity_SOURCES = \
	c/planarityApp/planarity.c \
	c/planarityApp/planarityCommandLine.c \
	c/planarityApp/planarityHelp.c \
	c/planarityApp/planarityMenu.c \
	c/planarityApp/planarityRandomGraphs.c \
	c/planarityApp/planaritySpecificGraph.c \
	c/planarityApp/planarityTransformGraph.c \
	c/planarityApp/planarityTestAllGraphs.c \
	c/planarityApp/planarityUtils.c

man1_MANS = c/planarityApp/planarity.1
EXTRA_DIST=$(man1_MANS)

TESTS = test-samples.sh

# The @docdir@ variable will be replaced by the ./configure script.
docdir = @docdir@
dist_doc_DATA = README.md LICENSE.TXT

pkgconfig_DATA = libplanarity.pc
