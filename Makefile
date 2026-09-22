# SPDX-FileCopyrightText: 2023 Jon Carstens
#
# SPDX-License-Identifier: Apache-2.0

# Makefile targets:
#
# all		   build and install the package
# clean    clean build products and intermediates
#
# Variables to override:
#
# MIX_COMPILE_PATH 	path to the build's ebin directory
# CC            		C compiler
# CFLAGS						compiler flags for compiling all C files

TOP := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SRC_TOP = $(TOP)/c_src

PREFIX = $(MIX_COMPILE_PATH)/../priv
BUILD  = $(MIX_COMPILE_PATH)/../obj

CFLAGS ?= -O2 -Wall -Wextra -pedantic -Wno-unused-parameter -Wno-unused-but-set-variable
REQUIRED_CFLAGS := -D_GNU_SOURCE

calling_from_make:
	mix compile

all: $(PREFIX)/tty0tty

$(PREFIX)/tty0tty: $(PREFIX)
	@echo " CC $(notdir $@)"
	$(CC) $(CFLAGS) $(REQUIRED_CFLAGS) $(SRC_TOP)/tty0tty.c -o $@

$(PREFIX) $(BUILD):
	mkdir -p $@

clean:
	if [ -n "$(MIX_COMPILE_PATH)" ]; then $(RM) -r $(BUILD); fi

.PHONY: all clean calling_from_make

# Don't echo commands unless the caller exports "V=1"
${V}.SILENT:
