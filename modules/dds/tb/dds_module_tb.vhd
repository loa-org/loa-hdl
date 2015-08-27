-------------------------------------------------------------------------------
-- Title      : Testbench for design "dds_module"
-------------------------------------------------------------------------------
-- Author     : Carl Treudler 
-- Standard   : 
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.dds_module_pkg.all;
use work.bus_pkg.all;
use work.reset_pkg.all;

-------------------------------------------------------------------------------
entity dds_module_tb is
end dds_module_tb;

-------------------------------------------------------------------------------
architecture tb of dds_module_tb is

  -- component generics
  constant BASE_ADDRESS : positive := 16#400#;

  -- component ports
  signal bus_o : busdevice_out_type;
  signal bus_i : busdevice_in_type :=
    (addr => (others => '0'),
     data => (others => '0'),
     we   => '0',
     re   => '0');
  signal dout  : std_logic_vector(15 downto 0);
  signal reset : std_logic;
  signal clk   : std_logic := '1';

begin

  dds_module_1 : entity work.dds_module
    generic map (
      BASE_ADDRESS => BASE_ADDRESS,
      RESET_IMPL   => none)
    port map (
      bus_o => bus_o,
      bus_i => bus_i,
      dout  => dout,
      reset => reset,
      clk   => clk);


  -- clock generation
  clk <= not clk after 10 ns;

  -- reset generation
  reset <= '1', '0' after 50 ns;

  waveform : process
  begin
    wait until falling_edge(reset);
    wait for 20 us;

    ---------------------------------------------------------------------------
    -- load some data into waveform ram
    ---------------------------------------------------------------------------
    wait until rising_edge(clk);
    bus_i.addr <= std_logic_vector(to_unsigned(16#400#, 15));
    bus_i.data <= x"0123";
    bus_i.we   <= '1';
    wait until rising_edge(clk);
    bus_i.addr <= std_logic_vector(to_unsigned(16#401#, 15));
    bus_i.data <= x"0124";
    bus_i.we   <= '1';
    wait until rising_edge(clk);
    bus_i.addr <= std_logic_vector(to_unsigned(16#402#, 15));
    bus_i.data <= x"0125";
    bus_i.we   <= '1';
    wait until rising_edge(clk);
    bus_i.we   <= '0';

    wait for 1 us;


    ---------------------------------------------------------------------------
    -- Set Phase increment
    ---------------------------------------------------------------------------
    wait until rising_edge(clk);
    bus_i.addr <= std_logic_vector(to_unsigned(16#801#, 15));
    bus_i.data <= x"0001";
    bus_i.we   <= '1';
    wait until rising_edge(clk);
    bus_i.addr <= std_logic_vector(to_unsigned(16#802#, 15));
    bus_i.data <= x"0020";
    bus_i.we   <= '1';
    wait until rising_edge(clk);
    bus_i.we   <= '0';


    
    ---------------------------------------------------------------------------
    -- Set Phase -- 0°
    ---------------------------------------------------------------------------
    wait until rising_edge(clk);
    bus_i.addr <= std_logic_vector(to_unsigned(16#803#, 15));
    bus_i.data <= x"0000";              
    bus_i.we   <= '1';
    wait until rising_edge(clk);
    bus_i.addr <= std_logic_vector(to_unsigned(16#804#, 15));
    bus_i.data <= x"0000";              
    bus_i.we   <= '1';
    wait until rising_edge(clk);
    bus_i.we   <= '0';


    ---------------------------------------------------------------------------
    -- set Control Register
    ---------------------------------------------------------------------------
    wait until rising_edge(clk);
    bus_i.addr <= std_logic_vector(to_unsigned(16#800#, 15));
    bus_i.data <= x"0002";              -- load accu0
    bus_i.we   <= '1';
    wait until rising_edge(clk);
    bus_i.we   <= '0';
    wait until rising_edge(clk);
    bus_i.addr <= std_logic_vector(to_unsigned(16#800#, 15));
    bus_i.data <= x"0001";              -- enable nco0
    bus_i.we   <= '1';
    wait until rising_edge(clk);
    bus_i.we   <= '0';

    wait for 30 us;



  end process waveform;
end tb;
