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
digraphs_la_SOURCES += src/bliss-0.73/defs.cc src/bliss-0.73/graph.cc 
digraphs_la_SOURCES += src/bliss-0.73/partition.cc src/bliss-0.73/orbit.cc
digraphs_la_SOURCES += src/bliss-0.73/uintseqhash.cc src/bliss-0.73/heap.cc
digraphs_la_SOURCES += src/bliss-0.73/timer.cc src/bliss-0.73/utils.cc 
digraphs_la_SOURCES += src/bliss-0.73/bliss_C.cc
digraphs_la_CXXFLAGS = -O3 -DNDEBUG -march=native -mpopcnt
digraphs_la_CFLAGS = -O3 -DNDEBUG -march=native -mpopcnt

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

debug: CFLAGS = -g3 -O0 -Wall -Wextra -Wpedantic -Wno-unused-parameter -Wtype-limits -Wformat-security -Wpointer-arith -Wno-div-by-zero -Wreturn-type -Wswitch -Wsizeof-array-argument -Wunused-label -fno-omit-frame-pointer -fno-omit-frame-pointer -Wno-c++11-extensions -UNDEBUG -DDEBUG
debug: clean all

gaplint: 
	gaplint *.g gap/* 
	gaplint doc/*.xml 
	gaplint tst/testinstall.tst tst/standard/*.tst tst/extreme/*.tst tst/workspaces/*.tst

cpplint:
	cpplint src/*.h src/*.c

lint: gaplint cpplint

format: 
	clang-format -i src/*.h src/*.c

.PHONY: debug, lint, format
