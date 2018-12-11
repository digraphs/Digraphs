#
# digraphs: 
#
# This file is part of the build system of a GAP kernel extension.
# Requires automake.
#

ACLOCAL_AMFLAGS = -I m4

SUBDIRS = @PLANARITY_SUITE_DIR@

PLANAR_INCLUDE = -I@PLANARITY_SUITE_DIR@/

BINARCHDIR = bin/$(GAPARCH)
GAPINSTALLLIB = $(abs_top_srcdir)/$(BINARCHDIR)/

lib_LTLIBRARIES = digraphs.la

digraphs_la_SOURCES = src/digraphs.c 
digraphs_la_SOURCES += src/homos.c 
digraphs_la_SOURCES += src/perms.c 
digraphs_la_SOURCES += src/planar.c
digraphs_la_SOURCES += src/schreier-sims.c
digraphs_la_SOURCES += src/bliss-0.73/defs.cc 
digraphs_la_SOURCES += src/bliss-0.73/graph.cc 
digraphs_la_SOURCES += src/bliss-0.73/partition.cc 
digraphs_la_SOURCES += src/bliss-0.73/orbit.cc
digraphs_la_SOURCES += src/bliss-0.73/uintseqhash.cc 
digraphs_la_SOURCES += src/bliss-0.73/heap.cc
digraphs_la_SOURCES += src/bliss-0.73/timer.cc 
digraphs_la_SOURCES += src/bliss-0.73/utils.cc 
digraphs_la_SOURCES += src/bliss-0.73/bliss_C.cc

digraphs_la_CPPFLAGS = $(GAP_CPPFLAGS) 
digraphs_la_CXXFLAGS = -O3 -march=native -mpopcnt $(PLANAR_INCLUDE)
digraphs_la_CFLAGS = -O3 -march=native -mpopcnt $(GAP_CFLAGS) $(PLANAR_INCLUDE)
digraphs_la_LDFLAGS = $(GAP_LDFLAGS) -module -avoid-version

digraphs_la_LIBADD = @PLANARITY_SUITE_DIR@/libplanarity.la

if SYS_IS_CYGWIN
digraphs_la_LDFLAGS += -no-undefined -version-info 0:0:0 -Wl,$(GAPROOT)/bin/$(GAPARCH)/gap.dll
endif

all-local: digraphs.la
	$(mkdir_p) $(top_srcdir)/$(BINARCHDIR) $(top_srcdir)/bin/lib
	cp -RL @PLANARITY_SUITE_DIR@/.libs/*  $(top_srcdir)/bin/lib/
if SYS_IS_CYGWIN
	cp .libs/digraphs.dll $(GAPINSTALLLIB)
else
	cp .libs/digraphs.so $(GAPINSTALLLIB)
endif
if KERNEL_DEBUG
	@echo "SUCCESS (debug mode enabled)!"
else
	@echo "SUCCESS!"
endif

distclean-local:
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
