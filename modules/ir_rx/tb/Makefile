
# Name of the testbench without extenstion
#TESTBENCH = ir_rx_module_tb
#TESTBENCH = ir_rx_adcs_tb

# VHDL files

ADV_FILES = \
../../hdl/utils_pkg.vhd \
../../hdl/edge_detect.vhd \
../../hdl/bus_pkg.vhd \
../../hdl/xilinx_block_ram_pkg.vhd \
../../hdl/xilinx_block_ram.vhd \
../../hdl/bus_pkg.vhd \
../../hdl/reg_file_pkg.vhd \
../../hdl/reg_file.vhd \
../../hdl/double_buffering.vhd \
../../hdl/reg_file_bram_double_buffered.vhd \
../../hdl/adc_ltc2351.vhd \
../../hdl/ir_rx_adcs.vhd \
../../hdl/adc_ltc2351_pkg.vhd \
../../hdl/adc_ltc2351_model.vhd \
../../hdl/signalprocessing_pkg.vhd \
../../hdl/goertzel.vhd \
../../hdl/goertzel_control_unit.vhd \
../../hdl/goertzel_muxes.vhd \
../../hdl/goertzel_pipeline.vhd \
../../hdl/goertzel_pipelined_v2.vhd \
../../hdl/timestamp_taker.vhd \
../../hdl/timestamp_generator.vhd \
../../hdl/ir_rx_module_pkg.vhd \
../../hdl/ir_rx_module.vhd 

ifeq ($(TESTBENCH), ir_rx_module_tb) 
FILES = \
$(ADV_FILES) 
else ifeq ($(TESTBENCH), ir_rx_module_timestamp_tb)
FILES = \
$(ADV_FILES) 
else ifeq ($(TESTBENCH), ir_rx_adcs_tb)
FILES = \
$(ADV_FILES) \
../../hdl/adc_ltc2351_pkg.vhd \
../../hdl/adc_ltc2351.vhd \
../../hdl/ir_rx_adcs.vhd
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=1000us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include makefile.ghdl.mk
