-------------------------------------------------------------------------------
-- Title      : SpaceWire Node Module
-------------------------------------------------------------------------------
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description: This module interfaces a SpW stram core with the Loa bus.
-- Timecode featrues aren't accessible.
-- RX and TX FIFOs are accessible via a single address. The data is combined
-- with fifo status flags, eleminating additional polling of the FIFO flags.
--
-- Note: This module supports only synchronous resets, due to the
--       encapsulated ip-core 
--
-------------------------------------------------------------------------------
-- Copyright (c) 2015 Carl Treudler
-------------------------------------------------------------------------------
-- The file is part for the Loa project and is released under the
-- 3-clause BSD license. See the file `LICENSE` for the full license
-- governing this code.
-------------------------------------------------------------------------------
--
-- Register Map
-------------------------------------------------------------------------------
-- BASE       FIFO Rx & Tx (RW)
--
-- ro  d15 tx fifo half full               
-- ro  d14 tx fifo ready
-- ro  d13 rx fifo halffull
-- ro  d12 rx fifo valid (word ready to read)
--     (..) unused
-- rw   d8 flag-bit of data 
-- rw   d7..d0 data
--
-------------------------------------------------------------------------------
-- BASE + 1   Status (RO)
--
-- ro  d15 tx fifo half full               
-- ro  d14 tx fifo ready
-- ro  d13 rx fifo halffull
-- ro  d12 rx fifo valid (word ready to read)
--     (..) unused
-- ro   d6 started
-- ro   d5 connecting
-- ro   d4 running
-- ro   d3 errdisc
-- ro   d2 errpar
-- ro   d1 erresc
-- ro   d0 errcred
--
-------------------------------------------------------------------------------
-- BASE + 2   Control Reg. (RW)
--
-- rw  d15..d8 tx baudrate divider 
--     (..) unused
-- rw   d2 linkdis
-- rw   d1 linkstart
-- rw   d0 autostart
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.reset_pkg.all;
use work.spwpkg.all;
use work.bus_pkg.all;
-------------------------------------------------------------------------------

entity spw_node is
  generic (
    BASE_ADDRESS : integer range 0 to 16#7FFF#;
    RESET_IMPL   : reset_type := sync);
  port (
    do_p  : out std_logic;
    so_p  : out std_logic;
    di_p  : in  std_logic;
    si_p  : in  std_logic;
    bus_o : out busdevice_out_type;
    bus_i : in  busdevice_in_type;
    reset : in  std_logic;
    clk   : in  std_logic);
end entity spw_node;

architecture behavioural of spw_node is
  signal txwrite : std_logic;
  signal txflag  : std_logic;
  signal txdata  : std_logic_vector(7 downto 0);
  signal txrdy   : std_logic;
  signal txhalff : std_logic;

  signal rxvalid : std_logic;
  signal rxhalff : std_logic;
  signal rxflag  : std_logic;
  signal rxdata  : std_logic_vector(7 downto 0);
  signal rxread  : std_logic;

  -- link control signal 
  signal autostart : std_logic;
  signal linkstart : std_logic;
  signal linkdis   : std_logic;
  signal txdivcnt  : std_logic_vector(7 downto 0);

  -- link status signals
  signal started    : std_logic;
  signal connecting : std_logic;
  signal running    : std_logic;
  signal errdisc    : std_logic;
  signal errpar     : std_logic;
  signal erresc     : std_logic;
  signal errcred    : std_logic;

  -- Status and Control Register
  signal statusword     : std_logic_vector(3 downto 0);
  signal ext_statusword : std_logic_vector(6 downto 0);
  signal ctrlword       : std_logic_vector(15 downto 0) := (others => '0');

  signal bus_o_data : std_logic_vector(15 downto 0) := (others => '0');
