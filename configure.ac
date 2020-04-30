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
AC_INIT([digraphs], m4_esyscmd([tr -d '\n' < .VERSION]))
AC_CONFIG_SRCDIR([src/digraphs.c])
AC_CONFIG_HEADER([src/_pkgconfig.h:cnf/pkgconfig.h.in])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_AUX_DIR([cnf])

dnl ##
dnl ## Get canonical host info
dnl ##
AC_CANONICAL_HOST

dnl ##
dnl ## Setup automake
dnl ##
AM_INIT_AUTOMAKE([1.11 -Wall foreign subdir-objects])
AM_SILENT_RULES([yes])
AM_PROG_AR

AX_PREFIX_CONFIG_H([src/digraphs-config.h],[],[src/_pkgconfig.h])

AC_PREFIX_DEFAULT('${abs_top_builddir}/../../bin/')

dnl ##
dnl ## Set the language
dnl ##
AC_PROG_CC_C99
AC_PROG_CXX
AC_LANG([C++])

dnl ##
dnl ## Setup libtool (for building the GAP kernel extension)
dnl ##
LT_PREREQ([2.4.2])
LT_INIT([disable-static dlopen win32-dll])

dnl ##
dnl ## Locate the GAP root dir
dnl ##
FIND_GAP

dnl ##
dnl ## Detect Windows resp. Cygwin
dnl ##
case $host_os in
  *cygwin* ) CYGWIN=yes;;
         * ) CYGWIN=no;;
esac
AM_CONDITIONAL([SYS_IS_CYGWIN], [test "$CYGWIN" = "yes"])
if test "$CYGWIN" = "yes"; then
  AC_DEFINE(SYS_IS_CYGWIN32, 1, are we on CYGWIN?)
else
  AC_DEFINE(SYS_IS_CYGWIN32, 0, are we on CYGWIN?)
fi

dnl ## User setting: Debug mode (off by default)
AC_ARG_ENABLE([debug],
    [AS_HELP_STRING([--enable-debug], [enable debug mode])],
    [AC_DEFINE([KERNEL_DEBUG], [1], [define if building in debug mode])],
    [enable_debug=no]
    )
AC_MSG_CHECKING([whether to enable debug mode])
AC_MSG_RESULT([$enable_debug])

AM_CONDITIONAL([KERNEL_DEBUG], [test "x$enable_debug" = xyes])

AC_ARG_ENABLE([stats],
    [AS_HELP_STRING([--enable-stats], [enable stats mode])],
    [AC_DEFINE([ENABLE_STATS], [1], [define if building in stats mode])],
    [enable_stats=no]
    )
AC_MSG_CHECKING([whether to enable stats mode])
AC_MSG_RESULT([$enable_stats])

AM_CONDITIONAL([ENABLE_STATS], [test "x$enable_stats" = xyes])

AX_CODE_COVERAGE()

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
       -pedantic dnl
       -Wold-style-cast])
   AC_SUBST([WARNING_CFLAGS])])

# Check for system planarity suite

AX_CHECK_PLANARITY()

if test "x$with_external_planarity" = xno ; then
  AC_CONFIG_SUBDIRS([extern/edge-addition-planarity-suite-Version_3.0.0.5])
  PLANARITY_SUITE_DIR=extern/edge-addition-planarity-suite-Version_3.0.0.5
  AC_SUBST(PLANARITY_SUITE_DIR)
fi

# Check for system bliss suite

AX_CHECK_BLISS()

# Check whether to use -march=native -mpopcnt and __builtin_ctzl
AC_ARG_WITH([intrinsics],
            [AS_HELP_STRING([--without-intrinsics], 
                            [do not use compiler intrinsics even if available])]
           )

AS_IF([test "x$with_intrinsics" == "xno" ],
      [AC_MSG_NOTICE([compiler intrinsics will not be used even if available])])

AS_IF([test "x$with_intrinsics" != "xno"],
      [AX_CHECK_COMPILE_FLAG(-march=native, AX_APPEND_FLAG(-march=native))
       AX_CHECK_COMPILE_FLAG(-mpopcnt, AX_APPEND_FLAG(-mpopcnt))
      ])

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
