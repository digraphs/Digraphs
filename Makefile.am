#
# digraphs: 
#
# This file is part of the build system of a GAP kernel extension.
# Requires automake.
#
ACLOCAL_AMFLAGS = -I m4

BINARCHDIR = bin/$(GAPARCH)
GAPINSTALLLIB = $(abs_top_srcdir)/$(BINARCHDIR)/digraphs.so

lib_LTLIBRARIES = digraphs.la

digraphs_la_SOURCES = src/digraphs.c src/homos.c src/perms.c src/schreier-sims.c
digraphs_la_SOURCES += src/bliss-0.73/defs.cc src/bliss-0.73/graph.cc src/bliss-0.73/partition.cc
digraphs_la_SOURCES += src/bliss-0.73/orbit.cc src/bliss-0.73/uintseqhash.cc src/bliss-0.73/heap.cc
digraphs_la_SOURCES += src/bliss-0.73/timer.cc src/bliss-0.73/utils.cc src/bliss-0.73/bliss_C.cc
digraphs_la_CXXFLAGS = -O3
digraphs_la_CFLAGS = -O3

digraphs_la_CPPFLAGS = $(GAP_CPPFLAGS) -DCONFIG_H
# Note that the latter is only for GAP 4.4.12
digraphs_la_LDFLAGS = -module -avoid-version
if SYS_IS_CYGWIN
digraphs_la_LDFLAGS += -no-undefined -version-info 0:0:0 -Wl,$(GAPROOT)/bin/$(GAPARCH)/gap.dll
endif

all-local: digraphs.la
	$(mkdir_p) $(top_srcdir)/$(BINARCHDIR)
if SYS_IS_CYGWIN
	cp .libs/digraphs.dll $(GAPINSTALLLIB)
else
	cp .libs/digraphs.so $(GAPINSTALLLIB)
endif
	@echo "SUCCESS!"

distclean-local:
	rm -rf bin/*
	(cd doc ; ./clean)

doc: doc/manual.six

doc/manual.six: doc/*.xml PackageInfo.g
	($(GAPROOT)/bin/gap.sh -A makedoc.g)