begin
  -----------------------------------------------------------------------------
  -- signal mapping and bit definition of registers
  -----------------------------------------------------------------------------

  -- short status word, also delivered for each read of the fifo 
  statusword <= txhalff & txrdy & rxhalff & rxvalid;

  -- extended status word, delivered together with short statusword via a
  -- read from the status register
  ext_statusword <= started & connecting & running & errdisc & errpar & erresc & errcred;

  -- control register
  autostart <= ctrlword(0);
  linkstart <= ctrlword(1);
  linkdis   <= ctrlword(2);
  txdivcnt  <= ctrlword(15 downto 8);

  -- generate fifo read and write strobes
  rxread  <= '1' when (bus_i.re = '1' and bus_i.addr = std_logic_vector(to_unsigned(BASE_ADDRESS + 0, 15))) else '0';
  txwrite <= '1' when (bus_i.we = '1' and bus_i.addr = std_logic_vector(to_unsigned(BASE_ADDRESS + 0, 15))) else '0';

  -- mapping of bus to tx fifo
  txdata <= bus_i.data(7 downto 0);
  txflag <= bus_i.data(8);

  bus_o.data <= bus_o_data;

  -----------------------------------------------------------------------------
  -- Adhoc implementation of bus output
  -----------------------------------------------------------------------------
  control_reg : process (clk) is
  begin  -- process
    if rising_edge(clk) then
      -- this module doesn't support async reset, as the spw codec doesn't anyway
      if reset = '0' then
        if bus_i.we = '1' and bus_i.addr = std_logic_vector(to_unsigned(BASE_ADDRESS + 2, 15)) then
          ctrlword <= bus_i.data;
        end if;

        if (bus_i.re = '1' and bus_i.addr = std_logic_vector(to_unsigned(BASE_ADDRESS + 0, 15))) then
          bus_o_data <= statusword & "000" & rxflag & rxdata;
        elsif (bus_i.re = '1' and bus_i.addr = std_logic_vector(to_unsigned(BASE_ADDRESS + 1, 15))) then
          bus_o_data <= statusword & "00000" & ext_statusword;
        elsif (bus_i.re = '1' and bus_i.addr = std_logic_vector(to_unsigned(BASE_ADDRESS + 2, 15))) then
          bus_o_data <= ctrlword;
        else
          bus_o_data <= (others => '0');
        end if;
      else                              --reset
        ctrlword   <= (others => '0');
        bus_o_data <= (others => '0');
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Spw Stream Core instantiation
  ----------------------------------------------------------------------------
  spwstream_1 : entity work.spwstream
    generic map (
      sysfreq         => 50000000.0,
      txclkfreq       => 50000000.0,
      rximpl          => impl_generic,
      rxchunk         => 1,
      tximpl          => impl_generic,
      rxfifosize_bits => 11,
      txfifosize_bits => 11)

    port map (
      -- clk and rst
      clk   => clk,
      rxclk => clk,
      txclk => clk,
      rst   => reset,

      -- link controls
      autostart => autostart,
      linkstart => linkstart,
      linkdis   => linkdis,
      txdivcnt  => txdivcnt,

      -- Timecodes are currently not supported 
      tick_in  => '0',
      ctrl_in  => (others => '0'),
      time_in  => (others => '0'),
      tick_out => open,
      ctrl_out => open,
      time_out => open,

      -- tx fifo interface
      txwrite => txwrite,
      txflag  => txflag,
      txdata  => txdata,
      txrdy   => txrdy,
      txhalff => txhalff,

      -- rx fifo interface
      rxvalid => rxvalid,
      rxhalff => rxhalff,
      rxflag  => rxflag,
      rxdata  => rxdata,
      rxread  => rxread,

      -- link status 
      started    => started,
      connecting => connecting,
      running    => running,
      errdisc    => errdisc,
      errpar     => errpar,
      erresc     => erresc,
      errcred    => errcred,

      -- actual SpW Link 
      spw_di => di_p,
      spw_si => si_p,
      spw_do => do_p,
      spw_so => so_p
      );

end behavioural;
