-------------------------------------------------------------------------------
-- Title      : Numerically controlled oscillator - NCO
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
use work.reset_pkg.all;

package nco_pkg is

  component nco is
    generic (
      ACCU_WIDTH  : natural;
      PHASE_WIDTH : natural;
      RESET_IMPL  : reset_type);
    port (
      en              : in  std_logic;
      phase_increment : in  std_logic_vector(ACCU_WIDTH-1 downto 0);
      phase           : out std_logic_vector(PHASE_WIDTH-1 downto 0);
      load            : in  std_logic;
      accu_load       : in  std_logic_vector(ACCU_WIDTH-1 downto 0);
      reset           : in  std_logic;
      clk             : in  std_logic);
  end component nco;

end package nco_pkg;

package body nco_pkg is

end package body nco_pkg;
