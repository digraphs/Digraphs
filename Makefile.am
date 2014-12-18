#
# graphs: 
#
# This file is part of the build system of a GAP kernel extension.
# Requires automake.
#
ACLOCAL_AMFLAGS = -I m4

BINARCHDIR = bin/$(GAPARCH)
GAPINSTALLLIB = $(abs_top_srcdir)/$(BINARCHDIR)/graphs.so

lib_LTLIBRARIES = graphs.la

graphs_la_SOURCES = src/graphs.c src/homos.c src/perms.c src/schreier-sims.c
graphs_la_SOURCES += src/bliss-0.72/defs.cc src/bliss-0.72/graph.cc src/bliss-0.72/partition.cc
graphs_la_SOURCES += src/bliss-0.72/orbit.cc src/bliss-0.72/uintseqhash.cc src/bliss-0.72/heap.cc
graphs_la_SOURCES += src/bliss-0.72/timer.cc src/bliss-0.72/utils.cc src/bliss-0.72/bliss_C.cc

graphs_la_CPPFLAGS = $(GAP_CPPFLAGS) -DCONFIG_H
# Note that the latter is only for GAP 4.4.12
graphs_la_LDFLAGS = -module -avoid-version
if SYS_IS_CYGWIN
graphs_la_LDFLAGS += -no-undefined -version-info 0:0:0 -Wl,$(GAPROOT)/bin/$(GAPARCH)/gap.dll
endif

all-local: graphs.la
	$(mkdir_p) $(top_srcdir)/$(BINARCHDIR)
if SYS_IS_CYGWIN
	cp .libs/graphs.dll $(GAPINSTALLLIB)
else
	cp .libs/graphs.so $(GAPINSTALLLIB)
endif
	@echo "SUCCESS!"

distclean-local:
	rm -rf bin/*
	(cd doc ; ./clean)

doc: doc/manual.six

doc/manual.six: doc/*.xml PackageInfo.g
	($(GAPROOT)/bin/gap.sh -A makedoc.g)
