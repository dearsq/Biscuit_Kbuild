$(warning Hello World)
VERSION = 4
PATCHLEVEL = 4
SUBLEVEL = 11
EXTRAVERSION =
NAME = Blurry Fish Butt

# *DOCUMENTATION*
# To see a list of typical targets execute "make help"
# More info can be located in ./README
# Comments in this file are target only to the developer, do not
# expect to learn how to build the kernel reading this file.

# o Do not use make's build-in rules and variables
#   (this increase performance and avoid hard-to-debug behaviour);
# o Look for make include files relative to root of kernel src
MAKEFLAGS += -rR --include-dir=$(CURDIR) 

# Output Debug Information
DEBUG_LEVEL :=0

ifeq ($(DEBUG_LEVEL), 8)
MAKEFLAGS += --warn-undefined-variables --print-data-base --just-print \
				--debug=all
endif
ifeq ($(DEBUG_LEVEL), 7)
MAKEFALGS += --debug=all
endif
ifeq ($(DEBUG_LEVEL), 6)
MAKEFALGS += --debug=jobs
endif
ifeq ($(DEBUG_LEVEL), 5)
MAKEFALGS += --debug=implicit
endif
ifeq ($(DEBUG_LEVEL), 4)
MAKEFALGS += --debug=verbose
endif
ifeq ($(DEBUG_LEVEL), 3)
MAKEFALGS += --debug=basic
endif
$(warning TOP_DEBUG MAKEFLAGS=$(MAKEFLAGS))


# Avoid funny character set dependencies
unexport LC_ALL
LC_COLLATE=C
LC_NUMERIC=C
export LC_COLLATE LC_NUMERIC

# Avoid interface with shell env setting
unexport GREP_OPTIONS

# We are using a recursive build, so we need to do a little thinking
# to get the ordering right.
#
# Most importantly: sub-Makefiles should only ever modify files in 
# their own directory. If in some directory we have a dependency on
# a file in another dir (which doesn't happen often, but it's often
# unavoidable when linking the built-in.o targets which finally
# turn into vmlinux), we will call a sub make in that other dir, and
# after that we are sure that everthing which is in that other dir
# is now up to date.
#
# The only cases where we need to modify files which have global
# effects are thus separated out and done before the recursive
# descending is started. They are now explicitly listed as the 
# prepare rule.

# Beautify output
# -------------------------------------------------------------------------
# 
# Normally, we echo the whole command before execting it. By making
# that echo $($(quiet)$(cmd)), we now have the possibility to set
# $(quiet) to choose other forms of output instead, e.g.
#
#		quiet_cmd_cc_o_c = Compilining $(RELDIR)/$@
#       cmd_cc_o_c       = $(CC) $(c_flags) -c -o $@ $<
#
# If $(quiet) is empty, the whole command will be printed.
# If it is set to "quiet_", only the short version will be printed.
# If it is set to "silent_", nothing will be printed at all, since
# the variable $(silent_cmd_cc_o_c) doesn't exist.
#
# A simple variant is to prefix commands with $(Q) - that's useful
# for commands that shall be hidden in non-verbose mode.
#
#	$(Q)ln $@ :<
#
# If KBUILD_VERBOSE equals 0 then the above command will be hidden.
# If KBUILD_VERBOSE equals 1 then the above command is displayed.
#
# To put more focus on warnings, be less verbose as default
# Use 'make V=1' to see the full commands

ifeq ("$(origin V)", "command line")
  KBUILD_VERBOSE = $(V)
endif
ifndef KBUILD_VERBOSE
  KBUILD_VERBOSE = 0
endif
$(warning TOP_DEBUG KBUILD_VERBOSE=$(KBUILD_VERBOSE))

ifeq ($(KBUILD_VERBOSE), 1)
  quiet = 
  Q =
else
  quiet=quiet_
  Q = @
endif
$(warning TOP_DEBUG Q=$(Q))
$(warning TOP_DEBUG quiet=$(quiet))

# If the user is running make -s (silent mode), suppress echoing of 
# commands

ifneq ($(filter 4.%,$(MAKE_VERSION)),) # make-4
ifneq ($(filter %s ,$(firstword x$(MAKEFLAGS))),)
  quiet=silent_
endif
else                     # make-3.8x
ifneq ($(filter s% -s%,$(MAKEFLAGS)),)
  quiet=silent_
