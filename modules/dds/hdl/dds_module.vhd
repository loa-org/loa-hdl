-------------------------------------------------------------------------------
-- Title      : Direct digital synhtesis module - 1 Channel
-------------------------------------------------------------------------------
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
-- Created    : 2015-08-24
-------------------------------------------------------------------------------
-- Copyright (c) 2015, Carl Treudler
-- All Rights Reserved.
--
-- The file is part for the Loa project and is released under the
-- 3-clause BSD license. See the file `LICENSE` for the full license
-- governing this code.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reg_file_pkg.all;
use work.nco_pkg.all;
use work.bus_pkg.all;
use work.reset_pkg.all;

entity dds_module is

  generic (
    BASE_ADDRESS : integer range 0 to 2**15-1;
    RESET_IMPL   : reset_type := none);

  port (
    bus_o : out busdevice_out_type;
    bus_i : in  busdevice_in_type;

    -- NCO 0 output
    dout : out std_logic_vector(15 downto 0);

    reset : in std_logic;
    clk   : in std_logic);

end entity dds_module;

architecture structural of dds_module is
  signal phase_increment : std_logic_vector(31 downto 0);
  signal phase           : std_logic_vector(9 downto 0);
  signal ctrl_reg        : std_logic_vector(15 downto 0);
  signal accu_load0      : std_logic_vector(31 downto 0);
  signal load0, en0      : std_logic;

  signal bus_ram_o, bus_ctrl_reg_o, bus_phase_inc_lsb_register_o, bus_load_lsb_register_o, bus_phase_inc_msb_register_o, bus_load_msb_register_o : busdevice_out_type;

begin  -- architecture structural

  -----------------------------------------------------------------------------
  -- NCO 0 - controls fed by bus mapped registers
  --         output goes to waveform_ram below
  -----------------------------------------------------------------------------
  nco_0 : entity work.nco
    generic map (
      ACCU_WIDTH  => 32,
      PHASE_WIDTH => 10,
      RESET_IMPL  => RESET_IMPL)
    port map (
      en              => en0,
      phase_increment => phase_increment,
      phase           => phase,
      load            => load0,
      accu_load       => accu_load0,
      reset           => reset,
      clk             => clk);

  -----------------------------------------------------------------------------
  -- Double ported BRAM
  -- waveform has to be loaded from bus-side
  -- output is updated every cycle
  -----------------------------------------------------------------------------
  waveform_ram : entity work.reg_file_bram
    generic map (
      BASE_ADDRESS => BASE_ADDRESS,
      RESET_IMPL   => RESET_IMPL)
    port map (
      bus_o       => bus_ram_o,
      bus_i       => bus_i,
      bram_data_i => (others => '0'),
      bram_data_o => dout,
      bram_addr_i => phase,
      bram_we_p   => '0',
      reset       => reset,
      clk         => clk);

  -----------------------------------------------------------------------------
  -- Registers:
  --
  -- Control register
  --      Enable
  --      Load
  --
  -- Phase Increment Reg - sets increment
  --
  -- Accu Preload - sets Phase accumulator directly, has to be enabled by laod
  --                bit in control register (and disabled).
  -----------------------------------------------------------------------------
  control_register : entity work.peripheral_register
    generic map (
      BASE_ADDRESS => BASE_ADDRESS + 16#400#,
      RESET_IMPL   => RESET_IMPL)
    port map (
      dout_p => ctrl_reg,
      din_p  => ctrl_reg,
      bus_o  => bus_ctrl_reg_o,
      bus_i  => bus_i,
      reset  => reset,
      clk    => clk);

  phase_inc_lsb_register : entity work.peripheral_register
    generic map (
      BASE_ADDRESS => BASE_ADDRESS + 16#401#,
      RESET_IMPL   => RESET_IMPL)
    port map (
      dout_p => phase_increment(15 downto 0),
      din_p  => phase_increment(15 downto 0),
      bus_o  => bus_phase_inc_lsb_register_o,
      bus_i  => bus_i,
      reset  => reset,
      clk    => clk);

  phase_inc_msb_register : entity work.peripheral_register
    generic map (
      BASE_ADDRESS => BASE_ADDRESS + 16#402#,
      RESET_IMPL   => RESET_IMPL)
    port map (
      dout_p => phase_increment(31 downto 16),
      din_p  => phase_increment(31 downto 16),
      bus_o  => bus_phase_inc_msb_register_o,
      bus_i  => bus_i,
      reset  => reset,
      clk    => clk);



  load_lsb_register : entity work.peripheral_register
    generic map (
      BASE_ADDRESS => BASE_ADDRESS + 16#403#,
      RESET_IMPL   => RESET_IMPL)
    port map (
      dout_p => accu_load0(15 downto 0),
      din_p  => accu_load0(15 downto 0),
      bus_o  => bus_load_lsb_register_o,
      bus_i  => bus_i,
      reset  => reset,
      clk    => clk);

  load_msb_register : entity work.peripheral_register
    generic map (
      BASE_ADDRESS => BASE_ADDRESS + 16#404#,
      RESET_IMPL   => RESET_IMPL)
    port map (
      dout_p => accu_load0(31 downto 16),
      din_p  => accu_load0(31 downto 16),
      bus_o  => bus_load_msb_register_o,
      bus_i  => bus_i,
      reset  => reset,
      clk    => clk);


  -----------------------------------------------------------------------------
  -- Control Register Mapping
  -- (ctrl_reg bits to control signals)
  -----------------------------------------------------------------------------
  en0   <= ctrl_reg(0);
  load0 <= ctrl_reg(1);

  -----------------------------------------------------------------------------
  -- combine bus_o signals of all components
  -----------------------------------------------------------------------------
  bus_o.data <= bus_load_lsb_register_o.data or
                bus_load_msb_register_o.data or
                bus_phase_inc_lsb_register_o.data or
                bus_phase_inc_msb_register_o.data or
                bus_ctrl_reg_o.data or
                bus_ram_o.data;

end architecture structural;
