# Find the location of GAP
# Sets GAPROOT, GAPARCH and GAP_CPPFLAGS appropriately
# Can be configured using --with-gaproot=...
#######################################################################

AC_DEFUN([AC_FIND_GAP],
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

  #Allow the user to specify the location of GAP
  #
  AC_ARG_WITH(gaproot,
    [AC_HELP_STRING([--with-gaproot=<path>], [specify root of GAP installation])],
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


  AC_MSG_CHECKING([for GAP >= 4.9])
  # test if this GAP >= 4.9
  if test "x$GAP_CPPFLAGS" != x; then
    AC_MSG_RESULT([yes])
  else
    AC_MSG_RESULT([no])
    #####################################
    # Now check for the GAP header files

    bad=0
    AC_MSG_CHECKING([for GAP include files])
    if test -r $GAPROOT/src/compiled.h; then
      AC_MSG_RESULT([$GAPROOT/src/compiled.h])
    else
      AC_MSG_RESULT([Not found])
      bad=1
    fi
    AC_MSG_CHECKING([for GAP config.h])
    if test -r $GAPROOT/bin/$GAPARCH/config.h; then
      AC_MSG_RESULT([$GAPROOT/bin/$GAPARCH/config.h])
    else
      AC_MSG_RESULT([Not found])
      bad=1
    fi

    if test "x$bad" = "x1"; then
      echo ""
      echo "********************************************************************"
      echo "  ERROR"
      echo ""
      echo "  Failed to find the GAP source header files in src/ and"
      echo "  GAP's config.h in the architecture dependend directory"
      echo ""
      echo "  The kernel build process expects to find the normal GAP "
      echo "  root directory structure as it is after building GAP itself, and"
      echo "  in particular the files"
      echo "      <gaproot>/sysinfo.gap"
      echo "      <gaproot>/src/<includes>"
      echo "  and <gaproot>/bin/<architecture>/bin/config.h."
      echo "  Please make sure that your GAP root directory structure"
      echo "  conforms to this layout, or give the correct GAP root using"
      echo "  --with-gaproot=<path>"
      echo "********************************************************************"
      echo ""
      AC_MSG_ERROR([Unable to find GAP include files in /src subdirectory])
    fi

    ARCHPATH=$GAPROOT/bin/$GAPARCH
    GAP_CPPFLAGS="-I$GAPROOT -iquote $GAPROOT/src -I$ARCHPATH"

    AC_MSG_CHECKING([for GAP's gmp.h location])
    if test -r "$ARCHPATH/extern/gmp/include/gmp.h"; then
      GAP_CPPFLAGS="$GAP_CPPFLAGS -I$ARCHPATH/extern/gmp/include"
      AC_MSG_RESULT([$ARCHPATH/extern/gmp/include/gmp.h])
    else
      AC_MSG_RESULT([not found, GAP was compiled without its own GMP])
    fi
  fi

  AC_SUBST(GAPARCH)
  AC_SUBST(GAPROOT)
  AC_SUBST(GAP_CPPFLAGS)
  AC_SUBST(GAP_CFLAGS)
  AC_SUBST(GAP_LDFLAGS)
  AC_SUBST(GAP_LIBS)

  AC_LANG_POP([C])
])