endif
endif

$(warning TOP_DEBUG quiet=$(quiet))
$(warning TOP_DEBUG firstword xMAKEFLAGS=$(firstword x$(MAKEFLAGS)))
$(warning TOP_DEBUG MAKECMDGOALS=$(MAKECMDGOALS))
export quiet Q KBUILD_VERBOSE

# kbuild supports saving output files in a separate directory.
# To locate output files in a separate directory two syntaxes are supported.
# In both cases the working directory must be the root of the kernel src.
# 1) O=
# Use "make O=dir/to/store/output/files/"
# 
# 2) Set KBUILD_OUTPUT
# Set the environment variable KBUILD_OUTPUT to print to the directory
# where the output files shall be placed.
# export KBUILD_OUTPUT=dir/to/store/files/
# make
#
# The O= assignment takes precedence over the KBUILD_OUTPUT environment
# variable.
#
# KBUILD_SRC is set on invocation of make in OBJ directory
# KBUILD_SRC is not intended to be used by the regular user (for now)
ifeq ($(KBUILD_SRC),)
$(warning TOP_DEBUG Entry the KBUILD_SRC)

# OK, Make called in directory where kernel src resides
# Do we want to locate output files in a separate directory?
ifeq ("$(origin O)", "command line")
  KBUILD_OUTPUT := $(O)
  $(warning TOP_DEBUG KBUILD_OUTPUT: $(KBUILD_OUTPUT))
endif

# That's our default target when none is given on the command line
PHONY := _all
_all:

# Cancel implicit rules on top Makefile
$(CURDIR)/Makefile Makefile: ;
$(warning TOP_DEBUG CURDIR=$(CURDIR))

ifneq ($(KBUILD_OUTPUT),)
$(warning TOP_DEBUG KBUILD_OUTPUT has create and entry the KBUILD_OUTPUT)
# Invoke a second make in the output directory, passing relevant variables
# check that the output directory actually exists.
saved-output := $(KBUILD_OUTPUT)
KBUILD_OUTPUT := $(shell mkdir -p $(KBUILD_OUTPUT) && cd $(KBUILD_OUTPUT) \
								&& /bin/pwd)
$(warning TOP_DEBUG saved-output=$(saved-output))
$(warning TOP_DEBUG KBUILD_OUTPUT=$(KBUILD_OUTPUT))

$(if $(KBUILD_OUTPUT),, \
	 $(error failed to create output directory "$(saved-output)"))

PHONY += $(MAKECMDGOALS) sub-make
$(warning TOP_DEBUG PHONY=$(PHONY))
$(warning TOP_DEBUG MAKECMDGOALS=$(MAKECMDGOALS))

$(filter-out _all sub-make $(CURDIR)/Makefile, $(MAKECMDGOALS)) _all: sub-make
	@:

$(warning TOP_DEBUG SUB_TARGET=$(filter-out _all sub-make $(CURDIR)/Makefile, \
							$(MAKECMDGOALS)) _all) 
$(warning FORCE=$(FORCE))

sub-make: FORCE
	$(Q)$(MAKE) -C $(KBUILD_OUTPUT) KBUILD_SRC=$(CURDIR) \
	-f $(CURDIR)/Makefile $(filter-out _all sub-make,$(MAKECMDGOALS))

$(warning FORCE=$(FORCE))
$(warning KBUILD_SRC=$(KBUILD_SRC))

# Leave processing to above invocation of make 
skip-makefile := 1
endif # ifneq ($(KBUILD_OUTPUT),)
endif # ifeq ($(KBUILD_SRC),)

# We process the reset of the Makefile if this is the final invocation of make
ifeq ($(skip-makefile),)
$(warning TOP_DEBUG Entry skip-makefile=0)

# Do not print "Entring directory ...",
# but we want to display it when entring to the output directory
# so that IDEs/editors are able to understand relative filenames.
MAKEFLAGS += --no-print-directory
$(warning MAKEFLAGS=$(MAKEFLAGS))

# Call a source code checker (by default, "sparse") as part of the 
# C compilation.
#
# Use 'make C=1' to enable checking of only re-compiled files.
# Use 'make C=2' to enable checking of *all* source files, regardless
# of whether they are re-compiled or not.
#
# See the file "Documentation/sparse.txt" for more details, including
# where to get the "sparse" utility.

