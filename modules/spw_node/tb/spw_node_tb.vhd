-------------------------------------------------------------------------------
-- Title      : Testbench for SpW Node 
-------------------------------------------------------------------------------
-- Author     : Carl Treudler
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.spw_node_pkg.all;
use work.bus_pkg.all;
use work.reset_pkg.all;
use work.reg_file_pkg.all;

-------------------------------------------------------------------------------
entity spw_node_tb is
end entity spw_node_tb;

-------------------------------------------------------------------------------
architecture behavourial of spw_node_tb is

  constant BASE_ADDRESS : integer := 16#0100#;

  signal do_p : std_logic;
  signal so_p : std_logic;
  signal di_p : std_logic;
  signal si_p : std_logic;

  signal bus_o : busdevice_out_type;
  signal bus_i : busdevice_in_type :=
    (addr => (others => '0'),
     data => (others => '0'),
     we   => '0',
     re   => '0');

  -- component ports
  signal clk, reset : std_logic := '0';

begin

  -- loop back
  si_p <= so_p;
  di_p <= do_p;

  spw_node_1 : entity work.spw_node
    generic map (
      BASE_ADDRESS => BASE_ADDRESS,
      RESET_IMPL   => sync)
    port map (
      do_p  => do_p,
      so_p  => so_p,
      di_p  => di_p,
      si_p  => si_p,
      bus_o => bus_o,
      bus_i => bus_i,
      reset => reset,
      clk   => clk);

  -- clock generation
  clk <= not clk after 10 ns;

  -- Generate reset signal 
  process
  begin
    wait until rising_edge(clk);
    reset <= '1';
    wait until rising_edge(clk);
    reset <= '0';
    wait for 500 ms;

  end process;

  -- waveform generation
  process
  begin
    wait until rising_edge(clk); wait until rising_edge(clk); wait until rising_edge(clk); wait until rising_edge(clk); wait until rising_edge(clk); wait until rising_edge(clk);

    readWord(addr  => BASE_ADDRESS+1, bus_i => bus_i, clk => clk);
    readWord(addr  => BASE_ADDRESS+2, bus_i => bus_i, clk => clk);
    readWord(addr  => BASE_ADDRESS, bus_i => bus_i, clk => clk);
    writeWord(addr => BASE_ADDRESS+2, data => 16#0203#, bus_i => bus_i, clk => clk);

    wait for 10 us;
    readWord(addr => BASE_ADDRESS+1, bus_i => bus_i, clk => clk);
    wait for 10 us;
    readWord(addr => BASE_ADDRESS+1, bus_i => bus_i, clk => clk);
    wait for 10 us;
    readWord(addr => BASE_ADDRESS+1, bus_i => bus_i, clk => clk);

    writeWord(addr => BASE_ADDRESS, data => 16#0055#, bus_i => bus_i, clk => clk);
    writeWord(addr => BASE_ADDRESS, data => 16#0056#, bus_i => bus_i, clk => clk);
    writeWord(addr => BASE_ADDRESS, data => 16#0057#, bus_i => bus_i, clk => clk);
    writeWord(addr => BASE_ADDRESS, data => 16#0058#, bus_i => bus_i, clk => clk);
    writeWord(addr => BASE_ADDRESS, data => 16#0059#, bus_i => bus_i, clk => clk);

    wait for 10 us;
    readWord(addr => BASE_ADDRESS+1, bus_i => bus_i, clk => clk);
    readWord(addr => BASE_ADDRESS, bus_i => bus_i, clk => clk);
    wait for 100 us;
    readWord(addr => BASE_ADDRESS, bus_i => bus_i, clk => clk);
    readWord(addr => BASE_ADDRESS, bus_i => bus_i, clk => clk);
    readWord(addr => BASE_ADDRESS, bus_i => bus_i, clk => clk);
    readWord(addr => BASE_ADDRESS, bus_i => bus_i, clk => clk);
    readWord(addr => BASE_ADDRESS, bus_i => bus_i, clk => clk);
    readWord(addr => BASE_ADDRESS, bus_i => bus_i, clk => clk);
    readWord(addr => BASE_ADDRESS, bus_i => bus_i, clk => clk);

    wait for 100 us;

  end process;

end architecture behavourial;
