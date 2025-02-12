#
# digraphs
#
# This file is part of the build system of a GAP kernel extension.
# Requires GNU autoconf, GNU automake and GNU libtool.
#

dnl ##
dnl ## Setup autoconf
dnl ##
AC_PREREQ([2.68])
AC_INIT([digraphs], [GAP package])
AC_CONFIG_SRCDIR([src/digraphs.c])
AC_CONFIG_HEADERS([gen/pkgconfig.h:src/pkgconfig.h.in])
AC_CONFIG_MACRO_DIR([m4])

AX_PREFIX_CONFIG_H([src/digraphs-config.h],[digraphs],[gen/pkgconfig.h])

AC_PREFIX_DEFAULT('${abs_top_builddir}/../../bin/')

dnl ##
dnl ## Set the language
dnl ##
AC_PROG_CC
AC_PROG_CXX
AC_LANG([C++])

dnl ##
dnl ## Locate the GAP root dir
dnl ##
FIND_GAP

dnl ## User setting: Debug mode (off by default)
AC_ARG_ENABLE([debug],
    [AS_HELP_STRING([--enable-debug], [enable debug mode])],
    [AC_DEFINE([KERNEL_DEBUG], [1], [define if building in debug mode])],
    [enable_debug=no]
    )
AC_MSG_CHECKING([whether to enable debug mode])
AC_MSG_RESULT([$enable_debug])
KERNEL_DEBUG=$enable_debug
AC_SUBST(KERNEL_DEBUG)

AC_ARG_ENABLE([stats],
    [AS_HELP_STRING([--enable-stats], [enable stats mode])],
    [AC_DEFINE([ENABLE_STATS], [1], [define if building in stats mode])],
    [enable_stats=no]
    )
AC_MSG_CHECKING([whether to enable stats mode])
AC_MSG_RESULT([$enable_stats])
ENABLE_STATS=$enable_debug
AC_SUBST(ENABLE_STATS)

AC_ARG_ENABLE([code-coverage],
  AS_HELP_STRING([--enable-code-coverage],
  [Whether to enable code coverage support]),,
  enable_code_coverage=no)
AC_MSG_CHECKING([whether to build with code coverage support])
AC_MSG_RESULT($enable_code_coverage)

AS_IF([ test "$enable_code_coverage" = "yes" ], [
    CODE_COVERAGE_CFLAGS="-DNDEBUG -O0 -g --coverage"
    CODE_COVERAGE_CXXFLAGS="-DNDEBUG -O0 -g --coverage"
    CODE_COVERAGE_LDFLAGS="--coverage"
    AC_SUBST([CODE_COVERAGE_CFLAGS])
    AC_SUBST([CODE_COVERAGE_CXXFLAGS])
    AC_SUBST([CODE_COVERAGE_LDFLAGS])
])


# Enable compiler warnings

AC_ARG_ENABLE([compile-warnings],
    [AS_HELP_STRING([--enable-compile-warnings], [enable compiler warnings])],
    [enable_compile_warnings=yes],
    [enable_compile_warnings=no])
AC_MSG_CHECKING([whether enable compiler warnings])
AC_MSG_RESULT([$enable_compile_warnings])

AS_IF([test "x$enable_compile_warnings" != "xno"],
  [ax_enable_compile_warnings=yes
   AX_COMPILER_FLAGS_CXXFLAGS([WARNING_CXXFLAGS], [], [ dnl
       -pedantic dnl
       -Wold-style-cast])
   AC_SUBST([WARNING_CXXFLAGS])])

AS_IF([test "x$enable_compile_warnings" != "xno"],
  [ax_enable_compile_warnings=yes
   AX_COMPILER_FLAGS_CFLAGS([WARNING_CFLAGS], [], [ dnl
       -pedantic dnl])
   AC_SUBST([WARNING_CFLAGS])])

# Check for system planarity suite

AX_CHECK_PLANARITY
if test "x$with_external_planarity" = xno ; then
  PLANARITY_SUITE_DIR=extern/edge-addition-planarity-suite-Version_3.0.1.0
  AC_SUBST(PLANARITY_SUITE_DIR)
fi

# Check for system bliss suite
AX_CHECK_BLISS

# Check whether to use -mpopcnt and __builtin_ctzl
AC_ARG_WITH([intrinsics],
            [AS_HELP_STRING([--without-intrinsics],
                            [do not use compiler intrinsics even if available])]
           )

AS_IF([test "x$with_intrinsics" = "xno" ],
      [AC_MSG_NOTICE([compiler intrinsics will not be used even if available])])

dnl compiler builtins
AC_DEFUN([CHECK_COMPILER_BUILTIN],
[AC_MSG_CHECKING([for $1])
    AC_LINK_IFELSE(
        [AC_LANG_PROGRAM(
            [[]],
            [$1[($2)];
            ]
        )],
        [AS_VAR_SET([[have_]$1], [yes])],
        [AS_VAR_SET([[have_]$1], [no])]
        )
    AC_MSG_RESULT(AS_VAR_GET([[have_]$1]))
    AS_IF([test yes = AS_VAR_GET([[have_]$1])],
        [AC_DEFINE_UNQUOTED(AS_TR_CPP([HAVE_]$1), 1,
            [Define to 1 if the system has the `]$1[' built-in function])], []
        )])

AS_IF([test "x$with_intrinsics" != "xno"],
      [CHECK_COMPILER_BUILTIN([__builtin_ctzll],[0])])

dnl ##
dnl ## Output everything
dnl ##
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
