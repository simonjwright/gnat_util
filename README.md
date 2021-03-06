With GNAT GPL 2013, AdaCore have extracted internal compiler
components into a library called gnat_util, which is used by (at
least) ASIS and GNATColl.

GNAT Util GPL 2013 contains components from the GNAT GPL 2013
compiler.

At least for ASIS, the components used to build it must match the
components in the compiler, so if building ASIS for use with (for
example) FSF GCC 4.8.1 a version of GNAT Util is needed which contains
components from FSF GCC 4.8.1.

This project provides such a library.

The code is released under GPL V3.0 without any Runtime Exception,
because the compiler components are themselves pure GPL.

If you've just built the compiler, it'd be normal to build the tools
to live with the compiler (that way you can have different versions of
the compiler on your system and switch between them by changing the
PATH).

The order of building the tools is important.

1. Install the new compiler and set your `PATH` so that its `bin/`
   directory is first: e.g., `PATH=/opt/gcc-4.8.1/bin:$PATH`

1. XML/Ada; build and install.

1. GPRBuild; build and install.

1. If you're on Darwin, rebuild XML/Ada using the new gprbuild (`make
   clean; make gprbuild`) and reinstall. This is so that the
   relocatable libraries are correctly built.

1. AUnit; build and install.

1. This library; edit the Makefile, build and install. The Makefile
   contains two variable definitions (`GCC_SRC_BASE` and
   `GCC_BLD_BASE`) which must be set to match the just-built
   compiler's source and build directories respectively.

1. GNATColl; build and install.

1. ASIS; build (make all tools) and install (`make install
   install-tools`).
