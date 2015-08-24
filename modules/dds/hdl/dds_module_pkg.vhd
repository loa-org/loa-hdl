-------------------------------------------------------------------------------
-- Title      : Direct digital synhtesis module 
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

library work;
use work.bus_pkg.all;
use work.reset_pkg.all;
library ieee;
use ieee.std_logic_1164.all;

package dds_module_pkg is

  component dds_module is
    generic (
      BASE_ADDRESS : integer range 0 to 2**15-1;
      RESET_IMPL   : reset_type := none);
    port (
      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;
      dout  : out std_logic_vector(15 downto 0);
      reset : in  std_logic;
      clk   : in  std_logic);
  end component dds_module;

end package dds_module_pkg;
