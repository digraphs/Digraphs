AC_INIT([planarity],[3.0.1.0],[jboyer@acm.org])
AM_INIT_AUTOMAKE([subdir-objects] [foreign])
AC_CONFIG_MACRO_DIRS([m4])
AC_CONFIG_SRCDIR([c/])

# The version of the libtool library is of the form current:revision:age
#
# See http://www.gnu.org/software/libtool/manual/html_node/Updating-version-info.html
#
# When doing a release, they should be updated like this:
# 1. If no interfaces changed, only implementations: just increment
# revision.
# 2. If interfaces were added, none removed: increment current, set
# revision to zero and increment age.
# 3. If interfaces were removed (breaks backward compatibility): increment
# current, and set both revision and age to zero.
LT_CURRENT=0
LT_REVISION=1
LT_AGE=0
AC_SUBST(LT_CURRENT)
AC_SUBST(LT_REVISION)
AC_SUBST(LT_AGE)

AC_PROG_CC
AC_PROG_INSTALL
LT_INIT

AC_CHECK_HEADERS([ctype.h stdio.h stdlib.h string.h time.h unistd.h])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