ifeq ("$(origin C)", "command line")
  KBUILD_CHECKSRC = $(C)
endif 
ifndef KBUILD_CHECKSRC
  KBUILD_CHECKSRC = 0
endif
$(warning TOP_DEBUG KBUILD_CHECKSRC=$(KBUILD_CHECKSRC))

# Use make M=dir to specify directory of external module to build
# Old syntex make ... SUBDIR=$PWD is still supported
# Setting the environment variable KBUILD_EXTMOD take precedence
ifdef SUBDIRS
  KBUILD_EXTMOD ?= $(SUBDIRS)
endif

ifeq ("$(origin M)", "command line")
  KBUILD_EXTMOD := $(M)
endif
$(warning TOP_DEBUG KBUILD_EXTMOD=$(KBUILD_EXTMOD))

# If building an external module we do not care about the all: rule
# but instead _all depend on modules
PHONY += all
ifeq ($(KBUILD_EXTMOD),)
_all: all
else
_all: modules
endif

ifeq ($(KBUILD_SRC),)
        # building in the source tree
        srctree := .
else
        ifeq ($(KBUILD_SRC)/,$(dir $(CURDIR)))
                # building in a subdirectory of the source tree
                srctree := ..
        else
                srctree := $(KBUILD_SRC)
        endif
endif
objtree   := .
src       := $(srctree)
obj       := $(srctree)
$(warning TOP_DEBUG srctree=$(srctree))
$(warning TOP_DEBUG objtree=$(objtree))
$(warning TOP_DEBUG src=$(src))
$(warning TOP_DEBUG obj=$(obj))
VPATH     := $(srctree)$(if $(KBUILD_EXTMOD),:$(KBUILD_EXTMOD))
$(warning TOP_DEBUG VPATH=$(VPATH))

export srctree objtree VPATH

# SUBARCH tell the usermode build what the underlying arch is. That is set
# first, and if a usermode build is happening, the "ARCH=um" on the command
# line overrides the setting of ARCH below. If a native build is happening,
# then ARCH is assigned, getting whatever value it gets normally, and
# SUBARCH is subsequently ignored.

SUBARCH := $(shell uname -m | sed -e s/i.86/x86/ -e s/x86_64/x86/ \
				  -e s/sun4u/sparc64/ \
				  -e s/arm.*/arm/ -e s/sa110/arm/ \
				  -e s/s390x/s390/ -e s/parisc64/parisc/ \
				  -e s/ppc.*/powerpc/ -e s/mips.*/mips/ \
				  -e s/sh[234].*/sh/ -e s/aarch64.*/arm64/ )

$(warning TOP_DEBUG SUBARCH=$(SUBARCH))

# Cross compiling and selecting different set of gcc/bin-utils
# ---------------------------------------------------------------------------
#
# When performing cross compilation for other architectures ARCH shall be set
# to the target architecture. (See arch/* for the possibilities).
# ARCH can be set during invocation of make:
# make ARCH=ia64
# Another way is to have ARCH set in the environment.
# The default ARCH is the host where make is executed.
#
# CROSS_COMPILE specify the prefix used for all executables used
# during compilation. Only gcc and related bin-utils executables
# are prefixed with $(CROSS_COMPILE).
# CORSS_COMPILE can be set on the command line
# make CROSS_COMPILE=ia64-linux-
# Alternatively CROSS_COMPILE can be set in the environment.
# A third alternative is to store a setting in .config so that plain
# "make" in the configured kernel build directory always uses that.
# Default value for CROSS_COMPILE is not to prefix executables
# Note: Some architectures assign CROSS_COMPILE in their arch/*/Makefile
#ARCH	?= $(SUBARCH)
ARCH	?= arm
CROSS_COMPILE ?=

# Architecture as present in compile.h
UTS_MACHINE    := $(ARCH)
SRCARCH        := $(ARCH)

$(warning TOP_DEBUG ARCH=$(ARCH))
$(warning TOP_DEBUG CROSS_COMPILE=$(CROSS_COMPILE))
$(warning TOP_DEBUG UTS_MACHINE=$(UTS_MACHINE))
$(warning TOP_DEBUG SRCARCH=$(SRCARCH))

# Additional ARCH setting for x86
ifeq ($(ARCH),i386)
        SRCARCH := x86
