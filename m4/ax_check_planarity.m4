dnl handle planarity checks
dnl
dnl if --with-external-planarity is supplied,
dnl use it if it is known to pkg-config and is new enough;
dnl otherwise use the included version
dnl
AC_DEFUN([AX_CHECK_PLANARITY], [
  AC_ARG_WITH([external-planarity],
	      [AS_HELP_STRING([--with-external-planarity],
			      [use external planarity])],
              [],
              [with_external_planarity=no])
  AC_MSG_CHECKING([whether to use external planarity])
  AC_MSG_RESULT([$with_external_planarity])
  if test "x$with_external_planarity" = xyes ; then
        AC_LANG_PUSH([C])
        AC_CHECK_LIB([planarity], 
                     [gp_InitGraph], 
                     [],
                     [AC_MSG_ERROR([no external libplanarity found])])

        AC_CHECK_HEADER([planarity/graph.h], 
                        [], 
                        [AC_MSG_ERROR([no external planarity headers found])])
        AC_LANG_POP()
  fi
  if test "x$with_external_planarity" = xno ; then
    WITH_INCLUDED_PLANARITY=yes
    AC_SUBST(WITH_INCLUDED_PLANARITY)
    AC_DEFINE([WITH_INCLUDED_PLANARITY], 
              [1], 
              [define that we should use the vendored planarity])
  fi
])
