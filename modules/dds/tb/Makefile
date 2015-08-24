
# Name of the testbench without extenstion
TESTBENCH = dds_module_tb

# VHDL files
FILES =  \
	../../hdl/dds_module.vhd \
	../../hdl/dds_module_pkg.vhd \
	../../hdl/nco.vhd \
	../../hdl/nco_pkg.vhd \
	../../hdl/peripheral_register.vhd \
	../../hdl/reset_pkg.vhd \
	../../hdl/bus_pkg.vhd \
	../../hdl/reg_file_bram.vhd \
	../../hdl/xilinx_block_ram_pkg.vhd \
	../../hdl/xilinx_block_ram.vhd \
	../../hdl/utils_pkg.vhd \
	../../hdl/reg_file_pkg.vhd

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=1000us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include makefile.ghdl.mk