endif
ifeq ($(ARCH),x86_64)
        SRCARCH := x86
endif

# Additional ARCH setting for sparc
ifeq ($(ARCH),sparc32)
        SRCARCH := sparc
endif
ifeq ($(ARCH),sparc64)
        SRCARCH := sparc
endif

# Additional ARCH setting for sh
ifeq ($(ARCH),sh64)
        SRCARCH := sh
endif

# Additional ARCH setting for tile
ifeq ($(ARCH),tilepro)
        SRCARCH := tile
endif
ifeq ($(ARCH),tilegx)
        SRCARCH := tile
endif

$(warning TOP_DEBUG SRCARCH=$(SRCARCH))

# Where to locate arch specific headers
hdr-arch  := $(SRCARCH)
$(warning TOP_DEBUG hdr-arch=$(hdr-arch))

KCONFIG_CONFIG ?= .config
export KCONFIG_CONFIG
$(warning TOP_DEBUG KCONFIG_CONFIG=$(KCONFIG_CONFIG))

# SHELL used by kbuild
CONFIG_SHELL := $(shell if [ -x "$$BASH" ]; then echo $$BASH; \
	  else if [ -x /bin/bash ]; then echo /bin/bash; \
	  else echo sh; fi ; fi)
$(warning TOP_DEBUG CONFIG_SHELL=$(CONFIG_SHELL))

HOSTCC       = gcc
HOSTCXX      = g++
HOSTCFLAGS   = -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer -std=gnu89
HOSTCXXFLAGS = -O2

$(warning TOP_DEBUG HOSTCC=$(HOSTCC))
$(warning TOP_DEBUG HOSTCXX=$(HOSTCXX))
$(warning TOP_DEBUG HOSTCFLAGS=$(HOSTCFLAGS))
$(warning TOP_DEBUG HOSTCXXFLAGS=$(HOSTCXXFLAGS))

ifeq ($(shell $(HOSTCC) -v 2>&1 | grep -c "clang version"), 1)
HOSTCFLAGS  += -Wno-unused-value -Wno-unused-parameter \
		-Wno-missing-field-initializers -fno-delete-null-pointer-checks
endif
$(warning HOSTCFLAGS=$(HOSTCFLAGS))

# Decide whether to build built-in, modular, or both.
# Normally, just do built-in

KBUILD_MODULES :=
KBUILD_BUILTIN := 1

# If we have only "make modules", don't compile built-in objects.
# When we're building modules with modversions, we need to consider
# the built-in objects during the descend as well, in order to 
# make sure the checksums are up to date before we record them.

ifeq ($(MAKECMDGOALS),modules)
  KBUILD_BUILTIN := $(if $(CONFIG_MODVERSIONS),1)
endif
$(warning KBUILD_BUILTIN=$(KBUILD_BUILTIN))

# If we have "make <whatever> modules", compile modules
# in addition to whatever we do anyway.
# Just "make" or "make all" shall build modules as well

ifneq ($(filter all _all modules,$(MAKECMDGOALS)),)
  KBUILD_MODULES := 1
endif
$(warning KBUILD_MODULE=$(KBUILD_MODULE))

ifeq ($(MAKECMDGOALS),)
  KBUILD_MODULES := 1
endif
$(warning KBUILD_MODULES=$(KBUILD_MODULES))

export KBUILD_MODULES KBUILD_BUILTIN
export KBUILD_CHECKSRC KBUILD_SRC KBUILD_EXTMOD

# We need some generic definitions (do not try to remake the file).
scripts/Kbuild.include: ;
include scripts/Kbuild.include

# Make variables (CC, etc...)
AS		= $(CROSS_COMPILE)as
LD		= $(CROSS_COMPILE)ld
CC		= $(CROSS_COMPILE)gcc
CPP		= $(CC) -E
AR		= $(CROSS_COMPILE)ar
NM		= $(CROSS_COMPILE)nm
STRIP 		= $(CROSS_COMPILE)strip
OBJCOPY		= $(CROSS_COMPILE)objcopy
OBJDUMP		= $(CROSS_COMPILE)objdump
AWK		= awk
GENKSYMS	= scripts/genksyms/genksyms
INSTALLKERNEL	:= installkernel
DEPMOD		=	/sbin/depmod
PERL		= perl
PYTHON		= python
CHECK		= sparse

