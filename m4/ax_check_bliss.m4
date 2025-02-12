dnl handle bliss checks
dnl
dnl if --with-external-bliss is supplied,
dnl use it if it is known to pkg-config and is new enough;
dnl otherwise use the included version
dnl
AC_DEFUN([AX_CHECK_BLISS], [
  AC_ARG_WITH([external-bliss],
	      [AS_HELP_STRING([--with-external-bliss],
			      [use external bliss])],
              [],
              [with_external_bliss=no])
  AC_MSG_CHECKING([whether to use external bliss])
  AC_MSG_RESULT([$with_external_bliss])
  if test "x$with_external_bliss" = xyes ; then
        AC_LANG_PUSH([C])
        AC_CHECK_LIB([bliss],
                     [bliss_add_edge],
                     [],
                     [AC_MSG_ERROR([no external libbliss found])])

        AC_CHECK_HEADER([bliss/bliss_C.h],
                        [],
                        [AC_MSG_ERROR([no external bliss headers found])])
        AC_LANG_POP()
  fi
  if test "x$with_external_bliss" = xno ; then
    WITH_INCLUDED_BLISS=yes
    AC_SUBST(WITH_INCLUDED_BLISS)
    AC_DEFINE([WITH_INCLUDED_BLISS],
              [1],
              [define that we should use the vendored bliss])
  fi
])
