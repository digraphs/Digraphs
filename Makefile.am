#
# digraphs:
#
# This file is part of the build system of a GAP kernel extension.
# Requires automake.
#

ACLOCAL_AMFLAGS = -I m4

SUBDIRS = @PLANARITY_SUITE_DIR@

PLANAR_INCLUDE   = -I$(top_srcdir)/@PLANARITY_SUITE_DIR@/
DIGRAPHS_INCLUDE = -I$(top_srcdir)/extern/

BINARCHDIR = bin/$(GAPARCH)
GAPINSTALLLIB = $(abs_top_srcdir)/$(BINARCHDIR)

lib_LTLIBRARIES = digraphs.la

pkginclude_HEADERS =  src/bitarray.h
pkginclude_HEADERS += src/conditions.h
pkginclude_HEADERS += src/digraphs-debug.h
pkginclude_HEADERS += src/digraphs.h
pkginclude_HEADERS += src/homos-graphs.h
pkginclude_HEADERS += src/homos.h
pkginclude_HEADERS += src/perms.h
pkginclude_HEADERS += src/planar.h
pkginclude_HEADERS += src/schreier-sims.h
pkginclude_HEADERS += extern/bliss-0.73/bignum.hh
pkginclude_HEADERS += extern/bliss-0.73/bliss_C.h
pkginclude_HEADERS += extern/bliss-0.73/defs.hh
pkginclude_HEADERS += extern/bliss-0.73/graph.hh
pkginclude_HEADERS += extern/bliss-0.73/heap.hh
pkginclude_HEADERS += extern/bliss-0.73/kqueue.hh
pkginclude_HEADERS += extern/bliss-0.73/kstack.hh
pkginclude_HEADERS += extern/bliss-0.73/orbit.hh
pkginclude_HEADERS += extern/bliss-0.73/partition.hh
pkginclude_HEADERS += extern/bliss-0.73/timer.hh
pkginclude_HEADERS += extern/bliss-0.73/uintseqhash.hh
pkginclude_HEADERS += extern/bliss-0.73/utils.hh

digraphs_la_SOURCES =  src/digraphs.c
digraphs_la_SOURCES += src/bitarray.c
digraphs_la_SOURCES += src/conditions.c
digraphs_la_SOURCES += src/homos.c
digraphs_la_SOURCES += src/homos-graphs.c
digraphs_la_SOURCES += src/perms.c
digraphs_la_SOURCES += src/planar.c
digraphs_la_SOURCES += src/schreier-sims.c
digraphs_la_SOURCES += extern/bliss-0.73/defs.cc
digraphs_la_SOURCES += extern/bliss-0.73/graph.cc
digraphs_la_SOURCES += extern/bliss-0.73/partition.cc
digraphs_la_SOURCES += extern/bliss-0.73/orbit.cc
digraphs_la_SOURCES += extern/bliss-0.73/uintseqhash.cc
digraphs_la_SOURCES += extern/bliss-0.73/heap.cc
digraphs_la_SOURCES += extern/bliss-0.73/timer.cc
digraphs_la_SOURCES += extern/bliss-0.73/utils.cc
digraphs_la_SOURCES += extern/bliss-0.73/bliss_C.cc

digraphs_la_CPPFLAGS =  $(GAP_CPPFLAGS)
digraphs_la_CPPFLAGS += $(CODE_COVERAGE_CPPFLAGS)

digraphs_la_CXXFLAGS =  -O3 -march=native -mpopcnt
digraphs_la_CXXFLAGS += $(PLANAR_INCLUDE) $(DIGRAPHS_INCLUDE) 
digraphs_la_CXXFLAGS += $(CODE_COVERAGE_CXXFLAGS)

digraphs_la_CFLAGS   =  -O3 -march=native -mpopcnt
digraphs_la_CFLAGS   += $(GAP_CFLAGS) $(PLANAR_INCLUDE) $(DIGRAPHS_INCLUDE)
digraphs_la_CFLAGS   += $(CODE_COVERAGE_CFLAGS)

digraphs_la_LDFLAGS  =  $(GAP_LDFLAGS) -module -avoid-version

digraphs_la_LIBADD = @PLANARITY_SUITE_DIR@/libplanarity.la

if SYS_IS_CYGWIN
digraphs_la_LDFLAGS += -no-undefined -version-info 0:0:0 -Wl,$(GAPROOT)/bin/$(GAPARCH)/gap.dll
endif

all-local: digraphs.la
	$(mkdir_p) $(top_srcdir)/$(BINARCHDIR) $(top_srcdir)/bin/lib
	cp -RL @PLANARITY_SUITE_DIR@/.libs/*  $(top_srcdir)/bin/lib/
if SYS_IS_CYGWIN
	cp .libs/digraphs.dll $(GAPINSTALLLIB)/digraphs.so
	cp bin/lib/cygplanarity-0.dll $(GAPROOT)/.libs
else
	cp .libs/digraphs.so $(GAPINSTALLLIB)/
endif
if KERNEL_DEBUG
	@echo "SUCCESS (debug mode enabled)!"
else
	@echo "SUCCESS!"
endif

clean-local:
	find . -name '*.gcda' -delete

distclean-local:
	rm -f *.tmp
	rm -f coverage.info
	rm -rf coverage/*
	rm -rf bin/*

doc: doc/manual.six

doc/manual.six: doc/*.xml PackageInfo.g
	($(GAPROOT)/bin/gap.sh -A makedoc.g)

gaplint:
	gaplint *.g gap/*
	gaplint doc/*.xml
	gaplint tst/testinstall.tst tst/standard/*.tst tst/extreme/*.tst tst/workspaces/*.tst

cpplint:
	cpplint src/*.[ch]

lint: gaplint cpplint

format:
	clang-format -i src/*.[hc]

.PHONY: debug, lint, format

superclean: distclean
	git clean -xdf --exclude *.swp --exclude *.swo
.PHONY: superclean