CHECKFLAGS		:= -D__linux__ -Dlinux -D_STDC__ -Dunix -D__unix__ \
			-Wbitwise -Wno-return-void $(CF) 
CFLAGS_MODULE	=
AFLAGS_MODULE	=
LDFLAGS_MODULE	=
CFLAGS_KERNEL	=
AFLAGS_KERNEL	=
CFLAGS_GCOV 	= -fprofile-arcs -ftest-coverage

$(warning AS=$(AS))
$(warning LD=$(LD))
$(warning CC=$(CC))
$(warning CPP=$(CPP))
$(warning AR=$(AR))
$(warning NM=$(NM))
$(warning STRIP=$(STRIP))
$(warning OBJCOPY=$(OBJCOPY))
$(warning OBJDUMP=$(OBJDUMP))
$(warning AWK=$(AWK))
$(warning GENKSYMS=$(GENKSYMS))
$(warning INSTALLKERNEL=$(INSTALLKERNEL))
$(warning DEPMOD=$(DEPMOD))
$(warning PERL=$(PERL))
$(warning PYTHON=$(PYTHON))
$(warning CHECK=$(CHECK))
$(warning CHECKFLAGS=$(CHECKFLAGS))
$(warning AFLAGS_MODULE=$(AFLAGS_MODULE))
$(warning CFLAGS_MODULE_$(CFLAGS_MODULE))
$(warning LDFLAGS_MODULE=$(LDFLAGS_MODULE))
$(warning CFLAGS_KERNEL=$(CFLAGS_KERNEL))
$(warning AFLAGS_KERNEL=$(AFLAGS_KERNEL))
$(warning CFLAGS_GCOV=$(CFLAGS_GCOV))

# Use USERINCLUDE when you must reference the UAPT directories only.
USERINCLUDE	:= \
	-I$(srctree)/arch/$(hdr-arch)/include/uapi \
	-Iarch/$(hdr-arch)/include/generated/uapi \
	-I$(srctree)/include/uapi \
	-Iinclude/generated/uapi \
			-include $(srctree)/include/linux/kconfig.h

$(warning USERINCLUDE=$(USERINCLUDE))

# Use LINUXINCLUDE when you must reference the include/ directory.
# Needed to be compatible with the O= option
LINUXINCLUDE	:= \
		-I$(srctree)/arch/$(hdr-arch)/include \
		-Iarch/$(hdr-arch)/include/generated/uapi \
		-Iarch/$(hdr-arch)/include/generated \
		$(if $(KBUILD_SRC), -I$(srctree)/include) \
		-Iinclude \
		$(USERINCLUDE)

$(warning LINUXINCLUDE=$(LINUXINCLUDE))

KBUILD_CPPFLAGS := -D__KERNEL__

KBUILD_CFLAGS 	:= -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs \
			-fno-strict-aliasing -fno-common \
			-Werror-implicit-function-declaration \
			-Wno-format-security \
			-std=gnu89

$(warning KBUILD_CPPFLAGS=$(KBUILD_CPPFLAGS))
$(warning KBUILD_CFLAGS=$(KBUILD_CFLAGS))

KBUILD_AFLAGS_KERNEL :=
KBUILD_CFLAGS_KERNEL :=
KBUILD_AFLAGS	:= -D__ASSEMBLY__
KBUILD_AFLAGS_MODULE  := -DMODULE
KBUILD_CFLAGS_MODULE  := -DMODULE
KBUILD_LDFLAGS_MODULE := -T $(srctree)/scripts/module-common.lds

$(warning KBUILD_AFLAGS_KERNEL=$(KBUILD_AFLAGS_KERNEL))
$(warning KBUILD_CFLAGS_KERNEL=$(KBUILD_CFLAGS_KERNEL))
$(warning KBUILD_AFLAGS=$(KBUILD_AFLAGS))
$(warning KBUILD_AFLAGS_MODULE=$(KBUILD_AFLAGS_MODULE))
$(warning KBUILD_CLFAGS_MODULE=$(KBUILD_CFLAGS_MODULE))
$(warning KBUILD_LDFLAGS_MODULE=$(KBUILD_LDFLAGS_MODULE))

