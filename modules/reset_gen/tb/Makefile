
# Name of the testbench without extenstion
TESTBENCH ?= reset_gen_tb

# VHDL files

FILES = \
../../hdl/reset_gen_pkg.vhd\
../../hdl/reset_gen.vhd

GHDL_SIM_OPT = --stop-time=60us

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT += --assert-level=error

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include makefile.ghdl.mk

