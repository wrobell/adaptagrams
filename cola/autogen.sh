#!/bin/sh -x
#
# We use gnu automake to build.  I've tried to make the contents of the
# repository as platform agnostic as possible, so you'll need to call
# aclocal, autoconf, and automake before configure.
#
# The following sequence builds from scratch:
aclocal $ACLOCAL_FLAGS
#libtoolize
autoheader
autoconf
automake -a --add-missing
# Configure.  Use the commented out line instead if building for SWIG:
# ./configure CPPFLAGS="-DUSE_ASSERT_EXCEPTIONS"
./configure
make
# The following builds examples and tests for each of the libraries.
# Please look at these before sending me questions.
make check