# Read KERNELRELEASE from include/config/kernel.release (if it exists)
KERNELRELEASE = $(shell cat include/config/kernel.release 2> /dev/null)
KERNELVERSION = $(VERSION)$(if $(PATCHLEVEL),.$(PATCHLEVEL)$(if $(SUBLEVEL),.$(SUBLEVEL)))$(EXTRAVERSION)

$(warning KERNELRELEASE=$(KERNELRELEASE))
$(warning KERNELVERSION=$(KERNELVERSION))

export VERSION PATCHLEVEL SUBLEVEL KERNELRELEASE KERNELVERSION
export ARCH SRCARCH CONFIG_SHELL HOSTCC HOSTCFLAGS CROSS_COMPILE AS LD CC
export CPP AR NM STRIP OBJCOPY OBJDUMP
export MAKE AWK GENKSYMS INSTALLKERNEL PERL PYTHON UTS_MACHINE
export HOSTCXX HOSTCXXFLAGS LDFLAGS_MODULE CHECK CHECKFLAGS

export KBUILD_CPPFLAGS NOSTDINC_FLAGS LINUXINCLUDE OBJCOPYFLAGS LDFLAGS
export KBUILD_CFALGS CFLAGS_KERNEL CFLAGS_MODULE CFLAGS_GCOV CFLAGS_KASAN
export KBUILD_AFLAGS AFLAGS_KERNEL AFLAGS_MODULE
export KBUILD_AFLAGS_MODULE KBUILD_CFLAGS_MODULE KBUILD_LDFLAGS_MODULE
export KBUILD_AFLAGS_KERNEL KBUILD_CFLAGS_KERNEL
export KBUILD_ARFLAGS

# When compiling out-of-tree modules, put MODVERDIR in the module
# tree rather than in the kernel tree. The kernel tree might
# even be read-only.
export MODVERDIR := $(if $(KBUILD_EXTMOD),$(firstword $(KBUILD_EXTMOD))/).tmp_versions
$(warning MODVERDIR=$(MODVERDIR))

# File to ignore in find ... statements

export RCS_FIND_IGNORE := \( -name SCCS -o -name BitKeeper -o -name .svn -o   \
			  -name CVS -o -name .pc -o -name .hg -o -name .git \) \
			  -prune -o
$(warning RCS_FIND_IGNORE=$(RCS_FIND_IGNORE))

export RCS_TAR_IGNORE := --exclude SCCS --exclude BitKeeper --exclude .svn \
		     --exclude CVS --exclude .pc --exclude .hg --exclude .git
$(warning RCS_TAR_IGNORE=$(RCS_TAR_IGNORE))

# ===========================================================================
# Rules shared between *config targets and build targets

# Basic helpers built in scripts/
PHONY += scripts_basic
scripts_basic:
	$(Q)$(MAKE) $(build)=scripts/basic
	$(Q)rm -f .tmp_quiet_recordmcount

$(warning build=$(build))

# To avoid any implicit rule to kick in, define an empty command.
scripts/basic/%: scripts_basic ;

PHONY += outputmakefile
# outputmakefile generates a Makefile in the output directory, if using a 
# separate output directory. This allows convenient use of make in the
# output directory.
outputmakefile:
ifneq ($(KBUILD_SRC),)
	$(Q)ln -fsn $(scrtree) source
	$(Q)$(CONFIG_SHELL) $(srctree)/scripts/mkmakefile \
		$(srctree) $(objtree) $(VERSION) $(PATCHLEVEL)
endif

# Support for using generic headers in asm-generic
PHONY += asm-generic
asm-generic:
	$(Q)$(MAKE) -f $(srctree)/scripts/Makefile.asm-generic \
				src=asm obj=arch/$(SRCARCH)/include/generated/asm
	$(Q)$(MAKE) -f $(srctree)/scripts/Makefile.asm-generic \
				src=uapi/asm obj=arch/$(SRCARCH)/include/generated/uapi/asm

# To make sure we do not include .config for any of the *config targets
# catch them early, and hand them over to scripts/kconfig/Makefile
# It is allowed to specify more target when calling make, including
# mixing *config targets and build targets.
# For example 'make oldconfig all'.
# Detect when mixed targets is specified, and make a second invocation
# of make so .config is not included in this case either (for *config)

version_h := include/generated/uapi/linux/version.h
old_version_h := include/linux/version.h

