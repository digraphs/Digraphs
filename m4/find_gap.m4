# Find the location of GAP
# Sets GAPROOT, GAPARCH and GAP_CPPFLAGS appropriately
# Can be configured using --with-gaproot=...
#######################################################################

AC_DEFUN([FIND_GAP],
[
  AC_LANG_PUSH([C])

  # Make sure CDPATH is portably set to a sensible value
  CDPATH=${ZSH_VERSION+.}:

  GAP_CPPFLAGS=""

  ######################################
  # Find the GAP root directory by
  # checking for the sysinfo.gap file
  AC_MSG_CHECKING([for GAP root directory])
  GAPROOT="../.."

  # Allow the user to specify the location of GAP
  AC_ARG_WITH(gaproot,
    [AS_HELP_STRING([--with-gaproot=<path>], [specify root of GAP installation])],
    [GAPROOT="$withval"])

  # Convert the path to absolute
  GAPROOT=`cd $GAPROOT > /dev/null 2>&1 && pwd`

  if test -e ${GAPROOT}/sysinfo.gap; then
    AC_MSG_RESULT([${GAPROOT}])
  else
    AC_MSG_RESULT([Not found])

    echo ""
    echo "********************************************************************"
    echo "  ERROR"
    echo ""
    echo "  Cannot find your GAP installation. Please specify the location of"
    echo "  GAP's root directory using --with-gaproot=<path>"
    echo ""
    echo "  The GAP root directory (as far as this package is concerned) is"
    echo "  the one containing the file sysinfo.gap"
    echo "********************************************************************"
    echo ""

    AC_MSG_ERROR([Unable to find GAP root directory])
  fi

  #####################################
  # Now find the architecture

  AC_MSG_CHECKING([for GAP architecture])
  GAPARCH="Unknown"
  . $GAPROOT/sysinfo.gap
  if test "x$GAParch" != "x"; then
    GAPARCH=$GAParch
  fi

  if test "x$GAPARCH" = "xUnknown" ; then
    echo ""
    echo "********************************************************************"
    echo "  ERROR"
    echo ""
    echo "  Found a GAP installation at $GAPROOT but could not find"
    echo "  information about GAP's architecture in the file"
    echo "    ${GAPROOT}/sysinfo.gap ."
    echo "  This file should be present: please check your GAP installation."
    echo "********************************************************************"
    echo ""

    AC_MSG_ERROR([Unable to find plausible GAParch information.])
  fi

  # require GAP >= 4.9
  if test "x$GAP_CPPFLAGS" = x; then
    echo ""
    echo "********************************************************************"
    echo "  ERROR"
    echo ""
    echo "  This version of GAP is too old and not supported by this package."
    echo "********************************************************************"
    echo ""
    AC_MSG_ERROR([No GAP_CPPFLAGS is given])
  fi

  AC_SUBST(GAPARCH)
  AC_SUBST(GAPROOT)
  AC_SUBST(GAP_CPPFLAGS)
  AC_SUBST(GAP_CFLAGS)
  AC_SUBST(GAP_LDFLAGS)
  AC_SUBST(GAP_LIBS)

  AC_LANG_POP([C])
])
