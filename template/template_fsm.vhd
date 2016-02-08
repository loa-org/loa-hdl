-------------------------------------------------------------------------------
-- Title      : xyz 
-- Project    : LOA Project - HDL Part
-------------------------------------------------------------------------------
-- File       : template_fsm.vhd
-- Author     : 
-- Company    : 
-- Created    : 2015-mm-dd
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: This is a Template for FSMs in 2-process description style.
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.reset_pkg.all;

entity xyz is

  generic (
    RESET_IMPL : reset_type := none);

  port (
    reset : in std_logic_1164;
    clk   : in std_logic);

end entity xyz;



-------------------------------------------------------------------------------
architecture behavioural of xyz is

  type xyz_state_type is (IDLE, START);

  type xyz_type is record
    state      : xyz_state_type;
    somesignal : std_logic;
  end record;

  constant xyz_rx_type_initial : xyz_type := (
    state      => IDLE,
    somesignal => '0');

  signal r, rin : xyz_type := xyz_type_initial;



begin

  bus_o.data <= r.dout;


  -----------------------------------------------------------------------------
  -- Combinatorial part of FSM
  -----------------------------------------------------------------------------
  comb_proc : process(r, reset)
    variable v : xyz_rx_type;
  begin
    v := r;
    case r.state is
      when IDLE =>

    end case;

    -- sync reset
    if RESET_IMPL = sync then
      if reset = '1' then
        v := xyz_type_initial;
      end if;
    end if;

    rin <= v;
  end process comb_proc;

  ----------------------------------------------------------------------------
  -- Sequential part of finite state machine (FSM)
  ----------------------------------------------------------------------------
  reset_async : if RESET_IMPL = async generate
    seq_proc : process(clk, reset)
    begin
      if reset = '1' then
        r <= xyz_type_initial;          -- async reset
      elsif rising_edge(clk) then
        r <= rin;
      end if;
    end process seq_proc;
  end generate reset_async;

  reset_sync : if not (RESET_IMPL = async) generate
    seq_proc : process(clk)
    begin
      if rising_edge(clk) then
        r <= rin;
      end if;
    end process seq_proc;
  end generate reset_sync;

end architecture xyz;