$(warning version_h=$(version_h))
$(warning old_version_h=$(old_version_h))

no-dot-config-targets := clean mrproper distclean \
			cscope gtags TAGS tags help% %docs check% coccicheck  \
			$(version_h) headers_% archheaders archscripts \
			kernelversion %src-pkg
$(warning no-dot-config-targets=$(no-dot-config-targets))

config-targets := 0
mixed_targets  := 0
dot-config	   := 1

$(warning MAKECMDGOALS=$(MAKECMDGOALS))
ifneq ($(filter $(no-dot-config-targets), $(MAKECMDGOALS)),)
    ifeq ($(filter-out $(no-dot-config-targets), $(MAKECMDGOALS)),)
          dot-config := 0
    endif
endif

$(warning KBUILD_EXTMOD=$(KBUILD_EXTMOD))
ifeq ($(KBUILD_EXTMOD),)
        ifneq ($(filter config %config,$(MAKECMDGOALS)),)
                config-targets := 1
                ifneq ($(words $(MAKECMDGOALS)),1)
                        mixed-targets := 1	
                endif
        endif
endif

$(warning mixed-targets=$(mixed-targets))
$(warning config-targets=$(config-targets))
$(warning dot-config=$(dot-config))

ifeq ($(mixed-targets),1)
$(warning Entry this path...)
# ==========================================================================
# We're called with mixed targets (*config and build targets).
# Handle them one by one.

PHONY += $(MAKECMDGOALS) __build_one_by_one

$(filter-out __build_one_by_one, $(MAKECMDGOALS)): __build_one_by_one
	@:

$(warning MAKECMDGOALS=$(MAKECMDGOALS))

__build_one_by_one:
	$(Q)set -e; \
	for i in $(MAKECMDGOALS); do \
		$(MAKE) -f $(srctree)/Makefile $$i; \
	done

else
$(warning Entry this else path....)
ifeq ($(config-targets),1)
$(warning Entry this path.....)
# ===========================================================================
# *config targets only - make sure prerequisites are updated, and descend
# in scripts/kconfig to make the *config target

# Read arch specific Makefile to set KBUILD_DEFCONFIG as needed.
# KBUILD_DEFCONFIG may point out an alternative default configuration
# used for 'make defconfig'
include arch/$(SRCARCH)/Makefile
export KBUILD_DEFCONFIG KBUILD_KCONFIG

config: scripts_basic outputmakefile FORCE
	$(Q)$(MAKE) $(build)=scripts/kconfig $@

%config: scripts_basic outputmakefile FORCE
	$(Q)$(MAKE) $(build)=scripts/kconfig $@

else
$(warning Entry the else path.....)
# ===========================================================================
# Build targets only - this includes vmlinux, arch specific targets, clean
# targets and others. In general all targets except *config targets.

ifeq ($(KBUILD_EXTMOD),)
$(warning Entry this path....)
# Additional helpers built in scripts/
# Carefully list dependencies so we do not try to build scripts twice
# in parallel
$(warning build=$(build))
PHONY += scripts
scripts: scripts_basic include/config/auto.conf include/config/tristate.conf \
		asm-generic
	$(Q)$(MAKE) $(build)=$(@)

# Objects we will link into vmlink /subdirs we need to visit
init-y 		:= init/
drivers-y	:= drivers/ sound/ firmware/
net-y		:= net/
libs-y		:= lib/
core-y		:= usr/
virt-y		:= virt/
endif # KBUILD_EXTMOD

ifeq ($(dot-config),1)
$(warning Entry this path....)
# Read in config
-include include/config/auto.conf

ifeq ($(KBUILD_EXTMOD),)
$(warning Entry this path....)
# Read in dependencies to all Kconfig* files, make sure to run
# oldconfig if changes are detected.
-include include/config/auto.conf.cmd

# To avoid any implicit rule to kick in, define an empty command
$(KCONFIG_CONFIG) include/config/auto.conf.cmd: ;
$(warning Avoid implicit rule)

# If .config is newer than include/config/auto.conf, someone tinkered
# with it and forgot to run make oldconfig.
# if auto.conf.cmd is missing then we are probably in a cleaned tree so
# we execute the config step to be sure to catch updated Kconfig files
$(warning KCONFIG_CONFIG=$(KCONFIG_CONFIG))
include/config/%.conf: $(KCONFIG_CONFIG) include/config/auto.conf.cmd
	$(Q)$(MAKE) -f $(srctree)/Makefile silentoldconfig
