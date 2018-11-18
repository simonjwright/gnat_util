# Copyright Simon Wright <simon@pushface.org>

# This file is part of the version of GNAT_Util created at Sourceforge
# by Simon Wright and intended to allow the building of tools provided
# by AdaCore in their GPL distributions.

# GNAT_Util is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.

# GNAT_Util is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with GNAT_Util; see the file COPYING3.  If not see
# <http://www.gnu.org/licenses/>.

# THESE VARIABLES NEED TO BE CONFIGURED!
BASE ?= $(HOME)
RELEASE ?= 8.1.0
GCC_SRC_BASE ?= $(BASE)/tmp/gcc-$(RELEASE)
GCC_BLD_BASE ?= $(BASE)/tmp/gcc-$(RELEASE)-build

GPRBUILD ?= gprbuild
GPRBUILD_OPTIONS ?=
BUILDER =$(GPRBUILD) $(GPRBUILD_OPTIONS)
GPRCLEAN ?= gprclean

all: lib-static-stamp lib-relocatable-stamp

lib-static-stamp: src-stamp gnat_util.gpr
	$(BUILDER) -p -P gnat_util.gpr -XLIBRARY_TYPE=static
	touch lib-static-stamp

lib-relocatable-stamp: src-stamp gnat_util.gpr
	$(BUILDER) -p -P gnat_util.gpr -XLIBRARY_TYPE=relocatable
	touch lib-relocatable-stamp

# Some of the sources are platform-specific; for example, the body of
# mlib-tgt-specific.ads for Darwin is found in the source tree as
# mlib-tgt-specific-darwin.adb. These sources are copied to the build
# tree with the expected name, in
#
# o gcc/ada/bldtools (used for generating some compiler sources, not
#   needed),
# o gcc/ada/rts (actually the complete RTS; we don't need any of
#   these, since this library is used by an already-installed
#   compiler),
# o gcc/ada/tools, and
# o gcc/ada.
#
# Other sources come from the source tree.
src-stamp: compiler_files
	[ -d src ] || mkdir src
	for s in `cat compiler_files`; do			\
	    if   [ -f $(GCC_BLD_BASE)/gcc/ada/tools/$$s ]; then	\
	        cp -p $(GCC_BLD_BASE)/gcc/ada/tools/$$s src/;	\
	    elif [ -f $(GCC_BLD_BASE)/gcc/ada/$$s ]; then	\
	        cp -p $(GCC_BLD_BASE)/gcc/ada/$$s src/;		\
	    elif [ -f $(GCC_SRC_BASE)/gcc/ada/$$s ]; then	\
	        cp -p $(GCC_SRC_BASE)/gcc/ada/$$s src/;		\
	    else						\
	        echo "couldn't find $$s";			\
	    fi							\
	done
	printf "char version_string[] = \"%s\";\n" `gcc -dumpversion` \
	  > src/version.c
	cp prefix.c src/
	touch src-stamp

prefix ?= $(realpath $(dir $(shell which gnatls))/..)

install: all
	gprinstall				\
	  -P gnat_util.gpr			\
	  --install-name=gnat_util		\
	  --prefix=$(prefix)			\
	  --mode=dev				\
	  --project-subdir=lib/gnat		\
	  --build-var=LIBRARY_TYPE		\
	  --build-name=static			\
	  -XLIBRARY_TYPE=static			\
	  -f					\
	  -p
	gprinstall				\
	  -P gnat_util.gpr			\
	  --install-name=gnat_util		\
	  --prefix=$(prefix)			\
	  --mode=dev				\
	  --project-subdir=lib/gnat		\
	  --build-var=LIBRARY_TYPE		\
	  --build-name=relocatable		\
	  -XLIBRARY_TYPE=relocatable		\
	  -f					\
	  -p

clean:
	-$(GPRCLEAN) -P gnat_util.gpr -XLIBRARY_TYPE=static
	-$(GPRCLEAN) -P gnat_util.gpr -XLIBRARY_TYPE=relocatable
	rm -rf src .build-* lib
	rm *-stamp

# Distribution construction.

# Create the current date, in the form yyyymmdd.
RELEASE ?= $(shell date +%Y%m%d)

# Files to copy to the distribution
FILES = COPYING3 README Makefile compiler_files gnat_util.gpr prefix.c

# Distribution directory - eg gnat_util-20130705
DISTDIR = gnat_util-$(RELEASE)

dist: $(DISTDIR).tar.gz

$(DISTDIR).tar.gz: $(DISTDIR)
	tar zcvf $@ $<

$(DISTDIR):
	-rm -rf $@
	mkdir $@
	cp $(FILES) $@/

.PHONY: all clean dist install $(DISTDIR)
