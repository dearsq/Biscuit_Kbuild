#
# linux/arch/arm/boot/comparessed/Makefile
#
# create a comparessed vmlinuz image from the original vmlinux
#

OBJS    =

AFLAGS_head.o += -DTEXT_OFFSET=$(TEXT_OFFSET)
HEAD  = head.o
OBJS  += misc.o decompress.o
ifeq ($(CONFIG_DEBUG_UNCOMPRESS),y)
OBJS    += debug.o
endif
FONTC  = $(srctree)/lib/font/font_acorn_8x8.c
