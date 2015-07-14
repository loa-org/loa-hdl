
# Name of the testbench without extenstion
TESTBENCH = uss_tx_module_tb
# TESTBENCH = serialiser_tb

# VHDL files
ifeq ($(TESTBENCH), uss_tx_module_tb)
FILES = \
../../hdl/bus_pkg.vhd \
../../hdl/reg_file_pkg.vhd \
../../hdl/reg_file.vhd \
../../hdl/motor_control_pkg.vhd \
../../hdl/deadtime.vhd \
../../hdl/utils_pkg.vhd \
../../hdl/clock_divider.vhd \
../../hdl/fractional_clock_divider_variable.vhd \
../../hdl/serialiser.vhd \
../../hdl/uss_tx_pkg.vhd \
../../hdl/uss_tx_module.vhd
else ifeq ($(TESTBENCH), serialiser_tb)
FILES = ../../hdl/serialiser.vhd \
../../hdl/utils_pkg.vhd \
../../hdl/fractional_clock_divider.vhd
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=50000us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include makefile.ghdl.mk

