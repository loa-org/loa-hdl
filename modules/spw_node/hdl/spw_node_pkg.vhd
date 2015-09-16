-------------------------------------------------------------------------------
-- Title      : SPW_NODE package
-------------------------------------------------------------------------------
-- Standard   : VHDL'x
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2015 Carl Treudler
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reset_pkg.all;
use work.bus_pkg.all;

package spw_node_pkg is

  --
  -- SPW_NODE 
  --

  component spw_node
    generic (
      BASE_ADDRESS : integer range 0 to 16#7FFF#;
      RESET_IMPL   : reset_type := none
      );
    port(
      -- spacewire interface
      -- (differential buffers should be placed in toplevel.)
      do_p : out std_logic;
      so_p : out std_logic;
      di_p : in  std_logic;
      si_p : in  std_logic;

      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;
      reset : in  std_logic;
      clk   : in  std_logic);

  end component;

end spw_node_pkg;
