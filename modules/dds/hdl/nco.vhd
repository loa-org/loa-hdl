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
use work.nco_pkg.all;
use work.bus_pkg.all;
use work.reset_pkg.all;


entity nco is
  generic (
    ACCU_WIDTH  : natural    := 16;
    PHASE_WIDTH : natural    := 8;
    RESET_IMPL  : reset_type := none);
  port (
    en              : in  std_logic;
    phase_increment : in  std_logic_vector(ACCU_WIDTH-1 downto 0);
    phase           : out std_logic_vector(PHASE_WIDTH-1 downto 0);

    load      : in std_logic;
    accu_load : in std_logic_vector(ACCU_WIDTH-1 downto 0);

    reset : in std_logic;
    clk   : in std_logic);
end entity nco;

architecture behavioral of nco is
  type nco_state_type is record
    accu : std_logic_vector(ACCU_WIDTH-1 downto 0);
  end record nco_state_type;
  constant nco_state_initial : nco_state_type := (accu => (others => '0'));
  signal r, rin              : nco_state_type := nco_state_initial;
begin  -- architecture behaviorall

  phase <= r.accu(ACCU_WIDTH-1 downto (ACCU_WIDTH - PHASE_WIDTH));

  comb : process (accu_load, en, load, phase_increment, r, reset) is
    variable v : nco_state_type;
  begin  -- process comb
    v := r;
    -- here usually goes the case statement for the FSMs state .. but not today

    if load = '1' then
      v.accu := accu_load;
    elsif en = '1' then
      v.accu :=
        std_logic_vector(
          resize(
            to_unsigned(to_integer(unsigned(r.accu)) +
                        to_integer(unsigned(phase_increment)),
                        16
                        ), 16)
          );                            -- numeric_std loves you
    end if;

    -- sync reset
    if RESET_IMPL = sync and reset = '1' then
      v := nco_state_initial;
    end if;
    rin <= v;
  end process comb;

  async_reset : if RESET_IMPL = async generate
    seq : process (clk, reset) is
    begin  -- process seq
      if reset = '0' then                 -- asynchronous reset (active low)
        r <= nco_state_initial;
      elsif clk'event and clk = '1' then  -- rising clock edge
        r <= rin;
      end if;
    end process seq;
  end generate;

  sync_reset : if RESET_IMPL /= async generate
    seq : process (clk) is
    begin  -- process seq
      if clk'event and clk = '1' then   -- rising clock edge
        r <= rin;
      end if;
    end process seq;
  end generate;

end architecture behavioral;