else # KBUILD_EXTMOD
$(warning Entry this path..........)
# external modules needs include/generated/autoconf.h and include/config/auto.conf
# but do not care if they are up-to-date. Use auto.conf to trigger the test
PHONY += include/config/auto.conf

include/config/auto.conf:
	$(Q)test -e include/generated/autoconf.h -a -e $@ || (      \
	echo >&2;              \
	echo >&2 "	ERROR: Kernel configuration is invalid.";     \
	echo >&2 "		   include/generated/autoconf.h or $@ are missing.";  \
	echo >&2 "		   Run 'make oldconfig && make prepare' on kernel src to fix it.";     \
	echo >&2 ;               \
	/bin/false)

endif # KBUILD_EXTMOD

else
$(warning Entry the path....................)
# Dummy target needed, because used as prerequisite
include/config/auto.conf: ;
$(warning End of KBUILD_EXTMOD)
endif # dot-config

# The all: target is the default when no target is given on the 
# command line.
# This allow a user to issue only 'make' to build a kernel including modules
# Defaults to vmlinux, but the arch makefile usually adds further targets
all: vmlinux

# The arch Makefile can set ARCH_{CPP,A,C}FLAGS to override the default
# values of the respective KBUILD_* variables
ARCH_CPPFLAGS :=
ARCH_AFLAGS :=
ARCH_CFLAGS :=
include arch/$(SRCARCH)/Makefile

KBUILD_CFLAGS += $(call cc-option,-fno-delete-null-pointer-checks,)
$(warning KBUILD_CFLAGS=$(KBUILD_CFLAGS))

ifdef CONFIG_CC_OPTIMIZE_FOR_SIZE
KBUILD_CFLAGS	+= -Os $(call cc-disable-warning,maybe-uninitialzied,)
else
KBUILD_CFLAGS	+= -O2
endif

# Tell gcc to never replace conditional load with a non-conditional one
KBUILD_CFLAGS	+= $(call cc-option,--param=alloc-store-data-reaces=0)
$(warning KBUILD_CFLAGS=$(KBUILD_CFLAGS))

ifdef CONFIG_READABLE_ASM
# Disable optimizations that make assembler listings hard to read.
# reorder blocks reorders the control in the function
# ipa clone creates specialized cloned functions
# partial inlining inlines only parts of functions
KBUILD_CFLAGS += $(call cc-option,-fno-reorder-blocks,) \
				 $(call cc-option,-fno-ipa-cp-clone,)  \
				 $(call cc-option,-fno-partial-inlining)
$(warning KBUILD_CFLAGS=$(KBUILD_CFLAGS))
endif

ifneq ($(CONFIG_FRAME_WARN),0)
KBUILD_CFLAGS += $(call cc-option,-Wframe-larger-than=${CONFIG_FRAME_WARN})
$(warning KBUILD_CFLAGS=$(KBUILD_CFLAGS))
endif

# Handle stack protector mode.
# Since kbuild can potentially perform two passes (first with the old
# .config value and then with update .config values), we cannot error out
# if a desired compiler option is unsupported. If we were to error, kbuild
# could never get to the second pass and actually notice that we changed
# the option to someting that was supported.
#
# Additionlly, we don't want to fallback and/or silently change which compiler
# flags will be used, since that leads to producing kernel with different
# security feature characteristics depending on the compiler used. ("But I
# selected CC_STACKPROTECTOR_STRONG! Why did it build with _REGULAR?!")
#
# The middle ground is to warn here so that the failed option is obvious, but
# to let the build fail with bad compiler flags so that we can't produce a 
# kernel when there is a CONFIG  and compiler mismatch.
#
ifdef CONFIG_CC_STACKPROTECTOR_REGULAR
   
endif

$(warning KBUILD_CFLAGS=$(KBUILD_CFLAGS))

$(warning End of dot-config)

endif # config-targets
$(warning End of config-targets)

endif # mixed-targets
$(warning End of mixed-targets)


endif
PHONY += FORCE
FORCE:

# Declare the contents of the .PHONY variable as phony. We keep that
# information in a variable so we can use it in if_changed and friends.
.PHONY: $(PHONY)
