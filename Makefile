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

# THESE TWO VARIABLES NEED TO BE CONFIGURED!
GCC_SRC_BASE ?= $(HOME)/tmp/gcc-4.8.0
GCC_BLD_BASE ?= $(HOME)/tmp/gcc-build

GNATMAKE ?= gnatmake

all: lib-static-stamp
# Not going to build the relocatable library by default: there might
# be problems on Linux, and anyway all the tools are built
# statically. This does mean that GNATColl needs to be configured with
# --disable-shared.

lib-static-stamp: src-stamp gnat_util.gpr
ifeq ($(GNATMAKE),gnatmake)
	[ -d .build-static ] || mkdir .build-static
	cd src;							\
	for c in *.c; do					\
	  gcc -c -O2 $$c -o ../.build-static/`basename $$c .c`.o;	\
	done
endif
	$(GNATMAKE) -p -P gnat_util.gpr -XLIBRARY_TYPE=static
	touch lib-static-stamp

lib-relocatable-stamp: src-stamp gnat_util.gpr
ifeq ($(GNATMAKE),gnatmake)
	[ -d .build-relocatable ] || mkdir .build-relocatable
	cd src;								     \
	for c in *.c; do						     \
	  gcc -c -O2 -fPIC $$c -o ../.build-relocatable/`basename $$c .c`.o; \
	done
endif
	$(GNATMAKE) -p -P gnat_util.gpr -XLIBRARY_TYPE=relocatable
	touch lib-relocatable-stamp

src-stamp: compiler_files
	[ -d src ] || mkdir src
	for s in `cat compiler_files`; do			\
	    if   [ -f $(GCC_BLD_BASE)/gcc/ada/$$s ]; then	\
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
	  --prefix=$(prefix)			\
	  --mode=dev				\
	  --project-subdir=lib/gnat		\
	  -f					\
	  -p

clean:
	gnatclean -P gnat_util.gpr
	rm -rf src .build-* lib
	rm *-stamp
