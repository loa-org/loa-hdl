
# Name of the testbench without extenstion
TESTBENCH = fsmcslave_tb

# VHDL files
FILES = \
../../hdl/fsmcslave_pkg.vhd \
../../hdl/fsmcslave.vhd  \
../../hdl/bus_pkg.vhd \
../../hdl/reg_file.vhd \
../../hdl/peripheral_register.vhd \
../../hdl/reg_file_pkg.vhd 

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=5us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include makefile.ghdl.mk

