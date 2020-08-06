# Usage
# =====
#
# Define the following variables and then include this file:
#
#   TESTBENCH
#		Testbench file without extensition
#   FILES
#		List of all VHDL files (e.g. ../hdl/spislave.vhd ../hdl/spislave_pkg.vhd)
#   WAVEFORM_SETTINGS
#		Save file for gtkwave, may be empty.
#		Use gtkwave > File > Write Save File (Strg + S) to generate the file
#   GHDL_SIM_OPT
#		Options for GHDL (e.g. "--stop-time=12us")

VHDLEX ?= .vhd

# Testbench
TESTBENCHPATH ?= $(TESTBENCH)$(VHDLEX)

# GHDL configuration
GHDL ?= ghdl
GHDL_IMPORT_FLAGS += --ieee=synopsys
GHDL_FLAGS += $(GHDL_IMPORT_FLAGS) --syn-binding

SIMDIR ?= simulation
WAVEFORM_VIEWER ?= gtkwave

all: compile run

Makefile_ghdl: $(FILES) $(TESTBENCH).vhd
	# check if TESTBENCH is empty
ifeq ($(strip $(TESTBENCH)),)
	@echo "TESTBENCH not set. Use TESTBENCH=value to set it."
	@exit 2
endif
	ghdl --clean
	ghdl -i $(FILES)
	ghdl -i ../../hdl/*.vhd
	ghdl -i $(TESTBENCH).vhd
	ghdl --gen-makefile $(TESTBENCH) > Makefile_ghdl

$(TESTBENCH).ghw: Makefile_ghdl
	make -f Makefile_ghdl  run GHDLRUNFLAGS="$(GHDL_SIM_OPT) --wave=$(TESTBENCH).ghw"

compile: $(TESTBENCH).ghw

run: $(TESTBENCH).ghw

view: $(TESTBENCH).ghw
	$(WAVEFORM_VIEWER) $(TESTBENCH).ghw $(WAVEFORM_SETTINGS)

clean:
	rm -rf Makefile_ghdl work-obj93.cf
