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
  AS_IF([test "x$with_external_planarity" = xyes], [
        AC_MSG_CHECKING([for external libplanarity])
        saved_LIBS="$LIBS"
        LIBS="$LIBS -lplanarity"
        AC_LANG_PUSH([C])
        AC_LINK_IFELSE([AC_LANG_SOURCE([
          #include <planarity/c/graphLib/graphLib.h>
          #if defined(GP_PROJECTVERSION_MAJOR) && GP_PROJECTVERSION_MAJOR >= 4
          #else
          #error too old
          #endif
          int main(void) { gp_InitGraph(0, 0); }
        ])], [
          AC_MSG_RESULT([yes])
        ], [
          AC_MSG_RESULT([not found or too old])
          LIBS="$saved_LIBS"
          with_external_planarity=no
        ])
        AC_LANG_POP()
  ])
  AS_IF([test "x$with_external_planarity" = xno], [
    WITH_INCLUDED_PLANARITY=yes
    AC_SUBST(WITH_INCLUDED_PLANARITY)
    AC_DEFINE([WITH_INCLUDED_PLANARITY], 
              [1], 
              [define that we should use the vendored planarity])
  ])
])
