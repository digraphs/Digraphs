ACLOCAL_AMFLAGS = -I m4

BINARCHDIR = bin/$(GAPARCH)
GAPINSTALLLIB = $(abs_top_srcdir)/$(BINARCHDIR)/digraphs.so

lib_LTLIBRARIES = digraphs.la

digraphs_la_SOURCES = src/digraphs.c
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

